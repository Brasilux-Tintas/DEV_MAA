#include 'rwmake.ch'
#include 'topconn.ch'
#include 'avprint.ch'
#include 'brpcpx01.ch'
#define DS_MODALFRAME            128  // 0x80
#define WS_POPUP          2147483648  // 0x80000000L
#define WS_CAPTION          12582912  // 0x00C00000L
#define WS_VISIBLE         268435456  // 0x10000000L
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
/******************************************************************************************************************/
/***                    FUNÇÕES UTILIZADAS NO MÓDULO DE PLANEJAMENTO E CONTROLE DA PRODUÇÃO                     ***/
/******************************************************************************************************************/
/***  FUNÇÃO  # F. AUXIL. #                                                                                     ***/
/******************************************************************************************************************/
/*** fCPvcBri #           # Calcula PVC e Brilho de produto/revisão                                             ***/
/***          # fBusVlPB  # Calcula e busca valores de PVC e Brilho                                             ***/
/***          # fCVolRes  # Calcula o volume da resina                                                          ***/
/***          # fCAbsOle  # Busca informação da Absorção de óleo do pigmento                                    ***/
/***          # fBInfPas  # Busca informação da pasta                                                           ***/
/******************************************************************************************************************/
/*** fFichaOP #           # Imprime a Ficha de Processo do Produto.                                             ***/
/***          # fBusOper  # Busca Operações para impressão da Ficha de Processo.                                ***/
/***          # fCabFich  # Imprime cabeçalho da Ficha de Processo.                                             ***/
/***          # fBusEsOp  # Busca estrutura por operação.                                                       ***/
/******************************************************************************************************************/
/*** fBusUlRv #           # Busca ultima revisão válida do produto.                                             ***/
/******************************************************************************************************************/
/*** fMonOper #           # Monta estrutura de operações do produto.                                            ***/
/***          # fMatOper  # Monta matriz aCols e aHeader para o roteiro do produto.                             ***/
/******************************************************************************************************************/
/*** fIncEmba #           # Monta entrada e manutenção de embalagens para os produtos tintas.                   ***/
/***          # fMatEmba  # Monta as matrizes aCols e aHeader para a manutenção das embalagens.                 ***/
/******************************************************************************************************************/
/*** fCCusPro #           # Função recursiva para calculo do custo de um PI.                                    ***/
/******************************************************************************************************************/
/*** fCPrcVen #           # Função para calculo do preço de venda.                                              ***/
/***          # fGets     # Lê linha de uma arquivo texto                                                       ***/
/***          # fTon      # Converte uma string em numero.                                                      ***/
/***          # fCCusPro  # Função recursiva para calculo do custo de um PI.                                    ***/
/***          # fCOutVal  # Função para busca de valores no calculo do preço do produto.                        ***/
/******************************************************************************************************************/
/*** ########################################################################################################## ***/

/******************************************************************************************************************/
/*** fCPvcBri - Calcula PVC e BRILHO de um produto/revisão                                                      ***/
/******************************************************************************************************************/
User Function fCPvcBri(cCodigo, cRevisao, aHeader, aCols)
       Local cQry1       := ""
       //Local cQry2       := ""
       //Local nPesEsp     := 0
       Local nCalPVC     := 0
       Local nCalBri     := 0
       Local cCodRev     := Iif(cRevisao == Nil, '', cRevisao)
       
       If Empty(cCodRev)
          cQry1 += "SELECT SB1.B1_COD AS CODIGO, SB1.B1_PESOESP AS PESOESP, SB1.B1_TIPO AS TIPO, SB1.B1_UM AS UNIMED "
          cQry1 += "FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "
          cQry1 += "WHERE SB1.B1_FILIAL  = '"+xFilial("SB1")+"' "
          cQry1 += "  AND SB1.D_E_L_E_T_ = '' "
          cQry1 += "  AND SB1.B1_COD  = '"+cCodigo+"' "
          cQry1 += "ORDER BY SB1.B1_COD "
       Else
          cQry1 += "SELECT SZM.ZM_CODIGO AS CODIGO, SZM.ZM_REVISAO AS REVISAO, SZM.ZM_PESESP AS PESOESP, SZM.ZM_TIPO AS TIPO, SZM.ZM_UM AS UNIMED "
          cQry1 += "FROM "+RetSqlName("SZM")+" SZM "
          cQry1 += "WHERE SZM.ZM_FILIAL  = '"+xFilial("SZM")+"' "
          cQry1 += "  AND SZM.D_E_L_E_T_ = '' "
          cQry1 += "  AND SZM.ZM_CODIGO  = '"+cCodigo+"' "
          cQry1 += "  AND SZM.ZM_REVISAO = '"+cRevisao+"' "
          cQry1 += "ORDER BY SZM.ZM_CODIGO, SZM.ZM_REVISAO "
       Endif
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       If !Eof() .and. !Bof()
          fBusVlPB(cCodigo, cCodRev, TCQ->TIPO, TCQ->UNIMED, TCQ->PESOESP, @nCalPVC, @nCalBri, aCols)
       Else
          fBusVlPB(cCodigo, cCodRev, M->ZM_TIPO, M->ZM_UM  , TCQ->PESOESP, @nCalPVC, @nCalBri, aCols)
       Endif
       DbSelectArea("TCQ")
       DbCloseArea()
Return({nCalPVC, nCalBri})

/******************************************************************************************************************/
/*** fBuscaVl - Calcula e busca valores de PVC e Brilho.                                                        ***/
/******************************************************************************************************************/
Static Function fBusVlPB(cCodPro, cRevPro, cTipPro, cUniMed, nPesNew, nCalPVC, nCalBri, aCols)
       Local nPosCom  := 1 //aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_COMP"  } )
       Local nPosSeq  := 2 //aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_TRT"   } )
       Local nPosPer  := 3 //aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERC"  } )
       Local nPosPEs  := 4 //aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PESESP"} )
       //Local nPerFor  := 0
       Local nPvol    := 0
       Local nPTot    := 0
       Local nVvol    := 0
       //Local nVTot    := 0
       Local nMAbs    := 0
       Local nMMis    := 0
       Local cQry1    := ""
       Local aFormula := {}
       Local aResina  := {}
       Local aPigmen  := {}
	   Local aSolvent := {}
	   Local aColsAux := {}
	   Local nY
       nCalPVC        := 0
       nCalBri        := 0
       
       If Empty(cRevPro) //Busca Valores para produtos vigentes.
          cQry1 := ""
          cQry1 += "SELECT * "
          cQry1 += "FROM "+RetSqlName("SG1")+" SG1 "
          cQry1 += "WHERE SG1.G1_FILIAL  = '"+xFilial("SG1")+"' "
          cQry1 += "  AND SG1.D_E_L_E_T_ = '' "
          cQry1 += "  AND SG1.G1_COD     = '"+cCodPro+"' "
          TCQuery cQry1 ALIAS "QFOR" NEW
          DbSelectArea("QFOR")
          While !Eof()
                aadd(aColsAux, {QFOR->G1_COMP, QFOR->G1_TRT, QFOR->G1_PERC, Posicione("SB1", 1, xFilial("SB1")+QFOR->G1_COMP, "B1_PESOESP") } )
                DbSelectArea("QFOR")
                DbSkip()
          Enddo
          DbSelectArea("QFOR")
          DbCloseArea()
       Else              //Busca Valores para produtos de revisão
          For nY := 1 To Len(aCols)
              If !aCols[nY][Len(aHeader) + 1]
                 aadd(aColsAux, {aCols[nY][1], aCols[nY][3], aCols[nY][4], aCols[nY][8] })
              Endif
          Next
       Endif
       If cTipPro $ 'PI'
          For nY := 1 To Len(aColsAux)
              cTipMat := Posicione("SB1", 1, xFilial("SB1")+aColsAux[nY][nPosCom], "B1_TIPO")
              cGruMat := Posicione("SB1", 1, xFilial("SB1")+aColsAux[nY][nPosCom], "B1_GRUPO")
              aAdd(aFormula, { aColsAux[nY][nPosSeq], aColsAux[nY][nPosCom], "", cTipMat, aColsAux[nY][nPosPer], aColsAux[nY][nPosPEs], cGruMat })
          Next
          If Len(Alltrim(cCodPro)) == 12
             For nY := 1 To Len(aFormula)
                 If aFormula[nY][4] $ 'MP'      //Matéria Prima
                    If aFormula[nY][7] $ '0002' //Resina
                       aadd(aResina, {'RES', 'D', aFormula[nY][2], aFormula[nY][5], aFormula[nY][6], 0, 0, 0, 0, 0, 0, 0, 0, "", 0, "" })
                       fCVolRes(1, aFormula[nY][2], @aSolvent, @aResina, aFormula[nY][5]) //Busca Solventes da Resina
                    ElseIf aFormula[nY][7] $ '0008.0009' //Pigmento ou Carga
                           aadd(aPigmen, {'PIG', 'D', aFormula[nY][2], aFormula[nY][5], aFormula[nY][6], 0, fCAbsOle(aFormula[nY][2]), 0, 0, 0, 0, aFormula[nY][5], (aFormula[nY][5] / aFormula[nY][6]), "", 0, ""} )
                    Endif
                 ElseIf aFormula[nY][4] $ 'PI'  //Produto Intermediário
                        If aFormula[nY][7] $ '0011' //Pasta
                           fBInfPas(aFormula[nY][2], aFormula[nY][5], '01', @aPigmen, @aResina, @aSolvent)
                        Endif 
                 Endif
             Next
             //Reprocessa Matriz de pigmentos para calculos
             For nY := 1 To Len(aPigmen)
                 nPTot += aPigmen[nY][12]
             Next
             For nY := 1 To Len(aPigmen)
                 aPigmen[nY][08] := (aPigmen[nY][12] / nPTot) * 100
                 aPigmen[nY][09] := (aPigmen[nY][08] / 100) * aPigmen[nY][05]
                 aPigmen[nY][10] := (aPigmen[nY][08] / 100) * aPigmen[nY][07]
                 nMMis += aPigmen[nY][09]
                 nMAbs += aPigmen[nY][10]
                 nPVol += aPigmen[nY][13]
             Next
             For nY := 1 To Len(aResina)
                 nVVol += aResina[nY][13]
             Next
             nCalPVC := ((nPVol / (nPVol + nVVol)) * 100)
             nCalBri := (100 - nCalPVC) - (nCalPVC * nMMis) * (nMAbs / 100)
             nCalPVC := Iif(nCalPVC < 0, 0, Iif(nCalPVC > 100, 100, nCalPVC)) 
             nCalBri := Iif(nCalBri < 0, 0, Iif(nCalBri > 100, 100, nCalBri))
          Else
             nCalPVC := 0
             nCalBri := 0
          Endif
       Else
          nCalPVC := 0
          nCalBri := 0
       Endif
Return

