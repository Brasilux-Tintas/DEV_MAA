#Include "protheus.ch"

/*/{Protheus.doc} BRPEDFC3
Consulta e mostra pedidos em aberto com controle FCI em tres grids.
@type function Processamento
@version  1.00
@author marioantonaccio
@since 22/05/2026
@return character, sem retorno
/*/
User Function BRPEDFC3()

    Local aArea       := {}  as array
    Private aFCI_OK   := {}  as array
    Private aFCI_RET  := {}  as array
    Private aFCI_GER  := {}  as array
    Private cPerCal   := " " as character
    Private lAjusta   := .T. as logical

    aArea := FWGetArea()

    MsAguarde({|| BRPED300()}, "Aguarde...", "Processando Registros...")

    If Empty(aFCI_OK) .And. Empty(aFCI_RET) .And. Empty(aFCI_GER)
        FWAlertInfo("Nenhum pedido encontrado.","Consulta FCI")
    Else
        BRPED301()
    EndIf

    FWRestArea(aArea)

Return (NIL)

/*/{Protheus.doc} BRPED301
Tela com tres grids, totais e botoes.
@type function Tela
@version  1.00
@author marioantonaccio
@since 22/05/2026
@return logical, retorna .T. se a tela foi montada com sucesso
/*/
Static Function BRPED301()

    Local cTotOk       := cValToChar(Len(aFCI_OK))  as character
    Local cTotRet      := cValToChar(Len(aFCI_RET)) as character
    Local cTotGer      := cValToChar(Len(aFCI_GER)) as character
    Local oGet1        as object
    Local oGet2        as object
    Local oGet3        as object
    Private oDlgFCI    as object
    Private oGetDados1 as object
    Private oGetDados2 as object
    Private oGetDados3 as object

    DEFINE MSDIALOG oDlgFCI TITLE "Pedidos Abertos com FCI - Referencia "+Transform(cPerCal,"@R 99/9999") FROM C(120),C(140) TO C(720),C(967) PIXEL

    @ C(009),C(007) TO C(099),C(382) LABEL "Pedidos com FCI na CFD" PIXEL OF oDlgFCI
    @ C(102),C(010) SAY "Total de Pedidos com FCI" SIZE C(090),C(008) COLOR CLR_BLACK PIXEL OF oDlgFCI
    @ C(102),C(110) MSGET oGet1 VAR cTotOk SIZE C(060),C(009) COLOR CLR_BLACK PICTURE "@ER 999999" PIXEL OF oDlgFCI

    @ C(114),C(007) TO C(204),C(382) LABEL "Pedidos com FCI Retirado" PIXEL OF oDlgFCI
    @ C(207),C(010) SAY "Total de Pedidos com FCI Retirado" SIZE C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlgFCI
    @ C(207),C(110) MSGET oGet2 VAR cTotRet SIZE C(060),C(009) COLOR CLR_BLACK PICTURE "@ER 999999" PIXEL OF oDlgFCI

    @ C(219),C(007) TO C(309),C(382) LABEL "Geral SC6 x CFD" PIXEL OF oDlgFCI
    @ C(312),C(010) SAY "Total Geral" SIZE C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgFCI
    @ C(312),C(110) MSGET oGet3 VAR cTotGer SIZE C(060),C(009) COLOR CLR_BLACK PICTURE "@ER 999999" PIXEL OF oDlgFCI

    @ C(327),C(195) BUTTON "Limpeza" SIZE C(050),C(012) PIXEL OF oDlgFCI ACTION {|| BRPED304() } WHEN lAjusta
    @ C(327),C(265) BUTTON "Impressao" SIZE C(050),C(012) PIXEL OF oDlgFCI ACTION {|| BRPED306() }
    @ C(327),C(333) BUTTON "Sair" SIZE C(050),C(012) PIXEL OF oDlgFCI ACTION oDlgFCI:End()

    oGet1:bWhen := {|| .F. }
    oGet2:bWhen := {|| .F. }
    oGet3:bWhen := {|| .F. }

    BRPED302(aFCI_OK,"1")
    BRPED302(aFCI_RET,"2")
    BRPED302(aFCI_GER,"3")

    ACTIVATE MSDIALOG oDlgFCI CENTERED

Return (.T.)

