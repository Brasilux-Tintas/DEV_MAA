#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT120BRW
Adiciona botões à rotina de Browse de Pedido
@type function Ponto de Entrada
@version   1.0
@author marioantonaccio
@since 22/10/2025
@return array, array com as rotinas que deverão aparecer no browse
/*/
User Function MT120BRW()
    // Permitido alteração  (4 no final)
    AAdd( aRotina, { 'Alterar Fornecedor', 'U_BRAFORPC()', 0, 4 } )
Return (aRotina )


/*/{Protheus.doc} BRAFORPC
Permite ou não a alterção do fornecedor depois do pedido liberado
Se caso pedido veio de Cotação, informar nas observações da COTACAO que houve a mudança
do fornecedor para outro do mesmo grupo economico
Somente para pedidods liberados(?)
@type function Processamento
@version 1.0
@author marioantonaccio
@since 22/10/2025
@return character, sem retorno
/*/
User Function BRAFORPC()
    Local aArea:=FWGetArea()
    Local nCont

    //Verifica se todos os itens estão Liberados (aprovados)
    BEGINSQL ALIAS "XSC7"
        SELECT
            COUNT(*) AS CONTADOR
        FROM
            %Table:SC7%
        WHERE
            %NotDel%
            AND C7_CONAPRO <> 'L'
            AND C7_NUM = %EXP:SC7->C7_NUM%
    ENDSQL
    nCont:=XSC7->CONTADOR
    XSC7->(dbCloseArea())

    If nCont > 0
        FWAlertWarning("Pedido Bloqueado não deve ser alterado o Fornecedor"+CRLF+CRLF+"Libere o pedido antes!","Atenção")
    End

    //Verifica se tem algum item eliminado por residuo
    nCont:=0
    BEGINSQL ALIAS "XSC7"
        SELECT
            COUNT(*) AS CONTADOR
        FROM
            %Table:SC7%
        WHERE
            %NotDel%
            AND C7_RESIDUO = 'S'
            AND C7_NUM = %EXP:SC7->C7_NUM%
    ENDSQL
    nCont:=XSC7->CONTADOR
    XSC7->(dbCloseArea())

    If nCont > 0
        FWAlertError("Fornecedor em Pedido Eliminado por Residuo não pode ser alterado !!","Nao Permitido","Nao Permitido (BRAFORPC)")
        Return
    End

    //Varifica se ja foi entregue parcial ou Totalmente
    nCont:=0
    BEGINSQL ALIAS "XSC7"
        SELECT
            COUNT(*) AS CONTADOR
        FROM
            %Table:SC7%
        WHERE
            %NotDel%
            AND C7_QUJE > 0
            AND C7_NUM = %EXP:SC7->C7_NUM%
    ENDSQL
    nCont:=XSC7->CONTADOR
    XSC7->(dbCloseArea())

    If nCont > 0
        FWAlertError("Pedido com entrega parcial ou total não pode ser alterado !!","Nao Permitido (BRAFORPC)")
        Return
    End

    //Verifica se fornecedor pertence a algum grupo economico para troca
    SA2->(dbSetOrder(1))
    SA2->(dbSeek(XFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))
    If Empty(SA2->A2_XGRPECO)
        FWAlertError("Esse Fornecedor: "+SC7->C7_FORNECE+"/"+SC7->C7_LOJA+"-"+AllTrim(Substr(SA2->A2_NOME,1,30))+;
            CRLF+CRLF+"<b><u>"+"NAO"+"</u>"+" pertence a nenhum Grupo Economico "+"</b>"+;
            CRLF+CRLF+"Por esse motivo nao será permitida a alteração", "Sem Grupo Economico (BRAFORPC)")
        Return
    End

    If FWAlertYesNo("Deseja alterar o Fornecedor do Pedido? ", "Alteração de Fornecedor")
        FmontaFOr()
    End

    FWRestArea(aArea)
Return NIL

/*/{Protheus.doc} fMontaFor
Monta Tela de Fornecedores ertecentes ao mesmo Grupo Economico
@type function Tela
@version 1.00
@author marioantonaccio
@since 24/10/2025
@return Character, sem retorno
/*/
Static Function fMontaFor()

    Local nOpca
    Local nJanAltu   := 200
    Local nJanLarg   := 800
    Local lDimPixels := .T.
    Local lCentraliz := .T.
    Local bBlocoOk   := {|| nOpca:=1, oDlg:End()}
    Local bBlocoCan  := {|| nOpca:=0, oDlg:End()}
    Local aOutrasAc  := {} //{ {"BMP", {|| Alert("Cliquei no 1")}, "Botão 1"}, {"BMP", {|| Alert("Cliquei no 2")}, "Botão 2"} }
    Local bBlocoIni  := {|| EnchoiceBar(oDlg, bBlocoOk, bBlocoCan, , aOutrasAc)}
    Local cJanTitulo := "Fornecedores do Mesmo Grupo Economico"
    Private oDlg
    Private nRadio
    Private aItems:={}

    BEGINSQL ALIAS "XSA2"
        SELECT
            A2_COD,
            A2_LOJA,
            A2_NOME
        FROM
            %Table:SA2%
        WHERE
            %NotDel%
            AND A2_XGRPECO = %EXP:SA2->A2_XGRPECO%
        ORDER BY
            A2_NOME
    ENDSQL

    While XSA2->(.NOT. EOF())

        // AADD(aItems,XSA2->A2_COD+"/"+XSA2->A2_LOJA+ "-" + AllTrim(XSA2->A2_NOME)+If(XSA2->A2_COD+XSA2->A2_LOJA == SC7->C7_FORNECE+SC7->C7_LOJA," (*)",""))
        If XSA2->A2_COD+XSA2->A2_LOJA == SC7->C7_FORNECE+SC7->C7_LOJA
            XSA2->(dbSkip())
            Loop
           // AADD(aItems,"<b>"+XSA2->A2_COD+"/"+XSA2->A2_LOJA+ "-" + AllTrim(XSA2->A2_NOME)+"</b>")
        Else
            AADD(aItems,XSA2->A2_COD+"/"+XSA2->A2_LOJA+ "-" + AllTrim(XSA2->A2_NOME)+If(XSA2->A2_COD+XSA2->A2_LOJA == SC7->C7_FORNECE+SC7->C7_LOJA," (*)",""))
        End
        XSA2->(dbSkip())

    End
    XSA2->(dbCloseArea())

    If Len(aItems) > 0
        //Cria a dialog
        oDlg := TDialog():New(0, 0, nJanAltu, nJanLarg, cJanTitulo, , , , , , /*nCorFundo*/, , , lDimPixels)
        nRadio := 0
        oRadio := TRadMenu():New (030,020,aItems,,oDlg,,,,,,,,200,12,,,,.T.)
        oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
        //Ativa e exibe a janela
        oDlg:Activate(, , , lCentraliz, , , bBlocoIni)

        If nOpca == 0
            Return
        EndIf

        If nRadio == 0
            FWAlertError("Não foi selecionado Fornecedor para mudança","Sem seleção")
            Return
        End

        MsAguarde({|| AltForne() },"Aguarde","Em processamento a alteração do fornecedor...")
    Else
        FWAlertError("Não foram encontrados Fornecedores para essa mudança","Sem Fornecedores")
    End
