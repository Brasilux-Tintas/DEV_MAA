#include "rwmake.ch"
#include "PROTHEUS.CH"
#include "Fileio.ch"
#include "TBICONN.CH"
#include "topconn.ch"
#include "COLORS.CH"
#include "RPTDEF.CH"
#include "FWPrintSetup.ch"

/*Programa que faz a consulta e exibe a informação salva na tabela ZAK*/
User Function BRCONBRA()

    Private aSays        := {}
    Private aButtons     := {}
    Private cTitulo      := "CONSULTA BRADESCO"
    Private lParam       := .F.
    Private cFuncionario := "" //AQUI CARAMBA
    Private cQry         := ""
    Private cCPF         := ""
    Private cNomRel      := ""

    AADD(aSays, "Informe o CPF do funcionário para buscar suas informações!")

    AADD(aButtons, {5, .T., {||  xParamBox()           }})
    AADD(aButtons, {1, .T., {|o| fBusca(o)             }})
    AADD(aButtons, {2, .T., {|o| dbCloseArea(), MS_Flush(), o:oWnd:End()}})

    FormBatch(cTitulo, aSays, aButtons,, 200, 405)
Return

Static Function fBusca(o)
    If ConsultaArquivo()
        o:oWnd:End()
    EndIf
Return

Static Function fMontaQry(cCPFParam)
    Local cQ := ""
    cQ := "    SELECT DISTINCT                          " + CRLF
    cQ += "    ZAK.ZAK_FUNCPF  AS CPF,                  " + CRLF
    cQ += "    ZAK.ZAK_FUNNOM  AS NOME,                 " + CRLF
    cQ += "    ZAK.ZAK_FUNCON  AS CONTA,                " + CRLF
    cQ += "    ZAK.ZAK_FUNAGE  AS AGENCIA,              " + CRLF
    cQ += "    ZAK.ZAK_FUNBAN  AS BANCO,                " + CRLF
    cQ += "    ZAK.ZAK_FUNTIP  AS TIPO                  " + CRLF
    cQ += "    FROM " + RetSqlName("ZAK") + " ZAK       " + CRLF
    cQ += "    WHERE ZAK.D_E_L_E_T_ = ' '               " + CRLF
    cQ += "    AND ZAK.ZAK_FUNCPF = '" + cCPFParam + "' " + CRLF
    cQ += "    ORDER BY NOME                            " + CRLF
Return cQ

Static Function ConsultaArquivo()
    Local cAlias   := GetNextAlias()
    Local aDados   := {}

    If !lParam
        MsgAlert("Parâmetros não informados, consulta cancelada.")
        Return .F.
    EndIf

    cCPF := fLimpaCPF(cFuncionario)

    If Empty(cCPF)
        MsgAlert("CPF não informado, consulta cancelada.")
        Return .F.
    EndIf

    cQry := fMontaQry(cCPF)

    If Select(cAlias) <> 0
        (cAlias)->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,, cQry), cAlias, .F., .T.)
    DbSelectArea(cAlias)
    DbGoTop()

    While !Eof()
        AAdd(aDados, {;
            AllTrim((cAlias)->CPF)    ,;
            AllTrim((cAlias)->NOME)   ,;
            AllTrim((cAlias)->CONTA)  ,;
            AllTrim((cAlias)->AGENCIA),;
            AllTrim((cAlias)->BANCO)  ,;
            AllTrim((cAlias)->TIPO)   ;
            })
        DbSkip()
    EndDo

    (cAlias)->(dbCloseArea())

Return fMostraDados(aDados, cFuncionario)

Static Function xParamBox()
    Local aRet      := {}
    Local aParambox := {}

    AADD(aParambox, {1, "Funcionário (CPF)", Space(14), "", "", "ZAK", "", 0, .F.})

    If Parambox(aParambox, "Informe o CPF", @aRet)
        cFuncionario := AllTrim(aRet[1])
        lParam := .T.
    Else
        lParam := .F.
    EndIf
Return

Static Function fMostraDados(aDados, cFuncionario)
    Local oDlg
    Local oBrw
    Local oBtnVol
    Local oBtnExp
    Local oBtnSai
    Local cBrw       := ""
    Local lVolta     := .F.
    Local lFechaIni  := .T.

    If Len(aDados) == 0
        ApMsgStop("Funcionário sem informações cadastradas.")
        fLimpaParam()
        Return .F.
    EndIf

    DEFINE MSDIALOG oDlg ;
        TITLE OemToAnsi("Folha de Pagamento - " + AllTrim(cFuncionario)) ;
        From 000, 000 To 290, 900 PIXEL

    @ 005, 005 LISTBOX oBrw VAR cBrw ;
        FIELDS HEADER "CPF", "NOME", "CONTA", "AGENCIA", "BANCO", "TIPO" ;
        SIZE 440, 125 OF oDlg PIXEL

    oBrw:SetArray(aDados)
    oBrw:bLine := {|| {;
        fMaskCPF(aDados[oBrw:nAt][1]),;
        OemToAnsi(aDados[oBrw:nAt][2]),;
        aDados[oBrw:nAt][3],;
        aDados[oBrw:nAt][4],;
        aDados[oBrw:nAt][5],;
        aDados[oBrw:nAt][6];
        }}
    oBrw:lAdjustColSize := .T.
    oDlg:nStyle := nOR(DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE)

    @ 132, 005 BUTTON oBtnVol PROMPT "Voltar"   SIZE 070, 013 OF oDlg ACTION (lVolta := .T., oDlg:End()) PIXEL
    @ 132, 080 BUTTON oBtnExp PROMPT "Exportar" SIZE 055, 013 OF oDlg ACTION fRelFun(aDados, cFuncionario) PIXEL
    @ 132, 385 BUTTON oBtnSai PROMPT "Sair"     SIZE 050, 013 OF oDlg ACTION (fLimpaParam(), lFechaIni := .F., oDlg:End()) PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

    If lVolta
        xParamBox()
        If lParam
            Return ConsultaArquivo()
        EndIf
        fLimpaParam()
        Return .F.
    EndIf