/*/{Protheus.doc} BRPED302
Montagem da visualizacao dos registros.
@type function Tela
@version 1.00
@author marioantonaccio
@since 22/05/2026
@param aDados, array, dados exibidos
@param cPos, character, indicativo do grid
@return character, sem retorno
/*/
Static Function BRPED302(aDados,cPos)

    Local aAlter    := {""}          as array
    Local aCol      := {}            as array
    Local aCpoGDa   := {}            as array
    Local aHead     := {}            as array
    Local cDelOk    := "AllwaysTrue" as character
    Local cFieldOk  := "AllwaysTrue" as character
    Local cIniCpos  := ""            as character
    Local cLinOk    := "AllwaysTrue" as character
    Local cSuperDel := ""            as character
    Local cTudoOk   := "AllwaysTrue" as character
    Local nDireita  := C(374)        as numeric
    Local nEsquerda := C(012)        as numeric
    Local nFreeze   := 0             as numeric
    Local nI        := 0             as numeric
    Local nInferior := C(098)        as numeric
    Local nMax      := 999           as numeric
    Local nOpc      := 0             as numeric
    Local nSuperior := C(022)        as numeric
    Local nUsado    := 0             as numeric
    Local nX        := 0             as numeric
    Local oWnd      := oDlgFCI       as object

    aCpoGDa := {"C6_NUM","C6_PRODUTO","C6_CLI","C6_LOJA","A1_NREDUZ","C6_CLASFIS","C6_FCICOD","CFD_COD","C9_STATUS"}

    If cPos == "2"
        nSuperior := C(127)
        nInferior := C(203)
    ElseIf cPos == "3"
        nSuperior := C(232)
        nInferior := C(308)
    EndIf

    aHead  := BRPED303(@aCpoGDa)
    nUsado := Len(aHead)

    For nI := 1 To Len(aDados)
        AAdd(aCol,Array(nUsado+1))
        For nX := 1 To nUsado
            aCol[nI][nX] := aDados[nI][nX]
        Next nX
        aCol[nI][nUsado+1] := .F.
    Next nI

    If cPos == "1"
        oGetDados1 := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
            aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)
    ElseIf cPos == "2"
        oGetDados2 := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
            aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)
    Else
        oGetDados3 := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
            aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)
    EndIf

Return (NIL)

/*/{Protheus.doc} BRPED303
Montagem do cabecalho dos grids.
@type function tela
@version  1.00
@author marioantonaccio
@since 22/05/2026
@param aHDer, array, array com os campos exibidos
@return array, array do cabecalho montado
/*/
Static Function BRPED303(aHDer)

    Local aHeadx := {} as array
    Local nX     := 0  as numeric

    DbSelectArea("SX3")
    SX3->(DbSetOrder(2))

    For nX := 1 To Len(aHDer)
        If SX3->(DbSeek(aHDer[nX]))
            AAdd(aHeadx,{AllTrim(X3Titulo()),;
                SX3->X3_CAMPO,;
                SX3->X3_PICTURE,;
                SX3->X3_TAMANHO,;
                SX3->X3_DECIMAL,;
                SX3->X3_VALID,;
                SX3->X3_USADO,;
                SX3->X3_TIPO,;
                SX3->X3_F3,;
                SX3->X3_CONTEXT,;
                SX3->X3_CBOX,;
                SX3->X3_RELACAO})
        EndIf
    Next nX

Return (aHeadx)

