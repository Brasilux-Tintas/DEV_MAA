#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
/*/{Protheus.doc} BRALTCSTSD2
Altera o campo D2_CLASFIS de SD2 e D1_CLASFIS de SD1 e atualiza B1_ORIGEM em SB1
@type function Processamento
@version 1.1
@author GitHub Copilot
@since 16/06/2026
@return character, sem retorno
/*/
User Function BRALTCST()
    Local aSays    := {}
    Local aButtons := {}
    Local lOk      := .F.
    Local cResp:=""
    Private lConfirma:=.F.
    Private dDataIni:=CTOD(" ")
    aAdd(aSays, "Programa para ajustar CST de SD2 e SD1 e definir origem do produto.")
    aAdd(aSays, "Busca registros a partir de 01/05/2026 com D2_CLASFIS ou D1_CLASFIS de 2 posicoes.")
    aAdd(aSays, "O campo sera atualizado para ZERO (0)+CST e B1_ORIGEM sera preenchido com ZERO (0)")
    aAdd(aSays," se estiver vazio.")

    aAdd(aButtons, { 1, .T., {|| lOk := .T., FechaBatch() } })
    aAdd(aButtons, { 2, .T., {|| lOk := .F., FechaBatch() } })

    FormBatch("Atualização SD2/SD1 e Origem Produto", aSays, aButtons)

    If lOk
        cResp  := FWInputBox("Data Inicio de Ajuste", "Informe a Data para inicio do Ajuste" )
        dDataIni:=CTOD(cResp)
        If FWAlertYesNo("Confirma atualização de dados?", "Atualiza Dados")
            lConfirma:=.T.
        End
        Processa( { |lEnd| BRALCST01() }, "Processando registros SD2 e SD1...")
    End

Return (NIL)

