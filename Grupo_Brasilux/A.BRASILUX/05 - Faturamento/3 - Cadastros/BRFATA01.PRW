//#include 'brasilux.ch'
#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATA01 ºAutor  ³ Luís G. de Souza   º Data ³  07/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Bordero de Despacho (CARGAS)                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  Alterações: Cleber Orati Domingues -> Antigo BRFAT074                     
              Luís Gustavo de Souza  -> Melhorias nas telas do programa, alteração
                                        nos nomes das funções, utilização de objetos.
*/
User Function BRFATA01()
     Local   cAcessos  := ""
     Private cCadastro := "Bordero de Despacho (CARGAS)"
     Private lPodeBaixar := .f.

   	 If !u_VldAcesso(funname())
		MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
	 	Return 
 	 Endif 

     Private aRotina   := { {"Pesquisa"             , 'AxPesqui'       , 0 , 1 },;
                            {"Visualizar"           , 'U_FATA01_1("V")', 0 , 2 } }     
/*
                            {"Incluir"              , 'U_FATA01_1("I")', 0 , 3 },;
                            {"Alterar"              , 'U_FATA01_1("A")', 0 , 4 },;
                            {"Excluir"              , 'U_FATA01_1("E")', 0 , 5 },;
                            {"Baixar"               , 'U_FATA01_1("B")', 0 , 9 },;
                            {"Cancela Baixa"        , 'U_FATA01_1("C")', 0 , 9 },;
                            {"Conferência"          , 'U_FATA01_3()'   , 0 , 9 },;
                            {"Re-monta Desp."       , 'U_FATA06_6'   , 0 , 9 },;
                            {"Retirada"             , 'U_FATA01_4()'   , 0 , 9 },; */

     DbSelectArea("SZW")
     DbSetOrder(4)
     DbSeek(xFilial("SZW")+'BRFATA01  '+RetCodUsr()+substr(cNumEmp,1,2)+substr(cNumEmp,FWSizeFilial()+1,2), .t.)
     If Found()
        cAcessos := SZW->ZW_ACESSOS
     Endif

     If Substr(cAcessos, 2, 1) $ '*' // Manutenção
 	     aadd(aRotina,    { OemToAnsi('Incluir')      , 'U_FATA01_1("I")', 0 , 3 } )
 	     aadd(aRotina,    { OemToAnsi('Alterar')      , 'U_FATA01_1("A")', 0 , 4 } )
 	     aadd(aRotina,    { OemToAnsi('Excluir')      , 'U_FATA01_1("E")', 0 , 5 } )
 	     aadd(aRotina,    { OemToAnsi('Baixar ')      , 'U_FATA01_1("B")', 0 , 6 } )
 	     aadd(aRotina,    { OemToAnsi('Cancela Baixa'), 'U_FATA01_1("C")', 0 , 7 } )
 	     aadd(aRotina,    { OemToAnsi('Conferência')  , 'U_FATA01_3()'   , 0 , 8 } )
 	     aadd(aRotina,    { OemToAnsi('Retirada')     , 'U_FATA01_4()'   , 0 , 9 } )
		 aadd(aRotina,    { OemToAnsi('Imp Endereços'), 'U_fImpLocl()'   , 0 , 9 } )
	 Endif       
     If Substr(cAcessos, 3, 1) $ '*' // Re-Monta Desp.
 	     aadd(aRotina,    { OemToAnsi('Re-monta Desp.'), 'U_FATA06_6()', 0 , 9 } )
 	 Endif       
     
     /*If Substr(cAcessos, 4, 1) $ '*' // Limpa Endereço SZG
 	     aadd(aRotina,    { OemToAnsi('Libera Endereço'), 'u_FATA01_1("L") ', 0 , 9 } )
 	 Endif*/

     If Substr(cAcessos, 5, 1) $ '*' // Envia e-mail para transportadora solicitando coleta ? 	 
 	     aadd(aRotina,    { OemToAnsi('Solicita Coleta Depósito?'), 'U_WFMAILTR()', 0 , 9 } ) 	        
 	 Endif
	 aadd(aRotina,    { OemToAnsi('Rel. de Faltas')  , 'U_BRFATR12("M")', 0 , 9 } )
	 aadd(aRotina,    { OemToAnsi('Legenda')         , 'U_FATA01_2()'   , 0 , 9 } )

    
     Private aCores    := { { 'SZA->ZA_FLAG $ " .N"', 'ENABLE'   },; //Não despachado
                            { 'SZA->ZA_FLAG == "C"', 'BR_AMARELO'},; //Conferência
                            { 'SZA->ZA_FLAG == "P"', 'BR_AZUL'   },; //Separado Parcialmente
                            { 'SZA->ZA_FLAG == "T"', 'BR_PRETO'  },; //Separado Totalmente
                            { 'SZA->ZA_FLAG == "S"', 'DISABLE'   } } //Baixado

     DbSelectArea("SZA")
     DbSetOrder(1)
     
     //Set Key VK_F10 To fAtvF10() desabilitado release 12.1.25
     SetKey( VK_F10, { || fAtvF10() } )

     mBrowse(06, 01, 22, 80, "SZA", , , , , , aCores)
     //Set Key VK_F10 To 
Return

Static Function fAtvF10()
       Local oDlg
       Local cMemo
       Local oFont
       Local cQry1 := ""
       Local cAux1 := ""
       Local nSomPes := 0
       Local nSomVol := 0
       Local nSomFat := 0
       Local nSomNFt := 0
       SetKey(VK_F10, Nil)
       cMemo := "+-------------------------------------------------------------------------------------------------------+"+Chr(13)+Chr(10)
       cMemo += "| BORDERO  REGIÃO                          PREVISÃO  PESO        VOLUME  NÃO FATURADO    FATURADO       |"+Chr(13)+Chr(10)
       cMemo += "+-------------------------------------------------------------------------------------------------------+"+Chr(13)+Chr(10)

       cQry1 += "SELECT SZA.ZA_CODIGO, SZA.ZA_DESCR, SZA.ZA_PREVDSP, SZA.ZA_PESO, SZA.ZA_VOLUME,ZA_KMVIAGE,ZA_CONSUMO "
       cQry1 += "FROM "+RetSqlName("SZA")+" SZA WITH (NOLOCK) "
       cQry1 += "WHERE SZA.ZA_FILIAL  = '"+xFilial("SZA")+"' "
       cQry1 += "  AND SZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZA.ZA_DTDESPA = '' "
       cQry1 += "ORDER BY SZA.ZA_PREVDSP "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       While !Eof()
             //         1         2         3         4         5         6         7     
             //123456789012345678901234567890123456789012345678901234567890123456789012345
             //+-------------------------------------------------------------------------------------------------------+
             //| BORDERO  REGIÃO                          PREVISÃO  PESO        VOLUME  NÃO FATURADO    FATURADO       |
             //+-------------------------------------------------------------------------------------------------------+
             //| 999999   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99/99/99  999,999.99  999999  999,999,999.99  999,999,999.99 |
             cQry1 := ""
             cQry1 += "SELECT SC6.C6_NOTA, SUM(SC6.C6_VALOR) AS TOTAL "
             cQry1 += "FROM "+RetSqlName("SZB")+" SZB WITH (NOLOCK) "
             cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON SC6.C6_FILIAL = SZB.ZB_FILIAL AND SC6.C6_NUM = SUBSTRING(SZB.ZB_PEDIDO, 3, 6) AND SC6.D_E_L_E_T_ = '' "
             cQry1 += "WHERE SZB.ZB_FILIAL  = '"+xFilial("SZB")+"' "
             cQry1 += "  AND SZB.D_E_L_E_T_ = '' "
             cQry1 += "  AND SZB.ZB_CODIGO = '"+TCQ->ZA_CODIGO+"' "
             cQry1 += "GROUP BY SC6.C6_NOTA "
             TCQuery cQry1 ALIAS "XPED" NEW
             DbSelectArea("XPED")
             xSomFat := 0
             xSomNFt := 0
             While !Eof()
                   If Empty(XPED->C6_NOTA)
                      nSomNFt += XPED->TOTAL
                      xSomNFt += XPED->TOTAL
                   Else
                      nSomFat += XPED->TOTAL
                      xSomFat += XPED->TOTAL
                   Endif
                   DbSelectArea("XPED")
                   DbSkip()
             Enddo
             cAux1 += "| "+TCQ->ZA_CODIGO+"   "+SubStr(TCQ->ZA_DESCR, 1, 30)+"  "+SubStr(TCQ->ZA_PREVDSP, 7, 2)+"/"+SubStr(TCQ->ZA_PREVDSP, 5, 2)+"/"+SubStr(TCQ->ZA_PREVDSP, 3, 2)+"  "+TransForm(TCQ->ZA_PESO, "@E 999,999.99")+"  "+TransForm(TCQ->ZA_VOLUME, "@E 999999")+"  "+TransForm(xSomNFt, "@E 999,999,999.99")+"  "+TransForm(xSomFat, "@E 999,999,999.99")+" |"+Chr(13)+Chr(10)
             nSomPes += TCQ->ZA_PESO
             nSomVol += TCQ->ZA_VOLUME
             DbSelectArea("XPED")
             DbCloseArea()
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       If !Empty(cAux1)
          cMemo += cAux1
          cMemo += "+-------------------------------------------------------------------------------------------------------+"+Chr(13)+Chr(10)
          cMemo += "|                                                    "+TransForm(nSomPes, "@E 999,999.99")+"  "+TransForm(nSomVol, "@E 999999")+"  "+TransForm(nSomNFt, "@E 999,999,999.99")+"  "+TransForm(nSomFat, "@E 999,999,999.99")+" |"+Chr(13)+Chr(10)
          cMemo += "+-------------------------------------------------------------------------------------------------------+"+Chr(13)+Chr(10)
          DEFINE FONT oFont NAME "Courier New"
          DEFINE MSDIALOG oDlg TITLE OemToAnsi("Saldos dos Borderos") From 0,0 to 330,775 PIXEL

                 @ 5,5 GET oMemo  VAR cMemo MEMO SIZE 380,145 HScroll OF oDlg PIXEL
                 oMemo:bRClicked := {||AllwaysTrue()}
                 oMemo:oFont:=oFont
                 oMemo:lReadOnly := .t.
                 DEFINE SBUTTON  FROM 153,350 TYPE 1 ACTION (oDlg:End()) ENABLE OF oDlg PIXEL
          ACTIVATE MSDIALOG oDlg CENTER
          SetKey(VK_F10, {|| fAtvF10()})
       Endif
Return

