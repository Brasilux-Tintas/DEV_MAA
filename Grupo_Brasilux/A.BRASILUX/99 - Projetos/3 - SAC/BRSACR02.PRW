#include "rwmake.ch"       
#include "topconn.ch"
#include "font.ch"   
#include "avprint.ch"    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRSACR02 ºAutor  ³ Marcos C. Vieira   º Data ³  15/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório Autorização para Devolução de Mercadoria.        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
- Melhorias devido a reformulação do SAC. - 30/03/05
- Adequação para impressão direto na tela do SAC. - 30/05/05
*/
User Function BRSACR02(nOpc)
     Local nOpcX := Iif(nOpc == Nil, 2, nOpc)
     Linha    := 0
     xLinha   := 0
     cCol     := 0
     cCol1    := 0

     If nOpcX == 2
        //VldPerg()  //LGS#20200211 - Adequação de release 12.1.25 e posteriores
        Pergunte("SACR02", .f.)
        nOpcA    := 0                
        i        := 1
        oDlg     := oSend( MSDialog(), "New", 8, 10, 18, 63,"Relatorio Devolução de Mercadorias(SAC)",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)

        @ 20,18  SAY "Este relatorio tem como funcao, Imprimir/Consultar  "
        @ 30,18  SAY "SAC's que geraram uma Devolução, podendo imprimir   "
        @ 40,18  SAY "uma ficha de Devolução de Mercadorias.              "
        @ 57,170 BMPBUTTON TYPE 05 ACTION (Pergunte("SACR02"))

        bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
        bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
        bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

        oSend( oDlg, "Activate",,,,.T.,,, bInit )
    
        If nOpca == 0 
           Return
        EndIf
     Else
        mv_par01 := SZQ->ZQ_NUM
        mv_par02 := SZQ->ZQ_NUM
     Endif

     MsAguarde({|| SACR02_1() },"Aguarde","Em processando conforme parametros...")

     DbSelectArea("TCQ")            
     DbGotop()
     If Eof()
        MSGSTOP("Nao ha dados a serem gerados com estes parametros.")
        DbSelectArea("TCQ") 
        DbCloseare()
        Return
     Endif  

     Processa({|lEnd| SACR02_2() })

     DbSelectArea("TCQ") 
     DbCloseare()

Return Nil

/***********************************************************************************/
/*** SACR02_1 - Busca dados dos Atendimentos para impressão.                     ***/
/***********************************************************************************/
Static Function SACR02_1()
       Local cQuery := ""
       cQuery += "SELECT * "
       cQuery += "FROM "+RetSqlName("SZQ")+" SZQ "
       cQuery += "WHERE SZQ.ZQ_FILIAL = '"+xFilial("SZQ")+ "' "
       cQuery += "  AND SZQ.ZQ_NUM BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
       cQuery += "  AND SZQ.ZQ_STATUS = '1' AND SZQ.D_E_L_E_T_ <> '*' "
       cQuery += "ORDER BY SZQ.ZQ_CLIENTE "
       cQuery := ChangeQuery(cQuery)
       DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F.)
Return 

