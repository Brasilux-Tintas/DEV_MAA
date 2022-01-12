#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"


User Function SERASARC()
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Private _cString   := "SE1"
     Private _cPerg     := "SERASARC"
     Private _oGeraTxt  
     Private _cPath     := '', _cFile  := ''
     Private _cEOL      := "CHR(13)+CHR(10)"
     Private _nTotCli   := 0 
     Private _nTotcRec  := 0

     Pergunte( _cPerg, .F. )

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Montagem da tela de processamento.                                  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     @ 200,1 TO 380,450 DIALOG _oGeraTxt TITLE OemToAnsi("Tratamento Arq. Retorno SERASA")
     @ 02,10 TO 060,215
     @ 10,018 Say " Este programa ira gerar um novo arquivo texto à partir de arquivo RETORNO " SIZE 196,0
     @ 18,018 Say " fornecido pelo SERASA." SIZE 196,0

     @ 70,128 BMPBUTTON TYPE 05 ACTION Pergunte(_cPerg,.T.)
     @ 70,158 BMPBUTTON TYPE 01 ACTION Processa( {|| OkGeraTrb() }) 
     @ 70,188 BMPBUTTON TYPE 02 ACTION Close(_oGeraTxt)

     Activate Dialog _oGeraTxt Centered

Return
//-------------------------------------
Static Function OkGeraTrb
       Local _nHdl, cArq, lFim, nTamArq, lComeco, nLidos, nArqDest, lSucesso, cDataLimite
       Local cArqDest
       Local _cFile := alltrim(mv_par01)
       Local _cPath := Alltrim( mv_par02 )  
       lSucesso     := .t.
       _cTipoMov    :=''
       _nTotcRec    := 0

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Cria o arquivo texto                                                ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If Substr( _cPath, Len( _cPath ), 1 ) != "\"
          _cPath += "\"
       Endif

       cArq := _cPath + _cFile

       If !File( cArq )
          MessageBox( "O arquivo " + cArq + " não existe! Verifique os parametros.", "Atencao!", 48 )
          Return
       Endif

       _nHdl  := fOpen( _cPath + _cFile )

       If _nHdl == -1
          MessageBox( "O arquivo " + cArq + " não pode ser aberto! Verifique os parametros.", "Atencao!", 48 )
          Return
       Endif

       _cEOL := CHR(13) + CHR(10)

       cArqDest := _cPath + "R" + _cFile
       If File( cArqDest )
          Delete File &cArqDest
       Endif
       nArqDest  := fCreate( cArqDest )

       If nArqDest == -1
          MessageBox( "O arquivo " + cArqDest + " não pode ser criado!", "Atenção!", 48 )
          Return
       Endif

       DbSelectArea("SE1")
       SE1->( DbSetOrder( 1 ) )

       fSeek( _nHdl, 0, 0 )
       nTamArq := fSeek( _nHdl, 0, 2 )
       fSeek( _nHdl, 0, 0 )
       lComeco  = .t.
       lFim     = .f.
       nLidos  := 0
       nLinha  := 0              

       ProcRegua( Round( nTamArq /132, 0 ) )
       While lSucesso .and. ( nLidos < nTamArq ) .and. !lFim
             If nLidos < nTamArq
                cLinha := U_fGets( _nHdl )
                nLidos += Len( cLinha )
             Else
                lFim = .t.
             Endif
             nLinha++
             IncProc( "Lendo linha " + Alltrim( str( nLinha ) ) )
             If ( nLinha == 1) .and. !( Substr( cLinha, 37, 8 ) == "CONCILIA" )
                MessageBox( "Este arquivo não é um arquivo de CONCILIAÇÃO SERASA! ", "Atencao!", 48 )
                lSucesso := .f.
                Exit
             Endif
             If nLinha == 1
                cDataLimite := Substr( cLinha, 45, 8 )
             Endif
             If ( nLinha > 1 ) .and. ( Substr( cLinha, 1, 2 ) != "99" )
                cAux := Rtrim( Substr( cLinha, 68, 32 ) )
                DbSelectArea("SE1")
                If !SE1->( DbSeek( cAux ) )
                   cAux := SubStr( cLinha, 29, 8 ) // Título excluido no sistema, colocar a data de emissão do mesmo na data de baixa
                Else
                   cAux := Padr( Dtos( SE1->E1_BAIXA ), 8, " " )
                Endif
                If cAux > cDataLimite
                   cAux := space(8)
                endif
                cLinha := SubStr( cLinha, 1, 57 ) + cAux + SubStr( cLinha, 66, Len( cLinha ) - 65 )
             Endif
             If fWrite( nArqDest, cLinha, Len( cLinha ) ) != Len( cLinha )
                MessageBox( "Ocorreu um erro na gravacao do arquivo retorno, linha do arquivo nro " + Alltrim( Str( nLinha ) ), "Atencao!", 48 )
                lSucesso := .f.
                Exit
             Endif
       EndDo 
       fClose( _nHdl )
       fClose( nArqDest )
       If lSucesso
          MessageBox( "Arquivo " + cArqDest + " gerado com SUCESSO!", "Aviso", 48 )
       Else
          MessageBox( "Houve falha na geração do arquivo!", "Aviso", 48 )
       Endif
Return