/************************************************************************************************/
/*** fCVolRes - Calculo do volume da resina.                                                   ***/
/************************************************************************************************/
Static Function fCVolRes(nTipCal, cCodRes, aSolvent, aResina, nPerFor)
       Local cQry1   := ""
       Local nPerVol := 0
       Local nDenSol := 0
       Local aRefRes := {}
       Local nX
       
       //VOLUME DO SOLVENTE NA RESINA = SOMA DOS PERCENTUAIS UTILIZADOS
       //DENSIDADE DO SOLVENTE NA RESINA = SOMATÓRIA DO PERCENTUAL DE CADA ITEM DIVIDIDO PELO SEU PESO ESPECIFICO
       //Matriz de conversão de resinas entre as filias 01 e 04 (Matriz x Resina)
       aAdd(aRefRes, {'RV100', '0100'}) ; aAdd(aRefRes, {'RV101', '0101'}) ; aAdd(aRefRes, {'RV108', '0108'})
       aAdd(aRefRes, {'RV109', '0149'}) ; aAdd(aRefRes, {'RV110', '0110'}) ; aAdd(aRefRes, {'RV112', '0112'})
       aAdd(aRefRes, {'RV118', '0118'}) ; aAdd(aRefRes, {'RV124', '0124'}) ; aAdd(aRefRes, {'RV127', '0127'})
       aAdd(aRefRes, {'RV130', '0158'}) ; aAdd(aRefRes, {'RV131', '0131'}) ; aAdd(aRefRes, {'RV132', '0132'})
       aAdd(aRefRes, {'RV138', '0138'}) ; aAdd(aRefRes, {'RV139', '0139'}) ; aAdd(aRefRes, {'RV150', '0150'})
       aAdd(aRefRes, {'RV154', '0154'}) ; aAdd(aRefRes, {'RV157', '0157'}) ; aAdd(aRefRes, {'RV160', '0160'})
       aAdd(aRefRes, {'RV161', '0161'}) ; aAdd(aRefRes, {'RV164', '0164'}) ; aAdd(aRefRes, {'RV165', '0165'})
       aAdd(aRefRes, {'RV166', '0166'}) ; aAdd(aRefRes, {'RV169', '0169'}) ; aAdd(aRefRes, {'RV170', '0170'})
       aAdd(aRefRes, {'RV171', '0171'}) ; aAdd(aRefRes, {'RV173', '0173'}) ; aAdd(aRefRes, {'RV180', '0180'})
       aAdd(aRefRes, {'RV181', '0181'}) ; aAdd(aRefRes, {'RV182', '0182'}) ; aAdd(aRefRes, {'RV183', '0183'})
       aAdd(aRefRes, {'RV188', '0188'}) ; aAdd(aRefRes, {'RV189', '0189'}) ; aAdd(aRefRes, {'RV190', '0190'})
       aAdd(aRefRes, {'RV191', '0191'}) ; aAdd(aRefRes, {'RV192', '0192'}) ; aAdd(aRefRes, {'RV193', '0193'})
       aAdd(aRefRes, {'RV194', '0194'}) ; aAdd(aRefRes, {'RV195', '0195'}) ; aAdd(aRefRes, {'RV198', '0198'})
       aAdd(aRefRes, {'RV719', '0719'})
       nPos := aScan(aRefRes, {|x| Alltrim(x[2]) = Alltrim(cCodRes)})
       
       cQry1 := ""
       If !nPos == 0
          If aScan(aSolvent, {|x| x[1] = aRefRes[nPos][1]}) == 0
             cQry1 += "SELECT SG1.G1_COMP AS COMPONENTE, SB1.B1_DESC AS DESCRICAO, SG1.G1_PERC AS PERVOL, (SG1.G1_PERC / SB1.B1_PESOESP) AS DENSOL "
             cQry1 += "FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
             cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SG1.G1_FILIAL = SB1.B1_FILIAL AND SG1.G1_COMP = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
             cQry1 += "WHERE SG1.G1_FILIAL  = '04' " // Sempre Filial 04 para pegar fórmula da Resina
             cQry1 += "  AND SG1.D_E_L_E_T_ = '' "
             cQry1 += "  AND SG1.G1_COD = '"+aRefRes[nPos][1]+"' " //Código da Resina
             cQry1 += "  AND SB1.B1_GRUPO = '"+Alltrim(GETMV("MV_GRPSOLV"))+"' " // Sempre Grupo 0003 para pegar Solventes
             cQry1 += "ORDER BY SG1.G1_COMP "
             TCQuery cQry1 ALIAS "CAL" NEW

             DbSelectArea("CAL")
             DbGoTop()
             While !Eof()
                   aadd(aSolvent, { aRefRes[nPos][1], CAL->COMPONENTE, CAL->DESCRICAO, CAL->PERVOL, CAL->DENSOL })
                   nPerVol += CAL->PERVOL
                   nDenSol += CAL->DENSOL
                   DbSelectArea("CAL")
                   DbSkip()
             Enddo
             DbSelectArea("CAL")
             DbCloseArea()
          Else
             For nX := 1 To Len(aSolvent)
                 If aSolvent[nX][1] == aRefRes[nPos][1]
                    nPerVol += aSolvent[nX][4]
                    nDenSol += aSolvent[nX][5]
                 Endif
             Next
          Endif
          nPesEsp := Posicione("SB1", 1, xFilial("SB1")+cCodRes, "B1_PESOESP")
          aResina[Len(aResina)][06] := (100 - nPerVol)                              // V
          aResina[Len(aResina)][07] := nPerVol                                      // 
          aResina[Len(aResina)][08] := (nPerVol / nDenSol)                          // Ds
          aResina[Len(aResina)][09] := (200 + (aResina[Len(aResina)][08] * 100))    // K
          aResina[Len(aResina)][10] := (200 + (nPesEsp * 100))                      // F
          aResina[Len(aResina)][11] := (aResina[Len(aResina)][06] * aResina[Len(aResina)][08]) / (aResina[Len(aResina)][06] + aResina[Len(aResina)][09] - aResina[Len(aResina)][10])
          If Empty(aResina[Len(aResina)][14])
             aResina[Len(aResina)][12] := (nPerFor * aResina[Len(aResina)][06]) / 100
          Else
             aResina[Len(aResina)][12] := ((aResina[Len(aResina)][15] * nPerFor) / 100) * (aResina[Len(aResina)][06] / 100)
          Endif
          aResina[Len(aResina)][13] := aResina[Len(aResina)][12] / aResina[Len(aResina)][11]
       Endif
Return(nil)

/************************************************************************************************/
/*** fCAbsOle - Busca informações de absorção em óleo do pigmento                              ***/
/************************************************************************************************/
Static Function fCAbsOle(cCodPig)
       Local cQry1   := ""
       Local nValAbs := 0
       
       cQry1 := "" 
       cQry1 += "SELECT ISNULL(QE7.QE7_NOMINA, '0') AS NOMINAL "
       cQry1 += "FROM "+RetSqlName("QE7")+" QE7 WITH (NOLOCK) "
       cQry1 += "WHERE QE7.QE7_FILIAL = '"+xFilial("QE7")+"' "
       cQry1 += "  AND QE7.QE7_PRODUT = '"+cCodPig+"' "
       cQry1 += "  AND QE7.QE7_ENSAIO = 'ENSABO01' " //Sempre utilizar esse ensaio que é o de absorção de óleo
       cQry1 += "  AND QE7.QE7_REVI   = '"+QA_ULTRV(cCodPig, ,.f.)+"' "
       TCQuery cQry1 ALIAS "CAL" NEW
       
       DbSelectArea("CAL")
       nValAbs := Val(CAL->NOMINAL)
       DbSelectArea("CAL")
       DbCloseArea()
       
Return(nValAbs)

/************************************************************************************************/
/*** fBInfPas - Busca informações das pastas                                                  ***/
/************************************************************************************************/
Static Function fBInfPas(cCodPas, nPerPas, cSeq, aPigmen, aResina, aSolvent)
       Local cQry1   := ""
       Local cAlias  := 'PAS'+cSeq
       Local aAuxRes := {}
       Local nX
       Local _cGRPADIT := GETMV("MV_GRPADIT") //LGS#20200210 - Adequação de release 12.1.25 e posteriores
       Local _cGRPPAST := GETMV("MV_GRPPAST") //LGS#20200210 - Adequação de release 12.1.25 e posteriores
       Local _cGRPPIGM := GETMV("MV_GRPPIGM") //LGS#20200210 - Adequação de release 12.1.25 e posteriores
       Local _cGRPCARG := GETMV("MV_GRPCARG") //LGS#20200210 - Adequação de release 12.1.25 e posteriores
       cQry1 := ""
       cQry1 += "SELECT SG1.G1_COMP, SB1.B1_TIPO, SG1.G1_PERC, SB1.B1_PESOESP, SB1.B1_GRUPO "
       cQry1 += "FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 ON SG1.G1_FILIAL = SB1.B1_FILIAL AND SG1.G1_COMP = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SG1.G1_FILIAL  = '"+xFilial("SG1")+"' "
       cQry1 += "  AND SG1.D_E_L_E_T_ = '' "
       cQry1 += "  AND SG1.G1_COD = '"+cCodPas+"' "
       cQry1 += "ORDER BY SG1.G1_TRT "
       TCQuery cQry1 ALIAS &cAlias NEW

       DbSelectArea(cAlias)
       DbGoTop()
       While !Eof()
             If (cAlias)->B1_TIPO $ 'MP'
                //LGS#20200210 - Adequação de release 12.1.25 e posteriores
                //If (cAlias)->B1_GRUPO $ Alltrim(GETMV("MV_GRPADIT")) //aditivos
                If (cAlias)->B1_GRUPO $ Alltrim( _cGRPADIT ) //aditivos
                   If aScan(aAuxRes, {|x| x[1] = (cAlias)->G1_COMP}) == 0
                      aadd(aAuxRes, {(cAlias)->G1_COMP, (cAlias)->G1_PERC, (cAlias)->B1_PESOESP})
                   Else
                      aAuxRes[aScan(aAuxRes, {|x| x[1] = (cAlias)->G1_COMP})][02] += (cAlias)->G1_PERC
                   Endif
                //LGS#20200210 - Adequação de release 12.1.25 e posteriores
                //ElseIf (cAlias)->B1_GRUPO $ Alltrim(GETMV("MV_GRPPIGM")) .or. (cAlias)->B1_GRUPO $ Alltrim(GETMV("MV_GRPCARG")) //Pigmentos e cargas
                ElseIf (cAlias)->B1_GRUPO $ Alltrim( _cGRPPIGM ) .or. (cAlias)->B1_GRUPO $ Alltrim( _cGRPCARG ) //Pigmentos e cargas
                       aadd(aPigmen, {'PIG', 'I', (cAlias)->G1_COMP, (cAlias)->G1_PERC, (cAlias)->B1_PESOESP, 0, fCAbsOle((cAlias)->G1_COMP), 0, 0, 0, 0, (((cAlias)->G1_PERC * nPerPas) / 100), ((((cAlias)->G1_PERC * nPerPas) / 100) / (cAlias)->B1_PESOESP), cCodPas, nPerPas, ""} )
                Endif
             ElseIf (cAlias)->B1_TIPO $ 'PI'
                    //LGS#20200210 - Adequação de release 12.1.25 e posteriores
                    //If (cAlias)->B1_GRUPO $ Alltrim(GETMV("MV_GRPPAST"))
                    If (cAlias)->B1_GRUPO $ Alltrim( _cGRPPAST )
                       //LGS#20200210 - Adequação de release 12.1.25 e posteriores
                       //fBInfPas( (cAlias)->G1_COMP, (cAlias)->G1_PERC, '01', StrZero((Val(cSeq)+1), 2), @aPigmen, @aResina, @aSolvent )
                       fBInfPas( (cAlias)->G1_COMP, (cAlias)->G1_PERC, '01', @aPigmen, @aResina, @aSolvent )
                    Endif 
             Endif
             DbSelectArea(cAlias)
             DbSkip()
       Enddo
       DbSelectArea(cAlias)
       DbCloseArea()
       For nX := 1 TO Len(aAuxRes)
           aadd(aResina, {'RES', 'I', aAuxRes[nX][1], aAuxRes[nX][2], aAuxRes[nX][3], 0, 0, 0, 0, 0, 0, 0, 0, cCodPas, nPerPas, ""})
           fCVolRes(1, aAuxRes[nX][1], @aSolvent, @aResina, aAuxRes[nX][2]) //Busca Solventes da Resina
       Next
Return

/******************************************************************************************************************/
/*** fFichaOP - Imprime a Ficha de Processo do Produto                                                          ***/
/******************************************************************************************************************/
User Function fFichaOp(cCodigo, cRevisao, cDescric)
     Local nLoop
     Private nLinMax := 2800
     Private nColMax := 2350
     Private nLin  :=  0
     Private nCol  := 30

     oFont1 := TFont():New( "Courier New Negrito"        , 9, 19, .F., .T., 5, .T., 5, .F., .F.)
     oFont2 := TFont():New( "Courier New Negrito"        , 9, 12, .F., .T., 5, .T., 5, .F., .F.)
     oFont3 := TFont():New( "Courier New Negrito"        , 9, 11, .F., .T., 5, .T., 5, .F., .F.)
     oFont4 := TFont():New( "Courier New"                , 9, 11, .F., .F., 5, .T., 5, .F., .F.)
     oFont5 := TFont():New( "Courier New Negrito Itálico", 9, 12, .F., .T., 5, .T., 5, .T., .F.)
     oFont6 := TFont():New( "Courier New"                , 9, 08, .F., .F., 5, .T., 5, .F., .F.)

     MsAguarde({|| fBusOper(cCodigo) },"Aguarde","Buscando informações das Operações ...")

     DbSelectArea("TCQ")
     DbGoTop()
     If EOF()
        MsgBox("Não existe roteiro de operações cadastrado para ser impresso !!!", "Atenção", "STOP")
     Else
        AVPRINT oPrn NAME "FICHA DE PROCESSO"
                oPrn:SetPage(9)
                oPrn:SetPortrait()
                AVPAGE
                  fCabFich(cCodigo, cRevisao, cDescric)
                  DbSelectArea("TCQ")
                  While !Eof()
                        oPrn:Say( nLin, nCol+0030, TCQ->G2_OPERAC+' - '+TCQ->G2_DESCRI, oFont3)
                        nLin += 60
                        oPrn:Say( nLin, nCol+0030, TCQ->G2_RECURSO+' - '+SubStr(Posicione("SH1", 1, xFilial("SH1")+TCQ->G2_RECURSO, "H1_DESCRI"), 1, 20), oFont4)
                        nLin += 60
                        cMemo := ""
                        cMemo := MSMM(,80,,Posicione("SG2", 1, xFilial("SG2")+cCodigo+'01'+TCQ->G2_OPERAC, "G2_ESPOP"),,,"SG2",)
                        nMCount := MlCount( cMemo, 80 )
                        If nMCount > 0
                           For nLoop := 1 To nMCount
                               cLinha := ""
                               cLinha := MemoLine( cMemo, 80, nLoop )
                               oPrn:Say( nLin, nCol+0030, StrTran( cLinha, Chr(13)+Chr(10)), oFont4)
                               nLin += 60
                               If nLin >= nLinMax
                                  AVNEWPAGE
                                    nLin := 0
                                    fCabFich(cCodigo, cRevisao, cDescric)
                               Endif  
                           Next
                        Endif
                        fBusEsOp(cCodigo, cRevisao, TCQ->G2_OPERAC)
                        DbSelectArea("PRO")
                        DbGoTop()
                        If !Eof()
                           oPrn:Line(nlin-10, nCol, nlin-10     , nColMax)
                           While !Eof()
                                 // produto de custeio
                                 If U_IsProdCusto(PRO->ZN_COMP)
                                    PRO->(dbSkip())
                                    Loop
                                 Endif 

                                 oPrn:Say(nLin, nCol+0030, PRO->ZN_COMP+' - '+iif(cNumEmp = "01010101","",SubStr(Alltrim(Posicione("SB1", 1, xFilial("SB1")+PRO->ZN_COMP, "B1_DESC")), 1, 30)), oFont4)
                                 oPrn:Say(nLin, nCol+1200, Transform(PRO->ZN_QUANT, "@E 9,999.9999"), oFont4)
                                 oPrn:Say(nLin, nCol+1600, Transform(PRO->ZN_PERC, "@E 999.999%"), oFont4)
                                 oPrn:Say(nLin, nCol+1900, PRO->ZN_TRT, oFont4)
                                 nLin += 60
                                 If nLin >= nLinMax
                                    AVNEWPAGE
                                      nLin := 0
                                      fCabFich(cCodigo, cRevisao, cDescric)
                                 Endif  
                                 DbSelectArea("PRO")
                                 DbSkip()
                           Enddo
                        Endif
                        DbSelectArea("PRO")
                        DbCloseArea()
                        
                        oPrn:Line(nlin-09, nCol, nlin-09     , nColMax)
                        oPrn:Line(nlin-10, nCol, nlin-10     , nColMax)
                        oPrn:Line(nlin-11, nCol, nlin-11     , nColMax)
                        nLin += 20
                        If nLin >= nLinMax
                           AVNEWPAGE
                             nLin := 0
                             fCabFich(cCodigo, cRevisao, cDescric)
                        Endif  
                        DbSelectArea("TCQ")
                        DbSkip()
                  Enddo
                AVENDPAGE
        AVENDPRINT
        MS_FLUSH()
     Endif
     DbSelectArea("TCQ")
     DbCloseArea()
     If lFiltro
        U_PCPX01_6(1)
     Endif
