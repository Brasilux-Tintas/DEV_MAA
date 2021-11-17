#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.CH"
/*
________________________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-------------------------------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ IMPET001 ¦ Autor ¦ Innovare Solucoes   ¦ Data ¦ 19/10/15                       ¦¦¦
¦¦+----------+--------------------------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Markbrowse para Liberação automatica de Pedidos                                ¦¦¦
¦¦¦Retorno   ¦ 			                                                                      ¦¦¦                                                                       
¦¦+----------+------------------------------------------------------------------------------- ¦¦¦
¦¦¦ Uso      ¦ TecPolpa 							                                          ¦¦¦
¦¦+----------+--------------------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function IMPET001()
     Processa({||xIMPET001()},"Imprimindo Etiquetas...") 

     Aviso("IMPET001.PRW","Impressão finalizou!",{"OK"})
Return 

Static Function xIMPET001
       Local cPergunt :="IMPET001"
       Local cQuery:=""
       Local cLinha:= Chr(13) + Chr(10) 
       Local nQtde:= 1

       Pergunte( cPergunt ) 

       cMsg     := "Segue prosseguir com a impressão das etiquetas?"
       cCaption := "Confirmar"

       If !ApMsgNoYes(cMsg, cCaption)        
          Return
       EndIf
 
       /*cQuery:="SELECT * FROM "+RetSqlName("SB8")+" "+cLinha
         cQuery+="WHERE B8_FILIAL='"+xFilial("SB8")+"'	"+cLinha
         cQuery+="  AND D_E_L_E_T_=' '"+cLinha
         cQuery+="  AND B8_PRODUTO  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'	"+cLinha
         cQuery+="  AND B8_LOCAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'	"+cLinha
         IF !Empty(MV_PAR05)
            cQuery+="	AND B8_LOTECTL ='"+MV_PAR05+"' " +cLinha
         EndIf
         cQuery+=" AND B8_SALDO > 0	" */

         cQuery := "SELECT SB8.B8_DTVALID, SB8.B8_SALDO, SB1.B1_COD, SB1.B1_DESC, ROUND( SB8.B8_POTENCI, 0) QTDPORVOL, SB1.B1_RASTRO, SB8.B8_SALDO / ROUND( SB8.B8_POTENCI, 0) QTD_ETIQUETA, SB8.B8_LOTECTL, SB8.B8_LOCAL " + cLinha
         cQuery += "FROM " + RetSqlName("SB1") + " SB1 " + cLinha
         cQuery += "INNER JOIN " + RetSqlName("SB8") + " SB8 ON SB8.B8_FILIAL = '" + xFilial("SB8") + "' AND SB1.B1_COD = SB8.B8_PRODUTO AND SB8.D_E_L_E_T_ = ' ' " + cLinha
         cQuery += " " + cLinha
         cQuery += "WHERE SB1.D_E_L_E_T_     = ' ' " + cLinha
         cQuery += "  AND SB1.B1_FILIAL      = '" + xFilial("SB1") + "' " + cLinha
         cQuery += "  AND SB8.B8_POTENCI    <> 0 "  + cLinha
         cQuery += "  AND SB1.B1_RASTRO      = 'L' " + cLinha
         cQuery += "  AND SB1.B1_COD   BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + cLinha
         cQuery += "  AND SB8.B8_LOCAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + cLinha
         IF !Empty( MV_PAR05 )
            cQuery += "  AND SB8.B8_LOTECTL = '" + MV_PAR05 + "' " +cLinha
         EndIf
         cQuery += "  AND SB8.B8_SALDO > 0 "
         cQuery += "UNION ALL "+cLinha
         cQuery += "SELECT SB9.B9_DATA, SB9.B9_QINI, SB1.B1_COD, SB1.B1_DESC, SB9.B9_XQTDVOL QTDPORVOL, SB1.B1_RASTRO, SB9.B9_QINI / SB9.B9_XQTDVOL QTD_ETIQUETA, ' ' SB8.B8_LOTECTL, SB9.B9_LOCAL " + cLinha
         cQuery += "FROM " + RetSqlName("SB1") + " SB1 " + cLinha
         cQuery += "INNER JOIN " + RetSqlName("SB9") + " SB9 ON SB9.B9_FILIAL = '" + xFilial("SB9") + "' AND SB1.B1_COD = SB9.B9_COD AND SB9.D_E_L_E_T_ = ' ' " + cLinha
         cQuery += " " + cLinha
         cQuery += "WHERE SB1.D_E_L_E_T_ = ' ' " + cLinha
         cQuery += "  AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' " + cLinha
         cQuery += "  AND SB1.B1_RASTRO NOT IN ('L') " + cLinha
         cQuery += "  AND SB9.B9_XQTDVOL <> 0 " + cLinha
         cQuery += "  AND SB1.B1_COD   BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + cLinha
         cQuery += "  AND SB9.B9_LOCAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + cLinha
         cQuery += "  AND SB9.B9_QINI > 0 "

         IF SELECT("TMPSB8") > 0
            TMPSB8->(dbCloseArea())
         EndIf
         TCQUERY cQuery NEW ALIAS "TMPSB8"

         If TMPSB8->(EOF())
            MsgAlert("Não foram encontrados Produtos com saldos! Reveja os parametros!","IMPET001.PRW")
            Return  Nil
         EndIf

         ProcRegua( SELECT("TMPSB8") )

         TMPSB8->( dbgotop() )
         While !( TMPSB8->( EOF() ) )
               While nQtde <= MV_PAR06
                     //aviso("teste","Teste",{"OK"})	
                     /** aSvPar
                         1 - Nota Fiscal
                         2 - Serie
                         3 - Cliente
                         4 - Loja        **/

                     aSvPar := { TMPSB8->B1_COD, '', '', '', '', '', '' }
                     /** aLbx
                         1  - Nota
                         2  - Produto
                         3  - Quantide
                         4  - Quantidade Etiqueta
                         5  - Resto?-
                         6  - quantide produtos por volume
                         7  - Lote
                         8  - Nun serie?
                         9  - Alias Orig
                         10 - Recno
                         11 - Lote?
                         12 - local?
                         13 - Data de validade?  **/
                     //TMPSB8->QTDPORVOL
                     //aLbx:={{.T.,TMPSB8->B1_COD,AllTrim(Str(TMPSB8->B8_SALDO)),AllTrim(Str(TMPSB8->QTD_ETIQUETA)),;
                     //'0',AllTrim(Str(TMPSB8->QTD_ETIQUETA)),TMPSB8->B8_LOCAL,TMPSB8->B8_LOTECTL,' ',STOD(TMPSB8->B8_DTVALID),' ',' ','SB1',11,,,,}}
                     aLbx := { { .T., TMPSB8->B1_COD, AllTrim( Str( TMPSB8->B8_SALDO ) ), AllTrim( Str( TMPSB8->B8_SALDO ) ),;
                                 '0', AllTrim( Str( TMPSB8->QTD_ETIQUETA ) ), TMPSB8->B8_LOCAL, TMPSB8->B8_LOTECTL, ' ', STOD( TMPSB8->B8_DTVALID ), ' ', ' ', 'SB1', 11, , , , } }
				
                     //XImprime(aSvPar,aLbx)	 //LGS#20200207 - Adequação de release 12.1.25 e posteriores
                     XImprime( aSvPar )
                     nQtde += 1
                     IncProc()
               End
               nQtde:= 1
               TMPSB8->(dbSkip())
         End
