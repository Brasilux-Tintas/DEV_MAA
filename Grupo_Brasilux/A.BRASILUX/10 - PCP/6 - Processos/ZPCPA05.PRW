#include 'totvs.ch'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} ZPCPA05
Painel de analise de apontamento de ordens de produção.
@type function
@version  P12.1.25
@author Luís Gustavo de Souza
@since 20/01/2021
/*/
User Function ZPCPA05()
     Local _cPergunta  := 'ZPCPA05'
     Local _cTitulo    := 'Analise de Apontamentos'
     Local _cPrograma  := 'ZPCPA05'
     Local _nOperation := Iif( dDataBase <= CTOD('31/01/2021'), MODEL_OPERATION_UPDATE, MODEL_OPERATION_VIEW )
     Local _aButtons   := { { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .T., 'Confirmar' }, { .T., 'Cancelar' }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil } }
     Private oTable1
     Private oTable2
     Private _aDiverg  := {}

     If Pergunte( _cPergunta, .T. )
        nOpc := FWExecView( _cTitulo, _cPrograma, _nOperation, /*oDlg*/, { || .t. }, /*bOk*/, 0 /*nPercReducao*/, _aButtons /*aEnableButtons*/ )
     Endif
     If Select( 'TMPCAB' ) > 0
        DbSelectArea( 'TMPCAB' )
        ( 'TMPCAB' )->( DbCloseArea( ) )
     Endif     
     If Select( 'TMPORD' ) > 0
        DbSelectArea( 'TMPORD' )
        ( 'TMPORD' )->( DbCloseArea( ) )
     Endif
Return

/*/{Protheus.doc} MODELDEF
Modelo da análise de produção
@type function
@version  P12.1.25
@author gustavosouza
@since 20/01/2021
@return Object, Retorno do modelo do formulário
/*/
Static Function MODELDEF()
       Local oModel as Object
       Local oStr1  as Array
       Local oStr2  as Array

       oStr1 := fMontaCab( 1 )
       oStr2 := fMontaCab( 3 )

       oModel := FWFormModel():New( "ANALISEPRD", , , { | oModel | fGrava() } , { | oModel | fCancel() } )

       oModel:SetDescription( 'Analise dos apontamentos de produção' )
       oModel:AddFields( 'PRDPARAM', , oStr1, , , { | oModel | fMontaDad( 1, oModel ) } )
       oModel:getModel( 'PRDPARAM' ):SetDescription( 'Analise dos apontamentos - Parâmetros' )
       oModel:SetPrimaryKey( {} )

       //oModel:AddGrid( 'GRIDORD', 'PRDPARAM', oStr2, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, MsgRun( 'Aguarde a busca de informações', 'Aguarde...', { | oModel | fMontaDad( 2, oModel ) } ) )
       oModel:AddGrid( 'GRIDORD', 'PRDPARAM', oStr2, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, { | oModel | fMontaDad( 2, oModel ) } )
       oModel:getModel( 'GRIDORD' ):SetDescription( 'Ordens de Produção' )
       oModel:getModel( 'GRIDORD' ):SetNoInsertLine( .T. )
       oModel:getModel( 'GRIDORD' ):SetNoDeleteLine( .T. )
       oModel:getModel( 'GRIDORD' ):SetUseOldGrid( .T. )
       oModel:SetOptional('GRIDORD' , .T. )
       If dDataBase <= CTOD('31/01/2021')
          oModel:lModify := .t.
       Endif
Return oModel

/*/{Protheus.doc} VIEWDEF
View da anális de produção
@type function
@version P12.1.25
@author Luís Gustavo de Souza
@since 20/01/2021
@return Object, Retorna o objeto view
/*/
Static Function VIEWDEF()
       Local oView  as Object
       Local oModel as Object
       Local oStr1  as Object
       Local oStr2  as Object

       oModel := ModelDef()

       oStr1 := fMontaCab( 2 )
       oStr2 := fMontaCab( 4 )

       oView := FWFormView():New()
       oView:SetModel( oModel )

       oView:AddField( 'FORM_CAB', oStr1, 'PRDPARAM' )
       oView:AddGrid( 'FORM_ORD' , oStr2, 'GRIDORD' )

       oView:addOtherObject( 'BTLEGENDA', { |oPanel| fButLeg( oPanel ) }, { || } )

       oView:CreateHorizontalBox( 'BOX_FORM_CAB', 15 )
       oView:CreateHorizontalBox( 'BOX_FORM_ORD', 70 )

       oView:SetOwnerView( 'FORM_CAB', 'BOX_FORM_CAB' )
       oView:SetOwnerView( 'FORM_ORD', 'BOX_FORM_ORD' )

       oView:EnableTitleView( 'FORM_CAB', 'Parâmetros da Consulta' )
       oView:EnableTitleView( 'FORM_ORD', 'Ordens de produção'     )

       oView:SetDescription( 'Consulta Apontamentos de Produção' )

       oView:SetCloseOnOk( { || .T. } )

Return oView