Static Function BRALCST01()
    Local cOrigem    := "0" as character
    Local cClasFis   := " " as character
    Local cOrigAnt   := " " as character
    Local nReg    := 0   as Numeric
    Local nRegSB1 := 0   as Numeric
    Local nRegSD1 := 0   as Numeric
    Local nRegSD2 := 0   as Numeric
    Local nRegSFT := 0   as Numeric
    Local cSeq:=" "

    BeginSql Alias "XZAJ"
    SELECT
        MAX(ZAJ_SEQ) AS SEQ
    FROM
        %TABLE:ZAJ%
    WHERE
        %NOTDEL%
        AND ZAJ_DTALT = %EXP:DTOS(dDataIni)%
    EndSQL
    cSeq:=Soma1(XZAJ->SEQ)
    XZAJ->(dbCloseArea())

    BeginSql Alias "XSD2"
        SELECT
            R_E_C_N_O_ AS REGSD2
        FROM
            %TABLE:SD2%
        WHERE
            %NOTDEL%
            AND D2_EMISSAO >= %EXP:DTOS(dDataIni)%
            AND LEN(TRIM(D2_CLASFIS)) = 2
    EndSQL

    nReg := CONTAR("XSD2", ".NOT. EOF()")

    If nReg > 0
        SD2->(dbSetOrder(1))
        XSD2->(dbGoTop())
        ProcRegua(nReg)

        While XSD2->(.NOT. EOF())
            IncProc("Processando... SD2")
            SD2->(dbGoTo(XSD2->REGSD2))

            If Len(Alltrim(SD2->D2_CLASFIS)) == 2
                cClasFis := AllTrim(SD2->D2_CLASFIS)
                If lConfirma
                    RecLock("SD2", .F.)
                    SD2->D2_CLASFIS := cOrigem + cClasFis
                    MsUnLock()
                End
                nRegSD2++

                RecLock("ZAJ", .T.)
                ZAJ->ZAJ_FILIAL := SD2->D2_FILIAL //FWxFilial("ZAJ")
                ZAJ->ZAJ_NUMERO := SD2->D2_DOC+SD2->D2_SERIE
                ZAJ->ZAJ_FORNEC := SD2->D2_CLIENTE
                ZAJ->ZAJ_LOJA   := SD2->D2_LOJA
                ZAJ->ZAJ_PROD   := SD2->D2_COD
                ZAJ->ZAJ_CAMPO  := "D2_CLASFIS"
                ZAJ->ZAJ_DE     := cClasFis
                ZAJ->ZAJ_PARA   := cOrigem + cClasFis
                ZAJ->ZAJ_SEQ    := cSeq
                ZAJ->ZAJ_DTALT  := dDataBase
                ZAJ->ZAJ_HORA   := Time()
                ZAJ->ZAJ_USRALT := cUserName
                ZAJ->ZAJ_TIPO   := "D2"
                If FieldPos ("ZAJ_CHAVE") > 0
                    ZAJ->ZAJ_CHAVE:="SD2"
                End
                If FieldPos ("ZAJ_RECTAB") > 0
                    ZAJ->ZAJ_RECTAB:=XSD2->REGSD2
                End
                MsUnLock()
            End

            SB1->(dbSetOrder(1))
            //If SB1->(dbSeek(xFilial("SB1") + SD2->D2_COD))
            If SB1->(dbSeek(SD2->D2_FILIAL + SD2->D2_COD))
                If Empty(SB1->B1_ORIGEM) .and. SB1->B1_IMPORT <> "S"
                    cOrigAnt := SB1->B1_ORIGEM
                    If lConfirma
                        RecLock("SB1", .F.)
                        SB1->B1_ORIGEM := cOrigem
                        MsUnLock()
                    End
                    nRegSB1++

                    RecLock("ZAJ", .T.)
                    ZAJ->ZAJ_FILIAL := SB1->B1_FILIAL //FWxFilial("ZAJ")
                    ZAJ->ZAJ_NUMERO := "PRODUTO"
                    ZAJ->ZAJ_FORNEC := SB1->B1_GRUPO
                    ZAJ->ZAJ_LOJA   := SB1->B1_TIPO
                    ZAJ->ZAJ_PROD   := SB1->B1_COD
                    ZAJ->ZAJ_CAMPO  := "B1_ORIGEM"
                    ZAJ->ZAJ_DE     := cOrigAnt
                    ZAJ->ZAJ_PARA   := cOrigem
                    ZAJ->ZAJ_SEQ    := cSeq
                    ZAJ->ZAJ_DTALT  := dDataBase
                    ZAJ->ZAJ_HORA   := Time()
                    ZAJ->ZAJ_USRALT := cUserName
                    ZAJ->ZAJ_TIPO   := "PR"
                    If FieldPos ("ZAJ_CHAVE") > 0
                        ZAJ->ZAJ_CHAVE:="SB1"
                    End
                    If FieldPos ("ZAJ_RECTAB") > 0
                        ZAJ->ZAJ_RECTAB:=SB1->(RecNo())
                    End
                    MsUnLock()
                End
            End

            XSD2->(dbSkip())
        End

        XSD2->(dbCloseArea())
    End

    BeginSql Alias "XSD1"
        SELECT
            R_E_C_N_O_ AS REGSD1
        FROM
            %TABLE:SD1%
        WHERE
            %NOTDEL%
            AND D1_DTDIGIT >= %EXP:DTOS(dDataIni)%
            AND LEN(TRIM(D1_CLASFIS)) = 2
    EndSQL

    nReg := CONTAR("XSD1", ".NOT. EOF()")

    If nReg > 0
        SD1->(dbSetOrder(1))
        XSD1->(dbGoTop())
        ProcRegua(nReg)

        While XSD1->(.NOT. EOF())
            IncProc("Processando... SD1")
            SD1->(dbGoTo(XSD1->REGSD1))

            If Len(Alltrim(SD1->D1_CLASFIS)) == 2
                cClasFis        := AllTrim(SD1->D1_CLASFIS)
                If lConfirma
                    RecLock("SD1", .F.)
                    SD1->D1_CLASFIS := cOrigem + cClasFis
                    MsUnLock()
                End
                nRegSD1++

                RecLock("ZAJ", .T.)
                ZAJ->ZAJ_FILIAL :=SD1->D1_FILIAL // FWxFilial("ZAJ")
                ZAJ->ZAJ_NUMERO := SD1->D1_DOC+SD1->D1_SERIE
                ZAJ->ZAJ_FORNEC := SD1->D1_FORNECE
                ZAJ->ZAJ_LOJA   := SD1->D1_LOJA
                ZAJ->ZAJ_PROD   := SD1->D1_COD
                ZAJ->ZAJ_CAMPO  := "D1_CLASFIS"
                ZAJ->ZAJ_DE     := cClasFis
                ZAJ->ZAJ_PARA   := cOrigem + cClasFis
                ZAJ->ZAJ_SEQ    := cSeq
                ZAJ->ZAJ_DTALT  := dDataBase
                ZAJ->ZAJ_HORA   := Time()
                ZAJ->ZAJ_USRALT := cUserName
                ZAJ->ZAJ_TIPO   := "D1"
                If FieldPos ("ZAJ_CHAVE") > 0
                    ZAJ->ZAJ_CHAVE:="SD1"
                End
                If FieldPos ("ZAJ_RECTAB") > 0
                    ZAJ->ZAJ_RECTAB:=XSD1->REGSD1
                End
                MsUnLock()
            End

            SB1->(dbSetOrder(1))
            //If SB1->(dbSeek(xFilial("SB1") + SD1->D1_COD))
            If SB1->(dbSeek(SD1->D1_FILIAL + SD1->D1_COD))
                If Empty(SB1->B1_ORIGEM) .and. SB1->B1_IMPORT <> "S"
                    cOrigAnt := SB1->B1_ORIGEM
                    If lConfirma
                        RecLock("SB1", .F.)
                        SB1->B1_ORIGEM := cOrigem
                        MsUnLock()
                    End
                    nRegSB1++

                    RecLock("ZAJ", .T.)
                    ZAJ->ZAJ_FILIAL :=SB1->B1_FILIAL // FWxFilial("ZAJ")
                    ZAJ->ZAJ_NUMERO := "PRODUTO"
                    ZAJ->ZAJ_FORNEC := SB1->B1_GRUPO
                    ZAJ->ZAJ_LOJA   := SB1->B1_TIPO
                    ZAJ->ZAJ_PROD   := SB1->B1_COD
                    ZAJ->ZAJ_CAMPO  := "B1_ORIGEM"
                    ZAJ->ZAJ_DE     := cOrigAnt
                    ZAJ->ZAJ_PARA   := cOrigem
                    ZAJ->ZAJ_SEQ    := cSeq
                    ZAJ->ZAJ_DTALT  := dDataBase
                    ZAJ->ZAJ_HORA   := Time()
                    ZAJ->ZAJ_USRALT := cUserName
                    ZAJ->ZAJ_TIPO   := "PR"
                    If FieldPos ("ZAJ_CHAVE") > 0
                        ZAJ->ZAJ_CHAVE:="SB1"
                    End
                    If FieldPos ("ZAJ_RECTAB") > 0
                        ZAJ->ZAJ_RECTAB:=SB1->(RecNo())
                    End
                    MsUnLock()
                End
            End

            XSD1->(dbSkip())
        End

        XSD1->(dbCloseArea())
    End

 BeginSql Alias "XSFT"
        SELECT
            R_E_C_N_O_ AS REGSFT
        FROM
            %TABLE:SFT%
        WHERE
            %NOTDEL%
            AND FT_ENTRADA >= %EXP:DTOS(dDataIni)%
            AND LEN(TRIM(FT_CLASFIS)) = 2
    EndSQL

    nReg := CONTAR("XSFT", ".NOT. EOF()")

    If nReg > 0
        SFT->(dbSetOrder(1))
        XSFT->(dbGoTop())
        ProcRegua(nReg)

        While XSFT->(.NOT. EOF())
            IncProc("Processando... SFT")
            SFT->(dbGoTo(XSFT->REGSFT))

            If Len(Alltrim(SFT->FT_CLASFIS)) == 2
                cClasFis        := AllTrim(SFT->FT_CLASFIS)
                If lConfirma
                    RecLock("SFT", .F.)
                    SFT->FT_CLASFIS := cOrigem + cClasFis
                    MsUnLock()
                End
                nRegSFT++

                RecLock("ZAJ", .T.)
                ZAJ->ZAJ_FILIAL := SFT->FT_FILIAL // FWxFilial("ZAJ")
                ZAJ->ZAJ_NUMERO := SFT->FT_NFISCAL+SFT->FT_SERIE
                ZAJ->ZAJ_FORNEC := SFT->FT_CLIEFOR
                ZAJ->ZAJ_LOJA   := SFT->FT_LOJA
                ZAJ->ZAJ_PROD   := SFT->FT_PRODUTO
                ZAJ->ZAJ_CAMPO  := "FT_CLASFIS"
                ZAJ->ZAJ_DE     := cClasFis
                ZAJ->ZAJ_PARA   := cOrigem + cClasFis
                ZAJ->ZAJ_SEQ    := cSeq
                ZAJ->ZAJ_DTALT  := dDataBase
                ZAJ->ZAJ_HORA   := Time()
                ZAJ->ZAJ_USRALT := cUserName
                ZAJ->ZAJ_TIPO   := "FT"
                If FieldPos ("ZAJ_CHAVE") > 0
                    ZAJ->ZAJ_CHAVE:="SFT"
                End
                If FieldPos ("ZAJ_RECTAB") > 0
                    ZAJ->ZAJ_RECTAB:=XSFT->REGSFT
                End
                MsUnLock()
            End

            SB1->(dbSetOrder(1))
            //If SB1->(dbSeek(xFilial("SB1") + SD1->D1_COD))
            If SB1->(dbSeek(SFT->FT_FILIAL + SFT->FT_PRODUTO))
                If Empty(SB1->B1_ORIGEM) .and. SB1->B1_IMPORT <> "S"
                    cOrigAnt := SB1->B1_ORIGEM
                    If lConfirma
                        RecLock("SB1", .F.)
                        SB1->B1_ORIGEM := cOrigem
                        MsUnLock()
                    End
                    nRegSB1++

                    RecLock("ZAJ", .T.)
                    ZAJ->ZAJ_FILIAL :=SB1->B1_FILIAL // FWxFilial("ZAJ")
                    ZAJ->ZAJ_NUMERO := "PRODUTO"
                    ZAJ->ZAJ_FORNEC := SB1->B1_GRUPO
                    ZAJ->ZAJ_LOJA   := SB1->B1_TIPO
                    ZAJ->ZAJ_PROD   := SB1->B1_COD
                    ZAJ->ZAJ_CAMPO  := "B1_ORIGEM"
                    ZAJ->ZAJ_DE     := cOrigAnt
                    ZAJ->ZAJ_PARA   := cOrigem
                    ZAJ->ZAJ_SEQ    := cSeq
                    ZAJ->ZAJ_DTALT  := dDataBase
                    ZAJ->ZAJ_HORA   := Time()
                    ZAJ->ZAJ_USRALT := cUserName
                    ZAJ->ZAJ_TIPO   := "PR"
                    If FieldPos ("ZAJ_CHAVE") > 0
                        ZAJ->ZAJ_CHAVE:="SB1"
                    End
                    If FieldPos ("ZAJ_RECTAB") > 0
                        ZAJ->ZAJ_RECTAB:=SB1->(RecNo())
                    End
                    MsUnLock()
                End
            End

            XSFT->(dbSkip())
        End

        XSFT->(dbCloseArea())
    End

    FWAlertSuccess("Rotina finalizada com sucesso!" + CRLF + CRLF + ;
        "SD2 alterados  : " + cValToChar(nRegSD2) + CRLF + ;
        "SD1 alterados  : " + cValToChar(nRegSD1) + CRLF + ;
        "SFT alterados  : " + cValToChar(nRegSFT) + CRLF + ;
        "SB1 atualizados: " + cValToChar(nRegSB1) + CRLF + ;
        " "+ CRLF + ;
        "Total Registros Processados: " + cValToChar(nRegSB1+nRegSD1+nRegSD2+nRegSFT),"Finalizado")

    If FWAlertYesNo("Imprime relatorio de LOG?", "Imprime LOG")
        BRALCST02()
    End

