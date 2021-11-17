#include "TOTVS.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FINALEG  ºAutor  ³ Cleber O. Dominguesº Data ³  25/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona legenga preta para Lucros e Perdas                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//30/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function FINALEG()
     Local aLegenda := {}
     Local uRetorno := {}
     Local nReg     := PARAMIXB[1]
     Local _cAlias  := PARAMIXB[2]

/*
//Cleber(21/01/20) -> Unificando empresas
     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
*/     
        aLegenda := { {"BR_VERDE"   , "Titulo em aberto"     },; //"Titulo em aberto"
                      {"BR_AZUL"    , "Baixado parcialmente" },; //"Baixado parcialmente"
                      {"BR_VERMELHO", "Titulo Baixado"       },; //"Titulo Baixado"
                      {"BR_PRETO"   , "Lucros e Perdas"      } }
        If nReg == Nil // Chamada direta da funcao onde nao passa, via menu Recno eh passado
           uRetorno := {}
           If _cAlias == "SE1"
              aAdd(uRetorno, { '(ROUND(E1_SALDO,2) = 0) .and. (E1_NATUREZ # "801004")', aLegenda[3][1] } )
              aAdd(uRetorno, { '(ROUND(E1_SALDO,2) # ROUND(E1_VALOR,2)) .AND. (E1_NATUREZ # "801004")', aLegenda[2][1] } )
              aAdd(uRetorno, { '(E1_NATUREZ = "801004")', aLegenda[4][1] } )
              aAdd(uRetorno, { '.T.', aLegenda[1][1] } )
           Else
              aAdd(uRetorno, { 'ROUND(E2_SALDO,2) = 0', aLegenda[3][1] } )
              aAdd(uRetorno, { 'ROUND(E2_SALDO,2) = 0', aLegenda[3][1] } )
              aAdd(uRetorno, { 'ROUND(E2_SALDO,2) # ROUND(E2_VALOR,2)', aLegenda[2][1] } )
              aAdd(uRetorno, { '.T.', aLegenda[1][1] } )
           Endif
        Else
           BrwLegenda(cCadastro, "Legenda", aLegenda)
        Endif
        
