#include "totvs.ch"

//***************************************************************//
// Programa.......: A410TAB                                      //
// Autor..........: Cleber Orati                                 //
// Ult. Alteração.:                                              //
// Data...........:    09/2012                                   //
// Ocorrência.....: Contorno para probl. de trazer vlr tabela    //
//                  indevidamente no preço negociado             //
// Data...........: 25/09/2019                                   //
// Alteração......: Luis Gustavo                                 //
// Ocorrência.....: Adequação para release 12.1.25               //
//***************************************************************//
User Function A410TAB(cProduto , cTabPrec , nLinha , nQtde , cCliente , cLoja , cLote , cSubLote)
     Local _nRet  := 0
     Local _aArea := GetArea()
     
     If FWCodEmp() <> '11'  //Empresas que não são do grupo 11(Tecpolpa).
        _nRet := 0
     Else
        //**************************************************************************************
        //*** LGS#20191008 - Precisei montar esse tratamento para buscar informações da tabela
        //                   de preço utilizada na Tecpolpa, pois na brasilux o Ponto de entrada
        //                   retorna o valor zerado.
        If ! Empty( ParamIXB[ 2 ] )
           DbSelectArea("DA0")
           DA0->( DbSetOrder( 1 ) )
           If DA0->( DbSeek( xFilial("DA0") + ParamIXB[ 2 ] ) ) //DA0_FILIAL + DA0_CODTAB
              If DA0->DA0_ATIVO == '1'
                 //Busco o produto na tabela e retorno o preço
                 DbSelectArea("DA1")
                 DA1->( DbSetOrder( 1 ) ) //DA1_FILIAL + DA1_CODTAB + DA1_CODPRO + DA1_INDLOT + DA1_ITEM
                 If DA1->( DbSeek( xFilial("DA1") + ParamIXB[ 2 ] + ParamIXB[ 1 ] ) )
                    If DA1->DA1_ATIVO == '1'
                       _nRet := DA1->DA1_PRCVEN
                    Else
                       Aviso( "Atenção", "Tabela de preços " + ParamIXB[ 2 ] + " para o produto " + ParamIXB[ 1 ] + " encontra-se INATIVA! Verifique!!!", { "Ok" }, 1)
                       _nRet := 0
                    Endif
                 Else
                    Aviso( "Atenção", "Preço para o produto " + ParamIXB[ 1 ] + " da tabela " + ParamIXB[ 2 ] + " não encontrado! Verifique!!!", { "Ok" }, 1)
                    _nRet := 0
                 Endif
              Else
                 Aviso( "Atenção", "Tabela de preços " + ParamIXB[ 2 ] + " encontra-se INATIVA! Verifique!!!", { "Ok" }, 1)
                 _nRet := 0
              Endif
           Else
              Aviso( "Atenção", "Tabela de preços " + ParamIXB[ 2 ] + " não encontrada! Verifique!!!", { "Ok" }, 1)
              _nRet := 0
           Endif
        Endif
     Endif
     RestArea( _aArea )       
Return( _nRet )