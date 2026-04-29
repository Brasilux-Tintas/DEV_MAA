
#Include 'TOTVS.CH'

/*/{Protheus.doc} ZFISA01
Ajusta de NCM no cadastro de produtos, com chamada no menu EICA130
@type function
@version v.2022.03.02
@author Luis Gustavo de Souza
@since 02/03/2022
/*/
User Function ZFISA01( _cParam )
     Local aArea := GetArea()
     
     Processa( { || FISA01Exe( _cParam ) }, "Processando..." )
     
     RestArea(aArea)
Return

Static Function FISA01Exe( _cParam )
       Local _cQryTmp         := GetNextAlias()
       Local _cNumNCM         := ""
       Local _cPerg           := 'ZFISA01'
       Private lMsErroAuto    := .F.
       Private lMsHelpAuto    := .F.
       Private lAutoErrNoFile := .t.

       //Executando pergunte do relatÃ³rio
       If _cParam == 'M'
          _cNumNCM := SYD->YD_TEC
       Else
          If Pergunte( _cPerg, .T. )
             _cNumNCM := MV_PAR01
          else
             Return
          Endif
       EndIf
       DbSelectArea('SYD')
       SYD->( DbSetOrder( 1 ) )
       If SYD->( DbSeek( xFilial("SYD") + _cNumNCM ) )
          _nPerIPI := SYD->YD_PER_IPI
          BEGINSQL ALIAS _cQryTmp
                   SELECT ROW_NUMBER() OVER(ORDER BY SB1.B1_COD DESC) AS Row, SB1.B1_COD, SB1.B1_DESC, SB1.B1_POSIPI, SB1.B1_IPI 
                   FROM SB1010 SB1
                   WHERE SB1.B1_FILIAL  = %exp:xFilial("SB1")%
                     AND SB1.D_E_L_E_T_ = ''
                     AND SB1.B1_IPI <> 0
                     AND SB1.B1_POSIPI = %exp:_cNumNCM%
                   ORDER BY SB1.B1_COD
          ENDSQL

          //Conta o total de registros, seta o tamanho da rÃ©gua, e volta pro topo
          nTotal := (_cQryTmp)->ROW
          ProcRegua( nTotal )

          //Imprime o cabeÃ§alho
          If nTotal <= 0
             MessageBox( "NÃ£o existe dados a serem processados...", "Atenção", 48 )
             Return
          Endif
          nAtual := 0
          _cLinCab := "PRODUTO         DESCRIÇÃO                                 ERRO" + CHR(13) + CHR(10)
          _cLinha  := ""
          //          123456789012345  1234567890123456789012345678901234567890
          DbSelectArea("SB1")
          SB1->( DbSetOrder( 1 ) )
          //Enquanto houver registros
          While !(_cQryTmp)->( EoF() )
                nAtual++
                IncProc( "Alterando IPI conforme NCM. Produto: " + Alltrim( (_cQryTmp)->B1_COD ) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")..." )
                If SB1->( DbSeek( xFilial("SB1") + (_cQryTmp)->B1_COD ) )
                   If SB1->B1_IPI <> _nPerIPI 
                      If ( !Empty( SB1->B1_GARANT ) .and. ( SB1->B1_TIPO $ 'PI.PA.MP' .AND. SB1->B1_PESOESP > 0 ) .and. !Empty( SB1->B1_GRUPO2 ) )
                         _aVetor := {}
                         _aVetor := { { "B1_COD"   , (_cQryTmp)->B1_COD , NIL },;
                                      { "B1_IPI"   ,           _nPerIPI , NIL } }

                         MSExecAuto( { | x, y | Mata010( x , y ) }, _aVetor, 4 )
                         If lMsErroAuto
                            _aErro  := GetAutoGRLog()
                            _cLinha += SB1->B1_COD + '  ' + SB1->B1_DESC + '  ' + Chr(13) + Chr(10)  + Iif( Len(_aErro) <= 0, '', Alltrim( _aErro[1] ) ) + Chr(13) + Chr(10) 
                            //MostraErro()
                         Endif
                      Else
                         _cLinha += SB1->B1_COD + '  ' + SB1->B1_DESC + '  ' + SB1->B1_GARANT + SB1->B1_GRUPO2 + TransForm( SB1->B1_PESOESP, "@E 999,999999" ) + Chr(13) + Chr(10) 
                      Endif
                   Endif
                Endif
                (_cQryTmp)->( DbSkip() )
          EndDo
          (_cQryTmp)->( DbCloseArea() )
          If Len( Alltrim( _cLinha ) ) > 0
             _cLinCab += _cLinha
             MemoWrite( 'C:\TEMP\LOG_' + Alltrim( _cNumNCM ) + '_' + DTOS( Date() ) + '_' + StrTran( Time(), ':' ) + '.TXT', _cLinCab )
           Endif
        Else
           MessageBox( "Não existe dados a serem processados...", "Atenção", 48 )
        Endif

Return
