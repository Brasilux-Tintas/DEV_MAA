#Include "Totvs.ch"
#Include "RWMAKE.ch"

/*/{Protheus.doc} BRINVERT
Rotina que permite a alteracao de carteira (D/C) dos registros do extrato bancario
@type function Processamento
@version 1.00
@author marioantonaccio
@since 01/04/2026
@return character, sem retorno
/*/
User Function BRINVERT()

    Local aArea    := FWGetArea() as array
    Local aButtons := {}          as array
    Local aPerg    := {}          as array
    Local aSays    := {}          as array
    Local cPerg    := "BRINVEXTR" as character
    Local lOk      := .F.         as logical
    Private  oListBox1 as object

    If .NOT. SuperGetMV("BR_INVERT",.F.,.T.)
        Return(NIL)
    End

    If .NOT. FWSX1Util():ExistPergunte(cPerg)
        aadd(aPerg, {cPerg, "01", "Data Incial do Extrato?", "MV_PAR01", "MV_CH0", "D", TamSX3( 'E1_EMISSAO' )[01], 0, 0, "G", "", ""   , "", "", "", "", "", ""})
        aadd(aPerg, {cPerg, "02", "Data Final do Extrato?" , "MV_PAR02", "MV_CH1", "D", TamSX3( 'E1_EMISSAO' )[01], 0, 0, "G", "", ""   , "", "", "", "", "", ""})
        aadd(aPerg, {cPerg, "03", "Banco?"                 , "MV_PAR03", "MV_CH2", "C", TamSX3( 'A6_COD' )[01]    , 0, 0, "G", "", "SA6", "", "", "", "", "", ""})
        U_XCRIASX1(aPerg)
    End

    //Popula as linhas que serao mostradas na tela
    aAdd(aSays, "Este programa efetua a troca da carteira dos registros selecionados")
    aAdd(aSays, "invertendo de Debito para Credito e Vice-Versa.")

    //Botoes da tela, cada botao tem um Bloco de Codigo
    aAdd(aButtons, { 5, .T., {|| Pergunte(cPerg, .T. ) } } )
    aAdd(aButtons, { 1, .T., {|| lOk := .T., FechaBatch() }} )
    aAdd(aButtons, { 2, .T., {|| lOk := .F., FechaBatch() }} )

    //Chama a tela principal
    FormBatch("Inversao Debito/Credito Extrato", aSays, aButtons)

    //Se foi confirmado a tela
    If lOk
        BREXTR01()
    EndIf

    FWRestArea(aArea)

Return (NIL)

/*/{Protheus.doc} BREXTR01
Montagem da tela de exibicao dos registros do intervalo que possam sofrer alteracao de carteira
@type function Tela
@version 1.00
@author marioantonaccio
@since 01/04/2026
@return character, sem retorno
/*/
Static Function BREXTR01()

    Local bConfirm          as codeblock
    Local bDMarcar          as codeblock
    Local bInvert           as codeblock
    Local bMarcar           as codeblock
    Local bSair             as codeblock
    Local oBtnObj0          as object
    Local oBtnObj1          as object
    Local oBtnObj2          as object
    Local oBtnObj3          as object
    Local oBtnObj4          as object
//    Local oSay01            as object
    Private aListBox1 := {} as array
    Private cFontNome       as character
    Private oDlg            as object
    Private oFontPadrao     as character

    oFontPadrao := TFont():New(cFontNome, , -12)
    cFontNome   := 'Tahoma'

    bSair    :={|| Iif(FWAlertYesNo( 'Tem certeza que deseja sair da rotina? ' , 'Sair da rotina' ),oDlg:End(),.T.)}
    bConfirm :={|| oDlg:End(),   Processa( { || BREXTR05(aListBox1)}, "Processando Alteração Registros.....")}
    bMarcar  :={|| BREXTR04("M", aListBox1)}
    bDMarcar :={|| BREXTR04("D", aListBox1)}
    bInvert  :={|| BREXTR04("I", aListBox1)}

    Processa({|| BREXTR02()}, "Processando...")

    IF Len(aListBox1) > 0
 
       // DEFINE MSDIALOG oDlg TITLE "Selecao de Registros Extrato" STYLE DS_MODALFRAME FROM  C(178),C(181) TO C(548),C(967) PIXEL
        DEFINE MSDIALOG oDlg TITLE "Selecao de Registros Extrato" FROM  C(178),C(181) TO C(548),C(967) PIXEL

        // Cria Componentes Padroes do Sistema
        oBtnObj0 := TButton():New(C(155), C(283), "Sair"            , oDlg, bSair   , 040, 010, , , , .T., , "", , , , .F.)
        oBtnObj1 := TButton():New(C(155), C(337), "Confirma"        , oDlg, bConfirm, 040, 010, , , , .T., , "", , , , .F.)
        oBtnObj2 := TButton():New(C(155), C(015), "Marca Tudo"      , oDlg, bMarcar , 040, 010, , , , .T., , "", , , , .F.)
        oBtnObj3 := TButton():New(C(155), C(063), "Desmarca Tudo"   , oDlg, bDMarcar, 040, 010, , , , .T., , "", , , , .F.)
        oBtnObj4 := TButton():New(C(155), C(110), "Inverter Selecao", oDlg, bInvert , 040, 010, , , , .T., , "", , , , .F.)
      //  oSay01:=TSay():New( 155,155, {||"Total de Registros: " + AllTrim(cValToChar((Len(aListBox1))))},oDlg, ,, , , ,.T., , , 22, 12)

        BREXTR03(oDlg, aListBox1)

        ACTIVATE MSDIALOG oDlg CENTERED

    ELSE
        FWAlertInfo("Nenhum registro encontrado para os parametros informados.", "Sem Registros")
    ENDIF

