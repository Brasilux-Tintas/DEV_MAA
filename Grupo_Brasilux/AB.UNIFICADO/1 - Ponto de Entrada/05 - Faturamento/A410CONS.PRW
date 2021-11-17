#include 'TOTVS.CH'
#include 'topconn.CH'

User Function A410CONS()
     Local _aButtons := {}

     If FWCodEmp() <> '11'
        /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
        ±±ºPrograma  ³ A410CONS ºAutor  ³ Luís G. de Souza   º Data ³  14/09/05   º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºDesc.     ³ Ponto de Entrada para adicionar botão no pedido de vendas. º±±
        ±±º          ³                                                            º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
        ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
             
        aadd( _aButtons, { 'OBJETIVO', { || U_fHisPed(1) }, 'Histórico do Pedido'} ) //Botão de histórico de pedido
     Else
        /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
        ±±ºPrograma  ³A410CONS  ºAutor  ³Tiago Lucio/Chau    º Data ³  19/04/16   º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºDesc.     ³ Ponto de entrada para inclusao de botoes no Pedido         º±±
        ±±º          ³ * incluido botão para importar os itens do TA              º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºUso       ³ AP                                                         º±±
        ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

        aadd( _aButtons, { 'PEDIDO'  , { || U_incta4()   }, 'aItens do TA'       } )
        aadd( _aButtons, { 'PEDIDO'  , { || U_IncPallet()}, 'Inc. Paletes'       } ) //Dyego
     Endif
     