/*****************************************************************************************************************/
/*** FATA01_1 - Inclusão / Alteração / Exclusão / Visualização do bordero de despachos.                        ***/
/*****************************************************************************************************************/
User Function FATA01_1(cOpc, aColNew, nPesNew, nVolNew, cRegNew)
     Local lSaida       := .f.
     Local nUsado       := 0
     Local nLinhas      := 200
     Local nOpcG        := Iif(cOpc $ "V.E.S", 2, 3)
     Local cFieldOk     := Iif(cOpc $ "I.A", "U_FATA01_A(1, oGetD, aCols, aHeader, @nTotPes, @nTotVol, @oTotPes, @oTotVol, @nDelete)", "AllwaysTrue()")
     Local cLinOk       := Iif(cOpc $ "I.A", "U_FATA01_A(2, oGetD, aCols, aHeader, @nTotPes, @nTotVol, @oTotPes, @oTotVol, @nDelete)", "AllwaysTrue()")
     Local cTudoOk      := Iif(cOpc $ "I.A", "U_FATA01_A(3, oGetD, aCols, aHeader, @nTotPes, @nTotVol, @oTotPes, @oTotVol, @nDelete)", "AllwaysTrue()")
     Local cDeleOk      := Iif(cOpc $ "I.A", "U_FATA01_A(4, oGetD, aCols, aHeader, @nTotPes, @nTotVol, @oTotPes, @oTotVol, @nDelete)", "AllwaysTrue()")
     Local aAltGetDados := {"ZB_PEDIDO"}
     Local cCodigo      := CriaVar("ZA_CODIGO")
     Local dEmissa      := CriaVar("ZA_EMISSAO")
     //Local cTpIncl      := ""
     //Local aTpIncl      := {"Automatica", "Manual"}
     Local nOpcA        := 0
     Local aRet         := {}
     Local nY
     Local oDlg, oCodigo, oEmissa 
     Private aHeader    := {}
     SetKey(VK_F10, Nil)
     If aColNew <> Nil
        Private aCols      := aColNew
     Else
       Private aCols      := {}
     Endif
     Private oTotPes, oTotVol
     Private nTotPes    := 0
     Private nTotVol    := 0
     Private nDelete    := 0
     AADD(aAltGetDados,"ZB_LOCALIZ")

     If cOpc $ 'A.E.B'
        If !Empty(SZA->ZA_DTDESPA)
           ApMsgInfo("Bordero já está baixado.", "Atenção")
           SetKey(VK_F10, {|| fAtvF10()})
           Return
        Endif
     ElseIf cOpc $ 'C'
            If Empty(SZA->ZA_DTDESPA)
               ApMsgInfo("Bordero ainda não está baixado.", "Atenção")
               SetKey(VK_F10, {|| fAtvF10()})
               Return
            Endif
     Endif

     cCodigo := Iif(cOpc $ 'I', GetSXENum("SZA", "ZA_CODIGO"), SZA->ZA_CODIGO )
     dEmissa := Iif(cOpc $ 'I', dDataBase                    , SZA->ZA_EMISSAO)
     dDespac := Iif(cOpc $ 'I', ctod('  /  /  ')             , SZA->ZA_DTDESPA)
     dPrevis := Iif(cOpc $ 'I', ctod('  /  /  ')             , SZA->ZA_PREVDSP)
     cDescri := Iif(cOpc $ 'I', space(40)                    , SubStr(SZA->ZA_DESCR, 1, 40)  )
     If GETMV("MV_REGTRA") $ 'R'
        cRegiao := Iif(cOpc $ 'I', space(03)                 , Alltrim(SZA->ZA_REGIAO) )
     Else
        cRegiao := Iif(cOpc $ 'I', space(06)                 , SZA->ZA_REGIAO )
     Endif
     cVeicul := Iif(cOpc $ 'I', space(08)                    , SZA->ZA_CODVEI)
     cMotori := Iif(cOpc $ 'I', space(06)                    , SZA->ZA_CODMOT)
     cDesVei := Iif(cOpc $ 'I', space(40)                    , SubStr(Posicione("DA3", 1, xFilial("DA3")+SZA->ZA_CODVEI, "DA3_DESC"), 1, 40)  )
     cDesMot := Iif(cOpc $ 'I', space(40)                    , SubStr(Posicione("DA4", 1, xFilial("DA4")+SZA->ZA_CODMOT, "DA4_NOME"), 1, 40)  )
     
     If cOpc $ 'L'
      	u_FATA01LI(cCodigo)
      	cOpc := 'V'
     Endif
     

     If cOpc $ 'I'
        CONFIRMSX8()
     Endif

     fMonHea(1, @aHeader, @nUsado)
     If aColNew <> Nil
        nTotPes := nPesNew
        nTotVol := nVolNew
        cRegiao := cRegNew
        cDescri := Iif(GETMV("MV_REGTRA") $ 'R', Alltrim(Posicione("SX5", 1, xFilial("SX5")+'98'+cRegiao, "X5_DESCRI")), Alltrim(Posicione("SA4", 1, xFilial("SA4")+cRegNew, "A4_NOME")))
     Else
        fMonCol(1, @aHeader, @nUsado, @aCols, cOpc, cCodigo, @nTotPes, @nTotVol, @oTotPes, @oTotVol)
     Endif

     DEFINE MSDIALOG oDlg FROM 000,000 TO 027,085 TITLE OemToAnsi(cCadastro) OF oMainWnd
            @ 032,001 GROUP oGrp1 TO 115,322 LABEL  OemToAnsi('')                                    PIXEL OF oDlg
            @ 037,005 SAY OemToAnsi("Codigo:")                          COLOR CLR_HBLUE SIZE 030,009 PIXEL OF oDlg
            @ 036,035 MSGET oCodigo  VAR cCodigo  Picture "999999"                      SIZE 020,009 PIXEL OF oDlg
            @ 037,085 SAY OemToAnsi("Emissão:")                         COLOR CLR_HBLUE SIZE 030,009 PIXEL OF oDlg
            @ 036,110 MSGET oEmissa  VAR dEmissa                                        SIZE 040,009 PIXEL OF oDlg
            @ 037,165 SAY OemToAnsi("Despacho:")                                        SIZE 030,009 PIXEL OF oDlg
            @ 036,210 MSGET oDespac  VAR dDespac                                        SIZE 040,008 PIXEL OF oDlg
            @ 053,005 SAY OemToAnsi("Dt. Previs.:")                     COLOR CLR_HBLUE SIZE 030,009 PIXEL OF oDlg
            @ 052,035 MSGET oPrevis  VAR dPrevis                                        SIZE 040,008 PIXEL OF oDlg
            @ 053,085 SAY OemToAnsi("Peso:")                            COLOR CLR_HBLUE SIZE 030,009 PIXEL OF oDlg
            @ 052,110 MSGET oTotPes  VAR nTotPes Picture "@E 99,999.99"                 SIZE 030,009 PIXEL OF oDlg
            @ 053,165 SAY OemToAnsi("Volume:")                          COLOR CLR_HBLUE SIZE 030,009 PIXEL OF oDlg
            @ 052,210 MSGET oTotVol  VAR nTotVol Picture "@E 99,999"                    SIZE 040,009 PIXEL OF oDlg
            If GETMV("MV_REGTRA") $ 'R'
               @ 069,005 SAY OemToAnsi("Região:")                          COLOR CLR_HBLUE SIZE 030,009 PIXEL OF oDlg
               @ 068,035 MSGET oRegiao  VAR cRegiao Picture "@!"  F3 "98"                  SIZE 015,009 PIXEL OF oDlg
            Else
               @ 069,005 SAY OemToAnsi("Transp.:")                         COLOR CLR_HBLUE SIZE 030,009 PIXEL OF oDlg
               @ 068,035 MSGET oRegiao  VAR cRegiao Picture "@!"  F3 "SA4"                 SIZE 015,009 PIXEL OF oDlg
            Endif
            @ 068,075 MSGET oDescri  VAR cDescri               WHEN .T.                 SIZE 140,008 PIXEL OF oDlg
            @ 085,005 SAY OemToAnsi("Veiculo:")                         COLOR CLR_HBLUE SIZE 030,009 PIXEL OF oDlg
            @ 084,035 MSGET oVeicul  VAR cVeicul Picture "@!"  F3 "DA3"                 SIZE 030,009 PIXEL OF oDlg
            @ 084,075 MSGET oDesVei  VAR cDesVei               WHEN .F.                 SIZE 140,008 PIXEL OF oDlg
            @ 099,005 SAY OemToAnsi("Motorista:")                       COLOR CLR_HBLUE SIZE 030,009 PIXEL OF oDlg
            @ 100,035 MSGET oMotori  VAR cMotori Picture "@!"  F3 "DA4"                 SIZE 030,009 PIXEL OF oDlg
            @ 100,075 MSGET oDesMot  VAR cDesMot               WHEN .F.                 SIZE 140,008 PIXEL OF oDlg

            oGetD         := MsGetDados():New( 115, 020, 200, 286, nOpcG, cLinOk, cTudoOk, "", If(cOpc $ 'V.E.S', .f., .t.), aAltGetDados,  ,   , nLinhas, cFieldOk,   ,  , cDeleOk,   )
            //                                  |    |    |    |     |      |       |      |                 |                    |        |   |     |        |      |   |     |    |
            //                                 01º  02º  03º  04º   05º    06º     07º    08º               09º                  10º      11º 12º   13º      14º    15º 16º   17º  18º
            //                                  |    |    |    |     |      |       |      |                 |                    |        |   |     |        |      |   |     |    |
            //                                  |    |    |    |     |      |       |      |                 |                    |        |   |     |        |      |   |     |    +->> Objeto n qual MsGetDados será criado
            //                                  |    |    |    |     |      |       |      |                 |                    |        |   |     |        |      |   |     +------>> Função para validação da exclusão de uma linha do aCols
            //                                  |    |    |    |     |      |       |      |                 |                    |        |   |     |        |      |   +------------>> Reservado
            //                                  |    |    |    |     |      |       |      |                 |                    |        |   |     |        |      +---------------->> Função executada quando pressionado <CTRL + DEL>
            //                                  |    |    |    |     |      |       |      |                 |                    |        |   |     |        +----------------------->> Função para validação de campos digitados
            //                                  |    |    |    |     |      |       |      |                 |                    |        |   |     +-------------------------------->> Numero de linhas da getdados
            //                                  |    |    |    |     |      |       |      |                 |                    |        |   +-------------------------------------->> 
            oDlg:nStyle    := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
            oCodigo:bWhen  := {|| .f. } ; oEmissa:bWhen := {|| .f. } ; oDespac:bWhen := {|| .f. }
            oTotPes:bWhen  := {|| .f. } ; oTotVol:bWhen := {|| .f. }
            oRegiao:bValid := {|| fValCam(1, @cRegiao, @cDescri)}
            oVeicul:bValid := {|| fValCam(2, @cVeicul, @cDesVei)}
            oMotori:bValid := {|| fValCam(3, @cMotori, @cDesMot)}
            If !cOpc $ 'I.A'
               oPrevis:bWhen := {|| .f. } ; oDescri:bWhen := {|| .f. } ; oRegiao:bWhen := {|| .f. }
               oVeicul:bWhen := {|| .f. } ; oMotori:bWhen := {|| .f. }
               //oLocali:bWhen := {|| .f. }
            Endif
            If cOpc $ 'B'
               oDespac:bWhen := {|| .t. }
            Endif
     ACTIVATE MSDIALOG oDlg CENTERED VALID lSaida ON INIT EnchoiceBar( oDlg, {|| Iif(oGetD:TudoOk(), nOpcA := 1, nOpcA := 0), Iif(nOpcA == 1, lSaida := .t., nOpcA := 0), Iif(nOpcA == 1, oDlg:End(), nOpcA := 0) }, {|| nOpcA := 0, lSaida := .t., oDlg:End()} )
     SetKey(VK_F10, {|| fAtvF10()})
     If nOpcA == 1
        If cOpc == "I"
           //Inclui na tabela de cabeçalho do bordero de despacho
           RecLock("SZA", .t.)
              SZA->ZA_FILIAL  := xFilial("SZA")
              SZA->ZA_CODIGO  := cCodigo
              SZA->ZA_EMISSAO := dEmissa
              SZA->ZA_DTDESPA := dDespac
              SZA->ZA_DESCR   := cDescri
              SZA->ZA_PREVDSP := dPrevis
              SZA->ZA_VOLUME  := nTotVol
              SZA->ZA_PESO    := nTotPes
              SZA->ZA_REGIAO  := cRegiao
              SZA->ZA_CODVEI  := cVeicul
              SZA->ZA_NOMVEI  := cDesVei
              SZA->ZA_CODMOT  := cMotori
              SZA->ZA_NOMMOT  := cDesMot
              //SZA->ZA_LOCALIZ := cLocali
           MsUnLock()
           //Inclui na tabela de itens do pedido
           For nY := 1 To Len(aCols)
               If !aCols[nY][nUsado+1]
                  RecLock("SZB", .t.)
                     SZB->ZB_FILIAL := xFilial("SZB")
                     SZB->ZB_CODIGO := cCodigo
					cAux := alltrim(aCols[nY][1])
					cAux := substr(cNumEmp,1,2)+substr(cAux,len(cAux)-5,6)
                     SZB->ZB_PEDIDO := cAux //aCols[nY][1]
                     SZB->ZB_RAZAO  := aCols[nY][2]
                  MsUnLock()
                  aAdd(aRet, {aCols[nY][1]})
                  DbSelectArea("SC6")
                  DbSetOrder(1)
                  DbSeek(xFilial("SC6")+SubStr(aCols[nY][1], 3, 6), .t.)
                  If Found()
                     While !Eof() .and. SC6->C6_NUM == SubStr(aCols[nY][1], 3, 6)
                           DbSelectArea("ZZC")
                           DbSetOrder(2)
                           DbSeek(xFilial("ZZC")+SC6->C6_NUM+SC6->C6_PRODUTO, .t.)
                           If Found()
                              RecLock("ZZC", .f.)
                                 ZZC->ZZC_CARGA  := cCodigo
                              MsUnLock()
                           Else                        
                           	//Cleber (29/08/12)->estava procurando em SZG!!! André - retorna busca do bordero de pedidos SZG 11-06-14
                              //cNumBor :=Posicione("SZB", 2, xFilial("SZB")+aCols[nY][1], "ZB_CODIGO")
                              cNumBor := Posicione("SZG", 2, xFilial("SZG")+aCols[nY][1], "ZG_CODIGO")
                              If !Empty(cNumBor)
                                 RecLock("ZZC", .t.)
                                    ZZC->ZZC_FILIAL := xFilial("ZZC")
                                    ZZC->ZZC_BORDER := cNumBor
                                    ZZC->ZZC_PEDIDO := SC6->C6_NUM
                                    ZZC->ZZC_PRODUT := SC6->C6_PRODUTO
                                    ZZC->ZZC_QUANTI := SC6->C6_QTDVEN
                                    ZZC->ZZC_RETIRA := 0
                                    ZZC->ZZC_VOLUME := SC6->C6_VOLITEM
                                    ZZC->ZZC_VOLRET := 0
                                    ZZC->ZZC_CARGA  := cCodigo
                                    ZZC->ZZC_OCUPAC := 0
                                    ZZC->ZZC_DESPAC := ""
                                    ZZC->ZZC_GAVETA := ""
                                    ZZC->ZZC_SEPARA := ""
                                 MsUnLock()
                              Endif
                           Endif
                           DbSelectArea("SC6")
                           DbSkip()
                     Enddo
                  Endif
               Endif
           Next
           If aColNew <> Nil
              Return(aRet)
           Else
              Return(.t.)
           Endif
        ElseIf cOpc == "A"
               //Inclui na tabela de cabeçalho do bordero de despacho
               RecLock("SZA", .f.)
                  SZA->ZA_DESCR   := cDescri
                  SZA->ZA_PREVDSP := dPrevis
                  SZA->ZA_VOLUME  := nTotVol
                  SZA->ZA_PESO    := nTotPes
                  SZA->ZA_REGIAO  := cRegiao
                  SZA->ZA_CODVEI  := cVeicul
                  SZA->ZA_NOMVEI  := cDesVei
                  SZA->ZA_CODMOT  := cMotori
                  SZA->ZA_NOMMOT  := cDesMot
                  //SZA->ZA_LOCALIZ := cLocali
               MsUnLock()
               //Altera na tabela de itens do bordero
               For nY := 1 To Len(aCols)
                   DbSelectArea("SZB")
                   DbSetOrder(1)
                   DbSeek(xFilial("SZB")+cCodigo+aCols[nY][1], .t.)
                   If Found()
                      If !aCols[nY][nUsado+1]
                         RecLock("SZB", .f.)
                            SZB->ZB_FILIAL := xFilial("SZB")
                            SZB->ZB_CODIGO := cCodigo
							cAux := alltrim(aCols[nY][1])
							cAux := substr(cNumEmp,1,2)+substr(cAux,len(cAux)-5,6)
                            SZB->ZB_PEDIDO := cAux //aCols[nY][1]
                            SZB->ZB_RAZAO  := aCols[nY][2]
                            SZB->ZB_LOCALIZ  := aCols[nY][3]
                         MsUnLock()
                         DbSelectArea("SC6")
                         DbSetOrder(1)
                         DbSeek(xFilial("SC6")+SubStr(aCols[nY][1], 3, 6), .t.)
                         If Found()
                            While !Eof() .and. SC6->C6_NUM == SubStr(aCols[nY][1], 3, 6)
                                  DbSelectArea("ZZC")
                                  DbSetOrder(2)
                                  DbSeek(xFilial("ZZC")+SC6->C6_NUM+SC6->C6_PRODUTO, .t.)
                                  If Found()
                                     RecLock("ZZC", .f.)
                                        ZZC->ZZC_CARGA  := cCodigo
                                     MsUnLock()
                                  Else   
                                  	//(Cleber - 29/08/12)->ESTAVA PROCURANTO EM SZG!!  André - Retornou em 11-06-14
                                     //cNumBor := Posicione("SZB", 2, xFilial("SZB")+aCols[nY][1], "ZB_CODIGO")
                                     cNumBor := Posicione("SZG", 2, xFilial("SZG")+aCols[nY][1], "ZG_CODIGO")
                                     If !Empty(cNumBor)
                                        RecLock("ZZC", .t.)
                                           ZZC->ZZC_FILIAL := xFilial("ZZC")
                                           ZZC->ZZC_BORDER := cNumBor
                                           ZZC->ZZC_PEDIDO := SC6->C6_NUM
                                           ZZC->ZZC_PRODUT := SC6->C6_PRODUTO
                                           ZZC->ZZC_QUANTI := SC6->C6_QTDVEN
                                           ZZC->ZZC_RETIRA := 0
                                           ZZC->ZZC_VOLUME := SC6->C6_VOLITEM
                                           ZZC->ZZC_VOLRET := 0
                                           ZZC->ZZC_CARGA  := cCodigo
                                           ZZC->ZZC_OCUPAC := 0
                                           ZZC->ZZC_DESPAC := ""
                                           ZZC->ZZC_GAVETA := ""
                                           ZZC->ZZC_SEPARA := ""
                                        MsUnLock()
                                     Endif
                                  Endif
                                  DbSelectArea("SC6")
                                  DbSkip()
                            Enddo
                         Endif
                      Else //Se deletou o item
                         RecLock("SZB", .f.)
                            DbDelete()
                         MsUnLock()
                         DbSelectArea("ZZC")
                         DbSetOrder(4)
                         DbSeek(xFilial("ZZC")+cCodigo+SubStr(aCols[nY][1], 3, 6), .t.)
                         If Found()
                            cNumBor := ZZC->ZZC_BORDER
                            DbSelectArea("ZZC")
                            DbSetOrder(1)
                            DbSeek(xFilial("ZZC")+cNumBor+SubStr(aCols[nY][1], 3, 6), .t.)
                            If Found()
                               While !Eof() .and. ZZC->ZZC_BORDER == cNumBor .and. ZZC->ZZC_PEDIDO == SubStr(aCols[nY][1], 3, 6)
                                     RecLock("ZZC", .f.)
                                        ZZC->ZZC_CARGA := ""
                                     MsUnLock()
                                     DbSelectArea("ZZC")
                                     DbSkip()
                               Enddo
                            Endif
                         Endif
                      Endif
                   Else //Se não encontrado.
                      If !aCols[nY][nUsado+1]
                         RecLock("SZB", .t.)
                            SZB->ZB_FILIAL := xFilial("SZB")
                            SZB->ZB_CODIGO := cCodigo
							cAux := alltrim(aCols[nY][1])
							cAux := substr(cNumEmp,1,2)+substr(cAux,len(cAux)-5,6)
                            SZB->ZB_PEDIDO := cAux //aCols[nY][1]
                            SZB->ZB_RAZAO  := aCols[nY][2]
                            SZB->ZB_LOCALIZ := aCols[nY][3]
                         MsUnLock()
                         DbSelectArea("SC6")
                         DbSetOrder(1)
                         DbSeek(xFilial("SC6")+SubStr(aCols[nY][1], 3, 6), .t.)
                         If Found()
                            While !Eof() .and. SC6->C6_NUM == SubStr(aCols[nY][1], 3, 6)
                                  DbSelectArea("ZZC")
                                  DbSetOrder(2)
                                  DbSeek(xFilial("ZZC")+SC6->C6_NUM+SC6->C6_PRODUTO, .t.)
                                  If Found()
                                     RecLock("ZZC", .f.)
                                        ZZC->ZZC_CARGA  := cCodigo
                                     MsUnLock()
                                  Else                                                              
                                  	//Cleber (29/08/42)->Estava procurando em SZG!!  André - Retornou em 11-06-14
                                     //cNumBor := Posicione("SZB", 2, xFilial("SZB")+aCols[nY][1], "ZB_CODIGO") 
                                     cNumBor := Posicione("SZG", 2, xFilial("SZG")+aCols[nY][1], "ZG_CODIGO")
                                     If !Empty(cNumBor)
                                        RecLock("ZZC", .t.)
                                           ZZC->ZZC_FILIAL := xFilial("ZZC")
                                           ZZC->ZZC_BORDER := cNumBor
                                           ZZC->ZZC_PEDIDO := SC6->C6_NUM
                                           ZZC->ZZC_PRODUT := SC6->C6_PRODUTO
                                           ZZC->ZZC_QUANTI := SC6->C6_QTDVEN
                                           ZZC->ZZC_RETIRA := 0
                                           ZZC->ZZC_VOLUME := SC6->C6_VOLITEM
                                           ZZC->ZZC_VOLRET := 0
                                           ZZC->ZZC_CARGA  := cCodigo
                                           ZZC->ZZC_OCUPAC := 0
                                           ZZC->ZZC_DESPAC := ""
                                           ZZC->ZZC_GAVETA := ""
                                           ZZC->ZZC_SEPARA := ""
                                        MsUnLock()
                                     Endif
                                  Endif
                                  DbSelectArea("SC6")
                                  DbSkip()
                            Enddo
                         Endif
                      Endif
                   Endif
               Next
        ElseIf cOpc == "E"
               //Exclui na tabela de cabeçalho do bordero do pedido
               RecLock("SZA", .f.)
                  DbDelete()
               MsUnLock()
               //Exclui na tabela de itens do pedido
               For nY := 1 To Len(aCols)
                   DbSelectArea("SZB")
                   DbSetOrder(1)
                   DbSeek(xFilial("SZB")+cCodigo+aCols[nY][1], .t.)
                   If Found()
                      RecLock("SZB", .f.)
                         DbDelete()
                      MsUnLock()
                      DbSelectArea("ZZC")
                      DbSetOrder(4)
                      DbSeek(xFilial("ZZC")+cCodigo+SubStr(aCols[nY][1], 3, 6), .t.)
                      If Found()
                         cNumBor := ZZC->ZZC_BORDER
                         DbSelectArea("ZZC")
                         DbSetOrder(1)
                         DbSeek(xFilial("ZZC")+cNumBor+SubStr(aCols[nY][1], 3, 6), .t.)
                         If Found()
                            While !Eof() .and. ZZC->ZZC_BORDER == cNumBor .and. ZZC->ZZC_PEDIDO == SubStr(aCols[nY][1], 3, 6)
                                  RecLock("ZZC", .f.)
                                     ZZC->ZZC_CARGA := ""
                                  MsUnLock()
                                  DbSelectArea("ZZC")
                                  DbSkip()
                            Enddo
                         Endif
                      Endif
                   Endif
               Next
        ElseIf cOpc == "B"
               If Empty(dDespac)
                  MsgBox("Preencha a data de despacho!", "Atenção", "ALERT")
                  Return(.f.)
               Else
                  lPodeBaixar := .t.
                  DbSelectArea("SF2")
                  DbOrderNickName("SF2001")
                  DbSelectArea("SZB")
                  DbSeek(xFilial("SZB")+SZA->ZA_CODIGO, .t.)
                  If Found()
                     While !Eof() .and. SZB->ZB_FILIAL == xFilial("SZB") .AND. SZB->ZB_CODIGO == SZA->ZA_CODIGO
                           If SubStr(cNumEmp, 1, 2) == SubStr(SZB->ZB_PEDIDO, 1, 2)
                              //Utilizado quando tinha empresa 02
                              lOutraEmpresa := .f. 
                           Else
                              //Quando utilizava empresa 02
                              lOutraEmpresa := .t.
                           Endif
                           DbSelectArea("SF2")
                           If !DbSeek(xFilial("SF2")+SubStr(SZB->ZB_PEDIDO, 3, 6))
                              lPodeBaixar = .f.
                           Endif
                           DbSelectArea("SZB")
                           DbSkip()
                     Enddo
                     If lPodeBaixar
                        DbSelectArea("SZB")
                        DbSeek(xFilial("SZB")+SZA->ZA_CODIGO, .t.)
                        While !Eof() .and. (SZB->ZB_FILIAL == xFilial("SZB")) .AND. (SZB->ZB_CODIGO == SZA->ZA_CODIGO)
                              If SubStr(cNumEmp, 1, 2) == SubStr(SZB->ZB_PEDIDO, 1, 2)
                                 //Utilizado quando tinha empresa 02
                                 lOutraEmpresa := .f.
                              Else
                                 //Quando utilizava empresa 02
                                 lOutraEmpresa := .t.
                              Endif
                              //Incluir registro para as cargas despachadas.
                              DbSelectArea("SF2")
                              DbSeek(xFilial("SZB")+SubStr(SZB->ZB_PEDIDO, 3, 6))
                              If Found()
                                 //Enviar informação para o Brasrepres
                                 If ((cNumEmp = "01010101") .or. (cNumEmp = "01060101")) 
                                    U_EnviaRec("SC5", SubStr(SZB->ZB_PEDIDO, 3, 6), .F.,Posicione("SC5", 1, xFilial("SC5")+SubStr(SZB->ZB_PEDIDO, 3, 6), "C5_VEND1"))
                                 Endif
                              Endif
                              //Baixar Pedido da Retirada de pedidos
                              DbSelectArea("ZZC")
                              DbSetOrder(4)
                              DbSeek(xFilial("ZZC")+SZB->ZB_CODIGO+SubStr(SZB->ZB_PEDIDO, 3, 6), .t.)
                              While !Eof() .and. ZZC->ZZC_CARGA == SZB->ZB_CODIGO .and. ZZC->ZZC_PEDIDO == SubStr(SZB->ZB_PEDIDO, 3, 6)
                                    RecLock("ZZC", .f.)
                                       ZZC->ZZC_DESPAC := 'S'
                                    MsUnLock()
                                    DbSelectArea("ZZC")
                                    DbSkip()
                              Enddo
                              //Liberar endereço do pedido na expedição
                              cQry1 := ""
                              cQry1 += "UPDATE "+RetSqlName("SBE")+" SET BE_STATUS = '1', BE_BORDERO = '', BE_PEDIDO = '' WHERE BE_FILIAL = '"+xFilial("SBE")+"' AND BE_PEDIDO = '"+SubStr(SZB->ZB_PEDIDO, 3, 6)+"' "
                              TCSqlExec(cQry1)
                              DbSelectArea("SZB")
                              Dbskip()
                        EndDo
                        DbSelectArea("SZA")
                        RecLock("SZA", .F.)
                           SZA->ZA_DTDESPA := dDespac
                           SZA->ZA_FLAG    := 'S'
                        MsUnLock()
                        MsgAlert("Processo Finalizado!", "Finalizado")
                     Else
                        MsgAlert("Bordero Já Baixado anteriormente ou Pedido Não Faturado!", "A baixa não será executada!")
                     Endif
                  Endif
               Endif
        ElseIf cOpc == "C"
               If Empty(SZA->ZA_DTDESPA)
                  MsgAlert("Esse Bordero Nao Foi Baixado Antes!", "Atenção")
               Else
                  DbSelectArea("SZB")
                  DbSeek(xFilial("SZB")+SZA->ZA_CODIGO, .t.)
                  nCont := 0
                  While !Eof() .and. (SZB->ZB_FILIAL == xFilial("SZB")) .AND. (SZB->ZB_CODIGO == SZA->ZA_CODIGO)
                        If SubStr(cNumEmp, 1, 2) == SubStr(SZB->ZB_PEDIDO, 1, 2)
                           //Utilizado quando tinha empresa 02
                        Else
                           //Utilizado quando tinha empresa 02
                        Endif
                        DbSelectArea("ZZC")
                        DbSetOrder(4)
                        DbSeek(xFilial("ZZC")+SZB->ZB_CODIGO+SubStr(SZB->ZB_PEDIDO, 3, 6), .t.)
                        While !Eof() .and. ZZC->ZZC_CARGA == SZB->ZB_CODIGO .and. ZZC->ZZC_PEDIDO == SubStr(SZB->ZB_PEDIDO, 3, 6)
                              RecLock("ZZC", .f.)
                                 ZZC->ZZC_DESPAC := ' '
                              MsUnLock()
                              nCont++
                              DbSelectArea("ZZC")
                              DbSkip()
                        Enddo
                        DbSelectArea("SZB")
                        DbSkip()
                  Enddo
                  If nCont > 0
                     DbSelectArea("SZA")
                     RecLock("SZA", .F.)
                        SZA->ZA_DTDESPA := cTod(space(8))
                     	SZA->ZA_FLAG :='N'
                     MsUnLock()
                     MsgAlert("Processo Finalizado!", "Atenção")
                  Else
                     MsgAlert("Nenhuma Ocorrencia!", "Atenção")
                  Endif
               Endif
      
        Endif
     Else
        If aColNew <> Nil
           Return(aRet)
        Else
           Return(.t.)
        Endif
     Endif
