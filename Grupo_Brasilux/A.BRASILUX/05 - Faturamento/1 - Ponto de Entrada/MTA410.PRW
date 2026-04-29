#include 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "AP5MAIL.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  MTA410  ºAutor  ³ Cleber O. Dominguesº Data ³  12/09/01   º±±F
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º 12/09/01 ³ Ponto de entrada na confirmação da inclusão/alteração do - º±±
±±º          ³ pedido de vendas.                                          º±±
±±º 16/04/04 ³ Se for inclusão e a venda for a vista colocar automatica - º±±
±±º          ³ mente como boleto sim.                                     º±±
±±º 09/11/04 ³ Retirado a pedido do Florivaldo, ajuste no campo boleto -  º±±
±±º          ³ para não gerar caso a condição de pagamento for a prazo.   º±±
±±º 02/01/06 ³ Ajuste linha 80                                          - º±±
±±º 29/09/06 ³ Preenchimento de C5_VEND2 E COMIS 1% P/ GERENTE DE VEND  - º±±
±±º 15/05/09 ³ Nova politica comercial de descontos                     - º±±
±±º 02/07/09 ³ Determinar CST pois nao grava corretamente.              - º±±
±±º 25/09/19 ³ Luís Gustavo - Adequação para release 12.1.25              º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MTA410()
     //////////////////////////////////////////////////////
     // Calculo da comissao de acordo com o lucro minimo //
     //////////////////////////////////////////////////////
     // aCols[2] : Cod.Produto                           //
     // aCols[5] : qtde na 1a. unidade de medida         //
     // aCols[6] : Preco de venda unitario               //
     // aCols[8] : Preco de venda total                  //
     // aCols[19]: comissao %                            //
     // aCols[9] : TES                                   //
     // aCols[10] : CFOP                                 //
     //////////////////////////////////////////////////////
     
     Local cComp 
     Local cMensErro      := ""
     Local _nVlrTotMin    := 0   //Valor total mínimo para entrar dentro da Política de Vendas!
     Local nVolTotal      := 0
     Local nSaldoVend     := 0   //Saldo de vendas do mês para o cliente
     Local _nVlrCDesc     := 0
     Local _nVlrComiss    := 0
     Local _nVlrLucro     := 0
     Local _nPorcComiss
      
     Local lSisRev        := .f. //Participa de política de venda p/ Comércio/Revenda? Caso positivo, verificar se o pedido atende à regra.
     Local lProblPrazo    := .f. //Bloquear pedido caso prazo médio não seja respeitado, independente de qualquer coisa
     Local lDescOk
     Local lRegB1
     Local lEmbaemG1, lAux

     Local nPosENTREG     := aScan( aHeader, { |x| Trim( x[2] ) == "C6_ENTREG" } ) //Posicionamento do campo C6_ENTREG no aHeader
     Local nPosC6SIM3G    := aScan( aHeader, { |x| Trim( x[2] ) == "C6_X_SIM3G"} ) //Posicionamento do campo C6_X_SIM3G no aHeader
     Local nQtdComp, nDescPerm, nPos1, nPos2
     Local nVar, nAux, cAux, i, nAuxQtde, nAuxVol
     Local nInd, nIndAnt, _nComisCal, cTrpBrz
     Local nDesc1, nDesc2, cPerCal, cPerVen, nMes, nAno, nTolerancia, j, cAuxMens
     Local aEmba          := {}  //Tipos de Embalagens utilizada, Colunas: 1-Cód Emba; 2-Qtde de Embal; 3-Qtde p/ Juntar Vol; 4-Qtde Vol. produtos que não juntam vol; 5-Qtde BL p/ verif. se fecham vol; 6-Rel. Volume
     Local lCalcVol       := .t. // Det. se vai incluir a relação de volume, auxiliar para prevenir probl. de numeração de pedido
     Local  nCubagem, nRegB1
     Local nVlrTot        := 0, nVlrFrete := 0, nPercFrete := 0 //,lCalcFrete := .t.


     //Alterado por Nelieder em 09/11/23 (solicitado por Gustavo via Teams)
     //Local _cGrpEmp   := Alltrim( FWGrpCompany( ) )                //Grupo de empresas
     //Local _cFilial   := Alltrim( FWCodFil( ) )                    //Código da Filial

     Local _cGrpEmp := cEmpAnt //Alltrim( FWGrpCompany( ) ) //LGS#20231022 - Retirada funções por recomendação da TOTVS Cascavel e usada variáveis
     Local _cFilial := cFilAnt //FWCodFil()                 //LGS#20231022 - Retirada funções por recomendação da TOTVS Cascavel e usada variáveis
     
     Local _cNumEmp   := Alltrim( _cGrpEmp ) + Alltrim( _cFilial ) //Grupo + Filial
     Local _aArea     := GetArea()
     Local _lCampanha := .T. //Chamado 020971, criar política de campanhas. Em princípio considerar verdadeiro que pedido é participante de campanha, validar em seguida
     Local _lRet      := .T. //Variavel lógica que retorna a validação geral do ponto de entrada, se aceita(.t.) ou nao(.f.)
     Local _cPrdVolQb := ""  //Solic. Cleiton em 15/10/14, relacionar produtos vendidos com volume quebrado na Dissoltex e enviar por e-mail.
     Local _cObs      := Alltrim( M->C5_X_OBSFA )
     Local _lIpiZeroM := .F. //Itens de IPI Zero Misturados com itens de IPI maior que zero. Chamado 007956
     Local _nIpiAnt   := 0.0
     Local _cCondPag  := M->C5_CONDPAG //Guarda o código da cond. de pagamento digitada
     Local _nQtdeParc := 0
     Local _aPrazos   := {}  // Vetor com prazos em dias + % de cada parcela sobre total e cálculo do prazo médio
     Local _nPrzMedio := 0   //Prazo médio em dias da venda
     Local _cUfCliFor := ""  //Estado do Cliente ou Fornecedor
     Local _cTipoCons := ""
     Local _cCnpj     := ""
     Local _cDeposito := Alltrim( M->C5_DEPOSI )  //Auxiliar para determinar se pedido é remessa pra depósito ou não.
     Local _oTmpTable
     Local _aStrut    := {}
     Local _cArqTmp
     Local _nVlrTPed  := 0   //Valor total do pedido
     Local _nVlrTDup  := 0   //Valor total que gera FINANCEIRO!
     Local _nSomVlTab := 0   //Valor total do pedido (apenas itens que GERAM FINANCEIRO!) pelo valor de tabela
     Local _lGeraDup  := .f. //Verifica se gera duplicata ou não
     Local _nContItem := 0   //Conta a qtde de itens do pedido
     Local _lProdEst  := .f. //Verifica se é produto de estoque
     Local _cTabCamp  := Iif( Alltrim( M->C5_TABELA ) == '2', '', Alltrim( M->C5_TABELA ) ) //Ajustado pois na atualização do SFA estava carregando a tabela padrão
     Local _nIcmCamp  := 0
     Local _cCondCamp
     Local _nX
     Local _nI
     Local _nPosVolIt := aScan( aHeader, { |x| Trim( x[2] ) == "C6_VOLITEM"} ) //Posicionamento do campo C6_VOLITEM no aHeader
     Local _nPosPROD  := aScan( aHeader, { |x| Trim( x[2] ) == "C6_PRODUTO"} ) //Posicionamento do campo C6_PRODUTO no aHeader
     Local _nPosLOCAL := aScan( aHeader, { |x| Trim( x[2] ) == "C6_LOCAL"  } ) //Posicionamento do campo C6_LOCAL   no aHeader
     Local _nPosPRCVE := aScan( aHeader, { |x| Trim( x[2] ) == "C6_PRCVEN" } ) //Posicionamento do campo C6_PRCVEN  no aHeader
     Local _nPosPRUNI := aScan( aHeader, { |x| Trim( x[2] ) == "C6_PRUNIT" } ) //Posicionamento do campo C6_PRUNIT  no aHeader
     Local _nPosDESCO := aScan( aHeader, { |x| Trim( x[2] ) == "C6_DESCONT"} ) //Posicionamento do campo C6_DESCONT no aHeader
     Local _nPosVALDE := aScan( aHeader, { |x| Trim( x[2] ) == "C6_VALDESC"} ) //Posicionamento do campo C6_VALDESC no aHeader
     Local _nPosVALOR := aScan( aHeader, { |x| Trim( x[2] ) == "C6_VALOR"  } ) //Posicionamento do campo C6_VALOR   no aHeader
     Local _nPosQTDVE := aScan( aHeader, { |x| Trim( x[2] ) == "C6_QTDVEN" } ) //Posicionamento do campo C6_QTDVEN  no aHeader
     Local _nPosTES   := aScan( aHeader, { |x| Trim( x[2] ) == "C6_TES"    } ) //Posicionamento do campo C6_TES     no aHeader
     Local _nPosCST   := aScan( aHeader, { |x| Trim( x[2] ) == "C6_CLASFIS"} ) //Posicionamento do campo C6_CLASFIS no aHeader
     Local _nPosFCI   := aScan( aHeader, { |x| Trim( x[2] ) == "C6_FCICOD" } ) //Posicionamento do campo C6_FCICOD  no aHeader
     Local _nPosCF    := aScan( aHeader, { |x| Trim( x[2] ) == "C6_CF"     } ) //Posicionamento do campo C6_CF      no aHeader
     Local _nPosVlLcr := aScan( aHeader, { |x| Trim( x[2] ) == "C6_VLRLUCR"} ) //Posicionamento do campo C6_VLRLUCR no aHeader
     Local _nPosITEM  := aScan( aHeader, { |x| Trim( x[2] ) == "C6_ITEM"   } ) //Posicionamento do campo C6_VLRLUCR no aHeader
     Local _nPosLEsp  := aScan( aHeader, { |x| Trim( x[2] ) == "C6_LUCRESP"} ) //Posicionamento do campo C6_LUCRESP no aHeader
     Local _nDel      := len(aHeader)+1
     Local _lVolJunto
     Local _nQtdeVol
     Local _nPesoLiqu := 0
     Local _nPesoBrut := 0
     Local _nBaseIcms := 0
     Local _nQtdMinEs := 0   //Quantidade mínima para entrar na tabela 1
     Local _nPerInt   := 0   //Soma de percentuais internos na formação de preços, exceto lucro e comissão
     Local _nLC1      := 0   //Lucro + Comissão na tabela 1
     Local _nLC2      := 0   //Lucro + Comissão na tabela 2
     Local _nValTab   := 0   //Valor total de tabela do item
     Local _nValUnTab := 0   //Valor unitário de tabela do item
     Local _nEntrega  := 5   //Prazo de entrega em dias a ser contado à partir da data de liberação do pedido
     Local _cAuxLoc   := ''  //Armazem do produto para faturamento nos itens do pedido
     Local _lSoSolven := .t. // determina se o pedido é exclusivo de solventes para poder entrar na política de desconto extra para esse tipo de prod(20/03/2012)
     Local cCst       := ''
     Local cEstado    := GETMV( "MV_ESTADO" )
     Local _lVolQuebr
     Local aAuxEmba   := {}
     Local nPesoLiquTotal := 0
     Local nPesoBrutTotal := 0
     Local nICMPAD    := GETMV( "MV_ICMPAD" )
     Local nTxPIS     := GETMV( "MV_TXPIS" )
     Local nTxCofin   := GETMV( "MV_TXCOFIN" )
     Local _nPercIcms := 0
     Local _nPisCof
     Local nVlrProd   := 0   //Valor total do produto do item
     //Local aPrecos    := {}  //Vetor que receberá os precos minimos para um item de produto de acordo com as 6 faixas de desconto definidas
     //Local aPrcMin    := { 0, 0, 0, 0, 0, 0 }  //Vetor com a soma dos preços mínimos a serem praticados de acordo com a politica de venda
     Local _aNewPol   := {}
     Local _aPolDes   := {}
     Local _nICMPol   := 0 //Valor do ICMS do estado do cliente.
     //Local _aNewMin    := { 0, 0, 0, 0, 0, 0 }  //Vetor com a soma dos preços mínimos a serem praticados de acordo com a politica de venda
     Local nValorHoje := 0
     Local nJuros     := GETMV( "MV_JUROS" )
     Local _nLucroItem:= 0
     Local _nValReal  := 0   //Total de LUCRO+COMISSAO
     Local nAuxLucro
     Local _nMedComiss:= 0   //Comissão de referência ponderada, cadastrada nos produtos
     Local _nMedLucro := 0   //Lucro mínimo de referência, pré-definido nos produtos
     Local _lMisturad := .f. //Informa se há itens de estoque misturados c/ itens Não Estoque!
     Local _lMudouEst := .f. // Identifica se mudou item de estoque p/ não estoque ou vice versa para verificar se existe itens misturados
     Local _cLogPed   := ''
     Local _cAuxMsg   := ''
     Local _nZPPAR37  := GETMV( "ZP_PAR0037" )  //LGS#20220201 - Parametro do Valor Total Minimo do Pedido de Vendas - POLITICA COMERCIAL BRASILUX
     Local _nZPPAR38  := GETMV( "ZP_PAR0038" )  //LGS#20220201 - Parametro do Prazo Médio de Pagamento - POLITICA COMERCIAL BRASILUX 
     Local _cZPPAR40  := GETMV( "ZP_PAR0040" )  //LGS#20220201 - Parametro que indica empresas do grupo com liberação automatica de pedidos 
     Local _lZPPAR50  := GETMV( "ZP_PAR0050" )  //               Parametro para indicar se a regra de politica comercial solvente está habilitada
     Local _cZPPAR51  := GETMV( "ZP_PAR0051" )  //               Parametro para indicar linhas que fazem parte da politica de desconto do solvente
     Local _nPosProx  := 0
     Local _lComisZer := .f. //Variável que identifica o pedido com item de comissão zero.
     Local _nComisZer := 0   //Variável que identifica o pedido a quantidade de itens de comissão zero.
     Local _cCnpje    := ''   // Jose 20/10/022
     //Local _dZPPAR84  := GETMV( "ZP_PAR0084" ) //LGS#20230324 - Data considerada para acrescimo de desconto e comissão - CONVENÇÃO COMERCIAL 2023
     //Local _dZPPAR93  := GETMV( "ZP_PAR0093" ) // Data Final para acrescimo de desconto e comissão - CONVENÇÃO COMERCIAL 2023
     //Local _cZPPAR85  := GETMV( "ZP_PAR0085" ) //LGS#20230324 - Empresas/Filiais consideradas para acrescimo de desconto e comissão - CONVENÇÃO COMERCIAL 2023
     //Local _nZPPAR87  := GETMV( "ZP_PAR0087" ) //LGS#20230324 - Percentual de comissão minimo - CONVENÇÃO COMERCIAL 2023
     Local _ZPPAR0100 := GetMV( "ZP_PAR0100" ) // Envia E-mail para Deposito informando que pedido é CIF

     // incluido por Nelieder em 15/06/2023 Projeto Comissão fixa SP
     Local _ZPPAR0106 := GetMV( "ZP_PAR0106" ) // Lista Representantes Comissao Fixa
     Local _ZPPAR0107 := GetMV( "ZP_PAR0107" ) // Lista politica
     Local _ZPPAR0108 := GetMV( "ZP_PAR0108" ) // Lista de Produtos Comissao Fixa 
     Local _ZPPAR0109 := GetMV( "ZP_PAR0109" ) // Lista de Embalagens Comissao Fixa
     Local _ZPPAR0110 := GetMV( "ZP_PAR0110" ) // Habilita Calculo Comissão Fixa 
     Local _ZPPAR0202 := GetMV( "ZP_PAR0202" ) // CNPJ Liberados
     Local _ZPPAR0204 := GetMV( "ZP_PAR0204" ) // Desabilita trig_inclui_SC5010
     Local _ZPPAR0205 := GetMV( "ZP_PAR0205" ) // Desabilita trig_atualiza_SC5010
     Local _PerFrete  := 0                     // Percentual de frete que será cobrado na nota fiscal (parte cliente paga, parte brasilux)  André em 21-08-25
     Local lFreteTerc := .F.                   // Frete 3º (não é com caminhão próprio) André em 21-08-25

     Local nPosi      := 0
     Local nAtu := 0
     
      
      //Enquanto houver processo conforme o nAtu
      // localiza posição da rotina divide pedido
      While ! Empty(ProcName(nAtu))
         if ProcName(nAtu) == "U_ZFATP01"
            nPosi := nAtu
            EXIT
         EndIf   
         nAtu++
      EndDo

     u_zcfga01( 'MTA410' )  //LGS#2021214 - Gravação de log de utilização da rotina

     DbSelectArea("SA1")    //Clientes
     SA1->( DbSetOrder(1) )

     DbSelectArea("SF4")    //Tipos de Entradas e Saídas
     SF4->( DbSetOrder(1) )

     DbSelectArea("CFD")    //FICHA DE CONTEUDO DE IMPORTAÇÃO
     CFD->( DbSetOrder(3) ) //CFD_FILIAL+CFD_FCICOD                                                                                                                                           

     DbSelectArea("SB1")    //Produtos
     SB1->( DbSetOrder(1) )

     DbSelectArea("SB2")    //Saldos em Estoque
     SB2->( DbSetOrder(1) )

     DbSelectArea("SX5")    //Tabelas
     SX5->( DbSetOrder(1) )

     DbSelectArea("DA1")    //Itens da Tabela de Preço  
     DA1->( DbSetOrder(1) ) //Cod. Tabela + Cod.Produto + Faixa + Item                                                                                 

     DbSelectArea("DA0")    //Tabela de Preço  
     DA0->( DbSetOrder(1) ) //Cod. Tabela                                                                                                             

     DbSelectArea("SA2")    //Fornecedores
     SA2->( DbSetOrder(1) )

     DbSelectArea("SA3")    //Representantes
     SA3->( DbSetOrder(1) )

     DbSelectArea("SB5")    //Tabela de Preços 2
     SB5->( DbSetOrder(1) )

     DbSelectArea("SG1")    //Estrutura de produtos
     SG1->( DbSetOrder(1) )
     //********************************************************************************************************************//
     //***                     VALIDAÇÕES INICIAIS E AJUSTES DO CABEÇALHO DO PEDIDO DE VENDAS - SC5                     ***//
     If Empty( _cGrpEmp )
        _cGrpEmp := "01"
     Endif
     If Empty( _cFilial )
        _cFilial := "010101" //Alguns Pedidos MasterSales não identificam filial!!
     Endif
     M->C5_TABELA := _cTabCamp
     M->C5_FRETE  :=  0
     If ( SC5->( FieldPos( "C5_APROVA" ) ) > 0 ) //(Cleber 23/09/20) -> Caso a origem do pedido for do Gestão de Contratos desconsiderar customizações Brasilux
        If !Empty( M->C5_MDCONTR ) .OR. !Empty( M->C5_MDNUMED ) .OR. !Empty( M->C5_MDPLANI )
           M->C5_APROVA := "1" //Considerar pedido aprovado(na aprovação customizada) caso venha do módulo Gestão de Contratos
        Endif
        If _cFilial $ Alltrim( _cZPPAR40 ) //Enlarge, venda de lenha para tecpolpa e Resina - liberação automática