/*       
//Cleber(21/01/20) -> Unificando empresas
 
     Else //Tecpolpa - Padrão
        aLegenda := { {"BR_VERDE"   , "Titulo em aberto"                         },; //1. "Titulo em aberto"
                      {"BR_AZUL"    , "Baixado parcialmente"                     },; //2. "Baixado parcialmente"
                      {"BR_VERMELHO", "Titulo Baixado"                           },; //3. "Titulo Baixado"
                      {"BR_PRETO"   , "Titulo em Bordero"                        },; //4. "Titulo em Bordero"
                      {"BR_BRANCO"  , "Adiantamento com saldo"                   },; //5. "Adiantamento com saldo"
                      {"BR_CINZA"   , "Titulo baixado parcialmente e em bordero" },; //6. "Titulo baixado parcialmente e em bordero"
                      {"BR_AMARELO" , "Adiantamento de Imp. Bx. com saldo"       } } //7. "Adiantamento de Imp. Bx. com saldo"

        If nReg == Nil // Chamada direta da funcao onde nao passa, via menu Recno eh passado
           uRetorno := {}
           If _cAlias == "SE1"
              Aadd(aLegenda, {"BR_VERDE_ESCURO", "Titulo Protestado" } )  //8. "Titulo Protestado"
              Aadd(uRetorno, { '.T.'                                                                                                 , aLegenda[1][1]              } )
              Aadd(uRetorno, { 'ROUND(E1_SALDO,2) + ROUND(E1_SDACRES,2) # ROUND(E1_VALOR,2) + ROUND(E1_ACRESC,2) .And. !FXAtuTitCo()', aLegenda[2][1]              } ) //"Baixado parcialmente"
              Aadd(uRetorno, { 'ROUND(E1_SALDO,2) = 0'                                                                               , aLegenda[3][1]              } ) //"Titulo Baixado" 
              Aadd(uRetorno, { '!Empty(E1_NUMBOR)'                                                                                   , aLegenda[4][1]              } ) //"Titulo em Bordero"
              Aadd(uRetorno, { 'E1_TIPO == "'+MVRECANT+'".and. ROUND(E1_SALDO,2) > 0 .And. !FXAtuTitCo()'                            , aLegenda[5][1]              } ) //"Adiantamento com saldo"
              Aadd(uRetorno, { '!Empty(E1_NUMBOR) .and.(ROUND(E1_SALDO,2) # ROUND(E1_VALOR,2))'                                      , aLegenda[6][1]              } ) //"Titulo baixado parcialmente e em bordero"              
              Aadd(uRetorno, { 'ROUND(E1_SALDO,2) == ROUND(E1_VALOR,2) .and. AllTrim(E1_SITUACA)== "F"'                              , aLegenda[ Len(aLegenda)][1] } ) //"Titulo Protestado"
           Else
              If lPrjCni
                 IF !Empty(SuperGetMv("MV_APRPAG",.F.,"")) .or. SuperGetMv("MV_CTLIPAG",.F.,.F.)           
                    Aadd(aLegenda, {"BR_AMARELO", "Titulo aguardando liberacao"})  //"Titulo aguardando liberacao"
                    Aadd(uRetorno, { ' EMPTY(E2_DATALIB) .AND. (SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE) > GetMV("MV_VLMINPG") .AND. E2_SALDO > 0', aLegenda[Len(aLegenda)][1] } ) 
                 EndIf
              Else
                 IF SuperGetMv("MV_CTLIPAG",.F.,.F.)          
                    Aadd(aLegenda, {"BR_AMARELO", "Titulo aguardando liberacao" } ) //"Titulo aguardando liberacao" 
                    Aadd(uRetorno, { ' !( SE2->E2_TIPO $ MVPAGANT ).and. EMPTY(E2_DATALIB) .AND. (SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE) > SuperGetMV("MV_VLMINPG",.F.,0) .AND. E2_SALDO > 0', aLegenda[Len(aLegenda)][1] } ) 
                 EndIf
              EndIf
              Aadd(aLegenda, { "BR_LARANJA", "Adiantamento de Viagem sem taxa" } ) //"Adiantamento de Viagem sem taxa"
              Aadd(uRetorno, { ' (ALLTRIM(SE2->E2_ORIGEM) $ "FINA667|FINA677") .and. SE2->E2_MOEDA > 1 .AND. SE2->E2_TXMOEDA == 0 .AND. SE2->E2_SALDO > 0', aLegenda[Len(aLegenda)][1] } )

              //Validação para uso do documento hábil - SIAFI
              If FinUsaDH()
                 Aadd(aLegenda, { "BR_VIOLETA", "Titulo Vinculado a Docto Hábil" } ) // "Titulo Vinculado a Docto Hábil"
                 Aadd(uRetorno, { 'ROUND(E2_SALDO,2) > 0 .And. !EMPTY(E2_DOCHAB)'                                                          , aLegenda[Len(aLegenda)][1] } ) //"Titulo relacionado ao Documento hábil"
              Endif
              Aadd(uRetorno, { '.T.'                                                                                                    , aLegenda[1][1] } )
              Aadd(uRetorno, { 'ROUND(E2_SALDO,2)+ ROUND(E2_SDACRES,2) # ROUND(E2_VALOR,2)+ ROUND(E2_ACRESC,2)'                         , aLegenda[2][1] } )
              Aadd(uRetorno, { 'ROUND(E2_SALDO,2) + ROUND(E2_SDACRES,2)  = 0'                                                           , aLegenda[3][1] } )
              Aadd(uRetorno, { '!Empty(E2_NUMBOR)'                                                                                      , aLegenda[4][1] } )
              Aadd(uRetorno, { 'E2_TIPO == "'+MVPAGANT+'" .and. ROUND(E2_SALDO,2) > 0'                                                  , aLegenda[5][1] } )
              Aadd(uRetorno, { '!Empty(E2_NUMBOR) .and.(ROUND(E2_SALDO,2)+ ROUND(E2_SDACRES,2) # ROUND(E2_VALOR,2)+ ROUND(E2_ACRESC,2))', aLegenda[6][1] } )
              Aadd(uRetorno, { 'E2_TIPO $ "INA/'+MVTXA+'" .and. ROUND(E2_SALDO,2) > 0 .And. E2_OK == "TA"  '                            , aLegenda[7][1] } )
           Endif
        Else
           If _cAlias = "SE1"
              Aadd(aLegenda,{"BR_VERDE_ESCURO", "Titulo Protestado" } ) //"Titulo Protestado" 
           Else
              If lPrjCni
                 If !Empty(SuperGetMv("MV_APRPAG",.F.,"")) .or. SuperGetMv("MV_CTLIPAG",.F.,.F.)    
                    Aadd(aLegenda, { "BR_AMARELO", "Titulo aguardando liberacao" } ) //"Titulo aguardando liberacao"  
                 EndIf
              Else
                 IF SuperGetMv("MV_CTLIPAG",.F.,.F.)    
                    Aadd(aLegenda, {"BR_AMARELO",  "Titulo aguardando liberacao" } ) //"Titulo aguardando liberacao"  
                 EndIf
              Endif
              Aadd(aLegenda, {"BR_LARANJA", "Adiantamento de Viagem sem taxa" } ) //"Adiantamento de Viagem sem taxa"
              //Validação para uso do documento habil (SIAFI)
              If FinUsaDH()
                 Aadd(aLegenda,{ "BR_VIOLETA", "Titulo Vinculado a Docto Hábil" } ) // "Titulo Vinculado a Docto Hábil"
              Endif
           Endif
           BrwLegenda(cCadastro, "Legenda", aLegenda)
        Endif

     Endif
*/     
Return(uRetorno)