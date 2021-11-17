#include "rwmake.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATX02 º Autor ³ Luís Gustavo de S. º Data ³  28/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Demonstrativo de Resultados.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATX02()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "            Demonstrativo de Resultados.            "
     Local titulo        := "Demonstrativo de Resultados: "
     Local nLin          := 80
     Local Cabec1        := ""
     Local Cabec2        := ""
     Local Cabec3        := ""
     Local Cabec4        := ""
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private CbTxt       := ""
     Private limite      := 220
     Private tamanho     := "G"
     Private nomeprog    := "BRFATX02" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 15
     Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "FATX02"
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATX02" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SZE"

     DbSelectArea("SZE")
     DbSetOrder(1)
     
     ValPerg()
     Pergunte(cPerg,.F.)

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

     Processa({|| FATX02_1(Cabec1, Cabec2, Titulo, nLin, Cabec3, Cabec4) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FATX02_1 º Autor ³ AP6 IDE            º Data ³  28/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FATX02_1(Cabec1, Cabec2, Titulo, nLin, Cabec3, Cabec4)
       Local cPul01  := "" ; Local cPul02  := ""
       Local nFol01  := 0  ; Local nFol02  := 0
       Local xUltMes := 0  ; Local nImpAcu := 0
       Local nNumFol := 0  ; Local nColIni := 0
       Local nColFim := 0  ; Local cPulLin := ""
       Local nSomPar := 0
       Local aMeses  := {"        Janeiro         ", "        Fevereiro       ", "         Março          ", "         Abril          ", "          Maio          ", "         Junho          ",;
                         "         Julho          ", "         Agosto         ", "        Setembro        ", "        Outubro         ", "        Novembro        ", "        Dezembro        "}
       Local aLinha  := {} ; Local aMatImp := {}
       /**********************************************************************************************************/
       /*** MATRIZES PARA PRIMEIRA PARTE DO RELATÓRIO - INFORMAÇÕES DE FATURAMENTO E IMPOSTOS                  ***/
       /**********************************************************************************************************/
       // Matrizes de Volumes Faturados
       Local aVolLin := {} ; Local aVolTot := {} 
       Local aParVLn := {} ; Local aParVTt := {} // Matrizes de Participação do Volume por Linha
       // Matrizes de Receita Bruta Geral Faturada
       Local aRecLin := {} ; Local aRecTot := {} 
       Local aParRLn := {} ; Local aParRTt := {} // Matrizes de Participação de Receita Bruta Geral por Linha
       // Matrizes de Volumes Devolvidos
       Local aVolDLn := {} ; Local aVolDTt := {} 
       Local aParDVL := {} ; Local aParDVT := {} // Matrizes de Participação do Volume Devolvido por Linha
       // Matrizes de Receita Bruta Geral Devolvida
       Local aRecDLn := {} ; Local aRecDTt := {} 
       Local aParDRL := {} ; Local aParDTt := {} // Matrizes de Participação de Receita Bruta Geral Devolvida por Linha
       //Matrizes de Impostos (IPI)
       Local aImpLI1 := {} ; Local aImpI1T := {}
       Local aParLI1 := {} ; Local aParI1T := {} // Matrizes de Participação de IPI por linha
       //Matrizes de Impostos (ICMS Retido)
       Local aImpLI2 := {} ; Local aImpI2T := {}
       Local aParLI2 := {} ; Local aParI2T := {} // Matrizes de Participação de ICMS Retido por linha
       //Matrizes de Receita Bruta
       Local aRecBLn := {} ; Local aRecBTt := {}
       Local aParBLn := {} ; Local aParBTt := {} // Matrizes de Participação de Receita Bruta por linha
       //Matrizes de Impostos (ICMS)
       Local aImpLI3 := {} ; Local aImpI3T := {}
       Local aParLI3 := {} ; Local aParI3T := {} // Matrizes de Participação de ICMS Retido por linha
       //Matrizes de Impostos (PIS)
       Local aImpLI4 := {} ; Local aImpI4T := {}
       Local aParLI4 := {} ; Local aParI4T := {} // Matrizes de Participação de PIS por linha
       //Matrizes de Impostos (COFINS)
       Local aImpLI5 := {} ; Local aImpI5T := {}
       Local aParLI5 := {} ; Local aParI5T := {} // Matrizes de Participação de COFINS por linha
       //Matrizes de Comissão
       Local aComLin := {} ; Local aComTot := {}
       Local aParCLn := {} ; Local aParCTt := {} // Matrizes de Participação de Comissão por linha
       //Matrizes de Deduções
       Local aDedLin := {} ; Local aDedTot := {}
       Local aParDDL := {} ; Local aParDDT := {} // Matrizes de Participação de Comissão por linha
       //Matrizes de Receitas Liquidas
       Local aLiqLin := {} ; Local aLiqTot := {}
       Local aParLqL := {} ; Local aParLqT := {} // Matrizes de Participação de Comissão por linha
       /**********************************************************************************************************/
       /*** MATRIZES PARA SEGUNDA PARTE DO RELATÓRIO - INFORMAÇÕES DE CUSTOS E DESPESAS                        ***/
       /**********************************************************************************************************/
       // Matrizes de Custos de Materias Primas
       Local aCusMtL := {} ; Local aCusMtT := {}
       Local aParMtL := {} ; Local aParMtT := {}
       // Matrizes de Custos de Embalagens
       Local aCusEmL := {} ; Local aCusEmT := {}
       Local aParEmL := {} ; Local aParEmT := {}
       // Matrizes de Custos de Produção
       Local aCusPrL := {} ; Local aCusPrT := {}
       Local aParPrL := {} ; Local aParPrT := {}
       // Matrizes de Margens de Contribuição
       Local aCusMCL := {} ; Local aCusMCT := {}
       Local aParMCL := {} ; Local aParMCT := {}
       Local nB, nZ, nA, nY
       /***********************************************************************************************************/
       /***                                  MONTANDO MATRIZES DO FATURAMENTO                                   ***/
       /***********************************************************************************************************/
       MsAguarde({|| fMonAFI( @aLinha,;
                              @aVolLin, @aVolTot, @aParVLn, @aParVTt, @aRecLin, @aRecTot, @aParRLn, @aParRTt,;
                              @aVolDLn, @aVolDTt, @aParDVL, @aParDVT, @aRecDLn, @aRecDTt, @aParDRL, @aParDTt,;
                              @aImpLI1, @aImpI1T, @aParLI1, @aParI1T, @aImpLI2, @aImpI2T, @aParLI2, @aParI2T,;
                              @aImpLI3, @aImpI3T, @aParLI3, @aParI3T, @aRecBLn, @aRecBTt, @aParBLn, @aParBTt,;
                              @aImpLI4, @aImpI4T, @aParLI4, @aParI4T, @aImpLI5, @aImpI5T, @aParLI5, @aParI5T,;
                              @aComLin, @aComTot, @aParCLn, @aParCTt, @aDedLin, @aDedTot, @aParDDL, @aParDDT,;
                              @aLiqLin, @aLiqTot, @aParLqL, @aParLqT) }, "Aguarde", "Montando Matrizes de Faturamento e Impostos...")

       /***********************************************************************************************************/
       /***                               MONTANDO MATRIZES DE CUSTOS E DESPESAS                                ***/
       /***********************************************************************************************************/
       MsAguarde({|| fMonACD(  aLinha, @aCusMtL, @aCusMtT, @aParMtL, @aParMtT, @aCusEmL, @aCusEmT, @aParEmL, @aParEmT, @aCusPrL, @aCusPrT, @aParPrL, @aParPrT, @aCusMCL, @aCusMCT, @aParMCL, @aParMCT) }, "Aguarde", "Montando Matrizes de Custos e Despesas...")

       /***********************************************************************************************************/
       
       /*** BUSCA INFORMAÇÕES DO FATURAMENTO ***/
       MsAguarde({|| FATX02_2(@aVolLin, @aVolTot, @aParVLn, @aParVTt, @aRecLin, @aRecTot, @aParRLn, @aParRTt) }, "Aguarde", "Buscando informações do Faturamento...")
       /*** BUSCA INFORMAÇÕES DAS DEVOLUÇÕES ***/
       MsAguarde({|| FATX02_3(@aVolDLn, @aVolDTt, @aParDVL, @aParDVT, @aRecDLn, @aRecDTt, @aParDRL, @aParDTt,;
                               aVolLin,  aVolTot,  aRecLin,  aRecTot ) }, "Aguarde", "Buscando informações de Devolução...")
       /*** BUSCA INFORMAÇÕES DOS IMPOSTOS ***/
       MsAguarde({|| FATX02_4(@aImpLI1, @aImpI1T, @aParLI1, @aParI1T, @aImpLI2, @aImpI2T, @aParLI2, @aParI2T,;
                              @aImpLI3, @aImpI3T, @aParLI3, @aParI3T,  aRecLin,  aRecTot) }, "Aguarde", "Buscando informações de Impostos...")
       /*** CALCULA RECEITA BRUTA ***/
       MsAguarde({|| FATX02_5(@aRecBLn, @aRecBTt, @aParBLn, @aParBTt,  aRecLin,  aRecTot,  aRecDLn,  aRecDTt,;
                              @aImpLI4, @aImpI4T, @aParLI4, @aParI4T, @aImpLI5, @aImpI5T, @aParLI5, @aParI5T,;
                               aImpLI1,  aImpI1T,  aImpLI2,  aImpI2T,  aLinha) }, "Aguarde", "Calculando Receita Bruta...")
       /*** CALCULA COMISSÃO ***/
       MsAguarde({|| FATX02_6(@aComLin, @aComTot, @aParCLn, @aParCTt,  aRecBLn,  aRecBTt) }, "Aguarde", "Calculando Comissão...")
       /*** CALCULOS FINAIS ***/
       MsAguarde({|| FATX02_7(@aDedLin, @aDedTot, @aParDDL, @aParDDT, @aLiqLin, @aLiqTot, @aParLqL, @aParLqT,;
                               aImpLI3,  aImpI3T,  aImpLI4,  aImpI4T,  aImpLI5,  aImpI5T,  aComLin,  aComTot,;
                               aRecBLn,  aRecBTt,  aRecLin,  aRecTot ) }, "Aguarde", "Calculos Finais das Receitas...")
       /***********************************************************************************************************/
       MsAguarde({|| FATX02_8(@aCusMtL, @aCusMtT, @aParMtL, @aParMtT, @aCusEML, @aCusEMT, @aParEML, @aParEMT,;
                              @aCusPrL, @aCusPrT, @aParPrL, @aParPrT, @aCusMCL, @aCusMCT, @aParMCL, @aParMCT,;
                               aLiqLin,  aLiqTot,  aParLqL,  aParLqT,  aRecBLn,  aRecBTt,  aRecLin,  aRecTot,;
                               aLinha ) }, "Aguarde", "Calculando Custo das Materias Primas...")
      
       /***********************************************************************************************************/
       /***                                 MONTANDO CABEÇALHO DOS RELATÓRIOS                                   ***/
       /***********************************************************************************************************/
       fMonCab(aVolTot, aMeses, @Cabec1, @Cabec2, @cPul01, @Cabec3, @Cabec4, @cPul02, @nFol01, @nFol02, @xUltMes)

       aadd(aMatImp, {aVolLin, aParVLn, aVolTot, aParVTt, "IM", "Volume Vendido     (L) |", .f., "Volume Vendido  -", " (L)| "})
       aadd(aMatImp, {aVolDLn, aParDVL, aVolDTt, aParDVT, "IM", "Volume Devolvido   (L) |", .t., "Volume Devolvido-", " (L)| "})
       aadd(aMatImp, {       ,        ,        ,        , "P1",                           ,    ,                    ,         })
       aadd(aMatImp, {aRecLin, aParRLn, aRecTot, aParRTt, "IM", "RECEITA BRUTA GERAL(R$)|", .t., "Rec. Bruta Geral-", "(R$)| "})
       aadd(aMatImp, {       ,        ,        ,        , "DL",                           ,    ,                    ,         })
       aadd(aMatImp, {aImpLI1, aParLI1, aImpI1T, aParI1T, "IM", "IPI                (R$)|", .t., "IPI             -", "(R$)| "})
       aadd(aMatImp, {aImpLI2, aParLI2, aImpI2T, aParI2T, "IM", "ICMS Subst. Tribut.(R$)|", .t., "ICMS Sub. Trib. -", "(R$)| "})
       aadd(aMatImp, {aRecDLn, aParDRL, aRecDTt, aParDTt, "IM", "Devolução          (R$)|", .t., "Devolução       -", "(R$)| "})
       aadd(aMatImp, {       ,        ,        ,        , "P1",                           ,    ,                    ,         })
       aadd(aMatImp, {aRecBLn, aParBLn, aRecBTt, aParBTt, "IM", "RECEITA BRUTA      (R$)|", .t., "Receita Bruta   -", "(R$)| "})
       aadd(aMatImp, {       ,        ,        ,        , "DL",                           ,    ,                    ,         })
       aadd(aMatImp, {aImpLI3, aParLI3, aImpI3T, aParI3T, "IM", "ICMS               (R$)|", .t., "ICMS            -", "(R$)| "})
       aadd(aMatImp, {aImpLI4, aParLI4, aImpI4T, aParI4T, "IM", "PIS                (R$)|", .t., "PIS             -", "(R$)| "})
       aadd(aMatImp, {aImpLI5, aParLI5, aImpI5T, aParI5T, "IM", "COFINS             (R$)|", .t., "COFINS          -", "(R$)| "})
       aadd(aMatImp, {aComLin, aParCLn, aComTot, aParCTt, "IM", "Comissão           (R$)|", .t., "Comissão        -", "(R$)| "})
       aadd(aMatImp, {       ,        ,        ,        , "P1",                           ,    ,                    ,         })
       aadd(aMatImp, {aDedLin, aParDDL, aDedTot, aParDDT, "IM", "Total das Deduções (R$)|", .t., "Deduções        -", "(R$)| "})
       aadd(aMatImp, {       ,        ,        ,        , "P1",                           ,    ,                    ,         })
       aadd(aMatImp, {aLiqLin, aParLqL, aLiqTot, aParLqT, "IM", "RECEITA LIQUIDA    (R$)|", .t., "Receita Liquida -", "(R$)| "})
       aadd(aMatImp, {       ,        ,        ,        , "DL",                           ,    ,                    ,         })
       aadd(aMatImp, {aCusMtL, aParMtL, aCusMtT, aParMtT, "IM", "Custo Materia Prima(R$)|", .t., "Custo Materia P.-", "(R$)| "})
       aadd(aMatImp, {aCusEmL, aParEmL, aCusEmT, aParEmT, "IM", "Custo Embalagem    (R$)|", .t., "Custo Embalagem -", "(R$)| "})
       aadd(aMatImp, {       ,        ,        ,        , "P1",                           ,    ,                    ,         })
       aadd(aMatImp, {aCusPrL, aParPrL, aCusPrT, aParPrT, "IM", "CUSTO DE PRODUÇÃO  (R$)|", .t., "Custo Produção  -", "(R$)| "})
       aadd(aMatImp, {       ,        ,        ,        , "P1",                           ,    ,                    ,         })
       aadd(aMatImp, {aCusMCL, aParMCL, aCusMCT, aParMCT, "IM", "MARGEM CONTRIBUIÇÃO(R$)|", .t., "Margem Contrib. -", "(R$)| "})
       aadd(aMatImp, {       ,        ,        ,        , "DL",                           ,    ,                    ,         })
       
       /**********************************************************************************************************/
       /*** IMPRESSÃO DA PRIMEIRA PARTE DO RELATÓRIO. SERÁ IMPRESSO NO MAXIMO 7 MESES NA PRIMEIRA FOLHA.       ***/
       /*** CASO A QUANTIDADE DE MESES SEJA MENOR QUE SETE MESES O ACUMULADO SAIRÁ NA PRIMEIRA FOLHA TAMBÉM    ***/
       /**********************************************************************************************************/
       If nFol01 > 0
          If mv_par02 == 1 // Impressão do relatório Analítico
             If mv_par04 == 1
                Titulo := Alltrim(Titulo)+' '+Alltrim(mv_par01)+' - Analitico (Linha)'
                nNumFol := Iif(nFol02 > 0, 2, 1)
                nImpAcu := Iif(nNumFol == 1, 1, 2)
                For nA := 1 To nNumFol
                    nColIni := Iif(nA      == 1,      2,        9)
                    nColFim := Iif(nA      == 1,Iif(xUltMes < 7, xUltMes + 1, 0), nFol02+1) // +1 significa a impressão dos acumulados
                    cPulLin := Iif(nA      == 1, cPul01, cPul02)
                    For nZ := 1 To Len(aLinha)
                        If nNumFol == 2 .and. nA == 2
                           nLin := 0 ; nLin := Cabec(Titulo, Cabec3, Cabec4, NomeProg, Tamanho, nTipo) ; nLin += 1
                           @ nLin, 000 PSAY "LINHA: "+aLinha[nZ][1]
                             nLin += 2
                        Else
                           nLin := 0 ; nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo) ; nLin += 1
                           @ nLin, 000 PSAY "LINHA: "+aLinha[nZ][1]
                             nLin += 2
                        Endif
                        For nB := 1 To Len(aMatImp)
                            If aMatImp[nB][5] $ 'IM'
                               IMPX03_1(aMatImp[nB][1], aMatImp[nB][2], aMatImp[nB][3], aMatImp[nB][4], nLin, nColIni, nColFim, aMatImp[nB][6], nImpAcu, nA, aMatImp[nB][7], nZ, "LN")
                            ElseIf aMatImp[nB][5] $ 'P1'
                                   @ nLin, 000 PSAY cPulLin
                            //ElseIf aMatImp[nB][5] $ 'DL'
                            Endif
                            nLin += 1
                        Next
                    Next
                Next
             Else
                Titulo := Alltrim(Titulo)+' '+Alltrim(mv_par01)+' - Analitico'
                nNumFol := Iif(nFol02 > 0, 2, 1)
                nImpAcu := Iif(nNumFol == 1, 1, 2)
                For nA := 1 To nNumFol
                    nColIni := Iif(nA      == 1,      2,        9)
                    nColFim := Iif(nA      == 1,Iif(xUltMes < 7, xUltMes + 1, 0), nFol02+1) // +1 significa a impressão dos acumulados
                    cPulLin := Iif(nA      == 1, cPul01, cPul02)
                    If nNumFol == 2 .and. nA == 2
                       nLin := 0 ; nLin := Cabec(Titulo, Cabec3, Cabec4, NomeProg, Tamanho, nTipo) ; nLin += 1
                    Else
                       nLin := 0 ; nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo) ; nLin += 1
                    Endif
                    For nB := 1 To Len(aMatImp)
                        If aMatImp[nB][5] $ 'IM'
                           For nZ := 1 To Len(aLinha)
                               IMPX03_2(aMatImp[nB][1], aMatImp[nB][2], aMatImp[nB][3], aMatImp[nB][4], nLin, nColIni, nColFim, aMatImp[nB][8]+aLinha[nZ][1]+aMatImp[nB][9], nImpAcu, nA, aMatImp[nB][7], nZ, "LN")
                               nLin += 1
                           Next
                           @ nLin, 000 PSAY cPulLin
                             nLin += 1
                           If Empty(mv_par03) //Totaliza se não for por linha
                              IMPX03_2(aMatImp[nB][1], aMatImp[nB][2], aMatImp[nB][3], aMatImp[nB][4], nLin, nColIni, nColFim, aMatImp[nB][6], nImpAcu, nA, aMatImp[nB][7], nZ, "TT")
                              nLin += 1
                           Endif
                           If nB < Len(aMatImp)
                              If nNumFol == 2 .and. nA == 2
                                 nLin := 0 ; nLin := Cabec(Titulo, Cabec3, Cabec4, NomeProg, Tamanho, nTipo) ; nLin += 1
                              Else
                                 nLin := 0 ; nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo) ; nLin += 1
                              Endif
                           Endif
                        Endif
                    Next
                Next             
             Endif
          ElseIf mv_par02 == 2 // Impressão do Relatório Sintético
                 Titulo := Alltrim(Titulo)+' '+Alltrim(mv_par01)+' - Sintético'
                 nLin := 0 ; nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo) ; nLin += 1
                 nNumFol := Iif(nFol02 > 0, 2, 1)
                 nImpAcu := Iif(nNumFol == 1, 1, 2)
                 For nA := 1 To nNumFol
                     nColIni := Iif(nA      == 1,      2,      9)
                     nColFim := Iif(nA      == 1, Iif(xUltMes < 7, xUltMes + 1, 0), nFol02+1)
                     //nColFim := Iif(nA      == 1,      8, nFol02)
                     cPulLin := Iif(nA      == 1, cPul01, cPul02)
                     If nNumFol == 2 .and. nA == 2
                        nLin := Cabec(Titulo, Cabec3, Cabec4, NomeProg, Tamanho, nTipo)
                        nLin += 1
                     Endif
                     For nB := 1 To Len(aMatImp)
                         If aMatImp[nB][5] $ 'IM'
                            IMPX03_3(aMatImp[nB][1], aMatImp[nB][2], aMatImp[nB][3], aMatImp[nB][4], nLin, nColIni, nColFim, aMatImp[nB][6], nImpAcu, nA, aMatImp[nB][7])
                         ElseIf aMatImp[nB][5] $ 'P1'
                                @ nLin, 000 PSAY cPulLin
                         //ElseIf aMatImp[nB][5] $ 'DL'
                         Endif
                         nLin += 1
                     Next
                 Next
          Else // Impressão do Relatório Sintético x Linha
             Titulo := Alltrim(Titulo)+' '+Alltrim(mv_par01)+' - Sintético x Linha'
             nLin := 0 ; nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo) ; nLin += 1
             nSomPar := 0
             For nY := 1 To Len(aLinha)
                 @ nLin, 002 PSAY aLinha[nY][1] Picture "99"
                 @ nLin, 006 PSAY "|"
                 @ nLin, 008 PSAY aVolLin[nY][14] Picture "@E 999,999,999.99"
                 @ nLin, 023 PSAY aParVLn[nY][14] Picture "@E 9999.99"
                 @ nLin, 031 PSAY "|"
                 @ nLin, 033 PSAY aVolDLn[nY][14] Picture "@E 999,999,999.99"
                 @ nLin, 048 PSAY aParDVL[nY][14] Picture "@E 9999.99"
                 @ nLin, 056 PSAY "|"
                 @ nLin, 058 PSAY aRecLin[nY][14] Picture "@E 999,999,999.99"
                 @ nLin, 073 PSAY aParRLn[nY][14] Picture "@E 9999.99"
                 @ nLin, 081 PSAY "|"
                 @ nLin, 083 PSAY aRecDLn[nY][14] Picture "@E 999,999,999.99"
                 @ nLin, 098 PSAY aParDRL[nY][14] Picture "@E 9999.99"
                 @ nLin, 106 PSAY "|"
                 @ nLin, 108 PSAY ((aRecDLn[nY][14] / aRecDTt[1][14]) * 100) Picture "@E 9999.99"
                 @ nLin, 116 PSAY "|"
                   nLin += 1
                   nSomPar += ((aRecDLn[nY][14] / aRecDTt[1][14]) * 100)
             Next
             @ nLin, 000 PSAY cPul01
               nLin += 1
             @ nLin, 000 PSAY "TOTAL |"
             @ nLin, 008 PSAY aVolTot[1][14] Picture "@E 999,999,999.99"
             @ nLin, 023 PSAY aParVTt[1][14] Picture "@E 9999.99"
             @ nLin, 031 PSAY "|"
             @ nLin, 033 PSAY aVolDTt[1][14] Picture "@E 999,999,999.99"
             @ nLin, 048 PSAY aParDVt[1][14] Picture "@E 9999.99"
             @ nLin, 056 PSAY "|"
             @ nLin, 058 PSAY aRecTot[1][14] Picture "@E 999,999,999.99"
             @ nLin, 073 PSAY aParRTt[1][14] Picture "@E 9999.99"
             @ nLin, 081 PSAY "|"
             @ nLin, 083 PSAY aRecDTt[1][14] Picture "@E 999,999,999.99"
             @ nLin, 098 PSAY aParDTt[1][14] Picture "@E 9999.99"
             @ nLin, 106 PSAY "|"
             @ nLin, 108 PSAY nSomPar        Picture "@E 9999.99"
             @ nLin, 116 PSAY "|"
               nLin += 1
             @ nLin, 000 PSAY cPul01
          Endif
       Endif
       
       SET DEVICE TO SCREEN

       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()

