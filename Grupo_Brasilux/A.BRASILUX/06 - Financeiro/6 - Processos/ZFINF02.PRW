#INCLUDE 'totvs.ch'
#INCLUDE 'fwmvcdef.ch'

Static __lConManual := .F.
Static __nHdlPrv	:= 0
Static __cArquivo
Static __nTotal		:= 0
Static __cLote		:= ""
Static __aFlagCTB	:= {}
Static __aSelFIL	:= {}
Static __aTmpFil	:= {}
Static __aRecCtb	:= {}
Static __aRetE5E1	:= {}
Static __lFK5Fil	:= .F.

/*/{Protheus.doc} ZFINF02
Conciliação Bancaria especifica para Brasilux, conforme solicitado no chamado 018457, Diretor Sérgio Duó.
@type function
@version 
@author Luís Gustavo
@since 24/09/2020
@return return_type, return_description
/*/
User Function ZFINF02()
     Local _aArea := GetArea()

     //Pergunte( "FINA473", .F. )
     Pergunte( "ZFINF01", .F. )

     RestArea( _aArea )
Return

Static Function ModelDef()
       Local oModel as Object
       Local oStr1 := MontaCab( 1 )
       Local oStr2 := FWFormStruct( 1, 'SIG' )
       Local oStr3 := FWFormStruct( 1, 'SE5' )
       Public _aConcNN   := {}
       Public _nContRC   := 1
       Public _nContPG   := 1
       Public _lDesCon   := .f.

       //Campos referentes ao extrato bancario
       oStr2:AddField( 'Banco'        , 'Banco'              , 'BANCO'   , 'C' ,  3    )
       oStr2:AddField( 'Cor'          , 'Cor'                , 'COR'     , 'BT', 30    )
       oStr2:AddField( 'Seq Dig'      , 'Sequencia Digitacao', 'SEQDIG'  , 'C' ,  5    )
       oStr2:AddField( 'RecnoSE5'     , 'Recno SE5'          , 'RECSE5'  , 'N' , 16, 0 )
       oStr2:AddField( 'Desconciliado', 'Desconciliado'      , 'DESCONC' , 'C' ,  1, 0 )
       oStr2:AddField( ''             , ''                   , 'EXT_MARK', 'L' ,  1, 0, , , , .F.,              , , , .F. )
       oStr2:AddField( ''             , ''                   , 'SIG_SOMA', 'N' , 18, 2, , , , .F.,              , , , .F. )
       oStr2:SetProperty( 'IG_STATUS', MODEL_FIELD_VALID ,  { || .T. } )
       oStr2:SetProperty( 'IG_STATUS', MODEL_FIELD_VALUES,  { }        )

       //Campos referentes ao movimento Bancario
       oStr3:AddField( ''             , ''                     , 'MOV_MARK' , 'L' ,  1, 0,                      , , , .F.,              , , , .F. )
       oStr3:AddField( 'Cor'          , 'Cor'                  , 'COR'      , 'BT', 30    )
       oStr3:AddField( 'Seq Dig'      , 'Sequencia Digitacao'  , 'SEQDIG'   , 'C' ,  5    )
       oStr3:AddField( 'Rec./Pag.'    , 'Receber ou pagar'     , 'E5_X_REPA', 'C' ,  1, 0, /*{|| Pertence('RP ') }*/, , /*{ '', 'R=Receber','P=Pagar' }*/, , )
       oStr3:AddField( ''             , ''                     , 'SE5_SOMA' , 'N' , 18, 2, , , , .F.,              , , , .F. )
       oStr3:AddField( 'RecnoSE5'     , 'Recno SE5'            , 'REC_NO'   , 'N' , 16, 0 )
       oStr3:AddField( 'Seq.Con'      , 'Sequencia Conciliacao', 'E5_SEQCON', 'C' , 10, 0 )
       oStr3:AddField( 'Ja Gravado'   , 'Registro já gravado'  , 'E5_X_JAGR', 'C' ,  1, 0 )
       oStr3:AddField( 'Banco Dest.'  , 'Banco de Destino'     , 'E5_X_BDES', 'C' , TAMSX3("E5_BANCO")[1]  , 0  )
       oStr3:AddField( 'Agencia Dest.', 'Agencia de Destino'   , 'E5_X_ADES', 'C' , TAMSX3("E5_AGENCIA")[1], 0  )
       oStr3:AddField( 'Conta Dest.'  , 'Conta de Destino'     , 'E5_X_CDES', 'C' , TAMSX3("E5_CONTA")[1]  , 0  )
       oStr3:AddField( 'Natur. Dest.' , 'Natureza de Destino'  , 'E5_X_NDES', 'C' , TAMSX3("E5_NATUREZ")[1], 0  )
       oStr3:AddField( 'Banco Dest.'  , 'Banco de Destino'     , 'E5_X_BORI', 'C' , TAMSX3("E5_BANCO")[1]  , 0  )
       oStr3:AddField( 'Agencia Dest.', 'Agencia de Destino'   , 'E5_X_AORI', 'C' , TAMSX3("E5_AGENCIA")[1], 0  )
       oStr3:AddField( 'Conta Dest.'  , 'Conta de Destino'     , 'E5_X_CORI', 'C' , TAMSX3("E5_CONTA")[1]  , 0  )
       oStr3:AddField( 'Natur. Dest.' , 'Natureza de Destino'  , 'E5_X_NORI', 'C' , TAMSX3("E5_NATUREZ")[1], 0  )
       oStr3:AddField( 'Natur. Dest.' , 'Natureza de Destino'  , 'E5_X_ORIG', 'C' ,  1, 0 )

       oModel := MPFormModel():New( "MD_CONCILIA", , { |oModel| fPosValid( oModel ) }, { |oModel| FGrava(oModel) } )
       oModel:SetDescription( "Conciliação Bancária" )
       oModel:addFields( 'MASTERCON', , oStr1, , , { |oModel| FLCab( oModel ) } )
       oModel:getModel( 'MASTERCON' ):SetDescription( 'Dados da Conciliação' )

       oModel:AddGrid( "GRIDEXTR", "MASTERCON", oStr2, /*{ || FLinePre() }*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, { |oModel| FLItem( oModel ) } )
       oModel:getModel( 'GRIDEXTR' ):SetNoInsertLine( .T. )
       oModel:getModel( 'GRIDEXTR' ):SetNoDeleteLine( .T. )
       oModel:AddGrid( "GRIDMOVI", "MASTERCON", oStr3, /*{ || FLinePre() }*/, /*bLinePost*/, /*bPre*/, { || .T. } /*bLinePost*/, { |oModel| FLMovi( oModel ) } )

       oModel:AddCalc( 'EXTRATO', "MASTERCON", "GRIDEXTR" , "SIG_SOMA", "EXT_SOMA" , "SUM", { || .T. }                                               , , 'Extrato'    , , 18, 2 )
       oModel:AddCalc( 'EXTRATO', "MASTERCON", "GRIDEXTR" , "SIG_SOMA", "EXT_SELE" , "SUM", { |oFw| oFw:GetValue( 'GRIDEXTR', 'EXT_MARK' ) }         , , 'Selecionado', , 18, 2 )
       
       oModel:AddCalc( 'CONCILI', "MASTERCON", "GRIDMOVI" , "SE5_SOMA", "CON_SOMA" , "SUM", { |oFw| oFw:GetValue( 'GRIDMOVI', 'MOV_MARK' ) }         , , 'Conciliado' , , 18, 2 )
       oModel:AddCalc( 'CONCILI', "MASTERCON", "GRIDMOVI" , "SE5_SOMA", "CON_SELE" , "SUM", { |oFw| oFw:GetValue( 'GRIDMOVI', 'COR' ) == 'BR_AZUL' } , , 'Lançamento' , , 18, 2 )

       oModel:AddCalc( 'MOVIMEN', "MASTERCON", "GRIDMOVI" , "SE5_SOMA", "SIS_SOMA" , "SUM", { || .T. }                                               , , 'Sistema'    , , 18, 2 )
       oModel:AddCalc( 'MOVIMEN', "MASTERCON", "GRIDMOVI" , "SE5_SOMA", "SIS_SELE" , "SUM", { |oFw| oFw:GetValue( 'GRIDMOVI', 'MOV_MARK' ) }         , , 'Selecionado', , 18, 2 )
       
       oModel:GetModel( 'GRIDEXTR' ):SetUseOldGrid( .T. )
       oModel:GetModel( 'GRIDMOVI' ):SetUseOldGrid( .T. )
Return oModel

/*/{Protheus.doc} FLCab
description
@type function
@version 
@author Luís Gustavo de Souza
@since 18/08/2020
@param oModel, object, Modelo do objeto
@return return_type, return_description
/*/
Static Function FLCab( oModel )
       Local aRet		:= {}
       Local aAux		:= {}

       //Pergunte("FINA473",.F.)
       Pergunte("ZFINF01",.F.)

       DbSelectArea( "SE8" )
       DbSeek( xFilial("SE8") + mv_par01 + mv_par02 + mv_par03 + Dtos(MV_PAR04), .T. )
       DbSkip( -1 )
       If FWxFilial("SE8") != SE8->E8_FILIAL .or.  SE8->E8_BANCO != mv_par01 .or. SE8->E8_AGENCIA != mv_par02 .or. SE8->E8_CONTA != mv_par03 .or. BOF() .or. EOF()
          nSldBanc := 0
       Else
          nSldBanc := SE8->E8_SALRECO
       Endif
       aAdd( aAux, xFilial("SIG") )
       aAdd( aAux, MV_PAR01 )
       aAdd( aAux, MV_PAR02 )
       aAdd( aAux, MV_PAR03 )
       aAdd( aAux, nSldBanc )
       aAdd( aAux, MV_PAR04 )
       aAdd( aAux, MV_PAR05 )
       aAdd( aAux, cValtoChar( MV_PAR06 ) )
       aAdd( aAux, cValtoChar( MV_PAR07 ) )
       //aAdd( aAux, cValtoChar( MV_PAR08 ) )
       //aAdd( aAux, cValtoChar( MV_PAR09 ) )
       aRet := { aAux, 0 }
Return aRet

Static Function ViewDef()
       Local oView      as Object
       Local oModel     as Object
       Local oStr1      as Object
       Local oStr2      as Object
       Local oStr3      as Object
	    Local oCal1      as Object
       //Local oCal2      as Object
       Local oCal3      as Object
       //Local oCal4      as Object
       Local oCal5      as Object
       //Local oCal6      as Object
       Private _oTable1 as Object
       //Private _aConcNN as Array
       Private bConcilia := { |oView| FWMsgRun( , { || fConAuto(oView, 1) }, "Aguarde...", "Processando conciliação Automática" ) }
       Private bReceber  := { |oView| FWMsgRun( , { || fConAuto(oView, 2) }, "Aguarde...", "Processando conciliação Automática" ) }
       Private bLancamen := { |oView| FWMsgRun( , { || fGeraLan(oView)    }, "Aguarde...", "Gerando lançamento"   ) }
       Private bTransfer := { |oView| FWMsgRun( , { || fGeraTra(oView)    }, "Aguarde...", "Gerando lançamento"   ) }
       Private bExcluiEx := { |oView| FWMsgRun( , { || fExcluiE(oView)    }, "Aguarde...", "Excluindo lançamento" ) }

       //_aConcNN := {}
       oModel := ModelDef()

       //Montagem e ajustes das estruturas de campos
       oStr1  := MontaCab( 2 )

       oStr2  := FWFormStruct( 2, "SIG" )
       oStr2:RemoveField( 'IG_STATUS' )
       oStr2:RemoveField( 'IG_NATMOV' )
       oStr2:RemoveField( 'IG_ITEM' )
       oStr2:RemoveField( 'IG_TIPEXT' )
       oStr2:RemoveField( 'IG_FILORIG' )
       oStr2:RemoveField( 'IG_TIPEXT' )
       oStr2:AddField( 'EXT_MARK', '01', '', '', {             }, 'L'  , ''     , , '', .T., NIL, NIL, NIL, NIL, NIL, .F.,	NIL, NIL )
       oStr2:AddField( 'SIG_SOMA', '60', '', '', {             }, 'N'  , ''     , , '', .T., NIL, NIL, NIL, NIL, NIL, .F.,	NIL, NIL )
       oStr2:AddField( 'COR'     , '02', '', '',                , 'BC' , '@BMP' )
       oStr2:AddField( 'SEQDIG'  , '03', '', '',                , 'Get'         )
       oStr2:SetProperty( 'IG_DTEXTR' , MVC_VIEW_ORDEM, '04' )
       oStr2:SetProperty( 'IG_VLREXT' , MVC_VIEW_ORDEM, '05' )
       oStr2:SetProperty( 'IG_HISTEXT', MVC_VIEW_ORDEM, '06' )
       oStr2:SetProperty( 'IG_CARTER' , MVC_VIEW_ORDEM, '07' )
       oStr2:SetProperty( 'IG_AGEEXT' , MVC_VIEW_ORDEM, '08' )
       oStr2:SetProperty( 'IG_CONEXT' , MVC_VIEW_ORDEM, '09' )
       oStr2:SetProperty( 'IG_DOCEXT' , MVC_VIEW_ORDEM, '10' )
       oStr2:RemoveField( 'IG_IDPROC' ) ; oStr2:RemoveField( 'SIG_SOMA' )
       oStr2:SetProperty( '*'       , MVC_VIEW_CANCHANGE, .F. )
       oStr2:SetProperty( 'EXT_MARK', MVC_VIEW_CANCHANGE, .T. )

       oStr3  := FWFormStruct( 2, "SE5" )
       oStr3:AddField( 'MOV_MARK' , '01', ''    , ''                     , , 'L' , ''  , , '', .T., NIL, NIL, NIL                              , NIL, NIL, .F.,	NIL, NIL )
       oStr3:AddField( 'COR'      , '02', ''    , ''                     , , 'BC', '@BMP' )
       oStr3:AddField( 'SEQDIG'   , '03', ''    , ''                     , , 'Get' )
       oStr3:AddField( 'E5_X_REPA', '09', 'Carteira', 'Tipo do Movimento', , 'C' , '@!', , '', .T., NIL, NIL, { '', 'R=Receber' , 'P=Pagar'   }, NIL, NIL, .T., NIL, NIL )
       oStr3:AddField( 'SE5_SOMA' , '60', ''    , ''                     , , 'N' , ''  , , '', .T., NIL, NIL,                                  , NIL, NIL, .T., NIL, NIL )
       oStr3:AddField( 'E5_X_JAGR', '90', ''    , ''                     , , 'C' , ''  , , '', .T., NIL, NIL,                                  , NIL, NIL, .T., NIL, NIL )
       oStr3:AddField( 'E5_SEQCON', '91', ''    , ''                     , , 'C' , ''  , , '', .T., NIL, NIL,                                  , NIL, NIL, .T., NIL, NIL )
       oStr3:AddField( 'E5_X_BDES', '92', ''    , ''                     , , 'C' , ''  , , '', .T., NIL, NIL,                                  , NIL, NIL, .T., NIL, NIL )
       oStr3:AddField( 'E5_X_ADES', '93', ''    , ''                     , , 'C' , ''  , , '', .T., NIL, NIL,                                  , NIL, NIL, .T., NIL, NIL )
       oStr3:AddField( 'E5_X_CDES', '94', ''    , ''                     , , 'C' , ''  , , '', .T., NIL, NIL,                                  , NIL, NIL, .T., NIL, NIL )
       oStr3:AddField( 'E5_X_NDES', '95', ''    , ''                     , , 'C' , ''  , , '', .T., NIL, NIL,                                  , NIL, NIL, .T., NIL, NIL )
       oStr3:AddField( 'E5_X_BORI', '96', ''    , ''                     , , 'C' , ''  , , '', .T., NIL, NIL,                                  , NIL, NIL, .T., NIL, NIL )
       oStr3:AddField( 'E5_X_AORI', '97', ''    , ''                     , , 'C' , ''  , , '', .T., NIL, NIL,                                  , NIL, NIL, .T., NIL, NIL )
       oStr3:AddField( 'E5_X_CORI', '98', ''    , ''                     , , 'C' , ''  , , '', .T., NIL, NIL,                                  , NIL, NIL, .T., NIL, NIL )
       oStr3:AddField( 'E5_X_NORI', '99', ''    , ''                     , , 'C' , ''  , , '', .T., NIL, NIL,                                  , NIL, NIL, .T., NIL, NIL )
       oStr3:AddField( 'E5_X_ORIG', 'A0', ''    , ''                     , , 'C' , ''  , , '', .T., NIL, NIL,                                  , NIL, NIL, .T., NIL, NIL )
       oStr3:SetProperty( 'E5_DTDISPO', MVC_VIEW_ORDEM, '04' )
       oStr3:SetProperty( 'E5_VALOR'  , MVC_VIEW_ORDEM, '05' )
       oStr3:SetProperty( 'E5_HISTOR' , MVC_VIEW_ORDEM, '06' )
       oStr3:SetProperty( 'E5_NATUREZ', MVC_VIEW_ORDEM, '07' )
       oStr3:SetProperty( 'E5_DOCUMEN', MVC_VIEW_ORDEM, '08' )
       oStr3:SetProperty( 'E5_DATA'   , MVC_VIEW_ORDEM, '09' )
       oStr3:SetProperty( 'E5_AGENCIA', MVC_VIEW_ORDEM, '10' )
       oStr3:SetProperty( 'E5_CONTA'  , MVC_VIEW_ORDEM, '11' )
       //oStr3:SetProperty( 'E5_RECPAG' , MVC_VIEW_ORDEM, '12' )
       oStr3:SetProperty( 'E5_MOEDA'  , MVC_VIEW_ORDEM, '13' )
       oStr3:SetProperty( 'E5_NUMCHEQ', MVC_VIEW_ORDEM, '14' )
       oStr3:RemoveField( 'SE5_SOMA' )   ; oStr3:RemoveField( 'E5_X_JAGR' ) ; oStr3:RemoveField( 'E5_BANCO'  )
       oStr3:RemoveField( 'E5_USERLGI' ) ; oStr3:RemoveField( 'E5_USERLGA') ; oStr3:RemoveField( 'E5_MODSPB' )
       oStr3:RemoveField( 'E5_AGLIMP' )  ; oStr3:RemoveField( 'E5_SERREC' ) ; oStr3:RemoveField( 'E5_MOVCX'  ) 
       oStr3:RemoveField( 'E5_DIACTB' )  ; oStr3:RemoveField( 'E5_NODIA'  ) ; oStr3:RemoveField( 'E5_PROCTRA')
       oStr3:RemoveField( 'E5_PRISS ' )  ; oStr3:RemoveField( 'E5_PRINSS' ) ; oStr3:RemoveField( 'E5_IDMOVI' )
       oStr3:RemoveField( 'E5_CCUSTO' )  ; oStr3:RemoveField( 'E5_FLDMED' ) ; oStr3:RemoveField( 'E5_DTCANBX')
       oStr3:RemoveField( 'E5_X_BDES' )  ; oStr3:RemoveField( 'E5_X_ADES' ) ; oStr3:RemoveField( 'E5_X_CDES' )
       oStr3:RemoveField( 'E5_X_NDES' )  ; oStr3:RemoveField( 'E5_X_ORIG' ) ; oStr3:RemoveField( 'E5_X_BORI' )
       oStr3:RemoveField( 'E5_X_AORI' )  ; oStr3:RemoveField( 'E5_X_CORI' ) ; oStr3:RemoveField( 'E5_X_NORI' )
       oStr3:SetProperty( '*', MVC_VIEW_CANCHANGE, .F. )
       oStr3:SetProperty( 'MOV_MARK'  , MVC_VIEW_CANCHANGE, .T. )
       oStr3:SetProperty( 'E5_NATUREZ', MVC_VIEW_CANCHANGE, .T. )
       oStr3:SetProperty( 'E5_HISTOR' , MVC_VIEW_CANCHANGE, .T. )

       //Atribuição do Form
       oView := FWFormView():New()
       oView:SetModel( oModel )
       
       //Inclusão do Field do formulário
       oView:AddField( 'FORM_SIF' , oStr1, 'MASTERCON' )
       oView:CreateHorizontalBox( 'BOX_FORM_SIF', 12 )
       oView:SetOwnerView( 'FORM_SIF', 'BOX_FORM_SIF' )

       //Inclusão dos Grids na View
       oView:AddGrid( "VIEW_EXT" , oStr2, "GRIDEXTR" )
       oView:AddGrid( "VIEW_MOV" , oStr3, "GRIDMOVI" )
       
       //Definição dos BOXEs das GRIDs
       oView:CreateHorizontalBox( 'BOX_FORM_CON', 70 )
       oView:CreateVerticalBox( 'BOX_ESQ', 50, "BOX_FORM_CON" )
       oView:CreateVerticalBox( 'BOX_DIR', 50, "BOX_FORM_CON" )
       oView:SetOwnerView( 'VIEW_EXT', 'BOX_ESQ' )
       oView:SetOwnerView( 'VIEW_MOV', 'BOX_DIR' )
       oView:EnableTitleView( 'VIEW_EXT', 'Extrato bancário')
       oView:EnableTitleView( 'VIEW_MOV', 'Movimento do Sistema')

       //Ação dos Campos
       oView:SetFieldAction("EXT_MARK", { | oView, cIDView, cField, xValue | FActionExt( oView, cIDView, cField, xValue, "EXT" ) } )
       oView:SetFieldAction("MOV_MARK", { | oView, cIDView, cField, xValue | FActionExt( oView, cIDView, cField, xValue, "MOV" ) } )
       oView:SetFieldAction("E5_BENEG", { | oView, cIDView, cField, xValue | FActionExt( oView, cIDView, cField, xValue, "MOV" ) } )

       //Montagem dos campos de calculo
       oCal1 := FWCalcStruct( oModel:GetModel( 'EXTRATO' ) )
       oCal3 := FWCalcStruct( oModel:GetModel( 'MOVIMEN' ) )
       oCal5 := FWCalcStruct( oModel:GetModel( 'CONCILI' ) )

       oView:AddField( 'VIEW_EXT_BCO', oCal1, 'EXTRATO' )
       oView:AddField( 'VIEW_SIS_BCO', oCal3, 'MOVIMEN' )
       oView:AddField( 'VIEW_CON_CON', oCal5, 'CONCILI' )

       //Montagem dos BOXEs de Calculo
       oView:CreateHorizontalBox( 'BOX_FORM_CAL1', 18 )
       oView:CreateVerticalBox( 'BOX_ESQ_CAL1', 33, "BOX_FORM_CAL1" )
       oView:CreateVerticalBox( 'BOX_CEN_CAL1', 34, "BOX_FORM_CAL1" )
       oView:CreateVerticalBox( 'BOX_DIR_CAL1', 33, "BOX_FORM_CAL1" )
       oView:SetOwnerView( 'VIEW_EXT_BCO', 'BOX_ESQ_CAL1' )
       oView:SetOwnerView( 'VIEW_CON_CON', 'BOX_CEN_CAL1' )
       oView:SetOwnerView( 'VIEW_SIS_BCO', 'BOX_DIR_CAL1' )
       oView:EnableTitleView( 'VIEW_EXT_BCO', 'Totais do Extrato' )
       oView:EnableTitleView( 'VIEW_SIS_BCO', 'Totais do Movimento' )
       oView:EnableTitleView( 'VIEW_CON_CON', 'Conciliados' )

       //Adição dos botões de Operação
       oView:AddUserButton( 'Legenda'                           , 'FORM'  , { |oView| fLegenda() } )
       oView:AddUserButton( "Conciliação automática - (F6)"     , 'PEDIDO', { |oView| FWMsgRun( , { || fConAuto(oView, 1) }, "Aguarde...", "Processando conciliação Automática" ) } )
       oView:AddUserButton( "Conciliação a Receber  - (F7)"     , 'PEDIDO', { |oView| FWMsgRun( , { || fConAuto(oView, 2) }, "Aguarde...", "Processando conciliação Automática" ) } )
       oView:AddUserButton( "Gera Lançamento - (F8)"            , 'PEDIDO', { |oView| FWMsgRun( , { || fGeraLan(oView)    }, "Aguarde...", "Gerando lançamento" )                 } )
       oView:AddUserButton( "Transferência - (F9)"              , 'PEDIDO', { |oView| FWMsgRun( , { || fGeraTra(oView)    }, "Aguarde...", "Gerando lançamento" )                 } )
       oView:AddUserButton( "Exclui registro do extrato - (F10)", 'PEDITO', { |oView| FWMsgRun( , { || fExcluiE(oView)    }, "Aguarde...", "Excluindo lançamento" )               } )

       oView:SetCloseOnOk( { || .F. } ) 
       SetKey( VK_F6 , bConcilia )
       SetKey( VK_F7 , bReceber  )
       SetKey( VK_F8 , bLancamen )
       SetKey( VK_F9 , bTransfer )
       SetKey( VK_F10, bExcluiEx )
