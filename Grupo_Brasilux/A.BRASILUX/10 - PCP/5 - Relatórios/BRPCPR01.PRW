#include 'rwmake.ch'
#include "topconn.ch"
#include "avprint.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                                                             

±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCPR01 ºAutor  ³ Luís G. de Souza   º Data ³  20/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressão das ordens de produção em modo gráfico, para emisº±±
±±º          ³ são do código de barras.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
BRPCPR01 - CHAMADA DO PROGRAMA PRINCIPAL NO MENU DO USUÁRIO
PCPR01_1 - QUERY PARA BUSCAR ORDENS DE PRODUÇÃO
PCPR01_2 - MONTAGEM DO LAYOUT DE IMPRESSÃO E CHAMADA DE FUNÇOES
PCPR01_3 - CABEÇALHO DA ORDEM DE PRODUÇÃO - TINTAS / PASTAS
PCPR01_4 - BUSCA ITENS EMPENHADOS
PCPR01_5 - IMPRESSÃO DOS ENSAIOS NAS ORDENS DE PRODUÇÕES - TINTAS / PASTAS
PCPR01_6 - IMPRESSÃO DE AVISO DE LOTES PROIBIDOS
PCPR01_7 - IMPRESSÃO DAS OPERAÇÕES
PCPR01_8 - IMPRESSÃO DAS ORDENS DE PRODUÇÃO DE ENVASE
PCPR01_9 - CABEÇALHO DAS ORDENS DE PRODUÇÃO DE ENVASE
PCPR01_A - 
PCPR01_B - 
*/
User Function BRPCPR01()

     Private cPerg := "PCPR01"
     Private nLin  := 30
     Private nCol  := 30
     Private nLinMax := 2920 
     Private nColMax := 2350
     
     Private _cPula  := 1 // Jose 11/08/2023

     u_zcfga01( 'BRPCPR01' ) //LGS#2021201 - Gravação de log de utilização da rotina
     //                     NOME DA FONTE             NEG ESP          ITA    
     oFont1 := TFont():New("Courier New"        , 9, 19, .F., .F.,  5, .F., 5, .F., .F.)
     oFont2 := TFont():New("Courier New"        , 9, 14, .F., .F.,  5, .F., 5, .F., .F.)
     oFont3 := TFont():New("Courier New"        , 9, 14, .F., .T.,  5, .F., 5, .F., .F.)
     oFont4 := TFont():New("Courier New"        , 9, 13, .F., .F.,  5, .F., 5, .F., .F.)
     oFont5 := TFont():New("Courier New Itálico", 9, 14, .F., .F.,  5, .F., 5, .F., .F.)
     oFont6 := TFont():New("Courier New Itálico", 9, 08, .F., .F.,  5, .F., 5, .F., .F.)
     oFont7 := TFont():New("Courier New"        , 9, 13, .F., .F.,  5, .F., 5, .F., .F.)

     If !u_VldAcesso(funname())
	    MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
     	Return 
  	 Endif 

     
     //VldPerg()  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     If !Pergunte(cPerg,.t.)
        Return
     Else
        MsAguarde({|| PCPR01_1() },"Aguarde","Buscando informações conforme parâmetros...")     
        DbSelectArea("TCQ")            
        DbGotop()
        If EOF()
           MsgBox("Não há dados a serem processados com estes parâmetros/ Ou / Ordem de produção já foi impressa !!!","Atenção","STOP")
           DbSelectArea("TCQ") 
           DbCloseArea()
           Return
        Endif
     Endif
     Processa({|lEnd| PCPR01_2()})

     DbSelectArea("TCQ")
     DbCloseArea()
Return

/**********************************************************************************************************/
/*** PCPR01_2 - Impressão do relatório.                                                                 ***/
/**********************************************************************************************************/
Static Function PCPR01_2()
       Local nVez    := 0
       Local aRetenc := {}
       Local aInfPro := {}
       Local nQtdPas := 0
       Local _cMVLINHAE := GETMV("MV_LINHAEX") //LGS#20200207 - Adequação de release 12.1.25 e posteriores
       Local _cMVLINHAI := GETMV("MV_LINHAIN") //LGS#20200207 - Adequação de release 12.1.25 e posteriores
       Local _cMVQTDINS := GETMV("MV_QTDINSP") //LGS#20200207 - Adequação de release 12.1.25 e posteriores
     
       Private _DATPRF := 0 /// Jose 12/11/2024       
       Private nCmt  := 2.0
       ProcRegua(Val(SubStr(mv_par04, 1, 6)) - Val(SubStr(mv_par03, 1, 6)))
       oPrn:= TMSPrinter():New( "Impressão de Ordens de Produção." )
       oPrn:SetPortrait()      //SetLandscape()
       
       AVPRINT oPrn NAME "Impressão de Ordens de Produção."
               AVPAGE
                    DbSelectArea("TCQ")
                    While !Eof()
                          If TCQ->C2_ITEM $ '02'
                             If Empty(Posicione("SB2", 1, xFilial("SB2")+TCQ->C2_PRODUTO+Posicione("SB1", 1, xFilial("SB1")+TCQ->C2_PRODUTO, "B1_LOCPAD"), "B2_LOCALIZ"))
                                If Len(Alltrim(TCQ->C2_PRODUTO)) == 5 .and. TCQ->C2_QUANT >= 20
                                   DbSelectArea("TCQ")
                                   DbSkip()
                                   Loop
                                Endif
                             Else
                                DbSelectArea("TCQ")
                                DbSkip()
                                Loop
                             Endif
                          Endif
                          nCmt  := 2.0
                          IncProc("Processando Ordem de Producao: "+TCQ->C2_NUM)
                          aRetenc := {}
                          nVez += 1
                          If nVez > 1
                             AVNEWPAGE
                             nLin := 30
                          Endif
                          _NumOrd := TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN
                          _DatEmi := CTOD(SubStr(TCQ->C2_EMISSAO, 7, 2)+"/"+SubStr(TCQ->C2_EMISSAO, 5, 2)+"/"+SUBSTR(TCQ->C2_EMISSAO, 1, 4))
                          //  Jose 12/11/2024   acrecentado
                          _DATPRF := CTOD(SubStr(TCQ->C2_DATPRF, 7, 2)+"/"+SubStr(TCQ->C2_DATPRF, 5, 2)+"/"+SUBSTR(TCQ->C2_DATPRF, 1, 4))
                          //  Jose 12/11/2024   até aqui 
                          _CodRot := TCQ->C2_ROTEIRO
                          _QtdSol := TCQ->C2_QUANT
                          _ObsOrd := TCQ->C2_OBS
                          _DesPro := Posicione("SB1", 1, xFilial("SB1")+TCQ->C2_PRODUTO, "B1_DESC")
                          _DesLin := Iif(Len(Alltrim(TCQ->C2_PRODUTO)) == 12, Posicione("SZ1", 1, xFilial("SZ1")+SubStr(TCQ->C2_PRODUTO, 4, 2), "Z1_DESCR"), "")
                          _CodCat := Alltrim(Posicione("SB1", 1, xFilial("SB1")+TCQ->C2_PRODUTO, "B1_CATALIS"))+Iif(!Empty(Posicione("SB1", 1, xFilial("SB1")+TCQ->C2_PRODUTO, "B1_RELCAT1")), "("+Alltrim(Posicione("SB1", 1, xFilial("SB1")+TCQ->C2_PRODUTO, "B1_RELCAT1"))+")", "")
                          _PadCor := Posicione("SB1", 1, xFilial("SB1")+TCQ->C2_PRODUTO, "B1_PADCOR")
                          _PesEsp := Posicione("SB1", 1, xFilial("SB1")+TCQ->C2_PRODUTO, "B1_PESOESP")
                          
                          PCPR01_3(_NumOrd, _DatEmi, _QtdSol, _DesPro, _DesLin, _CodCat)           //Cabeçalho
                          PCPR01_4(_NumOrd, _DatEmi, _QtdSol, _DesPro, _DesLin, _CodCat, @aRetenc, _PesEsp) //Itens empenhados
                          PCPR01_5(_ObsOrd)                                                               //Impressão dos ensaios

                          //nLin += 60
                          //oPrn:Say(nLin, nCol + 0100, 'TARA:                         PESO FINAL:                         ID. TACHO: '     , oFont2, , , , )

                          PCPR01_6()                                                               //Impressão de Lote Proibido
                          If mv_par07 == 1
                             PCPR01_7()                                                            //Operações
                          Endif
                          If Len(Alltrim(TCQ->C2_PRODUTO)) < 12 //Somente para produtos que não sejam tintas.
                             lMudaPag := .f.
                             If nLin >= nLinMax
                                AVNEWPAGE
                                nLin := 30
                                PCPR01_3(_NumOrd, _DatEmi, _QtdSol, _DesPro, _DesLin, _CodCat)
                                lMudaPag := .t.
                             Endif
                             nLin += 080
                            
                             oPrn:Say(nLin, nCol, 'LABORAT...: [ ]LIBERADO / [ ]NÃO LIBER. - RESP.:  __________________ Hr:__:__', oFont2, , , , )
                             nLin += 080
                             oPrn:Say(nLin, nCol, 'PADRÃO COR: [ ]SIM / [ ]NÃO             - RESP.:  __________________ Hr:__:__', oFont2, , , , )
                             nLin += 080
                             oPrn:Say(nLin, nCol, 'CONF.  COR: [ ]SIM / [ ]NÃO             - RESP.:  __________________ Hr:__:__', oFont2, , , , )
                             nLin += 080
                             oPrn:Say(nLin, nCol, 'PESAGEM     [ ]LIBERADA / [ ]NÃO LIBER. - RESP.:  __________________ Hr:__:__', oFont2, , , , )
                             nLin += 080
                             If Len(alltrim(TCQ->C2_PRODUTO)) < 12
								     oPrn:Say(nLin, nCol, 'BOMBEAMENTO [ ]LIBERADA / [ ]NÃO LIBER. - RESP.:  __________________ Hr:__:__', oFont2, , , , )
                             nLin += 080                                                          
							 	     oPrn:Say(nLin, nCol, 'CONFERENTE  [ ]LIBERADA / [ ]NÃO LIBER. - RESP.:  __________________ Hr:__:__', oFont2, , , , )
                             nLin += 080
                             EndIf
                             nLin += 080
                             If nLin >= nLinMax
                                AVNEWPAGE
                                nLin := 30
                                PCPR01_3(_NumOrd, _DatEmi, _QtdSol, _DesPro, _DesLin, _CodCat)
                                lMudaPag := .t.
                             Endif
                             oPrn:Say(nLin, nCol    , 'Cortar--------------------------------------------------------------------------------------------------------------------------------------------------------', oFont6, , , , )
                             nLin += 20
                             If !lMudaPag
                                nVez    := Iif(Empty(_CodCat), 11, 13)
                                cLogCor := ''
                                If substr(cNumEmp,1,2) != '05' //substr(cNumEmp,1,4) $ '0101' 
                                   _CodEan := TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN+'0'
                                Endif
                                oPrn:Line(nLin * nVez, nCol, nlin * nVez    , nColMax)
                                oPrn:Say(nLin, nCol + 700, "ORDEM DE PRODUÇÃO: "+TCQ->C2_NUM, oFont1,,,,)
                                oPrn:Say(nLin, nCol +1850, "Hora..:"+Time(), oFont4,,,,)
                                If substr(cNumEmp,1,2) != '05'  //substr(cNumEmp,1,4) $ '0101' 
                                   If Len(Alltrim(TCQ->C2_PRODUTO)) == 12
                                   		//MSBAR("EAN13",  1,  2.5 , _CodEan+EanDigito(_CodEan), oPrn, NIL, NIL, NIL, Nil, 1, NIL, NIL, NIL, .f.) 
		                                MSBAR("CODE128",  0.1,  1 , _CodEan+EanDigito(_CodEan), oPrn, NIL, NIL, NIL, Nil, 1, NIL, NIL, NIL, .f.)
        	                            //MSBar3('INT25',  0.8,  2.2 , SUBSTR(_CodEan+EanDigito(_CodEan),1,13), oPrn, .F.,    , .T., 0.025 , 0.8, .F., 'TAHOMA', 'B', .F. )
                                   Endif
                                Endif
                                nLin += 110
                                // jOSE 12/11/2024 ACRESCENTADO
                                oPrn:Say(nLin, nCol + 0030, "EMISSÃO: "                                              , oFont2, , , , )
                                oPrn:Say(nLin, nCol + 0280, DTOC(_DatEmi)                                            , oFont2, , , , )
                                // jOSE 12/11/2024 ATÉ AQUI
                                oPrn:Say(nLin   , nCol + 0750, Iif(Len(Alltrim(TCQ->C2_PRODUTO)) == 12, Transform(TCQ->C2_PRODUTO, "@R XX 99.99.999-99"), TCQ->C2_PRODUTO), oFont3, , , , )
                                oPrn:Say(nLin   , nCol + 1600, "QTDE. SOL.:"                                         , oFont2, , , , )
                                oPrn:Say(nLin   , nCol + 2000, Transform(_QtdSol, "@E 99999.99")                     , oFont3, , , , )
                                nLin += 60
                                oPrn:Say(nLin, nCol + 0030, "ENTREGA: "                                              , oFont2, , , , ) // jOSE 12/11/2024 ANTES "EMISSÃO: "
                                oPrn:Say(nLin, nCol + 0280, DTOC(_DATPRF)                                            , oFont2, , , , ) // jOSE 12/11/2024 ANTES  DTOC(_DatEmi)
                                oPrn:Say(nLin, nCol + 0750, SubStr(Alltrim(_DesPro), 1, 25)                          , oFont3, , , , )
                                oPrn:Say(nLin, nCol + 1600, SubStr(Iif(!Empty(_DesLin), Alltrim(_DesLin), ''), 1, 24), oFont2, , , , )
                                nLin += 60
                                If !Empty(_CodCat)
                                   oPrn:Say(nLin, nCol + 0030, "CATALIS.:"                                           , oFont2, , , , )
                                   oPrn:Say(nLin, nCol + 0310, _CodCat                                               , oFont2, , , , )
                                   nLin += 60
                                Endif
                                oPrn:Say(nLin, nCol + 0030, "REVISÃO: "                                              , oFont2, , , , )
                                oPrn:Say(nLin, nCol + 0280, fBusURv(TCQ->C2_PRODUTO, .f., @cLogCor)                  , oFont2, , , , )
                                oPrn:Say(nLin, nCol + 1900, "LOTE: "                                                 , oFont2, , , , )
                                oPrn:Say(nLin, nCol + 2100, TCQ->C2_LOTE                                             , oFont3, , , , )
                                oPrn:Say(nLin+70, nCol       , cLogCor                                               , oFont3, , , , )
                                nLin += 60
                                oPrn:Line(nLin, nCol      , nlin, nColMax)
                                nLin += 20
                             Endif
                             oPrn:Say(nLin, nCol, 'LABORAT...: [ ]LIBERADO / [ ]NÃO LIBER. - RESP.:  __________________ Hr:__:__', oFont2, , , , )
                             nLin += 080
                             oPrn:Say(nLin, nCol, 'PADRÃO COR: [ ]SIM / [ ]NÃO             - RESP.:  __________________ Hr:__:__', oFont2, , , , )
                             nLin += 080
                             oPrn:Say(nLin, nCol, 'CONF.  COR: [ ]SIM / [ ]NÃO             - RESP.:  __________________ Hr:__:__', oFont2, , , , )
                             nLin += 080
                             oPrn:Say(nLin, nCol, 'PESAGEM     [ ]LIBERADA / [ ]NÃO LIBER. - RESP.:  __________________ Hr:__:__', oFont2, , , , )
                             nLin += 080   
                             If Len(alltrim(TCQ->C2_PRODUTO)) < 12
								     oPrn:Say(nLin, nCol, 'BOMBEAMENTO [ ]LIBERADA / [ ]NÃO LIBER. - RESP.:  __________________ Hr:__:__', oFont2, , , , )
                             nLin += 080                                                          
							 	     oPrn:Say(nLin, nCol, 'CONFERENTE  [ ]LIBERADA / [ ]NÃO LIBER. - RESP.:  __________________ Hr:__:__', oFont2, , , , )
                             nLin += 080
                             EndIf
                          Endif
                          aInfPro := fQtdPas(TCQ->C2_PRODUTO)
                          nQtdPas := aInfPro[1]
                          cCodOut := aInfPro[2]
                          aCodOut := aInfPro[3]
                          PCPR01_8(_NumOrd, _DatEmi, _DesPro, _CodCat, _PadCor, @aRetenc, _PesEsp, nQtdPas, cCodOut, aCodOut, _ObsOrd) //Impressão das Ordens de Produção de Envase
                          If mv_par09 == 1
                             cFlagIm := ""
                             cLotPro := TCQ->C2_LOTE
                             lImpIns := .f.
                             //LGS#20200207 - Adequação de release 12.1.25 e posteriores
                             //If !(SubStr(TCQ->C2_PRODUTO, 4, 2) $ GETMV("MV_LINHAEX"))
                             If !(SubStr(TCQ->C2_PRODUTO, 4, 2) $ _cMVLINHAE )
                                //If SubStr(TCQ->C2_PRODUTO, 4, 2) $ GETMV("MV_LINHAIN")
                                If SubStr(TCQ->C2_PRODUTO, 4, 2) $ _cMVLINHAI
                                   lImpIns := .t.
                                   cFlagIm := "LINHAS DEFINIDAS PARA INSPEÇÃO"
                                ElseIf Len(Alltrim(TCQ->C2_PRODUTO)) == 12
                                       If !Empty(TCQ->C2_LOTE)
                                          cFlagIm := "ESTOQUE: "
                                          nVez    := 1
                                          DbSelectArea("SC2")
                                          DbOrderNickName("SC2001")
                                          DbSeek(xFilial("SC2")+TCQ->C2_LOTE, .t.)
                                          If Found()
                                             While !Eof() .and. SC2->C2_LOTE == TCQ->C2_LOTE
                                                   DbSelectArea("SB2")
                                                   DbSetOrder(1)
                                                   DbSeek(xFilial("SB2")+SC2->C2_PRODUTO+Posicione("SB1", 1, xFilial("SB1")+TCQ->C2_PRODUTO, "B1_LOCPAD"), .t.)
                                                   If Found()
                                                      If !Empty(SB2->B2_LOCALIZ)
                                                         If nVez == 1
                                                            cFlagIm += Alltrim(SB2->B2_LOCALIZ)
                                                            nVez += 1
                                                         Else
                                                            cFlagIm += ' / '+Alltrim(SB2->B2_LOCALIZ)
                                                         Endif
                                                         lImpIns := .t.
                                                      Endif
                                                   Endif
                                                   DbSelectArea("SC2")
                                                   DbSkip()
                                             Enddo
                                          Endif
                                       Else
                                          If !Empty(TCQ->C2_REVI)
                                             lImpIns := .t.
                                             cFlagIm := "PRODUTO SEM LOTE DE PRODUÇÃO"
                                          Endif
                                       Endif
                                ElseIf Len(Alltrim(TCQ->C2_PRODUTO)) == 4 .or. Len(Alltrim(TCQ->C2_PRODUTO)) == 5 .or. Len(Alltrim(TCQ->C2_PRODUTO)) == 6
                                       If !Empty(TCQ->C2_REVI)
                                          lImpIns := .t.
                                          cFlagIm := "PASTAS / SOLUÇÕES / CONCENTRADOS"
                                       Endif
                                Endif
                                If !lImpIns
                                   If Alltrim(TCQ->C2_UM) $ 'L'   
                                      //LGS#20200207 - Adequação de release 12.1.25 e posteriores
                                      //If TCQ->C2_QUANT >= GETMV("MV_QTDINSP")
                                      If TCQ->C2_QUANT >= _cMVQTDINS
                                         lImpIns := .t.
                                         //cFlagIm := "QUANTIDADE MAIOR OU IGUAL A "+TransForm(GETMV("MV_QTDINSP"), "@E 9999")
                                         cFlagIm := "QUANTIDADE MAIOR OU IGUAL A "+TransForm( _cMVQTDINS, "@E 9999")
                                      Endif
                                   Elseif Alltrim(TCQ->C2_UM) $ 'KG'
                                   	  //If TCQ->C2_QUANT >= GETMV("MV_QTDINSP")
                                   	  If TCQ->C2_QUANT >= _cMVQTDINS
                                   	  	 lImpIns := .t.
                                   	  	 //cFlagIm := "QUANTIDADE MAIOR OU IGUAL A "+TransForm(GETMV("MV_QTDINSP"), "@E 9999")
                                   	  	 cFlagIm := "QUANTIDADE MAIOR OU IGUAL A "+TransForm( _cMVQTDINS, "@E 9999")
                                   	  Endif
                                   Endif	  		
                               Endif
                               /* Else
                                   If Alltrim(TCQ->C2_UM) $ 'L'
                                      If TCQ->C2_QUANT >= GETMV("MV_QTDINSP")
                                         lImpIns := .t.
                                         cFlagIm := "QUANTIDADE MAIOR OU IGUAL A "+TransForm(GETMV("MV_QTDINSP"), "@E 9999")
                                      Else
                                         lImpIns := .f.
                                      Endif
                                   Elseif Alltrim(TCQ->C2_UM) $ 'KG'
                                   	  If TCQ->C2_QUANT >= GETMV("MV_QTDINSP")
                                   	  	 lImpIns := .t.
                                   	  	 cFlagIm := "QUANTIDADE MAIOR OU IGUAL A "+TransForm(GETMV("MV_QTDINSP"), "@E 9999")
                                   	  Else
                                   	  	 lImpIns := .f.
                                   	  Endif
                                   Endif
                                Endif */
                             Endif
                             If lImpIns
                                PCPR01_A(cFlagIm, cLotPro, _DatEmi, _CodCat, _QtdSol, _DesPro, _DesLin, aRetenc, cCodOut, aCodOut)
                             EndIf
                          Endif
                          // MARCAR OP COMO JÁ IMPRESSA (NÃO PERMITIR A IMPRESSÃO DE OPS QUE JÁ FORAM IMPRESSAS- solicitado por Thiago Diniz)
                          IF xFilial("SC2") == "010101"
                          	DbSelectArea("SC2")
                          	DbSetOrder(1)
                          	DbSeek(xFilial("SC2")+_NumOrd,.t.)
                          	If Found()
                          		RecLock("SC2",.f.)
            	                SC2->C2_XFLAG := "S"
            	                MsUnLock()  
            	            Endif  
            	          ENDIF                         

                          DbSelectArea("TCQ")
                          IncProc()
                          DbSkip() 
                    EndDo
               AVENDPAGE
       AVENDPRINT
