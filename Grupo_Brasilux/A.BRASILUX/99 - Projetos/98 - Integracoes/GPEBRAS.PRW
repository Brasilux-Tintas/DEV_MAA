#INCLUDE "rwmake.CH" 
#INCLUDE "MSOLE.CH"

//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Programa  ³ GpeWord  ³ Autor ³Marinaldo de Jesus     ³ Data ³05/07/2000³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descri‡„o ³ Impressao de Documentos tipo Word                          ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Sintaxe   ³ Chamada padr„o para programas em RdMake.                   ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Uso       ³ Generico                                                   ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Obs.:     ³                                                            ³
//ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Programador ³Data      ³ BOPS ³Motivo da Alteracao                     ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³            ³23/05/2002³      ³Inicial.nDepen qdo impr.variaveis       ³
//³            ³06/01/2003³------³Buscar o codigo CBO no cadastro funcoes ³
//³            ³          ³------³de acordo com os novos codigos CBO/2002.³
//³            ³28/04/2003|------|Incl.de Variaveis novas no Array aExp.  ³
//³            ³          ³------|Alteracao na perg.Verific.Dependente, na³
//³            ³          ³------|Perg.Funcao(tamanho)e Ordem de Impress. ³
//³            ³          ³------|para imprimir por Ordem de Dt. Admissao.³
//³            ³          ³061017³Ajuste na varialvel CGC p/ trazer corre ³
//³            ³          ³      ³tamente o numero do CGC c/ 14 dig.      ³
//³Pedro Eloy  ³27/11/03  ³067893³retirada o tratamento da foto.          ³
//³Emerson     ³14/06/04  ³072134|Tratar impressao da categoria Prof. "J".³
//³Ricardo D.  ³01/02/05  ³075835|Tratar a impressao do documento buscando³
//³            ³          ³      ³o modelo a partir do rootpath. Ajuste no³
//³            ³          ³      ³tamanho maximo do caminho+nome do modelo³
//³            ³          ³      ³para 60 caracteres.                     ³
//³            ³22/03/05  ³075835|Ajuste na exclusao do arq.temporario p/ ³
//³            ³          ³      ³somente quando a impressao for a partir ³
//³            ³          ³      ³do servidor.                            ³
//³Andreia     ³14/07/06  ³101032|Criacao do campo "RA_MUNNASC" para ser  ³
//³            ³          ³      ³utilizado na impressao do Cadastro do   ³
//³            ³          ³      ³Trabalhador(gpecadPis).                 ³
//³Andreia     ³06/09/06  ³105588|Criacao da variavel "GPE_NOMECMP" para  ³
//³            ³          ³      ³guardar o conteudo do campo RA_NOMECMP. ³
//³Natie       ³24/11/06  ³114085³Testar o campo RA_NOMECMP               ³
//³Pedro Eloy  ³26/04/07  ³123899³tratamento para compor os espacos no SX1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function GpeBras()
     Local	oDlg     := NIL
     Private cPerg   := "GPBRAS"
     Private aInfo   := {}
     Private aDepenIR:= {}
     Private aDepenSF:= {}
     Private nDepen  := 0
     u_zcfga01( 'GPEBRAS' ) //LGS#2021201 - Gravação de log de utilização da rotina
     //tratando os espacos do novo tamanho do X1_GRUPO
     //cPerg	:= cPerg + (Space( Len(SX1->X1_GRUPO)  - Len(cPerg) ) )

     Pergunte(cPerg,.F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³         Grupo  Ordem Pergunta Portugues     Pergunta Espanhol  Pergunta Ingles Variavel Tipo Tamanho Decimal Presel  GSC Valid                              Var01      Def01         DefSPA1   DefEng1 Cnt01             Var02  Def02    		 DefSpa2  DefEng2	Cnt02  Var03 Def03      DefSpa3    DefEng3  Cnt03  Var04  Def04     DefSpa4    DefEng4  Cnt04  Var05  Def05       DefSpa5	 DefEng5   Cnt05  XF3   GrgSxg ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     @ 096,042 TO 323,505 DIALOG oDlg TITLE OemToAnsi("INTEGRAÇÃO COM MS-WORD")
     @ 008,010 TO 084,222
     @ 018,020 SAY OemToAnsi("Impressão de Documentos Word. Serão impressos de acordo com a")
     @ 030,020 SAY OemToAnsi("Seleção dos Parâmetros.")
     @ 095,042 BMPBUTTON TYPE 5 ACTION Eval( { || fPerg_Word() , Pergunte(cPerg,.T.) } )	
     @ 095,072 BUTTON OemToAnsi("Impr. Variáveis") SIZE 55,13 ACTION Eval( { || fPerg_Word() , (ndepen:= 0,fVarW_Imp() ) }  )      
     @ 095,130 BUTTON OemToAnsi("Impr. Documentos") SIZE 55,13 ACTION Eval( { || fPerg_Word() , fWord_Imp() } )
     @ 095,187 BMPBUTTON TYPE 2 ACTION Close(oDlg)
     ACTIVATE DIALOG oDlg CENTERED

Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fWord_Imp ³ Autor ³Marinaldo de Jesus     ³ Data ³05/07/2000³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Impressao do Documento Word                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fWord_Imp()
       /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³Definindo Variaveis Locais                                             ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
       Local oWord      := NIL
       Local cExclui    := ""
       //Local cFilAnt    := ""
       Local aCampos    := {}
       Local nX         := 0
       Local nSvOrdem   := 0
       Local nSvRecno   := 0
       Local cAcessaSRA := &( " { || " + ChkRH( "GPEWORD" , "SRA" , "2" ) + " } " )

       /*
       ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³Carregando mv_par para Variaveis Locais do Programa                    ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
       Local cFilDe     := mv_par01
       Local cFilAte    := mv_par02
       Local cCcDe 	   := mv_par03
       Local cCcAte     := mv_par04
       Local cMatDe		:= mv_par05
       Local cMatAte    := mv_par06
       Local cNomeDe    := mv_par07
       Local cNomeAte   := mv_par08
       Local cTnoDe     := mv_par09
       Local cTnoAte    := mv_par10
       Local cFunDe     := mv_par11
       Local cFunAte    := mv_par12
       Local cSindDe    := mv_par13
       Local cSindAte   := mv_par14
       Local dAdmiDe    := mv_par15
       Local dAdmiAte   := mv_par16
       Local cSituacao  := mv_par17
       Local cCategoria := mv_par18
       Local nCopias    := If ( Empty(mv_par23), 1, mv_par23 ) 
       Local nOrdem     := mv_par24
       Local cArqWord   := mv_par25
       Local cAux       := ""
       Local cPath      := GETTEMPPATH()
       Local nAt        := 0
       /*-------------   Mudado por jose Uliana 30/11/2020  -----------------------------*/
       //Local lDepende   := If (Mv_par26 = 1, .T., .F.)
       // ----------------------------------------------------------------------------------
       /*--- Caso não funcinar tirar esta linha abaixo e voltar a de cima  30/11/2020 ----*/ 
       Local lDepende   := If (Mv_par26 <> 2, .T., .F.)
       /*----------------------------------------------------------------------------------*/
       Local nDepende   := mv_par27
       Local lImpress   := ( mv_par28 == 1 )
       Local cArqSaida  := AllTrim( mv_par29 )
       Local nArqSaida  := 1
       Private cGpeDep :=''
       
       //Acerta o nome do arquivo a ser impresso
       cAuxArq := cArqSaida
       cNewArq := ""
       cNewDir := AllTrim( mv_par29 )
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
       nDepen           := If ( ! lDepende, 4, nDepende )

      /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³Verifica se o usuario escolheu um drive local (A: C: D:) caso contrario³
        ³busca o nome do arquivo de modelo,  copia para o diretorio temporario  ³
        ³do windows e ajusta o caminho completo do arquivo a ser impresso.      ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
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
      /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³Bloco que definira a Consistencia da Parametrizacao dos Intervalos sele³
        ³cionados nas Perguntas De? Ate?.                                       ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
       cExclui := cExclui + "{ || "
       cExclui := cExclui + "(RA_FILIAL  < cFilDe     .or. RA_FILIAL  > cFilAte    ).or."
       cExclui := cExclui + "(RA_MAT     < cMatDe     .or. RA_MAT     > cMatAte    ).or." 
       cExclui := cExclui + "(RA_CC      < cCcDe      .or. RA_CC      > cCCAte     ).or." 
       cExclui := cExclui + "(RA_NOME    < cNomeDe    .or. RA_NOME    > cNomeAte   ).or." 
       cExclui := cExclui + "(RA_TNOTRAB < cTnoDe     .or. RA_TNOTRAB > cTnoAte    ).or." 
       cExclui := cExclui + "(RA_CODFUNC < cFunDe     .or. RA_CODFUNC > cFunAte    ).or." 
       cExclui := cExclui + "(RA_SINDICA < cSindDe    .or. RA_SINDICA > cSindAte   ).or." 
       cExclui := cExclui + "(RA_ADMISSA < dAdmiDe    .or. RA_ADMISSA > dAdmiAte   ).or." 
       cExclui := cExclui + "!(RA_SITFOLH$cSituacao).or.!(RA_CATFUNC$cCategoria)"
       cExclui := cExclui + " } "

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Inicializa o Ole com o MS-Word 97 ( 8.0 )						      ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       oWord	:= OLE_CreateLink() ; OLE_NewFile( oWord , cArqWord )

       DbSelectArea("SRB")
       nSBOrdem := IndexOrd() ; nSBRecno := Recno()
       DbGotop()

       DbSelectArea("SRA")
       nSvOrdem := IndexOrd() ; nSvRecno := Recno()
       DbGotop()

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Posicionando no Primeiro Registro do Parametro               ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       IF nOrdem == 1	   							//Matricula
          DbSetOrder(nOrdem)
          DbSeek( cFilDe + cMatDe , .T. )
          cInicio := '{ || RA_FILIAL + RA_MAT }'
          cFim    := cFilAte + cMatAte
       ElseIF nOrdem == 2							//Centro de Custo
              dbSetOrder(nOrdem)
              dbSeek( cFilDe + cCcDe + cMatDe , .T. )
              cInicio  := '{ || RA_FILIAL + RA_CC + RA_MAT }'
              cFim     := cFilAte + cCcAte + cMatAte
       ElseIF nOrdem == 3							//Nome 
              dbSetOrder(nOrdem)
              dbSeek( cFilDe + cNomeDe + cMatDe , .T. )
              cInicio := '{ || RA_FILIAL + RA_NOME + RA_MAT }'
              cFim    := cFilAte + cNomeAte + cMatAte
       ElseIF nOrdem == 4							//Turno 
              dbSetOrder(nOrdem)
              //---------  Mudado por Jose Uliana   03/12/2020 ---------------
              //dbSeek( cFilDe + cTnoDe ,.T. )
              //--------------------------------------------------------------
              dbSeek( cFilDe + cTnoDe + CMatDe , .T. )
              cInicio  := '{ || RA_FILIAL + RA_TNOTRAB + RA_MAT }'
              //---------  Mudado por Jose Uliana   03/12/2020 ---------------
              //cFim     := cFilAte + cCcAte + cNomeAte
              cFim     := cFilAte + cTnoAte + cMatAte
              //--------------------------------------------------------------
       ElseIF nOrdem == 5							//Admissao 
              cIndCond:= "RA_FILIAL + DTOS (RA_ADMISSA)"
              cArqNtx  := CriaTrab(Nil,.F.)
              IndRegua("SRA",cArqNtx,cIndCond,,,"Selecionando Registros...")		//"Selecionando Registros..."
              dbSeek( cFilDe + DTOS(dAdmiDe) ,.T. )
              cInicio  :='{ || RA_FILIAL + DTOS(RA_ADMISSA)}' 
              cFim     := cFilAte + DTOS(dAdmiAte)
       EndIF

       cFilialAnt := Space(02)
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Ira Executar Enquanto Estiver dentro do Escopo dos Parametros³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       While SRA->( !Eof() .and. Eval( &(cInicio) ) <= cFim )
             //    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //    ³ Consiste Parametrizacao do Intervalo de Impressao            ³
             //    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             IF SRA->( Eval ( &(cExclui) ) )
                dbSelectArea("SRA")
                dbSkip()
                Loop
             EndIF
             cArqSaida := Alltrim( SRA->RA_MAT )
             //	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //	³Consiste Filiais e Acessos                                             ³
             //	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             IF !( SRA->RA_FILIAL $ fValidFil() .and. Eval( cAcessaSRA ) )
                dbSelectArea("SRA")
                dbSkip()
                Loop
             EndIF 
	
             //	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
             //  ³Consiste os dependentes  de Salario Familia                            ³
             //	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If lDepende
                   If nDepende == 1 //Salario Familia //
                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³Consiste os dependentes  de Salario Familia                            ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   If SRB->(dbSeek(SRA->RA_Filial+SRA->RA_Mat,.F.))        
                      fDepSF( )
                   Else
                      SRA->(dbSkip())
                      Loop
                   Endif		
                ElseIf nDepende == 2 //Imposto de Renda	//
                       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                       //³Consiste os dependentes  de Imposto de Renda                           ³
                       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
                       If SRB->(dbSeek(SRA->RA_Filial+SRA->RA_Mat,.F.))  
                          fDepIR( )
                       Else
                          SRA->(dbSkip())
                          Loop
                       Endif	
                ElseIf nDepende == 3 // Todos os Tipos de Dependente (Salario Familia e Imposto de Renda //
                       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                       //³Consiste todos os tipos de Dependentes                            ³
                       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                       If SRB->(dbSeek(SRA->RA_Filial+SRA->RA_Mat,.F.))  
                          fDepIR( )
                      //  Else                    -----  Inibido por Jose Uliana 04/12/2020
                      //    SRA->(dbSkip())       -----  Inibido por Jose Uliana 04/12/2020
                      //    Loop                  -----  Inibido por Jose Uliana 04/12/2020
                       Endif
                       If SRB->(dbSeek(SRA->RA_Filial+SRA->RA_Mat,.F.))        
                          fDepSF( )
                      // Else                     -----  Inibido por Jose Uliana 04/12/2020
                      //    SRA->(dbSkip())       -----  Inibido por Jose Uliana 04/12/2020
                      //    Loop                  -----  Inibido por Jose Uliana 04/12/2020
                       Endif	
                Endif
                If (nDepende == 1)
                   If empty(aDepenSF[1,1])
                      SRA->(dbSkip())
                      Loop
                   Endif	
                ElseIf (nDepende == 2)
                       If empty(aDepenIR[1,1])
                          SRA->(dbSkip())
                          Loop
                       Endif	          
               // ElseIf (nDepende == 3)                -----  Inibido por Jose Uliana 04/12/2020    
               //        //If empty(aDepenIR[1,1]) .and. empty(aDepenSF[1,1]) --  Mudado pelo Jose Uliana / Gustavo 04/12/2020   -----  Inibido por Jose Uliana 04/12/2020
               //        If Len(aDepenIR) == 0 .and. Len(aDepenSF) == 0      -----  Inibido por Jose Uliana 04/12/2020           -----  Inibido por Jose Uliana 04/12/2020
               //           SRA->(dbSkip())             -----  Inibido por Jose Uliana 04/12/2020
               //           Loop                        -----  Inibido por Jose Uliana 04/12/2020
               //        EndIf                          -----  Inibido por Jose Uliana 04/12/2020
                Endif	                                                          
             Endif			

             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Carregando Informacoes da Empresa                            ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             IF SRA->RA_FILIAL # cFilialAnt
                IF !fInfo(@aInfo,SRA->RA_FILIAL)
                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³ Encerra o Loop se Nao Carregar Informacoes da Empresa        ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   Exit
                EndIF
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Atualiza a Variavel cFilialAnt                               ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                dbSelectArea("SRA")
                cFilialAnt := SRA->RA_FILIAL
             EndIF	
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Carrega Campos Disponiveis para Edicao                       ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             aCampos := fCpos_Word()

             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Ajustando as Variaveis do Documento                          ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             Aeval(	aCampos,                                                                  ;
                             { |x| OLE_SetDocumentVar( oWord, x[1],                            ;
                             IF( Subst( AllTrim( x[3] ) , 4 , 2 )  == "->",                    ;
                                 Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 ), ;
                                 Subst( AllTrim( x[3] ),                                       ;
                                 - ( Len( AllTrim( x[3] ) ) - 5 )	                             ;
                                 )                                                             ;
                                 )                                                             ;
                                 ),                                                            ; 
                                 Transform( x[2] , x[3] )                                      ;
                                 )                                                             ; 
                                 )                                                             ;
                             }                                                                 ;
                  )

             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Atualiza as Variaveis                                        ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             OLE_UpDateFields( oWord )

             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³Imprimindo o Documento                                                 ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             IF lImpress
                For nX := 1 To nCopias
                    OLE_SetProperty( oWord, '208', .F. ) 
                    OLE_PrintFile( oWord )
                Next nX
             Else
                //cArqSaida := SubStr(cArqSaida, 1, 5) + StrZero(nArqSaida, 5)
                //nArqSaida += 1
                OLE_SaveAsFile( oWord, cNewDir + Alltrim( cArqSaida ) + '.docx' )
             EndIF

             dbSelectArea("SRA")                                               
             dbSkip()
             //Iniciliaza array 
             aDepenIR:= {}
             aDepenSF:= {}
       Enddo	
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
       dbSelectArea('SRA')
       dbSetOrder( nSvOrdem )
       dbGoTo( nSvRecno )