Return oView

Static function MontaCab( _nOpc )
       Local oStruct  as Object
       Local _aCampos as Array

       If _nOpc == 1
          oStruct  := FWFormModelStruct():New()
          _aCampos := {}
          aAdd( _aCampos, { 'FILIAL'   , 'C', TamSx3("A6_FILIAL")[1] , TamSx3("A6_FILIAL")[2]  } )
          aAdd( _aCampos, { 'BANCO'    , 'C', TamSx3("A6_COD")[1]    , TamSx3("A6_COD")[2]     } )
          aAdd( _aCampos, { 'AGENCIA'  , 'C', TamSx3("A6_AGENCIA")[1], TamSx3("A6_AGENCIA")[2] } )
          aAdd( _aCampos, { 'CONTA'    , 'C', TamSx3("A6_NUMCON")[1] , TamSx3("A6_NUMCON")[2]  } )
          aAdd( _aCampos, { 'SALDOANT' , 'N',                      18,                       2 } )
          aAdd( _aCampos, { 'DATADE'   , 'C',                       8,                       0 } )
          aAdd( _aCampos, { 'DATAATE'  , 'C',                       8,                       0 } )
          //aAdd( _aCampos, { 'AGLUTINA' , 'C',                       1,                       0 } )
          //aAdd( _aCampos, { 'MOSTRACTB', 'C',                       1,                       0 } )
          //aAdd( _aCampos, { 'CTBONLINE', 'C',                       1,                       0 } )
          aAdd( _aCampos, { 'SELFIL'   , 'C',                       1,                       0 } )
          aAdd( _aCampos, { 'VISIBI'   , 'C',                       1,                       0 } )
          fMontaTMP( _aCampos, 'CABCON', _oTable1 )

          oStruct:AddTable( 'CABCON', { 'FILIAL', 'BANCO' }, 'Cabecalho Conciliacao' )
          oStruct:AddField( 'Filial'          , 'Filial do Sistema'        , 'FILIAL'   , 'C', TamSx3("A6_FILIAL")[1] , , , ,                   , , , .T. )
          oStruct:AddField( 'Banco'           , 'Banco Conciliacao'        , 'BANCO'    , 'C', TamSx3("A6_COD")[1]    , , , ,                   , , , .T., .F. )
          oStruct:AddField( 'Agencia'         , 'Agencia Conciliação'      , 'AGENCIA'  , 'C', TamSx3("A6_AGENCIA")[1], , , ,                   , , , .T., .F. )
          oStruct:AddField( 'Conta'           , 'Conta Conciliação'        , 'CONTA'    , 'C', TamSx3("A6_NUMCON")[1] , , , ,                   , , , .T., .F. )
          oStruct:AddField( 'Saldo Bancário'  , 'Saldo bancario (anterior)', 'SALDOANT' , 'N', 18, , , ,                   , , , .T., .F. )
          oStruct:AddField( 'Data De'         , 'Data De'                  , 'DATADE'   , 'D',                      8 )
          oStruct:AddField( 'Data Até'        , 'Data Até'                 , 'DATAATE'  , 'D',                      8 )
          //oStruct:AddField( 'Aglut Lanc'      , 'Aglut Lanc'         , 'AGLUTINA' , 'C',                      1 , , , , { '1=Sim', '2=Não' } )
          //oStruct:AddField( 'Mostra Lanc'     , 'Mostra Lanc'        , 'MOSTRACTB', 'C',                      1 , , , , { '1=Sim', '2=Não' } )
          //oStruct:AddField( 'Contb On Line'   , 'Contb On Line'      , 'CTBONLINE', 'C',                      1 , , , , { '1=Sim', '2=Não' } )
          oStruct:AddField( "Seleciona Filial", "Seleciona Filial"   , 'SELFIL'   , 'C',                      1 , , , , { '1=Sim', '2=Não' } )
          oStruct:AddField( "Visibilidade"    , "Visibilidade"       , 'VISIBI'   , 'C',                      1 , , , , { '1=Todos', '2=Não Conciliados', '3=Conciliados' } )
       Else
          oStruct := FWFormViewStruct():New()
          oStruct:AddField( 'BANCO'    , '1', 'Banco'           , 'Banco'           , , 'Get'  ,     , , , .F. )
          oStruct:AddField( 'AGENCIA'  , '2', 'Agencia'         , 'Agencia'         , , 'Get'  , '@!', , , .F. )
          oStruct:AddField( 'CONTA'    , '3', 'Conta'           , 'Conta'           , , 'Get'  ,     , , , .F. )
          oStruct:AddField( 'SALDOANT' , '5', 'Saldo'           , 'Saldo'           , , 'Get'  , '@E 999,999,999,999.99'    , , , .F. )
          oStruct:AddField( 'DATADE'   , '5', 'Data De'         , 'Data De'         , , 'Get'  ,     , , , .F. )
          oStruct:AddField( 'DATAATE'  , '6', 'Data Ate'        , 'Data Ate'        , , 'Get'  ,     , , , .F. )
          //oStruct:AddField( 'AGLUTINA' , '6', 'Aglut Lanc'      , 'Aglut Lanc'      , , 'Combo',     , , , .F., , , { '1-Sim', '2-Não' } )
          //oStruct:AddField( 'MOSTRACTB', '7', 'Mostra Lanc'     , 'Mostra Lanc'     , , 'Combo',     , , , .F., , , { '1-Sim', '2-Não' } )
          //oStruct:AddField( 'CTBONLINE', '8', 'Contb On Line'   , 'Contb On Line'   , , 'Combo',     , , , .F., , , { '1-Sim', '2-Não' } )
          oStruct:AddField( 'SELFIL'   , '7', 'Seleciona Filial', 'Seleciona Filial', , 'Combo',     , , , .F., , , { '1-Sim', '2-Não' } )
          oStruct:AddField( 'VISIBI'   , '8', 'Vilibilidade'    , 'Visibilidade'    , , 'Combo',     , , , .F., , , { '1-Todos', '2-Não Conciliados', '3-Conciliados' } )
       Endif
Return oStruct

Static Function FLItem( oModelItem )
       Local aItConc    := {}
       //Local aAux       := {}
       Local cBanco     := ""
       Local cAgencia   := ""
       Local cConta     := ""
       Local dDataDe    := cTod("")
       Local dDataAte   := cTod("")
       //Local lAglutina  := .F.
       //Local lMostra    := .F.
       //Local lCtbOnline := .F.
       Local aCpoSIG    := {}
       Local aArea      := GetArea()
       Local nSeqDig    := 0
       Local nY         := 0
       Local nPosCor    := 0
       Local nPosStatus := 0
       Local nPosSeq    := 0
       Local aFields    := oModelItem:GetStruct():GetFields()
       Local cStatus    := ""
       Local cItem      := ""
       Local nPosRec    := 0
       Local aAreaSE5   := SE5->(GetArea())
       Local nPosSeqCon := 0
       //Local cFilX      := ""

       //Pergunte( "FINA473", .F. )
       Pergunte( "ZFINF01", .F. )

       cBanco     := MV_PAR01
       cAgencia   := MV_PAR02
       cConta     := MV_PAR03
       dDataDe    := MV_PAR04
       dDataAte   := MV_PAR05
       //lAglutina  := MV_PAR06 == 1
       //lMostra    := MV_PAR07 == 1
       //lCtbOnline := MV_PAR08 == 1

       // Posição no Array - Atenção a ordem deve ser a mesma do model
       For nY := 1 to Len(aFields)
           aAdd( aCpoSIG, Alltrim( aFields[nY][3] ) )
       Next nY

       //Retorna os movimentos do extrato
       FWMsgRun( , { || FCSIG( @aItConc, aCpoSIG, cBanco, cAgencia, cConta, dDataDe, dDataAte ) }, "Aguarde...", "Carregando extrato bancario" )

       nPosCor    := aScan( aCpoSIG, { |cItem| Alltrim(cItem) == "COR"       } )
       nPosStatus := aScan( aCpoSIG, { |cItem| Alltrim(cItem) == "IG_STATUS" } )
       nPosEfetiv := aScan( aCpoSIG, { |cItem| Alltrim(cItem) == "IG_EFETIVA"} )
       nPosSeq    := aScan( aCpoSIG, { |cItem| Alltrim(cItem) == "SEQDIG"    } )
       nPosRec    := aScan( aCpoSIG, { |cItem| Alltrim(cItem) == "RECSE5"    } )
       nPosSeqCon := aScan( aCpoSIG, { |cItem| Alltrim(cItem) == "IG_SEQMOV" } )

       For nY := 1 to Len(aItConc)
           nSeqDig++
	
           cStatus                 := aItConc[nY][2][nPosStatus]
           aItConc[nY][2][nPosCor] := u_FRETCOR( cStatus )	
           aItConc[nY][2][nPosSeq] := cValToChar( nSeqDig )
	
           If Empty(aItConc[nY][2][nPosRec]) 
              aItConc[nY][2][nPosRec] := FSE5Rec(aItConc[nY][2][nPosSeqCon])
           EndIf
       Next nY

       RestArea( aAreaSE5 )
       RestArea( aArea )
Return aItConc

