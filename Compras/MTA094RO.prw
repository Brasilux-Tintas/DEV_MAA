#Include 'Protheus.ch'
#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

/*/{Protheus.doc} MTA094RO
Ponto de entrada em Outras Ações no browse de liberação de Documentos
@type function Ponto de Entrada
@version  1.0
@author marioantonaccio
@since 21/10/2025
@return array, rotinas que deverão ser mostradas em OUTRAS AÇÕES
/*/
User Function MTA094RO()

    Local aRotina:= PARAMIXB[1]

    Aadd(aRotina,{'Mostrar Cotacao',"U_BRMCOTAC('B')", 0, 4,0,NIL})

Return (aRotina)

/*/{Protheus.doc} MATA094
Ponto de entrada na liberação do Documento (MVC) - por isso demosntrado todas as etapas
Permite a visualização da cotação que deu origem ao pedido
@type function Ponto de entrada
@version  1.0
@author marioantonaccio
@since 21/10/2025
@return logical, prossegue ou não na rotina
/*/
User Function MATA094()
    Local aParam := PARAMIXB
    Local xRet := .T.
    Local oObj := ""
    Local cIdPonto := ""
    Local cIdModel := ""
    Local lIsGrid := .F.
    //Local nLinha := 0
    // Local nQtdLinhas := 0
    // Local cMsg := ""
    //  Local nOp

    If (aParam <> NIL)
        oObj := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid := (Len(aParam) > 3)

        nOpc := oObj:GetOperation() // PEGA A OPERAÇÃO

        If (cIdPonto == "MODELPOS")
            /*
            cMsg := "Chamada na validação total do modelo." + CRLF
            cMsg += "ID " + cIdModel + CRLF
            IF nOp == 3
                Alert('inclusão')
            ENDIF

            xRet := MsgYesNo(cMsg + "Continua?")
            */
        ElseIf (cIdPonto == "MODELVLDACTIVE")
            /*
            cMsg := "Chamada na ativação do modelo de dados."

            xRet := MsgYesNo(cMsg + "Continua?")
            */
        ElseIf (cIdPonto == "FORMPOS")
            /*
            cMsg := "Chamada na validação total do formulário." + CRLF
            cMsg += "ID " + cIdModel + CRLF

            If (lIsGrid == .T.)
                cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
                cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
            Else
                cMsg += "É um FORMFIELD" + CRLF
            EndIf

            xRet := MsgYesNo(cMsg + "Continua?")
            */
        ElseIf (cIdPonto =="FORMLINEPRE")
            /*
            If aParam[5] =="DELETE"
                cMsg := "Chamada na pré validação da linha do formulário." + CRLF
                cMsg += "Onde esta se tentando deletar a linha" + CRLF
                cMsg += "ID " + cIdModel + CRLF
                cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
                cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF

                xRet := MsgYesNo(cMsg + " Continua?")
            EndIf
            */
        ElseIf (cIdPonto =="FORMLINEPOS")
            /*
            cMsg := "Chamada na validação da linha do formulário." + CRLF
            cMsg += "ID " + cIdModel + CRLF
            cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
            cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF

            xRet := MsgYesNo(cMsg + " Continua?")
            */
        ElseIf (cIdPonto =="MODELCOMMITTTS")
            // MsgInfo("Chamada após a gravação total do modelo e dentro da transação do MVC.")
        ElseIf (cIdPonto =="MODELCOMMITNTTS")
            //  MsgInfo("Chamada após a gravação total do modelo e fora da transação do MVC.")
        ElseIf (cIdPonto =="FORMCOMMITTTSPRE")
            //   MsgInfo("Chamada após a gravação da tabela do formulário.")
        ElseIf (cIdPonto =="FORMCOMMITTTSPOS")
            // MsgInfo("Chamada após a gravação da tabela do formulário.")
        ElseIf (cIdPonto =="MODELCANCEL")
            //  cMsg := "Deseja realmente sair?"
            //  xRet := MsgYesNo(cMsg)
        ElseIf (cIdPonto =="BUTTONBAR")
            If SCR->CR_TIPO == "PC"
                xRet := {{"Mostrar Cotação", "Mostra Cotacao", {|| U_BRMCOTAC('R')}}}
            End
        EndIf
    EndIf
Return (xRet)

/*/{Protheus.doc} BRMCOTAC
Mostra o Mapa de da Cotacao realizada
@type function Tela
@version  1.0
@author marioantonaccio
@since 21/10/2025
@param cOpcao, character, indica a origem da chamada: B=Browse / R=Registro
@return character, sem retorno
/*/
User Function BRMCOTAC(cOpcao)
    If SCR->CR_TIPO $ "PC/IP"  //Pedido de compra
        SC7->(dbSetOrder(1))
        If SC7->(dbSeek(xFilial("SC7")+AllTrim(SCR->CR_NUM)))
            If Empty(SC7->C7_NUMCOT)
                FWAlertWarning("Pedido sem Cotação!", "Sem Cotação "+If(cOpcao == "B","(MTA094RO)","(MATA094)"))
            Else

                SC8->(dbSetOrder(1))
                SC8->(dbSeek(xFilial("SC8")+SC7->C7_NUMCOT))
                If .NOT. GetMv("MV_PGCWF")
                    A161MAPCOT()
                Else
                    PGCA020()
                End

            End
        Else
            FWAlertError("Pedido nao Encontrado...Verifique!!!!", "Não Encontrado (MATA094)")
        End
    Else
        FWAlertInfo("Por se tratar de um Contrato de Parceria, o mesmo nao tem cotação", "Contrato de Parceria (MATA094)")
    End

Return Nil

User Function PGCA020()
    Local aParam := PARAMIXB
    oObj := aParam[1]
    cIdPonto := aParam[2]
    cIdModel := aParam[3]
Return(.T.)

/*
Local aParam := PARAMIXB
continua…
oObj := aParam[1]
cIdPonto := aParam[2]
cIdModel := aParam[3]
continua…
If ( cIdPonto == ‘FORMPOS’ )
IF cIdModel == “SC8DETAIL”
continua…
For nCntItm := 1 To oObj:Length()
oObj:GoLine(nCntItm)
nTotCot += oObj:GetValue(“C8_TOTAL”)
Next nCntItm
Endif
EndIf
Return lRetPE
*/
