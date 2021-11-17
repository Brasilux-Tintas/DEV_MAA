#INCLUDE "rwmake.CH" 
#INCLUDE "MSOLE.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

//зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
//ЁPrograma  Ё ENVELOPE Ё Autor Ё LuМs G. de Souza      Ё Data Ё12/07/2011Ё
//цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
//ЁDescri┤└o Ё Impressao de Documentos tipo Word                          Ё
//цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
//ЁSintaxe   Ё Chamada padr└o para programas em RdMake.                   Ё
//цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
//ЁUso       Ё Generico                                                   Ё
//цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
//ЁObs.:     Ё                                                            Ё
//цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
//Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё
//цддддддддддддбддддддддддбддддддбдддддддддддддддддддддддддддддддддддддддд╢
//ЁProgramador ЁData      Ё BOPS ЁMotivo da Alteracao                     Ё
//цддддддддддддеддддддддддеддддддедддддддддддддддддддддддддддддддддддддддд╢
//ЁGustavo     Ё12/07/2011Ё      ЁInicial.                                Ё
//Ё            Ё          Ё      Ё                                        Ё
//Ё            Ё          Ё      Ё                                        Ё
//юддддддддддддаддддддддддаддддддадддддддддддддддддддддддддддддддддддддддды
User Function Envelope()
     Local	oDlg     := NIL
     Private aInfo   := {}
     Private nTipPes := 0
     Private cCodTip := ""

     oDlg2      := MSDialog():New( 091,232,260,709,"ENVELOPE - MSWORD",,,.F.,,,,,,.T.,,,.T. )
     oBtn1      := TButton():New( 060, 008, "ParБmetros"      , oDlg2, { || fPerg_Word()}, 037, 012,,,,.T.,,"",,,,.F. )
     oBtn2      := TButton():New( 060, 060, "Impr. VariАveis" , oDlg2, { || fVarW_Imp() }, 048, 012,,,,.T.,,"",,,,.F. )
     oBtn3      := TButton():New( 060, 124, "Impr. Documentos", oDlg2, { || fWord_Imp() }, 048, 012,,,,.T.,,"",,,,.F. )
     oBtn4      := TButton():New( 060, 188, "Sair"            , oDlg2, { || oDlg2:End() }, 037, 012,,,,.T.,,"",,,,.F. )

     oDlg2:Activate(,,,.T.)
Return( NIL )

