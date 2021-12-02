// #########################################################################################
// Projeto:
// Modulo :
// Fonte  : ZGPER09
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 19/08/19 | TOTVS             | Developer Studio | Gerado pelo Assistente de Código
// ---------+-------------------+-----------------------------------------------------------
#INCLUDE "RWMAKE.ch"
#INCLUDE "FILEIO.ch"
#INCLUDE 'APPEXCEL.ch'
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} novo
Leitura de Arquivo Texto

@author    TOTVS | Developer Studio - Gerado pelo Assistente de Código
@version   1.xx
@since     19/08/2019
/*/
//------------------------------------------------------------------------------------------
User Function ZGPER09()
     Local oDlgLeTxt
     //Local _cPerg    := "ZGPER09   "
     u_zcfga01( 'ZGPER09' ) //LGS#2021202 - Gravação de log de utilização da rotina
     //fValPerg( _cPerg )  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     //--< montagem da tela de processamento >---------------------------------------------------
     @ 200, 001 TO 380, 380 DIALOG oDlgLeTxt Title "Leitura de Arquivo Catraca - Refeitório"
     @ 002, 010 TO 065, 180

     //Coloque um pequeno descritivo com o objetivo deste processamento
     @ 010, 018 say "Este programa ira ler o conteudo de um arquivo texto, conforme"
     @ 018, 018 say "definidos pelo desenvolvedor ou usuário."
	 @ 068, 095 bmpButton TYPE 05 ACTION Pergunte( "ZGPER09", .t. )
     @ 068, 125 bmpButton TYPE 01 ACTION EVAL( { | | doIt( ), CLOSE( oDlgLeTxt ) } )
     @ 068, 155 bmpButton TYPE 02 ACTION CLOSE( oDlgLeTxt )
	
     //--< configuração de 'pergunte' e tecla de atalho >----------------------------------------
     Pergunte( "ZGPER09", .f. )
     //setKey( 123, { | | pergunte("ZGPER09", .t.) } ) // Acionamento dos parametros - tecla F12
     //@ 068, 018 say "[F12] Aciona a edição de parâmetros"
     Activate dialog oDlgLeTxt centered

     //SetKey( 123, nil) // Desativa a tecla F12 para acionamento dos parametros

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} doIt
Gerencia a execução do processo de exportação.

@author    TOTVS | Developer Studio - Gerado pelo Assistente de Código
@version   1.xx
@since     19/08/2019
/*/
//------------------------------------------------------------------------------------------
Static Function doIt()
       Local _nHdl
       Local _cArqTxt  := Alltrim( MV_PAR02 ) + '.TXT'

       //--< abre o arquivo de entrada >-----------------------------------------------------------
       _nHdl := fOpen( Alltrim( mv_par01 ) + _cArqTxt, FO_READ )
       If _nHdl == -1
          MsgAlert( "Não foi possível abrir o arquivo de entrada." + chr(13) + "Favor verificar parâmetros.", "Atenção." )
       Else
          //--< inicializa a regua de processamento >-------------------------------------------------
          Processa( { | | doProcess( _nHdl ) }, "Processando..." )
       Endif
       //--< encerramento >------------------------------------------------------------------------
       FCLOSE( _nHdl )
       _nHdl := Nil

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} doProcess
Processo de exportação.