Return

/*****************************************************************************************************/
/***                               IMPRESSÃO DO RELATÓRIO ANALÍTICO (Linha)                        ***/
/*****************************************************************************************************/
Static Function IMPX03_1(aMatLin, aParLin, aMatTot, aParTot, nLin, nColIni, nColFim, cSubTit, nImpAcu,;
                         nA     , lImpPar, nZ, cOpc)
       Local nX
       Local nCol1 :=0 ; Local nCol2 :=0 ; Local nCol3 :=0
       @ nLin, 000 PSAY cSubTit
         nCol1 := 25 ; nCol2 := 23 ; nCol3 := 40
       For nX := nColIni To nColFim
           @ nLin, nCol1 PSAY aMatLin[nZ][nX] Picture "@E 999,999,999.99"
             nCol1 += 25
           If lImpPar
              @ nLin, nCol3 PSAY aParLin[nZ][nX] Picture "@E 9999.99"
           Endif
             nCol3 += 25 ; nCol2 += 25
           @ nLin, nCol2 PSAY "|"
       Next
       If nImpAcu == nA
          @ nLin, nCol1 PSAY aMatLin[nZ][14] Picture "@E 999,999,999.99"
            nCol2 += 25
          If lImpPar
             @ nLin, nCol3 PSAY aParLin[nZ][14] Picture "@E 9999.99"
          Endif
          @ nLin, nCol2 PSAY "|"
            nCol1 := 25 ; nCol2 := 23 ; nCol3 := 40 ; nLin += 1
       Endif
Return