/*/{Protheus.doc} fGrava
Gravação das informações
@type function
@version P12.1.25  
@author gustavosouza
@since 20/01/2021
@return Logical, Retorno da gravação.
/*/
Static Function fGrava()
       Local _lRet     := .T.
       Local _nX, _nY
       Local _aGeraGGF := {}
       If MV_PAR03 == 2
          For _nX := 1 To Len( _aDiverg )
              /*** GRAVAÇÃO DO GGF ***/
              If _aDiverg[_nX][1] == 'GGF'
                 DbSelectArea('SC2')
                 SC2->( DbSetOrder( 1 ) )
                 If SC2->( DbSeek( xFilial('SC2') + _aDiverg[_nX][4] ) )
                    If _aDiverg[_nX][3] == 'E'
                       DbSelectArea('SG1')
                       SG1->( DbSetOrder(1) )
                       If SG1->( DbSeek( xFilial('SG1') + SC2->C2_PRODUTO ) )
                          _aGeraGGF := {}
                          While !Eof() .and. SG1->G1_COD == SC2->C2_PRODUTO
                                If SubStr( SG1->G1_COMP, 1, 3 ) == 'GGF'
                                   aAdd( _aGeraGGF, { SG1->G1_COMP, SG1->G1_TRT, SG1->G1_QUANT, '', '', '', 0 } )
                                Endif
                                SG1->( DbSkip() )
                          EndDo
                          If Len( _aGeraGGF ) > 0
                             DbSelectArea("SD3")
                             SD3->( DbSetOrder( 1 ) )
                             If SD3->( DbSeek( xFilial("SD3") + SC2->C2_OP ) )
                                While !Eof() .and. Alltrim( SD3->D3_OP ) == Alltrim( SC2->C2_OP )
                                      _nPos  := aScan( _aGeraGGF, { |x| x[1] == SD3->D3_COD } )
                                      _dData := SD3->D3_EMISSAO
                                      If _nPos <> 0 .and. SD3->D3_ESTORNO <> 'S'
                                         _aGeraGGF[ _nPos ][4] := SD3->D3_COD
                                         _aGeraGGF[ _nPos ][5] := SD3->D3_TRT
                                         _aGeraGGF[ _nPos ][6] := SD3->D3_QUANT
                                         _aGeraGGF[ _nPos ][7] := SD3->( RECNO() )
                                      Endif
                                      SD3->( DbSkip( ) )
                                EndDo
                             Endif
                          Endif
                       Endif
                    Else
                       MessageBox( 'ZPCPA05-GGF-01 - Ajustar programa para correção de divergências.', 'Divergencia', 64 )
                    Endif
                 Endif
                 //Gera GGF na SD3
                 For _nY := 1 To Len( _aGeraGGF )
                     If Empty( _aGeraGGF[_nY][4] )
                        RecLock( 'SD3', .T. )
                           SD3->D3_FILIAL  := xFilial("SD3")
                           SD3->D3_TM      := '997'
                           SD3->D3_COD     := _aGeraGGF[_nY][1]
                           SD3->D3_UM      := 'HR'
                           SD3->D3_QUANT   := Round( _aGeraGGF[_nY][3] * SC2->C2_QUJE, 3 )
                           SD3->D3_CF      := 'RE0'
                           SD3->D3_OP      := SC2->C2_OP
                           SD3->D3_LOCAL   := '05'
                           SD3->D3_DOC     :=  SC2->C2_NUM + '-G'
                           SD3->D3_NUMSEQ  := PROXNUM()
                           SD3->D3_EMISSAO := _dData
                           SD3->D3_TIPO    := 'MO'
                           SD3->D3_OBSERVA := 'ZPCPA05-GGF'
                           SD3->D3_USUARIO := 'Administrador'
                           SD3->D3_TRT     := _aGeraGGF[_nY][2]
                        MsUnLock()
                     Else
                        DbSelectArea('SD3')
                        SD3->( DbGoTo( _aGeraGGF[_nY][7] ) )
                        If Round( _aGeraGGF[_nY][3] * SC2->C2_QUJE, 3 ) <> SD3->D3_QUANT
                           RecLock( 'SD3', .f. )
                              SD3->D3_QUANT := Round( _aGeraGGF[_nY][3] * SC2->C2_QUJE, 3 )
                           MsUnLock()
                        Endif
                     Endif
                 Next
              ElseIf _aDiverg[_nX][1] == 'MOD'
                     _aAuxMOV := _aDiverg[_nX][6]
                     For _nY := 1 To Len( _aAuxMOV )
                         DbSelectArea("SB1")
                         SB1->( DbSetOrder( 1 ) )
                         SB1->( DbSeek( xFilial('SB1') + _aAuxMov[_nY][3] ) )
                         If SB1->B1_TIPO <> 'PA'
                            If Empty( _aAuxMOV[ _nY ][ 12 ] ) //Ajustes para divergências entre apontamento e novo roteiro
                               _cOperacao := Iif( _aAuxMOV[ _nY ][ 5 ] == '01', '10', Iif( _aAuxMOV[ _nY ][ 5 ] == '02', '20', Iif( _aAuxMOV[ _nY ][ 5 ] == '03', '30', Iif( _aAuxMOV[ _nY ][ 5 ] == '04', '40', Iif( _aAuxMOV[ _nY ][ 5 ] == '05', '50', _aAuxMOV[ _nY ][ 5 ] ) ) ) ) )
                               DbSelectArea('SG2')
                               SG2->( DbSetOrder( 1 ) )
                               If SG2->( DbSeek( xFilial('SG2') + _aAuxMOV[ _nY ][ 3 ] + _aAuxMOV[ _nY ][ 2 ] + _cOperacao ) )
                                  DbSelectArea('SH1')
                                  SH1->( DbSetOrder( 1 ) )
                                  SH1->( DbSeek( xFilial("SH1") + SG2->G2_RECURSO ) )
                                  DbSelectArea("SD3")
                                  SD3->( DbGoTo( _aAuxMOV[ _nY ][ 22 ] ) )
                                  RecLock( 'SD3', .f. )
                                     SD3->D3_COD := SubStr( 'MO' + SH1->H1_CCUSTO, 1, 15 )
                                  SD3->( MsUnLock() )
                                  DbSelectArea("SH6")
                                  SH6->( DbGoTo( _aAuxMOV[ _nY ][ 23 ] ) )
                                  RecLock( 'SH6', .f. )
                                     SH6->H6_OPERAC  := _cOperacao
                                     SH6->H6_RECURSO := SG2->G2_RECURSO
                                  SH6->( MsUnLock() )
                               Else
                                  If !SG2->( DbSeek( xFilial('SG2') + _aAuxMOV[ _nY ][ 3 ] + _aAuxMOV[ _nY ][ 2 ] + _aAuxMOV[ _nY ][ 5 ] ) )
                                     DbSelectArea("SD3")
                                     SD3->( DbGoTo( _aAuxMOV[ _nY ][ 22 ] ) )
                                     RecLock( 'SD3', .f. )
                                        SD3->( DbDelete() )
                                     SD3->( MsUnLock() )
                                     DbSelectArea("SH6")
                                     SH6->( DbGoTo( _aAuxMOV[ _nY ][ 23 ] ) )
                                     RecLock( 'SH6', .f. )
                                        SH6->( DbDelete() )
                                     SH6->( MsUnLock() )
                                  Else
                                     MessageBox( 'ZPCPA05-MOD-01 - Ajustar programa para correção de divergências.', 'Divergencia', 64 )
                                  Endif
                               Endif
                            ElseIf Substr( _aAuxMOV[ _nY ][ 19 ], 1, 3 ) <> 'MO6' //Codigo de mão de obra diferente
                                   If _aAuxMOV[ _nY ][ 17 ] <> '1'
                                      SD3->( DbGoTo( _aAuxMOV[ _nY ][ 22 ] ) )
                                      RecLock( 'SD3', .f. )
                                         SD3->D3_COD := SubStr( 'MO' + _aAuxMOV[ _nY ][ 18 ], 1, 15 )
                                      SD3->( MsUnLock() )
                                      DbSelectArea("SH6")
                                      SH6->( DbGoTo( _aAuxMOV[ _nY ][ 23 ] ) )
                                      RecLock( 'SH6', .f. )
                                         SH6->H6_OPERAC  := _aAuxMOV[ _nY ][ 14 ]
                                         SH6->H6_RECURSO := _aAuxMOV[ _nY ][ 15 ]
                                      SH6->( MsUnLock() )
                                   Else
                                      MessageBox( 'Existem Recursos Bloqueados.', 'Atenção', 64 )
                                   Endif
                            ElseIf _aAuxMOV[ _nY ][ 9 ] <> _aAuxMOV[ _nY ][ 16 ]
                                   DbSelectArea("SH6")
                                   SH6->( DbGoTo( _aAuxMOV[ _nY ][ 23 ] ) )
                                   RecLock( 'SH6', .f. )
                                      SH6->H6_RECURSO := _aAuxMOV[ _nY ][ 6 ]
                                   SH6->( MsUnLock() )
                            Endif
                         Else
                            DbSelectArea('SH1')
                            SH1->( DbSetOrder( 1 ) )
                            SH1->( DbSeek( xFilial("SH1") + _aAuxMOV[ _nY ][ 6 ] ) )
                            DbSelectArea("SD3")
                            SD3->( DbGoTo( _aAuxMOV[ _nY ][ 22 ] ) )
                            RecLock( 'SD3', .f. )
                               SD3->D3_COD := SubStr( 'MO' + SH1->H1_CCUSTO, 1, 15 )
                            SD3->( MsUnLock() )
                            DbSelectArea("SH6")
                            SH6->( DbGoTo( _aAuxMOV[ _nY ][ 23 ] ) )
                            RecLock( 'SH6', .f. )
                               SH6->H6_RECURSO := _aAuxMOV[ _nY ][ 6 ]
                            SH6->( MsUnLock() )
                         Endif
                     Next
              Endif
          Next
       Endif
Return _lRet

/*/{Protheus.doc} fCancel
Tratamento do cancelamento.
@type function
@version P12.1.25
@author Luís Gustavo de Souza
@since 20/01/2021
/*/
Static Function fCancel()

Return .t.