Return( NIL )

//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³fOpen_Word³ Autor ³ Marinaldo de Jesus    ³ Data ³06/05/2000³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descri‡Æo ³Selecionaro os Arquivos do Word.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function fOpen_br()
     Local cSvAlias     := Alias()
     //Local lAchou       := .F.
     Local cTipo        := "Modelo de Documentos(*.DOT?) | *.DOT? |"
     Local cNewPathArq  := cGetFile( cTipo , 'Selecione o arquivo *.DOT' )									

        IF !Empty( cNewPathArq )
        //IF Upper( Subst( AllTrim( cNewPathArq), - 3 ) ) == Upper( AllTrim( 'dot' ) )
        IF Upper( Subst( AllTrim( cNewPathArq), - 3 ) ) $ 'DOT|OTX' //LGS#20211201 - Ajuste na lógica
//------------ Inibido por Jose Uliana dia 02/12/2020 ---------------------- 
//          Aviso( 'Arquivo Selecionado' , cNewPathArq , { 'OK' } )
//--------------------------------------------------------------------------
//---------- Mudado por Jose Uliana dia 02/12/2020  MessageBox -------------------------
          MessageBox( 'Arquivo Selecionado' + cNewPathArq, 'Aviso', 48 )
          mv_par25 := cNewPathArq
          aPergunta[25][8] := cNewPathArq
//--------------------------------------------------------------------------
        Else
           MessageBox( 'Arquivo inválido', "Atenção", 48 )
           Return
        EndIF
     Else
    //------------ Inibido por Jose Uliana dia 03/12/2020 ---------------------- 
    //    Aviso('Você Cancelou a seleção do arquivo .dot.' ,{ 'OK' } )
    //--------------------------------------------------------------------------
    //---------- Mudado por Jose Uliana dia 03/12/2020 -------------------------
      MessageBox('Você Cancelou a seleção do arquivo .dot.' , 'Aviso', 48)
    //--------------------------------------------------------------------------
        Return
     EndIF
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Limpa o parametro para a Carga do Novo Arquivo                         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     /*DbSelectArea("SX1")  
     IF lAchou := ( SX1->( dbSeek( cPerg + "25" , .T. ) ) )
        RecLock("SX1", .F., .T.)
           SX1->X1_CNT01 := Space( Len( cNewPathArq ) )
           mv_par25 := cNewPathArq
           aPergunta[25][8] := cNewPathArq
        MsUnLock()
     EndIF	
     dbSelectArea( cSvAlias )*/
Return( .T. )


//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡Æo    ³fVarW_Imp ³ Autor ³ Marinaldo de Jesus    ³ Data ³07/05/2000³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descri‡Æo ³Impressao das Variaveis disponiveis para uso                ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function fVarW_Imp()
      /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³ Define Variaveis Locais                                      ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
       Local cString	:= 'SRA'                                	     
       Local aOrd		:= {"Variável", "Descrição da Variável"}
       Local cDesc1  := "Relatório Variáveis GPE_Word"
       Local cDesc2  := "Será impresso de acordo com os parâmetros solicitados pelo"
       Local cDesc3  := "usuário."
       //Local Tamanho	:= "P"

       /*
       ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³ Define Variaveis Privates Basicas                            ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
       Private nomeprog	:= 'GPEWORD'
       Private AT_PRG	:= nomeProg
       Private aReturn	:= {"Zebrado", 1, "Administração", 2, 2, 1, '',1 }
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
       ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³ Envia controle para a funcao SETPRINT                        ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
       WnRel := "WORD_VAR" 
       WnRel := SetPrint(cString, Wnrel, "", Titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, , nTamanho, , .F.)

       IF nLastKey == 27
          Return( NIL )
       EndIF

       SetDefault(aReturn, cString)

       IF nLastKey == 27
          Return( NIL )
       EndIF

       /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³ Chamada do Relatorio.                                          ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
       RptStatus( { |lEnd| fImpVar() } , Titulo )

Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡Æo    ³fImpVar   ³ Autor ³ Marinaldo de Jesus    ³ Data ³07/05/2000³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡Æo ³Impressao das Variaveis disponiveis para uso                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fImpVar()
       Local nOrdem	  := aReturn[8]
       Local aCampos  := {}
       Local nX		  := 0
       Local cDetalhe := ""

       /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³ Carregando Informacoes da Empresa                            ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/ 
       IF !fInfo(@aInfo, xFilial("SRA"))
          Return( NIL )
       EndIF			

       /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³ Carregando Variaveis                                         ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/ 
        aCampos := fCpos_Word()

       /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³ Ordena aCampos de Acordo com a Ordem Selecionada             ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/        
       IF nOrdem = 1
          aSort( aCampos , , , { |x,y| x[1] < y[1] } )
       Else
          aSort( aCampos , , , { |x,y| x[4] < y[4] } )
       EndIF

       /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³ Carrega Regua de Processamento                               ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/        
       SetRegua( Len( aCampos ) )

       /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³ Impressao do Relatorio                                       ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/        
       For nX := 1 To Len( aCampos )
           /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            ³ Movimenta Regua Processamento                                ³
            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/        
           IncRegua()  
           /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            ³ Cancela ImpresÆo                                             ³
            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
           IF lEnd
              @ Prow()+1,0 PSAY cCancel
              Exit
           EndIF            

           /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            ³ Mascara do Relatorio                                         ³
            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
           //        10        20        30        40        50        60        70        80
           //12345678901234567890123456789012345678901234567890123456789012345678901234567890
           //Variaveis                      Descricao
           //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

           /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            ³ Carregando Variavel de Impressao                             ³
            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
            cDetalhe := IF( Len( AllTrim( aCampos[nX,1] ) ) < 30 , AllTrim( aCampos[nX,1] ) + ( Space( 30 - Len( AllTrim ( aCampos[nX,1] ) ) ) ) , aCampos[nX,1] )
            cDetalhe := cDetalhe + AllTrim( aCampos[nX,4] )
      	
           /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            ³ Imprimindo Relatorio                                         ³
            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
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
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fPerg_Word³ Autor ³Marinaldo de Jesus     ³ Data ³05/07/2000³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Grava as Perguntas utilizadas no Programa no SX1            ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fPerg_Word()
       Local aArea		:= getarea()

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Ajusta o tamanho da pergunta 25 - Arquivo do Word            ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       //LGS#20200211 - Adequação de release 12.1.25 e posteriores
       /*dbselectarea("SX1")
       If dbseek(cPerg+"25")
          Reclock("SX1",.f.)
             SX1->X1_TAMANHO := 60
          MsUnlock()
       EndIf*/

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Retorna para a area corrente.                                ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       restarea(aArea)

