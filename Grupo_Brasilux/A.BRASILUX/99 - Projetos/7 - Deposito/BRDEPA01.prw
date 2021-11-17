#INCLUDE 'TOTVS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BRDEPA01³ Autor ³ Luís G. de Souza      ³ Data ³ 27/01/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retirada de itens do estoque do depósito                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³                                               ³±±
±±³              ³  /  /  ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function BRDEPA01()
     Private oTempTbl01
     //Verificação se a Filial é a 06
     If !(cNumEmp == '01010106')
        MsgStop("Atenção, essa rotina é exclusiva para a FILIAL DEPÓSITO.")
        Return
     Endif
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cMarca := GetMark()
     Private aCores := { { "RETT == 'N'", "BR_VERDE"    },; //Pedidos prontos para serem Retirados 
                         { "RETT == 'R'", "BR_AMARELO"  },; //Pedidos em transito (Retirando)
                         { "RETT == 'B'", "BR_AZUL"     },; //Pedidos já encontra em bordero para Faturamento
                         { "RETT == 'S'", "BR_VERMELHO" } } //Pedidos Totalmente Retirados - Prontos para montar bordero de Faturamento
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oDlg1Ret", "oBtn1Ret", "oBtn2Ret", "oBtn4Ret", "oBrw1Ret", "oBtn3Ret", "oBtn5Ret", "oTimer1R")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oDlg1Ret   := MSDialog():New( 091,232,691,1050,"Retirada de Produtos",,,.F.,,,,,,.T.,,,.T. )
                   oTimer1R := TTimer():New(216000, {|| MsAguarde( { || oTbl1Ret(2), 'Aguarde, atualizando...'} ) },oDlg1Ret)
                   oTimer1R:Activate()
     MsAguarde( { || oTbl1Ret(1), 'Aguarde, carregando informações...'} )
     DbSelectArea("TMPRET")
     oBrw1Ret   := MsSelect():New( "TMPRET", "MARC"    ,   , { {"MARC", "", "", ""}, {"PEDI", "", "Pedido", "999999"}, {"EMIS", "", "Emissao", ""}, {"PROG", "", "Programado", ""}, {"CLIE", "", "Cliente", "@!"}, {"ESTA", "", "Estado", "@!"}, {"REDE", "", "Redespacho", ""}, {"QTDI", "", "Qtd. Itens", "@E 9999"}, {"RETT", "", "Ret. Total?", ""} }, .F.      , cMarca, {004, 003, 268, 399}, , , oDlg1Ret, , aCores ) 
     oBrw1Ret:oBrowse:bChange     := {|| DbSelectArea("TMPRET") }
     oBrw1Ret:bAval               := {|| TMPRETMark() }
     oBrw1Ret:oBrowse:lHasMark    := .T.
     oBrw1Ret:oBrowse:lCanAllmark := .F.
     
     oBtn1Ret   := TButton():New( 276, 004, "Retirada/Bordero", oDlg1Ret, {|| fMonRetPed() }, 052, 012, , , , .T., , "", , , , .F. )
     oBtn2Ret   := TButton():New( 276, 068, "Ordem Retirada"  , oDlg1Ret, {|| fImpOrdRet() }, 052, 012, , , , .T., , "", , , , .F. )
     oBtn3Ret   := TButton():New( 276, 132, "Baixa Retirada"  , oDlg1Ret, {|| DEPA01_2()   }, 052, 012, , , , .T., , "", , , , .F. )
     //oBtn4Ret   := TButton():New( 276, 196, "Bordero"         , oDlg1Ret, , 052, 012, , , , .T., , "", , , , .F. )
     oBtn5Ret   := TButton():New( 276, 361, "Sair"            , oDlg1Ret, {|| oDlg1Ret:End() }, 037, 012, , , , .T., , "", , , , .F. )

     oDlg1Ret:Activate(,,,.T.)
     DbSelectArea("TMPRET")
     DbCloseArea()
     oTempTbl01:Delete()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1Ret() - Cria temporario para o Alias: TMPRET
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1Ret(nOpc)
       Local aFds := {}
       //Local cTmp

       If nOpc == 1
          aAdd( aFds, {"MARC", "C", 002, 000} )
          aAdd( aFds, {"PEDI", "C", 006, 000} )
          aAdd( aFds, {"EMIS", "D", 008, 000} )
          aAdd( aFds, {"PROG", "D", 008, 000} )
          aAdd( aFds, {"CLIE", "C", 050, 000} )
          aAdd( aFds, {"DDDC", "C", 003, 000} )
          aAdd( aFds, {"ESTA", "C", 002, 000} )
          aAdd( aFds, {"REDE", "C", 050, 000} )
          aAdd( aFds, {"QTDI", "N", 004, 000} )
          aAdd( aFds, {"ORDE", "N", 004, 000} )
          aAdd( aFds, {"RETT", "C", 001, 000} )

          /********************************************************************************************************************************/
          /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
          //cTmp := CriaTrab( aFds, .T. )
          //Use (cTmp) Alias TMPRET New Exclusive
          //Index On STR(ORDE, 0) Tag &("TMPSEL1") To (cTmp)
          //Index On PEDI         Tag &("TMPSEL2") To (cTmp)
          oTempTbl01 := FWTemporaryTable():New( "TMPRET" )
          oTempTbl01:SetFields( aFds )
          oTempTbl01:AddIndex( "cInd01", { "ORDE" } )
          oTempTbl01:AddIndex( "cInd02", { "PEDI" } )
          oTempTbl01:Create()
       Endif
       //LGS#20200211 - Adequação de release 12.1.25 e posteriores
       DbSelectArea("TMPRET")
       //Zap
       TCSqlExec("DELETE FROM " + oTempTbl01:GetRealName() )
       
       nContReg := 1
	   
       cQry1 := ""
       cQry1 += "SELECT PEDIDO, EMISSAO, PROGRAMADO, CLIENTE+' - '+NOMECLI AS CLIENTE, ESTADO, CODREDE+' - '+NOMEREDE AS REDES, DDD, COUNT(SC6.C6_NUM) AS QTDI, ISNULL(SUM(ZZC.ZZC_QUANTI), 999999) AS QUANTI, ISNULL(SUM(ZZC.ZZC_RETIRA), 999999) AS RETIRA, ISNULL(ZZC.ZZC_CARGA, '') AS CARGA "
       cQry1 += "FROM PEDIDOS_SEP_SP SEP "
       cQry1 += "LEFT OUTER JOIN SC6010 SC6 ON SC6.C6_NUM = SEP.PEDIDO AND SC6.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN ZZC010 ZZC ON ZZC.ZZC_FILIAL = '010106' AND ZZC.ZZC_PEDIDO = SEP.PEDIDO AND ZZC.D_E_L_E_T_ = '' "
       cQry1 += "GROUP BY PEDIDO, EMISSAO, PROGRAMADO, CLIENTE+' - '+NOMECLI, ESTADO, CODREDE+' - '+NOMEREDE, DDD, ZZC_CARGA "
       cQry1 += "ORDER BY PROGRAMADO DESC, CODREDE+' - '+NOMEREDE "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             RecLock("TMPRET", .t.)
                TMPRET->PEDI := TCQ->PEDIDO
                TMPRET->EMIS := STOD(TCQ->EMISSAO)
                TMPRET->PROG := STOD(TCQ->PROGRAMADO)	
                TMPRET->CLIE := TCQ->CLIENTE
                TMPRET->DDDC := TCQ->DDD
                TMPRET->ESTA := TCQ->ESTADO
                TMPRET->REDE := TCQ->REDES
                TMPRET->QTDI := TCQ->QTDI
                TMPRET->ORDE := nContReg
                If TCQ->QUANTI == 999999
                   TMPRET->RETT := 'N'
                ElseIf TCQ->QUANTI - TCQ->RETIRA <> 0
                       TMPRET->RETT := 'R'
                ElseIf TCQ->QUANTI - TCQ->RETIRA == 0
                       If Empty(TCQ->CARGA)
                          TMPRET->RETT := 'S'
                       Else
                          TMPRET->RETT := 'B'
                       Endif
                Endif
                nContReg += 1
             MsUnLock()
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TMPRET")
       DbGoTop()
       If nOpc == 2
          oBrw1Ret:oBrowse:Refresh()
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ TMPRETMark() - Funcao para marcar o MsSelect
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function TMPRETMark()
       Local lDesMarca := TMPRET->(IsMark("MARC", cMarca))
       RecLock("TMPRET", .F.)
          If lDesmarca
             TMPRET->MARC := "  "
          Else
             TMPRET->MARC := cMarca
          Endif
       TMPRET->(MsUnlock())
       oBrw1Ret:oBrowse:Refresh()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fMonRetPed() - Tratamento de itens marcados na tela principal
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fMonRetPed()
       Local aRetira := {}
       Local aBorder := {}
       Local aEstBor := {}
       Local nY
       oTimer1R:DeActivate()
       
       //Verifica pedidos marcados para Gravar
       DbSelectArea("TMPRET")
       DbGoTop()
       While !Eof()
             If IsMark("MARC", cMarca)
                If TMPRET->RETT == 'N' //Itens marcados para serem retirados.
                   RecLock("TMPRET", .f.)
                      TMPRET->RETT := 'R'
                      TMPRET->MARC := '  '
                   MsUnLock()
                   //Gravar na tabela ZZC filial 06
                   cQry1 := ""
                   cQry1 += "SELECT SC6.C6_PRODUTO, SC6.C6_QTDVEN "
                   cQry1 += "FROM SC6010 SC6 WITH (NOLOCK) "
                   cQry1 += "WHERE SC6.C6_FILIAL  = '01' " //BUSCA QUANTIDADE VENDIDA DA FILIAL 01
                   cQry1 += "  AND SC6.D_E_L_E_T_ = '' "
                   cQry1 += "  AND SC6.C6_NUM = '"+TMPRET->PEDI+"' "
                   TCQuery cQry1 ALIAS "TCQ" NEW
                   DbSelectArea("TCQ")
                   DbGoTop()
                   While !Eof()
                         RecLock("ZZC", .t.)
                            ZZC->ZZC_FILIAL := xFilial("ZZC")
                            ZZC->ZZC_PEDIDO := TMPRET->PEDI
                            ZZC->ZZC_PRODUT := TCQ->C6_PRODUTO
                            ZZC->ZZC_QUANTI := TCQ->C6_QTDVEN
                            ZZC->ZZC_RETIRA := 0
                            ZZC->ZZC_DESPAC := 'N'
                            ZZC->ZZC_SEPARA := 'N'
                            ZZC->ZZC_LOCEXP := ''                      
                         MsUnLock()
                         DbSelectArea("TCQ")
                         DbSkip()
                   EndDo
                   DbSelectArea("TCQ")
                   DbCloseArea()
                   DbSelectArea("TMPRET")
                   aAdd(aRetira, TMPRET->PEDI)
                ElseIf TMPRET->RETT == 'R' //Estorna retirada
                       RecLock("TMPRET", .f.)
                          TMPRET->RETT := 'N'
                          TMPRET->MARC := '  '
                       MsUnLock()
                       //Deletar na tabela ZZC filial 06
                       DbSelectArea("ZZC")
                       DbSetOrder(2)
                       DbSeek(xFilial("ZZC")+TMPRET->PEDI, .t.)
                       If Found()
                          While !Eof() .and. (ZZC->ZZC_FILIAL == xFilial("ZZC")) .AND. (ZZC->ZZC_PEDIDO == TMPRET->PEDI)
                                RecLock("ZZC", .f.)
                                   DbDelete()
                                MsUnLock()
                                DbSelectArea("ZZC")
                                DbSkip()
                          EndDo
                       Endif
                ElseIf TMPRET->RETT == 'S' //Gera Bordero do dia para Faturamento
                       aAdd(aBorder, TMPRET->PEDI) //Monta Array para inclusão do bordero de despacho matriz
                ElseIf TMPRET->RETT == 'B' //Estorna pedido do Bordero de pedidos na Matriz
                       If MsgYesNo("Deseja estornar pedido do 'Bordero de Faturamento - Matriz'?")
                          RecLock("TMPRET", .f.)
                             TMPRET->RETT := 'S'
                             TMPRET->MARC := '  '
                          MsUnLock()
                          aAdd(aEstBor, TMPRET->PEDI) //Monta Array para estorno do pedido do bordero de despacho da matriz
                       Endif
                Endif
             Endif
             DbSelectArea("TMPRET")
             DbSkip()
       EndDo
       DbSelectArea("TMPRET")
       DbGoTop()
       oBrw1Ret:oBrowse:Refresh()

       //Impressão dos pedidos marcados para serem retirados
       If Len(aRetira) > 0
          If MsgYesNo("Deseja imprimir 'Ordem de Retirada' dos pedidos marcados?")
             DEPA01_1(aRetira)
          Endif
       Endif

       //Montagem do bordero para Faturamento da matriz
       If Len(aBorder) > 0
          If MsgYesNo("Deseja montar 'Bordero de Faturamento' da matriz, para os pedidos já retirados?")
             cQry1 := ""
             cQry1 += "SELECT * "
             cQry1 += "FROM SZA010 SZA WITH (NOLOCK) "
             cQry1 += "WHERE SZA.ZA_FILIAL  = '01' " //Sempre fixo na Filial 01 aonde o pedido é faturado
             cQry1 += "  AND SZA.D_E_L_E_T_ = '' "
             cQry1 += "  AND SZA.ZA_DESCR   = '06-DEPOSITO' "
             cQry1 += "  AND SZA.ZA_EMISSAO = '"+dtos(dDataBase)+"' "
             TCQuery cQry1 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             nNumBor := TCQ->ZA_CODIGO
             DbSelectArea("TCQ")
             DbCloseArea()
             If Empty(cNumBor)
                cQry1 := ""
                cQry1 += "SELECT MAX(SZA.ZA_CODIGO) AS ZA_CODIGO
                cQry1 += "FROM SZA010 SZA WITH (NOLOCK) "
                cQry1 += "WHERE SZA.ZA_FILIAL  = '01' " //Sempre fixo na Filial 01 aonde o pedido é faturado
                cQry1 += "  AND SZA.D_E_L_E_T_ = '' "
                TCQuery cQry1 ALIAS "TCQ" NEW
                DbSelectArea("TCQ")
                nNumBor := StrZero(Val(TCQ->ZA_CODIGO) + 1, 6)
                DbSelectArea("TCQ")
                DbCloseArea()
                lNaoExi := .t.
             Else
                lNaoExi := .f.
             Endif
             //Grava tabela do Cabeçalho do Bordero - SZA
             RecLock("SZA", lNaoExi)
                If lNaoExi
                   SZA->ZA_FILIAL  := '01' //Gravar sempre na filial 01
                   SZA->ZA_CODIGO  := cNumBor
                   SZA->ZA_EMISSAO := dDataBase
                   SZA->ZA_DESCR   := '06-DEPOSITO'
                   SZA->ZA_REGIAO  := '00700'
                Endif
                SZA->ZA_FLAG    := 'N'
             MsUnLock()
             //Grava tabela dos pedidos do Bordero  - SZB
             For nY := 1 To Len(aBorder)
                 RecLock("SZB", .t.)
                    SZB->ZB_FILIAL := '01' //Gravar sempre na filial 01
                    SZB->ZB_CODIGO := cNumBor
                    SZB->ZB_PEDIDO := '01'+aBorder[nY]
                    SZB->ZB_RAZAO  := Posicione("SA1", 1, xFilial("SA1")+Posicione("SC5", 1, '01'+aBorder[nY], "C5_CLIENTE"), "A1_NOME")
                 MsUnLock()
                 DbSelectArea("ZZC")
                 DbSetOrder(2)
                 DbSeek(xFilial("ZZC")+aBorder[nY], .t.)
                 If Found()
                    While !Eof() .and. ZZC->ZZC_PEDIDO == aBorder[nY]
                          RecLock("ZZC", .f.)
                             ZZC->ZZC_CARGA := cNumBor
                          MsUnLock()
                          DbSelectArea("ZZC")
                          DbSkip()
                    EndDo
                 Endif
             Next
             //Ajusta Tela Principal
             RecLock("TMPRET", .f.)
                TMPRET->RETT := 'B'
                TMPRET->MARC := '  '
             MsUnLock()
          Endif
       Endif

       //Estorno do pedido do bordero para Faturamento da matriz
       If Len(aEstBor) > 0
          For nY := 1 To Len(aEstBor)
              //Busca numero do bordero
              cQry1 := ""
              cQry1 += "SELECT * "
              cQry1 += "FROM SZB010 SZB WITH (NOLOCK) "
              cQry1 += "WHERE SZB.ZB_FILIAL  = '01' " //Sempre na filial 01
              cQry1 += "  AND SZB.D_E_L_E_T_ = '' "
              cQry1 += "  AND SZB.ZB_PEDIDO  = '"+'01'+aEstBor[nY]+"' "
              TCQuery cQry1 ALIAS "TCQ" NEW
              DbSelectArea("TCQ")
              cNumBor := TCQ->ZB_CODIGO
              DbSelectArea("TCQ")
              DbCloseArea()
              //Busca qtde. de itens bordero
              cQry1 := ""
              cQry1 += "SELECT COUNT(*) AS QTDITE "
              cQry1 += "FROM SZB010 SZB WITH (NOLOCK) "
              cQry1 += "WHERE SZB.ZB_FILIAL  = '01' " //Sempre na filial 01
              cQry1 += "  AND SZB.D_E_L_E_T_ = '' "
              cQry1 += "  AND SZB.ZB_CODIGO  = '"+cNumBor+"' "
              TCQuery cQry1 ALIAS "TCQ" NEW
              DbSelectArea("TCQ")
              nNumIte := TCQ->QTDITE
              DbSelectArea("TCQ")
              DbCloseArea()
              If nNumIte == 1
                 //Exclui SZA
              Endif
              //Exclui SZB
          Next
       Endif

       oTimer1R:Activate()
       DbSelectArea("TMPRET")
