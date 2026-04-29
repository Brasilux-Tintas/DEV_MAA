#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} ZFATC10
Consulta Politica Comercial x Tabela de Frete
@type function
@version  v2023.06
@author Luís Gustavo Souza
@since 13/06/2023
@param _cNumPed, variant, Numero do pedido de vendas
/*/
User Function ZFATC10( _cNumPed )

   FWMsgRun(Nil, {|| ZFATC10(_cNumPed) }, "Calculo de Frete", "Calculando, Aguarde...")

Return()

Static Function ZFATC10(_cNumPed)
     Local _nVlrTot  := 0
     Local _aDadosP  := {}
     Local _aHeader  := {}
     Local _aCols    := {}
     Local _aButtons := {}
     Local _oFont1   := TFont():New( 'Courier new',          ,         -16,          , .T. )
     Local _nPosPrT  := 0
     Local _nY       := 0
     Local _nTotPrT  := 0
     Local _cTTabPo  := '1' //Tipo da Tabela de Politica
     //Local _cTTabCo  := '2' //Tipo da Tabela de Comissão
     Local _cCodPol  := '1' //Tipo de ICMS 1=7%, 2=12%, 3=18%
     Local _nDesMin  := 0

     // variaveis para o calculo do Frete
     Local Dif
     Local Var1,Var2,Var3,Var4
     Local vlFrete

     If SC5->C5_TPFRETE == 'C'

         //_aDadosP := fPlaFin( )
         _aDadosP := RET_ICMS()
        _nVlrTot := _aDadosP[1]
        _aHeader := _aDadosP[2]
        _aCols   := _aDadosP[3]
        _nPosPrT := aScan( _aHeader, { |x| Alltrim( x[2] ) == 'C6_X_PRCTA' } )
        _nPosQtV := aScan( _aHeader, { |x| Alltrim( x[2] ) == 'C6_QTDVEN'  } )

       For _nY := 1 To Len( _aCols )
           _nTotPrT += _aCols[_nY][_nPosQtV] * _aCols[_nY][_nPosPrT]
       Next
        DbSelectArea("SA1")
        SA1->( DbSetOrder( 1 ) )
        SA1->( DbSeek( xFilial("SA1") + SC5->C5_CLIENT ) )

        DbSelectArea("Z15")
        Z15->( DbSetOrder( 3 ) )
        If Z15->( DbSeek( xFilial("Z15") + SA1->A1_COD_MUN + Iif( SC5->C5_DEPOSI <> 'S', SC5->C5_TRANSP, SC5->C5_REDESP ) ) )
           _nVLRFPE := Z15->Z15_VLRFPE
           _nPESLIM := Z15->Z15_PESLIM
           _nVLREXC := Z15->Z15_VLREXC
           _nGRIS   := Z15->Z15_GRIS
           _nPEDAGI := Z15->Z15_PEDAGI
           _nSECCAT := Z15->Z15_SECCAT
           _nSEGURO := Z15->Z15_SEGURO
           _nTAS    := Z15->Z15_TAS
        Else
           MessageBox( 'Aviso, não encontrada tabela de frete para cidade x transportadora/redespacho não encontrada. ' + CHR(13) + CHR(10) + 'Verifique com o departamento de transporte.', 'Atenção', 64 )
           _nVLRFPE := 0
           _nPESLIM := 0
           _nVLREXC := 0
           _nGRIS   := 0
           _nPEDAGI := 0
           _nSECCAT := 0
           _nSEGURO := 0
           _nTAS    := 0
        Endif
        _nPesBru := SC5->C5_PBRUTO
        _nFrt100 := _nVLRFPE
        _nFrtExc := Iif( _nPesBru <= _nPESLIM, 0, _nPesBru - _nPESLIM ) * _nVLREXC
        
        _nVlrFrt := _nFrt100 + _nFrtExc
        // Incluido por Nelieder em 19/06/2023 ICMS MT
        _nVlrFrt := ROUND((_nVlrFrt/0.93),2)
        
        _nVlrGRI := ( _nVlrTot * ( _nGRIS / 100 ) ) / 0.93
        _nVlrPed := ( _nPesBru * _nPEDAGI ) / 0.93
        _nVlrSEC := _nSECCAT / 0.93
        _nVlrSeg := ( _nVlrTot * ( _nSEGURO / 100 ) ) / 0.93
        _nVlrTAS := _nTAS / 0.93
        _nTOTFRT := _nVlrFrt + _nVlrGRI + _nVlrPed + _nVlrSEC + _nVlrSeg + _nVlrTAS

        DbSelectArea('ZAD')
        ZAD->( DbSetOrder( 1 ) )
        If ZAD->( DbSeek( xFilial("ZAD") + _cTTabPo + _cCodPol ) )
           While !Eof() .and. ZAD->ZAD_TPTAB == _cTTabPo .and. ZAD->ZAD_TPEST == _cCodPol
                 If _nTotPrT >= ZAD->ZAD_FXDE .and. _nTotPrT <= ZAD->ZAD_FXATE
                    _nDesMin := ZAD->ZAD_DESC1
                 Endif
                 ZAD->( DbSkip( ) )
           EndDo
        Endif
        _nFDesPed := _nTotPrT * ( _nDesMin / 100 )
        _nFTotDes := _nTotPrT - _nFDesPed
        _nFVlrImp := ( ( 9.25 +  7 ) / 100 ) * _nFTotDes
        _nFVlrCom := ( ( 5 ) / 100 ) * _nFTotDes
        _nFVlrLiq := _nFTotDes - _nFVlrImp - _nFVlrCom

        oModal := FWDialogModal():New()
        oModal:SetEscClose( .F. )
        oModal:setTitle( "Simulação Frete CIF x Politica Comercial - " + SA1->A1_EST )
        oModal:setSize( 200, 525 )
        oModal:createDialog()

        aAdd( _aButtons, { "", 'Sair' , {|| oModal:DeActivate() }, , , .T., .F. } )
        oModal:addButtons( _aButtons )

        oContainer := TPanel():New( ,,, oModal:getPanelMain() )
        oContainer:Align := CONTROL_ALIGN_ALLCLIENT

        


        oGrp1 := TGroup():New( 001, 003, 154, 170, 'Calculo padrão Frete CIF', oContainer, , , .T. )
        oSay11  := TSay():New( 008, 004, { || 'Valor Total NF...:' }, oGrp1, , _oFont1, , , , .T., CLR_RED  , CLR_WHITE, 100, 10 )
        oSay12  := TSay():New( 018, 004, { || 'Peso KG..........:' }, oGrp1, , _oFont1, , , , .T., CLR_RED  , CLR_WHITE, 100, 10 )
        oSay13  := TSay():New( 040, 004, { || 'Frete até 100 KG.:' }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSay14  := TSay():New( 050, 004, { || 'Frete Excedente..:' }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSay15  := TSay():New( 072, 004, { || 'Valor Frete......:' }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSay16  := TSay():New( 082, 004, { || 'GRIS.............:' }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSay17  := TSay():New( 092, 004, { || 'Pedágio..........:' }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSay18  := TSay():New( 102, 004, { || 'SEC/CAT..........:' }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSay19  := TSay():New( 112, 004, { || 'Seguro...........:' }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSay1A  := TSay():New( 122, 004, { || 'TAS..............:' }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSay1B  := TSay():New( 144, 004, { || 'TOTAL FRETE......:' }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSayF1  := TSay():New( 008, 095, { || Transform( _nVlrTot, '@E 999,999,999.99' ) }, oGrp1, , _oFont1, , , , .T., CLR_RED  , CLR_WHITE, 100, 10 )
        oSayF2  := TSay():New( 018, 095, { || Transform( _nPesBru, '@E ###,#99,999.99' ) }, oGrp1, , _oFont1, , , , .T., CLR_RED  , CLR_WHITE, 100, 10 )
        oSayF3  := TSay():New( 040, 095, { || Transform( _nFrt100, '@E ###,#99,999.99' ) }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSayF4  := TSay():New( 050, 095, { || Transform( _nFrtExc, '@E ###,#99,999.99' ) }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSayF5  := TSay():New( 072, 095, { || Transform( _nVlrFrt, '@E ###,#99,999.99' ) }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSayF6  := TSay():New( 082, 095, { || Transform( _nVlrGRI, '@E ###,#99,999.99' ) }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSayF7  := TSay():New( 092, 095, { || Transform( _nVlrPed, '@E ###,#99,999.99' ) }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSayF8  := TSay():New( 102, 095, { || Transform( _nVlrSEC, '@E ###,#99,999.99' ) }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSayF9  := TSay():New( 112, 095, { || Transform( _nVlrSeg, '@E ###,#99,999.99' ) }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSayFA  := TSay():New( 122, 095, { || Transform( _nVlrTAS, '@E ###,#99,999.99' ) }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSayFB  := TSay():New( 144, 095, { || Transform( _nTOTFRT, '@E ###,#99,999.99' ) }, oGrp1, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )

        oGrp2   := TGroup():New( 001, 176, 154, 344, 'Politica Comercial - FOB', oContainer, , , .T. )
        oSay21  := TSay():New( 008, 179, { || 'Total do Pedido..:' }, oGrp2, , _oFont1, , , , .T., CLR_BLACK  , CLR_WHITE, 100, 10 )
        oSay22  := TSay():New( 018, 179, { || '% Desc. Politica.:' }, oGrp2, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSay23  := TSay():New( 028, 179, { || 'Desconto.........:' }, oGrp2, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSay23  := TSay():New( 038, 179, { || 'Total (-) Desc...:' }, oGrp2, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSay24  := TSay():New( 048, 179, { || 'Impostos.........:' }, oGrp2, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSay25  := TSay():New( 058, 179, { || 'Valor Frete......:' }, oGrp2, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSay26  := TSay():New( 068, 179, { || 'Comissão.........:' }, oGrp2, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSay27  := TSay():New( 078, 179, { || 'Valor Comissão...:' }, oGrp2, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        
        oSay28  := TSay():New( 098, 179, { || 'Valor Liquido....:' }, oGrp2, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )

        // incluido por Nelieder em 14/08/23
        oSay29  := TSay():New( 118, 179, { || 'Frete Sugerido...:' }, oGrp2, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        oSay30  := TSay():New( 128, 179, { || 'Saldo Frete......:' }, oGrp2, , _oFont1, , , , .T., CLR_BLACK, CLR_WHITE, 100, 10 )
        
        oSayR1  := TSay():New( 008, 271, { || Transform(  _nTotPrT, '@E 999,999,999.99' ) }, oGrp2, , _oFont1, , , , .T., CLR_BLUE, CLR_WHITE, 100, 10 )
        oSayR2  := TSay():New( 018, 271, { || Transform(  _nDesMin, '@E 999,999,999.99' ) }, oGrp2, , _oFont1, , , , .T., CLR_BLUE, CLR_WHITE, 100, 10 )
        oSayR3  := TSay():New( 028, 271, { || Transform( _nFDesPed, '@E 999,999,999.99' ) }, oGrp2, , _oFont1, , , , .T., CLR_BLUE, CLR_WHITE, 100, 10 )
        oSayR4  := TSay():New( 048, 271, { || Transform( _nFVlrImp, '@E 999,999,999.99' ) }, oGrp2, , _oFont1, , , , .T., CLR_BLUE, CLR_WHITE, 100, 10 )
        oSayR5  := TSay():New( 058, 271, { || Transform(         0, '@E 999,999,999.99' ) }, oGrp2, , _oFont1, , , , .T., CLR_BLUE, CLR_WHITE, 100, 10 )
        oSayR6  := TSay():New( 068, 271, { || Transform(         5, '@E 999,999,999.99' ) }, oGrp2, , _oFont1, , , , .T., CLR_BLUE, CLR_WHITE, 100, 10 )
        oSayR7  := TSay():New( 078, 271, { || Transform( _nFVlrCom, '@E 999,999,999.99' ) }, oGrp2, , _oFont1, , , , .T., CLR_BLUE, CLR_WHITE, 100, 10 )
        oSayR8  := TSay():New( 098, 271, { || Transform( _nFVlrLiq, '@E 999,999,999.99' ) }, oGrp2, , _oFont1, , , , .T., CLR_BLUE, CLR_WHITE, 100, 10 )
        
        _nNewTabP := _nTotPrT
        _nNewVLiq := _nFVlrLiq
        _nNewVFrt := _nTOTFRT
        _nNewPrcC := ( _nNewVLiq + _nNewVFrt ) / ( 1 - ( ( 3 + 9.25 + 7 ) / 100 ) )
        _nNewVlrC := _nNewPrcC * ( 3 / 100 )
        _nNewImpo := ( ( 9.25 + 7 ) / 100 ) * _nNewPrcC
        _nNewVDes := _nNewTabP - _nNewPrcC
        _nNewPolD := ( _nNewVDes / _nNewTabP ) * 100

        // Calculo Frete nELIEDER
        //Dif  := ( (_nDesMin-ROUND(_nNewPolD,2)) / 100 )
        Dif  := ( (_nDesMin-ROUND(SC5->C5_DESCON4,2)) / 100 )

        Var1 := ROUND((Dif * _nVlrTot)  ,2 )
        
        Var2 := ROUND( (_nVlrTot * 3) /100 ,2 )

        Var3 := ROUND( (_nVlrTot * 5) /100 ,2 )
        
        Var4 :=  (Var3 - Var2)

        vlFrete :=  (Var1 + Var4)


        oGrp3   := TGroup():New( 001, 350, 154, 434, 'Politica Comercial - CIF', oContainer, , , .T. )
        oSayN1  := TSay():New( 008, 353, { || Transform(       _nNewTabP      , '@E 999,999,999.99' ) }, oGrp3, , _oFont1, , , , .T., CLR_BLUE, CLR_WHITE, 100, 10 )
        oSayN2  := TSay():New( 018, 353, { || Transform(       _nNewPolD      , '@E 999,999,999.99' ) }, oGrp3, , _oFont1, , , , .T., CLR_RED , CLR_WHITE, 100, 10 )
        oSayN3  := TSay():New( 028, 353, { || Transform(       _nNewVDes      , '@E 999,999,999.99' ) }, oGrp2, , _oFont1, , , , .T., CLR_BLUE, CLR_WHITE, 100, 10 )
        oSayNX  := TSay():New( 038, 353, { || Transform( _nNewTabP - _nNewVDes, '@E 999,999,999.99' ) }, oGrp2, , _oFont1, , , , .T., CLR_BLUE, CLR_WHITE, 100, 10 )
        oSayN4  := TSay():New( 048, 353, { || Transform(       _nNewImpo      , '@E 999,999,999.99' ) }, oGrp3, , _oFont1, , , , .T., CLR_BLUE, CLR_WHITE, 100, 10 )
        oSayN5  := TSay():New( 058, 353, { || Transform(       _nNewVFrt      , '@E 999,999,999.99' ) }, oGrp3, , _oFont1, , , , .T., CLR_BLUE, CLR_WHITE, 100, 10 )
        oSayN6  := TSay():New( 068, 353, { || Transform(               3      , '@E 999,999,999.99' ) }, oGrp3, , _oFont1, , , , .T., CLR_RED , CLR_WHITE, 100, 10 )
        oSayN7  := TSay():New( 078, 353, { || Transform(       _nNewVlrC      , '@E 999,999,999.99' ) }, oGrp3, , _oFont1, , , , .T., CLR_RED , CLR_WHITE, 100, 10 )
        oSayN8  := TSay():New( 098, 353, { || Transform(       _nNewVLiq      , '@E 999,999,999.99' ) }, oGrp3, , _oFont1, , , , .T., CLR_BLUE, CLR_WHITE, 100, 10 )

        // incluido por Nelieder em 14/08/23
        oSayN9  := TSay():New( 118, 353, { || Transform(       vlFrete      , '@E 999,999,999.99' ) }, oGrp3, , _oFont1, , , , .T., CLR_BROWN, CLR_WHITE, 100, 10 )
        oSayN10 := TSay():New( 128, 353, { || Transform(       vlFrete-_nTOTFRT      , '@E 999,999,999.99' ) }, oGrp3, , _oFont1, , , , .T., CLR_BROWN, CLR_WHITE, 100, 10 )
         
        _nPedVDes := _nVlrTot * ( SC5->C5_DESCON4 / 100 )
        _nPedImpo := ( _nVlrTot - _nPedVDes ) * ( ( 9.25 + 7 ) / 100 )
        _nPedVlrC := ( _nVlrTot - _nPedVDes ) * ( SC5->C5_COMIS1 / 100 )
        _nPedVLiq := _nVlrTot - _nPedVDes - _nPedImpo - SC5->C5_XVLRFRE - _nPedVlrC

        oGrp4   := TGroup():New( 001, 440, 154, 524, 'Pedido ' + SC5->C5_NUM, oContainer, , , .T. )
        oSayP1  := TSay():New( 008, 443, { || Transform(        _nVlrTot     , '@E 999,999,999.99' ) }, oGrp4, , _oFont1, , , , .T., CLR_BLUE  , CLR_WHITE, 100, 10 )
        
        // Alterado Por Nelieder em 03/04/2023
        If _nNewPolD > SC5->C5_DESCON4
         oSayP2  := TSay():New( 018, 443, { || Transform( SC5->C5_DESCON4     , '@E 999,999,999.99' ) }, oGrp4, , _oFont1, , , , .T., CLR_BLUE  , CLR_WHITE, 100, 10 )
        else
         oSayP2  := TSay():New( 018, 443, { || Transform( SC5->C5_DESCON4     , '@E 999,999,999.99' ) }, oGrp4, , _oFont1, , , , .T., CLR_RED  , CLR_WHITE, 100, 10 )
        EndIf  
        
        oSayP3  := TSay():New( 028, 443, { || Transform(       _nPedVDes     , '@E 999,999,999.99' ) }, oGrp4, , _oFont1, , , , .T., CLR_BLUE  , CLR_WHITE, 100, 10 )
        oSayPX  := TSay():New( 038, 443, { || Transform( _nVlrTot - _nPedVDes, '@E 999,999,999.99' ) }, oGrp4, , _oFont1, , , , .T., CLR_BLUE  , CLR_WHITE, 100, 10 )
        oSayP4  := TSay():New( 048, 443, { || Transform(       _nPedImpo     , '@E 999,999,999.99' ) }, oGrp4, , _oFont1, , , , .T., CLR_BLUE  , CLR_WHITE, 100, 10 )
        
        // nelieder
        If vlFrete > SC5->C5_XVLRFRE
         oSayP5  := TSay():New( 058, 443, { || Transform( SC5->C5_XVLRFRE     , '@E 999,999,999.99' ) }, oGrp4, , _oFont1, , , , .T., CLR_GREEN  , CLR_WHITE, 100, 10 )
        else
         oSayP5  := TSay():New( 058, 443, { || Transform( SC5->C5_XVLRFRE     , '@E 999,999,999.99' ) }, oGrp4, , _oFont1, , , , .T., CLR_RED  , CLR_WHITE, 100, 10 )
        EndIf

        oSayP6  := TSay():New( 068, 443, { || Transform( SC5->C5_COMIS1      , '@E 999,999,999.99' ) }, oGrp4, , _oFont1, , , , .T., CLR_BLUE  , CLR_WHITE, 100, 10 )
        oSayP7  := TSay():New( 078, 443, { || Transform(       _nPedVlrC     , '@E 999,999,999.99' ) }, oGrp3, , _oFont1, , , , .T., CLR_RED , CLR_WHITE, 100, 10 )
        oSayP8  := TSay():New( 098, 443, { || Transform(       _nPedVLiq     , '@E 999,999,999.99' ) }, oGrp3, , _oFont1, , , , .T., CLR_BLUE, CLR_WHITE, 100, 10 )
        //_oGet1Rec     := TGet():New( 004, 004, {|u| If (PCount() > 0, _cGet1Rec := u, _cGet1Rec ) }, oContainer, 070 , 012, '@!', { || fVldRec( _cGet1Rec, @_oGet2DRec, @_cGet2Rec ) }, CLR_BLACK, CLR_WHITE, _oFont1Rec,    , , .T., "", , , .F., .F., , .F., .F., "", "_cGet1Rec", , , , , , , 'Recurso da Operação', 1,          , CLR_BLUE, '<Recurso>'    , .T. )
        //_oGet2DRec    := TGet():New( 028, 004, {|u| If (PCount() > 0, _cGet2Rec := u, _cGet2Rec ) }, oContainer, 150 , 012, '@!',                                                     , CLR_BLACK, CLR_WHITE, _oFont1Rec,    , , .T., "", , , .F., .F., , .T., .F., "", "_cGet2Rec", , , , , , , 'Descrição'          , 1,          , CLR_BLUE, ' '            , .T. )
        //_oGet1Rec:cF3 := 'SH1'
        oModal:Activate()

        //MessageBox( 'Consulta em desenvolvimento ' + Transform( _nVlrTot, '@E 999,999,999.99'), 'Atenção', 64 )
    Else
       MessageBox( 'Opção de consulta somente para pedidos com Frete CIF', 'Atenção', 16 )
    Endif
Return


// Função inutilizada em 19/06/2023 por Nelieder
Static Function fPlaFin( )
       Local aArea      := GetArea()                 //Irei gravar a area atual
       Local _aRentab   := {}
       Local _cPerg     := 'MTA410'
       /***********************************************************************/
       /** Bloco de variáveis para montagem das variáveis para o FillGetDados */
       Local _cArqQry := "SC6"
       Local _nTotPed := 0
       Local _nTotDes := 0
       Local _lGrade  := MaGrade()
       Local _cSeek   := ""
       Local _bWhile
       Local _bCond   := { || .T. }
       Local _bAction1:= { || Mta410Vis( _cArqQry, @_nTotPed, @_nTotDes, _lGrade ) }
       Local _bAction2:= { || .T. } 
       Local _cQuery  := "" 
       /***********************************************************************/
       Private aTransp  := {"",""}

       RegToMemory( 'SC5', .f. )
       Pergunte( _cPerg, .f. )

       DbSelectArea('SA4')
       SA4->( DbSetOrder( 1 ) )
       SA4->( DbSeek( xFilial('SA4') + Iif( SC5->C5_DEPOSI <> 'S', SC5->C5_TRANSP, SC5->C5_REDESP ) ) )

       DbSelectArea('SC5')
       SC5->( DbSetOrder( 1 ) )

       aCols    := {}
       aHeader  := {}
       _cSeek   := FwxFilial( "SC6" ) + SC5->C5_NUM
       _bWhile  := { || C6_FILIAL + C6_NUM }
       _cQuery  := "SELECT * "
       _cQuery  += "FROM " + RetSQLName("SC6") + " SC6 "
       _cQuery  += "WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
       _cQuery  += "  AND SC6.D_E_L_E_T_ = '' "
       _cQuery  += "  AND SC6.C6_NUM = '" + SC5->C5_NUM + "' "
       _cQuery  += "ORDER BY " + SQLOrder( SC6->( IndexKey() ) )
        
       FillGetDados( 2, 'SC6', 1, _cSeek, _bWhile, { { _bCond, _bAction1, _bAction2, } }, /*_aNoFields*/, /*_aYesFields*/, /*_lOnlyYes*/, _cQuery, /*_bMontCols*/, .F., /*_aHeaderAux*/, /*_aColsAux*/, , , , "SC6" )

       _nVlrTot := Ma410Impos( 2, .T., @_aRentab)

       RestArea( aArea )   
