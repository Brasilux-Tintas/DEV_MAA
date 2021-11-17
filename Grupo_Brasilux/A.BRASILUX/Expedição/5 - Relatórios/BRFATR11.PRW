#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRAFATR11 º Autor ³ Luís G. de Souza  º Data ³  29/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mapa de distribuiçào de produtos na expedição.             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATR11()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Mapa de Distribuição"
     //Local cPict         := ""
     Local titulo        := "Mapa de Distribuição"
     Local nLin          := 80
     Local Cabec1        := "PEDIDO  CLIENTE                                VOLUME         LOCALIZAÇÃO  %SEP."
     Local Cabec2        := "        PRODUTO          DESCRIÇÃO                       QTDE.  VOLUME    P   E"
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRFATR11" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "FATR11"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR11" // Coloque aqui o nome do arquivo usado para impressao em disco

     Private cString     := "ZZC"
     
     if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

     DbSelectArea("ZZC")
     DbSetOrder(1)

     //VldPerg()  //LGS#20200212 - Adequação de release 12.1.25 e posteriores
     Pergunte(cPerg, .F.)

     wnrel := SetPrint(cString, NomeProg, cPerg, @Titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     Processa({|| FATR11_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FATR11_1 º Autor ³ Luís G. de Souza   º Data ³  29/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FATR11_1(Cabec1, Cabec2, Titulo, nLin)
       Local cQry1   := ""
       Local aMatDad := {}
       Local aMatReg := {}
       Local nY, nX
       
       cQry1 += "SELECT ZZC.ZZC_BORDER, ZZC.ZZC_CARGA, ZZC.ZZC_PEDIDO, ZZC.ZZC_SEPARA, SUM(ZZC.ZZC_VOLUME) AS QTDE "
       cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC "
       cQry1 += "WHERE ZZC.ZZC_FILIAL = '"+xFilial("ZZC")+"' "
       cQry1 += "  AND D_E_L_E_T_ = '' "
       If mv_par01 == 1
          cQry1 += "  AND ZZC.ZZC_BORDER = '"+mv_par02+"' "
       Else
          cQry1 += "  AND ZZC.ZZC_CARGA  = '"+mv_par02+"' "
       Endif
       If mv_par04 == 1
          cQry1 += "  AND ZZC.ZZC_SEPARA = 'S' "
       ElseIf mv_par04 == 2
              cQry1 += "  AND ZZC.ZZC_SEPARA = 'N' "
       Endif
       cQry1 += "GROUP BY ZZC.ZZC_BORDER, ZZC.ZZC_CARGA, ZZC.ZZC_PEDIDO, ZZC.ZZC_SEPARA "
       cQry1 += "ORDER BY ZZC.ZZC_PEDIDO, ZZC.ZZC_SEPARA "
       TCQuery cQry1 ALIAS "TCQ" NEW

       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             nPosDad := aScan(aMatDad, {|x| x[1] == TCQ->ZZC_PEDIDO})
             If nPosDad == 0
                aadd(aMatDad, {'', '', '', '', '', '', 0, 0, 0, '', '', '', ''})
                aMatDad[Len(aMatDad)][01] := TCQ->ZZC_PEDIDO                                                                                      //Pedido
                aMatDad[Len(aMatDad)][02] := Posicione("SC5", 1, xFilial("SC5")+aMatDad[Len(aMatDad)][01], "C5_CLIENTE")                          //Cliente
                aMatDad[Len(aMatDad)][03] := Posicione("SC5", 1, xFilial("SC5")+aMatDad[Len(aMatDad)][01], "C5_LOJACLI")                          //Loja Cliente
                aMatDad[Len(aMatDad)][04] := Posicione("SA1", 1, xFilial("SA1")+aMatDad[Len(aMatDad)][02]+aMatDad[Len(aMatDad)][03], "A1_NOME")   //Razão Social
                aMatDad[Len(aMatDad)][05] := Posicione("SA1", 1, xFilial("SA1")+aMatDad[Len(aMatDad)][02]+aMatDad[Len(aMatDad)][03], "A1_CODCID") //Código da Cidade
                aMatDad[Len(aMatDad)][06] := Posicione("SZ7", 1, xFilial("SZ7")+aMatDad[Len(aMatDad)][05], "Z7_REGIAO")                           //Código da Região
                aMatDad[Len(aMatDad)][12] := Posicione("SZG", 2, xFilial("SZG")+'01'+aMatDad[Len(aMatDad)][01], "ZG_LOCALIZ")                     //Endereço na Expedição
                aMatDad[Len(aMatDad)][13] := Iif(mv_par01 == 1, TCQ->ZZC_BORDER, TCQ->ZZC_CARGA)
                If TCQ->ZZC_SEPARA $ 'S'
                   aMatDad[Len(aMatDad)][07] := TCQ->QTDE
                Else
                   aMatDad[Len(aMatDad)][08] := TCQ->QTDE
                Endif
                aMatDad[Len(aMatDad)][09] += TCQ->QTDE
                aMatDad[Len(aMatDad)][10] := aMatDad[Len(aMatDad)][06]+aMatDad[Len(aMatDad)][01]
                nPosReg := aScan(aMatReg, aMatDad[Len(aMatDad)][06] )
                If nPosReg == 0
                   aadd(aMatReg, aMatDad[Len(aMatDad)][06])
                Endif
             Else
                If TCQ->ZZC_SEPARA $ 'S'
                   aMatDad[nPosDad][07] += TCQ->QTDE
                Else
                   aMatDad[nPosDad][08] += TCQ->QTDE
                Endif
                aMatDad[nPosDad][09] += TCQ->QTDE
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       aSort(aMatReg)
       aSort(aMatDad,,,{|x,y| x[10] < y[10]})
       //0         1         2         3         4         5         6         7         8
       //01234567890123456789012345678901234567890123456789012345678901234567890123456789
       //PEDIDO  CLIENTE                                VOLUME         LOCALIZAÇÃO  %SEP.
       //        PRODUTO          DESCRIÇÃO                       QTDE.  VOLUME   P     E
       //REGIÃO: 999 - REDESPACHO
       //--------------------------------------------------------------------------------
       //999999  999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999           (999/999)    999
       //        XX 99.99.999-99  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99999   99999    *   *
       //        99999  XX 99.99.999-99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXX *99999*
       Titulo := 'Distribuição - '+Iif(mv_par01 == 1, 'Pedidos '+mv_par02, 'Despacho '+mv_par02)
       
       ProcRegua(Len(aMatDad))
       aResIte := {}
       For nY := 1 To Len(aMatReg)
           If lAbortPrint
              @ nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
              Exit
           Endif
           If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
              nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
              nLin += 1
           Endif
           aMatImp := {}
           For nX := 1 To Len(aMatDad)
               If aMatDad[nX][06] == aMatReg[nY]
                  aadd(aMatImp, {aMatDad[nX][01], aMatDad[nX][02], aMatDad[nX][03], aMatDad[nX][04], aMatDad[nX][05], aMatDad[nX][06], aMatDad[nX][07], aMatDad[nX][08], aMatDad[nX][09], aMatDad[nX][10], aMatDad[nX][11], aMatDad[nX][12], (Iif(aMatDad[nX][09] == 0, 0, aMatDad[nX][07] / aMatDad[nX][09]) * 100), '', aMatDad[nX][13] })
               Endif
           Next
           For nX := 1 To Len(aMatImp)
               aMatImp[nX][14] := StrZero(aMatImp[nX][13], 3)+aMatImp[nX][10]
           Next
           aSort(aMatImp,,,{|x,y| x[14] > y[14]})
           
           @ nLin, 000 PSAY aMatReg[nY]+' - '+Alltrim(Posicione("SX5", 1, xFilial("SX5")+'98'+aMatReg[nY], "X5_DESCRI"))
           nLin += 1
           @ nLin, 000 PSAY Replicate("*", 80)
           nLin += 1
           For nX := 1 To Len(aMatImp)
               If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                  nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                  nLin += 1
               Endif
               @ nLin, 000 PSAY aMatImp[nX][01]                                    //Pedido
               @ nLin, 008 PSAY aMatImp[nX][02]+'-'+SubStr(aMatImp[nX][04], 1, 30) //Cliente+Nome
               //@ nLin, 047 PSAY aMatImp[nX][09] Picture "@E 999999"                //Volume
               @ nLin, 047 PSAY Transform(Posicione("SC5", 1, xFilial("SC5")+aMatImp[nX][01], "C5_VOLUME1"), "@E 999999")                 //Volume
               //@ nLin, 054 PSAY aMatImp[nX][07] Picture "@E 99999"
               @ nLin, 064 PSAY aMatIMp[nX][12]
               If mv_par03 <> 1 //Analitico
                  @ nLin, 077 PSAY aMatIMp[nX][13] Picture "@E 999"
               Endif
               nLin += 1
               If mv_par03 == 1 //Analítico
                  If aMatIMp[nX][13] < 100 .or. mv_par05 == 2
                     If mv_par01 == 1    //Bordero de Pedidos
                        DbSelectArea("ZZC")
                        DbSetOrder(1)
                        DbSeek(xFilial("ZZC")+aMatImp[nX][15]+aMatImp[nX][01], .t.)
                        If Found()
                           While !Eof() .and. ZZC->ZZC_BORDER == aMatImp[nX][15] .and. ZZC->ZZC_PEDIDO == aMatImp[nX][01]
                                 If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                                    nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                                    nLin += 1
                                 Endif
                                 If ZZC->ZZC_SEPARA <> 'S' .or. mv_par05 == 2
                                    /******************************************************************************/
                                    //Montar *s para indicar se o produto já foi pesado e/ou envasado.
                                    nQtdPro := 0
                                    cNumOP:= "'"
                                    cNumLT:= "'"
									cQry2 := "SELECT SC2.C2_OP AS ORDEM, SC2.C2_LOTE AS LOTE, ISNULL(SUM(SC2.C2_QUANT - SC2.C2_QUJE),0) AS QUANT "+;
									"FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "+;
									"WHERE (SC2.C2_FILIAL  = '"+xFilial("SC2")+"') AND (SC2.D_E_L_E_T_ = '') "+;
									"AND (SC2.C2_DATRF   = '') AND (C2_PRODUTO = '"+ZZC->ZZC_PRODUT+"') "+;
									"GROUP BY SC2.C2_OP, SC2.C2_LOTE"
									
                                    TCQuery cQry2 ALIAS "QOP" NEW
                                    DbSelectArea("QOP")
                                    While !Eof()
                                          nQtdPro += QOP->QUANT
                                          cNumOP  += QOP->ORDEM+"', '"
                                          cNumLT  += QOP->LOTE+"', '"
                                          DbSelectArea("QOP")
                                          DbSkip()
                                    Enddo
                                    DbSelectArea("QOP")
                                    DbCloseArea()
                                    If !cNumLT == "'"
                                       cQry2 := ""
                                       cQry2 += "SELECT TOP 1 * "
                                       cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                                       cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                                       cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(ZZC->ZZC_PRODUT), 1, 10)+"00' "
                                       cQry2 += "ORDER BY PSQ.FIM "
                                       TCQuery cQry2 ALIAS "QOP" NEW
                                       If Empty(QOP->STATUS)
                                          DbSelectArea("QOP")
                                          DbCloseArea()
                                          cQry2 := ""
                                          cQry2 += "SELECT TOP 1 * "
                                          cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                                          cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                                          cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(ZZC->ZZC_PRODUT), 1, 10)+"00' "
                                          cQry2 += "ORDER BY PSQ.FIM "
                                          TCQuery cQry2 ALIAS "QOP" NEW
                                       Endif
                                       DbSelectArea("QOP")
                                       cPesado := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->INICIO), '*', ' ')
                                       DbSelectArea("QOP")
                                       DbCloseArea()
                                       cQry2 := ""
                                       cQry2 += "SELECT TOP 1 * "
                                       cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                                       cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                                       cQry2 += "  AND PSQ.PRODUTO = '"+ZZC->ZZC_PRODUT+"' "
                                       cQry2 += "ORDER BY PSQ.FIM "
                                       TCQuery cQry2 ALIAS "QOP" NEW
                                       If Empty(QOP->STATUS)
                                          DbSelectArea("QOP")
                                          DbCloseArea()
                                          cQry2 := ""
                                          cQry2 += "SELECT TOP 1 * "
                                          cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                                          cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                                          cQry2 += "  AND PSQ.PRODUTO = '"+ZZC->ZZC_PRODUT+"' "
                                          cQry2 += "ORDER BY PSQ.FIM "
                                          TCQuery cQry2 ALIAS "QOP" NEW
                                       Endif
                                       DbSelectArea("QOP")
                                       cEnvase := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->FIM), '*', ' ')
                                       DbSelectArea("QOP")
                                       DbCloseArea()
                                    Else
                                       cPesado := ' '
                                       cEnvase := ' '
                                    Endif
                                    /******************************************************************************/
                                    /*
                                    @ nLin, 008 PSAY ZZC->ZZC_PRODUT Picture "@R XX 99.99.999-99"
                                    @ nLin, 024 PSAY Iif(Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_ESTOQUE") == 'S', "*", "")
                                    @ nLin, 025 PSAY Posicione("SB1", 1, xFilial("ZZC")+ZZC->ZZC_PRODUT, "B1_DESC")
                                    @ nLin, 057 PSAY Iif(ZZC->ZZC_SEPARA <> 'S', ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA, ZZC->ZZC_QUANTI) Picture "@E 99999"
                                    @ nLin, 065 PSAY Iif(ZZC->ZZC_SEPARA <> 'S', ZZC->ZZC_VOLUME - ZZC->ZZC_VOLRET, ZZC->ZZC_VOLUME) Picture "@E 99999"
                                    @ nLin, 074 PSAY cPesado
                                    @ nLin, 078 PSAY cEnvase
                                    */
                                    @ nLin, 008 PSAY Iif(ZZC->ZZC_SEPARA <> 'S', ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA, ZZC->ZZC_QUANTI) Picture "@E 99999"
                                    @ nLin, 014 PSAY Iif(Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_ESTOQUE") == 'S', "*", " ")
                                    @ nLin, 015 PSAY ZZC->ZZC_PRODUT Picture "@R XX 99.99.999-99"
                                    @ nLin, 031 PSAY Posicione("SB1", 1, xFilial("ZZC")+ZZC->ZZC_PRODUT, "B1_DESC")
                                    @ nLin, 062 PSAY SubStr(Posicione("SB2", 1, xFilial("SB2")+ZZC->ZZC_PRODUT+Posicione("SB1", 1, xFilial("ZZC")+ZZC->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), 1, 10)
                                    @ nLin, 073 PSAY cPesado
                                    @ nLin, 074 PSAY nQtdPro Picture "@E 99999"
                                    @ nLin, 079 PSAY cEnvase
                                    nLin += 1
                                    aAdd(aResIte, {ZZC->ZZC_PRODUT, ;
                                                   Iif(Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_ESTOQUE") == 'S', "*", " "), ;
                                                   Posicione("SB1", 1, xFilial("ZZC")+ZZC->ZZC_PRODUT, "B1_DESC"), ;
                                                   Iif(ZZC->ZZC_SEPARA <> 'S', ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA, ZZC->ZZC_QUANTI), ;
                                                   Iif(ZZC->ZZC_SEPARA <> 'S', ZZC->ZZC_VOLUME - ZZC->ZZC_VOLRET, ZZC->ZZC_VOLUME), ;
                                                   Posicione("SB2", 1, xFilial("SB2")+ZZC->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ") })
                                 Endif
                                 DbSelectArea("ZZC")
                                 DbSkip()
                           Enddo
                        Endif
                     Else                       //Bordero de Despacho
                        DbSelectArea("ZZC")
                        DbSetOrder(4)
                        DbSeek(xFilial("ZZC")+aMatImp[nX][15]+aMatImp[nX][01], .t.)
                        If Found()
                           While !Eof() .and. ZZC->ZZC_CARGA == aMatImp[nX][15] .and. ZZC->ZZC_PEDIDO == aMatImp[nX][01]
                                 If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                                    nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                                    nLin += 1
                                 Endif
                                 If ZZC->ZZC_SEPARA <> 'S' .or. mv_par05 == 2
                                    /******************************************************************************/
                                    //Montar *s para indicar se o produto já foi pesado e/ou envasado.
                                    nQtdPro := 0
                                    cNumOP:= "'"
                                    cNumLT:= "'"
									cQry2 := "SELECT SC2.C2_OP AS ORDEM, SC2.C2_LOTE AS LOTE, ISNULL(SUM(SC2.C2_QUANT - SC2.C2_QUJE),0) AS QUANT "+;
									"FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "+;
									"WHERE (SC2.C2_FILIAL  = '"+xFilial("SC2")+"') AND (SC2.D_E_L_E_T_ = '') "+;
									"AND (SC2.C2_DATRF   = '') AND (C2_PRODUTO = '"+ZZC->ZZC_PRODUT+"') "+;
									"GROUP BY SC2.C2_OP, SC2.C2_LOTE"
                                    TCQuery cQry2 ALIAS "QOP" NEW
                                    DbSelectArea("QOP")
                                    While !Eof()
                                          nQtdPro += QOP->QUANT
                                          cNumOP  += QOP->ORDEM+"', '"
                                          cNumLT  += QOP->LOTE+"', '"
                                          DbSelectArea("QOP")
                                          DbSkip()
                                    Enddo
                                    DbSelectArea("QOP")
                                    DbCloseArea()
                                    If !cNumLT == "'"
                                       cQry2 := ""
                                       cQry2 += "SELECT TOP 1 * "
                                       cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                                       cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                                       cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(ZZC->ZZC_PRODUT), 1, 10)+"00' "
                                       cQry2 += "ORDER BY PSQ.FIM "
                                       TCQuery cQry2 ALIAS "QOP" NEW
                                       If Empty(QOP->STATUS)
                                          DbSelectArea("QOP")
                                          DbCloseArea()
                                          cQry2 := ""
                                          cQry2 += "SELECT TOP 1 * "
                                          cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                                          cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                                          cQry2 += "  AND PSQ.PRODUTO = '"+SubStr(Alltrim(ZZC->ZZC_PRODUT), 1, 10)+"00' "
                                          cQry2 += "ORDER BY PSQ.FIM "
                                          TCQuery cQry2 ALIAS "QOP" NEW
                                       Endif
                                       DbSelectArea("QOP")
                                       cPesado := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->INICIO), '*', ' ')
                                       DbSelectArea("QOP")
                                       DbCloseArea()
                                       cQry2 := ""
                                       cQry2 += "SELECT TOP 1 * "
                                       cQry2 += "FROM PESQUISA_PRODUCAO PSQ "
                                       cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                                       cQry2 += "  AND PSQ.PRODUTO = '"+ZZC->ZZC_PRODUT+"' "
                                       cQry2 += "ORDER BY PSQ.FIM "
                                       TCQuery cQry2 ALIAS "QOP" NEW
                                       If Empty(QOP->STATUS)
                                          DbSelectArea("QOP")
                                          DbCloseArea()
                                          cQry2 := ""
                                          cQry2 += "SELECT TOP 1 * "
                                          cQry2 += "FROM PESQUISA_PRODUCAO_2 PSQ "
                                          cQry2 += "WHERE PSQ.C2_LOTE IN("+SubStr(cNumLT, 1, Len(cNumLT)-3)+") "
                                          cQry2 += "  AND PSQ.PRODUTO = '"+ZZC->ZZC_PRODUT+"' "
                                          cQry2 += "ORDER BY PSQ.FIM "
                                          TCQuery cQry2 ALIAS "QOP" NEW
                                       Endif
                                       DbSelectArea("QOP")
                                       cEnvase := Iif(QOP->STATUS $ '1' .or. !Empty(QOP->FIM), '*', ' ')
                                       DbSelectArea("QOP")
                                       DbCloseArea()
                                    Else
                                       cPesado := ' '
                                       cEnvase := ' '
                                    Endif
                                    /******************************************************************************/
                                    /*
                                    @ nLin, 001 PSAY Iif(ZZC->ZZC_SEPARA <> 'S', ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA, ZZC->ZZC_QUANTI) Picture "@E 99999"
                                    @ nLin, 008 PSAY ZZC->ZZC_PRODUT Picture "@R XX 99.99.999-99"
                                    @ nLin, 024 PSAY Iif(Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_ESTOQUE") == 'S', "*", "")
                                    @ nLin, 025 PSAY Posicione("SB1", 1, xFilial("ZZC")+ZZC->ZZC_PRODUT, "B1_DESC")
                                    //@ nLin, 057 PSAY Iif(ZZC->ZZC_SEPARA <> 'S', ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA, ZZC->ZZC_QUANTI) Picture "@E 99999"
                                    @ nLin, 065 PSAY Iif(ZZC->ZZC_SEPARA <> 'S', ZZC->ZZC_VOLUME - ZZC->ZZC_VOLRET, ZZC->ZZC_VOLUME) Picture "@E 99999"
                                    @ nLin, 074 PSAY cPesado
                                    @ nLin, 078 PSAY cEnvase
                                    */
                                    @ nLin, 008 PSAY Iif(ZZC->ZZC_SEPARA <> 'S', ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA, ZZC->ZZC_QUANTI) Picture "@E 99999"
                                    @ nLin, 014 PSAY Iif(Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_ESTOQUE") == 'S', "*", " ")
                                    @ nLin, 015 PSAY ZZC->ZZC_PRODUT Picture "@R XX 99.99.999-99"
                                    @ nLin, 031 PSAY Posicione("SB1", 1, xFilial("ZZC")+ZZC->ZZC_PRODUT, "B1_DESC")
                                    @ nLin, 062 PSAY SubStr(Posicione("SB2", 1, xFilial("SB2")+ZZC->ZZC_PRODUT+Posicione("SB1", 1, xFilial("ZZC")+ZZC->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ"), 1, 10)
                                    @ nLin, 073 PSAY cPesado
                                    @ nLin, 074 PSAY nQtdPro Picture "@E 99999"
                                    @ nLin, 079 PSAY cEnvase
                                    nLin += 1
                                    //         1         2         3         4         5         6         7
                                    //12345678901234567890123456789012345678901234567890123456789012345678901234567890
                                    //       999999 / 999999 / 999999 - 99999  |  999999 / 999999 / 999999 - 99999
                                    If mv_par07 == 1 // Imprimir Outros Pedidos/Borderos
                                       cQry1 := ""
                                       cQry1 += "SELECT ZZC.ZZC_PEDIDO+' / '+ZZC.ZZC_BORDER+' / '+ZZC.ZZC_CARGA AS PEDBOR, SUM(ZZC.ZZC_RETIRA) AS RETIRA "
                                       cQry1 += "FROM "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) "
                                       cQry1 += "WHERE ZZC.ZZC_FILIAL =  '"+xFilial("ZZC")+"' "
                                       cQry1 += "  AND ZZC.D_E_L_E_T_ =  '' "
                                       cQry1 += "  AND ZZC.ZZC_PRODUT =  '"+ZZC->ZZC_PRODUT+"' "
                                       cQry1 += "  AND ZZC.ZZC_CARGA  <> '"+mv_par02+"' "
                                       cQry1 += "  AND ZZC.ZZC_SEPARA =  'S' "
                                       cQry1 += "  AND ZZC.ZZC_DESPAC <> 'S' "
                                       cQry1 += "GROUP BY ZZC.ZZC_PEDIDO+' / '+ZZC.ZZC_BORDER+' / '+ZZC.ZZC_CARGA "
                                       cQry1 += "ORDER BY 1 "
                                       TCQuery cQry1 ALIAS "OPD" NEW
                                       DbSelectArea("OPD")
                                       nPos    := 1
                                       aOutPed := {}
                                       While !Eof()
                                             If nPos == 1
                                                nPos += 1
                                                aAdd(aOutPed, {OPD->PEDBOR+' - '+TransForm(OPD->RETIRA, '@E 99999'), ''})
                                             Else
                                                nPos := 1
                                                aOutPed[Len(aOutPed)][2] := OPD->PEDBOR+' - '+TransForm(OPD->RETIRA, '@E 99999')
                                             Endif
                                             DbSelectArea("OPD")
                                             DbSkip()
                                       Enddo
                                       DbSelectArea("OPD")
                                       DbCloseArea()
                                       If Len(aOutPed) > 0
                                          For nY := 1 To Len(aOutPed)
                                              @ nLin, 008 PSAY aOutPed[nY][1]
                                              @ nLin, 042 PSAY '|'
                                              @ nLin, 044 PSAY aOutPed[nY][2]
                                              nLin += 1
                                          Next
                                       Endif
                                    Endif

                                    aAdd(aResIte, {ZZC->ZZC_PRODUT, ;
                                                   Iif(Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_ESTOQUE") == 'S', "*", ""), ;
                                                   Posicione("SB1", 1, xFilial("ZZC")+ZZC->ZZC_PRODUT, "B1_DESC"), ;
                                                   Iif(ZZC->ZZC_SEPARA <> 'S', ZZC->ZZC_QUANTI - ZZC->ZZC_RETIRA, ZZC->ZZC_QUANTI), ;
                                                   Iif(ZZC->ZZC_SEPARA <> 'S', ZZC->ZZC_VOLUME - ZZC->ZZC_VOLRET, ZZC->ZZC_VOLUME), ;
                                                   Posicione("SB2", 1, xFilial("SB2")+ZZC->ZZC_PRODUT+Posicione("SB1", 1, xFilial("SB1")+ZZC->ZZC_PRODUT, "B1_LOCPAD"), "B2_LOCALIZ") })
                                 Endif
                                 DbSelectArea("ZZC")
                                 DbSkip()
                           Enddo
                        Endif
                     Endif
                  Endif
               Endif
               @ nLin, 000 PSAY Replicate("-", 80)
               nLin += 1
           Next
           @ nLin, 000 PSAY Replicate("*", 80)
           nLin += 2
       Next
       If Len(aResIte) > 0 .and. mv_par06 == 1
          aSort(aResIte,,,{|x,y| x[6]+x[1] < y[6]+y[1]})
          nLin   := 61
          Titulo := "Resumo de Produtos - "+mv_par02
          Cabec1 := "LOCALIZ PRODUTO          DESCRIÇÃO                       QTDE.  VOLUME"
          Cabec2 := ""
          If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
             nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
             nLin += 1
          Endif
          For nX := 1 To Len(aResIte)
              If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                 nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                 nLin += 1
              Endif
              @ nLin, 000 PSAY SubStr(aResIte[nX][6], 1, 7)
              @ nLin, 008 PSAY aResIte[nX][1] Picture "@R XX 99.99.999-99"
              @ nLin, 024 PSAY aResIte[nX][2]
              @ nLin, 025 PSAY aResIte[nX][3]
              @ nLin, 057 PSAY aResIte[nX][4] Picture "@E 99999"
              @ nLin, 065 PSAY aResIte[nX][5] Picture "@E 99999"
              nLin += 1
          Next
       Endif

       SET DEVICE TO SCREEN

       If aReturn[5]==1
          DbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif
       MS_FLUSH()

Return

/*******************************************************************************/
/*** VLDPERG - Ajusta perguntas com o SX1.                                   ***/
/*******************************************************************************/
//LGS#20200212 - Adequação de release 12.1.25 e posteriores
/*Static Function VldPerg()
     //PutSx1(cGrupo  , cOrdem,   cPergunt                , cPerSpa, cPerEng, cVar    , cTipo, nTamanho, nDecimal, nPresel, cGSC, cValid, cF3, cGrpSxg, cPyme, cVar01    , cDef01            , cDefSpa1, cDefEng1, cCnt01, cDef02          , cDefSpa2, cDefEng2, cDef03        , cDefSpa3, cDefEng3, cDef04 , cDefSpa4, cDefEng4, cDef05       ,  cDefSpa5,  cDefEng5, aHelpPor, aHelpEng, aHelpSpa, cHelp    )
       PutSX1("FATR11    ", "01",   "Bord. Pedidos/Despacho  ", "", "", "mv_ch1", "N"  , 1, 0, 1, "C", " ", " ", "   ", " ", "mv_par01", "Pedidos"  , " "     , " "     , " "   , "Despacho"     , " "     , " "     , ""     , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , Nil  , Nil     , Nil     , "FATR11" )
       PutSX1("FATR11    ", "02",   "Numero Bordero          ", "", "", "mv_ch2", "C"  , 6, 0, 0, "G", " ", " ", "   ", " ", "mv_par02", " "        , " "     , " "     , " "   , " "            , " "     , " "     , ""     , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , Nil  , Nil     , Nil     , "FATR11" )
       PutSX1("FATR11    ", "03",   "Analitico/Sintético     ", "", "", "mv_ch3", "N"  , 1, 0, 1, "C", " ", " ", "   ", " ", "mv_par03", "Analítico", " "     , " "     , " "   , "Sintético"    , " "     , " "     , ""     , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , Nil  , Nil     , Nil     , "FATR11" )
       PutSX1("FATR11    ", "04",   "Imprime pedidos         ", "", "", "mv_ch4", "N"  , 1, 0, 1, "C", " ", " ", "   ", " ", "mv_par04", "Separados", " "     , " "     , " "   , "Não Separados", " "     , " "     , "Todos", " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , Nil  , Nil     , Nil     , "FATR11" )
       PutSX1("FATR11    ", "05",   "Imprime itens           ", "", "", "mv_ch5", "N"  , 1, 0, 1, "C", " ", " ", "   ", " ", "mv_par05", "Faltantes", " "     , " "     , " "   , "Todos        ", " "     , " "     , ""     , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , Nil  , Nil     , Nil     , "FATR11" )
       PutSX1("FATR11    ", "06",   "Imprime Resumo Faltantes", "", "", "mv_ch6", "N"  , 1, 0, 1, "C", " ", " ", "   ", " ", "mv_par06", "Sim"      , " "     , " "     , " "   , "Não"          , " "     , " "     , ""     , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , Nil  , Nil     , Nil     , "FATR11" )
       PutSX1("FATR11    ", "07",   "Mostra Ped. Separados   ", "", "", "mv_ch7", "N"  , 1, 0, 1, "C", " ", " ", "   ", " ", "mv_par07", "Sim"      , " "     , " "     , " "   , "Não"          , " "     , " "     , ""     , " "     , " "     , " ", " "     , " "     , " ",  " "     ,  " "     , Nil  , Nil     , Nil     , ".FATR1107." )
Return*/