Return

/*****************************************************************************************************************/
/*** fMonHea - Monta cabeçalho do acols                                                                        ***/
/*****************************************************************************************************************/
Static Function fMonHea(nOpc, aHeader, nUsado)

     Local _lOpen        := .F. // Adequação para release 12.1.25
     Local _cAliasSX3 := GetNextAlias() // Adequação para release 12.1.25
       
     // ABERTURA DO DICIONÁRIO SX3 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0

     If !_lOpen // Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
        Return
     Endif


     If nOpc == 1
     	/* desabilitado release 12.1.25
     	DbSelectArea("SX3")
        DbSetOrder(1)
        DbSeek("SZB")
        While !Eof() .And. (X3_ARQUIVO == "SZB")
        	If  Alltrim(X3_CAMPO) # "ZB_FILIAL"  .And.  Alltrim(X3_CAMPO) # "ZB_CODIGO"
        		nUsado += 1
        		AADD(aHeader, { TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
            Endif
            DbSkip()
        EndDo */

        DbSelectArea( _cAliasSX3 )
        ( _cAliasSX3 )->( DbSetOrder(1) )
        ( _cAliasSX3 )->( DbSeek("SZB") )
        While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SZB"
        	If  AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) # "ZB_FILIAL"  .And.  AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) # "ZB_CODIGO"
        		nUsado += 1
        		AADD(aHeader, { TRIM(( _cAliasSX3 )->(X3_TITULO)), ( _cAliasSX3 )->(X3_CAMPO), ( _cAliasSX3 )->(X3_PICTURE), ( _cAliasSX3 )->(X3_TAMANHO) , ( _cAliasSX3 )->(X3_DECIMAL), ( _cAliasSX3 )->(X3_VALID) , ( _cAliasSX3 )->(X3_USADO), ( _cAliasSX3 )->(X3_TIPO), ( _cAliasSX3 )->(X3_ARQUIVO), ( _cAliasSX3 )->(X3_CONTEXT) } )
            Endif
            DbSkip()
        EndDo       
        DbSelectArea( _cAliasSX3 )
        DbCloseArea()
        
     Endif