Static Function FCSIG( aRet, aCpoSIG, cBanco, cAgencia, cConta, dDataDe, dDataAte )
       Local aAux       := {}
       //Local lAglutina  := .F.
       //Local lMostra    := .F.
       //Local lCtbOnline := .F.
       Local cQuery     := ""
       Local cTabSIG    := "SIGCONTRB"
       Local aStru      := {}
       Local nX         := 0
       Local cCampo     := ""
       //Local cCpoIGE5   := ""
       Local aArea      := GetArea()
       Local cTmpSIGFil := ""
       Local cTipoCH    := IIF( Type( "MVCHEQUES" ) == "C", MVCHEQUES, MVCHEQUE )
       Local cSA6Emp    := FWModeAccess( "SA6", 1 )
       Local cSA6UNe    := FWModeAccess( "SA6", 2 )
       Local cSA6Fil    := FWModeAccess( "SA6", 3 )
       Local cNoCampos  := ''

       //Movimentos de Extratos não conciliados
       cQuery += " SELECT  DISTINCT "   + CRLF
       cQuery += " IG_FILIAL ," + CRLF
       cQuery += " IG_IDPROC ," + CRLF
       cQuery += " IG_ITEM   ," + CRLF
       cQuery += " IG_DTEXTR ," + CRLF
       cQuery += " IG_AGEEXT ," + CRLF
       cQuery += " IG_CONEXT ," + CRLF
       cQuery += " IG_DOCEXT ," + CRLF
       cQuery += " IG_VLREXT ," + CRLF
       cQuery += " IG_HISTEXT," + CRLF
       cQuery += " IG_TIPEXT ," + CRLF
       cQuery += " IG_CARTER ," + CRLF
       cQuery += " IG_DTMOVI ," + CRLF
       cQuery += " IG_AGEMOV ," + CRLF
       cQuery += " IG_CONMOV ," + CRLF
       cQuery += " IG_DOCMOV ," + CRLF
       cQuery += " IG_VLRMOV ," + CRLF
       cQuery += " IG_HISMOV ," + CRLF
       cQuery += " IG_NATMOV ," + CRLF
       cQuery += " IG_SEQMOV ," + CRLF
       cQuery += " IG_STATUS ," + CRLF
       cQuery += " IG_EFETIVA," + CRLF
       cQuery += " IF_BANCO BANCO, 	" + CRLF
       cQuery += " COALESCE(E5_RECONC,'') RECONC, 	" + CRLF
       cQuery += " IG_FILORIG 	" + CRLF
       cQuery += " FROM " + RetSQLName( "SIG" ) + " SIG		" + CRLF
       cQuery += " INNER JOIN " + RetSQLName( "SIF" ) + " SIF ON	" + CRLF
       cQuery += " IF_FILIAL = IG_FILIAL AND	" + CRLF
       cQuery += " IF_IDPROC = IG_IDPROC AND " + CRLF
       cQuery += " IF_BANCO = '" + cBanco + "' AND " + CRLF
       cQuery += " SIF.D_E_L_E_T_ = ' '	" + CRLF
       cQuery += " LEFT  JOIN " + RetSQLName( "SE5" ) + " SE5 ON	" + CRLF
       cQuery += " E5_DTDISPO = IG_DTEXTR AND " + CRLF
       cQuery += " E5_BANCO = '" + cBanco + "' AND " + CRLF
       cQuery += " E5_AGENCIA = '" + cAgencia + "' AND " + CRLF
       cQuery += " E5_CONTA   = '" + cConta + "' AND " + CRLF
       cQuery += " E5_SITUACA <> 'C' AND " + CRLF
       cQuery += " E5_TIPODOC NOT IN " + FormatIn( "BA/DC/JR/MT/CM/D2/J2/M2/C2/V2/CP/TL","/" ) + " AND " + CRLF
       cQuery += " E5_VALOR = IG_VLREXT AND " + CRLF
       cQuery += "(E5_MOEDA NOT IN " + FormatIn( "C1/C2/C3/C4/C5/CH","/" ) + " OR (E5_MOEDA IN " + FormatIn( "C1/C2/C3/C4/C5/CH","/" ) + " AND E5_NUMCHEQ <> ' ')) AND "
       cQuery += "(E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) AND " + CRLF
       cQuery += "((E5_TIPODOC  IN " + FormatIn( cTipoCH, "|" ) + "AND  E5_DTDISPO BETWEEN  '" + DTOS( dDataDe )+ "' AND '"  + DTOS( dDataAte ) +"' ) OR " + CRLF
       cQuery += "(E5_TIPODOC   NOT IN " + FormatIn( cTipoCH, "|" ) + "AND  E5_DTDISPO BETWEEN  '" + DTOS( dDataDe )+ "' AND '"  + DTOS( dDataAte ) +"' )) AND " + CRLF
       cQuery += "(E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) AND " + CRLF
       cQuery += " E5_SEQCON = IG_SEQMOV AND " + CRLF
       cQuery += " SE5.D_E_L_E_T_ = ' ' " + CRLF
       cQuery += " WHERE			"
       If cSA6Emp ==  "E" .And. cSA6UNe == "E" .And. cSA6Fil == "E"
          cQuery +=    " IG_FILIAL " + GetRngFil( __aSelFil, "SIG", .T., @cTmpSIGFil ) + " AND " + CRLF
       EndIf
       cQuery += " IG_AGEEXT = '" + cAgencia + "' AND	" + CRLF
       cQuery += " IG_CONEXT = '" + cConta + "' AND " + CRLF
       cQuery += " IG_DTEXTR >= '" + DTOS( dDataDe ) + "' AND	" + CRLF
       cQuery += " IG_DTEXTR <= '" + DTOS( dDataAte ) + "' AND " + CRLF
       If mv_par07 == 2
          cQuery += " IG_EFETIVA <> '1' AND " + CRLF
       elseIf mv_par07 == 3
              cQuery += " IG_EFETIVA = '1' AND " + CRLF
       Endif
       cQuery += " SIG.D_E_L_E_T_ = ' '  " + CRLF
       //cQuery += " AND SIF.IF_IDPROC = '" + SIF->IF_IDPROC + "' " + CRLF
       //If mv_par01 == '001' //para banco do brasil filtrar codigo 205 - bloqueio de cheques.
       //   cQuery += " AND SIG.IG_TIPEXT <> '205' " + CRLF
       //Endif
       cQuery += " ORDER BY " + CRLF
       cQuery += " IG_FILIAL , " + CRLF
       cQuery += " BANCO  ,	" + CRLF
       cQuery += " IG_AGEEXT , " + CRLF
       cQuery += " IG_CONEXT , " + CRLF
       cQuery += " IG_DTEXTR , " + CRLF
       cQuery += " IG_VLREXT " + CRLF
       cQuery := ChangeQuery( cQuery )

       aAdd( __aTmpFil, cTmpSIGFil )

       dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cTabSIG, .T., .T. )

       aStru := SIG->(dbStruct())

       For nX :=  1 To Len(aStru)
           If aStru[nX][2] <> "C" .And. SIG->(FieldPos(aStru[nX][1])) > 0
              TcSetField(cTabSIG,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
           EndIf
           If (cTabSIG)->(FieldPos(aStru[nX][1])) == 0
              cNoCampos += '/' + aStru[nX][1]       
           Endif
       Next nX

       While (cTabSIG)->(!EOF())
             aAux := Nil
             aAux := Array( Len( aCpoSIG ) )
             aAdd( aAux, "" )

             For nX := 1 to Len(aCpoSIG)
                 If !( aCpoSIG[nX] $ ("COR/SEQDIG/RECSE5/DESCONC/IG_TIPMOV/IG_TIPDSC/IG_USERLGI/EXT_MARK/SIG_SOMA") )
                    cCampo   := aCpoSIG[nX]
                    If cCampo == 'IG_STATUS' .AND. !Empty((cTabSIG)->RECONC) // Caso o movimento tenha sido Reconciliado anteriormente
                       aAux[nX] := '3'
                    Else
                       If !Empty(cNoCampos)
                          If !(cCampo $ cNoCampos) 
                             aAux[nX] := (cTabSIG)->&(cCampo)
                          Endif
                       Else
                          aAux[nX] := (cTabSIG)->&(cCampo)
                       Endif	
                    EndIf
                 ElseIf Alltrim(aCpoSIG[nX]) == "EXT_MARK"
                        aAux[nX] := Iif( (cTabSIG)->IG_EFETIVA == '1', .T., .f. ) 
                 ElseIf Alltrim(aCpoSIG[nX]) == "SIG_SOMA"
                        aAux[nX] := Iif( (cTabSIG)->IG_CARTER == '1', 1, -1 ) * (cTabSIG)->IG_VLREXT
                 ElseIf Alltrim(aCpoSIG[nX]) == "RECSE5"
                        aAux[nX] := 0
                 ElseIf Alltrim(aCpoSIG[nX]) == "IG_TIPMOV"
                        aAux[nX] :=  GetAdvFVal("SEJ","EJ_OCORSIS", xFilial("SEJ",(cTabSIG)->IG_FILORIG) + (cTabSIG)->BANCO + (cTabSIG)->IG_TIPEXT ,1)
                 ElseIf Alltrim(aCpoSIG[nX]) == "IG_TIPDSC"
                        aAux[nX] :=  GetAdvFVal("SEJ","EJ_DESCR", xFilial("SEJ",(cTabSIG)->IG_FILORIG) + (cTabSIG)->BANCO + (cTabSIG)->IG_TIPEXT ,1)
                 Else
                    aAux[nX] := ""
                 EndIf
             Next nX
             aAdd(aRet,{0 ,aAux })

            (cTabSIG)->(dbSkip())
       EndDo
       (cTabSIG)->(dbCloseArea())
       RestArea(aArea)
Return


Static Function FLMovi( oModelItem )
       Local aItConc    := {}
       //Local aAux       := {}
       Local cBanco     := ""
       Local cAgencia   := ""
       Local cConta     := ""
       Local dDataDe    := cTod("")
       Local dDataAte   := cTod("")
       //Local lAglutina  := .F.
       //Local lMostra    := .F.
       //Local lCtbOnline := .F.
       Local aCpoSE5    := {}
       Local aArea      := GetArea()
       Local nSeqDig    := 0
       Local nY         := 0
       Local nPosCor    := 0
       Local nPosStatus := 0
       Local nPosSeq    := 0
       Local aFields    := oModelItem:GetStruct():GetFields()
       Local cStatus    := ""
       Local cItem      := ""
       Local nPosRec    := 0
       Local aAreaSE5   := SE5->(GetArea())
       Local nPosSeqCon := 0
       //Local cFilX      := ""

       //Pergunte( "FINA473", .F. )
       Pergunte( "ZFINF01", .F. )

       cBanco     := MV_PAR01
       cAgencia   := MV_PAR02
       cConta     := MV_PAR03
       dDataDe    := MV_PAR04
       dDataAte   := MV_PAR05
       //lAglutina  := MV_PAR06 == 1
       //lMostra    := MV_PAR07 == 1
       //lCtbOnline := MV_PAR08 == 1

       // Posição no Array - Atenção a ordem deve ser a mesma do model
       For nY := 1 to Len(aFields)
           aAdd( aCpoSE5, Alltrim( aFields[nY][3] ) )
       Next nY

       //Retorna os movimentos do SE5
       FWMsgRun(  , { || FCMOV( @aItConc, aCpoSE5, cBanco, cAgencia, cConta, dDataDe, dDataAte ) }, "Aguarde...", "Carregando movimentos..." )

       nPosCor    := aScan( aCpoSE5, { |cItem| Alltrim(cItem) == "COR"       } )
       nPosStatus := aScan( aCpoSE5, { |cItem| Alltrim(cItem) == "IG_STATUS" } )
       nPosSeq    := aScan( aCpoSE5, { |cItem| Alltrim(cItem) == "SEQDIG"    } )
       nPosRec    := aScan( aCpoSE5, { |cItem| Alltrim(cItem) == "RECSE5"    } )
       nPosSeqCon := aScan( aCpoSE5, { |cItem| Alltrim(cItem) == "IG_SEQMOV" } )
       nPosRecon  := aScan( aCpoSE5, { |cItem| Alltrim(cItem) == "E5_RECONC" } )

       For nY := 1 to Len(aItConc)
           nSeqDig++
	
           cStatus                 := Iif( Empty( aItConc[nY][2][nPosRecon] ), '1', '3' )
           aItConc[nY][2][nPosCor] := u_FRETCOR( cStatus )	
           aItConc[nY][2][nPosSeq] := cValToChar( nSeqDig )
	
           //If Empty(aItConc[nY][2][nPosRec]) 
              //aItConc[nY][2][nPosRec] := FSE5Rec(aItConc[nY][2][nPosSeqCon])
           //EndIf
       Next nY

       RestArea( aAreaSE5 )
       RestArea( aArea )
Return aItConc

Static Function FCMOV( aRet, aCpoSE5, cBanco, cAgencia, cConta, dDataDe, dDataAte )
       //Local lAglutina  := .F.
       //Local lMostra    := .F.
       //Local lCtbOnline := .F.
       Local cQuery     := ""
       Local cTabSE5    := "SE5CONTRB"
       //Local cTabSIG    := "SE5CONTRB"
       //Local cTmpSIGFil := ""
       Local aStru      := {}
       Local nX         := 0
       Local cCampo     := ""
       //Local cCpoIGE5   := ""
       Local cChave     := ""
       //Local aCpoSE5    := {}
       Local aArea      := GetArea()
       Local cTmpSE5Fil := ""
       Local cTipoCH    := IIF( Type( "MVCHEQUES" ) == "C", MVCHEQUES, MVCHEQUE )
       Local cSA6Emp    := FWModeAccess( "SA6", 1 )
       Local cSA6UNe    := FWModeAccess( "SA6", 2 )
       Local cSA6Fil    := FWModeAccess( "SA6", 3 )
       Local cNoCampos  := ''

       /*aAdd( aCpoSE5, { "IG_FILIAL", "E5_FILIAL"  } )
       aAdd( aCpoSE5, { "IG_CARTER", "E5_RECPAG"  } )
       aAdd( aCpoSE5, { "IG_DTMOVI", "E5_DTDISPO" } )
       aAdd( aCpoSE5, { "BANCO"    , "E5_BANCO"   } )
       aAdd( aCpoSE5, { "IG_AGEMOV", "E5_AGENCIA" } )
       aAdd( aCpoSE5, { "IG_CONMOV", "E5_CONTA"   } )
       aAdd( aCpoSE5, { "IG_DOCMOV", "E5_NUMCHEQ" } )
       aAdd( aCpoSE5, { "IG_VLRMOV", "E5_VALOR"   } )
       aAdd( aCpoSE5, { "IG_HISMOV", "E5_HISTOR"  } )*/

       cChave := "E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+DTOS(E5_DTDISPO)"
       _aItSE5 := {}
       
       cQuery += 	  " SELECT      "   + CRLF
       cQuery +=     " E5_FILIAL , "   + CRLF
       cQuery +=     " E5_RECPAG , "   + CRLF
       cQuery +=     " E5_DTDISPO,	"   + CRLF
       cQuery +=     " E5_BANCO  , "   + CRLF
       cQuery +=     " E5_AGENCIA,	"   + CRLF
       cQuery +=     " E5_CONTA  ,	"   + CRLF
       cQuery +=     " E5_NUMCHEQ,	"   + CRLF
       cQuery +=     " E5_VALOR  ,	"   + CRLF
       cQuery +=     " E5_HISTOR ,	"   + CRLF
       cQuery +=     " E5_MOTBX  ,	"   + CRLF
       cQuery +=     " E5_TIPODOC,	"   + CRLF
       cQuery +=     " E5_PREFIXO, "   + CRLF
       cQuery +=     " E5_NUMERO , "   + CRLF
       cQuery +=     " E5_PARCELA, "   + CRLF
       cQuery +=     " E5_TIPO   , "   + CRLF
       cQuery +=     " E5_CLIFOR , "   + CRLF
       cQuery +=     " E5_LOJA   , "   + CRLF
       cQuery +=     " E5_SEQ    , "   + CRLF
       cQuery +=     " E5_SITUACA, "   + CRLF
       cQuery +=     " E5_DATA   , "   + CRLF
       cQuery +=     " E5_MOEDA  , "   + CRLF
       cQuery +=     " E5_NATUREZ, "   + CRLF
       cQuery +=     " E5_DOCUMEN, "   + CRLF
       cQuery +=     " E5_RECONC, "   + CRLF
       cQuery +=     " SE5.R_E_C_N_O_ RECONSE5 ,   "   + CRLF
       cQuery +=     " E5_NUMCHEQ,  "   + CRLF
       cQuery +=     " E5_SEQCON "   + CRLF
       cQuery += " FROM " + RetSqlName("SE5") + " SE5 " + CRLF
       cQuery += " WHERE " + CRLF
       If ( cSA6Emp <>  "C" .Or. cSA6UNe <> "C" .Or. cSA6Fil <> "C") .Or. mv_par06 == 1 //mv_par09 == 1
          cQuery += "     E5_FILIAL " + GetRngFil( __aSelFil, "SE5", .T., @cTmpSE5Fil ) + " AND " + CRLF
       EndIf
       cQuery += 		 " E5_DTDISPO >= '" + DTOS(dDataDe) + "' AND " + CRLF
       cQuery += 		 " E5_DTDISPO <= '" + DTOS(dDataAte) + "' AND " + CRLF
       cQuery += 		 " E5_BANCO = '" + cBanco + "' AND " + CRLF
       cQuery += 		 " E5_AGENCIA = '" + cAgencia + "' AND " + CRLF
       cQuery += 		 " E5_CONTA   = '" + cConta + "' AND " + CRLF
       cQuery += 		 " E5_SITUACA <> 'C' AND " + CRLF
       cQuery += 		 " E5_DTCANBX = ' ' AND " + CRLF
       cQuery += 		 " UPPER( E5_HISTOR ) NOT LIKE('ESTORNO%') AND " + CRLF
       cQuery += 		 " E5_TIPODOC<> 'TE' AND " + CRLF
       //cQuery += 		 " E5_RECONC = ' ' AND " + CRLF
       cQuery += 		 " E5_TIPODOC NOT IN " + FormatIn("BA/DC/JR/MT/CM/D2/J2/M2/C2/V2/CP/TL","/") + " AND " + CRLF
       cQuery += 		 " E5_VALOR > 0 AND " + CRLF
       cQuery += 		 "(E5_MOEDA NOT IN " + FormatIn("C1/C2/C3/C4/C5/CH","/") + " OR (E5_MOEDA IN " + FormatIn("C1/C2/C3/C4/C5/CH","/") + " AND E5_NUMCHEQ <> ' ')) AND "
       cQuery += 		 "(E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) AND "   + CRLF
       cQuery += 		 "((E5_TIPODOC  IN "+ FormatIn(cTipoCH,"|") + "AND  E5_DTDISPO BETWEEN  '" + DTOS(dDataDe)+ "' AND '"  + DTOS(dDataAte) +"' ) OR "   + CRLF
       cQuery += 		 "(E5_TIPODOC   NOT IN "+ FormatIn(cTipoCH,"|") + "AND  E5_DTDISPO BETWEEN  '" + DTOS(dDataDe)+ "' AND '"  + DTOS(dDataAte) +"' )) AND "   + CRLF
       cQuery += 		 "(E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) AND "   + CRLF
       cQuery += 		 "D_E_L_E_T_ = ' ' " + CRLF
       If mv_par07 == 2
          cQuery += " AND E5_RECONC <> 'x' " + CRLF
       elseIf mv_par07 == 3
              cQuery += " AND E5_RECONC = 'x' " + CRLF
       Endif
       
       cQuery += 		 "ORDER BY " + SqlOrder(cChave)
       cQuery := ChangeQuery(cQuery)

       aAdd( __aTmpFil, cTmpSE5Fil )

       dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cTabSE5, .T., .T. )

       aStru := SE5->(dbStruct())

       For nX :=  1 To Len(aStru)
           If aStru[nX][2] <> "C" .And. SE5->(FieldPos(aStru[nX][1])) > 0
              TcSetField(cTabSE5,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
           EndIf
           If (cTabSE5)->(FieldPos(aStru[nX][1])) == 0
              cNoCampos += '/' + aStru[nX][1]       
           Endif
       Next nX

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Inicia a leitura do arquivo   ³
       //³ de movimentacao do SE5        ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       While (cTabSE5)->(!(Eof()))
             aAux := Nil
             aAux := Array( Len( aCpoSE5 ) )
             aAdd( aAux, "" )
             If !Empty( (cTabSE5)->E5_MOTBX ) .and. !MovBcoBx((cTabSE5)->E5_MOTBX)
                (cTabSE5)->(dbSkip())
                Loop
             EndIF

             cChaveBx := (cTabSE5)->E5_PREFIXO+(cTabSE5)->E5_NUMERO+(cTabSE5)->E5_PARCELA+(cTabSE5)->E5_TIPO+(cTabSE5)->E5_CLIFOR+(cTabSE5)->E5_LOJA+(cTabSE5)->E5_SEQ 

             If (cTabSE5)->E5_SITUACA $ "E|X|C" .or. (!Empty(cChaveBx) .And. Empty((cTabSE5)->E5_NUMCHEQ) .And. TemBxCanc(cChaveBx,,(cTabSE5)->E5_FILIAL))
                (cTabSE5)->( dbskip())
                loop
             EndIf

             If (cTabSE5)->E5_TIPODOC = "CH"    //Emissão de Cheque
                If SEF->(dbSeek((cTabSE5)->E5_FILIAL +(cTabSE5)->E5_BANCO+(cTabSE5)->E5_AGENCIA+(cTabSE5)->E5_CONTA+(cTabSE5)->E5_NUMCHEQ))
                   If SEF->EF_IMPRESS = "C"
                      (cTabSE5)->(dbSkip())
                      Loop
                   EndIF
                EndIF
             EndIF
             For nX := 1 to Len( aCpoSE5 )
                 If !( aCpoSE5[nX] $ ("COR/SEQDIG/RECSE5/DESCONC/E5_USERLGI/MOV_MARK/E5_X_REPA/SE5_SOMA/REC_NO/E5_X_JAGR/E5_X_BDES/E5_X_ADES/E5_X_CDES/E5_X_NDES/E5_X_ORIG/E5_X_BORI/E5_X_AORI/E5_X_CORI/E5_X_NORI") )
                    cCampo   := aCpoSE5[nX]
                    If cCampo == 'IG_STATUS' .AND. !Empty((cTabSE5)->RECONC) // Caso o movimento tenha sido Reconciliado anteriormente
                       aAux[nX] := '4'
                    Else
                       If !Empty(cNoCampos)
                          If !(cCampo $ cNoCampos) 
                             aAux[nX] := (cTabSE5)->&(cCampo)
                          Endif
                       Else
                          aAux[nX] := (cTabSE5)->&(cCampo)
                       Endif	
                    EndIf
                 ElseIf Alltrim(aCpoSE5[nX]) $ "E5_X_BDES.E5_X_ADES.E5_X_CDES.E5_X_NDES.E5_X_ORIG.E5_X_BORI.E5_X_AORI.E5_X_CORI.E5_X_NORI"
                        aAux[nX] := ''
                 ElseIf Alltrim(aCpoSE5[nX]) $ "E5_X_JAGR"
                        aAux[nX] := Iif( (cTabSE5)->E5_RECONC == 'x', 'S', '' )
                 ElseIf Alltrim(aCpoSE5[nX]) == "E5_SEQCON"
                        aAux[nX] := ''
                 ElseIf Alltrim(aCpoSE5[nX]) == "REC_NO"
                        aAux[nX] := (cTabSE5)->RECONSE5
                 ElseIf Alltrim(aCpoSE5[nX]) == "E5_X_REPA"
                        aAux[nX] := (cTabSE5)->E5_RECPAG
                 ElseIf Alltrim(aCpoSE5[nX]) == "SE5_SOMA"
                        aAux[nX] := Iif( (cTabSE5)->E5_RECPAG == 'R', 1, -1 ) * (cTabSE5)->E5_VALOR
                 ElseIf Alltrim(aCpoSE5[nX]) == "MOV_MARK"
                        aAux[nX] := Iif( Empty( (cTabSE5)->E5_RECONC ), .f., .t. )
                 ElseIf Alltrim(aCpoSE5[nX]) == "RECSE5"
                        aAux[nX] := 0
                 EndIf
             Next nX
             aAdd(aRet,{0 ,aAux })

             (cTabSE5)->(dbSkip())
       Enddo
       (cTabSE5)->(dbCloseArea())
       RestArea(aArea)

Return

Static Function FSE5Rec( cSeqMov )
       Local nRecno  := 0
       Local aArea   := GetArea()
       Local cQuery  := ""
       Local cTabSE5 := "SIGREC"

       cQuery := " "
       cQuery += " SELECT "
       cQuery += " R_E_C_N_O_ SE5REC "
       cQuery += " FROM " + RetSQLName("SE5") + " SE5 "
       cQuery += " WHERE "
       cQuery += " E5_SEQCON = '" + cSeqMov + "' AND " // Nao tem filial pois o SEQCON é único para o grupo da empresa
       cQuery += " SE5.D_E_L_E_T_ = ' ' "
       cQuery := ChangeQuery(cQuery)

       dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabSE5,.T.,.T.)

       If (cTabSE5)->(!EOF())
          nRecno := (cTabSE5)->SE5REC
       EndIf
       (cTabSE5)->(dbCloseArea())

       RestArea(aArea)
Return nRecno

Static Function fMontaTMP( _aCampos, _cAlias, _objTbl )
       If Select( _cAlias ) > 0
          DbSelectArea( _cAlias )
          DbCloseArea()
       Endif
       _oObjTbl := FWTemporaryTable():New( _cAlias )
       _oObjTbl:SetFields( _aCampos )
       _oObjTbl:Create()
Return

Static Function fLegenda()
       Local _oDlg2
       Local _lRet   := .T.
       Local _oModel := FWModelActive()

       DEFINE MSDIALOG _oDlg2 FROM  69,70 TO 200,331 TITLE "Legenda - Reconciliação Automática" PIXEL
              @ 05 , 5 BITMAP NAME "BR_VERDE" 		SIZE 8,8 of _oDlg2 PIXEL
              @ 15 , 5 BITMAP NAME "BR_AMARELO" 		SIZE 8,8 of _oDlg2 PIXEL
              @ 25 , 5 BITMAP NAME "BR_AZUL" 		SIZE 8,8 of _oDlg2 PIXEL
              @ 35 , 5 BITMAP NAME "DISABLE" 			SIZE 8,8 of _oDlg2 PIXEL
              //@ 45 , 5 BITMAP NAME "BR_CANCEL"		SIZE 8,8 of _oDlg2 PIXEL
              //@ 55 , 5 BITMAP NAME "BR_PINK"			SIZE 8,8 of _oDlg2 PIXEL
              @ 05 , 19 SAY "  Reconciliado"                      SIZE 115, 7 OF _oDlg2 PIXEL
              @ 15 , 19 SAY "  Reconciliado Parcial"              SIZE 100, 7 OF _oDlg2 PIXEL
              @ 25 , 19 SAY "  Reconciliado Lançado"        SIZE 100, 7 OF _oDlg2 PIXEL
              @ 35 , 19 SAY "  Não Reconciliado"                  SIZE 100, 7 OF _oDlg2 PIXEL
              //@ 45 , 19 SAY "  Ignorado pelo usuário"             SIZE 100, 7 OF _oDlg2 PIXEL
              //@ 55 , 19 SAY "  Ignorado conciliado anteriormente" SIZE 100, 7 OF _oDlg2 PIXEL
              DEFINE SBUTTON FROM 20, 100 TYPE 1 ENABLE ACTION ( _oDlg2:End() ) OF _oDlg2
       ACTIVATE MSDIALOG _oDlg2 CENTERED
       _oModel:GetModel("GRIDEXTR"):GoLine(1)