/*****************************************************************************************************/
/***                               IMPRESSÃO DO RELATÓRIO ANALÍTICO                                ***/
/*****************************************************************************************************/
Static Function IMPX03_2(aMatLin, aParLin, aMatTot, aParTot, nLin, nColIni, nColFim, cSubTit, nImpAcu,;
                         nA     , lImpPar, nZ, cOpc)
       Local nX
       Local nCol1 :=0 ; Local nCol2 :=0 ; Local nCol3 :=0
       @ nLin, 000 PSAY cSubTit
       nCol1 := 25 ; nCol2 := 23 ; nCol3 := 40
       If cOpc == 'LN'
          For nX := nColIni To nColFim
              @ nLin, nCol1 PSAY aMatLin[nZ][nX] Picture "@E 999,999,999.99"
                nCol1 += 25
              @ nLin, nCol3 PSAY aParLin[nZ][nX] Picture "@E 9999.99"
                nCol3 += 25 ; nCol2 += 25
              @ nLin, nCol2 PSAY "|"
          Next
          If nImpAcu == nA
             @ nLin, nCol1 PSAY aMatLin[nZ][14] Picture "@E 999,999,999.99"
               nCol2 += 25
             @ nLin, nCol3 PSAY aParLin[nZ][14] Picture "@E 9999.99"
             @ nLin, nCol2 PSAY "|"
               nCol1 := 25 ; nCol2 := 23 ; nCol3 := 40 ; nLin += 1
          Endif
       Else
          nCol1 := 25 ; nCol2 := 23 ; nCol3 := 40
          For nX := nColIni To nColFim
              @ nLin, nCol1 PSAY aMatTot[1][nX] Picture "@E 999,999,999.99"
                nCol1 += 25
              @ nLin, nCol3 PSAY aParTot[1][nX] Picture "@E 9999.99"
                nCol3 += 25 ; nCol2 += 25
              @ nLin, nCol2 PSAY "|"
          Next
          If nImpAcu == nA
             @ nLin, nCol1 PSAY aMatTot[1][14] Picture "@E 999,999,999.99"
               nCol2 += 25
             @ nLin, nCol3 PSAY aParTot[1][14] Picture "@E 9999.99"
             @ nLin, nCol2 PSAY "|"
               nCol1 := 25 ; nCol2 := 23 ; nCol3 := 40 ; nLin += 1
          Endif
       Endif
Return

/*****************************************************************************************************/
/***                               IMPRESSÃO DO RELATÓRIO SINTÉTICO                                ***/
/*****************************************************************************************************/
Static Function IMPX03_3(aMatLin, aParLin, aMatTot, aParTot, nLin, nColIni, nColFim, cSubTit, nImpAcu,;
                         nA, lImpPar)
       Local nY
       Local nCol1 :=0 ; Local nCol2 :=0 ; Local nCol3 :=0
       @ nLin, 000 PSAY cSubTit
         nCol1 := 25 ; nCol2 := 23 ; nCol3 := 40
       For nY := nColIni To nColFim
           @ nLin, nCol1 PSAY aMatTot[1][nY] Picture "@E 999,999,999.99"
             nCol1 += 25 
           If lImpPar
              @ nLin, nCol3 PSAY aParTot[1][nY] Picture "@E 9999.99"
           Endif
             nCol3 += 25 ; nCol2 += 25
           @ nLin, nCol2 PSAY "|"
       Next
       If nImpAcu == nA
          @ nLin, nCol1 PSAY aMatTot[1][14] Picture "@E 999,999,999.99"
            nCol2 += 25
          If lImpPar
             @ nLin, nCol3 PSAY aParTot[1][14] Picture "@E 9999.99"
          Endif
          @ nLin, nCol2 PSAY "|"
       Endif
Return

/******************************************************************************************************************/
/***                                        BUSCA INFORMAÇÕES DO FATURAMENTO                                    ***/
/******************************************************************************************************************/
Static Function FATX02_2(aVolLin, aVolTot, aParVLn, aParVTt, aRecLin, aRecTot, aParRLn, aParRTt)
       Local cQry1 := ""
       Local nX, nY
       If mv_par02 == 1 .or. mv_par02 == 3// Analitico (Todas as Linhas ou linha conforme o parâmetro mv_par03)
             cQry1 := ""
             cQry1 += "SELECT SZE.ZE_LINHA AS LINHA, "
             cQry1 += "       SUM(SZE.ZE_Q01) AS QMES01, SUM(SZE.ZE_V01) AS VMES01, SUM(SZE.ZE_Q02) AS QMES02, SUM(SZE.ZE_V02) AS VMES02, "
             cQry1 += "       SUM(SZE.ZE_Q03) AS QMES03, SUM(SZE.ZE_V03) AS VMES03, SUM(SZE.ZE_Q04) AS QMES04, SUM(SZE.ZE_V04) AS VMES04, "
             cQry1 += "       SUM(SZE.ZE_Q05) AS QMES05, SUM(SZE.ZE_V05) AS VMES05, SUM(SZE.ZE_Q06) AS QMES06, SUM(SZE.ZE_V06) AS VMES06, "
             cQry1 += "       SUM(SZE.ZE_Q07) AS QMES07, SUM(SZE.ZE_V07) AS VMES07, SUM(SZE.ZE_Q08) AS QMES08, SUM(SZE.ZE_V08) AS VMES08, "
             cQry1 += "       SUM(SZE.ZE_Q09) AS QMES09, SUM(SZE.ZE_V09) AS VMES09, SUM(SZE.ZE_Q10) AS QMES10, SUM(SZE.ZE_V10) AS VMES10, "
             cQry1 += "       SUM(SZE.ZE_Q11) AS QMES11, SUM(SZE.ZE_V11) AS VMES11, SUM(SZE.ZE_Q12) AS QMES12, SUM(SZE.ZE_V12) AS VMES12  "
       Else
          cQry1 := ""          
          cQry1 += "SELECT SUM(SZE.ZE_Q01) AS QMES01, SUM(SZE.ZE_V01) AS VMES01, SUM(SZE.ZE_Q02) AS QMES02, SUM(SZE.ZE_V02) AS VMES02, "
          cQry1 += "       SUM(SZE.ZE_Q03) AS QMES03, SUM(SZE.ZE_V03) AS VMES03, SUM(SZE.ZE_Q04) AS QMES04, SUM(SZE.ZE_V04) AS VMES04, "
          cQry1 += "       SUM(SZE.ZE_Q05) AS QMES05, SUM(SZE.ZE_V05) AS VMES05, SUM(SZE.ZE_Q06) AS QMES06, SUM(SZE.ZE_V06) AS VMES06, "
          cQry1 += "       SUM(SZE.ZE_Q07) AS QMES07, SUM(SZE.ZE_V07) AS VMES07, SUM(SZE.ZE_Q08) AS QMES08, SUM(SZE.ZE_V08) AS VMES08, "
          cQry1 += "       SUM(SZE.ZE_Q09) AS QMES09, SUM(SZE.ZE_V09) AS VMES09, SUM(SZE.ZE_Q10) AS QMES10, SUM(SZE.ZE_V10) AS VMES10, "
          cQry1 += "       SUM(SZE.ZE_Q11) AS QMES11, SUM(SZE.ZE_V11) AS VMES11, SUM(SZE.ZE_Q12) AS QMES12, SUM(SZE.ZE_V12) AS VMES12  "
       Endif
       cQry1 += "FROM "+RetSqlName("SZE")+" SZE "
       cQry1 += "WHERE SZE.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZE.ZE_FILIAL  = '01' "
       cQry1 += "  AND SZE.ZE_EMPRESA = '01' "
       cQry1 += "  AND SZE.ZE_ANO     = '"+mv_par01+"' "
       If !Empty(mv_par03)
          cQry1 += "AND SZE.ZE_LINHA = '"+mv_par03+"' "
       Endif
       If mv_par02 == 1 .or. mv_par02 == 3
          cQry1 += "GROUP BY SZE.ZE_LINHA "
          cQry1 += "ORDER BY SZE.ZE_LINHA "
       Endif
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             If mv_par02 == 1 .or. mv_par02 == 3
                nPos := aScan(aVolLin, {|x| x[1] == TCQ->LINHA} )
                If nPos == 0
                   aadd(aVolLin, { TCQ->LINHA, TCQ->QMES01, TCQ->QMES02, TCQ->QMES03, TCQ->QMES04, TCQ->QMES05, TCQ->QMES06, TCQ->QMES07, TCQ->QMES08, TCQ->QMES09, TCQ->QMES10, TCQ->QMES11, TCQ->QMES12,;
                                (TCQ->QMES01+TCQ->QMES02+TCQ->QMES03+TCQ->QMES04+TCQ->QMES05+TCQ->QMES06+TCQ->QMES07+TCQ->QMES08+TCQ->QMES09+TCQ->QMES10+TCQ->QMES11+TCQ->QMES12) } )
                Else
                   aVolLin[nPos][02] += TCQ->QMES01 ; aVolLin[nPos][03] += TCQ->QMES02 ; aVolLin[nPos][04] += TCQ->QMES03
                   aVolLin[nPos][05] += TCQ->QMES04 ; aVolLin[nPos][06] += TCQ->QMES05 ; aVolLin[nPos][07] += TCQ->QMES06
                   aVolLin[nPos][08] += TCQ->QMES07 ; aVolLin[nPos][09] += TCQ->QMES08 ; aVolLin[nPos][10] += TCQ->QMES09
                   aVolLin[nPos][11] += TCQ->QMES10 ; aVolLin[nPos][12] += TCQ->QMES11 ; aVolLin[nPos][13] += TCQ->QMES12
                   aVolLin[nPos][14] += (TCQ->QMES01+TCQ->QMES02+TCQ->QMES03+TCQ->QMES04+TCQ->QMES05+TCQ->QMES06+TCQ->QMES07+TCQ->QMES08+TCQ->QMES09+TCQ->QMES10+TCQ->QMES11+TCQ->QMES12)
                Endif
                nPos := aScan(aRecLin, {|x| x[1] == TCQ->LINHA} )
                If nPos == 0
                   aadd(aRecLin, { TCQ->LINHA, TCQ->VMES01, TCQ->VMES02, TCQ->VMES03, TCQ->VMES04, TCQ->VMES05, TCQ->VMES06, TCQ->VMES07, TCQ->VMES08, TCQ->VMES09, TCQ->VMES10, TCQ->VMES11, TCQ->VMES12,;
                                   (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12) } )
                Else
                   aRecLin[nPos][02] += TCQ->VMES01 ; aRecLin[nPos][03] += TCQ->VMES02 ; aRecLin[nPos][04] += TCQ->VMES03
                   aRecLin[nPos][05] += TCQ->VMES04 ; aRecLin[nPos][06] += TCQ->VMES05 ; aRecLin[nPos][07] += TCQ->VMES06
                   aRecLin[nPos][08] += TCQ->VMES07 ; aRecLin[nPos][09] += TCQ->VMES08 ; aRecLin[nPos][10] += TCQ->VMES09
                   aRecLin[nPos][11] += TCQ->VMES10 ; aRecLin[nPos][12] += TCQ->VMES11 ; aRecLin[nPos][13] += TCQ->VMES12
                   aRecLin[nPos][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)
                Endif
             Endif
             aRecTot[1][02] += TCQ->VMES01 ; aRecTot[1][03] += TCQ->VMES02 ; aRecTot[1][04] += TCQ->VMES03
             aRecTot[1][05] += TCQ->VMES04 ; aRecTot[1][06] += TCQ->VMES05 ; aRecTot[1][07] += TCQ->VMES06
             aRecTot[1][08] += TCQ->VMES07 ; aRecTot[1][09] += TCQ->VMES08 ; aRecTot[1][10] += TCQ->VMES09
             aRecTot[1][11] += TCQ->VMES10 ; aRecTot[1][12] += TCQ->VMES11 ; aRecTot[1][13] += TCQ->VMES12
             aRecTot[1][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)
             aVolTot[1][02] += TCQ->QMES01 ; aVolTot[1][03] += TCQ->QMES02 ; aVolTot[1][04] += TCQ->QMES03
             aVolTot[1][05] += TCQ->QMES04 ; aVolTot[1][06] += TCQ->QMES05 ; aVolTot[1][07] += TCQ->QMES06
             aVolTot[1][08] += TCQ->QMES07 ; aVolTot[1][09] += TCQ->QMES08 ; aVolTot[1][10] += TCQ->QMES09
             aVolTot[1][11] += TCQ->QMES10 ; aVolTot[1][12] += TCQ->QMES11 ; aVolTot[1][13] += TCQ->QMES12
             aVolTot[1][14] += (TCQ->QMES01+TCQ->QMES02+TCQ->QMES03+TCQ->QMES04+TCQ->QMES05+TCQ->QMES06+TCQ->QMES07+TCQ->QMES08+TCQ->QMES09+TCQ->QMES10+TCQ->QMES11+TCQ->QMES12)
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       If (mv_par02 == 1 .or. mv_par02 == 3) .and. mv_par04 == 1
          For nY := 1 To Len(aVolLin)
              For nX := 2 To 14
                  aParRLn[aScan(aParRLn, {|x| x[1] == aRecLin[nY][1]})][nX] += ((aRecLin[nY][nX] / aRecLin[nY][nX] ) * 100 )
              Next
          Next
       Else
          For nY := 1 To Len(aVolLin)
              For nX := 2 To 14
                  aParVLn[aScan(aParVLn, {|x| x[1] == aVolLin[nY][1]})][nX] += ((aVolLin[nY][nX] / aVolTot[1][nX] ) * 100 )
                  aParRLn[aScan(aParRLn, {|x| x[1] == aRecLin[nY][1]})][nX] += ((aRecLin[nY][nX] / aRecTot[1][nX] ) * 100 )
                  aParVTt[1][nX] += ((aVolLin[nY][nX] / aVolTot[1][nX]) * 100)
              Next
          Next
          For nX := 2 To 14
              aParRTt[1][nX] += ((aRecTot[1][nX] / aRecTot[1][nX]) * 100)
          Next
       Endif