Return

/******************************************************************************************************************/
/*** fBusOper - Busca Operações do produto a ser impresso.                                                      ***/
/******************************************************************************************************************/
Static Function fBusOper(cCodigo)
       Local cQry := ""
       cQry := ""
       cQry += "SELECT * "
       cQry += "FROM "+RetSqlName("SG2")+" SG2 WITH (NOLOCK) "
       cQry += "WHERE SG2.G2_FILIAL  = '"+xFilial("SG2")+"' "
       cQry += "  AND SG2.G2_PRODUTO = '"+cCodigo+"' "
       cQry += "  AND SG2.D_E_L_E_T_ = '' "
       cQry += "ORDER BY SG2.G2_OPERAC "
       TCQUERY cQry ALIAS "TCQ" NEW
Return

/******************************************************************************************************************/
/*** fCabFich - Imprime cabeçalho da Ficha de Processo.                                                         ***/
/******************************************************************************************************************/
Static Function fCabFich(cCodigo, cRevisao, cDescric)
       nLin += 030 //Linha 030
       oPrn:Box( nLin, nCol     , nLin+120, nColMax ) // Box da Linha 030 até a 120 - 090 Linhas
       nLin += 030 //Linha 060
       oPrn:Say( nLin, nCol+0400, "F I C H A    D E    P R O C E S S O", oFont1) //Linha 60
       oPrn:Say( nLin+050, nCol+1950, dtoc(dDataBase)+' - '+Time(), oFont6) //Linha 110
       nLin += 100 //Linha 160
       oPrn:Box( nLin, nCol     , nLin+120, nColMax ) // Box da Linha 160 até a 280 - 120 Linhas
       nLin += 010 //Linha 170
       oPrn:Say( nLin, nCol+030 , "PRODUTO:", oFont2) //Linha 170
       oPrn:Say( nLin, nCol+300 , Alltrim(cCodigo)+' - '+Alltrim(cDescric)+Iif(Len(AllTrim(cCodigo)) == 12, ' / '+SubStr(Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodigo,4,2), "Z1_DESCR"), 1, 25), ''), oFont5) //Linha 170
       nLin += 060 //Linha 230
       oPrn:Say( nLin, nCol+030 , "REVISÃO:", oFont2) //Linha 230
       oPrn:Say( nLin, nCol+300 , U_fBusUlRv(cCodigo), oFont5)
       nLin += 080 //Linha 290
Return

/******************************************************************************************************************/
/*** fBusEsOp - Busca estrutura do produto por operação.                                                        ***/
/******************************************************************************************************************/
Static Function fBusEsOp(cCodigo, cRevisao, cOperacao)
       Local cQry := ""
       
       cQry := ""
       cQry += "SELECT * "
       cQry += "FROM "+RetSqlName("SZN")+" SZN WITH (NOLOCK) "
       cQry += "WHERE SZN.ZN_FILIAL = '"+xFilial("SZN")+"' "
       cQry += "  AND SZN.D_E_L_E_T_ = '' "
       cQry += "  AND SZN.ZN_CODIGO = '"+cCodigo+"' "
       cQry += "  AND SZN.ZN_REVISAO = '"+cRevisao+"' "
       cQry += "  AND SZN.ZN_OPERACA = '"+cOperacao+"' "
       cQry += "ORDER BY SZN.ZN_OPERACA, SZN.ZN_TRT "
       TCQUERY cQry ALIAS "PRO" NEW
Return

/******************************************************************************************************************/
/*** fBusUlRv - Busca ultima revisão válida do produto.                                                         ***/
/******************************************************************************************************************/
User Function fBusUlRv(cCodigo)
     Local cQry1 := ""
     Local cRet  := ""
     
     cQry1 += "SELECT TOP 1 SZM.ZM_REVISAO, SZM.ZM_RESPONS, SZM.ZM_ID, SZT.ZT_DATAGER "
     cQry1 += "FROM "+RetSqlName("SZM")+" SZM WITH (NOLOCK) "
     cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZT")+" SZT WITH (NOLOCK) ON SZM.ZM_FILIAL = SZT.ZT_FILIAL AND SZM.ZM_ID = SZT.ZT_ID AND SZT.D_E_L_E_T_ = '' AND SZT.ZT_STATUS = 'AC' "
     cQry1 += "WHERE SZM.ZM_FILIAL  = '"+xFilial("SZM")+"' "
     cQry1 += "  AND SZM.D_E_L_E_T_ = '' "
     cQry1 += "  AND SZM.ZM_CODIGO  = '"+cCodigo+"' "
     cQry1 += "  AND SZM.ZM_STATUS  = 'AC' "
     cQry1 += "ORDER BY SZM.ZM_REVISIN "
     TCQuery cQry1 ALIAS "TREV" NEW
     DbSelectArea("TREV")
     cRet += TREV->ZM_REVISAO+' - VIGÊNCIA: '+SubStr(TREV->ZT_DATAGER, 7, 2)+'/'+SubStr(TREV->ZT_DATAGER, 5, 2)+'/'+SubStr(TREV->ZT_DATAGER, 1, 4)+' RESPONSAVEL: '+Iif(Upper(Alltrim(TREV->ZM_RESPONS)) $ 'ADMINISTRADOR', 'IMPLANTAÇÃO', Alltrim(TREV->ZM_RESPONS) )
     DbSelectArea("TREV")
     DbCloseArea()
Return(cRet)

/******************************************************************************************************************/
/*** fMonOper - Monta estrutura de operações do produto.                                                        ***/
/******************************************************************************************************************/
User Function fMonOper(nOpc, cCodigo, cRevisao, cDescri)
     Local nOpca     := 0
     Local nOpcX     := Iif(nOpc == 1 .or. nOpc == 2, 2, 3)
     //Local aObjects  := {}
     //Local aSize     := {}
     //Local aInfo     := {}
     //Local aPosObj   := {}
     Local cRoteiro  := Iif(Empty(Posicione("SB1", 1, xFilial("SB1")+cCodigo, "B1_OPERPAD")), '01', Posicione("SB1", 1, xFilial("SB1")+cCodigo, "B1_OPERPAD"))
     Local cLinhaOk  := Iif(nOpc == 1 .or. nOpc == 2, "AllWaysTrue()", "fVlLOpe()")
     Local cTudoOOk  := Iif(nOpc == 1 .or. nOpc == 2, "AllWaysTrue()", "fVlTOpe()")
     Private aHeader := {}
     Private aCols   := {}
     
     fMatOper(@aCols, @aHeader, cRoteiro, cCodigo)

     DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Roteiro de Operações") PIXEL FROM 120, 0 TO 500, 720 OF oMainWnd
            //@ 15, 003 TO 035, 357              PIXEL
            @ 11, 007 SAY OemToAnsi("Roteiro")                     SIZE 020,07          PIXEL OF oDlg1
            @ 10, 030 MSGET cRoteiro PICTURE "@!"                  SIZE 015,10 WHEN .F. PIXEL OF oDlg1
            @ 11, 055 SAY OemToAnsi("Produto")                     SIZE 020,07          PIXEL OF oDlg1
            @ 10, 080 MSGET cCodigo  PICTURE "@R! XXX99.99.999.99" SIZE 050,10 WHEN .F. PIXEL OF oDlg1
            @ 11, 140 SAY OemToAnsi("Revisão")                     SIZE 020,07          PIXEL OF oDlg1
            @ 10, 165 MSGET cRevisao PICTURE "999"                 SIZE 015,10 WHEN .F. PIXEL OF oDlg1
            @ 11, 195 SAY OemToAnsi("Descrição")                   SIZE 025,07          PIXEL OF oDlg1
            @ 10, 225 MSGET cDescri  PICTURE "@!"                  SIZE 100,10 WHEN .F. PIXEL OF oDlg1
            
            oGetO := MSGetDados():New(038, 003, 187, 357, nOpcx, cLinhaOk, cTudoOOk, "", (nOpcx <> 2),,,, 30)
            
            oDlg1:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     If nOpc == 1 .or. nOpc == 2
        ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| nOpca := 0,  oDlg1:End() }, {|| oDlg1:End() } ) CENTERED
     Else
        //TRATAMENTO QDO FOR REESCREVER INCLUSAO / ALTERAÇÃO
        ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| nOpca := 1, If(oGetO:TudoOk(), oDlg1:End(), nOpca := 0)}, {|| oDlg1:End() } ) CENTERED
     Endif
Return