Return

/*****************************************************************************************************************/
/*** fMonCol - Monta aCols                                                                                     ***/
/*****************************************************************************************************************/
Static Function fMonCol(nOpc, aHeader, nUsado, aCols, cOpc, cCodigo, nTotPes, nTotVol, oTotPes, oTotVol)
       Local nY, nX
       If nOpc == 1
          If cOpc $ "V.E.A.S.B.C.L"
             DbSelectArea("SZB")
             DbSetOrder(1)
             DbSeek(xFilial("SZB")+cCodigo, .t.)
             If Found()
                While !Eof() .and. SZB->ZB_CODIGO == cCodigo
                      aAdd(aCols, Array(nUsado + 1))
                      For nY := 1 To nUsado
                          If Alltrim(aHeader[nY][2]) $ 'ZB_RAZAO'
                             aCols[Len(aCols)][nY] := Posicione("SA1", 1, xFilial("SA1")+Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[Len(aCols)][1], 3, 6), "C5_CLIENTE")+Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[Len(aCols)][1], 3, 6), "C5_LOJACLI"), "A1_NOME")
                          Else
                             aCols[Len(aCols)][nY] := SZB->&(aHeader[nY][2])
                          Endif
                      Next
                      aCols[Len(aCols)][nUsado + 1] := .F.
                      DbSelectArea("SZB")
                      DbSkip()
                Enddo
             Else
                aAdd(aCols, Array(nUsado + 1))
                For nX := 1 To nUsado
                    aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2])
                Next
                aCols[Len(aCols)][nUsado + 1] := .F.
             Endif
          Else
             aAdd(aCols, Array(nUsado + 1))
             For nX := 1 To nUsado
                 aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2])
             Next
             aCols[Len(aCols)][nUsado + 1] := .F.
          Endif
          nTotPes := 0 ; nTotVol := 0
          For nY := 1 To Len(aCols)
              If !aCols[nY][Len(aHeader)+1]
                 nTotPes += Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[nY][1], 3, 6), "C5_PBRUTO")
                 nTotVol += Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[nY][1], 3, 6), "C5_VOLUME1")
              Endif
          Next          
       Else     
			cQry1 := "SELECT SC6.C6_PRODUTO AS B1_COD, MAX(SC6.C6_DESCRI) AS B1_DESC, SC6.C6_LOCAL AS B1_LOCPAD, "+;
			"MAX(B2_LOCALIZ) AS B2_LOCALIZ,SUM(SC6.C6_QTDVEN) AS B2_QATU "+;
			"FROM "+RetSqlName("SZB")+" SZB WITH (NOLOCK) "+;
			"LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = ZB_FILIAL) AND (C6_NUM = SUBSTRING(ZB_PEDIDO, 3, 6)) "+;
			"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (C6_FILIAL = B1_FILIAL) AND (SC6.C6_PRODUTO = SB1.B1_COD) "+;
			"LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B1_FILIAL = B2_FILIAL) AND (B1_COD = B2_COD) AND (B1_LOCPAD = B2_LOCAL) "+;
			"WHERE (SZB.D_E_L_E_T_ <> '*') AND (SZB.ZB_FILIAL  = '"+xFilial("SZB")+"') AND "+;
			"(SZB.ZB_CODIGO  = '"+cCodigo+"') "+;
			"GROUP BY SC6.C6_FILIAL, SC6.C6_PRODUTO, SC6.C6_LOCAL "+;
			"ORDER BY B1_LOCPAD, B1_COD"
                 
          TCQuery cQry1 ALIAS "TCQ" NEW
          DbSelectArea("TCQ")
          DbGoTop()
          While !Eof()
                aAdd(aCols, Array(nUsado + 1))
                For nY := 1 To nUsado
                    If Alltrim(aHeader[nY][2]) $ 'B2_QFIM'
                       aCols[Len(aCols)][nY] := TCQ->B2_QATU
                    Else
                       aCols[Len(aCols)][nY] := TCQ->&(aHeader[nY][2])
                    Endif                
                Next
                aCols[Len(aCols)][nUsado + 1] := .F.
                DbSelectArea("TCQ")
                DbSkip()
          EndDo
          DbSelectArea("TCQ")
          DbCloseArea()
       Endif
Return

/*****************************************************************************************************************/
/*** FATA01_A - Validação da getdados.                                                                         ***/
/*****************************************************************************************************************/
User Function FATA01_A(nOpc, oGetD, aCols, aHeader, nTotPes, nTotVol, oTotPes, oTotVol, nDelete)
     Local lJaIncl := .f.
     Local nPosPed := aScan(aHeader, {|x| Trim(x[2]) == "ZB_PEDIDO"})
     Local nPosRaz := aScan(aHeader, {|x| Trim(x[2]) == "ZB_RAZAO" })
     Local nPosQtd := aScan(aHeader, {|x| Trim(x[2]) == "B2_QATU"})
     //Local nPosSep := aScan(aHeader, {|x| Trim(x[2]) == "B2_QFIM"})
     Local nY, nX
     
     If nOpc == 1
        If __ReadVar == "M->ZB_PEDIDO"
           DbSelectArea("SZB")
           DbSetOrder(2)
           DbSeek(xFilial("SZB")+M->ZB_PEDIDO, .t.)
           If Found()
              MsgBox("Pedido já digitado anteriormente!", "Atenção...", "STOP")
              Return(.f.)
           Endif
           lJaIncl := .f.
           For nY := 1 To Len(aCols)
               If nY <> n
                  If SubStr(M->ZB_PEDIDO, 3, 6) $ SubStr(aCols[nY][1], 3, 6) .and. !aCols[nY][Len(aHeader)+1]
                     lJaIncl := .t.
                  Endif
               Endif
           Next
           If lJaIncl
              MsgBox("Pedido já digitado nesse bordero!", "Atenção...", "STOP")
              Return(.f.)
           Endif
           If SubStr(M->ZB_PEDIDO, 1, 2) == SubStr(cNumEmp, 1, 2)
              DbSelectArea("SC5")
              DbSetOrder(1)
              DbSeek(xFilial("SC5")+SubStr(M->ZB_PEDIDO, 3, 6))
              If !Found()
                 MsgBox("Pedido não encontrado!", "Atenção...", "STOP")
                 Return(.f.)
              Else
                 If !SC5->C5_APROVA $ '1'
                    MsgBox("Pedido não está aprovado!", "Atenção...", "STOP")
                    Return(.f.)
                 Else
                    If Empty(aCols[n][nPosPed])
                       aCols[n][nPosPed] := M->ZB_PEDIDO
                       aCols[n][nPosRaz] := Posicione("SA1", 1, xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, "A1_NOME")
                    Else
                       If aCols[n][nPosPed] <> M->ZB_PEDIDO
                          MsgBox("Para incluir um pedido diferente, faça no final do browse.", "Atenção", "STOP")
							cAux := alltrim(aCols[n][nPosPed])
							cAux := substr(cNumEmp,1,2)+substr(cAux,len(cAux)-5,6)
                          
                          M->ZB_PEDIDO      := cAux //aCols[n][nPosPed]
                          aCols[n][nPosPed] := M->ZB_PEDIDO
                          aCols[n][nPosRaz] := Posicione("SA1", 1, xFilial("SA1")+Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[n][nPosPed], 3, 6), "C5_CLIENTE")+SC5->C5_LOJACLI, "A1_NOME")
                       Endif
                    Endif
                    nTotPes := 0 ; nTotVol := 0
                    For nY := 1 To Len(aCols)
                        If !aCols[nY][Len(aHeader)+1]
                           nTotPes += Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[nY][1], 3, 6), "C5_PBRUTO")
                           nTotVol += Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[nY][1], 3, 6), "C5_VOLUME1")
                        Endif
                    Next
                    oTotPes:Refresh() ; oTotVol:Refresh()
                 Endif
              Endif
           Else
              MsgBox("Empresa inválida!", "Atenção", "STOP")
              Return(.f.)
           Endif
        Endif
     ElseIf nOpc == 2
            For nY := 1 To Len(aCols)
                If aCols[nY][Len(aHeader)+1]
                   Loop
                Endif
                If nY <> n
                   If aCols[nY][1] == aCols[n][1]
                      If !aCols[nY][Len(aHeader)+1] .and. !aCols[nY][Len(aHeader)+1]
                         lJaIncl := .t.
                      Endif
                   Endif
                Else
                   If aCols[nY][Len(aHeader)+1]
                      nY := Len(aCols)
                      Loop
                   Else
                      For nX := 1 To Len(aCols)
                          If nX <> n
                             If !aCols[nX][Len(aHeader)+1]
                                If aCols[nX][1] == aCols[n][1]
                                   lJaIncl := .t.
                                Endif
                             Endif
                          Endif
                      Next
                   Endif
                Endif
            Next
            If Empty(aCols[n][1]) .and. !aCols[n][Len(aHeader)+1]
               MsgBox("Pedido não pode ser vazio!", "Atenção...", "STOP")
               Return(.f.)
            Endif
            If lJaIncl
               MsgBox("Pedido já digitado nesse bordero!", "Atenção...", "STOP")
               Return(.f.)
            Endif
     ElseIf nOpc == 3
            nSomExc := 0
            For nY := 1 To Len(aCols)
               If !aCols[nY][Len(aHeader)+1]
                  If nY <> n
                     If aCols[nY][1] == aCols[n][1]
                        lJaIncl := .t.
                     Endif
                  Endif
               Else
                  nSomExc += 1
               Endif
            Next
            If nSomExc == Len(aCols)
               MsgBox("Utilize a opção 'EXCLUIR', para exclusão de todos os itens.", "Atenção...", "STOP")
               Return(.f.)
            Endif
            If lJaIncl
               MsgBox("Existem pedidos repetidos nesse bordero!", "Atenção...", "STOP")
               Return(.f.)
            Endif
     ElseIf nOpc == 4
            nTotPes := 0 ; nTotVol := 0
            For nY := 1 To Len(aCols)
                If !aCols[nY][Len(aHeader)+1]
                   nTotPes += Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[nY][1], 3, 6), "C5_PBRUTO")
                   nTotVol += Posicione("SC5", 1, xFilial("SC5")+SubStr(aCols[nY][1], 3, 6), "C5_VOLUME1")
                Endif
            Next
            oTotPes:Refresh() ; oTotVol:Refresh()
     ElseIf nOpc == 5
            If __ReadVar == "M->B2_QFIM"
               If M->B2_QFIM > aCols[n][nPosQtd]
                  MsgBox("Atenção, quantidade inválida", "Atenção", "STOP")
                  Return(.f.)
               Endif
            Endif
     Endif
Return(.t.)

Static Function fValCam(nOpc, cPar001, cPar002)
       If nOpc == 1 //Região
          If Empty(cPar001)
             If GETMV("MV_REGTRA") $ 'R'
                MsgBox("Região não pode ser vazia.", "Atenção", "STOP")
             Else
                MsgBox("Transportadora não pode ser vazia.", "Atenção", "STOP")
             Endif
             Return(.f.)
          Else
             If GETMV("MV_REGTRA") $ 'R'
             	/* desabilitado release 12.1.25
                DbSelectArea("SX5")
                DbSetOrder(1)
                DbSeek(xFilial("SX5")+'98'+cPar001, .t.)
                If Found()
                   cPar002 := SX5->X5_DESCRI
                Else
                   MsgBox("Transportadora não encontrada.", "Atenção", "STOP")
                   Return(.f.)
                Endif
                */
                aSX598 := FwGetSX5("98",cPar001)
				If Len(aSX598) > 0
					cPar002 := aSX598[1][4]
                Else
                    MsgBox("Transportadora não encontrada.", "Atenção", "STOP")
                    Return(.f.)
                Endif
             Else
                DbSelectArea("SA4")
                DbSetOrder(1)
                DbSeek(xFilial("SA4")+cPar001, .t.)
                If Found()
                   cPar002 := SA4->A4_NOME
                Else
                   MsgBox("Transportadora não encontrada.", "Atenção", "STOP")
                   Return(.f.)
                Endif
             Endif
          Endif
       Elseif nOpc == 2
          If Empty(cPar001)
             //MsgBox("Veiculo não pode ser vazia.", "Atenção", "STOP")
             Return(.t.)
          Else
             DbSelectArea("DA3")
             DbSetOrder(1)
             DbSeek(xFilial("DA3")+cPar001, .t.)
             If Found()
                cPar002 := DA3->DA3_DESC
             Else
                MsgBox("Veiculo não encontrada.", "Atenção", "STOP")
                Return(.f.)
             Endif
          Endif
       Elseif nOpc == 3
          If Empty(cPar001)
             //MsgBox("Motorista não pode ser vazia.", "Atenção", "STOP")
             Return(.t.)
          Else
             DbSelectArea("DA4")
             DbSetOrder(1)
             DbSeek(xFilial("DA4")+cPar001, .t.)
             If Found()
                cPar002 := DA4->DA4_NOME
             Else
                MsgBox("Motorista não encontrada.", "Atenção", "STOP")
                Return(.f.)
             Endif
          Endif
       Endif
Return(.t.)

