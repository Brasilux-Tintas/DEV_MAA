#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BRRSPA01³ Autor ³ Luís Gustavo de Souza ³ Data ³ 18/07/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa curriculos                                        ³±±
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
User Function BRRSPA01()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cGet1PCV   := Space(100)
     Private cGet2PCV   := Space(3)
     Private cGet3PCV   := Space(2)
     Private cGet4PCV   := Space(2)
     Private cGet5PCV   := Space(1)
     Private cSay1PCV   := Space(1)
     Private cSay2PCV   := Space(1)
     Private cSay3PCV   := Space(1)
     Private cSay4PCV   := Space(1)
     Private nCBox1PC
     Private nCBox2PC
     Private aSelecao   := {}
     Private cBtn1PCV   := "Filtra"
     Private nChavPCV   := 1
     Private nOpcao     := 2
     Private INCLUI     := .f.
     Private ALTERA     := .f.
     Private DELETA     := .f.
     Private VISUAL     := .t.
     Private oTempTbl01

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1PC", "oDlg1PCV", "oSay1PCV", "oSay3PCV", "oSay2PCV", "oGet1PCV", "oGet3PCV", "oGet4PCV", "oGet2PCV")
     SetPrvt("oBtn2PCV", "oSay4PCV", "oGet5PCV", "oSay5PCV", "oCBox1PC", "oBrw1PCV", "oSay6PCV")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1PC     := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1PCV   := MSDialog():New( 091, 232, 669, 1172, "Pesquisa Curriculo", , , .F., , , , , , .T., , , .T. )
     oSay1PCV   := TSay():New( 008, 004, {|| "Palavra Chave:"}  , oDlg1PCV, , oFont1PC, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 064, 008)
     oGet1PCV   := TGet():New( 006, 074, {|u| If(PCount() > 0, cGet1PCV := u, cGet1PCV)}, oDlg1PCV, 386, 012, '', , CLR_BLACK, CLR_WHITE, oFont1PC, , , .T., "", , , .F., .F., , .F., .F., ""  , "cGet1PCV", , )
     oSay2PCV   := TSay():New( 024, 004, {|| "Área Pretendida:"}, oDlg1PCV, , oFont1PC, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 075, 008)
     oGet2PCV   := TGet():New( 022, 074, {|u| If(PCount() > 0, cGet2PCV := u, cGet2PCV)}, oDlg1PCV, 023, 012, '@!', , CLR_BLACK, CLR_WHITE, oFont1PC, , , .T., "", , , .F., .F., , .F., .F., "R1", "cGet2PCV", , )
     oSay3PCV   := TSay():New( 043, 004, {|| "Idade:"}          , oDlg1PCV, , oFont1PC, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 008)
     oGet3PCV   := TGet():New( 041, 074, {|u| If(PCount() > 0, cGet3PCV := u, cGet3PCV)}, oDlg1PCV, 023, 012, ''   , , CLR_BLACK, CLR_WHITE, oFont1PC, , , .T., "", , , .F., .F., , .F., .F., ""  , "cGet3PCV", , )     
     oGet4PCV   := TGet():New( 041, 104, {|u| If(PCount() > 0, cGet4PCV := u, cGet4PCV)}, oDlg1PCV, 023, 012, ''   , , CLR_BLACK, CLR_WHITE, oFont1PC, , , .T., "", , , .F., .F., , .F., .F., ""  , "cGet4PCV", , )
     oSay4PCV   := TSay():New( 043, 150, {|| "Est. Civil:"}     , oDlg1PCV, , oFont1PC, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 064, 008)
     oGet5PCV   := TGet():New( 041, 200, {|u| If(PCount() > 0, cGet5PCV := u, cGet5PCV)}, oDlg1PCV, 023, 012, '@!', , CLR_BLACK, CLR_WHITE, oFont1PC, , , .T., "" , , , .F., .F., , .F., .F., "33", "cGet5PCV", , )
     oSay5PCV   := TSay():New( 043, 255, {|| "Sexo: "     }     , oDlg1PCV, , oFont1PC, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 035, 008)
     oCBox2PC   := TComboBox():New( 041, 285, {|u| If(PCount() > 0, nCBox2PC := u, nCBox2PC)}, {"   ", "Masculino", "Feminino"}, 057, 014, oDlg1PCV, , , , CLR_BLACK, CLR_WHITE, .T., oFont1PC, "", , , , , , , nCBox2PC )     
     oSay6PCV   := TSay():New( 043, 360, {|| "Def. Fisico:"}    , oDlg1PCV, , oFont1PC, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 064, 008)
     oCBox1PC   := TComboBox():New( 041, 418, {|u| If(PCount() > 0, nCBox1PC := u, nCBox1PC)}, {"   ", "Sim", "Não"}, 042, 014, oDlg1PCV, , , , CLR_BLACK, CLR_WHITE, .T., oFont1PC, "", , , , , , , nCBox1PC )
     oCBox1PC:nAt := 1
     nCBox1PC   := "   "
     oCBox2PC:nAt := 1
     nCBox2PC   := "   "
     oTbl1PCV(1)
     DbSelectArea("TMPPCV")
     oBrw1PCV   := MsSelect():New( "TMPPCV", "", "", { {"NUMCV", "", "CURRICULO", "999999"}, {"NOMEC", "", "NOME", "@!"}, {"AREAC", "", "AREA"      , "@!"    }, {"IDADC", "", "IDADE"     , "@E 999"}, {"ESTCC", "", "EST. CIVIL", "@!"    }, {"SEXOC", "", "SEXO", "@!"    }, {"TDEFC", "", "DEFICIENCIA", "@!" } }, .F., , {096, 004, 276, 460}, , , oDlg1PCV )
     oBrw1PCV:oBrowse:lVisible := .f.
     oBrw1PCV:oBrowse:bLDBLClick := { || fMostraCV() }
     oBtn1PCV   := TButton():New( 072, 016, cBtn1PCV  , oDlg1PCV, { || MsAguarde( { || fBuscaCand(@nChavPCV) }, 'Aguarde! Pesquisando...') }, 045, 012, , , , .T., , "", , , , .F. )
     oBtn2PCV   := TButton():New( 072, 072, "Sair"    , oDlg1PCV, { || oDlg1PCV:End()         }, 037, 012, , , , .T., , "", , , , .F. )
     
     oDlg1PCV:Activate(,,,.T.)
     oTempTbl01:Delete()
