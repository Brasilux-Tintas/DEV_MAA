#include "rwmake.ch"       
#include "topconn.ch"
#include "font.ch"   
#include "avprint.ch"    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRSACR05 ºAutor  ³ Marcos C. Vieira   º Data ³  17/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório do SAC Prod. X Ocorrências X Carcteristicas      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRSACR05()
     Private nPag
     Private cNomeArq
     Private aCampos
     Private cIndex
     Private aInd
     Private nQtdTot

     //VldPerg()  //LGS#20200211 - Adequação de release 12.1.25 e posteriores
     Pergunte("SACR05", .f.)

     cIndex     := ""
     aInd       := {}
     cNomeArq   := ""
     aCampos    := {}
     Linha      := 0
     nOpcA      := 0
     nPag       := 0
     nQtdTot    := 0
     dDtInic    := CTOD("")
     dDtFin     := CTOD("")

     oDlg := oSend( MSDialog(), "New", 8, 10, 18, 63,"Produtos X Ocorrências e Caracteristicas",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)
     @ 20,18  SAY "Este relatório tem como função, Imprimir uma Relação "
     @ 30,18  SAY "de Produto para uma determinada Ocorrências."
     @ 57,170 BMPBUTTON TYPE 05 ACTION (Pergunte("SACR05", .t.))

     bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
     bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
     bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

     oSend( oDlg, "Activate",,,,.T.,,, bInit )

     If nOpca == 0
        Return
     EndIf

     MsAguarde({|| SACR05_1() },"Aguarde","Este processamento poderá levar alguns minutos...")

     DbSelectArea("TCQ")
     DbGotop()
     If EOF()
        ApMsgStop("Nao há dados a serem gerados com estes parâmetros.", "Atenção")
        DbSelectArea("TCQ")
        DbCloseArea()
        Return
     Endif

     Processa({|lEnd| SACR05_2() })

     DbSelectArea("TCQ")
     Dbcloseare()

Return Nil

/*******************************************************************************/
/*** SACR05_1 - Busca dados dos SAC's de acordo com parâmetros.              ***/
/*******************************************************************************/
Static Function SACR05_1()
       Local cQuery := ""

       cQuery  += " SELECT ZQ_NUM ,ZQ_CLIENTE, ZQ_DATA, SZR.ZR_OCORREN, SZR.ZR_ASSUNTO, SZR.ZR_LOTE, SZR.ZR_PRODUTO "
       cQuery  += " FROM "+RetSQLName("SZQ")+" SZQ "
       cQuery  += " LEFT OUTER JOIN "+RetSqlName("SZR")+" SZR ON SZQ.ZQ_FILIAL = SZR.ZR_FILIAL AND SZQ.ZQ_NUM = SZR.ZR_NUM AND SZR.D_E_L_E_T_ <> '*' "
       cQuery  += " WHERE SZQ.ZQ_FILIAL = '"+xFilial("SZQ")+ "' "
       cQuery  += "  AND SZQ.D_E_L_E_T_ <> '*' "
       cQuery  += "  AND SZQ.ZQ_DATA BETWEEN '"+dTos(MV_PAR01)+"' AND '"+dTos(MV_PAR02)+"' "
       cQuery  += "  AND SZR.ZR_ASSUNTO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
       cQuery  += "  AND SZR.ZR_OCORREN BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
       cQuery  += "  AND SZR.ZR_PRODUTO BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
       cQuery  += " GROUP BY SZQ.ZQ_NUM, SZQ.ZQ_CLIENTE, SZQ.ZQ_DATA, SZR.ZR_OCORREN, SZR.ZR_ASSUNTO, SZR.ZR_LOTE, SZR.ZR_PRODUTO  "
       If MV_PAR09 == 1 // ASSUNTO + OCORRÊNCIA
       		cQuery  += " ORDER BY SZR.ZR_ASSUNTO, SZR.ZR_OCORREN, SZQ.ZQ_NUM, SZR.ZR_PRODUTO, SZR.ZR_LOTE "
	   Else             // LINHA + PRODUTO
			cQuery  += " ORDER BY SUBSTRING(SZR.ZR_PRODUTO,4,2), SZR.ZR_PRODUTO , SZR.ZR_LOTE, SZR.ZR_ASSUNTO, SZR.ZR_OCORREN, SZQ.ZQ_NUM "	   		
       Endif	
       cQuery  := ChangeQuery(cQuery)
       DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F.)

       DbSelectArea("TCQ")
       DbGoTop()
       If EOF()
          Return
       Endif
Return Nil

