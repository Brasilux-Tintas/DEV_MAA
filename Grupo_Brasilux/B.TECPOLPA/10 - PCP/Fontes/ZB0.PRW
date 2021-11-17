// #########################################################################################
// Projeto: MIRVI
// Modulo : SIGAPCP
// Fonte  : ZPCPF19
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 13/10/16 | Luis Gustavo - MR | Manutenção do refugo
//          |                   | R=Refugo / E=Extrudado / M=Moido / D=Desmontado / C=Cancel       
// ---------+-------------------+-----------------------------------------------------------
#Include 'totvs.ch'
#Include 'fwmvcdef.ch'
#Include 'colors.ch'

User Function ZPCPF19()
     Local oBrowse
     //Local aIndex := {} 
     //Local cFiltro := " ZB0_TPAPT <> ' ' " //Expressao do Filtro
     Private aRotina  := MenuDef()
     
     oBrowse := FWMBrowse():New()
     oBrowse:SetAlias('CB0')
     oBrowse:SetDescription('Manutenção de Apontamentos de Refugos')
     //oBrowse:SetFilterDefault( "ZB0_TPAPT $ 'C.R.E.M.D'" )
     oBrowse:SetUseCursor(.F.)
     //oBrowse:AddLegend( "ZB0_TPAPT == 'C'", "BR_PRETO"  , "Cancelada" )
     //oBrowse:AddLegend( "ZB0_TPAPT == 'R'", "BR_AZUL"   , "Refugo"    )
     //oBrowse:AddLegend( "ZB0_TPAPT == 'D'", "BR_MARROM" , "Desmontado")
     //oBrowse:AddLegend( "ZB0_TPAPT == 'M'", "BR_LARANJA", "Moido"     )
     //oBrowse:AddLegend( "ZB0_TPAPT == 'E'", "BR_CINZA"  , "Extrudado" )
     
     oBrowse:Activate()

     //U_ZCFGF07( "ZPCPF19" ) //LGS#20161013 - Log de uso da rotina
Return

Static Function MenuDef()
       Local aRotina := {}
       
       ADD OPTION aRotina Title 'Pesquisar'  Action 'PesqBrw'          OPERATION 1 ACCESS 0
       ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.ZPCPF19'  OPERATION 2 ACCESS 0 //Visualizar
       ADD OPTION aRotina Title 'Imprimir'   Action 'U_ZPCPF19I()'     OPERATION 8 ACCESS 0 //Impressão
       ADD OPTION aRotina Title 'Cancelar'   Action 'U_ZPCPF19C()'     OPERATION 8 ACCESS 0 //Cancelar
       ADD OPTION aRotina Title 'Manutenção' Action 'U_ZPCPF19M()'     OPERATION 8 ACCESS 0 //Manutenção
       ADD OPTION aRotina Title 'Legenda'    Action 'U_ZPCPF09L()'     OPERATION 8 ACCESS 0 //Leganda
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author MS Consultoria

