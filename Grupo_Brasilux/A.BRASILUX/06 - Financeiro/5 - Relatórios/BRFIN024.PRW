#include "protheus.ch"
#include 'ap5mail.ch'
#Translate MSGBOX( => IW_MsgBox(
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ BRFIN024 ³ Autor ³ Luís Gustavo de Souza ³ Data ³ 11/11/03 ³±±
±±Cleber (29/08/08) => Preenchimento de mvpar32 para excluir tipos        ³±±
±±'NCC','AB-','JP','RA'. Filtrar Lucros e Perdas						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posição dos Titulos a Receber por Representante - e-mail   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFIN024()
     //Local cDesc1 :=OemToAnsi("Imprime a posi‡„o dos titulos a receber relativo a data ba-")
     //Local cDesc2 :=OemToAnsi("se do sistema.")
     //Local cDesc3 :=""
     Local wnrel
     Local cString:="SE1"
     Local nRegEmp:=SM0->(RecNo())
     Local dOldDtBase := dDataBase

     Private titulo  :=""
     //Private cabec1  :=""
     //Private cabec2  :=""

     Private aLinha  :={}
     Private aReturn :={ OemToAnsi("Zebrado"), 1,OemToAnsi("Administracao"), 1, 2, 1, "",1 }
     Private cPerg	 :="BRF022"
     Private nJuros  :=0
     Private nLastKey:=0
     Private nomeprog:="FINR130"
     Private tamanho :="G"  
     Private cArqTxt1 := ""
  if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
     u_zcfga01( 'BRFIN024' ) //LGS#2021202 - Gravação de log de utilização da rotina
     //ValPerg() //LGS#20200130 - Adequação para release 12.1.25 e posteriores
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Defini‡„o dos cabe‡alhos ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     titulo := OemToAnsi("Posicao dos Titulos a Receber")
     cabec1 := OemToAnsi("Codigo Nome do Cliente      Prf-Numero         TP  Natureza    Data de  Vencto   Vencto  Banco  Valor Original |        Titulos Vencidos          | Titulos a Vencer | Num        Vlr.juros ou  Dias   Historico     ")
     cabec2 := OemToAnsi("                            Parcela                            Emissao  Titulo    Real                         |  Valor Nominal   Valor Corrigido |   Valor Nominal  | Banco       permanencia  Atraso               ")
 /*    If cNumEmp $ "0101.0104.0301.0501"
     Else
        MsgBox("Empresa/Filial: "+cNumEmp+" não autorizadas a emitir esse relatório","Atenção","STOP")
        Return
     Endif*/
     //Nao retire esta chamada. Verifique antes !!!
     //Ela é necessaria para o correto funcionamento da pergunte 36 (Data Base)
     //PutDtBase() - Não mais necessário - Customização BRASILUX TINTAS TÉCNICAS
     If !(pergunte("BRF022",.T.))
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Variaveis utilizadas para parametros												³
     //³ mv_par01		 // Do Cliente 													    ³
     //³ mv_par02		 // Ate o Cliente													³
     //³ mv_par03		 // Do Prefixo														³
     //³ mv_par04		 // Ate o prefixo 												    ³
     //³ mv_par05		 // Do Titulo													    ³
     //³ mv_par06		 // Ate o Titulo													³
     //³ mv_par07		 // Do Banco														³
     //³ mv_par08		 // Ate o Banco													    ³
     //³ mv_par09		 // Do Vencimento 												    ³
     //³ mv_par10		 // Ate o Vencimento												³
     //³ mv_par11		 // Da Natureza														³
     //³ mv_par12		 // Ate a Natureza													³
     //³ mv_par13		 // Da Emissao														³
     //³ mv_par14		 // Ate a Emissao													³
     //³ mv_par15		 // Qual Moeda														³
     //³ mv_par16		 // Imprime provisorios												³
     //³ mv_par17		 // Reajuste pelo vecto												³
     //³ mv_par18		 // Impr Tit em Descont												³
     //³ mv_par19		 // Relatorio Anal/Sint												³
     //³ mv_par20		 // Consid Data Base?  												³
     //³ mv_par21		 // Consid Filiais  ?  												³
     //³ mv_par22		 // da filial													    ³
     //³ mv_par23		 // a flial 												        ³
     //³ mv_par24		 // Da loja  														³
     //³ mv_par25		 // Ate a loja														³
     //³ mv_par26		 // Consid Adiantam.?												³
     //³ mv_par27		 // Da data contab. ?												³
     //³ mv_par28		 // Ate data contab.?												³
     //³ mv_par29		 // Imprime Nome    ?												³
     //³ mv_par30		 // Outras Moedas   ?												³
     //³ mv_par31       // Imprimir os Tipos												³
     //³ mv_par32       // Nao Imprimir Tipos												³
     //³ mv_par33       // Abatimentos  - Lista/Nao Lista/Despreza	        				³
     //³ mv_par34       // Consid. Fluxo Caixa												³
     //³ mv_par35       // Salta pagina Cliente											    ³
     //³ mv_par36       // Despreza abatimentos                                             ³
     //³ mv_par37       // Data Base													    ³
     //³ mv_par38       // Compoe Saldo por: Data da Baixa ou Data de Credito	            ³
     //³ mv_par39       // Filtra Lucros e Perdas                                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If Empty(MV_PAR01)
        mvpar01 := "      "
        mvpar02 := "ZZZZZZ"
     Else
        mvpar01 := MV_PAR01
        mvpar02 := MV_PAR01
     Endif
     mvpar03 := MV_PAR03
     mvpar04 := MV_PAR04
     mvpar05 := "      "
     mvpar06 := "ZZZZZZ"
     mvpar07 := ""
     mvpar08 := "ZZZ"
     mvpar09 := MV_PAR05
     mvpar10 := MV_PAR06
     mvpar11 := ""
     mvpar12 := "ZZZZZZZZZZ"
     mvpar13 := MV_PAR07
     mvpar14 := MV_PAR08
     mvpar15 := 1
     mvpar16 := 1
     mvpar17 := 2
     mvpar18 := 1
     mvpar19 := 1
     mvpar20 := 2
     mvpar21 := 2
     mvpar22 := ""
     mvpar23 := "ZZ"
     mvpar24 := ""
     mvpar25 := "ZZ"
     mvpar26 := 1
     mvpar27 := CTOD("01/01/2000")
     mvpar28 := CTOD("31/12/2049")
     mvpar29 := 2
     mvpar30 := 1
     mvpar31 := ""
     mvpar32 := "('NCC','AB-','JP','RA')"
     mvpar33 := 1
     mvpar34 := 2
     mvpar35 := 2
     mvpar36 := DTOC(dDataBase)
     mvpar37 := 1
     mvpar38 := 1
     mvpar39 := 2
     If Empty(MV_PAR02)
        mvpar40 := "      "
        mvpar41 := "ZZZZZZ"
     Else
        mvpar40 := MV_PAR02
        mvpar41 := MV_PAR02
     Endif
     mvpar42 := MV_PAR09
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a fun‡„o SETPRINT ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     #IFDEF TOP
            IF TcSrvType() == "AS/400" .and. Select("__SE1") == 0
               ChkFile("SE1",.f.,"__SE1")
            Endif
     #ENDIF

     wnrel:="FINR130"            //Nome Default do relatorio em Disco
     aOrd :={OemToAnsi("Por Cliente"),;
             OemToAnsi("Por Prefixo/Numero"),;
             OemToAnsi("Por Banco"),;
             OemToAnsi("Por Venc/Cli"),;
             OemToAnsi("Por Natureza"),;
             OemToAnsi("Por Emissao"),;
             OemToAnsi("Por Ven\Bco"),;
             OemToAnsi("Por Cod.Cli."),;
             OemToAnsi("Banco/Situacao"),;
             OemToAnsi("Por Numero/Tipo/Prefixo"),;
             OemToAnsi("Por Vendedor/Cli") }

     //wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

     If nLastKey == 27
        Return
     Endif

     //SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     RptStatus({|lEnd| FA130Imp(@lEnd,wnRel,cString)},titulo)  // Chamada do Relatorio

     SM0->(dbGoTo(nRegEmp))
     cFilAnt := SM0->M0_CODFIL

     //Acerta a database de acordo com a database real do sistema
     If mvpar20 == 1    // Considera Data Base
        dDataBase := dOldDtBase
     Endif	

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FA130Imp ³ Autor ³ Paulo Boschetti		  ³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime relat¢rio dos T¡tulos a Receber						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FA130Imp(lEnd,WnRel,cString)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd	  - A‡Æo do Codeblock				    					  ³±±
±±³			 ³ wnRel   - T¡tulo do relat¢rio 									  ³±±
±±³			 ³ cString - Mensagem													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FA130Imp(lEnd,WnRel,cString)
       Local CbCont
       Local CbTxt
       //Local limite     := 220
       Local nOrdem
       Local lContinua  := .T.
       Local cCond1,cCond2,cCarAnt
       Local nTit0      := 0
       Local nTitCli0   := 0
       Local nTit1      := 0
       Local nTitCli1   := 0
       Local nTit2      := 0
       Local nTit3      := 0
       Local nTitCli3   := 0
       Local nTit4      := 0
       Local nTit5      := 0
       Local nTotJ      := 0
       Local nTot0      := 0
       Local nTot1      := 0
       Local nTot2      := 0
       Local nTot3      := 0
       Local nTot4      := 0
       Local nTotTit    := 0
       Local nTotJur    := 0
       Local nTotFil0   := 0
       Local nTotFil1   := 0
       Local nTotFil2   := 0
       Local nTotFil3   := 0
       Local nTotFil4   := 0
       Local nTotFilTit := 0
       Local nTotFilJ   := 0
       //Local aCampos    := {}
       //Local aTam       := {}
       Local nAtraso    := 0
       Local nTotAbat   := 0
       Local nSaldo     := 0
       Local dDataReaj
       Local dDataAnt   := dDataBase
       Local lQuebra
       Local nMesTit0   := 0
       Local nMesTit1   := 0
       Local nMesTit2   := 0
       Local nMesTit3   := 0
       Local nMesTit4   := 0
       Local nMesTTit   := 0
       Local nMesTitj   := 0
       Local cIndexSe1
       Local cChaveSe1
       //Local nIndexSE1
       Local dDtContab
       Local cTipos     := ""
       Local aStru      := SE1->(dbStruct()), ni
       Local nTotsRec   := SE1->(RecCount())
       Local aTamCli    := TAMSX3("E1_CLIENTE")
       // variavel  abaixo criada p/pegar o nr de casas decimais da moeda
       Local ndecs      := Msdecimais(mvpar15)
       Local nAbatim    := 0
       Local cLin       := ""
       Local cCpo       := ""
       Local cEOL       := CHR(13)+CHR(10)
       Private nRegSM0  := SM0->(Recno())
       Private nAtuSM0  := SM0->(Recno())
       PRIVATE dBaixa   := dDataBase
       PRIVATE cFilDe,cFilAte

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Ponto de entrada para Filtrar os tipos sem entrar na tela do ³
       //³ FINRTIPOS(), localizacao Argentina.                          ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄJose Lucas, Localiza‡”es ArgentinaÄÙ
       IF EXISTBLOCK("F130FILT")
          cTipos	:=	EXECBLOCK("F130FILT",.f.,.f.)
       ENDIF

       nOrdem := 11
       cMoeda := Str(mvpar15,1)

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Vari veis utilizadas para Impress„o do Cabe‡alho e Rodap‚ ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       cbtxt 	:= OemtoAnsi("* indica titulo provisorio, P Indica Saldo Parcial")
       cbcont	:= 1
       li 		:= 80
       m_pag 	:= 1

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ POR MAIS ESTRANHO QUE PARE€A, ESTA FUNCAO DEVE SER CHAMADA AQUI! ³
       //³                                                                  ³
       //³ A fun‡„o SomaAbat reabre o SE1 com outro nome pela ChkFile para  ³
       //³ efeito de performance. Se o alias auxiliar para a SumAbat() n„o  ³
       //³ estiver aberto antes da IndRegua, ocorre Erro de & na ChkFile,   ³
       //³ pois o Filtro do SE1 uptrapassa 255 Caracteres.                  ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       SomaAbat("","","","R")

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Atribui valores as variaveis ref a filiais                ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If mvpar21 == 2
          cFilDe  := cFilAnt
          cFilAte := cFilAnt
       ELSE
          cFilDe := mvpar22	// Todas as filiais
          cFilAte:= mvpar23
       Endif

       //Acerta a database de acordo com o parametro
       If mvpar20 == 1    // Considera Data Base
          dDataBase := mvpar36
       Endif	

       dbSelectArea("SM0")
       dbSeek(cEmpAnt+cFilDe,.T.)

       nRegSM0 := SM0->(Recno())
       nAtuSM0 := SM0->(Recno())

       While !Eof() .and. M0_CODIGO == cEmpAnt .and. M0_CODFIL <= cFilAte

             dbSelectArea("SE1")
             cFilAnt := SM0->M0_CODFIL
             Set Softseek On

             If mvpar19 == 1
                titulo := titulo + OemToAnsi(" - Analitico")
             Else
                titulo := titulo + OemToAnsi(" - Sintetico")
                cabec1 := OemToAnsi("                                                                                                               |        Titulos Vencidos          | Titulos a Vencer |            Vlr.juros ou             (Vencidos+Vencer)") 
                cabec2 := OemToAnsi("                                                                                                               |  Valor Nominal   Valor Corrigido |   Valor Nominal  |             permanencia                              ")
             EndIf

             #IFDEF TOP
                    if TcSrvType() != "AS/400"
                       cQuery := "SELECT *, 0 AS E1_TXMOEDA "
                       cQuery += "  FROM "+	RetSqlName("SE1")
                       cQuery += " WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
                       cQuery += "   AND D_E_L_E_T_ <> '*' "
                    endif
             #ENDIF

             IF nOrdem = 1
                //cChaveSe1 := "E1_FILIAL+E1_NOMCLI+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
                //#IFDEF TOP
                //       if TcSrvType() == "AS/400"
                //          cIndexSe1 := CriaTrab(nil,.f.)
                //          IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi("Selecionando Registros..."))
                //          nIndexSE1 := RetIndex("SE1")
                //          dbSetOrder(nIndexSe1+1)
                //          dbSeek(xFilial("SE1"))
                //       else
                //          cOrder := SqlOrder(cChaveSe1)
                //       endif
                //#ELSE
                //    cIndexSe1 := CriaTrab(nil,.f.)
                //    IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi("Selecionando Registros..."))
                //    nIndexSE1 := RetIndex("SE1")
                //    dbSetIndex(cIndexSe1+OrdBagExt())
                //    dbSetOrder(nIndexSe1+1)
                //    dbSeek(xFilial("SE1"))
                //#ENDIF
                //cCond1 := "E1_CLIENTE <= mvpar02"
                //cCond2 := "E1_CLIENTE + E1_LOJA"
                //titulo := titulo + OemToAnsi(" - Por Cliente")

             Elseif nOrdem = 2
                    //SE1->(dbSetOrder(1))
                    //#IFNDEF TOP
                    //        dbSeek(cFilial+mvpar03+mvpar05)
                    //#ELSE
                    //    if TcSrvType() == "AS/400"
                    //       dbSeek(cFilial+mvpar03+mvpar05)
                    //    else
                    //       cOrder := SqlOrder(IndexKey())
                    //    endif
                    //#ENDIF
                    //cCond1 := "E1_NUM <= mvpar06"
                    //cCond2 := "E1_NUM"
                    //titulo := titulo + OemToAnsi(" - Por Numero")
             Elseif nOrdem = 3
                    //SE1->(dbSetOrder(4))
                    //#IFNDEF TOP
                    //dbSeek(cFilial+mvpar07)
                    //#ELSE
                    //    if TcSrvType() == "AS/400"
                    //       dbSeek(cFilial+mvpar07)
                    //    else
                    //       cOrder := SqlOrder(IndexKey())
                    //    endif
                    //#ENDIF
                    //cCond1 := "E1_PORTADO <= mvpar08"
                    //cCond2 := "E1_PORTADO"
                    //titulo := titulo + OemToAnsi(" - Por Banco")
             Elseif nOrdem = 4
                    //SE1->(dbSetOrder(7))
                    //#IFNDEF TOP
                    //        dbSeek(cFilial+DTOS(mvpar09))
                    //#ELSE
                    //    if TcSrvType() == "AS/400"
                    //       dbSeek(cFilial+DTOS(mvpar09))
                    //    else
                    //       cOrder := SqlOrder(IndexKey())
                    //    endif
                    //#ENDIF
                    //cCond1 := "E1_VENCREA <= mvpar10"
                    //cCond2 := "E1_VENCREA"
                    //titulo := titulo + OemToAnsi(" - Por Data de Vencimento")
             Elseif nOrdem = 5
                    //SE1->(dbSetOrder(3))
                    //#IFNDEF TOP
                    //        dbSeek(cFilial+mvpar11)
                    //#ELSE
                    //    if TcSrvType() == "AS/400"
                    //       dbSeek(cFilial+mvpar11)
                    //    else
                    //      cOrder := SqlOrder(IndexKey())
                    //    endif
                    //#ENDIF
                    //cCond1 := "E1_NATUREZ <= mvpar12"
                    //cCond2 := "E1_NATUREZ"
                    //titulo := titulo + OemToAnsi(" - Por Natureza")
             Elseif nOrdem = 6
                    //SE1->(dbSetOrder(6))
                    //#IFNDEF TOP
                    //        dbSeek( cFilial+DTOS(mvpar13))
                    //#ELSE
                    //    if TcSrvType() == "AS/400"
                    //       dbSeek( cFilial+DTOS(mvpar13))
                    //    else
                    //       cOrder := SqlOrder(IndexKey())
                    //    endif
                    //#ENDIF
                    //cCond1 := "E1_EMISSAO <= mvpar14"
                    //cCond2 := "E1_EMISSAO"
                    //titulo := titulo + OemToAnsi(" - Por Emissao")
             Elseif nOrdem == 7
                    //cChaveSe1 := "E1_FILIAL+DTOS(E1_VENCREA)+E1_PORTADO+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
                    //#IFNDEF TOP
                    //        cIndexSe1 := CriaTrab(nil,.f.)
                    //        IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi("Selecionando Registros..."))
                    //        nIndexSE1 := RetIndex("SE1")
                    //        dbSetIndex(cIndexSe1+OrdBagExt())
                    //        dbSetOrder(nIndexSe1+1)
                    //        dbSeek(xFilial("SE1"))
                    //#ELSE
                    //    if TcSrvType() == "AS/400"
                    //       cIndexSe1 := CriaTrab(nil,.f.)
                    //       IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi("Selecionando Registros..."))
                    //       nIndexSE1 := RetIndex("SE1")
                    //       dbSetOrder(nIndexSe1+1)
                    //       dbSeek(xFilial("SE1"))
                    //    else
                    //       cOrder := SqlOrder(cChaveSe1)
                    //    endif
                    //#ENDIF
                    //cCond1 := "E1_VENCREA <= mvpar10"
                    //cCond2 := "DtoS(E1_VENCREA)+E1_PORTADO"
                    //titulo := titulo + OemToAnsi(" - Por Vencto/Banco")
             Elseif nOrdem = 8
                    //SE1->(dbSetOrder(2))
                    //#IFNDEF TOP
                    //        dbSeek(cFilial+mvpar01,.T.)
                    //#ELSE
                    //    if TcSrvType() == "AS/400"
                    //       dbSeek(cFilial+mvpar01,.T.)
                    //    else
                    //       cOrder := SqlOrder(IndexKey())
                    //    endif
                    //#ENDIF
                    //cCond1 := "E1_CLIENTE <= mvpar02"
                    //cCond2 := "E1_CLIENTE"
                    //titulo := titulo + OemToAnsi(" - Por Cod.Cliente")
             Elseif nOrdem = 9
                    //cChave := "E1_FILIAL+E1_PORTADO+E1_SITUACA+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
                    //#IFNDEF TOP
                    //        dbSelectArea("SE1")
                    //        cIndex := CriaTrab(nil,.f.)
                    //        IndRegua("SE1",cIndex,cChave,,fr130IndR(),OemToAnsi("Selecionando Registros..."))
                    //        nIndex := RetIndex("SE1")
                    //        dbSetIndex(cIndex+OrdBagExt())
                    //        dbSetOrder(nIndex+1)
                    //        dbSeek(xFilial("SE1"))
                    //#ELSE
                    //    if TcSrvType() == "AS/400"
                    //       dbSelectArea("SE1")
                    //       cIndex := CriaTrab(nil,.f.)
                    //       IndRegua("SE1",cIndex,cChave,,fr130IndR(),OemToAnsi("Selecionando Registros..."))
                    //       nIndex := RetIndex("SE1")
                    //       dbSetOrder(nIndex+1)
                    //       dbSeek(xFilial("SE1"))
                    //    else
                    //       cOrder := SqlOrder(cChave)
                    //    endif
                    //#ENDIF
                    //cCond1 := "E1_PORTADO <= mvpar08"
                    //cCond2 := "E1_PORTADO+E1_SITUACA"
                    //titulo := titulo + OemToAnsi(" - Por Banco e Situacao")
             ElseIf nOrdem == 10
                    //cChave := "E1_FILIAL+E1_NUM+E1_TIPO+E1_PREFIXO+E1_PARCELA"
                    //#IFNDEF TOP
                    //        dbSelectArea("SE1")
                    //        cIndex := CriaTrab(nil,.f.)
                    //        IndRegua("SE1",cIndex,cChave,,,OemToAnsi("Selecionando Registros..."))
                    //        nIndex := RetIndex("SE1")
                    //        dbSetIndex(cIndex+OrdBagExt())
                    //        dbSetOrder(nIndex+1)
                    //        dbSeek(xFilial("SE1")+mvpar05)
                    //#ELSE
                    //    if TcSrvType() == "AS/400"
                    //       dbSelectArea("SE1")
                    //       cIndex := CriaTrab(nil,.f.)
                    //       IndRegua("SE1",cIndex,cChave,,,OemToAnsi("Selecionando Registros..."))
                    //       nIndex := RetIndex("SE1")
                    //       dbSetOrder(nIndex+1)
                    //       dbSeek(xFilial("SE1")+mvpar05)
                    //    else
                    //       cOrder := SqlOrder(cChave)
                    //   endif
                    //#ENDIF
                    //cCond1 := "E1_NUM <= mvpar06"
                    //cCond2 := "E1_NUM"
                    //titulo := titulo + OemToAnsi(" - Numero/Prefixo")
             elseif nOrdem = 11
                    cChaveSe1 := "E1_FILIAL+E1_VEND1+E1_NOMCLI+DTOS(E1_VENCREA)+E1_PREFIXO+E1_NUM+E1_PARCELA"
                    // "E1_FILIAL+E1_VEND1+DTOS(E1_VENCREA)+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA"
                    cOrder := SqlOrder(cChaveSe1)
                    cCond1 := "E1_VEND1 <= 'ZZZZZZ'"
                    cCond2 := "E1_VEND1" // E1_CLIENTE + E1_LOJA"
                    titulo := titulo + OemToAnsi(" - Por Vendedor")
             Endif

             If mvpar19 == 1
                titulo := titulo + OemToAnsi(" - Analitico")
             Else
                titulo := titulo + OemToAnsi(" - Sintetico")
                cabec1 := OemToAnsi("Nome do Cliente      |        Titulos Vencidos          | Titulos a Vencer |            Vlr.juros ou             (Vencidos+Vencer)")
                cabec2 := OemToAnsi("                     |  Valor Nominal   Valor Corrigido |   Valor Nominal  |             permanencia                              ")
             EndIf

             //cFilterUser:=aReturn[7]
             cFilterUser:=""
             Set Softseek Off

             #IFDEF TOP
                    if TcSrvType() != "AS/400"
                       cQuery += " AND E1_CLIENTE between '" + mvpar01        + "' AND '" + mvpar02 + "'"
                       cQuery += " AND E1_VEND1   between '" + mvpar40        + "' AND '" + mvpar41 + "'"
                       cQuery += " AND E1_PREFIXO between '" + mvpar03        + "' AND '" + mvpar04 + "'"
                       cQuery += " AND E1_NUM     between '" + mvpar05        + "' AND '" + mvpar06 + "'"
                       cQuery += " AND E1_PORTADO between '" + mvpar07        + "' AND '" + mvpar08 + "'"
                       cQuery += " AND E1_VENCREA between '" + DTOS(mvpar09)  + "' AND '" + DTOS(mvpar10) + "'"
                       cQuery += " AND (E1_MULTNAT = '1' OR (E1_NATUREZ BETWEEN '"+MVPAR11+"' AND '"+MVPAR12+"'))"
                       cQuery += " AND (E1_NATUREZ <> '801004')" //Filtrar Lucros e Perdas
                       cQuery += " AND E1_EMISSAO between '" + DTOS(mvpar13)  + "' AND '" + DTOS(mvpar14) + "'"
                       cQuery += " AND E1_LOJA    between '" + mvpar24        + "' AND '" + mvpar25 + "'"
                       cQuery += " AND E1_EMISSAO <=      '" + DTOS(dDataBase) + "'"
                       cQuery += " AND ((E1_EMIS1  Between '"+ DTOS(mvpar27)+"' AND '"+DTOS(mvpar28)+"') OR E1_EMISSAO Between '"+DTOS(mvpar27)+"' AND '"+DTOS(mvpar28)+"')"
                       If !Empty(mvpar31) // Deseja imprimir apenas os tipos do parametro 31
                          cQuery += " AND E1_TIPO IN "+FormatIn(mvpar31,";") 
                       ElseIf !Empty(Mvpar32) // Deseja excluir os tipos do parametro 32
                              cQuery += " AND E1_TIPO NOT IN "+mvpar32 // FormatIn(mvpar32,";")
                       EndIf
                       If mvpar18 == 2
                          cQuery += " AND E1_SITUACA NOT IN ('2','7')"
                       Endif
                       If mvpar20 == 2
                          cQuery += ' AND E1_SALDO <> 0'
                       Endif
                       If mvpar34 == 1
                          cQuery += " AND E1_FLUXO <> 'N'"
                       Endif
                       cQuery += " ORDER BY "+ cOrder

                       cQuery := ChangeQuery(cQuery)

                       dbSelectArea("SE1")
                       dbCloseArea()
                       dbSelectArea("SA1")

                       dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1', .F., .T.)

                       For ni := 1 to Len(aStru)
                           If aStru[ni,2] != 'C'
                              TCSetField('SE1', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
                           Endif
                       Next
                    endif
             #ENDIF
             SetRegua(nTotsRec)

             If MV_MULNATR .And. nOrdem == 5
                Finr135(cTipos, lEnd, @nTot0, @nTot1, @nTot2, @nTot3, @nTotTit, @nTotJ )
                #IFDEF TOP
                       If TcSrvType() != "AS/400"
                          dbSelectArea("SE1")
                          dbCloseArea()
                          ChKFile("SE1")
                          dbSelectArea("SE1")
                          dbSetOrder(1)
                       Endif
                #ENDIF
                If Empty(xFilial("SE1"))
                   Exit
                Endif
                dbSelectArea("SM0")
                dbSkip()
                Loop
             Endif

             While &cCond1 .and. !Eof() .and. lContinua .and. E1_FILIAL == xFilial("SE1")

                   If lEnd
                      @PROW()+1,001 PSAY OemToAnsi("CANCELADO PELO OPERADOR")
                      Exit
                   Endif

                   IncRegua()

                   Store 0 To nTit1,nTit2,nTit3,nTit4,nTit5

                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³ Carrega data do registro para permitir ³
                   //³ posterior analise de quebra por mes.   ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   dDataAnt := Iif(nOrdem == 6 , SE1->E1_EMISSAO,  SE1->E1_VENCREA)
                   /* Verificação se existe o diretório para a geração do arquivo em
                      disco na maquina do usuário que está emitindo o relatório.     */
                   cRelato  := "\SPOOL\REPRES\"
                   nHandle := fCreate(cRelato+"Teste")
                   If nHandle <> -1 
                      fClose(nHandle)
                      fErase(cRelato+"TESTE")
                   Else
                      If MakeDir(cRelato) != 0
                         If Right(cRelato,1) == "\"
                            cRelt := SubStr(cRelato,1,Len(cRelato)-1)
                         Else
                            cRelt := cRelato
                         Endif
                         If !MontaDir(cRelt)
                            Help(" ",1,"RELDIRERR")
                         Endif
                      Endif
                   Endif
                   /******************************************************************/
                   cCarAnt  := &cCond2
                   If !Empty(cCarAnt) 
                      If Empty(Alltrim(Posicione("SA3",1,xFilial("SA3")+cCarAnt,"A3_EMAIL")))
                         DbSelectArea("SE1")
                         DbSkip()
                         Loop
                      Endif
                   Else
                      DbSelectArea("SE1")
                      DbSkip()
                      Loop
                   Endif
                   cArqTxt1 := cRelato+Iif(cNumEmp = "01010101","BR",Iif(cNumEmp = "01010104", "RS", IIF(cNumEmp = "05","PY",IIF(cNumEmp = "01060101","DS","BT"))))+Alltrim(cCarAnt)+".TXT"
                   nHdl1    := fCreate(cArqTxt1)
                   Li := 80
                   While &cCond2==cCarAnt .and. !Eof() .and. lContinua .and. E1_FILIAL == xFilial("SE1")
                         cQbrCli := SE1->E1_CLIENTE
                         While !Eof() .and. cQbrCli == SE1->E1_CLIENTE .and. lContinua .and. E1_FILIAL == xFilial("SE1")
                               cLin    := space(134)
                               IF lEnd
                                  @PROW()+1,001 PSAY OemToAnsi("CANCELADO PELO OPERADOR")
                                  lContinua := .F.
                                  Exit
                               EndIF

                               IncRegua()

                               dbSelectArea("SE1")
                               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                               //³ Filtrar com base no Pto de entrada do Usuario...             ³
                               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄJose Lucas, Localiza‡”es ArgentinaÄÙ
                               If !Empty(cTipos)
                                  If !(SE1->E1_TIPO $ cTipos)
                                     dbSkip()
                                     Loop
                                  Endif
                               Endif

                               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                               //³ Considera filtro do usuario                                  ³
                               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                               If !Empty(cFilterUser).and.!(&cFilterUser)
                                  dbSkip()
                                  Loop
                               Endif

                               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                               //³ Filtrar Lucros e Perdas(Natur 801004)-Cleber(14-07-03)          ³
                               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                               If (mvpar39 == 1) .and. (SE1->E1_NATUREZ = '801004')
                                  dbSkip()
                                  Loop
                               Endif

                               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                               //³ Verifica se titulo, apesar do E1_SALDO = 0, deve aparecer ou ³
                               //³ nÆo no relat¢rio quando se considera database (mvpar20 = 1) ³
                               //³ ou caso nÆo se considere a database, se o titulo foi totalmen³
                               //³ te baixado.																  ³
                               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                               dbSelectArea("SE1")
                               IF !Empty(SE1->E1_BAIXA) .and. Iif(mvpar20 == 2 ,SE1->E1_SALDO == 0 ,;
                                  IIF(mvpar37 == 1,(SE1->E1_SALDO == 0 .and. SE1->E1_BAIXA <= dDataBase),.F.))
                                  dbSkip()
                                  Loop
                               EndIF

                               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                               //³ Verifica se trata-se de abatimento ou somente titulos³
                               //³ at‚ a data base. 									 ³
                               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                               IF (SE1->E1_TIPO $ MVABATIM .And. mvpar33 != 1) .Or.;
                                  SE1->E1_EMISSAO>dDataBase
                                  dbSkip()
                                  Loop
                               Endif

                               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                               //³ Verifica se ser  impresso titulos provis¢rios		 ³
                               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                               IF E1_TIPO $ MVPROVIS .and. mvpar16 == 2
                                  dbSkip()
                                  Loop
                               Endif

                               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                               //³ Verifica se ser  impresso titulos de Adiantamento	 ³
                               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                               IF SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .and. mvpar26 == 2
                                  dbSkip()
                                  Loop
                               Endif

                               // dDtContab para casos em que o campo E1_EMIS1 esteja vazio
                               dDtContab := Iif(Empty(SE1->E1_EMIS1),SE1->E1_EMISSAO,SE1->E1_EMIS1)

                               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                               //³ Verifica se esta dentro dos parametros ³
                               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                               dbSelectArea("SE1")
                               IF SE1->E1_CLIENTE < mvpar01 .OR. SE1->E1_CLIENTE > mvpar02 .OR. ;
                                  SE1->E1_PREFIXO < mvpar03 .OR. SE1->E1_PREFIXO > mvpar04 .OR. ;
                                  SE1->E1_NUM	 	 < mvpar05 .OR. SE1->E1_NUM 		> mvpar06 .OR. ;
                                  SE1->E1_PORTADO < mvpar07 .OR. SE1->E1_PORTADO > mvpar08 .OR. ;
                                  SE1->E1_VENCREA < mvpar09 .OR. SE1->E1_VENCREA > mvpar10 .OR. ;
                                  SE1->E1_NATUREZ < mvpar11 .OR. SE1->E1_NATUREZ > mvpar12 .OR. ;
                                  SE1->E1_EMISSAO < mvpar13 .OR. SE1->E1_EMISSAO > mvpar14 .OR. ;
                                  SE1->E1_LOJA    < mvpar24 .OR. SE1->E1_LOJA    > mvpar25 .OR. ;
                                  dDtContab       < mvpar27 .OR. dDtContab       > mvpar28 .OR. ;
                                  SE1->E1_EMISSAO > dDataBase .Or. !&(fr130IndR())
                                  dbSkip()
                                  Loop
                               Endif

                               If mvpar18 == 2 .and. E1_SITUACA $ "27"
                                  dbSkip()
                                  Loop
                               Endif

                               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                               //³ Verifica se deve imprimir outras moedas³
                               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                               If mvpar30 == 2 // nao imprime
                                  if SE1->E1_MOEDA != mvpar15 //verifica moeda do campo=moeda parametro
                                     dbSkip()
                                     Loop
                                  endif
                               Endif


                               dDataReaj := IIF(SE1->E1_VENCREA < dDataBase ,;
                               IIF(mvpar17=1,dDataBase,E1_VENCREA),;
                               dDataBase)

                               If mvpar20 == 1	// Considera Data Base
                                  nSaldo :=SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,mvpar15,dDataReaj,,SE1->E1_LOJA,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0),IIF(mvpar37 == 1,.F.,.T.))
                               Else
                                  nSaldo := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,mvpar15,dDataReaj,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                               Endif

                               If ! SE1->E1_TIPO $ MVABATIM
                                  If ! (SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG) .And. ;
                                     !( MVPAR20 == 2 .And. nSaldo == 0 )  	// deve olhar abatimento pois e zerado o saldo na liquidacao final do titulo
                                     nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",mvpar15,dDataReaj,SE1->E1_CLIENTE,SE1->E1_LOJA)
                                     If STR(nSaldo,17,2) == STR(nAbatim,17,2)
                                        nSaldo := 0
                                     ElseIf mvpar33 != 3
                                            nSaldo-= nAbatim
                                     Endif
                                  EndIf
                               Endif	
                               nSaldo:=Round(NoRound(nSaldo,3),2)

                               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                               //³ Desconsidera caso saldo seja menor ou igual a zero   ³
                               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                               If nSaldo <= 0
                                  dbSkip()
                                  Loop
                               Endif

                               dbSelectArea("SA1")
                               MSSeek(cFilial+SE1->E1_CLIENTE+SE1->E1_LOJA)
                               dbSelectArea("SA6")
                               MSSeek(cFilial+SE1->E1_PORTADO)
                               dbSelectArea("SE1")

                               IF li > 58
                                  nAtuSM0 := SM0->(Recno())
                                  SM0->(dbGoto(nRegSM0)) 
                                  //                    1         2         3         4         5         6         7         8         9         10        11        12        13
                                  //           12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
                                  //           Codigo/LJ-Nome do Cliente    Prf-Numero   -P Tipo  Emissão   Vencto  Bco Vlr. Origin.|Tit. Vencidos|Tit. a Vencer|  Numero Banco   Atr
                                  //           999999/99-XXXXXXXXXXXXXXXXXX XXX-999999XXX-X [XXX] 99/99/99 99/99/99 999 9,999,999.99  9,999,999.99  9,999,999.99  999999999999999 999
                                  //           REPRESENTANTE : 999999-XXXXXXXXXXXXXXXXXXXXXXXXX -999999999999999 
                                  /**************************************************************/
                                  li := 1
                                  cLin := space(134)
                                  cCpo := space(134) // PADR(space(131),131)
                                  cLin := Stuff(cLin,01,134,cCpo)+cEol
                                  fWrite(nHdl1,cLin,Len(cLin))
                                  /**************************************************************/
                                  li++
                                  cLin := space(134)
                                  cCpo := Replicate("*",134)
                                  cLin := Stuff(cLin,01,134,cCpo)+cEol
                                  fWrite(nHdl1,cLin,Len(cLin))
                                  /**************************************************************/
                                  li++
                                  cLin := Space(134)
                                  cCpo := PADR("* "+Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL),35)
                                  cLin := Stuff(cLin,01,35,cCpo)
                                  cCpo := PADR(RPTFolha+" "+Transform(m_pag,"99999999")+" *",19)
                                  cLin := Stuff(cLin,113,19,cCpo)+cEol
                                  fWrite(nHdl1,cLin,Len(cLin))
                                  /**************************************************************/
                                  li++
                                  cLin := Space(134)
                                  cCpo := PADR("* SIGA / "+wnrel+" / v."+cVersao,31)
                                  cLin := Stuff(cLin,01,31,cCpo)
                                  cCpo := PADR(PADC(Trim(Titulo),134-31-19),83)
                                  cLin := Stuff(cLin,32,83,cCpo)
                                  cCpo := PADR("DT.Ref.: "+dToc(dDataBase,"DDMMYY")+" *",19)
                                  cLin := Stuff(cLin,113,19,cCpo)+cEol
                                  fWrite(nHdl1,cLin,Len(cLin))
                                  /**************************************************************/
                                  li++
                                  cLin := Space(134)
                                  cCpo := PADR("* "+RptHora+" "+Time(),19)
                                  cLin := Stuff(cLin,01,19,cCpo)
                                  cCpo := PADR(RptEmiss+" "+dToc(MsDate(),"DDMMYY")+" *",19)
                                  cLin := Stuff(cLin,113,19,cCpo)+cEol
                                  fWrite(nHdl1,cLin,Len(cLin))
                                  /**************************************************************/
                                  li++
                                  cLin := Space(134)
                                  cCpo := Replicate("*",134)
                                  cLin := Stuff(cLin,01,134,cCpo)+cEol
                                  fWrite(nHdl1,cLin,Len(cLin))
                                  /**************************************************************/
                                  li++
                                  cLin := space(134)
                                  cCpo := PADR("Codigo/LJ-Nome do Cliente    Prf-Numero   -P Tipo  Emissão   Vencto  Bco Vlr. Origin.|Tit. Vencidos|Tit. a Vencer|  Numero Banco   Atr",134)
                                  cLin := Stuff(cLin,01,134,cCpo)+cEol
                                  fWrite(nHdl1,cLin,Len(cLin))
                                  /**************************************************************/
                                  li++
                                  cLin := space(134)
                                  cCpo := Replicate("*",134)
                                  cLin := Stuff(cLin,01,134,cCpo)+cEol
                                  fWrite(nHdl1,cLin,Len(cLin))
                                  //cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
                                  SM0->(dbGoTo(nAtuSM0))
                               EndIF

                               If mvpar19 == 1
                                  li++
                                  cLin := space(128)
                                  cCpo := PADR(SE1->E1_CLIENTE + "/" + SE1->E1_LOJA + "-" +SubStr( Posicione("SA1", 1, xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA, "A1_NOME"), 1, 18 ),28) //SubStr( SE1->E1_NOMCLI, 1, 18 ),28)
                                  cLin := Stuff(cLin,01,28,cCpo)
                                  //@li,	0 PSAY SE1->E1_CLIENTE + "-" + SE1->E1_LOJA + "-" + SubStr( SE1->E1_NOMCLI, 1, 17 )
                                  li := IIf (aTamCli[1] > 6,li+1,li)
                                  cCpo := PADR(SE1->E1_PREFIXO+"-"+RTRIM(SE1->E1_NUM)+"-"+SE1->E1_PARCELA,12)
                                  cLin := Stuff(cLin,30,12,cCpo)
                                  //@li, 28 PSAY SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"-"+SE1->E1_PARCELA
                                  If SE1->E1_TIPO$MVABATIM
                                     cCpo := PADR("[",1)
                                     cLin := Stuff(cLin,43,1,cCpo)
                                     //@li,46 PSAY "["
                                  Endif
                                  cCpo := PADR(SE1->E1_TIPO,3)
                                  cLin := Stuff(cLin,44,3,cCpo)
                                  //@li, 47 PSAY SE1->E1_TIPO
                                  If SE1->E1_TIPO$MVABATIM
                                     cCpo := PADR("]",1)
                                     cLin := Stuff(cLin,47,1,cCpo)
                                     //@li,50 PSAY "]"
                                  Endif
                                  //@li, 51 PSAY SE1->E1_NATUREZ
                                  cCpo := PADR(SE1->E1_EMISSAO,8)
                                  cLin := Stuff(cLin,49,8,cCpo)
                                  //@li, 62 PSAY SE1->E1_EMISSAO
                                  cCpo := PADR(SE1->E1_VENCTO,8)
                                  cLin := Stuff(cLin,58,8,cCpo)
                                  //@li, 73 PSAY SE1->E1_VENCTO
                                  //@li, 84 PSAY SE1->E1_VENCREA
                                  cCpo := PADR(Iif(SE1->E1_PORTADO=="001","BR ",IIF(SE1->E1_PORTADO=="104","CEF",IIF(SE1->E1_PORTADO=="237","BRD",IIF(SE1->E1_PORTADO=="341","ITA",IIF(SE1->E1_PORTADO=="347","SUD","   "))))),3)
                                  cLin := Stuff(cLin,67,3,cCpo)
                                  //@li, 95 PSAY SE1->E1_PORTADO+" "+SE1->E1_SITUACA
                                  cCpo := PADR( Transform( xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mvpar15,SE1->E1_EMISSAO,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))* If(SE1->E1_TIPO$MVABATIM, -1,1), "@E 9,999,999.99"), 12)
                                  cLin := Stuff(cLin,71,12,cCpo)
                                  //@li,101 PSAY xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mvpar15,SE1->E1_EMISSAO,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))* If(SE1->E1_TIPO$MVABATIM, -1,1) Picture PesqPict("SE1","E1_VALOR",14,MVPAR15)
                               Endif

                               If dDataBase > E1_VENCREA	//vencidos
                                  If mvpar19 == 1
                                     If ! SE1->E1_TIPO $ MVABATIM
                                        cCpo := PADR( Transform(Iif(nSaldo>=0, nSaldo, 0), "@E 9,999,999.99"), 12)
                                        cLin := Stuff(cLin,85,12,cCpo)
                                        cCpo := PADR( Transform(0, "@E 9,999,999.99"), 12)
                                        cLin := Stuff(cLin,99,12,cCpo)
                                        //@li, 116 PSAY nSaldo  Picture PesqPict("SE1","E1_SALDO",14,MVPAR15)
                                     Else
                                        cCpo := PADR( Transform(0, "@E 9,999,999.99"), 12)
                                        cLin := Stuff(cLin,85,12,cCpo)
                                        cCpo := PADR( Transform(0, "@E 9,999,999.99"), 12)
                                        cLin := Stuff(cLin,99,12,cCpo)
                                     EndIf
                                  EndIf
                                  nJuros:=0
                                  fa070Juros(mvpar15)
                                  dbSelectArea("SE1")
                                  If mvpar19 == 1
                                     //@li,133 PSAY nSaldo+nJuros Picture PesqPict("SE1","E1_SALDO",14,MVPAR15)
                                  EndIf
                                  If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG
                                     nTit0 -= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mvpar15,SE1->E1_EMISSAO,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                                     nTitCli0 -= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mvpar15,SE1->E1_EMISSAO,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                                     nTit1 -= (nSaldo)
                                     nTitCli1 -= (nSaldo)
                                     nTit2 -= (nSaldo+nJuros)
                                     nMesTit0 -= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mvpar15,SE1->E1_EMISSAO,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                                     nMesTit1 -= (nSaldo)
                                     nMesTit2 -= (nSaldo+nJuros)
                                     nTotJur  -= nJuros
                                     nMesTitj -= nJuros
                                     nTotFilJ -= nJuros
                                  Else
                                     If !SE1->E1_TIPO $ MVABATIM
                                        nTit0 += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mvpar15,SE1->E1_EMISSAO,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                                        nTitCli0 += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mvpar15,SE1->E1_EMISSAO,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                                        nTit1 += (nSaldo)
                                        nTitCli1 += (nSaldo)
                                        nTit2 += (nSaldo+nJuros)
                                        nMesTit0 += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mvpar15,SE1->E1_EMISSAO,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                                        nMesTit1 += (nSaldo)
                                        nMesTit2 += (nSaldo+nJuros)
                                        nTotJur  += nJuros
                                        nMesTitj += nJuros
                                        nTotFilJ += nJuros
                                     Endif	
                                  Endif
                               Else						//a vencer
                                  If mvpar19 == 1
                                     If !(SE1->E1_TIPO $ MVABATIM)				
                                        cCpo := PADR( Transform(0, "@E 9,999,999.99"), 12)
                                        cLin := Stuff(cLin,85,12,cCpo)
                                        cCpo := PADR( Transform(Iif(nSaldo >= 0, nSaldo, 0), "@E 9,999,999.99"), 12)
                                        cLin := Stuff(cLin,99,12,cCpo)
                                        //@li,149 PSAY nSaldo Picture PesqPict("SE1","E1_SALDO",14,MVPAR15)
                                     Else
                                        cCpo := PADR( Transform(0, "@E 9,999,999.99"), 12)
                                        cLin := Stuff(cLin,85,12,cCpo)
                                        cCpo := PADR( Transform(0, "@E 9,999,999.99"), 12)
                                        cLin := Stuff(cLin,99,12,cCpo)                               
                                     Endif
                                  EndIf
                                  If ! ( SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
                                     If !SE1->E1_TIPO $ MVABATIM
                                        nTit0 += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mvpar15,SE1->E1_EMISSAO,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                                        nTitCli0 += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mvpar15,SE1->E1_EMISSAO,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                                        nTit3 += (nSaldo-nTotAbat)
                                        nTitCli3 += (nSaldo-nTotAbat)
                                        nTit4 += (nSaldo-nTotAbat)
                                        nMesTit0 += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mvpar15,SE1->E1_EMISSAO,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                                        nMesTit3 += (nSaldo-nTotAbat)
                                        nMesTit4 += (nSaldo-nTotAbat)
                                     Endif
                                  Else
                                     nTit0 -= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mvpar15,SE1->E1_EMISSAO,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                                     nTitCli0 -= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mvpar15,SE1->E1_EMISSAO,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                                     nTit3 -= (nSaldo-nTotAbat)
                                     nTitCli3 -= (nSaldo-nTotAbat)
                                     nTit4 -= (nSaldo-nTotAbat)
                                     nMesTit0 -= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mvpar15,SE1->E1_EMISSAO,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                                     nMesTit3 -= (nSaldo-nTotAbat)
                                     nMesTit4 -= (nSaldo-nTotAbat)
                                  Endif
                               Endif

                               If mvpar19 == 1
                                  cCpo := PADR( SE1->E1_NUMBCO, 15)
                                  cLin := Stuff(cLin,113,15,cCpo)
                                  //@ li, 164 PSAY SE1->E1_NUMBCO
                               EndIf
                               If nJuros > 0
                                  If mvpar19 == 1
                                     //@ Li,181 PSAY nJuros Picture PesqPict("SE1","E1_JUROS",10,MVPAR15)
                                  EndIf
                                  nJuros := 0
                               Endif

                               IF dDataBase > SE1->E1_VENCREA
                                  nAtraso := dDataBase - SE1->E1_VENCTO
                                  IF Dow(SE1->E1_VENCTO) == 1 .Or. Dow(SE1->E1_VENCTO) == 7
                                     IF Dow(dBaixa) == 2 .and. nAtraso <= 2
                                        nAtraso := 0
                                     EndIF
                                  EndIF
                                  nAtraso := IIF(nAtraso < 0, 0, nAtraso)
                                  If nAtraso > 0
                                     If mvpar19 == 1
                                        cCpo := PADR( Transform(nAtraso, "999"), 3)
                                        cLin := Stuff(cLin,129,3,cCpo)+cEol
                                        //@li ,195 PSAY nAtraso Picture "9999"
                                     EndIf
                                  Else
                                     cCpo := PADR( Transform(0, "999"), 3)
                                     cLin := Stuff(cLin,129,3,cCpo)+cEol
                                  EndIF
                               Else
                                  cCpo := PADR( Transform(0, "999"), 3)
                                  cLin := Stuff(cLin,129,3,cCpo)+cEol
                               EndIF
                               If mvpar19 == 1
                                  //@li,200 PSAY SubStr(SE1->E1_HIST,1,20)+ ;
                                  //IIF(E1_TIPO $ MVPROVIS,"*"," ")+ ;
                                  //Iif(nSaldo == xMoeda(E1_VALOR,E1_MOEDA,mvpar15,dDataReaj,ndecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))," ","P")
                               EndIf

                               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                               //³ Carrega data do registro para permitir ³
                               //³ posterior an lise de quebra por mes.   ³
                               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                               dDataAnt := Iif(nOrdem == 6, SE1->E1_EMISSAO, SE1->E1_VENCREA)
                               dbSkip()
                               nTotTit ++
                               nMesTTit ++
                               nTotFiltit++
                               nTit5 ++
                               If mvpar19 == 1
                                  //li++
                               EndIf
                               If fWrite(nHdl1,cLin,Len(cLin)) != Len(cLin)
                                  If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
                                     Exit
                                  Endif
                               Endif
                         Enddo
                         cLin := space(134)
                         cCpo := Replicate("-",134)
                         cLin := Stuff(cLin,01,134,cCpo)+cEol
                         fWrite(nHdl1,cLin,Len(cLin))
                         /**********************************************/
                         cLin := space(134)
	                     cCpo := PadR("TOTAL DO CLIENTE: "+cQbrCli+"-"+Substr(Posicione("SA1", 1, xFilial("SA1")+cQbrCli,"A1_NREDUZ"),1,25)+" - ("+Posicione("SA1",1, xFilial("SA1")+cQbrCli,"A1_DDD")+")"+Posicione("SA1",1, xFilial("SA1")+cQbrCli,"A1_TEL"),69)
						 cCpo := padr(cCpo,69)
                         cLin := Stuff(cLin,01,69,cCpo)
                         cCpo := PadR( Transform(nTitCli0, "@E 9,999,999.99"), 12)
                         cLin := Stuff(cLin,71,12,cCpo)
                         cCpo := PadR( Transform(nTitCli1, "@E 9,999,999.99"), 12)
                         cLin := Stuff(cLin,85,12,cCpo)
                         cCpo := PadR( Transform(nTitCli3, "@E 9,999,999.99"), 12)
                         cLin := Stuff(cLin,99,12,cCpo)+cEol
                         fWrite(nHdl1,cLin,Len(cLin))
                         cLin := space(134)
                         cCpo := Replicate("*",134)
                         cLin := Stuff(cLin,01,134,cCpo)+cEol
                         fWrite(nHdl1,cLin,Len(cLin))
                         Store 0 To nTitCli0, nTitCli1
                   Enddo
                   cLin := space(134)
                   cCpo := Replicate("-",134)
                   cLin := Stuff(cLin,01,134,cCpo)+cEol
                   fWrite(nHdl1,cLin,Len(cLin))
                   IF nTit5 > 0 .and. nOrdem != 2 .and. nOrdem != 10
                      FIN0241(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur)
                      If mvpar19 == 1
                         Li++
                      EndIf
                   Endif
                   cLin := space(134)
                   cCpo := Replicate("-",134)
                   cLin := Stuff(cLin,01,132,cCpo)+cEol
                   fWrite(nHdl1,cLin,Len(cLin))

                   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   //³ Verifica quebra por mˆs	  			   ³
                   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   lQuebra := .F.
                   If nOrdem == 4  .and. (Month(SE1->E1_VENCREA) # Month(dDataAnt) .or. SE1->E1_VENCREA > mvpar10)
                      lQuebra := .T.
                   Elseif nOrdem == 6 .and. (Month(SE1->E1_EMISSAO) # Month(dDataAnt) .or. SE1->E1_EMISSAO > mvpar14)
                          lQuebra := .T.
                   Endif
                   If lQuebra .and. nMesTTit # 0
                      //ImpMes130(nMesTit0,nMesTit1,nMesTit2,nMesTit3,nMesTit4,nMesTTit,nMesTitJ)
                      nMesTit0 := nMesTit1 := nMesTit2 := nMesTit3 := nMesTit4 := nMesTTit := nMesTitj := 0
                   Endif
                   nTot0+=nTit0
                   nTot1+=nTit1
                   nTot2+=nTit2
                   nTot3+=nTit3
                   nTot4+=nTit4
                   nTotJ+=nTotJur

                   nTotFil0+=nTit0
                   nTotFil1+=nTit1
                   nTotFil2+=nTit2
                   nTotFil3+=nTit3
                   nTotFil4+=nTit4
                   Store 0 To nTit0,nTit1,nTit2,nTit3,nTit4,nTit5,nTotJur,nTotAbat
                   fClose(nHdl1)
                   If (mvpar42 == 1) .and. !Empty(Posicione("SA3",1,xFilial("SA3")+cCarAnt,"A3_EMAIL"))
                   		MEMail(Posicione("SA3",1,xFilial("SA3")+cCarAnt,"A3_EMAIL"))
                   Endif
                   DbSelectArea("SE1")
             Enddo

             dbSelectArea("SE1")		// voltar para alias existente, se nao, nao funciona

             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Imprimir TOTAL por filial somente quan-³
             //³ do houver mais do que 1 filial.        ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             if mvpar21 == 1 .and. SM0->(Reccount()) > 1
                //ImpFil130(nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFiltit,nTotFilJ)
             Endif
             Store 0 To nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFilTit,nTotFilJ
             If Empty(xFilial("SE1"))
                Exit
             Endif

             #IFDEF TOP
                    if TcSrvType() != "AS/400"
                       dbSelectArea("SE1")
                       dbCloseArea()
                       ChKFile("SE1")
                       dbSelectArea("SE1")
                       dbSetOrder(1)
                    endif
             #ENDIF

             dbSelectArea("SM0")
             dbSkip()
       Enddo

       SM0->(dbGoTo(nRegSM0))
       cFilAnt := SM0->M0_CODFIL
       IF li != 80
          IF li > 58
             //cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
          EndIF
          //TotGer130(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ)
          //Roda(cbcont,cbtxt,"G")
       EndIF

       Set Device To Screen

       #IFNDEF TOP
               dbSelectArea("SE1")
               dbClearFil(NIL)
               RetIndex( "SE1" )
               If !Empty(cIndexSE1)
                  FErase (cIndexSE1+OrdBagExt())
               Endif
               dbSetOrder(1)
       #ELSE
           if TcSrvType() != "AS/400"
              dbSelectArea("SE1")
              dbCloseArea()
              ChKFile("SE1")
              dbSelectArea("SE1")
              dbSetOrder(1)
           else
              dbSelectArea("SE1")
              dbClearFil()
              RetIndex( "SE1" )
              If !Empty(cIndexSE1)
                 FErase (cIndexSE1+OrdBagExt())
              Endif
              dbSetOrder(1)
           endif
       #ENDIF
       cReturn5 := 1
       //If aReturn[5] = 1
       If cReturn5 = 1
          Set Printer TO
          dbCommitAll()
          //Ourspool(wnrel)
       Endif
       MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FIN0241  ³ Autor ³ Paulo Boschetti 		  ³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprimir SubTotal do Relatorio										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FIN0241()  																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³																				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	    ³ Generico																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function FIN0241(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur)
     //LOCAL aSituaca := {OemToAnsi("Carteira")  ,OemToAnsi("Simples"),;
     //                   OemToAnsi("Descontada"),OemToAnsi("Caucionada"),OemToAnsi("Vinculada"),;
     //                   OemToAnsi("Advogado")  ,OemToAnsi("Judicial")  ,OemToAnsi("Cauc Desc") }
     Local cLin := space(134)
     Local cEol := CHR(13)+CHR(10)
     If mvpar19 == 1
        li++
     EndIf
     IF li > 58
        nAtuSM0 := SM0->(Recno())
        SM0->(dbGoto(nRegSM0))
        //cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
        SM0->(dbGoTo(nAtuSM0))
     EndIF
     If nOrdem = 1
            //@li,000 PSAY IIF(mvpar29 == 1,SA1->A1_NREDUZ,SA1->A1_NOME)+" "+SA1->A1_DDD+"-"+SA1->A1_TEL+ " "+ "Loja - " + Right(cCarAnt,2)+Iif(mvpar21==1," Filial - "+cFilAnt,"")
     Elseif nOrdem == 4 .or. nOrdem == 6
            //@li,000 PSAY OemToAnsi("S U B - T O T A L ----> ")
            //@li,028 PSAY cCarAnt
            //@li,PCOL()+2 PSAY Iif(mvpar21==1,cFilAnt,"  ")
     Elseif nOrdem = 3
            //@li,000 PSAY OemToAnsi("S U B - T O T A L ----> ")
            //@li,028 PSAY Iif(Empty(SA6->A6_NREDUZ),OemToAnsi("Carteira"),SA6->A6_NREDUZ) + " " + Iif(mvpar21==1,cFilAnt,"")
     ElseIf nOrdem == 5
            dbSelectArea("SED")
            dbSeek(cFilial+cCarAnt)
            //@li,000 PSAY OemToAnsi("S U B - T O T A L ----> ")
            //@li,028 PSAY cCarAnt + " "+ED_DESCRIC + " " + Iif(mvpar21==1,cFilAnt,"")
            dbSelectArea("SE1")
     Elseif nOrdem == 7
            //@li,000 PSAY OemToAnsi("S U B - T O T A L ----> ")
            //@li,028 PSAY SubStr(cCarAnt,7,2)+"/"+SubStr(cCarAnt,5,2)+"/"+SubStr(cCarAnt,3,2)+" - "+SubStr(cCarAnt,9,3) + " " +Iif(mvpar21==1,cFilAnt,"")
     ElseIf nOrdem = 8
            //@li,000 PSAY SA1->A1_COD+" "+SA1->A1_NOME+" "+SA1->A1_DDD+"-"+SA1->A1_TEL + " " + Iif(mvpar21==1,cFilAnt,"")
     ElseIf nOrdem = 9
            //@li,000 PSAY SubStr(cCarant,1,3)+" "+SA6->A6_NREDUZ + SubStr(cCarant,4,1) + " "+aSituaca[Val(SubStr(cCarant,4,1))+1] + " " + Iif(mvpar21==1,cFilAnt,"")
     ElseIf nOrdem = 11
            cCpo := PadR("REPRESENTANTE : "+cCarAnt+"-"+IIF(mvpar29 == 1,Substr(Posicione("SA3",1, xFilial("SA3")+cCarAnt,"A3_NREDUZ"),1,25),Substr(Posicione("SA3",1, xFilial("SA3")+cCarAnt,"A3_NOME"),1,25))+" "+"- "+Posicione("SA3",1, xFilial("SA3")+cCarAnt,"A3_TEL"),69)
            cLin := Stuff(cLin,01,69,cCpo)
            //@li,000 PSAY "REPRESENTANTE : "+cCarAnt+"-"+IIF(mvpar29 == 1,Posicione("SA3",1, xFilial("SA3")+cCarAnt,"A3_NREDUZ"),Posicione("SA3",1, xFilial("SA3")+cCarAnt,"A3_NOME"))+" "+"-"+Posicione("SA3",1, xFilial("SA3")+cCarAnt,"A3_TEL") +Iif(mvpar21==1," Filial - "+cFilAnt,"")
     Endif
     If mvpar19 == 1
        cCpo := PadR( Transform(nTit0, "@E 9,999,999.99"), 12)
        cLin := Stuff(cLin,71,12,cCpo)
        //@li,101 PSAY nTit0		  Picture PesqPict("SE1","E1_VALOR",14,MVPAR15)
     Endif
     cCpo := PadR( Transform(nTit1, "@E 9,999,999.99"), 12)
     cLin := Stuff(cLin,85,12,cCpo)
     //@li,116 PSAY nTit1		  Picture PesqPict("SE1","E1_SALDO",14,MVPAR15)
     //@li,133 PSAY nTit2		  Picture PesqPict("SE1","E1_SALDO",14,MVPAR15)
     cCpo := PadR( Transform(nTit3, "@E 9,999,999.99"), 12)
     cLin := Stuff(cLin,99,12,cCpo)+cEol
     //@li,149 PSAY nTit3		  Picture PesqPict("SE1","E1_SALDO",14,MVPAR15)
     If nTotJur > 0
        //@li,179 PSAY nTotJur  Picture PesqPict("SE1","E1_JUROS",12,MVPAR15)
     Endif
     If nOrdem <> 11
        //@li,204 PSAY nTit2+nTit3 Picture PesqPict("SE1","E1_SALDO",16,MVPAR15)
     Endif
     li++
     If (nOrdem = 1 .Or. nOrdem == 8 .or. nOrdem == 11) .And. mvpar35 == 1 // Salta pag. por cliente
        //cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
     Endif
     fWrite(nHdl1,cLin,Len(cLin))
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TotGer130³ Autor ³ Paulo Boschetti       ³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprimir total do relatorio										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ TotGer130()																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³																				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
STATIC Function TotGer130(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ)

       li++
       IF li > 58
          nAtuSM0 := SM0->(Recno())
       SM0->(dbGoto(nRegSM0))
       cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
       SM0->(dbGoTo(nAtuSM0))
       EndIF
       @li,000 PSAY OemToAnsi("T O T A L   G E R A L ----> " + " " + Iif(mvpar21==1,cFilAnt,""))
       @li,028 PSAY "("+ALLTRIM(STR(nTotTit))+" "+IIF(nTotTit > 1,OemToAnsi("TITULOS"),OemToAnsi("TITULO"))+")"
       If mvpar19 == 1
          @li,101 PSAY nTot0		  Picture PesqPict("SE1","E1_VALOR",14,MVPAR15)
       Endif
       @li,116 PSAY nTot1		  Picture PesqPict("SE1","E1_SALDO",14,MVPAR15)
       @li,133 PSAY nTot2		  Picture PesqPict("SE1","E1_SALDO",14,MVPAR15)
       @li,149 PSAY nTot3		  Picture PesqPict("SE1","E1_SALDO",14,MVPAR15)
       @li,179 PSAY nTotJ		  Picture PesqPict("SE1","E1_JUROS",12,MVPAR15)
       @li,204 PSAY nTot2+nTot3 Picture PesqPict("SE1","E1_SALDO",16,MVPAR15)
       li++
       li++
Return .T.*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ImpMes130 ³ Autor ³ Vinicius Barreira	  ³ Data ³ 12.12.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³IMPRIMIR TOTAL DO RELATORIO - QUEBRA POR MES					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpMes130() 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
STATIC Function ImpMes130(nMesTot0,nMesTot1,nMesTot2,nMesTot3,nMesTot4,nMesTTit,nMesTotJ)
       li++
       IF li > 58
          nAtuSM0 := SM0->(Recno())
          SM0->(dbGoto(nRegSM0))
          cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
          SM0->(dbGoTo(nAtuSM0))
       EndIF
       @li,000 PSAY OemToAnsi("T O T A L   D O  M E S ---> ")
       @li,028 PSAY "("+ALLTRIM(STR(nMesTTit))+" "+IIF(nMesTTit > 1,OemToAnsi("TITULOS"),OemToAnsi("TITULO"))+")"
       If mvpar19 == 1
          @li,101 PSAY nMesTot0   Picture PesqPict("SE1","E1_VALOR",14,MVPAR15)
       Endif
       @li,116 PSAY nMesTot1	Picture PesqPict("SE1","E1_SALDO",14,MVPAR15)
       @li,133 PSAY nMesTot2	Picture PesqPict("SE1","E1_SALDO",14,MVPAR15)
       @li,149 PSAY nMesTot3	Picture PesqPict("SE1","E1_SALDO",14,MVPAR15)
       @li,179 PSAY nMesTotJ	Picture PesqPict("SE1","E1_JUROS",12,MVPAR15)
       @li,204 PSAY nMesTot2+nMesTot3 Picture PesqPict("SE1","E1_SALDO",16,MVPAR15)
       li+=2
Return(.T.)*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ImpFil130³ Autor ³ Paulo Boschetti  	  ³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprimir total do relatorio										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpFil130()																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³																				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	    ³ Generico																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
STATIC Function ImpFil130(nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFilTit,nTotFilJ)
       li++
       IF li > 58
          nAtuSM0 := SM0->(Recno())
          SM0->(dbGoto(nRegSM0))
          cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
          SM0->(dbGoTo(nAtuSM0))
       EndIF
       @li,000 PSAY OemToAnsi("T O T A L   F I L I A L ----> ")+" "+Iif(mvpar21==1,cFilAnt,"")
       If mvpar19 == 1
          @li,101 PSAY nTotFil0        Picture PesqPict("SE1","E1_VALOR",14,MVPAR15)
       Endif
       @li,116 PSAY nTotFil1          Picture PesqPict("SE1","E1_SALDO",14,MVPAR15)
       @li,133 PSAY nTotFil2          Picture PesqPict("SE1","E1_SALDO",14,MVPAR15)
       @li,149 PSAY nTotFil3          Picture PesqPict("SE1","E1_SALDO",14,MVPAR15)
       @li,179 PSAY nTotFilJ		  Picture PesqPict("SE1","E1_JUROS",12,MVPAR15)
       @li,204 PSAY nTotFil2+nTotFil3 Picture PesqPict("SE1","E1_SALDO",16,MVPAR15)
       li+=2
Return .T.*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fr130Indr ³ Autor ³ Wagner           	  ³ Data ³ 12.12.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Indregua para impressao do relat¢rio						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function fr130IndR()
       Local cString

       cString := 'E1_FILIAL=="'+xFilial("SE1")+'".And.'
       cString += 'E1_CLIENTE>="'+mvpar01+'".and.E1_CLIENTE<="'+mvpar02+'".And.'
       cString += 'E1_PREFIXO>="'+mvpar03+'".and.E1_PREFIXO<="'+mvpar04+'".And.'
       cString += 'E1_NUM>="'+mvpar05+'".and.E1_NUM<="'+mvpar06+'".And.'
       cString += 'DTOS(E1_VENCREA)>="'+DTOS(mvpar09)+'".and.DTOS(E1_VENCREA)<="'+DTOS(mvpar10)+'".And.'
       cString += '(E1_MULTNAT == "1" .OR. (E1_NATUREZ>="'+mvpar11+'".and.E1_NATUREZ<="'+mvpar12+'")).And.'
       cString += 'DTOS(E1_EMISSAO)>="'+DTOS(mvpar13)+'".and.DTOS(E1_EMISSAO)<="'+DTOS(mvpar14)+'"'
       If !Empty(mvpar31) // Deseja imprimir apenas os tipos do parametro 31
          cString += '.And.E1_TIPO$"'+mvpar31+'"'
       ElseIf !Empty(Mvpar32) // Deseja excluir os tipos do parametro 32
              cString += '.And.!(E1_TIPO$'+'"'+mvpar32+'")'
       EndIf
       IF mvpar34 == 1  // Apenas titulos que estarao no fluxo de caixa
          cString += '.And.(E1_FLUXO!="N")'	
       Endif
Return cString

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PutDtBase³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 18/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acerta parametro database do relatorio                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Finr130.prx                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//LGS#20200130 - Adequação para release 12.1.25 e posteriores
/*
Static Function PutDtBase()
       Local _sAlias	:= Alias()

       dbSelectArea("SX1")
       dbSetOrder(1)
       If MsSeek("FIN13036")
          //Acerto o parametro com a database
          RecLock("SX1",.F.)
             Replace x1_cnt01		With "'"+DTOC(dDataBase)+"'"
          MsUnlock()	
       Endif

     dbSelectArea(_sAlias)
Return*/

Static Function MEmail(cREMail)
       Local cRecebe   := cREMail
       Local cMensagem := ''
       Local xCRLF     := Chr(13)+Chr(10)

       cMensagem := Iif( Substr(Time(),1,5) >= '12:00' .and. Substr(Time(),1,5) <= '18:00', 'Boa Tarde !', Iif(Substr(Time(),1,5) >= '18:01' .and. Substr(Time(),1,5) <= '24:00','Boa Noite !', 'Bom dia !' ))+;
                    xCRLF+;
                    xCRLF+;
                    "Segue anexo arquivo com Posicao dos Titulos a Receber - Analitico - Por Vendedor. "+;
                    xCRLF

       cSubject  := "Posicao dos Titulos a Receber - Analitico - Por Vendedor"
       U_EnvMail(cSubject, cMensagem, cRecebe, "", cArqTxt1)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ VALPERG  º Autor ³ Luís Gustavo de Souza º Data ³ 10/07/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//LGS#20200130 - Adequação para release 12.1.25 e posteriores
/*
Static Function ValPerg()
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg,"01","Cliente             ","","","mv_ch1","C",06,0,0,"G","","mv_par01",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","CLI",""})
       aAdd(aRegs,{cPerg,"02","Representante       ","","","mv_ch2","C",06,0,0,"G","","mv_par02",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SA3",""})
       aAdd(aRegs,{cPerg,"03","Do prefixo          ","","","mv_ch3","C",03,0,0,"G","","mv_par03",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,""})
       aAdd(aRegs,{cPerg,"04","Ate o prefixo       ","","","mv_ch4","C",03,0,0,"G","","mv_par04",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,""})
       aAdd(aRegs,{cPerg,"05","Do vencimento       ","","","mv_ch5","D",08,0,0,"G","","mv_par05",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,""})
       aAdd(aRegs,{cPerg,"06","Até o vencimento    ","","","mv_ch6","D",08,0,0,"G","","mv_par06",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,""})
       aAdd(aRegs,{cPerg,"07","Da emissão          ","","","mv_ch7","D",08,0,0,"G","","mv_par07",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,""})
       aAdd(aRegs,{cPerg,"08","Até a emissão       ","","","mv_ch8","D",08,0,0,"G","","mv_par08",""   ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,""})
       aAdd(aRegs,{cPerg,"09","Envia e-mail        ","","","mv_ch9","N",01,0,0,"C","","mv_par09","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""   ,""})
       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i,2])
              RecLock("SX1",.T.)
              For j:=1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                 Endif
              Next
              MsUnlock()
           Endif
       Next

       dbSelectArea(_sAlias)
Return*/
