#include 'topconn.ch'
User Function BRFATI98()
     Local nX
     aPosic  := {}
     aItens  := {}
     cParUsa := If(ParamIxb == Nil, "2008MD", ParamIxb)
     cPar001 := SubStr(cParUsa, 1, 4) //Ano dos dados
     cPar002 := SubStr(cParUsa, 5, 1) //M=Mensal ou L=Linha
     nIni    := 4
     nSal    := 3
     If cPar002 $ 'L' 
        //Por Linha
        cPar003 := SubStr(cParUsa, 6, 1) //C=Cabeçalho ou D=Dados
        aPosLi  := {}
        nTamAr  := 3
        //Busca Linhas Vendidas para montar matriz dinâmica
        cQry1   := ""
        cQry1   += "SELECT SZ1.Z1_LINHA AS LINHA "
        cQry1   += "FROM "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) "
        cQry1   += "WHERE SZ1.Z1_FILIAL = '"+xFilial("SZ1")+"' "
        cQry1   += "  AND SZ1.D_E_L_E_T_ = '' "
        cQry1   += "GROUP BY SZ1.Z1_LINHA "
        cQry1   += "ORDER BY SZ1.Z1_LINHA "
        TCQuery cQry1 ALIAS "TCQ" NEW
        DbSelectArea("TCQ")
        While !Eof()
              nTamAr += 3
              If aScan(aPosLi, {|x| x[1] == TCQ->LINHA}) == 0
                 aAdd(aPosLi, {TCQ->LINHA})
              Endif
              DbSelectArea("TCQ")
              DbSkip()
        EndDo
        DbSelectArea("TCQ")
        DbCloseArea()
        nTamAr += 2
        If cPar003 $ 'C' //Cabeçalho
           aCabec := {}
           aAdd(aCabec, Array(nTamAr))
           aAdd(aCabec, Array(nTamAr))
           aCabec[1][1] := "ESTADO"
           aCabec[1][2] := "REPRESENTANTE"
           aCabec[1][3] := "CLIENTE"
           aCabec[2][1] := ""
           aCabec[2][2] := ""
           aCabec[2][3] := ""
           For nX := 1 To Len(aPosLi)
               aCabec[1][ ( ( nIni + (nSal * ( nX - 1 ) ) ) + 0)] := ""
               aCabec[1][ ( ( nIni + (nSal * ( nX - 1 ) ) ) + 1)] := "'"+aPosLi[nX][1]
               aCabec[1][ ( ( nIni + (nSal * ( nX - 1 ) ) ) + 2)] := ""
               aCabec[2][ ( ( nIni + (nSal * ( nX - 1 ) ) ) + 0)] := "VOLUME (L)"
               aCabec[2][ ( ( nIni + (nSal * ( nX - 1 ) ) ) + 1)] := "FATURAMENTO (R$)"
               aCabec[2][ ( ( nIni + (nSal * ( nX - 1 ) ) ) + 2)] := "PREÇO MÉDIO (R$)"
           Next
           aCabec[1][nTamAr - 1] := "TOTAL"
           aCabec[1][nTamAr - 0] := ""
           aCabec[2][nTamAr - 1] := "VOLUME (L)"
           aCabec[2][nTamAr - 0] := "FATURAMENTO (R$)"
           Return(aCabec)
        Else //Dados
           cQry1  := ""
           cQry1  += "SELECT ESTADO+REPRESENTANTE+CLIENTE AS CHAVE, ESTADO, REPRESENTANTE, CLIENTE, LINHA, SUM(QUANTIDADE) AS QUANTIDADE, SUM(VALOR) AS VALOR "
           cQry1  += "FROM RESULTADO_"+cPar001+" WITH (NOLOCK) "
           cQry1  += "GROUP BY ESTADO+REPRESENTANTE+CLIENTE, ESTADO, REPRESENTANTE, CLIENTE, LINHA "
           TCQuery cQry1 ALIAS "TCQ" NEW
           DbSelectArea("TCQ")
           While !Eof()
                 If aScan(aPosic, {|x| x[1] == TCQ->CHAVE}) == 0
                    aAdd(aPosic, {TCQ->CHAVE})
                    nPos := aScan(aPosic, {|x| x[1] == TCQ->CHAVE})
                    aAdd(aItens, Array(nTamAr) )
                    aItens[nPos][01] := TCQ->ESTADO
                    aItens[nPos][02] := TCQ->REPRESENTANTE
                    aItens[nPos][03] := TCQ->CLIENTE
                    For nX := 4 TO nTamAr
                        aItens[nPos][nX] := 0
                    Next
                 Else
                    nPos := aScan(aPosic, {|x| x[1] == TCQ->CHAVE})
                 Endif
                 nPosLin := aScan(aPosLi, {|x| x[1] == TCQ->LINHA})
                 aItens[nPos][ ( ( nIni + (nSal * ( nPosLin - 1 ) ) ) + 0) ] += TCQ->QUANTIDADE
                 aItens[nPos][ ( ( nIni + (nSal * ( nPosLin - 1 ) ) ) + 1) ] += TCQ->VALOR
                 aItens[nPos][ ( ( nIni + (nSal * ( nPosLin - 1 ) ) ) + 2) ] += ( aItens[nPos][ ( ( nIni + (nSal * ( nPosLin - 1 ) ) ) + 1) ] / aItens[nPos][ ( ( nIni + (nSal * ( nPosLin - 1 ) ) ) + 0) ] )
                 aItens[nPos][nTamAr - 1] += TCQ->QUANTIDADE
                 aItens[nPos][nTamAr    ] += TCQ->VALOR
                 DbSelectArea("TCQ")
                 DbSkip()
           EndDo
           aSort(aItens, , , {|x,y| x[1] < y[1]})
           DbSelectArea("TCQ")
           DbCloseArea()
           Return(aItens)
        Endif
     ElseIf cPar002 $ 'M'
            //Por Mes
            aPosMe := {}
            nTamAr := 3      //As 3 Primeiras Linhas
            For nX := 1 To 12
                aAdd(aPosMe, {StrZero(nX, 2)})
                nTamAr += 3 //12 Meses x 3 Colunas por mes
            Next
            nTamAr += 2        //2 Colunas de Soma
            cQry1  := ""
            cQry1  += "SELECT ESTADO+REPRESENTANTE+CLIENTE AS CHAVE, ESTADO, REPRESENTANTE, CLIENTE, MESANO, SUM(QUANTIDADE) AS QUANTIDADE, SUM(VALOR) AS VALOR "
            cQry1  += "FROM RESULTADO_"+cPar001+" WITH (NOLOCK) "
            cQry1  += "GROUP BY ESTADO+REPRESENTANTE+CLIENTE, ESTADO, REPRESENTANTE, CLIENTE, MESANO "
            TCQuery cQry1 ALIAS "TCQ" NEW
            DbSelectArea("TCQ")
            While !Eof()
                  If aScan(aPosic, {|x| x[1] == TCQ->CHAVE}) == 0
                     aAdd(aPosic, {TCQ->CHAVE})
                     nPos := aScan(aPosic, {|x| x[1] == TCQ->CHAVE})
                     aAdd(aItens, Array(nTamAr) )
                     aItens[nPos][01] := TCQ->ESTADO
                     aItens[nPos][02] := TCQ->REPRESENTANTE
                     aItens[nPos][03] := TCQ->CLIENTE
                     For nX := 4 TO nTamAr
                         aItens[nPos][nX] := 0
                     Next
                  Else
                     nPos := aScan(aPosic, {|x| x[1] == TCQ->CHAVE})
                  Endif
                  nPosMes := aScan(aPosMe, {|x| x[1] == SubStr(TCQ->MESANO, 1, 2)})
                  aItens[nPos][ ( ( nIni + (nSal * ( nPosMes - 1 ) ) ) + 0) ] += TCQ->QUANTIDADE
                  aItens[nPos][ ( ( nIni + (nSal * ( nPosMes - 1 ) ) ) + 1) ] += TCQ->VALOR
                  aItens[nPos][ ( ( nIni + (nSal * ( nPosMes - 1 ) ) ) + 2) ] += ( aItens[nPos][ ( ( nIni + (nSal * ( nPosMes - 1 ) ) ) + 1) ] / aItens[nPos][ ( ( nIni + (nSal * ( nPosMes - 1 ) ) ) + 0) ] )
                  aItens[nPos][nTamAr - 1] += TCQ->QUANTIDADE
                  aItens[nPos][nTamAr    ] += TCQ->VALOR
                  DbSelectArea("TCQ")
                  DbSkip()
            EndDo
            DbSelectArea("TCQ")
            DbCloseArea()
            Return(aItens)
     Endif
Return