Return Nil

/*/{Protheus.doc} xImprime
//TODO Chamada da impressão da etiqueta.
@author 
@since 24/03/2020
@version 1.0
@return ${return}, ${return_description}
@param cOrigem, characters, descricao
@type function
/*/
Static Function xImprime(cOrigem)
       Local cLocImp     := "000001" //MV_PAR01
       Local nX
       //Local nY
       Local cProduto
       Local cLocal      := Space( TamSX3("B2_LOCAL")[1] )
       Local nQtde
       Local nQE   
       Local nQVol
       Local nResto
       Local cAliasOri
       Local nRecno    
       Local cLote
       Local cSLote      := Space( TamSX3("B8_NUMLOTE")[1] )
       Local cNumSerie
       Local dValid
       //Local nMv
       Local cNotaFisc   := ""
       Local cSerieNFisc := ""
       Local cForn       := ""
       Local cLojaForn   := ""

       //If ! CBYesNo("Confirma a Impressao de Etiquetas","Aviso")  //"Confirma a Impressao de Etiquetas"###"Aviso"
       //   Return .f.
       //EndIf

       If ! CB5SetImp(cLocImp)  
          MsgAlert( "Local de Impressão " + cLocImp + " nao Encontrado!" ) //"Local de Impressão "###" nao Encontrado!"
          Return .f.
       Endif

       //For nMv := 1 To Len( aSvPar )
       //    &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aSvPar[ nMv ]
       //Next nMv

       cNotaFisc 		:= aSvPar[1]
       cSerieNFisc 	:= aSvPar[2]
       cForn 			:= aSvPar[3]
       cLojaForn 		:= aSvPar[4]

       SB1->(DbSetOrder(1))
       For nX := 1 to Len(aLbx)  // val(aLbx[1,4]) //Len(aLbx)  
           //nX := 1 

           If !aLbx[nx,1]
              Loop
           EndIf
           cProduto := aLbx[nx,2]
           nQtde    := Val( aLbx[nx,3] )
           If Empty(nQtde)
              Loop
           EndIf
           nQE      := Val( aLbx[nx,4] )
           nResto   := Val( aLbx[nx,5] )
           nQVol    := Val( aLbx[nx,6] )
           If nResto > 0
              nQVol--
           EndIf
           cLote     := aLbx[nx,8] 
           cNumSerie := aLbx[nx,9]
           cAliasOri := aLbx[nx,13] 
           nRecno    := aLbx[nx,14]
           If aLbx[nx,11] <> Nil
              cSLote := aLbx[nx,11]
           EndIf
           If aLbx[nx,7] <> Nil
              cLocal := aLbx[nx,7]
           Endif
           If aLbx[nx,10] <> Nil
              dValid := aLbx[nx,10]
           EndIf

           (cAliasOri)->(DbGoto(nRecno)) //posiciona na tabela de origem da informação

           SB1->(DbSeek(xFilial('SB1')+cProduto))
           If nQVol > 0
              ExecBlock( "IMG01", , , { nQE   , , , nQVol, cNotaFisc, cSerieNFisc, cForn, cLojaForn, cLocal, , , cLote, cSLote, dValid, , , , cNumSerie } )     
           EndIf
           If nResto > 0
              ExecBlock( "IMG01", , , { nResto, , ,     1, cNotaFisc, cNumSerie  , cForn, cLojaForn, cLocal, , , cLote, cSLote, dValid, , , , cNumSerie } )
           EndIf
       Next
       MSCBCLOSEPRINTER()             
Return .t. 