/*****************************************************************************************/
/*** FATA01_2 - Mostra a legenda com cores correspondentes.                            ***/
/*****************************************************************************************/
User Function FATA01_2()
     Local cCadastro := OemToAnsi('Bordero de Despacho')
     BrwLegenda(cCadastro, "Status",{ {"ENABLE"     ,"Não despachado"   } ,;
                                      {"BR_AMARELO" ,"Conferência"      } ,;
                                      {"BR_AZUL"    ,"Separado Parcial" } ,;
                                      {"BR_PRETO"   ,"Separado Total"   } ,;
                                      {"DISABLE"    ,"Despachado"       } })
Return(.t.)

/*****************************************************************************************/
/*** FATA01_3 - Bloqueia bordero de despacho para conferencia.                         ***/
/*****************************************************************************************/
User Function FATA01_3()
     If SZA->ZA_FLAG $ ' .N'
        RecLock("SZA", .f.)
           SZA->ZA_FLAG := 'C'
        MsUnLock()
        Return
     ElseIf SZA->ZA_FLAG == 'S'
            MsgBox("Bordero já foi despachado, não pode ser conferido.", "Atenção...", "STOP")
            Return
     ElseIf SZA->ZA_FLAG == 'C'
            RecLock("SZA", .f.)
               SZA->ZA_FLAG := 'N'
            MsUnLock()
            Return
     Endif
Return

User Function FATA01_4()
     Local oDlg, nY, nX
     Local nOpcA     := 0
     Local nOpcE     := 4
     Local cLinOk    := 'AllwaysTrue()'
     Local cTudoOk   := 'AllwaysTrue()'
     Local cFieldOk  := "U_FATA01_5(aCols, aHeader, @aMatPed, oGetRet)"
     //Local nLinhas   := 400
     Local aAltGet   := {"ZZC_RETIRA", "ZZC_GAVETA"}
     Local lPriCar   := .f.
     Local cQry1     := ""
     Local cRETFAL   := GetMv("MV_RETFAL")
     Local cAuxBor   := ""
     Local lContin   := .f.
     Local aVetCon   := {}
     Local _lOpen        := .F. // Adequação para release 12.1.25
     Local _cAliasSX3 := GetNextAlias() // Adequação para release 12.1.25
  
     Private aCols   := {}
     Private aHeader := {}
     Private nUsado  := 0
     Private aMatPed := {}
     Private aMatTCQ := {}
     Private hOK   := LoadBitmap( GetResources(), "LBTIK" )
     Private hNo   := LoadBitmap( GetResources(), "LBNO" )

     
     // ABERTURA DO DICIONÁRIO SX3 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0

     If !_lOpen // Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
        Return
     Endif


     aMatBor := u_fBorJaE("R") //Marca Borderos de Despacho a serem retirados.

     If Len(aMatBor) <= 0.0
        Return
     Endif
     For nY := 1 To Len(aMatBor)
         If aMatBor[nY][1]
            DbSelectArea("SZA")
            DbSetOrder(1)
            DbSeek(xFilial("SZA")+aMatBor[nY][2], .t.)
            If Found()
               If SZA->ZA_FLAG $ ' .N.C'
                  lPriCar := .t.
                  RecLock("SZA", .f.)
                     SZA->ZA_FLAG := "P"
                  MsUnLock()
                  cAuxBor += aMatBor[nY][2]+"', '"
                  aAdd(aVetCon, {aMatBor[nY][2], 0})
               ElseIf SZA->ZA_FLAG $ 'S.T'
                      MsgBox("Bordero "+aMatBor[nY][2]+" já despachado!", "Atenção", "STOP")
                      Return
               Else
                  cAuxBor += aMatBor[nY][2]+"', '"
                  aAdd(aVetCon, {aMatBor[nY][2], 0})
               Endif
            Endif
            lContin := .t.
         Endif
     Next
     If !lContin
        Return
     Endif
     cAuxBor := "('"+SubStr(cAuxBor, 1, Len(cAuxBor)-3)+")"
     //Montagem do aHeader
     
     /* desabilitado release 12.1.25
     DbSelectArea("SX3")
     DbSetOrder(1)
     DbSeek("ZZC")
     While !Eof() .And. (X3_ARQUIVO == "ZZC")
           IF X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. !(TRIM(X3_CAMPO) $ "ZZC_FILIAL") .And. !(TRIM(X3_CAMPO) $ "ZZC_BORDERO") .And. !(TRIM(X3_CAMPO) $ "ZZC_PEDIDO") .And. !(TRIM(X3_CAMPO) $ "ZZC_CARGA") .And. !(TRIM(X3_CAMPO) $ "ZZC_OCUPAC") .And. !(TRIM(X3_CAMPO) $ "ZZC_RESERV")
              nUsado += 1
              AADD(aHeader, { Trim(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
           EndIf
           dbSkip()
     Enddo
     */

     DbSelectArea( _cAliasSX3 )
     ( _cAliasSX3 )->( DbSetOrder(1) )
     ( _cAliasSX3 )->( DbSeek("ZZC") )
     While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "ZZC"
         IF X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .And. !(AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "ZZC_FILIAL") .And. !(AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "ZZC_BORDERO") .And. !(AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "ZZC_PEDIDO") .And. !(AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "ZZC_CARGA") .And. !(AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "ZZC_OCUPAC") .And. !(AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "ZZC_RESERV")
             nUsado += 1
             AADD(aHeader, { Trim(( _cAliasSX3 )->(X3_TITULO)), ( _cAliasSX3 )->(_X3_CAMPO), ( _cAliasSX3 )->(X3_PICTURE), ( _cAliasSX3 )->(X3_TAMANHO), ( _cAliasSX3 )->(X3_DECIMAL), ( _cAliasSX3 )->(X3_VALID), ( _cAliasSX3 )->(X3_USADO), ( _cAliasSX3 )->(X3_TIPO), ( _cAliasSX3 )->(X3_ARQUIVO), ( _cAliasSX3 )->(X3_CONTEXT) } )
         EndIf
         dbSkip()
     EndDo       
     
     If GetMv("MV_RETFAL") $ 'N' //Padrão N (faltante)
        aHeader[aScan(aHeader, {|x| Alltrim(x[2]) == "ZZC_RETIRA"})][1] := "Qtd Faltante"
     Endif

     DbSelectArea( _cAliasSX3 )
     DbCloseArea()


     //Montagem do aCols
     cQry1 := ""
     cQry1 += "SELECT ZZC.ZZC_BORDER, ZZC.ZZC_PEDIDO, ZZC.ZZC_PRODUT AS PRODUTO, SB1.B1_DESC AS DESCRICAO, SB2.B2_LOCALIZ AS LOCALIZ, ZZC.ZZC_QUANTI AS QUANTIDADE, ZZC.ZZC_RETIRA AS RETIRA, ZZC.ZZC_GAVETA AS GAVETA, ZZC.ZZC_VOLUME AS VOLUME, ZZC.ZZC_VOLRET, ZZC.ZZC_SEPARA AS SEPARA "
     cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
     cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 ON ZZC.ZZC_FILIAL = SB1.B1_FILIAL AND ZZC.ZZC_PRODUT = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
     cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 ON SB1.B1_FILIAL = SB2.B2_FILIAL AND SB1.B1_COD = SB2.B2_COD AND SB1.B1_LOCPAD = SB2.B2_LOCAL AND SB2.D_E_L_E_T_ = '' "
     cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
     cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
     cQry1 += "  AND ZZC.ZZC_CARGA IN "+cAuxBor+" "
     cQry1 += "  AND (ZZC.ZZC_SEPARA <> 'S' AND (ZZC.ZZC_QUANTI <> ZZC.ZZC_RETIRA)) "
     cQry1 += "ORDER BY 3, 1 "
     TCQuery cQry1 ALIAS "TCQ" NEW
     DbSelectArea("TCQ")
     While !Eof()
           //If GetMv("MV_RETFAL") $ 'S' //Quantidade Retirada desabilitada release 12.1.25
           If Alltrim(cRETFAL) == 'S' //Quantidade Retirada
              If aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO}) == 0
                 If TCQ->QUANTIDADE > TCQ->RETIRA
                    If TCQ->SEPARA == 'N'
                       nQtdRet := 0
                       nQtdVol := 0
                    ElseIf Empty(TCQ->SEPARA)
                           nQtdRet := 999999
                           nQtdVol := TCQ->VOLUME
                    ElseIf TCQ->SEPARA $ 'S'
                           nQtdRet := TCQ->RETIRA
                           nQtdVol := TCQ->ZZC_VOLRET
                    Endif
                    aadd(aMatTCQ, {TCQ->PRODUTO, TCQ->DESCRICAO, TCQ->LOCALIZ, TCQ->QUANTIDADE, nQtdRet, TCQ->GAVETA, TCQ->VOLUME, nQtdVol, .f. })
                 ElseIf TCQ->QUANTIDADE == TCQ->RETIRA
                        aadd(aMatTCQ, {TCQ->PRODUTO, TCQ->DESCRICAO, TCQ->LOCALIZ, TCQ->QUANTIDADE, TCQ->QUANTIDADE, TCQ->GAVETA, TCQ->VOLUME, TCQ->VOLUME, .f. })
                 Endif
              Else
                 If TCQ->SEPARA == 'N'
                    nQtdRet := 0
                    nQtdVol := 0
                 ElseIf Empty(TCQ->SEPARA)
                        nQtdRet := 999999
                        nQtdVol := TCQ->VOLUME
                 ElseIf TCQ->SEPARA $ 'S'
                        nQtdRet := TCQ->RETIRA
                        nQtdVol := TCQ->ZZC_VOLRET
                        aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][5] += nQtdRet
                        aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][8] += nQtdVol
                 Endif
                 If Empty(aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][6])
                    aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][6] := TCQ->GAVETA
                 Endif
                 aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][4] += TCQ->QUANTIDADE
                 aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][7] += TCQ->VOLUME
              Endif
           Else //Quantidade Faltante
              If aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO}) == 0
                 If TCQ->QUANTIDADE > TCQ->RETIRA
                    If Empty(TCQ->SEPARA)
                       nQtdRet := 0
                       nQtdVol := TCQ->VOLUME
                    Else
                       If TCQ->SEPARA == 'N'
                          nQtdRet := TCQ->QUANTIDADE - TCQ->RETIRA
                          nQtdVol := TCQ->ZZC_VOLRET
                       ElseIf TCQ->SEPARA $ 'S'
                              nQtdRet := 0
                              nQtdVol := TCQ->ZZC_VOLRET
                       Endif
                    Endif
                    aadd(aMatTCQ, {TCQ->PRODUTO, TCQ->DESCRICAO, TCQ->LOCALIZ, TCQ->QUANTIDADE, nQtdRet, TCQ->GAVETA, TCQ->VOLUME, nQtdVol, .f., .f. })
                 ElseIf TCQ->QUANTIDADE == TCQ->RETIRA
                        aadd(aMatTCQ, {TCQ->PRODUTO, TCQ->DESCRICAO, TCQ->LOCALIZ, TCQ->QUANTIDADE, 0, TCQ->GAVETA, TCQ->VOLUME, TCQ->VOLUME, .f., .f. })
                 Endif
                 If lPriCar
                    If Len(Alltrim(TCQ->PRODUTO)) == 12 .and. Empty(TCQ->LOCALIZ)
                       DbSelectArea("ZZC")
                       DbGoTop()
                       DbSetOrder(1)
                       DbSeek(xFilial("ZZC")+TCQ->ZZC_BORDER+TCQ->ZZC_PEDIDO+TCQ->PRODUTO, .t.)
                       If Found()
                          While !Eof() .and. ZZC->ZZC_BORDER == TCQ->ZZC_BORDER .and. ZZC->ZZC_PEDIDO == TCQ->ZZC_PEDIDO .and. ZZC->ZZC_PRODUT == TCQ->PRODUTO
                                RecLock("ZZC", .f.)
                                   ZZC->ZZC_RETIRA :=  0
                                   ZZC->ZZC_VOLRET :=  0
                                   ZZC->ZZC_GAVETA := '999'
                                   ZZC->ZZC_SEPARA := 'N'
                                   ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                                MsUnLock()
                                DbSelectArea("ZZC")
                                DbSkip()
                          Enddo
                       Endif
                       aMatTCQ[Len(aMatTCQ)][10] := .t.
                    Endif
                 Endif
              Else
                 If Empty(TCQ->SEPARA)
                    nQtdRet := 0
                    nQtdVol := TCQ->VOLUME
                 Else
                    If TCQ->SEPARA == 'N'
                       nQtdRet := TCQ->QUANTIDADE - TCQ->RETIRA
                       nQtdVol := TCQ->ZZC_VOLRET
                       aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][5] += nQtdRet
                       aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][8] += nQtdVol
                    ElseIf TCQ->SEPARA == 'S' 
                           nQtdRet := 0
                           nQtdVol := TCQ->ZZC_VOLRET
                    Endif
                 Endif
                 If Empty(aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][6])
                    aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][6] := TCQ->GAVETA
                 Endif
                 aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][4] += TCQ->QUANTIDADE
                 aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][7] += TCQ->VOLUME
                 If lPriCar
                    If Len(Alltrim(TCQ->PRODUTO)) == 12 .and. Empty(TCQ->LOCALIZ)
                       DbSelectArea("ZZC")
                       DbGoTop()
                       DbSetOrder(1)
                       DbSeek(xFilial("ZZC")+TCQ->ZZC_BORDER+TCQ->ZZC_PEDIDO+TCQ->PRODUTO, .t.)
                       If Found()
                          While !Eof() .and. ZZC->ZZC_BORDER == TCQ->ZZC_BORDER .and. ZZC->ZZC_PEDIDO == TCQ->ZZC_PEDIDO .and. ZZC->ZZC_PRODUT == TCQ->PRODUTO
                                RecLock("ZZC", .f.)
                                   ZZC->ZZC_RETIRA :=  0
                                   ZZC->ZZC_VOLRET :=  0
                                   ZZC->ZZC_GAVETA := '999'
                                   ZZC->ZZC_SEPARA := 'N'
                                   ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                                MsUnLock()
                                DbSelectArea("ZZC")
                                DbSkip()
                          Enddo
                       Endif
                       aMatTCQ[aScan(aMatTCQ, {|x| x[1] == TCQ->PRODUTO})][10] := .t.
                    Endif
                 Endif
              Endif
           Endif
           DbSelectArea("TCQ")
           DbSkip()
     Enddo
     DbSelectArea("TCQ")
     DbCloseArea()

     //Ordem matriz com dados do Bordero de Pedidos
     cOrdAtu  := "N"
     cLocaliz := ""
     aMatOrd  := {}
     For nY := 1 To Len(aMatTCQ)
         cLocaliz := SubStr(Alltrim(aMatTCq[nY][3]), 1, 3)
         If Empty(cLocaliz)
            If aScan(aMatOrd, {|x| Alltrim(x[1]) == Alltrim(cLocaliz)}) == 0
               aadd(aMatOrd, {cLocaliz, "N"})
            Endif
         Else
            For nX := 1 To Len(aMatTCQ)
                If cLocaliz == SubStr(Alltrim(aMatTCQ[nY][3]), 1, 3)
                   If aScan(aMatOrd, {|x| Alltrim(x[1]) == Alltrim(cLocaliz)}) == 0
                      aadd(aMatOrd, {SubStr(cLocaliz, 1, 3), cOrdAtu})
                   Endif
                Endif
            Next
            cOrdAtu := Iif(cOrdAtu == "I", "N", "I")
         Endif
     Next
     For nY := 1 To Len(aMatOrd)
         aMatAux := {}
         For nX := 1 To Len(aMatTCQ)
             If SubStr(Alltrim(aMatTCQ[nX][3]), 1, 3) == aMatOrd[nY][1]
                lSepDep := .f.
                /*
                If lPriCar
                   If Len(Alltrim(aMatTCQ[nX][1])) == 4
                      //lSepDep := .t.
                   ElseIf Len(Alltrim(aMatTCQ[nX][1])) == 12
                          If Empty(aMatTCQ[nX][3]) //Produto sem endereços (Produto Específico)
                             lSepDep := .t.
                          Endif
                   Endif
                Endif
                If lSepDep
                   DbSelectArea("ZZC")
                   DbGoTop()
                   DbSetOrder(3)
                   DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aMatTCQ[nX][1], .t.)
                   If Found()
                      While !Eof() .and. ZZC->ZZC_BORDER == SZF->ZF_CODIGO .and. ZZC->ZZC_PRODUT == aMatTCQ[nX][1]
                            RecLock("ZZC", .f.)
                               ZZC->ZZC_RETIRA :=  0
                               ZZC->ZZC_VOLRET :=  0
                               ZZC->ZZC_GAVETA := '999'
                               ZZC->ZZC_SEPARA := 'N'
                               ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                            MsUnLock()
                            DbSelectArea("ZZC")
                            DbSkip()
                      Enddo
                   Endif
                Endif*/
                aadd(aMatAux, { aMatTCQ[nX][1], aMatTCQ[nX][2], aMatTCQ[nX][3], aMatTCQ[nX][4], Iif(aMatTCQ[nX][10], aMatTCQ[nX][4], aMatTCQ[nX][5]), Iif(aMatTCQ[nX][10], '999', aMatTCQ[nX][6]), aMatTCQ[nX][7], aMatTCQ[nX][8], .f. })
             Endif
         Next
         //Ordena Matriz
         If aMatOrd[nY][2] $ 'I'
            aSort(aMatAux, , , {|x, y| x[4] > y[4]})
         Endif
         For nX := 1 To Len(aMatAux)
             aAdd(aCols, {aMatAux[nX][01], aMatAux[nX][02], aMatAux[nX][03], aMatAux[nX][04], Iif(aMatAux[nX][05] == 0, 999999, aMatAux[nX][05]), Iif(aMatAux[nX][05] == 0, '   ', aMatAux[nX][06]), aMatAux[nX][07], aMatAux[nX][08], aMatAux[nX][09] })
         Next
     Next
     cOpc := 'B'
     //Monta tela para Retirada / Baixa Bordero
     DbSelectArea("ZZC")
     DEFINE MSDIALOG oDlg FROM 000,000 TO 032,100 TITLE OemToAnsi("Retirada de itens do estoque") OF oMainWnd
            oGetRet := MsGetDados():New( 020, 004, 240, 393, nOpcE, cLinOk, cTudoOk, "", .f., aAltGet, 2, , Len(aCols), cFieldOk )
            oGetRet:nFreeze := 4
            oGetRet:Refresh()
            @ 001,001 GROUP oGrp1 TO 020,071 LABEL OemToAnsi('')    COLOR CLR_HRED                        PIXEL OF oDlg
            @ 10,008 BTNBMP oBtnCRe RESOURCE "OK"             SIZE 127,24 ACTION(nOpca := 1, oDlg:End()) PIXEL OF oDlg
            @ 001,325 GROUP oGrp2 TO 020,395 LABEL OemToAnsi('')    COLOR CLR_HRED                        PIXEL OF oDlg
            @ 10,657 BTNBMP oBtnSRe RESOURCE "CANCEL"         SIZE 127,24 ACTION(nOpca := 0, oDlg:End()) PIXEL OF oDlg
            @ 001,250 GROUP oGrp3 TO 020,320 LABEL OemToAnsi('')    COLOR CLR_HRED                        PIXEL OF oDlg
            @ 10,507 BTNBMP oBtnPRe RESOURCE "PESQUISA_OCEAN" SIZE 127,24 ACTION(Iif(GETMV("MV_QUALCON") == 1, U_FATA03_3("R"), U_FATA03_A("R")))        PIXEL OF oDlg

            oBtnCRe:cCaption := PADR(OemToAnsi("Confirma Retirada"), 20)
            oBtnCRe:cToolTip := OemToAnsi("Confirma retirada dos itens...")
            oBtnSRe:cCaption := PADR(OemToAnsi("Sair Retirada"), 20)
            oBtnSRe:cToolTip := OemToAnsi("Sai da retirada sem atualizar...")
            oBtnPRe:cCaption := PADR(OemToAnsi("Consulta Produto"), 20)
            oBtnPRe:cToolTip := OemToAnsi("Consulta produtos em outros borderos...")

     ACTIVATE MSDIALOG oDlg CENTERED
     If nOpca == 1
        If MsgYesNo("Deseja realmente dar baixa do estoque ?", 'Atenção', 'ALERT')
           For nY := 1 To Len(aCols)
               If aCols[nY][5] == 999999
                  cQry1 := ""
                  cQry1 += "SELECT ZZC.ZZC_BORDER, ZZC.ZZC_CARGA, ZZC.ZZC_PEDIDO "
                  cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
                  cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
                  cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
                  cQry1 += "  AND ZZC.ZZC_CARGA IN "+cAuxBor+" "
                  cQry1 += "  AND ZZC.ZZC_PRODUT = '"+aCols[nY][1]+"' "
                  TCQuery cQry1 ALIAS "TCQ" NEW
                  DbSelectArea("TCQ")
                  While !Eof()
                        DbSelectArea("ZZC")
                        DbSetOrder(3)
                        DbSeek(xFilial("ZZC")+TCQ->ZZC_BORDER+aCols[nY][1], .t.)
                        If Found()
                           While !Eof() .and. ZZC->ZZC_BORDER == TCQ->ZZC_BORDER .and. ZZC->ZZC_PRODUT == aCols[nY][1]
                                 RecLock("ZZC", .f.)
                                    ZZC->ZZC_RETIRA := ZZC->ZZC_QUANTI
                                    ZZC->ZZC_SEPARA := 'S'
                                    ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                                 MsUnLock()
                                 DbSelectArea("ZZC")
                                 DbSkip()
                           Enddo
                        Endif
                        DbSelectArea("TCQ")
                        DbSkip()
                  Enddo
                  DbSelectArea("TCQ")
                  DbCloseArea()
               Else
                  cQry1 := ""
                  cQry1 += "SELECT ZZC.ZZC_BORDER, ZZC.ZZC_CARGA, ZZC.ZZC_PEDIDO "
                  cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
                  cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
                  cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
                  cQry1 += "  AND ZZC.ZZC_CARGA IN "+cAuxBor+" "
                  cQry1 += "  AND ZZC.ZZC_PRODUT = '"+aCols[nY][1]+"' "
                  TCQuery cQry1 ALIAS "TCQ" NEW
                  DbSelectArea("TCQ")
                  While !Eof()
                        nPos := aScan(aVetCon, {|x| x[1] == TCQ->ZZC_CARGA})
                        If nPos > 0
                           aVetCon[nPos][2] += 1
                        Endif
                        DbSelectArea("TCQ")
                        DbSkip()
                  Enddo
                  DbSelectArea("TCQ")
                  DbCloseArea()
               Endif
           Next
           For nY := 1 To Len(aVetCon)
               If aVetCon[nY][2] <= 0
                  DbSelectArea("SZA")
                  DbSetOrder(1)
                  DbSeek(xFilial("SZA")+aVetCon[nY][1], .t.)
                  If Found()
                     RecLock("SZA", .f.)
                        SZA->ZA_FLAG = 'T'
                     MsUnLock()
                  Endif
               Endif
           Next
        Endif
     Endif
