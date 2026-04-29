#INCLUDE "PROTHEUS.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PES011A2  ³ Autor ³FSW TOTVS CASCAVEL     ³ Data ³ 19/10/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de Entrada genérico no WebService WSSIM3G_PEDIDOVENDA  ³±±
±±³          ³ IMPORTACAO DE PEDIDOS MASTERSALES (Wealth Systems)           ³±±
±±³          ³ Possibilita validação antes de processar e alteração dos     ³±±
±±³          ³ vetores aCABEC e aITENS do MsExecAuto()                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³PARAMIXB[1]: identifica a origem da chamada do PE, sendo:     ³±±
±±³          ³"VLDANTES", "ACABEC", "AITEM", "ANTESPEDIDO", "APOSPEDIDO"    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TOTVS CASCAVEL            B1                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//25/09/2019 - Luís Gustavo - Adequação para release 12.1.25 
User Function PES011A2()
     Local cOrigem       := Alltrim( Upper( PARAMIXB[1] ) )
     Local cArea         := Alias()
     Local aAreaAnt      := U_PegaArea( { "SA1", "SA3", "SB1", "SA4", "SC5" } )
     Local xRet          := .T.
     Local aItensAux     := {} 	// Vetor auxiliar que conterá os itens válidos do pedido
     Local cObsPedido    := "" 	// Variável para a observação com os itens excluídos
     Local lProdExcluido := .F.	// Indica se um item será excluído
     Local i, cRepres, cBco, cCodCli, cLojaCli, cProd, nQtde, cAux, nValor, nQtdItens, cObsAntes, cAuxTrans, cMens
     Local _cGrpEmp, _cFilial, _cNumEmp, _cFilPed, dEmissao, _cPvsim
	  Local _ZPPAR0203 := GetMV( "ZP_PAR0203" ) // Ativa-Desativa copia das Observações C5_OBS para o campo C5_X_OBSFA do MS/SFA

     u_zcfga01( 'PES011A2' ) //LGS#2021201 - Gravação de log de utilização da rotina

     _cGrpEmp := cEmpAnt //Alltrim( FWGrpCompany( ) ) //LGS#20231022 - Retirada funções por recomendação da TOTVS Cascavel e usada variáveis
     _cFilial := cFilAnt //FWCodFil()                 //LGS#20231022 - Retirada funções por recomendação da TOTVS Cascavel e usada variáveis
     _cNumEmp := _cGrpEmp + Alltrim( _cFilial )
     _cFilPed := ""
     DbSelectarea("SA3")
     DbSetOrder(1)
     DbSelectarea("SA4")
     DbSetOrder(1)
     DbSelectArea("SA1")
     DbSetOrder(1)
     DbSelectArea("SB1")
     DbSetOrder(1)
     Dbselectarea("SC5")
     DbOrderNickName("PVSIM") //C5_X_PVSIM
     nQtdItens := 1

     DO CASE 
        CASE cOrigem == "ANTESPEDIDO"
             nQtdItens := 0
             //conout('PES011A2 - ANTESPEDIDO') release 12.1.25
             cMens := 'PES011A2 - ANTESPEDIDO'
             FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', cMens, 0 )
			 FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', "Grupo.: " + _cGrpEmp, 0 )
			 FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', "Filial: " + _cFilial, 0 )
			 //FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', "Origem: " + cOrigem , 0 )
             //*************************************************************************************
             // Primeira parte: validações gerais para permitir ou não a inclusão do pedido
             // Retornar .F. para não permitir e indicar uma mensagem na variável PRIVATE cMsgVldPE
             //*************************************************************************************
             _cFilial := alltrim(cFilAnt)
             cRepres  := ""
             cBco     := ""
             cCodCli  := fPegaCampo( aCabecPE, "C5_CLIENTE" )
             cLojaCli := fPegaCampo( aCabecPE, "C5_LOJACLI" )
             If Empty( cCodCli )
                xRet := .f.
                cMsgVldPE := "Código do Cliente ESTA EM BRANCO !!"
             Endif

             If xRet .and. Empty( cLojaCli )
                If _cGrpEmp == "11"
                   xRet      := .f.
                   cMsgVldPE := "Loja do Cliente " + cCodCli + " ESTA EM BRANCO !!"
                Else
                   cLojaCli := "01"
                Endif
             Endif

             //Verificar se número do pedido no MasterSales já existe! Não incluir caso existir
             If xRet
                _cPvsim := fPegaCampo(aCabecPE,"C5_X_PVSIM")
                If !Empty( _cPvsim )
                   DbSelectArea("SC5")
                   DbSeek(_cPvsim)
                   If Found()
                      If Alltrim( _cPvsim ) == Alltrim( SC5->C5_X_PVSIM )
                         xRet      := .f.
                         cMsgVldPE := "Pedido MasterSales " + _cPvsim + " já EXISTE, inclusão ABORTADA !!"
                      Endif
                   Endif
                Endif
             Endif

		     If xRet .and. !empty(cCodCli)
                DbSelectArea("SA1")
                DbSeek(xFilial("SA1")+cCodCli+cLojaCli)
                If found()
                   cRepres := SA1->A1_VEND
                   cBco := ALLTRIM(SA1->A1_BCO1)
                   DO CASE
                      CASE ( SA1->( FieldPos("A1_X_SIM3G") ) > 0 ) .AND. ( SA1->( FieldPos("A1_MSBLQL") > 0 ) ) .AND. ( SA1->A1_MSBLQL = "1" )
                           xRet := .f.
                      CASE ( SA1->( FieldPos("A1_X_SIM3G") ) > 0 ) .AND. ( SA1->( FieldPos("A1_INATIVO") > 0 ) ) .AND. !EMPTY( ALLTRIM( SA1->A1_INATIVO ) )
                           xRet := .f.
                   ENDCASE
                   If !xRet
                      cMsgVldPE := "Cliente " + cCodCli + "/" + cLojaCli + "-" + Alltrim( SA1->A1_NOME ) + " ESTÁ BLOQUEADO!!"
                   Endif
                Endif
             Endif
		
             If xRet .and. !Empty( cRepres )
                DbSelectArea("SA3")
                DbSeek( xFilial("SA3") + cRepres )
                If Found()
                   If ( SA3->( FieldPos("A3_ENVPED") > 0 ) ) .AND. (SA3->A3_ENVPED != "S")
                      xRet := .f.
                      cMsgVldPE := "REPRESENTANTE "+cRepres+" ESTA BLOQUEADO !!"
                   Endif
                Else
                   xRet := .f.
                   cMsgVldPE := "NAO ENCONTRADO O REPRESENTANTE " + cRepres + " NO CADASTRO !!"
                Endif
             Endif

             If xRet .and. !Empty( cRepres )
                fAltCampo( aCabecPE, "C5_VEND1", cRepres )
             Endif 

             If xRet .and. !Empty( cBco )
                fAltCampo( aCabecPE, "C5_BANCO", cBco )
             Endif 

             cAuxTrans := Alltrim( fPegaCampo( aCabecPE, "C5_TRANSP" ) )
             If !Empty( cAuxTrans )
                DbSelectArea("SA4")
                DbSeek( xFilial("SA4") + cAuxTrans )
                If Found() .and. ( SA4->( FieldPos( "A4_OCORREN" ) > 0 ) ) .AND. ( SA4->A4_OCORREN = "B" )
                   cObsPedido += chr(13) + chr(10) + "Cod Transp. " + cAuxTrans + " BLOQUEADO! Apagado para o pedido ser incluso!"
                   fAltCampo( aCabecPE, "C5_TRANSP", "" )
                Endif
             Endif 
             cAuxTrans := Alltrim( fPegaCampo( aCabecPE, "C5_REDESP" ) )
             If !Empty( cAuxTrans )
                DbSelectArea("SA4")
                DbSeek( xFilial("SA4") + cAuxTrans )
                If Found() .and. ( SA4->( FieldPos("A4_OCORREN") > 0 ) ) .AND. ( SA4->A4_OCORREN = "B" )
                   cObsPedido += chr(13) + chr(10) + "Cod Redesp. " + cAuxTrans + " BLOQUEADO! Apagado para o pedido ser incluso!"
                   fAltCampo( aCabecPE, "C5_REDESP", "" )
                Endif
             Endif

             If xRet
                dEmissao := fPegaCampo( aCabecPE, "C5_EMISSAO" )
                If dEmissao != date()
                   fAltCampo( aCabecPE, "C5_EMISSAO", DATE() )
                Endif
             Endif 

             //*****************************************************************************************
             // Segunda parte: validações sobre todos os itens do pedido para montar um vetor auxiliar
             // somente com os itens válidos e montar um campo de observação contendo os itens removidos
             //*****************************************************************************************
             If xRet
                For i := 1 to Len( aItensPE )
                    cProd 	:= fPegaCampo( aItensPE[i],"C6_PRODUTO" )
                    nQtde 	:= fPegaCampo( aItensPE[i], "C6_QTDVEN" )
                    nValor := fPegaCampo( aItensPE[i], "C6_PRCVEN" )
                    If _cGrpEmp == '01'
					        cOper 	:= fPegaCampo( aItensPE[i], "C6_OPER" )
                                  fAltCampo( aItensPE[i], "C6_OPER", '' )
                       cOper   := fPegaCampo( aItensPE[i], "C6_OPER" )
                       _cTes   := fPegaCampo( aItensPE[i], "C6_TES" )
                       //FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', "TES ANT : " + _cTes, 0 )
                       _cTes    := U_BRFAT053( 'N', cCodCli, cProd )
                       fAltCampo(aItensPE[i], "C6_TES", _cTes )
                       _cTes    := fPegaCampo( aItensPE[i], "C6_TES" )
                       FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', "TES POS : " + _cTes, 0 )
                    Endif

                    lProdExcluido := .F.
                    //*****************
                    dbselectarea("SB1")
                    DbSeek( _cFilial + cProd ) //Obs. É aberto apenas um environment, pedidos com filiais distintas o xFilial() pode trazer filial do environment aberto!!
                    If Found()
                       DO CASE
                          CASE _cGrpEmp <> "11"
					           If SB1->B1_VEND = "N"
					              cAux := "Produto Excluido: " + Alltrim(cProd) + ", Qtde " + Alltrim( Str( nQtde ) ) +" , Valor " + cValToChar( nValor ) + " - VENDA BLOQUEADA, VERIFIQUE!"
					              cObsPedido += chr(13) + chr(10) + cAux
					              lProdExcluido := .t.
					           Endif
                          CASE _cGrpEmp <> "11"
					           If !U_QtdMinProd(cProd,nQtde)
					              cAux := "Produto Excluido: " + Alltrim(cProd) + ", Qtde " + Alltrim( Str( nQtde ) ) +" , Valor " + cValToChar( nValor ) + " - QTDE ABAIXO DO MINIMO, VERIFIQUE!"
					              cObsPedido += chr(13) + chr(10) + cAux
					              lProdExcluido := .t.
					           Endif
                          CASE SB1->B1_MSBLQL = "1"
					               cAux := "Produto Excluido: " + Alltrim(cProd) + ", Qtde " + Alltrim( Str( nQtde ) ) +" , Valor " + cValToChar( nValor ) + " - PRODUTO BLOQUEADO, VERIFIQUE!"
					               cObsPedido += chr(13) + chr(10) + cAux
					               lProdExcluido := .t.
                       ENDCASE
                    Else
                       lProdExcluido := .t.
                       cObsPedido += chr(13) + chr(10) + "NAO ENCONTRADO o produto " + Alltrim(cProd) + " ! O pedido podera ficar inconsistente!"
                    Endif
                    If !lProdExcluido .and. (_cGrpEmp <> "11")
                       lProdExcluido := U_VolQuebrado( cProd, nQtde )
                       If lProdExcluido
                          cAux := "Produto Excluido: " + Alltrim(cProd) + " , Qtde " + cValToChar( nQtde ) + " , Valor " + cValToChar( nValor ) + " - VOLUME INCOMPLETO, VERIFIQUE!"
                          cObsPedido  += chr(13) + chr(10) + cAux
                       Endif
                    Endif

                    If !lProdExcluido
                       nQtdItens++
                       aAdd( aItensAux, aItensPE[i] )
                    Endif
                Next i
                //**********
                //Após validar os itens, ajusta os vetores aCabec e aItens se necessário
                If !Empty( cObsPedido )
                   // Valida se já existe uma observação no Pedido
                   cObsAntes := fPegaCampo( aCabecPE, "C5_X_OBSFA" )
                   If cObsAntes <> nil
                      cObsAntes += cObsPedido
                      // Altera o campo com a nova observação
                      fAltCampo( aCabecPE, "C5_X_OBSFA", cObsAntes )
                   Else
                      // Adiciona a observação no pedido
                      aAdd( aCabecPE, { "C5_X_OBSFA", cObsPedido , NIL } )
                   Endif
                  If   _cGrpEmp == '01'
				           _cNewOBS := ""
					        _cNewOBS += "--- Vld. ANTES_PEDIDO , VERIFIQUE ---" + CHR(13) + CHR(10)
					        _cNewOBS += cObsPedido
				      fAltCampo( aCabecPE, "C5_X_OBSFA", _cNewOBS )
				      Endif
                   // Retorna o vetor auxiliar com os itens válidos para o pedido
                   aItensPE := aClone( aItensAux )
                   aItensAux := nil
                Endif
                //*********
             EndIf
             // Se não adicionou nenhum item retornar falso (Cleber)
             If xRet .and. ( nQtdItens == 0 )
                xRet := .F.
                If !Empty( cObsPedido )
                   cMsgVldPE := cObsPedido
                Else
                   cMsgVldPE := "Pedido está SEM ITENS !!!"
                Endif
             Endif
             cObsPedido := ""
        CASE cOrigem == "ACABEC"
             cObsAntes := fPegaCampo( aCabec, "C5_X_OBSFA" )
             If _ZPPAR0203
                If !Empty( Alltrim( cObsAntes ) )
                   // Adiciona campos específicos do cliente no cabeçalho do pedido 
                   aAdd( aCabec, { "C5_X_OBSFA", "PES011A2 - OBSERVAÇÃO SFA" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cObsAntes, NIL } )
                Endif
             Endif
        CASE cOrigem == "AITEM" //LGS#20231124 - Ajuste pós virada release 12.1.2307 TOTVS SFA
             _aItem := PARAMIXB[2]
             // Adiciona campos específicos do cliente no Item do Pedido
             //aAdd( _aItem, { "C6_OPER", "" , NIL } )
		CASE cOrigem == "APOSPEDIDO"
             // Complemento após inclusão do Pedido

             //Cleber(09/10/20) -> Desmarcar depósito fechado errado para dar um alterar via Schedule por SigaAuto (BRFAT101) pois os pedidos
             //quando estão vindo do MasterSales são inclusos através do ambiente BRASILUX/MATRIZ independente da filial, embora a filial no xml venha correta
             //a mesma não é identificada corretamente no MTA410 quando chegam pedidos de filiais diferentes. Criada essa solução de contorno.
             	If ( SC5->C5_FILIAL = "060101" ) .OR. ( SC5->C5_FILIAL = "010101" )
            	   If ((SC5->C5_FILIAL = "060101") .AND. (SC5->C5_DEPOSI = "S")) .OR. ((SC5->C5_FILIAL = "010101") .AND. (SC5->C5_DEPOSI = "N") .AND. (ALLTRIM(SC5->C5_TRANSP) $ "00700-00573-00800"))
			          dbSelectArea("SC5")
			          RecLock("SC5",.F.)
			             SC5->C5_DEPOSI := ""
			             SC5->C5_TABELA := Iif( Alltrim( SC5->C5_TABELA ) == '2', '', Alltrim( SC5->C5_TABELA ) ) //Ajustado pois na atualização do SFA estava carregando a tabela padrão
			          msUnlock() 
			          //desmarcar C6_CF pois está dando problema
      			      dbselectarea("SC6")
			          dbsetorder(1)
			          dbseek(SC5->C5_FILIAL+SC5->C5_NUM)
			          do while !eof() .and. (SC5->C5_FILIAL == SC6->C6_FILIAL) .AND. (SC5->C5_NUM == SC6->C6_NUM)
				         RecLock("SC6",.F.)
				            SC6->C6_CF := ""
				         msUnlock() 
				         dbskip()
			          enddo 
		           Else
				      If (SC5->C5_FILIAL = "010101") .and. (Alltrim( SC5->C5_TABELA ) == "2" )
    			         dbSelectArea("SC5")
			             RecLock("SC5",.F.)
			                SC5->C5_TABELA := Iif( Alltrim( SC5->C5_TABELA ) == '2', '', Alltrim( SC5->C5_TABELA ) ) //Ajustado pois na atualização do SFA estava carregando a tabela padrão
			             msUnlock() 
					  Endif
				   ENDIF 
	            ENDIF

	//Cleber(07/01/2021) -> Descoberto que não preenche banco no MATA410 desde Outubro/2020, criada solução contorno. Colocada também em MTA410
	dbselectarea("SA1")
	DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
	if found() .and. (empty(ALLTRIM(SC5->C5_BANCO)) .OR. (SC5->C5_TPFRETE != "F") .OR. (SC5->C5_VEND1 != SA1->A1_VEND) .OR. (SC5->C5_FRETE != 0.0)  .OR. (SC5->C5_SEGURO != 0.0))
		dbSelectArea("SC5")
		RecLock("SC5",.F.)
		if empty(ALLTRIM(SC5->C5_BANCO)) .AND. !empty(ALLTRIM(SA1->A1_BCO1))
			SC5->C5_BANCO := SA1->A1_BCO1
		endif 
		IF !empty(SA1->A1_VEND) .AND. (SC5->C5_VEND1 != SA1->A1_VEND)
			SC5->C5_VEND1 := SA1->A1_VEND
		ENDIF 
		if _cGrpEmp == "01"
			SC5->C5_TPFRETE := "F"
		endif
		SC5->C5_EMISSAO := DATE()
		SC5->C5_FRETE 	 := 0.0
		SC5->C5_SEGURO  := 0.0
		msUnlock() 
	endif 
     ENDCASE

     U_VoltaArea(aAreaAnt)

     If !Empty( cArea )
        DbSelectArea( cArea )
     Endif
Return xRet

//************************************************************************
// Função auxiliar para localizar um campo no vetor recebido como
// parâmetro: aCabec ou aItens[N] e retornar o seu conteúdo
//************************************************************************
Static Function fPegaCampo( aVetor, cCampo )
       Local xRet
       Local n

	   n := aScan( aVetor, { |x| Alltrim( x[1] ) == Alltrim( cCampo ) } )
       If n > 0
          xRet := aVetor[n][2] 
       Endif
Return xRet

//************************************************************************
// Função auxiliar para localizar um campo no vetor recebido como
// parâmetro: aCabec ou aItens[N] e alterar o seu conteúdo
//************************************************************************
Static Function fAltCampo( aVetor, cCampo, xConteudo )
       Local xRet
       Local n

       n := aScan( aVetor, { |x| Alltrim( x[1] ) == Alltrim( cCampo ) } )
       If n > 0
          aVetor[n][2] := xConteudo
          xRet         := xConteudo
       Endif
Return xRet
