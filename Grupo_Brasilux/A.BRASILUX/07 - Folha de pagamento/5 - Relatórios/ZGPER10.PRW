#INCLUDE "totvs.ch"
#INCLUDE "appexcel.ch"

/*/{Protheus.doc} ZGPER10
//Geração de planilhas das empresas conforme configuração de parâmetros para envio a seguradora.
@param mv_par01 - Perido Ano e Mes da geração das informações
       mv_par02 - Filiais ao qual as planilhas serão geradas
       mv_par03 - Categoria dos funcionários a serem gerados 
       mv_par04 - Valor do seguro
       mv_par05 - Diretório aonde serão gerados as planilhas
       mv_par06 - Sim para gerar prolabore somente para a empresa principal 010101
       mv_par07 - Tipos de afastamento que irão gerar o tipo para o segurado - deverão ser separados por ponto e virgula.
@author gustavosouza
@since 08/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function ZGPER10()
     Local _cPerg   := "ZGPER10   "
     Local oExcel
     Local _aEmpRel := {}
     Local _aDadRel := {}
     Local _nY
     Local _nX
     Local oCelCAB01, oCelCAB02, oCelCAB03, oCelCAB04, oCelDET01, oCelDET02
     Private oFont1
     Private oFont2
     Private oFont3
     u_zcfga01( 'ZGPER10' ) //LGS#2021202 - Gravação de log de utilização da rotina
     If !Pergunte( _cPerg ) 
        Return() //Se cancelar as perguntas sai do programa
     Endif
     MakeSQLExpr( _cPerg )
     If ! ExistDir( mv_par05 )
          MakeDir( mv_par05 )
     Endif
     If !fDados( @_aEmpRel, @_aDadRel )
        MsgAlert("Não existem dados para esse relatório")
        Return() //Se não tiver dados para impressão sai do programa
     Endif
     
     For _nY := 1 To Len( _aEmpRel )
         oFont1 := AppExcFont():New( "Calibri"      , '12', '#000080')
         oFont2 := AppExcFont():New( "Calibri"      , '12', '#000000')
         oFont3 := AppExcFont():New( "Calibri Light", '12', '#000000')
         oFont1:SetBold( .T. )

         oCelCAB01 := AppExcCell():New(); oCelCAB01:SetCellColor("#FFFFFF"); oCelCAB01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelCAB01:SetFont( oFont1 )
         oCelCAB01:SetVertAlign( VERTICAL_ALIGN_CENTER )
         oCelCAB02 := AppExcCell():New(); oCelCAB02:SetCellColor("#FFFFFF"); oCelCAB02:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelCAB02:SetFont( oFont2 )
         oCelCAB02:SetVertAlign( VERTICAL_ALIGN_CENTER )
         oCelCAB03 := AppExcCell():New(); oCelCAB03:SetCellColor("#FFFFFF"); oCelCAB03:SetHorzAlign( HORIZONTAL_ALIGN_LEFT )  ; oCelCAB03:SetFont( oFont1 )
         oCelCAB03:SetVertAlign( VERTICAL_ALIGN_CENTER )
         oCelCAB04 := AppExcCell():New(); oCelCAB04:SetCellColor("#FFFFFF"); oCelCAB04:SetHorzAlign( HORIZONTAL_ALIGN_LEFT )  ; oCelCAB04:SetFont( oFont3 )
         oCelCAB04:SetVertAlign( VERTICAL_ALIGN_CENTER )
         oCelDET01 := AppExcCell():New(); oCelDET01:SetCellColor("#FFFFFF"); oCelDET01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelDET01:SetFont( oFont3 )
         oCelDET01:SetVertAlign( VERTICAL_ALIGN_CENTER )
         oCelDET02 := AppExcCell():New(); oCelDET02:SetCellColor("#FFFFFF"); oCelDET02:SetHorzAlign( HORIZONTAL_ALIGN_LEFT ); oCelDET02:SetFont( oFont3 )
         oCelDET02:SetVertAlign( VERTICAL_ALIGN_CENTER )

         oExcel   := AppExcel():New()
         _aArrEmp := FWArrFilAtu( FWGrpCompany(), _aEmpRel[ _nY] )
         
         _cNomArq := "SEGURO_" + _aArrEmp[2] + '_' + ALLTRIM( Upper( _aArrEmp[7] ) ) + "_" + mv_par01 + ".xml"

         oExcel:SetDestPath( Alltrim( mv_par05 ) )
         oExcel:SetFileName( '\dirdoc\rh\SEGURO\' + _cNomArq )

         _nLin := 1

         oExcel:Merge( _nLin, 01, 09, 00, 'LAYOUT PARA FATURAMENTO'        , oCelCAB01 )
         _nLin++
         oExcel:Merge( _nLin, 01, 01, 03, ''                               , oCelCAB02 )
         oExcel:Merge( _nLin, 03, 07, 00, 'Estipulante'                    , oCelCAB03 )
         _nLin++
         oExcel:Merge( _nLin, 03, 07, 00, Alltrim( _aArrEmp[17] )          , oCelCAB04 )
         _nLin++
         oExcel:Merge( _nLin, 03, 07, 00, 'CNPJ nº.'                       , oCelCAB03 )
         _nLin++
         oExcel:Merge( _nLin, 03, 07, 00, Iif( Len( _aArrEmp[18] ) == 14, Transform( _aArrEmp[18], '@R 99.999.999/9999-99' ), TransForm( _aArrEmp[18], '999.999.999-99') ), oCelCAB04 )
         _nLin++
         oExcel:Merge( _nLin, 01, 00, 00, 'Mês/Ano de competência'         , oCelCAB01 )
         oExcel:Merge( _nLin, 02, 00, 00, 'Cód. Segurado'                  , oCelCAB01 )
         oExcel:Merge( _nLin, 03, 00, 00, 'Capital Garantia Básica - Morte', oCelCAB01 )
         oExcel:Merge( _nLin, 04, 00, 00, 'Matrícula na Empresa'           , oCelCAB01 )
         oExcel:Merge( _nLin, 05, 00, 00, 'Nome do segurado'               , oCelCAB01 )
         oExcel:Merge( _nLin, 06, 00, 00, 'CPF do segurado'                , oCelCAB01 )
         oExcel:Merge( _nLin, 07, 00, 00, 'Admissão'                       , oCelCAB01 )
         oExcel:Merge( _nLin, 08, 00, 00, 'Sexo'                           , oCelCAB01 )
         oExcel:Merge( _nLin, 09, 00, 00, 'Data de nascimento'             , oCelCAB01 )
         oExcel:Merge( _nLin, 10, 00, 00, 'Tipo de Registro Segurado'      , oCelCAB01 )
         _nLin++
         For _nX := 1 To Len( _aDadRel )
             If _aDadRel[_nX][ 2] == _aEmpRel[_nY]
                oExcel:Merge( _nLin, 01, 00, 00, _aDadRel[_nX][ 1], oCelDET01 )
                oExcel:Merge( _nLin, 02, 00, 00, _aDadRel[_nX][ 2], oCelDET01 )
                oExcel:Merge( _nLin, 03, 00, 00, _aDadRel[_nX][ 3], oCelDET01 )
                oExcel:Merge( _nLin, 04, 00, 00, _aDadRel[_nX][ 4], oCelDET01 )
                oExcel:Merge( _nLin, 05, 00, 00, _aDadRel[_nX][ 5], oCelDET02 )
                oExcel:Merge( _nLin, 06, 00, 00, _aDadRel[_nX][ 6], oCelDET01 )
                oExcel:Merge( _nLin, 07, 00, 00, _aDadRel[_nX][ 7], oCelDET01 )
                oExcel:Merge( _nLin, 08, 00, 00, _aDadRel[_nX][ 8], oCelDET01 )
                oExcel:Merge( _nLin, 09, 00, 00, _aDadRel[_nX][ 9], oCelDET01 )
                oExcel:Merge( _nLin, 10, 00, 00, _aDadRel[_nX][10], oCelDET01 )
                _nLin++
             Endif
         Next
         oExcel:Make( .F. )
         //oExcel:SetFileName( Alltrim( mv_par05 ) + _cNomArq )
         oExcel:Destroy()
     Next _nY
     MsgInfo( 'Arquivo'+ Iif( Len( _aEmpRel ) > 1, 's ', ' ' ) + ' gerado' + Iif( Len( _aEmpRel ) > 1, 's ', ' ' ) + ' com sucesso em ' + Alltrim( mv_par05 ) + '.' , 'Informação...' )
     
Return

/*/{Protheus.doc} fDados
//Static funcion para gerar os dados para geração da planilha.
@author Luís Gustavo
@since 08/04/2020
@version 1.0
@return ${return}, ${return_description}
@param _aEmpRel, , descricao
@param _aDadRel, , descricao
@type function
/*/
Static Function fDados( _aEmpRel, _aDadRel )
       Local _lRet      := .f.
       Local _cQry1     := ""
       Local _cAliasSRA := GetNextAlias()
       Local _cCatego   := mv_par03
       Local _cCatQry   := ""
       Local _nY        := 0
       Local _cTipo     := ""
       Local _dPerIni   := STOD( mv_par01 + '01' )
       Local _dPerFim   := LastDay( _dPerIni )
       Local _aAfasta   := {}
       Local _lCont     := .t.
       
       For _nY := 1 To Len( _cCatego )
           _cCatQry += "'" + SubS( _cCatego, _nY, 1 ) + "'"
           If ( _nY + 1 ) <= Len( _cCatego )
              _cCatQry += ", "
           Endif
       Next _nY
       
       _cQry1 := "SELECT * " + CHR(13) + CHR(10)
       _cQry1 += "FROM " + RetSQLName("SRA") + " SRA " + CHR(13) + CHR(10)
       _cQry1 += "WHERE SRA.D_E_L_E_T_ = '' " + CHR(13) + CHR(10)
       If !Empty( mv_par02 )
          _cQry1 += "  AND " + mv_par02  + CHR(13) + CHR(10)
       Endif
       If !Empty( _cCatQry )
          _cQry1 += "  AND SRA.RA_CATFUNC IN(" + _cCatQry + ") " + CHR(13) + CHR(10)
       Endif
       _cQry1 += "  AND (SRA.RA_DEMISSA = '' or SRA.RA_DEMISSA >= '" + MV_PAR01 + "01' ) " + CHR(13) + CHR(10)
       _cQry1 += "ORDER BY SRA.RA_FILIAL, SRA.RA_NOME"
       
       DbUseArea( .T., "TOPCONN", TCGENQRY( , , _cQry1 ), _cAliasSRA, .f., .T. )
       DbSelectArea( _cAliasSRA )
       
       While !Eof()
             _lRet  := .T.
             _lCont := .T.
             If aScan( _aEmpRel, ( _cAliasSRA )->RA_FILIAL ) == 0
                aAdd( _aEmpRel, ( _cAliasSRA )->RA_FILIAL )
             EndIf
             If Empty( ( _cAliasSRA )->RA_SITFOLH ) .or. ( _cAliasSRA )->RA_SITFOLH == 'F'
                _cTipo := "1"
             Else
                _aAfasta := {}
                fAfastaPer( @_aAfasta, _dPerIni, _dPerFim, ( _cAliasSRA )->RA_FILIAL, ( _cAliasSRA )->RA_MAT )
                If Len( _aAfasta ) > 0
                   _cTipo := Iif( _aAfasta[1][3] $ Alltrim( mv_par07 ), '3', '1' )
                Else
                   _cTipo := '1'
                Endif 
             Endif
             If !Empty( ( _cAliasSRA )->RA_DEMISSA ) .and. STOD( ( _cAliasSRA )->RA_DEMISSA ) <= dDataBase
                _lCont := .f.
             Endif
             If mv_par06 == 1 .and. ( _cAliasSRA )->RA_CATFUNC == 'P' .AND. ( _cAliasSRA )->RA_FILIAL <> '010101'
                _lCont := .F.
             Endif
             If _lCont
                aAdd( _aDadRel, { SubStr( mv_par01, 5, 2 ) + '/' + SubStr( mv_par01, 1, 4 ), ( _cAliasSRA )->RA_FILIAL, StrZero( mv_par04 * 100, 14 ), ( _cAliasSRA )->RA_MAT, ( _cAliasSRA )->RA_NOME, ( _cAliasSRA )->RA_CIC, DTOC( STOD( ( _cAliasSRA )->RA_ADMISSA ) ), Iif( ( _cAliasSRA )->RA_SEXO == 'F', 'FEMININO', 'MASCULINO' ), DTOC( STOD( ( _cAliasSRA )->RA_NASC ) ), _cTipo } )
             Endif
             DbSelectArea( _cAliasSRA )
             ( _cAliasSRA )->( DbSkip() )
       EndDo
       DbSelectArea( _cAliasSRA )
       ( _cAliasSRA )->( DbCloseArea() )
Return _lRet