Return _lRet

User Function fZeraStat( aSelFil )
         Default aSelFil := { cFilAnt }
         __lConManual := .F.
         __nHdlPrv    := 0
         __cArquivo   := ""
         __nTotal     := 0
         __cLote      := ""
         __aFlagCTB   := {}
         __aSelFil    := aSelFil
         __aTmpFil    := {}
         __aRecCtb    := {}
         __lFK5Fil    := !( 'C' $ FWModeAccess( "SA6", 1 ) + FWModeAccess( "SA6", 2 ) + FWModeAccess( "SA6", 3 ) ) .Or. mv_par06 == 1 //mv_par09 == 1
Return

Static Function FActionExt( oView, cIDView, cField, xValue, _cGrid )
       Local _lRet      := .T.
       Local _oModel    := FWModelActive()
       Local _oModelExt as Object
       Local _oModelMOV as Object
       Local _nLineEXT  as Numeric
       Local _nLineMOV  as Numeric
       Local _nX
       
       _oModelExt := _oModel:GetModel('GRIDEXTR')
       _oModelMOV := _oModel:GetModel('GRIDMOVI')
       _nLineMOV  := _oModelMov:nLine
       _nLineExt  := _oModelExt:nLine

       //Guardo posicionamento dos campos do Movimento e monto chave de busca
       nSE5Data := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_DTDISPO' } )
       nSE5Age  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_AGENCIA' } )
       nSE5Conta:= aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_CONTA'   } )
       nSE5Num  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_NUMCHEQ' } )
       nSE5Valor:= aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_VALOR'   } )
       nSE5Deb  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_RECPAG'  } )
       nSE5His  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_HISTOR'  } )
       nSE5Nat  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_NATUREZ' } )
       nSE5Fil  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_FILIAL'  } )
       nSE5Rec  := aScan( _oModelMov:aHeader, { |x| x[2] == 'REC_NO'     } )
       nSE5Mark := aScan( _oModelMov:aHeader, { |x| x[2] == 'MOV_MARK'   } )

       _cChaveSE5 := Alltrim( DTOS( _oModelMov:aCols[_nLineMov][nSE5Data] ) ) + Alltrim( _oModelMov:aCols[_nLineMov][nSE5Age] ) +;
                     Alltrim( _oModelMov:aCols[_nLineMov][nSE5Conta]  )       + Alltrim( _oModelMov:aCols[_nLineMov][nSE5Num] ) +;
                     Alltrim( STR( _oModelMov:aCols[_nLineMov][nSE5Valor] ) ) + Alltrim( _oModelMov:aCols[_nLineMov][nSE5Deb] )

       //Guardo posicionamento dos campos do Extrato e monto chave de busca
       nSIGData  := aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_DTEXTR' } )
       nSIGAge   := aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_AGEEXT' } )
       nSIGConta := aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CONEXT' } )
       nSIGNum   := aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_DTEXTR' } )
       nSIGValor := aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_VLREXT' } )
       nSIGDeb   := aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CARTER' } )
       nSIGMark  := aScan( _oModelExt:aHeader, { |x| x[2] == 'EXT_MARK'  } )

       _cChaveSIG := Alltrim( DTOS( _oModelExt:aCols[_nLineExt][nSIGData] ) ) + Alltrim( _oModelExt:aCols[_nLineExt][nSIGAge] ) +;
                     Alltrim( _oModelExt:aCols[_nLineExt][nSIGConta]  )       + Alltrim( _oModelExt:aCols[_nLineExt][nSIGNum] ) +;
                     Alltrim( STR( _oModelExt:aCols[_nLineExt][nSIGValor] ) ) + Iif( Alltrim( _oModelExt:aCols[_nLineExt][nSIGDeb] ) == '1', 'R', 'P' )

       If _cGrid == 'EXT' //Verifico se a marcação vem do EXT=Extrado ou MOV=Movimento
          If cField $ 'EXT_MARK'
             _nPosSE5 := aScan( _oModelMov:aCols, { |aItem| Alltrim( DTOS( aItem[nSE5Data] ) ) + Alltrim( aItem[nSE5Age] ) + Alltrim( aItem[nSE5Conta] ) + Alltrim( aItem[nSE5Num] ) + Alltrim( STR( aItem[nSE5Valor] ) ) + Alltrim( Iif( aItem[nSE5Deb]  == '1', 'R', 'P' ) ) == _cChaveSIG  } )
             If xValue //Marcado o conteudo passa a ser verdadeiro
                If _nPosSE5 > 0 //Encontrou um movimento (um para um)
                   _oModelMov:GoLine( _nPosSE5 ) //Posiciono no movimento
                   If _oModelMov:GetValue( 'MOV_MARK' )
                      //Mudo Status do movimento
                      _oModelMov:SetValue( 'COR'      , u_FRETCOR( '3' ) )
                      _oModelMov:SetValue( 'E5_SEQCON', _oModelExt:GetValue( 'IG_SEQMOV' ) )
                      //Gravo informações de amarração do Movimento para o extrato
                      _oModelExt:SetValue( 'COR', u_FRETCOR( '3' ) )
                      _oModelExt:SetValue( 'IG_DTMOVI' , _oModelMov:aCols[_nLineMov][nSE5Data] )
                      _oModelExt:SetValue( 'IG_AGEMOV' , _oModelMov:aCols[_nLineMov][nSE5Age]  )
                      _oModelExt:SetValue( 'IG_CONMOV' , _oModelMov:aCols[_nLineMov][nSE5Conta])
                      _oModelExt:SetValue( 'IG_DOCMOV' , _oModelMov:aCols[_nLineMov][nSE5Num]  )
                      _oModelExt:SetValue( 'IG_VLRMOV' , _oModelMov:aCols[_nLineMov][nSE5Valor])
                      _oModelExt:SetValue( 'IG_HISMOV' , _oModelMov:aCols[_nLineMov][nSE5His]  )
                      _oModelExt:SetValue( 'IG_NATMOV' , _oModelMov:aCols[_nLineMov][nSE5Nat]  )
                      _oModelExt:SetValue( 'RECSE5'    , _oModelMov:aCols[_nLineMov][nSE5Rec]  )
                      _oModelExt:SetValue( 'IG_FILORIG', _oModelMov:aCols[_nLineMov][nSE5Fil]  )
                      _oModelExt:SetValue( 'IG_STATUS' , '3'                                   )
                      //_oModelExt:SetValue( 'IG_EFETIVA', ' '                                   )
                   else
                      _oModelExt:SetValue( 'COR'      , u_FRETCOR( '2' ) )
                   Endif
                else
                   //**********************************************************************/
                   //** Marcação de itens sem vinculo                                    **/
                   If aScan( _aConCNN, { |x| x[4] == '' } ) == 0 .or. Len( _aConcNN ) == 0
                      _cChave := GetMV( "ZP_PAR0020" )
                      PutMV( "ZP_PAR0020", Soma1( _cChave ) )
                   Endif
                   _oModelExt:SetValue( 'COR', u_FRETCOR( '2' ) )
                   _nPosCon := aScan( _aConcNN, { |x| x[1] == _oModelExt:GetValue( 'IG_SEQMOV' ) } ) //Procuro pelo Identificador no array de conciliação N x N
                   _nFator  := Iif( _oModelExt:GetValue( 'IG_CARTER' ) == '1', 1, -1 )
                   If _nPosCon == 0 .and. Len( _aConcNN ) <= 0
                      _cChave := 'C' + _cChave
                      aAdd( _aConcNN, { _cChave, ( _oModelExt:GetValue( 'IG_VLREXT' ) * _nFator ), 0, '', { { _oModelExt:GetValue( 'IG_SEQMOV' ), _oModelExt:GetValue( 'IG_VLREXT' ), _oModelExt:nLine } }, {} } )
                      _oModelExt:SetValue( 'IG_SEQMOV', _cChave )
                   else
                      //Procuro se existem movimentos em aberto
                       _lAchou := .f.
                       For _nX := 1 To Len( _aConcNN )
                           If Empty( _aConcNN[_nX][4] )
                              _lAchou := .t.
                              _nAchou := _nX
                              _aConcNN[_nX][2] += ( _oModelExt:GetValue( 'IG_VLREXT' ) * _nFator )
                              aAdd( _aConcNN[_nX][5], { _oModelExt:GetValue( 'IG_SEQMOV' ), _oModelExt:GetValue( 'IG_VLREXT' ), _oModelExt:nLine } )
                              _oModelExt:SetValue( 'IG_SEQMOV', _aConcNN[_nX][1] )
                           Endif
                       Next
                       If !_lAchou
                          _cChave := GetMV( "ZP_PAR0020" )
                          PutMV( "ZP_PAR0020", Soma1( _cChave ) )
                          _cChave := 'C' + _cChave
                          aAdd( _aConcNN, { _cChave, ( _oModelExt:GetValue( 'IG_VLREXT' ) * _nFator ), 0, '', { { _oModelExt:GetValue( 'IG_SEQMOV' ), _oModelExt:GetValue( 'IG_VLREXT' ), _oModelExt:nLine } }, {} } )
                          _oModelExt:SetValue( 'IG_SEQMOV', _cChave )
                       Else
                          If _aConcNN[_nAchou][2] == _aConcNN[_nAchou][3] //Se a soma for igual, mudar o Flag
                             For _nX := 1 To Len( _aConcNN[_nAchou][5] ) //Ajusto flag para o extrato
                                 _oModelExt:GoLine( _aConcNN[_nAchou][5][_nX][3] )
                                 _oModelExt:SetValue( 'COR', u_FRETCOR( '3' ) )
                             Next
                             _oModelExt:GoLine( 1 )
                             For _nX := 1 To Len( _aConcNN[_nAchou][6] ) //Ajusto flag para o movimento
                                 _oModelMov:GoLine( _aConcNN[_nAchou][6][_nX][3] )
                                 _oModelMov:SetValue( 'COR', u_FRETCOR( '3' ) )
                             Next
                             _oModelMov:GoLine( 1 )
                          Endif
                       Endif
                   Endif
                Endif
             else
                //**********************************************************************/
                //** Verifico se o item já está efetivo e se trata de desconciliação. **/
                If _oModelExt:GetValue('IG_EFETIVA') == '1'
                   If MessageBox( 'Esse item já foi conciliado anteriormente, deseja desconciliar?', 'Desconciliação', 4 ) == 6
                      _lDesCon := .T.
                      _nLinAtu := _oModelExt:nLine
                      _cSeqExt := _oModelExt:GetValue( 'IG_SEQMOV')
                      For _nX := 1 To _oModelExt:Length()
                          _oModelExt:GoLine( _nX )
                          If _oModelExt:GetValue( 'IG_SEQMOV') == _cSeqExt
                             _oModelExt:SetValue( 'EXT_MARK'  , .f.                )
                             _oModelExt:SetValue( 'COR'       , u_FRETCOR( '1' )   )
                             _oModelExt:SetValue( 'IG_DTMOVI' , CTOD( '  /  /  ' ) )
                             _oModelExt:SetValue( 'IG_AGEMOV' , ''                 )
                             _oModelExt:SetValue( 'IG_CONMOV' , ''                 )
                             _oModelExt:SetValue( 'IG_DOCMOV' , ''                 )
                             _oModelExt:SetValue( 'IG_VLRMOV' , 0                  )
                             _oModelExt:SetValue( 'IG_HISMOV' , ''                 )
                             _oModelExt:SetValue( 'IG_NATMOV' , ''                 )
                             _oModelExt:SetValue( 'IG_STATUS' , '1'                )
                             //_oModelExt:SetValue( 'IG_EFETIVA', '2'                )
                             _oModelExt:SetValue( 'DESCONC'   , '1'                )
                          Endif
                      Next
                      For _nX := 1 To _oModelMov:Length()
                          _oModelMov:GoLine( _nX )
                          If _oModelMov:GetValue( 'E5_SEQCON') == _cSeqExt
                             _oModelMov:SetValue( 'MOV_MARK' , .f.              )
                             _oModelMov:SetValue( 'COR'      , u_FRETCOR( '1' ) )
                             _oModelMov:SetValue( 'E5_RECONC', ''               )
                          Endif
                      Next
                      _oModelExt:GoLine( _nLinAtu )
                   Else
                      _oModelExt:SetValue( 'EXT_MARK', .t. )
                   Endif
                   //**********************************************************************/
                Else 
                //**********************************************************************/
                //** Desmarcação de itens sem vinculo                                 **/
                   _oModelExt:SetValue( 'COR'       , u_FRETCOR( '1' ) )
                   If _nPosSE5 > 0
                      _oModelMov:GoLine( _nPosSE5 )
                      If _oModelMov:GetValue( 'MOV_MARK' )
                         _oModelMov:SetValue( 'COR'       , u_FRETCOR( '1' ) )
                      Endif
                   Else
                      _nPosStat := aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_STATUS' } )
                      _nPosEfet := aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_EFETIVA' } )
                      If _oModelExt:aCols[_oModelExt:nLine][_nPosStat] == '3' .and. _oModelExt:aCols[_oModelExt:nLine][_nPosEfet] == '1' //Verifico se é desconciliação
                         If Len( _aConcNN ) <= 0
                            aAdd( _aConcNN, { _oModelExt:GetValue( 'IG_SEQMOV' ), 0, 0, '', { { _oModelExt:GetValue( 'IG_SEQMOV' ), _oModelExt:GetValue( 'IG_VLREXT' ), _oModelExt:nLine } }, {} } )
                            _oModelExt:SetValue( 'IG_STATUS' , '1' )
                            //_oModelExt:SetValue( 'IG_EFETIVA', ' ' )
                            _oModelExt:SetValue( 'DESCONC'   , '1' )
                         else
                            
                         endif
                      Endif
                      _nSeqCon := aScan( _aConcNN, { |x| x[1] == _oModelExt:GetValue( 'IG_SEQMOV' ) } )
                      _aConcNN[_nSeqCon][2] -= Iif( _oModelExt:GetValue( 'IG_CARTER' ) == '1', _oModelExt:GetValue( 'IG_VLREXT' ), _oModelExt:GetValue( 'IG_VLREXT' ) * -1 )
                      _aConcNN[_nSeqCon][4] := ''
                      _nPosSIG := aScan( _aConcNN[_nSeqCon][5], { |x| x[3] == _oModelExt:nLine } )
                      _nQtdSIG := Len( _aConcNN[_nSeqCon][5] ) 
                      aDel( _aConcNN[_nSeqCon][5], _nPosSIG )
                      aSize( _aConcNN[_nSeqCon][5], _nQtdSIG - 1 )
                      For _nX := 1 To Len( _aConcNN[_nSeqCon][5] ) //Ajusto flag para o extrato
                          _oModelExt:GoLine( _aConcNN[_nSeqCon][5][_nX][3] )
                          _oModelExt:SetValue( 'COR', u_FRETCOR( '2' ) )
                      Next
                      For _nX := 1 To Len( _aConcNN[_nSeqCon][6] ) //Ajusto flag para o movimento
                          _oModelMov:GoLine( _aConcNN[_nSeqCon][6][_nX][3] )
                          _oModelMov:SetValue( 'COR', u_FRETCOR( '2' ) )
                      Next
                      If _aConcNN[_nSeqCon][2] == 0 .and. _aConcNN[_nSeqCon][3] == 0
                         If Len( _aConcNN ) == 1
                            _aConcNN := {}
                         Else
                            aDel( _aConcNN[_nSeqCon], _nSeqCon )
                            aSize( _aConcNN[_nSeqCon], _nSeqCon - 1 )
                         Endif
                      Endif
                      _oModelMov:GoLine( 1 )
                   Endif
                Endif
             Endif
          Endif
       Else
          If cField $ 'MOV_MARK'
             _nPosSIG := aScan( _oModelExt:aCols, { |aItem| Alltrim( DTOS( aItem[nSIGData] ) ) + Alltrim( aItem[nSIGAge] ) + Alltrim( aItem[nSIGConta] ) + Alltrim( aItem[nSIGNum] ) + Alltrim( STR( aItem[nSIGValor] ) ) + Alltrim( Iif( aItem[nSIGDeb]  == '1', 'R', 'P' ) ) == _cChaveSE5  } )
             If xValue //Marcado o conteudo passa a ser verdadeiro
                If _nPosSIG > 0
                   _oModelExt:GoLine( _nPosSIG )
                   If _oModelExt:GetValue( 'EXT_MARK' )
                      _oModelMov:SetValue( 'COR'      , u_FRETCOR( '3' ) )
                      _oModelMov:SetValue( 'E5_SEQCON', _oModelExt:GetValue( 'IG_SEQMOV' ) )
                      _oModelExt:SetValue( 'COR', u_FRETCOR( '3' ) )
                      _oModelExt:SetValue( 'IG_DTMOVI' , _oModelMov:aCols[_nLineMov][nSE5Data] )
                      _oModelExt:SetValue( 'IG_AGEMOV' , _oModelMov:aCols[_nLineMov][nSE5Age]  )
                      _oModelExt:SetValue( 'IG_CONMOV' , _oModelMov:aCols[_nLineMov][nSE5Conta])
                      _oModelExt:SetValue( 'IG_DOCMOV' , _oModelMov:aCols[_nLineMov][nSE5Num]  )
                      _oModelExt:SetValue( 'IG_VLRMOV' , _oModelMov:aCols[_nLineMov][nSE5Valor])
                      _oModelExt:SetValue( 'IG_HISMOV' , _oModelMov:aCols[_nLineMov][nSE5His]  )
                      _oModelExt:SetValue( 'IG_NATMOV' , _oModelMov:aCols[_nLineMov][nSE5Nat]  )
                      //_oModelExt:SetValue( 'IG_SEQMOV' , _oModelMov:aCols[_nLineMov][nSE5Rec]  )
                      _oModelExt:SetValue( 'IG_FILORIG', _oModelMov:aCols[_nLineMov][nSE5Fil]  )
                      _oModelExt:SetValue( 'IG_STATUS' , '3'                                   )
                   else
                      _oModelMov:SetValue( 'COR'      , u_FRETCOR( '2' ) )
                   Endif
                else
                   //**********************************************************************/
                   //** Marcação de itens sem vinculo                                    **/
                   If _oModelMov:GetValue( 'E5_RECPAG' ) == 'R' //Receber
                      If Len( _aConcNN ) > 0 //Verifica se o array de somatorio está preenchido
                         _nPosCon := aScan( _aConcNN, { |x| x[4] == '' } ) //Verifica se existe posição em aberto para somatorio
                         If _nPosCon > 0
                            If _aConcNN[ _nPosCon][ 2 ] == ( _aConcNN[_nPosCon][3] + _oModelMov:GetValue( 'E5_VALOR' ) ) //Verifica se os saldos batem (se sim faz o ajuste de cores do flag)
                               For _nX := 1 To Len( _aConcNN[ _nPosCon][ 5 ] )
                                   _oModelExt:GoLine( _aConcNN[_nPosCon][5][_nX][3] )
                                   _oModelExt:SetValue( 'COR', u_FRETCOR( '3' ) )
                                   _oModelExt:SetValue( 'IG_STATUS' , '3' )
                               Next
                               _oModelExt:GoLine( 1 )
                               _oModelMov:SetValue( 'E5_SEQCON', _aConcNN[_nPosCon][1] )
                               _oModelMov:SetValue( 'COR', u_FRETCOR( '3' ) )
                               _aConcNN[_nPosCon][3] += _oModelMov:GetValue( 'E5_VALOR' )
                               _aConcNN[_nPosCon][4] := 'S'
                               aAdd(_aConcNN[_nPosCon][6], { _aConcNN[_nPosCon][1], _oModelMov:GetValue( 'E5_VALOR' ), _oModelMOV:nLine } )
                               For _nX := 1 To Len( _aConcNN[ _nPosCon][ 6 ] )
                                   _oModelMov:GoLine( _aConcNN[_nPosCon][6][_nX][3] )
                                   _oModelMov:SetValue( 'COR', u_FRETCOR( '3' ) )
                               Next
                               _oModelMov:GoLine( 1 )
                            else
                               _oModelMov:SetValue( 'COR', u_FRETCOR( '2' ) )
                               _oModelMov:SetValue( 'E5_SEQCON', _aConcNN[ _nPosCon][ 1 ] )
                               _aConcNN[_nPosCon][3] += _oModelMov:GetValue( 'E5_VALOR' )
                               aAdd( _aConcNN[_nPosCon][6], { _oModelMov:GetValue( 'REC_NO' ), _oModelMov:GetValue( 'E5_VALOR' ), _oModelMOV:nLine } )
                            Endif
                         else
                            _oModelMov:SetValue( 'MOV_MARK', .f. )
                            _lRet := .f.
                            Help( Nil, Nil, 'COMP_RECEBER', Nil, 'Atenção, movimento a receber sem referência direta.', 1, 0, Nil, Nil, Nil, Nil, .f., { "Marque primeiro um item do extrato." })
                         Endif
                      else
                         _lRet := .f.
                         _oModelMov:SetValue( 'MOV_MARK', .F. )
                         Help( Nil, Nil, 'COMP_RECEBER', Nil, 'Atenção, movimento a receber sem referência direta.', 1, 0, Nil, Nil, Nil, Nil, .f., { "Marque primeiro um item do extrato." })
                      Endif
                   Else //Pagar
                      If Len( _aConcNN ) > 0
                         _nPosCon := aScan( _aConcNN, { |x| x[4] == '' } ) //Verifica se existe posição em aberto para somatorio
                         If _nPosCon > 0
                            If _aConcNN[ _nPosCon][ 2 ] == ( _aConcNN[_nPosCon][3] - _oModelMov:GetValue( 'E5_VALOR' ) ) //Verifica se os saldos batem (se sim faz o ajuste de cores do flag)
                               _aConcNN[_nPosCon][3] -= _oModelMov:GetValue( 'E5_VALOR' )
                               _aConcNN[_nPosCon][4] := 'S'
                               aAdd(_aConcNN[_nPosCon][6], { _aConcNN[_nPosCon][1], _oModelMov:GetValue( 'E5_VALOR' ), _oModelMOV:nLine } )
                               For _nX := 1 To Len( _aConcNN[ _nPosCon][ 5 ] )
                                   _oModelExt:GoLine( _aConcNN[_nPosCon][5][_nX][3] )
                                   _oModelExt:SetValue( 'COR', u_FRETCOR( '3' ) )
                                   _oModelExt:SetValue( 'IG_STATUS' , '3' )
                               Next
                               _oModelExt:GoLine( 1 )
                               For _nX := 1 To Len( _aConcNN[ _nPosCon][ 6 ] )
                                    _oModelMov:GoLine( _aConcNN[_nPosCon][6][_nX][3] )
                                    _oModelMov:SetValue( 'E5_SEQCON', _aConcNN[_nPosCon][1] )
                                    _oModelMov:SetValue( 'COR', u_FRETCOR( '3' ) )
                               Next
                               _oModelExt:GoLine( 1 )
                            Else
                               _oModelMov:SetValue( 'E5_SEQCON', _aConcNN[_nPosCon][1] )
                               _oModelMov:SetValue( 'COR', u_FRETCOR( '2' ) )
                               aAdd(_aConcNN[_nPosCon][6], { _aConcNN[_nPosCon][1], _oModelMov:GetValue( 'E5_VALOR' ), _oModelMOV:nLine } )
                               _aConcNN[_nPosCon][3] -= _oModelMov:GetValue( 'E5_VALOR' )
                            Endif
                         else
                            _lRet := .f.
                            _oModelMov:SetValue( 'MOV_MARK', .F. )
                            Help( Nil, Nil, 'COMP_PAGAR', Nil, 'Atenção, movimento a pagar sem referência direta.', 1, 0, Nil, Nil, Nil, Nil, .f., { "Marque primeiro um item do extrato." })
                         Endif
                      else
                         _lRet := .f.
                         _oModelMov:SetValue( 'MOV_MARK', .F. )
                         Help( Nil, Nil, 'COMP_PAGAR', Nil, 'Atenção, movimento a pagar sem referência direta.', 1, 0, Nil, Nil, Nil, Nil, .f., { "Marque primeiro um item do extrato." })
                      Endif
                   Endif
                Endif
             Else 
             //**********************************************************************/
             //** Desmarcação de itens sem vinculo                                 **/
                _cSeqMov := _oModelMov:GetValue( 'E5_SEQCON')
                //aScan( _oModelExt:aHeader, { |x| x[2] == 'E5_SEQCON' } )
                _nPosExt := aScan( _oModelExt:aCols, { |x| x[ aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_SEQMOV' } ) ] == _cSeqMov } )
                //Verifico se o movimento já está conciliado e não permito
                If _oModelExt:aCols[ _nPosExt][ aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_EFETIVA' } ) ] == '1'
                   _oModelMov:SetValue( 'MOV_MARK', .T. )
                   MessageBox( 'Atenção, esse item já está conciliado. Para desconciliação, desmarque o grid do extrato.', 'Desconciliação', 64 )
                Else
                //**********************************************************************/
                //** Desmarcação de itens sem vinculo                                 **/
                   _nSeqCon := aScan( _aConcNN, { |x| x[1] == _oModelMov:GetValue( 'E5_SEQCON' ) } )
                   If _nSeqCon > 0
                      _oModelMov:SetValue( 'COR', u_FRETCOR( '1' ) )
                      _aConcNN[_nSeqCon][3] -= Iif( _oModelMov:GetValue( 'E5_RECPAG' ) == 'P', _oModelMov:GetValue( 'E5_VALOR' ) * -1, _oModelMov:GetValue( 'E5_VALOR' ) )
                      _aConcNN[_nSeqCon][4] := ''
                      _nPosSE5 := aScan( _aConcNN[_nSeqCon][6], { |x| x[3] == _oModelMov:nLine } )
                      _nQtdSE5 := Len( _aConcNN[_nSeqCon][6] )
                      aDel( _aConcNN[_nSeqCon][6], _nPosSE5 )
                      aSize( _aConcNN[_nSeqCon][6], _nQtdSE5 - 1 )
                      For _nX := 1 To Len( _aConcNN[_nSeqCon][6] ) //Ajusto flag para o movimento
                          _oModelMov:GoLine( _aConcNN[_nSeqCon][6][_nX][3] )
                          _oModelMov:SetValue( 'COR', u_FRETCOR( '2' ) )
                      Next
                      For _nX := 1 To Len( _aConcNN[_nSeqCon][5] ) //Ajusto flag para o Extrato
                          _oModelExt:GoLine( _aConcNN[_nSeqCon][5][_nX][3] )
                          _oModelExt:SetValue( 'COR', u_FRETCOR( '2' ) )
                          _oModelExt:SetValue( 'IG_STATUS' , '3' )
                      Next
                      _oModelExt:GoLine( 1 )
                   Endif
                Endif
             Endif
          ElseIf cField $ 'E5_BENEF'
          Endif
       Endif
       oView:Refresh( 'GRIDEXTR' )
       oView:Refresh( 'GRIDMOVI' )
Return _lRet

/*/{Protheus.doc} fConAuto
Função utilizada para conciliação automática
Movimentos: 1 - Pagar(F6)   - Concilia movimentos a pagar com mesma chave extrato x movimento
            2 - Receber(F7) - Concilia movimentos a receber a partir de movimentos marcados no extrato.
@type function
@version 
@author Luís Gustavo de Souza
@since 10/09/2020
@param oView, object, Objeto da View
@param _xOpc, Numeric, Parametro que indica a Carteira: 1-Pagar / 2-Receber
@return Nil, Sem retorno para essa função.
/*/
Static Function fConAuto( oView, _xOpc )
       Local _oView  as Object
       Local _oModel as Object
       Local _oModelExt as Object
       Local _oModelMOV as Object
       Local _nX, _nY
       
       If mv_par07 == 2 //Não conciliados
          _oModel := FWModelActive()
          _oView  := Iif( ValType( oView ) == 'O', oView, FWViewActive() )
          _oModelExt := _oModel:GetModel('GRIDEXTR')
          _oModelMOV := _oModel:GetModel('GRIDMOVI')

          //Guardo posicionamento dos campos do Movimento e monto chave de busca
          nSE5Data := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_DTDISPO' } )
          nSE5Age  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_AGENCIA' } )
          nSE5Conta:= aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_CONTA'   } )
          nSE5Num  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_NUMCHEQ' } )
          nSE5Valor:= aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_VALOR'   } )
          nSE5Deb  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_RECPAG'  } )
          nSE5His  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_HISTOR'  } )
          nSE5Nat  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_NATUREZ' } )
          nSE5Fil  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_FILIAL'  } )
          nSE5Rec  := aScan( _oModelMov:aHeader, { |x| x[2] == 'REC_NO'     } )
          nSE5Mark := aScan( _oModelMov:aHeader, { |x| x[2] == 'MOV_MARK'   } )
          nSE5Doc  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_DOCUMEN' } )

          //Guardo posicionamento dos campos do Extrato e monto chave de busca
          nSIGData  := aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_DTEXTR' } )
          nSIGAge   := aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_AGEEXT' } )
          nSIGConta := aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CONEXT' } )
          nSIGNum   := aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_DTEXTR' } )
          nSIGValor := aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_VLREXT' } )
          nSIGDeb   := aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CARTER' } )
          nSIGSeqM  := aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_SEQMOV' } )
          nSIGMark  := aScan( _oModelExt:aHeader, { |x| x[2] == 'EXT_MARK'  } )

          If _xOpc == 1 //A Pagar
             /*_cChaveSIG := Alltrim( DTOS( _oModelExt:aCols[_nLineExt][nSIGData] ) ) + Alltrim( _oModelExt:aCols[_nLineExt][nSIGAge] ) +;
                           Alltrim( _oModelExt:aCols[_nLineExt][nSIGConta]  )       + Alltrim( _oModelExt:aCols[_nLineExt][nSIGNum] ) +;
                           Alltrim( STR( _oModelExt:aCols[_nLineExt][nSIGValor] ) ) + Iif( Alltrim( _oModelExt:aCols[_nLineExt][nSIGDeb] ) == '1', 'R', 'P' )       */
             For _nX := 1 To _oModelExt:Length()
                 /*_cChaveSE5 := Alltrim( DTOS( _oModelMov:aCols[_nX][nSE5Data] ) ) + Alltrim( _oModelMov:aCols[_nX][nSE5Age] ) +;
                               Alltrim( _oModelMov:aCols[_nX][nSE5Conta]  )       + Alltrim( _oModelMov:aCols[_nX][nSE5Num] ) +;
                               Alltrim( STR( _oModelMov:aCols[_nX][nSE5Valor] ) ) + Alltrim( _oModelMov:aCols[_nX][nSE5Deb] )*/
                 _cChaveSIG := Alltrim( DTOS( _oModelExt:aCols[_nX][nSIGData] ) ) + Alltrim( _oModelExt:aCols[_nX][nSIGAge] ) +;
                               Alltrim( _oModelExt:aCols[_nX][nSIGConta]  )       + Alltrim( _oModelExt:aCols[_nX][nSIGNum] ) +;
                               Alltrim( STR( _oModelExt:aCols[_nX][nSIGValor] ) ) + Iif( Alltrim( _oModelExt:aCols[_nX][nSIGDeb] ) == '1', 'R', 'P' )
                 For _nY := 1 To _oModelMov:Length()
                     //_nPosSIG := aScan( _oModelExt:aCols, { |aItem| Alltrim( DTOS( aItem[nSIGData] ) ) + Alltrim( aItem[nSIGAge] ) + Alltrim( aItem[nSIGConta] ) + Alltrim( aItem[nSIGNum] ) + Alltrim( STR( aItem[nSIGValor] ) ) + Alltrim( Iif( aItem[nSIGDeb]  == '1', 'R', 'P' ) ) == _cChaveSE5  } )
                     _nPosSE5 := aScan( _oModelMov:aCols, { |aItem| Alltrim( DTOS( aItem[nSE5Data] ) ) + Alltrim( aItem[nSE5Age] ) + Alltrim( aItem[nSE5Conta] ) + Alltrim( aItem[nSE5Num] ) + Alltrim( STR( aItem[nSE5Valor] ) ) + Alltrim( aItem[nSE5Deb] ) == _cChaveSIG  } )
                     If _nPosSE5 > 0
                        //Atualiza Dados do Movimento
                        _oModelMov:GoLine( _nPosSE5 )
                        _oModelMov:SetValue( 'MOV_MARK', .T.              )
                        _oModelMov:SetValue( 'COR'     , u_FRETCOR( '3' ) )
                        _oModelMov:SetValue( 'E5_SEQCON' , _oModelExt:aCols[_nX][nSIGSeqM]  )

                        //Atualiza Dados do Extrato
                        _oModelExt:GoLine( _nX )
                        _oModelExt:SetValue( 'EXT_MARK', .T.         )
                        _oModelExt:SetValue( 'COR', u_FRETCOR( '3' ) )
                        _oModelExt:SetValue( 'IG_DTMOVI' , _oModelMov:aCols[_nPosSE5][nSE5Data] )
                        _oModelExt:SetValue( 'IG_AGEMOV' , _oModelMov:aCols[_nPosSE5][nSE5Age]  )
                        _oModelExt:SetValue( 'IG_CONMOV' , _oModelMov:aCols[_nPosSE5][nSE5Conta])
                        _oModelExt:SetValue( 'IG_DOCMOV' , _oModelMov:aCols[_nPosSE5][nSE5Num]  )
                        _oModelExt:SetValue( 'IG_VLRMOV' , _oModelMov:aCols[_nPosSE5][nSE5Valor])
                        _oModelExt:SetValue( 'IG_HISMOV' , _oModelMov:aCols[_nPosSE5][nSE5His]  )
                        _oModelExt:SetValue( 'IG_NATMOV' , _oModelMov:aCols[_nPosSE5][nSE5Nat]  )
                        _oModelExt:SetValue( 'IG_FILORIG', _oModelMov:aCols[_nPosSE5][nSE5Fil]  )
                        _oModelExt:SetValue( 'IG_STATUS' , '3'                                  )
                        //_oModelExt:SetValue( 'IG_EFETIVA', ' '                                  )
                        _nY := _oModelMov:Length()
                     Endif
                 Next
             Next
          Else //A Receber
             If Len( _aConcNN ) > 0
                For _nX := 1 To Len( _aConcNN )
                    If Empty( _aConcNN[_nX][4] )
                       For _nY := 1 To _oModelMov:Length()
                           _oModelMov:GoLine( _nY )
                           If !_oModelMov:IsDeleted() .and. !_oModelMov:GetValue('MOV_MARK') .and. Upper( Alltrim( _oModelMov:aCols[_nY][nSE5His] ) ) == 'VALOR RECEBIDO S/ TITULO' .and. !Empty( _oModelMov:aCols[_nY][nSE5Doc] )
                              _oModelMov:SetValue( 'MOV_MARK', .T.              )
                              _oModelMov:SetValue( 'COR'     , u_FRETCOR( '2' ) )
                              _oModelMov:SetValue( 'E5_SEQCON' , _aConcNN[_nX][1]  )
                              _aConcNN[_nX][3] += _oModelMov:GetValue( 'E5_VALOR' )
                              aAdd( _aConcNN[_nX][6], { _aConcNN[_nX][1], _oModelMov:GetValue( 'E5_VALOR' ), _oModelMov:nLine } )
                           Endif
                       Next
                    Endif
                    If _aConcNN[_nX][2] == _aConcNN[_nX][3]
                       _aConcNN[_nX][4] := 'S' //Marco item como consolidado
                       For _nY := 1 To Len( _aConcNN[_nX][6] ) //Ajusto flag para o movimento
                           _oModelMov:GoLine( _aConcNN[_nX][6][_nY][3] )
                           _oModelMov:SetValue( 'COR', u_FRETCOR( '3' ) )
                       Next
                       For _nY := 1 To Len( _aConcNN[_nX][5] ) //Ajusto flag para o Extrato
                           _oModelExt:GoLine( _aConcNN[_nX][5][_nY][3] )
                           _oModelExt:SetValue( 'COR', u_FRETCOR( '3' ) )
                           _oModelExt:SetValue( 'IG_STATUS' , '3' )
                           //_oModelExt:SetValue( 'IG_EFETIVA', ' ' )
                       Next
                    Endif
                Next
             Endif
          Endif
          _oModelExt:GoLine( 1 )
          _oView:Refresh( 'GRIDEXTR' )
          _oModelMov:GoLine( 1 )
          _oView:Refresh( 'GRIDMOVI' )
       Else
          MessageBox( 'Função deve ser utilizada somente quando o parâmetro inicial estiver marcardo para não conciliados.', 'Atenção', 48 )
       Endif
Return

/*/{Protheus.doc} fGeraLan
description
@type function
@version 
@author Luís Gustavo de Souza
@since 10/09/2020
@param oView, object, Objeto da View
@return Nil, Sem retorno para essa função
/*/
Static Function fGeraLan( oView )
       Local _oView     as Object
       Local _oModel    as Object
       Local _oModelExt as Object
       Local _oModelMOV as Object
       Local _oModelCAB as Object
       //Local _nLineEXT  as Numeric
       Local _nX, _nY
       Local _cNatMov := GetMV( 'ZP_PAR0030' )
	   Local _cCusMov := GetMV( 'ZP_PAR0031' )

       _oModel    := FWModelActive()
       _oView     := Iif( ValType( oView ) == 'O', oView, FWViewActive() )
       _oModelExt := _oModel:GetModel('GRIDEXTR')
       _oModelMOV := _oModel:GetModel('GRIDMOVI')
       _oModelCAB := _oModel:GetModel('MASTERCON')
       //Verifica se a linha do extrato está marcada e se o status da mesma está como não conciliada.
       For _nX := 1 To Len( _aConcNN )
           If Empty( _aConcNN[_nX][4] )
              cRecPag := ' '
              _oModelMOV:AddLine()
              _oModelMOV:SetValue( 'MOV_MARK'  , .t. )
              _oModelMOV:SetValue( 'COR'       , u_FRETCOR( '4' ) )
              _oModelMOV:SetValue( 'SEQDIG'    , cValToChar( _oModelMOV:nLine ) )
              _oModelMOV:SetValue( 'E5_FILIAL' , FWxFilial("SE5") )
              _oModelMOV:SetValue( 'E5_DATA'   , dDataBase        )
              M->E5_DATA := dDataBase
              _oModelMOV:SetValue( 'E5_DTDIGIT', dDataBase        )
              _oModelMOV:SetValue( 'E5_DTDISPO', dDataBase        )
              _oModelMOV:SetValue( 'E5_VENCTO' , dDataBase        )
              M->E5_VENCTO := dDataBase
              _oModelMOV:SetValue( 'E5_NUMCHEQ', ''               )
              _oModelMOV:SetValue( 'E5_VALOR' , ABS( _aConcNN[_nX][2] ) )
              _oModelMOV:SetValue( 'E5_HISTOR' , 'PAGAMENTO DE DESPESAS BANCARIAS' )
              _oModelMOV:SetValue( 'E5_NATUREZ', _cNatMov /*'904004'*/ )
              _oModelMOV:SetValue( 'E5_BANCO'  , _oModelCAB:GetValue('BANCO')   )
              _oModelMOV:SetValue( 'E5_AGENCIA', _oModelCAB:GetValue('AGENCIA') )
              _oModelMOV:SetValue( 'E5_CONTA'  , _oModelCAB:GetValue('CONTA') )
              _oModelMOV:SetValue( 'E5_RECPAG' , 'P' )
              _oModelMOV:SetValue( 'E5_DOCUMEN', SubStr( _oModelMOV:GetValue( 'E5_HISTOR' ), 1, 50 ) )
              _oModelMOV:SetValue( 'E5_TIPODOC', 'VL' )
              _oModelMOV:SetValue( 'E5_X_REPA' , 'P' )
              _oModelMOV:SetValue( 'E5_BENEF'  , SubStr( _oModelMOV:GetValue( 'E5_HISTOR' ), 1, 30 ) )
              _oModelMOV:SetValue( 'E5_FILORIG', FWxFilial("SE5") )
              _oModelMOV:SetValue( 'SE5_SOMA'  , _aConcNN[_nX][2] )
              _oModelMOV:SetValue( 'E5_SEQCON' , _aConcNN[_nX][1] )
              _oModelMOV:SetValue( 'E5_MOEDA'  , 'M1' )
			  _oModelMOV:SetValue( 'E5_CCUSTO' , _cCusMov )
              _aConcNN[_nX][3] += _aConcNN[_nX][2]
              _aConcNN[_nX][4] := 'S'
              aAdd(_aConcNN[_nX][6], { _aConcNN[_nX][1], _aConcNN[_nX][3], _oModelMOV:nLine})
              //Troco a cor do Status
              nSE5Data := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_DTDISPO' } )
              nSE5Age  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_AGENCIA' } )
              nSE5Conta:= aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_CONTA'   } )
              nSE5Num  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_NUMCHEQ' } )
              nSE5Valor:= aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_VALOR'   } )
              nSE5His  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_HISTOR'  } )
              nSE5Nat  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_NATUREZ' } )
              nSE5Fil  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_FILIAL'  } )
              For _nY := 1 To Len( _aConcNN[_nX][5] )
                  _oModelExt:GoLine( _aConcNN[_nX][5][_nY][3] )
                  _oModelExt:SetValue( 'COR', u_FRETCOR( '4' ) )
                  _oModelExt:SetValue( 'IG_DTMOVI' , _oModelMov:aCols[_oModelMOV:nLine][nSE5Data] )
                  _oModelExt:SetValue( 'IG_AGEMOV' , _oModelMov:aCols[_oModelMOV:nLine][nSE5Age]  )
                  _oModelExt:SetValue( 'IG_CONMOV' , _oModelMov:aCols[_oModelMOV:nLine][nSE5Conta])
                  _oModelExt:SetValue( 'IG_DOCMOV' , _oModelMov:aCols[_oModelMOV:nLine][nSE5Num]  )
                  _oModelExt:SetValue( 'IG_VLRMOV' , _oModelMov:aCols[_oModelMOV:nLine][nSE5Valor])
                  _oModelExt:SetValue( 'IG_HISMOV' , _oModelMov:aCols[_oModelMOV:nLine][nSE5His]  )
                  _oModelExt:SetValue( 'IG_NATMOV' , _oModelMov:aCols[_oModelMOV:nLine][nSE5Nat]  )
                  _oModelExt:SetValue( 'IG_FILORIG', _oModelMov:aCols[_oModelMOV:nLine][nSE5Fil]  )
                  _oModelExt:SetValue( 'IG_STATUS' , '3'  )
                  //_oModelExt:SetValue( 'IG_EFETIVA', ' '  )
              Next
              _oModelExt:GoLine( 1 )
           EndIf
       Next
       _oView:Refresh( 'GRIDEXTR' )
       _oView:Refresh( 'GRIDMOVI' )
Return

/*/{Protheus.doc} fPosValid
Validação antes da gravação, que verifica os valores selecionados, que devem ser iguais entre Extrato x Conciliados x Movimento
@type function
@version 
@author Luís Gustavo de Souza
@since 10/09/2020
@param oModel, object, objeto do modelo
@return Logic, Retorna verdadeiro se os valores são iguais ou falso se são diferentes.
/*/
Static Function fPosValid( oModel )
       Local _lRet := .t.
       Local _nQtdExt := oModel:GetModel( 'EXTRATO' ):GetValue( 'EXT_SELE' )
       Local _nQtdCon := oModel:GetModel( 'CONCILI' ):GetValue( 'CON_SOMA' )
       Local _nQtdMov := oModel:GetModel( 'MOVIMEN' ):GetValue( 'SIS_SELE' )

       If !_lDesCon
          If !( _nQtdExt == _nQtdMov ) .or. !( _nQtdMov == _nQtdCon )
             _lRet := .f.
             Help( Nil, Nil, 'DIF_CONCILIA', Nil, 'Atenção, valores marcados divergem.', 1, 0, Nil, Nil, Nil, Nil, .f., { "Verifique os itens marcados." })
          Endif
       Endif
Return _lRet

Static Function FGrava( oModel )
       Local _aArea     := GetArea()
       Local _oModelSIG := oModel:GetModel( 'GRIDEXTR' )
       Local _oModelSE5 := oModel:GetModel( 'GRIDMOVI' )
       Local lAtuDtDisp := .T.
       //Local _oModelSIF := oModel:GetModel( 'MASTERCON' )
       Local _nX, _nY, _nContCon
       Local CIDORIG    := ""
       Local _lRet      := .t.
       Local cFilFKA    := ''
       Local _nPSeqCon  := aScan( _oModelSE5:aHeader, { |x| Alltrim( x[2] ) = 'E5_SEQCON' } )
       Local _nPRecSE5  := aScan( _oModelSE5:aHeader, { |x| Alltrim( x[2] ) = 'REC_NO' } )
       Local _nJaGrav   := aScan( _oModelSE5:aHeader, { |x| Alltrim( x[2] ) = 'E5_X_JAGR' } )
       //Local _nPReconc  := aScan( _oModelSE5:aHeader, { |x| Alltrim( x[2] ) = 'E5_RECONC' } )

       DbSelectArea("FKA")
       DbSelectArea("FK5")
       FK5->( DbSetOrder(1) )
       SIF->( DbSetOrder(1) ) //IF_FILIAL+IF_IDPROC
       SIG->( DbSetOrder(1) ) //IG_IDPROC + IG_ITEM
       SE5->( DbSetOrder(20)) //E5_FILIAL+E5_SEQCON
       SA6->( DbSetOrder(1) )

       _nContCon := 0 //Contador de conciliação
       For _nX := 1 To _oModelSIG:Length() //Busco informações do extrato
           _oModelSIG:GoLine( _nx )
           If !_oModelSIG:IsDeleted() .and. (_oModelSIG:GetValue('EXT_MARK') .or. _oModelSIG:GetValue('DESCONC') == '1')
              If SIG->( DbSeek( FWxFilial("SIG") + _oModelSIG:GetValue("IG_IDPROC") + _oModelSIG:GetValue("IG_ITEM") ) )
                 _nContCon++
                 If !SIG->IG_EFETIVA == '1' .or. _oModelSIG:GetValue('DESCONC') == '1'
                    RecLock( "SIG", .F. )
                       SIG->IG_DTMOVI  := _oModelSIG:GetValue("IG_DTMOVI")
                       SIG->IG_AGEMOV  := _oModelSIG:GetValue("IG_AGEMOV")
                       SIG->IG_CONMOV  := _oModelSIG:GetValue("IG_CONMOV")
                       SIG->IG_DOCMOV  := _oModelSIG:GetValue("IG_DOCMOV")
                       SIG->IG_VLRMOV  := _oModelSIG:GetValue("IG_VLRMOV")
                       SIG->IG_HISMOV  := _oModelSIG:GetValue("IG_HISMOV")
                       SIG->IG_NATMOV  := _oModelSIG:GetValue("IG_NATMOV")
                       SIG->IG_SEQMOV  := _oModelSIG:GetValue("IG_SEQMOV")
                       SIG->IG_STATUS  := _oModelSIG:GetValue("IG_STATUS")
                       SIG->IG_EFETIVA := Iif( _oModelSIG:GetValue('DESCONC') == '1', '', '1' )
                       If _oModelSIG:GetValue("COR") == 'BR_PRETO'
                          SIG->( DbDelete() )
                       Endif
                    SIG->( MsUnLock() )
                    If _oModelSIG:GetValue("COR") == 'BR_PRETO'
                       Loop
                    Endif
                 else
                    Loop
                 Endif
                 cSeqCon  := _oModelSIG:GetValue("IG_SEQMOV")
                 cStatus  := _oModelSIG:GetValue("IG_STATUS")
                 lDesconc := _oModelSIG:GetValue("DESCONC") == '1'
                 dDataExt := _oModelSIG:GetValue("IG_DTEXTR")
                 dDataMov := _oModelSIG:GetValue("IG_DTMOVI")
                 nValor   := 0
                 nVlrSE5  := If(_oModelSIG:GetValue("IG_VLREXT") > 0, _oModelSIG:GetValue("IG_VLREXT"), _oModelSIG:GetValue("IG_VLRMOV"))
                 nRECSE5  := _oModelSIG:GetValue("RECSE5")

                 If SubStr( cSeqCon, 1, 1 ) $ 'R.P.C'
                    For _nY := 1 To _oModelSE5:Length()
                        _oModelSE5:GoLine( _nY )
                        If !_oModelSE5:IsDeleted() .and. ( _oModelSE5:GetValue('MOV_MARK') .or. lDesconc ) //_oModelSE5:GetValue('MOV_MARK')
                           If _oModelSE5:aCols[_nY][_nPSeqCon] == cSeqCon .and. ( _oModelSE5:aCols[_nY][_nJaGrav] <> 'S' .or. lDesconc ) //_oModelSE5:aCols[_nY][_nJaGrav] <> 'S'
                              _nRECSE5 := _oModelSE5:aCols[_nY][_nPRecSE5]
                              If _nRECSE5 == 0
                                 _nRECSE5 := fGeraMov( _oModelSE5:aCols[_nY], _oModelSE5:aHeader, _nX, _nY, _oModelSE5:aCols )
                                 _oModelSE5:SetValue( 'E5_X_JAGR', 'S')
                              Endif
                              If !(cStatus $ '|5|6') .And. _nRECSE5 > 0
                                 SE5->( DbGoTo( _nRECSE5 ) )
                                 FKA->( DbSetOrder(3) ) //Posiciona a FKA com base no IDORIG da SE5 posicionada
                                 If SE5->E5_TABORI == "FK1"
                                    FKA->( DbSeek( SE5->E5_FILIAL + "FK1" + SE5->E5_IDORIG ) )
                                    lFK5 := .F. // Precisa fazer o loop na FKA procurando o registro de Movimentação Bancaria
                                    lFKs := .T. // Possui dados migrados
                                 ElseIf SE5->E5_TABORI == "FK2"
                                        FKA->( DbSeek( SE5->E5_FILIAL + "FK2" + SE5->E5_IDORIG ) )
                                        lFK5 := .F. // Precisa fazer o loop na FKA procurando o registro de Movimentação Bancaria
                                        lFKs := .T. // Possui dados migrados
                                 ElseIf SE5->E5_TABORI == "FK5"
                                        FKA->( DbSeek( SE5->E5_FILIAL + "FK5" + SE5->E5_IDORIG ) )
                                        lFK5 := .T. // NÃO PRECISA fazer o loop na FKA procurando o registro de Movimentação Bancaria, pois esse é o registro de movimentação
                                        lFKs := .T. // Possui dados migrados
                                        cIdOrig := FKA->FKA_IDORIG
                                        cFilFKA := FKA->FKA_FILIAL
                                 ElseIf Empty(SE5->E5_TABORI)
                                        lFKs := .F. // NÃO POSSUI dados migrados
                                 Endif
                                 If lFKs // Possui dados migrados
                                    cIdProc := FKA->FKA_IDPROC
                                    If !lFK5 // Precisa fazer o loop na FKA procurando o registro de Movimentação Bancaria
                                       FKA->( DbSetOrder(2) )
                                       FKA->( DbSeek( FKA->FKA_FILIAL + cIdProc ) )
                                       While FKA->(!EOF()) .AND. FKA->FKA_IDPROC == cIdProc
                                             If FKA->FKA_TABORI == "FK5"
                                                cIdOrig := FKA->FKA_IDORIG
                                                cFilFKA := FKA->FKA_FILIAL
                                             EndIf
                                             FKA->(DbSkip())
                                       Enddo
                                    EndIf
                                    If FK5->( DbSeek( cFilFKA + cIdOrig ) )
                                       lPosFK5 := .t.
                                       If !lDesconc //Conciliou
                                           Reclock( "SE5", .F. )
                                              SE5->E5_RECONC  := 'x'
                                              SE5->E5_SEQCON  := cSeqCon
                                              SE5->E5_NATUREZ := _oModelSE5:GetValue( 'E5_NATUREZ' )
                                              SE5->E5_BENEF   := _oModelSE5:GetValue( 'E5_BENEF'   )
                                              SE5->E5_HISTOR  := _oModelSE5:GetValue( 'E5_HISTOR'  )
											  SE5->E5_CCUSTO  := _oModelSE5:GetValue( 'E5_CCUSTO'  )
                                           SE5->( MsUnLock() )
                                           Reclock("FK5", .F.)
                                             FK5->FK5_DTCONC := dDataBase
                                             FK5->FK5_SEQCON := cSeqCon
                                           FK5->( MsUnLock() )							
                                       Else //Desconciliou
                                          Reclock( "SE5", .F. )
                                             SE5->E5_RECONC := ' '
                                             SE5->E5_SEQCON := ' '
                                          SE5->( MsUnLock() )
                                          Reclock("FK5", .F.)
                                             FK5->FK5_DTCONC := CTOD("")
                                             FK5->FK5_SEQCON := ""
                                          SE5->( MsUnLock() )
                                       EndIf
                                    Else
                                       cLog := 'Registro não localizado na tabela FK5.' + cFilFKA + "' " + 'Filial: ' + cIdOrig + "' "
                                       Help( ,,"MF473GRV1",,cLog, 1, 0 )
                                    EndIf
                                 Else // Registro da SE5 não possui dados nas Tabelas FKs, não foi migrado.
                                    If !lDesconc //Conciliou
                                       Reclock( "SE5", .F. )
                                          SE5->E5_RECONC := 'x'
                                          SE5->E5_SEQCON := cSeqCon
                                          SE5->E5_NATUREZ := _oModelSE5:GetValue( 'E5_NATUREZ' )
                                          SE5->E5_BENEF   := _oModelSE5:GetValue( 'E5_BENEF'   )
                                          SE5->E5_HISTOR  := _oModelSE5:GetValue( 'E5_HISTOR'  )
										  SE5->E5_CCUSTO  := _oModelSE5:GetValue( 'E5_CCUSTO'  )
                                       SE5->( MsUnLock() )
                                    Else //Desconciliou
                                       Reclock( "SE5", .F. )
                                          SE5->E5_RECONC := ' '
                                          SE5->E5_SEQCON := ' ' 
                                       SE5->( MsUnLock() )
                                    EndIf
                                 EndIf
                                 If lDesconc
                                    dDataNova := dDataMov
                                 Else
                                    dDataNova := dDataExt
                                 EndIf
                                 //Acerto E5_DTDISPO dos titulos baixados
                                 If dDataNova !=  SE5->E5_DTDISPO .and. lAtuDtDisp
                                    dOldDispo := SE5->E5_DTDISPO
                                    If lFKs // Possui dados migrados
                                       //Posiciona a FK5 com base no IDORIG da SE5 posicionada
                                       //Modifiquei esse bloco, pois alguns registros estão como correto posicionamento na FK5 baseada na FK1/Fk2
                                       If lFk5
                                          DbSelectArea("FK5")
                                          FK5->( DbSetOrder(1) )
                                          lPosFK5 := FK5->( DbSeek( xFilial("SE5") + SE5->E5_IDORIG ) )
                                       EndIf
                                       If lPosFK5
                                          Reclock("FK5", .F.)
                                             FK5->FK5_DTDISP := SE5->E5_DTDISPO
                                          FK5->(MsUnlock())
                                          If SE5->E5_RECPAG == "P"
                                             AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "+", lDesconc )
                                             AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "-", !lDesconc )
                                          Else
                                             AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "-", lDesconc )
                                             AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "+", !lDesconc )
                                          EndIf
                                       Else
                                          cLog := 'Registro não localizado na tabela FK5. Filial: ' + cFilFKA + "' " + 'Filial: ' + cIdOrig + "' "
                                          Help( , , "MF473GRV2", , 'Não foi possivel atualizar o Saldo do Banco.' + CRLF + cLog, 1, 0 )
                                       EndIf
                                    Else // Registro da SE5 não possui dados nas Tabelas FKs, dados não foram migrados.
                                       If SE5->E5_RECPAG == "P"
                                          AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "+", lDesconc )
                                          AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "-", !lDesconc )
                                       Else
                                          AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "-", lDesconc )
                                          AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "+", !lDesconc )
                                       EndIf
                                    EndIf
                                 Else
                                    //Atualiza apenas o saldo reconciliado
                                    If lDesconc	    //Desconciliou
                                       AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,If(SE5->E5_RECPAG == "P","+","-"),.T.,.F.)
                                    Else //Conciliou
                                       AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,If(SE5->E5_RECPAG == "P","-","+"),.T.,.F.)
                                    EndIf
                                 EndIf
                              Endif
                           Endif
                        Endif
                    Next
                 Else
                    _nPosSeq := aScan( _oModelSE5:aCols, { |x| x[_nPSeqCon] == cSeqCon } )
                    _nRECSE5 := _oModelSE5:aCols[_nPosSeq][_nPRecSE5]
                    If !(cStatus $ '|5|6') .And. _nRECSE5 > 0
                       SE5->( DbGoTo( _nRECSE5 ) )
                       FKA->( DbSetOrder(3) ) //Posiciona a FKA com base no IDORIG da SE5 posicionada
                       If SE5->E5_TABORI == "FK1"
                          FKA->( DbSeek( SE5->E5_FILIAL + "FK1" + SE5->E5_IDORIG ) )
                          lFK5 := .F. // Precisa fazer o loop na FKA procurando o registro de Movimentação Bancaria
                          lFKs := .T. // Possui dados migrados
                       ElseIf SE5->E5_TABORI == "FK2"
                              FKA->( DbSeek( SE5->E5_FILIAL + "FK2" + SE5->E5_IDORIG ) )
                              lFK5 := .F. // Precisa fazer o loop na FKA procurando o registro de Movimentação Bancaria
                              lFKs := .T. // Possui dados migrados
                       ElseIf SE5->E5_TABORI == "FK5"
                              FKA->( DbSeek( SE5->E5_FILIAL + "FK5" + SE5->E5_IDORIG ) )
                              lFK5 := .T. // NÃO PRECISA fazer o loop na FKA procurando o registro de Movimentação Bancaria, pois esse é o registro de movimentação
                              lFKs := .T. // Possui dados migrados
                              cIdOrig := FKA->FKA_IDORIG
                              cFilFKA := FKA->FKA_FILIAL
                       ElseIf Empty(SE5->E5_TABORI)
                              lFKs := .F. // NÃO POSSUI dados migrados
                       Endif
                       If lFKs // Possui dados migrados
                          cIdProc := FKA->FKA_IDPROC
                          If !lFK5 // Precisa fazer o loop na FKA procurando o registro de Movimentação Bancaria
                             FKA->( DbSetOrder(2) )
                             FKA->( DbSeek( FKA->FKA_FILIAL + cIdProc ) )
                             While FKA->(!EOF()) .AND. FKA->FKA_IDPROC == cIdProc
                                   If FKA->FKA_TABORI == "FK5"
                                      cIdOrig := FKA->FKA_IDORIG
                                      cFilFKA := FKA->FKA_FILIAL
                                   EndIf
                                   FKA->(DbSkip())
                             Enddo
                          EndIf
                          If FK5->( DbSeek( cFilFKA + cIdOrig ) )
                             lPosFK5 := .t.
                             If !lDesconc //Conciliou
                                Reclock( "SE5", .F. )
                                   SE5->E5_RECONC	:= 'x'
                                   SE5->E5_SEQCON	:= cSeqCon
                                SE5->( MsUnLock() )
                                Reclock("FK5", .F.)
                                   FK5->FK5_DTCONC := dDataBase
                                   FK5->FK5_SEQCON := cSeqCon
                                FK5->( MsUnLock() )							
                             Else //Desconciliou
                                Reclock( "SE5", .F. )
                                   SE5->E5_RECONC	:= ' '
                                   SE5->E5_SEQCON	:= ' '
                                SE5->( MsUnLock() )
                                Reclock("FK5", .F.)
                                   FK5->FK5_DTCONC := CTOD("")
                                   FK5->FK5_SEQCON := ""
                                SE5->( MsUnLock() )
                             EndIf
                          Else
                             cLog := 'Registro não localizado na tabela FK5.' + cFilFKA + "' " + 'Filial: ' + cIdOrig + "' "
                             Help( ,,"MF473GRV1",,cLog, 1, 0 )
                          EndIf
                       Else // Registro da SE5 não possui dados nas Tabelas FKs, não foi migrado.
                          If !lDesconc //Conciliou
                             Reclock( "SE5", .F. )
                                SE5->E5_RECONC := 'x'
                                SE5->E5_SEQCON := cSeqCon
                             SE5->( MsUnLock() )
                          Else //Desconciliou
                             Reclock( "SE5", .F. )
                                SE5->E5_RECONC := ' '
                                SE5->E5_SEQCON := ' ' 
                             SE5->( MsUnLock() )
                          EndIf
                       EndIf
                       If lDesconc
                          dDataNova := dDataMov
                       Else
                          dDataNova := dDataExt
                       EndIf
                       //Acerto E5_DTDISPO dos titulos baixados
                       If dDataNova !=  SE5->E5_DTDISPO .and. lAtuDtDisp
                          dOldDispo := SE5->E5_DTDISPO
                          If lFKs // Possui dados migrados
                             //Posiciona a FK5 com base no IDORIG da SE5 posicionada
                             If lFk5
                                DbSelectArea("FK5")
                                FK5->( DbSetOrder(1) )
                                lPosFK5 := FK5->( DbSeek( xFilial("SE5") + SE5->E5_IDORIG ) )
                             Endif
                             If lPosFK5
                                Reclock("FK5", .F.)
                                   FK5->FK5_DTDISP	:= SE5->E5_DTDISPO
                                FK5->(MsUnlock())
                                If SE5->E5_RECPAG == "P"
                                   AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "+", lDesconc )
                                   AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "-", !lDesconc )
                                Else
                                   AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "-", lDesconc )
                                   AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "+", !lDesconc )
                                EndIf
                             Else
                                cLog := 'Registro não localizado na tabela FK5. Filial: ' + cFilFKA + "' " + 'Filial: ' + cIdOrig + "' "
                                Help( , , "MF473GRV2", , 'Não foi possivel atualizar o Saldo do Banco.' + CRLF + cLog, 1, 0 )
                             EndIf
                          Else // Registro da SE5 não possui dados nas Tabelas FKs, dados não foram migrados.
                             If SE5->E5_RECPAG == "P"
                                AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "+", lDesconc )
                                AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "-", !lDesconc )
                             Else
                                AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "-", lDesconc )
                                AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "+", !lDesconc )
                             EndIf
                          EndIf
                       Else
                          //Atualiza apenas o saldo reconciliado
                          If lDesconc	    //Desconciliou
                             AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,If(SE5->E5_RECPAG == "P","+","-"),.T.,.F.)
                          Else //Conciliou
                             AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,If(SE5->E5_RECPAG == "P","-","+"),.T.,.F.)
                          EndIf
                       EndIf
                    Endif
                 Endif
              Endif
           Endif
       Next
       
       If _nContCon == 0
          _lRet := .f.
          Help( Nil, Nil, 'ITENS_NAO_MARCADOS', Nil, 'Atenção, não haviam registros marcados.', 1, 0, Nil, Nil, Nil, Nil, .f., { "Marque primeiro um item do extrato/movimento para conciliar." })
       else
          //Atualiza os Status da tabela SIF
          RecLock("SIF",.F.)
             SIF->IF_STATUS := SIFStatus( )
          SIF->( MsUnLock() )
       Endif
       RestArea( _aArea )