/******************************************************************************************************************/
/*** fMatOper - Monta matriz aCols e aHeader para o roteiro do produto.                                         ***/
/******************************************************************************************************************/
Static Function fMatOper(aCols, aHeader, cRoteiro, cCodigo)
       Local nUsado := 0
       Local nY, nX
       Local _lOpen        := .F. //LGS#20200210 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200210 - Adequação para release 12.1.25
     
       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200210 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0

       If !_lOpen //LGS#20200210 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SG2")
       While !Eof() .And. (X3_ARQUIVO == "SG2")
             If X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .And. Trim(X3_CAMPO) != "G2_PRODUTO"
                nUsado++
                aAdd(aHeader,{ TRIM(( _cAliasSX3 )->( X3_TITULO )), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
             EndIf
             DbSkip()
       EndDo*/

       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("SG2") )
       While !Eof() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SG2")
             If X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .AND. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .And. Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) != "G2_PRODUTO"
                nUsado++
                aAdd(aHeader,{ TRIM( ( _cAliasSX3 )->( X3_TITULO ) ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
             EndIf
             DbSkip()
       EndDo
       /********************************************************************************************************************************/
       DbSelectArea("SG2")
       DbSetOrder(1)
       DbSeek(xFilial("SG2")+cCodigo+cRoteiro, .t.)
       If Found()
          While !Eof() .and. SG2->G2_CODIGO == cRoteiro .and. SG2->G2_PRODUTO == cCodigo
                aAdd(aCols, Array(nUsado + 1))
                For nY := 1 To nUsado
                    If Alltrim(aHeader[nY][2]) $ "G2_OPERAC"
                       aCols[Len(aCols)][nY] := SG2->G2_OPERAC
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_RECURSO"
                           aCols[Len(aCols)][nY] := SG2->G2_RECURSO
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_FERRAM"
                           aCols[Len(aCols)][nY] := SG2->G2_FERRAM
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_LINHAPR"
                           aCols[Len(aCols)][nY] := SG2->G2_LINHAPR
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_TPLINHA"
                           aCols[Len(aCols)][nY] := SG2->G2_TPLINHA
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_DESCRI"
                           aCols[Len(aCols)][nY] := SG2->G2_DESCRI
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_MAOOBRA"
                           aCols[Len(aCols)][nY] := SG2->G2_MAOOBRA
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_FERRAMEN"
                           aCols[Len(aCols)][nY] := SG2->G2_FERRAMEN
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_SETUP"
                           aCols[Len(aCols)][nY] := SG2->G2_SETUP
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_FORMSTP"
                           aCols[Len(aCols)][nY] := SG2->G2_FORMSTP
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_LOTEPAD"
                           aCols[Len(aCols)][nY] := SG2->G2_LOTEPAD
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_TEMPAD"
                           aCols[Len(aCols)][nY] := SG2->G2_TEMPAD
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_TPOPER"
                           aCols[Len(aCols)][nY] := SG2->G2_TPOPER
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_TPSOBRE"
                           aCols[Len(aCols)][nY] := SG2->G2_TPSOBRE
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_TPDESD"
                           aCols[Len(aCols)][nY] := SG2->G2_TPDESD
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_TEMPDES"
                           aCols[Len(aCols)][nY] := SG2->G2_TEMPDES
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_DESPROP"
                           aCols[Len(aCols)][nY] := SG2->G2_DESPROP
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_CTRAB"
                           aCols[Len(aCols)][nY] := SG2->G2_CTRAB
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_ROTALT"
                           aCols[Len(aCols)][nY] := SG2->G2_ROTALT
                    ElseIf Alltrim(aHeader[nY][2]) $ "G2_ESPOP"
                           aCols[Len(aCols)][nY] := SG2->G2_ESPOP
                    Endif
                Next
                aCols[Len(aCols)][nUsado+1] := .f.
                DbSelectArea("SG2")
                DbSkip()
          Enddo
       Else
          aAdd(aCols, Array(nUsado + 1))
          For nX := 1 To nUsado
              If Trim(aHeader[nX][2]) $ 'G2_OPERAC'
                 aCols[Len(aCols)][nX] := '01'
              Else
                 aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2])
              Endif
           Next
           aCols[Len(aCols)][nUsado + 1] := .F.
       Endif
       DbSelectArea( _cAliasSX3 )
       DbCloseArea()
Return

/******************************************************************************************************************/
/*** fIncEmba - Monta entrada e manutenção de embalagens para os produtos tintas.                               ***/
/******************************************************************************************************************/
User Function fIncEmba(nOpc, cCodigo, cRevisao, cTipoPro)
       Local nOpcb     := 0
       Local nOpcG     := Iif(nOpc == 1 .or. nOpc == 2, 2              , 3          )
       Local cTudoOk   := Iif(nOpc == 1 .or. nOpc == 2, "AllwaysTrue()", "fTudInc()")
       Local aAltGet   := Iif(nOpc == 1 .or. nOpc == 2, {}             , {"ZP_EMB"} )
       Private aHeader := {}
       Private aCols   := {}
       
       fMatEmba(@aHeader, @aCols, cCodigo, cRevisao, cTipoPro)
       
       DEFINE MSDIALOG oDlgE TITLE OemToAnsi("Embalagens") From 9,0 to 20,50 of oMainWnd
              oGetE := MsGetDados():New( 15, 1, 80, 195, nOpcG, "AllwaysTrue()", cTudoOk, "", .T., aAltGet, nOpcG, , 10, "AllwaysTrue()")
       ACTIVATE MSDIALOG oDlgE ON INIT EnchoiceBar(oDlgE, {|| nOpcb := 1, If(oGetE:TudoOk(), oDlgE:End(), nOpcb := 0)},{|| oDlgE:End() } ) CENTERED
       If nOpcb == 1
          //TRATAMENTO DESSA ROTINA DEVERÁ OCORRER QDO FOR REFORMULADO A INCLUSAO / ALTERACAO.
       Endif
Return

/******************************************************************************************************************/
/*** fMatEmba - Monta as matrizes aCols e aHeader para a manutenção das embalagens.                             ***/
/******************************************************************************************************************/
Static Function fMatEmba(aHeader, aCols, cCodigo, cRevisao, cTipoPro)
       Local nUsado := 0
       //Local cQry1  := ""
       Local lAchou :=.F.
       Local nX
       Local _lOpen        := .F. //LGS#20200210 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200210 - Adequação para release 12.1.25
     
       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200210 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0

       If !_lOpen //LGS#20200210 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SZP")
       While !Eof() .And. (X3_ARQUIVO == "SZP")
             IF X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. !(TRIM(X3_CAMPO) $ "ZP_FILIAL") .And. !(TRIM(X3_CAMPO) $ "ZP_CODIGO") .And. !(TRIM(X3_CAMPO) $ "ZP_REVISAO")
	            nUsado := nUsado+1
	            AADD(aHeader, { Trim(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
             EndIf
             dbSkip()
       Enddo*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("SZP") )
       While !Eof() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SZP" )
             IF X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .And. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .And. !( TRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZP_FILIAL") .And. !( TRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZP_CODIGO") .And. !( TRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZP_REVISAO")
	            nUsado := nUsado+1
	            AADD(aHeader, { Trim( ( _cAliasSX3 )->( X3_TITULO ) ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
             EndIf
             ( _cAliasSX3 )->( dbSkip( ) )
       Enddo
       
	   If ChkFile("TMPSZP")
	       DbSelectArea("TMPSZP")
		   DbCloseArea()
       Endif
                  
       /********************************************************************************************************************************/
       // PROCURAR PRIMEIRO NA SZP 
       cQry1 := "SELECT DISTINCT ZP_FILIAL, ZP_CODIGO, ZP_EMB "
       cQry1 += "FROM "+RetSqlName("SZP")+" SZP WITH (NOLOCK) "
       cQry1 += "WHERE (SZP.ZP_FILIAL  = '"+xFilial("SZP")+"') "
       cQry1 += "AND (SZP.D_E_L_E_T_ = '') "
       cQry1 += "AND (SZP.ZP_CODIGO ='"+Alltrim(cCodigo)+"') "
       cQry1 += "ORDER BY SZP.ZP_EMB "

       TCQuery cQry1 ALIAS "TMPSZP" NEW
       DbSelectArea("TMPSZP")
       DbGoTop()
       
      While !Eof() .and. (xFilial("SZP") == TMPSZP->ZP_FILIAL) .and. (Alltrim(cCodigo) == Alltrim(TMPSZP->ZP_CODIGO))
         lAchou :=.t.
		   aAdd(aCols, Array(nUsado + 1) )
		   For nX := 1 to nUsado
			   If aHeader[nX][10] $ "R"
               aCols[Len(aCols)][nX] := Alltrim(TMPSZP->ZP_EMB)
            ElseIf aHeader[nX][10] $ "V"
               aCols[Len(aCols)][nX] := Posicione("SZ5", 1, xFilial("SZ5")+aCols[Len(aCols)][1], "Z5_DESCR")
            Endif
      	Next
         aCols[Len(aCols)][nUsado + 1] := .f.
         DbSelectArea("TMPSZP")
         DbSkip()
      Enddo
   
      
      If !lAchou
       
	       DbSelectArea("SZP")
    	   DbSetOrder(1)
	       DbSeek(xFilial("SZP")+cCodigo+cRevisao,.t.)
	       If Found()
    	   	   While !Eof() .and. (xFilial("SZP") == SZP->ZP_FILIAL) .and. (Alltrim(cCodigo) == Alltrim(SZP->ZP_CODIGO)) .and. (cRevisao == SZP->ZP_REVISAO)
    	           aAdd(aCols, Array(nUsado + 1) )
	               For nX := 1 to nUsado
        	       	   If !aHeader[nX][2] ==  'ZP_DESCEMB'
            	           aCols[Len(aCols)][nX] := FieldGet(FieldPos(aHeader[nX][2]))
                	   Else
	                       aCols[Len(aCols)][nX] := Posicione("SZ5", 1, xFilial("SZ5")+aCols[Len(aCols)][1], "Z5_DESCR")
    	               Endif
        	       Next
            	   aCols[Len(aCols)][nUsado + 1] := .f.
	               DbSelectArea("SZP")
    	           DbSkip()
        	   Enddo
	       ElseIf cTipoPro $ "PE"
    	          DbSelectArea("SB1")
        	      DbSetOrder(1)
            	  DbSeek(xFilial("SB1")+cCodigo,.t.)
	              If Found()
    	             While !Eof() .and. (SB1->B1_FILIAL == XFilial("SB1")) .and. (SubStr(Alltrim(SB1->B1_COD), 1, 10) == SubStr(Alltrim(cCodigo), 1, 10))
        	               If !SubStr(Alltrim(SB1->B1_COD),11,02) == "00"
            	              aAdd(aCols, Array(nUsado + 1) )
                	          For nX := 1 to nUsado
                    	          If aHeader[nX][10] $ "R"
                        	         aCols[Len(aCols)][nX] := SubStr(SB1->B1_COD,11,02)
                            	  ElseIf aHeader[nX][10] $ "V"
	                               	 aCols[Len(aCols)][nX] := Posicione("SZ5", 1, xFilial("SZ5")+aCols[Len(aCols)][1], "Z5_DESCR")
    	                          Endif
	                          Next
    	                      aCols[Len(aCols)][nUsado + 1] := .f.
        	               Endif
            	           DbSelectArea("SB1")
                	       DbSkip()
	                 Enddo
    	          Else
        	         aAdd(aCols, Array(nUsado + 1) )
            	     For nX := 1 to nUsado
                	     If aHeader[nX][10] $ "R"
                    	    aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2])
	                     ElseIf aHeader[nX][10] $ "V"
    	                        aCols[Len(aCols)][nX] := ""
        	             Endif
            	     Next
	                 aCols[Len(aCols)][nUsado + 1] := .f.
    	          Endif
	       Else
    	      aAdd(aCols, Array(nUsado + 1) )
	          For nX := 1 to nUsado
	              If aHeader[nX][10] $ "R"
    	             aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2])
        	      ElseIf aHeader[nX][10] $ "V"
            	         aCols[Len(aCols)][nX] := ""
	              Endif
    	      Next
        	  aCols[Len(aCols)][nUsado + 1] := .f.
	       Endif

	   Endif
       aSort(aCols ,,,{|x,y| x[1] < y[1] })

       DbSelectArea( _cAliasSX3 )
       DbCloseArea()
      DbSelectArea("TMPSZP")

Return

/******************************************************************************************************************/
/*** fCCusPro - Função recursiva para calculo do custo de um PI.                                                ***/
/******************************************************************************************************************/
User Function fCCusPro(cComp, cRev)

     Local nCusto  := 0
     Local cQry    := ""
             
     If cRev == Nil  //.or. (Len(Alltrim(cComp) ==12) .and. (Substr(Alltrim(cComp),11,2) $ '00.99'))
	     cQry := "SELECT dbo.CustoMp('"+xFilial("SG1")+"','"+cComp+"',1) AS CUSTO" // CUSTO SEM M.O   
	 Else	    
//     	If Substr(cComp,11,2) $ '00.99' .AND. LEN(Alltrim(cComp)==12 
	     	cQry := "SELECT dbo.CustoMpSZN('"+xFilial("SZN")+"','"+cComp+"',1,'"+cRev+"') AS CUSTO"    // CUSTO SEM M.O
     	//cQry := "SELECT dbo.CustoProSZN('"+xFilial("SZN")+"','"+cComp+"',1,'"+cRev+"') AS CUSTO" // CUSTO COM M.O  
 	 Endif 
 	
	 cAlias := "TC00"
     DbUseArea(.T., "TOPCONN", TcGenQry( , , cQry), cAlias, .T., .T.)
     DbSelectArea(cAlias)
     DbGoTop()
     If !eof() .and. !bof()
     	nCusto := (cAlias)->CUSTO
       	//If (Substr(cComp,11,2) $ '00.99' .AND. LEN(Alltrim(cComp))==12 .and. !cRev == Nil) REMOVER CUSTO DE M.O PRA CUSTOPROSZN
     	//   	nCusto := nCusto - Iif(Len(Alltrim(cComp)) == 12, Posicione("SZ5", 1, xFilial("SZ5")+SubStr(cComp, 11, 02), "Z5_VOLUME") * Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cComp, 04, 02), "Z1_VLRMO"), Posicione("SB1", 1, xFilial("SB1")+cComp, "B1_VLRMO"))
     	//Endif   
     Endif 

     DbSelectArea(cAlias)
     DbCloseArea()

Return(nCusto)

/******************************************************************************************************************/
/*** fCPrcVen - Função para calculo do preço de venda.                                                          ***/
/******************************************************************************************************************/
User Function fCPrcVen(cCodPro, cRevPro, cTipPro)
	 Local cPlanilha := Iif(cNumEmp = "01010101","BRASILUX",Iif(cNumEmp = "01010104","RESINA",Iif(cNumEmp = "01060101","DISSOLTE",Iif(cNumEmp = "05","UNIONSUR","SEMPLANI"))))+".pdv" //Variável que guarda o nome da planilha para calculo do preço
	 Local nAbrArq   := fOpen(cPlanilha)                                                          //Variável que indica se o arquivo foi aberto
	 Local nTamArq   := 0
	 Local nLidos    := 0
	 Local nUsado    := 0
	 Local cLinha    := ""
	 Local lOk       := .f.
	 Local aAux      := {}
	 //Local cVar      := ""
	 Local nJuros    := GETMV("MV_JUROS")
	 Local nIcms     := GETMV("MV_ICMPAD")
	 Local nCusPro   := 0
	 Local nMDOPro   := 0
	 Local nTotCus   := 0
     Local nLucPro   := 0
     Local nComVen   := 0
	 Local nQtdPar   := 0
	 Local nTaxJur   := 0
	 Local nPrcVen   := 0
	 Local nPrazo   := 0
	 Local nY
	 Private aPrazos := {}

	 If SubStr(cNumEmp, 1, 2) = "05"
		cPlanilha := "UNIONSUR.PDV"
	 Endif 
//     aAdd(aPrazos, GETMV("MV_PRZPRC"))

     nPrazo := GETMV("MV_PRZPRC")

     If nAbrArq > 0
        FSeek(nAbrArq, 0, 0)
        nTamArq := FSeek(nAbrArq, 0, 2)
        FSeek(nAbrArq, 0, 0)
        While nLidos < nTamArq
              cLinha := U_fGets(nAbrArq, nTamArq)
              If SubStr(cLinha, 6, 3) $ "PIS_IVA"
                 lOk := .t.
              Endif
              If lOk
                 nUsado += 1
                 aadd(aAux, { "V"+Alltrim(Str(nUsado)), U_cTon(Alltrim(SubStr(cLinha, 36, 10))) })
              Endif
              If SubStr(cLinha, 6, 16) == "DESP. COMERCIAIS"
                 lOk = .f.
              Endif
              nLidos += Len(cLinha) + 2
        EndDo
        fClose(nAbrArq)
     Else
        MsgBox("Não foi possível abrir a planilha "+cPlanilha, "Atenção...", "STOP")
        Return 
     Endif
     nCusPro := Iif(cTipPro $ 'REV', U_fCCusPro(cCodPro, cRevPro), U_fCCusPro(cCodPro,Nil))
     nMDOPro := fCOutVal(1, cCodPro, cRevPro, cTipPro) // RETIRADO CALCULO DA MÃO DE OBRA, PQ ESTA INCLUSO NO CUSTO DO PRODUTO
     nLucPro := fCOutVal(2, cCodPro, cRevPro, cTipPro)
     nComVen := fCOutVal(3, cCodPro, cRevPro, cTipPro)
     nTotCus := nCusPro + nMDOPro
     nPerApl := nIcms + nLucPro + nComVen
     
     nQtdPar := 1 //Len(aPrazos)
     nTaxJur := 0
//     For i := 1 to nQtdPar
         nTaxJur += 1 / ((1 + (nJuros / 100)) ^ ((12 * nPrazo) / 365))
//     Next
//     nTaxJur := (1 / nQtdPar) * nTaxJur
     For nY := 1 to LEn(aAux)
         nPerApl += aAux[nY][2]
     Next

     nPrcVen := nTotCus / (nTaxJur - (nPerApl / 100))
Return(nPrcVen)

/******************************************************************************************************************/
/*** fCOutVal - Função para buscar valores no calculo do preço do produto.                                      ***/
/******************************************************************************************************************/
Static Function fCOutVal(nOpc, cCodPro, cRevPro, cTipPro)
       Local nVlrMov := 0
       Local _cOpc := "XX"
       Private aArray := Array(1, 4) //Array com Produto, para fins de calc prc tabela, usado tb nas planilhas
       aArray[1][4] := cCodPro
      
       	If nOpc == 1     //Mão de Obra    
       		_cOpc := "MO"
          	//nVlrMov := Iif(Len(Alltrim(cCodPro)) == 12, Posicione("SZ5", 1, xFilial("SZ5")+SubStr(cCodPro, 11, 02), "Z5_VOLUME") * Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodPro, 04, 02), "Z1_VLRMO"), Posicione("SB1", 1, xFilial("SB1")+cCodPro, "B1_VLRMO"))
       	ElseIf nOpc == 2 //Lucro     
       		_cOpc := "LU"
          	//nVlrMov := Iif(Len(Alltrim(cCodPro)) == 12, Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodPro, 4, 2), "Z1_LUCRO"), Posicione("SB1", 1, xFilial("SB1")+cCodPro, "B1_LUCRO"))
       	ElseIf nOpc == 3 //Comissão
       		_cOpc := "CO"
          	//nVlrMov := Iif(Len(Alltrim(cCodPro)) == 12, Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodPro, 4, 2), "Z1_COMISSA"), Posicione("SB1", 1, xFilial("SB1")+cCodPro, "B1_COMIS"))
       	Endif
		nVlrMov := EXECBLOCK("BRPCP011",.F.,.F.,_cOpc)
       
Return(nVlrMov)

/******************************************************************************************************************/
/*** fAjuOper - Função para buscar valores no calculo do preço do produto.                                      ***/
/******************************************************************************************************************/
User Function fAjuOper()
     Processa({|| ProcOper()}, "Processa Ajuste de Operação")
Return

/******************************************************************************************************************/
/*** ProcOper - Função para gravar roteiro padrão para produtos.                                                ***/
/******************************************************************************************************************/
Static Function ProcOper()
       Local cQry1   := ""
       Local aMatInc := {}
       Local nX
       Local _cGRPPAST := GETMV("MV_GRPPAST") //LGS#20200210 - Adequação de release 12.1.25 e posteriores
       Local _cGRPSOLU := GETMV("MV_GRPSOLU") //LGS#20200210 - Adequação de release 12.1.25 e posteriores

       cQry1 += "SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_TIPO, SB1.B1_GRUPO "
       cQry1 += "FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "
       cQry1 += "WHERE SB1.B1_FILIAL  = '"+xFilial("SB1")+"' "
       cQry1 += "  AND SB1.D_E_L_E_T_ = '' "
       cQry1 += "  AND SB1.B1_OPERPAD = '' "
       cQry1 += "  AND SB1.B1_TIPO   IN('PA','PI') "
       cQry1 += "ORDER BY SB1.B1_COD "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       ProcRegua(20000)
       While !Eof()
             IncProc("Processando: "+TCQ->B1_COD)
             DbSelectArea("SG2")
             DbSetOrder(1)
             DbSeek(xFilial("SG2")+TCQ->B1_COD, .t.)
             If !Found()
                 If TCQ->B1_TIPO $ 'PI'
                 	If Len(Alltrim(TCQ->B1_COD)) == 12 .or. Len(Alltrim(TCQ->B1_COD)) == 5 .or. Len(Alltrim(TCQ->B1_COD)) == 6
                    	lSemIns := .f.
                      	cCodRev := ""
                      	DbSelectArea("QP6")
                      	DbSetOrder(1)
                      	DbSeek(xFilial("QP6")+TCQ->B1_COD, .t.)
                      	If Found()
                        	DbSelectArea("QQK")
                         	DbSetOrder(1)
                         	DbSeek(xFilial("QQK")+TCQ->B1_COD, .t.)
                         	If !Found()
                            	lSemIns := .t.
                         	Endif
                         	cCodRev := QP6->QP6_REVI
                      	Endif
                    	If LEN(ALLTRIM(TCQ->B1_COD))==12 .and. !(Substr(TCQ->B1_COD,4,2) $ ('08.41.42.43.44.46.47.48.49.52.54.57.90'))
	                      
    	                  //              G2_FILIAL *    G2_CODIGO*  G2_PRODUTO*  G2_OPERAC*  G2_RECURSO     G2_FERRAM   G2_LINHAPR  G2_TPLINHA  G2_DESCRI*          G2_MAOOBRA
        	              //              G2_SETUP       G2_FORMSTP  G2_LOTEPAD   G2_TEMPAD*  G2_TPOPER*     G2_TPSOBRE  G2_TEMPSOB  G2_TPDESD   G2_TEMPDES          G2_DESPROP
            	          //              G2_CTRAB  *    G2_OPE_OBR  G2_SEQ_OBR   G2_LAU_OBR  G2_REVIPRD*    G2_CHAVE    G2_ROTALT   G2_OPERGRP  G2_ESPOP            G2_GRSETUP
                	      //              G2_GRUPREC     G2_NIVMONT  G2_CHAVMON   G2_TMAXPRO  G2_TPINTER     G2_MAXINCR  G2_FOLMIN   G2_HOROTIM  G2_FULTREV          D_E_L_E_T_* 
                    	  //              R_E_C_N_O_*
             	        	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '01'      , '000002'     , ''        , ''        , ''        , 'PESAGEM'         , 0.0        ,;
                	                     0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
                    	                 'CTTN01'      , ''        , ''         , ''        , cCodRev      , ''        , ''        , ''        , 'PESAR MATERIAIS' , ''         ,;
                        	             ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
                            	         000000        , "SG2"})
 	                     	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '02'      , '000015'     , ''        , ''        , ''        , 'TINGIMENTO'      , 0.0        ,;
    	                                 0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
        	                             'CTTN03'      , ''        , ''         , ''        , cCodRev      , ''        , ''        , ''        , 'TINGIR PRODUTO'  , ''         ,;
            	                         ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
                	                     000000        , "SG2"})
                    	 	If !Empty(cCodRev)
                        		aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '90'      , '000013'     , ''        , ''        , ''        , 'CONTROLE QUALIDADE' , 0.0        ,;
	                                        0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0                  , ''         ,;
    	                                    'CTGR01'      , 'S'       , 'S'        , 'S'       , cCodRev      , ''        , ''        , ''        , 'INSPECIONAR'        , ''         ,;
        	                                ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                   , ''         ,;
            	                            000000        , "SG2"})
                	     	Endif
                    	 	If lSemIns
	                        	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '01'      , '000002'     , ''        , ''        , ''        , 'PESAGEM'         , 0.0        ,;
    	                                    0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
        	                                'CTTN01'      , ''        , ''         , ''        , cCodRev      , ''        , ''        , ''        , 'PESAR MATERIAIS' , ''         ,;
            	                            ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
                	                        000000        , "QQK"})
                    	     	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '02'      , '000015'     , ''        , ''        , ''        , 'TINGIMENTO'      , 0.0        ,;
                        	                0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
	                           	            'CTTN03'      , ''        , ''         , ''        , cCodRev      , ''        , ''        , ''        , 'TINGIR PRODUTO'  , ''         ,;
    	                                    ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
        	                                000000        , "QQK"})
            	             	If !Empty(cCodRev)
                	            	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '90'      , '000013'     , ''        , ''        , ''        , 'CONTROLE QUALIDADE' , 0.0        ,;
                    	                       0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0                  , ''         ,;
                        	                   'CTGR01'      , 'S'       , 'S'        , 'S'       , cCodRev      , ''        , ''        , ''        , 'INSPECIONAR'        , ''         ,;
                            	               ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                   , ''         ,;
                                	           000000        , "QQK"})
	                         	Endif
    	                 	Endif
    	         		ElseIf LEN(ALLTRIM(TCQ->B1_COD))==12 .and. (Substr(TCQ->B1_COD,4,2) $ ('08.41.42.43.44.46.47.48.49.52.54.57.90')) // LINHAS LATEX - NOVO CADASTRO DE OPERAÇÕES E INSPEÇÃO DE PROCESSOS LINHAS AFETADAS (08,41,42,43,44,46,47,48,49,52,54,57,90) CONF SOLIC MARCOS PELEGRINI 