Return

Static Function fBuscaCand(nChavPCV)
       Local cQry1   := ""
       //Local aAuxSel := {}
       Local nY

       If nChavPCV == 1
          nChavPCV := 2
          oGet1PCV:lReadOnly := .t.
          oGet2PCV:lReadOnly := .t.
          oGet3PCV:lReadOnly := .t.
          oGet4PCV:lReadOnly := .t.
          oGet5PCV:lReadOnly := .t.
          oCBox1PC:lReadOnly := .t.
          oCBox2PC:lReadOnly := .t.
          cBtn1PCV := "Novo Filtro"
          oBtn1PCV:cCaption := "Novo Filtro"
          oBtn1PCV:cTitle   := "Novo Filtro"
          oBtn1PCV:Refresh()
          oDlg1PCV:Refresh()
       Else
          nChavPCV := 1
          oGet1PCV:lReadOnly := .f.
          oGet2PCV:lReadOnly := .f.
          oGet3PCV:lReadOnly := .f.
          oGet4PCV:lReadOnly := .f.
          oGet5PCV:lReadOnly := .f.
          oCBox1PC:lReadOnly := .f.
          oCBox2PC:lReadOnly := .f.
          cBtn1PCV := "Filtro"
          oBtn1PCV:cCaption := "Filtro"
          oBtn1PCV:cTitle   := "Filtro"
          oBtn1PCV:Refresh()
          oDlg1PCV:Refresh()
          cGet1PCV   := Space(100)
          cGet2PCV   := Space(3)
          cGet3PCV   := Space(2)
          cGet4PCV   := Space(2)
          cGet5PCV   := Space(1)
          oCBox1PC:nAt := 1
          nCBox1PC   := "   "
          oCBox2PC:nAt := 1
          nCBox2PC   := "   "
          oGet1PCV:Refresh()
          oGet2PCV:Refresh()
          oGet3PCV:Refresh()
          oGet4PCV:Refresh()
          oGet5PCV:Refresh()
          oBrw1PCV:oBrowse:lVisible := .f.
          oGet1PCV:SetFocus()
          Return
       Endif
       //Palavras Chave
       cFil1Aux := Alltrim(cGet1PCV)
       aFilPCha := {}
       If !Empty(cFil1Aux)
          While Len(cFil1Aux) > 0
                nPos := At( ";", cFil1Aux)
                aAdd(aFilPCha, SubStr(UPPER(cFil1Aux), 1, Iif(nPos == 0, Len(cFil1Aux), (nPos - 1))) )
                cFil1Aux := Alltrim(Iif( nPos > 0, SubStr(cFil1Aux, nPos+1), "") )
          EndDo
       Endif

       //Cargo Pretendido
       cFilCPre := ""
       cFilCPre := cGet2PCV

       //Idade
       lIdade := .t.
       If Empty(cGet4PCV)
          If Empty(cGet3PCV)
             lIdade := .f.
          Endif
       Endif
       
       //Estado Civil
       cFilECiv := ""
       If !Empty(cGet5PCV)
          cFilECiv := cGet5PCV
       Endif

       //Sexo
       cFilSexo := ""
       If !Empty(nCBox2PC)
          If nCBox2PC $ 'Masculino'
             cFilSexo := 'M'
          Else
             cFilSexo := 'F'
          Endif
       Endif
       //Deficiente Fisico
       cFilDFis := ""
       If !Empty(nCBox1PC)
          If nCBox1PC $ 'Sim'
             cFilDFis := '1'
          Else
             cFilDFis := '2'
          Endif
       Endif

       //Inicio das Buscas
       If !lIdade .and. Len(aFilPCha) == 0 .and. Empty(cFilCPre) .and. Empty(cFilECiv) .and. Empty(cFilDFis) .and. Empty(cFilSexo)
          MsgStop("Atenção, não existem parâmetros para busca de C.V.")
          Return
       Endif
       cQry1 += "SELECT DAD.QG_CURRIC, DAD.QG_NOME, DAD.QG_AREA, DAD.QG_DTNASC, DAD.QG_ESTCIV, DAD.QG_DFISICO, DAD.QG_SEXO, DAD.QG_TPDEF "
       cQry1 += "FROM SQG010 DAD WITH (NOLOCK) "
       cQry1 += "WHERE DAD.QG_FILIAL  = '' "
       cQry1 += "  AND DAD.D_E_L_E_T_ = '' "
       cQry1 += Iif(!Empty(cFilCPre), "  AND DAD.QG_AREA    = '"+cFilCPre+"' ", "") //Area Pretendida
       cQry1 += Iif(!Empty(cFilECiv), "  AND DAD.QG_ESTCIV  = '"+cFilECiv+"' ", "") //Estado Civil
       cQry1 += Iif(!Empty(cFilDFis), "  AND DAD.QG_DFISICO = '"+cFilDFis+"' ", "") //Deficiente Fisico
       cQry1 += Iif(!Empty(cFilSexo), "  AND DAD.QG_SEXO    = '"+cFilSexo+"' ", "") //Sexo
       cQry1 += "  AND DAD.QG_SITUAC  = '001' "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       aSelecao := {}
       While !Eof()
             //Verificar Idade
             nIdaCan := 0
             If lIdade 
                If !Empty(TCQ->QG_DTNASC)
                   //Montar calculo de idade
                   nIdaCan := Int( ( ( dDataBase - Stod( TCQ->QG_DTNASC ) ) / 365.25 ) )
                   If nIdaCan >= Val(cGet3PCV) .and. nIdaCan <= Val(cGet4PCV)
                      If Len(aFilPCha) > 0 // Verifica Palavras Chaves
                         lEncPCha := .f.
                         For nY := 1 To Len(aFilPCha)
                             cQry1 := ""
                             cQry1 += "SELECT PCH.QL_ATIVIDA, SYP.YP_TEXTO "
                             cQry1 += "FROM SQL010 PCH WITH (NOLOCK) "
                             cQry1 += "LEFT OUTER JOIN SYP010 SYP WITH (NOLOCK) ON SYP.YP_FILIAL = '' AND SYP.YP_CHAVE = PCH.QL_ATIVIDA AND SYP.D_E_L_E_T_ = '' "
                             cQry1 += "WHERE PCH.QL_FILIAL  = '' "
                             cQry1 += "  AND PCH.QL_CURRIC  = '"+TCQ->QG_CURRIC+"' "
                             cQry1 += "  AND PCH.D_E_L_E_T_ = '' "
                             cQry1 += "  AND UPPER(SYP.YP_TEXTO) LIKE('%"+aFilPCha[nY]+"%') "
                             TCQuery cQry1 ALIAS "PCHAVE" NEW
                             DbSelectArea("PCHAVE")
                             While !Eof()
                                   lEncPCha := .t.
                                   DbSelectArea("PCHAVE")
                                   DbSkip()
                             EndDo
                             DbSelectArea("PCHAVE")
                             DbCloseArea()
                         Next
                         If lEncPCha
                            aAdd(aSelecao, { TCQ->QG_CURRIC, TCQ->QG_NOME, TCQ->QG_AREA, nIdaCan, TCQ->QG_ESTCIV, TCQ->QG_DFISICO, TCQ->QG_SEXO, Iif(TCQ->QG_DFISICO <> '1', '', Iif(TCQ->QG_TPDEF == '1', 'AUDITIVA', Iif(TCQ->QG_TPDEF == '2', 'FISICA', Iif(TCQ->QG_TPDEF == '3', 'MENTAL', Iif(TCQ->QG_TPDEF == '4', 'VISUAL',  'MULTIPLA'))))) })
                         Endif
                      Else
                         //Adicionar como selecionado
                         aAdd(aSelecao, { TCQ->QG_CURRIC, TCQ->QG_NOME, TCQ->QG_AREA, nIdaCan, TCQ->QG_ESTCIV, TCQ->QG_DFISICO, TCQ->QG_SEXO, Iif(TCQ->QG_DFISICO <> '1', '', Iif(TCQ->QG_TPDEF == '1', 'AUDITIVA', Iif(TCQ->QG_TPDEF == '2', 'FISICA', Iif(TCQ->QG_TPDEF == '3', 'MENTAL', Iif(TCQ->QG_TPDEF == '4', 'VISUAL',  'MULTIPLA'))))) })
                      Endif
                   Endif
                Endif
             Else
                //Adicionar como selecionado
                nIdaCan := Iif( !Empty(TCQ->QG_DTNASC), Int( ( ( dDataBase - Stod( TCQ->QG_DTNASC ) ) / 365.25 ) ), 0 )
                aAdd(aSelecao, { TCQ->QG_CURRIC, TCQ->QG_NOME, TCQ->QG_AREA, nIdaCan, TCQ->QG_ESTCIV, TCQ->QG_DFISICO, TCQ->QG_SEXO, Iif(TCQ->QG_DFISICO <> '1', '', Iif(TCQ->QG_TPDEF == '1', 'AUDITIVA', Iif(TCQ->QG_TPDEF == '2', 'FISICA', Iif(TCQ->QG_TPDEF == '3', 'MENTAL', Iif(TCQ->QG_TPDEF == '4', 'VISUAL',  'MULTIPLA'))))) })
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       
       //Montando arquivo de Trabalho
       oTbl1PCV(2)
       
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1PCV() - Cria temporario para o Alias: TMPPCV
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1PCV(nOpc)
       Local aFds := {}
       //Local cTmp
       Local nY
       Local _aRetInfR1 := FWGetSX5( 'R1', aSelecao[nY][3] )
       Local _aRetInf33 := FWGetSX5( '33', aSelecao[nY][5] )

       If nOpc == 1
          If !SELECT("TMPPCV") == 0
             DbSelectArea("TMPPCV")
             DbCloseArea()
          Endif
          aAdd( aFds , {"NUMCV"   , "C", 006, 000} )
          aAdd( aFds , {"NOMEC"   , "C", 030, 000} )
          aAdd( aFds , {"AREAC"   , "C", 020, 000} )
          aAdd( aFds , {"IDADC"   , "N", 003, 000} )
          aAdd( aFds , {"ESTCC"   , "C", 013, 000} )
          aAdd( aFds , {"SEXOC"   , "C", 009, 000} )
          aAdd( aFds , {"TDEFC"   , "C", 008, 000} )
       
          /********************************************************************************************************************************/
          /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
          //cTmp := CriaTrab( , .f. )
          //DbCreate(cTmp+".dbf", aFds, "DBFCDXADS")
          //Use (cTmp+".Dbf") Alias TMPPCV VIA "DBFCDXADS" New Exclusive          
          //DbCreateIndex(cTmp+"_1.cdx", "NUMCV", {|| "NUMCV"} )
          //DbClearInd()
          //DbSetIndex(cTmp+"_1")
          oTempTbl01 := FWTemporaryTable():New( TMPPCV )
          oTempTbl01:SetFields( aFds )
          oTempTbl01:AddIndex( "cInd01", { "NUMCV" } )
          oTempTbl01:Create()
          /********************************************************************************************************************************/
          DbSetOrder(1)
       Else
          DbSelectArea("TMPPCV")
          ZAP
          For nY := 1 To Len(aSelecao)
              DbSelectArea("TMPPCV")
              RecLock("TMPPCV", .t.)
                 TMPPCV->NUMCV := aSelecao[nY][1]
                 TMPPCV->NOMEC := aSelecao[nY][2]
                 /********************************************************************************************************************************/
                 /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
                 //DbSelectArea("SX5")
                 //DbSetOrder(1)
                 //DbSeek(xFilial("SX5")+'R1'+aSelecao[nY][3], .t.)
                 //If Found()
                 //   TMPPCV->AREAC := ALLTRIM(SX5->X5_CHAVE)+' - '+SubStr(ALLTRIM(SX5->X5_DESCRI), 1, 11)
                 //Else
                 //   TMPPCV->AREAC := aSelecao[nY][3]
                 //Endif
                 If Len( _aRetInfR1 ) > 0
                    TMPPCV->AREAC := ALLTRIM( _aRetInfR1[ 1][3] ) + ' - ' + SubStr( ALLTRIM( _aRetInfR1[ 1][4] ), 1, 11 )
                 Else
                    TMPPCV->AREAC := aSelecao[nY][3]
                 Endif
                 /********************************************************************************************************************************/
                 TMPPCV->IDADC := aSelecao[nY][4]
                 
                 /********************************************************************************************************************************/
                 /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
                 //DbSelectArea("SX5")
                 //DbSetOrder(1)
                 //DbSeek(xFilial("SX5")+'33'+aSelecao[nY][5], .t.)
                 //If Found()
                 //   TMPPCV->ESTCC := ALLTRIM(SX5->X5_DESCRI)
                 //Else
                 //   TMPPCV->ESTCC := ''
                 //Endif
                 If Len( _aRetInf33 ) > 0
                    TMPPCV->ESTCC := ALLTRIM( _aRetInf33[ 1][ 4] )
                 Else
                    TMPPCV->ESTCC := ''
                 Endif
                 TMPPCV->SEXOC := Iif(aSelecao[nY][7] $ 'M', 'Masculino', Iif(aSelecao[nY][7] $ 'F', 'Feminino', ''))
                 TMPPCV->TDEFC := aSelecao[nY][8]
              MsUnLock()
          Next
          DbSelectArea("TMPPCV")
          DbGoTop()
          oBrw1PCV:oBrowse:lVisible := .t.
       Endif
Return

Static Function fMostraCV()
       // Chama o programa de curriculos RSPA010
       DbSelectArea("SQG")

       If DbSeek(xFilial("SQG")+TMPPCV->NUMCV)
          Rsp010Vis("SQG", RecNo())        // Parametro de visualizacao do curric
       EndIf
       DbSelectArea("TMPPCV")
Return