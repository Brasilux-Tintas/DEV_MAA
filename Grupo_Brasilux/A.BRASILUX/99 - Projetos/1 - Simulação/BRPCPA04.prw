#include "protheus.ch"
#include "topconn.ch"
#include 'font.ch'
#include 'colors.ch'
#include 'avprint.ch'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCPA04 º Autor ³ Luís G. de Souza   º Data ³  18/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Simulação de Produtos v.1.04/09                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRPCPA04()
     Local _lOpen        := .F. //LGS#20200128 - Adequação para release 12.1.25
     Private cRotUsu   := "BRPCPA04"
     Private lFilUtil  := .t.
     Private cDepUsu   := ""
     Private cTipFil   := ""
   	 Private oObjBrow  := Nil
	 Private aIndexSZM := {}
     Private nIniFil   := 1
     Private lFiltro   := .f.        
     Private cCodUsr   := RetCodUsr()
     Private cMenssag  := ""
     Private cSubject  := ""
     Private _cAliasSX3  := GetNextAlias() //LGS#20200128 - Adequação para release 12.1.25
     Private oTempTbl01

     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200128 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0

     If !_lOpen //LGS#20200128 - Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
        Return
     Endif
     If !((SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2)) $ GETMV("MV_FILSIMU"))
        MsgStop("Essa empresa não está autorizada a utilizar a simulação de produtos. Verifique com o Administrador do sistema")
        Return
     Endif
     
     If !u_fVerAcsUsr(cRotUsu, 1, , @cDepUsu, @cTipFil)
        MsgStop("Usuário sem acesso a essa opção. ", "Atenção")
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Private cCadastro := "Simulação de Produtos - v. 1.02/13"
     Private lCopyFor  := .f.

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta um aRotina proprio                                            ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Private aRotina   := { {"Pesquisa"         , "AxPesqui"  , 0, 1},;
                            {"Visualiza"        , "u_PCPA04_0", 0, 2},;
                            {"Prod. Novo"       , "u_PCPA04_1", 0, 3},;
                            {"Simula"           , "u_PCPA04_2", 0, 4},;
                            {"Manutenção"       , "u_PCPA04_3", 0, 5},;
                            {"Cancelar"         , "u_PCPA04_4", 0, 6},;
                            {"Liberação"        , "u_PCPA04_5", 0, 3},;
                            {"Cópia"            , "u_PCPA04_6", 0, 6},;
                            {"Reprog. Previsão" , "u_PCPA04_9", 0, 6},;
                            {"Histórico"        , "u_PCPA04_7", 0, 6},;
                            {"Filtra Pendentes" , "u_PCPA04_8(nIniFil)", 0, 6},;
                            {"Legenda"          , "u_PCPA04_L", 0, 6} }
                            
     DbSelectArea("SZM")
     If __CUSERID $ '000000' .or. __CUSERID $ '000071'
        aAdd(aRotina, { OemToAnsi("Liber.")      , 'u_PCPA04_5'  , 0, 3} )
     Endif
     If __CUSERID $ '000000' .or. u_fRetGrupoUser() $ '000000'
        aAdd(aRotina, { OemToAnsi("Acessos")      , 'U_SENA01(cRotUsu)'  , 0, 6} )
     Endif
                            
     Private aCores    := { { 'SZM->ZM_STATUS $ "EE"    .AND. ( SZM->ZM_DTPREVI >= DDATABASE .OR. EMPTY(SZM->ZM_DTPREVI) ) ', 'DISABLE'    },;
                            { 'SZM->ZM_STATUS $ "PP" '                                                                      , 'BR_AMARELO' },;
                            { 'SZM->ZM_STATUS == "EA"'                                                                      , 'BR_AZUL'    },;
                            { 'SZM->ZM_STATUS == "AC"'                                                                      , 'ENABLE'     },;
                            { 'SZM->ZM_STATUS == "RE"'                                                                      , 'BR_PRETO'   },;
                            { 'SZM->ZM_STATUS == "RX"'                                                                      , 'BR_LARANJA' },;
                            { 'SZM->ZM_STATUS == "RT"'                                                                      , 'BR_CINZA'   },;
                            { 'SZM->ZM_STATUS $ "EE.PP" .AND. SZM->ZM_DTPREVI < DDATABASE'                                  , 'BR_BRANCO'  } }

     Private cDelFunc  := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
     Private cString   := "SZM"

     DbSelectArea("SM2")
     DbSetOrder(1)
     DbGoBottom()
     Private nDolarDia := SM2->M2_MOEDA2
     Private cCodCopy := ""
     Private cRevCopy := ""
     Private cEmprFili := ""
     
     DbSelectArea("SZM")
     DbSetOrder(1)
     
	 oObjBrow := FWMBrowse():New()
	 oObjBrow:SetAlias("SZM")		// Indica o Alias da tabela utilizada no Browse
	 oObjBrow:SetMenuDef(cRotUsu)
	 oObjBrow:SetWalkThru(.F.)
	 oObjBrow:SetUseFilter(.T.)
	 if type("oObjBrow:lDetails") != "U"
		 oObjBrow:lDetails := .F.
	 endif 
	 oObjBrow:SetExecuteDef(2)		// Elemento do aRotina executado no duplo clique
	 oObjBrow:AddLegend( 'SZM->ZM_STATUS == "EE"' , 'DISABLE'    , "Analise Química" )
	 oObjBrow:AddLegend( 'SZM->ZM_STATUS == "PP"' , 'BR_AMARELO' , "Analise PCP" )
	 oObjBrow:AddLegend( 'SZM->ZM_STATUS == "EA"' , 'BR_AZUL'    , "Analise Diretoria" )
	 oObjBrow:AddLegend( 'SZM->ZM_STATUS == "AC"' , 'ENABLE'     , "Aprovado" )
	 oObjBrow:AddLegend( 'SZM->ZM_STATUS == "RE"' , 'BR_PRETO'   , "Rejeitado" )
	 oObjBrow:AddLegend( 'SZM->ZM_STATUS == "RT"' , 'BR_CINZA'   , "Retorno Status" )
     

	 oObjBrow:Activate()	
 	 EndFilBrw("SZM",aIndexSZM)

     dbSelectArea( _cAliasSX3 )
     dbCloseArea()

//     DbSelectArea(cString)
//     mBrowse( 6, 1, 22, 75, cString, , , , U_PCPA04_8(), , aCores, , , , , .t.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCPA04_0 ºAutor  ³ Luís G. de Souza   º Data ³  19/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visualiza a revisão de uma fórmula.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCPA04_0(cAlias, nRecno, nOpc)
     Private nRadMen
     Private cSayPRNE   := "PE - PRODUTO EXISTENTE"
     Private cRevisao   := SZM->ZM_REVISAO
	
	IF !(cNumEmp == "01010104")
        If Len(Alltrim(SZM->ZM_CODIGO)) == 12
           nRadMen := 1
        ElseIf Len(Alltrim(SZM->ZM_CODIGO)) == 4
               nRadMen := 2
        Else
           nRadMen := 3
        Endif
	ELSE
            If Len(Alltrim(SZM->ZM_CODIGO)) == 12
               nRadMen := 1
            Else
               nRadMen := 2
            Endif
    ENDIF
     //Faz a Chamada para a função da tela principal da simulação
     MsgRun(OemToAnsi('Gerando a visualização...... Aguarde....'), '', {|| CursorWait(), PCPA04_PR(cAlias, nRecno, nOpc, 'V'), CursorArrow() } )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCPA04_1 ºAutor  ³ Luís G. de Souza   º Data ³  19/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusão de produto novo na simulação.                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCPA04_1(cAlias, nRecno, nOpc)
     If !u_fVerAcsUsr(cRotUsu, 2)
        MsgStop("Usuário sem acesso a essa opção.", "Atenção")
        Return
     Endif
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cGetCarT   := Space(3)
     Private cGetLinT   := Space(2)
     Private cGetCorT   := Space(2)
     Private cGetVarT   := Space(3)
     Private cGetEmbT   := Space(2)
     Private cGetLocT   := Space(2)
     Private cGetUMeT   := Space(2)
     Private cGetTipT   := Space(2)
     Private cGetCodT   := Space(15)
     Private cGetDesT   := Space(30)
     Private nRadMen
     Private nCBoxCo
     Private cPicCodT   := '@!R AA 99.99.999-99'
     Private cSayPRNE   := "PE - PRODUTO EXISTENTE"
     Private cRevisao   := ""
     Private lSaiNovo   := .f.

     If lCopyFor //Se a rotina vier da cópia de produto, travar alguns campos.
        If Len(Alltrim(cCodCopy)) == 4
           nRadMen := 2
        ElseIf Len(Alltrim(cCodCopy)) == 5 .or. Len(Alltrim(cCodCopy)) == 6
               nRadMen := 3
        ElseIf Len(Alltrim(cCodCopy)) == 12 .and. SubStr(cCodCopy, 11, 2) $ '00'
               nRadMen := 1
        Else
           nRadMen := 1
        Endif
     Endif
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFontGer", "oFontDes", "oDlgPNov", "oRadMenu", "oGrpOpca", "oSayCarT", "oSayLinT", "oSayCorT", "oSayVarT", "oSayEmbT")
     SetPrvt("oSayLocT", "oSayTipT", "oSayUMeT", "oSayCodT", "oSayDesT", "oGetCarT", "oGetLinT", "oGetCorT", "oGetVarT", "oGetEmbT")
     SetPrvt("oGetLocT", "oGetTipT", "oGetUMeT", "oGetCodT", "oGetDesT", "oBtnConf", "oBtnSair", "oSayClas", "oCBoxCon", "oBtnVolt")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFontGer := TFont():New( "MS Sans Serif", 0, -16, , .F., 0, , 400, .F., .F., , , , , , )
     oFontDes := TFont():New( "MS Sans Serif", 0, -13, , .T., 0, , 700, .F., .F., , , , , , )
     oDlgPNov := MSDialog():New( 085, 310, 405, 1039, "Produto Novo", , , .F., , , , , , .T., , oFontGer, .T.)
     oGrpRadi := TGroup():New( 004, 004, 070, 360, "", oDlgPNov, CLR_BLACK, CLR_WHITE, .T., .F. )
     oGrpRadi:oFont := oFontGer
     If !(cNumEmp == "01010104")
        oRadMenu    := TRadMenu():New( 010, 010, {"Tintas", "Pastas / Soluções", "Concentrados"}, {|u| If(PCount() > 0, nRadMen := u, nRadMen)}, oDlgPNov, , , CLR_BLACK, CLR_WHITE, "", , , 344, 20, , .F., .T., .T. )
        oRadMenu:SetFont(oFontDes)
     Else
            oRadMenu    := TRadMenu():New( 010, 010, {"Tintas", "Resina"}, {|u| If(PCount() > 0, nRadMen := u, nRadMen)}, oDlgPNov, , , CLR_BLACK, CLR_WHITE, "", , , 344, 20, , .F., .T., .T. )
            oRadMenu:SetFont(oFontDes)
     endif 
	 /*
        MsgStop("Empresa não possui simulação.")
        oDlgPNov:End()
        Return
     Endif
	 */
     If lCopyFor //Se a rotina vier da cópia de produto, travar alguns campos.
        oRadMenu:lReadOnly := .t.
     Endif
     oGrpOpca    := TGroup():New( 072, 004, 140, 360, "Tintas", oDlgPNov, CLR_BLACK, CLR_WHITE, .T., .F. )

     //Variáveis para Tintas
     oSayCarT    := TSay():New( 082, 008, {||"Caracteristica:"}, oGrpOpca, , oFontDes, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 052, 010)
     oSayLinT    := TSay():New( 082, 120, {||"Linha:"}         , oGrpOpca, , oFontDes, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 024, 010)
     oSayCorT    := TSay():New( 082, 204, {||"Cor:"}           , oGrpOpca, , oFontDes, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 016, 010)
     oSayVarT    := TSay():New( 082, 280, {||"Variação:"}      , oGrpOpca, , oFontDes, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 036, 010)
     oSayEmbT    := TSay():New( 102, 008, {||"Embalagem:"}     , oGrpOpca, , oFontDes, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 044, 010)
     oSayLocT    := TSay():New( 102, 112, {||"Local:"}         , oGrpOpca, , oFontDes, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 024, 010)
     oSayTipT    := TSay():New( 102, 196, {||"Tipo:"}          , oGrpOpca, , oFontDes, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 020, 010)
     oSayUMeT    := TSay():New( 102, 276, {||"Un. Medida:"}    , oGrpOpca, , oFontDes, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 044, 010)
     oSayCodT    := TSay():New( 122, 008, {||"Codigo:"}        , oGrpOpca, , oFontDes, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 028, 010)
     oSayDesT    := TSay():New( 122, 116, {||"Descrição:"}     , oGrpOpca, , oFontDes, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 040, 010)
     oSayPRNE    := TSay():New( 144, 080, {||cSayPRNE }        , oDlgPNov, , oFontGer, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 140, 008)
     oSayPRNE:lVisible := .f.
     oGetCarT    := TGet():New( 080, 064, {|u| If(PCount() > 0, cGetCarT := u, cGetCarT)}, oGrpOpca, 020, 012, '@! AA'              , , CLR_BLACK, CLR_WHITE, oFontGer, , , .T., "", , , .F., .F., , .F., .F., "SZ4", "cGetCarT", , )
     oGetCarT:bLostFocus := {|| fValTlPN(1) }
     oGetLinT    := TGet():New( 080, 148, {|u| If(PCount() > 0, cGetLinT := u, cGetLinT)}, oGrpOpca, 020, 012, '@R 99'              , , CLR_BLACK, CLR_WHITE, oFontGer, , , .T., "", , , .F., .F., , .F., .F., "SZ1", "cGetLinT", , )
     oGetLinT:bValid := {|| fValTlPN(2) }
     oGetCorT    := TGet():New( 080, 224, {|u| If(PCount() > 0, cGetCorT := u, cGetCorT)}, oGrpOpca, 020, 012, '@R 99'              , , CLR_BLACK, CLR_WHITE, oFontGer, , , .T., "", , , .F., .F., , .F., .F., "SZ2", "cGetCorT", , )
     oGetCorT:bValid := {|| fValTlPN(3) }
     oGetVarT    := TGet():New( 080, 320, {|u| If(PCount() > 0, cGetVarT := u, cGetVarT)}, oGrpOpca, 020, 012, '@R 999'             , , CLR_BLACK, CLR_WHITE, oFontGer, , , .T., "", , , .F., .F., , .F., .F., "SZ3", "cGetVarT", , )
     oGetVarT:bValid := {|| fValTlPN(4) }
     oGetEmbT    := TGet():New( 100, 056, {|u| If(PCount() > 0, cGetEmbT := u, cGetEmbT)}, oGrpOpca, 020, 012, '@R 99'              , , CLR_BLACK, CLR_WHITE, oFontGer, , , .T., "", , , .F., .F., , .F., .F., "SZ5", "cGetEmbT", , )
     oGetEmbT:bValid := {|| fValTlPN(5) }
     oGetLocT    := TGet():New( 100, 140, {|u| If(PCount() > 0, cGetLocT := u, cGetLocT)}, oGrpOpca, 020, 012, '@!'                 , , CLR_BLACK, CLR_WHITE, oFontGer, , , .T., "", , , .F., .F., , .F., .F., ""   , "cGetLocT", , )
	 oGetLocT:bValid := {|| fValTlPN(8) }     
     oGetTipT    := TGet():New( 100, 220, {|u| If(PCount() > 0, cGetTipT := u, cGetTipT)}, oGrpOpca, 020, 012, '@!'                 , , CLR_BLACK, CLR_WHITE, oFontGer, , , .T., "", , , .F., .F., , .T., .F., ""   , "cGetTipT", , )
     oGetUMeT    := TGet():New( 100, 324, {|u| If(PCount() > 0, cGetUMeT := u, cGetUMeT)}, oGrpOpca, 020, 012, ''                   , , CLR_BLACK, CLR_WHITE, oFontGer, , , .T., "", , , .F., .F., , .T., .F., ""   , "cGetUMeT", , )
     oGetCodT    := TGet():New( 120, 040, {|u| If(PCount() > 0, cGetCodT := u, cGetCodT)}, oGrpOpca, 072, 012, cPicCodT             , , CLR_BLACK, CLR_WHITE, oFontGer, , , .T., "", , , .F., .F., , .T., .F., ""   , "cGetCodT", , )
     oGetCodT:bValid := {|| fValTlPN(6) }
     oGetDesT    := TGet():New( 120, 160, {|u| If(PCount() > 0, cGetDesT := u, cGetDesT)}, oGrpOpca, 196, 012, '@!'                 , , CLR_BLACK, CLR_WHITE, oFontGer, , , .T., "", , , .F., .F., , .F., .F., ""   , "cGetDesT", , )

     //Variáveis para Concentrados
     oSayClas    := TSay():New( 102, 008, {||"Classificação:"} , oGrpOpca, , oFontDes, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 048, 010)
     oCBoxCon    := TComboBox():New( 100, 060, {|u| If(PCount() > 0, nCBoxCo := u, nCBoxCo)}, {" - Base Solvente", "1- Base D'Agua"}, 072, 014, oGrpOpca, , , , CLR_BLACK, CLR_WHITE, .T., oFontGer, "", , , , , , , nCBoxCo )
     oSayClas:lVisible := .f.; oCBoxCon:lVisible := .f.; oCBoxCon:lReadOnly := .t.
     oCBoxCon:bValid := {|| fValTlPN(7) }
     oRadMenu:bChange := {|| fTrocaPN()  }
     oBtnVolt    := TButton():New( 144, 004, "&Voltar"   , oDlgPNov, {|| fVolT1PN()                                     }, 045, 012, , oFontGer, , .T., , "", , , , .F. )
     oBtnConf    := TButton():New( 144, 244, "&Confirmar", oDlgPNov, {|| fConT1PN(cAlias, nRecno, nOpc), oDlgPNov:End() }, 045, 012, , oFontGer, , .T., , "", , , , .F. )
     oBtnSair    := TButton():New( 144, 312, "&Sair"     , oDlgPNov, {|| lSaiNovo := .t., oDlgPNov:End()                                 }, 045, 012, , oFontGer, , .T., , "", , , , .F. )

     oDlgPNov:bInit := { || fTrocaPN() }
     oDlgPNov:Activate(,,,.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCPA04_2 ºAutor  ³ Luís G. de Souza   º Data ³  19/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera uma nova revisão da fórmula do produto.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCPA04_2(cAlias, nRecno, nOpc, nOrigem)
     Local cQry1 := ""
     Local nSimAberta := 0
     Private nRadMen
     Private cSayPRNE   := "PE - PRODUTO EXISTENTE"
     Private cRevisao   := Posicione("SZM", 3, xFilial("SZM")+SZM->ZM_CODIGO, "ZM_REVISAO")
     Private cCodigo    := Iif(Empty(SZM->ZM_CODIGO) , cGetCodT, SZM->ZM_CODIGO)
     Private cDescri    := Iif(Empty(SZM->ZM_DESCRIC), cGetDesT, SZM->ZM_DESCRIC)
     
     cQry1 := "SELECT COUNT(SZM.ZM_STATUS) AS QTDSTA "
     cQry1 += "FROM "+RetSqlName("SZM")+" SZM WITH (NOLOCK) "
     cQry1 += "WHERE SZM.ZM_FILIAL  = '"+xFilial("SZM")+"' "
     cQry1 += "  AND SZM.D_E_L_E_T_ = '' "
     cQry1 += "  AND SZM.ZM_CODIGO  = '"+cCodigo+"' "
     cQry1 += "  AND SZM.ZM_STATUS IN ('EE', 'PP') "
     TCQuery cQry1 ALIAS "TCQ" NEW

     DbSelectArea("TCQ")
     nSimAberta := TCQ->QTDSTA
     DbSelectArea("TCQ")
     DbCloseArea()
     If nSimAberta > 0
        MsgStop("Atenção, existe simulação em aberto para esse produto, verifique antes de tentar gerar uma nova simulação.")
        Return
     Endif
     If !(cNumEmp == "01010104")
        If Len(Alltrim(cCodigo)) == 12
           If SZM->ZM_TIPO $ 'PI
              If !u_fVerAcsUsr(cRotUsu, 3)
                 MsgStop("Usuário sem acesso a essa opção.", "Atenção")
                 Return
              Endif
           Else 
              If !u_fVerAcsUsr(cRotUsu, 4)
                 MsgStop("Usuário sem acesso a essa opção.", "Atenção")
                 Return
              Endif
           Endif
           nRadMen := 1
        ElseIf Len(Alltrim(cCodigo)) == 4
               If !u_fVerAcsUsr(cRotUsu, 3)
                  MsgStop("Usuário sem acesso a essa opção.", "Atenção")
                  Return
               Endif
               nRadMen := 2
        Else
           If !u_fVerAcsUsr(cRotUsu, 3)
              MsgStop("Usuário sem acesso a essa opção.", "Atenção")
              Return
           Endif
           nRadMen := 3
        Endif
     Else
            If Len(Alltrim(cCodigo)) == 12
               If SZM->ZM_TIPO $ 'PI
                  If !u_fVerAcsUsr(cRotUsu, 3)
                     MsgStop("Usuário sem acesso a essa opção.", "Atenção")
                     Return
                  Endif
               Else 
                  If !u_fVerAcsUsr(cRotUsu, 4)
                     MsgStop("Usuário sem acesso a essa opção.", "Atenção")
                     Return
                  Endif
               Endif
               nRadMen := 1
            Else
               If !u_fVerAcsUsr(cRotUsu, 4)
                  MsgStop("Usuário sem acesso a essa opção.", "Atenção")
                  Return
               Endif
               nRadMen := 2
            Endif
     Endif
     cQry1 := ""
     cQry1 += "SELECT MAX(SZM.ZM_REVISAO) + 1 AS REVISAO "
     cQry1 += "FROM "+RetSqlName("SZM")+" SZM WITH (NOLOCK) "
     cQry1 += "WHERE SZM.ZM_FILIAL  = '"+xFilial("SZM")+"' "
     cQry1 += "  AND SZM.D_E_L_E_T_ = '' "
     cQry1 += "  AND SZM.ZM_CODIGO  = '"+cCodigo+"' "
     TCQuery cQry1 ALIAS "TCQ" NEW

     DbSelectArea("TCQ")
     nRevisao := Iif(TCQ->REVISAO == 0, 1, TCQ->REVISAO)
     
     DbSelectArea("TCQ")
     DbCloseArea()
     If MsgYesNo("Será gerada a revisão "+StrZero(nRevisao, 3)+" para o produto "+Alltrim(cCodigo)+" ("+Alltrim(cDescri)+"), continua ?", "Continua...")
        //Faz a Chamada para a função da tela principal da simulação
        MsgRun(OemToAnsi('Gerando uma nova revisão.... Aguarde....'), '', {|| CursorWait(), PCPA04_PR(cAlias, nRecno, nOpc, 'S'), CursorArrow() } )
     Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCPA04_3 ºAutor  ³ Luís G. de Souza   º Data ³  19/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Manutenção de simulação ainda não aprovada.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCPA04_3(cAlias, nRecno, nOpc)
     Private nRadMen
     Private cSayPRNE   := "PE - PRODUTO EXISTENTE" //Iif(SZM->ZM_TIPOPRO $ 'PN', 'PN - Produto Novo', "PE - PRODUTO EXISTENTE")
     Private cRevisao   := SZM->ZM_REVISAO
     
     If !SZM->ZM_STATUS $ 'EE.PP'
        MsgStop("O status dessa fórmula não permite manutenção da mesma.")
        Return
     Else
        If !Alltrim(Upper(cUserName)) $ Alltrim(Upper(SZM->ZM_RESPONS)) .AND. !Empty(SZM->ZM_RESPONS)
           MsgStop("Usuário não é o responsável por essa fórmula")
           Return
        Endif
     Endif
     If SZM->ZM_STATUS $ 'PP' .and. Len(Alltrim(SZM->ZM_CODIGO)) == 12 .and. SubStr(SZM->ZM_CODIGO, 11, 2) == '00'
        MsgStop("O status dessa fórmula não permite manutenção da mesma.")
        Return
     Endif
     If !(cNumEmp == "01010104")
        If Len(Alltrim(SZM->ZM_CODIGO)) == 12
           nRadMen := 1
        ElseIf Len(Alltrim(SZM->ZM_CODIGO)) == 4
               nRadMen := 2
        Else
           nRadMen := 3
        Endif
     Else
            If Len(Alltrim(SZM->ZM_CODIGO)) == 12
               nRadMen := 1
            Else
               nRadMen := 2
            Endif
     Endif
     //Faz a Chamada para a função da tela principal da simulação
     MsgRun(OemToAnsi('Abrindo tela de manutenção.. Aguarde....'), '', {|| CursorWait(), PCPA04_PR(cAlias, nRecno, nOpc), CursorArrow() } )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCPA04_4 ºAutor  ³ Luís G. de Souza   º Data ³  03/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclusão de simulação ainda não aprovada.                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCPA04_4(cAlias, nRecno, nOpc)
     Private nRadMen
     Private cSayPRNE   := "PE - PRODUTO EXISTENTE"
     Private cRevisao   := SZM->ZM_REVISAO
     If SZM->ZM_STATUS $ 'AC.RT.RE.EA.RX'
        MsgStop("Atenção, o status dessa fórmula não permite a exclusão da mesma.")
        Return
     ElseIf SZM->ZM_STATUS $ 'PP'
            cQry1 := ""
            cQry1 += "SELECT COUNT(*) AS QTDREG "
            cQry1 += "FROM SZM010 SZM WITH (NOLOCK) "
            cQry1 += "WHERE SZM.ZM_FILIAL = '"+xFilial("SZM")+"' "
            cQry1 += "  AND SZM.D_E_L_E_T_ = '' "
            cQry1 += "  AND SZM.ZM_ID = '"+SZM->ZM_ID+"' "
            TCQuery cQry1 ALIAS "TCQ" NEW
            DbSelectArea("TCQ")
            DbGoTop()
            nQtdReg := TCQ->QTDREG
            DbSelectArea("TCQ")
            DbCloseArea()
            If nQtdReg > 1
               MsgStop("Atenção, o status dessa fórmula não permite a exclusão da mesma.")
               Return
            Endif
            DbSelectArea("SZM")
     Else
        If !Alltrim(Upper(SZM->ZM_RESPONS)) $ Alltrim(Upper(cUserName))
           MsgStop("Atenção, esse usuário não é o responsável pela formulação para exclusão da mesma.")
           Return
        Endif
     Endif
     If !(cNumEmp == "01010104")
        If Len(Alltrim(SZM->ZM_CODIGO)) == 12
           nRadMen := 1
        ElseIf Len(Alltrim(SZM->ZM_CODIGO)) == 4
               nRadMen := 2
        Else
           nRadMen := 3
        Endif
     Else
            If Len(Alltrim(SZM->ZM_CODIGO)) == 12
               nRadMen := 1
            Else
               nRadMen := 2
            Endif
     Endif
     //Faz a Chamada para a função da tela principal da simulação
     PCPA04_PR(cAlias, nRecno, nOpc)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCPA04_5 ºAutor  ³ Luís G. de Souza   º Data ³  05/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Libera a simulação ainda não aprovada.                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCPA04_5(cAlias, nRecno, nOpc)
     //Local bLDblClick
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cGet1Lib   := SZM->ZM_CODIGO
     Private cGet2Lib   := SZM->ZM_DESCRIC
     Private cGet3Lib   := SZM->ZM_TIPO
     Private cGet4Lib   := SZM->ZM_LOCAL
     Private cGet5Lib   := Iif(SZM->ZM_TIPOPRO $ 'PN', 'NOVO', 'EXISTENTE')
     Private aFolder1	:= {"", "Fórmulas"}
     Private cPictPro   := Iif(Len(Alltrim(cGet1Lib)) == 12, '@!R AA 99.99.999-99', '@!')
     Private cIdProce   := SZM->ZM_ID
     Private nGet1Lib   := 0
     Private nGet2Lib   := 0
     Private nGet5Lib   := 0
     Private nGet6Lib   := 0
     Private nGet7Lib   := 0
     Private cSay7Lib   := "Custo(R$/L):"
     Private cSay8Lib   := "Custo(U$):"
     Private cSayBLib   := "Custo(R$/K):"

     Private cSay9Lib   := "Custo(R$/L):"
     Private cSayALib   := "Custo(U$):"
     Private cSayCLib   := Space(1)
     Private cSayDLib   := "Custo(R$/K):"
     Private cSayELib   := Space(1)
     Private nGet3Lib   := 0
     Private nGet4Lib   := 0
     Private nGet9Lib   := 0
     Private nGetALib   := 0
     Private nGetBLib   := 0
     Private cMGet1Li
     Private cMarSimu   := GetMark()
     Private cMonitor   := ''
     Private oTmpHis := "" //Objeto para criar cursor temporário
     Private oTmpVig := "" //Objeto para criar cursor temporário
     Private oTmpLib := "" //Objeto para criar cursor temporário
     Private oTmpRev := "" //Objeto para criar cursor temporário

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1Li", "oDlg1Lib", "oFld1Lib", "oBtn1Lib", "oBtn2Lib", "oBtn4Lib", "oBtn3Lib", "oGrp1Lib", "oGet1Lib")
     SetPrvt("oGet3Lib", "oGet4Lib", "oGet5Lib", "oBrw1Lib", "oSay1Lib", "oSay2Lib", "oGrp2Lib", "oGrp3Lib", "oSay3Lib")
     SetPrvt("oGet1Lib", "oSay4Lib", "oGet2Lib", "oSay7Lib", "oGet5Lib", "oSay8Lib", "oGet6Lib", "oSayBLib", "oGet7Lib")
     SetPrvt("oSay5Lib", "oGet3Lib", "oSay6Lib", "oGet4Lib", "oSayALib", "oGetALib", "oSayDLib", "oGetBLib", "oMGet1Li")
     SetPrvt("oBmp1Lib")
     //Verificação de acesso a rotina
     If SZM->ZM_STATUS $ 'EE'
        If !u_fVerAcsUsr(cRotUsu, 3)
           MsgStop("Usuário sem acesso a essa opção.", "Atenção")
           Return
        Endif
     ElseIf SZM->ZM_STATUS $ 'PP'
            If !u_fVerAcsUsr(cRotUsu, 4)
               MsgStop("Usuário sem acesso a essa opção.", "Atenção")
               Return
            Endif
            cQry1 := ""
            cQry1 += "SELECT COUNT(*) AS QTDREC "
            cQry1 += "FROM "+RetSqlName("SZM")+" SZM "
            cQry1 += "WHERE SZM.ZM_FILIAL  = '"+xFilial("SZM")+"' "
            cQry1 += "  AND SZM.D_E_L_E_T_ = '' "
            cQry1 += "  AND SZM.ZM_ID      = '"+SZM->ZM_ID+"' "
            cQry1 += "  AND SZM.ZM_RESPONS = '' "
            TCQUERY cQry1 ALIAS "TCQ" NEW
            DbSelectArea("TCQ")
            DbGoTop()
            nQtdRes := TCQ->QTDREC
            DbSelectArea("TCQ")
            DbCloseArea()
            DbSelectArea("SZM")
            If nQtdRes > 0
               MsgStop("Atenção, existe(m) fórmula(s) de embalagem(ns) sem ter(em) sido analisada(s)!")
               Return
            Endif
     ElseIf SZM->ZM_STATUS $ 'EA'
            If !u_fVerAcsUsr(cRotUsu, 6)
               MsgStop("Usuário sem acesso a essa opção.", "Atenção")
               Return
            Endif
     Else
        MsgStop("Esse status não permite o uso dessa opção.", "Atenção")
        Return
     Endif
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1Li   := TFont():New( "MS Sans Serif", 0, -16, , .F., 0, , 400, .F., .F., , , , , , )
     oFont2Li   := TFont():New( "Courier New"  , 0, -21, , .T., 0, , 700, .F., .F., , , , , , )
     oFont3Li   := TFont():New( "MS Sans Serif", 0, -13, , .F., 0, , 400, .F., .F., , , , , , )
     oDlg1Lib   := MSDialog():New( 111, 247, 578, 1032, "Liberação", , , .F., , , , , , .T., , , .T. )
     If SZM->ZM_STATUS <> 'EE'
        oBtn1Lib   := TButton():New( 003, 004, "Devolve", oDlg1Lib, {|| MsgRun(OemToAnsi('Devolvendo formulação........ Aguarde....'), '', {|| CursorWait(), fDevolveFormula(), CursorArrow() } ) }, 056, 012, , , , .T., , "", , , , .F. )
     Endif
     If SZM->ZM_STATUS $ 'EA'
        oBtn2Lib   := TButton():New( 003, 080, "Rejeita", oDlg1Lib,                       , 056, 012, , , , .T., , "", , , , .F. )
     Endif
     oBtn3Lib   := TButton():New( 003, 260, "Libera" , oDlg1Lib, {|| MsgRun(OemToAnsi('Liberando formulação........ Aguarde....'), '', {|| CursorWait(), fLiberaFor(), CursorArrow() } ) }, 056, 012, , , , .T., , "", , , , .F. )
     oBtn4Lib   := TButton():New( 003, 336, "Sair"   , oDlg1Lib, {|| oDlg1Lib:End() }  , 056, 012, , , , .T., , "", , , , .F. )
     //oGet3Lib   := TGet():New( 024, 264, {|u| If( PCount() > 0, cGet3Lib := u, cGet3Lib) }, oGrp1Lib, 022, 012, '@!'    , , CLR_BLUE, CLR_WHITE, oFont1Li, , , .T., "", , , .F., .F., , .T., .F., "", "cGet3Lib", , )
     //oGet4Lib   := TGet():New( 024, 290, {|u| If( PCount() > 0, cGet4Lib := u, cGet4Lib) }, oGrp1Lib, 022, 012, '@!'    , , CLR_BLUE, CLR_WHITE, oFont1Li, , , .T., "", , , .F., .F., , .T., .F., "", "cGet4Lib", , )
     //oGet5Lib   := TGet():New( 024, 316, {|u| If( PCount() > 0, cGet5Lib := u, cGet5Lib) }, oGrp1Lib, 070, 012, '@!'    , , CLR_BLUE, CLR_WHITE, oFont1Li, , , .T., "", , , .F., .F., , .T., .F., "", "cGet5Lib", , )
     
     oFld1Lib   := TFolder():New( 016, 004, aFolder1, {}, oDlg1Lib, , , , .T., .F., 388, 214, )

     oGrp1Lib   := TGroup():New( 000, 002, 021, 260, "Dados do Produto", oFld1Lib:aDialogs[2], CLR_RED,  CLR_WHITE, .T., .F. )
     oGet1Lib   := TGet():New( 007, 004, {|u| If( PCount() > 0, cGet1Lib := u, cGet1Lib) }, oGrp1Lib, 072, 010, cPictPro, , CLR_BLUE, CLR_WHITE, oFont3Li, , , .T., "", , , .F., .F., , .T., .F., "", "cGet1Lib", , )
     oGet2Lib   := TGet():New( 007, 080, {|u| If( PCount() > 0, cGet2Lib := u, cGet2Lib) }, oGrp1Lib, 176, 010, '@!'    , , CLR_BLUE, CLR_WHITE, oFont3Li, , , .T., "", , , .F., .F., , .T., .F., "", "cGet2Lib", , )
     
     /*********************************************************************************************************************************************/
     If oTbl1Lib()
        MsgStop("Existe(m) formulação(ões) de produto(s) sem responsável!", "Verifique...")
        Return
     Endif
     DbSelectArea("TMPLIB")
     DbSetOrder(1)
     oFon1Lib := TFont():New( "Courier New"  , 0,  19, , .T., 0, , 400, .F., .F., , , , , , )
     oBrw1Lib   := MsSelect():New( "TMPLIB", "LIBMAR", "", { {"LIBMAR", "", "", ""}, {"LIBPRO", "", "Produto", "@R! AA 99.99.999-99"}, {"LIBDES", "", "Descricao", "@!"}, {"LIBREV", "", "Revisao", "@R 999"}, {"LIBRES", "", "Responsavel", "@!"} }, .F., cMarSimu, {004, 002, 098, 364}, , , oFld1Lib:aDialogs[1] ) 
     oBrw1Lib:oFont       := oFon1Lib
     oBrw1Lib:bMark               := {|| TMPLIBMark()}
     oBrw1Lib:oBrowse:bChange     := {|| fMoviFor("B") }
     oBrw1Lib:oBrowse:lAllMark    := .T.
     oBrw1Lib:oBrowse:lHasMark    := .T.
     oBrw1Lib:oBrowse:lCanAllmark := .T.

     If TMPLIB->(RecCount()) > 1
        @ 009, 736 BTNBMP oBtnBmp1 RESNAME "UP3_MDI"   SIZE 030, 030 OF oFld1Lib:aDialogs[1] MESSAGE "Anterior" ACTION fMoviFor("A") WHEN .T.
        @ 164, 736 BTNBMP oBtnBmp2 RESNAME "DOWN3_MDI" SIZE 030, 030 OF oFld1Lib:aDialogs[1] MESSAGE "Próximo"  ACTION fMoviFor("P") WHEN .T.
        @ 010, 536 BTNBMP oBtnBmp1 RESNAME "LEFT_MDI"  SIZE 030, 030 OF oFld1Lib:aDialogs[2] MESSAGE "Anterior" ACTION fMoviFor("A") WHEN .T.
        @ 010, 726 BTNBMP oBtnBmp2 RESNAME "RIGHT_MDI" SIZE 030, 030 OF oFld1Lib:aDialogs[2] MESSAGE "Próximo"  ACTION fMoviFor("P") WHEN .T.
     Endif

     oGrp6Lib   := TGroup():New( 100, 002, 198, 384, "Histórico", oFld1Lib:aDialogs[1], CLR_BLACK, CLR_WHITE, .T., .F. )
     oTbl2Lib()
     DbSelectArea("TMPHIS")
     oBrw2Lib   := MsSelect():New( "TMPHIS", "", "", { {"HISSTA", "", "Status", ""}, {"HISGER", "", "Geração", ""} }, .F., , { 108, 006, 194, 191 }, , , oGrp6Lib )
     oMGet1Li   := TMultiGet():New( 108, 195, { |u| If(PCount() > 0, cMGet1Li := u, cMGet1Li) }, oGrp6Lib, 185, 086, , , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .T., , , .F., , )
     oBrw2Lib:oBrowse:bChange := {|| fTrocaHist() }

     /*********************************************************************************************************************************************/
     oSay1Lib   := TSay():New( 022, 002, {||"       FÓRMULA VIGENTE"          }, oFld1Lib:aDialogs[2], , oFont2Li, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 193, 009)
     oGrp2Lib   := TGroup():New( 032, 002, 057, 191, "Especificações", oFld1Lib:aDialogs[2], CLR_RED, CLR_WHITE, .T., .F. )
     oSay3Lib   := TSay():New( 042, 007, {|| "% Fórmula:"}, oGrp2Lib, , oFont3Li, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 009)
     oGet1Lib   := TGet():New( 041, 045, {|u| If(PCount() > 0, nGet1Lib := u, nGet1Lib) }, oGrp2Lib, 048, 010, '@E 999.99%' , , CLR_HBLUE, CLR_WHITE, oFont3Li, , , .T., "", , , .F., .F., , .T., .F., "", "nGet1Sim", , )
     oSay4Lib   := TSay():New( 042, 096, {|| "P. Espec.:"}, oGrp2Lib, , oFont3Li, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 008)
     oGet2Lib   := TGet():New( 041, 135, {|u| If(PCount() > 0, nGet2Lib := u, nGet2Lib) }, oGrp2Lib, 056, 010, '@E 9.999999', , CLR_HBLUE, CLR_WHITE, oFont3Li, , , .T., "", , , .F., .F., , .T., .F., "", "nGet2Lib", , )
     oGrp4Lib   := TGroup():New( 060, 002, 106, 191, "Totais"        , oFld1Lib:aDialogs[2], CLR_RED, CLR_WHITE, .T., .F. )
     oSay7Lib   := TSay():New( 070, 007, {|| cSay7Lib }, oGrp4Lib, , oFont3Li, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 009)
     oGet5Lib   := TGet():New( 069, 045, {|u| If(PCount() > 0, nGet5Lib := u, nGet5Lib) }, oGrp4Lib, 048, 010, '@E 9,999.999', , CLR_HBLUE, CLR_WHITE, oFont3Li, , , .T., "", , , .F., .F., , .T., .F., "", "nGet5Lib", , )
     oSay8Lib   := TSay():New( 070, 096, {|| cSay8Lib }, oGrp4Lib, , oFont3Li, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 008)
     oGet6Lib   := TGet():New( 069, 135, {|u| If(PCount() > 0, nGet6Lib := u, nGet6Lib) }, oGrp4Lib, 048, 010, '@E 9,999.999', , CLR_HBLUE, CLR_WHITE, oFont3Li, , , .T., "", , , .F., .F., , .T., .F., "", "nGet6Lib", , )
     oSayBLib   := TSay():New( 090, 007, {|| cSayBLib}, oGrp4Lib, , oFont3Li, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 009)
     oGet7Lib   := TGet():New( 089, 045, {|u| If(PCount() > 0, nGet7Lib := u, nGet7Lib) }, oGrp4Lib, 048, 010, '@E 9,999.999', , CLR_HBLUE, CLR_WHITE, oFont3Li, , , .T., "", , , .F., .F., , .T., .F., "", "nGet7Lib", , )
     oTbl3Lib(1)
     DbSelectArea("TMPVIG")
     DbSetOrder(1)
     oBrw3Lib   := MsSelect():New( "TMPVIG", "", "", { {"VIGCOM", "", "Componente", ""}, {"VIGDES", "", "Descrição", ""}, {"VIGTRT", "", "Seq.", ""}, {"VIGPER", "", "% Formula", "@E 999.999"}, {"VIGQTD", "", "Quantidade", "@E 999.999999"}, {"VIGPRD", "", "Perda", "@E 99.99"}, {"VIGPES", "", "P. Específico", "@E 9.999999"}, {"VIGCUN", "", "C. Unit.", "@E 9,999.999"}, {"VIGCRE", "", "C. R$", "@E 9,999.999"}, {"VIGCDO", "", "C. U$", "@E 9,999.999"} }, .F., , { 108, 002, 196, 191 }, , , oFld1Lib:aDialogs[2] )
     oBrw3Lib:oBrowse:nFreeze := 1
     /*******************************************************************************************************************************************/

     /****************************************************************************/
     oSay2Lib   := TSay():New( 022, 198, {||"        REVISÃO - "+TMPLIB->LIBREV }, oFld1Lib:aDialogs[2], , oFont2Li, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 193, 009)
     oGrp3Lib   := TGroup():New( 032, 195, 057, 384, "Especificações", oFld1Lib:aDialogs[2], CLR_RED, CLR_WHITE, .T., .F. )
     oSay5Lib   := TSay():New( 042, 202, {|| "% Fórmula:"}, oGrp3Lib, , oFont3Li, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 009)
     oGet3Lib   := TGet():New( 041, 239, {|u| If(PCount() > 0, nGet3Lib := u, nGet3Lib) }, oGrp3Lib, 048, 010, '@E 999.99%' , , CLR_HBLUE, CLR_WHITE, oFont3Li, , , .T., "", , , .F., .F., , .T., .F., "", "nGet3Lib", , )
     oSay6Lib   := TSay():New( 042, 291, {|| "P. Espec.:"}, oGrp3Lib, , oFont3Li, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 008)
     oGet4Lib   := TGet():New( 041, 328, {|u| If(PCount() > 0, nGet4Lib := u, nGet4Lib) }, oGrp3Lib, 056, 010, '@E 9.999999', , CLR_HBLUE, CLR_WHITE, oFont3Li, , , .T., "", , , .F., .F., , .T., .F., "", "nGet4Lib", , )
     oGrp5Lib   := TGroup():New( 060, 195, 106, 384, "Totais"        , oFld1Lib:aDialogs[2], CLR_RED, CLR_WHITE, .T., .F. )
     oSay9Lib   := TSay():New( 070, 202, {|| cSay9Lib }, oGrp5Lib, , oFont3Li, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 009)
     oGet9Lib   := TGet():New( 069, 239, {|u| If(PCount() > 0, nGet9Lib := u, nGet9Lib) }, oGrp5Lib, 048, 010, '@E 9,999.999', , CLR_HBLUE, CLR_WHITE,oFont3Li,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nGet9Lib",,)
     oSayALib   := TSay():New( 070, 291, {|| cSayALib }, oGrp5Lib, , oFont3Li, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 008)
     oGetALib   := TGet():New( 069, 328, {|u| If(PCount() > 0, nGetALib := u, nGetALib) }, oGrp5Lib, 048, 010, '@E 9,999.999', , CLR_HBLUE, CLR_WHITE,oFont3Li,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nGetALib",,)
     oSayDLib   := TSay():New( 090, 202, {|| cSayDLib }, oGrp5Lib, , oFont3Li, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 009)
     oGetBLib   := TGet():New( 089, 239, {|u| If(PCount() > 0, nGetBLib := u, nGetBLib) }, oGrp5Lib, 048, 010, '@E 9,999.999', , CLR_HBLUE, CLR_WHITE,oFont3Li,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nGetBLib",,)
     oBmp1Lib   := TBitmap():New( 088, 370, 012, 012, , "", .F., oGrp3Lib, , , .F., .F., , "", .T., , .T., , .F. )

     oTbl4Lib(1)
     DbSelectArea("TMPREV")
     DbSetOrder(1)
     oBrw4Lib   := MsSelect():New( "TMPREV", "", "", { {"REVCOM", "", "Componente", ""}, {"REVDES", "", "Descrição", ""}, {"REVTRT", "", "Seq.", ""}, {"REVPER", "", "% Formula", "@E 999.999"}, {"REVQTD", "", "Quantidade", "@E 999.999999"}, {"REVPRD", "", "Perda", "@E 99.99"}, {"REVPES", "", "P. Específico", "@E 9.999999"}, {"REVCUN", "", "C. Unit.", "@E 9,999.999"}, {"REVCRE", "", "C. R$", "@E 9,999.999"}, {"REVCDO", "", "C. U$", "@E 9,999.999"} }, .F., , { 108, 195, 196, 384 }, , , oFld1Lib:aDialogs[2] )
     oBrw4Lib:oBrowse:nFreeze := 1
     oDlg1Lib:Activate(,,,.T.)
     DbSelectArea("TMPLIB")
     DbCloseArea()
     oTmpLib:Delete()
     
     DbSelectArea("TMPHIS")
     DbCloseArea()
     oTmpHis:Delete()
     
     DbSelectArea("TMPVIG")
     DbCloseArea()
     oTmpVig:Delete()
     
     DbSelectArea("TMPREV")
     DbCloseArea()
     oTmpRev:Delete()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCPA04_6 ºAutor  ³ Luís G. de Souza   º Data ³  20/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Copia fórmula atual para uma nova fórmula                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCPA04_6(cAlias, nRecno, nOpc)
     If !u_fVerAcsUsr(cRotUsu, 5)
        MsgStop("Usuário sem acesso a essa opção.", "Atenção")
        Return
     Endif
     Private cCodCopy := SZM->ZM_CODIGO
     Private cRevCopy := SZM->ZM_REVISAO
     lCopyFor := .t.
     MsgRun(OemToAnsi('Iniciando cópia do produto... Aguarde....'), '', {|| CursorWait(), u_PCPA04_1(cAlias, nRecno, nOpc), CursorArrow() } )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCPA04_7 ºAutor  ³ Luís G. de Souza   º Data ³  04/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Histórico do processo de simulação.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCPA04_7(cAlias, nRecno, nOpc)
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cMGet1Li
     Private cIdProce   := SZM->ZM_ID
     Private oTmpHis := "" //objeto para conter o cursor temporário
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oDlg1His", "oGrp1His", "oMGet1Li", "oBrw2Lib", "oBtn1His")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oDlg1His   := MSDialog():New( 091, 232, 345, 915, "Histórico", , , .F., , , , , , .T., , , .T. )
     oGrp1His   := TGroup():New( 004, 004, 108, 340, "Histórico", oDlg1His, CLR_BLACK, CLR_WHITE, .T., .F. )
     oMGet1Li   := TMultiGet():New( 012, 176, {|u| If(PCount() > 0, cMGet1Li := u, cMGet1Li)}, oGrp1His, 160, 092, , , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .T., , , .F., , )
     oTbl2Lib()
     DbSelectArea("TMPHIS")
     oBrw2Lib   := MsSelect():New( "TMPHIS", "", "", { {"HISSTA", "", "Status", ""}, {"HISGER", "", "Geracao", ""} }, .F., , {012, 008, 104, 172}, , , oGrp1His )
     oBrw2Lib:oBrowse:bChange := {|| fTrocaHist() }
     oBtn1His   := TButton():New( 112, 300, "Sair", oDlg1His,{ || oDlg1His:End() }, 037, 012, , , , .T., , "", , , , .F. )

     oDlg1His:Activate(, , , .T.)
     DbSelectArea("TMPHIS")
     DbCloseArea()
     oTmpHis:Delete()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funçao    ³ PCPA08_4 ³ Autor ³ Luís G. de Souza      ³ Data ³ 11/06/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçao ³ Retorna o filtro do cadastro                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PCPA04_8()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BRPCPA04                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function PCPA04_8(nOnOff)
     Local cFiltro  
     lFilUtil := !lFilUtil
     If lFilUtil
        cFiltro := 'ZM_FILIAL == "'+xFilial("SZM")+'" .and. ZM_STATUS <> "AC"'
       	lFiltro := .t.
       	nIniFil := 1

        If cDepUsu $ 'DIR'
           cFiltro += ' .and. ( ZM_STATUS == "EA" .OR. UPPER(Alltrim(ZM_RESPONS)) $ "'+UPPER(Alltrim(cUserName))+'" ) '
        Else
           If SubStr(cTipFil, 1, 1) $ '*'
              If SubStr(cTipFil, 2, 1) $ '*'
                 cFiltro += ' .and. ( ZM_STATUS $ "EE.PP.RE.RT.RX" .OR. UPPER(Alltrim(ZM_RESPONS)) $ "'+UPPER(Alltrim(cUserName))+'" ) '
              Else
                 cFiltro += ' .and. ( ZM_STATUS $ "PP.RE.RT.RX" .OR. UPPER(Alltrim(ZM_RESPONS)) $ "'+UPPER(Alltrim(cUserName))+'" ) '
              Endif
           Else
              If SubStr(cTipFil, 2, 1) $ '*'
                 cFiltro += ' .and. ( ZM_STATUS $ "PP.RE.RT.RX" .OR. UPPER(Alltrim(ZM_RESPONS)) $ "'+UPPER(Alltrim(cUserName))+'" ) '
              Else
                 cFiltro += ' .and. ( ZM_STATUS $ "RE.RT.RX" .OR. UPPER(Alltrim(ZM_RESPONS)) $ "'+UPPER(Alltrim(cUserName))+'" ) '
              Endif
           Endif
        Endif
     Else
        lFiltro := .f.
        nIniFil := 2
        cFiltro := 'ZM_FILIAL == "'+xFilial("SZM")+'"'
     Endif

/*     DbSelectArea("SZM")
     Set Filter To &(cFiltro)
     DbSeek(xFilial("SZM"))
     DbGoTop()        */


		dbselectarea("SZM")
        
		if oObjBrow:Filtrate()
			nReg := recno()
			oObjBrow:DeleteFilter("Pendentes") 
			dbgoto(nReg)
		endif
		
		if !empty(cFiltro)
		  	oObjBrow:AddFilter("Pendentes",cFiltro,,.t.,,,,"Pendentes")
		endif            
     
Return() 

Static Function fMoviFor(cOpcCli)
       If TMPLIB->LIBSTP $ 'PE'
          DbSelectArea("SZM")
          DbSetOrder(1)
          DbSeek(xFilial("SZM")+TMPLIB->LIBPRO+TMPLIB->LIBREV, .t.)
       Endif
       If cOpcCli $ 'A'
          If TMPLIB->( RECNO() ) > 1
             nNumRec := TMPLIB->( RECNO() ) - 1
             DbSelectArea("TMPLIB")
             DbGoTo(nNumRec)
             oBrw1Lib:oBrowse:nAt := nNumRec
             oBrw1Lib:oBrowse:Refresh()
          ElseIf TMPLIB->( RECNO() ) == 1
                 nNumRec := TMPLIB->( RECCOUNT() )
                 DbSelectArea("TMPLIB")
                 DbGoTo(nNumRec)
                 oBrw1Lib:oBrowse:nAt := nNumRec
                 oBrw1Lib:oBrowse:Refresh()
          Endif
       ElseIf cOpcCli $ 'P'
              If TMPLIB->( RECNO() ) < TMPLIB->( RECCOUNT() )
                 DbSelectArea("TMPLIB")
                 DbSkip()
                 oBrw1Lib:oBrowse:nAt := TMPLIB->( RECNO() )
                 oBrw1Lib:oBrowse:Refresh()
              ElseIf TMPLIB->( RECNO() ) == TMPLIB->( RECCOUNT() )
                   nNumRec := 1
                   DbSelectArea("TMPLIB")
                   DbGoTo(nNumRec)
                   oBrw1Lib:oBrowse:nAt := nNumRec
                   oBrw1Lib:oBrowse:Refresh()
              Endif
       Endif
       MsgRun(OemToAnsi('Aguarde....'), '', {|| CursorWait(), fCarregaPr(), CursorArrow() } )
Return

Static Function fCarregaPr()
       cGet1Lib := TMPLIB->LIBPRO
       oGet1Lib:Refresh()
       cGet2Lib := TMPLIB->LIBDES
       oGet2Lib:Refresh()
       oSay2Lib:cCaption := SubStr(oSay2Lib:cCaption, 1, Len(oSay2Lib:cCaption) - 3 )+TMPLIB->LIBREV
       oSay2Lib:Refresh()

        oTbl3Lib(2)
        DbSelectArea("TMPVIG")
        DbSetOrder(1)
        DbGoTop()
        oBrw3Lib:oBrowse:Refresh()
        oTbl4Lib(2)
        DbSelectArea("TMPREV")
        DbSetOrder(1)
        DbGoTop()
        oBrw4Lib:oBrowse:Refresh()
Return

/*Static Function fMarcaProd()
       Local aArea := GetArea()

       DbSelectArea("TMPLIB")
       nReg := RecNo()
       DbGoTop()
       While !Eof()
             If nReg <> recno()
                If TMPLIB->LIBMAR == cMarSimu
                   RecLock("TMPLIB", .f.)
                      TMPLIB->LIBMAR := " "
                   MsUnLock()
                Else
                   RecLock("TMPLIB", .f.)
                      TMPLIB->LIBMAR := cMarSimu
                   MsUnLock()
                Endif
             Endif
             DbSelectArea("TMPLIB")
             DbSkip()
       Enddo
       DbSelectArea(aArea[1])
       DbSetOrder(aArea[2])
       DbGoTo(aArea[3])
       oBrw1Lib:oBrowse:Refresh(.t.)
Return*/

Static Function fLiberaFor()
       Local nConLib   := 0
       Local lMarLib   := .f.
       Local cUserList := ""
       Local cIdentLib := ""
       Local nY
       Begin Transaction
             DbSelectArea("TMPLIB")
             DbSetOrder(1)
             DbGoTop()
             While !Eof()
                   nConLib++
                   If nConLib == 1
                      If !Empty(TMPLIB->LIBMAR)
                         lMarLib := .t.
                      Endif
                   Endif
                   DbSelectArea("TMPLIB")
                   DbSkip()
             EndDo
             If lMarLib
                DbSelectArea("TMPLIB")
                DbSetOrder(1)
                DbGoTop()
                While !Eof() .and. Empty(TMPLIB->LIBLIB)
                      //Liberar trocando o status item a item.
                      If TMPLIB->LIBSTA $ 'EE' //Elaboração
                         cMenssag := "ENVIO DE FÓRMULAS "
                         cSubject := "ANÁLISE DE FÓRMULA - PCP"
                         //Mudar status
                         DbSelectArea("SZM")
                         DbSetOrder(1)
                         DbSeek(xFilial("SZM")+TMPLIB->LIBPRO+TMPLIB->LIBREV, .t.)
                         If Found()
                            //Verificar se existem embalagens a serem incluidas.
                            DbSelectArea("SZP")
                            DbSetOrder(1)
                            DbSeek(xFilial("SZP")+TMPLIB->LIBPRO+TMPLIB->LIBREV, .t.)
                            If Found()
                               cMenssag += " PARA ANÁLISE DO PCP"+Chr(10)+Chr(13)
                               cMenssag += Alltrim(TMPLIB->LIBPRO)+" / "+TMPLIB->LIBREV+"  -  "+Alltrim(TMPLIB->LIBDES)+Chr(10)+Chr(13)
                               //Mudar status para PCP
                               RecLock("SZM", .f.)
                                  SZM->ZM_STATUS := "PP"
                               MsUnLock()
                               RecLock("TMPLIB", .f.)
                                  TMPLIB->LIBLIB := "S"
                               MsUnLock()
                               //Gravar Histórico (SZT)
                               cSeqHis := "201"
                               DbSelectArea("SZT")
                               RecLock("SZT", .t.)
                                  SZT->ZT_FILIAL  := xFilial("SZT")
                                  SZT->ZT_ID      := TMPLIB->LIBIDE
                                  SZT->ZT_PROCESS := "SI"
                                  SZT->ZT_STATUS  := "PP"
                                  SZT->ZT_LOG     := "Envio de fórmula "+Alltrim(TMPLIB->LIBPRO)+" / "+TMPLIB->LIBREV+"  -  "+Alltrim(TMPLIB->LIBDES)+" para o PCP."
                                  SZT->ZT_USUARIO := cUserName
                                  SZT->ZT_DATAGER := dDataBase
                                  SZT->ZT_HORAGER := Time()
                                  SZT->ZT_SEQ     := cSeqHis
                               MsUnLock()
                               //Incluir Embalagens na simulação com o status PCP (PP)
                               While !Eof() .and. SZP->ZP_CODIGO == TMPLIB->LIBPRO .and. SZP->ZP_REVISAO == TMPLIB->LIBREV
                                     cSeqHis  := StrZero( ( Val( cSeqHis ) + 1 ), 3)
                                     _CODIGO  := Iif( cNumEmp = "01010104" .and. LEN(Alltrim(TMPLIB->LIBPRO)) == 5 .and. SubStr(TMPLIB->LIBPRO, 1, 2) == "RV", ALLTRIM( TMPLIB->LIBPRO )+SZP->ZP_EMB, Alltrim( SubStr( TMPLIB->LIBPRO, 1, 10) )+SZP->ZP_EMB )
                                     //Pesquisar se existe SB1
                                     lExisteSB1 := .f.
                                     lExisteSG1 := .f.
                                     DbSelectArea("SB1")
                                     DbSetOrder(1)
                                     DbSeek(xFilial("SB1")+_CODIGO, .t.)
                                     If Found()
                                        lExisteSB1 := .t.
                                     Endif
                                     //Pesquisar se existe SG1
                                     DbSelectArea("SG1")
                                     DbSetOrder(1)
                                     DbSeek(xFilial("SG1")+_CODIGO, .t.)
                                     If Found()
                                        lExisteSG1 := .t.
                                     Endif
                                     //Gravar SZM gerando a revisão para a ultima revisão + 1 disponível.
                                     DbSelectArea("SZM")
                                     DbSetOrder(3)
                                     DbSeek(xFilial("SZM")+_CODIGO, .t.)
                                     If Found()
                                        _REVIANT := SZM->ZM_REVISAO
                                        _REVISAO := StrZero( ( Val( SZM->ZM_REVISAO ) + 1 ), 3 )
                                        _DESCRIC := SZM->ZM_DESCRIC
                                        _RESPONS := ""
                                        _DTINCLU := dDataBase
                                        _TIPO    := Iif(lExisteSB1, Iif(SZM->ZM_TIPO == SB1->B1_TIPO, SZM->ZM_TIPO, SB1->B1_TIPO), "PA")
                                        _CATALIS := SZM->ZM_CATALIS
                                        _RELCAT  := SZM->ZM_RELCAT
                                        _TIPOPRO := SZM->ZM_TIPOPRO
                                        _SOLICIT := SZM->ZM_SOLICIT
                                        _REVISIN := Inverte(_REVISAO)
                                        _STATUS  := "PP"
                                        _PESESP  := Iif(SZM->ZM_PESESP == 0, 1, SZM->ZM_PESESP)
                                        _LOCAL   := SZM->ZM_LOCAL
                                        _UM      := Iif(lExisteSB1, Iif(SZM->ZM_UM == SB1->B1_UM, SZM->ZM_UM, SB1->B1_UM), Iif( SZM->ZM_FILIAL == "04" .and. LEN(SZM->ZM_CODIGO) == 5 .and. SubStr(SZM->ZM_CODIGO, 1, 2) == "RV", "K ", "UN") )
                                        _ID      := TMPLIB->LIBIDE
                                        _SEQ     := cSeqHis
                                        _ROTEIRO := Iif(lExisteSB1, Iif( Empty( SZM->ZM_ROTEIRO ), SB1->B1_OPERPAD, SZM->ZM_ROTEIRO ), "  " )
                                        _PADCOR  := SZM->ZM_PADCOR
                                        _PCREVIS := SZM->ZM_PCREVIS
                                        _PREVENT := SZM->ZM_DTPREVI
                                        _GRUPO2  := SZM->ZM_GRUPO2
                                     Else
                                        _CODIGO  := Iif( cNumEmp = "01010104" .and. LEN(Alltrim(TMPLIB->LIBPRO)) == 5 .and. SubStr(TMPLIB->LIBPRO, 1, 2) == "RV", ALLTRIM( TMPLIB->LIBPRO )+SZP->ZP_EMB, Alltrim( SubStr( TMPLIB->LIBPRO, 1, 10) )+SZP->ZP_EMB )
                                        _REVISAO := "001"
                                        _DESCRIC := TMPLIB->LIBDES
                                        _RESPONS := ""
                                        _DTINCLU := dDataBase
                                        _TIPO    := "PA"
                                        _CATALIS := ""
                                        _RELCAT  := ""
                                        _TIPOPRO := "PN"
                                        _SOLICIT := Posicione("SZM", 1, xFilial("SZM")+TMPLIB->LIBPRO, "ZM_SOLICIT")
                                        _REVISIN := Inverte(_REVISAO)
                                        _STATUS  := "PP"
                                        _PESESP  := 1
                                        _LOCAL   := "03"
                                        _UM      := Iif( SZM->ZM_FILIAL == "04" .and. LEN(TMPLIB->LIBPRO) == 5 .and. SubStr(TMPLIB->LIBPRO, 1, 2) == "RV", "K ", "UN")
                                        _ID      := TMPLIB->LIBIDE
                                        _SEQ     := cSeqHis
                                        _ROTEIRO := Iif(lExisteSB1, Iif( Empty( Posicione("SZM", 1, xFilial("SZM")+TMPLIB->LIBPRO, "ZM_ROTEIRO") ), SB1->B1_OPERPAD, Posicione("SZM", 1, xFilial("SZM")+TMPLIB->LIBPRO, "ZM_ROTEIRO") ), "  " )
                                        _PADCOR  := ""
                                        _PCREVIS := ""
                                        _PREVENT := Posicione("SZM", 1, xFilial("SZM")+TMPLIB->LIBPRO, "ZM_DTPREVI")
                                        _GRUPO2  := Posicione("SZM", 1, xFilial("SZM")+TMPLIB->LIBPRO, "ZM_GRUPO2")
                                     Endif
                                     cMenssag += Alltrim(_CODIGO)+" / "+_REVISAO+"  -  "+Alltrim(TMPLIB->LIBDES)+Chr(10)+Chr(13)
                                     DbSelectArea("SZM")
                                     RecLock("SZM", .t.)
                                        SZM->ZM_FILIAL := xFilial("SZM")
                                        SZM->ZM_CODIGO  := _CODIGO
                                        SZM->ZM_REVISAO := _REVISAO
                                        SZM->ZM_DESCRIC := _DESCRIC
                                        SZM->ZM_RESPONS := _RESPONS
                                        SZM->ZM_DTINCLU := _DTINCLU
                                        SZM->ZM_TIPO    := _TIPO
                                        SZM->ZM_CATALIS := _CATALIS
                                        SZM->ZM_RELCAT  := _RELCAT
                                        SZM->ZM_TIPOPRO := _TIPOPRO
                                        SZM->ZM_SOLICIT := _SOLICIT
                                        SZM->ZM_REVISIN := _REVISIN
                                        SZM->ZM_STATUS  := _STATUS
                                        SZM->ZM_PESESP  := _PESESP
                                        SZM->ZM_LOCAL   := _LOCAL
                                        SZM->ZM_UM      := _UM
                                        SZM->ZM_ID      := _ID
                                        SZM->ZM_SEQ     := _SEQ
                                        SZM->ZM_ROTEIRO := _ROTEIRO
                                        SZM->ZM_PADCOR  := _PADCOR
                                        SZM->ZM_PCREVIS := _PCREVIS
                                        SZM->ZM_DTPREVI := _PREVENT
                                        SZM->ZM_GRUPO2  := _GRUPO2
                                     MsUnLock()
                                     //Gravar SZN gerando a revisão para a ultima revisão + 1 disponível.
                                     If lExisteSG1
                                        DbSelectArea("SG1")
                                        DbSetOrder(1)
                                        DbSeek(xFilial("SG1")+_CODIGO, .t.)
                                        If Found()
                                           While !Eof() .and. Alltrim(SG1->G1_COD) == Alltrim(_CODIGO)
                                                 RecLock("SZN", .t.)
                                                    SZN->ZN_FILIAL  := xFilial("SG1")
                                                    SZN->ZN_CODIGO  := _CODIGO
                                                    SZN->ZN_REVISAO := _REVISAO
                                                    SZN->ZN_COMP    := SG1->G1_COMP
                                                    SZN->ZN_TRT     := SG1->G1_TRT
                                                    SZN->ZN_PERC    := SG1->G1_PERC
                                                    SZN->ZN_QUANT   := SG1->G1_QUANT
                                                    SZN->ZN_PERDA   := SG1->G1_PERDA            
                                                    SZN->ZN_PESESP  := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_PESOESP")
                                                    SZN->ZN_INI     := SG1->G1_INI
                                                    SZN->ZN_FIM     := SG1->G1_FIM
                                                    SZN->ZN_FIXVAR  := "V"
                                                    SZN->ZN_REVINI  := ""
                                                    SZN->ZN_REVFIM  := "ZZZ"
                                                    SZN->ZN_OPERACA := ""
                                                 DbSelectArea("SG1")
                                                 DbSkip()
                                           Enddo
                                        Else
                                           DbSelectArea("SZN")
                                           DbSetOrder(2)
                                           DbSeek(xFilial("SZN")+_CODIGO+_REVISAO, .t.)
                                           If Found()
                                              aGravaItens := {}
                                              While !Eof() .and. SZN->ZN_CODIGO == _CODIGO .and. SZN->ZN_REVISAO == _REVISAO
                                                    aAdd(aGravaItens, { SZN->ZN_FILIAL , SZN->ZN_CODIGO , _REVISAO, SZN->ZN_COMP   , SZN->ZN_TRT    , SZN->ZN_PERC   , SZN->ZN_QUANT  , SZN->ZN_PERDA  , SZN->ZN_PESESP , SZN->ZN_INI    , SZN->ZN_FIM    , SZN->ZN_FIXVAR , SZN->ZN_REVINI , SZN->ZN_REVFIM , SZN->ZN_OPERACA } )
                                                    DbSelectArea("SZN")
                                                    DbSkip()
                                              Enddo
                                              For nY := 1 To Len(aGravaItens)
                                                  RecLock("SZN", .t.)
                                                     SZN->ZN_FILIAL  := aGravaItens[nY][01]
                                                     SZN->ZN_CODIGO  := aGravaItens[nY][02]
                                                     SZN->ZN_REVISAO := aGravaItens[nY][03]
                                                     SZN->ZN_COMP    := aGravaItens[nY][04]
                                                     SZN->ZN_TRT     := aGravaItens[nY][05]
                                                     SZN->ZN_PERC    := aGravaItens[nY][06]
                                                     SZN->ZN_QUANT   := aGravaItens[nY][07]
                                                     SZN->ZN_PERDA   := aGravaItens[nY][08]
                                                     SZN->ZN_PESESP  := aGravaItens[nY][09]
                                                     SZN->ZN_INI     := aGravaItens[nY][10]
                                                     SZN->ZN_FIM     := aGravaItens[nY][11]
                                                     SZN->ZN_FIXVAR  := aGravaItens[nY][12]
                                                     SZN->ZN_REVINI  := aGravaItens[nY][13]
                                                     SZN->ZN_REVFIM  := aGravaItens[nY][14]
                                                     SZN->ZN_OPERACA := aGravaItens[nY][15]
                                                  MsUnLock()
                                              Next
                                           Else
                                              RecLock("SZN", .t.)
                                                 SZN->ZN_FILIAL  := xFilial("SG1")
                                                 SZN->ZN_CODIGO  := _CODIGO
                                                 SZN->ZN_REVISAO := "001"
                                                 SZN->ZN_COMP    := TMPLIB->LIBPRO
                                                 SZN->ZN_TRT     := "001"
                                                 SZN->ZN_PERC    := Posicione("SZ5", 1, xFilial("SZ5")+SZP->ZP_EMB, "Z5_VOLUME")
                                                 SZN->ZN_QUANT   := Posicione("SZ5", 1, xFilial("SZ5")+SZP->ZP_EMB, "Z5_VOLUME")
                                                 SZN->ZN_PERDA   := 0
                                                 SZN->ZN_PESESP  := Iif(lExisteSB1, Posicione("SB1", 1, xFilial("SB1")+TMPLIB->LIBPRO, "B1_PESOESP"), 0)
                                                 SZN->ZN_INI     := dDataBase
                                                 SZN->ZN_FIM     := CTOD("31/12/2049")
                                                 SZN->ZN_FIXVAR  := "V"
                                                 SZN->ZN_REVINI  := ""
                                                 SZN->ZN_REVFIM  := "ZZZ"
                                                 SZN->ZN_OPERACA := ""
                                              MsUnLock()
                                           Endif
                                        Endif
                                     Else
                                        DbSelectArea("SZN")
                                        DbSetOrder(2)
                                        DbSeek(xFilial("SZN")+_CODIGO+_REVISAO, .t.)
                                        If Found()
                                           aGravaItens := {}
                                           While !Eof() .and. SZN->ZN_CODIGO == _CODIGO .and. SZN->ZN_REVISAO == _REVISAO
                                                 aAdd(aGravaItens, { SZN->ZN_FILIAL , SZN->ZN_CODIGO , _REVISAO, SZN->ZN_COMP   , SZN->ZN_TRT    , SZN->ZN_PERC   , SZN->ZN_QUANT  , SZN->ZN_PERDA  , SZN->ZN_PESESP , SZN->ZN_INI    , SZN->ZN_FIM    , SZN->ZN_FIXVAR , SZN->ZN_REVINI , SZN->ZN_REVFIM , SZN->ZN_OPERACA } )
                                                 DbSelectArea("SZN")
                                                 DbSkip()
                                           Enddo
                                           For nY := 1 To Len(aGravaItens)
                                               RecLock("SZN", .t.)
                                                  SZN->ZN_FILIAL  := aGravaItens[nY][01]
                                                  SZN->ZN_CODIGO  := aGravaItens[nY][02]
                                                  SZN->ZN_REVISAO := aGravaItens[nY][03]
                                                  SZN->ZN_COMP    := aGravaItens[nY][04]
                                                  SZN->ZN_TRT     := aGravaItens[nY][05]
                                                  SZN->ZN_PERC    := aGravaItens[nY][06]
                                                  SZN->ZN_QUANT   := aGravaItens[nY][07]
                                                  SZN->ZN_PERDA   := aGravaItens[nY][08]
                                                  SZN->ZN_PESESP  := aGravaItens[nY][09]
                                                  SZN->ZN_INI     := aGravaItens[nY][10]
                                                  SZN->ZN_FIM     := aGravaItens[nY][11]
                                                  SZN->ZN_FIXVAR  := aGravaItens[nY][12]
                                                  SZN->ZN_REVINI  := aGravaItens[nY][13]
                                                  SZN->ZN_REVFIM  := aGravaItens[nY][14]
                                                  SZN->ZN_OPERACA := aGravaItens[nY][15]
                                               MsUnLock()
                                           Next
                                        Else
                                           RecLock("SZN", .t.)
                                              SZN->ZN_FILIAL  := xFilial("SG1")
                                              SZN->ZN_CODIGO  := _CODIGO
                                              SZN->ZN_REVISAO := "001"
                                              SZN->ZN_COMP    := TMPLIB->LIBPRO
                                              SZN->ZN_TRT     := "001"
                                              SZN->ZN_PERC    := 0
                                              SZN->ZN_QUANT   := Posicione("SZ5", 1, xFilial("SZ5")+SZP->ZP_EMB, "Z5_VOLUME")
                                              SZN->ZN_PERDA   := 0
                                              SZN->ZN_PESESP  := Iif(lExisteSB1, Posicione("SB1", 1, xFilial("SB1")+TMPLIB->LIBPRO, "B1_PESOESP"), 0)
                                              SZN->ZN_INI     := dDataBase
                                              SZN->ZN_FIM     := CTOD("31/12/2049")
                                              SZN->ZN_FIXVAR  := "V"
                                              SZN->ZN_REVINI  := ""
                                              SZN->ZN_REVFIM  := "ZZZ"
                                              SZN->ZN_OPERACA := ""
                                           MsUnLock()
                                        Endif
                                     Endif
                                     //Gravar Histórico (SZT)
                                     DbSelectArea("SZT")
                                     RecLock("SZT", .t.)
                                        SZT->ZT_FILIAL  := xFilial("SZT")
                                        SZT->ZT_ID      := TMPLIB->LIBIDE
                                        SZT->ZT_PROCESS := "SI"
                                        SZT->ZT_STATUS  := "PP"
                                        SZT->ZT_LOG     := "Envio de fórmula "+Alltrim(SZM->ZM_CODIGO)+" / "+SZM->ZM_REVISAO+"  -  "+Alltrim(SZM->ZM_DESCRIC)+" para o PCP."
                                        SZT->ZT_USUARIO := cUserName
                                        SZT->ZT_DATAGER := dDataBase
                                        SZT->ZT_HORAGER := Time()
                                        SZT->ZT_SEQ     := cSeqHis
                                     MsUnLock()
                                     DbSelectArea("SZP")
                                     DbSkip()
                               Enddo
                               //Enviar mensagem para o responsável PCP para ajustar a fórmula e liberar as mesmas
                               //Verificar Usuários para envio de mensagem
                               cUserList := ""
                               DbSelectArea("SZW")
                               DbSetOrder(4)
                               DbSeek(xFilial("SZW")+cRotUsu, .t.)
                               If Found()
                                  While !Eof() .and. Alltrim(SZW->ZW_ROTINA) == Alltrim(cRotUsu)
                                        If u_fVerAcsUsr(cRotUsu, 4, SZW->ZW_USUARIO) .and. u_fVerAcsUsr(cRotUsu, 7, SZW->ZW_USUARIO)
                                           If Empty(cUserList)
                                              cUserList += Alltrim( UsrRetName( SZW->ZW_USUARIO ) )
                                           Else
                                              cUserList += ";"+Alltrim( UsrRetName( SZW->ZW_USUARIO ) )
                                           Endif
                                        Endif
                                        DbSelectArea("SZW")
                                        DbSkip()
                                  Enddo
                               Endif
                            Else
                               cMenssag += " PARA ANÁLISE DA DIRETORIA"+Chr(10)+Chr(13)
                               //Verificar se o tipo do produto é PA com 5 digitos ou com 12 digitos
                               If TMPLIB->LIBTIP $ 'PA' .and. ( LEN(TMPLIB->LIBPRO) == 12 .or. (SubStr(TMPLIB->LIBPRO, 1, 2) $ 'RV' .and. LEN(TMPLIB->LIBPRO) == 5) )
                                  //Mudar status para PCP
                                  RecLock("SZM", .f.)
                                     SZM->ZM_STATUS := "PP"
                                  MsUnLock()
                               Else
                                  //Mudar status para diretoria
                                    RecLock("SZM", .f.)
                                       SZM->ZM_STATUS := "EA"
                                    MsUnLock()
                               Endif
                            Endif
                         Else
                            MsgStop("Produto não encontrado, verifique!", "Verifique...")
                            //Return //LGS#20200207 - Adequação de release 12.1.25 e posteriores
                         Endif
                      ElseIf TMPLIB->LIBSTA $ 'PP' //PCP
                             cMenssag := "ENVIO DE FÓRMULAS "
                             cSubject := "ANÁLISE DE FÓRMULA - DIRETORIA"
                             //Mudar status
                             DbSelectArea("SZM")
                             DbSetOrder(4)
                             DbSeek(xFilial("SZM")+TMPLIB->LIBIDE, .t.)
                             If Found()
                                While !Eof() .and. SZM->ZM_ID == TMPLIB->LIBIDE
                                      //Mudar status para DIRETORIA
                                      RecLock("SZM", .f.)
                                         SZM->ZM_STATUS := "EA"
                                      MsUnLock()
                                      RecLock("TMPLIB", .f.)
                                         TMPLIB->LIBLIB := "S"
                                      MsUnLock()
                                      //Gravar Histórico (SZT)
                                      cSeqHis := "301"
                                      DbSelectArea("SZT")
                                      RecLock("SZT", .t.)
                                         SZT->ZT_FILIAL  := xFilial("SZT")
                                         SZT->ZT_ID      := TMPLIB->LIBIDE
                                         SZT->ZT_PROCESS := "SI"
                                         SZT->ZT_STATUS  := "EA"
                                         SZT->ZT_LOG     := "Envio de fórmula "+Alltrim(TMPLIB->LIBPRO)+" / "+TMPLIB->LIBREV+"  -  "+Alltrim(TMPLIB->LIBDES)+" para a Diretoria."
                                         SZT->ZT_USUARIO := cUserName
                                         SZT->ZT_DATAGER := dDataBase
                                         SZT->ZT_HORAGER := Time()
                                         SZT->ZT_SEQ     := cSeqHis
                                      MsUnLock()
                                      DbSelectArea("SZM")
                                      DbSkip()
                                EndDo
                             Endif
                             //Enviar mensagem para o responsável PCP para ajustar a fórmula e liberar as mesmas
                             //Verificar Usuários para envio de mensagem
                             cUserList := ""
                             DbSelectArea("SZW")
                             DbSetOrder(4)
                             DbSeek(xFilial("SZW")+cRotUsu, .t.)
                             If Found()
                                While !Eof() .and. Alltrim(SZW->ZW_ROTINA) == Alltrim(cRotUsu)
                                      If u_fVerAcsUsr(cRotUsu, 4, SZW->ZW_USUARIO) .and. u_fVerAcsUsr(cRotUsu, 7, SZW->ZW_USUARIO)
                                         If Empty(cUserList)
                                            cUserList += Alltrim( UsrRetName( SZW->ZW_USUARIO ) )
                                         Else
                                            cUserList += ";"+Alltrim( UsrRetName( SZW->ZW_USUARIO ) )
                                         Endif
                                      Endif
                                      DbSelectArea("SZW")
                                      DbSkip()
                                Enddo
                             Endif
                      ElseIf TMPLIB->LIBSTA $ 'EA' //Diretoria
                             cMenssag := "BAIXA DE SIMULAÇÃO "
                             cSubject := "PRODUTOS APROVADOS - DIRETORIA"
                             //Mudar status
                             DbSelectArea("SZM")
                             DbSetOrder(4)
                             DbSeek(xFilial("SZM")+TMPLIB->LIBIDE, .t.)
                             If Found()
                                While !Eof() .and. SZM->ZM_ID == TMPLIB->LIBIDE
                                      //Mudar status para APROVADO
                                      RecLock("SZM", .f.)
                                         SZM->ZM_STATUS := "AC"
                                      MsUnLock()
                                      RecLock("TMPLIB", .f.)
                                         TMPLIB->LIBLIB := "S"
                                      MsUnLock()
                                      //Gravar Histórico (SZT)
                                      cSeqHis := "301"  // VERIFICAR QUAL É A SEQUENCIA
                                      DbSelectArea("SZT")
                                      RecLock("SZT", .t.)
                                         SZT->ZT_FILIAL  := xFilial("SZT")
                                         SZT->ZT_ID      := TMPLIB->LIBIDE
                                         SZT->ZT_PROCESS := "SI"
                                         SZT->ZT_STATUS  := "AC"
                                         SZT->ZT_LOG     := "Baixa de Pendência "+Alltrim(TMPLIB->LIBPRO)+" / "+TMPLIB->LIBREV+"  -  "+Alltrim(TMPLIB->LIBDES)+" da Diretoria."
                                         SZT->ZT_USUARIO := cUserName
                                         SZT->ZT_DATAGER := dDataBase
                                         SZT->ZT_HORAGER := Time()
                                         SZT->ZT_SEQ     := cSeqHis
                                      MsUnLock()
                                      DbSelectArea("SZM")
                                      DbSkip()
                                EndDo
                             Endif
                             //Verificar Usuários para envio de mensagem
                             cUserList := ""
                             DbSelectArea("SZW")
                             DbSetOrder(4)
                             DbSeek(xFilial("SZW")+cRotUsu, .t.)
                             If Found()
                                While !Eof() .and. Alltrim(SZW->ZW_ROTINA) == Alltrim(cRotUsu)
                                      If u_fVerAcsUsr(cRotUsu, 4, SZW->ZW_USUARIO) .and. u_fVerAcsUsr(cRotUsu, 7, SZW->ZW_USUARIO)
                                         If Empty(cUserList)
                                            cUserList += Alltrim( UsrRetName( SZW->ZW_USUARIO ) )
                                         Else
                                            cUserList += ";"+Alltrim( UsrRetName( SZW->ZW_USUARIO ) )
                                         Endif
                                      Endif
                                      DbSelectArea("SZW")
                                      DbSkip()
                                Enddo
                             Endif

                             //Incluir SG1
                             //Se Produto Novo Incluir no SB1
                             //Senão Atualizar informações no SB1
                             If TMPLIB->LIBSTP $ 'PN' //Se for produto novo
                             
                             Else //Se for produto antigo
                                DbSelectArea("SB1")
                                DbSetOrder(1)
                                DbSeek(xFilial("SB1")+TMPLIB->LIBPRO, .t.)
                                If Found()
                                   RecLock("SB1", .f.)
                                      SB1->B1_DESC   := TMPLIB->LIBDES
                                      SB1->B1_POSIPI := TMPLIB->LIBNCM
                                      SB1->B1_EX_NCM := TMPLIB->LIBEX
                                   MsUnLock()
                                Endif 
                             Endif
                      Endif
                      DbSelectArea("TMPLIB")
                      DbSkip()
                Enddo
          
          
             Else
                MsgStop("Atenção, é necessário marcar os itens para efetuar a liberação!", "Atenção")
                DbSelectArea("TMPLIB")
                DbGoTop()
                //Return //LGS#20200207 - Adequação de release 12.1.25 e posteriores
             Endif
       End Transaction

       cIdentLib := Int2Hex( WFGetNum( "MV_WF6IDEN" ),10 )
       WFMessenger(cUserName, Iif(Empty(cUserList), cUserName, cUserList), cSubject, cMenssag, "0", cIdentLib)

       oDlg1Lib:End()
Return

Static Function fDevolveFormula()
       Local cMenssag := ""
       Local nOpcA    := 0
       Private cMGet1Mo

       SetPrvt("oDlg1Mot", "oMGet1Mo", "oBtn1Mot")
       
       DbSelectArea("TMPLIB")
       DbGoTop()
       If TMPLIB->(Marked("LIBMAR") )
          oDlg1Mot   := MSDialog():New( 091, 232, 260, 560, "Motivo da Devolução", , , .F., , , , , , .T., , , .T. )
          oMGet1Mo   := TMultiGet():New( 004, 004, {|u| If(PCount() > 0, cMGet1Mo := u, cMGet1Mo)}, oDlg1Mot, 156, 060, , , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .F., , , .F., ,  )
          oBtn1Mot   := TButton():New( 068, 122, "Confirma", oDlg1Mot, {|| nOpcA := 1, oDlg1Mot:End() }, 037, 012, , , , .T., , "", , , , .F. )

          oDlg1Mot:Activate(, , , .T.)
          If nOpcA == 0
             MsgStop("Atenção, não pode haver devolução da fórmula sem o motivo.", "Atenção...")
             Return
          Else
             If !Empty(cMGet1Mo)
                DbSelectArea("SZT")
                RecLock("SZT", .t.)
                   cMotDev := "DEVOLUÇÃO DE FÓRMULA"+Chr(10)+Chr(13)
                   cMotDev += cMGet1Mo
                   SZT->ZT_FILIAL  := xFilial("SZT")
                   SZT->ZT_ID      := TMPLIB->LIBIDE
                   SZT->ZT_PROCESS := "SI"
                   SZT->ZT_STATUS  := "MD"
                   SZT->ZT_LOG     := cMotDev
                   SZT->ZT_USUARIO := cUserName
                   SZT->ZT_DATAGER := dDataBase
                   SZT->ZT_HORAGER := Time()
                MsUnLock()
             Else
                MsgStop("Atenção, motivo da devolução não pode ser vazio.", "Verifique...")
                Return
             Endif
          Endif
          If TMPLIB->LIBSTA $ 'PP.EA' //Analise do PCP ou Analise Diretoria
             Begin Transaction
                   cSubject := "RETORNO DE FÓRMULA "+Alltrim(TMPLIB->LIBPRO)+" / "+TMPLIB->LIBREV+"  -  "+Alltrim(TMPLIB->LIBDES)
                   //Voltar Status para 'EE' Analise Química
                   RecLock("TMPLIB", .f.)
                      TMPLIB->LIBLIB := "S"
                   MsUnLock()
                   DbSelectArea("SZM")
                   DbSetOrder(1)
                   DbSeek(xFilial("SZM")+TMPLIB->LIBPRO+TMPLIB->LIBREV, .t.)
                   If Found()
                      cUserList := SZM->ZM_RESPONS
                      RecLock("SZM", .f.)
                         SZM->ZM_STATUS := "EE"
                      MsUnLock()
                   EndIf
                   //Gravar Histórico
                   DbSelectArea("SZT")
                   RecLock("SZT", .t.)
                      SZT->ZT_FILIAL  := xFilial("SZT")
                      SZT->ZT_ID      := TMPLIB->LIBIDE
                      SZT->ZT_PROCESS := "SI"
                      SZT->ZT_STATUS  := "RT"
                      SZT->ZT_LOG     := "Retorno de fórmula "+Alltrim(TMPLIB->LIBPRO)+" / "+TMPLIB->LIBREV+"  -  "+Alltrim(TMPLIB->LIBDES)+" para o responsável "
                      SZT->ZT_USUARIO := cUserName
                      SZT->ZT_DATAGER := dDataBase
                      SZT->ZT_HORAGER := Time()
                   MsUnLock()
                   //Montar texto para mensagem
                   cMenssag += Alltrim(TMPLIB->LIBPRO)+" / "+TMPLIB->LIBREV+"  -  "+Alltrim(TMPLIB->LIBDES)+"   -   RETORNOU."+Chr(10)+Chr(13)
                   //Verificar se existem embalagens - se existir excluir as mesmas.
                   DbSelectArea("TMPLIB")
                   While !Eof()
                         If Empty(TMPLIB->LIBLIB)
                            //Excluir SZM
                            DbSelectArea("SZM")
                            DbSetOrder(1)
                            DbSeek(xFilial("SZM")+TMPLIB->LIBPRO+TMPLIB->LIBREV, .t.)
                            If Found()
                               RecLock("SZM", .f.)
                                  DbDelete()
                               MsUnLock()
                            Endif
                            //Excluir SZN
                            DbSelectArea("SZN")
                            DbSetOrder(2)
                            DbSeek(xFilial("SZN")+TMPLIB->LIBPRO+TMPLIB->LIBREV, .t.)
                            If Found()
                               While !Eof() .and. SZN->ZN_CODIGO == TMPLIB->LIBPRO .and. SZN->ZN_REVISAO == TMPLIB->LIBREV
                                     RecLock("SZN", .f.)
                                        DbDelete()
                                     MsUnLock()
                                     DbSelectArea("SZN")
                                     DbSkip()
                               EndDo
                            Endif
                            //Excluir ZZH
                            DbSelectArea("ZZH")
                            DbSetOrder(2)
                            DbSeek(xFilial("ZZH")+TMPLIB->LIBPRO+TMPLIB->LIBREV, .t.)
                            If Found()
                               While !Eof() .and. ZZH->ZZH_CODIGO == TMPLIB->LIBPRO .and. ZZH->ZZH_REVISAO == TMPLIB->LIBREV
                                     RecLock("ZZH", .f.)
                                        DbDelete()
                                     MsUnLock()
                                     DbSelectArea("ZZH")
                                     DbSkip()
                               EndDo
                            Endif
                            //Gravar log de exclusão
                            DbSelectArea("SZT")
                            RecLock("SZT", .t.)
                               SZT->ZT_FILIAL  := xFilial("SZT")
                               SZT->ZT_ID      := TMPLIB->LIBIDE
                               SZT->ZT_PROCESS := "SI"
                               SZT->ZT_STATUS  := "RT"
                               SZT->ZT_LOG     := "Excluido "+Alltrim(TMPLIB->LIBPRO)+" / "+TMPLIB->LIBREV+"  -  "+Alltrim(TMPLIB->LIBDES)+" pelo retorno de fórmula para o responsável."
                               SZT->ZT_USUARIO := cUserName
                               SZT->ZT_DATAGER := dDataBase
                               SZT->ZT_HORAGER := Time()
                            MsUnLock()
                            //Montar texto para mensagem
                            cMenssag += Alltrim(TMPLIB->LIBPRO)+" / "+TMPLIB->LIBREV+"  -  "+Alltrim(TMPLIB->LIBDES)+"   -   EXCLUIDO."+Chr(10)+Chr(13)
                         Endif
                         DbSelectArea("TMPLIB")
                         DbSkip()
             EndDo
             End Transaction
             //Enviar mensagem ao responsável
             cUserList := ""
             //cIdentDev := Int2Hex( WFGetNum( "MV_WF6IDEN" ),10 )
             //WFMessenger(cUserName, Iif(Empty(cUserList), cUserName, cUserList), cSubject, cMenssag, "0", cIdentDev)
             //Fechar tela
             oDlg1Lib:End()
          Endif
       Else
          MsgStop("Atenção o primeiro produto a ser liberado não está marcado!", "Verifique...")
          //PUTMV("MV_WFMESSE", "F")
          Return
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1Lib() - Cria temporario para o Alias: TMPLIB
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1Lib()
       Local aFds  := {}
       //Local cTmp
       Local aArea := {}
       Local lResp := .f. //Variável que indica se existe(m) algum(ns) item(ns) sem responsável(is)

       aAdd( aFds, {"LIBMAR", "C", 002, 000} )
       aAdd( aFds, {"LIBPRO", "C", 015, 000} )
       aAdd( aFds, {"LIBDES", "C", 030, 000} )
       aAdd( aFds, {"LIBREV", "C", 003, 000} )
       aAdd( aFds, {"LIBRES", "C", 015, 000} )
       aAdd( aFds, {"LIBTIP", "C", 002, 000} )
       aAdd( aFds, {"LIBUNM", "C", 002, 000} )
       aAdd( aFds, {"LIBSTA", "C", 002, 000} )
       aAdd( aFds, {"LIBSTP", "C", 002, 000} )
       aAdd( aFds, {"LIBLIB", "C", 001, 000} )
       aAdd( aFds, {"LIBIDE", "C", 006, 000} )
       aAdd( aFds, {"LIBNCM", "C", 010, 000} )
       aAdd( aFds, {"LIBEX",  "C", 003, 000} )

/*
       cTmp := CriaTrab( , .F. )
       dbcreate(cTmp+".dbf", aFds, "DBFCDXADS")
       Use (cTmp+".Dbf") Alias TMPLIB VIA "DBFCDXADS" New Exclusive
       DbCreateIndex(cTmp+"_1.cdx", "LIBPRO", {||"LIBPRO"} )

       DbClearInd()
       DbSetIndex(cTmp+"_1")
       DbSetOrder(1)
       */
       
        oTmpLib := FWTemporaryTable():New( "TMPLIB" )
        oTmpLib:SetFields( aFds )
        oTmpLib:AddIndex( "cLIBPRO", { "LIBPRO" } )
        oTmpLib:Create()
        DbSelectArea( "TMPLIB" )
        DbSetOrder(1)
       
       
       DbSelectArea("SZM")
       aArea := GetArea()
       DbSetOrder(5)
       DbSeek(xFilial("SZM")+cIdProce, .t.)
       If Found()
          While !Eof() .and. SZM->ZM_ID == cIdProce .and. !SZM->ZM_STATUS $ 'RT.RE.RX.AC'
                RecLock("TMPLIB", .t.)
                   TMPLIB->LIBMAR := "  "
                   TMPLIB->LIBPRO := SZM->ZM_CODIGO
                   TMPLIB->LIBDES := SZM->ZM_DESCRIC
                   TMPLIB->LIBREV := SZM->ZM_REVISAO
                   TMPLIB->LIBRES := SZM->ZM_RESPONS
                   TMPLIB->LIBTIP := SZM->ZM_TIPO
                   TMPLIB->LIBUNM := SZM->ZM_UM
                   TMPLIB->LIBSTA := SZM->ZM_STATUS
                   TMPLIB->LIBSTP := SZM->ZM_TIPOPRO
                   TMPLIB->LIBIDE := SZM->ZM_ID
                   TMPLIB->LIBNCM := SZM->ZM_POSIPI
                   TMPLIB->LIBEX  := SZM->ZM_EX_NCM
                   If Empty(SZM->ZM_RESPONS)
                      lResp := .t.
                   Endif
                MsUnLock()
                DbSelectArea("SZM")
                DbSkip()
          EndDo
       Endif
       DbSelectArea(aArea[1])
       DbSetOrder(aArea[2])
       DbGoTo(aArea[3])
       DbSelectArea("TMPLIB")
       DbGoTop()
Return(lResp)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl2Lib() - Cria temporario para o Alias: TMPHIS
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl2Lib()
       Local aFds := {}
       //Local cTmp

       aAdd( aFds , {"HISSTA", "C", 020, 000} ) //Status
       aAdd( aFds , {"HISGER", "C", 018, 000} ) //Geração
       aAdd( aFds , {"HISSEQ", "C", 003, 000} ) //Sequência
       aAdd( aFds , {"HISUSU", "C", 030, 000} ) //Usuário
       aAdd( aFds , {"HISLOG", "M", 010, 000} ) //Usuário
       aAdd( aFds , {"HISIND", "C", 018, 000} ) //INDICE
       aAdd( aFds , {"HISINV", "C", 018, 000} ) //INDICE INVERTIDO


        oTmpHis := FWTemporaryTable():New( "TMPHIS" )
        oTmpHis:SetFields( aFds )
        oTmpHis:AddIndex( "cHISINV", { "HISINV" } )
        oTmpHis:Create()
        DbSelectArea( "TMPHIS" )
        DbSetOrder(1)

/*
       cTmp := CriaTrab( , .F. )
       dbcreate(cTmp+".dbf", aFds, "DBFCDXADS")
       Use (cTmp+".Dbf") Alias TMPHIS VIA "DBFCDXADS" New Exclusive
       DbCreateIndex(cTmp+"_1.cdx", "HISINV", {||"HISINV"} )       

       DbClearInd()
       DbSetIndex(cTmp+"_1")
       DbSetOrder(1)
*/
       DbSelectArea("SZT")
       DbSetOrder(1)
       DbSeek(xFilial("SZT")+cIdProce, .t.)
       If Found()
          While !Eof() .and. SZT->ZT_ID == cIdProce
                RecLock("TMPHIS", .t.)
                   TMPHIS->HISSTA := Iif(SZT->ZT_STATUS $ "EE", "Produto em simulação.", Iif(SZT->ZT_STATUS $ "PP", "Produto no PCP", Iif(SZT->ZT_STATUS $ "AC", "Baixa Pend. Diretoria" ,Iif(SZT->ZT_STATUS $ "MD", "Motivo de Devolução", Iif(SZT->ZT_STATUS $ "OD", "Observação Diretoria.", Iif(SZT->ZT_STATUS $ "RT", "Retorno de formulação.", Iif(SZT->ZT_STATUS $ "EA", "Produto na Diretoria.", "." ) ) ) ) ) ) )
                   TMPHIS->HISGER := DTOC(SZT->ZT_DATAGER)+" - "+SZT->ZT_HORAGER
                   TMPHIS->HISIND := DTOS(SZT->ZT_DATAGER)+" - "+SZT->ZT_HORAGER
                   TMPHIS->HISINV := INVERTE( TMPHIS->HISIND ) //Indice decrescente
                   TMPHIS->HISSEQ := SZT->ZT_SEQ
                   PswOrder(2)
                   If PswSeek(SZT->ZT_USUARIO, .t.)
                      TMPHIS->HISUSU := Alltrim(PSWRET()[1][4])
                   Else
                      TMPHIS->HISUSU := Alltrim(SZT->ZT_USUARIO)
                   Endif
                   TMPHIS->HISLOG  := SZT->ZT_LOG
                MsUnLock()
                DbSelectArea("SZT")
                DbSkip()
          EndDo
       Endif
       DbSelectArea("TMPHIS")
       DbGoTop()
       cMGet1Li := "*** "+Alltrim(TMPHIS->HISUSU)+" ***" + Chr(13)+Chr(10) + TMPHIS->HISLOG
Return

Static Function fTrocaHist()
       cMGet1Li := "*** "+Alltrim(TMPHIS->HISUSU)+" ***" + Chr(13)+Chr(10) + TMPHIS->HISLOG
       oMGet1Li:Refresh()
Return
             
/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl3Lib() - Cria temporario para o Alias: TMPVIG
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl3Lib(nOpcVig)
       Local aFds := {}
       //Local cTmp
       If nOpcVig == 1
          aAdd( aFds , {"VIGCOM", "C", 015, 000} ) //Componente
          aAdd( aFds , {"VIGDES", "C", 030, 000} ) //Descrição
          aAdd( aFds , {"VIGTRT", "C", 003, 000} ) //Sequencia
          aAdd( aFds , {"VIGPER", "N", 007, 003} ) //Percentual
          aAdd( aFds , {"VIGQTD", "N", 010, 006} ) //Quantidade
          aAdd( aFds , {"VIGPRD", "N", 005, 002} ) //Perda
          aAdd( aFds , {"VIGPES", "N", 009, 006} ) //Peso específico
          aAdd( aFds , {"VIGCUN", "N", 007, 003} ) //Custo Unitário
          aAdd( aFds , {"VIGCRE", "N", 007, 003} ) //Custo Reais
          aAdd( aFds , {"VIGCDO", "N", 007, 003} ) //Custo Dolar

          /*
          cTmp := CriaTrab( , .F. )
          dbcreate(cTmp+".dbf", aFds, "DBFCDXADS")
          Use (cTmp+".Dbf") Alias TMPVIG VIA "DBFCDXADS" New Exclusive
          DbCreateIndex(cTmp+"_1.cdx", "VIGTRT+VIGCOM", {||"VIGTRT+VIGCOM"} )

          DbClearInd()
          DbSetIndex(cTmp+"_1")
          DbSetOrder(1)
          */
          
          oTmpVig := FWTemporaryTable():New( "TMPVIG" )
          oTmpVig:SetFields( aFds )
          oTmpVig:AddIndex( "cTrt", { "VIGTRT","VIGCOM" } )
          oTmpVig:Create()
          DbSelectArea( "TMPVIG" )
          DbSetOrder(1)
          
          
       Else
          DbSelectArea("TMPVIG")
          //LGS#20200211 - Adequação de release 12.1.25 e posteriores
          //ZAP
          TCSqlExec("DELETE FROM " + oTmpVig:GetRealName() )
       Endif
       cGet1Lib   := TMPLIB->LIBPRO
       cGet2Lib   := TMPLIB->LIBDES
       cGet3Lib   := TMPLIB->LIBTIP
       cGet5Lib   := Iif(TMPLIB->LIBSTP $ 'PN', 'NOVO', 'EXISTENTE')
       //SG1
       nGet1Lib := 0
       nGet2Lib := 0
       nGet5Lib := 0
       nGet6Lib := 0
       nGet7Lib := 0
       DbSelectArea("SG1")
       DbSetOrder(1)
       DbSeek(xFilial("SG1")+TMPLIB->LIBPRO, .t.)
       If Found()
          While !Eof() .and. SG1->G1_COD == TMPLIB->LIBPRO
                RecLock("TMPVIG", .t.)
                   TMPVIG->VIGCOM := SG1->G1_COMP
                   TMPVIG->VIGDES := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_DESC")
                   TMPVIG->VIGTRT := SG1->G1_TRT
                   TMPVIG->VIGPER := SG1->G1_PERC
                   TMPVIG->VIGQTD := SG1->G1_QUANT
                   TMPVIG->VIGPRD := SG1->G1_PERDA
                   TMPVIG->VIGPES := Posicione("SB1", 1, xFilial("SB1")+SG1->G1_COMP, "B1_PESOESP")
                   TMPVIG->VIGCUN := Iif( Posicione("SB1", 1, xFilial('SB1')+SG1->G1_COMP, "B1_TIPO") $ 'MP', Posicione("SB1", 1, xFilial('SB1')+SG1->G1_COMP, "B1_UPRC"), U_CustoPro(SG1->G1_COMP) )
                   TMPVIG->VIGCRE := ( TMPVIG->VIGCUN * ( ( TMPVIG->VIGQTD * ( TMPVIG->VIGPRD / 100 ) ) + TMPVIG->VIGQTD ) )
                   TMPVIG->VIGCDO := (                  ( ( TMPVIG->VIGQTD * ( TMPVIG->VIGPRD / 100 ) ) + TMPVIG->VIGQTD ) ) / nDolarDia
                MsUnLock()
                nGet1Lib += Iif(TMPLIB->LIBTIP $ 'PA' .and. !TMPLIB->LIBUNM $ 'K .L ', 0, SG1->G1_PERC )
                nGet2Lib += Iif(TMPLIB->LIBTIP $ 'PA' .and. !TMPLIB->LIBUNM $ 'K .L ', 0, Round( (TMPVIG->VIGPER / TMPVIG->VIGPES), 6 ) )
                nGet5Lib += Round( TMPVIG->VIGCRE, 3 )
                nGet6Lib += Round( TMPVIG->VIGCDO, 3 )
                DbSelectArea("SG1")
                DbSkip()
          Enddo
          nGet2Lib := Iif(TMPLIB->LIBTIP $ 'PA' .and. !TMPLIB->LIBUNM $ 'K .L ', 1, nGet2Lib := 100 / nGet2Lib )
          If !(cNumEmp == "01010104")
             If TMPLIB->LIBTIP $ 'PI'
                If 'K' $ TMPLIB->LIBUNM
                   //%Fórmula
                   oSay3Lib:Refresh()
                   oGet1Lib:Refresh()
                   //P.Especifico
                   oSay4Lib:Refresh()
                   oGet2Lib:Refresh()
                   //Custo(R$/K)
                   cSay7Lib := "Custo(R$/K):"
                   oSay7Lib:Refresh()
                   oGet5Lib:Refresh()
                   //Custo(U$/K)
                   cSay8Lib := "Custo(U$/K):"
                   oSay8Lib:Refresh()
                   oGet6Lib:Refresh()
                   //
                   oSayBLib:lVisible := .f.
                   oGet7Lib:lVisible := .f.
                   //Imagem (Comparação do Custo(R$/K))
                ElseIf 'L' $ TMPLIB->LIBUNM
                       //%Fórmula
                       oSay3Lib:Refresh()
                       oGet1Lib:Refresh()
                       //P.Especifico
                       oSay4Lib:Refresh()
                       oGet2Lib:Refresh()
                       //Custo(R$/L)
                       cSay7Lib := "Custo(R$/L):"
                       oSay7Lib:Refresh()
                       oGet5Lib:Refresh()
                       //Custo(U$/K)
                       cSay8Lib := "Custo(U$/K):"
                       oSay8Lib:Refresh()
                       oGet6Lib:Refresh()
                       //Custo(R$/K)
                       oSayBLib:lVisible := .t.
                       cSayBLib := "Custo(R$/K):"
                       oSayBLib:Refresh()
                       oGet7Lib:lVisible := .t.
                       nGet7Lib := Round( ( 1 / nGet2Lib ) * nGet5Lib, 3 )
                       oGet7Lib:Refresh()
                       //Imagem (Comparação do Custo(R$/L))
                Endif
             ElseIf TMPLIB->LIBTIP $ 'PA'
                    //%Fórmula
                    oSay3Lib:Refresh()
                    nGet1Lib := 0
                    oGet1Lib:Refresh()
                    //P.Especifico
                    oSay4Lib:Refresh()
                    nGet2Lib := 0
                    oGet2Lib:Refresh()
                    //Custo(R$/L)
                    cSay7Lib := "Custo(R$/L):"
                    oSay7Lib:Refresh()
                    oGet5Lib:Refresh()
                    //Custo(U$/K)
                    cSay8Lib := "Custo(U$/K):"
                    oSay8Lib:Refresh()
                    oGet6Lib:Refresh()
                    //Preço(R$/K)
                    oSayBLib:lVisible := .t.
                    cSayBLib := "Preço:"
                    oSayBLib:Refresh()
                    aPreco := fCalculaPr(nGet5Lib, "VIG", "M")
                    nGet7Lib := aPreco[1]
                    oGet7Lib:lVisible := .t.
                    //Imagem (Comparação do Custo(R$/L))
             Endif
 
          Else
          If 'K' $ TMPLIB->LIBUNM
             cSay7Lib := "Custo(R$/K):"
             oSay7Lib:Refresh()
             If TMPLIB->LIBTIP $ 'PA'
                cSayBLib := "Preço:"
                oSayBLib:lVisible := .t.
                aPreco := fCalculaPr(nGet5Lib, "VIG", "L")
                nGet7Lib := aPreco[1]
                oGet7Lib:lVisible := .t.
             Endif
          Else
             nGet7Lib := Round( ( 1 / nGet2Lib ) * nGet5Lib, 3 )
          Endif
          Endif
       Endif
       DbSelectArea("TMPVIG")
       DbGoTop()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl4Lib() - Cria temporario para o Alias: TMPVIG
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl4Lib(nOpcRev)
       Local aFds := {}
       //Local cTmp
       If nOpcRev == 1
          aAdd( aFds , {"REVCOM", "C", 015, 000} ) //Componente
          aAdd( aFds , {"REVDES", "C", 030, 000} ) //Descrição
          aAdd( aFds , {"REVTRT", "C", 003, 000} ) //Sequencia
          aAdd( aFds , {"REVPER", "N", 007, 003} ) //Percentual
          aAdd( aFds , {"REVQTD", "N", 010, 006} ) //Quantidade
          aAdd( aFds , {"REVPRD", "N", 005, 002} ) //Perda
          aAdd( aFds , {"REVPES", "N", 009, 006} ) //Peso específico
          aAdd( aFds , {"REVCUN", "N", 007, 003} ) //Custo Unitário
          aAdd( aFds , {"REVCRE", "N", 007, 003} ) //Custo Reais
          aAdd( aFds , {"REVCDO", "N", 007, 003} ) //Custo Dolar

          /*
          cTmp := CriaTrab( , .F. )
          dbcreate(cTmp+".dbf", aFds, "DBFCDXADS")
          Use (cTmp+".Dbf") Alias TMPREV VIA "DBFCDXADS" New Exclusive
          DbCreateIndex(cTmp+"_1.cdx", "REVTRT+REVCOM", {||"REVTRT+REVCOM"} )
          DbClearInd()
          DbSetIndex(cTmp+"_1")
          DbSetOrder(1)
          */
          
          oTmpRev := FWTemporaryTable():New( "TMPREV" )
          oTmpRev:SetFields( aFds )
          oTmpRev:AddIndex( "cTrt", { "REVTRT","REVCOM" } )
          oTmpRev:Create()
          DbSelectArea( "TMPREV" )
          DbSetOrder(1)
          
       Else
          //LGS#20200211 - Adequação de release 12.1.25 e posteriores
          DbSelectArea("TMPREV")
          //Zap
          TCSqlExec("DELETE FROM " + oTmpRev:GetRealName() )
       Endif
       //Buscar SZN
       nGet3Lib := 0
       nGet4Lib := 0
       nGet9Lib := 0
       nGetALib := 0
       nGetDLib := 0
       DbSelectArea("SZN")
       DbSetOrder(2)
       DbSeek(xFilial("SZN")+TMPLIB->LIBPRO+TMPLIB->LIBREV, .t.)
       If Found()
          While !Eof() .and. SZN->ZN_CODIGO == TMPLIB->LIBPRO .AND. SZN->ZN_REVISAO == TMPLIB->LIBREV
                RecLock("TMPREV", .t.)
                   TMPREV->REVCOM := SZN->ZN_COMP
                   TMPREV->REVDES := Iif(LEN(ALLTRIM(SZN->ZN_COMP)) == 12 .AND. SZN->ZN_REVISAO $ '001', Posicione("SZM", 1, xFilial("SZM")+SZN->ZN_COMP, "ZM_DESCRIC"), Posicione("SB1", 1, xFilial("SB1")+SZN->ZN_COMP, "B1_DESC") )
                   TMPREV->REVTRT := SZN->ZN_TRT
                   TMPREV->REVPER := SZN->ZN_PERC
                   TMPREV->REVQTD := SZN->ZN_QUANT
                   TMPREV->REVPRD := SZN->ZN_PERDA
                   TMPREV->REVPES := SZN->ZN_PESESP
                   //TMPREV->REVCUN := Iif( Posicione("SB1", 1, xFilial('SB1')+SZN->ZN_COMP, "B1_TIPO") $ 'MP', Posicione("SB1", 1, xFilial('SB1')+SZN->ZN_COMP, "B1_UPRC"), U_fCCusPro(SZN->ZN_COMP,SZN->ZN_REVISAO) )
                   TMPREV->REVCUN := Iif(SZM->ZM_REVISAO $ '001' .and. SubStr(TMPLIB->LIBPRO, 1, 10) $ SubStr(SZN->ZN_COMP, 1, 10), U_fCCusPro(SZN->ZN_COMP,SZM->ZM_REVISAO), Iif( Posicione("SB1", 1, xFilial('SB1')+SZN->ZN_COMP, "B1_TIPO") $ 'MP', Posicione("SB1", 1, xFilial('SB1')+SZN->ZN_COMP, "B1_UPRC"), U_CustoPro(SZN->ZN_COMP) ) )
                   TMPREV->REVCRE := ( TMPREV->REVCUN * ( ( TMPREV->REVQTD * ( TMPREV->REVPRD / 100 ) ) + TMPREV->REVQTD ) )
                   TMPREV->REVCDO := (                  ( ( TMPREV->REVQTD * ( TMPREV->REVPRD / 100 ) ) + TMPREV->REVQTD ) ) / nDolarDia
                MsUnLock()
                nGet3Lib += Iif(TMPLIB->LIBTIP $ 'PA' .and. !TMPLIB->LIBUNM $ 'K .L ', 0, SZN->ZN_PERC )
                nGet4Lib += Iif(TMPLIB->LIBTIP $ 'PA' .and. !TMPLIB->LIBUNM $ 'K .L ', 0, Round( (TMPREV->REVPER / TMPREV->REVPES), 6 ) )
                nGet9Lib += Round( TMPREV->REVCRE, 3 )
                nGetALib += Round( TMPREV->REVCDO, 3 )
                DbSelectArea("SZN")
                DbSkip()
          Enddo
       Endif
       nGet4Lib := Iif(TMPLIB->LIBTIP $ 'PA' .and. !TMPLIB->LIBUNM $ 'K .L ', 0, 100 / nGet4Lib )
       If !(cNumEmp == "01010104")
          If TMPLIB->LIBTIP $ 'PI'
             If 'K' $ TMPLIB->LIBUNM
                //%Fórmula
                oSay5Lib:Refresh()
                oGet3Lib:Refresh()
                //P.Especifico
                oSay6Lib:Refresh()
                oGet4Lib:Refresh()
                //Custo(R$/K)
                cSay7Lib := "Custo(R$/K):"
                oSay7Lib:Refresh()
                cSay9Lib := "Custo(R$/K):"
                oSay9Lib:Refresh()
                oGet9Lib:Refresh()
                //Custo(U$/K)
                cSay8Lib := "Custo(U$/K):"
                oSay8Lib:Refresh()
                cSayALib := "Custo(U$/K):"
                oSayALib:Refresh()
                oGetALib:Refresh()
                //
                oSayBLib:lVisible := .f.
                oGet7Lib:lVisible := .f.
                oSayDLib:lVisible := .f.
                oGetBLib:lVisible := .f.
                //Imagem (Comparação do Custo(R$/K))
                If QuantDecimais(nGet9Lib) <> QuantDecimais(nGet5Lib)
                   If QuantDecimais(nGet9Lib) > QuantDecimais(nGet5Lib)
                      cMonitor := "QMT_NO"
                   Else
                      cMonitor := "QMT_OK"
                   Endif
                Else
                   cMonitor := "QMT_COND"
                Endif
                If TMPLIB->LIBREV $ '001'
                   cMonitor := "QMT_COND"
                Endif
                oBmp1Lib:cResName := cMonitor
                oBmp1Lib:Refresh()
             ElseIf 'L' $ TMPLIB->LIBUNM
                    //%Fórmula
                    oSay5Lib:Refresh()
                    oGet3Lib:Refresh()
                    //P.Especifico
                    oSay6Lib:Refresh()
                    oGet4Lib:Refresh()
                    //Custo(R$/L)
                    cSay9Lib := "Custo(R$/L):"
                    oSay9Lib:Refresh()
                    oGet9Lib:Refresh()
                    //Custo(U$/K)
                    cSayALib := "Custo(U$/K):"
                    oSayALib:Refresh()
                    oGetALib:Refresh()
                    //Custo(R$/K)
                    oSayDLib:lVisible := .t.
                    cSayDLib := "Custo(R$/K):"
                    oSayDLib:Refresh()
                    oGetBLib:lVisible := .t.
                    nGetBLib := Round( ( 1 / nGet4Lib ) * nGet9Lib, 3 )
                    oGetBLib:Refresh()
                    //Imagem (Comparação do Custo(R$/L))
                    If QuantDecimais(nGet9Lib) <> QuantDecimais(nGet5Lib)
                       If QuantDecimais(nGet9Lib) > QuantDecimais(nGet5Lib)
                          cMonitor := "QMT_NO"
                       Else
                          cMonitor := "QMT_OK"
                       Endif
                    Else
                       cMonitor := "QMT_COND"
                    Endif
                    If TMPLIB->LIBREV == '001'
                       cMonitor := "QMT_COND"
                    Endif
                    oBmp1Lib:cResName := cMonitor
                    oBmp1Lib:Refresh()
             Endif
          ElseIf TMPLIB->LIBTIP $ 'PA'
                 //%Fórmula
                 oSay5Lib:Refresh()
                 nGet3Lib := 0
                    oGet3Lib:Refresh()
                    //P.Especifico
                    oSay6Lib:Refresh()
                    nGet4Lib := 0
                    oGet4Lib:Refresh()
                    //Custo(R$/L)
                    cSay9Lib := "Custo(R$/L):"
                    oSay9Lib:Refresh()
                    oGet9Lib:Refresh()
                    //Custo(U$/K)
                    cSayALib := "Custo(U$/K):"
                    oSayALib:Refresh()
                    oGetALib:Refresh()
                    //Preço(R$/K)
                    oSayDLib:lVisible := .t.
                    cSayDLib := "Preço:"
                    oSayDLib:Refresh()
                    aPreco := fCalculaPr(nGet9Lib, "REV", "L")
                    nGetBLib := aPreco[1]
                    oGetBLib:lVisible := .t.
                    //Imagem (Comparação do Custo(R$/L))
                    If QuantDecimais(nGet7Lib) <> QuantDecimais(nGetBLib)
                       If QuantDecimais(nGetBLib) > QuantDecimais(nGet7Lib)
                          If Abs( QuantDecimais(nGetBLib) - QuantDecimais(nGet7Lib) ) > 0.005
                             cMonitor := "QMT_NO"
                          Else
                             nGetBLib := nGetBLib - Abs( QuantDecimais(nGetBLib) - QuantDecimais(nGet7Lib) )
                             nGet9Lib := nGet9Lib - Abs( QuantDecimais(nGet9Lib) - QuantDecimais(nGet5Lib) )
                             cMonitor := "QMT_COND"
                          Endif
                       Else
                          If Abs( QuantDecimais(nGetBLib) - QuantDecimais(nGet7Lib) ) > 0.005
                             cMonitor := "QMT_OK"
                          Else
                             nGetBLib := nGetBLib + Abs( QuantDecimais(nGetBLib) - QuantDecimais(nGet7Lib) )
                             nGet9Lib := nGet9Lib + Abs( QuantDecimais(nGet9Lib) - QuantDecimais(nGet5Lib) )
                             cMonitor := "QMT_OK"
                          Endif
                       Endif
                    Else
                       cMonitor := "QMT_COND"
                    Endif
                    If TMPLIB->LIBREV == '001'
                       cMonitor := "QMT_COND"
                    Endif
                    oBmp1Lib:cResName := cMonitor
                    oBmp1Lib:Refresh()
             Endif
       Else
       If 'K' $ TMPLIB->LIBUNM
          cSay9Lib := "Custo(R$/K):"
          oSay9Lib:Refresh()
          If TMPLIB->LIBTIP $ 'PA'
             cSayDLib := "Preço:"
             oSayDLib:lVisible := .t.
             aPreco := fCalculaPr(nGet9Lib, "REV", "L")
             nGetBLib := aPreco[1]
             oGetBLib:lVisible := .t.
             //Comparação pelo Preço de Venda
             If QuantDecimais(nGet7Lib) <> QuantDecimais(nGetBLib)
                If QuantDecimais(nGetBLib) > QuantDecimais(nGet7Lib)
                   cMonitor := "QMT_NO"
                Else
                   cMonitor := "QMT_OK"
                Endif
             Else
                cMonitor := "QMT_COND"
             Endif
             oBmp1Lib:cResName := cMonitor
             oBmp1Lib:Refresh()
          Else
             //Comparação pelo Custo
             If QuantDecimais(nGet9Lib) <> QuantDecimais(nGet5Lib)
                If QuantDecimais(nGetBLib) > QuantDecimais(nGet7Lib)
                   cMonitor := "QMT_NO"
                Else
                   cMonitor := "QMT_OK"
                Endif
             Else
                cMonitor := "QMT_COND"
             Endif
             oBmp1Lib:cResName := cMonitor
             oBmp1Lib:Refresh()
          Endif
       Else
          nGetDLib := Round( ( 1 / nGet3Lib ) * nGet9Lib, 3 )
       Endif
       Endif
       DbSelectArea("TMPREV")
       DbGoTop()
Return

/*
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º fConT1PN ³ Confirma produto novo                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
Static Function fConT1PN(cAlias, nRecno, nOpc)
       Local nX
       If Empty(cGetCodT)
          MsgStop("Atenção o código do produto está vazio!", "Atenção...")
          Return
       Endif
       If SubStr(cSayPRNE, 1, 2) $ "PN"
          //Verifica se a fórmula existe em outra Empresa/Filial
          xaEmpFil := {}
          If !((SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2)) $ GETMV("MV_FILSIME"))
             xcEmpFil := GETMV("MV_FILSIMU")
             While !Empty(xcEmpFil)
                   If !(SubStr(xcEmpFil, 1, 4) = (SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2)))
                      aAdd(xaEmpFil, SubStr(xcEmpFil, 1, 4) )
                   EndIf
                  xcEmpFil := SubStr(xcEmpFil, 6, Len(xcEmpFil))
             Enddo
          Endif
          //Busca nas outras Empresas/Filiais pela nova Fórmula
          For nX := 1 To Len(xaEmpFil)
              cCodCopy := ""
              cRevCopy := ""
              cEmprFili := ""
              cQry1 := ""
              cQry1 += "SELECT SZM.ZM_CODIGO, SZM.ZM_REVISAO "
              cQry1 += "FROM SZM"+SubStr(xaEmpFil[nX], 1, 2)+"0 SZM WITH (NOLOCK) "
              cQry1 += "WHERE SZM.ZM_FILIAL  = '"+SubStr(xaEmpFil[nX], 3, 2)+"' "
              cQry1 += "  AND SZM.D_E_L_E_T_ = '' "
              cQry1 += "  AND SZM.ZM_CODIGO  = '"+cGetCodT+"' "
              cQry1 += "ORDER BY SZM.ZM_REVISAO DESC "
              TCQuery cQry1 ALIAS "TCQ" NEW
              DbSelectArea("TCQ")
              DbGoTop()
              cCodCopy := TCQ->ZM_CODIGO
              cRevCopy := TCQ->ZM_REVISAO
              cEmprFili := xaEmpFil[nX]
              DbSelectArea("TCQ")
              DbCloseArea()
              If !Empty(cCodCopy) .and. !Empty(cRevCopy)
                 If MsgYesNo("Existe esse produto na Empresa: "+xaEmpFil[nX]+", copia?", "Copia...")
                    nX := Len(xaEmpFil) + 1
                 Else
                    cCodCopy := ""
                    cRevCopy := ""
                    cEmprFili := ""
                 Endif
              Endif
          Next
       Endif
       //Faz a Chamada para a função da tela principal da simulação
       If Empty(cRevisao)
          If SubStr(cSayPRNE, 1, 2) $ "PE"
             U_PCPA04_2(cAlias, nRecno, nOpc, 'PE')
          Else
             MsgRun(OemToAnsi('Gerando nova formulação....Aguarde....'), '', {|| CursorWait(), PCPA04_PR(cAlias, nRecno, nOpc), CursorArrow() } )
          Endif
       Else
          U_PCPA04_2(cAlias, nRecno, nOpc, 'RE')
       Endif
Return

/*
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º fVolT1PN ³ Volta(Zera) tela para condição inicial do produto novo.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
Static Function fVolT1PN()
       If nRadMen == 1
          cGetCarT := space(03)
          cGetLinT := space(02)
          cGetCorT := space(02)
          cGetVarT := space(03)
          cGetEmbT := space(02)
          cGetDesT := space(30)
          cGetCodT := space(15)
          cGetLocT := space(02)
          cGetTipT := space(02)
          cGetUMeT := space(02)
          oRadMenu:lReadOnly := .f.
          oSayPRNE:lVisible  := .f.
          oSayPRNE:Refresh()
          oGetCarT:Refresh()
          oGetLinT:Refresh()
          oGetCorT:Refresh()
          oGetVarT:Refresh()
          oGetEmbT:Refresh()
          oGetDesT:Refresh()
          oGetCodT:Refresh()
          oGetLocT:Refresh()
          oGetTipT:Refresh()
          oGetUMeT:Refresh()
          oRadMenu:Refresh()
       ElseIf nRadMen == 2
              cGetDesT := space(30)
              cGetCodT := space(15)
              oRadMenu:lReadOnly := .f.
              oSayPRNE:lVisible  := .f.
              oSayPRNE:Refresh()
              oGetDesT:Refresh()
              oGetCodT:Refresh()
              oRadMenu:Refresh()
       ElseIf nRadMen == 3
              cGetDesT := space(30)
              cGetCodT := space(15)
              cGetUMeT := space(02)
              oGetCodT:oGet:Picture := '@R! 99999'
              oGetCodT:Picture     := '@R! 99999'
              oRadMenu:lReadOnly := .f.
              oSayPRNE:lVisible  := .f.
              oSayPRNE:Refresh()
              oGetDesT:Refresh()
              oGetCodT:Refresh()
              oGetUMeT:Refresh()
              oRadMenu:Refresh()
              nCBoxCo := " - Base Solvente"
              oCBoxCon:nAt := 1
              oCBoxCon:Refresh()
       Endif
Return()

/*
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º fValT1PN ³ Valida os itens da tela de produto novo.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
Static Function fValTlPN(nOpc)
       If oRadMenu:nOption == 1 // nRadMen == 1
          If nOpc == 1 //Valida Caracteristicas
             If Empty(cGetCarT) .and. oGetCarT:lReadOnly
                MsgStop("Informe uma caracteristica valida.")
                cGetCarT := space(03)
                oGetCart:SetFocus()
                oGetCart:Refresh()
                Return
             ElseIf !Empty(cGetCarT)
                    DbSelectArea("SZ4")
                    DbSetOrder(1)
                    DbSeek(xFilial("SZ4")+cGetCarT, .t.)
                    If Found()
                       cGetCodT := cGetCarT+cGetLinT+cGetCorT+cGetVarT+cGetEmbT+Space(3)
                       oGetCodT:Refresh()
                       cGetDesT := space(30)
                       cGetDesT := Alltrim(cGetDesT)+Iif(Empty(Alltrim(cGetDesT)),'', ' ')+Alltrim(SZ4->Z4_DESCR)+Space(30 - Len(Alltrim(cGetDesT)+Iif(Empty(Alltrim(cGetDesT)),'', ' ')+Alltrim(SZ4->Z4_DESCR)))
                       oGetDesT:Refresh()
                       oRadMenu:lReadOnly := .t.
                       oRadMenu:Refresh()
                       oGetLinT:SetFocus()
                    Else
                       MsgStop("Caracteristica inválida.")
                       cGetCarT := space(03)
                       oGetCart:SetFocus()
                       oGetCart:Refresh()
                       Return
                    Endif
             Endif
          ElseIf nOpc == 2 //Valida Linha
                 If Empty(cGetLinT)
                    MsgStop("Informe uma linha valida.")
                    cGetLinT := space(02)
                    oGetLinT:SetFocus()
                    oGetLinT:Refresh()
                    Return
                 Else
                    DbSelectArea("SZ1")
                    DbSetOrder(1)
                    DbSeek(xFilial("SZ1")+cGetLinT, .t.)
                    If Found()
                       cGetCodT := cGetCarT+cGetLinT+cGetCorT+cGetVarT+cGetEmbT+Space(3)
                       oGetCodT:Refresh()
                       oGetCorT:SetFocus()
                    Else
                       MsgStop("Linha inválida.")
                       cGetLinT := space(02)
                       oGetLinT:SetFocus()
                       oGetLinT:Refresh()
                       Return
                    Endif
                 Endif
          ElseIf nOpc == 3 //Valida Cor
                 If (Empty(cGetCorT) .or. Len(cGetCorT)<>2)
                    MsgStop("Informe uma cor valida.")
                    cGetCorT := space(02)
                    oGetCorT:SetFocus()
                    oGetCorT:Refresh()
                    Return
                 Else
                    DbSelectArea("SZ2")
                    DbSetOrder(1)
                    DbSeek(xFilial("SZ2")+cGetCorT, .t.)
                    If Found()
                       cGetCodT := cGetCarT+cGetLinT+cGetCorT+cGetVarT+cGetEmbT+Space(3)
                       cGetDesT:= AllTrim(cGetDesT)+Iif(Empty(cGetDesT), Alltrim(SZ2->Z2_DESCR), ' '+Alltrim(SZ2->Z2_DESCR))+space( (30 - Len(AllTrim(AllTrim(cGetDesT)+Iif(Empty(cGetDesT), Alltrim(SZ2->Z2_DESCR), ' '+Alltrim(SZ2->Z2_DESCR)))) ) )
                       cGetDesT := cGetDesT+Space((30 - Len(Alltrim(cGetDesT))))
                       oGetCodT:Refresh()
                       oGetVarT:SetFocus()
                    Else
                       MsgStop("Cor inválida.")
                       cGetCorT := space(02)
                       oGetCorT:SetFocus()
                       oGetCorT:Refresh()
                       Return
                    Endif
                 Endif
          ElseIf nOpc == 4 //Valida Variação da Cor
                 If (Empty(cGetVarT) .or. Len(cGetVarT)<>3)
                    MsgStop("Informe uma variação valida.")
                    cGetVarT := space(03)
                    oGetVarT:SetFocus()
                    oGetVarT:Refresh()
                    Return(.f.)
                 Else
                    DbSelectArea("SZ3")
                    DbSetOrder(1)
                    DbSeek(xFilial("SZ3")+cGetCorT+cGetVarT, .t.)
                    If Found()
            	       cGetCodT:= cGetCarT+' '+cGetLinT+cGetCorT+cGetVarT+ space(Len(cGetCodT) - Len(cGetCarT+' '+cGetLinT+cGetCorT+cGetVarT))
                       oGetCodT:Refresh()
                       cGetDesT:= Alltrim(cGetDesT)+Iif(Empty(cGetDesT), Alltrim(SZ3->Z3_DESCR), ' '+Alltrim(SZ3->Z3_DESCR))+space( (30 - Len(AllTrim(cGetDesT+Iif(Empty(cGetDesT), Alltrim(SZ3->Z3_DESCR), ' '+Alltrim(SZ3->Z3_DESCR)) )) ) )
                       cGetDesT:= cGetDesT+Space((30 - Len(Alltrim(cGetDesT))))
                       oGetDesT:Refresh()
                       oGetEmbT:SetFocus()
                       oGetEmbT:Refresh()
           
                     //  cGetCodT := cGetCarT+cGetLinT+cGetCorT+cGetVarT+cGetEmbT+Space(3)
                     //  oGetCodT:Refresh()
                     //  cGetDesT := Alltrim(cGetDesT)+Iif(Empty(Alltrim(cGetDesT)), '', ' ')+Alltrim(SZ3->Z3_DESCR)+Space(30 - Len(Alltrim(cGetDesT)+Iif(Empty(Alltrim(cGetDesT)), '', ' ')+Alltrim(SZ3->Z3_DESCR)))
                     //  oGetDesT:Refresh()
                     //  oGetEmbT:SetFocus()
                    Else
                       MsgStop("Variação inválida.")
                       cGetVarT := space(03)
                       oGetVarT:SetFocus()
                       oGetVarT:Refresh()
                       Return
                    Endif
                 Endif
          ElseIf nOpc == 5 //Valida Embalagem
                 If Empty(cGetEmbT)
                    MsgStop("Informe uma embalagem valida.")
                    cGetEmbT := space(02)
                    oGetEmbT:SetFocus()
                    oGetEmbT:Refresh()
                    Return
                 Else
                    DbSelectArea("SZ5")
                    DbSetOrder(1)
                    DbSeek(xFilial("SZ5")+cGetEmbT, .t.)
                    If Found()
                       cGetCodT := cGetCarT+cGetLinT+cGetCorT+cGetVarT+cGetEmbT+Space(3)
                       oGetCodT:Refresh()
                       oGetDesT:SetFocus()
                       If cGetEmbT $ '00'
          //              cGetLocT := '02'
                          cGetTipT := 'PI'
                          cGetUMeT := 'L '
                          oGetLocT:SetFocus()
                       Else
          //              cGetLocT := '03'
                          cGetTipT := 'PA'
                          cGetUMeT := 'UN'
                          oGetLocT:SetFocus()
                       Endif
                       //Verificação de Produto Existente ou novo
                       DbSelectArea("SB1")
                       DbSetOrder(1)
                       DbSeek(xFilial("SB1")+cGetCodT, .t.)
                       If Found()
                          cRevisao := Posicione("SZM", 3, xFilial("SZM")+cGetCodT, "ZM_REVISAO")
                          cSayPRNE := "PE - PRODUTO EXISTENTE - "+Iif(Empty(cRevisao), "SEM REVISAO", cRevisao)
                          cGetDesT := SB1->B1_DESC
                       Else
                          If SubStr(cGetCodT, 11, 2) <> '00'
                             DbSelectArea("SB1")
                             DbSetOrder(1)
                             DbSeek(xFilial("SB1")+SubStr(cGetCodT, 1, 10), .t.)
                             If Found()
                               cGetDesT := SB1->B1_DESC
                              Endif
                          Endif
                          cSayPRNE := "PN - PRODUTO NOVO"
                          cRevisao := ""
                       Endif
                       oSayPRNE:lVisible := .t.
                       oGetDesT:Refresh()
                       oSayPRNE:Refresh()
                       oGetLocT:Refresh()
                       oGetTipT:Refresh()
                       oGetUMeT:Refresh()
                    Else
                       MsgStop("Embalagem inválida.")
                       cGetEmbT := space(02)
                       oGetEmbT:SetFocus()
                       oGetEmbT:Refresh()
                       Return
                    Endif
                 Endif
          ElseIf nOpc == 8 //Valida Local
          		 If cGetEmbT == '00' .and. cGetTipT == 'PI'
						If (Empty(cGetLocT) .or. !cGetLocT $ '02.20')
							MsgStop("Informe o local válido de produção do produto. ( 02 PI Fab I e 20 PI Fab II)! ")
							cGetLocT :=Space(02)
							oGetLocT:SetFocus()
							oGetLoct:Refresh()
							Return(.f.)
						Endif
		   		 Elseif ! cGetEmbT ='00' .and. cGetTipT == 'PA'
		            	If (Empty(cGetLocT) .or. !cGetLocT $ '03.30')
		            		MsgStop("Informe o local válido de envase do produto. ( 03 PA Fab I e 30 PA Fab II)! ")
							cGetLocT :=Space(02)
							oGetLocT:SetFocus()
							oGetLoct:Refresh()
							Return(.f.)
						Endif	
          		Endif
          Endif
       ElseIf oRadMenu:nOption == 2 // nRadMen == 2
              If nOpc == 6 //Valida Codigo
                 If (Empty(cGetCodT) .or. Len(Alltrim(cGetCodT)) < 4)
                    MsgStop("Informe um codigo valido.")
                    cGetCodT := space(04)
                    oGetCodT:SetFocus()
                    oGetCodT:Refresh()
                    Return
                 ElseIf !Empty(cGetCodT)
                        DbSelectArea("SB1")
                        DbSetOrder(1)
                        DbSeek(xFilial("SB1")+cGetCodT, .t.)
                        If Found()
                           If SB1->B1_TIPO <> 'PI' .and. !(cNumEmp == "01010104")
                              MsgStop("Atenção esse produto já existe no cadastro, como tipo "+SB1->B1_TIPO+". ", "Atenção...")
                              cGetCodT := space(04)
                              oGetCodT:SetFocus()
                              oGetCodT:Refresh()
                              cGetDesT := space(30)
                              oGetDesT:Refresh()
                           Else
                              cRevisao := Posicione("SZM", 3, xFilial("SZM")+cGetCodT, "ZM_REVISAO")
                              oSayPRNE:lVisible := .t.
                              cSayPRNE := "PE - PRODUTO EXISTENTE - "+Iif(Empty(cRevisao), "SEM REVISAO", cRevisao)
                              cGetDesT := SB1->B1_DESC
                              oGetDesT:Refresh()
                              If (cNumEmp == "01010104") .and. SubStr(cGetCodT, 6, 2) $ '05'
                                 cGetUMeT := 'UN'
                              Endif
                           Endif
                        Else
                           oSayPRNE:lVisible := .t.
                           cSayPRNE := "PN - PRODUTO NOVO"
                           cRevisao := ""
                           cGetDesT := space(30)
                           oGetDesT:SetFocus()
                           oGetDesT:Refresh()
                           oSayPRNE:Refresh()
                           If (cNumEmp == "01010104")
                              cGetUMeT := Iif(Len(Alltrim(cGetCodT)) == 5, 'K ', Iif(SubStr(Alltrim(cGetCodT), 6, 2) $ '00', 'K ', 'UN'))
                              oGetUMet:Refresh()
                           Endif
                           oRadMenu:lReadOnly := .t.
                           oRadMenu:Refresh()
                           Return
                        Endif
                 Endif
              Endif
       ElseIf oRadMenu:nOption == 3 // nRadMen == 3
              If nOpc == 6 //Valida Codigo
                 If (Empty(cGetCodT) .or. Len(cGetCodT) < 5)
                    MsgStop("Informe um codigo valido.")
                    cGetCodT := space(05)
                    oGetCodT:SetFocus()
                    oGetCodT:Refresh()
                    Return
                 ElseIf !Empty(cGetCodT)
                        DbSelectArea("SB1")
                        DbSetOrder(1)
                        DbSeek(xFilial("SB1")+cGetCodT, .t.)
                        If Found()
                           If SB1->B1_TIPO <> 'PI' .and. !(cNumEmp == "01010104")
                              MsgStop("Atenção esse produto já existe no cadastro, como tipo "+SB1->B1_TIPO+". ", "Atenção...")
                              cGetCodT := space(05)
                              oGetCodT:SetFocus()
                              oGetCodT:Refresh()
                              cGetDesT := space(30)
                              oGetDesT:Refresh()
                           Else
                              cRevisao := Posicione("SZM", 3, xFilial("SZM")+cGetCodT, "ZM_REVISAO")
                              oSayPRNE:lVisible := .t.
                              cSayPRNE := "PE - PRODUTO EXISTENTE - "+Iif(Empty(cRevisao), "SEM REVISAO", cRevisao)
                              oCBoxCon:lReadOnly := .f.
                              cGetDesT := SB1->B1_DESC
                              oGetDesT:Refresh()
                              oCBoxCon:Refresh()
                           Endif
                        Else
                           cSayPRNE := "PN - PRODUTO NOVO"
                           cRevisao := ""
                           oSayPRNE:lVisible := .t.
                           oSayPRNE:Refresh()
                           cGetDesT := space(30)
                           oGetDesT:SetFocus()
                           oGetDesT:Refresh()
                           oCBoxCon:lReadOnly := .f.
                           oRadMenu:lReadOnly := .t.
                           oRadMenu:Refresh()
                           oCBoxCon:Refresh()
                           Return
                        Endif
                 Endif
              ElseIf nOpc == 7 //Valida Solvente/Base D'agua
                     If oCBoxCon:nAt == 1
                        cGetCodT := SubStr(Alltrim(cGetCodT), 1, 5)+space(10)
                     Else
                        cGetCodT := SubStr(Alltrim(cGetCodT), 1, 5)+'1'+space(9)
                        oGetCodT:Picture      := '@R! 999999'
                        oGetCodT:oGet:Picture := '@R! 999999'
                        DbSelectArea("SB1")
                        DbSetOrder(1)
                        DbSeek(xFilial("SB1")+cGetCodT, .t.)
                        If Found()
                           cRevisao := Posicione("SZM", 3, xFilial("SZM")+cGetCodT, "ZM_REVISAO")
                           oSayPRNE:lVisible := .t.
                           cSayPRNE := "PE - PRODUTO EXISTENTE - "+Iif(Empty(cRevisao), "SEM REVISAO", cRevisao)
                           cGetDesT := SB1->B1_DESC
                           oGetDesT:Refresh()
                        Else
                           cSayPRNE := "PN - PRODUTO NOVO"
                           cRevisao := ""
                           cGetDesT := "CONC B'AGUA"+SubStr(cGetDesT, 5, 30)
                           oGetDesT:Refresh()
                           oSayPRNE:lVisible := .t.
                           oSayPRNE:Refresh()
                        Endif
                     Endif
                     oGetCodT:Refresh()
              Endif
       Endif
Return(.t.)

/*
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º fTrocaPN ³ Valida a troca do tipo de produto novo, Tinta, Pastas/Solu-º±±
±±º          ³ ções e Concentrado para Matriz e Tintas e Resinas para Fi- º±±
±±º          ³ lial.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
Static Function fTrocaPN()
       If oRadMenu:nOption == 1  //nRadMen == 1
          oGrpOpca:cCaption := "Tintas"
          oSayCarT:lVisible := .t. ; oGetCarT:lVisible := .t.
          oSayLinT:lVisible := .t. ; oGetLinT:lVisible := .t.
          oSayCorT:lVisible := .t. ; oGetCorT:lVisible := .t.
          oSayVarT:lVisible := .t. ; oGetVarT:lVisible := .t.
          oSayEmbT:lVisible := .t. ; oGetEmbT:lVisible := .t.
          oSayEmbT:nLeft    :=  16 ; oGetEmbT:nLeft    := 112
          oSayLocT:lVisible := .t. ; oGetLocT:lVisible := .t.
          oSayLocT:nLeft    := 224 ; oGetLocT:nLeft    := 280
          oSayTipT:lVisible := .t. ; oGetTipT:lVisible := .t.
          oSayTipT:nLeft    := 392 ; oGetTipT:nLeft    := 440
          oSayUMeT:lVisible := .t. ; oGetUMeT:lVisible := .t.
          oSayUMeT:nLeft    := 552 ; oGetUMeT:nLeft    := 648
          oGetCodT:lVisible := .t.
          cPicCodT := '@!R AA 99.99.999-99'
          oGetCodT:Picture      := cPicCodT
          oGetCodT:oGet:Picture := cPicCodT
          cGetCodT := space(15)
          oSayCodT:nTop     := 244 ; oGetCodT:nTop     := 240
          oGetCodT:lReadOnly:= .t.
          oSayDesT:lVisible := .t. ; oGetDesT:lVisible := .t.
          oSayDesT:nTop     := 244 ; oGetDesT:nTop     := 240
          cGetDesT := space(30)
          oSayClas:lVisible := .f. ; oCBoxCon:lVisible := .f.
          cGetLocT := space(02)
          cGetTipT := space(02)
          cGetUMeT := space(02)
          oGetLocT:Refresh()
          oGetTipT:Refresh()
          oGetUMeT:Refresh()
          oGetCodT:Refresh()
          oGetCarT:SetFocus()
       ElseIf oRadMenu:nOption == 2 //nRadMen == 2
              If !(cNumEmp == "01010104")
                 oGrpOpca:cCaption := "Pastas / Soluções"
                 oSayCarT:lVisible := .f. ; oGetCarT:lVisible := .f.
                 oSayLinT:lVisible := .f. ; oGetLinT:lVisible := .f.
                 oSayCorT:lVisible := .f. ; oGetCorT:lVisible := .f.
                 oSayVarT:lVisible := .f. ; oGetVarT:lVisible := .f.
                 oSayEmbT:lVisible := .f. ; oGetEmbT:lVisible := .f.
                 oSayClas:lVisible := .f. ; oCBoxCon:lVisible := .f.
                 oSayLocT:nLeft    :=  16 ; oGetLocT:nLeft    :=  72
                 oSayTipT:nLeft    := 304 ; oGetTipT:nLeft    := 352
                 oSayUMeT:nLeft    := 576 ; oGetUMeT:nLeft    := 672
                 oGetCodT:lReadOnly:= .f.
                 cPicCodT := '@R 9999'
                 oGetCodT:Picture      := cPicCodT
                 oGetCodT:oGet:Picture := cPicCodT
                 cGetCodT := space(15)
                 oSayCodT:nTop     := 164 ; oGetCodT:nTop     := 160
                 oSayDesT:nTop     := 164 ; oGetDesT:nTop     := 160
                 cGetDesT := space(30)
                 cGetLocT := '02'
                 cGetTipT := 'PI'
                 cGetUMeT := 'K '
                 oGetLocT:Refresh()
                 oGetTipT:Refresh()
                 oGetUMeT:Refresh()
                 oGetCodT:Refresh()
                 oGetCodT:SetFocus()
              Else 
                     oGrpOpca:cCaption := "Resinas"
                     oSayCarT:lVisible := .f. ; oGetCarT:lVisible := .f.
                     oSayLinT:lVisible := .f. ; oGetLinT:lVisible := .f.
                     oSayCorT:lVisible := .f. ; oGetCorT:lVisible := .f.
                     oSayVarT:lVisible := .f. ; oGetVarT:lVisible := .f.
                     oSayEmbT:lVisible := .f. ; oGetEmbT:lVisible := .f.
                     oSayLocT:nLeft    :=  16 ; oGetLocT:nLeft    :=  72
                     oSayTipT:nLeft    := 304 ; oGetTipT:nLeft    := 352
                     oSayUMeT:nLeft    := 576 ; oGetUMeT:nLeft    := 672
                     oGetCodT:lReadOnly:= .f.
                     cPicCodT := '@R! AA99999'
                     oGetCodT:Picture      := cPicCodT
                     oGetCodT:oGet:Picture := cPicCodT
                     cGetCodT := space(15)
                     oSayCodT:nTop     := 164 ; oGetCodT:nTop     := 160
                     oSayDesT:nTop     := 164 ; oGetDesT:nTop     := 160
                     cGetDesT := space(30)
                     oSayClas:lVisible := .f. ; oCBoxCon:lVisible := .f.
                     cGetLocT := '03'
                     cGetTipT := 'PA'
                     cGetUMeT := 'K '
                     oGetLocT:Refresh()
                     oGetTipT:Refresh()
                     oGetUMeT:Refresh()
                     oGetCodT:Refresh()
              Endif
       ElseIf oRadMenu:nOption == 3 // nRadMen == 3
              oGrpOpca:cCaption := "Concentrados"
              oSayCarT:lVisible := .f. ; oGetCarT:lVisible := .f.
              oSayLinT:lVisible := .f. ; oGetLinT:lVisible := .f.
              oSayCorT:lVisible := .f. ; oGetCorT:lVisible := .f.
              oSayVarT:lVisible := .f. ; oGetVarT:lVisible := .f.
              oSayEmbT:lVisible := .f. ; oGetEmbT:lVisible := .f.
              oSayClas:lVisible := .t. ; oCBoxCon:lVisible := .t.
              oSayLocT:nLeft    := 296 ; oGetLocT:nLeft    := 352
              oSayTipT:nLeft    := 440 ; oGetTipT:nLeft    := 488
              oSayUMeT:nLeft    := 576 ; oGetUMeT:nLeft    := 672
              oGetCodT:lReadOnly:= .f.
              cPicCodT := '@R! 99999'
              oGetCodT:Picture      := cPicCodT
              oGetCodT:oGet:Picture := cPicCodT
              cGetCodT := space(15)
              oSayCodT:nTop := 164 ; oGetCodT:nTop := 160
              oSayDesT:nTop := 164 ; oGetDesT:nTop := 160
              cGetDesT := space(30)
              cGetLocT := '02'
              cGetTipT := 'PI'
              cGetUMeT := 'K '
              oGetLocT:Refresh()
              oGetTipT:Refresh()
              oGetUMeT:Refresh()
              oGetCodT:SetFocus()
              oGetCodT:Refresh()
       Endif
       oGrpOpca:Refresh()
       oSayCarT:Refresh() ; oGetCarT:Refresh()
       oSayLinT:Refresh() ; oGetLinT:Refresh()
       oSayCorT:Refresh() ; oGetCorT:Refresh()
       oSayVarT:Refresh() ; oGetVarT:Refresh()
       oSayEmbT:Refresh() ; oGetEmbT:Refresh()
       oSayLocT:Refresh() ; oGetLocT:Refresh()
       oSayTipT:Refresh() ; oGetTipT:Refresh()
       oSayUMeT:Refresh() ; oGetUMeT:Refresh()
       oSayCodT:Refresh() ; oGetCodT:Refresh()
       oSayDesT:Refresh() ; oGetDesT:Refresh()
       oSayClas:Refresh() ; oCBoxCon:Refresh()
Return

/*
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º PCPA04_PR³ Função principal da simulação.                             º±±
±±º          ³ Visualiza (2) - Visualiza simulações.                      º±±
±±º          ³ Prod. Novo(3) - Inclui simulações de produtos novas.       º±±
±±º          ³ Simulação (4) - Gera uma nova revisão de produto.          º±±
±±º          ³ Manutenção(5) - Faz Manutenção de um produto não aprovado. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
Static Function PCPA04_PR(cAlias, nRecno, nOpc, cSimula)
       // Variaveis Locais da Funcao

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Inicio das variveis da Enchoice   ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Local cAliasE    := "SZM"      // Tabela cadastrada no Dicionario de Tabelas (SX2) que sera editada
       //Local aCpoEnch   := {""}       // Vetor com nome dos campos que serao exibidos. Os campos de usuario sempre serao
                                      // exibidos se nao existir no parametro um elemento com a expressao "NOUSER"
       Local aAlterEnch := {""}       // Vetor com nome dos campos que poderao ser editados
       //Local nReg       := 1          // Numero do Registro a ser Editado/Visualizado (Em caso de Alteracao/Visualizacao)
                                      // Vetor com coordenadas para criacao da enchoice no formato {<top>, <left>, <bottom>, <right>}
       Local aPos       := {017, 006, 124, 428}
       Local nModelo    := 3          // Se for diferente de 1 desabilita execucao de gatilhos estrangeiros
       Local lF3        := .F.        // Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria
       Local lMemoria   := .T.        // Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao
       Local lColumn    := .F.        // Indica se a apresentacao dos campos sera em forma de coluna
       Local caTela     := ""         // Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela
       Local lNoFolder  := .F.        // Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)
       Local lProperty  := .T.        // Indica se a enchoice nao utilizara as variaveis aTela e aGets, somente suas propriedades com os mesmos nomes
       Local lCreate    := .f.
       Local lNomDistretch := .f.
       
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Termino das variveis da Enchoice   ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       Private aCoBrw2Sim := {}
       Private aHoBrw2Sim := {}
       Private noBrw2Sim  := 0
       Private cSay1Sim   := Space(1)
       Private cSay2Sim   := Space(1)
       Private cSay3Sim   := Space(1)
       Private cSay4Sim   := Space(1)
       Private cSay5Sim   := Space(1)
       Private cSay6Sim   := Space(1)
       Private cSay7Sim   := "Custo(R$/L):"
       Private cSay8Sim   := "Custo(U$):"
       Private cSay9Sim   := "Custo(R$/L):"
       Private cSayASim   := "Custo(U$):"
       Private cSayBSim   := "Custo(R$/K):"
       Private cSayCSim   := Space(1)
       Private cSayDSim   := "Custo(R$/K):"
       Private cSayESim   := Space(1)
       Private cSayFSim   := Space(1)
       Private nGet1Sim   := 0
       Private nGet2Sim   := 0
       Private nGet3Sim   := 0
       Private nGet4Sim   := 0
       Private nGet5Sim   := 0
       Private nGet6Sim   := 0
       Private nGet7Sim   := 0
       Private oGet7Sim
       Private nGet8Sim   := 0
       Private nGet9Sim   := 0
       Private nGetASim   := 0
       Private nGetBSim   := 0
       Private nGetDSim   := 0
       Private aResultE   := {} //Valores para Embalagens do produto
       Private aResultO   := {} //Valores para Operações  do produto
       Private aResultA   := {} //Valores para Análise Técnica do Produto
       Private aResultX   := {} //Valores para Análise Técnica do Produto - Aceite
       Private cMonitor   := ''
       Private aAcho      := {}

       // Variaveis que definem a Acao do Formulario
       If nOpc == 8
          nOpc := 3
       Endif
       PRIVATE VISUALSIM := Iif(nOpc == 2, .T., .F.)
       Private INCLUISIM := Iif(nOpc == 3, .T., .F.)
       Private ALTERASIM := Iif(nOpc == 4 .or. nOpc == 5, .T., .F.)
       Private DELETASIM := Iif(nOpc == 6, .T., .F.)
       Private aSavTela := {}
       Private aTELA    := Array(0,0)
       Private aGets    := Array(0)

       If ALTERASIM
          nOpcE := 4
       ElseIf DELETASIM
              nOpcE := 5
       Else
          nOpcE := nOpc
       Endif
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oFont1Si", "oFont2Si", "oFont3Si", "oDlg1Sim", "oSay1Sim", "oSay2Sim", "oBtn1Sim", "oBtn2Sim", "oBtn3Sim")
       SetPrvt("oBtn5Sim", "oGrp1Sim", "oGrp4Sim", "oSay7Sim", "oSay8Sim", "oSayBSim", "oSayCSim", "oGet5Sim", "oGet6Sim")
       SetPrvt("oGet8Sim", "oGrp5Sim", "oSay9Sim", "oSayASim", "oSayDSim", "oSayESim", "oGet9Sim", "oGetBSim", "oGetASim")
       SetPrvt("oGrp2Sim", "oSay3Sim", "oSay4Sim", "oGet1Sim", "oGet2Sim", "oGrp3Sim", "oSay5Sim", "oSay6Sim", "oGet3Sim")
       SetPrvt("oBrw1Sim", "oBrw2Sim", "oSayFSim", "oBmp1Sim", "oBtn6Sim", "oBtn7Sim")

       RegToMemory(cAliasE, INCLUISIM, .F.)
       If nOpc == 3
          If !Empty(cCodCopy) .and. !Empty(cRevCopy)
             cQry1 := ""
             cQry1 += "SELECT SZM.ZM_CODIGO, SZM.ZM_REVISAO, SZM.ZM_DESCRIC, SZM.ZM_TIPO, SZM.ZM_LOCAL, SZM.ZM_UM "
             cQry1 += "FROM SZM"+SubStr(cEmprFili, 1, 2)+"0 SZM WITH (NOLOCK) "
             cQry1 += "WHERE SZM.ZM_FILIAL  = '"+SubStr(cEmprFili, 3, 2)+"' "
             cQry1 += "  AND SZM.D_E_L_E_T_ = '' "
             cQry1 += "  AND SZM.ZM_CODIGO  = '"+cCodCopy+"' "
             cQry1 += "  AND SZM.ZM_REVISAO = '"+cRevCopy+"' "
             cQry1 += "ORDER BY SZM.ZM_REVISAO DESC "
             TCQuery cQry1 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             DbGoTop()
             cGetDesT := TCQ->ZM_DESCRIC
             cGetTipT := TCQ->ZM_TIPO
             cGetLocT := TCQ->ZM_LOCAL
             cGetUMeT := TCQ->ZM_UM
             DbSelectArea("TCQ")
             DbCloseArea()
          Endif
          M->ZM_CODIGO  := cGetCodT
          M->ZM_REVISAO := Iif(SubStr(cSayPRNE, 1, 2) $ 'PN', "001", StrZero(nRevisao, 3))
          M->ZM_DESCRIC := cGetDesT
          M->ZM_RESPONS := cUserName
          M->ZM_DTINCLU := dDataBase
          M->ZM_TIPO    := cGetTipT
          M->ZM_TIPOPRO := SubStr(cSayPRNE, 1, 2)
          M->ZM_REVISIN := INVERTE(Iif(SubStr(cSayPRNE, 1, 2) $ 'PN', "001", StrZero(nRevisao, 3) ))
          M->ZM_STATUS  := "EE"
          M->ZM_LOCAL   := cGetLocT
          M->ZM_UM      := cGetUMeT
          M->ZM_SEQ     := "001"
          M->ZM_PCREVIS := Iif(Empty(Posicione("SZ3", 1, xFilial("SZ3")+SubStr(M->ZM_CODIGO, 6, 5), "Z3_PADCOR")), "N", "S")
          M->ZM_PADCOR  := Iif(M->ZM_PCREVIS $ 'S', Posicione("ZZE", 1, xFilial("ZZE")+Posicione("SZ3", 1, xFilial("SZ3")+SubStr(M->ZM_CODIGO, 6, 5), "Z3_PADCOR"), "ZZE_DESCRI"), "")
          M->ZM_DESEMB  := Iif(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_UMEMB") $ 'K', "KILOS", "LITROS")
       Else
          M->ZM_CODIGO  := SZM->ZM_CODIGO
          M->ZM_REVISAO := Iif(nOpc == 2 .or. nOpc == 5 .or. nOpc == 6, SZM->ZM_REVISAO, Iif(SubStr(cSayPRNE, 1, 2) $ 'PN', "001", StrZero(nRevisao, 3)) )
          M->ZM_DESCRIC := SZM->ZM_DESCRIC
          M->ZM_RESPONS := Iif(Empty(SZM->ZM_RESPONS), cUserName, SZM->ZM_RESPONS)
          M->ZM_DTINCLU := Iif(cSimula == 'S' .and. nOpc ==  4, dDataBase, SZM->ZM_DTINCLU )
          M->ZM_TIPO    := SZM->ZM_TIPO
          M->ZM_TIPOPRO := SZM->ZM_TIPOPRO
          M->ZM_REVISIN := SZM->ZM_REVISIN
          M->ZM_STATUS  := SZM->ZM_STATUS
          M->ZM_LOCAL   := SZM->ZM_LOCAL
          M->ZM_UM      := SZM->ZM_UM
          M->ZM_SEQ     := SZM->ZM_SEQ
          M->ZM_MOTIVO  := Iif(cSimula == 'S' .and. nOpc ==  4, '', u_fBuscaHistorico(SZM->ZM_ID, "SI", "EE"))
          M->ZM_PCREVIS := SZM->ZM_PCREVIS
          M->ZM_PADCOR  := SZM->ZM_PADCOR
          M->ZM_DESEMB  := Iif(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_UMEMB") $ 'K', "KILOS", "LITROS")
          M->ZM_POSIPI  := Iif(!Empty(SZM->ZM_POSIPI), SZM->ZM_POSIPI, Posicione("SB1", 1, xFilial("SB1")+SZM->ZM_CODIGO, "B1_POSIPI"))
          M->ZM_EX_NCM  := Iif(!Empty(SZM->ZM_POSIPI), SZM->ZM_EX_NCM, Posicione("SB1", 1, xFilial("SB1")+SZM->ZM_CODIGO, "B1_EX_NCM"))
          If DELETASIM
             nOpc := 2
          Endif
       Endif
       If !SubStr(M->ZM_CODIGO, 1, 2) $ 'RV'
          DbSelectArea("SZ3")
          DbSetOrder(1)
          DbSeek(xFilial("SZ3")+Iif( Len(M->ZM_CODIGO) == 12, SubStr(M->ZM_CODIGO, 6, 5), SubStr(M->ZM_CODIGO, 1, 5) ), .t.)
          If Found()
             DbSelectArea("ZZE")
             DbSetOrder(1)
             DbSeek(xFilial("ZZE")+SZ3->Z3_PADCOR, .t.)
             If Found()
                M->ZM_PCREVIS := ZZE->ZZE_LIBERA
                M->ZM_PADCOR  := ZZE->ZZE_DESCRI
             Endif
          Endif
       Endif
       MHoBrw2Sim()
       If !MCoBrw2Sim()
          Return
       Endif
       If !(cNumEmp == "01010104")
          If nRadMen == 1 //Tinta
             If M->ZM_TIPO $ 'PI'
                aAcho      := {"NOUSER", "ZM_CODIGO", "ZM_DESCRIC", "ZM_RESPONS", "ZM_DTINCLU", "ZM_TIPO", "ZM_SOLICIT", "ZM_MOTIVO", "ZM_LOCAL", "ZM_UM", "ZM_ROTEIRO", "ZM_CATALIS", "ZM_RELCAT", "ZM_GRUPO2", "ZM_PCREVIS", "ZM_PADCOR", "ZM_DTPREVI"}
                //Carregar as embalagens caso exista.
                DbSelectArea("SZP")
                DbSetOrder(2)
                DbSeek(xFilial("SZP")+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
                If Found()
                   While !Eof() .and. SZP->ZP_CODIGO == M->ZM_CODIGO .and. SZP->ZP_REVISAO == M->ZM_REVISAO
                         aAdd(aResultE, {SZP->ZP_EMB, Posicione("SZ5", 1, xFilial("SZ5")+SZP->ZP_EMB, "Z5_DESCR")} )
                         DbSelectArea("SZP")
                         DbSkip()
                   Enddo
                Endif
                //Análise técnica
                DbSelectArea("ZZD")
                DbSetOrder(1)
                DbSeek(xFilial("ZZD")+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
                If Found()
                   While !Eof() .and. ZZD->ZZD_CODIGO == M->ZM_CODIGO .and. ZZD->ZZD_REVISAO == M->ZM_REVISAO
                         aAdd(aResultA, {ZZD->ZZD_FILIAL, ZZD->ZZD_CODIGO, ZZD->ZZD_REVISAO, ZZD->ZZD_SEQAT, ZZD->ZZD_SEQ, ZZD->ZZD_ENSAIO, Posicione("QP1", 1, xFilial("QP1")+ZZD->ZZD_ENSAIO, "QP1_DESCPO"), ZZD->ZZD_CARTA, ZZD->ZZD_MINMAX, ZZD->ZZD_LIE, ZZD->ZZD_NOMINA, ZZD->ZZD_LIS, ZZD->ZZD_TEXTO, ZZD->ZZD_DATAME, ZZD->ZZD_HORAME, ZZD->ZZD_ENSR, u_SI_NUSR(SubStr(ZZD->ZZD_ENSR, 3, 2), ZZD->ZZD_ENSR, .f., "A"), ZZD->ZZD_MEDNUM, ZZD->ZZD_MEDTXT, ZZD->ZZD_RESULT} )
                         DbSelectArea("ZZD")
                         DbSkip()
                   EndDo
                Endif
                DbSelectArea("SZT")
                DbSetOrder(2)
                DbSeek(xFilial("SZT")+M->ZM_ID+'SI'+'AT', .T.)
                If Found()
                   aAdd(aResultX, {Iif(Empty(SZT->ZT_USUARIO), 0, Val(SZT->ZT_SEQ)), SZT->ZT_DATAGER, SZT->ZT_HORAGER, SZT->ZT_USUARIO, SZT->ZT_LOG})
                Endif
             Else 
                aAcho      := {"NOUSER", "ZM_CODIGO", "ZM_DESCRIC", "ZM_RESPONS", "ZM_DTINCLU", "ZM_TIPO", "ZM_SOLICIT", "ZM_MOTIVO", "ZM_LOCAL", "ZM_UM", "ZM_ROTEIRO", "ZM_CATALIS", "ZM_RELCAT", "ZM_GRUPO2", "ZM_PCREVIS", "ZM_PADCOR", "M->ZM_DESEMB", "ZM_DTPREVI"}
             Endif
             If nOpc == 5
                aAlterEnch := {"ZM_DESCRIC", "ZM_CATALIS", "ZM_RELCAT", "ZM_GRUPO2"}
             Else
                aAlterEnch := {"ZM_DESCRIC", "ZM_CATALIS", "ZM_RELCAT", "ZM_SOLICIT", "ZM_MOTIVO", "ZM_GRUPO2", "ZM_DTPREVI"}
             Endif
          ElseIf nRadMen == 2 //Pastas / Soluções
                 aAcho      := {"NOUSER", "ZM_CODIGO", "ZM_DESCRIC", "ZM_RESPONS", "ZM_DTINCLU", "ZM_TIPO", "ZM_SOLICIT", "ZM_MOTIVO", "ZM_LOCAL", "ZM_UM", "ZM_ROTEIRO", "ZM_DTPREVI", "ZM_POSIPI","ZM_EX_NCM"}
                 //Análise técnica
                 DbSelectArea("ZZD")
                 DbSetOrder(1)
                 DbSeek(xFilial("ZZD")+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
                 If Found()
                    While !Eof() .and. ZZD->ZZD_CODIGO == M->ZM_CODIGO .and. ZZD->ZZD_REVISAO == M->ZM_REVISAO
                          aAdd(aResultA, {ZZD->ZZD_FILIAL, ZZD->ZZD_CODIGO, ZZD->ZZD_REVISAO, ZZD->ZZD_SEQAT, ZZD->ZZD_SEQ, ZZD->ZZD_ENSAIO, Posicione("QP1", 1, xFilial("QP1")+ZZD->ZZD_ENSAIO, "QP1_DESCPO"), ZZD->ZZD_CARTA, ZZD->ZZD_MINMAX, ZZD->ZZD_LIE, ZZD->ZZD_NOMINA, ZZD->ZZD_LIS, ZZD->ZZD_TEXTO, ZZD->ZZD_DATAME, ZZD->ZZD_HORAME, ZZD->ZZD_ENSR, u_SI_NUSR(SubStr(ZZD->ZZD_ENSR, 3, 2), ZZD->ZZD_ENSR, .f., "A"), ZZD->ZZD_MEDNUM, ZZD->ZZD_MEDTXT, ZZD->ZZD_RESULT} )
                          DbSelectArea("ZZD")
                          DbSkip()
                    EndDo
                 Endif
                 DbSelectArea("SZT")
                 DbSetOrder(2)
                 DbSeek(xFilial("SZT")+M->ZM_ID+'SI'+'AT', .T.)
                 If Found()
                    aAdd(aResultX, {Val(SZT->ZT_SEQ), SZT->ZT_DATAGER, SZT->ZT_HORAGER, SZT->ZT_USUARIO, SZT->ZT_LOG})
                 Endif
                 If nOpc == 5
                    aAlterEnch := {"ZM_DESCRIC", "ZM_POSIPI"}
                 Else
                    aAlterEnch := {"ZM_DESCRIC", "ZM_SOLICIT", "ZM_MOTIVO", "ZM_DTPREVI", "ZM_POSIPI"}
                 Endif
          ElseIf nRadMen == 3 //Concentrados
                 aAcho      := {"NOUSER", "ZM_CODIGO", "ZM_DESCRIC", "ZM_RESPONS", "ZM_DTINCLU", "ZM_TIPO", "ZM_SOLICIT", "ZM_MOTIVO", "ZM_LOCAL", "ZM_UM", "ZM_ROTEIRO", "ZM_DTPREVI"}
                 //Análise técnica
                 DbSelectArea("ZZD")
                 DbSetOrder(1)
                 DbSeek(xFilial("ZZD")+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
                 If Found()
                    While !Eof() .and. ZZD->ZZD_CODIGO == M->ZM_CODIGO .and. ZZD->ZZD_REVISAO == M->ZM_REVISAO
                          aAdd(aResultA, {ZZD->ZZD_FILIAL, ZZD->ZZD_CODIGO, ZZD->ZZD_REVISAO, ZZD->ZZD_SEQAT, ZZD->ZZD_SEQ, ZZD->ZZD_ENSAIO, Posicione("QP1", 1, xFilial("QP1")+ZZD->ZZD_ENSAIO, "QP1_DESCPO"), ZZD->ZZD_CARTA, ZZD->ZZD_MINMAX, ZZD->ZZD_LIE, ZZD->ZZD_NOMINA, ZZD->ZZD_LIS, ZZD->ZZD_TEXTO, ZZD->ZZD_DATAME, ZZD->ZZD_HORAME, ZZD->ZZD_ENSR, u_SI_NUSR(SubStr(ZZD->ZZD_ENSR, 3, 2), ZZD->ZZD_ENSR, .f., "A"), ZZD->ZZD_MEDNUM, ZZD->ZZD_MEDTXT, ZZD->ZZD_RESULT} )
                          DbSelectArea("ZZD")
                          DbSkip()
                    EndDo
                 Endif
                 DbSelectArea("SZT")
                 DbSetOrder(2)
                 DbSeek(xFilial("SZT")+M->ZM_ID+'SI'+'AT', .T.)
                 If Found()
                    aAdd(aResultX, {Val(SZT->ZT_SEQ), SZT->ZT_DATAGER, SZT->ZT_HORAGER, SZT->ZT_USUARIO, SZT->ZT_LOG})
                 Endif
                 If nOpc == 5
                    aAlterEnch := {"ZM_DESCRIC"}
                 Else
                    aAlterEnch := {"ZM_DESCRIC", "ZM_SOLICIT", "ZM_MOTIVO", "ZM_DTPREVI"}
                 Endif
          Endif
       Else
              If nRadMen == 1 //Tinta
                 If M->ZM_TIPO $ 'PI'
                    aAcho      := {"NOUSER", "ZM_CODIGO", "ZM_DESCRIC", "ZM_RESPONS", "ZM_DTINCLU", "ZM_TIPO", "ZM_SOLICIT", "ZM_MOTIVO", "ZM_LOCAL", "ZM_UM", "ZM_ROTEIRO", "ZM_CATALIS", "ZM_RELCAT", "ZM_GRUPO2", "ZM_PCREVIS", "ZM_PADCOR", "ZM_DTPREVI"}
                    //Análise técnica
                    DbSelectArea("ZZD")
                    DbSetOrder(1)
                    DbSeek(xFilial("ZZD")+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
                    If Found()
                       While !Eof() .and. ZZD->ZZD_CODIGO == M->ZM_CODIGO .and. ZZD->ZZD_REVISAO == M->ZM_REVISAO
                             aAdd(aResultA, {ZZD->ZZD_FILIAL, ZZD->ZZD_CODIGO, ZZD->ZZD_REVISAO, ZZD->ZZD_SEQAT, ZZD->ZZD_SEQ, ZZD->ZZD_ENSAIO, Posicione("QP1", 1, xFilial("QP1")+ZZD->ZZD_ENSAIO, "QP1_DESCPO"), ZZD->ZZD_CARTA, ZZD->ZZD_MINMAX, ZZD->ZZD_LIE, ZZD->ZZD_NOMINA, ZZD->ZZD_LIS, ZZD->ZZD_TEXTO, ZZD->ZZD_DATAME, ZZD->ZZD_HORAME, ZZD->ZZD_ENSR, u_SI_NUSR(SubStr(ZZD->ZZD_ENSR, 3, 2), ZZD->ZZD_ENSR, .f., "A"), ZZD->ZZD_MEDNUM, ZZD->ZZD_MEDTXT, ZZD->ZZD_RESULT} )
                             DbSelectArea("ZZD")
                             DbSkip()
                       EndDo
                    Endif
                    DbSelectArea("SZT")
                    DbSetOrder(2)
                    DbSeek(xFilial("SZT")+M->ZM_ID+'SI'+'AT', .T.)
                    If Found()
                       aAdd(aResultX, {Val(SZT->ZT_SEQ), SZT->ZT_DATAGER, SZT->ZT_HORAGER, SZT->ZT_USUARIO, SZT->ZT_LOG})
                    Endif
                 Else 
                    aAcho      := {"NOUSER", "ZM_CODIGO", "ZM_DESCRIC", "ZM_RESPONS", "ZM_DTINCLU", "ZM_TIPO", "ZM_SOLICIT", "ZM_MOTIVO", "ZM_LOCAL", "ZM_UM", "ZM_ROTEIRO", "ZM_CATALIS", "ZM_RELCAT", "ZM_GRUPO2", "ZM_PCREVIS", "ZM_PADCOR", "M->ZM_DESEMB", "ZM_DTPREVI"}
                 Endif
                 If nOpc == 5
                    aAlterEnch := {"ZM_DESCRIC", "ZM_CATALIS", "ZM_RELCAT", "ZM_GRUPO2"}
                 Else
                    aAlterEnch := {"ZM_DESCRIC", "ZM_CATALIS", "ZM_RELCAT", "ZM_SOLICIT", "ZM_MOTIVO", "ZM_GRUPO2", "ZM_DTPREVI"}
                 Endif
              ElseIf nRadMen == 2 //Resinas
                     aAcho      := {"NOUSER", "ZM_CODIGO", "ZM_DESCRIC", "ZM_RESPONS", "ZM_DTINCLU", "ZM_TIPO", "ZM_SOLICIT", "ZM_MOTIVO", "ZM_LOCAL", "ZM_UM", "ZM_ROTEIRO", "ZM_DTPREVI"}
                     //Análise técnica
                     DbSelectArea("ZZD")
                     DbSetOrder(1)
                     DbSeek(xFilial("ZZD")+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
                     If Found()
                        While !Eof() .and. ZZD->ZZD_CODIGO == M->ZM_CODIGO .and. ZZD->ZZD_REVISAO == M->ZM_REVISAO
                              aAdd(aResultA, {ZZD->ZZD_FILIAL, ZZD->ZZD_CODIGO, ZZD->ZZD_REVISAO, ZZD->ZZD_SEQAT, ZZD->ZZD_SEQ, ZZD->ZZD_ENSAIO, Posicione("QP1", 1, xFilial("QP1")+ZZD->ZZD_ENSAIO, "QP1_DESCPO"), ZZD->ZZD_CARTA, ZZD->ZZD_MINMAX, ZZD->ZZD_LIE, ZZD->ZZD_NOMINA, ZZD->ZZD_LIS, ZZD->ZZD_TEXTO, ZZD->ZZD_DATAME, ZZD->ZZD_HORAME, ZZD->ZZD_ENSR, u_SI_NUSR(SubStr(ZZD->ZZD_ENSR, 3, 2), ZZD->ZZD_ENSR, .f., "A"), ZZD->ZZD_MEDNUM, ZZD->ZZD_MEDTXT, ZZD->ZZD_RESULT} )
                              DbSelectArea("ZZD")
                              DbSkip()
                       EndDo
                     Endif
                     DbSelectArea("SZT")
                     DbSetOrder(2)
                     DbSeek(xFilial("SZT")+M->ZM_ID+'SI'+'AT', .T.)
                     If Found()
                        aAdd(aResultX, {Val(SZT->ZT_SEQ), SZT->ZT_DATAGER, SZT->ZT_HORAGER, SZT->ZT_USUARIO, SZT->ZT_LOG})
                     Endif
                     If nOpc == 5
                        aAlterEnch := {"ZM_DESCRIC", "ZM_GRUPO2"}
                     Else
                        aAlterEnch := {"ZM_DESCRIC", "ZM_SOLICIT", "ZM_MOTIVO", "ZM_DTPREVI", "ZM_GRUPO2", "ZM_POSIPI"}
                     Endif
              Endif
       Endif

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oFont1Si   := TFont():New( "MS Sans Serif", 0, -16, , .F., 0, , 400, .F., .F., , , , , , )
       oFont2Si   := TFont():New( "Courier New"  , 0, -21, , .T., 0, , 700, .F., .F., , , , , , )
       oFont3Si   := TFont():New( "MS Sans Serif", 0, -13, , .F., 0, , 400, .F., .F., , , , , , )
       oDlg1Sim   := MSDialog():New( 113, 180, 725, 1042, "Simulação", , , .F., , , , , , .T., , , .T. )

       oBtn1Sim   := TButton():New( 0.75, 003, "Operações"        , oDlg1Sim, { || fMontaOpera() }, 056, 012, , , , .T., , "", , , , .F. )
       oBtn2Sim   := TButton():New( 0.75, 065, "Ficha de Processo", oDlg1Sim, { || fImprimePro() }, 056, 012, , , , .T., , "", , , , .F. )
       If ( M->ZM_TIPO $ 'PI' .and. Len(Alltrim(M->ZM_CODIGO)) == 12 ) .or. (M->ZM_TIPO $ 'PA' .and. Len(Alltrim(M->ZM_CODIGO)) = 5 .and. SubStr(Alltrim(M->ZM_CODIGO), 1, 2) $ 'RV' ) //Somente para PIs Tintas ou Resinas
          oBtn3Sim   := TButton():New( 0.75, 127, "Embalagens"       , oDlg1Sim, { || fMontaEmbal() }, 056, 012, , , , .T., , "", , , , .F. )
       Endif
       //If M->ZM_TIPOPRO $ 'PN'
       oBtn6Sim   := TButton():New( 0.75, 189, "Análise Técnica"     , oDlg1Sim, { || fMontaATecn("N") }, 056, 012, , , , .T., , "", , , , .F. )
       //Endif
       oBtn7Sim   := TButton():New( 0.75, 251, "Hist. Desenvol."     , oDlg1Sim, { || fMonHisDese() }, 056, 012, , , , .T., , "", , , , .F. )
       
       oBtn4Sim   := TButton():New( 0.75, 313, "Confirmar"        , oDlg1Sim, { || fCPrincipa() }, 056, 012, , , , .T., , "", , , , .F. )
       oBtn5Sim   := TButton():New( 0.75, 375, "Sair"             , oDlg1Sim, { || oDlg1Sim:End()}, 056, 012, , , , .T., , "", , , , .F. )

       oGrp1Sim   := TGroup():New( 013, 003, 127, 431, "", oDlg1Sim, CLR_BLACK, CLR_WHITE, .T., .F. )
     //oEnchoice  := Msmget():New(cAliasE, nReg, nOpcE, /*aCra*/, /*cLetras*/, /*cTexto*/,       , @aPos         , @aAlterEnch, nModelo, , , , oDlg1Sim, lF3, lMemoria, lColumn, cAtela, lNoFolder, lProperty, , , lCreate, lNomDistretch)
       oEnchoice  := Msmget():New(cAliasE,     , nOpcE,         ,            ,           , @aAcho, @aPos         , @aAlterEnch, nModelo, , , , oDlg1Sim, lF3, lMemoria, lColumn, cAtela, lNoFolder, lProperty, , , lCreate, lNomDistretch)
       oSay1Sim   := TSay():New( 127, 004, {||"          FÓRMULA VIGENTE"          }, oDlg1Sim, , oFont2Si, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 193, 009)
       oGrp2Sim   := TGroup():New( 222, 003, 247, 215, "Especificações", oDlg1Sim, CLR_RED, CLR_WHITE, .T., .F. )
       oSay3Sim   := TSay():New( 231, 007, {|| "% Fórmula:"}, oGrp2Sim, , oFont3Si, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 009)
       oGet1Sim   := TGet():New( 230, 045, {|u| If(PCount() > 0, nGet1Sim := u, nGet1Sim) }, oGrp2Sim, 048, 010, '@E 999.99%' , , CLR_HBLUE, CLR_WHITE, oFont3Si, , , .T., "", , , .F., .F., , .T., .F., "", "nGet1Sim", , )
       oSay4Sim   := TSay():New( 231, 106, {|| "P. Espec.:"}, oGrp2Sim, , oFont3Si, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 008)
       oGet2Sim   := TGet():New( 230, 144, {|u| If(PCount() > 0, nGet2Sim := u, nGet2Sim) }, oGrp2Sim, 056, 010, '@E 9.999999', , CLR_HBLUE, CLR_WHITE, oFont3Si, , , .T., "", , , .F., .F., , .T., .F., "", "nGet2Sim", , )
       oGrp4Sim   := TGroup():New( 250, 003, 296, 215, "Totais", oDlg1Sim, CLR_RED, CLR_WHITE, .T., .F. )
       oSay7Sim   := TSay():New( 259, 007, {|| cSay7Sim }, oGrp4Sim, , oFont3Si, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 009)
       oGet5Sim   := TGet():New( 258, 045, {|u| If(PCount() > 0, nGet5Sim := u, nGet5Sim) }, oGrp4Sim, 048, 010, '@E 9,999.999', , CLR_HBLUE, CLR_WHITE, oFont3Si, , , .T., "", , , .F., .F., , .T., .F., "", "nGet5Sim", , )
       oSay8Sim   := TSay():New( 259, 106, {|| cSay8Sim }, oGrp4Sim, , oFont3Si, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 008)
       oGet6Sim   := TGet():New( 258, 144, {|u| If(PCount() > 0, nGet6Sim := u, nGet6Sim) }, oGrp4Sim, 048, 010, '@E 9,999.999', , CLR_HBLUE, CLR_WHITE, oFont3Si, , , .T., "", , , .F., .F., , .T., .F., "", "nGet6Sim", , )
       oSayBSim   := TSay():New( 279, 007, {|| cSayBSim}, oGrp4Sim, , oFont3Si, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 009)
       oGet7Sim   := TGet():New( 278, 045, {|u| If(PCount() > 0, nGet7Sim := u, nGet7Sim) }, oGrp4Sim, 048, 010, '@E 9,999.999', , CLR_HBLUE, CLR_WHITE, oFont3Si, , , .T., "", , , .F., .F., , .T., .F., "", "nGet7Sim", , )
       oSayFSim   := TSay():New( 297, 004, {|| cSayFSim}, oDlg1Sim, , , .F., .F., .F., .T., CLR_RED  , CLR_WHITE, 120, 008)
       /************* INVISIVEL POR ENQUANTO *************/
       //oSayCSim   := TSay():New( 304, 096, {|| "Custo(R$/u):"},oGrp4Sim,,oFont3Si,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,036,009)
       //oGet8Sim   := TGet():New( 303, 135, {|u| If(PCount()>0,nGet8Sim:=u,nGet8Sim)},oGrp4Sim,048,010,'',,CLR_BLACK,CLR_WHITE,oFont3Si,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nGet8Sim",,)
       /**************************************************/
       oTbl1Sim()
       DbSelectArea("TMPVIG")
       DbSetOrder(1)
       oBrw1Sim   := MsSelect():New( "TMPVIG", "", "", { {"VIGCOM", "", "Componente", ""}, {"VIGDES", "", "Descrição", ""}, {"VIGTRT", "", "Seq.", ""}, {"VIGPER", "", "% Formula", "@E 999.999"}, {"VIGQTD", "", "Quantidade", "@E 999.999999"}, {"VIGPRD", "", "Perda", "@E 99.99"}, {"VIGPES", "", "P. Específico", "@E 9.999999"}, {"VIGCUN", "", "C. Unit.", "@E 9,999.999"}, {"VIGCRE", "", "C. R$", "@E 9,999.999"}, {"VIGCDO", "", "C. U$", "@E 9,999.999"} }, .F., , { 140, 003, 220, 215 }, , , oDlg1Sim )
       oBrw1Sim:oBrowse:lAdjustColSize := .t.
       oBrw1Sim:oBrowse:nFreeze := Iif(nOpc == 3, 0, 1)
       oBrw1Sim:oBrowse:aColSizes[1] := 35
       oBrw1Sim:oBrowse:aColumns[1]:nWidth := 35
       oBrw1Sim:oBrowse:aColSizes[3] := 15
       oBrw1Sim:oBrowse:aColumns[3]:nWidth := 15
       /*******************************************************************************************************************************************/

       oSay2Sim   := TSay():New( 127, 219, {||"           REVISÃO - "+M->ZM_REVISAO} , oDlg1Sim, , oFont2Si, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 212, 009)
       oGrp3Sim   := TGroup():New( 222, 219, 247, 431, "Especificações", oDlg1Sim, CLR_RED, CLR_WHITE, .T., .F. )
       oSay5Sim   := TSay():New( 231, 223, {|| "% Fórmula:"}, oGrp3Sim, , oFont3Si, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 009)
       oGet3Sim   := TGet():New( 230, 261, {|u| If(PCount() > 0, nGet3Sim := u, nGet3Sim) }, oGrp3Sim, 048, 010, '@E 999.99%' , , CLR_HBLUE, CLR_WHITE, oFont3Si, , , .T., "", , , .F., .F., , .T., .F., "", "nGet3Sim", , )
       oSay6Sim   := TSay():New( 231, 322, {|| "P. Espec.:"}, oGrp3Sim, , oFont3Si, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 008)
       oGet4Sim   := TGet():New( 230, 360, {|u| If(PCount() > 0, nGet4Sim := u, nGet4Sim) }, oGrp3Sim, 056, 010, '@E 99.999999', , CLR_HBLUE, CLR_WHITE, oFont3Si, , , .T., "", , , .F., .F., , .T., .F., "", "nGet4Sim", , )
       oGrp5Sim   := TGroup():New( 250, 219, 296, 431, "Totais", oDlg1Sim, CLR_RED, CLR_WHITE, .T., .F. )
       oSay9Sim   := TSay():New( 259, 223, {|| cSay9Sim }, oGrp5Sim, , oFont3Si, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 009)
       oGet9Sim   := TGet():New( 258, 261, {|u| If(PCount() > 0, nGet9Sim := u, nGet9Sim) }, oGrp5Sim, 048, 010, '@E 9,999.999', , CLR_HBLUE, CLR_WHITE,oFont3Si,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nGet9Sim",,)
       oSayASim   := TSay():New( 259, 322, {|| cSayASim }, oGrp5Sim, , oFont3Si, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 008)
       oGetASim   := TGet():New( 258, 360, {|u| If(PCount() > 0, nGetASim := u, nGetASim) }, oGrp5Sim, 048, 010, '@E 9,999.999', , CLR_HBLUE, CLR_WHITE,oFont3Si,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nGetASim",,)
       oSayDSim   := TSay():New( 279, 223, {|| cSayDSim }, oGrp5Sim, , oFont3Si, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 009)
       oGetBSim   := TGet():New( 278, 261, {|u| If(PCount() > 0, nGetBSim := u, nGetBSim) }, oGrp5Sim, 048, 010, '@E 9,999.999', , CLR_HBLUE, CLR_WHITE,oFont3Si,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nGetBSim",,)
       /************* INVISIVEL POR ENQUANTO *************/
       //oSayESim   := TSay():New( 304,292,{||"Custo(R$/K):"},oGrp5Sim,,oFont3Si,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,036,009)
       //oGetDSim   := TGet():New( 303,331,{|u| If(PCount()>0,nGetDSim:=u,nGetDSim)},oGrp5Sim,048,010,'',,CLR_BLACK,CLR_WHITE,oFont3Si,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nGetDSim",,)
       /**************************************************/
       oBmp1Sim   := TBitmap():New( 283, 418, 012, 012, , "", .F., oGrp5Sim, , , .F., .F., , "", .T., , .T., , .F. )

       oBrw2Sim   := MsNewGetDados():New(140, 219, 220, 431, Iif(nOpc == 2 .or. nOpc == 6, 0, GD_INSERT+GD_UPDATE+GD_DELETE), 'AllwaysTrue()', 'AllwaysTrue()', '', , 0, 020, 'u_pcpa04cp()', '', 'u_pcpa04ap()', oDlg1Sim, aHoBrw2Sim, aCoBrw2Sim )
       oBrw2Sim:oBrowse:lAdjustColSize := .t.
       oBrw2Sim:oBrowse:nFreeze := Iif(nOpc == 3 .or. nOpc == 5 .or. nOpc == 4, 0, 1)
       oBrw2Sim:oBrowse:aColSizes[1] := 35
       oBrw2Sim:oBrowse:aColumns[1]:nWidth := 35
       oBrw2Sim:oBrowse:aColSizes[3] := 15
       oBrw2Sim:oBrowse:aColumns[3]:nWidth := 15

       MCarregaVr() //Carrega variáveis
       oDlg1Sim:Activate( , , , .T.)
       DbSelectArea("TMPVIG")
       DbCloseArea()
       oTempTbl01:Delete()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fCPrincipa() - Confirmação principal
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fCPrincipa()
       Local nSomPer := 0
       Local nY
       If VISUALSIM
          oDlg1Sim:End()
          Return
       ElseIf INCLUISIM .or. ALTERASIM
              //Verifica Solicitante da Revisão
              If Empty(M->ZM_SOLICIT)
                 MsgStop("Faltou indicar o SOLICITANTE no cabeçalho da simulação.", "Atenção...")
                 Return
              Endif
              //Verifica Motivo da Revisão
              If Empty(M->ZM_MOTIVO)
                 MsgStop("Faltou informar o MOTIVO no cabeçalho da simulação.", "Atenção...")
                 Return
              Endif
              //Verificação do Grupo 2
              If Len(Alltrim(M->ZM_CODIGO)) == 12 .and. SubStr(Alltrim(M->ZM_CODIGO), 11, 2) $ '00'
                 If Empty(M->ZM_GRUPO2)
                    MsgStop("Faltou informar o GRUPO 2 no cabeçalho da simulação.", "Atenção...")
                    Return
                 Endif
              Endif
              //Verifica se Soma de Percentuais = 100%
              If !M->ZM_TIPO $ 'PA' .and. ( Len(Alltrim(M->ZM_CODIGO)) == 5 .and. SubStr(M->ZM_CODIGO, 1, 2) $ 'RV' )
                 For nY := 1 To Len(oBrw2Sim:aCols)
                     nSomPer += oBrw2Sim:aCols[nY][4]
                 Next
                 If !nSomPer == 100
                    If nSomPer < 100
                       MsgStop("Percentual da fórmula MAIOR QUE 100%.", "Atenção...")
                       Return
                    ElseIf nSomPer < 100
                           MsgStop("Percentual da fórmula MENOR QUE 100%.", "Atenção...")
                           Return
                    Endif
                 Endif
              Endif
              //Verifica cadastro de operações.
              If Len(aResultO) == 0
                 If MsgYesNo("Atenção o cadastro de Operações não foi alterado. Deseja retornar? ", "Atenção...")
                    Return
                 Endif
              Endif
              //Verifica se for PI-Tinta se tem embalagens cadastradas
              If ( M->ZM_TIPO $ 'PI' .and. Len(Alltrim(M->ZM_CODIGO)) == 12 ) .or. (M->ZM_TIPO $ 'PA' .and. Len(Alltrim(M->ZM_CODIGO)) = 5 .and. SubStr(Alltrim(M->ZM_CODIGO), 1, 2) $ 'RV' ) //Somente para PIs Tintas ou Resinas
                 If Len(aResultE) == 0
                    MsgStop("Atenção esse tipo de produto requer cadastro para embalagens.", "Atenção...")
                    Return
                 Endif
              Endif
              //Verifica se previsão de témino está cadastrada
              If Empty(M->ZM_DTPREVI)
                 MsgStop("Faltou informar a previsão de término para essa simulação.", "Atenção...")
                 Return
              Endif
              //Gravar Simulação
              Begin Transaction
                    MsgRun(OemToAnsi('Gravando a Simulação........ Aguarde....'), '', {|| CursorWait(), fGravaSimulacao(), CursorArrow() } )
              End Transaction
              oDlg1Sim:End()
       ElseIf DELETASIM
              Begin Transaction
                    MsgRun(OemToAnsi('Excluindo a Simulação........ Aguarde....'), '', {|| CursorWait(), fGravaSimulacao(), CursorArrow() } )
              End Transaction
              oDlg1Sim:End()
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ TMPLIBMark() - Funcao para marcar o MsSelect
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function TMPLIBMark()
       //Local lDesMarca := TMPLIB->(IsMark("LIBMAR", cMarSimu))
       
       DbSelectArea("TMPLIB")
       nRegistr := Recno()
       lMarcado := TMPLIB->(Marked("LIBMAR"))
       cMarSimu := TMPLIB->LIBMAR
       DbGoTop()
       While !Eof()
             If nRegistr <> Recno()
                If lMarcado
                   RecLock("TMPLIB", .F.)
                      TMPLIB->LIBMAR := cMarSimu
                   MsUnLock()
                Else
                   RecLock("TMPLIB", .F.)
                      TMPLIB->LIBMAR := "  "
                   MsUnLock()
                Endif
             Endif
             DbSelectArea("TMPLIB")
             DbSkip()
       Enddo
       DbSelectArea("TMPLIB")
       DbGoTo(nRegistr)
       oBrw1Lib:oBrowse:Refresh(.t.)
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fGravaSimulacao() - Gravação da Simulação do Produto.
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fGravaSimulacao()
       Local nY
       If INCLUISIM
          //Gravação dos Itens
          DbSelectArea("SZN")
          For nY := 1 To Len(oBrw2Sim:aCols)
              If !oBrw2Sim:aCols[nY][noBrw2Sim + 1]
                 RecLock("SZN",.t.)
                    SZN->ZN_FILIAL  := xFilial("SZN")
                    SZN->ZN_CODIGO  := M->ZM_CODIGO
                    SZN->ZN_REVISAO := M->ZM_REVISAO
                    SZN->ZN_COMP    := oBrw2Sim:aCols[nY][1]
                    SZN->ZN_TRT     := oBrw2Sim:aCols[nY][3]
                    SZN->ZN_PERC    := oBrw2Sim:aCols[nY][4]
                    SZN->ZN_QUANT   := oBrw2Sim:aCols[nY][5]
                    SZN->ZN_PESESP  := oBrw2Sim:aCols[nY][7]
                    SZN->ZN_PERDA   := oBrw2Sim:aCols[nY][6]
                    SZN->ZN_INI     := dDataBase
                    SZN->ZN_FIM     := cTod("31/12/49")
                    SZN->ZN_FIXVAR  := "V"
                    SZN->ZN_REVINI  := ""
                    SZN->ZN_REVFIM  := "ZZZ"
                    SZN->ZN_OPERACA := Iif(M->ZM_TIPOPRO $ "PE", Posicione("SB1", 1, xFilial("SB1")+M->ZM_CODIGO, "B1_OPERPAD"), " ")
                 MsUnLock()
              Endif
          Next
          //Gravação do Cabeçalho
          DbSelectArea("SZM")
          RecLock("SZM", .t.)
             SZM->ZM_FILIAL  := xFilial("SZM")
             SZM->ZM_CODIGO  := M->ZM_CODIGO
             SZM->ZM_DESCRIC := M->ZM_DESCRIC
             SZM->ZM_RESPONS := M->ZM_RESPONS
             SZM->ZM_DTINCLU := M->ZM_DTINCLU
             SZM->ZM_REVISAO := M->ZM_REVISAO
             SZM->ZM_SOLICIT := M->ZM_SOLICIT
             SZM->ZM_PESESP  := nGet4Sim
             //SZM->ZM_PVC     := 
             //SZM->ZM_BRILHO  := 
             SZM->ZM_CATALIS := M->ZM_CATALIS
             SZM->ZM_RELCAT  := M->ZM_RELCAT
             SZM->ZM_REVISIN := Inverte(M->ZM_REVISAO)
             SZM->ZM_STATUS  := "EE"
             SZM->ZM_TIPOPRO := M->ZM_TIPOPRO
             SZM->ZM_TIPO    := M->ZM_TIPO
             SZM->ZM_LOCAL   := M->ZM_LOCAL
             SZM->ZM_UM      := M->ZM_UM
             SZM->ZM_ROTEIRO := M->ZM_ROTEIRO
             SZM->ZM_ID      := StrZero(SZM->(RecNo()), 6)
             SZM->ZM_SEQ     := '101'
             SZM->ZM_PADCOR  := M->ZM_PADCOR
             SZM->ZM_PCREVIS := M->ZM_PCREVIS
             SZM->ZM_DTPREVI := M->ZM_DTPREVI
             SZM->ZM_GRUPO2  := M->ZM_GRUPO2
             SZM->ZM_POSIPI  := Iif( Empty( Iif( Empty(M->ZM_POSIPI), Iif( Len(Alltrim(M->ZM_CODIGO)) == 12, Posicione( "SZ6", 1, xFilial("SZ6")+SubStr(Alltrim(M->ZM_CODIGO), 1, 3)+SubStr(Alltrim(M->ZM_CODIGO), 4, 2)+SubStr(Alltrim(M->ZM_CODIGO), 6, 2), "Z6_CLASFIS"), "99999999"), M->ZM_POSIPI) ), "99999999", Iif( Len(Alltrim(M->ZM_CODIGO)) == 12, Posicione( "SZ6", 1, xFilial("SZ6")+SubStr(Alltrim(M->ZM_CODIGO), 1, 3)+SubStr(Alltrim(M->ZM_CODIGO), 4, 2)+SubStr(Alltrim(M->ZM_CODIGO), 6, 2), "Z6_CLASFIS"), "99999999") )
             SZM->ZM_EX_NCM  := Iif( Empty( Iif( Empty(M->ZM_POSIPI), Iif( Len(Alltrim(M->ZM_CODIGO)) == 12, Posicione( "SZ6", 1, xFilial("SZ6")+SubStr(Alltrim(M->ZM_CODIGO), 1, 3)+SubStr(Alltrim(M->ZM_CODIGO), 4, 2)+SubStr(Alltrim(M->ZM_CODIGO), 6, 2), "Z6_EX_NCM" ), "@!"      ), M->ZM_EX_NCM) ), "@!",       Iif( Len(Alltrim(M->ZM_CODIGO)) == 12, Posicione( "SZ6", 1, xFilial("SZ6")+SubStr(Alltrim(M->ZM_CODIGO), 1, 3)+SubStr(Alltrim(M->ZM_CODIGO), 4, 2)+SubStr(Alltrim(M->ZM_CODIGO), 6, 2), "Z6_EX_NCM" ), "@!") )
          MsUnLock()
          //Gravação do Histórico
          DbSelectArea("SZT")
          RecLock("SZT", .t.)
             SZT->ZT_FILIAL  := xFilial("SZT")
             SZT->ZT_ID      := SZM->ZM_ID
             SZT->ZT_PROCESS := "SI"
             SZT->ZT_STATUS  := "EE"
             SZT->ZT_LOG     := "Inclusão de simulação. "+Chr(13)+Chr(10)+M->ZM_MOTIVO
             SZT->ZT_USUARIO := cUserName
             SZT->ZT_DATAGER := dDataBase
             SZT->ZT_HORAGER := Time()
             SZT->ZT_SEQ     := "101"
          MsUnLock()
          //Gravação das Operações
          If Len(aResultO) > 0
             DbSelectArea("ZZH")
             For nY := 1 To Len(aResultO)
                 RecLock("ZZH", .t.)
                    ZZH->ZZH_FILIAL := xFilial("ZZH")
                    ZZH->ZZH_CODIGO := aResultO[nY][13]
                    ZZH->ZZH_PRODUT := M->ZM_CODIGO
                    ZZH->ZZH_REVISA := M->ZM_REVISA
                    ZZH->ZZH_OPERAC := aResultO[nY][01]
                    ZZH->ZZH_RECURS := aResultO[nY][02]
                    ZZH->ZZH_FERRAM := aResultO[nY][03]
                    ZZH->ZZH_LINHAP := ""
                    ZZH->ZZH_TPLINH := aResultO[nY][04]
                    ZZH->ZZH_DESCRI := aResultO[nY][05]
                    ZZH->ZZH_MAOOBR := aResultO[nY][06]
                    ZZH->ZZH_SETUP  := aResultO[nY][07]
                    ZZH->ZZH_LOTEPA := aResultO[nY][08]
                    ZZH->ZZH_TEMPAD := aResultO[nY][09]
                    ZZH->ZZH_TPOPER := aResultO[nY][10]
                    ZZH->ZZH_CTTRAB := aResultO[nY][11]
                    ZZH->ZZH_CODESP := MSMM(ZZH->ZZH_CODESP, , , aResultO[nY][12], 1, , , "ZZH", "ZZH_CODESP")
                 MsUnLock()
             Next
          Endif
          //Gravação das Embalagens
          If Len(aResultE) > 0
             DbSelectArea("SZP")
             For nY := 1 To Len(aResultE)
                 RecLock("SZP", .t.)
                    SZP->ZP_FILIAL  := xFilial("SZP")
                    SZP->ZP_CODIGO  := M->ZM_CODIGO
                    SZP->ZP_REVISAO := M->ZM_REVISAO
                    SZP->ZP_EMB     := aResultE[nY][1]
                 MsUnLock()
             Next
          Endif
          //Gravação dos Ensaios
          If Len(aResultA) > 0
             DbSelectArea("ZZD")
             For nY := 1 To Len(aResultA)
                 RecLock("ZZD", .t.)
                    ZZD->ZZD_FILIAL := aResultA[nY][01]
                    ZZD->ZZD_CODIGO := aResultA[nY][02]
                    ZZD->ZZD_REVISA := aResultA[nY][03]
                    ZZD->ZZD_SEQAT  := aResultA[nY][04]
                    ZZD->ZZD_SEQ    := aResultA[nY][05]
                    ZZD->ZZD_ENSAIO := aResultA[nY][06]
                    ZZD->ZZD_CARTA  := aResultA[nY][08]
                    ZZD->ZZD_MINMAX := aResultA[nY][09]
                    ZZD->ZZD_LIE    := aResultA[nY][10]
                    ZZD->ZZD_NOMINA := aResultA[nY][11]
                    ZZD->ZZD_LIS    := aResultA[nY][12]
                    ZZD->ZZD_TEXTO  := aResultA[nY][13]
                    ZZD->ZZD_DATAME := aResultA[nY][14]
                    ZZD->ZZD_HORAME := aResultA[nY][15]
                    ZZD->ZZD_ENSR   := aResultA[nY][16]
                    ZZD->ZZD_MEDNUM := aResultA[nY][18]
                    ZZD->ZZD_MEDTXT := aResultA[nY][19]
                    ZZD->ZZD_RESULT := aResultA[nY][20]
                 MsUnLock()
             Next
          Endif
          If Len(aResultX) > 0
             DbSelectArea("SZT")
             DbSetOrder(2)
             DbSeek(xFilial("SZT")+M->ZM_ID+'SI'+'AT', .T.)
             If Found()
                RecLock("SZT", .t.)
                   SZT->ZT_LOG     := aResultX[1][5]
                   SZT->ZT_USUARIO := aResultX[1][4]
                   SZT->ZT_DATAGER := aResultX[1][2]
                   SZT->ZT_HORAGER := aResultX[1][3]
                   SZT->ZT_SEQ     := StrZero(aResultX[1][1], 3)
                MsUnLock()
             Else
                RecLock("SZT", .t.)
                   SZT->ZT_FILIAL  := xFilial("SZT")
                   SZT->ZT_ID      := M->ZM_ID
                   SZT->ZT_PROCESS := "SI"
                   SZT->ZT_STATUS  := "AT"
                   SZT->ZT_LOG     := aResultX[1][5]
                   SZT->ZT_USUARIO := aResultX[1][4]
                   SZT->ZT_DATAGER := aResultX[1][2]
                   SZT->ZT_HORAGER := aResultX[1][3]
                   SZT->ZT_SEQ     := StrZero(aResultX[1][1], 3)
                MsUnLock()
             Endif
          Endif
       ElseIf ALTERASIM
              //Gravação dos Itens
                //1º) Deleta Itens já gravados
              DbSelectArea("SZN")
              DbSetOrder(2)
              DbSeek(xFilial("SZN")+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
              If Found()
                 While !Eof() .and. Alltrim(SZN->ZN_CODIGO) == Alltrim(M->ZM_CODIGO) .and. SZN->ZN_REVISAO == M->ZM_REVISAO
                       RecLock("SZN", .f., .t.)
                          DbDelete()
                       MsUnLock()
                       DbSelectArea("SZN")
                       DbSkip()
                 Enddo
              EndIf
                //2º) Grava novos Itens
              DbSelectArea("SZN")
              For nY := 1 To Len(oBrw2Sim:aCols)
                  If !oBrw2Sim:aCols[nY][noBrw2Sim + 1]
                     RecLock("SZN",.t.)
                        SZN->ZN_FILIAL  := xFilial("SZN")
                        SZN->ZN_CODIGO  := M->ZM_CODIGO
                        SZN->ZN_REVISAO := M->ZM_REVISAO
                        SZN->ZN_COMP    := oBrw2Sim:aCols[nY][1]
                        SZN->ZN_TRT     := oBrw2Sim:aCols[nY][3]
                        SZN->ZN_PERC    := oBrw2Sim:aCols[nY][4]
                        SZN->ZN_QUANT   := oBrw2Sim:aCols[nY][5]
                        SZN->ZN_PESESP  := oBrw2Sim:aCols[nY][7]
                        SZN->ZN_PERDA   := oBrw2Sim:aCols[nY][6]
                        SZN->ZN_INI     := dDataBase
                        SZN->ZN_FIM     := cTod("31/12/49")
                        SZN->ZN_FIXVAR  := "V"
                        SZN->ZN_REVINI  := ""
                        SZN->ZN_REVFIM  := "ZZZ"
                        SZN->ZN_OPERACA := Iif(M->ZM_TIPOPRO $ "PE", Posicione("SB1", 1, xFilial("SB1")+M->ZM_CODIGO, "B1_OPERPAD"), " ")
                     MsUnLock()
                  Endif
              Next
              //Gravação do Cabeçalho
                //Somente dos campos marcados para alteração
              DbSelectArea("SZM")
              DbSetOrder(1)
              DbSeek(xFilial("SZM")+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
              If Found()
                 RecLock("SZM", .f.)
                    SZM->ZM_DESCRIC := M->ZM_DESCRIC
                    SZM->ZM_CATALIS := M->ZM_CATALIS
                    SZM->ZM_RELCAT  := M->ZM_RELCAT
                    SZM->ZM_SOLICIT := M->ZM_SOLICIT
                    SZM->ZM_RESPONS := cUserName
                    SZM->ZM_GRUPO2  := M->ZM_GRUPO2
                    SZM->ZM_PESESP  := nGet4Sim
                    SZM->ZM_POSIPI  := Iif( Empty( Iif( Empty(M->ZM_POSIPI), Iif( Len(Alltrim(M->ZM_CODIGO)) == 12, Posicione( "SZ6", 1, xFilial("SZ6")+SubStr(Alltrim(M->ZM_CODIGO), 1, 3)+SubStr(Alltrim(M->ZM_CODIGO), 4, 2)+SubStr(Alltrim(M->ZM_CODIGO), 6, 2), "Z6_CLASFIS"), "99999999"), M->ZM_POSIPI) ), "99999999", Iif( Len(Alltrim(M->ZM_CODIGO)) == 12, Posicione( "SZ6", 1, xFilial("SZ6")+SubStr(Alltrim(M->ZM_CODIGO), 1, 3)+SubStr(Alltrim(M->ZM_CODIGO), 4, 2)+SubStr(Alltrim(M->ZM_CODIGO), 6, 2), "Z6_CLASFIS"), "99999999") )
                    SZM->ZM_EX_NCM  := Iif( Empty( Iif( Empty(M->ZM_POSIPI), Iif( Len(Alltrim(M->ZM_CODIGO)) == 12, Posicione( "SZ6", 1, xFilial("SZ6")+SubStr(Alltrim(M->ZM_CODIGO), 1, 3)+SubStr(Alltrim(M->ZM_CODIGO), 4, 2)+SubStr(Alltrim(M->ZM_CODIGO), 6, 2), "Z6_EX_NCM" ), "@!"      ), M->ZM_EX_NCM) ), "@!"      , Iif( Len(Alltrim(M->ZM_CODIGO)) == 12, Posicione( "SZ6", 1, xFilial("SZ6")+SubStr(Alltrim(M->ZM_CODIGO), 1, 3)+SubStr(Alltrim(M->ZM_CODIGO), 4, 2)+SubStr(Alltrim(M->ZM_CODIGO), 6, 2), "Z6_EX_NCM" ), "@!") )
                 MsUnLock()
              Endif
              //Gravação do Histórico
              DbSelectArea("SZT")
              RecLock("SZT", .t.)
                 SZT->ZT_FILIAL  := xFilial("SZT")
                 SZT->ZT_ID      := SZM->ZM_ID
                 SZT->ZT_PROCESS := "SI"
                 SZT->ZT_STATUS  := M->ZM_STATUS
                 SZT->ZT_LOG     := "Manutenção da fórmula "+Alltrim(M->ZM_CODIGO)+" / "+M->ZM_REVISAO+"  -  "+Alltrim(M->ZM_DESCRIC)+"."
                 SZT->ZT_USUARIO := cUserName
                 SZT->ZT_DATAGER := dDataBase
                 SZT->ZT_HORAGER := Time()
                 SZT->ZT_SEQ     := "101"
              MsUnLock()
              //Gravação das Operações
              If Len(aResultO) > 0
                 DbSelectArea("ZZH")
                 For nY := 1 To Len(aResultO)
                     RecLock("ZZH", .t.)
                        ZZH->ZZH_FILIAL := xFilial("ZZH")
                        ZZH->ZZH_CODIGO := aResultO[nY][13]
                        ZZH->ZZH_PRODUT := M->ZM_CODIGO
                        ZZH->ZZH_REVISA := M->ZM_REVISAO
                        ZZH->ZZH_OPERAC := aResultO[nY][01]
                        ZZH->ZZH_RECURS := aResultO[nY][02]
                        ZZH->ZZH_FERRAM := aResultO[nY][03]
                        ZZH->ZZH_LINHAP := ""
                        ZZH->ZZH_TPLINH := aResultO[nY][04]
                        ZZH->ZZH_DESCRI := aResultO[nY][05]
                        ZZH->ZZH_MAOOBR := aResultO[nY][06]
                        ZZH->ZZH_SETUP  := aResultO[nY][07]
                        ZZH->ZZH_LOTEPA := aResultO[nY][08]
                        ZZH->ZZH_TEMPAD := aResultO[nY][09]
                        ZZH->ZZH_TPOPER := aResultO[nY][10]
                        ZZH->ZZH_CTTRAB := aResultO[nY][11]
                        ZZH->ZZH_CODESP := MSMM(ZZH->ZZH_CODESP, , , aResultO[nY][12], 1, , , "ZZH", "ZZH_CODESP")
                     MsUnLock()
                 Next
              Endif
              //Gravação das Embalagens
              If Len(aResultE) > 0
                 DbSelectArea("SZP")
                 For nY := 1 To Len(aResultE)
                     DbSelectArea("SZP")
                     DbSetOrder(2)
                     DbSeek(xFilial("SZP")+M->ZM_CODIGO+M->ZM_REVISAO+aResultE[nY][1], .t.)
                     If Found()
                        RecLock("SZP", .f.)
                           SZP->ZP_EMB     := aResultE[nY][1]
                     Else
                        RecLock("SZP", .t.)
                           SZP->ZP_FILIAL  := xFilial("SZP")
                           SZP->ZP_CODIGO  := M->ZM_CODIGO
                           SZP->ZP_REVISAO := M->ZM_REVISAO
                           SZP->ZP_EMB     := aResultE[nY][1]
                     Endif
                     MsUnLock()
                 Next
              Endif
              //Gravação dos Ensaios
              If Len(aResultA) > 0
                 DbSelectArea("ZZD")
                 DbSetOrder(1)
                 DbSeek(xFilial('ZZD')+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
                 If Found()
                    While !Eof() .and. ZZD->ZZD_CODIGO == M->ZM_CODIGO .and. ZZD->ZZD_REVISAO == M->ZM_REVISAO
                          RecLock("ZZD", .f.)
                             DbDelete()
                          MsUnLock()
                          DbSelectArea('ZZD')
                          DbSkip()
                    EndDo
                 Endif
                 DbSelectArea("ZZD")
                 For nY := 1 To Len(aResultA)
                     RecLock("ZZD", .t.)
                        ZZD->ZZD_FILIAL := aResultA[nY][01]
                        ZZD->ZZD_CODIGO := aResultA[nY][02]
                        ZZD->ZZD_REVISA := aResultA[nY][03]
                        ZZD->ZZD_SEQAT  := aResultA[nY][04]
                        ZZD->ZZD_SEQ    := aResultA[nY][05]
                        ZZD->ZZD_ENSAIO := aResultA[nY][06]
                        ZZD->ZZD_CARTA  := aResultA[nY][08]
                        ZZD->ZZD_MINMAX := aResultA[nY][09]
                        ZZD->ZZD_LIE    := aResultA[nY][10]
                        ZZD->ZZD_NOMINA := aResultA[nY][11]
                        ZZD->ZZD_LIS    := aResultA[nY][12]
                        ZZD->ZZD_TEXTO  := aResultA[nY][13]
                        ZZD->ZZD_DATAME := aResultA[nY][14]
                        ZZD->ZZD_HORAME := aResultA[nY][15]
                        ZZD->ZZD_ENSR   := aResultA[nY][16]
                        ZZD->ZZD_MEDNUM := aResultA[nY][18]
                        ZZD->ZZD_MEDTXT := aResultA[nY][19]
                        ZZD->ZZD_RESULT := aResultA[nY][20]
                     MsUnLock()
                 Next
              Endif
              If Len(aResultX) > 0
                 DbSelectArea("SZT")
                 DbSetOrder(2)
                 DbSeek(xFilial("SZT")+M->ZM_ID+'SI'+'AT', .T.)
                 If Found()
                    RecLock("SZT", .F.)
                       If Empty(aResultX[1][4])
                          DbDelete()
                       Else
                          SZT->ZT_LOG     := aResultX[1][5]
                          SZT->ZT_USUARIO := aResultX[1][4]
                          SZT->ZT_DATAGER := aResultX[1][2]
                          SZT->ZT_HORAGER := aResultX[1][3]
                          SZT->ZT_SEQ     := StrZero(aResultX[1][1], 3)
                       Endif
                    MsUnLock()
                 Else
                    RecLock("SZT", .t.)
                       SZT->ZT_FILIAL  := xFilial("SZT")
                       SZT->ZT_ID      := M->ZM_ID
                       SZT->ZT_PROCESS := "SI"
                       SZT->ZT_STATUS  := "AT"
                       SZT->ZT_LOG     := aResultX[1][5]
                       SZT->ZT_USUARIO := aResultX[1][4]
                       SZT->ZT_DATAGER := aResultX[1][2]
                       SZT->ZT_HORAGER := aResultX[1][3]
                       SZT->ZT_SEQ     := StrZero(aResultX[1][1], 3)
                    MsUnLock()
                 Endif
              Endif
       ElseIf DELETASIM
              //Excluir SZT
              //DbSelectArea("SZT")
              //DbSetOrder(1)
              //DbSeek(xFilial("SZT")+M->ZM_ID, .t.)
              //If Found()
              //   While !Eof() .and. SZT->ZT_ID == M->ZM_ID
              //         RecLock("SZT", .f.)
              //            DbDelete()
              //         MsUnLock()
              //         DbSelectArea("SZT")
              //         DbSkip()
              //  EndDo
              //Endif
              //Excluir SZP
              //DbSelectArea("SZP")
              //DbSetOrder(1)
              //DbSeek(xFilial("SZP")+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
              //If Found()
              //   While !Eof() .and. SZP->ZP_CODIGO == M->ZM_CODIGO .and. SZP->ZP_REVISAO == M->ZM_REVISAO
              //         RecLock("SZP", .f.)
              //            DbDelete()
              //         MsUnLock()
              //         DbSelectArea("SZP")
              //         DbSkip()
              //   EndDo
              //EndIf
              //Excluir ZZH
              //DbSelectArea("ZZH")
              //DbSetOrder(2)
              //DbSeek(xFilial("ZZH")+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
              //If Found()
              //   While !Eof() .and. ZZH->ZZH_PRODUT == M->ZM_CODIGO .and. ZZH->ZZH_REVISA == M->ZM_REVISAO
              //         RecLock("ZZH", .f.)
              //            DbDelete()
              //         MsUnLock()
              //        DbSelectArea("ZZH")
              //         DbSkip()
              //   EndDo
              //EndIf
              //Excluir SZN
              //DbSelectArea("SZN")
              //DbSetOrder(2)
              //DbSeek(xFilial("SZN")+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
              //If Found()
              //   While !Eof() .and. SZN->ZN_CODIGO == M->ZM_CODIGO .and. SZN->ZN_REVISAO == M->ZM_REVISAO
              //         RecLock("SZN", .f.)
              //            DbDelete()
              //         MsUnLock()
              //         DbSelectArea("SZN")
              //         DbSkip()
              //   EndDo
              //EndIf
              //Excluir SZM
              DbSelectArea("SZM")
              DbSetOrder(1)
              DbSeek(xFilial("SZM")+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
              If Found()
                 While !Eof() .and. SZM->ZM_CODIGO == M->ZM_CODIGO .and. SZM->ZM_REVISAO == M->ZM_REVISAO
                       RecLock("SZM", .f.)
                          SZM->ZM_STATUS := 'RX'
                       MsUnLock()
                       DbSelectArea("SZM")
                       DbSkip()
                 EndDo
              EndIf
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1Sim() - Cria temporario para o Alias: TMPVIG
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1Sim()
       Local aFds := {}
       //Local cTmp

       aAdd( aFds , {"VIGCOM", "C", 015, 000} ) //Componente
       aAdd( aFds , {"VIGDES", "C", 030, 000} ) //Descrição
       aAdd( aFds , {"VIGTRT", "C", 003, 000} ) //Sequencia
       aAdd( aFds , {"VIGPER", "N", 007, 003} ) //Percentual
       aAdd( aFds , {"VIGQTD", "N", 010, 006} ) //Quantidade
       aAdd( aFds , {"VIGPRD", "N", 005, 002} ) //Perda
       aAdd( aFds , {"VIGPES", "N", 009, 006} ) //Peso específico
       aAdd( aFds , {"VIGCUN", "N", 007, 003} ) //Custo Unitário
       aAdd( aFds , {"VIGCRE", "N", 007, 003} ) //Custo Reais
       aAdd( aFds , {"VIGCDO", "N", 007, 003} ) //Custo Dolar

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cTmp := CriaTrab( , .F. )
       //dbcreate(cTmp+".dbf", aFds, "DBFCDXADS")
       //Use (cTmp+".Dbf") Alias TMPVIG VIA "DBFCDXADS" New Exclusive
       //DbCreateIndex(cTmp+"_1.cdx", "VIGTRT+VIGCOM", {||"VIGTRT+VIGCOM"} )
       //DbClearInd()
       //DbSetIndex(cTmp+"_1")

       oTempTbl01 := FWTemporaryTable():New( "TMPVIG" )
       oTempTbl01:SetFields( aFds )
       oTempTbl01:AddIndex( "cInd01", { "VIGTRT", "VIGCOM" } )
       oTempTbl01:Create()
       /********************************************************************************************************************************/
       DbSetOrder(1)
       
       nGet1Sim := 0
       nGet2Sim := 0
       nGet5Sim := 0
       nGet6Sim := 0
       DbSelectArea("SG1")
       DbSetOrder(1)
       DbSeek(xFilial("SG1")+M->ZM_CODIGO, .t.)
       If Found()
          While !Eof() .and. SG1->G1_COD == M->ZM_CODIGO
                RecLock("TMPVIG", .t.)
                   TMPVIG->VIGCOM := SG1->G1_COMP
                   TMPVIG->VIGDES := Posicione('SB1', 1, xFilial('SB1')+SG1->G1_COMP, "B1_DESC")
                   TMPVIG->VIGTRT := SG1->G1_TRT
                   TMPVIG->VIGPER := SG1->G1_PERC
                   TMPVIG->VIGQTD := SG1->G1_QUANT
                   TMPVIG->VIGPRD := SG1->G1_PERDA
                   TMPVIG->VIGPES := Posicione('SB1', 1, xFilial('SB1')+SG1->G1_COMP, "B1_PESOESP")
                   TMPVIG->VIGCUN := Iif( Posicione("SB1", 1, xFilial('SB1')+SG1->G1_COMP, "B1_TIPO") $ 'MP', Posicione("SB1", 1, xFilial('SB1')+SG1->G1_COMP, "B1_UPRC"), U_CustoPro(SG1->G1_COMP) )
                   TMPVIG->VIGCRE := ( TMPVIG->VIGCUN * ( ( TMPVIG->VIGQTD * ( TMPVIG->VIGPRD / 100 ) ) + TMPVIG->VIGQTD ) )
                   TMPVIG->VIGCDO := (                  ( ( TMPVIG->VIGQTD * ( TMPVIG->VIGPRD / 100 ) ) + TMPVIG->VIGQTD ) ) / nDolarDia
                   nGet1Sim += Iif(M->ZM_TIPO $ 'PA' .and. !M->ZM_UM $ 'K .L ', 0, TMPVIG->VIGPER )                                //Percentual da fórmula
                   nGet2Sim += Iif(M->ZM_TIPO $ 'PA' .and. !M->ZM_UM $ 'K .L ', 0, Round( (TMPVIG->VIGPER / TMPVIG->VIGPES), 6 ) ) //Peso Específico
                   nGet5Sim += Round( TMPVIG->VIGCRE, 3 )
                   nGet6Sim += Round( TMPVIG->VIGCDO, 3 )
                MsUnLock()
                DbSelectArea("SG1")
                DbSkip()
          EndDo
          nGet2Sim := Iif(M->ZM_TIPO $ 'PA' .and. !M->ZM_UM $ 'K .L ', 1, (100 / nGet2Sim) ) //Peso Específico
          If !(cNumEmp == "01010104")
             If M->ZM_TIPO $ 'PI'
                If 'K' $ M->ZM_UM
                   //%Fórmula
                   oSay3Sim:Refresh()
                   oGet1Sim:Refresh()
                   //P.Especifico
                   oSay4Sim:Refresh()
                   oGet2Sim:Refresh()
                   //Custo(R$/K)
                   cSay7Sim := "Custo(R$/K):"
                   oSay7Sim:Refresh()
                   oGet5Sim:Refresh()
                   //Custo(U$/K)
                   cSay8Sim := "Custo(U$/K):"
                   oSay8Sim:Refresh()
                   oGet6Sim:Refresh()
                   //
                   oSayBSim:lVisible := .f.
                   oGet7Sim:lVisible := .f.
                   //Imagem (Comparação do Custo(R$/K))
                ElseIf 'L' $ M->ZM_UM
                       //%Fórmula
                       oSay3Sim:Refresh()
                       oGet1Sim:Refresh()
                       //P.Especifico
                       oSay4Sim:Refresh()
                       oGet2Sim:Refresh()
                       //Custo(R$/L)
                       cSay7Sim := "Custo(R$/L):"
                       oSay7Sim:Refresh()
                       oGet5Sim:Refresh()
                       //Custo(U$/K)
                       cSay8Sim := "Custo(U$/K):"
                       oSay8Sim:Refresh()
                       oGet6Sim:Refresh()
                       //Custo(R$/K)
                       oSayBSim:lVisible := .t.
                       cSayBSim := "Custo(R$/K):"
                       oSayBSim:Refresh()
                       oGet7Sim:lVisible := .t.
                       nGet7Sim := Round( ( 1 / nGet2Sim ) * nGet5Sim, 3 )
                       oGet7Sim:Refresh()
                       //Imagem (Comparação do Custo(R$/L))
                Endif
             ElseIf M->ZM_TIPO $ 'PA'
                    //%Fórmula
                    oSay3Sim:Refresh()
                    nGet1Sim := 0
                    oGet1Sim:Refresh()
                    //P.Especifico
                    oSay4Sim:Refresh()
                    nGet2Sim := 0
                    oGet2Sim:Refresh()
                    //Custo(R$/L)
                    cSay7Sim := "Custo(R$/L):"
                    oSay7Sim:Refresh()
                    oGet5Sim:Refresh()
                    //Custo(U$/K)
                    cSay8Sim := "Custo(U$/K):"
                    oSay8Sim:Refresh()
                    oGet6Sim:Refresh()
                    //Preço(R$/K)
                    oSayBSim:lVisible := .t.
                    cSayBSim := "Preço:"
                    oSayBSim:Refresh()
                    aPreco := fCalculaPr(nGet5Sim, "VIG", "M")
                    nGet7Sim := aPreco[1]
                    oGet7Sim:lVisible := .t.
                    //Imagem (Comparação do Custo(R$/L))
             Endif
          Else
          If 'K' $ M->ZM_UM
             cSay7Sim := "Custo(R$/K):"
             oSay7Sim:Refresh()
             If M->ZM_TIPO $ 'PA'
                cSayBSim := "Preço:"
                oSayBSim:lVisible := .t.
                aPreco := fCalculaPr(nGet5Sim, "VIG", "M")
                nGet7Sim := aPreco[1]
                oGet7Sim:lVisible := .t.
             Endif
          ElseIf 'UN' $ M->ZM_UM
                 cSay7Sim := "Custo(R$/L):"
                 oSay7Sim:Refresh()
                 If M->ZM_TIPO $ 'PA'
                    cSayBSim := "Preço:"
                    oSayBSim:lVisible := .t.
                    aPreco := fCalculaPr(nGet5Sim, "VIG", "M")
                    nGet7Sim := aPreco[1]
                    oGet7Sim:lVisible := .t.
                 Endif
          Else
             nGet7Sim := Round( ( 1 / nGet2Sim ) * nGet5Sim, 3 )
          Endif
          Endif
          If QtdComp(Round(nGet2Sim, 5)) <> QtdComp(Round(Posicione('SB1', 1, xFilial('SB1')+M->ZM_CODIGO, "B1_PESOESP"), 5))
             cSayFSim := "DIVERGÊNCIA: P.Específico"
          Endif
       Else //Produto Novo
          If 'K' $ M->ZM_UM .or. 'L' $ M->ZM_UM
             cSay7Sim := "Custo(R$/K):"
             oSay7Sim:Refresh()
             If M->ZM_TIPO $ 'PA'
                cSayBSim := "Preço:"
                oSayBSim:lVisible := .t.
                oGet7Sim:lVisible := .t.
             Endif
          ElseIf 'UN' $ M->ZM_UM
                 cSay7Sim := "Custo(R$/L):"
                 oSay7Sim:Refresh()
                 If M->ZM_TIPO $ 'PA'
                    cSayBSim := "Preço:"
                    oSayBSim:lVisible := .t.
                    oGet7Sim:lVisible := .t.
                 Endif
          Endif
       Endif
       DbSelectArea("TMPVIG")
       DbGoTop()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrw2Sim() - Monta aHeader da MsNewGetDados para o Alias: TMPREV
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrw2Sim()
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SZN")
       While !Eof() .and. SX3->X3_ARQUIVO == "SZN"
             If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
                If Alltrim(SX3->X3_CAMPO) $ 'ZN_COMP'
                       noBrw2Sim++
                       aAdd(aHoBrw2Sim, {"Componente"   , SX3->X3_CAMPO, ""            , SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT } )
                ElseIf Alltrim(SX3->X3_CAMPO) $ 'ZN_DESC'
                       noBrw2Sim++
                       aAdd(aHoBrw2Sim, {"Descrição"    , SX3->X3_CAMPO, ""            , SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT } )
                ElseIf Alltrim(SX3->X3_CAMPO) $ 'ZN_TRT'
                       noBrw2Sim++
                       aAdd(aHoBrw2Sim, {"Seq."         , SX3->X3_CAMPO, ""            , SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT } )
                ElseIf Alltrim(SX3->X3_CAMPO) $ 'ZN_PERC'
                       noBrw2Sim++
                       aAdd(aHoBrw2Sim, {"% Formula"    , SX3->X3_CAMPO, "@E 999.999"  , SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT } )
                ElseIf Alltrim(SX3->X3_CAMPO) $ 'ZN_QUANT'
                       noBrw2Sim++
                       aAdd(aHoBrw2Sim, {"Quantidade"   , SX3->X3_CAMPO, "@E 99.999999", SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT } )
                ElseIf Alltrim(SX3->X3_CAMPO) $ 'ZN_PERDA'
                       noBrw2Sim++
                       aAdd(aHoBrw2Sim, {"Perda"        , SX3->X3_CAMPO, "@E 99.99"    , SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT } )
                ElseIf Alltrim(SX3->X3_CAMPO) $ 'ZN_PESESP'
                       noBrw2Sim++
                       aAdd(aHoBrw2Sim, {"P. Específico", SX3->X3_CAMPO, "@E 9.999999" , SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT } )
                ElseIf Alltrim(SX3->X3_CAMPO) $ 'ZN_CUSTOUN'
                       noBrw2Sim++
                       aAdd(aHoBrw2Sim, {"C. Unit."     , SX3->X3_CAMPO, "@E 9,999.999", SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT } )
                ElseIf Alltrim(SX3->X3_CAMPO) $ 'ZN_CUSTORE'
                       noBrw2Sim++
                       aAdd(aHoBrw2Sim, {"C. R$"        , SX3->X3_CAMPO, "@E 9,999.999", SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT } )
                ElseIf Alltrim(SX3->X3_CAMPO) $ 'ZN_CUSTODO'
                       noBrw2Sim++
                       aAdd(aHoBrw2Sim, {"C. U$"        , SX3->X3_CAMPO, "@E 9,999.999", SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT } )
                Endif
             EndIf
             DbSkip()
       EndDo*/
       DbSelectArea( _cAliasSX3 )
       DbSetOrder(1)
       DbSeek("SZN")
       While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SZN"
             If X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL )
                If Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZN_COMP'
                       noBrw2Sim++
                       aAdd( aHoBrw2Sim, {"Componente"   , ( _cAliasSX3 )->( X3_CAMPO ), ""            , ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_F3 ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
                ElseIf Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZN_DESC'
                       noBrw2Sim++
                       aAdd( aHoBrw2Sim, {"Descrição"    , ( _cAliasSX3 )->( X3_CAMPO ), ""            , ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_F3 ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
                ElseIf Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZN_TRT'
                       noBrw2Sim++
                       aAdd( aHoBrw2Sim, {"Seq."         , ( _cAliasSX3 )->( X3_CAMPO ), ""            , ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_F3 ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
                ElseIf Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZN_PERC'
                       noBrw2Sim++
                       aAdd( aHoBrw2Sim, {"% Formula"    , ( _cAliasSX3 )->( X3_CAMPO ), "@E 999.999"  , ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_F3 ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
                ElseIf Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZN_QUANT'
                       noBrw2Sim++
                       aAdd( aHoBrw2Sim, {"Quantidade"   , ( _cAliasSX3 )->( X3_CAMPO ), "@E 99.999999", ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_F3 ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
                ElseIf Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZN_PERDA'
                       noBrw2Sim++
                       aAdd( aHoBrw2Sim, {"Perda"        , ( _cAliasSX3 )->( X3_CAMPO ), "@E 99.99"    , ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_F3 ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
                ElseIf Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZN_PESESP'
                       noBrw2Sim++
                       aAdd( aHoBrw2Sim, {"P. Específico", ( _cAliasSX3 )->( X3_CAMPO ), "@E 9.999999" , ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_F3 ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
                ElseIf Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZN_CUSTOUN'
                       noBrw2Sim++
                       aAdd( aHoBrw2Sim, {"C. Unit."     , ( _cAliasSX3 )->( X3_CAMPO ), "@E 9,999.999", ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_F3 ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
                ElseIf Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZN_CUSTORE'
                       noBrw2Sim++
                       aAdd( aHoBrw2Sim, {"C. R$"        , ( _cAliasSX3 )->( X3_CAMPO ), "@E 9,999.999", ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_F3 ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
                ElseIf Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZN_CUSTODO'
                       noBrw2Sim++
                       aAdd( aHoBrw2Sim, {"C. U$"        , ( _cAliasSX3 )->( X3_CAMPO ), "@E 9,999.999", ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_F3 ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
                Endif
             EndIf
             DbSkip()
       EndDo
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrw2Sim() - Monta aCols da MsNewGetDados para o Alias: TMPREV
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrw2Sim()
       //Local aAux    := {}
       Local nPosCom := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_COMP"    } )
       //Local nPosFor := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_PERC"    } )
       Local nPosQtd := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_QUANT"   } )
       Local nPosPer := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_PERDA"   } )
       //Local nPosPEs := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_PESESP"  } )
       Local nPosCUn := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_CUSTOUN" } )
       Local nPosCRe := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_CUSTORE" } )
       Local nPosCDo := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_CUSTODO" } )
       Local nY, nI
       If SubStr(cSayPRNE, 1, 2) $ 'PN'
          If lCopyFor
             nAjuSeq := 1 //Ajusta sequencia da fórmula
             cQry1 := ""
             cQry1 += "SELECT * "
             cQry1 += "FROM SZN"+SubStr(cEmprFili, 1, 2)+"0 SZN WITH (NOLOCK) "
             cQry1 += "WHERE SZN.ZN_FILIAL  = '"+SubStr(cEmprFili, 3, 2)+"' "
             cQry1 += "  AND SZN.D_E_L_E_T_ = '' "
             cQry1 += "  AND SZN.ZN_CODIGO  = '"+cCodCopy+"' "
             cQry1 += "  AND SZN.ZN_REVISAO = '"+cRevCopy+"' "
             cQry1 += "ORDER BY SZN.ZN_REVISAO DESC "
             TCQuery cQry1 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             DbGoTop()
             While !Eof()
                   //Verifica se existe a matéria prima no cadastro
                   DbSelectArea("SB1")
                   DbSetOrder(1)
                   DbSeek(xFilial("SB1")+TCQ->ZN_COMP, .t.)
                   If Found()
                      If SB1->B1_TIPO $ 'PI'
                         DbSelectArea("SG1")
                         DbSetOrder(1)
                         DbSeek(xFilial("SG1")+TCQ->ZN_COMP, .t.)
                         If !Found()
                            MsgStop("Atenção, esse produto intermediário não existe no cadastro de Estruturas: "+TCQ->ZN_COMP, "Verifique antes de continuar...")
                            Return(.f.)
                         Endif
                      Endif
                   Else
                      MsgStop("Atenção, essa matéria prima não existe no cadastro de Produtos: "+Alltrim(TCQ->ZN_COMP), "Verifique antes de continuar...")
                      Return(.f.)
                   Endif
                   aAdd(aCoBrw2Sim, Array(noBrw2Sim + 1))
                   For nY := 1 To noBrw2Sim
                       If !aHoBrw2Sim[nY][10] $ 'V'
                          If Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_PESESP'
                             aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := Posicione('SB1', 1, xFilial('SB1')+aCoBrw2Sim[Len(aCoBrw2Sim)][nPosCom], "B1_PESOESP")
                          ElseIf Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_TRT'
                                 aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := StrZero(nAjuSeq, 3)
                                 nAjuSeq += 1
                          Else
                             aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := FieldGet(FieldPos(aHoBrw2Sim[nY][2]))
                          Endif
                       Else
                          If Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_DESC'
                             aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := Posicione("SB1", 1, xFilial("SB1")+aCoBrw2Sim[Len(aCoBrw2Sim)][1], "B1_DESC")
                          ElseIf Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_CUSTOUN'
                                 aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := Iif( Posicione("SB1", 1, xFilial('SB1')+aCoBrw2Sim[Len(aCoBrw2Sim)][1], "B1_TIPO") $ 'MP', Posicione("SB1", 1, xFilial('SB1')+aCoBrw2Sim[Len(aCoBrw2Sim)][1], "B1_UPRC"), U_CustoPro(aCoBrw2Sim[Len(aCoBrw2Sim)][1]) )
                          ElseIf Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_CUSTORE'
                                 aCoBrw2Sim[Len(aCoBrw2Sim)][nPosCRe] := aCoBrw2Sim[Len(aCoBrw2Sim)][nPosCUn] * ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosQtd] + ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosQtd] * ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosPer] / 100 ) ) )
                          ElseIf Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_CUSTODO'
                                 aCoBrw2Sim[Len(aCoBrw2Sim)][nPosCDo] := ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosQtd] + ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosQtd] * ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosPer] / 100 ) ) ) / nDolarDia
                          Endif
                       Endif
                   Next
                   aCoBrw2Sim[Len(aCoBrw2Sim)][noBrw2Sim + 1] := .F.
                   DbSelectArea("TCQ")
                   DbSkip()
             Enddo
             DbSelectArea("TCQ")
             DbGoTop()
          Else
             aAdd(aCoBrw2Sim, Array(noBrw2Sim + 1))
             For nI := 1 To noBrw2Sim
                 aCoBrw2Sim[1][nI] := CriaVar(aHoBrw2Sim[nI][2])
             Next
             aCoBrw2Sim[1][noBrw2Sim+1] := .F.
          Endif
       Else
          nAjuSeq := 1
          DbSelectArea("SZN")
          DbSetOrder(2)
          DbSeek(xFilial("SZN")+M->ZM_CODIGO+cRevisao, .t.)
          If Found()
             While !eof() .and. SZN->ZN_CODIGO == M->ZM_CODIGO .and. SZN->ZN_REVISAO == cRevisao
                   aAdd(aCoBrw2Sim, Array(noBrw2Sim + 1))
                   For nY := 1 To noBrw2Sim
                       If !aHoBrw2Sim[nY][10] $ 'V'
                          If Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_PESESP'
                             aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := Iif(M->ZM_REVISAO $ '001' .and. SubStr(aCoBrw2Sim[Len(aCoBrw2Sim)][nPosCom], 1, 10) $ SubStr(M->ZM_CODIGO, 1, 10), Posicione("SZM", 1, xFilial("SZM")+SubStr(M->ZM_CODIGO, 1, 10)+'00', "ZM_PESESP"), Posicione("SB1", 1, xFilial("SB1")+aCoBrw2Sim[Len(aCoBrw2Sim)][1], "B1_PESOESP") )
                          ElseIf Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_TRT'
                                 aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := StrZero(nAjuSeq, 3)
                                 nAjuSeq += 1
                          Else
                             aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := FieldGet(FieldPos(aHoBrw2Sim[nY][02]))
                             If Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_QUANT' .and. aCoBrw2Sim[Len(aCoBrw2Sim)][nY] == 0
                                DbSelectArea("SG1")
                                DbSetOrder(1)
                                DbSeek(xFilial("SG1")+SZN->ZN_CODIGO+SZN->ZN_COMP+SZN->ZN_TRT, .t.)
                                If Found()
                                   RecLock("SZN", .f.)
                                      SZN->ZN_QUANT := Round(SG1->G1_QUANT, 3)
                                      aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := Round(SG1->G1_QUANT, 3)
                                   MsUnLock()
                                Endif
                                DbSelectArea("SZN")
                             Endif
                          Endif
                       Else
                          If Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_DESC'
                             aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := Iif(M->ZM_REVISAO $ '001' .and. SubStr(aCoBrw2Sim[Len(aCoBrw2Sim)][nPosCom], 1, 10) $ SubStr(M->ZM_CODIGO, 1, 10), M->ZM_DESCRIC , Posicione("SB1", 1, xFilial("SB1")+aCoBrw2Sim[Len(aCoBrw2Sim)][1], "B1_DESC") )
                          ElseIf Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_CUSTOUN'
                                 aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := Iif(M->ZM_REVISAO $ '001' .and. SubStr(aCoBrw2Sim[Len(aCoBrw2Sim)][nPosCom], 1, 10) $ SubStr(M->ZM_CODIGO, 1, 10), U_fCCusPro(aCoBrw2Sim[Len(aCoBrw2Sim)][nPosCom],M->ZM_REVISAO), Iif( Posicione("SB1", 1, xFilial('SB1')+aCoBrw2Sim[Len(aCoBrw2Sim)][1], "B1_TIPO") $ 'MP', Posicione("SB1", 1, xFilial('SB1')+aCoBrw2Sim[Len(aCoBrw2Sim)][1], "B1_UPRC"), U_CustoPro(aCoBrw2Sim[Len(aCoBrw2Sim)][1]) ) )
                          ElseIf Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_CUSTORE'
                                 aCoBrw2Sim[Len(aCoBrw2Sim)][nPosCRe] := aCoBrw2Sim[Len(aCoBrw2Sim)][nPosCUn] * ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosQtd] + ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosQtd] * ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosPer] / 100 ) ) )
                          ElseIf Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_CUSTODO'
                                 aCoBrw2Sim[Len(aCoBrw2Sim)][nPosCDo] := ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosQtd] + ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosQtd] * ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosPer] / 100 ) ) ) / nDolarDia
                          Endif
                       Endif
                   Next
                   aCoBrw2Sim[Len(aCoBrw2Sim)][noBrw2Sim + 1] := .F.
                   DbSelectArea("SZN")
                   DbSkip()
             EndDo
          Else
             DbSelectArea("SG1")
             DbSetOrder(1)
             DbSeek(xFilial("SG1")+M->ZM_CODIGO, .t.)
             If Found()
                While !Eof() .and. SG1->G1_COD == M->ZM_CODIGO
                      aAdd(aCoBrw2Sim, Array(noBrw2Sim + 1))
                      For nY := 1 To noBrw2Sim
                          If !aHoBrw2Sim[nY][10] $ 'V'
                             If Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_PESESP'
                                aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := Posicione('SB1', 1, xFilial('SB1')+aCoBrw2Sim[Len(aCoBrw2Sim)][nPosCom], "B1_PESOESP")
                             ElseIf Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_TRT'
                                    aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := StrZero(nAjuSeq, 3)
                                    nAjuSeq += 1
                             Else
                                aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := FieldGet(FieldPos("G1"+SubStr(aHoBrw2Sim[nY][02], 3, 10)))
                                If Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_QUANT' .and. aCoBrw2Sim[Len(aCoBrw2Sim)][nY] == 0
                                   DbSelectArea("SG1")
                                   DbSetOrder(1)
                                   DbSeek(xFilial("SG1")+SZN->ZN_CODIGO+SZN->ZN_COMP+SZN->ZN_TRT, .t.)
                                   If Found()
                                      RecLock("SZN", .f.)
                                         SZN->ZN_QUANT := Round(SG1->G1_QUANT, 3)
                                         aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := Round(SG1->G1_QUANT, 3)
                                      MsUnLock()
                                   Endif
                                   DbSelectArea("SZN")
                                Endif
                             Endif
                          Else
                             If Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_DESC'
                                aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := Posicione("SB1", 1, xFilial("SB1")+aCoBrw2Sim[Len(aCoBrw2Sim)][1], "B1_DESC")
                             ElseIf Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_CUSTOUN'
                                    aCoBrw2Sim[Len(aCoBrw2Sim)][nY] := Iif( Posicione("SB1", 1, xFilial('SB1')+aCoBrw2Sim[Len(aCoBrw2Sim)][1], "B1_TIPO") $ 'MP', Posicione("SB1", 1, xFilial('SB1')+aCoBrw2Sim[Len(aCoBrw2Sim)][1], "B1_UPRC"), U_CustoPro(aCoBrw2Sim[Len(aCoBrw2Sim)][1]) )
                             ElseIf Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_CUSTORE'
                                    aCoBrw2Sim[Len(aCoBrw2Sim)][nPosCRe] := aCoBrw2Sim[Len(aCoBrw2Sim)][nPosCUn] * ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosQtd] + ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosQtd] * ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosPer] / 100 ) ) )
                             ElseIf Alltrim(aHoBrw2Sim[nY][02]) $ 'ZN_CUSTODO'
                                    aCoBrw2Sim[Len(aCoBrw2Sim)][nPosCDo] := ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosQtd] + ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosQtd] * ( aCoBrw2Sim[Len(aCoBrw2Sim)][nPosPer] / 100 ) ) ) / nDolarDia
                             Endif
                          Endif
                      Next
                      aCoBrw2Sim[Len(aCoBrw2Sim)][noBrw2Sim + 1] := .F.
                      DbSelectArea("SG1")
                      DbSkip()
                EndDo
             Else
                aAdd(aCoBrw2Sim, Array(noBrw2Sim + 1))
                For nI := 1 To noBrw2Sim
                    aCoBrw2Sim[1][nI] := CriaVar(aHoBrw2Sim[nI][2])
                Next
                aCoBrw2Sim[1][noBrw2Sim+1] := .F.
                MsgAlert("Revisão "+cRevisao+" não encontrada.", "Atenção...")
             Endif
          Endif
       Endif
Return(.t.)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCarregaVr() - CARREGA VARIÁVEIS DE TELA DA SIMULAÇÃO
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCarregaVr() //Carrega variáveis
       //Local aAux    := {}
       //Local nPosCom := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_COMP"    } )
       Local nPosFor := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_PERC"    } )
       //Local nPosQtd := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_QUANT"   } )
       //Local nPosPer := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_PERDA"   } )
       Local nPosPEs := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_PESESP"  } )
       //Local nPosCUn := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_CUSTOUN" } )
       Local nPosCRe := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_CUSTORE" } )
       Local nPosCDo := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_CUSTODO" } )
       Local nY
       If SubStr(cSayPRNE, 1, 2) $ 'PN'
          If 'K' $ M->ZM_UM
             //Vigente
             cSay7Sim := "Custo(R$/K):"
             oSay7Sim:Refresh()
             oSayBSim:lVisible := .f.
             oSayFSim:lVisible := .f.
             oGet7Sim:lVisible := .f.
             //Revisão
             cSay9Sim := "Custo(R$/K):"
             oSay9Sim:Refresh()
             oSayDSim:lVisible := .f.
             oGetBSim:lVisible := .f.
          ElseIf 'UN' $ M->ZM_UM
                 //Vigente
                 cSay7Sim := "Custo(R$/K):"
                 oSay7Sim:Refresh()
                 cSayBSim := "Preço(R$/U):"
                 oGet7Sim:lVisible := .f.
                 //Revisão
                 cSay9Sim := "Custo(R$/K):"
                 oSay9Sim:Refresh()
                 oGetBSim:lVisible := .f.
                 cSayDSim := "Preço(R$/U):"
          Endif
       Else
          For nY := 1 To Len(aCoBrw2Sim)
              nGet3Sim += Iif(M->ZM_TIPO $ 'PA' .and. !M->ZM_UM $ 'K .L ', 0, aCoBrw2Sim[nY][nPosFor] )
              nGet4Sim += Iif(M->ZM_TIPO $ 'PA' .and. !M->ZM_UM $ 'K .L ', 0, Round( (aCoBrw2Sim[nY][nPosFor] / aCoBrw2Sim[nY][nPosPEs]), 6 ) )
              nGet9Sim += Round( aCoBrw2Sim[nY][nPosCRe], 3 )
              nGetASim += Round( aCoBrw2Sim[nY][nPosCDo], 3 )
          Next
          nGet4Sim := Iif(M->ZM_TIPO $ 'PA' .and. !M->ZM_UM $ 'K .L ', 1, (100 / nGet4Sim) )
          If !(cNumEmp == "01010104")
             If M->ZM_TIPO $ 'PI'
                If 'K' $ M->ZM_UM
                   //%Fórmula
                   oSay5Sim:Refresh()
                   oGet3Sim:Refresh()
                   //P.Especifico
                   oSay6Sim:Refresh()
                   oGet4Sim:Refresh()
                   //Custo(R$/K)
                   cSay7Sim := "Custo(R$/K):"
                   oSay7Sim:Refresh()
                   cSay9Sim := "Custo(R$/K):"
                   oSay9Sim:Refresh()
                   oGet9Sim:Refresh()
                   //Custo(U$/K)
                   cSay8Sim := "Custo(U$/K):"
                   oSay8Sim:Refresh()
                   cSayASim := "Custo(U$/K):"
                   oSayASim:Refresh()
                   oGetASim:Refresh()
                   //
                   oSayBSim:lVisible := .f.
                   oGet7Sim:lVisible := .f.
                   oSayDSim:lVisible := .f.
                   oGetBSim:lVisible := .f.
                   //Imagem (Comparação do Custo(R$/K))
                   If QuantDecimais(nGet9Sim) <> QuantDecimais(nGet5Sim)
                      If QuantDecimais(nGet9Sim) > QuantDecimais(nGet5Sim)
                         cMonitor := "QMT_NO"
                      Else
                         cMonitor := "QMT_OK"
                      Endif
                   Else
                      cMonitor := "QMT_COND"
                   Endif
                   If cRevisao $ '001'
                      cMonitor := "QMT_COND"
                   Endif
                   oBmp1Sim:cResName := cMonitor
                   oBmp1Sim:Refresh()
                ElseIf 'L' $ M->ZM_UM
                       //%Fórmula
                       oSay5Sim:Refresh()
                       oGet3Sim:Refresh()
                       //P.Especifico
                       oSay6Sim:Refresh()
                       oGet4Sim:Refresh()
                       //Custo(R$/L)
                       cSay9Sim := "Custo(R$/L):"
                       oSay9Sim:Refresh()
                       oGet9Sim:Refresh()
                       //Custo(U$/K)
                       cSayASim := "Custo(U$/K):"
                       oSayASim:Refresh()
                       oGetASim:Refresh()
                       //Custo(R$/K)
                       oSayDSim:lVisible := .t.
                       cSayDSim := "Custo(R$/K):"
                       oSayDSim:Refresh()
                       oGetBSim:lVisible := .t.
                       nGetBSim := Round( ( 1 / nGet4Sim ) * nGet9Sim, 3 )
                       oGetBSim:Refresh()
                       //Imagem (Comparação do Custo(R$/L))
                       If M->ZM_TIPOPRO $ 'PN'
                          cMonitor := "QMT_COND"
                       Else
                          If QuantDecimais(nGet9Sim) <> QuantDecimais(nGet5Sim)
                             If QuantDecimais(nGet9Sim) > QuantDecimais(nGet5Sim)
                                cMonitor := "QMT_NO"
                             Else
                                cMonitor := "QMT_OK"
                             Endif
                          Else
                             cMonitor := "QMT_COND"
                          Endif
                       Endif
                       oBmp1Sim:cResName := cMonitor
                       oBmp1Sim:Refresh()
                Endif
             ElseIf M->ZM_TIPO $ 'PA'
                    //%Fórmula
                    oSay5Sim:Refresh()
                    nGet3Sim := 0
                    oGet3Sim:Refresh()
                    //P.Especifico
                    oSay6Sim:Refresh()
                    nGet4Sim := 0
                    oGet4Sim:Refresh()
                    //Custo(R$/L)
                    cSay9Sim := "Custo(R$/L):"
                    oSay9Sim:Refresh()
                    oGet9Sim:Refresh()
                    //Custo(U$/K)
                    cSayASim := "Custo(U$/K):"
                    oSayASim:Refresh()
                    oGetASim:Refresh()
                    //Preço(R$/K)
                    oSayDSim:lVisible := .t.
                    cSayDSim := "Preço:"
                    oSayDSim:Refresh()
                    aPreco := fCalculaPr(nGet9Sim, "REV", "M")
                    nGetBSim := aPreco[1]
                    oGetBSim:lVisible := .t.
                    //Imagem (Comparação do Custo(R$/L))
                    If QuantDecimais(nGet7Sim) <> QuantDecimais(nGetBSim)
                       If QuantDecimais(nGetBSim) > QuantDecimais(nGet7Sim)
                          If Abs( QuantDecimais(nGetBSim) - QuantDecimais(nGet7Sim) ) > 0.005
                             cMonitor := "QMT_NO"
                          Else
                             nGetBSim := nGetBSim - Abs( QuantDecimais(nGetBSim) - QuantDecimais(nGet7Sim) )
                             nGet9Sim := nGet9Sim - Abs( QuantDecimais(nGet9Sim) - QuantDecimais(nGet5Sim) )
                             cMonitor := "QMT_COND"
                          Endif
                       Else
                          If Abs( QuantDecimais(nGetBSim) - QuantDecimais(nGet7Sim) ) > 0.005
                             cMonitor := "QMT_OK"
                          Else
                             nGetBSim := nGetBSim + Abs( QuantDecimais(nGetBSim) - QuantDecimais(nGet7Sim) )
                             nGet9Sim := nGet9Sim + Abs( QuantDecimais(nGet9Sim) - QuantDecimais(nGet5Sim) )
                             cMonitor := "QMT_OK"
                          Endif
                       Endif
                    Else
                       cMonitor := "QMT_COND"
                    Endif
                    If M->ZM_REVISAO $ '001'
                       cMonitor := "QMT_COND"
                    Endif
                    oBmp1Sim:cResName := cMonitor
                    oBmp1Sim:Refresh()
             Endif
          Else
          
          If 'K' $ M->ZM_UM
             cSay9Sim := "Custo(R$/K):"
             oSay9Sim:Refresh()
             If M->ZM_TIPO $ 'PA'
                cSayDSim := "Preço:"
                oSayDSim:lVisible := .t.
                aPreco := fCalculaPr(nGet9Sim, "REV", "M")
                nGetBSim := aPreco[1]
                oGetBSim:lVisible := .t.
                //Comparação pelo Preço de Venda
                If QuantDecimais(nGet7Sim) <> QuantDecimais(nGetBSim)
                   If QuantDecimais(nGetBSim) > QuantDecimais(nGet7Sim)
                      cMonitor := "QMT_NO"
                   Else
                      cMonitor := "QMT_OK"
                   Endif
                Else
                   cMonitor := "QMT_COND"
                Endif
                oBmp1Sim:cResName := cMonitor
                oBmp1Sim:Refresh()
             Else
                //Comparação pelo Custo
                If QuantDecimais(nGet9Sim) <> QuantDecimais(nGet5Sim)
                   If QuantDecimais(nGetBSim) > QuantDecimais(nGet7Sim)
                      cMonitor := "QMT_NO"
                   Else
                      cMonitor := "QMT_OK"
                   Endif
                Else
                   cMonitor := "QMT_COND"
                Endif
                oBmp1Sim:cResName := cMonitor
                oBmp1Sim:Refresh()
             Endif
          ElseIf "UN" $ M->ZM_UM
                 cSay9Sim := "Custo(R$/U):"
                 oSay9Sim:Refresh()
                 If M->ZM_TIPO $ 'PA'
                    cSayDSim := "Preço:"
                    oSayDSim:lVisible := .t.
                    aPreco := fCalculaPr(nGet9Sim, "REV", "M")
                    nGetBSim := aPreco[1]
                    oGetBSim:lVisible := .t.
                    //Comparação pelo Preço de Venda
                    If QuantDecimais(nGet7Sim) <> QuantDecimais(nGetBSim)
                       If QuantDecimais(nGetBSim) > QuantDecimais(nGet7Sim)
                          If Abs( QuantDecimais(nGetBSim) - QuantDecimais(nGet7Sim) ) > 0.005
                             cMonitor := "QMT_NO"
                          Else
                             nGetBSim := nGetBSim - Abs( QuantDecimais(nGetBSim) - QuantDecimais(nGet7Sim) )
                             nGet9Sim := nGet9Sim - Abs( QuantDecimais(nGet9Sim) - QuantDecimais(nGet5Sim) )
                             cMonitor := "QMT_COND"
                          Endif
                       Else
                          If Abs( QuantDecimais(nGetBSim) - QuantDecimais(nGet7Sim) ) > 0.005
                             cMonitor := "QMT_COND"
                          Else
                             nGetBSim := nGetBSim + Abs( QuantDecimais(nGetBSim) - QuantDecimais(nGet7Sim) )
                             nGet9Sim := nGet9Sim + Abs( QuantDecimais(nGet9Sim) - QuantDecimais(nGet5Sim) )
                             cMonitor := "QMT_OK"
                          Endif
                       Endif
                    Else
                       cMonitor := "QMT_COND"
                    Endif
                    oBmp1Sim:cResName := cMonitor
                    oBmp1Sim:Refresh()
                 Else
                    //Comparação pelo Custo
                    If QuantDecimais(nGet9Sim) <> QuantDecimais(nGet5Sim)
                       If QuantDecimais(nGetBSim) > QuantDecimais(nGet7Sim)
                          cMonitor := "QMT_NO"
                       Else
                          cMonitor := "QMT_OK"
                       Endif
                    Else
                       cMonitor := "QMT_COND"
                    Endif
                    oBmp1Sim:cResName := cMonitor
                    oBmp1Sim:Refresh()
                 Endif
          Else
             nGetBSim := Round( ( 1 / nGet4Sim ) * nGet9Sim, 3 )
          Endif
          Endif
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ PCPA04CP()  - VALIDAÇÃO DE CAMPOS NA MSGETNEWDADOS DA TELA PRINCIPAL DA SIMULAÇÃO
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
User Function PCPA04CP()
     Local lRet := .t.
     Local nQtdDec := Iif((cNumEmp == "01010104") .and. SubStr(M->ZM_CODIGO, 1, 1) $ 'R', 6, 4)
     //Local nPosCom := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_COMP"    } )
     Local nPosDes := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_DESC"    } )
     Local nPosSeq := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_TRT"     } )
     Local nPosFor := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_PERC"    } )
     Local nPosQtd := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_QUANT"   } )
     Local nPosPer := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_PERDA"   } )
     Local nPosPEs := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_PESESP"  } )
     Local nPosCUn := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_CUSTOUN" } )
     Local nPosCRe := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_CUSTORE" } )
     Local nPosCDo := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_CUSTODO" } )
     Local _nY
     If __ReadVar $ 'M->ZN_COMP'
        //Verificação geral do produto digitado
        DbSelectArea("SB1")
        DbSetOrder(1)
        DbSeek(xFilial("SB1")+M->ZN_COMP, .t.)
        If Found()
           //Verifica se o produto não está Bloqueado
           If SB1->B1_MSBLQL $ '1'
              MsgStop("Produto bloqueado, verifique...", "Atenção")
              lRet := .f.
           Endif
           //Verificar se o produto é MP ou PI
           If lRet
              If !(cNumEmp == "01010104")
                 If !M->ZM_TIPO == 'PA'
                    If !SB1->B1_TIPO $ 'MP.PI'
                       MsgStop("Tipo de produto inválido, verifique...", "Atenção")
                       lRet := .f.
                    Endif
                 Endif
              Endif
           Endif
           //Verificar a unidade do produto K
           If lRet
              If !(cNumEmp == "01010104")
                 If !M->ZM_TIPO == 'PA'
                    If !SB1->B1_UM $ 'K .KG'
                       MsgStop("Unidade de medida inválida, verifique...", "Atenção")
                       lRet := .f.
                    Endif
                 Endif
              Endif
           Endif
           //Preencher descrição do componente
           If lRet
              oBrw2Sim:aCols[oBrw2Sim:nAt][nPosDes] := SB1->B1_DESC
           Endif
           //Preencher sequencia da fórmula
           If lRet
              oBrw2Sim:aCols[oBrw2Sim:nAt][nPosSeq] := StrZero(oBrw2Sim:nAt, 3)
           Endif
           //Preencher peso específico
           If lRet
              oBrw2Sim:aCols[oBrw2Sim:nAt][nPosPEs] := SB1->B1_PESOESP
           Endif
           //Preencher custo unitário do produto
           If lRet
              oBrw2Sim:aCols[oBrw2Sim:nAt][nPosCUn] := Iif(SB1->B1_TIPO $ 'MP', SB1->B1_UPRC, U_CustoPro(SB1->B1_COD))
           Endif
        Else
           MsgStop("Material não encontrado, verifique...", "Atenção")
           lRet := .f.
        Endif
     ElseIf __ReadVar $ 'M->ZN_TRT'
            //Verificar se não existe sequencia igual
            For _nY := 1 To Len(oBrw2Sim:aCols)
                If !oBrw2Sim:aCols[_nY][noBrw2Sim+1]
                   If oBrw2Sim:nAt <> _nY
                      If oBrw2Sim:aCols[_nY][nPosSeq] == M->ZN_TRT
                         MsgStop("Já existe essa seqüência na fórmula, verifique...", "Atenção")
                         lRet := .f.
                      Endif
                   Endif
                Endif
            Next
     ElseIf __ReadVar $ 'M->ZN_PERC'
            //Verificar percentual da fórmula digitado
            If !M->ZM_TIPO == 'PA' .or. (cNumEmp == "01010104")
               //Verificar o valor digitado
               If M->ZN_PERC > 100.00
                  MsgStop("Valor digitado não pode ser maior que 100.00%", "Atenção")
                  lRet := .f.
               Endif
               If lRet
                  If M->ZN_PERC == 0.00
                     MsgStop("Valor digitado não pode ser igual a 0.00%", "Atenção")
                     lRet := .f.
                  Endif
               Endif
               If lRet
                  nSomFor := M->ZN_PERC
                  nSomPes := M->ZN_PERC / oBrw2Sim:aCols[oBrw2Sim:nAt][nPosPEs]
                  For _nY := 1 To Len(oBrw2Sim:aCols)
                      If !oBrw2Sim:aCols[_nY][noBrw2Sim+1]
                         If oBrw2Sim:nAt <> _nY
                            nSomFor += oBrw2Sim:aCols[_nY][nPosFor]
                            nSomPEs += oBrw2Sim:aCols[_nY][nPosFor] / oBrw2Sim:aCols[_nY][nPosPEs]
                         Endif
                      Endif
                  Next
                  If nSomFor > 100.00
                     MsgStop("Soma do percentual da fórmula não pode ser maior que 100.00%", "Atenção")
                     lRet := .f.
                  Endif
                  If lRet
                     nGet9Sim := 0
                     nGetASim := 0
                     nGet3Sim := nSomFor
                     oGet3Sim:Refresh()
                     nGet4Sim := Round( 100 / nSomPes, 6 )
                     oGet4Sim:Refresh()
                     //Calculo da Quantidade / Custos Total / Custo Dolar
                     For _nY := 1 To Len(oBrw2Sim:aCols)
                         If !oBrw2Sim:aCols[_nY][noBrw2Sim+1]
                            If oBrw2Sim:nAt == _nY
                               If Alltrim(M->ZM_UM) $ 'L'
                                  oBrw2Sim:aCols[_nY][nPosQtd] := Round( ( ( M->ZN_PERC / 100 ) * nGet4Sim ), nQtdDec )
                               Else
                                  oBrw2Sim:aCols[_nY][nPosQtd] := Round( ( ( M->ZN_PERC / 100 )            ), nQtdDec )
                               Endif
                            Else
                               If Alltrim(M->ZM_UM) $ 'L'
                                  oBrw2Sim:aCols[_nY][nPosQtd] := Round( ( ( oBrw2Sim:aCols[_nY][nPosFor] / 100 ) * nGet4Sim ), nQtdDec )
                               Else
                                  oBrw2Sim:aCols[_nY][nPosQtd] := Round( ( ( oBrw2Sim:aCols[_nY][nPosFor] / 100 )            ), nQtdDec )
                               Endif
                            Endif
                            oBrw2Sim:aCols[_nY][nPosCRe] := ( oBrw2Sim:aCols[_nY][nPosQtd] + ( oBrw2Sim:aCols[_nY][nPosQtd] * ( oBrw2Sim:aCols[_nY][nPosPer] / 100 ) ) ) * oBrw2Sim:aCols[_nY][nPosCUn]
                            oBrw2Sim:aCols[_nY][nPosCDo] := ( oBrw2Sim:aCols[_nY][nPosQtd] + ( oBrw2Sim:aCols[_nY][nPosQtd] * ( oBrw2Sim:aCols[_nY][nPosPer] / 100 ) ) ) / nDolarDia
                            nGet9Sim += oBrw2Sim:aCols[_nY][nPosCRe]
                            nGetASim += oBrw2Sim:aCols[_nY][nPosCDo]
                         Endif
                     Next
                     If 'K' $ M->ZM_UM
                        cSay9Sim := "Custo(R$/K):"
                        oSay9Sim:Refresh()
                        If M->ZM_TIPO $ "PA"
                           cSayDSim := "Preço: "
                           oSayDSim:lVisible := .t.
                           aPreco := fCalculaPr(nGet9Sim, "REV", "M")
                           nGetBSim := aPreco[1]
                           oGetBSim:lVisible := .t.
                           //Comparação pelo Preço de Venda
                           If QuantDecimais(nGet7Sim) <> QuantDecimais(nGetBSim)
                              If QuantDecimais(nGetBSim) > QuantDecimais(nGet7Sim)
                                 cMonitor := "QMT_NO"
                              Else
                                 cMonitor := "QMT_OK"
                              Endif
                           Else
                              cMonitor := "QMT_COND"
                           Endif
                           oBmp1Sim:cResName := cMonitor
                           oBmp1Sim:Refresh()
                        Else
                           //Comparação pelo Custo
                           If QuantDecimais(nGet9Sim) <> QuantDecimais(nGet5Sim)
                              If QuantDecimais(nGetBSim) > QuantDecimais(nGet7Sim)
                                 cMonitor := "QMT_NO"
                              Else
                                 cMonitor := "QMT_OK"
                              Endif
                           Else
                              cMonitor := "QMT_COND"
                           Endif
                           oBmp1Sim:cResName := cMonitor
                           oBmp1Sim:Refresh()
                        Endif
                     Else
                        nGetBSim := Round( ( 1 / nGet4Sim ) * nGet9Sim, 3 )
                        If M->ZM_TIPOPRO $ 'PN'
                           cMonitor := "QMT_COND"
                           oBmp1Sim:cResName := cMonitor
                           oBmp1Sim:Refresh()
                        Else
                           If M->ZM_TIPO $ "PA"
                              //Comparação pelo Preço de Venda
                              If QuantDecimais(nGet7Sim) <> QuantDecimais(nGetBSim)
                                 If QuantDecimais(nGetBSim) > QuantDecimais(nGet7Sim)
                                    cMonitor := "QMT_NO"
                                 Else
                                    cMonitor := "QMT_OK"
                                 Endif
                              Else
                                 cMonitor := "QMT_COND"
                              Endif
                              oBmp1Sim:cResName := cMonitor
                              oBmp1Sim:Refresh()
                           Else
                              //Comparação pelo Custo
                              If QuantDecimais(nGet9Sim) <> QuantDecimais(nGet5Sim)
                                 If QuantDecimais(nGetBSim) > QuantDecimais(nGet7Sim)
                                    cMonitor := "QMT_NO"
                                 Else
                                    cMonitor := "QMT_OK"
                                 Endif
                              Else
                                 cMonitor := "QMT_COND"
                              Endif
                              oBmp1Sim:cResName := cMonitor
                              oBmp1Sim:Refresh()
                           Endif
                        Endif
                     Endif
                     oSayDSim:Refresh()
                     oGetBSim:Refresh()
                     oGet9Sim:Refresh()
                     oGetASim:Refresh()
                  Endif
               Endif
            Else
               If M->ZM_TIPO $ 'PA' .or. (cNumEmp == "01010104")
                  If M->ZN_PERC == 0.00
                     MsgStop("Valor digitado não pode ser igual a 0.00%", "Atenção")
                     lRet := .f.
                  Endif
                  If lRet
                     //Calculo da Quantidade / Custos Total / Custo Dolar
                     nGet9Sim := 0
                     nGetASim := 0
                     For _nY := 1 To Len(oBrw2Sim:aCols)
                         If !oBrw2Sim:aCols[_nY][noBrw2Sim+1]
                            If oBrw2Sim:nAt == _nY
                               oBrw2Sim:aCols[_nY][nPosQtd] := Round( ( ( M->ZN_PERC                   )            ), nQtdDec )
                            Else
                               oBrw2Sim:aCols[_nY][nPosQtd] := Round( ( ( oBrw2Sim:aCols[_nY][nPosFor] )            ), nQtdDec )
                            Endif
                            oBrw2Sim:aCols[_nY][nPosCRe] := ( oBrw2Sim:aCols[_nY][nPosQtd] + ( oBrw2Sim:aCols[_nY][nPosQtd] * ( oBrw2Sim:aCols[_nY][nPosPer] / 100 ) ) ) * oBrw2Sim:aCols[_nY][nPosCUn]
                            oBrw2Sim:aCols[_nY][nPosCDo] := ( oBrw2Sim:aCols[_nY][nPosQtd] + ( oBrw2Sim:aCols[_nY][nPosQtd] * ( oBrw2Sim:aCols[_nY][nPosPer] / 100 ) ) ) / nDolarDia
                            nGet9Sim += oBrw2Sim:aCols[_nY][nPosCRe]
                            nGetASim += oBrw2Sim:aCols[_nY][nPosCDo]
                         Endif
                     Next
                  Endif
                  cSayDSim := "Preço: "
                  oSayDSim:lVisible := .t.
                  aPreco := fCalculaPr(nGet9Sim, "REV", "M")
                  nGetBSim := aPreco[1]
                  oGetASim:Refresh()
                  oGet9Sim:Refresh()
                  oGetBSim:Refresh()
                  oGetBSim:lVisible := .t.
               Else
                  nGet3Sim := 0
                  oGet3Sim:Refresh()
                  nGet4Sim := 0
                  oGet4Sim:Refresh()
               Endif
            Endif
     ElseIf __ReadVar $ 'M->ZN_PERDA'
            oBrw2Sim:aCols[oBrw2Sim:nAt][nPosCRe] := ( oBrw2Sim:aCols[oBrw2Sim:nAt][nPosQtd] + ( oBrw2Sim:aCols[oBrw2Sim:nAt][nPosQtd] * ( M->ZN_PERDA / 100 ) ) ) * oBrw2Sim:aCols[oBrw2Sim:nAt][nPosCUn]
            oBrw2Sim:aCols[oBrw2Sim:nAt][nPosCDo] := ( oBrw2Sim:aCols[oBrw2Sim:nAt][nPosQtd] + ( oBrw2Sim:aCols[oBrw2Sim:nAt][nPosQtd] * ( M->ZN_PERDA / 100 ) ) ) / nDolarDia
            nGet9Sim := oBrw2Sim:aCols[oBrw2Sim:nAt][nPosCRe]
            nGetASim := oBrw2Sim:aCols[oBrw2Sim:nAt][nPosCDo]
            For _nY := 1 To Len(oBrw2Sim:aCols)
                If !oBrw2Sim:aCols[_nY][noBrw2Sim+1]
                   If _nY <> oBrw2Sim:nAt
                      nGet9Sim += oBrw2Sim:aCols[_nY][nPosCRe]
                      nGetASim += oBrw2Sim:aCols[_nY][nPosCDo]
                   Endif
                Endif
            Next
            If 'K' $ M->ZM_UM
               cSay9Sim := "Custo(R$/K):"
               oSay9Sim:Refresh()
               If M->ZM_TIPO $ "PA"
                  cSayDSim := "Preço:"
                  oSayDSim:lVisible := .t.
                  aPreco := fCalculaPr(nGet9Sim, "REV", "M")
                  nGetBSim := aPreco[1]
                  oGetBSim:lVisible := .t.
                  //Comparação pelo Preço de Venda
                  If QuantDecimais(nGet7Sim) <> QuantDecimais(nGetBSim)
                     If QuantDecimais(nGetBSim) > QuantDecimais(nGet7Sim)
                        cMonitor := "QMT_NO"
                     Else
                        cMonitor := "QMT_OK"
                     Endif
                  Else
                     cMonitor := "QMT_COND"
                  Endif
                  oBmp1Sim:cResName := cMonitor
                  oBmp1Sim:Refresh()
               Else
                  //Comparação pelo Custo
                  If QuantDecimais(nGet9Sim) <> QuantDecimais(nGet5Sim)
                     If QuantDecimais(nGetBSim) > QuantDecimais(nGet7Sim)
                        cMonitor := "QMT_NO"
                     Else
                        cMonitor := "QMT_OK"
                     Endif
                  Else
                     cMonitor := "QMT_COND"
                  Endif
                  oBmp1Sim:cResName := cMonitor
                  oBmp1Sim:Refresh()
               Endif
            Else
               nGetBSim := Round( ( 1 / nGet4Sim ) * nGet9Sim, 3 )
            Endif
            oSayDSim:Refresh()
            oGetBSim:Refresh()
            oGet9Sim:Refresh()
            oGetASim:Refresh()
     Endif
     //aSort(oBrw2Sim:aCols, , ,{|x, y| x[3] < y[3]})
Return(lRet)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ PCPA04AP()  - VALIDAÇÃO DE DELEÇÃO NA MSGETNEWDADOS DA TELA PRINCIPAL DA SIMULAÇÃO
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
User Function pcpa04ap()
     Local lRet := .t.
     Local _nY
     //Local nPosCom := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_COMP"    } )
     //Local nPosDes := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_DESC"    } )
     //Local nPosSeq := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_TRT"     } )
     Local nPosFor := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_PERC"    } )
     //Local nPosQtd := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_QUANT"   } )
     //Local nPosPer := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_PERDA"   } )
     Local nPosPEs := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_PESESP"  } )
     //Local nPosCUn := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_CUSTOUN" } )
     Local nPosCRe := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_CUSTORE" } )
     Local nPosCDo := aScan(aHoBrw2Sim, { |x| Trim(x[2]) == "ZN_CUSTODO" } )

     nGet9Sim := Iif(!oBrw2Sim:aCols[oBrw2Sim:nAt][noBrw2Sim+1], 0, oBrw2Sim:aCols[oBrw2Sim:nAt][nPosCRe] )
     nGetASim := Iif(!oBrw2Sim:aCols[oBrw2Sim:nAt][noBrw2Sim+1], 0, oBrw2Sim:aCols[oBrw2Sim:nAt][nPosCDo] )
     nGet3Sim := Iif(!oBrw2Sim:aCols[oBrw2Sim:nAt][noBrw2Sim+1], 0, oBrw2Sim:aCols[oBrw2Sim:nAt][nPosFor] )
     nSomPes  := Iif(!oBrw2Sim:aCols[oBrw2Sim:nAt][noBrw2Sim+1], 0, oBrw2Sim:aCols[oBrw2Sim:nAt][nPosFor] / oBrw2Sim:aCols[oBrw2Sim:nAt][nPosPEs] )
     For _nY := 1 To Len(oBrw2Sim:aCols)
         If !oBrw2Sim:aCols[_nY][noBrw2Sim+1]
            If oBrw2Sim:nAt <> _nY
               nGet9Sim += oBrw2Sim:aCols[_nY][nPosCRe]
               nGetASim += oBrw2Sim:aCols[_nY][nPosCDo]
               nGet3Sim += oBrw2Sim:aCols[_nY][nPosFor]
               nSomPEs += oBrw2Sim:aCols[_nY][nPosFor] / oBrw2Sim:aCols[_nY][nPosPEs]
            Endif
         Endif
     Next
     oGet3Sim:Refresh()
     nGet4Sim := Round( 100 / nSomPes, 6 )
     oGet4Sim:Refresh()
     If 'K' $ M->ZM_UM
        cSay9Sim := "Custo(R$/K):"
        oSay9Sim:Refresh()
        If M->ZM_TIPO $ 'PA'
           cSayDSim := "Preço:"
           oSayDSim:lVisible := .t.
           aPreco := fCalculaPr(nGet9Sim, "REV", "M")
           nGetBSim := aPreco[1]
           oGetBSim:lVisible := .t.
           //Comparação pelo Preço de Venda
           If QuantDecimais(nGet7Sim) <> QuantDecimais(nGetBSim)
              If QuantDecimais(nGetBSim) > QuantDecimais(nGet7Sim)
                 cMonitor := "QMT_NO"
              Else
                 cMonitor := "QMT_OK"
              Endif
           Else
              cMonitor := "QMT_COND"
           Endif
           oBmp1Sim:cResName := cMonitor
           oBmp1Sim:Refresh()
        Else
           //Comparação pelo Custo
           If QuantDecimais(nGet9Sim) <> QuantDecimais(nGet5Sim)
              If QuantDecimais(nGetBSim) > QuantDecimais(nGet7Sim)
                 cMonitor := "QMT_NO"
              Else
                 cMonitor := "QMT_OK"
              Endif
           Else
              cMonitor := "QMT_COND"
           Endif
           If M->ZM_REVISAO == "001"
              cMonitor := "QMT_COND"
           Endif
           oBmp1Sim:cResName := cMonitor
           oBmp1Sim:Refresh()
        Endif
     ElseIf 'UN' $ M->ZM_UM
            //cSay9Sim := "Custo(R$/K):"
            //oSay9Sim:Refresh()
            aPreco := fCalculaPr(nGet9Sim, "REV", "M")
            nGetBSim := aPreco[1]
            oGetBSim:lVisible := .t.
            //Comparação pelo Preço de Venda
            If QuantDecimais(nGet7Sim) <> QuantDecimais(nGetBSim)
               If QuantDecimais(nGetBSim) > QuantDecimais(nGet7Sim)
                  cMonitor := "QMT_NO"
               Else
                  cMonitor := "QMT_OK"
               Endif
            Else
               cMonitor := "QMT_COND"
            Endif
            If M->ZM_REVISAO == "001"
               cMonitor := "QMT_COND"
            Endif
            oBmp1Sim:cResName := cMonitor
            oBmp1Sim:Refresh()
     Else
        nGetBSim := Round( ( 1 / nGet4Sim ) * nGet9Sim, 3 )
     Endif
     oSayDSim:Refresh()
     oGetBSim:Refresh()
     oGet9Sim:Refresh()
     oGetASim:Refresh()
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ fMontaEmbal ³ Autor ³ Luís G. de Souza   ³ Data ³ 21/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta Browse de embalagens para produtos que tem PAs.      ³±±
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
Static Function fMontaEmbal()
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       Local   nOpcEmb    := Iif(VISUALSIM, 0, Iif( INCLUISIM, 3, IIF(ALTERASIM, 5, 0)))
       Local   nOpcEmp    := 0
       Local nY
       Private aCoBrw1Emb := {}
       Private aHoBrw1Emb := {}
       Private noBrw1Emb  := 0

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oDlg1Emb", "oBtn1Emb", "oBtn2Emb", "oBrw1Emb")

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oDlg1Emb   := MSDialog():New( 434, 415, 625, 780, "Embalagens", , , .F., , , , , , .T., , , .T. )
       oBtn1Emb   := TButton():New( 004, 004, "Confirma", oDlg1Emb, {|| nOpcEmp := 1, oDlg1Emb:End() }, 037, 012, , , , .T., , "", , , , .F. )
       oBtn2Emb   := TButton():New( 004, 143, "Cancela" , oDlg1Emb, {|| nOpcEmp := 0, oDlg1Emb:End() }, 037, 012, , , , .T., , "", , , , .F. )
       MHoBrw1Emb()
       MCoBrw1Emb()
       oBrw1Emb   := MsNewGetDados():New(020, 004, 092, 180, Iif(nOpcEmb == 2 .or. nOpcEmb == 6, 0, GD_INSERT+GD_UPDATE+GD_DELETE), 'AllwaysTrue()', 'AllwaysTrue()', '', , 0, 99, 'AllwaysTrue()', '', 'AllwaysTrue()', oDlg1Emb, aHoBrw1Emb, aCoBrw1Emb )

       oDlg1Emb:Activate(,,,.T.)
       If nOpcEmb == 0 //Não altera valor da Matriz aResultE
       
       ElseIf nOpcEmp == 1 //Ajusta o Valor da Matriz aResultE
              If !VISUALSIM
                 aResultE := {}
                 For nY := 1 To Len(oBrw1Emb:aCols)
                     If !oBrw1Emb:aCols[nY][noBrw1Emb+1]
                        aAdd(aResultE, {oBrw1Emb:aCols[nY][1], oBrw1Emb:aCols[nY][2] } )
                     Endif
                 Next
              Endif
       Endif
Return                                                                                           


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrw1Emb() - Monta aHeader da MsNewGetDados para o Alias: SZP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrw1Emb()
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SZP")
       While !Eof() .and. SX3->X3_ARQUIVO == "SZP"
             If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. TRIM(SX3->X3_CAMPO) $ 'ZP_EMB.ZP_DESCEMB'
                noBrw1Emb++
                aAdd( aHoBrw1Emb, { Trim(( _cAliasSX3 )->( X3_TITULO )), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
             EndIf
             DbSkip()
       End*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("SZP") )
       While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SZP"
             If X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .and. TRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZP_EMB.ZP_DESCEMB'
                noBrw1Emb++
                aAdd( aHoBrw1Emb, { Trim(( _cAliasSX3 )->( X3_TITULO )), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
             EndIf
             DbSkip()
       End
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrw1Emb() - Monta aCols da MsNewGetDados para o Alias: SZP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrw1Emb()
       //Local aAux := {}
       Local nI, nY
       If Len(aResultE) > 0
          For nY := 1 To Len(aResultE)
              aAdd(aCoBrw1Emb, Array(noBrw1Emb+1))
              For nI := 1 To noBrw1Emb
                  aCoBrw1Emb[Len(aCoBrw1Emb)][nI] := aResultE[nY][nI]
              Next
              aCoBrw1Emb[Len(aCoBrw1Emb)][noBrw1Emb + 1] := .F.
          Next
       Else
          If SubStr(cSayPRNE, 1, 2) $ 'PN'
             aAdd(aCoBrw1Emb, Array(noBrw1Emb+1))
             For nI := 1 To noBrw1Emb
                 aCoBrw1Emb[1][nI] := CriaVar(aHoBrw1Emb[nI][2])
             Next
             aCoBrw1Emb[1][noBrw1Emb+1] := .F.
          Else //Busca Informações no cadastro de embalagens da simulação
             DbSelectArea("SZP")
             DbSetOrder(2)
             DbSeek(xFilial("SZP")+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
             If Found()
                While !Eof() .and. SZP->ZP_CODIGO == M->ZM_CODIGO .and. SZP->ZP_REVISAO == M->ZM_REVISAO
                      aAdd(aCoBrw1Emb, Array(noBrw1Emb+1))
                      aCoBrw1Emb[Len(aCoBrw1Emb)][1] := SZP->ZP_EMB
                      aCoBrw1Emb[Len(aCoBrw1Emb)][2] := Posicione("SZ5", 1, xFilial("SZ5")+SZP->ZP_EMB, "Z5_DESCR")
                      aCoBrw1Emb[Len(aCoBrw1Emb)][3] := .f.
                      DbSkip()
                      DbSelectArea("SZP")
                Enddo
             Else //Busca Informações no cadastro do Produto.
                DbSelectArea("SB1")
                DbSetOrder(1)
                DbSeek(xFilial("SB1")+M->ZM_CODIGO, .t.)
                If Found()
                   nTamCod := Len(Alltrim(SB1->B1_COD))
                   While !Eof() .and. SubStr(Alltrim(SB1->B1_COD), 1, nTamCod) == Alltrim(M->ZM_CODIGO)
                         If !Empty(SubStr(Alltrim(SB1->B1_COD), nTamCod + 1, 2)) .and. Len(SubStr(Alltrim(SB1->B1_COD), nTamCod + 1, 2)) == 2
                            aAdd(aCoBrw1Emb, Array(noBrw1Emb+1))
                            aCoBrw1Emb[Len(aCoBrw1Emb)][1] := SubStr(Alltrim(SB1->B1_COD), nTamCod + 1, 2)
                            aCoBrw1Emb[Len(aCoBrw1Emb)][2] := Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(SB1->B1_COD), nTamCod + 1, 2), "Z5_DESCR")
                            aCoBrw1Emb[Len(aCoBrw1Emb)][3] := .f.
                         Endif
                         DbSelectArea("SB1")
                         DbSkip()
                   EndDo
                Endif
             Endif
          Endif
       Endif
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ fMontaOpera ³ Autor ³ Luís G. de Souza   ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta browse com as operações do produto.                  ³±±
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
Static Function fMontaOpera()
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       Local nOpc         := Iif(VISUALSIM, 0, GD_INSERT+GD_DELETE+GD_UPDATE)
       Local nOpcOpe      := 0
       Local nI, nY
       Private aCoBrw1Ope := {}
       Private aHoBrw1Ope := {}
       Private cGet2Ope   := M->ZM_CODIGO
       Private cGet3Ope   := M->ZM_DESCRIC
       Private cSay1Ope   := Space(1)
       Private cSay2Ope   := Space(1)
       Private nCBox1Op
       Private aVetOper   := {}
       Private aMatOper   := {}
       Private nPosVetO   := 0
       Private noBrw1Ope  := 0
       Private cPictPro   := Iif(Len(Alltrim(cGet2Ope)) == 12, "@R! AA 99.99.999-99", "")

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oFont1Op", "oDlg1Ope", "oBrw1Ope", "oBtn1Ope", "oBtn2Ope", "oGrp1Ope", "oSay1Ope", "oSay2Ope", "oCBox1Op")
       SetPrvt("oGet3Ope", "oBtn3Ope")

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oFont1Op   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
       oDlg1Ope   := MSDialog():New( 187, 229, 500, 1058, "Operações", , , .F., , , , , , .T., , , .T. )
       oGrp1Ope   := TGroup():New( 016, 004, 040, 412, "", oDlg1Ope, CLR_BLACK, CLR_WHITE, .T., .F. )
       MHoBrw1Ope()
       MCoBrw1Ope()
       oSay1Ope   := TSay():New(      024, 007, {|| "Código:" }, oGrp1Ope, , oFont1Op, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 010)
       oSay2Ope   := TSay():New(      024, 064, {|| "Produto:"}, oGrp1Ope, , oFont1Op, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 036, 010)
       oGet2Ope   := TGet():New(      022, 100, {|u| If(PCount() > 0, cGet2Ope := u, cGet2Ope)}, oGrp1Ope, 072, 012, cPictPro             , , CLR_BLACK, CLR_WHITE, oFont1Op, , , .T., "", , , .F., .F., , .T., .F., "", "cGet2Ope", , )
       oGet3Ope   := TGet():New(      022, 176, {|u| If(PCount() > 0, cGet3Ope := u, cGet3Ope)}, oGrp1Ope, 232, 012, '@!'                 , , CLR_BLACK, CLR_WHITE, oFont1Op, , , .T., "", , , .F., .F., , .T., .F., "", "cGet3Ope", , )
       oCBox1Op   := TComboBox():New( 022, 040, {|u| If(PCount() > 0, nCBox1Op := u, nCBox1Op)}, aVetOper, 025, 018, oGrp1Ope         , , , , CLR_BLACK, CLR_WHITE, .T., oFont1Op, "", , , , , , , nCBox1Op )

       oBrw1Ope   := MsNewGetDados():New(044, 004, 156, 412, nOpc, 'AllwaysTrue()', 'AllwaysTrue()', '', , 0, 99, 'AllwaysTrue()', '', 'AllwaysTrue()', oDlg1Ope, aHoBrw1Ope, aCoBrw1Ope )

       oBtn1Ope   := TButton():New( 001, 376, "Sair"        , oDlg1Ope, { || nOpcOpe := 0, oDlg1Ope:End() }, 037, 012, , , , .T., , "", , , , .F. )
       If !VISUALSIM
          oBtn3Ope   := TButton():New( 001, 054, "Novo Roteiro", oDlg1Ope, { || MsgStop("Rotina será desenvolvida")}, 037, 012, , , , .T., , "", , , , .F. )
       Endif
       oBtn2Ope   := TButton():New( 001, 004, "Confirma"    , oDlg1Ope, { || nOpcOpe := 1, oDlg1Ope:End() }, 037, 012, , , , .T., , "", , , , .F. )
       oCBox1Op:bChange := {|| fTrocaOper() }
       oDlg1Ope:Activate( , , , .T.)
       If nOpcOpe == 0 //Cancela
       
       ElseIf nOpcOpe == 1 //Confirma
              If !VISUALSIM
                 aResultO := {}
                 //Ajustar a Matriz de Resultados pelo Roteiro atual
                 For nY := 1 To Len(oBrw1Ope:aCols)
                     If !oBrw1Ope:aCols[nY][noBrw1Ope+1]
                        aAdd(aResultO, Array(noBrw1Ope + 1) )
                        For nI := 1 To noBrw1Ope
                            aResultO[Len(aResultO)][nI] := oBrw1Ope:aCols[nY][nI]
                        Next
                        aResultO[Len(aResultO)][nI] := aVetOper[nPosVetO]
                     Endif
                 Next
                 //Ajusta os outros Roteiros do Produto
                 For nY := 1 To Len(aMatOper)
                     If aMatOper[nY][noBrw1Ope + 1] <> aVetOper[nPosVetO]
                        aAdd(aResultO, Array(noBrw1Ope + 1) )
                        For nI := 1 To (noBrw1Ope + 1)
                            aResultO[Len(aResultO)][nI] := aMatOper[nY][nI]
                        Next
                     Endif
                 Next
              Endif
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrw1Ope() - Monta aHeader da MsNewGetDados para o Alias: SG2
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrw1Ope()
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SG2")
       While !Eof() .and. SX3->X3_ARQUIVO == "SG2"
             If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
                If TRIM(SX3->X3_CAMPO) $ 'G2_OPERACAO.G2_RECURSO.G2_FERRAM.F2_LINHAPR.G2_TPLINHA.G2_DESCRI.G2_MAOOBRA.G2_SETUP.G2_LOTEPAD.G2_TEMPAD.G2_TPOPER.G2_CTRAB.G2_ESPOP'
                   noBrw1Ope++
                   aAdd( aHoBrw1Ope, { Trim(( _cAliasSX3 )->( X3_TITULO )), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
                Endif
             EndIf
             DbSkip()
       EndDo*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("SG2") )
       While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SG2"
             If X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL )
                If TRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'G2_OPERACAO.G2_RECURSO.G2_FERRAM.F2_LINHAPR.G2_TPLINHA.G2_DESCRI.G2_MAOOBRA.G2_SETUP.G2_LOTEPAD.G2_TEMPAD.G2_TPOPER.G2_CTRAB.G2_ESPOP'
                   noBrw1Ope++
                   aAdd( aHoBrw1Ope, { Trim(( _cAliasSX3 )->( X3_TITULO )), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
                Endif
             EndIf
             DbSkip()
       EndDo
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrw1Ope() - Monta aCols da MsNewGetDados para o Alias: SG2
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrw1Ope()
       Local cOpePri := ""
       Local nI, nY
       If M->ZM_TIPOPRO $ 'PE'
          cOpePri  := ''
          aVetOper := {}
          DbSelectArea("SB1")
          DbSetOrder(1)
          DbSeek(xFilial("SB1")+M->ZM_CODIGO, .t.)
          If Found()
             cOpePri := SB1->B1_OPERPAD
             aAdd(aVetOper, SB1->B1_OPERPAD)
          Endif
       Endif
       DbSelectArea("SG2")
       If Empty(cOpePri)
          DbSetOrder(3)
          DbSeek(xFilial("SG2")+M->ZM_CODIGO, .t.)
       Else
          DbSetOrder(1)
          DbSeek(xFilial("SG2")+M->ZM_CODIGO, .t.)
       Endif
       If Found()
          If Len( aResultO ) > 0
             While !Eof() .and. SG2->G2_PRODUTO == M->ZM_CODIGO
                   If SG2->G2_CODIGO <> cOpePri
                      nPos := aScan(aVetOper, SG2->G2_CODIGO)
                      If nPos == 0
                         aAdd(aVetOper, SG2->G2_CODIGO)
                      Endif
                   Endif
                   DbSelectArea("SG2")
                   DbSkip()
             EndDo
             aMatOper := aResultO
             For nY := 1 To Len(aResultO)
                 If aMatOper[nY][noBrw1Ope + 1] == cOpePri
                    aAdd(aCoBrw1Ope, Array(noBrw1Ope + 1))
                    For nI := 1 To noBrw1Ope
                        aCoBrw1Ope[Len(aCoBrw1Ope)][nI] := aMatOper[nY][nI]
                    Next
                    aCoBrw1Ope[Len(aCoBrw1Ope)][noBrw1Ope + 1] := .f.
                 Endif
             Next
          Else
             While !Eof() .and. SG2->G2_PRODUTO == M->ZM_CODIGO
                   If SG2->G2_CODIGO == cOpePri
                      aAdd(aCoBrw1Ope, Array(noBrw1Ope + 1))
                      aAdd(aMatOper  , Array(noBrw1Ope + 1)) //Inclusão para Matriz Principal com todos os roteiros do produto
                      For nI := 1 To noBrw1Ope
                          aCoBrw1Ope[Len(aCoBrw1Ope)][nI] := FieldGet(FieldPos(aHoBrw1Ope[nI][2]))
                          aMatOper[Len(aMatOper)][nI]     := FieldGet(FieldPos(aHoBrw1Ope[nI][2])) //Inclusão para Matriz Principal com todos os roteiros do produto
                      Next
                      aCoBrw1Ope[Len(aCoBrw1Ope)][noBrw1Ope+1] := .F.
                      aMatOper[Len(aMatOper)][nI]   := SG2->G2_CODIGO
                   Else
                      nPos := aScan(aVetOper, SG2->G2_CODIGO)
                      If nPos == 0
                         aAdd(aVetOper, SG2->G2_CODIGO)
                      Endif
                      //Inclusão para Matriz Principal com todos os roteiros do produto.
                      aAdd(aMatOper  , Array(noBrw1Ope + 1))
                      For nI := 1 To noBrw1Ope
                          aMatOper[Len(aMatOper)][nI]   := FieldGet(FieldPos(aHoBrw1Ope[nI][2]))
                      Next
                      aMatOper[Len(aMatOper)][nI]   := SG2->G2_CODIGO
                   Endif
                   DbSelectArea("SG2")
                   DbSkip()
             EndDo
          Endif
       Else
          aAdd(aCoBrw1Ope, Array(noBrw1Ope + 1))
          For nI := 1 To noBrw1Ope
              If Trim(aHoBrw1Ope[nI][2]) $ 'G2_OPERACAO'
                 aCoBrw1Ope[1][nI] := '01'
              Else
                 aCoBrw1Ope[1][nI] := CriaVar(aHoBrw1Ope[nI][2])
              Endif
          Next
          aCoBrw1Ope[1][noBrw1Ope+1] := .F.
       Endif
       aSort(aVetOper)
       nCBox1Op := cOpePri
       nPosVetO := aScan(aVetOper, cOpePri)
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fTrocaOper() - Troca Operação do Produto
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fTrocaOper()
       //Antes de Zerar o Browse Principal tem que tirar a operação da Matriz 
       //de Operações e atualiza-las com a do browse principal, pois pode ter
       //tido alterações na mesma.
       Local aAuxOper := {}
       Local nY, nI
       //Retira dados do Browse Principal;
       For nY := 1 To Len(oBrw1Ope:aCols)
           If !oBrw1Ope:aCols[nY][noBrw1Ope + 1]
              aAdd(aAuxOper, Array(noBrw1Ope + 1))
              For nI := 1 To noBrw1Ope
                  aAuxOper[Len(aAuxOper)][nI] := oBrw1Ope:aCols[nY][nI]
              Next
              aAuxOper[Len(aAuxOper)][nI] := aVetOper[nPosVetO]
           Endif
       Next
       //Coloca dados da Matriz com todas as operações, menos a atual na matriz
       //auxiliar;
       For nY := 1 To Len(aMatOper)
           If aMatOper[nY][noBrw1Ope+1] <> aVetOper[nPosVetO]
              aAdd(aAuxOper, Array(noBrw1Ope + 1))
              For nI := 1 To noBrw1Ope + 1
                  aAuxOper[Len(aAuxOper)][nI] := aMatOper[nY][nI]
              Next
           Endif
       Next
       //Atualiza Matriz com dados de todas as operações com dados da matriz auxiliar;
       aMatOper := aAuxOper
       oBrw1Ope:aCols := {}
       For nY := 1 To Len(aMatOper)
           If aMatOper[nY][noBrw1Ope+1] == oCBox1Op:aItems[oCBox1Op:nAt]
              aAdd(oBrw1Ope:aCols, Array(noBrw1Ope + 1))
              For nI := 1 To noBrw1Ope
                  oBrw1Ope:aCols[Len(oBrw1Ope:aCols)][nI] := aMatOper[nY][nI]
              Next
              oBrw1Ope:aCols[Len(oBrw1Ope:aCols)][noBrw1Ope+1] := .F.
           Endif
       Next
       /*
       DbSelectArea("SG2")
       DbSetOrder(1)
       DbSeek(xFilial("SG2")+M->ZM_CODIGO+oCBox1Op:aItems[oCBox1Op:nAt], .t.)
       If Found()
          While !Eof() .and. SG2->G2_PRODUTO == M->ZM_CODIGO .and. SG2->G2_CODIGO == oCBox1Op:aItems[oCBox1Op:nAt]
                   aAdd(oBrw1Ope:aCols, Array(noBrw1Ope + 1))
                   For nI := 1 To noBrw1Ope
                       oBrw1Ope:aCols[Len(oBrw1Ope:aCols)][nI] := FieldGet(FieldPos(aHoBrw1Ope[nI][2]))
                   Next
                   oBrw1Ope:aCols[Len(oBrw1Ope:aCols)][noBrw1Ope+1] := .F.
                DbSelectArea("SG2")
                DbSkip()
          Enddo
       Endif
       */
       nPosVetO := aScan(aVetOper, nCBox1Op)
       oBrw1Ope:oBrowse:nAt := 1
       oBrw1Ope:oBrowse:Refresh()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ fImprimePro ³ Autor ³ Luís G. de Souza   ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta browse com as operações do produto.                  ³±±
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
Static Function fImprimePro()
       Local cCodigo  := M->ZM_CODIGO
       Local cRevisao := M->ZM_REVISAO
       Local cDescric := M->ZM_DESCRIC
       Local cRoteiro := Posicione("SB1", 1, xFilial("SB1")+M->ZM_CODIGO, "B1_OPERPAD")
       Local nLoop
       Private nLinMax := 2800
       Private nColMax := 2350
       Private nLin  :=  0
       Private nCol  := 30

       oFont1 := TFont():New( "Courier New"        , 9, 19, .F., .T., 5, .T., 5, .F., .F.)
       oFont2 := TFont():New( "Courier New"        , 9, 12, .F., .T., 5, .T., 5, .F., .F.)
       oFont3 := TFont():New( "Courier New"        , 9, 11, .F., .T., 5, .T., 5, .F., .F.)
       oFont4 := TFont():New( "Courier New"        , 9, 11, .F., .F., 5, .T., 5, .F., .F.)
       oFont5 := TFont():New( "Courier New"        , 9, 12, .F., .T., 5, .T., 5, .T., .F.)
       oFont6 := TFont():New( "Courier New"        , 9, 08, .F., .F., 5, .T., 5, .F., .F.)

       MsAguarde({|| fBuscaIOpe(cCodigo, cRoteiro) }, "Aguarde", "Buscando informações das Operações ...")

       DbSelectArea("TCQ")
       DbGoTop()
       If EOF()
          MsgStop("Não existe roteiro de operações cadastrado para ser impresso !!!", "Atenção", "STOP")
       Else
          AVPRINT oPrn NAME "FICHA DE PROCESSO"
                  oPrn:SetPage(9)
                  oPrn:SetPortrait()
                  AVPAGE
                    fCabecFich(cCodigo, cRevisao, cDescric)
                    DbSelectArea("TCQ")
                    While !Eof()
                          oPrn:Say( nLin, nCol+0030, TCQ->G2_OPERAC+' - '+TCQ->G2_DESCRI, oFont3)
                          nLin += 60
                          oPrn:Say( nLin, nCol+0030, TCQ->G2_RECURSO+' - '+SubStr(Posicione("SH1", 1, xFilial("SH1")+TCQ->G2_RECURSO, "H1_DESCRI"), 1, 20), oFont4)
                          nLin += 60
                          cMemo := ""
                          cMemo := MSMM(,80,,Posicione("SG2", 1, xFilial("SG2")+cCodigo+'01'+TCQ->G2_OPERAC, "G2_ESPOP"),,,"SG2",)
                          nMCount := MlCount( cMemo, 80 )
                          If nMCount > 0
                             For nLoop := 1 To nMCount
                                 cLinha := ""
                                 cLinha := MemoLine( cMemo, 80, nLoop )
                                 oPrn:Say( nLin, nCol+0030, StrTran( cLinha, Chr(13)+Chr(10)), oFont4)
                                 nLin += 60
                                 If nLin >= nLinMax
                                    AVNEWPAGE
                                      nLin := 0
                                      fCabecFich(cCodigo, cRevisao, cDescric)
                                 Endif  
                             Next
                          Endif
                          fBuscaEstr(cCodigo, cRevisao, TCQ->G2_OPERAC)
                          DbSelectArea("PRO")
                          DbGoTop()
                          If !Eof()
                             oPrn:Line(nlin-10, nCol, nlin-10     , nColMax)
                             While !Eof()
                                   oPrn:Say(nLin, nCol+0030, PRO->ZN_COMP+' - '+SubStr(Alltrim(Posicione("SB1", 1, xFilial("SB1")+PRO->ZN_COMP, "B1_DESC")), 1, 30), oFont4)
                                   oPrn:Say(nLin, nCol+1200, Transform(PRO->ZN_QUANT, "@E 9,999.9999"), oFont4)
                                   oPrn:Say(nLin, nCol+1600, Transform(PRO->ZN_PERC, "@E 999.999%"), oFont4)
                                   oPrn:Say(nLin, nCol+1900, PRO->ZN_TRT, oFont4)
                                   nLin += 60
                                   If nLin >= nLinMax
                                      AVNEWPAGE
                                        nLin := 0
                                        fCabFich(cCodigo, cRevisao, cDescric)
                                   Endif  
                                   DbSelectArea("PRO")
                                   DbSkip()
                             Enddo
                          Endif
                          DbSelectArea("PRO")
                          DbCloseArea()
                        
                          oPrn:Line(nlin-09, nCol, nlin-09     , nColMax)
                          oPrn:Line(nlin-10, nCol, nlin-10     , nColMax)
                          oPrn:Line(nlin-11, nCol, nlin-11     , nColMax)
                          nLin += 20
                          If nLin >= nLinMax
                             AVNEWPAGE
                               nLin := 0
                               fCabecFich(cCodigo, cRevisao, cDescric)
                          Endif  
                          DbSelectArea("TCQ")
                          DbSkip()
                    Enddo
                  AVENDPAGE
          AVENDPRINT
          MS_FLUSH()
       Endif
       DbSelectArea("TCQ")
       DbCloseArea()

Return

/******************************************************************************************************************/
/*** fBuscaIOper - Busca Operações do produto a ser impresso.                                                      ***/
/******************************************************************************************************************/
Static Function fBuscaIOpe(cCodigo, cRoteiro)
       Local cQry := ""
       cQry := ""
       cQry += "SELECT * "
       cQry += "FROM "+RetSqlName("SG2")+" SG2 WITH (NOLOCK) "
       cQry += "WHERE SG2.G2_FILIAL  = '"+xFilial("SG2")+"' "
       cQry += "  AND SG2.G2_PRODUTO = '"+cCodigo+"' "
       cQry += "  AND SG2.D_E_L_E_T_ = '' "
       If !Empty(cRoteiro)
          cQry += "  AND SG2.G2_CODIGO  = '"+cRoteiro+"' "
       Endif
       cQry += "ORDER BY SG2.G2_OPERAC "
       TCQUERY cQry ALIAS "TCQ" NEW
Return

/******************************************************************************************************************/
/*** fCabecFich - Imprime cabeçalho da Ficha de Processo.                                                         ***/
/******************************************************************************************************************/
Static Function fCabecFich(cCodigo, cRevisao, cDescric)
       nLin += 030 //Linha 030
       oPrn:Box( nLin, nCol     , nLin+120, nColMax ) // Box da Linha 030 até a 120 - 090 Linhas
       nLin += 030 //Linha 060
       oPrn:Say( nLin, nCol+0400, "F I C H A    D E    P R O C E S S O", oFont1) //Linha 60
       oPrn:Say( nLin+050, nCol+1950, dtoc(dDataBase)+' - '+Time(), oFont6) //Linha 110
       nLin += 100 //Linha 160
       oPrn:Box( nLin, nCol     , nLin+120, nColMax ) // Box da Linha 160 até a 280 - 120 Linhas
       nLin += 010 //Linha 170
       oPrn:Say( nLin, nCol+030 , "PRODUTO:", oFont2) //Linha 170
       oPrn:Say( nLin, nCol+300 , Alltrim(cCodigo)+' - '+Alltrim(cDescric)+Iif(Len(AllTrim(cCodigo)) == 12, ' / '+SubStr(Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodigo,4,2), "Z1_DESCR"), 1, 25), ''), oFont5) //Linha 170
       nLin += 060 //Linha 230
       oPrn:Say( nLin, nCol+030 , "REVISÃO:", oFont2) //Linha 230
       oPrn:Say( nLin, nCol+300 , U_fBusUlRv(cCodigo), oFont5)
       nLin += 080 //Linha 290
Return

/******************************************************************************************************************/
/*** fBuscaEstr - Busca estrutura do produto por operação.                                                        ***/
/******************************************************************************************************************/
Static Function fBuscaEstr(cCodigo, cRevisao, cOperacao)
       Local cQry := ""
       
       cQry := ""
       cQry += "SELECT * "
       cQry += "FROM "+RetSqlName("SZN")+" SZN WITH (NOLOCK) "
       cQry += "WHERE SZN.ZN_FILIAL = '"+xFilial("SZN")+"' "
       cQry += "  AND SZN.D_E_L_E_T_ = '' "
       cQry += "  AND SZN.ZN_CODIGO = '"+cCodigo+"' "
       cQry += "  AND SZN.ZN_REVISAO = '"+cRevisao+"' "
       cQry += "  AND SZN.ZN_OPERACA = '"+cOperacao+"' "
       cQry += "ORDER BY SZN.ZN_OPERACA, SZN.ZN_TRT "
       TCQUERY cQry ALIAS "PRO" NEW
Return

/***************************************************** FUNÇÃO PARA MONTAGEM DOS ACESSOS PARA ******************************************************/
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SENA01   ³ Autor ³ Luís G. de Souza      ³ Data ³ 17/11/09 ³±±
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
USER Function SENA01(cRotUsu)
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Local nOpc := GD_INSERT+GD_DELETE+GD_UPDATE
     Private aCoBrw1Sen := {}
     Private aHoBrw1Sen := {}
     Private cGet1Sen   := Iif(cRotUsu <> Nil, Iif(!Empty(cRotUsu), Alltrim(cRotUsu), space(10) ), space(10) )
     Private cRot1SZW   := Space(10)
     Private cGet2Sen   := Iif(!Empty(cRotUsu), Posicione("SZY", 1, xFilial("SZY")+cRotUsu, "ZY_NOMEROT"), Space(20))
     Private cSay1Sen   := Space(1)
     Private cSay2Sen   := Space(1)
     Private noBrw1Sen  := 0

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1Se", "oDlg1Sen", "oBtn1Sen", "oBtn2Sen", "oBtn3Sen", "oGrp1Sen", "oSay1Sen", "oSay2Sen", "oBrw1Sen")
     SetPrvt("oGet2Sen")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1Se   := TFont():New( "MS Sans Serif", 0, -16, , .F., 0, , 400, .F., .F., , , , , , )
     oDlg1Sen   := MSDialog():New( 095, 232, 365, 915, "Acessos de Usuários", , , .F., , , , , , .T., , , .T. )
     oBtn1Sen   := TButton():New( 004, 300, "Sair"    , oDlg1Sen, { || oDlg1Sen:End() }           , 037, 012, , , , .T., , "", , , , .F. )
     oBtn2Sen   := TButton():New( 004, 256, "Confirma", oDlg1Sen, { || fCon1Sen(), oDlg1Sen:End()}, 037, 012, , , , .T., , "", , , , .F. )
     oBtn3Sen   := TButton():New( 004, 004, "Usuários", oDlg1Sen, { || U_SENA02() }               , 037, 012, , , , .T., , "", , , , .F. )
     oGrp1Sen   := TGroup():New( 020, 004, 133, 340, "Acessos", oDlg1Sen, CLR_BLACK, CLR_WHITE, .T., .F. )
     oSay1Sen   := TSay():New( 032, 008, {||"Rotina:"}   , oGrp1Sen, , oFont1Se, .F., .F., .F., .T., CLR_HBLUE, CLR_WHITE, 032, 009)
     oGet1Sen   := TGet():New( 029, 052, {|u| If(PCount() > 0, cGet1Sen := u, cGet1Sen) }, oGrp1Sen, 064, 012, '', , CLR_BLACK, CLR_WHITE, oFont1Se, , , .T., "", , , .F., .F., , Iif(!Empty(cRotUsu), .T., .F.), .F., "", "cGet1Sen", , )
     oSay2Sen   := TSay():New( 052, 008, {||"Descrição:"}, oGrp1Sen, , oFont1Se, .F., .F., .F., .T., CLR_HBLUE, CLR_WHITE, 040, 009)
     oGet2Sen   := TGet():New( 049, 052, {|u| If(PCount() > 0, cGet2Sen := u, cGet2Sen) }, oGrp1Sen, 120, 012, '', , CLR_BLACK, CLR_WHITE, oFont1Se, , , .T., "", , , .F., .F., , Iif(!Empty(cRotUsu) .and. !Empty(cGet2Sen), .T., .F.), .F., "", "cGet2Sen", , )

     MHoBrw1Sen()
     MCoBrw1Sen()
     oBrw1Sen   := MsNewGetDados():New(024, 196, 130, 336, nOpc, 'AllwaysTrue()', 'AllwaysTrue()', '', , 1, 10, 'AllwaysTrue()', '', 'AllwaysTrue()', oGrp1Sen, aHoBrw1Sen, aCoBrw1Sen )
     oDlg1Sen:Activate(, , , .T.)
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fCon1Sen() - CONFIRMAÇÃO DAS ROTINAS
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fCon1Sen()
       Local nY
       For nY := 1 To Len(oBrw1Sen:aCols)
           DbSelectArea("SZY")
           DbSetOrder(2)
           DbSeek(xFilial("SZY")+cGet1Sen+oBrw1Sen:aCols[nY][1], .t.)
           If Found()
              RecLock("SZY", .f.)
                 SZY->ZY_NOMACS  := oBrw1Sen:aCols[nY][2]
                 SZY->ZY_DTALTER := dDataBase
                 SZY->ZY_NOMEROT := cGet2Sen
                 SZY->ZY_USERALT := cUserName
           Else
              RecLock("SZY", .t.)
                 SZY->ZY_FILIAL  := xFilial("SZY")
                 SZY->ZY_ROTINA  := cGet1Sen
                 SZY->ZY_NOMEROT := cGet2Sen
                 SZY->ZY_DTINCLU := dDataBase
                 SZY->ZY_USERINC := cUserName
                 SZY->ZY_ITEM    := oBrw1Sen:aCols[nY][1]
                 SZY->ZY_NOMACS  := oBrw1Sen:aCols[nY][2]
           Endif
           MsUnLock()
       Next
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrw1Sen() - Monta aHeader da MsNewGetDados para o Alias: SZY
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrw1Sen()
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SZY")
       While !Eof() .and. SX3->X3_ARQUIVO == "SZY"
             If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
                If Alltrim(SX3->X3_CAMPO) $ 'ZY_ITEM.ZY_NOMACS'
                   noBrw1Sen++
                   aAdd(aHoBrw1Sen,{Trim(( _cAliasSX3 )->( X3_TITULO )), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
                Endif
             EndIf
             DbSkip()
       End*/
       Local _cAliasSX3 := GetNextAlias() //LGS#20200211 - Adequação para release 12.1.25
       
       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200211 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )



       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("SZY") )
       While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SZY"
             If X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL )
                If Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZY_ITEM.ZY_NOMACS'
                   noBrw1Sen++
                   aAdd( aHoBrw1Sen, { Trim(( _cAliasSX3 )->( X3_TITULO )), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
                Endif
             EndIf
             DbSkip()
       End
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrw1Sen() - Monta aCols da MsNewGetDados para o Alias: TMPSEN
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrw1Sen()
       Local _nZ, nI
       For _nZ := 1 To 10
           aAdd(aCoBrw1Sen, Array(noBrw1Sen + 1))
           For nI := 1 To noBrw1Sen
               aCoBrw1Sen[_nZ][nI] := CriaVar(aHoBrw1Sen[nI][2])
           Next
           aCoBrw1Sen[_nZ][1] := StrZero(_nZ, 2)
           aCoBrw1Sen[_nZ][2] := Posicione("SZY", 2, xFilial("SZY")+cGet1Sen+aCoBrw1Sen[_nZ][1], "ZY_NOMACS")
           aCoBrw1Sen[_nZ][noBrw1Sen + 1] := .F.
       Next
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SENA02  ³ Autor ³ Luís G. de Souza      ³ Data ³ 17/11/09  ³±±
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
USER Function SENA02()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Local nOpcUsu     := GD_INSERT+GD_DELETE+GD_UPDATE
     Private aCoBrw1Usu := {}
     Private aHoBrw1Usu := {}
     Private cSay01Us   := Space(1)
     Private cSay02Us   := Space(1)
     Private cSay03Us   := Space(1)
     Private cSay04Us   := Space(1)
     Private cSay05Us   := Space(1)
     Private cSay06Us   := Space(1)
     Private cSay07Us   := Space(1)
     Private cSay08Us   := Space(1)
     Private cSay09Us   := Space(1)
     Private cSay10Us   := Space(1)
     Private oSay01Us
     Private oSay02Us
     Private oSay03Us
     Private oSay04Us
     Private oSay05Us
     Private oSay06Us
     Private oSay07Us
     Private oSay08Us
     Private oSay09Us
     Private oSay10Us
     Private noBrw1Usu  := 0

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oDlg1Usu", "oBrw1Usu", "oBtn1Usu", "oBtn2Usu", "oSay01Us", "oSay02Us", "oSay03Us", "oSay04Us", "oSay05Us", "oSay06Us")
     SetPrvt("oSay07Us", "oSay08Us", "oSay09Us", "oSay10Us")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oDlg1Usu   := MSDialog():New( 095, 232, 535, 920, "Usuarios", , , .F., , , , , , .T., , , .T. )
     oFont1Us   := TFont():New( "MS Sans Serif", 0, -13, , .T., 0, , 700, .F., .F., , , , , , )
     oBtn1Usu   := TButton():New( 002, 303, "Sair"    , oDlg1Usu, { || oDlg1Usu:End()            }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn2Usu   := TButton():New( 002, 256, "Confirma", oDlg1Usu, { || fCon1Usu(), oDlg1Usu:End()}, 037, 012, , , , .T., , "", , , , .F. )
     oSay01Us   := TSay():New( 152, 004, {|| cSay01Us}, oDlg1Usu, , oFont1Us, .F., .F., .F., .T., CLR_HRED , CLR_WHITE, 144, 009)
     oSay02Us   := TSay():New( 152, 196, {|| cSay02Us}, oDlg1Usu, , oFont1Us, .F., .F., .F., .T., CLR_HRED , CLR_WHITE, 144, 009)
     oSay03Us   := TSay():New( 165, 004, {|| cSay03Us}, oDlg1Usu, , oFont1Us, .F., .F., .F., .T., CLR_HRED , CLR_WHITE, 144, 009)
     oSay04Us   := TSay():New( 165, 196, {|| cSay04Us}, oDlg1Usu, , oFont1Us, .F., .F., .F., .T., CLR_HRED , CLR_WHITE, 144, 009)
     oSay05Us   := TSay():New( 178, 004, {|| cSay05Us}, oDlg1Usu, , oFont1Us, .F., .F., .F., .T., CLR_HRED , CLR_WHITE, 144, 009)
     oSay06Us   := TSay():New( 178, 196, {|| cSay06Us}, oDlg1Usu, , oFont1Us, .F., .F., .F., .T., CLR_HRED , CLR_WHITE, 144, 009)
     oSay07Us   := TSay():New( 191, 004, {|| cSay07Us}, oDlg1Usu, , oFont1Us, .F., .F., .F., .T., CLR_HRED , CLR_WHITE, 144, 009)
     oSay08Us   := TSay():New( 191, 196, {|| cSay08Us}, oDlg1Usu, , oFont1Us, .F., .F., .F., .T., CLR_HRED , CLR_WHITE, 144, 009)
     oSay09Us   := TSay():New( 204, 004, {|| cSay09Us}, oDlg1Usu, , oFont1Us, .F., .F., .F., .T., CLR_HRED , CLR_WHITE, 144, 009)
     oSay10Us   := TSay():New( 204, 196, {|| cSay10Us}, oDlg1Usu, , oFont1Us, .F., .F., .F., .T., CLR_HRED , CLR_WHITE, 144, 009)

     MHoBrw1Usu()
     MCoBrw1Usu()
     oBrw1Usu   := MsNewGetDados():New(018, 004, 146, 340, nOpcUsu, 'AllwaysTrue()', 'AllwaysTrue()', '', , 0, 99, 'AllwaysTrue()', '', 'AllwaysTrue()', oDlg1Usu, aHoBrw1Usu, aCoBrw1Usu )

     oDlg1Usu:Activate( , , , .T.)

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fCon1Usu() - CONFIRMAÇÃO DOS ACESSOS
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fCon1Usu()
       Local cRot1SZW := Stuff(cRot1SZW, 1, Len(cGet1Sen), cGet1Sen)
       Local nX, nY
       For nY := 1 To Len(oBrw1Usu:aCols)
           If oBrw1Usu:aCols[nY][noBrw1Usu+1]
              DbSelectArea("SZW")
              DbSetOrder(4)
              DbSeek(xFilial("SZW")+cRot1SZW+oBrw1Usu:aCols[nY][1], .t.)
              If Found()
                 RecLock("SZW", .f.)
                    DbDelete()
              Endif
           Else
              DbSelectArea("SZW")
              DbSetOrder(4)
              DbSeek(xFilial("SZW")+cRot1SZW+oBrw1Usu:aCols[nY][1], .t.)
              If Found()
                 RecLock("SZW", .f.)
                    SZW->ZW_DTALTER := dDataBase
                    SZW->ZW_USERALT := cUserName
                    SZW->ZW_DEPTO   := oBrw1Usu:aCols[nY][3]
              Else
                 RecLock("SZW", .t.)
                    SZW->ZW_FILIAL  := xFilial('SZW')
                    SZW->ZW_EMPFIL  := SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2)
                    SZW->ZW_DTINCLU := dDataBase
                    SZW->ZW_USERINC := cUserName
                    SZW->ZW_ROTINA  := cRot1SZW
                    SZW->ZW_USUARIO := oBrw1Usu:aCols[nY][1]
                    SZW->ZW_DEPTO   := oBrw1Usu:aCols[nY][3]
              Endif
              cAcesso := space(10)
              aPosica := {}
              For nX := 4 To Len(oBrw1Usu:aHeader)
                  aAdd(aPosica, {SubStr(oBrw1Usu:aHeader[nX][1], 1, 2), Iif(oBrw1Usu:aCols[nY][nX] $ 'S', '*', '') } )
              Next
              For nX := 1 To Len(aPosica)
                  cAcesso := Stuff(cAcesso, Val( aPosica[nX][1] ), 1, aPosica[nX][2])
              Next
              SZW->ZW_ACESSOS := cAcesso
           Endif
           MsUnLock()
       Next
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrw1Usu() - Monta aHeader da MsNewGetDados para o Alias: SZW
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrw1Usu()
       Local _nY
       Local _cAliasSX3 := GetNextAlias() //LGS#20200211 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SZW")
       While !Eof() .and. SX3->X3_ARQUIVO == "SZW"
             If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
                If Alltrim(SX3->X3_CAMPO) $ 'ZW_USUARIO.ZW_NOMUSER.ZW_DEPTO'
                   noBrw1Usu++
                   aAdd(aHoBrw1Usu, { Trim(( _cAliasSX3 )->( X3_TITULO )), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, "", SX3->X3_TIPO, "", "" } )
                Endif
             EndIf
             DbSkip()
       EndDo*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("SZW") )
       While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SZW"
             If X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL )
                If Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZW_USUARIO.ZW_NOMUSER.ZW_DEPTO'
                   noBrw1Usu++
                   aAdd(aHoBrw1Usu, { Trim(( _cAliasSX3 )->( X3_TITULO )), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
                 //aAdd(aHoBrw1Usu, { Trim(( _cAliasSX3 )->( X3_TITULO )),                SX3->X3_CAMPO,                SX3->X3_PICTURE,                SX3->X3_TAMANHO,                SX3->X3_DECIMAL,                SX3->X3_VALID, "",                SX3->X3_TIPO, "", "" } )
                Endif
             EndIf
             DbSkip()
       EndDo
       
       /*DbSetOrder(2)
       DbSeek("ZW_ACESSOS")
       For _nY := 1 To Len(oBrw1Sen:aCols)
           If !Empty(oBrw1Sen:aCols[_nY][2])
              noBrw1Usu++
              aAdd(aHoBrw1Usu, { Trim(oBrw1Sen:aCols[_nY][1]+'-'+oBrw1Sen:aCols[_nY][2]), SX3->X3_CAMPO, SX3->X3_PICTURE, 1, 0, "Pertence('SN')", "", SX3->X3_TIPO, "", "" } )
              &('cSay'+StrZero(_nY, 2)+'Us') := oBrw1Sen:aCols[_nY][1]+'-'+oBrw1Sen:aCols[_nY][2]
              &('oSay'+StrZero(_nY, 2)+'Us'):Refresh()
           Endif
       Next*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(2) )
       ( _cAliasSX3 )->( DbSeek("ZW_ACESSOS") )
       For _nY := 1 To Len( oBrw1Sen:aCols )
           If !Empty( oBrw1Sen:aCols[_nY][2] )
              noBrw1Usu++
              aAdd( aHoBrw1Usu, { Trim( oBrw1Sen:aCols[_nY][1]+'-'+oBrw1Sen:aCols[_nY][2]), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), 1, 0, "Pertence('SN')", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
              &('cSay'+StrZero(_nY, 2)+'Us') := oBrw1Sen:aCols[_nY][1]+'-'+oBrw1Sen:aCols[_nY][2]
              &('oSay'+StrZero(_nY, 2)+'Us'):Refresh()
           Endif
       Next
Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrw1Usu() - Monta aCols da MsNewGetDados para o Alias: SZW
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrw1Usu(nOpcUsu)
       Local cRot1SZW := Stuff(cRot1SZW, 1, Len(cGet1Sen), cGet1Sen)
       Local nX, _nY
       DbSelectArea("SZW")
       DbSetOrder(4)
       DbSeek(xFilial("SZW")+cRot1SZW, .t.)
       If Found()
          While !Eof() .and. Alltrim(SZW->ZW_ROTINA) == Alltrim(cRot1SZW)
                aAdd(aCoBrw1Usu, Array(noBrw1Usu+1))
                aCoBrw1Usu[Len(aCoBrw1Usu)][1] := SZW->ZW_USUARIO
                aCoBrw1Usu[Len(aCoBrw1Usu)][2] := UsrRetName(SZW->ZW_USUARIO)
                aCoBrw1Usu[Len(aCoBrw1Usu)][3] := SZW->ZW_DEPTO
                aPosica := {}
                For nX := 4 To Len(aHoBrw1Usu)
                    aAdd(aPosica, {SubStr(aHoBrw1Usu[nX][1], 1, 2), Iif(SubStr(SZW->ZW_ACESSOS, Val( SubStr(aHoBrw1Usu[nX][1], 1, 2) ), 1) $ '*', 'S', 'N') } )
                Next
                For nX := 1 To Len(aPosica)
                    aCoBrw1Usu[Len(aCoBrw1Usu)][nX + 3] := aPosica[nX][2]
                Next
                aCoBrw1Usu[Len(aCoBrw1Usu)][noBrw1Usu+1] := .F.
                DbSelectArea("SZW")
                DbSkip()
          Enddo
       Else
          aAdd(aCoBrw1Usu, Array(noBrw1Usu+1))
          For _nY := 1 To noBrw1Usu
              If !Alltrim(aHoBrw1Usu[_nY][2]) == Alltrim('ZW_ACESSOS')
                 aCoBrw1Usu[1][_nY] := CriaVar(aHoBrw1Usu[_nY][2])
              Else
                 aCoBrw1Usu[1][_nY] := space(1)
              Endif
          Next
          aCoBrw1Usu[1][noBrw1Usu+1] := .f.
       Endif
Return
/**************************************************************************************************************************************************/

/******************************************** FUNÇÃO PARA CONSULTA DE ACESSO ESPECÍFICOS PARA USUÁRIOS ********************************************/
/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fVerAcsUsr() - Verificação de acesso de usuário
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
User Function fVerAcsUsr(cRotUsu, nPosAcs, cChkUsu, cDepUsu, cTipFil)
     Local lRet     := .f.
     Local cRot1Usu := Space(10)
     Local lVerOutr := Iif(cChkUsu == Nil, .f., .t.)
     Local cVerUsua := Iif(cChkUsu == Nil, __CUSERID, cChkUsu)

     cRot1Usu := Stuff(cRot1Usu, 1, Len(cRotUsu), cRotUsu)
     cGrpUsr  := u_fRetGrupoUser()
     If !lVerOutr
        DbSelectArea("SZM")
        If __CUSERID $ '000000' 
           If !Empty(cGrpUsr)
              If cGrpUsr $ '000000'
                 lRet    := .t.
                 cDepUsu := "DIR"
              Else
                 lRet := .f.
              Endif
           Else
              lRet := .f.
           Endif
        Else
           If !Empty(cGrpUsr)
              If cGrpUsr $ '000000'
                 lRet    := .t.
                 cDepUsu := "DIR"
              Else
                 DbSelectArea("SZW")
                 DbSetOrder(4)
                 DbSeek(xFilial("SZW")+cRot1Usu+cVerUsua, .t.)
                 If Found()
                    lRet    := !Empty(SubStr(SZW->ZW_ACESSOS, nPosAcs, 1))
                    cDepUsu := SZW->ZW_DEPTO
                    cTipFil := SubStr(SZW->ZW_ACESSOS, 3, 2)
                 Else
                    lRet := .f.
                 Endif
              Endif
           Else
              DbSelectArea("SZW")
              DbSetOrder(4)
              DbSeek(xFilial("SZW")+cRot1Usu+cVerUsua, .t.)
              If Found()
                 lRet    := !Empty(SubStr(SZW->ZW_ACESSOS, nPosAcs, 1))
                 cDepUsu := SZW->ZW_DEPTO
                 cTipFil := SubStr(SZW->ZW_ACESSOS, 3, 2)
              Else
                 lRet := .f.
              Endif
           Endif
        Endif
     Else
        DbSelectArea("SZW")
        DbSetOrder(4)
        DbSeek(xFilial("SZW")+cRot1Usu+cVerUsua, .t.)
        If Found()
           lRet    := !Empty(SubStr(SZW->ZW_ACESSOS, nPosAcs, 1))
           cDepUsu := SZW->ZW_DEPTO
           cTipFil := SubStr(SZW->ZW_ACESSOS, 3, 2)
        Else
           lRet := .f.
        Endif
     Endif
Return(lRet)

User Function fRetGrupoUser()
       //Local cGrpUse := ""
       Local nX
       //Tratamento para grupo de usuários
       DbSelectArea("SZM")
       aGrpUsr := UsrRetGrp()
       cGrpUsr := ""
       For nX := 1 To Len(aGrpUsr)
           If nX == 1
              cGrpUsr += aGrpUsr[1]
           Else
              cGrpUsr += "."+aGrpUsr[1]
           Endif
       Next
Return(cGrpUsr)

  /****************************************************************************/
  /*** BUSCA MOTIVO DA REVISÃO                                              ***/
  /*** Parâmetros: ExpC1 - Identificador do Log                             ***/
  /***             ExpC2 - Processo             (SI=Simulação)              ***/
  /***             ExpC3 - Status               (EE=Inclusão de Simulação)  ***/
  /***                                                                      ***/
  /****************************************************************************/
User Function fBuscaHistorico(cIdLog, cPrLog, cStaLog)
     DbSelectArea("SZT")
     DbSetOrder(2)
     DbSeek(xFilial("SZT")+cIdLog+cPrLog+cStaLog,.t.)
     If Found()
        If Empty(SZT->ZT_LOG)
           cLog := "."
        Else
           cLog := SZT->ZT_LOG
        Endif
     Else
        DbSelectArea("SZT")
        DbSetOrder(1)
        DbSeek(xFilial("SZT")+cIdLog,.t.)
        If Found()
           cLog := SZT->ZT_LOG
        Else
           cLog := "."
        Endif
     Endif
Return(cLog)

Static Function fCalculaPr(nCustoMP, cTipoSim, cOpcPrg)
       Local nPrec1 := 0                       //Variável de retorno para o preço de venda
       Local nPrec2 := 0                       //Variável de retorno para o preço de venda
       Local nJuros := GETMV('MV_JUROS') / 100 //Taxa de Juros
       Local cCondP := GETMV('MV_SIMCOND')     //Condicao de Pagamento
       Local nIcmsP := GETMV("MV_ICMPAD")      //ICMS Padrão
       Local cTxtPg := ""
       Local aPrazo := {}
       Local cPlani := Iif( cNumEmp = '01010101', 'BRASILUX', Iif( cNumEmp = '01010104', 'RESINA', Iif( cNumEmp = '01060101', 'DISSOLTEX', Iif( cNumEmp = '05', 'UNIONSUR', 'SEMPLANI' ) ) ) )+'.PDV'
       Local nArqPl := fOpen(cPlani)
       Local nTArqu := 0
       Local nLidos := 0
       Local cLinha := ""
       Local nUsaPl := 0
       //Local nVarPl := ""
       Local lOkPla
       Local aAuxPl, _nY

       //Busca prazos em dias, para condição de pagamento
       DbSelectArea("SE4")
       DbSetOrder(1)
       DbSeek(xFilial("SE4")+cCondP, .t.)
       If Found()
          If SE4->E4_TIPO == "1"
             cTxtPg := Alltrim(SE4->E4_COND)+Iif( !SubStr( Alltrim(SE4->E4_COND), Len( Alltrim(SE4->E4_COND) ), 1 ) $ ",", ",", "")
             While !Empty( Alltrim( cTxtPg ) )
                   aAdd( aPrazo, Val( SubStr( cTxtPg, 1, Iif( At( ",", cTxtPg ) == 0, Len(cTxtPg), At( ",", cTxtPg ) - 1 ) ) ) )
                   cTxtPg := Alltrim( SubStr( cTxtPg, At( ",", cTxtPg ) + 1, Len( cTxtPg ) ) )
             EndDo
          Else
             MsgStop("Atenção, condição de pagamento não é do tipo 1. Será utilizado o prazo de 60 dias!", "Atenção...")
             aAdd(aPrazo, 60)
          Endif
       Else
          MsgStop("Atenção, condição de pagamento não encontrada. Será utilizado o prazo de 60 dias!", "Atenção...")
          aAdd(aPrazo, 60)
       Endif

       //Busca informações da Planilha
       If nArqPl > 0
          fSeek(nArqPl, 0, 0)
          nTArqu := fSeek(nArqPl, 0, 2)
          fSeek(nArqPl, 0, 0)
          lOkPla := .f.
          aAuxPl := {}
          While nLidos < nTArqu
                cLinha = U_fGets(nArqPl, nTArqu)
                If (SubStr(cLinha, 6, 3) $ "PIS_IVA") 
                   lOkPla = .t.
                Endif
                If lOkPla
                   nUsaPl += 1
                   cVarPl := "V"+Alltrim( Str( nUsaPl ) )
                   aAdd( aAuxPl, { cVarPl, U_cTon( Alltrim( SubStr( cLinha, 36, 10) ) ) })
                Endif
                If SubStr(cLinha, 6, 16) == "DESP. COMERCIAIS"
                   lOkPla := .f.
                Endif
                nLidos += Len(cLinha) + 2
          EndDo
          fClose(nArqPl)
       Else
          MsgStop("Planilha não pode ser aberta, verifique se o arquivo "+cPlani+" existe.", "Atenção...")
          Return({nPrec1, nPrec2})
       Endif

       //Busca Informações de Mão de Obra, Lucro, Lucro 2 e Comissão
       nMaoObra := fCalPrc("MO", cTipoSim, cOpcPrg)
       nLucroPr := fCalPrc("LU", cTipoSim, cOpcPrg)
       nLucr2Pr := fCalPrc("L2", cTipoSim, cOpcPrg)
       nComissa := fCalPrc("CO", cTipoSim, cOpcPrg)

       //Calculo de Juros pela condição de pagamento
       nAuxJu := 0
       For _nY := 1 To Len(aPrazo)
           nAuxJu += 1 / ( ( 1 + ( nJuros ) ) ^ ( ( 12 * aPrazo[_nY] ) / 365 ) )
       Next
       nJuros := ( 1 / Len(aPrazo) ) * nAuxJu

       //Calculo dos Impostos
       nPercI := 0
       For _nY := 1 To Len(aAuxPl)
          nPercI += aAuxPl[_nY][2]
       Next

       //Calculo do Preço de Vendas
       nPrec1   := ( nCustoMP + nMaoObra ) / ( nJuros - ( ( nPercI + nIcmsP + nLucroPr + nComissa ) / 100 ) )
       nPrec2   := ( nCustoMP + nMaoObra ) / ( nJuros - ( ( nPercI + nIcmsP + nLucr2Pr + nComissa ) / 100 ) )
Return( {nPrec1, nPrec2} )

Static Function fCalPrc(cTipoBusca, cTipoSim, cOpcPrg)
       Local nValorBusca := 0
       Local cTipoProdut := Iif(cOpcPrg $ 'M', M->ZM_TIPOPRO, TMPLIB->LIBSTP)
       Local cCodProduto := Iif(cOpcPrg $ 'M', M->ZM_CODIGO , TMPLIB->LIBPRO)
       Private aArray := Array(1, 4) //Array com Produto, para fins de calc prc tabela, usado tb nas planilhas
       aArray[1][4] := cCodProduto
       If cTipoProdut $ 'PE'                //Produto Existente
          If cTipoSim $ "VIG.REV"             //Fórmula Vigente/Revisão
             DbSelectArea("SB1")
             DbSetOrder(1)
             DbSeek(xFilial("SB1")+cCodProduto, .t.)
             If Found()
				nValorBusca := EXECBLOCK("BRPCP011",.F.,.F.,cTipoBusca) 
    			/*	//Cleber (01/06/2012)
                If Len( AllTrim( cCodProduto ) ) == 12   
                   If cTipoBusca == "MO"      //Mão de Obra
                      	nValorBusca := Posicione("SZ5", 1, xFilial("SZ5")+SubStr(cCodProduto, 11, 02), "Z5_VOLUME") * Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodProduto, 04, 02), "Z1_VLRMO") 
                   ElseIf cTipoBusca == "LU"  //Lucro
						nValorBusca := Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodProduto, 4, 2), "Z1_LUCRO")
                   ElseIf cTipoBusca == "L2"  //Lucro 2
						nValorBusca := Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodProduto, 4, 2), "Z1_LUCRO2")
                   ElseIf cTipoBusca == "CO"  //Comissão
						nValorBusca := Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodProduto, 4, 2), "Z1_COMISSA")
                   Endif     
                Else
                   If cTipoBusca == "MO"      //Mão de Obra
                      nValorBusca := SB1->B1_VLRMO
                   ElseIf cTipoBusca == "LU"  //Lucro
                          nValorBusca := SB1->B1_LUCRO
                   ElseIf cTipoBusca == "L2"  //Lucro 2
                          nValorBusca := SB1->B1_LUCRO2
                   ElseIf cTipoBusca == "CO"  //Comissão
                          nValorBusca := SB1->B1_COMIS
                   Endif
                Endif
                */
             Endif
          Endif
       ElseIf cTipoProdut $ 'PN' //Produto Novo
              If Len( AllTrim( cCodProduto ) ) == 12
                 If cTipoBusca == "MO"      //Mão de Obra
                    nValorBusca := Posicione("SZ5", 1, xFilial("SZ5")+SubStr(cCodProduto, 11, 02), "Z5_VOLUME") * Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodProduto, 04, 02), "Z1_VLRMO") 
                 ElseIf cTipoBusca == "LU"  //Lucro
                        nValorBusca := Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodProduto, 4, 2), "Z1_LUCRO")
                 ElseIf cTipoBusca == "L2"  //Lucro 2
                        nValorBusca := Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodProduto, 4, 2), "Z1_LUCRO2")
                 ElseIf cTipoBusca == "CO"  //Comissão
                        nValorBusca := Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodProduto, 4, 2), "Z1_COMISSA")
                 Endif
              Else
                 MsgStop("Informação precisa ser calculada")
              Endif
       Endif
Return(nValorBusca)

Static Function QuantDecimais(nQtdEntr)
       Local nCasDeci := 3
       Local nQtdDest := Round(0, nCasDeci)
       Local cQtdDest := ""

       If nQtdEntr # Nil .and. ValType(nQtdEntr) == 'N'
          nQtdDest := Round(nQtdEntr, nCasDeci)
          cQtdDest := Str(nQtdDest, 30, nCasDeci)
          nQtdDest := Val(cQtdDest)
       EndIf
Return(nQtdDest)

Static Function fMontaATecn(nOpcCha)
       Local nOpcAte := Iif(Len(aResultX) == 0, GD_INSERT+GD_DELETE+GD_UPDATE, 0) 
       Local nOpcA   := 0
       Local nY
       Private aFldATec := {"Analise", "Aceite"}
       Private aCoBrw1Ate := {}
       Private aHoBrw1Ate := {}
       Private noBrw1Ate  := 0
       Private nCBox1En
       Private aVetEnsa   := {'01'}
       Private nCBox2Ac
       Private aVetAcei   := {' ', 'Cliente', 'Ger. Produção', 'Usuário'}
       Private cSay1Ens   := ''
       Private cF3Aceit   := ''
       Private cGet1Ens   := space(06)
       Private cGet2Ens   := space(40)
       Private cMGet1En   := ''
       
       SetPrvt("oDlg1ATe", "oFld1Ate", "oCBox1En", "oMGet1En")
       
       If nOpcCha $ 'T'
          aAdd(aVetEnsa, StrZero(Len(aVetEnsa)+1, 2) )
       Endif
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oDlg1Ate   := MSDialog():New( 091, 352, 423, 1043, "Analise Técnica de Amostra Inicial", , , .F., , , , ,  , .T., , , .T. )
       oFont1En   := TFont():New( "MS Sans Serif",0,-19,,.F.,0,,400,.F.,.F.,,,,,, )
       oCBox1En   := TComboBox():New( 1.50, 004, {|u| If(PCount()>0,nCBox1En:=u,nCBox1En)}, aVetEnsa, 024, 016, oDlg1Ate, , { || AltSeqTes('1') }, , CLR_BLACK, CLR_WHITE, .T.,oFont1En, "",,,,,,,nCBox1En )
       oBtn1Ate   := TButton():New( 0.75, 030, "Nova Análise"     , oDlg1Ate, { || nOpcA := 2, oDlg1Ate:End()                          }, 056, 012, , , , .T., , "", , , , .F. )
       oBtn2Ate   := TButton():New( 0.75, 224, "Confirma"         , oDlg1Ate, { || nOpcA := 1, nTipAce := oCBox2Ac:nAt, oDlg1Ate:End() }, 056, 012, , , , .T., , "", , , , .F. )
       oBtn3Ate   := TButton():New( 0.75, 284, "Sair"             , oDlg1Ate, { || nOpcA := 0, oDlg1Ate:End()                          }, 056, 012, , , , .T., , "", , , , .F. )
       oFld1Ate   := TFolder():New( 016, 004, aFldATec, {}, oDlg1Ate, , , , .T., .F., 340, 144, )
       MHoBrw1Ate()
       MCoBrw1Ate()
       oBrw1Ate   := MsNewGetDados():New(003, 003, 127, 337, nOpcAte, 'AllwaysTrue()', 'AllwaysTrue()', '+ZZD_SEQ', , 0, 99, 'AllwaysTrue()', '', 'AllwaysTrue()', oFld1Ate:aDialogs[1], aHoBrw1Ate, aCoBrw1Ate )
       oBrw1Ate:oBrowse:nFreeze := 3
       
       oCBox2Ac   := TComboBox():New( 003, 003, {|u| If(PCount()>0, nCBox2Ac:=u, nCBox2Ac)}, aVetAcei, 084, 016, oFld1Ate:aDialogs[2], , { || AltSeqTes('2') }, , CLR_BLACK, CLR_WHITE, .T.,oFont1En, "",,,,,,,nCBox2Ac )
       oSay1Ens   := TSay():New( 022, 003, {|| cSay1Ens}, oFld1Ate:aDialogs[2], , oFont1En, .F., .F., .F., .T., CLR_BLUE , CLR_WHITE, 046, 012)
       oGet1Ens   := TGet():New( 021, 050, {|u| If(PCount() > 0, cGet1Ens := u, cGet1Ens)}, oFld1Ate:aDialogs[2], 056, 014, '', , CLR_BLACK, CLR_WHITE, oFont1En, , , .T., "", , , .F., .F., , .F., .F., cF3Aceit, "cGet1Ens", , )
       oGet2Ens   := TGet():New( 021, 110, {|u| If(PCount() > 0, cGet2Ens := u, cGet2Ens)}, oFld1Ate:aDialogs[2], 224, 014, '', , CLR_BLACK, CLR_WHITE, oFont1En, , , .T., "", , , .F., .F., , .T., .F., ""      , "cGet2Ens", , )
       oSay2Ens   := TSay():New( 041, 003, {|| "Observ.:"}, oFld1Ate:aDialogs[2], , oFont1En, .F., .F., .F., .T., CLR_BLUE , CLR_WHITE, 046, 012)
       oMGet1En   := TMultiGet():New( 040, 050, {|u| If(PCount() > 0, cMGet1En := u, cMGet1En)}, oFld1Ate:aDialogs[2], 284, 048, , , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .F., , , .F., ,  )
       oGet1Ens:bValid := {|| fValAceiteAt() }
       If nOpcAte == 0 //Já foi dado aceite
          nCBox2Ac := aResultX[1][1]
          oCBox2Ac:lReadOnly := .t.
          cSay1Ens     := Iif(oCBox2Ac:nAt == 2, 'Cliente:', Iif(oCBox2Ac:nAt == 3, 'Ger. Prod.:', 'Usuário:') )
          oGet1Ens:cF3 := Iif(oCBox2Ac:nAt == 2, 'CLI'     , Iif(oCBox2Ac:nAt == 3, 'XXXQIY', 'XXXQIY') )
          oSay1Ens:lVisible  := .t.
          oGet1Ens:lVisible  := .t.
          cGet1Ens := Alltrim(aResultX[1][4])
          oGet2Ens:lVisible  := .t.
          cGet2Ens := Iif(aResultX[1][1] == 2, Posicione("SA1", 1, xFilial("SA1")+aResultX[1][4], "A1_NOME"), u_SI_NUSR(SubStr(aResultX[1][4], 1, 2), Alltrim(aResultX[1][4]), .t.,"N"))
          oMGet1En:lVisible  := .t.
          cMGet1En := aResultX[1][5]
          oMGet1En:lReadOnly := .t.
       Else
          oSay1Ens:lVisible := .f.
          oSay2Ens:lVisible := .f.
          oGet1Ens:lVisible := .f.
          oGet2Ens:lVisible := .f.
          oMGet1En:lVisible := .f.
       Endif 
       oDlg1Ate:Activate(, , , .T.)
       If nOpcA == 1
          aResultA := {}
          aResultX := {}
          For nY := 1 To Len(oBrw1Ate:aCols)
              If !oBrw1Ate:aCols[nY][noBrw1Ate+1]
                 aAdd(aResultA, {xFilial('ZZD'), M->ZM_CODIGO, M->ZM_REVISAO, nCBox1En, oBrw1Ate:aCols[nY][1], oBrw1Ate:aCols[nY][2], oBrw1Ate:aCols[nY][3], oBrw1Ate:aCols[nY][4], oBrw1Ate:aCols[nY][5], oBrw1Ate:aCols[nY][6], oBrw1Ate:aCols[nY][7], oBrw1Ate:aCols[nY][8], oBrw1Ate:aCols[nY][9], oBrw1Ate:aCols[nY][10], oBrw1Ate:aCols[nY][11], oBrw1Ate:aCols[nY][12], oBrw1Ate:aCols[nY][13], oBrw1Ate:aCols[nY][14], oBrw1Ate:aCols[nY][15], oBrw1Ate:aCols[nY][16]  } )
              Endif
          Next
          cObsMsg := Alltrim(cUserName)+" ("+dToc(dDataBase)+" "+Time()+"):"+Chr(13)+chr(10)
          cObsMsg += Upper(cMGet1En)+Chr(13)+chr(10)+Chr(13)+chr(10)
          aAdd(aResultX, {nTipAce, dDataBase, Time(), cGet1Ens, cObsMsg} )
       ElseIf nOpcA == 2
              //Verificar se todos as analises estão com resultados.
              lSemResp := .f.
              aResultA := {}
              For nY := 1 To Len(oBrw1Ate:aCols)
                  If !oBrw1Ate:aCols[nY][noBrw1Ate+1]
                     If Empty(oBrw1Ate:aCols[nY][16])
                        lSemResp := .t.
                     Endif
                     aAdd(aResultA, {xFilial('ZZD'), M->ZM_CODIGO, M->ZM_REVISAO, nCBox1En, oBrw1Ate:aCols[nY][1], oBrw1Ate:aCols[nY][2], oBrw1Ate:aCols[nY][3], oBrw1Ate:aCols[nY][4], oBrw1Ate:aCols[nY][5], oBrw1Ate:aCols[nY][6], oBrw1Ate:aCols[nY][7], oBrw1Ate:aCols[nY][8], oBrw1Ate:aCols[nY][9], oBrw1Ate:aCols[nY][10], oBrw1Ate:aCols[nY][11], oBrw1Ate:aCols[nY][12], oBrw1Ate:aCols[nY][13], oBrw1Ate:aCols[nY][14], oBrw1Ate:aCols[nY][15], oBrw1Ate:aCols[nY][16]  } )
                  Endif
              Next
              If !lSemResp
                 //Pedir confirmação do usuário se deseja carregar uma nova análise
                 If MsgYesNo("Deseja mesmo gerar uma nova análise?")
                    //Ajustar variáveis
                    //Fazer nova chamada da tela de análise
                    fMontaATecn("T")
                 Endif
              Else
                 fMontaATecn("N")
              Endif
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrw1Ate() - Monta aHeader da MsNewGetDados para o Alias: ZZD
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrw1Ate()
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("ZZD")
       While !Eof() .and. SX3->X3_ARQUIVO == "ZZD"
             If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
                noBrw1Ate++
                aAdd(aHoBrw1Ate, {Trim(( _cAliasSX3 )->( X3_TITULO )),;
                     SX3->X3_CAMPO,;
                     SX3->X3_PICTURE,;
                     SX3->X3_TAMANHO,;
                     SX3->X3_DECIMAL,;
                     SX3->X3_VALID,;
                     SX3->X3_USADO,;
                     SX3->X3_TIPO,;
                     SX3->X3_F3,;
                     SX3->X3_CONTEXTO,;
                     SX3->X3_CBOX,;
                     SX3->X3_RELACAO,;
                     SX3->X3_WHEN,;
                     SX3->X3_VISUAL,;
                     SX3->X3_VLDUSER,;
                     SX3->X3_PICTVAR,;
                     SX3->X3_OBRIGAT } )
             EndIf
             DbSkip()
       EndDo*/
       Local _cAliasSX3 := GetNextAlias() //LGS#20200211 - Adequação para release 12.1.25
       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200211 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )

       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("ZZD") )
       While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "ZZD"
             If X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL )
                noBrw1Ate++
                aAdd( aHoBrw1Ate, { Trim(( _cAliasSX3 )->( X3_TITULO )), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_F3 ), ( _cAliasSX3 )->( X3_CONTEXTO ), ( _cAliasSX3 )->( X3_CBOX ), ( _cAliasSX3 )->( X3_RELACAO ),( _cAliasSX3 )->( X3_WHEN ), ( _cAliasSX3 )->( X3_VISUAL ), ( _cAliasSX3 )->( X3_VLDUSER ), ( _cAliasSX3 )->( X3_PICTVAR ), ( _cAliasSX3 )->( X3_OBRIGAT ) } )
             EndIf
             DbSkip()
       EndDo
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrw1Ate() - Monta aCols da MsNewGetDados para o Alias: ZZD
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrw1Ate()
       //Local aAux := {}
       Local cQry1 := ""
       Local nI, nY
       If INCLUI
          //Busca nas especificações
          cQry1 := ""
          cQry1 += "SELECT TOP 1 * "
          cQry1 += "FROM "+RetSQLName("QP6")+" QP6  WITH (NOLOCK) "
          cQry1 += "WHERE QP6.QP6_FILIAL = '"+xFilial("QP6")+"' "
          cQry1 += "  AND QP6.D_E_L_E_T_ = '' "
          cQry1 += "  AND QP6.QP6_SITREV = '0' "
          cQry1 += "  AND SUBSTRING(QP6.QP6_PRODUT, 4, 2) = '"+SubStr(M->ZM_CODIGO, 4, 2)+"' "
          cQry1 += "ORDER BY QP6.QP6_PRODUT, QP6.QP6_REVINV "
          TCQuery cQry1 ALIAS "TENS" NEW
          DbSelectArea("TENS")
          cProdEns := TENS->QP6_PRODUT
          cReviEns := TENS->QP6_REVI
          DbSelectArea("TENS")
          DbCloseArea()
       Endif
          //Busca se já houve cadastro anterior, senão busca nas especificações
          If Len(aResultA) > 0
             For nY := 1 To Len(aResultA)
                 aAdd(aCoBrw1Ate, Array(noBrw1Ate+1))
                 For nI := 5 To noBrw1Ate + 4
                     aCoBrw1Ate[Len(aCoBrw1Ate)][nI-4] := aResultA[nY][nI]
                 Next
                 aCoBrw1Ate[Len(aCoBrw1Ate)][noBrw1Ate + 1] := .F.
             Next
          Else
             DbSelectArea("ZZD")
             DbSetOrder(1)
             DbSeek(xFilial("ZZD")+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
             If Found()
                cProdEns := ZZD->ZZD_CODIGO
                cReviEns := ZZD->ZZD_REVISA
             Else
                //Busca nas especificações
                cQry1 := ""
                cQry1 += "SELECT TOP 1 * "
                cQry1 += "FROM "+RetSQLName("QP6")+" QP6  WITH (NOLOCK) "
                cQry1 += "WHERE QP6.QP6_FILIAL = '"+xFilial("QP6")+"' "
                cQry1 += "  AND QP6.D_E_L_E_T_ = '' "
                cQry1 += "  AND QP6.QP6_SITREV = '0' "
                cQry1 += "  AND SUBSTRING(QP6.QP6_PRODUT, 4, 2) = '"+SubStr(M->ZM_CODIGO, 4, 2)+"' "
                cQry1 += "ORDER BY QP6.QP6_PRODUT, QP6.QP6_REVINV "
                TCQuery cQry1 ALIAS "TENS" NEW
                DbSelectArea("TENS")
                cProdEns := TENS->QP6_PRODUT
                cReviEns := TENS->QP6_REVI
                DbSelectArea("TENS")
                DbCloseArea()
             Endif
             If !Empty(cProdEns)
                cQry1 := ""
                cQry1 += "SELECT QP7.QP7_SEQLAB, QP7.QP7_ENSAIO, QP1.QP1_DESCPO, QP1.QP1_CARTA, QP7.QP7_MINMAX, QP7.QP7_LIE, QP7.QP7_NOMINA, QP7.QP7_LSE, ' ' AS QP8_TEXTO "
                cQry1 += "FROM "+RetSQLName("QP7")+" QP7 WITH (NOLOCK) "
                cQry1 += "LEFT OUTER JOIN QP1010 QP1 ON QP1.QP1_FILIAL = QP7.QP7_FILIAL AND QP1.QP1_ENSAIO = QP7.QP7_ENSAIO AND QP1.D_E_L_E_T_ = '' "
                cQry1 += "WHERE QP7.QP7_FILIAL = '"+xFilial("QP7")+"' "
                cQry1 += "  AND QP7.D_E_L_E_T_ = '' "
                cQry1 += "  AND QP7.QP7_PRODUT = '"+cProdEns+"' "
                cQry1 += "  AND QP7.QP7_REVI   = '"+cReviEns+"' "
                cQry1 += "UNION ALL "
                cQry1 += "SELECT QP8.QP8_SEQLAB, QP8.QP8_ENSAIO, QP1.QP1_DESCPO, QP1.QP1_CARTA, ' ', ' ', ' ', ' ', QP8.QP8_TEXTO "
                cQry1 += "FROM "+RetSQLName("QP8")+" QP8 WITH (NOLOCK) "
                cQry1 += "LEFT OUTER JOIN QP1010 QP1 ON QP1.QP1_FILIAL = QP8.QP8_FILIAL AND QP1.QP1_ENSAIO = QP8.QP8_ENSAIO AND QP1.D_E_L_E_T_ = '' "
                cQry1 += "WHERE QP8.QP8_FILIAL = '"+xFilial("QP8")+"' "
                cQry1 += "  AND QP8.D_E_L_E_T_ = '' "
                cQry1 += "  AND QP8.QP8_PRODUT = '"+cProdEns+"' "
                cQry1 += "  AND QP8.QP8_REVI   = '"+cReviEns+"' "
                cQry1 += "ORDER BY QP7.QP7_SEQLAB "
                TCQuery cQry1 ALIAS "TENS" NEW
                DbSelectArea("TENS")
                While !Eof()
                      aAdd(aCoBrw1Ate, Array(noBrw1Ate+1))
                      For nI := 1 To noBrw1Ate
                          If !aHoBrw1Ate[nI][10] $ 'V'
                             If Alltrim(aHoBrw1Ate[nI][2]) $ 'ZZD_SEQ'
                                aCoBrw1Ate[Len(aCoBrw1Ate)][nI] := TENS->QP7_SEQLAB
                             ElseIf Alltrim(aHoBrw1Ate[nI][2]) $ 'ZZD_ENSAIO'
                                    aCoBrw1Ate[Len(aCoBrw1Ate)][nI] := TENS->QP7_ENSAIO
                             ElseIf Alltrim(aHoBrw1Ate[nI][2]) $ 'ZZD_CARTA'
                                    aCoBrw1Ate[Len(aCoBrw1Ate)][nI] := TENS->QP1_CARTA
                             ElseIf Alltrim(aHoBrw1Ate[nI][2]) $ 'ZZD_MINMAX'
                                    aCoBrw1Ate[Len(aCoBrw1Ate)][nI] := TENS->QP7_MINMAX
                             ElseIf Alltrim(aHoBrw1Ate[nI][2]) $ 'ZZD_LIE'
                                    aCoBrw1Ate[Len(aCoBrw1Ate)][nI] := TENS->QP7_LIE
                             ElseIf Alltrim(aHoBrw1Ate[nI][2]) $ 'ZZD_NOMINA'
                                    aCoBrw1Ate[Len(aCoBrw1Ate)][nI] := TENS->QP7_NOMINA
                             ElseIf Alltrim(aHoBrw1Ate[nI][2]) $ 'ZZD_LIS'
                                    aCoBrw1Ate[Len(aCoBrw1Ate)][nI] := TENS->QP7_LSE
                             ElseIf Alltrim(aHoBrw1Ate[nI][2]) $ 'ZZD_TEXTO'
                                    aCoBrw1Ate[Len(aCoBrw1Ate)][nI] := TENS->QP8_TEXTO
                             ElseIf Alltrim(aHoBrw1Ate[nI][2]) $ 'ZZD_DATAME'
                                    aCoBrw1Ate[Len(aCoBrw1Ate)][nI] := dDataBase
                             ElseIf Alltrim(aHoBrw1Ate[nI][2]) $ 'ZZD_HORAME'
                                    aCoBrw1Ate[Len(aCoBrw1Ate)][nI] := Time()
                             ElseIf Alltrim(aHoBrw1Ate[nI][2]) $ 'ZZD_MEDNUM'
                                    nRetu := 0
                                    cValor := aCoBrw1Ate[Len(aCoBrw1Ate)][7]
                                    nTam  := Len(AllTrim(cValor))
                                    nPos  := At(',', Alltrim(cValor))
                                    nDecim:= Iif(nPos <> 0, nTam-nPos, nRetu)
                                    If nPos == 0
                                       cPict := "@E "+Replicate('9',nTam)
                                    Else
                                       cPict := "@E "+Replicate('9',nTam-(nDecim + 1) ) + '.' + Replicate('9', nDecim)
                                    Endif
                                    aCoBrw1Ate[Len(aCoBrw1Ate)][nI] := TransForm(Space(08), cPict)
                             Else
                                aCoBrw1Ate[Len(aCoBrw1Ate)][nI] := CriaVar(aHoBrw1Ate[nI][2])
                             Endif
                          Else
                             If Alltrim(aHoBrw1Ate[nI][2]) $ 'ZZD_DESENS'
                                aCoBrw1Ate[Len(aCoBrw1Ate)][nI] := TENS->QP1_DESCPO
                             Else
                                aCoBrw1Ate[Len(aCoBrw1Ate)][nI] := CriaVar(aHoBrw1Ate[nI][2])
                             Endif
                          Endif
                      Next
                      aCoBrw1Ate[Len(aCoBrw1Ate)][noBrw1Ate+1] := .F.
                      DbSelectArea("TENS")
                      DbSkip()
                EndDo
                DbSelectArea("TENS")
                DbCloseArea()
             Else
                aAdd(aCoBrw1Ate, Array(noBrw1Ate+1))
                For nI := 1 To noBrw1Ate
                    aCoBrw1Ate[1][nI] := CriaVar(aHoBrw1Ate[nI][2])
                Next
                aCoBrw1Ate[1][noBrw1Ate+1] := .F.
             Endif
          Endif
          DbSelectArea("ZZD")
          DbGoTop()
       
Return

/*Static Function cPictMedi()
       Local cPict := ""
       xxx := "@!"
Return(cPict)*/

Static Function AltSeqTes(nOpcTrc)
       If nOpcTrc == '1'
       
       ElseIf nOpcTrc == '2'
          cSay1Ens     := Iif(oCBox2Ac:nAt == 2, 'Cliente:', Iif(oCBox2Ac:nAt == 3, 'Ger. Prod.:', 'Usuário:') )
          oGet1Ens:cF3 := Iif(oCBox2Ac:nAt == 2, 'CLI'     , Iif(oCBox2Ac:nAt == 3, 'XXXQIY', 'XXXQIY') )
          oCBox2Ac:lReadOnly := .t.
          oSay1Ens:lVisible  := .t.
          oSay2Ens:lVisible  := .t.
          oGet1Ens:lVisible  := .t.
          oGet2Ens:lVisible  := .t.
          oMGet1En:lVisible  := .t.
       Endif
Return

Static Function fMonHisDese()
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       Local nOpcO        := 0
       Private cGet1Obs   := TransForm(Alltrim(M->ZM_CODIGO), Iif(nRadMen == 2 .or. nRadMen == 3, "999999", "@R XX 99.99.999-99"))+' / '+M->ZM_REVISAO
       Private cGet2Obs   := M->ZM_DESCRIC
       Private cMGet1Ob
       Private cMGet2Ob
       Private cSay1Obs   := Space(1)
       Private cSay2Obs   := Space(1)

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oFont2Con", "oDlg2Con", "oSay1Obs", "oSay2Obs", "oSay3Obs", "oGet1Obs", "oGet2Obs", "oGet3Obs", "oMGet1Ob")
       SetPrvt("oBtn1Obs")

       DbSelectArea("SZT")
       DbSetOrder(2)
       DbSeek(xFilial("SZT")+M->ZM_ID+'SI'+'HD', .T.)
       If Found()
          cMGet2Ob := SZT->ZT_LOG
       Else
          cMGet2Ob := ''
       Endif
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oFont2Con  := TFont():New( "MS Sans Serif",0,-19,,.F.,0,,400,.F.,.F.,,,,,, )
       oDlg2Con   := MSDialog():New( 295,414,610,0990,"Histórico de Desenvolvimento",,,.F.,,,,,,.T.,,,.T. )
       oSay1Obs   := TSay():New( 005,004,{||"Produto:"},oDlg2Con,,oFont2Con,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,012)
       oGet1Obs   := TGet():New( 004,040,{|u| If(PCount()>0,cGet1Obs:=u,cGet1Obs)},oDlg2Con,110,014,'',,CLR_BLACK,CLR_WHITE,oFont2Con,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGet1Obs",,)
       oGet2Obs   := TGet():New( 024,040,{|u| If(PCount()>0,cGet2Obs:=u,cGet2Obs)},oDlg2Con,248,014,'',,CLR_BLACK,CLR_WHITE,oFont2Con,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGet2Obs",,)
       oMGet1Ob   := TMultiGet():New( 044,004,{|u| If(PCount()>0,cMGet1Ob:=u,cMGet1Ob)},oDlg2Con,284,048,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
       oMGet2Ob   := TMultiGet():New( 096,004,{|u| If(PCount()>0,cMGet2Ob:=u,cMGet2Ob)},oDlg2Con,284,040,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.T.,,,.F.,,  )
       oBtn2Obs   := TButton():New( 140,244, "Sair"    , oDlg2Con, { || nOpcO := 0, oDlg2Con:End() }, 037,012,,,,.T.,,"",,,,.F. )
       oBtn1Obs   := TButton():New( 140,200, "Confirma", oDlg2Con, { || nOpcO := 1, oDlg2Con:End() }, 037,012,,,,.T.,,"",,,,.F. )
       oDlg2Con:Activate(,,,.T.)
       If nOpcO == 1 //Gravar Informação.
          If !Empty(cMGet1Ob)
             cObsMsg := Alltrim(cUserName)+" ("+dToc(dDataBase)+" "+Time()+"):"+Chr(13)+chr(10)
             cObsMsg += Upper(cMGet1Ob)+Chr(13)+chr(10)+Chr(13)+chr(10)
             cObsMsg += cMGet2Ob
             DbSelectArea("SZT")
             DbSetOrder(2)
             DbSeek(xFilial("SZT")+M->ZM_ID+'SI'+'HD', .T.)
             If Found()
                DbSelectArea("SZT")
                RecLock("SZT", .f.)
                   SZT->ZT_LOG     := cObsMsg
                MsUnLock()
             Else
                DbSelectArea("SZT")
                RecLock("SZT", .t.)
                   SZT->ZT_FILIAL  := xFilial("SZT")
                   SZT->ZT_ID      := M->ZM_ID
                   SZT->ZT_PROCESS := "SI"
                   SZT->ZT_STATUS  := "HD"
                   SZT->ZT_LOG     := cObsMsg
                   SZT->ZT_USUARIO := cUserName
                   SZT->ZT_DATAGER := dDataBase
                   SZT->ZT_HORAGER := Time()
                   SZT->ZT_SEQ     := '901'
                MsUnLock()
             Endif
          Endif
       Endif
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
  ±±ºPrograma  ³ PCPX01_7 ºAutor  ³ Luís Gustavo       º Data ³  10/03/04   º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºDesc.     ³ Mostra legenda do status dos registros.                    º±±
  ±±º          ³                                                            º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºUso       ³ BRASILUX                                                   º±±
  ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function PCPA04_L()
     BrwLegenda(OemToAnsi("Legenda"), "Status", { {"DISABLE"    , "Analise Química"   } ,;
                                                  {"BR_AMARELO" , "Analise PCP"       } ,;
                                                  {"BR_AZUL"    , "Analise Diretoria" } ,;
                                                  {"ENABLE"     , "Aprovado"          } ,;
                                                  {"BR_PRETO"   , "Rejeitado"         } ,;
                                                  {"BR_LARANJA" , "Obsoleta"          } ,;
                                                  {"BR_CINZA"   , "Retorno Status"    } ,;
                                                  {"BR_BRANCO"  , "Previsão estourada"} })
Return(.T.)
/**************************************************************************************************************************************************/

User Function SI215Ens()
     Local nOrdQAA   := QAA->(IndexOrd())
     Local cApelid   := TRIM(UPPER(cUserName))
     Local cCod      := Space(10)

     DbSelectArea("QAA")
     DbSetOrder(6)
     If DbSeek(cApelid)
        cCod := QAA->QAA_MAT
        cFil := QAA->QAA_FILIAL
     EndIf
     DbSetOrder(nOrdQAA)
Return({cCod, cFil})

User Function SI_NUSR(cCodFI, cCodDe, lGatilho,cTipo)
     Local aArea := GetArea()
     Local cNome     := ""

     DbSelectArea("QAA")
     lGatilho := If(lGatilho == NIL, .T., lGatilho)

     If Type("INCLUI") == "U"
        Private Inclui := .F.
     Endif
     If Empty(cCodDe) .and. cTipo == "C"
        DbSetOrder(6)
        If QAA->(DbSeek(TRIM(UPPER(cUsername))))
           cCodDe := QAA->QAA_MAT
        EndIf
     EndIf
     lGatilho := If(lGatilho == NIL, .T.                      , lGatilho)
     cTipo    := If(cTipo    == NIL, "N"                      , cTipo)
     cNome    := If(cTipo    == "N", Space(Len(QAA->QAA_NOME)), Space(Len(QAA->QAA_APELID)))

     If !Inclui .or. lGatilho   // Se Inic. Padrao ou gatilho
        DbSetOrder(1)
        If !Empty(cCodDe)
           If dbSeek(cCodFI + cCodDe)
              If cTipo == "N"
                 cNome := PadR(QAA->QAA_NOME,40)
              Else
                 cNome := QAA->QAA_APELID
              EndIf
           EndIf
        EndIf
     EndIf

     RestArea(aArea)

     If cTipo == "C"
        Return(cCodDe)
     EndIf
Return(cNome)

User Function SI215P()
     Local cPict     := ''
     Local cCampo    := "ZZD_MEDNUM"
     Local nDec      := 0
     Local nRecSx3   := 0
     Local nTam      := 0
     Local nPosNom   := aScan(aHoBrw1Ate, { |x| Trim(x[2]) == "ZZD_NOMINA" } )
     Local nPosCar   := aScan(aHoBrw1Ate, { |x| Trim(x[2]) == "ZZD_CARTA" } )
     
     If oBrw1Ate:aCols[oBrw1Ate:nAt][nPosCar] $ 'TXT'
        cPict := "@!"
     Else
        nDec := QA_NumDec(oBrw1Ate:aCols[oBrw1Ate:nAt][nPosNom])
        nRecSx3 := SX3->(Recno())
        nTam := TamSx3(cCampo)[1]       // A picture tera' o tamanho def. p/ o campo no SX3
        SX3->(dbGoTo(nRecSx3))

        If oBrw1Ate:aCols[oBrw1Ate:nAt][nPosCar] <> "P  " .And. oBrw1Ate:aCols[oBrw1Ate:nAt][nPosCar] <> "TMP"
           If At('i', oBrw1Ate:aCols[oBrw1Ate:nAt][nPosNom]) == 0
              cPict := QA_PICT(cCampo, oBrw1Ate:aCols[oBrw1Ate:nAt][nPosNom]) // Campo,Valor Referencia: Nominal
           Else
              cPict := "%C"
           EndIf
        ElseIf oBrw1Ate:aCols[oBrw1Ate:nAt][nPosCar] == "P  "
               // Monta a picture def. no aheader                
               cPict := aHoBrw1Ate[nColPos][3]
        ElseIf oBrw1Ate:aCols[oBrw1Ate:nAt][nPosCar] == "TMP"
               cPict := "@R 999:99"
        EndIf
     Endif
Return(cPict)

User Function SI215COMED()
     Local nPosCar   := aScan(aHoBrw1Ate, { |x| Trim(x[2]) == "ZZD_CARTA" } )
     Local nPosLiI   := aScan(aHoBrw1Ate, { |x| Trim(x[2]) == "ZZD_LIE" } )
     //Local nPosNom   := aScan(aHoBrw1Ate, { |x| Trim(x[2]) == "ZZD_NOMINA" } )
     Local nPosLiS   := aScan(aHoBrw1Ate, { |x| Trim(x[2]) == "ZZD_LIS" } )
     //Local nPosMed   := aScan(aHoBrw1Ate, { |x| Trim(x[2]) == "ZZD_MEDNUM" } )
     Local nPosMeM   := aScan(aHoBrw1Ate, { |x| Trim(x[2]) == "ZZD_MINMAX" } )
     Local nPosRes   := aScan(aHoBrw1Ate, { |x| Trim(x[2]) == "ZZD_RESULT" } )
     Local lRet      := .f.

     If oBrw1Ate:aCols[oBrw1Ate:nAt][nPosCar] $ 'TXT'
        lRet := .t.
     Else
        nLimInf := Val( StrTran( oBrw1Ate:aCols[oBrw1Ate:nAt][nPosLiI], ",", "." ) )
        nValMed := Val( StrTran( &__ReadVar                           , ",", "." ) )
        nLimSup := Val( StrTran( oBrw1Ate:aCols[oBrw1Ate:nAt][nPosLiS], ",", "." ) )
        If oBrw1Ate:aCols[oBrw1Ate:nAt][nPosMeM] $ '1' // Controla Minimo e Maximo
           If nValMed >= nLimInf .and. nValMed <= nLimSup
              oBrw1Ate:aCols[oBrw1Ate:nAt][nPosRes] := "A"
           Else
              oBrw1Ate:aCols[oBrw1Ate:nAt][nPosRes] := "R"
           Endif
        ElseIf oBrw1Ate:aCols[oBrw1Ate:nAt][nPosCar] $ '2' // Controla Minimo
               If nValMed >= nLimInf
                  oBrw1Ate:aCols[oBrw1Ate:nAt][nPosRes] := "A"
               Else
                  oBrw1Ate:aCols[oBrw1Ate:nAt][nPosRes] := "R"
               Endif
        ElseIf oBrw1Ate:aCols[oBrw1Ate:nAt][nPosCar] $ '3' // Controla Maximo
               If nValMed <= nLimInf
                  oBrw1Ate:aCols[oBrw1Ate:nAt][nPosRes] := "A"
               Else
                  oBrw1Ate:aCols[oBrw1Ate:nAt][nPosRes] := "R"
               Endif
        Endif
        lRet := .t.
     Endif
Return(lRet)

Static Function fValAceiteAt()
       lRet := .t.
       If cGet1Ens =''
          If !Empty(aResultX[1][4])
             If MsgYesNo("Atenção, o Aceite já foi dado! Estornar o aceite?")
                nCBox2Ac := 1
                oCBox2Ac:lReadOnly := .f.
                oSay1Ens:lVisible  := .f.
                cGet1Ens := space(10)
                oGet1Ens:lVisible  := .f.
                cGet2Ens := space(40)
                oGet2Ens:lVisible  := .f.
                oSay2Ens:lVisible  := .f.
                cMGet1En := ""
                oMGet1En:lVisible  := .f.
                oMGet1En:lReadOnly := .f.
                oCBox2Ac:Refresh()
                oSay1Ens:Refresh()
                oGet1Ens:Refresh()
                oGet2Ens:Refresh()
                oSay2Ens:Refresh()
                aAdd(aResultX, {0, Ctod("  /  /  "), '', '', ''})
             Else
                cGet1Ens := aResultX[1][4]
                oGet1Ens:SetFocus()
                oGet1Ens:Refresh()
             Endif
          Endif
       Endif
Return(lRet)

User Function PCPA04_9()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cMGet1Pr  
     Private cSay1Pre   := Space(1)
     Private cSay2Pre   := Space(1)
     Private dGet1Pre   := CtoD(" ")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1Re", "oDlg1Pre", "oSay1Pre", "oSay2Pre", "oGet1Pre", "oMGet1Pr", "oBtn1Pre", "oBtn2Pre")

     If !u_fVerAcsUsr(cRotUsu, 2)
        MsgStop("Usuário sem acesso a essa opção.", "Atenção")
        Return
     Endif
     If !SZM->ZM_STATUS $ 'EE.PP'
        MsgStop("O status dessa fórmula não permite a reprogramação da mesma.")
        Return
     Else
        If !Alltrim(Upper(cUserName)) $ Alltrim(Upper(SZM->ZM_RESPONS)) .AND. !Empty(SZM->ZM_RESPONS)
           MsgStop("Usuário não é o responsável por essa fórmula.")
           Return
        Endif
     Endif

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1Re   := TFont():New( "MS Sans Serif",0,-19,,.F.,0,,400,.F.,.F.,,,,,, )
     oDlg1Pre   := MSDialog():New( 091,232,257,771,"Reprograma Previsão",,,.F.,,,,,,.T.,,,.T. )
     oSay1Pre   := TSay():New( 004,004,{||"Nova Data:"},oDlg1Pre,,oFont1Re,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,012)
     oSay2Pre   := TSay():New( 024,004,{||"Motivo:"},oDlg1Pre,,oFont1Re,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,012)
     oGet1Pre   := TGet():New( 003,056,{|u| If(PCount()>0,dGet1Pre:=u,dGet1Pre)},oDlg1Pre,052,014,'',,CLR_BLACK,CLR_WHITE,oFont1Re,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dGet1Pre",,)
     oMGet1Pr   := TMultiGet():New( 024,056,{|u| If(PCount()>0,cMGet1Pr:=u,cMGet1Pr)},oDlg1Pre,204,048,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
     oBtn1Pre   := TButton():New( 004, 176, "Confirma", oDlg1Pre, { || fTrocPre()     }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn2Pre   := TButton():New( 004, 224, "Sair"    , oDlg1Pre, { || oDlg1Pre:End() }, 037, 012, , , , .T., , "", , , , .F. )

     oDlg1Pre:Activate(,,,.T.)

Return

Static Function fTrocPre()
       If Empty(dGet1Pre)
          MsgStop("Atenção a data da nova previsão deve ser informada.")
          Return
       Endif
       If SZM->ZM_DTPREVI >= dGet1Pre
          MsgStop("Atenção a data da nova previsão não pode ser menor ou igual a previsão anterior.")
          Return
       Endif
       If Empty(cMGet1Pr)
          MsgStop("Atenção o motivo da re-programação da previsão deve ser informado.")
       Endif
       //Gravar a reprogramação
       RecLock("SZM", .f.)
          SZM->ZM_DTPREVI := dGet1Pre
       MsUnLock()
       //Gravar o motivo da reprogramação
       cObsMsg := Alltrim(cUserName)+" ("+dToc(dDataBase)+" "+Time()+"):"+Chr(13)+chr(10)
       cObsMsg += Upper(cMGet1Pr)+Chr(13)+chr(10)+Chr(13)+chr(10)
       DbSelectArea("SZT")
       DbSetOrder(2)
       DbSeek(xFilial("SZT")+SZM->ZM_ID+'SI'+'DT', .T.)
       If Found()
          RecLock("SZT", .t.)
             SZT->ZT_FILIAL  := xFilial("SZT")
             SZT->ZT_ID      := SZM->ZM_ID
             SZT->ZT_PROCESS := "SI"
             SZT->ZT_STATUS  := "DT"
             SZT->ZT_LOG     := cObsMsg
             SZT->ZT_USUARIO := cUserName
             SZT->ZT_DATAGER := dDataBase
             SZT->ZT_HORAGER := Time()
             SZT->ZT_SEQ     := '800'
       Else
          cObsMsg += Upper(Alltrim(SZT->ZT_LOG))+Chr(13)+chr(10)+Chr(13)+chr(10)
          RecLock("SZT", .f.)
             SZT->ZT_LOG     := cObsMsg
       Endif
       MsUnLock()
       oDlg1Pre:End()
Return
