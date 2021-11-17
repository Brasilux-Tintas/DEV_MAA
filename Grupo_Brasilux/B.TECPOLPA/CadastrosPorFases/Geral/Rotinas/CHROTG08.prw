#INCLUDE "PROTHEUS.CH"  
#include "Rwmake.ch"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"



/**  SetEdCPF
*** Seta o modo de edicao dos campos do cadastro de cliente/produto/fornecedor 
***/ 

User Function CHROTG08(_tabela)
     //Caracter que representa a tabela 
     Local  caracTab := ""
     Local _cAliasSX3 := GetNextAlias() //LGS#20200207 - Adequação para release 12.1.25
     Local _lOpen        := .F. //LGS#20200207 - Adequação para release 12.1.25

     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200207 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0

     If !_lOpen //LGS#20200128 - Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
        Return
     Endif

     If _tabela == "SA1"
        caracTab := "C"
     ElseIf _tabela == "SA2"
            caracTab := "F" 
     ElseIf _tabela == "SB1"
            caracTab := "P"
     Endif

     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
     /*DbSelectArea("SX3")
     DbSetOrder(1)      
     DbGotop()
     DbSeek(_tabela)
     While !Eof() .And. SX3->X3_ARQUIVO == _tabela
           If Empty(SX3->X3_WHEN) //.or. Substr(SX3->X3_WHEN, 1,3 ) = 'Val'
              RecLock("SX3", .F.)
                 SX3->X3_WHEN := "u_CHROTG05('"+caracTab+"', '"+SX3->X3_CAMPO+"') "
                 SX3->(MSUNLOCK())
           Endif
           SX3->(DbSkip())
     Enddo*/
     DbSelectArea( _cAliasSX3 )
     ( _cAliasSX3 )->( DbSetOrder(1) )      
     ( _cAliasSX3 )->( DbGotop() )
     ( _cAliasSX3 )->( DbSeek( _tabela ) )
     While !Eof() .And. ( _cAliasSX3 )->( X3_ARQUIVO ) == _tabela
           If Empty( ( _cAliasSX3 )->( X3_WHEN ) ) //.or. Substr(SX3->X3_WHEN, 1,3 ) = 'Val'
              RecLock("SX3", .F.)
                 ( _cAliasSX3 )->( X3_WHEN ) := "u_CHROTG05('"+caracTab+"', '"+( _cAliasSX3 )->( X3_CAMPO )+"') "
                 ( _cAliasSX3 )->( MSUNLOCK() )
           Endif
           ( _cAliasSX3 )->(DbSkip())
     Enddo
     DbSelectArea( _cAliasSX3 )
     DbCloseArea()
     /********************************************************************************************************************************/
Return
    

                   
	