/*/{Protheus.doc} fMontaCab
Montagem das estruturas das tabelas a serem utilizadas
@type function
@version P12.1.25
@author Luís Gustavo de Souza
@since 20/01/2021
@param _nOpcao, Numeric, Parâmetro com a opção da estrutura a ser criada.
@return Object, Retorna o objeto com as estruturas das tabelas.
/*/
Static Function fMontaCab( _nOpcao )
       Local oStruct as Object
       Local aCampos as Array

       If _nOpcao == 1
          oStruct := FWFormModelStruct():New()
          aCampos := {}
          aAdd( aCampos, { 'DATADE' , 'D', 8, 0 } )
          aAdd( aCampos, { 'DATAATE', 'D', 8, 0 } )
          aAdd( aCampos, { 'TIPOCON', 'C', 1, 0 } )
          fMontaTMP( aCampos, "TMPCAB", oTable1 )
          oStruct:AddField( 'Data de' , 'Data de' , 'DATADE' , 'D', 8, 0, , { || .T. } )
          oStruct:AddField( 'Data até', 'Data até', 'DATAATE', 'D', 8, 0, , { || .T. } )
          oStruct:AddField( 'Consulta', 'Consulta', 'TIPOCON', 'N', 1, 0, , { || .T. }, { 'Ordem de produção', 'Produção' } )
       ElseIf _nOpcao == 2
              oStruct := FWFormViewStruct():New()
              oStruct:AddField( 'DATADE' , '01', 'Data de'     , 'Data de'     , , 'D', , , , .F.                                            )
              oStruct:AddField( 'DATAATE', '02', 'Data ate'    , 'Data ate'    , , 'D', , , , .F.                                            )
              oStruct:AddField( 'TIPOCON', '03', 'Consulta por', 'Consulta por', , 'C', , , , .F., , , { '1=Ordem de produção', 'Produção' } )
       ElseIf _nOpcao == 3
              oStruct := FWFormModelStruct():New()
              aCampos := {}
              aAdd( aCampos, { 'LEGEN01'  , 'C',  2, 0 } ) //Legenda 01 - Produção/Manutenção
              aAdd( aCampos, { 'LEGEN02'  , 'C',  2, 0 } ) //Legenda 02 - GGF
              aAdd( aCampos, { 'LEGEN03'  , 'C',  2, 0 } ) //Legenda 03 - MOD
              aAdd( aCampos, { 'LEGEN04'  , 'C',  2, 0 } ) //Legenda 04 - Apontamento/Manual
              aAdd( aCampos, { 'LEGEN05'  , 'C',  2, 0 } ) //Legenda 05 - Requisição OK/Não
              aAdd( aCampos, { 'ORDEM'    , 'C', 14, 0 } ) //Ordem de Produção
              aAdd( aCampos, { 'LOTE'     , 'C',  6, 0 } ) //Lote
              aAdd( aCampos, { 'DTEMIS'   , 'D',  8, 0 } ) //Lote
              aAdd( aCampos, { 'PRODUTO'  , 'C', 15, 0 } ) //Produto
              aAdd( aCampos, { 'DESCRICAO', 'C', 40, 0 } ) //Descrição
              aAdd( aCampos, { 'UNIDADE'  , 'C',  2, 0 } ) //Unidade de Medida
              aAdd( aCampos, { 'TIPO'     , 'C',  2, 0 } ) //Tipo de produto
              aAdd( aCampos, { 'ORIGEM'   , 'C', 10, 0 } ) //Origem do Lançamento
              aAdd( aCampos, { 'REC_NO'   , 'N', 20, 0 } ) //
              aAdd( aCampos, { 'QTDORIOP' , 'N', 16, 4 } ) //Quantidade da ordem de producao
              aAdd( aCampos, { 'QTDJAENT' , 'N', 16, 4 } ) //Quantidade ja entregue
              aAdd( aCampos, { 'ROTEIRO'  , 'C',  2, 0 } ) //Roteiro de produção
              aAdd( aCampos, { 'LOCPAD'   , 'C',  2, 0 } ) //Local do Produto
              aAdd( aCampos, { 'STATUS'   , 'C', 50, 0 } ) //Status do roteiro
              fMontaTMP( aCampos, "TMPORD", oTable2 )
              oStruct:AddField( 'TP', 'TP' , 'LEGEN01'  , 'C',  2, 0,       , { || .T. } )
              oStruct:AddField( 'TP', 'GGF', 'LEGEN02'  , 'C',  2, 0,       , { || .T. } )
              oStruct:AddField( 'TP', 'MOD', 'LEGEN03'  , 'C',  2, 0,       , { || .T. } )
              oStruct:AddField( 'TP', 'APT', 'LEGEN04'  , 'C',  2, 0,       , { || .T. } )
              oStruct:AddField( 'TP', 'REQ', 'LEGEN05'  , 'C',  2, 0,       , { || .T. } )
              oStruct:AddField( ''  , ''   , 'ORDEM'    , 'C', 14, 0,       , { || .T. } )
              oStruct:AddField( ''  , ''   , 'LOTE'     , 'C',  6, 0,       , { || .T. } )
              oStruct:AddField( ''  , ''   , 'DTEMIS'   , 'D',  8, 0,       , { || .T. } )
              oStruct:AddField( ''  , ''   , 'PRODUTO'  , 'C', 15, 0,       , { || .T. } )
              oStruct:AddField( ''  , ''   , 'DESCRICAO', 'C', 40, 0,       , { || .T. } )
              oStruct:AddField( ''  , ''   , 'UNIDADE'  , 'C',  2, 0,       , { || .T. } )
              oStruct:AddField( ''  , ''   , 'TIPO'     , 'C',  2, 0,       , { || .T. } )
              oStruct:AddField( ''  , ''   , 'ORIGEM'   , 'C', 10, 0,       , { || .T. } )
              oStruct:AddField( ''  , ''   , 'REC_NO'   , 'N', 20, 0,       , { || .T. } )
              oStruct:AddField( ''  , ''   , 'QTDORIOP' , 'N', 16, 4,       , { || .T. } )
              oStruct:AddField( ''  , ''   , 'QTDJAENT' , 'N', 16, 4,       , { || .T. } )
              oStruct:AddField( ''  , ''   , 'ROTEIRO'  , 'C',  2, 0,       , { || .T. } )
              oStruct:AddField( ''  , ''   , 'LOCAL'    , 'C',  2, 0,       , { || .T. } )
              oStruct:AddField( ''  , ''   , 'STATUS'   , 'C', 50, 0,       , { || .T. } )
       ElseIf _nOpcao == 4
              oStruct := FWFormViewStruct():New()
              oStruct:AddField( 'LEGEN01'  , '01', 'TP'       , ''         , , 'C', "@BMP", , , .F. )
              If mv_par03 == 1
                 oStruct:AddField( 'LEGEN02'  , '02', 'EST'      , 'GGF na Estrutura'       , , 'C', "@BMP", , , .F. )
                 oStruct:AddField( 'LEGEN03'  , '03', 'EMP'      , 'GGF no Empenho'         , , 'C', "@BMP", , , .F. )
              Else
                 oStruct:AddField( 'LEGEN02'  , '02', 'GGF'      , 'GGF no apontamento'     , , 'C', "@BMP", , , .F. )
                 oStruct:AddField( 'LEGEN03'  , '03', 'MOD'      , 'Mão Obra no apontamento', , 'C', "@BMP", , , .F. )
                 //oStruct:AddField( 'LEGEN04'  , '04', 'APT'      , ''         , , 'C', "@BMP", , , .F. )
                 //oStruct:AddField( 'LEGEN05'  , '05', 'REQ'      , ''         , , 'C', "@BMP", , , .F. )
              Endif
              oStruct:AddField( 'ORDEM'    , '06', 'Ordem'    , 'Ordem'    , , 'C',       , , , .F. )
              oStruct:AddField( 'LOTE'     , '07', 'Lote'     , 'Lote'     , , 'C',       , , , .F. )
              oStruct:AddField( 'DTEMIS'   , '08', 'Data'     , 'Data'     , , 'D',       , , , .F. )
              oStruct:AddField( 'PRODUTO'  , '09', 'Produto'  , 'Produto'  , , 'C',       , , , .F. )
              oStruct:AddField( 'DESCRICAO', '10', 'Descricao', 'Descricao', , 'C',       , , , .F. )
              oStruct:AddField( 'UNIDADE'  , '11', 'Unidade'  , 'Unidade'  , , 'C',       , , , .F. )
              oStruct:AddField( 'TIPO'     , '12', 'Tipo'     , 'Tipo'     , , 'C',       , , , .F. )
              oStruct:AddField( 'LOCAL'    , '13', 'Local'    , 'Local'    , , 'C',       , , , .F. )
              oStruct:AddField( 'STATUS'   , '14', 'Status'   , 'Status'   , , 'C',       , , , .F. )
       Endif
Return oStruct