Return { _nVlrTot, aHeader, aCols }

Static Function RET_ICMS()

     Local aArea      := GetArea()
     Local aAreaSA1   := SA1->(GetArea())
     Local aFisGet    := {}
     Local aFisGetSC5 := {}
     //Local aTitles    := {"Nota Fiscal", "Duplicatas"}
     Local aDupl      := {}
     //Local aFlHead    := { "Vencimento", "Valor", 'STR0063' }
     Local aEntr      := {}                
     Local aDuplTmp   := {}
     Local aHeadSC6   := MHeaderSC6()
     Local aColsSC6   := MonAcolSC6(aHeadSC6)
     Local nPTotal    := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_VALOR"   })
     Local nPValDesc  := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_VALDESC" })
     Local nPPrUnit   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_PRUNIT"  })
     Local nPPrcVen   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_PRCVEN"  })
     Local nPQtdVen   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_QTDVEN"  })
     Local nPDtEntr   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_ENTREG"  })
     Local nPProduto  := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_PRODUTO" })
     Local nPTES      := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_TES"     })
     Local nPNfOri    := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_NFORI"   })
     Local nPSerOri   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_SERIORI" })
     Local nPItemOri  := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_ITEMORI" })
     Local nPCodPro   := aScan(aHeadSC6, {|x| AllTrim(x[2]) == "C6_PRODUTO" })
     //Local nUsado     := Len(aHeadSC6)
     Local nX         := 0
     Local nAcerto    := 0
     Local nPrcLista  := 0
     Local nValMerc   := 0
     Local nDesconto  := 0
     Local nAcresFin  := 0
     Local nQtdPeso   := 0
     Local nRecOri    := 0
     Local nPosEntr   := 0
     Local nItem      := 0
     Local nY         := 0 
     Local nPosCpo    := 0
     Local lDtEmi     := SuperGetMv("MV_DPDTEMI", .F., .T.)
     Local dDataCnd   := SC5->C5_EMISSAO
     //Local oDlg
     //Local oDupl
     //Local oFolder
     Local _lOpen        := .F. //LGS#20200210 - Adequação para release 12.1.25
     Local _cAliasSX3 := GetNextAlias() //LGS#20200210 - Adequação para release 12.1.25
     Local _nNFFRETE     //LGS#20200211 - Adequação para release 12.1.25
     Local _nNFSEGUR
     Local _nNFDESCO
     Local _nNFAUTON
     Local _nNFDESPE
     Local _nNFBASED
     

     Private nUsdSC6  := Len(aHeadSC6)

     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200210 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0
     If !_lOpen //LGS#20200210 - Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Busca referencias no SC5                     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("SC5")
     DbSetOrder(1)
     DbSeek(xFilial("SC5")+SC5->C5_NUM, .t.)
     dDataCnd   := SC5->C5_EMISSAO
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Busca referencias no SC6                     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     aFisGet	:= {}

     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     /*DbSelectArea("SX3")
     DbSetOrder(1)
     MsSeek("SC6")
     While !Eof() .And. X3_ARQUIVO == "SC6"
           cValid := UPPER(X3_VALID+X3_VLDUSER)
           If 'MAFISGET("' $ cValid
              nPosIni     := AT('MAFISGET("', cValid)+10
              nLen        := AT('")',Substr(cValid, nPosIni, Len(cValid) - nPosIni)) - 1
              cReferencia := Substr(cValid, nPosIni, nLen)
              aAdd(aFisGet, {cReferencia, X3_CAMPO, MaFisOrdem(cReferencia)})
           EndIf
           If 'MAFISREF("' $ cValid
              nPosIni     := AT('MAFISREF("', cValid) + 10
              cReferencia :=Substr(cValid, nPosIni, AT('","MT410",', cValid) - nPosIni)
              aAdd(aFisGet, {cReferencia, X3_CAMPO, MaFisOrdem(cReferencia)})
           EndIf
           DbSkip()
     EndDo*/
     DbSelectArea( _cAliasSX3 )
     ( _cAliasSX3 )->( DbSetOrder(1) )
     ( _cAliasSX3 )->( MsSeek("SC6") )
     While !Eof() .And. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SC6"
           cValid := UPPER( ( _cAliasSX3 )->( X3_VALID ) + ( _cAliasSX3 )->( X3_VLDUSER ) )
           If 'MAFISGET("' $ cValid
              nPosIni     := AT('MAFISGET("', cValid)+10
              nLen        := AT('")',Substr(cValid, nPosIni, Len(cValid) - nPosIni)) - 1
              cReferencia := Substr(cValid, nPosIni, nLen)
              aAdd(aFisGet, {cReferencia, ( _cAliasSX3 )->( X3_CAMPO ), MaFisOrdem(cReferencia)})
           EndIf
           If 'MAFISREF("' $ cValid
              nPosIni     := AT('MAFISREF("', cValid) + 10
              cReferencia :=Substr(cValid, nPosIni, AT('","MT410",', cValid) - nPosIni)
              aAdd(aFisGet, {cReferencia, ( _cAliasSX3 )->( X3_CAMPO ), MaFisOrdem(cReferencia)})
           EndIf
           DbSkip()
     EndDo
     /********************************************************************************************************************************/
     aSort(aFisGet, , ,{|x, y| x[3] < y[3]})

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Busca referencias no SC5                     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     aFisGetSC5	:= {}

     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     /*dbSelectArea("SX3")
     dbSetOrder(1)
     MsSeek("SC5")
     While !Eof() .And. X3_ARQUIVO == "SC5"
           cValid := UPPER(X3_VALID+X3_VLDUSER)
           If 'MAFISGET("' $ cValid
              nPosIni     := AT('MAFISGET("', cValid) + 10
              nLen        := AT('")', Substr(cValid, nPosIni, Len(cValid) - nPosIni)) - 1
              cReferencia := Substr(cValid, nPosIni, nLen)
              aAdd(aFisGetSC5, {cReferencia, X3_CAMPO, MaFisOrdem(cReferencia)})
           EndIf
           If 'MAFISREF("' $ cValid
              nPosIni     := AT('MAFISREF("', cValid) + 10
              cReferencia :=Substr(cValid, nPosIni, AT('","MT410",', cValid) - nPosIni)
              aAdd(aFisGetSC5, { cReferencia, X3_CAMPO, MaFisOrdem(cReferencia)})
           EndIf
           DbSkip()
     EndDo*/
     dbSelectArea( _cAliasSX3 )
     ( _cAliasSX3 )->( dbSetOrder(1) )
     ( _cAliasSX3 )->( MsSeek("SC5") )
     While !Eof() .And. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SC5"
           cValid := UPPER( ( _cAliasSX3 )->( X3_VALID ) + ( _cAliasSX3 )->( X3_VLDUSER ) )
           If 'MAFISGET("' $ cValid
              nPosIni     := AT('MAFISGET("', cValid) + 10
              nLen        := AT('")', Substr(cValid, nPosIni, Len(cValid) - nPosIni)) - 1
              cReferencia := Substr(cValid, nPosIni, nLen)
              aAdd(aFisGetSC5, {cReferencia, ( _cAliasSX3 )->( X3_CAMPO ), MaFisOrdem(cReferencia)})
           EndIf
           If 'MAFISREF("' $ cValid
              nPosIni     := AT('MAFISREF("', cValid) + 10
              cReferencia :=Substr(cValid, nPosIni, AT('","MT410",', cValid) - nPosIni)
              aAdd(aFisGetSC5, { cReferencia, ( _cAliasSX3 )->( X3_CAMPO ), MaFisOrdem(cReferencia)})
           EndIf
           DbSkip()
     EndDo
     /********************************************************************************************************************************/
     aSort(aFisGetSC5, , , {|x, y| x[3] < y[3]})

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Inicializa a funcao fiscal                   ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     MaFisSave()
     MaFisEnd()
     MaFisIni(SC5->C5_CLIENTE                   ,; //1-Codigo Cliente/Fornecedor
              SC5->C5_LOJAENT                   ,; //2-Loja do Cliente/Fornecedor
              IIf(SC5->C5_TIPO $ 'DB', "F", "C"),; //3-C:Cliente , F:Fornecedor
              SC5->C5_TIPO                      ,; //4-Tipo da NF
              SC5->C5_TIPOCLI                   ,; //5-Tipo do Cliente/Fornecedor
              Nil                               ,;
              Nil                               ,;
              Nil                               ,;
              Nil                               ,;
              "MATA461"                          )

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Agrega os itens para a funcao fiscal         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If nPTotal > 0 .And. nPValDesc > 0 .And. nPPrUnit > 0 .And. nPProduto > 0 .And. nPQtdVen > 0 .And. nPTes > 0
        For nX := 1 To Len(aColsSC6)
            nQtdPeso := 0
            If Len(aColsSC6[nX]) == nUsdSC6 .Or. !aColsSC6[nX][nUsdSC6+1]
               nItem++
               If nPNfOri > 0 .And. nPSerOri > 0 .And. nPItemOri > 0
                  If !Empty(aColsSC6[nX][nPNfOri]) .And. !Empty(aColsSC6[nX][nPItemOri])
                     SD1->(dbSetOrder(1))
                     If SD1->(MSSeek(xFilial("SD1")+aColsSC6[nX][nPNfOri]+aColsSC6[nX][nPSerOri]+SC5->C5_CLIENTE+SC5->C5_LOJACLI+aColsSC6[nX][nPCodPro]+aColsSC6[nX][nPItemOri]))
                        nRecOri := SD1->(Recno())
                     Endif	
                  Endif
               Endif	
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³Calcula o preco de lista                     ³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               nValMerc  := aColsSC6[nX][nPTotal]
               nPrcLista := aColsSC6[nX][nPPrUnit]
               If ( nPrcLista == 0 )
                  nPrcLista := NoRound(nValMerc / aColsSC6[nX][nPQtdVen], TamSX3("C6_PRCVEN")[2])
               EndIf
               nAcresFin := a410Arred(aColsSC6[nX][nPPrcVen] * SC5->C5_ACRSFIN / 100, "D2_PRCVEN")
               nValMerc  += a410Arred(aColsSC6[nX][nPQtdVen] * nAcresFin, "D2_TOTAL")
               nDesconto := a410Arred(nPrcLista * aColsSC6[nX][nPQtdVen], "D2_DESCON") - nValMerc
               nDesconto := IIf(nDesconto == 0, aColsSC6[nX][nPValDesc], nDesconto)
               nDesconto := Max(0, nDesconto)
               nPrcLista += nAcresFin
               nValMerc  += nDesconto

               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³Verifica a data de entrega para as duplicatas³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               If ( nPDtEntr > 0 )
                  If ( dDataCnd > aColsSC6[nX][nPDtEntr] .And. !Empty(aColsSC6[nX][nPDtEntr]) )
                     dDataCnd := aColsSC6[nX][nPDtEntr]
                  EndIf
               Else
                  dDataCnd  := SC5->C5_EMISSAO
               EndIf
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³Agrega os itens para a funcao fiscal         ³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               MaFisAdd(aColsSC6[nX][nPProduto],; // 1-Codigo do Produto ( Obrigatorio )
                        aColsSC6[nX][nPTES]    ,; // 2-Codigo do TES ( Opcional )
                        aColsSC6[nX][nPQtdVen] ,; // 3-Quantidade ( Obrigatorio )
                        nPrcLista           ,; // 4-Preco Unitario ( Obrigatorio )
                        nDesconto           ,; // 5-Valor do Desconto ( Opcional )
                        ""                  ,; // 6-Numero da NF Original ( Devolucao/Benef )
                        ""                  ,; // 7-Serie da NF Original ( Devolucao/Benef )
                        nRecOri             ,; // 8-RecNo da NF Original no arq SD1/SD2
                        0                   ,; // 9-Valor do Frete do Item ( Opcional )
                        0                   ,; // 10-Valor da Despesa do item ( Opcional )
                        0                   ,; // 11-Valor do Seguro do item ( Opcional )
                        0                   ,; // 12-Valor do Frete Autonomo ( Opcional )
                        nValMerc            ,; // 13-Valor da Mercadoria ( Obrigatorio )
                        0                    ) // 14-Valor da Embalagem ( Opiconal )
            EndIf
            SB1->(dbSetOrder(1))
            If SB1->(MsSeek(xFilial("SB1")+aColsSC6[nX][nPProduto]))
               nQtdPeso := aColsSC6[nX][nPQtdVen] * SB1->B1_PESO
            Endif	
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Altera peso para calcular frete              ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            MaFisLoad("IT_VALMERC", nValMerc, nItem)
            MaFisAlt("IT_PESO"    , nQtdPeso, nItem)
        Next nX
     EndIf

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Indica os valores do cabecalho               ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     MaFisAlt("NF_FRETE"   , SC5->C5_FRETE)
     MaFisAlt("NF_SEGURO"  , SC5->C5_SEGURO)
     MaFisAlt("NF_AUTONOMO", SC5->C5_FRETAUT)
     MaFisAlt("NF_DESPESA" , SC5->C5_DESPESA)
     If SC5->C5_DESCONT > 0
        MaFisAlt("NF_DESCONTO", Min(MaFisRet(, "NF_VALMERC") - 0.01, SC5->C5_DESCONT + MaFisRet(, "NF_DESCONTO")))
     EndIf
     If SC5->C5_PDESCAB > 0
        MaFisAlt("NF_DESCONTO", A410Arred(MaFisRet(, "NF_VALMERC") * SC5->C5_PDESCAB / 100, "C6_VALOR")+MaFisRet(, "NF_DESCONTO"))
     EndIf

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Realiza alteracoes de referencias do SC6         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("SC6")
     If Len(aFisGet) > 0
        For nX := 1 to Len(aColsSC6)
            If !aColsSC6[nX][Len(aHeadSC6)+1]
               For nY := 1 to Len(aFisGet)
                   nPosCpo := aScan(aHeadSC6, { |x| AllTrim(x[2]) == Alltrim(aFisGet[ny][2])})
                   If nPosCpo > 0
                      If !Empty(aColsSC6[nX][nPosCpo])
                         MaFisAlt(aFisGet[ny][1], aColsSC6[nX][nPosCpo], nX, .F.)
                      Endif
                   EndIf
               Next nX
            Endif
        Next nY           
     Endif

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Realiza alteracoes de referencias do SC5         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If Len(aFisGetSC5) > 0	
        DbSelectArea("SC5")
        For nY := 1 to Len(aFisGetSC5)
            If !Empty(&("SC5->"+Alltrim(aFisGetSC5[ny][2])))
               MaFisAlt(aFisGetSC5[ny][1], &("SC5->"+Alltrim(aFisGetSC5[ny][2])), nItem, .F.)
            EndIf
        Next nY
     Endif
     If ExistBlock("M410PLNF")
        ExecBlock("M410PLNF", .F., .F.)
     EndIf
     MaFisWrite(1)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Calcula os venctos conforme a condicao de pagto  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If lDtEmi
        DbSelectarea("SE4")
        DbSetOrder(1)
        MsSeek(xFilial("SE4")+SC5->C5_CONDPAG)
        If !(SE4->E4_TIPO == "9")
           aDupl := Condicao(MaFisRet(, "NF_BASEDUP"), SC5->C5_CONDPAG, MaFisRet(, "NF_VALIPI"), dDataCnd, MaFisRet(, "NF_VALSOL"))
           If Len(aDupl) > 0
              For nX := 1 To Len(aDupl)
                  nAcerto += aDupl[nX][2]
              Next nX
              aDupl[Len(aDupl)][2] += MaFisRet(,"NF_BASEDUP") - nAcerto
              For nX := 1 To Len(aDupl)
                  aDupl[nX][2] := TransForm(aDupl[nX][2], PesqPict("SE1", "E1_VALOR"))
              Next nX
           Endif	
        Else
           aDupl := {{Ctod(""), TransForm(MaFisRet(,"NF_BASEDUP"), PesqPict("SE1", "E1_VALOR"))}}
        EndIf
     Else
        For nX := 1 to Len(aColsSC6)
            If Len(aColsSC6[nX]) == nUsdSC6 .Or. !aColsSC6[nX][nUsdSC6+1]
               If nPDtEntr > 0
                  nPosEntr := Ascan(aEntr, {|x| x[1] == aColsSC6[nX][nPDtEntr]})
                  If nPosEntr == 0
                     aAdd(aEntr, {aColsSC6[nX][nPDtEntr], MaFisRet(nX, "IT_BASEDUP"), MaFisRet(nX, "IT_VALIPI"), MaFisRet(nX, "IT_VALSOL")})
                  Else
                     aEntr[nPosEntr][2]+= MaFisRet(nX, "IT_BASEDUP")
                     aEntr[nPosEntr][2]+= MaFisRet(nX, "IT_VALIPI")
                     aEntr[nPosEntr][2]+= MaFisRet(nX, "IT_VALSOL")
                  Endif
               Endif
            Endif
        Next
        DbSelectArea("SE4")
        DbSetOrder(1)
        MsSeek(xFilial("SE4")+SC5->C5_CONDPAG)
        If !(SE4->E4_TIPO == "9")
           For nY := 1 to Len(aEntr)           
               nAcerto := 0
               aDuplTmp := Condicao(aEntr[nY][2], SC5->C5_CONDPAG, aEntr[nY][3], aEntr[nY][1], aEntr[nY][4])
               For nX := 1 To Len(aDuplTmp)
                   nAcerto += aDuplTmp[nX][2]
               Next nX
               aDuplTmp[Len(aDuplTmp)][2] += aEntr[nY][2] - nAcerto
               For nX := 1 To Len(aDuplTmp)
                   aDuplTmp[nX][2] := TransForm(aDuplTmp[nX][2], PesqPict("SE1", "E1_VALOR"))
               Next nX
               aEval(aDuplTmp, {|x| Aadd(aDupl, {aEntr[nY][1], x[1], x[2]})})
           Next
        Else
           aDupl := { {Ctod(""), TransForm(MaFisRet(, "NF_BASEDUP"), PesqPict("SE1", "E1_VALOR"))}}
        EndIf
     Endif
     If Len(aDupl) == 0
        aDupl := {{Ctod(""), TransForm(MaFisRet(, "NF_BASEDUP"), PesqPict("SE1", "E1_VALOR"))}}
     Endif
     _nNFFRETE := MaFisRet(,"NF_FRETE")  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
     _nNFSEGUR := MaFisRet(,"NF_SEGURO")
     _nNFDESCO := MaFisRet(,"NF_DESCONTO")
     _nNFAUTON := MaFisRet(,"NF_AUTONOMO")
     _nNFDESPE := MaFisRet(,"NF_DESPESA")
     _nNFBASED := MaFisRet(,"NF_BASEDUP")
     _nNFTOTAL := MaFisRet(,"NF_TOTAL")
     

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Monta a tela de exibicao dos valores fiscais ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     /*DEFINE MSDIALOG oDlg TITLE OemToAnsi("Planilha Financeira") FROM 09, 00 TO 28, 80
            oFolder := TFolder():New(001, 001, aTitles, {"HEADER"}, oDlg, , , , .T., .F., 315, 140)
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Folder 1                                     ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            MaFisRodape(1, oFolder:aDialogs[1], , {005, 001, 310, 60}, Nil, .T.)
            @ 070, 005 SAY RetTitle("F2_FRETE")       SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            @ 070, 105 SAY RetTitle("F2_SEGURO")      SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            @ 070, 205 SAY RetTitle("F2_DESCONT")     SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            @ 085, 005 SAY RetTitle("F2_FRETAUT")     SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            @ 085, 105 SAY RetTitle("F2_DESPESA")     SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            @ 085, 205 SAY RetTitle("F2_VALFAT")      SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            //LGS#20200210 - Adequação de release 12.1.25 e posteriores - Troquei as chamadas de função para variável pois não será suportado em versões futuras.
            //@ 070, 050 MSGET MaFisRet(,"NF_FRETE")    PICTURE PesqPict("SF2", "F2_FRETE"   , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 070, 050 MSGET _nNFFRETE                PICTURE PesqPict("SF2", "F2_FRETE"   , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            //@ 070, 150 MSGET MaFisRet(,"NF_SEGURO")   PICTURE PesqPict("SF2", "F2_SEGURO"  , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 070, 150 MSGET _nNFSEGUR                PICTURE PesqPict("SF2", "F2_SEGURO"  , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            //@ 070, 250 MSGET MaFisRet(,"NF_DESCONTO") PICTURE PesqPict("SF2", "F2_DESCONTO", 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 070, 250 MSGET _nNFDESCO                PICTURE PesqPict("SF2", "F2_DESCONTO", 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            //@ 085, 050 MSGET MaFisRet(,"NF_AUTONOMO") PICTURE PesqPict("SF2", "F2_FRETAUT" , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 085, 050 MSGET _nNFAUTON                PICTURE PesqPict("SF2", "F2_FRETAUT" , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            //@ 085, 150 MSGET MaFisRet(,"NF_DESPESA")  PICTURE PesqPict("SF2", "F2_DESPESA" , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 085, 150 MSGET _nNFDESPE                PICTURE PesqPict("SF2", "F2_DESPESA" , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            //@ 085, 250 MSGET MaFisRet(,"NF_BASEDUP")  PICTURE PesqPict("SF2", "F2_VALFAT"  , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 085, 250 MSGET _nNFBASED                PICTURE PesqPict("SF2", "F2_VALFAT"  , 16, 2) SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            @ 105, 005 TO 106, 310 PIXEL OF oFolder:aDialogs[1]
            @ 110, 005 SAY OemToAnsi("Total da Nota") SIZE 40, 10 PIXEL OF oFolder:aDialogs[1]
            //@ 110, 050 MSGET MaFisRet(,"NF_TOTAL")    PICTURE PesqPict("SF2","F2_VALBRUT",16,2)     SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
              @ 110, 050 MSGET   _nNFTOTAL              PICTURE PesqPict("SF2","F2_VALBRUT",16,2)     SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
            @ 110, 270 BUTTON OemToAnsi("Sair")       SIZE 040,11 FONT oFolder:aDialogs[1]:oFont ACTION oDlg:End() OF oFolder:aDialogs[1] PIXEL
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Folder 2                                     ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If lDtEmi
               @ 005, 001 LISTBOX oDupl FIELDS TITLE aFlHead[1], aFlHead[2]             SIZE 310, 095 OF oFolder:aDialogs[2] PIXEL
            Else	
               @ 005, 001 LISTBOX oDupl FIELDS TITLE aFlHead[3], aFlHead[1], aFlHead[2] SIZE 310, 095 OF oFolder:aDialogs[2] PIXEL
            Endif
            oDupl:SetArray(aDupl)
            oDupl:bLine := {|| aDupl[oDupl:nAt] }
            @ 105, 005 TO 106, 310 PIXEL OF oFolder:aDialogs[2]
            If cPaisLoc == "BRA"
               @ 110, 005 SAY RetTitle("F2_VALFAT") SIZE 40, 10 PIXEL OF oFolder:aDialogs[2]
            Else
               @ 110, 005 SAY OemToAnsi('STR0051')    SIZE 40, 10 PIXEL OF oFolder:aDialogs[2]
            Endif	
            //@ 110, 050 MSGET MaFisRet(,"NF_BASEDUP")  PICTURE PesqPict("SF2", "F2_VALFAT", 16, 2)   SIZE 50, 07 PIXEL WHEN .F. OF oFolder:aDialogs[2]
              @ 110, 050 MSGET _nNFBASED                PICTURE PesqPict("SF2", "F2_VALFAT", 16, 2)   SIZE 50, 07 PIXEL WHEN .F. OF oFolder:aDialogs[2]
            @ 110, 270 BUTTON OemToAnsi("Sair")       SIZE 040,11 FONT oFolder:aDialogs[1]:oFont ACTION oDlg:End() OF oFolder:aDialogs[2] PIXEL

     //ACTIVATE MSDIALOG oDlg CENTERED*/
     MaFisEnd()
     MaFisRestore()

     DbSelectArea( _cAliasSX3 )
     DbCloseArea()

     RestArea(aAreaSA1)
     RestArea(aArea)
