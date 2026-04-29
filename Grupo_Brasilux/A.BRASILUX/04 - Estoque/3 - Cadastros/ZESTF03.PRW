#include 'totvs.ch'
#include 'protheus.ch'
#include 'FWMVCDef.ch'

/*/{Protheus.doc} ZESTF03
Visualização de códigos de barras EAN13/GTIN e DUN14/GTIN14
@type function
@version  v2023.01
@author Luís Gustavo de Souza
@since 20/03/2023
/*/
User Function ZESTF03()
     Local   _oBrowse  := Nil
     Local   _oProcess := Nil
     Private _aRotina  := MenuDef()
     
     //Validar informações cadastradas antes de acessar o Browse.
     _oProcess := MsNewProcess():New( { || fVerSeqCd( _oProcess )  }, "VERIFICANDO - Esse processo pode ser demorado...", "Aguarde...", .T. )
     _oProcess:Activate()
     //fValidDad( _oProcess )
     _oProcess := MsNewProcess():New( { || fValidDad( _oProcess ) }, "Validando - Esse processo pode ser demorado...", "Aguarde...", .T. )
     _oProcess:Activate()
     
     DbSelectArea( "ZA1" )
     _oBrowse := FWMBrowse():New()
     _oBrowse:SetAlias("ZA1")//Seleciona o Alias que estamos trabalhando.
     _oBrowse:SetDescription( "Cadastro de Código de Barras" )// "Descrição"
 
     // Remove os botões de navegação na edição ou visualização do model
     _oBrowse:SetUseCursor(.F.)
     _oBrowse:Activate()
Return

Static Function MenuDef()
       Local _aRotina := {}
       ADD OPTION _aRotina TITLE "Pesquisar"    ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 //"Pesquisar"
       ADD OPTION _aRotina TITLE "Visualizar"   ACTION 'VIEWDEF.ZESTF03' OPERATION 2 ACCESS 0 //"Visualizar"
       ADD OPTION _aRotina TITLE "Alterar"      ACTION 'VIEWDEF.ZESTF03' OPERATION 4 ACCESS 0 //"Alterar"
       ADD OPTION _aRotina TITLE "Importar CNP" ACTION 'U_ESTF03_CNP()'  OPERATION 6 ACCESS 0 //"Gerar arquivo de importação CNP"
 Return _aRotina

User Function ESTF03_CNP()
     Processa( { || fExpGTIN() }, "Exportando dados para inclusão GTIN..." )
Return

