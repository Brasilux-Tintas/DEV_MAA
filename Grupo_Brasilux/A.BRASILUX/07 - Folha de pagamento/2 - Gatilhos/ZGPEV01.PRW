#include 'TOTVS.CH'

/*/{Protheus.doc} ZGPEV01
//VALIDAÇÃO DOS CAMPOS DE FUNÇÃO E CARGO DEVIDO A AMARRAÇÃO ESPECÍFICA DA BRASILUX. CHAMADO 012671
@author Luís Gustavo de Souza
@since 25/02/2019
@version 6
@return ${return}, ${return_description}

@type function
/*/
User Function ZGPEV01( _cTpGat )
     Local _lRet   := .T.
     u_zcfga01( 'ZGPEV01' ) //LGS#2021201 - Gravação de log de utilização da rotina
     If _cTpGat == 'F' //Validação da função na digitação
        DbSelectArea("SRJ")
        SRJ->( DbSetOrder( 1 ) )
        If !SRJ->( DbSeek( xFilial( "SRJ" ) + M->RA_CODFUNC ) )
           _lRet := .F.
           MsgAlert( "Atenção, a FUNÇÃO digitada não existe!" )
        Else
           If !( GETMV( "ZP_PAR0008" ) $  SubStr( Iif( ALTERA, SRA->RA_FILIAL, M->RA_FILIAL ), 1, 2 ) )
              If Empty( SRJ->RJ_CARGO )
                 _lRet := .f.
                 MsgAlert( "Atenção, o CARGO dessa função não está preenchido!" )
              Else
                 DbSelectArea( "SQ3" )
                 SQ3->( DbSetOrder( 1 ) )
                 If SQ3->( DbSeek( xFilial( "SQ3" ) + SRJ->RJ_CARGO ) )
                    If !( SQ3->Q3_CC == M->RA_CC )
                       _lRet := .f.
                       MsgAlert( "Atenção, o CARGO dessa função não corresponde ao CENTRO DE CUSTO cadastrado!" )
                    Endif
                 Else
                    _lRet := .f.
                    MsgAlert( "Atenção, a CARGO digitado não encontrado!" )
                 Endif
              Endif
           Endif
        Endif
        If !_lRet
           M->RA_CODFUNC = SRA->RA_CODFUNC
        Endif
     ElseIf _cTpGat == 'C'
            If !( GETMV( "ZP_PAR0008" ) $  SubStr( Iif( ALTERA, SRA->RA_FILIAL, M->RA_FILIAL ), 1, 2 ) )
               If Empty( M->RA_CARGO )
                  _lRet := .F.
                  MsgAlert( "Atenção, o CARGO não pode ser em branco!" )
               Else
                  DbSelectArea("SQ3")
                  SQ3->( DbSetOrder( 1 ) )
                  If !SQ3->( DbSeek( xFilial( "SQ3" ) + M->RA_CARGO ) )
                     _lRet := .F.
                     MsgAlert( "Atenção, o CARGO digitado não existe!" )
                  Else
                     If !( SQ3->Q3_CC == M->RA_CC )
                        _lRet := .f.
                        MsgAlert( "Atenção, o CARGO dessa função não corresponde ao CENTRO DE CUSTO cadastrado!" )
                     Else
                        DbSelectArea("SRJ")
                        SRJ->( DbSetOrder( 4 ) )
                        If !SRJ->( DbSeek( xFilial( "SRJ" ) + SQ3->Q3_CARGO ) )
                           _lRet := .f.
                           MsgAlert( "Atenção, o CARGO digitado não tem amarração com nenhuma função!" ) 
                        Endif
                     Endif
                  Endif
               Endif
            Endif
            If !_lRet
               M->RA_CARGO := SRA->RA_CARGO
            Endif
     Endif
Return _lRet
