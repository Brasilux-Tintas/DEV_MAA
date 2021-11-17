#include "rwmake.ch"       
#include "topconn.ch"
#include "font.ch"   
#include "avprint.ch"    
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "Protheus.ch"                                
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRSACR01 ºAutor  ³                     º Data ³ 21/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressão dos SAC's.                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
- Variaveis utilizadas para parametros:
- Melhorias devido a reformulação do SAC. - 30/03/05
- Adequação para impressão direto na tela do SAC. - 30/05/05
*/
User Function BRSACR01(nOpc)
     Local nOpcX := Iif(nOpc == Nil, 2, nOpc)
     Linha    := 0
     xLinha   := 0
     cCol     := 0
     cCol1    := 0
     Private nAuxT    := 0
     If nOpcX == 2
        //VldPerg()  //LGS#20200211 - Adequação de release 12.1.25 e posteriores
        nOpcA    := 0
        i        := 1
        oDlg     := oSend( MSDialog(), "New", 8, 10, 18, 63,"Impressão do SAC",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)

        @ 20,018 SAY "Este relatorio tem como funcao, Imprimir/Consultar  "
        @ 30,018 SAY "SAC's. Podendo ser impresso um ou mais SAC's.       "
        @ 57,170 BMPBUTTON TYPE 05 ACTION (Pergunte("SACR01", .t.))

        bOk      := {||nOpcA := 1, oSend(oDlg, "End")}
        bCancel  := {||nOpcA := 0, oSend(oDlg, "End")}
        bInit    := {|| EnchoiceBar(oDlg, bOk, bCancel) }

        oSend( oDlg, "Activate",,,,.T.,,, bInit )

        If nOpca == 0
           Return
        EndIf
        Pergunte("SACR01", .f.)
     Else
        mv_par01 := SZQ->ZQ_NUM
        mv_par02 := SZQ->ZQ_NUM
     Endif
     
     MsAguarde({|| SACR01_1() }, "Aguarde", "Em processando conforme parametros...")

     DbSelectArea("TCQ")            
     DbGotop()
     If Eof()
        MsgStop("Nao ha dados a serem gerados com estes parametros.")
        DbSelectArea("TCQ") 
        DbCloseArea()
        Return
     Endif  

     Processa({|lEnd| SACR01_2() })
                                  
  	 DbSelectArea("TCQ")            
     DbGotop()
   	 
   	 If nOpcX == 2
		If MV_PAR04 = 1
		 	Processa({|lEnd| ImpAut() })
	 		envMail()	
	 	EndIf
	 EndIf   	 
     DbSelectArea("TCQ") 
     Dbclosearea()
	

Return Nil

/*******************************************************************************/
/*** SACR01_1 - Busca dados dos SAC's de acordo com parâmetros.              ***/
/*******************************************************************************/
Static Function SACR01_1()
       Local cQuery := ""
       cQuery += "SELECT * "
       cQuery += "FROM "+RetSqlName("SZQ")+" SZQ "
       cQuery += "WHERE SZQ.ZQ_FILIAL = '"+xFilial("SZQ")+ "' "
       cQuery += "  AND SZQ.D_E_L_E_T_ <> '*' "
       cQuery += "  AND SZQ.ZQ_NUM BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
       cQuery += "ORDER BY SZQ.ZQ_NUM "
       cQuery := ChangeQuery(cQuery)
       DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F.)
Return 
            
