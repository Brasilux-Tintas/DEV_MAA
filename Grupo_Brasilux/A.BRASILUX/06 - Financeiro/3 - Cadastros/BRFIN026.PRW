#include "rwmake.ch"
#include "fina290.ch"
#include "topconn.ch"  
#include "brfatx01.ch"  
#include "vkey.ch"
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFIN026 ºAutor  ³ Paulo Boschetti    º Data ³  27/07/93   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Seleção de titulos para Fatura                             º±±
±±º          ³ Programa original FINA290, adaptado para uso específico.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNINCAS LTDA.                            ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFIN026
     Private aRotina := { { OemToAnsi(STR0001), "AxPesqui"   , 0, 1 },; //"Pesquisar"
                          { OemToAnsi(STR0002), "FA050Visua" , 0, 2 },; //"Visualizar"
                          { OemToAnsi(STR0003), "U_BfA290Aut", 0, 3 },; //"Selecionar"
                          { OemToAnsi(STR0004), "FA290Can"   , 0, 6 } } //"Cancelar"

     Private cFatura   := CRIAVAR("E2_FATURA")
     Private cForn     := Space(6)
     Private cLoja     := Space(2)
     Private cPrefix   := CRIAVAR("E2_PREFIXO", .T.)
     Private dVencto   := Ctod(Space(8))
     Private dDataDe   := dDataBase
     Private dDataAte  := dDataBase
     Private nValor    := 0
     Private nValorFat := 0
     Private cNat      := Space(10)
     Private nTotAbat  := 0
     Private nValCruz  := 0
     Private aVlCruz   := {}
     Private aDupl
     Private nValtot   := 0
     Private aVenc     := {}
     Private nMoeda    := 1
     Private nIndex    := 0
     Private cFil290
     Private cLote
     Private oFatura
     Private lFocus    := .F.
     Private oTipo
     Private oNat

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Define o cabecalho da tela de baixas                         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Private cCadastro := OemToAnsi(STR0005) //"Aglutina‡„o de Titulos"
     u_zcfga01( 'BRFIN026' ) //LGS#2021202 - Gravação de log de utilização da rotina
     DbSelectArea("SE2")
     DbSetOrder(1)
     DbGoTop()

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Carrega a funcao pergunte                                    ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     SetKey (VK_F12, {|a,b| AcessaPerg("AFI290", .T.)})
     Pergunte("AFI290", .F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Endereca a Fun‡„o de BROWSE                                  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     mBrowse( 6, 1, 22, 75, "SE2",, "!E2_SALDO")

     Set Key VK_F12 to

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Recupera a Integridade dos dados                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("SE2")
     DbSetOrder(1)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ fA290Aglu³ Autor ³ Paulo Boschetti       ³ Data ³ 27/07/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marcacao dos titulos para emissao de fatura                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fa290Aglu()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BfA290Aut(cAlias, cCampo, nOpcE)
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Define Variaveis 														  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     //Local lRet       := .F.
     //Local aCRA       := {OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008)} //"Confirma"###"Redigita"###"Abandona"
     Local cArquivo
     Local nTotal     := 0
     Local nHdlPrv    := 0
     Local lPadrao
     Local cPadrao    := "587"
     //Local nOpcc      := 1
     Local nW         := 1
     Local dDatCont   := dDatabase
     Local cCondicao  := Space(3)
     Local cIndex     := ""
     Local nOpca      := 0
     Local oDlg, oDlg1, oDlg2
     Local oGet
     Local oValor     := 0
     Local oQtdTit    := 0
     Local oValorFat  := 0
     Local cMarca     := GetMark()
     Local aMoedas    := {}
     Local oCbx
     Local cVar,nO
     //Local nOrdSe2    :=0
     Local aCampos    := {}
     Local lF290PRE   := (ExistBlock("F290PRE")) // Pto Entrada inicializar variaveis
     Local cSequencia := "00"
     Local nRecSe2    := 0
     Local cAliasSE2  := "SE2"
     Local cSetFilter := SE2->(DBFILTER()) // Salva o filtro atual, para restaurar no final da rotina
     //Local cFilSx6
     Local nValTotal  := 0
     Local lHead      := .F.
     Local lF290Baixa := Existblock("F290BAIXA")
     Local i, nX
     //Local nY
     Local _lOpen        := .F. //LGS#20200130 - Adequação para release 12.1.25
     Private _cAliasSX3  := GetNextAlias() //LGS#20200130 - Adequação para release 12.1.25
     Private lF290OWN := (ExistBlock("F290OWN")) // Ponto de entrada p/ indregua
     Private _lFA290  := ( ExistBlock("FA290") ) //LGS#20200130 - Adequação para release 12.1.25

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica se data do movimento n„o ‚ menor que data limite de ³
     //³ movimentacao no financeiro                                   ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If !DtMovFin()
        Return
     Endif

     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200128 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0

     If !lOpen
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicializa alias alternativo para AS400 para ser utilizado   ³
     //³ apenas no momento da grava‡Æo dos novos registos gerados	  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     #IFDEF TOP
            If TcSrvType() == "AS/400"
               If Select("SE2_FAT") == 0
                  ChkFile("SE2", .F., "SE2_FAT")
               Else
                  DbSelectArea("SE2_FAT")
               Endif
               cAliasSE2 := "SE2_FAT"
            Endif
     #ENDIF

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ ACIONA A FUNCAO PERGUNTE                                     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     SetKey (VK_F12,{|a,b| AcessaPerg("AFI290", .T.)})
     Pergunte("AFI290", .F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicializa array com as moedas existentes.                   ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     aMoedas := FDescMoed()

     DbSelectArea( cAlias )

     Private lInverte := .F.
     Private aHeader  := {}
     Private aCols    := {}
     Private oValTot  := 0
     Private nValTot  := 0
     Private nUsado   := 0
     Private cTipo    := Criavar ("E2_TIPOFAT")
     Private cFornP   := CRIAVAR("E2_FORNECE", .F.)
     Private cLojaP   := CRIAVAR("E2_LOJA", .F.)
     Private nJur290  := 0
     Private nDesc290 := 0

     //LGS#20200130 - Adequação do release 12.1.25 e posteriores
     //DbSelectArea("SX3")
     //DbSetOrder(2)
     //DbSeek("E2_PREFIXO")
     //cPictPref := AllTrim(X3_PICTURE)
     //DbSetOrder(1)
     cPictPref := PesqPict( "SE2", "E2_PREFIXO" )
     
     aTam  := TamSX3("E2_FORNECE")
     cForn := Space(aTam[1])

     aTam  := TamSX3("E2_LOJA")
     cLoja := Space(aTam[1])

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica o numero do Lote                                    ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     LoteCont( "FIN" )

     DbSelectArea(cAlias)
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Recebe dados a serem digitados                               ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     cVar    := aMoedas[1]
     aTam    := TamSx3("E2_FATURA")
     cFatura := Soma1(GetMv("MV_NUMFATP"), aTam[1])
     cFatura += Space(aTam[1] - Len(cFatura))
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Ponto de Entrada para inicializacao das vari veis da fatura  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If lF290PRE
        ExecBlock("F290PRE", .F., .F.)
     Endif

     DEFINE MSDIALOG oDlg FROM	22,9 TO 260,540 TITLE OemToAnsi(STR0009) PIXEL //"Faturas a Pagar"
            @ 020, 014 MSGET cPrefix	Pict cPictPref  			 SIZE 10, 11 OF oDlg PIXEL
            @ 020, 040 MSGET oTipo VAR cTipo		F3 "05" Picture "@!" Valid (!Empty (cTipo) .and. FA290Tipo(@cTipo)) SIZE 10, 11 OF oDlg PIXEL 		
            @ 020, 068 MSGET oFATURA VAR cFatura	Valid !Empty(cFatura) SIZE 50, 11 OF oDlg PIXEL
            @ 020, 120 MSGET oNat VAR cNat		F3 "SED" Valid Fa290Nat() SIZE 55, 11 OF oDlg PIXEL
            @ 020, 175 MSCOMBOBOX oCbx VAR cVar ITEMS aMoedas 		SIZE 46, 55 OF oDlg PIXEL

            @ 054, 014 MSGET dDataDe	Valid !Empty(dDataDe)		SIZE 50, 11 OF oDlg PIXEL
            @ 054, 068 MSGET dDataAte	Valid !Empty(dDataAte) .and. dDataAte >= dDataDe SIZE 50, 11 OF oDlg PIXEL
            @ 054, 120 MSGET nValorFat Picture "@E 9,999,999,999.99"    SIZE 65, 11 OF oDlg PIXEL

            @ 085, 014 MSGET cForn		F3 "FOR" Valid Fa290For(cForn) 	SIZE 65, 11 OF oDlg PIXEL
            @ 085, 079 MSGET cLoja		When mv_par01 == 1 Valid Fa290For(cForn,cLoja) SIZE 21, 11 OF oDlg PIXEL

            @ 085, 120 MSGET cFornP		When mv_par01 == 2 F3 "FOR" Valid Fa290For(cFornP) .And. Fa290Num()	SIZE 65, 11 OF oDlg PIXEL
            @ 085, 185 MSGET cLojaP		When mv_par01 == 2 Valid Fa290For(cFornP,cLojaP)	SIZE 21, 11 OF oDlg PIXEL

            @ 010, 014 SAY OemToAnsi(STR0010) SIZE 20, 7 OF oDlg PIXEL //"Prefixo"
            @ 010, 040 SAY OemToAnsi(STR0053) SIZE 12, 7 OF oDlg PIXEL //"Tp"
            @ 010, 068 SAY OemToAnsi(STR0055) SIZE 49, 7 OF oDlg PIXEL //"Nr.Fatura"
            @ 010, 120 SAY OemToAnsi(STR0012) SIZE 25, 7 OF oDlg PIXEL //"Natureza"
            @ 010, 175 SAY OemToAnsi(STR0013) SIZE 25, 7 OF oDlg PIXEL //"Moeda"

            @ 044, 014 SAY OemToAnsi(STR0014) SIZE 30, 7 OF oDlg PIXEL //"EmissÆo de"
            @ 044, 068 SAY OemToAnsi(STR0015) SIZE 10, 7 OF oDlg PIXEL //"At‚"
            @ 044, 120 SAY OemToAnsi(STR0016) SIZE 50, 7 OF oDlg PIXEL //"Valor da Fatura"

            @ 075, 014 SAY OemToAnsi(STR0017) SIZE 30, 7 OF oDlg PIXEL //"Fornecedor"
            @ 075, 079 SAY OemToAnsi(STR0018) SIZE 30, 7 OF oDlg PIXEL //"Loja"
            @ 075, 120 SAY OemToAnsi(STR0057) SIZE 50, 7 OF oDlg PIXEL //"Gerar p/Fornecedor"
            @ 075, 185 SAY OemToAnsi(STR0018) SIZE 30, 7 OF oDlg PIXEL //"Loja"

            @ 004, 007 TO 036, 225 OF oDlg PIXEL
            @ 038, 007 TO 070, 225 OF oDlg PIXEL
            @ 072, 007 TO 104, 225 OF oDlg PIXEL

            DEFINE SBUTTON FROM 07, 230 TYPE 1 ACTION (nOpca:=1,IF(If(FA290NUM() .and. !lFocus, FA290Ok() ,.F.),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
            DEFINE SBUTTON FROM 21, 230 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

     ACTIVATE MSDIALOG oDlg CENTERED

     If nOpca == 0
        Return
     EndIf

     nMoeda := Val(SubStr(cVar, 1, 2))

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Execblock a ser executado antes da Indregua                  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If (ExistBlock("F290FIL"))
        cFil290 := ExecBlock("F290FIL", .f., .f.)
     Else
        cFil290 := ".T."
     Endif

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Cria indice condicional                                      ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("SE2")
     DbSetOrder(6)
     cIndex := CriaTrab(nil, .f.)
     cChave := IndexKey()
     IndRegua(cAlias, cIndex, cChave, , Fa290ChecF(), OemToAnsi(STR0019))  //"Selecionando Registros..."
     nIndex := RetIndex(cAlias)
     DbSelectArea(cAlias)
     #IFNDEF TOP
             DbSetIndex(cIndex+OrdBagExt())
     #ENDIF
     DbSetOrder(nIndex+1)
     DbGoTop()
     If BOF() .and. EOF()
        Help(" ",1,"RECNO")
        Set Filter to
        DbSetOrder(1)
        RetIndex("SE2")
        // Restaura o filtro
        Set Filter To &cSetFilter.
        DbGoTop()
        FErase(cIndex+OrdBagExt())
        Return
     Endif

     nValor   := 0  // valor total dos titulos,mostrado no rodape do browse
     nValCruz := 0
     nQtdTit  := 0  // quantidade de titulos,mostrado no rodape do browse
     aVlCruz  := {} // Valor na Moeda Nacional correspondente a cada parcela
     nOpcA    := 0

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta array com capos a serem mostrados na marcacao de titulos ³
     //³ Utiliza os capos em uso do SE2 mais o E2_SALDO que apesar de   ³
     //³ nao estar em uso deve ser mostrado na tela.                    ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     aAdd(aCampos, {"E2_OK", "", "  ", ""})
     //LGS#20200128 - Adequação para release 12.1.25
     //DbSelectArea("SX3")
     //DbSeek (cAlias)
     //While !EOF() .And. (x3_arquivo == cAlias)
     //      If ( X3USO(x3_usado) .or. X3_CAMPO == "E2_SALDO  ") .and. cNivel >= x3_nivel .and. X3_CONTEXT != "V"
     //         aAdd(aCampos, {X3_CAMPO, "", ( _cAliasSX3 )->( X3_TITULO ), X3_PICTURE})
     //      Endif
     //      DbSkip()
     //Enddo
     DbSelectArea( _cAliasSX3 )
     DbSeek (cAlias)
     While !EOF() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == cAlias )
           If ( X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .or. ( _cAliasSX3 )->( X3_CAMPO ) == "E2_SALDO  ") .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .and. ( _cAliasSX3 )->( X3_CONTEXT ) != "V"
              aAdd( aCampos, { ( _cAliasSX3 )->( X3_CAMPO ), "", ( _cAliasSX3 )->( X3_TITULO ), ( _cAliasSX3 )->( X3_PICTURE ) } )
           Endif
           DbSkip()
     Enddo

     DbSelectArea(cAlias)
     DbSetOrder(nIndex+1)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Marca os titulos ate o valor informado para a fatura 		  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Fa290Marca(cAlias, cMarca, nValorFat)

     nValorF := nValorFat

     DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(STR0020) From 9,0 To 28,80 OF oMainWnd //"Fatura a Pagar"
            @ 1.6 , 00.8	SAY OemToAnsi(STR0021) + cPrefix 					  FONT oDlg1:oFont // "Prefixo: "
            @ 2.4 , 00.8	Say OemToAnsi(STR0022) + cFatura 					  FONT oDlg1:oFont // "N£mero: "
            @ 1.6 , 06		SAY OemToAnsi(STR0023) + Substr(cNat,1,10)		  FONT oDlg1:oFont // "Natureza: "
            @ 2.4 , 06		SAY OemToAnsi(STR0024) + AllTrim(Str(nMoeda,2,0)) FONT oDlg1:oFont // "Moeda: "

            @ 1.6 , 18		Say OemToAnsi(STR0025) FONT oDlg1:oFont //"Valor Fatura"
            @ 1.6 , 25		Say OemToAnsi(STR0026) FONT oDlg1:oFont //"Valor Selecionado"
            @ 1.6 , 34		Say OemToAnsi(STR0027) FONT oDlg1:oFont //"T¡t. Selec."
            @ 2.4 , 18		Say oValorFat VAR nValorF	  Picture "@E 999,999,999.99" FONT oDlg1:oFont
            @ 2.4 , 25		Say oValor	  VAR nValor	  Picture "@E 999,999,999.99" FONT oDlg1:oFont
            @ 2.4 , 34		Say oQtdTit   VAR nQtdTit	  Picture "999"                               FONT oDlg1:oFont

            @ 1.0 , 00.3	To 3.35,17 OF oDlg1
            @ 1.0 , 17		To 3.35,39 OF oDlg1

            oMark 		:=MsSelect():New(cAlias,"E2_OK","!E2_SALDO",aCampos,@lInverte,@cMarca,{45,1,143,315})
            oMark:bMark := { || Fa290Exibe( cMarca, oValor, oQtdTit, oValorFat ) }
            oMark:oBrowse:lhasMark = .t.
            oMark:oBrowse:lCanAllmark := .t.
            oMark:oBrowse:bAllMark := { || FA290Inverte(cMarca,oValor,oQtdTit) }

     ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| nOpca := 1, Iif(Fa290ValOK(), IF(Fa290Soma(), oDlg1:End(), Iif(Fa290Val(oValorFat), nOpca := 0, nOpca := 0)), nOpca := 0)}, {|| nOpca := 2, oDlg1:End()})
     
     DbSelectArea("SE2")

     If nOpca == 1
        If !((ExistBlock("F290CON")))
           cCondicao := Fa290PedCd()				// Monta tela para pedir condicao de pgto
           aVenc     := Condicao(nValor, cCondicao, 0)
        Else
           aVenc := Execblock("F290CON", .f., .f., {nValTot, cCondicao, cMarca})
        Endif
        nDup  := Len(aVenc)
        aCols := GravaDup(nDup, cPrefix, cFatura, nValor, dDatabase, aVenc)
        If !Empty(aCols)
           aVlCruz := {}
           aVlCruz := F280VlCruz(nDup, nValCruz)
           //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
           //³ Mostra tela com os diversos titulos                  ³
           //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           For no := 1 To Len(aCols)
               nValTot += aCols[no][6]
           Next no

           nOpca := 0
           DEFINE MSDIALOG oDlg2 TITLE OemToAnsi(STR0028) From 9,0 To 28,80 OF oMainWnd //"Dados Cont beis Financeiros"
                  @ 1.4 , 00.8	SAY OemToAnsi(STR0029) //"Data Contabiliza‡„o : "
                  @ 1.4 , 07.4	Say dDatCont FONT oDlg2:oFont
                  @ 1.4 , 14		Say OemToAnsi(STR0030) //"Condi‡„o de Pagamento : "
                  @ 1.4 , 22		Say cCondicao
                  @ 1.4 , 27		Say OemToAnsi(STR0031) //"Valor Total:"
                  @ 1.4 , 32		Say oValTot VAR nValTot Picture "@E 9,999,999,999.99" FONT oDlg2:oFont
	
                  oGet := MSGetDados():New(34,5,128,315,3,"Fa290LinOk","Fa290TudOk","",.T.,,,,,,"",,"Fa290AtuVl(.F.)")
           ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{||nOpca:=1,if(oGet:TudoOk(),oDlg2:End(),nOpca := 0)},{||oDlg2:End()})
        Else
           nOpcA := 2
        Endif

        If nOpcA == 1
           STRLCTPAD := ""		// para contabilizar o historico do LP
           nTotAbat  := 0
           DbSelectArea( "SE2" )
           DbSetOrder(nIndex+1)
           DbGotop()
           While !Eof() .and. E2_FILIAL == cFilial .and. E2_FORNECE == cForn .and. Iif(mv_par01 == 1, E2_LOJA == cLoja, .T. )
				 nX := RecNo()
				 DbSkip()
				 nRecSe2 := RecNo()
				 DbGoto(nX)
				 If E2_OK == cMarca
				    cChave   := &(IndexKey())
				    cNumero  := E2_NUM
				    cPrefixo := E2_PREFIXO
				    cParcela := E2_PARCELA
				    *ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				    *³ Soma Titulos Abatimentos								³
				    *ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    DbSetOrder(1)
                    DbSeek(cFilial+cPrefixo+cNumero+cParcela)
                    While !EOF() .And. E2_FILIAL == cFilial .And. E2_PREFIXO == cPrefixo .And. E2_NUM == cNumero .And. E2_PARCELA == cParcela
                          If E2_TIPO $ MVABATIM .And. E2_SALDO > 0 .and. E2_FORNECE == cForn .and. Iif (mv_par01 == 1, E2_LOJA == cLoja, .T. )
                             nTotAbat += E2_SALDO
                             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                             //³ Atualiza a Baixa do Titulo     ³
                             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                             DbSelectArea("SE2")
                             RecLock("SE2",.F.)
                                SE2->E2_BAIXA   := dDataBase
                                SE2->E2_VALLIQ  := SE2->E2_SALDO
                                SE2->E2_SALDO   := 0
                                SE2->E2_MOVIMEN := dDataBase
                                SE2->E2_FATURA  := cFatura
                                SE2->E2_FATPREF := cPrefix
                                SE2->E2_TIPOFAT := cTipo
                                SE2->E2_DTFATUR := dDatabase
                                SE2->E2_FLAGFAT := "S"
                             MsUnlock()
                          EndIf
                          DbSkip()
                    EndDo
                    DbSetOrder(nIndex+1)
                    DbGoto(nX)
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ Atualiza a Baixa do Titulo     ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    If !(E2_TIPO $ MVABATIM) .and. E2_SALDO > 0
                       nJur290  := SE2->E2_SDACRES
                       nDesc290	:= SE2->E2_SDDECRE
                       RecLock("SE2")
                          SE2->E2_BAIXA   := dDataBase
                          SE2->E2_VALLIQ  := SE2->E2_SALDO + SE2->E2_SDACRES - SE2->E2_SDDECRE
                          SE2->E2_JUROS   := nJur290
                          SE2->E2_DESCONT := nDesc290
                          SE2->E2_SALDO   := 0
                          SE2->E2_MOVIMEN := dDataBase
                          SE2->E2_FATURA  := cFatura
                          SE2->E2_FATPREF := cPrefix
                          SE2->E2_TIPOFAT := cTipo
                          SE2->E2_DTFATUR := dDataBase
                          SE2->E2_FLAGFAT := "S"
                          SE2->E2_SDACRES := 0
                          SE2->E2_SDDECRE := 0
                       MsUnlock( )
                       If lF290Baixa
                          // Executa PE apos a baixa do titulo que gerou a fatura.
                          // Pode ser retornado um historico que sera utilizado na
                          // contabilizacao, atraves da variavel STRLCTPAD
                          STRLCTPAD += ExecBlock("F290BAIXA",.F., .F.)
                       Endif
                       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                       //³ Gera movimento da Baixa do Titulo no SE5   ³
                       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                       //³ Localiza a sequencia da baixa ( CP,BA,VL,V2,LJ )             ³
                       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                       aTipoDoc := {"CP", "BA", "VL", "V2"}
                       SE5->(DbSetOrder(2))
                       cSequencia := "00"
                       For i := 1 to Len(aTipoDoc)
                           SE5->(dbSeek(cFilial + aTipoDoc[i] + SE2->E2_PREFIXO + SE2->E2_NUM + ;
                           SE2->E2_PARCELA + SE2->E2_TIPO) )
                           While !SE5->(Eof())                       .And. ;
                                  SE5->E5_FILIAL  == cFilial         .And. ;
                                  SE5->E5_TIPODOC == aTipoDoc[i]     .And. ;
                                  SE5->E5_PREFIXO == SE2->E2_PREFIXO .And. ;
                                  SE5->E5_NUMERO  == SE2->E2_NUM     .And. ;
                                  SE5->E5_PARCELA == SE2->E2_PARCELA .And. ;
                                  SE5->E5_TIPO    == SE2->E2_TIPO
                                  If ( SE5->E5_CLIFOR+SE5->E5_LOJA == SE2->E2_FORNECE+SE2->E2_LOJA .And. SE5->E5_RECPAG == "P" )
                                     If cSequencia < SE5->E5_SEQ
                                        cSequencia := SE5->E5_SEQ
                                     Endif
                                  EndIf
                                  SE5->(DbSkip())
                           EndDo
                       Next I
                       cSequencia := Soma1(cSequencia,2)
                       For nX := 1 To 3
                           //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                           //³ Atualiza a Movimentação Bancária                             ³
                           //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                           If nX == 1
                              cCpoTp := "SE2->E2_VALLIQ"
                              cTpDoc := "BA"
                           Elseif nX == 2
                                  cCpoTp := "nJur290"
                                  cTpDoc := "JR"
                           Elseif nX == 3
                                  cCpoTp := "nDesc290"
                                  cTpDoc := "DC"
                           Endif
                           If &cCpoTp != 0 .or. nX == 1
                              RecLock("SE5", .T.)
                                 SE5->E5_FILIAL  := xFilial("SE5")
                                 SE5->E5_DATA    := dDataBase
                                 SE5->E5_VALOR   := xMoeda(&cCpoTp, SE2->E2_MOEDA, 1, dDataBase)
                                 SE5->E5_NATUREZ := SE2->E2_NATUREZ
                                 SE5->E5_RECPAG  := "P"
                                 SE5->E5_TIPO    := SE2->E2_TIPO
                                 SE5->E5_LA      := "S"
                                 SE5->E5_TIPODOC := cTpDoc
                                 SE5->E5_HISTOR  := STR0056+cFatura  //"Bx.p/Emiss.Fatura "
                                 SE5->E5_PREFIXO := SE2->E2_PREFIXO
                                 SE5->E5_NUMERO  := SE2->E2_NUM
                                 SE5->E5_PARCELA := SE2->E2_PARCELA
                                 SE5->E5_CLIFOR  := SE2->E2_FORNECE
                                 SE5->E5_LOJA    := SE2->E2_LOJA
                                 SE5->E5_DTDIGIT := dDataBase
                                 SE5->E5_MOTBX   := "FAT"
                                 SE5->E5_VLMOED2 := &cCpoTp
                                 SE5->E5_SEQ     := cSequencia
                                 SE5->E5_DTDISPO := dDataBase
                                 SE5->E5_BENEF   := SE2->E2_NOMFOR
                                 If nX == 1  //Baixa Principal
                                    SE5->E5_VLJUROS := nJur290
                                    SE5->E5_VLDESCO := nDesc290
                                 Endif
                           Endif
                       Next
                    Endif
                 Endif
                 DbSelectArea("SE2")
                 DbGoto(nRecSe2)
           Enddo
           DbSelectArea("SA2")
           DbSeek(cFilial+cForn+Iif(mv_par01==1,cLoja,cLojaP))
           nValTotal := 0
           For nW := 1 To Len(aCols)
               If !aCols[nW][8]  // .F. == Ativo  .T. == Deletado
                  cPrefix  := aCols[nW][1]
                  cParcela := aCols[nW][3]
                  cTipo    := aCols[nW][4]
                  cVencmto := aCols[nW][5]
                  nValDup  := aCols[nW][6]
                  nValCruz := xMoeda(aCols[nW][6], nMoeda, 1)
                  cBanco   := aCols[nW][7]
                  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                  //³ Implantacao da Fatura          ³
                  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                  RecLock(cAliasSE2, .T.)
                     Replace E2_FILIAL  With xFilial("SE2")
                     Replace E2_NUM     With cFatura
                     Replace E2_PARCELA With cParcela
                     Replace E2_PREFIXO With cPrefix
                     Replace E2_NATUREZ With cNat
                     Replace E2_VENCTO  With cVencmto
                     Replace E2_VENCREA With DataValida(E2_VENCTO, .T.)
                     Replace E2_EMISSAO With dDatabase
                     Replace E2_EMIS1   With dDatabase
                     Replace E2_TIPO    With cTipo
                     Replace E2_FORNECE With cFornP
                     Replace E2_LOJA    With Iif(mv_par01 == 1, cLoja, cLojaP)
                     Replace E2_VALOR   With nValDup
                     Replace E2_SALDO   With nValDup
                     Replace E2_MOEDA   With nMoeda
                     Replace E2_PORTADO With cBanco
                     Replace E2_FATURA  With "NOTFAT"
                     Replace E2_NOMFOR  With SA2->A2_NREDUZ
                     Replace E2_VLCRUZ  With xMoeda(nValDup, nMoeda, 1) //nValCruz
                     Replace E2_ORIGEM  With "FINA290"
                     lPadrao:=VerPadrao(cPadrao)
                     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     //³ Atualiza Flag de Lancamento contabil       ³
                     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                     If lPadrao
                        Replace E2_LA With "S"
                     End
                  MsUnlock()
                  If _lFA290 //LGS#20200130 - Adequação do release 12.1.25
                     ExecBlock("FA290", .f., .f.)
                  Endif
                  nValTotal += xMoeda(nValDup,nMoeda,1)  // nValCruz
                  If lPadrao
                     If !lHead
                        nHdlPrv := HeadProva(cLote, "FINA290", SubStr(cUsername, 1, 6), @cArquivo)
                        lHead   := .T.
                     Endif
                     nTotal += DetProva(nHdlPrv, cPadrao, "FINA290", cLote)
                  Endif
                  DbSelectArea("SE2")
               Endif
           Next nW
           If nTotal > 0
              DbSelectArea("SE2")
              nRecSe2 := Recno()
              SE2->(DbGoBottom())
              SE2->(DbSkip())
              VALOR   := nValTotal
              nTotal  += DetProva(nHdlPrv, cPadrao, "FINA290", cLote)
              RodaProva(nHdlPrv, nTotal)
              //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
              //³ Envia para Lancamento Contabil                      ³
              //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              cA100Incl(cArquivo, nHdlPrv, 3, cLote, .T., .F.)
              VALOR := 0
              DbSelectArea("SE2")
              SE2->(DbGoTo(nRecSe2))
           Endif
           //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
           //³ Grava no SX6 o numero da ultima fatura gerada.                     ³
           //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           //LGS#20200130 - Adequação do release 12.1.25
           GetMv("MV_NUMFATP")
           //RecLock("SX6", .F.)
           //   SX6->X6_CONTEUD := cFatura
           //MsUnlock()
           PutMv("MV_NUMFATP", cFatura )
        Endif
     Endif
     cFatura   := CRIAVAR("E2_FATURA")
     cForn     := Space(6)
     cNat      := Space(10)
     cPrefix   := CRIAVAR("E2_PREFIXO", .T.)
     cLoja     := Space(2)
     dDataDe   := dDatabase
     dDataAte  := dDatabase
     nValorFat := 0
     aVlCruz   := {}

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Recupera a Integridade dos dados                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DbSelectArea("SE2")
     RetIndex( "SE2" )
     // Restaura o filtro
     Set Filter To &cSetFilter.
     If !Empty(cIndex)
        fErase(cIndex+OrdBagExt())
        cIndex := ""
     Endif