/***********************************************************************************/
/*** SACR02_2 - Imprime dados dos atendimentos.                                  ***/
/***********************************************************************************/
Static Function SACR02_2()
       oPrn:= TMSPrinter():New( "Relatorio para Auxilio na Coleta de Produtos." )
       oPrn:SetPortrait()     //SetLandscape()

       AVPRINT oPrn NAME "Relatorio para Auxilio na Coleta de Produtos."
               ProcRegua(150)

               oFont1 := TFont():New("Arial"      ,9,07,.F.,.T.,5,.T.,5,.T.,.F.)
               oFont2 := TFont():New("Courier New",9,14,.F.,.T.,5,.F.,5,.T.,.F.) 
               oFont3 := TFont():New("Courier New",9,10,.F.,.T.,5,.F.,5,.T.,.F.)
               oFont4 := TFont():New("Courier New",9,10,.F.,.F.,5,.T.,5,.T.,.F.) 
               oFont5 := TFont():New("Arial"      ,9,10,.F.,.F.,5,.F.,5,.T.,.F.)
               oFont6 := TFont():New("Arial"      ,9,09,.F.,.T.,5,.T.,5,.T.,.F.)
               oFont7 := TFont():New("Arial"      ,9,10,.F.,.F.,5,.T.,5,.T.,.F.) 

               AVPAGE

                 DbSelectArea("TCQ")            
                 DbGotop()
                 While !EOF()
                       SACR02_3()
                       DbSelectArea("SZR")            
                       DbSetOrder(1)
                       DbSeek(xFilial("SZR")+TCQ->ZQ_NUM, .t.)
                       While TCQ->ZQ_NUM = SZR->ZR_NUM
                             //If Alltrim(SZR->ZR_ITEMDEV) == "1"
                                DbSelectArea("SB1")            
                                DbSetOrder(1)
                                DbSeek(xFilial("SB1")+SZR->ZR_PRODUTO, .t.)
                                oPrn:Say( Linha, cCol     , SZR->ZR_PRODUTO                        , oFont5 )
                                oPrn:Say( Linha, cCol+0350, SB1->B1_DESC                           , oFont5 )
                                oPrn:Say( Linha, cCol+1090, Transform(SZR->ZR_QTD,"@E 999,999,999"), oFont5 )
                                oPrn:Say( Linha, cCol+1370, DTOC(SZR->ZR_DTVALID)                  , oFont5 )
                                oPrn:Say( Linha, cCol+1620, SZR->ZR_LOTE                           , oFont5 )
                                oPrn:Say( Linha, cCol+1860, SZR->ZR_PEDIDO                         , oFont5 )
                                oPrn:Say( Linha, cCol+2150, SZR->ZR_NUMNF                          , oFont5 )
                                Linha += 40
                             //Endif
                             If Linha > 2400
                                SACR02_3()
                             Endif  
                             DbSelectArea("SZR")
                             DbSkip()
                       Enddo
                       DbSelectArea("TCQ")
                       DbSkip()
                 Enddo  

               AVENDPAGE
       AVENDPRINT

       oFont1:End()
       oFont2:End()
       oFont3:End()
       oFont4:End()
       oFont5:End() 
       oFont6:End() 
       oFont7:End()

       MS_FLUSH() 

Return Nil 

