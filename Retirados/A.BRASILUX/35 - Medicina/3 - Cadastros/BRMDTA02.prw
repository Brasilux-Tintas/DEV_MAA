#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

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
User Function BRMDTA02()
     Private cCadastro := "Anamnese Nutricional"
     Private aRotina   := { {"Pesquisar"  , "AxPesqui"  , 0, 1} ,;
                            {"Visualizar" , "u_MDTA02_1", 0, 2} ,;
                            {"Atendimento", "u_MDTA02_1", 0, 3} ,;
                            {"Exclui"     , "u_MDTA02_1", 0, 4} }
                            //{"Teste"     , "u_NewSource", 0, 5} }
     Private cDelFunc  := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
     Private cString   := "ZZP"
     Private oMenu
     Private aoPpMenu1 := { }
     Private nLeft
     Private nTop

     aAdd(aoPpMenu1, { "Exames"                  , "EXAME120()" } )
     aAdd(aoPpMenu1, { "Avaliação Antropométrica", "fAvalAnt(nOpc)" } )

     DbSelectArea("ZZP")
     DbSetOrder(1)
     mBrowse( 6, 1, 22, 75, cString, , , , , , , , , , , .t.)
Return

User Function MDTA02_1(cAlias, nRecno, nOpc)
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cGetAFFr   := Space(50)
     Private cGetAFQu   := Space(50)
     Private cGetAlAl   := Space(30)
     Private cGetAlco   := Space(20)
     Private cGetApet   := Space(30)
     Private cGetAver   := Space(30)
     Private cGetFich   := Space(9)
     Private cGetInAl   := Space(30)
     Private cGetMeSu   := Space(50)
     Private cGetNome   := Space(40)
     Private cGetPrAl   := Space(50)
     Private cGetQtdM   := Space(20)
     Private cGetQuem   := Space(20)
     Private cGetSalM   := Space(20)
     Private cGetTFTv   := Space(20)
     Private cGetTipO   := Space(20)
     Private cSayAFFr   := Space(1)
     Private cSayAFQu   := Space(1)
     Private cSayDatA   := Space(1)
     Private cSayFich   := Space(1)
     Private dGetDatA   := dDataBase
     Private lCBoxDi1   := .F.
     Private lCBoxDi2   := .F.
     Private lCBoxDi3   := .F.
     Private lCBoxHA1   := .F.
     Private lCBoxHA2   := .F.
     Private lCBoxHA3   := .F.
     Private lCBoxHA4   := .F.
     Private lCBoxHA5   := .F.
     Private lCBoxHF1   := .F.
     Private lCBoxHF2   := .F.
     Private lCBoxHF3   := .F.
     Private lCBoxHF4   := .F.
     Private lCBoxHF5   := .F.
     Private lCBoxOu1   := .F.
     Private lCBoxOu2   := .F.
     Private lCBoxOu3   := .F.
     Private lCBoxOu4   := .F.
     Private lCBoxOu5   := .F.
     Private lCBoxOu6   := .F.
     Private nRMenuAA   := 0
     Private nRMenuAF   := 0
     Private nRMenuAg   := 0
     Private nRMenuAl   := 0
     Private nRMenuAv   := 0
     Private nRMenuCo   := 0
     Private nRMenuCU   := 0
     Private nRMenuDe   := 0
     Private nRMenuDi   := 0
     Private nRMenuFu   := 0
     Private nRMenuHD   := 0
     Private nRMenuHI   := 0
     Private nRMenuIA   := 0
     Private nRMenuLR   := 0
     Private nRMenuMa   := 0
     Private nRMenuOd   := 0
     Private nRMenuPT   := 0
     Private nRMenuQC   := 0
     Private nRMenuRT   := 0
     Private nRMenuUA   := 0
     Private cNumSeq0   := ""
     Private nRMe1Sel
     Private cGet03AAn  := Space(33)
     Private cGet04AAn  := Space(1)
     Private cGet06AAn  := Space(1)
     Private cGet07AAn  := Space(1)
     Private cSay01AAn  := Space(1)
     Private cSay02AAn  := Space(1)
     Private cSay03AAn  := Space(1)
     Private cSay04AAn  := Space(1)
     Private cSay05AAn  := Space(1)
     Private cSay06AAn  := Space(1)
     Private cSay07AAn  := Space(1)
     Private cSay08AAn  := Space(1)
     Private cSay09AAn  := Space(1)
     Private cSay10AAn  := Space(1)
     Private cSay11AAn  := Space(1)
     Private cSay12AAn  := Space(1)
     Private cSay13AAn  := Space(1)
     Private cSay14AAn  := Space(1)
     Private cSay15AAn  := Space(1)
     Private nGet01AAn  := 0
     Private nGet02AAn  := 0
     Private nGet05AAn  := 0
     Private nGet08AAn  := 0
     Private nGet09AAn  := 0
     Private nGet10AAn  := 0
     Private nGet11AAn  := 0
     Private nGet12AAn  := 0
     Private nGet13AAn  := 0
     Private nGet14AAn  := 0
     Private nGet15AAn  := 0
     Private nGet16AAn  := 0
     Private nGet17AAn  := 0
     Private nGet18AAn  := 0
     Private nGet19AAn  := 0
     Private cMGet01An
	 Private cMGet01Ev
     
     If nOpc == 3
        SetPrvt("oFon1Sel", "oDlg1Sel", "oRMe1Sel", "oBtn1Sel", "oBtn2Sel")
        aVetOpc := {"Novo", "Altera"}
        /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
        ±± Definicao do Dialog e todos os seus componentes.                        ±±
        Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
        oFon1Sel   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
        oDlg1Sel   := MSDialog():New( 091, 232, 263, 442, "Selecione a opção", , , .F., , , , , , .T., , oFon1Sel, .T. )
        GoRM1Sel   := TGroup():New( 004, 004, 060, 096, "", oDlg1Sel, CLR_BLACK, CLR_WHITE, .T., .F. )
        oRMe1Sel   := TRadMenu():New( 008, 010, aVetOpc, {|u| If(PCount() > 0, nRMe1Sel := u, nRMe1Sel)}, oDlg1Sel, , , CLR_BLACK, CLR_WHITE, "", , , 072, 18, , .F., .F., .T. )
        oBtn1Sel   := TButton():New( 064, 059, "Sair"     , oDlg1Sel,{ || nOpcS := 0, oDlg1Sel:End()}, 037, 012, , , , .T., , "", , , , .F. )
        oBtn2Sel   := TButton():New( 064, 004, "Confirma" , oDlg1Sel,{ || nOpcS := 1, oDlg1Sel:End()}, 037, 012, , , , .T., , "", , , , .F. )

        oDlg1Sel:Activate(, , , .T.)
        If nOpcS == 1
           If nRMe1Sel == 2
              nOpc := 4
           Endif
        Else
           Return
        Endif
     ElseIf nOpc == 4
            nOpc := 5 //Exclusão
     Endif
     If nOpc == 2 .or. nOpc == 4 .or. nOpc == 5 //Visualização / Alteração / Exclusão
        dGetDatA := ZZP->ZZP_DATA
        cNumSeq0 := ZZP->ZZP_SEQCON
        cGetFich := ZZP->ZZP_FICHA
        cGetNome := Posicione("TM0", 1, xFilial("TM0")+cGetFich, "TM0_NOMFIC")
        lCBoxHF1 := Iif( SubStr(ZZP->ZZP_HISTFA, 1, 1) == 'V', .T., .F.)
        lCBoxHF2 := Iif( SubStr(ZZP->ZZP_HISTFA, 2, 1) == 'V', .T., .F.)
        lCBoxHF3 := Iif( SubStr(ZZP->ZZP_HISTFA, 3, 1) == 'V', .T., .F.)
        lCBoxHF4 := Iif( SubStr(ZZP->ZZP_HISTFA, 4, 1) == 'V', .T., .F.)
        lCBoxHF5 := Iif( SubStr(ZZP->ZZP_HISTFA, 5, 1) == 'V', .T., .F.)
        lCBoxHA1 := Iif( SubStr(ZZP->ZZP_HISTAT, 1, 1) == 'V', .T., .F.)
        lCBoxHA2 := Iif( SubStr(ZZP->ZZP_HISTAT, 2, 1) == 'V', .T., .F.)
        lCBoxHA3 := Iif( SubStr(ZZP->ZZP_HISTAT, 3, 1) == 'V', .T., .F.)
        lCBoxHA4 := Iif( SubStr(ZZP->ZZP_HISTAT, 4, 1) == 'V', .T., .F.)
        lCBoxHA5 := Iif( SubStr(ZZP->ZZP_HISTAT, 5, 1) == 'V', .T., .F.)
        lCBoxOU1 := Iif( SubStr(ZZP->ZZP_OUTR01, 1, 1) == 'V', .T., .F.)
        lCBoxOU2 := Iif( SubStr(ZZP->ZZP_OUTR01, 2, 1) == 'V', .T., .F.)
        lCBoxOU3 := Iif( SubStr(ZZP->ZZP_OUTR01, 3, 1) == 'V', .T., .F.)
        lCBoxOU4 := Iif( SubStr(ZZP->ZZP_OUTR01, 4, 1) == 'V', .T., .F.)
        lCBoxOU5 := Iif( SubStr(ZZP->ZZP_OUTR01, 5, 1) == 'V', .T., .F.)
        lCBoxOU6 := Iif( SubStr(ZZP->ZZP_OUTR01, 6, 1) == 'V', .T., .F.)
        cGetApet := ZZP->ZZP_APETIT
        nRMenuDi := Val(ZZP->ZZP_DIET01)
        lCBoxDI1 := Iif( SubStr(ZZP->ZZP_DIET02, 1, 1) == 'V', .T., .F.)
        lCBoxDI2 := Iif( SubStr(ZZP->ZZP_DIET02, 2, 1) == 'V', .T., .F.)
        lCBoxDI3 := Iif( SubStr(ZZP->ZZP_DIET02, 3, 1) == 'V', .T., .F.)
        nRMenuDe := Val(ZZP->ZZP_DENT01)
        nRMenuPT := Val(ZZP->ZZP_DENT02)
        nRMenuFu := Val(ZZP->ZZP_FUMA)
        nRMenuAl := Val(ZZP->ZZP_ALCO01)
        cGetAlco := ZZP->ZZP_ALCO02
        nRMenuMa := Val(ZZP->ZZP_MASTIG)
        nRMenuHI := Val(ZZP->ZZP_HABI01)
        nRMenuHD := Val(ZZP->ZZP_HABI02)
        nRMenuCo := Val(ZZP->ZZP_CONSIS)
        nRMenuAg := Val(ZZP->ZZP_AGUA)
        nRMenuCU := Val(ZZP->ZZP_URICOR)
        nRMenuOd := Val(ZZP->ZZP_URIODO)
        nRMenuLR := Val(ZZP->ZZP_LOCREF)
        nRMenuQC := Val(ZZP->ZZP_COZINH)
        cGetQuem := ZZP->ZZP_OUTR02
        cGetTipO := ZZP->ZZP_CTIPOL
        cGetQtdM := ZZP->ZZP_QTDEOL
        cGetSalM := ZZP->ZZP_QTDSAL
        nRMenuUA := Val(ZZP->ZZP_ACUCAR)
        nRMenuAF := Val(ZZP->ZZP_ATVFIS)
        cGetAFQu := ZZP->ZZP_QATIVI
        cGetAFFr := ZZP->ZZP_FATIVI
        cGetTFTv := ZZP->ZZP_TMPTV
        nRMenuRT := Val(ZZP->ZZP_REFFTV)
        cGetMeSu := ZZP->ZZP_USAMED
        cGetPrAl := ZZP->ZZP_PREALI
        nRMenuIA := Val(ZZP->ZZP_INTALI)
        cGetInAl := ZZP->ZZP_CINTAL
        nRMenuAA := Val(ZZP->ZZP_ALERGI)
        cGetAlAl := ZZP->ZZP_CALERG
        nRMenuAv := Val(ZZP->ZZP_AVERSA)
        cGetAver := ZZP->ZZP_CAVERSA
        nGet01AAn  := ZZP->ZZP_PESO
        nGet02AAn  := round(ZZP->ZZP_ALTURA,3)
        nGet03AAn  := ""
        nGet04AAn  := ""
        nGet05AAn  := ZZP->ZZP_CQ
        nGet06AAn  := ""
        nGet07AAn  := ""
        nGet08AAn  := ZZP->ZZP_PESGOR
        nGet09AAn  := ZZP->ZZP_PESMMA
        nGet10AAn  := ZZP->ZZP_TMB
        nGet11AAn  := ZZP->ZZP_PERAFU
        nGet12AAn  := ZZP->ZZP_PERPEC
        nGet13AAn  := ZZP->ZZP_PERMMA
        nGet14AAn  := ZZP->ZZP_BIORES
        nGet15AAn  := ZZP->ZZP_REATAN
        nGet16AAn  := ZZP->ZZP_IMC
        nGet17AAn  := ZZP->ZZP_CC
        nGet18AAn  := ZZP->ZZP_CPQ
        nGet19AAn  := ZZP->ZZP_PERGOR
        cMGet01An  := ZZP->ZZP_OBS 
        cMGet01Ev  := ZZP->ZZP_EVOLUC
     Endif 
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFontCab", "oFontBtn", "oDlgAnNu", "oSayDatA", "oSayFich", "oGetDatA", "oGetFich", "oGetNome", "oGrpHisF")
     SetPrvt("oCBoxHF2", "oCBoxHF3", "oCBoxHF4", "oCBoxHF5", "oGrpHisA", "oCBoxHA1", "oCBoxHA2", "oCBoxHA3", "oCBoxHA4")
     SetPrvt("oGrpOut1", "oCBoxOu1", "oCBoxOu2", "oCBoxOu3", "oCBoxOu4", "oCBoxOu5", "oCBoxOu6", "oGrpApet", "oGetApet")
     SetPrvt("oRMenuDi", "oCBoxDi1", "oCBoxDi2", "oCBoxDi3", "oGrpDent", "oRMenuDe", "oRMenuPT", "oGrpFuma", "oRMenuFu")
     SetPrvt("oRMenuAl", "oGetAlco", "oGrpMast", "oRMenuMa", "oGrpHabI", "oRMenuHI", "oRMenuHD", "oGrpCons", "oRMenuCo")
     SetPrvt("oRMenuAg", "oGrpCorU", "oRMenuCU", "oGrpOdor", "oRMenuOd", "oGrpLocR", "oRMenuLR", "oGrpQuem", "oRMenuQC")
     SetPrvt("oGrpTipO", "oGetTipO", "oGrpQtdM", "oGetQtdM", "oGrpSalM", "oGetSalM", "oGrpUAcu", "oRMenuUA", "oGrpAtiF")
     SetPrvt("oSayAFFr", "oRMenuAF", "oGetAFQu", "oGetAFFr", "oGrpTFTv", "oGetTFTv", "oGrpRFTv", "oRMenuRT", "oGrpMeSu")
     SetPrvt("oGrpPrAl", "oGetPrAl", "oGrpInAl", "oRMenuIA", "oGetInAl", "oGrpAlAl", "oRMenuAA", "oGetAlAl", "oGrpAver")
     SetPrvt("oGetAver", "oBtnAvAn", "oBtnExLa", "oBtnEvCl", "oBtnSair", "oBtnConf")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFontCab   := TFont():New( "MS Sans Serif",0,-13,,.F.,0,,400,.F.,.F.,,,,,, )
     oFontBtn   := TFont():New( "MS Sans Serif",0,-11,,.T.,0,,700,.F.,.F.,,,,,, )
     //oDlgAnNu   := MSDialog():New( 096,162,689,1247,"Anamnese Nutricional",,,.F.,,,,,,.T.,,,.T. )  
     oDlgAnNu   := MSDialog():New( 096,158,670,1230,"Anamnese Nutricional",,,.F.,,,,,,.T.,,,.T. )
     //ngPOPUP(aoPpMenu1, @oMenu)
     fPopMenu1(nLeft, nTop, aoPpMenu1, oDlgAnNu)
     //oMenu:nClrPane :=   16777215, oMenu:nClrText := 0, oMenu:oFont := oFontBtn
     /*For nY := 1 To Len(aoPpMenu1)
         oMenu:aItems[nY]:cMsg   := aoPpMenu1[nY][1]
         oMenu:aItems[nY]:cName  := aoPpMenu1[nY][1]
         oMenu:aItems[nY]:cTitle := aoPpMenu1[nY][1]
         oMenu:aItems[nY]:cCaption := aoPpMenu1[nY][1]
     Next*/
     oDlgAnNu:bRClicked  := { |o, x, y| oMenu:Activate(x, y, oDlgAnNu) }
     //Cabeçalho
     oSayDatA   := TSay():New( 004, 004,{ || "Dt. Atendimento:"}, oDlgAnNu, , oFontCab, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 052, 009)
     oSayFich   := TSay():New( 004, 108,{ || "Ficha:"          }, oDlgAnNu, , oFontCab, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 024, 009)
     oGetDatA   := TGet():New( 002, 060,{ |u| If( PCount() > 0, dGetDatA := u, dGetDatA)}, oDlgAnNu, 040, 010, '', , CLR_BLACK, CLR_WHITE, oFontCab, , , .T., "", , , .F., .F., , Iif(nOpc == 2 .or. nOpc == 4 .or. nOpc == 5, .F., .F.), .F., ""   , "dGetDatA", , )
     oGetFich   := TGet():New( 002, 136,{ |u| If( PCount() > 0, cGetFich := u, cGetFich)}, oDlgAnNu, 036, 010, '', , CLR_BLACK, CLR_WHITE, oFontCab, , , .T., "", , , .F., .F., , Iif(nOpc == 2 .or. nOpc == 4 .or. nOpc == 5, .T., .F.), .F., "TM0", "cGetFich", , )
     oGetNome   := TGet():New( 002, 192,{ |u| If( PCount() > 0, cGetNome := u, cGetNome)}, oDlgAnNu, 144, 010, '', , CLR_BLACK, CLR_WHITE, oFontCab, , , .T., "", , , .F., .F., , .T.                                                   , .F., ""   , "cGetNome", , )
     oGetDatA:bLostFocus := Iif(nOpc == 3, { || oGetFich:SetFocus() }, )
     oGetFich:bLostFocus := Iif(nOpc == 3, { || fGetFich()          }, )

     //Historico Familiar
     oGrpHisF   := TGroup():New( 016, 004, 036, 268,"Historico Familiar", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oCBoxHF1   := TCheckBox():New( 022, 008, "Dislipidemias"           , { |u| If( PCount() > 0, lCBoxHF1 := u, lCBoxHF1)}, oGrpHisF, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxHF1:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxHF2   := TCheckBox():New( 022, 060, "Obesidade"               , { |u| If( PCount() > 0, lCBoxHF2 := u, lCBoxHF2)}, oGrpHisF, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxHF2:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxHF3   := TCheckBox():New( 022, 112, "Hipertensão"             , { |u| If( PCount() > 0, lCBoxHF3 := u, lCBoxHF3)}, oGrpHisF, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxHF3:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxHF4   := TCheckBox():New( 022, 164, "Diabetes"                , { |u| If( PCount() > 0, lCBoxHF4 := u, lCBoxHF4)}, oGrpHisF, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxHF4:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxHF5   := TCheckBox():New( 022, 216, "AVC"                     , { |u| If( PCount() > 0, lCBoxHF5 := u, lCBoxHF5)}, oGrpHisF, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxHF5:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)

     //Historico Atual
     oGrpHisA   := TGroup():New( 016, 273, 036, 537, "Historico Atual", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oCBoxHA1   := TCheckBox():New( 022, 277, "Dislipidemias", { |u| If( PCount() > 0, lCBoxHA1 := u, lCBoxHA1)}, oGrpHisA, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxHA1:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxHA2   := TCheckBox():New( 022, 329, "Obesidade"    , { |u| If( PCount() > 0, lCBoxHA2 := u, lCBoxHA2)}, oGrpHisA, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxHA2:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxHA3   := TCheckBox():New( 022, 381, "Hipertensão"  , { |u| If( PCount() > 0, lCBoxHA3 := u, lCBoxHA3)}, oGrpHisA, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxHA3:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxHA4   := TCheckBox():New( 022, 433, "Diabetes"     , { |u| If( PCount() > 0, lCBoxHA4 := u, lCBoxHA4)}, oGrpHisA, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxHA4:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxHA5   := TCheckBox():New( 022, 485, "AVC"          , { |u| If( PCount() > 0, lCBoxHA5 := u, lCBoxHA5)}, oGrpHisA, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxHA5:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)

     //Outros
     oGrpOut1   := TGroup():New( 036, 004, 056, 320, "Outros", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oCBoxOu1   := TCheckBox():New( 042, 008, "Disfagia"   , { |u| If(PCount() > 0, lCBoxOu1 := u, lCBoxOu1)}, oGrpOut1, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxOu1:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxOu2   := TCheckBox():New( 042, 060, "Odinofagia" , { |u| If(PCount() > 0, lCBoxOu2 := u, lCBoxOu2)}, oGrpOut1, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxOu2:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxOu3   := TCheckBox():New( 042, 112, "Nauseas"    , { |u| If(PCount() > 0, lCBoxOu3 := u, lCBoxOu3)}, oGrpOut1, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxOu3:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxOu4   := TCheckBox():New( 042, 164, "Vômitos"    , { |u| If(PCount() > 0, lCBoxOu4 := u, lCBoxOu4)}, oGrpOut1, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxOu4:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxOu5   := TCheckBox():New( 042, 216, "Pirose"     , { |u| If(PCount() > 0, lCBoxOu5 := u, lCBoxOu5)}, oGrpOut1, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxOu5:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxOu6   := TCheckBox():New( 042, 268, "Flatulência", { |u| If(PCount() > 0, lCBoxOu6 := u, lCBoxOu6)}, oGrpOut1, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxOu6:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)

     //Apetite
     oGrpApet   := TGroup():New( 036, 324, 056, 537, "Apetite", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGetApet   := TGet():New( 042, 328, { |u| If( PCount() > 0, cGetApet := u, cGetApet)}, oGrpApet, 204, 008, '@!', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , Iif(nOpc == 2 .or. nOpc == 5, .T., .F.), .F., "", "cGetApet", , )

     //Dieta
     oGrpDiet   := TGroup():New( 056, 004, 100, 104, "Já fez algum tipo de dieta?", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenDi   := TGroup():New( 062, 008, 096, 048, ""                           , oGrpDiet, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuDi   := TRadMenu():New( 066, 014,{"Nao", "Sim"}, { |u| If( PCount() > 0, nRMenuDi := u, nRMenuDi)}, oGrpDiet, , , CLR_BLACK, CLR_WHITE, "", , , 030, 15, , .F., .F., .T. )
     oRMenuDi:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxDi1   := TCheckBox():New( 064, 054, "Conta própria", { |u| If( PCount() > 0, lCBoxDi1 := u, lCBoxDi1)}, oGrpDiet, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxDi1:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxDi2   := TCheckBox():New( 076, 054, "Nutricionista", { |u| If( PCount() > 0, lCBoxDi2 := u, lCBoxDi2)}, oGrpDiet, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxDi2:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oCBoxDi3   := TCheckBox():New( 088, 054, "Medico"       , { |u| If( PCount() > 0, lCBoxDi3 := u, lCBoxDi3)}, oGrpDiet, 048, 008, , , , , CLR_BLACK, CLR_WHITE, , .T., "", , )
     oCBoxDi3:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., Iif(nRMenuDi == 0 .or. nRMenuDi == 1, .T., .F.) )
     oRMenuDi:bChange   := { || fRMenuDi() }

     //Dentição
     oGrpDent   := TGroup():New( 056, 108, 100, 204, "Dentição", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenDe   := TGroup():New( 062, 112, 096, 156, ""        , oGrpDent, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuDe   := TRadMenu():New( 066, 118, { "Completa", "Incompleta", "Protese"}, { |u| If( PCount() > 0, nRMenuDe := u, nRMenuDe)}, oGrpDent, , , CLR_BLACK, CLR_WHITE, "", , , 035, 10, , .F., .F., .T. )
     oRMenuDe:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oGRMenPT   := TGroup():New( 062, 160, 096, 200, "", oGrpDent, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuPT   := TRadMenu():New( 066, 166, { "Parcial", "Total"}, { |u| If( PCount() > 0, nRMenuPT := u, nRMenuPT)}, oGrpDent, , , CLR_BLACK, CLR_WHITE, "", , , 030, 15, , .F., .F., .T. )
     oRMenuPT:lReadOnly := .t.
     oRMenuDe:bChange := { || fRMenuDe() }
     
     //Fuma
     oGrpFuma   := TGroup():New( 056, 208, 100, 256, "Fuma?", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenFu   := TGroup():New( 062, 212, 096, 252, ""     , oGrpFuma, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuFu   := TRadMenu():New( 066, 218, {"Nao", "Sim"}, { |u| If( PCount() > 0, nRMenuFu := u, nRMenuFu)}, oGrpFuma, , , CLR_BLACK, CLR_WHITE, "", , , 030, 15, , .F., .F., .T. )
     oRMenuFu:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)

     //Alcool
     oGrpAlco   := TGroup():New( 056, 260, 100, 380, "Alcool", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenAl   := TGroup():New( 062, 264, 096, 304, ""      , oGrpAlco, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuAl   := TRadMenu():New( 066, 268, {"Nao", "Sim", "As vezes"}, { |u| If( PCount() > 0, nRMenuAl := u, nRMenuAl)}, oGrpAlco, , , CLR_BLACK, CLR_WHITE, "", , , 032, 10, , .F., .F., .T. )
     oRMenuAl:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oGetAlco   := TGet():New( 084, 308, { |u| If( PCount() > 0, cGetAlco := u, cGetAlco)}, oGrpAlco, 064, 008, '@!', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , Iif(nOpc == 2 .or. nOpc == 5, .T., .F.), .F., "", "cGetAlco", , )
     oGetAlco:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., Iif(nRMenuAl == 0 .or. nRMenuAl == 1, .T., .F.) )
     oRMenuAl:bChange := { || fRMenuAl() }

     //Mastigação
     oGrpMast   := TGroup():New( 056, 384, 100, 436, "Mastigação", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenMa   := TGroup():New( 062, 388, 096, 432, ""          , oGrpMast, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuMa   := TRadMenu():New( 066, 394, {"Rapida", "Adequada", "Lenta"}, { |u| If( PCount() > 0, nRMenuMa := u, nRMenuMa)}, oGrpMast, , , CLR_BLACK, CLR_WHITE, "", , , 035, 10, , .F., .F., .T. )
     oRMenuMa:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)

     //Habito Intestinal
     oGrpHabI   := TGroup():New( 056, 440, 100, 536, "Habito Intestinal", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenHI   := TGroup():New( 062, 444, 096, 490, ""                 , oGrpHabI, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuHI   := TRadMenu():New( 066, 450, {"Diario", "Alternado"}, { |u| If( PCount() > 0, nRMenuHI := u, nRMenuHI)}, oGrpHabI, , , CLR_BLACK, CLR_WHITE, "", , , 035, 15, , .F., .F., .T. )
     oRMenuHi:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oGRMenHD   := TGroup():New( 062, 494, 096, 532, ""                 , oGrpHabI, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuHD   := TRadMenu():New( 066, 500, {"2-3 dias", "4-5 dias", "> 5 dias"}, { |u| If( PCount() > 0, nRMenuHD := u, nRMenuHD)}, oGrpHabI, , , CLR_BLACK, CLR_WHITE, "", , , 027, 10, , .F.,  .F., .T. )
     oRMenuHD:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., Iif(nRMenuHI == 0, .T., .F.) )
     oRMenuHI:bChange := { || fRMenuHi() }
     
     //Consistencia
     oGrpCons   := TGroup():New( 100, 004, 160, 060, "Consistência", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenCo   := TGroup():New( 106, 008, 156, 056, ""            , oGrpCons, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuCo   := TRadMenu():New( 110, 014, {"Ressecada", "Pastosa", "Liquida"}, {|u| If( PCount() > 0, nRMenuCo := u, nRMenuCo)}, oGrpCons, , , CLR_BLACK, CLR_WHITE, "", , , 035, 16, , .F., .F., .T. )
     oRMenuCo:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     
     //Agua
     oGrpAgua   := TGroup():New( 100, 064, 160, 128, "Água", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenAg   := TGroup():New( 106, 068, 156, 123, ""    , oGrpAgua, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuAg   := TRadMenu():New( 110, 074, {"< 2 copos/dia", "2-4 copos/dia", "5-6 copos/dia", "7-8 copos/dia", "> 8 copos/dia"}, {|u| If( PCount() > 0, nRMenuAg := u, nRMenuAg)}, oGrpAgua, , , CLR_BLACK, CLR_WHITE, "", , , 045, 10, , .F., .F., .T. )
     oRMenuAg:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)

     //Cor Urina
     oGrpCorU   := TGroup():New( 100, 132, 160, 180, "Cor Urina", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenCU   := TGroup():New( 106, 136, 156, 176, ""         , oGrpCorU, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuCU   := TRadMenu():New( 110, 142, {"Clara", "Escura"}, {|u| If(PCount() > 0, nRMenuCU := u, nRMenuCU)}, oGrpCorU, , , CLR_BLACK, CLR_WHITE, "", , , 025, 25, , .F., .F., .T. )
     oRMenuCU:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)

     //Odor Urina
     oGrpOdor   := TGroup():New( 100, 184, 160, 232, "Odor", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenOd   := TGroup():New( 106, 188, 156, 228, ""    , oGrpOdor, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuOd   := TRadMenu():New( 110, 194, {"Normal", "Forte"}, {|u| If(PCount() > 0, nRMenuOd := u, nRMenuOd)}, oGrpOdor, , , CLR_BLACK, CLR_WHITE, "", , , 030, 25, , .F., .F., .T. )
     oRMenuOd:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)

     //Local das Refeições
     oGrpLocR   := TGroup():New( 100, 236, 160, 300, "Local das Refeições", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenLR   := TGroup():New( 106, 240, 156, 295, ""                   , oGrpLocR, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuLR   := TRadMenu():New( 110, 246, {"Casa", "Trabalho", "Escola", "Lanchonete", "Restaurante"}, {|u| If(PCount() > 0, nRMenuLR := u, nRMenuLR)}, oGrpLocR, , , CLR_BLACK, CLR_WHITE, "", , , 040, 10, , .F., .F., .T. )
     oRMenuLR:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)

     //Quem cozinha
     oGrpQuem   := TGroup():New( 100, 304, 160, 452, "Quem cozinha", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenQC   := TGroup():New( 106, 308, 156, 363, ""            , oGrpQuem, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuQC   := TRadMenu():New( 110, 314, {"Cliente/paciente", "Outro"}, {|u| If(PCount() > 0, nRMenuQC := u, nRMenuQC)}, oGrpQuem, , , CLR_BLACK, CLR_WHITE, "", , , 045, 25, , .F., .F., .T. )
     oRMenuQC:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F.)
     oGetQuem   := TGet():New( 140, 368,{|u| If(PCount() > 0,cGetQuem := u, cGetQuem)}, oGrpQuem, 076, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetQuem",,)
     oGetQuem:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., Iif(nRMenuQC == 0 .or. nRMenuQC == 1, .T., .F.) )
     oRMenuQC:bChange := { || fRMenuQC() }

     //Tipo de Oleo
     oGrpTipO   := TGroup():New( 100, 456, 128, 536, "Tipo de Óleo", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGetTipO   := TGet():New( 111, 460, {|u| If(PCount() > 0, cGetTipO := u, cGetTipO)}, oGrpTipO, 072, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetTipO", , )
     oGetTipO:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

     //Quantidade de Óleo utilizada por mes
     oGrpQtdM   := TGroup():New( 130, 456, 160, 536, "Quantidade / mês", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGetQtdM   := TGet():New( 143, 460, {|u| If(PCount() > 0, cGetQtdM := u, cGetQtdM)}, oGrpQtdM, 072, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetQtdM", , )
     oGetQtdM:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

     //Quantidade de Sal utilizada por mes
     oGrpSalM   := TGroup():New( 160, 004, 204, 096, "Quantidade utilizada de sal / mês:", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGetSalM   := TGet():New( 179, 008,{|u| If(PCount() > 0, cGetSalM := u, cGetSalM)}, oGrpSalM, 084, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetSalM", , )
     oGetSalM:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

     //Utiliza
     oGrpUAcu   := TGroup():New( 160, 100, 204, 156, "Utiliza", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenUA   := TGroup():New( 166, 104, 200, 152, "", oGrpUAcu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuUA   := TRadMenu():New( 170, 110, {"Acucar", "Adocante", "Acucar Light"}, {|u| If(PCount() > 0, nRMenuUA := u, nRMenuUA)}, oGrpUAcu, , , CLR_BLACK, CLR_WHITE, "", , , 048, 11, , .F., .F., .T. )
     oRMenuUA:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )
     
     //Atividade Fisica
     oGrpAtiF   := TGroup():New( 160, 160, 204, 396, "Atividade Física", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenAF   := TGroup():New( 166, 164, 200, 204, "", oGrpAtiF, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuAF   := TRadMenu():New( 170, 170, {"Nao", "Sim"}, {|u| If(PCount() > 0, nRMenuAF := u, nRMenuAF)}, oGrpAtiF, , , CLR_BLACK, CLR_WHITE, "", , , 020, 17, , .F., .F., .T. )
     oRMenuAF:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

     //Qual
     oSayAFQu   := TSay():New( 169, 206, {||"Qual:"}, oGrpAtiF, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008)
     oGetAFQu   := TGet():New( 168, 242, {|u| If(PCount() > 0,cGetAFQu := u, cGetAFQu)}, oGrpAtiF, 152, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetAFQu", , )
     oGetAFQu:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

     //Frequencia
     oSayAFFr   := TSay():New( 189, 206, {||"Frequência:"}, oGrpAtiF, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008)
     oGetAFFr   := TGet():New( 188, 242, {|u| If(PCount() > 0, cGetAFFr := u, cGetAFFr)}, oGrpAtiF, 152, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetAFFr", , )
     oGetAFFr:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

     //Tempo na Frente da TV
     oGrpTFTv   := TGroup():New( 160, 400, 204, 464, "Tempo em Frente a TV", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGetTFTv   := TGet():New( 177,404,{|u| If(PCount() > 0, cGetTFTv := u, cGetTFTv)}, oGrpTFTv, 056, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetTFTv", , )
     oGetTFTv:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

     //Refeições na Frente da TV
     oGrpRFTv   := TGroup():New( 160, 468, 204, 536, "Refeições em Frente a TV", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenRT   := TGroup():New( 166, 472, 200, 532, "", oGrpRFTv, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuRT   := TRadMenu():New( 170, 478, {"Sim", "Nao", "As vezes"}, {|u| If(PCount() > 0, nRMenuRT := u, nRMenuRT)}, oGrpRFTv, , , CLR_BLACK, CLR_WHITE, "", , , 040, 11, , .F., .F., .T. )
     oRMenuRT:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

     //Medicamentos
     oGrpMeSu   := TGroup():New( 204, 004, 228, 268, "Uso de Medicamentos / Suplementos", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGetMeSu   := TGet():New( 213, 008, {|u| If(PCount() > 0, cGetMeSu := u, cGetMeSu)}, oGrpMeSu, 256, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetMeSu", , )
     oGetMeSu:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

     //Preferencia Alimentar
     oGrpPrAl   := TGroup():New( 204, 272, 228, 536, "Preferencia Alimentar", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGetPrAl   := TGet():New( 213, 276, {|u| If(PCount() > 0, cGetPrAl := u, cGetPrAl)}, oGrpPrAl, 256, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetPrAl", , )
     oGetPrAl:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

     //Intolerância Alimentar
     oGrpInAl   := TGroup():New( 228, 004, 272, 180, "Intolerância Alimentar", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenIA   := TGroup():New( 234, 008, 268, 048, "", oGrpInAl, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuIA   := TRadMenu():New( 238, 014, {"Nao", "Sim"}, {|u| If(PCount() > 0, nRMenuIA := u, nRMenuIA)}, oGrpInAl, , , CLR_BLACK, CLR_WHITE, "", , , 020, 17, , .F., .F., .T. )
     oRMenuIA:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )
     oGetInAl   := TGet():New( 256, 052, {|u| If(PCount() > 0, cGetInAl := u, cGetInAl)}, oGrpInAl, 124, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetInAl", , )
     oGetInAl:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

     oGrpAlAl   := TGroup():New( 228, 184, 272, 356, "Alergia / Alimento", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenAA   := TGroup():New( 234, 188, 268, 228, "", oGrpAlAl, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuAA   := TRadMenu():New( 238, 194, {"Nao", "Sim"}, {|u| If(PCount() > 0, nRMenuAA := u, nRMenuAA)}, oGrpAlAl, , , CLR_BLACK, CLR_WHITE, "", , , 020, 17, , .F., .F., .T. )
     oRMenuAA:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )
     oGetAlAl   := TGet():New( 256, 232, {|u| If(PCount() > 0, cGetAlAl := u, cGetAlAl)}, oGrpAlAl, 120, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetAlAl", , )
     oGetAlAl:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )
     
     oGrpAver   := TGroup():New( 228, 360, 272, 536, "Aversões", oDlgAnNu, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGRMenAv   := TGroup():New( 234, 364, 268, 404, "", oGrpAver, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenuAv   := TRadMenu():New( 238, 370, {"Nao", "Sim"}, {|u| If(PCount() > 0, nRMenuAv := u, nRMenuAv)}, oGrpAver, , , CLR_BLACK, CLR_WHITE, "", , , 020, 17, , .F., .F., .T. )
     oRMenuAv:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )
     oGetAver   := TGet():New( 256, 408, {|u| If(PCount() > 0, cGetAver := u, cGetAver)}, oGrpAver, 124, 008, '', , CLR_BLACK,CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetAver", , )
     oGetAver:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

     oBtnAvAn   := TButton():New( 273, 004, "Avaliação Antropométrica", oDlgAnNu, { || fAvalAnt(nOpc) }, 092, 012, , oFontBtn, , .T., , "", , , , .F. )
     oBtnExLa   := TButton():New( 273, 104, "Exames Laboratoriais"    , oDlgAnNu, { || EXAME120()     }, 092, 012, , oFontBtn, , .T., , "", , , , .F. )
     oBtnEvCl   := TButton():New( 273, 204, "Evolução Clínica"        , oDlgAnNu, { || fEvolucao(nOpc)}, 092, 012, , oFontBtn, , .T., , "", , , , .F. )
     oBtnSair   := TButton():New( 273, 496, "Sair"                    , oDlgAnNu, { || oDlgAnNu:End() }, 037, 012, , oFontBtn, , .T., , "", , , , .F. )
     oBtnConf   := TButton():New( 273, 448, "Confirmar"               , oDlgAnNu, { || fConAnam(nOpc) }, 037, 012, , oFontBtn, , .T., , "", , , , .F. )
     oDlgAnNu:Activate(, , , .T.)

Return

Static Function fConAnam(nOpc)
       If nOpc == 3
          RecLock("ZZP", .t.)
             ZZP->ZZP_FILIAL := xFilial("ZZP")                                                                                                                                                  //Filial             C( 2)
             ZZP->ZZP_DATA   := dGetDatA //dDataBase                                                                                                                                                       //Data da Consulta   D( 8)
             ZZP->ZZP_SEQCON := cNumSeq0                                                                                                                                                        //Seq. Consulta      C( 2)
             ZZP->ZZP_FICHA  := cGetFich                                                                                                                                                        //Numero da Ficha    C( 9)
          MsUnLock()
       Endif
       If nOpc == 3 .or. nOpc == 4
          RecLock("ZZP", .f.)
             ZZP->ZZP_DATA   := dGetDatA
             ZZP->ZZP_HISTFA := Iif( lCBoxHF1, 'V', 'F') + Iif( lCBoxHF2, 'V', 'F') + Iif( lCBoxHF3, 'V', 'F') + Iif( lCBoxHF4, 'V', 'F') + Iif( lCBoxHF5, 'V', 'F')                            //Historico Familiar C( 5)
             ZZP->ZZP_HISTAT := Iif( lCBoxHA1, 'V', 'F') + Iif( lCBoxHA2, 'V', 'F') + Iif( lCBoxHA3, 'V', 'F') + Iif( lCBoxHA4, 'V', 'F') + Iif( lCBoxHA5, 'V', 'F')                            //Historico Atual    C( 5)
             ZZP->ZZP_OUTR01 := Iif( lCBoxOU1, 'V', 'F') + Iif( lCBoxOU2, 'V', 'F') + Iif( lCBoxOU3, 'V', 'F') + Iif( lCBoxOU4, 'V', 'F') + Iif( lCBoxOU5, 'V', 'F') + Iif( lCBoxOU6, 'V', 'F') //Outras             C( 6)
             ZZP->ZZP_APETIT := cGetApet                                                                                                                                                        //Apetite            C(30)
             ZZP->ZZP_DIET01 := StrZero(nRMenuDi, 1)                                                                                                                                            //Ja fez Algum tipo  C( 1)
             ZZP->ZZP_DIET02 := Iif( lCBoxDI1, 'V', 'F') + Iif( lCBoxDI2, 'V', 'F') + Iif( lCBoxDI3, 'V', 'F')                                                                                  //     de Dieta      C( 3)
             ZZP->ZZP_DENT01 := StrZero(nRMenuDe, 1)                                                                                                                                            //Dentição           C( 1)
             ZZP->ZZP_DENT02 := StrZero(nRMenuPT, 1)                                                                                                                                            //Dentição           C( 1)
             ZZP->ZZP_FUMA   := StrZero(nRMenuFu, 1)                                                                                                                                            //Fuma               C( 1)
             ZZP->ZZP_ALCO01 := StrZero(nRMenuAl, 1)                                                                                                                                            //Alcool             C( 1)
             ZZP->ZZP_ALCO02 := cGetAlco                                                                                                                                                        //Alcool             C(20)
             ZZP->ZZP_MASTIG := StrZero(nRMenuMa, 1)                                                                                                                                            //Mastigação         C( 1)
             ZZP->ZZP_HABI01 := StrZero(nRMenuHI, 1)                                                                                                                                            //Habito Intestinal  C( 1)
             ZZP->ZZP_HABI02 := StrZero(nRMenuHD, 1)                                                                                                                                            //Habito Intestinal  C( 1)
             ZZP->ZZP_CONSIS := StrZero(nRMenuCo, 1)                                                                                                                                            //Consistencia       C( 1)
             ZZP->ZZP_AGUA   := StrZero(nRMenuAg, 1)                                                                                                                                            //Agua               C( 1)
             ZZP->ZZP_URICOR := StrZero(nRMenuCU, 1)                                                                                                                                            //Cor Urina          C( 1)
             ZZP->ZZP_URIODO := StrZero(nRMenuOd, 1)                                                                                                                                            //Odor Urina         C( 1)
             ZZP->ZZP_LOCREF := StrZero(nRMenuLR, 1)                                                                                                                                            //Local Refeições    C( 1)
             ZZP->ZZP_COZINH := StrZero(nRMenuQC, 1)                                                                                                                                            //Quem Cozinha       C( 1)
             ZZP->ZZP_OUTR02 := cGetQuem                                                                                                                                                        //Quem Cozinha       C(20)
             ZZP->ZZP_CTIPOL := cGetTipO                                                                                                                                                        //Tipo Oleo          C(20)
             ZZP->ZZP_QTDEOL := cGetQtdM                                                                                                                                                        //Quantidade Oleo    C(20)
             ZZP->ZZP_QTDSAL := cGetSalM                                                                                                                                                        //Quantidade de Sal  C(20)
             ZZP->ZZP_ACUCAR := StrZero(nRMenuUA, 1)                                                                                                                                            //Utiliza Acucar     C( 1)
             ZZP->ZZP_ATVFIS := StrZero(nRMenuAF, 1)                                                                                                                                            //Atividade Fisica   C( 1)
             ZZP->ZZP_QATIVI := cGetAFQu                                                                                                                                                        //Qual Ativ. Fisica  C(50)
             ZZP->ZZP_FATIVI := cGetAFFr                                                                                                                                                        //Freq. Ativ. Fisica C(50)
             ZZP->ZZP_TMPTV  := cGetTFTv                                                                                                                                                        //Tempo na TV        C(20)
             ZZP->ZZP_REFFTV := StrZero(nRMenuRT, 1)                                                                                                                                            //Refeições na TV    C( 1)
             ZZP->ZZP_USAMED := cGetMeSu                                                                                                                                                        //Usa medicamento    C(50)
             ZZP->ZZP_PREALI := cGetPrAl                                                                                                                                                        //Preferencia Alim.  C(50)
             ZZP->ZZP_INTALI := StrZero(nRMenuIA, 1)                                                                                                                                            //Intol. Alimentar   C( 1)
             ZZP->ZZP_CINTAL := cGetInAl                                                                                                                                                        //Intol. Alimentar   C(20)
             ZZP->ZZP_ALERGI := StrZero(nRMenuAA, 1)                                                                                                                                            //Alergia            C( 1)
             ZZP->ZZP_CALERG := cGetAlAl                                                                                                                                                        //Alergia            C(20)
             ZZP->ZZP_AVERSA := StrZero(nRMenuAv, 1)                                                                                                                                            //Aversões           C( 1)
             ZZP->ZZP_CAVERS := cGetAver                                                                                                                                                        //Aversões           C(20)
             ZZP->ZZP_PESO   := nGet01AAn                                                                                                                                                       //
             ZZP->ZZP_ALTURA := round(nGet02AAn,3)                                                                                                                                                       //
             ZZP->ZZP_IMC    := nGet16AAn                                                                                                                                                       //
             ZZP->ZZP_CC     := nGet17AAn                                                                                                                                                       //
             ZZP->ZZP_CQ     := nGet05AAn                                                                                                                                                       //
             ZZP->ZZP_CPQ    := nGet18AAn                                                                                                                                                       //
             ZZP->ZZP_PERGOR := nGet19AAn                                                                                                                                                       //
             ZZP->ZZP_PESGOR := nGet08AAn                                                                                                                                                       //
             ZZP->ZZP_PESMMA := nGet09AAn                                                                                                                                                       //
             ZZP->ZZP_TMB    := nGet10AAn                                                                                                                                                       //
             ZZP->ZZP_PERAFU := nGet11AAn                                                                                                                                                       //
             ZZP->ZZP_PERPEC := nGet12AAn                                                                                                                                                       //
             ZZP->ZZP_PERMMA := nGet13AAn                                                                                                                                                       //
             ZZP->ZZP_BIORES := nGet14AAn                                                                                                                                                       //
             ZZP->ZZP_REATAN := nGet15AAn                                                                                                                                                       //
             ZZP->ZZP_OBS    := cMGet01An 
             ZZP->ZZP_EVOLUC := cMGet01Ev
                                                                                                                                                                   //
          MsUnLock()
       Endif
       If nOpc == 5 // Exclusão
          If MsgYesNo("Confirma exclusão dessa ficha?")
             RecLock("ZZP", .f.)
                DbDelete()
             MsUnLock()
          Endif
       Endif
       oDlgAnNu:End()
Return

Static Function fGetFich()
       DbSelectArea("TM0")
       DbSetOrder(1)
       DbSeek(xFilial("TM0")+cGetFich, .t.)
       If Found()
          cGetFich := TM0->TM0_NUMFIC
          cGetNome := TM0->TM0_NOMFIC
          //Verificação da Data
          DbSelectArea("ZZP")
          DbSetOrder(1)
          DbSeek(xFilial("ZZP")+Dtos(dDataBase), .t.)
          If Found()
             While !Eof() .and. ZZP->ZZP_FICHA == cGetFich .and. ZZP->ZZP_DATA == dDataBase
                   cNumSeq0 := ZZP->ZZP_SEQCON
                   DbSkip()
             EndDo
             cNumSeq0 := StrZero(Val(cNumSeq0) + 1, 2)
          Else
             cNumSeq0 := '01'
          Endif
       Else
          MsgStop("Código inválido!")
          cGetFich := Space(9)
          cGetNome := Space(40)
          oGetFich:SetFocus()
       Endif
       oGetFich:Refresh()
       oGetNome:Refresh()
Return(.t.)

Static Function fRMenuDi()
       If nRMenuDi == 1
          oCBoxDi1:lReadOnly := .t.
          lCBoxDi1           := .f.
          oCBoxDi2:lReadOnly := .t.
          lCBoxDi2           := .f.
          oCBoxDi3:lReadOnly := .t.
          lCBoxDi3           := .f.
       Else
          oCBoxDi1:lReadOnly := .f.
          lCBoxDi1           := .f.
          oCBoxDi2:lReadOnly := .f.
          lCBoxDi2           := .f.
          oCBoxDi3:lReadOnly := .f.
          lCBoxDi3           := .f.
       Endif
       oCBoxDi1:Refresh()
       oCBoxDi2:Refresh()
       oCBoxDi3:Refresh()
Return

Static Function fRMenuDe()
       If nRMenuDe == 1 .or. nRMenuDe == 2
          nRMenuPT           := 0
          oRMenuPT:lReadOnly := .t.
          oRMenuPT:nOption   := 0
       Else
          nRMenuPT           := 0
          oRMenuPT:lReadOnly := .f.
          oRMenuPT:nOption   := 0
       Endif
       oRMenuPT:Refresh()
Return

Static Function fRMenuAl()
       If nRMenuAl == 1 .or. nRMenuAl == 2
          oGetAlco:lReadOnly := .t.
          cGetAlco           := Space(20)
       Else
          oGetAlco:lReadOnly := .f.
          cGetAlco           := Space(20)
          oGetAlco:SetFocus()
       Endif
       oGetAlco:Refresh()
       oRMenuAl:Refresh()
Return(.t.)

Static Function fRMenuHi()
       If nRMenuHi == 1
          nRMenuHD           := 0
          oRMenuHD:lReadOnly := .t.
          oRMenuHD:nOption   := 0
       Else
          nRMenuHD           := 0
          oRMenuHD:lReadOnly := .f.
          oRMenuHD:nOption   := 0
       Endif
       oRMenuHD:Refresh()
Return

Static Function fRMenuQC()
       If nRMenuQC == 1 .or. nRMenuQC == 0
          oGetQuem:lReadOnly := .t.
          cGetQuem           := Space(20)
       Else
          oGetQuem:lReadOnly := .f.
          cGetQuem           := Space(20)
          oGetQuem:SetFocus()
       Endif
       oGetQuem:Refresh()
       oRMenuQC:Refresh()
Return(.t.)

//------------------------------------------------ 
Static Function fPopMenu1(nLeft, nTop, aoPpMenu1, oDlgA)
//------------------------------------------------
//Local oMenu
Local oMenuItem  := {}
MENU oMenu POPUP OF oDlgA
  AAdd( oMenuItem, MenuAddItem("Teste 1", "XX", .t.,.T., , , "PROJETOAP",oMenu,{|| EXAME120() }) )
  AAdd( oMenuItem, MenuAddItem("Teste 2", "YY", .t.,.T., , , "PROJETOAP",oMenu,{|| EXAME120() }) )
ENDMENU
oMenu:aItems[1]:nClrPane :=    65535
oMenu:aItems[1]:nClrText := 16711680
oMenu:aItems[2]:nClrPane :=    65535
oMenu:aItems[2]:nClrText := 16711680
oMenu:nClrPane           :=        0
oMenu:nClrText           := 16777215
oMenu:oFont              := oFontBtn
//ACTIVATE POPUP oMenu AT nLeft, nTop
Return


User Function NewSource

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de Variaveis Private dos Objetos                             ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
SetPrvt("oDlg1")

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
oDlg1      := MSDialog():New( 091, 232, 523, 737, "Titulo", , , .F., , 16777215, 0, ,,.T.,,,.T. )
oFontBtn   := TFont():New( "MS Sans Serif",0,-11,,.T.,0,,700,.F.,.F.,,,,,, )
fPopMenu1(nLeft, nTop, aoPpMenu1, oDlg1)
oDlg1:bRClicked  := { |o, x, y| oMenu:Activate(x, y, oDlg1) }
oDlg1:nClrPane           :=        0
oDlg1:Activate(,,,.T.)
Return

Static Function fEvolucao(nOpc)
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oDlg01EvC", "oSay16EvC", "oBtn01Evc", "oSay03AAn", "oMGet01Ev", "cMGet01Ev")

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oDlg01Evc  := MSDialog():New( 091, 252, 385, 667, "Evolução Clínica do Funcionário", , , .F., , , , , , .T., , , .T. )

       oSay16EvC  := TSay():New( 08, 004, {|| "Observações :"}  , oDlg01Evc, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oMGet01Ev  := TMultiGet():New( 18, 004,{|u| If(PCount() > 0, cMGet01Ev := u, cMGet01Ev)}, oDlg01Evc, 200, 110, , , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .F., , , .F., ,  )
       oMGet01Ev:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )
       
       oBtn01Evc  := TButton():New( 130, 163, "Sair", oDlg01EvC, { || oDlg01Evc:End() }, 037, 012, , , , .T., , "", , , , .F. )

       oDlg01Evc:Activate(, , , .T.)
Return

Static Function fAvalAnt(nOpc)
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oDlg01AAn", "oSay01AAn", "oSay02AAn", "oSay03AAn", "oSay04AAn", "oSay05AAn", "oSay06AAn", "oSay07AAn")
       SetPrvt("oSay09AAn", "oSay10AAn", "oSay11AAn", "oSay12AAn", "oSay13AAn", "oSay14AAn", "oSay15AAn", "oGet01AAn")
       SetPrvt("oGet03AAn", "oGet04AAn", "oGet05AAn", "cGet06AAn", "oGet07AAn", "oGet08AAn", "oGet09AAn", "oGet10AAn")
       SetPrvt("oGet12AAn", "oGet13AAn", "oGet14AAn", "oGet15AAn", "oGet16AAn", "oGet17AAn", "oGet18AAn", "oGet19AAn")
       SetPrvt("oMGet01An")

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oDlg01AAn  := MSDialog():New( 091, 232, 685, 600, "Avaliação Antropométrica", , , .F., , , , , , .T., , , .T. )
       oSay01AAn  := TSay():New( 008, 004, {|| "Peso (Kg):"}         , oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oGet01AAn  := TGet():New( 008, 060, {|u| If(PCount() > 0, nGet01AAn := u, nGet01AAn)}, oDlg01AAn, 024, 008, '@E 999.999', { || nGet01AAn >= 0 }, CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "nGet01AAn", , )
       oGet01AAn:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

       oSay02AAn  := TSay():New( 024, 004, {|| "Altura (Metros) :"}            , oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oGet02AAn  := TGet():New( 024, 060, {|u| If(PCount() > 0, nGet02AAn := u, nGet02AAn)}, oDlg01AAn, 024, 008, '@E 999.999'   , { || nGet02AAn >= 0 }, CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "nGet02AAn", , )
       oGet02AAn:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., 	.F. )
       oGet02AAn:bChange   := { || Iif(nOpc == 2 .or. nOpc == 5, , fCalcIMC()) }

       oSay03AAn  := TSay():New( 040, 004, {|| "IMC:"}               , oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oGet16AAn  := TGet():New( 040, 060, {|u| If(PCount() > 0, nGet16AAn := u, nGet16AAn)}, oDlg01AAn, 024, 008, '@E 99.99'  ,                      , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "nGet16AAn", , )
       oGet03AAn  := TGet():New( 040, 095, {|u| If(PCount() > 0, cGet03AAn := u, cGet03AAn)}, oDlg01AAn, 088, 008, ''          ,                      , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cGet03AAn", , )

       oSay04AAn  := TSay():New( 056, 004, {|| "CC (cm):"}                , oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oGet17AAn  := TGet():New( 056, 060, {|u| If(PCount() > 0, nGet17AAn := u, nGet17AAn)}, oDlg01AAn, 024, 008, '@E 999.99' , { || nGet17AAn >= 0 }, CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "nGet17AAn", , )
       oGet04AAn  := TGet():New( 056, 095, {|u| If(PCount() > 0, cGet04AAn := u, cGet04AAn)}, oDlg01AAn, 024, 008, ''          ,                      , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cGet04AAn", , )
       oGet17AAn:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )
       oGet17AAn:bLostFocus := { || Iif(nOpc == 2 .or. nOpc == 5, , fCaluCC()) }

       oSay05AAn  := TSay():New( 072, 004, {|| "CQ (cm):"}                , oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oGet05AAn  := TGet():New( 072, 060, {|u| If(PCount() > 0, nGet05AAn := u, nGet05AAn)}, oDlg01AAn, 024, 008, '@E 999.99' , { || nGet05AAn >= 0 }, CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "nGet05AAn", , )
       oGet05AAn:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )
       oGet05AAn:bChange   := { || Iif(nOpc == 2 .or. nOpc == 5, , fCalCPQ()) }

       oSay06AAn  := TSay():New( 088, 004, {|| "C/Q:"}               , oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oGet18AAn  := TGet():New( 088, 060, {|u| If(PCount() > 0, nGet18AAn := u, nGet18AAn)}, oDlg01AAn, 024, 008, '@E  9.99'  , { || nGet18AAn >= 0 }, CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "nGet18AAn", , )
       oGet06AAn  := TGet():New( 088, 095, {|u| If(PCount() > 0, cGet06AAn := u, cGet06AAn)}, oDlg01AAn, 024, 008, ''          ,                      , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cGet06AAn", , )

       oSay07AAn  := TSay():New( 104, 004, {|| "% de gordura:"}      , oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oGet19AAn  := TGet():New( 104, 060, {|u| If( PCount() > 0, nGet19AAn := u, nGet19AAn)}, oDlg01AAn, 024, 008, '@E 999.99',                      , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "nGet19AAn", , )
       oGet07AAn  := TGet():New( 104, 095, {|u| If( PCount() > 0, cGet07AAn := u, cGet07AAn)}, oDlg01AAn, 024, 008, ''         ,                      , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .T., .F., "", "cGet07AAn", , )
       oGet19AAn:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )
       oGet19AAn:bLostFocus := { || Iif(nOpc == 2 .or. nOpc == 5, , fCalcPGR()) }

       oSay08AAn  := TSay():New( 120, 004, {|| "Peso da gordura:"}   , oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oGet08AAn  := TGet():New( 120, 060, {|u| If( PCount() > 0, nGet08AAn := u, nGet08AAn)}, oDlg01AAn, 024, 008, '@E 999.99', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "nGet08AAn", , )
       oGet08AAn:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

       oSay09AAn  := TSay():New( 136, 004, {|| "Peso massa magra:"}  , oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oGet09AAn  := TGet():New( 136, 060, {|u| If( PCount() > 0, nGet09AAn := u, nGet09AAn)}, oDlg01AAn, 024, 008, '@E 999.99', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "nGet09AAn", , )
       oGet09AAn:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

       oSay10AAn  := TSay():New( 152, 004, {|| "TMB:"}               , oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oGet10AAn  := TGet():New( 152, 060, {|u| If( PCount() > 0, nGet10AAn := u, nGet10AAn)}, oDlg01AAn, 024, 008, '@E 999.99', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "nGet10AAn", , )
       oGet10AAn:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

       oSay11AAn  := TSay():New( 168, 004, {|| "% de agua do corpo:"}, oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oGet11AAn  := TGet():New( 168, 060, {|u| If( PCount() > 0, nGet11AAn := u, nGet11AAn)}, oDlg01AAn, 024, 008, '@E 999.99', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "nGet11AAn", , )
       oGet11AAn:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

       oSay12AAn  := TSay():New( 184, 004, {|| "% do peso corporeo:"}, oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oGet12AAn  := TGet():New( 184, 060, {|u| If( PCount() > 0, nGet12AAn := u, nGet12AAn)}, oDlg01AAn, 024, 008, '@E 999.99', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "nGet12AAn", , )
       oGet12AAn:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

       oSay13AAn  := TSay():New( 200, 004, {|| "% massa magra"}      , oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oGet13AAn  := TGet():New( 200, 060, {|u| If( PCount() > 0, nGet13AAn := u, nGet13AAn)}, oDlg01AAn, 024, 008, '@E 999.99', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "nGet13AAn", , )
       oGet13AAn:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

       oSay14AAn  := TSay():New( 216, 004, {|| "Bioresistência:"}    , oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oGet14AAn  := TGet():New( 216, 060, {|u| If( PCount() > 0, nGet14AAn := u, nGet14AAn)}, oDlg01AAn, 024, 008, '@E 999.99', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "nGet14AAn", , )
       oGet14AAn:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

       oSay15AAn  := TSay():New( 232, 004, {|| "Reatância:"}         , oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oGet15AAn  := TGet():New( 232, 060, {|u| If( PCount() > 0, nGet15AAn := u, nGet15AAn)}, oDlg01AAn, 024, 008, '@E 999.99', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "nGet15AAn", , )       
       oGet15AAn:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )

       oSay16AAn  := TSay():New( 248, 004, {|| "Observações:"}       , oDlg01AAn, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
       oMGet01An  := TMultiGet():New( 248, 060,{|u| If(PCount() > 0, cMGet01An := u, cMGet01An)}, oDlg01AAn, 116, 044, , , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .F., , , .F., ,  )
       oMGet01An:lReadOnly := Iif(nOpc == 2 .or. nOpc == 5, .T., .F. )
       
       oBtn01AAn  := TButton():New( 268, 004, "Sair", oDlg01AAn, { || oDlg01AAn:End() }, 037, 012, , , , .T., , "", , , , .F. )

       oDlg01AAn:Activate(, , , .T.)
Return

Static Function fCalcIMC()
       nGet16AAn := ( nGet01AAn / (( (nGet02AAn) * (nGet02AAn)) ))
       If nGet16AAn <= 15.99
          cGet03AAn := '< 15,99 - Magreza Grau I'
       ElseIf nGet16AAn >= 16.00 .and. nGet16AAn <= 16.99
              cGet03AAn := '16,00 - 16,99 - Magreza Grau II'
       ElseIf nGet16AAn >= 17.00 .and. nGet16AAn <= 18.49
              cGet03AAn := '17,00 - 18,49 - Magreza Grau III'
       ElseIf nGet16AAn >= 18.50 .and. nGet16AAn <= 24.99
              cGet03AAn := '18,50 - 24,99 - Eutrofia'
       ElseIf nGet16AAn >= 25.00 .and. nGet16AAn <= 29.99
              cGet03AAn := '25,00 - 29,99 - Sobrepeso'
       ElseIf nGet16AAn >= 30.00 .and. nGet16AAn <= 34.99
              cGet03AAn := '30,00 - 34,99 - Obesidade Grau I'
       ElseIf nGet16AAn >= 35.00 .and. nGet16AAn <= 39.99
              cGet03AAn := '35,00 - 39,99 - Obesidade Grau II'
       Else
          cGet03AAn := '> 40.00 - Obesidade Grau III'
       Endif
       oGet16AAn:Refresh()
       oGet03AAn:Refresh()
Return

Static Function fCalCPQ()
       nGet18AAn := nGet17AAn / nGet05AAn
       DbSelectArea("TM0")
       DbSetOrder(1)
       DbSeek(xFilial("TM0")+cGetFich, .t.)
       If Found()
          If TM0->TM0_SEXO $ '1'
             If nGet18AAn <= 1.0
                cGet06AAn := 'Normal'
             Else
                cGet06AAn := 'Acima'
             Endif
          Else
             If nGet18AAn <= 0.8
                cGet06AAn := 'Normal'
             Else
                cGet06AAn := 'Acima'
             Endif
          Endif
       Endif
       oGet18AAn:Refresh()
       oGet06AAn:Refresh()
Return

Static Function fCalcPGR()
       DbSelectArea("TM0")
       DbSetOrder(1)
       DbSeek(xFilial("TM0")+cGetFich, .t.)
       If Found()
          If TM0->TM0_SEXO == '1'
             If nGet19AAn < 6
                cGet07AAn := 'Abaixo'
             ElseIf nGet19AAn > 24
                    cGet07AAn := 'Acima'
             Else 
                cGet07AAn := 'Normal'
             Endif
          Else
             If nGet19AAn < 9
                cGet07AAn := 'Abaixo'
             ElseIf nGet19AAn > 29
                    cGet07AAn := 'Acima'
             Else
                cGet07AAn := 'Normal'
             Endif
          Endif
       Endif
       oGet07AAn:Refresh()
Return

Static Function fCaluCC()
       DbSelectArea("TM0")
       DbSetOrder(1)
       DbSeek(xFilial("TM0")+cGetFich, .t.)
       If Found()
          If TM0->TM0_SEXO $ '1'
             If nGet17AAn <= 94.0
                cGet04AAn := 'Normal'
             Else
                cGet04AAn := 'Acima'
             Endif
          Else
             If nGet17AAn <= 80
                cGet04AAn := 'Normal'
             Else
                cGet04AAn := 'Acima'
             Endif
          Endif
       Endif
       oGet17AAn:Refresh()
       oGet04AAn:Refresh()
Return