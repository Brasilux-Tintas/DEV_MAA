#include 'totvs.ch'
#include 'appexcel.ch'
/*/{Protheus.doc} ZGPER12
//RELATÓRIO PARA GERAÇÃO DE VALORES PARA VALECARD - VALE ALIMENTAÇÃO
@author Luís Gustavo de Souza
@since 28/12/2018
@version 6
@return ${return}, ${return_description}
@type function
/*/
User Function ZGPER12()
     Local oExcel      := AppExcel():New()
     Local _cNomArq    := ""
     Local _cPerg      := "ZGPER07   "
     Local _aEmpRel    := {}
     Local _aDadRel    := {}
     Local _aTabVA     := {}
     Local _aContab    := {}
     Local _lRetImp    := .F.
     Local _nLin       := 0
     Local _nX         := 0
     Local _nY         := 0
     Local _nPosCTB    := 0
     Private MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08, MV_PAR09, MV_PAR10, MV_PAR11, MV_PAR12
     Private oFont1    := AppExcFont():New( "Calibri", '14', '#000000')
     Private oFont2    := AppExcFont():New( "Calibri", '12', '#000000')
     Private oFont3    := AppExcFont():New( "Calibri", '12', '#000000')
     Private oFont4    := AppExcFont():New( "Calibri", '12', '#FF0000')
     Private _oProcess 
 
     _oProcess := MsNewProcess( ):New( { | | fDados( @_aEmpRel, @_aDadRel, _aTabVA, @_lRetImp ) }, "Processando...", "Aguarde...", .T. )
  
     //fValPerg( _cPerg ) //Chamada da Criação das perguntas  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     If ! Pergunte( _cPerg ) 
        Return() //Se cancelar as perguntas sai do programa
     Else
        If !Empty( MV_PAR05 )
           _cSit	:= ""
           For _nY := 1 To Len( Alltrim( MV_PAR05 ) )
               If Substr( MV_PAR05, _nY, 1 ) <> '*'
                  _cSit += Substr( MV_PAR05, _nY, 1 ) + "', '"
               EndIf
           Next
           MV_PAR05 := Substr( _cSit, 1, Len( _cSit ) - 4 )
        Else
           MV_PAR05 := "' '"
        EndIf

        If !Empty( MV_PAR06 )
           _cCateg := ""
           For _nY := 1 To Len( Alltrim( MV_PAR06 ) )
               If Substr( MV_PAR06, _nY, 1 ) <> '*'
                  _cCateg += Substr( MV_PAR06, _nY, 1 ) + "', '"
               EndIf
           Next
           MV_PAR06 := Substr( _cCateg, 1, Len( _cCateg ) - 4 )
        Else
           MV_PAR06:= "' '"
        EndIf
     Endif
     fCarrTab( @_aTabVA, "U003" )
     _oProcess:Activate() //Ativa chamada do processo.

     If !_lRetImp
        MsgAlert("Não existem dados para esse relatório")
        Return() //Se não tiver dados para impressão sai do programa
     Endif

     /*************************************************************************************************************/
     /***   GERAÇÃO DOS ARQUIVOS DE VALE ALIMENTAÇÃO                                                            ***/ 
     /*************************************************************************************************************/
     //CONFIGURAÇÕES DAS CELULAS
     oFont1:SetBold( .T. )
     oCelL01C01 := AppExcCell():New(); oCelL01C01:SetCellColor("#FFFFFF"); oCelL01C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER )  //   jose   ; oCelL01C01:SetFont( oFont1 )
     oCelL01C01:SetVertAlign( VERTICAL_ALIGN_CENTER )
     oFont2:SetBold( .T. )
     oCelL02C01 := AppExcCell():New(); oCelL02C01:SetCellColor("#FFFFFF"); oCelL02C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER )  //   jose   ; oCelL02C01:SetFont( oFont2 )
     oCelL02C01 :SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL03C01 := AppExcCell():New(); oCelL03C01:SetCellColor("#FFFFFF"); oCelL03C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER )  //   jose   ; oCelL03C01:SetFont( oFont2 )
     oCelL03C01 :SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL03C01 :SetBorder( BORDER_POSITION_TOP   , .t. ); oCelL03C01:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL03C01:SetBorder(    BORDER_POSITION_RIGHT, .t. )
     oCelL03C01 :SetLineWeigth(BORDER_POSITION_TOP, 1   ); oCelL03C01:SetLineWeigth(BORDER_POSITION_LEFT, 1   ); oCelL03C01:SetLineWeigth(BORDER_POSITION_RIGHT, 1   )
     oCelL03C01 :SetBorder(    BORDER_POSITION_BOTTOM, .t. ); oCelL03C01:SetLineWeigth(BORDER_POSITION_BOTTOM, 1   )
     oCelL04C01 := AppExcCell():New(); oCelL04C01:SetCellColor("#FFFFFF"); oCelL04C01:SetHorzAlign( HORIZONTAL_ALIGN_LEFT )  //   jose  ; oCelL04C01:SetFont( oFont3 )
     oCelL04C01 :SetBorder( BORDER_POSITION_BOTTOM, .t. ); oCelL04C01:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL04C01:SetBorder(    BORDER_POSITION_RIGHT, .t. )
     oCelL04C01 :SetLineWeigth(BORDER_POSITION_BOTTOM, 1   ); oCelL04C01:SetLineWeigth(BORDER_POSITION_LEFT, 1   ); oCelL04C01:SetLineWeigth(BORDER_POSITION_RIGHT, 1   )
     oCelL04C01 :SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL05C01 := AppExcCell():New(); oCelL05C01:SetCellColor("#FFFFFF"); oCelL05C01:SetHorzAlign( HORIZONTAL_ALIGN_LEFT )   //  jose  ; oCelL05C01:SetFont( oFont4 )
     oCelL05C01 :SetBorder( BORDER_POSITION_BOTTOM, .t. ); oCelL05C01:SetBorder(    BORDER_POSITION_LEFT, .t. ); oCelL05C01:SetBorder(    BORDER_POSITION_RIGHT, .t. )
     oCelL05C01 :SetLineWeigth(BORDER_POSITION_BOTTOM, 1   ); oCelL05C01:SetLineWeigth(BORDER_POSITION_LEFT, 1   ); oCelL05C01:SetLineWeigth(BORDER_POSITION_RIGHT, 1   )
     oCelL05C01 :SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL06C01 := AppExcCell():New(); oCelL06C01:SetCellColor("#FFFFFF"); oCelL06C01:SetHorzAlign( HORIZONTAL_ALIGN_CENTER )   //   jose  ; oCelL06C01:SetFont( oFont2 )
     oCelL06C01 :SetVertAlign( VERTICAL_ALIGN_CENTER )
     oCelL06C01 :SetBorder( BORDER_POSITION_TOP   , .t. )
     oCelL06C01 :SetLineWeigth(BORDER_POSITION_TOP, 1   )
     
     oCelL06C02 := AppExcCell():New(); oCelL06C02:SetCellColor("#FFFFFF"); oCelL06C02:SetHorzAlign( HORIZONTAL_ALIGN_RIGHT )  //   jose   ; oCelL06C02:SetFont( oFont2 )
//   inibido por jose 03/08/201    e se tiver que voltar apagar a linha de baixo deste 
//   oCelL06C02:SetFormat( NUMBER_CURRENCY_REAL ); oCelL06C02:SetBorder(    BORDER_POSITION_RIGHT, .t. ); oCelL06C02:SetLineWeigth(BORDER_POSITION_RIGHT, 2   )
     oCelL06C02 :SetBorder(    BORDER_POSITION_BOTTOM, .t. ); oCelL06C02:SetLineWeigth(BORDER_POSITION_BOTTOM, 1   ); oCelL06C02:SetVertAlign( VERTICAL_ALIGN_CENTER )

     oCelL06C03 := AppExcCell():New(); oCelL06C03:SetCellColor("#FFFFFF"); oCelL06C03:SetHorzAlign( HORIZONTAL_ALIGN_RIGHT ) //   jose   ; oCelL06C03:SetFont( oFont2 )