/*/{Protheus.doc} fMontaDad
Monta os dados para serem apresentados em tela
@type function
@version P12.1.25
@author Luís Gustavo de Souza
@since 20/01/2021
@param _nOpcao, Numeric, Opção dos dados que será montada.
@param _oModel, Object, Modelo do objeto que receberá os dados
@return Array, Retorna array com os dados a serem apresentados.
/*/
Static Function fMontaDad( _nOpcao, _oModel )
       Local _aRet as Array
       Local _aAux as Array
       Local _cAliasTMP := GetNextAlias()
       Local _nContador := 0
       Local _cWhere    := '%'
       Local _cStatGGF  := 'BR_BRANCO'
       Local _aStatGGF  := {}
       Local _cStatMOD  := 'BR_BRANCO'
       Local _aStatMOD  := {}

       _cWhere += '%'

       _aRet := {}
       _aAux := {}
       Pergunte( "ZPCPA05", .f. )
       If _nOpcao == 1
          aAdd( _aAux, MV_PAR01 )
          aAdd( _aAux, MV_PAR02 )
          aAdd( _aAux, MV_PAR03 )
          _aRet := { _aAux, 0 }
       ElseIf _nOpcao == 2
              If MV_PAR03 == 1
                 If MV_PAR05 == 1
                    _cWhere := "% SC2.C2_BATROT >= '       ' %"
                 Else
                    _cWhere := "% SC2.C2_BATROT = 'MATA650' %"
                 Endif
                 BeginSQL Alias _cAliasTMP
                          COLUMN C2_EMISSAO AS DATE
                          SELECT ROW_NUMBER() OVER (ORDER BY SC2.R_E_C_N_O_) AS 'REGISTROS', SC2.C2_FILIAL, SC2.C2_OP, SC2.C2_LOTE, SC2.C2_PRODUTO, SC2.C2_UM, SC2.C2_LOCAL, SC2.C2_EMISSAO, SC2.C2_QUANT, SC2.C2_QUJE, SC2.C2_BATROT, SC2.R_E_C_N_O_, SC2.C2_ROTEIRO, SB1.B1_DESC, SB1.B1_TIPO
                          FROM %table:SC2% SC2
                          LEFT JOIN %table:SB1% SB1 on SB1.B1_FILIAL = SC2.C2_FILIAL AND SB1.D_E_L_E_T_ = '' AND SC2.C2_PRODUTO = SB1.B1_COD
                          WHERE SC2.C2_FILIAL  = %xFilial:SC2%
                            AND SC2.%notdel%
                            AND SC2.C2_EMISSAO BETWEEN  %exp:MV_PAR01% AND %exp:MV_PAR02%
                            AND SC2.C2_DATRF = ''
                            AND %exp:_cWhere%
                          ORDER BY SC2.R_E_C_N_O_
                 EndSQL
                 DbSelectArea( _cAliasTMP )
                 ( _cAliasTMP )->( DbGoBottom() )
                 _nQtdReg := ( _cAliasTMP )->( REGISTROS )
                 ( _cAliasTMP )->( DbGoTop() )
                 While !( _cAliasTMP )->( Eof() )
                       _nContador += 1
                       _aAux := {}
                       aAdd( _aAux, Iif( Alltrim( ( _cAliasTMP )->C2_BATROT ) == 'MATA650', 'BR_VERDE', 'BR_VERMELHO' ) )
                       aAdd( _aAux, 'BR_BRANCO'                )
                       aAdd( _aAux, 'BR_BRANCO'                )
                       aAdd( _aAux, 'BR_BRANCO'                )
                       aAdd( _aAux, 'BR_BRANCO'                )
                       aAdd( _aAux, ( _cAliasTMP )->C2_OP      )
                       aAdd( _aAux, ( _cAliasTMP )->C2_LOTE    )
                       aAdd( _aAux, ( _cAliasTMP )->C2_EMISSAO )
                       aAdd( _aAux, ( _cAliasTMP )->C2_PRODUTO )
                       aAdd( _aAux, ( _cAliasTMP )->B1_DESC    )
                       aAdd( _aAux, ( _cAliasTMP )->C2_UM      )
                       aAdd( _aAux, ( _cAliasTMP )->B1_TIPO    )
                       aAdd( _aAux, ( _cAliasTMP )->C2_BATROT  )
                       aAdd( _aAux, ( _cAliasTMP )->R_E_C_N_O_ )
                       aAdd( _aAux, ( _cAliasTMP )->C2_QUANT   )
                       aAdd( _aAux, ( _cAliasTMP )->C2_QUJE    )
                       aAdd( _aAux, ( _cAliasTMP )->C2_ROTEIRO )
                       aAdd( _aAux, ( _cAliasTMP )->C2_LOCAL   )
                       aAdd( _aAux, ''                         )
                       /********************************/
                       /*** Analise do Status do GGF ***/
                       If Alltrim( ( _cAliasTMP )->C2_BATROT ) == 'MATA650' //Somente para ordens de produção de produção
                          _aStatGGF := fGGFPRD( _aAux )
                          _aAux[ 2] := _aStatGGF[1]
                          _aAux[19] := _aStatGGF[2]
                          _aAux[ 3] := _aStatGGF[3]
                          _aAux[19] += _aStatGGF[4]
                       Endif
                       If MV_PAR04 == 1 //Somente divergentes
                          If !( ( _aStatGGF[1] $ 'BR_BRANCO' .or. _aStatGGF[1] $ 'BR_VERDE' ) .or. ( _aStatGGF[3] $ 'BR_BRANCO' .or. _aStatGGF[3] $ 'BR_VERDE' ) )
                             aAdd( _aRet,  { 0, _aAux } )
                          Endif
                       Else
                          aAdd( _aRet,  { 0, _aAux } )
                       Endif
                       ( _cAliasTMP )->( DbSkip() )
                 EndDo
              Else
                 If MV_PAR05 == 1
                    _cWhere := "% ( SD3.D3_ORDEM = '' OR SD3.D3_ORDEM <> '' ) %"
                 Else
                    _cWhere := "% SD3.D3_ORDEM IN('') %"
                 Endif
                 BeginSQL Alias _cAliasTMP
                          COLUMN D3_EMISSAO AS DATE
                          SELECT ROW_NUMBER() OVER (ORDER BY SD3.R_E_C_N_O_) AS 'REGISTROS', SD3.D3_FILIAL, SD3.D3_OP, SC2.C2_LOTE, SC2.C2_ROTEIRO, SD3.D3_EMISSAO, SD3.D3_COD, SB1.B1_DESC, SD3.D3_UM, SD3.D3_TIPO, SD3.D3_LOCAL, SD3.D3_EMISSAO, SD3.D3_QUANT, SC2.C2_QUJE, SC2.C2_BATROT, SD3.R_E_C_N_O_, SC2.C2_QUANT, SC2.C2_LOCAL
                          FROM %table:SD3% SD3
                          LEFT JOIN %table:SC2% SC2 ON SC2.C2_FILIAL = SD3.D3_FILIAL AND SC2.D_E_L_E_T_ = '' AND RTRIM( SC2.C2_OP ) = RTRIM( SD3.D3_OP )
                          LEFT JOIN %table:SB1% SB1 on SB1.B1_FILIAL = SD3.D3_FILIAL AND SB1.D_E_L_E_T_ = '' AND SD3.D3_COD = SB1.B1_COD
                          WHERE SD3.D3_FILIAL   = %xFilial:SD3%
                            AND SD3.%notdel%
                            AND SD3.D3_ESTORNO <> 'S'
                            AND SUBSTRING( SD3.D3_CF, 1, 2 ) = 'PR'
                            AND SD3.D3_EMISSAO BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
                            AND %exp:_cWhere%
                          ORDER BY SD3.R_E_C_N_O_
                 EndSQL
                 ( _cAliasTMP )->( DbGoTop() )
                 While !( _cAliasTMP )->( Eof() )
                       _nContador += 1
                       _aAux := {}
                       aAdd( _aAux, Iif( Alltrim( ( _cAliasTMP )->C2_BATROT ) == 'MATA650', 'BR_VERDE', 'BR_PRETO' ) )
                       aAdd( _aAux, _cStatGGF                  )
                       aAdd( _aAux, _cStatMOD                  )
                       aAdd( _aAux, 'BR_BRANCO'                )
                       aAdd( _aAux, 'BR_BRANCO'                )
                       aAdd( _aAux, ( _cAliasTMP )->D3_OP      )
                       aAdd( _aAux, ( _cAliasTMP )->C2_LOTE    )
                       aAdd( _aAux, ( _cAliasTMP )->D3_EMISSAO )
                       aAdd( _aAux, ( _cAliasTMP )->D3_COD     )
                       aAdd( _aAux, ( _cAliasTMP )->B1_DESC    )
                       aAdd( _aAux, ( _cAliasTMP )->D3_UM      )
                       aAdd( _aAux, ( _cAliasTMP )->D3_TIPO    )
                       aAdd( _aAux, ( _cAliasTMP )->C2_BATROT  )
                       aAdd( _aAux, ( _cAliasTMP )->R_E_C_N_O_ )
                       aAdd( _aAux, ( _cAliasTMP )->C2_QUANT   )
                       aAdd( _aAux, ( _cAliasTMP )->C2_QUJE    )
                       aAdd( _aAux, ( _cAliasTMP )->C2_ROTEIRO )
                       aAdd( _aAux, ( _cAliasTMP )->C2_LOCAL   )
                       /*******************************/
                       /*** Ajuste do Status do GGF ***/
                       _cLogGGF := ''
                       _cLogMOD := ''
                       If Alltrim( ( _cAliasTMP )->C2_BATROT ) == 'MATA650'
                          If MV_PAR06 == 1
                             _aStatGGF := fBuscaGGF( _aAux )
                             _aAux[2]  := _aStatGGF[1]
                             _cStatGGF := _aStatGGF[1]
                             _cLogGGF  := _aStatGGF[2]
                          Endif
                          If MV_PAR07 == 1
                             _aStatMOD := fBuscaMOD( _aAux )
                             _aAux[3]  := _aStatMOD[1]
                             _cStatMOD := _aStatMOD[1]
                             _cLogMOD  := _aStatMOD[2]
                          Endif
                          aAdd( _aAux, Alltrim( _cLogGGF ) + Alltrim( _cLogMOD ) )
                       Else
                          aAdd( _aAux, '' )
                       Endif

                       /*******************************/
                       If mv_par04 == 1
                          If !( _cStatGGF $ 'BR_VERDE' .or. _cStatGGF $ 'BR_BRANCO' ) .or. !( _cStatMOD $ 'BR_VERDE'  .or. _cStatMOD $ 'BR_BRANCO' )
                             aAdd( _aRet,  { 0, _aAux } )
                          Endif
                       Else
                          aAdd( _aRet,  { 0, _aAux } )
                       Endif
                       ( _cAliasTMP )->( DbSkip() )
                 EndDo
              Endif
              DbSelectArea( _cAliasTMP )
              ( _cAliasTMP )->( DbCloseArea( ) )
       Endif
