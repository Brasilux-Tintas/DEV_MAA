#include "TOTVS.CH"
#include "MSOLE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRSACA02 ºAutor  ³ Luís G. de Souza   º Data ³  16/02/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Integração Word com SAC                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRSACA02(nOpcImp)
     Private cSay1Imp := Space(1)
     Private cSay2Imp := Space(1)
     Private cPerg    := "BRSACA02  "

     nOpcImp := Iif(nOpcImp == 1, 1, 2)

     SetPrvt("oFon1Imp", "oDlg1Imp", "oGrp1Imp", "oSay1Imp", "oSay2Imp", "oBtn1Imp", "oBtn2Imp", "oBtn3Imp")

     //fPergSAC()  //LGS#20200211 - Adequação de release 12.1.25 e posteriores
     Pergunte(cPerg, .F.)

     oFon1Imp   := TFont():New( "MS Sans Serif", 0, -16, , .F., 0, , 400, .F., .F., , , , , , )
     oDlg1Imp   := MSDialog():New( 343, 597, 554, 1085, "Integração com MS-WORD", , , .F., , , , , , .T., , , .T. )
     oGrp1Imp   := TGroup():New( 004, 004, 080, 236, "", oDlg1Imp, CLR_BLACK, CLR_WHITE, .T., .F. )
     oSay1Imp   := TSay():New( 012, 008, {||"Impressão de documentos Word."}                         , oGrp1Imp, , oFon1Imp, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 224, 009)
     oSay2Imp   := TSay():New( 028, 008, {||"Serão impressos de acordo com a seleção de parâmetros."}, oGrp1Imp, , oFon1Imp, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 224, 009)
     oBtn1Imp   := TButton():New( 084, 004, "Parâmetros", oDlg1Imp, { || fAjus_Word(nOpcImp), Pergunte(cPerg, .T.) }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn2Imp   := TButton():New( 084, 198, "Sair"      , oDlg1Imp, { || oDlg1Imp:End() }                           , 037, 012, , , , .T., , "", , , , .F. )
     oBtn3Imp   := TButton():New( 084, 056, "Impressão" , oDlg1Imp, { || fAjus_Word(nOpcImp), fWord_Imp()          }, 037, 012, , , , .T., , "", , , , .F. )

     oDlg1Imp:Activate(, , , .T.)

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fPergSAC ³ Autor ³Luís G. de Souza       ³ Data ³16/02/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Grava as Perguntas utilizadas no Programa no SX1            ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*Static Function fPergSAC()
         aHelpPor := {}
         //              1234567890123456789012345678901234567890
         aAdd(aHelpPor, 'Informe o numero do SAC.                ')
         PutSX1("BRSACA02"  , "01"      ,  "Numero SAC"                     , "Numero SAC"                     , "Numero SAC"                     , "mv_ch1", "C"      ,  6          , 0           , 1          , "G"     , ""             , "SZQ"   , ""         , ""       , "mv_par01", ""        , ""          , ""          , ""        , ""        , ""          , ""          , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}         , {}           , ".BRSACA0201." )

         aHelpPor := {}
         aAdd(aHelpPor, 'Informe o nome do arquivo a ser impresso')
         PutSX1("BRSACA02"  , "02"      ,  "Arquivo MS-WORD"                , "Arquivo MS-WORD"                , "Arquivo MS-WORD"                , "mv_ch2", "C"      ,  60         , 0           , 1          , "G"     , "u_fOpenSAC()", ""      , ""         , ""       , "mv_par02", ""        , ""          , ""          , ""        , ""        , ""          , ""          , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}         , {}           , ".BRSACA0202." )

         aHelpPor := {}
         aAdd(aHelpPor, 'Informe o nome do arquivo de saida.     ')
         PutSX1("BRSACA02"  , "03"      ,  "Arquivo de saida"               , "Arquivo de saida"               , "Arquivo de saída"               , "mv_ch3", "C"      ,  40         , 0           , 1          , "G"     , ""             , ""      , ""         , ""       , "mv_par03", ""        , ""          , ""          , ""        , ""        , ""          , ""          , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}         , {}           , ".BRSACA0203." )

         aHelpPor := {}
         aAdd(aHelpPor, 'Imprime (S)im ou Gera arquivo(N)ão.     ')
         PutSX1("BRSACA02"  , "04"      ,  "Imprime?"                       , "Imprime?"                       , "Imprime?"                       , "mv_ch4", "C"      ,   1         , 0           , 1          , "C"     , ""             , ""      , ""         , ""       , "mv_par04", "Sim"     , ""          , ""          , ""        , "Não"     , ""          , ""          , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}         , {}           , ".BRSACA0204." )
         
         aHelpPor := {}
         aAdd(aHelpPor, 'Informações adicionais.                 ')
         PutSX1("BRSACA02"  , "05"      ,  "Texto 1"                        , "Texto 1"                        , "Texto 1"                        , "mv_ch5", "C"      ,  40         , 0           , 1          , "G"     , ""             , ""      , ""         , ""       , "mv_par05", ""        , ""          , ""          , ""        , ""        , ""          , ""          , ""        , ""          , ""          , ""        , ""          , ""          ,  ""       , ""          , ""          , aHelpPor    , {}         , {}           , ".BRSACA0205." )