//     oCelL06C03:SetFormat( NUMBER_CURRENCY_REAL )    ---- Inibido por Jose 03/08/2021
     oCelL06C03 :SetBorder(    BORDER_POSITION_RIGHT , .t. ); oCelL06C03:SetLineWeigth(BORDER_POSITION_RIGHT , 1   )
     oCelL06C03 :SetBorder(    BORDER_POSITION_LEFT  , .t. ); oCelL06C03:SetLineWeigth(BORDER_POSITION_LEFT  , 1   )
     oCelL06C03 :SetBorder(    BORDER_POSITION_TOP   , .t. ); oCelL06C03:SetLineWeigth(BORDER_POSITION_TOP   , 1   )
     oCelL06C03 :SetBorder(    BORDER_POSITION_BOTTOM, .t. ); oCelL06C03:SetLineWeigth(BORDER_POSITION_BOTTOM, 1   )

     _cNomArq := "VALECARD_" + "_" + MV_PAR03 + "_" + DTOS( dDataBase ) + "_" + StrTran( Time(), ":", "" ) + ".xml"
     _cNomCon := "CONTABIL" + "_" + MV_PAR03 + "_" + DTOS( dDataBase ) + "_" + StrTran( Time(), ":", "" ) + ".xml"
//  Acrescentado por Jose 04/08/2021 --------------------------------------------------
     _vNomTXT := "VALECARD_" + "_" + MV_PAR03 + "_" + DTOS( dDataBase ) + "_" + StrTran( Time(), ":", "" ) + ".txt"
     _vLinTXT := 'MATRIC NOME                                VALOR   ' + chr(13) + chr(10)
     //           999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   9,999.99
     MemoWrite( Alltrim( MV_PAR04 ) + _vNomTXT, _vLinTXT )