/*******************************************************************************/
/*** SACR01_2 - Impressão dos SAC's.                                         ***/
/*******************************************************************************/                         
Static Function SACR01_2()
	   Local _nY, _nX
	   Private oPrn:= TMSPrinter():New( "Impressão de SAC." )
       oPrn:SetLandscape()      //SetPortrait()   

       AVPRINT oPrn NAME "Impressão de SAC."
               ProcRegua(150)

               oFont1 := TFont():New("Arial"      , 9, 07, .F., .T., 5, .T., 5, .T., .F.)
               oFont2 := TFont():New("Courier New", 9, 14, .F., .T., 5, .F., 5, .T., .F.)
               oFont3 := TFont():New("Courier New", 9, 10, .F., .T., 5, .F., 5, .T., .F.)
               oFont4 := TFont():New("Courier New", 9, 10, .F., .F., 5, .T., 5, .T., .F.)
               oFont5 := TFont():New("Arial"      , 9, 10, .F., .F., 5, .F., 5, .T., .F.)
               oFont6 := TFont():New("Arial"      , 9, 09, .F., .T., 5, .T., 5, .T., .F.)
               oFont7 := TFont():New("Arial"      , 9, 10, .F., .F., 5, .T., 5, .T., .F.)

               AVPAGE
                 DbSelectArea("TCQ")
                 DbGotop()
                 While !EoF()
                       SACR01_3()
                       DbSelectArea("SZR")            
                       DbSetOrder(1)
                       DbSeek(xFilial("SZR")+TCQ->ZQ_NUM)
                       While TCQ->ZQ_NUM == SZR->ZR_NUM  
                             cItemDev := Iif(Alltrim(SZR->ZR_ITEMDEV) == "1", "SIM", "NÃO")
                             oPrn:Say(Linha, cCol     , SZR->ZR_SEQITEM                          , oFont5 )
                             oPrn:Say(Linha, cCol+140 , SZR->ZR_OCORREN+" - "+SubStr(Posicione("SU9", 1, xFilial("SU9")+SZR->ZR_ASSUNTO+SZR->ZR_OCORREN, "U9_DESC") , 1, 25), oFont6 )
                             oPrn:Say(Linha, cCol+890 , AllTrim(SubStr(SZR->ZR_PRODUTO, 1, 5)+'.'+SubStr(SZR->ZR_PRODUTO, 6, 2)+'.'+SubStr(SZR->ZR_PRODUTO, 8, 3)+'-'+SubStr(SZR->ZR_PRODUTO, 11, 2))+" - "+Posicione("SB1", 1, xFilial("SB1")+SZR->ZR_PRODUTO, "B1_DESC") , oFont6 )
                             oPrn:Say(Linha, cCol+1845, Transform(SZR->ZR_QTD,"@E 9,999")         , oFont5 )
                             oPrn:Say(Linha, 2040, SZR->ZR_LOTE                                   , oFont5 )
                             oPrn:Say(Linha, 2240, Transform(SZR->ZR_VUORI,"@E 99,999.99")        , oFont5 )
                             oPrn:Say(Linha, cCol+2410, SZR->ZR_PEDIDO                            , oFont5 )
                             oPrn:Say(Linha, cCol+2610, SZR->ZR_NUMNF                             , oFont5 )
                             oPrn:Say(Linha, cCol+2870, DTOC(SZR->ZR_DTVALID)                     , oFont5 )
                             oPrn:Say(Linha, cCol+3160, cItemDev                                  , oFont5 )
                             Linha += 40
                             If Linha > 2200
                                SACR01_3()
                             Endif
                             DbSelectArea("SZR")
                             DbSkip()
                       Enddo
                       //Impressão do Parecer no SAC
                       Linha += 40
                       oPrn:Say(Linha, cCol+340 , "*** PARECER ***" , oFont6 )
                       Linha += 40
                       cMemImp := ''
                       nLinImp := 0
                       nLinMem := 0
                       nAuxLin := 0
                       cMemAux := ""
                       aMemAux := {}
                       cQry1xx := ""
                       cQry1xx += "SELECT *, CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), SZS.ZS_PARECER)) AS ZS_PARECER "
                       cQry1xx += "FROM "+RetSqlName("SZS")+" SZS WITH (NOLOCK) "
                       cQry1xx += "WHERE SZS.ZS_FILIAL = '"+xFilial("SZQ")+"' "
                       cQry1xx += "  AND SZS.ZS_NUM    = '"+TCQ->ZQ_NUM+"' "
                       cQry1xx += "  AND SZS.ZS_LOG NOT IN('ABE', 'ENC') AND D_E_L_E_T_ ='' "
                       cQry1xx += "ORDER BY SZS.ZS_DATA, SZS.ZS_HORA DESC "
                       TCQuery cQry1xx ALIAS "MEM" NEW
                       DbSelectArea("MEM")
                       While !Eof()
                             If !Empty(AllTrim(MEM->ZS_PARECER))
                                nLinMem := MlCount(Alltrim(MEM->ZS_PARECER), 42)
                                cMemAux := ""
                                For _nY := 1 To nLinMem
                                    cMemAux += Upper(Alltrim(MemoLine(AllTrim(MEM->ZS_PARECER), 42, _nY))+' ')
                                Next
                             Endif
                             If !Empty(Alltrim(cMemAux))
                                aAdd(aMemAux, { UPPER( MEM->ZS_LOG+" - "+SubStr(Alltrim(MEM->ZS_RESP), 1, 10)+"("+DTOC(STOD(MEM->ZS_DATA))+"-"+Alltrim(MEM->ZS_HORA)+")" ), u_TiraAcento(cMemAux)} )
                             Endif
                             DbSelectArea("MEM")
                             DbSkip()
                       Enddo
                       DbSelectArea("MEM")
                       DbCloseArea()
                       For _nY := 1 To Len(aMemAux)
                           nLinImp := Int((Len(aMemAux[_nY][2]) / 42))+1
                           oPrn:Say( Linha , 0140 , aMemAux[_nY][1], oFont3 )
                           nPos := 1
                           For _nX := 1 to nLinImp
                               oPrn:Say( Linha , 0890 , Alltrim(SubStr(aMemAux[_nY][2], nPos, 42)), oFont4 ) //Linha 0130
                               nPos += 42
                               nAuxLin += 1
                               Linha += 40
                               If Linha > 2080
                                  nPosAtu := nPos
                                  SACR01_3()
                                  nPos := nPosAtu
                               Endif
                           Next
                           If Linha > 2080
                              nPosAtu := nPos
                              SACR01_3()
                              nPos := nPosAtu
                           Endif
                           Linha += 40
                       Next
                       /*
                       DbSelectArea("SZS")
                       DbSetOrder(1)
                       DbSeek(xFilial("SZS")+TCQ->ZQ_NUM, .t.)
                       If Found()
                          While !Eof() .and. SZS->ZS_NUM == TCQ->ZQ_NUM
                                If !SZS->ZS_LOG $ 'ABE.ENC'
                                   If !Empty(AllTrim(SZS->ZS_PARECER))
                                      cMemImp := ""
                                      oPrn:Say( Linha , 0140 , UPPER(SZS->ZS_LOG+" - "+SubStr(Alltrim(SZS->ZS_RESP), 1, 10)+"("+DTOC(SZS->ZS_DATA)+"-"+Alltrim(SZS->ZS_HORA)+")"), oFont3 )
                                      nLinMem := MlCount(Alltrim(SZS->ZS_PARECER), 42)
                                      For _nY := 1 To nLinMem
                                          cMemImp += Upper(Alltrim(MemoLine(AllTrim(SZS->ZS_PARECER), 42, _nY))+' ')
                                      Next
                                      If !Empty(cMemImp)
                                         nLinImp := Int((Len(cMemImp) / 42))
                                         If ((Len(cMemImp)/42) - Int((Len(cMemImp) / 42))) > 0
                                            nLinImp += 1
                                         Endif
                                         nPos := 1
                                         For _nY := 1 to nLinImp
                                             oPrn:Say( Linha , 0890 , Alltrim(SubStr(cMemImp, nPos, 42)), oFont4 ) //Linha 0130
                                             nPos += 42
                                             nAuxLin += 1
                                             Linha += 40
                                             If Linha > 2200
                                                nPosAtu := nPos
                                                SACR01_3()
                                                nPos := nPosAtu
                                             Endif
                                         Next
                                      Endif
                                      Linha += 40
                                   Endif
                                Endif
                                If Linha > 2200
                                   SACR01_3()
                                Endif
                                DbSelectArea("SZS")
                                DbSkip()
                          Enddo
                       Endif
                       */
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