Return( Nil )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fDepIR    ³ Autor ³R.H.                   ³ Data ³02/04/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Carrega Dependentes de Imp. de Renda                        ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/                                                                                                                                                  
Static Function fDepIR( )
Local Nx,nVezes
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Consiste os dependentes  de I.R.                                       ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aDepenIR:= {}
	Do  while SRB->RB_FILIAL+SRB->RB_MAT == SRA->RA_FILIAL+SRA->RA_MAT
		If  (SRB->RB_TipIr == '1') .Or.;
          (SRB->RB_TipIr == '2' .And. Year(dDataBase)-Year(SRB->RB_DtNasc) <= 21) .Or. ;
          (SRB->RB_TipIr == '3' .And. Year(dDataBase)-Year(SRB->RB_DtNasc) <= 24)
			//	Nome do Depend., Dta Nascimento,Grau de parentesco
      	  aAdd(aDepenIR,{left(SRB->RB_Nome,30),SRB->RB_DtNasc,If(SRB->RB_GrauPar=='C','Conjuge   ',If(SRB->RB_GrauPar=='F','Filho     ','Outros    '))   })
        EndIf
        SRB->(dbSkip())
	EndDo 
	If  Len(aDepenIR) < 10
      	nVezes := (10 - Len(aDepenIR))
		For Nx := 1 to nVezes
			 aAdd(aDepenIR,{Space(30),Space(10),Space(10) } )
		Next Nx
	EndIf
Return(aDepenIR)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fDepSF    ³ Autor ³R.H.                   ³ Data ³02/04/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Carrega Dependentes de Salario Familia                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function  fDepSF()
Local Nx,nVezes
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Consiste os dependentes  de I.R.                                       ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aDepenSF:= {}
   	Do While SRB->RB_FILIAL+SRB->RB_MAT == SRA->RA_FILIAL+SRA->RA_MAT
		If (SRB->RB_TipSf == '1') .Or. (SRB->RB_TipSf == '2' .And. ;
			Year(dDAtABase) - Year(SRB->RB_DtNasc) <= 14)
			//Nome do Depend., Dta Nascimento,Grau Parent.,Local Nascimento,Cartorio,Numero Regr.,Numero do Livro, Numero da Folha, Data Entrega,Data baixa. //
      		aAdd(aDepenSF,{left(SRB->RB_Nome,30),SRB->RB_DtNasc,If(SRB->RB_GrauPar=='C','Conjuge   ',If(SRB->RB_GrauPar=='F','Filho     ','Outros    ')),;
      			 SRB->RB_LOCNASC,SRB->RB_CARTORI,SRB->RB_NREGCAR,SRB->RB_NUMLIVR,SRB->RB_NUMFOLH,SRB->RB_DTENTRA,SRB->RB_DTBAIXA})
		EndIf
		SRB->(dbSkip())
	Enddo
   	If  Len(aDepenSF) < 10
      	nVezes := (10 - Len(aDepenSF))
		For Nx := 1 to nVezes
			 aAdd(aDepenSF,{Space(30),Space(10),Space(10),Space(10),Space(10),Space(10),Space(10),Space(10),Space(10),Space(10) } )
		Next Nx
	EndIf

Return(aDepenSF)

