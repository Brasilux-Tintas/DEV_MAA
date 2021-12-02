#include "protheus.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCPR10 º Autor ³ Luís G. de Souza   º Data ³  18/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Comparativos de custos de formulas.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRPCPR10()
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "COMPARATIVO DE CUSTO"
     //Local cPict         := ""
     Local titulo        := "COMPARATIVO DE CUSTO"
     Local nLin          := 80
     Local Cabec1        := "                                                            CUSTO      CUSTO"
     Local Cabec2        := "PRODUTO         DESCRIÇÃO                  REV DT. INCL.  FORMULAÇÃO   ATUAL"
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRPCPR10" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "PCPR10"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRPCPR10" // Coloque aqui o nome do arquivo usado para impressao em disco

     Private cString := "SZM"

     DbSelectArea("SZM")
     DbSetOrder(1)

     //fVldPerg()  //LGS#20200131 - Adequação de release 12.1.25 e posteriores
     Pergunte(cPerg, .F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta a interface padrao com o usuario...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn, cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     Processa({|| PCPR10_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ PCPR10_1 º Autor ³ Luís G. de Souza   º Data ³  18/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PCPR10_1(Cabec1, Cabec2, Titulo, nLin)
       //Local nOrdem
       Local nX
       Local cQry1 := ""
       Local cQry2 := ""
       Local cQry3 := ""

       DbSelectArea(cString)
       DbSetOrder(1)
       
       cQry1 += "SELECT SZM.ZM_CODIGO, SZM.ZM_DESCRIC, SZM.ZM_REVISAO, SZM.ZM_DTINCLU "
       cQry2 += "SELECT COUNT(*) QTDREC "
       cQry3 += "FROM "+RetSqlName("SZM")+" SZM WITH (NOLOCK) "
       cQry3 += "WHERE SZM.ZM_FILIAL   = '"+xFilial("SZM")+"' "
       cQry3 += "  AND SZM.D_E_L_E_T_  = '' "
       cQry3 += "  AND SZM.ZM_DTINCLU >= '"+Dtos(mv_par01)+"' "
       cQry3 += "  AND SZM.ZM_STATUS = 'AC' "
       cQry2 += cQry3
       cQry1 += cQry3
       cQry1 += "ORDER BY SZM.ZM_CODIGO, SZM.ZM_REVISAO "
       TCQuery cQry2 ALIAS "TCQ" NEW

       DbSelectArea("TCQ")
       ProcRegua(TCQ->QTDREC)
       DbSelectArea("TCQ")
       DbCloseArea()

       TCQuery cQry1 ALIAS "TCQ" NEW
       aDadSim := {}
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             If aScan(aDadSim, {|x| Alltrim(x[1]) == Alltrim(TCQ->ZM_CODIGO) }) == 0 // Busca Custo Atual do Produto
                aAdd(aDadSim, {TCQ->ZM_CODIGO, TCQ->ZM_DESCRIC, TCQ->ZM_REVISAO, SubStr(TCQ->ZM_DTINCLU, 7, 2)+'/'+SubStr(TCQ->ZM_DTINCLU, 5, 2)+'/'+SubStr(TCQ->ZM_DTINCLU, 1, 4), 0, 0 })
                /*** CUSTO DA REVISÃO ***/
                aDadSim[Len(aDadSim)][5] := U_fCCusPro(TCQ->ZM_CODIGO,TCQ->ZM_REVISAO)
                /***  CUSTO DA ATUAL  ***/
                aDadSim[Len(aDadSim)][6] := U_fCCusPro(TCQ->ZM_CODIGO,Nil)
             Else                                                          // Busca somente o custo da revisão
                aAdd(aDadSim, {TCQ->ZM_CODIGO, TCQ->ZM_DESCRIC, TCQ->ZM_REVISAO, SubStr(TCQ->ZM_DTINCLU, 7, 2)+'/'+SubStr(TCQ->ZM_DTINCLU, 5, 2)+'/'+SubStr(TCQ->ZM_DTINCLU, 1, 4), 0, 0 })
                /*** CUSTO DA REVISÃO ***/
                aDadSim[Len(aDadSim)][5] := U_fCCusPro(TCQ->ZM_CODIGO,TCQ->ZM_REVISAO)
             Endif
             IncProc(Alltrim(TCQ->ZM_CODIGO)+' - '+TCQ->ZM_DESCRIC)
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()

       For nX := 1 To Len(aDadSim)
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica o cancelamento pelo usuario...                             ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If lAbortPrint
               @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
               Exit
            Endif
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Impressao do cabecalho do relatorio. . .                            ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
               nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
               nLin += 1
            Endif
            //0         1         2         3         4         5         6         7         
            //01234567890123456789012345678901234567890123456789012345678901234567890123456789
            //                                                            CUSTO      CUSTO
            //PRODUTO         DESCRIÇÃO                  REV DT. INCL.  FORMULAÇÃO   ATUAL
            //XX 99.99.999-99 XXXXXXXXXXXXXXXXXXXXXXXXXX 999 99/99/9999 99,999.999 99,999.999
            @ nLin,000 PSAY aDadSim[nX][1] Picture "@R XX 99.99.999-99"
            @ nLin,016 PSAY SubStr(aDadSim[nX][2], 1, 26) Picture "@!"
            @ nLin,043 PSAY aDadSim[nX][3] Picture "999"
            @ nLin,047 PSAY aDadSim[nX][4]
            @ nLin,058 PSAY aDadSim[nX][5] Picture "@E 99,999.999"
            If aDadSim[nX][6] <> 0.00
               @ nLin,069 PSAY aDadSim[nX][6] Picture "@E 99,999.999"
            Endif
            nLin += 1 // Avanca a linha de impressao
       Next
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

/*******************************************************************************/
/*** fVldPerg - Ajusta perguntas com o SX1.                                  ***/
/*******************************************************************************/
//LGS#20200131 - Adequação de release 12.1.25 e posteriores
/*
Static Function fVldPerg()
       Local aHelp1 := {}
       aAdd( aHelp1, "Data das simulações dos produtos   " )
       aAdd( aHelp1, "aprovados.                         " )
     //PutSx1(cGrupo  , cOrdem,   cPergunt            , cPerSpa, cPerEng, cVar    , cTipo, nTamanho, nDecimal, nPresel, cGSC, cValid, cF3, cGrpSxg, cPyme, cVar01    , cDef01       , cDefSpa1, cDefEng1, cCnt01, cDef02          , cDefSpa2, cDefEng2, cDef03        , cDefSpa3, cDefEng3, cDef04 , cDefSpa4, cDefEng4, cDef05       ,  cDefSpa5,  cDefEng5, aHelpPor, aHelpEng, aHelpSpa, cHelp    )
       PutSX1("PCPR10    ", "01"  ,   "A partir de       ", ""     , ""     , "mv_ch1", "D"  , 8       , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par01", " "          , " "     , " "     , " "   , " "             , " "     , " "     , " "           , " "     , " "     , " "    , " "     , " "     , " "          ,  " "     ,  " "     , aHelp1  , Nil     , Nil     , "PCPR10" )
Return */