/*******************************************************************************/
/*** SACR01_3 - Cabeçalho do SAC.                                            ***/
/*******************************************************************************/                         
Static FUNCTION SACR01_3()
       Local cStatus, cTipoSAC, cDevolv
       //Local cDepto
       Local lObsDev := .f.
       Local lObsCli := .f.
       Local nAuxLin := 0
       Local nY
       If Linha <> 0
          AVNEWPAGE
       Endif                            
                           
       cStatus  := Iif(TCQ->ZQ_STATUS  == "1" , "PENDENTE"  , "ENCERRADO")
       cTipoSAC := Iif(TCQ->ZQ_TIPOSAC == "1" , "RECLAMAÇÃO", "SUGESTÃO")
       cDevolv  := Iif(TCQ->ZQ_DEVOLV  == "1" , "SIM"       , "NÃO")
       cData    := SubStr(TCQ->ZQ_DATA,7,2)+"/"+SubStr(TCQ->ZQ_DATA,5,2)+"/"+SubStr(TCQ->ZQ_DATA,1,4)
       Linha := 10                           
       oPrn:Say( Linha , 0010 , "NUM.SAC.:"                                                                           , oFont3 ) //Linha 0010
       oPrn:Say( Linha , 0250 , TCQ->ZQ_NUM                  	                                                      , oFont4 ) //Linha 0010
       oPrn:Say( Linha , 0600 , "CLIENTE.:"                                                                           , oFont3 ) //Linha 0010
       oPrn:Say( Linha , 0810 , TCQ->ZQ_CLIENTE+" - "+Posicione("SA1", 1, xFilial("SA1")+TCQ->ZQ_CLIENTE, "A1_NREDUZ"), oFont4 ) //Linha 0010
       oPrn:Say( Linha , 1600 , "DATA....:"                                                                           , oFont3 ) //Linha 0010
       oPrn:Say( Linha , 1810 , cData                                                                                 , oFont4 ) //Linha 0010
       oPrn:Say( Linha , 2090 , "TEL.CLI..:"                                                                          , oFont3 ) //Linha 0010
       oPrn:Say( Linha , 2330 , Posicione("SA1", 1, xFilial("SA1")+TCQ->ZQ_CLIENTE, "A1_TEL")                         , oFont4 ) //Linha 0010
       oPrn:Say( Linha , 2700 , "CONTATO.:"                                                                           , oFont3 ) //Linha 0010
       oPrn:Say( Linha , 2930 , TCQ->ZQ_CONTATO                                                                       , oFont4 ) //Linha 0010
       Linha += 60
       oPrn:Say( Linha , 0010 , "STATUS..:"                          , oFont3 ) //Linha 0070
       oPrn:Say( Linha , 0250 , cStatus                              , oFont4 ) //Linha 0070
       oPrn:Say( Linha , 0600 , "TIPO SAC:"                          , oFont3 ) //Linha 0070
       oPrn:Say( Linha , 0800 , cTipoSAC                             , oFont4 ) //Linha 0070
       oPrn:Say( Linha , 1600 , "TEM DEV.?"                          , oFont3 ) //Linha 0070
       oPrn:Say( Linha , 1810 , cDevolv                              , oFont4 ) //Linha 0070
       Linha += 60 
       cMemImp := ''
       nLinImp := 0
       nLinMem := 0
       DbSelectArea("SZS")
       DbSetOrder(1)
       DbSeek(xFilial("SZS")+TCQ->ZQ_NUM, .t.)
       If Found()
       	If nAuxT = 0
          While !Eof() .and. SZS->ZS_NUM == TCQ->ZQ_NUM
                If SZS->ZS_LOG $ 'ABE'
                   If !Empty(AllTrim(SZS->ZS_PARECER))
                      oPrn:Say( Linha , 0010 , "OBS.CLI.:"                          , oFont3 )
                      nLinMem := MlCount(Alltrim(SZS->ZS_PARECER), 80)
                      For nY := 1 To nLinMem
                          cMemImp += Alltrim(MemoLine(AllTrim(SZS->ZS_PARECER), 80, nY))+' '
                      Next
                      If !Empty(cMemImp)
                         nLinImp := Int((Len(cMemImp) / 140))
                         If ((Len(cMemImp)/140) - Int((Len(cMemImp) / 140))) > 0
                            nLinImp += 1
                         Endif
                         nPos := 1
                         For nY := 1 to nLinImp
                             oPrn:Say( Linha , 0250 , Alltrim(SubStr(cMemImp, nPos, 140)), oFont4 ) //Linha 0130
                             nPos += 140
                             nAuxLin += 1
                             Linha += 60
                         Next
                      Endif
                      lObsCli := .t.
                   Endif
                Endif
                DbSelectArea("SZS")
                DbSkip()
          EndDo
      	Endif
       Endif  
       
       if nAuxT = 0
       	 if nY >= 7
       		AVNEWPAGE
       		nAuxT := 1
       		Linha := 0 
       	 	nAuxLin := 0
       	 endif
       endif
       If lObsDev
          nAuxLin := nLinImp - 1
       Else
          If lObsCli
             nAuxLin -= 1
          Endif
       Endif
       // Impressão da Estrutura da pagina.
       //TRACO_BOLD1
       oPrn:Line( Linha - 1,   10, Linha - 1     , 3340 )
       oPrn:Line( Linha    ,   10, Linha         , 3340 )
       oPrn:Line( Linha + 1,   10, Linha + 1     , 3340 )
       Linha  += 1
       xLinha := 100
       //BORDA_BOLD1
       oPrn:Line( Linha    ,   09, (Linha+xLinha),   09 )
       oPrn:Line( Linha    ,   10, (Linha+xLinha),   10 )
       oPrn:Line( Linha    ,   11, (Linha+xLinha),   11 )
       oPrn:Line( Linha    , 3338, (Linha+xLinha), 3338 )
       oPrn:Line( Linha    , 3339, (Linha+xLinha), 3339 )
       oPrn:Line( Linha    , 3340, (Linha+xLinha), 3340 )
       Linha += 34
       cCol  := 20       
       oPrn:Say(  Linha     , 0020, "ITEM"      , oFont3 )
       oPrn:Line( Linha - 34,  128, (Linha - 34 + xLinha),  128 )
       oPrn:Line( Linha - 34,  129, (Linha - 34 + xLinha),  129 )
       oPrn:Line( Linha - 34,  130, (Linha - 34 + xLinha),  130 )
       oPrn:Say(  Linha     , 0395, "OCORRÊNCIA", oFont3 )
       oPrn:Line( Linha - 34,  878, (Linha - 34 + xLinha),  878 )
       oPrn:Line( Linha - 34,  879, (Linha - 34 + xLinha),  879 )
       oPrn:Line( Linha - 34,  880, (Linha - 34 + xLinha),  880 )
       oPrn:Say(  Linha     , 1250, "PRODUTO"   , oFont3 )
       oPrn:Line( Linha - 34, 1848, (Linha - 34 + xLinha), 1848 )
       oPrn:Line( Linha - 34, 1849, (Linha - 34 + xLinha), 1849 )
       oPrn:Line( Linha - 34, 1850, (Linha - 34 + xLinha), 1850 )
       oPrn:Say(  Linha     , 1870, "QTDE."     , oFont3 )
       oPrn:Line( Linha - 34, 2003, (Linha - 34 + xLinha), 2003 )
       oPrn:Line( Linha - 34, 2004, (Linha - 34 + xLinha), 2004 )
       oPrn:Line( Linha - 34, 2005, (Linha - 34 + xLinha), 2005 )
       oPrn:Say(  Linha     , 2040, "LOTE"  , oFont3 )
       oPrn:Line( Linha - 34, 2198, (Linha - 34 + xLinha), 2198 )
       oPrn:Line( Linha - 34, 2199, (Linha - 34 + xLinha), 2199 )
       oPrn:Line( Linha - 34, 2200, (Linha - 34 + xLinha), 2200 )
       oPrn:Say(  Linha     , 2230, "V. UNIT."         , oFont3 )
       oPrn:Line( Linha - 34, 2378, (Linha - 34 + xLinha), 2378 )
       oPrn:Line( Linha - 34, 2379, (Linha - 34 + xLinha), 2379 )
       oPrn:Line( Linha - 34, 2380, (Linha - 34 + xLinha), 2380 )
       oPrn:Say(  Linha     , 2400, "NUM.PED."  , oFont3 )
       oPrn:Line( Linha - 34, 2598, (Linha - 34 + xLinha), 2598 )
       oPrn:Line( Linha - 34, 2599, (Linha - 34 + xLinha), 2599 )
       oPrn:Line( Linha - 34, 2600, (Linha - 34 + xLinha), 2600 )
       oPrn:Say(  Linha     , 2620, "NF ORIGEM" , oFont3 )
       oPrn:Line( Linha - 34, 2858, (Linha - 34 + xLinha), 2858 )
       oPrn:Line( Linha - 34, 2859, (Linha - 34 + xLinha), 2859 )
       oPrn:Line( Linha - 34, 2860, (Linha - 34 + xLinha), 2860 )
       oPrn:Say(  Linha     , 2895, "VALIDADE"  , oFont3 )
       oPrn:Line( Linha - 34, 3128, (Linha - 34 + xLinha), 3128 )
       oPrn:Line( Linha - 34, 3129, (Linha - 34 + xLinha), 3129 )
       oPrn:Line( Linha - 34, 3130, (Linha - 34 + xLinha), 3130 )
       oPrn:Say(  Linha     , 3140, "ITEM DEV." , oFont3 )
       Linha += 65
       //TRACO_BOLD1 
       oPrn:Line( Linha - 1,   10, Linha - 1     , 3340 )
       oPrn:Line( Linha    ,   10, Linha         , 3340 )
       oPrn:Line( Linha + 1,   10, Linha + 1     , 3340 )
       xLinha := 100
       nLinAtu := Linha + 30
       nAuxLin := 20 - nAuxLin
       For nY := 1 To nAuxLin
           Linha += 1
           //BORDA_BOLD1 
           oPrn:Line( Linha    ,   09, (Linha+xLinha),   09 )
           oPrn:Line( Linha    ,   10, (Linha+xLinha),   10 )
           oPrn:Line( Linha    ,   11, (Linha+xLinha),   11 )
           oPrn:Line( Linha    , 3338, (Linha+xLinha), 3338 )
           oPrn:Line( Linha    , 3339, (Linha+xLinha), 3339 )
           oPrn:Line( Linha    , 3340, (Linha+xLinha), 3340 )
           //BORDA_NORMAL
           oPrn:Line( Linha    ,  129, (Linha+xLinha),  129 )
           oPrn:Line( Linha    ,  879, (Linha+xLinha),  879 )
           oPrn:Line( Linha    , 1849, (Linha+xLinha), 1849 )
           oPrn:Line( Linha    , 2004, (Linha+xLinha), 2004 )
           oPrn:Line( Linha    , 2199, (Linha+xLinha), 2199 )
           oPrn:Line( Linha    , 2379, (Linha+xLinha), 2379 )
           oPrn:Line( Linha    , 2599, (Linha+xLinha), 2599 )
           oPrn:Line( Linha    , 2859, (Linha+xLinha), 2859 )
           oPrn:Line( Linha    , 3129, (Linha+xLinha), 3129 )
           Linha += 100
       Next
       //TRACO_BOLD1
       oPrn:Line( Linha    ,   10, Linha         , 3340 )
       oPrn:Say( 2360 , 10   , "Brasilux Tintas Técnicas"      , oFont1 ) //Linha
       oPrn:Say( 2360 , 3050 , "Emitido em: "+dtoc(dDataBase)  , oFont1 ) //Linha

       Linha := nLinAtu

	       