Return (NIL)

Static Function BRALCST02()
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
    oReport:=TReport():New("BRALCSTA",cTitle,"", {|oReport| BRALCST04(),RPrintCom(oReport)},;
        "Este programa emite o Relatorio de LOG de Alteracao de CST.")

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

    TRCell():New(oSec, "ZAJ_FILIAL", " ", "Filial"      , " " , TamSX3( 'ZAJ_FILIAL' )[01] , {||XDEM->ZAJ_FILIAL}         , "LEFT")
    TRCell():New(oSec, "ZAJ_NUMERO", " ", "No.DOC"      , " " , TamSX3( 'ZAJ_NUMERO' )[01] , {||XDEM->ZAJ_NUMERO}         , "LEFT")
    TRCell():New(oSec, "ZAJ_PROD"  , " ", "Produto"     , " " , TamSX3( 'ZAJ_PROD' )[01]   , {||XDEM->ZAJ_PROD}           , "LEFT")
    TRCell():New(oSec, "ZAJ_FORNEC", " ", "Forn/Cliente", " " , TamSX3( 'ZAJ_FORNEC' )[01] , {||XDEM->ZAJ_FORNEC}         , "LEFT")
    TRCell():New(oSec, "ZAJ_LOJA"  , " ", "Loja"        , " " , TamSX3( 'ZAJ_LOJA' )[01]   , {||XDEM->ZAJ_LOJA}           , "LEFT")
    TRCell():New(oSec, "ZAJ_CAMPO" , " ", "Campo"       , " " , 20                         , {||RetTitle(XDEM->ZAJ_CAMPO)}, "LEFT")
    TRCell():New(oSec, "ZAJ_DE"    , " ", "DE"          , "@!", TamSX3( 'ZAJ_DE' )[01]+5   , {||XDEM->ZAJ_DE}             , "LEFT")
    TRCell():New(oSec, "ZAJ_PARA"  , " ", "PARA"        , "@!", TamSX3( 'ZAJ_PARA' )[01]   , {||XDEM->ZAJ_PARA}           , "LEFT")
    TRCell():New(oSec, "ZAJ_DTALT" , " ", "Data"        , "@D", TamSX3( 'ZAJ_DTALT' )[01]+5, {||XDEM->ZAJ_DTALT}          , "LEFT")
    TRCell():New(oSec, "ZAJ_HORA"  , " ", "Hora"        , "@!", TamSX3( 'ZAJ_HORA' )[01]+5 , {||XDEM->ZAJ_HORA}           , "LEFT")
    TRCell():New(oSec, "ZAJ_USRALT", " ", "Usuario"     , " " , TamSX3( 'ZAJ_USRALT' )[01] , {||XDEM->ZAJ_USRALT}         , "LEFT")

    // Quebra 1 - Solicitacao
    oBreak1 := TRBreak():New(oSecSC,{|| (XDEM->ZAJ_FILIAL) },"Processo")

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

Static Function BRALCST04()
    BeginSql Alias "XDEM"
        SELECT
            ZAJ_FILIAL,
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
            AND ZAJ_DTALT = %EXP:DTOS(dDataBASE)%
            AND ZAJ_TIPO IN ('PR', 'D1', 'D2')
        ORDER BY
            ZAJ_PROD,
            ZAJ_FORNEC,
            ZAJ_LOJA
    EndSQL

Return (NIL)