Return _aRet

/*/{Protheus.doc} fMontaTMP
Função para montar arquivos temporários de acordo com as tabelas utilizadas
@type function
@version P12.1.25
@author Luís Gustavo de Souza
@since 20/01/2021
@param _aFields, Array, Array com a estrutura de campos da tabela
@param _cAlias , Character, Alias que será usado para a Tabela temporária
@param _oTable , object, Tabela que será gerada
/*/
Static Function fMontaTMP( _aFields, _cAlias, _oTable )
       If Select( _cAlias ) > 0
          DbSelectArea( _cAlias )
          DbCloseArea()
       Endif
       _oTable := FWTemporaryTable():New( _cAlias )
       _oTable:SetFields( _aFields )
       _oTable:Create()
Return

/*/{Protheus.doc} fBuscaGGF
Busca GGF da baixa e 
@type function
@version P12.1.25
@author Luís Gustavo de Souza
@since 21/01/2021
@return Character, Retorna a cor do status
/*/
Static Function fBuscaGGF( _aAux )
       Local _cAliasMOV := GetNextAlias()
       Local _nContador := 0
       Local _cStatus   := 'BR_BRANCO'
       Local _aAuxMOV   := {}
       Local _lDiverGGF := .T.
       Local _nX
       Local _cAnalise  := 0

       BeginSQL Alias _cAliasMOV
                COLUMN D3_EMISSAO AS DATE
                SELECT * 
                FROM %table:SD3% SD3
                WHERE SD3.D3_FILIAL   = %exp:xFilial('SD3')%
                  AND SD3.D_E_L_E_T_  = ' '
                  AND SD3.D3_ESTORNO <> 'S'
                  AND SD3.D3_OP       = %exp:_aAux[6]%
                  AND SUBSTRING( SD3.D3_COD, 1, 4) = 'GGF6'
       EndSQL
       DbSelectArea( _cAliasMOV )
       ( _cAliasMOV )->( DbGoTop() )
       While !Eof()
             _nPos := aScan( _aAuxMOV, { |x| Alltrim( x[1] ) == Alltrim( (_cAliasMov)->D3_COD ) } ) 
             If _nPos == 0
                _nContador += 1
                aAdd( _aAuxMOV, { (_cAliasMov)->D3_COD, (_cAliasMov)->D3_QUANT, _aAux[16], 0, 0, _aAux[9] } )
             Else
                _aAuxMOV[_nPos][2] += (_cAliasMov)->D3_QUANT
             Endif
             ( _cAliasMOV )->( DbSkip() )
       EndDo
       _cAnalise := ""
       If _nContador > 0
          fBuscaEst( @_aAuxMOV )
          _lDiverGGF := .T.
          For _nX := 1 To Len( _aAuxMOV )
              If !( _aAuxMOV[_nX][4] == _aAuxMOV[_nX][5] )
                 _lDiverGGF := .f.
              Endif
          Next
          If _lDiverGGF
             _cStatus := 'BR_VERDE'
          Else
             _cStatus  := 'BR_AZUL'
             _cAnalise := '# Divergencia GGF Baixado x GGF Estrutura #'
             aAdd( _aDiverg, { 'GGF', 'Divergência GGF baixado x GGF Estrutura ' + _aAux[9], 'D', _aAux[6], _aAuxMOV } )
          Endif
       Else
          _cStatus  := 'BR_VERMELHO'
          _cAnalise := '# Sem GGF baixado no movimento #'
          aAdd( _aDiverg, { 'GGF', 'Sem GGF baixado ' + _aAux[9], 'E', _aAux[6] } )
       Endif
       DbSelectArea( _cAliasMOV )
       ( _cAliasMOV )->( DbCloseArea() )
Return { _cStatus, _cAnalise }

/*/{Protheus.doc} fBuscaEst
Verificação do(s) item(ns) GGF na estrutura
@type function
@version P12.1.25
@author Luís Gustavo de Souza
@since 21/01/2021
/*/
Static Function fBuscaEst( _aAuxMOV )
       Local _cAliasEST := GetNextAlias()

       BeginSQL Alias _cAliasEST
                SELECT SG1.G1_COMP, SG1.G1_TRT, SG1.G1_QUANT
                FROM %table:SG1% SG1
                WHERE SG1.G1_FILIAL  = %exp:xFilial("SG1")%
                  AND SG1.D_E_L_E_T_ = ''
                  AND SG1.G1_COD     = %exp:_aAuxMOV[1][6]%
                  AND SUBSTRING( SG1.G1_COMP, 1, 4 ) = 'GGF6'
       EndSQL
       DbSelectArea( _cAliasEST )
       ( _cAliasEST )->( DbGoTop() )
       While !Eof()
             _nPos := aScan( _aAuxMOV, { |x| Alltrim( x[1] ) == Alltrim( (_cAliasEST)->G1_COMP ) } )
             If _nPos <> 0
                _aAuxMOV[_nPos][5] := (_cAliasEST)->G1_QUANT
                _aAuxMOV[_nPos][4] := _aAuxMOV[_nPos][2] / _aAuxMOV[_nPos][3]
             Else
                aAdd( _aAuxMOV, { (_cAliasEST)->G1_COMP, 0, 0, 0, (_cAliasEST)->G1_QUANT, '' } )
             Endif
             ( _cAliasEST )->( DbSkip( ) )
       EndDo
       DbSelectArea( _cAliasEST )
       ( _cAliasEST )->( DbCloseArea( ) )
Return

