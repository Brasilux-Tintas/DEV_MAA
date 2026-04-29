#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} ZGATFG02
Novo programa para gatilho de preenchimento de informações dos itens de pedidos de vendas
@type function
@version  v2023.001
@author Luís Gustavo de Souza
@since 31/01/2023
@param _nOpc, variant, Opção para tratamento da chamada do gatilho
@return variant, Retorna o valor para gatilho
/*/
User Function ZFATG02( _nOpc )
     Local _nRet     := 0
     Local _nPosPrd  := aScan( aHeader, { |x| Alltrim( x[2] ) == 'C6_PRODUTO' } )
     Local _nPosTES  := aScan( aHeader, { |x| Alltrim( x[2] ) == 'C6_TES'     } )
     Local _nPosQtd  := aScan( aHeader, { |x| Alltrim( x[2] ) == 'C6_QTDVEN'  } )
     Local _nPosPrc  := aScan( aHeader, { |x| Alltrim( x[2] ) == 'C6_PRCVEN'  } )
     Local _nPosDes  := aScan( aHeader, { |x| Alltrim( x[2] ) == 'C6_VALDESC' } )
     Local _nPosNFO  := aScan( aHeader, { |x| Alltrim( x[2] ) == 'C6_NFORI'   } )
     Local _nPosSEO  := aScan( aHeader, { |x| Alltrim( x[2] ) == 'C6_SERIORI' } )
     Local _nPosVlr  := aScan( aHeader, { |x| Alltrim( x[2] ) == 'C6_VALOR'   } )
     Local _nPosFCI  := aScan( aHeader, { |x| AllTrim( x[2] ) == "C6_FCICOD"  } )
     Local _nPosCFS  := aScan( aHeader, { |x| AllTrim( x[2] ) == "C6_CLASFIS" } )

     //Dados do Cabeçalho
     MaFisIni( M->C5_CLIENTE                        ,; // 01 - Codigo Cliente/Fornecedor
               M->C5_LOJACLI                        ,; // 02 - Loja do Cliente/Fornecedor
               Iif( M->C5_TIPO $ "D;B", "F", "C" )  ,; // 03 - C:Cliente , F:Fornecedor
               M->C5_TIPO                           ,; // 04 - Tipo da NF
               M->C5_TIPOCLI                        ,; // 05 - Tipo do Cliente/Fornecedor
               MaFisRelImp( "MT100", {"SF2", "SD2"}),; // 06 - Relacao de Impostos que suportados no arquivo
                                                    ,; // 07 - Tipo de complemento
                                                    ,; // 08 - Permite Incluir Impostos no Rodape .T./.F.
               "SB1"                                ,; // 09 - Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
               "MATA461"                             ) // 10 - Nome da rotina que esta utilizando a funcao
     //Adiciona o item nos tratamentos de impostos
     DbSelectArea('SB1')
     SB1->( DbSetOrder(1) )
     SB1->( DbSeek( FWxFilial("SB1") + aCols[n][_nPosPrd] ) )
     MaFisAdd( aCols[n][_nPosPrd],;    // 01 - Codigo do Produto                    ( Obrigatorio )
               aCols[n][_nPosTES],;    // 02 - Codigo do TES                        ( Opcional )
               aCols[n][_nPosQtd],;    // 03 - Quantidade                           ( Obrigatorio )
               aCols[n][_nPosPrc],;    // 04 - Preco Unitario                       ( Obrigatorio )
               aCols[n][_nPosDes],;    // 05 - Desconto
               aCols[n][_nPosNFO],;    // 06 - Numero da NF Original                ( Devolucao/Benef )
               aCols[n][_nPosSEO],;    // 07 - Serie da NF Original                 ( Devolucao/Benef )
                                0,;    // 08 - RecNo da NF Original no arq SD1/SD2
                                0,;    // 09 - Valor do Frete do Item               ( Opcional )
                                0,;    // 10 - Valor da Despesa do item             ( Opcional )
                                0,;    // 11 - Valor do Seguro do item              ( Opcional )
                                0,;    // 12 - Valor do Frete Autonomo              ( Opcional )
               aCols[n][_nPosVlr],;           // 13 - Valor da Mercadoria                  ( Obrigatorio )
                                0,;    // 14 - Valor da Embalagem                   ( Opcional )
               SB1->(RecNo())    ,;    // 15 - RecNo do SB1
                                0 )    // 16 - RecNo do SF4
       
     MaFisLoad( "IT_VALMERC", aCols[n][_nPosVlr], n )
     MaFisLoad( "IT_ALIQIPI", SB1->B1_IPI       , n )               
     If _nOpc == 1 //ICMS
        _cClF   := MaFisRet( n, 'IT_CLASFIS' )
        If Len( Alltrim(_cClF) ) == 2 .and. Len( AllTrim( aCols[n][_nPosFCI] ) ) > 0
           MaFisAlt( 'IT_CLASFIS', aCols[n][_nPosCFS], n, .T. )
        Endif
        _nRet   := MaFisRet( n, 'IT_ALIQICM' )
     ElseIf _nOpc == 2 //IPI
            _nRet   := MaFisRet( n, 'IT_ALIQIPI' )
     ElseIf _nOpc == 3 //PIS
            _nRet   := MaFisRet( n, 'IT_ALIQPIS' )
     ElseIf _nOpc == 4 //COFINS
            _nRet   := MaFisRet( n, 'IT_ALIQCOF' )
     Endif
Return _nRet
