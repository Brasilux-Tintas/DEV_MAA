#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*/{Protheus.doc} BRALTPRD
Permite a alteração de Vendedores cadastrados nos clientes em massa
@type function Processamento
@version  1.0
@author marioantonaccio
@since 10/03/2026
@return character, sem retorno
/*/
User Function BRALTPRD()
    Local aSays        := {}
    Local aButtons     := {}
    Local lOk          := .F.
    Local cPerg        := "BRALTPRD"
    Local aPerg:={}

    //Identifica se a rotina esta em uso
    If .NOT. SuperGetMV("BR_ALTPRD",.F.,.F.)  
        Return(NIL)
    End    

    If .NOT. FWSX1Util():ExistPergunte(cPerg)

        AADD(aPerg,{cPerg, "01", "Produto  DE?","MV_PAR01"          , "MV_CH0", "C", TamSX3('B1_COD')[01], 0, 0 ,"G", "","SB1", "","","","","",""})
        AADD(aPerg,{cPerg, "02", "Produto Ate?","MV_PAR02"          , "MV_CH1", "C", TamSX3('B1_COD')[01], 0, 0 ,"G", "","SB1", "","","","","",""})
        AADD(aPerg,{cPerg, "03", "Campo a Alterar?","MV_PAR03"      , "MV_CH3", "C", 10, 0, 0                   ,"G", "","", "","","","","",""})
        AADD(aPerg,{cPerg, "04", "Conteudo de?","MV_PAR04"          , "MV_CH4", "C", 30, 0, 0                   ,"G", "","", "","","","","",""})
        AADD(aPerg,{cPerg, "05", "Mudar Conteudo para?","MV_PAR05"  , "MV_CH5", "C", 30, 0, 0                   ,"G", "","", "","","","","",""})
        U_XCRIASX1(aPerg)
    End

    //Popula as linhas que serão mostradas na tela
    aAdd(aSays, "Esse programa tem como objetivo efetuar a Atualização de campos")
    aAdd(aSays, "no cadastro de Produtos (SB1).")
    aAdd(aSays, "Nao deve ser usado para trocar campos chaves (Codigo,descricao)")
    aAdd(aSays, "Somente um VALOR que sera repetido para todos os produtos Uma UNICA VEZ")
    aAdd(aSays, "Serao considerados produtos tipo PA,PI,MP,EM,OI")
    aAdd(aSays, "Serao descconsiderados produtos bloqueados")

    //Botões da tela, cada botão tem um Bloco de Código
    aAdd(aButtons, { 5, .T., {|| Pergunte(cPerg, .T. ) } } )
    aAdd(aButtons, { 1, .T., {|| lOk := .T., FechaBatch() }} )
    aAdd(aButtons, { 2, .T., {|| lOk := .F., FechaBatch() }} )

    //Chama a tela principal
    FormBatch("Atualizacao de campos de Produtos", aSays, aButtons)

    //Se foi confirmado a tela
    If lOk
        Processa( { |lEnd|  BRALTP01()}, "Processando Alteração Produto.....")
    EndIf

Return (NIL)

/*/{Protheus.doc} BRALTP01
Processo de alteração de campos de produtos e gravação de logs
@type function Processamento
@version  1.00
@author marioantonaccio
@since 10/03/2026
@return character, sem retorno
/*/
Static Function BRALTP01()

    Local aCampos  := {} as array
    Local aConteud := {} as array
    Local cCampo         as character
    Local cMsg           as character
    Local nI             as numeric
    Local nReg     := 0  as Numeric
    Local nRegOk   := 0  as Numeric

    cCampo:=AllTrim(mv_par03)

    //Valida se é campo chave
    lErro:=.F.
    SIX->(dbSetOrder(1))
    If SIX->(dbSeek("SB1"))
        While SIX->(.NOT. EOF()) .and. SIX->INDICE == "SB1"
            If cCampo $ AllTrim(SIX->CHAVE)
                lErro:=.T.
                Exit
            End
            SIX->(dbSkip())
        End
    End
    If lErro
        FWAlertError("O campo utilizado é campo chave...Não sera possivel utiliza-lo!!","Campo Chave")
        Return (NIL)
    End

    //Verifica se Esta em Uso/Reservado/Obrigatorio
    lErro:=.F.
    SX3->(dbSetOrder(1))
    If SX3->(dbSeek(cCampo))
        If .NOT. X3USO()
            lErro:=.T.
        End
        If  XReserv()
            lErro:=.T.
        End
    End
    If  X3OBRIGAT(cCampo)
        lErro:=.T.
    End
    If lErro
        FWAlertError("O campo utilizado é:"+CRLF+"Obrigatorio, Reservado ou nao esta em uso..."+CRLF+"Não sera possivel utiliza-lo!!","Campo Obrigatorio/Reservado/Nao em uso")
        Return (NIL)
    End

    cExp:="%"
    If TamSX3(cCampo)[03] $ "C/D"
        cExp+=cCampo +"='"+If(Empty(mv_par04),Space(TamSX3(cCampo)[01]),AllTrim(mv_par04))+"'"
        mv_par04:=If(Empty(mv_par04),Space(TamSX3(cCampo)[01]),AllTrim(mv_par04))
    ElseIf TamSX3(cCampo)[03] == "N"
        cExp+=cCampo +"= "+If(Empty(mv_par04),"0",AllTrim(mv_par04))
        mv_par04:=If(Empty(mv_par04),0,Val(mv_par04))
    End
    cExp+="%"

    If Empty(mv_par05)
        If TamSX3(cCampo)[03]  $  "C/D"
            mv_par05:=Space(TamSX3(mv_par03)[01])
        ElseIf TamSX3(cCampo)[03] == "N"
            mv_par05:=0
        End
    End

    //Seleciona os Registros
    BeginSql AlIAS "XSB1"
        SELECT
            R_E_C_N_O_ AS REGSB1
        FROM
            %TABLE:SB1%
        WHERE
            %EXP:cExp%
            AND B1_TIPO IN ('PA', 'PI', 'MP', 'EM', 'OI')
            AND B1_COD >= %exp:MV_PAR01%
            AND B1_COD <= %exp:MV_PAR02%
            AND D_E_L_E_T_ = ' '
            AND B1_MSBLQL <> '1'
    EndSQL

    //Contaem de registros conforme parametro
    nReg:=CONTAR("XSB1",".NOT. EOF()")

    // Se nao existir registros retorna
    If nReg == 0
        XSB1->(dbCloseArea())
        FWAlertError("Nao existem Produtos para alteração", "Sem Produtos")
        Return(NIL)
    End

    cMsg:="Existem "+cValToChar(nReg)+ " Registros"+CRLF
    cMsg+="que atendam as condicoes para alteração"+CRLF+CRLF
    cMsg+="Deseja efetuar a Alteração no Campo:"+CRLF+CRLF
    cMsg+=MV_PAR03+CRLF+CRLF
    cMsg+="DE: " +mv_par04+CRLF+CRLF
    cMsg+="PARA: " +mv_par05+" ?"

    //Confirma execução rotina
    If FWAlertNoYes(cMsg, "Alteração de Produto")

        ProcRegua(nReg)

        SB1->(dbSetOrder(1))

        XSB1->(dbGoTop())

        While XSB1->(.NOT. EOF())

            IncProc()

            SB1->(dbGoTo(XSB1->REGSB1))
            cCampo:="SB1->"+Alltrim(mv_par03)

            If &cCampo == mv_par04

                // Atualiza Campos
                RecLock("SB1",.F.)
                &cCampo:=AllTrim(mv_par05)
                MSUnLock()

                //Grava Log
                ZAJ->(dbSetOrder(1))
                RecLock("ZAJ",.T.)
                ZAJ->ZAJ_FILIAL := SB1->B1_FILIAL
                ZAJ->ZAJ_NUMERO := "ALTPRD "
                ZAJ->ZAJ_FORNEC := " "
                ZAJ->ZAJ_LOJA   := " "
                ZAJ->ZAJ_PROD   := SB1->B1_COD
                ZAJ->ZAJ_CAMPO  := AllTrim(mv_par03)
                ZAJ->ZAJ_DE     := cValToChar(mv_par04)
                ZAJ->ZAJ_PARA   := cValToChar(mv_par05)
                ZAJ->ZAJ_SEQ    := "01"
                ZAJ->ZAJ_DTALT  := dDataBase
                ZAJ->ZAJ_HORA   := Time()
                ZAJ->ZAJ_USRALT := cUserName
                ZAJ->ZAJ_TIPO   := "PR"
                MsUnLock()
                nRegOk++
            End
            XSB1->(dbSkip())
        End

        cMsg:="Rotina Finalizada Com SUCESSO!!!"+CRLF
        cMsg+="Registros Alterados: "+cValToChar(nRegOk)
        FWAlertSuccess(cMsg, "Rotina Finalizada")

        If FWAlertYesNo("Deseja ver o Log de Alteração?", "LOG de alterações")
            BRALTP02()
        End
    Else
        //Abortado rotina
        FWAlertError("Alteracao de produtos nao realizada!!", "Rotina nao executada")
    End

    XSB1->(dbCloseArea())

Return(Nil)

/*/{Protheus.doc} BRALTV02()
Geraçao e impressao de arquivo de LOG de Alterações
@type function Relatorio
@version  1.0
@author marioantonaccio
@since 11/03/2026
@return character, sem retorno
/*/
Static Function BRALTP02()

    Private oReport                  as Object
    Private oSecSC                   as Object

    //Cria as definições do relatório
    oReport := ReportDef()
    oReport:PrintDialog()

Return (NIL)

/*/{Protheus.doc} ReportDef
Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS  monta a janela com a regua de processamento.
@type function Processamento
@version  1.0
@author marioantonaccio
@since 30/01/2026
@return object, Objeto Report
/*/
Static Function ReportDef()

    Local cTitle  as Character
    Local oReport as Object

    cTitle := "Log de Alteração de Vendedor"
    //--------------------------------------------------------------------------
    //³Criacao do componente de impressao                                      ³
    //³                                                                        ³
    //³TReport():New                                                           ³
    //³ExpC1 : Nome do relatorio                                               ³
    //³ExpC2 : Titulo                                                          ³
    //³ExpC3 : Pergunte                                                        ³
    //³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
    //³ExpC5 : Descricao                                                       ³
    //³                                                                        ³
    //--------------------------------------------------------------------------
    oReport:=TReport():New("BRALTP02",cTitle,"", {|oReport| _FQuery(),RPrintCom(oReport)},;
        "Este programa emite o Relatorio de LOG de Alteracao de Produtos.")

    oReport:lParamPage:=.F.
    oReport:lTotalInLine:=.F.
    oReport:SetLandScape()
    oReport:nFontBody := 8
    oReport:nLineHeight := 30
    oReport:lDisableOrientation:=.F.
    oReport:nEnvironment:=2
    oReport:lEdit:=.F.
    oReport:SetLeftMargin(1)

    oSecSC:= TRSection():New(oReport,"Processo")
    oSecSC:SetHeaderPage()
    oSecSC:nLinesBefore := 0

Return(oReport)

/*/{Protheus.doc} RPrintCom
Processa as informacoes e imprime o relatorio
@type function Processamento
@version  1.0
@author marioantonaccio
@since 30/01/2026
@param oReport, object, Obejto do relatorio
@return character, sem retorno
@see
//oSection1:SetTotalInLine(.F.)
//DEFINE FUNCTION FROM oSection1:Cell('PAC_COMIS') FUNCTION SUM NO END SECTION PICTURE '@E@Z 999.99'
oSecSC:Cell("NQTD"):Hide()
/*/
Static Function RPrintCom(oReport)

    Local cTitulo       := oReport:Title()    as Object
    Local oSecSC        := oReport:Section(1) as Object
    Private lEndPage    := .F.                as Logical
    Private lEndRep     := .T.                as Logical
    Private lEndReport  := .T.                as Logical
    Private lEndSection := .T.                as Logical

    oSecSC := oReport:Section(1)

    TRCell():New(oSecSC,"ZAJ_FORNEC"	,"   ","Cliente"	    ," ",TamSX3('ZAJ_FORNEC')[01]   	,/*lPixel*/,{||XDEM->ZAJ_FORNEC},"LEFT")
    TRCell():New(oSecSC,"ZAJ_LOJA"	    ,"   ","Loja"	        ," ",TamSX3('ZAJ_LOJA')[01]		    ,/*lPixel*/,{||XDEM->ZAJ_LOJA},"LEFT")
    TRCell():New(oSecSC,"NOMECLI"		,"   ","Nome Cliente"	," ",20								,/*lPixel*/,{||Substr(AllTRim(Posicione("SA1",1,xFilial("SA1")+XDEM->ZAJ_FORNEC+XDEM->ZAJ_LOJA,"A1_NREDUZ")),1,12)},"LEFT")
    TRCell():New(oSecSC,"NCAMPO"		,"   ","Campo Alterado"	," ",20								,/*lPixel*/,{||RetTitle(XDEM->ZAJ_CAMPO)},"LEFT")
    TRCell():New(oSecSC,"ZAJ_DE"		,"   ","DE"				,"@!",TamSX3("ZAJ_DE")[01]+5		,/*lPixel*/,{||XDEM->ZAJ_DE},"LEFT")
    TRCell():New(oSecSC,"ZAJ_PARA"		,"   ","PARA"			,"@!",TamSX3("ZAJ_PARA")[01]		,/*lPixel*/,{||XDEM->ZAJ_PARA},"LEFT")
    TRCell():New(oSecSC,"ZAJ_DTALT"	    ,"   ","Data Alter"		,"@D",TamSX3("ZAJ_DTALT")[01]+5		,/*lPixel*/,{||XDEM->ZAJ_DTALT},"LEFT")
    TRCell():New(oSecSC,"ZAJ_HORA"		,"   ","Hora Alter"		,"@!",TamSX3("ZAJ_HORA")[01]+5		,/*lPixel*/,{||XDEM->ZAJ_HORA},"LEFT")
    TRCell():New(oSecSC,"ZAJ_USRALT"	,"   ","Usuario Alt"	," ",TamSX3("ZAJ_USRALT")[01]		,/*lPixel*/,{||XDEM->ZAJ_USRALT},"LEFT")

    // Quebra 1 - Solicitacao
    oBreak1 := TRBreak():New(oSecSC,{|| (XDEM->ZAJ_SEQ) },"Processo")

    oReport:SetTotalInLine(.F.)
    oReport:lUnderLine := .F.

    dbSelectArea("XDEM")
    nCount:=Contar("XDEM",".NOT. EOF()")
    XDEM->(dbGotop())

    // Titulo
    oReport:SetTitle(cTitulo)

    // Regua
    oReport:SetMeter(nCount)

    // Esconde a Secao referente a Filial para impressao somente dos totais
    oReport:cFontBody := 'Courier New'
    oReport:nFontBody := 6
    oReport:EndReport(.F.)

    oSecSC:lHeaderSection := .T.
    oSecSC:Init()

    While .NOT. oReport:Cancel() .And. .NOT. XDEM->(EOF())

        If oReport:Cancel()
            Exit
        EndIf

        oReport:SetMsgPrint("Imprimindo ...")
        oReport:SkipLine()
        oReport:IncMeter()

        oSecSC:PrintLine()

        If oReport:nDevice == 4 .And. oSecSC:lHeaderSection
            oReport:lHeaderVisible := .F.
            oSecVend:lHeaderSection := .F.
        EndIf

        XDEM->(DbSkip())

    End
    oSecSC:Finish()

    dbSelectArea("XDEM")

    oReport:Finish()

    If Select ("XDEM") > 0
        XDEM->(DbCloseArea())
    EndIf

