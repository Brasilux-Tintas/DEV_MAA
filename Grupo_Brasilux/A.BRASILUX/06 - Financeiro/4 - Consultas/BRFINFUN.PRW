//#include 'brasilux.ch'
#include "protheus.ch"
#DEFINE QTDETITULOS 1
#DEFINE MOEDATIT    2
#DEFINE VALORTIT    3
#DEFINE VALORREAIS  4

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FINFUN_01³ Autor ³ Luís Gustavo de Souza ³ Data ³13.05.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta a Posicao de Clientes                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : nOpcao                                             ³±±
±±³          ³         [1] Titulos em Aberto                              ³±±
±±³          ³         [2] Titulos Recebidos                              ³±±
±±³          ³         [3] Pedidos                                        ³±±
±±³          ³         [4] Faturamento                                    ³±±
±±³          ³ ExpA2 : Alias a Serem Fechados.                            ³±±
±±³          ³ ExpA3 : [1] Data de Emissao Inicial                        ³±±
±±³          ³         [2] Data de Emissao Final                          ³±±
±±³          ³         [3] Vencimento Inicial                             ³±±
±±³          ³         [4] Vencimento Final                               ³±±
±±³          ³         [5] Considera Provisorios (1) Sim (2) Nao          ³±±
±±³          ³         [6] Prefixo Inicial                                ³±±
±±³          ³         [7] Prefixo Final                                  ³±±
±±³          ³ ExpL4 : Indica se os dados devem ser exibidos              ³±±
±±³          ³ ExpL5 : Indica se os dados serao montados para o relatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FINFUN_01(nBrowse, aAlias, aParam, lExibe, aGet, lRelat, lAcsCre)
     Local aArea     := GetArea()
     Local aAreaSC5  := SC5->(GetArea())
     Local aAreaSC6  := SC6->(GetArea())
     Local aAreaSC9  := SC9->(GetArea())
     Local aAreaSF4  := SF4->(GetArea())
     Local aStru     := {}
     Local aQuery    := {}
     Local aSay      := {"","","","","",""}
     Local aSize     := MsAdvSize( .F. )
     Local aPosObj1  := {}
     Local aObjects  := {}

     Local oGetDb
     Local oDlg
     Local oBtn
     Local oAlt
     Local oScrPanel
     Local oBold
     Local bVisual
     Local bAltera
     Local bWhile
     Local bFiltro
     Local cAlias	   := ""
     Local cArquivo  := ""
     Local cCadastro := ""
     Local cQuery    := ""
     Local cQry      := ""
     Local cChave    := ""
     Local lQuery    := .F.
     Local nCntFor   := 0
     Local nSalped   := 0
     Local nSalpedl  := 0
     Local nSalpedb  := 0
     Local nQtdPed   := 0
     Local nTotAbat  := 0
     Local cAnterior := ""
     Local nTaxaM	   := 0
     Local nTipo     := 1
     Local aTotRec   := {{0,1,0,0}} // Totalizador de titulos a receber por por moeda
     Local aTotPag   := {{0,1,0,0}} // Totalizador de titulos recebidos por por moeda
     Local nTotalRec :=0
     Local nMoeda
     //Local oDlgl, cMoeda, aMoedas, nX, oCBXMoeda
     //Local oCBX0tras, cOtras, aOtras
     Local oTipo, bTipo, oCheq
     Local nAscan
     Local cDbMs
     Local _lOpen    := .F. //LGS#20200128 - Adequação para release 12.1.25
     Local _aSX5Situ := FwGetSX5( "07" )
     Local _cSX5Desc := ""
     Local _nX
     Private aHeader := {}
     Private _lRelat  := Iif(lRelat == Nil, .F., lRelat)
     Private _cAliasSX3  := GetNextAlias() //LGS#20200128 - Adequação para release 12.1.25
     Private oTempTbl01
     u_zcfga01( 'FINFUN_01' ) //LGS#2021201 - Gravação de log de utilização da rotina
     aGet := {"","","","","",""}

     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200128 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0

     If !_lOpen
        MessageBox( "Não foi possível abrir dicionário de dados SX3!", "Atenção", 16 )
        Return
     Endif
     Do Case
        Case (nBrowse == 1)
             cCadastro := OemToAnsi("Tit Aberto")
             cAlias    := "FC010QRY01"
             aSay[1]   := OemToAnsi("Qtd.Tit.")
             aSay[2]   := OemToAnsi("Principal")
             aSay[3]   := OemToAnsi("Saldo")
             aSay[4]   := OemToAnsi("Juros")
             aSay[5]   := OemToAnsi("Acresc.")
             aSay[6]   := OemToAnsi("Decresc.")
             bVisual   := {|| fFINFUN_03((cAlias)->XX_RECNO, nBrowse) }
             bAltera   := {|| fFINFUN_04((cAlias)->XX_RECNO, nBrowse) }
        Case (nBrowse == 2)
             cCadastro := OemToAnsi("Tit Recebidos")
             cAlias    := "FC010QRY02"
             aSay[1]   := OemToAnsi("Qtd.Pag.")
             aSay[2]   := OemToAnsi("Principal")
             aSay[3]   := OemToAnsi("Vlr.Pagto")
             bVisual   := {|| fFINFUN_03((cAlias)->XX_RECNO, nBrowse) }
        Case (nBrowse == 3)
             cCadastro := OemToAnsi("Pedidos")
             cAlias    := "FC010QRY03"
             aSay[1]   := OemToAnsi("Qtd.Ped.")
             aSay[2]   := OemToAnsi("Tot.Pedido")
             aSay[3]   := OemToAnsi("Tot.Liber.")
             aSay[4]   := OemToAnsi("Sld.Pedido")
             bVisual   := {|| fFINFUN_03((cAlias)->XX_RECNO, nBrowse) }
        Case (nBrowse == 4)
             cCadastro := OemToAnsi("Faturamento")
             cAlias    := "FC010QRY04"
             aSay[1]   := OemToAnsi("Qtd.Notas")
             aSay[2]   := OemToAnsi("Tot.Fatur.")
             bVisual   := {|| fFINFUN_03((cAlias)->XX_RECNO,nBrowse) }
        Case (nBrowse == 5)
             cCadastro := OemToAnsi("Cartera de cheques")
             cAlias    := "FC010QRY05"
             aSay[1]   := OemToAnsi("Pendiente")
             If cPaisLoc == 'URU'
                aSay[2]:= OemToAnsi("Rechazado")
             Else
                aSay[2]:= OemToAnsi("Negociado")
             Endif
             aSay[3]   := OemToAnsi("Cobrado")
             bVisual   := {|| fFINFUN_03((cAlias)->XX_RECNO,1) }
     EndCase
     Do Case
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³Titulo em Aberto                                                        ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        Case (nBrowse == 1)
             /********************************************************************************************************************************/
             /*** BLOCO ALTERADO EM 30/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
             /*
             DbSelectArea("SX3")
             DbSetOrder(2)
             DbSeek("E1_PREFIXO")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_NUM")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_PARCELA")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_TIPO")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_CLIENTE")
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_LOJA")
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_EMISSAO")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_VENCTO")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_VENCREA")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		
             If !lRelat
                DbSeek("E1_MOEDA")
                aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
                DbSeek("E1_VALOR")
                aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
                aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
                aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             Endif	
             DbSeek("E1_VLCRUZ")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aHeader,{"Abatimentos","E1_ABT","@E 999,999,999.99",14,2,"","","N","","V" } )
             aadd(aStru ,{"E1_ABT","N",14,2})
             DbSeek("E1_SDACRES")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_SDDECRE")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_SALDO")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             If !lRelat
                aadd(aHeader,{ "Saldo na moeda tit","E1_SALDO2",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
                aadd(aStru ,{"E1_SALDO2",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             Endif
             DbSeek("E1_NATUREZ")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_PORTADO")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_NUMBCO")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_HIST")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aHeader,{"Atraso","E1_ATR","99999",5,0,"","","N","","V" } )
             aadd(aStru ,{"E1_ATR","N",5,0})
             DbSeek("E1_VALJUR")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             */
             DbSelectArea( _cAliasSX3 )
             DbSetOrder(2)
             DbSeek("E1_PREFIXO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_NUM")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_PARCELA")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_TIPO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_CLIENTE")
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_LOJA")
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_EMISSAO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_VENCTO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_VENCREA")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
		
             If !_lRelat
                DbSeek("E1_MOEDA")
                aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
                DbSeek("E1_VALOR")
                aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
                aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
                aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             Endif	
             DbSeek("E1_VLCRUZ")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd(aHeader,{"Abatimentos","E1_ABT","@E 999,999,999.99",14,2,"","","N","","V" } )
             aadd(aStru ,{"E1_ABT","N",14,2})
             DbSeek("E1_SDACRES")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_SDDECRE")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_SALDO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             If !_lRelat
                aadd( aHeader, { "Saldo na moeda tit", "E1_SALDO2", (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
                aadd( aStru  , { "E1_SALDO2", (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             Endif
             DbSeek("E1_NATUREZ")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_PORTADO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_NUMBCO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_HIST")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd(aHeader,{"Atraso","E1_ATR","99999",5,0,"","","N","","V" } )
             aadd(aStru ,{"E1_ATR","N",5,0})
             DbSeek("E1_VALJUR")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )

             #IfDef SPANISH
                    Aadd(aStru,{"X5_DESCSPA","C",25,0})
             #Else
                 #IfDef ENGLISH
                        Aadd(aStru,{"X5_DESCENG","C",25,0})			
                 #Else
                     Aadd(aStru,{"X5_DESCRI","C",25,0})
                 #Endif
             #Endif
             aadd(aStru,{"XX_RECNO"  , "N", 12, 0})
             If !_lRelat
                aadd(aStru,{"E1_MOEDA"  , "N", 02, 0})
             Endif	
             aadd(aQuery,{"E1_PORCJUR", "N", 12, 4})
             aadd(aQuery,{"E1_MOEDA"  , "N", 02, 0})
             aadd(aQuery,{"E1_VALOR"  , "N", 16, 2})
             #IfDef SPANISH
                    Aadd(aHeader,{"Situacao","X5_DESCSPA","@!",25,0,"","","C","SX5","" } )
             #Else
                 #IfDef ENGLISH
                        Aadd(aHeader,{"Situacao","X5_DESCENG","@!",25,0,"","","C","SX5","" } )
                 #Else
                     Aadd(aHeader,{"Situacao","X5_DESCRI","@!",25,0,"","","C","SX5","" } )
                 #Endif
             #Endif
             SX3->(DbSetOrder(1))
             If ( Select(cAlias) ==	0 )
                /********************************************************************************************************************************/
                /*** BLOCO ALTERADO EM 31/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
                //cArquivo := CriaTrab(,.F.)			
                //aadd(aAlias,{ cAlias , cArquivo })
                aadd(aStru,{"FLAG","L",01,0})
                //DbCreate(cArquivo,aStru)
                //DbUseArea(.T.,,cArquivo,cAlias,.F.,.F.)
                //IndRegua(cAlias,cArquivo,"E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO")
                oTempTbl01 := FWTemporaryTable():New( cAlias )
                oTempTbl01:SetFields( aStru )
                oTempTbl01:AddIndex( "cInd01", { "E1_CLIENTE", "E1_LOJA", "E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO" } )
                oTempTbl01:AddIndex( "cInd02", { "E1_VENCREA" } )
                oTempTbl01:Create()
                cArquivo := oTempTbl01:GetRealName()
                aadd(aAlias,{ cAlias , cArquivo })
                /********************************************************************************************************************************/
                #IFDEF TOP
                       If (TcSrvType()!="AS/400")
                          lQuery := .T.
                          cQuery := ""
                          aEval(aQuery,{|x| cQuery += ","+AllTrim(x[1])})
                          cQuery := "SELECT "+SubStr(cQuery,2)
                          cQuery +=         ",SE1.R_E_C_N_O_ SE1RECNO"
                          #IfDef SPANISH
                                 cQuery += ",SX5.X5_DESCSPA "
                          #Else
                              #IfDef ENGLISH
                                     cQuery += ",SX5.X5_DESCENG "				
                              #Else
                                  cQuery += ",SX5.X5_DESCRI "								
                              #Endif
                          #Endif
                          cQuery += "FROM "+RetSqlName("SE1")+" SE1 WITH (NOLOCK),"
                          cQuery +=         RetSqlName("SX5")+" SX5 WITH (NOLOCK) "
                          cQuery += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
                          cQuery +=       "SE1.E1_CLIENTE='"+SA1->A1_COD+"' AND "
                          cQuery +=       "SE1.E1_LOJA='"+SA1->A1_LOJA+"' AND "
                          cQuery +=       "SE1.E1_EMISSAO>='"+Dtos(aParam[1])+"' AND "
                          cQuery +=       "SE1.E1_EMISSAO<='"+Dtos(aParam[2])+"' AND "
                          cQuery +=       "SE1.E1_VENCREA>='"+Dtos(aParam[3])+"' AND "
                          cQuery +=       "SE1.E1_VENCREA<='"+Dtos(aParam[4])+"' AND "
                          If (aParam[5] == 2)
                             cQuery +=   "SE1.E1_TIPO<>'PR ' AND "
                          EndIf					
                          If cPaisLoc	<> "BRA"
                             cQuery +=   "SE1.E1_TIPO<>'"+MVCHEQUE+"' AND "
                          Endif
                          cQuery +=      "SE1.E1_PREFIXO>='"+aParam[6]+"' AND "
                          cQuery +=      "SE1.E1_PREFIXO<='"+aParam[7]+"' AND "
                          cQuery +=      "SE1.E1_FATURA IN('"+Space(Len(SE1->E1_FATURA))+"','NOTFAT') AND "
                          cQuery +=      "SE1.E1_SALDO > 0 AND "
                          If mv_par11 == 2 // Se nao considera titulos gerados pela liquidacao
                             cQuery += "SE1.E1_NUMLIQ ='"+Space(Len(SE1->E1_NUMLIQ))+"' AND "
                             cQuery += "SE1.E1_TIPOLIQ='"+Space(Len(SE1->E1_TIPOLIQ))+"' AND "
                          Endif
                          cQuery +=		"SE1.D_E_L_E_T_<>'*' AND "
                          cQuery +=     "SX5.X5_FILIAL='"+xFilial("SX5")+"' AND "
                          cQuery +=		"SX5.X5_TABELA='07' AND "
                          cQuery +=		"SX5.X5_CHAVE=SE1.E1_SITUACA AND "
                          cQuery +=		"SX5.D_E_L_E_T_<>'*' "
                          cQuery += "AND SE1.E1_TIPO NOT LIKE '__-' UNION ALL "+cQuery
                          cQuery += "AND SE1.E1_TIPO LIKE '__-'"
                          //cQuery := ChangeQuery(cQuery)
                          cQry   := cArquivo+"A"
                          dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)
                          aEval(aQuery,{|x| If(x[2]!="C",TcSetField(cQry,x[1],x[2],x[3],x[4]),Nil)})
                       Else
                #ENDIF
                cQry := "SE1"
                #IFDEF TOP
                       EndIf
                #ENDIF
                DbSelectArea(cQry)
                If (!lQuery)
                   DbSetOrder(2)
                   DbSeek(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA)
                   bWhile := {|| !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL ;
                                        .And. SA1->A1_COD    == SE1->E1_CLIENTE;
                                        .And. SA1->A1_LOJA   == SE1->E1_LOJA }
                   bFiltro:= {|| !(SE1->E1_TIPO $ MVABATIM) .And.;
                                   SE1->E1_EMISSAO >= aParam[1] .And.;
                                   SE1->E1_EMISSAO <= aParam[2] .And.;
                                   SE1->E1_VENCREA >= aParam[3] .And.;
                                   SE1->E1_VENCREA <= aParam[4] .And.;
                                   If(aParam[5]==2,SE1->E1_TIPO!="PR ",.T.) .And.;
                                   SE1->E1_PREFIXO >= aParam[6] .And.;
                                   SE1->E1_PREFIXO <= aParam[7] .And.;
                                   SE1->E1_SALDO   > 0 .And.;
                                   IIf(cPaisLoc == "BRA",.T.,SE1->E1_TIPO<>MVCHEQUE) .And.;
                                   IIF(mv_par11 == 2, Empty(SE1->E1_NUMLIQ) .And. Empty(SE1->E1_TIPOLIQ),.T.)}
                Else
                   bWhile := {|| !Eof() }
                   bFiltro:= {|| .T. }
                EndIf			
                While (Eval(bWhile))				
                      If (Eval(bFiltro))
                         If (!lQuery)
                            //LGS#20200131 - Adequação ao release 12.1.25 e posteriores
                            //DbSelectArea("SX5")
                            //DbSetOrder(1)
                            //MsSeek(xFilial("SX5")+"07"+SE1->E1_SITUACA)
                            For _nX := 1 To Len( _aSX5Situ )
                                If Upper( Alltrim( _aSX5Situ[_nX][2] ) ) == Upper( Alltrim( SE1->E1_SITUACA ) )
                                   _cSX5Desc := Alltrim( _aSX5Situ[_nX][4] )
                                Endif
                            Next
                         EndIf
                         DbSelectArea(cAlias)
                         DbSetOrder(1)
                         cChave := (cQry)->(E1_CLIENTE)+(cQry)->(E1_LOJA) +;
                                   (cQry)->(E1_PREFIXO)+(cQry)->(E1_NUM)+;
                                   (cQry)->(E1_PARCELA)
                         cChave += If((cQry)->(E1_TIPO)	$ MVABATIM, "",;
                                   (cQry)->(E1_TIPO))
                         If (!dbSeek(cChave))
                            RecLock(cAlias,.T.)						
                         Else
                            RecLock(cAlias,.F.)
                         EndIf
                         DbSetOrder(1)
                         nTotAbat := 0
                         For nCntFor := 1 To Len(aStru)
                             Do Case
                                #IfDef SPANISH
                                       Case (AllTrim(aStru[nCntFor][1])=="X5_DESCSPA")
                                            If !((cQry)->(E1_TIPO) $ MVABATIM)
                                               If (lQuery)
                                                  (cAlias)->( X5_DESCSPA ) := (cQry)->( X5_DESCSPA )
                                               Else
                                                  //(cAlias)->( X5_DESCSPA ) := SX5->X5_DESCSPA
                                                  (cAlias)->( X5_DESCSPA ) := _cSX5Desc
                                               EndIf
                                            Endif	
                                #Else
                                    #IfDef ENGLISH
                                           Case (AllTrim(aStru[nCntFor][1])=="X5_DESCENG")
                                                If !((cQry)->(E1_TIPO) $ MVABATIM)
                                                   If (lQuery)
                                                      (cAlias)->( X5_DESCENG ) := (cQry)->( X5_DESCENG )
                                                   Else
                                                      //(cAlias)->( X5_DESCENG ) := SX5->X5_DESCENG
                                                      (cAlias)->( X5_DESCENG ) := _cSX5Desc
                                                   EndIf
                                                Endif	
                                    #Else
                                        Case (AllTrim(aStru[nCntFor][1])=="X5_DESCRI")
                                             If !((cQry)->(E1_TIPO) $ MVABATIM)
                                                If (lQuery)
                                                   (cAlias)->( X5_DESCRI ) := (cQry)->( X5_DESCRI )
                                                Else
                                                   //(cAlias)->( X5_DESCRI ) := SX5->X5_DESCRI
                                                   (cAlias)->( X5_DESCRI ) := _cSX5Desc
                                                EndIf
                                             Endif	
                                    #Endif
                                #Endif
                                Case (AllTrim(aStru[nCntFor][1])=="E1_VALJUR")
                                Case (AllTrim(aStru[nCntFor][1])=="E1_ABT")
                                     nTaxaM:=round((cQry)->E1_VLCRUZ / (cQry)->E1_VALOR,4)  // Pegar a taxa da moeda usada qdo da inclusão do titulo
                                     If ((cQry)->(E1_TIPO) $ MVABATIM)
                                        (cAlias)->E1_ABT := (nTotAbat := xMoeda((cQry)->(E1_SALDO),(cQry)->(E1_MOEDA),1,(cQry)->(E1_EMISSAO),,nTaxaM))
                                     Endif
                                     If (!lQuery)
                                        (cAlias)->E1_ABT := (nTotAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA))
                                     Endif
                                Case (AllTrim(aStru[nCntFor][1])=="E1_SALDO")
                                     If ((cQry)->(E1_TIPO) $ MVABATIM)
                                        (cAlias)->E1_SALDO -= nTotAbat
                                     Else
                                        (cAlias)->E1_SALDO += xMoeda((cQry)->(E1_SALDO),(cQry)->(E1_MOEDA),1,dDataBase)
                                        (cAlias)->E1_SALDO += xMoeda((cAlias)->E1_SDACRES - (cAlias)->E1_SDDECRE,(cQry)->(E1_MOEDA),1,dDataBase)
                                     EndIf
                                     If (!lQuery)
                                        (cAlias)->E1_SALDO -= nTotAbat
                                     EndIf
                                Case (AllTrim(aStru[nCntFor][1])=="E1_SALDO2")
                                     If ( (cQry)->(E1_TIPO)	$ MVABATIM )
                                        (cAlias)->E1_SALDO2 -= nTotAbat
                                     Else
                                        (cAlias)->E1_SALDO2 += (cQry)->(E1_SALDO)
                                        (cAlias)->E1_SALDO2 += (cAlias)->E1_SDACRES - (cAlias)->E1_SDDECRE
                                     EndIf
                                     If (!lQuery)
                                        (cAlias)->E1_SALDO2 -= nTotAbat
                                     EndIf	
                                Case (AllTrim(aStru[nCntFor][1])=="XX_RECNO")
                                     If !((cQry)->(E1_TIPO)	$ MVABATIM)
                                        If (lQuery)
                                           (cAlias)->XX_RECNO := (cQry)->SE1RECNO
                                        Else
                                           (cAlias)->XX_RECNO := SE1->(RecNo())
                                        EndIf
                                     Endif
                                Case (AllTrim(aStru[nCntFor][1])=="E1_TIPO")
                                     If (Empty((cAlias)->E1_TIPO))
                                        (cAlias)->E1_TIPO := (cQry)->E1_TIPO
                                     EndIf
                                Case ( AllTrim(aStru[nCntFor][1])=="E1_ATR" )
                                     If dDataBase > DataValida((cQry)->E1_VENCTO)
                                        (cAlias)->E1_ATR := dDataBase - (cQry)->E1_VENCTO
                                     Else
                                        (cAlias)->E1_ATR := dDataBase - DataValida((cQry)->E1_VENCTO,.T.)
                                     Endif
                                Case (AllTrim(aStru[nCntFor][1])=="FLAG")
                                Case (AllTrim(aStru[nCntFor][1])=="E1_VLCRUZ")
                                     If !((cQry)->(E1_TIPO)	$ MVABATIM)
                                        (cAlias)->E1_VLCRUZ := xMoeda((cQry)->(E1_VALOR),(cQry)->(E1_MOEDA),1,dDataBase)
                                     Endif
                                OtherWise							
                                     If !((cQry)->(E1_TIPO) $ MVABATIM)
                                        If (lQuery)
                                           (cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))
                                        Else
                                           (cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))
                                        Endif
                                     Endif	
                             EndCase
                         Next nCntFor
                         DbSelectArea(cAlias)
                         If nTotAbat = 0
                            If ((cAlias)->E1_SALDO <= 0)
                               dbDelete()
                            EndIf
                         Endif						
                         (cAlias)->E1_VALJUR := xMoeda(FaJuros((cQry)->E1_VALOR,(cAlias)->E1_SALDO,(cAlias)->E1_VENCTO,(cQry)->E1_VALJUR,(cQry)->E1_PORCJUR,(cQry)->E1_MOEDA,(cQry)->E1_EMISSAO),(cQry)->E1_MOEDA,1)
                         MsUnLock()
                      EndIf
                      DbSelectArea(cQry)
                      DbSkip()				
                EndDo
                If (lQuery)
                   DbSelectArea(cQry)
                   DbCloseArea()
                   ChkFile(cQry)
                EndIf
                DbSelectArea(cAlias)
                //IndRegua(cAlias,cArquivo,"DTOS(E1_VENCREA)")
                DbSetOrder( 2 )
             EndIf
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³Totais da Consulta                                                      ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             aGet[1] := 0
             aGet[2] := 0
             aGet[3] := 0
             aGet[4] := 0
             aGet[5] := 0
             aGet[6] := 0
             aTotRec := {{0,1,0,0}} // Totalizador de titulos a receber por por moeda
             DbSelectArea(cAlias)
             DbGotop()
             While !EOF()
                   aGet[1]++
                   If !_lRelat
                      SE1->(DbGoto((cAlias)->XX_RECNO)) // Posiciona no arquivo original para obter os valores
                                                        // em outras moedas e em R$
                      nAscan := Ascan(aTotRec,{|e| e[MOEDATIT] == E1_MOEDA})
                   Endif
                   If E1_TIPO $ "RA #"+MV_CRNEG
                      aGet[2] -= E1_VLCRUZ
                      aGet[3] -= E1_SALDO
                      aGet[4] -= E1_VALJUR
                      aGet[5] -= xMoeda(E1_SDACRES,E1_MOEDA,1,dDataBase)
                      aGet[6] -= xMoeda(E1_SDDECRE,E1_MOEDA,1,dDataBase)
                      If !_lRelat
                         If nAscan = 0
                            Aadd(aTotRec,{1,E1_MOEDA,SE1->E1_SALDO*(-1),If(E1_MOEDA>1,xMoeda(SE1->E1_SALDO,E1_MOEDA,1),SE1->E1_SALDO)*(-1)})
                         Else
                            aTotRec[nAscan][QTDETITULOS]--
                            aTotRec[nAscan][VALORTIT]   -= SE1->E1_SALDO
                            aTotRec[nAscan][VALORREAIS] -= If(E1_MOEDA>1,xMoeda(SE1->E1_SALDO,E1_MOEDA,1),SE1->E1_SALDO)
                         Endif
                      Endif	
                   Else	
                      aGet[2] += E1_VLCRUZ
                      aGet[3] += E1_SALDO
                      aGet[4] += E1_VALJUR
                      aGet[5] += xMoeda(E1_SDACRES,E1_MOEDA,1,dDataBase)
                      aGet[6] += xMoeda(E1_SDDECRE,E1_MOEDA,1,dDataBase)
                      If !_lRelat
                         If nAscan = 0
                            Aadd(aTotRec,{1,E1_MOEDA,SE1->E1_SALDO,If(E1_MOEDA>1,xMoeda(SE1->E1_SALDO,E1_MOEDA,1),SE1->E1_SALDO)})
                         Else
                            aTotRec[nAscan][QTDETITULOS]++
                            aTotRec[nAscan][VALORTIT]   += SE1->E1_SALDO
                            aTotRec[nAscan][VALORREAIS] += If(E1_MOEDA>1,xMoeda(SE1->E1_SALDO,E1_MOEDA,1),SE1->E1_SALDO)
                         Endif
                      Endif
                   Endif
                   DbSkip()
             Enddo
             If !_lRelat
                nTotalRec := 0
                aEval(aTotRec,{|e| nTotalRec+=e[VALORREAIS]})
                Aadd(aTotRec,{"","","TOTAL ====>>",nTotalRec})
                // Formata as colunas
                aEval(aTotRec,{|e| If(ValType(e[VALORTIT]) == "N", e[VALORTIT] := Transform(e[VALORTIT], Tm(e[VALORTIT], 16, nCasas)), Nil),;
                                   If(ValType(e[VALORREAIS]) == "N", e[VALORREAIS] := Transform(e[VALORREAIS], Tm(e[VALORREAIS], 16, nCasas)), Nil)})
             Endif										
             aGet[1] := TransForm(aGet[1],Tm(aGet[1],16,0))
             aGet[2] := TransForm(aGet[2],Tm(aGet[2],16,nCasas))
             aGet[3] := TransForm(aGet[3],Tm(aGet[3],16,nCasas))
             aGet[4] := TransForm(aGet[4],Tm(aGet[4],16,nCasas))
             aGet[5] := TransForm(aGet[5],Tm(aGet[5],16,nCasas))
             aGet[6] := TransForm(aGet[6],Tm(aGet[6],16,nCasas))
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³Titulos Recebidos                                                       ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        Case (nBrowse == 2)
             /********************************************************************************************************************************/
             /*** BLOCO ALTERADO EM 30/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
             /*DbSelectArea("SX3")
             DbSetOrder(2)
             DbSeek("E1_PREFIXO")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_NUM")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_PARCELA")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_TIPO")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             If !lRelat
                DbSeek("E1_MOEDA")
                aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
                aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
                aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
                DbSeek("E1_VALOR")
                aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
                aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
                aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             Endif	
             DbSeek("E1_VLCRUZ")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             For nCntFor := 1 To 4
                 DbSeek(If(nCntFor==1,	"E5_VLJUROS",;
                        If(nCntFor==2,	"E5_VLMULTA",;
                        If(nCntFor==3,	"E5_VLCORRE",;
                                        "E5_VLDESCO"))))
                 aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
                 aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
                 aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             Next	
             DbSeek("E5_VALOR")
             aadd(aHeader,{"Pago","E1_PAGO",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,"V" } )
             aadd(aStru ,{"E1_PAGO",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             If !lRelat
                DbSeek("E1_VALOR")
		        aadd(aHeader,{ "Vlr pago  moeda tit.","E1_VLMOED2",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		        aadd(aStru ,{"E1_VLMOED2",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		        DbSeek("E5_VLMOED2")
		        aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		        aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     Endif	
		     DbSeek("E1_EMISSAO")
		     aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		     aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     DbSeek("E1_VENCTO")
		     aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})		
		     DbSeek("E1_VENCREA")
		     aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		     aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     DbSeek("E5_DATA")
		     aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		     aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     DbSeek("E5_DTDISPO")
		     aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		     aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     DbSeek("E1_NATUREZ")
		     aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		     aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     DbSeek("E5_BANCO")
		     aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		     aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     DbSeek("E5_AGENCIA")
		     aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		     aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     DbSeek("E5_CONTA")
		     aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		     aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     DbSeek("E5_HISTOR")
		     aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		     aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     DbSeek("E5_MOTBX")
		     aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		     aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     If !lRelat
		        DbSeek("E5_CNABOC")
		        aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
                aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
                aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		     Endif
             DbSeek("E5_TIPODOC")
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})		
             aadd(aHeader,{"Atraso","E1_ATR","99999",5,0,"","","N","","V" } )
             aadd(aStru ,{"E1_ATR","N",5,0})
             DbSeek("E1_VALJUR")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aStru,{"XX_RECNO","N",12,0})
             SX3->(DbSetOrder(1))
             */
             DbSelectArea(_cAliasSX3)
             (_cAliasSX3)->( DbSetOrder( 2 ) )
             (_cAliasSX3)->( DbSeek( "E1_PREFIXO" ) )
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_NUM")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_PARCELA")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_TIPO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             If !_lRelat
                DbSeek("E1_MOEDA")
                aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
                aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
                aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
                DbSeek("E1_VALOR")
                aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
                aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
                aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             Endif	
             DbSeek("E1_VLCRUZ")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             For nCntFor := 1 To 4
                 DbSeek(If(nCntFor==1,	"E5_VLJUROS",;
                        If(nCntFor==2,	"E5_VLMULTA",;
                        If(nCntFor==3,	"E5_VLCORRE",;
                                        "E5_VLDESCO"))))
                 aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
                 aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
                 aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             Next	
             DbSeek("E5_VALOR")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), "E1_PAGO", (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { "E1_PAGO", (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             If !_lRelat
                DbSeek("E1_VALOR")
		        aadd( aHeader, { "Vlr pago  moeda tit.", "E1_VLMOED2", (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
		        aadd( aStru  , { "E1_VLMOED2", (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
		        DbSeek("E5_VLMOED2")
                aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
                aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
		     Endif	
		     DbSeek("E1_EMISSAO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
		     DbSeek("E1_VENCTO")
		     aadd( aQuery, { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
		     DbSeek("E1_VENCREA")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
		     DbSeek("E5_DATA")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
		     DbSeek("E5_DTDISPO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
		     DbSeek("E1_NATUREZ")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
		     DbSeek("E5_BANCO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
		     DbSeek("E5_AGENCIA")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
		     DbSeek("E5_CONTA")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
		     DbSeek("E5_HISTOR")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
		     DbSeek("E5_MOTBX")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
		     If !_lRelat
		        DbSeek("E5_CNABOC")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
		     Endif
             DbSeek("E5_TIPODOC")
             aadd( aQuery , { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )		
             aadd( aHeader, { "Atraso", "E1_ATR", "99999", 5, 0, "", "", "N", "", "V" } )
             aadd( aStru  , { "E1_ATR", "N" , 5, 0 } )
             DbSeek("E1_VALJUR")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd(aStru,{"XX_RECNO","N",12,0})
             (_cAliasSX3)->( DbSetOrder(1) )

             If (Select(cAlias) == 0)
                /********************************************************************************************************************************/
                /*** BLOCO ALTERADO EM 31/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
                //cArquivo := CriaTrab(,.F.)			
                //aadd(aAlias,{ cAlias , cArquivo })
                aadd(aStru,{"FLAG","L",01,0})
                //DbCreate(cArquivo,aStru)
                //DbUseArea(.T.,,cArquivo,cAlias,.F.,.F.)
                //IndRegua(cAlias,cArquivo,"E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO")
                oTempTbl01 := FWTemporaryTable():New( cAlias )
                oTempTbl01:SetFields( aStru )
                oTempTbl01:AddIndex( "cInd01", { "E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO" } )
                oTempTbl01:AddIndex( "cInd02", { "E1_VENCREA" } )
                oTempTbl01:Create()
                cArquivo := oTempTbl01:GetRealName()
                aadd(aAlias,{ cAlias , cArquivo })
                /********************************************************************************************************************************/
                #IFDEF TOP
                       If (TcSrvType()!="AS/400")
                          cQuery := ""
                          aEval(aQuery,{|x| cQuery += ","+AllTrim(x[1])})
                          cQuery := "SELECT "+SubStr(cQuery,2)+",SE5.R_E_C_N_O_ SE5RECNO "
                          cQuery += "FROM "+RetSqlName("SE1")+" SE1 WITH (NOLOCK),"
                          cQuery +=         RetSqlName("SE5")+" SE5 WITH (NOLOCK) "
                          cQuery += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
                          cQuery +=       "SE1.E1_CLIENTE='"+SA1->A1_COD+"' AND "
                          cQuery +=       "SE1.E1_LOJA='"+SA1->A1_LOJA+"' AND "
                          cQuery +=       "SE1.E1_EMISSAO>='"+Dtos(aParam[1])+"' AND "
                          cQuery +=       "SE1.E1_EMISSAO<='"+Dtos(aParam[2])+"' AND "
                          cQuery +=       "SE1.E1_VENCREA>='"+Dtos(aParam[3])+"' AND "
                          cQuery +=       "SE1.E1_VENCREA<='"+Dtos(aParam[4])+"' AND "
                          If (aParam[5] == 2)
                             cQuery +=   "SE1.E1_TIPO<>'PR ' AND "
                          EndIf					
                          If cPaisLoc <> "BRA"
                             cQuery +=   "SE1.E1_TIPO<>'"+MVCHEQUE+"' AND "					
                          Endif
                          If aParam[8] == 2
                             cQuery += " SE1.E1_FATURA IN('"+Space(Len(SE1->E1_FATURA))+"','NOTFAT') AND "
                          Endif
                          cQuery +=       "SE1.E1_PREFIXO>='"+aParam[6]+"' AND "
                          cQuery +=       "SE1.E1_PREFIXO<='"+aParam[7]+"' AND "
                          If mv_par09 == 2
                             cQuery += "( SE1.E1_NUMLIQ ='"+Space(Len(SE1->E1_NUMLIQ))+"' OR "
                             cQuery += "( SE1.E1_NUMLIQ <>'"+Space(Len(SE1->E1_NUMLIQ))+"' AND "
                             cQuery += " SE1.E1_TIPOLIQ ='"+Space(Len(SE1->E1_TIPOLIQ))+"')) AND "
                          Endif
                          cQuery +=		"SE1.E1_TIPO NOT LIKE '__-' AND "
                          cQuery +=		"SE1.E1_TIPO NOT IN ('RA ','PA ','"+MV_CRNEG+"','"+MV_CPNEG+"') AND "
                          cQuery +=		"SE1.D_E_L_E_T_<>'*' AND "
                          cQuery +=     "SE5.E5_FILIAL='"+xFilial("SE5")+"' AND "
                          cQuery +=		"SE5.E5_NATUREZ=SE1.E1_NATUREZ AND "
                          cQuery +=		"SE5.E5_PREFIXO=SE1.E1_PREFIXO AND "
                          cQuery +=		"SE5.E5_NUMERO=SE1.E1_NUM AND "
                          cQuery +=		"SE5.E5_PARCELA=SE1.E1_PARCELA AND "
                          cQuery +=		"SE5.E5_TIPO=SE1.E1_TIPO AND "
                          cQuery +=		"SE5.E5_CLIFOR=SE1.E1_CLIENTE AND "
                          cQuery +=		"SE5.E5_LOJA=SE1.E1_LOJA AND "
                          cQuery +=		"SE5.E5_RECPAG='R' AND "
                          cQuery +=		"SE5.E5_SITUACA<>'C' AND "
                          cQuery +=		"SE5.D_E_L_E_T_<>'*' AND NOT EXISTS ("
                          cQuery += "SELECT A.E5_NUMERO "
                          cQuery += "FROM "+RetSqlName("SE5")+" A WITH (NOLOCK) "
                          cQuery += "WHERE A.E5_FILIAL='"+xFilial("SE5")+"' AND "
                          cQuery +=		"A.E5_NATUREZ=SE5.E5_NATUREZ AND "
                          cQuery +=		"A.E5_PREFIXO=SE5.E5_PREFIXO AND "
                          cQuery +=		"A.E5_NUMERO=SE5.E5_NUMERO AND "
                          cQuery +=		"A.E5_PARCELA=SE5.E5_PARCELA AND "
                          cQuery +=		"A.E5_TIPO=SE5.E5_TIPO AND "
                          cQuery +=		"A.E5_CLIFOR=SE5.E5_CLIFOR AND "
                          cQuery +=		"A.E5_LOJA=SE5.E5_LOJA AND "
                          cQuery +=		"A.E5_SEQ=SE5.E5_SEQ AND "
                          cQuery +=		"A.E5_TIPODOC='ES' AND "
                          cQuery +=		"A.E5_RECPAG<>'R' AND "
                          cQuery +=		"A.D_E_L_E_T_<>'*')"
                          //cQuery := ChangeQuery(cQuery)
                          cQry   := cArquivo+"A"
                          dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)
                          aEval(aQuery,{|x| If(x[2]!="C",TcSetField(cQry,x[1],x[2],x[3],x[4]),Nil)})

                          DbSelectArea(cQry)
                          bWhile    := {|| !Eof() }
                          bFiltro   := {|| (cQry)->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" }
                          cAnterior := ""
                          While (Eval(bWhile))				
                                If (Eval(bFiltro))
                                   DbSelectArea(cAlias)
                                   DbSetOrder(1)
                                   RecLock(cAlias,.T.)
                                      For nCntFor := 1 To Len(aStru)
                                          Do Case
                                             Case (AllTrim(aStru[nCntFor][1])=="E1_PAGO")
                                                  If ((cQry)->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$")
                                                     (cAlias)->E1_PAGO += (cQry)->E5_VALOR
                                                  EndIf
                                             Case (AllTrim(aStru[nCntFor][1])=="E1_VLMOED2" ) .And. !_lRelat
                                                  If ((cQry)->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$")
                                                     (cAlias)->E1_VLMOED2 := If((cQry)->E1_MOEDA > 1, (cQry)->E5_VLMOED2, (cQry)->E5_VALOR)
                                                  EndIf	
                                             Case (AllTrim(aStru[nCntFor][1])=="E1_SALDO2")
                                                  If ((cQry)->(E1_TIPO)	$ MVABATIM)
                                                     (cAlias)->E1_SALDO2 -= nTotAbat
                                                  Else
                                                     (cAlias)->E1_SALDO2 += (cQry)->(E1_SALDO)
                                                     (cAlias)->E1_SALDO  += (cAlias)->E1_SDACRES - (cAlias)->E1_SDDECRE
                                                  EndIf
                                                  If (!lQuery)
                                                     (cAlias)->E1_SALDO2 -= nTotAbat
                                                  EndIf		
                                             Case (AllTrim(aStru[nCntFor][1])=="E1_VLCRUZ")
                                                  If ((cQry)->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$")
                                                     If cAnterior != (cQry)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
                                                        (cAlias)->E1_VLCRUZ := (cQry)->E1_VLCRUZ
                                                        cAnterior := (cQry)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
                                                     Endif
                                                  EndIf										
                                             Case (AllTrim(aStru[nCntFor][1])=="E1_ATR")
                                                  If (cQry)->E5_DATA > DataValida((cQry)->E1_VENCTO,.T.)
                                                     (cAlias)->E1_ATR := (cQry)->E5_DATA - (cQry)->E1_VENCTO
                                                  Else
                                                     (cAlias)->E1_ATR := (cQry)->E5_DATA - DataValida((cQry)->E1_VENCTO,.T.)
                                                  Endif
                                             Case ( AllTrim(aStru[nCntFor][1])=="XX_RECNO" )
                                                  (cAlias)->XX_RECNO := (cQry)->SE5RECNO
                                             Case ( AllTrim(aStru[nCntFor][1])=="FLAG" )
                                             OtherWise
                                                  (cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))
                                          EndCase
                                      Next nCntFor
                                   (cAlias)->(MsUnLock())
                                EndIf
                                DbSelectArea(cQry)
                                DbSkip()				
                          EndDo
                          DbSelectArea(cQry)
                          DbCloseArea()
                       Else
                #ENDIF
                DbSelectArea("SE1")
                DbSetOrder(2)
                DbSeek(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA)
                bWhile := {|| !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL;
                                     .And. SA1->A1_COD    == SE1->E1_CLIENTE;
                                     .And. SA1->A1_LOJA   == SE1->E1_LOJA }
                bFiltro:= {|| SubStr(SE1->E1_TIPO,3,1)!="-" .And.;
                              SE1->E1_EMISSAO >= aParam[1] .And.;
                              SE1->E1_EMISSAO <= aParam[2] .And.;
                              SE1->E1_VENCREA >= aParam[3] .And.;
                              SE1->E1_VENCREA <= aParam[4] .And.;
                              If(aParam[5]==2,SE1->E1_TIPO!="PR ",.T.) .And.;
                              SE1->E1_PREFIXO >= aParam[6] .And.;
                              SE1->E1_PREFIXO <= aParam[7] .And.;
                              IIf(cPaisLoc == "BRA",.T.,SE1->E1_TIPO<>MVCHEQUE) .And.;
                              If(!Empty(SE1->E1_FATURA) .And. Substr(SE1->E1_FATURA,1,6) != "NOTFAT",aParam[8]==1, .T.).AND.;
                              IIF(mv_par09 == 2, Empty(SE1->E1_NUMLIQ) .OR. (!Empty(SE1->E1_NUMLIQ) .And. Empty(SE1->E1_TIPOLIQ)),.T.)}
                While (Eval(bWhile))
                      If (Eval(bFiltro))
                         DbSelectArea("SE5")
                         DbSetOrder(4)
                         DbSeek(xFilial("SE5")+SE1->E1_NATUREZ+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
                         While (!Eof() .And. xFilial("SE5") == SE5->E5_FILIAL;
                                       .And. SE1->E1_NATUREZ == SE5->E5_NATUREZ;
                                       .And. SE1->E1_PREFIXO == SE5->E5_PREFIXO;
                                       .And. SE1->E1_NUM == SE5->E5_NUMERO;
                                       .And. SE1->E1_PARCELA == SE5->E5_PARCELA;
                                       .And. SE1->E1_TIPO == SE5->E5_TIPO )

                               If ((!SE5->E5_TIPO $ "RA /PA /"+MV_CRNEG+"/"+MV_CPNEG) .And. !TemBxCanc() .and. ;
                                  SE5->E5_SITUACA <> "C" .And. SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$")
                                  RecLock(cAlias,.T.)
                                     For nCntFor := 1 To Len(aStru)
                                         Do Case
                                            Case ( AllTrim(aStru[nCntFor][1])=="E1_PAGO" )
                                                 If (SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$")
                                                    (cAlias)->E1_PAGO += SE5->E5_VALOR
                                                 EndIf
                                            Case (AllTrim(aStru[nCntFor][1])=="E1_VLMOED2") .And. !_lRelat
                                                 If (SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$")
                                                    (cAlias)->E1_VLMOED2 := If(SE1->E1_MOEDA > 1, SE5->E5_VLMOED2, SE5->E5_VALOR)
                                                 EndIf	
                                            Case (AllTrim(aStru[nCntFor][1])=="E1_VLCRUZ")
                                                 If (SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$")
                                                    If cAnterior != SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
                                                       (cAlias)->E1_VLCRUZ := SE1->E1_VLCRUZ
                                                       cAnterior := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
                                                    Endif
                                                 EndIf												
                                            Case (AllTrim(aStru[nCntFor][1])=="E1_ATR")
                                                 If SE5->E5_DATA > DataValida(SE1->E1_VENCTO,.T.)
                                                    (cAlias)->E1_ATR := SE5->E5_DATA - SE1->E1_VENCTO
                                                 Else
                                                    (cAlias)->E1_ATR := SE5->E5_DATA - DataValida(SE1->E1_VENCTO,.T.)
                                                 Endif
                                            Case (AllTrim(aStru[nCntFor][1])=="XX_RECNO")
                                                 (cAlias)->XX_RECNO := SE5->(RecNo())
                                            Case ("E5_"$AllTrim(aStru[nCntFor][1]))
                                                 (cAlias)->(FieldPut(nCntFor,SE5->(FieldGet(FieldPos(aStru[nCntFor][1])))))
                                            Case (AllTrim(aStru[nCntFor][1])=="FLAG")
                                            OtherWise
                                                 (cAlias)->(FieldPut(nCntFor,SE1->(FieldGet(FieldPos(aStru[nCntFor][1])))))
                                         EndCase
                                     Next nCntFor
                                  (cAlias)->(MsUnLock())
                               EndIf
                               DbSelectArea("SE5")
                               DbSkip()
                         EndDo
                      EndIf
                      DbSelectArea("SE1")
                      DbSkip()					
                EndDo
                #IFDEF TOP
                       EndIf
                #ENDIF
                DbSelectArea(cAlias)
                //LGS#20200131 - Adequação ao release 12.1.25 e posteriores
                //IndRegua(cAlias,cArquivo,"DTOS(E1_VENCREA)")
                DbSetOrder(2)
             EndIf
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³Totais da Consulta                                                      ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             aGet[1] := 0
             aGet[2] := 0
             aGet[3] := 0
             aTotPag := {{0,1,0,0}} // Totalizador de titulos recebidos por por moeda
             DbSelectArea(cAlias)
             DbGotop()
             fFINFUN_02(aGet, cAlias, aTotPag)  // Totais de Baixas
             If !_lRelat
                nTotalRec:=0
                aEval(aTotPag,{|e| nTotalRec+=e[VALORREAIS]})
                Aadd(aTotPag,{"","","Total ====>>",nTotalRec})
                // Formata as colunas
                aEval(aTotPag,{|e| If(ValType(e[VALORTIT]) == "N", e[VALORTIT] := Transform(e[VALORTIT], Tm(e[VALORTIT], 16, nCasas)), Nil),;
                                   If(ValType(e[VALORREAIS]) == "N", e[VALORREAIS] := Transform(e[VALORREAIS], Tm(e[VALORREAIS], 16, nCasas)), Nil)})
             Endif
             aGet[1] := TransForm(aGet[1],Tm(aGet[1],16,0))
             aGet[2] := TransForm(aGet[2],Tm(aGet[2],16,nCasas))
             aGet[3] := TransForm(aGet[3],Tm(aGet[3],16,nCasas))
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³Pedidos                                                                 ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        Case (nBrowse == 3)
             /********************************************************************************************************************************/
             /*** BLOCO ALTERADO EM 30/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
             /*
             DbSelectArea("SX3")
             DbSetOrder(2)
             DbSeek("C5_NUM")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("C5_EMISSAO")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("C6_VALOR")
             aadd(aHeader,{"Tot.Pedido","XX_SLDTOT",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{"XX_SLDTOT",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aHeader,{"Sld.Liberado","XX_SLDLIB",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{"XX_SLDLIB",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aHeader,{"Sld.Pedido","XX_SLDPED",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{"XX_SLDPED",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aStru,{"XX_RECNO","N",12,0})
             SX3->(dbSetOrder(1))
             */
             DbSelectArea( (_cAliasSX3) )
             (_cAliasSX3)->( DbSetOrder(2) )
             (_cAliasSX3)->( DbSeek("C5_NUM") )
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("C5_EMISSAO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("C6_VALOR")
             aadd( aHeader,{ "Tot.Pedido","XX_SLDTOT", (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru  ,{ "XX_SLDTOT", (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aHeader,{ "Sld.Liberado","XX_SLDLIB", (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru  ,{ "XX_SLDLIB", (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aHeader,{ "Sld.Pedido","XX_SLDPED", (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru  ,{ "XX_SLDPED", (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aStru  ,{ "XX_RECNO","N",12,0})
             (_cAliasSX3)->( dbSetOrder(1) )

             If (Select(cAlias) == 0)
                /********************************************************************************************************************************/
                /*** BLOCO ALTERADO EM 31/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
                //cArquivo := CriaTrab(,.F.)			
                //aadd(aAlias,{ cAlias , cArquivo })
                aadd(aStru,{"FLAG","L",01,0})
                //DbCreate(cArquivo,aStru)
                //DbUseArea(.T.,,cArquivo,cAlias,.F.,.F.)
                //IndRegua(cAlias,cArquivo,"C5_NUM")
                oTempTbl01 := FWTemporaryTable():New( cAlias )
                oTempTbl01:SetFields( aStru )
                oTempTbl01:AddIndex( "cInd01", { "C5_NUM" } )
                oTempTbl01:Create()
                cArquivo := oTempTbl01:GetRealName()
                aadd(aAlias,{ cAlias , cArquivo })
                /********************************************************************************************************************************/
                #IFDEF TOP
                       If (TcSrvType()!="AS/400")
                          lQuery := .T.
                          cQuery := "SELECT SC5.C5_NUM PEDIDO,"
                          cQuery += 		  "SC5.C5_EMISSAO EMISSAO,"
                          cQuery += 		  "SC5.C5_MOEDA MOEDA,"
                          cQuery += 		  "SC5.R_E_C_N_O_ SC5RECNO,"
                          cQuery += 		  "(C6_QTDVEN-C6_QTDEMP-C6_QTDENT) QTDVEN,"
                          cQuery +=	          "C6_PRCVEN PRCVEN,"
                          cQuery +=           "1 TIPO,"
                          cQuery +=           "C5_EMISSAO DATALIB," //NAO RETIRAR - POSTGRES
                          cQuery +=           "C6_BLQ BLCRED "		//NAO RETIRAR - POSTGRES
                          cQuery += "FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK),"
                          cQuery +=         RetSqlName("SC6")+" SC6 WITH (NOLOCK),"
                          cQuery +=         RetSqlName("SF4")+" SF4 WITH (NOLOCK) "
                          cQuery += "WHERE SC5.C5_FILIAL='"+xFilial("SC5")+"' AND "
                          cQuery += "      SC5.C5_CLIENTE='"+SA1->A1_COD+"' AND "
                          cQuery +=	"      SC5.C5_LOJACLI='"+SA1->A1_LOJA+"' AND "
                          cQuery +=	"      SC5.C5_TIPO NOT IN('D','B') AND "
                          cQuery +=	"      SC5.C5_EMISSAO >='"+Dtos(aParam[1])+"' AND "
                          cQuery +=	"      SC5.C5_EMISSAO <='"+Dtos(aParam[2])+"' AND "	
                          cQuery +=	"      SC5.D_E_L_E_T_<>'*' AND "
                          cQuery +=	"      SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
                          cQuery +=	"      SC6.C6_NUM=SC5.C5_NUM AND "
                          cQuery +=	"      SC6.C6_BLQ NOT IN('R ') AND "
                          If mv_par10 == 2 // nao considera pedidos com bloqueio
                             cQuery +=	"      SC6.C6_BLQ NOT IN('S ') AND "
                          Endif
                          cQuery +=		"(SC6.C6_QTDVEN-SC6.C6_QTDEMP-SC6.C6_QTDENT)>0 AND "
                          cQuery +=		"SC6.D_E_L_E_T_<>'*' AND "
                          cQuery +=		"SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
                          cQuery +=		"SF4.F4_CODIGO=SC6.C6_TES AND "
                          cQuery +=		"SF4.F4_DUPLIC='S' AND "
                          cQuery +=		"SF4.D_E_L_E_T_<>'*' "
                          cQuery += "UNION ALL "
                          cQuery += "SELECT C5_NUM PEDIDO,"
                          cQuery += "       C5_EMISSAO EMISSAO,"
                          cQuery += "       C5_MOEDA MOEDA,"
                          cQuery += "       SC5.R_E_C_N_O_ SC5RECNO,"					
                          cQuery += "       C9_QTDLIB QTDVEN,"
                          cQuery +=	"       C9_PRCVEN PRCVEN, "
                          cQuery += "       2 TIPO,"										
                          cQuery +=	"       C9_DATALIB DATALIB, "
                          cQuery += "       C9_BLCRED BLCRED "
                          cQuery += "FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK),"+RetSqlName("SC6")+" SC6 WITH (NOLOCK),"
                          cQuery +=         RetSqlName("SF4")+" SF4 WITH (NOLOCK),"+RetSqlName("SC9")+" SC9 WITH (NOLOCK) "
                          cQuery += "WHERE SC5.C5_FILIAL='"+xFilial("SC5")+"' AND "
                          cQuery += "      SC5.C5_CLIENTE='"+SA1->A1_COD+"' AND "
                          cQuery +=	"      SC5.C5_LOJACLI='"+SA1->A1_LOJA+"' AND "
                          cQuery +=	"      SC5.C5_TIPO NOT IN('D','B') AND "
                          cQuery +=	"      SC5.C5_EMISSAO >='"+Dtos(aParam[1])+"' AND "
                          cQuery +=	"      SC5.C5_EMISSAO <='"+Dtos(aParam[2])+"' AND "						
                          cQuery +=	"      SC5.D_E_L_E_T_<>'*' AND "
                          cQuery +=	"      SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
                          cQuery +=	"      SC6.C6_NUM=SC5.C5_NUM AND "
                          cQuery +=	"      SC6.D_E_L_E_T_<>'*' AND "
                          cQuery +=	"      SC6.C6_BLQ NOT IN('R ') AND "
                          If mv_par10 == 2 // nao considera pedidos com bloqueio
                             cQuery +=	"      SC6.C6_BLQ NOT IN('S ') AND "
                          Endif
                          cQuery +=	"      SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
                          cQuery +=	"      SF4.F4_CODIGO=SC6.C6_TES AND "
                          cQuery +=	"      SF4.F4_DUPLIC='S' AND "
                          cQuery += "      SF4.D_E_L_E_T_<>'*' AND "
                          cQuery +=	"      SC9.C9_FILIAL='"+xFilial("SC9")+"' AND "
                          cQuery +=	"      SC9.C9_PEDIDO=SC5.C5_NUM AND "
                          cQuery +=	"      SC9.C9_ITEM=SC6.C6_ITEM AND "
                          cQuery +=	"      SC9.C9_PRODUTO=SC6.C6_PRODUTO AND "		
                          cQuery +=	"      SC9.C9_NFISCAL='"+Space(Len(SC9->C9_NFISCAL))+"' AND "
                          cQuery +=	"      SC9.D_E_L_E_T_<>'*'"
                          //cQuery := ChangeQuery(cQuery)
                          cQry   := cArquivo+"A"
                          dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)
                          TcSetField(cQry,"EMISSAO","D")
                          TcSetField(cQry,"DATALIB","D")
                          TcSetField(cQry,"TIPO","N",1)
                          TcSetField(cQry,"SC5RECNO","N",12,0)
                          TcSetField(cQry,"QTDVEN","N",TamSx3("C6_QTDVEN")[1],TamSx3("C6_QTDVEN")[2])
                          TcSetField(cQry,"PRCVEN","N",TamSx3("C6_PRCVEN")[1],TamSx3("C9_PRCVEN")[2])
										
                          DbSelectArea(cQry)
                          bWhile := {|| !Eof() }
                          bFiltro:= {|| .T. }
                          While (Eval(bWhile))
                                If (Eval(bFiltro))
                                   DbSelectArea(cAlias)
                                   DbSetOrder(1)
                                   cChave := (cQry)->(PEDIDO)
                                   If (!dbSeek(cChave))
                                      RecLock(cAlias,.T.)
                                   Else
                                      RecLock(cAlias,.F.)
                                   EndIf
                                   If ((cQry)->TIPO == 1)
                                      (cAlias)->C5_NUM     := (cQry)->PEDIDO
                                      (cAlias)->C5_EMISSAO := (cQry)->EMISSAO
                                      (cAlias)->XX_SLDTOT  += xMoeda((cQry)->QTDVEN*(cQry)->PRCVEN,(cQry)->MOEDA,1,(cQry)->EMISSAO)
                                      (cAlias)->XX_SLDLIB  := 0
                                      (cAlias)->XX_SLDPED  := (cAlias)->XX_SLDTOT
                                   Else
                                      (cAlias)->C5_NUM     := (cQry)->PEDIDO
                                      (cAlias)->C5_EMISSAO := (cQry)->EMISSAO						
                                      If (Empty((cQry)->BLCRED))
                                         (cAlias)->XX_SLDLIB  += xMoeda((cQry)->QTDVEN*(cQry)->PRCVEN,(cQry)->MOEDA,1,(cQry)->DATALIB)
                                         (cAlias)->XX_SLDTOT  += xMoeda((cQry)->QTDVEN*(cQry)->PRCVEN,(cQry)->MOEDA,1,(cQry)->DATALIB)
                                      Else
                                         (cAlias)->XX_SLDTOT  += xMoeda((cQry)->QTDVEN*(cQry)->PRCVEN,(cQry)->MOEDA,1,(cQry)->DATALIB)
                                         (cAlias)->XX_SLDPED  += xMoeda((cQry)->QTDVEN*(cQry)->PRCVEN,(cQry)->MOEDA,1,(cQry)->DATALIB)
                                      EndIf
                                   EndIf
                                   (cAlias)->XX_RECNO := (cQry)->SC5RECNO
                                   (cAlias)->(MsUnLock())
                                EndIf
                                DbSelectArea(cQry)
                                DbSkip()				
                          EndDo
                          DbSelectArea(cQry)
                          DbCloseArea()			
                       Else
                #ENDIF
                DbSelectArea("SC5")
                DbSetOrder(3)
                DbSeek(xFilial("SC5")+SA1->A1_COD)
                While ( !Eof() .And. SC5->C5_FILIAL==xFilial("SC5") .And.;
                      SC5->C5_CLIENTE == SA1->A1_COD )
                      nSalPed := 0
                      nSalPedb:= 0
                      nSalPedL:= 0
                      nQtdPed := 0											
                      If (SC5->C5_LOJACLI == SA1->A1_LOJA .And. !(SC5->C5_TIPO $ "DB") .And. SC5->C5_EMISSAO >= aParam[1] .And. C5_EMISSAO <= aParam[2])
                         DbSelectArea("SC6")
                         DbSetOrder(1)
                         DbSeek(xFilial("SC6")+SC5->C5_NUM)
                         While (!Eof() .And. SC6->C6_FILIAL == xFilial('SC5') .And.;
                               SC6->C6_NUM == SC5->C5_NUM )
                               If (!AllTrim(SC6->C6_BLQ) $ "R"+If(mv_par10==2,"#S",""))
                                  DbSelectArea("SF4")
                                  DbSetOrder(1)
                                  DbSeek(cFilial+SC6->C6_TES)
                                  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                                  //³ Buscar Qtde no arquivo SC9 (itens liberados) p/ A1_SALPEDL³
                                  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                  DbSelectArea("SC9")
                                  DbSetOrder(2)
                                  DbSeek(xFilial("SC9")+SC6->C6_CLI+SC6->C6_LOJA+SC6->C6_NUM+SC6->C6_ITEM)
                                  If (SF4->F4_DUPLIC == "S")
                                     While (!Eof() .And. xFilial("SC9") == SC9->C9_FILIAL;
                                                   .And. SC6->C6_CLI == SC9->C9_CLIENTE;
                                                   .And. SC6->C6_LOJA == SC9->C9_LOJA;
                                                   .And. SC6->C6_NUM == SC9->C9_PEDIDO;
                                                   .And. SC6->C6_ITEM == SC9->C9_ITEM )
                                           If (Empty(C9_NFISCAL) .And. SC6->C6_PRODUTO==SC9->C9_PRODUTO)
                                              If (Empty(SC9->C9_BLCRED))
                                                 nSalpedl += xMoeda( SC9->C9_QTDLIB * SC9->C9_PRCVEN , SC5->C5_MOEDA , 1 , SC9->C9_DATALIB )
                                              Else
                                                 nSalpedb += xMoeda( SC9->C9_QTDLIB * SC9->C9_PRCVEN , SC5->C5_MOEDA , 1 , SC9->C9_DATALIB )
                                              EndIf
                                           EndIf
                                           DbSelectArea("SC9")
                                           DbSkip()
                                     EndDo
                                  Endif
                                  If (SF4->F4_DUPLIC == "S")
                                     nQtdPed := SC6->C6_QTDVEN - SC6->C6_QTDEMP - SC6->C6_QTDENT
                                     nQtdPed := IIf( nQtdPed < 0 , 0 , nQtdPed )
                                     nSalped += xMoeda( nQtdPed * SC6->C6_PRCVEN , SC5->C5_MOEDA , 1 , SC5->C5_EMISSAO )
                                  EndIf
                               EndIf
                               DbSelectArea("SC6")
                               DbSkip()
                         EndDo
                      EndIf
                      If (nSalped+nSalpedl+nSalpedb > 0)
                         RecLock(cAlias,.T.)
                            (cAlias)->C5_NUM     := SC5->C5_NUM
                            (cAlias)->C5_EMISSAO := SC5->C5_EMISSAO
                            (cAlias)->XX_SLDTOT  := nSalPed+nSalPedL+nSalPedb
                            (cAlias)->XX_SLDLIB  := nSalPedL
                            (cAlias)->XX_SLDPED  := nSalPed+nSalPedb
                            (cAlias)->XX_RECNO    := SC5->(RecNo())
                         MsUnlock()
                      EndIf
                      DbSelectArea("SC5")
                      DbSkip()
                EndDo
                #IfDef TOP
                       EndIf
                #Endif
             EndIf
             DbSelectArea(cAlias)
             DbGotop()
             aGet[1] := 0
             aGet[2] := 0
             aGet[3] := 0
             aGet[4] := 0
             dbEval({|| aGet[1]++,;
                        aGet[2]+=XX_SLDTOT,;
                        aGet[3]+=XX_SLDLIB,;
                        aGet[4]+=XX_SLDPED})

             aGet[1] := TransForm(aGet[1],Tm(aGet[1],16,0))
             aGet[2] := TransForm(aGet[2],Tm(aGet[2],16,nCasas))
             aGet[3] := TransForm(aGet[3],Tm(aGet[3],16,nCasas))
             aGet[4] := TransForm(aGet[4],Tm(aGet[3],16,nCasas))	
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³Notas Fiscais                                                           ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        Case (nBrowse == 4)
             /********************************************************************************************************************************/
             /*** BLOCO ALTERADO EM 30/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
             /*
             DbSelectArea("SX3")
             DbSetOrder(2)
             DbSeek("F2_SERIE")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("F2_DOC")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("F2_EMISSAO")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("F2_DUPL")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("F2_VALFAT")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})				
             DbSeek("F2_FRETE")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("F2_HORA")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("F2_TRANSP")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("A4_NREDUZ")
             aadd(aHeader,{ AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aStru,{"XX_RECNO","N",12,0})
             SX3->(dbSetOrder(1))
             */
             DbSelectArea(_cAliasSX3)
             (_cAliasSX3)->( DbSetOrder(2) )
             (_cAliasSX3)->( DbSeek("F2_SERIE") )
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("F2_DOC")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("F2_EMISSAO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("F2_DUPL")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("F2_VALFAT")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("F2_FRETE")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("F2_HORA")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("F2_TRANSP")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("A4_NREDUZ")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd(aStru,{"XX_RECNO","N",12,0})
             (_cAliasSX3)->(dbSetOrder(1))

             If (Select(cAlias) == 0)
                /********************************************************************************************************************************/
                /*** BLOCO ALTERADO EM 31/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
                //cArquivo := CriaTrab(,.F.)			
                //aadd(aAlias,{ cAlias , cArquivo })
                aadd(aStru,{"FLAG","L",01,0})
                //DbCreate(cArquivo,aStru)
                //DbUseArea(.T.,,cArquivo,cAlias,.F.,.F.)
                //IndRegua(cAlias,cArquivo,"DTOS(F2_EMISSAO)+F2_SERIE+F2_DOC")
                oTempTbl01 := FWTemporaryTable():New( cAlias )
                oTempTbl01:SetFields( aStru )
                oTempTbl01:AddIndex( "cInd01", { "DTOS(F2_EMISSAO)", "F2_SERIE", "F2_DOC" } )
                oTempTbl01:Create()
                cArquivo := oTempTbl01:GetRealName()
                aadd(aAlias,{ cAlias , cArquivo })
                /********************************************************************************************************************************/
                #IfDef TOP
                       If (TcSrvType()!="AS/400" .and. cDbMs!="POSTGRES")
                          cDbMs := UPPER(TcGetDb())
                          lQuery := .T.

                          cQuery := "SELECT SF2.F2_DOC F2_DOC,"
                          cQuery += "       SF2.F2_SERIE F2_SERIE,"
                          cQuery += "       SF2.F2_EMISSAO F2_EMISSAO,"
                          cQuery +=	"       SF2.F2_DUPL F2_DUPL,"
                          cQuery += "       SF2.F2_VALFAT F2_VALFAT, "
                          cQuery += "       SF2.F2_FRETE F2_FRETE, "
                          cQuery += "       SF2.F2_HORA F2_HORA, "
                          cQuery += "       SF2.F2_TRANSP F2_TRANSP, "
                          cQuery += "       SA4.A4_COD A4_COD, "
                          cQuery += "       SA4.A4_NREDUZ A4_NREDUZ, "
                          cQuery += "       SF2.R_E_C_N_O_ SF2RECNO "
                          cQuery += "FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "
                          If cDbMs == "INFORMIX"
                             cQuery += ", OUTER "+ RetSqlName("SA4") + " SA4 "
                          Else
                             cQuery += ", "+ RetSqlName("SA4") + " SA4 "
                          Endif
                          cQuery += "WHERE SF2.F2_FILIAL='"+xFilial("SF2")+"' AND "
                          cQuery += "      SF2.F2_CLIENTE='"+SA1->A1_COD+"' AND "
                          cQuery +=	"      SF2.F2_LOJA='"+SA1->A1_LOJA+"' AND "
                          cQuery +=	"      SF2.F2_TIPO NOT IN('D','B') AND "
                          cQuery +=	"      SF2.F2_EMISSAO>='"+DTOS(aParam[1])+"' AND "
                          cQuery +=	"      SF2.F2_EMISSAO<='"+DTOS(aParam[2])+"' AND "
                          cQuery +=	"      SF2.F2_VALFAT > 0 AND "
                          cQuery +=	"      SF2.D_E_L_E_T_<>'*'"
                          If cDbMs == "ORACLE"
                          cQuery += "  AND SF2.F2_TRANSP = SA4.A4_COD(+) "
                          ElseIf cDbMs == "INFORMIX"
                          cQuery += "  AND SF2.F2_TRANSP = SA4.A4_COD "
                          Else
                          cQuery += "  AND SF2.F2_TRANSP *= SA4.A4_COD "
                          Endif
                          //cQuery := ChangeQuery(cQuery)
                          cQry   := cArquivo+"A"
                          dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)
                          TcSetField(cQry,"F2_EMISSAO","D")
                          TcSetField(cQry,"F2_VALFAT","N",TamSx3("F2_VALFAT")[1],TamSx3("F2_VALFAT")[2])
                          TcSetField(cQry,"F2_FRETE","N",TamSx3("F2_FRETE")[1],TamSx3("F2_FRETE")[2])
                          TcSetField(cQry,"SF2RECNO","N",12,0)
                       Else
                #Endif
                cQry := "SF2"
                #IfDef TOP
                       EndIf
                #Endif
                aGet[1] := 0
                aGet[2] := 0
                DbSelectArea(cQry)
                If (!lQuery)
                   DbSetOrder(2)
                   DbSeek(xFilial("SF2")+SA1->A1_COD+SA1->A1_LOJA)
                   bWhile := {|| !Eof() .And. xFilial("SF2") == SF2->F2_FILIAL;
                                        .And. SA1->A1_COD == SF2->F2_CLIENTE;
                                        .And. SA1->A1_LOJA == SF2->F2_LOJA }
                   bFiltro:= {|| !SF2->F2_TIPO$"DB" .And.;
                                 SF2->F2_EMISSAO >= aParam[1] .And.;
                                 SF2->F2_EMISSAO <= aParam[2] }					
                Else
                   bWhile := {|| !Eof() }
                   bFiltro:= {|| .T. }
                EndIf			
                While (Eval(bWhile))
                      If (Eval(bFiltro))
                         If !lQuery
                            // Se nao for query, posiciona SA4 para obter o nome da transportadora
                            SA4->(MsSeek(xFilial("SA4")+SF2->F2_TRANSP))
                         Endif
                         RecLock(cAlias,.T.)
                            (cAlias)->F2_SERIE   := (cQry)->F2_SERIE
                            (cAlias)->F2_DOC     := (cQry)->F2_DOC
                            (cAlias)->F2_EMISSAO := (cQry)->F2_EMISSAO
                            (cAlias)->F2_DUPL    := (cQry)->F2_DUPL
                            (cAlias)->F2_VALFAT  := (cQry)->F2_VALFAT
                            (cAlias)->F2_FRETE   := (cQry)->F2_FRETE
                            (cAlias)->F2_HORA    := (cQry)->F2_HORA
                            (cAlias)->F2_TRANSP  := (cQry)->F2_TRANSP
                            (cAlias)->A4_NREDUZ  := If(lQuery,(cQry)->A4_NREDUZ,SA4->A4_NREDUZ)
                            (cAlias)->XX_RECNO   := If(lQuery,(cQry)->SF2RECNO,SF2->(RecNo()))
                            (cAlias)->(MsUnLock())
                      EndIf
                      DbSelectArea(cQry)
                      DbSkip()				
                EndDo
                If (lQuery)
                   DbSelectArea(cQry)
                   DbCloseArea()
                EndIf
             EndIf		
             aGet[1] := 0
             aGet[2] := 0
             DbSelectArea(cAlias)
             DbGotop()
             dbEval({|| aGet[1]++,aGet[2]+=F2_VALFAT})
             aGet[1] := TransForm(aGet[1],Tm(aGet[1],16,0))
             aGet[2] := TransForm(aGet[2],Tm(aGet[2],16,nCasas))			
        Case (nBrowse == 5)
             DEFINE MSDIALOG oCheq FROM   15,1 TO 150,272 TITLE OemToAnsi("Seleccion de parametros") PIXEL
                    @ 6 , 11 TO 60, 93 OF oCheq   LABEL Oemtoansi("Tipos de cheques a exhibir") PIXEL
                    @ 11, 13 RADIO oTipo VAR nTipo ;
                             PROMPT OemToAnsi("Pendientes"),OemToAnsi("Cobrados"),If(cPaisLoc == 'URU',OemToAnsi("Rechazado"),OemToAnsi("Negociados")),OemToAnsi("Todos");
                             OF oCheq PIXEL SIZE 75,12
                    DEFINE SBUTTON FROM 45, 100 TYPE 1 ACTION oCheq:End() ENABLE OF oCheq //11,132
             ACTIVATE MSDIALOG oCheq CENTERED
             Do case
                Case nTipo == 1
                     bTipo := { || (cQry)->E1_SALDO > 0 }
                Case nTipo == 2
                     bTipo := { || !((cQry)->E1_SITUACA $ " 0") .And. (cQry)->E1_SALDO == 0 }
                Case nTipo == 3
                     bTipo := { || (cQry)->E1_STATUS == "R" .And. (cQry)->E1_SITUACA $ " 0" .And. (cQry)->E1_SALDO == 0}
                Case nTipo == 4
                     bTipo := { || .T. }
             EndCase

             nMoeda := 1
             /********************************************************************************************************************************/
             /*** BLOCO ALTERADO EM 30/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
             /*
             DbSelectArea("SX3")
             DbSetOrder(2)
             DbSeek("E1_STATUS")
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aHeader,{AllTrim(SX3->X3_TITULO),"XX_ESTADO","@!",04,0,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru,{"XX_ESTADO","C",04,0})
             DbSeek("E1_PREFIXO")
             aadd(aHeader,{ AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_NUM")
             aadd(aHeader,{ AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_PARCELA")
             aadd(aHeader,{ AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_NUMNOTA")
             aadd(aHeader,{ AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_EMISSAO")
             aadd(aHeader,{ AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_VALOR")
             aadd(aHeader,{ AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_MOEDA")
             aadd(aHeader,{ AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_VLCRUZ")
             aadd(aHeader,{ AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_VENCREA")
             aadd(aHeader,{ AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_NATUREZ")
             aadd(aHeader,{ AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_PORTADO")
             aadd(aHeader,{ AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_BCOCHQ")
             aadd(aHeader,{ AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_HIST")
             aadd(aHeader,{ AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
             aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             DbSeek("E1_SITUACA")
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             aadd(aHeader,{"Situacao","X5_DESCRI","@!",25,0,"","","C","SX5","" } )
             aadd(aStru,{"X5_DESCRI","C",25,0})
             aadd(aStru,{"XX_RECNO" ,"N",12,0})
             aadd(aStru,{"XX_VALOR" ,"N",18,0})
             DbSeek("E1_SALDO")
             aadd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
             SX3->(dbSetOrder(1))
             */
             DbSelectArea("SX3")
             DbSetOrder(2)
             DbSeek("E1_STATUS")
             aadd( aQuery , { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aHeader, { AllTrim( (_cAliasSX3)->( X3_TITULO ) ), "XX_ESTADO", "@!", 04, 0, (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru  , { "XX_ESTADO","C",04,0})
             DbSeek("E1_PREFIXO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_NUM")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_PARCELA")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_NUMNOTA")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_EMISSAO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_VALOR")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_MOEDA")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_VLCRUZ")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_VENCREA")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_NATUREZ")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_PORTADO")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_BCOCHQ")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_HIST")
             aadd( aHeader, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), (_cAliasSX3)->( X3_CAMPO ), (_cAliasSX3)->( X3_PICTURE ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_VALID ), (_cAliasSX3)->( X3_USADO ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_ARQUIVO ), (_cAliasSX3)->( X3_CONTEXT ) } )
             aadd( aStru ,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aQuery,  { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             DbSeek("E1_SITUACA")
             aadd( aQuery , { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             aadd( aHeader, {"Situacao" ,"X5_DESCRI","@!",25,0,"","","C","SX5","" } )
             aadd( aStru  , {"X5_DESCRI","C",25,0})
             aadd( aStru  , {"XX_RECNO" ,"N",12,0})
             aadd( aStru  , {"XX_VALOR" ,"N",18,0})
             DbSeek("E1_SALDO")
             aadd( aQuery , { AllTrim( (_cAliasSX3)->( X3_CAMPO ) ), (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ) } )
             (_cAliasSX3)->(dbSetOrder(1))

             /********************************************************************************************************************************/
             /*** BLOCO ALTERADO EM 31/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
             //cArquivo := CriaTrab(,.F.)			
             //If !lExibe
             //   aadd(aAlias,{ cAlias , cArquivo })
             //Endif
             aadd(aStru,{"FLAG","L",01,0})
             //DbCreate(cArquivo,aStru)
             //DbUseArea(.T.,,cArquivo,cAlias,.F.,.F.)
             //IndRegua(cAlias,cArquivo,"E1_PREFIXO+E1_NUM+E1_PARCELA")
             oTempTbl01 := FWTemporaryTable():New( cAlias )
             oTempTbl01:SetFields( aStru )
             oTempTbl01:AddIndex( "cInd01", { "E1_PREFIXO", "E1_NUM", "E1_PARCELA" } )
             oTempTbl01:Create()
             If !lExibe
                cArquivo := oTempTbl01:GetRealName()
                aadd(aAlias,{ cAlias , cArquivo })
             Endif
             /********************************************************************************************************************************/
             #IFDEF TOP
                    If (TcSrvType()!="AS/400")
                       lQuery := .T.
                       cQuery := ""
                       aEval(aQuery,{|x| cQuery += ","+AllTrim(x[1])})
                       cQuery := "SELECT "+SubStr(cQuery,2)
                       cQuery +=         ",SE1.R_E_C_N_O_ SE1RECNO"
                       cQuery +=         ",SX5.X5_DESCRI "
                       cQuery += "FROM "+RetSqlName("SE1")+" SE1 WITH (NOLOCK),"
                       cQuery +=         RetSqlName("SX5")+" SX5 WITH (NOLOCK) "
                       cQuery += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
                       cQuery += "      SE1.E1_CLIENTE='"+SA1->A1_COD+"' AND "
                       cQuery += "      SE1.E1_LOJA='"+SA1->A1_LOJA+"' AND "
                       cQuery += "      SE1.E1_EMISSAO>='"+Dtos(aParam[1])+"' AND "
                       cQuery += "      SE1.E1_EMISSAO<='"+Dtos(aParam[2])+"' AND "
                       cQuery += "      SE1.E1_VENCREA>='"+Dtos(aParam[3])+"' AND "
                       cQuery += "      SE1.E1_VENCREA<='"+Dtos(aParam[4])+"' AND "
                       cQuery += "      SE1.E1_TIPO    ='CH ' AND "					
                       cQuery += "      SE1.E1_PREFIXO>='"+aParam[6]+"' AND "
                       cQuery += "      SE1.E1_PREFIXO<='"+aParam[7]+"' AND "
                       cQuery += "      SE1.E1_MOEDA  = "+Alltrim(STR(nMoeda))+" AND "
                       cQuery += "      SE1.D_E_L_E_T_<>'*' AND "
                       cQuery += "      SX5.X5_FILIAL='"+xFilial("SX5")+"' AND "
                       cQuery += "      SX5.X5_TABELA='07' AND "
                       cQuery += "      SX5.X5_CHAVE=SE1.E1_SITUACA AND "
                       cQuery += "      SX5.D_E_L_E_T_<>'*' "
                       //cQuery := ChangeQuery(cQuery)
                       cQry   := cArquivo+"A"
                       MsAguarde({ || dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)},"Seleccionado registros en el servidor")

                       aEval(aQuery,{|x| If(x[2]!="C",TcSetField(cQry,x[1],x[2],x[3],x[4]),Nil)})
                    Else
             #ENDIF
             cQry := "SE1"
             #IFDEF TOP
                    EndIf
             #ENDIF
             DbSelectArea(cQry)
             If (!lQuery)
                DbSetOrder(2)
                DbSeek(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA)
                bWhile := {|| !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL;
                                     .And. SA1->A1_COD    == SE1->E1_CLIENTE;
                                     .And. SA1->A1_LOJA   == SE1->E1_LOJA   }
                bFiltro:= {|| SE1->E1_EMISSAO >= aParam[1] .And.;
                              SE1->E1_EMISSAO <= aParam[2] .And.;
                              SE1->E1_VENCREA >= aParam[3] .And.;
                              SE1->E1_VENCREA <= aParam[4] .And.;
                              SE1->E1_TIPO    == MVCHEQUE  .And.;
                              SE1->E1_PREFIXO >= aParam[6] .And.;
                              SE1->E1_PREFIXO <= aParam[7]}
             Else
                bWhile := {|| !Eof() }
                bFiltro:= {|| .T. }
             EndIf			
             While (Eval(bWhile))
                   If (Eval(bFiltro)) .And. Eval(bTipo)
                      If (!lQuery)
                         //LGS#20200131 - Adequação ao release 12.1.25 e posteriores
                         //DbSelectArea("SX5")
                         //DbSetOrder(1)
                         //MsSeek(xFilial("SX5")+"07"+SE1->E1_SITUACA)
                         For _nX := 1 To Len( _aSX5Situ )
                             If Upper( Alltrim( _aSX5Situ[_nX][2] ) ) == Upper( Alltrim( SE1->E1_SITUACA ) )
                                _cSX5Desc := Alltrim( _aSX5Situ[_nX][4] )
                             Endif
                         Next
                      EndIf
                      DbSelectArea(cAlias)
                      DbSetOrder(1)
                      cChave := (cQry)->(E1_PREFIXO)+(cQry)->(E1_NUM)+(cQry)->(E1_PARCELA)
                      If (!dbSeek(cChave))
                         RecLock(cAlias,.T.)						
                      Else
                         RecLock(cAlias,.F.)
                      EndIf
                      For nCntFor := 1 To Len(aStru)
                          Do Case
                             Case (AllTrim(aStru[nCntFor][1])=="X5_DESCRI")
                                  If (lQuery)
                                     (cAlias)->( X5_DESCRI ) := (cQry)->( X5_DESCRI )
                                  Else
                                     //(cAlias)->( X5_DESCRI ) := SX5->X5_DESCRI
                                     (cAlias)->( X5_DESCRI ) := _cSX5Desc
                                  EndIf
                             Case (AllTrim(aStru[nCntFor][1])=="XX_ESTADO")
                                  If lQuery
                                     If (cQry)->E1_SALDO > 0
                                        (cAlias)->XX_ESTADO := "PEND"
                                     ElseIf (cQry)->E1_STATUS == "R" .And. (cQry)->E1_SITUACA == "0"
                                            (cAlias)->XX_ESTADO := If(cPaisLoc == 'URU',"STR0089","STR0067") //"NEGO"
                                     Else									
                                        (cAlias)->XX_ESTADO := "COBR"
                                     Endif
                                  Else
                                     If SE1->E1_SALDO > 0
                                        (cAlias)->XX_ESTADO := "PEND"
                                     ElseIf SE1->E1_STATUS == "R" .And. SE1->E1_SITUACA == "0"
                                            (cAlias)->XX_ESTADO := IIf(cPaisLoc == "URU","STR0089","STR0067") //"NEGO"
                                     Else									
                                        (cAlias)->XX_ESTADO := "COBR"
                                     Endif
                                  Endif
                             Case (AllTrim(aStru[nCntFor][1])=="XX_RECNO")
                                  If (lQuery)
                                     (cAlias)->XX_RECNO := (cQry)->SE1RECNO
                                  Else
                                     (cAlias)->XX_RECNO := SE1->(RecNo())
                                  EndIf
                             Case (AllTrim(aStru[nCntFor][1])=="XX_VALOR")
                                  If (lQuery)
                                     (cAlias)->XX_VALOR := IIf(nMoeda  > 1, xMoeda((cQry)->E1_VALOR,(cQry)->E1_MOEDA,nMoeda),(cQry)->E1_VLCRUZ)
                                  Else
                                     (cAlias)->XX_VALOR :=  IIf(nMoeda  > 1, xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,nMoeda),SE1->E1_VLCRUZ)
                                  EndIf
                             Case (AllTrim(aStru[nCntFor][1])=="FLAG")
                             OtherWise							
                                  (cAlias)->(FieldPut(nCntFor,(cQry)->(FieldGet(FieldPos(aStru[nCntFor][1])))))
                          EndCase
                      Next nCntFor
                      DbSelectArea(cAlias)
                      MsUnLock()
                   EndIf
                   DbSelectArea(cQry)
                   DbSkip()				
             EndDo
             If (lQuery)
                DbSelectArea(cQry)
                DbCloseArea()
             EndIf
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³Totais da Consulta                                                      ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             DbSelectArea(cAlias)
             DbGotop()
             aGet	:=	{0,0,0,0,0,0}
             While !EOF()
                   Do Case
                      Case XX_ESTADO	==	"PEND"
                           aGet[1]	+=	(cAlias)->XX_VALOR
                           aGet[4]++
                      Case XX_ESTADO	==	If(cPaisLoc == 'URU',"STR0089","STR0067") //"NEGO"
                           aGet[2]	+=	(cAlias)->XX_VALOR
                           aGet[5]++
                      Case XX_ESTADO	==	"COBR"
                           aGet[3]	+=	(cAlias)->XX_VALOR
                           aGet[6]++
                   EndCase				 	
                   DbSkip()
             Enddo
             If lExibe
                aGet[1] := TransForm(aGet[1],Tm(aGet[1],16,MsDecimais(nMoeda))) + " (" +Alltrim(STR(aGet[4]))+")"
                aGet[2] := TransForm(aGet[2],Tm(aGet[2],16,MsDecimais(nMoeda))) + " (" +Alltrim(STR(aGet[5]))+")"
                aGet[3] := TransForm(aGet[3],Tm(aGet[3],16,MsDecimais(nMoeda))) + " (" +Alltrim(STR(aGet[6]))+")"
                aGet[4] := "Valores en "+GetMv("MV_MOEDA1")
             EndIf
        OtherWise
             Alert("Não Implementado")
             lExibe := .f.
     EndCase	
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Exibe os dados Gerados                                                  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If (lExibe)
        DbSelectArea(cAlias)
        DbGotop()
        If (!Eof())
           aObjects := {}
           AAdd( aObjects, { 100, 35,  .t., .f., .t. } )
           AAdd( aObjects, { 100, 100 , .t., .t. } )
           AAdd( aObjects, { 100, 50 , .t., .f. } )
           aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
           aPosObj1 := MsObjSize( aInfo, aObjects)

           DEFINE FONT oBold    NAME "Arial" SIZE 0, -12 BOLD
           DEFINE MSDIALOG oDlg FROM	aSize[7],00 TO aSize[6],aSize[5] TITLE cCadastro OF oMainWnd PIXEL
                  @ aPosObj1[1,1], aPosObj1[1,2] MSPANEL oScrPanel PROMPT "" SIZE aPosObj1[1,3],aPosObj1[1,4] OF oDlg LOWERED
                  @ 04,004 SAY OemToAnsi("Codigo") SIZE 025,07          OF oScrPanel PIXEL
                  @ 12,004 SAY SA1->A1_COD  SIZE 060,09  OF oScrPanel PIXEL FONT oBold
                  @ 04,067 SAY OemToAnsi("Loja") SIZE 020,07          OF oScrPanel PIXEL
                  @ 12,067 SAY SA1->A1_LOJA SIZE 021,09 OF oScrPanel PIXEL FONT oBold
                  @ 04,090 SAY OemToAnsi("Nome") SIZE 025,07 OF oScrPanel PIXEL
                  @ 12,090 SAY SA1->A1_NOME SIZE 165,09 OF oScrPanel PIXEL FONT oBold
                  oGetDb:=MsGetDB():New(aPosObj1[2,1],aPosObj1[2,2],aPosObj1[2,3],aPosObj1[2,4],2,"",,,.F.,,,.F.,,cAlias,,,,,,.T.)
                  oGetdb:lDeleta:=NIL
                  DbSelectArea(cAlias)
                  DbGotop()
                  @ aPosObj1[3,1]+5,005 SAY aSay[1] SIZE 025,07 OF oDlg PIXEL
                  @ aPosObj1[3,1]+5,175 SAY aSay[2] SIZE 025,07 OF oDlg PIXEL
                  @ aPosObj1[3,1]+16,005 SAY aSay[3] SIZE 025,07 OF oDlg PIXEL
                  @ aPosObj1[3,1]+16,175 SAY aSay[4] SIZE 025,07 OF oDlg PIXEL
                  @ aPosObj1[3,1]+27,005 SAY aSay[5] SIZE 025,07 OF oDlg PIXEL
                  @ aPosObj1[3,1]+27,175 SAY aSay[6] SIZE 025,07 OF oDlg PIXEL
                  @ aPosObj1[3,1]+5,045 SAY aGet[1] SIZE 060,07 OF oDlg PIXEL
                  @ aPosObj1[3,1]+5,215 SAY aGet[2] SIZE 060,07 OF oDlg PIXEL
                  @ aPosObj1[3,1]+16,045 SAY aGet[3] SIZE 060,07 OF oDlg PIXEL
                  @ aPosObj1[3,1]+16,215 SAY aGet[4] SIZE 060,07 OF oDlg PIXEL
                  @ aPosObj1[3,1]+27,045 SAY aGet[5] SIZE 060,07 OF oDlg PIXEL
                  @ aPosObj1[3,1]+27,215 SAY aGet[6] SIZE 060,07 OF oDlg PIXEL

                  DEFINE SBUTTON 		FROM 04,aPosObj1[1,3]-If(nBrowse <= 2,60,30) TYPE  1  ENABLE OF oScrPanel ACTION ( oDlg:End() )
                  // Exibe o botao de distribuicao por moedas, apenas na consulta de titulos
                  // em aberto e recebidos
                  If nBrowse <= 2
                     SButton():New( 7, aPosObj1[1,3]-27, 18,{||fFINAUX_01(If(nBrowse==1,aTotRec,aTotPag),oDlg)},oDlg,.T., "Consulta distribuição por moedas")
                  Endif
                  If nBrowse == 1 .and. lAcsCre
                     DEFINE SBUTTON oAlt   FROM 19,aPosObj1[1,3]-60 TYPE 10 ENABLE OF oScrPanel 
                     oAlt:lAutDisable := .t.
                     oAlt:bAction := bAltera
                     oAlt:cToolTip := OemToAnsi("Altera Histórico")
                  Endif
                  DEFINE SBUTTON oBtn 	FROM 19,aPosObj1[1,3]-30 TYPE 15 ENABLE OF oScrPanel
                  oBtn:lAutDisable := .F.
                  If ( bVisual != Nil )
                     oBtn:bAction := bVisual
                  Else
                     oBtn:SetDisable(.T.)
                  EndIf
           ACTIVATE MSDIALOG oDlg
        Else
           Help(" ",1,"REGNOIS")	
        EndIf
        If nBrowse == 5
           (cAlias)->(dbCloseArea()) ;Ferase(cArquivo+GetDBExtension());Ferase(cArquivo+OrdBagExt())
           oTempTbl01:Delete()
        Endif
     EndIf
     DbSelectArea(_cAliasSX3)
     DbCloseArea()
     RestArea(aAreaSC5)
     RestArea(aAreaSC6)
     RestArea(aAreaSC9)
     RestArea(aAreaSF4)
     RestArea(aArea)
Return(aHeader)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³fFINAUX_01³ Autor ³ Luís Gustavo de Souza ³ Data ³13.05.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe os totais a pagar a recebidos por moeda               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aTotais- Matriz de totais por moeda                         ³±±
±±³          ³oDlg   - Objeto dialog que sera exibida a tela da consulta  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fFINAUX_01(aTotais, oDlg)
       Local aCab := {"Qtde. Titulos",;
                      "Moeda",;
                      "Valor na moeda",;
                      "Valor em R$"}
       //Local oDlgMoeda
       Local oLbx					
       DEFINE DIALOG oDlg FROM 0,0 TO 20,70 TITLE "Distribuição por moeda" OF oDlg
              oLbx := RDListBox(.5, .4, 270, 130, aTotais, aCab)
              oLbx:LNOHSCROLL := .T.
              oLbx:LHSCROLL := .F.
       ACTIVATE MSDIALOG oDlg CENTERED
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³fFINFUN_02³ Autor ³ Luís Gustavo de Souza ³ Data ³13.05.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Somat¢ria dos titulos recebidos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aGet - Array que guardar  o nro de titulos, valores princi- ³±±
±±³          ³       pais e valor da baixa                                ³±±
±±³          ³cAlias - Alias do arquivo tempor rio                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fFINFUN_02(aGet, cAlias, aTotPag)
       Local cTitAnt := ""
       Local nAscan

       While !Eof()
             aGet[1]++
             // Impressao do relatorio nao existe E1_MOEDA no temporario
             If FieldPos("E1_MOEDA") > 0
                nAscan := Ascan(aTotPag,{|e| e[MOEDATIT] == E1_MOEDA})
                If nAscan = 0
                   Aadd(aTotPag,{1,E1_MOEDA,If(E1_MOEDA>1,E1_VLMOED2,E1_PAGO),E1_PAGO})
                Else
                   aTotPag[nAscan][QTDETITULOS]++
                   aTotPag[nAscan][VALORTIT]   += If(E1_MOEDA>1,E1_VLMOED2,E1_PAGO)
                   aTotPag[nAscan][VALORREAIS] += E1_PAGO
                Endif
             Endif
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Somo o valor do titulo apenas uma vez em caso de baixa parcial ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If (cAlias)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) != cTitAnt
                aGet[2]+= E1_VLCRUZ
                cTitAnt := (cAlias)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
             Endif
             aGet[3] += E1_PAGO
             DbSkip()
       Enddo
Return (aGet)
                	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fFINFUN_03³ Autor ³Luís Gustavo de Souza  ³ Data ³13/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de Visualizacao dos Itens individuais da Posicao de  ³±±
±±³          ³Cliente.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³                    						     			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1		: Recno do Arquivo principal                      ³±±
±±³          ³ExpN2		: nBrowse                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Brasilux Tintas Técnicas Ltda.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fFINFUN_03(nRecno, nBrowse)
       Local aArea := GetArea()
       Local aAreaSE1 := SE1->(GetArea())
       Local aAreaSE5 := SE5->(GetArea())
       Local aAreaSC5 := SC5->(GetArea())
       Local aSavAhead:= If(Type("aHeader")=="A",aHeader,{})
       Local aSavAcol := If(Type("aCols")=="A",aCols,{})
       Local nSavN    := If(Type("N")=="N",N,0)

       Do Case
          Case (nBrowse == 1)
               SE1->(MsGoto(nRecno))
               SE1->(AxVisual("SE1",nRecNo,2))
          Case (nBrowse == 2)
               SE5->(MsGoto(nRecno))
               SE5->(AxVisual("SE5",nRecNo,2))
          Case (nBrowse == 3)
               SC5->(MsGoto(nRecno))		
               SC5->(a410Visual("SC5",nRecNo,2))
          Case (nBrowse == 4)
               SF2->(MsGoto(nRecno))
               SF2->(Mc090Visual("SF2",nRecNo,2))
       EndCase
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Restaura a Integridade dos Dados                                        ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       aHeader := aSavAHead
       aCols   := aSavACol
       N       := nSavN

       RestArea(aAreaSC5)
       RestArea(aAreaSE5)
       RestArea(aAreaSE1)
       RestArea(aArea)
Return(.T.)	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fFINFUN_04³ Autor ³Luís Gustavo de Souza  ³ Data ³13/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de alteração do itens individuais da posição de cli- ³±±
±±³          ³ente.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³                    						     			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1		: Recno do Arquivo principal                      ³±±
±±³          ³ExpN2		: nBrowse                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Brasilux Tintas Técnicas Ltda.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fFINFUN_04(nRecno, nBrowse)
       Local aArea := GetArea()
       Local aAreaSE1 := SE1->(GetArea())
       Local aAreaSE5 := SE5->(GetArea())
       Local aAreaSC5 := SC5->(GetArea())
       Local aSavAhead:= If(Type("aHeader")=="A",aHeader,{})
       Local aSavAcol := If(Type("aCols")=="A",aCols,{})
       Local nSavN    := If(Type("N")=="N",N,0)
       Local aAcho    := {} //Todos os Campos
       Local aCpos    := {} //Campos a alterar
       Local nOpc     := 7
       Do Case
          Case (nBrowse == 1)
               /********************************************************************************************************************************/
               /*** BLOCO ALTERADO EM 30/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
               /*
               DbSelectArea("SX3")
               DbSetOrder(1)
               DbSeek("SE1")
               While !EOF() .And. (X3_ARQUIVO == "SE1")
                     If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL 
		                AADD(aAcho, X3_CAMPO)
                     Endif	  
                     DbSkip()
               EndDo
               */
               DbSelectArea(_cAliasSX3)
               (_cAliasSX3)->( DbSetOrder(1) )
               (_cAliasSX3)->( DbSeek("SE1") )
               While !EOF() .And. ( (_cAliasSX3)->( X3_ARQUIVO ) == "SE1")
                     If X3USO( (_cAliasSX3)->( X3_USADO ) ) .and. cNivel >= (_cAliasSX3)->( X3_NIVEL ) 
		                AADD(aAcho, (_cAliasSX3)->( X3_CAMPO ) )
                     Endif	  
                     DbSkip()
               EndDo
               
               aadd(aCpos, "E1_HIST")
               SE1->(MsGoto(nRecno))
               AxAltera("SE1", nRecNo, nOpc, ,aCpos,,,)
       EndCase
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Restaura a Integridade dos Dados                                        ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       aHeader := aSavAHead
       aCols   := aSavACol
       N       := nSavN

       RestArea(aAreaSC5)
       RestArea(aAreaSE5)
       RestArea(aAreaSE1)
       RestArea(aArea)
Return(.T.)