/*******************************************************************************/
/*** SACR05_2 - Imprime dados dos SAC's.                                     ***/
/*******************************************************************************/
Static Function SACR05_2()
       oPrn:= TMSPrinter():New("Produtos X Ocorrências e Caracteristicas")
       oPrn:SetPortrait()     //SetLandscape()

       AVPRINT oPrn NAME "Produtos X Ocorrências X Caracteristicas"
               ProcRegua(150)
               oFont1    := TFont():New("Arial"      ,9,07,.F.,.T.,5,.T.,5,.T.,.F.)
               oFont2    := TFont():New("Courier New",9,14,.F.,.T.,5,.F.,5,.T.,.F.)
               oFont3    := TFont():New("Courier New",9,10,.F.,.T.,5,.F.,5,.T.,.F.)
               oFont4    := TFont():New("Courier New",9,10,.F.,.F.,5,.T.,5,.T.,.F.)
               oFont5    := TFont():New("Arial"      ,9,10,.F.,.T.,5,.T.,5,.T.,.F.)
               AVPAGE
               DbSelectArea("TCQ")
               DbGotop()
               While !EOF() .and. !BOF()
	               If nPag == 0 .OR. Linha > 3200
    	               SACR05_3()
         	       Endif
                   oPrn:Say( Linha , 0010 , TCQ->ZR_PRODUTO+"- "+Substr(Posicione("SB1", 1, xFilial("SB1")+TCQ->ZR_PRODUTO, "B1_DESC"),1,30) 			, oFont4 )
                   oPrn:Say( Linha , 0900 , TCQ->ZR_LOTE                          												 						, oFont4 )
                   oPrn:Say( Linha , 1100 , SUBSTR(TCQ->ZQ_DATA,7,2)+"/"+SUBSTR(TCQ->ZQ_DATA,5,2)+"/"+SUBSTR(TCQ->ZQ_DATA,3,2)   						, oFont4 )
                   oPrn:Say( Linha , 1310 , TCQ->ZQ_NUM                           												 						, oFont4 )
                   oPrn:Say( Linha , 1510 , TCQ->ZR_ASSUNTO                        												 						, oFont4 )
                   oPrn:Say( Linha , 1700 , TCQ->ZR_OCORREN+" - "+Posicione("SU9", 1, xFilial("SU9")+TCQ->ZR_ASSUNTO+TCQ->ZR_OCORREN, "U9_DESC")       	, oFont4 )
                                  
                   Linha   += 60
                   nQtdTot += 1
                   DbSelectArea("TCQ")
                   DbSkip()
               Enddo
               Linha += 60
               oPrn:Say( Linha , 0010 , "Total Ocorrências: "               , oFont3 )
               oPrn:Say( Linha , 0360 , Transform(nQtdTot ,"@E 999,999")    , oFont3 )
               AVENDPAGE
       AVENDPRINT
       DbSelectArea("SAC")
       Dbcloseare()

       oFont1:End()
       oFont2:End()
       oFont3:End()
       oFont4:End()
       oFont5:End()

       MS_FLUSH()

Return nil

