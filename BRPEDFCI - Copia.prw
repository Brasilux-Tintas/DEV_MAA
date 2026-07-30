#Include "protheus.ch"

/*/{Protheus.doc} BRPEDFCI
Consulta e mostra pedidos em aberto com controle FCI
@type function Processamento
@version  1.00
@author marioantonaccio
@since 19/05/2026
@return character, sem retorno
/*/
User Function BRPEDFCI()

    Local aArea      := {}  as array
    Private aFCI_OK  := {}  as array
    Private aFCI_RET := {}  as array
    Private aLinha   := {}  as array
    Private cPerCal  := " " as character
    Private cStatus  := " " as character
    Private lAjusta  := .T. as logical

    aArea    := FWGetArea()

    MsAguarde({|| BRPEDFCI00()}, "Aguarde...", "Processando Registros...")

    If Empty(aFCI_OK) .and. Empty(aFCI_RET)
        FWAlertInfo("Nenhum pedido encontrado.","Consulta FCI")
    Else
        BRPEDFCI01(aFCI_OK,aFCI_RET)
    EndIf

    FWRestArea(aArea)

Return (NIL)

/*/{Protheus.doc} BRPEDFCI01
Tela de montagem dos pedicos com e sem FCI
@type function Tela
@version  1.00
@author marioantonaccio
@since 19/05/2026
@param aOK, array, Array dos dados com FCI ativo
@param aRET, array, Array dos dados com FCI retirado
@return logical, retorna .T. se a tela foi montada com sucesso
/*/
Static Function BRPEDFCI01(aOK,aRET)

    Local nNOK         as numeric
    Local nOk          as numeric
    Private oDlgFCI    as object // Dialog Principal
    Private oGetDados1 as object
    Private oGetDados2 as object

    nOk  := Len(aOK)
    nNOK := Len(aRET)

    DEFINE MSDIALOG oDlgFCI TITLE "Pedidos Abertos com FCI - Referencia "+Transform(cPercal,"@R 99/9999") FROM C(178),C(182) TO C(665),C(967) PIXEL

    // Cria as Groups do Sistema
    @ C(009),C(007) TO C(112),C(382) LABEL "Pedidos com FCI" PIXEL OF oDlgFCI
    @ C(115),C(010) Say "Total de Pedios com FCI" Size C(071),C(008) COLOR CLR_BLACK PIXEL OF oDlgFCI
    @ C(115),C(110) MsGet oGet1 Var cValToChar(nOk) Size C(060),C(009) COLOR CLR_BLACK Picture "@ER 999999" PIXEL OF oDlgFCI

    @ C(126),C(007) TO C(218),C(382) LABEL "Pedidos com FCI Retirados" PIXEL OF oDlgFCI
    @ C(222),C(010) Say "Total de Pedidos com FCI Retirado" Size C(084),C(008) COLOR CLR_BLACK PIXEL OF oDlgFCI
    @ C(222),C(110) MsGet oGet2 Var cValToChar(nNOK) Size C(060),C(009) COLOR CLR_BLACK Picture "@ER 999999" PIXEL OF oDlgFCI

    If lAjusta
        @ C(222),C(250) Button "Limpar FCI Retirados" Size C(050),C(012) PIXEL OF oDlgFCI ACTION  {|| BRPEDFCI04()}
    Endif
    @ C(222),C(333) Button "Fechar" Size C(050),C(012) PIXEL OF oDlgFCI ACTION oDlgFCI:End()

    oGet1:bWhen := {|| .F. }
    oGet2:bWhen := {|| .F. }

    BRPEDFCI02(@aOk,"1")
    BRPEDFCI02(@aRet,"2")

    ACTIVATE MSDIALOG oDlgFCI CENTERED

Return (.T.)