@author    TOTVS | Developer Studio - Gerado pelo Assistente de Código
@version   1.xx
@since     19/08/2019
/*/
//------------------------------------------------------------------------------------------
//--< procedimentos >-----------------------------------------------------------------------
Static Function doProcess( _nHdl )
       //Variáveis
       Local _cBuffer
       Local _nTamLin   := 46
       Local _nTamFile  := 0
       Local _nRecLote  := 0
       Local _nLenLote  := 10
       Local _nBtLidos  := 0
       Local _cEOL      := chr(13) + chr(10)
       Local _aMatDad   := {}
       Local _cNomArq   := ""
       Local _nLin      := 0
       Local _nCol      := 0
       //Local _aTotCol   := 0
       Local _nPosDiv   := 0
       Local oExcel     := AppExcel():New()
       Local _aDiverg   := { }
       Local _aTOTGer   := { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
       Local _nTOTGer   := 0
       Local _nX, _nY
       Private oFont1   := AppExcFont():New( "Calibri", '14', '#000000')
       Private oFont2   := AppExcFont():New( "Calibri", '12', '#000000')
       Private oFont3   := AppExcFont():New( "Calibri", '12', '#000000')
       Private oFont4   := AppExcFont():New( "Calibri", '12', '#FF0000')

       //Recomenda-se o uso de procRegua usando 100 (representando 100%)
       _nLenLote := Int( fSeek( _nHdl, 0, FS_END ) / ( _nTamLin + Len( _cEOL ) ) )
       If _nLenLote > 100
          procRegua(100)
          _nLenLote := Int( _nLenLote * 0.05 )
       Else
          ProcRegua( _nLenLote )
       Endif
       _nRecLote := 0

       //inicialização de 'buffer' e primeira leitura
       _nTamLin  := _nTamLin + Len( _cEOL )
       _cBuffer  := Space( _nTamLin )
       _nTamFile := fSeek( _nHdl, 0, 2 )
       fSeek( _nHdl, 0, 0 )
       _nBtLidos := fRead(_nHdl, @_cBuffer, _nTamLin) // leitura da primeira linha do arquivo texto
       While _nBtLidos >= _nTamLin
             //Para melhor performance, recomenda-se o uso de incProc em lotes de registro
             If (_nRecLote > _nLenLote)
                IncProc( "Lendo dados do arquivo..." )
                _nRecLote := 0
             Endif
             //adiciona um registro no array
             _cFilial := ""
             _cMatric := ""
             _cNome   := ""
             _cCCusto := ""
             _cCCDesc := ""
             _cCConta := ""
             If SubStr( _cBuffer, 34, 2 ) == '09'
                _cFilial := 'TERCEIRO'
                _cMatric := Alltrim( Str( Val( SubStr( _cBuffer, 36, 5 ) ) ) )
                DbSelectArea( "SPY" )
                SPY->( DbSetOrder( 2 ) )
                If SPY->( DbSeek( xFilial( "SPY" ) + _cMatric ) )
                   DbSelectArea( "SPW" )
                   SPW->( DbSetOrder( 1 ) )
                   If SPW->( DbSeek( xFilial("SPW") + SPY->PY_VISITA ) )
                      _cNome   := Alltrim( SPW->PW_NOME ) + ' ' + Alltrim( SPW->PW_POSNOM1 )
                      _cCCusto := SPY->PY_NOMEMP
                   Else
                      _cNome   := "Não Encontrado"
                      _cCCusto := ""
                   Endif
                Else
                   _cNome   := "Não Encontrado"
                   _cCCusto := ""
                Endif 
             ElseIf SubStr( _cBuffer, 34, 2 ) == '60'
                    _cFilial := 'MESTRE'
                    _cMatric := Alltrim( SubStr( _cBuffer, 36, 5 ) )
                    _cNome   := 'CARTÃO MESTRE'
                    _cCCusto := ""
             Else
                _cFilial := '0101' + SubStr( _cBuffer, 34, 2 )
                _cMatric := Alltrim( Str( Val( SubStr( _cBuffer, 36, 5 ) ) ) )
                DbSelectArea( "SRA" )
                SRA->( DbSetOrder( 1 ) )
                If SRA->( DbSeek( _cFilial + _cMatric ) )
                   _cNome   := Alltrim( SRA->RA_NOME )
                   _cCCusto := SRA->RA_CC
                Else
                   _cNome   := "Não encontrado"
                   _cCCusto := ""
                Endif
             Endif
             If ! Empty( _cCCusto ) .and. _cCCusto != 'TERCEIRO'
                DbSelectArea( "CTT" )
                CTT->( DbSetOrder( 1 ) )
                If CTT->( DbSeek( xFilial( "CTT" ) + _cCCusto ) )
                   _cCCDesc := Alltrim( CTT->CTT_DESC01 )
                   _cCConta := Alltrim( CTT->CTT_NOME   )
                Endif
             Else
                _cCCDesc := ""
                _cCConta := ""
             Endif
             _dDatMar := SubStr( _cBuffer, 08, 10 )
             _dHorMar := SubStr( _cBuffer, 19, 08 )
             _nPosFun := aScan( _aMatDad, { |x| x[1]+x[2] == _cFilial + _cMatric } )
             If _nPosFun == 0
                aAdd( _aMatDad, { _cFilial ,; //Filial
                                  _cMatric ,; //Matricula
                                  _cNome   ,; //Nome
                                  _cCCusto ,; //Centro de Custo
                                  _cCCDesc ,; //Descrição Centro Custo
                                  _cCConta ,; //Codigo Raiz da Conta Contabil
                                  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } )
                _dPosRef := Val( SubStr( _cBuffer, 08, 02 ) )
                _aMatDad[ Len( _aMatDad ) ][ 6 + _dPosRef ] += 1
                _aTotGer[ _dPosRef ]                        += 1
             Else
                _dPosRef := Val( SubStr( _cBuffer, 08, 02 ) )
                _nSomRef := Iif( Alltrim( _cFilial ) == 'MESTRE', 1, Iif( ( _aMatDad[ _nPosFun ][ 6 + _dPosRef ] ) > 0, 0, 1 ) )
                _aMatDad[ _nPosFun ][ 6 + _dPosRef ] += _nSomRef
                _aTotGer[ _dPosRef ]                 += _nSomRef
             Endif
             _nPosDiv := aScan( _aDiverg, { |x| x[1] + x[2] + x[3] == _cFilial + _cMatric + _dDatMar } )
             If _nPosDiv == 0
                aAdd( _aDiverg, { _cFilial, _cMatric, _dDatMar, { _dHorMar } } )
             Else
                aAdd( _aDiverg[ _nPosDiv][ 4], _dHorMar )
             Endif
             //aAdd( _aDiverg, { _cFilial, _cMatric,  }
             _cBuffer  := Space( _nTamLin )
             _nBtLidos := FREAD( _nHdl, @_cBuffer, _nTamLin )
             _nRecLote += _nBtLidos
       EndDo
       aSort(_aMatDad, , , { |x, y| x[1]+x[2] < y[1]+y[2] } )
       
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

       _cNomArq := UPPER( "REFEICAO" + "_" + MV_PAR04 + "_" + Iif( mv_par05 == 1, 'P', 'S' ) + "_" + DTOS( dDataBase ) + "_" + StrTran( Time(), ":", "" ) + ".xml" )
       oExcel:SetDestPath( Alltrim( MV_PAR03 ) )
       oExcel:SetFileName( '\dirdoc\rh\' + _cNomArq )
       If ! ExistDir( MV_PAR03 )
          MakeDir( MV_PAR03 )
       Endif
       oExcel:SetSheetName( Alltrim( "REFEIÇÃO" ) )
       //***************************************************************************************************************************************/
       //Cabeçalho
       //***
       ProcRegua( Len( _aMatDad ) )
       IncProc( "Gerando arquivo de apuração..." )
       _nTOTGer := 0
       _nLin    := 1
       _nMerge  := Iif( mv_par05 == 1, 15, ( Val( SubStr( DTOS( LastDay( Stod( mv_par04 + '01' ) ) ), 7, 2 ) ) ) - 15 ) + 06 + 02
       oExcel:Merge( _nLin, 01, _nMerge, 01, 'APURAÇÃO DE REFEIÇÕES - ' + Iif( MV_PAR05 == 1, "Primeira ", "Segunda " ) + "quinzena de " + Alltrim( MesExtenso( Val( SubStr( MV_PAR04, 5, 2 ) ) ) )  + " de " + SubStr( MV_PAR04, 1, 4 ), oCelL01C01 )
       _nLin    += 2
       oExcel:Merge( _nLin, 01, _nMerge, 00, ''                                                         , oCelL02C01 )
       _nLin    += 1
       oExcel:Merge( _nLin, 01, 00, 01, ''                                                         , oCelL02C01 )
       oExcel:Merge( _nLin, 02, 00, 01, 'FILIAL'                                                   , oCelL03C01 )
       oExcel:Merge( _nLin, 03, 00, 01, 'MATR.'                                                    , oCelL03C01 )
       oExcel:Merge( _nLin, 04, 00, 01, 'NOME'                                                     , oCelL03C01 )
       oExcel:Merge( _nLin, 05, 00, 01, 'CENTRO C.'                                                , oCelL03C01 )
       oExcel:Merge( _nLin, 06, 00, 01, 'DESCRIÇÃO'                                                , oCelL03C01 )
       oExcel:Merge( _nLin, 07, 00, 01, 'CONTA CONT.'                                              , oCelL03C01 )
       _nCol := 07
       If mv_par05 == 1 //Primeira Quinzena
          For _nX := 1 To 15
              _nCol += 1
              oExcel:Merge( _nLin    , _nCol, 00, 00, Alltrim( DiaSemana( Stod( mv_par04 + StrZero( _nX, 2 ) ) ) ), oCelL03C01 )
              oExcel:Merge( _nLin + 1, _nCol, 00, 00, StrZero( _nX, 2 ) + '/' + SubStr( mv_par04, 5, 2 )          , oCelL03C01 )
          Next
       Else             //Segunda Quinzena
          For _nX := 16 To ( Val( SubStr( DTOS( LastDay( Stod( mv_par04 + '01' ) ) ), 7, 2 ) ) )
              _nCol += 1
              oExcel:Merge( _nLin    , _nCol, 00, 00, Alltrim( DiaSemana( Stod( mv_par04 + StrZero( _nX, 2 ) ) ) ), oCelL03C01 )
              oExcel:Merge( _nLin + 1, _nCol, 00, 00, StrZero( _nX, 2 ) + '/' + SubStr( mv_par04, 5, 2 )          , oCelL03C01 )
          Next
       Endif
       _nCol += 1
       oExcel:Merge( _nLin, _nCol, 00, 01, 'TOTAL'                                              , oCelL03C01 )
       _nCol += 1
       oExcel:Merge( _nLin, _nCol, 00, 01, ''                                                   , oCelL02C01 )
       //***************************************************************************************************************************************/

       //***************************************************************************************************************************************/
       //Impressão dos dados
       //***
       _nLin    += 2
       _nConFor := ( Val( SubStr( DTOS( LastDay( Stod( mv_par04 + '01' ) ) ), 7, 2 ) ) ) - 15
       For _nX := 1 To Len( _aMatDad )
           IncProc( "Gerando arquivo de apuração..." )
           _nTotFun := 0
           oExcel:Merge( _nLin, 01, 00, 00, ''                                                     , oCelL02C01 )
           oExcel:Merge( _nLin, 02, 00, 00, _aMatDad[ _nX][ 01]                                    , oCelL03C01 )
           oExcel:Merge( _nLin, 03, 00, 00, _aMatDad[ _nX][ 02]                                    , oCelL03C01 )
           oExcel:Merge( _nLin, 04, 00, 00, _aMatDad[ _nX][ 03]                                    , oCelL03C01 )
           oExcel:Merge( _nLin, 05, 00, 00, _aMatDad[ _nX][ 04]                                    , oCelL03C01 )
           oExcel:Merge( _nLin, 06, 00, 00, _aMatDad[ _nX][ 05]                                    , oCelL03C01 )
           oExcel:Merge( _nLin, 07, 00, 00, _aMatDad[ _nX][ 06]                                    , oCelL03C01 )
           _nColImp := 08
           If mv_par05 == 1 //Primeira Quinzena
              _nPosCol := 7
              For _nY := 1 To 15
                  oExcel:Merge( _nLin, _nColImp, 00, 00, _aMatDad[ _nX][ _nPosCol]                               , oCelL03C01 )
                  _nTotFun += _aMatDad[ _nX][ _nPosCol]
                  _nColImp += 1
                  _nPosCol += 1
              Next
           Else
              _nPosCol := 22
              For _nY := 1 To _nConFor
                  oExcel:Merge( _nLin, _nColImp, 00, 00, _aMatDad[ _nX][ _nPosCol]                               , oCelL03C01 )
                  _nTotFun += _aMatDad[ _nX][ _nPosCol]
                  _nColImp += 1
                  _nPosCol += 1
              Next
           Endif
           _nTOTGer += _nTotFun
           oExcel:Merge( _nLin, _nColImp, 00, 00, _nTotFun                               , oCelL03C01 )
           _nColImp += 1
           oExcel:Merge( _nLin, _nColImp, 00, 00, ''                                                     , oCelL02C01 )
           _nLin += 1
       Next
       oExcel:Merge( _nLin,    01, 00, 00, ''                                                    , oCelL02C01 )
       oExcel:Merge( _nLin,    02, 05, 00, 'TOTAL'                                               , oCelL03C01 )
       _nColImp := 07
       For _nX := 1 To Len( _aTOTGer )
           If mv_par05 == 1 //1º Quinzena
              If _nX <= 15
                 oExcel:Merge( _nLin, _nColImp + _nX, 00, 00, _aTOTGer[ _nX]                      , oCelL03C01 )
              ElseIf _nX == 16
                     oExcel:Merge( _nLin, _nColImp + _nX, 00, 00, _nTOTGer                        , oCelL03C01 )
                     oExcel:Merge( _nLin, _nColImp + _nX + 1, 00, 00, ''                          , oCelL02C01 )
              Endif
           Else
              If _nX >= 16 .and. _nX <= 15 + _nConFor //2º Quinzena
                 oExcel:Merge( _nLin, _nColImp + ( _nX - 15 ), 00, 00, _aTOTGer[ _nX]             , oCelL03C01 )
              ElseIf _nX == 32
                 oExcel:Merge( _nLin, _nColImp + ( _nX - 15 )    , 00, 00, _nTOTGer               , oCelL03C01 )
                 oExcel:Merge( _nLin, _nColImp + ( _nX - 15 ) + 1, 00, 00, ''                     , oCelL02C01 )
              Endif
           Endif
       Next
       //***************************************************************************************************************************************/
       _nLin := 1
       ProcRegua( Len( _aDiverg ) )
       IncProc( "Gerando arquivo de divergencias..." )
       oExcel:AddSheet( 'DIVERGÊNCIAS' )
       oExcel:Merge( _nLin, 01, 5, 01, 'DIVERGÊNCIAS', oCelL01C01 )
       _nLin += 2
       oExcel:Merge( _nLin, 01, 5, 00, ''                                                         , oCelL02C01 )
       _nLin += 1
       oExcel:Merge( _nLin, 01, 00, 00, ''                                                         , oCelL02C01 )
       oExcel:Merge( _nLin, 02, 00, 00, 'FILIAL'                                                   , oCelL03C01 )
       oExcel:Merge( _nLin, 03, 00, 00, 'MATR.'                                                    , oCelL03C01 )
       oExcel:Merge( _nLin, 04, 00, 00, 'DATA'                                                     , oCelL03C01 )
       oExcel:Merge( _nLin, 05, 00, 00, 'HORA'                                                     , oCelL03C01 )
       oExcel:Merge( _nLin, 06, 00, 00, ''                                                         , oCelL02C01 )
       _nLin += 1
       For _nX := 1 TO Len( _aDiverg )
           IncProc( "Gerando arquivo de divergencias..." )
           If Len( _aDiverg[ _nX][ 4] ) > 1
              oExcel:Merge( _nLin, 01, 00, 00, ''                                                     , oCelL02C01 )
              oExcel:Merge( _nLin, 02, 00, 00, _aDiverg[ _nX][ 01]                                    , oCelL03C01 )
              oExcel:Merge( _nLin, 03, 00, 00, _aDiverg[ _nX][ 02]                                    , oCelL03C01 )
              oExcel:Merge( _nLin, 04, 00, 00, _aDiverg[ _nX][ 03]                                    , oCelL03C01 )
              For _nY := 1 TO Len( _aDiverg[_nX][ 4] )
                  If _nY > 1
                     oExcel:Merge( _nLin, 01, 00, 00, ''                                                     , oCelL02C01 )
                     oExcel:Merge( _nLin, 02, 00, 00, ''                                                     , oCelL02C01 )
                     oExcel:Merge( _nLin, 03, 00, 00, ''                                                     , oCelL02C01 )
                     oExcel:Merge( _nLin, 04, 00, 00, ''                                                     , oCelL02C01 )
                     oExcel:Merge( _nLin, 05, 00, 00, _aDiverg[ _nX][ 04][ _nY]                              , oCelL03C01 )
                     oExcel:Merge( _nLin, 06, 00, 00, ''                                                     , oCelL02C01 )
                  Else
                     oExcel:Merge( _nLin, 05, 00, 00, _aDiverg[ _nX][ 04][ _nY]                              , oCelL03C01 )
                     oExcel:Merge( _nLin, 06, 00, 00, ''                                                     , oCelL02C01 )
                  Endif
                  _nLin += 1
              Next
           Endif
       Next
       oExcel:Make( .F. )
       oExcel:SetFileName( Alltrim( MV_PAR04 ) + _cNomArq )
       oExcel:Destroy()
