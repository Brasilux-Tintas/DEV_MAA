#include 'topconn.ch'
User Function BRFATI99()
     aItens := {}
     aPosic := {}
     cQry1  := ""
     cQry1  += "SELECT ESTADO+REPRESENTANTE+CLIENTE AS CHAVE, MESANO, ESTADO, REPRESENTANTE, CLIENTE, SUM(QUANTIDADE) AS QUANTIDADE, SUM(VALOR) AS VALOR "
     cQry1  += "FROM RESULTADO_2007 WITH (NOLOCK) "
     cQry1  += "GROUP BY ESTADO+REPRESENTANTE+CLIENTE, ESTADO, REPRESENTANTE, CLIENTE, MESANO "
     TCQuery cQry1 ALIAS "TCQ" NEW
     DbSelectArea("TCQ")
     While !Eof()
           If aScan(aPosic, {|x| x[1] == TCQ->CHAVE}) == 0
              aAdd(aPosic, {TCQ->CHAVE})
              nPos := aScan(aPosic, {|x| x[1] == TCQ->CHAVE})
              aAdd(aItens, { TCQ->ESTADO, TCQ->REPRESENTANTE, TCQ->CLIENTE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
           Else
              nPos := aScan(aPosic, {|x| x[1] == TCQ->CHAVE})
           Endif
           nIni := 4
           nSal := 3

           aItens[nPos][( ( nIni + (nSal * ( Val( SubStr( TCQ->MESANO, 1, 2 ) ) - 1 ) ) ) + 0) ] += TCQ->QUANTIDADE
           aItens[nPos][( ( nIni + (nSal * ( Val( SubStr( TCQ->MESANO, 1, 2 ) ) - 1 ) ) ) + 1) ] += TCQ->VALOR
           aItens[nPos][( ( nIni + (nSal * ( Val( SubStr( TCQ->MESANO, 1, 2 ) ) - 1 ) ) ) + 2) ] += ( aItens[nPos][( ( nIni + (nSal * ( Val( SubStr( TCQ->MESANO, 1, 2 ) ) - 1 ) ) ) + 1) ] / aItens[nPos][( ( nIni + (nSal * ( Val( SubStr( TCQ->MESANO, 1, 2 ) ) - 1 ) ) ) + 0) ] )

           DbSelectArea("TCQ")
           DbSkip()
     EndDo
     aSort(aItens, , , {|x,y| x[1] < y[1]})
     DbSelectArea("TCQ")
     DbCloseArea()
Return(aItens)