/*******************************************************************************/
/*** SACR05_3 - Cabeçalho dos SAC's.                                         ***/
/*******************************************************************************/
Static Function SACR05_3()
       If Linha <> 0
          AVNEWPAGE
       Endif

       nPag  += 1
       Linha := 10
       oPrn:Say( Linha , 010  , ALLTRIM(SM0->M0_FILIAL)+"/BRSACR05"          , oFont1 )
       oPrn:Say( Linha , 590  , "PRODUTOS POR OCORRÊNCIAS " , oFont2 )
       oPrn:Say( Linha , 2100 , "PAG........:"                               , oFont1 )
       oPrn:Say( Linha , 2260 , STRZERO(nPag,3)                              , oFont1 )
       Linha += 70
       oPrn:Say( Linha , 10   , "Ref.ao Período: "+DTOC(MV_PAR01)+" a "+DTOC(MV_PAR02), oFont1 )

       oPrn:Say( Linha,500,"PRODUTOS COM O ASSUNTO "+MV_PAR03+" ATÉ ASSUNTO "+MV_PAR04 , oFont3 )
       oPrn:Say( Linha , 2100 , "Emissao.:"                           , oFont1 )
       oPrn:Say( Linha , 2240 , DTOC(dDataBase)                       , oFont1 )
       Linha += 40
       //TRACO_BOLD1
       oPrn:Line( Linha - 1 , 10 , Linha - 1 , 2340 )
       oPrn:Line( Linha     , 10 , Linha     , 2340 )
       oPrn:Line( Linha + 1 , 10 , Linha + 1 , 2340 )
       Linha += 20
       oPrn:Say( Linha , 0010 , "PRODUTO"                             , oFont3 )
       oPrn:Say( Linha , 0900 , "LOTE"                                , oFont3 )
       oPrn:Say( Linha , 1100 , "DATA SAC"                            , oFont3 )
       oPrn:Say( Linha , 1300 , "NUM.SAC"                             , oFont3 )
       oPrn:Say( Linha , 1500 , "ASSUNTO"                             , oFont3 )
       oPrn:Say( Linha , 1700 , "OCORRÊNCIA"                          , oFont3 )
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
       Local aHelp3 := {}
       Local aHelp4 := {}
       Local aHelp5 := {}
       aAdd( aHelp1, "Informe o periodo desejado para" )
       aAdd( aHelp1, "a emissão do relatório.        " )
       aAdd( aHelp2, "Informe o intervalo de assuntos" )
       aAdd( aHelp2, "para impressão.                " )
       aAdd( aHelp3, "Informe o intervalo de ocorrên " )
       aAdd( aHelp3, "cias para impressão.           " )
       aAdd( aHelp4, "Informe o intervalor dos pro-  " )
       aAdd( aHelp4, "dutos a ser pesquisado         " )
       aAdd( aHelp5, "Informe a ordenação do resulta-" )
       aAdd( aHelp5, "do (Assunto+Ocorr. ou Produtos)" )
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Inclui parametros de consulta                                                  ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      //     X1_GRUPO  X1_ORDEM  X1_PERGUNT              X1_PERSPA      X1_PERENG        X1_VARIAVL X1_TIPO X1_TAMANHO X1_DECIMAL X1_PRESEL X1_GSC X1_VALID             X1_F3  X1_GRPSXG X1_PYME   X1_VAR01    X1_DEF01          X1_DEFSPA1                X1_DEFENG1           X1_CNT01 X1_VAR02           X1_DEF02            X1_DEFSPA2 X1_DEFENG2 X1_CNT02 X1_VAR03 X1_DEF03 X1_DEFSPA3 X1_DEFENG3 X1_CNT03 X1_VAR04 X1_DEF04 X1_DEFSPA4 X1_DEFENG4 X1_CNT04 X1_VAR05 X1_DEF05 X1_DEFSPA5 X1_DEFENG5 X1_CNT05 X1_HELP
      PutSX1("SACR05    ", "01",     "Do Periodo    ", "Do Periodo    ", "Do Periodo    ", "mv_ch1",  "D",    8,         0,         0,        "G",   ""                , " "  , " ",      " ",    "mv_par01", " "			  ,     " "			   ,       " "			  ,       " ",     " "			,     " "			,     " "		,       Nil		,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp1,    aHelp1,     Nil )
      PutSX1("SACR05    ", "02",     "Até Periodo   ", "Até Periodo   ", "Até Periodo   ", "mv_ch2",  "D",    8,         0,         0,        "G",   ""                , " "  , " ",      " ",    "mv_par02", " "			  ,     " "			   ,       " "			  ,       " ",     " "			,     " "			,     " "		,       Nil		,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp1,    aHelp1,     Nil )
      PutSX1("SACR05    ", "03",     "Do Assunto    ", "Do Assunto    ", "Do Assunto    ", "mv_ch3",  "C",    6,         0,         0,        "G",   ""                , "T1" , " ",      " ",    "mv_par03", " "			  ,     " "			   ,       " "			  ,       " ",     " "			,     " "			,     " "		,       Nil		,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp2,    aHelp2,     Nil )
      PutSX1("SACR05    ", "04",     "Até o Assunto ", "Até o Assunto ", "Até o Assunto ", "mv_ch4",  "C",    6,         0,         0,        "G",   "!VAZIO(MV_PAR04)", "T1" , " ",      " ",    "mv_par04", " "			  ,     " "			   ,       " "			  ,       " ",     " "			,     " "			,     " "		,       Nil		,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp2,    aHelp2,     Nil )
      PutSX1("SACR05    ", "05",     "Da Ocorrência ", "Da Ocorrência ", "Da Ocorrência ", "mv_ch5",  "C",    6,         0,         0,        "G",   ""                , "SU9", " ",      " ",    "mv_par05", " "			  ,     " "			   ,       " "			  ,       " ",     " "			,     " "			,     " "		,       Nil		,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp3,    aHelp3,     Nil )
      PutSX1("SACR05    ", "06",     "Até Ocorrência", "Até Ocorrência", "Até Ocorrência", "mv_ch6",  "C",    6,         0,         0,        "G",   "!VAZIO(MV_PAR06)", "SU9", " ",      " ",    "mv_par06", " "			  ,     " "			   ,       " "			  ,       " ",     " "			,     " "			,     " "		,       Nil		,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp3,    aHelp3,     Nil )
      PutSX1("SACR05    ", "07",     "Do Produto    ", "Do Produto    ", "Do Produto    ", "mv_ch7",  "C",   12,         0,         0,        "G",   ""                , "SB1", " ",      " ",    "mv_par07", " "			  ,     " "			   ,       " "			  ,       " ",     " "			,     " "			,     " "		,       Nil		,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp4,    aHelp4,     Nil )
      PutSX1("SACR05    ", "08",     "Até o Produto ", "Até o Produto ", "Até o Produto ", "mv_ch8",  "C",   12,         0,         0,        "G",   "!VAZIO(MV_PAR08)", "SB1", " ",      " ",    "mv_par08", " "			  ,     " "			   ,       " "			  ,       " ",     " "			,     " "			,     " "		,       Nil		,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp4,    aHelp4,     Nil )
      PutSX1("SACR05    ", "09",     "Ordem de      ", "Ordem de      ", "Ordem de      ", "mv_ch9",  "N",    1,         0,         1,        "C",   ""                , " "  , " ",      " ",    "mv_par08", "Assunto+Ocorr ",     "Assunto+Ocorr",       "Assunto+Ocorr",    	  " ",     "Produtos"	,     "Produtos"	,     "Produtos",       Nil		,     	Nil,     Nil,     Nil,     Nil,       Nil,    	 Nil,     Nil,     Nil,     aHelp5,    aHelp5,     Nil )
      
Return*/