/*/{Protheus.doc} C
Ajuste de posionamento.
@type function Tela
@version  1.00
@author marioantonaccio
@since 19/05/2026
@param nTam, numeric, posicao na tela
@return numeric, posicao ajustada
/*/
Static Function C(nTam)

    Local nHRes := oMainWnd:nClientWidth as numeric

    If nHRes == 640
        nTam *= 0.8
    ElseIf (nHRes == 798) .Or. (nHRes == 800)
        nTam *= 1
    Else
        nTam *= 1.28
    EndIf

    If "MP8" $ oApp:cVersion
        If (AllTrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
            nTam *= 0.90
        EndIf
    EndIf

Return Int(nTam)

/*/{Protheus.doc} BRPED300
Montagem da query de pedidos em aberto.
@type function Processamento
@version  1.00
@author marioantonaccio
@since 22/05/2026
@return character, sem retorno
/*/
Static Function BRPED300()

    BEGINSQL ALIAS "QRYMAX"
        SELECT
            MAX(
                SUBSTRING(CFD_PERCAL, 3, 4) + SUBSTRING(CFD_PERCAL, 1, 2)
            ) AS PERCAL
        FROM
            %TABLE:CFD%
        WHERE
            %NOTDEL%
            AND CFD_FILIAL = %XFILIAL:CFD%
    ENDSQL

    If Empty(QRYMAX->PERCAL)
        cPerCal := StrZero(Month(dDataBase),2,0) + StrZero(Year(dDataBase),4,0)
        lAjusta := .F.
    Else
        cPerCal := Substr(QRYMAX->PERCAL,5,2) + Substr(QRYMAX->PERCAL,1,4)
    EndIf

    QRYMAX->(DbCloseArea())

    If cPerCal <> StrZero(Month(dDataBase),2,0) + StrZero(Year(dDataBase),4,0)
        lAjusta := .F.
        FWAlertWarning("Nenhuma Atualizacao de FCI encontrada para o periodo atual: "+CRLF+;
            "Periodo atual: "+Transform(StrZero(Month(dDataBase),2,0)+StrZero(Year(dDataBase),4,0),"@R 99/9999")+CRLF+CRLF+;
            "Periodo considerado: "+Transform(cPerCal,"@R 99/9999"),"Consulta FCI")
    EndIf

    BEGINSQL ALIAS "QRY"
        SELECT
            SC6.C6_NUM,
            SC6.C6_PRODUTO,
            SC6.C6_CLI,
            SC6.C6_LOJA,
            SA1.A1_NREDUZ,
            SC6.C6_CLASFIS,
            SC6.C6_FCICOD,
            COALESCE(CFD.CFD_COD, '') CFD_COD
        FROM
            %TABLE:SC6% SC6
        INNER JOIN %TABLE:SF4% SF4
        ON SF4.F4_FILIAL = %XFILIAL:SF4%
            AND SF4.F4_CODIGO = SC6.C6_TES
            AND SF4.F4_ESTOQUE = 'S'
            AND SF4.%NOTDEL%
        INNER JOIN %TABLE:SA1% SA1
        ON SA1.A1_FILIAL = %XFILIAL:SA1%
            AND SA1.A1_COD = SC6.C6_CLI
            AND SA1.A1_LOJA = SC6.C6_LOJA
            AND SA1.%NOTDEL%
        LEFT JOIN %TABLE:CFD% CFD
        ON CFD.CFD_FILIAL = SC6.C6_FILIAL
            AND CFD.CFD_FCICOD = SC6.C6_FCICOD
            AND CFD.CFD_COD = SC6.C6_PRODUTO
            AND CFD.CFD_PERCAL = %EXP:cPerCal%
            AND CFD.%NOTDEL%
        WHERE
            SC6.C6_FILIAL = %XFILIAL:SC6%
            AND SC6.C6_QTDENT < SC6.C6_QTDVEN
            AND SC6.C6_BLQ <> 'R'
            AND SC6.C6_FCICOD <> ''
            AND LEFT(SC6.C6_CLASFIS, 1) IN ('3', '8')
            AND SC6.%NOTDEL%
        GROUP BY
            SC6.C6_NUM,
            SC6.C6_PRODUTO,
            SC6.C6_CLI,
            SC6.C6_LOJA,
            SA1.A1_NREDUZ,
            SC6.C6_CLASFIS,
            SC6.C6_FCICOD,
            CFD.CFD_COD
        ORDER BY
            SC6.C6_NUM,
            SC6.C6_PRODUTO
    ENDSQL

    While !QRY->(EOF())
        BRPED309(QRY->C6_NUM,QRY->C6_PRODUTO,QRY->C6_CLI,QRY->C6_LOJA,QRY->A1_NREDUZ,;
            QRY->C6_CLASFIS,QRY->C6_FCICOD,QRY->CFD_COD)
        QRY->(DbSkip())
    EndDo

    QRY->(DbCloseArea())

Return (NIL)

/*/{Protheus.doc} BRPED304
Botao de limpeza dos pedidos com FCI retirado.
@type function Processamento
@version  1.00
@author marioantonaccio
@since 22/05/2026
@return character, sem retorno
/*/
Static Function BRPED304()

    If SuperGetMv("BR_LIMPFCI",.F.,.F.)
        FWAlertWarning("Funcionalidade em desenvolvimento.","Limpar FCI Retirados")
        Return (NIL)
    EndIf

    If lAjusta
        If FWAlertNoYes("Tem certeza que deseja limpar os registros de FCI retirados? Esta acao e irreversivel.","Limpar FCI Retirados")
            MsAguarde({|| BRPED305()}, "Aguarde...", "Limpando Registros...")
            FWAlertSuccess("Registros de FCI retirados limpos com sucesso.","Limpar FCI Retirados")
        EndIf
    EndIf

Return (NIL)

/*/{Protheus.doc} BRPED305
Atualiza a base de pedidos.
@type function Processamento
@version  1.00
@author marioantonaccio
@since 22/05/2026
@return character, sem retorno
/*/
Static Function BRPED305()

    Local nI as numeric

    For nI := 1 To Len(aFCI_RET)
        SC6->(DbSetOrder(1))
        If SC6->(DbSeek(xFilial("SC6")+aFCI_RET[nI][1]))
            While !SC6->(EOF()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == aFCI_RET[nI][1]
                If SC6->C6_PRODUTO == aFCI_RET[nI][2] .And. SC6->C6_FCICOD == aFCI_RET[nI][7]
                    SB1->(DbSetOrder(1))
                    SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))

                    RecLock("SC6",.F.)
                    SC6->C6_FCICOD  := " "
                    SC6->C6_CLASFIS := If(Empty(SB1->B1_ORIGEM),"0",SB1->B1_ORIGEM)+Substr(SC6->C6_CLASFIS,2,2)
                    MsUnLock()
                EndIf
                SC6->(DbSkip())
            EndDo
        EndIf
    Next nI