Return*/

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fAjus_Word³ Autor ³Luís G. de Souza       ³ Data ³16/02/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Ajusta pergunta na tabela SX1                               ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fAjus_Word(nOpcImp)
       Local aArea		:= GetArea()
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Ajusta o tamanho da pergunta 25 - Arquivo do Word            ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Não pode haver mais acesso direto ao dicionário
       /*DbSelectArea("SX1")
       If DbSeek(cPerg+"01") //Ajusta primeira pergunta
          If nOpcImp == 1
             Reclock("SX1",.f.)
                SX1->X1_GSC   := 'S'
                SX1->X1_CNT01 := SZQ->ZQ_NUM
             MsUnlock()
          Else
             Reclock("SX1",.f.)
                SX1->X1_GSC   := 'G'
             MsUnLock()
          Endif
       Endif
       If DbSeek(cPerg+"02")
          Reclock("SX1",.f.)
             SX1->X1_TAMANHO := 60
          MsUnlock()
       EndIf*/
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Retorna para a area corrente.                                ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       RestArea(aArea)
Return( Nil )

//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³fOpenSAC  ³ Autor ³ Luís G. de Souza      ³ Data ³16/02/2011³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descri‡Æo ³Selecionaro os Arquivos do Word.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function fOpenSAC()
     Local cSvAlias     := Alias()
     //Local lAchou       := .F.
     Local cTipo        := "Modelo de Documentos(*.DOT) | *.DOT |"
     Local cNewPathArq  := cGetFile( cTipo , 'Selecione o arquivo *.DOT' )									

     IF !Empty( cNewPathArq )
        IF Upper( Subst( AllTrim( cNewPathArq), - 3 ) ) == Upper( AllTrim( 'dot' ) )
           MsgAlert( 'Arquivo Selecionado' , cNewPathArq , { 'OK' } )
        Else
           MsgAlert( 'Arquivo inválido' )
           Return( .F. )
        EndIF
     Else
        MsgAlert('Você Cancelou a seleção do arquivo .dot.' ,{ 'OK' } )
        Return( .T. )
     EndIF
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Limpa o parametro para a Carga do Novo Arquivo                         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Não pode haver mais acesso direto ao dicionário
     /*DbSelectArea("SX1")  
     IF lAchou := ( SX1->( dbSeek( cPerg + "02" , .T. ) ) )
        RecLock("SX1", .F., .T.)
           SX1->X1_CNT01 := Space( Len( SX1->X1_CNT01 ) )
           mv_par02 := cNewPathArq
        MsUnLock()
     EndIF*/
     dbSelectArea( cSvAlias )
