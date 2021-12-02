#INCLUDE "BRTMK002.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ BRTMK001 ³ Autor ³ Luís Gustavo de Souza ³ Data ³ 07/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ligacoes realizadas no atendimento de Televendas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Televendas (SUA)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Luis G.   ³07/07/04³  710 ³Conversão de programa para uso especifico. 2³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User  Function BRTMK002()
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Define Variaveis                                             ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      Local wnrel     := "BRTMK002"         // Nome do Arquivo utilizado no Spool
      Local Titulo    := STR0001            // "Ligacoes Realizadas - Televendas"
      Local cDesc1    := STR0002            // "Este programa ira emitir uma relacao das Ligacoes"
      Local cDesc2    := STR0003            // "realizadas pelo operador no atendimento Televendas"
      Local cDesc3    := STR0004            // "conforme os parametros previamente definidos"
      //Local nReg      := 0
      Local nomeprog  := "BRTMK002.PRW"     // nome do programa
      Local cString   := "SUA"              // Alias utilizado na Filtragem
      Local lDic      := .F.                // Habilita/Desabilita Dicionario
      Local lComp     := .F.                // Habilita/Desabilita o Formato Comprimido/Expandido
      Local lFiltro   := .T.                // Habilita/Desabilita o Filtro

      Private Tamanho := "G"                // P/M/G
      Private Limite  := 220                // 80/132/220
      Private aReturn := { STR0005 ,;       // [1] Reservado para Formulario	//"Zebrado"
                           1       ,;       // [2] Reservado para N§ de Vias
                           STR0006 ,;       // [3] Destinatario					//"Administracao"
                           2       ,;       // [4] Formato => 1-Comprimido 2-Normal	
                           2       ,;       // [5] Midia   => 1-Disco 2-Impressora
                           1       ,;       // [6] Porta ou Arquivo 1-LPT1... 4-COM1...
                           ""      ,;       // [7] Expressao do Filtro
                           1        }       // [8] Ordem a ser selecionada
                                            // [9]..[10]..[n] Campos a Processar (se houver)
      Private m_pag   := 1                  // Contador de Paginas
      Private nLastKey:= 0                  // Controla o cancelamento da SetPrint e SetDefault
      Private cPerg   := "BRTM02"           // Pergunta do Relatorio
      Private aOrdem  := {}        

     if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
        u_zcfga01( 'BRTMK002' ) //LGS#2021201 - Gravação de log de utilização da rotina
              // Ordem do Relatorio
      ValPerg()
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Verifica as perguntas selecionadas                           ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      Pergunte(cPerg,.F.)
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Variaveis utilizadas para parametros                          ³
      //³ Mv_Par01           // Do Operador                             ³
      //³ Mv_Par02           // Ate o Operador                          ³
      //³ Mv_Par03           // A Partir de                             ³
      //³ Mv_Par04           // Ate o dia                               ³
      //³ Mv_Par05           // Da Midia                                ³
      //³ Mv_Par06           // Ate a Midia                             ³
      //³ Mv_Par07           // Campanha         - Vazio entra tudo     ³
      //³ Mv_Par08           // Tipo da Entidade - SA1, SUS ou TODAS    ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)

      If (nLastKey == 27)
         DbSelectArea(cString)
         DbSetOrder(1)
         Set Filter to
         Return
      Endif
      SetDefault(aReturn,cString)
      If (nLastKey == 27)
         DbSelectArea(cString)
         DbSetOrder(1)
         Set Filter to
         Return
      Endif
      RptStatus({|lEnd| TK016Imp(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TK016Imp ³ Autor ³ Armando M. Tessaroli  ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atendimentos realizados no Televendas                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Televendas                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TK016Imp(lEnd,wnrel,cString,nomeprog,Titulo)
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Variaveis utilizadas para Impressao Do Cabecalho e Rodape    ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Local nLi         := 0                      // Linha a ser impressa
       Local nMax        := 58                     // Maximo de linhas suportada pelo relatorio
       Local cbCont      := 0                      // Numero de Registros Processados
       Local cbText      := SPACE(10)              // Mensagem do Rodape
       Local cCabec1     := ""                     // Label dos itens
       Local cCabec2     := ""                     // Label dos itens
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Declaracao de variaveis especificas para este relatorio³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Local cQuery      := ""                     // Guardfa a query para top
       Local dData       := ""                     // Para quebra de relatorio
       Local cCodSUA     := ""                     // Controla a quebra do cabecalho do atendimento
       //Local cCodSUB     := ""                     // Controla a quebra dos itens do atendimento
       Local nI          := 0                      // Controle
       Local nPos        := 0                      // Ponteiro da pesquisa no array
       Local aLinhas     := {}                     // Linha do campo memo
       Local aUA_Oper    := TkSx3Box("UA_OPER")    // Pesquisa as opcoes do campo no DD SX3
       //Local aUA_TMK     := TkSx3Box("UA_TMK")     // Pesquisa as opcoes do campo no DD SX3
       //Local aUA_TpFrete := TkSx3Box("UA_TPFRETE") // Pesquisa as opcoes do campo no DD SX3
       Local aValDia     := {}                     // Totaliza os valores do dia
       Local aValGer     := {}                     // Totaliza os valores em geral
       Local nTotDia     := 0                      // Total de atendimento do dia
       Local nTotGer     := 0                      // Total geral de atendimentos
       Local aCampDia    := {}                     // Total das campanhas por dia
       Local aCampGer    := {}                     // Total geral das campanhas
       Local aMidDia     := {}                     // Total das midias por dia
       Local aMidGer     := {}                     // Total geral das midias
       Local aValOper    := {}                     // Valor de faturamento por operador
       Local aProdMid    := {}                     // Produtos vendidos por midia
       Local cProduto    := ""                     // Controle de quebra por produto
       Local cCampos     := ""                     // Campos do alias principal para select
       Local aSetField   := {}                     // Parametros para SetField do alias principal
       Local cDesc       := ""                     // Armazena o resultado da pesquisa do seek
       Local lFechaDia   := .F.                    // Controla o fechamento por dia
       Local lIni        := .T.                    // Controle de quebra por data do relatorio

       DbSelectArea("SUA")
       DbSetOrder(4)
       SetRegua(RecCount())

       #IFDEF TOP
              TkSelect(cString, @cCampos, @aSetField)
              cQuery := " SELECT "+cCampos+;
                        " FROM "+RetSqlName("SUA")+" SUA "+;
                        " WHERE SUA.UA_FILIAL = '"+xFilial("SUA")+"' AND "+;
                        "       SUA.UA_EMISSAO BETWEEN '"+DtoS(Mv_Par03)+"' AND '"+DtoS(Mv_Par04)+"' AND"+;
                        "       SUA.UA_OPERADO BETWEEN '"+Mv_Par01+"' AND '"+Mv_Par02+"' AND"+;
                        "       SUA.UA_MIDIA   BETWEEN '"+Mv_Par05+"' AND '"+Mv_Par06+"' AND"+;
                        "       SUA.UA_CANC = '' AND"+;
                        "       SUA.UA_TMK  = '2' AND " // Ativo
              
              //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
              //³Seleciono somente a campanha informada nos parametros³
              //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              If !Empty(Mv_Par07)
                 cQuery +=	"       SUA.UA_CODCAMP = '"+Mv_Par07+"' AND"
              Endif
              //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
              //³Seleciono somente o tipo de entidade dos parametros³
              //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              If Mv_Par08 <> 3		// Ambos
                 If Mv_Par08 == 1	// Clientes
                    cQuery += "       SUA.UA_PROSPEC = 'F' AND"
                 Else				// Prospects
                    cQuery += "       SUA.UA_PROSPEC = 'T' AND"
                 Endif
              Endif
              cQuery += "       SUA.D_E_L_E_T_ = ' '"
              cQuery += " ORDER BY "+SqlOrder(IndexKey())

              DbSelectArea("SUA")
              DbCloseArea()
              cQuery := ChangeQuery(cQuery)
              // MemoWrite("TMKR016.SQL", cQuery)
              DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUA', .F., .T.)

              For nI := 1 To Len(aSetField)
                  If aSetField[nI][2] $ "NDL"
                     TCSetField(cString, aSetField[nI][1], aSetField[nI][2], aSetField[nI][3], aSetField[nI][4])
                  Endif
              Next nI
       #ELSE
           MsSeek(xFilial("SUA") + DtoS(Mv_Par03), .T.)
       #ENDIF

       While (!Eof())                          .AND.;
             SUA->UA_FILIAL  == xFilial("SUA") .AND.;
             SUA->UA_EMISSAO >= Mv_Par03       .AND.;
             SUA->UA_EMISSAO <= Mv_Par04
             IncRegua()
             If lEnd
                @Prow()+1,001 PSay STR0007 //"CANCELADO PELO OPERADOR"
                Exit
             Endif
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Considera filtro do usuario                                  ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If (!Empty(aReturn[7])) .AND. (!&(aReturn[7]))
                DbSkip()
                Loop
             Endif
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³Avalia os parametros para DBF³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             #IFNDEF TOP
                     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     //³Seleciona somente os atendimentos Ativos    ³
                     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                     If SUA->UA_TMK <> "2"
                        DbSkip()
                        Loop
                     Endif
                     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     //³Valida o intervalo de operadores informado nos parametros³
                     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                     If SUA->UA_OPERADO < Mv_Par01 .OR. SUA->UA_OPERADO > Mv_Par02
                        DbSkip()
                        Loop
                     Endif
                     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     //³Valida o intervalo de midias informado nos parametros³
                     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                     If SUA->UA_MIDIA < Mv_Par05 .OR. SUA->UA_MIDIA > Mv_Par06
                        DbSkip()
                        Loop
                     Endif
                     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     //³Seleciono somente a campanha informada nos parametros³
                     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                     If !Empty(Mv_Par07) .AND. SUA->UA_CODCAMP <> Mv_Par07
                        DbSkip()
                        Loop
                     Endif
                     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     //³Seleciono somente o tipo de entidade dos parametros³
                     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                     Do Case
                        // Se o parametro = cliente e atendimento = prospect  <<pula>>
                        Case MV_PAR08 == 1 .AND. SUA->UA_PROSPEC
                             DbSkip()
                             Loop
                             // Se o parametro = prospect e atendimento <> prospect  <<pula>>
                        Case MV_PAR08 == 2 .AND. !SUA->UA_PROSPEC
                             DbSkip()
                             Loop
                     EndCase
                     If SUA->UA_CANC == "S"
                        DbSkip()
                        Loop
                     Endif
             #ENDIF

             If lIni
                dData := SUA->UA_EMISSAO
                lIni := .F.
             Endif
             If SUA->UA_EMISSAO <> dData
                lFechaDia := .T.
                TkIncLine(@nLi,3,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                @ nLi,000 PSay __PrtFatLine()

                aSort(aValDia,,, {|x,y| x[1] < y[1]} )		// Coloca em ordem Crescente
                For nI := 1 To Len(aValDia)
                    TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                    @ nLi,000		PSay PadR(STR0032 + IIF(Val(aValDia[nI][1])>0,aUA_Oper[Val(aValDia[nI][1])],STR0042),80) //"Valor total negociado em REAIS para " //" os atendimentos"
                    @ nLi,PCol()+5	PSay aValDia[nI][2] Picture '@E 999,999,999.99'
                Next nI
                TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                @ nLi,000 PSay __PrtFatLine()
                TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                @ nLi,000		PSay PadR(STR0033 + DtoC(dData),80) //"Total de atendimentos realizados no dia "
                @ nLi,PCol()+5	PSay nTotDia Picture '@E 99,999,999,999'
                @ nLi,PCol()+5	PSay " --> 100,00 %"
                aSort(aCampDia,,, {|x,y| x[1] < y[1]} )		// Coloca em ordem Crescente
                For nI := 1 To Len(aCampDia)
                    If !Empty(aCampDia[nI][1])
                        DbSelectArea("SUO")
                        DbSetOrder(1)
                        If MsSeek(xFilial("SUO") + aCampDia[nI][1])
                           cDesc := SUO->UO_DESC
                        Else
                           cDesc := STR0045 //"Não Localizado no cadastro..."
                        Endif
                    Else
                       cDesc := STR0046 //"Não Informado no atendimento..."
                    Endif
                    TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                    @ nLi,000		PSay PadR(STR0034 + aCampDia[nI][1] + " - "  + cDesc,80) //"Total de atendimentos na campanha "
                    @ nLi,PCol()+5	PSay aCampDia[nI][2] Picture '@E 99,999,999,999'
                    @ nLi,PCol()+5	PSay " --> " + Transform((aCampDia[nI][2]/nTotDia*100), '@E 999.99') + " %"
                Next nI
                aSort(aMidDia,,, {|x,y| x[1] < y[1]} )		// Coloca em ordem Crescente
                For nI := 1 To Len(aMidDia)
                    If !Empty(aMidDia[nI][1])
                       DbSelectArea("SUH")
                       DbSetOrder(1)
                       If MsSeek(xFilial("SUH") + aMidDia[nI][1])
                          cDesc := SUH->UH_DESC
                       Else
                          cDesc := STR0045 //"Não Localizado no cadastro..."
                       Endif
                    Else
                       cDesc := STR0046 //"Não Informado no atendimento..."
                    Endif
                    TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                    @ nLi,000		PSay PadR(STR0035 + aMidDia[nI][1] + " - "  + cDesc,80) //"Total de atendimentos na midia "
                    @ nLi,PCol()+5	PSay aMidDia[nI][2] Picture '@E 99,999,999,999'
                    @ nLi,PCol()+5	PSay " --> " + Transform((aMidDia[nI][2]/nTotDia*100), '@E 999.99') + " %"
                Next nI
                TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                @ nLi,000 PSay __PrtFatLine()
                aValDia		:= {}
                nTotDia		:= 0
                aCampDia	:= {}
                aMidDia		:= {}
                TkIncLine(@nLi,nMax+1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                DbSelectArea("SUA")
                dData := SUA->UA_EMISSAO
             Else
                lFechaDia := .F.
             Endif
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³Quebra de atendimento ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If SUA->UA_NUM <> cCodSUA
                cCodSUA := SUA->UA_NUM
                TkIncLine(@nLi,2,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                @ nLi,000		PSay __PrtFatLine()
                TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                @ nLi,000		PSay PadR(STR0008,25) //"Data do Atendimento"
                @ nLi,PCol()+1	PSay PadR(DtoC(SUA->UA_EMISSAO),80)
                @ nLi,Limite/2	PSay PadR(STR0009,25) //"Codigo do Atendimento"
                @ nLi,PCol()+1	PSay PadR(SUA->UA_NUM,80)
                If !Empty(SUA->UA_CLIENTE) .AND. !Empty(SUA->UA_LOJA)
                   DbSelectArea("SA1")
                   DbSetOrder(1)
                   If MsSeek(xFilial("SA1") + SUA->UA_CLIENTE + SUA->UA_LOJA)
                      cDesc := SA1->A1_NOME
                   Else
                      cDesc := STR0045 //"Não Localizado no cadastro..."
                   Endif
                Else
                   cDesc := STR0046 //"Não Informado no atendimento..."
                Endif
                TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                @ nLi,000		PSay PadR(STR0010,25) //"Codigo Cliente/Loja"
                @ nLi,PCol()+1	PSay PadR(SUA->UA_CLIENTE + " / " + SUA->UA_LOJA,80)
                @ nLi,Limite/2	PSay PadR(STR0011,25) //"Razao Social"
                @ nLi,PCol()+1	PSay PadR(cDesc,80)
                If !Empty(SUA->UA_CODCONT)
                   DbSelectArea("SU5")
                   DbSetOrder(1)
                   If MsSeek(xFilial("SU5") + SUA->UA_CODCONT)
                      cDesc := SU5->U5_CONTAT
                   Else
                      cDesc := STR0045 //"Não Localizado no cadastro..."
                   Endif
                Else
                   cDesc := STR0046 //"Não Informado no atendimento..."
                Endif
                TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                @ nLi,000		PSay PadR(STR0012,25) //"Codigo do Contato"
                @ nLi,PCol()+1	PSay PadR(SUA->UA_CODCONT,80)
                @ nLi,Limite/2	PSay PadR(STR0013,25) //"Nome do Contato"
                @ nLi,PCol()+1	PSay PadR(cDesc,80)
                TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                //@ nLi,000		PSay PadR(STR0014,25) //"Tipo de Marketing"
                //@ nLi,PCol()+1	PSay PadR(IIF(Val(SUA->UA_TMK)>0,aUA_TMK[Val(SUA->UA_TMK)],""),80)
                //@ nLi,Limite/2	PSay PadR(STR0015,25) //"Operacao"
                //@ nLi,PCol()+1	PSay PadR(IIF(Val(SUA->UA_OPER)>0,aUA_Oper[Val(SUA->UA_OPER)],""),80)
                //TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                //@ nLi,000		PSay PadR(STR0016,25) //"Tipo de Frete"
                //@ nLi,PCol()+1	PSay PadR(IIF(Val(SUA->UA_TPFRETE)>0,aUA_TpFrete[Val(SUA->UA_TPFRETE)],""),80)
                //@ nLi,Limite/2	PSay PadR(STR0017,25) //"Tabela de Preco"
                //@ nLi,PCol()+1	PSay PadR(SUA->UA_TABELA,80)
                If !Empty(SUA->UA_OPERADO)
                   DbSelectArea("SU7")
                   DbSetOrder(1)
                   If MsSeek(xFilial("SU7") + SUA->UA_OPERADO)
                      cDesc := SU7->U7_NOME
                   Else
                      cDesc := STR0045 //"Não Localizado no cadastro..."
                   Endif
                Else
                   cDesc := STR0046 //"Não Informado no atendimento..."
                Endif
                //TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                @ nLi,000		PSay PadR(STR0018,25) //"Codigo do Operador"
                @ nLi,PCol()+1	PSay PadR(SUA->UA_OPERADO,80)
                @ nLi,Limite/2	PSay PadR(STR0019,25) //"Nome do Operador"
                @ nLi,PCol()+1	PSay PadR(cDesc,80)
                If !Empty(SUA->UA_VEND)
                   DbSelectArea("SA3")
                   DbSetOrder(1)
                   If MsSeek(xFilial("SA3") + SUA->UA_VEND)
                      cDesc := SA3->A3_NOME
                   Else
                      cDesc := STR0045 //"Não Localizado no cadastro..."
                   Endif
                Else
                   cDesc := STR0046 //"Não Informado no atendimento..."
                Endif
                TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                @ nLi,000		PSay PadR(STR0020,25) //"Codigo do Vendedor"
                @ nLi,PCol()+1	PSay PadR(SUA->UA_VEND,80)
                @ nLi,Limite/2	PSay PadR(STR0021,25) //"Nome do Vendedor"
                @ nLi,PCol()+1	PSay PadR(cDesc,80)
                //If !Empty(SUA->UA_MIDIA)
                //   DbSelectArea("SUH")
                //   DbSetOrder(1)
                //   If MsSeek(xFilial("SUH") + SUA->UA_MIDIA)
                //      cDesc := SUH->UH_DESC
                //   Else
                //      cDesc := STR0045 //"Não Localizado no cadastro..."
                //   Endif
                //Else
                //   cDesc := STR0046 //"Não Informado no atendimento..."
                //Endif
                //TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                //@ nLi,000		PSay PadR(STR0022,25) //"Codigo da Midia"
                //@ nLi,PCol()+1	PSay PadR(SUA->UA_MIDIA,80)
                //@ nLi,Limite/2	PSay PadR(STR0023,25) //"Descricao da Midia"
                //@ nLi,PCol()+1	PSay PadR(cDesc,80)
                //If !Empty(SUA->UA_CODCAMP)
                //   DbSelectArea("SUO")
                //   DbSetOrder(1)
                //   If MsSeek(xFilial("SUO") + SUA->UA_CODCAMP)
                //      cDesc := SUO->UO_DESC
                //   Else
                //      cDesc := STR0045 //"Não Localizado no cadastro..."
                //   Endif
                //Else
                //   cDesc := STR0046 //"Não Informado no atendimento..."
                //Endif
                //TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                //@ nLi,000		PSay PadR(STR0024,25) //"Codigo da Campanha"
                //@ nLi,PCol()+1	PSay PadR(SUA->UA_CODCAMP,80)
                //@ nLi,Limite/2	PSay PadR(STR0025,25) //"Descricao da Campanha"
                //@ nLi,PCol()+1	PSay PadR(cDesc,80)
                //If !Empty(SUA->UA_CODLIG)
                //   DbSelectArea("SU9")
                //   DbSetOrder(2)    	// Codigo da Ocorrencia
                //   If MsSeek(xFilial("SU9") + SUA->UA_CODLIG)
                //      cDesc := SU9->U9_DESC
                //   Else
                //      cDesc := STR0045 //"Não Localizado no cadastro..."
                //   Endif
                //Else
                //   cDesc := STR0046 //"Não Informado no atendimento..."
                //Endif
                //TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                //@ nLi,000		PSay PadR(STR0026,25) //"Codigo da Ocorrencia"
                //@ nLi,PCol()+1	PSay PadR(SUA->UA_CODLIG,80)
                //@ nLi,Limite/2	PSay PadR(STR0027,25) //"Descricao da Ocorrencia"
                //@ nLi,PCol()+1	PSay PadR(cDesc,80)
                //TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                //@ nLi,000		PSay PadR(STR0028,25) //"Data de Retorno"
                //@ nLi,PCol()+1	PSay PadR(DtoC(SUA->UA_PROXLIG),80)
                //@ nLi,Limite/2	PSay PadR(STR0029,25) //"Hora de Retorno"
                //@ nLi,PCol()+1	PSay PadR(SUA->UA_HRPEND,80)
                aLinhas := TkMemo(SUA->UA_CODOBS, 83)
                If Len(aLinhas) > 0
                   For nI := 1 to Len(aLinhas)
                       TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                       If nI == 1
                          @ nLi,000         PSay PadR(STR0030,25) //"Observacao"
                       Endif
                       @ nLi,26 PSay aLinhas[nI]
                       If nI == 1
                          @ nLi,Limite/2	PSay PadR(STR0047,25)
                          @ nLi,PCol()+1   PSay PadR(Posicione("SA1", 1, xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA, "A1_CODCID")+" - "+Posicione("SA1", 1, xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA, "A1_MUN"),80)
                       Endif
                   Next nI
                Else
                Endif
                TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                @ nLi,000 PSay __PrtThinLine()
                TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                @ nLi,000		PSay PadR(STR0031, Limite) //"Item Produto         Descricao                      St   Qtdade    Vl.Unitario        Vl.Item  %Desc    Vl.Desconto  %Acres   Vl.Acrescimo TES CFOP      Tabela      Base ICMS LP UM Entrega    Lote       Sub-Lt Validade"
                TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                @ nLi,000 PSay __PrtThinLine()
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³Totaliza os atendimentos em geral e totaliza por campanha e midia.  ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                nTotDia++
                nTotGer++
                nPos := aScan(aCampDia, {|x| x[1]==SUA->UA_CODCAMP} )
                If nPos == 0
                   aAdd(aCampDia, {SUA->UA_CODCAMP, 1} )
                Else
                   aCampDia[nPos][2]++
                Endif
                nPos := aScan(aCampGer, {|x| x[1]==SUA->UA_CODCAMP} )
                If nPos == 0
                   aAdd(aCampGer, {SUA->UA_CODCAMP, 1} )
                Else
                   aCampGer[nPos][2]++
                Endif
                nPos := aScan(aMidDia, {|x| x[1]==SUA->UA_MIDIA} )
                If nPos == 0
                   aAdd(aMidDia, {SUA->UA_MIDIA, 1} )
                Else
                   aMidDia[nPos][2]++
                Endif
                nPos := aScan(aMidGer, {|x| x[1]==SUA->UA_MIDIA} )
                If nPos == 0
                   aAdd(aMidGer, {SUA->UA_MIDIA, 1} )
                Else
                   aMidGer[nPos][2]++
                Endif
             Endif
             DbSelectArea("SUB")
             DbSetOrder(1)
             MsSeek(xFilial("SUB") + SUA->UA_NUM)
             While (!Eof())							.AND.;
                    SUB->UB_FILIAL	==	xFilial("SUB")	.AND.;
                    SUB->UB_NUM		==	SUA->UA_NUM
                    If !Empty(SUB->UB_PRODUTO)
                       DbSelectArea("SB1")
                       DbSetOrder(1)
                       If MsSeek(xFilial("SB1") + SUB->UB_PRODUTO)
                          cDesc := SB1->B1_DESC
                       Else
                          cDesc := STR0045 //"Não Localizado no cadastro..."
                       Endif
                    Else
                       cDesc := STR0046 //"Não Informado no atendimento..."
                    Endif
                    TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                    @ nLi,000		PSay PadR(SUB->UB_ITEM,4)
                    @ nLi,PCol()+1	PSay PadR(SUB->UB_PRODUTO,15)
                    @ nLi,PCol()+1	PSay PadR(cDesc,30)
                    @ nLi,PCol()+1	PSay PadR(SUB->UB_SITPROD,2)
                    @ nLi,PCol()+1	PSay PadR(Transform(SUB->UB_QUANT, '@E 99999.99'),8)
                    @ nLi,PCol()+1	PSay PadR(Transform(SUB->UB_VRUNIT, '@E 999,999,999.99'),14)
                    @ nLi,PCol()+1	PSay PadR(Transform(SUB->UB_VLRITEM, '@E 999,999,999.99'),14)
                    @ nLi,PCol()+1	PSay PadR(Transform(SUB->UB_DESC, '@E 999.99'),6)
                    @ nLi,PCol()+1	PSay PadR(Transform(SUB->UB_VALDESC, '@E 999,999,999.99'),14)
                    @ nLi,PCol()+2	PSay PadR(Transform(SUB->UB_ACRE, '@E 999.99'),6)
                    @ nLi,PCol()+1	PSay PadR(Transform(SUB->UB_VALACRE, '@E 999,999,999.99'),14)
                    @ nLi,PCol()+1	PSay PadR(SUB->UB_TES,3)
                    @ nLi,PCol()+1	PSay PadR(SUB->UB_CF,5)
                    @ nLi,PCol()+1	PSay PadR(Transform(SUB->UB_PRCTAB, '@E 999,999.99'),10)
                    @ nLi,PCol()+1	PSay PadR(Transform(SUB->UB_BASEICM, '@E 999,999,999.99'),14)
                    @ nLi,PCol()+1	PSay PadR(SUB->UB_LOCAL,2)
                    @ nLi,PCol()+1	PSay PadR(SUB->UB_UM,2)
                    @ nLi,PCol()+1	PSay PadR(SUB->UB_DTENTRE,10)
                    @ nLi,PCol()+1	PSay PadR(SUB->UB_LOTE,10)
                    @ nLi,PCol()+1	PSay PadR(SUB->UB_SUBLOTE,6)
                    @ nLi,PCol()+1	PSay PadR(SUB->UB_DTVALID,10)
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³Valor total em dinheiro dos Atendimentos, Orcamentos e Faturamentos.³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    nPos := aScan(aValDia, {|x| x[1]==SUA->UA_OPER} )
                    If nPos == 0
                       aAdd(aValDia, {SUA->UA_OPER, SUB->UB_VLRITEM} )
                    Else
                       aValDia[nPos][2]+=SUB->UB_VLRITEM
                    Endif
                    nPos := aScan(aValGer, {|x| x[1]==SUA->UA_OPER} )
                    If nPos == 0
                       aAdd(aValGer, {SUA->UA_OPER, SUB->UB_VLRITEM} )
                    Else
                       aValGer[nPos][2]+=SUB->UB_VLRITEM
                    Endif
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³Valor total em dinheiro dos faturamentos realizados por operador.   ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    If SUA->UA_OPER == "1"		// Faturamento
                       nPos := aScan(aValOper, {|x| x[1]==SUA->UA_OPERADO} )
                       If nPos == 0
                          aAdd(aValOper, {SUA->UA_OPERADO, SUB->UB_VLRITEM} )
                       Else
                          aValOper[nPos][2]+=SUB->UB_VLRITEM
                       Endif
                    Endif
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³Quantidade total de cada produto vendido dentro de cada campanha.   ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    If SUA->UA_OPER == "1"		// Faturamento
                       nPos := aScan(aProdMid, {|x,y| x[1]==SUB->UB_PRODUTO .AND. x[2]==SUA->UA_MIDIA} )
                       If nPos == 0
                          aAdd(aProdMid, {SUB->UB_PRODUTO, SUA->UA_MIDIA, SUB->UB_QUANT} )
                       Else
                          aProdMid[nPos][3]+=SUB->UB_QUANT
                       Endif
                    Endif
                    DbSelectArea("SUB")
                    DbSkip()
             End
             DbSelectArea("SUA")
             DbSkip()
       End
       If !lFechaDia .AND. nTotDia > 0
          TkIncLine(@nLi,3,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
          @ nLi,000 PSay __PrtFatLine()
          aSort(aValDia,,, {|x,y| x[1] < y[1]} )		// Coloca em ordem Crescente
          For nI := 1 To Len(aValDia)
              TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
              @ nLi,000		PSay PadR(STR0032 + IIF(Val(aValDia[nI][1])>0,aUA_Oper[Val(aValDia[nI][1])],STR0042),80) //"Valor total negociado em REAIS para " //" os atendimentos"
              @ nLi,PCol()+5	PSay aValDia[nI][2] Picture '@E 999,999,999.99'
          Next nI
          TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
          @ nLi,000 PSay __PrtFatLine()
          TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
          @ nLi,000		PSay PadR(STR0033 + DtoC(dData),80) //"Total de atendimentos realizados no dia "
          @ nLi,PCol()+5	PSay nTotDia Picture '@E 99,999,999,999'
          @ nLi,PCol()+5	PSay " --> 100,00 %"
          aSort(aCampDia,,, {|x,y| x[1] < y[1]} )		// Coloca em ordem Crescente
          For nI := 1 To Len(aCampDia)
              If !Empty(aCampDia[nI][1])
                 DbSelectArea("SUO")
                 DbSetOrder(1)
                 If MsSeek(xFilial("SUO") + aCampDia[nI][1])
                    cDesc := SUO->UO_DESC
                 Else
                    cDesc := STR0045 //"Não Localizado no cadastro..."
                 Endif
              Else
                 cDesc := STR0046 //"Não Informado no atendimento..."
              Endif
              TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
              @ nLi,000		PSay PadR(STR0034 + aCampDia[nI][1] + " - "  + cDesc,80) //"Total de atendimentos na campanha "
              @ nLi,PCol()+5	PSay aCampDia[nI][2] Picture '@E 99,999,999,999'
              @ nLi,PCol()+5	PSay " --> " + Transform((aCampDia[nI][2]/nTotDia*100), '@E 999.99') + " %"
          Next nI
          aSort(aMidDia,,, {|x,y| x[1] < y[1]} )		// Coloca em ordem Crescente
          For nI := 1 To Len(aMidDia)
              If !Empty(aMidDia[nI][1])
                 DbSelectArea("SUH")
                 DbSetOrder(1)
                 If MsSeek(xFilial("SUH") + aMidDia[nI][1])
                    cDesc := SUH->UH_DESC
                 Else
                    cDesc := STR0045 //"Não Localizado no cadastro..."
                 Endif
              Else
                 cDesc := STR0046 //"Não Informado no atendimento..."
              Endif
              TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
              @ nLi,000		PSay PadR(STR0035 + aMidDia[nI][1] + " - "  + cDesc,80) //"Total de atendimentos na midia "
              @ nLi,PCol()+5	PSay aMidDia[nI][2] Picture '@E 99,999,999,999'
              @ nLi,PCol()+5	PSay " --> " + Transform((aMidDia[nI][2]/nTotDia*100), '@E 999.99') + " %"
          Next nI
          TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
          @ nLi,000 PSay __PrtFatLine()
          aValDia		:= {}
          nTotDia		:= 0
          aCampDia	:= {}
          aMidDia		:= {}
          TkIncLine(@nLi,nMax+1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
          DbSelectArea("SUA")
          dData := SUA->UA_EMISSAO
       Endif
       If nTotGer > 0
          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //³Totais gerais da ultima pagina igual aos totais diarios³
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          TkIncLine(@nLi,3,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
          @ nLi,000 PSay __PrtFatLine()
          aSort(aValGer,,, {|x,y| x[1] < y[1]} )		// Coloca em ordem Crescente
          For nI := 1 To Len(aValGer)
              TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
               @ nLi,000		PSay PadR(STR0032 + IIF(Val(aValGer[nI][1])>0,aUA_Oper[Val(aValGer[nI][1])],STR0042),80) //"Valor total negociado em REAIS para " //" os atendimentos"
               @ nLi,PCol()+5	PSay aValGer[nI][2] Picture '@E 999,999,999.99'
          Next nI
          TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
          @ nLi,000 PSay __PrtFatLine()
          TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
          @ nLi,000		PSay PadR(STR0036 + DtoC(Mv_Par03) + STR0043 + DtoC(Mv_Par04),80) //"Total de atendimentos realizados no periodo de " //" a "
          @ nLi,PCol()+5	PSay nTotGer Picture '@E 99,999,999,999'
          @ nLi,PCol()+5	PSay " --> 100,00 %"
          aSort(aCampGer,,, {|x,y| x[1] < y[1]} )		// Coloca em ordem Crescente
          For nI := 1 To Len(aCampGer)
              If !Empty(aCampGer[nI][1])
                 DbSelectArea("SUO")
                 DbSetOrder(1)
                 If MsSeek(xFilial("SUO") + aCampGer[nI][1])
                    cDesc := SUO->UO_DESC
                 Else
                    cDesc := STR0045 //"Não Localizado no cadastro..."
                 Endif
              Else
                 cDesc := STR0046 //"Não Informado no atendimento..."
              Endif
              TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
              @ nLi,000		PSay PadR(STR0034 + aCampGer[nI][1] + " - "  + cDesc,80) //"Total de atendimentos na campanha "
              @ nLi,PCol()+5	PSay aCampGer[nI][2] Picture '@E 99,999,999,999'
              @ nLi,PCol()+5	PSay " --> " + Transform((aCampGer[nI][2]/nTotGer*100), '@E 999.99') + " %"
          Next nI
          aSort(aMidGer,,, {|x,y| x[1] < y[1]} )		// Coloca em ordem Crescente
          For nI := 1 To Len(aMidGer)
              If !Empty(aMidGer[nI][1])
                 DbSelectArea("SUH")
                 DbSetOrder(1)
                 If MsSeek(xFilial("SUH") + aMidGer[nI][1])
                    cDesc := SUH->UH_DESC
                 Else
                    cDesc := STR0045 //"Não Localizado no cadastro..."
                 Endif
              Else
                 cDesc := STR0046 //"Não Informado no atendimento..."
              Endif
              TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
              @ nLi,000		PSay PadR(STR0035 + aMidGer[nI][1] + " - "  + cDesc,80) //"Total de atendimentos na midia "
              @ nLi,PCol()+5	PSay aMidGer[nI][2] Picture '@E 99,999,999,999'
              @ nLi,PCol()+5	PSay " --> " + Transform((aMidGer[nI][2]/nTotGer*100), '@E 999.99') + " %"
          Next nI
          TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
          @ nLi,000 PSay __PrtFatLine()
          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //³Total geral de faturamento por operador³
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          If Len(aValOper) > 0
             TkIncLine(@nLi,nMax+1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
             @ nLi,000 PSay __PrtFatLine()
             TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
             @ nLi,080 PSay PadR(STR0037,60) //"Valor total em REAIS de faturamento realizado por operador"
             TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
             @ nLi,000 PSay __PrtFatLine()
             aSort(aValOper,,, {|x,y| x[2] > y[2]} )		// Coloca em ordem Decrescente
             For nI := 1 To Len(aValOper)
                 If !Empty(aValOper[nI][1])
                    DbSelectArea("SU7")
                    DbSetOrder(1)
                    If MsSeek(xFilial("SU7") + aValOper[nI][1])
                       cDesc := SU7->U7_NOME
                    Else
                       cDesc := STR0045 //"Não Localizado no cadastro..."
                    Endif
                 Else
                    cDesc := STR0046 //"Não Informado no atendimento..."
                 Endif
                 TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                 @ nLi,000		PSay PadR(STR0038 + aValOper[nI][1] + " - "  + cDesc,80) //"Valor total faturado pelo operador "
                 @ nLi,PCol()+5	PSay aValOper[nI][2] Picture '@E 999,999,999.99'
             Next nI
             TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
             @ nLi,000 PSay __PrtFatLine()
          Endif
          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //³Quantidade de produtos vendidos por midia   ³
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          If Len(aProdMid) > 0
             TkIncLine(@nLi,nMax+1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
             @ nLi,000 PSay __PrtFatLine()
             TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
             @ nLi,080 PSay PadR(STR0044,60) //"Quantidade de Produtos vendidos por Midia"
             TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
             @ nLi,000 PSay __PrtFatLine()
             aSort(aProdMid,,, {|x,y| x[1] < y[1]} )		// Coloca em ordem Crescente
             For nI := 1 To Len(aProdMid)
                 TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
                 If cProduto <> aProdMid[nI][1]
                    cProduto := aProdMid[nI][1]
                    If !Empty(aProdMid[nI][1])
                       DbSelectArea("SB1")
                       DbSetOrder(1)
                       If MsSeek(xFilial("SB1") + aProdMid[nI][1])
                          cDesc := SB1->B1_DESC
                       Else
                          cDesc := PadR(STR0045,30) //"Não Localizado no cadastro..."
                       Endif
                    Else
                       cDesc := PadR(STR0046,30) //"Não Informado no atendimento..."
                    Endif
                    @ nLi,000		PSay PadR(STR0039 + aProdMid[nI][1] + "-" + cDesc + STR0040,64)	 	//"Produto "###" na Mídia "
                    If !Empty(aProdMid[nI][2])
                       DbSelectArea("SUH")
                       DbSetOrder(1)
                       If MsSeek(xFilial("SUH") + aProdMid[nI][2])
                          cDesc := SUH->UH_DESC
                       Else
                          cDesc := STR0045 //"Não Localizado no cadastro..."
                       Endif
                    Else
                       cDesc := STR0046 //"Não Informado no atendimento..."
                    Endif
                    @ nLi,PCol()	PSay PadR(aProdMid[nI][2] + "-" + cDesc,36)
                 Else
                    If !Empty(aProdMid[nI][2])
                       DbSelectArea("SUH")
                       DbSetOrder(1)
                       If MsSeek(xFilial("SUH") + aProdMid[nI][2])
                          cDesc := SUH->UH_DESC
                       Else
                          cDesc := STR0045 //"Não Localizado no cadastro..."
                       Endif
                    Else
                       cDesc := STR0046 //"Não Informado no atendimento..."
                    Endif
                    @ nLi,000		PSay PadR(Space(64) + aProdMid[nI][2] + "-" + cDesc,100)
                 Endif
                 @ nLi,PCol()+5	PSay aProdMid[nI][3] Picture '@E 99,999,999,999'
             Next nI
             TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
             @ nLi,000 PSay __PrtFatLine()
          Endif
       Endif
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Caso nada tenha sido impresso, entao imprime uma menssagem de aviso³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If nLi == 0
          TkIncLine(@nLi,nMax+1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
          @ nLi,000 PSay STR0041 //"Nao existem dados a serem impressos para este relatorio com os parametros informados"
       Endif
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Imprime o rodape do relatorio³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Roda(cbCont,cbText,Tamanho)
       #IFDEF TOP
              DbSelectArea("SUA")
              DbCloseArea()
              ChkFile("SUA")
       #ENDIF
       Set Device To Screen
       If ( aReturn[5] = 1 )
          Set Printer To
          dbCommitAll()
          OurSpool(wnrel)
       Endif
       MS_FLUSH()
Return(.T.)

/********************************************************************/
/*** VALPERG - Monta as perguntas na tabela SX1                   ***/
/********************************************************************/
Static Function ValPerg()
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aadd(aRegs, {cPerg, '01', 'Do Operador ?         ', '¿De Operador?         ', 'From Operator ?       ', 'mv_ch1', 'C', 6, 0, 0, 'G', '        ', 'mv_par01', '        ', '        ', '         ', '000029    ', ' ', '         ', '         ', '         ', ' ', ' ', '     ', '     ', '    ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'SU7', 'S', ' ', ' ' } )
       aadd(aRegs, {cPerg, '02', 'Até o Operador ?      ', '¿A  Operador?         ', 'To Operator ?         ', 'mv_ch2', 'C', 6, 0, 0, 'G', 'naovazio', 'mv_par02', '        ', '        ', '         ', '000029    ', ' ', '         ', '         ', '         ', ' ', ' ', '     ', '     ', '    ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'SU7', 'S', ' ', ' ' } )
       aadd(aRegs, {cPerg, '03', 'A Partir de ?         ', '¿De Dia?              ', 'From ?                ', 'mv_ch3', 'D', 8, 0, 0, 'G', 'naovazio', 'mv_par03', '        ', '        ', '         ', '"01/04/04"', ' ', '         ', '         ', '         ', ' ', ' ', '     ', '     ', '    ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '   ', 'S', ' ', ' ' } )
       aadd(aRegs, {cPerg, '04', 'Até o dia ?           ', '¿A  Dia?              ', 'To Day ?              ', 'mv_ch4', 'D', 8, 0, 0, 'G', 'naovazio', 'mv_par04', '        ', '        ', '         ', '"20/04/04"', ' ', '         ', '         ', '         ', ' ', ' ', '     ', '     ', '    ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '   ', 'S', ' ', ' ' } )
       aadd(aRegs, {cPerg, '05', 'Da Midia ?            ', '¿De Media?            ', 'From Media ?          ', 'mv_ch5', 'C', 6, 0, 0, 'G', '        ', 'mv_par05', '        ', '        ', '         ', '          ', ' ', '         ', '         ', '         ', ' ', ' ', '     ', '     ', '    ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'SUH', 'S', ' ', ' ' } )
       aadd(aRegs, {cPerg, '06', 'Até a Midia ?         ', '¿A  Media?            ', 'To Media ?            ', 'mv_ch6', 'C', 6, 0, 0, 'G', 'naovazio', 'mv_par06', '        ', '        ', '         ', 'ZZZZZZ    ', ' ', '         ', '         ', '         ', ' ', ' ', '     ', '     ', '    ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'SUH', 'S', ' ', ' ' } )
       aadd(aRegs, {cPerg, '07', 'Campanha ?            ', '¿Campaña?             ', 'Campaign ?            ', 'mv_ch7', 'C', 6, 0, 0, 'G', '        ', 'mv_par07', '        ', '        ', '         ', '          ', ' ', '         ', '         ', '         ', ' ', ' ', '     ', '     ', '    ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'SUO', 'S', ' ', ' ' } )
       aadd(aRegs, {cPerg, '08', 'Tipo da entidade ?    ', '¿Tipo de entidad?     ', 'Entity type ?         ', 'MV_CH8', 'C',20, 0, 3, 'C', 'naovazio', 'mv_par08', 'CLIENTES', 'CLIENTES', 'CUSTOMERS', '          ', ' ', 'PROSPECTS', 'PROSPECTS', 'PROSPECTS', ' ', ' ', 'AMBOS', 'AMBOS', 'BOTH', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '   ', 'S', ' ', ' ' } )
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
Return       
