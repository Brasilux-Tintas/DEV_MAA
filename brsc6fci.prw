#INCLUDE "TOTVS.CH"

User Function BRSC6FCI()
    Local aAreaSC6		:= SC6->(GetArea())
    Local lItemFat		:= .F.
    Local nPosItemPro	:= GDFieldPos("C6_ITEM")
    Local nPosCodPro	:= GDFieldPos("C6_PRODUTO")
    Local nPosOrigem	:= GDFieldPos("C6_CLASFIS")
    Local nPosCodFCI	:= GDFieldPos("C6_FCICOD")
    Local aRet			:= {}
    Local dDatPesq		:= M->C5_EMISSAO
    Local cMsg:=""

    SC6->(DbSetOrder(1))

    If (.NOT. INCLUI)
        If SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM + aCols[n][nPosItemPro] + aCols[n][nPosCodPro]))
            lItemFat := ( .NOT. Empty(SC6->C6_NOTA) .OR. SC6->C6_QTDENT > 0)
        EndIf
    End
    If (.NOT. GdDeleted(n)) .And. (.NOT. Empty(aCols[n][nPosCodPro])) .AND. (.NOT. lItemFat)

        aRet := XFciGetOrigem( aCols[n][nPosCodPro], dDatPesq )

        If (.NOT. Empty(aRet[1]))
            aCols[n][nPosOrigem] := aRet[1]+Substr(aCols[n][nPosOrigem],2)
        Else
            SB1->(dbSetOrder(1))
            SB1->(DbSeek(xFilial("SB1") + aCols[n][nPosCodPro]))
            aCols[n][nPosOrigem] := AllTrim(SB1->B1_ORIGEM)+AllTrim(Substr(aCols[n][nPosOrigem],2))
        EndIf
        If nPosCodFCI > 0
            If (.NOT. Empty(aCols[n][nPosCodFCI])) .and. Empty(aRet[2])
                cMsg := "Produto "+aCols[n][nPosCodPro]+CRLF+" não possui FCI para a data de emissão do Pedido."
            ElseIf  Empty(aCols[n][nPosCodFCI]) .and. (.NOT. Empty(aRet[2])) .or.;
                    (.NOT.  Empty(aCols[n][nPosCodFCI])) .and. (.NOT. Empty(aRet[2]))
                cMsg := "Produto "+aCols[n][nPosCodPro]+" possui FCI: "+aRet[2] +" = ICMS 4%"
            End
            aCols[n][nPosCodFCI] := Upper(aRet[2])
        EndIf
    EndIf
    If (.NOT. Empty(cMsg))
        FwAlertInfo(cMsg,"FCI - Ficha de Conteúdo de Importação")
    EndIf
    RestArea(aAreaSC6)

Return (aCols[n][nPosCodPro])