Static Function fExpGTIN()
       Local _oFwXlsx := ""
       ProcRegua( 30000 )

       If __FWLibVersion() >= '20201009' .And. GetRpoRelease() >= '12.1.023' .And. PrinterVersion():fromServer() >= '2.1.0'
          _oFwXlsx := FwMsExcelXlsx():New()
       Else
          _oFwXlsx := FWMsExcelEx():New()
       Endif

       //_oFwXlsx:SetWriteinFile( .T. )
       If Alltrim( xFilial('ZA1'))  <> '11'
          _oFwXlsx:AddworkSheet( "GTIN13" )
          _oFwXlsx:AddTable ( "GTIN13", "Table1" )
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Status GTIN"                                              , 1, 1, .F., ""       ) //  1*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "GTIN"                                                     , 1, 1, .F., ""       ) //  2*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Descrição"                                                , 1, 1, .F., ""       ) //  3*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Idioma da Descrição"                                      , 1, 1, .F., ""       ) //  4*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "GTIN Origem"                                              , 1, 1, .F., ""       ) //  5
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Quantidade de itens na caixa"                             , 1, 1, .F., ""       ) //  6
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "GTIN contido"                                             , 1, 1, .F., ""       ) //  7
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Quantidade do GTIN contido"                               , 1, 1, .F., ""       ) //  8
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Tipo da imagem"                                           , 1, 1, .F., ""       ) //  9*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Link da URL"                                              , 1, 1, .F., ""       ) // 10*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Descrição da imagem"                                      , 1, 1, .F., ""       ) // 11*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Idioma da imagem"                                         , 1, 1, .F., ""       ) // 12*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Permitir o compartilhamento de dados"                     , 1, 1, .F., ""       ) // 13*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Marca"                                                    , 1, 1, .F., ""       ) // 14*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Idioma da marca"                                          , 1, 1, .F., ""       ) // 15*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Tipo de codigo"                                           , 1, 1, .F., ""       ) // 16*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Codigo"                                                   , 1, 1, .F., ""       ) // 17*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Orgão Governamental"                                      , 1, 1, .F., ""       ) // 18
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Código do Registro"                                       , 1, 1, .F., ""       ) // 19
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Pais de Origem"                                           , 1, 1, .F., ""       ) // 20*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Estado de Origem"                                         , 1, 1, .F., ""       ) // 21
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Tipo de produto"                                          , 1, 1, .F., ""       ) // 22
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Tipo de embalagem"                                        , 1, 1, .F., ""       ) // 23
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Peso Bruto"                                               , 3, 2, .F., "999.99" ) // 24*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "UN Medida - Peso Bruto"                                   , 1, 1, .F., ""       ) // 25*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Peso Bruto(médio)"                                        , 1, 1, .F., ""       ) // 26
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Peso Bruto mínimo"                                        , 1, 1, .F., ""       ) // 27
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Peso Bruto máximo"                                        , 1, 1, .F., ""       ) // 28
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "UN Medida - pesos médio, mínimo e máximo"                 , 1, 1, .F., ""       ) // 29
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Peso Líquido"                                             , 3, 2, .F., "999.99" ) // 30*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "UN Medida - Peso Líq."                                    , 1, 1, .F., ""       ) // 31*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Conteúdo Líquido"                                         , 1, 1, .F., ""       ) // 32*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "UN Medida - Cont. Líquido"                                , 1, 1, .F., ""       ) // 33*
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Altura"                                                   , 1, 1, .F., ""       ) // 34
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "UN Medida - Altura"                                       , 1, 1, .F., ""       ) // 35
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Largura"                                                  , 1, 1, .F., ""       ) // 36
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "UN Medida - Largura"                                      , 1, 1, .F., ""       ) // 37
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Profundidade"                                             , 1, 1, .F., ""       ) // 38
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "UN Medida - Profundidade"                                 , 1, 1, .F., ""       ) // 39
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Tipo de Pallet"                                           , 1, 1, .F., ""       ) // 40
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Fator de Empilhamento"                                    , 1, 1, .F., ""       ) // 41
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Quantidade de Camadas por Pallet"                         , 1, 1, .F., ""       ) // 42
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Quantidade de Itens Comerciais em uma Única Camada"       , 1, 1, .F., ""       ) // 43
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Quantidade de Itens Comerciais em uma Camada Completa"    , 1, 1, .F., ""       ) // 44
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Quantidade de Camadas Completas em Item Comercial"        , 1, 1, .F., ""       ) // 45
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Tempo mínimo (dias) de vida útil do produto após produção", 1, 1, .F., ""       ) // 46
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Temperatura Mínima"                                       , 1, 1, .F., ""       ) // 47
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Temperatura Máxima"                                       , 1, 1, .F., ""       ) // 48
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "UN Medida - temperatura mínima e máxima"                  , 1, 1, .F., ""       ) // 49
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Indicador de Mercadorias Perigosas"                       , 1, 1, .F., ""       ) // 50
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "NCM"                                                      , 1, 1, .F., ""       ) // 51
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "TIPI"                                                     , 1, 1, .F., ""       ) // 52
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "CEST"                                                     , 1, 1, .F., ""       ) // 53
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Alíquota de Impostos IPI (%)"                             , 1, 1, .F., ""       ) // 54
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "GPC - Classificação Global de Produtos"                   , 1, 1, .F., ""       ) // 55
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Descrição de Porção ou Medida"                            , 1, 1, .F., ""       ) // 56
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Referência diária"                                        , 1, 1, .F., ""       ) // 57
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Item Nutricional"                                         , 1, 1, .F., ""       ) // 58
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Quantidade - Nutriente"                                   , 1, 1, .F., ""       ) // 59
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "UN Medida - Nutriente"                                    , 1, 1, .F., ""       ) // 60
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "% VD"                                                     , 1, 1, .F., ""       ) // 61
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Alérgeno"                                                 , 1, 1, .F., ""       ) // 62
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Presença do Alérgeno"                                     , 1, 1, .F., ""       ) // 63
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Observações"                                              , 1, 1, .F., ""       ) // 64
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Tipo do Site"                                             , 1, 1, .F., ""       ) // 65
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Link do site (URL)"                                       , 1, 1, .F., ""       ) // 66
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Nome do Site"                                             , 1, 1, .F., ""       ) // 67
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Data de lançamento para o mercado (DD/MM/AAAA)"           , 1, 1, .F., ""       ) // 68
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "País de destino"                                          , 1, 1, .F., ""       ) // 69
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Quantidade Mínima para Pedido"                            , 1, 1, .F., ""       ) // 70
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Unidade de Medida para Pedidos"                           , 1, 1, .F., ""       ) // 71
          _oFwXlsx:AddColumn( "GTIN13", "Table1", "Múltiplo da Quantidade para Pedido"                       , 1, 1, .F., ""       ) // 72
       Else
          _oFwXlsx:AddworkSheet( "GTIN14" )
          _oFwXlsx:AddTable ( "GTIN14", "Table1" )
          _oFwXlsx:AddColumn( "GTIN14", "Table1", "Status GTIN"                                              , 1, 1, .F., ""       ) //  1*
          _oFwXlsx:AddColumn( "GTIN14", "Table1", "GTIN"                                                     , 1, 1, .F., ""       ) //  2*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Descrição"                                                , 1, 1, .F., ""       ) //  3*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Idioma da Descrição"                                      , 1, 1, .F., ""       ) //  4*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "GTIN Origem"                                              , 1, 1, .F., ""       ) //  5
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Quantidade de itens na caixa"                             , 1, 1, .F., ""       ) //  6
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "GTIN contido"                                             , 1, 1, .F., ""       ) //  7
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Quantidade do GTIN contido"                               , 1, 1, .F., ""       ) //  8
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Tipo da imagem"                                           , 1, 1, .F., ""       ) //  9*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Link da URL"                                              , 1, 1, .F., ""       ) // 10*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Descrição da imagem"                                      , 1, 1, .F., ""       ) // 11*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Idioma da imagem"                                         , 1, 1, .F., ""       ) // 12*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Permitir o compartilhamento de dados"                     , 1, 1, .F., ""       ) // 13*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Marca"                                                    , 1, 1, .F., ""       ) // 14*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Idioma da marca"                                          , 1, 1, .F., ""       ) // 15*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Tipo de codigo"                                           , 1, 1, .F., ""       ) // 16*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Codigo"                                                   , 1, 1, .F., ""       ) // 17*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Orgão Governamental"                                      , 1, 1, .F., ""       ) // 18
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Código do Registro"                                       , 1, 1, .F., ""       ) // 19
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Pais de Origem"                                           , 1, 1, .F., ""       ) // 20*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Estado de Origem"                                         , 1, 1, .F., ""       ) // 21
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Tipo de produto"                                          , 1, 1, .F., ""       ) // 22
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Tipo de embalagem"                                        , 1, 1, .F., ""       ) // 23	   
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Peso Bruto"                                               , 3, 2, .F., "999.99" ) // 24*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "UN Medida - Peso Bruto"                                   , 1, 1, .F., ""       ) // 25*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Peso Bruto(médio)"                                        , 1, 1, .F., ""       ) // 26
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Peso Bruto mínimo"                                        , 1, 1, .F., ""       ) // 27
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Peso Bruto máximo"                                        , 1, 1, .F., ""       ) // 28
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "UN Medida - pesos médio, mínimo e máximo"                 , 1, 1, .F., ""       ) // 29
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Peso Líquido"                                             , 3, 2, .F., "999.99" ) // 30*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "UN Medida - Peso Líq."                                    , 1, 1, .F., ""       ) // 31*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Conteúdo Líquido"                                         , 1, 1, .F., ""       ) // 32*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "UN Medida - Cont. Líquido"                                , 1, 1, .F., ""       ) // 33*
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Altura"                                                   , 1, 1, .F., ""       ) // 34
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "UN Medida - Altura"                                       , 1, 1, .F., ""       ) // 35
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Largura"                                                  , 1, 1, .F., ""       ) // 36
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "UN Medida - Largura"                                      , 1, 1, .F., ""       ) // 37
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Profundidade"                                             , 1, 1, .F., ""       ) // 38
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "UN Medida - Profundidade"                                 , 1, 1, .F., ""       ) // 39
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Tipo de Pallet"                                           , 1, 1, .F., ""       ) // 40
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Fator de Empilhamento"                                    , 1, 1, .F., ""       ) // 41
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Quantidade de Camadas por Pallet"                         , 1, 1, .F., ""       ) // 42
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Quantidade de Itens Comerciais em uma Única Camada"       , 1, 1, .F., ""       ) // 43
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Quantidade de Itens Comerciais em uma Camada Completa"    , 1, 1, .F., ""       ) // 44
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Quantidade de Camadas Completas em Item Comercial"        , 1, 1, .F., ""       ) // 45
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Tempo mínimo (dias) de vida útil do produto após produção", 1, 1, .F., ""       ) // 46
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Temperatura Mínima"                                       , 1, 1, .F., ""       ) // 47
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Temperatura Máxima"                                       , 1, 1, .F., ""       ) // 48
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "UN Medida - temperatura mínima e máxima"                  , 1, 1, .F., ""       ) // 49
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Indicador de Mercadorias Perigosas"                       , 1, 1, .F., ""       ) // 50
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "NCM"                                                      , 1, 1, .F., ""       ) // 51
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "TIPI"                                                     , 1, 1, .F., ""       ) // 52
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "CEST"                                                     , 1, 1, .F., ""       ) // 53
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Alíquota de Impostos IPI (%)"                             , 1, 1, .F., ""       ) // 54
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "GPC - Classificação Global de Produtos"                   , 1, 1, .F., ""       ) // 55
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Descrição de Porção ou Medida"                            , 1, 1, .F., ""       ) // 56
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Referência diária"                                        , 1, 1, .F., ""       ) // 57
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Item Nutricional"                                         , 1, 1, .F., ""       ) // 58
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Quantidade - Nutriente"                                   , 1, 1, .F., ""       ) // 59
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "UN Medida - Nutriente"                                    , 1, 1, .F., ""       ) // 60
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "% VD"                                                     , 1, 1, .F., ""       ) // 61
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Alérgeno"                                                 , 1, 1, .F., ""       ) // 62
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Presença do Alérgeno"                                     , 1, 1, .F., ""       ) // 63
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Observações"                                              , 1, 1, .F., ""       ) // 64
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Tipo do Site"                                             , 1, 1, .F., ""       ) // 65
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Link do site (URL)"                                       , 1, 1, .F., ""       ) // 66
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Nome do Site"                                             , 1, 1, .F., ""       ) // 67
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Data de lançamento para o mercado (DD/MM/AAAA)"           , 1, 1, .F., ""       ) // 68
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "País de destino"                                          , 1, 1, .F., ""       ) // 69
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Quantidade Mínima para Pedido"                            , 1, 1, .F., ""       ) // 70
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Unidade de Medida para Pedidos"                           , 1, 1, .F., ""       ) // 71
                      _oFwXlsx:AddColumn( "GTIN14", "Table1", "Múltiplo da Quantidade para Pedido"                       , 1, 1, .F., ""       ) // 72
       Endif
       DbSelectArea('SB1')
       DbSetOrder(1)
       DbSelectArea('ZA1')
       ZA1->( DbGoTop() )
       ZA1->( DbSeek( xFilial('ZA1') ) )
       While !ZA1->( Eof() ) .and. ZA1->ZA1_FILIAL == xFilial('ZA1')
             If !EMPTY( ZA1->ZA1_PRODUT ) .and. ZA1->ZA1_CNP == 'N'
                IncProc( "Processando registro " + Alltrim( ZA1->ZA1_PRODUT ) + "..." )
                SB1->( DbSeek( xFilial('SB1') + ZA1->ZA1_PRODUT ) )
                If Alltrim( xFilial('ZA1') ) $ '01.06'
                   SZ5->( DbSeek( xFilial('SZ5') + SubStr( ZA1->ZA1_PRODUT, 11, 2 ) ) )
                   _oFwXlsx:AddRow( "GTIN13", "Table1", { 'Ativo'                     ,;
                                                          ZA1->ZA1_GTIN               ,;
                                                          'BRASILUX TINTAS ' + Alltrim( SB1->B1_DESC ) + ' ' + Alltrim( SZ5->Z5_DESCR )  ,;
                                                          'Português (Brasil)'        ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          'Foto do produto'           ,;
                                                          'https://cnp30blob.blob.core.windows.net/cnp3filestemp/8facc1974b0400f078749a292034e9bec41d72d104ed66277713baaaa3a2d012.png',;
                                                          'naodisponivel.png'         ,;
                                                          'Português (Brasil)'        ,;
                                                          'Sim'                       ,;
                                                          'Brasilux Tintas'           ,;
                                                          'Português (Brasil)'        ,;
                                                          'Código SKU'                ,;
                                                          Alltrim( ZA1->ZA1_PRODUT )  ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          'Brasil'                    ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ROUND( SB1->B1_PESBRU, 4 )  ,;
                                                          'kg'                        ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ROUND( SB1->B1_PESO, 4 )    ,;
                                                          'kg'                        ,;
                                                          ROUND( SZ5->Z5_VOLUME, 2 )  ,;
                                                          'l'                         ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          TransForm( SB1->B1_POSIPI, "@R 9999.99.99" ),;
                                                          ''                          ,;
                                                          TransForm( SB1->B1_CEST  , "@R 99.999.99" ),;
                                                          SB1->B1_IPI                 ,;
                                                          '10002505'                  ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          'Brasil'                    ,;
                                                          ''                          ,;
                                                          ''                          ,;
                                                          ''                           ;
                                                        } )
                Else
                   If SubStr( SB1->B1_COD, 1, 4 ) == '1AAA'
                      DbSelectArea('SB5')
                      SB5->( DbSetOrder(1))
                      If SB5->( DbSeek( xFilial('SB5') + SB1->B1_COD ) )
                         _nConv := StrZero( Iif( SB5->B5_CONVDIP == 0, SB1->B1_CONV, SB5->B5_CONVDIP ), 2 )
                      Endif
                      _oFwXlsx:AddRow( "GTIN14", "Table1", { 'Ativo'                     ,;
                                                             ZA1->ZA1_GTIN14             ,;
                                                             Alltrim( SB1->B1_DESC ),;
                                                             'Português (Brasil)'        ,;
                                                             ZA1->ZA1_GTIN               ,;
                                                             _nConv                      ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             'Foto do produto'           ,;
                                                             'https://cnp30blob.blob.core.windows.net/cnp3filestemp/8facc1974b0400f078749a292034e9bec41d72d104ed66277713baaaa3a2d012.png',;
                                                             'naodisponivel.png'         ,;
                                                             'Português (Brasil)'        ,;
                                                             'Sim'                       ,;
                                                             'Tecpolpa'                  ,;
                                                             'Português (Brasil)'        ,;
                                                             'Código SKU'                ,;
                                                             Alltrim( ZA1->ZA1_PRODUT )  ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             'Brasil'                    ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ROUND( SB1->B1_PESBRU, 4 )  ,;
                                                             'kg'                        ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ROUND( SB1->B1_PESO, 4 )    ,;
                                                             'kg'                        ,;
                                                             ''                          ,;
                                                             'l'                         ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             TransForm( SB1->B1_POSIPI, "@R 9999.99.99" ),;
                                                             ''                          ,;
                                                             TransForm( SB1->B1_CEST  , "@R 99.999.99" ),;
                                                             SB1->B1_IPI                 ,;
                                                             '10000223'                  ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             'Brasil'                    ,;
                                                             ''                          ,;
                                                             ''                          ,;
                                                             ''                           ;
                                                           } )
                   Endif
                Endif
             Endif
             DbSelectArea("ZA1")
             ZA1->( DbSkip() )
       EndDo

       _oFwXlsx:SetFont( "Calibri" )
       _oFwXlsx:SetFontSize( 11 )
       _oFwXlsx:SetItalic( .f. )
       _oFwXlsx:SetBold( .f. )
       _oFwXlsx:SetUnderline( .f. )

       _oFwXlsx:Activate()
       _oFwXlsx:GetXMLFile( "c:\TOTVS\GTIN.xlsx" )
       _oFwXlsx:DeActivate()