Return NIL                              

/*******************************************************************************/
/*** VLDPERG - Ajusta perguntas com o SX1.                                   ***/
/*******************************************************************************/
//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*Static Function VldPerg() 
       Local aHelp       := {}
       Local aHelp1      := {}
       aAdd( aHelp , "Informe o Numero do SAC.       " )
       aAdd( aHelp , "                               " )
       aAdd( aHelp1, "Imprime ou não o parecer.      " )
       aAdd( aHelp1, "                               " )
       aAdd( aHelp1, "Enviar SAC por Email?		     " )
       aAdd( aHelp1, "                          	 " )

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Inclui parametros de consulta                                                  ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      //     X1_GRUPO  X1_ORDEM  X1_PERGUNT X1_PERSPA   X1_PERENG   X1_VARIAVL X1_TIPO X1_TAMANHO X1_DECIMAL X1_PRESEL X1_GSC X1_VALID X1_F3 X1_GRPSXG X1_PYME X1_VAR01    X1_DEF01 X1_DEFSPA1 X1_DEFENG1 X1_CNT01 X1_VAR02 X1_DEF02 X1_DEFSPA2 X1_DEFENG2 X1_CNT02 X1_VAR03 X1_DEF03 X1_DEFSPA3 X1_DEFENG3 X1_CNT03 X1_VAR04 X1_DEF04 X1_DEFSPA4 X1_DEFENG4 X1_CNT04 X1_VAR05 X1_DEF05 X1_DEFSPA5 X1_DEFENG5 X1_CNT05 X1_HELP
      PutSX1("SACR01    ", "01",     "Do SAC"         , "Do SAC"         , "Do SAC"         , "mv_ch1",  "C",    6,         0,         0,        "G",   "",      " ",  " ",      " ",    "mv_par01", " "  ,     " ",       " ",       " ",     " "  ,     " ",     " ",       Nil,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp,     aHelp,     Nil )
      PutSX1("SACR01    ", "02",     "Até SAC"        , "Até SAC"        , "Até SAC"        , "mv_ch2",  "C",    6,         0,         0,        "G",   "",      " ",  " ",      " ",    "mv_par02", " "  ,     " ",       " ",       " ",     " "  ,     " ",     " ",       Nil,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp,     aHelp,     Nil )
      PutSX1("SACR01    ", "03",     "Imprime Parecer", "Imprime Parecer", "Imprime Parecer", "mv_ch3",  "N",    1,         0,         0,        "C",   "",      " ",  " ",      " ",    "mv_par03", "Sim",     " ",       " ",       " ",     "Não",     " ",     " ",       Nil,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp1,    aHelp1,    Nil )
	  PutSX1("SACR01    ", "04",     "Enviar Email?", "Enviar Email?", "Enviar Email?", "mv_ch4",  "N",    1,         0,         0,        "C",   "",      " ",  " ",      " ",    "mv_par04", "Sim",     " ",       " ",       " ",     "Não",     " ",     " ",       Nil,       Nil,     Nil,     Nil,     Nil,       Nil,       Nil,     Nil,     Nil,     aHelp1,    aHelp1,    Nil )