Return (NIL)

/*/{Protheus.doc} _FQuery
Motagem Uqry para filtro
@type function Processamento
@version  1.0
@author marioantonaccio
@since 30/01/2026
@return character, sem retorno
/*/
Static Function _FQuery()

    //Montando consulta de dados
    BeginSql Alias "XDEM"
        COLUMN ZAJ_DTALT AS DATE
        SELECT
            ZAJ_PROD,
            ZAJ_FORNEC,
            ZAJ_LOJA,
            ZAJ_CAMPO,
            ZAJ_DE,
            ZAJ_PARA,
            ZAJ_DTALT,
            ZAJ_HORA,
            ZAJ_USRALT
        FROM
            %TABLE:ZAJ%
        WHERE
            %NOTDEL%
            AND ZAJ_FILIAL = %XFILIAL:ZAJ%
            AND ZAJ_DTALT = %EXP:DTOS(dDataBase)%
            AND ZAJ_TIPO = 'PR'
        ORDER BY
            ZAJ_SEQ,
            ZAJ_PROD
    EndSQL

Return (NIL)
User Function ConEspX3()

    Local oDlg
    Local oLbx
    Local aCpos  := {}
    Local aRet   := {}
    Local cAlias := GetNextAlias()
    Local lRet   := .F.

    BeginSQL Alias cAlias
        SELECT
            X3_CAMPO,
            X3_TITULO,
            X3_TIPO
        FROM
            %TABLE:SX3%
        WHERE
            %NOTDEL%
            AND X3_ARQUIVO = 'SB1'
        ORDER BY
            2
    EndSQL

    While (cAlias)->(!Eof())
        aAdd(aCpos,{(cAlias)->(X3_TITULO), (cAlias)->(X3_CAMPO), (cAlias)->(X3_TIPO)})
        (cAlias)->(dbSkip())
    End
    (cAlias)->(dbCloseArea())

    If Len(aCpos) < 1
        aAdd(aCpos,{" "," "," "})
    EndIf

    DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Campos de Arquivo" FROM 0,0 TO 240,500 PIXEL

    @ 10,10 LISTBOX oLbx FIELDS HEADER 'Titulo' /*"Roteiro"*/, 'Campo' /*"Produto"*/, 'Tipo' SIZE 230,95 OF oDlg PIXEL

    oLbx:SetArray( aCpos )
    oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3]}}
    oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3]}}}

    DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3]})  ENABLE OF oDlg
    ACTIVATE MSDIALOG oDlg CENTER

    If Len(aRet) > 0 .And. lRet
        If Empty(aRet[1])
            lRet := .F.
        Else
            SX3->(dbSetOrder(1))
            SX3->(dbSeek(aRet[2]))
        EndIf
    EndIf
Return (aRet[2])