Static Function fBuscaMOD( _aAux )
       Local _cAliasAPT := GetNextAlias()
       Local _cAliasSD3 := GetNextAlias()
       Local _cStatus   := 'BR_BRANCO'
       Local _aAuxApt   := {}
       Local _nX

       BeginSQL Alias _cAliasAPT
                COLUMN ZZA_DTINI AS DATE
                COLUMN ZZA_DTFIM AS DATE
                SELECT SC2.C2_OP, SC2.C2_ROTEIRO, SH6.H6_PRODUTO, SH6.H6_OP, SH6.H6_OPERAC, SH6.H6_RECURSO, SH6.H6_TEMPO, SH6.H6_IDENT, ATU.H1_CODIGO AS 'CODRECATU', ATU.H1_MSBLQL AS 'BLQRECATU', ATU.H1_CCUSTO AS 'CCRECATU', SG2.G2_CODIGO, SG2.G2_PRODUTO, SG2.G2_OPERAC, SG2.G2_RECURSO, NEW.H1_CODIGO AS 'NEWRECCOD', NEW.H1_MSBLQL AS 'NEWRECBLQ', NEW.H1_CCUSTO AS 'NEWRECCUS', SH6.R_E_C_N_O_
                FROM %table:SH6% SH6
                LEFT JOIN %table:SH1% ATU ON ATU.H1_FILIAL = SH6.H6_FILIAL AND ATU.D_E_L_E_T_ = '' AND ATU.H1_CODIGO = SH6.H6_RECURSO
                LEFT JOIN %table:SC2% SC2 ON SC2.C2_FILIAL = SH6.H6_FILIAL AND SC2.D_E_L_E_T_ = '' AND SC2.C2_OP = RTRIM( SH6.H6_OP )
                LEFT JOIN %table:SG2% SG2 ON SG2.G2_FILIAL = SC2.C2_FILIAL AND SG2.D_E_L_E_T_ = '' AND SG2.G2_CODIGO = SC2.C2_ROTEIRO AND SG2.G2_PRODUTO = SH6.H6_PRODUTO AND SG2.G2_OPERAC = SH6.H6_OPERAC
                LEFT JOIN %table:SH1% NEW ON NEW.H1_FILIAL = SG2.G2_FILIAL AND NEW.D_E_L_E_T_ = '' AND NEW.H1_CODIGO = SG2.G2_RECURSO
                WHERE SH6.H6_FILIAL  = %exp:xFilial('SH6')%
                  AND SH6.D_E_L_E_T_ = ''
                  AND SH6.H6_OP      = %exp:_aAux[6]%
                  AND SH6.H6_TEMPO  <> '000:00'
                ORDER BY SH6.R_E_C_N_O_
       EndSQL
       DbSelectArea( _cAliasAPT )
       ( _cAliasAPT )->( DbGoTop() )
       While !Eof()
             aAdd( _aAuxAPT, { ( _cAliasAPT )->C2_OP     ,; //01
                               ( _cAliasAPT )->C2_ROTEIRO,; //02
                               ( _cAliasAPT )->H6_PRODUTO,; //03
                               ( _cAliasAPT )->H6_OP     ,; //04
                               ( _cAliasAPT )->H6_OPERAC ,; //05
                               ( _cAliasAPT )->H6_RECURSO,; //06
                               ( _cAliasAPT )->H6_TEMPO  ,; //07
                               ( _cAliasAPT )->H6_IDENT  ,; //08
                               ( _cAliasAPT )->CODRECATU ,; //09
                               ( _cAliasAPT )->BLQRECATU ,; //10
                               ( _cAliasAPT )->CCRECATU  ,; //11
                               ( _cAliasAPT )->G2_CODIGO ,; //12
                               ( _cAliasAPT )->G2_PRODUTO,; //13
                               ( _cAliasAPT )->G2_OPERAC ,; //14
                               ( _cAliasAPT )->G2_RECURSO,; //15
                               ( _cAliasAPT )->NEWRECCOD ,; //16
                               ( _cAliasAPT )->NEWRECBLQ ,; //17
                               ( _cAliasAPT )->NEWRECCUS ,; //18
                               '', 0, '', 0              ,;
                               ( _cAliasAPT )->R_E_C_N_O_,; //23
                                GetLastQuery()[2], '' } )

             ( _cAliasAPT )->( DbSkip() )
       EndDo
       DbSelectArea( _cAliasAPT )
       ( _cAliasAPT )->( DbCloseArea() )
       BeginSQL Alias _cAliasSD3
                SELECT SD3.D3_COD, SD3.D3_QUANT, SD3.R_E_C_N_O_, SD3.D3_IDENT
                FROM SD3010 SD3 
                WHERE SD3.D3_FILIAL  = %exp:xFilial('SD3')%
                  AND SD3.D_E_L_E_T_ = ' '
                  AND SD3.D3_ESTORNO <> 'S'
                  AND SD3.D3_OP = %exp:_aAux[6]%
                  AND SUBSTRING( SD3.D3_COD, 1, 2 ) = 'MO'
       EndSQL
       DbSelectArea( _cAliasSD3 )
       ( _cAliasSD3 )->( DbGoTop() )
       While !Eof()
             _nPosSD3 := aScan( _aAuxAPT, { |x| x[8] == ( _cAliasSD3 )->D3_IDENT } )
             If _nPosSD3 == 0
                aAdd( _aAuxAPT, { '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',;
                                   ( _cAliasSD3 )->D3_COD     ,; //19
                                   ( _cAliasSD3 )->D3_QUANT   ,; //20
                                   ( _cAliasSD3 )->D3_IDENT   ,; //21
                                   ( _cAliasSD3 )->R_E_C_N_O_ ,; //22
                                   0                          ,; //23
                                   ''                         ,; //24
                                   GetLastQuery()[2]          }) //25
             Else
                _aAuxAPT[ _nPosSD3][19] := ( _cAliasSD3 )->D3_COD
                _aAuxAPT[ _nPosSD3][20] := ( _cAliasSD3 )->D3_QUANT
                _aAuxAPT[ _nPosSD3][21] := ( _cAliasSD3 )->D3_IDENT
                _aAuxAPT[ _nPosSD3][22] := ( _cAliasSD3 )->R_E_C_N_O_
                _aAuxAPT[ _nPosSD3][25] := GetLastQuery()[2]
             Endif
             ( _cAliasSD3 )->( DbSkip() )
       EndDo
       _lAnalise1 := .T.
       _lAnalise2 := .T.
       _lAnalise3 := .T.
       _lAnalise4 := .T.
       _lAnalise5 := .T.
       _lAnalise6 := .T.
       _lAnalise7 := .T.
       _cAnalise  := ''
       DbSelectArea( _cAliasSD3 )
       ( _cAliasSD3 )->( DbCloseArea() )
       For _nX := 1 To Len( _aAuxAPT )
           If Empty( _aAuxAPT[ _nX ][ 3 ] )               //Sem apontamento Modelo 2
              _lAnalise1 := .F.
              _cAnalise  += '# Sem apontamento Modelo 2 #'
           Endif
           If SubStr( _aAuxAPT[ _nX][ 11 ], 1, 1 ) <> '6' //Centro de Custo antigo
              _lAnalise2 := .F.
              _cAnalise  += '# Centro de Custo antigo #'
           Endif
           If Empty( _aAuxAPT[ _nX][ 12 ] )               //Roteiro SG2 não encontrado para o apontamento SH6
              _lAnalise3 := .F.
              _cAnalise  := '# Roteiro SG2 não encontrado para o apontamento SH6 #'
           Endif
           If Empty( _aAuxAPT[ _nX][ 16 ] )               //Novo recurso não encontrado
              _lAnalise4 := .F.
              _cAnalise  := '# Novo recurso não encontrado #'
           Endif
           If Empty( _aAuxAPT[ _nX][ 19 ] )               //Movimento não encontrado
              _lAnalise5 := .F.
              _cAnalise  := '# Movimento não encontrado #'
           Else
              If SubStr( _aAuxAPT[ _nX][ 19 ], 1, 3 ) <> 'MO6' //Movimento encontrado com MOD antiga
                 _lAnalise6 := .F.
                 _cAnalise  := '# Movimento encontrado com MOD antiga #'
              Else
                 If _aAuxAPT[_nX][ 20 ] <> Round( HoraToInt( SubStr( _aAuxAPT[ _nX][ 7 ], 2, 5 ) + ':00' ), 4 ) //Diferença de horas
                    DbSelectArea("SG2")
                    SG2->( DbSetOrder( 1 ) )
                    If SG2->( DbSeek( xFilial( "SG2" ) + _aAuxAPT[_nX][3] + _aAuxAPT[_nX][2] + _aAuxAPT[_nX][5] ) )
                       If SG2->G2_MAOOBRA > 1
                          If ( _aAuxAPT[_nX][ 20 ] <> Round( HoraToInt( SubStr( _aAuxAPT[ _nX][ 7 ], 2, 5 ) + ':00' ) * SG2->G2_MAOOBRA, 4 ) )
                             If Val( SubStr( _aAuxAPT[ _nX][ 7 ], 1, At( ':', _aAuxAPT[ _nX][ 7 ] ) - 1 ) ) > 100
                                _nNewHor := Round( ( Val( SubStr( _aAuxAPT[ _nX][ 7 ], 1, At( ':', _aAuxAPT[ _nX][ 7 ] ) - 1 ) ) + HoraToInt( "00:" + SubStr( _aAuxAPT[ _nX][ 7 ], At( ':', _aAuxAPT[ _nX][ 7 ] ) + 1 ) + ":00" ) ) * SG2->G2_MAOOBRA, 4 )
                                If _aAuxAPT[_nX][ 20 ] <> _nNewHor
                                   _lAnalise7 := .F.
                                   _cAnalise  := '# Diferença de horas #'
                                Endif
                             Else
                                _lAnalise7 := .F.
                                _cAnalise  := '# Diferença de horas #'
                             Endif
                          Endif
                       Else
                          _lAnalise7 := .F.
                          _cAnalise  := '# Diferença de horas - G2_MAOOBRA <= 1 #'
                       Endif
                    Else
                       _lAnalise7 := .F.
                       _cAnalise  := '# Diferença de horas - Rot. Não Encontrado #'
                    Endif
                 Endif
              Endif
           Endif
       Next
       _cStatus := 'BR_BRANCO'
       If !_lAnalise1
          _cStatus := 'BR_VERMELHO'
       Else
          If !_lAnalise2
             _cStatus := 'BR_MARROM'
          Else
             If !_lAnalise3
                _cStatus := 'BR_VIOLETA'
             Else
                If !_lAnalise4
                   _cStatus := 'BR_AZUL'
                Else
                   If !_lAnalise5
                      _cStatus := 'BR_AMARELO'
                   Else
                      If !_lAnalise6
                         _cStatus := 'BR_AZUL_CLARO'
                      Else
                         If !_lAnalise7
                            _cStatus := 'BR_PRETO'
                         Else
                            _cStatus := 'BR_VERDE'
                         Endif
                      Endif
                   Endif
                Endif
             Endif
          Endif
       Endif
       If _cStatus <> 'BR_VERDE'
          aAdd( _aDiverg, { 'MOD', 'Divergência Mão de Obra. ' + _aAux[9], 'D', _aAux[6], _cStatus, _aAuxAPT } )
       Endif
