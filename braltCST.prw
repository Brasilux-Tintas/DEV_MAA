#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*/{Protheus.doc} BRALTCST
Permite a alteração de CST/Origem nos campos D1_CLASFIS/D2_CLASFIS/B1_ORIGEM
@type function Processamento
@version  1.0
@author marioantonaccio
@since 10/03/2026
@return character, sem retorno
/*/
User Function BRALTCST()
    Local aSays        := {}
    Local aButtons     := {}
    Local lOk          := .F.

    //Identifica se a rotina esta em uso
    If .NOT. SuperGetMV("BR_ALTCST",.F.,.F.)
        Return(NIL)
    End

    //Popula as linhas que serão mostradas na tela
    aAdd(aSays, "Esse programa tem como objetivo efetuar a troca de um CST que esteja errado")
    aAdd(aSays, "(2 posicoes) corrigindo para 3 posicoes.")

    //Botões da tela, cada botão tem um Bloco de Código
    aAdd(aButtons, { 1, .T., {|| lOk := .T., FechaBatch() }} )
    aAdd(aButtons, { 2, .T., {|| lOk := .F., FechaBatch() }} )

    //Chama a tela principal
    FormBatch("Alteração de CST", aSays, aButtons)

    //Se foi confirmado a tela
    If lOk
        Processa( { |lEnd| BRACST01() }, "Processando Alteração CST/Origem.....")
    EndIf

Return (NIL)

/*/{Protheus.doc} BRACST01
Processo de alteração de CST/Origem
@type function Processamento
@version  1.00
@author marioantonaccio
@since 10/03/2026
@return character, sem retorno
/*/
Static Function BRACST01()

    Local cClasFis := " " as character
    Local cMsg     := " " as character
    Local cOrigem  := "0" as character
    Local cRegNFE  := " " as character
    Local cRegNFS  := " " as character
    Local cRegPr   := " " as character
    Local nReg     := 0   as Numeric
    Local nRegNFE  := 0   as Numeric
    Local nRegNFS  := 0   as Numeric
    Local nRegPr   := 0   as Numeric

    //Seleciona os Registros SD2
    BeginSql AlIAS "XSD2"
        SELECT
            R_E_C_N_O_ AS REGSD2
        FROM
            %TABLE:SD2%
        WHERE
            %NOTDEL%
            AND LEN(TRIM(D2_CLASFIS)) = 2
    EndSQL

    //Contagem de registros conforme parametro
    nReg:=CONTAR("XSD2",".NOT. EOF()")

    // Se nao existir registros retorna
    If nReg > 0

        //Confirma execução rotina
        SD2->(dbSetOrder(1))
        XSD2->(dbGoTop())

        ProcRegua(nReg)
        While XSD2->(.NOT. EOF())

            IncProc("Processando...SD2")

            SD2->(dbGoTo(XSD2->REGSD2))

            SB1->(dbSetOrder(1))
            If SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))
                If Empty(SB1->B1_ORIGEM) .and. SB1->B1_IMPORT <>"S"
                    cRegPr:=StrZero(nRegpr,2,0)

                    RecLock("SB1",.F.)
                    //SB1->B1_ORIGEM := cOrigem
                    MsUnLock()

                    //Grava Log
                    ZAJ->(dbSetOrder(1))
                    ZAJ->(dbSetOrder(1))
                    RecLock("ZAJ",.T.)
                    ZAJ->ZAJ_FILIAL := FWxFilial( 'ZAJ' )
                    ZAJ->ZAJ_NUMERO := "ALTCST "
                    ZAJ->ZAJ_FORNEC := SB1->B1_FILIAL
                    ZAJ->ZAJ_LOJA   := " "
                    ZAJ->ZAJ_PROD   := SB1->B1_COD
                    ZAJ->ZAJ_CAMPO  := "B1_ORIGEM"
                    ZAJ->ZAJ_DE     := " "
                    ZAJ->ZAJ_PARA   := cOrigem
                    ZAJ->ZAJ_SEQ    := Soma1(cRegPr)
                    ZAJ->ZAJ_DTALT  := dDataBase
                    ZAJ->ZAJ_HORA   := Time()
                    ZAJ->ZAJ_USRALT := cUserName
                    ZAJ->ZAJ_TIPO   := "PR"
                    MsUnLock()
                    nRegPr++
                End
            End

            If Len(Alltrim(SD2->D2_CLASFIS)) == 2
                cRegNFS:=StrZero(nRegNFS,2,0)
                cClasFis:=AllTrim(SD2->D2_CLASFIS)

                RecLock("SD2",.F.)
                //SD2->D2_CLASFIS:=cOrigem+cClasFis
                MsUnLock()

                //Grava Log
                ZAJ->(dbSetOrder(1))
                ZAJ->(dbSetOrder(1))
                RecLock("ZAJ",.T.)
                ZAJ->ZAJ_FILIAL := FWxFilial( 'ZAJ' )
                ZAJ->ZAJ_NUMERO := SD2->D2_DOC
                ZAJ->ZAJ_FORNEC := SD2->D2_CLIENTE
                ZAJ->ZAJ_LOJA   := SD2->D2_LOJA
                ZAJ->ZAJ_PROD   := SD2->D2_COD
                ZAJ->ZAJ_CAMPO  := "D2_CLASFIS"
                ZAJ->ZAJ_DE     := cClasFis
                ZAJ->ZAJ_PARA   := SD2->D2_CLASFIS
                ZAJ->ZAJ_SEQ    := Soma1(cRegNFS)
                ZAJ->ZAJ_DTALT  := dDataBase
                ZAJ->ZAJ_HORA   := Time()
                ZAJ->ZAJ_USRALT := cUserName
                ZAJ->ZAJ_TIPO   := "D2"
                MsUnLock()
                cRegNFS++
            End

            XSD2->(dbSkip())
        
        End

        XSD2->(dbCloseArea())
    
    End

    //Seleciona os Registros SD1
    BeginSql AlIAS "XSD1"
        SELECT
            R_E_C_N_O_ AS REGSD1
        FROM
            %TABLE:SD1%
        WHERE
            %NOTDEL%
            AND LEN(TRIM(D1_CLASFIS)) = 2
    EndSQL

    //Contaem de registros conforme parametro
    nReg:=CONTAR("XSD1",".NOT. EOF()")

    // Se nao existir registros retorna
    If nReg >  0

        SD1->(dbSetOrder(1))

        XSD1->(dbGoTop())

        ProcRegua(nReg)

        While XSD1->(.NOT. EOF())

            IncProc("Processando...SD1")

            SD1->(dbGoTo(XSD1->REGSD1))
            SB1->(dbSetOrder(1))

            If SB1->(dbSeek(xFilial("SB1")+SD1->D1_COD))

                If Empty(SB1->B1_ORIGEM) .and. SB1->B1_IMPORT <>"S"
                    cRegPr:=StrZero(nRegpr,2,0)

                    RecLock("SB1",.F.)
                    // SB1->B1_ORIGEM := cOrigem
                    MsUnLock()

                    //Grava Log
                    ZAJ->(dbSetOrder(1))
                    ZAJ->(dbSetOrder(1))
                    RecLock("ZAJ",.T.)
                    ZAJ->ZAJ_FILIAL := FWxFilial( 'ZAJ' )
                    ZAJ->ZAJ_NUMERO := "ALTCST "
                    ZAJ->ZAJ_FORNEC := SB1->B1_FILIAL
                    ZAJ->ZAJ_LOJA   := " "
                    ZAJ->ZAJ_PROD   := SB1->B1_COD
                    ZAJ->ZAJ_CAMPO  := "B1_ORIGEM"
                    ZAJ->ZAJ_DE     := " "
                    ZAJ->ZAJ_PARA   := cOrigem
                    ZAJ->ZAJ_SEQ    := Soma1(cRegPr)
                    ZAJ->ZAJ_DTALT  := dDataBase
                    ZAJ->ZAJ_HORA   := Time()
                    ZAJ->ZAJ_USRALT := cUserName
                    ZAJ->ZAJ_TIPO   := "PR"
                    MsUnLock()
                    nRegPr++
                End
            End

            If Len(Alltrim(SD1->D1_CLASFIS)) == 2
                cRegNFE:=StrZero(nRegNFE,2,0)
                cClasFis:=AllTrim(SD1->D1_CLASFIS)

                RecLock("SD1",.F.)
                //  SD1->D1_CLASFIS:=cOrigem+cClasFis
                MsUnLock()

                //Grava Log
                ZAJ->(dbSetOrder(1))
                ZAJ->(dbSetOrder(1))
                RecLock("ZAJ",.T.)
                ZAJ->ZAJ_FILIAL := FWxFilial( 'ZAJ' )
                ZAJ->ZAJ_NUMERO := SD1->D1_DOC
                ZAJ->ZAJ_FORNEC := SD1->D1_FORNECE
                ZAJ->ZAJ_LOJA   := SD1->D1_LOJA
                ZAJ->ZAJ_PROD   := SD1->D1_COD
                ZAJ->ZAJ_CAMPO  := "D1_CLASFIS"
                ZAJ->ZAJ_DE     := cClasFis
                ZAJ->ZAJ_PARA   := SD1->D1_CLASFIS
                ZAJ->ZAJ_SEQ    := Soma1(cRegNFE)
                ZAJ->ZAJ_DTALT  := dDataBase
                ZAJ->ZAJ_HORA   := Time()
                ZAJ->ZAJ_USRALT := cUserName
                ZAJ->ZAJ_TIPO   := "D1"
                MsUnLock()
                cRegNFE++
            End

            XSD1->(dbSkip())
        
        End
    
        XSD1->(dbCloseArea())
    
    End

    cMsg:="Rotina Finalizada Com SUCESSO!!!"+CRLF+CRLF
    cMsg+="Registros Alterados Total: "+cValToChar(nRegPR+nREgNFS+nREgNFE)+CRLF+CRLF
    cMsg+="Registros Alterados SB1  : "+cValToChar(nRegPR)+CRLF+CRLF
    cMsg+="Registros Alterados SD1  : "+cValToChar(nRegNFE)+CRLF+CRLF
    cMsg+="Registros Alterados SD2  : "+cValToChar(nRegNFS)+CRLF+CRLF
    FWAlertSuccess(cMsg, "Rotina Finalizada")

    If FWAlertYesNo("Deseja ver o Log de Alteração?", "LOG de alterações")
        BRACST02()
    End

Return(Nil)

/*/{Protheus.doc} BRACST02()
Geraçao e impressao de arquivo de LOG de Alterações
@type function Relatorio
@version  1.0
@author marioantonaccio
@since 11/03/2026
@return character, sem retorno
/*/
Static Function BRACST02()

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

    cTitle := "Log de Alteração de CST"
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
    oReport:=TReport():New("BRACST02",cTitle,"", {|oReport| _FQuery(),RPrintCom(oReport)},;
        "Este programa emite o Relatorio de LOG de Alteracao de CST/Origem.")

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

    TRCell():New(oSecSC, "ZAJ_NUMERO", " ", "No.DOC"        , " " , TamSX3( 'ZAJ_NUMERO' )[01], /*lPixel*/, {||XDEM->ZAJ_NUMERO}         , "LEFT")
    TRCell():New(oSecSC, "ZAJ_FORNEC", " ", "Cliente"       , " " , TamSX3( 'ZAJ_FORNEC' )[01], /*lPixel*/, {||XDEM->ZAJ_FORNEC}         , "LEFT")
    TRCell():New(oSecSC, "ZAJ_LOJA"  , " ", "Loja"          , " " , TamSX3( 'ZAJ_LOJA' )[01]  , /*lPixel*/, {||XDEM->ZAJ_LOJA}           , "LEFT")
    TRCell():New(oSecSC, "ZAJ_PROD"  , " ", "Produto"       , " " , TamSX3( 'ZAJ_PROD' )[01]  , /*lPixel*/, {||XDEM->ZAJ_PROD}           , "LEFT")
    TRCell():New(oSecSC, "NCAMPO"    , " ", "Campo Alterado", " " , 20                        , /*lPixel*/, {||RetTitle(XDEM->ZAJ_CAMPO)}, "LEFT")
    TRCell():New(oSecSC, "ZAJ_DE"    , " ", "DE"            , "@!", TamSX3("ZAJ_DE")[01]+5    , /*lPixel*/, {||XDEM->ZAJ_DE}             , "LEFT")
    TRCell():New(oSecSC, "ZAJ_PARA"  , " ", "PARA"          , "@!", TamSX3("ZAJ_PARA")[01]    , /*lPixel*/, {||XDEM->ZAJ_PARA}           , "LEFT")
    TRCell():New(oSecSC, "ZAJ_DTALT" , " ", "Data Alter"    , "@D", TamSX3("ZAJ_DTALT")[01]+5 , /*lPixel*/, {||XDEM->ZAJ_DTALT}          , "LEFT")
    TRCell():New(oSecSC, "ZAJ_HORA"  , " ", "Hora Alter"    , "@!", TamSX3("ZAJ_HORA")[01]+5  , /*lPixel*/, {||XDEM->ZAJ_HORA}           , "LEFT")
    TRCell():New(oSecSC, "ZAJ_USRALT", " ", "Usuario Alt"   , " " , TamSX3("ZAJ_USRALT")[01]  , /*lPixel*/, {||XDEM->ZAJ_USRALT}         , "LEFT")

    // Quebra 1 - Solicitacao
    oBreak1 := TRBreak():New(oSecSC,{|| (XDEM->ZAJ_PROD) },"Processo")

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
            ZAJ_NUMERO,
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
            AND ZAJ_TIPO IN ('PR', 'D1', 'D2')
        ORDER BY
            ZAJ_PROD,
            ZAJ_FORNEC,
            ZAJ_LOJA
    EndSQL

Return (NIL)