Return (NIL)

/*/{Protheus.doc} BRPED306
Botao de impressao dos grids.
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 22/05/2026
@return character, sem retorno
/*/
Static Function BRPED306()

    Local oReport as object

    oReport := TReport():New("BRPEDFC3","Pedidos Abertos com FCI","",{|oReport| BRPED307(oReport)},;
        "Imprime os pedidos abertos com vinculo SC6 x CFD.")
    oReport:lParamPage := .F.
    oReport:SetLandScape()
    oReport:nFontBody := 8
    oReport:lEdit := .F.
    oReport:PrintDialog()

Return (NIL)

/*/{Protheus.doc} BRPED307
Impressao da consulta.
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 22/05/2026
@param oReport, object, objeto do relatorio
@return character, sem retorno
/*/
Static Function BRPED307(oReport)

    oReport:EndReport(.F.)
    oReport:SetTitle("Pedidos Abertos com FCI - Referencia "+Transform(cPerCal,"@R 99/9999"))

    BRPED308(oReport,"Pedidos com FCI na CFD",aFCI_OK)
    BRPED308(oReport,"Pedidos com FCI Retirado",aFCI_RET)
    BRPED308(oReport,"Geral SC6 x CFD",aFCI_GER)

    oReport:Finish()

Return (NIL)

/*/{Protheus.doc} BRPED308
Imprime um bloco do relatorio.
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 22/05/2026
@param oReport, object, objeto do relatorio
@param cTitulo, character, titulo do bloco
@param aDados, array, dados impressos
@return character, sem retorno
/*/
Static Function BRPED308(oReport,cTitulo,aDados)

    Local cLinha as character
    Local nI     as numeric

    If oReport:Cancel()
        Return (NIL)
    EndIf

    oReport:SkipLine()
    oReport:PrintText(cTitulo+" - Total: "+cValToChar(Len(aDados)))
    oReport:PrintText("Pedido | Produto | Cliente | Loja | Nome | Class.Fis | FCI | CFD Cod | Status")

    For nI := 1 To Len(aDados)
        If oReport:Cancel()
            Exit
        EndIf

        cLinha := AllTrim(aDados[nI][1])+" | "+;
            AllTrim(aDados[nI][2])+" | "+;
            AllTrim(aDados[nI][3])+" | "+;
            AllTrim(aDados[nI][4])+" | "+;
            AllTrim(aDados[nI][5])+" | "+;
            AllTrim(aDados[nI][6])+" | "+;
            AllTrim(aDados[nI][7])+" | "+;
            AllTrim(aDados[nI][8])+" | "+;
            AllTrim(aDados[nI][9])

        oReport:PrintText(cLinha)
    Next nI

Return (NIL)

/*/{Protheus.doc} BRPED309
Adiciona registro nos arrays dos grids.
@type function Processamento
@version  1.00
@author marioantonaccio
@since 22/05/2026
@return character, sem retorno
/*/
Static Function BRPED309(cNum,cProduto,cCli,cLoja,cNome,cClasFis,cFciCod,cCfdCod)

    Local cStatus as character
    Local aLinha  as array

    cStatus := IIf(Empty(AllTrim(cCfdCod)),"RETIRADO","ATIVO")
    aLinha  := {cNum,cProduto,cCli,cLoja,cNome,cClasFis,cFciCod,cCfdCod,cStatus}

    AAdd(aFCI_GER,aLinha)

    If cStatus == "RETIRADO"
        AAdd(aFCI_RET,aLinha)
    Else
        AAdd(aFCI_OK,aLinha)
    EndIf

Return (NIL)