Return

Static Function fImpOrdRet()
       oTimer1R:DeActivate()
       If TMPRET->RETT == 'R'
          DEPA01_1( {TMPRET->PEDI} )
       ElseIf TMPRET->RETT == 'N'
              MsgStop("Pedido ainda não foi enviado para retirada.")
       ElseIf TMPRET->RETT == 'S'
              If MsgYesNo("Pedido já foi retirado, imprime mesmo assim?")
                 DEPA01_1( {TMPRET->PEDI} )
              Endif
       Endif
       oTimer1R:Activate()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ DEPA01_1() - Botão impressão da Ordem de Retirada por pedido
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function DEPA01_1(aRetira)
     Local cStartPath  := GetSrvProfString("Startpath","")
     Local nY
     Private nMaxCol   := 2330
     
     If Len(aRetira) > 0
        // Monta objeto para impressão
        nCab1 := 0
        nCab2 := 0
        oPrint := TMSPrinter():New("Ordem de Retirada")
        oPrint:SetPortrait()
        oPrint:Setup()
        oPrint:StartPage()
        oPrint:SetPaperSize( 9 )

        oFont1 := TFont():New('Courier New', , -10, .T.)
        oFont2 := TFont():New('Arial'      , , -14, .T., .T.) 
        oFont4 := TFont():New('Courier New', , -14, .T., .T.)
        oFont3 := TFont():New('Courier New', , -12, .T., .T.)
        oFont5 := TFont():New('Courier New', , -08, .T., .T., , , ,.T., .F.)
        
        For nY := 1 To Len(aRetira)
            DbSelectArea("TMPRET")
            DbSetOrder(2)
            DbSeek(aRetira[nY])
            nCab2 := 0
            If nCab1 == 0
               oPrint:SayBitmap( 0020, 0020, cStartPath+"logo-bras.jpg", 474, 112 )
               oPrint:Line(00140, 0010, 0140, nMaxCol )
               oPrint:Say(0100, 0500, Alltrim( SM0->M0_FILIAL ), oFont1, 100, CLR_BLACK )
               oPrint:Say(0050, 0900, "ORDEM DE RETIRADA - "+TMPRET->PEDI, oFont4, 100, CLR_BLACK )
               oPrint:Say(0100, 1990, "Data: "+DTOC( MsDate() ), oFont1, 100, CLR_BLACK )
               nLin := 0150
               If nCab2 == 0
                  oPrint:Say(nLin, 0050, "CLIENTE: "+TMPRET->CLIE, oFont4, 100, CLR_BLACK )
                  nLin += 50
                  oPrint:Say(nLin, 0050, "EMISSÃO: "+DTOC(TMPRET->EMIS), oFont4, 100, CLR_BLACK )
                  If !Empty(TMPRET->PROG)
                     oPrint:Say(nLin, 710, "PROG.: "+DTOC(TMPRET->PROG), oFont4, 100, CLR_BLACK )
                  Endif
                  nLin += 50
                  oPrint:Say(nLin, 0050, "TRANSPORTADORA: "+TMPRET->REDE, oFont4, 100, CLR_BLACK )
                  nLin += 60
                  oPrint:Line(nLin, 0010, nLin, nMaxCol )
                  nLin += 10
                  nCab2 += 1
               Endif
               nCab1 += 1
               oPrint:Say(nLin, 0050, "PRODUTO"  , oFont3, 100, CLR_BLACK )
               oPrint:Say(nLin, 0500, "DESCRIÇÃO", oFont3, 100, CLR_BLACK )
               oPrint:Say(nLin, 1500, "QTDE."    , oFont3, 100, CLR_BLACK )
               nLin += 50
               oPrint:Line(nLin, 0010, nLin, nMaxCol )
            Endif
            DbSelectArea('ZZC')
            DbSetOrder(2)
            DbSeek(xFilial('ZZC')+aRetira[nY], .t.)
            If Found()
               While !Eof() .and. ZZC->ZZC_PEDIDO == aRetira[nY]
                     oPrint:Say(nLin, 0050, Iif(Len(ALLTRIM(ZZC->ZZC_PRODUT)) == 12, TransForm(ZZC->ZZC_PRODUT, '@R XX 99.999.999-99'), ZZC->ZZC_PRODUT), oFont3, 100, CLR_BLACK )
                     oPrint:Say(nLin, 0500, Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_DESC"), oFont3, 100, CLR_BLACK )
                     oPrint:Say(nLin, 1500, Transform(ZZC->ZZC_QUANTI, '@E 999,999.99')                    , oFont3, 100, CLR_BLACK )
                     nLin += 40
                     DbSelectArea('ZZC')
                     DbSkip()
               EndDo
            Endif
        Next
        // Visualiza a impressão
        oPrint:EndPage()     
        oPrint:Preview() 
     Else
        MsgStop("Não foram encontrados informações")
     Endif
     DbSelectArea("TMPRET")
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ DEPA01_2() - Botão baixa retirada na tela principal
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function DEPA01_2()
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       Local nOpc         := GD_UPDATE
       Private aCoBrw1Bai := {}
       Private aHoBrw1Bai := {}
       Private noBrw1Bai  := 0
       Private lEstorna   := .f.
       Private aCpoAGd    := {"ZZC_RETIRA"}

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oDlg1Bai", "oBrw1Bai", "oBtn1Bai", "oBtn2Bai", "oBtn3Bai")

       If TMPRET->RETT $ 'S'
          If !MsgYesNo('Atenção, esse pedido já foi retirado. Deseja estornar a retirada?')
             Return
          Endif
          lEstorna := .t.
       ElseIf TMPRET->RETT $ 'N'
              MsgStop('Atenção, esse pedido ainda não foi disponibilizado para retirada.')
              Return
       ElseIf TMPRET->RETT $ 'B'
              MsgStop('Atenção, esse pedido já se encontra em bordero para faturamento.')
              Return
       Endif
       oTimer1R:DeActivate()
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oDlg1Bai   := MSDialog():New( 091, 232, 483, 932, "Baixa retirada - pedido", , , .F., , , , , , .T., , , .T. )
       MHoBrw1Bai()
       MCoBrw1Bai()
       oBrw1Bai   := MsNewGetDados():New( 004, 004, 164, 340, nOpc, 'AllwaysTrue()', 'AllwaysTrue()', '', aCpoAGd, 0, 99, 'AllwaysTrue()', '', 'AllwaysTrue()', oDlg1Bai, aHoBrw1Bai, aCoBrw1Bai )
       If lEstorna
          oBtn1Bai   := TButton():New( 172, 004, "Estorna Tudo", oDlg1Bai, {|| fBaixaTudo(2) }, 037, 012, , , , .T., , "", , , , .F. )
       Else
          oBtn1Bai   := TButton():New( 172, 004, "Baixa Tudo"  , oDlg1Bai, {|| fBaixaTudo(1) }, 037, 012, , , , .T., , "", , , , .F. )
       Endif
       oBtn2Bai   := TButton():New( 172, 303, "Sair"           , oDlg1Bai, {|| oDlg1Bai:End() }, 037, 012, , , , .T., , "", , , , .F. )
       oBtn3Bai   := TButton():New( 172, 248, "Confirma"       , oDlg1Bai, {|| fConfBaixa() }, 037, 012, , , , .T., , "", , , , .F. )

       oDlg1Bai:Activate(, , , .T.)
       oTimer1R:Activate()
       DbSelectArea("TMPRET")
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrw1Bai() - Monta aHeader da MsNewGetDados para o Alias: ZZC
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrw1Bai()
       Local _lOpen        := .F. //LGS#20200211 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200211 - Adequação para release 12.1.25
       
       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200211 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0
       If !_lOpen //LGS#20200211 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("ZZC")
       While !Eof() .and. SX3->X3_ARQUIVO == "ZZC"
             If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .AND. RTRIM(SX3->X3_CAMPO) $ 'ZZC_PRODUT.ZZC_DESCRI.ZZC_LOCALI.ZZC_QUANTI.ZZC_RETIRA.ZZC_LOCEXP'
                noBrw1Bai++
                aAdd(aHoBrw1Bai, { Trim(( _cAliasSX3 )->( X3_TITULO )), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", SX3->X3_CONTEXT } )
             EndIf
             DbSkip()
       EndDo*/
       ( _cAliasSX3 )->( DbSelectArea("SX3") )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("ZZC") )
       While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "ZZC"
             If X3Uso(( _cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .AND. RTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZZC_PRODUT.ZZC_DESCRI.ZZC_LOCALI.ZZC_QUANTI.ZZC_RETIRA.ZZC_LOCEXP'
                noBrw1Bai++
                aAdd(aHoBrw1Bai, { Trim( ( _cAliasSX3 )->( X3_TITULO ) ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", ( _cAliasSX3 )->( X3_CONTEXT ) } )
             EndIf
             ( _cAliasSX3 )->( DbSkip() )
       EndDo
       DbSelectArea( _cAliasSX3 )
       DbCloseArea()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrw1Bai() - Monta aCols da MsNewGetDados para o Alias: ZZC
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrw1Bai()
       //Local aAux := {}
       Local nI
       DbSelectArea("ZZC")
       DbSetOrder(2)
       DbSeek(xFilial('ZZC')+TMPRET->PEDI, .t.)
       If Found()
          While !Eof() .and. ZZC->ZZC_PEDIDO == TMPRET->PEDI
                aAdd(aCoBrw1Bai, Array(noBrw1Bai+1) )
                For nI := 1 To noBrw1Bai
                    If aHoBrw1Bai[nI][10] $ 'V'
                       If Alltrim(aHoBrw1Bai[nI][2]) $ 'ZZC_DESCRI'
                          aCoBrw1Bai[Len(aCoBrw1Bai)][nI] := Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_DESC")
                       ElseIf Alltrim(aHoBrw1Bai[nI][2]) $ 'ZZC_LOCALI'
                              aCoBrw1Bai[Len(aCoBrw1Bai)][nI] := Posicione("SB2", 1, xFilial("SB2")+ZZC->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ")
                       Endif
                    Else
                       aCoBrw1Bai[Len(aCoBrw1Bai)][nI] := FieldGet( FieldPos( aHoBrw1Bai[nI][2] ) )
                    Endif
                Next
                aCoBrw1Bai[Len(aCoBrw1Bai)][noBrw1Bai+1] := .F.
                DbSelectArea("ZZC")
                DbSkip()
          EndDo
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fBaixaTudo() - Efetua a troca da quantidade retirada para total(baixa) ou 0 (estorno)
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fBaixaTudo(nOpcBai)
Local nY
       If nOpcBai == 1
          For nY := 1 To Len(oBrw1Bai:aCols)
              oBrw1Bai:aCols[nY][5] := oBrw1Bai:aCols[nY][4]
          Next
       Else
          For nY := 1 To Len(oBrw1Bai:aCols)
              oBrw1Bai:aCols[nY][5] := 0
          Next
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fConfBaixa() - Confirma a baixa do pedido
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fConfBaixa()
       Local nIteTot := 0
       Local nY
       For nY := 1 To Len(oBrw1Bai:aCols)
           DbSelectArea("ZZC")
           DbSetOrder(2)
           DbSeek(xFilial("ZZC")+TMPRET->PEDI+oBrw1Bai:aCols[nY][1], .t.)
           If Found()
              RecLock("ZZC", .f.)
                 ZZC->ZZC_RETIRA := oBrw1Bai:aCols[nY][5]
                 ZZC->ZZC_SEPARA := Iif(ZZC->ZZC_QUANTI == ZZC->ZZC_RETIRA, 'S', 'N')
              MsUnLock()
              nIteTot += Iif(ZZC->ZZC_QUANTI == ZZC->ZZC_RETIRA, 1, 0)
           Endif
       Next
       If nIteTot == Len(oBrw1Bai:aCols)
             RecLock("TMPRET", .f.)
                TMPRET->RETT := 'S'
             MsUnLock()
       Else
          If lEstorna
             RecLock("TMPRET", .f.)
                TMPRET->RETT := 'R'
             MsUnLock()
          Endif
       EndIf
       oDlg1Bai:End()
       DbSelectArea("TMPRET")
Return