#include "rwmake.ch"       
#include "topconn.ch"
#include "font.ch"   
#include "avprint.ch"    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRSACR04 ºAutor  ³ Marcos C. Vieria   º Data ³  27/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório do SAC Produto X Ocorrências                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRSACR04()
     Private nPag
     //Private cNomeArq
     Private aCampos
     //Private cIndex
     //Private aInd
     Private nQtdTot
     Private oTempTbl01

     //VldPerg()  //LGS#20200211 - Adequação de release 12.1.25 e posteriores
     Pergunte("SACR04", .f.)
     //cIndex     := ""
     //aInd       := {}
     //cNomeArq   := ""
     aCampos    := {}
     Linha      := 0
     nOpcA      := 0
     nPag       := 0
     nQtdTot    := 0
     nPerOcor   := 0
     nTotPer    := 0
     dDtInic    := CTOD("")
     dDtFin     := CTOD("")

     oDlg := oSend( MSDialog(), "New", 8, 10, 18, 63,"Produtos X Ocorrências",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)
     @ 20,018 SAY "Este relatório tem como função, Imprimir uma Relação "
     @ 30,018 SAY "de Produto para uma determinada Ocorrências."
     @ 57,170 BMPBUTTON TYPE 05 ACTION (Pergunte("SACR04", .t.))

     bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
     bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
     bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

     oSend( oDlg, "Activate",,,,.T.,,, bInit )

     If nOpca == 0
        Return
     EndIf

     MsAguarde({|| SACR04_1() },"Aguarde","Este processamento poderá levar alguns minutos...")

     DbSelectArea("TCQ")
     DbGotop()
     If EOF()
        ApMsgStop("Nao ha dados a serem gerados com estes parametros.", "Atenção")
        DbSelectArea("TCQ")
        DbCloseArea()
        Return
     Endif

     Processa({|lEnd| SACR04_2()})

DBSelectArea("TCQ") 
Dbcloseare()

Return Nil

/*******************************************************************************/
/*** SACR04_1 - Busca dados dos SAC's de acordo com parâmetros.              ***/
/*******************************************************************************/
Static Function SACR04_1()
       Local cQuery := ""
       If Empty(MV_PAR01)
          dDtInic := CTOD("01/01/02")
       Else
          dDtInic := MV_PAR01
       Endif

       If Empty(MV_PAR02)
          dDtFin  := DATE()
       Else
          dDtFin := MV_PAR02
       Endif

       cQuery  += "SELECT * "
       cQuery  += "FROM "+RetSqlName("SZQ")+" SZQ "
       cQuery  += "WHERE SZQ.ZQ_FILIAL = '"+xFilial("SZQ")+ "' "
       cQuery  += "  AND SZQ.D_E_L_E_T_ <> '*' "
       cQuery  += "  AND SZQ.ZQ_DATA BETWEEN '"+dTos(dDtInic)+"' AND '"+dTos(dDtFin)+"' "
       cQuery  += "ORDER BY SZQ.ZQ_NUM "
       cQuery  := ChangeQuery(cQuery)
       DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F.)

       DbSelectArea("TCQ")
       DbGotop()
       If EOF()
          Return
       Endif

       cNumSac  := Space(06)
       nQtdTot  := 0
       //cNomeArq := ""
       aCampos  := {}

       AADD( aCampos, { "CodProd" , "C", 15, 0 })
       AADD( aCampos, { "DescProd", "C", 40, 0 })
       AADD( aCampos, { "Lote"    , "C", 12, 0 })
       AADD( aCampos, { "QtdOcor" , "N", 10, 0 }) 
       AADD( aCampos, { "NumSac"  , "C", 06, 0 })
       AADD( aCampos, { "QtdOINV" , "C", 10, 0 }) //LGS#20200211 - Adequação de release 12.1.25 e posteriores 

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cNomeArq := CriaTrab(aCampos)
       //cIndex   := CriaTrab(nil, .f.)
       //AADD(aInd, cIndex)
       //dbUseArea( .T.,, cNomeArq, "SAC", .F. , .F. )
       //IndRegua("SAC",cNomeArq,"CODPROD+LOTE",,,"Selecionando Registros...")
       oTempTbl01 := FWTemporaryTable():New( "SAC" )
       oTempTbl01:SetFields( aCampos )
       oTempTbl01:AddIndex( "cInd01", { "CODPROD", "LOTE" } )
       oTempTbl01:AddIndex( "cInd02", { "QtdOINV" } )
       oTempTbl01:Create()
       /********************************************************************************************************************************/
       DbSelectArea("TCQ")
       While !EOF()
             DbSelectArea("SZR")
             DbSetOrder(1)
             DbSeek(xFilial("SZR")+TCQ->ZQ_NUM, .t.)
             While !EOF() .AND. TCQ->ZQ_NUM == SZR->ZR_NUM
                   If Alltrim(SZR->ZR_OCORREN) <> Alltrim(MV_PAR03)
                      DbSelectArea("SZR")
                      DbSkip()
                      Loop
                   Endif  

                   DbSelectArea("SU9")
                   DbSetOrder(2)
                   DbSeek(xFilial("SU9")+SZR->ZR_OCORREN, .t.)
                   If TCQ->ZQ_PROCEDE == 'S' // Se procede a Reclamação
                      If Alltrim(SU9->U9_ASSUNTO) == "000001" .OR. Alltrim(SU9->U9_ASSUNTO) == "000003" .OR. Alltrim(SU9->U9_ASSUNTO) == "000004" // Se é Tecnico, Expedição ou Produção
                         DbSelectArea("SAC")
                         DbSetOrder(1)
                         DbSeek(SZR->ZR_PRODUTO+SZR->ZR_LOTE, .t.)
                         If Found()
                            Reclock("SAC",.f.)
                               SAC->QtdOcor += 1
                               SAC->nQtdTot += 1
                               SAC->QtdOINV := Inverte( StrZero( SAC->QtdOcor, 10) )
                         Else 
                            Reclock("SAC",.t.)
                               SAC->CodProd  := SZR->ZR_PRODUTO
                               SAC->DescProd := Posicione("SB1", 1, xFilial("SB1")+SZR->ZR_PRODUTO, "B1_DESC")
                               SAC->Lote     := SZR->ZR_LOTE
                               SAC->NumSac   := SZR->ZR_NUM
                               SAC->QtdOcor  += 1
                               SAC->nQtdTot  += 1
                               SAC->QtdOINV  := Inverte( StrZero( SAC->QtdOcor, 10 ) )
                         Endif
                         MsUnlock()
                      Endif
                   Endif
                   DbSelectArea("SZR")
                   DbSkip()
             Enddo
             DbSelectArea("TCQ")
             DbSkip()
       Enddo

       DbSelectArea("SAC")
       //LGS#20200211 - Adequação de release 12.1.25 e posteriores
       //IndRegua("SAC", cNomeArq, "DESCEND(STR(QTDOCOR))", , , "Selecionando Registros...")
       DbSetOrder(2)
