#include 'protheus.ch'
#Translate MSGBOX( => IW_MsgBox(
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATX06  ºAutor  ³ Luís G. de Souza   º Data ³  18/08/05  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação de usuário dos campos C6_PRODUTO e C6_PRCVEN no- º±±
±±º          ³ dicionário de dados (SX3), para não deixar alterar item queº±±
±±º          ³ esteja amarrado com uma ordem de produção.                 º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFATX06()
     Local cAliAtu := Alias()
     Local nOrdAtu := IndexOrd()
     Local nRecAtu := Recno()
     Local lRet    := .t.
     Local nPosIte := aScan(aHeader, {|x| Trim(x[2]) == "C6_ITEM"    })
     Local nPosPro := aScan(aHeader, {|x| Trim(x[2]) == "C6_PRODUTO" })
     Local nPosDes := aScan(aHeader, {|x| Trim(x[2]) == "C6_DESCRI"  })
     Local nPosQtd := aScan(aHeader, {|x| Trim(x[2]) == "C6_QTDVEN"  })
     Local nPosPrc := aScan(aHeader, {|x| Trim(x[2]) == "C6_PRCVEN"  })
     Local nPosUnt := aScan(aHeader, {|x| Trim(x[2]) == "C6_PRUNIT"  })
     Local nPosVlr := aScan(aHeader, {|x| Trim(x[2]) == "C6_VALOR"   })
     Local nPosUni := aScan(aHeader, {|x| Trim(x[2]) == "C6_UM"      })
     Local nPosTES := aScan(aHeader, {|x| Trim(x[2]) == "C6_TES"     })
     Local nPosCFi := aScan(aHeader, {|x| Trim(x[2]) == "C6_CF"      })
     Local nPosCla := aScan(aHeader, {|x| Trim(x[2]) == "C6_CLASFIS" })
     Local nPosUVe := aScan(aHeader, {|x| Trim(x[2]) == "C6_UNSVEN"  })
     Local nPosLot := aScan(aHeader, {|x| Trim(x[2]) == "C6_NUMLOTE" })

     If ALTERA .and. !INCLUI
        If __ReadVar $ 'M->C6_PRODUTO.M->C6_QTDVEN'
           If !Empty(Posicione("SC6", 1, xFilial("SC6")+M->C5_NUM+aCols[n][nPosIte], "C6_NUMLOTE"))
              MsgBox("Esse item não pode ser alterado, pois possui Ordem de Produção gerada.", "Atenção...", "STOP")
              aCols[n][nPosPro] := Posicione("SC6", 1, xFilial("SC6")+M->C5_NUM+aCols[n][nPosIte], "C6_PRODUTO")
              aCols[n][nPosDes] := Posicione("SC6", 1, xFilial("SC6")+M->C5_NUM+aCols[n][nPosIte], "C6_DESCRI" )
              aCols[n][nPosQtd] := Posicione("SC6", 1, xFilial("SC6")+M->C5_NUM+aCols[n][nPosIte], "C6_QTDVEN" )
              aCols[n][nPosPrc] := Posicione("SC6", 1, xFilial("SC6")+M->C5_NUM+aCols[n][nPosIte], "C6_PRCVEN" )
              aCols[n][nPosUnt] := Posicione("SC6", 1, xFilial("SC6")+M->C5_NUM+aCols[n][nPosIte], "C6_PRUNIT" )
              aCols[n][nPosVlr] := Posicione("SC6", 1, xFilial("SC6")+M->C5_NUM+aCols[n][nPosIte], "C6_VALOR"  )
              aCols[n][nPosUni] := Posicione("SC6", 1, xFilial("SC6")+M->C5_NUM+aCols[n][nPosIte], "C6_UM"     )
              aCols[n][nPosTES] := Posicione("SC6", 1, xFilial("SC6")+M->C5_NUM+aCols[n][nPosIte], "C6_TES"    )
              aCols[n][nPosCFi] := Posicione("SC6", 1, xFilial("SC6")+M->C5_NUM+aCols[n][nPosIte], "C6_CF"     )
              aCols[n][nPosCla] := Posicione("SC6", 1, xFilial("SC6")+M->C5_NUM+aCols[n][nPosIte], "C6_CLASFIS")
              aCols[n][nPosUVe] := Posicione("SC6", 1, xFilial("SC6")+M->C5_NUM+aCols[n][nPosIte], "C6_UNSVEN" )              
              aCols[n][nPosLot] := Posicione("SC6", 1, xFilial("SC6")+M->C5_NUM+aCols[n][nPosIte], "C6_NUMLOTE")
              lRet := .f.
           Endif
        Endif
     Endif
     DbSelectArea(cAliAtu)
     DbSetOrder(nOrdAtu)
     DbGoTo(nRecAtu)
Return(lRet)
