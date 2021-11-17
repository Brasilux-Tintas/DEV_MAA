#include 'protheus.CH'
#include 'FWMvcDef.CH'

/*/{Protheus.doc} ZPCPF01
//TODO Descrição auto-gerada.
@author gustavosouza
@since 14/02/2020
@version 1.0
@return ${return}, ${return_description}
@param _cParConf, , descricao
@type function
/*/
User Function ZFISF01() 
     Local _oDlgPri
     Local _oAreaPar
     Local _aWindow     := { 100, 100 }
     Local _aColumn     := { 092, 008 }
     Local _nX
     Local _nLin
     Local _lOpen
     Local _cTextSay
     Local _oFont01     := Tfont():New("Courier New", , 14, , .F., , , , , , )
     Local _oFont02     := Tfont():New("Courier New", , 14, , .T., , , , , , )
     Local _oFont03     := Tfont():New("Courier New", , 13, , .T., , , , , , )
     Local _nSalto      := 0
     Local _cVarDem     := ""
     Private _cParAlt   := GETMV("ZP_PAR0017") //Parâmetro com os parâmetros que o usuário pode alterar.
     Private _aVarArr   := {}
     Private _cAliasSX6 := GetNextAlias()
     Private _aCoords
     Private _aParAlt   
     

     OpenSXS( ,,,,, _cAliasSX6, 'SX6',, .F.,, .T., .F. )
     _lOpen := Select( _cAliasSX6 )

     If Type( "_cParAlt" ) == 'L' .and.  !_cParAlt
        MessageBox('Atenção o parâmetros ZP_PAR0017 não está configurado para essa Empresa/Filial, informe o Administrador do sistema!', 'Atenção', 16 )
        Return
     Else
        _aParAlt   := StrTokArr( _cParAlt, '/' ) //Parâmetro com os parâmetros que o usuário pode alterar.
     Endif
     If Len( _aParAlt ) > 0
        If _lOpen
           _aCoords := FWGetDialogSize()
        
           _nSalto  := Len( _aParAlt ) * 40
           _oDlgPri := tDialog():New( _aCoords[1] + 100, _aCoords[2] + 100, ( _aCoords[3] - ( 400 - _nSalto ) ), _aCoords[4] - 100, "Manutenção de parâmetros do sistema",,,,,CLR_BLACK, CLR_WHITE,,,.T. )
           _oAreaPar:= FWLayer():New()
           //Area
           _oAreaPar:Init( _oDlgPri, .F. )
     
           //Linha
           _oAreaPar:AddLine( "L01", 100, .F. )
     
           //Coluna
           _oAreaPar:AddColumn( "L01C01", _aColumn[1], .T., "L01" )
           _oAreaPar:AddColumn( "L01C02", _aColumn[2], .T., "L01" )
     
           _oAreaPar:AddWindow("L01C01", "L01C01P01", "Parâmetros", _aWindow[1], .f., .T., , "L01",  )
           _oPanel := _oAreaPar:GetWinPanel( "L01C01", "L01C01P01", "L01" )
     
           _oAreaPar:AddWindow("L01C02", "L01C02P01", "Funções"    , _aWindow[2], .f., .T., , "L01",  )
           _oAreaBut := _oAreaPar:GetWinPanel("L01C02", "L01C02P01", "L01" ) 
     
           _oBotao00 := tButton():New( 000, 000, "&Sair", _oAreaBut, { || _oDlgPri:End() }, _oAreaBut:nClientWidth / 2, 15, , , , .T., , , , )
     
           _nLin := 30
           For _nX := 1 To Len( _aParAlt )
               _cDesc   := ""
               _cVarDem += Iif( _nX == 1, _aParAlt[_nX], " \ " + _aParAlt[_nX] )
               DbSelectArea( _cAliasSX6 )
               ( _cAliasSX6 )->( DbSetorder(1) )
               If ( _cAliasSX6 )->( DbSeek( xFilial( _cAliasSX6 ) + _aParAlt[_nX] ) )
                      _cDesc := xFilial( _cAliasSX6 ) + ' - ' + _aParAlt[ _nX ] + Space( 10 - Len( _aParAlt[ _nX ] ) ) + ' - ' + SubStr( Alltrim( ( _cAliasSX6 )->( X6_DESCRIC ) ) + ' ' + Alltrim( ( _cAliasSX6 )->( X6_DESC1 ) ) + ' ' + Alltrim( ( _cAliasSX6 )->( X6_DESC2 ) ), 1, 90 )
                      _cDesc += Space( 90 - Len(SubStr( Alltrim( ( _cAliasSX6 )->( X6_DESCRIC ) ) + ' ' + Alltrim( ( _cAliasSX6 )->( X6_DESC1 ) ) + ' ' + Alltrim( ( _cAliasSX6 )->( X6_DESC2 ) ), 1, 90 )) ) + ' - '
                      aAdd( _aVarArr, { _cDesc, _aParAlt[ _nX ], "_cDesc" + StrZero( _nX, 2 ), "_oDesc" + StrZero( _nX, 2 ), "_oBotao" + StrZero( _nX, 2 ) } )
               ElseIf ( _cAliasSX6 )->( DbSeek( cFilAnt + _aParAlt[_nX] ) )
                      _cDesc := cFilAnt               + ' - ' + _aParAlt[ _nX ] + Space( 10 - Len( _aParAlt[ _nX ] ) ) + ' - ' + SubStr( Alltrim( ( _cAliasSX6 )->( X6_DESCRIC ) ) + ' ' + Alltrim( ( _cAliasSX6 )->( X6_DESC1 ) ) + ' ' + Alltrim( ( _cAliasSX6 )->( X6_DESC2 ) ), 1, 90 )
                      _cDesc += Space( 90 - Len(SubStr( Alltrim( ( _cAliasSX6 )->( X6_DESCRIC ) ) + ' ' + Alltrim( ( _cAliasSX6 )->( X6_DESC1 ) ) + ' ' + Alltrim( ( _cAliasSX6 )->( X6_DESC2 ) ), 1, 90 )) ) + ' - '
                      aAdd( _aVarArr, { _cDesc, _aParAlt[ _nX ], "_cDesc" + StrZero( _nX, 2 ), "_oDesc" + StrZero( _nX, 2 ), "_oBotao" + StrZero( _nX, 2 ) } )
               ElseIf ( _cAliasSX6 )->( DbSeek( cEmpAnt + _aParAlt[_nX] ) )
                      _cDesc := cEmpAnt               + ' - ' + _aParAlt[ _nX ] + Space( 10 - Len( _aParAlt[ _nX ] ) ) + ' - ' + SubStr( Alltrim( ( _cAliasSX6 )->( X6_DESCRIC ) ) + ' ' + Alltrim( ( _cAliasSX6 )->( X6_DESC1 ) ) + ' ' + Alltrim( ( _cAliasSX6 )->( X6_DESC2 ) ), 1, 90 )
                      _cDesc += Space( 90 - Len(SubStr( Alltrim( ( _cAliasSX6 )->( X6_DESCRIC ) ) + ' ' + Alltrim( ( _cAliasSX6 )->( X6_DESC1 ) ) + ' ' + Alltrim( ( _cAliasSX6 )->( X6_DESC2 ) ), 1, 90 )) ) + ' - '
                      aAdd( _aVarArr, { _cDesc, _aParAlt[ _nX ], "_cDesc" + StrZero( _nX, 2 ), "_oDesc" + StrZero( _nX, 2 ), "_oBotao" + StrZero( _nX, 2 ) } )
               Endif
               If ( _cAliasSX6 )->( X6_TIPO ) == 'C'
                  _aVarArr[ Len( _aVarArr ) ][ 1 ] := _aVarArr[ Len( _aVarArr ) ][ 1 ] + Alltrim( ( _cAliasSX6 )->( X6_CONTEUDO ) )
               ElseIf ( _cAliasSX6 )->( X6_TIPO ) == 'N'
                      _aVarArr[ Len( _aVarArr ) ][ 1 ] := _aVarArr[ Len( _aVarArr ) ][ 1 ] + cValToChar( ( _cAliasSX6 )->( X6_CONTEUDO ) )
               ElseIf ( _cAliasSX6 )->( X6_TIPO ) == 'L'
                      _aVarArr[ Len( _aVarArr ) ][ 1 ] := _aVarArr[ Len( _aVarArr ) ][ 1 ] + cValToChar( ( _cAliasSX6 )->( X6_CONTEUDO ) )
               ElseIf ( _cAliasSX6 )->( X6_TIPO ) == 'D'
                      _aVarArr[ Len( _aVarArr ) ][ 1 ] := _aVarArr[ Len( _aVarArr ) ][ 1 ] + DTOC( STOD( ( _cAliasSX6 )->( X6_CONTEUDO ) ) )
               Endif
           Next
           _nX := 1
           _oSayCab01 := TSay():New( _nLin - 30, 002,  {|| "Parâmetro ZP_PAR0017: " + _cVarDem } , _oPanel, , _oFont02, , , , .T., CLR_BLUE, , 800, 120 )
           _oSayCab01 := TSay():New( _nLin - 18, 002,  {|| "FILIAL   PARÂMETRO    DESCRIÇÃO                                                                                    CONTEUDO"                         } , _oPanel, , _oFont02, , , , .T., CLR_HBLUE, , 800, 120 )
           _oSayCab01 := TSay():New( _nLin - 10, 002,  {|| "======   ==========   ==========================================================================================   ================================" } , _oPanel, , _oFont02, , , , .T., CLR_HBLUE, , 800, 120 )
           For _nX := 1 To Len( _aVarArr )
               _cTextSay := "{ ||'" + _aVarArr[_nX][1] + "'} "
               _cBotaoBl := "{ || fAltPar(" + _aVarArr[_nX][5] + "," + Strzero( _nX, 2 ) + " ) }"
               &( _aVarArr[_nX][4] )  := TSay():New(    _nLin    , 002,  MontaBlock( _cTextSay ), _oPanel, , _oFont01, , , , .T., , , 900, 120 )
               &( _aVarArr[_nX][5] )  := tButton():New( _nLin - 4, 000, _aVarArr[ _nX ][ 2], _oAreaBut, MontaBlock( _cBotaoBl ), _oAreaBut:nClientWidth / 2, 15, , _oFont03, , .T., , , , )
               _nLin += 20
           Next
           _nX := 1
           _oDlgPri:Activate( ,,,.t.,,, )
        Else
           MessageBox('Atenção o parâmetros ZP_PAR0017 não está configurado para essa Empresa/Filial, informe o Administrador do sistema!', 'Atenção', 16 )
        Endif
        DbSelectArea( _cAliasSX6 )
        DbCloseArea()
     Else
        MessageBox( 'Não foi possível abrir dicionário de dados SX6.', 'Atenção...', 48)
     Endif