Return

User Function FATA01_5(aCols, aHeader, aMatPed, oGetRet)
     Local nPosPro := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZC_PRODUT" } ) //Código do Produto
     Local nPosQtI := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZC_QUANTI" } ) //Quantidade do Item
     Local nPosQtR := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZC_RETIRA" } ) //Quantidade Retirada
     //Local nPosVlI := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZC_VOLUME" } ) //Volume do Item
     //Local nPosVlR := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZC_VOLRET" } ) //Volume Retirado
     Local nPosGav := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZC_GAVETA" } ) //Gaveta
     //Local nPosicao:= 0
     Private nPosAtu := n
     Private aColAtu := aCols

     If oGetRet == Nil
        oDlg := GetWndDefault()
        oDlg := oGetRet:oWnd
     Endif

     If __ReadVar $ "M->ZZC_RETIRA"
        If M->ZZC_RETIRA == 999999 .or. M->ZZC_RETIRA == 0.0 //Verificar se o valor digitado foi 999999 ou 0.0
           If aCols[n][nPosQtR] == aCols[n][nPosQtI]
              DbSelectArea("ZZC")
              DbSetOrder(3)
              DbSeek(xFilial("ZZC")+SZF->ZF_CODIGO+aCols[n][nPosPro], .t.)
              If Found()
                 While !Eof() .and. ZZC->ZZC_FILIAL == xFilial("ZZC") .and. ZZC->ZZC_BORDER == SZF->ZF_CODIGO .and. ZZC->ZZC_PRODUT == aCols[n][nPosPro]
                       RecLock("ZZC", .f.)
                          ZZC->ZZC_RETIRA := 0
                          ZZC->ZZC_SEPARA := 'N'
                          ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                       MsUnLock()
                       DbSelectArea("ZZC")
                       DbSkip()
                 Enddo
              Endif
              aCols[n][nPosQtR] := 999999
              M->ZZC_RETIRA                                             := 999999
           ElseIf aCols[n][nPosQtR] < aCols[n][nPosQtI] .and. aCols[n][nPosQtR] > 0
                  MsgBox('Já existe quantidade parcial retirada para esse item', 'Atenção...', 'STOP')
                  Return(.f.)
           ElseIf aCols[n][nPosQtR] == 0 .or. aCols[n][nPosQtR] == 999999
                  aCols[n][nPosQtR] := 999999
                  M->ZZC_RETIRA     := 999999
           Endif
        ElseIf M->ZZC_RETIRA < aCols[n][nPosQtI] //Verificar se o valor digitado é menor do que a quantidade do pedido
               cQry1 := ""
               cQry1 += "SELECT COUNT(ZZC.ZZC_PEDIDO) AS QTDPED "
               cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
               cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
               cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
               cQry1 += "  AND ZZC.ZZC_CARGA IN "+cAuxBor+" "
               cQry1 += "  AND ZZC.ZZC_PRODUT = '"+aCols[n][nPosPro]+"' "
               TCQUERY cQry1 ALIAS "TCQ" NEW
               DbSelectArea("TCQ")
               nQtdPed := TCQ->QTDPED
               DbSelectArea("TCQ")
               DbCloseArea()
               If nQtdPed <> 1
                  nPosAtu := n
                  aColAtu := aCols
                  nQtdRet := fMonPed(nPosAtu, aColAtu)
                  aCols[n][nPosQtR] := nQtdRet
               Else
                  cQry1 := ""
                  cQry1 += "SELECT ZZC.ZZC_PEDIDO, ZZC.ZZC_BORDER "
                  cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
                  cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
                  cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
                  cQry1 += "  AND ZZC.ZZC_CARGA IN "+cAuxBor+" "
                  cQry1 += "  AND ZZC.ZZC_PRODUT = '"+aCols[n][nPosPro]+"' "
                  TCQuery cQry1 ALIAS "TCQ" NEW
                  DbSelectArea("TCQ")
                  cPedRet := TCQ->ZZC_PEDIDO
                  cBorRet := TCQ->ZZC_BORDER
                  DbSelectArea("TCQ")
                  DbCloseArea()
                  nQtdRet := M->ZZC_RETIRA
                  DbSelectArea("ZZC")
                  DbSetOrder(1)
                  DbSeek(xFilial("ZZC")+cBorRet+cPedRet+aCols[n][nPosPro], .t.)
                  If Found()
                     RecLock("ZZC", .f.)
                        ZZC->ZZC_RETIRA := (ZZC->ZZC_QUANTI - nQtdRet)
                        ZZC->ZZC_SEPARA := 'N'
                        ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                     MsUnLock()
                  Endif
               Endif
        ElseIf M->ZZC_RETIRA > aCols[n][nPosQtI] //Verificar se a quantidade digitada é maior do que a quantidade do pedido
               MsgBox('Quantidade faltante de retirada não pode ser maior que a quantidade solicitada!', 'Atenção...', 'STOP')
               Return(.f.)
        ElseIf M->ZZC_RETIRA == aCols[n][nPosQtI] //Verificar se a quantidade digitada é igaul do que a quantidade do pedido
               aCols[n][nPosQtR] := M->ZZC_RETIRA
               M->ZZC_RETIRA     := M->ZZC_RETIRA
        Endif
     ElseIf __ReadVar $ "M->ZZC_GAVETA"
            If aCols[n][nPosQtR] <= aCols[n][nPosQtI]
               M->ZZC_GAVETA     := StrZero(Val(Iif(Empty(M->ZZC_GAVETA), aCols[n][nPosGav], M->ZZC_GAVETA)), 3)
               aCols[n][nPosGav] := StrZero(Val(Iif(Empty(M->ZZC_GAVETA), aCols[n][nPosGav], M->ZZC_GAVETA)), 3)
            ElseIf aCols[n][nPosQtR] == 0 .or. aCols[n][nPosQtR] == 999999
               M->ZZC_GAVETA     := space(03)
               aCols[n][nPosGav] := space(03)
            Endif
            cQry1 := ""
            cQry1 += "SELECT ZZC.ZZC_BORDER, ZZC.ZZC_CARGA, ZZC.ZZC_PEDIDO, ZZC.ZZC_PRODUT "
            cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
            cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
            cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
            cQry1 += "  AND ZZC.ZZC_CARGA IN "+cAuxBor+" "
            cQry1 += "  AND ZZC.ZZC_PRODUT = '"+aCols[n][nPosPro]+"' "
            TCQuery cQry1 ALIAS "TCQ" NEW
            DbSelectArea("TCQ")
            DbGoTop()
            While !Eof()
                  DbSelectArea("ZZC")
                  DbGoTop()
                  DbSetOrder(3)
                  DbSeek(xFilial("ZZC")+TCQ->ZZC_BORDER+TCQ->ZZC_PRODUT, .t.)
                  If Found()
                     While !Eof() .AND. ZZC->ZZC_BORDER == TCQ->ZZC_BORDER .AND. ZZC->ZZC_PRODUT == TCQ->ZZC_PRODUT
                           If ZZC->ZZC_QUANTI <> ZZC->ZZC_RETIRA
                              RecLock("ZZC", .f.)
                                 ZZC->ZZC_GAVETA := aCols[n][nPosGav]
                              MsUnLock()
                           Endif
                           DbSelectArea("ZZC")
                           DbSkip()
                     Enddo
                  Endif
                  DbSelectArea("TCQ")
                  DbSkip()
            EndDo
            DbSelectArea("TCQ")
            DbCloseArea()
     Endif
     oGetRet:oBrowse:Refresh()
     DbSelectArea("ZZC")