/*
OPERAÇÃO '01','PESAR E ADICIONAR CO'
OPERAÇÃO '02','ADICIONAR SACARIAS  '
OPERAÇÃO '03','DISPERSAR POR 45 MIN'
OPERAÇÃO '04','ACERTO DE COR       '  
OPERAÇÃO '90','CONTROLE QUALIDADE  ' */
	                    	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '01'      , '000002'     , ''        , ''        , ''        , 'PESAR E ADICIONAR CO', 0.0        ,;
    	                                 0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
        	                             'CTTN01'      , ''        , ''         , ''        , cCodRev      , ''        , ''        , ''        , 'PESAR E ADICIONAR CO', ''         ,;
            	                         ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
                	                     000000        , "SG2"})
                    	  	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '02'      , '000002'     , ''        , ''        , ''        , 'ADICIONAR SACARIAS  ', 0.0        ,;
	                                     0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
    	                                 'CTTN01'      , ''        , ''         , ''        , cCodRev      , ''        , ''        , ''        , 'ADICIONAR SACARIAS  ', ''         ,;
        	                             ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
            	                         000000        , "SG2"})
                    	  	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '03'      , '000015'     , ''        , ''        , ''        , 'DISPERSAR POR 45 MIN', 0.0        ,;
	                                     0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
    	                                 'CTTN03'      , ''        , ''         , ''        , cCodRev      , ''        , ''        , ''        , 'DISPERSAR POR 45 MIN', ''         ,;
        	                             ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
            	                         000000        , "SG2"})
                    	  	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '04'      , '000015'     , ''        , ''        , ''        , 'ACERTO DE COR       ', 0.0        ,;
	                                     0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
    	                                 'CTTN03'      , ''        , ''         , ''        , cCodRev      , ''        , ''        , ''        , 'ACERTO DE COR       ', ''         ,;
        	                             ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
            	                         000000        , "SG2"})
                	      	If !Empty(cCodRev)
	                        	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '90'      , '000013'     , ''        , ''        , ''        , 'CONTROLE QUALIDADE' , 0.0        ,;
    	                                    0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0                  , ''         ,;
            	                            'CTGR01'      , 'S'       , 'S'        , 'S'       , cCodRev      , ''        , ''        , ''        , 'CONTROLE QUALIDADE' , ''         ,;
        	                                ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                   , ''         ,;
                	                        000000        , "SG2"})
                    	  	Endif
	                      	If lSemIns
	                        	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '01'      , '000002'     , ''        , ''        , ''        , 'PESAR E ADICIONAR CO', 0.0        ,;
   	                	                    0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
    	                                    'CTTN01'      , ''        , ''         , ''        , cCodRev      , ''        , ''        , ''        , 'PESAR E ADICIONAR CO', ''         ,;
        	                                ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
            	                            000000        , "QQK"})
                	         	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '02'      , '000002'     , ''        , ''        , ''        , 'ADICIONAR SACARIAS  ', 0.0        ,;
	                                        0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
    	                                    'CTTN01'      , ''        , ''         , ''        , cCodRev      , ''        , ''        , ''        , 'ADICIONAR SACARIAS  ', ''         ,;
        	                                ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
            	                            000000        , "QQK"})
                	         	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '03'      , '000015'     , ''        , ''        , ''        , 'DISPERSAR POR 45 MIN', 0.0        ,;
	                                        0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
    	                                    'CTTN03'      , ''        , ''         , ''        , cCodRev      , ''        , ''        , ''        , 'DISPERSAR POR 45 MIN'  , ''         ,;
        	                                ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
            	                            000000        , "QQK"})
                	         	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '04'      , '000015'     , ''        , ''        , ''        , 'ACERTO DE COR       ', 0.0        ,;
	                                        0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
    	                                    'CTTN03'      , ''        , ''         , ''        , cCodRev      , ''        , ''        , ''        , 'ACERTO DE COR       ', ''         ,;
        	                                ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
            	                            000000        , "QQK"})

                	         	If !Empty(cCodRev)
                    	        	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '90'      , '000013'     , ''        , ''        , ''        , 'CONTROLE QUALIDADE' , 0.0        ,;
                        	                   0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0                  , ''         ,;
                            	               'CTGR01'      , 'S'       , 'S'        , 'S'       , cCodRev      , ''        , ''        , ''        , 'CONTROLE QUALIDADE' , ''         ,;
                                	           ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                   , ''         ,;
                                    	       000000        , "QQK"})
	                         	Endif
    	                  	Endif
                      	Endif
                 	ElseIf Len(Alltrim(TCQ->B1_COD)) == 4
                    	lSemIns := .f.
                        cCodRev := ""
                        DbSelectArea("QP6")
                        DbSetOrder(1)
                        DbSeek(xFilial("QP6")+TCQ->B1_COD, .t.)
                        If Found()
                        	DbSelectArea("QQK")
                            DbSetOrder(1)
                            DbSeek(xFilial("QQK")+TCQ->B1_COD, .t.)
                            If !Found()
                            	lSemIns := .t.
                            Endif
                            cCodRev := QP6->QP6_REVI
                        Endif
                        //LGS#20200210 - Adequação de release 12.1.25 e posteriores
                        //If TCQ->B1_GRUPO $ Alltrim(GETMV("MV_GRPPAST")) //Pastas
                        If TCQ->B1_GRUPO $ Alltrim( _cGRPPAST ) //Pastas
                        	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '05'      , 'PBAL01'     , '      '  , 'PAS'     , 'O'       , 'PESAGEM           ', 1.0          ,;
                                            0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                            'CTPT01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'PESAR PRODUTOS'    , '      '     ,;
                                            '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                            000000        , "SG2"})
                            aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '10'      , 'PMIS01'     , '      '  , 'PAS'     , 'O'       , 'DISPERSAO         ', 1.0          ,;
                                            0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                            'CTPT04'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'DISPERSAR       '  , '      '     ,;
                                            '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                            000000        , "SG2"})
                            aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '15'      , 'PBAL01'     , '      '  , 'PAS'     , 'O'       , 'ADICIONAR         ', 1.0          ,;
                                            0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                            'CTPT01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ADICIONAR       '  , '      '     ,;
                                            '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                            000000        , "SG2"})
                            aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '20'      , 'PMIS01'     , '      '  , 'PAS'     , 'O'       , 'DISPERSAO         ', 1.0          ,;
                                            0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                            'CTPT04'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'DISPERSAR       '  , '      '     ,;
                                            '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                            000000        , "SG2"})
                            aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '25'      , 'PBAS01'     , '      '  , 'PAS'     , 'O'       , 'MOAGEM            ', 1.0          ,;
                                            0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                            'CTPT02'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'MOER PRODUTOS '    , '      '     ,;
                                            '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                            000000        , "SG2"})
                            aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '30'      , 'PLAB01'     , '      '  , 'PAS'     , 'O'       , 'ANALISE I         ', 1.0          ,;
                                            0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                            'CTPT05'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR        '  , '      '     ,;
                                            '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                            000000        , "SG2"})
                            aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '35'      , 'PBAL01'     , '      '  , 'PAS'     , 'O'       , 'ANALISE I         ', 1.0          ,;
                                            0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                            'CTPT01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '    , '      '     ,;
                                            '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                            000000        , "SG2"})
                            aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '40'      , 'PMIS01'     , '      '  , 'PAS'     , 'O'       , 'DISPERSAO        ' , 1.0          ,;
                                            0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                            'CTPT04'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'DISPERSAR       '  , '      '     ,;
                                            '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                            000000        , "SG2"})
                            aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '45'      , 'GLAB01'     , '      '  , 'PAS'     , 'O'       , 'ANALISE II        '  , 1.0          ,;
                                            0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                            'CTGR01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '    , '      '     ,;
                                            '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                            000000        , "SG2"})
                            If !Empty(cCodRev)
                            	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '50'      , '000013'     , '      '  , 'PAS'     , 'O'       , 'CONTROLE QUALIDADE', 1.0          ,;
                                               0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0               , ' '          ,;
                                               '      '      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '  , '      '     ,;
                                               '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'               , ' '          ,;
                                               000000        , "SG2"})
                            Endif
                            If lSemIns
                            	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '05'      , 'PBAL01'     , '      '  , 'PAS'     , 'O'       , 'PESAGEM           ', 1.0          ,;
                                               0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                               'CTPT01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'PESAR PRODUTOS'    , '      '     ,;
                                               '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                               000000        , "QQK"})
                                aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '10'      , 'PMIS01'     , '      '  , 'PAS'     , 'O'       , 'DISPERSAO         ', 1.0          ,;
                                               0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                               'CTPT04'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'DISPERSAR       '  , '      '     ,;
                                               '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                               000000        , "QQK"})
                                aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '15'      , 'PBAL01'     , '      '  , 'PAS'     , 'O'       , 'ADICIONAR         ', 1.0          ,;
                                               0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                               'CTPT01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ADICIONAR       '  , '      '     ,;
                                               '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                               000000        , "QQK"})
                                aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '20'      , 'PMIS01'     , '      '  , 'PAS'     , 'O'       , 'DISPERSAO         ', 1.0          ,;
                                               0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                               'CTPT04'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'DISPERSAR       '  , '      '     ,;
                                               '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                               000000        , "QQK"})
                                aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '25'      , 'PBAS01'     , '      '  , 'PAS'     , 'O'       , 'MOAGEM            ', 1.0          ,;
                                               0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                               'CTPT02'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'MOER PRODUTOS '    , '      '     ,;
                                               '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                               000000        , "QQK"})
                                aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '30'      , 'PLAB01'     , '      '  , 'PAS'     , 'O'       , 'ANALISE I         ', 1.0          ,;
                                               0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                               'CTPT05'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR        '  , '      '     ,;
                                               '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                               000000        , "QQK"})
                                aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '35'      , 'PBAL01'     , '      '  , 'PAS'     , 'O'       , 'ANALISE I         ', 1.0          ,;
                                               0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                               'CTPT01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '    , '      '     ,;
                                               '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                               000000        , "QQK"})
                                aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '40'      , 'PMIS01'     , '      '  , 'PAS'     , 'O'       , 'DISPERSAO        ' , 1.0          ,;
                                               0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                               'CTPT04'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'DISPERSAR       '  , '      '     ,;
                                               '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                               000000        , "QQK"})
                                aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '45'      , 'GLAB01'     , '      '  , 'PAS'     , 'O'       , 'ANALISE II        '  , 1.0          ,;
                                               0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                               'CTGR01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '    , '      '     ,;
                                               '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                               000000        , "QQK"})
                                If !Empty(cCodRev)
                                	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '50'      , '000013'     , '      '  , 'PAS'     , 'O'       , 'CONTROLE QUALIDADE', 1.0          ,;
                                                  0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0               , ' '          ,;
                                                  '      '      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '  , '      '     ,;
                                                  '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'               , ' '          ,;
                                                  000000        , "QQK"})
                                Endif
                            Endif
                        //LGS#20200210 - Adequação de release 12.1.25 e posteriores
                        //ElseIf TCQ->B1_GRUPO $ Alltrim(GETMV("MV_GRPSOLU")) //Soluções
                        ElseIf TCQ->B1_GRUPO $ Alltrim( _cGRPSOLU ) //Soluções
                        	//              G2_FILIAL *    G2_CODIGO*  G2_PRODUTO*  G2_OPERAC*  G2_RECURSO   G2_FERRAM   G2_LINHAPR  G2_TPLINHA  G2_DESCRI*         G2_MAOOBRA
                            //              G2_SETUP       G2_FORMSTP  G2_LOTEPAD   G2_TEMPAD*  G2_TPOPER*   G2_TPSOBRE  G2_TEMPSOB  G2_TPDESD   G2_TEMPDES         G2_DESPROP
                            //              G2_CTRAB  *    G2_OPE_OBR  G2_SEQ_OBR   G2_LAU_OBR  G2_REVIPRD*  G2_CHAVE    G2_ROTALT   G2_OPERGRP  G2_ESPOP           G2_GRSETUP
                            //              G2_GRUPREC     G2_NIVMONT  G2_CHAVMON   G2_TMAXPRO  G2_TPINTER   G2_MAXINCR  G2_FOLMIN   G2_HOROTIM  G2_FULTREV         D_E_L_E_T_* 
                            //              R_E_C_N_O_*
                             aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '01'      , '000003'     , '      '  , 'PAS'     , 'O'       , 'PESAGEM           ', 1.0          ,;
                                                0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                '      '      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'PESAR PRODUTOS'    , '      '     ,;
                                                '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                000000        , "SG2"})
                             If !Empty(cCodRev)
                             	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '90'      , '000013'     , '000001'  , 'PAS'     , 'O'       , 'CONTROLE QUALIDADE', 1.0          ,;
                                                   0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0               , ' '          ,;
                                                   '      '      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '  , '      '     ,;
                                                   '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'               , ' '          ,;
                                                   000000        , "SG2"})
                             Endif
                             If lSemIns
                             	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '01'      , '000003'     , '      '  , 'PAS'     , 'O'       , 'PESAGEM           ', 1.0          ,;
                                                   0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                   '      '      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'PESAR PRODUTOS'    , '      '     ,;
                                                   '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                   000000        , "QQK"})
                             	If !Empty(cCodRev)
                                	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '90'      , '000013'     , '000001'  , 'PAS'     , 'O'       , 'CONTROLE QUALIDADE', 1.0          ,;
                                                      0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0               , ' '          ,;
                                                      '      '      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '  , '      '     ,;
                                                      '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'               , ' '          ,;
                                                      000000        , "QQK"})
                             	Endif
                             Endif
                        Endif
                   Endif
                 ElseIf TCQ->B1_TIPO $ 'PA'
                 	//              G2_FILIAL *    G2_CODIGO*  G2_PRODUTO*  G2_OPERAC*  G2_RECURSO   G2_FERRAM   G2_LINHAPR  G2_TPLINHA  G2_DESCRI*         G2_MAOOBRA
                    //              G2_SETUP       G2_FORMSTP  G2_LOTEPAD   G2_TEMPAD*  G2_TPOPER*   G2_TPSOBRE  G2_TEMPSOB  G2_TPDESD   G2_TEMPDES         G2_DESPROP
                    //              G2_CTRAB  *    G2_OPE_OBR  G2_SEQ_OBR   G2_LAU_OBR  G2_REVIPRD*  G2_CHAVE    G2_ROTALT   G2_OPERGRP  G2_ESPOP           G2_GRSETUP
                    //              G2_GRUPREC     G2_NIVMONT  G2_CHAVMON   G2_TMAXPRO  G2_TPINTER   G2_MAXINCR  G2_FOLMIN   G2_HOROTIM  G2_FULTREV         D_E_L_E_T_* 
                    //              R_E_C_N_O_*
                    aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '04'      , '000005'   , ''        , ''        , ''        , 'ENVASAMENTO'    , 0.0        ,;
                                      0.0           , ''        , 0.0        , 1.0       , '1'        , ''        , 0.0       , ''        , 0.0              , ''         ,;
                                      'CTTN04'      , ''        , ''         , ''        , ''         , ''        , ''        , ''        , 'ENVASAR PRODUTO', ''         ,;
                                      ''            , 0.0       , 0.0        , ''        , ''         , 0.0       , ''        , ''        , ''               , ''         ,;
                                      000000, "SG2"})
                    DbSelectArea("QP6")
                    DbSetOrder(1)
                    DbSeek(xFilial("QP6")+TCQ->B1_COD, .t.)
                    If Found()
                    	DbSelectArea("QQK")
                        DbSetOrder(1)
                        DbSeek(xFilial("QQK")+TCQ->B1_COD, .t.)
                        If !Found()
                             //              G2_FILIAL *    G2_CODIGO*  G2_PRODUTO*  G2_OPERAC*  G2_RECURSO     G2_FERRAM   G2_LINHAPR  G2_TPLINHA  G2_DESCRI*         G2_MAOOBRA
                             //              G2_SETUP       G2_FORMSTP  G2_LOTEPAD   G2_TEMPAD*  G2_TPOPER*     G2_TPSOBRE  G2_TEMPSOB  G2_TPDESD   G2_TEMPDES         G2_DESPROP
                             //              G2_CTRAB  *    G2_OPE_OBR  G2_SEQ_OBR   G2_LAU_OBR  G2_REVIPRD*    G2_CHAVE    G2_ROTALT   G2_OPERGRP  G2_ESPOP           G2_GRSETUP
                             //              G2_GRUPREC     G2_NIVMONT  G2_CHAVMON   G2_TMAXPRO  G2_TPINTER     G2_MAXINCR  G2_FOLMIN   G2_HOROTIM  G2_FULTREV         D_E_L_E_T_* 
                             //              R_E_C_N_O_*
                             aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '04'      , '000005'     , ''        , ''        , ''        , 'ENVASAMENTO'    , 0.0        ,;
                                            0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0              , ''         ,;
                                            'CTTN04'      , ''        , ''         , ''        , QP6->QP6_REVI, ''        , ''        , ''        , 'ENVASAR PRODUTO', ''         ,;
                                            ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''               , ''         ,;
                                            000000, "QQK"})
                        Endif
                    Endif
                 Endif
             Else
                DbSelectArea("QP6")
                DbSetOrder(1)
                DbSeek(xFilial("QP6")+TCQ->B1_COD, .t.)
                If Found()
                   DbSelectArea("QQK")
                   DbSetOrder(1)
                   DbSeek(xFilial("QQK")+TCQ->B1_COD, .t.)
                   If !Found()
                      If TCQ->B1_TIPO $ 'PI'
                         If Len(Alltrim(TCQ->B1_COD)) == 12 .or. Len(Alltrim(TCQ->B1_COD)) == 5
                         	
 		                    If LEN(ALLTRIM(TCQ->B1_COD))==12 .and. !(Substr(TCQ->B1_COD,4,2) $ ('08.41.42.43.44.46.47.48.49.52.54.57.90'))
                            
                            
                            	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '01'      , '000002'     , ''        , ''        , ''        , 'PESAGEM'         , 0.0        ,;
                                	           0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
                                    	       'CTTN01'      , ''        , ''         , ''        , QP6->QP6_REVI, ''        , ''        , ''        , 'PESAR MATERIAIS' , ''         ,;
                                        	   ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
                                           	   000000        , "QQK"})
	                            aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '02'      , '000015'     , ''        , ''        , ''        , 'TINGIMENTO'      , 0.0        ,;
    	                                       0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
        	                                   'CTTN03'      , ''        , ''         , ''        , QP6->QP6_REVI, ''        , ''        , ''        , 'TINGIR PRODUTO'  , ''         ,;
            	                               ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
                	                           000000        , "QQK"})
                    	        aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '90'      , '000013'     , ''        , ''        , ''        , 'CONTROLE QUALIDADE' , 0.0        ,;
                        	                   0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0                  , ''         ,;
                            	               'CTGR01'      , 'S'       , 'S'        , 'S'       , QP6->QP6_REVI, ''        , ''        , ''        , 'INSPECIONAR'        , ''         ,;
                                	           ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                   , ''         ,;
                                    	       000000        , "QQK"})
	                     
	                        Else
