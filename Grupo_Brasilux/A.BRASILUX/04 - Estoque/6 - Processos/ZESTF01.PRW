#include 'TOTVS.CH'

/*/{Protheus.doc} ZESTF01
Apontamento de Conferencia de estoque
@type function
@version 2021.01.v01
@author Luís Gustavo de Souza
@since 16/01/2021
@return return_type, return_description
/*/
User Function ZESTF01()
     Local _lRetCHV   := .f.
     Local _cGet1CHV  := Space(44)
     Local _cGet2CHV  := Space(1)
     Local _aButtons  := {}
     Local _oFont1CHV := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
     Local _aStatusCH := { '', 'Pré Nota Fiscal', 'Processada pelo Robo', 'Conferencia estoque', 'Classificada Robo' }
     Local _cStatusCH := ''

     oModal := FWDialogModal():New()
     oModal:SetEscClose( .F. )
     oModal:setTitle( "Legenda" )
     oModal:setSize( 100, 230 )
     oModal:createDialog()
     aAdd( _aButtons, { "", 'Confirma', {|| fGRVCHV( @_oGet1CHV, @_cGet1CHV, @_oGet2DCHV, _cGet2CHV ) }, , , .T., .F. } )
     aAdd( _aButtons, { "", 'Cancela' , {|| oModal:DeActivate() }, , , .T., .F. } )

     oModal:addButtons( _aButtons )

     oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
     oContainer:Align := CONTROL_ALIGN_ALLCLIENT

     _oGet1CHV     := TGet():New( 004, 004, {|u| If (PCount() > 0, _cGet1CHV := u, _cGet1CHV ) }, oContainer, 220 , 012, '@!', { || fVldCHV( @_oGet1CHV, @_cGet1CHV, @_oGet2DCHV, @_cGet2CHV, @_lRetCHV, @_cStatusCH ) }, CLR_BLACK, CLR_WHITE, _oFont1CHV,    , , .T., "", , , .F., .F., , .F., .F., "", "_cGet1CHV", , , , , , , 'Chave da Nota Fiscal', 1,          , CLR_BLUE, '<Chave NFe>'  , .T. )
     _oGet2DCHV    := TComboBox():Create( oContainer, { |u| If( PCount() > 0, _cGet2CHV := u, _cGet2CHV ) }, 028, 004, _aStatusCH, 150, 012, , {||}, , , , .T., , , , /*{ || cProg == "MATA110"}*/, , , , , '_cGet2CHV', 'Status', 1, _oFont1CHV, CLR_BLUE )
     oModal:Activate()
Return

/*/{Protheus.doc} fVldCHV
description
@type function
@version  
@author gustavosouza
@since 16/01/2021
@param _cGet1CHV, param_type, param_description
@param _oGet2DCHV, param_type, param_description
@param _cGet2CHV, param_type, param_description
@param _lRetCHV, param_type, param_description
@return return_type, return_description
/*/
Static Function fVldCHV( _oGet1CHV, _cGet1CHV, _oGet2DCHV, _cGet2CHV, _lRetCHV, _cStatusCH )
       Local _lRet := .T.

       If !Empty( _cGet1CHV )
          DbSelectArea("ZNF")
          ZNF->( DbSetOrder( 1 ) )
          If !ZNF->( DbSeek( xFilial("ZNF") + _cGet1CHV ) )
             MessageBox( 'Chave de nota fiscal não encontrada, digite uma chave valida.', 'Atenção', 48 )
             _cGet1CHV := space(44)
             _oGet1CHV:Refresh()
             _oGet1CHV:SetFocus()
             _lRet := .f.
          else
             If ZNF->ZNF_X_STAT $ ' .0'
                _oGet2DCHV:nAt := 2
             ElseIf ZNF->ZNF_X_STAT $ '1'
                    _oGet2DCHV:nAt := 3
             ElseIf ZNF->ZNF_X_STAT $ '2'
                    MessageBox( 'Nota fiscal já conferida!', 'Atenção', 64 )
                    _oGet2DCHV:nAt := 4
                    _oGet2DCHV:lReadOnly := .t.
             ElseIf ZNF->ZNF_X_STAT $ '3'
                    MessageBox( 'Nota fiscal já classificada!', 'Atenção', 64 )
                    _oGet2DCHV:nAt := 5
                    _oGet2DCHV:lReadOnly := .t.
             Endif
             _oGet2DCHV:Refresh()
          Endif
       Endif
       _lRetCHV := _lRet

Return _lRet

Static Function fGRVCHV( _oGet1CHV, _cGet1CHV, _oGet2DCHV, _cGet2CHV )

       If !Empty( _cGet1CHV )
          DbSelectArea("ZNF")
          ZNF->( DbSetOrder( 1 ) )
          If ZNF->( DbSeek( xFilial("ZNF") + _cGet1CHV ) )
             If _oGet2DCHV:nAt == 4
                RecLock( 'ZNF', .F. )
                   ZNF->ZNF_X_STAT := '2'
                MSUnLock()
             Endif
          Endif
       Endif
       _oGet2DCHV:nAt := 1
       _cGet2CHV  := ''
       _oGet2DCHV:Refresh()
       _cGet1CHV  := space(44)
       _oGet1CHV:Refresh()
       _oGet1CHV:SetFocus()
Return