Return

Static Function fAltPar( _cBotao, _nZ )
       Local _cPictur
       Local _oAltera
       Local _oBtnRet
       Local _oBtnCon
       Private _vAltera
       Private _cCodPar := _aParAlt[ _nZ ]
       Private _vParAnt
       Private _oDlgAlt

       //Busco as informações atuais dos parâmetros
       DbSelectArea( _cAliasSX6 )
       ( _cAliasSX6 )->( DbSetOrder( 1 ) )
       If ( _cAliasSX6 )->( DbSeek( xFilial("SX6") + _cCodPar ) )
          _vAltera := Iif( ( _cAliasSX6 )->( X6_TIPO ) == 'D', STOD( ( _cAliasSX6 )->( X6_CONTEUDO ) ), Iif( ( _cAliasSX6 )->( X6_TIPO ) == 'N', Val ( ( _cAliasSX6 )->( X6_CONTEUDO ) ), Iif( ( _cAliasSX6 )->( X6_TIPO ) == 'C', ( Alltrim( ( _cAliasSX6 )->( X6_CONTEUDO ) ) ) + Space( 250 - Len( Alltrim( ( _cAliasSX6 )->( X6_CONTEUDO ) ) ) ), Alltrim( ( _cAliasSX6 )->( X6_CONTEUDO ) ) ) )  )
       ElseIf ( _cAliasSX6 )->( DbSeek( cFilAnt + _cCodPar ) )
              _vAltera := Iif( ( _cAliasSX6 )->( X6_TIPO ) == 'D', STOD( ( _cAliasSX6 )->( X6_CONTEUDO ) ), Iif( ( _cAliasSX6 )->( X6_TIPO ) == 'N', Val ( ( _cAliasSX6 )->( X6_CONTEUDO ) ), Iif( ( _cAliasSX6 )->( X6_TIPO ) == 'C', ( Alltrim( ( _cAliasSX6 )->( X6_CONTEUDO ) ) ) + Space( 250 - Len( Alltrim( ( _cAliasSX6 )->( X6_CONTEUDO ) ) ) ), Alltrim( ( _cAliasSX6 )->( X6_CONTEUDO ) ) ) )  )
       ElseIf ( _cAliasSX6 )->( DbSeek( cEmpAnt + _cCodPar ) )
              _vAltera := Iif( ( _cAliasSX6 )->( X6_TIPO ) == 'D', STOD( ( _cAliasSX6 )->( X6_CONTEUDO ) ), Iif( ( _cAliasSX6 )->( X6_TIPO ) == 'N', Val ( ( _cAliasSX6 )->( X6_CONTEUDO ) ), Iif( ( _cAliasSX6 )->( X6_TIPO ) == 'C', ( Alltrim( ( _cAliasSX6 )->( X6_CONTEUDO ) ) ) + Space( 250 - Len( Alltrim( ( _cAliasSX6 )->( X6_CONTEUDO ) ) ) ), Alltrim( ( _cAliasSX6 )->( X6_CONTEUDO ) ) ) )  )
       Endif
       _vParAnt := _vAltera
       //Busco informações do tipo para montar a picture e ajustar o tamanho da variável
       If ( _cAliasSX6 )->( X6_TIPO ) == 'C'
          _cPictur := "@!"
          _cDesTip := "Caracter."
       ElseIf ( _cAliasSX6 )->( X6_TIPO ) == 'N'
              _cPictur := "@!"
              _cDesTip := "Numérico."
       ElseIf ( _cAliasSX6 )->( X6_TIPO ) == 'L'
          _cPictur := ""
          _cDesTip := "Lógico."
          //_vAltera := ( Alltrim( _vAltera ) ) + Iif( Len( _vAltera ) == 1, Space( 2 ), Alltrim( _vAltera ) )
       Else
          _cPictur := ""
          _cDesTip := "Data."
       Endif

       _oDlgAlt := tDialog():New( _aCoords[1], _aCoords[2], _aCoords[3] - 500, _aCoords[4] - 1000, "Manutenção",,,,,CLR_BLACK, CLR_WHITE,,,.T. )
       
       _oAltera := TGet():New( 005, 010, {|u| If( PCount() > 0, _vAltera := u, _vAltera ) }, _oDlgAlt, 160, 012, _cPictur, , 0, , , .F., , .T., , .F., , .F., .F., , .F., .F., , "_vAltera", , , , , , ,"Parâmetro Tipo " + _cDesTip, 1 )
       
       _oBtnRet := tButton():New( 030, 090, "Voltar"   , _oDlgAlt, { || _oDlgAlt:End() }, 35, 15, , , , .T., , , , )
       _oBtnCon := tButton():New( 030, 130, "Confirmar", _oDlgAlt, { || fConfirma() }, 35, 15, , , , .T., , , , )
       
       _oDlgAlt:Activate( ,,,.t.,,, )