//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡„o    ³fCpos_Word³ Autor ³Marinaldo de Jesus     ³ Data ³06/07/2000³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descri‡„o ³Retorna Array com as Variaveis Disponiveis para Impressao   ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³          ³aExp[x,1] - Variavel Para utilizacao no Word (Tam Max. 30)  ³
//³          ³aExp[x,2] - Conteudo do Campo                (Tam Max. 49)  ³
//³          ³aExp[x,3] - Campo para Pesquisa da Picture no X3 ou Picture ³
//³          ³aExp[x,4] - Descricao da Variaval                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
STATIC Function fCpos_Word()
       Local aExp		:= {}
       Local cTexto_01	:= AllTrim( mv_par19 )
       Local cTexto_02	:= AllTrim( mv_par20 )
       Local cTexto_03	:= AllTrim( mv_par21 )
       Local cTexto_04  := AllTrim( mv_par22 ) 
       Local cApoderado	:= ""
       Local cRamoAtiv  := ""   

       If cPaisLoc == "ARG"
          If fPHist82(xFilial(),"99","01")
             cApoderado := SubStr(SRX->RX_TXT,1,30)
          EndIf
          If fPHist82(xFilial(),"99","02")
             cRamoAtiv  := SubStr(SRX->RX_TXT,1,50) 
          EndIf	           
       EndIf	

       aAdd( aExp, {'GPE_FILIAL'            , SRA->RA_FILIAL                                                                      , "SRA->RA_FILIAL"       , 'STR0013'} ) 
       aAdd( aExp, {'GPE_MATRICULA'         , SRA->RA_MAT                                                                         , "SRA->RA_MAT"          , 'STR0014'} ) 
       aAdd( aExp, {'GPE_CENTRO_CUSTO'      , SRA->RA_CC                                                                          , "SRA->RA_CC"           , 'STR0015'} ) 
     //Inibido e acescentado pelo Gustavo TI  03/12/2020 -------------------------------------------------------------
     //aAdd( aExp, {'GPE_DESC_CCUSTO'       , fDesc("SI3",SRA->RA_CC,"I3_DESC")                                                   , "@!"                   , 'STR0016'} ) 
       aAdd( aExp, {'GPE_DESC_CCUSTO'       , fDesc("CTT",SRA->RA_CC,"CTT_DESC01")                                                , "@!"                   , 'STR0016'} ) 
       aAdd( aExp, {'GPE_NOME'              , SRA->RA_NOME                                                                        , "SRA->RA_NOME"         , 'STR0017'} ) 
       aAdd( aExp, {'GPE_NOMECMP'           , If(SRA->(FieldPos("RA_NOMECMP")) # 0  ,SRA->RA_NOMECMP,space(40))                   , "@!"                   , 'STR0017'} )
       aAdd( aExp, {'GPE_CPF'               , SRA->RA_CIC                                                                         , "SRA->RA_CIC"          , 'STR0018'} ) 
       aAdd( aExp, {'GPE_PIS'               , SRA->RA_PIS                                                                         , "SRA->RA_PIS"          , 'STR0019'} ) 
       aAdd( aExp, {'GPE_RG'                , SRA->RA_RG                                                                          , "SRA->RA_RG"           , 'STR0020'} ) 
       aAdd( aExp, {'GPE_RG_ORG'            , SRA->RA_RGORG                                                                       , "@!"                   , 'STR0152'} ) 
       aAdd( aExp, {'GPE_CTPS'              , SRA->RA_NUMCP                                                                       , "SRA->RA_NUMCP"        , 'STR0021'} ) 
       aAdd( aExp, {'GPE_SERIE_CTPS'        , SRA->RA_SERCP                                                                       , "SRA->RA_SERCP"        , 'STR0022'} ) 
       aAdd( aExp, {'GPE_UF_CTPS'           , SRA->RA_UFCP                                                                        , "SRA->RA_UFCP"         , 'STR0023'} ) 
       aAdd( aExp, {'GPE_CNH'               , SRA->RA_HABILIT                                                                     , "SRA->RA_HABILIT"      , 'STR0024'} ) 
       aAdd( aExp, {'GPE_RESERVISTA'        , SRA->RA_RESERVI                                                                     , "SRA->RA_RESERVI"      , 'STR0025'} ) 
       aAdd( aExp, {'GPE_TIT_ELEITOR'       , SRA->RA_TITULOE                                                                     , "SRA->RA_TITULOE"      , 'STR0026'} ) 
       aAdd( aExp, {'GPE_ZONA_SECAO'        , SRA->RA_ZONASEC                                                                     , "SRA->RA_ZONASEC"      , 'STR0027'} ) 
       aAdd( aExp, {'GPE_ENDERECO'          , SRA->RA_ENDEREC                                                                     , "SRA->RA_ENDEREC"      , 'STR0028'} ) 
       aAdd( aExp, {'GPE_COMP_ENDER'        , SRA->RA_COMPLEM                                                                     , "SRA->RA_COMPLEM"      , 'STR0029'} )	
       aAdd( aExp, {'GPE_BAIRRO'            , SRA->RA_BAIRRO                                                                      , "SRA->RA_BAIRRO"       , 'STR0030'} ) 
       aAdd( aExp, {'GPE_MUNICIPIO'         , SRA->RA_MUNICIP                                                                     , "SRA->RA_MUNICIP"      , 'STR0031'} )	
       aAdd( aExp, {'GPE_ESTADO'            , SRA->RA_ESTADO                                                                      , "SRA->RA_ESTADO"       , 'STR0032'} )	
       aAdd( aExp, {'GPE_DESC_ESTADO'       , fDesc("SX5","12"+SRA->RA_ESTADO,"X5_DESCRI")                                        , "@!"                   , 'STR0033'} ) 
       aAdd( aExp, {'GPE_CEP'               , SRA->RA_CEP                                                                         , "SRA->RA_CEP"          , 'STR0034'} ) 
       aAdd( aExp, {'GPE_TELEFONE'          , SRA->RA_TELEFON                                                                     , "SRA->RA_TELEFON"      , 'Numero do Telefone'                   } ) 
       aAdd( aExp, {'GPE_NOME_PAI'          , SRA->RA_PAI                                                                         , "SRA->RA_PAI"          , 'Nome do Pai'                          } )
       aAdd( aExp, {'GPE_NOME_MAE'          , SRA->RA_MAE                                                                         , "SRA->RA_MAE"          , 'Nome da Mãe'                          } )
       aAdd( aExp, {'GPE_COD_SEXO'          , SRA->RA_SEXO                                                                        , "SRA->RA_SEXO"         , 'Sexo'                                 } ) 
       aAdd( aExp, {'GPE_DESC_SEXO'         , SRA->( IF( RA_SEXO = "M", "Masculino", "Feminino") )                                , "@!"                   , 'Descrição do Sexo'                    } )
       If cPaisLoc <> "ARG"
       aAdd( aExp, {'GPE_EST_CIVIL'         , SRA->RA_ESTCIVI                                                                     , "SRA->RA_ESTCIVI"      , 'Estado Civil'                         } )
       Else
       aAdd( aExp, {'GPE_EST_CIVIL'         , fDesc("SX5", "33"+SRA->RA_ESTCIVI, "X5DESCRI()")                                    , "SRA->RA_ESTCIVI"      , 'Estado Civil'                         } )
       EndIf
       aAdd( aExp, {'GPE_COD_NATURALIDADE'  , If(SRA->RA_NATURAL # " ", SRA->RA_NATURAL, " ")                                     , "SRA->RA_NATURAL"      , 'Código da Naturalidade'               } )
       aAdd( aExp, {'GPE_DESC_NATURALIDADE' , fDesc("SX5", "12"+SRA->RA_NATURAL, "X5_DESCRI")                                     , "@!"                   , 'Descrição da Naturalidade'            } )
       aAdd( aExp, {'GPE_COD_NACIONALIDADE' , SRA->RA_NACIONA                                                                     , "SRA->RA_NACIONA"      , 'Código da Nacionalidade'              } )
       aAdd( aExp, {'GPE_DESC_NACIONALIDADE', fDesc("SX5", "34"+SRA->RA_NACIONA, "X5_DESCRI")                                     , "@!"                   , 'Descrição da Nacionalidalde'          } )
       aAdd( aExp, {'GPE_ANO_CHEGADA'       , SRA->RA_ANOCHEG                                                                     , "SRA->RA_ANOCHEG"      , 'Ano de Chegada no Pais'               } )
       aAdd( aExp, {'GPE_DEP_IR'            , SRA->RA_DEPIR                                                                       , "SRA->RA_DEPIR"        , 'Numero de Dependentes de I.R.'        } )	
       aAdd( aExp, {'GPE_DEP_SAL_FAM'       , SRA->RA_DEPSF                                                                       , "SRA->RA_DEPSF"        , 'Numero de Dependentes Salário Família'} )
       If SRA->RA_DEPSF <> ' '
       	  cGpeDep :=' '
       Else
       	  cGpeDep :='NÃO HÁ FILHOS DECLARADOS NESTA DATA'
       Endif
       aAdd( aExp, {'GPE_DATA_NASC'         , SRA->RA_NASC                                                                        , "SRA->RA_NASC"         , 'Data de Nascimento'                   } )
       aAdd( aExp, {'GPE_DATA_ADMISSAO'     , SRA->RA_ADMISSA                                                                     , "SRA->RA_ADMISSA"      , 'Data de Admissão'                     } )
       aAdd( aExp, {'GPE_DIA_ADMISSAO'      , StrZero( Day( SRA->RA_ADMISSA ) , 2 )                                               , "@!"                   , 'Dia da Admissão'                      } )
       aAdd( aExp, {'GPE_MES_ADMISSAO'      , StrZero( Month( SRA->RA_ADMISSA ) , 2 )                                             , "@!"                   , 'Mês de Admissão'                      } )
       aAdd( aExp, {'GPE_ANO_ADMISSAO'      , StrZero( Year( SRA->RA_ADMISSA ) , 4)                                               , "@!"                   , 'Ano de Admissão'                      } )
       aAdd( aExp, {'GPE_DT_OP_FGTS'        , SRA->RA_OPCAO                                                                       , "SRA->RA_OPCAO"        , 'Data de Opção do FGTS'                } )
       aAdd( aExp, {'GPE_DATA_DEMISSAO'     , SRA->RA_DEMISSA                                                                     , "SRA->RA_DEMISSA"      , 'Data de Demissão'                     } ) 
       aAdd( aExp, {'GPE_DATA_EXPERIENCIA'  , SRA->RA_VCTOEXP                                                                     , "SRA->RA_VCTOEXP"      , 'Data de Experiência'                  } )
       aAdd( aExp, {'GPE_DIA_EXPERIENCIA'   , StrZero( Day( SRA->RA_VCTOEXP ) , 2 )                                               , "@!"                   , 'STR0056'} )
       aAdd( aExp, {'GPE_MES_EXPERIENCIA'   , StrZero( Month( SRA->RA_VCTOEXP ) , 2 )                                             , "@!"                   , 'STR0057'} )
       aAdd( aExp, {'GPE_ANO_EXPERIENCIA'   , StrZero( Year( SRA->RA_VCTOEXP ) , 4 )                                              , "@!"                   , 'STR0058'} )
       aAdd( aExp, {'GPE_DIAS_EXPERIENCIA'  , StrZero(SRA->(RA_VCTOEXP-RA_ADMISSA)+1,03)                                          , "@!"                   , 'STR0059'} )
       aAdd( aExp, {'GPE_DATA_EX_MEDIC'     , SRA->RA_EXAMEDI                                                                     , "SRA->RA_EXAMEDI"      , 'STR0060'} )
       aAdd( aExp, {'GPE_BCO_AG_DEP_SAL'    , SRA->RA_BCDEPSA                                                                     , "SRA->RA_BCDEPSA"      , 'STR0061'} )
       aAdd( aExp, {'GPE_DESC_BCO_SAL'      , fDesc("SA6", SRA->RA_BCDEPSA, "A6_NOME")                                            , "@!"                   , 'STR0062'} )
       aAdd( aExp, {'GPE_DESC_AGE_SAL'      , fDesc("SA6", SRA->RA_BCDEPSA, "A6_NOMEAGE")                                         , "@!"                   , 'STR0063'} )
       aAdd( aExp, {'GPE_CTA_DEP_SAL'       , SRA->RA_CTDEPSA                                                                     , "SRA->RA_CTDEPSA"      , 'STR0064'} )
       aAdd( aExp, {'GPE_BCO_AG_FGTS'       , SRA->RA_BCDPFGT                                                                     , "SRA->RA_BCDPFGT"      , 'STR0065'} )
       aAdd( aExp, {'GPE_DESC_BCO_FGTS'     , fDesc("SA6", SRA->RA_BCDPFGT, "A6_NOME")                                            , "@!"                   , 'STR0066'} )
       aAdd( aExp, {'GPE_DESC_AGE_FGTS'     , fDesc("SA6", SRA->RA_BCDPFGT, "A6_NOMEAGE")                                         , "@!"                   , 'STR0067'} )
       aAdd( aExp, {'GPE_CTA_Dep_FGTS'      , SRA->RA_CTDPFGT                                                                     , "SRA->RA_CTDPFGT"      , 'STR0068'} )
       aAdd( aExp, {'GPE_SIT_FOLHA'         , SRA->RA_SITFOLH                                                                     , "SRA->RA_SITFOLH"      , 'STR0069'} )
       aAdd( aExp, {'GPE_DESC_SIT_FOLHA'    , fDesc("SX5", "30"+SRA->RA_SITFOLH, "X5_DESCRI")                                     , "@!"                   , 'STR0070'} )
       aAdd( aExp, {'GPE_HRS_MENSAIS'       , SRA->RA_HRSMES                                                                      , "SRA->RA_HRSMES"       , 'STR0071'} )
       aAdd( aExp, {'GPE_HRS_SEMANAIS'      , SRA->RA_HRSEMAN                                                                     , "SRA->RA_HRSEMAN"      , 'STR0072'} )
       aAdd( aExp, {'GPE_CHAPA'             , SRA->RA_CHAPA                                                                       , "SRA->RA_CHAPA"        , 'STR0073'} )
       aAdd( aExp, {'GPE_TURNO_TRAB'        , SRA->RA_TNOTRAB                                                                     , "SRA->RA_TNOTRAB"      , 'STR0074'} )
       aAdd( aExp, {'GPE_DESC_TURNO'        , fDesc('SR6', SRA->RA_TNOTRAB, 'R6_DESC')                                            , "@!"                   , 'STR0075'} )
       aAdd( aExp, {'GPE_COD_FUNCAO'        , SRA->RA_CODFUNC                                                                     , "SRA->RA_CODFUNC"      , 'STR0076'} )
       aAdd( aExp, {'GPE_DESC_FUNCAO'       , fDesc('SRJ', SRA->RA_CODFUNC, 'RJ_DESC')                                            , "@!"                   , 'STR0077'} )
       aAdd( aExp, {'GPE_CBO'               , fCodCBO(SRA->RA_FILIAL, SRA->RA_CODFUNC, dDataBase)                                 , "@!"                   , 'STR0078'} )
       aAdd( aExp, {'GPE_CONT_SINDIC'       , SRA->RA_PGCTSIN                                                                     , "SRA->RA_PGCTSIN"      , 'STR0079'} )
       aAdd( aExp, {'GPE_COD_SINDICATO'     , SRA->RA_SINDICA                                                                     , "SRA->RA_SINDICA"      , 'STR0080'} )
       aAdd( aExp, {'GPE_DESC_SINDICATPO'   , AllTrim( fDesc("RCE", SRA->RA_SINDICA, "RCE_DESCRI", 40) )                          , "@!"                   , 'STR0081'} )
       aAdd( aExp, {'GPE_COD_ASS_MEDICA'    , SRA->RA_ASMEDIC                                                                     , "SRA->RA_ASMEDIC"      , 'STR0082'} )
       aAdd( aExp, {'GPE_DEP_ASS_MEDICA'    , SRA->RA_DPASSME                                                                     , "SRA->RA_DPASSME"      , 'STR0083'} )
       aAdd( aExp, {'GPE_ADIC_TEMP_SERVIC'  , SRA->RA_ADTPOSE                                                                     , "SRA->RA_ADTPOSE"      , 'STR0084'} )
       aAdd( aExp, {'GPE_COD_CESTA_BASICA'  , SRA->RA_CESTAB                                                                      , "SRA->RA_CESTAB"       , 'STR0085'} )
       aAdd( aExp, {'GPE_COD_VALE_REF'      , SRA->RA_VALEREF                                                                     , "SRA->RA_VALEREF"      , 'STR0086'} )
       aAdd( aExp, {'GPE_COD_SEG_VIDA'      , SRA->RA_SEGUROV                                                                     , "SRA->RA_SEGUROV"      , 'STR0087'} )
       aAdd( aExp, {'GPE_%ADIANTAM'         , SRA->RA_PERCADT                                                                     , "SRA->RA_PERCADT"      , 'STR0089'} )
       aAdd( aExp, {'GPE_CATEG_FUNC'        , SRA->RA_CATFUNC                                                                     , "SRA->RA_CATFUNC"      , 'STR0090'} )
       aAdd( aExp, {'GPE_DESC_CATEG_FUNC'   , fDesc("SX5","28"+SRA->RA_CATFUNC,"X5_DESCRI")                                       , "@!"                   , 'STR0091'} )
       aAdd( aExp, {'GPE_POR_MES_HORA'      , SRA->( IF( RA_CATFUNC $ "H", "P/Hora", IF( RA_CATFUNC $ "J", "P/Aula", "P/Mes" ) ) ), "@!"                   , 'STR0092'} )
       aAdd( aExp, {'GPE_TIPO_PAGTO'        , SRA->RA_TIPOPGT                                                                     , "SRA->RA_TIPOPGT"      , 'STR0093'} )
       aAdd( aExp, {'GPE_DESC_TIPO_PAGTO'   , fDesc("SX5", "40"+SRA->RA_TIPOPGT, "X5_DESCRI")                                     , "@!"                   , 'STR0094'} )
       aAdd( aExp, {'GPE_SALARIO'           , SRA->RA_SALARIO                                                                     , "SRA->RA_SALARIO"      , 'STR0095'} )
       aAdd( aExp, {'GPE_SAL_BAS_DISS'      , SRA->RA_ANTEAUM                                                                     , "SRA->RA_ANTEAUM"      , 'STR0096'} )
       aAdd( aExp, {'GPE_HRS_PERICULO'      , SRA->RA_PERICUL                                                                     , "SRA->RA_PERICUL"      , 'STR0099'} )
       aAdd( aExp, {'GPE_HRS_INS_MINIMA'    , SRA->RA_INSMIN                                                                      , "SRA->RA_INSMIN"       , 'STR0100'} )
       aAdd( aExp, {'GPE_HRS_INS_MEDIA'     , SRA->RA_INSMED                                                                      , "@!"                   , 'STR0101'} )
       aAdd( aExp, {'GPE_HRS_INS_MAXIMA'    , SRA->RA_INSMAX                                                                      , "SRA->RA_INSMAX"       , 'STR0102'} )
       aAdd( aExp, {'GPE_TIPO_ADMISSAO'     , SRA->RA_TIPOADM                                                                     , "SRA->RA_TIPOADM"      , 'STR0103'} )
       aAdd( aExp, {'GPE_DESC_TP_ADMISSAO'  , fDesc("SX5", "38"+SRA->RA_TIPOADM, "X5_DESCRI")                                     , "@!"                   , 'STR0104'} )
       aAdd( aExp, {'GPE_COD_AFA_FGTS'      , SRA->RA_AFASFGT                                                                     , "SRA->RA_AFASFGT"      , 'STR0105'} )
       aAdd( aExp, {'GPE_DESC_AFA_FGTS'     , fDesc("SX5", "30"+SRA->RA_AFASFGT, "X5_DESCRI")                                     , "@!"                   , 'STR0106'} )
       aAdd( aExp, {'GPE_VIN_EMP_RAIS'      , SRA->RA_VIEMRAI                                                                     , "SRA->RA_VIEMRAI"      , 'STR0107'} )
       aAdd( aExp, {'GPE_DESC_VIN_EMP_RAIS' , fDesc("SX5", "25"+RA_VIEMRAI, "X5_DESCRI")                                          , "@!"                   , 'STR0108'} )
       aAdd( aExp, {'GPE_COD_INST_RAIS'     , SRA->RA_GRINRAI                                                                     , "SRA->RA_GRINRAI"      , 'STR0109'} )
       aAdd( aExp, {'GPE_DESC_GRAU_INST'    , fDesc("SX5", "26"+SRA->RA_GRINRAI, "X5_DESCRI")                                     , "@!"                   , 'STR0110'} )
       aAdd( aExp, {'GPE_COD_RESC_RAIS'     , SRA->RA_RESCRAI                                                                     , "SRA->RA_RESCRAI"      , 'STR0111'} )
       aAdd( aExp, {'GPE_CRACHA'            , SRA->RA_CRACHA                                                                      , "SRA->RA_CRACHA"       , 'STR0112'} )
       aAdd( aExp, {'GPE_REGRA_APONTA'      , SRA->RA_REGRA                                                                       , "SRA->RA_REGRA"        , 'STR0113'} )
       aAdd( aExp, {'GPE_NO_REGISTRO'       , SRA->RA_REGISTR                                                                     , "SRA->RA_REGISTR"      , 'STR0115'} )
       aAdd( aExp, {'GPE_NO_FICHA'          , SRA->RA_FICHA                                                                       , "SRA->RA_FICHA"        , 'STR0116'} )
       aAdd( aExp, {'GPE_TP_CONT_TRAB'      , SRA->RA_TPCONTR                                                                     , "SRA->RA_TPCONTR"      , 'STR0117'} )
       aAdd( aExp, {'GPE_DESC_TP_CONT_TRAB' , SRA->( IF( RA_TPCONTR = "1", "Indeterminado", "Determinado"))                       , "@!"                   , 'STR0118'} )
       aAdd( aExp, {'GPE_APELIDO'           , SRA->RA_APELIDO                                                                     , "SRA->RA_APELIDO"      , 'STR0119'} )
       aAdd( aExp, {'GPE_E-MAIL'            , SRA->RA_EMAIL                                                                       , "SRA->RA_EMAIL"        , 'STR0120'} )
       aAdd( aExp, {'GPE_TEXTO_01'          , cTexto_01                                                                           , "@!"                   , 'STR0121'} ) 
       aAdd( aExp, {'GPE_TEXTO_02'          , cTexto_02                                                                           , "@!"                   , 'STR0122'} )
       aAdd( aExp, {'GPE_TEXTO_03'          , cTexto_03                                                                           , "@!"                   , 'STR0123'} )
       aAdd( aExp, {'GPE_TEXTO_04'          , cTexto_04                                                                           , "@!"                   , 'STR0124'} )
       aAdd( aExp, {'GPE_EXTENSO_SAL'       , Extenso( SRA->RA_SALARIO , .F. , 1 )                                                , "@!"                   , 'STR0125'} )
       aAdd( aExp, {'GPE_DDATABASE'         , dDataBase                                                                           , ""                     , 'STR0126'} )
       aAdd( aExp, {'GPE_DIA_DDATABASE'     , StrZero( Day( dDataBase ) , 2 )                                                     , "@!"                   , 'STR0127'} )
       aAdd( aExp, {'GPE_MES_DDATABASE'     , MesExtenso( dDataBase )                                                             , "@!"                   , 'STR0128'} )
       aAdd( aExp, {'GPE_ANO_DDATABASE'     , StrZero( Year( dDataBase ) , 4 )                                                    , "@!"                   , 'STR0129'} )
       aAdd( aExp, {'GPE_NOME_EMPRESA'      , aInfo[03]                                                                           , "@!"                   , 'STR0130'} )
       aAdd( aExp, {'GPE_END_EMPRESA'       , aInfo[04]                                                                           , "@!"                   , 'STR0131'} )
       aAdd( aExp, {'GPE_CID_EMPRESA'       , aInfo[05]                                                                           , "@!"                   , 'STR0132'} )
       aAdd( aExp, {'GPE_CEP_EMPRESA'       , aInfo[07]                                                                           , "!@R #####-###"        , 'STR0034'} )
       aAdd( aExp, {'GPE_EST_EMPRESA'       , aInfo[06]                                                                           , "@!"                   , 'STR0032'} )
       aAdd( aExp, {'GPE_CGC_EMPRESA'       , aInfo[08]                                                                           , "@R ##.###.###/####-##", 'STR0134'} )
       aAdd( aExp, {'GPE_INSC_EMPRESA'      , aInfo[09]                                                                           , "@!"                   , 'STR0135'} )
       aAdd( aExp, {'GPE_TEL_EMPRESA'       , aInfo[10]                                                                           , "@!"                   , 'STR0136'} )
       aAdd( aExp, {'GPE_FAX_EMPRESA'       , If(aInfo[11] # nil, aInfo[11], "        ")                                          , "@!"                   , 'STR0136'} )
       aAdd( aExp, {'GPE_BAI_EMPRESA'       , aInfo[13]                                                                           , "@!"                   , 'STR0137'} )
       aAdd( aExp, {'GPE_DESC_RESC_RAIS'    , fDesc("SX5", "31"+SRA->RA_RESCRAI, "X5_DESCRI")                                     , "@!"                   , 'STR0138'} )
       aAdd( aExp, {'GPE_DIA_DEMISSAO'      , StrZero( Day( SRA->RA_DEMISSA ) , 2 )                                               , "@!"                   , 'STR0139'} )
       aAdd( aExp, {'GPE_MES_DEMISSAO'      , StrZero( Month( SRA->RA_DEMISSA ) , 2 )                                             , "@!"                   , 'STR0140'} )
       aAdd( aExp, {'GPE_ANO_DEMISSAO'      , StrZero( Year( SRA->RA_DEMISSA ) , 4 )                                              , "@!"                   , 'STR0141'} )
       //SALARIO FAMILIA//
       aAdd( aExp, {'GPE_CFILHO01'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[01,01], space(30) ), space(30) )                        , "@!"                   , 'STR0150'} )
       aAdd( aExp, {'GPE_DTFL01'            , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[01,02], space(08) ), space(08) )                        , ""                     , 'STR0151'} )
       aAdd( aExp, {'GPE_CFILHO02'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[02,01], space(30) ), space(30) )                        , "@!"                   , 'STR0150'} )
       aAdd( aExp, {'GPE_DTFL02'            , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[02,02], space(08) ), space(08) )                        , ""                     , 'STR0151'} )
       aAdd( aExp, {'GPE_CFILHO03'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[03,01], space(30) ), space(30) )                        , "@!"                   , 'STR0150'} )
       aAdd( aExp, {'GPE_DTFL03'            , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[03,02], space(08) ), space(08) )                        , ""                     , 'STR0151'} )
       aAdd( aExp, {'GPE_CFILHO04'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[04,01], space(30) ), space(30) )                        , "@!"                   , 'STR0150'} )
       aAdd( aExp, {'GPE_DTFL04'            , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[04,02], space(08) ), space(08) )                        , ""                     , 'STR0151'} )
       aAdd( aExp, {'GPE_CFILHO05'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[05,01], space(30) ), space(30) )                        , "@!"                   , 'STR0150'} )
       aAdd( aExp, {'GPE_DTFL05'            , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[05,02], space(08) ), space(08) )                        , ""                     , 'STR0151'} )
       aAdd( aExp, {'GPE_CFILHO06'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[06,01], space(30) ), space(30) )                        , "@!"                   , 'STR0150'} )
       aAdd( aExp, {'GPE_DTFL06'            , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[06,02], space(08) ), space(08) )                        , ""                     , 'STR0151'} )
       aAdd( aExp, {'GPE_CFILHO07'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[07,01], space(30) ), space(30) )                        , "@!"                   , 'STR0150'} )
       aAdd( aExp, {'GPE_DTFL07'            , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[07,02], space(08) ), space(08) )                        , ""                     , 'STR0151'} )
       aAdd( aExp, {'GPE_CFILHO08'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[08,01], space(30) ), space(30) )                        , "@!"                   , 'STR0150'} )
       aAdd( aExp, {'GPE_DTFL08'            , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[08,02], space(08) ), space(08) )                        , ""                     , 'STR0151'} )
       aAdd( aExp, {'GPE_CFILHO09'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[09,01], space(30) ), space(30) )                        , "@!"                   , 'STR0150'} )
       aAdd( aExp, {'GPE_DTFL09'            , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[09,02], space(08) ), space(08) )                        , ""                     , 'STR0151'} )
       aAdd( aExp, {'GPE_CFILHO10'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[10,01], space(30) ), space(30) )                        , "@!"                   , 'STR0150'} )
       aAdd( aExp, {'GPE_DTFL10'            , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[10,02], space(08) ), space(08) )                        , ""                     , 'STR0151'} )
       aAdd( aExp, {'GPE_DESC_ESTEMP'       , alltrim( fDesc("SX5", "12"+aInfo[06], "X5_DESCRI"))                                 , "@!"                   , 'STR0134'} ) 
       aAdd( aExp, {'GPE_cGrau01'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[01,03], space(10) ), space(10) )                         , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_cGrau02'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[02,03], space(10) ), space(10) )                        , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_cGrau03'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[03,03], space(10) ), space(10) )                        , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_cGrau04'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[04,03], space(10) ), space(10) )                        , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_cGrau05'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[05,03], space(10) ), space(10) )                        , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_cGrau06'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[06,03], space(10) ), space(10) )                        , "@!"                   , 'STR0153'} )
       aAdd( aExp, {'GPE_cGrau07'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[07,03], space(10) ), space(10) )                        , "@!"                   , 'STR0153'} )
       aAdd( aExp, {'GPE_cGrau08'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[08,03], space(10) ), space(10) )                        , "@!"                   , 'STR0153'} )
       aAdd( aExp, {'GPE_cGrau09'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[09,03], space(10) ), space(10) )                        , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_cGrau10'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[10,03], space(10) ), space(10) )                        , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_LOCAL01'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[01,04], space(10) ), space(10) )                        , "@!"                   , 'STR0164'} ) 
       aAdd( aExp, {'GPE_CARTORIO01'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[01,05], space(10) ), space(10) )                        , "@!"                   , 'STR0156'} ) 
       aAdd( aExp, {'GPE_NREGISTRO01'       , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[01,06], space(10) ), space(10) )                        , "@!"                   , 'STR0165'} ) 
       aAdd( aExp, {'GPE_NLIVRO01'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[01,07], space(10) ), space(10) )                        , "@!"                   , 'STR0158'} ) 
       aAdd( aExp, {'GPE_NFOLHA01'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[01,08], space(10) ), space(10) )                        , "@!"                   , 'STR0159'} ) 
       aAdd( aExp, {'GPE_DT_ENTREGA01'      , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[01,09], space(10) ), space(10) )                        , "@!"                   , 'STR0160'} ) 
       aAdd( aExp, {'GPE_DT_BAIXA01'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[01,10], space(10) ), space(10) )                        , "@!"                   , 'STR0161'} ) 
       aAdd( aExp, {'GPE_LOCAL02'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[02,04], space(10) ), space(10) )                        , "@!"                   , 'STR0164'} ) 
       aAdd( aExp, {'GPE_CARTORIO02'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[02,05], space(10) ), space(10) )                        , "@!"                   , 'STR0156'} ) 
       aAdd( aExp, {'GPE_NREGISTRO02'       , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[02,06], space(10) ), space(10) )                        , "@!"                   , 'STR0165'} ) 
       aAdd( aExp, {'GPE_NLIVRO02'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[02,07], space(10) ), space(10) )                        , "@!"                   , 'STR0158'} ) 
       aAdd( aExp, {'GPE_NFOLHA02'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[02,08], space(10) ), space(10) )                        , "@!"                   , 'STR0159'} ) 
       aAdd( aExp, {'GPE_DT_ENTREGA02'      , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[02,09], space(10) ), space(10) )                        , "@!"                   , 'STR0160'} ) 
       aAdd( aExp, {'GPE_DT_BAIXA02'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[02,10], space(10) ), space(10) )                        , "@!"                   , 'STR0161'} ) 
       aAdd( aExp, {'GPE_LOCAL03'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[03,04], space(10) ), space(10) )                        , "@!"                   , 'STR0164'} ) 
       aAdd( aExp, {'GPE_CARTORIO03'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[03,05], space(10) ), space(10) )                        , "@!"                   , 'STR0156'} ) 
       aAdd( aExp, {'GPE_NREGISTRO03'       , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[03,06], space(10) ), space(10) )                        , "@!"                   , 'STR0165'} ) 
       aAdd( aExp, {'GPE_NLIVRO03'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[03,07], space(10) ), space(10) )                        , "@!"                   , 'STR0158'} ) 
       aAdd( aExp, {'GPE_NFOLHA03'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[03,08], space(10) ), space(10) )                        , "@!"                   , 'STR0159'} ) 
       aAdd( aExp, {'GPE_DT_ENTREGA03'      , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[03,09], space(10) ), space(10) )                        , "@!"                   , 'STR0160'} ) 
       aAdd( aExp, {'GPE_DT_BAIXA03'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[03,10], space(10) ), space(10) )                        , "@!"                   , 'STR0161'} ) 
       aAdd( aExp, {'GPE_LOCAL04'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[04,04], space(10) ), space(10) )                        , "@!"                   , 'STR0164'} ) 
       aAdd( aExp, {'GPE_CARTORIO04'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[04,05], space(10) ), space(10) )                        , "@!"                   , 'STR0156'} ) 
       aAdd( aExp, {'GPE_NREGISTRO04'       , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[04,06], space(10) ), space(10) )                        , "@!"                   , 'STR0165'} ) 
       aAdd( aExp, {'GPE_NLIVRO04'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[04,07], space(10) ), space(10) )                        , "@!"                   , 'STR0158'} ) 
       aAdd( aExp, {'GPE_NFOLHA04'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[04,08], space(10) ), space(10) )                        , "@!"                   , 'STR0159'} ) 
       aAdd( aExp, {'GPE_DT_ENTREGA04'      , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[04,09], space(10) ), space(10) )                        , "@!"                   , 'STR0160'} ) 
       aAdd( aExp, {'GPE_DT_BAIXA04'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[04,10], space(10) ), space(10) )                        , "@!"                   , 'STR0161'} ) 
       aAdd( aExp, {'GPE_LOCAL05'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[05,04], space(10) ), space(10) )                        , "@!"                   , 'STR0164'} ) 
       aAdd( aExp, {'GPE_CARTORIO05'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[05,05], space(10) ), space(10) )                        , "@!"                   , 'STR0156'} )
       aAdd( aExp, {'GPE_NREGISTRO05'       , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[05,06], space(10) ), space(10) )                        , "@!"                   , 'STR0165'} ) 
       aAdd( aExp, {'GPE_NLIVRO05'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[05,07], space(10) ), space(10) )                        , "@!"                   , 'STR0158'} ) 
       aAdd( aExp, {'GPE_NFOLHA05'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[05,08], space(10) ), space(10) )                        , "@!"                   , 'STR0159'} ) 
       aAdd( aExp, {'GPE_DT_ENTREGA05'      , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[05,09], space(10) ), space(10) )                        , "@!"                   , 'STR0160'} ) 
       aAdd( aExp, {'GPE_DT_BAIXA05'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[05,10], space(10) ), space(10) )                        , "@!"                   , 'STR0161'} ) 
       aAdd( aExp, {'GPE_LOCAL06'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[06,04], space(10) ), space(10) )                        , "@!"                   , 'STR0164'} ) 
       aAdd( aExp, {'GPE_CARTORIO06'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[06,05], space(10) ), space(10) )                        , "@!"                   , 'STR0156'} ) 
       aAdd( aExp, {'GPE_NREGISTRO06'       , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[06,06], space(10) ), space(10) )                        , "@!"                   , 'STR0165'} ) 
       aAdd( aExp, {'GPE_NLIVRO06'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[06,07], space(10) ), space(10) )                        , "@!"                   , 'STR0158'} ) 
       aAdd( aExp, {'GPE_NFOLHA06'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[06,08], space(10) ), space(10) )                        , "@!"                   , 'STR0159'} ) 
       aAdd( aExp, {'GPE_DT_ENTREGA06'      , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[06,09], space(10) ), space(10) )                        , "@!"                   , 'STR0160'} ) 
       aAdd( aExp, {'GPE_DT_BAIXA06'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[06,10], space(10) ), space(10) )                        , "@!"                   , 'STR0161'} ) 
       aAdd( aExp, {'GPE_LOCAL07'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[07,04], space(10) ), space(10) )                        , "@!"                   , 'STR0164'} ) 
       aAdd( aExp, {'GPE_CARTORIO07'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[07,05], space(10) ), space(10) )                        , "@!"                   , 'STR0156'} ) 
       aAdd( aExp, {'GPE_NREGISTRO07'       , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[07,06], space(10) ), space(10) )                        , "@!"                   , 'STR0165'} ) 
       aAdd( aExp, {'GPE_NLIVRO07'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[07,07], space(10) ), space(10) )                        , "@!"                   , 'STR0158'} ) 
       aAdd( aExp, {'GPE_NFOLHA07'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[07,08], space(10) ), space(10) )                        , "@!"                   , 'STR0159'} ) 
       aAdd( aExp, {'GPE_DT_ENTREGA07'      , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[07,09], space(10) ), space(10) )                        , "@!"                   , 'STR0160'} ) 
       aAdd( aExp, {'GPE_DT_BAIXA07'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[07,10], space(10) ), space(10) )                        , "@!"                   , 'STR0161'} ) 
       aAdd( aExp, {'GPE_LOCAL08'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[08,04], space(10) ), space(10) )                        , "@!"                   , 'STR0164'} ) 
       aAdd( aExp, {'GPE_CARTORIO08'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[08,05], space(10) ), space(10) )                        , "@!"                   , 'STR0156'} ) 
       aAdd( aExp, {'GPE_NREGISTRO08'       , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[08,06], space(10) ), space(10) )                        , "@!"                   , 'STR0165'} ) 
       aAdd( aExp, {'GPE_NLIVRO08'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[08,07], space(10) ), space(10) )                        , "@!"                   , 'STR0158'} ) 
       aAdd( aExp, {'GPE_NFOLHA08'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[08,08], space(10) ), space(10) )                        , "@!"                   , 'STR0159'} ) 
       aAdd( aExp, {'GPE_DT_ENTREGA08'      , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[08,09], space(10) ), space(10) )                        , "@!"                   , 'STR0160'} ) 
       aAdd( aExp, {'GPE_DT_BAIXA08'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[08,10], space(10) ), space(10) )                        , "@!"                   , 'STR0161'} ) 
       aAdd( aExp, {'GPE_LOCAL09'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[09,04], space(10) ), space(10) )                        , "@!"                   , 'STR0164'} ) 
       aAdd( aExp, {'GPE_CARTORIO09'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[09,05], space(10) ), space(10) )                        , "@!"                   , 'STR0156'} ) 
       aAdd( aExp, {'GPE_NREGISTRO09'       , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[09,06], space(10) ), space(10) )                        , "@!"                   , 'STR0165'} ) 
       aAdd( aExp, {'GPE_NLIVRO09'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[09,07], space(10) ), space(10) )                        , "@!"                   , 'STR0158'} ) 
       aAdd( aExp, {'GPE_NFOLHA09'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[09,08], space(10) ), space(10) )                        , "@!"                   , 'STR0159'} ) 
       aAdd( aExp, {'GPE_DT_ENTREGA09'      , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[09,09], space(10) ), space(10) )                        , "@!"                   , 'STR0160'} ) 
       aAdd( aExp, {'GPE_DT_BAIXA09'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[09,10], space(10) ), space(10) )                        , "@!"                   , 'STR0161'} ) 
       aAdd( aExp, {'GPE_LOCAL10'           , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[10,04], space(10) ), space(10) )                        , "@!"                   , 'STR0164'} ) 
       aAdd( aExp, {'GPE_CARTORIO10'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[10,05], space(10) ), space(10) )                        , "@!"                   , 'STR0156'} ) 
       aAdd( aExp, {'GPE_NREGISTRO10'       , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[10,06], space(10) ), space(10) )                        , "@!"                   , 'STR0165'} ) 
       aAdd( aExp, {'GPE_NLIVRO10'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[10,07], space(10) ), space(10) )                        , "@!"                   , 'STR0158'} ) 
       aAdd( aExp, {'GPE_NFOLHA10'          , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[10,08], space(10) ), space(10) )                        , "@!"                   , 'STR0159'} ) 
       aAdd( aExp, {'GPE_DT_ENTREGA10'      , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[10,09], space(10) ), space(10) )                        , "@!"                   , 'STR0160'} ) 
       aAdd( aExp, {'GPE_DT_BAIXA10'        , if(nDepen == 1 .or. nDepen == 3, Iif( Len(aDepenSF) > 0, aDepenSF[10,10], space(10) ), space(10) )                        , "@!"                   , 'STR0161'} ) 
       //IMPOSTO DE RENDA//
     //aAdd( aExp, {'GPE_CDEPE01'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[01,01], space(30) ), space(30) )                         , "@!"                   , 'STR0154'} )
       aAdd( aExp, {'GPE_CDEPE01'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[01,01], space(30) ), space(30) )                         , "@!"                   , 'STR0154'} )
       aAdd( aExp, {'GPE_cGrDp01'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[01,03], space(10) ), space(10) )                         , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_DTFLIR01'          , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[01,02], space(08) ), space(08) )                         , ""                     , 'STR0163'} )
       aAdd( aExp, {'GPE_CDEPE02'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[02,01], space(30) ), space(30) )                         , "@!"                   , 'STR0154'} )
       aAdd( aExp, {'GPE_cGrDp02'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[02,03], space(10) ), space(10) )                         , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_DTFLIR02'          , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[02,02], space(08) ), space(08) )                         , ""                     , 'STR0163'} )
       aAdd( aExp, {'GPE_CDEPE03'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[03,01], space(30) ), space(30) )                         , "@!"                   , 'STR0154'} )
       aAdd( aExp, {'GPE_cGrDp03'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[03,03], space(10) ), space(10) )                         , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_DTFLIR03'          , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[03,02], space(08) ), space(08) )                         , ""                     , 'STR0163'} )
       aAdd( aExp, {'GPE_CDEPE04'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[04,01], space(30) ), space(30) )                         , "@!"                   , 'STR0154'} )
       aAdd( aExp, {'GPE_cGrDp04'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[04,03], space(10) ), space(10) )                         , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_DTFLIR04'          , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[04,02], space(08) ), space(08) )                         , ""                     , 'STR0163'} )
       aAdd( aExp, {'GPE_CDEPE05'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[05,01], space(30) ), space(30) )                         , "@!"                   , 'STR0154'} )
       aAdd( aExp, {'GPE_cGrDp05'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[05,03], space(10) ), space(10) )                         , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_DTFLIR05'          , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[05,02], space(08) ), space(08) )                         , ""                     , 'STR0163'} )
       aAdd( aExp, {'GPE_CDEPE06'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[06,01], space(30) ), space(30) )                         , "@!"                   , 'STR0154'} )
       aAdd( aExp, {'GPE_cGrDp06'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[06,03], space(10) ), space(10) )                         , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_DTFLIR06'          , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[06,02], space(08) ), space(08) )                         , ""                     , 'STR0163'} )
       aAdd( aExp, {'GPE_CDEPE07'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[07,01], space(30) ), space(30) )                         , "@!"                   , 'STR0154'} )
       aAdd( aExp, {'GPE_cGrDp07'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[07,03], space(10) ), space(10) )                         , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_DTFLIR07'          , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[07,02], space(08) ), space(08) )                         , ""                     , 'STR0163'} )
       aAdd( aExp, {'GPE_CDEPE08'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[08,01], space(30) ), space(30) )                         , "@!"                   , 'STR0154'} )
       aAdd( aExp, {'GPE_cGrDp08'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[08,03], space(10) ), space(10) )                         , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_DTFLIR08'          , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[08,02], space(08) ), space(08) )                         , ""                     , 'STR0163'} )
       aAdd( aExp, {'GPE_CDEPE09'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[09,01], space(30) ), space(30) )                         , "@!"                   , 'STR0154'} )
       aAdd( aExp, {'GPE_cGrDp09'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[09,03], space(10) ), space(10) )                         , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_DTFLIR09'          , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[09,02], space(08) ), space(08) )                         , ""                     , 'STR0163'} )
       aAdd( aExp, {'GPE_CDEPE10'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[10,01], space(30) ), space(30) )                         , "@!"                   , 'STR0154'} )
       aAdd( aExp, {'GPE_cGrDp10'           , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[10,03], space(10) ), space(10) )                         , "@!"                   , 'STR0153'} ) 
       aAdd( aExp, {'GPE_DTFLIR10'          , if(nDepen == 2 .or. nDepen == 3, Iif( Len(aDepenIR) > 0, aDepenIR[10,02], space(08) ), space(08) )                         , ""                     , 'STR0163'} )
       aAdd( aExp, {'GPE_MES_ADEXT'         , MesExtenso( Month( SRA->RA_ADMISSA ) )                                               , "@!"                   , 'STR0155'} )
       If cPaisLoc == "ARG"
       aAdd( aExp, {'GPE_MES_ADEXT'         , MesExtenso( Month( SRA->RA_ADMISSA ) )                                               , "@!"                   , 'STR0155'} )
       aAdd( aExp, {'GPE_APODERADO'         , cApoderado                                                                           , "@!"                   , 'STR0156'} )
       aAdd( aExp, {'GPE_ATIVIDADE'         , cRamoAtiv                                                                            , "@!"                   , 'STR0157'} )
       EndIf	
       aAdd( aExp, {'GPE_MUNICNASC'         , if(SRA->( FieldPos("RA_MUNNASC") ) # 0, SRA->RA_MUNNASC, space(20))                  , "@!"                   , 'STR0166'} )
              
       //CAMPOS ESPECIFICOS PARA BRASILUX
       nDiaPriExper := SRA->RA_ADMISSA + 44
       nDiaPriEEntr := SRA->RA_ADMISSA + 39
       nDiaSegExper := SRA->RA_ADMISSA + 89
       nDiaSegEEntr := SRA->RA_ADMISSA + 84
       aAdd( aExp, {'GPE_PRIEXPER'          , nDiaPriExper                                                                        , "SRA->RA_ADMISSA"      , 'STR0049'} )
       aAdd( aExp, {'GPE_PRIEENTR'          , nDiaPriEEntr                                                                        , "SRA->RA_ADMISSA"      , 'STR0049'} )
       aAdd( aExp, {'GPE_SEGEXPER'          , nDiaSegExper                                                                        , "SRA->RA_ADMISSA"      , 'STR0049'} )
       aAdd( aExp, {'GPE_SEGEENTR'          , nDiaSegEEntr                                                                        , "SRA->RA_ADMISSA"      , 'STR0049'} )
       If Len(aDePenSF) > 0
          If Empty(aDePenSF[1][1])
             aAdd( aExp, {'GPE_TEXTOSF01'      , 'NÃO HÁ FILHOS DECLARADOS NESTA DATA'                                            , "@!"                   , 'Variável utilizada no salário Familia'} )
          Else
             aAdd( aExp, {'GPE_TEXTOSF01'      , ''                                                                               , "@!"                   , 'Variável utilizada no salário Familia'} )
          Endif
       Endif
       aAdd( aExp, {'GPE_MES_EXPEREXTENSO'  , MesExtenso( SRA->RA_VCTOEXP )                                                       , "@!"                   , 'Mês Experiencia Extenso'} )
       
       //2º Experiencia
       aAdd( aExp, {'GPE_DATA_EXPERIENCIA2'  , SRA->RA_VCTEXP2                                                                          , "SRA->RA_VCTEXP2"      , 'Data de Experiência'                  } )
       aAdd( aExp, {'GPE_DIA_EXPERIENCIA2'   , StrZero( Day( SRA->RA_VCTEXP2 ) , 2 )                                                    , "@!"                   , 'STR0056'} )
       aAdd( aExp, {'GPE_MES_EXPERIENCIA2'   , StrZero( Month( SRA->RA_VCTEXP2 ) , 2 )                                                  , "@!"                   , 'STR0057'} )
       aAdd( aExp, {'GPE_ANO_EXPERIENCIA2'   , StrZero( Year( SRA->RA_VCTEXP2 ) , 4 )                                                   , "@!"                   , 'STR0058'} )
       aAdd( aExp, {'GPE_DIAS_EXPERIENCIA2'  , StrZero(SRA->(RA_VCTEXP2-RA_ADMISSA)+1,03)                                               , "@!"                   , 'STR0059'} )       
       aAdd( aExp, {'GPE_MES_EXPERIENCIA2'   , MesExtenso( SRA->RA_VCTEXP2 )                                                            , "@!"                   , 'Mês Experiencia Extenso'} )
       
       dDtValAdmiss := DataValida(SRA->RA_ADMISSA + 2)
       aAdd( aExp, {'GPE_DATA_VLADMI'   , dDtValAdmiss                                                                             , "SRA->RA_ADMISSA"      , 'Data de Admissão'                     } )
       aAdd( aExp, {'GPE_DIA_VLADMI'    , StrZero( Day( dDtValAdmiss ) , 2 )                                                       , "@!"                   , 'Dia da Admissão'                      } )
       aAdd( aExp, {'GPE_MES_VLADMI'    , StrZero( Month( dDtValAdmiss ) , 2 )                                                     , "@!"                   , 'Mês de Admissão'                      } )
       aAdd( aExp, {'GPE_ANO_VLADMI'    , StrZero( Year( dDtValAdmiss ) , 4)                                                       , "@!"                   , 'Ano de Admissão'                      } )
       
Return( aExp )

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³          Grupo  Ordem  Pergunta Portugues     Pergunta Espanhol    Pergunta Ingles   Variavel  Tipo Tamanho Decimal  Presel  GSC Valid                              Var01      Def01              DefSPA1     DefEng1  Cnt01             Var02  Def02    		  DefSpa2  DefEng2	Cnt02  Var03  Def03      DefSpa3    DefEng3  Cnt03  Var04  Def04     DefSpa4    DefEng4  Cnt04  Var05  Def05       DefSpa5	 DefEng5   Cnt05  XF3   GrgSxg ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aRegs,{cPerg,  '01' ,'Filial De          ?' ,''				       ,''			       ,'mv_ch1' ,'C'  ,02     ,0      ,0     ,'G','                                ','mv_par01','               '  ,''		     ,''	     ,'                ',''   ,'        	   ',''    	 ,''   	  ,''	   ,''    ,'       ' ,''        ,''   	  ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'SM0',''})
aAdd(aRegs,{cPerg,  '02' ,'Filial Ate         ?' ,''				       ,''			       ,'mv_ch2' ,'C'  ,02     ,0      ,0     ,'G','naovazio                        ','mv_par02','               '  ,''		 ,''	 ,REPLICATE('9',02) ,''   ,'        	   ',''   	 ,''  	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,'' 	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'SM0',''})
aAdd(aRegs,{cPerg,  '03' ,'Centro de Custo De ?' ,''				       ,''			       ,'mv_ch3' ,'C'  ,09     ,0      ,0     ,'G','                                ','mv_par03','               '  ,''		 ,''	 ,'                ',''   ,'        	   ',''   	 ,''  	  ,''	 ,''   ,'       ' ,''  		 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'SI3',''})
aAdd(aRegs,{cPerg,  '04' ,'Centro de Custo Ate?' ,''				       ,''			       ,'mv_ch4' ,'C'  ,09     ,0      ,0     ,'G','naovazio                        ','mv_par04','               '  ,''		 ,''	 ,REPLICATE('Z',09) ,''   ,'        	   ',''		 ,''  	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'SI3',''})
aAdd(aRegs,{cPerg,  '05' ,'Matricula De       ?' ,''				       ,''			       ,'mv_ch5' ,'C'  ,06     ,0      ,0     ,'G','                                ','mv_par05','               '  ,''		 ,''	 ,'                ',''   ,'        	   ',''    	 ,''  	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'SRA',''})
aAdd(aRegs,{cPerg,  '06' ,'Matricula Ate      ?' ,''				       ,''			       ,'mv_ch6' ,'C'  ,06     ,0      ,0     ,'G','naovazio                        ','mv_par06','               '  ,''		 ,''	 ,REPLICATE('Z',06) ,''   ,'        	   ',''    	 ,''  	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ','' 		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'SRA',''})
aAdd(aRegs,{cPerg,  '07' ,'Nome De            ?' ,''				       ,''			       ,'mv_ch7' ,'C'  ,30     ,0      ,0     ,'G','                                ','mv_par07','               '  ,''		 ,''	 ,'                ',''   ,'        	   ',''    	 ,''  	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,  '08' ,'Nome Ate           ?' ,''				       ,''			       ,'mv_ch8' ,'C'  ,30     ,0      ,0     ,'G' ,'naovazio                       ','mv_par08','               '  ,''		 ,''	 ,REPLICATE('Z',30) ,''   ,'        	   ',''    	 ,''  	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,'' 	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,  '09' ,'Turno De           ?' ,''				       ,''			       ,'mv_ch9' ,'C'  ,03     ,0      ,0     ,'G','                                ','mv_par09','               '  ,''		 ,''	 ,'                ',''   ,'        	   ',''    	 ,'' 	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'SR6',''})
aAdd(aRegs,{cPerg,  '10' ,'Turno Ate          ?' ,''				       ,''			       ,'mv_cha' ,'C'  ,03     ,0      ,0     ,'G','naovazio                        ','mv_par10','               '  ,''		 ,''	 ,REPLICATE('Z',03) ,''   ,'        	   ',''    	 ,''   	  ,''	 ,''   ,'       ' ,''  	 	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'SR6',''})
aAdd(aRegs,{cPerg,  '11' ,'Fun‡ao De          ?' ,''				       ,''			       ,'mv_chb' ,'C'  ,03     ,0      ,0     ,'G','                                ','mv_par11','               '  ,''		 ,''	 ,'                ',''   ,'        	   ',''    	 ,''  	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'SRJ',''})
aAdd(aRegs,{cPerg,  '12' ,'Fun‡ao Ate         ?' ,''				       ,''			       ,'mv_chc' ,'C'  ,03     ,0      ,0     ,'G','naovazio                        ','mv_par12','               '  ,''		 ,''	 ,REPLICATE('Z',03) ,''   ,'        	   ',''    	 ,''  	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'SRJ',''})
aAdd(aRegs,{cPerg,  '13' ,'Sindicato De       ?' ,''				       ,''			       ,'mv_chd' ,'C'  ,02     ,0      ,0     ,'G','                                ','mv_par13','               '  ,''		 ,''	 ,'                ',''   ,'        	   ',''   	 ,''   	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'X04',''})
aAdd(aRegs,{cPerg,  '14' ,'Sindicato Ate      ?' ,''				       ,''			       ,'mv_che' ,'C'  ,02     ,0      ,0     ,'G','naovazio                        ','mv_par14','               '  ,''		 ,''	 ,REPLICATE('Z',03) ,''   ,'        	   ',''   	 ,''  	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'X04',''})
aAdd(aRegs,{cPerg,  '15' ,'Admissao De        ?' ,''				       ,''			       ,'mv_chf' ,'D'  ,08     ,0      ,0     ,'G','                                ','mv_par15','               '  ,''		 ,''	 ,'                ',''   ,'        	   ',''   	 ,''   	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,  '16' ,'Admissao Ate       ?' ,''				       ,''			       ,'mv_chg' ,'D'  ,08     ,0      ,0     ,'G','naovazio                        ','mv_par16','               '  ,''		 ,''	 ,'                ',''   ,'        	   ',''   	 ,''  	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,  '17' ,'Situa‡”es  a Impr. ?' ,''				       ,''			       ,'mv_chh' ,'C'  ,05     ,0      ,0     ,'G','fSituacao                       ','mv_par17','               '  ,''		 ,''	 ,'                ',''   ,'        	   ',''   	 ,''  	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,  '18' ,'Categorias a Impr. ?' ,''				       ,''			       ,'mv_chi' ,'C'  ,10     ,0      ,0     ,'G','fCategoria                      ','mv_par18','               '  ,''		 ,''	 ,'                ',''   ,'        	   ',''   	 ,''  	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,  '19' ,'Texto Livre 1      ?' ,''				       ,''			       ,'mv_chj' ,'C'  ,30     ,0      ,0     ,'G','                                ','mv_par19','               '  ,''		 ,''	 ,'<Texto Livre 01>',''   ,'        	   ',''   	 ,''  	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,  '20' ,'Texto Livre 2      ?' ,''				       ,''			       ,'mv_chk' ,'C'  ,30     ,0      ,0     ,'G','                                ','mv_par20','               '  ,''		 ,''	 ,'<Texto Livre 02>',''   ,'        	   ',''   	 ,''  	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,  '21' ,'Texto Livre 3      ?' ,''				       ,''			       ,'mv_chl' ,'C'  ,30     ,0      ,0     ,'G','                                ','mv_par21','               '  ,''		 ,''	 ,'<Texto Livre 03>',''   ,'        	   ',''   	 ,''   	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,  '22' ,'Texto Livre 4      ?' ,''				       ,''			       ,'mv_chm' ,'C'  ,30     ,0      ,0     ,'G','                                ','mv_par22','               '  ,''		 ,''	 ,'<Texto Livre 04>',''   ,'        	   ',''   	 ,''   	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,  '23' ,'Nro. de Copias     ?' ,''				       ,''			       ,'mv_chn' ,'N'  ,03     ,0      ,0     ,'G','                                ','mv_par23','               '  ,''		 ,''	 ,'                ',''   ,'        	   ',''   	 ,''   	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,  '24' ,'Ordem de Impressao ?' ,''				       ,''			       ,'mv_cho' ,'N'  ,01     ,0      ,0     ,'C','                                ','mv_par24','Matricula      '  ,''		 ,''	 ,'                ',''   ,'Centro de Custo',''   	 ,''   	  ,''	 ,''   ,'Nome   ' ,''   	 ,''      ,''	 ,''	,'Turno  ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,  '25' ,'Arquivo do Word    ?' ,''				       ,''			       ,'mv_chp' ,'C'  ,30     ,0      ,0     ,'G','fOpen_Word()                    ','mv_par25','               '  ,''		 ,''	 ,'                ',''   ,'        	   ',''   	 ,''   	  ,''	 ,''   ,'       ' ,''   	 ,''      ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'   ',''})
aAdd(aRegs,{cPerg,  '26' ,'Verific.Dependente ?' ,'Verifi.Dependiente','Check Dependent','mv_chq' ,'N'  ,1      ,0      ,1     ,'C',''                                ,'mv_par26','Sim'              ,'Yes'      ,'Si'   ,''                ,''   ,'Nao'            ,'No'           ,'No'         ,''         ,''        ,''      ,''    ,''    ,''	      ,''	     ,'      ',''  	 ,''  	,''	        ,''	       ,''		 ,''    ,''	  ,''})
aAdd(aRegs,{cPerg,  '27  ,'Tipo de Dependente ?' ,'                  ','               ','mv_chr" ,'N'  ,01     ,0      ,3     ,'C',''                                ,'mv_par27','Dep.Sal.Familia'  ,'Dep.Sal.Familia'  ,'Fam.Allow.Dep.'  ,''   ,'Dep.Imp.Renda'  ,'Dep.Imp.Renta','Income Dep.','Ambos'    ,'Ambos'   ,'Ambos' ,''	 ,''	,''	      ,''	     ,''	  ,''	 ,''	,''	        ,''	       ,''	     ,''	,''	  ,''})
aAdd(aRegs,{cPerg,  '28' ,'Impressao          ?' ,'Impresion         ','Printing       ','mv_chs' ,'N'  ,01     ,0      ,0     ,'C','                                ','mv_par28','Impressora' 		 ,'Impresone','Printer','              ',''   ,'Arquivo        ','Archivo'      ,'File'       ,''         ,''        ,'      ',''    ,''    ,''       ,''        ,'      ',''    ,''    ,''         ,''        ,''       ,''    ,''   ,''})
aAdd(aRegs,{cPerg,  '29' ,'Arquivo Saida      ?' ,'Archivo Salida    ','Output File    ','mv_cht' ,'C'  ,30     ,0      ,0     ,'G','                                ','mv_par29','         '  		 ,''         ,''     ,'                ',''   ,'               ',''      ,''      ,''    ,''   ,'       ' ,''        ,''      ,''    ,''    ,'       ',''        ,''      ,''    ,''    ,''         ,''        ,''       ,''    ,'   ',''})
*/