Return

Static Function fValidDad( _oBarProc )
       Local _cCodBra  := '789'
       Local _nCodGS1  := Iif( Alltrim( xFilial('ZA1') ) == '01', '3866', Iif( Alltrim( xFilial('ZA1') ) == '06', '9599', Iif( Alltrim( xFilial('ZA1') ) == '11', '8608', '' )) )
       Local _cLogCar  := ''
       Local _cArquivo := "C:\TOTVS\LOG_" + DTOS( dDataBase ) + "_" + SubStr( time(), 1, 2 ) + SubStr( time(), 4, 2 ) + ".txt"
       Local _cEof     := Chr(13) + Chr(10)

       DbSelectArea("SB1")
       _oBarProc:SetRegua1(2)
       _oBarProc:IncRegua1('Buscando produtos com codigos de barras')
       _oBarProc:SetRegua2( SB1->( RecCount() ) )
       If Alltrim( SB1->B1_FILIAL ) <> '11'
          SB1->( DbSetOrder( 5 ) )
          SB1->( DbSeek( xFilial('SB1') + _cCodBra ) )
          While !Eof()
                _oBarProc:IncRegua2('Analisando...')
                If !Empty( SB1->B1_CODGTIN )
                   DbSelectArea("ZA1")
                   ZA1->( DbSetOrder(3) )
                   If ZA1->( DbSeek( xFilial("ZA1") + SB1->B1_CODGTIN ) )
                      RecLock( "ZA1", .f. )
                         If Alltrim( ZA1->ZA1_FILIAL ) == '01'
                            IF Empty( ZA1->ZA1_PRODUT )
                               ZA1->ZA1_PRODUT := SB1->B1_COD
                            Endif
                            If ZA1->ZA1_RELVOL <= 0
                               ZA1->ZA1_RELVOL  := Val( SB1->B1_RELCAT2 )
                            Endif
                         ElseIf Alltrim( ZA1->ZA1_FILIAL ) == '06'
                                //If SubStr( SB1->B1_COD, 4, 2 ) $ '68.95.96.97.98' .and. SubStr( SB1->B1_CODGTIN, 1, 7 ) == _cCodBra + _nCodGS1
                                   IF Empty( ZA1->ZA1_PRODUT )
                                      ZA1->ZA1_PRODUT := SB1->B1_COD
                                   Endif
                                   If ZA1->ZA1_RELVOL <= 0
                                      ZA1->ZA1_RELVOL  := Val( SB1->B1_RELCAT2 )
                                   Endif
                                //Endif
                         Endif
                      MsUnLock()
                   Endif
                Endif
                DbSelectArea("SB1")
                SB1->( DbSkip() )
          EndDo
       ElseIf Alltrim( SB1->B1_FILIAL ) == '11'
              SB1->( DbSetOrder( 1 ) )
              SB1->( DbGoTop( ) )
              While !Eof()
                    _oBarProc:IncRegua2('Analisando...')
                    If SubStr( SB1->B1_COD, 1, 4 ) $ '1AAA' .and. !Empty( SB1->B1_CODGTIN ) .and. SB1->B1_TIPO = 'PA' .and. SB1->B1_MSBLQL <> '1'
                       If SubStr( SB1->B1_CODGTIN, 1, 1 ) == '1' //GTIN 14
                          DbSelectArea("ZA1")
                          ZA1->( DbSetOrder(4) )
                       Else
                          DbSelectArea("ZA1")
                          ZA1->( DbSetOrder(3) )
                       Endif
                       If ZA1->( DbSeek( xFilial("ZA1") + SB1->B1_CODGTIN ) )
                          IF Empty( ZA1->ZA1_PRODUT )
                             RecLock( 'ZA1', .f. )
                                ZA1->ZA1_PRODUT := SB1->B1_COD
                             MsUnLock()
                          Endif
                       Endif
                    Endif
                    DbSelectArea('SB1')
                    SB1->( DbSkip( ) )
              EndDo
       Endif
       DbSelectArea("ZA1")
