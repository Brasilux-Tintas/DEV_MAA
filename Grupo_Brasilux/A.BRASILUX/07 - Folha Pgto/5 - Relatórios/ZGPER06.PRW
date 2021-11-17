#include 'totvs.ch'
#include 'appexcel.ch'

/*/{Protheus.doc} ZGPER06
//RELATÓRIO PARA GERAÇÃO DE EXTRATOS DE HORAS COMPENSADAS
@author Luís Gustavo de Souza
@since 11/01/2018
@version 6
@return ${return}, ${return_description}

@type function
/*/
User Function ZGPER06()
     Local   bProcess := { || ZGeraXML() }
     Private oProcess

     
     oProcess := MsNewProcess():New( bProcess, "Gerando informações...", "Aguarde", .f. )
     oProcess:Activate()
Return

Static Function ZGeraXML()
     Local oExcel, _nX, _nY
     Local _cNomArq := ""
     Local _cPerg   := "ZGPER06   "
     Local _aDadRel := {}
     Local _nTotAbo := 0
     Local _nTotLin := 0

     Private oFont1 := AppExcFont():New( "Calibri", '14', '#000000')
     Private oFont2 := AppExcFont():New( "Calibri", '12', '#000000')
     Private oFont3 := AppExcFont():New( "Calibri", '12', '#000000')
     Private oFont4 := AppExcFont():New( "Calibri", '12', '#FF0000')

     //fValPerg( _cPerg ) //Chamada da Criação das perguntas //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     If !Pergunte( _cPerg ) 
        Return() //Se cancelar as perguntas sai do programa
     Endif
     If !fDados( @_aDadRel )
        MsgAlert("Não existem dados para esse relatório")
        Return() //Se não tiver dados para impressão sai do programa
     Endif

     //CONFIGURAÇÕES DAS CELULAS
     oFont1:SetBold( .T. )
     oCelL01C01 := AppExcCell():New(); oCelL01C01:SetCellColor("#FFFFFF"); oCelL01C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL01C01:SetFont( oFont1 )
     oCelL01C01:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oFont2:SetBold( .T. )
     oCelL02C01 := AppExcCell():New(); oCelL02C01:SetCellColor("#FFFFFF"); oCelL02C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL02C01:SetFont( oFont2 )
     oCelL02C01:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL02C02 := AppExcCell():New(); oCelL02C02:SetCellColor("#FFFFFF"); oCelL02C02:SetHorzAlign( HORIZONTAL_ALIGN_LEFT ); oCelL02C02:SetFont( oFont2 )
     oCelL02C02:SetVertAlign( VERTICAL_ALIGN_CENTER )

     oCelL03C01 := AppExcCell():New(); oCelL03C01:SetCellColor("#FFFFFF"); oCelL03C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL03C01:SetFont( oFont2 )
     oCelL03C01:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL03C01:SetBorder( BORDER_POSITION_TOP   , .t. ); oCelL03C01:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL03C01:SetBorder(    BORDER_POSITION_RIGHT, .t. )
     oCelL03C01:SetLineWeigth(BORDER_POSITION_TOP, 2   ); oCelL03C01:SetLineWeigth(BORDER_POSITION_LEFT, 2   ); oCelL03C01:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )
     oCelL03C01:SetBorder(    BORDER_POSITION_BOTTOM, .t. ); oCelL03C01:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   )

     oCelL03C02 := AppExcCell():New(); oCelL03C02:SetCellColor("#FFFFFF"); oCelL03C02:SetHorzAlign( HORIZONTAL_ALIGN_RIGHT ); oCelL03C02:SetFont( oFont2 )
     oCelL03C02:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL03C02:SetBorder( BORDER_POSITION_TOP   , .t. ); oCelL03C02:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL03C02:SetBorder(    BORDER_POSITION_RIGHT, .t. )
     oCelL03C02:SetLineWeigth(BORDER_POSITION_TOP, 2   ); oCelL03C02:SetLineWeigth(BORDER_POSITION_LEFT, 2   ); oCelL03C02:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )
     oCelL03C02:SetBorder(    BORDER_POSITION_BOTTOM, .t. ); oCelL03C02:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   )

     oCelL04C01 := AppExcCell():New(); oCelL04C01:SetCellColor("#FFFFFF"); oCelL04C01:SetHorzAlign( HORIZONTAL_ALIGN_LEFT ); oCelL04C01:SetFont( oFont3 )
     oCelL04C01:SetBorder( BORDER_POSITION_BOTTOM, .t. ); oCelL04C01:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL04C01:SetBorder(    BORDER_POSITION_RIGHT, .t. )
     oCelL04C01:SetLineWeigth(BORDER_POSITION_BOTTOM, 1   ); oCelL04C01:SetLineWeigth(BORDER_POSITION_LEFT, 2   ); oCelL04C01:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )

     oCelL04C02 := AppExcCell():New(); oCelL04C02:SetCellColor("#FFFFFF"); oCelL04C02:SetHorzAlign( HORIZONTAL_ALIGN_RIGHT ); oCelL04C02:SetFont( oFont3 )
     oCelL04C02:SetBorder( BORDER_POSITION_BOTTOM, .t. ); oCelL04C02:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL04C02:SetBorder(    BORDER_POSITION_RIGHT, .t. )
     oCelL04C02:SetLineWeigth(BORDER_POSITION_BOTTOM, 1   ); oCelL04C02:SetLineWeigth(BORDER_POSITION_LEFT, 2   ); oCelL04C02:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )

     oCelL04C03 := AppExcCell():New(); oCelL04C03:SetCellColor("#FFFFFF"); oCelL04C03:SetHorzAlign( HORIZONTAL_ALIGN_LEFT ); oCelL04C03:SetFont( oFont3 )
     oCelL04C03:SetBorder( BORDER_POSITION_BOTTOM, .t. ); oCelL04C03:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL04C03:SetBorder(    BORDER_POSITION_RIGHT, .t. )
     oCelL04C03:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   ); oCelL04C03:SetLineWeigth(BORDER_POSITION_LEFT, 2   ); oCelL04C03:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )

     oCelL04C04 := AppExcCell():New(); oCelL04C02:SetCellColor("#FFFFFF"); oCelL04C04:SetHorzAlign( HORIZONTAL_ALIGN_RIGHT ); oCelL04C04:SetFont( oFont3 )
     oCelL04C04:SetBorder( BORDER_POSITION_BOTTOM, .t. ); oCelL04C04:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL04C04:SetBorder(    BORDER_POSITION_RIGHT, .t. )
     oCelL04C04:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   ); oCelL04C04:SetLineWeigth(BORDER_POSITION_LEFT, 2   ); oCelL04C04:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )

     oCelL05C01 := AppExcCell():New(); oCelL05C01:SetCellColor("#FFFFFF"); oCelL05C01:SetHorzAlign( HORIZONTAL_ALIGN_LEFT ); oCelL05C01:SetFont( oFont4 )
     oCelL05C01:SetBorder( BORDER_POSITION_BOTTOM, .t. ); oCelL05C01:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL05C01:SetBorder(    BORDER_POSITION_RIGHT, .t. )
     oCelL05C01:SetLineWeigth(BORDER_POSITION_BOTTOM, 1   ); oCelL05C01:SetLineWeigth(BORDER_POSITION_LEFT, 2   ); oCelL05C01:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )
     oCelL06C01 := AppExcCell():New(); oCelL06C01:SetCellColor("#FFFFFF"); oCelL06C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL06C01:SetFont( oFont2 )
     oCelL06C01:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL06C01:SetBorder( BORDER_POSITION_TOP   , .t. )
     oCelL06C01:SetLineWeigth(BORDER_POSITION_TOP, 2   )

     If ! ExistDir( mv_par04 )
        MakeDir( mv_par04 )
     Endif
     oProcess:IncRegua1( "Imprimindo informações..." )
     oProcess:SetRegua2( Len( _aDadRel ) )
     If mv_par09 == 1
        For _nY := 1 TO Len( _aDadRel )
            oProcess:IncRegua2( Alltrim( _aDadRel[ _nY ][ 2] ) + ' - ' + _aDadRel[ _nY ][ 3] )
            _cNomArq := "EXTRATO" + "_" + _aDadRel[ _nY ][ 1] + "_" + Alltrim( _aDadRel[ _nY ][ 2] ) + "_" + DTOS( mv_par03 ) + ".xml"
            _nTotAbo := 0
            oExcel   := AppExcel():New()
            oExcel:SetDestPath( Alltrim( mv_par04 ) )
            oExcel:SetFileName( '\dirdoc\rh\ponto\' + _cNomArq )

            _nLin := 1
            oExcel:SetSheetName( Alltrim( _aDadRel[ _nY][2] ) )

            //Cabeçalho
            oExcel:Merge( _nLin, 01, 05, 01, 'EXTRATO DE HORAS COMPENSADAS - ' + DTOC( MV_PAR03 )       , oCelL01C01 )
            _nLin += 2
            oExcel:Merge( _nLin, 01, 05, 00, ''                                                         , oCelL02C01 )
            _nLin += 1
            oExcel:Merge( _nLin, 02, 05, 00, _aDadRel[ _nY][ 2] + ' - ' + _aDadRel[ _nY][ 3]            , oCelL02C02 )
            _nLin += 1
            oExcel:Merge( _nLin, 01, 00, 00, ''                                                         , oCelL02C01 )
            oExcel:Merge( _nLin, 02, 00, 00, 'DATA'                                                     , oCelL03C01 )
            oExcel:Merge( _nLin, 03, 00, 00, 'HR ABONADA(-)'                                            , oCelL03C01 )
            oExcel:Merge( _nLin, 04, 00, 00, 'HR COMPENSADA(+)'                                         , oCelL03C01 )
            oExcel:Merge( _nLin, 05, 00, 00, 'TOTAL'                                                    , oCelL03C01 )
            oExcel:Merge( _nLin, 06, 00, 00, ''                                                         , oCelL02C01 )
            _nLin += 1

            _nTotAbo -= HoraToInt( StrZero( Int( _aDadRel[ _nY][ 8] ), 2 ) + ':' + StrZero( ( _aDadRel[ _nY][ 8] - Int( _aDadRel[ _nY][ 8] ) ) * 100, 2 ) )
            oExcel:AddCell( _nLin, 01, ' '                                                              , oCelL02C01 )
            oExcel:AddCell( _nLin, 02, DTOC( STOD( _aDadRel[ _nY][ 5] ) )                               , oCelL04C01 )
            oExcel:AddCell( _nLin, 03, _aDadRel[ _nY][ 8]                                               , oCelL04C02 )
            oExcel:AddCell( _nLin, 04, ' '                                                              , oCelL04C02 )
            oExcel:AddCell( _nLin, 05, _aDadRel[ _nY][ 8]                                               , oCelL04C02 )
            oExcel:AddCell( _nLin, 06, ' '                                                              , oCelL02C01 )
            _nLin += 1
            If Len( _aDadRel[ _nY][ 9] ) > 0
               For _nX := 1 To Len( _aDadRel[ _nY][ 9] )
                   oExcel:AddCell( _nLin, 01, ' '                                                       , oCelL02C01 )
                   oExcel:AddCell( _nLin, 02, DTOC( STOD( _aDadRel[ _nY][ 9][ _nX][ 1] ) )              , oCelL04C01 )
                   oExcel:AddCell( _nLin, 03, ' '                                                       , oCelL04C02 )
                   oExcel:AddCell( _nLin, 04, _aDadRel[ _nY][ 9][ _nX][ 2]                              , oCelL04C02 )
                   oExcel:AddCell( _nLin, 05, _aDadRel[ _nY][ 9][ _nX][ 2]                              , oCelL04C02 )
                   oExcel:AddCell( _nLin, 06, ' '                                                       , oCelL02C01 )
                   _nTotAbo += HoraToInt( StrZero( Int( _aDadRel[ _nY][ 9][ _nX][ 2] ), 2 ) + ':' + StrZero( ( _aDadRel[ _nY][ 9][ _nX][ 2] - Int( _aDadRel[ _nY][ 9][ _nX][ 2] ) ) * 100, 2 ) )
                   _nLin += 1
               Next
            Endif
            //Totalizador
            oExcel:Merge( _nLin, 01, 00, 00, ''                                                         , oCelL02C01 )
            oExcel:Merge( _nLin, 02, 02, 00, 'TOTAL'                                                    , oCelL03C01 )
            oExcel:AddCell( _nLin, 05, IntToHora( _nTotAbo )                                            , oCelL03C02 )
            oExcel:Merge( _nLin, 06, 00, 00, ''                                                         , oCelL02C01 )
            _nLin += 1
            //Rodapé
            oExcel:Merge( _nLin, 01, 05, 00, ''                                                         , oCelL02C01 )

            oExcel:Make( .F. )
            oExcel:SetFileName( Alltrim( mv_par04 ) + _cNomArq )
            oExcel:Destroy()
        Next
     Else
        _cNomArq := "EXTRATO_SINTETICO_DE_HORAS_" + DTOS( mv_par03 ) + ".xml"
        _nTotAbo := 0
        oExcel   := AppExcel():New()
        oExcel:SetDestPath( Alltrim( mv_par04 ) )
        oExcel:SetFileName( '\dirdoc\rh\ponto\' + _cNomArq )

        _nLin := 1
        oExcel:SetSheetName( Alltrim( 'Horas' ) )

        //Cabeçalho
        oExcel:Merge( _nLin, 01, 07, 01, 'EXTRATO DE HORAS COMPENSADAS - ' + DTOC( MV_PAR03 )       , oCelL01C01 )
        _nLin += 2
        oExcel:Merge( _nLin, 01, 07, 00, ''                                                         , oCelL02C01 )
        _nLin += 1
        oExcel:Merge( _nLin, 01, 00, 00, ''                                                         , oCelL02C01 )
        oExcel:Merge( _nLin, 02, 00, 00, 'FILIAL'                                                   , oCelL03C01 )
        oExcel:Merge( _nLin, 03, 00, 00, 'MATR.'                                                    , oCelL03C01 )
        oExcel:Merge( _nLin, 04, 00, 00, 'NOME'                                                     , oCelL03C01 )
        oExcel:Merge( _nLin, 05, 00, 00, 'HR ABONADA(-)'                                            , oCelL03C01 )
        oExcel:Merge( _nLin, 06, 00, 00, 'HR COMPENSADA(+)'                                         , oCelL03C01 )
        oExcel:Merge( _nLin, 07, 00, 00, 'TOTAL'                                                    , oCelL03C01 )
        oExcel:Merge( _nLin, 08, 00, 00, ''                                                         , oCelL02C01 )
        _nLin += 1
        For _nY := 1 TO Len( _aDadRel )
            oProcess:IncRegua2( Alltrim( _aDadRel[ _nY ][ 2] ) + ' - ' + _aDadRel[ _nY ][ 3] )
            _nTotAbo := 0; _nTotLin := 0
            _nTotAbo -= HoraToInt( StrZero( Int( _aDadRel[ _nY][ 8] ), 2 ) + ':' + StrZero( ( _aDadRel[ _nY][ 8] - Int( _aDadRel[ _nY][ 8] ) ) * 100, 2 ) )
            oExcel:AddCell( _nLin, 01, ' '                                                              , oCelL02C01 )
            If _nY <> Len( _aDadRel )
               oExcel:AddCell( _nLin, 02, _aDadRel[ _nY][ 1]                                               , oCelL04C01 )
               oExcel:AddCell( _nLin, 03, _aDadRel[ _nY][ 2]                                               , oCelL04C01 )
               oExcel:AddCell( _nLin, 04, _aDadRel[ _nY][ 3]                                               , oCelL04C01 )
               oExcel:AddCell( _nLin, 05, IntToHora( _nTotAbo )                                            , oCelL04C02 )
               If Len( _aDadRel[ _nY][ 9] ) > 0
                  For _nX := 1 To Len( _aDadRel[ _nY][ 9] )
                      _nTotLin += HoraToInt( StrZero( Int( _aDadRel[ _nY][ 9][ _nX][ 2] ), 2 ) + ':' + StrZero( ( _aDadRel[ _nY][ 9][ _nX][ 2] - Int( _aDadRel[ _nY][ 9][ _nX][ 2] ) ) * 100, 2 ) )
                  Next
               Endif
               oExcel:AddCell( _nLin, 06, IntToHora( _nTotLin )                                            , oCelL04C02 )
               oExcel:AddCell( _nLin, 07, IntToHora( _nTotAbo + _nTotLin )                                 , oCelL04C02 )
            Else
               oExcel:AddCell( _nLin, 02, _aDadRel[ _nY][ 1]                                               , oCelL04C03 )
               oExcel:AddCell( _nLin, 03, _aDadRel[ _nY][ 2]                                               , oCelL04C03 )
               oExcel:AddCell( _nLin, 04, _aDadRel[ _nY][ 3]                                               , oCelL04C03 )
               oExcel:AddCell( _nLin, 05, IntToHora( _nTotAbo )                                            , oCelL04C04 )
               If Len( _aDadRel[ _nY][ 9] ) > 0
                  For _nX := 1 To Len( _aDadRel[ _nY][ 9] )
                      _nTotLin += HoraToInt( StrZero( Int( _aDadRel[ _nY][ 9][ _nX][ 2] ), 2 ) + ':' + StrZero( ( _aDadRel[ _nY][ 9][ _nX][ 2] - Int( _aDadRel[ _nY][ 9][ _nX][ 2] ) ) * 100, 2 ) )
                  Next
               Endif
               oExcel:AddCell( _nLin, 06, IntToHora( _nTotLin )                                            , oCelL04C03 )
               oExcel:AddCell( _nLin, 07, IntToHora( _nTotAbo + _nTotLin )                                 , oCelL04C03 )
            Endif
            oExcel:AddCell( _nLin, 08, ' '                                                              , oCelL02C01 )
            _nLin += 1
        Next
        //Rodapé
        oExcel:Merge( _nLin, 01, 07, 00, ''                                                         , oCelL02C01 )

        oExcel:Make( .F. )
        oExcel:SetFileName( Alltrim( mv_par04 ) + _cNomArq )
        oExcel:Destroy()
     Endif
     MsgInfo( 'Arquivo' + Iif( Len( _aDadRel ) > 1, 's ', ' ') + ' gerado' + Iif( Len( _aDadRel ) > 1, 's ', ' ') + ' com sucesso em ' + Alltrim( mv_par04 ) + '.' , 'Informação...' )

Return

Static Function fDados( _aDadRel )
       Local _lRet      := .f.
       Local _cQryPRI   := ""
       Local _cQryAUX   := ""
       Local _aDadAux   := {}
       //Local _dDatIni   := Alltrim( SubStr( GetMV("MV_PAPONTA"), 1, AT( '/', GetMV("MV_PAPONTA") ) - 1 ) ) 
       //Local _dDatFim   := Alltrim( SubStr( GetMV("MV_PAPONTA"), AT( '/', GetMV("MV_PAPONTA") ) + 1 ) )
       Local _cAliasPRI := GetNextAlias()
       Local _cAliasAUX := GetNextAlias()

       oProcess:SetRegua1( 2 ) //Numero de Processos que serão executados
       oProcess:IncRegua1( "Gerando informações..." )
       oProcess:SetRegua2( 150 )
       //_cQryPRI := "SELECT SPC.PC_FILIAL AS FILIAL, SPC.PC_MAT AS MAT, SRA.RA_NOME AS NOME, SPC.PC_PD AS PD, SPC.PC_DATA AS DTLANC, SPC.PC_QUANTC AS QUANT, SPC.PC_ABONO AS ABONO, SPC.PC_QTABONO AS QTABONO " + CHR(13) + CHR(10)
       //_cQryPRI += "FROM " + RetSQLName("SPC") + " SPC " + CHR(13) + CHR(10)
       //_cQryPRI += "LEFT JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL = SPC.PC_FILIAL AND SRA.D_E_L_E_T_ = ' ' AND SRA.RA_MAT = SPC.PC_MAT " + CHR(13) + CHR(10)
       //_cQryPRI += "WHERE SPC.PC_FILIAL  BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CHR(13) + CHR(10)
       //_cQryPRI += "  AND SPC.D_E_L_E_T_ = ' ' " + CHR(13) + CHR(10)
       //_cQryPRI += "  AND SPC.PC_DATA    = '" + DTOS(MV_PAR03 ) + "' " + CHR(13) + CHR(10)
       //_cQryPRI += "  AND SPC.PC_ABONO  <> ' ' " + CHR(13) + CHR(10)
       //_cQryPRI += "  AND SRA.RA_MAT BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + CHR(13) + CHR(10)
       //_cQryPRI += "UNION ALL " + CHR(13) + CHR(10)
       _cQryPRI += "SELECT SPK.PK_FILIAL AS FILIAL, SPK.PK_MAT AS MAT, SRA.RA_NOME AS NOME, SPK.PK_CODEVE AS PD, SPK.PK_DATA AS DTLANC, SPK.PK_HRSABO AS QUANT, SPK.PK_CODABO AS ABONO, SPK.PK_HRSABO  AS QTABONO "
       _cQryPRI += "FROM " + RetSQLName("SPK") + " SPK "
       _cQryPRI += "LEFT JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL = SPK.PK_FILIAL AND SRA.D_E_L_E_T_ = ' ' AND SRA.RA_MAT = SPK.PK_MAT "
       _cQryPRI += "WHERE SPK.PK_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CHR(13) + CHR(10)
       _cQryPRI += "  AND SPK.D_E_L_E_T_ = ' ' "
       _cQryPRI += "  AND SPK.PK_DATA    = '" + DTOS(MV_PAR03 ) + "' " + CHR(13) + CHR(10)
       _cQryPRI += "  AND SPK.PK_CODABO <> ' ' " + CHR(13) + CHR(10)
       _cQryPRI += "  AND SPK.PK_MAT BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + CHR(13) + CHR(10)
       _cQryPRI += "ORDER BY 1, 2 " + CHR(13) + CHR(10)
       //_cQryPRI += "SELECT SPH.PH_FILIAL AS FILIAL, SPH.PH_MAT AS MAT, SRA.RA_NOME AS NOME, SPH.PH_PD AS PD, SPH.PH_DATA AS DTLANC, SPH.PH_QUANTC AS QUANT, SPH.PH_ABONO AS ABONO, SPH.PH_QTABONO AS QTABONO " + CHR(13) + CHR(10)
       //_cQryPRI += "FROM " + RetSQLName("SPH") + " SPH " + CHR(13) + CHR(10)
       //_cQryPRI += "LEFT JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL = SPH.PH_FILIAL AND SRA.D_E_L_E_T_ = ' ' AND SRA.RA_MAT = SPH.PH_MAT " + CHR(13) + CHR(10)
       //_cQryPRI += "WHERE SPH.PH_FILIAL  BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CHR(13) + CHR(10)
       //_cQryPRI += "  AND SPH.D_E_L_E_T_ = ' ' " + CHR(13) + CHR(10)
       //_cQryPRI += "  AND SPH.PH_DATA    = '" + DTOS(MV_PAR03 ) + "' " + CHR(13) + CHR(10)
       //_cQryPRI += "  AND SPH.PH_ABONO  <> ' ' " + CHR(13) + CHR(10)
       //_cQryPRI += "  AND SRA.RA_MAT BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + CHR(13) + CHR(10)
       //_cQryPRI += "ORDER BY 1, 2 " + CHR(13) + CHR(10) 
       DbUseArea( .T., "TOPCONN", TCGENQRY( , , _cQryPRI ), _cAliasPRI, .f., .T. )
       DbSelectArea( _cAliasPRI )
       While !Eof()
             aAdd( _aDadRel, { ( _cAliasPRI )->FILIAL, ( _cAliasPRI )->MAT, ( _cAliasPRI )->NOME, ( _cAliasPRI )->PD, ( _cAliasPRI )->DTLANC, ( _cAliasPRI )->QUANT, ( _cAliasPRI )->ABONO, ( _cAliasPRI )->QTABONO, {} } )
             oProcess:IncRegua2( Alltrim( ( _cAliasPRI )->MAT ) + ' - ' + ( _cAliasPRI )->NOME )
             _aDadAux := {}
             _cQryAux := "SELECT SPC.PC_FILIAL AS FILIAL, SPC.PC_MAT AS MAT, SRA.RA_NOME AS NOME, SPC.PC_PD AS PD, SPC.PC_DATA AS DTLANC, SPC.PC_QUANTC AS QUANT, SPC.PC_ABONO AS ABONO, SPC.PC_QTABONO AS QTABONO " + CHR(13) + CHR(10)
             _cQryAux += "FROM " + RetSQLName("SPC") + " SPC " + CHR(13) + CHR(10)
             _cQryAux += "LEFT JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL = SPC.PC_FILIAL AND SRA.D_E_L_E_T_ = ' ' AND SRA.RA_MAT = SPC.PC_MAT " + CHR(13) + CHR(10)
             _cQryAux += "WHERE SPC.PC_FILIAL  = '" + ( _cAliasPRI )->FILIAL + "' " + CHR(13) + CHR(10)
             _cQryAux += "  AND SPC.D_E_L_E_T_ = ' ' " + CHR(13) + CHR(10)
             _cQryAux += "  AND SPC.PC_DATA   <> '" + DTOS(MV_PAR03 ) + "' " + CHR(13) + CHR(10)
             _cQryAux += "  AND SPC.PC_DATA  BETWEEN '" + DTOS(MV_PAR07 ) + "' AND '" + DTOS(MV_PAR08 ) + "' " + CHR(13) + CHR(10)
             _cQryAux += "  AND SPC.PC_ABONO   = '" + ( _cAliasPRI )->ABONO + "' " + CHR(13) + CHR(10)
             _cQryAux += "  AND SPC.PC_MAT     = '" + ( _cAliasPRI )->MAT + "' " + CHR(13) + CHR(10)
             _cQryAux += "UNION ALL " + CHR(13) + CHR(10)
             _cQryAux += "SELECT SPK.PK_FILIAL AS FILIAL, SPK.PK_MAT AS MAT, SRA.RA_NOME AS NOME, SPK.PK_CODEVE AS PD, SPK.PK_DATA AS DTLANC, SPK.PK_HRSABO AS QUANT, SPK.PK_CODABO AS ABONO, SPK.PK_HRSABO  AS QTABONO "
             _cQryAux += "FROM " + RetSQLName("SPK") + " SPK "
             _cQryAux += "LEFT JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL = SPK.PK_FILIAL AND SRA.D_E_L_E_T_ = ' ' AND SRA.RA_MAT = SPK.PK_MAT "
             _cQryAux += "WHERE SPK.PK_FILIAL   = '" + ( _cAliasPRI )->FILIAL + "' " + CHR(13) + CHR(10)
             _cQryAux += "  AND SPK.D_E_L_E_T_  = ' ' "
             _cQryAux += "  AND SPK.PK_DATA    <> '" + DTOS(MV_PAR03 ) + "' " + CHR(13) + CHR(10)
             _cQryAux += "  AND SPK.PK_DATA  BETWEEN '" + DTOS(MV_PAR07 ) + "' AND '" + DTOS(MV_PAR08 ) + "' " + CHR(13) + CHR(10)
             _cQryAux += "  AND SPK.PK_CODABO   = '" + ( _cAliasPRI )->ABONO + "' " + CHR(13) + CHR(10)
             _cQryAux += "  AND SPK.PK_MAT      = '" + ( _cAliasPRI )->MAT + "' " + CHR(13) + CHR(10)
             _cQryAux += "ORDER BY 1, 2 " + CHR(13) + CHR(10)
             //_cQryAux += "SELECT SPH.PH_FILIAL AS FILIAL, SPH.PH_MAT AS MAT, SRA.RA_NOME AS NOME, SPH.PH_PD AS PD, SPH.PH_QUANTC AS QUANT, SPH.PH_ABONO AS ABONO, SPH.PH_QTABONO AS QTABONO, SPH.PH_DATA AS DATA " + CHR(13) + CHR(10)
             //_cQryAux += "FROM " + RetSQLName("SPH") + " SPH " + CHR(13) + CHR(10)
             //_cQryAux += "LEFT JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL = SPH.PH_FILIAL AND SRA.D_E_L_E_T_ = ' ' AND SRA.RA_MAT = SPH.PH_MAT " + CHR(13) + CHR(10)
             //_cQryAux += "WHERE SPH.PH_FILIAL  = '" + ( _cAliasPRI )->FILIAL + "' " + CHR(13) + CHR(10)
             //_cQryAux += "  AND SPH.D_E_L_E_T_ = ' ' " + CHR(13) + CHR(10)
             //_cQryAux += "  AND SPH.PH_DATA   <> '" + DTOS(MV_PAR03 ) + "' " + CHR(13) + CHR(10)
             //_cQryAux += "  AND SPH.PH_DATA BETWEEN '" + DTOS(MV_PAR07 ) + "' AND '" + DTOS(MV_PAR08 ) + "' " + CHR(13) + CHR(10)
             //_cQryAux += "  AND SPH.PH_ABONO   = '" + ( _cAliasPRI )->ABONO + "' " + CHR(13) + CHR(10)
             //_cQryAux += "  AND SPH.PH_MAT     = '" + ( _cAliasPRI )->MAT + "' " + CHR(13) + CHR(10)
             //_cQryAux += "ORDER BY 1, 2 " + CHR(13) + CHR(10)
             DbUseArea( .T., "TOPCONN", TCGENQRY( , , _cQryAUX ), _cAliasAUX, .f., .T. )
             DbSelectArea( _cAliasAUX )
             While !Eof()
                   If aScan( _aDadAux, { |x| x[1] + x[3] == ( _cAliasAUX )->DTLANC + ( _cAliasAUX )->PD } ) == 0
                      aAdd( _aDadAux, { ( _cAliasAUX )->DTLANC, ( _cAliasAUX )->QTABONO, ( _cAliasAUX )->PD } )
                   Endif
                   DbSelectArea( _cAliasAUX )
                   ( _cAliasAUX )->( DbSkip( ) )
             EndDo
             DbSelectArea( _cAliasAUX )
             ( _cAliasAUX )->( DbCloseArea( ) )
             
             If Len( _aDadAux ) > 0
                _aDadRel[ Len( _aDadRel ) ][ 9] := _aDadAux
             Endif

             DbSelectArea( _cAliasPRI )
             ( _cAliasPRI )->( DbSkip( ) )
       EndDo
       DbSelectArea( _cAliasPRI )
       ( _cAliasPRI )->( DbCloseArea( ) )

       If Len( _aDadRel ) > 0
          _lRet := .t.
       Endif
Return _lRet
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*
Static Function fValPerg( _cPerg )
       Local _aArea   := GetArea()
       Local aHelpPor := {}
       //Local aHelpEng := {}
       //Local aHelpSpa := {}

       //           X1_GRUPO , X1_ORDEM, X1_PERGUNT             , X1_VAR01  , X1_VARIAVL, X1_TIPO, X1_TAMANHO, X1_DECIMAL, X1_GSC, X1_VALID    , X1_F3   , X1_PICTURE , X1_DEF01   , X1_DEF02         , X1_DEF03, X1_DEF04, X1_DEF05, X1_HELP
       //u_zPutSX1( _cPerg   , "01"    , "Codigo do Armazem    ", "mv_par01", "mv_ch1"  , "C"    ,  2        , 0         , "G"   , ""          , "NNR"   , ""         , ""         , ""               , ""      , ""      , ""      , aHelpPor[1] )
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "01" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código da Filial Inicial para Filtro dos dados." )
          u_zPutSX1( _cPerg   , "01"    , "Filial De ?          ", "mv_par01", "mv_ch1"  , "C"    ,  6        , 0         , "G"   , ""             , "XM0"   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "02" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código da Filial Final para Filtro dos dados." )
          u_zPutSX1( _cPerg   , "02"    , "Filial Até ?         ", "mv_par02", "mv_ch2"  , "C"    ,  6        , 0         , "G"   , "NaoVazio"     , "XM0"   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "03" ) )
          aAdd( aHelpPor, "Informe para qual data deseja emitir o extrato." )
          u_zPutSX1( _cPerg   , "03"    , "Data Compensada?"     , "mv_par03", "mv_ch3"  , "D"    ,  8        , 0         , "G"   , ""             , "   "   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "04" ) )
          aAdd( aHelpPor, "Informe o diretório para gravação da planilha." )
          u_zPutSX1( _cPerg   , "04"    , "Diretorio ? "         , "mv_par04", "mv_ch4"  , "C"    ,  30       , 0         , "G"   , ""             , "   "   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "05" ) )
          aAdd( aHelpPor, "Informe a Matricula Inicial para Filtro dos dados." )
          u_zPutSX1( _cPerg   , "05"    , "Matricula De ?       ", "mv_par05", "mv_ch5"  , "C"    ,  6        , 0         , "G"   , ""             , "SRA"   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "06" ) )
          aAdd( aHelpPor, "Informe a Matricula Final para Filtro dos dados." )
          u_zPutSX1( _cPerg   , "06"    , "Matricula Até ?         ", "mv_par06", "mv_ch6"  , "C"    ,  6        , 0         , "G"   , "NaoVazio"     , "SRA"   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "07" ) )
          aAdd( aHelpPor, "Informe a Data Inicial para Filtro das compensações." )
          u_zPutSX1( _cPerg   , "07"    , "Da data de compensação?", "mv_par07", "mv_ch7"  , "D"    ,  8        , 0         , "G"   , ""             , "   "   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "08" ) )
          aAdd( aHelpPor, "Informe a Data Final para Filtro das compensações." )
          u_zPutSX1( _cPerg   , "08"    , "Até data de compensação?", "mv_par08", "mv_ch8"  , "D"    ,  8        , 0         , "G"   , "NaoVazio"     , "   "   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "09" ) )
          aAdd( aHelpPor, "Informe se o relatório será analitico (uma planilha por funcionário) ou sintético." )
          u_zPutSX1( _cPerg   , "09"    , "Até data de compensação?", "mv_par09", "mv_ch9"  , "N"    ,  1        , 0         , "C"   , "NaoVazio"     , "   "   , ""        , "Analitico" , "Sintético"      , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
*/
/*
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "05" ) )
          aAdd( aHelpPor, "Informe o tipo de horas a ser impresso.")
          u_zPutSX1( _cPerg   , "05"    , "Tipo de Horas?        ", "mv_par05", "mv_ch5"  , "N"    ,  1        , 0         , "C"   , ""               , "   "   , ""        , "Centesimal", "Sexagenal"      , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "06" ) )
          aAdd( aHelpPor, "Informe a situação do funcionário.")
          u_zPutSX1( _cPerg   , "06"    , "Situação?        "     , "mv_par06", "mv_ch6"  , "C"    ,  5        , 0         , "G"   , "FSituacao()" , "   "   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "07" ) )
          aAdd( aHelpPor, "Informe a categoria do funcionário.")
          u_zPutSX1( _cPerg   , "07"    , "Categoria?       "     , "mv_par07", "mv_ch7"  , "C"    , 15        , 0         , "G"   , "FCategoria()", "   "   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "08" ) )
          aAdd( aHelpPor, "Motivos de Abono/Justificativa a serem considerados para calculo do Vale Transporte." )
          u_zPutSX1( _cPerg   , "08"    , "Motivo Abono"          , "mv_par08", "mv_ch8"  , "C"    , 60        , 0         , "G"   , ""             , "   "   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "09" ) )
          aAdd( aHelpPor, "Motivos de Abono/Justificativa a serem considerados para calculo do Vale Transporte, porém com valor diferenciado no valor do V.A." )
          u_zPutSX1( _cPerg   , "09"    , "Motivo Abono Diferenciado", "mv_par09", "mv_ch9"  , "C"    , 60        , 0         , "G"   , ""             , "   "   , ""        , ""          , ""               , ""      , ""      , ""   , aHelpPor[1]  )
       Endif
       aHelpPor := {}
*//*
       RestArea( _aArea )
Return*/