@since 13/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
       Local oView
       Local oModel := ModelDef()

       Local oStr1:= FWFormStruct(2, 'ZB0')

       oView := FWFormView():New()
       oView:SetModel(oModel)
       oView:AddField('FORM1' , oStr1,'FIELD1' ) 
       oView:CreateHorizontalBox( 'BOXFORM1', 100)
       oView:SetOwnerView('FORM1','BOXFORM1')
       oView:SetViewProperty('FORM1' , 'ONLYVIEW' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author MS Consultoria

@since 13/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
       Local oModel
       Local oStr1:= FWFormStruct(1,'ZB0')

       oModel := MPFormModel():New('ModelName')
       oModel:SetDescription('Manutenção de Apontamentos de Refugo')
       oModel:addFields('FIELD1',,oStr1)
       oModel:SetPrimaryKey({ 'ZB0_FILIAL', 'ZB0_CODBAR' })
       oModel:getModel('FIELD1'):SetDescription('Manutenção de Apontamentos de Refugo')

Return oModel

User Function ZPCPF19I()
     If ZB0->ZB0_TPAPT <> 'C'
        If ZB0->ZB0_TPAPT = 'D'
           If SubStr( ZB0->ZB0_CODBAR, 1, 1 ) == 'A'
              _cTipImp := 'A'  // AI
           Else
              _cTipImp := 'N'  //A Moer
           Endif
        ElseIf ZB0->ZB0_TPAPT = 'E'
               _cTipImp := 'E'  //Extrudado
        ElseIf ZB0->ZB0_TPAPT = 'M'
               _cTipImp := 'M'  //Moido
        ElseIf ZB0->ZB0_TPAPT = 'R'
               _cTipImp := 'R'  //Refugo
        Endif

        u_ZPCPE02_I( ZB0->ZB0_CODBAR, ZB0->ZB0_OP, ZB0->ZB0_QTDEKG, 1      , ZB0->ZB0_LOTECT + "/" + ZB0->ZB0_NUMLOT, ZB0->ZB0_PROD, _cTipImp )
     Else
        MsgStop( "Etiqueta Cancelada não poderá ser impressa" )
     Endif
Return

User Function ZPCPF19C()
     If ZB0->ZB0_CONFER == 'S'
        MsgStop("Etiqueta já foi conferida e não pode ser cancelada.")
     Else
        If ZB0->ZB0_TPAPT $ 'R.M.E.D'
           If MsgYesNo("Deseja realmente cancelar essa etiqueta?" )
              RecLock("ZB0", .f.)
                 ZB0->ZB0_TPAPT := "C"
              ZB0->( MsUnLock() )
           Endif
        ElseIf ZB0->ZB0_TPAPT == 'C'
               If MsgYesNo("Deseja retornar essa etiqueta para leitura?" )
                  RecLock("ZB0", .f.)
                     ZB0->ZB0_TPAPT := "R"
                  ZB0->( MsUnLock() )
               Endif
        Endif
     Endif 
Return

User Function ZPCPF19M()
     Private cSay1Ref   := Space(1)
     Private nCBx1Ref  
     
     SetPrvt( "oFon1Ref", "oDlg1Ref", "oSay1Ref", "oCBx1Ref", "oBtn1Ref", "oBtn2Ref" )
     
     If !ZB0->ZB0_TPAPT $ 'M.E'
        MsgAlert(" Atenção, essa rotina somente será valida para lotes de Moidos e extrudados.", "Verifique..." )
        Return
     Endif
     oFon1Ref   := TFont():New( "Arial Narrow", 0, -21, , .T., 0, , 700, .F., .F., , , , , , )
     
     oDlg1Ref   := MSDialog():New( 092, 232, 231, 521, "Manutenção de Refugos", , , .F., , , , , , .T., , , .T. )
     oSay1Ref   := TSay():New( 008, 004, { || "Opção:" }, oDlg1Ref, , oFon1Ref, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 036, 012 )
     oCBx1Ref   := TComboBox():New( 008, 060, { |u| If( PCount() > 0, nCBx1Ref := u, nCBx1Ref ) }, { "Dividir", "Juntar" }, 072, 016, oDlg1Ref, , , , CLR_BLACK, CLR_WHITE, .T., oFon1Ref, "", , , , , , , nCBx1Ref )

     oBtn1Ref   := TButton():New( 040, 004, "Confirma", oDlg1Ref, { || fManutL()      }, 052, 016, , oFon1Ref, , .T., , "", , , , .F. )
     oBtn2Ref   := TButton():New( 040, 080, "Sair"    , oDlg1Ref, { || oDlg1Ref:End() }, 052, 016, , oFon1Ref, , .T., , "", , , , .F. )

     oDlg1Ref:Activate( , , , .T. )

Return

Static Function fManutL()
       Local nOpc         := GD_UPDATE
       Private cSay1Man   := Space(1)
       Private cSay2Man   := Space(1)
       Private cSay3Man   := Space(1)
       Private cSay4Man   := Space(1)
       Private cSay5Man   := Space(1)
       Private cSay6Man   := Space(1)
       Private cSay7Man   := Space(1)

       Private cGet1Man   := ZB0->ZB0_LOTECT
       Private cGet2Man   := ZB0->ZB0_NUMLOT
       Private cGet3Man   := ZB0->ZB0_PROD
       Private cGet6Man   := Space(136)
       Private nCBx1Man  
       Private nGet4Man   := ZB0->ZB0_QTDEKG
       Private nGet7Man   := 0

       Private noBrw1ZB0  := 0
       Private aCoBrw1ZB0 := {}
       Private aHoBrw1ZB0 := {}
       Private aAlter     := Iif( oCBx1Ref:nAt == 1, { "ZB0_QTDEKG" }, { } )
       	
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oFon1Man", "oDlg1Man", "oSay1Man", "oSay2Man", "oSay3Man", "oSay4Man", "oSay5Man", "oGet1Man", "oGet2Man", "oGet3Man" )
       SetPrvt("oCBx1Man", "oGet4Man", "oSay6Man", "oSay7Man", "oGet7Man" )

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oFon1Man     := TFont():New( "Arial Narrow", 0, -21, , .T., 0, , 700, .F., .F., , , , , , )
       oDlg1Man     := MSDialog():New( 092, 232, 592, 927, "Manutenção - " + Iif( oCBx1Ref:nAt == 1, "Dividir", "Juntar" ), , , .F., , , , , , .T., , , .T. )

       oSay1Man   := TSay():New( 005, 005, {|| "Lote:"    }, oDlg1Man, , oFon1Man, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 026, 012 )
       oSay2Man   := TSay():New( 005, 105, {|| "Sub-lote:"}, oDlg1Man, , oFon1Man, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 041, 012 )
       oSay3Man   := TSay():New( 005, 202, {|| "Produto:" }, oDlg1Man, , oFon1Man, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 041, 012 )
       oSay4Man   := TSay():New( 026, 005, {|| "Qtde:"    }, oDlg1Man, , oFon1Man, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 026, 012 )
       If oCBx1Ref:nAt == 1  //Dividir
          //oSay5Man   := TSay():New( 026, 105, {|| "Emb.:"    }, oDlg1Man, , oFon1Man, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 028, 012 )
          oSay7Man   := TSay():New( 026, 202, {|| "Unid.:"   }, oDlg1Man, , oFon1Man, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 028, 012 )
       Else  //Juntar
          oSay6Man   := TSay():New( 047, 005, {|| "Etq.:"    }, oDlg1Man, , oFon1Man, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 028, 012 )
       Endif
       oGet1Man   :=      TGet():New( 005, 035, { |u| If( PCount() > 0, cGet1Man := u, cGet1Man ) }, oDlg1Man, 060, 013, ''               , , CLR_BLACK, CLR_WHITE, oFon1Man, , , .T., "", , , .F., .F., , .T., .F., "", "cGet1Man", , )
       oGet2Man   :=      TGet():New( 005, 150, { |u| If( PCount() > 0, cGet2Man := u, cGet2Man ) }, oDlg1Man, 040, 013, ''               , , CLR_BLACK, CLR_WHITE, oFon1Man, , , .T., "", , , .F., .F., , .T., .F., "", "cGet2Man", , )
       oGet3Man   :=      TGet():New( 005, 243, { |u| If( PCount() > 0, cGet3Man := u, cGet3Man ) }, oDlg1Man, 089, 013, ''               , , CLR_BLACK, CLR_WHITE, oFon1Man, , , .T., "", , , .F., .F., , .T., .F., "", "cGet3Man", , )
       oGet4Man   :=      TGet():New( 026, 035, { |u| If( PCount() > 0, nGet4Man := u, nGet4Man ) }, oDlg1Man, 060, 013, '@E 999,999.9999', , CLR_BLACK, CLR_WHITE, oFon1Man, , , .T., "", , , .F., .F., , .T., .F., "", "nGet4Man", , )
       If oCBx1Ref:nAt == 1 //Dividir
          //oCBx1Man   := TComboBox():New( 025, 150, { |u| If( PCount() > 0, nCBx1Man := u, nCBx1Man ) }, { "Octa", "Bag"}, 042, 020, oDlg1Man, , , , CLR_BLACK, CLR_WHITE, .T., oFon1Man, "", , , , , , , nCBx1Man )
          oGet7Man   :=      TGet():New( 026, 243, { |u| If( PCount() > 0, nGet7Man := u, nGet7Man ) }, oDlg1Man, 30, 013, ''               , , CLR_BLACK, CLR_WHITE, oFon1Man, , , .T., "", , , .F., .F., , .F., .F., "", "nGet7Man", , )
       Else  //Juntar
          oGet6Man   :=      TGet():New( 047, 035, { |u| If( PCount() > 0, cGet6Man := u, cGet6Man ) }, oDlg1Man, 301, 013, ''               , , CLR_BLACK, CLR_WHITE, oFon1Man, , , .T., "", , , .F., .F., , .F., .F., "", "cGet6Man", , )
       Endif
       
       MHoBrw1ZB0()
       MCoBrw1ZB0()

       oBrw1ZB0   := MsNewGetDados():New(070, 004, 220, 344, nOpc, 'AllwaysTrue()', 'AllwaysTrue()', '', aAlter, 0, 99, 'U_ZPCPF09V()', '', 'AllwaysTrue()', oDlg1Man, aHoBrw1ZB0, aCoBrw1ZB0 )
       
       oBtn1Man   := TButton():New( 228, 210, "Confirma", oDlg1Man, { || fGrvMan()                      }, 052, 016, , oFon1Ref, , .T., , "", , , , .F. )
       oBtn2Man   := TButton():New( 228, 290, "Sair"    , oDlg1Man, { || oDlg1ref:End(), oDlg1Man:End() }, 052, 016, , oFon1Man, , .T., , "", , , , .F. )

       //Validações
       If oCBx1Ref:nAt == 2 //Somente para juntar
          oGet6Man:SetFocus()
          oGet6Man:bValid    := { || fVldEtq( ) }
       Endif

       If oCBx1Ref:nAt == 1
          oGet7Man:SetFocus()
          oGet7Man:bValid := { || fVldQtd( ) }
       Endif
       oDlg1Man:Activate(,,,.T.)
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrw1ZB0() - Monta aHeader da MsNewGetDados para o Alias: ZB0
	ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrw1ZB0()
       Local _lOpen        := .F. //LGS#20200210 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200210 - Adequação para release 12.1.25

       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200210 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0

       If !_lOpen //LGS#20200210 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 14/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("ZB0")
       While !Eof() .and. SX3->X3_ARQUIVO == "ZB0"
             If X3Uso( SX3->X3_USADO ) .and. cNivel >= SX3->X3_NIVEL .and. Alltrim( SX3->X3_CAMPO ) $ 'ZB0_OP|ZB0_DATA|ZB0_PROD|ZB0_LOTECT|ZB0_NUMLOT|ZB0_QTDEKG|ZB0_CODBAR'
                noBrw1ZB0++
                aAdd( aHoBrw1ZB0, { Trim(X3Titulo()),;
                                    SX3->X3_CAMPO   ,;
                                    SX3->X3_PICTURE ,;
                                    SX3->X3_TAMANHO ,;
                                    SX3->X3_DECIMAL ,;
                                    ""              ,;
                                    ""              ,;
                                    SX3->X3_TIPO    ,;
                                    ""              ,;
                                    ""              })
             EndIf
             SX3->( DbSkip( ) )
       EndDo*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("ZB0") )
       While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "ZB0"
             If X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .and. Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZB0_OP|ZB0_DATA|ZB0_PROD|ZB0_LOTECT|ZB0_NUMLOT|ZB0_QTDEKG|ZB0_CODBAR'
                noBrw1ZB0++
                aAdd( aHoBrw1ZB0, { ( _cAliasSX3 )->( X3_Titulo ) ,;
                                    ( _cAliasSX3 )->( X3_CAMPO )  ,;
                                    ( _cAliasSX3 )->( X3_PICTURE ),;
                                    ( _cAliasSX3 )->( X3_TAMANHO ),;
                                    ( _cAliasSX3 )->( X3_DECIMAL ),;
                                    ""                            ,;
                                    ""                            ,;
                                    ( _cAliasSX3 )->( X3_TIPO )   ,;
                                    ""                            ,;
                                    ""                            })
             EndIf
             ( _cAliasSX3 )->( DbSkip( ) )
       EndDo

       DbSelectArea( _cAliasSX3 )
       DbCloseArea()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrw1ZB0() - Monta aCols da MsNewGetDados para o Alias: ZB0
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrw1ZB0()
       //Local aAux := {}
       Local nI

       aAdd( aCoBrw1ZB0, Array( noBrw1ZB0 + 1 ) )
       For nI := 1 To noBrw1ZB0
           aCoBrw1ZB0[1][nI] := CriaVar( aHoBrw1ZB0[ nI ][ 2 ] )
       Next
       aCoBrw1ZB0[ 1 ][ noBrw1ZB0 + 1 ] := .F.