/*
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁfWord_Imp Ё Autor ЁMarinaldo de Jesus     Ё Data Ё05/07/2000Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁImpressao do Documento Word                                 Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fWord_Imp()
       /*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        ЁDefinindo Variaveis Locais                                             Ё
        юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
       Local cArqWord   := "\samples\documents\docs\envelope.dot"
       Local cAux       := ""
       Local cPath      := GETTEMPPATH()
       Local nAt        := 0
       Local lImpress   := .f. 
       Local nArqSaida  := 1
       Local oWord      := NIL
       Local aCampos    := {}
       Local nX         := 0

       If Empty(cCodTip)
          MsgStop("Verifique os parБmetros")
          Return
       Endif

       //Acerta o nome do arquivo a ser impresso
       cAuxArq := 'C:\TEMP\Env'
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

       /*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        ЁVerifica se o usuario escolheu um drive local (A: C: D:) caso contrarioЁ
        Ёbusca o nome do arquivo de modelo,  copia para o diretorio temporario  Ё
        Ёdo windows e ajusta o caminho completo do arquivo a ser impresso.      Ё
        юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
       If substr(cArqWord,2,1) <> ":"
          cAux := cArqWord
          nAT  := 1
          For nx := 1 to len(cArqWord)
              cAux := substr(cAux,If(nx==1,nAt,nAt+1),len(cAux))
              nAt  := at("\",cAux)
              If nAt == 0
                 Exit
              Endif
          next nx
          CpyS2T(cArqWord, cPath, .T.)
          cArqWord := cPath+cAux
       Endif

       //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //ЁInicializa o Ole com o MS-Word 97 ( 8.0 )						      Ё
       //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       oWord	:= OLE_CreateLink() ; OLE_NewFile( oWord , cArqWord )

       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Carrega Campos Disponiveis para Edicao                       Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       aCampos := fCpos_Word()

       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Ajustando as Variaveis do Documento                          Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       Aeval( aCampos,                                                                   ;
                       { |x| OLE_SetDocumentVar( oWord, x[1],                            ;
                       IF( Subst( AllTrim( x[3] ) , 4 , 2 )  == "->",                    ;
                           Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 ), ;
                           Subst( AllTrim( x[3] ),                                       ;
                           - ( Len( AllTrim( x[3] ) ) - 5 )                              ;
                           )                                                             ;
                           )                                                             ;
                           ),                                                            ; 
                           Transform( x[2] , x[3] )                                      ;
                           )                                                             ; 
                           )                                                             ;
                       }                                                                 ;
            )

       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //Ё Atualiza as Variaveis                                        Ё
       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       OLE_UpDateFields( oWord )

       //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //ЁImprimindo o Documento                                                 Ё
       //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       If Pergunte("ENVELO", .t.)
          lImpress := Iif(mv_par01 == 1, .t., .f.)
          IF lImpress
             OLE_SetProperty( oWord, '208', .F. ) 
             OLE_PrintFile( oWord )
          Endif
       Else
          MsgStop("Word serА fechado.")
          //   cArqSaida := SubStr(cArqSaida, 1, 5) + StrZero(nArqSaida, 3)
          //   nArqSaida += 1
          //   OLE_SaveAsFile( oWord, cNewDir+Alltrim(cArqSaida) )
       EndIF

       //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       //ЁEncerrando o Link com o Documento                                      Ё
       //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       OLE_CloseLink( oWord )
       If Len(cAux) > 0
          fErase(carqword)
       Endif

Return( NIL )

//зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
//ЁFun┤фo    ЁfVarW_Imp Ё Autor Ё Marinaldo de Jesus    Ё Data Ё07/05/2000Ё
//цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
//ЁDescri┤фo ЁImpressao das Variaveis disponiveis para uso                Ё
//юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function fVarW_Imp()
       /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        Ё Define Variaveis Locais                                      Ё
        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
       Local cString	:= 'SA1'
       Local aOrd		:= {"VariАvel", "DescriГЦo da VariАvel"}
       Local cDesc1	    := "RelatСrio variАveis envelope"
       Local cDesc2	    := "SerА impresso de acordo com os parБmetros solicitados pelo"
       Local cDesc3	    := "usuАrio."
       Local Tamanho	:= "P"

       /*
       здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       Ё Define Variaveis Privates Basicas                            Ё
       юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
       Private nomeprog	:= 'ENVELOPE'
       Private AT_PRG	:= nomeProg
       Private aReturn	:= {"Zebrado", 1, "AdministraГЦo", 2, 2, 1, '',1 }
       Private wCabec0	:= 1
       Private wCabec1	:= "Variaveis                      Descricao"
       Private wCabec2	:= ""
       Private wCabec3	:= ""
       Private nTamanho	:= "P"
       Private lEnd		:= .F.
       Private Titulo	:= cDesc1
       Private Li		:= 0
       Private ContFl	:= 1
       Private cBtxt	:= ""
       Private aLinha	:= {}
       Private nLastKey	:= 0

       /*
       здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
       Ё Envia controle para a funcao SETPRINT                        Ё
       юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
       WnRel := "WORD_VAR"
       WnRel := SetPrint(cString, Wnrel, "", Titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, , nTamanho, , .F.)

       IF nLastKey == 27
          Return( NIL )
       EndIF

       SetDefault(aReturn, cString)

       IF nLastKey == 27
          Return( NIL )
       EndIF

       /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        Ё Chamada do Relatorio.                                        Ё
        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
       RptStatus( { |lEnd| fImpVar() } , Titulo )

Return( NIL )

/*
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤фo    ЁfImpVar   Ё Autor Ё Marinaldo de Jesus    Ё Data Ё07/05/2000Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤фo ЁImpressao das Variaveis disponiveis para uso                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fImpVar()
       Local nOrdem	  := aReturn[8]
       Local aCampos  := {}
       Local nX		  := 0
       Local cDetalhe := ""

       /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        Ё Carregando Variaveis                                         Ё
        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/ 
        aCampos := fCpos_Word()

       /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        Ё Ordena aCampos de Acordo com a Ordem Selecionada             Ё
        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/        
       IF nOrdem = 1
          aSort( aCampos , , , { |x,y| x[1] < y[1] } )
       Else
          aSort( aCampos , , , { |x,y| x[4] < y[4] } )
       EndIF

       /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        Ё Carrega Regua de Processamento                               Ё
        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/        
       SetRegua( Len( aCampos ) )

       /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
        Ё Impressao do Relatorio                                       Ё
        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/        
       For nX := 1 To Len( aCampos )
           /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            Ё Movimenta Regua Processamento                                Ё
            юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/        
           IncRegua()  
           /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            Ё Cancela Impresфo                                             Ё
            юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
           IF lEnd
              @ Prow()+1,0 PSAY cCancel
              Exit
           EndIF            

           /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            Ё Mascara do Relatorio                                         Ё
            юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
           //        10        20        30        40        50        60        70        80
           //12345678901234567890123456789012345678901234567890123456789012345678901234567890
           //Variaveis                      Descricao
           //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

           /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            Ё Carregando Variavel de Impressao                             Ё
            юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
            cDetalhe := IF( Len( AllTrim( aCampos[nX,1] ) ) < 30 , AllTrim( aCampos[nX,1] ) + ( Space( 30 - Len( AllTrim ( aCampos[nX,1] ) ) ) ) , aCampos[nX,1] )
            cDetalhe := cDetalhe + AllTrim( aCampos[nX,4] )
      	
           /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            Ё Imprimindo Relatorio                                         Ё
            юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
           Impr( cDetalhe )
       Next nX

       IF aReturn[5] == 1
          Set Printer To
          dbCommit()
          OurSpool(WnRel)
       EndIF
       //--APAGA OS INDICES TEMPORARIOS--//
       If nOrdem == 5
          fErase( cArqNtx + OrdBagExt() )
       Endif                      

       MS_FLUSH()

Return( NIL )

/*
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁfPerg_WordЁ Autor ЁMarinaldo de Jesus     Ё Data Ё05/07/2000Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁGrava as Perguntas utilizadas no Programa no SX1            Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fPerg_Word()
       Private cGet1      := Space(6)
       /*дддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
       ╠╠ DeclaraГЦo de Variaveis Private dos Objetos                             ╠╠
       ы╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддд*/
       SetPrvt("oFont1", "oDlg1", "oSay1", "oSay2", "oCBox1", "oGet1", "oBtn1", "oBtn2")

       /*дддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
       ╠╠ Definicao do Dialog e todos os seus componentes.                        ╠╠
       ы╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддд*/
       oFont1     := TFont():New( "MS Sans Serif",0,-16,,.T.,0,,700,.F.,.F.,,,,,, )
       oDlg1      := MSDialog():New( 091,232,254,589,"Perguntas",,,.F.,,,,,,.T.,,,.T. )
       oSay1      := TSay():New( 011,008,{||"Cadastro de:"},oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,012)
       oSay2      := TSay():New( 036,008,{||"CСdigo:"},oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,012)
       oCBox1     := TComboBox():New( 010,072,,{"Clientes", "Fornecedores", "Representantes", "Transportadoras", "Funcionarios"},088,014,oDlg1,,,,CLR_BLACK,CLR_WHITE,.T.,oFont1,"",,,,,,, )
       oCBox1:bLostFocus := { || fTrocaPesq() }
       oCBox1:nAt := 1
       oGet1      := TGet():New( 034,072, {|u| If(PCount()>0,cGet1:=u,cGet1)},oDlg1,060,012,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"CLI","cGet1",,)
       oGet1:cF3  := "CLI"
       oBtn1      := TButton():New( 056,128,"Sair"    , oDlg1, { || oDlg1:End() },037,012,,,,.T.,,"",,,,.F. )
       oBtn2      := TButton():New( 056,072,"Confirma", oDlg1, { || nTipPes := oCBox1:nAt, cCodTip := cGet1, DbSelectArea( Iif(nTipPes == 1, "SA1", Iif(nTipPes == 2, "SA2", Iif(nTipPes == 3, "SA3", Iif(nTipPes == 4, "SA4", "SRA")))) ), DbSetOrder(1), DbSeek( xFilial(Iif(nTipPes == 1, "SA1", Iif(nTipPes == 2, "SA2", Iif(nTipPes == 3, "SA3", Iif(nTipPes == 4, "SA4", "SRA")))) )+cCodTip ), oDlg1:End() },037,012,,,,.T.,,"",,,,.F. )

       oDlg1:Activate(,,,.T.)