Return*/

Static Function envMail()         
Sleep( 3000 )
DbSelectArea("TCQ")
DbGotop() 
cCodUser:= RetCodUsr()
cPara:= alltrim(UsrRetMail(RetCodUsr()))
cAssunto := "Anexo do SAC "+TCQ->ZQ_NUM
cTexEnc := ""
cCC      := ""
cArquivo := "\SAC\"+TCQ->ZQ_NUM+""+SUBSTR(RetCodUsr(),4,3)+".pdf"
U_EnvMail(cAssunto,cTexEnc,cPara,cCC,cArquivo) 
Return nil
return

Static Function ImpAut()
Local _nY, _nX
Private oPrinter

nFlag := 0 
oFont1 := TFont():New("Arial"      , 9, 07, .F., .T., 5, .T., 5, .T., .F.)
oFont2 := TFont():New("Courier New", 9, 14, .F., .T., 5, .F., 5, .T., .F.)
oFont3 := TFont():New("Courier New", 9, 10, .F., .T., 5, .F., 5, .T., .F.)
oFont4 := TFont():New("Courier New", 9, 08, .F., .F., 5, .T., 5, .T., .F.)
oFont5 := TFont():New("Arial"      , 9, 10, .F., .F., 5, .F., 5, .T., .F.)
oFont6 := TFont():New("Arial"      , 9, 09, .F., .T., 5, .T., 5, .T., .F.)
oFont7 := TFont():New("Arial"      , 9, 10, .F., .F., 5, .T., 5, .T., .F.)