Return

Static Function fVldEtq( )
       Local _lRet    := .t.
       Local _nORDPRO := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_OP'     } )
       Local _nDATPRO := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_DATA'   } )
       Local _nCODPRO := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_PROD'   } )
       Local _nLOTPRO := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_LOTECT' } )
       Local _nSUBPRO := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_NUMLOT' } )
       Local _nQTDEKG := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_QTDEKG' } )
       Local _nCODBAR := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_CODBAR' } )
       //Local _nQTDEPC := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_QUANT'  } ) 

       If Alltrim( cGet6Man ) == Alltrim( ZB0->ZB0_CODBAR )
          MsgAlert( "Atenção esse é o lote principal para JUNTAR, e já está sendo considerado.", "Atenção")
          _lRet := .f.
          cGet6Man := space( 136 )
          oGet6Man:Refresh()
          oGet6Man:SetFocus()
       Elseif !Empty( cGet6Man )
              If SubStr( cGet1Man, 1, 2) == SubStr( cGet6Man, 1, 2)
                 DbSelectArea( "ZB0" )
                 ZB0->( DbSetOrder( 2 ) )
                 If ZB0->( DbSeek( xFilial("ZB0") + cGet6Man ) )
                    If Empty( oBrw1ZB0:aCols[ 1 ][ _nCODPRO ] )
                       oBrw1ZB0:aCols[ 1 ][ _nORDPRO ] := ZB0->ZB0_OP
                       oBrw1ZB0:aCols[ 1 ][ _nDATPRO ] := ZB0->ZB0_DATA
                       oBrw1ZB0:aCols[ 1 ][ _nCODPRO ] := ZB0->ZB0_PROD
                       oBrw1ZB0:aCols[ 1 ][ _nLOTPRO ] := ZB0->ZB0_LOTECT
                       oBrw1ZB0:aCols[ 1 ][ _nSUBPRO ] := ZB0->ZB0_NUMLOT
                       oBrw1ZB0:aCols[ 1 ][ _nQTDEKG ] := ZB0->ZB0_QTDEKG
                       oBrw1ZB0:aCols[ 1 ][ _nCODBAR ] := ZB0->ZB0_CODBAR
                    Else   
                       aAdd( oBrw1ZB0:aCols, Array( Len( oBrw1ZB0:aHeader ) + 1 ) )
                       oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ _nORDPRO ] := ZB0->ZB0_OP
                       oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ _nDATPRO ] := ZB0->ZB0_DATA
                       oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ _nCODPRO ] := ZB0->ZB0_PROD
                       oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ _nLOTPRO ] := ZB0->ZB0_LOTECT
                       oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ _nSUBPRO ] := ZB0->ZB0_NUMLOT
                       oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ _nQTDEKG ] := ZB0->ZB0_QTDEKG
                       oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ _nCODBAR ] := ZB0->ZB0_CODBAR
                       oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ Len( oBrw1ZB0:aHeader ) + 1 ] := .F.
                    Endif
                    cGet6Man := space( 136 )
                    oGet6Man:Refresh()
                    oGet6Man:SetFocus()
                    oBrw1ZB0:Refresh()
                 Else
                    MsgAlert( "Atenção esse etiqueta não foi encontrada.", "Atenção")
                    _lRet := .f.
                    cGet6Man := space( 136 )
                    oGet6Man:Refresh()
                    oGet6Man:SetFocus()
                 Endif
              Else
                 MsgAlert( "Atenção somente etiquetas do mesmo tipo de produto podem ser juntadas.", "Atenção")
                 _lRet := .f.
                 cGet6Man := space( 136 )
                 oGet6Man:Refresh()
                 oGet6Man:SetFocus()
              Endif
       Endif
