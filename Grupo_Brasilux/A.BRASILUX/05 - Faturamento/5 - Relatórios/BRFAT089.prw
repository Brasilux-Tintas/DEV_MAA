#include 'rwmake.ch'
#include 'topconn.ch'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT089 º Autor ³ Luís Gustavo de S. º Data ³  15/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Faturamento X Produto                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFAT089()
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2         := "de acordo com os parametros informados pelo usuario."
     Local cDesc3         := "Faturamento x Cidade"
     Local cPict          := ""
     Local titulo         := "Faturamento x Cidade"
     Local nLin           := 80
     Local Cabec1         := ""
     Local Cabec2         := ""
     Local imprime        := .T.
     Local aOrd           := {}
     Private lEnd         := .F.
     Private lAbortPrint  := .F.
     Private CbTxt        := ""
     Private limite       := 220
     Private tamanho      := "G"
     Private nomeprog     := "BRFAT089" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo        := 18
     Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey     := 0
     Private cPerg        := "FAT089"
     Private cbtxt        := Space(10)
     Private cbcont       := 00
     Private CONTFL       := 01
     Private m_pag        := 01
     Private wnrel        := "BRFAT089" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString      := "SD2"

     DbSelectArea("SD2")
     DbSetOrder(1)
     
     ValPerg()
     Pergunte(cPerg, .F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta a interface padrao com o usuario...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

     If nLastKey == 27
        Return
     Endif
     SetDefault(aReturn,cString)
     If nLastKey == 27
        Return
     Endif
     nTipo := If(aReturn[4]==1,15,18)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     Processa({|lEnd| FAT089_1(Cabec1,Cabec2,Titulo,nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  15/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FAT089_1(Cabec1,Cabec2,Titulo,nLin)
       Local nOrdem, nY, nX
       Local aRetFun := {}
       DbSelectArea(cString)
       DbSetOrder(1)

       ProcRegua(RecCount())
       aRetFun := FAT089_2()
       aMeses  := {}
       nMes    := aRetFun[1]
       nAno    := aRetFun[2]
       Cabec1  := "    CÓDIGO                DESCRIÇÃO            | "
       For nY := 1 To mv_par03
           aadd(aMeses, StrZero(nMes, 2))
           Cabec1 += StrZero(nMes, 2)+'/'+StrZero(nAno, 4)+"    | "
           nMes += 1
           If nMes == 13
              nMes := 1
              nAno += 1
           Endif
       Next 
       Cabec1 += '  TOTAL    |'
       DbSelectArea("TCQ")
       DbGoTop()
       While !EOF()
             //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        220
             //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
             //----------------------------------------------------------------------------------------------------------------------
             //CIDADE: 999999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
             //----------------------------------------------------------------------------------------------------------------------
             //    CÓDIGO                DESCRIÇÃO            | 04/2004    | 05/2004    |   TOTAL    |
             //XXX99.99.999-99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | 999.999.99 | 999.999.99 | 999.999.99 | 999.999.99 | 999.999.99 | 999.999.99 | 999.999.99 | 999.999.99 | 999.999.99 | 999.999.99 | 999.999.99 | 999.999.99 | 999.999.99 |
             //   99           XXXXXXXXXXXXXXXXXXXX

             If lAbortPrint
                @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif
             cCodCid := TCQ->CODCID
             aCodCid := {}
             nLin := 80
             While !Eof() .and. TCQ->CODCID == cCodCid
                   nPos1 := aScan(aCodCid, {|x| x[1] == TCQ->CODIGO})
                   If nPos1 == 0
                      aadd(aCodCid, {TCQ->CODIGO, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} )
                      nPos2 := aScan(aMeses, TCQ->MES)
                      If nPos2 <> 0
                         aCodCid[Len(aCodCid)][nPos2+1] += TCQ->VOLUME
                         aCodCid[Len(aCodCid)][14]      += TCQ->VOLUME
                      Endif
                   Else
                      nPos2 := aScan(aMeses, TCQ->MES)
                      If nPos2 <> 0
                         aCodCid[nPos1][nPos2+1] += TCQ->VOLUME
                         aCodCid[nPos1][14]      += TCQ->VOLUME
                      Endif
                   Endif
                   DbSelectArea("TCQ")
                   DbSkip() // Avanca o ponteiro do registro no arquivo
             Enddo
             aTotal := {}
             aadd(aTotal, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
             For nY := 1 to Len(aCodCid)
                 For nX := 2 To 14
                     aTotal[1][nX] += aCodCid[nY][nX]
                 Next
             Next
             If mv_par07 == 1
                aSort(aCodCid,,, {|x,y| x[1] < y[1]})
             Else
                aSort(aCodCid,,, {|x,y| x[14] > y[14]})
             Endif
             For nY := 1 to Len(aCodCid)
                 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                 //³ Impressao do cabecalho do relatorio. . .                            ³
                 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                 If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                    nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                    nLin += 1
                    @ nLin, 000 PSAY cCodCid+'  -  '+Posicione("SZ7", 1, xFilial("SZ7")+cCodCid, "Z7_NOME") Picture "@!"
                      nLin += 1
                    @ nLin, 000 PSAY Replicate("-", 220)
                      nLin += 1
                 Endif
                 If mv_par05 == 1
                    @ nLin, 000 PSAY aCodCid[nY][1] Picture "@R 99"
                    @ nLin, 016 PSAY SubStr(Alltrim(Posicione("SZ1", 1, xFilial("SZ1")+aCodCid[nY][1], "Z1_DESCR")), 1, 30) Picture "@!"
                 Else
                    @ nLin, 000 PSAY aCodCid[nY][1] Picture "@R XXX99.99.999-99"
                    @ nLin, 016 PSAY SubStr(Alltrim(Posicione("SB1", 1, xFilial("SB1")+aCodCid[nY][1], "B1_DESC")), 1, 30) Picture "@!"
                 Endif
                 @ nLin, 047 PSAY "|"
                 nCol1 := 49
                 nCol2 := 60
                 For nX := 2 to (mv_par03 + 1)
                     @ nLin, nCol1 PSAY aCodCid[nY][nX] Picture "@E 999,999.99"
                     @ nLin, nCol2 PSAY "|"
                     nCol1 += 13
                     nCol2 += 13
                 Next
                 @ nLin, nCol1 PSAY aCodCid[nY][14] Picture "@E 999,999.99"
                 @ nLin, nCol2 PSAY "|"
                 nLin := nLin + 1 // Avanca a linha de impressao
             Next
             @ nLin, 000 PSAY Replicate("-", 220)
               nLin += 1
               nCol1 := 49
               nCol2 := 60
             For nX := 2 to (mv_par03+1)
                 @ nLin, nCol1 PSAY aTotal[1][nX] Picture "@E 999,999.99"
                 @ nLin, nCol2 PSAY "|"
                 nCol1 += 13
                 nCol2 += 13
             Next
             @ nLin, nCol1 PSAY aTotal[1][14] Picture "@E 999,999.99"
             @ nLin, nCol2 PSAY "|"
             nLin := nLin + 1 // Avanca a linha de impressao
       EndDo
DbSelectArea("TCQ")
DbCloseArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

Static Function FAT089_2()
       Local cQry1   := ""
       Local dPriDia := cTod('  /  /  ')
       Local dUltDia := cTod('  /  /  ')
       
       If mv_par06 == 1
          nMesAtu := Month(dDataBase)
          nAnoAtu := Year(dDataBase)
          nMesIni := nMesAtu - (mv_par03 - 1)
          If nMesIni == 0
             nMesIni := 12
             nAnoIni := nAnoAtu - 1
          ElseIf nMesIni < 0
                 nMesIni := 12 + nMesIni
                 nAnoIni := nAnoAtu - 1
          Else
             nAnoIni := Year(dDataBase)
          Endif
          dPriDia := cTod('01/'+StrZero(nMesIni, 2)+'/'+StrZero(nAnoIni, 4))
          dUltDia := cTod(StrZero(f_UltDia(dDataBase), 2)+'/'+StrZero(Month(dDataBase), 2)+'/'+StrZero(Year(dDataBase), 4))
       Else
          nMesAtu := Month(dDataBase) - 1
          If nMesAtu == 0
             nMesAtu := 12
             nAnoAtu := Year(dDataBase) - 1
          Else
             nAnoAtu := Year(dDataBase)
          Endif
          nMesIni := nMesAtu - (mv_par03 - 1)
          If nMesIni == 0
             nMesIni := 12
             nAnoIni := Year(dDataBase) - 1
          ElseIf nMesIni < 0
                 nMesIni := 12 + nMesIni
                 nAnoIni := Year(dDataBase) - 1
          Else
             nAnoIni := Year(dDataBase)
          Endif
          dPriDia := cTod('01/'+StrZero(nMesIni, 2)+'/'+StrZero(nAnoIni, 4))
          dUltDia := cTod('01/'+StrZero(Month(dDataBase), 2)+'/'+StrZero(Year(dDataBase), 4))
       Endif  
       
       
       If mv_par05 == 1
			cQry1 := "SELECT SUBSTRING(SD2.D2_COD,4,2) AS CODIGO, SF2.F2_CODCID AS CODCID, SUBSTRING(SF2.F2_EMISSAO,5,2) AS MES,"+;
			"SUM(SD2.D2_QUANT*SZ5.Z5_VOLUME) AS VOLUME "

//          cQry1 += "SELECT FAT.CODCID, SUBSTRING(FAT.CODIGO, 4, 2) AS CODIGO, SUBSTRING(FAT.EMISSAO, 5, 2) AS MES, SUM(QUANTIDADE * VOLUME) AS VOLUME "
       Else
			cQry1 := "SELECT SD2.D2_COD AS CODIGO, SF2.F2_CODCID AS CODCID, SUBSTRING(SF2.F2_EMISSAO,5,2) AS MES, "+;
			"SUM(SD2.D2_QUANT*SZ5.Z5_VOLUME) AS VOLUME "
//          cQry1 += "SELECT FAT.CODCID, FAT.CODIGO, SUBSTRING(FAT.EMISSAO, 5, 2) AS MES, SUM(QUANTIDADE * VOLUME) AS VOLUME "
       Endif
		cQry1 += "FROM SD2010 SD2 "+;
		"LEFT OUTER JOIN SF2010 SF2 ON SD2.D2_FILIAL = SF2.F2_FILIAL AND SD2.D2_DOC = SF2.F2_DOC    AND SF2.D_E_L_E_T_ = '' "+;
		"LEFT OUTER JOIN SF4010 SF4 ON '  '          = SF4.F4_FILIAL AND SD2.D2_TES = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ = '' "+;
		"LEFT OUTER JOIN SZ5010 SZ5 ON '  '          = SZ5.Z5_FILIAL AND SUBSTRING(SD2.D2_COD, 11, 2) = SZ5.Z5_EMB AND SZ5.D_E_L_E_T_ = '' "+;
		"WHERE (SD2.D2_FILIAL = '"+xFilial("SD2")+"') AND (SD2.D_E_L_E_T_ = '') "+;
		"AND (F2_CODCID BETWEEN  '"+mv_par01+"' AND '"+mv_par02+"') "+;
       	"AND (F2_EMISSAO BETWEEN '"+dTos(dPriDia)+"' AND '"+dTos(dUltDia)+"') "
       	If mv_par04 == 1
        	cQry1 += "  AND (F4_DUPLIC = 'S') "
       	ElseIf mv_par04 == 1
        	cQry1 += "  AND (F4_DUPLIC <> 'S') "
       	Endif
       	If mv_par05 == 1
          	cQry1 += "GROUP BY F2_CODCID, SUBSTRING(D2_COD, 4, 2), SUBSTRING(F2_EMISSAO, 5, 2)  "
       	Else
          	cQry1 += "GROUP BY F2_CODCID, D2_COD, SUBSTRING(F2_EMISSAO, 5, 2) "
       Endif
       cQry1 += "ORDER BY CODCID, MES "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
Return({nMesIni, nAnoIni, nMesAtu, nAnoAtu})

Static Function ValPerg()
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg, "01", "Da cidade           ?", "", "", "mv_ch1", "C", 06, 0, 0, "G", ""                      , "mv_par01", ""      , "", "", "", "", ""       , "", "", "", "", ""     , "", "", "", "", "", "", "", "", "", "", "", "", "", "SZ7", ""})
       aAdd(aRegs,{cPerg, "02", "Até a cidade        ?", "", "", "mv_ch2", "C", 06, 0, 0, "G", ""                      , "mv_par02", ""      , "", "", "", "", ""       , "", "", "", "", ""     , "", "", "", "", "", "", "", "", "", "", "", "", "", "SZ7", ""})
       aAdd(aRegs,{cPerg, "03", "Quantidade de meses ?", "", "", "mv_ch3", "N", 02, 0, 0, "G", "Entre(1, 12, mv_par03)", "mv_par03", ""      , "", "", "", "", ""       , "", "", "", "", ""     , "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})
       aAdd(aRegs,{cPerg, "04", "Considera TES Dupl. ?", "", "", "mv_ch4", "N", 01, 0, 0, "C", ""                      , "mv_par04", "Sim"   , "", "", "", "", "Não"    , "", "", "", "", "Ambas", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})
       aAdd(aRegs,{cPerg, "05", "Tipo de relatório   ?", "", "", "mv_ch5", "N", 01, 0, 0, "C", ""                      , "mv_par05", "Linha" , "", "", "", "", "Produto", "", "", "", "", ""     , "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})
       aAdd(aRegs,{cPerg, "06", "Considera mes atual ?", "", "", "mv_ch6", "N", 01, 0, 0, "C", ""                      , "mv_par06", "Sim"   , "", "", "", "", "Não"    , "", "", "", "", ""     , "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})
       aAdd(aRegs,{cPerg, "07", "Ordem               ?", "", "", "mv_ch7", "N", 01, 0, 0, "C", ""                      , "mv_par07", "Código", "", "", "", "", "Volume" , "", "", "", "", ""     , "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})
       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i,2])
              RecLock("SX1",.T.)
              For j:=1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                 Endif
              Next
              MsUnlock()
           Endif
       Next

       dbSelectArea(_sAlias)
Return