//------------  Jose dia 07/10/022
           DbSelectArea("SA1")
           If SA1->( DbSeek( xFilial("SA1") + M->C5_CLIENTE ) )
              _cCnpje   := Alltrim( SUBSTRING( SA1->A1_CGC,1,8) )
           Endif
           //If _cCnpje == '72770878' .Or.  _cCnpje == '59599555' alterado chamado R2167 07/08/23
            If _cCnpje $ Alltrim( _ZPPAR0202 ) 
              M->C5_APROVA := "1"
           EndIf
        Endif // acrscentado por Jose 07/10/2022
     Endif
     If ( _cGrpEmp == "01" ) .and. ( SubStr( _cFilial, 1, 2 ) >= "07" ) //Se estiver nas empresas de Gestão Imobiliária não executar
        Return( .T. )
     Endif
     If SC5->( FieldPos( "C5_USRAPR" ) ) > 0 //(Cleber 24/07/19) -> Marcador quando estiver em aprovação de pedido frete CIF, não passar pelo ponto de entrada!
        If M->C5_USRAPR = "#*#CIF#*#"
           Return( .T. )
        Endif
     Endif
     If SC5->( FieldPos( "C5_X_SIM3G" ) ) > 0 //Marcar, em princípio, para não enviar pedido para MasterSales
        M->C5_X_SIM3G := "N"
        M->C5_X_EXPO  := " "
     Endif
     If SC5->( FieldPos( "C5_XCONF" ) ) > 0 //Marcar, em princípio, comissão variável, pode inclusive participar de compensação de comissão
        M->C5_XCONF := .F. //Comissão Variavel (.F.) Comissão Fixa (.T.)
     Endif
     //***                   FIM VALIDAÇÕES INICIAIS E AJUSTES DO CABEÇALHO DO PEDIDO DE VENDAS - SC5                   ***//
     //********************************************************************************************************************//

     If _cGrpEmp == "01"

        //*********************************************************************************************************************//
        //***                                  ABERTURA DE TABELAS ESPECIFICAS DA BRASILUX                                  ***//
        DbSelectArea("SZ7")    //Cadastro de Cidades
        SZ7->( DbOrderNickName("SZ7001") )

        DbSelectArea("SZ1")    //Qtde de Volumes por Embalagem
        SZ1->( DbOrderNickName("SZ1001") )

        DbSelectArea("ZZO")    //Qtde de Volumes por Embalagem
        ZZO->( DbSetorder(1) )
        /************************************************************************************************************************/
        /***                               CRIAÇÃO DO ARQUIVO TEMPORÁRIO - UTILIZADO NA BRASILUX                              ***/
        aadd( _aStrut,{ "PRODUTO", "C", 10, 0 } )
        aadd( _aStrut,{ "VOLUME" , "N", 15, 4 } )
        _cArqTmp := "ZTMP"
        If Select( _cArqTmp ) <> 0
           DbSelectArea( _cArqTmp )
           _cArqTmp->( DbCloseArea() )
        Endif
        _oTmpTable := FWTemporaryTable():New( _cArqTmp )
        _oTmpTable:SetFields( _aStrut )
        _oTmpTable:AddIndex( "cInd01", { "PRODUTO" } )
        _oTmpTable:Create()
        DbSelectArea( _cArqTmp )
        DbSetOrder(1)
        /************************************************************************************************************************/
        DbSelectArea("SZ5")    //Tabela de embalagens
        SZ5->( DbSetOrder(1) )
        /**********************************************************************************************************************************/
        /***                                                   VALIDAÇÕES DA BRASILUX                                                   ***/
        /**********************************************************************************************************************************/
        _cLogPed += 'Pedido:' + M->C5_NUM + ' - CLIENTE: ' + M->C5_CLIENTE + '/' + M->C5_LOJACLI + ' - '
        M->C5_NAOCONF := "N"
        If Empty( Alltrim( M->C5_TPFRETE ) ) //Cleber (26/09/2019) -> Caso não venha preenchido o tipo de frete, preencher com FOB
           M->C5_TPFRETE := "F"
        Endif
        //Gravar se pedido possui solvente, marcar primeiro como N para, quando achar algum, marcar como S
        If Len( _cNumEmp ) == 8 .and. _cNumEmp $ "01010101.01060101"
           DbSelectArea("SX5")  //Tabelas
           If SX5->( DbSeek( xFilial("SC5") + "96" + M->C5_NUM ) )
              RecLock( "SX5", .F. )
                 SX5->X5_DESCRI  := "N"
                 SX5->X5_DESCSPA := "N"
                 SX5->X5_DESCENG := "N"
              SX5->( MsUnLock() )
           Endif
        Else
           _lCampanha := .f. // Campanha somente implantar para Brasilux/Matriz e Dissoltex
        Endif
        fCalPrzMed( @_cCondPag, @_nQtdeParc, @_aPrazos, @_nPrzMedio, @_lRet )

        If M->C5_TIPO $ "D_B"
           DbSelectArea("SA2")
           If SA2->( DbSeek( xFilial("SA2") + M->C5_CLIENTE ) )
              _cUfCliFor := SA2->A2_EST
              _cTipoCons := SA2->A2_CLAS
              _cCnpj     := Alltrim( SA2->A2_CGC )
           Endif
           //Cleber(13/09/21), pedido não passa por análise se não existir id de quem cadastrou. Identificação de quem está incluindo/alterando o pedido. 
           If INCLUI .OR. Empty( M->C5_CAD )
              M->C5_CAD   := Iif( !Empty( M->C5_PEDREPR ) .OR. !Empty( M->C5_X_PVSIM ), M->C5_VEND1, RTrim( cUserName ) )
              M->C5_DTCAD := dDataBase
              M->C5_FLAG  := "N" // Flag informando que o pedido não foi impresso
           Endif
           _lCampanha := .f.
        Else
           DbSelectArea("SA1")
           SA1->( DbSeek( xFilial("SA1") + M->C5_CLIENTE ) )
           If Found()
              _cUfCliFor := SA1->A1_EST
              _cTipoCons := SA1->A1_CLAS
              _PerFrete  := SA1->A1_XPERFRE
              If INCLUI
                 If SA1->A1_BOLETO = 'S' .AND. _cCondPag == "001"  // Cleber(16/04/04) =>Se for venda à vista, colocar automaticamente como boleto
                    M->C5_BOLETO  := "S"
                 Endif
                 If !Empty( M->C5_X_PVSIM ) 
                    M->C5_TIPOVEN := "E"
                    M->C5_DESCON1 := 0
                    M->C5_VEND1   := SA1->A1_VEND
                    M->C5_EMISSAO := DATE()
                    M->C5_FRETE   := 0.0
                    M->C5_SEGURO  := 0.0
                 Endif
                 If Empty( M->C5_VEND1 )
                    M->C5_VEND1   := SA1->A1_VEND
                 Endif
                 //Cleber(07/01/21) -> Descobri que desde outubro/2020 não está gravando banco
                 If !Empty( SA1->A1_BCO1 ) .AND. Empty( M->C5_BANCO )
                    M->C5_BANCO := SA1->A1_BCO1
                 Endif 
              Endif
              _cCnpj := Alltrim( SA1->A1_CGC )
              //Chamado 020971, campanha pra revenda
              //Chamado 024742-> Extender campanha pra TODOS os segmentos
           Endif
        Endif
        If _cUfCliFor $ "AC_AL_AM_AP_BA_CE_DF_ES_GO_MA_MS_MT_PA_PB_PE_PI_RN_RO_RR_SE_TO"
           _nICMPol := 7
        ElseIf _cUfCliFor $ "RJ_MG_PR_RS_SC"
               _nICMPol := 12
        ElseIf _cUfCliFor $ "SP"
               _nICMPol := 18
        Endif
        _cLogPed += SA1->A1_NOME + ' - UF: ' + _cUfCliFor + '  |  ICMS EST.: ' + TransForm( _nICMPol, "@E 99.99" ) + Chr(13) + Chr(10)
        _cLogPed += 'Tipo Consumidor: ' + _cTipoCons + ' Emissão: ' + DTOC( M->C5_EMISSAO ) + Chr(13) + Chr(10)
        _cLogPed += 'Vendedor: ' + M->C5_VEND1 + '   Condição de Pagamento: ' + _cCondPag + Chr(13) + Chr(10)
        _cLogPed += Chr(13) + Chr(10)
        If _cDeposito == Nil
           _cDeposito := ""
        Endif 
        _cDeposito := "" // andre em 27-02-25 (seguir a regra da transportadora ao invés de deixar o usuário escolher o local de despacho)
        //Vefificar se cidade NÃO ESTÁ HABILITADA PARA Dep. Fechado
        //If !( SubStr( _cNumEmp, 1, 4 ) == "0101" ) //Somente a empresa 01 opera com deposito
        //   _cDeposito := "N"
        //Endif
        _cDeposito := Iif( !( ( _cNumEmp = "01010101" ) .OR. ( _cNumEmp = "01010106" ) .OR. ( _cNumEmp = "01010107" ) .OR. ( _cNumEmp = "01010108" ) ), "N", _cDeposito ) //Se não for Brasilux/Matriz não sai pelo depósito a não ser que tenha sido solicitado pelo usuário
        If ( ( M->C5_TRANSP = "00700" ) .OR. ( M->C5_TRANSP = "00573" ) .OR. ( M->C5_TRANSP = "00800" ) ) // - andre em 27-02-25  //.and. Empty( _cDeposito ) - andre em 27-02-25 
           _cDeposito := "S"
        Elseif   (( M->C5_TRANSP = "" ) .OR. !( M->C5_TRANSP = "00250" )) .OR. ( _cNumEmp = "01010108" ) //.or. Empty( _cDeposito )/.and.  ( Empty( _cDeposito ) .OR. (_cDeposito <>'N') )
            _cDeposito := "A"
        Elseif ( (M->C5_TRANSP = "00250") .OR.( M->C5_TRANSP = "099998" ) .OR. ( M->C5_TRANSP = "099999" )) .or. Empty( _cDeposito )
            _cDeposito := "N"
        Endif
        If !( SubStr( _cNumEmp, 1, 4 ) == "0101" ) //Somente a empresa 01 opera com deposito
           _cDeposito := "N"
        Endif        
        //Chamado 020971, campanha pra revenda
        If _lCampanha .and. Empty( _cTabCamp )
           _lCampanha := .f.
        Endif 
        _cTabCamp := PadR( _cTabCamp, TamSX3("C5_TABELA")[1], " " )
        _cLogPed += 'Transportadora: ' + M->C5_TRANSP + 'Deposito: ' + _cDeposito + Chr(13) + Chr(10)
        _cLogPed += 'Campanha: ' + Iif( _lCampanha, 'SIM', 'NÃO') + '  -  Tabela: ' + _cTabCamp  + Chr(13) + Chr(10)
        _cLogPed += Chr(13) + Chr(10)
        /**********************************************/
        /*** COMEÇA A VARREDURA DOS ITENS DO PEDIDO ***/
        /**********************************************/
        For _nX := 1 to Len( aCols )
            If !aCols[ _nX ][ Len( aHeader ) + 1 ] //Se não for registro deletado
               _nContItem ++
               aCols[ _nX ][ _nPosVolIt ] := 0
               _cAuxPro := Alltrim( aCols[_nX][ _nPosPROD ] )
               If Len( _cAuxPro ) == 12 .and. Substr( _cAuxPro, 4, 2 ) $ "87-88"
                  _cAuxMsg := "Pedido possui item(ns) da linha 87 e/ou 88"
                  If !_cAuxMsg $ _cObs
                     _cObs += Chr(13) + Chr(10) + _cAuxMsg
                  Endif
               Endif

               _lVolJunto := U_VolJunto( aCols[_nX][ _nPosPROD ] ) // Determinar em lVolJunto se produto junta volume c/ outros ou não, p/ efeito de cálculo de volumes
               _nQtdeVol  := 0
               _nPesoLiqu := 0
               _nPesoBrut := 0
               _nQtdMinEs := 999999   //Quantidade mínima para considerar tabela de preço de produtos de estoque
               _nPerint   := 0
               _nLc1      := 0
               _nLc2      := 0
               _nValTab   := 0
               _nValUnTab := 0
               _lProdEst  := .f. //Verifica se é produto de estoque, para det. de lucro

               DbSelectArea("SB1") //Produtos
               If SB1->( DbSeek( xFilial("SB1") + aCols[ _nX ][ _nPosPROD ] ) )
                  _lProdEst := Iif( SB1->B1_ESTOQUE == "S", .t., .f. )
                  //Itens de IPI Zero Misturados com itens de IPI maior que zero. Chamado 007956
                  If !_lIpiZeroM .AND. _nContItem > 1 .AND. ( SB1->B1_IPI == 0.0 .AND. _nIpiAnt > 0.0 ) .OR. ( SB1->B1_IPI > 0.0 .AND. _nIpiAnt = 0.0 )
                     _lIpiZeroM := .T.
                  Endif
                  _nIpiAnt := SB1->B1_IPI

                  If Len( Alltrim( SB1->B1_COD ) ) == 12
                     If !_lProdEst
                        DbSelectArea("SZ5")
                        If SZ5->( DbSeek( xFilial("SZ5") + SubStr( aCols[_nX][_nPosPROD], 11, 2 ) ) )
                           _nQtdMinEs := SZ5->Z5_QTDVEN
                           If aCols[_nX][_nPosQTDVE] >= _nQtdMinEs //Se atingir qtde mínima considerar como prod. de estoque
                              _lProdEst := .t.
                           Endif
                        Endif
                     Endif
                  Endif
                  _nLc1      := SB1->B1_COMIS + SB1->B1_LUCRO
                  _nLc2      := SB1->B1_COMIS + SB1->B1_LUCRO2
                  _nValUnTab := SB1->B1_PRV1
                  If !_lProdEst
                     DbSelectArea("SB5")
                     If SB5->( DbSeek( xFilial("SB5") + aCols[_nX][_nPosPROD] ) )
                        _nValUnTab := SB5->B5_PRV2
                     Endif
                     _nEntrega := 15 //Se tiver produtos específicos o prazo se estende para 15 dias úteis
                  Endif
                  _nValTab := _nValUnTab * aCols[_nX][_nPosQTDVE] //Em princípio, fica com o valor tabela 1, logo abaixo, se for o caso troca caso não seja produto de estoque
                  _nPerInt := SB1->B1_PERINT / 100
                  aCols[_nX][_nPosLEsp] := Iif( _lProdEst, SB1->B1_LUCRO, SB1->B1_LUCRO2 ) // % de Lucro esperado para o item
               Else
                  _lRet := .f.
                  cAuxMens := "Não encontrado o PRODUTO " + aCols[_nX][_nPosPROD] + " no cadastro. Contacte o Adm. do Sistema!"
                  If fValAtrib("l410Auto") <> "U" .and. l410Auto  .and. ProcName(nPosi) <> "U_ZFATP01" //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
                     FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAuxMens, 0 )
                  Else
                     MessageBox( cAuxMens, "Atenção", 16 )
                  Endif
                  Exit
               Endif
               //********************************************************************************************************************//
               //***                                   DETERMINAÇÃO DO LOCAL POR ITEM DO PEDIDO                                   ***//
               //(01/08/12) - Cleber - Determinar saída sempre da fábrica 1 na Matriz
               If SubStr( _cFilial, 1, 2 ) == "01" .OR. Substr( _cFilial, 1, 2 ) == "06" 
                  //16-09-2014 -> Cond. temporaria para separar estoque de Guarulhos até implantar estoque por endereços
                  _cAuxLoc := fDetEst( _cFilial, _cDeposito, _nPosLOCAL, _nX )
               Endif
               If !aCols[_nX][_nPosLOCAL] == _cAuxLoc
                  aCols[_nX][_nPosLOCAL] := _cAuxLoc
               Endif
               //********************************************************************************************************************//
               // Zerar Descontos para não aparecer valor maior em Valor Contabil em SF3
               nAux := TamSX3( "C6_PRCVEN" )[2]
               aCols[_nX][_nPosPRCVE] := Round( U_DescPed( _nValUnTab, aCols[_nX][_nPosPRCVE], M->C5_DESCON1, M->C5_DESCON2, M->C5_DESCON3 ), nAux )
               aCols[_nX][_nPosPRUNI] := aCols[_nX][_nPosPRCVE]
               aCols[_nX][_nPosDESCO] := 0
               aCols[_nX][_nPosVALDE] := 0
               nAux := TamSX3("C6_VALOR")[2]
               IF M->C5_TIPO == "N"
                  aCols[_nX][_nPosVALOR] := Round( aCols[_nX][_nPosPRCVE] * aCols[_nX][_nPosQTDVE], nAux )
               Else
                  _lCampanha := .f. //Chamado 020971, campanha somente pra pedidos de venda normais
               Endif
               M->C5_DESC1 := 0
               M->C5_DESC2 := 0
               M->C5_DESC3 := 0
               M->C5_DESC4 := 0

               // Checar consistências
               DbSelectArea("SF4") //Tipo de Entrada e Saída
               If !SF4->( DbSeek( xFilial("SF4") + aCols[_nX][_nPosTES] ) )   //    jose 23/09/2022
                  _lRet := .f.
                  cAuxMens := "Não encontrado o TES " + aCols[_nX][_nPosTES] + " no cadastro. Contacte o Adm. do Sistema!"
                  If fValAtrib("l410Auto") <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01" //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
                     FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAuxMens, 0 )
                  Else
                     MessageBox( cAuxMens, "Atenção", 16 )
                  Endif
                  Exit
               Endif
               If SF4->F4_DUPLIC $ 'S '
                  _lGeraDup := .t.
               Endif
               //Enviar pedido p/ MasterSales
               If M->C5_TIPO = "N" .AND. SF4->F4_DUPLIC $ 'S ' .AND. ( _cFilial == "010101" .OR. _cFilial == "060101" )
                  M->C5_X_SIM3G         := "S"
                  aCols[_nX,nPosC6SIM3G] := "S"
               Else
                  aCols[_nX,nPosC6SIM3G] := "N"
               Endif
               If _lGeraDup .AND. M->C5_TIPO = "N"
                  If Len( Alltrim( aCols[_nX][_nPosPROD] ) ) != 12 .OR. !Substr( aCols[_nX][_nPosPROD], 4, 2 ) $ _cZPPAR51
                     If _lZPPAR50 //Habilita/Desabilita regra para solventes
                        _lSoSolven := .f. // Não é pedido exclusivo de Solventes linhaS 71 e 10!
                     Endif
                  Endif
               Endif
               //********************************************************************************************************************//
               //***      PRECISA ENTENDER MELHOR PARA DETERMINAR O CST NA DIGITAÇÃO DO PRODUTO E NÃO PELO PONTO DE ENTRADA       ***//
               // Determinar o CST -> Cleber
               cCst    := ""
               cAuxDat := DtoS( Date() )
               cPerVen := Substr( cAuxDat, 5, 2 ) + Substr( cAuxDat, 1, 4 )
               //Período de cálculo
               nAno    := Year( Date() )
               nMes    := Month( Date() ) - 2
               If nMes <= 0
                  nMes := 12 + nMes
                  nAno--
               Endif
               cPerCal := Padl( Alltrim( Str( nMes ) ), 2, "0" ) + Padl( Alltrim( Str( nAno ) ), 4, "0" )
               //Cleber (2021)->FCI passou a ser determinado automaticamente pelo Protheus (substituição ao código situação anterior)
               If _nPosFCI > 0 // Não encontrado campo FCI qdo se usa a ferramenta Copiar!
                  If !Empty( aCols[_nX][_nPosFCI] ) .and. M->C5_TIPO == "N" //Caso o código fci esteja preenchido
                     DbSelectArea("CFD")
                     If CFD->( DbSeek( xFilial("CFD") + aCols[_nX][_nPosFCI] ) ) //CFD_FILIAL+CFD_FCICOD
                        cCst := CFD->CFD_ORIGEM
                     Endif
                  Endif
               Endif
               If Empty( cCst )
                  If !Empty( SB1->B1_ORIGEM )
                     cCst := Trim( SB1->B1_ORIGEM )
                  Else
                     If _cUfCliFor != "EX"
                        cCst := "0"
                     Else
                        cCst := "1"
                     Endif
                  Endif
               Endif
               If Empty( cCst )
                  cCst := "0"
               Endif
               cCst += Alltrim( SF4->F4_SITTRIB )
               //Preenchimento correto do CST (02/07/09) -> Cleber
               //Correção do CST (15/05/13) -> Cleber
               If Len( Alltrim( aCols[_nX][_nPosCST] ) ) != 3 .OR. M->C5_TIPO = "N"
                  aCols[_nX][_nPosCST] := cCst
               Endif

               // Definição da CFOP
               cCf := Alltrim( aCols[_nX][_nPosCF] )
               If Empty( cCf )
                  cCf := Alltrim( SF4->F4_CF )
               Endif
               If _cUfCliFor != "EX"  //   jose 23/09/2022
                  Do Case
                     Case ( cCf == "6107" .OR. Alltrim( SF4->F4_CF ) == "6107" ) .AND. ( cEstado == _cUfCliFor ) // Antes era "618"
                          cCf := "5101"
                          //Cleber (12/04/16) -> Solic. Nadia inclusão para o CFOP 6108 semelhante à situação do 6107
                     Case ( cCf == "6108" .OR. Alltrim( SF4->F4_CF ) == "6108" ) .AND. ( cEstado == _cUfCliFor )
                          cCf := "5102"
                     OtherWise
                          If cEstado != _cUfCliFor .and. Substr( cCf, 1, 1 ) == "5"
                             cCf := "6" + SubStr( cCf, 2, Len( cCf ) - 1 )
                          Endif
                  EndCase
               Else
                  If Substr( cCf, 1, 1 ) == "5"
                     cCf := "7" + Substr( cCf, 2, Len( cCf ) - 1 )
                  Endif
               Endif
               If _cDeposito $ "S.A"  .and. !Empty( Alltrim( SF4->F4_XCFODEP ) )    //  jose 23/09/2022
                  cCf := SubStr( cCf, 1, 1 ) + Substr( SF4->F4_XCFODEP, 2, 3 )
               Endif
               aCols[_nX][_nPosCF] := cCf

               // Definição da Base de ICMS p/ fins de apuração de Lucro e Comissão
               _nPercIcms := 0
               _nBaseIcms := 0
               If SF4->F4_ICM == "S"
                  _nBaseIcms := aCols[_nX][_nPosVALOR]
                  If SF4->F4_IPI == "S" .AND. SF4->F4_INCIDE == "S"
                     _nBaseIcms := _nBaseIcms * ( 1 + ( SB1->B1_IPI / 100 ) )
                  Endif
                  If _cUfCliFor == "EX"
                     _nPercIcms := 0
                     _lCampanha := .f.
                  Else
                     If cEstado == _cUfCliFor //If _cTipoCons == "N" .OR. cEstado == _cUfCliFor ANDRE EM 19-02-25 (ESTAVA CONSIDERANDO POLITICA DE SP PARA NÃO CONTRIBUINTE)
                        IF cEstado == _cUfCliFor .AND. cEstado == "SP" .AND. SB1->B1_GRTRIB == '003'
                           //25% ICMS para produtos 100% solvente puro
                           _nPercIcms = 25
                        Else
                           _nPercIcms = nICMPAD
                        Endif
                     Else
                        //FCI -> ICMS 4%
                        If SubStr( aCols[_nX][_nPosCST], 1, 1 ) $ "1,3,8"
                           _nPercIcms := 4
                        Else
                           If _cUfCliFor $ "MG_PR_RJ_RS_SC_SP"
                              _nPercIcms = 12
                           Else
                              _nPercIcms = 7
                           Endif
                        Endif
                     Endif
                  Endif
               Endif
               // Verificar se tem desconto de Pis/Cofins
               _nPisCof := 0 // Valor a ser descontado de Pis/Cofins
               If Empty( SF4->F4_PISCOF ) .or. SF4->F4_PISCOF == "N"
                  _nPisCof :=  aCols[_nX][_nPosVALOR] * ( ( nTXPIS + nTXCOFIN ) / 100 )
               Endif
               If _nX == 1
                  _cLogPed += 'Perc.ICMS: ' + TransForm( _nPercIcms, '@E 99.99' ) + ' | Pis/Cofins: ' + TransForm( _nPisCof, '@E 99.99' ) + ' | ICM PAD' + TransForm( nICMPAD, '@E 99.99' ) + Chr(13) + Chr(10)
                  _cLogPed += Chr(13) + Chr(10)
                  //            99-XX 999999999    | 99 |XXX| 999,999.999 | 999,999.999 | 9,999,999.999 | 999,999.999 | 9,999,999.999 | 999.9999 | 999.99 | 999 | 99.99 | 99.9999 | 99.99   | 999 | 999,999.999 | 999,999.999 | XXX | XXX | 99 | 999,999.999 | 999,999.999 | 999,999.999 | 999,999.999 | 999,999.999 | 999,999.999 |'
                  _cLogPed +=  'IT PRODUTO         | LC |EST| PRC VENDA   | QUANTIDADE  | VALOR TOTAL   | PRC TABELA  | VL. TOTAL TAB.| P.INT.   | L.ESP. | CST | ICMS  | IPI     | PIS/COF | GRT | PESO LIQUIDO| PESO BRUTO  | CAM | DUP | PG | VALOR HOJE  | LUCRO ITEM  | VALOR REAL  | LUCRO MIN.  | DESCONTO    | VLR C/ DESC.|' + Chr(13) + Chr(10)
               Endif
               _cLogPed +=  aCols[_nX][ _nPosITEM ] + '-' + aCols[_nX][ _nPosPROD ] + ' | ' +;
                            aCols[_nX][_nPosLOCAL] + ' |' +;
                            Iif( _lProdEst, 'SIM', 'NÃO') + '| ' +;
                            Transform( aCols[_nX][_nPosPRCVE], '@E 999,999.999'   ) + ' | ' +; 
                            Transform( aCols[_nX][_nPosQTDVE], '@E 999,999.999'   ) + ' | ' +;
                            Transform( aCols[_nX][_nPosVALOR], '@E 9,999,999.999' ) + ' | ' +; 
                            Transform( _nValUnTab            , '@E 999,999.999'   ) + ' | ' +;
                            Transform( _nValTab              , '@E 9,999,999.999' ) + ' | ' +;
                            Transform( _nPerInt              , '@E 999.9999'      ) + ' | ' +;
                            Transform( aCols[_nX][_nPosLEsp] , '@E 999.99'        ) + ' | ' +;
                            cCst + ' | ' +;
                            Transform( _nPercIcms            , '@E 99.99'         ) + ' | ' +;
                            Transform( SB1->B1_IPI           , '@E 99.9999'       ) + ' | ' +;
                            Transform( _nPisCof              , '@E 99.99'         ) + '   | ' +;
                            Alltrim( SB1->B1_GRTRIB ) + ' | '
                            
               //********************************************************************************************************************//
               //Verificar se volumes ficam incompletos
               _lVolQuebr := M->C5_TIPO = "N" .AND. U_VolQuebrado( aCols[_nX][_nPosPROD], aCols[_nX][_nPosQTDVE] )
               If _lVolQuebr .AND. SF4->F4_VOLQUEB != "S"
                  //Ped. funcionários podem ter volume quebrado (Solic. Ramon em 03/10/14)
                  lAux := .f. //Flag que identifica se é funcionário
                  If Len( _cCnpj ) == 11
                     cQry1 := "SELECT RA_MAT FROM " + RetSqlName("SRA") + " SRA WITH (NOLOCK) WHERE D_E_L_E_T_ <> '*' AND RA_CIC = '" + _cCnpj + "' AND RA_SITFOLH <> 'D' "
                     TCQuery cQry1 ALIAS "TCQRA" NEW
                     DbSelectArea("TCQRA")
                     DbGoTop()
                     If !eof() .and. !bof()
                        lAux := .t.
                     Endif
                     DbSelectArea("TCQRA")
                     DbCloseArea()
                  Endif
                  If !lAux //Se não for funcionário
                     _lRet := .f.
                     cMensErro := "Quantidade de Volumes para o produto " + aCols[_nX][_nPosPROD] + " não permitida!"
                     If fValAtrib("l410Auto") <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01" //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
                        FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cMensErro, 0 )
                     Else
                        MessageBox( cMensErro, "Atenção", 16 )
                     Endif
                     Exit
                  Endif
               Endif
               //Solic. Cleiton em 15/10/2014-> Enviar e-mail pro Caio e Cleiton quando for volume quebrado na Dissoltex
               If _lVolQuebr
                  If !Empty( _cPrdVolQb )
                     _cPrdVolQb += Chr(13) + Chr(10)
                  Endif
                  _cPrdVolQb += aCols[_nX][_nPosPROD]
               Endif

               //Determinação dos Pesos Liquido/Bruto, da quantidade de volumes e volume por cor
               _nPesoLiqu := SB1->B1_PESO   * aCols[_nX][_nPosQTDVE]
               _nPesoBrut := SB1->B1_PESBRU * aCols[_nX][_nPosQTDVE]
               _cLogPed += TransForm( _nPesoLiqu, '@E 999,999.999' ) + ' | ' +;
                           TransForm( _nPesoBrut, '@E 999,999.999' ) + ' | '
               nPesoLiquTotal += _nPesoLiqu
               nPesoBrutTotal += _nPesoBrut
               /****************************************************************************************************************************/
               /***               DETERMINAÇÃO DOS PESOS LIQUIDO/BRUTO, DA QUANTIDADE DE VOLUMES, VOLUME POR COR E CUBAGEM               ***/
               aAuxEmba := {}
               If Len( Alltrim( aCols[_nX][_nPosPROD] ) ) == 12 .and. !Substr( aCols[_nX][_nPosPROD], 11, 2 ) $ "00.99"
                  aAdd( aAuxEmba, { Alltrim( Substr( aCols[_nX][_nPosPROD], 11, 2 ) ), 0, 0, 0, 0, "", 0 } )
                  lRegB1 := .f.
                  DbSelectArea("SZ5")
                  If SZ5->( DbSeek( xFilial("SZ5") + SubStr( aCols[_nX][_nPosPROD], 11, 2) ) )
                     DbSelectArea("SB1")
                     nRegB1 := Recno()
                     lRegB1 := .t.
                     DbSelectArea( _cArqTmp )
                     If !( ( _cArqTmp )->( DbSeek( SubStr( aCols[_nX][_nPosPROD], 1, 10 ), .t.) ) )
                        RecLock( _cArqTmp, .t. )
                           (_cArqTmp)->PRODUTO := SubStr( aCols[_nX][_nPosPROD], 1, 10 )
                     Else
                        RecLock( _cArqTmp, .f. )
                     Endif
                     (_cArqTmp)->VOLUME += SZ5->Z5_VOLUME
                     (_cArqTmp)->( MsUnLock() )
                  Endif
                  lEmbaemG1 := .f. //Identifica se há tipo de embalagem na estrutura, caso contrário pega dos 2 díg. finais do código do produto
                  If SB1->B1_RELVOL > 0
                     aAuxEmba[1][6] := Alltrim( Str( SB1->B1_RELVOL ) )
                     nAuxVol        := U_DetVolEmba( aAuxEmba[1][6], aCols[_nX][_nPosQTDVE] ) 
                     aAuxEmba[1][2] := aCols[_nX][_nPosQTDVE]
                     aAuxEmba[1][3] := Iif( _lVolJunto, aCols[_nX][_nPosQTDVE], 0 )
                     aAuxEmba[1][4] := Iif(!_lVolJunto, nAuxVol, 0 )
                     aAuxEmba[1][5] := Iif( _lVolJunto .AND. SF4->F4_VOLQUEB != "S" .AND. SubStr( aCols[_nX][_nPosPROD], 1, 2 ) $ "BL", aCols[_nX][_nPosQTDVE], 0 )
                     aCols[ _nX ][ _nPosVolIt ] += nAuxVol
                  Else
                     DbSelectArea("SG1")
                     If SG1->( DbSeek( xFilial("SG1") + aCols[_nX][_nPosPROD], .F. ) )
                        While !Eof() .AND. SG1->G1_FILIAL == xFilial("SG1") .AND. SG1->G1_COD == aCols[_nX][_nPosPROD] .AND. Len( RTrim( SG1->G1_COMP ) ) == 4
                              cComp    := RTrim( SG1->G1_COMP )
                              nQtdComp := 0
                              While !Eof() .AND. SG1->G1_FILIAL == xFilial("SG1") .AND. SG1->G1_COD == aCols[_nX][_nPosPROD] .AND. Len( RTrim( SG1->G1_COMP ) ) == 4 .AND. RTrim( SG1->G1_COMP ) == cComp
                                    nQtdComp += SG1->G1_QUANT
                                    SG1->( DbSkip() )
                              Enddo
                              DbSelectArea("SB1")
                              If SB1->( DbSeek(xFilial("SB1")+cComp, .F.) )
                                 If !Empty( SB1->B1_RELCAT1 )
                                    lEmbaemG1 := .t.
                                    DbSelectArea("SZ5")
                                    If !SZ5->( DbSeek( xFilial("SZ5") + Alltrim( SB1->B1_RELCAT1 ) ) )
                                       DbSelectArea("SG1")
                                       Loop
                                    Endif
                                    lAchou := .f.
                                    For i = 1 to Len( aAuxEmba )
                                        If ( Empty( aAuxEmba[i][6] ) .or. ( aAuxEmba[i][6] == Alltrim( SZ5->Z5_RELVOL) ) )
                                           lAchou := .t.
                                           nVar   := i
                                        Endif
                                    Next
                                    If !lAchou
                                       nVar := Len( aAuxEmba ) + 1
                                       aAdd( aAuxEmba, { Alltrim( SubStr( aCols[_nX][_nPosPROD], 11, 2 ) ), 0, 0, 0, 0, Alltrim( SZ5->Z5_RELVOL ), 0 } )
                                    Else
                                       If Empty( aAuxEmba[nVar][6] )
                                          aAuxEmba[nVar][6] := Alltrim( SZ5->Z5_RELVOL )
                                       Endif
                                    Endif

                                    nAuxQtde          := aCols[_nX][_nPosQTDVE] * nQtdComp
                                    nAuxVol           := U_DetVolEmba( aAuxEmba[nVar][6], nAuxQtde )
                                    aAuxEmba[nVar][2] := aAuxEmba[nVar][2] + nAuxQtde
                                    aAuxEmba[nVar][3] := aAuxEmba[nVar][3] + Iif( _lVolJunto, nAuxQtde, 0 )
                                    aAuxEmba[nVar][4] := aAuxEmba[nVar][4] + Iif(!_lVolJunto, nAuxVol , 0 )
                                    aAuxEmba[nVar][5] := aAuxEmba[nVar][5] + Iif( _lVolJunto .and. SF4->F4_VOLQUEB != "S" .and. SubStr( aCols[_nX][_nPosPROD], 1, 2 ) $ "BL", nAuxQtde, 0 )
                                    aCols[ _nX ][ _nPosVolIt ] += nAuxVol
                                 Endif
                                 DbSelectArea("SG1")
                              Endif
                        EndDo
                     Endif
                     // Se não tiver embalagem na estrutura considerar código final.
                     If !lEmbaemG1 .and. !( SubStr( aCols[_nX][_nPosPROD], 11, 2 ) $ "00.99" ) // Se não tiver cód. de embalagem na estrutura, pegar pelo final do cód. do prod.
                        DbSelectArea("SZ5")
                        If SZ5->( DbSeek(xFilial("SZ5")+aAuxEmba[1][1]) )
                           aAuxEmba[1][6] := Alltrim( SZ5->Z5_RELVOL )
                        Endif
                        nAuxVol := U_DetVolEmba( aAuxEmba[1][6], aCols[_nX][_nPosQTDVE] )
                        aAuxEmba[1][2] := aCols[_nX][_nPosQTDVE]
                        aAuxEmba[1][3] := Iif( _lVolJunto, aCols[_nX][_nPosQTDVE], 0 )
                        aAuxEmba[1][4] := Iif(!_lVolJunto, nAuxVol, 0 )
                        aAuxEmba[1][5] := Iif( _lVolJunto .and. SF4->F4_VOLQUEB != "S" .and. SubStr( aCols[_nX][_nPosPROD], 1, 2 ) $ "BL", aCols[_nX][_nPosQTDVE],0 )
                        aCols[_nX][ _nPosVolIt ] += nAuxVol 
                     Endif
                  Endif

                  DbSelectArea("SB1")
                  If lRegB1
                     DbGoto(nRegB1)
                  Endif
               Else // Se não PA de 12 dígitos(Tinta) !
                  If Len( Alltrim( aCols[_nX][_nPosPROD] ) ) == 12
                     _nQtdeVol += 1
                     aAuxEmba := {}
                     aAdd( aAuxEmba, { SubStr( aCols[_nX][_nPosPROD], 11, 2 ), aCols[_nX][_nPosQTDVE], 0, 1, 0, Alltrim( Str( aCols[_nX][_nPosQTDVE] ) ), 0 } )
                     aCols[_nX][ _nPosVolIt ] += 1
                  Else
                     nAux := Iif( SB1->B1_RELVOL > 0, Round( aCols[_nX][_nPosQTDVE]  / SB1->B1_RELVOL, 3 ), 0 )
                     If Int( nAux ) < nAux
                        nAux := Int( nAux ) + 1
                     Endif
                     _nQtdeVol += nAux
                     aAuxEmba := {}
                     aAdd( aAuxEmba, { "--", aCols[_nX][_nPosQTDVE], 0, nAux, 0, Alltrim( Str( SB1->B1_RELVOL ) ), 0 } )
                     aCols[ _nX ][ _nPosVolIt ] += nAux
                  Endif
               Endif
               For j := 1 to Len(aAuxEmba)
                   //Det. da Cubagem
                   nCubagem := Iif( j == 1, DetCubagem( aCols[_nX][_nPosPROD] ) * aCols[_nX][_nPosQTDVE], 0 )

                   lAchou = .f.
                   For i := 1 to Len(aEmba)
                       If aEmba[i][1] == aAuxEmba[j][1] .and. aEmba[i][6] == aAuxEmba[j,6]
                          lAchou := .t.
                          nVar   := i
                       Endif
                   Next
                   If !lAchou
                      nVar := Len( aEmba ) + 1
                      //Tipo de embalagem correspondente armazenado
                      aAdd( aEmba, { aAuxEmba[j][1], 0, 0, 0, 0, aAuxEmba[j][6], 0 } )
                   Endif
                   aEmba[nVar][2] += aAuxEmba[j][2]
                   aEmba[nVar][3] += aAuxEmba[j][3]
                   aEmba[nVar][4] += aAuxEmba[j][4]
                   aEmba[nVar][5] += aAuxEmba[j][5]
                   aEmba[nVar][7] += nCubagem
               Next
               // Término cálculo volumes para o item
               /***************************************************************************************************/
               //Chamado 020971, campanha de venda
               If _lCampanha
                  Do Case 
                     Case cEstado == _cUfCliFor
                          _nIcmCamp := 18
                     Case _cUfCliFor $ "MG_PR_RJ_RS_SC_SP"
                          _nIcmCamp := 12
                     OtherWise
                          _nIcmCamp := 7
                  Endcase
                  //Verificar se preencheu com uma das tabelas de campanha de região de ICMS, validar se foi pra região de ICMS correto
                  DbSelectArea("DA0")
                  If !DA0->( DbSeek( xFilial("DA0") + _cTabCamp ) ) .OR. _cTabCamp ='GRU' // ANDRE MAESTER 13-02-25
                     _lCampanha := .f.
                  Endif 
               Endif 
               If _lCampanha .and. ( DA0->DA0_DATDE > M->C5_EMISSAO .OR. DA0->DA0_DATATE < M->C5_EMISSAO )				
                  _lCampanha := .f.
               Endif 
               If _lCampanha
                  _cCondCamp := fEhAvista( DA0->DA0_CONDPG ) //Converter cond. pgto pra à vista (menos de 7 dias é consid à vista)
                  If DA0->DA0_REGICM > 0 .AND. DA0->DA0_REGICM != _nIcmCamp
                     cAux := "Tabela de Campanha " + _cTabCamp + " NÃO pertence à região de icms correta!"
                     If fValAtrib("l410Auto") <> "U" .and. !l410Auto .and. ProcName(nPosi) <> "U_ZFATP01" //release 12.1.25 If  ( Type("l410Auto") = "U" .or. !l410Auto )
                        FwLogMSG( "WARN", , 'SIGAFAT', FunName(), '', '01', cAux, 0 )
                     Else
                        MessageBox( cAux, "Atenção", 16 )
                     Endif
                     _lCampanha := .f.
                  Endif 
               Endif 
               If _lCampanha
                  If !Empty( Alltrim( DA0->DA0_CONDPG ) ) .AND. !( _cCondPag == _cCondCamp )
                     cAux := "Condição de Pgto diverge do cad da Tabela, deveria ser " + DA0->DA0_CONDPG + "!"
                     If fValAtrib("l410Auto") <> "U" .and. !l410Auto .and. ProcName(nPosi) <> "U_ZFATP01" //release 12.1.25 If  ( Type("l410Auto") = "U" .or. !l410Auto )
                        FwLogMSG( "WARN", , 'SIGAFAT', FunName(), '', '01', cAux, 0 )
                     Else
                        MessageBox( cAux, "Atenção", 16 )
                     Endif
                     _lCampanha := .f.
                  Endif 
               Endif 
               _cLogPed += Iif( _lCampanha, 'SIM', 'NÃO' ) + ' | '
               /***********************************************************************************************************************/
               /***                           INICIO DOS CALCULOS DOS ITENS E POLITICA COMERCIAL BRASILUX                           ***/
               nVlrProd   := aCols[_nX][_nPosVALOR]
               _nVlrTPed += nVlrProd
               If SF4->F4_DUPLIC == "S"
                  _nVlrTDup += nVlrProd

                  /*aPrecos := U_PrcMinimo( _nValTab, Iif( Len( Alltrim( SB1->B1_COD ) ) == 12, Substr( SB1->B1_GRUPO2, 2, 1 ), "X" ), _nPercIcms, Iif( SF4->F4_INCIDE == "S", .T., .F. ), _cCondPag )
                  aPrcMin[1] += NoRound( aPrecos[1], 2 )
                  aPrcMin[2] += NoRound( aPrecos[2], 2 )
                  aPrcMin[3] += NoRound( aPrecos[3], 2 )
                  aPrcMin[4] += NoRound( aPrecos[4], 2 )
                  aPrcMin[5] += NoRound( aPrecos[5], 2 )*/

                  //LGS#20220707 - Alterado o ICMS para o ICM do estado, pois antes pegaga um valor "calculado"
                  //_aNewPol := u_fPolComBra( _nValTab, _nPercIcms, Iif( SF4->F4_INCIDE == "S", .T., .F. ), _cCondPag )
                  _aNewPol := u_fPolComBra( _nValTab, _nICMPol, Iif( SF4->F4_INCIDE == "S", .T., .F. ), _cCondPag, _cFilial )
                  /*_aNewMin[1] += NoRound( _aNewPol[1], 2 )
                  _aNewMin[2] += NoRound( _aNewPol[2], 2 )
                  _aNewMin[3] += NoRound( _aNewPol[3], 2 )
                  _aNewMin[4] += NoRound( _aNewPol[4], 2 )
                  _aNewMin[5] += NoRound( _aNewPol[5], 2 )*/

                  nValorHoje := 0
                  _nQtdeParc  := Len( _aPrazos )
                  For _nI := 1 To _nQtdeParc
                      nAux := ( aCols[_nX][_nPosVALOR] * _aPrazos[_nI][2] ) / ( ( 1 + ( nJuros / 100 ) ) ^ ( ( 12 * _aPrazos[_nI][1]) / 365 ) )
                      nValorHoje := nValorHoje + nAux
                  Next
                  //Valor do lucro+comissao da empresa no preco praticado do pedido.
                  _nLucroItem := nValorHoje - ( aCols[_nX][_nPosVALOR] * ( SB1->B1_PERINT / 100 ) ) - ( SB1->B1_CUSTOR * aCols[_nX][_nPosQTDVE] ) - ( _nBaseIcms * _nPercIcms / 100 ) - _nPisCof
                  aCols[_nX][_nPosVlLcr] := _nLucroItem  // Valor do Lucro + Comissão, p/ posterior apuração de lucro obtido por linha de prod
                  _nValReal   := _nValReal + _nLucroItem

                  //Media de Comissao e Lucro Minimo.
                  If !_lProdEst
                     nAuxLucro := SB1->B1_LUCROM2
                  Else
                     nAuxLucro := SB1->B1_LCRMIN
                  Endif
                  _nMedComiss += ( SB1->B1_COMIS * aCols[_nX][_nPosVALOR] )
                  _nMedLucro  += ( nAuxLucro * aCols[_nX][_nPosVALOR] )
                  _lComisZer  := Iif( !_lComisZer, Iif( SB1->B1_COMIS == 0, .t., .f. ), _lComisZer )
                  _nComisZer  += Iif( SB1->B1_COMIS == 0, 1, 0 )
                  //Descontos para produtos de estoque e Não Estoque
                  nInd := 0
                  For _nI := 1 To _nQtdeParc
                      nAux := _aPrazos[_nI][2] / ( ( 1 + ( nJuros / 100 ) ) ^ ( ( 12 * _aPrazos[_nI][1] ) / 365 ) )
                      nInd := nInd + nAux
                  Next
                  nIndAnt     := ( 1 + ( nJuros / 100 ) ) ^ ( ( 12 * 60 ) / 365 ) //60 dias
                  nDesc1      := ( nInd - ( 1 / nIndAnt ) + ( nICMPAD / 100 ) - ( _nPercIcms / 100 ) ) / ( nInd - _nPerint - ( _nLC1 / 100 ) - ( _nPercIcms / 100 ) )
                  nDesc2      := ( nInd - ( 1 / nIndAnt ) + ( nICMPAD / 100 ) - ( _nPercIcms / 100 ) ) / ( nInd - _nPerint - ( _nLC2 / 100 ) - ( _nPercIcms / 100 ) )

                  _nVlrCDesc  := _nValTab * ( 1 - Iif( _lProdEst, nDesc1, nDesc2 ) ) // Somar vlr tabela c/ desconto p/ 60 dias em regioes de icms diferentes
                  _nSomVlTab  += _nValTab // _nVlrCDesc , a partir de 15/05/09 passou a aplicar descontos tendo ref. apenas a tabela 18%

                  If M->C5_TIPO == "N" .AND. Len( Alltrim( aCols[_nX][_nPosPROD] ) ) == 12 .and. ( ( ( _nVlrCDesc / 1.165 ) > ( aCols[_nX][_nPosPRCVE] * aCols[_nX][_nPosQTDVE] ) ) .and. ( _nLucroItem <= 0 ) )
                  //   Jose 30/04/2024 --------------------------
                     If aCols[_nx][7] > 0
                       _PerDesc := ROUND( ( ( ( ( aCols[_nx][6] / aCols[_nx][7] ) * 100 ) - 100 ) * -1 ) ,0 )
                       //-----------------Jose 06/05/2024----------------------
                       cAux := "Valor para o produto " + Alltrim( aCols[_nX][_nPosPROD] )  + "  Desc.: " + ALLTRIM(STR(_PerDesc)) + "% muito pequeno em relação à tabela!!! CONFIRA!" 
                     Else
                       cAux := _cObs
                     Endif
                     If fValAtrib("l410Auto") <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01"//release 12.1.25 If  ( Type("l410Auto") = "U" .or. !l410Auto )
                        FwLogMSG( "WARN", , 'SIGAFAT', FunName(), '', '01', cAux, 0 )
                     Else
                        MessageBox( cAux, "Atenção", 16 )
                     Endif
                     If !( cAux $ _cObs )
                        _cObs += Chr(13) + Chr(10) + cAux
                     Endif
                  Endif
                  If M->C5_TIPO == "N" .AND. _nValUnTab > 0 .AND. ( aCols[_nX][_nPosPRCVE] > ( _nValUnTab * 1.5 ) )
                     cAux := "Valor para o produto " + Alltrim( aCols[_nX][_nPosPROD] ) + " MUITO ALTO em relação à tabela!!! CONFIRA!"
                     If fValAtrib("l410Auto") <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01" //release 12.1.25 If  ( Type("l410Auto") = "U" .or. !l410Auto )
                        FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAux, 0 )
                     Else
                        MessageBox( cAux, "Atenção", 16 )
                     Endif
                     If !(cAux $ _cObs)
                        _cObs += chr(13)+chr(10)+cAux
                     Endif
                  Endif
                  //Chamado 018057, quantidades mínimas de venda para específicos
                  //Caso não seja venda via MasterSales o bloqueio não está sendo feito porém alerta será colocado na Observação
                  If M->C5_TIPO == "N"  
                     If !U_QtdMinProd( aCols[_nX][_nPosPROD], aCols[_nX][_nPosQTDVE] )
                        cAux := ""
                        If INCLUI  .AND. !EMPTY(M->C5_X_PVSIM)
                           cAux :="Produto Excluido: "
                           _cLogPed += "Produto Excluido 1 : "
                        EndIf   
                        
                        cAux +=  Alltrim( aCols[_nX][_nPosPROD] ) + ", Qtde " + Alltrim( Str( aCols[_nX][_nPosQTDVE] ) ) + ", Valor " + cValToChar( aCols[_nX][_nPosPRCVE]) + " - QTDE ABAIXO DO MINIMO"
                      
                        /* 
                           Alterado em 23/11/2022
                           Bloqueia pedido quando produto é abaixo do pedido minimo
                        */
                        If GETMV("ZP_PAR0066") == .T.
                           _lRet := .f.   
                        EndIf

                        /* alterado por nelieder em 27/07/20222 */
                        /* informa lote minimo necessário */
                        If GETMV("ZP_PAR0052") == .T.
                           If SB5->B5_X_QTDE > 0
                             cAux += "("+ALLTRIM(STR(SB5->B5_X_QTDE))+")!"
                           Else
                             cAux += "("+ALLTRIM(STR(ZA8->ZA8_QTD))+")!"
                           EndIf
                        EndIf
                        If fValAtrib("l410Auto") <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01" //release 12.1.25 If  ( Type("l410Auto") = "U" .or. !l410Auto )
                           FwLogMSG( "WARN", , 'SIGAFAT', FunName(), '', '01', "Produto : " + cAux, 0 )
                        Else
                           MessageBox( "Produto : " + cAux, "Atenção", 16 )
                        Endif
                        If !(cAux $ _cObs)
                           _cObs += Chr(13) + Chr(10) + "Produto : " + cAux
                        Endif
                        
                        //Comentado por Neliede em 01/08/2023
                        If INCLUI  .AND. !EMPTY(M->C5_X_PVSIM)
                          _cLogPed += "Produto Excluido 2 : "
                          aCols[_nX][_nDel] := .T.
                        EndIf  
                        
                     Endif 
                  Endif
                  //Definição de campanha de venda, chamado 020971
                  If _lCampanha
                     DbSelectArea("DA1")
                     If !DA1->( Dbseek( xFilial("DA1") + _cTabCamp + aCols[_nX][_nPosPROD] ) )
                        _lCampanha := .f.
                     Else 
                        If ( aCols[_nX][_nPosPRCVE] == 0.0 ) .or. ( DA1->DA1_PRCVEN == 0.0 )
                           _lCampanha := .f.
                        Else
                           If Abs( ( aCols[_nX][_nPosPRCVE] - DA1->DA1_PRCVEN ) * 100 / DA1->DA1_PRCVEN ) > 0.5
                              _lCampanha := .f.
                           Endif 
                        Endif 
                     Endif 
                  Endif 
                  _cLogPed += Iif( SF4->F4_DUPLIC == 'S', 'SIM', 'NÃO' ) + ' | ' +;
                              TransForm( _nQtdeParc, '@E 99' ) + ' | ' +;
                              TransForm( nValorHoje, '@E 999,999.999' ) + ' | ' +;
                              TransForm( _nLucroItem, '@E 999,999.999' ) + ' | ' +;
                              TransForm( _nValReal, '@E 999,999.999' ) + ' | ' +;
                              TransForm( nAuxLucro, '@E 999,999.999' ) + ' | ' +;
                              TransForm( Iif( _lProdEst, nDesc1, nDesc2 ), '@E 999,999.999' ) + ' | ' +;
                              TransForm( _nVlrCDesc, '@E 999,999.999' ) + ' | ' + CHR(13) +CHR(10)
               Else
                  _lCampanha := .f. //Chamado 020971, campanhas de venda, se existir produto sem gerar financeiro então pedido não participa de campanha
               Endif
            Endif
        Next
        /**********************************************/
        /***       FIM DA VARREDURA DOS ITENS       ***/
        /**********************************************/
        //            99-XX 999999999    | 99 |XXX| 999,999.999 | 999,999.999 | 9,999,999.999 | 999,999.999 | 9,999,999.999 | 999.9999 | 999.99 | 999 | 99.99 | 99.9999 | 99.99   | 999 | 999,999.999 | 999,999.999 | XXX | XXX | 99 | 999,999.999 | 999,999.999 | 999,999.999 | 999,999.999 | 999,999.999 | 999,999.999 |
        _cLogPed +=  '-------------------+----+---+-------------+-------------+---------------+-------------+---------------+----------+--------+-----+-------+---------+---------+-------------+-------------+-----+-----+-----+----+-------------+-------------+-------------+-------------+-------------+-------------+' + Chr(13) + Chr(10)
        _cLogPed +=  ' PESO LIQUIDO      | PESO BRUTO           |             | VALOR TOTAL   |             | VL. TOTAL TAB.|                                                     |' + Chr(13) + Chr(10)
        //           '     9,999,999.999 |        9,999,999.999 |             | 9,999,999.999 |             | 9,999,999.999 |                                                                         |
        _cLogPed +=  '     ' +;
                     TransForm( nPesoLiquTotal, '@E 9,999,999.999' ) + ' |        ' +; 
                     TransForm( nPesoBrutTotal, '@E 9,999,999.999' ) + ' |             | ' +;
                     Transform( _nVlrTPed     , '@E 9,999,999.999' ) + ' |             | ' +;
                     Transform( _nSomVlTab    , '@E 9,999,999.999' ) + ' |  '
        //LGS#20220707 - Alterado o ICMS para o ICM do estado, pois antes pegaga um valor "calculado"
        //_aPolDes := fCarrDesc( _nPercIcms, Iif( SF4->F4_INCIDE == "S", .T., .F. ), _cCondPag )
        _aPolDes := fCarrDesc( _nICMPol, Iif( SF4->F4_INCIDE == "S", .T., .F. ), _cCondPag, _cFilial )
        _cLogPed += Chr(13) + Chr(10)
        //
        //Chamado 020971, campanha de vendas. Verificar se foi estabelecido valor mínimo de venda
        If _lCampanha .AND. ( DA0->DA0_PEDMIN > 0 ) .AND. ( _nVlrTDup < DA0->DA0_PEDMIN )
           _lCampanha := .f.
           cAuxMens = "Pedido de Campanha abaixo do Vlr Mínimo!"
           If fValAtrib("l410Auto") <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01" //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
              FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAuxMens, 0 )
           Else
              MessageBox( cAuxMens, "Atenção", 16 )
           Endif
        Endif
        If _lZPPAR50 //Habilita/Desabilita regra para solventes
           If _lSoSolven .and. !_lCampanha
              //Gravar que pedido possui solvente
              DbSelectArea("SX5")
              If !SC5->( DbSeek( xFilial("SC5") + "96" + M->C5_NUM ) )
                 RecLock( "SX5", .T. )
                    SX5->X5_FILIAL := xFilial("SC5")
                    SX5->X5_TABELA := "96"
                    SX5->X5_CHAVE  := M->C5_NUM 
              Else
                 RecLock( "SX5", .F. )
              Endif
              SX5->X5_DESCRI := "S"
              SX5->X5_DESCSPA := "S"
              SX5->X5_DESCENG := "S"
              SX5->( MsUnLock() )
           Endif
        Endif
        If _cUfCliFor != "EX" .AND. _nContItem > 150
           cAuxMens = "Qtde de Itens maior que 150! Poderá não ser possível a transmissão da NFe!"
           If fValAtrib("l410Auto") <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01" //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
              FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAuxMens, 0 )
           Else
              MessageBox( cAuxMens, "Atenção", 16 )
           Endif
        Endif
        If _lRet .and. Empty( _cDeposito )
           _cDeposito := "N"
        Endif
        M->C5_DEPOSI := _cDeposito
        //Solic. Cleiton em 15/10/14, enviar e-mail p/ Caio e Eliana caso sejam vendidos produtos com quebra de volume na Dissoltex
        If !Empty( _cPrdVolQb )
           M->C5_VOLQUEB := "S"
           If _cFilial = "060101" //Enviar email qdo for Dissoltex
              cAuxMens := "Os seguintes produtos foram vendidos em volumes incompletos na Dissotex: " + Chr(13) + Chr(10) + _cPrdVolQb + ;
                          Chr(13) + Chr(10) + "Usuário que incluiu/alterou o pedido: " + Rtrim( cUserName ) +;
                          Chr(13) + Chr(10) + "Nro do Pedido: " + M->C5_NUM+;
                          Chr(13) + Chr(10) + "Cliente: " + M->C5_CLIENTE + "-" + SA1->A1_NOME
              U_EnvMail( "DISSOLTEX - Pedido " + M->C5_NUM + " vendido com VOLUMES INCOMPLETOS", cAuxMens, "caio@brasilux.com.br", "eliana@brasilux.com.br", " " )
           Endif
        Endif
        //Solic. Michelly em 07/10/2015 -> Enviar email pro Ramon quando o pedido tiver marcado para acompanhar laudo
        If _cNumEmp == "01010101" .and. M->C5_LAUDO = "S"
           cAuxMens := "O Pedido nro " + M->C5_NUM + ", CLIENTE : " + M->C5_CLIENTE + "-" + Alltrim( Iif( M->C5_TIPO $ "D_B", SA2->A2_NOME, SA1->A1_NOME ) ) + " acompanha LAUDO!"
           U_EnvMail( "Pedido " + M->C5_NUM + " possui laudo.", cAuxMens, "faturamento@brasilux.com.br", " " )
        Endif
        //Checar se existe item de estoque misturado com Não estoque(23/06/20)
        If _nContItem == 1
           _lMudouEst :=  _lProdEst
        Else 
           If !_lMisturad .and. ( _lProdEst <> _lMudouEst )
              _lMisturad := .t.
           Endif 
        Endif 
        //Qtde de Volumes à partir de vetor gerado e/ou Volume Total Gerado
        lCalcVol := .t.
        If _lRet
           If !INCLUI
              cQry1 := "DELETE FROM "+retsqlname("ZZO")+" WHERE (ZZO_FILIAL = '"+xFilial("ZZO")+"') AND (ZZO_PEDIDO = '"+M->C5_NUM+"')"
              _lRet := TcSQLExec( cQry1 ) >= 0
              If !_lRet
                 MessageBox( TcSqlError(), 'Atenção', 16 )
              Endif
           Else
              DbSelectArea("ZZO")
              If ZZO->( Dbseek( xFilial("ZZO") + M->C5_NUM ) )
                 cMensErro := "Cálculo de VOLUMES ficará errado! Salve novamente o PEDIDO!!"
                 If fValAtrib("l410Auto") <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01" //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
                    FwLogMSG( "INFO", , 'SIGAFAT', FunName(), '', '01', cMensErro, 0 )
                 Else
                    MessageBox( cMensErro, "Atenção", 16 )
                 Endif
                 lCalcVol := .f.
                 M->C5_NAOCONF := "S"
                 If !Empty( _cObs )
                    _cObs += chr(13)+chr(10)
                 Endif
                 _cObs += cMensErro
              Endif
           Endif
        Endif
        nCubagem := 0
        If _lRet .and. lCalcVol
           For i := 1 to Len(aEmba)
               _nQtdeVol := aEmba[i][4]
               If _lRet .and. aEmba[i][5] > 0
                  _lRet := U_VolCompl( aEmba[i][6], aEmba[i][5] )
                  If !_lRet
                     cMensErro := "Pedido não fecha volumes devido a BL!"
                     If fValAtrib("l410Auto") <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01" //release 12.1.25 If ( Type("l410Auto") <> "U" .And. l410Auto )
                        FwLogMSG( "INFO", , 'SIGAFAT', FunName(), '', '01', cMensErro, 0 )
                     Else
                        MessageBox( cMensErro, "Atenção", 16 )
                     Endif
                     Exit
                  Endif
               Endif
               If aEmba[i][3] > 0
                  _nQtdeVol += U_DetVolEmba(aEmba[i][6], aEmba[i][3])
               Endif
               nVolTotal += _nQtdeVol
               DbSelectArea("ZZO")
               If !ZZO->( DbSeek( xFilial("ZZO") + M->C5_NUM + aEmba[i][1] ) )
                  RecLock( "ZZO", .t. )
                     ZZO->ZZO_FILIAL := xFilial("ZZO")
                     ZZO->ZZO_PEDIDO := M->C5_NUM
                     ZZO->ZZO_EMBA   := aEmba[i][1]
               Else
                  Reclock( "ZZO", .f. )
               Endif
               ZZO->ZZO_QTDE   += aEmba[i][2]
               ZZO->ZZO_QTDVOL += _nQtdeVol
               ZZO->ZZO_CUBAGE += aEmba[i][7]
               ZZO->( MsUnLock() )
               nCubagem += aEmba[i][7]
           Next
        Endif
        If (nCubagem > 0)
           M->C5_VOLUME2 := nCubagem
           //ATENÇÃO!!! SE SALVAR C5_ESPECI2 O PROGRAMA NFESEFAZ IRÁ SOMAR AO TOTAL DE VOLUMES A QTDE DE C5_VOLUME2!!
           //If Empty( M->C5_ESPECI2 )
           //   M->C5_ESPECI2 := "CUBAGEM"
           //Endif
        Endif
        If _cUfCliFor == "EX" //Exportação não paga comissão
           _nMedComiss := 0
        Endif
        // % de lucro obtido
        If _nVlrTDup > 0
           _nMedComiss := _nMedComiss / _nVlrTDup
           _nMedLucro  := _nMedLucro / _nVlrTDup
           _nLucroCal  := ((_nValReal - (_nVlrTDup * (_nMedComiss / 100))) / _nVlrTDup) * 100
           // Gerente de Vendedor, comissão de 1%
           M->C5_COMIS2 := Iif( !Empty( Alltrim( M->C5_VEND2 ) ), 1, 0 ) // 1% DE COMISSÃO P/ GERENTE, CASO EXISTA.
        Else
           _nLucroCal := 0
           _nMedComiss := 0
           _nMedLucro  := 0
           _nLucroCal  := 0
           M->C5_COMIS2 := 0
        Endif
        _cLogPed += 'Media Comissao: ' + TransForm( _nMedComiss, '@E 999,999.999' ) + Chr(13) + Chr(10)
        _cLogPed += 'Media Lucro: ' + TransForm( _nMedLucro, '@E 999,999.999' ) + Chr(13) + Chr(10)
        _cLogPed += 'Lucro Calculado: ' + TransForm( _nLucroCal, '@E 999,999.999' ) + Chr(13) + Chr(10)
        // À partir de 01/03/06 todos participam de comissão fixa 5%
        lSisRev     := .f. // Participa de pol. nova para revenda?
        If _cUfCliFor == "EX" //Exportação nao participa de compensação, não há comissionamento!
           M->C5_COMPENS := "N" // Não participa de compensação de comissão!
           lSisRev       := .f.
        Else
           If !M->C5_TIPO $ "D_B"
              If Empty( M->C5_VEND1 ) .AND. !EMPTY( SA1->A1_VEND )
                 M->C5_VEND1 := SA1->A1_VEND
              Endif 
              If !Empty( M->C5_VEND1 )
                 DbSelectArea("SA3")
                 If SA3->( DbSeek( xFilial("SA3") + M->C5_VEND1 ) )
                    If SA3->A3_SISREV == "S" .AND. !_lCampanha .AND. SA3->A3_COMIS <= 0.0 // Se o representante aderiu à política de revenda, 5% fixos de comissão.  Chamado 020971, verificar campanha de venda. Chamado 024740, verificar comissão fixa
                       M->C5_COMPENS := "S" // Participa de compensação de comissão!
                       lSisRev       := .t.
                    Endif 
                    //Chamado 024740, definir comissão fixa. Combinado que quando o cadastro do representante contiver percentual de comissão então a mesma será fixa
                    //If !_lSoSolven .AND. SA3->A3_COMIS > 0.0 //LGS#04/06/2022 - Retirado solvente da regra
                    If SA3->A3_COMIS > 0.0  //Pedidos de solventes não participam de comissão fixa
                       M->C5_XCONF := .T. //Comissão fixa
                       lSisRev := .f.
                    Endif 
                 Endif
              Endif
           Endif
        Endif
        
        
        // Gravar desconto aplicado sobre o geral de tabela. Solic. Eliana em Fev/2008
        // Antes de 17/10/23
        //M->C5_DESCON4 := IIF( _nSomVlTab > 0, ROUND( ( 1 - ( _nVlrTDup / _nSomVlTab ) ) * 100, 2 ), 0 )
        
        
        // Gravar desconto aplicado sobre o geral de tabela. Solic. Eliana em Fev/2008
        // Depois de 17/10/23
        //if (M->C5_XDESCON > 0) // Flag para fixar desconto em pedido dividido 
           //M->C5_DESCON4 := M->C5_XDESCON
        //else
           M->C5_DESCON4 := IIF( _nSomVlTab > 0, ROUND( ( 1 - ( _nVlrTDup / _nSomVlTab ) ) * 100, 2 ), 0 )
        //EndIf 

        _cLogPed += 'Desconto: ' + TransForm( M->C5_DESCON4, '@E 999,999.999' ) + Chr(13) + Chr(10)
        //Se o lucro da empresa praticado no preco do pedido for menor que o Lucro Minimo
        //abate esta diferenca da comissao do representante.
        If (_nLucroCal >= _nMedLucro) 
           _nComisCal := _nMedComiss
        Else
           _nLucroCal   := _nMedLucro
           _nComisCal   := Iif( _nVlrTDup <= 0, 0, ( ( _nValReal - ( ( _nLucroCal * _nVlrTDup ) / 100 ) ) / _nVlrTDup ) * 100 )
        Endif
        
        lDescOk       := .t.
        //Política padrão de comissionamento
        If lSisRev .and. _lRet .and. M->C5_TIPO =  "N"      //   jose 23/09/2022
           cQry1 := "SELECT SUM(C6_VALOR/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1.0 END)) AS SALDO "+;
                    "FROM " + RetSqlName("SC6") + " SC6 WITH (NOLOCK) "+;
                    "LEFT OUTER JOIN " + RetSqlName("SC5") + " SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C6_FILIAL = C5_FILIAL) AND (C6_NUM = C5_NUM) "+;
                    "LEFT OUTER JOIN " + RetSqlName("SF4") + " SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '" + xFilial("SF4") + "') AND (F4_CODIGO = C6_TES) "+;
                    "WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '" + xFilial("SC6") + "') AND (C5_CLIENTE = '" + M->C5_CLIENTE + "') "+;
                    "AND (C6_NUM <> '" + M->C5_NUM + "') AND (C5_EMISSAO LIKE '" + SUBSTR( DTOS( M->C5_EMISSAO ), 1, 6 ) + "%') AND ( C5_EMISSAO <= '" + DTOS( M->C5_EMISSAO ) + "') AND "+;
                    "(C5_TIPO NOT IN ('D','B')) AND ((F4_DUPLIC = 'S') OR (C6_TES = '519')) " 
                    //Conforme conversado com a Eliana o saldo do pedido para pedidos de tintas e com embalgens(comissão igual a zero) devem ser consideradas.
           If !INCLUI //Considerar registros anteriores apenas para manter regra
              cQry1 += " AND (SC5.R_E_C_N_O_ < " + Alltrim( Str( SC5->( Recno() ) ) ) + ")"
           Endif
           TCQuery cQry1 ALIAS "TCQSLD" NEW
           DbSelectArea("TCQSLD")
           If !Eof() .and. !Bof()
              nSaldoVend := TCQSLD->SALDO
           Else
              nSaldoVend := 0
           Endif
           DbSelectArea("TCQSLD")
           DbCloseArea()
           nSaldoVend += _nVlrTDup
           _nVlrTotMin := _nZPPAR37 //LGS#20220201 - Alterado valor fixo para parâmetros facilitando ajustes futuros

           If M->C5_TIPO == 'N' .and. _nVlrTDup > 0
              If _nPrzMedio > _nZPPAR38 .and. _nComisCal < _nMedComiss //LGS#20220201 - Alterado valor fixo para parâmetros facilitando ajustes futuros
                 lProblPrazo := .t. //Não respeita prazo mínimo!!
                 lDescOk := .f.
              Else
                 nTolerancia := 0.005
                 /*Do Case
                    POLITICA ANTIGA DE VALOR MINIMO
                    Case nSaldoVend < _nVlrTotMin //750
                         lDescOk := .f.
                    Case nSaldoVend <= 3000
                         _nVlrTotMin := aPrcMin[1]
                    Case nSaldoVend <= 5000
                         _nVlrTotMin := aPrcMin[2]
                    Case nSaldoVend <= 8000
                         _nVlrTotMin := aPrcMin[3]
                    Case nSaldoVend <= 11000
                         _nVlrTotMin := aPrcMin[4]
                    OtherWise
                         _nVlrTotMin := aPrcMin[5]
                 EndCase */
                 //_lIcmsIPI := Iif( SF4->F4_INCIDE == "S", .T., .F. )
                 //Consumidor Final LGS#20220621 - Desabilitada regra para consumidor final
                 //If _nPercIcms >= 18 .and. _lIcmsIPI //Tipo de consumidor Não Contribuinte para nova politica necessitou de tratatica devido a ser array e não vertor
                 //   _nPosProx   := 1
                 //Else
                 _nPosProx := aScan( _aNewPol, { |x| x[3] >= nSaldoVend } )
                 Do Case
                    Case nSaldoVend < _nVlrTotMin
                         lDescOk := .f.
                    Case nSaldoVend  <= _aNewPol[1][3] //Valor até  5000.00 - 01/06/2022
                         _nVlrTotMin := _aNewPol[1][8] 
                    Case nSaldoVend  <= _aNewPol[2][3] //Valor até 11000.00 - 01/06/2022
                         _nVlrTotMin := _aNewPol[2][8]
                    Case nSaldoVend  <= _aNewPol[3][3] //Valor até 17000.00 - 01/06/2022
                         _nVlrTotMin := _aNewPol[3][8]
                    OtherWise                          //Valor maior que 17000.00 - 01/06/2022
                         _nVlrTotMin := _aNewPol[4][8]
                 EndCase
                 //Endif
                 If _nVlrTDup < _nVlrTotMin
                    nDescPerm := Iif( _nSomVlTab > 0, Round( ( 1 - ( _nVlrTotMin / _nSomVlTab ) ) * 100, 2 ), 0 )
                    If M->C5_DESCON4 - nDescPerm > nTolerancia * 100
                       lDescOk := .f.
                    Endif
                 Endif
              Endif
           Endif
           //Ajusta comissão Fixa
           If _nComisCal > _nMedComiss .OR. lDescOk
              _nComisCal := _nMedComiss
           Endif
           //Não permitir que comissão seja maior que 5%, por segurança (30/10/09) => Cleber
           If _nComisCal > 5
              _nComisCal := 5
           Endif
           /*******************************************************************************/
           /***                Nova politica comercial - COMISSIONAMENTO                ***/
           _lComis := .f.
           If _nPosProx > 0  .and. _nVlrTDup > 0
              _cLogPed += 'Faixa: ' + StrZero( _aPolDes[_nPosProx][1], 1 ) + ' | De: ' +;
                                      Transform( _aPolDes[_nPosProx][2], '@E 999,999.99' ) + ' | a ' +;
                                      Transform( _aPolDes[_nPosProx][3], '@E 999,999.99' ) + ' | ' +;
                                      Transform( _aPolDes[_nPosProx][4], '@E 999.999' ) + ' | ' +;
                                      Transform( _aPolDes[_nPosProx][5], '@E 999.999' ) + ' | ' +;
                                      Transform( _aPolDes[_nPosProx][6], '@E 999.999' ) + ' | ' +;
                                      Transform( _aPolDes[_nPosProx][7], '@E 999.999' ) + ' | ' +;
                                      Transform( _aPolDes[_nPosProx][8], '@E 999.999' ) + ' |' + Chr(13) + Chr(10)
           Endif
           //If !_lComisZer //Produtos com itens que tenham comissão zero, considera média de comissão  
           //If _nComisZer < _nContItem
              If _nPosProx > 0  .and. _nVlrTDup > 0
                 For _nI := 4 To 8
                     If !_lComis
                        If _aPolDes[_nPosProx][_nI] == M->C5_DESCON4
                           _nComisCal := Iif( _nI == 4, 5, _nComisCal := Iif( _nI == 5, 4, _nComisCal := Iif( _nI == 6, 3, _nComisCal := Iif( _nI == 7, 2, 1 ) ) ) )
                           _lComis := .T.
                        ElseIf _aPolDes[_nPosProx][_nI] <= M->C5_DESCON4
                               _nComisCal := Iif( _nI == 4, 5, _nComisCal := Iif( _nI == 5, 4, _nComisCal := Iif( _nI == 6, 3, _nComisCal := Iif( _nI == 7, 2, 1 ) ) ) )
                        Else
                           _nComisCal := Iif( _nI == 4, 5, _nComisCal := Iif( _nI == 5, 4, _nComisCal := Iif( _nI == 6, 3, _nComisCal := Iif( _nI == 7, 2, 1 ) ) ) )
                           _lComis := .T.
                        Endif
                     Endif
                 Next
              Endif
           //Endif
           _cLogPed += 'Comissão Cal.: ' + TransForm( _nComisCal, '@E 999,999.999' ) + '  |  TEM EMBALAGEM: ' + Iif( _lComisZer, 'SIM', 'NÃO' ) + Chr(13) + Chr(10)
           If _lComisZer //Verificar se existe itens de embalagem sem comissão
              _nTotCom := 0
              DbSelectArea('SB1')
              SB1->( DbSetOrder( 1 ) )
              For _nX := 1 To Len( aCols )
                  If SB1->( DbSeek( xFilial('SB1' ) + aCols[_nX][_nPosPROD] ) )
                     If SB1->B1_COMIS > 0
                        _nTotCom += aCols[_nX][_nPosVALOR] * ( _nComisCal / 100 )
                     Endif
                  Endif
              Next
              _nComisCal := Round( ( ( _nTotCom / _nVlrTDup ) * 100 ), 4 )
           Endif
           _cLogPed += 'Comissão Pol.: ' + TransForm( _nComisCal, '@E 999,999.999' ) + Chr(13) + Chr(10)
           _cLogPed += 'Saldo Pedidos Anteriores: ' + TransForm( nSaldoVend, '@E 999,999,999.999' ) + Chr(13) + Chr(10)
           If _lZPPAR50 //Habilita/Desabilita politica comercial para solventes
              If M->C5_TIPO = 'N' .and. _lSoSolven .and. !lDescOk .and. (_nVlrTDup > 0) //Permissão de desconto adicional para as linhas 71,10 - solventes
                 //Chamado 004437(Eliana) em que solicita que se aplique desconto máximo independente do valor vendido
                 _nVlrTotMin := Iif( _cTipoCons == 'N' , _aNewPol[1][8], _aNewPol[4][8] ) //aPrcMin[5] //aPrcMin[6] LGS#20220413 - Nova Politica enviada pela Eliana 02/03/2022
                 If _nVlrTotMin <= _nVlrTDup
                    _nComisCal := 5      //Se atingir o valor minimo comissão de 5
                    lDescOk := .t.
                 Else 
                    nAux := _nVlrTotMin*0.95
                    If nAux <= _nVlrTDup
                       _nComisCal := 4
                       lDescOk := .t.
                    Else
                       nAux := nAux*0.95
                       If nAux <= _nVlrTDup 
                          _nComisCal := 3
                          lDescOk := .t.
                       Else
                          nAux := nAux*0.95
                          If nAux <= _nVlrTDup
                             _nComisCal := 2
                             lDescOk := .t.
                          Else
                             nAux := nAux*0.95
                             If nAux <= _nVlrTDup
                                _nComisCal := 1
                                lDescOk := .t.
                             Endif
                          Endif
                       Endif
                    Endif
                 Endif 
              Endif
           Endif
           /*****************************************************************************************************/
           //AJUSTE DE COMISSÃO PARA CONVENÇÃO DE VENDAS 2023 - LINHA PÓ - COMISSÃO MENOR 1% e 2% AJUSTAR PARA 3%
           /* andre em 09/09/2025
           If M->C5_EMISSAO == _dZPPAR84 //Pedidos com entrada na data da CONVENÇÃO
              If _cFilial $ Alltrim( _cZPPAR85 ) //Filial valida para CONVENÇÃO
                 If ( _nComisCal == 1 ) .or. ( _nComisCal == 2 )
                    _nComisCal := _nZPPAR87
                 Endif
              Endif
           Endif
           /*
           /*****************************************************************************************************/
           If _nVlrTDup > 0
              _nLucroCal := ( ( _nValReal - (((_nComisCal + M->C5_COMIS2) * _nVlrTDup) / 100)) / _nVlrTDup) * 100
           Else
              _nLucroCal := 0
           Endif
           //Marcar pedido, caso não esteja em conformidade com a política p/ revenda. Desconsiderar depósito fechado
           If !lDescOk .and. _lGeraDup .and. (_cNumEmp != "01010106") .and. (_cNumEmp != "01010107") .and. (_cNumEmp != "01010108")
              //Cleber (27/11/2013) => Eliana pediu pra não mais bloquear pedidos por probl. pol. vendas
              //M->C5_NAOCONF := "S"
           Endif
           If !lDescOk .and. M->C5_NAOCONF == "S"
              cMensErro := "Atencao! Pedido "+M->C5_NUM+" NAO RESPEITA as Politicas Comerciais Para Revenda!"
              If fValAtrib("l410Auto") <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01" //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
                 FwLogMSG( "WARN", , 'SIGAFAT', FunName(), '', '01', cMensErro, 0 )
              Else
                 MessageBox( cMensErro, "Atenção", 16 )
              Endif
           Endif
        Else 
           If _nComisCal < 0 .and. _lGeraDup .and. !(alltrim(_cNumEmp) $ "01010106-01010107-01010108")
              //Cleber (27/11/2013) => Eliana pediu pra não mais bloquear pedidos por probl. pol. vendas
              //M->C5_NAOCONF := "S"
           Endif
        Endif //Fim if lSisRev
        //Chamado 020971, campanha de vendas
        If _lCampanha .and. !Empty( _cTabCamp )
           Dbselectarea("DA0")
           If DA0->( DbSeek( xFilial("DA0") + _cTabCamp ) )
              If DA0->DA0_COMIS > 0
                 _nComisCal := DA0->DA0_COMIS
              Else
                 _nComisCal := 1 //Por precaução colocar 1% que é a comissão mínima
              Endif 
              M->C5_XCONF := .T. //Comissão fixa
           Endif 
        Endif
        //Chamado 024740, definir comissão fixa. Combinado que quando o cadastro do representante contiver percentual de comissão então a mesma será fixa
        If !_lCampanha .and. M->C5_XCONF 
           _nComisCal := SA3->A3_COMIS
        Endif
        If M->C5_XCONF
           _nMedComiss := _nComisCal //Fixar comissão padrão igual à comissão de campanha ou igual à cadastrada em SA3
           If _nVlrTDup > 0
              _nLucroCal := ( ( _nValReal - ( ( ( _nComisCal + M->C5_COMIS2 ) * _nVlrTDup ) / 100 ) ) / _nVlrTDup ) * 100
           Else
              _nLucroCal := 0
           Endif
        Endif
        DbSelectArea("DA0")
        DbGoTop()
        If _lMisturad .AND. M->C5_TIPO = 'N' .AND. _nVlrTDup > 0
           cAux := "Atencao! Pedido " + M->C5_NUM + " possui itens de Estoque Misturados aos itens Não Estoque!"
        Endif 
        If !M->C5_TIPO = "N"
           M->C5_NAOCONF := "N"
        Endif
        // Recalcula comissao.
        If _nVlrTDup == 0 //Se o pedido não tiver financeiro zerar comissão
           _nComisCal := 0
        Endif
        _nPorcComiss := _nComisCal //Se o pedido não tiver financeiro zerar comissão
        
        
        // Alterado por Nelieder em 26/09/23
        // Prevalece ajuste de comissão do campo C5_XCOMIS1
       // If M->C5_XCOMIS1 == 0
            M->C5_PORCOM := _nPorcComiss //Cleber(03/08/21)->Eliana pediu para mostrar a comissão realizada para poder ter parâmetros de aprovação. Como foi acertado no MasterSales para passar a mostrar C5_COMIS1 então estou deixando C5_PORCOM como informativo apenas
        //else
           // M->C5_PORCOM := C5_XCOMIS1
       // Endif 

        If M->C5_TIPO == "N" .AND. _nVlrTDup > 0 .AND. _nComisCal < 1
           If _nContItem > _nComisZer
              _nComisCal := 1.0 //Nova política de comissionamento, não deverá ser menor que 1%
              _nPorcComiss := _nComisCal
              _nLucroCal := ((_nValReal - (((_nComisCal + M->C5_COMIS2) * _nVlrTDup) / 100)) / _nVlrTDup) * 100
           Else
              _nComisCal := 0.0 //Se o pedido for somente de embalagens ou itens sem comissão zerar
              _nPorcComiss := _nComisCal
              _nLucroCal := ((_nValReal - (((_nComisCal + M->C5_COMIS2) * _nVlrTDup) / 100)) / _nVlrTDup) * 100
           Endif
        Endif 
        _nVlrComiss  := _nVlrTDup * _nComisCal  / 100
        // Calcula Lucro da empresa.
        _nVlrLucro   := _nVlrTDup * _nLucroCal  / 100
        _nPorcLucro  := _nLucroCal
        //Atualiza variaveis do pedido.
        IF _nVlrTDup == 0
           _nPorcComiss := 0
        Endif
        // Alterado por Nelieder em 26/09/23
        // Prevalece ajuste de comissão do campo C5_XCOMIS1
        If M->C5_XCOMIS1 == 0
            M->C5_COMIS1 := _nPorcComiss
        else
            M->C5_COMIS1 := M->C5_XCOMIS1
        EndIf

        M->C5_VLRCOM  := _nVlrComiss
        M->C5_LUCRO   := _nPorcLucro
        M->C5_MEDCOM  := _nMedComiss
        M->C5_MEDLUCR := _nMedLucro
        If nPesoLiquTotal > 0
           M->C5_PESOL := nPesoLiquTotal
        Endif
        If nPesoBrutTotal > 0
           M->C5_PBRUTO := nPesoBrutTotal
        Endif
        If M->C5_PBRUTO < M->C5_PESOL
           M->C5_PBRUTO := M->C5_PESOL
        Endif
        If nVolTotal > 0 .and. lCalcVol
           M->C5_VOLUME1 := nVolTotal
        Endif
        If Empty(M->C5_ESPECI1) .AND. (M->C5_VOLUME1 > 0)
           M->C5_ESPECI1 := "VOLUME"
        Endif
        If Empty(M->C5_ESPECI3)
           M->C5_ESPECI3 := "VOLUME"
        Endif
        //Identificação de quem está incluindo/alterando o pedido
        If INCLUI .OR. EMPTY(M->C5_CAD)
           M->C5_CAD   := Iif(!Empty(M->C5_PEDREPR) .OR. !EMPTY(M->C5_X_PVSIM), M->C5_VEND1, rtrim(cUserName))
           M->C5_DTCAD := dDataBase
           M->C5_FLAG  := "N" // Flag informando que o pedido não foi impresso
        Endif
        If !EMPTY( M->C5_X_PVSIM ) .AND. ( ( M->C5_TIPOVEN <> "E" ) .OR. ( M->C5_CAD <> M->C5_VEND1 ) )
           M->C5_CAD := M->C5_VEND1
           M->C5_TIPOVEN := "E"
        ENDIF

        //If !((M->C5_EMISSAO >= _dZPPAR84) .and. (M->C5_EMISSAO <= _dZPPAR93))
           M->C5_ALT    := rtrim(cUserName)
        //Endif
        M->C5_DTALT  := dDataBase
        M->C5_ALTERAD := "S"
        If M->C5_TIPO <> 'N' .OR. Substr( _cCnpj, 1, 8 ) == Substr( Alltrim( SM0->M0_CGC ), 1, 8 )
           M->C5_LIBCAD := 'T'
           M->C5_USRCAD := rtrim(cUserName)
           M->C5_LIBPED := 'T'
           M->C5_USRPED := rtrim(cUserName)
           If !_lGeraDup
              M->C5_LIBCRE := 'T'
              M->C5_USRCRE := rtrim(cUserName)
              M->C5_LIBDIR := 'T'
              M->C5_USRDIR := rtrim(cUserName)
              If M->C5_APROVA <> "1"
                 M->C5_APROVA := "1"
                 M->C5_DTAPR := dDataBase
                 M->C5_SUGENT := dDataBase+1
              Endif
              M->C5_USRAPR := rtrim(cUserName)
           Endif
        Else
           //If !((M->C5_EMISSAO >= _dZPPAR84) .and. (M->C5_EMISSAO <= _dZPPAR93))
           M->C5_LIBPED := 'F'
           M->C5_USRPED := ""
           //Endif
           If INCLUI .OR. ( !INCLUI .AND. ( ROUND( _nVlrTDup, 2 ) != M->C5_VLRDUP ) )
              //If !((M->C5_EMISSAO >= _dZPPAR84) .and. (M->C5_EMISSAO <= _dZPPAR93))
              M->C5_LIBCRE := 'F'
              M->C5_USRCRE := ""
              //Endif
           Endif
           //If !((M->C5_EMISSAO >= _dZPPAR84) .and. (M->C5_EMISSAO <= _dZPPAR93))
           M->C5_LIBDIR := 'F'
           M->C5_USRDIR := ""
           //Endif
           If INCLUI .OR. (!INCLUI .AND. (M->C5_APROVA <> '2'))
              If !( _cFilial $ Alltrim( _cZPPAR40 ) ) //Empresas que não passam por aprovação de pedidos
                 //If !((M->C5_EMISSAO >= _dZPPAR84) .and. (M->C5_EMISSAO <= _dZPPAR93))
                 M->C5_APROVA := "0"
                 //Endif
                 M->C5_SUGENT := CTOD(SPACE(8))
                 M->C5_DTAPR := CTOD(SPACE(8))
               Endif
           Endif
           //If !((M->C5_EMISSAO >= _dZPPAR84) .and. (M->C5_EMISSAO <= _dZPPAR93))
               M->C5_USRAPR := ""
           //Endif
        Endif
        M->C5_VLRDUP := ROUND( _nVlrTDup, 2 )
        //Itens de IPI Zero Misturados com itens de IPI maior que zero. Chamado 007956. Relacionado a clientes Suframa
        If _lIpiZeroM .AND. (M->C5_TIPO = "N") .AND. (_nVlrTDup > 0.0) .AND. !EMPTY(SA1->A1_SUFRAMA) .AND. ((SA1->A1_CALCSUF = "N") .OR. EMPTY(SA1->A1_CALCSUF)) .AND. EMPTY(SA1->A1_CODMUN)
           cAux := "*Pedido possui item(ns) com IPI zero misturado com item(ns) de IPI maior que zero*"
           If !(cAux $ _cObs)
              _cObs += Chr(13) + Chr(10) + cAux
           Endif
        Endif

         M->C5_TIPLIB := '2' //Garantir que seja liberado por pedido e não por item

	     //IF M->C5_FILIAL ==('060101')
            //M->C5_TIPLIB := '1' 
        //ELSE
            //M->C5_TIPLIB := '2' //Garantir que seja liberado por pedido e não por item
        //ENDIF

        //25/04/16 -> Cleber - Atualizar campo C5_SUGENT (Dt. Sugestão de Entrega) com o valor da data programada para entrega
        If !EMPTY(M->C5_PEDPROG) .AND. !(M->C5_SUGENT == M->C5_PEDPROG)
           M->C5_SUGENT := M->C5_PEDPROG
        Endif
        //Atualizar prazo de entrega (em dias úteis)
        M->C5_ENTREGA := _nEntrega

        //Grava log de inclusao / alteração do pedido
        If _lRet
           RecLock( "ZZB", .t. )
              ZZB->ZZB_FILIAL := xFilial("ZZB")
              ZZB->ZZB_PEDIDO := M->C5_NUM
              ZZB->ZZB_IDLOG  := iif(INCLUI, 'INC', 'ALT')
              ZZB->ZZB_USRLOG := rtrim(cUserName)
              ZZB->ZZB_DATLOG := dDataBase
              ZZB->ZZB_HORLOG := Time()
           MsUnLock()
        Endif
        //Cleber(09/01/19) -> Uso cálculo Frete CIF
        If (M->C5_TIPO = "N") .AND. (M->C5_TPFRETE = "C") // .AND. !EMPTY(M->C5_REDESP) //.AND. lCalcFrete
           If SA4->( DbSeek( xFilial("SA4") + M->C5_REDESP ) )
               If !SUBSTRING(SA4->A4_CGC,1,8) $ Alltrim( _ZPPAR0202 ) 
                  lFreteTerc := .T.
               Endif
           Endif
           If _PerFrete > 0 .AND. lFreteTerc .AND. (_cFilial =='010101')  // Se o cliente tiver o percentual do frete preenchido e não for transporte brasilux
              nVlrTot := Ma410Impos(3,.T.)   // Calcular o % de frete sobre o valor total da nota
              M->C5_FRETE := Round(((nVlrTot * _PerFrete)/100),2)
           Endif
           M->C5_COMPENS := "N" //Não participa de compensação de comissão
           cTrpBrz       := "00250 " //Transp. para cálc frete Brasilux
           dbselectarea("Z15")
           dbsetorder(1)
           If !Z15->( DbSeek( xFilial("Z15") + cTrpBrz + SA1->A1_CODCID ) )
              M->C5_XVLRFRE := 0.0
           Else
              If !Empty( Alltrim( M->C5_ESPECI4 ) )
                 M->C5_XVLRFRE := 0.0
                 M->C5_TPFRETE := "F"
                 nPos1         := AT( "<CIF>", _cObs )
                 If nPos1 > 0
                    nPos2 := AT( "<CIF>", _cObs, nPos1+5 )
                    cAux := substr( _cObs, 1, nPos1-1 ) + SubStr( _cObs, nPos2+5, Len(_cObs)-nPos2-4 )
                    _cObs := cAux
                 Endif
                 cAuxMens := "Linha 70 NÃO PODE TER FRETE CIF!!"
                 If fValAtrib("l410Auto") <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01" //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
                    FwLogMSG( "WARN", , 'SIGAFAT', FunName(), '', '01', cAuxMens, 0 )
                 Else
                    MessageBox( cAuxMens, "Atenção", 16 )
                 Endif
                 _cObs += "<CIF>"+cAuxMens+"<CIF>"
              Else
                 nVlrTot := Ma410Impos(3,.T.) // Cálculo do valor total da NF
                 //Varrer transportadoras para ver qual a que tem menor frete
                 nAux := 9999999.9
                 DbSelectArea("SA4")
                 DbSetOrder(1)
                 DbSelectArea("Z15")
                 DbOrderNickName("Z15CID")
                 DbSeek( xFilial("Z15") + SA1->A1_CODCID )
                 While !eof() .and. (Z15->Z15_FILIAL == xFilial("Z15")) .AND. (Z15->Z15_CODCID == SA1->A1_CODCID)
                       nVlrFrete := 0.0
                       nPercFrete := Z15->Z15_ADVALO
                       nVlrFrete += Z15->Z15_VLRFPE
                       If M->C5_PBRUTO > Z15->Z15_PESLIM
                          nVlrFrete += Z15->Z15_VLREXC*(M->C5_PBRUTO - Z15->Z15_PESLIM)
                       Endif
                       DbSelectArea("SA4")
                       If SA4->( DbSeek( xFilial("SA4") + Z15->Z15_CODTRA ) )
                          nPercFrete += SA4->A4_FREPERC
                          nVlrFrete += M->C5_PBRUTO*SA4->A4_FREPED
                          nVlrFrete += SA4->A4_FRETX
                       Endif
                       nVlrFrete += (nPercFrete*nVlrTot/100.0)
                       If SA4->(FieldPos("A4_ICMFRET")) > 0
                          If SA4->A4_ICMFRET > 0.0
                             nVlrFrete := round(nVlrFrete/SA4->A4_ICMFRET,2) // Indice de icms de frete. Por ex., se for agregar 7% então A4_ICMFRET será 0.93
                          Endif
                       Endif
                       If Z15->Z15_CODTRA = cTrpBrz
                          M->C5_XVLRFRE := 0 //nVlrFrete  //LGS#20230309 - Retirada gravação do valor do frete CIF
                          /*nPos1 := AT("<CIF>", _cObs) //LGS#20230309 - Retirada mensagem de frete CIF
                          If nPos1 > 0
                             nPos2 := AT("<CIF>", _cObs, nPos1+5 )
                             cAux := substr( _cObs, 1, nPos1-1 ) + Substr( _cObs, nPos2+5, Len( _cObs )-nPos2-4)
                             cObs := cAux
                          Endif
                          _cObs += "<CIF>Valor do Frete CIF: "+TRANSFORM(nVlrFrete, "@E 999,999.99") +"<CIF>"*/
                       Else
                          If nAux >= nVlrFrete
                             //M->C5_REDESP := Z15->Z15_CODTRA  //LGS#20230313 - Retirada gravação de codigo de transporte qdo CIF.
                             nAux := nVlrFrete
                          Endif
                       Endif
                       DbSelectArea("Z15")
                       DbSkip()
                 Enddo
              Endif
           Endif
        Endif
        M->C5_X_OBSFA := _cObs
        // INICIO
      If _ZPPAR0110
         // inicio da nova regra de comissão fixa para representantes
         PosREpre   := 0
         lFixProdu  := .F. // Produto
         lFixPolit  := .F. // Politica

         _cLogPed += Chr(13) + Chr(10)
         _cLogPed += "Comissão Fixa."

         // Pega lista de Representantes
         aRepre := strtokarr (_ZPPAR0106, ",")
         
         PosREpre :=  aScan(aRepre, {|x|x == M->C5_VEND1})
         If PosREpre > 0

            _cLogPed += Chr(13) + Chr(10)
            _cLogPed += "Representante :="+M->C5_VEND1
            // Loop produtos pedido
            For _nX := 1 to Len(aCols)
               
               aProd := strtokarr (_ZPPAR0108, ",") // pega produtos parametro
               For j := 1 to len(aProd)

                     aEmb := strtokarr (_ZPPAR0109, ",") // pega embalagens
                        For i := 1 to len(aEmb)
                           
                           // Compara Produtos+Embalagens MV com Pedido de Vendas
                           If Alltrim( aCols[_nX][ _nPosPROD ] ) == AllTrim(aProd[j])+AllTrim(aEmb[i])
                              lFixProdu := .T.
                           EndIf

                        Next

               Next
            Next

            // caso não tenha produtos que estão fora da regra entra
            If !lFixProdu

               _cLogPed += Chr(13) + Chr(10)
               _cLogPed += "Entrou para Calculo" 
               // 0,20.99,5,21,30,3
               // 0% a 20,99% = 5% comissão 
               // 21% a 30%   = 3% comissão
               aPolitic := strtokarr (_ZPPAR0107, ",")
               if (M->C5_DESCON4 >= Val(aPolitic[1]))  .AND. (M->C5_DESCON4 <= Val(aPolitic[2]))
                  
                  // Alterado por Nelieder em 26/09/23
                  // Prevalece ajuste de comissão do campo C5_XCOMIS1 
                  If M->C5_XCOMIS1 == 0
                     M->C5_COMIS1 := Val(aPolitic[3])
                  else
                     M->C5_COMIS1 := M->C5_XCOMIS1
                  EndIf 

                  M->C5_X_OBSFA := M->C5_X_OBSFA + Chr(13) + Chr(10) + "Ajuste Comissão Fixa para "+AllTrim(Str(M->C5_COMIS1))+"% - "+DTOC(dDataBase)+Time()
                  
                  _cLogPed += Chr(13) + Chr(10)
                  _cLogPed += "Calculo 1"
               
                  //U_EnvMail("Pedido com Frete CIF "+M->C5_NUM,"Entrou Pedido","neliedercorneta@brasilux.com.br","","")
               EndIf

               if (M->C5_DESCON4 >= Val(aPolitic[4]))  .AND. (M->C5_DESCON4 <= Val(aPolitic[5]))
                  
                 // Alterado por Nelieder em 26/09/23
                 // Prevalece ajuste de comissão do campo C5_XCOMIS1
                  If M->C5_XCOMIS1 == 0
                     M->C5_COMIS1 := Val(aPolitic[6])
                  else
                     M->C5_COMIS1 := M->C5_XCOMIS1
                  EndIf 

                  M->C5_X_OBSFA := M->C5_X_OBSFA + Chr(13) + Chr(10) + "Ajuste Comissão Fixa para "+AllTrim(Str(M->C5_COMIS1))+"% - "+DTOC(dDataBase)+Time()
                  
                  _cLogPed += Chr(13) + Chr(10)
                  _cLogPed += "Calculo 2 "
                  
                  //U_EnvMail("Pedido com Frete CIF "+M->C5_NUM,"Entrou Pedido","neliedercorneta@brasilux.com.br","","")
               EndIf

               EndIf   

         EndIf   

      EndIf
      // fim da nova regra de comissão fixa para representantes

      // Regra de comissão cliente fixo
      // Nelieder em 28/07/23
      If (SA1->A1_COMIS > 0) .AND. ( M->C5_XCOMIS1 == 0)
         M->C5_COMIS1 := SA1->A1_COMIS
         M->C5_X_OBSFA := M->C5_X_OBSFA + Chr(13) + Chr(10) + "Cliente com Comissão Fixa de "+AllTrim(Str(SA1->A1_COMIS))+"%"
         _cLogPed += Chr(13) + Chr(10)
         _cLogPed += "Cliente com Comissão Fixa de "+AllTrim(Str(SA1->A1_COMIS))+"%"
      EndIf   


      // Troca Trigger trig_inclui_SC5010
      // Nelieder 14/09/23

      If INCLUI .AND. _ZPPAR0204
         If !Empty(M->C5_PEDREPR)  .AND. !Empty(M->C5_VEND1)
           cQry1 := " SELECT TOP 1 R_E_C_N_O_ RegZ6 FROM "+RetSqlName("ZZ6")+" ZZ6 "
           cQry1 += " WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (ZZ6_EMPR = '"+xFilial("SB1")+"') "
           cQry1 += " AND (ZZ6_TABELA = 'SC5') AND (ZZ6_CHAVE = '"+Alltrim(M->C5_NUM)+"') AND (ZZ6_VEND = '"+Alltrim(M->C5_VEND1)+"') "
           TCQuery cQry1 ALIAS "TMPT" NEW
           DbSelectArea("TMPT")
           Count to nTotal
           TMPT->(DbGoTop())
           TMPT->(dbCloseArea())

           If (nTotal > 0) 
               _cLogPed += Chr(13) + Chr(10)
               _cLogPed += "Atualizou a tabela ZZ6 "
               _cLogPed += Chr(13) + Chr(10)
               cQry1 := "UPDATE "+RetSqlName("ZZ6")+" SET ZZ6_PROCES = 'N',ZZ6_APAGAR = 'F',ZZ6_VEND = '"+Alltrim(M->C5_VEND1)+"' ,ZZ6_ULTATU = CONVERT(VARCHAR,GETDATE(),112) WHERE R_E_C_N_O_ = '"+Alltrim(M->RegZ6)+"' "
               _cLogPed += cQry1
               TCSqlExec(cQry1)
           else
               reclock("ZZ6",.T.)
                  ZZ6->ZZ6_FILIAL := xFilial("ZZ6")
                  ZZ6->ZZ6_EMPR   := xFilial("SC5")
                  ZZ6->ZZ6_TABELA := "SC5"
                  ZZ6->ZZ6_CHAVE  := M->C5_NUM
                  ZZ6->ZZ6_DIA    := dDataBase
                  ZZ6->ZZ6_APAGAR := .F.
                  ZZ6->ZZ6_PROCES := "N"
                  ZZ6->ZZ6_VEND   := M->C5_VEND1
                  ZZ6->ZZ6_ULTATU := date()
               MsUnLock()
               _cLogPed += Chr(13) + Chr(10)
               _cLogPed += "Incluiu registro novo ZZ6 "+Alltrim(Str(recno()))
           EndIf 


         EndIf
      EndIf

            // Troca Trigger trig_inclui_SC5010
            // Nelieder 14/09/23

            If ALTERA .AND. _ZPPAR0205

               cQry1 := " UPDATE "+RetSqlName("SC9")+"  SET C9_APROVA = " 
               cQry1 += " CASE " 
               cQry1 += " WHEN ISNULL('"+Alltrim(M->C5_APROVA)+"','') < '1' THEN '0' " 
               cQry1 += " WHEN ISNULL('"+Alltrim(M->C5_APROVA)+"','') = '2' THEN '2'  "
               cQry1 += " WHEN C6_TES IN ('519','507')                      THEN '9' "
               cQry1 += " ELSE '1' "
               cQry1 += " END "
               cQry1 += " FROM "+RetSqlName("SC9")+" SC9  WITH (NOLOCK) "
               cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (C9_FILIAL = C6_FILIAL) AND (C9_PEDIDO = C6_NUM) AND (C6_ITEM = C9_ITEM) "
               cQry1 += " WHERE (SC9.D_E_L_E_T_ <> '*') AND (C9_FILIAL = '"+xFilial("SB1")+"') AND (C9_PEDIDO = '"+Alltrim(M->C5_NUM)+"') "
               
               nRet := TCSQLExec(cQry1)
      
               If(nRet < 0 )
                  _cLogPed += Chr(13) + Chr(10)
                  _cLogPed += "Trig_inclui_SC5010 Erro na execução da query:"+TcSqlError()
               Else
                  _cLogPed += Chr(13) + Chr(10)
                  _cLogPed += "Trig_inclui_SC5010 foi executado com sucesso! "+cQry1
               EndIf
               
               If  (M->C5_X_SIM3G <> '')  .AND.  (SC5->C5_X_SIM3G <> '') 
                  cQry1 := " UPDATE "+RetSqlName("SC6")+" SET C6_X_SIM3G = '"+Alltrim(M->C5_X_SIM3G)+"', C6_X_EXPO = ' ' WHERE (C6_FILIAL = '"+xFilial("SC6")+"') AND (C6_NUM = '"+Alltrim(M->C5_NUM)+"') AND (C6_X_SIM3G <> '"+Alltrim(M->C5_X_SIM3G)+"'); "
                  nRet := TCSQLExec(cQry1)
               EndIf

            EndIf

          

        MEMOWRITE( '\dirdoc\Comercial\Ponto_Entrada\MTA410\' + SubStr( _cFilial, 1, 2) +   '_' + M->C5_NUM + '_' + DTOS( M->C5_EMISSAO ) + '_' + StrTran( Time(), ':', '' ) + '.log', _cLogPed )
        DbSelectArea( _cArqTmp )
        ( _cArqTmp )->( DbCloseArea() )
        _oTmpTable:Delete()
     ElseIf _cGrpEmp = "11" //Empresas que  são do grupo 11(Tecpolpa).
           /**********************************************************************************************************************************/
           /***                                                   VALIDAÇÕES DA TECPOLPA                                                   ***/
           /**********************************************************************************************************************************/
           lCampanha := .f.    //TecPolpa não participa de campanha até o momento
           If M->C5_TIPO = "N"
              DbSelectArea("SA1")
              If SA1->( DbSeek( xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI ) )
                 If !Empty( M->C5_X_PVSIM )
                    M->C5_X_SIM3G := "S"
                    If INCLUI 
                       M->C5_VEND1 := SA1->A1_VEND
                       M->C5_EMISSAO := DATE()
                       M->C5_FRETE := 0.0
                       M->C5_SEGURO := 0.0
                       //Cleber(07/01/21) -> Descobri que desde outubro/2020 não está gravando banco
                       If !Empty( SA1->A1_BCO1 ) .AND. Empty( M->C5_BANCO )
                          M->C5_BANCO := SA1->A1_BCO1
                       Endif 
                    Endif
                 Endif 
                 If Empty( M->C5_VEND1 )
                    M->C5_VEND1 := SA1->A1_VEND
                 Endif 
              Endif 
           Endif 
           For _nX := 1 to Len(aCols)
               If !aCols[_nX][Len(aHeader)+1] //Se não for registro deletado
                  // Zerar Descontos para não aparecer valor maior em Valor Contabil em SF3
                  nAux := TamSX3("C6_PRCVEN")[2]
                  aCols[_nX][_nPosPRUNI] := aCols[_nX][_nPosPRCVE]
                  aCols[_nX][_nPosDESCO] := 0
                  aCols[_nX][_nPosVALDE] := 0
                  nAux := TamSX3("C6_VALOR")[2]
                  IF M->C5_TIPO = "N"
                     aCols[_nX][_nPosVALOR] := round(aCols[_nX][_nPosPRCVE]*aCols[_nX][_nPosQTDVE],nAux)
                  ENDIF
                  //*****************
                  // Checar consistências
                  DbSelectArea("SF4") //Tipo de Entrada e Saída
                  If !SF4->( DbSeek( xFilial("SF4")+aCols[_nX][_nPosTES] ) )   // Jose 23/09/2022
                     _lRet := .f.
                     cAuxMens := "Não encontrado o TES "+aCols[_nX][_nPosTES]+" no cadastro. Contacte o Adm. do Sistema!"
                     If (fValAtrib("l410Auto") <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01") //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
                        FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAuxMens, 0 )
                     Else
                        MessageBox( cAuxMens, "Atenção", 16 )
                     Endif
                     Exit
                  Endif
                  If ( SF4->F4_DUPLIC $ 'S ' ) 
                     _lGeraDup := .t.
                  Endif
                  //Enviar pedido p/ MasterSales
                  If M->C5_X_SIM3G = "S" .AND. _lGeraDup
                     aCols[_nX,nPosC6SIM3G] := "S"
                  Else
                     aCols[_nX,nPosC6SIM3G] := "N"
                  Endif
                  //*****************
                  //Chamado 024692, compatibilizar a data de entrega do cabeçalho com a data de entrega de SC6
                  If !Empty( M->C5_FECENT ) .AND. ( M->C5_FECENT != aCols[_nX][nPosENTREG] )
                     aCols[_nX][nPosENTREG] :=  M->C5_FECENT
                  Endif 
               Endif
           Next
           // Zerar Descontos para não aparecer valor maior em Valor Contabil em SF3
           M->C5_DESC1 := 0
           M->C5_DESC2 := 0
           M->C5_DESC3 := 0
           M->C5_DESC4 := 0
           /**********************************************************************************************************************************/

          If ALTERA .AND. _ZPPAR0205
            
            If  (M->C5_X_SIM3G <> '')  .AND.  (SC5->C5_X_SIM3G <> '') 
               cQry1 := " UPDATE "+RetSqlName("SC6")+" SET C6_X_SIM3G = '"+Alltrim(M->C5_X_SIM3G)+"', C6_X_EXPO = ' ' WHERE (C6_FILIAL = '"+xFilial("SC6")+"') AND (C6_NUM = '"+Alltrim(M->C5_NUM)+"') AND (C6_X_SIM3G <> '"+Alltrim(M->C5_X_SIM3G)+"'); "
               nRet := TCSQLExec(cQry1)
            EndIf

          EndIf     
      
   Endif

   // Envia E-mail para Deposito informando que pedido é CIF de MT
   // Nelieder em 12/05/2023 
   If _ZPPAR0100  
   If _lRet // .AND. (SA1->A1_EST == "MT")
      If (INCLUI .AND. SC5->C5_TPFRETE == "C") //.OR. (ALTERA .AND. M->C5_TPFRETE == "C" .AND. SC5->C5_TPFRETE <> "C") 
         If INCLUI
            TxtMail := "Foi incluido um novo Pedido com Frete CIF."+chr(13)+chr(10)
            TxtMail += "Nº Pedido : "+M->C5_NUM+chr(13)+chr(10)
            TxtMail += "Cliente : "+AllTrim(SA1->A1_COD)+ " - "+AllTrim(SA1->A1_NOME)+chr(13)+chr(10)
            TxtMail += "Cidade : "+AllTrim(SA1->A1_MUN)+ " - UF : "+AllTrim(SA1->A1_EST)+chr(13)+chr(10)+chr(13)+chr(10)
            TxtMail += "Empresa : "+_cFilial
            TxtMail += "Tipo de Frente : "+AllTrim(SC5->C5_TPFRETE)
            U_EnvMail("Pedido com Frete CIF",TxtMail,"neliedercorneta@brasilux.com.br","","")
         EndIf      
      EndIf   
   EndIf
   EndIf 

   
   


     RestArea( _aArea )
Return(_lRet)

Static Function DetCubagem( _cCodProd )
       Local _nRet
       //Local cQuery, cCursor
       Local _aArea := GetArea()
       Local _cAliasEST := GetNextAlias()

       BeginSQL Alias _cAliasEST
                SELECT ISNULL( SUM( SB1.B1_ESP05 ), 0 ) AS CUBAGEM 
                FROM %table:SG1% SG1 
                LEFT OUTER JOIN %table:SB1% SB1 ON SB1.%notdel% AND SB1.B1_FILIAL = SG1.G1_FILIAL AND SB1.B1_COD = SG1.G1_COMP
                WHERE SG1.%notdel%
                  AND SG1.G1_FILIAL = %xFilial:SG1% 
                  AND SG1.G1_COD    = %exp:_cCodProd%
       EndSQL
       DbSelectArea( _cAliasEST )
       _nRet := (_cAliasEST)->CUBAGEM
       ( _cAliasEST )->( DbCloseArea() )
       /*
       cCursor := U_NovoCursor()
       cQuery := "SELECT ISNULL(SUM(B1_ESP05),0) AS CUBAGEM FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "+;
                 "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = G1_COMP) "+;
                 "WHERE (SG1.D_E_L_E_T_ <> '*') AND (G1_FILIAL = '"+xFilial("SG1")+"') AND (G1_COD = '"+alltrim(cProd)+"') "
       TCQuery cQuery NEW ALIAS (cCursor)
       nRet := (cCursor)->CUBAGEM
       dbSelectArea(cCursor)
       dbclosearea()*/
       If _nRet <= 0
          /*cQuery := "SELECT ISNULL(B1_ESP05,0) AS CUBAGEM FROM "+RetSqlName("SB1")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = '" + _cCodProd + "')"
          TCQuery cQuery NEW ALIAS (cCursor)*/
          BeginSQL Alias _cAliasEST
                   SELECT ISNULL( SB1.B1_ESP05, 0 ) AS CUBAGEM 
                   FROM %table:SB1% SB1 
                   WHERE SB1.%notdel%
                     AND SB1.B1_FILIAL = %xFilial:SB1%
                     AND SB1.B1_COD    = %exp:_cCodProd%
          EndSQL
          DbSelectArea( _cAliasEST )
	       _nRet := ( _cAliasEST )->CUBAGEM
          ( _cAliasEST )->( DbCloseArea() )
          /*dbSelectArea(cCursor)
          dbclosearea()*/
       Endif
       RestArea( _aArea )
Return( _nRet )

/*/{Protheus.doc} fCalPrzMed
Função criada para calculo do prazo médio de pagamento.
@type function
@version v2022.0527
@author Luís Gustavo Souza
@since 27/05/2022
@param _cCondPag, Character, Código da codição de pagamento digitada no pedido
@param _nQtdeParc, Numeric, Quantidade de parcelas da condição de pagamento
@param _Prazos, Array, Vetor com prazos em dias + % de cada parcela sobre total e cálculo do prazo médio
@param _nPrzMedio, Numeric, Valor do prazo médio de pagamento
@param _lRet, Logical, Retorna verdadeiro ou falso conforme a validação efetuada
/*/
Static Function fCalPrzMed( _cCondPag, _nQtdeParc, _aPrazos, _nPrzMedio, _lRet )
       Local _dDiaFat   := dDataBase //Considerar dia do Faturamento data de hoje para cálculo do prazo médio
       Local _aVenctos  := {}        //Vetor com prazos de pagamentos
       Local _nI        := 0
       Local _nTotalTp9 := 0         //Valor total dos valores das parcelas tipo 9
       Local _cAuxMens  := ""
       Local _cAuxCPO

       DbSelectArea("SE4")  // Condição de Pagamento
       SE4->( DbSetOrder(1) )
       If SE4->( DbSeek( xFilial("SE4") + _cCondPag ) )
          //Cleber(24/07/18) Solicitação Eliana, chamado 010813 -> pedidos com cond. pgto até 7 dias calcular comissão como se fosse à vista
          _cCondPag := fEhAvista( M->C5_CONDPAG )
          If SE4->E4_TIPO <> "9"
             _aVenctos := Condicao( 100, _cCondPag, 0.00, _dDiaFat, 0.00 ) //Condicao( nValTot, cCond, nVIPI, dData, nVSol )
          Else
             For _nI := 1 To 4
                 _cAuxCPO := "M->C5_DATA" + Alltrim( Str( _nI ) )
                 If !Empty( &_cAuxCPO )
                    aAdd( _aVenctos, { &_cAuxCPO, 0 } )
                    _cAuxCPO  := "M->C5_PARC" + Alltrim( Str( _nI ) )
                    If &_cAuxCPO <= 0
                       _lRet := .f.
                       _cAuxMens := "Preencha Todos os Valores para os Vencimentos Apontados!"
                       If fValAtrib( "l410Auto" ) <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01"
                          FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', _cAuxMens, 0 )
                       Else
                          MessageBox( _cAuxMens, "Atenção", 48 )
                       Endif
                       Exit
                    Endif
                    _nTotalTp9        += &_cAuxCPO
                    _aVenctos[_nI][2] := &_cAuxCPO
                    _nQtdeParc++
                 Else
                    _cAuxCPO := "M->C5_PARC" + Alltrim( Str( _nI ) )
                    If &_cAuxCPO > 0
                       _lRet := .f.
                       _cAuxMens := "Preencha Todos os Vencimentos para os Valores Apontados!"
                       If fValAtrib("l410Auto") <> "U" .and. l410Auto .and. ProcName(nPosi) <> "U_ZFATP01"
                          FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', _cAuxMens, 0 )
                       Else
                          MessageBox( _cAuxMens, "Atenção", 48 )
                       Endif
                       Exit
                    Endif
                 Endif
             Next
             If _nQtdeParc == 0
                _nQtdeParc := 1
                _nTotalTp9 := 1
                M->C5_DATA1 := dDataBase
                aAdd( _aVenctos, { dDataBase, 1 } )
             Endif
          Endif
       Else
          _nTotalTp9 := 1
          _aVenctos  := {}
          aAdd( _aVenctos, { dDataBase, 1 } )
       Endif
       //Chamado 014805, problema com cond. pgto datas fixas vencto, comissionamento muda devido a não se saber dia do faturamento,
       //considerar data do ped programado como ref. para cálculo do prazo médio
       If _nTotalTp9 > 0 .and. SC5->( FieldPos( "C5_PEDPROG" ) ) > 0
          If !Empty( M->C5_PEDPROG )
             _dDiaFat := M->C5_PEDPROG //Considerar dia do Faturamento data do pedido programado para o caso de datas fixas de vencimento (Chamado 014805)
          Endif
       Endif

       For _nI := 1 to Len( _aVenctos )
           aAdd( _aPrazos, { _aVenctos[_nI][1] - _dDiaFat + 1, Iif( _nTotalTp9 > 0, _aVenctos[_nI][2] / _nTotalTp9, 1 / Len( _aVenctos ) ) } )
           _nPrzMedio += _aPrazos[_nI][1]
       Next
       If Len( _aVenctos ) > 0
          _nPrzMedio := _nPrzMedio / Len( _aVenctos )
       Endif
Return

/*/{Protheus.doc} fEhAvista
Função p/ Brasilux que verifica se cond. for menor que 7 dias então considera cond à vista (001)
@type function
@version  v.2022.05.27
@author Cleber Orati Domingues
@since 27/05/2022
@param _cCond, Character, Código da condição de pagamento que será verificado
@return Character, Retorna o código da condição de pagamento
/*/
Static Function fEhAvista( _cCond )
       Local _aArea := GetArea()
       Local _cRet  := _cCond

       DbSelectArea("SE4")  // Condição de Pagamento
       SE4->( DbSetOrder(1) )
       If SE4->( DbSeek( xFilial("SE4") + _cCond ) )
          //Cleber(24/07/18) Solicitação Eliana, chamado 010813 -> pedidos com cond. pgto até 7 dias calcular comissão como se fosse à vista
          If SE4->E4_TIPO = "1" .AND. Len( ( Alltrim( SE4->E4_COND ) ) ) == 1
             If Val( Alltrim( SE4->E4_COND ) ) <= 7
                _cRet := "001"
             Endif
          Endif
       Endif 
       RestArea( _aArea )
Return _cRet

/*/{Protheus.doc} fValAtrib
Retorna o tipo da variável
@type function
@version v.2022.05.27
@author Luís Gustavo Souza
@since 27/05/2022
@param _xAtributo, Character, Atributo a ser verificado
@return Character, Retorna o tipo do atributo
/*/
Static Function fValAtrib( _xAtributo )
Return ( Type( _xAtributo ) )

/*/{Protheus.doc} fDetEst
Determina o armazem de onde o item do pedido de vendas irá ser faturado
@type function
@version v2022.05.30
@author Luis Gustavo Souza
@since 30/05/2022
@param _cFilial, Character, Filial corrente do pedido de vendas
@param _cDeposito, Character, Indica se o pedido irá sair do depoosito SP ou não
@param _nPosLOCAL, Numeric, Posição (Coluna) do acols no qual está o campo do Local
@param _nX, Numeric, Posição linha que está sendo lida na chamada da função
@return Character, Retorna o armazem do item
/*/

//Manutenção Andre Maester 16/01/2025
Static Function fDetEst( _cFilial, _cDeposito, _nPosLOCAL, _nX )
       Local _cAuxLoc  := ''
       Local _CFornece := GETMV( "ZP_PAR0227" ) // LISTA CODIGOS DE FORNECEDORES QUE ALOCARÃO ALMOXARIFADOS DISTINTOS
       Local _cCliente := GETMV( "ZP_PAR0228" ) // LISTA CODIGOS DE CLIENTES QUE ALOCARÃO ALMOXARIFADOS DISTINTOS

       Do Case
          Case _cFilial == "010106" //Depósito Guarulhos
               //_cAuxLoc := "G3"
               Do Case
                  Case SB1->B1_TIPO == "MP"
                       _cAuxLoc := "G1"
                  Case SB1->B1_TIPO == "PI"
                       _cAuxLoc := "G2"
                  Case SB1->B1_TIPO == "PA"
                       _cAuxLoc := "G3"
                  Case SB1->B1_TIPO $ "MC.EP"
                       _cAuxLoc := "G4"
               EndCase
          Case _cFilial == "010107" //Depósito Matão
               _cAuxLoc := "M1"
               /*
               Do Case
                  Case SB1->B1_TIPO == "MP"
                       _cAuxLoc := "M1"
                  Case SB1->B1_TIPO == "PI"
                       _cAuxLoc := "M2"
                  Case SB1->B1_TIPO == "PA"
                       _cAuxLoc := "M3"
                  Case SB1->B1_TIPO == "MC"
                       _cAuxLoc := "M4"
               EndCase
               */
          Case _cFilial == "010108" //Depósito Ararquara
               _cAuxLoc := "A3"
          Case _cFilial == "010101" //Brasilux/Matriz -> Se for operação com Depósito atualizar almoxarifado.
               If !aCols[_nX][_nPosLOCAL] $ "90.98"
                  /*
                  Do Case
                     Case SB1->B1_TIPO == "MP"
                          _cAuxLoc := Iif( _cDeposito == "S", "G1", "01" )
                     Case SB1->B1_TIPO == "PI"
                          _cAuxLoc := Iif( _cDeposito == "S", "G2", "02" )
                     Case SB1->B1_TIPO == "PA"
                          _cAuxLoc := Iif( _cDeposito == "S", "G3", "03" )
                     OtherWise
                          _cAuxLoc := Iif( _cDeposito == "S" .AND. SubStr( aCols[_nX][_nPosLOCAL], 1, 1 ) == "0", "G" + SubStr( aCols[_nX][_nPosLOCAL], 2, 1 ), aCols[_nX][_nPosLOCAL] )
                  EndCase
                  */
                  If (M->C5_TIPO $ 'D.B' .AND. M->C5_CLIENTE $ _CFornece) .OR. (!M->C5_TIPO $ 'D.B' .AND. M->C5_CLIENTE $ _cCliente) 
                     //M->C5_TIPLIB := '2' //Garantir que seja liberado por pedido e não por item
                     Do Case
                        Case SB1->B1_TIPO == "MP"
                          _cAuxLoc := '01'
                        Case SB1->B1_TIPO == "PI"
                           _cAuxLoc := '02'
                        Case SB1->B1_TIPO == "PA"
                           _cAuxLoc := '03'
                        Case SB1->B1_TIPO $ "MC.EP"
                           _cAuxLoc := '04'
                        OtherWise
                           _cAuxLoc := aCols[_nX][_nPosLOCAL]
                     EndCase
                  Else
                     If _cDeposito ='S' //.AND. M->C5_TABELA ='GRU'
                           _cAuxLoc := 'G3'
                     //Elseif _cDeposito ='S' //.AND. M->C5_TABELA  <>'GRU'
                        //_cAuxLoc := 'G3'  ANDRE EM 15-01-24
                        //  _cAuxLoc := 'M3'
                     Elseif _cDeposito ='A'
                        _cAuxLoc := 'A3'
                     Elseif (_cDeposito ='' .OR. _cDeposito ='N')
                        //_cAuxLoc := 'M3'
                        _cAuxLoc := '03'
                     Endif
                  Endif
               Else
                  _cAuxLoc := aCols[_nX][_nPosLOCAL]
               Endif
          Case _cFilial == "060101" //Dissoltex -> Permitir Inclusão de Pedidos de devolução de material de terceiros ALMO TE
               //M->C5_TIPLIB := '1'
               If !aCols[_nX][_nPosLOCAL] $ "TE.90.98"
                  Do Case
                     Case SB1->B1_TIPO == "MP"
                          _cAuxLoc := "01"
                     Case SB1->B1_TIPO == "PI"
                          _cAuxLoc := "02"
                     Case SB1->B1_TIPO == "PA"
                          _cAuxLoc := "03"
                     Case SB1->B1_TIPO $ "MC.EP"
                          _cAuxLoc := "04"
                     OtherWise
                          _cAuxLoc := aCols[_nX][_nPosLOCAL]
                  EndCase
               Else
                  _cAuxLoc := aCols[_nX][_nPosLOCAL]
               Endif
          OtherWise
               Do Case
                  Case SB1->B1_TIPO == "MP"
                       _cAuxLoc := "01"
                  Case SB1->B1_TIPO == "PI"
                       _cAuxLoc := "02"
                  Case SB1->B1_TIPO == "PA"
                       _cAuxLoc := "03"
                  Case SB1->B1_TIPO $ "MC.EP"
                       _cAuxLoc := "04"
                  OtherWise
                       _cAuxLoc := aCols[_nX][_nPosLOCAL]
               EndCase
       EndCase
Return _cAuxLoc

/*/{Protheus.doc} fPolComBra
Carrega a faixa de descontos e calcula os valores 
@type function
@version  v.2022.06
@author Luis Gustavo Souza
@since 07/07/2022
@param nValorTab, numeric, Valor total do preço de tabela
@param nPercIcm, numeric, Percentual de icms para determinação da politica
@param lIcmsIpi, logical, Parametro que determina não contribuinte - não usado mais, mantido para compatibilidade
@param cCondPgto, character, Condição de pagamento para aplicação de adicional de desconto
@return numeric, Retorna o array com o valor minimo para verificação do desconto
/*/
User Function fPolComBra( nValorTab, nPercIcm, lIcmsIpi, cCondPgto, _cFilial )
     Local _nZPPAR39  := 1 - GETMV( "ZP_PAR0039" ) // Parametro do Percentual de desconto adicional para pagamento a vista - POLITICA COMERCIAL BRASILUX
     Local _aFaixa    := {}
     Local _nX, _nY
     Local _aNewPreco := {}
     Local _dZPPAR84  := GETMV( "ZP_PAR0084" ) // Data Inicial considerada para acrescimo de desconto e comissão - CONVENÇÃO COMERCIAL 2023
     Local _dZPPAR93  := GETMV( "ZP_PAR0093" ) // Data Final para acrescimo de desconto e comissão - CONVENÇÃO COMERCIAL 2023
     Local _cZPPAR85  := GETMV( "ZP_PAR0085" ) // Empresas/Filiais consideradas para acrescimo de desconto e comissão - CONVENÇÃO COMERCIAL 2023
     Local _nZPPAR86  := 1 - GETMV( "ZP_PAR0086" ) // Percentual de acrescimo para politica de desconto - CONVENÇÃO COMERCIAL 2023

     Do Case
        Case nPercIcm <= 7
             aAdd( _aFaixa, { 1,  1500.00,   5000.00, 20, 23, 26, 29, 32 } )
             aAdd( _aFaixa, { 1,  5000.01,  11000.00, 23, 26, 29, 32, 35 } )
             aAdd( _aFaixa, { 1, 11000.01,  17000.00, 26, 29, 32, 35, 38 } )
             aAdd( _aFaixa, { 1, 17000.01, 99999999.99, 29, 32, 35, 38, 40 } )
        Case nPercIcm <= 12
             aAdd( _aFaixa, { 2,  1500.00,   5000.00, 12, 15, 18, 21, 24 } )
             aAdd( _aFaixa, { 2,  5000.01,  11000.00, 15, 18, 21, 24, 27 } )
             aAdd( _aFaixa, { 2, 11000.01,  17000.00, 18, 21, 24, 27, 30 } )
             aAdd( _aFaixa, { 2, 17000.01, 99999999.99, 21, 24, 27, 30, 33 } )
        OtherWise
             aAdd( _aFaixa, { 3,  1500.00,   5000.00,  8, 12, 16, 20, 24 } )
             aAdd( _aFaixa, { 3,  5000.01,  11000.00, 10, 14, 18, 22, 26 } )
             aAdd( _aFaixa, { 3, 11000.01,  17000.00, 12, 16, 20, 24, 28 } )
             aAdd( _aFaixa, { 3, 17000.01, 99999999.99, 14, 18, 22, 26, 30 } )
     EndCase
     If cCondPgto == "001" //Desconto adicional ZP_PAR0039
        For _nX := 1 To Len( _aFaixa )
            For _nY := 4 To 8
                _aFaixa[_nX][ _nY] := 100 * ( 1 - ( _nZPPAR39 * ( 1 - ( _aFaixa[_nX][ _nY] / 100 ) ) ) )
            Next
        Next
     Endif
     /****************************************************************************************************************************/
     //Desconto adicional de 5% - Campanha Convenção 2023 - Linha pó
     If (M->C5_EMISSAO >= _dZPPAR84) .and. (M->C5_EMISSAO <= _dZPPAR93)  //Pedidos com entrada na data da CONVENÇÃO
        If _cFilial $ Alltrim( _cZPPAR85 ) //Filial valida para CONVENÇÃO
           For _nX := 1 To Len( _aFaixa )
               For _nY := 4 To 8
                   _aFaixa[_nX][ _nY] := 100 * ( 1 - ( _nZPPAR86 * ( 1 - ( _aFaixa[_nX][ _nY] / 100 ) ) ) )
               Next
           Next
        Endif
     Endif
     /****************************************************************************************************************************/
     For _nX := 1 To Len( _aFaixa )
         aAdd( _aNewPreco, { _aFaixa[_nX][1], _aFaixa[_nX][2], _aFaixa[_nX][3], 0, 0, 0, 0, 0 } )
         For _nY := 4 To 8
             _aNewPreco[_nX][_nY] := nValorTab * ( 1 - ( _aFaixa[_nX][_nY] / 100 ) )
         Next
     Next
Return( _aNewPreco )

/*/{Protheus.doc} fCarrDesc
Carrega os percentuais de desconto da politica comercial brasilux
@type function
@version  v.2022.06
@author gustavosouza
@since 07/07/2022
@param nPercIcm, numeric, Percentual de icms para determinação da politica
@param lIcmsIpi, logical, Parametro que determina não contribuinte - não usado mais, mantido para compatibilidade
@param cCondPgto, character, Condição de pagamento para aplicação de adicional de desconto
@return numeric, Retorna o array com o valor minimo para verificação do desconto
/*/
Static Function fCarrDesc( nPercIcm, lIcmsIpi, cCondPgto, _cFilial )
       Local _aFaixaDes := {}
       Local _nX, _nY
       Local _nZPPAR39  := 1 - GETMV( "ZP_PAR0039" ) //LGS#20220201 - Parametro do Percentual de desconto adicional para pagamento a vista - POLITICA COMERCIAL BRASILUX
       Local _dZPPAR84  := GETMV( "ZP_PAR0084" ) //LGS#20230324 - Data considerada para acrescimo de desconto e comissão - CONVENÇÃO COMERCIAL 2023
       Local _dZPPAR93  := GETMV( "ZP_PAR0093" ) // Data Final para acrescimo de desconto e comissão - CONVENÇÃO COMERCIAL 2023
       Local _cZPPAR85  := GETMV( "ZP_PAR0085" ) //LGS#20230324 - Empresas/Filiais consideradas para acrescimo de desconto e comissão - CONVENÇÃO COMERCIAL 2023
       Local _nZPPAR86  := 1 - GETMV( "ZP_PAR0086" ) //LGS#20230324 - Percentual de acrescimo para politica de desconto - CONVENÇÃO COMERCIAL 2023
       Do Case
          Case nPercIcm <= 7
               aAdd( _aFaixaDes, { 1,  1500.00,   5000.00, 20, 23, 26, 29, 32 } )
               aAdd( _aFaixaDes, { 1,  5000.01,  11000.00, 23, 26, 29, 32, 35 } )
               aAdd( _aFaixaDes, { 1, 11000.01,  17000.00, 26, 29, 32, 35, 38 } )
               aAdd( _aFaixaDes, { 1, 17000.01, 99999999.99, 29, 32, 35, 38, 40 } )
          Case nPercIcm <= 12
               aAdd( _aFaixaDes, { 2,  1500.00,   5000.00, 12, 15, 18, 21, 24 } )
               aAdd( _aFaixaDes, { 2,  5000.01,  11000.00, 15, 18, 21, 24, 27 } )
               aAdd( _aFaixaDes, { 2, 11000.01,  17000.00, 18, 21, 24, 27, 30 } )
               aAdd( _aFaixaDes, { 2, 17000.01, 99999999.99, 21, 24, 27, 30, 33 } )
          OtherWise
               aAdd( _aFaixaDes, { 3,  1500.00,   5000.00,  8, 12, 16, 20, 24 } )
               aAdd( _aFaixaDes, { 3,  5000.01,  11000.00, 10, 14, 18, 22, 26 } )
               aAdd( _aFaixaDes, { 3, 11000.01,  17000.00, 12, 16, 20, 24, 28 } )
               aAdd( _aFaixaDes, { 3, 17000.01, 99999999.99, 14, 18, 22, 26, 30 } )
       EndCase
       If cCondPgto == "001" //Desconto adicional ZP_PAR0039
          For _nX := 1 To Len( _aFaixaDes )
              For _nY := 4 To 8
                  _aFaixaDes[_nX][ _nY] := 100 * ( 1 - ( _nZPPAR39 * ( 1 - ( _aFaixaDes[_nX][ _nY] / 100 ) ) ) )
              Next
          Next
       Endif
       /****************************************************************************************************************************/
       //Desconto adicional de 5% - Campanha Convenção 2023 - Linha pó
       If (M->C5_EMISSAO >= _dZPPAR84) .and. (M->C5_EMISSAO <= _dZPPAR93) //Pedidos com entrada na data da campanha
          If _cFilial $ Alltrim( _cZPPAR85 )
             For _nX := 1 To Len( _aFaixaDes )
                 For _nY := 4 To 8
                     _aFaixaDes[_nX][ _nY] := 100 * ( 1 - ( _nZPPAR86 * ( 1 - ( _aFaixaDes[_nX][ _nY] / 100 ) ) ) )
                 Next
             Next
          Endif
       Endif
       /****************************************************************************************************************************/
Return _aFaixaDes