Return _lRet

Static Function SIFStatus(  )
       Local cStatus  := "1"
       Local cQuery   := ""
       Local cTabSIF  := "SIFCONTA"
       Local nTotal   := 0
       Local nNaoConc := 0

       Default cFilSIG   := FWxFilial("SIG")
       Default cProcesso := SIF->IF_IDPROC

       Pergunte('ZFINF01', .F.)
       cQuery := " "
       cQuery += " SELECT "
       cQuery += "     COUNT(*) SIGCONT "
       cQuery += " FROM "+RetSQLName("SIG")+" SIG "
       cQuery += " WHERE "
       cQuery += "     IG_FILIAL = '" + cFilSIG   + "'  AND "
       cQuery += "     IG_IDPROC = '" + cProcesso + "'        AND "
       //cQuery += "     IG_DTEXTR = '" + DTOS( mv_par04 ) + "' AND "
       cQuery += "     SIG.D_E_L_E_T_ = ' ' "
       cQuery := ChangeQuery(cQuery)

       dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabSIF,.T.,.T.)

       If (cTabSIF)->(!EOF())
          nTotal := (cTabSIF)->SIGCONT
       EndIf
       (cTabSIF)->(dbCloseArea())

       cQuery := " "
       cQuery += " SELECT "
       cQuery += "     COUNT(*) SIGCONT "
       cQuery += " FROM "+RetSQLName("SIG")+" SIG "
       cQuery += " WHERE "
       cQuery += "     IG_FILIAL = '" + cFilSIG + "'  AND "
       cQuery += "     IG_IDPROC = '" + cProcesso + "'        AND "
       cQuery += "     IG_STATUS = '1'        		AND "
       cQuery += "     SIG.D_E_L_E_T_ = ' ' "
       cQuery := ChangeQuery(cQuery)

       dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabSIF,.T.,.T.)

       If (cTabSIF)->(!EOF())
          nNaoConc := (cTabSIF)->SIGCONT
       EndIf
       (cTabSIF)->(dbCloseArea())

       If nNaoConc == 0 // Totalmente conciliado
          cStatus := '3'
       ElseIf nNaoConc < nTotal // Conciliado Parcialmente
              cStatus := '2'
       EndIf