/***********************************************************************************/
/*** SACR02_3 - Imprime dados dos atendimentos.                                  ***/
/***********************************************************************************/
Static Function SACR02_3()
       Local I
       DbSelectArea("SA1")
       DbSetOrder(1)
       DbSeek(xFilial("SA1")+TCQ->ZQ_CLIENTE)

       If Linha <> 0
          AVNEWPAGE
       Endif
       Linha := 10                           
       oPrn:Say( Linha , 600  , "ROMANEIO DE PRODUTOS A SEREM COLETADOS / ENTREGUES", oFont2 )
       Linha += 150
       oPrn:Say( Linha , 10   , "CLIENTE....:"                             , oFont3 )
       oPrn:Say( Linha , 300  , SA1->A1_COD+" - "+SA1->A1_NOME  	        , oFont4 )
       oPrn:Say( Linha , 1750 , "DATA.......:"                             , oFont3 )
       oPrn:Say( Linha , 2035 , DTOC(dDataBase)                            , oFont4 )
       Linha += 60                                                 
       oPrn:Say( Linha , 10   , "ENDEREÇO...:"                             , oFont3 )
       oPrn:Say( Linha , 300  , SA1->A1_END                                , oFont4 ) 
       oPrn:Say( Linha , 1750 , "SAC........:"                             , oFont3 )
       oPrn:Say( Linha , 2035 , TCQ->ZQ_NUM                                , oFont4 )
       Linha += 60
       oPrn:Say( Linha , 10   , "CIDADE-UF..:"                             , oFont3 )
       oPrn:Say( Linha , 300  , ALLTRIM(SA1->A1_MUN) +"-"+SA1->A1_EST      , oFont4 ) 
       oPrn:Say( Linha , 1750 , "TELEFONE...:"                             , oFont3 )
       oPrn:Say( Linha , 2035 , TRIM(SA1->A1_DDD)+'-'+SA1->A1_TEL                                , oFont4 ) 
       Linha += 60

       //TRACO_BOLD1
       oPrn:Line( Linha - 1 , 10 , Linha - 1 , 2340 )
       oPrn:Line( Linha     , 10 , Linha     , 2340 )
       oPrn:Line( Linha + 1 , 10 , Linha + 1 , 2340 )

       Linha  += 1 
       xLinha := 100
       // BORDA_BOLD1
       oPrn:Line( Linha,   09, (Linha+xLinha),   09 )
       oPrn:Line( Linha,   10, (Linha+xLinha),   10 )
       oPrn:Line( Linha,   11, (Linha+xLinha),   11 )
       oPrn:Line( Linha, 2338, (Linha+xLinha), 2338 )
       oPrn:Line( Linha, 2339, (Linha+xLinha), 2339 )
       oPrn:Line( Linha, 2340, (Linha+xLinha), 2340 )
       //BORDA_BOLD2
       oPrn:Line( Linha, 349 , (Linha+xLinha),  349 )
       oPrn:Line( Linha, 350 , (Linha+xLinha),  350 )
       oPrn:Line( Linha, 351 , (Linha+xLinha),  351 )
       oPrn:Line( Linha, 1099, (Linha+xLinha), 1099 )
       oPrn:Line( Linha, 1100, (Linha+xLinha), 1100 )
       oPrn:Line( Linha, 1101, (Linha+xLinha), 1101 )
       oPrn:Line( Linha, 1349, (Linha+xLinha), 1349 )
       oPrn:Line( Linha, 1350, (Linha+xLinha), 1350 )
       oPrn:Line( Linha, 1351, (Linha+xLinha), 1351 )
       oPrn:Line( Linha, 1599, (Linha+xLinha), 1599 )
       oPrn:Line( Linha, 1600, (Linha+xLinha), 1600 )
       oPrn:Line( Linha, 1601, (Linha+xLinha), 1601 )
       oPrn:Line( Linha, 1839, (Linha+xLinha), 1839 )
       oPrn:Line( Linha, 1840, (Linha+xLinha), 1840 )
       oPrn:Line( Linha, 1841, (Linha+xLinha), 1841 )
       oPrn:Line( Linha, 2089, (Linha+xLinha), 2089 )
       oPrn:Line( Linha, 2090, (Linha+xLinha), 2090 )
       oPrn:Line( Linha, 2091, (Linha+xLinha), 2091 )
       
       Linha += 100
       //TRACO_BOLD1
       oPrn:Line( Linha - 1 , 10 , Linha - 1 , 2340 )
       oPrn:Line( Linha     , 10 , Linha     , 2340 )
       oPrn:Line( Linha + 1 , 10 , Linha + 1 , 2340 )
       
       xLinha := 100
       I := 1
       For I = 1 to 25
           Linha += 1
           //BORDA_BOLD1
           oPrn:Line( Linha,   09, (Linha+xLinha),   09 )
           oPrn:Line( Linha,   10, (Linha+xLinha),   10 )
           oPrn:Line( Linha,   11, (Linha+xLinha),   11 )
           oPrn:Line( Linha, 2338, (Linha+xLinha), 2338 )
           oPrn:Line( Linha, 2339, (Linha+xLinha), 2339 )
           oPrn:Line( Linha, 2340, (Linha+xLinha), 2340 )
           //BORDA_NORMAL
           oPrn:Line( Linha, 350 , (Linha+xLinha),  350 )
           oPrn:Line( Linha, 1100, (Linha+xLinha), 1100 )
           oPrn:Line( Linha, 1350, (Linha+xLinha), 1350 )
           oPrn:Line( Linha, 1600, (Linha+xLinha), 1600 )
           oPrn:Line( Linha, 1840, (Linha+xLinha), 1840 )
           oPrn:Line( Linha, 2090, (Linha+xLinha), 2090 )

           Linha += 100
       Next  
       //TRACO_NORMAL
       oPrn:Line( Linha   ,  10, Linha            , 2340 )
       //If !Empty(SA1->A1_OBSSAC)
          //cMemImp := ''
          //nLinImp := 0
          //nLinMem := 0
          //nLinMem := MLCOUNT(Alltrim(SA1->A1_OBSSAC), 80)
          //For nY := 1 To 3
          //    cMemImp += Alltrim(MemoLine(ALLTRIM(SA1->A1_OBSSAC), 80, nY))+' '
          //Next
          //If !Empty(cMemImp)
          //   nLinImp := Int((Len(cMemImp) / 80))
          //   If ((Len(cMemImp) / 80) - Int((Len(cMemImp) / 80))) > 0
          //      nLinImp += 1
          //   Endif
          //   nPos := 1
          //   For nY := 1 to nLinImp
          //       oPrn:Say( Linha , 0250 , Alltrim(SubStr(cMemImp, nPos, 140)), oFont4 ) //Linha 0130
          //       nPos += 80
          //       Linha += 50
          //   Next
          //Endif
                
       //   oPrn:Say( Linha+20 , 350, SUBSTR(SA1->A1_OBSSAC,   1, 85) , oFont4 )
       //   oPrn:Say( Linha+70 , 350, SUBSTR(SA1->A1_OBSSAC,  86, 85) , oFont4 )
       //   oPrn:Say( Linha+120, 350, SUBSTR(SA1->A1_OBSSAC, 171, 85) , oFont4 )
       //Endif
       nVez := 1
       cMemImp1 := ""
       cMemImp2 := ""
       cMemImp3 := ""
       cMemImp4 := ""
       cMemImp5 := ""
       DbSelectArea("SZS")
       DbSetOrder(1)
       DbSeek(xFilial("SZS")+TCQ->ZQ_NUM, .t.)
       If Found()
          While !Eof() .and. SZS->ZS_NUM == TCQ->ZQ_NUM
                If SZS->ZS_LOG $ 'ABE'
                  // If !Empty(AllTrim(SZS->ZS_PARECER))
                  //    If nVez == 1
                  //       oPrn:Say( Linha+20 ,  20, "OBSERVAÇÃO..:"  , oFont3 )
                  //       nVez += 1
                  //    Endif
                  //    cMemImp1 := Alltrim(MemoLine(AllTrim(SZS->ZS_PARECER), 85, 1))
                  //    cMemImp2 := Alltrim(MemoLine(AllTrim(SZS->ZS_PARECER), 85, 2))
                  //    cMemImp3 := Alltrim(MemoLine(AllTrim(SZS->ZS_PARECER), 85, 3))
                  //    cMemImp4 := Alltrim(MemoLine(AllTrim(SZS->ZS_PARECER), 85, 4))
                  //    cMemImp5 := Alltrim(MemoLine(AllTrim(SZS->ZS_PARECER), 85, 5))
                  // Endif
                Endif
                DbSelectArea("SZS")
                DbSkip()
          EndDo
          oPrn:Say( Linha+20 , 350, cMemImp1 , oFont4 )
          oPrn:Say( Linha+70 , 350, cMemImp2 , oFont4 )
          oPrn:Say( Linha+120, 350, cMemImp3 , oFont4 )
          oPrn:Say( Linha+170, 350, cMemImp4 , oFont4 )
          oPrn:Say( Linha+220, 350, cMemImp5 , oFont4 )
       Endif
                      
       I := 1
       For I = 1 to 3
           Linha += 1
           //BORDA_BOLD1
           oPrn:Line( Linha,   09, (Linha+xLinha),   09 )
           oPrn:Line( Linha,   10, (Linha+xLinha),   10 )
           oPrn:Line( Linha,   11, (Linha+xLinha),   11 )
           oPrn:Line( Linha, 2338, (Linha+xLinha), 2338 )
           oPrn:Line( Linha, 2339, (Linha+xLinha), 2339 )
           oPrn:Line( Linha, 2340, (Linha+xLinha), 2340 )

           Linha += 100
       Next  
       //TRACO_BOLD1           
       oPrn:Line( Linha - 1 , 10 , Linha - 1 , 2340 )
       oPrn:Line( Linha     , 10 , Linha     , 2340 )
       oPrn:Line( Linha + 1 , 10 , Linha + 1 , 2340 )

       oPrn:Say( 3300 , 10   , "Brasilux Tintas Técnicas"      , oFont1 )
       oPrn:Say( 3300 , 2050 , "Emitido em: "+dtoc(dDataBase)  , oFont1 )

       cCol  := 20 
       Linha := 360

       oPrn:Say( Linha , cCol      , "COD.DO PRODUTO"     , oFont3 ) 
       oPrn:Say( Linha , cCol+620  , "DESCRIÇÃO"          , oFont3 ) 
       oPrn:Say( Linha , cCol+1100 , "QUANTIDADE"         , oFont3 ) 
       oPrn:Say( Linha , cCol+1365 , "VALIDADE"           , oFont3 )  
       oPrn:Say( Linha , cCol+1640 , "LOTE"               , oFont3 ) 
       oPrn:Say( Linha , cCol+1860 , "NUM.PED."           , oFont3 ) 
       oPrn:Say( Linha , cCol+2085 , "NF ORIGEM"          , oFont3 ) 
       Linha := 450

