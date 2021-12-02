#include 'totvs.ch'
#include 'appexcel.ch'

/*/{Protheus.doc} ZGPER03
//RELATÓRIO PARA CONFERÊNCIA DE INSS GERADO PARA SEFIP/DCTF-Web
@author Luís Gustavo de Souza
@since 20/09/2018
@version 6
@return ${return}, ${return_description}

@type function
/*/
User Function ZGPER03()
     Local oExcel   := AppExcel():New()
     Local _cNomArq := ""
     Local _cPerg   := "ZGPER03   "
     Local _aEmpRel := {}
     Local _aDadRel := {}
     Local _aTotFil := {}
     Local _aTotTer := {}
     Local _aTotGer := {}
     Local _nLin    := 1
     Local _nY      := 0
     Local _nX      := 0
     Local _nValRat := 0
     Local _cCodEmp := ""
     Local _aArrEmp := {}
     Local _nZ, _nA
     Local oCelL01C01, oCelL02C01, oCelL04C01, oCelL04C02, oCelL05C01, oCelL05C02, oCelL05C03, oCelL05C04, oCelL05C05

     Private oFont1 := AppExcFont():New( "Calibri", '14', '#000000')
     Private oFont2 := AppExcFont():New( "Calibri", '12', '#000000')
     Private oFont3 := AppExcFont():New( "Calibri", '12', '#000000')
     u_zcfga01( 'ZGPER03' ) //LGS#2021202 - Gravação de log de utilização da rotina
     //fValPerg( _cPerg ) //Chamada da Criação das perguntas  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     
     If !Pergunte( _cPerg ) 
        Return() //Se cancelar as perguntas sai do programa
     Endif
     If !fDados( @_aEmpRel, @_aDadRel, @_aTotFil, @_aTotGer, @_aTotTer )
        MsgAlert("Não existem dados para esse relatório")
        Return() //Se não tiver dados para impressão sai do programa
     Endif

     _cNomArq := "Fechamento_" + Iif( mv_par13 $ '132', '132', 'FOL' ) + "_" + mv_par03 + "_" + DTOS( dDataBase ) + "_" + StrTran( Time(), ":", "" ) + ".xml"

     //Definição dos objetos de configuração
     oFont1:SetBold( .T. )
     oCelL01C01 := AppExcCell():New(); oCelL01C01:SetCellColor("#FFFFFF"); oCelL01C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL01C01:SetFont( oFont1 )
     oCelL01C01:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oFont2:SetBold( .T. )
     oCelL02C01 := AppExcCell():New(); oCelL02C01:SetCellColor("#FFFFFF"); oCelL02C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL02C01:SetFont( oFont2 )
     oCelL02C01:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL02C02 := AppExcCell():New(); oCelL02C02:SetCellColor("#FFFFFF"); oCelL02C02:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL02C02:SetFont( oFont2 )
     oCelL02C02:SetVertAlign( VERTICAL_ALIGN_CENTER ); oCelL02C02:SetBorder( BORDER_POSITION_RIGHT, .t. ); oCelL02C02:SetLineWeigth(BORDER_POSITION_RIGHT, 2   ) 
     
     oCelL04C01 := AppExcCell():New(); oCelL04C01:SetCellColor("#FFFFFF"); oCelL04C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL04C01:SetFont( oFont2 )
     oCelL04C01:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL04C01:SetBorder( BORDER_POSITION_TOP   , .t. ); oCelL04C01:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL04C01:SetBorder(    BORDER_POSITION_RIGHT, .t. )
     oCelL04C01:SetLineWeigth(BORDER_POSITION_TOP, 2   ); oCelL04C01:SetLineWeigth(BORDER_POSITION_LEFT, 2   ); oCelL04C01:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )

     oCelL04C02 := AppExcCell():New(); oCelL04C02:SetCellColor("#FFFFFF"); oCelL04C02:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL04C02:SetFont( oFont2 )
     oCelL04C02:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL04C02:SetBorder( BORDER_POSITION_TOP   , .t. ); oCelL04C02:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL04C02:SetBorder(    BORDER_POSITION_RIGHT, .t. ); oCelL04C02:SetBorder(    BORDER_POSITION_BOTTOM, .t. )
     oCelL04C02:SetLineWeigth(BORDER_POSITION_TOP, 2   ); oCelL04C02:SetLineWeigth(BORDER_POSITION_LEFT, 2   ); oCelL04C02:SetLineWeigth(BORDER_POSITION_RIGHT, 2   ); oCelL04C02:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   )

     oCelL05C01 := AppExcCell():New(); oCelL05C01:SetCellColor("#FFFFFF"); oCelL05C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL05C01:SetFont( oFont2 )
     oCelL05C01:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL05C01:SetBorder( BORDER_POSITION_TOP   , .t. ); oCelL05C01:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL05C01:SetBorder(    BORDER_POSITION_RIGHT, .t. ); oCelL05C01:SetBorder(    BORDER_POSITION_BOTTOM, .t. )
     oCelL05C01:SetLineWeigth(BORDER_POSITION_TOP, 1   ); oCelL05C01:SetLineWeigth(BORDER_POSITION_LEFT, 2   ); oCelL05C01:SetLineWeigth(BORDER_POSITION_RIGHT, 1   ); oCelL05C01:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   )

     oCelL05C02 := AppExcCell():New(); oCelL05C02:SetCellColor("#FFFFFF"); oCelL05C02:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL05C02:SetFont( oFont2 )
     oCelL05C02:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL05C02:SetBorder( BORDER_POSITION_TOP   , .t. ); oCelL05C02:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL05C02:SetBorder(    BORDER_POSITION_RIGHT, .t. ); oCelL05C02:SetBorder(    BORDER_POSITION_BOTTOM, .t. )
     oCelL05C02:SetLineWeigth(BORDER_POSITION_TOP, 1   ); oCelL05C02:SetLineWeigth(BORDER_POSITION_LEFT, 1   ); oCelL05C02:SetLineWeigth(BORDER_POSITION_RIGHT, 2   ); oCelL05C02:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   )

     oCelL05C03 := AppExcCell():New(); oCelL05C03:SetCellColor("#FFFFFF"); oCelL05C03:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL05C03:SetFont( oFont2 )
     oCelL05C03:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL05C03:SetBorder( BORDER_POSITION_TOP   , .t. ); oCelL05C03:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL05C03:SetBorder(    BORDER_POSITION_RIGHT, .t. ); oCelL05C03:SetBorder(    BORDER_POSITION_BOTTOM, .t. )
     oCelL05C03:SetLineWeigth(BORDER_POSITION_TOP, 1   ); oCelL05C03:SetLineWeigth(BORDER_POSITION_LEFT, 2   ); oCelL05C03:SetLineWeigth(BORDER_POSITION_RIGHT, 1   ); oCelL05C03:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   )

     oCelL05C04 := AppExcCell():New(); oCelL05C04:SetCellColor("#FFFFFF"); oCelL05C04:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL05C04:SetFont( oFont2 )
     oCelL05C04:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL05C04:SetBorder( BORDER_POSITION_TOP   , .t. ); oCelL05C04:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL05C04:SetBorder(    BORDER_POSITION_RIGHT, .t. ); oCelL05C04:SetBorder(    BORDER_POSITION_BOTTOM, .t. )
     oCelL05C04:SetLineWeigth(BORDER_POSITION_TOP, 1   ); oCelL05C04:SetLineWeigth(BORDER_POSITION_LEFT, 1   ); oCelL05C04:SetLineWeigth(BORDER_POSITION_RIGHT, 2   ); oCelL05C04:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   )

     oCelL05C05 := AppExcCell():New(); oCelL05C05:SetCellColor("#FFFFFF"); oCelL05C05:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL05C05:SetFont( oFont2 )
     oCelL05C05:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL05C05:SetBorder( BORDER_POSITION_TOP   , .t. ); oCelL05C05:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL05C05:SetBorder(    BORDER_POSITION_RIGHT, .t. ); oCelL05C05:SetBorder(    BORDER_POSITION_BOTTOM, .t. )
     oCelL05C05:SetLineWeigth(BORDER_POSITION_TOP, 1   ); oCelL05C05:SetLineWeigth(BORDER_POSITION_LEFT, 1   ); oCelL05C05:SetLineWeigth(BORDER_POSITION_RIGHT, 1   ); oCelL05C05:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   )

     oCelL06C01 := AppExcCell():New(); oCelL06C01:SetCellColor("#FFFFFF"); oCelL06C01:SetHorzAlign( HORIZONTAL_ALIGN_RIGHT ); oCelL06C01:SetFont( oFont3 )
     oCelL06C01:SetFormat( 6 ); oCelL06C01:SetBorder(    BORDER_POSITION_RIGHT, .t. ); oCelL06C01:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )

     oCelL06C02 := AppExcCell():New(); oCelL06C02:SetCellColor("#FFFFFF"); oCelL06C02:SetHorzAlign( HORIZONTAL_ALIGN_LEFT ); oCelL06C02:SetFont( oFont3 )

     oCelL06C03 := AppExcCell():New(); oCelL06C03:SetCellColor("#FFFFFF"); oCelL06C03:SetHorzAlign( HORIZONTAL_ALIGN_RIGHT ); oCelL06C03:SetFont( oFont3 )
     oCelL06C03:SetFormat( NUMBER_CURRENCY_REAL ); oCelL06C03:SetBorder(    BORDER_POSITION_RIGHT, .t. ); oCelL06C03:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )

     oCelL06C04 := AppExcCell():New(); oCelL06C04:SetCellColor("#FFFFFF"); oCelL06C04:SetHorzAlign( HORIZONTAL_ALIGN_LEFT ); oCelL06C04:SetFont( oFont3 )
     oCelL06C04:SetBorder(    BORDER_POSITION_RIGHT, .t. ); oCelL06C04:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )

     oCelL06C05 := AppExcCell():New(); oCelL06C05:SetCellColor("#FFFFFF"); oCelL06C05:SetHorzAlign( HORIZONTAL_ALIGN_LEFT ); oCelL06C05:SetFont( oFont3 )
     oCelL06C05:SetBorder(    BORDER_POSITION_TOP, .t. ); oCelL06C05:SetLineWeigth(BORDER_POSITION_TOP, 2   )
     
     oCelL06C06 := AppExcCell():New(); oCelL06C06:SetCellColor("#FFFFFF"); oCelL06C06:SetHorzAlign( HORIZONTAL_ALIGN_LEFT ); oCelL06C06:SetFont( oFont3 )
     oCelL06C06:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL06C06:SetLineWeigth(BORDER_POSITION_LEFT, 2   )
     
     oCelL07C00 := AppExcCell():New(); oCelL07C00:SetCellColor("#FFFFFF"); oCelL07C00:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL07C00:SetFont( oFont2 )
     oCelL07C00:SetBorder( BORDER_POSITION_TOP   , .t. ); oCelL07C00:SetLineWeigth(BORDER_POSITION_TOP   , 2   )
     oCelL07C00:SetBorder( BORDER_POSITION_BOTTOM, .t. ); oCelL07C00:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   )
     oCelL07C00:SetBorder( BORDER_POSITION_RIGHT, .t. ); oCelL07C00:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )

     oCelL07C01 := AppExcCell():New(); oCelL07C01:SetCellColor("#FFFFFF"); oCelL07C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL07C01:SetFont( oFont2 )
     oCelL07C01:SetBorder( BORDER_POSITION_TOP   , .t. ); oCelL07C01:SetLineWeigth(BORDER_POSITION_TOP   , 2   )
     oCelL07C01:SetBorder( BORDER_POSITION_BOTTOM, .t. ); oCelL07C01:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   )

     oCelL07C02 := AppExcCell():New(); oCelL07C02:SetCellColor("#FFFFFF"); oCelL07C02:SetHorzAlign( HORIZONTAL_ALIGN_RIGHT ); oCelL07C02:SetFont( oFont2 )
     oCelL07C02:SetBorder( BORDER_POSITION_TOP   , .t. ); oCelL07C02:SetLineWeigth(BORDER_POSITION_TOP   , 2   )
     oCelL07C02:SetBorder( BORDER_POSITION_BOTTOM, .t. ); oCelL07C02:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   )
     oCelL07C02:SetBorder( BORDER_POSITION_RIGHT , .t. ); oCelL07C02:SetLineWeigth(BORDER_POSITION_RIGHT , 2   )
     oCelL07C02:SetFormat( NUMBER_CURRENCY_REAL )

     oCelL07C03 := AppExcCell():New(); oCelL07C03:SetCellColor("#FFFFFF"); oCelL07C03:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL07C03:SetFont( oFont2 )
     oCelL07C03:SetBorder( BORDER_POSITION_TOP   , .t. ); oCelL07C03:SetLineWeigth(BORDER_POSITION_TOP   , 2   )
     oCelL07C03:SetBorder( BORDER_POSITION_BOTTOM, .t. ); oCelL07C03:SetLineWeigth(BORDER_POSITION_BOTTOM, 2   )
     oCelL07C03:SetBorder( BORDER_POSITION_RIGHT , .t. ); oCelL07C03:SetLineWeigth(BORDER_POSITION_RIGHT , 2   )
     oCelL07C03:SetBorder( BORDER_POSITION_LEFT  , .t. ); oCelL07C03:SetLineWeigth(BORDER_POSITION_RIGHT , 2   )

     oCelL08C01 := AppExcCell():New(); oCelL08C01:SetCellColor("#FFFFFF"); oCelL08C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL08C01:SetFont( oFont2 )
     oCelL08C01:SetVertAlign( VERTICAL_ALIGN_CENTER ); oCelL08C01:SetBorder( BORDER_POSITION_TOP, .t. ); oCelL08C01:SetLineWeigth(BORDER_POSITION_TOP, 2   )
     oCelL08C02 := AppExcCell():New(); oCelL08C02:SetCellColor("#FFFFFF"); oCelL08C02:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL08C02:SetFont( oFont2 )
     oCelL08C02:SetVertAlign( VERTICAL_ALIGN_CENTER ); oCelL08C02:SetBorder( BORDER_POSITION_RIGHT, .t. ); oCelL08C02:SetLineWeigth(BORDER_POSITION_RIGHT, 2   ) 
     oCelL08C02:SetBorder( BORDER_POSITION_TOP, .t. ); oCelL08C02:SetLineWeigth(BORDER_POSITION_TOP, 2   )
     oCelL08C03 := AppExcCell():New(); oCelL08C03:SetCellColor("#FFFFFF"); oCelL08C03:SetHorzAlign( HORIZONTAL_ALIGN_RIGHT ); oCelL08C03:SetFont( oFont3 )
     oCelL08C03:SetFormat( 6 ); oCelL08C03:SetBorder(    BORDER_POSITION_RIGHT, .t. ); oCelL08C03:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )
     oCelL08C03:SetBorder( BORDER_POSITION_TOP, .t. ); oCelL08C03:SetLineWeigth(BORDER_POSITION_TOP, 2   )
     oCelL08C04 := AppExcCell():New(); oCelL08C04:SetCellColor("#FFFFFF"); oCelL08C04:SetHorzAlign( HORIZONTAL_ALIGN_CENTER ); oCelL08C04:SetFont( oFont2 )
     oCelL08C04:SetVertAlign( VERTICAL_ALIGN_CENTER )

     //Inicio do relatório
     oExcel:SetDestPath( Alltrim( mv_par04 ) )
     oExcel:SetFileName( '\dirdoc\rh\' + _cNomArq )
     //Verificação de diretório Local para gravação do relatório
     If ! ExistDir( mv_par04 )
          MakeDir( mv_par04 )
     Endif
     For _nY := 1 To Len ( _aEmpRel )
         _nLin := 1
         _cCodEmp := SubStr( _aEmpRel[ _nY ], 1, 2 )
         _aArrEmp := FWArrFilAtu( FWGrpCompany(), _aEmpRel[ _nY] )
         If _nY == 1
            oExcel:SetSheetName( SubStr( _aArrEmp[18], 1, 8 ) )
         Else
            oExcel:AddSheet( SubStr( _aArrEmp[18], 1, 8 ) )
         Endif
         //Cabeçalho
         oExcel:Merge( _nLin, 01, 19, 01, 'CONTRIBUICAO PREVIDENCIARIA SOBRE ' + Iif( 'FOL' $ MV_PAR13, 'A FOLHA DE PAGAMENTO', '13º SALÁRIO' ) + ' (' + Upper( MesExtenso( SubStr( mv_par03, 5, 2 ) ) ) + ' DE ' + SubStr( mv_par03, 1, 4 ) + ') - DTCF-Web.', oCelL01C01 )
         _nLin += 2
         oExcel:Merge( _nLin, 01, 19, 00, ''                          , oCelL02C01 )
         _nLin += 1
         oExcel:Merge( _nLin, 01, 00, 00, ''                          , oCelL02C01 )
         oExcel:Merge( _nLin, 02, 03, 00, 'BASE (INSS)'               , oCelL04C01 )
         oExcel:Merge( _nLin, 06, 02, 00, 'SEGURADO'                  , oCelL04C01 )
         oExcel:Merge( _nLin, 09, 04, 00, 'EMPRESA'                   , oCelL04C01 )
         
         oExcel:Merge( _nLin, 14, 03, 00, 'DEDUCOES'                  , oCelL04C01 )
         oExcel:Merge( _nLin, 18, 01, 00, 'OUTRAS ENTIDADES'          , oCelL04C01 )
         oExcel:Merge( _nLin, 20, 00, 01, 'RECOLHER'                  , oCelL04C02 )

         _nLin += 1
         oExcel:Merge( _nLin, 01, 00, 00, ''                          , oCelL02C01 )
         oExcel:Merge( _nLin, 02, 00, 00, 'VERBAS'                    , oCelL05C01 )
         oExcel:Merge( _nLin, 03, 00, 00, 'EMPREGADOS'                , oCelL05C02 )
         oExcel:Merge( _nLin, 04, 00, 00, 'VERBAS'                    , oCelL05C03 )
         oExcel:Merge( _nLin, 05, 00, 00, 'CONTRIB. IND.'             , oCelL05C04 )

         oExcel:Merge( _nLin, 06, 00, 00, 'VERBAS'                    , oCelL05C01 )
         oExcel:Merge( _nLin, 07, 00, 00, 'EMPREGADOS'                , oCelL05C02 )
         oExcel:Merge( _nLin, 08, 00, 00, 'CONTRIB. IND.'             , oCelL05C04 )

         oExcel:Merge( _nLin, 09, 00, 00, 'VERBAS'                    , oCelL05C01 )
         oExcel:Merge( _nLin, 10, 00, 00, 'EMPREGADOS'                , oCelL05C02 )
         oExcel:Merge( _nLin, 11, 00, 00, 'CONTRIB. IND.'             , oCelL05C02 )
         oExcel:Merge( _nLin, 12, 00, 00, 'VERBA'                     , oCelL05C03 )
         oExcel:Merge( _nLin, 13, 00, 00, 'RAT. AJUSTADA'             , oCelL05C04 )
     
         oExcel:Merge( _nLin, 14, 00, 00, 'VERBAS'                    , oCelL05C01 )
         oExcel:Merge( _nLin, 15, 00, 00, '(-)SAL. FAMILIA'           , oCelL05C04 )
         oExcel:Merge( _nLin, 16, 00, 00, '(-)SAL. MATERN.'           , oCelL05C04 )
         oExcel:Merge( _nLin, 17, 00, 00, '(-)COMPENS.'               , oCelL05C04 )

         oExcel:Merge( _nLin, 18, 00, 00, 'VERBAS'                    , oCelL05C01 )
         oExcel:Merge( _nLin, 19, 00, 00, 'VALOR'                     , oCelL05C04 )
         _nLin += 1
         //Impressão dos dados
         For _nX := 1 To Len( _aDadRel )
             If _aEmpRel[ _nY] == _aDadRel[ _nX][1]
                If _nX == 1
                   //1º Linha por Filial
                   oExcel:AddCell( _nLin, 1, Alltrim( FWFilialName(FWGrpCompany(), _aDadRel[_nX][ 1] ) ) , oCelL02C02 )
                   oExcel:AddCell( _nLin, 2, ""                                                          , oCelL02C01 )
                   oExcel:AddCell( _nLin, 3, ""                                                          , oCelL02C02 )
                   oExcel:AddCell( _nLin, 4, ""                                                          , oCelL02C01 )
                   oExcel:AddCell( _nLin, 5, ""                                                          , oCelL02C02 )
                   oExcel:AddCell( _nLin, 6, ""                                                          , oCelL02C01 )
                   oExcel:AddCell( _nLin, 7, ""                                                          , oCelL02C02 )
                   oExcel:AddCell( _nLin, 8, ""                                                          , oCelL02C02 )
                   oExcel:AddCell( _nLin, 9, ""                                                          , oCelL02C01 )
                   oExcel:AddCell( _nLin,10, ""                                                          , oCelL02C02 )
                   oExcel:AddCell( _nLin,11, ""                                                          , oCelL02C02 )
                   oExcel:AddCell( _nLin,12, ""                                                          , oCelL02C01 )
                   _aArrEmp := FWArrFilAtu( FWGrpCompany(), _aEmpRel[ _nY] )
                   _nValRat := fVerRat( _aArrEmp )
                   oExcel:AddCell( _nLin, 13, ( _nValRat / 100 )                                         , oCelL06C01 )
                   oExcel:AddCell( _nLin,14, ""                                                          , oCelL02C01 )
                   oExcel:AddCell( _nLin,15, ""                                                          , oCelL02C02 )
                   oExcel:AddCell( _nLin,16, ""                                                          , oCelL02C02 )
                   oExcel:AddCell( _nLin,17, ""                                                          , oCelL02C02 )
                   oExcel:AddCell( _nLin,18, ""                                                          , oCelL02C01 )
                   oExcel:AddCell( _nLin,19, ""                                                          , oCelL02C02 )
                   oExcel:AddCell( _nLin,20, ""                                                          , oCelL02C01 )
                   
                   _nLin += 1
                   oExcel:AddCell( _nLin,  1, ''                                                          , oCelL02C02 )
                   oExcel:AddCell( _nLin,  2, _aDadRel[ _nX][ 2]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin,  3, Iif( _aDadRel[ _nX][ 3] == 0, "", _aDadRel[ _nX][ 3] )      , Iif( _aDadRel[ _nX][ 3] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin,  4, _aDadRel[ _nX][ 4]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin,  5, Iif( _aDadRel[ _nX][ 5] == 0, "", _aDadRel[ _nX][ 5] )      , Iif( _aDadRel[ _nX][ 5] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin,  6, _aDadRel[ _nX][ 6]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin,  7, Iif( _aDadRel[ _nX][ 7] == 0, "", _aDadRel[ _nX][ 7] )      , Iif( _aDadRel[ _nX][ 7] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin,  8, Iif( _aDadRel[ _nX][ 9] == 0, "", _aDadRel[ _nX][ 9] )      , Iif( _aDadRel[ _nX][ 9] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin,  9, _aDadRel[ _nX][10]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin, 10, Iif( _aDadRel[ _nX][11] == 0, "", _aDadRel[ _nX][11] )      , Iif( _aDadRel[ _nX][11] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 11, Iif( _aDadRel[ _nX][12] == 0, "", _aDadRel[ _nX][12] )      , Iif( _aDadRel[ _nX][12] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 12, _aDadRel[ _nX][13]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin, 13, Iif( _aDadRel[ _nX][14] == 0, "", _aDadRel[ _nX][14] )      , Iif( _aDadRel[ _nX][14] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 14, _aDadRel[ _nX][15]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin, 15, Iif( _aDadRel[ _nX][16] == 0, "", _aDadRel[ _nX][16] )      , Iif( _aDadRel[ _nX][16] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 16, Iif( _aDadRel[ _nX][17] == 0, "", _aDadRel[ _nX][17] )      , Iif( _aDadRel[ _nX][17] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 17, Iif( _aDadRel[ _nX][18] == 0, "", _aDadRel[ _nX][18] )      , Iif( _aDadRel[ _nX][18] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 18, _aDadRel[ _nX][19]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin, 19, Iif( _aDadRel[ _nX][20] == 0, "", _aDadRel[ _nX][20] )      , Iif( _aDadRel[ _nX][20] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 20, ""                                                          , oCelL06C02 )
                   _nLin += 1
                Else
                   oExcel:AddCell( _nLin,  1, ''                                                          , oCelL02C02 )
                   oExcel:AddCell( _nLin,  2, _aDadRel[ _nX][ 2]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin,  3, Iif( _aDadRel[ _nX][ 3] == 0, "", _aDadRel[ _nX][ 3] )      , Iif( _aDadRel[ _nX][ 3] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin,  4, _aDadRel[ _nX][ 4]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin,  5, Iif( _aDadRel[ _nX][ 5] == 0, "", _aDadRel[ _nX][ 5] )      , Iif( _aDadRel[ _nX][ 5] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin,  6, _aDadRel[ _nX][ 6]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin,  7, Iif( _aDadRel[ _nX][ 7] == 0, "", _aDadRel[ _nX][ 7] )      , Iif( _aDadRel[ _nX][ 7] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin,  8, Iif( _aDadRel[ _nX][ 9] == 0, "", _aDadRel[ _nX][ 9] )      , Iif( _aDadRel[ _nX][ 9] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin,  9, _aDadRel[ _nX][10]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin, 10, Iif( _aDadRel[ _nX][11] == 0, "", _aDadRel[ _nX][11] )      , Iif( _aDadRel[ _nX][11] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 11, Iif( _aDadRel[ _nX][12] == 0, "", _aDadRel[ _nX][12] )      , Iif( _aDadRel[ _nX][12] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 12, _aDadRel[ _nX][13]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin, 13, Iif( _aDadRel[ _nX][14] == 0, "", _aDadRel[ _nX][14] )      , Iif( _aDadRel[ _nX][14] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 14, _aDadRel[ _nX][15]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin, 15, Iif( _aDadRel[ _nX][16] == 0, "", _aDadRel[ _nX][16] )      , Iif( _aDadRel[ _nX][16] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 16, Iif( _aDadRel[ _nX][17] == 0, "", _aDadRel[ _nX][17] )      , Iif( _aDadRel[ _nX][17] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 17, Iif( _aDadRel[ _nX][18] == 0, "", _aDadRel[ _nX][18] )      , Iif( _aDadRel[ _nX][18] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 18, _aDadRel[ _nX][19]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin, 19, Iif( _aDadRel[ _nX][20] == 0, "", _aDadRel[ _nX][20] )      , Iif( _aDadRel[ _nX][20] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 20, ""                                                          , oCelL06C02 )
                   _nLin += 1
                Endif
             Else //Totalizador
                If SubStr(_aEmpRel[ _nY], 1, 2 )  == SubStr( _aDadRel[ _nX][1], 1, 2 )
                   _nPosTot := aScan( _aTotFil, { |x| x[1] == _aEmpRel[ _nY] })
                   //Totaliza anterior
                   oExcel:AddCell( _nLin,  1, 'TOTAL'                                                     , oCelL07C00 )
                   oExcel:AddCell( _nLin,  2, ''                                                          , oCelL07C01 )
                   oExcel:AddCell( _nLin,  3, _aTotFil[_nPosTot][2]                                       , oCelL07C02 )
                   oExcel:AddCell( _nLin,  4, ''                                                          , oCelL07C01 )
                   oExcel:AddCell( _nLin,  5, _aTotFil[_nPosTot][3]                                       , oCelL07C02 )
                   oExcel:AddCell( _nLin,  6, ''                                                          , oCelL07C01 )
                   oExcel:AddCell( _nLin,  7, _aTotFil[_nPosTot][4]                                       , oCelL07C02 )
                   oExcel:AddCell( _nLin,  8, _aTotFil[_nPosTot][5]                                       , oCelL07C02 )
                   oExcel:AddCell( _nLin,  9, ''                                                          , oCelL07C01 )
                   oExcel:AddCell( _nLin, 10, _aTotFil[_nPosTot][6]                                       , oCelL07C02 )
                   oExcel:AddCell( _nLin, 11, _aTotFil[_nPosTot][7]                                       , oCelL07C02 )
                   oExcel:AddCell( _nLin, 12, ''                                                          , oCelL07C01 )
                   oExcel:AddCell( _nLin, 13, _aTotFil[_nPosTot][8]                                       , oCelL07C02 )
                   oExcel:AddCell( _nLin, 14, ''                                                          , oCelL07C01 )
                   oExcel:AddCell( _nLin, 15, _aTotFil[_nPosTot][9]                                       , oCelL07C02 )
                   oExcel:AddCell( _nLin, 16, _aTotFil[_nPosTot][10]                                      , oCelL07C02 )
                   oExcel:AddCell( _nLin, 17, _aTotFil[_nPosTot][11]                                      , oCelL07C02 )
                   oExcel:AddCell( _nLin, 18, ''                                                          , oCelL07C01 )
                   oExcel:AddCell( _nLin, 19, _aTotFil[_nPosTot][12]                                      , oCelL07C02 )
                   oExcel:AddCell( _nLin, 20, ( _aTotFil[_nPosTot][ 4] + _aTotFil[_nPosTot][ 5] + _aTotFil[_nPosTot][ 6] + _aTotFil[_nPosTot][ 7] + _aTotFil[_nPosTot][ 8] + _aTotFil[_nPosTot][12]) - _aTotFil[_nPosTot][ 9] - _aTotFil[_nPosTot][10] - _aTotFil[_nPosTot][11], oCelL07C02 )
                   _nLin += 1
                   For _nZ := 1 To 20
                       oExcel:AddCell( _nLin, _nZ, ''                                                   , oCelL02C01 )
                   Next
                   _nLin += 1
                   oExcel:AddCell( _nLin, 1, Alltrim( FWFilialName(FWGrpCompany(), _aDadRel[_nX][ 1] ) ), oCelL08C02 )
                   oExcel:AddCell( _nLin, 2, ""                                                         , oCelL08C01 )
                   oExcel:AddCell( _nLin, 3, ""                                                         , oCelL08C02 )
                   oExcel:AddCell( _nLin, 4, ""                                                         , oCelL08C01 )
                   oExcel:AddCell( _nLin, 5, ""                                                         , oCelL08C02 )
                   oExcel:AddCell( _nLin, 6, ""                                                         , oCelL08C01 )
                   oExcel:AddCell( _nLin, 7, ""                                                         , oCelL08C02 )
                   oExcel:AddCell( _nLin, 8, ""                                                         , oCelL08C02 )
                   oExcel:AddCell( _nLin, 9, ""                                                         , oCelL08C01 )
                   oExcel:AddCell( _nLin,10, ""                                                         , oCelL08C02 )
                   oExcel:AddCell( _nLin,11, ""                                                         , oCelL08C02 )
                   oExcel:AddCell( _nLin,12, ""                                                         , oCelL08C01 )
                   _aArrEmp := FWArrFilAtu( FWGrpCompany(), _aDadRel[ _nX][1] )
                   _nValRat := fVerRat( _aArrEmp )
                   oExcel:AddCell( _nLin, 13, ( _nValRat / 100 )                                        , oCelL08C03 )
                   oExcel:AddCell( _nLin,14, ""                                                         , oCelL08C01 )
                   oExcel:AddCell( _nLin,15, ""                                                         , oCelL08C02 )
                   oExcel:AddCell( _nLin,16, ""                                                         , oCelL08C02 )
                   oExcel:AddCell( _nLin,17, ""                                                         , oCelL08C02 )
                   oExcel:AddCell( _nLin,18, ""                                                         , oCelL08C01 )
                   oExcel:AddCell( _nLin,19, ""                                                         , oCelL08C02 )
                   oExcel:AddCell( _nLin,20, ""                                                         , oCelL08C04 )
                   _nLin += 1

                   //Inicia próxima empresa
                   oExcel:AddCell( _nLin,  1, ''                                                          , oCelL02C02 )
                   oExcel:AddCell( _nLin,  2, _aDadRel[ _nX][ 2]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin,  3, Iif( _aDadRel[ _nX][ 3] == 0, "", _aDadRel[ _nX][ 3] )      , Iif( _aDadRel[ _nX][ 3] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin,  4, _aDadRel[ _nX][ 4]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin,  5, Iif( _aDadRel[ _nX][ 5] == 0, "", _aDadRel[ _nX][ 5] )      , Iif( _aDadRel[ _nX][ 5] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin,  6, _aDadRel[ _nX][ 6]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin,  7, Iif( _aDadRel[ _nX][ 7] == 0, "", _aDadRel[ _nX][ 7] )      , Iif( _aDadRel[ _nX][ 7] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin,  8, Iif( _aDadRel[ _nX][ 9] == 0, "", _aDadRel[ _nX][ 9] )      , Iif( _aDadRel[ _nX][ 9] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin,  9, _aDadRel[ _nX][10]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin, 10, Iif( _aDadRel[ _nX][11] == 0, "", _aDadRel[ _nX][11] )      , Iif( _aDadRel[ _nX][11] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 11, Iif( _aDadRel[ _nX][12] == 0, "", _aDadRel[ _nX][12] )      , Iif( _aDadRel[ _nX][12] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 12, _aDadRel[ _nX][13]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin, 13, Iif( _aDadRel[ _nX][14] == 0, "", _aDadRel[ _nX][14] )      , Iif( _aDadRel[ _nX][14] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 14, _aDadRel[ _nX][15]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin, 15, Iif( _aDadRel[ _nX][16] == 0, "", _aDadRel[ _nX][16] )      , Iif( _aDadRel[ _nX][16] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 16, Iif( _aDadRel[ _nX][17] == 0, "", _aDadRel[ _nX][17] )      , Iif( _aDadRel[ _nX][17] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 17, Iif( _aDadRel[ _nX][18] == 0, "", _aDadRel[ _nX][18] )      , Iif( _aDadRel[ _nX][18] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 18, _aDadRel[ _nX][19]                                          , oCelL06C02 )
                   oExcel:AddCell( _nLin, 19, Iif( _aDadRel[ _nX][20] == 0, "", _aDadRel[ _nX][20] )      , Iif( _aDadRel[ _nX][20] == 0, oCelL06C04, oCelL06C03 ) )
                   oExcel:AddCell( _nLin, 20, ""                                                          , oCelL06C02 )
                   _nLin += 1
                   _nY += 1
                Endif
             Endif
         Next
         //Totaliza anterior
         _nPosTot := aScan( _aTotFil, { |x| x[1] == _aEmpRel[ _nY] })
         oExcel:AddCell( _nLin,  1, 'TOTAL'                                                     , oCelL07C00 )
         oExcel:AddCell( _nLin,  2, ''                                                          , oCelL07C01 )
         oExcel:AddCell( _nLin,  3, _aTotFil[_nPosTot][ 2]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin,  4, ''                                                          , oCelL07C01 )
         oExcel:AddCell( _nLin,  5, _aTotFil[_nPosTot][ 3]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin,  6, ''                                                          , oCelL07C01 )
         oExcel:AddCell( _nLin,  7, _aTotFil[_nPosTot][ 4]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin,  8, _aTotFil[_nPosTot][ 5]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin,  9, ''                                                          , oCelL07C01 )
         oExcel:AddCell( _nLin, 10, _aTotFil[_nPosTot][ 6]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin, 11, _aTotFil[_nPosTot][ 7]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin, 12, ''                                                          , oCelL07C01 )
         oExcel:AddCell( _nLin, 13, _aTotFil[_nPosTot][ 8]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin, 14, ''                                                          , oCelL07C01 )
         oExcel:AddCell( _nLin, 15, _aTotFil[_nPosTot][ 9]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin, 16, _aTotFil[_nPosTot][10]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin, 17, _aTotFil[_nPosTot][11]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin, 18, ''                                                          , oCelL07C01 )
         oExcel:AddCell( _nLin, 19, _aTotFil[_nPosTot][12]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin, 20, ( _aTotFil[_nPosTot][ 4] + _aTotFil[_nPosTot][ 5] + _aTotFil[_nPosTot][ 6] + _aTotFil[_nPosTot][ 7] + _aTotFil[_nPosTot][ 8] + _aTotFil[_nPosTot][12] ) - _aTotFil[_nPosTot][ 9] - _aTotFil[_nPosTot][10] - _aTotFil[_nPosTot][11], oCelL07C02 )    
         _nLin += 1
         For _nZ := 1 To 20
             oExcel:AddCell( _nLin, _nZ, ''                                                   , oCelL02C01 )
         Next
         _nLin += 1

         //Totalizador Geral
         _nPosTot := aScan( _aTotGer, { |x| x[1] == SubStr( _aEmpRel[ _nY], 1, 2 ) } )
         oExcel:AddCell( _nLin,  1, 'TOTAL GERAL'                                               , oCelL07C00 )
         oExcel:AddCell( _nLin,  2, ''                                                          , oCelL07C01 )
         oExcel:AddCell( _nLin,  3, _aTotGer[_nPosTot][ 2]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin,  4, ''                                                          , oCelL07C01 )
         oExcel:AddCell( _nLin,  5, _aTotGer[_nPosTot][ 3]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin,  6, ''                                                          , oCelL07C01 )
         oExcel:AddCell( _nLin,  7, _aTotGer[_nPosTot][ 4]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin,  8, _aTotGer[_nPosTot][ 5]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin,  9, ''                                                          , oCelL07C01 )
         oExcel:AddCell( _nLin, 10, _aTotGer[_nPosTot][ 6]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin, 11, _aTotGer[_nPosTot][ 7]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin, 12, ''                                                          , oCelL07C01 )
         oExcel:AddCell( _nLin, 13, _aTotGer[_nPosTot][ 8]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin, 14, ''                                                          , oCelL07C01 )
         oExcel:AddCell( _nLin, 15, _aTotGer[_nPosTot][ 9]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin, 16, _aTotGer[_nPosTot][10]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin, 17, _aTotGer[_nPosTot][11]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin, 18, ''                                                          , oCelL07C01 )
         oExcel:AddCell( _nLin, 19, _aTotGer[_nPosTot][12]                                      , oCelL07C02 )
         oExcel:AddCell( _nLin, 20, ( _aTotGer[_nPosTot][ 4] + _aTotGer[_nPosTot][ 5] + _aTotGer[_nPosTot][ 6] + _aTotGer[_nPosTot][ 7] + _aTotGer[_nPosTot][ 8] + _aTotGer[_nPosTot][12] ) - _aTotGer[_nPosTot][ 9] - _aTotGer[_nPosTot][10] - _aTotGer[_nPosTot][11], oCelL07C02 )
         _nLin += 1
         oExcel:AddCell( _nLin,  1, ''                                              , oCelL02C02 )
         oExcel:Merge( _nLin, 02, 02, 00, 'TOTAL - BASE (INSS)'                     , oCelL07C03 )
         oExcel:AddCell( _nLin,  5, _aTotGer[_nPosTot][ 2] + _aTotGer[_nPosTot][ 3] , oCelL07C02 )
         oExcel:Merge( _nLin, 06, 01, 00, 'TOTAL - SEGURADO'                        , oCelL07C03 )
         oExcel:AddCell( _nLin,  8, _aTotGer[_nPosTot][ 4] + _aTotGer[_nPosTot][ 5] , oCelL07C02 )
         oExcel:Merge( _nLin, 09, 03, 00, 'TOTAL - EMPRESA'                         , oCelL07C03 )
         oExcel:AddCell( _nLin, 13, _aTotGer[_nPosTot][ 6] + _aTotGer[_nPosTot][ 7] + _aTotGer[_nPosTot][ 8] , oCelL07C02 )
         oExcel:Merge( _nLin, 14, 02, 00, 'TOTAL - DEDUÇÕES'                        , oCelL07C03 )
         oExcel:AddCell( _nLin, 17, _aTotGer[_nPosTot][ 9] + _aTotGer[_nPosTot][10] + _aTotGer[_nPosTot][ 11], oCelL07C02 )
         oExcel:Merge( _nLin, 18, 01, 00, 'RESUMO TOTAL - TERCEIROS'                , oCelL07C03 )
         oExcel:AddCell( _nLin,  20, ''                                             , oCelL02C01 )
         _nLin += 1
         For _nZ := 1 To Len( _aTotTer )
             If _cCodEmp == _aTotTer[ _nZ ][ 1]
                For _nA := 1 To 17
                    oExcel:AddCell( _nLin,  _nA, ''                                         , oCelL02C01 )
                Next
                oExcel:AddCell( _nLin,  18, _aTotTer[ _nZ ][ 2]                             , oCelL06C06 )
                oExcel:AddCell( _nLin,  19, _aTotTer[ _nZ ][ 3]                             , oCelL06C03 )
                oExcel:AddCell( _nLin,  20, ''                                              , oCelL02C01 )
                _nLin += 1
             Endif
         Next
         For _nA := 1 To 17
             oExcel:AddCell( _nLin,  _nA, ''                                         , oCelL02C01 )
         Next
         oExcel:AddCell( _nLin,  18, ' '                                             , oCelL06C05 )
         oExcel:AddCell( _nLin,  19, ' '                                             , oCelL06C05 )
         oExcel:AddCell( _nLin,  20, ''                                              , oCelL02C01 )
         _nLin += 1
     Next
     oExcel:Make( .F. )
     oExcel:SetFileName( Alltrim( mv_par04 ) + _cNomArq )
     oExcel:Destroy()
     MsgInfo( 'Arquivo '+ _cNomArq + ' gerado com sucesso em ' + Alltrim( mv_par04 ) + '.' , 'Informação...' )
Return

Static Function fDados( _aEmpRel, _aDadRel, _aTotFil, _aTotGer, _aTotTer )
       Local _lRet      := .f.
       Local _cQry1     := ""
       Local _cAliasSRD := GetNextAlias()
       Local _cCatFun   := ""
       Local _nPos      := 0
       Local _nY        := 0
       Local _cVerUtil  := ""
       Local _cVerRot   := ""
       
       _cVerUtil := fVerPar()
       _cVerRot  := fVerRot()
       
       If mv_par14 == 1
          _cQry1 += "SELECT SRC.RC_FILIAL AS RD_FILIAL, SRC.RC_PD AS RD_PD, SRV.RV_DESC AS RV_DESC, SRC.RC_MAT AS RD_MAT, SRC.RC_VALOR AS RD_VALOR "
          _cQry1 += "FROM " + RetSQLName("SRC") +" SRC "
          _cQry1 += "LEFT JOIN " + RetSQLName("SRV") + " SRV ON SRV.RV_FILIAL = '" + Iif( FWCodEmp() <> '11', SUBSTR( xFilial("SRV"), 1, 2 ), xFilial("SRV") ) + "' AND SRV.D_E_L_E_T_ = ' '  AND SRV.RV_COD = SRC.RC_PD "
          _cQry1 += "WHERE SRC.RC_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
          _cQry1 += "  AND SRC.D_E_L_E_T_ = ' ' "
          _cQry1 += "  AND SRC.RC_PERIODO = '" + MV_PAR03 + "' "
          _cQry1 += "  AND SRC.RC_ROTEIR IN " + _cVerRot + " "
          _cQry1 += "  AND SRC.RC_PD IN " + _cVerUtil
          _cQry1 += "ORDER BY SRC.RC_FILIAL, SRC.RC_PD "
       Else
          _cQry1 += "SELECT SRD.RD_FILIAL, SRD.RD_PD, SRV.RV_DESC, SRD.RD_MAT, SRD.RD_VALOR "
          _cQry1 += "FROM " + RetSQLName("SRD") +" SRD "
          _cQry1 += "LEFT JOIN " + RetSQLName("SRV") + " SRV ON SRV.RV_FILIAL = '" + Iif( FWCodEmp() <> '11', SUBSTR( xFilial("SRV"), 1, 2 ), xFilial("SRV") ) + "' AND SRV.D_E_L_E_T_ = ' '  AND SRV.RV_COD = SRD.RD_PD "
          _cQry1 += "WHERE SRD.RD_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
          _cQry1 += "  AND SRD.D_E_L_E_T_ = ' ' "
          _cQry1 += "  AND SRD.RD_PERIODO = '" + MV_PAR03 + "' "
          _cQry1 += "  AND SRD.RD_ROTEIR IN " + _cVerRot + " "
          _cQry1 += "  AND SRD.RD_PD IN " + _cVerUtil
          _cQry1 += "ORDER BY SRD.RD_FILIAL, SRD.RD_PD "
       Endif
       DbUseArea( .T., "TOPCONN", TCGENQRY( , , _cQry1 ), _cAliasSRD, .f., .T. )
       DbSelectArea( _cAliasSRD )
       While !Eof()
             //Separação das empresas/filiais
             If aScan( _aEmpRel, ( _cAliasSRD )->RD_FILIAL ) == 0
                aAdd( _aEmpRel, ( _cAliasSRD )->RD_FILIAL )
             EndIf
             If fVerSit( _cAliasSRD )
                //Separação dos Dados
                If ( _cAliasSRD )->RD_PD $ mv_par05 //Base de INSS Empregados (701 / 702 / 707)
                   If Len( _aDadRel ) > 0
                      If aScan( _aDadRel, { |x| x[1] + x[2] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                         _nPos := 0
                         For _nY := 1 To Len( _aDadRel )
                             If Empty( _aDadRel[ _nY ][ 2 ] ) .and. _nPos == 0 .and. _aDadRel[ _nY ][ 1 ] == ( _cAliasSRD )->RD_FILIAL
                                _nPos := _nY
                             Endif
                         Next
                         If _nPos <> 0
                            _aDadRel[ _nPos][2] := ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC
                            _aDadRel[ _nPos][3] := ( _cAliasSRD )->RD_VALOR
                         Else
                            aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR, "", 0, "", 0, "", 0, "", 0, 0, "", 0, "", 0, 0, 0, "", 0 } )
                         Endif
                      Else
                         _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[2] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 3 ] += ( _cAliasSRD )->RD_VALOR
                      Endif
                   Else
                      If aScan( _aDadRel, { |x| x[1] + x[2] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                         aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR, "", 0, "", 0, "", 0, "", 0, 0, "", 0, "", 0, 0, 0, "", 0 } )
                      Else
                         _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[2] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 3 ] += ( _cAliasSRD )->RD_VALOR
                      Endif
                   Endif
                ElseIf ( _cAliasSRD )->RD_PD $ mv_par06 //Base INSS Contribuinte Individual (726)
                       If Len( _aDadRel ) > 0
                          If aScan( _aDadRel, { |x| x[1] + x[4] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                             _nPos := 0
                             For _nY := 1 To Len( _aDadRel )
                                 If Empty( _aDadRel[ _nY ][ 4 ] ) .and. _nPos == 0 .and. _aDadRel[ _nY ][ 1 ] == ( _cAliasSRD )->RD_FILIAL
                                    _nPos := _nY
                                 Endif
                             Next
                             If _nPos <> 0
                                _aDadRel[ _nPos][4] := ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC
                                _aDadRel[ _nPos][5] := ( _cAliasSRD )->RD_VALOR
                             Else
                                aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR, "", 0, "", 0, "", 0, 0, "", 0, "", 0, 0, 0, "", 0 } )
                             Endif
                          Else
                             _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[4] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 5 ] += ( _cAliasSRD )->RD_VALOR
                          Endif
                       Else
                          If aScan( _aDadRel, { |x| x[1] + x[4] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                             aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR, "", 0, "", 0, "", 0, 0, "", 0, "", 0, 0, 0, "", 0 } )
                          Else
                             _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[4] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 5 ] += ( _cAliasSRD )->RD_VALOR
                          Endif
                       Endif
                ElseIf ( _cAliasSRD )->RD_PD $ mv_par07 //SEGURADOS - EMPREGADOS (401 / 403 / 443) E CONTRIBUINTE INDIVIDUAL (401)
                       _cCatFun := fVerFun( _cAliasSRD )
                       If ! _cCatFun $ 'A.P'
                          If Len( _aDadRel ) > 0
                             If aScan( _aDadRel, { |x| x[1] + x[6] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                                _nPos := 0
                                For _nY := 1 To Len( _aDadRel )
                                    If Empty( _aDadRel[ _nY ][ 6 ] ) .and. _nPos == 0 .and. _aDadRel[ _nY ][ 1 ] == ( _cAliasSRD )->RD_FILIAL
                                       _nPos := _nY
                                    Endif
                                Next
                                If _nPos <> 0
                                   _aDadRel[ _nPos][6] := ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC
                                   _aDadRel[ _nPos][7] := ( _cAliasSRD )->RD_VALOR
                                Else
                                   aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR, "", 0, "", 0, 0, "", 0, "", 0, 0, 0, "", 0 } )
                                Endif
                             Else
                                _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[6] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 7 ] += ( _cAliasSRD )->RD_VALOR
                             Endif
                          Else
                             If aScan( _aDadRel, { |x| x[1] + x[6] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                                aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR, "", 0, "", 0, 0, "", 0, "", 0, 0, 0, "", 0 } )
                             Else
                                _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[6] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 7 ] += ( _cAliasSRD )->RD_VALOR
                             Endif
                          Endif
                       Else
                          If Len( _aDadRel ) > 0
                             If aScan( _aDadRel, { |x| x[1] + x[8] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                                _nPos := 0
                                For _nY := 1 To Len( _aDadRel )
                                    If Empty( _aDadRel[ _nY ][ 8 ] ) .and. _nPos == 0  .and. _aDadRel[ _nY ][ 1 ] == ( _cAliasSRD )->RD_FILIAL
                                       _nPos := _nY
                                    Endif
                                Next
                                If _nPos <> 0
                                   _aDadRel[ _nPos][8] := ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC
                                   _aDadRel[ _nPos][9] := ( _cAliasSRD )->RD_VALOR
                                Else
                                   aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, "", 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR, "", 0, 0, "", 0, "", 0, 0, 0, "", 0 } )
                                Endif
                             Else
                                _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[8] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 9 ] += ( _cAliasSRD )->RD_VALOR
                             Endif
                          Else
                             If aScan( _aDadRel, { |x| x[1] + x[8] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                                aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, "", 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR, "", 0, 0, "", 0, "", 0, 0, 0, "", 0 } )
                             Else
                                _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[8] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 9 ] += ( _cAliasSRD )->RD_VALOR
                             Endif
                          Endif
                       Endif
                ElseIf ( _cAliasSRD )->RD_PD $ mv_par08 //EMPRESA INSS EMPREGADOS - CONTRIBUINTE INDIVIDUAL
                       _cCatFun := fVerFun( _cAliasSRD )
                       If Len( _aDadRel ) > 0
                          If aScan( _aDadRel, { |x| x[1] + x[10] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                             _nPos := 0
                             For _nY := 1 To Len( _aDadRel )
                                 If Empty( _aDadRel[ _nY ][ 10 ] ) .and. _nPos == 0 .and. _aDadRel[ _nY ][ 1 ] == ( _cAliasSRD )->RD_FILIAL
                                    _nPos := _nY
                                 Endif
                             Next
                             If _nPos <> 0
                                _aDadRel[ _nPos][10] := ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC
                                If ! _cCatFun $ 'A.P'
                                   _aDadRel[ _nPos][11] := ( _cAliasSRD )->RD_VALOR
                                Else
                                   _aDadRel[ _nPos][12] := ( _cAliasSRD )->RD_VALOR
                                Endif
                             Else
                                If ! _cCatFun $ 'A.P'
                                   aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, "", 0, "", 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR, 0, "", 0, "", 0, 0, 0, "", 0 } )
                                Else
                                   aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, "", 0, "", 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, 0, ( _cAliasSRD )->RD_VALOR, "", 0, "", 0, 0, 0, "", 0 } )
                                Endif
                             Endif
                          Else
                             If ! _cCatFun $ 'A.P'
                                _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[10] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 11 ] += ( _cAliasSRD )->RD_VALOR
                             Else
                                _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[10] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 12 ] += ( _cAliasSRD )->RD_VALOR
                             Endif
                          Endif
                       Else
                          If aScan( _aDadRel, { |x| x[1] + x[10] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                             If ! _cCatFun $ 'A.P'
                                aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, "", 0, "", 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR, 0, "", 0, "", 0, 0, 0, "", 0 } )
                             Else
                                aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, "", 0, "", 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, 0, ( _cAliasSRD )->RD_VALOR, "", 0, "", 0, 0, 0, "", 0 } )
                             Endif
                          Else
                             If ! _cCatFun $ 'A.P'
                                _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[10] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 11 ] += ( _cAliasSRD )->RD_VALOR
                             Else
                                _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[10] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 12 ] += ( _cAliasSRD )->RD_VALOR
                             Endif
                          Endif
                       Endif
                ElseIf ( _cAliasSRD )->RD_PD $ mv_par09 //EMPRESA - RAT AJUSTADA
                       If Len( _aDadRel ) > 0
                          If aScan( _aDadRel, { |x| x[1] + x[13] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                             _nPos := 0
                             For _nY := 1 To Len( _aDadRel )
                                 If Empty( _aDadRel[ _nY ][ 13 ] ) .and. _nPos == 0 .and. _aDadRel[ _nY ][ 1 ] == ( _cAliasSRD )->RD_FILIAL
                                    _nPos := _nY
                                 Endif
                             Next
                             If _nPos <> 0
                                _aDadRel[ _nPos][13] := ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC
                                _aDadRel[ _nPos][14] := ( _cAliasSRD )->RD_VALOR
                             Else
                                aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, "", 0, "", 0, "", 0, 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR, "", 0, 0, 0, "", 0 } )
                             Endif
                          Else
                             _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[13] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 14 ] += ( _cAliasSRD )->RD_VALOR
                          Endif
                       Else
                          If aScan( _aDadRel, { |x| x[1] + x[13] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                             aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, "", 0, "", 0, "", 0, 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR, "", 0, 0, 0, "", 0 } )
                          Else
                             _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[13] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 14 ] += ( _cAliasSRD )->RD_VALOR
                          Endif
                       Endif
                ElseIf ( _cAliasSRD )->RD_PD $ mv_par10 //DEDUÇÕES - FAMILIA
                       If Len( _aDadRel ) > 0
                          If aScan( _aDadRel, { |x| x[1] + x[15] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                             _nPos := 0
                             For _nY := 1 To Len( _aDadRel )
                                 If Empty( _aDadRel[ _nY ][ 15 ] ) .and. _nPos == 0 .and. _aDadRel[ _nY ][ 1 ] == ( _cAliasSRD )->RD_FILIAL
                                    _nPos := _nY
                                 Endif
                             Next
                             If _nPos <> 0
                                _aDadRel[ _nPos][15] := ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC
                                _aDadRel[ _nPos][16] := ( _cAliasSRD )->RD_VALOR
                             Else
                                aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, "", 0, "", 0, "", 0, 0, "", 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR, 0, 0, "", 0 } )
                             Endif
                          Else
                             _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[15] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 16 ] += ( _cAliasSRD )->RD_VALOR
                          Endif
                       Else
                          If aScan( _aDadRel, { |x| x[1] + x[13] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                             aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, "", 0, "", 0, "", 0, 0, "", 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR, 0, 0, "", 0 } )
                          Else
                             _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[15] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 16 ] += ( _cAliasSRD )->RD_VALOR
                          Endif
                       Endif
                ElseIf ( _cAliasSRD )->RD_PD $ mv_par11 //DEDUÇÕES - MATERNIDADE
                       If Len( _aDadRel ) > 0
                          If aScan( _aDadRel, { |x| x[1] + x[15] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                             _nPos := 0
                             For _nY := 1 To Len( _aDadRel )
                                 If Empty( _aDadRel[ _nY ][ 15 ] ) .and. _nPos == 0 .and. _aDadRel[ _nY ][ 1 ] == ( _cAliasSRD )->RD_FILIAL
                                    _nPos := _nY
                                 Endif
                             Next
                             If _nPos <> 0
                                _aDadRel[ _nPos][15] := ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC
                                _aDadRel[ _nPos][17] := ( _cAliasSRD )->RD_VALOR
                             Else
                                aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, "", 0, "", 0, "", 0, 0, "", 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, 0, ( _cAliasSRD )->RD_VALOR, 0, "", 0 } )
                             Endif
                          Else
                             _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[15] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 17 ] += ( _cAliasSRD )->RD_VALOR
                          Endif
                       Else
                          If aScan( _aDadRel, { |x| x[1] + x[13] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                             aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, "", 0, "", 0, "", 0, 0, "", 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, 0, ( _cAliasSRD )->RD_VALOR, 0, "", 0 } )
                          Else
                             _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[15] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 17 ] += ( _cAliasSRD )->RD_VALOR
                          Endif
                       Endif
                ElseIf ( _cAliasSRD )->RD_PD $ mv_par12 //Terceiros
                       If Len( _aDadRel ) > 0
                          If aScan( _aDadRel, { |x| x[1] + x[19] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                             _nPos := 0
                             For _nY := 1 To Len( _aDadRel )
                                 If Empty( _aDadRel[ _nY ][ 19 ] ) .and. _nPos == 0 .and. _aDadRel[ _nY ][ 1 ] == ( _cAliasSRD )->RD_FILIAL
                                    _nPos := _nY
                                 Endif
                             Next
                             If _nPos <> 0
                                _aDadRel[ _nPos][19] := ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC
                                _aDadRel[ _nPos][20] := ( _cAliasSRD )->RD_VALOR
                             Else
                                aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, "", 0, "", 0, "", 0, 0, "", 0, "", 0, 0, 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR } )
                             Endif
                          Else
                             _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[19] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 20 ] += ( _cAliasSRD )->RD_VALOR
                          Endif
                       Else
                          If aScan( _aDadRel, { |x| x[1] + x[19] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) == 0
                             aAdd( _aDadRel, { ( _cAliasSRD )->RD_FILIAL, "", 0, "", 0, "", 0, "", 0, "", 0, 0, "", 0, "", 0, 0, 0, ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC, ( _cAliasSRD )->RD_VALOR } )
                          Else
                             _aDadRel[ aScan( _aDadRel, { |x| x[1] + x[19] == ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_PD + ' - ' + ( _cAliasSRD )->RV_DESC } ) ][ 20 ] += ( _cAliasSRD )->RD_VALOR
                          Endif
                       Endif
                Endif
             Endif
             DbSelectArea( _cAliasSRD )
             ( _cAliasSRD )->( DbSkip() )
       EndDo
       DbSelectArea( _cAliasSRD )
       ( _cAliasSRD )->( DbCloseArea( ) )
       
       For _nY := 1 To Len( _aDadRel )
           _nPos := aScan( _aTotFil, { |x| x[ 1 ] == _aDadRel[ _nY ][ 1 ] } )
           If _nPos == 0
              aAdd( _aTotFil, { _aDadRel[ _nY][ 1 ], _aDadRel[ _nY][ 3 ], _aDadRel[ _nY][ 5 ], _aDadRel[ _nY][ 7 ], _aDadRel[ _nY][ 9 ], _aDadRel[ _nY][ 11 ], _aDadRel[ _nY][ 12 ], _aDadRel[ _nY][ 14 ], _aDadRel[ _nY][ 16 ], _aDadRel[ _nY][ 17 ], _aDadRel[ _nY][ 18 ], _aDadRel[ _nY][ 20 ] } )
           Else
              _aTotFil[ _nPos][ 2 ] += _aDadRel[ _nY][  3 ]
              _aTotFil[ _nPos][ 3 ] += _aDadRel[ _nY][  5 ]
              _aTotFil[ _nPos][ 4 ] += _aDadRel[ _nY][  7 ]
              _aTotFil[ _nPos][ 5 ] += _aDadRel[ _nY][  9 ]
              _aTotFil[ _nPos][ 6 ] += _aDadRel[ _nY][ 11 ]
              _aTotFil[ _nPos][ 7 ] += _aDadRel[ _nY][ 12 ]
              _aTotFil[ _nPos][ 8 ] += _aDadRel[ _nY][ 14 ]
              _aTotFil[ _nPos][ 9 ] += _aDadRel[ _nY][ 16 ]
              _aTotFil[ _nPos][10 ] += _aDadRel[ _nY][ 17 ]
              _aTotFil[ _nPos][11 ] += _aDadRel[ _nY][ 18 ]
              _aTotFil[ _nPos][12 ] += _aDadRel[ _nY][ 20 ]
           Endif
           _nPosTer := aScan( _aTotTer, { |x| x[ 1 ] + x[ 2 ] == SubStr( _aDadRel[ _nY ][ 1 ], 1, 2 ) + _aDadRel[ _nY ][ 19 ] } )
           If _nPosTer == 0
              aAdd( _aTotTer, { SubStr( _aDadRel[ _nY ][ 1 ], 1, 2 ), _aDadRel[ _nY ][ 19 ], _aDadRel[ _nY ][ 20 ] })
           Else
              _aTotTer[ _nPosTer ][ 3 ] += _aDadRel[ _nY ][ 20 ]
           Endif
       Next
       For _nY := 1 To Len( _aTotFil )
           _nPos := aScan( _aTotGer, { |x| x[ 1 ] == SubStr( _aTotFil[ _nY ][ 1 ], 1, 2 ) } )
           If _nPos == 0
              aAdd( _aTotGer, { SubStr( _aTotFil[ _nY ][ 1 ], 1, 2 ), _aTotFil[ _nY][  2 ], _aTotFil[ _nY][  3 ], _aTotFil[ _nY][  4 ], _aTotFil[ _nY][  5 ], _aTotFil[ _nY][  6 ], _aTotFil[ _nY][  7 ], _aTotFil[ _nY][  8 ], _aTotFil[ _nY][  9 ], _aTotFil[ _nY][ 10 ], _aTotFil[ _nY][ 11 ], _aTotFil[ _nY][ 12 ] } )
           Else
              _aTotGer[ 1][ 2 ] += _aTotFil[ _nY][  2 ]
              _aTotGer[ 1][ 3 ] += _aTotFil[ _nY][  3 ]
              _aTotGer[ 1][ 4 ] += _aTotFil[ _nY][  4 ]
              _aTotGer[ 1][ 5 ] += _aTotFil[ _nY][  5 ]
              _aTotGer[ 1][ 6 ] += _aTotFil[ _nY][  6 ]
              _aTotGer[ 1][ 7 ] += _aTotFil[ _nY][  7 ]
              _aTotGer[ 1][ 8 ] += _aTotFil[ _nY][  8 ]
              _aTotGer[ 1][ 9 ] += _aTotFil[ _nY][  9 ]
              _aTotGer[ 1][10 ] += _aTotFil[ _nY][ 10 ]
              _aTotGer[ 1][11 ] += _aTotFil[ _nY][ 11 ]
              _aTotGer[ 1][12 ] += _aTotFil[ _nY][ 12 ]
           Endif
       Next
       If Len( _aEmpRel )
          _lRet := .t.
       Endif
Return _lRet

Static Function fVerSit( _cAliasSRD ) //Verifica situação de transferência
       Local _lRet := .t.
       
       DbSelectArea("SRE")
       SRE->( DbSetOrder(2) )
       If SRE->( DbSeek( FWGrpCompany() + ( _cAliasSRD )->RD_FILIAL +'      '+ ( _cAliasSRD )->RD_MAT ))
          If LastDay( STOD( mv_par03 + '01' ) ) <= SRE->RE_DATA .AND. SUBSTR( SRE->RE_FILIALD, 1, 2) <> SUBSTR( SRE->RE_FILIALP, 1, 2)
             _lRet := .f.
          Endif
       Endif
Return _lRet

Static Function fVerFun( _cAliasSRD ) //Verifica situação de transferência
       Local _cCatFun := .t.
       
       DbSelectArea("SRA")
       SRA->( DbSetOrder(1) )
       If SRA->( DbSeek( ( _cAliasSRD )->RD_FILIAL + ( _cAliasSRD )->RD_MAT ))
          _cCatFun := SRA->RA_CATFUNC
       Endif
Return _cCatFun

Static Function fVerPar()
       Local _cRet := "('"
       Local _cAux := ""
       Local _nY   := ""

       For _nY := 5 To 12
           _cAux := &( "mv_par" + StrZero( _nY, 2 ) )
           //_cAux := mv_par05
           While ! Empty( _cAux )
                 _cRet += SubStr( _cAux, 1, 3 ) + "', '"
                 _cAux := SubStr( Alltrim( _cAux ), If( At( ";", _cAux ) == 0, 3, At( ";", _cAux ) ) + 1 )
           EndDo
       Next
       _cRet := SubStr( _cRet, 1, Len( _cRet ) - 3) + ")"
       //_cRet := "('701', '702', '707', '726', '401', '403', '443', '744', '746') "

Return _cRet

Static Function fVerRAT( _aArrInf )
       Local _nRat := 0 
       
       DbSelectArea("C92")
       C92->( DbSetOrder( 3 ) )
       If C92->( DbSeek( xFilial("C92") + _aArrInf[ 18] ) )
          While !Eof() .and. Alltrim( C92->C92_NRINSC ) == Alltrim( _aArrInf[ 18] )
                If C92->C92_ATIVO == '1'
                   _nRat := C92->C92_AJURAT
                Endif
                DbSelectArea("C92")
                C92->( DbSkip() )
          EndDo
       Endif
Return _nRat

Static Function fVerROT( )
       Local _cRet := "('"
       Local _cAux := "" 
       //Local _nY   := ""

       _cAux := Alltrim( mv_par13 )
       While ! Empty( _cAux )
             _cRet += SubStr( _cAux, 1, 3 ) + "', '"
             _cAux := SubStr( Alltrim( _cAux ), 4 )
       EndDo
       _cRet := SubStr( _cRet, 1, Len( _cRet ) - 3) + ")"
Return _cRet

/*
Função para geração dos parâmetros
*/
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*Static Function fValPerg( _cPerg )
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
          u_zPutSX1( _cPerg   , "01"    , "Filial De ?          ", "mv_par01", "mv_ch1"  , "C"    ,  6        , 0         , "G"   , ""          , "XM0"   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "02" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código da Filial Final para Filtro dos dados." )
          u_zPutSX1( _cPerg   , "02"    , "Filial AtÚ ?         ", "mv_par02", "mv_ch2"  , "C"    ,  6        , 0         , "G"   , "NaoVazio"  , "XM0"   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "03" ) )
          aAdd( aHelpPor, "Informe o periodo para geração das informações." )
          u_zPutSX1( _cPerg   , "03"    , "Periodo ? "           , "mv_par03", "mv_ch3"  , "C"    ,  6        , 0         , "G"   , ""          , "   "   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "04" ) )
          aAdd( aHelpPor, "Informe o diretório para gravação da planilha." )
          u_zPutSX1( _cPerg   , "04"    , "Diretorio ? "         , "mv_par04", "mv_ch4"  , "C"    ,  30       , 0         , "G"   , ""          , "   "   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "05" ) )
          aAdd( aHelpPor, "Informe as verbas que fazem parte da Base do INSS para os empregados, separadas por ponto e virgula." )
          u_zPutSX1( _cPerg   , "05"    , "Base(INSS) Empregado" , "mv_par05", "mv_ch5"  , "C"    ,  60       , 0         , "G"   , ""          , "   "   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       If !SX1->(MsSeek( _cPerg + "06" ) )
          aAdd( aHelpPor, "Informe as verbas que fazem parte da Base do INSS para contribuintes individuais, separadas por ponto e virgula." )
          u_zPutSX1( _cPerg   , "06"    , "Base(INSS) Individual", "mv_par06", "mv_ch6"  , "C"    ,  60       , 0         , "G"   , ""          , "   "   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "07" ) )
          aAdd( aHelpPor, "Informe as verbas que fazem parte do INSS do Segurado, separadas por ponto e virgula." )
          u_zPutSX1( _cPerg   , "07"    , "Valor INSS Segurado" , "mv_par07", "mv_ch7"  , "C"    ,  60       , 0         , "G"   , ""          , "   "   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       If !SX1->(MsSeek( _cPerg + "08" ) )
          aAdd( aHelpPor, "Informe as verbas que fazem parte do INSS parte Empresa, separadas por ponto e virgula." )
          u_zPutSX1( _cPerg   , "08"    , "INSS parte empresa  ", "mv_par08", "mv_ch8"  , "C"    ,  60       , 0         , "G"   , ""          , "   "   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       If !SX1->(MsSeek( _cPerg + "09" ) )
          aAdd( aHelpPor, "Informe as verbas que fazem parte da RAT Ajustada, separadas por ponto e virgula." )
          u_zPutSX1( _cPerg   , "09"    , "RAT Ajustada", "mv_par09", "mv_ch9"  , "C"    ,  60       , 0         , "G"   , ""          , "   "   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       If !SX1->(MsSeek( _cPerg + "10" ) )
          aAdd( aHelpPor, "Informe as verbas que fazem parte da Dedução - Salário Familia, separadas por ponto e virgula." )
          u_zPutSX1( _cPerg   , "10"    , "Dedução - Salário Familia", "mv_par10", "mv_cha"  , "C"    ,  60       , 0         , "G"   , ""          , "   "   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       If !SX1->(MsSeek( _cPerg + "11" ) )
          aAdd( aHelpPor, "Informe as verbas que fazem parte da Dedução - Salário Maternidade, separadas por ponto e virgula." )
          u_zPutSX1( _cPerg   , "11"    , "Dedução - Salário Maternidade", "mv_par11", "mv_chb"  , "C"    ,  60       , 0         , "G"   , ""          , "   "   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       If !SX1->(MsSeek( _cPerg + "12" ) )
          aAdd( aHelpPor, "Informe as verbas que fazem parte de Outras Entidades, separadas por ponto e virgula." )
          u_zPutSX1( _cPerg   , "12"    , "Outras Entidades", "mv_par12", "mv_chc"  , "C"    ,  60       , 0         , "G"   , ""          , "   "   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       If !SX1->(MsSeek( _cPerg + "13" ) )
          aAdd( aHelpPor, "Informe o Roteiro - Usar 132 para 13º Salário ou FOL/AUT para folha de pagamento." )
          u_zPutSX1( _cPerg   , "13"    , "Roteiro", "mv_par13", "mv_chd"  , "C"    ,  30       , 0         , "G"   , "fRoteiro()"          , "   "   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "14" ) )
          aAdd( aHelpPor, "Informe o periodo aberto ou fechado.")
          u_zPutSX1( _cPerg   , "14"    , "Tipo ?               ", "mv_par14", "mv_che"  , "N"    ,  1        , 0         , "C"   , ""          , ""      , ""        , "Aberto"  , "Fechado"          , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
*/
/*
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "04" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código do Centro de Custo Final para Filtro dos dados." )
          u_zPutSX1( _cPerg   , "04"    , "Centro de Custo Até ?", "mv_par04", "mv_ch4"  , "C"    ,  9        , 0         , "G"   , "NaoVazio"  , "CTT"   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "05" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código de Matrícula Inicial para Filtro dos dados." )
          u_zPutSX1( _cPerg   , "05"    , "Matricula De ?       ", "mv_par05", "mv_ch5"  , "C"    ,  6        , 0         , "G"   , ""          , "SRA02A", ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "06" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código de Matrícula Final para Filtro dos dados.")
          u_zPutSX1( _cPerg   , "06"    , "Matricula Até ?      ", "mv_par06", "mv_ch6"  , "C"    ,  6        , 0         , "G"   , "NaoVazio  ", "SRA02A", ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "07" ) )
          aAdd( aHelpPor, "Informe o Nome do Funcionário Inicial para Filtro dos dados.")
          u_zPutSX1( _cPerg   , "07"    , "Nome De ?            ", "mv_par07", "mv_ch7"  , "C"    , 30        , 0         , "G"   , "          ", ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "08" ) )
          aAdd( aHelpPor, "Informe o Nome do Funcionário Final para Filtro dos dados.")
          u_zPutSX1( _cPerg   , "08"    , "Nome Até ?           ", "mv_par08", "mv_ch8"  , "C"    , 30        , 0         , "G"   , "NaoVazio  ", ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "09" ) )
          aAdd( aHelpPor, "Informe ou selecione uma Categoria p/ Funcionários para filtro dos dados.")
          u_zPutSX1( _cPerg   , "09"    , "Categorias ?         ", "mv_par09", "mv_ch9"  , "C"    , 15        , 0         , "G"   , "fCategoria", ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "10" ) )
          aAdd( aHelpPor, "Informe a Data do Período Inicial que deseja filtrar os dados.")
          u_zPutSX1( _cPerg   , "10"    , "Periodo De ?         ", "mv_par10", "mv_cha"  , "D"    ,  8        , 0         , "G"   , "NaoVazio"  , ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "11" ) )
          aAdd( aHelpPor, "Informe a Data do Período Final que desejá filtrar os dados.")
          u_zPutSX1( _cPerg   , "11"    , "Periodo Ate ?        ", "mv_par11", "mv_chb"  , "D"    ,  8        , 0         , "G"   , "NaoVazio"  , ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "12" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código do Sindicato que deseja imprimir, ou informe 99, que estará selecionando todos os sindicatos cadastrados.")
          u_zPutSX1( _cPerg   , "12"    , "Sindicato(99-Todos) ?", "mv_par12", "mv_chc"  , "C"    ,  2        , 0         , "G"   , "NaoVazio"  , "RCE"   , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "13" ) )
          aAdd( aHelpPor, "Informe o Número de Colunas que desejam configurar para impressão das Etiquetas.")
          u_zPutSX1( _cPerg   , "13"    , "Numero Colunas ?     ", "mv_par13", "mv_chd"  , "N"    ,  1        , 0         , "G"   , "naovazio"  , ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "14" ) )
          aAdd( aHelpPor, "Informe para Férias.")
          u_zPutSX1( _cPerg   , "14"    , "Informe para férias  ", "mv_par14", "mv_che"  , "C"    , 40        , 0         , "G"   , ""          , ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "15" ) )
          aAdd( aHelpPor, "Informe o tipo de Etiqueta que  será impressa: Entrada (Admissão) ou Saída (Demissão).")
          u_zPutSX1( _cPerg   , "15"    , "Tipo ?               ", "mv_par15", "mv_chf"  , "N"    ,  1        , 0         , "C"   , ""          , ""      , ""        , "Entrada"  , "Saida"          , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "16" ) )
          aAdd( aHelpPor, "Informe ou Selecione as Situações dos Funcionários para Filtro dos dados.")
          u_zPutSX1( _cPerg   , "16"    , "Situações ?          ", "mv_par16", "mv_chg"  , "C"    ,  5        , 0         , "G"   , "fSituacao" , ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "17" ) )
          aAdd( aHelpPor, "Informe em qual coluna se inicia a impressão das informações")
          u_zPutSX1( _cPerg   , "17"    , "Coluna Inicial       ", "mv_par17", "mv_chh"  , "N"    ,  1        , 0         , "G"   , ""          , ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "18" ) )
          aAdd( aHelpPor, "Informe a ordem das etiquetas para que sejam impressas.")
          u_zPutSX1( _cPerg   , "18"    , "Ordem de Impressao   ", "mv_par18", "mv_chi"  , "N"    ,  1        , 0         , "C"   , ""          , ""      , ""        , "Matricula", "Centro de Custo", "Nome"  , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "19" ) )
          aAdd( aHelpPor, "Escolha o tipo de etiqueta a ser impressa. Alteração Salarial ou Férias.")
          u_zPutSX1( _cPerg   , "19"    , "Tipo de Etiqueta     ", "mv_par19", "mv_chj"  , "N"    ,  1        , 0         , "C"   , ""          , ""      , ""        , "Alteração Salarial", "Férias", ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "20" ) )
          aAdd( aHelpPor, "Informe em qual linha de etiqueta se inicia a impressão das informações")
          u_zPutSX1( _cPerg   , "20"    , "Linha Inicial       ", "mv_par20", "mv_chh"  , "N"    ,  2        , 0         , "G"   , ""          , ""      , ""        , ""         , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif*/
/*
       RestArea( _aArea )
Return*/
