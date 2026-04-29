#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'INKEY.CH'
#INCLUDE 'vkey.CH' 
/*************************************************************************************************/
/*** 000000   F U N Ç Õ E S   D E   C H A M A D A   D A S   T E L A S    P R I N C I P A I S   ***/
    /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
    ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
    ±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
    ±±³Programa  ³ BRPCPA09 ³ Autor ³ Luís G. de Souza      ³ Data ³ 30/06/10 ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Locacao   ³                  ³Contato ³                                ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Descricao ³ Gera arquivo TXT para Ordens de produção.                  ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Parametros³ 0101 - Empresa+Filial                                      ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Retorno   ³                                                            ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Aplicacao ³                                                            ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Uso       ³                                                            ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³Analista Resp.³  Data  ³                                               ³±±
    ±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
    ±±³              ³  /  /  ³                                               ³±±
    ±±³              ³  /  /  ³                                               ³±±
    ±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
    ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
    User Function ZPCPA06(_cParam)

     Local _oSay1Loc, _oSay2Loc, _oLayer, _oApontamento
     Local _oSize        := FWDefSize():New(.F.)
     Private _oFontApt    := TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
     Private _oFontLeg    := TFont():New( "MS Sans Serif", 0, -12, , .T.) 
     Private _oDlgApt
     Private _cGet1Ord    := Space(11)
     Private _oGet1Ord
     Private _oGetGer01, _oGetGer02, _oGetGer03, _oGetGer04, _oGetGer05, _oGetGer06, _oGetGer07
     Private _oGetIte01, _oGetIte02, _oGetIte03, _oGetIte04
     Private _oBtnDApt, _oBtPeso
     Private _lSair       := .f.
     Private _aRotApt     := { }
     Private _aBrwIte     := { }
     Private _aBrwRes     := { }
     Private _oPreto      := LoadBitmap( GetResources(), 'BR_PRETO'   ) //Não iniciada
     Private _oVerde      := LoadBitmap( GetResources(), 'BR_VERDE'   ) //Iniciada
     Private _oAmarelo    := LoadBitmap( GetResources(), 'BR_AMARELO' ) //Pausada
     Private _oVermelho   := LoadBitmap( GetResources(), 'BR_VERMELHO') //Finalizada
     Private _oAzul       := LoadBitmap( GetResources(), 'BR_AZUL'    ) //Conferência
     Private _cMVBLQOPSA, _cMVXLIBOPE, _lZPPAR9999, _cMVXHABZZ
     /*+-----------------------------------------------------+
       | Abertura de Empresa                                 |
       +-----------------------------------------------------+*/

     If Empty( _cParam )
        _cParam := '010101011'
     Endif
     OpenSm0( SubStr( _cParam, 1, 2 ) )
     DbSelectArea('SM0')
     SM0->( DbSetOrder( 1 ) )
     SM0->( DbSeek( SubStr( _cParam, 1, 8 ) ) )
     
     PREPARE ENVIRONMENT EMPRESA SubStr( _cParam, 1, 2 ) FILIAL SubStr( _cParam, 3, 6 ) MODULO 'PCP'

     _cFabrica    := Iif( !Empty( SubStr( _cParam, 9 ) ), 'FABRICA - ' + SubStr( _cParam, 9 ), '' )
     _aFabrica    := GetStringPixSize( _cFabrica, "MS Sans Serif", -19, .T. )
     _cNFilial    := Alltrim( SM0->M0_FILIAL )
     _aNFilial    := GetStringPixSize( _cNFilial, "MS Sans Serif", -19, .T. )
     _cMVBLQOPSA  := Alltrim( GETMV( "MV_BLQOPSA" ) )
     _cMVXLIBOPE  := GetMv("MV_XLIBOPE")
     _lZPPAR9999  := GetMv( "ZP_PAR0024" , .F. , .F. ) //Parametro que indica se faz debug na pesagem da balança para correção de problemas
     _cMVXHABZZ   := getMV("MV_XHABZZF")
     _lMVVEREST   := Alltrim(GETMV("MV_VERESTI")) $ 'S'

     /*+-----------------------------------------------------+
       | Teste para montagem de conexão com o Banco de dados |
       +-----------------------------------------------------+*/
     _oSize:lLateral := .F.
     _oSize:AddObject( "LAYER", 100, 100, .T., .T. )
     DEFINE DIALOG _oDlgApt TITLE "Apontamento de produção v.01/2020" FROM 0, 0 TO 480, 300 STYLE nOr( WS_VISIBLE, WS_POPUP ) PIXEL
            _oLayer       := FWLayer():New()
            _oLayer:Init( _oDlgApt, .F. )
            _oLayer:AddLine( "LINE01", 100) 
            _oLayer:AddCollumn( "BOX_UNICO", 100, , "LINE01")           
            _oLayer:AddWindow( "BOX_UNICO", "PANEL01", "Apontamento de produção v.01/2020"     , 100, .F., , , "LINE01" )
            _oApontamento := _oLayer:GetWinPanel( "BOX_UNICO", "PANEL01", "LINE01" )

            _oGet1Ord   := TGet():New( 002, 002, {|u| If(PCount() > 0, _cGet1Ord := u, _cGet1Ord ) }, _oApontamento, 100, 013, '@!R XXXXXX-99-999', { || Iif( !Empty( _cGet1Ord ) .and. Len(Alltrim(_cGet1Ord)) <= 11, fVerOrdPro(), ) }, CLR_BLACK, CLR_WHITE, _oFontApt, .F., , .T.,  ,    , ,    ,    , , .F., .F.,   , _cGet1Ord, , , , , , , 'Informe o numero da OP', 1, _oFontApt, CLR_BLUE, '<Ordem de produção>', .T.)

            _oSay1Loc     := TSay():New( _oApontamento:nClientHeight * 0.20, ( _oApontamento:nWidth * 0.25 ) - ( _aFabrica[2] * 0.5 ), {|| _cFabrica }, _oApontamento, , _oFontApt, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, _aFabrica[2], 036, , , , , , , 2, 2 )
            _oSay2Loc     := TSay():New( _oApontamento:nClientHeight * 0.25, ( _oApontamento:nWidth * 0.25 ) - ( _aNFilial[2] * 0.5 ), {|| _cNFilial }, _oApontamento, , _oFontApt, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, _aNFilial[2], 036, , , , , , , 2, 2 )

            _oBtnDApt   := TButton():New( 234, 108, "Sair", _oDlgApt, { | | _oDlgApt:End() }, 037, 012, , , .F., .T., .F., "", .F., , , .F. )
            _oBtnDApt:bAction  := {|| fAptSaiVol(1)}
            _oGet1Ord:SetFocus( )

     ACTIVATE DIALOG _oDlgApt CENTERED

