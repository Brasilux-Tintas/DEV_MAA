#Include 'TOTVS.ch'

/*/{Protheus.doc} PCPADDTAGS
//TODO Complementa informações do XML para integração com o PCFactory.
//30/09/2019 - Adequação a release 12.1.25
@author Luis Gustavo Souza
@since 01/01/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function PCPADDTAGS()
     Local _cAddXml  := ""
     Local _cTransac := PARAMIXB[1] // Transação que está sendo trafegada. Ex: Item.
     Local _cEvent   := PARAMIXB[2] // Evento da transação. upsert/delete.
     Local _cPont    := PARAMIXB[3] // Ponteiro para recuperar as informações da transação. Ex: &( _cPont+"B1_COD" ) -> retorna o código do produto.
     Local _nPesLiq  := 0 
     Local _nPesBru  := 0
     //Local _aPesoProd:= {}
     Local _aAuxZZA  := {}

     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        If UPPER( AllTrim( _cTransac ) ) == "ITEM" //Trafegando a mensagem de Produtos.
           If UPPER( AllTrim( _cEvent ) ) == "UPSERT" //Atualizando ou Incluindo um produto.
              /*As informações devem ser inseridas em um formato válido para arquivos XML.
                Por exemplo: <TagXml>informação</TagXml>.
                Não deve ser utilizado nenhuma Tag do XML padrão Totvs para inserir novas informações.*/
              //Quantidade de Volume
              _cAddXml := "<EMBALQTD>" + &( _cPont+"B1_RELCAT2" ) + "</EMBALQTD>"
              //Produto de Sobra somente PI
              If &( _cPont+"B1_TIPO" ) == 'PI'
                 DbSelectArea( "SZ1" )
                 SZ1->( DbSetOrder( 1 ) )
                 If SZ1->( DbSeek( xFilial( "SZ1" ) + SubStr( &( _cPont+"B1_COD" ), 4, 2 ) ) )
                    _cAddXml := "<SubIdProduct>" + SZ1->Z1_REAPROV  + "</SubIdProduct>"
                 Endif
              Endif
              //_cAddXml := "<PackingQuantity>" + &( _cPont+"B1_RELCAT2" ) + "</PackingQuantity>"
           Endif
        ElseIf UPPER( AllTrim( _cTransac ) ) == "ITEMSCRIPT" //Trafegando a mensagem de Roteiros de operações.
               If UPPER( AllTrim( _cEvent ) ) == "UPSERT" //Atualizando ou Incluindo um Roteiro de operações.
                  /*As informações devem ser inseridas em um formato válido para arquivos XML.
                    Por exemplo: <TagXml>informação</TagXml>.
                    Não deve ser utilizado nenhuma Tag do XML padrão Totvs para inserir novas informações.*/
               Endif
        ElseIf UPPER( AllTrim( _cTransac ) ) == "PRODUCTIONORDER" //Trafegando a mensagem de Ordem de Produção.
               If UPPER( AllTrim( _cEvent ) ) == "UPSERT" //Atualizando ou Incluindo uma Ordem de Produção.
                  If FWIsInCallStack( 'FFIMLABPRO' ) .or. FWIsInCallStack( 'FINTEGPCF' ) .or. FWIsInCallStack( 'U_ZPCPA02I' ) //Chamada somente no apontamento de produção do laboratorio.
                     DbSelectArea("SB1")
                     SB1->( DbSetOrder( 1 ) )
                     SB1->( DbSeek( xFilial("SB1") + SC2->C2_PRODUTO ) )
                     If FWIsInCallStack( 'fIntegPAs' ) //PARA OS PAs
                        //Modificada chamada para calcular o pesos liquido/bruto no apontamento - devido a erros encontrados nos pesos após alteração de MP que modifica P.E. do PI
                        _nPesLiq := _aPesoProd[1] //ROUND( ROUND( SB1->B1_PESO / SB1->B1_PESOESP, 3 ) * ZZA->ZZA_PESLAB, 4 ) //Ajusto o peso liquido pelo peso especifico apurado no laboratorio
                        _nPesBru := _aPesoProd[2] //ROUND( ( SB1->B1_PESBRU - SB1->B1_PESO ) + _nPesLiq                , 4 ) //Ajusto o peso bruto pelo novo peso liquido. 
                        _cAddXml := "<PESOLIQUIDOREAL>" + cValToChar( _nPesLiq ) + "</PESOLIQUIDOREAL>"
                        _cAddXml += "<PESOBRUTOREAL>"   + cValToChar( _nPesBru ) + "</PESOBRUTOREAL>"
                        _cAddXml += "<PESOESPECIFICO>"   + cValToChar(ZZA->ZZA_PESESP) + "</PESOESPECIFICO>"
                        _cAddXml += "<PESOESPLAB>"   + cValToChar(ZZA->ZZA_PESLAB) + "</PESOESPLAB>"
                     Else
                        _cAddXml := "<PESOMP>" + cValToChar(ZZA->ZZA_PESFIN) + "</PESOMP>"
                        _cAddXml += "<TARAMP>"   + cValToChar(ZZA->ZZA_TARA) + "</TARAMP>"
                        _cAddXml += "<PESOESPECIFICO>"   + cValToChar(ZZA->ZZA_PESESP) + "</PESOESPECIFICO>"
                        _cAddXml += "<PESOESPLAB>"   + cValToChar(ZZA->ZZA_PESLAB) + "</PESOESPLAB>"
                     Endif
                  else
                     //Esse bloco foi criado para suprir o tratamento de envio de informações para ordem de produção complementares
                     //as funções abaixo chamadas são cópias das funções do apontamento de produção BRPCPA08 (antigo) / ZPCPA01 (novo)
                     //e futuramente deve ser estudada um forma de deixar uma única função no sistema.
                     _aPesoProd := {}
                     DbSelectArea("SB1") //Verifico se produto é um PA
                     SB1->( DbSetorder( 1 ) )
                     If SB1->( DbSeek( xFilial ("SB1") + SC2->C2_PRODUTO ) )
                        If SB1->B1_TIPO == 'PA'
                           DbSelectArea("ZZA")      //Procuro os apontamentos do PI por lote devido ao apontamento atual não ser por operação
                           ZZA->( DbSetOrder( 3 ) ) //dificulta saber o ultimo apontamento.
                           If ZZA->( DbSeek( FwxFilial("ZZA") + SC2->C2_LOTE ) ) //Se não encontrar lote significa que não existem apontamentos ainda.
                              While !Eof() .and. ZZA->ZZA_LOTE == SC2->C2_LOTE
                                    If SubStr( ZZA->ZZA_PRODUTO, 11, 2 ) $ '00.99'
                                       aAdd( _aAuxZZA, { ZZA->ZZA_ORDEM, ZZA->ZZA_OPERAC, ZZA->ZZA_LOTE, ZZA->ZZA_PRODUTO, ZZA->ZZA_PESESP, ZZA->ZZA_PESLAB, Recno() } )
                                    Endif
                                    DbSelectArea( "ZZA" )
                                    ZZA->( DbSkip() )
                              EndDo
                              //Ordeno array com registro(s) ZZA - e pego o ultimo item se existir - senão significa que não existem apontamentos
                              If Len( _aAuxZZA ) > 0
                                 aSort( _aAuxZZA, , , { |x, y| x[7] < y[7] } )
                                 DbSelectArea( "ZZA" )
                                 ZZA->( DbGoTo( _aAuxZZA[ Len( _aAuxZZA ) ][ 7 ] ) ) //Posiciono no registro ZZA do ultimo apontamento do PI

                                 _aPesoProd := fPesoPA()

                                 _nPesLiq := _aPesoProd[1]
                                 _nPesBru := _aPesoProd[2]
                                 _cAddXml := "<PESOLIQUIDOREAL>" + cValToChar( _nPesLiq ) + "</PESOLIQUIDOREAL>"
                                 _cAddXml += "<PESOBRUTOREAL>"   + cValToChar( _nPesBru ) + "</PESOBRUTOREAL>"
                                 _cAddXml += "<PESOESPECIFICO>"   + cValToChar(ZZA->ZZA_PESESP) + "</PESOESPECIFICO>"
                                 _cAddXml += "<PESOESPLAB>"   + cValToChar(ZZA->ZZA_PESLAB) + "</PESOESPLAB>"
                              Endif
                           Endif
                        Endif
                     Endif
                  Endif
               Endif
        Endif
     Endif