Return cStatus

Static Function fGeraMov( _aFINA100, _aHeadSE5, _nPosExt, _nPosMov, _aMovimen )
       Local _aFin100 as Array
       Local _nNumRec as Numeric
       Local _nPosTip as Numeric
       Local _nPosBan as Numeric
       Local _nPosAge as Numeric
       Local _nPosCta as Numeric
       Local _nPosNat as Numeric
       Local _nPosDoc as Numeric
       Private lMsErroAuto := .F.
       SetFunName('FINA100')
       _nPosTip  := aScan( _aHeadSE5, { |x| x[2] == 'E5_TIPODOC' } )
       _nPosBan  := aScan( _aHeadSE5, { |x| x[2] == 'E5_BANCO'   } )
       _nPosAge  := aScan( _aHeadSE5, { |x| x[2] == 'E5_AGENCIA' } )
       _nPosCta  := aScan( _aHeadSE5, { |x| x[2] == 'E5_CONTA'   } )
       _nPosNat  := aScan( _aHeadSE5, { |x| x[2] == 'E5_NATUREZ' } )
       _nPosDoc  := aScan( _aHeadSE5, { |x| x[2] == 'E5_DOCUMEN' } )
       _nPosChe  := aScan( _aHeadSE5, { |x| x[2] == 'E5_NUMCHEQ' } )
       _nPosVlr  := aScan( _aHeadSE5, { |x| x[2] == 'E5_VALOR'   } )
       _nPosHis  := aScan( _aHeadSE5, { |x| x[2] == 'E5_HISTOR'  } )
       _nPosBen  := aScan( _aHeadSE5, { |x| x[2] == 'E5_BENEF'   } )
       _nPosSeq  := aScan( _aHeadSE5, { |x| x[2] == 'E5_SEQCON'  } )
       _nPosRec  := aScan( _aHeadSE5, { |x| x[2] == 'REC_NO'     } )
       _nPosBDes := aScan( _aHeadSE5, { |x| x[2] == 'E5_X_BDES'  } )
       _nPosADes := aScan( _aHeadSE5, { |x| x[2] == 'E5_X_ADES'  } )
       _nPosCDes := aScan( _aHeadSE5, { |x| x[2] == 'E5_X_CDES'  } )
       _nPosNDes := aScan( _aHeadSE5, { |x| x[2] == 'E5_X_NDES'  } )
       _nPosBOri := aScan( _aHeadSE5, { |x| x[2] == 'E5_X_BORI'  } )
       _nPosAOri := aScan( _aHeadSE5, { |x| x[2] == 'E5_X_AORI'  } )
       _nPosCOri := aScan( _aHeadSE5, { |x| x[2] == 'E5_X_CORI'  } )
       _nPosNOri := aScan( _aHeadSE5, { |x| x[2] == 'E5_X_NORI'  } )
       _nPosOrig := aScan( _aHeadSE5, { |x| x[2] == 'E5_X_ORIG'  } )

       _nNumRec := 0
       If !( _aFina100[_nPosTip] $ 'TR' ) //Se não for transferência
          _aFin100 := { { "E5_DATA"   , _aFINA100[ aScan( _aHeadSE5, { |x| x[2] == 'E5_DATA'    } ) ], Nil },;
                        { "E5_MOEDA"  , _aFINA100[ aScan( _aHeadSE5, { |x| x[2] == 'E5_MOEDA'   } ) ], Nil },;
                        { "E5_VALOR"  , _aFINA100[ aScan( _aHeadSE5, { |x| x[2] == 'E5_VALOR'   } ) ], Nil },;
                        { "E5_NATUREZ", _aFINA100[ aScan( _aHeadSE5, { |x| x[2] == 'E5_NATUREZ' } ) ], Nil },;
                        { "E5_BANCO"  , _aFINA100[ aScan( _aHeadSE5, { |x| x[2] == 'E5_BANCO'   } ) ], Nil },;
                        { "E5_AGENCIA", _aFINA100[ aScan( _aHeadSE5, { |x| x[2] == 'E5_AGENCIA' } ) ], Nil },;
                        { "E5_CONTA"  , _aFINA100[ aScan( _aHeadSE5, { |x| x[2] == 'E5_CONTA'   } ) ], Nil },;
                        { "E5_BENEF"  , _aFINA100[ aScan( _aHeadSE5, { |x| x[2] == 'E5_BENEF'   } ) ], Nil },;
                        { "E5_HISTOR" , _aFINA100[ aScan( _aHeadSE5, { |x| x[2] == 'E5_HISTOR'  } ) ], Nil } }
          If _aFINA100[13] == 'P' //Pagar
             MSExecAuto( { |x, y, z| FinA100( x, y, z ) }, 0, _aFin100, 3 )
          else //Receber
             MSExecAuto( { |x, y, z| FinA100( x, y, z ) }, 0, _aFin100, 4 )
          Endif
          If lMsErroAuto
             MostraErro()
          else
             _nNumRec := SE5->(Recno())
          Endif
       Else
          //_nPosCon := aScan( _aConCNN, { |x| x[1] == _aFINA100[_nPosSeq]} )
          //_nPosDes := _aConCNN[_nPosCon][6][2][3]
          //If _nPosDes > 0
             _cBcoOrig := _aFINA100[ _nPosBOri ]
             _cAgeOrig := _aFINA100[ _nPosAOri ]
             _cCtaOrig := _aFINA100[ _nPosCOri ]
             _cNatOrig := _aFINA100[ _nPosNOri ]
             /*_cBcoDest := _aMovimen[_nPosDes][_nPosBan]
             _cAgeDest := _aMovimen[_nPosDes][_nPosAge]
             _cCtaDest := _aMovimen[_nPosDes][_nPosCta]
             _cNatDest := _aMovimen[_nPosDes][_nPosNat]*/
             _cBcoDest := _aFINA100[ _nPosBDes ]
             _cAgeDest := _aFINA100[ _nPosADes ]
             _cCtaDest := _aFINA100[ _nPosCDes ]
             _cNatDest := _aFINA100[ _nPosNDes ]
             _cDocTran := Iif( Empty( _aFINA100[ _nPosDoc ] ), _aFINA100[ _nPosChe ], _aFINA100[ _nPosDoc ] )
             _nVlrTran := _aFINA100[ _nPosVlr ]
             _cBenTran := _aFINA100[ _nPosBen ]
             _cHisTran := _aFINA100[ _nPosHis ]

             _aFin100 := { { "CBCOORIG"  , _cBcoOrig, Nil },;
                           { "CAGENORIG" , _cAgeOrig, Nil },;
                           { "CCTAORIG"  , _cCtaOrig, Nil },;
                           { "CNATURORI" , _cNatOrig, Nil },;
                           { "CBCODEST"  , _cBcoDest, Nil },;
                           { "CAGENDEST" , _cAgeDest, Nil },;
                           { "CCTADEST"  , _cCtaDest, Nil },;
                           { "CNATURDES" , _cNatDest, Nil },;
                           { "CTIPOTRAN" , "TB"     , Nil },;
                           { "CDOCTRAN"  , _cDocTran, Nil },;
                           { "NVALORTRAN", _nVlrTran, Nil },;
                           { "CHIST100"  , _cHisTran, Nil },;
                           { "CBENEF100" , _cBenTran, Nil } }
             MSExecAuto( { |x, y, z| FinA100( x, y, z ) }, 0, _aFin100, 7 )
             If lMsErroAuto
                MostraErro()
             Else
                //Recno do ultimo registro gravado na SE5, portando
                //_aMovimen[_nPosDes][_nPosRec] := SE5->( Recno() )
                If _aFINA100[ _nPosOrig ] == 'R'
                   _nNumRec := SE5->( Recno() )
                Else
                   SE5->( DbSkip(-1) ) //Volto 1 registro
                   _nNumRec := SE5->( Recno() )
                Endif
             EndIf
          //else
          //   MessageBox( 'Não foi possível gravar o movimento de transferência.', 'Atenção', 48 )
          //Endif
       Endif
       SetFunName('ZFINF01')