Return

Static Function fVerSeqCd( _oBarProc )
       Local _nY       := 0
       Local _cCodBra  := '789'
       Local _nCodGS1  := Iif( Alltrim( xFilial('ZA1') ) == '01', '3866', Iif( Alltrim( xFilial('ZA1') ) == '06', '9599', Iif( Alltrim( xFilial('ZA1') ) == '11', '8608', '' )) )
       _oBarProc:SetRegua1(2)
       _oBarProc:IncRegua1('Buscando seqüência de códigos.')
       _oBarProc:SetRegua2( 99999 )

       If !Empty( _nCodGS1 )
          DbSelectArea('ZA1')
          ZA1->( DbSetOrder( 2 ) )
          If !ZA1->( DbSeek( xFilial('ZA1') + '00001' ) )
             For _nY := 1 TO 99999
                 _oBarProc:IncRegua2('Seqüência... ' + StrZero( _nY, 5 ) )
                 RecLock( 'ZA1', .t. )
                    ZA1->ZA1_FILIAL := xFilial('ZA1')
                    ZA1->ZA1_PRODUT := ''
                    ZA1->ZA1_SEQCOD := StrZero( _nY, 5 )
                    ZA1->ZA1_GTIN   := _cCodBra + _nCodGS1 + StrZero( _nY, 5 ) + EanDigito( _cCodBra + _nCodGS1 + StrZero( _nY, 5 ) )
                    ZA1->ZA1_GTIN14 := '1' + _cCodBra + _nCodGS1 + StrZero( _nY, 5 ) + EanDigito( '1' + _cCodBra + _nCodGS1 + StrZero( _nY, 5 ) )
                    ZA1->ZA1_RELVOL := 0
                    ZA1->ZA1_CNP    := 'N'
                 ZA1->( MsUnLock() )
                 DbSelectArea('ZA1')
                 ZA1->( DbSkip( ) )
             Next
          Endif
       Else
          MessageBox( 'Essa empresa não utiliza Codigo de Barras.', 'Atenção', 64 )
       Endif
       DbSelectArea('ZA1')
Return