//	                        
	                         	aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '01'      , '000002'     , ''        , ''        , ''        , 'PESAR E ADICIONAR CO', 0.0     ,;
   	                	        	            0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
    	                            	        'CTTN01'      , ''        , ''         , ''        , QP6->QP6_REVI, ''        , ''        , ''        , 'PESAR E ADICIONAR CO', ''     ,;
        	                            	    ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
	           	                            	000000        , "QQK"})
	                	        aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '02'      , '000002'     , ''        , ''        , ''        , 'ADICIONAR SACARIAS  ', 0.0     ,;
		                                        0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
    		                                    'CTTN01'      , ''        , ''         , ''        , QP6->QP6_REVI, ''        , ''        , ''        , 'ADICIONAR SACARIAS  ', ''     ,;
        		                                ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
            		                            000000        , "QQK"})
                		        aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '03'      , '000015'     , ''        , ''        , ''        , 'DISPERSAR POR 45 MIN', 0.0     ,;
	                    	                    0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
    	                    	                'CTTN03'      , ''        , ''         , ''        , QP6->QP6_REVI, ''        , ''        , ''        , 'DISPERSAR POR 45 MIN', ''     ,;
        	                    	            ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
            	                    	        000000        , "QQK"})
	                	        aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '04'      , '000015'     , ''        , ''        , ''        , 'ACERTO DE COR       ', 0.0     ,;
		                                        0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0               , ''         ,;
    		                                    'CTTN03'      , ''        , ''         , ''        , QP6->QP6_REVI, ''        , ''        , ''        , 'ACERTO DE COR      ', ''      ,;
        		                                ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                , ''         ,;
            		                            000000        , "QQK"})
                    		    aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '90'      , '000013'     , ''        , ''        , ''        , 'CONTROLE QUALIDADE' , 0.0      ,;
                        		                0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0                 , ''       ,;
                            	               'CTGR01'      , 'S'       , 'S'        , 'S'       , QP6->QP6_REVI, ''        , ''        , ''        , 'CONTROLE QUALIDADE' , ''       ,;
                                	           ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''                   , ''       ,;
                                   		       000000        , "QQK"})	                     
							Endif