Return { _cStatus, _cAnalise }


/*/{Protheus.doc}  fGGFPRD( )
   Analise de GGF e EMPENHO para parâmetros de analise por Ordem de Produção
   @type Function
   @author user
   @since 02/02/2021
   @version P12.1.25
   @param _aAux, Array, Parametro com informações da ordem de produção a ser gerada
   @return Array, com retorno das analises.
/*/
Static Function fGGFPRD( _aAux )
       Local _cAliasEST := GetNextAlias()
       Local _cAliasEMP := GetNextAlias()
       Local _aAnalise  := {}
       Local _cRetoEST  := ''
       Local _cStatEST  := 'BR_BRANCO'
       Local _cRetoEMP  := ''
       Local _cStatEMP  := 'BR_BRANCO'
       Local _nX
       Local _aReturn   := {}

       /*** ANALISE DAS ESTRUTURAS ***/
       BeginSQL ALIAS _cAliasEST
                SELECT * 
                FROM %table:SG1% SG1
                WHERE SG1.G1_FILIAL  = %exp:xFilial('SG1')%
                  AND SG1.D_E_L_E_T_ = ''
                  AND SG1.G1_COD = %exp:_aAux[9]%
                  AND SUBSTRING(SG1.G1_COMP, 1, 3) = 'GGF'
       EndSQL
       DbSelectArea( _cAliasEST )
       ( _cAliasEST )->( DbGoTop( ))
       While !Eof()
             aAdd( _aAnalise, { ( _cAliasEST )->G1_COMP, ( _cAliasEST )->G1_TRT, ( _cAliasEST )->G1_QUANT, 0, '' } )
             DbSelectArea( _cAliasEST )
             ( _cAliasEST )->( DbSkip( ) )
       EndDo
       DbSelectArea( _cAliasEST )
       ( _cAliasEST )->( DbCloseArea( ) )
       _lDiverEST := .f.
       If Len( _aAnalise ) <= 0
          _cStatEST := 'BR_PRETO'
          _cRetoEST := '$ Sem GGF na estutura #'
          _lDiverEST := .T.
       Else
          If xFilial("SC2") == '010101'
             For _nX := 1 To Len( _aAnalise )
                 If !_lDiverEST
                    If SubStr( _aAnalise[_nX][1], 1, 5 ) == 'GGF62' //Fabrica 1
                       If _aAux[18] <= '10' .or. _aAux[18] == 'P1'
                          _cStatEST := 'BR_VERDE'
                       Else
                          _cStatEST := 'BR_VERMELHO'
                          _cRetoEST := '$ GGF Fabrica 1 na estrutura alocado OP Fabrica 2 #'
                          _lDiverEST := .T.
                       Endif
                    Else //Fabrica 2
                       If _aAux[18] > '10' .or. _aAux[18] == 'P2'
                          _cStatEST := 'BR_VERDE'
                       Else
                          _cStatEST := 'BR_VERMELHO'
                          _cRetoEST := '$ GGF Fabrica 2 na estrutura alocado OP Fabrica 1 #'
                          _lDiverEST := .T.
                       Endif
                    Endif
                 Endif
             Next
          Else
             _cStatEST := 'BR_VERDE'
          Endif
       Endif
       /****************************/

       /*** ANALISE DOS EMPENHOS ***/
       BeginSQL ALIAS _cAliasEMP
                SELECT * 
                FROM %table:SD4% SD4
                WHERE SD4.D4_FILIAL  = %exp:xFilial('SD4')%
                  AND SD4.D_E_L_E_T_ = ''
                  AND SD4.D4_OP      = %exp:_aAux[6]%
                  AND SUBSTRING(SD4.D4_COD, 1, 3) = 'GGF'
       EndSQL
       DbSelectArea( _cAliasEMP )
       ( _cAliasEMP )->( DbGoTop( ))
       While !Eof()
             _nPos := aScan( _aAnalise, { |x| Alltrim( x[1] ) == Alltrim( ( _cAliasEMP )->D4_COD ) } )
             If _nPos > 0
                _aAnalise[_nPos][4] := ( ( _cAliasEMP )->D4_QTDEORI / _aAux[15] )
                _aAnalise[_nPos][5] := 'E'
             Else
                aAdd( _aAnalise, {  ( _cAliasEMP )->D4_COD, ( _cAliasEMP )->D4_TRT, 0, ( ( _cAliasEMP )->D4_QTDEORI / _aAux[15] ), 'D' } )
             Endif
             DbSelectArea( _cAliasEMP )
             ( _cAliasEMP )->( DbSkip( ))
       EndDo
       DbSelectArea( _cAliasEMP )
       ( _cAliasEMP )->( DbCloseArea( ))
       _lDiverEST := .f.
       If Len( _aAnalise ) <= 0
          _cStatEMP := 'BR_PRETO'
          _cRetoEMP := '$ Sem GGF empenhado #'
          _lDiverEST := .T.
       Else
          If xFilial("SC2") == '010101'
             For _nX := 1 To Len( _aAnalise )
                 If !_lDiverEST
                    If SubStr( _aAnalise[_nX][1], 1, 5 ) == 'GGF62' //Fabrica 1
                       If _aAux[18] <= '10' .or. _aAux[18] == 'P1'
                          _cStatEMP := 'BR_VERDE'
                       Else
                          _cStatEMP := 'BR_VERMELHO'
                          _cRetoEMP := '$ GGF Fabrica 1 empenhado na Fabrica 2 #'
                          _lDiverEST := .T.
                       Endif
                    Else
                       If _aAux[18] > '10' .or. _aAux[18] == 'P2'
                          _cStatEMP := 'BR_VERDE'
                       Else
                          _cStatEMP := 'BR_VERMELHO'
                          _cRetoEMP := '$ GGF Fabrica 2 empenhado na Fabrica 1 #'
                          _lDiverEST := .T.
                       Endif
                    Endif
                 Endif
             Next
          Endif
       Endif
       _aReturn := { _cStatEST, _cRetoEST, _cStatEMP, _cRetoEMP }