If oPrinter == Nil
     lPreview := .T.
     oPrinter      := FWMSPrinter():New(TCQ->ZQ_NUM+''+SUBSTR(RetCodUsr(),4,3),2,.F.,"/SAC/",.T.,.F.,,"PDF",.T., .T., .F.,.F.)
     oPrinter:SetPortrait()
     //oPrinter:Setup()
     oPrinter:SetPaperSize(9)
     oPrinter:SetMargin(10,0,20,0)
	     
EndIf       
oPrinter:StartPage()
DbSelectArea("TCQ")
DbGotop()
While !EoF()
	ImpAut_2(nFlag)
	nFlag := 1
    DbSelectArea("SZR")            
    DbSetOrder(1)
    Linha += -20 
    DbSeek(xFilial("SZR")+TCQ->ZQ_NUM)
    	While TCQ->ZQ_NUM == SZR->ZR_NUM 
    		cItemDev := Iif(Alltrim(SZR->ZR_ITEMDEV) == "1", "SIM", "NÃO")
            oPrinter:Say(Linha, 011 , SZR->ZR_SEQITEM, oFont1 )
            oPrinter:Say(Linha, 038 , SZR->ZR_OCORREN+" - "+SubStr(Posicione("SU9", 1, xFilial("SU9")+SZR->ZR_ASSUNTO+SZR->ZR_OCORREN, "U9_DESC") , 1, 25), oFont1 )
            oPrinter:Say(Linha, 173 , AllTrim(SubStr(SZR->ZR_PRODUTO, 1, 5)+'.'+SubStr(SZR->ZR_PRODUTO, 6, 2)+'.'+SubStr(SZR->ZR_PRODUTO, 8, 3)+'-'+SubStr(SZR->ZR_PRODUTO, 11, 2))+" - "+Posicione("SB1", 1, xFilial("SB1")+SZR->ZR_PRODUTO, "B1_DESC") , oFont1 )
            oPrinter:Say(Linha, 323 , Transform(SZR->ZR_QTD,"@E 9,999")        , oFont1 )
            oPrinter:Say(Linha, 353 , SZR->ZR_LOTE                             , oFont1 )
            oPrinter:Say(Linha, 388, Transform(SZR->ZR_VUORI,"@E 99,999.99")   , oFont1 )
            oPrinter:Say(Linha, 423, SZR->ZR_PEDIDO                            , oFont1 )
            oPrinter:Say(Linha, 460, SZR->ZR_NUMNF                             , oFont1 )
            oPrinter:Say(Linha, 498, DTOC(SZR->ZR_DTVALID)                     , oFont1 )
            oPrinter:Say(Linha, 543, cItemDev                                  , oFont1 )
            Linha += 10
            If Linha > 800
            	ImpAut_2(nFlag)
            Endif
            DbSelectArea("SZR")
            DbSkip()
		Enddo
        //Impressão do Parecer no SAC
        Linha += 10
        oPrinter:Say(Linha, 080, "*** PARECER ***" , oFont6 )
        Linha += 10
        cMemImp := ''
        nLinImp := 0
        nLinMem := 0
        nAuxLin := 0
        cMemAux := ""
        aMemAux := {}
        cQry1xx := ""
        cQry1xx += "SELECT *, CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), SZS.ZS_PARECER)) AS ZS_PARECER "
        cQry1xx += "FROM "+RetSqlName("SZS")+" SZS WITH (NOLOCK) "
        cQry1xx += "WHERE SZS.ZS_FILIAL = '"+xFilial("SZQ")+"' "
        cQry1xx += "  AND SZS.ZS_NUM    = '"+TCQ->ZQ_NUM+"' "
        cQry1xx += "  AND SZS.ZS_LOG NOT IN('ABE', 'ENC') AND D_E_L_E_T_ ='' "
        cQry1xx += "ORDER BY SZS.ZS_DATA, SZS.ZS_HORA DESC "
        TCQuery cQry1xx ALIAS "MEM" NEW
        DbSelectArea("MEM")
        While !Eof()
        If !Empty(AllTrim(MEM->ZS_PARECER))
        	nLinMem := MlCount(Alltrim(MEM->ZS_PARECER), 30)
        	cMemAux := ""
         	For _nY := 1 To nLinMem
            	cMemAux += Upper(Alltrim(MemoLine(AllTrim(MEM->ZS_PARECER), 30, _nY))+' ')
            Next
        Endif                                                                        
        If !Empty(Alltrim(cMemAux))
        	aAdd(aMemAux, { UPPER( MEM->ZS_LOG+" - "+SubStr(Alltrim(MEM->ZS_RESP), 1, 10)+"("+DTOC(STOD(MEM->ZS_DATA))+"-"+Alltrim(MEM->ZS_HORA)+")" ), u_TiraAcento(cMemAux)} )
        Endif
        DbSelectArea("MEM")
        DbSkip()
  Enddo
  DbSelectArea("MEM")
  DbCloseArea()
  For _nY := 1 To Len(aMemAux)
  	nLinImp := Int((Len(aMemAux[_nY][2]) / 33))+1
    oPrinter:Say( Linha , 038 , aMemAux[_nY][1], oFont1 )
    nPos := 1
    For _nX := 1 to nLinImp
    	oPrinter:Say( Linha , 173 , Alltrim(SubStr(aMemAux[_nY][2], nPos, 33)), oFont4 ) //Linha 0130
        nPos += 33
        nAuxLin += 1
        Linha += 10
        If Linha > 770
        	nPosAtu := nPos
            ImpAut_2(nFlag)
            nPos := nPosAtu
        Endif
    Next
    If Linha > 770
    	nPosAtu := nPos
        ImpAut_2(nFlag)
        nPos := nPosAtu
    Endif
  	Linha += 10
  Next	