//	                     
	                     ElseIf Len(Alltrim(TCQ->B1_COD)) == 4
                                lSemIns := .f.
                                cCodRev := ""
                                DbSelectArea("QP6")
                                DbSetOrder(1)
                                DbSeek(xFilial("QP6")+TCQ->B1_COD, .t.)
                                If Found()
                                   DbSelectArea("QQK")
                                   DbSetOrder(1)
                                   DbSeek(xFilial("QQK")+TCQ->B1_COD, .t.)
                                   If !Found()
                                      lSemIns := .t.
                                   Endif
                                   cCodRev := QP6->QP6_REVI
                                Endif
                                //LGS#20200210 - Adequação de release 12.1.25 e posteriores
                                //If TCQ->B1_GRUPO $ Alltrim(GETMV("MV_GRPPAST")) //Pastas
                                If TCQ->B1_GRUPO $ Alltrim( _cGRPPAST ) //Pastas
                                   aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '05'      , 'PBAL01'     , '      '  , 'PAS'     , 'O'       , 'PESAGEM           ', 1.0          ,;
                                                  0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                 'CTPT01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'PESAR PRODUTOS'    , '      '     ,;
                                                 '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                  000000        , "SG2"})
                                   aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '10'      , 'PMIS01'     , '      '  , 'PAS'     , 'O'       , 'DISPERSAO         ', 1.0          ,;
                                                  0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                  'CTPT04'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'DISPERSAR       '  , '      '     ,;
                                                  '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                  000000        , "SG2"})
                                   aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '15'      , 'PBAL01'     , '      '  , 'PAS'     , 'O'       , 'ADICIONAR         ', 1.0          ,;
                                                  0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                  'CTPT01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ADICIONAR       '  , '      '     ,;
                                                  '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                  000000        , "SG2"})
                                   aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '20'      , 'PMIS01'     , '      '  , 'PAS'     , 'O'       , 'DISPERSAO         ', 1.0          ,;
                                                  0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                  'CTPT04'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'DISPERSAR       '  , '      '     ,;
                                                  '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                  000000        , "SG2"})
                                   aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '25'      , 'PBAS01'     , '      '  , 'PAS'     , 'O'       , 'MOAGEM            ', 1.0          ,;
                                                  0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                  'CTPT02'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'MOER PRODUTOS '    , '      '     ,;
                                                  '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                  000000        , "SG2"})
                                   aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '30'      , 'PLAB01'     , '      '  , 'PAS'     , 'O'       , 'ANALISE I         ', 1.0          ,;
                                                  0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                  'CTPT05'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR        '  , '      '     ,;
                                                  '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                  000000        , "SG2"})
                                   aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '35'      , 'PBAL01'     , '      '  , 'PAS'     , 'O'       , 'ANALISE I         ', 1.0          ,;
                                                  0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                  'CTPT01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '    , '      '     ,;
                                                  '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                  000000        , "SG2"})
                                   aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '40'      , 'PMIS01'     , '      '  , 'PAS'     , 'O'       , 'DISPERSAO        ' , 1.0          ,;
                                                  0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                  'CTPT04'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'DISPERSAR       '  , '      '     ,;
                                                  '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                  000000        , "SG2"})
                                   aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '45'      , 'GLAB01'     , '      '  , 'PAS'     , 'O'       , 'ANALISE II        '  , 1.0          ,;
                                                  0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                  'CTGR01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '    , '      '     ,;
                                                  '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                  000000        , "SG2"})
                                   If !Empty(cCodRev)
                                      aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '50'      , '000013'     , '      '  , 'PAS'     , 'O'       , 'CONTROLE QUALIDADE', 1.0          ,;
                                                     0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0               , ' '          ,;
                                                     '      '      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '  , '      '     ,;
                                                     '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'               , ' '          ,;
                                                     000000        , "SG2"})
                                   Endif
                                   If lSemIns
                                      aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '05'      , 'PBAL01'     , '      '  , 'PAS'     , 'O'       , 'PESAGEM           ', 1.0          ,;
                                                     0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                     'CTPT01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'PESAR PRODUTOS'    , '      '     ,;
                                                     '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                     000000        , "QQK"})
                                      aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '10'      , 'PMIS01'     , '      '  , 'PAS'     , 'O'       , 'DISPERSAO         ', 1.0          ,;
                                                     0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                     'CTPT04'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'DISPERSAR       '  , '      '     ,;
                                                     '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                     000000        , "QQK"})
                                      aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '15'      , 'PBAL01'     , '      '  , 'PAS'     , 'O'       , 'ADICIONAR         ', 1.0          ,;
                                                     0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                     'CTPT01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ADICIONAR       '  , '      '     ,;
                                                     '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                     000000        , "QQK"})
                                      aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '20'      , 'PMIS01'     , '      '  , 'PAS'     , 'O'       , 'DISPERSAO         ', 1.0          ,;
                                                     0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                     'CTPT04'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'DISPERSAR       '  , '      '     ,;
                                                     '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                     000000        , "QQK"})
                                      aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '25'      , 'PBAS01'     , '      '  , 'PAS'     , 'O'       , 'MOAGEM            ', 1.0          ,;
                                                     0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                     'CTPT02'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'MOER PRODUTOS '    , '      '     ,;
                                                     '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                     000000        , "QQK"})
                                      aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '30'      , 'PLAB01'     , '      '  , 'PAS'     , 'O'       , 'ANALISE I         ', 1.0          ,;
                                                     0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                     'CTPT05'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR        '  , '      '     ,;
                                                     '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                     000000        , "QQK"})
                                      aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '35'      , 'PBAL01'     , '      '  , 'PAS'     , 'O'       , 'ANALISE I         ', 1.0          ,;
                                                     0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                     'CTPT01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '    , '      '     ,;
                                                     '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                     000000        , "QQK"})
                                      aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '40'      , 'PMIS01'     , '      '  , 'PAS'     , 'O'       , 'DISPERSAO        ' , 1.0          ,;
                                                     0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                     'CTPT04'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'DISPERSAR       '  , '      '     ,;
                                                     '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                     000000        , "QQK"})
                                      aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '45'      , 'GLAB01'     , '      '  , 'PAS'     , 'O'       , 'ANALISE II        '  , 1.0          ,;
                                                     0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                     'CTGR01'      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '    , '      '     ,;
                                                     '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                     000000        , "QQK"})
                                      If !Empty(cCodRev)
                                         aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '50'      , '000013'     , '      '  , 'PAS'     , 'O'       , 'CONTROLE QUALIDADE', 1.0          ,;
                                                        0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0               , ' '          ,;
                                                        '      '      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '  , '      '     ,;
                                                        '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'               , ' '          ,;
                                                        000000        , "QQK"})
                                      Endif
                                   Endif
                                //LGS#20200210 - Adequação de release 12.1.25 e posteriores
                                //ElseIf TCQ->B1_GRUPO $ Alltrim(GETMV("MV_GRPSOLU")) //Soluções
                                ElseIf TCQ->B1_GRUPO $ Alltrim( _cGRPSOLU ) //Soluções
                                       //              G2_FILIAL *    G2_CODIGO*  G2_PRODUTO*  G2_OPERAC*  G2_RECURSO   G2_FERRAM   G2_LINHAPR  G2_TPLINHA  G2_DESCRI*         G2_MAOOBRA
                                       //              G2_SETUP       G2_FORMSTP  G2_LOTEPAD   G2_TEMPAD*  G2_TPOPER*   G2_TPSOBRE  G2_TEMPSOB  G2_TPDESD   G2_TEMPDES         G2_DESPROP
                                       //              G2_CTRAB  *    G2_OPE_OBR  G2_SEQ_OBR   G2_LAU_OBR  G2_REVIPRD*  G2_CHAVE    G2_ROTALT   G2_OPERGRP  G2_ESPOP           G2_GRSETUP
                                       //              G2_GRUPREC     G2_NIVMONT  G2_CHAVMON   G2_TMAXPRO  G2_TPINTER   G2_MAXINCR  G2_FOLMIN   G2_HOROTIM  G2_FULTREV         D_E_L_E_T_* 
                                       //              R_E_C_N_O_*
                                       aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '01'      , '000003'     , '      '  , 'PAS'     , 'O'       , 'PESAGEM           ', 1.0          ,;
                                                      0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                      '      '      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'PESAR PRODUTOS'    , '      '     ,;
                                                      '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                      000000        , "SG2"})
                                       If !Empty(cCodRev)
                                          aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '90'      , '000013'     , '000001'  , 'PAS'     , 'O'       , 'CONTROLE QUALIDADE', 1.0          ,;
                                                         0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0               , ' '          ,;
                                                         '      '      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '  , '      '     ,;
                                                         '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'               , ' '          ,;
                                                         000000        , "SG2"})
                                       Endif
                                       If lSemIns
                                          aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '01'      , '000003'     , '      '  , 'PAS'     , 'O'       , 'PESAGEM           ', 1.0          ,;
                                                         0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0                 , ' '          ,;
                                                         '      '      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'PESAR PRODUTOS'    , '      '     ,;
                                                         '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'                 , ' '          ,;
                                                         000000        , "QQK"})
                                          If !Empty(cCodRev)
                                             aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '90'      , '000013'     , '000001'  , 'PAS'     , 'O'       , 'CONTROLE QUALIDADE', 1.0          ,;
                                                            0.0           , '   '     , 0.0        , 1.0       , '1'          , '      '  , 0.0       , ' '       , 0.0               , ' '          ,;
                                                            '      '      , ' '       , ' '        , ' '       , cCodRev      , '      '  , '  '      , ' '       , 'ANALISAR      '  , '      '     ,;
                                                            '      '      , 0.0       , 0.0        , ' '       , '      '     , 0.0       , '     '   , '       ' , 'S'               , ' '          ,;
                                                            000000        , "QQK"})
                                          Endif
                                       Endif
                                Endif
                         Endif
                      ElseIf TCQ->B1_TIPO $ 'PA'
                             //              G2_FILIAL *    G2_CODIGO*  G2_PRODUTO*  G2_OPERAC*  G2_RECURSO     G2_FERRAM   G2_LINHAPR  G2_TPLINHA  G2_DESCRI*         G2_MAOOBRA
                             //              G2_SETUP       G2_FORMSTP  G2_LOTEPAD   G2_TEMPAD*  G2_TPOPER*     G2_TPSOBRE  G2_TEMPSOB  G2_TPDESD   G2_TEMPDES         G2_DESPROP
                             //              G2_CTRAB  *    G2_OPE_OBR  G2_SEQ_OBR   G2_LAU_OBR  G2_REVIPRD*    G2_CHAVE    G2_ROTALT   G2_OPERGRP  G2_ESPOP           G2_GRSETUP
                             //              G2_GRUPREC     G2_NIVMONT  G2_CHAVMON   G2_TMAXPRO  G2_TPINTER     G2_MAXINCR  G2_FOLMIN   G2_HOROTIM  G2_FULTREV         D_E_L_E_T_* 
                             //              R_E_C_N_O_*
                             aadd(aMatInc, {xFilial("SG2"), '01'      , TCQ->B1_COD, '04'      , '000005'     , ''        , ''        , ''        , 'ENVASAMENTO'    , 0.0        ,;
                                            0.0           , ''        , 0.0        , 1.0       , '1'          , ''        , 0.0       , ''        , 0.0              , ''         ,;
                                            'CTTN04'      , ''        , ''         , ''        , QP6->QP6_REVI, ''        , ''        , ''        , 'ENVASAR PRODUTO', ''         ,;
                                            ''            , 0.0       , 0.0        , ''        , ''           , 0.0       , ''        , ''        , ''               , ''         ,;
                                            000000, "QQK"})
                      Endif
                   Endif
                Endif
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       ProcRegua(Len(aMatInc))
       For nX := 1 To Len(aMatInc)
           IncProc("Incluindo registro na tabela: "+aMatInc[nX][42])
           DbSelectArea(aMatInc[nX][42])
           DbSetOrder(1)
           DbSeek(aMatInc[nX][01]+aMatInc[nX][03]+aMatInc[nX][02]+aMatInc[nX][04], .t.)
           If !Found()
              RecLock(aMatInc[nX][42], .t.)
