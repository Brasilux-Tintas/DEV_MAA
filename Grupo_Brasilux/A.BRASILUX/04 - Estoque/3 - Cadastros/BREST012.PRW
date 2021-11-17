#include "rwmake.ch"
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
#include "sigawin.ch"
#include "colors.ch"
#include "font.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ BREST012   ³ Autor ³ Luís Gustavo de Souza      ³ Data ³ 17/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Cadastro de Produtos específicos.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ Siga EST (Cadastro de Produtos Especifico)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacoes³                                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³   Data   ³  BOPS  ³ Programador ³Alteracao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³             ³                                             ³±±
±±³          ³        ³             ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BREST012()
     Private cCadastro    := OemToAnsi( "Cadastro de Produtos" ) 
     Private aRotina      := { { OemToAnsi( "Pesquisar" ) , 'AxPesqui', 0, 1 },; 
                               { OemToAnsi( "Visualizar" ), 'AxVisual', 0, 2 },;
                               { OemToAnsi( "Alterar" )   , 'ExecBlock("EST0121",.f.,.f.)', 0, 4 } }

     DbSelectArea( "SB1" )   
     DbSetorder(1)
     dbGotop()
				 
     mBrowse( 6, 1, 22, 75, "SB1")
     
     Set Filter to
     
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³   EST0121  ³ Autor ³ Luís Gustavo de Souza      ³ Data ³ 17/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Funcao para alteracao do cadastro de produto.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³            ³                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacoes³                                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function EST0121()
     Local nOpcA
     Local aAcho := {}
     Local aCpos := {}
     Local nReg
     Local nOpc  := 3
     Local _lOpen:= .F. //LGS#20200130 - Adequação para release 12.1.25
     Private aTELA[0][0], aGets[0]
     Private _cAliasSX3  := GetNextAlias() //LGS#20200130 - Adequação para release 12.1.25

     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200130 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0

     nReg := Recno()
     If !Upper(Alltrim(cUsername)) $ "ADMINISTRADOR"
        aadd(aAcho,'B1_COD')
        aadd(aAcho,'B1_DESC')
     Else
        //LGS#20200130 - Adequação para release 12.1.25
        /*
        DbSelectArea("SX3")
        DbSetOrder(1)
        DbSeek("SB1")
        While !Eof() .and. X3_ARQUIVO == "SB1"
              If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
                 aadd(aAcho,X3_CAMPO)
              Endif
              DbSkip()
        Enddo
        */
        DbSelectArea( _cAliasSX3 )
        ( _cAliasSX3 )->( DbSetOrder(1) )
        ( _cAliasSX3 )->( DbGoTop() )
        ( _cAliasSX3 )->( DbSeek("SB1") )
        While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SB1"
              If X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL )
                 aadd( aAcho, ( _cAliasSX3 )->( X3_CAMPO ) )
              Endif
              DbSkip()
        Enddo
     Endif                         
     If Upper(Alltrim(cUsername)) $ "MARCIO"
            aAdd(aCpos, 'B1_ESTSEG')
            aAdd(aCpos, 'B1_PE')
            aAdd(aCpos, 'B1_TIPE')
            aAdd(aCpos, 'B1_LE')
            aAdd(aCpos, 'B1_LM')
            aAdd(aCpos, 'B1_LOCENT')
            aAdd(aAcho, 'B1_ESTSEG')
            aAdd(aAcho, 'B1_PE')
            aAdd(aAcho, 'B1_TIPE')
            aAdd(aAcho, 'B1_LE')
            aAdd(aAcho, 'B1_LM')
            aAdd(aAcho, 'B1_LOCENT')
     Else
        //LGS#20200130 - Adequação para release 12.1.25
        /*
        DbSelectArea("SX3")
        DbSetOrder(1)
        DbSeek("SB1")
        SX3->( dbEval( { || aAdd(aCpos, Alltrim(SX3->X3_CAMPO)) },{ || x3USO(SX3->X3_USADO) }, { || Sx3->X3_ARQUIVO == "SB1" },,,,.T. ) )
        */
        DbSelectArea( _cAliasSX3 )
        ( _cAliasSX3 )->( DbSetOrder(1) )
        ( _cAliasSX3 )->( DbSeek("SB1") )
        ( _cAliasSX3 )->( dbEval( { || aAdd(aCpos, Alltrim(( _cAliasSX3 )->( X3_CAMPO ) ) ) }, { || x3USO( ( _cAliasSX3 )->( X3_USADO ) ) }, { || ( _cAliasSX3 )->( X3_ARQUIVO ) == "SB1" },,,,.T. ) )
     Endif
     
     nOpcA := 0
     DbSelectArea("SB1")
     DbSetOrder(1)
     
     nOpcA := AxAltera("SB1",nReg,nOpc,aAcho,aCpos)
     
     dbSelectArea( _cAliasSX3 )
     dbCloseArea()

Return()