DbSelectArea("TCQ")
DbSkip()
EndDo	     
oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()
oFont5:End() 
oFont6:End() 
oFont7:End()
MS_FLUSH() 
oPrinter:EndPage()
If lPreview
     oPrinter:Preview()
EndIf                      
FreeObj(oPrinter)
oPrinter := Nil   
    
return 

Static function ImpAut_2(nFlag)

 Local cStatus, cTipoSAC, cDevolv, nY
       //Local cDepto
       //Local lObsDev := .f.
       Local lObsCli := .f.
       Local nAuxLin := 0

If nFlag = 1
	oPrinter:EndPage()
	oPrinter:StartPage()
endIf          

cStatus  := Iif(TCQ->ZQ_STATUS  == "1" , "PENDENTE"  , "ENCERRADO")
cTipoSAC := Iif(TCQ->ZQ_TIPOSAC == "1" , "RECLAMAÇÃO", "SUGESTÃO")
cDevolv  := Iif(TCQ->ZQ_DEVOLV  == "1" , "SIM"       , "NÃO")
cData    := SubStr(TCQ->ZQ_DATA,7,2)+"/"+SubStr(TCQ->ZQ_DATA,5,2)+"/"+SubStr(TCQ->ZQ_DATA,1,4)

Linha := 20                           
If nFlag = 0
	oPrinter:Say( Linha , 0010 , "NUM.SAC.:"                                                                           , oFont3 ) //Linha 0010
	oPrinter:Say( Linha , 0055 , TCQ->ZQ_NUM                  	                                                      , oFont4 ) //Linha 0010
	oPrinter:Say( Linha , 0120 , "CLIENTE.:"                                                                           , oFont3 ) //Linha 0010
	oPrinter:Say( Linha , 0165 , TCQ->ZQ_CLIENTE+" - "+Posicione("SA1", 1, xFilial("SA1")+TCQ->ZQ_CLIENTE, "A1_NREDUZ"), oFont4 ) //Linha 0010
	oPrinter:Say( Linha , 0310 , "DATA....:"                                                                           , oFont3 ) //Linha 0010
	oPrinter:Say( Linha , 0355 , cData                                                                                 , oFont4 ) //Linha 0010
	oPrinter:Say( Linha , 0400 , "TEL.CLI..:"                                                                          , oFont3 ) //Linha 0010
	oPrinter:Say( Linha , 0447 , Posicione("SA1", 1, xFilial("SA1")+TCQ->ZQ_CLIENTE, "A1_TEL")                         , oFont4 ) //Linha 0010
	oPrinter:Say( Linha , 0492, "CONTATO.:"                                                                           , oFont3 ) //Linha 0010
	oPrinter:Say( Linha , 0537 , TCQ->ZQ_CONTATO                                                                       , oFont4 ) //Linha 0010
	Linha += 10
	oPrinter:Say( Linha , 0010 , "STATUS..:"                          , oFont3 ) //Linha 0070
	oPrinter:Say( Linha , 0055 , cStatus                              , oFont4 ) //Linha 0070
	oPrinter:Say( Linha , 0120 , "TIPO SAC:"                          , oFont3 ) //Linha 0070
	oPrinter:Say( Linha , 0165 , cTipoSAC                             , oFont4 ) //Linha 0070
	oPrinter:Say( Linha , 0310 , "TEM DEV.?"                          , oFont3 ) //Linha 0070
	oPrinter:Say( Linha , 0355 , cDevolv                              , oFont4 ) //Linha 0070
	Linha += 10 