/*                 For nJ := 1 to FCount()
                     If nJ <= Len(aMatInc[nX])
                        FieldPut(nJ, aMatInc[nX][nJ])
                     Endif
                 Next*/
				if aMatInc[nX][42] = "SG2"
					SG2->G2_FILIAL := aMatInc[nX][1]
					SG2->G2_CODIGO := aMatInc[nX][2]
					SG2->G2_PRODUTO := aMatInc[nX][3]
					SG2->G2_OPERAC := aMatInc[nX][4]
					SG2->G2_RECURSO := aMatInc[nX][5]
					SG2->G2_FERRAM := aMatInc[nX][6]
					SG2->G2_LINHAPR := aMatInc[nX][7]
					SG2->G2_TPLINHA := aMatInc[nX][8]
					SG2->G2_DESCRI := aMatInc[nX][9]
					SG2->G2_MAOOBRA := aMatInc[nX][10]
					SG2->G2_SETUP := aMatInc[nX][11]
					SG2->G2_FORMSTP := aMatInc[nX][12]
					SG2->G2_LOTEPAD := aMatInc[nX][13]
					SG2->G2_TEMPAD := aMatInc[nX][14]
					SG2->G2_TPOPER := aMatInc[nX][15]
					SG2->G2_TPSOBRE := aMatInc[nX][16]
					SG2->G2_TEMPSOB := aMatInc[nX][17]
					SG2->G2_TPDESD := aMatInc[nX][18]
					SG2->G2_TEMPDES := aMatInc[nX][19]
					SG2->G2_DESPROP := aMatInc[nX][20]
					SG2->G2_CTRAB := aMatInc[nX][21]
					SG2->G2_OPE_OBR := aMatInc[nX][22]
					SG2->G2_SEQ_OBR := aMatInc[nX][23]
					SG2->G2_LAU_OBR := aMatInc[nX][24]
					SG2->G2_REVIPRD := aMatInc[nX][25]
					SG2->G2_CHAVE := aMatInc[nX][26]
					SG2->G2_ROTALT := aMatInc[nX][27]
					SG2->G2_OPERGRP := aMatInc[nX][28]
					SG2->G2_ESPOP := aMatInc[nX][29]
					SG2->G2_GRSETUP := aMatInc[nX][30]
					SG2->G2_GRUPREC := aMatInc[nX][31]
					SG2->G2_NIVMONT := aMatInc[nX][32]
					SG2->G2_CHAVMON := aMatInc[nX][33]
					SG2->G2_TMAXPRO := aMatInc[nX][34]
					SG2->G2_TPINTER := aMatInc[nX][35]
					SG2->G2_MAXINCR := aMatInc[nX][36]
					SG2->G2_FOLMIN := aMatInc[nX][37]
					SG2->G2_HOROTIM := aMatInc[nX][38]
					SG2->G2_FULTREV := aMatInc[nX][39]   
				ELSE
					QQK->QQK_FILIAL := aMatInc[nX][1]
					QQK->QQK_CODIGO := aMatInc[nX][2]
					QQK->QQK_PRODUT := aMatInc[nX][3]
					QQK->QQK_OPERAC := aMatInc[nX][4]
					QQK->QQK_RECURS := aMatInc[nX][5]
					QQK->QQK_FERRAM := aMatInc[nX][6]
					QQK->QQK_LINHAP := aMatInc[nX][7]
					QQK->QQK_TPLINH := aMatInc[nX][8]
					QQK->QQK_DESCRI := aMatInc[nX][9]
					QQK->QQK_MAOOBR := aMatInc[nX][10]
					QQK->QQK_SETUP := aMatInc[nX][11]
					QQK->QQK_FORMST := aMatInc[nX][12]
					QQK->QQK_LOTEPA := aMatInc[nX][13]
					QQK->QQK_TEMPAD := aMatInc[nX][14]
					QQK->QQK_TPOPER := aMatInc[nX][15]
					QQK->QQK_TPSOBR := aMatInc[nX][16]
					QQK->QQK_TEMPSO := aMatInc[nX][17]
					QQK->QQK_TPDESD := aMatInc[nX][18]
					QQK->QQK_TEMPDE := aMatInc[nX][19]
					QQK->QQK_DESPRO := aMatInc[nX][20]
					QQK->QQK_CTRAB := aMatInc[nX][21]
					QQK->QQK_OPE_OB := aMatInc[nX][22]
					QQK->QQK_SEQ_OB := aMatInc[nX][23]
					QQK->QQK_LAU_OB := aMatInc[nX][24]
					QQK->QQK_REVIPR := aMatInc[nX][25]
					QQK->QQK_CHAVE := aMatInc[nX][26]
					QQK->QQK_ROTALT := aMatInc[nX][27]
					QQK->QQK_OPERGR := aMatInc[nX][28]
					QQK->QQK_ESPOP := aMatInc[nX][29]
					QQK->QQK_GRSETU := aMatInc[nX][30]
					QQK->QQK_GRUPRE := aMatInc[nX][31]
					QQK->QQK_NIVMON := aMatInc[nX][32]
					QQK->QQK_CHAVMO := aMatInc[nX][33]
					QQK->QQK_TMAXPR := aMatInc[nX][34]
					QQK->QQK_TPINTE := aMatInc[nX][35]
					QQK->QQK_MAXINC := aMatInc[nX][36]
					QQK->QQK_FOLMIN := aMatInc[nX][37]
					QQK->QQK_HOROTI := aMatInc[nX][38]
					QQK->QQK_FULTRE := aMatInc[nX][39]
				
				ENDIF 
					
              MsUnLock()
              DbSelectArea("SB1")
              DbSetOrder(1)
              DbSeek(xFilial("SB1")+aMatInc[nX][3], .t.)
              If Found()
                 RecLock("SB1", .f.)
                    SB1->B1_OPERPAD := '01'
                 MsUnLock()
              Endif
           Endif
       Next
Return

User Function fVerOps()
     /*** VERIFICA OPS EM ABERTO PARA OS PRODUTOS ***/
     cQry1 := ""
     cQry1 += "SELECT COUNT(SC2.C2_NUM) AS NUMOP, SUM(SC2.C2_QUANT - SC2.C2_QUJE) AS QTDOP "
     cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
     cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
     cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
     cQry1 += "  AND SC2.C2_DATRF   = '' "
     cQry1 += "  AND SC2.C2_PRODUTO = '"+M->C2_PRODUTO+"' "
     TCQuery cQry1 ALIAS "TOPS" NEW
     DbSelectArea("TOPS")
     If TOPS->NUMOP > 0
        cVarDes := "" ; cVarOps := ""
        cVarDes := Iif(TOPS->NUMOP == 1, "Existe ", "Existem ")
        cVarOps := Iif(TOPS->NUMOP == 1, " OP aberta ", " OPs abertas ")
        MsgBox(cVarDes+Transform(TOPS->NUMOP, "@E 99")+cVarOps+"para esse produto, com "+Transform(TOPS->QTDOP, "@E 999,999.99")+" "+SB1->B1_UM+".", "Informação", "INFO")
     Endif
     DbSelectArea("TOPS")
     DbCloseArea()
Return .t.
