#include 'protheus.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRFATA04 บAutor  ณ Luํs G. de Souza   บ Data ณ  12/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gatilho para calculo de pallets por item de pedido.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BRFATA04()
     Local nPosProd := aScan(aHeader, { |x| Trim(x[2]) == 'C6_PRODUTO'})
     Local nPosQuan := aScan(aHeader, { |x| Trim(x[2]) == 'C6_QTDVEN' })
     Local nCapProd := Iif(Len(Alltrim(aCols[n][nPosProd])) == 12, Iif( SubStr(Alltrim(aCols[n][nPosProd]), 11, 2) == '11' .and. SubStr(Alltrim(aCols[n][nPosProd]), 01, 2) $ 'CT.ED', Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(aCols[n][nPosProd]), 11, 2), "Z5_CAPMIN"), Posicione("SZ5", 1, xFilial("SZ5")+SubStr(Alltrim(aCols[n][nPosProd]), 11, 2), "Z5_CAPACID")), 1)
     Local nPallets := 0
     If aCols[n][nPosQuan] == 0
        nPallets := 0
     Else
        If nCapProd == 1
           nPallets := 0
        Else
           nPallets := aCols[n][nPosQuan] / nCapProd
        Endif
     Endif
Return(nPallets)