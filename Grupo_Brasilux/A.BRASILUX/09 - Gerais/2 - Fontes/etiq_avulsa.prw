#include "protheus.ch"

USER Function ETIQ_AVULSA()
     If !PERGUNTE("EAVULS", .T.)
        Return()
     Else
        If Empty(mv_par01)
           MsgStop("Código não pode ser vazio!")
           Return
        Endif
     Endif
     u_zcfga01( 'ETIQ_AVULSA' ) //LGS#2021202 - Gravação de log de utilização da rotina
     MSCBPRINTER("S600"    , "LPT1"  ,             , 120       , .F.   ,         ,          ,       ,           ,        , .F.      ,             )
     MSCBBEGIN(1, 6, , .f.)
     MSCBSAYBAR(10, 03, Alltrim(mv_par01), "N", "MB02", 15, .F., .T., .F., , 3, 2)
     MSCBCHKSTATUS(.f.)
     cText := MSCBEND()
     MSCBCLOSEPRINTER()
     //FERASE('C:\ENVASE.ETQ')
     //cArq := ' '
     //cArq := 'C:\ENVASE.ETQ'
     //MemoWrit(cArq, cText)
     //Copy File C:\ENVASE.ETQ To lpt1
Return

/*******************************************************************************/
/*** VLDPERG - Ajusta perguntas com o SX1.                                   ***/
/*******************************************************************************/
//LGS#20200207 - Adequação de release 12.1.25 e posteriores
/*
Static Function VldPerg()
       Local aHelp1 := {}
       aAdd( aHelp1, "Informe o código a ser impresso    " )
     //PutSx1(cGrupo  , cOrdem,   cPergunt            , cPerSpa, cPerEng, cVar    , cTipo, nTamanho, nDecimal, nPresel, cGSC, cValid, cF3, cGrpSxg, cPyme, cVar01    , cDef01       , cDefSpa1, cDefEng1, cCnt01, cDef02          , cDefSpa2, cDefEng2, cDef03        , cDefSpa3, cDefEng3, cDef04 , cDefSpa4, cDefEng4, cDef05       ,  cDefSpa5,  cDefEng5, aHelpPor, aHelpEng, aHelpSpa, cHelp    )
       PutSX1("EAVULS    ", "01"  ,   "Informe o código  ", ""     , ""     , "mv_ch1", "C"  , 15      , 0       , 0      , "G" , " "   , " ", " "    , " "  , "mv_par01", " "          , " "     , " "     , " "   , " "             , " "     , " "     , " "           , " "     , " "     , " "    , " "     , " "     , " "          ,  " "     ,  " "     , aHelp1  , Nil     , Nil     , ".EAVULS01." )
Return */