Return( .T. )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fWord_Imp ³ Autor ³ Luís G. de Souza      ³ Data ³16/02/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Impressao do Documento Word                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fWord_Imp()
       /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³Definindo Variaveis Locais                                             ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
       Local oWord      := NIL
       //Local cNumSac    := mv_par01
       Local cArqWord   := mv_par02
       Local aCampos    := {}
       Local cAux       := ""
       Local cPath      := GETTEMPPATH()
       Local cArqSaida  := AllTrim( mv_par03 )
       Local nArqSaida  := 1
       Local nX         := 0
       Local nAt        := 0
       Local nSvOrdem   := 0
       Local nSvRecno   := 0
       Local lImpress   := ( mv_par04 == 1 )

       DbSelectArea("SZQ")
       nSvOrdem := IndexOrd()
       nSvRecno := Recno()

       //Acerta o nome do arquivo a ser impresso
       cAuxArq := cArqSaida
       cNewArq := ""
       cNewDir := ""
       While Len(cAuxArq) > 0
             nPosBar := At("\", cAuxArq)
             If nPosBar == 0
                cNewDir := cNewArq
                cNewArq := Alltrim(SubStr(cAuxArq, 1, 5))
                cAuxArq := ''
             Else
                cNewArq += SubStr(cAuxArq, 1, nPosBar)
                cAuxArq := SubStr(cAuxArq, nPosBar + 1)
             Endif
       EndDo
       cArqSaida := cNewArq

       /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³Verifica se o usuario escolheu um drive local (A: C: D:) caso contrario³
        ³busca o nome do arquivo de modelo,  copia para o diretorio temporario  ³
        ³do windows e ajusta o caminho completo do arquivo a ser impresso.      ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
       If substr(cArqWord, 2, 1) <> ":"
          cAux := cArqWord
          nAT  := 1
          For nx := 1 to len(cArqWord)
              cAux := substr(cAux, If(nx == 1, nAt, nAt+1), len(cAux))
              nAt  := at("\",cAux)
              If nAt == 0
                 Exit
              Endif
          next nx
          CpyS2T(cArqWord, cPath, .T.)
          cArqWord := cPath+cAux
       Endif
       
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Inicializa o Ole com o MS-Word 97 ( 8.0 )						      ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       oWord	:= OLE_CreateLink()
       OLE_NewFile( oWord , cArqWord )

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Carrega Campos Disponiveis para Edicao                       ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       aCampos := fCpos_Word()

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Ajustando as Variaveis do Documento                          ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Aeval(	aCampos,                                                      ;
                { |x| OLE_SetDocumentVar( oWord, x[1],                        ;
                IF( Subst( AllTrim( x[3] ) , 4 , 2 )  == "->",                ;
                Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 ), ;
                Subst( AllTrim( x[3] ),                                       ;
                - ( Len( AllTrim( x[3] ) ) - 5 )	                          ;
                )                                                             ;
                )                                                             ;
                ),                                                            ; 
                Transform( x[2] , x[3] )                                      ;
                )                                                             ; 
                )                                                             ;
                }                                                             ;
            )

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Atualiza as Variaveis                                        ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       OLE_UpDateFields( oWord )

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Imprimindo o Documento                                                 ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If lImpress
          OLE_SetProperty( oWord, '208', .F. ) 
          OLE_PrintFile( oWord )
       Else
          cArqSaida := SubStr(cArqSaida, 1, 5) + StrZero(nArqSaida, 3)
          nArqSaida += 1
          OLE_SaveAsFile( oWord, cNewDir+Alltrim(cArqSaida) )
       EndIF

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Encerrando o Link com o Documento                                      ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       OLE_CloseLink( oWord )
       If Len(cAux) > 0
          fErase(carqword)
       Endif
 
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Restaurando dados de Entrada                                           ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       dbSelectArea('SZQ')
       dbSetOrder( nSvOrdem )
       dbGoTo( nSvRecno )

Return( NIL )

//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡„o    ³fCpos_Word³ Autor ³ Luís G. de Souza      ³ Data ³16/02/2011³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descri‡„o ³Retorna Array com as Variaveis Disponiveis para Impressao   ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³          ³aExp[x,1] - Variavel Para utilizacao no Word (Tam Max. 30)  ³
//³          ³aExp[x,2] - Conteudo do Campo                (Tam Max. 49)  ³
//³          ³aExp[x,3] - Campo para Pesquisa da Picture no X3 ou Picture ³
//³          ³aExp[x,4] - Descricao da Variaval                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function fCpos_Word()
       Local aExp		:= {}
		dbselectarea("SA1")
		dbsetorder(1)
		dbseek(xFilial("SA1")+SZQ->ZQ_CLIENTE)
       aAdd( aExp, {'GPE_NUMSAC', SZQ->ZQ_NUM                                                     , "SZQ->ZQ_NUM"   , 'Numero do SAC'      } )
       aAdd( aExp, {'GPE_NOMECL', SA1->A1_NOME  , "SZQ->ZQ_NREDUZ", 'Nome do Cliente'    } )
       aAdd( aExp, {'GPE_ENDECL', SA1->A1_END   , "@!"            , 'Endereço do Cliente'} )
       aAdd( aExp, {'GPE_CIDACL', SA1->A1_MUN   , "@!"            , 'Cidade do Cliente'  } )
       aAdd( aExp, {'GPE_BAIRCL', SA1->A1_BAIRRO, "@!"            , 'Bairro do Cliente'  } )
       aAdd( aExp, {'GPE_FONECL', TRIM(SA1->A1_DDD)+'-'+TRIM(SA1->A1_TEL)   , ""              , 'Fone do Cliente'    } )
       aAdd( aExp, {'GPE_TEXTO1', MV_PAR05                                                        , "@!"            , 'Informação Caminhão'} )
       cItemSAC := ""
       DbSelectArea("SZR")
       DbSetOrder(1)
       DbSeek(xFilial("SZR")+SZQ->ZQ_NUM, .t.)
       If Found()
          While !Eof() .and. SZR->ZR_NUM == SZQ->ZQ_NUM
                cItemSac += Transform((SZR->ZR_PRODUTO), "@R! XX 99.99.999-99")+' - '+SubStr((Posicione("SB1", 1, xFilial("SB1")+SZR->ZR_PRODUTO, "B1_DESC")), 1, 30)+' - '+TransForm(SZR->ZR_QTD, "@E 9999")+CHR(11)
                //XX 99.99.999-99 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - 99999
                DbSelectArea("SZR")
                DbSkip()
          EndDo
       Endif
       aAdd( aExp, {'GPE_ITESAC', cItemSAC, "@!", 'Itens do SAC'} )
Return( aExp )