Return(_aButtons)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetIteTA   ºAutor  ³Tiago Lucio/Chaus  º Data ³  19/04/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para validar se o pedido é de beneficiamento e trazerº±±
±±º          ³os intes de MP do TA                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function GetIteTA()
     Local  _aArea   := getArea()
     Local _cProd    := ""
     Local _cLocal   := ""
     Local _cOper    := _cCodCF    := ""
     Local _nQuant   := 0, _nQtdOP := 0, _nPreco := 0, _nSalAnt := 0
     Local _cLote    := ""
     Local i         := 0
     Local _cQuery   := ""
     Private _aItens := {}, _aAux := {}, _aNFItem := {}
     Private _nRecno := SC6->( LASTREC( ) )
     Private _nItem  := Len( aCols )

     //DYEGO ** corrige o sequencial dos itens
     For i := 1 to Len( aCols )
         _nItem := Val( aCols[ i, GdFieldPos( "C6_ITEM", aHeader ) ] )
     Next i
     // fim DYEGO

     //Varre os itens do Pedido de Vendas
     //For i := 1 to Len(aCols)
     //For i := N to N //PEGA SOMENTE A LINHA DO ACOLS SELECIONADA
     i := N
     If Posicione( "SB1", 1, xFILIAL( "SB1" ) + ( aCols[ i, GdFieldPos( "C6_PRODUTO", aHeader ) ] ), "B1_TIPO" ) $ "PA/TA"
        _cProd    := ( aCols[ i, GdFieldPos( "C6_PRODUTO", aHeader ) ] )
        _cLocal   := ( aCols[ i, GdFieldPos( "C6_LOCAL"  , aHeader ) ] )
        _nQuant   := ( aCols[ i, GdFieldPos( "C6_QTDVEN" , aHeader ) ] )
        _cLote    := ( aCols[ i, GdFieldPos( "C6_LOTECTL", aHeader ) ] )
        _cOpeTA   := ( aCols[ i, GdFieldPos( "C6_OPER"   , aHeader ) ] )
        _cTesTA   := ( aCols[ i, GdFieldPos( "C6_TES"    , aHeader ) ] )
        _cCFTA    := ( aCols[ i, GdFieldPos( "C6_CF"     , aHeader ) ] )
        _cEntrega := ( aCols[ i, GdFieldPos( "C6_ENTREG" , aHeader ) ] )
        _cBloquei := ( aCols[ i, GdFieldPos( "C6_BLOQUEI", aHeader ) ] )
       
        aADD( _aAux, { ( aCols[ i, GdFieldPos( "C6_ITEM", aHeader ) ] ), ( aCols[ i, GdFieldPos( "C6_TES", aHeader ) ] ) } )
        
        DbSelectArea( "SB1" )
        SB1->( dbSetorder(1) )
        SB1->( dbSeek( xFilial("SB1") + _cProd ) )
        If Empty( _cLote )
           _cControl := Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_RASTRO")
           If Alltrim(_cControl)=='L'
              Aviso( "A410CONS.PRW", "O campo 'Lote de Terceiros' não foi inforamdo para o produto controlado por " + ;
                                     "Lote '" + Alltrim(_cProd) + "'. Favor informar o lote! ", { "OK" } )
              Return Nil
           EndIf
        EndIf
        DbSelectArea("SB8")
        SB8->( dbSetOrder( 3 ) ) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL
        SB8->( dbSeek( xFilial("SB8") + _cProd + _cLocal + _cLote ) )
        If SB8->B8_SALDO < _nQuant
           Aviso( "A410CONS.PRW", "A quantidade informada para o produto é maior que a quantidade disponivel no lote.", { "OK" } )
           Return Nil
        EndIf
        _aItens := BuscaSD3( _cLote,_cProd )
     Else
  		Aviso("A410CONS.PRW","Produto selecionado não é um Produto Acabado. Favor selecione um produto valido e execute a rotina novamente!",{"OK"})
        Return Nil
     EndIf
     //Next i
     If Len(_aItens) == 0
        RestArea(_aArea)
        Return Nil
     EndIf
     DbSelectArea("SB1")

     For i:=1 To Len(_aItens) // 4INCMSUCLJ01
         DbSelectArea("SB1")
         SB1->(dbSetorder(1))
         SB1->(dbSeek(xFilial("SB1")+_aItens[i][1]))
         aAux := {}
         aAux:=aclone(acols[N])

         dbSelectArea("SD5")
         SD5->(dbSetOrder(2)) //D5_FILIAL+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_NUMLOTE+D5_NUMSEQ
         SD5->(dbSeek(xFilial("SD5")+_cProd))
         While !(SD5->(eof())) .And. xFilial("SD5")==SD5->D5_FILIAL .And. AllTrim(_cProd)==AllTrim(SD5->D5_PRODUTO)// ;
               //.And. _cLocal==SD5->D5_LOCAL .And. _cLote==SD5->D5_LOTECTL
               if SD5->D5_ORIGLAN =="001" .And. SD5->D5_LOTECTL==_cLote //Entrada
                  _nQtdOP:=SD5->D5_QUANT
               EndIf
               SD5->(DBSKIP())
         End
         dbSelectArea("SD5")
         SD5->(dbSetOrder(2)) //D5_FILIAL+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_NUMLOTE+D5_NUMSEQ
         SD5->(dbSeek(xFilial("SD5")+_cProd))
         While !(SD5->(eof())) .And. xFilial("SD5")==SD5->D5_FILIAL .And. AllTrim(_cProd)==AllTrim(SD5->D5_PRODUTO)// ;
               //.And. _cLocal==SD5->D5_LOCAL .And. _cLote==SD5->D5_LOTECTL
               If SD5->D5_ORIGLAN =="001" .And. SD5->D5_LOTECTL==_cLote //Entrada
                  _nQtdOP:=SD5->D5_QUANT
               EndIf
               SD5->(DBSKIP())
         End
         _nqtd := ( _nQuant * ( _aItens[i][3] ) ) / _nQtdOP //Calcula quantidade apontada x quantidade do pedido
         //IF (SB1->B1_TIPO $ 'TA/PA/PI/TI')   //Busca da tabela de preço
         //   _nPreco:= BuscaPrc(M->C5_TABELA,M->C5_TIPO, _aItens[i][1],_aItens[i][2], M->C5_CLIENTE, M->C5_LOJACLI,_nqtd)
         //Else //Busca da nota de entrada
         _nPreco:=0

        dbSelectArea("SA1")
        SA1->(dbSetorder(1))
        SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))

        dbSelectArea("SA2")
        SA2->(dbSetorder(3))
        SA2->(dbSeek(xFilial("SA2")+SA1->A1_CGC))

        If SUBSTR(_aItens[i][1],1,1) $ '1.2' //Produto da TecPolpa
           _cOper  := "RV"
           _cCodCF := "5124"
           _cQuery := "	SELECT B2_FILIAL, B2_COD, B2_QATU, B2_CM1 "
           _cQuery += "	FROM " + RetSqlName("SB2")+" "
           _cQuery += "	WHERE B2_COD='"+ _aItens[i][1]+"' "
           _cQuery += "		AND D_E_L_E_T_=' ' "
           _cQuery += "	 	AND B2_FILIAL='"+xFILIAL("SB2")+"' "
           If SELECT("TMPSB2") >1
              TMPSB2->(dbcloseArea())
           EndIf

           TcQuery _cQuery New Alias "TMPSB2"

           If TMPSB2->(EOF())
              //Aviso("A410CONS.PRW","Não existe saldo suficiente do produto  "+Alltrim(_aItens[i][1])+;
              //                     " no armazem "+AllTrim(SB1->B1_LOCPAD)+" !",{"OK"})
           Else
              If TMPSB2->B2_QATU <_nqtd
                 //Aviso("A410CONS.PRW","Não existe saldo suficiente do produto  "+Alltrim(_aItens[i][1])+;
                 //				  " no armazem "+AllTrim(SB1->B1_LOCPAD)+" !",{"OK"})
              Else
                 // alterado por Dyego 09/06/16
                 _nPreco    :=  TMPSB2->B2_CM1
                 _cCliFor 	:=	M->C5_CLIENTE
                 _cLoja		:=	M->C5_LOJACLI
                 _cProduto	:=  _aItens[i][1]
                 //_nPreco  :=  u_RMarkup(_nPreco, _cCliFor, _cLoja, _cProduto)
                 //Fim alteração
                 //_aSaldo:=CalcEst(_aItens[i][1],SB1->B1_LOCPAD,dDataBase)

                 _nItem := _nItem + 1
                 aAux[ GdFieldPos( "C6_ITEM"   , aHeader ) ] := Strzero(_nItem,2) //Item
                 aAux[ GdFieldPos( "C6_PRODUTO", aHeader ) ] := _aItens[i][1]		   //Produto
                 aAux[ GdFieldPos( "C6_UM"     , aHeader ) ] := SB1->B1_UM              //UNidade de Medida
                 aAux[ GdFieldPos( "C6_QTDVEN" , aHeader ) ] := Round(_nqtd,3)			//Quantidade
                 aAux[ GdFieldPos( "C6_PRCVEN" , aHeader ) ] := _nPreco						//Preço de venda
                 aAux[ GdFieldPos( "C6_VALOR"  , aHeader ) ] := Round(Round(_nqtd,3) * _nPreco,2)	//Tota.l
                 aAux[ GdFieldPos( "C6_QTDLIB" , aHeader ) ] := Round(_nqtd,3)             	//Quantidade Liberada
                 //aAux[8] :=   0
                 aAux[ GdFieldPos( "C6_OPER"   , aHeader ) ] := _cOper				//Operação
                 aAux[ GdFieldPos( "C6_TES"    , aHeader ) ] := getTes(_cOper, M->C5_CLIENTE,  M->C5_LOJACLI,_aItens[i][1] )//TES (Gatilho da TES inteligente
                 aAux[ GdFieldPos( "C6_LOCAL"  , aHeader ) ] := SB1->B1_LOCPAD	//Armazem
                 aAux[ GdFieldPos( "C6_DESCRI" , aHeader ) ] := SB1->B1_DESC 			//Descrição
                 //aAux[GdFieldPos(/*"C6_LOTECTL"*/"C6_XLOTERC",aHeader)] := _aItens[i][5]			//LoteX
                 aAux[ GdFieldPos( "C6_LOTECTL", aHeader ) ] := " "		//Lotec
                 aAux[ GdFieldPos( "C6_NFORI"  , aHeader ) ] := " "		//Lotec
                 aAux[ GdFieldPos( "C6_SERIORI", aHeader ) ] := " "	//Lotec
                 aAux[ GdFieldPos( "C6_IDENTB6", aHeader ) ] := " " //Lotec
                 aAux[ GdFieldPos( "C6_ITEMORI", aHeader ) ] := " "
                 aAux[ GdFieldPos( "C6_PRUNIT" , aHeader ) ] := 0//Preço Lista
                 aAux[ GdFieldPos( "C6_DTVALID", aHeader ) ] := '  /  /    '
                 aAux[ GdFieldPos( "C6_CF"     , aHeader ) ] := _cCodCF
                 aAux[ GdFieldPos( "C6_CLASFIS", aHeader ) ] := CodSitTri()
                 aAux[ GdFieldPos( "C6_NUMOP"  , aHeader ) ] := _aItens[i][4]
                 aAux[ GdFieldPos( "C6_ITEMOP" , aHeader ) ] := _aItens[i][5]
                 //[GdFieldPos("C6_ENTREG",aHeader)]  	:= _cEntrega
                 //aAux[GdFieldPos("C6_CODLAN",aHeader)]  		:= SF4->F4_CODLAN
                 _nRecno   := _nRecno +1
                 aAux[104] := _nRecno

                 ///Corrigi a TES do PA/TA
                 aCols[N][GdFieldPos("C6_OPER",aHeader)]:= _cOpeTA
                 aCols[N][GdFieldPos("C6_TES",aHeader)]:= _cTesTA
                 aCols[N][GdFieldPos("C6_CF",aHeader)]:=  _cCFTA
                 aadd(acols, aAux )
              EndIf
			EndIf
         Else
            _cQuery:="	SELECT  B6_PRUNIT, B6_SALDO, B6_DOC, B6_SERIE,  B6_CLIFOR, B6_LOJA,B6_IDENT, B6_TES, B6_TIPO, B6_TIPO "
            _cQuery+="		FROM " + RetSqlName("SDH")+" SDH "
            _cQuery+="		LEFT JOIN " + RetSqlName("SB6")+" SB6 ON B6_FILIAL = DH_FILIAL AND  "
            _cQuery+="			DH_IDENTNF = B6_IDENT AND  "
            _cQuery+="			SDH.D_E_L_E_T_=SB6.D_E_L_E_T_ "
            _cQuery+="			WHERE SDH.D_E_L_E_T_=' ' "
            _cQuery+="				AND SDH.DH_FILIAL='"+xFILIAL("SDH")+"' "
            _cQuery+="					AND SDH.DH_TPMOV='1' "
            _cQuery+="					AND DH_CLIENTE='"+M->C5_CLIENTE+"' "
            _cQuery+="					AND DH_LOJACLI='"+M->C5_LOJACLI+"' "
            _cQuery+="					AND B6_PRODUTO='"+ _aItens[i][1]+"' "
            _cQuery+="					AND B6_LOCAL='"+ SB1->B1_LOCPAD+"' "
            _cQuery+="					AND B6_SALDO > 0" //Dyego
            _cQuery+="		ORDER BY B6_DOC "
            IF SELECT("TMPSB6") >1
               TMPSB6->(dbcloseArea())
            EndIf

            TcQuery _cQuery New Alias "TMPSB6"

            if !(TMPSB6->(EOF()))
               dbSelectArea("SD1")
               SD1->(dbSetOrder(1))
               SD1->(dbSeek(xFilial("SD1")+TMPSB6->B6_DOC+TMPSB6->B6_SERIE+TMPSB6->B6_CLIFOR+TMPSB6->B6_LOJA+ _aItens[i][1]))
               IF SD1->D1_TIPO=="B" .And. SD1->D1_TES="029"

               _cOper:="ST"

               //dentro do estado 5902 estado do cliente igual o da empresa
               If M->C5_TIPO=="N"
                  If SM0->M0_ESTENT==SA1->A1_EST
                     _cCodCF:="5925"
                  Else //fora do estado 6902 estado do cliente diferente o da empresa
                     _cCodCF:="6925"
                  EndIf
               ElseIf M->C5_TIPO=="B"
                      If SM0->M0_ESTENT==SA2->A2_EST
                         _cCodCF:="5902"
                      Else //fora do estado 6902 estado do cliente diferente o da empresa
                         _cCodCF:="6902"
                      EndIf
                   EndIf
               Endif
               _nPreco := Round(TMPSB6->B6_PRUNIT,2)
            Else
               _cQuery := "	SELECT  B6_PRUNIT, B6_SALDO, B6_DOC, B6_SERIE, B6_CLIFOR, B6_LOJA,B6_IDENT, B6_IDENT, B6_TES, B6_TIPO "
               _cQuery += "		FROM " + RetSqlName("SB6")+" "
               _cQuery += "	WHERE B6_PRODUTO='"+ _aItens[i][1]+"'	"
               _cQuery += "		AND D_E_L_E_T_=' '	"
               _cQuery += "		AND B6_FILIAL='"+xFILIAL("SD1")+"'  "
               _cQuery += "		AND B6_CLIFOR='"+M->C5_CLIENTE+"' 	"
               _cQuery += "		AND B6_LOJA='"+M->C5_LOJACLI+"'	"
               _cQuery += "		AND B6_LOCAL='"+ SB1->B1_LOCPAD+"' "
               _cQuery += "		AND B6_SALDO > 0" //Dyego
               _cQuery += "		ORDER BY B6_DOC "

               IF SELECT("TMPSB6") >1
                  TMPSB6->(dbcloseArea())
               EndIf

               TcQuery _cQuery New Alias "TMPSB6"

               if !(TMPSB6->(EOF()))
                  dbSelectArea("SD1")
                  SD1->(dbSetOrder(1))
                  SD1->(dbSeek(xFilial("SD1")+TMPSB6->B6_DOC+TMPSB6->B6_SERIE+TMPSB6->B6_CLIFOR+TMPSB6->B6_LOJA+ _aItens[i][1]))
                  IF SD1->D1_TIPO=="B" .And. SD1->D1_TES=="004"
                     _cOper:="SI"
                     //dentro do estado 5902 estado do cliente igual o da empresa
                     IF M->C5_TIPO=="N"
                        If SM0->M0_ESTENT==SA1->A1_EST
                           _cCodCF := "5902"
                        Else //fora do estado 6902 estado do cliente diferente o da empresa
                           _cCodCF:="6902"
                        EndIf
                     ElseIf M->C5_TIPO=="B"
                            if SM0->M0_ESTENT==SA2->A2_EST
                               _cCodCF:="5902"
                            Else //fora do estado 6902 estado do cliente diferente o da empresa
                               _cCodCF:="6902"
                            EndIf
                     EndIf
                  Endif
                  _nPreco := Round(TMPSB6->B6_PRUNIT,4)
               EndIf
            EndIf

            // alterado por Dyego 09/06/16
            _cCliFor  := M->C5_CLIENTE
            _cLoja    := M->C5_LOJACLI
            _cProduto := _aItens[i][1]
            _nPreco   := u_RMarkup( _nPreco, _cCliFor, _cLoja, _cProduto )

            //Fim alteração
            //_aSaldo:=CalcEst(_aItens[i][1],SB1->B1_LOCPAD,dDataBase)

            _nItem := _nItem+1
            aAux[ GdFieldPos( "C6_ITEM"   , aHeader ) ] := Strzero(_nItem,2) //Item
            aAux[ GdFieldPos( "C6_PRODUTO", aHeader ) ] := _aItens[i][1]		   //Produto
            aAux[ GdFieldPos( "C6_UM"     , aHeader ) ] := SB1->B1_UM              //UNidade de Medida
            aAux[ GdFieldPos( "C6_QTDVEN" , aHeader ) ] := Round(_nqtd,TamSX3("C6_QTDVEN")[2])			//Quantidade
            aAux[ GdFieldPos( "C6_PRCVEN" , aHeader ) ]	:= _nPreco						//Preço de venda
            aAux[ GdFieldPos( "C6_VALOR"  , aHeader ) ] := Round(Round(_nqtd,TamSX3("C6_QTDVEN")[2]) * _nPreco,2)	//Tota.l
            aAux[ GdFieldPos( "C6_QTDLIB" , aHeader ) ] := Round(_nqtd,TamSX3("C6_QTDVEN")[2])             	//Quantidade Liberada
            //aAux[8] :=   0
            aAux[ GdFieldPos( "C6_OPER"   , aHeader ) ] := _cOper				//Operação
            aAux[ GdFieldPos( "C6_TES"    , aHeader ) ] := getTes(_cOper, M->C5_CLIENTE,  M->C5_LOJACLI,_aItens[i][1] )//TES (Gatilho da TES inteligente
            aAux[ GdFieldPos( "C6_LOCAL"  , aHeader ) ] := SB1->B1_LOCPAD	//Armazem
            aAux[ GdFieldPos( "C6_DESCRI" , aHeader ) ] := SB1->B1_DESC 			//Descrição
            //aAux[GdFieldPos(/*"C6_LOTECTL"*/"C6_XLOTERC",aHeader)] := _aItens[i][5]			//LoteX
            aAux[ GdFieldPos( "C6_LOTECTL", aHeader ) ] := " "		//Lotec
            aAux[ GdFieldPos( "C6_NFORI"  , aHeader ) ] := TMPSB6->B6_DOC			//Lotec
            aAux[ GdFieldPos( "C6_SERIORI", aHeader ) ]	:= TMPSB6->B6_SERIE	//Lotec
            aAux[ GdFieldPos( "C6_IDENTB6", aHeader ) ] := TMPSB6->B6_IDENT//Lotec
            aAux[ GdFieldPos( "C6_ITEMORI", aHeader ) ] := POSICIONE("SD1",1,xFilial("SD1")+TMPSB6->B6_DOC+ TMPSB6->B6_SERIE+TMPSB6->B6_CLIFOR+TMPSB6->B6_LOJA+_aItens[i][1],"D1_ITEM")//ITem nota   //D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
            aAux[ GdFieldPos( "C6_PRUNIT" , aHeader ) ] := 0//Preço Lista
            aAux[ GdFieldPos( "C6_DTVALID", aHeader ) ] := '  /  /    '
            aAux[ GdFieldPos( "C6_CF"     , aHeader ) ] := _cCodCF
            aAux[ GdFieldPos( "C6_CLASFIS", aHeader ) ] := CodSitTri()
            aAux[ GdFieldPos( "C6_NUMOP"  , aHeader ) ] := _aItens[i][4]
            aAux[ GdFieldPos( "C6_ITEMOP" , aHeader ) ] := _aItens[i][5]
            //[GdFieldPos("C6_ENTREG",aHeader)]  	:= _cEntrega
            //aAux[GdFieldPos("C6_CODLAN",aHeader)]  		:= SF4->F4_CODLAN
            _nRecno   := _nRecno + 1
            aAux[104] := _nRecno
            ///Corrigi a TES do PA/TA
            aCols[N][GdFieldPos("C6_OPER",aHeader)]:= _cOpeTA
            aCols[N][GdFieldPos("C6_TES",aHeader)]:= _cTesTA
            aCols[N][GdFieldPos("C6_CF",aHeader)]:=  _cCFTA
            //aCols[N][GdFieldPos("C6_CLASFIS",aHeader)]:=  _cCodCF
            //aCols[N][GdFieldPos("C6_CODLAN",aHeader)]:=  _cCodCF
            //_nSalAnt := TMPSB6->B6_SALDO
            _docAnt := TMPSB6->B6_DOC
            _serAnt := TMPSB6->B6_SERIE
            _ideAnt := TMPSB6->B6_IDENT
            _nSalAnt:= TMPSB6->B6_SALDO
            _nqtd2:=_nqtd
            _nSobra:= 0
            If _nqtd2 < _nSalAnt
               _nSobra := _nSalAnt- _nqtd2
            EndIf
            If _nqtd2 > _nSalAnt
               If _nSalAnt > 0
                  aAux2   := {}
                  _nPreco := u_RMarkup(TMPSB6->B6_PRUNIT, _cCliFor, _cLoja, _cProduto)
                  aAux[ GdFieldPos( "C6_PRCVEN" , aHeader) ] := _nPreco
                  aAux[ GdFieldPos( "C6_QTDVEN" , aHeader) ] := Round(_nSalAnt,TamSX3("C6_QTDVEN")[2])		//Quantidade
                  aAux[ GdFieldPos( "C6_VALOR"  , aHeader) ] := Round(Round(_nSalAnt,TamSX3("C6_QTDVEN")[2]) * _nPreco,2)	//Tota.l
                  aAux[ GdFieldPos( "C6_QTDLIB" , aHeader) ] := Round(_nSalAnt,TamSX3("C6_QTDVEN")[2])            	//Quantidade Liberada
                  aAux[ GdFieldPos( "C6_PRUNIT" , aHeader) ] := 0//Preço Lista
                  aAux[ GdFieldPos( "C6_NFORI"  , aHeader) ] := TMPSB6->B6_DOC			//Lotec
                  aAux[ GdFieldPos( "C6_SERIORI", aHeader) ] := TMPSB6->B6_SERIE	//Lotec
                  aAux[ GdFieldPos( "C6_IDENTB6", aHeader) ] := TMPSB6->B6_IDENT//Lotec
                  aAux[ GdFieldPos( "C6_ITEMORI", aHeader) ] := POSICIONE("SD1",1,xFilial("SD1")+TMPSB6->B6_DOC+ TMPSB6->B6_SERIE+TMPSB6->B6_CLIFOR+TMPSB6->B6_LOJA+_aItens[i][1],"D1_ITEM")//ITem nota   //D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
                  aAux[ GdFieldPos( "C6_PRUNIT" , aHeader) ] := 0//Preço Lista
                  _nqtd2 := (_nqtd -  _nSalAnt)
                  _nRecno := _nRecno +1
                  aAux[Len(aAux)-1]:=  _nRecno
                  //aAux[GdFieldPos("C6_VALDESC",aHeader)]  :=0
                  //	aAux[GdFieldPos("C6_COMIS1",aHeader)]  :=0
                  //	aAux[GdFieldPos("C6_COMIS2",aHeader)]  :=0
                  //	aAux[GdFieldPos("C6_COMIS4",aHeader)]  :=0
                  //	aAux[GdFieldPos("C6_COMIS5",aHeader)]  :=0
                  // 	aAux[GdFieldPos("C6_ENTREG",aHeader)]  := _cEntrega
                  //aAux[GdFieldPos("C6_BLOQUEI",aHeader)]  := _cBloquei
                  Aadd(acols,aAux)
               EndIf
               TMPSB6->(dbGOTOP())
               TMPSB6->(dbSkip()) //Busca proxima nota se existir
               While _nqtd2 > 0 .And.  !(TMPSB6->(EOF()))//A quantidade solicitada é maior que o saldo disponivel no lote
                     If !(_docAnt== TMPSB6->B6_DOC .And. _serAnt== TMPSB6->B6_SERIE .And. 	_ideAnt==  TMPSB6->B6_IDENT)
                        _nSalAnt:= TMPSB6->B6_SALDO
                     EndIf
                     If _nSalAnt>_nqtd2
                        _nItem  := _nItem+1
                        _nPreco	:= u_RMarkup(TMPSB6->B6_PRUNIT, _cCliFor, _cLoja, _cProduto)
                        aAux2   := aclone(aAux)//Copia a linha
                        aAux2[ GdFieldPos( "C6_ITEM"   , aHeader ) ] := Strzero(_nItem,2) //Item
                        aAux2[ GdFieldPos( "C6_PRCVEN" , aHeader ) ] := _nPreco
                        aAux2[ GdFieldPos( "C6_QTDVEN" , aHeader ) ] := Round(_nqtd2,TamSX3("C6_QTDVEN")[2])		//Quantidade
                        aAux2[ GdFieldPos( "C6_VALOR"  , aHeader ) ] := Round(Round(_nqtd2,TamSX3("C6_QTDVEN")[2])	* _nPreco,2)	//Tota.l]
                        aAux2[ GdFieldPos( "C6_QTDLIB" , aHeader ) ] := Round(_nqtd2,TamSX3("C6_QTDVEN")[2] )         	//Quantidade Liberada
                        aAux2[ GdFieldPos( "C6_NFORI"  , aHeader ) ] := TMPSB6->B6_DOC			//Lotec
                        aAux2[ GdFieldPos( "C6_SERIORI", aHeader ) ] := TMPSB6->B6_SERIE	//Lotec
                        aAux2[ GdFieldPos( "C6_IDENTB6", aHeader ) ] := TMPSB6->B6_IDENT//Lotec
                        aAux2[ GdFieldPos( "C6_ITEMORI", aHeader ) ] := POSICIONE("SD1",1,xFilial("SD1")+TMPSB6->B6_DOC+ TMPSB6->B6_SERIE+TMPSB6->B6_CLIFOR+TMPSB6->B6_LOJA+_aItens[i][1],"D1_ITEM")//ITem nota   //D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
                        aAux2[ GdFieldPos( "C6_PRUNIT" , aHeader ) ] := 0//Preço Lista

                        _nqtd2            := (_nqtd2 -_nqtd)
                        _nSalAnt          := _nSalAnt - _nqtd
                        _nRecno           := _nRecno +1
                        aAux[Len(aAux)-1] := _nRecno
                        //aAux2[GdFieldPos("C6_VALDESC",aHeader)]  :=0
                        //aAux2[GdFieldPos("C6_COMIS1",aHeader)]  :=0
                        //aAux2[GdFieldPos("C6_COMIS2",aHeader)]  :=0
                        //aAux2[GdFieldPos("C6_COMIS3",aHeader)]  :=0
                        //aAux2[GdFieldPos("C6_COMIS4",aHeader)]  :=0
                        //aAux2[GdFieldPos("C6_COMIS5",aHeader)]  :=0
                        //aAux2[GdFieldPos("C6_ENTREG",aHeader)]  	:= _cEntrega
                        //aAux2[GdFieldPos("C6_BLOQUEI",aHeader)]  := _cBloquei
                        //aAux2[104]:=  _nRecno
                        Aadd(acols,aAux2)
                     Else
                        //Aviso( "A410CONS.PRW", "Não existe saldo suficiente do produto  " + Alltrim(_aItens[i][1] )+;
                        //                       " no armazem " + AllTrim(SB1->B1_LOCPAD) + " !",{"OK"})
                     EndIf
                     TMPSB6->(dbSkip())
                     _docAnt := TMPSB6->B6_DOC
                     _serAnt := TMPSB6->B6_SERIE
                     _ideAnt := TMPSB6->B6_IDENT
               End
               //if _nqtd2>0 //Faltou saldo
               //   Aviso("A410CONS.PRW","A quantidade requisitada para o produto " + AllTrim(_aItens[i][1]) + " é maior que a disponivel em estoque.",{"OK"})
               //   return Nil
               //Else
               //   If  SB1->B1_TIPO <> 'MO'//Dyego
               //      Aadd(acols,aAux) //Dyego
               //   Endif
               //EndIF
            Else
               //aAux[GdFieldPos("C6_PRCVEN",aHeader)]		:= TMPSB6->B6_PRUNIT
               aAux[GdFieldPos("C6_NFORI",aHeader)] 		:= TMPSB6->B6_DOC			//Lotec
               aAux[GdFieldPos("C6_SERIORI",aHeader)]		:= TMPSB6->B6_SERIE	//Lotec
               aAux[GdFieldPos("C6_IDENTB6",aHeader)] 		:= TMPSB6->B6_IDENT//Lotec
               aAux[GdFieldPos("C6_ITEMORI",aHeader)] 		:= POSICIONE("SD1",1,xFilial("SD1")+TMPSB6->B6_DOC+ TMPSB6->B6_SERIE+TMPSB6->B6_CLIFOR+TMPSB6->B6_LOJA+_aItens[i][1],"D1_ITEM")//ITem nota   //D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
               aAux[GdFieldPos("C6_PRUNIT",aHeader)]  		:= 0//Preço Lista
               //aAux[GdFieldPos("C6_VALDESC",aHeader)]  :=0
               //aAux[GdFieldPos("C6_COMIS1",aHeader)]  :=0
               //aAux[GdFieldPos("C6_COMIS2",aHeader)]  :=0
               //aAux[GdFieldPos("C6_COMIS3",aHeader)]  :=0
               //aAux[GdFieldPos("C6_COMIS4",aHeader)]  :=0
               //aAux[GdFieldPos("C6_COMIS5",aHeader)]  :=0
               //aAux[GdFieldPos("C6_ENTREG",aHeader)]  	:= _cEntrega
               //aAux[GdFieldPos("C6_BLOQUEI",aHeader)]  := _cBloquei
               //aAux[104]:=  _nRecno
               Aadd(acols,aAux)
            EndIf
         EndIf
     Next i
     RestArea( _aArea )