/*/{Protheus.doc} BRPEDFCI02
Montagem da visalização dos regitros de pedidos com e sem FCI
@type function Tela
@version 1.00
@author marioantonaccio
@since 18/05/2026
@param aDados, array, Array dos Dados a serem exibidos
@param cPos, character, indicativo de qual array de dados estamos tratando
@return character, sem retorno
/*/
Static Function BRPEDFCI02(aDados,cPos)
    Local aAlter    :={""}           as array // Array de campos que sofrerão alteração de valor durante a execução da MsNewGetDados. O formato deste array deve ser {<nome do campo 1>, <nome do campo 2>, ...}
    Local aCol      := {}            as array // Array a ser tratado internamente na MsNewGetDados como aCols
    Local aCpoGDa   := {}            as array
    Local aAux      := {}            as array
    Local aHead     := {}            as array // Array a ser tratado internamente na MsNewGetDados como aHeader
    Local cDelOk    := "AllwaysTrue" as character // Funcao executada para validar a exclusao de uma linha do aCols
    Local cFieldOk  := "AllwaysTrue" as character // Funcao executada na validacao do campo
    Local cIniCpos  := ""            as character // Nome dos campos do tipo caracter que utilizarao incremento automatico.
    Local cLinOk    := "AllwaysTrue" as character // Funcao executada para validar o contexto da linha atual do aCols
    Local cSuperDel := ""            as character // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
    Local cTudoOk   := "AllwaysTrue" as character // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
    Local nDireita  := C(374)        as numeric // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
    Local nEsquerda := C(012)        as numeric // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
    Local nFreeze   := 000           as numeric // Campos estaticos na GetDados.
    Local nI        := 0             as numeric
    Local nInferior := C(106)        as numeric // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
    Local nMax      := 999           as numeric // Numero maximo de linhas permitidas. Valor padrao 99
    Local nOpc      := 0             as numeric // Opcao de comportamento da MsNewGetDados. Valor padrao 0.
    Local nSuperior := C(022)        as mumeric // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
    Local nUsado    :=0              as numeric
    Local nX        := 0             as numeric
    Local oWnd      := oDlgFCI       as object
    Local oGetDados1 as object
    Local oGetDados2 as object

    // Variaveis deste Form
    aCpoGDa       :={"C6_NUM","C6_PRODUTO","C6_CLI","C6_LOJA","A1_NREDUZ","C6_CLASFIS","C6_FCICOD","C9_STATUS"}

    If cPos == "2"
        nSuperior    	:= C(136)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
        nEsquerda    	:= C(012)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
        nInferior    	:= C(217)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
        nDireita     	:= C(372)
    End

    // Carrega aHead
    aHead:=BRPEDFCI03(@aCpoGda)

    aAux := {}
    If Len(aDados)>0
        nUsado := Len(aHead)
        For nI:=1 To Len(aDados)
            aadd(aCOL,Array(nUsado+1))
            For nX	:= 1 To nUsado
                aCol[nI][nX] := aDados[nI][nX]
            Next
            aCOL[nI][nUsado+1] := .F.
        Next
    Else
        For nX := 1 to Len(aCpoGDa)
            If DbSeek(aCpoGDa[nX])
                Aadd(aAux,CriaVar(SX3->X3_CAMPO))
            Endif
        Next nX
    Endif

    If cPos == "1"
        oGetDados1:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
            aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)
    Else
        oGetDados2:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
            aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)
    End
Return (Nil)

/*/{Protheus.doc} BRPEDFCI03
Montagem do cabecalho dos itens
@type function tela
@version  1.00
@author marioantonaccio
@since 19/05/2026
@param aHDer, array, array com os campos que serão exibidos
@return array, array do cabecalho montado
/*/
Static Function BRPEDFCI03(aHDer)

    Local aHeadx := {} as array
    Local nX     := 0  as numeric

    // Carrega aHead
    DbSelectArea("SX3")
    SX3->(DbSetOrder(2)) // Campo
    For nX := 1 to Len(aHDer)
        If SX3->(DbSeek(aHDer[nX]))
            Aadd(aHeadx,{ AllTrim(X3Titulo()),;
                SX3->X3_CAMPO	,;
                SX3->X3_PICTURE,;
                SX3->X3_TAMANHO,;
                SX3->X3_DECIMAL,;
                SX3->X3_VALID	,;
                SX3->X3_USADO	,;
                SX3->X3_TIPO	,;
                SX3->X3_F3 		,;
                SX3->X3_CONTEXT,;
                SX3->X3_CBOX	,;
                SX3->X3_RELACAO})
        Endif
    Next nX
Return (aHeadx)

/*/{Protheus.doc} C
Ajuste de posionamento
@type function Tela
@version  1.00
@author marioantonaccio
@since 19/05/2026
@param nTam, numeric, posição na tela
@return numeric, posição ajustada
/*/
Static Function C(nTam)

    Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor

    If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
        nTam *= 0.8
    ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
        nTam *= 1
    Else	// Resolucao 1024x768 e acima
        nTam *= 1.28
    EndIf

    //³Tratamento para tema "Flat"³
    If "MP8" $ oApp:cVersion
        If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
            nTam *= 0.90
        EndIf
    EndIf