Return NIL                              

/***********************************************************************************/
/*** VLDPERG - Verifica e monta parâmetros SX1.                                  ***/
/***********************************************************************************/
//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*Static Function VldPerg() 
       Local aHelp       := {}  
       aAdd( aHelp, "Informe o Numero do SAC com de-" )
       aAdd( aHelp, "volução.                       " )

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Inclui parametros de consulta                                                  ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      //     X1_GRUPO  X1_ORDEM  X1_PERGUNT X1_PERSPA   X1_PERENG   X1_VARIAVL X1_TIPO X1_TAMANHO X1_DECIMAL X1_PRESEL X1_GSC X1_VALID X1_F3 X1_GRPSXG X1_PYME X1_VAR01    X1_DEF01 X1_DEFSPA1 X1_DEFENG1 X1_CNT01 X1_VAR02 X1_DEF02 X1_DEFSPA2 X1_DEFENG2 X1_CNT02 X1_VAR03 X1_DEF03 X1_DEFSPA3 X1_DEFENG3 X1_CNT03 X1_VAR04 X1_DEF04 X1_DEFSPA4 X1_DEFENG4 X1_CNT04 X1_VAR05 X1_DEF05 X1_DEFSPA5 X1_DEFENG5 X1_CNT05 X1_HELP
      PutSX1("SACR02    ", "01",     "Do SAC",  "Do SAC"  , "Do SAC"  , "mv_ch1",  "C",    6,         0,         0,        "G",   " ",     " ",  " ",      " ",    "mv_par01", " ",     " ",       " ",       " ",     " ",     " ",     " ",       Nil,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp,     aHelp,     Nil )
      PutSX1("SACR02    ", "02",     "Até SAC", "Até SAC",  "Até SAC" , "mv_ch2",  "C",    6,         0,         0,        "G",   "",      " ",  " ",      " ",    "mv_par02", " ",     " ",       " ",       " ",     " ",     " ",     " ",       Nil,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp,     aHelp,     Nil )
Return*/