Return(.t.)

Static Function fMonPed(nPosAtu, aColAtu)
       // Variaveis Locais da Funcao
       Local nY
       // Variaveis Private da Funcao
       Private _oDlgPed    // Dialog Principal
       Private oGetDados1

       DEFINE MSDIALOG _oDlgPed TITLE "Pedidos x Produto" FROM 019,025 TO 256,486 PIXEL
              // Cria Componentes Padroes do Sistema
              DEFINE SBUTTON oBtnBPe FROM 002,002 TYPE 1 ENABLE OF _oDlgPed ACTION(nOpcB := 1, _oDlgPed:End())

              // Chamadas das GetDados do Sistema
              fGetDados1(nPosAtu, aColAtu)
              oGetDados1:oBrowse:SetFocus()
              _oDlgPed:nStyle    := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
       ACTIVATE MSDIALOG _oDlgPed CENTERED
       If nOpcB == 1
          nQtdRet := 0
          For nY := 1 To Len(oGetDados1:aCols)
              If oGetDados1:aCols[nY][3] <> 999999
                 nQtdRet += oGetDados1:aCols[nY][3]
              Endif
              DbSelectArea("ZZC")
              DbSetOrder(2)
              DbSeek(xFilial("ZZC")+oGetDados1:aCols[nY][1]+aCols[nPosAtu][1], .t.)
              If Found()
                 RecLock("ZZC", .f.)
                    ZZC->ZZC_RETIRA := Iif(oGetDados1:aCols[nY][3] <> 999999, (ZZC->ZZC_QUANTI - oGetDados1:aCols[nY][3]), ZZC->ZZC_QUANTI)
                    ZZC->ZZC_SEPARA := Iif(oGetDados1:aCols[nY][3] <> 999999, "N", "S")
                    ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                 MsUnLock()
              Endif
          Next
          If nQtdRet == 0
             nQtdRet := 999999
          Endif
       Endif
Return(nQtdRet)    


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fGetDados1()³ Autor ³ Luís Gustavo de Souza     ³ Data ³27/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da GetDados                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao ³ O Objeto oGetDados1 foi criado como Private no inicio do Fonte   ³±±
±±³           ³ desta forma voce podera trata-lo em qualquer parte do            ³±±
±±³           ³ seu programa:                                                    ³±±
±±³           ³                                                                  ³±±
±±³           ³ Para acessar o aCols desta MsNewGetDados: oGetDados1:aCols[nX,nY]³±±
±±³           ³ Para acessar o aHeader: oGetDados1:aHeader[nX,nY]                ³±±
±±³           ³ Para acessar o "n"    : oGetDados1:nAT                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGetDados1(nPosAtu, aColAtu)
       // Variaveis deste Form
       Local nX           := 0
       Local cQry1  	  := ""
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Cria o Cabecalho da GetDados com todos os Campos do Alias ³
       //³ Caso queira IGNORAR algum Campo basta substituir o Nil    ³
       //³ por uma array com os campos Ex. {"A1_NOME","A1_LC"}		  ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Local aGetAux1     := {"NOUSER"}
       //Local nZ           := aEval(ApBuildHeader("ZZC", Nil), {|x| Aadd(aGetAux1,x[2])})
       // Fim da Criacao do Cabecalho --------------------------------
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Variaveis da MsNewGetDados()      ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       // Vetor responsavel pela montagem da aHeader
       Local aCpoGDa      := aGetAux1
       // Vetor com os campos que poderao ser alterados
       Local aAlter       := {"ZZC_RETIRA"}
       Local nSuperior    := 019          // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
       Local nEsquerda    := 002          // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
       Local nInferior    := 115          // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
       Local nDireita     := 230          // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
       // Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia
       //Local nOpc         := GD_INSERT+GD_DELETE+GD_UPDATE
       Local nOpc         := 2               //Substituido pela Opção 2, altera mas não deleta.
       Local cLinhaOk     := "AllwaysTrue"   // Funcao executada para validar o contexto da linha atual do aCols
       Local cTudoOk      := "AllwaysTrue"   // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
       Local cIniCpos     := ""              // Nome dos campos do tipo caracter que utilizarao incremento automatico.
                                             // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do
                                             // segundo campo>+..."
       Local nFreeze      := 002             // Campos estaticos na GetDados.
       Local nMax         := 999             // Numero maximo de linhas permitidas. Valor padrao 99
       Local cCampoOk     := "U_FATA01_7(1, nPosAtu, aColAtu)" // Funcao executada na validacao do campo
       Local cSuperApagar := ""              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
       Local cApagaOk     := "AllwaysTrue"   // Funcao executada para validar a exclusao de uma linha do aCols
       // Objeto no qual a MsNewGetDados sera criada
       Local oWnd         := _oDlgPed 
       Local aHead        := {}              // Array a ser tratado internamente na MsNewGetDados como aHeader
       Local aCol         := {}              // Array a ser tratado internamente na MsNewGetDados como aCols
       Local _lOpen        := .F. // Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() // Adequação para release 12.1.25
       // ABERTURA DO DICIONÁRIO SX3 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0

       If !_lOpen // Adequação para release 12.1.25
           MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
           Return
       Endif
       /*
       // Carrega aHead                                                                                                                
       DbSelectArea("SX3")
       SX3->(DbSetOrder(2))                  // Campo
       For nX := 1 to Len(aCpoGDa)
           If SX3->(DbSeek(aCpoGDa[nX])) .and. (AllTrim(SX3->X3_CAMPO) == 'ZZC_PEDIDO' .or. AllTrim(SX3->X3_CAMPO) == 'ZZC_QUANTI' .or. AllTrim(SX3->X3_CAMPO) == 'ZZC_RETIRA' .or. AllTrim(SX3->X3_CAMPO) == 'ZZC_VOLUME' .or. AllTrim(SX3->X3_CAMPO) == 'ZZC_VOLRET')
              Aadd(aHead, { AllTrim( SX3->X3_TITULO ),;
                            SX3->X3_CAMPO      ,;
                            SX3->X3_PICTURE    ,;
                            SX3->X3_TAMANHO    ,;
                            SX3->X3_DECIMAL    ,;
                            SX3->X3_VALID      ,;
                            SX3->X3_USADO      ,;
                            SX3->X3_TIPO       ,;
                            SX3->X3_F3         ,;
                            SX3->X3_CONTEXT    ,;
                            SX3->X3_CBOX       ,;
                            SX3->X3_RELACAO    })
           Endif
       Next nX
*/

       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(2) )
       For nX := 1 to Len(aCpoGDa)
           If ( _cAliasSX3 )->( DbSeek(aCpoGDa[nX])) .and. ( AllTrim(( _cAliasSX3 )->( X3_CAMPO )) == 'ZZC_PEDIDO' .or. AllTrim(( _cAliasSX3 )->( X3_CAMPO )) == 'ZZC_QUANTI' .or. AllTrim(( _cAliasSX3 )->( X3_CAMPO )) == 'ZZC_RETIRA' .or. AllTrim(( _cAliasSX3 )->( X3_CAMPO )) == 'ZZC_VOLUME' .or. AllTrim(( _cAliasSX3 )->( X3_CAMPO )) == 'ZZC_VOLRET')
              Aadd(aHead, { AllTrim(( _cAliasSX3 )->(X3_TITULO)),;
                            ( _cAliasSX3 )->(X3_CAMPO)      ,;
                            ( _cAliasSX3 )->(X3_PICTURE)    ,;
                            ( _cAliasSX3 )->(X3_TAMANHO)    ,;
                            ( _cAliasSX3 )->(X3_DECIMAL)    ,;
                            ( _cAliasSX3 )->(X3_VALID)      ,;
                            ( _cAliasSX3 )->(X3_USADO)      ,;
                            ( _cAliasSX3 )->(X3_TIPO)       ,;
                            ( _cAliasSX3 )->(X3_F3)         ,;
                            ( _cAliasSX3 )->(X3_CONTEXT)    ,;
                            ( _cAliasSX3 )->(X3_CBOX)       ,;
                            ( _cAliasSX3 )->(X3_RELACAO)    })
           Endif
       Next nX
        
     
       DbSelectArea( _cAliasSX3 )
       DbCloseArea()      
       
       // Carregue aqui a Montagem da sua aCol
       aCol := {}
       cQry1 := ""
       cQry1 += "SELECT ZZC.ZZC_PEDIDO, SUM(ZZC.ZZC_QUANTI) AS ZZC_QUANTI, SUM(ZZC.ZZC_RETIRA) AS ZZC_RETIRA, SUM(ZZC.ZZC_VOLUME) AS ZZC_VOLUME, SUM(ZZC.ZZC_VOLRET) AS ZZC_VOLRET "
       cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
       cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
       cQry1 += "  AND ZZC.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZC.ZZC_CARGA IN "+cAuxBor+" "
       cQry1 += "  AND ZZC.ZZC_PRODUT = '"+aCols[n][1]+"' "
       cQry1 += "GROUP BY ZZC.ZZC_PEDIDO "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       While !Eof()
             If TCQ->ZZC_RETIRA == 0.0
                nQtdRes := 999999
             ElseIf TCQ->ZZC_RETIRA > 0.0
                  nQtdRes := TCQ->ZZC_QUANTI - TCQ->ZZC_RETIRA
             Endif
             aAdd(aCol, {TCQ->ZZC_PEDIDO, TCQ->ZZC_QUANTI, nQtdRes, TCQ->ZZC_VOLUME, TCQ->ZZC_VOLRET, .f.})
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       
       nMax := Len(aCol)
       oGetDados1 := MsNewGetDados():New(nSuperior, nEsquerda, nInferior, nDireita, nOpc, cLinhaOk, cTudoOk, cIniCpos, aAlter, nFreeze, nMax, cCampoOk, cSuperApagar, cApagaOk, oWnd, aHead, aCol)
       oGetDados1:oBrowse:lAdjustColSize  := .t.
Return

User Function FATA01_7(nGet, nPosAtu, aColAtu)
     If nGet == 1
        If __ReadVar $ 'M->ZZC_RETIRA' //Verificar se o campo digitado foi o M->ZZC_RETIRA
           If M->ZZC_RETIRA == 999999 .or. M->ZZC_RETIRA == 0.0 //Verificar se o valor digitado foi 999999 ou 0.0
              aCols[n][3]   := M->ZZC_RETIRA
              M->ZZC_RETIRA := M->ZZC_RETIRA
              DbSelectArea("ZZC")
              DbSetOrder(2)
              DbSeek(xFilial("ZZC")+aCols[n][1]+aColAtu[nPosAtu][1], .t.)
              If Found()
                 RecLock("ZZC", .f.)
                    ZZC->ZZC_RETIRA := (ZZC->ZZC_QUANTI - M->ZZC_RETIRA)
                    ZZC->ZZC_SEPARA := 'N'
                    ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                 MsUnLock()
              Endif
           ElseIf M->ZZC_RETIRA < aCols[n][2] //Verificar se o valor digitado é menor do que a quantidade do pedido
                  aCols[n][3]   := M->ZZC_RETIRA
                  M->ZZC_RETIRA := M->ZZC_RETIRA
                  DbSelectArea("ZZC")
                  DbSetOrder(2)
                  DbSeek(xFilial("ZZC")+aCols[n][1]+aColAtu[nPosAtu][1], .t.)
                  If Found()
                     RecLock("ZZC", .f.)
                        ZZC->ZZC_RESERV := (ZZC->ZZC_QUANTI - M->ZZC_RETIRA)
                        ZZC->ZZC_SEPARA := 'N'
                        ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                     MsUnLock()
                  Endif
           ElseIf M->ZZC_RETIRA > aCols[n][2] //Verificar se a quantidade digitada é maior do que a quantidade do pedido
                  MsgBox('Quantidade faltante não pode ser maior que a quantidade solicitada!', 'Atenção...', 'STOP')
                  Return(.f.)
           ElseIf M->ZZC_RETIRA == aCols[n][2] //Verificar se a quantidade digitada é igaul do que a quantidade do pedido
                  aCols[n][3]   := M->ZZC_RETIRA
                  M->ZZC_RETIRA := M->ZZC_RETIRA
           Endif
        Endif
     Endif
