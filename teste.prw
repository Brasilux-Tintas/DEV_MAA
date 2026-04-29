#include "protheus.ch"

/*/{Protheus.doc} PE01NFESEFAZ
Ponto de Entrada para NFESEFAZ
@type       Function
@version    1.00
@author     Mário
@since      14/01/2026
@return     array  -> Variáveis modificadas
/*/

User Function PE01NFESEFAZ()

    Local aProd      := PARAMIXB[01]
    Local cMensCli   := PARAMIXB[02]
    Local cMensFis   := PARAMIXB[03]
    Local aDest      := PARAMIXB[04]
    Local aNota      := PARAMIXB[05]
    Local aInfoItem  := PARAMIXB[06]
    Local aDupl      := PARAMIXB[07]
    Local aTransp    := PARAMIXB[08]
    Local aEntrega   := PARAMIXB[09]
    Local aRetirada  := PARAMIXB[10]
    Local aVeiculo   := PARAMIXB[11]
    Local aReboque   := PARAMIXB[12]
    Local aNfVincRur := PARAMIXB[13]
    Local aEspVol    := PARAMIXB[14]
    Local aNfVinc    := PARAMIXB[15]
    Local AdetPag    := PARAMIXB[16]
    Local aObsCont   := PARAMIXB[17]
    Local aProcRef   := PARAMIXB[18]
    Local aMed       := PARAMIXB[19]
    Local aLote      := PARAMIXB[20]
    Local aRetorno   := {}

    Local lFCI       := GetNewPar("MV_FCIDANF", .F.)
    Local aArea      := FWGetArea()
    Local cAux       := ""
    Local nI         := 0

    Local aPedCli    := {}
    Local cAuxMsg    := ""
    Local lTemB5     := .F.

    // -----------------------------------------------------------------------
    // Função Local para garantir inclusão única de mensagens
    // -----------------------------------------------------------------------
    Local Function AddMsg(cMsg)
        If !Empty(AllTrim(cMsg)) .And. !(cMsg $ cMensCli)
            cMensCli += AllTrim(cMsg) + "**"
        EndIf
    Return

    // -----------------------------------------------------------------------
    // Apenas empresas do grupo Brasilux (01)
    // -----------------------------------------------------------------------
    If Alltrim(FWGrpCompany()) == '01'

        If aNota[4] == "1" // Saída

            // -------------------------------------------------------------------
            // Informações do Cliente / Nota
            // -------------------------------------------------------------------
            SF2->(DbSetOrder(1))
            SF2->(DbSeek(xFilial("SF2") + aNota[2] + aNota[1]))

            SA1->(DbSetOrder(1))
            SA1->(DbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))

            // Mensagem do Tipo de Contribuinte
            AddMsg(U_TIPOCONS(SA1->A1_CLAS))

            // Mensagem complementar do cadastro do cliente
            If SA1->(FieldPos("A1_MENSNF")) > 0
                AddMsg(AllTrim(SA1->A1_MENSNF))
            EndIf

            // Número do pedido
            AddMsg("Nro PEDIDO: " + SF2->F2_PEDIDO)

            // -------------------------------------------------------------------
            // Pedidos de Cliente - Roda aInfoItem
            // -------------------------------------------------------------------
            For nI := 1 To Len(aInfoItem)
                SC6->(DbSetOrder(1))
                If SC6->(DbSeek(xFilial("SC6") + aInfoItem[nI][1] + aInfoItem[nI][2]))
                    If !Empty(SC6->C6_PEDCLI)
                        If Ascan(aPedCli, SC6->C6_PEDCLI) == 0
                            AAdd(aPedCli, SC6->C6_PEDCLI)
                        EndIf
                    EndIf
                EndIf
            Next

            If Len(aPedCli) > 0
                cAuxMsg := "Pedido(s) do Cliente: "

                For nI := 1 To Len(aPedCli)
                    cAuxMsg += aPedCli[nI] + IIf(nI < Len(aPedCli), "/", "")
                Next

                AddMsg(cAuxMsg)
            EndIf

            // -------------------------------------------------------------------
            // Regras tributárias conforme classificação do cliente
            // -------------------------------------------------------------------
            Do Case
            Case SA1->A1_CLAS == "V"
                If SF2->F2_ICMSRET > 0
                    AddMsg("ICMS RETIDO ANTECIPADAMENTE NOS TERMOS DO CONVENIO ICMS 52/17")
                EndIf

            Case SA1->A1_CLAS == "C"
                If SF2->F2_ICMSRET > 0
                    AddMsg("ICMS RETIDO CONVENIO 52/17 - OPERACOES INTERESTADUAIS - CONSUMO PROPRIO")
                EndIf

            Case SA1->A1_CLAS == "I"
                AddMsg("NAO APLICABILIDADE DE ST - ART. 243-I DO RICMS/91 - CONVENIO 52/17 - INDUSTRIALIZACAO")

            Case SA1->A1_CLAS == "D"
                AddMsg("OPER. SEM RETENCAO ICMS CONV. 52/17 REGIME ESPECIAL Nº 141/93 - SFEAM")

            Otherwise
                AddMsg("NAO APLICABILIDADE DE ST ART. 243-I RICMS/91 - INTEGRACAO OU CONSUMO PROPRIO")
            EndCase

            // -------------------------------------------------------------------
            // Redespacho
            // -------------------------------------------------------------------
            SC5->(DbSetOrder(1))
            If SC5->(DbSeek(xFilial("SC5") + SF2->F2_PEDIDO))

                If !Empty(SC5->C5_REDESP)
                    SA4->(DbSetOrder(1))
                    If SA4->(DbSeek(xFilial("SA4") + SC5->C5_REDESP))
                        AddMsg("Redespacho: " + AllTrim(SA4->A4_NOME) + ;
                               " End.: " + AllTrim(SA4->A4_END) + ;
                               " Tel.: " + AllTrim(SA4->A4_TEL) + ;
                               " Frete: " + IIf(SC5->C5_TPFRETE == "C", "CIF", "FOB"))
                    EndIf
                EndIf

                // Mensagens do pedido
                cAux := U_TIRAACENTO(AllTrim(MSMM(SC5->C5_OBSNFS)))
                AddMsg(cAux)

            EndIf

            // Declaração obrigatória de produtos perigosos
            AddMsg("Declaro que os produtos perigosos estao classificados, embalados e identificados conforme regulamentacao.")

            cMensCli := U_TIRAACENTO(cMensCli)

        EndIf

        // -----------------------------------------------------------------------
        // Loop de Produtos
        // -----------------------------------------------------------------------
        For nI := 1 To Len(aProd)

            SB1->(DbSetOrder(1))
            SB1->(DbSeek(xFilial("SB1") + aProd[nI][2]))

            // Verifica tabela SB5
            lTemB5 := .F.
            SB5->(DbSetOrder(1))
            If SB5->(MsSeek(xFilial("SB5") + aProd[nI][2]))
                lTemB5 := .T.
            EndIf

            // Ajuste de descrição do produto
            aProd[nI][4] := AllTrim(SB1->B1_DESC)
            aProd[nI][3] := AllTrim(SB1->B1_CODBAR)

            // FCI
            SD2->(DbSetOrder(3))
            SD2->(DbSeek(xFilial("SD2") + aNota[2] + aNota[1] + SF2->F2_CLIENTE + SF2->F2_LOJA + aProd[nI][2] + StrZero(aProd[nI][1], 4)))

            If SD2->(FieldPos("D2_FCICOD")) > 0 .And. !Empty(SD2->D2_FCICOD)
                If lFCI .And. !(SD2->D2_FCICOD $ aProd[nI][25])
                    aProd[nI][25] += " Resolucao Senado 13/12 - FCI " + AllTrim(SD2->D2_FCICOD)
                EndIf
            EndIf

            // TES
            SF4->(DbSetOrder(1))
            If SF4->(DbSeek(xFilial("SF4") + aProd[nI][27]))
                AddMsg(AllTrim(SF4->F4_MENSNF))

                If !Empty(SF4->F4_PISCOF) .And. SF4->F4_PISCOF < "4"
                    AddMsg("Exclusao ICMS da BC Pis/Cofins - Regime Especial")
                EndIf
            EndIf

        Next // Produtos

    EndIf // Grupo 01 Brasilux

    // ---------------------------------------------------------------------------
    // Retorno obrigatório seguindo a ordem do ponto de entrada
    // ---------------------------------------------------------------------------
    AAdd(aRetorno, aProd)
    AAdd(aRetorno, cMensCli)
    AAdd(aRetorno, cMensFis)
    AAdd(aRetorno, aDest)
    AAdd(aRetorno, aNota)
    AAdd(aRetorno, aInfoItem)
    AAdd(aRetorno, aDupl)
    AAdd(aRetorno, aTransp)
    AAdd(aRetorno, aEntrega)
    AAdd(aRetorno, aRetirada)
    AAdd(aRetorno, aVeiculo)
    AAdd(aRetorno, aReboque)
    AAdd(aRetorno, aNfVincRur)
    AAdd(aRetorno, aEspVol)
    AAdd(aRetorno, aNfVinc)
    AAdd(aRetorno, AdetPag)
    AAdd(aRetorno, aObsCont)
    AAdd(aRetorno, aProcRef)
    AAdd(aRetorno, aMed)
    AAdd(aRetorno, aLote)

    FWRestArea(aArea)

Return aRetorno