Return Int(nTam)

/*/{Protheus.doc} BRPEDFCI00
Motagem da query de pedidos em aberto
@type function Processamento
@version  1.00
@author marioantonaccio
@since 19/05/2026
@return character,. sem retorno
/*/
Static Function BRPEDFCI00()

    //Pesquisa qual foi a ultima interação de FCI para usar como parametro de busca dos pedidos
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
    cPercal:= Substr(QRYMAX->PERCAL, 5, 2) + Substr(QRYMAX->PERCAL, 1, 4)

    QRYMAX->(DbCloseArea())

    If cPercal <> StrZero(Month(dDataBase),2,0) + StrZero(Year(dDataBase),4,0)
        lAjusta:=.F.
        FWAlertWarning("Nenhuma Atualização de FCI encontrada para o período atual: " +CRLF+;
        "Período atual: " +;
            '<b>'+Transform(StrZero(Month(dDataBase),2,0)+StrZero(Year(dDataBase),4,0),"@R 99/9999")+'</b>'+CRLF +CRLF+;
            "A consulta trará os pedidos com base no último período encontrado: "+CRLF+;
            "Periodo Considerado: "+'<b>'+Transform(cPercal,"@R 99/9999")+'</b>',"Consulta FCI")
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
            AND CFD.CFD_COD = SC6.C6_PRODUTO
            AND CFD.CFD_FCICOD = SC6.C6_FCICOD
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
            SC6.C6_NUM
    ENDSQL

    While .NOT. QRY->(EOF())

        cStatus := IIf(Empty(AllTrim(QRY->CFD_COD)),"RETIRADO","ATIVO")

        aLinha := {;
            QRY->C6_NUM,;
            QRY->C6_PRODUTO,;
            QRY->C6_CLI,;
            QRY->C6_LOJA,;
            QRY->A1_NREDUZ,;
            QRY->C6_CLASFIS,;
            QRY->C6_FCICOD,;
            cStatus}

        If cStatus == "RETIRADO"
            AAdd(aFCI_RET,aLinha)
        Else
            AAdd(aFCI_OK,aLinha)
        EndIf

        QRY->(DbSkip())

    EndDo

    QRY->(DbCloseArea())

Return (NIL)

/*/{Protheus.doc} BRPEDFCI04
Rotina que limpa dos pedidos a FCI retirada e ajusta a Classificação Fiscal
@type function Processamento
@version  1.00
@author marioantonaccio
@since 19/05/2026
@return character, sem retorno
/*/
Static Function BRPEDFCI04()

    If SuperGetMv("BR_LIMPFCI",.F.,.F.)
        FWAlertWarning("Funcionalidade em desenvolvimento.","Limpar FCI Retirados")
        Return (NIL)
    End

    If lAjusta // Aqui deve ser implementada a validação para permitir ou não a limpeza dos FCI retirados
        If FWAlertNoYes("Tem certeza que deseja limpar os registros de FCI retirados? Esta ação é irreversível.","Limpar FCI Retirados")
            MsAguarde({|| BRPEDFCI05()}, "Aguarde...", "Limpando Registros...")
            FWAlertSuccess("Registros de FCI retirados limpos com sucesso.","Limpar FCI Retirados")
        EndIf

    EndIf

Return(NIL)

/*/{Protheus.doc} BRPEDFCI05
Atualiza a base de Pedidos
@type function Processamento
@version  1.00
@author marioantonaccio
@since 19/05/2026
@return character, sem retorno
/*/
Static Function BRPEDFCI05()
    Local nI:=0 as numeric

    For nI := 1 to Len(aFCI_RET)

        SC6->(DbSetOrder(1))
        If SC6->(DbSeek(xFilial("SC6")+aFCI_RET[nI][1]))

            While .NOT. SC6->(EOF()) .AND. SC6->C6_NUM == aFCI_RET[nI][1] .and. SC6->C6_FILIAL = xFilial("SC6")               //Pega Origem
                SB1->(DbSetOrder(1))
                SB1->(dbSeek(xFilial("SB1")+SC6->C6_PRODUTO))

                RecLock("SC6",.F.)
                SC6->C6_FCICOD := " "
                SC6->C6_CLASFIS:=If(Empty(SB1->B1_ORIGEM),"0",SB1->B1_ORIGEM)+Substr(SC6->C6_CLASFIS,2,2)
                MsUnLock()

                SC6->(DbSkip())

            EndDo

        EndIf
    Next nI

Return(NIL)