//---------------------------------------- JOSE ---------------------------------------
     oExcel:SetDestPath( Alltrim( MV_PAR04 ) )
     oExcel:SetFileName( '\dirdoc\rh\' + _cNomArq )
     If ! ExistDir( MV_PAR04 )
          MakeDir( MV_PAR04 )
     Endif
     //_oProcess:IncRegua1( "Gerando relatório..." ) //Ajusta escrita do processo principal
     For _nY := 1 To Len ( _aEmpRel )
         _nLin   := 1
         _nSomaT := 0
         _nContT := 0
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
                oExcel:Merge( _nLin,  1, 0, 0, ''                                                       , oCelL02C01 )
                oExcel:Merge( _nLin,  2, 0, 0, _aDadRel[ _nX][ 2]                                       , oCelL03C01 ) // oCelL04C01 ) alterado por jose 01/10/0021
                oExcel:Merge( _nLin,  3, 0, 0, _aDadRel[ _nX][ 3]                                       , oCelL03C01 ) // oCelL04C01 ) alterado por jose 01/10/0021
                oExcel:Merge( _nLin,  4, 0, 0, _aDadRel[ _nX][ 4]                                       , oCelL03C01 ) // oCelL05C01 ) alterado por jose 01/10/0021 
                oExcel:Merge( _nLin,  5, 0, 0, _aDadRel[ _nX][ 5]                                       , oCelL03C01 ) // oCelL06C02 ) alterado por jose 01/10/0021
                oExcel:Merge( _nLin,  6, 0, 0, ''                                                       , oCelL02C01 ) // oCelL02C01 )  oCelL06C02 ) alterado por jose 01/10/0021
                _nSomaT += _aDadRel[ _nX][ 5]
//----------------- acrescentado por Jose 04/08/2021 --------------------
                _vLinTXT += SubStr( _aDadRel[ _nX][ 2] + Space( 6 ), 1, 6 ) + ' ' + SubStr( _aDadRel[ _nX][ 3] + Space( 6 ), 1, 30 ) + ' ' + ' ' + TransForm( _aDadRel[ _nX][ 5], "@E 9,999.99" ) + chr(13) + chr(10)
//------------------ jose ------------------------------------------------
                _nLin += 1
                _nContT += 1
             Endif
         Next
         //Totalizador
         oExcel:Merge( _nLin, 01, 00, 00, ''                                                             , oCelL02C01 )
         oExcel:Merge( _nLin, 02, 02, 00, 'TOTAL - ' + Transform( _nContT, "@E 9999" ) + ' Funcionarios.', oCelL03C01 )
         oExcel:Merge( _nLin, 05, 00, 00, _nSomaT                                                        , oCelL06C03 )
         oExcel:Merge( _nLin, 06, 00, 00, ''                                                             , oCelL02C01 )
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
// acrescentado Por Jose ----------------------------------
     MemoWrite( Alltrim( MV_PAR04 ) + _vNomTXT, _vLinTXT )
//---------------------------------------------------------
     oExcel:Make( .F. )
     oExcel:SetFileName( Alltrim( MV_PAR04 ) + _cNomArq )
     oExcel:Destroy()
     /*************************************************************************************************************/
     /***   GERAÇÃO DOS ARQUIVOS DE RECARGA                                                                     ***/
     /*************************************************************************************************************/
     For _nY := 1 To Len ( _aEmpRel )
         _cNomRec := "RECARGA_" + _aEmpRel[ _nY] + "_" + MV_PAR03 + "_" + DTOS( dDataBase ) + "_" + StrTran( Time(), ":", "" ) + ".xml"
         _cNomTXT := "IMPORTA_" + _aEmpRel[ _nY] + "_" + MV_PAR03 + "_" + DTOS( dDataBase ) + "_" + StrTran( Time(), ":", "" ) + ".txt"
         _cLinTXT := 'MATRIC NOME                              VALOR   ' + chr(13) + chr(10)
         //           999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 9,999.99
         oExcel:= AppExcel():New()
         oExcel:SetDestPath( Alltrim( MV_PAR04 ) )
         oExcel:SetFileName( '\dirdoc\rh\' + _cNomRec )

         _nLin    := 1
         _cCodEmp := SubStr( _aEmpRel[ _nY ], 1, 2 )
         _aArrEmp := FWArrFilAtu( FWGrpCompany(), _aEmpRel[ _nY] )

         oExcel:Merge( _nLin, 1, 00, 00, 'Matrícula'                                                , oCelL02C01 )
         oExcel:Merge( _nLin, 2, 00, 00, 'Nome'                                                     , oCelL03C01 )
         oExcel:Merge( _nLin, 3, 00, 00, 'Novo Limite'                                              , oCelL03C01 )
         oExcel:Merge( _nLin, 4, 00, 00, 'Referência'                                               , oCelL03C01 )
         _nLin += 1
         For _nX := 1 TO Len( _aDadRel )
             If _aEmpRel[ _nY] == _aDadRel[ _nX][1]
                oExcel:Merge( _nLin,  1, 0, 0, _aDadRel[ _nX][ 2]                                    , oCelL02C01 )
                oExcel:Merge( _nLin,  2, 0, 0, _aDadRel[ _nX][ 3]                                    , oCelL04C01 )
                oExcel:Merge( _nLin,  3, 0, 0, _aDadRel[ _nX][ 5]                                    , oCelL06C02 )
                oExcel:Merge( _nLin,  4, 0, 0,                                                       , oCelL05C01 )
                _cLinTXT += SubStr( _aDadRel[ _nX][ 2] + Space( 6 ), 1, 6 ) + ' ' + SubStr( _aDadRel[ _nX][ 3] + Space( 6 ), 1, 30 ) + ' ' + TransForm( _aDadRel[ _nX][ 5], "@E 9,999.99" ) + chr(13) + chr(10)
                _nLin += 1
             Endif
         Next
         MemoWrite( Alltrim( MV_PAR04 ) + _cNomTXT, _cLinTXT )
         oExcel:Make( .F. )
         oExcel:SetFileName( Alltrim( MV_PAR04 ) + _cNomRec )
         oExcel:Destroy()
     Next
     
     /*************************************************************************************************************/
     /***   GERAÇÃO DOS ARQUIVOS DE CONTABILIZAÇÃO                                                              ***/
     /*************************************************************************************************************/
     _aContab := {}
     For _nX := 1 TO Len( _aDadRel )
         _nPosCtb := aScan( _aContab, { |x| Alltrim( x[ 9] ) == Alltrim( _aDadRel[ _nX][ 8] ) } )
         If _nPosCtb == 0
            aAdd( _aContab, { '001' + space( 06 ),;                    //01
            	              Alltrim( _aDadRel[ _nX][ 8] ) + '015' + ( Space( 20 - Len( Alltrim( _aDadRel[ _nX][ 8] ) + '015' ) ) ),; //02
            	              Space( 20 ),;                             //03
            	              Alltrim( '501010101' ) + '016' + ( Space( 20 - Len( Alltrim( '501010101' ) + '016' ) ) ),; //04
            	              Space( 20 ),;                             //05
            	              _aDadRel[ _nX][ 5],;                      //06
            	              Space( 09 ),;                             //07
            	              'lct txt - apropr mensal vale cesta',;    //08
            	              _aDadRel[ _nX][ 8] } )                    //09
         Else
            _aContab[ _nPosCTB][ 6 ] += _aDadRel[ _nX][ 5]
         Endif
     Next
     For _nY := 1 To Len ( _aEmpRel )
         _cNomRec := "CONTABIL_" + _aEmpRel[ _nY] + "_" + MV_PAR03 + "_" + DTOS( dDataBase ) + "_" + StrTran( Time(), ":", "" ) + ".xml"
         oExcel := AppExcel():New()
         oExcel:SetDestPath( Alltrim( MV_PAR04 ) )
         oExcel:SetFileName( '\dirdoc\rh\' + _cNomRec )

         _nLin   := 1
         _cCodEmp := SubStr( _aEmpRel[ _nY ], 1, 2 )
         _aArrEmp := FWArrFilAtu( FWGrpCompany(), _aEmpRel[ _nY] )
         
         oExcel:SetSheetName( Alltrim( "REFERENCIA" ) )
         
         oExcel:Merge( _nLin, 1, 00, 00, 'Matrícula'                                                , oCelL02C01 )
         oExcel:Merge( _nLin, 2, 00, 00, 'Nome'                                                     , oCelL03C01 )
         oExcel:Merge( _nLin, 3, 00, 00, 'Novo Limite'                                              , oCelL03C01 )
         oExcel:Merge( _nLin, 4, 00, 00, 'Filial'                                                   , oCelL03C01 )
         oExcel:Merge( _nLin, 5, 00, 00, 'Centro Custo'                                             , oCelL03C01 )
         oExcel:Merge( _nLin, 6, 00, 00, 'Conta Contabil'                                           , oCelL03C01 )
         _nLin += 1
         For _nX := 1 TO Len( _aDadRel )
             If _aEmpRel[ _nY] == _aDadRel[ _nX][1]
                oExcel:Merge( _nLin,  1, 0, 0, _aDadRel[ _nX][ 2]                                    , oCelL02C01 )
                oExcel:Merge( _nLin,  2, 0, 0, _aDadRel[ _nX][ 3]                                    , oCelL04C01 )
                oExcel:Merge( _nLin,  3, 0, 0, _aDadRel[ _nX][ 5]                                    , oCelL06C02 )
                oExcel:Merge( _nLin,  4, 0, 0, _aDadRel[ _nX][ 1]                                    , oCelL05C01 )
                oExcel:Merge( _nLin,  5, 0, 0, _aDadRel[ _nX][ 6]                                    , oCelL05C01 )
                oExcel:Merge( _nLin,  6, 0, 0, _aDadRel[ _nX][ 8]                                    , oCelL05C01 )
                _nLin += 1
             Endif
         Next

         _nLin   := 1
         oExcel:AddSheet( Alltrim( 'CONTABILIZA' ) )

         //Codigo Lançamento Padrão - Posição  01, tamanho 09 - Fixo 001
         //Conta Débito             - Posição  10, tamanho 20
         //                         - Posição  30, tamanho 20
         //Conta Crédito            - Posição  50, tamanho 20
         //                         - Posição  70, tamanho 20
         //Valor                    - Posição  80, tamanho 17
         //Historico                - Posição 100, tamanho 40 - Fixo lct txt - apropr mensal vale cesta
         For _nX := 1 TO Len( _aContab )
             _cStrCont := _aContab[ _nX][ 1] // 1
             _cStrCont += _aContab[ _nX][ 2] // 2
             _cStrCont += _aContab[ _nX][ 3] // 3
             _cStrCont += _aContab[ _nX][ 4] // 4
             _cStrCont += _aContab[ _nX][ 5] // 5
             _cStrCont += TransForm( _aContab[ _nX][ 6] * 100, "@E 9999999") // 6
             _cStrCont += _aContab[ _nX][ 7] // 7
             _cStrCont += _aContab[ _nX][ 8] // 8

             oExcel:Merge( _nLin,  1, 0, 0, _cStrCont                       , oCelL02C01 )

             _nLin += 1
         Next
         oExcel:Make( .F. )
         oExcel:SetFileName( Alltrim( MV_PAR04 ) + _cNomRec )
         oExcel:Destroy()
     Next
     MsgInfo( 'Arquivos gerados com sucesso em ' + Alltrim( MV_PAR04 ) + '.' , 'Informação...' )

Return

/*/{Protheus.doc} fDados
Função para busca e tratamento de dados a serem impressos/gerados em excel.
@type function
@author Luís Gustavo de Souza
@since 05/07/2019
@version 1.0
@param _aEmpRel, ${param_type}, Array com dados das empresas.
@param _aDadRel, ${param_type}, Array com dados a serem impressos.
@param _aTabVA, ${param_type}, Array com dados de referencia hora atraso/falta x valores
@param _lRetImp, ${param_type}, Variável de retorno se há dados a serem impressos
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function fDados( _aEmpRel, _aDadRel, _aTabVA, _lRetImp )
       Local _cAliasSPO := GetNextAlias() //Alias para tabela SPO - Periodos de Apontamento
       Local _cAliasSRA := GetNextAlias() //Alias para tabela SRA - Funcionários
       Local _cAliasTNY := GetNextAlias() //Alias para tabela TNY - Atestados Médicos
       Local _cAliasSPH := GetNextAlias() //Alias para tabela SPH - Historico de Apontamentos 
       Local _cWhere    := "%"
// inibido dia 24/06 tirar no oficial, tirado a inibição dia 27/06/2022 para testar
       Local _FimPer    := Iif( Alltrim( GetMV("MV_PAPONTA") ) $ '01/31', LastDate( CTOD( '01/' + SubStr( MV_PAR03, 5, 2) + '/' + SubStr( MV_PAR03, 1, 4) ) ), STOD( MV_PAR03 + Alltrim( SubStr( GetMV("MV_PAPONTA"), AT( '/', GetMV("MV_PAPONTA") ) + 1 ) ) ) )
// Acrescentado por Jose 23/09/2021 depois tirar ------------------
//       Local FimPer     := "20220520"
//-----------------------------------------------------------------
       Local _aAuxFun   := {} //Array com dados dos funcionarios
       Local _aAuxTNY   := {} //Array com dados dos atestados
       Local _aAuxPON   := {} //Array com dados dos apontamentos
       Local _aAuxAUS   := {} //Array com dados tratados de apontamentos
       Local _aValidFil := StrToArray( fValidFil(), "/" ) //Empresas validas
       Local _cValidFil := "" //Filiais válidas
       Local _cOcorr    := "" //Ocorrência a ser gerada por funcionário
       Local _nX, _nY, _nZ    //Variáveis de controle de laço
       Local _cFilEmp   := ""
       Local _nValCs    := 0
       Local _cTipoVl   := 'F'
       Local _nSomHr    := 0
       Local _nAtras    := 0
       Local aAfastaPer := {}
       Local lAfastaPer := .f.
       Local _cTipBus   := ""
       Local _nHrsDest  := 0
       Local _nHrsFixo  := 0
//------Acrescentado por   jose --------------------------
       Local _Vlimite   := "08:48"
//--------------------------------------------------------

       _oProcess:SetRegua1( 6 )    //Seta Regua do Processo principal
       _oProcess:SetRegua2( 2 )    //Seta Regua do Processo secundário
       
       //Montando variável de filiais
       _cValidFil := "% SRA.RA_FILIAL IN('"
       For _nY := 1 To Len( _aValidFil )
           If _aValidFil[ _nY] >= MV_PAR01 .and. _aValidFil[ _nY] <= MV_PAR02
              _cValidFil += _aValidFil[ _nY] + "', '"
              aAdd( _aEmpRel, _aValidFil[ _nY] )
           Endif
       Next
       _cValidFil := SubStr( _cValidFil, 1, Len( _cValidFil ) - 3 ) + ') %'
       
       //Busca Informações do Periodo
       _oProcess:IncRegua1( "Buscando periodo..." ) //Ajusta escrita do processo principal
       _cWhere += "%"
       BeginSql ALIAS _cAliasSPO
                COLUMN PO_DATAINI AS DATE
                COLUMN PO_DATAFIM AS DATE
                SELECT SPO.PO_DATAINI, SPO.PO_DATAFIM, SPO.PO_FLAGFEC  
                FROM %Table:SPO% SPO
                WHERE %exp:_cWhere% 
                  SPO.%notDel% AND 
//------   INIBIDO E ACESCENTADO POR jOSE   23/09/2021   DEPOIS TIRAR -----------------]
                  SPO.PO_DATAFIM = %exp:_FimPer% 
//                  SPO.PO_DATAFIM = %exp:FimPer%
//------------------------------------------------------------------------------
       EndSql
       
       DbSelectArea( _cAliasSPO )
       If ( _cAliasSPO )->PO_FLAGFEC == '0' 
          _dDatIni := ( _cAliasSPO )->PO_DATAINI 
          _dDatFim := ( _cAliasSPO )->PO_DATAFIM
          _lPerAbe := .f. //Periodo Fechado
       Else  //Se o periodo for aberto
          //_dDatIni := STOD( SubStr( MV_PAR03, 1, 4 ) + StrZero( Val( SubStr( MV_PAR03, 5, 2 ) ) - 1, 2 )  + Alltrim( SubStr( GetMV("MV_PAPONTA"), 1, AT( '/', GetMV("MV_PAPONTA") ) - 2 ) ) ) 
          _dDatIni := STOD( SubStr( MV_PAR03, 1, 4 ) + StrZero( Val( SubStr( MV_PAR03, 5, 2 ) ) -0, 2 )  + Alltrim(SubStr(GetMV("MV_PAPONTA"),7,2)))
          _dDatFim := STOD( MV_PAR03 + Alltrim( SubStr( GetMV("MV_PAPONTA"), len( alltrim(GetMV("MV_PAPONTA")))-1,2)))
          //, AT( '/', GetMV("MV_PAPONTA") ) + 1 ) ) )    
          _lPerAbe := .t.  //Periodo Aberto
       Endif 
       _oProcess:IncRegua2( "Periodo " + MV_PAR03 + "..." )

       //Busca Informações dos Funcionários
       _oProcess:IncRegua1( "Buscando funcionarios..." ) //Ajusta escrita do processo principal
       BeginSql ALIAS _cAliasSRA
                SELECT SRA.RA_FILIAL, SRA.RA_MAT, TM0.TM0_NUMFIC, SRA.RA_NOME, SRA.RA_CC, CTT.CTT_DESC01, SRA.RA_CIC, SRA.RA_HRSDIA, SRA.RA_HRSEMAN, SRA.RA_HRSMES, SRA.RA_CATEFD, SRA.RA_REGRA, CTT.CTT_NOME 
                     FROM %Table:SRA% SRA 
                JOIN %Table:CTT% CTT ON CTT.D_E_L_E_T_ = '' AND CTT.CTT_CUSTO = SRA.RA_CC  AND CTT.CTT_FILIAL = SUBSTRING(SRA.RA_FILIAL,1,2) //CTT.CTT_FILIAL = '01'
                JOIN %Table:TM0% TM0 ON TM0.D_E_L_E_T_ = '' AND TM0.TM0_MAT   = SRA.RA_MAT AND TM0.TM0_FILIAL = SRA.RA_FILIAL
                WHERE %exp:_cWhere% 
                     SRA.%notDel% AND 
                     %exp:_cValidFil% AND 
                     //SRA.RA_MSBLQL IN ('2') AND
                     SRA.RA_SITFOLH IN(%exp:MV_PAR05%) AND 
                     SRA.RA_CATFUNC IN(%exp:MV_PAR06%) AND
                     SRA.RA_MAT BETWEEN %exp:MV_PAR11% AND %exp:MV_PAR12% 
                ORDER BY %Order:SRA,3% 
       EndSQL
       DbSelectArea( _cAliasSRA ) 
       While !Eof()
             _oProcess:IncRegua2( "Funcionario " + ( _cAliasSRA )->RA_FILIAL + " / " + Alltrim( ( _cAliasSRA )->RA_MAT ) )
             //                                   1                         2                         3                        4                         5                         6                        7                         8                            9                        10                           11     12                      13                         14
             aAdd( _aAuxFun, { ( _cAliasSRA )->RA_FILIAL, ( _cAliasSRA )->RA_MAT, ( _cAliasSRA )->TM0_NUMFIC, ( _cAliasSRA )->RA_NOME, ( _cAliasSRA )->RA_CC, ( _cAliasSRA )->CTT_DESC01, ( _cAliasSRA )->RA_CIC, ( _cAliasSRA )->RA_HRSDIA, ( _cAliasSRA )->RA_HRSEMAN, ( _cAliasSRA )->RA_HRSMES, ( _cAliasSRA )->RA_CATEFD, ' ', ( _cAliasSRA )->RA_REGRA, ( _cAliasSRA )->CTT_NOME } )
             ( _cAliasSRA )->( DbSkip() )
       EndDo
       _oProcess:IncRegua1( "Buscando afastamentos/atrasos..." ) //Ajusta escrita do processo principal
       _oProcess:SetRegua2( Len( _aAuxFun ) )
       For _nY := 1 To Len( _aAuxFun )
           _oProcess:IncRegua2( "Buscando informação: " + SubStr( _aAuxFun[ _nY][ 4 ], 1, 25 ) )
           //Atestado
           BeginSql ALIAS _cAliasTNY 
                    Column TNY_DTINIC as DATE
                    Column TNY_DTFIM  as DATE
                    SELECT TNY.TNY_DTINIC, TNY.TNY_HRINIC, TNY.TNY_DTFIM, TNY.TNY_HRFIM, TNY.TNY_CODABO, TNY.TNY_QTDIAS 
                    FROM %Table:TNY% TNY 
                    WHERE %exp:_cwhere%  
                      TNY.%notDel% AND 
                      TNY.TNY_FILIAL = %exp:_aAuxFun[ _nY][ 1]% AND  
                      //( ( TNY.TNY_DTINIC BETWEEN %exp:_dDatIni% AND %exp:_dDatFim%  ) OR ( TNY.TNY_DTFIM BETWEEN %exp:_dDatIni% AND %exp:_dDatFim% ) OR ( TNY.TNY_DTFIM = ' ' ) ) AND 
                      ( ( TNY.TNY_DTINIC BETWEEN %exp:_dDatIni% AND %exp:_dDatFim%  ) OR ( TNY.TNY_DTFIM BETWEEN %exp:_dDatIni% AND %exp:_dDatFim% ) AND ( TNY.TNY_DTFIM = ' ' ) ) AND 
                      TNY.TNY_NUMFIC = %exp:_aAuxFun[ _nY][ 3]% 
           EndSql

           DbSelectArea( _cAliasTNY )
           While !Eof() 
                 aAdd( _aAuxTNY, { _aAuxFun[ _nY][ 1], _aAuxFun[ _nY][ 2], _aAuxFun[ _nY][ 3], Iif( (_cAliasTNY)->TNY_DTINIC < _dDatIni, _dDatIni, (_cAliasTNY)->TNY_DTINIC ) , (_cAliasTNY)->TNY_HRINIC, Iif( Empty( (_cAliasTNY)->TNY_DTFIM ), _dDatFim,(_cAliasTNY)->TNY_DTFIM ), Iif( Empty( (_cAliasTNY)->TNY_HRFIM ), '23:59', (_cAliasTNY)->TNY_HRFIM ), (_cAliasTNY)->TNY_CODABO, (_cAliasTNY)->TNY_QTDIAS, ' '  } ) 
                 DbSelectArea( _cAliasTNY )
                 ( _cAliasTNY )->( DbSkip( ) )
           EndDo
           DbSelectArea( _cAliasTNY ) 
           ( _cAliasTNY )->( DbCloSeArea( ) )
           //Ponto
           _cFilEmp := xFilial("SP9") 
           If _lPerAbe    //Periodo aberto 
              BeginSql ALIAS _cAliasSPH 
                       Column PC_DATA as DATE
                       Column PH_DATA as DATE
                       SELECT SPC.PC_DATA AS PH_DATA, SPC.PC_PD AS PH_PD, SP9.P9_DESC, SPC.PC_QUANTC AS PH_QUANTC, SPC.PC_ABONO AS PH_ABONO, SPC.PC_QTABONO AS PH_QTABONO  
                       FROM %Table:SPC% SPC 
                       LEFT JOIN %Table:SP9% SP9 ON SP9.P9_FILIAL = %exp:_cFilEmp% AND SP9.D_E_L_E_T_ = ' ' AND SP9.P9_CODIGO = SPC.PC_PD  
                       WHERE SPC.%notDel% AND 
                         SPC.PC_FILIAL  = %exp:_aAuxFun[ _nY][ 1]% AND 
                         SPC.PC_MAT     = %exp:_aAuxFun[ _nY][ 2]% AND 
                         SPC.PC_DATA    BETWEEN %exp:_dDatIni% AND %exp:_dDatFim% AND 
//                         SP9.P9_CODFOL IN('421', '423', '424', '490')
                         SP9.P9_CODFOL IN('421','423','424','490','005','009','010','011','012','017','018') 
              EndSql
           Else //Periodo Fechado
              BeginSql ALIAS _cAliasSPH
                       Column PH_DATA as DATE
                       SELECT SPH.PH_DATA, SPH.PH_PD, SP9.P9_DESC, SPH.PH_QUANTC, SPH.PH_ABONO, SPH.PH_QTABONO 
                       FROM %Table:SPH% SPH 
                       LEFT JOIN %Table:SP9% SP9 ON SP9.P9_FILIAL = %exp:_cFilEmp% AND SP9.D_E_L_E_T_ = ' ' AND SP9.P9_CODIGO = SPH.PH_PD 
                       WHERE SPH.%notDel% AND 
                         SPH.PH_FILIAL  = %exp:_aAuxFun[ _nY][ 1]% AND 
                         SPH.PH_MAT     = %exp:_aAuxFun[ _nY][ 2]% AND 
                         SPH.PH_DATA    BETWEEN  %exp:_dDatIni% AND %exp:_dDatFim% AND 
//                         SP9.P9_CODFOL IN('421', '423', '424', '490')
                         SP9.P9_CODFOL IN('421','423','424','490','005','009','010','011','012','017','018') 
              EndSql
           Endif
           DbSelectArea( _cAliasSPH ) 
           While !Eof() 
                 If aScan( _aAuxPON, { |x| x[1] + x[2] + DTOS( x[4] ) == _aAuxFun[ _nY][ 1] + _aAuxFun[ _nY][ 2] + DTOS( ( _cAliasSPH )->PH_DATA ) } ) == 0  
                    aAdd( _aAuxPON, { _aAuxFun[ _nY][ 1], _aAuxFun[ _nY][ 2], _aAuxFun[ _nY][ 3], ( _cAliasSPH )->PH_DATA, ( _cAliasSPH )->PH_PD, ( _cAliasSPH )->P9_DESC, ( _cAliasSPH )->PH_ABONO, ( _cAliasSPH )->PH_QTABONO, ' ', ( _cAliasSPH )->PH_QUANTC } ) 
                 Else 
                    _aAuxPON[ aScan( _aAuxPON, { |x| x[1] + x[2] + DTOS( x[4] ) == _aAuxFun[ _nY][ 1] + _aAuxFun[ _nY][ 2] + DTOS( ( _cAliasSPH )->PH_DATA ) } ) ][ 8] += ( _cAliasSPH )->PH_QTABONO 
                    _aAuxPON[ aScan( _aAuxPON, { |x| x[1] + x[2] + DTOS( x[4] ) == _aAuxFun[ _nY][ 1] + _aAuxFun[ _nY][ 2] + DTOS( ( _cAliasSPH )->PH_DATA ) } ) ][10] += ( _cAliasSPH )->PH_QUANTC 
                 Endif 
                 DbSelectArea( _cAliasSPH )
                 ( _cAliasSPH )->( DbSkip() ) 
           EndDo 
           DbSelectArea( _cAliasSPH ) 
           ( _cAliasSPH )->( DbCloseArea() ) 
       Next
       
       //**********************************************************************************************************************************//
       //Compatibilização entre Atestados e Ponto
       _oProcess:IncRegua1( "Compatibilizando informações..." ) //Ajusta escrita do processo principal
       For _nY := 1 To Len( _aAuxTNY )
           //Análise dos Atestados
           _cHoras := SubStr( ElapTime( _aAuxTNY[ _nY][ 5] + ":00", _aAuxTNY[ _nY][ 7] + ":00" ), 1, 5 )
           //Posiciono no Funcionario para verificar as horas dia
           _nPosFun := aScan( _aAuxFun, { |x| x[1] + x[2] == _aAuxTNY[ _nY][ 1] + _aAuxTNY[ _nY][ 2] } )
           //Analise das horas
           If _cHoras >= IntToHora( _aAuxFun[ _nPosFun][ 9] / 5 )
              _cHoras := IntToHora( _aAuxFun[ _nPosFun][ 9] / 5 )
           Endif
           If _aAuxTNY[ _nY][ 4] == _aAuxTNY[ _nY][ 6]
              //                  FILIAL              MATRICULA           FICHA MEDICA        DATA ATESTADO                      HORAS    CODIGO ABONO        DIAS ATESTADO       CODIGO ABONO  HORAS ABONO  DESCRICAO
              aAdd( _aAuxAUS, { _aAuxTNY[ _nY][ 1], _aAuxTNY[ _nY][ 2], _aAuxTNY[ _nY][ 3], _aAuxTNY[ _nY][ 4]                , _cHoras, _aAuxTNY[ _nY][ 8], _aAuxTNY[ _nY][ 9],           '', 0          , 'ATEST.' } )
           Else
              _nDiaAte := _aAuxTNY[ _nY][ 6] - _aAuxTNY[ _nY][ 4] + 1
              For _nZ := 1 To _nDiaAte
              //                      FILIAL              MATRICULA           FICHA MEDICA        DATA ATESTADO                  HORAS    CODIGO ABONO        DIAS ATESTADO       CODIGO ABONO  HORAS ABONO  DESCRICAO
                  aAdd( _aAuxAUS, { _aAuxTNY[ _nY][ 1], _aAuxTNY[ _nY][ 2], _aAuxTNY[ _nY][ 3], _aAuxTNY[ _nY][ 4] + (_nZ - 1), _cHoras, _aAuxTNY[ _nY][ 8], _aAuxTNY[ _nY][ 9],           '', 0          , 'ATEST.' } )
              Next
           Endif
           _aAuxTNY[ _nY][ 10] := 'X'
           //Análise do Ponto Eletrônico
           For _nX := 1 To Len( _aAuxPON )
               _nPosATE := aScan( _aAuxAUS, { |x| x[1] + x[2] + DTOS( x[4] ) == _aAuxPON[ _nX][1] + _aAuxPON[ _nX][2] + DTOS( _aAuxPON[ _nX][4] ) } )
               If _nPosATE > 0 .AND. Empty( _aAuxPON[ _nX][9] )
                  _aAuxAUS[ _nPosATE][8] := _aAuxPON[ _nX][7]
                  _aAuxAUS[ _nPosATE][9] += _aAuxPON[ _nX][8]
                  _aAuxPON[ _nX][9]      := "X"
               Endif
           Next
       Next 
       For _nY := 1 To Len( _aAuxPON )
           If Empty( _aAuxPON[ _nY][9] )
              //Analise dos Abonos
              _cAbono := SubSTr( _aAuxPON[_nY][ 6], 1, 6 ) 
              _nQdtFal := _aAuxPON[_nY][10]

              aAdd( _aAuxAUS, { _aAuxPON[ _nY][ 1], _aAuxPON[ _nY][ 2], _aAuxPON[ _nY][ 3], _aAuxPON[ _nY][ 4]            , "", "", 0, _aAuxPON[_nY][7], _nQdtFal, _cAbono } )
              _aAuxPON[ _nY][9] := "X"
           Endif
       Next 
       //Fim
       //**********************************************************************************************************************************//
       _oProcess:IncRegua1( "Montando impressão..." ) //Ajusta escrita do processo principal
       For _nY := 1 To Len( _aAuxFun )
           _cOcorr  := " "
           _nSomHr  := 0
           _nHrsDest:= 0
           _nAtras  := 0
           _nValCs  := 0
  
           _cTipoVl := Iif( _aAuxFun[ _nY][ 11] == '103', 'M', Iif( _aAuxFun[ _nY][ 11] <> '103' .and. _aAuxFun[ _nY][ 10] >= 220.00, 'N', 'T' ) ) //N=Normal; T=Telefonista; M=Menor Aprendiz
           _cTipBus = " "  
           For _nX := 1 To Len( _aAuxAUS )
               _cHora   := ""
//               _cTipBus := " "    // inibido por jose 30/09/2022
               If _aAuxAUS[ _nX][ 1] + _aAuxAUS[ _nX][ 2] == _aAuxFUN[ _nY][ 1] + _aAuxFUN[ _nY][ 2]
                  If _aAuxAUS[ _nX][ 9] >= horatoint( _aAuxAUS[ _nX][ 5] )
                     If Empty( _aAuxAUS[ _nX][ 8] ) //Sem Abono/Justificativa
                        _cHora  := fConvHor( _aAuxAUS[ _nX][ 9] )
                        _nAtras := SomaHoras( _nAtras, _cHora )
                        _cTipBus := 'D'  /// mudado por Jose 29/09/2022   antes era 'A'
                     Else //Analise abono Justificativa
                        _cHora := fConvHor( _aAuxAUS[ _nX][ 9] )
                        If Alltrim( _aAuxAUS[ _nX][ 8] ) $ Alltrim( MV_PAR07 ) // .and. _cTipoVl = 'M'  //Desconta da valor  // Acrecentado por Jose 30/09/2021
                            _cTipBus := 'D' //Desconta  // Acrecentado por Jose 30/09/2021
                        else  // Acrecentado por Jose 30/09/2021
                            If Alltrim( _aAuxAUS[ _nX][ 8] ) == "06"  .OR. Alltrim( _aAuxAUS[ _nX][ 8] ) == "08"  // Acrecentado por Jose 30/09/2022 .OR. Alltrim( _aAuxAUS[ _nX][ 8] ) == "08" 
                              _cTipBus := 'D' //Desconta  // Acrecentado por Jose 30/09/2021
                            else  // Acrecentado por Jose 30/09/2021
                               _cTipBus := 'A' //  mudado por jose 30/09/2022 antes era N   Não Desconta Só destaca   // Acrecentado por Jose 30/09/2021
                            Endif  // Acrecentado por Jose 30/09/2021
                        Endif
                        If Alltrim( _aAuxAUS[ _nX][ 8] ) $ Alltrim( MV_PAR08 ) //Valor Fixo
                           _cTipBus := 'F' //Fixo
                           _aAuxAUS[ _nX][ 10] := fBuscaAbo( _aAuxAUS[ _nX][ 8] )
                           _nHrsFixo+= _aAuxAUS[ _nX][ 9]
                        Endif
                        If Alltrim( _aAuxAUS[ _nX][ 8] ) $ Alltrim( MV_PAR09 ) //Destaca
                           _cTipBus := 'N' //Não Desconta, mas destaca
                           _aAuxAUS[ _nX][ 10] := fBuscaAbo( _aAuxAUS[ _nX][ 8] )
                           _nHrsDest := SomaHoras( _nHrsDest, _aAuxAUS[ _nX][ 9] )  //Modado por Jose 06/10/2022 antes era  _nHrsDest+= _aAuxAUS[ _nX][ 9]  
                        Endif
                     Endif
                  ElseIf _aAuxAUS[ _nX][ 9] <> 0
                     If Empty( _aAuxAUS[ _nX][ 8] ) //Sem Abono/Justificativa
                        _cHora := fConvHor( _aAuxAUS[ _nX][ 9] )
                        _nAtras := SomaHoras( _nAtras, _cHora )
                        _cTipBus := 'A'
                     Else //Analise abono Justificativa
                        _cHora := fConvHor( _aAuxAUS[ _nX][ 9] )
                        If Alltrim( _aAuxAUS[ _nX][ 8] ) $ Alltrim( MV_PAR07 ) // Inibido por Jose 30/09/2022--> .and. _cTipoVl = 'M'  //Desconta da valor // Acrecentado por Jose 30/09/2021
                           _cTipBus := 'A' // jose 30/09/2022 era D mudou para A    Desconta // Acrecentado por Jose 30/09/2021

                         else // Acrecentado por Jose 30/09/2021
                           If Alltrim( _aAuxAUS[ _nX][ 8] ) == "06" .OR. Alltrim( _aAuxAUS[ _nX][ 8] ) == "08"  // Acrecentado por Jose 30/09/2022 .OR. Alltrim( _aAuxAUS[ _nX][ 8] ) == "08" 
                              _cTipBus := 'A' // jose 30/09/2022 era D mudou para A Desconta  // Acrecentado por Jose 30/09/2021
                            else  // Acrecentado por Jose 30/09/2021
                              _cTipBus := 'D' //   anterado por jose 30/09/2022 ants era N Não Desconta Só destaca   // Acrecentado por Jose 30/09/2021
                           Endif // Acrecentado por Jose 30/09/2021
                        Endif
                        If Alltrim( _aAuxAUS[ _nX][ 8] ) $ Alltrim( MV_PAR08 ) //Valor Fixo
                           _cTipBus := 'F' //Fixo
                           _aAuxAUS[ _nX][ 10] := fBuscaAbo( _aAuxAUS[ _nX][ 8] )
                           _nHrsFixo+= _aAuxAUS[ _nX][ 9]
                        Endif
                        If Alltrim( _aAuxAUS[ _nX][ 8] ) $ Alltrim( MV_PAR09 ) //Destaca
                           _cTipBus := 'N' //Não Desconta, mas destaca
                           _aAuxAUS[ _nX][ 10] := fBuscaAbo( _aAuxAUS[ _nX][ 8] )
                            _nHrsDest := SomaHoras( _nHrsDest, _aAuxAUS[ _nX][ 9] )  //Modado por Jose 06/10/2022 antes era _nHrsDest+= _aAuxAUS[ _nX][ 9]
                        Endif
                     Endif
                  Else
                     _cHora   := _aAuxAUS[ _nX][ 5]
                     _cTipBus := 'A' 
                  Endif
                  If !Empty( _cTipBus )
                    If _cTipoVl == 'M'  // Acrescentado jose 30/09/2021 
                       _nSomHr  := SomaHoras( _nSomHr, _cHora )
                       _cOcorr  += _aAuxAUS[ _nX][ 10] + ' ' + SubStr( DTOC( _aAuxAUS[ _nX][ 4] ), 1, 5 ) + ' (' + _cHora + '); '
                       _aAuxFUN[ _nY][ 12] := Iif( _aAuxFUN[ _nY][ 12] $ 'F', _aAuxFUN[ _nY][ 12], _cTipBus )
                     Else  //  Acrescentado por Jose 30/09/2021
                      If _cTipBus == 'D' .OR. _aAuxAUS[ _nX][ 5] >= _vLIMITE//  Acrescentado por Jose 30/09/2021
                         _nSomHr  := SomaHoras( _nSomHr, _cHora )   //  Acrescentado por Jose 30/09/2021
                         _cOcorr  += _aAuxAUS[ _nX][ 10] + ' ' + SubStr( DTOC( _aAuxAUS[ _nX][ 4] ), 1, 5 ) + ' (' + _cHora + '); '   //  Acrescentado por Jose 30/09/2021
                         _aAuxFUN[ _nY][ 12] := Iif( _aAuxFUN[ _nY][ 12] $ 'F', _aAuxFUN[ _nY][ 12], _cTipBus )   //  Acrescentado por Jose 30/09/2021
                       Else //  Acrescentado por Jose 30/09/2021
                         If _cTipBus == "F" .and. (_aAuxAus[ _nx][ 8] == "17 " .OR. _aAuxAus[ _nx][ 8] == "01 " .OR. _aAuxAus[ _nx][ 8] == "02 ")  // Acrescentado por Jose 13/10/2021
                            _nSomHr  := SomaHoras( _nSomHr, _cHora )   //  Acrescentado por Jose 13/10/2021
                           _cOcorr  += _aAuxAUS[ _nX][ 10] + ' ' + SubStr( DTOC( _aAuxAUS[ _nX][ 4] ), 1, 5 ) + ' (' + _cHora + '); '   //  Acrescentado por Jose 13/10/2021
                           _aAuxFUN[ _nY][ 12] := Iif( _aAuxFUN[ _nY][ 12] $ 'F', _aAuxFUN[ _nY][ 12], _cTipBus )   //  Acrescentado por Jose 13/10/2021
                         Else  // Acrescentado por Jose  13/10/2021
                            _nSomHr  := SomaHoras( _nSomHr, _cHora )   //  Acrescentado por Jose 03/10/2022
                            _cOcorr  += _aAuxAUS[ _nX][ 10] + ' ' + SubStr( DTOC( _aAuxAUS[ _nX][ 4] ), 1, 5 ) + ' (' + _cHora + '); '   //  Acrescentado por Jose 30/09/2021
                            _aAuxFUN[ _nY][ 12] := Iif( _aAuxFUN[ _nY][ 12] $ 'F', _aAuxFUN[ _nY][ 12], _cTipBus )   //  Acrescentado por Jose 30/09/2021
                         EndIf // Acrescentado por jose   13/10/2021
                      Endif  //  Acrescentado por Jose 30/09/2021
                    Endif  //  Acrescentado por Jose 30/09/2021
                  Endif
               Endif
           Next
           //*************************************************************************************************
           //*** TRATAMENTO PARA AFASTAMENTO 
           /*8*/
           aAfastaPer := {}
           lAfastaPer := .F.
           lAfastaPer := fAfastaPer( @aAfastaPer, _dDatIni, _dDatFim, _aAuxFUN[ _nY][ 1], _aAuxFUN[ _nY][ 2] )
           If lAfastaPer
              If aAfastaPer[ 1][ 3] $ Alltrim( MV_PAR13 ) .And. _nAtras = 0 // Acrescentado por jose 03/10/2022  .And. _nAtras = 0  porque agora se tiver mais de um evento para desconto tem que considerar
                 _nSomHr := 999.99
//                 _cOcorr +=  Upper( Alltrim( Posicione("RCM", 1, xFilial("RCM") + aAfastaPer[ 1][ 3], "RCM_DESCRI" ) ) )
                 If Empty( aAfastaPer[ 1][ 2] ) //Se não tiver final de afastamento, considerar os dias não trabalhados do periodo;
                   _nSomHr := Round( ( _dDatFim - _dDatIni ) * ( _aAuxFUN[ _nY][ 9] / 5 ) , 2 )
                   _cOcorr += 'AFASTAMENTO(' + StrZero( ( _dDatFim - _dDatIni ), 2) + ' dia' + Iif( ( _dDatFim - _dDatIni ) <= 1, '', 's' ) +')'
                Else
                   If aAfastaPer[ 1][ 1] <= _dDatIni
                      _nSomHr := Round( ( ( aAfastaPer[ 1][ 2] - _dDatIni ) + 1 ) * ( _aAuxFUN[ _nY][ 9] / 5 ), 2 )
                      _cOcorr += 'AFASTAMENTO(' + StrZero( ( ( aAfastaPer[ 1][ 2] - _dDatIni ) + 1), 2) + ' dia' + Iif( ( _dDatFim - _dDatIni ) <= 1, '', 's' ) +')'
                   Else
                      _nSomHr := Round( ( ( aAfastaPer[ 1][ 2] - aAfastaPer[ 1][ 1] ) + 1 ) * ( _aAuxFUN[ _nY][ 9] / 5 ), 2 ) // por jose 30/09/2022 acrescenta dois pararenteses que estavam falta do e dava erro nos calculos
                      _cOcorr += 'AFASTAMENTO(' + StrZero( ( ( aAfastaPer[ 1][ 2] - aAfastaPer[ 1][ 1] ) + 1), 2) + ' dia' + Iif( ( ( aAfastaPer[ 1][ 2] - aAfastaPer[ 1][ 1] ) + 1) <= 1, '', 's' ) +')'
                   Endif
                 Endif
              Endif
           Endif /**/
           //*************************************************************************************************
           //Matriculas que não devem ter descontos
           If Alltrim( _aAuxFUN[ _nY][ 2] ) $ Alltrim( MV_PAR14 )
              _aAuxFUN[ _nY][ 12] := ' '
              _cTipoVl := Iif( _aAuxFun[ _nY][ 11] == '103', 'M', Iif( _aAuxFun[ _nY][ 11] <> '103' .and. _aAuxFun[ _nY][ 10] >= 220.00, 'N', 'T' ) ) //N=Normal; T=Telefonista; M=Menor Aprendiz
              _cOcorr   := ''
              _nSomHr   := 0
              _nAtras   := 0
           Endif
           //Regra para Valor Fixo
           If _aAuxFUN[ _nY][ 12] == 'F' //Valor Fixo
              If _nSomHr > _nHrsFixo //Validação para verificar se houver atestado além do motivo de consideração fixo, passa a descontar 100%
                 _cTipoVl := Iif( _aAuxFun[ _nY][ 11] == '103', 'M', Iif( _aAuxFun[ _nY][ 11] <> '103' .and. _aAuxFun[ _nY][ 10] >= 220.00, 'N', 'T' ) ) //N=Normal; T=Telefonista; M=Menor Aprendiz
              Else
                 If _nSomHr <= Val( StrTran( inttohora( _aAuxFUN[ _nY][ 9] / 5 ), ":", "." ) ) //Se as horas de valor fixo for menor que o dia, considera proporcional.
                    _cTipoVl := Iif( _aAuxFun[ _nY][ 11] == '103', 'M', Iif( _aAuxFun[ _nY][ 11] <> '103' .and. _aAuxFun[ _nY][ 10] >= 220.00, 'N', 'T' ) ) //N=Normal; T=Telefonista; M=Menor Aprendiz
                 Else
                    _cTipoVl := 'F'
                    _nSomHr  := 0
                 Endif
              Endif
           Endif
           //Regra para casos de destacar falta/atraso mas não desconta
           If (_aAuxFUN[ _nY][ 12] == 'N' .Or. _aAuxFUN[ _nY][ 12] == 'D')     //   jose 07/10/2022 .Or. _aAuxFUN[ _nY][ 12] == 'D'
              If _nSomHr = _nHrsDest //Verifica se não tem horas além do evento destacado. Em caso afirmativo passa a considerar a Soma das Horas
                 _nSomHr  := 0
//                 _cTipBus := "N"                    //   Jose 07/10/2022 Incluiu e Inibiou 
//                 _aAuxFUN[ _nY][ 12] := Iif( _aAuxFUN[ _nY][ 12] $ 'F', _aAuxFUN[ _nY][ 12], _cTipBus )     //  Jose 07/10/2022 Incluiu e Inibiou 
               Else
                If _nSomHr <= _nHrsDest 
                   _nSomHr := SubHoras( _nHrsDest, _nSomHr   ) 
//                   _cTipBus := "N"                  //  Jose 07/10/2022 Incluiu e Inibiou 
//                   _aAuxFUN[ _nY][ 12] := Iif( _aAuxFUN[ _nY][ 12] $ 'F', _aAuxFUN[ _nY][ 12], _cTipBus )    //  Jose 07/10/2022 Incluiu e Inibiou 
                Else
                   _nSomHr := SubHoras( _nSomHr  , _nHrsDest ) 
//                   _cTipBus := "N"                  //  Jose 07/10/2022 Incluiu e Inibiou 
//                   _aAuxFUN[ _nY][ 12] := Iif( _aAuxFUN[ _nY][ 12] $ 'F', _aAuxFUN[ _nY][ 12], _cTipBus )    //  Jose 07/10/2022 Incluiu e Inibiou 
                Endif
              Endif
           Endif // jose 06/10/2022
           //Regra para empresa 100101 (Hotel) - devido a convenção coletiva não existe desconto para atraso, logo zerar a variável _nAtras
           If cNumEmp $ '0110010101' 
              _nAtras := 0
           Endif
           //Regra para verificar atraso além de 30 minutos não recebe, para todas empresas menor hotel
           If _nAtras > Somahoras( 0, "0:30" ) .and. _cTipoVl = '?'  // Jose apartir do .and. foi acrescentado 29/09/2021
              _nValCs := 0
           Else
              //Para Marcações Automáticas - destaco na frente do nome
              If _aAuxFUN[ _nY][ 13] == mv_par10
                 _aAuxFUN[ _nY][ 4] := Alltrim( _aAuxFUN[ _nY][ 4] ) + " (Aut.)"
              Endif
              //Pesquisa tabela S052 em array as condições para pagamento do Vale Alimentação.

//-----------------------------------------------------------------------------------
              If _cTipoVl == 'M'   // Acescentado por jose Jose  29/09/2021
//-------------------------------------------------------------------------------------------
                 For _nZ := 1 To Len( _aTabVA )
                    If _aAuxFUN[ _nY][ 1] == _aTabVA[ _nZ][ 2] .and. _aTabVA[ _nZ][ 5] == _cTipoVl 
                       If _nSomHr >= _aTabVA[ _nZ][ 6]  .and. _nSomHr <= _aTabVA[ _nZ][ 7]
                          _nValCs := _aTabVA[ _nZ][ 8]
                       Endif
                    Endif
                 Next
// Acrescentado por Jose  29/9/2021 ----------------------------------------------------
               Else
                  _Contad := 0
                  For _nZ := 1 To Len( _aTabVA ) 
                    If (_aAuxFUN[ _nY][ 1] == _aTabVA[ _nZ][ 2] .and. _aTabVA[ _nZ][ 5] == _cTipoVl .And. _Contad = 0) // Acrescentado por jose 30/09/2022 . And. _Contad = 0 
                        If _nSomHr >= _aTabVA[ _nZ][ 6]  .and. _nSomHr <= _aTabVA[ _nZ][ 7]
                            _nValCs := _aTabVA[ _nZ][ 8]
                            _Contad = 1 // acrescentado por jose 30/09/2022
                        Endif
                    Else
                       IF (_aAuxFUN[ _nY][ 1] == _aTabVA[ _nZ][ 2] .and. _aTabVA[ _nZ][ 5] == "F" .And. ( _cTipBus = "F" .Or. _cTipBus = "D" ) .And. _Contad = 0 ) // _cTipBus <> "A" 06/10/2022 Acrescentado por jose 30/09/2022 . And. _Contad = 0 
                         If _nSomHr >= _aTabVA[ _nZ][ 6]  .and. _nSomHr <= _aTabVA[ _nZ][ 7] /// Inibid por jose  13/10/2021
                            _nValCs := _aTabVA[ _nZ][ 8]
                            _Contad = 1 // acrescentado por jose 30/09/2022
                         Endif
                       Endif
                    Endif
                 Next
              Endif   /// acrescentado por Jose 29/09/2021
//----------------------------------------------------------------------------------- 
           Endif
           //Adiciono informações a serem geradas nos relatórios.
             aAdd( _aDadRel, { _aAuxFUN[ _nY][ 1], _aAuxFUN[ _nY][ 2], _aAuxFUN[ _nY][ 4], _cOcorr, _nValCs, _aAuxFUN[ _nY][ 5], _aAuxFUN[ _nY][ 6], _aAuxFUN[ _nY][ 14] } )
       Next

       If Len( _aDadRel ) > 0
          _lRetImp := .T.
       Endif
Return

Static Function fBuscaAbo( _cCodAbo )
       Local _cDesAbo := ""
       DbSelectArea("SP6") 
       SP6->( DbSetOrder( 1 ) ) 
       If SP6->( DbSeek( xFilial("SP6") + _cCodAbo ) ) 
          _cDesAbo := SubStr( SP6->P6_DESC, 1, 10 ) 
       Endif 
Return _cDesAbo 

Static Function fConvHor( _nHorCon )
        Local _cHorRet := ""
       If Int( _nHorCon ) >= 1 
         _nHorCon := Min2Hrs( Int( _nHorCon ) * 60 + ( ( _nHorCon - Int( _nHorCon ) ) * 100 ) )
       Else
          _nHorCon := Min2Hrs( ( ( _nHorCon - Int( _nHorCon ) ) * 100 ) )
       Endif
       _cHorRet := StrZero( Int( _nHorCon ), 2 ) + ':' + StrZero( ( _nHorCon - Int( _nHorCon ) ) * 100, 2 ) 
Return _cHorRet

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
          u_zPutSX1( _cPerg   , "01"    , "Filial De ?          ", "MV_PAR01", "mv_ch1"  , "C"    ,  6        , 0         , "G"   , ""             , "XM0"   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "02" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código da Filial Final para Filtro dos dados." )
          u_zPutSX1( _cPerg   , "02"    , "Filial AtÚ ?         ", "MV_PAR02", "mv_ch2"  , "C"    ,  6        , 0         , "G"   , "NaoVazio"     , "XM0"   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "03" ) )
          aAdd( aHelpPor, "Informe o periodo, no formaro AAAAMM para geração das informações." )
          u_zPutSX1( _cPerg   , "03"    , "Periodo ? "           , "MV_PAR03", "mv_ch3"  , "C"    ,  6        , 0         , "G"   , ""             , "   "   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "04" ) )
          aAdd( aHelpPor, "Informe o diretório para gravação da planilha." )
          u_zPutSX1( _cPerg   , "04"    , "Diretorio ? "         , "MV_PAR04", "mv_ch4"  , "C"    ,  30       , 0         , "G"   , ""             , "   "   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "05" ) )
          aAdd( aHelpPor, "Informe a situação do funcionário.")
          u_zPutSX1( _cPerg   , "05"    , "Situação?        "     , "MV_PAR05", "mv_ch5"  , "C"    ,  5        , 0         , "G"   , "FSituacao()" , "   "   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
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
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "10" ) )
          aAdd( aHelpPor, "Regra de apontamento na qual não será considerado o desconto." )
          u_zPutSX1( _cPerg   , "10"    , "Regra que desconsidera descontos", "mv_para", "mv_chA"  , "C"    , 02        , 0         , "G"   , ""             , "SPA"   , ""        , ""          , ""               , ""      , ""      , ""   , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "11" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código do Funcionario inicial para Filtro dos dados." )
          u_zPutSX1( _cPerg   , "11"    , "Do Codigo ?          ", "MV_PAR11", "mv_chb"  , "C"    ,  6        , 0         , "G"   , ""             , "SRA"   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "12" ) )
          aAdd( aHelpPor, "Informe ou Selecione o Código do Funcionario Final para Filtro dos dados." )
          u_zPutSX1( _cPerg   , "12"    , "Até Codigo?          ", "MV_PAR12", "mv_chc"  , "C"    ,  6        , 0         , "G"   , ""             , "SRA"   , ""        , ""          , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "13" ) )
          aAdd( aHelpPor, "Motivos de Afastamentos que considera para desconto do valor. Utilizar ; para separação dos motivos." )
          u_zPutSX1( _cPerg   , "13"    , "Motivo Afastamento   ", "mv_par13", "mv_chd"  , "C"    , 90        , 0         , "G"   , ""             , "   "   , ""        , ""          , ""               , ""      , ""      , ""   , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "14" ) )
          aAdd( aHelpPor, "Matriculas que não devem considerar descontos de valores. Utilizar ; para separação dos motivos." )
          u_zPutSX1( _cPerg   , "14"    , "Matriculas           ", "mv_par14", "mv_che"  , "C"    , 90        , 0         , "G"   , ""             , "   "   , ""        , ""          , ""               , ""      , ""      , ""   , aHelpPor[1]  )
       Endif
       aHelpPor := {}

       RestArea( _aArea )
Return*/