Return

/*****************************************************************************************************************/
/***                                        BUSCA INFORMAÇÕES DAS DEVOLUÇÕES                                   ***/
/*****************************************************************************************************************/
Static Function FATX02_3(aVolDLn, aVolDTt, aParDVL, aParDVT, aRecDLn, aRecDTt, aParDRL, aParDTt,;
                         aVolLin, aVolTot, aRecLin, aRecTot)
       Local cQry1 := ""
       Local nX, nY
       If mv_par02 == 1 .or. mv_par02 == 3      // Analitico (Todas as Linhas ou linha conforme o parâmetro mv_par03)
             cQry1 := ""
             cQry1 += "SELECT SZE.ZE_LINHA AS LINHA, "
             cQry1 += "       SUM(SZE.ZE_Q01) AS QMES01, SUM(SZE.ZE_V01) AS VMES01, SUM(SZE.ZE_Q02) AS QMES02, SUM(SZE.ZE_V02) AS VMES02, "
             cQry1 += "       SUM(SZE.ZE_Q03) AS QMES03, SUM(SZE.ZE_V03) AS VMES03, SUM(SZE.ZE_Q04) AS QMES04, SUM(SZE.ZE_V04) AS VMES04, "
             cQry1 += "       SUM(SZE.ZE_Q05) AS QMES05, SUM(SZE.ZE_V05) AS VMES05, SUM(SZE.ZE_Q06) AS QMES06, SUM(SZE.ZE_V06) AS VMES06, "
             cQry1 += "       SUM(SZE.ZE_Q07) AS QMES07, SUM(SZE.ZE_V07) AS VMES07, SUM(SZE.ZE_Q08) AS QMES08, SUM(SZE.ZE_V08) AS VMES08, "
             cQry1 += "       SUM(SZE.ZE_Q09) AS QMES09, SUM(SZE.ZE_V09) AS VMES09, SUM(SZE.ZE_Q10) AS QMES10, SUM(SZE.ZE_V10) AS VMES10, "
             cQry1 += "       SUM(SZE.ZE_Q11) AS QMES11, SUM(SZE.ZE_V11) AS VMES11, SUM(SZE.ZE_Q12) AS QMES12, SUM(SZE.ZE_V12) AS VMES12  "
       Else
          cQry1 := ""          
          cQry1 += "SELECT SUM(SZE.ZE_Q01) AS QMES01, SUM(SZE.ZE_V01) AS VMES01, SUM(SZE.ZE_Q02) AS QMES02, SUM(SZE.ZE_V02) AS VMES02, "
          cQry1 += "       SUM(SZE.ZE_Q03) AS QMES03, SUM(SZE.ZE_V03) AS VMES03, SUM(SZE.ZE_Q04) AS QMES04, SUM(SZE.ZE_V04) AS VMES04, "
          cQry1 += "       SUM(SZE.ZE_Q05) AS QMES05, SUM(SZE.ZE_V05) AS VMES05, SUM(SZE.ZE_Q06) AS QMES06, SUM(SZE.ZE_V06) AS VMES06, "
          cQry1 += "       SUM(SZE.ZE_Q07) AS QMES07, SUM(SZE.ZE_V07) AS VMES07, SUM(SZE.ZE_Q08) AS QMES08, SUM(SZE.ZE_V08) AS VMES08, "
          cQry1 += "       SUM(SZE.ZE_Q09) AS QMES09, SUM(SZE.ZE_V09) AS VMES09, SUM(SZE.ZE_Q10) AS QMES10, SUM(SZE.ZE_V10) AS VMES10, "
          cQry1 += "       SUM(SZE.ZE_Q11) AS QMES11, SUM(SZE.ZE_V11) AS VMES11, SUM(SZE.ZE_Q12) AS QMES12, SUM(SZE.ZE_V12) AS VMES12  "
       Endif
       cQry1 += "FROM "+RetSqlName("SZE")+" SZE "
       cQry1 += "WHERE SZE.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZE.ZE_FILIAL  = '"+xFilial("SZE")+"' "
       cQry1 += "  AND SZE.ZE_EMPRESA = 'DV' "
       cQry1 += "  AND SZE.ZE_ANO     = '"+mv_par01+"' "
       If !Empty(mv_par03)
          cQry1 += "AND SZE.ZE_LINHA = '"+mv_par03+"' "
       Endif
       If mv_par02 == 1 .or. mv_par02 == 3
          cQry1 += "GROUP BY SZE.ZE_LINHA "
          cQry1 += "ORDER BY SZE.ZE_LINHA "
       Endif
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             If mv_par02 == 1 .or. mv_par02 == 3
                nPos := aScan(aVolDLn, {|x| x[1] == TCQ->LINHA} )
                If nPos == 0
                   aadd(aVolDLn, { TCQ->LINHA, TCQ->QMES01, TCQ->QMES02, TCQ->QMES03, TCQ->QMES04, TCQ->QMES05, TCQ->QMES06, TCQ->QMES07, TCQ->QMES08, TCQ->QMES09, TCQ->QMES10, TCQ->QMES11, TCQ->QMES12,;
                                  (TCQ->QMES01+TCQ->QMES02+TCQ->QMES03+TCQ->QMES04+TCQ->QMES05+TCQ->QMES06+TCQ->QMES07+TCQ->QMES08+TCQ->QMES09+TCQ->QMES10+TCQ->QMES11+TCQ->QMES12) } )
                Else
                   aVolDLn[nPos][02] += TCQ->QMES01 ; aVolDLn[nPos][03] += TCQ->QMES02 ; aVolDLn[nPos][04] += TCQ->QMES03
                   aVolDLn[nPos][05] += TCQ->QMES04 ; aVolDLn[nPos][06] += TCQ->QMES05 ; aVolDLn[nPos][07] += TCQ->QMES06
                   aVolDLn[nPos][08] += TCQ->QMES07 ; aVolDLn[nPos][09] += TCQ->QMES08 ; aVolDLn[nPos][10] += TCQ->QMES09
                   aVolDLn[nPos][11] += TCQ->QMES10 ; aVolDLn[nPos][12] += TCQ->QMES11 ; aVolDLn[nPos][13] += TCQ->QMES12
                   aVolDLn[nPos][14] += (TCQ->QMES01+TCQ->QMES02+TCQ->QMES03+TCQ->QMES04+TCQ->QMES05+TCQ->QMES06+TCQ->QMES07+TCQ->QMES08+TCQ->QMES09+TCQ->QMES10+TCQ->QMES11+TCQ->QMES12)
                Endif
                nPos := aScan(aRecDLn, {|x| x[1] == TCQ->LINHA} )
                If nPos == 0
                   aadd(aRecDLn, { TCQ->LINHA, TCQ->VMES01, TCQ->VMES02, TCQ->VMES03, TCQ->VMES04, TCQ->VMES05, TCQ->VMES06, TCQ->VMES07, TCQ->VMES08, TCQ->VMES09, TCQ->VMES10, TCQ->VMES11, TCQ->VMES12,;
                                  (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12) } )
                Else
                   aRecDLn[nPos][02] += TCQ->VMES01 ; aRecDLn[nPos][03] += TCQ->VMES02 ; aRecDLn[nPos][04] += TCQ->VMES03
                   aRecDLn[nPos][05] += TCQ->VMES04 ; aRecDLn[nPos][06] += TCQ->VMES05 ; aRecDLn[nPos][07] += TCQ->VMES06
                   aRecDLn[nPos][08] += TCQ->VMES07 ; aRecDLn[nPos][09] += TCQ->VMES08 ; aRecDLn[nPos][10] += TCQ->VMES09
                   aRecDLn[nPos][11] += TCQ->VMES10 ; aRecDLn[nPos][12] += TCQ->VMES11 ; aRecDLn[nPos][13] += TCQ->VMES12
                   aRecDLn[nPos][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)
                Endif
             Endif
             aVolDTt[1][02] += TCQ->QMES01 ; aVolDTt[1][03] += TCQ->QMES02 ; aVolDTt[1][04] += TCQ->QMES03
             aVolDTt[1][05] += TCQ->QMES04 ; aVolDTt[1][06] += TCQ->QMES05 ; aVolDTt[1][07] += TCQ->QMES06
             aVolDTt[1][08] += TCQ->QMES07 ; aVolDTt[1][09] += TCQ->QMES08 ; aVolDTt[1][10] += TCQ->QMES09
             aVolDTt[1][11] += TCQ->QMES10 ; aVolDTt[1][12] += TCQ->QMES11 ; aVolDTt[1][13] += TCQ->QMES12
             aVolDTt[1][14] += (TCQ->QMES01+TCQ->QMES02+TCQ->QMES03+TCQ->QMES04+TCQ->QMES05+TCQ->QMES06+TCQ->QMES07+TCQ->QMES08+TCQ->QMES09+TCQ->QMES10+TCQ->QMES11+TCQ->QMES12)
             aRecDTt[1][02] += TCQ->VMES01 ; aRecDTt[1][03] += TCQ->VMES02 ; aRecDTt[1][04] += TCQ->VMES03
             aRecDTt[1][05] += TCQ->VMES04 ; aRecDTt[1][06] += TCQ->VMES05 ; aRecDTt[1][07] += TCQ->VMES06
             aRecDTt[1][08] += TCQ->VMES07 ; aRecDTt[1][09] += TCQ->VMES08 ; aRecDTt[1][10] += TCQ->VMES09
             aRecDTt[1][11] += TCQ->VMES10 ; aRecDTt[1][12] += TCQ->VMES11 ; aRecDTt[1][13] += TCQ->VMES12
             aRecDTt[1][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       If (mv_par02 == 1 .or. mv_par02 == 3) .and. mv_par04 == 1
          For nY := 1 To Len(aVolDLn)
              For nX := 2 To 14
                  aParDVL[aScan(aParDVL, {|x| x[1] == aVolDLn[nY][1]})][nX] += ((aVolDLn[nY][nX] / aVolLin[nY][nX] ) * 100 )
                  aParDRL[aScan(aParDVL, {|x| x[1] == aVolDLn[nY][1]})][nX] += ((aRecDLn[nY][nX] / aRecLin[nY][nx] ) * 100 )
              Next
          Next
       Else
          For nY := 2 To 14
              aParDVT[1][nY] := ((aVolDTt[1][nY] / aVolTot[1][nY]) * 100 )
              aParDTt[1][nY] := ((aRecDTt[1][nY] / aRecTot[1][nY]) * 100 )
          Next
          For nY := 1 To Len(aVolDLn)
              For nX := 2 To 14
                  aParDVL[aScan(aParDVL, {|x| x[1] == aVolDLn[nY][1]})][nX] += ((aVolDLn[nY][nX] / aVolDTt[1][nX] ) * 100 )
                  aParDRL[aScan(aParDVL, {|x| x[1] == aVolDLn[nY][1]})][nX] += ((aRecDLn[nY][nX] / aRecLin[nY][nx] ) * 100 )
              Next
          Next
       Endif
Return

/*****************************************************************************************************************/
/***                                        BUSCA INFORMAÇÕES DOS IMPOSTOS                                     ***/
/*****************************************************************************************************************/
Static Function FATX02_4(aImpLI1, aImpI1T, aParLI1, aParI1T, aImpLI2, aImpI2T, aParLI2, aParI2T,;
                         aImpLI3, aImpI3T, aParLI3, aParI3T, aRecLin, aRecTot)
       Local cQry1 := ""
       Local nX, nY
       If mv_par02 == 1 .or. mv_par02 == 3      // Analitico (Todas as Linhas ou linha conforme o parâmetro mv_par03)
             cQry1 := ""
             cQry1 += "SELECT SZE.ZE_LINHA AS LINHA, SZE.ZE_EMPRESA AS EMPRESA, "
             cQry1 += "       SUM(SZE.ZE_Q01) AS QMES01, SUM(SZE.ZE_V01) AS VMES01, SUM(SZE.ZE_Q02) AS QMES02, SUM(SZE.ZE_V02) AS VMES02, "
             cQry1 += "       SUM(SZE.ZE_Q03) AS QMES03, SUM(SZE.ZE_V03) AS VMES03, SUM(SZE.ZE_Q04) AS QMES04, SUM(SZE.ZE_V04) AS VMES04, "
             cQry1 += "       SUM(SZE.ZE_Q05) AS QMES05, SUM(SZE.ZE_V05) AS VMES05, SUM(SZE.ZE_Q06) AS QMES06, SUM(SZE.ZE_V06) AS VMES06, "
             cQry1 += "       SUM(SZE.ZE_Q07) AS QMES07, SUM(SZE.ZE_V07) AS VMES07, SUM(SZE.ZE_Q08) AS QMES08, SUM(SZE.ZE_V08) AS VMES08, "
             cQry1 += "       SUM(SZE.ZE_Q09) AS QMES09, SUM(SZE.ZE_V09) AS VMES09, SUM(SZE.ZE_Q10) AS QMES10, SUM(SZE.ZE_V10) AS VMES10, "
             cQry1 += "       SUM(SZE.ZE_Q11) AS QMES11, SUM(SZE.ZE_V11) AS VMES11, SUM(SZE.ZE_Q12) AS QMES12, SUM(SZE.ZE_V12) AS VMES12  "
       Else
          cQry1 := ""          
          cQry1 += "SELECT SZE.ZE_EMPRESA AS EMPRESA, "
          cQry1 += "       SUM(SZE.ZE_Q01) AS QMES01, SUM(SZE.ZE_V01) AS VMES01, SUM(SZE.ZE_Q02) AS QMES02, SUM(SZE.ZE_V02) AS VMES02, "
          cQry1 += "       SUM(SZE.ZE_Q03) AS QMES03, SUM(SZE.ZE_V03) AS VMES03, SUM(SZE.ZE_Q04) AS QMES04, SUM(SZE.ZE_V04) AS VMES04, "
          cQry1 += "       SUM(SZE.ZE_Q05) AS QMES05, SUM(SZE.ZE_V05) AS VMES05, SUM(SZE.ZE_Q06) AS QMES06, SUM(SZE.ZE_V06) AS VMES06, "
          cQry1 += "       SUM(SZE.ZE_Q07) AS QMES07, SUM(SZE.ZE_V07) AS VMES07, SUM(SZE.ZE_Q08) AS QMES08, SUM(SZE.ZE_V08) AS VMES08, "
          cQry1 += "       SUM(SZE.ZE_Q09) AS QMES09, SUM(SZE.ZE_V09) AS VMES09, SUM(SZE.ZE_Q10) AS QMES10, SUM(SZE.ZE_V10) AS VMES10, "
          cQry1 += "       SUM(SZE.ZE_Q11) AS QMES11, SUM(SZE.ZE_V11) AS VMES11, SUM(SZE.ZE_Q12) AS QMES12, SUM(SZE.ZE_V12) AS VMES12  "
       Endif
       cQry1 += "FROM "+RetSqlName("SZE")+" SZE "
       cQry1 += "WHERE SZE.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZE.ZE_FILIAL  = '01' "
       cQry1 += "  AND SUBSTRING(SZE.ZE_EMPRESA, 1, 1) = 'I' "
       cQry1 += "  AND SZE.ZE_ANO     = '"+mv_par01+"' "
       If !Empty(mv_par03)
          cQry1 += "AND SZE.ZE_LINHA = '"+mv_par03+"' "
       Endif
       If mv_par02 == 1 .or. mv_par02 == 3
          cQry1 += "GROUP BY SZE.ZE_LINHA, SZE.ZE_EMPRESA "
          cQry1 += "ORDER BY SZE.ZE_LINHA "
       Else
          cQry1 += "GROUP BY SZE.ZE_EMPRESA "
          cQry1 += "ORDER BY SZE.ZE_EMPRESA "
       Endif
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             If mv_par02 == 1 .or. mv_par02 == 3
                If TCQ->EMPRESA $ 'I1'
                   nPos := aScan(aImpLI1, {|x| x[1] == TCQ->LINHA} )
                   If nPos == 0
                      aadd(aImpLI1, { TCQ->LINHA, TCQ->VMES01, TCQ->VMES02, TCQ->VMES03, TCQ->VMES04, TCQ->VMES05, TCQ->VMES06, TCQ->VMES07, TCQ->VMES08, TCQ->VMES09, TCQ->VMES10, TCQ->VMES11, TCQ->VMES12,;
                                    (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12) } )
                   Else
                      aImpLI1[nPos][02] += TCQ->VMES01 ; aImpLI1[nPos][03] += TCQ->VMES02 ; aImpLI1[nPos][04] += TCQ->VMES03
                      aImpLI1[nPos][05] += TCQ->VMES04 ; aImpLI1[nPos][06] += TCQ->VMES05 ; aImpLI1[nPos][07] += TCQ->VMES06
                      aImpLI1[nPos][08] += TCQ->VMES07 ; aImpLI1[nPos][09] += TCQ->VMES08 ; aImpLI1[nPos][10] += TCQ->VMES09
                      aImpLI1[nPos][11] += TCQ->VMES10 ; aImpLI1[nPos][12] += TCQ->VMES11 ; aImpLI1[nPos][13] += TCQ->VMES12
                      aImpLI1[nPos][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)
                   Endif
                ElseIf TCQ->EMPRESA $ 'I2'
                       nPos := aScan(aImpLI2, {|x| x[1] == TCQ->LINHA} )
                       If nPos == 0
                          aadd(aImpLI2, { TCQ->LINHA, TCQ->VMES01, TCQ->VMES02, TCQ->VMES03, TCQ->VMES04, TCQ->VMES05, TCQ->VMES06, TCQ->VMES07, TCQ->VMES08, TCQ->VMES09, TCQ->VMES10, TCQ->VMES11, TCQ->VMES12,;
                                         (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12) } )
                       Else
                          aImpLI2[nPos][02] += TCQ->VMES01 ; aImpLI2[nPos][03] += TCQ->VMES02 ; aImpLI2[nPos][04] += TCQ->VMES03
                          aImpLI2[nPos][05] += TCQ->VMES04 ; aImpLI2[nPos][06] += TCQ->VMES05 ; aImpLI2[nPos][07] += TCQ->VMES06
                          aImpLI2[nPos][08] += TCQ->VMES07 ; aImpLI2[nPos][09] += TCQ->VMES08 ; aImpLI2[nPos][10] += TCQ->VMES09
                          aImpLI2[nPos][11] += TCQ->VMES10 ; aImpLI2[nPos][12] += TCQ->VMES11 ; aImpLI2[nPos][13] += TCQ->VMES12
                          aImpLI2[nPos][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)
                   Endif
                ElseIf TCQ->EMPRESA $ 'I3'
                       nPos := aScan(aImpLI3, {|x| x[1] == TCQ->LINHA} )
                       If nPos == 0
                          aadd(aImpLI3, { TCQ->LINHA, TCQ->VMES01, TCQ->VMES02, TCQ->VMES03, TCQ->VMES04, TCQ->VMES05, TCQ->VMES06, TCQ->VMES07, TCQ->VMES08, TCQ->VMES09, TCQ->VMES10, TCQ->VMES11, TCQ->VMES12,;
                                         (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12) } )
                       Else
                          aImpLI3[nPos][02] += TCQ->VMES01 ; aImpLI3[nPos][03] += TCQ->VMES02 ; aImpLI3[nPos][04] += TCQ->VMES03
                          aImpLI3[nPos][05] += TCQ->VMES04 ; aImpLI3[nPos][06] += TCQ->VMES05 ; aImpLI3[nPos][07] += TCQ->VMES06
                          aImpLI3[nPos][08] += TCQ->VMES07 ; aImpLI3[nPos][09] += TCQ->VMES08 ; aImpLI3[nPos][10] += TCQ->VMES09
                          aImpLI3[nPos][11] += TCQ->VMES10 ; aImpLI3[nPos][12] += TCQ->VMES11 ; aImpLI3[nPos][13] += TCQ->VMES12
                          aImpLI3[nPos][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)
                       Endif
                Endif
             Endif
             If TCQ->EMPRESA $ 'I1' //IPI
                aImpI1T[1][02] += TCQ->VMES01 ; aImpI1T[1][03] += TCQ->VMES02 ; aImpI1T[1][04] += TCQ->VMES03
                aImpI1T[1][05] += TCQ->VMES04 ; aImpI1T[1][06] += TCQ->VMES05 ; aImpI1T[1][07] += TCQ->VMES06
                aImpI1T[1][08] += TCQ->VMES07 ; aImpI1T[1][09] += TCQ->VMES08 ; aImpI1T[1][10] += TCQ->VMES09
                aImpI1T[1][11] += TCQ->VMES10 ; aImpI1T[1][12] += TCQ->VMES11 ; aImpI1T[1][13] += TCQ->VMES12
                aImpI1T[1][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)
             ElseIf TCQ->EMPRESA $ 'I2' //ICMS Subst. Tribut.
                    aImpI2T[1][02] += TCQ->VMES01 ; aImpI2T[1][03] += TCQ->VMES02 ; aImpI2T[1][04] += TCQ->VMES03
                    aImpI2T[1][05] += TCQ->VMES04 ; aImpI2T[1][06] += TCQ->VMES05 ; aImpI2T[1][07] += TCQ->VMES06
                    aImpI2T[1][08] += TCQ->VMES07 ; aImpI2T[1][09] += TCQ->VMES08 ; aImpI2T[1][10] += TCQ->VMES09
                    aImpI2T[1][11] += TCQ->VMES10 ; aImpI2T[1][12] += TCQ->VMES11 ; aImpI2T[1][13] += TCQ->VMES12
                    aImpI2T[1][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)
             ElseIf TCQ->EMPRESA $ 'I3' //
                    aImpI3T[1][02] += TCQ->VMES01 ; aImpI3T[1][03] += TCQ->VMES02 ; aImpI3T[1][04] += TCQ->VMES03
                    aImpI3T[1][05] += TCQ->VMES04 ; aImpI3T[1][06] += TCQ->VMES05 ; aImpI3T[1][07] += TCQ->VMES06
                    aImpI3T[1][08] += TCQ->VMES07 ; aImpI3T[1][09] += TCQ->VMES08 ; aImpI3T[1][10] += TCQ->VMES09
                    aImpI3T[1][11] += TCQ->VMES10 ; aImpI3T[1][12] += TCQ->VMES11 ; aImpI3T[1][13] += TCQ->VMES12
                    aImpI3T[1][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       If (mv_par02 == 1 .or. mv_par02 == 3) .and. mv_par04 == 1
          For nY := 1 To Len(aImpLI1)
              For nX := 2 To 14
                  aParLI1[aScan(aParLI1, {|x| x[1] == aImpLI1[nY][1]})][nX] += ((aImpLI1[nY][nX] / aRecLin[nY][nx] ) * 100 )
                  aParLI2[aScan(aParLI2, {|x| x[1] == aImpLI2[nY][1]})][nX] += ((aImpLI2[nY][nX] / aRecLin[nY][nx] ) * 100 )
                  aParLI3[aScan(aParLI3, {|x| x[1] == aImpLI3[nY][1]})][nX] += ((aImpLI3[nY][nX] / aRecLin[nY][nx] ) * 100 )
              Next
          Next
       Else
          For nX := 2 To 14
              aParI1T[1][nX] := ((aImpI1T[1][nX] / aRecTot[1][nX] ) * 100 )
              aParI2T[1][nX] := ((aImpI2T[1][nX] / aRecTot[1][nX] ) * 100 )
              aParI3T[1][nX] := ((aImpI3T[1][nX] / aRecTot[1][nX] ) * 100 )
          Next
          For nY := 1 To Len(aImpLI1)
              For nX := 2 To 14
                  aParLI1[aScan(aParLI1, {|x| x[1] == aImpLI1[nY][1]})][nX] += ((aImpLI1[nY][nX] / aRecLin[nY][nx] ) * 100 )
                  aParLI2[aScan(aParLI2, {|x| x[1] == aImpLI2[nY][1]})][nX] += ((aImpLI2[nY][nX] / aRecLin[nY][nx] ) * 100 )
                  aParLI3[aScan(aParLI3, {|x| x[1] == aImpLI3[nY][1]})][nX] += ((aImpLI3[nY][nX] / aRecLin[nY][nx] ) * 100 )
              Next
          Next
       Endif
Return

/*****************************************************************************************************************/
/***                                        CALCULANDO INFORMAÇÕES DA RECEITA BRUTA                            ***/
/*****************************************************************************************************************/
Static Function FATX02_5(aRecBLn, aRecBTt, aParBLn, aParBTt, aRecLin, aRecTot, aRecDLn, aRecDTt,;
                         aImpLI4, aImpI4T, aParLI4, aParI4T, aImpLI5, aImpI5T, aParLI5, aParI5T,;
                         aImpLI1,  aImpI1T,  aImpLI2,  aImpI2T, aLinha)
       Local nY, nX
       For nY := 1 To Len(aLinha)
           For nX := 2 To 14
               aRecBLn[nY][nX] += aRecLin[nY][nX] - aImpLI1[nY][nX] - aImpLI2[nY][nX] - aRecDLn[nY][nX]
               aImpLI4[nY][nX] +=  (aRecBLn[nY][nX] * 0.0065)
               aImpLI5[nY][nX] +=  (aRecBLn[nY][nX] * 0.03)
           Next
       Next
       For nX := 2 To 14
           aRecBTt[1][nX] += aRecTot[1][nX] - aImpI1T[1][nX] - aImpI2T[1][nX] - aRecDTt[1][nX]
           aImpI4T[1][nX] +=  (aRecBTt[1][nX] * 0.0065)
           aImpI5T[1][nX] +=  (aRecBTt[1][nX] * 0.03)
       Next
       If (mv_par02 == 1 .or. mv_par02 == 3) .and. mv_par04 == 1
          For nY := 1 To Len(aLinha)
              For nX := 2 To 14
                  aParBLn[nY][nX] += ((aRecBLn[nY][nX] / aRecLin[nY][nX]) * 100)
                  aParLI4[nY][nX] += ((aImpLI4[nY][nX] / aRecBLn[nY][nX]) * 100)
                  aParLI5[nY][nX] += ((aImpLI5[nY][nX] / aRecBLn[nY][nX]) * 100)
              Next
          Next
       Else
          For nY := 1 To Len(aLinha)
              For nX := 2 To 14
                  aParBLn[nY][nX] += ((aRecBLn[nY][nX] / aRecLin[nY][nX]) * 100)
                  aParLI4[nY][nX] += ((aImpLI4[nY][nX] / aRecBLn[nY][nX]) * 100)
                  aParLI5[nY][nX] += ((aImpLI5[nY][nX] / aRecBLn[nY][nX]) * 100)
              Next
          Next
          For nX := 2 To 14
              aParBTt[1][nX] += ((aRecBTt[1][nX] / aRecTot[1][nX]) * 100)
              aParI4T[1][nX] += ((aImpI4T[1][nX] / aRecBTt[1][nX]) * 100)
              aParI5T[1][nX] += ((aImpI5T[1][nX] / aRecBTt[1][nX]) * 100)
          Next
       Endif
Return

/*****************************************************************************************************************/
/***                                        CALCULANDO INFORMAÇÕES DA COMISSÃO                                 ***/
/*****************************************************************************************************************/
Static Function FATX02_6(aComLin, aComTot, aParCLn, aParCTt, aRecBLn, aRecBTt)
       Local cQry1 := ""
       Local nX, nY
       If mv_par02 == 1 .or. mv_par02 == 3       // Analitico (Todas as Linhas ou linha conforme o parâmetro mv_par03)
             cQry1 := ""
             cQry1 += "SELECT SZE.ZE_LINHA AS LINHA, "
             cQry1 += "       SUM(SZE.ZE_Q01) AS QMES01, SUM(SZE.ZE_V01) AS VMES01, SUM(SZE.ZE_Q02) AS QMES02, SUM(SZE.ZE_V02) AS VMES02, "
             cQry1 += "       SUM(SZE.ZE_Q03) AS QMES03, SUM(SZE.ZE_V03) AS VMES03, SUM(SZE.ZE_Q04) AS QMES04, SUM(SZE.ZE_V04) AS VMES04, "
             cQry1 += "       SUM(SZE.ZE_Q05) AS QMES05, SUM(SZE.ZE_V05) AS VMES05, SUM(SZE.ZE_Q06) AS QMES06, SUM(SZE.ZE_V06) AS VMES06, "
             cQry1 += "       SUM(SZE.ZE_Q07) AS QMES07, SUM(SZE.ZE_V07) AS VMES07, SUM(SZE.ZE_Q08) AS QMES08, SUM(SZE.ZE_V08) AS VMES08, "
             cQry1 += "       SUM(SZE.ZE_Q09) AS QMES09, SUM(SZE.ZE_V09) AS VMES09, SUM(SZE.ZE_Q10) AS QMES10, SUM(SZE.ZE_V10) AS VMES10, "
             cQry1 += "       SUM(SZE.ZE_Q11) AS QMES11, SUM(SZE.ZE_V11) AS VMES11, SUM(SZE.ZE_Q12) AS QMES12, SUM(SZE.ZE_V12) AS VMES12  "
       Else
          cQry1 := ""          
          cQry1 += "SELECT "
          cQry1 += "       SUM(SZE.ZE_Q01) AS QMES01, SUM(SZE.ZE_V01) AS VMES01, SUM(SZE.ZE_Q02) AS QMES02, SUM(SZE.ZE_V02) AS VMES02, "
          cQry1 += "       SUM(SZE.ZE_Q03) AS QMES03, SUM(SZE.ZE_V03) AS VMES03, SUM(SZE.ZE_Q04) AS QMES04, SUM(SZE.ZE_V04) AS VMES04, "
          cQry1 += "       SUM(SZE.ZE_Q05) AS QMES05, SUM(SZE.ZE_V05) AS VMES05, SUM(SZE.ZE_Q06) AS QMES06, SUM(SZE.ZE_V06) AS VMES06, "
          cQry1 += "       SUM(SZE.ZE_Q07) AS QMES07, SUM(SZE.ZE_V07) AS VMES07, SUM(SZE.ZE_Q08) AS QMES08, SUM(SZE.ZE_V08) AS VMES08, "
          cQry1 += "       SUM(SZE.ZE_Q09) AS QMES09, SUM(SZE.ZE_V09) AS VMES09, SUM(SZE.ZE_Q10) AS QMES10, SUM(SZE.ZE_V10) AS VMES10, "
          cQry1 += "       SUM(SZE.ZE_Q11) AS QMES11, SUM(SZE.ZE_V11) AS VMES11, SUM(SZE.ZE_Q12) AS QMES12, SUM(SZE.ZE_V12) AS VMES12  "
       Endif
       cQry1 += "FROM "+RetSqlName("SZE")+" SZE "
       cQry1 += "WHERE SZE.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZE.ZE_FILIAL  = '01' "
       cQry1 += "  AND SZE.ZE_EMPRESA = 'CM' "
       cQry1 += "  AND SZE.ZE_ANO     = '"+mv_par01+"' "
       If !Empty(mv_par03)
          cQry1 += "AND SZE.ZE_LINHA = '"+mv_par03+"' "
       Endif
       If mv_par02 == 1 .or. mv_par02 == 3
          cQry1 += "GROUP BY SZE.ZE_LINHA "
          cQry1 += "ORDER BY SZE.ZE_LINHA "
       Endif
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             If mv_par02 == 1 .or. mv_par02 == 3
                nPos := aScan(aComLin, {|x| x[1] == TCQ->LINHA} )
                If nPos == 0
                      aadd(aComLin, { TCQ->LINHA, TCQ->VMES01, TCQ->VMES02, TCQ->VMES03, TCQ->VMES04, TCQ->VMES05, TCQ->VMES06, TCQ->VMES07, TCQ->VMES08, TCQ->VMES09, TCQ->VMES10, TCQ->VMES11, TCQ->VMES12,;
                                    (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12) } )
                Else
                   aComLin[nPos][02] += TCQ->VMES01 ; aComLin[nPos][03] += TCQ->VMES02 ; aComLin[nPos][04] += TCQ->VMES03
                   aComLin[nPos][05] += TCQ->VMES04 ; aComLin[nPos][06] += TCQ->VMES05 ; aComLin[nPos][07] += TCQ->VMES06
                   aComLin[nPos][08] += TCQ->VMES07 ; aComLin[nPos][09] += TCQ->VMES08 ; aComLin[nPos][10] += TCQ->VMES09
                   aComLin[nPos][11] += TCQ->VMES10 ; aComLin[nPos][12] += TCQ->VMES11 ; aComLin[nPos][13] += TCQ->VMES12
                   aComLin[nPos][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)
                Endif
             Endif
             aComTot[1][02] += TCQ->VMES01 ; aComTot[1][03] += TCQ->VMES02 ; aComTot[1][04] += TCQ->VMES03
             aComTot[1][05] += TCQ->VMES04 ; aComTot[1][06] += TCQ->VMES05 ; aComTot[1][07] += TCQ->VMES06
             aComTot[1][08] += TCQ->VMES07 ; aComTot[1][09] += TCQ->VMES08 ; aComTot[1][10] += TCQ->VMES09
             aComTot[1][11] += TCQ->VMES10 ; aComTot[1][12] += TCQ->VMES11 ; aComTot[1][13] += TCQ->VMES12
             aComTot[1][14] += (TCQ->VMES01+TCQ->VMES02+TCQ->VMES03+TCQ->VMES04+TCQ->VMES05+TCQ->VMES06+TCQ->VMES07+TCQ->VMES08+TCQ->VMES09+TCQ->VMES10+TCQ->VMES11+TCQ->VMES12)
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       If (mv_par02 == 1 .or. mv_par02 == 3) .and. mv_par04 == 1
          For nY := 1 To Len(aComLin)
              For nX := 2 To 14
                  aParCLn[nY][nX] += ((aComLin[nY][nX] / aRecBLn[nY][nX]) * 100)
              Next
          Next
       Else
          For nY := 1 To Len(aComLin)
              For nX := 2 To 14
                  aParCLn[nY][nX] += ((aComLin[nY][nX] / aRecBLn[nY][nX]) * 100)
              Next
          Next
          For nX := 2 To 14
              aParCTt[1][nX] += ((aComTot[1][nX] / aRecBTt[1][nX]) * 100)
          Next
       Endif
Return

/*****************************************************************************************************************/
/***                                        CALCULOS FINAIS DAS RECEITAS                                       ***/
/*****************************************************************************************************************/
Static Function FATX02_7(aDedLin, aDedTot, aParDDL, aParDDT, aLiqLin, aLiqTot, aParLqL, aParLqT,;
                         aImpLI3, aImpI3T, aImpLI4, aImpI4T, aImpLI5, aImpI5T, aComLin, aComTot,;
                         aRecBLn, aRecBTt, aRecLin, aRecTot )
       Local nX, NY
       For nY := 1 To Len(aDedLin)
           For nX := 2 To 14
              aDedLin[nY][nX] += aImpLI3[nY][nX] + aImpLI4[nY][nX] + aImpLI5[nY][nX] + aComLin[nY][nX]
              aLiqLin[nY][nX] += aRecBLn[nY][nX] - aDedLin[nY][nX]
           Next
       Next
       For nY := 2 To 14
           aDedTot[1][nY] += aImpI3T[1][nY] + aImpI4T[1][nY] + aImpI5T[1][nY] + aComTot[1][nY]
           aLiqTot[1][nY] += aRecBTt[1][nY] - aDedTot[1][nY]
       Next
       If (mv_par02 == 1 .or. mv_par02 == 3) .and. mv_par04 == 1
          For nY := 1 To Len(aDedLin)
              For nX := 2 To 14
                  aParDDL[nY][nX] += (( aDedLin[nY][nX] / aRecBLn[nY][nX]) * 100)
                  aParLqL[nY][nX] += (( aLiqLin[nY][nX] / aRecLin[nY][nX]) * 100)
              Next
          Next
       Else
          For nY := 1 To Len(aDedLin)
              For nX := 2 To 14
                  aParDDL[nY][nX] += (( aDedLin[nY][nX] / aRecBLn[nY][nX]) * 100)
                  aParLqL[nY][nX] += (( aLiqLin[nY][nX] / aRecLin[nY][nX]) * 100)
              Next
          Next
          For nY := 2 To 14
              aParDDT[1][nY] += (( aDedTot[1][nY] / aRecBTt[1][nY]) * 100)
              aParLqT[1][nY] += (( aLiqTot[1][nY] / aRecTot[1][nY]) * 100)
          Next
       Endif
Return

/*****************************************************************************************************************/
/***                           CALCULOS DOS CUSTOS DAS MATERIAS PRIMAS E EMBALAGENS                            ***/
/*****************************************************************************************************************/
Static Function FATX02_8(aCusMtL, aCusMtT, aParMtL, aParMtT, aCusEML, aCusEMT, aParEML, aParEMT,;
                         aCusPrL, aCusPrT, aParPrL, aParPrT, aCusMCL, aCusMCT, aParMCL, aParMCT,;
                         aLiqLin, aLiqTot, aParLqL, aParLqT, aRecBLn, aRecBTt, aRecLin, aRecTot,;
                         aLinha)
       Local cQry1 := ""
       Local nX, nY
       If mv_par02 == 1 .or. mv_par02 == 3       // Analitico (Todas as Linhas ou linha conforme o parâmetro mv_par03)
          cQry1 := ""
          cQry1 += "SELECT SZE.ZE_LINHA AS LINHA, "
          cQry1 += "       SUM(SZE.ZE_CMP01) AS CMPM01, SUM(SZE.ZE_CME01) AS CMEM01, SUM(SZE.ZE_CMP02) AS CMPM02, SUM(SZE.ZE_CME02) AS CMEM02, "
          cQry1 += "       SUM(SZE.ZE_CMP03) AS CMPM03, SUM(SZE.ZE_CME03) AS CMEM03, SUM(SZE.ZE_CMP04) AS CMPM04, SUM(SZE.ZE_CME04) AS CMEM04, "
          cQry1 += "       SUM(SZE.ZE_CMP05) AS CMPM05, SUM(SZE.ZE_CME05) AS CMEM05, SUM(SZE.ZE_CMP06) AS CMPM06, SUM(SZE.ZE_CME06) AS CMEM06, "
          cQry1 += "       SUM(SZE.ZE_CMP07) AS CMPM07, SUM(SZE.ZE_CME07) AS CMEM07, SUM(SZE.ZE_CMP08) AS CMPM08, SUM(SZE.ZE_CME08) AS CMEM08, "
          cQry1 += "       SUM(SZE.ZE_CMP09) AS CMPM09, SUM(SZE.ZE_CME09) AS CMEM09, SUM(SZE.ZE_CMP10) AS CMPM10, SUM(SZE.ZE_CME10) AS CMEM10, "
          cQry1 += "       SUM(SZE.ZE_CMP11) AS CMPM11, SUM(SZE.ZE_CME11) AS CMEM11, SUM(SZE.ZE_CMP12) AS CMPM12, SUM(SZE.ZE_CME12) AS CMEM12  "
       Else
          cQry1 := ""
          cQry1 += "SELECT "
          cQry1 += "       SUM(SZE.ZE_CMP01) AS CMPM01, SUM(SZE.ZE_CME01) AS CMEM01, SUM(SZE.ZE_CMP02) AS CMPM02, SUM(SZE.ZE_CME02) AS CMEM02, "
          cQry1 += "       SUM(SZE.ZE_CMP03) AS CMPM03, SUM(SZE.ZE_CME03) AS CMEM03, SUM(SZE.ZE_CMP04) AS CMPM04, SUM(SZE.ZE_CME04) AS CMEM04, "
          cQry1 += "       SUM(SZE.ZE_CMP05) AS CMPM05, SUM(SZE.ZE_CME05) AS CMEM05, SUM(SZE.ZE_CMP06) AS CMPM06, SUM(SZE.ZE_CME06) AS CMEM06, "
          cQry1 += "       SUM(SZE.ZE_CMP07) AS CMPM07, SUM(SZE.ZE_CME07) AS CMEM07, SUM(SZE.ZE_CMP08) AS CMPM08, SUM(SZE.ZE_CME08) AS CMEM08, "
          cQry1 += "       SUM(SZE.ZE_CMP09) AS CMPM09, SUM(SZE.ZE_CME09) AS CMEM09, SUM(SZE.ZE_CMP10) AS CMPM10, SUM(SZE.ZE_CME10) AS CMEM10, "
          cQry1 += "       SUM(SZE.ZE_CMP11) AS CMPM11, SUM(SZE.ZE_CME11) AS CMEM11, SUM(SZE.ZE_CMP12) AS CMPM12, SUM(SZE.ZE_CME12) AS CMEM12  "
       Endif
       cQry1 += "FROM "+RetSqlName("SZE")+" SZE "
       cQry1 += "WHERE SZE.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZE.ZE_FILIAL  = '"+xFilial("SZE")+"' "
       cQry1 += "  AND SZE.ZE_ANO     = '"+mv_par01+"' "
       cQry1 += "  AND SZE.ZE_LINHA   NOT IN('') "
       If !Empty(mv_par03)
          cQry1 += "AND SZE.ZE_LINHA = '"+mv_par03+"' "
       Endif
       If mv_par02 == 1 .or. mv_par02 == 3
          cQry1 += "GROUP BY SZE.ZE_LINHA "
          cQry1 += "ORDER BY SZE.ZE_LINHA "
       Endif
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             If mv_par02 == 1 .or. mv_par02 == 3
                nPos := aScan(aCusMtL, {|x| x[1] == TCQ->LINHA} )
                If nPos == 0
                   aadd(aCusMtL, { TCQ->LINHA, TCQ->CMPM01, TCQ->CMPM02, TCQ->CMPM03, TCQ->CMPM04, TCQ->CMPM05, TCQ->CMPM06, TCQ->CMPM07, TCQ->CMPM08, TCQ->CMPM09, TCQ->CMPM10, TCQ->CMPM11, TCQ->CMPM12,;
                                 (TCQ->CMPM01+TCQ->CMPM02+TCQ->CMPM03+TCQ->CMPM04+TCQ->CMPM05+TCQ->CMPM06+TCQ->CMPM07+TCQ->CMPM08+TCQ->CMPM09+TCQ->CMPM10+TCQ->CMPM11+TCQ->CMPM12) } )
                   aadd(aCusEML, { TCQ->LINHA, TCQ->CMEM01, TCQ->CMEM02, TCQ->CMEM03, TCQ->CMEM04, TCQ->CMEM05, TCQ->CMEM06, TCQ->CMEM07, TCQ->CMEM08, TCQ->CMEM09, TCQ->CMEM10, TCQ->CMEM11, TCQ->CMEM12,;
                                 (TCQ->CMEM01+TCQ->CMEM02+TCQ->CMEM03+TCQ->CMEM04+TCQ->CMEM05+TCQ->CMEM06+TCQ->CMEM07+TCQ->CMEM08+TCQ->CMEM09+TCQ->CMEM10+TCQ->CMEM11+TCQ->CMEM12) } )
                Else
                   aCusMtL[nPos][02] += TCQ->CMPM01 ; aCusMtL[nPos][03] += TCQ->CMPM02 ; aCusMtL[nPos][04] += TCQ->CMPM03
                   aCusMtL[nPos][05] += TCQ->CMPM04 ; aCusMtL[nPos][06] += TCQ->CMPM05 ; aCusMtL[nPos][07] += TCQ->CMPM06
                   aCusMtL[nPos][08] += TCQ->CMPM07 ; aCusMtL[nPos][09] += TCQ->CMPM08 ; aCusMtL[nPos][10] += TCQ->CMPM09
                   aCusMtL[nPos][11] += TCQ->CMPM10 ; aCusMtL[nPos][12] += TCQ->CMPM11 ; aCusMtL[nPos][13] += TCQ->CMPM12
                   aCusMtL[nPos][14] += (TCQ->CMPM01+TCQ->CMPM02+TCQ->CMPM03+TCQ->CMPM04+TCQ->CMPM05+TCQ->CMPM06+TCQ->CMPM07+TCQ->CMPM08+TCQ->CMPM09+TCQ->CMPM10+TCQ->CMPM11+TCQ->CMPM12)
                   aCusEML[nPos][02] += TCQ->CMEM01 ; aCusEML[nPos][03] += TCQ->CMEM02 ; aCusEML[nPos][04] += TCQ->CMEM03
                   aCusEML[nPos][05] += TCQ->CMEM04 ; aCusEML[nPos][06] += TCQ->CMEM05 ; aCusEML[nPos][07] += TCQ->CMEM06
                   aCusEML[nPos][08] += TCQ->CMEM07 ; aCusEML[nPos][09] += TCQ->CMEM08 ; aCusEML[nPos][10] += TCQ->CMEM09
                   aCusEML[nPos][11] += TCQ->CMEM10 ; aCusEML[nPos][12] += TCQ->CMEM11 ; aCusEML[nPos][13] += TCQ->CMEM12
                   aCusEML[nPos][14] += (TCQ->CMEM01+TCQ->CMEM02+TCQ->CMEM03+TCQ->CMEM04+TCQ->CMEM05+TCQ->CMEM06+TCQ->CMEM07+TCQ->CMEM08+TCQ->CMEM09+TCQ->CMEM10+TCQ->CMEM11+TCQ->CMEM12)
                Endif
             Endif
             aCusMtT[1][02] += TCQ->CMPM01 ; aCusMtT[1][03] += TCQ->CMPM02 ; aCusMtT[1][04] += TCQ->CMPM03
             aCusMtT[1][05] += TCQ->CMPM04 ; aCusMtT[1][06] += TCQ->CMPM05 ; aCusMtT[1][07] += TCQ->CMPM06
             aCusMtT[1][08] += TCQ->CMPM07 ; aCusMtT[1][09] += TCQ->CMPM08 ; aCusMtT[1][10] += TCQ->CMPM09
             aCusMtT[1][11] += TCQ->CMPM10 ; aCusMtT[1][12] += TCQ->CMPM11 ; aCusMtT[1][13] += TCQ->CMPM12
             aCusMtT[1][14] += (TCQ->CMPM01+TCQ->CMPM02+TCQ->CMPM03+TCQ->CMPM04+TCQ->CMPM05+TCQ->CMPM06+TCQ->CMPM07+TCQ->CMPM08+TCQ->CMPM09+TCQ->CMPM10+TCQ->CMPM11+TCQ->CMPM12)
             aCusEMT[1][02] += TCQ->CMEM01 ; aCusEMT[1][03] += TCQ->CMEM02 ; aCusEMT[1][04] += TCQ->CMEM03
             aCusEMT[1][05] += TCQ->CMEM04 ; aCusEMT[1][06] += TCQ->CMEM05 ; aCusEMT[1][07] += TCQ->CMEM06
             aCusEMT[1][08] += TCQ->CMEM07 ; aCusEMT[1][09] += TCQ->CMEM08 ; aCusEMT[1][10] += TCQ->CMEM09
             aCusEMT[1][11] += TCQ->CMEM10 ; aCusEMT[1][12] += TCQ->CMEM11 ; aCusEMT[1][13] += TCQ->CMEM12
             aCusEMT[1][14] += (TCQ->CMEM01+TCQ->CMEM02+TCQ->CMEM03+TCQ->CMEM04+TCQ->CMEM05+TCQ->CMEM06+TCQ->CMEM07+TCQ->CMEM08+TCQ->CMEM09+TCQ->CMEM10+TCQ->CMEM11+TCQ->CMEM12)
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()

       For nY := 1 To Len(aLinha)
           For nX := 2 To 14
               aCusPRL[nY][nX] += aCusMTL[nY][nX] + aCusEML[nY][nX]
           Next
       Next
       For nX := 2 To 14
           aCusPRT[1][nX] += (aCusMTT[1][nX] + aCusEMT[1][nX])
           aCusMCT[1][nX] += (aLiqTot[1][nX] - aCusPRT[1][nX])
       Next

       If (mv_par02 == 1 .or. mv_par02 == 3) .and. mv_par04 == 1
          For nY := 1 To Len(aDedLin)
              For nX := 2 To 14
                  //aParDDL[nY][nX] += (( aDedLin[nY][nX] / aRecBLn[nY][nX]) * 100)
                  //aParLqL[nY][nX] += (( aLiqLin[nY][nX] / aRecLin[nY][nX]) * 100)
              Next
          Next
       Else
          For nY := 2 To 14
              aParMTt[1][nY] += (( aCusMTt[1][nY] / aRecTot[1][nY]) * 100)
              aParEmT[1][nY] += (( aCusEmT[1][nY] / aRecTot[1][nY]) * 100)
          Next
       Endif

Return

/******************************************************************************************************************/
/***                                        MONTA CABEÇALHO DO RELATÓRIO                                        ***/
/******************************************************************************************************************/
Static Function fMonCab(aVolTot, aMeses, Cabec1, Cabec2, cPul01, Cabec3, Cabec4, cPul02, nFol01, nFol02, xUltMes)
       Local nVolZer := 0 
       Local lTotMes := .t.
       Local nUltMes := 0
       Local nY
       //aVolTot("", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0) - Matriz
       //         1  2  3  4  5  6  7  8  9  0  1  2  3  4  - Posição
       //            1  2  3  4  5  6  7  8  9  0  1  2     - Mes
       If !mv_par02 == 3 //Cabeçalho dos relatórios por meses
          For nY := 2 To 13
              If lTotMes
                 If aVolTot[1][nY] == 0
                    nVolZer := nY - 1 ; lTotMes := .f.
                 Endif
              Endif
          Next
          nUltMes := Iif(nVolZer == 0, 12, (nVolZer - 1))
          nFol01  := Iif(nUltMes < 7, nUltMes, Iif(nUltMes == 7, 7, 7       ))
          nFol02  := Iif(nUltMes < 7, 0      , Iif(nUltMes == 7, 1, nUltMes ))
          nFolAcu := Iif(nUltMes < 7, 1      , Iif(nUltMes == 7, 2, 2       ))
       
          /*** CABEÇALHO DA 1º FOLHA DO RELATÓRIO ***/
          If nFol01 > 0
             Cabec1 := "   REFERENTE AO MÊS    |" ; Cabec2 := "                       |" ; cPul01 := "-----------------------+"
             For nY := 1 To nFol01
                 Cabec1 += aMeses[nY] ; Cabec1 += "|" ; Cabec2 += "     TOTAL       %Part. |" ; cPul01 += "------------------------+"
             Next
          Else
             Cabec1 := "   REFERENTE AO MÊS    |" ; Cabec2 := "                       |" ; cPul01 += "------------------------+"
          Endif
          If nFolAcu == 1
             Cabec1 += "       ACUMULADO        |" ; Cabec2 += "     TOTAL       %Part. |" ; cPul01 += "------------------------+"
          Endif
          /*** CABEÇALHO DA 2º FOLHA DO RELATÓRIO ***/
          If nFol02 > 0
             Cabec3 := "   REFERENTE AO MÊS    |" ; Cabec4 := "                       |" ; cPul02 := "-----------------------+"
             For nY := 8 To (nUltMes-1)
                 Cabec3 += aMeses[nY] ; Cabec3 += "|" ; Cabec4 += "     TOTAL       %Part. |" ; cPul02 += "------------------------+"
             Next
          Endif
          If nFolAcu == 2
             Cabec3 += "       ACUMULADO        |" ; Cabec4 += "     TOTAL       %Part. |" ; cPul02 += "-------------------------+"
          Endif
       Else //Cabeçalho do relatório por Linha
            //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
            //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
            //LINHA | VOLUME VENDIDO (LITROS)| VOLUME DEVOLV. (LITROS)|   RECEITA BRUTA (R$)   |    DEVOLUÇÕES (R$)     |         |
            //      |     TOTAL      % Part. |     TOTAL      % Part. |     TOTAL      % Part. |     TOTAL      % Part. | % Linha |
            //  99  | 999,999,999,99 9999.99 | 999,999,999,99 9999.99 | 999,999,999,99 9999.99 | 999,999,999,99 9999.99 | 9999.99 |
            //  99  | 999,999,999,99 9999.99 | 999,999,999,99 9999.99 | 999,999,999,99 9999.99 | 999,999,999,99 9999.99 | 9999.99 |
            Cabec1 := "LINHA | VOLUME VENDIDO (LITROS)| VOLUME DEVOLV. (LITROS)|   RECEITA BRUTA (R$)   |    DEVOLUÇÕES (R$)     |         |"
            Cabec2 := "      |     TOTAL      % Part. |     TOTAL      % Part. |     TOTAL      % Part. |     TOTAL      % Part. | % Linha |"
            cPul01 := "------+------------------------+------------------------+------------------------+------------------------+---------+"
       Endif
       xUltMes := nUltMes
       nFol01  := 1
Return

/************************************************************************************************/
/*** FMONAFI - Função para montar matrizes de faturamento e impostos.                         ***/
/************************************************************************************************/
Static Function fMonAFI(aLinha,;
                        aVolLin, aVolTot, aParVLn, aParVTt, aRecLin, aRecTot, aParRLn, aParRTt,;
                        aVolDLn, aVolDTt, aParDVL, aParDVT, aRecDLn, aRecDTt, aParDRL, aParDTt,;
                        aImpLI1, aImpI1T, aParLI1, aParI1T, aImpLI2, aImpI2T, aParLI2, aParI2T,;
                        aImpLI3, aImpI3T, aParLI3, aParI3T, aRecBLn, aRecBTt, aParBLn, aParBTt,;
                        aImpLI4, aImpI4T, aParLI4, aParI4T, aImpLI5, aImpI5T, aParLI5, aParI5T,;
                        aComLin, aComTot, aParCLn, aParCTt, aDedLin, aDedTot, aParDDL, aParDDT,;
                        aLiqLin, aLiqTot, aParLqL, aParLqT)
       DbSelectArea("SZ1")
       DbSetOrder(1)
       DbGoTop()
	   dbseek(xFilial("SZ1"))
       While !Eof() .and. (SZ1->Z1_FILIAL == xFilial("SZ1"))
             If Empty(mv_par03)
                aadd(aLinha,  {SZ1->Z1_LINHA})
                aadd(aVolLin, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParVLn, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                aadd(aRecLin, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParRLn, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                aadd(aVolDLn, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParDVL, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                aadd(aRecDLn, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParDRL, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                aadd(aImpLI1, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParLI1, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                aadd(aImpLI2, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParLI2, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                aadd(aImpLI3, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParLI3, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                aadd(aRecBLn, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParBLn, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                aadd(aImpLI4, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParLI4, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                aadd(aImpLI5, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParLI5, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                aadd(aComLin, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParCLn, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                aadd(aDedLin, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParDDL, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                aadd(aLiqLin, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParLqL, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
             Else
                If mv_par03 $ SZ1->Z1_LINHA
                   aadd(aLinha,  {SZ1->Z1_LINHA})
                   aadd(aVolLin, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParVLn, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                   aadd(aRecLin, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParRLn, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                   aadd(aVolDLn, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParDVL, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                   aadd(aRecDLn, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParDRL, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                   aadd(aImpLI1, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParLI1, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                   aadd(aImpLI2, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParLI2, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                   aadd(aImpLI3, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParLI3, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                   aadd(aRecBLn, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParBLn, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                   aadd(aImpLI4, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParLI4, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                   aadd(aImpLI5, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParLI5, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                   aadd(aComLin, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParCLn, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                   aadd(aDedLin, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParDDL, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                   aadd(aLiqLin, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParLqL, { SZ1->Z1_LINHA, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                Endif
             Endif
             DbSelectArea("SZ1")
             DbSkip()
       Enddo
       aadd(aVolTot, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParVTt, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aadd(aRecTot, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParRTt, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aadd(aVolDTt, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParDVT, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aadd(aRecDTt, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParDTt, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aadd(aImpI1T, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParI1T, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aadd(aImpI2T, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParI2T, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aadd(aImpI3T, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParI3T, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aadd(aRecBTt, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParBTt, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aadd(aImpI4T, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParI4T, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aadd(aImpI5T, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParI5T, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aadd(aComTot, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParCTt, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aadd(aDedTot, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParDDT, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aadd(aLiqTot, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParLqT, {'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aSort(aVolLin,,, {|x,y| x[1] < y[1]}) ; aSort(aParVLn,,, {|x,y| x[1] < y[1]})
       aSort(aRecLin,,, {|x,y| x[1] < y[1]}) ; aSort(aParRLn,,, {|x,y| x[1] < y[1]})
       aSort(aVolDLn,,, {|x,y| x[1] < y[1]}) ; aSort(aParDVL,,, {|x,y| x[1] < y[1]})
       aSort(aRecDLn,,, {|x,y| x[1] < y[1]}) ; aSort(aParDRL,,, {|x,y| x[1] < y[1]})
       aSort(aImpLI1,,, {|x,y| x[1] < y[1]}) ; aSort(aParLI1,,, {|x,y| x[1] < y[1]})
       aSort(aImpLI2,,, {|x,y| x[1] < y[1]}) ; aSort(aParLI2,,, {|x,y| x[1] < y[1]})
       aSort(aImpLI3,,, {|x,y| x[1] < y[1]}) ; aSort(aParLI3,,, {|x,y| x[1] < y[1]})
       aSort(aRecBLn,,, {|x,y| x[1] < y[1]}) ; aSort(aParBLn,,, {|x,y| x[1] < y[1]})
       aSort(aImpLI4,,, {|x,y| x[1] < y[1]}) ; aSort(aParLI4,,, {|x,y| x[1] < y[1]})
       aSort(aImpLI5,,, {|x,y| x[1] < y[1]}) ; aSort(aParLI5,,, {|x,y| x[1] < y[1]})
       aSort(aComLin,,, {|x,y| x[1] < y[1]}) ; aSort(aParCLn,,, {|x,y| x[1] < y[1]})
       aSort(aDedLin,,, {|x,y| x[1] < y[1]}) ; aSort(aParDDL,,, {|x,y| x[1] < y[1]})
       aSort(aLiqLin,,, {|x,y| x[1] < y[1]}) ; aSort(aParLqL,,, {|x,y| x[1] < y[1]})
Return

/************************************************************************************************/
/*** FMONACD - Função para montar matrizes de custos e despesas.                              ***/
/************************************************************************************************/
Static Function fMonACD(aLinha ,;
                        aCusMtL, aCusMtT, aParMtL, aParMtT, aCusEmL, aCusEmT, aParEmL, aParEmT,;
                        aCusPrL, aCusPrT, aParPrL, aParPrT, aCusMCL, aCusMCT, aParMCL, aParMCT )
       Local nY
       For nY := 1 To Len(aLinha)
           If Empty(mv_par03)
              aadd(aCusMtL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParMtL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
              aadd(aCusEmL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParEmL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
              aadd(aCusPrL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParPrL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
              aadd(aCusMCL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParMCL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
           Else
              If mv_par03 $ aLinha[nY][1]
                 aadd(aCusMtL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParMtL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                 aadd(aCusEmL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParEmL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                 aadd(aCusPrL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParPrL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                 aadd(aCusMCL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParMCL, { aLinha[nY][1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
              Endif
           Endif
       Next
       aadd(aCusMtT, { '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParMtT, { '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aadd(aCusEmT, { '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParEmT, { '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aadd(aCusPrT, { '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParPrT, { '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aadd(aCusMCT, { '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }) ; aadd(aParMCT, { '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
       aSort(aCusMtL,,, {|x,y| x[1] < y[1]}) ; aSort(aParMtL,,, {|x,y| x[1] < y[1]})
       aSort(aCusEmL,,, {|x,y| x[1] < y[1]}) ; aSort(aParEmL,,, {|x,y| x[1] < y[1]})
       aSort(aCusPrL,,, {|x,y| x[1] < y[1]}) ; aSort(aParPrL,,, {|x,y| x[1] < y[1]})
       aSort(aCusMCL,,, {|x,y| x[1] < y[1]}) ; aSort(aParMCL,,, {|x,y| x[1] < y[1]})
Return

/************************************************************************************************/
/*** VALPERG - Validação das perguntas para o relatório                                       ***/
/************************************************************************************************/
Static Function ValPerg()
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg, "01", "Ano                   ", "", "", "mv_ch1", "C", 04, 0, 0, "G", "", "mv_par01", ""         , "", "", "", "", ""         , "", "", "", "", ""                 , "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "02", "Analitico/Sintético   ", "", "", "mv_ch2", "N", 01, 0, 0, "C", "", "mv_par02", "Analitico", "", "", "", "", "Sintético", "", "", "", "", "Sintético x Linha", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "03", "Linha                 ", "", "", "mv_ch3", "C", 02, 0, 0, "G", "", "mv_par03", ""         , "", "", "", "", ""         , "", "", "", "", ""                 , "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "04", "Separa Linha por Folha", "", "", "mv_ch4", "N", 01, 0, 0, "C", "", "mv_par04", "Sim"      , "", "", "", "", "Não"      , "", "", "", "", ""                 , "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
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

//0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//  REFERENTE AO MÊS     |        Janeiro         |        Fevereiro       |         Março          |         Abril          |          Maio          |         Junho          |         Julho          |       ACUMULADO        |
//                       |        Setembro        |        Outubro         |        Novembro        |        Dezembro        |
//                       |     TOTAL       %Part. |     TOTAL       %Part. |     TOTAL       %Part. |     TOTAL       %Part. |     TOTAL       %Part. |     TOTAL       %Part. |     TOTAL       %Part. |     TOTAL       %Part. |
//Volume Vendido      (L)| 999.999.999,99 9999.99 | 999.999.999,99 9999.99 | 999.999.999,99 9999.99 | 999.999.999,99 9999.99 | 999.999.999,99  999.99 | 999.999.999,99  999.99 | 999.999.999,99  999.99 | 999.999.999,99  999.99 |
//Volume Devolvido    (L)|
//RECEITA BRUTA GERAL(R$)|
//IPI                (R$)|
//Subst. Tributaria  (R$)|
//Devolução          (R$)|
//RECEITA BRUTA      (R$)|
//ICMS               (R$)|
//PIS                (R$)|
//COFINS             (R$)|
//Comissão           (R$)|
//Total das Deduções (R$)|
//RECEITA LIQUIDA    (R$)|
//Volume Vendido  -99 (L)| 
//Volume Devolvido-99 (L)|
//Rec. Bruta Geral-99(R$)|
//IPI             -99(R$)|
//Subst. Tribut.  -99(R$)|
//Devolução       -99(R$)|
//Receita Bruta   -99(R$)|
//ICMS            -99(R$)|
//PIS             -99(R$)|
//COFINS          -99(R$)|
//Comissão Linha  -99(R$)|
//Deduções Linha  -99(R$)|
//Rec. Liq. Linha -99(R$)|
/*
Relatório BRFATX02 - Sintético

   REFERENTE AO MÊS    |        MES        |                           F Ó R M U L A S                           |
                       | TOTAL     % Part. | TOTAL                                     % Part.                   |
-----------------------+-------------------+---------------------------------------------------------------------+
Volume Vendido     (L) | aVolTot           |                                                                     
Volume Devolvido   (L) | aVolDTt   aParDVT |                                           (aVolDTt / aVolTot) * 100 |
-----------------------+-------------------+---------------------------------------------------------------------+
RECEITA BRUTA GERAL(R$)| aRecTot   aParRTt |                                           100                       |
                                                                                                                 
IPI                    | aImpI1T   aParI1T |                                           (aImpI1T / aRecTot) * 100 |
ICMS Subst. Tribut.(R$)| aImpI2T   aParI2T |                                           (aImpI2T / aRecTot) * 100 |
Devolução          (R$)| aRecDTt   aParDTt |                                           (aRecDTt / aRecTot) * 100 |
-----------------------+-------------------+---------------------------------------------------------------------+
RECEITA BRUTA      (R$)| aRecBTt   aParBTt | aRecTot - (aImpI1T + aImpI2T + aRecDTt)   (aRecBTt / aRecTot) * 100 |
                                                                                                                  
ICMS               (R$)| aImpI3T   aParI3T |                                           (aImpI3T / aRecTot) * 100 |
PIS                (R$)| aImpI4T   aParI4T |                                           (aImpI4T / aRecTot) * 100 |
COFINS             (R$)| aImpI5T   aParI5T |                                           (aImpI5T / aRecTot) * 100 |
Comissão           (R$)| aComTot   aParCTt |                                           (aComTot / aRecTot) * 100 |
-----------------------+-------------------+---------------------------------------------------------------------+
Total das Deduções (R$)| aDedTot   aParDDT | (aImpI3T + aImpI4T + aImpI5T + aComTot)   (aDedTot / aRecTot) * 100 |
-----------------------+-------------------+---------------------------------------------------------------------+
RECEITA LIQUIDA    (R$)| aLiqTot   aParLqT | aRecBTt - aDedTot                         (aLiqTot / aRecTot) * 100 |
                                                                                                                  
Custo Materia Prima(R$)| aCusMtT   aParMtT |                                           (aCusMtT / aRecTot) * 100 |
Custo Embalagem    (R$)| aCusEmT   aParEmT |                                           (aCusEmT / aRecTot) * 100 |
-----------------------+-------------------+---------------------------------------------------------------------+
CUSTO PRODUÇÃO     (R$)| aCusPrT   aParPrT | aCusMtT + aCusEmT                         (aCusPrT / aRecTot) * 100 |
-----------------------+-------------------+---------------------------------------------------------------------+
MARGEM CONTRIBUIÇÃO(R$)| aCusMCT   aParMCT | aLiqTot - aCusPrT                         (aCusMCT / aRecTot) * 100 |
*/