Return lFechaIni

Static Function fRelFun(aDados, cFuncionario)
    Local oReport := Nil

    If Len(aDados) == 0
        MsgAlert(OemToAnsi("Nenhum dado para exportar."))
        Return
    EndIf

    cCPF := aDados[1][1]
    cNomRel := OemToAnsi(AllTrim(cFuncionario))

    oReport := fDefRelFun()
    oReport:PrintDialog()

    cCPF := ""
    cNomRel := ""
Return

Static Function fDefRelFun()
    Local oReport  := Nil
    Local oSection := Nil

    oReport := TReport():New( ;
        "BRCRELFUN",;
        OemToAnsi("Detalhe do Pagamento - Crédito em Conta Salário"),;
        ,;
        {|oRpt| fPrnRelFun(oRpt)},;
        OemToAnsi("Funcionário: " + cNomRel) ;
        )

    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .F.
    oReport:oPage:SetPaperSize(9)
    oReport:SetPortrait()
    oReport:SetLineHeight(50)
    oReport:nFontBody := 10

    oSection := TRSection():New(oReport, OemToAnsi("Dados do Funcionário"), {"QRY_ZAKREL"})
    oSection:SetTotalInLine(.F.)

    TRCell():New(oSection, "CPF"    , "QRY_ZAKREL", "CPF"              ,, 20,,, "LEFT",,,,, .F.,,, .T.)
    TRCell():New(oSection, "NOME"   , "QRY_ZAKREL", OemToAnsi("Nome")  ,, 50,,, "LEFT",,,,, .F.,,, .F.)
    TRCell():New(oSection, "BANCO"  , "QRY_ZAKREL", "Banco"            ,, 10,,, "LEFT",,,,, .F.,,, .F.)
    TRCell():New(oSection, "AGENCIA", "QRY_ZAKREL", OemToAnsi("Agência"),, 10,,, "LEFT",,,,, .F.,,, .F.)
    TRCell():New(oSection, "CONTA"  , "QRY_ZAKREL", "Conta"            ,, 20,,, "LEFT",,,,, .F.,,, .F.)
    TRCell():New(oSection, "TIPO"   , "QRY_ZAKREL", "Tipo"             ,, 15,,, "LEFT",,,,, .F.,,, .F.)

Return oReport

Static Function fPrnRelFun(oReport)
    Local aArea   := FWGetArea()
    Local oSect   := Nil
    Local nAtual  := 0
    Local nTotal  := 0

    oSect := oReport:Section(1)

    If Select("QRY_ZAKREL") <> 0
        dbSelectArea("QRY_ZAKREL")
        dbCloseArea()
    EndIf

    PlsQuery(cQry, "QRY_ZAKREL")
    dbSelectArea("QRY_ZAKREL")
    Count To nTotal
    oReport:SetMeter(nTotal)

    oSect:Init()
    QRY_ZAKREL->(dbGoTop())
    While !QRY_ZAKREL->(Eof())
        nAtual++
        oReport:SetMsgPrint(OemToAnsi("Imprimindo " + cValToChar(nAtual) + " de " + cValToChar(nTotal)))
        oReport:IncMeter()
        oSect:PrintLine()
        QRY_ZAKREL->(dbSkip())
    EndDo
    oSect:Finish()
    QRY_ZAKREL->(dbCloseArea())

    FWRestArea(aArea)
Return

/*Limpa totalmente os parametros caso o funcionario não tenha dados assim já volta vazia para uma nova consulta*/
Static Function fLimpaParam()
    cFuncionario := ""
    cCPF         := ""
    cQry         := ""
    lParam       := .F.
Return

/*Mascara para usar no CPF*/
Static Function fMaskCPF(cCPFParam)
    Local cRet := AllTrim(cCPFParam)
    If Len(cRet) == 11
        cRet := SubStr(cRet,1,3) + "." + SubStr(cRet,4,3) + "." + SubStr(cRet,7,3) + "-" + SubStr(cRet,10,2)
    EndIf
Return cRet

/*Verifica se o CPF esta vazio ou se tem a quantidade de caracteres e após isso limpa a formatação*/
Static Function fLimpaCPF(cCPFParam)
    Local cRet := AllTrim(StrTran(StrTran(StrTran(cCPFParam, ".", ""), "-", ""), " ", ""))
    Local cTemp := ""
    Local nI := 0

    For nI := 1 To Len(cRet)
        If SubStr(cRet, nI, 1) >= "0" .And. SubStr(cRet, nI, 1) <= "9"
            cTemp += SubStr(cRet, nI, 1)
        EndIf
    Next nI

    If Len(cTemp) <> 11 .Or. Empty(cTemp)
        Return ""
    EndIf
Return cTemp