Return _lRet

Static Function fVldQtd( )
       Local _lRet := .t.
       Local _nORDPRO := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_OP'     } )
       Local _nDATPRO := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_DATA'   } )
       Local _nCODPRO := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_PROD'   } )
       Local _nLOTPRO := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_LOTECT' } )
       Local _nSUBPRO := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_NUMLOT' } )
       Local _nQTDEKG := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_QTDEKG' } )
       Local _nCODBAR := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_CODBAR' } )
       //Local _nQTDEPC := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_QUANT'  } ) 
       Local _nY
       If nGet7Man <= 1
          MsgAlert( "Para divisão de embalagens a quantidade deve ser maior que 1.", "Atenção" )
          _lRet := .f.
          oGet7Man:SetFocus()
       Else
          oBrw1ZB0:aCols := {}
          For _nY := 1 to nGet7Man
              aAdd( oBrw1ZB0:aCols, Array( Len( oBrw1ZB0:aHeader ) + 1 ) )
              //If Empty( oBrw1ZB0:aCols[ 1 ][ _nCODPRO ] )
              //   oBrw1ZB0:aCols[ 1 ][ _nORDPRO ] := ZB0->ZB0_OP
              //   oBrw1ZB0:aCols[ 1 ][ _nDATPRO ] := ZB0->ZB0_DATA
              //   oBrw1ZB0:aCols[ 1 ][ _nCODPRO ] := ZB0->ZB0_PROD
              //   oBrw1ZB0:aCols[ 1 ][ _nLOTPRO ] := ZB0->ZB0_LOTECT
              //   oBrw1ZB0:aCols[ 1 ][ _nSUBPRO ] := ZB0->ZB0_NUMLOT
              //   oBrw1ZB0:aCols[ 1 ][ _nQTDEKG ] := ZB0->ZB0_QTDEKG / nGet7Man
              //   oBrw1ZB0:aCols[ 1 ][ _nCODBAR ] := ZB0->ZB0_CODBAR
              //Else   
              //   aAdd( oBrw1ZB0:aCols, Array( Len( oBrw1ZB0:aHeader ) + 1 ) )
                 oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ _nORDPRO ] := ZB0->ZB0_OP
                 oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ _nDATPRO ] := ZB0->ZB0_DATA
                 oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ _nCODPRO ] := ZB0->ZB0_PROD
                 oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ _nLOTPRO ] := ZB0->ZB0_LOTECT
                 oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ _nSUBPRO ] := ZB0->ZB0_NUMLOT
                 oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ _nQTDEKG ] := ZB0->ZB0_QTDEKG / nGet7Man
                 oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ _nCODBAR ] := ZB0->ZB0_CODBAR
                 oBrw1ZB0:aCols[ Len( oBrw1ZB0:aCols ) ][ Len( oBrw1ZB0:aHeader ) + 1 ] := .F.
              //Endif
          Next
          oBrw1ZB0:Refresh()
       Endif