Return(.t.)  


/******************************************************************************************************************/
/*** FATA01LI - Liberação do endereço do bordero de Pedidos para melhorar o controle dos endereços liberados    ***/
/***            para distribuição de novos pedidos                                                              ***/
/******************************************************************************************************************/
User Function FATA01LI(cCodigo)

 Local cQuery := "" 
	If MsgYesNo('Libera os endereços de todos os pedidos do Bordero de despacho '+cCodigo+' ?', 'Atenção', 'ALERT')

 		cQuery += " SELECT ZB_FILIAL, ZB_CODIGO, ZB_PEDIDO, ZB_RAZAO, ZG_CODIGO, ZG_LOCALIZ "  
		cQuery += " FROM "+RetSqlName("SZB")+" SZB WITH (NOLOCK) "
 		cQuery += " LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON ZB_FILIAL = ZG_FILIAL AND ZB_PEDIDO = ZG_PEDIDO AND SZG.D_E_L_E_T_ ='' "
 		cQuery += " WHERE SZB.D_E_L_E_T_ ='' "
 		cQuery += " AND ZG_LOCALIZ NOT IN('','END. LIB.')"
 		cQuery += " AND ZG_FILIAL = '"+xFilial("SZG")+"' "
		cQuery += " AND ZB_CODIGO = '"+cCodigo+"' "
 		cQuery += " ORDER BY ZG_CODIGO "
  
 		TCQuery cQuery NEW ALIAS "TCQ"         
 
 		While !TCQ->(EOF()) 
			Begin Transaction
				DbSelectArea("SZB")	 // ATUALIZA O BORDER DE DESPACHO COM O ENDEREÇO DO BORDERO DE PEDIDOS  
 				SZB->(DbSetOrder(1))// ZB_FILIAL+ZB_CODIGO+ZB_PEDIDO                                                                                                                                   
				SZB->(DbSeek(xFilial("SZB")+TCQ->ZB_CODIGO+TCQ->ZB_PEDIDO))
			 	If !(SZB->(eof()))
					If Alltrim(TCQ->ZG_LOCALIZ) <> 'END. LIB.' 
						SZB->(RecLock("SZB",.F.))
			   				SZB->ZB_LOCALIZ := TCQ->ZG_LOCALIZ
    					MsUnLock()	
    				Endif
			   	Endif
   	 	
	   	 		DbSelectArea("SZB")
 				DbCloseArea()		

			 	DbSelectArea("SZG") // LIMPA O ENDEREÇO DO BORDERO DE PEDIDOS	   
				SZG->(DbSetOrder(1))// ZG_FILIAL+ZG_CODIGO+ZG_PEDIDO                                                                                                                                                                                                                                                                     
			 	SZG->(DbSeek(xFilial("SZG")+TCQ->ZG_CODIGO+TCQ->ZB_PEDIDO))
			 	If !(SZG->(eof()))
	   				SZG->(RecLock("SZG",.F.))
						SZG->ZG_LOCALIZ := "END. LIB."
	    			MsUnLock()	
	   	 		Endif
	   	 
	   		 	DbSelectArea("SZG")
		 		DbCloseArea()		
			End Transaction	 

		 	DbSelectArea("TCQ")
		 	DbSkip()

	 	Enddo
	 	DbSelectArea("TCQ")
	 	DbCloseArea()
		MsgBox('Endereços Liberados com Sucesso !', 'Atenção...', 'ALERT')
	Endif
   
Return


User Function fImpLocl() // Imprimir Pedidos ordernados por localização
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Declaracao de Variaveis                                             ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
       Local cDesc2        := "de acordo com os parametros informados pelo usuario."
       Local cDesc3        := "Localizações do Bordero de Despacho"
       Local titulo        := "Localizações do Bordero de Despacho"
       Local nLin          := 80
       Local Cabec1        := ""
       Local Cabec2        := "PEDIDO         CLIENTE                                         LOCALIZ "
       //Local imprime       := .T.
       Local aOrd          := {}
       Private lEnd        := .F.
       Private lAbortPrint := .F.
       Private CbTxt       := ""
       Private limite      := 80
       Private tamanho     := "P"
       Private nomeprog    := "BRFATA01" // Coloque aqui o nome do programa para impressao no cabecalho
       Private nTipo       := 18
       Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
       Private nLastKey    := 0
       Private cPerg       := ""
       Private cbcont      := 0
       Private CONTFL      := 1
       Private m_pag       := 01
       Private wnrel       := "BRFATA01" // Coloque aqui o nome do arquivo usado para impressao em disco
       Private cString     := ""
       Private mvpar01

        
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta a interface padrao com o usuario...                           ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       wnrel := SetPrint(cString, NomeProg,      , @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

       If nLastKey == 27
          Return
       Endif

       SetDefault(aReturn,cString)

       If nLastKey == 27
          Return
       Endif

       nTipo := If(aReturn[4]==1,15,18)

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       Processa({|| fRunILo(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ fRunILo  º André Maester              º Data ³  30/06/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fRunILo(Cabec1, Cabec2, Titulo, nLin)
       //Local nOrdem
       Local cQuery := ""
       
       cQuery :=""
 	   cQuery += " SELECT ZA_CODIGO, SUBSTRING(ZA_EMISSAO,7,2)+'/'+SUBSTRING(ZA_EMISSAO,5,2)+'/'+SUBSTRING(ZA_EMISSAO,1,4) AS ZA_EMISSAO, "
	   cQuery += " SUBSTRING(ZA_DTDESPA,7,2)+'/'+SUBSTRING(ZA_DTDESPA,5,2)+'/'+SUBSTRING(ZA_DTDESPA,1,4) AS ZA_DTDESPA, ZA_DESCR, SUBSTRING(ZB_PEDIDO,3,6) AS ZB_PEDIDO, ZB_RAZAO, ZB_LOCALIZ "
	   cQuery += " FROM "+RetSqlName("SZA")+" SZA WITH (NOLOCK) LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH (NOLOCK) ON ZA_FILIAL = ZB_FILIAL AND ZA_CODIGO = ZB_CODIGO AND SZB.D_E_L_E_T_ ='' "
	   cQuery += " WHERE SZA.D_E_L_E_T_ ='' "
	   cQuery += " AND ZA_CODIGO ='"+SZA->ZA_CODIGO+"' "
	   cQuery += " AND ZA_FILIAL ='"+xFilial("SZA")+"' "
	   cQuery += " ORDER BY ZB_LOCALIZ, ZB_PEDIDO "  	      
       TCQuery cQuery ALIAS "TZB" NEW
       
       DbSelectArea("TZB")

       ProcRegua(RecCount())
       DbGoTop()
       If !Eof()
           Cabec1 := "BORDERO -> "+TZB->ZA_CODIGO+" -> "+TZB->ZA_DESCR+" DT. DESPACHO "+TZB->ZA_DTDESPA
       	   While !Eof()
             	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             	//³ Verifica o cancelamento pelo usuario...                             ³
             	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             	If lAbortPrint
                	@ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                	Exit
             	Endif

             	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             	//³ Impressao do cabecalho do relatorio. . .                            ³
             	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
                	nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                	nLin += 1
             	Endif
	
    	         // ORDEM          LOTE    PRODUTO          QTDE.     STATUS                ERRO
            	 // 999999-99-999  999999  XX 99.99.999-99  9,999.99  XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        	     // 1234567890123  123456  123456789012345  12345678  12345678901234567890  123456789012345678901234567890123456789012345678901234567890
	             // 123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
    	         //          1         2         3         4         5         6         7         8         9         100       110       12        13
        	     @ nLin,001 PSAY TZB->ZB_PEDIDO   Picture "@R XXXXXX"
            	 @ nLin,016 PSAY TZB->ZB_RAZAO    
	             @ nLin,064 PSAY TZB->ZB_LOCALIZ

    	         nLin += 1 // Avanca a linha de impressao
        	     DbSelectArea("TZB")
            	 DbSkip() // Avanca o ponteiro do registro no arquivo
	       EndDo
       Endif

       Set Filter To
       DbGoTop()
       
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Finaliza a execucao do relatorio...                                 ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       SET DEVICE TO SCREEN

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Se impressao em disco, chama o gerenciador de impressao...          ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif
       DbSelectArea("TZB")
       DbClosearea() 
	   
       MS_FLUSH()
Return


User Function WFMAILTR()                                                        
   
    //Local cPara    	:= ""
    Local cAssunto  := "PEDIDOS DISPONIVEIS PARA COLETA NO DEPOSITO BRASILUX"
    Local cMsg		:= ""
    Local cQuery    := ""
	Local cAuxMail  := ""
	Local cFlag 	:= 0
	// PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 
     

     /**	Monta a query para buscar os dados	**/   
	cTmp := U_NovoCursor()    
    cQuery := ""
    cQuery += " SELECT ZB_CODIGO, F2_DOC, F2_SERIE, F2_CLIENTE, F2_RAZAO, F2_VOLUME1, F2_PBRUTO, A4_COD, A4_NOME, A4_EMAIL,A1_MUN,F2_EST "   
    cQuery += " FROM "+RetSqlName("SZB")+" SZB WITH(NOLOCK) "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH(NOLOCK) ON F2_FILIAL = ZB_FILIAL AND F2_PEDIDO = SUBSTRING(ZB_PEDIDO,3,6) AND SF2.D_E_L_E_T_ ='' "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH(NOLOCK) ON A4_FILIAL = '"+xFilial("SA4")+"' AND A4_COD = F2_REDESP AND SA4.D_E_L_E_T_ ='' "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH(NOLOCK) ON A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = F2_CLIENT AND SA1.D_E_L_E_T_ =''
	cQuery += " WHERE SZB.D_E_L_E_T_ = '' AND ZB_FILIAL = '"+xFilial("SZB")+"' AND ZB_CODIGO ='"+SZA->ZA_CODIGO+"' AND F2_TRANSP = '00700' AND A4_EMAIL <> ''"
	cQuery += " ORDER BY A4_NOME "

	TcQuery cQuery ALIAS (cTmp) NEW   
	DbSelectArea(cTmp)      
	
    If ((cTmp)->(eof())) 
   	//se o arquivo estiver vazio, sai da rotina
   		 (cTmp)->(DbCloseArea())                                                       	
   		 Return()
   	EndIf	
	
	cAuxMail := ""
	cAuxTransp  := (cTmp)->A4_COD
	While !eof()
		If(cFlag == 0)
			cMsg:="<html>"
			cMsg+="<body>"
			cMsg+="<H3>OS SEGUINTES PEDIDOS ESTÃO DISPONÍVEIS PARA COLETA EM NOSSO DEPÓSITO FECHADO: </H3>"
			cMsg+="<table width='1400' height='92' border='0' font size='1'>"
			cMsg+="<th style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>NOTA</th>"
			cMsg+="<th style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>SERIE</th>"
			cMsg+="<th style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>VOLUME</th>"
			cMsg+="<th style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PESO</th>"
			cMsg+="<th style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CLIENTE</th>"
			cMsg+="<th style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CIDADE</th>"
			cMsg+="<th style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>ESTADO</th>"
			cMsg+="</tr>"  
			cFlag++  
		Endif
		if(cAuxTransp == (cTmp)->A4_COD)
			cMsg+="<tr>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->F2_DOC)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->F2_SERIE)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM((cTmp)->F2_VOLUME1,'@E 99999999')+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM((cTmp)->F2_PBRUTO,'@E 99999999')+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->F2_RAZAO)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->A1_MUN)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->F2_EST)+"</td>"
			cMsg+="</tr>"
			cAuxTransp := (cTmp)->A4_COD
			cAuxMail := (cTmp)->A4_EMAIL
			(cTmp)->(dbSkip())
		else
			cMsg+="</table>"
			cMsg+="<footer>"
			cMsg+="<H3 align='center'>ENDEREÇO DEPÓSITO GUARULHOS RUA ANTONIO RODRIGUES FILHO, 501 - CUMBICA </BR>GUARULHOS - SP, CEP 07170-325 - FONE (11)-2412-4111</H3>"
			cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>WFMAILTR</p>"
			cMsg+="</footer>"
		  	cMsg+="</body>"
		  	cMsg+="</html>" 
			cMsg+="</table>"
		  	cMsg+="</body>"
		  	cMsg+="</html>" 
		  	cAuxTransp := (cTmp)->A4_COD
		  	U_EnvMail(cAssunto, cMsg,cAuxMail)
		  	cMsg:=""
		  	cFlag:=0		 
		endif
	EndDo  
	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<H3 align='center'>ENDEREÇO DEPÓSITO GUARULHOS RUA ANTONIO RODRIGUES FILHO, 501 - CUMBICA </BR>GUARULHOS - SP, CEP 07170-325 - FONE (11)-2412-4111</BR>QUÍMICO CLASSIFICADO ACIMA DE 330 KG (CURSO MOOP - PLACAS - KIT EMERGÊNCIA)</BR>ONU 1263 - RISCO 33</BR>COLETAS DAS 08:00 AS 17:30 POR ORDEM DE CHEGADA.</BR>ACIMA DE 2.000 KG COLETAR ATÉ AS 16:30 HRS.</BR> ENVIAR NÚMERO DA COLETA PARA coletas@brasilux.com.br </H3>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>WFMAILTR</p>"
	cMsg+="</footer>"
	cMsg+="</body>"
	cMsg+="</html>" 
	cMsg+="</table>"
	cMsg+="</body>"
	cMsg+="</html>" 
	U_EnvMail(cAssunto, cMsg,cAuxMail)
		  		
    (cTmp)->(DbCloseArea())      
    
    cAssunto := "Solicitação de coleta do bordero "+SZA->ZA_CODIGO
    cMsg := "Foi enviado um email para as transportados coletarem os pedidos do bordero "+SZA->ZA_CODIGO
    
    U_EnvMail(cAssunto, cMsg,"colpeddep@brasilux.com.br")
    
  //  RESET ENVIRONMENT
  Return() 	  