Return

/**********************************************************************************************************/
/*** PCPR01_A - Monta cabeçalho da Inspeção de Processo.                                                ***/
/**********************************************************************************************************/
Static Function PCPR01_A(cFlagIm, cLotPro, _DatEmi, _CodCat, _QtdSol, _DesPro, _DesLin, aRetenc, cCodOut, aCodOut)
       Local cQry    := ""
       Local aEnsaio := {}
       Local aOperac := {}
       Local nZ, nY
       
       cQry += "SELECT QP6.QP6_PRODUT PRODUT, QP6.QP6_REVI REVI    , QP6.QP6_FATCO1 FATCO1, QP6.QP6_TIPCO1 TIPCO1 , "
       cQry += "       QP6.QP6_FATCO2 FATCO2, QP6.QP6_TIPCO2 TIPCO2, QP6.QP6_DESCPO DESCPO, QP6.QP6_DTCAD DTCAD   , "
       cQry += "       QP6.QP6_DTDES DTDES  , QP6.QP6_RVDES RVDES  , QP6.QP6_DTINI DTINI   , QP6.QP6_DOCOBR DOCOBR, "
       cQry += "       QP6.QP6_UNMED1 UNMED1, QP6.QP6_UNMED2 UNMED2 "
       cQry += "FROM "+RetSqlName("QP6")+" QP6 WITH (NOLOCK) "
       cQry += "WHERE QP6.QP6_FILIAL = '"+xFilial("QP6")+"' "
       cQry += "  AND QP6.D_E_L_E_T_ = '' "
       cQry += "  AND QP6.QP6_PRODUT = '"+TCQ->C2_PRODUTO+"' "
       cQry += "  AND QP6.QP6_REVI   = '"+TCQ->C2_REVI+"' "
       cQry += "  AND QP6.QP6_CODREC = '"+TCQ->C2_ROTEIRO+"' "
       TCQuery cQry ALIAS "TESP" NEW
       DbSelectArea("TESP")
       
       cQry := ""
       cQry += "SELECT QP7.QP7_CODREC CODREC, QP7.QP7_OPERAC OPERAC, QP7.QP7_LABOR LABOR  , QP7.QP7_SEQLAB SEQLAB, "
       cQry += "       QP7.QP7_ENSAIO ENSAIO, QP7.QP7_ENSOBR ENSOBR, QP7.QP7_UNIMED UNIMED, QP7.QP7_NOMINA NOMINA, "
       cQry += "       QP7.QP7_LIE LIE      , QP7.QP7_NIVEL STATUS , QP7.QP7_LSE LSE      , QP7.QP7_PLAMO PLAMO  , "
       cQry += "       QP7.QP7_DESPLA DESPLA, QP7.QP7_MINMAX MINMAX "
       cQry += "FROM "+RetSqlName("QP7")+" QP7 WITH (NOLOCK) "
       cQry += "WHERE QP7.QP7_FILIAL = '"+xFilial("QP7")+"' "
       cQry += "  AND QP7.D_E_L_E_T_ = '' "
       cQry += "  AND QP7.QP7_PRODUT = '"+TESP->PRODUT+"' "
       cQry += "  AND QP7.QP7_REVI   = '"+TESP->REVI+"' "
       cQry += "  AND QP7.QP7_CODREC = '"+TCQ->C2_ROTEIRO+"' "
       cQry += "ORDER BY QP7.QP7_SEQLAB "
       TCQuery cQry ALIAS "TENS" NEW
       DbSelectArea("TENS")
       DbGoTop()
       While !Eof()
             cTipEns := Posicione("QP1", 1, xFilial("QP1")+TENS->ENSAIO, "QP1_TPCART")
             cDesEns := Posicione("QP1", 1, xFilial("QP1")+TENS->ENSAIO, "QP1_DESCPO")
             If aScan(aOperac, TENS->OPERAC) == 0
                aadd(aOperac, TENS->OPERAC)
             Endif
             If cTipEns == "X"
                //Nessa query não tem ensaio do tipo X (TXT) Fiz somente para manter a lógica
             Else
                If TENS->MINMAX $ '1'
                   aadd(aEnsaio, {TENS->OPERAC, TENS-> SEQLAB, cTipEns, TENS->ENSAIO, cDesEns, TENS->UNIMED, TENS->LIE, TENS->NOMINA, TENS->LSE, '', TENS->ENSOBR })
                ElseIf TENS->MINMAX $ '2'
                   aadd(aEnsaio, {TENS->OPERAC, TENS-> SEQLAB, cTipEns, TENS->ENSAIO, cDesEns, TENS->UNIMED, TENS->LIE, TENS->NOMINA, '>>>'    , '', TENS->ENSOBR })
                Else
                   aadd(aEnsaio, {TENS->OPERAC, TENS-> SEQLAB, cTipEns, TENS->ENSAIO, cDesEns, TENS->UNIMED, '<<<'    , TENS->NOMINA, TENS->LSE, '', TENS->ENSOBR })
                Endif
             Endif
             DbSelectArea("TENS")
             DbSkip()
       Enddo
       DbSelectArea("TENS")
       DbCloseArea()

       cQry := ""
       cQry += "SELECT QP8.QP8_CODREC CODREC, QP8.QP8_OPERAC OPERAC, QP8.QP8_LABOR LABOR, QP8.QP8_SEQLAB SEQLAB, "
       cQry += "       QP8.QP8_ENSAIO ENSAIO, QP8.QP8_ENSOBR ENSOBR, QP8.QP8_TEXTO TEXTO, QP8.QP8_PLAMO PLAMO  , "
       cQry += "       QP8.QP8_DESPLA DESPLA, QP8.QP8_NIVEL STATUS "
       cQry += "FROM "+RetSqlName("QP8")+" QP8 WITH (NOLOCK) "
       cQry += "WHERE QP8.QP8_FILIAL = '"+xFilial("QP8")+"' "
       cQry += "  AND QP8.D_E_L_E_T_ = '' "
       cQry += "  AND QP8.QP8_PRODUT = '"+TESP->PRODUT+"' "
       cQry += "  AND QP8.QP8_REVI   = '"+TESP->REVI+"' "
       cQry += "  AND QP8.QP8_CODREC = '"+TCQ->C2_ROTEIRO+"' "
       cQry += "ORDER BY QP8.QP8_SEQLAB "
       TCQuery cQry ALIAS "TENS" NEW
       DbSelectArea("TENS")
       DbGoTop()
       While !Eof()
             cTipEns := Posicione("QP1", 1, xFilial("QP1")+TENS->ENSAIO, "QP1_TPCART")
             cDesEns := Posicione("QP1", 1, xFilial("QP1")+TENS->ENSAIO, "QP1_DESCPO")
             If aScan(aOperac, TENS->OPERAC) == 0
                aadd(aOperac, TENS->OPERAC)
             Endif
             If cTipEns == "X"
                aadd(aEnsaio, {TENS->OPERAC, TENS-> SEQLAB, cTipEns, TENS->ENSAIO, cDesEns, '', '', '', '', TENS->TEXTO, TENS->ENSOBR })
             Else
                //Nessa query não tem ensaios do tipo diferente de X (TXT) Fiz somente para manter a lógica
             Endif
             DbSelectArea("TENS")
             DbSkip()
       Enddo
       DbSelectArea("TENS")
       DbCloseArea()
       aSort(aOperac)
       aSort(aEnsaio,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
       
       If Len(aEnsaio) > 0
          PCPR01_B(_CodCat, _DatEmi, _QtdSol, _DesPro, _DesLin, cFlagIm, aRetenc, cCodOut, aCodOut)
          For nY := 1 To Len(aOperac)
              oPrn:Say(nLin, nCol, "OPERAÇÃO ==> "+aOperac[nY]+' - '+Posicione("SG2", 1, xFilial("SG2")+TCQ->C2_PRODUTO+TCQ->C2_ROTEIRO+aOperac[nY], "G2_DESCRI"), oFont2, , , , )
              nLin += 70
              oPrn:Line(nLin, nCol, nLin, nColMax)
              oPrn:Say(nLin, nCol+0050, "ENSAIO", oFont2, , , , )
              oPrn:Say(nLin, nCol+1450, "UM", oFont2, , , , )
              oPrn:Say(nLin, nCol+1560, 'NOMINAL ', oFont2, , , , )
              oPrn:Say(nLin, nCol+1820, ' L.I.E. ', oFont2, , , , )
              oPrn:Say(nLin, nCol+2080, ' L.S.E. ', oFont2, , , , )
              nLin += 60
              oPrn:Line(nLin, nCol, nLin, nColMax)
              If nLin >= nLinMax
                 nLin := 30
                 PCPR01_B(_CodCat, _DatEmi, _QtdSol, _DesPro, _DesLin, cFlagIm, aRetenc, cCodOut, aCodOut)
              Endif
              For nZ := 1 To Len(aEnsaio)
                  If aOperac[nY] == aEnsaio[nZ][1]
                     nLin += 20
                     oPrn:Say(nLin, nCol     , Iif(aEnsaio[nZ][11] == 'S', '*', ' '), oFont2, , , , )
                     oPrn:Say(nLin, nCol+0050, aEnsaio[nZ][04]                      , oFont2, , , , )
                     oPrn:Say(nLin, nCol+0320, SubStr(aEnsaio[nZ][05] , 1, 37)      , oFont2, , , , )
                     If !aEnsaio[nZ][03] $ 'X'
                        oPrn:Say(nLin, nCol+1450, aEnsaio[nZ][06]                      , oFont2, , , , )
                        oPrn:Say(nLin, nCol+1560, aEnsaio[nZ][08]                      , oFont2, , , , )
                        oPrn:Say(nLin, nCol+1820, aEnsaio[nZ][07]                      , oFont2, , , , )
                        oPrn:Say(nLin, nCol+2080, aEnsaio[nZ][09]                      , oFont2, , , , )
                     Else
                        cText1 := SubStr(Alltrim(aEnsaio[nZ][10]), 01, 28)
                        cText2 := SubStr(Alltrim(aEnsaio[nZ][10]), 29, 28)
                        cText3 := SubStr(Alltrim(aEnsaio[nZ][10]), 57, 28)
                        cText4 := SubStr(Alltrim(aEnsaio[nZ][10]), 85, 28)
                        If !Empty(cText1)
                           oPrn:Say(nLin, nCol+1450, cText1                      , oFont2, , , , )
                        Endif
                        If !Empty(cText2)
                           nLin += 60
                           oPrn:Say(nLin, nCol+1450, cText2                      , oFont2, , , , )
                        Endif
                        If !Empty(cText3)
                           nLin += 60
                           oPrn:Say(nLin, nCol+1450, cText3                      , oFont2, , , , )
                        Endif
                        If !Empty(cText4)
                           nLin += 60
                           oPrn:Say(nLin, nCol+1450, cText4                      , oFont2, , , , )
                        Endif
                     Endif
                     nLin += 80
                     oPrn:Line(nLin, nCol, nLin, nColMax)
                     If nLin >= nLinMax
                        nLin := 30
                        PCPR01_B(_CodCat, _DatEmi, _QtdSol, _DesPro, _DesLin, cFlagIm, aRetenc, cCodOut, aCodOut)
                     Endif
                  Endif
              Next
              nLin += 100
              If nLin >= nLinMax
                 nLin := 30
                 PCPR01_B(_CodCat, _DatEmi, _QtdSol, _DesPro, _DesLin, cFlagIm, aRetenc, cCodOut, aCodOut)
              Endif
              oPrn:Say(nLin, nCol, '+----------+-------------+---------------------------------------------------+', oFont2, , , , )
              nLin += 60
              oPrn:Say(nLin, nCol, '|  ENSAIO  |  ENSAIADOR  |                  M E D I Ç Õ E S                  |', oFont2, , , , )
              nLin += 60
              oPrn:Say(nLin, nCol, '+----------+-------------+---------+----------+---------+----------+---------+', oFont2, , , , )
              nLin += 60
              For nZ := 1 To Len(aEnsaio)
                  If aOperac[nY] == aEnsaio[nZ][1]
                     If !aEnsaio[nZ][03] $ 'X'
                        oPrn:Say(nLin, nCol, '| '+aEnsaio[nZ][04]+' |             |         |          |         |          |         |', oFont2, , , , )
                     Else
                        oPrn:Say(nLin, nCol, '| '+aEnsaio[nZ][04]+' |             |                                                   |', oFont2, , , , )
                     Endif
                     nLin += 60
                     oPrn:Say(nLin, nCol, '+----------+-------------+---------+----------+---------+----------+---------+', oFont2, , , , )
                     nLin += 60
                  Endif
                  If nLin >= nLinMax
                     nLin := 30
                     PCPR01_B(_CodCat, _DatEmi, _QtdSol, _DesPro, _DesLin, cFlagIm, aRetenc, cCodOut, aCodOut)
                  Endif
              Next
              nLin += 60
              oPrn:Say(nLin, nCol, 'Laudo: ____________________________          Data: ____ / ____ / ____          ', oFont2, , , , )
              nLin += 120
          Next 
       Endif
       
       DbSelectArea("TESP")
       DbCloseArea()
Return

/**********************************************************************************************************/
/*** PCPR01_B - Monta cabeçalho da Inspeção de Processo.                                                ***/
/**********************************************************************************************************/
Static Function PCPR01_B(_CodCat, _DatEmi, _QtdSol, _DesPro, _DesLin, cFlagIm, aRetenc, cCodOut, aCodOut)
       Local _nY
       Local nVez := Iif(Empty(_CodCat), 11, 13)
       AVNEWPAGE
         nLin := 30
         oPrn:Box(nLin, nCol      , nlin * nVez    , nColMax)
         _DatIni := SubStr(TESP->DTINI, 7, 2)+'/'+SubStr(TESP->DTINI, 5, 2)+'/'+SubStr(TESP->DTINI, 1, 4)
 		   _CodEan := TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN+'0' //Iif(cNumEmp $ '0104' .and. SubStr(TCQ->C2_NUM, 1, 1) < '1', '1'+SubStr(TCQ->C2_NUM, 2, 5)+TCQ->C2_ITEM+TCQ->C2_SEQUEN+'0', TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN+'0')
         oPrn:Say(nLin, nCol + 800, "FICHA DE INSPEÇÃO", oFont1,,,,)
		 If substr(cNumEmp,1,2) != '05' // substr(cNumEmp,1,4) $ '0101'
          //MSBAR ("EAN13",  1,  2.5 , _CodEan+EanDigito(_CodEan), oPrn, NIL, NIL, NIL,    Nil, 1, NIL, NIL, NIL, .f.)
         //	MSBar3('INT25',  0.7,  1.2 , SUBSTR(_CodEan+EanDigito(_CodEan),1,13), oPrn, .F.,    , .T., 0.025 , 0.8, .F., 'TAHOMA', 'B', .F. )
            MSBAR("CODE128",  0.4, 0.3 , _CodEan+EanDigito(_CodEan), oPrn, NIL, NIL, NIL, Nil, 1, NIL, NIL, NIL, .f.)
         Else                // 0.1, 0.4
            //MSBAR("CODE128",  1,  2.5 , _CodEan, oPrn, NIL, NIL, NIL, Nil, 1, NIL, NIL, NIL, .f.)
         Endif
         nLin += 50
         oPrn:Say(nLin, nCol + 1600, "EMISSÃO...:"                                            , oFont2, , , , )
         oPrn:Say(nLin, nCol + 2000, DTOC(_DatEmi)                                            , oFont2, , , , )
         nLin += 60
         oPrn:Say(nLin   , nCol + 0580, Iif(Len(Alltrim(TCQ->C2_PRODUTO)) == 12, Transform(TCQ->C2_PRODUTO, "@R XX 99.99.999-99"), TCQ->C2_PRODUTO)+' - '+TCQ->C2_REVI+' - '+_DatIni , oFont3, , , , )
         oPrn:Say(nLin   , nCol + 1600, "QTDE. SOL.:"                                           , oFont2, , , , )
         oPrn:Say(nLin   , nCol + 2000, Transform(_QtdSol, "@E 99999.99")                       , oFont3, , , , )
         nLin += 60
         oPrn:Say(nLin, nCol + 0030, "O.P.: "+TCQ->C2_NUM                                     , oFont2, , , , )
         oPrn:Say(nLin, nCol + 0580, SubStr(Alltrim(_DesPro), 1, 25)                          , oFont3, , , , )
         oPrn:Say(nLin, nCol + 1600, SubStr(Iif(!Empty(_DesLin), Alltrim(_DesLin), ''), 1, 24), oFont2, , , , )
         nLin += 60
         If !Empty(_CodCat)
            oPrn:Say(nLin, nCol + 0030, "CATALIS.:"                                           , oFont2, , , , )
            oPrn:Say(nLin, nCol + 0310, _CodCat                                               , oFont2, , , , )
            nLin += 60
         Endif
         oPrn:Say(nLin, nCol + 0030, "REV.FOR: "                                              , oFont2, , , , )
         oPrn:Say(nLin, nCol + 0280, fBusURv(TCQ->C2_PRODUTO, .t.)                            , oFont2, , , , )
         oPrn:Say(nLin, nCol + 1600, "LOTE......: "                                           , oFont2, , , , )
         oPrn:Say(nLin, nCol + 2000, TCQ->C2_LOTE                                             , oFont3, , , , )
         nLin += 100
         oPrn:Say(nLin, nCol, "MOTIVO DA IMPRESSÃO: "+cFlagIm                                           , oFont2, , , , )
         If Len(aRetenc) > 0
            If aRetenc[1][7] > 0.00
               nLin += 60
               oPrn:Say(nLin, nCol     , "CONCENTRADO........: "+TransForm(Round(aRetenc[1][7], 3), "@E 99.999")   , oFont2, , , , )
               cAuxOut := ""
               For _nY := 1 To Len(aCodOut)
                   cAuxOut += Alltrim(aCodOut[1][1])+': '+TransForm(Round(aCodOut[_nY][3], 3), "@E 99.999")+' / '
               Next
               cAuxOut := SubStr(cAuxOut, 1, Len(cAuxOut)-3)
               oPrn:Say(nLin, nCol+1000, "OUTROS: "+cAuxOut                                                        , oFont2, , , , )
               //oPrn:Say(nLin, nCol+1400, "OUTROS: "+cCodOut                                                        , oFont2, , , , )
            Endif
         Endif
         nLin += 80
         oPrn:Say(nLin, nCol, "ROTEIRO  ==> "+TCQ->C2_ROTEIRO                                   , oFont2, , , , )
         nLin += 60
Return

/**********************************************************************************************************/
/*** PCPR01_9 - Monta cabeçalho da Ordem de Produção - Envase                                           ***/
/**********************************************************************************************************/
Static Function PCPR01_9(nOpc, _NumOrd, _DatEmi, _DesPro, _CodCat, _PadCor)
       Local lCodCat := .f.
       Local lPadCor := .f.
       _CodEan := TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN+'0' //Iif(cNumEmp $ '0104' .and. SubStr(TCQ->C2_NUM, 1, 1) < '1', '1'+SubStr(TCQ->C2_NUM, 2, 5)+TCQ->C2_ITEM+TCQ->C2_SEQUEN+'0', TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN+'0') //TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN+'0'
       
       If nOpc == 1
          AVNEWPAGE
          oPrn:Say(nLin, nCol + 0900, "CONTROLE ", oFont1,,,,)
          oPrn:Say(nLin, nCol +1850, "Hora..:"+Time(), oFont4,,,,)
			If substr(cNumEmp,1,2) != "05" //substr(cNumEmp,1,4) $ '0101'
	          MSBAR("CODE128",  nCmt-1.25, 1 , _CodEan+EanDigito(_CodEan), oPrn, NIL, NIL, NIL, Nil, 1, NIL, NIL, NIL, .f.)  
 	  		Endif
       Endif
       nLin += 60
       nCmt += 0.5
       oPrn:Say(nLin, nCol + 1800, "LOTE: "                                              , oFont2, , , , )
       oPrn:Say(nLin, nCol + 2050, TCQ->C2_LOTE                                          , oFont3, , , , )
       If nOpc == 1
          oPrn:Say(nLin   , nCol + 0750, Transform(TCQ->C2_PRODUTO, "@R XX 99.99.999-99"), oFont3, , , , )
          nLin += 10
          
          nLin += 50
          oPrn:Say(nLin   , nCol + 0750, SubStr(Alltrim(_DesPro), 1, 30)                 , oFont3, , , , )
       Else
          oPrn:Say(nLin, nCol + 0900, "CONTROLE ", oFont1,,,,)
          nLin += 90
          nCmt += 0.25
          // Jose 12/11/2024 acrescentado
          oPrn:Say(nLin   , nCol + 1800, "EMISSÃO:"                                        , oFont2, , , , ) // Jose 12/11/2024 nCol + 1800, 
          oPrn:Say(nLin   , nCol + 2050, DTOC(_DatEmi)                                     , oFont2, , , , )
          // Jose 12/11/2024  até aqui
          oPrn:Say(nLin, nCol + 0750, Transform(TCQ->C2_PRODUTO, "@R XX 99.99.999-99")  , oFont3, , , , )
          oPrn:Say(nLin, nCol + 1400, "Hora..:"+Time(), oFont4,,,,) // Jose 12/11/2024 nCol + 1850,
          nLin += 60
          oPrn:Say(nLin   , nCol + 0750, SubStr(Alltrim(_DesPro), 1, 25)                   , oFont3, , , , )
       Endif
       oPrn:Say(nLin   , nCol + 1800, "ENTREGA:"                                        , oFont2, , , , ) // Jose 12/11/2024 "EMISSÃO:"  
       oPrn:Say(nLin   , nCol + 2050, DTOC(_DATPRF)                                     , oFont2, , , , ) // Jose 12/11/2024 DTOC(_DatEmi) 
       If nOpc == 2
          oPrn:Say(nLin, nCol + 0200, 'O.P.: '+SubStr(_NumOrd, 1, 6), oFont4, , , , )
       Endif
       If !Empty(_CodCat)
          If nOpc == 1
             nLin += 60
             oPrn:Say(nLin, nCol + 0750, "CATALIS.:"                                       , oFont2, , , , )
             oPrn:Say(nLin, nCol + 1030, _CodCat                                           , oFont2, , , , )
             nCmt += 0.25
          Else
             nLin += 60
             oPrn:Say(nLin, nCol + 0750, "CATALIS.:"                                       , oFont2, , , , )
             oPrn:Say(nLin, nCol + 1030, _CodCat                                           , oFont2, , , , )
             nCmt += 0.5
          Endif
          lCodCat := .t.
       Else
          nCmt += 0.25
       Endif
       If !Empty(_PadCor)
          If nOpc == 1
             nLin += 60
             oPrn:Say(nLin, nCol + 0750, "PADR. COR:"                                      , oFont2, , , , )
             oPrn:Say(nLin, nCol + 1070, _PadCor                                           , oFont2, , , , )
             lPadCor := .t.
             nCmt += 0.5
          Else
             nCmt += 0.5
          Endif
       Else
          If nOpc == 1
		      nLin += 60       
          Endif
          nCmt += 0.5
	   Endif	
       nLin += 60
       oPrn:Line(nLin, nCol      , nlin, nColMax)
       oPrn:Say(nLin, nCol + 0030, "EMBALAGEM     R.VOL    DESCRICAO EMBALAGEM      QTD.EMBAL ESTOQUE.   NUM.OP", oFont2, , , , )
//     oPrn:Say(nLin, nCol + 0030, "   EMBALAGEM        DESCRICAO EMBALAGEM        QTDE. EMBAL  LOCALIZ.   NUM.OP", oFont2, , , , )
       nLin += 60
       oPrn:Line(nLin, nCol      , nlin, nColMax)
       nCmt += 0.5
       If nOpc == 2
          If lCodCat .or. lPadCor
             nCmt += 0.5
          Endif
          If substr(cNumEmp,1,2) != '05'//substr(cNumEmp,1,4) $ '0101'
             MSBAR("CODE128",  nCmt-2.2, 1, _CodEan+EanDigito(_CodEan), oPrn, NIL, NIL, NIL, Nil, 1, NIL, NIL, NIL, .f.) 
                            //     -2.7
          Else
             //MSBAR("CODE128",  1,  2.5 , _CodEan, oPrn, NIL, NIL, NIL, Nil, 1, NIL, NIL, NIL, .f.)
          Endif

       Endif
       nLin += 30
Return

/**********************************************************************************************************/
/*** PCPR01_8 - Monta impressão das Ordens de produção do envase.                                       ***/
/**********************************************************************************************************/
Static Function PCPR01_8(_NumOrd, _DatEmi, _DesPro, _CodCat, _PadCor, aRetenc, _PesEsp, nQtdPas, cCodOut, aCodOut, _ObsOrd)
       Local cQry1   := ""
       Local aEmbala := {}
       Local aEmbal  := {}
       Local nAEmbal := 0
       Local nPesPadr:= 0 

       Local nIndex  :=0 // Jose 23/04/2025
     //Local cGrpEmb := ""
     //Local cAuxGrp := ""
       Local nPos    := 0
     //Local lAchou := .f.
       Local nZ, nY, nX
       Local cGrpEmb := Alltrim(GETMV("MV_GRPEMB"))
       Local _cMVGRTAMP := GETMV("MV_GRTAMPA") //LGS#20200207 - Adequação de release 12.1.25 e posteriores
/*     While Len(cGrpEmb) > 0
             cAuxGrp += SubStr(cGrpEmb, 1, 4)+"."
             If SubStr(cGrpEmb, 5, 1) $ '.'
                cGrpEmb := SubStr(cGrpEmb, 6, Len(cGrpEmb))
             Else
                cGrpEmb := ""
             Endif
       Enddo
       
       If Len(cAuxGrp) <= 0
          MsgStop("Não existe grupo no parâmetro: MV_GRPEMB")
          Return
       Else
          cGrpEmb := cAuxGrp
          cGrpEmb := SubStr(cGrpEmb, 1, Len(cGrpEmb)-1)
       Endif
*/       
       If Len(cGrpEmb) <= 0
          MsgStop("Não existe grupo no parâmetro: MV_GRPEMB")
          Return
       endif 

       nLin := 30
       nCol := 30
       If !Empty(TCQ->C2_LOTE) .and. Len(Alltrim(TCQ->C2_PRODUTO)) == 12
          cQry1 += "SELECT C2_FILIAL,C2_PRODUTO,C2_QUANT,C2_NUM,C2_ITEM,C2_SEQUEN,C2_PEDIDO,C2_LOTE, C2_ITEMPV,B1_ESTOQUE ESTOQUE "
          cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "

          /* incluido por nelieder em 14/07/2022 */
          cQry1 += "INNER JOIN "+RetSqlName("SB1")+" B1 WITH (NOLOCK) ON B1_COD = C2_PRODUTO AND B1_FILIAL = C2_FILIAL AND B1.D_E_L_E_T_ = '' "

          cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
          cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
          cQry1 += "  AND SC2.C2_LOTE    = '"+TCQ->C2_LOTE+"' "
          cQry1 += "  AND SUBSTRING(SC2.C2_PRODUTO, 11, 2) NOT IN('00','99') "
          cQry1 += "ORDER BY SUBSTRING(SC2.C2_PRODUTO, 11, 2) "
          TCQuery cQry1 ALIAS "TENV" NEW
          DbSelectArea("TENV")
          DbGoTop()
          While !Eof()
       
                DbSelectArea("SG1")
                DbSetOrder(1)
                DbSeek(xFilial("SG1")+TENV->C2_PRODUTO, .t.)
                If Found()
                   While !Eof() .and. (SG1->G1_FILIAL == TENV->C2_FILIAL) .and. (SG1->G1_COD == TENV->C2_PRODUTO)
                   		dbselectarea("SB1")
                   		dbsetorder(1)
                   		dbseek(xFilial("SB1")+SG1->G1_COMP,.f.)
                   		If found()
                                    	If Len(Alltrim(SG1->G1_COMP)) == 4 .OR. Len(Alltrim(SG1->G1_COMP)) == 5
                            	If Alltrim(SB1->B1_GRUPO) $ cGrpEmb //Alltrim(SG1->G1_COMP) >= '0500' .and. Alltrim(SG1->G1_COMP) <= '0599'
                               		aadd(aEmbal , {SG1->G1_COMP, SB1->B1_DESC, SubStr(TENV->C2_PRODUTO, 11, 2), ((Posicione("SZ5", 1, xFilial("SZ5")+SubStr(TENV->C2_PRODUTO, 11, 2), "Z5_VOLUME") * nQtdPas) * _PesEsp) })
                                    aadd(aEmbala, { SubStr(TENV->C2_PRODUTO, 11, 2), SG1->G1_COMP, SB1->B1_DESC, SG1->G1_QUANT, TENV->C2_QUANT, SG1->G1_QUANT*TENV->C2_QUANT,'', ' ', 2, TENV->C2_PRODUTO, TENV->C2_NUM+TENV->C2_ITEM+TENV->C2_SEQUEN, SubStr(TENV->C2_PRODUTO, 11, 2), '', '',TENV->ESTOQUE })
                            	Else
                               		If !(Alltrim(SB1->B1_GRUPO) $ 'E400')
//                                		aadd(aEmbala, { '  ', SG1->G1_COMP, iif((cNumEmp = "01010101") .AND. (SUBSTR(SB1->B1_GRUPO,1,1) != "E"),"",SB1->B1_DESC), SG1->G1_QUANT, TENV->C2_QUANT, SG1->G1_QUANT*TENV->C2_QUANT, '', ' ', 2, TENV->C2_PRODUTO, TENV->C2_NUM+TENV->C2_ITEM+TENV->C2_SEQUEN, SubStr(TENV->C2_PRODUTO, 11, 2), '', '',TENV->ESTOQUE }) // Jose 22/04/2025
                                  		aadd(aEmbala, { ' ', SG1->G1_COMP, iif((cNumEmp = "01010101") .AND. (SUBSTR(SB1->B1_GRUPO,1,1) != "E"),"",SB1->B1_DESC), SG1->G1_QUANT, TENV->C2_QUANT, SG1->G1_QUANT*TENV->C2_QUANT, '', ' ', 2, TENV->C2_PRODUTO, TENV->C2_NUM+TENV->C2_ITEM+TENV->C2_SEQUEN, SubStr(TENV->C2_PRODUTO, 11, 2), '', '',TENV->ESTOQUE }) // 22/04/2025
                              	 	Endif
                           	Endif
                         	Endif           
                     	endif 
                      	DbSelectArea("SG1")
                       	DbSkip()
                   Enddo
                   If !Empty(TENV->C2_PEDIDO)
                      aadd(aEmbala, { '', '', '', '', '', '', '', '', 3, ' ', ' ', ' ', TENV->C2_PEDIDO, TENV->C2_ITEMPV })
                   Else
                      cQry1 := ""
                      cQry1 += "SELECT SC6.C6_NUM, SC6.C6_ITEM, SC6.C6_PRODUTO, SC6.C6_CLI "
                      cQry1 += "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
                      cQry1 += "WHERE SC6.C6_FILIAL  = '"+xFilial("SC6")+"' "
                      cQry1 += "  AND SC6.D_E_L_E_T_ = '' "
                      cQry1 += "  AND SC6.C6_PRODUTO = '"+TENV->C2_PRODUTO+"' "
                      cQry1 += "  AND SC6.C6_NUMLOTE = '"+TCQ->C2_LOTE+"' "
                      TCQuery cQry1 ALIAS "TSC6" NEW
                      DbSelectArea("TSC6")
                      While !Eof()
                            aadd(aEmbala, { '', '', '', '', '', '', '', '', 3, ' ', ' ', ' ', TSC6->C6_NUM, TSC6->C6_ITEM })
                            DbSelectArea("TSC6")
                            DbSkip()
                      Enddo
                      DbSelectArea("TSC6")
                      DbCloseArea()
                   Endif
                   aadd(aEmbala, { '', '', '', '', '', '', '', '', 1, ' ', ' ', ' ', ' ', ' ' })
                Endif
                DbSelectArea("TENV")
                DbSkip()
          Enddo
          DbSelectArea("TENV")
          DbCloseArea()
          nPos := 0
          For nY := 1 To Len(aEmbala)
              For nZ := 1 To Len(aEmbala)
                  If aEmbala[nZ][12] == aEmbala[nY][1]
                     nPos := nZ
                  Endif
              Next
              If nPos <> 0
                aEmbala[nPos][7] := Posicione("SB2", 1, xFilial("SB2")+aEmbala[nPos][10]+Posicione("SB1",1,xFilial("SB1")+aEmbala[nPos][10],"B1_LOCPAD"), "B2_LOCALIZ")
                aEmbala[nPos][8] := Posicione("SC2", 6, xFilial("SC2")+aEmbala[nPos][11]+aEmbala[nPos][10], "C2_NUM")
              Endif
              nPos := 0
          Next
          aSort(aRetenc,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
          For nY := 1 To Len(aRetenc)
              If nY > 1
                 aadd(aEmbala, { '', '', '', '', '', '', '', '', 1, ' ', ' ', ' ', ' ', ' ' })
              Endif
              aadd(aEmbala, { aRetenc[nY][1], aRetenc[nY][2], aRetenc[nY][5], aRetenc[nY][4], aRetenc[nY][4], aRetenc[nY][4], ' ', '-', 1, ' ' })
              aadd(aEmbal , { aRetenc[nY][2], aRetenc[nY][5], aRetenc[nY][1], ((Posicione("SZ5", 1, xFilial("SZ5")+aRetenc[nY][1], "Z5_VOLUME") * nQtdPas) * _PesEsp) })
              aRetenc[nY][7] := ((Posicione("SZ5", 1, xFilial("SZ5")+aRetenc[nY][1], "Z5_VOLUME") * nQtdPas) * _PesEsp)
              For nX := 1 To Len(aCodOut)
                  aCodOut[nX][3] := Posicione("SZ5", 1, xFilial("SZ5")+aRetenc[nY][1], "Z5_VOLUME") * ( aCodOut[nX][2] / 100 ) * _PesEsp
              Next
          Next
          For nY := 1 To 2
              If nY == 1
                 PCPR01_9(1, _NumOrd, _DatEmi, _DesPro, _CodCat, _PadCor)
              Else
                 cMsgPDC := fBusPDC()
                 oPrn:Say(nLin, nCol, '*******************************************************************************', oFont2, , , , )
                 nLin += 50
                 oPrn:Say(nLin, nCol, cMsgPDC, oFont2, , , , )
                 nLin += 50
                 oPrn:Say(nLin, nCol, '*******************************************************************************', oFont2, , , , )
 		  		  // ALTERAÇÃO ATENDENDO PLANO DE AÇÃO 00000000013/2011        em 06-12-11
                 nLin += 080
                 oPrn:Say(nLin, nCol, 'LIBERADO P/ ENVASE: [ ]SIM / [ ]NÃO     - RESP.:  __________________ Hr:__:__', oFont2, , , , )
                 nLin += 080                                                                
                 If !Empty(_ObsOrd)
                    oPrn:Say(nLin, nCol, UPPER(_ObsOrd), oFont3, , , , )
                    nLin += 070
                 Endif
                 nCmt += 2.0

                 oPrn:Say(nLin, nCol    , 'Cortar--------------------------------------------------------------------------------------------------------------------------------------------------------', oFont6, , , , )
                 nLin += 50
                 nCmt += 0.5
                 PCPR01_9(2, _NumOrd, _DatEmi, _DesPro, _CodCat, _PadCor)
              Endif
              
//            nIndex := 0 // Jose 23/04/2025

              For nZ := 1 TO Len(aEmbala)
//                  If ( (aEmbala[nZ][2]) = "" .AND. (aEmbala[nZ][10]) = " " ) // Jose 30/04/2025
//                     nIndex := 0 // Jose 30/04/2025
//                  EndIf // Jose 30/04/2025
                  oPrn:Say(nLin, nCol, Iif(!Empty(aEmbala[nZ][1]), aEmbala[nZ][1]+'-'+Alltrim(aEmbala[nZ][2]), space(03)+Alltrim(aEmbala[nZ][2])), oFont2, , , , ) 
                  
                  If !Empty(aEmbala[nZ][1]) //.and. !Empty(Posicione("SB1", 1, xFilial("SB1")+aEmbala[nZ][2], "B1_RELCAT1")) //Omitido por Cleber(07/03/2012
                     DbSelectArea("SZ5")
                     DbSetOrder(1)
                     DbSeek(xFilial("SZ5")+aEmbala[nZ][1],.t.)
                     If Found()
                        oPrn:Say(nLin, nCol+200, "("+Alltrim(Transform(SZ5->Z5_VOLUME,"@E 999.999"))+Iif(SZ5->Z5_UMEMB ='K',"K","L")+")", oFont2, , , , )
                     Endif
                  Endif                 
                  cQry := ""      // INCLUSÃO DA RELAÇÃO DE VOLUMES - SOLICITADO POR MICHELLY 20/08/12
                  cQry += "SELECT RELVOL = dbo.DetVol('"+xFilial("SB1")+"','"+Iif(!Empty(aEmbala[nZ][1]), aEmbala[nZ][10], aEmbala[nZ][2])+"')"
				      TCQuery cQry ALIAS "TCR" NEW
                  DbSelectArea("TCR")
                  oPrn:Say(nLin, nCol+460, IIF(!Empty(TCR->RELVOL),Substr(Alltrim(TCR->RELVOL),1,10),''), oFont2, , , , )
                  DbClosearea() 
                  
                //MSBAR("EAN13",  5,  nCmt , aEmbala[nZ][10], oPrn, NIL, NIL, NIL, Nil, 0.7, NIL, NIL, NIL, .f.) 
                //MSBAR("CODE128",  6,  nCmt , Posicione("SB1", 1, xFilial("SB1")+aEmbala[nZ][10], "B1_CODBAR"), oPrn, NIL, NIL, NIL, Nil, 0.7, NIL, NIL, NIL, .f.) 
                  
                  
                  oPrn:Say(nLin, nCol+0770, SubStr(aEmbala[nZ][3], 1, 26), oFont2, , , , )
                  oPrn:Say(nLin, nCol+1530, TransForm(aEmbala[nZ][6], "@E 99999"), oFont2, , , , )

                  If substr(cNumEmp,3,2) = '06' // jose 06/05/2025
                     If !Empty(aEmbala[nZ][7])  
                        nColCB  :=16
                        MSBAR("CODE128",    nCmt -0.2,  nColCB , aEmbala[nZ][11], oPrn, NIL, NIL, NIL, NIL, 0.8, NIL, NIL, NIL, .f.)    //Jose 08/04/2025  Jose 30/04/205 aEmbala[nZ][11] 
                        oPrn:Say(nLin, nCol+1870, SubStr(aEmbala[nZ][11] , 1, 30), oFont2, , , , )  // Jose 08/04/2025    Jose 30/04/2025 aEmbala[nZ][11]
                     Else

                     EndIF
                  Else
//                   If !Empty(aEmbala[nZ][7]) // Jose 30/04/2025 
                     If ( (aEmbala[nZ][2]) = "" .AND. (aEmbala[nZ][10]) = " " ) // Jose 30/04/2025
                        nColCB  :=16
//                      nIndex += 1 // Jose 30/04/2025
                        nIndex := nZ - 1 // Jose 30/04/2025
                        MSBAR("CODE128",    nCmt -0.2,  nColCB , aEmbala[nIndex][11], oPrn, NIL, NIL, NIL, NIL, 0.8, NIL, NIL, NIL, .f.)    //Jose 08/04/2025  Jose 30/04/205 aEmbala[nZ][11] 
                        oPrn:Say(nLin, nCol+1870, SubStr(aEmbala[nIndex][11] , 1, 30), oFont2, , , , )  // Jose 08/04/2025    Jose 30/04/2025 aEmbala[nZ][11]
//                      oPrn:Say(nLin, nCol+1860, SubStr(aEmbala[nZ][7] , 1, 20), oFont2, , , , )  // Jose 08/04/2025
                     Else

                     Endif
                  EndIf

//                If !Empty(aEmbala[nZ][8])  // Jose 08/04/2025 +2120 
//                    oPrn:Say(nLin, nCol+2140, aEmbala[nZ][8], oFont2, , , , ) // Jose 08/04/2025 +2120  
//                Endif  // Jose 08/04/2025 +2120 

                  If aEmbala[nZ][9] == 1
                     nLin += 30
                     nCmt += 0.25
                  ElseIf aEmbala[nZ][9] == 2
                  	 oPrn:Say(nLin, nCol+1660, ' [ ]', oFont2, , , , ) 
		 			       //Cleber (19/04/13) -> Michelly reclamou que não tava saindo nro das OPs das embalagens
                  //  oPrn:Say(nLin, nCol+1860, "["+aEmbala[nZ][11]+"]", oFont2, , , , )
                      nCmt += 0.5
                      nLin += 60
                 	 
                  /*   
                  ElseIf aEmbala[nZ][9] == 3 REMOVIDO POR SOLICITAÇÃOD E CHAMADO 015414
                         oPrn:Say(nLin, nCol, 'PEDIDO: '+aEmbala[nZ][13]+'-'+aEmbala[nZ][14]+' / CLIENTE: '+Posicione("SC5", 1, xFilial("SC5")+aEmbala[nZ][13], "C5_CLIENTE")+'-'+SubStr(Alltrim(Posicione("SA1", 1, xFilial("SA1")+Posicione("SC5", 1, xFilial("SC5")+aEmbala[nZ][13], "C5_CLIENTE"), "A1_NOME")), 1, 30), oFont2, , , , )
                         nLin += 60
                         nCmt += 0.5 */
                  Endif  
              Next
// Jose 23/04/2025 
/*              If nIndex = 0 // Jose 23/04/2025
                 nZ = nZ - 3 // Jose 23/04/2025
                 If nZ > 0  // Jose 23/04/2025
                    nColCB  :=16 // Jose 23/04/2025
                    MSBAR("CODE128",    nCmt -0.2,  nColCB , aEmbala[nZ][11], oPrn, NIL, NIL, NIL, NIL, 0.8, NIL, NIL, NIL, .f.)    // Jose 23/04/2025
                    oPrn:Say(nLin, nCol+1870, SubStr(aEmbala[nZ][11] , 1, 30), oFont2, , , , )  // Jose 23/04/2025
                 EndIf
               EndIf*/
//  ate aqui 23/04/2025

              nLin += 050             //         1         2         3         4         5         6         7         
              nCmt += 0.5             //1234567890123456789012345678901234567890123456789012345678901234567890123456789
          Next

          //oPrn:Say(nLin, nCol, '--------------------------------------------------------------------------------------------------------------------------------------------------------------', oFont6, , , , )
          nColCB  :=0.1
          nColCod :=100
          cCodPro := ""
          /* nelieder */
          For nZ := 1 TO Len(aEmbala)
              If aEmbala[nZ][9] == 2 .and. ALLTRIM(aEmbala[nZ][10]) <> ALLTRIM(cCodPro) 
                 MSBAR("CODE128",  nCmt +0.6,  nColCB , aEmbala[nZ][10], oPrn, NIL, NIL, NIL, Nil, 0.8, NIL, NIL, NIL, .f.)  
                 cCodPro := aEmbala[nZ][10]     
                 oPrn:Say(nLin +110, nCol + nColCod, aEmbala[nZ][10], oFont4,,,,)  
                 /* Nelieder */
                 oPrn:Say(nLin +110, nCol + nColCod + 400, "Est = "+Alltrim(aEmbala[nZ][15]), oFont4,,,,)
                 nColCB  +=7.8
                 nColCod +=915	
              Endif
          Next nZ
          If NColCB >0.1
              nLin += 130
          Else
              oPrn:Say(nLin, nCol, '--------------------------------------------------------------------------------------------------------------------------------------------------------------', oFont6, , , , )
          Endif    

          nLin += 40 
          oPrn:Say(nLin, nCol, 'DATA         : [ ___/___/___ ]                 TURNO [ ____________ ]', oFont7, , , , )
          nLin += 60
          oPrn:Say(nLin, nCol, 'HORA INICIO  : [ ___:___ ]                 HORA TERMINO : [ ___:___ ]', oFont7, , , , )
          nLin += 60
          oPrn:Say(nLin, nCol, 'PARADA MOTIVO:'                                                       , oFont7, , , , )
          nLin += 60
          oPrn:Say(nLin, nCol, 'ENVASADOR    : [ __________________________________________________ ]', oFont7, , , , )
          nLin += 60
          oPrn:Say(nLin, nCol, 'ETIQUETADOR  : [ __________________________________________________ ]', oFont7, , , , )
          nLin += 60
 /*       oPrn:Say(nLin, nCol, 'PERDAS       :'                                                       , oFont7, , , , )
          For nY := 1 To Len(aEmbal)
              nLin += 40
              oPrn:Say(nLin, nCol     , aEmbal[nY][1]               , oFont7, , , , )
              oPrn:Say(nLin, nCol+0500, SubStr(aEmbal[nY][2], 1, 30), oFont7, , , , )
              oPrn:Say(nLin, nCol+1500, 'QTDE. PERDA : [ ______ ]'  , oFont7, , , , )
          Next
          lOut    := .f.
          nLinAux := 0
          For nY := 1 To Len(aEmbal)
              If aEmbal[nY][4] > 0.00
                 nLinAux += 1
                 lOut := .t.
              Endif
          Next
          If lOut
             nLinAux += 1
          Endif
          If nLin + (160 + (40 * nLinAux)) >= nLinMax
             nLin := 30
             PCPR01_9(1, _NumOrd, _DatEmi, _DesPro, _CodCat, _PadCor)
          Else
             nLin += 80
          Endif
 */
          oPrn:Say(nLin, nCol, '		    	CONFERÊNCIA DAS EMBALAGENS : __________________'          , oFont7, , , , )
          nLin += 065
          oPrn:Say(nLin, nCol, 'OBSERVAÇÕES  :'                                                       , oFont7, , , , )
          nLin += 040
          //
          //123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
          //99 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    CONCENTRADO: 
          //                                       OUTROS     : 0181 / 
          lOut := .f.
          For nY := 1 To Len(aEmbal)
              If aEmbal[nY][4] > 0.00
               	cAuxOut := ""
             	cAuxOut += aEmbal[nY][3]+' - '+SubStr(Posicione("SZ5", 1, xFilial("SZ5")+aEmbal[nY][3], "Z5_DESCR"), 1, 15)+'    CONCENT.: '+Transform(Round(aEmbal[nY][4], 3), "@E 99.999")
                For nX := 1 To Len(aCodOut)
                     If nX == 1
                        cAuxOut += ' - OUTROS: '
                     Endif
                     cAuxOut += Alltrim(aCodOut[nX][1])+': '+Transform(Round(((Posicione("SZ5", 1, xFilial("SZ5")+aEmbal[nY][3], "Z5_VOLUME")) * (aCodOut[nX][2] / 100) * (_PesEsp)), 3), "@E 99.999")+' / '
                 Next
                 cAuxOut := SubStr(cAuxOut, 1, Len(cAuxOut) - 3)
                 oPrn:Say(nLin, nCol, cAuxOut, oFont7, , , , )
                 nLin += 40
              Endif
          Next
          nLin += 050
          oPrn:Say(nLin, nCol, 'LABORAT...: [ ]LIBERADO / [ ]NÃO LIBER. - RESP.:  __________________ Hr:__:__', oFont7, , , , )
          nLin += 050
          oPrn:Say(nLin, nCol, 'PADRÃO COR: [ ]SIM / [ ]NÃO             - RESP.:  __________________ Hr:__:__', oFont7, , , , )
          nLin += 050
          oPrn:Say(nLin, nCol, 'CONF.  COR: [ ]SIM / [ ]NÃO             - RESP.:  __________________ Hr:__:__', oFont7, , , , )
          nLin += 050
          If Len(aRetenc)>0 
          	  nAEmbal = (Len(aEmbal)-1)         // controle p/ não imprimir registro da embalagem retenção
          Else
              nAEmbal = Len(aEmbal)
          Endif
          For nY := 1 To nAEmbal   
           If nLin >= nLinMax
          	  	  AVNEWPAGE
          	  	  nLin :=040   	    	   
                  oPrn:Say(nLin, nCol + 0900, "CONTROLE ", oFont1,,,,)
	       	      nLin += 90
	              nCmt += 0.25
                 // Jose 12/11/2024 acrescentado 
	              oPrn:Say(nLin   , nCol + 1800, "EMISSÃO:"                                        , oFont2, , , , )
                 oPrn:Say(nLin   , nCol + 2050, DTOC(_DatEmi)                                     , oFont2, , , , )
                 // jose 12/11/2024 ate aqui
	              oPrn:Say(nLin, nCol + 0750, Transform(TCQ->C2_PRODUTO, "@R XX 99.99.999-99")  , oFont3, , , , )
	              oPrn:Say(nLin, nCol + 1400, "Hora..:"+Time(), oFont4,,,,) // Jose 12/11/2024 nCol + 1850,
     	          nLin += 60
	              oPrn:Say(nLin   , nCol + 0750, SubStr(Alltrim(_DesPro), 1, 25)                   , oFont3, , , , )
	              oPrn:Say(nLin   , nCol + 1800, "ENTREGA:"                                        , oFont2, , , , ) // Jose 12/11/2024  "EMISSÃO:" 
                 oPrn:Say(nLin   , nCol + 2050, DTOC(_DATPRF)                                     , oFont2, , , , ) // Jose 12/11/2024  DTOC(_DatEmi)  
	              oPrn:Say(nLin, nCol + 0200, 'O.P.: '+SubStr(_NumOrd, 1, 6), oFont4, , , , )
	              nLin += 60
	              oPrn:Line(nLin, nCol      , nlin, nColMax)
	              nLin += 15
	              oPrn:Line(nLin, nCol      , nlin, nColMax)
	              nLin += 60
			 EndIF     		  
           //If !Alltrim(Posicione("SB1", 1, xFilial("SB1")+SubStr(aEmbal[nY][1],1,5), "B1_GRUPO")) $ GETMV("MV_GRTAMPA")
             If !Alltrim(Posicione("SB1", 1, xFilial("SB1")+SubStr(aEmbal[nY][1],1,5), "B1_GRUPO")) $ _cMVGRTAMP
              	nLin += 40
          	  	oPrn:Say(nLin, nCol, 'EMBALAGEM: '+SubStr(aEmbal[nY][1],1,5)+'-'+SubStr(aEmbal[nY][2], 1, 30)+'            REG 1-)____________  ', oFont7, , , , )
          	  	nLin += 050                                                         
             //oPrn:Say(nLin, nCol, 'PESO           MÍN -0,5%  MÁX +0,5% RESPONSÁVEL            REG 2-)____________  ', oFont7, , , , ) 
          	  	oPrn:Say(nLin, nCol, '   PESO                          RESPONSÁVEL               REG 2-)____________  ', oFont7, , , , ) 
          	  	nLin += 050                                                                    
          	  	oPrn:Say(nLin, nCol, '                                                           REG 3-)____________  ', oFont7, , , , )      
         	 //If TCQ->C2_QUANT >= GETMV("MV_QTDINSP") // RETIRADO A PEDIDO DE MARCIO NONIS - MICHELLY CIENTE - 11/12/14
	          //  	nLin += 050
          	 //	oPrn:Say(nLin, nCol, '__________    ________   ________   _______________        REG 4-)____________  ', oFont7, , , , )	
		  	  	 //Else // Incluído o peso da embalagem de acordo com o peso específico padrão para produtos que não atingem o volume de inspeção, já que não são realizadas análises para estas o.ps
			  	  // Variação : Peso Máximo 0.5% p/ mais / Peso Mínimo 0.5% p/ menos 
			  	  // Alterado de 1% para 0.5% por Solicitação de Gustavo Diniz via chamado em 14/09/15
			    	nPesPadr = Iif(Posicione("SB1", 1, xFilial("SB1")+Substr(TCQ->C2_PRODUTO,1,10)+aEmbal[nY][3], "B1_SEGUM") $ 'K ', Posicione("SB1", 1, xFilial("SB1")+Substr(TCQ->C2_PRODUTO,1,10)+aEmbal[nY][3], "B1_CONV"), (Posicione("SB1", 1, xFilial("SB1")+Substr(TCQ->C2_PRODUTO,1,10)+aEmbal[nY][3], "B1_CONV")) * Posicione("SB1", 1, xFilial("SB1")+TCQ->C2_PRODUTO, "B1_PESOESP"))
	          	  	nLin += 020
				 //oPrn:Say(nLin, nCol, Transform(nPesPadr,"@E 9999.9999") +'    '+Transform((nPesPadr*0.995),"@E 9999.9999") +'  '+Transform((nPesPadr*1.005),"@E 9999.9999"), oFont7, , , , )	
					oPrn:Say(nLin, nCol, Transform(nPesPadr,"@E 9999.9999")						 , oFont7, , , , )	
	       	  		nLin += 030
           	    //oPrn:Say(nLin, nCol, '__________    ________   ________   _______________        REG 4-)____________  ', oFont7, , , , )	
           	  		oPrn:Say(nLin, nCol, '______________            _________________________        REG 4-)____________  ', oFont7, , , , )	

	 	  	   //Endif
		  	  	   nLin += 050
          	  	oPrn:Say(nLin, nCol, '                                                           REG 5-)____________  ', oFont7, , , , )	
          	  	nLin += 020
         	 //oPrn:Say(nLin, nCol, '__________    ________   ________   _______________ ', oFont7, , , , )	
					oPrn:Say(nLin, nCol, '______________            _________________________ ', oFont7, , , , )	
          	  	nLin += 030
          	 //nLin += 050 
          	 
           	Endif
          Next

          nLin += 080
          If !Empty(_ObsOrd)
             oPrn:Say(nLin, nCol, UPPER(_ObsOrd), oFont3, , , , )
             nLin += 040
          Endif
       Else
          //PCPR01_9(1, _NumOrd, _DatEmi, _DesPro, _CodCat, _PadCor)
          //nLin += 080
          //oPrn:Say(nLin, nCol, 'LABORAT...: [ ]LIBERADO / [ ]NÃO LIBER. - RESP.:  __________________ Hr:__:__', oFont2, , , , )
          //nLin += 080
          //oPrn:Say(nLin, nCol, 'PADRÃO COR: [ ]SIM / [ ]NÃO             - RESP.:  __________________ Hr:__:__', oFont2, , , , )
          //nLin += 080
          //oPrn:Say(nLin, nCol, 'CONF.  COR: [ ]SIM / [ ]NÃO             - RESP.:  __________________ Hr:__:__', oFont2, , , , )
       Endif
Return

/**********************************************************************************************************/
/*** PCPR01_7 - Monta impressão das Operações.                                                          ***/
/**********************************************************************************************************/
Static Function PCPR01_7()
       Local nLoop
       
	    nLin += 80
       DbSelectArea("SG2")
       DbSetOrder(1)  // g2_filial+g2_produto
       DbSeek(xFilial("SG2")+TCQ->C2_PRODUTO+TCQ->C2_ROTEIRO, .t.)
       If Found()
          _cPula = 0  //  Jose   11/08/2023
          oPrn:Say(nLin, nCol +850, "O P E R A Ç Õ E S", oFont2, , , , )
          nLin += 40
          While !Eof() .and. SG2->G2_PRODUTO+SG2->G2_CODIGO == TCQ->C2_PRODUTO+TCQ->C2_ROTEIRO
                _cPula := 1  //  Jose   11/08/2023
                oPrn:Say(nLin, nCol    , '-------------------------------------------------------------------------------', oFont2, , , , )
                nLin += 50
                oPrn:Say(nLin, nCol     , Alltrim(SG2->G2_OPERAC)        , oFont2, , , , )
                oPrn:Say(nLin, nCol+0100, Left(SG2->G2_DESCRI,18)        , oFont2, , , , )
                oPrn:Say(nLin, nCol+0700, "INICIO[___/___/___  ___:___]" , oFont4, , , , )
                oPrn:Say(nLin, nCol+1500, "TERMINO[___/___/___  ___:___]", oFont4, , , , )
                cCodRec := ""
                cCodRec := Posicione("SH1", 1, xFilial("SH1")+SG2->G2_RECURSO, "H1_CODIGO")
                cDesRec := Posicione("SH1", 1, xFilial("SH1")+SG2->G2_RECURSO, "H1_DESCRI") 
                cCodRec := Iif(Empty(cCodRec), cDesRec, Iif(Empty(cDesRec), cCodRec, cCodRec+' - '+cDesRec))
                If !Empty(cCodRec)
                   nLin += 60
                   oPrn:Say(nLin, nCol, cCodRec, oFont2, , , , )
                Endif
                If mv_par08 == 1
                   cMemo   := MSMM(,80,,SG2->G2_ESPOP,,,"SG2",)
                   nMCount := MlCount( cMemo, 78 )
                   If !Empty(nMCount)
                      For nLoop := 1 To nMCount
                         cLinha := MemoLine( cMemo, 78, nLoop )
                         nLin += 60
                         oPrn:Say(nLin, nCol, StrTran( cLinha, Chr(13)+Chr(10), "" ), oFont5, , , , )
                         If nLin >= nLinMax
                            AVNEWPAGE
                            nLin := 30
                            PCPR01_3(_NumOrd, _DatEmi, _QtdSol, _DesPro, _DesLin, _CodCat)
                         Endif
                      Next
                   Endif
                 If !Empty(nMCount) = .F.  // Jose 14/08/2023
                    _cPula = 0  // Jose 14/08/2023
                 EndIf // Jose 14/08/2023
                Endif
                nLin += 50
                oPrn:Say(nLin, nCol    , '-------------------------------------------------------------------------------', oFont2, , , , )
                nLin += 50
            If _cPula = 1  //  Jose 14/08/2023
                If nLin >= nLinMax
                   AVNEWPAGE
                   nLin := 30
                   PCPR01_3(_NumOrd, _DatEmi, _QtdSol, _DesPro, _DesLin, _CodCat)
                Endif
            EndIf  // Jose 14/08/2023
                DbSelectArea("SG2")
                DbSkip()
                _cPula = 0  //  Jose   11/08/2023
          Enddo
       Endif
       If _cPula = 1  //  Jose 11/08/2023
          If nLin >= nLinMax
             AVNEWPAGE
             nLin := 30
             PCPR01_3(_NumOrd, _DatEmi, _QtdSol, _DesPro, _DesLin, _CodCat)
          Endif
       EndIf  //  Jose   11/08/2023
Return

/**********************************************************************************************************/
/*** PCPR01_6 - Monta impressão de Lote Proibido.                                                       ***/
/**********************************************************************************************************/
Static Function PCPR01_6()
       Local lRevisao := .f.
       
       DbSelectArea("SZM")
       DbSetOrder(3)
       DbSeek(xFilial("SZM")+TCQ->C2_PRODUTO, .t.)
       If Found()
          While !Eof() .and. Alltrim(SZM->ZM_CODIGO) == Alltrim(TCQ->C2_Produto)
                If !SZM->ZM_STATUS $ "AC.RE"
                   lRevisao := .T.
                Endif
                DbSkip()
          Enddo
       Endif
       If lRevisao
          nLin += 60
          oPrn:Box(nLin, nCol      , nlin + 60       , nColMax)
          oPrn:Say(nLin, nCol + 350, 'ATENÇÃO - EXISTE FÓRMULA DESTE PRODUTO EM DESENVOLVIMENTO - VERIFIQUE' , oFont3, , , , )
       Endif
       If nLin >= nLinMax
          AVNEWPAGE
          nLin := 30
          PCPR01_3(_NumOrd, _DatEmi, _QtdSol, _DesPro, _DesLin, _CodCat)
       Endif
Return

/**********************************************************************************************************/
/*** PCPR01_5 - Monta impressão dos ensaios do produto.                                                 ***/
/**********************************************************************************************************/
Static Function PCPR01_5(_ObsOrd)
       Local aEnsaio := {}
       Local aAuxImp := {}
       Local nParte  := 1
       Local nY
       
       aAdd(aEnsaio, {"PESO ESP"   ,"SB1->B1_PESOESP"})
       aAdd(aEnsaio, {"EMPILHAM."  ,"SB1->B1_ESP02"})
       aAdd(aEnsaio, {"VISCOSIDADE","SB1->B1_ESP03"})
       aAdd(aEnsaio, {"ESTABILID"  ,"SB1->B1_ESP04"})
       aAdd(aEnsaio, {"N.V.MASSA"  ,"SB1->B1_ESP05"})
       aAdd(aEnsaio, {"POT LIFE"   ,"SB1->B1_ESP06"})
       aAdd(aEnsaio, {"SECAGEM PO" ,"SB1->B1_ESP07"})
       aAdd(aEnsaio, {"SUBSTRATO"  ,"SB1->B1_ESP08"})
       aAdd(aEnsaio, {"SEC. TOQUE" ,"SB1->B1_ESP09"})
       aAdd(aEnsaio, {"APLICACAO"  ,"SB1->B1_ESP10"})
       aAdd(aEnsaio, {"SEC. MANUS" ,"SB1->B1_ESP11"})
       aAdd(aEnsaio, {"COBERTURA"  ,"SB1->B1_ESP12"})
       aAdd(aEnsaio, {"BRILHO"     ,"SB1->B1_ESP13"})
       aAdd(aEnsaio, {"FINEZA"     ,"SB1->B1_ESP14"})
       aAdd(aEnsaio, {"ADERENCIA"  ,"SB1->B1_ESP15"})
       aAdd(aEnsaio, {"APROVACAO"  ,"SB1->B1_ESP16"})
       aAdd(aEnsaio, {"LIXAMENTO"  ,"SB1->B1_ESP17"})

       DbSelectArea("SB1")
       DbSetOrder(1)
       DbSeek(xFilial("SB1")+TCQ->C2_PRODUTO, .t.)
       If Found()
          For nY := 1 To Len(aEnsaio)
              If ValType(&(aEnsaio[nY][2])) == 'N'
                 If &(aEnsaio[nY][2]) > 0.0
                    If nParte == 1
                       aadd(aAuxImp, {aEnsaio[nY][1], SubStr(Alltrim(Transform(&(aEnsaio[nY][2]), "@E 999.99999")), 1, 10), "", ""})
                       nParte += 1
                    Else
                       aAuxImp[Len(aAuxImp)][3] := aEnsaio[nY][1]
                       aAuxImp[Len(aAuxImp)][4] := SubStr(Alltrim(Transform(&(aEnsaio[nY][2]), "@E 999.99999")), 1, 10)
                       nParte := 1
                    Endif
                 Endif
              ElseIf ValType(&(aEnsaio[nY][2])) == 'C'
                     If !Empty(&(aEnsaio[nY][2]))
                        If nParte == 1
                           aadd(aAuxImp, {aEnsaio[nY][1], SubStr(&(aEnsaio[nY][2]), 1, 13), "", ""})
                           nParte += 1
                        Else
                           aAuxImp[Len(aAuxImp)][3] := aEnsaio[nY][1]
                           aAuxImp[Len(aAuxImp)][4] := SubStr(&(aEnsaio[nY][2]), 1, 13)
                           nParte := 1
                        Endif
                     Endif
              Endif
          Next
       Endif
       aAdd(aAuxImp, {"TARA:", "", "PESAGEM:"   , ""})
       aAdd(aAuxImp, {""     , "", "PESO FINAL:", ""})
       If Len(aAuxImp) > 0
          nLin += 30
          oPrn:Line(nLin   , nCol       , nLin   , nColMax  )
          oPrn:Line(nLin   , nCol       , nLin+60, nCol     )
          oPrn:Line(nLin   , nCol + 0360, nLin+60, nCol+0360)
          oPrn:Line(nLin   , nCol + 0800, nLin+60, nCol+0800)
          oPrn:Line(nLin   , nCol + 1175, nLin+60, nCol+1175)
          oPrn:Line(nLin   , nCol + 1505, nLin+60, nCol+1505)
          oPrn:Line(nLin   , nCol + 1945, nLin+60, nCol+1945)
          oPrn:Line(nLin   , nColMax    , nLin+60, nColMax  )
          oPrn:Line(nLin+60, nCol       , nLin+60, nColMax  )
          oPrn:Say(nLin, nCol + 0500, 'STD'     , oFont2, , , , )
          oPrn:Say(nLin, nCol + 0880, 'OBTIDOS' , oFont2, , , , )
          oPrn:Say(nLin, nCol + 1650, 'STD'     , oFont2, , , , )
          oPrn:Say(nLin, nCol + 2025, 'OBTIDOS' , oFont2, , , , )
          nLin += 60
          nUltCol := Iif(aAuxImp[Len(aAuxImp)][3] == Nil, 3, 0)
          For nY := 1 To Len(aAuxImp)
              If nY == Len(aAuxImp)
                 oPrn:Line(nLin   , nCol       , nLin+60, nCol     )
                 oPrn:Line(nLin   , nCol + 0360, nLin+60, nCol+0360)
                 oPrn:Line(nLin   , nCol + 0800, nLin+60, nCol+0800)
                 oPrn:Line(nLin   , nCol + 1175, nLin+60, nCol+1175)
                 oPrn:Line(nLin   , nCol + 1505, nLin+60, nCol+1505)
                 oPrn:Line(nLin   , nCol + 1945, nLin+60, nCol+1945)
                 oPrn:Line(nLin   , nColMax    , nLin+60, nColMax  )
                 oPrn:Line(nLin+60, nCol       , nLin+60, nColMax  )
                 oPrn:Say(nLin, nCol + 0030, aAuxImp[nY][1], oFont2, , , , )
                 oPrn:Say(nLin, nCol + 0370, aAuxImp[nY][2], oFont2, , , , )
                 If aAuxImp[nY][3] <> Nil
                    oPrn:Say(nLin, nCol + 1200, aAuxImp[nY][3], oFont2, , , , )
                    oPrn:Say(nLin, nCol + 1515, aAuxImp[nY][4], oFont2, , , , )
                 Endif
                 nLin += 60
              Else
                 oPrn:Line(nLin   , nCol       , nLin+60, nCol     )
                 oPrn:Line(nLin   , nCol + 0360, nLin+60, nCol+0360)
                 oPrn:Line(nLin   , nCol + 0800, nLin+60, nCol+0800)
                 oPrn:Line(nLin   , nCol + 1175, nLin+60, nCol+1175)
                 oPrn:Line(nLin   , nCol + 1505, nLin+60, nCol+1505)
                 oPrn:Line(nLin   , nCol + 1945, nLin+60, nCol+1945)
                 oPrn:Line(nLin   , nColMax    , nLin+60, nColMax  )
                 oPrn:Line(nLin+60, nCol       , nLin+60, nColMax  )
                 oPrn:Say(nLin, nCol + 0030, aAuxImp[nY][1], oFont2, , , , )
                 oPrn:Say(nLin, nCol + 0370, aAuxImp[nY][2], oFont2, , , , )
                 oPrn:Say(nLin, nCol + 1200, aAuxImp[nY][3], oFont2, , , , )
                 oPrn:Say(nLin, nCol + 1515, aAuxImp[nY][4], oFont2, , , , )
                 nLin += 60
              Endif
          Next
       Endif
       If !Empty(_OBSORD)
          oPrn:Say(nLin, nCol, UPPER(_OBSORD) , oFont3, , , , )
          nLin += 60
       Endif
       If nLin >= nLinMax
          AVNEWPAGE
          nLin := 30
          PCPR01_3(_NumOrd, _DatEmi, _QtdSol, _DesPro, _DesLin, _CodCat)
       Endif
Return

/**********************************************************************************************************/
/*** PCPR01_4 - Monta impressão dos itens empenhados e o Acerto de Cores                                ***/
/**********************************************************************************************************/
Static Function PCPR01_4(_NumOrd, _DatEmi, _QtdSol, _DesPro, _DesLin, _CodCat, aRetenc, _PesEsp)
       Local aAceCor := {}
       Local nQtdTot := 0
       Local aMatEmp := {}
       Local nTotMat := 0  
       Local cDescr := ""
       Local cReten := ""
       Local nY
       Local _cGRPCONC  := Alltrim( GETMV("MV_GRPCONC") )
       //Impressão dos ITENS EMPENHADOS
       nLin += 40
       cQry := ""
       cQry += "SELECT SD4.D4_COD, SD4.D4_TRT, SD4.D4_QTDEORI, SD4.D4_ACECOR, SD4.D4_LOCAL "
       cQry += "FROM "+RetSqlName("SD4")+" SD4 WITH (NOLOCK) "
       cQry += "WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"' "
       cQry += "  AND SD4.D_E_L_E_T_ = '' "
       cQry += "  AND SD4.D4_OP = '"+_NumOrd+"' "
       cQry += "ORDER BY SD4.D4_TRT "
       TCQuery cQry ALIAS "TSD4" NEW
       DbSelectArea("TSD4")
       DbGoTop()
       While !Eof() 
       		dbselectarea("SB1")
       		dbsetorder(1)
       		dbseek(xFilial("SB1")+Alltrim(TSD4->D4_COD)+space(15 - Len(Alltrim(TSD4->D4_COD))),.f.)
       		If found()
               // produto de custeio
               If U_IsProdCusto(TSD4->D4_COD)
                  TSD4->(dbSkip())
                  Loop
               Endif   
         		//If !Alltrim(TSD4->D4_COD) $ GETMV("MV_RETENOP")
                	If Posicione("SZ4", 1, xFilial("SZ4")+Substr(TCQ->C2_PRODUTO, 01, 3)+Substr(TCQ->C2_PRODUTO, 04, 2), "Z4_USAFILT") $ 'S'
                   		If !Empty(Posicione("SZ1", 1, xFilial("SZ1")+Substr(TCQ->C2_PRODUTO, 04, 2), "Z1_CODFILT")) .and. Alltrim(TSD4->D4_COD) $ Alltrim(Posicione("SZ1", 1, xFilial("SZ1")+Substr(TCQ->C2_PRODUTO, 04, 2), "Z1_CODFILT"))
                      		aadd(aRetenc, {'99', Alltrim(TSD4->D4_COD)+space(15 - Len(Alltrim(TSD4->D4_COD))), 1    , Round(TSD4->D4_QTDEORI, 3), iif((cNumEmp = "01010101") .AND. (SUBSTR(SB1->B1_GRUPO,1,1) != "E"),"",SB1->B1_DESC), '', 0})
                      		DbSelectArea("TSD4")
                      		DbSkip()
                      		Loop
                   		Endif
                	Endif
                	aAdd(aMatEmp, {Alltrim(TSD4->D4_COD)+space(15 - Len(Alltrim(TSD4->D4_COD))), TSD4->D4_TRT, Round(TSD4->D4_QTDEORI, 3), Round(TSD4->D4_ACECOR, 3), TSD4->D4_LOCAL, 0 } )
                	nTotMat += Round(TSD4->D4_QTDEORI, 3) + Round(TSD4->D4_ACECOR, 3)
             	//Else
                	//aadd(aRetenc, {'11', Alltrim(TSD4->D4_COD)+space(15 - Len(Alltrim(TSD4->D4_COD))), 0.225, Round(TSD4->D4_QTDEORI, 3), iif((cNumEmp = "01010101") .AND. (SUBSTR(SB1->B1_GRUPO,1,1) != "E"),"",SB1->B1_DESC), '', 0})
             	//Endif    
         	Endif 
          	DbSelectArea("TSD4")
           	DbSkip()
       Enddo
       // INCLUSÃO DA EMBALAGEM DE RETENÇÃO QUANDO OP ATINGIR O VOLUME MV_QTDRETE. CARATER INFORMATIVO, JÁ QUE ESSES PRODUTOS NÃO ESTÃO MAIS NA ESTRUTURA. ANDRÉ 16/09/14
       If (!Empty(Posicione("SZ1", 1, xFilial("SZ1")+Substr(TCQ->C2_PRODUTO, 04, 2), "Z1_PRODRET"))) 
       	   cReten := Posicione("SZ1", 1, xFilial("SZ1")+Substr(TCQ->C2_PRODUTO, 04, 2), "Z1_PRODRET")
       	   If !(SuperGetMV("ZP_PAR0004",.F.,"") == SUBSTR( TCQ->C2_PRODUTO, 4, 2)) //LGS#20181221 - CHAMADO 005100 - IMPRESSAO DA RETENÇÃO INDEPENDENTE DA QUANTIDADE PARA LINHAS DE PRODUTOS CONTIDAS NO PARAMETRO. Cleber (22/01/20)-> Troca por SUPERGETMV por conta da UnionSur
   	          If (Alltrim(cReten) $  GETMV("MV_RETENOP")) .and.(TCQ->C2_QUANT >= GETMV("MV_QTDRETE"))
                 aadd(aRetenc, {'11', Alltrim(cReten)+space(15 - Len(Alltrim(cReten))), 0.225, Round(0.225, 3), iif((cNumEmp = "01010101") .AND. (SUBSTR(Posicione("SB1", 1, xFilial("SB1")+cReten, "B1_GRUPO"),1,1) != "E"),"",Posicione("SB1", 1, xFilial("SB1")+cReten, "B1_DESC")), '', 0})
              Endif
           Else
              aadd(aRetenc, {'11', Alltrim(cReten)+space(15 - Len(Alltrim(cReten))), 0.225, Round(0.225, 3), iif((cNumEmp = "01010101") .AND. (SUBSTR(Posicione("SB1", 1, xFilial("SB1")+cReten, "B1_GRUPO"),1,1) != "E"),"",Posicione("SB1", 1, xFilial("SB1")+cReten, "B1_DESC")), '', 0})
		   Endif	
	   Endif

       DbSelectArea("TSD4")
       DbCloseArea()
       For nY := 1 To Len(aMatEmp)
           aMatEmp[nY][6] := Round((aMatEmp[nY][3] / nTotMat) * 100, 2)
       Next
       For nY := 1 To Len(aMatEmp)
           nPerFor := aMatEmp[nY][6]     
           
           cLocPro := SubStr(Alltrim(Posicione("SB2", 1, xFilial("SB2")+aMatEmp[nY][1]+Posicione("SB1", 1, xFilial("SB1")+aMatEmp[nY][1], "B1_LOCPAD"), "B2_LOCALIZ")), 1, 6)
           oPrn:Say(nLin, nCol + 0030, Alltrim(aMatEmp[nY][1])+Iif(Posicione("SB1", 1, xFilial("SB1")+aMatEmp[nY][1], "B1_TIPO") $ 'MP', '    ('+Transform(Posicione("SB1", 1, xFilial("SB1")+aMatEmp[nY][1], "B1_EMIN"), "@E 99,999")+')', ''), oFont2, , , , )
           cInkMak := '          '
           If !Empty(Posicione("SC2", 1, xFilial("SC2")+SubStr(_NumOrd, 1, 6)+'02', "C2_NUM"))
              //LGS#20200207 - Adequação de release 12.1.25 e posteriores
              //If Posicione("SB1", 1, xFilial("SB1")+aMatEmp[nY][1], "B1_GRUPO") $ Alltrim(GETMV("MV_GRPCONC"))
              If Posicione("SB1", 1, xFilial("SB1")+aMatEmp[nY][1], "B1_GRUPO") $ _cGRPCONC
                 If !Empty(Posicione("SB2", 1, xFilial("SB2")+SB1->B1_COD+Posicione("SB1", 1, xFilial("SB1")+SubStr(TCQ->C2_PRODUTO, 6, 5), "B1_LOCPAD"), "B2_LOCALIZ"))
                    If aMatEmp[nY][3] >= 30.0
                       cInkMak := '(InkMaker)'
                    Else
                       cInkMak := '          '
                    Endif
                 Else
                    If aMatEmp[nY][3] >= 20.0
                       cInkMak := '(InkMaker)'
                    Else
                       cInkMak := '(Impress.)'
                    Endif
                 Endif
              Else                                                            	
                 cInkMak := '          '
              Endif
           Endif
           If !Empty(cInkMak)
              //LGS#20200207 - Adequação de release 12.1.25 e posteriores
              //If Posicione("SB1", 1, xFilial("SB1")+aMatEmp[nY][1], "B1_GRUPO") $ Alltrim(GETMV("MV_GRPCONC"))
              If Posicione("SB1", 1, xFilial("SB1")+aMatEmp[nY][1], "B1_GRUPO") $ _cGRPCONC
                 oPrn:Say(nLin, nCol       , '                [      ]'+cLocPro+cInkMak     , oFont2, , , , )
              Else
                 oPrn:Say(nLin, nCol       , '                [      ]'+cLocPro                  , oFont2, , , , )
              Endif
           Else
              oPrn:Say(nLin, nCol       , '                [      ]'+cLocPro                  , oFont2, , , , )
           Endif
           oPrn:Say(nLin, nCol + 1050, Transform(aMatEmp[nY][3], "@E 999999.999")        , oFont2, , , , )      
           oPrn:Say(nLin, nCol + 1850, Transform(nPerFor, "@E 999.99%")                    , oFont2, , , , )
           oPrn:Say(nLin, nCol + 2200, aMatEmp[nY][2]                                      , oFont2, , , , )
           nLin += 50
           oPrn:Say(nLin, nCol       , '-------------------------------------------------------------------------------', oFont2, , , , )
           nLin += 60
           If aMatEmp[nY][4] > 0.0
              	nPerFor := Round((aMatEmp[nY][4] / nTotMat) * 100, 2)   
              	cDescr := ""
              	dbselectarea("SB1")
              	dbsetorder(1)
              	dbseek(xFilial("SB1")+aMatEmp[nY][1],.f.)
           		if found()
           			if (cNumEmp != "01010101") .OR. (SUBSTR(SB1->B1_GRUPO,1,1) == "E")
           				cDescr := SB1->B1_DESC
           			endif 
           		endif 
              	aadd(aAceCor, {aMatEmp[nY][1], cDescr, Round(aMatEmp[nY][4], 3), nPerFor})
           Endif
           nQtdTot += aMatEmp[nY][3]
       		If nLin >= nLinMax
          		AVNEWPAGE
          		nLin := 30
	           oPrn:Say(nLin, nCol       , '-------------------------------------------------------------------------------', oFont2, , , , )
    	       nLin += 60
       		Endif

       Next
       nLin += 40

       //Impressão do ACERTO DE COR
       If Len(aAceCor) > 0
          nLin += 40
          oPrn:Say(nLin, nCol +700, "A C E R T O S   D E   C O R E S", oFont2, , , , )
          nLin += 50
          oPrn:Say(nLin, nCol       , '-------------------------------------------------------------------------------', oFont2, , , , )
          nLin += 60
          For nY := 1 To Len(aAceCor)
              oPrn:Say(nLin, nCol + 0030, aAceCor[nY][1]                            , oFont2, , , , )
              oPrn:Say(nLin, nCol + 1050, Transform(aAceCor[nY][3], "@E 999999.999"), oFont2, , , , )  
              oPrn:Say(nLin, nCol + 1850, Transform(aAceCor[nY][4], "@E 999.99%")          , oFont2, , , , )
              nLin += 50
              oPrn:Say(nLin, nCol       , '-------------------------------------------------------------------------------', oFont2, , , , )
              nLin += 60
              nQtdTot += aAceCor[nY][3]
          Next
          oPrn:Line(nLin - 35, nCol      , nlin - 35, nColMax)
          oPrn:Say(nLin, nCol + 0030, "TOTAL"                                         , oFont2, , , , )
          oPrn:Say(nLin, nCol + 1050, Transform(nQtdTot, "@E 999999.999")+' Kg'       , oFont2, , , , )
          If Len(Alltrim(TCQ->C2_PRODUTO)) == 5
             oPrn:Say(nLin, nCol + 2000, Transform(_QtdSol / _PesEsp, "@E 99999.99")+' L', oFont3, , , , )
          Endif
          nLin += 60
       Else
          oPrn:Say(nLin, nCol + 0030, "TOTAL"                                         , oFont2, , , , )
          oPrn:Say(nLin, nCol + 1050, Transform(nQtdTot, "@E 999999.999")+' Kg'       , oFont2, , , , )
          If Len(Alltrim(TCQ->C2_PRODUTO)) == 5 .OR. Len(Alltrim(TCQ->C2_PRODUTO)) == 6 .OR. (Len(Alltrim(TCQ->C2_PRODUTO)) == 12 .AND. Substr(TCQ->C2_PRODUTO,11,2) $ '99')
             oPrn:Say(nLin, nCol + 2000, Transform(_QtdSol / _PesEsp, "@E 99999.99")+' L', oFont3, , , , )
          Endif
          nLin += 70
       Endif

	   DbSelectArea("SZZ")
	   DbSetOrder(1)
       DbSeek(xFilial("SZZ")+TCQ->C2_LOTE+TCQ->C2_PRODUTO)          
	   If Found() .AND. LEN(Alltrim(SZZ->ZZ_INFOP)) >0
	      oPrn:Line(nLin , nCol      , nlin, nColMax)
	  	  If 'F' $ SZZ->ZZ_INFOP   // tem fnc aberta
				oPrn:Say(nLin, nCol + 0030, "| FNC EM ABERTO |"    , oFont2, , , , )
		  Endif
		  If 'T' $ SZZ->ZZ_INFOP   // mais de 6 meses sem produzir
				oPrn:Say(nLin, nCol + 0550, "| PRODUTO COM MAIS DE 6 MSESES SEM PRODUÇÃO |", oFont2, , , , )
		  Endif
		  If 'P' $ SZZ->ZZ_INFOP // primeira produção
				oPrn:Say(nLin, nCol + 1600, "| 1º PRODUÇÃO |"                  , oFont2, , , , )
		  Endif
		  nLin += 70
          oPrn:Line(nLin, nCol      , nlin, nColMax)
       Endif

       DbSelectArea("SZZ")
       DbCloseArea()

       If nLin >= nLinMax
          AVNEWPAGE
          nLin := 30
          PCPR01_3(_NumOrd, _DatEmi, _QtdSol, _DesPro, _DesLin, _CodCat)
       Endif
       If Len(Alltrim(TCQ->C2_PRODUTO)) == 12 .and. SubStr(Alltrim(TCQ->C2_PRODUTO), 11, 2) $ '00.99'
          cMsgPDC := fBusPDC()
          oPrn:Say(nLin, nCol, '*******************************************************************************', oFont2, , , , )
          nLin += 50
          oPrn:Say(nLin, nCol, cMsgPDC, oFont2, , , , )
          nLin += 50
          oPrn:Say(nLin, nCol, '*******************************************************************************', oFont2, , , , )
          nLin += 60
       Endif
Return

Static Function fBusPDC()
       cChave := xFilial("SZM")+TCQ->C2_PRODUTO+SubStr(fBusURv(TCQ->C2_PRODUTO, .f.), 1, 3)
       DbSelectArea("SZM")
       DbSetOrder(1)
       DbSeek(cChave, .t.)
       If Found()
          //If SZM->ZM_PCREVIS $ 'S'
             DbSelectArea("SZ3")
             DbSetOrder(1)
             DbSeek(xFilial("SZ3")+SubStr(TCQ->C2_PRODUTO, 6, 5), .t.)
             If Found()
                DbSelectArea("ZZE")
                DbSetOrder(1)
                DbSeek(xFilial("ZZE")+SZ3->Z3_PADCOR, .t.)
                If Found()
                   If ZZE->ZZE_LIBERA $ 'S.R'
                      cRet := '***PADRÃO DE COR:'+ZZE->ZZE_DESCRI+'***'
                   Else
                      cRet := '***                 PADRÃO DE COR NÃO LIBERADO - VERIFIQUE!              CAD***'
                   Endif
                Else
                   cRet := '***                PADRÃO DE COR NÃO ENCONTRADO - VERIFIQUE!             CAD***'
                Endif
             Else
                cRet := '***                PADRÃO DE COR NÃO ENCONTRADO - VERIFIQUE!             VAR***'
             Endif
          //Else
          //   cRet := '***                 PADRÃO DE COR NÃO REVISADO - VERIFIQUE!              SIM***'
          //Endif
       Else
          cRet := '***                   FÓRMULA NÃO ENCONTRADA - VERIFIQUE!                SIM***'
       Endif
Return(cRet)

/**********************************************************************************************************/
/*** PCPR01_3 - Monta cabeçalho da Ordem de Produção - Tintas / Pastas                                  ***/
/**********************************************************************************************************/
Static Function PCPR01_3(_NumOrd, _DatEmi, _QtdSol, _DesPro, _DesLin, _CodCat)
//If _cPula = 1
       nVez    := Iif(Empty(_CodCat), 11, 13)
       cLogCor := ''
       //_CodEan := TCQ->C2_LOTE+'000000'         
       	if substr(cNumEmp,1,2) != '05' // substr(cNumEmp,1,4) $ "0101" 
	       	_CodEan := TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN+'0' //Iif(cNumEmp $ '0104' .and. SubStr(TCQ->C2_NUM, 1, 1) < '1', '1'+SubStr(TCQ->C2_NUM, 2, 5)+TCQ->C2_ITEM+TCQ->C2_SEQUEN+'0', TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN+'0') //TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN+'0'
		else
			_CodEan := ""				      
		endif	      
       //oPrn:Box(nLin, nCol      , nlin * nVez    , nColMax)
       oPrn:Line(nLin * nVez, nCol, nlin * nVez    , nColMax)
       oPrn:Say(nLin, nCol + 700, "ORDEM DE PRODUÇÃO: "+TCQ->C2_NUM, oFont1,,,,)
       oPrn:Say(nLin, nCol +1850, "Hora..:"+Time(), oFont4,,,,)
       If substr(cNumEmp,1,2) != '05'// substr(cNumEmp,1,4) $ "0101" 
        //MSBar3('INT25',  0.8,  2.2 , SUBSTR(_CodEan+EanDigito(_CodEan),1,13), oPrn, .F.,    , .T., 0.025 , 0.8, .F., 'TAHOMA', 'B', .F. )
          MSBAR("CODE128",  0.1,  1 , _CodEan+EanDigito(_CodEan), oPrn, NIL, NIL, NIL, Nil, 1, NIL, NIL, NIL, .f.) 
        //MSBAR("EAN13",  1,  2.5 , _CodEan+EanDigito(_CodEan), oPrn, NIL, NIL, NIL, Nil, 1, NIL, NIL, NIL, .f.)
       Else
          //MSBAR("CODE128",  1,  2.5 , _CodEan, oPrn, NIL, NIL, NIL, Nil, 1, NIL, NIL, NIL, .f.)
       Endif
       nLin += 110
       // jOSE 12/11/2024 acrescentado
       oPrn:Say(nLin, nCol + 0030, "EMISSÃO: "                                              , oFont2, , , , )
       oPrn:Say(nLin, nCol + 0280, DTOC(_DatEmi)                                            , oFont2, , , , )
       // Jose 12/11/2024 ate aqui
       oPrn:Say(nLin   , nCol + 0750, Iif(Len(Alltrim(TCQ->C2_PRODUTO)) == 12, Transform(TCQ->C2_PRODUTO, "@R XX 99.99.999-99"), TCQ->C2_PRODUTO), oFont3, , , , )
       oPrn:Say(nLin   , nCol + 1600, "QTDE. SOL.:"                                         , oFont2, , , , )
       oPrn:Say(nLin   , nCol + 2000, Transform(_QtdSol, "@E 99999.99")                     , oFont3, , , , )
       nLin += 60
       oPrn:Say(nLin, nCol + 0030, "ENTREGA: "                                              , oFont2, , , , ) // Jose 12/11/2024 "EMISSÃO: "
       oPrn:Say(nLin, nCol + 0280, DTOC(_DATPRF)                                            , oFont2, , , , ) // Jose 12/112024  DTOC(_DatEmi)
       oPrn:Say(nLin, nCol + 0750, SubStr(Alltrim(_DesPro), 1, 25)                          , oFont3, , , , )
       oPrn:Say(nLin, nCol + 1600, SubStr(Iif(!Empty(_DesLin), Alltrim(_DesLin), ''), 1, 24), oFont2, , , , )
       nLin += 60
       If !Empty(_CodCat)
          oPrn:Say(nLin, nCol + 0030, "CATALIS.:"                                           , oFont2, , , , )
          oPrn:Say(nLin, nCol + 0310, _CodCat                                               , oFont2, , , , )
          nLin += 60
       Endif
       oPrn:Say(nLin, nCol + 0030, "REVISÃO: "                                              , oFont2, , , , )
       oPrn:Say(nLin, nCol + 0280, fBusURv(TCQ->C2_PRODUTO, .f., @cLogCor)                  , oFont2, , , , )
       oPrn:Say(nLin, nCol + 1900, "LOTE: "                                                 , oFont2, , , , )
       oPrn:Say(nLin, nCol + 2100, TCQ->C2_LOTE                                             , oFont3, , , , )
       oPrn:Say(nLin+70, nCol       , cLogCor                                               , oFont3, , , , )
       nLin += 140
       oPrn:Say(nLin, nCol + 0030, "MATERIA PRIMA     LOTE   QTDE. MAT. PRIMA (Kg)        PERC. MAT.PRIMA    SEQ", oFont2, , , , )
       nLin += 60
       oPrn:Line(nLin, nCol      , nlin, nColMax)
//EndIf 
Return

/**********************************************************************************************************/
/*** fBusURv - Busca informações da ultima revisão do Produto                                           ***/
/**********************************************************************************************************/
Static Function fBusURv(cCodigo, lOpc, cLogCor)
       Local cRet  := ""
       Local lCont := .t.
       Local _nX
       DbSelectArea("SZM")
       DbSetOrder(3)
       DbSeek(xFilial("SZM")+cCodigo,.t.)
       If Found()
          While !Eof() .and. lCont
                If SZM->ZM_STATUS == 'AC'
                   If lOpc
                      cRet  := SZM->ZM_REVISAO+" - VIG.: "
                   Else
                      cRet  := SZM->ZM_REVISAO+" - VIGÊNCIA: "
                   Endif
                   cRes  := SZM->ZM_RESPONS
                   cId   := SZM->ZM_ID
                   lCont := .f.
                Endif
                DbSkip()
          Enddo
          lCont := .t.
          DbSelectArea("SZT")
          DbSetOrder(1)
          DbSeek(xFilial("SZT")+cId,.t.)
          If Found()
             While !Eof() .and. lCont
                   If SZT->ZT_STATUS == 'AC'
                      cRet += DTOC(SZT->ZT_DATAGER)
                      lCont := .f.
                   ElseIf SZT->ZT_STATUS == 'EE'
                          cLog    := SZT->ZT_LOG
                          cLinLog := MlCount(cLog)
                          For _nX := 1 To cLinLog
                              If Alltrim(Upper(MEMOLINE(cLog, 80, _nX))) $ 'COR'
                                 cLogCor := 'COR AJUSTADA'
                              Endif
                          Next
                   Endif
                   DbSkip()
             Enddo
          Endif
          If lOpc
             cRet += ' RESP.: '+Iif(Alltrim(Upper(cRes)) $ 'ADMINISTRADOR' , 'IMPLANTAÇÃO', cRes)
          Else
             cRet += ' RESPONSÁVEL: '+Iif(Alltrim(Upper(cRes)) $ 'ADMINISTRADOR' , 'IMPLANTAÇÃO', cRes)
          Endif
       Endif
Return(cRet)

/**********************************************************************************************************/
/*** PCPR01_1 - Busca informações conforme parâmetros no Banco de Dados                                  ***/
/**********************************************************************************************************/
Static Function PCPR01_1()
       Local cCond    := ""
       Local cQuery   := ""

       If !Empty(mv_par02) .and. (mv_par02 >= mv_par01)
          cCond += " AND (SC2.C2_EMISSAO  BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"') "
       Endif
       If !Empty(mv_par04) .and. (mv_par04 >= mv_par03)
          cCond += " AND (SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN) BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
       Endif
       If !Empty(mv_par06) .and. (mv_par06 >= mv_par05)
          cCond += " AND (SC2.C2_LOTE BETWEEN '"+mv_par05+"' AND '"+mv_par06+"')"
       Endif

       //Cleber(17-03-15)-> Mudei pra trazer apenas 1 registro no máximo e também pegando somente o SC2.R_E_C_N_O_, estava 
       //como SC2.* para melhorar a performance pois essa consulta é somente pra saber se existe alguma OP.
       cQuery += " SELECT C2_FILIAL,C2_PRODUTO,C2_QUANT,C2_NUM,C2_ITEM,C2_SEQUEN,C2_PEDIDO,C2_LOTE,C2_EMISSAO,C2_ROTEIRO,C2_OBS,C2_UM,C2_REVI, C2_DATPRF " // 12/11/20204 , C2_DATPRF
       cQuery += " FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
       cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (C2_PRODUTO = B1_COD) "
       cQuery += " WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
       cQuery += "   AND (SC2.D_E_L_E_T_ <> '*') "
       cQuery += "   AND (SC2.C2_ITEM    IN('01', '02')) AND (((B1_TIPO = 'PI') AND (LEN(B1_COD) = 12)) OR (LEN(B1_COD) <> 12)) "
       cQuery += "   AND (SC2.C2_XFLAG <> 'S') "  // NÃO IMPRIMIR OPS QUE JÁ FORAM IMPRESSAS  
       cQuery += cCond 
       cQuery := cQuery + " ORDER BY SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN "
	    //Cleber (16-09-2015) -> tá dando erro de alias já aberto anteriormente!
	   If Select("TCQ") <> 0
	       DbCloseArea()
	   Endif 
      TCQuery cQuery NEW ALIAS "TCQ"
    
	//cQuery += "  AND SC2.C2_LOCAL  BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "             retirado p/ impressão ser direta, sem escolha de almoxarifado padrao
Return

/**********************************************************************************************************/
/*** VldPerg - Monta perguntas na tabela SX1                                                            ***/
/**********************************************************************************************************/
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*
Static Function VldPerg()
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs,{cPerg,"01","Da Emissao     ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"02","Ate Emissao    ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"03","Da Ordem Prod. ?","","","mv_ch3","C",11,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SC2",""})
       AADD(aRegs,{cPerg,"04","Ate Ordem Prod.?","","","mv_ch4","C",11,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SC2",""})
       AADD(aRegs,{cPerg,"05","Do Lote        ?","","","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"06","Ate Lote       ?","","","mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"07","Operacoes      ?","","","mv_ch7","N",01,0,0,"C","","mv_par07","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"08","Descr. Processo?","","","mv_ch8","N",01,0,0,"C","","mv_par08","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"09","Inspecao C.Q.  ?","","","mv_ch9","N",01,0,0,"C","","mv_par09","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",""})

  //     AADD(aRegs,{cPerg,"01","Do Almoxarifado   ?","","","mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","",""})
  //     AADD(aRegs,{cPerg,"02","Ate Almoxarifado  ?","","","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","",""})

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

       DbSelectArea(_sAlias)

Return*/

Static Function fQtdPas(cCodPro)
       Local cQry1   := ""
       Local nPerPas := 0
       Local aCodOut := {}
       
       cQry1 += "SELECT SUM(SG1.G1_PERC) AS G1_PERC "
       cQry1 += "FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.B1_FILIAL = '"+xFilial("SB1")+"') AND SG1.G1_COMP = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SG1.G1_FILIAL  = '"+xFilial("SG1")+"' "
       cQry1 += "  AND SG1.D_E_L_E_T_ = '' "
       cQry1 += "  AND SG1.G1_COD     = '"+cCodPro+"' "
       cQry1 += "  AND (SB1.B1_DESC LIKE('%PASTA%') OR SB1.B1_GRUPO = '"+Alltrim(GETMV("MV_GRPCONC"))+"') "
       TCQuery cQry1 ALIAS "TPER" NEW
       DbSelectArea("TPER")
       nPerPas := (TPER->G1_PERC / 100)

       DbSelectArea("TPER")
       DbCloseArea()
       cCodOut := ""
       cQry1 := ""
       cQry1 += "SELECT SG1.G1_COMP AS G1_COMP, SG1.G1_PERC AS G1_PERC "
       cQry1 += "FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.B1_FILIAL = '"+xFilial("SB1")+"') AND SG1.G1_COMP = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SG1.G1_FILIAL  = '"+xFilial("SG1")+"' "
       cQry1 += "  AND SG1.D_E_L_E_T_ = '' "
       cQry1 += "  AND SG1.G1_COD     = '"+cCodPro+"' "
       cQry1 += "  AND (SB1.B1_DESC NOT LIKE('%PASTA%') AND SB1.B1_GRUPO <> '"+Alltrim(GETMV("MV_GRPCONC"))+"') "
       TCQuery cQry1 ALIAS "TPER" NEW
       DbSelectArea("TPER")
       While !Eof()
            // produto de custeio
            If U_IsProdCusto(TPER->G1_COMP)
               TPER->(dbSkip())
               Loop
            Endif   

             cCodOut += Alltrim(TPER->G1_COMP)+' / '
             aAdd(aCodOut, {TPER->G1_COMP, TPER->G1_PERC, 0} )
             DbSelectArea("TPER")
             DbSkip()
       Enddo
       DbSelectArea("TPER")
       DbCloseArea()
       cCodOut := SubStr(cCodOut, 1, Len(cCodOut)-3)
Return({nPerPas, cCodOut, aCodOut})