Return Nil

Static Function BuscaSD3(_cLote,_cProd)
       Local _aItens:={}
       Local _cOP:=""

       dbSelectArea("SD5")
       SD5->(dbSetOrder(2)) //D5_FILIAL+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_NUMLOTE+D5_NUMSEQ
       SD5->(dbSeek(xFilial("SD5")+_cProd))

       While !(SD5->(eof())) .And. xFilial("SD5")==SD5->D5_FILIAL .And. AllTrim(_cProd)==AllTrim(SD5->D5_PRODUTO)// ;
             //.And. _cLocal==SD5->D5_LOCAL .And. _cLote==SD5->D5_LOTECTL
             If SD5->D5_ORIGLAN =="001" .And. SD5->D5_LOTECTL==_cLote //Entrada
                _cOP:= SUBSTR(SD5->D5_OP,1,6)
             EndIf
             SD5->(DBSKIP())
       End
       _cQuery := "SELECT D3_FILIAL, D3_COD, D3_LOCAL, SUM(D3_QUANT) AS QTD_TOTAL, MAX(SUBSTRING(D3_OP,1,6)) AS NUMOP "
       _cQuery += "FROM " + RetSqlName("SD3")+" SD3"
       _cQuery += "LEFT JOIN " + RetSqlName("SB1")+" SB1  ON D3_COD = B1_COD AND SD3.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
       _cQuery += "WHERE  SUBSTRING(D3_OP,1,6)='"+_cOP+"' AND "
       _cQuery += "	D3_CF<>'PR0' AND "
       _cQuery += "	SD3.D_E_L_E_T_=' ' AND "
       _cQuery += "	D3_FILIAL='"+xFilial("SD3")+"' AND "
       _cQuery += "	B1_FILIAL='"+xFilial("SB1")+"' AND "
       _cQuery += "	B1_TIPO NOT IN ('PA','TA','PI','MO') AND "
       _cQuery += "	D3_ESTORNO<> 'S'"
       _cQuery += "	GROUP BY D3_FILIAL, D3_COD, D3_LOCAL, SUBSTRING(D3_OP,1,6) "

       IF SELECT("TMPSD3") >1
          TMPSD3->(dbcloseArea())
       EndIf
       TcQuery _cQuery New Alias "TMPSD3"

       While !(TMPSD3->(EOF()))
             Aadd(_aItens,{TMPSD3->D3_COD,TMPSD3->D3_LOCAL,TMPSD3->QTD_TOTAL,TMPSD3->NUMOP,ItemOP(TMPSD3->NUMOP,TMPSD3->D3_COD)})
             TMPSD3->(dbSkip())
       End