Return(.T.)

/*/{Protheus.doc} BREXTR02
Consulta SQL e popula o array aListBox1 com os registros do extrato
@type function Dados
@version 1.00
@author marioantonaccio
@since 01/04/2026
@return character, sem retorno
/*/
Static Function BREXTR02()

    Local cAlias     as character
    Local nCont := 0 as numeric

    cAlias := GetNextAlias()

    BEGINSQL ALIAS cAlias
        SELECT
            SIG.R_E_C_N_O_ AS IG_RECSIG,
            SIG.IG_FILIAL,
            SIG.IG_DTEXTR,
            SIF.IF_BANCO,
            SIG.IG_AGEEXT,
            SIG.IG_CONEXT,
            SIG.IG_DOCEXT,
            SIG.IG_VLREXT,
            SIG.IG_HISTEXT,
            SIG.IG_CARTER,
            SIG.IG_TIPEXT
        FROM
            %TABLE:SIG% SIG
        INNER JOIN %TABLE:SIF% SIF
        ON SIF.IF_FILIAL = SIG.IG_FILIAL
            AND SIF.IF_IDPROC = SIG.IG_IDPROC
            AND SIF.%NOTDEL%
        WHERE
            SIG.%NotDel%
            AND SIG.IG_FILIAL = %XFILIAL:SIG%
            AND SIG.IG_DTEXTR >= %EXP:DTOS(mv_par01)%
            AND SIG.IG_DTEXTR <= %EXP:DTOS(mv_par02)%
            AND SIF.IF_BANCO = %EXP:mv_par03%
    ENDSQL

    nCont := CONTAR((cAlias), ".NOT. EOF()")
    (cAlias)->(DbGoTop())

    Procregua(nCont)
    While .NOT. (cAlias)->(EOF())

        IncProc()

        aadd(aListBox1, { .F.,              ;
            (cAlias)->IG_FILIAL,             ;
            STOD((cAlias)->IG_DTEXTR),       ;
            (cAlias)->IG_DOCEXT,             ;
            (cAlias)->IG_HISTEXT,            ;
            Transform((cAlias)->IG_VLREXT,"@ER 999,999,999.99"),             ;
            If((cAlias)->IG_CARTER=="2","Pagar","Receber"), ;
            (cAlias)->IF_BANCO,              ;
            (cAlias)->IG_AGEEXT,             ;
            (cAlias)->IG_CONEXT,             ;
            (cAlias)->IG_TIPEXT,             ;
            (cAlias)->IG_RECSIG })

        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())

Return (NIL)