Return (.T.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ fa290num ³ Autor ³ Paulo Boschetti	  ³ Data ³ 27/07/93   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se ja' existe numero do titulo.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa290num()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA290													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fa290num()
       Local cAlias   := Alias()
       Local nOrdemE2 := IndexOrd()
       lFocus := .F.
       If Empty(cTipo)
          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //³ Retorno .T. para que possa focar o campo do numero da³
          //³ fatura para altera‡Æo e posterior valida‡Æo. A valida³
          //³ ‡Æo neste caso ‚ feita somente no Fornecedor e ao con³
          //³ firmar a opera‡Æo da fatura.                         ³
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          Help(" ", 1, "TIPOFAT")
          oTipo:SetFocus()
          lFocus := .T.
       Endif

       If !lFocus .and. Empty(cNat)
          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //³ Retorno .T. para que possa focar o campo de natureza ³
          //³ para altera‡Æo e posterior valida‡Æo. A validacao    ³
          //³ neste caso ‚ feita somente no Fornecedor e ao con    ³
          //³ firmar a opera‡Æo da fatura.                         ³
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          Help(" ", 1, "A290NAT")
          oNat:SetFocus()
          lFocus := .T.
       Endif

       If !lFocus
          DbSelectArea("SE2")
          DbSetOrder(1)
          If DbSeek(xFilial("SE2")+cPrefix+cFatura)
             While !Eof() .and. SE2->E2_FILIAL == xFilial("SE2") .and. cPrefix+cFatura == SE2->(E2_PREFIXO+E2_NUM)
                   If SE2->E2_TIPO == cTipo .and. SE2->(E2_FORNECE+E2_LOJA) == cForn+IIF(mv_par01 == 1, cLoja, cLojaP)
                      Help(" ", 1, "A290EXIST")
                      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                      //³ Retorno .T. para que possa focar o campo do numero da³
                      //³ fatura para altera‡Æo e posterior valida‡Æo. A valida³
                      //³ ‡Æo neste caso ‚ feita somente no Fornecedor e ao con³
                      //³ firmar a opera‡Æo da fatura.                         ³
                      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                      oFatura:SetFocus()
                      lFocus := .T.
                      Exit
                   Else
                      DbSkip()
                   Endif
             Enddo
          Endif
       Endif
       DbSelectArea(cAlias)
       DbSetOrder(nOrdemE2)
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FA290For ³ Autor ³ Paulo Boschetti	  ³ Data ³ 27/07/93   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica validade do Fornecedor							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa290For()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA290													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fa290For( cFornecedor, cLoja )
       Local cAlias := Alias()
       If Empty(cFornecedor)
          Return .F.
       Endif
       cAlias := Alias()
       DbSelectArea("SA2")
       DbSetOrder(1)
       cLoja := Iif(cLoja == Nil, "", cLoja)
       If !(DbSeek(xFilial("SA2")+cFornecedor+cLoja))
          Return .f.
       End
       DbSelectArea(cAlias)
Return ( .T. )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FA290Ok	³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 07/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe mensagem de OK para dados digitados da fatura		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA290OK()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA290													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fa290Ok()
       Return (MsgYesNo(OemToAnsi(STR0045), OemToAnsi(STR0046))) //"Confirma Dados?"###"Aten‡„o"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FA290OkCan³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 07/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe mensagem de OK para confirmacao do cancelamento 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA290OKCan()											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA290													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Static Function Fa290OkCan()
       Return (MsgYesNo(OemToAnsi(STR0047), OemToAnsi(STR0048))) //"Confirma Cancelamento?"###"Aten‡„o"
*/
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa290Marca³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 21/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Trata o valor	para marcar e desmarcar item			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa290Marca(ExpN1,ExpD1,ExpD2) 						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA290													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fa290Marca(cAlias, cMarca, nLimite)
       Local nRec
       Local cAliasAnt := Alias()
       Local lMarkTit  := .t.
       Local lF290Tit  := ExistBlock("F290TIT")

       DbSelectArea(cAlias)
       nRec := Recno()
       While !Eof()
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ PONTO DE ENTRADA F290TIT                                       ³
             //³ Verifica se titulo pode ser marcado para compor a Fatura,      ³
             //³ caso tenha sido alterada a marca‡Æo do titulo, ExecBlock       ³
             //³ dever  retornar .F., para nÆo haver altera‡Æo dos acumuladores ³
             //³ de valores e numero de titulos.                                ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If lF290Tit
                lMarkTit := ExecBlock("F290TIT",.F.,.F.)
             Endif
             If lMarkTit
                If nValor <= nLimite .Or. Empty(nLimite)
                   RecLock("SE2")
                      SE2->E2_OK := cMarca
                   MsUnlock()
                   If E2_TIPO $ MVABATIM+"/"+MV_CPNEG
                      nValor   -= E2_SALDO+E2_SDACRES-E2_SDDECRE
                      nValCruz -= E2_VLCRUZ+Round(NoRound(xMoeda(E2_SDACRES-E2_SDDECRE, E2_MOEDA, 1, E2_EMISSAO, 3), 3), 2)
                      nQtdTit++
                   Else
                      nValor += E2_SALDO+E2_SDACRES-E2_SDDECRE
                      nValCruz += E2_VLCRUZ+Round(NoRound(xMoeda(E2_SDACRES-E2_SDDECRE,E2_MOEDA,1,E2_EMISSAO,3),3),2)
                      nQtdTit++
                   Endif
                Else
                   RecLock("SE2")
                      SE2->E2_OK := "  "
                   SE2->(MsUnlock())
                EndIf
             EndIf
             DbSkip()
       EndDo
       DbGoto(nRec)
       DbSelectArea(cAliasAnt)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FA290Invert³ Autor ³ Wagner Xavier		 ³ Data ³ 12/05/97  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca / Desmarca	todos os titulos					        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fina290													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fa290Inverte(cMarca, oValor, oQtdTit)
       Local nReg     := SE2->(Recno())
       //Local cAlias   := Alias()
       Local lMarkTit := .t.
       Local lF290Tit := ExistBlock("F290TIT")
       DbSelectArea("SE2")
       DbSeek(cFilial)
       While !Eof() .and. cFilial == E2_FILIAL
             RecLock("SE2")
                If E2_OK == cMarca
                   SE2->E2_OK := "  "
                   If E2_TIPO$ MVABATIM+"/"+MV_CPNEG
                      nValor += Moeda(E2_SALDO+E2_SDACRES-E2_SDDECRE, nMoeda, "P")
                   Else
                      nValor -= Moeda(E2_SALDO+E2_SDACRES-E2_SDDECRE, nMoeda, "P")
                   Endif
                   nQtdTit--
                Else
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ PONTO DE ENTRADA F290TIT                                       ³
                //³ Verifica se titulo pode ser marcado para compor a Fatura,      ³
                //³ caso tenha sido alterada a marca‡Æo do titulo, ExecBlock       ³
                //³ dever  retornar .F., para nÆo haver altera‡Æo dos acumuladores ³
                //³ de valores e numero de titulos.                                ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If lF290Tit
                   lMarkTit := ExecBlock("F290TIT",.F.,.F.)
                Endif
                If lMarkTit
                   SE2->E2_OK := cMarca
                   If E2_TIPO$ MVABATIM+"/"+MV_CPNEG
                      nValor -= Moeda(E2_SALDO+E2_SDACRES-E2_SDDECRE,nMoeda,"P")
                   Else
                      nValor += Moeda(E2_SALDO+E2_SDACRES-E2_SDDECRE,nMoeda,"P")
                   Endif
                   nQtdTit++
                Endif
             Endif
             DbSkip()
       Enddo
       SE2->(dbGoto(nReg))
       oValor:Refresh()
       oQtdTit:Refresh()
       oMark:oBrowse:Refresh(.t.)
Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ fa290nat ³ Autor ³ Paulo Boschetti	  ³ Data ³ 27/07/93   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica validade da natureza.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa290nat()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA290													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA290NAT()
       Local cAlias := Alias()
       Local lRet   := .T.

       DbSelectArea("SED")
       If !(DbSeek(xFilial("SED")+cNat))
          Help(" ",1,"A290NAT")
          lRet := .F.
       Endif
       DbSelectArea(cAlias)
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FA290Exibe³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 07/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe Totais de titulos selecionados						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA290Exibe()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA290													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fa290Exibe( cMarca, oValor, oQtdTit, oValorFat )
       //Local nElem
       Local lMarkTit := .t.
	
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ PONTO DE ENTRADA F290TIT                                       ³
       //³ Verifica se titulo pode ser marcado para compor a Fatura,      ³
       //³ caso tenha sido alterada a marca‡Æo do titulo, ExecBlock       ³
       //³ dever  retornar .F., para nÆo haver altera‡Æo dos acumuladores ³
       //³ de valores e numero de titulos.                                ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If (ExistBlock("F290TIT"))
          lMarkTit := ExecBlock("F290TIT",.F.,.F.)
       Endif
       If lMarkTit
          If SE2->E2_OK == cMarca
             If E2_TIPO$ MVABATIM+"/"+MV_CPNEG
                nValor   -= E2_SALDO+E2_SDACRES-E2_SDDECRE
                nValCruz -= E2_VLCRUZ+Round(NoRound(xMoeda(E2_SDACRES-E2_SDDECRE, E2_MOEDA, 1, E2_EMISSAO, 3), 3), 2)
                nQtdTit++
             Else
                nValor   += E2_SALDO+E2_SDACRES-E2_SDDECRE
                nValCruz += E2_VLCRUZ+Round(NoRound(xMoeda(E2_SDACRES-E2_SDDECRE, E2_MOEDA, 1, E2_EMISSAO, 3), 3), 2)
                nQtdTit++
             Endif
          Else
             If E2_TIPO$ MVABATIM+"/"+MV_CPNEG
      			nValor   += E2_SALDO+E2_SDACRES-E2_SDDECRE
                nValCruz += E2_VLCRUZ+Round(NoRound(xMoeda(E2_SDACRES-E2_SDDECRE, E2_MOEDA, 1, E2_EMISSAO, 3), 3), 2)
                nQtdTit--
             Else
                nValor   -= E2_SALDO+E2_SDACRES-E2_SDDECRE
                nValCruz -= E2_VLCRUZ+Round(NoRound(xMoeda(E2_SDACRES-E2_SDDECRE, E2_MOEDA, 1, E2_EMISSAO, 3), 3), 2)
                nQtdTit--
             Endif
          Endif
       Endif
       nQtdTit:= Iif(nQtdTit<0,0,nQtdTit)
       oValor:Refresh()
       oQtdTit:Refresh()
Return
