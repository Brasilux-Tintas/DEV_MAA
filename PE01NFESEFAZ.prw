#include "protheus.ch"
/*/{Protheus.doc} PE01NFESEFAZ
Ponto de Entrada para NFESEFAZ
@type function Ponto de Entrada
@version  1.00
@author marioantonaccio
@since 14/01/2026
@return array, variaveis alteradas
@see
//O retorno deve ser exatamente nesta ordem e passando o conteúdo completo dos arrays
//pois no rdmake nfesefaz é atribuido o retorno completo para as respectivas variáveis
//Ordem:
//      aRetorno[1] -> aProd
//      aRetorno[2] -> cMensCli
//      aRetorno[3] -> cMensFis
//      aRetorno[4] -> aDest
//      aRetorno[5] -> aNota
//      aRetorno[6] -> aInfoItem
//      aRetorno[7] -> aDupl
//      aRetorno[8] -> aTransp
//      aRetorno[9] -> aEntrega
//      aRetorno[10] -> aRetirada
//      aRetorno[11] -> aVeiculo
//      aRetorno[12] -> aReboque
//      aRetorno[13] -> aNfVincRur
//      aRetorno[14] -> aEspVol
//      aRetorno[15] -> aNfVinc
//      aRetorno[16] -> AdetPag
//      aRetorno[17] -> aObsCont
//      aRetorno[18] -> aProcRef
//      aRetorno[19] -> aMed
//      aRetorno[20] -> aLote
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

    Local lFCI      := GetNewPar("MV_FCIDANF",.F.)
    Local _cIeSubst := ""
    Local aArea     := FwGetArea()
    Local cAux
    Local nI
    Local _cNomeProd
    Local _cCodBar
    Local _cOnu
    Local _cNembar
    Local _cClasRis
    Local _cGrpemb
    Local _cRisco
    Local lSYD      := .F.
    Local lTemB5    := .F.
    Local cItem:=" "
    Local aPedcli:={} // Pegar Pedido de Cliente
    Local cAuxMsg:=""
    /*
Local cMsg          := ""

cMsg := 'Produto: '+aProd[1][4] + CRLF
cMsg += 'Mensagem da nota: '+cMensCli + CRLF
cMsg += 'Mensagem padrao: '+cMensFis + CRLF
cMsg += 'Destinatario: '+aDest[2] + CRLF
cMsg += 'Numero da nota: '+aNota[2] + CRLF
cMsg += 'Pedido: ' +aInfoItem[1][1]+ 'Item PV: ' +aInfoItem[1][2]+ 'Codigo do Tes: ' +aInfoItem[1][3]+ 'Quantidade de itens no pedido: ' +aInfoItem[1][4] + CRLF
cMsg += 'Existe Duplicata ' + If( len(aDupl) > 0, "SIM", "NAO" )  + CRLF
cMsg += 'Existe Transporte ' + If( len(aTransp) > 0, "SIM", "NAO" ) + CRLF
cMsg += 'Existe Entrega ' + If( len(aEntrega) > 0, "SIM", "NAO" ) + CRLF
cMsg += 'Existe Retirada ' + If( len(aRetirada) > 0, "SIM", "NAO" ) + CRLF
cMsg += 'Existe Veiculo ' + If( len(aVeiculo) > 0, "SIM", "NAO" ) + CRLF
cMsg += 'Placa Reboque: ' + IIf(len(aReboque)> 0,aReboque[1],"NAO")+ 'Estado Reboque:' + IIf(len(aReboque) > 1, aReboque[2],"NAO")+ 'RNTC:' + IIf(len(aReboque) >2,aReboque[3],"NAO") + CRLF
cMsg += 'Nota Produtor Rural Referenciada: ' + If( len(aVeiculo) > 0, "SIM", "SEM NOTA REF." ) + CRLF
cMsg += 'Especie Volume: ' + If( len(aEspVol) > 0, "SIM", "NAO" ) + CRLF
cMsg += 'NF Vinculada: ' + If( len(aNfVinc) > 0, "SIM", "NAO" ) + CRLF

Alert(cMsg)
    */
    If Alltrim(FWGrpCompany()) == '01' //Empresas do grupo BRASILUX

        cInfAdic := ""

        If aNota[4] == "1" // Saida

            //Nota
            // Verifica Mensagens de ST
            SF2->(dbSetOrder(1))
            SF2->(dbSeek(xFilial("SF2")+aNota[2]+aNota[1]))

            //Cliente
            SA1->(dbSetOrder(1))
            SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
            cMensCli += u_Tipocons(SA1->A1_CLAS)+"**"
            IF (SA1->(FieldPos("A1_MENSNF")) > 0)
                cAux := Alltrim(SA1->A1_MENSNF)
                IF .NOT. Empty(cAux) .and. .NOT. (cAux $ cMensCli)
                    cMensCli += Alltrim(SA1->A1_MENSNF)+"**"
                End
            End

            cMensCli += " Nro PEDIDO: "+SF2->F2_PEDIDO+"**"
           
            //Roda aInfoItem - MAA Chamado R11813 - Pedido de cliente
            For nI:=1 To Len(aInfoItem)
                SC6->(dbSetOrder(1))
                If SC6->(dbSeek(xFilial("SC6")+aInfoItem[nI][1]+aInfoItem[nI][2]))
                    If .NOT. Empty(SC6->C6_PEDCLI)
                        If ASCAN(aPedCli,SC6->C6_PEDCLI) == 0
                            AADD(aPedCli,SC6->C6_PEDCLI)
                        End
                    End
                End
            Next
            If Len(aPedCli) > 0
                cAuxMsg:=" Pedido"+If(Len(aPedCli) > 1,"(s) "," ")+"do Cliente: "
                For nI:=1 To Len(aPedcli)
                    cAuxMsg+=AllTrim(aPedCli[nI])
                    If nI < Len(aPedCli)
                        cAuxMsg+="/"
                    End
                Next
                cAuxMsg+=" **"
                cMensCli+=" "+cAuxMsg +" "
            End
            //Fim Pedido Cliente

            If (SA1->A1_CLAS == "V") // .or. (SF2->F2_EST == "MS")
                If SF2->F2_ICMSRET > 0
                    If Empty(_cIeSubst)
                        cMensCli += "ICMS RETIDO ANTECIPADAMENTE NOS TERMOS DO CONVE"
                        cMensCli += "NIO ICMS 52/17**"
                    Else
                        cMensCli += "IMPOSTO RETIDO ANTECIPADAMENTE NOS TERMOS DO AR"
                        cMensCli += "TIGO 312 DO RICMS/2000**"
                    Endif
                Endif
            Elseif SA1->A1_CLAS = "C"
                If SF2->F2_ICMSRET > 0
                    cMensCli += "ICMS RETIDO ANTECIPADAMENTE NOS TERMOS DO CONVE"
                    cMensCli += "NIO ICMS 52/17 OPERACOES INTERESTADUAIS - PARA "
                    cMensCli += "CONSUMO PROPRIO**"
                Endif
            Elseif SA1->A1_CLAS = "I"
                cMensCli += "NAO APLICABILIDAD DA SUBST. TRIBUT. CONFORME AR-"
                cMensCli += "TIGO 243-I DO RICMS/91 CONVENIO ICMS 52/17 - INTE"
                cMensCli += "GRACAO OU CONSUMO EM PROCESSO DE INDUSTRIALIZACAO**"
            Elseif SA1->A1_CLAS = "D"
                cMensCli += "OPER. S/ RETENCAO ICMS PREV CONV. 52/17 P/ FORCA"
                cMensCli += " REG. ESP. No. 141/93 - SFEAM."
                cMensCli += " OBS.: CLIENTE COM REGIME ESPECIAL.**"
            Elseif Empty(SA1->A1_CLAS)
                cMensCli += "NAO APLICABILIDADE DA SUBST. TRIBUT. CONFORME AR-"
                cMensCli += "TIGO 243-I DO RICMS/91 CONVENIO ICMS 52/17 - INTE-"
                cMensCli += "GRACAO OU CONSUMO PROPRIO**"
            Endif

            SC5->(dbSetOrder(1))
            If SC5->(dbseek(xFilial("SC5")+SF2->F2_PEDIDO))
                If .NOT. Empty(SC5->C5_REDESP)
                    SA4->(dbSetOrder(1))
                    If SA4->(DbSeek(xFilial("SA4")+SC5->C5_REDESP))
                        cMensCli += "Redespacho: "+alltrim(SA4->A4_NOME)+;
                            "*End.:" +Alltrim(SA4->A4_END)+;
                            "*Tel.: "+ alltrim(SA4->A4_TEL)+;
                            "*Frete: "+Iif(SC5->C5_TPFRETE == "C", "CIF", "FOB")+"**"
                    End
                End
                cMensCli += If(SC5->C5_TIPO $ "D_B",;
                    "",;
                    Iif(Empty(SA1->A1_ENDENT),;
                    "",;
                    "Local Entrega: "+AllTrim(SA1->A1_ENDENT)+;
                    "End Entr.: "+AllTrim(SA1->A1_BAIRROE)+" - "+SA1->A1_CEPE+" - "+SA1->A1_ESTE+"**"))

                cAux = Alltrim(MSMM(SC5->C5_OBSNFS))
                cAux = U_TIRAACENTO(cAux)
                If !Empty(cAux) .and. .NOT. (cAux $ cMensCli)
                    cMensCli += cAux+" **"            // Mensagem para a Nota Fiscal
                Endif
                IF  SC5->C5_FILIAL == '010101' .OR. SC5->C5_FILIAL == '010104' //Empresas que não são do grupo 11(Tecpolpa). // jOSE 11/11/2024 Arescentado .AND. (SC5->C5_FILIAL = '010101' .OR. SC5->C5_FILIAL = '010104')
                    IF SC5->C5_DEPOSI == 'S'
                        cAux := "As mercadorias serao retiradas do deposito fechado, localizado na R. ANTONIO RODRIGUES FILHO, 501-GUARULHOS/SP, inscr estadual n. 336941590110, CNPJ n. 72770878000540 **"
                        If .NOT. (cAux $ cMensCli)
                            cMensCli += cAux
                        End
                    Else
                        If SC5->C5_DEPOSI == 'A'    // jose 08/11/2024
                            cAux := "As mercadorias serao retiradas do deposito fechado, localizado na AV MANOEL NIETO LOPEZ, 1888-ARARAQUARA/SP, inscr estadual n. 181629304113, CNPJ n. 72770878000702 **" // jose 08/11/2024
                            If .NOT. (cAux $ cMensCli) // jose 08/11/2024
                                cMensCli += cAux // jose 08/11/2024
                            End // jose 08/11/2024
                        Endif
                    Endif

                    If (.NOT. SF2->F2_TIPO $ "DB") .AND. (SF2->F2_VALFAT > 0)
                        cAux := Iif(SC5->C5_BOLETO == 'S', "ACOMPANHA BOLETO  ** ", "")
                        If .NOT. (cAux $ cMensCli)
                            cMensCli += cAux
                        End
                    End

                Endif
                cMensCli +=" Declaro que os produtos perigosos estão adequadamente classificados, embalados, "+;
                    "identificados, e estivados para suportar os riscos das operações de transporte e que atendem às "+;
                    "exigências da regulamentação"

                cMensCli:=U_TIRAACENTO(cMenscli)

                If SF2->F2_TIPO $ "DB"
                    SA2->(dbSetOrder(1))
                    SA2->(dbSeek(xFilial("SA2")+aNota[7]+aNota[8]))
                    //vALIDA ie
                    aadd(aDest,VldIE(SA2->A2_INSCR,.NOT.(SA2->A2_CLAS == "N")))
                End

            Endif
         
        Endif

        //Roda PRODUTO
        For nI:=1 To Len(aProd)
            If Alltrim(FWGrpCompany()) == '01'

                SB1->(dbSetOrder(1))
                SB1->(dbSeek(xFilial("SB1")+aProd[nI][2]))

                SB5->(dbSetOrder(1))
                If SB5->(MsSeek(xFilial("SB5")+aProd[nI][2]))
                    lTemB5:=.T.
                End
                DY3->(dbSetOrder(1))

                _cNomeProd := If(Len(Alltrim(SB1->B1_COD)) != 12,;
                    If(Empty(Alltrim(SB1->B1_DESCLIN)), "", Alltrim(SB1->B1_DESCLIN)+" - "),;
                    If(Empty(Alltrim(SB1->B1_DESCLIN)),;
                    Alltrim(Posicione("SZ1", 1, xFilial("SZ1")+SubStr(SB1->B1_COD,4,2), "Z1_DESCR")),;
                    Alltrim(SB1->B1_DESCLIN) )+" - ")+Alltrim(SB1->B1_DESC)+;
                    If(Len(Alltrim(SB1->B1_COD)) == 12," "+Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(SB1->B1_COD,11,2), "Z5_DESCR")),"")

                _cCodBar := AllTrim(SB1->B1_CODBAR)
                If Len(_cCodBar) == 12
                    _cCodBar += U_DigEan13(_cCodBar)
                End
                aProd[nI][4]:=_cNomeProd
                aProd[nI][3]:=_cCodBar

                //Posiciona Item da  Nota- FCI
                cItem:=StrZero(aProd[nI][1],TamSx3("D2_ITEM")[1],0)
                SD2->(dbSetOrder(3))
                SD2->(dbSeek(xFilial("SD2")+aNota[2]+aNota[1]+SF2->F2_CLIENTE+SF2->F2_LOJA+aProd[nI][2]+cItem ))

                If SD2->(FieldPos("D2_FCICOD")) > 0 .And. .NOT. Empty(SD2->D2_FCICOD)
                    If lFCI .and. .NOT. Alltrim(SD2->D2_FCICOD) $ aProd[nI][25]
                        aProd[nI][25]+= " Resolucao do Senado Federal nº 13/12, Numero da FCI " + Alltrim(SD2->D2_FCICOD) + "."
                    End
                End
                SYD->(dbSetOrder(1))  //YD_FILIAL+YD_TEC+YD_EX_NCM+YD_EX_NBM
                lSYD:=SYD->(dbSeek(xFilial("SYD")+SB1->B1_POSIPI+SB1->B1_EX_NCM+SB1->B1_EX_NBM))
                _cOnu     := if(lTemB5 .and. .NOT. Empty(SB5->B5_XONU),SB5->B5_XONU,If(lSYD,SYD->YD_XONU,""))
                _cNembar  := if(lTemB5 .and. .NOT. Empty(SB5->B5_XNEMBAR),SB5->B5_XNEMBAR,If(lSYD,SYD->YD_XNEMBAR,""))
                _cClasRis := if(lTemB5 .and. .NOT. Empty(SB5->B5_XCLASRI),SB5->B5_XCLASRI,If(lSYD,SYD->YD_XCLASRI,""))
                _cGrpemb  := if(lTemB5 .and. .NOT. Empty(SB5->B5_GRPEMB),SB5->B5_GRPEMB,If(lSYD,SYD->YD_GRPEMB,""))
                _cRisco   := if(lTemB5 .and. .NOT. Empty(SB5->B5_XRISCO),SB5->B5_XRISCO,If(lSYD,SYD->YD_XRISCO,""))
                If .NOT. Empty(_cOnu)
                    aProd[nI][25] += If(.NOT. Empty(aProd[nI][25]),"**","")+" UN "+_cOnu
                    If .NOT. Empty(_cNembar)
                        aProd[nI][25] += " " +ALLTRIM(_cNembar)
                    End
                    If .NOT. Empty(_cClasRis)
                        aProd[nI][25] += " " +ALLTRIM(_cClasRis)
                    End
                    If .NOT. Empty(_cGrpemb)
                        aProd[nI][25] += " " +ALLTRIM(_cGrpemb)
                    End
                    If .NOT. Empty(_cRisco)
                        aProd[nI][25] +=  " RISCO "+_cRisco
                    End
                Else
                    If DY3->(MsSeek(xFilial("DY3")+ SB5->B5_ONU))
                        If .NOT. Empty(DY3->DY3_DESCRI) .and. (DY3->DY3_INFCPL =="S" .OR. DY3->DY3_INFCPL =="1")
                            If .NOT. aProd[nI][25] $ DY3->DY3_ONU
                                aProd[nI][25]	+='  ONU '+Alltrim(DY3->DY3_ONU)+' '+Alltrim(DY3->DY3_DESCRI)+'   '
                            EndIF
                        EndIF
                    Else
                        aProd[nI][25] +=  If(.NOT. Empty(aProd[nI][25]),"**","")+" Produto NAO Perigoso"
                    EndIF
                End

            End

            If SF4->(FieldPos("F4_MENSNF"))>0

                SF4->(dbSetOrder(1))
                SF4->(dbSeeK(xFilial("SF4")+aProd[nI][27]))   // posicao 27 é o TES
                If SF4->(FieldPos("F4_MENSNF"))>0
                    cAux := alltrim(SF4->F4_MENSNF)
                    IF .NOT. Empty(cAux) .and. .NOT. (cAux $ cMensCli)
                        cMensCli += cAux+"**"
                    End
                End
                IF .NOT. EMPTY(SF4->F4_PISCOF) .AND. (SF4->F4_PISCOF < '4')
                    cAux := " Exclusao ICMS da Base de Calculo Pis e Cofins Conforme Regime Especial."
                    IF .NOT. (cAux $ cMensCli)
                        cMensCli += cAux+"**"
                    END
                END
                cMensCli:=U_TIRAACENTO(cMenscli)
            End
        Next
    End

    aadd(aRetorno,aProd)
    aadd(aRetorno,cMensCli)
    aadd(aRetorno,cMensFis)
    aadd(aRetorno,aDest)
    aadd(aRetorno,aNota)
    aadd(aRetorno,aInfoItem)
    aadd(aRetorno,aDupl)
    aadd(aRetorno,aTransp)
    aadd(aRetorno,aEntrega)
    aadd(aRetorno,aRetirada)
    aadd(aRetorno,aVeiculo)
    aadd(aRetorno,aReboque)
    aadd(aRetorno,aNfVincRur)
    aadd(aRetorno,aEspVol)
    aadd(aRetorno,aNfVinc)
    aadd(aRetorno,AdetPag)
    aadd(aRetorno,aObsCont)
    aadd(aRetorno,aProcRef)
    aadd(aRetorno,aMed)
    aadd(aRetorno,aLote)

    FwRestArea(aArea)

RETURN (aRetorno)
