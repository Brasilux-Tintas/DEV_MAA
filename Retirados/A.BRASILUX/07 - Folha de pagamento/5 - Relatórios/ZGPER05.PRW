#include 'totvs.ch'
#include 'appexcel.ch'

/*/{Protheus.doc} ZGPER05
//RELATÓRIO PARA GERAÇÃO DE VALORES PARA VALECARD - VALE ALIMENTAÇÃO
@author Luís Gustavo de Souza
@since 28/12/2018
@version 6
@return ${return}, ${return_description}

@type function
/*/
User Function ZGPER05()
     Local oExcel   := AppExcel():New()
     Local _cNomArq := ""
     Local _cPerg   := "ZGPER05   "
     Local _aEmpRel := {}
     Local _aDadRel := {}
     Local _aTabVA  := {}
     Local _nY, _nX
     Private MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08
     Private oFont1 := AppExcFont():New( "Calibri", '14', '#000000')
     Private oFont2 := AppExcFont():New( "Calibri", '12', '#000000')
     Private oFont3 := AppExcFont():New( "Calibri", '12', '#000000')
     Private oFont4 := AppExcFont():New( "Calibri", '12', '#FF0000')

     //fValPerg( _cPerg ) //Chamada da Criação das perguntas  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     If !Pergunte( _cPerg ) 
        Return() //Se cancelar as perguntas sai do programa
     Else
        If !Empty( MV_PAR05 )
           _cSit	:= "'"
           For _nY := 1 To Len( Alltrim( MV_PAR05 ) )
               If Substr( MV_PAR05, _nY, 1 ) <> '*'
                  _cSit += Substr( MV_PAR05, _nY, 1 ) + "', '"
               EndIf
           Next
           MV_PAR05 := Substr( _cSit, 1, Len( _cSit ) - 3 )
        Else
           MV_PAR05 := "' '"
        EndIf

        If !Empty( MV_PAR06 )
           _cCateg := "'"
           For _nY := 1 To Len( Alltrim( MV_PAR06 ) )
               If Substr( MV_PAR06, _nY, 1 ) <> '*'
                  _cCateg += Substr( MV_PAR06, _nY, 1 ) + "', '"
               EndIf
           Next
           MV_PAR06 := Substr( _cCateg, 1, Len( _cCateg ) - 3 )
        Else
           MV_PAR06:="' '"
        EndIf
     Endif
     fCarrTab( @_aTabVA, "U003" )
     If !fDados( @_aEmpRel, @_aDadRel, _aTabVA )
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
     oCelL03C01 := AppExcCell():New(); oCelL03C01:SetCellColor("#FFFFFF"); oCelL03C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL03C01:SetFont( oFont2 )
     oCelL03C01:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL03C01:SetBorder( BORDER_POSITION_TOP   , .t. ); oCelL03C01:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL03C01:SetBorder(    BORDER_POSITION_RIGHT, .t. )
     oCelL03C01:SetLineWeigth(BORDER_POSITION_TOP, 2   ); oCelL03C01:SetLineWeigth(BORDER_POSITION_LEFT, 2   ); oCelL03C01:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )
     oCelL03C01:SetBorder(    BORDER_POSITION_BOTTOM, .t. ); oCelL03C01:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   )
     oCelL04C01 := AppExcCell():New(); oCelL04C01:SetCellColor("#FFFFFF"); oCelL04C01:SetHorzAlign( HORIZONTAL_ALIGN_LEFT ); oCelL04C01:SetFont( oFont3 )
     oCelL04C01:SetBorder( BORDER_POSITION_BOTTOM, .t. ); oCelL04C01:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL04C01:SetBorder(    BORDER_POSITION_RIGHT, .t. )
     oCelL04C01:SetLineWeigth(BORDER_POSITION_BOTTOM, 1   ); oCelL04C01:SetLineWeigth(BORDER_POSITION_LEFT, 2   ); oCelL04C01:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )
     oCelL05C01 := AppExcCell():New(); oCelL05C01:SetCellColor("#FFFFFF"); oCelL05C01:SetHorzAlign( HORIZONTAL_ALIGN_LEFT ); oCelL05C01:SetFont( oFont4 )
     oCelL05C01:SetBorder( BORDER_POSITION_BOTTOM, .t. ); oCelL05C01:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL05C01:SetBorder(    BORDER_POSITION_RIGHT, .t. )
     oCelL05C01:SetLineWeigth(BORDER_POSITION_BOTTOM, 1   ); oCelL05C01:SetLineWeigth(BORDER_POSITION_LEFT, 2   ); oCelL05C01:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )
     oCelL06C01 := AppExcCell():New(); oCelL06C01:SetCellColor("#FFFFFF"); oCelL06C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL06C01:SetFont( oFont2 )
     oCelL06C01:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL06C01:SetBorder( BORDER_POSITION_TOP   , .t. )
     oCelL06C01:SetLineWeigth(BORDER_POSITION_TOP, 2   )
     oCelL06C02 := AppExcCell():New(); oCelL06C02:SetCellColor("#FFFFFF"); oCelL06C02:SetHorzAlign( HORIZONTAL_ALIGN_RIGHT ); oCelL06C02:SetFont( oFont2 )
     oCelL06C02:SetFormat( NUMBER_CURRENCY_REAL ); oCelL06C02:SetBorder(    BORDER_POSITION_RIGHT, .t. ); oCelL06C02:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )

     oCelL06C03 := AppExcCell():New(); oCelL06C03:SetCellColor("#FFFFFF"); oCelL06C03:SetHorzAlign( HORIZONTAL_ALIGN_RIGHT ); oCelL06C03:SetFont( oFont2 )
     oCelL06C03:SetFormat( NUMBER_CURRENCY_REAL )
     oCelL06C03:SetBorder(    BORDER_POSITION_RIGHT , .t. ); oCelL06C03:SetLineWeigth(BORDER_POSITION_RIGHT , 2   )
     oCelL06C03:SetBorder(    BORDER_POSITION_LEFT  , .t. ); oCelL06C03:SetLineWeigth(BORDER_POSITION_LEFT  , 2   )
     oCelL06C03:SetBorder(    BORDER_POSITION_TOP   , .t. ); oCelL06C03:SetLineWeigth(BORDER_POSITION_TOP   , 2   )
     oCelL06C03:SetBorder(    BORDER_POSITION_BOTTOM, .t. ); oCelL06C03:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   )

     _cNomArq := "VALECARD_" + "_" + mv_par03 + "_" + DTOS( dDataBase ) + "_" + StrTran( Time(), ":", "" ) + ".xml"

     oExcel:SetDestPath( Alltrim( mv_par04 ) )
     oExcel:SetFileName( '\dirdoc\rh\' + _cNomArq )
     If ! ExistDir( mv_par04 )
          MakeDir( mv_par04 )
     Endif
     
     For _nY := 1 To Len ( _aEmpRel )
         _nLin   := 1
         _nSomaT := 0
         _cCodEmp := SubStr( _aEmpRel[ _nY ], 1, 2 )
         _aArrEmp := FWArrFilAtu( FWGrpCompany(), _aEmpRel[ _nY] )
         If _nY == 1
            oExcel:SetSheetName( Alltrim( _aArrEmp[7] ) )
         Else
            oExcel:AddSheet( Alltrim( _aArrEmp[7] ) )
         Endif
         //Cabeçalho
         oExcel:Merge( _nLin, 01, 05, 01, 'VALE ALIMENTAÇÃO - ' + Transform( SubStr(MV_PAR03, 5, 2) + SubStr(MV_PAR03, 1, 4), "@R 99/9999" ), oCelL01C01 )
         _nLin += 2
         oExcel:Merge( _nLin, 01, 05, 00, ''                                                         , oCelL02C01 )
         _nLin += 1
         oExcel:Merge( _nLin, 01, 00, 00, ''                                                         , oCelL02C01 )
         oExcel:Merge( _nLin, 02, 00, 00, 'MAT.'                                                     , oCelL03C01 )
         oExcel:Merge( _nLin, 03, 00, 00, 'NOME'                                                     , oCelL03C01 )
         oExcel:Merge( _nLin, 04, 00, 00, 'OCORRÊNCIA'                                               , oCelL03C01 )
         oExcel:Merge( _nLin, 05, 00, 00, 'VALOR'                                                    , oCelL03C01 )
         oExcel:Merge( _nLin, 06, 00, 00, ''                                                         , oCelL02C01 )
         _nLin += 1
         //Impressão dos dados
         For _nX := 1 TO Len( _aDadRel )
             If _aEmpRel[ _nY] == _aDadRel[ _nX][1]
                oExcel:Merge( _nLin, 01, 00, 00, ''                                                         , oCelL02C01 )
                oExcel:AddCell( _nLin,  2, _aDadRel[ _nX][ 2]                                               , oCelL04C01 )
                oExcel:AddCell( _nLin,  3, _aDadRel[ _nX][ 3]                                               , oCelL04C01 )
                oExcel:AddCell( _nLin,  4, _aDadRel[ _nX][ 4]                                               , oCelL05C01 )
                oExcel:AddCell( _nLin,  5, _aDadRel[ _nX][ 5]                                               , oCelL06C02 )
                oExcel:Merge( _nLin, 06, 00, 00, ''                                                         , oCelL02C01 )
                _nSomaT += _aDadRel[ _nX][ 5]
             Else

             Endif
             _nLin += 1
         Next
         //Totalizador
         oExcel:Merge( _nLin, 01, 00, 00, ''                                                         , oCelL02C01 )
         oExcel:Merge( _nLin, 02, 02, 00, 'TOTAL'                                                    , oCelL03C01 )
         oExcel:Merge( _nLin, 05, 00, 00, _nSomaT                                                    , oCelL06C03 )
         oExcel:Merge( _nLin, 06, 00, 00, ''                                                         , oCelL02C01 )
         _nLin += 1
         //Rodapé
         oExcel:Merge( _nLin, 01, 05, 00, ''                                                         , oCelL02C01 )
         _nLin += 1
         oExcel:Merge( _nLin, 01, 05, 00, ''                                                         , oCelL02C01 )
         _nLin += 1
         oExcel:Merge( _nLin, 01, 05, 00, ''                                                         , oCelL02C01 )
         _nLin += 1
         oExcel:Merge( _nLin, 01, 00, 00, ''                                                         , oCelL02C01 )
         oExcel:Merge( _nLin, 02, 00, 00, ''                                                         , oCelL02C01 )
         oExcel:Merge( _nLin, 03, 00, 00, ''                                                         , oCelL02C01 )
         oExcel:Merge( _nLin, 04, 00, 00, 'DIRETORIA'                                                , oCelL06C01 )
         oExcel:Merge( _nLin, 05, 00, 00, ''                                                         , oCelL02C01 )
         oExcel:Merge( _nLin, 06, 00, 00, ''                                                         , oCelL02C01 )
         _nLin += 1
         oExcel:Merge( _nLin, 01, 05, 00, ''                                                         , oCelL02C01 )
     Next
     oExcel:Make( .F. )
     oExcel:SetFileName( Alltrim( mv_par04 ) + _cNomArq )
     oExcel:Destroy()
     MsgInfo( 'Arquivo '+ _cNomArq + ' gerado com sucesso em ' + Alltrim( mv_par04 ) + '.' , 'Informação...' )

Return

Static Function fDados( _aEmpRel, _aDadRel, _aTabVA )
       Local _lRet      := .f.
       Local _lPerAbe   := .T.
       Local _cQry1     := ""
       Local _cQrySPO   := ""
       Local _cQrySRA   := ""
       Local _cQryTNY   := ""
       //Local _cQrySPK   := ""
       //Local _cQrySR8   := ""
       //Local _dDatIni   := "" 
       Local _dDatFim   := ""
       Local _cOcorren  := ""
       Local _nTotalHO  := ""
       Local _nHoras    := 0
       Local _nValor    := 0
       //Local _nQtdAte   := 0
       Local _nX        := 0
       Local _nY        := 0
       Local _aMatAbo   := {}
       Local _aDesAbn   := {}
       Local _cAliasSPO := GetNextAlias()
       Local _cAliasSRA := GetNextAlias()
       Local _cAliasTMP := GetNextAlias()
       Local _cAliasTNY := GetNextAlias()
       //Local _cAliasSPK := GetNextAlias()
       //Local _cAliasSR8 := GetNextAlias()
       //Local _cVerAbono := fVerPar()
       Local _aAuxApur  := {}

       _cQrySPO := "SELECT SPO.PO_DATAINI, SPO.PO_DATAFIM, SPO.PO_FLAGFEC " + CHR(13) + CHR(10)
       _cQrySPO += "FROM " + RetSQLName("SPO") + " SPO " + CHR(13) + CHR(10)
       _cQrySPO += "WHERE SPO.D_E_L_E_T_ = ' ' " + CHR(13) + CHR(10)
       _cQrySPO += "  AND SUBSTRING( SPO.PO_DATAFIM, 1, 6 ) = '" + mv_par03 + "' " + CHR(13) + CHR(10)
       DbUseArea( .T., "TOPCONN", TCGENQRY( , , _cQrySPO ), _cAliasSPO, .f., .T. )
       DbSelectArea( _cAliasSPO )
       If ( _cAliasSPO )->PO_FLAGFEC == '0'
          _dDatIni := ( _cAliasSPO )->PO_DATAINI 
          _dDatFim := ( _cAliasSPO )->PO_DATAFIM
          _lPerAbe := .f. //Periodo Fechado
       Else //Se o periodo for aberto
          _dDatIni := Alltrim( SubStr( GetMV("MV_PAPONTA"), 1, AT( '/', GetMV("MV_PAPONTA") ) - 1 ) )
          _dDatFim := Alltrim( SubStr( GetMV("MV_PAPONTA"), AT( '/', GetMV("MV_PAPONTA") ) + 1 ) )
          _lPerAbe := .t. //Periodo Aberto
       Endif
       DbSelectArea( _cAliasSPO )
       ( _cAliasSPO )->( DbCloseArea() )
       
       _cQrySRA := "SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, TM0.TM0_NUMFIC, SRA.RA_HRSDIA, SRA.RA_HRSEMAN, SRA.RA_HRSMES, SRA.RA_CATEFD, SRA.RA_CC " + CHR(13) + CHR(10)
       _cQrySRA += "FROM " + RetSQLName("SRA") + " SRA " + CHR(13) + CHR(10)
       _cQrySRA += "LEFT JOIN TM0010 TM0 ON TM0.TM0_FILIAL = '" + xFilial("TM0") + "' AND TM0.D_E_L_E_T_ = ' ' AND TM0.TM0_FILFUN = SRA.RA_FILIAL AND TM0.TM0_MAT = SRA.RA_MAT " + CHR(13) + CHR(10)
       _cQrySRA += "WHERE SRA.RA_FILIAL  BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' " + CHR(13) + CHR(10)
       _cQrySRA += "  AND SRA.D_E_L_E_T_ = ' ' " + CHR(13) + CHR(10)
       _cQrySRA += "  AND SRA.RA_SITFOLH IN(" + mv_par05 + ") " + CHR(13) + CHR(10)
       _cQrySRA += "  AND SRA.RA_CATFUNC IN(" + mv_par06 + ") " + CHR(13) + CHR(10)
       //_cQrySRA += "  AND SRA.RA_MAT = '103' "
       _cQrySRA += "ORDER BY SRA.RA_FILIAL, SRA.RA_NOME "
       DbUseArea( .T., "TOPCONN", TCGENQRY( , , _cQrySRA ), _cAliasSRA, .f., .T. )
       DbSelectArea( _cAliasSRA )
       While !Eof()
             If _lPerAbe //Periodo Aberto - SPB
                _cQry1 := "SELECT SPB.PB_PD AS PRODES, SRV.RV_DESC AS DESVER, SUM( SPB.PB_HORAS ) AS HORAS, SPB.PB_DATA AS DTAPT  " + CHR(13) + CHR(10)
                _cQry1 += "FROM " + RetSQLName("SPB") + " SPB " + CHR(13) + CHR(10)
                _cQry1 += "LEFT JOIN " + RetSQLName("SRV") + " SRV ON SRV.RV_FILIAL = SUBSTRING(SPB.PB_FILIAL, 1, 2) AND SRV.RV_COD = SPB.PB_PD AND SRV.D_E_L_E_T_ = ' ' " + CHR(13) + CHR(10)
                _cQry1 += "WHERE SPB.PB_FILIAL  = '" + ( _cAliasSRA )->RA_FILIAL + "' " + CHR(13) + CHR(10)
                _cQry1 += "  AND SPB.D_E_L_E_T_ = ' ' " + CHR(13) + CHR(10)
                _cQry1 += "  AND SPB.PB_DATA    = '" + _dDatFim + "' " + CHR(13) + CHR(10)
                _cQry1 += "  AND SPB.PB_MAT     = '" + ( _cAliasSRA )->RA_MAT + "' " + CHR(13) + CHR(10)
                _cQry1 += "  AND SPB.PB_PD     IN('421', '423', '424', '490') " + CHR(13) + CHR(10)  //VERBAS QUE CONSIDERA NO DESCONTO DO VALE CARD
                _cQry1 += "GROUP BY SPB.PB_PD, SRV.RV_DESC, SPB.PB_DATA " + CHR(13) + CHR(10)
                _cQry1 += "ORDER BY SPB.PB_PD " + CHR(13) + CHR(10)
             Else //Periodo Fechado - SPL
                _cQry1 := "SELECT SPH.PH_FILIAL, SPH.PH_MAT, SPH.PH_DATA AS DTAPT, SPH.PH_QUANTC AS HORAS, SPH.PH_ABONO, SPH.PH_QTABONO, SP9.P9_CODIGO, SP9.P9_DESC AS DESVER, SP9.P9_CODFOL AS PRODES " + CHR(13) + CHR(10)
                _cQry1 += "FROM " + RetSQLName("SPH") + " SPH " + CHR(13) + CHR(10)
                _cQry1 += "LEFT JOIN " + RetSQLName("SP9") + " SP9 ON SP9.P9_FILIAL = SUBSTRING( SPH.PH_FILIAL, 1, 2)  AND SP9.D_E_L_E_T_ = ' ' AND SP9.P9_CODIGO = SPH.PH_PD " + CHR(13) + CHR(10)
                _cQry1 += "WHERE SPH.PH_FILIAL  = '" + ( _cAliasSRA )->RA_FILIAL + "' " + CHR(13) + CHR(10)
                _cQry1 += "  AND SPH.D_E_L_E_T_ = ' ' " + CHR(13) + CHR(10)
                _cQry1 += "  AND SPH.PH_MAT = '" + ( _cAliasSRA )->RA_MAT + "' " + CHR(13) + CHR(10)
                _cQry1 += "  AND SPH.PH_DATA BETWEEN '" + _dDatIni + "' AND '" + _dDatFim + "' " + CHR(13) + CHR(10)
                _cQry1 += "  AND SPH.PH_ABONO <> ' ' " + CHR(13) + CHR(10)
                _cQry1 += "  AND SP9.P9_CODFOL IN('421', '423', '424', '490') " + CHR(13) + CHR(10) //VERBAS QUE CONSIDERA NO DESCONTO DO VALE CARD
                /*
                _cQry1 := "SELECT SPL.PL_PD AS PRODES, SRV.RV_DESC AS DESVER, SUM( SPL.PL_HORAS ) AS HORAS, SPL.PL_DATA AS DTAPT " + CHR(13) + CHR(10)
                _cQry1 += "FROM " + RetSQLName("SPL") + " SPL " + CHR(13) + CHR(10)
                _cQry1 += "LEFT JOIN " + RetSQLName("SRV") + " SRV ON SRV.RV_FILIAL = SUBSTRING(SPL.PL_FILIAL, 1, 2) AND SRV.RV_COD = SPL.PL_PD AND SRV.D_E_L_E_T_ = ' ' " + CHR(13) + CHR(10)
                _cQry1 += "WHERE SPL.PL_FILIAL  = '" + ( _cAliasSRA )->RA_FILIAL + "' " + CHR(13) + CHR(10)
                _cQry1 += "  AND SPL.D_E_L_E_T_ = ' ' " + CHR(13) + CHR(10)
                _cQry1 += "  AND SPL.PL_DATA    = '" + _dDatFim + "' " + CHR(13) + CHR(10)
                _cQry1 += "  AND SPL.PL_MAT     = '" + ( _cAliasSRA )->RA_MAT + "' " + CHR(13) + CHR(10)
                _cQry1 += "  AND SPL.PL_PD     IN('421', '423', '424', '490') " + CHR(13) + CHR(10) //VERBAS QUE CONSIDERA NO DESCONTO DO VALE CARD
                _cQry1 += "GROUP BY SPL.PL_PD, SRV.RV_DESC, SPL.PL_DATA " + CHR(13) + CHR(10)
                _cQry1 += "ORDER BY SPL.PL_PD " + CHR(13) + CHR(10)
                */
             Endif
             DbUseArea( .T., "TOPCONN", TCGENQRY( , , _cQry1 ), _cAliasTMP, .f., .T. )
             DbSelectArea( _cAliasTMP )

             //Separação das empresas/filiais
             If aScan( _aEmpRel, ( _cAliasSRA )->RA_FILIAL ) == 0
                aAdd( _aEmpRel, ( _cAliasSRA )->RA_FILIAL )
             EndIf
             
             //ANÁLISE DE RESULTADOS DO PONTO
             _cOcorren := "PONTO: "
             _nTotalHO := 0
             _aAuxApur := {}
             While !Eof()
                   /*bloqueio em 28/02/2019 para analise
                   //_nHoras := ( _cAliasTMP )->HORAS
                   //_cOcorren += Alltrim( ( _cAliasTMP )->DESVER ) + '(' + SubStr( ( _cAliasTMP )->DTAPT, 7, 2 ) + '/' + SubStr( ( _cAliasTMP )->DTAPT, 5, 2 ) + ') = ' + StrZero( int( ( _cAliasTMP )->HORAS ), 2) + ":" + StrZero( ( ( _cAliasTMP )->HORAS - int( ( _cAliasTMP )->HORAS ) ) * 100, 2 ) + " / "
                   //_nTotalHO += _nHoras*/
                   If aScan( _aAuxApur, { |x| x[1]+x[2]+x[3]+x[5] == ( _cAliasSRA )->RA_FILIAL + ( _cAliasSRA )->RA_MAT + ( _cAliasTMP )->DTAPT + ( _cAliasTMP )->PH_ABONO } ) == 0
                                      // 1                          2                       3                      4                      5                         6                           7                          8                       9                       10       11   12    13
                                      // FILIAL                     MATRICULA               DATA                   HORAS                  COD.ABONO                 HORAS ABONADAS              CODIGO                     DESCRICAO VERBA         PRODES                  CONTADOR DIAS HORAS CONTADOR
                      aAdd( _aAuxApur, { ( _cAliasSRA )->RA_FILIAL, ( _cAliasSRA )->RA_MAT, ( _cAliasTMP )->DTAPT, ( _cAliasTMP )->HORAS, ( _cAliasTMP )->PH_ABONO, ( _cAliasTMP )->PH_QTABONO, ( _cAliasTMP )->P9_CODIGO, ( _cAliasTMP )->DESVER, ( _cAliasTMP )->PRODES, 1,       0,   0,    0  } )
                   Else
                      _aAuxApur[ aScan( _aAuxApur, { |x| x[1]+x[2]+x[3]+x[5] == ( _cAliasSRA )->RA_FILIAL + ( _cAliasSRA )->RA_MAT + ( _cAliasTMP )->DTAPT + ( _cAliasTMP )->PH_ABONO } ) ][  4] += ( _cAliasTMP )->HORAS
                      _aAuxApur[ aScan( _aAuxApur, { |x| x[1]+x[2]+x[3]+x[5] == ( _cAliasSRA )->RA_FILIAL + ( _cAliasSRA )->RA_MAT + ( _cAliasTMP )->DTAPT + ( _cAliasTMP )->PH_ABONO } ) ][  6] += ( _cAliasTMP )->HORAS
                      _aAuxApur[ aScan( _aAuxApur, { |x| x[1]+x[2]+x[3]+x[5] == ( _cAliasSRA )->RA_FILIAL + ( _cAliasSRA )->RA_MAT + ( _cAliasTMP )->DTAPT + ( _cAliasTMP )->PH_ABONO } ) ][ 10] += 1
                   Endif
                   DbSelectArea( _cAliasTMP )
                   ( _cAliasTMP )->( DbSkip() )
             EndDo
             If _nTotalHO == 0
                _cOcorren := ""
             Else
                _cOcorren := SubStr( _cOcorren, 1, Len( _cOcorren ) - 3 )
             Endif
             DbSelectArea( _cAliasTMP )
             ( _cAliasTMP )->( DbCloseArea() )

             //ATESTADOS MÉDICOS
             _aMatAbo := {}
             If !Empty( ( _cAliasSRA )->TM0_NUMFIC )
                _cQryTNY := "SELECT * " + CHR(13) + CHR(10)
                _cQryTNY += "FROM " + RetSQLName("TNY") + " TNY " + CHR(13) + CHR(10)
                _cQryTNY += "WHERE TNY.D_E_L_E_T_ = ' ' " + CHR(13) + CHR(10)
                _cQryTNY += "  AND TNY.TNY_DTINIC BETWEEN '" + _dDatIni + "' AND '" + _dDatFim + "' " + CHR(13) + CHR(10)
                _cQryTNY += "  AND TNY.TNY_NUMFIC = '" + ( _cAliasSRA )->TM0_NUMFIC + "' " + CHR(13) + CHR(10)
                //_cQryTNY += "  AND TNY.TNY_CODABO NOT IN "+ _cVerAbono + " " + CHR(13) + CHR(10)
                DbUseArea( .T., "TOPCONN", TCGENQRY( , , _cQryTNY ), _cAliasTNY, .f., .T. )
                DbSelectArea( _cAliasTNY )
                While !Eof()
                      //Apurar atestados
                      If ( _cAliasTNY )->TNY_DTINIC == ( _cAliasTNY )->TNY_DTFIM
                         _nHorasAT := SubStr( ElapTime ( ( _cAliasTNY )->TNY_HRINIC + ":00", ( _cAliasTNY )->TNY_HRFIM+":00" ), 1, 5)
                         _nHoras   := Val( SubStr( _nHorasAT, 1, 2) ) + ( Val( SubStr( _nHorasAT, 4, 2) ) / 100 )
                         If aScan( _aAuxApur, { |x| x[1]+x[2]+x[3]+x[5] == ( _cAliasSRA )->RA_FILIAL + ( _cAliasSRA )->RA_MAT + ( _cAliasTNY )->TNY_DTINIC + ( _cAliasTNY )->TNY_CODABO } ) == 0
                                            // 1                          2                       3                          4     5                           6              7      8               9      10       11   12       13
                                            // FILIAL                     MATRICULA               DATA                       HORAS COD.ABONO                   HORAS ABONADAS CODIGO DESCRICAO VERBA PRODES CONTADOR DIAS HORAS    CONTADOR
                            aAdd( _aAuxApur, { ( _cAliasSRA )->RA_FILIAL, ( _cAliasSRA )->RA_MAT, ( _cAliasTNY )->TNY_DTINIC, 0,   ( _cAliasTNY )->TNY_CODABO, 0,             ' ',   ' ',            ' ',   0,       1,   _nHoras, 1 } )
                         Else
                            _aAuxApur[ aScan( _aAuxApur, { |x| x[1]+x[2]+x[3]+x[5] == ( _cAliasSRA )->RA_FILIAL + ( _cAliasSRA )->RA_MAT + ( _cAliasTNY )->TNY_DTINIC + ( _cAliasTNY )->TNY_CODABO } ) ][ 11] += 1
                            _aAuxApur[ aScan( _aAuxApur, { |x| x[1]+x[2]+x[3]+x[5] == ( _cAliasSRA )->RA_FILIAL + ( _cAliasSRA )->RA_MAT + ( _cAliasTNY )->TNY_DTINIC + ( _cAliasTNY )->TNY_CODABO } ) ][ 12] += _nHoras
                            _aAuxApur[ aScan( _aAuxApur, { |x| x[1]+x[2]+x[3]+x[5] == ( _cAliasSRA )->RA_FILIAL + ( _cAliasSRA )->RA_MAT + ( _cAliasTNY )->TNY_DTINIC + ( _cAliasTNY )->TNY_CODABO } ) ][ 13] += 1
                         Endif
                      Else
                         _nDiaAfa := STOD( ( _cAliasTNY )->TNY_DTFIM ) - STOD( ( _cAliasTNY )->TNY_DTINIC )
                         If aScan( _aAuxApur, { |x| x[1]+x[2]+x[3]+x[5] == ( _cAliasSRA )->RA_FILIAL + ( _cAliasSRA )->RA_MAT + ( _cAliasTNY )->TNY_DTINIC + ( _cAliasTNY )->TNY_CODABO } ) == 0
                            aAdd( _aAuxApur, { ( _cAliasSRA )->RA_FILIAL, ( _cAliasSRA )->RA_MAT, ( _cAliasTNY )->TNY_DTINIC, 0, ( _cAliasTNY )->TNY_CODABO, 0, ' ', ' ', ' ', 0, _nDiaAfa,  0, 1    } )
                         Else
                            _aAuxApur[ aScan( _aAuxApur, { |x| x[1]+x[2]+x[3]+x[5] == ( _cAliasSRA )->RA_FILIAL + ( _cAliasSRA )->RA_MAT + ( _cAliasTNY )->TNY_DTINIC + ( _cAliasTNY )->TNY_CODABO } ) ][ 11] += _nDiaAfa
                            _aAuxApur[ aScan( _aAuxApur, { |x| x[1]+x[2]+x[3]+x[5] == ( _cAliasSRA )->RA_FILIAL + ( _cAliasSRA )->RA_MAT + ( _cAliasTNY )->TNY_DTINIC + ( _cAliasTNY )->TNY_CODABO } ) ][ 12] += 0
                            _aAuxApur[ aScan( _aAuxApur, { |x| x[1]+x[2]+x[3]+x[5] == ( _cAliasSRA )->RA_FILIAL + ( _cAliasSRA )->RA_MAT + ( _cAliasTNY )->TNY_DTINIC + ( _cAliasTNY )->TNY_CODABO } ) ][ 13] += 1
                         Endif
                         
                      Endif
                      /*bloqueio em 28/02/2019 para analise
                      If ( _cAliasTNY )->TNY_DTINIC == ( _cAliasTNY )->TNY_DTFIM
                         _nHorasAT := SubStr( ElapTime ( ( _cAliasTNY )->TNY_HRINIC + ":00", ( _cAliasTNY )->TNY_HRFIM+":00" ), 1, 5)
                         _nHoras   := Val( SubStr( _nHorasAT, 1, 2) ) + ( Val( SubStr( _nHorasAT, 4, 2) ) / 100 )
                      Else
                         _nQtdAte := 0
                      Endif
                      _nPosABO := aScan( _aMatAbo, { |x| x[1]+x[2]+x[3]+x[4] == ( _cAliasSRA )->RA_FILIAL + ( _cAliasSRA )->RA_MAT + ( _cAliasTNY )->TNY_DTINIC + ( _cAliasTNY )->TNY_CODABO } )
                      If _nPosABO == 0
                         aAdd( _aMatAbo, { ( _cAliasSRA )->RA_FILIAL, ( _cAliasSRA )->RA_MAT, ( _cAliasTNY )->TNY_DTINIC, ( _cAliasTNY )->TNY_CODABO, _nHoras, 0, 'A' } )
                      Else
                         _hAux01 := _aMatAbo[ _nPosABO][ 5]
                         _hAux01 := horatoint( StrZero( int( _hAux01 ), 2 ) + ":" + StrZero( ( ( _hAux01 - int( _hAux01 ) ) * 100 ), 2 ) )
                         _hAux02 := _nHoras
                         _hAux02 := horatoint( StrZero( int( _hAux02 ), 2 ) + ":" + StrZero( ( ( _hAux02 - int( _hAux02 ) ) * 100 ), 2 ) )
                         _hAuxTo := Inttohora( _hAux01 + _hAux02 )
                         _hAuxTo := Val( SubStr( _hAuxTo, 1, 2 ) ) + ( Val( SubStr( _hAuxTo, 4, 2 ) ) / 100 )
                         _aMatAbo[ _nPosABO][ 5] := _hAuxTo //Posição 5 é referente as horas de atestado, considerando a busca no aScan
                      Endif */
                      DbSelectArea( _cAliasTNY )
                      ( _cAliasTNY )->( DbSkip() )
                EndDo
                DbSelectArea( _cAliasTNY )
                ( _cAliasTNY )->( DbCloseArea() )
             Endif

/* REAVALIAR UTILIZACAO
             //ANALISE DE ABONOS
             _cQrySPK := "SELECT SPK.PK_FILIAL, SPK.PK_MAT, SPK.PK_DATA, SPK.PK_CODABO, SP6.P6_DESC, SPK.PK_HRSABO " + CHR(13) + CHR(10)
             _cQrySPK += "FROM " + RetSQLName("SPK") + " SPK " + CHR(13) + CHR(10)
             _cQrySPK += "LEFT JOIN " + RetSQLName("SP6") + " SP6 ON SP6.P6_FILIAL = '" + xFilial("SP6") + "' AND SP6.D_E_L_E_T_ = ' ' AND SP6.P6_CODIGO = SPK.PK_CODABO " + CHR(13) + CHR(10)
             _cQrySPK += "WHERE SPK.PK_FILIAL  = '" + ( _cAliasSRA )->RA_FILIAL + "' " + CHR(13) + CHR(10)
             _cQrySPK += "  AND SPK.D_E_L_E_T_ = ' ' " + CHR(13) + CHR(10)
             _cQrySPK += "  AND SPK.PK_MAT = '" + ( _cAliasSRA )->RA_MAT + "' " + CHR(13) + CHR(10)
             _cQrySPK += "  AND SPK.PK_DATA BETWEEN '" + _dDatIni + "' AND '" + _dDatFim + "' " + CHR(13) + CHR(10)
             _cQrySPK += "ORDER BY SPK.PK_MAT " + CHR(13) + CHR(10)
             DbUseArea( .T., "TOPCONN", TCGENQRY( , , _cQrySPK ), _cAliasSPK, .f., .T. )
             DbSelectArea( _cAliasSPK )
             While !Eof()
                   _nPosABO := aScan( _aMatAbo, { |x| x[1]+x[2]+x[3] == ( _cAliasSPK )->PK_FILIAL + ( _cAliasSPK )->PK_MAT + ( _cAliasSPK )->PK_DATA } ) 
                   If _nPosABO > 0
                      If _aMatAbo[ _nPosABO ][ 4] == ( _cAliasSPK )->PK_CODABO
                         _aMatAbo[ _nPosABO ][ 6] := ( _cAliasSPK )->PK_HRSABO
                         _aMatAbo[ _nPosABO ][ 7] := 'P'
                      Else
                         aAdd( _aMatAbo, { ( _cAliasSRA )->RA_FILIAL, ( _cAliasSRA )->RA_MAT, ( _cAliasSPK )->PK_DATA, ( _cAliasSPK )->PK_CODABO, 0, ( _cAliasSPK )->PK_HRSABO, 'P' } )
                      Endif
                   Else
                      aAdd( _aMatAbo, { ( _cAliasSRA )->RA_FILIAL, ( _cAliasSRA )->RA_MAT, ( _cAliasSPK )->PK_DATA, ( _cAliasSPK )->PK_CODABO, 0, ( _cAliasSPK )->PK_HRSABO, 'P' } )
                   Endif
                   DbSelectArea( _cAliasSPK )
                   ( _cAliasSPK )->( DbSkip() )
             EndDo
             DbSelectArea( _cAliasSPK )
             ( _cAliasSPK )->( DbCloseArea() )
*/

/* REAVALIAR UTILIZACAO
             //VERIFICAR AUSENCIAS DA FOLHA
             _cQrySR8 := "SELECT * "
             _cQrySR8 += "FROM " + RetSQLName("SR8") + " SR8 "
             _cQrySR8 += "WHERE SR8.R8_FILIAL  = '" + ( _cAliasSRA )->RA_FILIAL + "' "
             _cQrySR8 += "  AND SR8.R8_MAT     = '" + ( _cAliasSRA )->RA_MAT + "' "
             _cQrySR8 += "  AND SR8.R8_TIPOAFA = '006' "
             DbUseArea( .T., "TOPCONN", TCGENQRY( , , _cQrySR8 ), _cAliasSR8, .f., .T. )
             DbSelectArea( _cAliasSR8 )
             While !Eof()
                   If Stod( _dDatIni ) >= Stod( ( _cAliasSR8 )->R8_DATAINI)
                      _nDiaAfa := Stod( _dDatIni ) - Stod( ( _cAliasSR8 )->R8_DATAINI)
                      If _nDiaAfa < ( _cAliasSR8 )->R8_DURACAO
                         aAdd( _aMatAbo, { ( _cAliasSRA )->RA_FILIAL, ( _cAliasSRA )->RA_MAT, STOD( ( _cAliasSR8 )->R8_DATAINI ), '006', 0, 0, 'P' } )
                      Endif
                   Endif
                   DbSelectArea( _cAliasSR8 )
                   ( _cAliasSR8 )->( DbSkip() )
             EndDo
             DbSelectArea( _cAliasSR8 )
             ( _cAliasSR8 )->( DbCloseArea() )
*/

             //AVALIAR TOTAL DE HORAS X TABELA DO VALE ALIMENTAÇÃO
             _lValFix := .f.
             For _nY := 1 To Len( _aAuxApur )
                 If Alltrim( _aAuxApur[ _nY][ 5] ) $ Alltrim( mv_par07 )
                    _nTotalHO += _aAuxApur[ _nY][ 6]
                    _cOcorren += Iif( Len( _cOcorren ) == 0, '', ' | ' )
                    _cOcorren += 'ATES.(' + SubStr( _aAuxApur[ _nY][ 3], 7, 2 ) + '/' + SubStr( _aAuxApur[ _nY][ 3], 5, 2 ) + ') - ' + StrZero( int( _aAuxApur[ _nY][ 6] ), 2) + ":" + StrZero( ( _aAuxApur[ _nY][ 6] - int( _aAuxApur[ _nY][ 6] ) ) * 100, 2 )
                 ElseIf Alltrim( _aAuxApur[ _nY][ 5] ) $ Alltrim( mv_par08 )
                        _lValFix := .T.
                        _cOcorren += Iif( Len( _cOcorren ) == 0, '', ' | ' )
                        _cOcorren += 'ATES.(' + SubStr( _aAuxApur[ _nY][ 3], 7, 2 ) + '/' + SubStr( _aAuxApur[ _nY][ 3], 5, 2 ) + ') - ' + StrZero( int( _aAuxApur[ _nY][ 6] ), 2) + ":" + StrZero( ( _aAuxApur[ _nY][ 6] - int( _aAuxApur[ _nY][ 6] ) ) * 100, 2 )
                 ElseIf Alltrim( _aAuxApur[ _nY][ 5] ) $ Alltrim( mv_par09 )
                        xxx := 2 
                 Endif
             Next
             /*
             _aDesAbn := {}
             For _nY := 1 To Len( _aMatAbo )
                 If Alltrim( _aMatAbo[ _nY][ 4] ) $ Alltrim( mv_par07 )
                    _nTotalHO += Iif( _aMatAbo[ _nY][ 7] == 'P', _aMatAbo[ _nY][ 6], _aMatAbo[ _nY][ 5] ) // Verifica posição 7, se for P=Ponto é o que irá prevalescer.
                    _cOcorren += Iif( Len( _cOcorren ) == 0, '', ' | ' )
                    _cOcorren += 'ATESTADO(' + SubStr( _aMatAbo[ _nY][ 3], 7, 2 ) + '/' + SubStr( _aMatAbo[ _nY][ 3], 5, 2 ) + ') - ' + StrZero( int( _aMatAbo[ _nY][ 6] ), 2) + ":" + StrZero( ( _aMatAbo[ _nY][ 6] - int( _aMatAbo[ _nY][ 6] ) ) * 100, 2 )
                 ElseIf Alltrim( _aMatAbo[ _nY][ 4] ) $ Alltrim( mv_par08 )
                        _lValFix := .T.
                        _cOcorren += Iif( Len( _cOcorren ) == 0, '', ' | ' )
                        _cOcorren += 'ATESTADO(' + SubStr( _aMatAbo[ _nY][ 3], 7, 2 ) + '/' + SubStr( _aMatAbo[ _nY][ 3], 5, 2 ) + ') - ' + StrZero( int( _aMatAbo[ _nY][ 6] ), 2) + ":" + StrZero( ( _aMatAbo[ _nY][ 6] - int( _aMatAbo[ _nY][ 6] ) ) * 100, 2 )
                 ElseIf Alltrim( _aMatAbo[ _nY][ 4] ) $ Alltrim( mv_par09 )
                        _nPosDes := aScan( _aDesAbn, { |x| x[1] == _aMatAbo[ _nY][ 4] } )
                        If _nPosDes <= 0
                           aAdd( _aDesAbn, { _aMatAbo[ _nY][ 4], fBusEve( _aMatAbo[ _nY][ 4] ) } )
                        Endif
                 Endif
             Next
             */
             If _lValFix .and. Len( _cOcorren ) <= 0 
                For _nX := 1 To Len( _aTabVA ) 
                    If ( _cAliasSRA )->RA_FILIAL == _aTabVA[ _nX][ 2] .and. _aTabVA[ _nX][ 5] == 'F'    //VALOR FIXO
                       If _nTotalHo >= _aTabVA[ _nX][ 6]  .and. _nTotalHo <= _aTabVA[ _nX][ 7]
                          _nValor := _aTabVA[ _nX][ 8]
                       Endif
                    Endif
                Next
             Else
                If ( _cAliasSRA )->RA_HRSMES >= 220.00
                   For _nX := 1 To Len( _aTabVA ) 
                       If ( _cAliasSRA )->RA_FILIAL == _aTabVA[ _nX][ 2] .and. _aTabVA[ _nX][ 5] == 'N' //NORMAL
                          If _nTotalHo >= _aTabVA[ _nX][ 6]  .and. _nTotalHo <= _aTabVA[ _nX][ 7]
                             _nValor := _aTabVA[ _nX][ 8]
                          Endif
                       Endif
                   Next
                ElseIf ( _cAliasSRA )->RA_CATEFD <> '103' .and. ( _cAliasSRA )->RA_HRSMES < 220.00      //TELEFONISTA
                       For _nX := 1 To Len( _aTabVA )
                           If ( _cAliasSRA )->RA_FILIAL == _aTabVA[ _nX][ 2] .and. _aTabVA[ _nX][ 5] == 'T'
                              If _nTotalHo >= _aTabVA[ _nX][ 6]  .and. _nTotalHo <= _aTabVA[ _nX][ 7]
                                 _nValor := _aTabVA[ _nX][ 8]
                              Endif
                           Endif
                       Next
                ElseIf ( _cAliasSRA )->RA_CATEFD == '103'                                               //MENOR APRENDIZ
                       For _nX := 1 To Len( _aTabVA )
                           If ( _cAliasSRA )->RA_FILIAL == _aTabVA[ _nX][ 2] .and. _aTabVA[ _nX][ 5] == 'M'
                              If _nTotalHo >= _aTabVA[ _nX][ 6]  .and. _nTotalHo <= _aTabVA[ _nX][ 7]
                                 _nValor := _aTabVA[ _nX][ 8]
                              Endif
                           Endif
                       Next
                Endif
             Endif
             If Len( _aDesAbn ) > 0
                For _nY := 1 To Len( _aDesAbn )
                    _cOcorren += _aDesAbn[ _nY][ 2] += " / "
                Next
                _cOcorren := SubStr( _cOcorren, 1, Len( _cOcorren ) - 3 )
             Endif
             //Adicionar na matriz com os dados
             aAdd( _aDadRel, { ( _cAliasSRA )->RA_FILIAL, ( _cAliasSRA )->RA_MAT, ( _cAliasSRA )->RA_NOME, _cOcorren, _nValor, ( _cAliasSRA )->RA_CC } )
             _cOcorren := ""

             DbSelectArea( _cAliasSRA )
             ( _cAliasSRA )->( DbSkip() )
       EndDo
       If Len( _aDadRel ) > 0
          _lRet := .t.
       Endif
Return _lRet

/*Static Function fVerPar()
       Local _cRet := "('"
       Local _cAux := ""
       //Local _nY   := ""

       _cAux := mv_par07 + mv_par08
       While ! Empty( _cAux )
             _cRet += SubStr( _cAux, 1, At(";", _cAux ) - 1 ) + "', '"
             _cAux := SubStr( Alltrim( _cAux ), If( At( ";", _cAux ) == 0, 3, At( ";", _cAux ) ) + 1 )
       EndDo
       _cRet := SubStr( _cRet, 1, Len( _cRet ) - 3) + ")"

Return _cRet*/

/*
Static Function fBusEve( _cCodEve )
       Local _cRet := ""
       
       DbSelectArea("SP6")
       SP6->( DbSetOrder(1) )
       If SP6->( DbSeek( xFilial("SP6") + _cCodEve ) )
          _cRet := Alltrim( SP6->P6_DESC ) 
       Endif
Return _cRet*/
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*
Static Function fValPerg( _cPerg )
       Local _aArea   := GetArea()
       Local aHelpPor := {}

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
          u_zPutSX1( _cPerg   , "02"    , "Filial AtÚ ?         ", "mv_par02", "mv_ch2"  , "C"    ,  6        , 0         , "G"   , "NaoVazio"     , "XM0"   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "03" ) )
          aAdd( aHelpPor, "Informe o periodo, no formaro AAAAMM para geração das informações." )
          u_zPutSX1( _cPerg   , "03"    , "Periodo ? "           , "mv_par03", "mv_ch3"  , "C"    ,  6        , 0         , "G"   , ""             , "   "   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
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
          aAdd( aHelpPor, "Informe a situação do funcionário.")
          u_zPutSX1( _cPerg   , "05"    , "Situação?        "     , "mv_par05", "mv_ch5"  , "C"    ,  5        , 0         , "G"   , "FSituacao()" , "   "   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "06" ) )
          aAdd( aHelpPor, "Informe a categoria do funcionário.")
          u_zPutSX1( _cPerg   , "06"    , "Categoria?       "     , "mv_par06", "mv_ch6"  , "C"    , 15        , 0         , "G"   , "FCategoria()", "   "   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "07" ) )
          aAdd( aHelpPor, "Motivos de Abono/Justificativa a serem considerados para calculo do Vale Alimentação. Utilizar ; para separação dos motivos." )
          u_zPutSX1( _cPerg   , "07"    , "Motivo Abono - DESCONTAR", "mv_par07", "mv_ch7"  , "C"    , 60        , 0         , "G"   , ""             , "   "   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "08" ) )
          aAdd( aHelpPor, "Motivos de Abono/Justificativa a serem considerados para calculo do Vale Alimentação, porém com valor diferenciado. Utilizar ; para separação dos motivos." )
          u_zPutSX1( _cPerg   , "08"    , "Motivo Abono - DIFERENCIADO", "mv_par08", "mv_ch8"  , "C"    , 60        , 0         , "G"   , ""             , "   "   , ""        , ""          , ""               , ""      , ""      , ""   , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "09" ) )
          aAdd( aHelpPor, "Motivos de Abono/Justificativa que devem sair na observação, porém sem desconto do valor. Utilizar ; para separação dos motivos." )
          u_zPutSX1( _cPerg   , "09"    , "Motivo Abono - DESTACADO", "mv_par09", "mv_ch9"  , "C"    , 60        , 0         , "G"   , ""             , "   "   , ""        , ""          , ""               , ""      , ""      , ""   , aHelpPor[1]  )
       Endif
       aHelpPor := {}

       RestArea( _aArea )
Return*/