Return

Static Function fTrocaPesq()
       oGet1:cF3 := Iif(oCBox1:nAt == 1, 'CLI', Iif(oCBox1:nAt == 2, 'SA2', Iif(oCBox1:nAt == 3, 'SA3', Iif(oCBox1:nAt == 4, 'SA4', 'SRA'))))
Return

//зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
//ЁFun┤└o    ЁfCpos_WordЁ Autor ЁMarinaldo de Jesus     Ё Data Ё06/07/2000Ё
//цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
//ЁDescri┤└o ЁRetorna Array com as Variaveis Disponiveis para Impressao   Ё
//цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
//Ё          ЁaExp[x,1] - Variavel Para utilizacao no Word (Tam Max. 30)  Ё
//Ё          ЁaExp[x,2] - Conteudo do Campo                (Tam Max. 49)  Ё
//Ё          ЁaExp[x,3] - Campo para Pesquisa da Picture no X3 ou Picture Ё
//Ё          ЁaExp[x,4] - Descricao da Variaval                           Ё
//юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
STATIC Function fCpos_Word()
       Local aExp		:= {}

       aAdd( aExp, {'ENV_FILIAL'            , Iif(nTipPes == 1, SA1->A1_FILIAL, Iif(nTipPes == 2, SA2->A2_FILIAL, Iif(nTipPes == 3, SA3->A3_FILIAL, Iif(nTipPes == 4, SA4->A4_FILIAL, SRA->RA_FILIAL )))), "99"                   , 'Filial'     } ) 
       aAdd( aExp, {'ENV_CODIGO'            , Iif(nTipPes == 1, SA1->A1_COD   , Iif(nTipPes == 2, SA2->A2_COD   , Iif(nTipPes == 3, SA3->A3_COD   , Iif(nTipPes == 4, SA4->A4_COD   , SRA->RA_MAT    )))), "999999"               , 'Codigo'     } ) 
       aAdd( aExp, {'ENV_NOME'              , Iif(nTipPes == 1, SA1->A1_NOME  , Iif(nTipPes == 2, SA2->A2_NOME  , Iif(nTipPes == 3, SA3->A3_NOME  , Iif(nTipPes == 4, SA4->A4_NOME  , SRA->RA_NOME   )))), "@!"                   , 'Nome'       } ) 
       aAdd( aExp, {'ENV_ENDERECO'          , Iif(nTipPes == 1, SA1->A1_END   , Iif(nTipPes == 2, SA2->A2_END   , Iif(nTipPes == 3, SA3->A3_END   , Iif(nTipPes == 4, SA4->A4_END   , SRA->RA_ENDEREC)))), "@!"                   , 'EndereГo'   } ) 
       aAdd( aExp, {'ENV_COMPLEMENTO'       , Iif(nTipPes == 1, ""            , Iif(nTipPes == 2, ""            , Iif(nTipPes == 3, ""            , Iif(nTipPes == 4, ""            , SRA->RA_COMPLEM)))), "@!"                   , 'Complemento'} ) 
       aAdd( aExp, {'ENV_BAIRRO'            , Iif(nTipPes == 1, SA1->A1_BAIRRO, Iif(nTipPes == 2, SA2->A2_BAIRRO, Iif(nTipPes == 3, SA3->A3_BAIRRO, Iif(nTipPes == 4, SA4->A4_BAIRRO, SRA->RA_BAIRRO )))), "@!"                   , 'Bairro'     } ) 
       aAdd( aExp, {'ENV_CEP'               , Iif(nTipPes == 1, SA1->A1_CEP   , Iif(nTipPes == 2, SA2->A2_CEP   , Iif(nTipPes == 3, SA3->A3_CEP   , Iif(nTipPes == 4, SA4->A4_CEP   , SRA->RA_CEP    )))), "@R 99.999-999"         , 'CEP'        } )
       aAdd( aExp, {'ENV_MUNICIPIO'         , Iif(nTipPes == 1, SA1->A1_MUN   , Iif(nTipPes == 2, SA2->A2_MUN   , Iif(nTipPes == 3, SA3->A3_MUN   , Iif(nTipPes == 4, SA4->A4_MUN   , SRA->RA_MUNICIP)))), "@!"                   , 'Cidade'     } ) 
       aAdd( aExp, {'ENV_ESTADO'            , Iif(nTipPes == 1, SA1->A1_EST   , Iif(nTipPes == 2, SA2->A2_EST   , Iif(nTipPes == 3, SA3->A3_EST   , Iif(nTipPes == 4, SA4->A4_EST   , SRA->RA_ESTADO )))), "@!"                   , 'Estado'     } ) 
Return( aExp )