Return _aReturn


Static Function fButLeg( oPanel )
       Private oBtn1Leg
       Private oFon1Leg := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )

       oBtn1Leg := TButton():New( 020, 550, "Legenda", oPanel, { || fMostraLeg( ) }, 090, 018, , oFon1Leg, , .T., , "", , , , .F. )

Return

Static Function fMostraLeg( )
       //Local _oModel    := FWModelActive()
       //Local _oView     := FWViewActive()
       Local _aButtons    := {}
       Local _oFontLeg1   := TFont():New( "MS Sans Serif", 0, -12, , .T.) 
       Local _oFontLeg2   := TFont():New( "MS Sans Serif", 0, -12, , .F.) 

       oModal := FWDialogModal():New()
       oModal:SetEscClose( .F. )
       oModal:setTitle( "Legenda" )
       oModal:setSize( 270, 190 )
       oModal:createDialog()

       aAdd( _aButtons, { "", 'Cancela' , {|| oModal:DeActivate() }, , , .T., .F. } )

       oModal:addButtons( _aButtons )

       oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
       oContainer:Align := CONTROL_ALIGN_ALLCLIENT

       If MV_PAR03 == 1
          _oSayTit01   := TSay():New( 000, 002, {|| "Ordem de produção"                                   }, oContainer, , _oFontLeg1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oSayTit02   := TSay():New( 006, 002, {|| "---------------------------------------------------" }, oContainer, , _oFontLeg1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oSayTit03   := TSay():New( 016, 002, {|| "TP - Tipo da Ordem"                                  }, oContainer, , _oFontLeg1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap1   := TBitmap():New(028, 002, 020, 020, 'BR_VERDE'   ,             , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe01   := TSay():New( 028, 020, {|| "Produção"                                            }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap2   := TBitmap():New(040, 002, 020, 020, 'BR_PRETO'   ,             , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe02   := TSay():New( 040, 020, {|| "Manutenção"                                          }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oSayTit04   := TSay():New( 046, 002, {|| "---------------------------------------------------" }, oContainer, , _oFontLeg1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)

          _oSayTit05   := TSay():New( 056, 002, {|| "EST - GGF na estrutura"                              }, oContainer, , _oFontLeg1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap3   := TBitmap():New(068, 002, 020, 020, 'BR_VERDE'   ,             , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe03   := TSay():New( 068, 020, {|| "GGF correto"                                         }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap4   := TBitmap():New(080, 002, 020, 020, 'BR_VERMELHO',             , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe04   := TSay():New( 080, 020, {|| "GGF incorreto na estrutura"                          }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap5   := TBitmap():New(092, 002, 020, 020, 'BR_PRETO'   ,             , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe05   := TSay():New( 092, 020, {|| "Sem GGF na estrutura"                                }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)

          _oSayTit06   := TSay():New( 098, 002, {|| "---------------------------------------------------" }, oContainer, , _oFontLeg1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oSayTit07   := TSay():New( 108, 002, {|| "EMP - GGF no empenho"                                }, oContainer, , _oFontLeg1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap6   := TBitmap():New(120, 002, 020, 020, 'BR_VERDE'   ,             , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe06   := TSay():New( 120, 020, {|| "GGF correto"                                         }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap7   := TBitmap():New(132, 002, 020, 020, 'BR_VERMELHO',             , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe07   := TSay():New( 132, 020, {|| "GGF incorreto no empenho"                            }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap8   := TBitmap():New(144, 002, 020, 020, 'BR_PRETO'   ,             , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe08   := TSay():New( 144, 020, {|| "GGF não empenhado"                                   }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
       Else
          _oSayTit01   := TSay():New( 000, 002, {|| "Movimento de produção"                               }, oContainer, , _oFontLeg1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oSayTit02   := TSay():New( 006, 002, {|| "---------------------------------------------------" }, oContainer, , _oFontLeg1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oSayTit03   := TSay():New( 016, 002, {|| "TP - Tipo da Ordem"                                  }, oContainer, , _oFontLeg1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap1   := TBitmap():New(028, 002, 020, 020, 'BR_VERDE'   ,             , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe01   := TSay():New( 028, 020, {|| "Produção"                                            }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 060, 012)
          _oTBitmap2   := TBitmap():New(040, 002, 020, 020, 'BR_PRETO'   ,             , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe02   := TSay():New( 040, 020, {|| "Manutenção"                                          }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 060, 012)
          _oSayTit04   := TSay():New( 046, 002, {|| "---------------------------------------------------" }, oContainer, , _oFontLeg1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)

          _oSayTit05   := TSay():New( 056, 002, {|| "GGF - GGF no apontamento"                            }, oContainer, , _oFontLeg1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap3   := TBitmap():New(068, 002, 020, 020, 'BR_VERDE'   ,             , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe03   := TSay():New( 068, 020, {|| "GGF correto"                                         }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap4   := TBitmap():New(080, 002, 020, 020, 'BR_AZUL',                 , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe04   := TSay():New( 080, 020, {|| "Divergencia GGF Baixado x GGF Estrutura"             }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap5   := TBitmap():New(092, 002, 020, 020, 'BR_VERMELHO',             , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe05   := TSay():New( 092, 020, {|| "Sem GGF baixado"                                     }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)

          _oSayTit06   := TSay():New( 098, 002, {|| "---------------------------------------------------" }, oContainer, , _oFontLeg1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oSayTit07   := TSay():New( 108, 002, {|| "MOD - Mão de Obra no apontamento"                    }, oContainer, , _oFontLeg1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap6   := TBitmap():New(120, 002, 020, 020, 'BR_VERDE'    ,            , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe06   := TSay():New( 120, 020, {|| "Movimentos OK"                                       }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap7   := TBitmap():New(132, 002, 020, 020, 'BR_VERMELHO' ,            , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe07   := TSay():New( 132, 020, {|| "Sem apontamento"                                     }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap8   := TBitmap():New(144, 002, 020, 020, 'BR_MARROM'   ,            , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe08   := TSay():New( 144, 020, {|| "Centro de Custo Antigo"                              }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmap9   := TBitmap():New(156, 002, 020, 020, 'BR_VIOLETA'  ,            , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe09   := TSay():New( 156, 020, {|| "Roteiro SG2 não encontrado para o apontamento SH6"   }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 180, 012)
          _oTBitmapA   := TBitmap():New(168, 002, 020, 020, 'BR_AZUL'     ,            , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe0A   := TSay():New( 168, 020, {|| "Novo recurso não encontrado"                         }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmapB   := TBitmap():New(180, 002, 020, 020, 'BR_AMARELO'  ,            , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe0B   := TSay():New( 180, 020, {|| "Movimento não encontrado"                            }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmapC   := TBitmap():New(192, 002, 020, 020, 'BR_AZUL_CLARO',           , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe0C   := TSay():New( 192, 020, {|| "Movimento encontrado com MOD antiga"                 }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
          _oTBitmapD   := TBitmap():New(204, 002, 020, 020, 'BR_PRETO'    ,            , .T.               , oContainer,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
          _oSayOpe0C   := TSay():New( 204, 020, {|| "Diferença de horas"                                  }, oContainer, , _oFontLeg2, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 150, 012)
       Endif
       oModal:Activate()

Return