Return{_nNFTOTAL,aHeadSC6,aColsSC6}


Static Function MHeaderSC6()
       Local aHeaderSC6 := {}
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
       MsSeek("SC6")
       While ( !Eof() .And. (SX3->X3_ARQUIVO == "SC6") )
             If ( X3USO(SX3->X3_USADO) .And. !(	Trim(SX3->X3_CAMPO) == "C6_NUM" ) .And. Trim(SX3->X3_CAMPO) <> "C6_QTDEMP" .And. Trim(SX3->X3_CAMPO) <> "C6_QTDENT" .And. cNivel >= SX3->X3_NIVEL )
                aAdd(aHeaderSC6, { TRIM(( _cAliasSX3 )->( X3_TITULO )), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )
             EndIf
             DbSelectArea("SX3")
             DbSkip()
       EndDo*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( MsSeek("SC6") )
       While ( !Eof() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SC6") )
             If ( X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .And. !( Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C6_NUM" ) .And. Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) <> "C6_QTDEMP" .And. Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) <> "C6_QTDENT" .And. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) )
                aAdd( aHeaderSC6, { TRIM(( _cAliasSX3 )->( X3_TITULO )), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
             EndIf
             DbSelectArea( _cAliasSX3 )
             ( _cAliasSX3 )->( DbSkip() )
       EndDo
       DbSelectArea( _cAliasSX3 )
       DbCloseArea()
       /********************************************************************************************************************************/
Return( aHeaderSC6 )

Static Function MonAcolSC6(aHeadSC6)
       Local aColsSC6 := {}
       Local nCntFor
       Private AHEADGRADE := {}
       Private ACOLSGRADE := {}
       DbSelectArea("SC6")
       DbSetOrder(1)
       MsSeek(xFilial("SC6")+SC5->C5_NUM)
       While ( !Eof() .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM )
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Verifica se este item foi digitada atraves de uma    ³
             //³ grade, se for junta todos os itens da grade em uma   ³
             //³ referencia , abrindo os itens so quando teclar enter ³
             //³ na quantidade                                        ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If ( SC6->C6_GRADE == "S" .And. lGrade )
                //a410Grade(.F., , cArqQry)
             Else
                aAdd(aColsSC6, Array(Len(aHeadSC6)+1))
                For nCntFor:=1 To Len(aHeadSC6)
                    If ( aHeadSC6[nCntFor,10] <>  "V" )
                       aCOLSSC6[Len(aColsSC6)][nCntFor] := FieldGet(FieldPos(aHeadSC6[nCntFor,2]))
                    Else			
                       //aCOLSSC6[Len(aColsSC6)][nCntFor] := CriaVar(aHeadSC6[nCntFor,2])
                    EndIf
                Next nCntFor
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Mesmo nao sendo um item digitado atraves de grade e' necessa-³
                //³ rio criar o Array referente a este item para controle da     ³
                //³ grade                                                        ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                MatGrdMont(Len(aColsSC6))
             EndIf
             aColsSC6[Len(aColsSC6)][Len(aHeadSC6)+1] := .F.	
             DbSelectArea("SC6")
             DbSkip()
       EndDo
Return(aColsSC6)