EndIf
	cMemImp := ''
	nLinImp := 0
	nLinMem := 0
	DbSelectArea("SZS")
	DbSetOrder(1)
	DbSeek(xFilial("SZS")+TCQ->ZQ_NUM, .t.)
	If Found()
		If nAuxT = 0
			If nFlag = 0
	        	While !Eof() .and. SZS->ZS_NUM == TCQ->ZQ_NUM
	          		If SZS->ZS_LOG $ 'ABE'
	                	If !Empty(AllTrim(SZS->ZS_PARECER))
	                		oPrinter:Say( Linha , 0010 , "OBS.CLI.:", oFont3 )
	                		nLinMem := MlCount(Alltrim(SZS->ZS_PARECER), 80)
	            			For nY := 1 To nLinMem
	            				cMemImp += Alltrim(MemoLine(AllTrim(SZS->ZS_PARECER), 80, nY))+' '
				            Next                                
	           		 		If !Empty(cMemImp)
	            				nLinImp := Int((Len(cMemImp) / 113))
	            				If ((Len(cMemImp)/113) - Int((Len(cMemImp) / 113))) > 0
	            					nLinImp += 1
	            				Endif
	            				nPos := 1
	            				For nY := 1 to nLinImp
	                				oPrinter:Say( Linha , 055 , Alltrim(SubStr(cMemImp, nPos, 113)), oFont4 ) //Linha 0130
	                				nPos += 113
	                				nAuxLin += 1
	            					Linha += 10
	            				Next
	        				Endif
	        				lObsCli := .t.
	    				Endif
	    			Endif
	    			DbSelectArea("SZS")
					DbSkip()
				EndDo  
			EndIf          
		DbSelectArea("TCQ")
        DbGotop()
        Linha += 10 
		oPrinter:Line( Linha    ,   10, Linha         , 591 )
		Linha  += 1
		xLinha := 20
		//BORDA_BOLD1
		oPrinter:Line( Linha    ,   10, (Linha+xLinha),   10 )
		oPrinter:Line( Linha    , 591, (Linha+xLinha), 591 )
		Linha += 10
        cCol  := 10 
		oPrinter:Say(  Linha     , 011, "ITEM"      , oFont3 )
		oPrinter:Line( Linha - 10, 037, (Linha - 10 + xLinha),  37 )
		oPrinter:Say(  Linha     , 080, "OCORRÊNCIA", oFont3 )
		oPrinter:Line( Linha - 10, 172, (Linha - 10 + xLinha),  172 )
		oPrinter:Say(  Linha     , 240, "PRODUTO"   , oFont3 )
		oPrinter:Line( Linha - 10, 322, (Linha - 10 + xLinha), 322 )
		oPrinter:Say(  Linha     , 325, "QTDE."     , oFont3 )
		oPrinter:Line( Linha - 10, 352, (Linha - 10 + xLinha), 352 )
		oPrinter:Say(  Linha     , 354, "LOTE"  , oFont3 )
       	oPrinter:Line( Linha - 10, 387, (Linha - 10 + xLinha), 387 )
		oPrinter:Say(  Linha     , 390, "V.UNIT" , oFont3 )
		oPrinter:Line( Linha - 10, 422, (Linha - 10 + xLinha), 422 )
		oPrinter:Say(  Linha     , 424, "NUM.PED"  , oFont3 )
		oPrinter:Line( Linha - 10, 459, (Linha - 10 + xLinha), 459 )
		oPrinter:Say(  Linha     , 460, "NF ORIG" , oFont3 )
		oPrinter:Line( Linha - 10, 497, (Linha - 10 + xLinha), 497 )
		oPrinter:Say(  Linha     , 499, "VALID"  , oFont3 )
		oPrinter:Line( Linha - 10, 542, (Linha - 10 + xLinha), 542 )
		oPrinter:Say(  Linha     , 544, "ITEM DEV." , oFont3 )
		oPrinter:Line( Linha - 10, 591, (Linha - 10 + xLinha), 591 )
		Linha += 10
		//TRACO_BOLD1 
       	oPrinter:Line( Linha    ,   10, Linha         , 591 )
        xLinha := 100
		nLinAtu := Linha + 30
		nAuxLin := 20 - nAuxLin
		For nY := 1 To nAuxLin
			Linha += 1
		    //BORDA_BOLD1 
		    oPrinter:Line( Linha    , 010, (Linha+xLinha),   10 )
		    oPrinter:Line( Linha    , 591, (Linha+xLinha), 591 )
		    //BORDA_NORMAL
		    oPrinter:Line( Linha    , 037, (Linha+xLinha), 037  )
		    oPrinter:Line( Linha    , 172, (Linha+xLinha), 172  )
		    oPrinter:Line( Linha    , 322, (Linha+xLinha), 322  )
		    oPrinter:Line( Linha    , 352, (Linha+xLinha), 352  )
		    oPrinter:Line( Linha    , 387, (Linha+xLinha), 387  )
		    oPrinter:Line( Linha    , 422, (Linha+xLinha), 422  )
		    oPrinter:Line( Linha    , 459, (Linha+xLinha), 459  )
		    oPrinter:Line( Linha    , 497, (Linha+xLinha), 497  )
		    oPrinter:Line( Linha    , 542, (Linha+xLinha), 542  )
		    oPrinter:Line( Linha    , 591, (Linha+xLinha), 591  )
		    If nFlag = 1
				Linha += 33 
			Else   
		    	Linha += 42                    
		    EndIf	    
		Next 	 
		If nFlag = 1
			oPrinter:Line( Linha +67    ,   10, Linha +67, 591 )  
		Else   
			oPrinter:Line( Linha +58    ,   10, Linha +58, 591 )  
		EndIf   
		Linha := nLinAtu   
	EndIf
EndiF
Return()