Return Nil

/*******************************************************************************/
/*** SACR04_2 - Impressão dos SAC's.                                         ***/
/*******************************************************************************/
Static Function SACR04_2()
       oPrn:= TMSPrinter():New( "Produto X Ocorrências.")
       oPrn:SetPortrait()     //SetLandscape()

       AVPRINT oPrn NAME "Produto X Ocorrências."
               ProcRegua(150)

               oFont1 := TFont():New("Arial"      , 9, 07, .F., .T., 5, .T., 5, .T., .F.)
               oFont2 := TFont():New("Courier New", 9, 14, .F., .T., 5, .F., 5, .T., .F.)
               oFont3 := TFont():New("Courier New", 9, 10, .F., .T., 5, .F., 5, .T., .F.)
               oFont4 := TFont():New("Courier New", 9, 10, .F., .F., 5, .T., 5, .T., .F.)
               oFont5 := TFont():New("Arial"      , 9, 10, .F., .T., 5, .T., 5, .T., .F.)

               AVPAGE

                 DbSelectArea("SAC")
                 DbGotop()
                 While !EOF()
                       If nPag == 0 .OR. Linha > 3200
                          SACR04_3()
                       Endif
                       oPrn:Say( Linha , 0010 , SAC->CODPROD+" - "+SAC->DESCPROD    , oFont4 )
                       oPrn:Say( Linha , 1120 , SAC->LOTE                           , oFont4 )
                       oPrn:Say( Linha , 1460 , Transform(SAC->QTDOCOR,"@E 999,999"), oFont4 )
                       Linha += 60

                       DbSelectArea("SAC")
                       DbSkip()
                 Enddo        

                 Linha += 60
                 oPrn:Say( Linha , 0010 , "Total: "                           , oFont3 )
                 oPrn:Say( Linha , 1460 , Transform(nQtdTot ,"@E 999,999")    , oFont3 )

               AVENDPAGE
       AVENDPRINT
       DbSelectArea("SAC")
       Dbclosearea()
       oTempTbl01:Delete()

       oFont1:End()
       oFont2:End()
       oFont3:End()
       oFont4:End()
       oFont5:End()

       MS_FLUSH()

Return nil 