/*/{Protheus.doc} BREXTR03
Cria e configura a ListBox dentro do dialogo informado
@type function Tela
@version 1.00
@author marioantonaccio
@since 01/04/2026
@return character, sem retorno
/*/
Static Function BREXTR03(oDlg, aListBox1)

    Local oNo       as object
    Local oOk       as object

    oNo := LoadBitmap(GetResources(), "LBNO")
    oOk := LoadBitmap(GetResources(), "LBOK")

    @ C(006), C(005) ListBox oListBox1 ;
        Fields ;
        HEADER ;
        " ",     ;
        "Filial",    ;
        "Data",      ;
        "Documento", ;
        "Historico", ;
        "Valor",     ;
        "Carteira",  ;
        "Banco",     ;
        "Agencia",   ;
        "Conta",     ;
        "Tipo",      ;
        "Recno"      ;
        Size C(374), C(140) ;
        Of oDlg Pixel ;
        ColSizes 40, 45, 60, 45, 120, 70, 40,55, 60, 65,45, 50 ;
        ON DBLCLICK ( ;
        aListBox1[oListBox1:nAt, 1] := .NOT. aListBox1[oListBox1:nAt, 1], ;
        oListBox1:Refresh() ;
        )

    oListBox1:SetArray(aListBox1)

    oListBox1:bLine := {|| { ;
        IIf(aListBox1[oListBox1:nAt, 01], oOk, oNo), ;
        aListBox1[oListBox1:nAt, 02], ;
        aListBox1[oListBox1:nAt, 03], ;
        aListBox1[oListBox1:nAt, 04], ;
        aListBox1[oListBox1:nAt, 05], ;
        aListBox1[oListBox1:nAt, 06], ;
        aListBox1[oListBox1:nAt, 07], ;
        aListBox1[oListBox1:nAt, 08], ;
        aListBox1[oListBox1:nAt, 09], ;
        aListBox1[oListBox1:nAt, 10], ;
        aListBox1[oListBox1:nAt, 11], ;
        aListBox1[oListBox1:nAt, 12]  ;
        }}

    oListBox1:Refresh()

Return (Nil)

/*/{Protheus.doc} BREXTR04
Funcao para marcar/desmarcar todos os itens
@type function Processamento
@version  1.00
@author marioantonaccio
@since 01/04/2026
@param cTipo, character, Qual tipo de processamento M=Marcar todos, D=Desmarcar todos, I=Inverter selecao
@param aListBox1, array, Array dos itens da ListBox
@return character, sem retorno
/*/
Static Function BREXTR04(cTipo,aListBox1)

    Local nI as numeric

    For nI := 1 To Len(aListBox1)
        If cTipo == "M" // Marcar todos
            aListBox1[nI][1] := .T.
        ElseIf cTipo == "D" // Desmarcar todos
            aListBox1[nI][1] := .F.
        ElseIf cTipo == "I" // Inverter selecao
            aListBox1[nI][1] := .NOT. aListBox1[nI][1]
        End
    Next
    oListBox1:Refresh()
Return (NIL)

/*/{Protheus.doc} BREXTR05
Funcao de atualizacao dos registros
@type function Processamento
@version  1.00
@author marioantonaccio
@since 01/04/2026
@param aListBox1, array, array dos itens da ListBox
@return character, sem retorno
/*/
Static Function BREXTR05(aListBox1)

    Local nAtual := 0 as numeric
    Local nI          as numeric
    Local nOk    := 0 as numeric

    For nI:=1 To Len(aListBox1)
        If aListBox1[nI, 1] // Verifica se item marcado
            nOk++
            Exit
        EndIf
    Next
    If nOk == 0
        FWAlertError("Nao foram selecionados registros","Sem registros")
        Return(NIL)
    End
    ProcRegua(Len(aListBox1))
    For nI:=1 To Len(aListBox1)
        IncProc()
        If aListBox1[nI, 1] // Verifica se o item esta marcado
            nAtual++
            SIG->(dbGoTo(aListBox1[nI, 12])) // Posiciona no registro do extrato
            RecLock("SIG",.F.) // Bloqueia o registro
            SIG->IG_CARTER := IIf((SIG->IG_CARTER) == "1", "2", "1") // Inverte a carteira
            MsUnlock()
        EndIf
    Next

    FWAlertSuccess("Foi(ram) alterado(s) "+cValTochar(nAtual)+" registro(s)", "Rotina Finalizada")

Return (NIL)

/*/{Protheus.doc} C
Calculo de posicao
@type function Tela
@version  1.00
@author marioantonaccio
@since 01/04/2026
@param nTam, numeric,posicao do componente na tela
@return numeric, retorno com a nova coordenada
/*/
Static Function C(nTam)
    Local nHRes as numeric

    nHRes := oMainWnd:nClientWidth  // Resolucao horizontal do monitor

    If nHRes == 640                        // Resolucao 640x480
        nTam *= 0.8
    ElseIf (nHRes == 798) .Or. (nHRes == 800)  // Resolucao 800x600
        nTam *= 1
    Else                                   // Resolucao 1024x768 e acima
        nTam *= 1.28
    EndIf

    // Tratamento para tema "Flat"
    If "MP8" $ oApp:cVersion
        If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
            nTam *= 0.90
        EndIf
    EndIf
Return Int(nTam)