Return _lRet

Static Function fGrvMan( )
       //Local _nORDPRO := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_OP'     } )
       //Local _nDATPRO := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_DATA'   } )
       //Local _nCODPRO := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_PROD'   } )
       Local _nLOTPRO := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_LOTECT' } )
       Local _nSUBPRO := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_NUMLOT' } )
       Local _nQTDEKG := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_QTDEKG' } )
       //Local _nCODBAR := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_CODBAR' } )
       //Local _nQTDEPC := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_QUANT'  } ) 
       Local _nY
       DbSelectArea("ZB0")
       ZB0->( DbSetOrder( 1 ) )

       If oCBx1Ref:nAt == 1 //Dividir
          //Validar a Soma e confirmar antes de gravar
          _nSomTot := 0
          For _nY := 1 To Len( oBrw1ZB0:aCols )
              _nSomTot += oBrw1ZB0:aCols[ _nY ][ _nQTDEKG ]
          Next
          If MsgYesNo( "Confirma a divisão de " + Transform( _nSomTot, "@R 999,999.999999" ) + " em " + TransForm( nGet7Man, "@E 999" ) + " etiquetas?", "Confirme" )
             //Cancelo a Etiqueta principal
             If ZB0->( DbSeek( xFilial("ZB0") + cGet1Man + cGet2Man ) )
                RecLock( "ZB0", .f. )
                   ZB0->ZB0_TPAPT  := "C"
                   ZB0->ZB0_DOCDES := "D" + Alltrim( cGet1Man )
                MsUnLock()
             Endif
             _cNumLot := '1' + SubStr( cGet2Man, 2, 5 )
             For _nY := 1 To Len( oBrw1ZB0:aCols )
                 //Novo lote gerado e chamada para impressão da etiqueta
                 RecLock( "ZB0", .t. )
                    ZB0->ZB0_FILIAL := xFilial("ZB0")
                    ZB0->ZB0_USERID := __cUserID
                    ZB0->ZB0_USNAME := cUserName
                    ZB0->ZB0_DATA   := dDataBase
                    ZB0->ZB0_PROD   := cGet3Man
                    ZB0->ZB0_LOTECT := cGet1Man
                    ZB0->ZB0_NUMLOT := cGet2Man
                    ZB0->ZB0_QUANT  := 0
                    ZB0->ZB0_QTDEKG := oBrw1ZB0:aCols[ _nY ][ _nQTDEKG ] - Iif( nCBx1Man == 1,  35.5, 7.5 ) 
                    ZB0->ZB0_TPAPT  := SubStr( cGet1Man, 1, 1 )
                    ZB0->ZB0_CODBAR := ZB0->ZB0_LOTECT + ZB0->ZB0_NUMLOT + TransForm( ZB0->ZB0_QTDEKG, "@E 999,999.999" )
                    ZB0->ZB0_DOCDES := "JUNTAETQ"
                 MsUnLock()
                 u_ZPCPE02_I( ZB0->ZB0_CODBAR, ZB0->ZB0_OP, ZB0->ZB0_QTDEKG, 1      , ZB0->ZB0_LOTECT + "/" + ZB0->ZB0_NUMLOT, ZB0->ZB0_PROD, ZB0->ZB0_TPAPT )
             Next
          Endif
          oDlg1ref:End()
          oDlg1Man:End()
       Else //Juntar
          //Validar a Soma e confirmar antes de gravar
          _nSomTot := 0
          _nSomTot += nGet4Man
          For _nY := 1 To Len( oBrw1ZB0:aCols )
              _nSomTot += oBrw1ZB0:aCols[ _nY ][ _nQTDEKG ]
          Next
          If MsgYesNo( "Confirma juntar " + Transform( _nSomTot, "@R 999,999.999999" ) + " em somente uma etiqueta?", "Confirme" )
             //Busco sequencia de lote para Moido/Extrudado
             _cZB0LOT := SubStr( cGet1Man, 1, 2 ) + GetMV("ZP_PAR075")
             PutMV( "ZP_PAR075", Soma1( SubStr( _cZB0LOT, 3, 6 ) ) )
             
             If ZB0->( DbSeek( xFilial("ZB0") + cGet1Man + cGet2Man ) )
                RecLock( "ZB0", .f. )
                   ZB0->ZB0_TPAPT  := "C"
                   ZB0->ZB0_DOCDES := "J" + Alltrim( _cZB0LOT )
                MsUnLock()
             Endif
             For _nY := 1 To Len( oBrw1ZB0:aCols )
                 If ZB0->( DbSeek( xFilial("ZB0") + oBrw1ZB0:aCols[ _nY][ _nLOTPRO ] + oBrw1ZB0:aCols[ _nY][ _nSUBPRO ] ) )
                    RecLock( "ZB0", .f. )
                       ZB0->ZB0_TPAPT  := "C"
                       ZB0->ZB0_DOCDES := "J" + Alltrim( _cZB0LOT )
                    MsUnLock()
                 Endif
             Next

             //Novo lote gerado e chamada para impressão da etiqueta
             RecLock( "ZB0", .t. )
                ZB0->ZB0_FILIAL := xFilial("ZB0")
                ZB0->ZB0_USERID := __cUserID
                ZB0->ZB0_USNAME := cUserName
                ZB0->ZB0_DATA   := dDataBase
                ZB0->ZB0_PROD   := cGet3Man
                ZB0->ZB0_LOTECT := _cZB0LOT
                ZB0->ZB0_NUMLOT := '200001'
                ZB0->ZB0_QUANT  := 0
                ZB0->ZB0_QTDEKG := _nSomTot - Iif( nCBx1Man == 1,  35.5, 7.5 )
                ZB0->ZB0_TPAPT  := SubStr( _cZB0LOT, 1, 1 )
                ZB0->ZB0_CODBAR := ZB0->ZB0_LOTECT + ZB0->ZB0_NUMLOT + TransForm( ZB0->ZB0_QTDEKG, "@E 999,999.999" )
                ZB0->ZB0_DOCDES := "JUNTAETQ"
             MsUnLock()

             //Impressão da etiqueta
             u_ZPCPE02_I( ZB0->ZB0_CODBAR, ZB0->ZB0_OP, ZB0->ZB0_QTDEKG, 1      , ZB0->ZB0_LOTECT + "/" + ZB0->ZB0_NUMLOT, ZB0->ZB0_PROD, ZB0->ZB0_TPAPT )
          Endif
          oDlg1ref:End()
          oDlg1Man:End()
       Endif
