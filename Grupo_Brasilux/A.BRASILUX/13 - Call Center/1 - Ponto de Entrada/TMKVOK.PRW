#include 'rwmake.ch'
#include 'topconn.ch'
#include 'protheus.ch'    
#include 'DIRECTRY.CH'       
#INCLUDE "AP5MAIL.CH"                                    
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  TMKVOK  ºAutor  ³ Cleber O. Dominguesº Data ³  11/04/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º 12/09/01 ³ Ponto de entrada na confirmação da inclusão/alteração do - º±±
±±º          ³ pedido de vendas.                                          º±±
±±º 16/04/04 ³ Se for inclusão e a venda for a vista colocar automatica - º±±
±±º          ³ mente como boleto sim.                                     º±±
±±º 09/11/04 ³ Retirado a pedido do Florivaldo, ajuste no campo boleto -  º±±
±±º          ³ para não gerar caso a condição de pagamento for a prazo.   º±±
±±º 02/01/06 ³ Ajuste linha 80                                          - º±±
±±º 29/09/06 ³ Preenchimento de UA_VEND2 E COMIS 1% P/ GERENTE DE VEND  - º±±
±±º 15/05/09 ³ Nova politica comercial de descontos                     - º±±
±±º 02/07/09 ³ Determinar CST pois nao grava corretamente.              - º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function TMKVOK()  
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
     Local cArea := Alias()
     Local aVenctos       := {}  //Vetor com prazos de pagamentos
     Local aPrazos        := {}  //Vetor com prazos em dias
     Local aAuxEmba       := {}  
     //Local aPedGOP        := {}  //Matriz com Pedidos que irão gerar 
     Local aPrecos		  := {}  //Vetor que receberá os precos minimos para um item de produto de acordo com as 6 faixas de desconto definidas
     Local aPrcMin   	  := {0,0,0,0,0,0}  //Vetor com a soma dos preços mínimos a serem praticados de acordo com a politica de venda
     Local cUf            := ""  //Estado do Cliente ou Fornecedor
     Local cInscr         := ""  //Inscrição Estadual do Cliente ou Fornecedor
     Local cComp,lVolJunto,_x
     Local cMensErro      := ""
     Local nPrazoMedio    := 0   //Prazo médio em dias da venda
     Local _nVlrTotPed    := 0   //Valor total do pedido
     Local _nVlrTotDup    := 0   //Valor total que gera FINANCEIRO!
     Local _nVlrTotMin    := 0   //Valor total mínimo para entrar dentro da Política de Vendas!
     Local nSomaVlrTab    := 0   //Valor total do pedido (apenas itens que GERAM FINANCEIRO!) pelo valor de tabela
     Local nPesoBrut      := 0   
     Local nQtdeMinEst    := 0   //Quantidade mínima para entrar na tabela 1
     Local nPerInt        := 0   //Soma de percentuais internos na formação de preços, exceto lucro e comissão
     Local nLc1           := 0   //Lucro + Comissão na tabela 1
     Local nLc2           := 0   //Lucro + Comissão na tabela 2
     Local nValTab        := 0   //Valor total de tabela do item
     Local nValUnTab      := 0   //Valor unitário de tabela do item
     Local nVlrProd       := 0   //Valor total do produto do item
     Local nVolTotal      := 0
     Local nPesoLiquTotal := 0
     Local nPesoBrutTotal := 0
     Local _nPercIcms     := 0 //GETMV("MV_ICMPAD")
     Local nValorHoje     := 0
     Local nQtdeParc      := 0
     Local nSaldoVend     := 0 //Saldo de vendas do mês para o cliente
     Local _nLucroItem    := 0
     Local _nValReal      := 0 //Total de LUCRO+COMISSAO
     Local _nMedComiss    := 0
     Local _nMedLucro     := 0
     Local _nVlrCDesc     := 0
     Local _nVlrComiss    := 0
     Local _nVlrLucro     := 0
     Local nJuros         := GETMV("MV_JUROS")
     Local lGeraDup       := .f. //Verifica se gera duplicata ou não
     //Local lMisturado 	  := .f. //Informa se há itens de estoque misturados c/ itens Não Estoque!
     Local cCodCid		  := "" //Código da Cidade do Cliente
     Local lRet           := .t. //Variavel lógica que retorna a validação geral do ponto de entrada, se aceita(.t.) ou nao(.f.)
     Local lProdEstoque   := .f. //Verifica se é produto de estoque
     Local lSisRev        := .f. //Participa de política de venda p/ Comércio/Revenda? Caso positivo, verificar se o pedido atende à regra.
     Local lProblPrazo    := .f. //Bloquear pedido caso prazo médio não seja respeitado, independente de qualquer coisa
     Local lDescOk,cCnpj
     Local lRegB1
     Local lEmbaemG1,nContItens,lAux
     Local nPosPRUNIT     := aScan(aHeader, {|x| Trim(x[2]) == "UB_VRUNIT" }) //Posicionamento do campo UB_VRUNIT  no aHeader
     Local nPosDESCONT    := aScan(aHeader, {|x| Trim(x[2]) == "UB_DESC"}) 		//Posicionamento do campo UB_DESC no aHeader
     Local nPosVALDESC    := aScan(aHeader, {|x| Trim(x[2]) == "UB_VALDESC"}) //Posicionamento do campo UB_VALDESC no aHeader
     Local nPosPRODUTO    := aScan(aHeader, {|x| Trim(x[2]) == "UB_PRODUTO"}) //Posicionamento do campo UB_PRODUTO no aHeader
     Local nPosQTDVEN     := aScan(aHeader, {|x| Trim(x[2]) == "UB_QUANT" }) //Posicionamento do campo UB_QUANT no aHeader
     Local nPosTES        := aScan(aHeader, {|x| Trim(x[2]) == "UB_TES"    }) //Posicionamento do campo UB_TES no aHeader
     Local nPosCF         := aScan(aHeader, {|x| Trim(x[2]) == "UB_CF"     }) //Posicionamento do campo UB_CF no aHeader
     Local nPosVALOR      := aScan(aHeader, {|x| Trim(x[2]) == "UB_VLRITEM"  }) //Posicionamento do campo UB_VLRITEM no aHeader
     Local nPosPRCVEN     := aScan(aHeader, {|x| Trim(x[2]) == "UB_VRUNIT" }) //Posicionamento do campo UB_VRUNIT no aHeader
     Local nPosVolItem    := aScan(aHeader, {|x| Trim(x[2]) == "UB_VOLITEM"}) //Posicionamento do campo UB_VOLITEM no aHeader
     Local nPosVlrLucr    := aScan(aHeader, {|x| Trim(x[2]) == "UB_VLRLUCR"}) //Posicionamento do campo UB_VLRLUCR no aHeader
     Local nPosLucrEsp    := aScan(aHeader, {|x| Trim(x[2]) == "UB_LUCRESP"}) //Posicionamento do campo UB_LUCRESP no aHeader
     Local nPosCst        := aScan(aHeader, {|x| Trim(x[2]) == "UB_CLASFIS"}) //Posicionamento do campo UB_CLASFIS no aHeader
     Local nPosFCI        := aScan(aHeader, {|x| Trim(x[2]) == "UB_FCICOD"}) //Posicionamento do campo UB_FCICOD no aHeader
     Local nQtdComp,cCst,cCondPag,nDescPerm
     Local nVar, nAux, cAux, i,nAuxQtde,nAuxLucro,nAuxVol,nQtdeVol
     //Local _cFilial
     Local nInd, nIndAnt, cTipoCons,_nComisCal
     Local nDesc1, nDesc2, _nPisCof,nMes,nAno,nTolerancia
     //Local nIndA, nIndB, nIndC, nIndD, nIndE, nIndF, nIndG
     Local aStrut := {},cCursorTemp,nTotalTipo9,j,cAuxMens
     //Local cArqTemp,cInd01, cKey01
     Local aEmba := {}  //Tipos de Embalagens utilizada, Colunas: 1-Cód Emba; 2-Qtde de Embal; 3-Qtde p/ Juntar Vol; 4-Qtde Vol. produtos que não juntam vol; 5-Qtde BL p/ verif. se fecham vol; 6-Rel. Volume
     Local lCalcVol := .t. // Det. se vai incluir a relação de volume, auxiliar para prevenir probl. de numeração de pedido
     Local lSoSolventes := .t. // determina se o pedido é exclusivo de solventes para poder entrar na política de desconto extra para esse tipo de prod(20/03/2012)
     Local aArea,lVolQuebr,nCubagem,nRegB1,nIpiAnt,cTipoPed
     Local _lVerAuto := Type("l410Auto") <> "U"
     //Local nVlrTot := 0
     Local _cMVESTADO := GETMV("MV_ESTADO") //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     Local _nMVICMPAD := GETMV("MV_ICMPAD")
     Local _nMVTXPIS  := GETMV("MV_TXPIS")
     Local _nMVTXCOFI := GETMV("MV_TXCOFIN")
     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        //Se estiver nas empresas de Gestão Imobiliária não executar
        IF (cNumEmp = "01") .and. (SUBSTR(cNumEmp,3,2) $ "07*08*09")
           return(.t.)
        endif 
        aArea := U_PegaArea({"SB9","CFD","SB1","SB2","SF4","SA1","SE4","SA2","SA3","SB5","SZ5","SZ7","ZZO"})
        dbselectarea("SUA")
        RecLock("SUA",.F.)

           nIpiAnt := 0.0

           nTotalTipo9 := 0 // Valor total dos valores das parcelas tipo 9

           DbSelectArea("SZ7")  // Cadastro de Cidades
           DbOrderNickName("SZ7001")

           DbSelectArea("SZ1")  // Qtde de Volumes por Embalagem
           DbOrderNickName("SZ1001")

           DbSelectArea("ZZO")  // Qtde de Volumes por Embalagem
           dbsetorder(1)
	
           DbSelectArea("SB1")  //Produtos
           DbSetOrder(1)

           DbSelectArea("SB2")  //Saldos em Estoque
           DbSetOrder(1)

           DbSelectArea("SF4")  //Tipos de Entradas e Saídas
           DbSetOrder(1)

           DbSelectArea("SA1")  //Clientes
           DbSetOrder(1)

           cCondPag := SUA->UA_CONDPG  //Guarda o código da cond. de pagamento digitada

           cTipoPed := ALLTRIM(SUA->UA_TIPO)
           IF EMPTY(cTipoPed)
              SUA->UA_TIPO := "N"
              cTipoPed := "N"
           ENDIF 

           DbSelectArea("SE4")  // Condição de Pagamento
           DbSetOrder(1)
           DbSeek(xFilial("SE4")+cCondPag)
           IF Found() // Cria vetor com prazos de pagamento
              //Cleber(24/07/18) Solicitação Eliana, chamado 010813 -> pedidos com cond. pgto até 7 dias calcular comissão como se fosse à vista
              IF (SE4->E4_TIPO = "1") .AND. (LEN((ALLTRIM(SE4->E4_COND))) == 1)
                 IF VAL(ALLTRIM(SE4->E4_COND)) <= 7
                    cCondPag := "001"
                 ENDIF
              ENDIF 
     	
              If (SE4->E4_TIPO # "9")
                 aVenctos := Condicao(100, cCondPag, 0.00, dDataBase, 0.00)
              Else
                 aVenctos  := {}
                 nQtdeParc := 0
                 For i := 1 to 4
                     cAux := "SUA->UA_DATA"+Alltrim(Str(i))
                     If !Empty(&cAux)
                        aAdd(aVenctos, {&cAux, 0})
                        cAux  := "SUA->UA_PARC"+Alltrim(Str(i))
                        if &cAux <= 0
                           lRet := .f.
                           cAuxMens := "Preencha Todos os Valores para os Vencimentos Apontados!"
                           MsgBox(cAuxMens, "Atenção", "STOP")
                           exit 
                        endif
	          			
                        nTotalTipo9 += &cAux
                        aVenctos[i,2] := &cAux
                        nQtdeParc++    
                     else
                        cAux  := "SUA->UA_PARC"+Alltrim(Str(i))
                        if &cAux > 0
                           lRet := .f.    
                           cAuxMens := "Preencha Todos os Vencimentos para os Valores Apontados!"
                           MsgBox(cAuxMens, "Atenção", "STOP")
                           exit 
                        endif
                     Endif
                 Next
           If nQtdeParc == 0
              nQtdeParc  := 1
              nTotalTipo9 := 1
              SUA->UA_DATA1 := dDataBase
              aAdd(aVenctos, {dDataBase, 1})
           Endif

        Endif
     Else
		nTotalTipo9 := 1
        aVenctos := {}
        aAdd(aVenctos, {dDataBase, 1})
     Endif


     aPrazos     := {} // Vetor com prazos em dias + % de cada parcela sobre total e cálculo do prazo médio
     nPrazoMedio := 0
     For i := 1 to Len(aVenctos)
         aadd(aPrazos, {aVenctos[i,1] - dDataBase + 1,iif(nTotalTipo9 > 0,aVenctos[i,2]/nTotalTipo9,1/len(aVenctos))})
         nPrazoMedio += aPrazos[i,1]
     Next
     If Len(aVenctos) > 0
        nPrazoMedio := nPrazoMedio / Len(aVenctos)
     Endif


     DbSelectArea("SA2")  //Fornecedores
     DbSetOrder(1)

     DbSelectArea("SA3")  //Representantes
     DbSetOrder(1)

     DbSelectArea("SB5")  //Tabela de Preços 2
     DbSetOrder(1)

     cUf    := ""
     cInscr := ""  
     cTipoCons := ""
     cCodCid := ""  
     cCnpj := ""
     If cTipoPed $ "D_B"          
        DbSelectArea("SA2")
        DbSeek(xFilial("SA2")+SUA->UA_CLIENTE)
        If Found()
           cUf    := SA2->A2_EST
           cInscr := SA2->A2_INSCR
           cTipoCons := SA2->A2_CLAS
           cCodCid := SA2->A2_CODCID
           cCnpj := alltrim(SA2->A2_CGC)
        Endif
     Else
        DbSelectArea("SA1")
        DbSeek(xFilial("SA1")+SUA->UA_CLIENTE)
        If Found()
           cUf    := SA1->A1_EST
           cInscr := SA1->A1_INSCR
           cTipoCons := SA1->A1_CLAS
           If INCLUI 
           		IF (SA1->A1_BOLETO = 'S') .AND. (cCondPag == "001")  // Cleber(16/04/04) =>Se for venda à vista, colocar automaticamente como boleto
           			SUA->UA_BOLETO := "S"
           		ENDIF 
           Endif                    
           cCodCid := SA1->A1_CODCID
           cCnpj := alltrim(SA1->A1_CGC)
        Endif
     Endif

     aadd(aStrut,{"PRODUTO"   , "C", 10, 0})     
     aadd(aStrut,{"VOLUME"  , "N", 15, 4})
     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 27/09/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/

       //cArqTemp := U_NovoArqTrab("dbf") 
       //dbcreate(cArqTemp+".dbf", aStrut, "DBFCDXADS")      
       cCursorTemp := U_NovoCursor()
       //Use (cArqTemp+".Dbf") Alias (cCursorTemp) VIA "DBFCDXADS" New Exclusive
       //cKey01  := "PRODUTO"
       //cInd01  := cArqTemp+"_1" //"SC"+SubStr(cNomArq, 8, 6)+"_1"
       //DbCreateIndex(cInd01, cKey01, {||cKey01} )
       //DbClearIndex()
       //DbSetIndex(cInd01)
        oTempTable := FWTemporaryTable():New( cCursorTemp )
        oTemptable:SetFields( aStrut )
        oTempTable:AddIndex( "cInd01", { "PRODUTO" } )
        oTempTable:Create()

     /********************************************************************************************************************************/
     DbSelectArea(cCursorTemp)
     DbSetOrder(1)

     _nVlrTotPed := 0   //Valor Total do Pedido
     _nVlrTotDup := 0   // Valor Total que gera FINANCEIRO
     nSomaVlrTab := 0   //Valor Total do Pedido (de itens que GERAM FINANCEIRO) pelo Valor de Tabela
     lGeraDup    := .f. //Verifica se gera duplicata ou não
     nContItens := 0 // Conta a qtde de itens do pedido
     lProdEstoque := .f.
     DbSelectArea("SZ5")
     DbSetOrder(1)
	 For _x := 1 to Len(aCols)
         If !aCols[_x][Len(aHeader)+1] //Se não for registro deletado
         	nContItens ++
            aCols[_x][nPosVolItem] := 0   
				
			cAux := alltrim(aCols[_x][nPosProduto])
				
            // Determinar em lVolJunto se produto junta volume c/ outros ou não, p/ efeito de cálculo de volumes
            lVolJunto := U_VolJunto(aCols[_x][nPosProduto]) 
            nQtdeVol     := 0
            nPesoLiqu    := 0
            nPesoBrut    := 0
            _nBaseIcms   := 0
            lProdEstoque := .f. //Verifica se é produto de estoque, para det. de lucro
            nQtdeMinEst  := 999999   //Quantidade mínima para considerar tabela de preço de produtos de estoque
            nPerint      := 0
            nLc1         := 0
            nLc2         := 0
            nValTab      := 0
            nValUnTab      := 0
            DbSelectArea("SB1") //Produtos
            DbSeek(xFilial("SB1")+aCols[_x][nPosProduto])
            If Found()
               	lProdEstoque := iif((SB1->B1_ESTOQUE == "S"),.t.,.f.)   
               	
            	nIpiAnt := SB1->B1_IPI

	            if (len(alltrim(SB1->B1_COD)) == 12)
	            
					if !lProdEstoque
		               	DbSelectArea("SZ5")
    		           	DbSeek(xFilial("SZ5")+SubStr(aCols[_x][nPosProduto], 11, 2))
        		       	If Found()
            		      	nQtdeMinEst := SZ5->Z5_QTDVEN 
							if ((aCols[_x][nPosQtdVen] ) >= nQtdeMinEst) //Se atingir qtde mínima considerar como prod. de estoque
								lProdEstoque := .t.
							endif 
						endif 
					endif 
	            
	            endif //FIM (len(alltrim(SB1->B1_COD)) == 12)
	            	

               	nLc1    := SB1->B1_COMIS + SB1->B1_LUCRO
               	nLc2    := SB1->B1_COMIS + SB1->B1_LUCRO2
               	nValUnTab := SB1->B1_PRV1
	            If !lProdEstoque
    	        	DbSelectArea("SB5")
               		DbSeek(xFilial("SB5")+aCols[_x][nPosProduto])
               		If Found() 
               			nValUnTab := SB5->B5_PRV2
	               	Endif  
    	        Endif  

               	nValTab := nValUnTab * aCols[_x][nPosQTDVEN] // * Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1) //Em princípio, fica com o valor tabela 1, logo abaixo, se for o caso troca caso não seja produto de estoque
               	nPerInt := SB1->B1_PERINT/100
	            aCols[_x][nPosLucrEsp] := iif(lProdEstoque,SB1->B1_LUCRO,SB1->B1_LUCRO2) // % de Lucro esperado para o item       
	            

    		else
               	lRet := .f.
				cAuxMens := "Não encontrado o PRODUTO "+aCols[_x][nPosProduto]+" no cadastro. Contacte o Adm. do Sistema!"			
				//LGS#20200204 - Adequação de release 12.1.25 e posteriores
				//if ( Type("l410Auto") <> "U" .And. l410Auto )
				if ( _lVerAuto .And. l410Auto )
					//LGS#20200204 - Adequação de release 12.1.25 e posteriores
					//ConOut(cAuxMens)
					FwLogMSG( "ERROR", , 'SIGATMK', funname(), '', '01', cAuxMens, 0 )
				else
	               	MsgBox(cAuxMens, "Atenção", "STOP")
	   			endif 
	   			exit 
            Endif        


              // Zerar Descontos para não aparecer valor maior em Valor Contabil em SF3
            //DescPed(nVlrTab,nVlrOrig,nDesc1,nDesc2,nDesc3)  
            nAux := TamSX3("UB_VRUNIT")[2]
            aCols[_x][nPosPRCVEN] := round(U_DescPed(nValUnTab,aCols[_x][nPosPRCVEN],SUA->UA_DESCON1,SUA->UA_DESCON2,SUA->UA_DESCON3),nAux)
            aCols[_x][nPosPRUNIT]  := aCols[_x][nPosPRCVEN]
   	        aCols[_x][nPosDESCONT] := 0
       	    aCols[_x][nPosVALDESC] := 0            
            nAux := TamSX3("UB_VLRITEM")[2]
            IF cTipoPed = "N"
	       	    aCols[_x][nPosValor] := round(aCols[_x][nPosPRCVEN]*aCols[_x][nPosQTDVEN],nAux)     
			ENDIF 
       	    SUA->UA_DESC1 := 0
       	    SUA->UA_DESC2 := 0
       	    SUA->UA_DESC3 := 0
       	    SUA->UA_DESC4 := 0
            
  
            // Checar consistências
            DbSelectArea("SF4") //Tipo de Entrada e Saída
            DbSeek(xFilial("SF4")+aCols[_x][nPosTES])
            If !Found()
               	lRet := .f.
               	cAuxMens := "Não encontrado o TES "+aCols[_x,nPosTES]+" no cadastro. Contacte o Adm. do Sistema!"
           		MsgBox(cAuxMens, "Atenção", "STOP")
           		exit 
            endif 

            If (SF4->F4_DUPLIC $ 'S ') .OR. (SF4->F4_CODIGO = "519")
				lGeraDup := .t.
			Endif
			
 			if lGeraDup .AND. (cTipoPed = "N") .AND. ((len(alltrim(aCols[_x][nPosProduto])) != 12) .or. !(substr(aCols[_x][nPosProduto],4,2) $ "71-10"))
 				// Não é pedido exclusivo de Solventes linhaS 71 e 10!
				lSoSolventes := .f. 
			endif 

            // Determinar o CST -> Cleber   
            cCst := ""
            cAux := dtos(date()) 
   	        cPerVen := substr(cAux,5,2)+substr(cAux,1,4)  
   	        //Período de cálculo
       	    nAno := year(date())
           	nMes := month(date()) - 2
            if nMes <= 0
   	        	nMes := 12+nMes
       	    	nAno--
           	endif    
            cPerCal := padl(alltrim(str(nMes)),2,"0")+padl(alltrim(str(nAno)),4,"0")
            	    
			if nPosFCI > 0 // Não encontrado campo FCI qdo se usa a ferramenta Copiar!
	 			dbselectarea("CFD")   
				//CFD_FILIAL+CFD_COD+CFD_PERCAL+CFD_PERVEN 
				cAux := iif((cNumEmp = "01010106") .OR. (cNumEmp = "01010107"),"010101",xFilial("CFD"))
				dbseek(cAux+SB1->B1_COD+cPerCal+cPerVen,.T.)
				if found()
					cCst := CFD->CFD_ORIGEM   
					if cTipoPed = "N"
						aCols[_x][nPosFCI] := CFD->CFD_FCICOD
					endif 
				endif 
			endif 
		    IF EMPTY(cCst)
            	if !empty(SB1->B1_ORIGEM)
	   	       		cCst := trim(SB1->B1_ORIGEM)
    	   	   	else 
        		    if cUf != "EX"
   	    	    		cCst := "0"
	        		else
       					cCst := "1"
					endif         	   
				endif 
			endif 
			if empty(cCst)
				cCst := "0"
			endif 
			cCst += ALLTRIM(SF4->F4_SITTRIB)

            //Preenchimento correto do CST (02/07/09) -> Cleber  
            //Correção do CST (15/05/13) -> Cleber  
            if (len(alltrim(aCols[_x][nPosCst])) != 3) .OR. (M->UB_TIPO = "N") 
	            aCols[_x][nPosCst] := cCst
			endif 

            //Verificar se volumes ficam incompletos
            lVolQuebr := (cTipoPed = "N") .AND. U_VolQuebrado(aCols[_x][nPosProduto], aCols[_x][nPosQTDVEN] )
            If lVolQuebr .AND. (SF4->F4_VOLQUEB != "S")  //* Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1)
            	//Ped. funcionários podem ter volume quebrado (Solic. Ramon em 03/10/14)
            	lAux := .f. //Flag que identifica se é funcionário
            	if len(cCnpj) == 11
            		cQry1 := "SELECT RA_MAT FROM "+RetSqlName("SRA")+" SRA WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (RA_CIC = '"+cCnpj+"') AND (RA_SITFOLH <> 'D')"
			  		TCQuery cQry1 ALIAS "TCQRA" NEW 
			  		dbselectarea("TCQRA") 
			  		dbgotop()
			  		if !eof() .and. !bof() 
			  			lAux := .t.
			  		endif    
			  		dbclosearea()      
				endif 
				if !lAux //Se não for funcionário            		
	               	lRet      := .f.
    	           	cMensErro := "Quantidade de Volumes para o produto "+aCols[_x][nPosProduto]+" não permitida!"
	               	MsgBox(cMensErro, "Atenção", "STOP")
	   				exit 
            	Endif                                         
        	endif 
        	

            //Determinação dos Pesos Liquido/Bruto, da quantidade de volumes e volume por cor
			nPesoLiqu := (SB1->B1_PESO * aCols[_x][nPosQTDVEN] ) //* Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1)
   			//nPesoBrut := nPesoLiqu 
      		nPesoBrut := (SB1->B1_PESBRU * aCols[_x][nPosQTDVEN] )

            DbSelectArea("SG1")
            DbSetOrder(1)

			
            //Determinação dos Pesos Liquido/Bruto, da quantidade de volumes, volume por cor e cubagem
			aAuxEmba := {}   
            If (Len(Alltrim(aCols[_x][nPosProduto])) == 12) .and. !(Substr(aCols[_x][nPosProduto], 11, 2) $ "00.99")
				aAdd(aAuxEmba, {Alltrim(Substr(aCols[_x][nPosProduto], 11, 2)),0,0,0,0,"",0}) 
               	lRegB1 := .f.
               	DbSelectArea("SZ5")
               	DbSeek(xFilial("SZ5")+SubStr(aCols[_x][nPosProduto], 11, 2))
               	If Found()
                  	DbSelectArea("SB1")
                  	nRegB1 := Recno()
                  	lRegB1 := .t.
					dbselectarea(cCursorTemp)
					dbseek(substr(aCols[_x][nPosProduto],1,10),.t.)
					if !found()
						reclock(cCursorTemp,.t.)
						(cCursorTemp)->PRODUTO := substr(aCols[_x][nPosProduto],1,10)
					else
						reclock(cCursorTemp,.f.)
					endif 
					(cCursorTemp)->VOLUME += SZ5->Z5_VOLUME
					msunlock()
     			Endif

               	lEmbaemG1 := .f. //Identifica se há tipo de embalagem na estrutura, caso contrário pega dos 2 díg. finais do código do produto
               	IF SB1->B1_RELVOL > 0
					aAuxEmba[1][6] := alltrim(STR(SB1->B1_RELVOL))
                  	nAuxVol := U_DetVolEmba(aAuxEmba[1][6], aCols[_x][nPosQTDVEN] ) //* Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1)
                   	aAuxEmba[1][2] := aCols[_x][nPosQTDVEN] // * Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1)
                    aAuxEmba[1][3] := iif(lVolJunto,aCols[_x][nPosQTDVEN],0)
                    aAuxEmba[1][4] := iif(!lVolJunto,nAuxVol,0)
                    aAuxEmba[1][5] := iif(lVolJunto .and. (SF4->F4_VOLQUEB != "S") .and.  (substr(aCols[_x][nPosProduto],1,2) $ "BL"),aCols[_x][nPosQTDVEN],0)
					aCols[_x][nPosVolItem] += nAuxVol //* Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1)
				else 
               
               		DbSelectArea("SG1")
               		DbSetOrder(1)
               		DbSeek(xFilial("SG1")+aCols[_x][nPosProduto], .F.)
               		If Found()
               			While !Eof() .AND. (SG1->G1_FILIAL == xFilial("SG1")) .AND. (SG1->G1_COD = aCols[_x][nPosProduto]) .AND. (Len(RTrim(SG1->G1_COMP)) == 4)
                        	cComp    := RTrim(SG1->G1_COMP)
                        	nQtdComp := 0
        	    	   		While !Eof() .AND. (SG1->G1_FILIAL == xFilial("SG1")) .AND. (SG1->G1_COD = aCols[_x][nPosProduto]) .AND. (Len(RTrim(SG1->G1_Comp)) == 4) .AND. (RTrim(SG1->G1_COMP) == cComp)
                              	nQtdComp += SG1->G1_QUANT
                              	DbSkip()
                        	Enddo

                        	DbSelectArea("SB1")
                        	DbSeek(xFilial("SB1")+cComp, .F.)
                        	If Found() .and. !Empty(SB1->B1_RELCAT1)
                           		lEmbaemG1 := .t. 
			               		DbSelectArea("SZ5")
       	    			   		DbSeek(xFilial("SZ5")+alltrim(SB1->B1_RELCAT1))
			               		If !Found()
		    	           			dbselectarea("SG1")
		        	       	   		loop 
		            	   		endif 

                       			lAchou := .f.
                       			for i = 1 to len(aAuxEmba)
                       				if (empty(aAuxEmba[i][6]) .or. (aAuxEmba[i][6] == alltrim(SZ5->Z5_RELVOL)))
                        				lAchou := .t.
   	                    				nVar := i
       	                			endif
           	            		next
               	        		if !lAchou                    
                   	    			nVar := len(aAuxEmba)+1   
									aAdd(aAuxEmba, {Alltrim(Substr(aCols[_x][nPosProduto], 11, 2)),0,0,0,0,alltrim(SZ5->Z5_RELVOL),0}) 
								else        
									if empty(aAuxEmba[nVar][6])
										aAuxEmba[nVar][6] := alltrim(SZ5->Z5_RELVOL)
									endif 
   	                    		endif
		
                           		nAuxQtde := aCols[_x][nPosQTDVEN] * nQtdComp
   	                       		nAuxVol := U_DetVolEmba(aAuxEmba[nVar][6], nAuxQtde ) //* Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1)
                       	   		aAuxEmba[nVar][2] := aAuxEmba[nVar][2] + nAuxQtde // * Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1)
                       			aAuxEmba[nVar][3] := aAuxEmba[nVar][3] + iif(lVolJunto,nAuxQtde,0)
                       			aAuxEmba[nVar][4] := aAuxEmba[nVar][4] + iif(!lVolJunto,nAuxVol,0)
                           		aAuxEmba[nVar][5] := aAuxEmba[nVar][5] + iif(lVolJunto .and. (SF4->F4_VOLQUEB != "S") .and. (substr(aCols[_x][nPosProduto],1,2) $ "BL"),nAuxQtde,0)

    	
       	                   		aCols[_x][nPosVolItem] += nAuxVol //* Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1)
              	          	Endif
   	                    	DbSelectArea("SG1")
       	          		EndDo
   					Endif
					// Se não tiver embalagem na estrutura considerar código final.
					If !lEmbaemG1 .and. !(Substr(aCols[_x][nPosProduto], 11, 2) $ "00.99") // Se não tiver cód. de embalagem na estrutura, pegar pelo final do cód. do prod.
    		           	DbSelectArea("SZ5")
   						DbSeek(xFilial("SZ5")+aAuxEmba[1][1])
						If Found()
							aAuxEmba[1][6] := alltrim(SZ5->Z5_RELVOL)
						endif 
    	              	nAuxVol := U_DetVolEmba(aAuxEmba[1][6], aCols[_x][nPosQTDVEN] ) //* Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1)
   	    	           	aAuxEmba[1][2] := aCols[_x][nPosQTDVEN] // * Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1)
       	    	        aAuxEmba[1][3] := iif(lVolJunto,aCols[_x][nPosQTDVEN],0)
           	    	    aAuxEmba[1][4] := iif(!lVolJunto,nAuxVol,0)
            	        aAuxEmba[1][5] := iif(lVolJunto .and. (SF4->F4_VOLQUEB != "S") .and.  (substr(aCols[_x][nPosProduto],1,2) $ "BL"),aCols[_x][nPosQTDVEN],0)
						aCols[_x][nPosVolItem] += nAuxVol //* Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1)
					Endif 
       	 		endif 

               DbSelectArea("SB1")
   	           If lRegB1
       	          DbGoto(nRegB1)
           	   Endif
            Else // Se não PA de 12 dígitos(Tinta) !
            	IF (Len(Alltrim(aCols[_x][nPosProduto])) == 12) 
                  	nQtdeVol := nQtdeVol + 1
					aAuxEmba := {}   
					aAdd(aAuxEmba, {substr(aCols[_x][nPosProduto],11,2),aCols[_x][nPosQTDVEN],0,1,0,alltrim(str(aCols[_x][nPosQTDVEN])),0}) 
           	      	aCols[_x][nPosVolItem] += 1
     			ELSE 
      				
   	              	nAux := IIF(SB1->B1_RELVOL > 0,round(aCols[_x][nPosQTDVEN]  / SB1->B1_RELVOL,3),0)   //* Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1)
    	  			If Int(nAux) < nAux
   	    	  			nAux := Int(nAux) + 1
       	    	 	Endif
	            	nQtdeVol := nQtdeVol + nAux
					aAuxEmba := {}   
					aAdd(aAuxEmba, {"--",aCols[_x][nPosQTDVEN],0,nAux,0,alltrim(str(SB1->B1_RELVOL)),0}) 
                  	aCols[_x][nPosVolItem] += nAux
               	ENDIF 
               	
            Endif
            
    		for j := 1 to len(aAuxEmba)       
				//Det. da Cubagem
				nCubagem := iif(j == 1,DetCubagem(aCols[_x][nPosProduto])*aCols[_x][nPosQTDVEN],0)
    			
				lAchou = .f.
				For i := 1 to Len(aEmba)
					If (aEmba[i][1] == aAuxEmba[j,1]) .and. (aEmba[i][6] == aAuxEmba[j,6])
						lAchou := .t.
						nVar   := i
					Endif
     			Next
        		If !lAchou
        			nVar := Len(aEmba)+1
          			//Tipo de embalagem correspondente armazenado 
             		aAdd(aEmba, {aAuxEmba[j,1],0,0,0,0,aAuxEmba[j,6],0 }) 
             	endif 
           		aEmba[nVar,2] += aAuxEmba[j,2]
           		aEmba[nVar,3] += aAuxEmba[j,3]
           		aEmba[nVar,4] += aAuxEmba[j,4]
           		aEmba[nVar,5] += aAuxEmba[j,5]
           		aEmba[nVar,7] += nCubagem
           		
           	next 
			// término cálc. volumes p/ o item
            
//            nVolTotal      := nVolTotal + nQtdeVol
            nPesoLiquTotal := nPesoLiquTotal + nPesoLiqu
            nPesoBrutTotal := nPesoBrutTotal + nPesoBrut

            // Definição da CFOP
			cCf := alltrim(aCols[_x][nPosCF])
			if empty(cCf)
				cCf := alltrim(SF4->F4_CF)
			endif  
			If (cUf != "EX")  
				DO CASE
				//LGS#20200204 - Adequação de release 12.1.25 e posteriores
				//CASE ((cCf = "6107") .OR. (alltrim(SF4->F4_CF) = "6107")) .AND. (GETMV("MV_ESTADO") = cUf) // Antes era "618"
				CASE ((cCf = "6107") .OR. (alltrim(SF4->F4_CF) = "6107")) .AND. ( _cMVESTADO = cUf) // Antes era "618"
                   	cCf := "5101"
    			//Cleber (12/04/16) -> Solic. Nadia inclusão para o CFOP 6108 semelhante à situação do 6107
    			//LGS#20200204 - Adequação de release 12.1.25 e posteriores
				//CASE ((cCf = "6108") .OR. (alltrim(SF4->F4_CF) = "6108")) .AND. (GETMV("MV_ESTADO") = cUf)
				CASE ((cCf = "6108") .OR. (alltrim(SF4->F4_CF) = "6108")) .AND. ( _cMVESTADO = cUf)
    				cCf := "5102"
    			OTHERWISE
       				//LGS#20200204 - Adequação de release 12.1.25 e posteriores
       				//If (GETMV("MV_ESTADO") != cUf) .and. (substr(cCf,1,1) == "5")
       				If ( _cMVESTADO != cUf) .and. (substr(cCf,1,1) == "5")
       					cCf := "6"+substr(cCf,2,len(cCf)-1)
                  	Endif
    			ENDCASE 
				  
           	Else    
           		if substr(cCf,1,1) == "5"
           			cCf := "7"+substr(cCf,2,len(cCf)-1)
           		endif 
            Endif                                           

            aCols[_x][nPosCF] := cCf

            // Definição da Base de ICMS p/ fins de apuração de Lucro e Comissão
			_nPercIcms := 0
            If SF4->F4_ICM = "S"
               	_nBaseIcms := aCols[_x][nPosVALOR] / Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 0.7, 1)
               	If (SF4->F4_IPI == "S") .AND. (SF4->F4_INCIDE == "S")
                  	_nBaseIcms := _nBaseIcms * (1 + (SB1->B1_IPI / 100))
               	Endif   
        		if cUf = "EX"
          			_nPercIcms := 0
        		else
        		    //LGS#20200204 - Adequação de release 12.1.25 e posteriores
	         		//If (cTipoCons = "N") .OR. (GETMV("MV_ESTADO") = cUf) 
	         		If (cTipoCons = "N") .OR. ( _cMVESTADO = cUf)
	         		    //LGS#20200204 - Adequação de release 12.1.25 e posteriores
	         			//IF (GETMV("MV_ESTADO") = cUf) .AND. (GETMV("MV_ESTADO") = "SP") .AND. (SB1->B1_GRTRIB = '003')
	         			IF ( _cMVESTADO = cUf) .AND. ( _cMVESTADO = "SP") .AND. (SB1->B1_GRTRIB = '003')
	         				//25% ICMS para produtos 100% solvente puro
	         				_nPercIcms = 25
	         			else
	                  		//LGS#20200204 - Adequação de release 12.1.25 e posteriores
	                  		//_nPercIcms = GETMV("MV_ICMPAD")
	                  		_nPercIcms = _nMVICMPAD
	            		endif 
               		Else                                           
               			//FCI -> ICMS 4%
               			if substr(aCols[_x][nPosCst],1,1) $ "1,3,8"
                     		_nPercIcms = 4
                  		else 
	                  		If cUf $ "MG_PR_RJ_RS_SC_SP"
    	                 		_nPercIcms = 12
        	          		Else
            	         		_nPercIcms = 7
                	  		Endif
               			Endif
               		endif 
            	endif                    
            Endif     

			// Verificar se tem desconto de Pis/Cofins  
			_nPisCof := 0 // Valor a ser descontado de Pis/Cofins
			if empty(SF4->F4_PISCOF) .or. (SF4->F4_PISCOF = "N")
			   //LGS#20200204 - Adequação de release 12.1.25 e posteriores
			   //_nPisCof :=  (aCols[_x][nPosVALOR] / Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 0.7, 1)) * ((GETMV("MV_TXPIS") + GETMV("MV_TXCOFIN"))/100)
				_nPisCof :=  (aCols[_x][nPosVALOR] / Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 0.7, 1)) * ( ( _nMVTXPIS + _nMVTXCOFI ) / 100 )
			endif 

            nVlrProd := (aCols[_x][nPosVALOR]/Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 0.7, 1)) // * Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1)
            _nVlrTotPed := _nVlrTotPed + nVlrProd

            if (SF4->F4_DUPLIC = "S") .OR. (SF4->F4_CODIGO = "519")
	            _nVlrTotDup := _nVlrTotDup + nVlrProd

				aPrecos := U_PrcMinimo(nValTab,iif(len(alltrim(SB1->B1_COD)) == 12,SUBSTR(SB1->B1_GRUPO2,2,1),"X"),_nPercIcms,IIF(SF4->F4_INCIDE == "S",.T.,.F.),cCondPag)

				aPrcMin[1] += noround(aPrecos[1],2)
				aPrcMin[2] += noround(aPrecos[2],2)
				aPrcMin[3] += noround(aPrecos[3],2)
				aPrcMin[4] += noround(aPrecos[4],2)
				aPrcMin[5] += noround(aPrecos[5],2)
				aPrcMin[6] += noround(aPrecos[6],2)

            	nValorHoje := 0
            	nQtdeParc  := Len(aPrazos)
            	For i := 1 To nQtdeParc
                	nAux := ((aCols[_x][nPosVALOR]/Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 0.7, 1)) * aPrazos[i,2]) / ((1 + (nJuros / 100)) ^ ((12 * aPrazos[i,1]) / 365)) //* Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1)
	                nValorHoje := nValorHoje + nAux
    	        Next

        	    //Valor do lucro+comissao da empresa no preco praticado do pedido.
            	_nLucroItem := nValorHoje - ((aCols[_x][nPosVALOR]/Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 0.7, 1)) * (SB1->B1_PERINT / 100)) - (SB1->B1_CUSTOR * aCols[_x][nPosQTDVEN] ) - (_nBaseIcms * _nPercIcms / 100) - _nPisCof //* Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 2, 1)
	            aCols[_x][nPosVlrLucr] := _nLucroItem*Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 0.7, 1) // Valor do Lucro + Comissão, p/ posterior apuração de lucro obtido por linha de prod   

    	        _nValReal   := _nValReal + _nLucroItem
            
	            //Media de Comissao e Lucro Minimo.
    	        If !lProdEstoque 
        	       nAuxLucro := SB1->B1_LUCROM2
            	Else
	               nAuxLucro := SB1->B1_LCRMIN
    	        Endif
        	    _nMedComiss := _nMedComiss + (SB1->B1_COMIS * aCols[_x][nPosVALOR] / Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 0.7, 1))
            	_nMedLucro  := _nMedLucro  + (nAuxLucro * aCols[_x][nPosVALOR] / Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 0.7, 1))

	            //Descontos para produtos de estoque e Não Estoque
    	        //nQtdeParc = Len(aPrazos)
        	    nInd := 0
            	For i := 1 To nQtdeParc
                	nAux := (aPrazos[i,2]) / ((1 + (nJuros / 100)) ^ ((12 * aPrazos[i,1]) / 365))
	                nInd := nInd + nAux
	            Next
    	        nIndAnt     := (1 + (nJuros / 100)) ^ ((12 * 60) / 365) // 60 dias
	            //LGS#20200204 - Adequação de release 12.1.25 e posteriores
	            //nDesc1      := (nInd - (1 / nIndAnt) + (GETMV("MV_ICMPAD") / 100) - (_nPercIcms / 100)) / (nInd - nPerint - (nLC1 / 100) - (_nPercIcms / 100))
	            nDesc1      := (nInd - (1 / nIndAnt) + ( _nMVICMPAD / 100) - (_nPercIcms / 100)) / (nInd - nPerint - (nLC1 / 100) - (_nPercIcms / 100))
	            //LGS#20200204 - Adequação de release 12.1.25 e posteriores
	            //nDesc2      := (nInd - (1 / nIndAnt) + (GETMV("MV_ICMPAD") / 100) - (_nPercIcms / 100)) / (nInd - nPerint - (nLC2 / 100) - (_nPercIcms / 100))
	            nDesc2      := (nInd - (1 / nIndAnt) + ( _nMVICMPAD / 100) - (_nPercIcms / 100)) / (nInd - nPerint - (nLC2 / 100) - (_nPercIcms / 100))
    	        _nVlrCDesc  := nValTab * (1 - Iif(lProdEstoque, nDesc1, nDesc2)) // Somar vlr tabela c/ desconto p/ 60 dias em regioes de icms diferentes
        	    nSomaVlrTab += nValTab // _nVlrCDesc , a partir de 15/05/09 passou a aplicar descontos tendo ref. apenas a tabela 18%

                  endif // FIM if SF4->F4_DUPLIC = 'S'

               Else //Se for registro deletado

               Endif
           Next
           //Qtde de Volumes à partir de vetor gerado e/ou Volume Total Gerado
           lCalcVol := .t.
           nCubagem := 0
           if lRet .and. lCalcVol
              For i := 1 to Len(aEmba)   
                  nQtdeVol := aEmba[i][4]
                  if lRet .and. (aEmba[i][5] > 0)
                     lRet := U_volcompl(aEmba[i][6], aEmba[i][5])
                     if !lRet
                        cMensErro := "Pedido não fecha volumes devido a BL!"
                        MsgBox(cMensErro, "Atenção", "STOP")
                        exit
                     endif
                  endif
                  If aEmba[i][3] > 0
                     nQtdeVol += U_DetVolEmba(aEmba[i][6], aEmba[i][3])
                  Endif                                                 
                  nVolTotal += nQtdeVol
                  nCubagem += aEmba[i][7]
              Next
           endif 
           If (nCubagem > 0) 
              SUA->UA_VOLUME2 := nCubagem
           Endif                    
           /*
           //ATENÇÃO!!! SE SALVAR UA_ESPECI2 O PROGRAMA NFESEFAZ IRÁ SOMAR AO TOTAL DE VOLUMES A QTDE DE UA_VOLUME2!!
           If Empty(SUA->UA_ESPECI2) .AND. (nCubagem > 0)
              SUA->UA_ESPECI2 := "CUBAGEM"
           Endif
           */
           if cUf = "EX" //Exportação não paga comissão
              _nMedComiss := 0
           endif 		

           // % de lucro obtido  
           if _nVlrTotDup > 0
              _nMedComiss := _nMedComiss / _nVlrTotDup                   
              _nMedLucro  := _nMedLucro / _nVlrTotDup
              _nLucroCal  := ((_nValReal - (_nVlrTotDup * (_nMedComiss / 100))) / _nVlrTotDup) * 100     
           else
              _nLucroCal := 0
              _nMedComiss := 0  
              _nMedLucro  := 0  
              _nLucroCal  := 0
           endif 

           // À partir de 01/03/06 todos participam de comissão fixa 5%
           lSisRev     := .f. // Participa de pol. nova para revenda?
           if cUf = "EX" //Exportação nao participa de compensação, não há comissionamento!
              SUA->UA_COMPENS := "N" // Não participa de compensação de comissão!
              lSisRev       := .f.
           else 
              If !(cTipoPed $ "D_B") // .AND. (SA1->A1_CLAS == "V")
                 DbSelectArea("SA3")
                 DbSeek(xFilial("SA3")+Iif(Empty(SUA->UA_VEND), SA1->A1_VEND, SUA->UA_VEND))
                 If Found() .and. (SA3->A3_SISREV == "S") // Se o representante aderiu à política de revenda, 5% fixos de comissão
                    SUA->UA_COMPENS := "N" // Não participa de compensação de comissão!
                    lSisRev       := .t.
                 Endif
              Endif 
           endif 

           // Gravar desconto aplicado sobre o geral de tabela. Solic. Eliana em Fev/2008
           SUA->UA_DESCON4 := IIF(nSomaVlrTab > 0,ROUND((1-(_nVlrTotDup/nSomaVlrTab))*100,2),0)

           // Se o lucro da empresa praticado no preco do pedido for menor que o Lucro Minimo
           // abate esta diferenca da comissao do representante.
           If _nLucroCal >= _nMedLucro
              _nComisCal := _nMedComiss
           Else
              _nLucroCal   := _nMedLucro                                                     
              _nComisCal   := iif(_nVlrTotDup <= 0,0,((_nValReal - ((_nLucroCal * _nVlrTotDup) / 100)) / _nVlrTotDup) * 100)
              // aCols[_x,16] := _nComisCal
           Endif
           lDescOk       := .t.

           //Política padrão de comissionamento
           If lSisRev .and. lRet .and. (cTipoPed =  "N") 
              cQry1 := "SELECT SUM(C6_VALOR/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS SALDO "+;
              "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "+;
              "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C6_FILIAL = C5_FILIAL) AND (C6_NUM = C5_NUM) "+;
              "LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (F4_CODIGO = C6_TES) "+;
              "WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C5_CLIENTE = '"+SUA->UA_CLIENTE+"') "+;
              "AND (C5_EMISSAO LIKE '"+SUBSTR(DTOS(SUA->UA_EMISSAO),1,6)+"%') AND (C5_EMISSAO <= '"+DTOS(SUA->UA_EMISSAO)+"') AND "+;
              "(C5_TIPO NOT IN ('D','B')) AND ((F4_DUPLIC = 'S') OR (C6_TES = '519'))" 
              TCQuery cQry1 ALIAS "TCQSLD" NEW
              DBSELECTAREA("TCQSLD")
              if !eof() .and. !bof()
                 nSaldoVend := TCQSLD->SALDO
              else
                 nSaldoVend := 0
              endif
              DBSELECTAREA("TCQSLD")
              dbclosearea()
              nSaldoVend += _nVlrTotDup        
              _nVlrTotMin := 750 // Fev/2017 mudou de 450 para 750

              IF (cTipoPed = 'N') 
                 If (nPrazoMedio > 65) .and. (_nComisCal < _nMedComiss) // Prazo máximo 60 dias porém coloquei 65 como forma de tolerância para vencimentos reais maiores
                    lProblPrazo := .t. //Não respeita prazo mínimo!!
                    lDescOk := .f.
                 else
                    nTolerancia := 0.005
                    do case
                       case nSaldoVend < 750
                            lDescOk := .f.
                       case nSaldoVend <= 3000
                            _nVlrTotMin := aPrcMin[1] 
                       case nSaldoVend <= 5000
                            _nVlrTotMin := aPrcMin[2] 
                       case nSaldoVend <= 8000
                            _nVlrTotMin := aPrcMin[3] 
                       case nSaldoVend <= 11000
                            _nVlrTotMin := aPrcMin[4] 
                       case nSaldoVend <= 15000
                            _nVlrTotMin := aPrcMin[5] 
                       otherwise
                            _nVlrTotMin := aPrcMin[6] 
                    endcase
                    If _nVlrTotDup < _nVlrTotMin
                       //SUA->UA_DESCON4 := IIF(nSomaVlrTab > 0,ROUND((1-(_nVlrTotDup/nSomaVlrTab))*100,2),0)
                       nDescPerm := IIF(nSomaVlrTab > 0,ROUND((1-(_nVlrTotMin/nSomaVlrTab))*100,2),0)
                       if (SUA->UA_DESCON4 - nDescPerm) > (nTolerancia*100)
                          lDescOk := .f.
                       endif
                       /*
                       If ((_nVlrTotMin - _nVlrTotDup) / _nVlrTotMin) > nTolerancia // Se distorção maior que tolerancia
                          lDescOk := .f.
                       Endif
                       */
                    Endif
                 endif            
              endif
              //Ajusta comissão Fixa   
              If (_nComisCal > _nMedComiss) .OR. lDescOk
                 _nComisCal := _nMedComiss  
              Endif  
              //Não permitir que comissão seja maior que 5%, por segurança (30/10/09) => Cleber
              if _nComisCal > 5
                 _nComisCal := 5  
              endif 
              if  (cTipoPed = 'N') .and. lSoSolventes .and. !lDescOk .and. (_nVlrTotDup > 0) // .AND. !lProblPrazo //Permissão de desconto adicional para as linhas 71,10 - solventes
                 //Chamado 004437(Eliana) em que solicita que se aplique desconto máximo independente do valor vendido
                 _nVlrTotMin := aPrcMin[6]	
                 nAux := _nVlrTotMin*0.95
                 if nAux <= _nVlrTotDup
                    _nComisCal := 4  
                    lDescOk := .t.
                 else
                    nAux := nAux*0.95
                    if nAux <= _nVlrTotDup
                       _nComisCal := 3  
                       lDescOk := .t. 
                    else
                       nAux := nAux*0.95
                       if nAux <= _nVlrTotDup
                          _nComisCal := 2  
                          lDescOk := .t. 
                       else 
                          nAux := nAux*0.95
                          if nAux <= _nVlrTotDup
                             _nComisCal := 1
                             lDescOk := .t. 
                          else
                             nAux := nAux*0.95
                             if nAux <= _nVlrTotDup
                                _nComisCal := 0
                                lDescOk := .t. 
                             endif 
                          endif 
                       endif 
                    endif 
                 endif
              endif 
              if _nVlrTotDup > 0
                 _nLucroCal := ((_nValReal - ((_nComisCal * _nVlrTotDup) / 100)) / _nVlrTotDup) * 100
              else
                 _nLucroCal := 0
              endif 

           Endif //Fim if lSisRev
     
           // Recalcula comissao.
           _nVlrComiss  := _nVlrTotDup * _nComisCal * Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 0.7, 1)/ 100
           // Calcula Lucro da empresa.
           _nVlrLucro   := _nVlrTotDup * _nLucroCal * Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 0.7, 1) / 100
           _nPorcComiss := _nComisCal
           _nPorcLucro  := _nLucroCal
           //Atualiza variaveis do pedido.
           SUA->UA_PORCOM  := _nPorcComiss
           SUA->UA_COMIS   := _nPorcComiss
           SUA->UA_VLRCOM  := _nVlrComiss
           SUA->UA_LUCRO   := _nPorcLucro
           SUA->UA_MEDCOM  := _nMedComiss
           SUA->UA_MEDLUCR := _nMedLucro
           If nPesoLiquTotal > 0
              SUA->UA_PESOL := nPesoLiquTotal
           Endif
           If (nPesoBrutTotal > 0)
              SUA->UA_PBRUTO := nPesoBrutTotal
           Endif
           If SUA->UA_PBRUTO < SUA->UA_PESOL
              SUA->UA_PBRUTO := SUA->UA_PESOL
           Endif
           If (nVolTotal > 0) .and. lCalcVol
              SUA->UA_VOLUME1 := nVolTotal
           Endif
           If Empty(SUA->UA_ESPECI1) .AND. (SUA->UA_VOLUME1 > 0)
              SUA->UA_ESPECI1 := "VOLUME"
           Endif
           If Empty(SUA->UA_ESPECI3)
              SUA->UA_ESPECI3 := "VOLUME"
           Endif
     	
           SUA->UA_VLRDUP := ROUND(_nVlrTotDup*Iif(!Empty(Alltrim(SUA->UA_ESPECI4)), 0.7, 1),2)
           SUA->UA_TIPLIB := '2' //Garantir que seja liberado por pedido e não por item

           //25/04/16 -> Cleber - Atualizar campo UA_SUGENT (Dt. Sugestão de Entrega) com o valor da data programada para entrega
           /*IF !EMPTY(SUA->UA_PEDPROG) .AND. !(SUA->UA_SUGENT == SUA->UA_PEDPROG)                                                                   
              SUA->UA_SUGENT := SUA->UA_PEDPROG
           ENDIF */                    
           DbSelectArea("SUA")
        MsUnlock()     
        U_VoltaArea(aArea)
        dbselectarea(cCursorTemp)
        dbclosearea()
        oTempTable:Delete()     

        aEval(Directory("tmp*.dbf"), { |aFile| FERASE(aFile[F_NAME]) })     
        aEval(Directory("tmp*.cdx"), { |aFile| FERASE(aFile[F_NAME]) })     

        If !empty(cArea)
           DbSelectArea(cArea)
        Endif
     Endif
Return(lRet)

Static Function DetCubagem(cProd)
Local nRet,cQuery,cCursor
	cCursor := U_NovoCursor()
	cQuery := "SELECT ISNULL(SUM(B1_ESP05),0) AS CUBAGEM FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = G1_COMP) "+;
	"WHERE (SG1.D_E_L_E_T_ <> '*') AND (G1_FILIAL = '"+xFilial("SG1")+"') AND (G1_COD = '"+alltrim(cProd)+"') "
	TCQuery cQuery NEW ALIAS (cCursor)
	nRet := (cCursor)->CUBAGEM	       
	dbclosearea()        
	if nRet <= 0
		cQuery := "SELECT ISNULL(B1_ESP05,0) AS CUBAGEM FROM "+RetSqlName("SB1")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = '"+cProd+"')"
		TCQuery cQuery NEW ALIAS (cCursor)
		nRet := (cCursor)->CUBAGEM		
		dbclosearea()        
	endif 
return(nRet)