/*******************************************************************************/
/*** SACR04_3 - Cabeçalho do relatório.                                      ***/
/*******************************************************************************/
Static Function SACR04_3()
       If Linha <> 0
          AVNEWPAGE
       Endif

       nPag  += 1
       Linha := 10

       oPrn:Say( Linha , 010  , ALLTRIM(SM0->M0_FILIAL)+"/BRSAC006"   , oFont1 )
       oPrn:Say( Linha , 640  , "RELAÇÃO DE PRODUTOS POR OCORRÊNCIAS" , oFont2 )
       oPrn:Say( Linha , 2100 , "PAG........:"                        , oFont1 )
       oPrn:Say( Linha , 2260 , STRZERO(nPag,3)                       , oFont1 ) 
       Linha += 70
       oPrn:Say( Linha , 10   , "Ref.ao Período: "+DTOC(ddtinic)+" a "+DTOC(ddtfin), oFont1 )        

       DbSelectArea("SU9")
       DbSetOrder(2)
       DbSeek(xFilial("SU9")+MV_PAR03, .t.)
       oPrn:Say( Linha,600,"PRODUTOS COM A OCORRÊNCIAS "+MV_PAR03+" - "+SU9->U9_DESC , oFont3 )

       oPrn:Say( Linha , 2100 , "Emissao.:"                           , oFont1 )
       oPrn:Say( Linha , 2240 , DTOC(dDataBase)                       , oFont1 )
       Linha += 40
       //TRACO_BOLD1
       oPrn:Line( Linha - 1 , 10 , Linha - 1 , 2340 )
       oPrn:Line( Linha     , 10 , Linha     , 2340 )
       oPrn:Line( Linha + 1 , 10 , Linha + 1 , 2340 )

       Linha += 20   
       oPrn:Say( Linha , 0010 , "PRODUTO"                             , oFont3 )
       oPrn:Say( Linha , 1130 , "LOTE"                                , oFont3 )
       oPrn:Say( Linha , 1450 , "QTD.OCORRÊCNIAS"                     , oFont3 )
       Linha += 70
       //TRACO_BOLD1
       oPrn:Line( Linha - 1 , 10 , Linha - 1 , 2340 )
       oPrn:Line( Linha     , 10 , Linha     , 2340 )
       oPrn:Line( Linha + 1 , 10 , Linha + 1 , 2340 )

       Linha += 30
Return NIL                              

/*******************************************************************************/
/*** VLDPERG - Ajusta perguntas com o SX1.                                   ***/
/*******************************************************************************/
//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*Static Function VldPerg() 
       Local aHelp1 := {}  
       Local aHelp2 := {}  
       aAdd( aHelp1, "Informe o periodo desejado para" )
       aAdd( aHelp1, "a emissão do relatório.        " )
       aAdd( aHelp2, "Informe a ocorrência desejada -" )
       aAdd( aHelp2, "para impressão.                " )

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Inclui parametros de consulta                                                  ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      //     X1_GRUPO  X1_ORDEM  X1_PERGUNT     X1_PERSPA      X1_PERENG      X1_VARIAVL X1_TIPO X1_TAMANHO X1_DECIMAL X1_PRESEL X1_GSC X1_VALID            X1_F3  X1_GRPSXG X1_PYME X1_VAR01    X1_DEF01 X1_DEFSPA1 X1_DEFENG1 X1_CNT01 X1_VAR02 X1_DEF02 X1_DEFSPA2 X1_DEFENG2 X1_CNT02 X1_VAR03 X1_DEF03 X1_DEFSPA3 X1_DEFENG3 X1_CNT03 X1_VAR04 X1_DEF04 X1_DEFSPA4 X1_DEFENG4 X1_CNT04 X1_VAR05 X1_DEF05 X1_DEFSPA5 X1_DEFENG5 X1_CNT05 X1_HELP
      PutSX1("SACR04    ", "01",     "Do Periodo ", "Do Periodo" , "Do Periodo" , "mv_ch1",  "D",    8,         0,         0,        "G",   " "               , " "  , " ",      " ",    "mv_par01", " ",     " ",       " ",       " ",     " ",     " ",     " ",       Nil,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp1,    aHelp1,     Nil )
      PutSX1("SACR04    ", "02",     "Até Periodo", "Até Periodo", "Até Periodo", "mv_ch2",  "D",    8,         0,         0,        "G",   " "               , " "  , " ",      " ",    "mv_par02", " ",     " ",       " ",       " ",     " ",     " ",     " ",       Nil,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp1,    aHelp1,     Nil )
      PutSX1("SACR04    ", "03",     "Ocorrência ", "Ocorrência ", "Ocorrência ", "mv_ch3",  "C",    6,         0,         0,        "G",   "!VAZIO(MV_PAR03)", "SU9", " ",      " ",    "mv_par02", " ",     " ",       " ",       " ",     " ",     " ",     " ",       Nil,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp2,    aHelp2,     Nil )
Return*/