Return Nil

/*/{Protheus.doc} AltForne
Processa a alteração de Fornecedor e gravacao de audiotria em Cotacao (se houver)
@type function Processamento
@version  1.00
@author marioantonaccio
@since 24/10/2025
@return character, sem retorno
/*/
Static Function AltForne()

    Local cFornece :=Substr(aItems[nRadio],1,TamSX3("A2_COD")[1])
    Local cLoja := Substr(aItems[nRadio],TamSX3("A2_COD")[1]+2,TamSX3("A2_LOJA")[1])
    Local lCotac:=.F.
    Local cObsCot:=" "
    Local cFornAtu:=SC7->C7_FORNECE
    Local cLojaAtu:=SC7->C7_LOJA

    cObsCot:="O Fornecedor desse pedido "+SC7->C7_NUM +CRLF+;
        SC7->C7_FORNECE+"/"+SC7->C7_LOJA+"-"+AllTrim(Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME"))+CRLF+;
        "foi alterado para o fornecedor "+CRLF+;
        cFornece+"/"+cLoja+"-"+AllTrim(Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_NOME"))+CRLF+;
        "que fará o atendimento visto que faz parte do mesmo Grupo Economico"

    BEGINSQL ALIAS "XSC7"
        SELECT
            R_E_C_N_O_ AS REG
        FROM
            %Table:SC7%
        WHERE
            %NotDel%
            AND C7_NUM = %EXP:SC7->C7_NUM%
    ENDSQL

    While XSC7->( .NOT. EOF())

        SC7->(dbGoTo(XSC7->REG))
        If cFornece+cLoja ==  SC7->C7_FORNECE+SC7->C7_LOJA
            XSC7->(dbSkip())
            Loop
        End

        RecLock("SC7",.F.)
        SC7->C7_FORNECE:=cFornece
        SC7->C7_LOJA:=cLoja
        MsUnLock()

        If .NOT. Empty(SC7->C7_NUMCOT)
            lCotac:=.T.
            BEGINSQL ALIAS "XSC8"
                SELECT
                    R_E_C_N_O_ AS REGSC8
                FROM
                    %Table:SC8%
                WHERE
                    %NotDel%
                    AND C8_NUM = %EXP:SC7->C7_NUMCOT%
                    AND C8_NUMPED = %EXP:SC7->C7_NUM%
            ENDSQL
            SC8->(dbGoTo(XSC8->REGSC8))
            //Se voltou o fornecedor da cotação, apago a mensgagem
            If .NOT. SC8->C8_FORNECE + SC8->C8_LOJA == cFornAtu+cLojaAtu
                cObsCot:=""
            End
            RecLock("SC8",.F.)
            SC8->C8_OBSFOR:=cObsCot
            MsUnLock()

            XSC8->(dbCloseArea())
        End

        XSC7->(dbSkip())

    End

    XSC7->(dbCloseArera())
    cObs:="Processo Concluido com Sucesso - Pedido alterado"
    If lCotac
        cObs+= CRLF+CRLF+"Alterada tambem a Cotacao"
    End
    FWAlertSuccess(cObs, "Processo Concluido")

Return