Return
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*
Static Function fValPerg( _cPerg )
       Local _aArea   := GetArea()
       Local aHelpPor := {}

        //           X1_GRUPO , X1_ORDEM, X1_PERGUNT                   , X1_VAR01  , X1_VARIAVL, X1_TIPO, X1_TAMANHO, X1_DECIMAL, X1_GSC, X1_VALID       , X1_F3   , X1_PICTURE, X1_DEF01     , X1_DEF02         , X1_DEF03, X1_DEF04, X1_DEF05, X1_HELP
        //u_zPutSX1( _cPerg   , "01"    , "Codigo do Armazem    "      , "mv_par01", "mv_ch1"  , "C"    ,  2        , 0         , "G"   , ""             , "NNR"   , ""        , ""           , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "01" ) )
          aAdd( aHelpPor, "Informe o diretório do arquivo de entrada." )
          u_zPutSX1( _cPerg   , "01"    , "Diretorio arq. para leitura", "MV_PAR01", "mv_ch1"  , "C"    ,  90       , 0         , "G"   , ""             , "   "   , ""        , ""           , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "02" ) )
          aAdd( aHelpPor, "Informe o nome do arquivo completo com extenção." )
          u_zPutSX1( _cPerg   , "02"    , "Nome do arquivo para leitura", "MV_PAR02", "mv_ch2"  , "C"    ,  20       , 0         , "G"   , ""             , "   "   , ""        , ""           , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "03" ) )
          aAdd( aHelpPor, "Informe o diretório do arquivo de saida." )
          u_zPutSX1( _cPerg   , "03"    , "Diretorio arq. para gravação", "MV_PAR03", "mv_ch3"  , "C"    ,  90       , 0         , "G"   , ""             , "   "   , ""        , ""           , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "04" ) )
          aAdd( aHelpPor, "Informe o periodo, no formaro AAAAMM para geração das informações." )
          u_zPutSX1( _cPerg   , "04"    , "Periodo ? "                  , "MV_PAR04", "mv_ch3"  , "C"    ,  6        , 0         , "G"   , ""             , "   "   , ""        , ""           , ""               , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}
       DbSelectArea("SX1")
       SX1->( DbSetOrder( 1 ) )
       If !SX1->(MsSeek( _cPerg + "05" ) )
          aAdd( aHelpPor, "Informe qual quinzena o arquivo de leitura pertence." )
          u_zPutSX1( _cPerg   , "05"    , "Quinzena? "                  , "MV_PAR05", "mv_ch5"  , "N"    ,  1        , 0         , "C"   , ""             , "   "   , ""        , "1º Quinzena", "2º Quinzena"    , ""      , ""      , ""      , aHelpPor[1]  )
       Endif
       aHelpPor := {}

       RestArea( _aArea )
Return*/
//--< fim de arquivo >----------------------------------------------------------------------
