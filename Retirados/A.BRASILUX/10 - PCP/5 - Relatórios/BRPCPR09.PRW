#include 'rwmake.ch'
#include "topconn.ch"
#include "avprint.ch"

User Function BRPCPR09()
     Local nX, NY
     Private nLin  := 30
     Private nCol  := 30
     Private nLinMax := 3315
     Private nColMax := 2350

     oFont1  := TFont():New("Courier New"        , 9, 14, .F., .T.,  5, .F., 5, .F., .F.)
     cTipCod := 'CODE128'
     cAuxFun := GETMV("MV_ENVASAD")
     cAuxQry := ""
     While Len(cAuxFun) > 0.0
           cAuxQry += "'"+SubStr(cAuxFun, 1, 3)+"', "
           cAuxFun := SubStr(cAuxFun, 5, Len(cAuxFun))
     Enddo
     
     cQry1  := ""
     cQry1  += "SELECT SRA.RA_NOME, SRA.RA_MAT "
     cQry1  += "FROM "+RetSqlName("SRA")+" SRA WITH (NOLOCK) "
     cQry1  += "WHERE SRA.RA_FILIAL = '"+xFilial("SRA")+"' "
     cQry1  += "  AND SRA.D_E_L_E_T_ = '' "
     cQry1  += "  AND SRA.RA_MAT IN("+SubStr(cAuxQry, 1, Len(cAuxQry)-2)+") "
     cQry1  += "ORDER BY 1 "
     TCQuery cQry1 ALIAS "TCQ" NEW
     DbSelectArea("TCQ")
     
     oPrn:= TMSPrinter():New( "Impressão de Código de Barras de envasadores." )
     oPrn:SetPortrait()      //SetLandscape()
     AVPRINT oPrn NAME "Impressão de Código de Barras de envasadores."
             AVPAGE
             nLin := 190
             nRow := 1 //cm
             nCol := 1 //cm
             nTes := 10
             nLad := 0
             lMais := .t.
             For nY := 1 to 332
                 //oPrn:Say(nTes, nLad, StrZero(nY*10, 4), oFont1, , , , )
                 nTes += 10
                 If (nTes/200) - Int(nTes/200) == 0
                    If (nTes / 200) / 2 - int((nTes / 200) / 2) == 0.5
                       lMais := .f.
                    Else
                       lMais := .t.
                    Endif
                 Endif
                 If lMais
                    nLad += 100
                 Else
                    nLad -= 100
                 Endif
             Next
             nPag := 1
             xCol := 1
             nSal := 50
             nIni := 0
             aEnv := {}
             __useOldCm2Pix := .f.
             While !Eof()
                   If xCol == 1
                      xCol += 1
                      //        Pagina                                            1º Coluna                                                   2º Coluna
                      //           |      +-------------------------------------------/\---------------------------------------------+      +-----/\-----+
                      //           |     /                                                                                            \    /              \
                      //           |    |                                                                                              |  |                |
                      aAdd(aEnv, {nPag, nRow, nCol, nLin, 060, TCQ->RA_MAT, Alltrim(TCQ->RA_MAT)+' - '+SubStr(TCQ->RA_NOME, 1, 25), 0, 0, 0, 0, '', '', nLin+nSal, nIni })
                      If nLin >= nLinMax
                         nPag += 1
                         nRow := 1
                         nLin := 190
                         nIni := 0
                      Endif
                   Else
                      xCol -= 1
                      aEnv[Len(aEnv)][08] := nRow
                      aEnv[Len(aEnv)][09] := 10.6
                      aEnv[Len(aEnv)][10] := nLin
                      aEnv[Len(aEnv)][11] := 1200
                      aEnv[Len(aEnv)][12] := TCQ->RA_MAT
                      aEnv[Len(aEnv)][13] := Alltrim(TCQ->RA_MAT)+' - '+SubStr(TCQ->RA_NOME, 1, 25)
                      nRow += 2.00
                      nLin += 236.15
                      If nLin >= nLinMax
                         nPag += 1
                         nRow := 1
                         nLin := 190
                         nIni := 0
                      Endif
                   Endif
                   DbSelectArea("TCQ")
                   DbSkip()
             Enddo
             For nX := 1 to nPag
                 If nX <> 1
                    AVNEWPAGE
                 Endif
                 For nY := 1 to Len(aEnv)
                     If aEnv[nY][1] == nX
                        If !Empty(aEnv[nY][6])
                           MSBAR(cTipCod,  aEnv[nY][02], aEnv[nY][03] , aEnv[nY][06], oPrn, .f., NIL, .t., 0.025, 1, NIL, NIL, NIL, .f.)
                           oPrn:Say(aEnv[nY][04], aEnv[nY][05], aEnv[nY][07], oFont1, , , , )
                        Endif
                        If !Empty(aEnv[nY][12])
                           MSBAR(cTipCod,  aEnv[nY][08], aEnv[nY][09] , aEnv[nY][12], oPrn, .f., NIL, .t., 0.025, 1, NIL, NIL, NIL, .f.)
                           oPrn:Say(aEnv[nY][10], aEnv[nY][11], aEnv[nY][13], oFont1, , , , )
                        Endif
                        oPrn:Line(aEnv[nY][15], 1150, aEnv[nY][14], 1150)       //Coluna
                        oPrn:Line(aEnv[nY][14], 0000, aEnv[nY][14], nColMax+10) //Linhas
                     Endif
                 Next
             Next
             AVENDPAGE
     AVENDPRINT
     DbSelectArea("TCQ")
     DbCloseArea()
Return