Return

User Function ZPCPF09V()
     Local _lRet := .t.
     //Local _nQTDEKG := aScan( oBrw1ZB0:aHeader, { |x| Alltrim( x[ 2 ] ) == 'ZB0_QTDEKG' } )
     
     If __ReadVar $ "M->ZB0_QTDEKG"
        //If oCBx1Man:nAt == 1 //1 = Octa 35,5
        //   If &__ReadVar - 35.5 <= 0 
        //      MsgAlert( "Atenção esse peso não pode ser menor que o peso da embalagem", "Atenção" )
        //      _lRet := .f.
        //   Endif
        //Else             //2 = Bag   7,5
        //   If &__ReadVar - 7.5 <= 0 
        //      MsgAlert( "Atenção esse peso não pode ser menor que o peso da embalagem", "Atenção" )
        //      _lRet := .f.
        //  Endif
        //Endif
     Endif
Return _lRet

User Function ZPCPF09L()
     BrwLegenda( "Legenda", "Status", { { "BR_PRETO"  , "Cancelada" },; 
                                        { "BR_AZUL"   , "Refugo"    },;
                                        { "BR_MARROM" , "Desmontado"},;
                                        { "BR_LARANJA", "Moido"     },;
                                        { "BR_CINZA"  , "Extrudado" } } )

Return 