Return _nNumRec

Static Function fGeraTra( oView )
       Local oDlg        := NIL
       Local oPanel      := Nil
       Local nEspLarg    := 0
       Local nEspLin     := 1
       Local cBcoOrig    := CriaVar( "E5_BANCO" )
       Local cBcoDest    := CriaVar( "E5_BANCO" )
       Local cAgenOrig   := CriaVar( "E5_AGENCIA" )
       Local cAgenDest   := CriaVar( "E5_AGENCIA" )
       Local cCtaOrig    := CriaVar( "E5_CONTA" )
       Local cCtaDest    := CriaVar( "E5_CONTA" )
       Local cNaturOri   := CriaVar( "E5_NATUREZ" )
       Local cNaturDes   := CriaVar( "E5_NATUREZ" )
       Local cDocTran    := CriaVar( "E5_NUMCHEQ" )
       Local cHist100    := CriaVar( "E5_HISTOR" )
       Local cBenef100   := CriaVar( "E5_BENEF" )
       Local nDiasDispo  := SUPERGETMV("MV_DIASCRD", .F., 0 )
       Local dDataCred   := dDatabase + nDiasDispo
       //Local dDtdisp     := dDatabase
       Local nValorTran  := 0
       Local nOpcA       := 0
       Local lSpbInUse   := SpbInUse()
       //Local aModalSPB   := { "1=TED", "2=CIP", "3=COMP" }
       //Local oModSPB     := NIL
       Local cModSpb     := ""
       Local _oView     as Object
       Local _oModel    as Object
       Local _oModelExt as Object
       Local _oModelMOV as Object
       Local _oModelCAB as Object
       Local _nLineEXT  as Numeric
       Local _nX, _nY

       Private oBcoOrig  := NIL
       Private oAgenOrig := NIL
       Private oCtaOrig  := NIL
       Private oBcoDest  := NIL
       Private oAgenDest := NIL
       Private oCtaDest  := NIL
       Private oDataCred := NIL
       Private cTipoTran := 'TB '

       cDocTran   := GravaData( dDataBase, .f., 5 ) + StrTran( Time(),":", "",/*nStart*/,/*nCount*/)

       _oModel    := FWModelActive()
       _oView     := Iif( ValType( oView ) == 'O', oView, FWViewActive() )
       _oModelExt := _oModel:GetModel('GRIDEXTR')
       _nLineEXT  := _oModelExt:nLine
       _oModelMOV := _oModel:GetModel('GRIDMOVI')
       _oModelCAB := _oModel:GetModel('MASTERCON')
       If _oModelExt:aCols[ _nLineExt ][aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CARTER' } )] == '1' //Receber
          cBcoDest  := _oModelExt:aCols[ _nLineExt ][aScan( _oModelExt:aHeader, { |x| x[2] == 'BANCO' } )]
          cAgenDest := _oModelExt:aCols[ _nLineExt ][aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_AGEEXT' } )]
          cCtaDest  := _oModelExt:aCols[ _nLineExt ][aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CONEXT' } )]
          cNaturDes := GETMV('ZP_PAR0029') //'RESG.APLIC'
          cNaturOri := GETMV('ZP_PAR0029') //'RESG.APLIC'
          lOrigem   := .t.
          lDestino  := .f.
       else //Pagar
          cBcoOrig  := _oModelExt:aCols[ _nLineExt ][aScan( _oModelExt:aHeader, { |x| x[2] == 'BANCO' } )]
          cAgenOrig := _oModelExt:aCols[ _nLineExt ][aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_AGEEXT' } )]
          cCtaOrig  := _oModelExt:aCols[ _nLineExt ][aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CONEXT' } )]
          cNaturOri := GETMV('ZP_PAR0029') //'APLICACAO'
          cNaturDes := GETMV('ZP_PAR0029') //'APLICACAO'
          lOrigem   := .f.
          lDestino  := .t.
       Endif
       nValorTran   := _oModelExt:aCols[ _nLineExt ][aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_VLREXT' } )]
       cHist100     := 'RESGATE APLICAÇÃO'
       cBenef100    := SubStr( Alltrim( SM0->M0_NOMECOM ), 1, TAMSX3( 'E5_BENEF' )[1] )
       DEFINE MSDIALOG oDlg FROM 32, 113 TO 340, 550 TITLE OemToAnsi( "Transferência Bancária" ) PIXEL
              oDlg:lMaximized := .F.
              oPanel := TPanel():New( 0, 0, '', oDlg, , .T., .T., , , 20, 20 )
              oPanel:Align := CONTROL_ALIGN_ALLCLIENT

              @ 000 + nEspLin, 004 + nEspLarg TO 025 + nEspLin, 172 + nEspLarg OF oPanel PIXEL LABEL "Origem"
              @ 027 + nEspLin, 004 + nEspLarg TO 052 + nEspLin, 172 + nEspLarg OF oPanel PIXEL LABEL "Destino"
              @ 056 + nEspLin, 004 + nEspLarg TO 079 + nEspLin, 172 + nEspLarg OF oPanel PIXEL
              @ 081 + nEspLin, 004 + nEspLarg TO 150 + nEspLin, 172 + nEspLarg OF oPanel PIXEL LABEL "Identificação"

              //Banco Origem - Extrato
              @ 005 + nEspLin, 008 + nEspLarg SAY OemToAnsi("Banco")    SIZE 19, 7 OF oPanel PIXEL 
              @ 005 + nEspLin, 042 + nEspLarg SAY OemToAnsi("Agência")  SIZE 25, 7 OF oPanel PIXEL
              @ 005 + nEspLin, 072 + nEspLarg SAY OemToAnsi("Conta")    SIZE 20, 7 OF oPanel PIXEL
              @ 005 + nEspLin, 122 + nEspLarg SAY OemToAnsi("Natureza") SIZE 28, 7 OF oPanel PIXEL

              @ 013 + nEspLin, 009 + nEspLarg MSGET oBcoOrig  VAR cBcoOrig  F3 "SA6" Picture "@S3"  Valid CarregaSa6( @cBcoOrig, @cAgenOrig, @cCtaOrig, .F., , , @cNaturOri )                                        WHEN lOrigem  SIZE 10, 08 OF oPanel PIXEL hasbutton
              @ 013 + nEspLin, 042 + nEspLarg MSGET oAgenOrig VAR cAgenOrig          Picture "@S5"                                                                                                                   WHEN lOrigem  SIZE 20, 08 OF oPanel PIXEL
              @ 013 + nEspLin, 072 + nEspLarg MSGET oCtaOrig  VAR cCtaOrig           Picture "@S10"                                                                                                                  WHEN lOrigem  SIZE 45, 08 OF oPanel PIXEL
              @ 013 + nEspLin, 122 + nEspLarg MSGET               cNaturOri F3 "SED"                Valid ExistCpo( "SED", @cNaturOri ) .AND. FinVldNat( .F., cNaturOri, 3 )                                     /*WHEN lOrigem*/  SIZE 47, 08 OF oPanel PIXEL hasbutton

              //Banco Destino
              @ 032 + nEspLin, 008 + nEspLarg SAY OemToAnsi("Banco")           SIZE 23, 7 OF oPanel PIXEL
              @ 032 + nEspLin, 042 + nEspLarg SAY OemToAnsi("Agência")         SIZE 27, 7 OF oPanel PIXEL
              @ 032 + nEspLin, 072 + nEspLarg SAY OemToAnsi("Conta")           SIZE 18, 7 OF oPanel PIXEL
              @ 032 + nEspLin, 122 + nEspLarg SAY OemToAnsi("Natureza")        SIZE 28, 7 OF oPanel PIXEL

              @ 040 + nEspLin, 009 + nEspLarg MSGET oBcoDest  VAR cBcoDest  F3 "SA6" Picture "@S3"  Valid CarregaSa6( @cBcoDest, @cAgenDest, @cCtaDest, .F., @cBenef100, , @cNaturDes)                               WHEN lDestino SIZE 10, 08 OF oPanel PIXEL hasbutton
              @ 040 + nEspLin, 042 + nEspLarg MSGET oAgenDest VAR cAgenDest          Picture "@S5"                                                                                                                   WHEN lDestino SIZE 20, 08 OF oPanel PIXEL
              @ 040 + nEspLin, 072 + nEspLarg MSGET oCtaDest  VAR cCtaDest           Picture "@S10" Valid If( ( cBcoDest + cAgenDest + cCtaDest ) <> ( cBcoOrig + cAgenOrig + cCtaOrig ), .T., oBcoDest:SetFocus() )	WHEN lDestino SIZE 45, 08 OF oPanel PIXEL
              @ 040 + nEspLin, 122 + nEspLarg MSGET               cNaturDes F3 "SED"                Valid ExistCpo( "SED", @cNaturDes ) .AND. FinVldNat( .F., cNaturDes, 3 )                                     /*WHEN lDestino*/ SIZE 47, 08 OF oPanel PIXEL hasbutton

              //"Data de Crédito"
              @ 058 + nEspLin, 008 + nEspLarg SAY OemToAnsi("Data de Crédito") SIZE 50, 7 OF oPanel PIXEL
              @ 066 + nEspLin, 009 + nEspLarg MSGET oDataCred VAR dDataCred                         Valid F100VlDtCr( dDataCred )                                                                                    WHEN .F.      SIZE 60, 08 OF oPanel PIXEL hasbutton

              //Dados complementares
              @ 087 + nEspLin, 008 + nEspLarg SAY OemToAnsi("Tipo Mov.")       SIZE 31, 7 OF oPanel PIXEL
              @ 087 + nEspLin, 042 + nEspLarg SAY OemToAnsi("Numero Doc.")     SIZE 43, 7 OF oPanel PIXEL
              @ 087 + nEspLin, 099 + nEspLarg SAY OemToAnsi("Valor")           SIZE 17, 7 OF oPanel PIXEL
              @ 106 + nEspLin, 009 + nEspLarg SAY OemToAnsi("Histórico")       SIZE 28, 7 OF oPanel PIXEL
              @ 125 + nEspLin, 009 + nEspLarg SAY OemToAnsi("Beneficiário")    SIZE 40, 7 OF oPanel PIXEL

              @ 096 + nEspLin, 009 + nEspLarg MSGET cTipoTran F3 "14" Picture "!!!"	Valid (!Empty(cTipoTran) .And. ExistCpo("SX5","14"+cTipoTran)) .and. ;
                                                                                          Iif( cTipoTran = "CH", fa050Cheque( cBcoOrig, cAgenOrig, cCtaOrig, cDocTran ), .T. ) .And. ;
                                                                                          Iif( cTipoTran = "CH" .or. cTipoTran = "TB", fa100DocTran( cBcoOrig, cAgenOrig, cCtaOrig, cTipoTran, @cDocTran ), .T. )    WHEN .F. SIZE 15 , 08 OF oPanel PIXEL hasbutton
              @ 096 + nEspLin, 042 + nEspLarg MSGET cDocTran          Picture PesqPict( "SE5", "E5_NUMCHEQ" )   Valid !Empty(cDocTran) .and. fa100doc( cBcoOrig, cAgenOrig, cCtaOrig, cDocTran )                     WHEN .F. SIZE 47 , 08 OF oPanel PIXEL
              @ 096 + nEspLin, 099 + nEspLarg MSGET nValorTran        PicTure PesqPict( "SE5", "E5_VALOR", 18 ) Valid nValorTran > 0 .and. If( cPaisLoc == "DOM", FA100V01( nValorTran, cTipoTran ), .T. )           WHEN .F. SIZE 66 , 08 OF oPanel PIXEL hasbutton
              @ 114 + nEspLin, 009 + nEspLarg MSGET cHist100          Picture "@S22"                            Valid !Empty(cHist100)                                                                                        SIZE 155, 08 OF oPanel PIXEL
              @ 133 + nEspLin, 009 + nEspLarg MSGET cBenef100         Picture "@S21"                            Valid !Empty(cBenef100)                                                                                       SIZE 155, 08 OF oPanel PIXEL

              DEFINE SBUTTON FROM 10, 180 TYPE 1 ENABLE ACTION (If(FinOkDiaCTB(),nOpca:=1,nOpca:=0),oDLg:End()) OF oPanel
              DEFINE SBUTTON FROM 23, 180 TYPE 2 ENABLE ACTION (nOpca:=0,oDlg:End()) OF oPanel
       ACTIVATE MSDIALOG oDlg CENTERED VALID  ( Iif( nOpca == 1 ,;
                                                If( !CarregaSa6( cBcoOrig, cAgenOrig, cCtaOrig, .T., , .T. ), ( oBcoOrig:SetFocus(), .F. ), .T. ) .and.;
                                                If( !CarregaSa6( cBcoDest, cAgendest, cCtadest, .T., , .T. ), ( oBcoDest:SetFocus(), .F. ), .T. ) .and.;
                                                IIf( cPaisLoc == "BRA", ValidHist( cHist100 ), .t. ) .and.;
                                                ValidTran( cTipoTran, cBcoDest, cAgenDest, cCtaDest, cBenef100, cDocTran, nValorTran, cNaturOri, cNaturDes, cBcoOrig, cAgenOrig,cCtaOrig).and.;
                                                IIF(lSpbInUse,SpbTipo("SE5",cModSpb,cTipoTran,"TR"),.T.),.T.) )
       If nOpca == 1 //Confirma
          For _nX := 1 To Len( _aConcNN )
              If Empty( _aConcNN[_nX][4] ) .and. Len( _aConcNN[_nX][5] ) == 1 //Garanto que somente 1 registro foi marcado para transferência
                 //1º Lançamento da transferência
                 _oModelMOV:AddLine()
                 _oModelMOV:SetValue( 'MOV_MARK'  , .t. )
                 _oModelMOV:SetValue( 'COR'       , u_FRETCOR( '4' ) )
                 _oModelMOV:SetValue( 'SEQDIG'    , cValToChar( _oModelMOV:nLine ) )
                 _oModelMOV:SetValue( 'E5_FILIAL' , FWxFilial("SE5") )
                 _oModelMOV:SetValue( 'E5_DATA'   , dDataBase        )
                 M->E5_DATA := dDataBase
                 _oModelMOV:SetValue( 'E5_DTDIGIT', dDataBase        )
                 _oModelMOV:SetValue( 'E5_DTDISPO', dDataBase        )
                 _oModelMOV:SetValue( 'E5_VENCTO' , dDataBase        )
                 M->E5_VENCTO  := dDataBase
                 M->E5_BANCO   := cBcoOrig
                 M->E5_AGENCIA := cAgenOrig
                 M->E5_CONTA   := cCtaOrig
                 _oModelMOV:SetValue( 'E5_VALOR'  , nValorTran       )
                 _oModelMOV:SetValue( 'E5_HISTOR' , cHist100         )
                 _oModelMOV:SetValue( 'E5_RECPAG' , Iif( _oModelExt:aCols[_nLineExt][ aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CARTER' } ) ] == '1', 'R', 'P' ) )
                 _oModelMOV:SetValue( 'E5_TIPODOC', 'TR'             )
                 _oModelMOV:SetValue( 'E5_X_REPA' , Iif( _oModelExt:aCols[_nLineExt][ aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CARTER' } ) ] == '1', 'R', 'P' ) )
                 _oModelMOV:SetValue( 'E5_BENEF'  , cBenef100        )
                 _oModelMOV:SetValue( 'E5_FILORIG', FWxFilial("SE5") )
                 _oModelMOV:SetValue( 'SE5_SOMA'  , nValorTran * Iif( _oModelExt:aCols[_nLineExt][ aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CARTER' } ) ] == '1', 1, -1 ) )
                 _oModelMOV:SetValue( 'E5_SEQCON' , _aConcNN[_nX][1] )
                 _oModelMOV:SetValue( 'E5_MOEDA'  , 'M1' )
                 M->E5_MOEDA := 'M1'
                 _oModelMOV:SetValue( 'E5_NUMCHEQ', Iif( _oModelExt:aCols[_nLineExt][ aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CARTER' } ) ] == '1', '', cDocTran ) )
                 _oModelMOV:SetValue( 'E5_DOCUMEN', Iif( _oModelExt:aCols[_nLineExt][ aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CARTER' } ) ] == '1', cDocTran, '' ) )
                 _oModelMOV:aCols[_oModelMov:nLine][ aScan( _oModelMOV:aHeader, { |x| x[2] == 'E5_MOEDA' } ) ] := 'M1'
                 If lOrigem
                    _oModelMOV:SetValue( 'E5_NATUREZ', cNaturDes )
                    _oModelMOV:SetValue( 'E5_BANCO'  , cBcoDest  )
                    _oModelMOV:SetValue( 'E5_AGENCIA', cAgenDest )
                    _oModelMOV:SetValue( 'E5_CONTA'  , cCtaDest  )

                    _oModelMOV:SetValue( 'E5_X_NORI' , cNaturOri )
                    _oModelMOV:SetValue( 'E5_X_BORI' , cBcoOrig  )
                    _oModelMOV:SetValue( 'E5_X_AORI' , cAgenOrig )
                    _oModelMOV:SetValue( 'E5_X_CORI' , cCtaOrig  )
                    _oModelMOV:SetValue( 'E5_X_NDES' , cNaturDes )
                    _oModelMOV:SetValue( 'E5_X_BDES' , cBcoDest  )
                    _oModelMOV:SetValue( 'E5_X_ADES' , cAgenDest )
                    _oModelMOV:SetValue( 'E5_X_CDES' , cCtaDest  )
                    _oModelMOV:SetValue( 'E5_X_ORIG' , Iif( lOrigem, 'R', 'P' ) )
                 Else
                    _oModelMOV:SetValue( 'E5_NATUREZ', cNaturOri )
                    _oModelMOV:SetValue( 'E5_BANCO'  , cBcoOrig  )
                    _oModelMOV:SetValue( 'E5_AGENCIA', cAgenOrig )
                    _oModelMOV:SetValue( 'E5_CONTA'  , cCtaOrig  )

                    _oModelMOV:SetValue( 'E5_X_NORI' , cNaturOri )
                    _oModelMOV:SetValue( 'E5_X_BORI' , cBcoOrig  )
                    _oModelMOV:SetValue( 'E5_X_AORI' , cAgenOrig )
                    _oModelMOV:SetValue( 'E5_X_CORI' , cCtaOrig  )
                    _oModelMOV:SetValue( 'E5_X_NDES' , cNaturDes )
                    _oModelMOV:SetValue( 'E5_X_BDES' , cBcoDest  )
                    _oModelMOV:SetValue( 'E5_X_ADES' , cAgenDest )
                    _oModelMOV:SetValue( 'E5_X_CDES' , cCtaDest  )
                    _oModelMOV:SetValue( 'E5_X_ORIG' , Iif( lOrigem, 'R', 'P' ) )
                 Endif
                 _aConcNN[_nX][3] += nValorTran * Iif( _oModelExt:aCols[_nLineExt][ aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CARTER' } ) ] == '1', 1, -1 )
                 aAdd(_aConcNN[_nX][6], { _aConcNN[_nX][1], _aConcNN[_nX][3], _oModelMOV:nLine})
                 
                 //2º Lançamento da Transferência
                 /*_oModelMOV:AddLine()
                 _oModelMOV:SetValue( 'MOV_MARK'  , .t. )
                 _oModelMOV:SetValue( 'COR'       , u_FRETCOR( '4' ) )
                 _oModelMOV:SetValue( 'SEQDIG'    , cValToChar( _oModelMOV:nLine ) )
                 _oModelMOV:SetValue( 'E5_FILIAL' , FWxFilial("SE5") )
                 _oModelMOV:SetValue( 'E5_DATA'   , dDataBase        )
                 M->E5_DATA := dDataBase
                 _oModelMOV:SetValue( 'E5_DTDIGIT', dDataBase        )
                 _oModelMOV:SetValue( 'E5_DTDISPO', dDataBase        )
                 _oModelMOV:SetValue( 'E5_VENCTO' , dDataBase        )
                 M->E5_VENCTO := dDataBase
                 M->E5_BANCO   := cBcoDest
                 M->E5_AGENCIA := cAgenDest
                 M->E5_CONTA   := cCtaDest
                 _oModelMOV:SetValue( 'E5_VALOR'  , nValorTran       )
                 _oModelMOV:SetValue( 'E5_HISTOR' , cHist100         )
                 _oModelMOV:SetValue( 'E5_NATUREZ', cNaturDes        )
                 _oModelMOV:SetValue( 'E5_BANCO'  , cBcoDest         )
                 _oModelMOV:SetValue( 'E5_AGENCIA', cAgenDest        )
                 _oModelMOV:SetValue( 'E5_CONTA'  , cCtaDest         )
                 _oModelMOV:SetValue( 'E5_RECPAG' , Iif( _oModelExt:aCols[_nLineExt][ aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CARTER' } ) ] == '1', 'P', 'R' ) )
                 _oModelMOV:SetValue( 'E5_TIPODOC', 'TR'             )
                 _oModelMOV:SetValue( 'E5_X_REPA' , Iif( _oModelExt:aCols[_nLineExt][ aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CARTER' } ) ] == '1', 'P', 'R' ) )
                 _oModelMOV:SetValue( 'E5_BENEF'  , cBenef100        )
                 _oModelMOV:SetValue( 'E5_FILORIG', FWxFilial("SE5") )
                 _oModelMOV:SetValue( 'SE5_SOMA'  , 0                ) //Para o segundo lançamento esse valor deve ser zero
                 _oModelMOV:SetValue( 'E5_SEQCON' , _aConcNN[_nX][1] )
                 _oModelMOV:SetValue( 'E5_MOEDA'  , 'M1' )
                 M->E5_MOEDA := 'M1'
                 _oModelMOV:SetValue( 'E5_NUMCHEQ', Iif( _oModelExt:aCols[_nLineExt][ aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CARTER' } ) ] == '1', cDocTran, '' ) )
                 _oModelMOV:SetValue( 'E5_DOCUMEN', Iif( _oModelExt:aCols[_nLineExt][ aScan( _oModelExt:aHeader, { |x| x[2] == 'IG_CARTER' } ) ] == '1', '', cDocTran ) )
                 _oModelMOV:aCols[_oModelMov:nLine][ aScan( _oModelMOV:aHeader, { |x| x[2] == 'E5_MOEDA' } ) ] := 'M1'
                 _aConcNN[_nX][4] := 'S'
                 aAdd(_aConcNN[_nX][6], { _aConcNN[_nX][1], _aConcNN[_nX][3], _oModelMOV:nLine})*/
                 nSE5Data := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_DTDISPO' } )
                 nSE5Age  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_AGENCIA' } )
                 nSE5Conta:= aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_CONTA'   } )
                 nSE5Num  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_NUMCHEQ' } )
                 nSE5Valor:= aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_VALOR'   } )
                 nSE5His  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_HISTOR'  } )
                 nSE5Nat  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_NATUREZ' } )
                 nSE5Fil  := aScan( _oModelMov:aHeader, { |x| x[2] == 'E5_FILIAL'  } )
                 //Troco a cor do Status e complemento os dados do extrato
                 For _nY := 1 To Len( _aConcNN[_nX][5] )
                     _oModelExt:GoLine( _aConcNN[_nX][5][_nY][3] )
                     _oModelExt:SetValue( 'COR', u_FRETCOR( '4' ) )
                     _oModelExt:SetValue( 'IG_DTMOVI' , _oModelMov:aCols[_oModelMOV:nLine][nSE5Data] )
                     _oModelExt:SetValue( 'IG_AGEMOV' , _oModelMov:aCols[_oModelMOV:nLine][nSE5Age]  )
                     _oModelExt:SetValue( 'IG_CONMOV' , _oModelMov:aCols[_oModelMOV:nLine][nSE5Conta])
                     _oModelExt:SetValue( 'IG_DOCMOV' , _oModelMov:aCols[_oModelMOV:nLine][nSE5Num]  )
                     _oModelExt:SetValue( 'IG_VLRMOV' , _oModelMov:aCols[_oModelMOV:nLine][nSE5Valor])
                     _oModelExt:SetValue( 'IG_HISMOV' , _oModelMov:aCols[_oModelMOV:nLine][nSE5His]  )
                     _oModelExt:SetValue( 'IG_NATMOV' , _oModelMov:aCols[_oModelMOV:nLine][nSE5Nat]  )
                     _oModelExt:SetValue( 'IG_FILORIG', _oModelMov:aCols[_oModelMOV:nLine][nSE5Fil]  )
                     _oModelExt:SetValue( 'IG_STATUS' , '3'                                          )
                     _oModelExt:SetValue( 'IG_EFETIVA', '1'                                          )
                 Next
                 _oModelExt:GoLine( 1 )
           EndIf
       Next
       _oView:Refresh( 'GRIDEXTR' )
       _oView:Refresh( 'GRIDMOVI' )

       Endif
Return

Static Function fExcluiE( oView )
       Local _oModel    := FWModelActive()
       Local _oModelExt := _oModel:GetModel('GRIDEXTR')
       Local _oModelMOV := _oModel:GetModel('GRIDMOVI')
       Local _oModelCAB := _oModel:GetModel('MASTERCON')
       Local _nY
       _oView           := Iif( ValType( oView ) == 'O', oView, FWViewActive() )
       For _nY := 1 To _oModelExt:Length()
           _oModelExt:GoLine( _nY )
           If _oModelExt:GetValue( "EXT_MARK" ) .and. !( _oModelExt:GetValue( 'COR' ) $ 'BR_AZUL.BR_VERDE' )
              _oModelExt:SetValue( 'COR', 'BR_PRETO' )
              _oModelExt:SetValue( 'SIG_SOMA', 0.01 )
           Endif
       Next
       /*********************************************************************************************/
       If Len( _oModelMOV:aCols ) <= 0 .or. Empty( _oModelMOV:aCols[1][1] )
          _oModelMOV:AddLine()
          _oModelMOV:SetValue( 'MOV_MARK'  , .t. )
          _oModelMOV:SetValue( 'COR'       , 'BR_PRETO' )
          _oModelMOV:SetValue( 'SEQDIG'    , cValToChar( _oModelMOV:nLine ) )
          _oModelMOV:SetValue( 'E5_FILIAL' , FWxFilial("SE5")      )
          _oModelMOV:SetValue( 'E5_DATA'   , dDataBase             )
          M->E5_DATA := dDataBase
          _oModelMOV:SetValue( 'E5_DTDIGIT', dDataBase             )
          _oModelMOV:SetValue( 'E5_DTDISPO', dDataBase             )
          _oModelMOV:SetValue( 'E5_VENCTO' , dDataBase             )
          _oModelMOV:SetValue( 'E5_VALOR'  , 0.01                  )
          _oModelMOV:SetValue( 'E5_HISTOR' , 'Exclusão do extrato' )
          _oModelMOV:SetValue( 'E5_RECPAG' , 'R'                   )
          _oModelMOV:SetValue( 'E5_TIPODOC', '01'                  )
          _oModelMOV:SetValue( 'E5_X_REPA' , 'R'                   )
          _oModelMOV:SetValue( 'E5_BENEF'  , 'Exclusão do extrato' )
          _oModelMOV:SetValue( 'E5_FILORIG', FWxFilial("SE5")      )
          _oModelMOV:SetValue( 'SE5_SOMA'  , 0.01                  )
          _oModelMOV:SetValue( 'E5_SEQCON' , 'E00000001'           )
          _oModelMOV:SetValue( 'E5_MOEDA'  , 'M1'                  )
          _oModelMOV:SetValue( 'E5_NATUREZ', 'SANGRIA'             )
          _oModelMOV:SetValue( 'E5_BANCO'  , _oModelCAB:GetValue("BANCO")   )
          _oModelMOV:SetValue( 'E5_AGENCIA', _oModelCAB:GetValue("AGENCIA") )
          _oModelMOV:SetValue( 'E5_CONTA'  , _oModelCAB:GetValue("CONTA")   )
          M->E5_MOEDA := 'M1'
          _oModelMOV:SetValue( 'E5_DOCUMEN', 'Exclusão do extrato' )
          _oModelMOV:aCols[_oModelMov:nLine][ aScan( _oModelMOV:aHeader, { |x| x[2] == 'E5_MOEDA' } ) ] := 'M1'
       Endif
       /*********************************************************************************************/
       _oModel:getModel( 'GRIDMOVI' ):SetNoInsertLine( .T. )
       _oModel:getModel( 'GRIDMOVI' ):SetNoUpdateLine( .T. )
       _oModel:getModel( 'GRIDMOVI' ):SetNoDeleteLine( .T. )
       _oView:Refresh( 'GRIDEXTR' )
       _oView:Refresh( 'GRIDMOVI' )
Return