Return _cAddXml

Static Function fPesoPA()
       Local _nPesoLiqu := 0
       Local _nPesoBrut := 0
       Local _aCompProd := {}
       Local _nX        := 0

       DbSelectArea("SG1")
       SG1->( DbSetOrder( 1 ) )
       If SG1->( DbSeek( xFilial("SG1") + SB1->B1_COD) )
          While !Eof() .and. SG1->G1_COD == SB1->B1_COD
               // produto de custeio
               If U_IsProdCusto(SG1->G1_COMP)
                  SG1->(dbSkip())
                  Loop
               Endif   

                //                  COMPONENTE    QUANTIDADE     UNIDADE  TIPO  PESO  TOTAL
                aAdd( _aCompProd, { SG1->G1_COMP, SG1->G1_QUANT, ''     , ''  , 0   , 0    } )
                DbSelectArea("SG1")
                SG1->( DbSkip( ) )
          EndDo
       Endif
       //Calcula Peso Por item da fórmula
       For _nX := 1 To Len( _aCompProd )
           DbSelectArea( "SB1" )
           SB1->( DbSetorder( 1 ) )
           If SB1->( DbSeek( xFilial( "SB1" ) + _aCompProd[_nX][1] ) )
              _aCompProd[ _nX ][3] := SB1->B1_UM
              _aCompProd[ _nX ][4] := SB1->B1_TIPO
              _aCompProd[ _nX ][5] := SB1->B1_PESO //Peso Liquido do Produto
              If SB1->B1_TIPO == 'PI'
                 _aCompProd[ _nX ][6] := Round( Iif( SB1->B1_UM $ 'KG.K ', _aCompProd[ _nX ][2], _aCompProd[ _nX ][2] * ZZA->ZZA_PESLAB ), 3 )
                 _nPesoLiqu += Round( _aCompProd[ _nX ][6], 3 )
                 _nPesoBrut += Round( _aCompProd[ _nX ][6], 3 )
              Else
                 _aCompProd[ _nX ][6] := Round( _aCompProd[ _nX ][2] * _aCompProd[ _nX ][5], 3 )
                 _nPesoBrut += Round( _aCompProd[ _nX ][6], 3 )
              Endif
           Endif
       Next
Return { _nPesoLiqu, _nPesoBrut }