Return

    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fVerOrdPro() - Verifica Ordem de Produção e abre botões para apontamento
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fVerOrdPro()
           Local cQry1    := ""
           Local lRetorna := .f.
           Local nX
           Private cEOL   := CHR(13)+CHR(10)
           If Empty(_cGet1Ord)
              Return(.t.)
           Else
              If Len(Alltrim(_cGet1Ord)) == 6
                 _cGet1Ord := AllTrim(_cGet1Ord)+'01001'
              ElseIf Len(Alltrim(_cGet1Ord)) == 11
                 _cGet1Ord := SubStr(_cGet1Ord, 1, 11)
              Endif
           Endif
           /*********************************************/
           /***  MONTA CONEXÃO COM O BANCO DE DADOS   ***/
           /*********************************************/
           cQry1 := ""
           cQry1 += "SELECT SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_LOTE, SC2.C2_PRODUTO, SC2.C2_QUANT, SC2.C2_DATRF, SC2.C2_ROTEIRO, SB1.B1_TIPO, SB1.B1_ESTOQUE, SB1.B1_PESOESP, SB1.B1_DESC, SC2.C2_EMISSAO "
           cQry1 += "FROM " + RetSQLName('SC2') + " SC2 WITH(NOLOCK) "
           cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = SC2.C2_FILIAL AND SB1.B1_COD = SC2.C2_PRODUTO AND SB1.D_E_L_E_T_ = '' "
           cQry1 += "WHERE SC2.C2_FILIAL  = '"+SM0->M0_CODFIL+"' "
           cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
           cQry1 += "  AND SC2.C2_NUM     = '"+SubStr(_cGet1Ord, 1, 6)+"' "
           cQry1 += "  AND SC2.C2_ITEM    = '"+SubStr(_cGet1Ord, 7, 2)+"' "
           cQry1 += "  AND SC2.C2_SEQUEN  = '"+SubStr(_cGet1Ord, 9, 3)+"' "
           TCQuery cQry1 ALIAS "TCQ" NEW
           DbSelectArea("TCQ")
           If Empty(TCQ->C2_NUM)
              //MsgStop('Ordem de produção inexistente')
              MessageBox("Ordem de produção inexistente.", "Atenção...",48)
              lRetorna := .t.
           Else
              If !Empty(TCQ->C2_DATRF)
                 MsgStop("Ordem de produção já foi finalizada!")
                 lRetorna := .t.
              Else
                 If TCQ->B1_TIPO $ 'PI'
                    aGerTxt := {}
                    aAdd(aGerTxt, {TCQ->C2_PRODUTO, TCQ->C2_LOTE, TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN, TCQ->C2_EMISSAO, TCQ->C2_QUANT })
                 Else
                    MessageBox("Ordem de produção para esse produto não pode ter o arquivo gerado", "Atenção...",48)
                    lRetorna := .t.
                 Endif
              Endif
              DbSelectArea("TCQ")
              DbCloseArea()
              If lRetorna
                 _oGet1Ord:SetFocus()
                 _cGet1Ord := space(11)
                 _oGet1Ord:Refresh()
                 Return(.f.)
              Else
                 /********************************************************************************************************************/
                 //Dados genéricos para as duas fábricas
                 lExiste   := .f.
                 lNaoGer   := .f.
                 cDescri := Posicione("SB1", 1, xFilial("SB1")+aGerTXT[1][1], "B1_DESC")
                 aQtdMat := {} ; aVolMat := {}
                 aCodMat := {}
                 aadd(aQtdMat, { 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0})
                 aadd(aCodMat, {"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
                 aadd(aVolMat, { 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0})
                 aMatIte := {}
                 nPos    := 1
                 DbSelectArea("SD4")
                 DbSetOrder(2)
                 DbSeek(xFilial("SD4")+aGerTxt[1][3], .t.)
                 If Found()
                     While !Eof() .and. Alltrim(SD4->D4_OP) == Alltrim(aGerTxt[1][3])
                         /*
                         If nPos <= 20
                            If !Alltrim(SD4->D4_COD) $ Alltrim(GETMV("MV_RETENOP"))
                               aAdd(aMatIte, {SD4->D4_QUANT, Alltrim(SD4->D4_COD), SD4->D4_QUANT / Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_PESOESP") } )
                               //aQtdMat[1][nPos] := SD4->D4_QUANT
                               //aCodMat[1][nPos] := Alltrim(SD4->D4_COD)
                               //aVolMat[1][nPos] := SD4->D4_QUANT / Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_PESOESP")
                               nPos += 1
                               If Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_DOSADOR") $ 'S'
                                  lExiste := .t.
                               Endif
                            Endif
                         Endif

                         DbSelectArea("SD4")
                         DbSkip() */
                         If nPos <= 20
	                         If Substr(Posicione("SC2", 1, xFilial("SC2")+SD4->D4_OP, "C2_PRODUTO"),6,2) =='05' .and. Len(Alltrim(Posicione("SC2", 1, xFilial("SC2")+SD4->D4_OP, "C2_PRODUTO")))==12
		                        If !Posicione("SB1", 1, xFilial("SB1")+Alltrim(SD4->D4_COD), "B1_DESC") $ 'PASTA' .and. SD4->D4_QUANT >= 0.2  .AND. !U_IsProdCusto( SD4->D4_COD )
			                        aAdd(aMatIte, {SD4->D4_QUANT, Alltrim(SD4->D4_COD), SD4->D4_QUANT / Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_PESOESP") } )
    			                    //aQtdMat[1][_nPos] := SD4->D4_QUANT
        			                //aCodMat[1][_nPos] := Alltrim(SD4->D4_COD)
            			            //aVolMat[1][_nPos] := SD4->D4_QUANT / Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_PESOESP")
                			        nPos += 1
                             
		                	        If Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_DOSADOR") $ 'S'
    		                           lExiste := .t.
	        	              	    Endif
	        	              	Endif
    	    	             Else
                            If !U_IsProdCusto( SD4->D4_COD )
			                    aAdd(aMatIte, {SD4->D4_QUANT, Alltrim(SD4->D4_COD), SD4->D4_QUANT / Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_PESOESP") } )
	             		        nPos += 1
    	            	        If Posicione("SB1", 1, xFilial("SB1")+SD4->D4_COD, "B1_DOSADOR") $ 'S'
   	    	            	       lExiste := .t.
       	    	                Endif
                            Endif
	        	             Endif
                         Endif
                         DbSelectArea("SD4")
                         DbSkip() 
                     Enddo
                 Endif
                 nPos    := 1
                 aSort(aMatIte, , , { | x, y | x[3] > y[3] } )
                 For nX := 1 To Len(aMatIte)
                     If nPos <= 20
                        aQtdMat[1][nPos] := aMatIte[nX][1]
                        aCodMat[1][nPos] := aMatIte[nX][2]
                        aVolMat[1][nPos] := aMatIte[nX][3]
                        nPos += 1
                     Endif
                 Next
                 nQtdMat := 0
                 For nX := 1 To 20
                     nQtdMat += aQtdMat[1][nX]
                 Next
                 If nQtdMat <= 0
                    lNaoGer := .t.
                 Endif
                 If !lExiste
                    lNaoGer := .t.
                 Endif
                 If !lNaoGer
                    cProduto := aGerTxt[1][1]
                    cCatalis := Posicione("SB1", 1, xFilial("SB1")+aGerTXT[1][1], "B1_CATALIS")
                    dEmissao := DTOC(Stod(aGerTxt[1][4]))
                    nVolume  := aGerTxt[1][5]
                    nPeso    := aGerTxt[1][5] * Posicione("SB1", 1, xFilial("SB1")+aGerTXT[1][1], "B1_PESOESP")
                    cNumOrd  := aGerTxt[1][3]
                    cNumLot  := aGerTxt[1][2]
                    /********************************************************************************************************************/
                    //If cParInf5 $ '2'
                       cPatGer := 'C:\DADOS\OP\'+SubStr(aGerTxt[1][3], 1, 6)+".DAT"
                       lContinua := .t.
                       If FILE(cPatGer)
                          If MsgYesNo("Essa Ordem de produção já tem o arquivo gerado. Sobrepõe?")
                             lContinua := .t.
                          Else
                             lContinua := .f.
                          Endif
                       Else
                          lContinua := .t.
                       Endif
                       If lContinua
                          /******************************************************************/
                          /*** MONTAGEM DO ARQUIVO TEXTO                                  ***/
                          /******************************************************************/
                          /*** Linha 1 - Código do Produto ***/
                          cLinMes := ""
                          cFab2   := ""
                          cCpoMes := Alltrim(cProduto)
                          cLinMes := Stuff(cLinMes, 001, 040, cCpoMes)+cEol
                          cFab2   += cLinMes
                          /*** Linha 2 - Descrição do produto ***/
                          cLinMes := ""
                          cCpoMes := PADR(cDescri, 040)
                          cLinMes := Stuff(cLinMes, 001, 040, cCpoMes)+cEol
                          cFab2   += cLinMes
                          /*** Linha 3 - Peso ***/
                          cLinMes := ""
                          cCpoMes := Alltrim(Stuff(TransForm(nPeso, "@E 99999.999999"), At(",", TransForm(nPeso, "@E 99999.999999")), 1, "."))
                          cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), cCpoMes)+cEol
                          cFab2   += cLinMes
                          /*** Linha 4 - Volume ***/
                          cLinMes := ""
                          cCpoMes := Alltrim(Stuff(TransForm(nVolume, "@E 99999.999999"), At(",", TransForm(nVolume, "@E 99999.999999")), 1, "."))
                          cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), cCpoMes)+cEol
                          cFab2   += cLinMes
                          /*** Linha 5 - Materias Primas ***/
                          For nX := 1 To 20
                              cLinMes := ""
                              cCpoMes := ""
                              If !Empty(aCodMat[1][nX])
                                 cCpoMes := Alltrim(aCodMat[1][nX])+' '
                              Else
                                 cCpoMes := " "
                              Endif
                              cCpoMes := PADR(Alltrim(cCpoMes), Len(Alltrim(cCpoMes)))
                              cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), cCpoMes)+cEol
                              cFab2   += cLinMes
                          Next
                          /*** Linha 25 - Quantidades de matérias primas ***/
                          cLinMes := ""
                          cCpoMes := ""
                          For nX := 1 To 20
                              cCpoMes += Alltrim(Stuff( TransForm(Round(aQtdMat[1][nX], 3), "@E 99999.999999"), At(",", TransForm(Round(aQtdMat[1][nX], 3), "@E 99999.999999")), 1 , "."))+' '
                          Next
                          cCpoMes := PADR(Alltrim(cCpoMes), Len(Alltrim(cCpoMes)))
                          cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), Alltrim(cCpoMes))+cEol
                          cFab2   += cLinMes
                          /*** Linha 26 - Quantidades de matérias primas com valor negativo ***/
                          cLinMes := ""
                          cCpoMes := ""
                          For nX := 1 To 20
                              cCpoMes += Alltrim(Stuff( TransForm((Round(aQtdMat[1][nX], 3) * (-1)), "@E 99999.999999"), At(",", TransForm((Round(aQtdMat[1][nX], 3) * (-1)), "@E 99999.999999")), 1 , "."))+' '
                          Next
                          cCpoMes := PADR(Alltrim(cCpoMes), Len(Alltrim(cCpoMes)))
                          cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), Alltrim(cCpoMes))+cEol
                          cFab2   += cLinMes
                          MemoWrit(cPatGer, cFab2)
                       Endif
                    //Endif
                 Else
                    cPatGer := 'C:\DADOS\OP\NOVA\'+SubStr(aGerTxt[1][3], 1, 6)+".DAT"
                    If FILE(cPatGer)
                       If MsgYesNo("Essa Ordem de produção já tem o arquivo gerado. Sobrepõe?")
                          MsgStop("Rotina não desenvolvida")
                       Endif
                    Endif
                 Endif
                 
              Endif
           Endif
           fAptSaiVol(2)
    Return
    
    /*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Function  ³ fAptSaiVol() - Verifica saida da ordem de produção ou volta para tela principal
    ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Static Function fAptSaiVol(nOpcApt)
           If nOpcApt == 1
              _oDlgApt:End()
           ElseIf nOpcApt == 2
                  _cGet1Ord := space(11)
                  _oGet1Ord:SetFocus()
                  _oGet1Ord:Refresh()
                  _oBtnDApt:cCaption := "Sair"
                  _oBtnDApt:bAction  := {|| fAptSaiVol(1)}
                  _oBtnDApt:Refresh()
                  _oGet1Ord:lReadOnly := .f.
                  _oGet1Ord:Refresh()
           Endif
    Return