Return _aItens

Static Function BuscaPrc(cTabela, cTpNota, cProduto,cLocal, cCliFor, cLoja,cLote )
       Local _nPreco :=0
       Local _cTabela:=""

       DbSelectArea("DA0")
       DbSelectArea("DA1")
       DA1->(dbSetOrder(1))	//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
       DA1->(dbSeek(xFilial("DA1")+cTabela+cProduto))
       _lOk := .T.
       While !(DA1->(EOF())) .And. Alltrim(cTabela)==Alltrim(DA1->DA1_CODTAB) .And. AllTrim(DA1->DA1_CODPRO)== AllTrim(cProduto) .and. !(_lOk)
             dbSelectArea("DA0")
             DA0->(dbSetOrder(1))	//DA0_FILIAL+DA0_CODTAB
             DA0->(dbSeek(xFilial("DA0")+cTabela))
             if date() >= DA1->DA1_DATVIG .And. date() >= DA0->DA0_DATDE .And. date() <= DA0->DA0_DATATE //Valida a vigencia
                _nPreco:= DA1->DA1_PRCVEN
             EndIf
             DA1->(dbSkip())
       End
Return _nPreco

Static Function getTes(cOper, cCliente, cLoja,cProd )
       Local cTes:=""
       Local _aArea:=getArea()
       cTes := MaTesInt(2,cOper,cCliente,cLoja,If(M->C5_TIPO $'DB',"F","C"),cProd,"C6_TES")

       RestArea(_aArea)
Return cTes

Static Function ItemOP(_cOP,_cProd)
       Local cRetorno

       _cQuery := "SELECT SUBSTRING(D3_OP,9,3) ITEM "
       _cQuery += "FROM " + RetSqlName("SD3")+" SD3 "
       _cQuery += "LEFT JOIN " + RetSqlName("SB1")+" SB1  ON D3_COD = B1_COD AND SD3.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
       _cQuery += "WHERE  SUBSTRING(D3_OP,1,6)='"+_cOP+"' AND "
       _cQuery += "	SD3.D3_COD ='"+_cProd+"' AND "
       _cQuery += "	SD3.D3_CF<>'PR0' AND "
       _cQuery += "	SD3.D_E_L_E_T_=' ' AND "
       _cQuery += "	D3_FILIAL='"+xFilial("SD3")+"' AND "
       _cQuery += "	B1_FILIAL='"+xFilial("SB1")+"'  "

       IF SELECT("TMPTRB") >1
          TMPTRB->(dbcloseArea())
       EndIf
       TcQuery _cQuery New Alias "TMPTRB"
       cRetorno:= TMPTRB->ITEM

Return cRetorno