Return

Static Function fConfirma()
       Local _nPosPar := aScan( _aVarArr, {|x| x[2] == _cCodPar} )
       Local _lRet := .F.
       If _vParAnt <> _vAltera
          //Posicionar o parâmetro de acordo com a Filial do mesmo, compartilhado, por empresa ou por empresa+unidade+filial
          DbSelectArea( _cAliasSX6 )
          ( _cAliasSX6 )->( DbSetOrder( 1 ) )
          If ( _cAliasSX6 )->( DbSeek( xFilial("SX6") + _cCodPar ) )
             _lRet := .T.
          ElseIf ( _cAliasSX6 )->( DbSeek( cFilAnt + _cCodPar ) )
                 _lRet := .T.
          ElseIf ( _cAliasSX6 )->( DbSeek( cEmpAnt + _cCodPar ) )
                 _lRet := .T.
          Endif
          If _lRet
             //Faço o tratamento por tipo e atualizo texto da tela principal
             If ( _cAliasSX6 )->( X6_TIPO ) == 'C' //Caracter
                //Atualizar matriz _aVarArr
                _aVarArr[ _nPosPar][1] := SubStr( _aVarArr[ _nPosPar][1], 1, 115) + Alltrim( _vAltera )
                //Atualizar texto
                &( _aVarArr[ _nPosPar][4] ):cCaption := _aVarArr[ _nPosPar][1]
                &( _aVarArr[ _nPosPar][4] ):Refresh()
                //Atualizar _cAliasSX6
                RecLock( _cAliasSX6, .f.)
                   ( _cAliasSX6 )->( X6_CONTEUDO ) := Alltrim( _vAltera )
                MsUnLock()
                //Atualizar SX6
                PutMV( _cCodPar, Alltrim( _vAltera ) )
             ElseIf ( _cAliasSX6 )->( X6_TIPO ) == 'N' //Numérico
                    //Atualizar matriz _aVarArr
                    _aVarArr[ _nPosPar][1] := SubStr( _aVarArr[ _nPosPar][1], 1, 115) + Alltrim( cValToChar( _vAltera ) )
                    //Atualizar texto
                    &( _aVarArr[ _nPosPar][4] ):cCaption := _aVarArr[ _nPosPar][1]
                    &( _aVarArr[ _nPosPar][4] ):Refresh()
                    //Atualizar _cAliasSX6
                    RecLock( _cAliasSX6, .f.)
                       ( _cAliasSX6 )->( X6_CONTEUDO ) := Alltrim( cValToChar( _vAltera ) )
                    MsUnLock()
                    //Atualizar SX6
                    PutMV( _cCodPar, DTOS( _vAltera ) )
             ElseIf ( _cAliasSX6 )->( X6_TIPO ) == 'L' //Lógico
                    If Len( Alltrim( _vAltera ) ) == 1 .and. UPPER( Alltrim( _vAltera ) ) $ 'F.T'
                       _vAltera := '.' + Alltrim( _vAltera ) + '.'
                       //Atualizar matriz _aVarArr
                       _aVarArr[ _nPosPar][1] := SubStr( _aVarArr[ _nPosPar][1], 1, 115) + DTOC( _vAltera )
                       //Atualizar texto
                       &( _aVarArr[ _nPosPar][4] ):cCaption := _aVarArr[ _nPosPar][1]
                       &( _aVarArr[ _nPosPar][4] ):Refresh()
                       //Atualizar _cAliasSX6
                       RecLock( _cAliasSX6, .f.)
                          ( _cAliasSX6 )->( X6_CONTEUDO ) := DTOS( _vAltera )
                       MsUnLock()
                       //Atualizar SX6
                       PutMV( _cCodPar, DTOS( _vAltera ) )
                    Else
                       MessageBox( 'Conteudo inválido, verifique.', 'Atenção', 48 )
                    Endif
             ElseIf ( _cAliasSX6 )->( X6_TIPO ) == 'D' //Data
                    //Atualizar matriz _aVarArr
                    _aVarArr[ _nPosPar][1] := SubStr( _aVarArr[ _nPosPar][1], 1, 115) + DTOC( _vAltera )
                    //Atualizar texto
                    &( _aVarArr[ _nPosPar][4] ):cCaption := _aVarArr[ _nPosPar][1]
                    &( _aVarArr[ _nPosPar][4] ):Refresh()
                    //Atualizar _cAliasSX6
                    RecLock( _cAliasSX6, .f.)
                       ( _cAliasSX6 )->( X6_CONTEUDO ) := DTOS( _vAltera )
                    MsUnLock()
                    //Atualizar SX6
                    PutMV( _cCodPar, DTOS( _vAltera ) )
             Endif
          Else
             MessageBox( 'Parâmetro não localizado, verifique.', 'Atenção', 48 )
          Endif
       Endif
       _oDlgAlt:End()
Return