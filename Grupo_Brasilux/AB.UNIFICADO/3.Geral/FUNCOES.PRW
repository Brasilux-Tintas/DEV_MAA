#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "AP5MAIL.CH"
#include "PRTOPDEF.CH"
#Include "ApWebSrv.ch"

#Translate MSGBOX( => IW_MsgBox(
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕ"ÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ FUNCOES  ∫Autor  ≥                    ∫ Data ≥             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ FunÁıes genÈricas usados nas customizaÁıes do sistema.     ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ BRASILUX TINTAS T…CNICAS LTDA.                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
+--------------+----------+----------+-------------------------------------------------+
|    FUN«√O    |   DATA   | ANALISTA |               DESCRI«√O DA FUN«√O               |
+--------------+----------+----------+-------------------------------------------------+
| CalcVariacao | 08/10/02 | Cleber   | Calcula % variaÁ„o entre o ultimo preÁo pago    |
| VerUlPreco   | 12/08/02 | Cleber   | Ver ultimo preÁo pago pelo cliente              |
| AtingeVend   | 09/01/03 | Cleber   | Verifica se produto atinge cota minima de venda |
| CalcComis    | 04/11/05 | Cleber   | Retorna o valor da comiss„o por item            |
| fHisPed      | 14/09/05 | Gustavo  | Mostra histÛrico dos movimentos do pedido       |
| TiraAcento   | 26/02/03 | Cleber   | Substitui caracteres especiais e com acento     |
| ChrTran      | 27/02/03 | Cleber   | Verifica a existencia de caracteres especiais   |
| fgets        | 27/02/03 | Cleber   | Le Linha de arquivo texto                       |
| VolQuebrado  | 05/03/04 | Cleber   | Verifica se um produto tem volume quebrado      |
| EditaX5      | 14/11/02 | Cleber   | Edita tabelas do cadastro do SX5                |
| VldX5_Chave  | 14/11/02 | Cleber   | Usado na validaÁ„o da funÁ„o EditaX5            |
| VolJunto     | 10/04/06 | Cleber   | Determina se junta volume ou n„o                |
| DetVolEmba   | 29/03/04 | Cleber   | Determina quantidade de volumes de uma embalagem|
| cTon         |          | Cleber   | Converte uma string em numero                   |
| CustoPro     |   /04/02 | Cleber   | Calcula o custo unit·rio de MP do produto       |
| DCustoPro    | 19/08/09 | Cleber   | Calcula o custo unit·rio de MP do produto consid vlr do dolar       |
| CalcPesoEsp  | 17/05/02 | Cleber   | Calcula peso especifico das fÛrmulas            |
| VerSX2       | 01/04/02 | Cleber   | Verifica a tabela apontada no banco             |
| EnviaRec     | 25/03/03 | Cleber   | Envia registros alterados para o brasrepres     |
| EstaBloqueado|   /  /   | Cleber   | Verifique se o registro bloqueado na tabela     |
| CalcLucro    |   /  /   | Cleber   | FunÁ„o para calcular o lucro                    |
| DetPercInt   | 25/05/04 | Cleber   | Usado para determinar percentuais internos      |
| NumSeqLot    | 25/02/02 | Renato   | Retorna o proximo numero de lote.               |
| TrataFiltro  | 11/06/02 | Cleber   | FunÁ„o para tratar filtro                       |
| Scatter      | 21/10/02 | Cleber   | Guarda os valores de uma tabela em uma matriz   |
| TipoCons     | 30/07/03 | Cleber   | Retorna o tipo de consumidor                    |
| DetQtdeVol   | 04/03/04 | Cleber   | Determina quantidade de volumes de um produto   |
|              | 05/03/10 | Cleber   | Retirada da funÁ„o DetQtdeVol!!!                |
| fMosAvs      |   /  /   | Gustavo  | Mostra Aviso                                    |
| fBusEndLiv   | 21/06/06 | Gustavo  | Busca endereÁo vazio na expediÁ„o               |
| fEndPedExp   | 21/06/06 | Gustavo  | EndereÁa pedidos na expediÁ„o                   |
| volcompl     | 19/02/08 | Cleber   | Verifica se o volume est· preenchido por completo
| PrcUltCompra | 15/09/08 | Cleber   | Traz o ult. preco de SD1 para det produto       | 
| PrcMinimo    | 15/05/09 | Cleber   | Traz o preco c/ o desc maximo permitido p/ o prod 
| Sodig        | 02/06/09 | Cleber   | Retorna somente os nros de uma string           | 
| SoNumCar     | 09/06/14 | Cleber   | Retorna somente os nros e letras de uma string  | 
| CorrigeVol   | 15/10/10 | Cleber   | Corrige Rel. de Volumes p/ Det. Pedido          | 
| NovoCursor   | 23/12/10 | Cleber   | Retorna o nome de um cursor que nao esta em uso | 
| UltDiaMes    | 21/09/11 | Cleber   | Retorna data do ˙ltimo dia de det. mÍs          | 
| DescPed  	   | 08/05/12 | Cleber   | Aplicar Desconto no item do pedido mÍs          | 
| BRTEMAMOSTRA | 17/04/13 | Cleber   | Verificar se det. pedido tem tes de amostra     | 
| FILTSQL      | 03/08/13 | Cleber   | Converter filtro pra SQL Serer                  | 
| fPedLib      | 23/10/13 | Cleber   | Liberar ped., trazida de BRFATX01 p. uso Gen    | 
| ParamSql     | 17/02/14 | Cleber   | Tratar parametro para filtro em SQL             | 
| DetLocPad    | 15/09/14 | Cleber   | Det. Local Padr„o Consid. Dep. Fechado - Tempor | 
| fTemSpray    | 29/09/14 | AndrÈ    | Verifica se pedido possui spray entre os itens  | 
| VldAcesso    | 09/10/14 | Cleber   | Verifica se usuario logado possui acesso a det  | 
|              |          |          | rotina.                                         | 
| TemProInd    | 20/01/15 | AndrÈ    | ValidaÁ„o do tipo de Tm para produtos aprop dire| 
| TrazPITinta  | 04/09/15 | Cleber   | Traz o CÛd. do PI ref. ao PA - final 99 p/ Kg e | 
|              |          |          | 00 para Tintas em Litros                        | 
| Aliqinterna  | 24/03/16 | Cleber   | Devido ao estd RO passar a ter aliq 17,5% nem t | 
|              |          |          | odos os estados ficam com 2 digitos de aliq.    | 
| ProxDiaUtil  | 27/04/16 | Cleber   | Retorna a data do Prox Dia Util a partir de um  | 
|              |          |          | nro de dias fornecido                           | 
| ValidProd    | 03/05/16 | Cleber   | Retorna a data de validade do Prod ‡ partir do  | 
|              |          |          | lote e cod produto.                             | 
| ValMesesPro  | 19/08/17 | AndrÈ    | Retorna a validade me meses do produto          |
| BloqProg     | 24/03/17 | Cleber   | Cria uma tabela exclusiva com nome do usuario   | 
|              |          |          | para fins de bloqueio de uso de funÁ„o          |
| DiasUteis    | 20/04/17 |          | Retorna n˙mero de dias ˙teis entre duas datas   |
| AF010Conv    | 14/11/17 | AndrÈ    | Converte o valor da moeda1 em 2,3,4,5           |
| ObsProd      | 27/12/18 | Cleber   | Define Conteudo do Campo B1_OBS P/ MASTERSALES  |
| DetCposTab   | 09/08/19 | Cleber   | Retorna Matriz c/ Cpos Tabela p/ ExecAuto       |
| NossoNro     | 28/08/19 | Cleber   | Trata o Nosso Nro no arquivo Remessa            |
| zPutSX1      |          | Gustavo  | FunÁ„o substitui a original da TOTVS PutSX1 pois|
|              |          |          | essa foi descontinuada apos a vers„o 12.        |
| DigNNBrad    | 27/09/19 | Cleber   | Calcula dÌg verificador Nosso Nro Bradesco      |
| zBxXML       | 28/09/19 | Cleber   | Baixa XML da Receita atravÈs da Chave           |
| xPutSx1      | 11/05/20 | Cleber   | Inserir Parametros diretamente no SX1           |
| QtdMinProd   | 12/07/20 | Cleber   | Valida qtde mÌnima de venda para det produto    |
| DetIdCNAB    | 20/08/20 | Cleber   | Determina a chave do registro CNAB para os arquivos |
| DetCodFci    | 18/12/20 | Cleber   | Determina o cÛdigo FCI a partir do cod produto |
| DetCstFci    | 18/12/20 | Cleber   | Determina o cÛdigo CST FCI a partir do cod produto |
| VerZ17       | 26/04/21 | Cleber   | Verifica a existÍncia da AmarraÁ„o Grp Trib x NCMo |
+--------------+----------+----------+-------------------------------------------------+


*/



/*********************************************************************************/
/*** FunÁ„o que calcula a variaÁ„o (em %) entre dois valores                   ***/
/*** Usada p/ calcular a variaÁ„o entre o ˙ltimo preÁo pago em R$ pelo produto ***/
/*** e o preÁo atual convertido em DÛlar.                                      ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data : 08/10/02                                                           ***/
/*********************************************************************************/
User Function CalcVariacao(nVlr1, nVlrUS)
     Local nVlrConv, nVariacao
     // Converter de US$ p/ Real
     nVlrConv := nVlrUS * RETFIELD("SM2", 1, dDataBase, "SM2->M2_MOEDA2")
     If nVlr1 > 0
        nVariacao := ((nVlrConv / nVlr1) - 1) * 100
     Else
        nVariacao := 0
     Endif
Return(nVariacao)

/*********************************************************************************/
/*** FunÁ„o Gatilho para Veficar o ⁄ltimo preÁo pago pelo cliente a deter-     ***/
/*** minado produto. Usado na digitaÁ„o do Pedido e na digitaÁ„o do OrÁamento. ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data : 12/08/02                                                           ***/
/*** Alterado: 24/04/07 - LuÌs Gustavo de Souza                                ***/
/***           Incluida pesquisa DbSeek para a tabela SA7, incluido parametro  ***/
/***           Loja Cliente.                                                   ***/
/*********************************************************************************/
User Function VerUlPreco(cCliente, cProduto, cLojaCli)
Local nRet, nArea, i, cAux
     /*
     Local nPosSC6  := n  //LGS#20191121 - AdequaÁ„o para release 12.1.25
     Local nPosPro  := aScan(aHeader, { |x| Alltrim( x[2] ) == "C6_PRODUTO" } )  //LGS#20191121 - AdequaÁ„o para release 12.1.25

     cProduto := Iif( Empty( cProduto ), aCols[ nPosSC6][ nPosPro], cProduto ) //LGS#20191121 - AdequaÁ„o para release 12.1.25
     */
nArea    := Alias()
nRet     := 0
if !empty(cCliente) .and. !empty(cProduto)     
     DbSelectArea("SA7")
     DbSetOrder(1)
     
     DbSeek(xFilial("SA7")+padr(cCliente,TamSx3("A1_COD")[1]," ")+padr(cLojaCli,TamSx3("A1_LOJA")[1]," ")+cProduto, .t.)
     If Found()
        For i := 1 to 12
            cAux := "SA7->A7_PRECO"+Iif(i < 10, "0", "")+Alltrim(Str(i))
            If &cAux > 0
               nRet := &cAux
            Endif
        Next
     Endif
endif      
DbSelectArea(nArea)
Return(nRet)

/*********************************************************************************/
/*** FunÁ„o gatilho para Veficar se atinge cota mÌnima de venda para produtos  ***/
/*** que n„o s„o de estoque. Retorna Sim ou N„o. Usado na digitaÁ„o do pedido  ***/
/*** e na digitaÁ„o do orÁamento.                                              ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data : 09/01/03                                                           ***/
/*********************************************************************************/
User Function AtingeVend( cProduto, nQtde )
     Local cRet, nQtdeMinEst
     Local _cArea   := alias()
     Local nPosSC6  := n  //LGS#20191121 - AdequaÁ„o para release 12.1.25
     Local aAreaAnt := U_PegaArea({"SB1","SB2","SZ5"})
     Local nPosPro  := aScan(aHeader, { |x| Alltrim( x[2] ) == "C6_PRODUTO" } )  //LGS#20191121 - AdequaÁ„o para release 12.1.25
     Local nPosQtd  := aScan(aHeader, { |x| Alltrim( x[2] ) == "C6_QTDVEN"  } )  //LGS#20191121 - AdequaÁ„o para release 12.1.25
     
     cProduto := Iif( Empty( cProduto ), aCols[ nPosSC6][ nPosPro], cProduto ) //LGS#20191121 - AdequaÁ„o para release 12.1.25
     nQtde    := Iif( nQtde == 0       , aCols[ nPosSC6][ nPosQtd], nQtde    ) //LGS#20191121 - AdequaÁ„o para release 12.1.25
     cRet  := "N„o"
     nQtdeMinEst := 999999
     dbselectarea("SB1")
     dbsetorder(1)
     dbseek(xFilial("SB1")+cProduto)
     if found()
     	dbselectarea("SB2")
     	dbsetorder(1)
     	dbseek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
     	If found() .and. !Empty(SB2->B2_LOCALIZ)
	        cRet := "Sim" // Produto c/ Quadrante, entrega imediata
    	Else
        	// Se n„o tiver quadrante, verificar se atinge a cota mÌnima para venda de produto estoque
	      DbSelectArea("SZ5")
    	   DbSetOrder(1)
        	DbSeek(xFilial("SZ5")+SubStr(cProduto, 11, 2), .t.)
	      If Found()
    	       nQtdeMinEst := SZ5->Z5_QTDVEN
        	Endif
	      If nQtde >= nQtdeMinEst
    	      cRet := "Sim"
        	Else
	         cRet := "N„o"
    	   Endif
	   Endif
	  endif 	    
	   U_VoltaArea(aAreaAnt)
	   if !empty( _cArea )
 		   DbSelectArea( _cArea )
 	   endif 
Return(cRet)

/*********************************************************************************/
/*** FunÁ„o para retornar o percentual de comiss„o, baseado no cÛdigo do clien-***/
/*** te e no TES utilizado.                                                    ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data : 04/11/05                                                           ***/
/*********************************************************************************/
User Function CalcComis(_cCliente, _cTes, _cProd, _nPreco, _cCond)
     Local _cArea   := alias()
     Local aAreaAnt := U_PegaArea({"SE4","SB5","SB1","SF4","SA1"})
     Local aVenctos, aPrazos,cUf, nPrazoMedio, lProdEstoque, nLc1, nLc2, nPerInt, nValTab, _nPercIcms,;
           _nBaseIcms, nJuros, nValorHoje, nQtdeParc, i, nAux, _nLucroItem, nAuxLucro, _nMedLucro,  ;
           _nLucroCal, _nComisCal, nRet
     Local _nPosSC6 := n  //LGS#20191121 - AdequaÁ„o para release 12.1.25
     Local _nPosTES := aScan(aHeader, { |x| Alltrim( x[2] ) == "C6_TES"     } )  //LGS#20191121 - AdequaÁ„o para release 12.1.25
     Local _nPosPRO := aScan(aHeader, { |x| Alltrim( x[2] ) == "C6_PRODUTO" } )  //LGS#20191121 - AdequaÁ„o para release 12.1.25
     Local _nPosPRC := aScan(aHeader, { |x| Alltrim( x[2] ) == "C6_PRCVEN"  } )  //LGS#20191121 - AdequaÁ„o para release 12.1.25
     Local cMVESTADO := SUPERGETMV("MV_ESTADO",.F.,"SP")
     Local nMVICMPAD := SUPERGETMV("MV_ICMPAD",.F.,18)
     Local nMVJUROS := SUPERGETMV("MV_JUROS",.F.,1.0)
     
     _cTes   := Iif( Empty( _cTES   ), aCols[ _nPosSC6][ _nPosTES], _cTES   ) //LGS#20191121 - AdequaÁ„o para release 12.1.25
     _cProd  := Iif( Empty( _cProd  ), aCols[ _nPosSC6][ _nPosPRO], _cProd  ) //LGS#20191121 - AdequaÁ„o para release 12.1.25
     _nPreco := Iif( Empty( _nPreco ), aCols[ _nPosSC6][ _nPosPRC], _nPreco ) //LGS#20191121 - AdequaÁ„o para release 12.1.25
     
     aVenctos := {}
     aPrazos  := {}
     nRet     := 0
	 DbSelectArea("SE4")
     DbSetOrder(1)

     DbSelectArea("SB1")
     DbSetOrder(1)

     Dbselectarea("SB5")
     DbSetOrder(1)

     DbSelectArea("SF4")
     DbSetOrder(1)

     DbSelectArea("SA1")
     DbSetOrder(1)

     DbSeek(xFilial("SA1")+_cCliente, .t.)
     If found()
        cUf := SA1->A1_EST
        DbSelectArea("SF4")
        DbSeek(xFilial("SF4")+_cTes)
        If Found()
           DbSelectArea("SB1")
           DbSeek(xFilial("SB1")+_cProd)
           If found()
              DbSelectArea("SE4")  // CondiÁ„o de Pagamento
              DbSeek(xFilial("SE4")+_cCond)
              If Found() // Cria vetor com prazos de pagamento
                 If (SE4->E4_TIPO # "9")
                    aVenctos := Condicao(100, _cCond, 0.00, dDataBase, 0.00)
                 Else
                    // Considerar condiÁ„o padr„o, pois n„o p/ tipo 9 teria que observar os datas referenciadas no pedido
                    aVenctos := Condicao(0, "010", 0.00, dDataBase, 0.00)
                 Endif
                 aPrazos     := {} // Vetor com prazos em dias e c·lculo do prazo mÈdio
                 nPrazoMedio := 0
                 For i := 1 to Len(aVenctos)
                     aadd(aPrazos, aVenctos[i,1] - dDataBase)
                     nPrazoMedio += aPrazos[i]
                 Next
                 If Len(aVenctos) > 0
                    nPrazoMedio := nPrazoMedio / Len(aVenctos)
                 Endif
                 lProdEstoque := Iif((SB1->B1_ESTOQUE == "S"), .t., .f.)
                 nLc1         := SB1->B1_COMIS + SB1->B1_LUCRO
                 nLc2         := SB1->B1_COMIS + SB1->B1_LUCRO2
                 nPerInt      := SB1->B1_PERINT / 100
                 If lProdEstoque
                    nValTab := SB1->B1_PRV1 //Em princÌpio, fica com o valor tabela 1, logo abaixo, se for o caso troca caso n„o seja produto de estoque
                 Else
                    DbSelectArea("SB5")
                    DbSeek(xFilial("SB5")+_cProd)
                    If Found()
                       nValTab := SB5->B5_PRV2
                    Endif
                 Endif

                 // DefiniÁ„o da Base de ICMS p/ fins de apuraÁ„o de Lucro e Comiss„o
                 _nPercIcms := 0
                 _nBaseIcms := 0
                 If SF4->F4_ICM == "S"
                    _nBaseIcms := _nPreco
                    If (SF4->F4_IPI == "S") .AND. (SF4->F4_INCIDE == "S")
                       _nBaseIcms := _nBaseIcms * (1 + (SB1->B1_IPI / 100))
                    Endif     
                    
        			if cUf = "EX"
          				_nPercIcms := 0
        			else
	         			If (SA1->A1_CLAS = "N") .OR. (cMVESTADO = cUf) 
	         				IF (cMVESTADO = cUf) .AND. (cMVESTADO = "SP") .AND. (SB1->B1_GRTRIB = '003')
	         					//25% ICMS para produtos 100% solvente puro
		         				_nPercIcms = 25
		         			else
	    	              		_nPercIcms = nMVICMPAD
	        	    		endif 
               			Else
                  			If cUf $ "MG_PR_RJ_RS_SC_SP"
                     			_nPercIcms = 12
	                  		Else
    	                 		_nPercIcms = 7
        	          		Endif
            	   		Endif
            		endif 

                 Endif
                 nJuros     := nMVJUROS
                 nValorHoje := 0
                 nQtdeParc  := Len(aPrazos)
                 For i := 1 To nQtdeParc
                     nAux       := (_nPreco / nQtdeParc) / ((1 + (nJuros / 100)) ^ ((12 * aPrazos[i]) / 365))
                     nValorHoje := nValorHoje + nAux
                 Next
                 //Valor do lucro+comissao da empresa no preco praticado
                 _nLucroItem := nValorHoje - (_nPreco * (SB1->B1_PERINT / 100)) - SB1->B1_CUSTOR  - (_nBaseIcms * _nPercIcms / 100)

                 //Media de Comissao e Lucro Minimo.
                 If !lProdEstoque // .and. ((aCols[_x][nPosQtdVen] * Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)) < nQtdeMinEst)
                    nAuxLucro := SB1->B1_LUCROM2
                 Else
                    nAuxLucro := SB1->B1_LCRMIN
                 Endif
                 _nMedLucro  := nAuxLucro
                 // % de lucro obtido
                 _nLucroCal  := ((_nLucroItem - (_nPreco * (SB1->B1_COMIS / 100))) / _nPreco) * 100

                 // Se o lucro da empresa praticado no preco do pedido for menor que o Lucro Minimo
                 // abate esta diferenca da comissao do representante.
                 If _nLucroCal >= _nMedLucro
                    _nComisCal := SB1->B1_COMIS
                 Else
                    _nLucroCal   := _nMedLucro
                    _nComisCal   := ((_nLucroItem - ((_nLucroCal * _nPreco) / 100)) / _nPreco) * 100
                 Endif
                 nRet = Round(_nComisCal, 2)
              Endif 		
           Endif 
        Endif 
     Endif 

	U_VoltaArea(aAreaAnt)
	if !empty( _cArea )
 		DbSelectArea( _cArea )
 	endif 
Return(nRet)

/*********************************************************************************/
/*** FunÁ„o para mostrar histÛrico de movimentaÁ„o do pedido.                  ***/
/*** Autor: Luis Gustavo de Souza                                              ***/
/*** Data : 14/09/05                                                           ***/
/*********************************************************************************/
User Function fHisPed(nOpc)
     Local oDlgHis, oGrp1, oLBXHis
     Local cLBXHis := ""
     Local cQry1   := ""
     Local aLog    := {}
     Local cLog    := ""

     If nOpc == 2
        DbSelectArea("LPD")
        If RecCount() <= 0
           MsgBox("N„o existem registros para serem mostrados !", "AtenÁ„o...", "STOP")
           Return
        Endif
     Endif
     cQry1 += "SELECT ZZB_PEDIDO,ZZB_IDLOG,ZZB_USRLOG,ZZB_DATLOG,ZZB_HORLOG "
     cQry1 += "FROM "+RetSqlName("ZZB")+" ZZB WITH (NOLOCK) "
     cQry1 += "WHERE ZZB.ZZB_FILIAL = '"+xFilial("ZZB")+"' "
     cQry1 += "  AND ZZB.D_E_L_E_T_ = '' "
     If nOpc == 1
        cQry1 += "  AND ZZB.ZZB_PEDIDO = '"+M->C5_NUM+"' "
     Else
        cQry1 += "  AND ZZB.ZZB_PEDIDO = '"+LPD->PEDIDO+"' "
     Endif
     cQry1 += "  AND ZZB.ZZB_IDLOG NOT IN('001', '002', '003', '004', '005', '006', '007', '008', '009', '010') "
     cQry1 += "ORDER BY R_E_C_N_O_ DESC "
     TCQUERY cQry1 ALIAS "TCQ" NEW
     DbSelectArea("TCQ")
     DbGoTop()
     While !Eof()
           DO CASE
              CASE TCQ->ZZB_IDLOG $ 'INC'
                   cLog := "Inclus„o de Pedido"
              CASE TCQ->ZZB_IDLOG $ 'ALT'
                   cLog := "AlteraÁ„o de Pedido"
              CASE TCQ->ZZB_IDLOG $ 'EXC'
                   cLog := "Exclus„o de Pedido"
              CASE TCQ->ZZB_IDLOG $ 'LCA'
                   cLog := "LiberaÁ„o de Cadastro"
              CASE TCQ->ZZB_IDLOG $ 'LVE'
                   cLog := "LiberaÁ„o de Vendas"
              CASE TCQ->ZZB_IDLOG $ 'LCR'
                   cLog := "LiberaÁ„o de CrÈdito"
              CASE TCQ->ZZB_IDLOG $ 'LDI'
                   cLog := "LiberaÁ„o da Diretoria"
              CASE TCQ->ZZB_IDLOG $ 'APR'
                   cLog := "AprovaÁ„o do Pedido"
              CASE TCQ->ZZB_IDLOG $ 'REC'
                   cLog := "Pedido Recusado"
              CASE TCQ->ZZB_IDLOG $ 'ERE'
                   cLog := "Estorno de Pedido Recusado"
              CASE TCQ->ZZB_IDLOG $ 'IAU'
                   cLog := "Impress„o autom·tica"
              CASE TCQ->ZZB_IDLOG $ 'IMA'
                   cLog := "Impress„o manual"
              CASE TCQ->ZZB_IDLOG $ 'IMV'
                   cLog := "Impress„o manual V"
              CASE TCQ->ZZB_IDLOG $ 'IMI'
                   cLog := "Impress„o manual I"
              CASE TCQ->ZZB_IDLOG $ 'FAT'
                   cLog := "Pedido Faturado"
              OTHERWISE
                   cLog := TCQ->ZZB_IDLOG
           ENDCASE
           aadd(aLog, {cLog, TCQ->ZZB_USRLOG, SubStr(TCQ->ZZB_DATLOG, 7, 2)+'/'+SubStr(TCQ->ZZB_DATLOG, 5, 2)+'/'+SubStr(TCQ->ZZB_DATLOG, 1, 4), TCQ->ZZB_HORLOG })
           DbSelectArea("TCQ")
           DbSkip()
     Enddo
     DbSelectArea("TCQ")
     DbCloseArea()
     If Len(aLog) <= 0
        aadd(aLog, {'', '', '', ''})
     Endif
     DEFINE MSDIALOG oDlgHis TITLE OemToAnsi( "HistÛrico do Pedido" ) FROM 000,000 TO 020, 080 OF oMainWnd
            DEFINE FONT oFont1 NAME 'COURIER NEW' SIZE 6,0
            @ 005,005 GROUP oGrp1 TO 146,312 LABEL OemToAnsi("Movimentos") COLOR CLR_HRED PIXEL OF oDlgHis
            @ 010,007 LISTBOX oLBXHis VAR cLBXHis FIELDS HEADER OemToAnsi('Log'), OemToAnsi('Usu·rio'), OemToAnsi('Data'), OemToAnsi('Hora') SIZE 302,131 PIXEL OF oDlgHis
             bHisLin := { || { aLog[oLBXHis:nAt][1], aLog[oLBXHis:nAt][2], aLog[oLBXHis:nAt][3], aLog[oLBXHis:nAt][4] } }
            oLBXHis:SetArray( aLog )
            oLBXHis:bLine  := bHisLin
            oLBXHis:GoTop()
            oDlgHis:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     ACTIVATE MSDIALOG oDlgHis CENTERED
Return Nil

/*********************************************************************************/
/*** FunÁ„o para substituir caracteres especiais, como acento, etc... ⁄til para***/
/*** impress„o em impressoras matriciais.                                      ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data : 26/02/03                                                           ***/
/*********************************************************************************/
User Function TiraAcento(cExpressao)
     Local cProcurarPor   := "¡…Õ”⁄·ÈÌÛ˙¿»Ã“Ÿ‡ËÏÚ˘¬ Œ‘€‚ÍÓÙ˚ƒÀœ÷‹‰ÎÔˆ¸√’„ı«Á—Ò∫"+chr(13)+chr(10)
     Local cSubstituirPor := "AEIOUaeiouAEIOUaeiouAEIOUaeiouAEIOUaeiouAOaoCcNno  "
     Local cExpressaoRetorno
     
     cExpressaoRetorno = U_ChrTran(cExpressao, cProcurarPor, cSubstituirPor)

Return(cExpressaoRetorno)

/*********************************************************************************/
/*** FunÁ„o que verifica a existÍncia de caracteres de cProcurarPor e substitui***/
/*** por correspondente em cSubstituirPor.                                     ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data : 27/02/2003                                                         ***/
/*********************************************************************************/
User Function ChrTran(cExpressao, cProcurarPor, cSubstituirPor)
     Local cExpressaoRetorno := cExpressao
     Local i

     For i := 1 to Len(cProcurarPor)
         cExPressaoRetorno := StrTran(cExpressaoRetorno, SubStr(cProcurarPor, i, 1), SubStr(cSubstituirPor, i, 1))
     Next

Return(cExpressaoRetorno)

/*********************************************************************************/
/*** FunÁ„o para ler linha de arquivo texto                                    ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data : 27/02/2003                                                         ***/
/*********************************************************************************/
User Function fgets(nArq)
     Local cRet     := ""
     Local cChar    := ""
//     Local cComp    := ""

     While (cChar != chr(1)) .and. (cChar != chr(10)) 
     	fRead(nArq, @cChar, 1)
		cRet     += cChar
     EndDo
Return(cRet)

/*********************************************************************************/
/*** FunÁ„o para determinar se determinada quantidade de um produto tem permis-***/
/*** s„o para volumes quebrados. Retorna verdadeiro ou falso p/ qtde vol irre- ***/
/*** gular.                                                                    ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data : 05/03/2004                                                         ***/
/*** Data : 15/01/2008 (Cleber) BM e BL tiveram exceÁ„o p/ vol quebrados	   ***/
/*** Data : 02/08/2011 (Cleber) Apenas BL tiveram exceÁ„o p/ vol quebrados	   ***/
/*********************************************************************************/
User Function VolQuebrado(cProduto, nQtde)
     Local cArea    := alias()
     Local aAreaAnt := U_PegaArea({"SZ1","SB1","SG1","SZ5","SA1"})
     Local nQtdeVol, nRelVol, i, nAux, lVolIrregular,;
           lEmbaemG1, nQtdeEmba, nResto, nPos1, nPos2, nRelAnt, cVolJunto, cQuery,;
           nLotVen
           
//nLotVen := Qtde MÌnima de Venda           

if empty(cProduto) .or. (nQtde <= 0)
	return(.t.)
endif 
     nQtdeEmba := nQtde

     DbSelectArea("SZ1")              //Linhas de produto
     DbSetOrder(1)

     DbSelectArea("SB1")              // Produtos
     DbSetOrder(1)

     DbSelectArea("SG1")              // Estruturas
     DbSetOrder(1)

     DbSelectArea("SZ5")              // Rel. Volumes
     DbSetOrder(1)

cVolJunto := "N"
lVolIrregular := .f.
DbSelectArea("SB1")
DbSeek(xFilial("SB1")+cProduto)
if found()
	nLotVen := SB1->B1_LOTVEN
//	cVolJunto := iif((SB1->B1_TIPO = "PA"),alltrim(SB1->B1_VOLJUNT),"S")
	cVolJunto := alltrim(SB1->B1_VOLJUNT)
	if (Len(alltrim(cProduto)) == 12) .and. (SB1->B1_RELVOL <= 0) //.AND. (SB1->B1_TIPO = "PA")
   	 	if !(cVolJunto == "S") 
       	   	DbSelectArea("SZ1")
    		DbSeek(xFilial("SZ1")+SubStr(cProduto,4,2))
	     	if found()
				cVolJunto := alltrim(SZ1->Z1_VOLJUNT)
			endif
		endif 
//**********************************
		nQtdeVol     := 0
  		lEmbaemG1 := .f. //Identifica se h· tipo de embalagem na estrutura, caso contr·rio pega dos 2 dÌg. finais do cÛdigo do produto
    	cQuery := "SELECT B1_RELCAT1 AS EMBA,SUM(G1_QUANT) AS QTDE,MAX(Z5_RELVOL) AS RELVOL "+;
    	"FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "+;
		"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (G1_COMP = SB1.B1_COD) "+;
		"LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON (SZ5.D_E_L_E_T_ <> '*') AND (SZ5.Z5_FILIAL = '"+xFilial("SZ5")+"') AND (B1_RELCAT1 = Z5_EMB) "+;
		"WHERE (SG1.D_E_L_E_T_ <> '*') AND (G1_FILIAL = '"+xFilial("SG1")+"') AND (LEN(G1_COMP) = 4) AND (B1_RELCAT1 > '') "+;
		"AND (G1_COD = '"+cProduto+"') GROUP BY G1_COD,B1_RELCAT1"
		TCQuery cQuery ALIAS "TMPVOL" NEW
  		dbselectarea("TMPVOL")
    	if !eof() .and. !bof()
     		lEmbaemG1 := .t.
     		cRelVol  := Alltrim(TMPVOL->RELVOL)
       		nResto     = -1
         	nQtdeEmba := nQtde*TMPVOL->QTDE
          	While (nResto != 0)
           		nRelVol := 0
             	nRelAnt := 0
              	nPos1   := 1
               	For i := 1 to len(cRelVol)
                	If !isDigit(SubStr(cRelVol, i, 1)) .or. (i == Len(cRelVol))
                 		nPos2 := Iif(i == Len(cRelVol), i+1, i)
                   		nAux  := Val(SubStr(cRelVol, nPos1, nPos2-nPos1))
                     	nRelAnt := nRelVol
                      	nRelVol := nAux
                       	If (nQtdeEmba <= nAux) .or. (i == Len(cRelVol))
                        	Exit
                       	Endif
                       	nPos1 := nPos2 + 1
                 	Endif               
               	Next
                If nRelVol > 0
                	If (nRelAnt > 0) .and. (nQtdeEmba < nRelVol) .and. (nQtdeEmba > nRelAnt)
                 		nRelVol := nRelAnt
                   	Endif 
                    nAuxVol = nQtdeEmba/nRelVol  
                    nResto := (nAuxVol - int(nAuxVol)) 
                    If nResto > 0
                    	If Int(nAuxVol) > 0
                     		nQtdeVol += Int(nAuxVol)
                       	Else
                        	Exit
                       	Endif
                        nQtdeEmba := nQtdeEmba - (Int(nAuxVol) * nRelVol)
                 	Endif 
             	Else
              		nResto := 0
                Endif 
       		Enddo
         	If (nResto > 0) .and. (cVolJunto != "S")
          		lVolIrregular := .t.
            Endif
      	Endif
		dbselectarea("TMPVOL")
		dbclosearea()
       	If !lEmbaemG1 .and. (SubStr(cProduto, 11, 2) # "00") // Se n„o tiver cÛd. de embalagem na estrutura, pegar pelo final do cÛd. do prod.
        	DbSelectArea("SZ5")
         	If DbSeek(xFilial("SZ5")+SubStr(cProduto, 11, 2))
          		cRelVol := Alltrim(SZ5->Z5_RELVOL)
            	nResto  := -1
             	While (nResto != 0)
              		nRelVol := 0
                	nRelAnt := 0
                 	nPos1   := 1
                  	For i := 1 to len(cRelVol)
                   		If !isDigit(substr(cRelVol, i, 1)) .or. (i == Len(cRelVol))
                     		nPos2   := Iif(i == Len(cRelVol), i+1, i)
                       		nAux    := Val(SubStr(cRelVol, nPos1, nPos2-nPos1))
                         	nRelAnt := nRelVol
                          	nRelVol := nAux
                           	If (nQtdeEmba <= nAux) .or. (i == Len(cRelVol))
                            	Exit
                           	Endif
                            nPos1 := nPos2+1
                     	Endif               
                  	Next
                   	If nRelVol > 0
                    	If (nRelAnt > 0) .and. (nQtdeEmba < nRelVol) .and. (nQtdeEmba > nRelAnt)
                     		nRelVol := nRelAnt
                       	Endif
                  		nAuxVol := nQtdeEmba/nRelVol  
                    	nResto  := (nAuxVol - Int(nAuxVol))
                     	If nResto > 0
                      		If Int(nAuxVol) > 0
                        		nQtdeVol += Int(nAuxVol)
                          	Else
                           		Exit
                           	Endif
                            nQtdeEmba := nQtdeEmba - (Int(nAuxVol)*nRelVol)
                     	Endif 
                 	Else
                 		nResto := 0
                   	Endif 
            	Enddo 	
             	If (nResto > 0) .and. (cVolJunto != "S")
              		lVolIrregular := .t.
                Endif
    		Endif
    	Endif
	Else   
		nRelVol := SB1->B1_RELVOL
  		nAux := iif(nRelVol > 0,round(nQtdeEmba/nRelVol,3),0)
    	If (nAux == 0) .OR. ((int(nAux) < nAux) .and. (cVolJunto != "S"))
     		lVolIrregular := .t.
	 	Endif
 	Endif
endif 

/* //Cleber (19/08/15) -> retirada exceÁ„o pra BL
// ExceÁ„o para BL's, criada em 15/Jan/08 
if !lVolIrregular .and. (len(alltrim(cProduto)) == 12) .and. !(SubStr(cProduto, 11, 2) $ "00.99") .and. (substr(cProduto,1,2) = "BL")
	nAux = iif(nRelVol > nQtdeEmba,nQtdeEmba,round(((nQtdeEmba/nRelVol) - int(nQtdeEmba/nRelVol))*nRelVol,0))
	if (nLotVen = 0) .and. (nAux > 0) .and. ((nRelVol/nAux) != 2)
		lVolIrregular := .t.                                  
	endif 
endif 			
*/

U_VoltaArea(aAreaAnt)
if !empty(cArea)
	DbSelectArea(cArea)
endif 
		
Return(lVolIrregular)

/*********************************************************************************/
/*** FunÁ„o para editar uma tabela especÌficas do cadastro de tabelas (SX5)    ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data : 14/11/2002                                                         ***/
/*********************************************************************************/
User Function EditaX5(_cTab, _cPict)
     Local _ni,aTabela,i,aAux
     Local cSx3
     Local lAbriu  := .f.
     Private cTabela := _cTab
     nOpcx := 3

     //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
     //≥ Montando aHeader                                             ≥
     //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
     cSx3 := U_NovoCursor()
    lAbriu := Select(cSx3) > 0
    IF !lAbriu
    	Messagebox("ImpossÌvel Abrir Tabela SX3!!","Erro!",48)
    	return(.f.)
    endif
     	
    
     
     DbSelectArea(cSx3)
     DbSetOrder(1)
     DbSeek("SX5")
     nUsado  := 0
     aHeader := {}
     While !Eof() .And. ((cSx3)->(X3_ARQUIVO) == "SX5")
           If X3USO((cSx3)->(X3_USADO)) .AND. cNivel >= (cSx3)->(X3_NIVEL) .and. (Alltrim((cSx3)->(X3_CAMPO)) != "X5_TABELA")
              nUsado := nUsado + 1
              Do Case
                 Case Alltrim((cSx3)->(X3_CAMPO)) == "X5_CHAVE"
                      aAdd(aHeader, { TRIM((cSx3)->(X3_TITULO)), (cSx3)->(X3_CAMPO), _cPict, (cSx3)->(X3_TAMANHO), (cSx3)->(X3_DECIMAL), "U_VldX5_CHAVE()", (cSx3)->(X3_USADO), (cSx3)->(X3_TIPO), (cSx3)->(X3_ARQUIVO), (cSx3)->(X3_CONTEXT) } )
                 OtherWise
                      aAdd(aHeader, { TRIM((cSx3)->(X3_TITULO)), (cSx3)->(X3_CAMPO), (cSx3)->(X3_PICTURE), (cSx3)->(X3_TAMANHO), (cSx3)->(X3_DECIMAL), (cSx3)->(X3_VALID), (cSx3)->(X3_USADO), (cSx3)->(X3_TIPO), (cSx3)->(X3_ARQUIVO), (cSx3)->(X3_CONTEXT) } )
              EndCase
           Endif
           DbSkip()
     EndDo

     //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
     //≥ Montando aCols                                               ≥
     //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
     aCols := Array(1, nUsado+1)
     DbSelectArea(cSx3)
     DbSeek("SX5")
     nUsado := 0
     While !Eof() .And. ((cSx3)->(X3_ARQUIVO) == "SX5")
           If X3USO((cSx3)->(X3_USADO)) .AND. cNivel >= (cSx3)->(X3_NIVEL) .and. (Alltrim((cSx3)->(X3_CAMPO)) != "X5_TABELA")
              nUsado := nUsado + 1
              If nOpcx == 3
                 If (cSx3)->(X3_TIPO) == "C"
                    aCols[1][nUsado] := SPACE((cSx3)->(X3_TAMANHO))
                 ElseIf (cSx3)->(X3_TIPO) == "N"
                        aCols[1][nUsado] := 0
                 Elseif (cSx3)->(x3_tipo) == "D"
                        aCols[1][nUsado] := dDataBase
                 Elseif (cSx3)->(x3_tipo) == "M"
                        aCols[1][nUsado] := ""
                 Else
                    aCols[1][nUsado] := .F.
                 Endif
              Endif
           Endif
           DbSkip()
     EndDo
     dbselectarea(cSx3)
     DbCloseArea()

     aTabela := FWGetSX5( cTabela )
     aCols[1][nUsado+1] := .F.
     //DbSelectArea("SX5")
     
     //DbSetOrder(1)
     //DbSeek(xFilial("SX5")+cTabela)
     
     //If Found()
     if len(aTabela) > 0
     
        aCols := {}
        for i := 1 to len(aTabela)
        //While !Eof() .and. (xFilial("SX5") == SX5->X5_FILIAL) .and. (SX5->X5_TABELA == cTabela)
              aAdd(aCols, Array(nUsado+1))
              For _ni := 1 to nUsado
                  aCols[Len(aCols)][_ni]  := FieldGet(FieldPos(aHeader[_ni][2]))
              Next
              aCols[Len(aCols)][nUsado+1] := .F.
              //DbSkip()
        Endfor
     Endif
     aAux := FWGetSX5( "00",cTabela )
     cTitulo := iif(len(aAux) > 0,aAux[1][4],"")
/*     nRegistro := RecNo()
     DbSelectArea("SX5")
     DbSeek(cFilial+"00"+cTabela)
     cTitulo :=  Iif(!Eof( ), X5Descri(), "" )
     DbGoTo(nRegistro) */

     //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
     //≥ Array com descricao dos campos do Cabecalho do Modelo 2      ≥
     //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
     aC := {}
     // aC[n,1] = Nome da Variavel Ex.:"cCliente"
     // aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
     // aC[n,3] = Titulo do Campo
     // aC[n,4] = Picture
     // aC[n,5] = Validacao
     // aC[n,6] = F3
     // aC[n,7] = Se campo e' editavel .t. se nao .f.
     aAdd(aC, {"cTabela", {15, 10}, "Tabela" , "@!", "AllwaysTrue()", , .f.})

     //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
     //≥ Array com descricao dos campos do Rodape do Modelo 2         ≥
     //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
     aR := {}
     // aR[n,1] = Nome da Variavel Ex.:"cCliente"
     // aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
     // aR[n,3] = Titulo do Campo
     // aR[n,4] = Picture
     // aR[n,5] = Validacao
     // aR[n,6] = F3
     // aR[n,7] = Se campo e' editavel .t. se nao .f.
     //AADD(aR, {"nLinGetD", {120, 10}, "Linha na GetDados", "@E 999", , , .F.})
     //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
     //≥ Array com coordenadas da GetDados no modelo2                 ≥
     //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
     aCGD := {044, 005, 118, 315}
     //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
     //≥ Validacoes na GetDados da Modelo 2                           ≥
     //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
     cLinhaOk := ".T."
     cTudoOk  := ".T."
     //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
     //≥ Chamada da Modelo2                                           ≥
     //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
     // lRetMod2 = .t. se confirmou 
     // lRetMod2 = .f. se cancelou
     lRetMod2 := Modelo2(cTitulo, aC, aR, aCGD, nOpcx, cLinhaOk, cTudoOk)
     // No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
     // objeto Getdados Corrente
     If lRetMod2
        C160Grava("SX5", cTabela)
     Endif
Return

/*********************************************************************************/
/*** FunÁ„o que valida a digitaÁ„o do campo X5_CHAVE para evitar duplicidade   ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data : 14/11/2002                                                         ***/
/*********************************************************************************/
User Function VldX5_CHAVE()
     Local lRet := .t.
     Local _x, nPosCHAVE, cAux, i

     If Empty(M->X5_CHAVE)
        lRet := .f.
     Else
        If !aCols[n][Len(aHeader)+1] // Se n„o for reg. deletado
           nPosCHAVE := 0
           For i := 1 to Len(aHeader)
               cAux := Upper(Alltrim(aHeader[i][2]))
               Do Case
                  Case cAux == "X5_CHAVE"
                       nPosCHAVE := i
               EndCase
           Next
           If nPosCHAVE > 0
              cCodPro := aCols[n][nPosCHAVE]
              For _x := 1 to Len(aCols)
                  If (_x # n) .and. (aCols[_x][nPosCHAVE] == M->X5_CHAVE) .and. !aCols[_x][Len(aHeader)+1]
                     lRet := .f.
                     Exit
                  Endif
              Next
           Endif
           If !lRet
              MsgBox("Existe item em duplicidade!", "AtenÁ„o...", "STOP")
           Endif
        Endif
     Endif
Return(lRet)

/*********************************************************************************/
/*** FunÁ„o para determinar se determinado produto junta volume ou n„o         ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data : 10/04/2006                                                         ***/
/*********************************************************************************/
User Function VolJunto(cProduto)
     Local cArea    := alias()
     Local aAreaAnt := U_PegaArea({"SZ1","SB1"})
     Local lVoljunto
     If Len(Alltrim(cProduto)) <> 12
        Return(.f.)
     Endif


     Dbselectarea("SZ1")    // Linhas de Produtos
     Dbsetorder(1)

     DbSelectArea("SB1")    // Produtos
     Dbsetorder(1)

	lVoljunto := .f.
	Dbselectarea("SB1")
	Dbseek(xFilial("SB1")+cProduto)
	If Found() 
     	if (SB1->B1_TIPO = "PA") .AND. (SB1->B1_VOLJUNT = "S")
	        lVoljunto := .t.
		Endif
     	If !lVoljunto .and. (SB1->B1_TIPO = "PA")
        	DbSelectArea("SZ1")
	        DbSeek(xFilial("SZ1")+substr(cProduto,4,2))
    	    If Found() .and. (SZ1->Z1_VOLJUNT = "S")
        	   lVoljunto := .t.
	        Endif
  		Endif
	endif 

U_VoltaArea(aAreaAnt)
if !empty(cArea)
	DbSelectArea(cArea)
endif 
Return(lVoljunto)

/*********************************************************************************/
/*** FunÁ„o p/ determinar a quantidade de volumes de uma determinada embalagem ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data : 29/03/2004                                                         ***/
/*********************************************************************************/
User Function DetVolEmba(cRelVol,nQtde)
     Local nQtdeVol, nRelVol, i, nAux,  nPos1, nPos2,;
           nResto, nQtdeEmba, nRelAnt
	Local aArea := GetArea()
     nQtdeEmba := nQtde


     nQtdeVol := 0
        nResto  := -1
        While nResto != 0
              nRelVol := 0
              nRelAnt := 0
              nPos1 := 1
              For i := 1 to Len(cRelVol)
                  If !IsDigit(SubStr(cRelVol, i, 1)) .or. (i == Len(cRelVol))
                     nPos2   := Iif(i == Len(cRelVol), i+1, i)
                     nAux    := Val(SubStr(cRelVol, nPos1, nPos2-nPos1))
                     nRelAnt := nRelVol
                     nRelVol := nAux
                     If (nQtdeEmba <= nAux) .or. (i == Len(cRelVol))
                        Exit
                     Endif
                     nPos1 := nPos2 + 1
                  Endif
              Next
              If nRelVol > 0
                 If (nRelAnt > 0) .and. (nQtdeEmba < nRelVol) .and. (nQtdeEmba > nRelAnt)
                    nRelVol := nRelAnt
                 Endif 
                 nAuxVol = nQtdeEmba / nRelVol  
                 nResto := (nAuxVol - Int(nAuxVol)) 
                 If Int(nAuxVol) > 0
                    nQtdeVol += int(nAuxVol)
                 Else
                    nQtdeVol += 1
                    nResto   := 0
                 Endif 
                 nQtdeEmba := nQtdeEmba - (Int(nAuxVol) * nRelVol)
              Endif 
        Enddo 	

RestArea(aArea)
Return(nQtdeVol)

/*User Function DetVolEmba(cEmba,nQtde)
     Local nQtdeVol, nRelVol, i, nAux, nArea, nRegZh, nIndZh, cRelVol, nPos1, nPos2,;
           nResto, nQtdeEmba, nRelAnt
     nQtdeEmba := nQtde
     nArea     := Alias()

     DbSelectArea("SZ5")     // Tipos de Embalagem
     nRegZh  := Recno()
     nIndZh  := IndexOrd()
     Dbsetorder(1)

     nQtdeVol := 0
     DbSelectArea("SZ5")
     If DbSeek(xFilial("SZ5")+cEmba)
        cRelVol := Alltrim(SZ5->Z5_RELVOL)
        nResto  := -1
        While nResto != 0
              nRelVol := 0
              nRelAnt := 0
              nPos1 := 1
              For i := 1 to Len(cRelVol)
                  If !IsDigit(SubStr(cRelVol, i, 1)) .or. (i == Len(cRelVol))
                     nPos2   := Iif(i == Len(cRelVol), i+1, i)
                     nAux    := Val(SubStr(cRelVol, nPos1, nPos2-nPos1))
                     nRelAnt := nRelVol
                     nRelVol := nAux
                     If (nQtdeEmba <= nAux) .or. (i == Len(cRelVol))
                        Exit
                     Endif
                     nPos1 := nPos2 + 1
                  Endif
              Next
              If nRelVol > 0
                 If (nRelAnt > 0) .and. (nQtdeEmba < nRelVol) .and. (nQtdeEmba > nRelAnt)
                    nRelVol := nRelAnt
                 Endif 
                 nAuxVol = nQtdeEmba / nRelVol  
                 nResto := (nAuxVol - Int(nAuxVol)) 
                 If Int(nAuxVol) > 0
                    nQtdeVol += int(nAuxVol)
                 Else
                    nQtdeVol += 1
                    nResto   := 0
                 Endif 
                 nQtdeEmba := nQtdeEmba - (Int(nAuxVol) * nRelVol)
              Endif 
        Enddo 	
     Endif

     DbSelectArea("SZ5")              // Tipos de Embalagem
     DbSetOrder(nIndZh)
     DbGoto(nRegZh)

	if !empty(nArea)
     	DbSelectArea(nArea)
 	endif 
Return(nQtdeVol)
*/
/*************************************************************************************/
/*** FunÁ„o p/ determinar se o volume   preenche toda a caixa ou se est· incompleto***/
/*** Autor: Cleber Orati Domingues                                                 ***/
/*** Data : 19/02/2008                                                             ***/
/*************************************************************************************/
User Function volcompl(cRelVol,nQtde)
//User Function volcompl(cEmba,nQtde)
     Local nQtdeVol, nRelVol, i, nAux, nArea,  nPos1, nPos2,;
           nResto, nQtdeEmba, nRelAnt,lRet

	lRet := .t.
     nQtdeEmba := nQtde
     nArea     := Alias()


     nQtdeVol := 0
	    nResto  := -1
        While nResto != 0
              nRelVol := 0
              nRelAnt := 0
              nPos1 := 1
              For i := 1 to Len(cRelVol)
                  If !IsDigit(SubStr(cRelVol, i, 1)) .or. (i == Len(cRelVol))
                     nPos2   := Iif(i == Len(cRelVol), i+1, i)
                     nAux    := Val(SubStr(cRelVol, nPos1, nPos2-nPos1))
                     nRelAnt := nRelVol
                     nRelVol := nAux
                     If (nQtdeEmba <= nAux) .or. (i == Len(cRelVol))
                        Exit
                     Endif
                     nPos1 := nPos2 + 1
                  Endif
              Next
              If nRelVol > 0
                 If (nRelAnt > 0) .and. (nQtdeEmba < nRelVol) .and. (nQtdeEmba > nRelAnt)
                    nRelVol := nRelAnt
                 Endif 
                 nAuxVol = nQtdeEmba / nRelVol  
                 nResto := (nAuxVol - Int(nAuxVol)) 
                 If Int(nAuxVol) > 0
                    nQtdeVol += int(nAuxVol)
                 Else
                 	lRet := .f.
                 	exit
                 Endif 
                 nQtdeEmba := nQtdeEmba - (Int(nAuxVol) * nRelVol)
              Endif 
        Enddo 	


	if !empty(nArea)
     	DbSelectArea(nArea)
 	endif 
Return(lRet)


/*********************************************************************************/
/*** Converte uma string em n˙mero                                             ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data :   /  /                                                             ***/
/*********************************************************************************/
User Function cTon(cValor)
     Local nValor, i, nPos, nVal1, nVal2, cAux
     For i := 1 to Len(cValor)
         nPos := i
         If SubStr(cValor, i, 1) $ ",."
            Exit
         Endif
     Next
     nVal1 := 0
     nVal2 := 0
     If nPos < Len(cValor)
        nVal1 := Val(SubStr(cValor, 1, nPos - 1))
        cAux := "1"
        For i := 1 to (Len(cValor) - nPos)
            cAux += "0"
        Next
        nVal2 := Val(SubStr(cValor, nPos + 1, Len(cValor) - nPos)) / Val(cAux)
     Else
        nVal1 := Val(cValor)
     Endif

     nValor = nVal1 + nVal2
Return(nValor)

/*********************************************************************************/
/*** FunÁ„o para calcular o custo unit·rio de materia prima de produto         ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data :   /04/2002                                                         ***/
/*** Alterado: 29/08/02 - Cleber Orati Domingues                               ***/
/***           Buscar, ao invÈs do custo mÈdio, o ˙ltimo preÁo do cadastro de  ***/
/***           produtos.                                                       ***/
/*** Alterado: 30/05/14 - Cleber Orati Domingues                               ***/
/***           Troca para chamada de funÁ„o SQL Server                         ***/
/*********************************************************************************/
User Function CustoPro(cProduto,_cFilial)
Local cArea, nCusto, cAlias, cQry, _cFil

_cFil := iif(pcount() > 1,_cFilial,xFilial("SG1"))
	
	cArea  := Alias()
	//Cleber (30/05/2014) -> ExecuÁ„o funÁ„o SQL Server     
	cQry := "SELECT dbo.CustoMp"+;
	iif(substr(cNumEmp,1,2) == "05","05","")+;
	"('"+_cFil+"','"+cProduto+"',1) AS CUSTO"    
	cAlias := U_NovoCursor()
 	DbUseArea(.T., "TOPCONN", TcGenQry( , , cQry), cAlias, .T., .T.)
  	DbSelectArea(cAlias)
   	DbGoTop()
    if !eof() .and. !bof()
		nCusto := (cAlias)->CUSTO
	else
		nCusto := 0
	endif          
	DbSelectArea(cAlias)
  	dbclosearea()
	if !empty(cArea)
 		DbSelectArea(cArea)
 	endif 
Return(nCusto)

/*********************************************************************************/
/*** FunÁ„o para calcular o custo unit·rio de materia prima de produto         ***/
/*** convertendo mat. primas dolarizadas do valor do dolar para reais          ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data :  18/09/2009                                                         ***/
/*********************************************************************************/
User Function DCustoPro(cProduto,nDolar)
Local cArea, nCusto, cAlias, cQry,cDolar

	cArea  := Alias() 
	
	//Cleber (30/05/2014) -> ExecuÁ„o funÁ„o SQL Server     
	cDolar = transform(nDolar,"9999.99999")
	cQry := "SELECT dbo.CustoMpD('"+xFilial("SG1")+"','"+cProduto+"',1,"+cDolar+") AS CUSTO"    
	cAlias := U_NovoCursor()
 	DbUseArea(.T., "TOPCONN", TcGenQry( , , cQry), cAlias, .T., .T.)
  	DbSelectArea(cAlias)
   	DbGoTop()
    if !eof() .and. !bof()
		nCusto := (cAlias)->CUSTO
	else
		nCusto := 0
	endif          
  	DbSelectArea(cAlias)
  	dbclosearea()

	if !empty(cArea)
 		DbSelectArea(cArea)
 	endif 
Return(nCusto)


/*********************************************************************************/
/*** FunÁ„o para recalcular pesos especÌficos de PI's ‡ partir dos pesos espe- ***/
/*** cÌficos de materia prima. Usada apÛs alterar um peso especÌfico de alguma ***/
/*** matÈria prima.                                                            ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data : 17/05/2002                                                         ***/
/*********************************************************************************/
User Function CalcPesoEsp(cCodMatPri)
     Local nArea, nRegB1, nRegG1, nOrdB1, nOrdG1, cCodPro, nReg
     Local cUmFilha, cQuery, cFator,  cSg1

     nArea = Alias()
     DbSelectArea("SB1")
     nRegB1 = Recno()
     nOrdB1 = IndexOrd()
     DbSetOrder(1)
     DbSelectArea("SG1")
     nRegG1 = Recno()
     nOrdG1 = IndexOrd()
     DbSetOrder(2)
     DbSeek(xFilial("SG1")+cCodMatPri, .t.)
     While !Eof() .and. (SG1->G1_COMP == cCodMatPri) .and. (xFilial("SG1") == SG1->G1_FILIAL)
           // produto de custeio
           If U_IsProdCusto(SG1->G1_COMP)
              SG1->(dbSkip())
              Loop
           Endif 

           nReg = Recno()
           cUmFilha := ""
           DbSelectArea("SB1")
           DbSeek(xFilial("SB1")+SG1->G1_COMP)
           If Found()
              cUmFilha := SB1->B1_UM
           Endif
           cCodPro = SG1->G1_COD
           DbSeek(xFilial("SB1")+cCodPro)
           If found() .and. (SB1->B1_TIPO != "PA")
              cSg1 = RetSqlName("SG1") // Verifica qual arquivo SX2 aponta
              cQuery = "UPDATE "+RetSqlName("SB1")+" SET B1_PESOESP = "+;
                       "(100/(SELECT SUM(SG1.G1_PERC/SB1.B1_PESOESP) FROM "+cSg1+;
                       " SG1 WITH (NOLOCK) "+;
                       "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SG1.G1_COMP = SB1.B1_COD) WHERE "+;
                       "(G1_FILIAL = '"+xFilial("SG1")+"') AND (B1_FILIAL = '"+xFilial("SB1")+;
                       "') AND (SG1.G1_COD = '"+cCodPro+"') AND (SG1.D_E_L_E_T_ <> '*') AND (SB1.D_E_L_E_T_ <> '*') "+;
                       U_IsFQProdCusto() /* produto de custeio*/+;
                       ")) "+;
                       "WHERE (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = '"+cCodPro+"') AND (D_E_L_E_T_ <> '*') "
              TCSQLEXEC(cQuery)
              If cUmFilha != SB1->B1_UM
                 cFator := "(SELECT B1_PESOESP FROM "+RetSqlName("SB1")+" WITH (NOLOCK) "+;
                           "WHERE (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = '"+cCodPro+;
                           "') AND (D_E_L_E_T_ <> '*')) "
              Else
                 cFator := "1"
              EndIf

              cQuery := "UPDATE "+cSg1+" SET G1_QUANT = ((G1_PERC/100)*"+cFator+") "+;
                        "WHERE (G1_FILIAL = '"+xFilial("SG1")+"') AND "+;
                        "(G1_COD = '"+cCodPro+"') AND (D_E_L_E_T_ <> '*')"
              TCSQLEXEC(cQuery)

              DbSelectArea("SG1")
              DbSetOrder(2)
              DbSeek(xFilial("SG1")+cCodPro)
              If Found()
                 U_CalcPesoEsp(cCodPro)
              Endif
           Endif
           DbSelectArea("SG1")
           DbSetOrder(2)
           DbGoto(nReg)	
           DbSkip()
     Enddo

     DbSelectArea("SB1")
     DbSetOrder(nOrdB1)
     DbGoto(nRegB1)
     DbSelectArea("SG1")
     DbSetOrder(nOrdG1)
     DbGoto(nRegG1)
     DbSelectArea(nArea)
Return

/*********************************************************************************/
/*** FunÁ„o que retorna qual tabela no SQL o SX2 da empresa local est· apon-   ***/
/*** tanto                                                                     ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data : 01/04/2002                                                         ***/
/*********************************************************************************/
User Function VerSX2(cTabela)
     Local cRet, lAbriu, cAuxX2
     cRet   := ""
     lAbriu := .f.
     
     cAuxX2 := U_NovoCursor()
    // ABERTURA DO DICION¡RIO SX3
    OpenSXs(NIL, NIL, NIL, NIL, NIL, cAuxX2, "SX2", NIL, .F.)
    lAbriu := Select(cAuxX2) > 0


/*     
     If SELECT(cAuxX2) == 0
        lAbriu := .t.
        cAuxX2 := GetSrvProfString("StartPath", "")+"SX2"+substr(cnumemp,1,2)+"0"
        USE &cAuxX2 ALIAS SX2 NEW SHARED
        DbSetIndex(cAuxX2)
     Endif
*/     
    If lAbriu
        DbSelectArea(cAuxX2)
        (cAuxX2)->(DbSetOrder(1))
        Dbseek(cTabela)
        If Found()
        	cRet := Alltrim((cAuxX2)->(X2_ARQUIVO))
        Endif
        DbCloseArea()
     Endif
Return(cRet)


/*********************************************************************************/
/*** FunÁ„o para registrar as modificaÁıes em tabelas, para transmiss„o para   ***/
/*** representantes                                                            ***/
/*** tanto                                                                     ***/
/*** Autor: Cleber Orati Domingues                                             ***/
/*** Data : 25/03/2003                                                         ***/
/*** Param: cTabela - Tabela a ser considerada                                 ***/
/***        cChave  - Chave da tabela (geralmente cÛdigo)                      ***/
/***        lApagar - Define se refere-se a uma exclus„o ou n„o                ***/
/***        cVend   - CÛdigo do Representante, para as tab. SA1 e SC5          ***/
/*********************************************************************************/
User Function EnviaRec(cTabela, cChave, lApagar,cVend)
     Local lInclui
     Local cArea,cTable 
     cArea  := Alias()   
	if (cTabela $ "SA1_SC5") .and. empty(cVend)
		return(.t.)
	endif 
		
     DbSelectArea("ZZ6")
     DbSetOrder(1) //Filial+Empresa+Tabela+Chave
     DbSeek(xFilial("ZZ6")+xFilial(cTabela)+cTabela+alltrim(cChave))
     If Found()  
     	if (cTabela $ "SA1_SC5") .and. (ZZ6_VEND != cVend)
			do while  !eof() .and. (ZZ6->ZZ6_FILIAL = xFilial("ZZ6")) .and. (ZZ6_EMPR = xFilial(cTabela)) .and. (ZZ6->ZZ6_TABELA = cTabela) .and. (alltrim(ZZ6->ZZ6_CHAVE) == alltrim(cChave)) .and. (ZZ6->ZZ6_VEND != cVend)
				dbskip()
			enddo 
			if !eof() .and. (ZZ6->ZZ6_FILIAL = xFilial("ZZ6")) .and. (ZZ6_EMPR = xFilial(cTabela)) .and. (ZZ6->ZZ6_TABELA = cTabela) .and. (alltrim(ZZ6->ZZ6_CHAVE) == alltrim(cChave)) .and. (ZZ6->ZZ6_VEND = cVend)
				lInclui = .f.
			else
				lInclui = .t.
			endif 
		else
			lInclui = .f.
		endif 
					
     Else
        lInclui := .t.
     Endif
	cTable := RetSqlName("ZZ6")
	TcRefresh( cTable )	
      RecLock("ZZ6", lInclui)
      ZZ6->ZZ6_FILIAL := xFilial("ZZ6")
      ZZ6->ZZ6_DIA    := Date()
      ZZ6->ZZ6_EMPR   := iif(cTabela = "SZ1","",xFilial(cTabela))
      ZZ6->ZZ6_CHAVE  := cChave
      ZZ6->ZZ6_APAGAR := lApagar
      ZZ6->ZZ6_PROCES	:= "N"
      ZZ6->ZZ6_TABELA := cTabela
      if cTabela $ "SA1_SC5"  
			ZZ6->ZZ6_VEND := cVend
		endif
      ZZ6->ZZ6_ULTATU := date()        	            

      MsUnLock()    
	if !empty(cArea)
	     DbSelectArea(cArea)
	endif	    
Return(.t.)

/*********************************************************************************/
/*** FunÁ„o para calcular o preÁo de venda, baseado nos par‚metros vindos da   ***/
/*** planilha de custos.                                                       ***/
/*** Autor:                                                                    ***/
/*** Data :   /  /                                                             ***/
/*** Param: nCusto - Custo de MP + M„o de Obra                                 ***/
/***        nPerc  - Soma de percentuais internos da planilha +comissao + lucro***/
/*********************************************************************************/
User Function CalcPreco(nCusto, nPerc)
     Local nRet   := 0
     Local nJuros := GETMV('MV_JUROS') / 100
     nRet   := nCusto / ( (1 / ( (1 + nJuros) ^ (720 / 365) ) ) -( (nPerc) / 100) )               
Return(nRet)

/*****************************************************************************/
/*** Verifica se determinado registro j· est· bloqueado. Retorna .t. para  ***/
/*** Sim ou .f. para n„o bloqueado                                         ***/
/*** Autor: Cleber O. Domingues                                            ***/
/*** Data :   /  /                                                         ***/
/*** Param: _cAlias - Alias a ser verficado                                ***/
/***        nReg    - Numero do registro                                   ***/
/*****************************************************************************/
User Function EstaBloqueado(_cAlias,_nReg)                              
     Local nArea := Alias()
     Local aList, nSize, nCount, lBloqueado

     DbSelectArea(_cAlias)
     lBloqueado := .f.
     aList      := DbRLockList()
     nSize      := Len(aList)
     For nCount := 1 TO nSize
         If aList[nCount] == _nReg
            lBloqueado := .t.
            Exit
         Endif
     NEXT
     DbSelectArea(nArea)
Return(lBloqueado)

/*****************************************************************************/
/*** FunÁ„o para calcular o lucro, baseado nos par‚metros vindos da plani- ***/
/*** lha de custos                                                         ***/
/*** Autor: Cleber Orati Domingues                                         ***/
/*** Data :   /  /                                                         ***/
/*** Param: nCusto - Custo de MP + M„o de Obra                             ***/
/***        nPerc  - Soma de percentuais internos da planilha +comissao,   ***/
/***                 EXCETO lucro                                          ***/
/***        nPreco - PreÁo de venda a conseguir mantendo a comiss„o e      ***/
/***                 outros percentuais                                    ***/
/*****************************************************************************/
User Function CalcLucro(nCusto, nPerc, nPreco)
     Local nRet   := 0
     Local nJuros := GETMV('MV_JUROS') / 100

     nRet = ((1/((1+nJuros)^(720/365)))-((nPerc)/100) - (nCusto/nPreco))*100
Return(nRet)

/*****************************************************************************/
/*** FunÁ„o para determinar os percentuais internos para formaÁ„o de PreÁos***/
/*** Autor: Cleber Orati Domingues                                         ***/
/*** Data : 25/05/04                                                       ***/
/*** Param: _cPlanilha - Nome da Planilha                                  ***/
/*****************************************************************************/
User Function DetPercInt(_cPlanilha)
     Local nTamArq, lOk, aAux
     Local nSomaPerc := 0
     Local nArq      := fopen(_cPlanilha)
     Local nLidos    := 0
     If nArq > 0 
        FSEEK(nArq, 0, 0)
        nTamArq := FSEEK(nArq, 0, 2)
        FSEEK(nArq, 0, 0)
        lOk  := .f.
        aAux := {}
        While nLidos < nTamArq
              cLinha := U_fgets(nArq)
              If SubStr(cLinha,6,3) == "PIS_IVA"
                 lOk := .t.
              Endif
              If lOk
                 nSomaPerc += U_cTon(Alltrim(SubStr(cLinha, 36, 10)))
              Endif	
              If SubStr(cLinha, 6, 16) == "DESP. COMERCIAIS"
                 lOk := .f.
              Endif
              nLidos += Len(cLinha) + 2
        EndDo
        fclose(nArq)
     Else
        MsgBox("ImpossÌvel abrir planilha "+_cPlanilha, "AtenÁ„o", "STOP")
     Endif
Return(nSomaPerc)

/*****************************************************************************/
/*** Retorna o proximo numero de lote.                                     ***/
/*** Autor: Renato Palma Zuccolotto                                        ***/
/*** Data : 25/02/02                                                       ***/
/*** Param: cTabela - Nome da tabela                                       ***/
/***        nTam    - Tamanho do cÛdigo                                    ***/
/*****************************************************************************/
User Function NumSeqLot(cTabela, nTam)
     Local _cNumAut  := "*"
     Local _cProximo := ""
     Local cSx2, cAliasZZW, lAbriuOutraArea
     Local _cAux, _cGrupoEmp,nTamFil,cFilTab
     Local cArea := Alias()
     If nTam == nil
        nTam = 6
     Endif                       
     
     //Ver para qual tabela SX2 aponta (Cleber)
     
	cAliasZZW       := "ZZW"
	cSx2 := alltrim(RetSqlName(cAliasZZW))
	_cGrupoEmp := substr(cSx2,4,2)
	nTamFil := FWSizeFilial(_cGrupoEmp)

	lAbriuOutraArea := .f.
	DbSelectArea(cAliasZZW)
	DbSetOrder(1)

     cFilTab := padr(alltrim(xFilial(cTabela)),nTamFil," ")
     DbSelectArea(cAliasZZW)         // Tabela de numeracao de Lote.
     DbSeek(cFilTab+cTabela, .F.)
     If !Found()
        RecLock(cAliasZZW, .T.)
           _cAux  := cAliasZZW+"->ZZW_FILIAL"
           &_cAux := cFilTab
           _cAux  := cAliasZZW+"->ZZW_TABELA"
           &_cAux := cTabela
           _cAux  := cAliasZZW+"->ZZW_NUM"
           &_cAux := "*"
        MsUnLock()          
        _cNumAut := StrZero(1, nTam)
     Else
        _cAux    := cAliasZZW+"->ZZW_NUM"
        _cNumAut := &_cAux
        _nTime   := 1000
        While ("*" $ _cNumAut)
              DbSelectArea(cAliasZZW)
              DbGoBottom()
              DbGoTop()
              DbSeek(cFilTab+cTabela)
              _cAux    := cAliasZZW+"->ZZW_NUM"
              _cNumAut := &_cAux
              If ("*" $ _cNumAut) .And. ((_nTime--) <= 0)
                 If MsgYesNo("Nao foi possÌvel obter proximo numero.", "Tentar novamente?")
                    _nTime := 500
                    Loop
                 Else
                    Exit
                 EndIf
              EndIf
        EndDo
        If !("*" $ _cNumAut)
           RecLock(cAliasZZW, .F.)
              _cAux  := cAliasZZW+"->ZZW_NUM"
              &_cAux := "*"
           MsUnLock()
        EndIf
     EndIf
     If ("*" $ _cNumAut)
        MsgBox("Nao foi possivel obter prox. nro!", "Tente novamente!", "STOP")
     Else
        // Libera para pegarem o proximo numero de Lote
        _cProximo := StrZero(Val(_cNumAut)+1, nTam)
        DbSelectArea(cAliasZZW)
        DbSeek(cFilTab+cTabela, .F.)
        RecLock(cAliasZZW, .F.)
           _cAux  := cAliasZZW+"->ZZW_NUM"
           &_cAux := _cProximo
        MsUnLock()
     Endif 
     If lAbriuOutraArea
        DbSelectArea(cAliasZZW)
        DbCloseArea()
     Endif   
     if !empty(cArea)
     	select(cArea)
     endif 
Return _cNumAut

/*****************************************************************************/
/*** FunÁ„o para tratar filtro a ser passado para instruÁ‡o SQL.           ***/
/*** Autor: Cleber Orati Domingues                                         ***/
/*** Data : 11/06/02                                                       ***/
/*****************************************************************************/
User Function TrataFiltro(cFiltro)
     Local cRet
     cRet := UPPER(cFiltro)
     cRet := Strtran(cRet, '"'      , "'"    )
     cRet := Strtran(cRet, ".AND."  , " AND ")
     cRet := Strtran(cRet, ".OR."   , " OR " )
     cRet := Strtran(cRet, "ALLTRIM", ""     )
     cRet := Strtran(cRet, "=="     , "="    )
Return(cRet)

/*****************************************************************************/
/*** FunÁ„o para guardar em uma matriz vetor, os valores de todos os campos***/
/*** de uma tabela que est· na ·rea atual                                  ***/
/*** Autor: Cleber Orati Domingues                                         ***/
/*** Data : 21/10/02                                                       ***/
/*** Data : 13/02/20->AdaptaÁ„o release 10.1.25                            ***/
/*****************************************************************************/
User Function Scatter(cTabela)
     Local aMemVar := {}
     Local cAux,cSx3
     Local nArea   := Alias()
     Local lAbriu  := .f.
     
     cSx3 := U_NovoCursor()

    // ABERTURA DO DICION¡RIO SX3
    OpenSXs(NIL, NIL, NIL, NIL, NIL, cSx3, "SX3", NIL, .F.)
    lAbriu := Select(cSx3) > 0
    // CASO ABERTO FILTRA O ARQUIVO PELO X3_ARQUIVO DO CONTEUDO cTabela,
    // DEFINE COMO TABELA CORRENTE E POSICIONA NO TOPO
    If (lAbriu)
        DbSelectArea(cSx3)
        ( cSx3 )->( DbSetOrder( 1 ) )
    else
    	return(aMemVar)
    EndIf
     
/*
     If Select("SX3") == 0
        lAbriu := .t.
        cAuxX3 := GetSrvProfString("StartPath", "")+"SX3"+SubStr(cNumEmp, 1, 2)+"0"
        USE &cAuxX3 ALIAS SX3 NEW SHARED
        DbSetIndex(cAuxX3)
     Endif
*/
     DbSelectArea(cSx3)
     ( cSx3 )->( DbSeek(cTabela) )
     While !Eof() .and. ( cSx3 )->( X3_ARQUIVO ) == cTabela
           If (cSx3)->(X3_CONTEXT) != "V"
              DbSelectArea(nArea)
              cAux := Alltrim((cSx3)->(X3_CAMPO))
              aAdd(aMemVar, {cAux, &cAux})
           Endif
           DbSelectArea(cSx3)
           DbSkip()
     Enddo
     If lAbriu
        DbSelectArea(cSx3)
        //DbClearIndex()
        DbCloseArea()
     Endif
     DbSelectArea(nArea)
Return(aMemVar)

/*****************************************************************************/
/*** FunÁ„o para retornar o Tipo de Consumidor, de acordo com a Letra de   ***/
/*** classificaÁ„o informada, constante no cadastro de clientes e fornece- ***/
/*** dores                                                                 ***/
/*** Autor: Cleber Orati Domingues                                         ***/
/*** Data : 30/07/03                                                       ***/
/*****************************************************************************/
User Function TipoCons(cTipoCons)
     Local cClas
     If cTipoCons $ "C"
        cClas := "Consumidor Final" 
     ElseIf cTipoCons $ "I"
            cClas := "Industrializacao" 
     ElseIf cTipoCons $ "N"
            cClas := "Nao Contribuinte" 
     ElseIf cTipoCons $ "V"
            cClas := "Comercio/Revenda" 
     ElseIf cTipoCons $ "D"
            cClas := "Com. Distrib." 
     Else
            cClas := ""
  	Endif
Return(cClas)


/*****************************************************************************/
/*** FMOSAVS - Mostra aviso.                                               ***/
/*** Autor: LuÌs Gustavo de Souza                                          ***/
/*** Data :                                                                ***/
/*****************************************************************************/
User FUNCTION fMosAvs(cCaption, cMensagem, aBotoes, nSize)
     Local ny    := 0
     Local nx    := 0
     Local aSize := { 	{134, 304, 35, 155, 35, 113, 51},; 	// Tamanho 1
                        {134, 450, 35, 155, 35, 185, 51},;      // Tamanho 2
                        {200, 450, 35, 210, 50, 185, 82} }	// Tamanho 3
     Private oDlgAviso
     Private nOpcAviso := 0

     If nSize == Nil
        //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
        //≥ Verifica o numero de botoes Max. 5 e o tamanho da Msg.       ≥
        //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
        If Len(aBotoes) > 3
           If Len(cMensagem) > 286
              nSize := 3
           Else
              nSize := 2
           EndIf
        Else
           Do Case
              Case Len(cMensagem) > 170 .And. Len(cMensagem) < 250
                   nSize := 2
              Case Len(cMensagem) >= 250
                   nSize := 3
              OtherWise
                   nSize := 1
           EndCase
        EndIf
     EndIf
     DEFINE MSDIALOG oDlgAviso FROM 010,000 TO aSize[nSize][1],aSize[nSize][2] TITLE OemtoAnsi(cCaption) Of oMainWnd PIXEL
            DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
            @ 0, 0 BITMAP oBmp RESNAME "LOGIN" oF oDlgAviso SIZE aSize[nSize][3],aSize[nSize][4] NOBORDER WHEN .F. PIXEL
            @ 11 ,35  TO 13 ,400 LABEL '' OF oDlgAviso PIXEL
            @ 3  ,37  SAY cCaption Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold
            @ 16 ,38  SAY cMensagem Of oDlgAviso PIXEL SIZE aSize[nSize][6],aSize[nSize][5]
            TButton():New(1000,1000," ",oDlgAviso,{||Nil},32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
            ny := (aSize[nSize][2]/2)-36
            For nx:=1 to Len(aBotoes)
                cAction:="{||nOpcAviso:="+Str(Len(aBotoes)-nx+1)+",oDlgAviso:End()}"
                bAction:=&(cAction)
                TButton():New(aSize[nSize][7],ny,OemToAnsi(AllTrim(aBotoes[Len(aBotoes)-nx+1])), oDlgAviso,bAction,32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
                ny -= 35
            Next nx
            oDlgAviso:nStyle       := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     ACTIVATE MSDIALOG oDlgAviso

Return(nOpcAviso)

/************************************************************************************/
/*** FBUSENDLIV - Busca EndereÁos de Pallets/Quadrantes e PrÛximos pallets Livres ***/
/*** Criada em: 21/06/2006                                                        ***/
/*** Vari·veis:   aPallet - Retorna os PALLETS livres para serem utilizados       ***/
/***              aQuadra - Retorna os QUADRANTES livres para serem utilizados    ***/
/***              aProPal - Retorna os PALLETS das prÛximas cargas que sairam     ***/
/***              aProQua - Retorna os QUADRANTES das prÛximas cargas que sairam  ***/
/*** ObservaÁ„o - Sempre que utilizar essa funÁ„o passar os par‚metros com @ para ***/
/***              serem retornadas as matrizes com seu conte˙do.                  ***/
/************************************************************************************/
User Function fBusEndLiv(aPallet, aQuadra, aProPal, aProQua)
     Local cQry1 := ""
     Local nA
     Local cMVJUNENDE := SUPERGETMV("MV_JUNENDE",.F.,"N")
     /******************************************************/
     /*** Monta Matriz dos Pallets                       ***/
     /******************************************************/
     cQry1 += "SELECT SBE.BE_LOCALIZ, SBE.BE_STATUS "
     cQry1 += "FROM "+RetSqlName("SBE")+" SBE WITH (NOLOCK) "
     cQry1 += "WHERE SBE.BE_FILIAL = '"+xFilial("SBE")+"' "
     cQry1 += "  AND SBE.D_E_L_E_T_ = '' "
     cQry1 += "  AND SBE.BE_PRIOR IN('ZZZ') "
     cQry1 += "ORDER BY SBE.BE_PRIOR, SBE.BE_LOCALIZ "
     TCQuery cQry1 ALIAS "TCQ" NEW
     DbSelectArea("TCQ")
     DbGoTop()
     While !Eof()
           aAdd(aPallet, {TCQ->BE_LOCALIZ, TCQ->BE_STATUS})
           DbSelectArea("TCQ")
           DbSkip()
     Enddo
     DbSelectArea("TCQ")
     DbCloseArea()

     /******************************************************/
     /*** Monta Matriz dos Quadrantes                    ***/
     /******************************************************/
     cQry1 := ""
     cQry1 += "SELECT SBE.BE_LOCALIZ, SBE.BE_STATUS "
     cQry1 += "FROM "+RetSqlName("SBE")+" SBE WITH (NOLOCK) "
     cQry1 += "WHERE SBE.BE_FILIAL = '"+xFilial("SBE")+"' "
     cQry1 += "  AND SBE.D_E_L_E_T_ = '' "
     cQry1 += "  AND SBE.BE_PRIOR IN('001', '002') "
     cQry1 += "ORDER BY SBE.BE_PRIOR, SBE.BE_LOCALIZ "
     TCQuery cQry1 ALIAS "TCQ" NEW
     DbSelectArea("TCQ")
     DbGoTop()
     While !Eof()
           aAdd(aQuadra, {TCQ->BE_LOCALIZ, TCQ->BE_STATUS})
           DbSelectArea("TCQ")
           DbSkip()
     Enddo
     DbSelectArea("TCQ")
     DbCloseArea()

     /******************************************************/
     /*** Monta Matriz dos PrÛximos Pallets e Quadrantes ***/
     /******************************************************/
     // 1∫) Busca as prÛximas cargas que sair„o.
     cQry1 := ""
     cQry1 += "SELECT * "
     cQry1 += "FROM "+RetSqlName("SZA")+" SZA WITH (NOLOCK) "
     cQry1 += "WHERE SZA.ZA_FILIAL  = '"+xFilial("SZA")+"' "
     cQry1 += "  AND SZA.D_E_L_E_T_ = '' "
     cQry1 += "  AND SZA.ZA_DTDESPA = '' "
     cQry1 += "  AND SZA.ZA_PREVDSP = '"+DTOS(dDataBase)+"' "
     cQry1 += "ORDER BY SZA.ZA_PREVDSP DESC "
     TCQuery cQry1 ALIAS "TCQ" NEW
     DbSelectArea("TCQ")
     DbGoTop()
     cProDes := TCQ->ZA_PREVDSP
     cAuxBor := ""
     While !Eof()
           If TCQ->ZA_PREVDSP == cProDes
              cAuxBor += TCQ->ZA_CODIGO+"', '"
           Endif
           DbSelectArea("TCQ")
           DbSkip()
     Enddo
     DbSelectArea("TCQ")
     DbCloseArea()

     // 2∫) Monta Matrizes com os endereÁos que ser„o liberados na prÛxima carga.
     If !Empty(cAuxBor)
        cQry1 := ""
        cQry1 += "SELECT SZG.ZG_LOCALIZ "
        cQry1 += "FROM "+RetSqlName("SZB")+" SZB WITH (NOLOCK) "
        cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON SZB.ZB_FILIAL = SZG.ZG_FILIAL AND SZB.ZB_PEDIDO = SZG.ZG_PEDIDO AND SZG.D_E_L_E_T_ = '' "
        cQry1 += "WHERE SZB.ZB_FILIAL  = '"+xFilial("SZB")+"' "
        cQry1 += "  AND SZB.D_E_L_E_T_ = '' "
        cQry1 += "  AND SZB.ZB_CODIGO IN('"+SubStr(cAuxBor, 1, Len(cAuxBor)-3)+") "
        cQry1 += "ORDER BY SZG.ZG_LOCALIZ "
        TCQuery cQry1 ALIAS "QEND" NEW
        DbSelectArea("QEND")
        DbGoTop()
        While !Eof()
              If !Empty(Alltrim(QEND->ZG_LOCALIZ))
                 // a)Verificar se possui os caracteres '(, *, /'
                 If Alltrim(QEND->ZG_LOCALIZ) $ '(.*./.)'
                    If Alltrim(QEND->ZG_LOCALIZ) $ '/' //Verifica se existe somente 1 endereÁo
                       cEndIni := SubStr(Alltrim(QEND->ZG_LOCALIZ), 2, 3)
                       DbSelectArea("SBE")
                       DbSetOrder(9)
                       DbSeek(xFilial("SBE")+cEndIni, .t.)
                       If Found()
                          If SBE->BE_PRIOR $ '001.002.003' //Quadrante
                             aAdd(aProQua, {SBE->BE_LOCALIZ, '1'})
                          ElseIf SBE->BE_PRIOR $ 'ZZZ' //Pallets
                                 cEndFim := SubStr(Alltrim(QEND->ZG_LOCALIZ), 6, 3)
                                 If (Val(cEndFim) - Val(cEndIni)) <= 0.0 //Somente 1 EndereÁo/Pallet
                                    aAdd(aProPal, {SBE->BE_LOCALIZ, '1'})
                                 Else
                                    For nA := Val(cEndIni) TO Val(cEndFim)
                                        DbSelectArea("SBE")
                                        DbSetOrder(9)
                                        DbSeek(xFilial("SBE")+StrZero(nA, 3), .t.)
                                        If Found()
                                           aAdd(aProPal, {SBE->BE_LOCALIZ, '1'})
                                        Endif
                                    Next
                                 Endif
                          Endif
                       Endif
                    Else
                       cEndIni := StrZero(Val(Alltrim(QEND->ZG_LOCALIZ)), 3)
                       DbSelectArea("SBE")
                       DbSetOrder(9)
                       DbSeek(xFilial("SBE")+cEndIni, .t.)
                       If Found()
                          If SBE->BE_PRIOR $ '001.002.003' //Quadrante
                             aAdd(aProQua, {SBE->BE_LOCALIZ, '1'})
                          ElseIf SBE->BE_PRIOR $ 'ZZZ' //Pallets
                                 aAdd(aProPal, {SBE->BE_LOCALIZ, '1'})
                          Endif
                       Endif
                    Endif
                 Else
                    cEndIni := StrZero(Val(Alltrim(QEND->ZG_LOCALIZ)), 3)
                    DbSelectArea("SBE")
                    DbSetOrder(9)
                    DbSeek(xFilial("SBE")+cEndIni, .t.)
                    If Found()
                       If SBE->BE_PRIOR $ '001.002.003' //Quadrante
                          aAdd(aProQua, {SBE->BE_LOCALIZ, '1'})
                       ElseIf SBE->BE_PRIOR $ 'ZZZ' //Pallets
                              aAdd(aProPal, {SBE->BE_LOCALIZ, '1'})
                       Endif
                    Endif
                 Endif
              Endif
              DbSelectArea("QEND")
              DbSkip()
        EndDo
        DbSelectArea("QEND")
        DbCloseArea()
        
        If Alltrim(cMVJUNENDE) $ 'S'//Parametro que ira verificar se deve ou nao juntar enderecos alocados com os vazio
           If Len(aProPal) > 0.0 //Juntar enderecos de Pallets
              For nA := 1 To Len(aProPal)
                  aAdd(aPallet, {aProPal[nA][1], aProPal[nA][2]})
              Next
           Endif
           If Len(aProQua) > 0.0 //Juntar enderecos de Quadrantes
              For nA := 1 To Len(aProQua)
                  aAdd(aQuadra, {aProQua[nA][1], aProQua[nA][2]})
              Next
           Endif
        Endif
     Endif   
Return

/************************************************************************************/
/*** FENDPEDEXP - EndereÁa pedidos na expediÁ„o                                   ***/
/*** Criada em: 21/06/2006 - LuÌs Gustavo de Souza                                ***/
/*** Vari·veis:   cTipAlo - Tipo de alocaÁ„o, E = EndereÁa, R = RelaÛrio          ***/
/***              cTipEnd - Tipo do endereÁo, 1 = Pallets , 2 = Quadrante         ***/
/***              cBorPed - CÛdigo do Bordero de Pedidos                          ***/
/***              cNumPed - Numero do Pedido                                      ***/
/***              cCodReg - CÛdigo da Regi„o                                      ***/
/***              nQtdPal - Quantidade de pallets                                 ***/
/***              aPallet - PALLETS livres para serem utilizados                  ***/
/***              aQuadra - QUADRANTES livres para serem utilizados               ***/
/***              aProPal - PALLETS das prÛximas cargas que sairam                ***/
/***              aProQua - QUADRANTES das prÛximas cargas que sairam             ***/
/*** ObservaÁ„o - Sempre que utilizar essa funÁ„o passar os par‚metros com @ para ***/
/***              as matrizes de endereÁos.                                       ***/
/************************************************************************************/
User Function fEndPedExp(cTipAlo, cTipEnd, cBorPed, cNumPed, cCodReg, nQtdPal, aPallet, aQuadra, aProPal, aProQua)
     Local cEndPed := ""
     Local lCont   := .t.
     Local nQtde   := nQtdPal
     Local nB, nX
     Local nA
     LOCAL cMVJUNENDE := SUPERGETMV("MV_JUNENDE",.F.,"N")

     If cTipEnd == '1' //Pallets
        While lCont                                 //Enquanto a vari·vel for verdadeira, procura endereÁo
              For nA := 1 To Len(aPallet)           //Busca do 1∫ endereÁo atÈ o ultimo.
                  If (nA + nQtde) <= Len(aPallet)   //Verifica se a Soma do contador de endereÁos + a quantidade de pallets necess·rios n„o passa do total de endereÁos.
                     lQuebra := .f.                 //Variavel para indicar se existe quebra na seq¸Íncia de endereÁos.
                     For nB := nA To (nQtde + nA)-1 //Busca do contador de endeÁos inicial atÈ a quantidade necess·ria de pallets.
                         If aPallet[nB][2] == '2'   //Verifica se o endereÁo est· ocupado.
                            lQuebra := .t.          //Muda status para indicar que existe quebra entre os endereÁos.
                         Endif
                     Next
                     If !lQuebra                    //Se n„o houve quebra aloca os endereÁos inicial ao final
                        nEndIni := nA               //EndereÁo Inicial
                        nEndFim := (nA + Iif(nQtde == 1, 0, nQtde - 1))     //EndereÁo Final
                        For nB := nEndIni To nEndFim
                            aPallet[nB][2] := '2'
                            //Somente ativar o bloco abaixo qdo for realmente utilizar a alocaÁ„o de endereÁos
                            If cTipAlo $ 'E'
                               DbSelectArea("SBE")
                               DbSetOrder(9)
                               DbSeek(xFilial("SBE")+aPallet[nB][1], .t.)
                               If Found()
                                  RecLock("SBE", .f.)
                                     SBE->BE_STATUS  := '2'
                                     SBE->BE_BORDERO := cBorPed
                                     SBE->BE_PEDIDO  := cNumPed
                                  MsUnLock()
                               Endif
                            Endif
                        Next
                        cEndPed := Iif(cCodReg $ '999', '(', '*')+Alltrim(aPallet[nEndIni][1])+'/'+Alltrim(aPallet[nEndFim][1])+Iif(cCodReg $ '999', ')', '')
                        lCont   := .f.
                        Exit
                     Endif
                  Else
                     nQtde -= 1               //Diminuir 1 Pallet para nova busca de seq¸Íncia
                     If nQtde == 0.0          //Se a quantidade de Pallets necess·ria chegar a 0
                        lCont := .f.          //Sai da Busca pelo Pallet
                        If Alltrim(cMVJUNENDE) $ 'S'
                           cEndPed := 'Sem End.'
                        Else
                           /****************************************************/
                           /*** Busca EndereÁo livre nos prÛximos pallets.   ***/
                           /****************************************************/
                           While lCont
                                 For nX := 1 To Len(aProPal)
                                     If (nX + nQtde) <= Len(aProPal)
                                        lQuebra := .f.
                                        For nB := nX To (nQtde + nX)-1
                                            If aProPal[nB][2] == '2'
                                               lQuebra := .t.
                                            Endif
                                        Next
                                        If !lQuebra
                                           nEndIni := nX
                                           nEndFim := (nX + Iif(nQtde == 1, 0, nQtde - 1))
                                           For nB := nEndIni To nEndFim
                                               aProPal[nB][2] := '2'
                                               //Somente ativar o bloco abaixo qdo for realmente utilizar a alocaÁ„o de endereÁos
                                               If cTipAlo $ 'E'
                                                  DbSelectArea("SBE")
                                                  DbSetOrder(9)
                                                  DbSeek(xFilial("SBE")+aProPal[nB][1], .t.)
                                                  If Found()
                                                     RecLock("SBE", .f.)
                                                        SBE->BE_STATUS  := '2'
                                                        SBE->BE_BORDERO := cBorPed
                                                        SBE->BE_PEDIDO  := cNumPed
                                                     MsUnLock()
                                                  Endif
                                               Endif
                                           Next
                                           cEndPed := Iif(cCodReg $ '999', '(', '*')+Alltrim(aProPal[nEndIni][1])+'/'+Alltrim(aProPal[nEndFim][1])+Iif(cCodReg $ '999', ')', '')
                                           lCont   := .f.
                                           Exit
                                        Endif
                                     Else
                                        nQtde -= 1
                                        If nQtde == 0.0
                                           lCont := .f.
                                           cEndPed := 'Sem End.'
                                        EndIf
                                        Exit
                                     Endif
                                 Next
                           Enddo
                           /****************************************************/
                        EndIf
                     Endif
                     Exit
                  Endif
              Next
        Enddo
        
     Else
        For nA := 1 To Len(aQuadra)
            If aQuadra[nA][2] == '1'
               aQuadra[nA][2] := '2'
               cEndPed := Iif(cCodReg $ '999', '(', '*')+Alltrim(aQuadra[nA][1])+Iif(cCodReg $ '999', ')', '')
               //Somente ativar o bloco abaixo qdo for realmente utilizar a alocaÁ„o de endereÁos
               If cTipAlo $ 'E'
                  DbSelectArea("SBE")
                  DbSetOrder(9)
                  DbSeek(xFilial("SBE")+aQuadra[nA][1], .t.)
                  If Found()
                     RecLock("SBE", .f.)
                        SBE->BE_STATUS  := '2'
                        SBE->BE_BORDERO := cBorPed
                        SBE->BE_PEDIDO  := cNumPed
                     MsUnLock()
                  Endif
               Endif
               Exit
            Endif
        Next
        If Empty(cEndPed)
           If Alltrim(cMVJUNENDE) $ 'S'
              cEndPed := 'Sem End.'
           Else
              /****************************************************/
              /*** Busca EndereÁo livre nos prÛximos quadrantes ***/
              /****************************************************/
              For nX := 1 To Len(aProQua)
                  If aProQua[nX][2] == '1'
                     aProQua[nX][2] := '2'
                     cEndPed := Iif(cCodReg $ '999', '(', '*')+Alltrim(aProQua[nX][1])+Iif(cCodReg $ '999', ')', '')
                     //Somente ativar o bloco abaixo qdo for realmente utilizar a alocaÁ„o de endereÁos
                     If cTipAlo $ 'E'
                        DbSelectArea("SBE")
                        DbSetOrder(9)
                        DbSeek(xFilial("SBE")+aProQua[nX][1], .t.)
                        If Found()
                           RecLock("SBE", .f.)
                              SBE->BE_STATUS  := '2'
                              SBE->BE_BORDERO := cBorPed
                              SBE->BE_PEDIDO  := cNumPed
                           MsUnLock()
                        Endif
                     Endif
                     Exit
                  Endif
              Next
           Endif
        Endif
     Endif
Return(cEndPed)

/********************************************************************************/
/*** CALLJOB - FunÁ„o para iniciar um JOB quando o mesmo estiver parado       ***/
/********************************************************************************/
User Function CallJob()
     StartJob("WFONSTART", GetEnvServer(), .f.)
Return Nil         

User Function PrcUltCompra(cProd)   
Local cQuery,nPreco,_cEmpr
Local nArea  
	nArea := Alias()
    	if substr(cNumEmp,1,2) == "01"
    		_cEmpr := ""
    	else
    		_cEmpr := substr(cNumEmp,1,2)
    	endif 
		cQuery := "SELECT UPRC = dbo.UltPreco"+_cEmpr+"('"+xFilial("SD1")+"','"+ALLTRIM(cProd)+"')" 
    	TCQuery cQuery NEW ALIAS "TCQ"
	    nPreco := TCQ->UPRC
	 	DbSelectArea("TCQ")
		DbCloseArea()           

 	DbSelectArea(nArea)
    
return(nPreco)

User Function PrcMinimo(nValorTab,cGrupoVenda,nPercIcm,lIcmsIpi,cCondPgto)   
Local nDesc1,nDesc2,nDesc3,nDesc4,nDesc5,nDesc6     
Local aPrecos := {}

	nDesc1 := 0
	nDesc2 := 0
	nDesc3 := 0
	nDesc4 := 0
	nDesc5 := 0
	nDesc6 := 0

if (nPercIcm >= 18) .and. lIcmsIpi
			nDesc1 := 5
			nDesc2 := 6
			nDesc3 := 7
			nDesc4 := 8
			nDesc5 := 9
			nDesc6 := 10
else 
	do case
	case nPercIcm <= 7
		do case
		case cGrupoVenda = "1"
			nDesc1 := 26
			nDesc2 := 27
			nDesc3 := 29
			nDesc4 := 30
			nDesc5 := 31
			nDesc6 := 32
		case cGrupoVenda = "2"
			nDesc1 := 26
			nDesc2 := 27
			nDesc3 := 29
			nDesc4 := 30
			nDesc5 := 31
			nDesc6 := 32
		case cGrupoVenda = "3"
			nDesc1 := 27
			nDesc2 := 28
			nDesc3 := 30
			nDesc4 := 31
			nDesc5 := 32
			nDesc6 := 33
		endcase 
	case nPercIcm <= 12
		do case
		case cGrupoVenda = "1"
			nDesc1 := 17
			nDesc2 := 19
			nDesc3 := 21
			nDesc4 := 23
			nDesc5 := 23
			nDesc6 := 24
		case cGrupoVenda = "2"
			nDesc1 := 17
			nDesc2 := 19
			nDesc3 := 21
			nDesc4 := 23
			nDesc5 := 23
			nDesc6 := 24
		case cGrupoVenda = "3"
			nDesc1 := 18
			nDesc2 := 20
			nDesc3 := 22
			nDesc4 := 23
			nDesc5 := 24
			nDesc6 := 25
		endcase 
	otherwise
		do case
		case cGrupoVenda = "1"
			nDesc1 := 6
			nDesc2 := 8
			nDesc3 := 10
			nDesc4 := 12
			nDesc5 := 13
			nDesc6 := 14
		case cGrupoVenda = "2"
			nDesc1 := 6
			nDesc2 := 8
			nDesc3 := 10
			nDesc4 := 12
			nDesc5 := 13
			nDesc6 := 14
		case cGrupoVenda = "3"
			nDesc1 := 7
			nDesc2 := 9
			nDesc3 := 11
			nDesc4 := 13
			nDesc5 := 14
			nDesc6 := 15
		endcase 
	endcase
endif  

if (cGrupoVenda != "3") .and. (cGrupoVenda != "2") .and. (cGrupoVenda != "1")
	nDesc1 := 0
	nDesc2 := 0
	nDesc3 := 0
	nDesc4 := 0
	nDesc5 := 0
	nDesc6 := 0
endif 

if cCondPgto == "001" // Se for venda a vista, desc. adic. de 5% => Desconto da polÌtica + aplicaÁ„o de desconto adicional de 5% sobre o valor com desconto (fÛrmula => D1 = 5 + 0.95D
//Chamado 017308->Mudar desconto adicional de 5% para 3%
//Chamado 021202->Mudar desconto adicional de 3% para 1,5%

	nDesc1 := 100*(1 - (0.985*(1-(nDesc1/100))))
	nDesc2 := 100*(1 - (0.985*(1-(nDesc2/100))))
	nDesc3 := 100*(1 - (0.985*(1-(nDesc3/100))))
	nDesc4 := 100*(1 - (0.985*(1-(nDesc4/100))))
	nDesc5 := 100*(1 - (0.985*(1-(nDesc5/100))))
	nDesc6 := 100*(1 - (0.985*(1-(nDesc6/100))))

/*
	nDesc1 := 100*(1 - (0.97*(1-(nDesc1/100))))
	nDesc2 := 100*(1 - (0.97*(1-(nDesc2/100))))
	nDesc3 := 100*(1 - (0.97*(1-(nDesc3/100))))
	nDesc4 := 100*(1 - (0.97*(1-(nDesc4/100))))
	nDesc5 := 100*(1 - (0.97*(1-(nDesc5/100))))
	nDesc6 := 100*(1 - (0.97*(1-(nDesc6/100))))
*/   
/*
	nDesc1 = 5 + (0.95*nDesc1)
	nDesc2 = 5 + (0.95*nDesc2)
	nDesc3 = 5 + (0.95*nDesc3)
	nDesc4 = 5 + (0.95*nDesc4)
	nDesc5 = 5 + (0.95*nDesc5)
	nDesc6 = 5 + (0.95*nDesc6)
	*/
endif 
aadd(aPrecos,nValorTab*(1-(nDesc1/100)))
aadd(aPrecos,nValorTab*(1-(nDesc2/100)))
aadd(aPrecos,nValorTab*(1-(nDesc3/100)))
aadd(aPrecos,nValorTab*(1-(nDesc4/100)))
aadd(aPrecos,nValorTab*(1-(nDesc5/100)))
aadd(aPrecos,nValorTab*(1-(nDesc6/100)))
    
return(aPrecos)   

User Function Sodig(_cString)
local cRet,i,cDig
cRet := ""
for i = 1 to len(_cString)
	cDig := substr(_cString,i,1)
	if isdigit(cDig)
		cRet += cDig
	endif
next 
return(cRet)

//Retorna somente numeros e letras
User Function SoNumCar(_cString)
local cRet,i,cDig
cRet := ""
for i = 1 to len(_cString)
	cDig := substr(_cString,i,1)
	if isdigit(cDig) .or. isalpha(cDig)
		cRet += cDig
	endif
next 
return(cRet)

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥LibOutPed≥ Autor ≥ LuÌs G. de Souza      ≥ Data ≥ 21/08/09  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Locacao   ≥                  ≥Contato ≥                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ LiberaÁ„o de outros pedidos pela contabilidade.            ≥±±
±±≥          ≥ Utilizado pelo Fernando e pela Guaciara.                   ≥±±
±±≥          ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Aplicacao ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥                                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥  /  /  ≥                                               ≥±±
±±≥              ≥  /  /  ≥                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

User Function LibOutPed() 
     /*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
     ±± DeclaraÁ„o de cVariable dos componentes                                 ±±
     Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
     Private cGet1Ped   := Space(6)
     Private cSay1Ped   := Space(1)
     Private nRMenu1L   := 1

     /*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
     ±± DeclaraÁ„o de Variaveis Private dos Objetos                             ±±
     Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
     SetPrvt("oFont1", "oDlg1Lib", "oSay1Ped", "oGet1Ped", "oRMenu1L", "oBtn1", "oBtn2")

     /*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
     oFont1     := TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1Lib   := MSDialog():New( 095, 232, 310, 500, "LiberaÁ„o", , , .F., , , , , , .T., , oFont1, .T. )
     oSay1Ped   := TSay():New( 004, 004, {|| "Pedido:"}, oDlg1Lib, , oFont1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 012)
     oGet1Ped   := TGet():New( 002, 044, {|u| If(PCount() > 0, cGet1Ped := u, cGet1Ped)}, oDlg1Lib, 040, 014, '@!', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "SC5", "cGet1Ped", , )
     GoRMenu1L  := TGroup():New( 024, 004, 087, 128, "LiberaÁ„o", oDlg1Lib, CLR_BLACK, CLR_WHITE, .T., .F. )
     oRMenu1L   := TRadMenu():New( 035, 010, {"Somente Cadastro", "Todas"}, {|u| If(PCount() > 0, nRMenu1L := u, nRMenu1L)}, oDlg1Lib, , , CLR_BLACK, CLR_WHITE, "", , , 104, 26, , .F., .F., .T. )
     oBtn1      := TButton():New( 095, 004, "Confirma", oDlg1Lib, { || fConfLib()     }, 053, 012, , oFont1, , .T., , "", , , , .F. )
     oBtn2      := TButton():New( 095, 072, "Abandona", oDlg1Lib, { || oDlg1Lib:End() }, 053, 012, , oFont1, , .T., , "", , , , .F. )

     oDlg1Lib:Activate(,,,.T.)

Return

Static Function fConfLib()
       If Empty(cGet1Ped)
          MsgStop("AtenÁ„o, informe um numero de pedido!")
          cGet1Ped := space(06)
          oGet1Ped:SetFocus()
          Return
       Else
          DbSelectArea("SC5")
          DbSetOrder(1)
          DbSeek(xFilial("SC5")+cGet1Ped, .t.)
          If !Found()
             MsgStop("AtenÁ„o, pedido n„o encontrado!")
             cGet1Ped := space(06)
             oGet1Ped:SetFocus()
             Return
          Else
             If !Empty(SC5->C5_NOTA)
                MsgStop("AtenÁ„o, esse pedido j· foi Faturado!")
                cGet1Ped := space(06)
                oGet1Ped:SetFocus()
                Return
             Else
                If SC5->C5_APROVA == '2'
                   MsgStop("AtenÁ„o, esse pedido est· Bloqueado!")
                   cGet1Ped := space(06)
                   oGet1Ped:SetFocus()
                   Return
                ElseIf SC5->C5_APROVA == '1'
                       MsgStop("AtenÁ„o, esse pedido est· Liberado!")
                       cGet1Ped := space(06)
                       oGet1Ped:SetFocus()
                       Return
                ElseIf SC5->C5_APROVA == '0'
                       RecLock("SC5", .f.)
                          SC5->C5_LIBCAD := 'T'
                          SC5->C5_USRCAD := cUserName
                          If nRMenu1L == 2
                             SC5->C5_LIBPED := 'T'
                             SC5->C5_USRPED := cUserName
                             SC5->C5_LIBCRE := 'T'
                             SC5->C5_USRCRE := cUserName
                             SC5->C5_LIBDIR := 'T'
                             SC5->C5_USRDIR := cUserName
                             SC5->C5_APROVA := '1'
							 SC5->C5_DTAPR := dDataBase
							 SC5->C5_SUGENT := dDataBase + 1
                             SC5->C5_USRAPR := cUserName
                          Endif
                       MsUnLock()
                       oDlg1Lib:End()
                Endif
             Endif
          Endif
       Endif
Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥         ≥ Autor ≥                       ≥ Data ≥           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Locacao   ≥                  ≥Contato ≥                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Descricao ≥ FunÁ„o para baixa de Rampa (ZZA_RAMPA)                    ≥±±
±±≥ Material j· conferido pela Rampa nas baixas de Ops                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Aplicacao ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥                                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥  /  /  ≥                                               ≥±±
±±≥              ≥  /  /  ≥                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

User Function BxRpaEst()   
     
     // Baixa de Produtos de Estoque
     /*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
     ±± DeclaraÁ„o de cVariable dos componentes                                 ±±
     Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
     Private cSay1Ram   := Space(1)
     Private cSay2Ram   := Space(1)
     Private dGet1Ram   := CtoD(" ")
     Private cGet2Ram   := Space(5)
     Private cTipoProd  := 'Estoque'

     /*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
     ±± DeclaraÁ„o de Variaveis Private dos Objetos                             ±±
     Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
     SetPrvt("oFont1", "oDlg1Lib", "oSay1Ram", "oSay2Ram", "oGet1Ram", "oBtn1Ram", "oBtn2Ram", "oGet2Ram")

     /*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
     oFont1     := TFont():New( "MS Sans Serif",0,-19,,.T.,0,,700,.F.,.F.,,,,,, )
     oDlg1Lib   := MSDialog():New( 095,232,225,500,"RAMPA ESTOQUE",,,.F.,,,,,,.T.,,oFont1,.T. )
     oSay1Ram   := TSay():New( 004,004,{||"Data:"},oDlg1Lib,,oFont1,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,036,012)
     oSay2Ram   := TSay():New( 024,004,{||"Hora:"},oDlg1Lib,,oFont1,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,036,012)
     oGet1Ram   := TGet():New( 002,044,{|u| If(PCount()>0,dGet1Ram:=u,dGet1Ram)},oDlg1Lib,060,014,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dGet1Ram",,)
     oGet2Ram   := TGet():New( 022,044,{|u| If(PCount()>0,cGet2Ram:=u,cGet2Ram)},oDlg1Lib,032,014,'@R 99:99',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGet2Ram",,)
     oBtn1Ram   := TButton():New( 046,004,"Confirma",oDlg1Lib,{ || fBxRampa(cTipoProd) },053,012,,oFont1,,.T.,,"",,,,.F. )
     oBtn2Ram   := TButton():New( 046,072,"Abandona",oDlg1Lib,{ || oDlg1Lib:End() },053,012,,oFont1,,.T.,,"",,,,.F. )

     oDlg1Lib:Activate(,,,.T.)

Return

Static Function fBxRampa(cTipoProd)
       cQry1 := ""
       cQry2 := ""
       cQry3 := ""
       cQry1 += "SELECT COUNT(ZZA.R_E_C_N_O_) AS QTDRAM "
       cQry1 += "FROM "+RetSqlName("ZZA")+" ZZA WITH(NOLOCK) "+;
       "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (SB1.B1_FILIAL = '"+xFilial("SB1")+"') AND (ZZA.ZZA_PRODUT = SB1.B1_COD) "
       cQry2 += "UPDATE "+RetSqlName("ZZA")+" "
       cQry2 += "SET ZZA_RAMPA = 'S' "
       cQry2 += "FROM "+RetSqlName("ZZA")+" ZZA "+;
       "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (SB1.B1_FILIAL = '"+xFilial("SB1")+"') AND (ZZA.ZZA_PRODUT = SB1.B1_COD) "
       cQry3 += "WHERE (ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"') "
       cQry3 += "AND (ZZA.D_E_L_E_T_ = '') "
       cQry3 += "AND ZZA.ZZA_FLAG IN('7', '8') "
       cQry3 += "AND ZZA.ZZA_RAMPA = '' "
       cQry3 += "AND ZZA.ZZA_DTFIM <= '"+DTOS(dGet1Ram)+"' "
       cQry3 += "AND ZZA.ZZA_HFIM <= '"+Alltrim(cGet2Ram)+"' "
       If cTipoProd $ 'Estoque'
       		cQry3 += "  AND SB1.B1_ESTOQUE = 'S' "
       Else
       		cQry3 += "  AND SB1.B1_ESTOQUE <> 'S' "
       Endif
       TCQuery cQry1+cQry3 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       nQtdReg := TCQ->QTDRAM
       DbSelectArea("TCQ")
       DbCloseArea()
       If nQtdReg > 0
          If MsgYesNo("Existem "+StrZero(nQtdReg, 3)+" registros a serem processados (Produtos "+cTipoProd+"), continua? ")
             TCSQLExec(cQry2+cQry3)
             oDlg1Lib:End()
          Endif
       Else
          MsgStop("N„o existem registros a serem processados")
          dGet1Ram := ctod(" ")
          cGet2Ram := space(5)
          oGet1Ram:SetFocus()
       Endif
Return


User Function BxRpaEsp()
     // Baixa de Produtos EspecÌficos
     /*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
     ±± DeclaraÁ„o de cVariable dos componentes                                 ±±
     Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
     Private cSay1Ram   := Space(1)
     Private cSay2Ram   := Space(1)
     Private dGet1Ram   := Ddatabase
     Private cGet2Ram   := Left(Time(),5)
     Private cTipoProd  := 'Especificos'

     /*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
     ±± DeclaraÁ„o de Variaveis Private dos Objetos                             ±±
     Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
     SetPrvt("oFont1", "oDlg1Lib", "oSay1Ram", "oSay2Ram", "oGet1Ram", "oBtn1Ram", "oBtn2Ram", "oGet2Ram")

     /*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
     oFont1     := TFont():New( "MS Sans Serif",0,-19,,.T.,0,,700,.F.,.F.,,,,,, )
     oDlg1Lib   := MSDialog():New( 095,232,225,500,"RAMPA ESPECÕFICOS",,,.F.,,,,,,.T.,,oFont1,.T. )
     oSay1Ram   := TSay():New( 004,004,{||"Data:"},oDlg1Lib,,oFont1,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,036,012)
     oSay2Ram   := TSay():New( 024,004,{||"Hora:"},oDlg1Lib,,oFont1,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,036,012)
     oGet1Ram   := TGet():New( 002,044,{|u| If(PCount()>0,dGet1Ram:=u,dGet1Ram)},oDlg1Lib,060,014,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dGet1Ram",,)
     oGet2Ram   := TGet():New( 022,044,{|u| If(PCount()>0,cGet2Ram:=u,cGet2Ram)},oDlg1Lib,032,014,'@R 99:99',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGet2Ram",,)
     oBtn1Ram   := TButton():New( 046,004,"Confirma",oDlg1Lib,{ || fBxRampa(cTipoProd) },053,012,,oFont1,,.T.,,"",,,,.F. )
     oBtn2Ram   := TButton():New( 046,072,"Abandona",oDlg1Lib,{ || oDlg1Lib:End() },053,012,,oFont1,,.T.,,"",,,,.F. )

     oDlg1Lib:Activate(,,,.T.)

Return

User Function CorrigeVol(_cPedido)   
Local cArea    := alias()
Local aAreaAnt := U_PegaArea({"SC5","SZ5","SB1","SG1","SZO"})
Local cTmp,nVolTotal,i,nVar,lAchou,lEmbaemG1,cComp,nQtdComp,nAuxQtde,nAuxVol,cQuery,nCubagem
Local aEmba          := {}  //Tipos de Embalagens utilizada, Colunas: 1-CÛd Emba; 2-Qtde de Embal; 3-Qtde p/ Juntar Vol; 4-Qtde Vol. produtos que n„o juntam vol; 5-Qtde BM ou BL p/ verif. se fecham vol; 6-Rel. Volume
Local aAuxEmba       := {}
Local j  

dbselectarea("SC5")
DbSetOrder(1)

dbselectarea("SB1")
DbSetOrder(1)

dbselectarea("SZ5")
DbSetOrder(1)

dbselectarea("SG1")
DbSetOrder(1)

dbselectarea("ZZO")
dbsetorder(1)

cTmp := U_NovoCursor()

cQuery := "SELECT C6_NUM AS PEDIDO,C6_PRODUTO AS PROD,C6_QTDVEN AS QTDE,B1_RELVOL,F4_VOLQUEB,ISNULL(B1_ESP05,0) AS CUBC6,"+;
"CUBAGEM = ISNULL((SELECT SUM(B1_ESP05)*C6_QTDVEN FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = G1_COMP) "+;
	"WHERE (SG1.D_E_L_E_T_ <> '*') AND (G1_FILIAL = '"+xFilial("SG1")+"') AND (G1_COD = SC6.C6_PRODUTO)),0) "+;
"FROM "+retsqlname("SC6")+" SC6 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+retsqlname("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C6_FILIAL = C5_FILIAL) AND (C6_NUM = C5_NUM) "+;
"LEFT OUTER JOIN "+retsqlname("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (C6_PRODUTO = B1_COD) "+;
"LEFT OUTER JOIN "+retsqlname("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (C6_TES = F4_CODIGO) "+;
"WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C6_NUM = '"+_cPedido+"') "+;
"ORDER BY PROD"
TCQuery cQuery ALIAS (cTmp) NEW
dbselectarea(cTmp)
dbgotop()
	aEmba := {}
	while !eof()
            // Determinar em lVolJunto se produto junta volume c/ outros ou n„o, p/ efeito de c·lculo de volumes
            lVolJunto := U_VolJunto((cTmp)->PROD) 
	        nCubagem := iif((cTmp)->CUBAGEM > 0,(cTmp)->CUBAGEM,(cTmp)->CUBC6)
            //DeterminaÁ„o dos Pesos Liquido/Bruto, da quantidade de volumes e volume por cor
			aAuxEmba := {}   
            If (Len(Alltrim((cTmp)->PROD)) == 12) .and. (Substr((cTmp)->PROD, 11, 2) # "00.99")
				aAdd(aAuxEmba, {Alltrim(Substr((cTmp)->PROD, 11, 2)),0,0,0,0,"",nCubagem}) 

               	lEmbaemG1 := .f. //Identifica se h· tipo de embalagem na estrutura, caso contr·rio pega dos 2 dÌg. finais do cÛdigo do produto
               	IF (cTmp)->B1_RELVOL > 0
					aAuxEmba[1][6] := alltrim(STR((cTmp)->B1_RELVOL))
                  	nAuxVol := U_DetVolEmba(aAuxEmba[1][6], (cTmp)->QTDE ) //* Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
                   	aAuxEmba[1][2] := (cTmp)->QTDE // * Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
                    aAuxEmba[1][3] := iif(lVolJunto,(cTmp)->QTDE,0)
                    aAuxEmba[1][4] := iif(!lVolJunto,nAuxVol,0)
                    aAuxEmba[1][5] := iif(lVolJunto .and. ((cTmp)->F4_VOLQUEB != "S") .and.  (substr((cTmp)->PROD,1,2) = "BL"),(cTmp)->QTDE,0)
				else 
               
               		DbSelectArea("SG1")
               		DbSeek(xFilial("SG1")+(cTmp)->PROD, .F.)
               		If Found()
               			While !Eof() .AND. (SG1->G1_FILIAL == xFilial("SG1")) .AND. (SG1->G1_COD = (cTmp)->PROD) .AND. (Len(RTrim(SG1->G1_COMP)) == 4)
                        	cComp    := RTrim(SG1->G1_COMP)
                        	nQtdComp := 0
        	    	   		While !Eof() .AND. (SG1->G1_FILIAL == xFilial("SG1")) .AND. (SG1->G1_COD = (cTmp)->PROD) .AND. (Len(RTrim(SG1->G1_Comp)) == 4) .AND. (RTrim(SG1->G1_COMP) == cComp)
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
									aAdd(aAuxEmba, {Alltrim(Substr((cTmp)->PROD, 11, 2)),0,0,0,0,alltrim(SZ5->Z5_RELVOL),0}) 
								else        
									if empty(aAuxEmba[nVar][6])
										aAuxEmba[nVar][6] := alltrim(SZ5->Z5_RELVOL)
									endif 
                        		endif
                        		
		
                           		nAuxQtde := (cTmp)->QTDE * nQtdComp
                           		nAuxVol := U_DetVolEmba(aAuxEmba[nVar][6], nAuxQtde ) //* Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)

                           		aAuxEmba[nVar][2] := aAuxEmba[nVar][2] + nAuxQtde // * Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
                           		aAuxEmba[nVar][3] := aAuxEmba[nVar][3] + iif(lVolJunto,nAuxQtde,0)
                           		aAuxEmba[nVar][4] := aAuxEmba[nVar][4] + iif(!lVolJunto,nAuxVol,0)
                           		aAuxEmba[nVar][5] := aAuxEmba[nVar][5] + iif(lVolJunto .and. ((cTmp)->F4_VOLQUEB != "S") .and. (substr((cTmp)->PROD,1,2) $ "BL"),nAuxQtde,0)

                        	Endif
                        	DbSelectArea("SG1")
                  		EndDo
               		Endif
					// Se n„o tiver embalagem na estrutura considerar cÛdigo final.
					If !lEmbaemG1 .and. (Substr((cTmp)->PROD, 11, 2) # "00.99") // Se n„o tiver cÛd. de embalagem na estrutura, pegar pelo final do cÛd. do prod.
	    	           	DbSelectArea("SZ5")
     					DbSeek(xFilial("SZ5")+aAuxEmba[1][1])
						If Found()
							aAuxEmba[1][6] := alltrim(SZ5->Z5_RELVOL)
						endif 
    	              	nAuxVol := U_DetVolEmba(aAuxEmba[1][6], (cTmp)->QTDE ) //* Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
        	           	aAuxEmba[1][2] := (cTmp)->QTDE // * Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
            	        aAuxEmba[1][3] := iif(lVolJunto,(cTmp)->QTDE,0)
                	    aAuxEmba[1][4] := iif(!lVolJunto,nAuxVol,0)
	                    aAuxEmba[1][5] := iif(lVolJunto .and. ((cTmp)->F4_VOLQUEB != "S") .and.  (substr((cTmp)->PROD,1,2) $ "BL"),(cTmp)->QTDE,0)
					Endif 
            	endif 

            Else // Se n„o for cÛdigo de 12 dÌgitos(Tinta) !
            	If (Len(Alltrim((cTmp)->PROD)) == 12) // .and. (Substr((cTmp)->PROD, 11, 2) == "99")
//                  	nQtdeVol := nQtdeVol + 1
					aAuxEmba := {}   
					aAdd(aAuxEmba, {Substr((cTmp)->PROD, 11, 2),(cTmp)->QTDE         ,0,1,0,alltrim(str((cTmp)->QTDE)),nCubagem}) 
     			ELSE 
     				nAux := 0
     				IF (cTmp)->B1_RELVOL > 0
	                  	nAux := round((cTmp)->QTDE  / (cTmp)->B1_RELVOL,3)   //* Iif(!Empty(Alltrim(M->C5_ESPECI4)), 2, 1)
    	              	If Int(nAux) < nAux
        	             	nAux := Int(nAux) + 1
            	      	Endif
         			ENDIF
					aAuxEmba := {}   
					aAdd(aAuxEmba, {"--",(cTmp)->QTDE,0,nAux,0,alltrim(str((cTmp)->B1_RELVOL)),nCubagem}) 
               	Endif

            Endif
    		for j := 1 to len(aAuxEmba)
    			
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
           		aEmba[nVar,7] += aAuxEmba[j,7]
           next 
			// tÈrmino c·lc. volumes p/ o item
		dbselectarea(cTmp)
		dbskip()
	enddo

    //Qtde de Volumes e cubagem ‡ partir de vetor gerado e/ou Volume Total Gerado

    
	dbselectarea("ZZO")    
	dbseek(xFilial("ZZO")+_cPedido,.f.)
		
	For i := 1 to Len(aEmba)   
		nQtdeVol := aEmba[i][4]
		If aEmba[i][3] > 0
 			nQtdeVol += U_DetVolEmba(aEmba[i][6], aEmba[i][3])
 			aEmba[i][4] := nQtdeVol
	   	Endif                                                 
    	dbselectarea("ZZO")    
		if !eof() .and. (ZZO->ZZO_FILIAL == xFilial("ZZO")) .and. (ZZO_PEDIDO == _cPedido)
			aEmba[i][5] := recno()
			dbskip()
		else
			aEmba[i][5] := 0
		endif
			
	Next
	do while !eof() .and. (ZZO->ZZO_FILIAL == xFilial("ZZO")) .and. (ZZO_PEDIDO == _cPedido)
		reclock("ZZO",.f.)
		dbdelete()	
		msunlock()
		dbskip()
	enddo 

	nVolTotal := 0
	nCubagem := 0
	dbselectarea("ZZO")    
	For i := 1 to Len(aEmba)   
		if aEmba[i][5] == 0
			reclock("ZZO",.t.)   
		else
    	 	dbgoto(aEmba[i][5])
			reclock("ZZO",.f.)
		endif
		ZZO->ZZO_FILIAL := xFilial("ZZO")
		ZZO->ZZO_PEDIDO := _cPedido
		ZZO->ZZO_EMBA := aEmba[i][1]
		ZZO->ZZO_QTDE := aEmba[i][2]        
		ZZO->ZZO_QTDVOL := aEmba[i][4] 
		ZZO->ZZO_CUBAGE := aEmba[i][7] 
		nVolTotal += aEmba[i][4]       
		nCubagem += aEmba[i][7]
		msunlock()
	next
		
			
  	dbselectarea("SC5")
  	dbseek(xFilial("SC5")+_cPedido)
  	if found()            
  		if (nVolTotal > 0) .OR. (nCubagem > 0)
	  		reclock("SC5",.F.)
	  		if nVolTotal > 0
		  		SC5->C5_VOLUME1 := nVolTotal
		  	endif
	  		SC5->C5_VOLUME2 := iif(nCubagem > 0,nCubagem,0)
  		  	//ATEN«√O!!! SE SALVAR C5_ESPECI2 O PROGRAMA NFESEFAZ IR¡ SOMAR AO TOTAL DE VOLUMES A QTDE DE C5_VOLUME2!!
	  		//SC5->C5_ESPECI2 := iif(nCubagem > 0,"CUBAGEM","")
  			msunlock()
  		endif 
  	endif 

dbselectarea(cTmp)
dbclosearea()

U_VoltaArea(aAreaAnt)
if !empty(cArea)
	DbSelectArea(cArea)
endif 

return     

//FunÁ„o para verificar se a relaÁ„o de volumes por embalagens est· coerente
User Function VerificaVolumes(_cPed)   
Local cQuery,cTmp
Local aArea := GetArea()

cTmp := U_NovoCursor()


cQuery := "SELECT C5_NUM FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("ZZO")+" ZZO (NOLOCK) ON (ZZO.D_E_L_E_T_ <> '*') AND (C5_FILIAL = ZZO_FILIAL) AND (C5_NUM = ZZO_PEDIDO) AND (ZZO_PEDIDO IS NOT NULL) "+;
"WHERE (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_NOTA = '') AND (C5_EMISSAO >= '20180101') "+;
iif(!empty(_cPed),"AND (C5_NUM = '"+_cPed+"') ","")+;
"GROUP BY C5_FILIAL,C5_NUM "+;
"HAVING SUM(ISNULL(ZZO_QTDVOL,0)) <> MAX(C5_VOLUME1)"
TCQuery cQuery ALIAS (cTmp) NEW


dbselectarea(cTmp)
dbgotop()
while !eof() 
	U_CorrigeVol((cTmp)->C5_NUM)
	dbselectarea(cTmp)
	dbskip()
enddo
dbselectarea(cTmp)
dbclosearea()  

cQuery := "WITH TMPCOMP AS "+;
"("+;
"SELECT C6_FILIAL,C6_NUM,SUM(C6_QTDVEN) AS S1,S2 = (SELECT SUM(ZZO_QTDE) FROM "+RetSqlName("ZZO")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND "+;
"(ZZO_FILIAL = C6_FILIAL) AND (ZZO_PEDIDO = C6_NUM)) FROM "+RetSqlName("SC6")+" SC6 (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C6_FILIAL = C5_FILIAL) AND (C6_NUM = C5_NUM) "+;
"WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C5_NOTA = '') AND (C5_EMISSAO >= '20100101') "+;
iif(!empty(_cPed),"AND (C6_NUM = '"+_cPed+"') ","")+;
"GROUP BY C6_FILIAL,C6_NUM "+;
")"+;
"SELECT * FROM TMPCOMP WHERE S1 <> S2 ORDER BY C6_NUM"
TCQuery cQuery ALIAS (cTmp) NEW


dbselectarea(cTmp)
dbgotop()
while !eof() 
	U_CorrigeVol((cTmp)->C6_NUM)
	dbselectarea(cTmp)
	dbskip()
enddo
dbselectarea(cTmp)
dbclosearea()  


RestArea(aArea)

return(.t.)

User Function NovoCursor()
Local nCont,cTmp
Local aArea := GetArea()

nCont := 0
cTmp := "TMP0"
while Select(cTmp)<>0
	cTmp := "TMP0"+alltrim(str(nCont))    
	nCont++ 
enddo           
RestArea(aArea)

return(cTmp) 

User Function NovoArqTrab(_cExt)
Local nCont,cTmp

nCont := 0
cTmp := "TMP"
while FILE(cTmp+"."+_cExt)
	cTmp := "TMP"+alltrim(str(nCont))   
	nCont++
enddo    

return(cTmp)

User Function UltDiaMes(nMes,nAno)
Local nAuxMes,nAuxAno,dAux

nAuxMes := nMes+1
if nAuxMes > 12
	nAuxMes := 1
	nAuxAno := nAno + 1
else
	nAuxAno := nAno
endif 
dAux := ctod("01/"+padl(alltrim(str(nAuxMes)),2,"0")+"/"+padl(alltrim(str(nAuxAno)),4,"0")) - 1

return(dAux)

User Function DigEan13(cCod)
Local nSoma1,nSoma2,nTotal,cRet,i,nMult1,nMult2,nTam

nSoma1 = 0
nSoma2 = 0
nTam = LEN(ALLTRIM(cCod))
IF ((nTam/2) - int(nTam/2)) == 0.5
	nMult1 = 1
	nMult2 = 3
ELSE
	nMult1 = 3
	nMult2 = 1
ENDIF 


	for i := 1 to len(cCod)
		if (i/2 - int(i/2)) == 0.5
			nSoma2 := nSoma2 + val(substr(cCod,i,1))
		else
			nSoma1 := nSoma1 + val(substr(cCod,i,1))
		endif
	next
	nTotal := (nSoma1*nMult1)+(nSoma2*nMult2)
	cRet = alltrim(str(10 - (nTotal/10 - int(nTotal/10))*10))
	IF cRet == "10"
		cRet = "0"
	ENDIF 
	

return(cRet)       

//Retorna o valor de tabela descontado caso algum desconto esteja preenchido ou o vlr esteja zerado
//Usado em gatilho para C6_PRODUTO e C6_QTDVEN

User Function DescPed(nVlrTab,nVlrOrig,nDesc1,nDesc2,nDesc3)
local nRet        
if (nVlrTab > 0) .and. ((nVlrOrig = 0) .or. (nDesc1 > 0) .or. (nDesc2 > 0) .or. (nDesc3 > 0))
	nRet = round(nVlrTab*(1-(nDesc1/100))*(1-(nDesc2/100))*(1-(nDesc3/100)),4)
else
	if nVlrOrig > 0
		nRet := nVlrOrig
	else
		nRet := nVlrTab
	endif 
endif                 

return(nRet)      

//Retorna o valor de tabela descontado caso algum desconto esteja preenchido ou o vlr esteja zerado
//Usado em gatilho para C6_PRODUTO e C6_QTDVEN


//Cleber (13/05/20) ->voltando funÁ„o anterior ‡ atualizaÁ„o de retirada de ctree
/*
User Function DescPed( nVlrTab, nVlrOrig, nDesc1, nDesc2, nDesc3 )
     Local nRet
     Local nPosSC6  := n
     Local nPosVlrT := aScan(aHeader, { |x| Alltrim( x[2] ) == "C6_XPRUNIT" } ) //LGS#20191121 - AdequaÁ„o para release 12.1.25
     Local nPosVlrO := aScan(aHeader, { |x| Alltrim( x[2] ) == "C6_PRCVEN"  } ) //LGS#20191121 - AdequaÁ„o para release 12.1.25
     
     nVlrTab  := Iif( nVlrTab  == 0, aCols[ nPosSC6][ nPosVlrT], nVlrTab  ) //LGS#20191121 - AdequaÁ„o para release 12.1.25
     nVlrOrig := Iif( nVlrOrig == 0, aCols[ nPosSC6][ nPosVlrO], nVlrOrig ) //LGS#20191121 - AdequaÁ„o para release 12.1.25
     If (nVlrTab > 0) .and. ((nVlrOrig = 0) .or. (nDesc1 > 0) .or. (nDesc2 > 0) .or. (nDesc3 > 0))
        nRet = round(nVlrTab*(1-(nDesc1/100))*(1-(nDesc2/100))*(1-(nDesc3/100)),4)
     Else
        If nVlrOrig > 0
           nRet := nVlrOrig
        Else
           nRet := nVlrTab
        Endif 
     Endif

Return(nRet)    
*/

User Function DetSaldo(_cProd)
Local cArea    := alias()
Local aAreaAnt := U_PegaArea({"SB2"})
Local nSaldo

dbselectarea("SB2")
DbSetorder(1)

nSaldo := 0

// Calcula o saldo atual dos almoxarifados escolhidos 
dbSelectArea("SB2")
dbSeek(xFilial("SB2")+_cProd)
While !EOF() .And. (SB2->B2_FILIAL = xFilial("SB2")) .AND. (ALLTRIM(SB2->B2_COD) == ALLTRIM(_cProd))
	nSaldo += SALDOSB2(.T.)+SB2->B2_SALPEDI-SB2->B2_QEMPN+AvalQtdPre("SB2",2)
	dbselectarea("SB2")
	dbSkip()
EndDo    
//SaldoSB2(.T., , ,lConsTerc,lConsNPT)+SB2->B2_SALPEDI-SB2->B2_QEMPN+AvalQtdPre("SB2",2)	

/*
// Verifica a necessidade do material considerando estoque de seguranca
// e Ponto de Pedido
nNeces := SB1->B1_EMIN + SB1->B1_ESTSEG - nSaldo
// Utiliza a funcao padrao CalcLote para calculo de necessidades
If nNeces > 0
	aQtdes := CalcLote(_cProd,nNeces,"F")   
EndIf      
*/

U_VoltaArea(aAreaAnt)
if !empty(cArea)
	DbSelectArea(cArea)
endif 

return(nSaldo)

User Function LiberaPed(_cNum)
Local aArea := getarea()
Local lRet := .t.,_cFilial := xFilial("SC6"),_lAchou
Local nRegC5,lRegC5,nOrdC5,nRegC6,lRegC6,nOrdC6,nQtdLib,;
nRegC9,lRegC9,nOrdC9

dbselectarea("SC9")
nOrdC9 := IndexOrd()
if !eof() .and. !bof()	 
	lRegC9 = .t.
   	nRegC9 = recno()
else
	lRegC9 = .f.
endif 

dbselectarea("SC5")
nOrdC5 := IndexOrd()
if !eof() .and. !bof()	 
	lRegC5 = .t.
   	nRegC5 = recno()
else
	lRegC5 = .f.
endif 

dbselectarea("SC6")
nOrdC6 := IndexOrd()
if !eof() .and. !bof()	 
	lRegC6 = .t.
   	nRegC6 = recno()
else
	lRegC6 = .f.
endif 


dbselectarea("SC5")
DbSetorder(1)
dbseek(xFilial("SC5")+_cNum) 
if !found()
	lRet := .f.
endif 


dbselectarea("SC6")
dbsetorder(1)
dbseek(xFilial("SC6")+_cNum,.t.)
if !found()
	lRet := .f.
endif
While lRet .and. !EOF() .And. (SC6->C6_FILIAL = _cFilial) .and. (SC6->C6_NUM == _cNum)
     
     If RecLock("SC5")
          nQtdLib := SC6->C6_QTDVEN
          //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
          //≥Recalcula a Quantidade Liberada                                         ≥
          //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
          RecLock("SC6") //Forca a atualizacao do Buffer no Top
          //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
          //≥Libera por Item de Pedido                                               ≥
          //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
          Begin Transaction
          /*
          ±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
          ±±≥Funcao    ≥MaLibDoFat≥ Autor ≥Eduardo Riera          ≥ Data ≥09.03.99 ≥±±
          ±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
          ±±≥Descri?.o ≥Liberacao dos Itens de Pedido de Venda                      ≥±±
          ±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
          ±±≥Retorno   ≥ExpN1: Quantidade Liberada                                  ≥±±
          ±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
          ±±≥Transacao ≥Nao possui controle de Transacao a rotina chamadora deve    ≥±±
          ±±≥          ≥controlar a Transacao e os Locks                            ≥±±
          ±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
          ±±≥Parametros≥ExpN1: Registro do SC6                                      ≥±±
          ±±≥          ≥ExpN2: Quantidade a Liberar                                 ≥±±
          ±±≥          ≥ExpL3: Bloqueio de Credito                                  ≥±±
          ±±≥          ≥ExpL4: Bloqueio de Estoque                                  ≥±±
          ±±≥          ≥ExpL5: Avaliacao de Credito                                 ≥±±
          ±±≥          ≥ExpL6: Avaliacao de Estoque                                 ≥±±
          ±±≥          ≥ExpL7: Permite Liberacao Parcial                            ≥±±
          ±±≥          ≥ExpL8: Tranfere Locais automaticamente                      ≥±±
          ±±≥          ≥ExpA9: Empenhos ( Caso seja informado nao efetua a gravacao ≥±±
          ±±≥          ≥       apenas avalia ).                                    ≥±±
          ±±≥          ≥ExpbA: CodBlock a ser avaliado na gravacao do SC9           ≥±±
          ±±≥          ≥ExpAB: Array com Empenhos previamente escolhidos            ≥±±
          ±±≥          ≥       (impede selecao dos empenhos pelas rotinas)          ≥±±
          ±±≥          ≥ExpLC: Indica se apenas esta trocando lotes do SC9          ≥±±
          ±±≥          ≥ExpND: Valor a ser adicionado ao limite de credito          ≥±±
          ±±≥          ≥ExpNE: Quantidade a Liberar - segunda UM                    ≥±±
          */
			dbselectarea("SC9")
			dbsetorder(1)
			dbseek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)
			_lAchou := found()
			if !_lAchou .or. (_lAchou .and. !(SC6->C6_PRODUTO == SC9->C9_PRODUTO))
	          	MaLibDoFat(SC6->(RecNo()),@nQtdLib,.T.,.F.,.T.,.T.,.F.,.F.)     
	  		endif
          End Transaction
     EndIf
     SC6->(MsUnLock())
     //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
     //≥Atualiza o Flag do Pedido de Venda                                      ≥
     //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
     Begin Transaction
        SC6->(MaLiberOk({_cNum},.F.))
     End Transaction
     
     dbSelectArea("SC6")
     dbSkip()
EndDo

dbselectarea("SC5")
dbsetorder(nOrdC5)
if lRegC5
	dbgoto(nRegC5)
endif    
dbselectarea("SC6")
dbsetorder(nOrdC6)
if lRegC6
	dbgoto(nRegC6)
endif    
dbselectarea("SC9")
dbsetorder(nOrdC9)
if lRegC9
	dbgoto(nRegC9)
endif    

restarea(aArea)

return(lRet)     

/*************************/
/*************************
Gera arquivo .TXT na pasta SYSTEM com dados das funÁıes do RPO

**************************/
User Function CheckRPO()
Local nHdl,aRet,aInfo,nX,nY,cLinha
nHdl := fCreate("LOGRPO.TXT")
aRet := GetSrcArray("*.*")

For nX := 1 To Len(aRet)
	aInfo := getApoInfo(aRet[nX])
	cLinha := aRet[nX] + ","
	For nY := 1 To Len(aInfo)
		cLinha += Transform(aInfo[nY],"") + ","
	Next
	fWrite(nHdl, cLinha + chr(13)+chr(10) )
Next

fClose(nHdl)
Return
///////////////////////////////////////////////////////


/* Pegar informaÁıes de indice e posiÁ„o de registros em tabelas para posterior restauraÁ„o */     
User Function PegaArea(_aAliases)
Local _cAlias := alias()
Local i,nReg,nOrdem,aRet := {}
//Primeiro registro È o Alias corrente
aadd(aRet,{_cAlias,0,0})

for i := 1 to len(_aAliases)
  if Select(_aAliases[i])<>0
	dbselectarea(_aAliases[i])   
	nOrdem := IndexOrd() 
	if !eof() .and. !bof()
		nReg := recno()
	else
		nReg := 0
	endif 
	aadd(aRet,{_aAliases[i],nOrdem,nReg})
  endif
next 
if !empty(_cAlias)
	dbselectarea(_cAlias)
endif 
return(aRet)  

/* Voltar area atraves de matriz de tabelas */  
User Function VoltaArea(_aArea)
Local i
//ComeÁa com o segundo item pois o primeiro È o Alias corrente a ser restaurado
for i := 2 to len(_aArea)  
	dbselectarea(_aArea[i,1])   
	dbsetorder(_aArea[i,2])
	if _aArea[i,3] > 0
		dbgoto(_aArea[i,3])
	endif 
next 
//Restaurar alias corrente
if !empty(_aArea[1,1])
	dbselectarea(_aArea[1,1])
endif 
return(.t.)  


//FunÁ„o que verifica se det. pedido tem algum spray. Usado para marcar bordero de despacho
User Function fTemSpray(_cPed)
Local aArea := U_PegaArea({"SC6"})
Local lRet := .f. ,cAuxPed

cAuxPed := iif(len(alltrim(_cPed)) == 8,substr(_cPed,3,6),_cPed)

Dbselectarea("SC6")
Dbsetorder(1)
Dbseek(xFilial("SC6")+cAuxPed)

Do while !lRet .and. !eof() .and. (ALLTRIM(SC6->C6_FILIAL) == ALLTRIM(xFilial("SC6"))) .and. (SC6->C6_NUM = cAuxPed)
	If Substr(SC6->C6_PRODUTO,1,5) $ 'ST 55'
		lRet := .t.
		Exit 
	Endif
	Dbselectarea("SC6")
	Dbskip()
Enddo 

U_VoltaArea(aArea)
Return(lRet)


//FunÁ„o que verifica se det. pedido tem TES de amostra. Usado para impedir digitaÁ„o de Bord. Pedidos                  
User Function BRTEMAMOSTRA(_cPed)
Local aArea := U_PegaArea({"SC6"})
Local lRet := .f. ,cTes,cAuxPed
cTes := "614_616_617_618_615_661_664" //Rel. de TES de amostras

cAuxPed := iif(len(alltrim(_cPed)) == 8,substr(_cPed,3,6),_cPed)
dbselectarea("SC6")
dbsetorder(1)
dbseek(xFilial("SC6")+cAuxPed)
do while !lRet .and. !eof() .and. (ALLTRIM(SC6->C6_FILIAL) == ALLTRIM(xFilial("SC6"))) .AND. (SC6->C6_NUM = cAuxPed)
	if SC6->C6_TES $ cTes
		lRet := .t.
		exit 
	endif
	dbselectarea("SC6")
	dbskip()
enddo 

U_VoltaArea(aArea)
return(lRet)

User Function FILTSQL(_cFiltro)
Local cRet,nPos,nCont,cAux
cRet := alltrim(_cFiltro)
if empty(cRet)
	return(cRet)
endif 
cRet := upper(strtran(cRet,'"',"'"))
cRet := strtran(cRet,".AND."," AND ")
cRet := strtran(cRet,".OR."," OR ")
cRet := strtran(cRet,"DTOS(","")
cRet := strtran(cRet,"ALLTRIM(","")
cRet := strtran(cRet,")","")
cRet := strtran(cRet,"!=","<>")
cRet := strtran(cRet,"==","=")
while "$" $ cRet
	nPos := at("$",cRet) 
	cAux := substr(cRet,1,nPos-1)+"IN("
	nCont := nPos+1
	while (substr(cRet,nCont,1) == " ")
		nCont++
	enddo 
	while (substr(cRet,nCont,1) != " ")
		cAux += substr(cRet,nCont,1)
		nCont++
	enddo 
	cAux += ") "+substr(cRet,nCont+1,len(cRet)-nCont)
	cRet := cAux
enddo 
	
return(cRet)

//FunÁ„o para liberar pedido.
//ATEN«AO! O SC5 dever· estar posicionado no pedido a liberar
User Function fPedLib()
Local cArea := alias()
Local aArea := U_PegaArea({"SA3","SA2","SA1","SB2","SB5","SC5","SD1","SF1","SF4","SG1","SZ1","SZ5","ZZO","SC6","SC9"})
Local nQtdLib := 0
Local _cNum := SC5->C5_NUM
Local _cFilial := xFilial("SC6")
Local _lAchou,lTransf
Local aRegistros:= {}
LOCAL lMVXHABBOR := GETMV("MV_XHABBOR")

//***06/06/212

if SC5->C5_LIBEROK = "S"
	if !empty(cArea)
		dbselectarea(cArea)
	endif 
	return .t.
endif 
	DbSelectarea("SA3")
	DbSetOrder(1)
	DbSelectarea("SA2")
	DbSetOrder(1)
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSelectArea("SB2")
	DbSetOrder(1)
    DbSelectArea("SB5")
    DbSetOrder(1)
	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSelectArea("SD1")
	DbSetOrder(1)
	DbSelectArea("SF1")
	DbSetOrder(1)
	DbSelectArea("SF4")
	DbSetOrder(1)
    DbSelectArea("SG1")
	DbSetOrder(1)
	DbSelectArea("SZ1")
	DbSetOrder(1)
	DbSelectArea("SZ5")
	DbSetOrder(1)
	DbSelectArea("ZZO")
	DbSetOrder(1)

	DbSelectArea("SC6")
	DbSetOrder(1)


dbselectarea("SC6")
dbseek(_cFilial+_cNum,.f.)

If RecLock("SC5")
	While !EOF() .And. (SC6->C6_FILIAL = _cFilial) .and. (SC6->C6_NUM == _cNum)
     
          nQtdLib := SC6->C6_QTDVEN
          //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
          //≥Recalcula a Quantidade Liberada                                         ≥
          //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
          RecLock("SC6") //Forca a atualizacao do Buffer no Top
          //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
          //≥Libera por Item de Pedido                                               ≥
          //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
          Begin Transaction
          /*
          ±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
          ±±≥Funcao    ≥MaLibDoFat≥ Autor ≥Eduardo Riera          ≥ Data ≥09.03.99 ≥±±
          ±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
          ±±≥Descri?.o ≥Liberacao dos Itens de Pedido de Venda                      ≥±±
          ±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
          ±±≥Retorno   ≥ExpN1: Quantidade Liberada                                  ≥±±
          ±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
          ±±≥Transacao ≥Nao possui controle de Transacao a rotina chamadora deve    ≥±±
          ±±≥          ≥controlar a Transacao e os Locks                            ≥±±
          ±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
          ±±≥Parametros≥ExpN1: Registro do SC6                                      ≥±±
          ±±≥          ≥ExpN2: Quantidade a Liberar                                 ≥±±
          ±±≥          ≥ExpL3: Bloqueio de Credito                                  ≥±±
          ±±≥          ≥ExpL4: Bloqueio de Estoque                                  ≥±±
          ±±≥          ≥ExpL5: Avaliacao de Credito                                 ≥±±
          ±±≥          ≥ExpL6: Avaliacao de Estoque                                 ≥±±
          ±±≥          ≥ExpL7: Permite Liberacao Parcial                            ≥±±
          ±±≥          ≥ExpL8: Tranfere Locais automaticamente                      ≥±±
          ±±≥          ≥ExpA9: Empenhos ( Caso seja informado nao efetua a gravacao ≥±±
          ±±≥          ≥       apenas avalia ).                                    ≥±±
          ±±≥          ≥ExpbA: CodBlock a ser avaliado na gravacao do SC9           ≥±±
          ±±≥          ≥ExpAB: Array com Empenhos previamente escolhidos            ≥±±
          ±±≥          ≥       (impede selecao dos empenhos pelas rotinas)          ≥±±
          ±±≥          ≥ExpLC: Indica se apenas esta trocando lotes do SC9          ≥±±
          ±±≥          ≥ExpND: Valor a ser adicionado ao limite de credito          ≥±±
          ±±≥          ≥ExpNE: Quantidade a Liberar - segunda UM                    ≥±±
          */
          	lTransf := iif(!lMVXHABBOR .OR. (SC5->C5_TIPO <> 'N'),.F.,.T.)
			dbselectarea("SC9")
			dbsetorder(1)
			dbseek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)
			_lAchou := found()
			if !_lAchou .or. (_lAchou .and. !(SC6->C6_PRODUTO == SC9->C9_PRODUTO))
				If ( SC5->C5_TIPLIB == "1" )
					If !lMVXHABBOR .OR. (SC5->C5_TIPO <> 'N')  // liberaÁ„o credito e estoque se parametro desativado, liberaÁ„o somente credito se parametro ativado
						MaLibDoFat(SC6->(RecNo()),@nQtdLib           ,.T.                 ,.F.                ,.T.                 ,.T.                 ,.F.                      ,lTransf)  
					Else
						// LIBERA CREDITO - BLOQUEIA ESTOQUE
						MaLibDoFat(SC6->(RecNo()),@nQtdLib           ,.T.                 ,.F.                ,.T.                 ,.F.                 ,.F.                      ,lTransf,,,,,,0,)
						//MaLibDoFat(Registro do SC6 ,Quantidade a Liberar,Bloqueio de Credito ,Bloqueio de Estoque,Avaliacao de Credito,Avaliacao de Estoque,Permite Liberacao Parcial,Tranfere Locais automaticamente )
					Endif
				Else
					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥Libera por Pedido                                                       ≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ			
					Begin Transaction
					RecLock("SC6",.f.)
					SC6->C6_QTDLIB := nQtdLib
					MsUnLock()
					aadd(aRegistros,SC6->(RecNo()))
					End Transaction
				EndIf
	  		endif
          End Transaction
          SC6->(MsUnLock())
     
          dbSelectArea("SC6")
          dbSkip()
     EndDo
EndIf
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Libera por Total de Pedido                                              ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If ( Len(aRegistros) > 0 )
	Begin Transaction
	SC6->(MaAvLibPed(_cNum,.F.,lTransf,.F.,aRegistros,Nil,Nil,Nil,!lTransf))
	End Transaction
EndIf

 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Atualiza o Flag do Pedido de Venda                                      ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Begin Transaction
SC6->(MaLiberOk({_cNum},.F.))
End Transaction

SC5->(MsUnLock())
SC6->(dbCloseArea())

//*****06/06/2012

/*Local aArea := GetArea() 
 private INCLUI := .f.
 private ALTERA := .t.
 private lSugere := .f.
 private aCols , aHeadGrade, aColsGrade, aHeader
 


       DbSelectarea("SA3")
       DbSetOrder(1)
       DbSelectarea("SA2")
       DbSetOrder(1)
       DbSelectArea("SA1")
       DbSetOrder(1)
       DbSelectArea("SB2")
       DbSetOrder(1)
       DbSelectArea("SB5")
       DbSetOrder(1)
       DbSelectArea("SC5")
       DbSetOrder(1)
       DbSelectArea("SD1")
       DbSetOrder(1)
       DbSelectArea("SF1")
       DbSetOrder(1)
       DbSelectArea("SF4")
       DbSetOrder(1)
       DbSelectArea("SG1")
       DbSetOrder(1)
       DbSelectArea("SZ1")
       DbSetOrder(1)
       DbSelectArea("SZ5")
       DbSetOrder(1)
       DbSelectArea("ZZO")
       DbSetOrder(1)

       DbSelectArea("SC6")
       DbSetOrder(1)


	dbselectarea("SC6")
	dbseek(xFilial("SC6")+SC5->C5_NUM,.f.)
	dbselectarea("SC5")
		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Inicializa desta forma para criar uma nova instancia de variaveis private ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		RegToMemory( "SC5", .F., .F. )

		aHeadGrade := {}
		aColsGrade := {}
		aHeader := {}
		aCols := MontaCols()
		Begin Transaction
			A440Grava(.f.,.f.)
			EvalTrigger()
		End Transaction       

RestArea(aArea)*/
U_VoltaArea(aArea)
if !empty(cArea)
	dbselectarea(cArea)
endif 

return(.t.)     

User Function ParamSql(cCampo,cParam)
Local cRet,i,cChar,j,cCond
cCond := ""                
cCpo := ""
cParam := upper(cParam)
i := 0
while i < len(cParam) 
	i++ 
	cChar := alltrim(substr(cParam,i,1))
	if empty(cChar)
		loop
	endif 
	if isdigit(cChar) .or. isalpha(cChar)
		cCpo += cChar
	else        
		if cChar == "-"
			if !empty(cCond)
				cCond += " OR "
			endif 
			cCond += "("+cCampo+" BETWEEN '"+cCpo+"' AND '" 
			cCpo := ""
			for j := i+1 to len(cParam)
				cChar := substr(cParam,j,1)
				if empty(cChar)
					loop
				endif 
				if isdigit(cChar) .or. isalpha(cChar)
					cCpo += cChar
				else
					exit
				endif
			next
			i := j
			cCond += cCpo+"')"
		endif
		cCpo := ""
	endif 
enddo 
cRet := cCond
cCond := ""  
cCpo := ""
i := 0
while i < len(cParam) 
	i++ 
	cChar := alltrim(substr(cParam,i,1))
	if empty(cChar)
		loop
	endif 
	if isdigit(cChar) .or. isalpha(cChar) 
		cCpo += cChar
	else        
		if cChar != "-"
			if !empty(cCond)
				cCond += ","
			endif
			cCond += "'"+cCpo+"'"
		else
			cCpo := ""
			for j := i+1 to len(cParam)
				cChar := substr(cParam,j,1)
				if empty(cChar)
					loop
				endif 
				if !isdigit(cChar) .and. !isalpha(cChar)
					exit
				endif
			next
			i := j
		endif
		cCpo := ""
	endif 
enddo
if !empty(cCpo) 
	if !empty(cCond)
		cCond += ","
	endif
	cCond += "'"+cCpo+"'"
endif                  
if !empty(cRet) .and. !empty(cCond)
	cRet += " OR "
endif           

if !empty(cCond)
	cRet += "("+cCampo+" IN("+cCond+"))"
endif 	
if !empty(cRet)
	cRet := "("+cRet+")"
endif 
return(cRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥TEMPROEST∫Autor  ≥Mauricio-chaus      ∫ Data ≥  04/04/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Funcao de Validacao                                         ∫±±
±±∫          ≥                                                            ∫±± 
±±∫          ≥Esta funcao e chamada na validacao do campo CP_PRODUTO      ∫±±
±±∫          ≥e tem como objetivo verificar se o produto que esta sendo   ∫±±
±±∫          ≥requisitado na Requisicao ao Armazem esta associado a uma   ∫±±
±±∫          ≥estrutura de produto. Caso esteja n„o permite fazer a       ∫±±
±±∫          ≥requisicao. Somente Materias de Consumo e fora da estrutura  ∫±±
±±∫          ≥sao permitidos                                              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/


User Function TemProEst(_Cap) 
Local _Ret := .T.
Local _aAreaTmp := GetArea()
Local _NumReg := 0   
                        
//AlteraÁ„o Tiago Lucio/Chaus 02/06/2014
cQuery:=" SELECT TOP 1 R_E_C_N_O_ AS NUMREG FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) WHERE B1_FILIAL ='"+xFilial("SB1")+"' "
cQuery+=" AND D_E_L_E_T_ ='' AND B1_XREQUIS <>'S' AND B1_APROPRI <> 'I' AND B1_TIPO <> 'PA' "
cQuery+=" AND B1_COD = '"+_Cap+"'  "

TcQuery cQuery ALIAS "TMP" NEW
DbSelectArea("TMP")
IF !EOF() .AND. !BOF()
	_NumReg := 1
ENDIF 
TMP->(DbCloseArea()) 

/* retirada validaÁ„o de produtos para baixa de embalagens e pas para uso e consumo das filias em                       
                      
If _NumReg > 0 .And. (cNumEmp == "01010101") 
	_Ret := .F.                                       
	MsgBox("O Produto "+Ltrim(RTrim(_Cap))+" n„o esta configurado como produto de baixa por RequisiÁ„o, verifique o cadastro de produtos !! ","PRODUTO NA ESTRUTURA-BRASILUX-TEMPRODESTR.PRW","STOP")
	
EndIf                      
*/
                                    
/*                 
dbSelectArea("SG1")
dbSetOrder(2)  // G1_FILIAL+G1_COMP
dbSeek(xFilial("SG1")+_Cap,.f.)

If Found()                   	
	_Ret := .F.                                       
	MsgBox("O Produto "+Ltrim(RTrim(_Cap))+" Esta associado a uma Estrutura de Produto, sendo assim, n„o È permitido a solicitaÁ„o ao armazem","PRODUTO NA ESTRUTURA-BRASILUX-TEMPRODESTR.PRW","STOP")
EndIf
*/
RestArea(_aAreaTmp)
Return (_Ret)

// Funcao de ENvio de Email de Aviso 
User Function EnvMail(_cSubject, _cBody, _cMailTo, _cCC, _cAnexo, _cAccount, _cPass)
Local _cMailS		:= GetMv("MV_RELSERV")
Local lAuth			:= GetMv("MV_RELAUTH",,.F.)
Local _xx 
Default _cCC := ""
Default _cAnexo := ""
Default _cAccount	:= GetMV("MV_RELACNT")
Default _cPass		:= GetMV("MV_RELPSW")   

Connect Smtp Server _cMailS Account _cAccount Password _cPass RESULT lResult

If lAuth		// Autenticacao da conta de e-mail
	lResult := MailAuth(_cAccount, _cPass)
	If !lResult
		FwLogMSG( "WARN", , 'REST', funname(), '', '01', "Nao foi possivel autenticar a conta - " + _cAccount, 0 )
		Return(.f.)
	EndIf
EndIf

_xx := 0

lResult := .F.

do while !lResult
	
	If !Empty(_cAnexo)
		Send Mail From _cAccount To _cMailTo CC _cCC Subject _cSubject Body _cBody ATTACHMENT _cAnexo RESULT lResult
	Else
		Send Mail From _cAccount To _cMailTo CC _cCC Subject _cSubject Body _cBody RESULT lResult
	Endif
	
	_xx++
	if _xx > 2
		Exit
	Else
		Get Mail Error cErrorMsg
		FwLogMSG( "WARN", , 'REST', funname(), '', '01', cErrorMsg, 0 )
	EndIf
EndDo
Return(lResult)  
 
/*
Cleber (15/09/14)->Det. local padr„o considerando armazÈns tempor·rios para os depÛsitos fechados.
SituaÁ„o provisÛria atÈ que se implante o OMS daÌ os estoques ser„o diferenciados por endereÁo.
*/
User Function DetLocPad(cCodPro)
Local cArea := Alias()
Local aAreaAnt := U_PegaArea({"SB1","SB2"})
Local cRet := ""

if !empty(cCodPro)
	dbselectarea("SB1")
	dbsetorder(1)
	MsSeek(xFilial("SB1")+cCodPro)
	if found()
		do case

		case cNumEmp = "01010101"  //Matriz, entrar sempre no R0    PROJETO 17 - CRIA«√O DO ALMOXARIFADO R0 EM 16/06/16
			do case
			case SB1->B1_TIPO $ "MP.PI.PA"
				cRet := "R0"
			OTHERWISE
				cRet := SB1->B1_LOCPAD
			endcase 
		case cNumEmp = "01010106"  //DepÛsito Guarulhos
			do case
			case SB1->B1_TIPO = "MP"
				cRet := "G1"
			case SB1->B1_TIPO = "PI"
				cRet := "G2"
			case SB1->B1_TIPO = "PA"
				cRet := "G3"
			case SB1->B1_TIPO = "MC"
				cRet := "G4"
			OTHERWISE
				cRet := SB1->B1_LOCPAD
			endcase
		case cNumEmp = "01010107"//DepÛsito Mat„o
			do case
			case SB1->B1_TIPO = "MP"
				cRet := "M1"
			case SB1->B1_TIPO = "PI"
				cRet := "M2"
			case SB1->B1_TIPO = "PA"
				cRet := "M3"
			case SB1->B1_TIPO = "MC"
				cRet := "M4"
			OTHERWISE
				cRet := SB1->B1_LOCPAD
			endcase       
		otherwise
			cRet := alltrim(SB1->B1_LOCPAD)
		endcase 
		IF empty(cRet)   
			do case
			case SB1->B1_TIPO = "MP"
				cRet := "01"
			case SB1->B1_TIPO = "PI"
				cRet := "02"
			case SB1->B1_TIPO = "PA"
				cRet := "03"
			case SB1->B1_TIPO = "MC"
				cRet := "04"
			endcase       
		ENDIF 
		if !empty(cRet)
			dbselectarea("SB2")
			dbsetorder(1)
			dbseek(xFilial("SB2")+SB1->B1_COD+cRet)
			if !found()
				CriaSb2(SB1->B1_COD,cRet)
			endif  
		ENDIF 
	endif 
	
endif 
U_VoltaArea(aAreaAnt)
if !empty(cArea)
	DbSelectArea(cArea)
endif 
return(cRet)

//(09/10/2014 - Cleber) FunÁ„o que verifica se usu·rio est· autorizado a executar rotina passada como par‚metro
User Function VldAcesso(cPRWRotina)
Local aAreaAnt := U_PegaArea({"SZW"})
Local lRet := .t.

if PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),__CUSERID) <> 0 
   	DbSelectArea("SZW")
   	DbSetOrder(5)
   	DbSeek(__CUSERID + cPRWRotina)
   	if !found() .or. (found() .and. (substr(ZW_ACESSOS,1,1) != "*"))
   		lRet := .f.
	endif
endif 

U_VoltaArea(aAreaAnt)
return(lRet)  
    
//FunÁ„o que determina quais estados a sigla da regi„o pertence para utilizar em queries
User Function RegiaoGeo(cReg)  
local cAux   
	cReg := upper(cReg)
	do case
	CASE cReg = "SE"
		cAux := "'SP','RJ','ES','MG'"
	CASE cReg = "NE"
		cAux := "'MA','PI','CE','RN','PE','PB','SE','AL','BA'"
	CASE ALLTRIM(cReg) == "N"
		cAux := "'AM','RR','AP','PA','TO','RO','AC'"
	CASE ALLTRIM(cReg) == "S"
		cAux := "'PR','RS','SC'"
	CASE ALLTRIM(cReg) == "CO"
		cAux := "'MT','MS','GO','DF'"
	otherwise
		cAux := "'**'"
	endcase
return(cAux)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±∫Desc.     ≥Funcao de Validacao              20/01/15 AndrÈ              ∫±±
±±∫          ≥                                                             ∫±± 
±±∫          ≥Esta funcao e chamada na validacao do campo D3_COD           ∫±±
±±∫          ≥verifica se o produto esta com o B1_APROPRI = I para utilizar∫±±
±±∫          ≥as TMs 160,170,560,570                                       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ π±±
±±∫Uso       ≥ AP                                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function TemProInd(_cProd, _cTM) 

Local _Ret := .T.
Local _aAreaTmp := GetArea()
Local _NumReg := 0   

If !Empty(_cTM) .and. !Empty(_cProd)

	IF Posicione("SF5", 1, xFilial("SF5")+_cTM, "F5_APROPR") $ 'N'
	//IF _cTM $ '.160.170.560.570'                        

		cQuery:=" SELECT TOP 1 R_E_C_N_O_ AS NUMREG FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) WHERE B1_FILIAL ='"+xFilial("SB1")+"' "
		cQuery+=" AND (D_E_L_E_T_ ='') AND (B1_APROPRI <>'I') AND (B1_TIPO IN('MP','MC')) AND B1_COD = '"+_cProd+"'  "

		TcQuery cQuery ALIAS "TMP" NEW
		DbSelectArea("TMP")
		IF !EOF() .AND. !BOF()
			_NumReg := 1
		ENDIF 
		TMP->(DbCloseArea()) 
	                      
		If _NumReg > 0  
			_Ret := .F.                                       
			MsgBox("O Produto "+Ltrim(RTrim(_cProd))+" n„o esta classificado como ApropriaÁ„o Indireta, sendo assim, n„o È permitido utilizar este tipo de MovimentaÁ„o!! ","AtenÁ„o, Produto N„o È Indireto","STOP")
		Endif
	EndIf                      

Endif

RestArea(_aAreaTmp)
Return (_Ret)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±∫Desc.     ≥Funcao de Validacao              05/05/15 AndrÈ              ∫±±
±±∫          ≥                                                             ∫±± 
±±∫          ≥Esta funcao e chamada na validacao do campo ZN_COD           ∫±±
±±∫          ≥verifica se o produto È MP e se esta com o preÁo preenchido  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ π±±
±±∫Uso       ≥ AP                                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function FUprcMP(_cProd) 

Local _Ret := .T.
Local _aAreaTmp := GetArea()

If !Empty(_cProd) 
	
	cQuery:=" SELECT COUNT(R_E_C_N_O_) AS COUNT FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) WHERE B1_FILIAL ='"+xFilial("SB1")+"' "
	cQuery+=" AND (D_E_L_E_T_ ='') AND (B1_TIPO = 'MP') AND (B1_UPRC <=0) AND B1_COD = '"+_cProd+"'  "

	TcQuery cQuery ALIAS "TMP" NEW
	DbSelectArea("TMP")

	If !EOF() .AND. !BOF()
		IF TMP->COUNT >0
			_Ret := .F.                                       
			MsgBox("O custo do produto "+Ltrim(RTrim(_cProd))+" n„o esta preenchido, informe o setor de compras para preenchimento antes de utiliz·-lo !! ","AtenÁ„o, Produto sem PreÁo","STOP")
		Endif
	Endif
	TMP->(DbCloseArea()) 
	                      
Endif

RestArea(_aAreaTmp)
Return (_Ret)       

/*  
Cleber (04/09/2015)
FunÁ„o que retorna o cÛdigo do PI da Tinta (00 se for prod. em Litros e 99 se for prod. em Kg)
*/
User Function TrazPITinta(cProd)
Local cArea    := alias()
Local aAreaAnt := U_PegaArea({"SZ1","SB1"})
Local cRet := ""

if len(alltrim(cProd)) == 12
	dbselectarea("SB1")
	dbsetorder(1)
	dbseek(xFilial("SB1")+cProd)
	if found()
		dbselectarea("SZ1")
		dbsetorder(1)
		dbseek(xFilial("SZ1")+SUBSTR(cProd,4,2))
		if found()
			cRet = substr(cProd,1,10)+iif(SZ1->Z1_UM = "K","99","00")
		endif
	endif 
endif 

U_VoltaArea(aAreaAnt)
if !empty(cArea)
	DbSelectArea(cArea)
endif 
return(cRet)



//FunÁ„o que verifica o tipo do pedido esta de acordo com o tipo de bordero de pedidos

User Function BrVerPed(_cPed,_cBordero)

Local aArea := U_PegaArea({"SC5"})
Local lRet := .f. ,cAuxPed

cAuxPed := iif(len(alltrim(_cPed)) == 8,substr(_cPed,3,6),_cPed)
DbSelectArea("SC5")
DbSetOrder(1)
DbSeek(xFilial("SC5")+cAuxPed)
If Found() .and. (ALLTRIM(SC5->C5_FILIAL) == ALLTRIM(xFilial("SC5"))) .AND. (SC5->C5_NUM = cAuxPed)
	 DbSelectArea("SZF")
     DbSetOrder(1)
     DbSeek(xFilial("SZF")+_cBordero, .t.)
     If Found()
     	 If SZF->ZF_TIPOBOR $ '2'  //DEP”SITO
			If !Alltrim(SC5->C5_TRANSP) $ '00700.099999.00573'
		    	//MsgStop("Pedido n„o pode ser incluido neste bordero, verifique o tipo do bordero e o transporte do pedido!!")
    	     	lRet := .t.
	      	Endif
    	 Endif
    	 If ALLTRIM(SZF->ZF_TIPOBOR) $ '3-8' // REGIAO-RETIRA OU CARGA-MATRIZ (CLEBER 06-11-18 -> CHAMADO 011842, Mirinho pediu pra tipo 8 ser igual tipo 3)
			If Alltrim(SC5->C5_TRANSP) $ '00700.099999.00573' 
		    	//MsgStop("Pedido n„o pode ser incluido neste bordero, verifique o tipo do bordero e o transporte do pedido!!")
    	     	lRet := .t.
	      	Endif
    	 Endif
     Endif
Endif 

U_VoltaArea(aArea)
Return(lRet)     

//FunÁ„o para trazer a alÌquota interna de ICMS do estado passado como par‚metro
User Function Aliqinterna(cUF)
Local nRet,cEstIcm,nPosAliq,nPosFim,cAliq,cDig

cEstIcm := RTRIM(GETMV("MV_ESTICM"))
nPosAliq := At(cUf, cEstIcm)+2
nPosFim := nPosAliq-1
cAliq := ""
do while nPosAliq > 2       
	nPosFim++
	if nPosFim > len(cEstIcm)
		exit
	endif          
	cDig := substr(cEstIcm,nPosFim,1)
	if isalpha(cDig)
		exit
	endif 
	cAliq += cDig
enddo 
nRet := val(cAliq)/100

return(nRet)

User Function ProxDiaUtil(dInicio,nQtdDias)
Local i,dProxDia 
dProxDia := dInicio
for i := 1 to nQtdDias
	dProxDia++     
	do while (Dow(dProxDia) == 1) .Or. (Dow(dProxDia) == 7) .OR. U_EhFeriado(dProxDia)
		dProxDia++
	enddo   
next 
return(dProxDia)

User Function EhFeriado(_dDia)
Local cArea    := alias()
Local aAreaAnt := U_PegaArea({"SP3"})
Local lSim := .f.
Local cDia
cDia := substr(dtos(_dDia),5,4)

//Verificar se cai em algum feriado fixo
dbselectarea("SP3")
dbsetorder(2) //P3_FILIAL+P3_MESDIA+P3_FIXO                                                                                                                                     
dbseek(xFilial("SP3")+cDia+"S")
if found()
	lSim := .t.
endif 

U_VoltaArea(aAreaAnt)
if !empty(cArea)
	DbSelectArea(cArea)
endif 
return(lSim)     
                               
//Determinar a validade do produto ‡ partir do lote e produto
User Function ValidProd(_cLote,_cProd)
Local cArea    := alias()
Local aAreaAnt := U_PegaArea({"SB1","SZZ","SZ1","SC2"})
Local dValid,nValid
dValid := ctod(space(8))     
nValid := 0
dbselectarea("SB1")
dbsetorder(1)
dbseek(xFilial("SB1")+_cProd)
if found()
	if SB1->B1_PRVALID > 0
		nValid := SB1->B1_PRVALID
	else 
		if len(alltrim(_cProd)) == 12
			dbselectarea("SZ1")
			dbseek(xFilial("SZ1")+substr(_cProd,4,2))
			if found()
				nValid := SZ1->Z1_VALIDAD
			endif
		endif 
	endif 
	dbselectarea("SZZ")
	dbsetorder(1)
	dbseek(xFilial("SZZ")+_cLote+_cProd)
	if found()
		dValid := SZZ->ZZ_PREVF + (nValid*30)
	else
		dbselectarea("SC2")     
		DbOrderNickName("SC2001")     
		dbseek(xFilial("SC2")+_cLote)
		if found()
			dValid := SC2->C2_DATPRF + (nValid*30)
		endif 
	endif 
endif 

U_VoltaArea(aAreaAnt)
if !empty(cArea)
	DbSelectArea(cArea)
endif 

return(dValid)      


//Retornar a validade do produto em Meses de acordo com o cadastro do produto ou linha
User Function ValMesesPro(_cProd)

Local cArea    := alias()
Local aAreaAnt := U_PegaArea({"SB1","SZ1"})
Local nValid   := 0

DbSelectArea("SB1")
DbSetOrder(1)
Dbseek(xFilial("SB1")+_cProd)
If Found()
	If SB1->B1_PRVALID > 0
		nValid := SB1->B1_PRVALID
	Else 
		If Len(Alltrim(_cProd)) == 12
			DbSelectArea("SZ1")
			DbSeek(xFilial("SZ1")+Substr(_cProd,4,2))
			If Found()
				nValid := SZ1->Z1_VALIDAD
			Endif
		Endif 
	Endif 
Endif

U_VoltaArea(aAreaAnt)

If !empty(cArea)
	DbSelectArea(cArea)
Endif     

Return(nValid)  


/*
| BloqProg     | 24/03/17 | Cleber   | Cria uma tabela exclusiva com nome do usuario   | 
|              |          |          | para fins de bloqueio de uso de funÁ„o          | 
|              |          |          | Retorna matriz de 1 linha e 4 colunas sendo     | 
|              |          |          | 1a. Linha -> Registro j· est· bloqueado?        | 
|              |          |          | 2a. Linha -> Usu·rio que est· com utilizando(Blq| 
|              |          |          | 3a. Linha -> Nro R_E_C_N_O_ Bloqueado           | 
|              |          |          | 4a. Linha -> Alias da tabela ZZI010 aberta      |  
+--------------+----------+----------+-------------------------------------------------+
*/
//ATEN«√O!! Verificar TODAS as chamadas a essa funÁ„o! N„o mais ser· passado arquivo em cArqBloq mas sim uma ID exclusiva para bloqueio 
User Function BloqProg(cArqBloq)   
Local cArea   := alias()
Local lJabloq, _cUser, aRet,cRDD,cTable,cQuery,nReg,cQry
Local _cAliasF := U_NovoCursor()



cRDD := "TOPCONN"
cTable := "ZZI010"  //Tabela contendo as funÁıes ou programas a serem bloqueados

aRet    := {}
lJabloq := .f.      
lTentouBloq := .f.
_cUser  := ""
nReg := 0


do while nReg == 0
	If SELECT("TMPZZI") > 0
		TMPZZI->(DbcloseArea())
	Endif
	cQuery := "SELECT R_E_C_N_O_ AS REG FROM "+cTable+" WHERE (D_E_L_E_T_ <> '*') AND (ZZI_GRPEMP = '"+substr(cNumEmp,1,2)+"') AND (ZZI_CHAVE = '"+upper(ALLTRIM(cArqBloq))+"')"
	dbUseArea(.T., cRDD, TcGenQry(,, cQuery), "TMPZZI", .T., .T.)
	dbselectarea("TMPZZI")
	nReg := iif(!eof() .and. !bof(),TMPZZI->REG,0)

	if nReg == 0
		//Incluir registro
		cQry := "INSERT INTO "+cTable+" (ZZI_GRPEMP,ZZI_CHAVE,ZZI_USER,ZZI_DTHBLQ,R_E_C_N_O_) SELECT "+;
		"'"+substr(cNumEmp,1,2)+"','"+upper(alltrim(cArqBloq))+"','"+Alltrim(cUserName)+"',CONVERT(varchar, GETDATE(),120),"+;
		"MAX(R_E_C_N_O_)+1 FROM "+cTable
		TCSQLEXEC(cQry)
	else 
		nReg := int(nReg)
	endif
enddo 

If SELECT("TMPZZI") > 0
	TMPZZI->(DbcloseArea())
Endif

// Abre a tabela em modo compartilhado
DBUseArea( .T., cRDD, cTable, (_cAliasF), .T., .F. )
DBGoTo( nReg )
lJabloq := !DBRLock()       // Tenta Bloquear o Registro 

if lJabloq
	_cUser := (_cAliasF)->ZZI_USER 
	dbselectarea(_cAliasF) 
	DBCloseArea()   
else
    _cUser := Alltrim(cUserName)
    If Empty(_cUser)
    	_cUser := "SCHEDULE"
    Endif
	cQuery := "UPDATE "+cTable+" SET ZZI_USER = '"+_cUser+"',ZZI_DTHBLQ = CONVERT(varchar, GETDATE(),120) WHERE R_E_C_N_O_ = "+alltrim(str(nReg))
	TCSQLEXEC(cQuery)
endif	
aAdd( aRet, { lJabloq, _cUser,nReg,_cAliasF } )

If !Empty( cArea )
	DbSelectArea(cArea) 
Endif
Return(aRet)

/*
Cleber (12/2/20)->AdequaÁ„o para release 12.1.25, reescrita da funÁ„o acima
User Function BloqProg(cArqBloq)    
     Local cArea   := alias()
     Local _cAreaBloq, cMens, lJabloq, _cUser, aCampos, cArq, aRet
     Local aCampos := {} 

     aRet    := {}
     lJabloq := .f.      
     _cUser  := ""
     If file(cArqBloq)
        fErase(cArqBloq)
     Endif

     If File( cArqBloq )
        lJabloq    := .t.
        _cAreaBloq := U_NovoCursor()
        //Use (cArqBloq) Alias ( _cAreaBloq ) VIA "DBFCDXADS" New  //LGS-20191202 - AdequaÁ„o para release 12.1.25
        Use (cArqBloq) Alias ( _cAreaBloq ) VIA "CTREECDX" New
        DbSelectArea( _cAreaBloq )
        Dbgotop()
        If !eof() .and. !bof()  
           _cUser := (_cAreaBloq)->USUARIO     
        Else
           _cUser := "USUARIO NAO IDENTIFICADO"
        Endif
        DbCloseArea()
        aAdd( aRet, { lJabloq, _cUser } )
     Else
        aCampos := { {"USUARIO"    ,"C",20,0} }
        _cAreaBloq := U_NovoCursor()
        //DbCreate(cArqBloq, aCampos, "DBFCDXADS")               //LGS-20191202 - AdequaÁ„o para release 12.1.25
        //Use (cArqBloq) Alias (_cAreaBloq) VIA "DBFCDXADS" New  //LGS-20191202 - AdequaÁ„o para release 12.1.25
        DbCreate(cArqBloq, aCampos, "CTREECDX")
        Use (cArqBloq) Alias (_cAreaBloq) VIA "CTREECDX" New
        DbSelectArea(_cAreaBloq)
        Reclock(_cAreaBloq,.t.)
           _cUser := Alltrim(cUserName)
           If Empty(_cUser)
              _cUser := "SCHEDULE"
           Endif
           (_cAreaBloq)->USUARIO := _cUser
        MsUnlock()      
        aAdd( aRet, { lJabloq, _cAreaBloq } )
     Endif
     If !Empty( cArea )
        DbSelectArea(cArea) 
     Endif
Return(aRet)

*/
// DiasUteis     | 19/04/17 | Cleber   | Qtde de dias ˙teis entre duas datas   | 

User Function DiasUteis(dDtIni, dDtFin)
††††Local aArea††† := GetArea()
††††Local nDias††† := 0
††††Local dDtAtu†† := sToD("")
††††Default dDtIni := dDataBase
††††Default dDtFin := dDataBase
†††††
††††//Enquanto a data atual for menor ou igual a data final
††††dDtAtu := dDtIni
††††While dDtAtu <= dDtFin
††††††††//Se a data atual for uma data V·lida
††††††††If dDtAtu == DataValida(dDtAtu) 
††††††††††††nDias++
††††††††EndIf
†††††††††
††††††††dDtAtu := DaySum(dDtAtu, 1)
††††EndDo
†††††
††††RestArea(aArea)
Return nDias

/*/
AF010Conv  ?Autor ?Claudinei M. Benzi    ?Data ?22.01.92
// funÁ„o descontinuada na virada para vers„o 12 e utilizada no sx3 do campo n3_vorig1
*/
User Function Af010Conv( )
Local nValor:=&(ReadVar())
Local cMoedaAtf := GetMV("MV_ATFMOEDA")
// Data de conversao das moedas para reavaliacao sera a data base.
Local dDtConv := If( aCols[n][Ascan(aHeader, {|e| Alltrim(e[2]) = "N3_TIPO"})]="02", dDataBase, M->N1_AQUISIC)
Local nPosVOrigAtf := Ascan(aHeader	, {|e| Alltrim(e[2]) = "N3_VORIG"+cMoedaAtf} )
Local nPosVOrig2 := Ascan(aHeader	, {|e| Alltrim(e[2]) = "N3_VORIG2"} )
Local nPosVOrig3 := Ascan(aHeader	, {|e| Alltrim(e[2]) = "N3_VORIG3"} )
Local nPosVOrig4 := Ascan(aHeader	, {|e| Alltrim(e[2]) = "N3_VORIG4"} )
Local nPosVOrig5 := Ascan(aHeader	, {|e| Alltrim(e[2]) = "N3_VORIG5"} )

If Type("dDataAqui") = "U"
	If nPosVOrig2 > 0
		aCols[n][nPosVOrig2] := nValor / RecMoeda(dDtConv,2)
	Endif	
	If nPosVOrig3 > 0
		aCols[n][nPosVOrig3] := nValor / RecMoeda(dDtConv,3)
	Endif	
	If nPosVOrig4 > 0
		aCols[n][nPosVOrig4] := nValor / RecMoeda(dDtConv,4)
	Endif
	If nPosVOrig5 > 0
		aCols[n][nPosVOrig5] := nValor / RecMoeda(dDtConv,5)
	Endif
	If nPosVOrigAtf > 0
		aCols[n][nPosVOrigAtf] := Iif(ExistBlock("A30EMBRA"),nValor/ExecBlock("A30EMBRA",.F.,.F.),nValor / RecMoeda(dDtConv,Val(cMoedaAtf)))
	Endif
Endif

Return .T.

/*/{Protheus.doc} zPutSX1
FunÁ„o para criar Grupo de Perguntas
@author Atilio
@since 09/06/2017
@version 1.0
@type function
    @param cGrupo,    characters, Grupo de Perguntas       (ex.: X_TESTE)
    @param cOrdem,    characters, Ordem da Pergunta        (ex.: 01, 02, 03, ...)
    @param cTexto,    characters, Texto da Pergunta        (ex.: Produto De, Produto AtÈ, Data De, ...)
    @param cMVPar,    characters, MV_PAR?? da Pergunta     (ex.: MV_PAR01, MV_PAR02, MV_PAR03, ...)
    @param cVariavel, characters, Vari·vel da Pergunta     (ex.: MV_CH0, MV_CH1, MV_CH2, ...)
    @param cTipoCamp, characters, Tipo do Campo            (C = Caracter, N = NumÈrico, D = Data)
    @param nTamanho,  numeric,    Tamanho da Pergunta      (M·ximo de 60)
    @param nDecimal,  numeric,    Tamanho de Decimais      (M·ximo de 9)
    @param cTipoPar,  characters, Tipo do Par‚metro        (G = Get, C = Combo, F = Escolha de Arquivos, K = Check Box)
    @param cValid,    characters, ValidaÁ„o da Pergunta    (ex.: Positivo(), u_SuaFuncao(), ...)
    @param cF3,       characters, Consulta F3 da Pergunta  (ex.: SB1, SA1, ...)
    @param cPicture,  characters, M·scara do Par‚metro     (ex.: @!, @E 999.99, ...)
    @param cDef01,    characters, Primeira opÁ„o do combo
    @param cDef02,    characters, Segunda opÁ„o do combo
    @param cDef03,    characters, Terceira opÁ„o do combo
    @param cDef04,    characters, Quarta opÁ„o do combo
    @param cDef05,    characters, Quinta opÁ„o do combo
    @param cHelp,     characters, Texto de Help do par‚metro
    @obs FunÁ„o foi criada, pois a partir de algumas versıes do Protheus 12, a funÁ„o padr„o PutSX1 n„o funciona (por medidas de seguranÁa)
    @example Abaixo um exemplo de como criar um grupo de perguntas
     
    cPerg    := "X_TST"
     
    cValid   := ""
    cF3      := ""
    cPicture := ""
    cDef01   := ""
    cDef02   := ""
    cDef03   := ""
    cDef04   := ""
    cDef05   := ""
     
    u_zPutSX1(cPerg, "01", "Produto De?",       "MV_PAR01", "MV_CH0", "C", TamSX3('B1_COD')[01], 0, "G", cValid,       "SB1", cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o produto inicial")
    u_zPutSX1(cPerg, "02", "Produto AtÈ?",      "MV_PAR02", "MV_CH1", "C", TamSX3('B1_COD')[01], 0, "G", cValid,       "SB1", cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o produto final")
    u_zPutSX1(cPerg, "03", "A partir da Data?", "MV_PAR03", "MV_CH2", "D", 08,                   0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a data inicial a ser considerada")
    u_zPutSX1(cPerg, "04", "MÈdia maior que?",  "MV_PAR04", "MV_CH3", "N", 09,                   2, "G", "Positivo()", cF3,   "@E 999,999.99", cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a mÈdia de atraso que ser· considerada")
    u_zPutSX1(cPerg, "05", "Tipo de Saldos?",   "MV_PAR05", "MV_CH4", "N", 01,                   0, "C", cValid,       cF3,   cPicture,        "Todos", "Maior que 0", "Menor que 0", "Zerados", cDef05, "Informe o tipo de saldo a ser considerado")
    u_zPutSX1(cPerg, "06", "Tipos de Produto?", "MV_PAR06", "MV_CH5", "C", 60,                   0, "K", cValid,       cF3,   cPicture,        "PA",    "PI",          "MP",          cDef04,    cDef05, "Informe os tipos de produto que ser„o considerados")
    u_zPutSX1(cPerg, "07", "Caminho de Log?",   "MV_PAR07", "MV_CH6", "C", 60,                   0, "F", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o caminho para geraÁ„o do log")
/*/
 
//Cleber (17/02/20)->Readequar apÛs subir dicion·rios para o BD
/* 
User Function zPutSX1(cGrupo, cOrdem, cTexto, cMVPar, cVariavel, cTipoCamp, nTamanho, nDecimal, cTipoPar, cValid, cF3, cPicture, cDef01, cDef02, cDef03, cDef04, cDef05, cHelp)
    Local aArea       := GetArea()
    Local cChaveHelp  := ""
    Local nPreSel     := 0
    Default cGrupo    := Space(10)
    Default cOrdem    := Space(02)
    Default cTexto    := Space(30)
    Default cMVPar    := Space(15)
    Default cVariavel := Space(6)
    Default cTipoCamp := Space(1)
    Default nTamanho  := 0
    Default nDecimal  := 0
    Default cTipoPar  := "G"
    Default cValid    := Space(60)
    Default cF3       := Space(6)
    Default cPicture  := Space(40)
    Default cDef01    := Space(15)
    Default cDef02    := Space(15)
    Default cDef03    := Space(15)
    Default cDef04    := Space(15)
    Default cDef05    := Space(15)
    Default cHelp     := ""
     
    //Se tiver Grupo, Ordem, Texto, Par‚metro, Vari·vel, Tipo e Tamanho, continua para a criaÁ„o do par‚metro
    If !Empty(cGrupo) .And. !Empty(cOrdem) .And. !Empty(cTexto) .And. !Empty(cMVPar) .And. !Empty(cVariavel) .And. !Empty(cTipoCamp) .And. nTamanho != 0
         
        //DefiniÁ„o de vari·veis
        cGrupo     := PadR(cGrupo, Len(SX1->X1_GRUPO), " ")           //Adiciona espaÁos a direita para utilizaÁ„o no DbSeek
        cChaveHelp := "P." + AllTrim(cGrupo) + AllTrim(cOrdem) + "."  //Define o nome da pergunta
        cMVPar     := Upper(cMVPar)                                   //Deixa o MV_PAR tudo em mai˙sculo
        nPreSel    := Iif(cTipoPar == "C", 1, 0)                      //Se for Combo, o prÈ-selecionado ser· o Primeiro
        cDef01     := Iif(cTipoPar == "F", "56", cDef01)              //Se for File, muda a definiÁ„o para ser tanto Servidor quanto Local
        nTamanho   := Iif(nTamanho > 60, 60, nTamanho)                //Se o tamanho for maior que 60, volta para 60 - LimitaÁ„o do Protheus
        nDecimal   := Iif(nDecimal > 9,  9,  nDecimal)                //Se o decimal for maior que 9, volta para 9
        nDecimal   := Iif(cTipoPar == "N", nDecimal, 0)               //Se n„o for par‚metro do tipo numÈrico, ser· 0 o Decimal
        cTipoCamp  := Upper(cTipoCamp)                                //Deixa o tipo do Campo em mai˙sculo
        cTipoCamp  := Iif(! cTipoCamp $ 'C;D;N;', 'C', cTipoCamp)     //Se o tipo do Campo n„o estiver entre Caracter / Data / NumÈrico, ser· Caracter
        cTipoPar   := Upper(cTipoPar)                                 //Deixa o tipo do Par‚metro em mai˙sculo
        cTipoPar   := Iif(Empty(cTipoPar), 'G', cTipoPar)             //Se o tipo do Par‚metro estiver em branco, ser· um Get
        nTamanho   := Iif(cTipoPar == "C", 1, nTamanho)               //Se for Combo, o tamanho ser· 1
     
        DbSelectArea('SX1')
        SX1->(DbSetOrder(1)) // Grupo + Ordem
     
        //Se n„o conseguir posicionar, a pergunta ser· criada
        If ! SX1->(DbSeek(cGrupo + cOrdem))
            RecLock('SX1', .T.)
                X1_GRUPO   := cGrupo
                X1_ORDEM   := cOrdem
                X1_PERGUNT := cTexto
                X1_PERSPA  := cTexto
                X1_PERENG  := cTexto
                X1_VAR01   := cMVPar
                X1_VARIAVL := cVariavel
                X1_TIPO    := cTipoCamp
                X1_TAMANHO := nTamanho
                X1_DECIMAL := nDecimal
                X1_GSC     := cTipoPar
                X1_VALID   := cValid
                X1_F3      := cF3
                X1_PICTURE := cPicture
                X1_DEF01   := cDef01
                X1_DEFSPA1 := cDef01
                X1_DEFENG1 := cDef01
                X1_DEF02   := cDef02
                X1_DEFSPA2 := cDef02
                X1_DEFENG2 := cDef02
                X1_DEF03   := cDef03
                X1_DEFSPA3 := cDef03
                X1_DEFENG3 := cDef03
                X1_DEF04   := cDef04
                X1_DEFSPA4 := cDef04
                X1_DEFENG4 := cDef04
                X1_DEF05   := cDef05
                X1_DEFSPA5 := cDef05
                X1_DEFENG5 := cDef05
                X1_PRESEL  := nPreSel
                 
                //Se tiver Help da Pergunta
                If !Empty(cHelp)
                    X1_HELP    := ""
                     
                    fPutHelp(cChaveHelp, cHelp)
                EndIf
            SX1->(MsUnlock())
        EndIf
    EndIf
     
    RestArea(aArea)
Return
*/ 
/*---------------------------------------------------*
 | FunÁ„o: fPutHelp                                  |
 | Desc:   FunÁ„o que insere o Help do Parametro     |
 *---------------------------------------------------*/
 Static Function fPutHelp(cKey, cHelp, lUpdate)
    Local cFilePor  := "SIGAHLP.HLP"
    Local cFileEng  := "SIGAHLE.HLE"
    Local cFileSpa  := "SIGAHLS.HLS"
    Local nRet      := 0
    Default cKey    := ""
    Default cHelp   := ""
    Default lUpdate := .F.
     
    //Se a Chave ou o Help estiverem em branco
    If Empty(cKey) .Or. Empty(cHelp)
        Return
    EndIf
     
    //**************************** PortuguÍs
    nRet := SPF_SEEK(cFilePor, cKey, 1)
     
    //Se n„o encontrar, ser· inclus„o
    If nRet < 0
        SPF_INSERT(cFilePor, cKey, , , cHelp)
     
    //Sen„o, ser· atualizaÁ„o
    Else
        If lUpdate
            SPF_UPDATE(cFilePor, nRet, cKey, , , cHelp)
        EndIf
    EndIf
     
     
     
    //**************************** InglÍs
    nRet := SPF_SEEK(cFileEng, cKey, 1)
     
    //Se n„o encontrar, ser· inclus„o
    If nRet < 0
        SPF_INSERT(cFileEng, cKey, , , cHelp)
     
    //Sen„o, ser· atualizaÁ„o
    Else
        If lUpdate
            SPF_UPDATE(cFileEng, nRet, cKey, , , cHelp)
        EndIf
    EndIf
     
     
     
    //**************************** Espanhol
    nRet := SPF_SEEK(cFileSpa, cKey, 1)
     
    //Se n„o encontrar, ser· inclus„o
    If nRet < 0
        SPF_INSERT(cFileSpa, cKey, , , cHelp)
     
    //Sen„o, ser· atualizaÁ„o
    Else
        If lUpdate
            SPF_UPDATE(cFileSpa, nRet, cKey, , , cHelp)
        EndIf
    EndIf
Return

/*
FunÁ„o: ObsProd 
DescriÁ„o: Utilizada para gravar B1_OBS utilizada para gravar observaÁıes utilizadas no 
MASTERSALES. Utilizada nos Pontos de Entrada na Inclus„o e AlteraÁ„o do Produto.
Data : 27/12/18
Autor: Cleber 
*/
User Function ObsProd()
Local cObs,cRelVol,cTmp,cQuery,nPreco,cNcm

//Considera-se que j· esteja posicionado no produto!!!

dbselectarea("SYD")
dbsetorder(1)
dbselectarea("SB5")
dbsetorder(1)

cObs := ""
IF !empty(ALLTRIM(SB1->B1_CATALIS))
	cObs := "Cat.:"+ALLTRIM(SUBSTR(SB1->B1_CATALIS,1,10))
	IF !EMPTY(ALLTRIM(SB1->B1_RELCAT1))
		cObs += "("+ALLTRIM(SB1->B1_RELCAT1)+")"
	ENDIF
ENDIF

cRelVol := "0"
cTmp := U_NovoCursor()

cQuery := "SELECT dbo.DetVol('"+SB1->B1_FILIAL+"','"+ALLTRIM(SB1->B1_COD)+"') AS RELVOL"
TCQuery cQuery ALIAS (cTmp) NEW
dbselectarea(cTmp)
dbgotop()
IF !eof()
	cRelVol := (cTmp)->RELVOL
ENDIF
cObs += "|Rel.Vol.: "+alltrim(cRelVol)
dbselectarea(cTmp)
dbclosearea()
		
dbselectarea("SYD")
dbseek(xFilial("SYD")+SB1->B1_POSIPI+SB1->B1_EX_NCM)
if found() .AND. (SYD->YD_TEM_ST == "1")
	cObs +=  "|TEM ST "
endif 

cNcm := ALLTRIM(SB1->B1_POSIPI)
if !empty(cNcm)
	cObs += "|NCM:"+cNcm
	cObs += "|IPI:"+ALLTRIM(transform(SB1->B1_IPI,"99.9"))+"%"
endif
		
nPreco := SB1->B1_PRV1
IF !(SB1->B1_ESTOQUE = "S")
	dbselectarea("SB5")
	dbseek(xFilial("SB5")+SB1->B1_COD)
	if found()
		if SB5->B5_PRV2 > 0.0
			nPreco := SB5->B5_PRV2
		endif 
	endif
ENDIF
/*
//Cleber(21/10/20) ->Retirando preÁo da Obs 
if nPreco > 0.0
	cObs += "|Prc TAB:"+alltrim(transform(nPreco,"@E 999,999.99"))
endif
*/
Return(cObs)

User Function DetCposTab( _cAlias,_cCposExcl )
Local aArea := GetArea()
Local aCampos := {}
Local cAux,xValor,lAbriu,_cCampo
Local cSx3
lAbriu := .f.

cSx3 := U_NovoCursor()
// ABERTURA DO DICION¡RIO SX3
OpenSXs(NIL, NIL, NIL, NIL, NIL, cSx3, "SX3", NIL, .F.)
lAbriu := Select(cSx3) > 0

if (lAbriu)
	DbSelectArea(cSx3)
	(cSx3)->( DbSetOrder(1) )
else
	Messagebox("ImpossÌvel Abrir tabela SX3!","Erro!",48) 	
	return(aCampos)
EndIf



dbSelectArea(cSx3)
dbSeek( _cAlias )
While !EOF() .And. (cSx3)->(X3_ARQUIVO) = _cAlias
	If X3Uso((cSx3)->(X3_USADO)) .AND. !((cSx3)->(X3_CONTEXT) = "V") .and. !(ALLTRIM((cSx3)->(X3_CAMPO)) $ _cCposExcl)
		_cCampo := (cSx3)->(X3_CAMPO)
		IF (_cAlias)->(FieldPos( _cCampo )) > 0
			cAux := alltrim(_cAlias)+"->"+(cSx3)->(X3_CAMPO)
			xValor := &cAux
			if !empty(xValor)
				aadd(aCampos,{(cSx3)->(X3_CAMPO)   ,xValor,.F.})		
			endif 
		ENDIF
	Endif
	dbSelectArea(cSx3)
	dbSkip()
End
DbSelectArea(cSx3)
DbCloseArea()

RestArea(aArea)
Return(aCampos)

User Function NossoNro( _cBco,_Nro )
Local aArea := GetArea()
local _cRet,cBcox,nTam,cAux,cDig
_cRet := alltrim(_Nro)
cBcox := alltrim(_cBco)
do case
case cBcox == "341"
	_cRet := IF(EMPTY(_Nro),'00000000',right(ALLTRIM(_Nro),8))
case cBcox == "237"
	if EMPTY(_Nro)
		_cRet := '000000000000'
	else
		nTam := len(_Nro) 
		do case
		case nTam == 12
			_cRet := _Nro
		case nTam < 12
			cAux := padl(alltrim(_cNro),11,"0")
			cDig := U_DigNNBrad(SEE->EE_CODCART,cAux)
			_cRet := cAux+cDig
		case nTam > 12 // NumeraÁ„o gerada pelo programa da B2FINANCE
			_cRet := right(ALLTRIM(_Nro),11)
			cDig := U_DigNNBrad(SEE->EE_CODCART,_cRet)
			_cRet += cDig
		endcase 
	endif 
case cBcox == "001"
	if EMPTY(_Nro)
		_cRet := '00000000000000000'
	else
		_cRet := PADL(ALLTRIM(SEE->EE_CODEMP),7,"0")+right(alltrim(_Nro),10)
	endif 
endcase
RestArea(aArea)
Return(_cRet)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ Modulo11 ≥ Autor ≥ Cleber                ≥ Data ≥ 27/07/19 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Calculo do DÌgito verificador do Nosso Nro Boleto Bradesco ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Boletos Bradesco                                           ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function DigNNBrad(cCart,cNN)
local cRef,i,nSoma,nFat,D,nAux
/*
cCart -> Carteira
cNN -> Nosso N˙mero
*/
nSoma := 0
cRef := alltrim(cCart)+alltrim(cNN)
nFat := 2
for i := 1 to len(cRef)
	nSoma += val(substr(cRef,i,1))*nFat
	nFat := nFat - 1
	if nFat < 2
		nFat := 7
	endif
next 
nAux := mod(nSoma,11)
do case 
case nAux == 1
	D := "P"
case nAux == 0
	D := "0"
otherwise
	D := alltrim(str(11 - nAux))
endcase 

Return(D)


  
/*/{Protheus.doc} zBxXML
Faz download do arquivo XML do site da sefaz usando a Chave da nota
@author S˙livan Simıes Silva - Email: sulivansimoes@gmail.com
@since  08/03/2019
@version 1.1
@param cChaveNFe, caracter, chave da NFe ‡ ser baixada da Sefaz 
@example zBxXML
@type function
@see Abaixo os links usados como referÍncia para montagem da funÁ„o
        Link 01 - http://tdn.totvs.com/display/tec/Classe+TWsdlManager
        Link 02 - http://tdn.totvs.com/display/tec/SOAP+1.1+e+SOAP+1.2
        Link 03 - http://tdn.totvs.com/display/tec/XmlParser                
        Link 04 - http://www.nfe.fazenda.gov.br/portal/exibirArquivo.aspx?conteudo=iGDFY8YBs28=
    D˙vidas quanto a Parse:
        Link 01 - https://centraldeatendimento.totvs.com/hc/pt-br/articles/360022658731-MP-ADVPL-Peer-certificate-cannot-be-authenticated-with-given-CA-certificates
        Link 02 - http://tdn.totvs.com/display/tec/Acesso+a+Web+Services+que+exigem+certificados+de+CA
        Link 03 - http://tdn.totvs.com/pages/viewpage.action?pageId=223932805
        Link 04 - http://tdn.totvs.com/display/tec/TWsdlManager%3AlSSLInsecure
@obs DocumentaÁ„o feita e adaptaÁıes por Daniel Atilio
    Os par‚metros que devem ser criados na base s„o:
        MV_X_BXUF  - CÛdigo do Estado conforme IBGE ( https://www.oobj.com.br/bc/article/quais-os-c%C3%B3digos-de-cada-uf-no-brasil-465.html )
        MV_X_BXAMB - Indica o tipo de Ambiente, 1 = ProduÁ„o, 2 = HomologaÁ„o
        MV_X_BXCA  - DiretÛrio do certificado "ca", por exemplo: \certs\000001_ca.pem
        MV_X_BXCER - DiretÛrio do certificado "cert", por exemplo: \certs\000001_cert.pem
        MV_X_BXKEY - DiretÛrio do certificado "key", por exemplo: \certs\000001_key.pem
        MV_X_BXPSW - Senha do Certificado
        MV_X_BXPRO - Tipo do Protocolo, 0=Descobre sozinho; 1=TLSv1; 2=SSLv2; 3=SSLv3
        MV_X_BXDIR - DiretÛrio que ser· gerado os arquivos XML
        MV_X_SSLIN - Define se far· a conex„o SSL com o servidor de forma anÙnima, ou seja, sem verificaÁ„o de certificados ou chaves. Default È .T.
@example Basta chamar a funÁ„o passando a chave da nfe
    u_zBxXML("CHAVE_AAAAAAAAAAAAAAAAAAAAAAA")
    u_zBxXML("CHAVE_BBBBBBBBBBBBBBBBBBBBBBB")
    u_zBxXML("CHAVE_CCCCCCCCCCCCCCCCCCCCCCC")
/*/
  
User Function zBxXML(cChaveNFe)
    Local aArea        := GetArea()
    Local lRet      := .T.
    Local cURL        := "https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL"
    Local cMsg      := ""
    Local oWsdl     := Nil
    Local cMsgRet   := ""
    Local cError    := ""
    Local cWarning  := ""
    Local cXmlGZip  := ""
    Local cArqXML   := ""
    Local cUfAutor  := SuperGetMV("MV_X_BXUF",  .F., "35")
    Local cTpAmb    := SuperGetMV("MV_X_BXAMB", .F., "1")
    Local cCNPJEmp  := alltrim(SM0->M0_CGC) //Alltrim(Alltrim(FWArrFilAtu(FWCodEmp(),FWCodFil())[18]))
    Local lContinua := .T.
    Private oXmlDocZip
  
    //Inst‚ncia a classe, setando as par‚metrizaÁıes necess·rias
    oWsdl := TWsdlManager():New()
    oWsdl:cSSLCACertFile := SuperGetMV("MV_X_BXCA",  .F., "\system\certs\000002_ca.pem")
    oWsdl:cSSLCertFile   := SuperGetMV("MV_X_BXCER", .F., "\system\certs\000002_cert.pem")
    oWsdl:cSSLKeyFile    := SuperGetMV("MV_X_BXKEY", .F., "\system\certs\000002_key.pem")
    oWsdl:cSSLKeyPwd     := SuperGetMV("MV_X_BXPSW", .F., "senha")
    oWsdl:nSSLVersion    := SuperGetMV("MV_X_BXPRO", .F., "0")
    oWsdl:lSSLInsecure   := SuperGetMV("MV_X_SSLIN", .F., .T.)
    oWsdl:nTimeout       := 120
  
    //Tenta fazer o Parse da URL
    lRet := oWsdl:ParseURL(cURL)
    If ! lRet 
        FwLogMSG( "WARN", , 'REST', funname(), '', '01', "[u_zBxXML] - Erro ParseURL: " + oWsdl:cError, 0 )
        lContinua := .F.
    EndIf
      
    //Se for continuar o processamento
    If lContinua
      
        //Tenta definir a operaÁ„o
        lRet := oWsdl:SetOperation("nfeDistDFeInteresse")
        If ! lRet 
            FwLogMSG( "WARN", , 'REST', funname(), '', '01', "[u_zBxXML] - Erro SetOperation: " + oWsdl:cError, 0 )
            lContinua := .F.
        EndIf
    EndIf
      
    //Se for continuar
    If lContinua
        //Monta a mensagem que ser· enviada
        cMsg := '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                        + CRLF
        cMsg += '    <soapenv:Header/>'                                                                              + CRLF
        cMsg += '    <soapenv:Body>'                                                                                + CRLF
        cMsg += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'  + CRLF
        cMsg += '                <nfeDadosMsg>'                                                                      + CRLF
        cMsg += '                    <distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.01">'          + CRLF
        cMsg += '                        <tpAmb>'+cTpAmb+'</tpAmb>'                                                  + CRLF
        cMsg += '                     <cUFAutor>'+cUfAutor+'</cUFAutor>'                                              + CRLF
        cMsg += '                        <CNPJ>'+cCNPJEmp+'</CNPJ>'                                                  + CRLF
        cMsg += '                      <consChNFe>'                                                                    + CRLF
        cMsg += '                           <chNFe>'+alltrim(cChaveNFe)+'</chNFe>'                                  + CRLF
        cMsg += '                      </consChNFe>'                                                                   + CRLF
        cMsg += '                    </distDFeInt>'                                                                  + CRLF
        cMsg += '                </nfeDadosMsg>'                                                                     + CRLF
        cMsg += '            </nfeDistDFeInteresse>'                                                                 + CRLF
        cMsg += '        </soapenv:Body>'                                                                            + CRLF
        cMsg += '    </soapenv:Envelope>'                                                                            + CRLF
          
        //Envia uma mensagem SOAP personalizada ao servidor
        lRet := oWsdl:SendSoapMsg(cMsg)
        If ! lRet 
            FwLogMSG( "WARN", , 'REST', funname(), '', '01', "[u_zBxXML] - Erro SendSoapMsg: " + oWsdl:cError, 0 )
            FwLogMSG( "WARN", , 'REST', funname(), '', '01', "[u_zBxXML] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode, 0 )
            lContinua := .F.
        EndIf
    EndIf
  
    //Se for continuar
    If lContinua
        //Pega a resposta do SOAP
        cMsgRet := oWsdl:GetSoapResponse()
                             
        //Transforma a resposta em um objeto
        oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)
          
        //Se existir Warning, mostra no console.log
        If ! Empty(cWarning)
            FwLogMSG( "WARN", , 'REST', funname(), '', '01', "[u_zBxXML] - Alerta cWarning: " + cWarning, 0 )
        EndIf
          
        //Se houve erro, n„o permitir· prosseguir
        If ! Empty(cError)
            FwLogMSG( "WARN", , 'REST', funname(), '', '01',"[u_zBxXML] - Erro cError: " + cError, 0 )
            lContinua := .F.
        EndIf
    EndIf
  
    //Se for continuar
    If lContinua
        //Se a tag DocZip existir (for diferente de Undefinied)
        If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") != "U")
  
            //Pega tag que contÈm XML em zip
            cXmlGZip := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT
              
            //Gera arquivo XML
            cArqXML := fGeraXML(cXmlGZip, cChaveNFe)
        else
            FwLogMSG( "WARN", , 'REST', funname(), '', '01',"[u_zBxXML] - Ocorreu algum problema no momento de baixar o arquivo da sefaz!", 0 )
        endif
    EndIf
  
    RestArea(aArea)
Return cArqXML
  
/*-------------------------------------------------------------------------------*
 | Func:  fGeraXML                                                               |
 | Desc:  FunÁ„o para gerar o arquivo XML em uma pasta                           |
 *-------------------------------------------------------------------------------*/
  
Static Function fGeraXML(cConteudo, cChave)
    Local aArea        := getArea()
    Local lRet         := .T. 
    Local cArquivo     := cChave + ".xml"
    Local cDiretorio := Alltrim(SuperGetMV("MV_X_BXDIR", .F., "C:\TOTVS\XML\"))
    Local nTamanho     := 0
    Local cUnXML       := ""
    Local cDecode64  := ""
    Local cArqFull   := ""
    Local lHouveErro := .F.
      
    //Se o ˙ltimo caracter do diretÛrio n„o for \, ser· barra \
    If SubStr(cDiretorio, Len(cDiretorio), 1) != "\"
        cDiretorio += "\"
    EndIf
      
    //Define o caminho final do arquivo
    cArqFull := cDiretorio + cArquivo
      
    //Pega o tamanho e descriptografa o conte˙do
    nTamanho  := Len(cConteudo)
    cDecode64 := Decode64(cConteudo)
    lRet      := GzStrDecomp(cDecode64, nTamanho, @cUnXML)
       
    //Se deu certo
    If lRet
          
        //Se o diretÛrio n„o existir, cria
        If ! ExistDir(cDiretorio)
            MakeDir(cDiretorio)
        EndIf
          
        //Cria o arquivo com o conte˙do
        lRet := MemoWrite(cDiretorio+cArquivo, cUnXML)
          
        //Se houve falha, mostra mensagem no console.log
        If ! lRet
            FwLogMSG( "WARN", , 'SIGACOM', funname(), '', '01', "[u_zBxXML][fGeraXML] - N„o foi possivel criar o arquivo: " + cArqFull, 0 )
            lHouveErro := .T.
        EndIf
      
    //Se n„o deu certo, mostra mensagem no console.log
    Else
        FwLogMSG( "WARN", , 'SIGACOM', funname(), '', '01', "[u_zBxXML][fGeraXML] - Houve algum erro na descompactaÁ„o do arquivo!", 0 )
        lHouveErro := .T.
    EndIf
  
    //Se houve erro, zera o nome do arquivo para retornar em branco
    If lHouveErro
        cArqFull := ""
    EndIf
  
    RestArea(aArea)
Return cArqFull

//(29/11/2019 - Cleber) FunÁ„o que verifica se usu·rio pode alterar campos relativos a comiss„o tais como
//E1_VEND1, E1_COMIS1 e E1_BASCOM1 . Dever· ser chamada na cl·usula WHEN do SX3.
User Function AltComis()
Local lRet := .T.

if PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),__CUSERID) <> 0 
	IF ! (__CUSERID $ SuperGetMV("MV_XUSRCOM",.F.,""))
   		lRet := .f.
	ENDIF 
endif 
return(lRet)  

/*/{Protheus.doc} ZGATF01
//Gatilho gerado do campo C6_QTDVEN para C6_XPRUNIT - adequaÁ„o da release 12.1.25.
@author Luis Gustavo
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function ZGATF01()
     Local _nPosPro := aScan( aHeader, { |x| Alltrim( x[ 2 ] ) == "C6_PRODUTO" } )
     Local _nPosSC6 := n
     Local _nPrcVen := 0
     
     If SB1->B1_ESTOQUE == 'S'
        _nPrcVen := SB1->B1_PRV1
     Else
        DbSelectArea("SB5")
        SB5->( DbSetOrder( 1 ) )
        If SB5->( DbSeek( xFilial("SB5") + aCols[ _nPosSC6][ _nPosPro] ) )
           _nPrcVen := SB5->B5_PRV2
        Endif
     Endif
Return _nPrcVen


User Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,; 
     cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,; 
     cF3, cGrpSxg,cPyme,; 
     cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,; 
     cDef02,cDefSpa2,cDefEng2,; 
     cDef03,cDefSpa3,cDefEng3,; 
     cDef04,cDefSpa4,cDefEng4,; 
     cDef05,cDefSpa5,cDefEng5,; 
     aHelpPor,aHelpEng,aHelpSpa,cHelp) 

LOCAL aArea := GetArea() 
Local cKey 
Local nTamX1_GRUPO := 10
Local cQuery,nCont,cTabSx1,cQry,cTcq

cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "." 

cPyme    := Iif( cPyme           == Nil, " ", cPyme          ) 
cF3      := Iif( cF3           == NIl, " ", cF3          ) 
cGrpSxg := Iif( cGrpSxg     == Nil, " ", cGrpSxg     ) 
cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01      ) 
cHelp      := Iif( cHelp          == Nil, "" , cHelp          ) 



// Ajusta o tamanho do grupo. Ajuste emergencial para validaÁ„o dos fontes. 
// RFC - 15/03/2007 
cGrupo := PadR( cGrupo , nTamX1_GRUPO , " " ) 


/*
       cQry1 += "INSERT INTO "+RetSqlName("ZZJ")+" (ZZJ_FILIAL,  ZZJ_CODIGO  ,  ZZJ_DTINI         , ZZJ_HINI                                       ,  R_E_C_N_O_ , ZZJ_FLAG,   ZZJ_USER     , ZZJ_BORDER, ZZJ_LOCALI    ) "
       cQry1 += "                  VALUES('"+xFilial("ZZJ")+"', '"+cCodSeq+"',  '"+DTOS(Date())+"', '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "+nCodReg+" ,  '3'    , '"+__cUserId+"','"+cGet2Env+"','"+cLocali+"' ) "
	   XXX := TCSQLExec(cQry1)		
*/

If SELECT("TMPSX1") > 0
	TMPSX1->(DbcloseArea())
Endif


cTabSx1 := "SX1"+substr(cNumEmp,1,2)+"0"
cQuery := "SELECT X1_GRUPO,X1_ORDEM FROM "+cTabSx1+" SX1 WHERE (D_E_L_E_T_ <> '*') AND (X1_GRUPO = '"+alltrim(cGrupo)+"') AND (X1_ORDEM = '"+alltrim(cOrdem)+"')"
TCQUERY cQuery ALIAS "TMPSX1" NEW
DbSelectArea("TMPSX1")
dbgotop()
nCont := 0
do while !eof()
 	nCont++
 	dbskip()
enddo

cQuery := "UPDATE "+cTabSx1+" SET "
If nCont == 0
 

    cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
     cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
     cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 

     //Reclock( "SX1" , .T. )
     
     cQuery += "X1_GRUPO = '"+cGrupo+"',X1_ORDEM = '"+cOrdem+"',X1_PERGUNT = '"+cPergunt+"',X1_PERSPA = '"+cPerSpa+;
     "',X1_PERENG = '"+cPerEng+"',X1_VARIAVL = '"+cVar+"',X1_TIPO = '"+cTipo+"',X1_TAMANHO = "+alltrim(str(nTamanho))+",X1_DECIMAL = "+alltrim(str(nDecimal))+;
     ",X1_PRESEL = "+alltrim(str(nPresel))+",X1_GSC = '"+cGSC+"',X1_VALID = '"+cValid+"',X1_VAR01 = '"+cVar01+;
     "',X1_F3 = '"+cF3+"',X1_GRPSXG = '"+cGrpSxg+"',"
 
     If cPyme = Nil
      	cPyme := ""
     Endif 
     cQuery += "X1_PYME = '"+cPyme+"',X1_CNT01 = '"+cCnt01+"'" 

     If cGSC == "C"               // Mult Escolha
     	cQuery += ",X1_DEF01 = '"+cDef01+"',X1_DEFSPA1 = '"+cDefSpa1+"',X1_DEFENG1 = '"+cDefEng1+"',"+;
     	"X1_DEF02 = '"+cDef02+"',X1_DEFSPA2 = '"+cDefSpa2+"',X1_DEFENG2 = '"+cDefEng2+"',"+;
     	"X1_DEF03 = '"+cDef03+"',X1_DEFSPA3 = '"+cDefSpa3+"',X1_DEFENG3 = '"+cDefEng3+"',"+;
     	"X1_DEF04 = '"+cDef04+"',X1_DEFSPA4 = '"+cDefSpa4+"',X1_DEFENG4 = '"+cDefEng4+"',"+;
     	"X1_DEF05 = '"+cDef05+"',X1_DEFSPA5 = '"+cDefSpa5+"',X1_DEFENG5 = '"+cDefEng5+"'"
     Endif 
     cQuery += ",X1_HELP = '"+cHelp+"'"
     
     cTcq := u_NovoCursor()
     /*
     If SELECT("TCQ") > 0
     	TCQ->(DbcloseArea())
     Endif
*/
     cQry := "SELECT MAX(R_E_C_N_O_)+1 AS REG FROM "+cTabSx1
     TCQUERY cQry ALIAS (cTcq) NEW
     nRegSx1 := (cTcq)->REG
     (cTcq)->(DbcloseArea())
     
     cQry := "INSERT INTO "+cTabSx1+" (R_E_C_N_O_) VALUES ("+alltrim(str(nRegSx1))+")"
     TCSQLExec(cQry)
     cQuery += " WHERE R_E_C_N_O_ = "+alltrim(str(nRegSx1))    
     TCSQLExec(cQuery)
      
     
     PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa) 

Endif 
TMPSX1->(DbcloseArea())

RestArea( aArea ) 

Return(.t.)

//FunÁ„o que determina se Produto pode ser vendido na quantidade determinada
User Function QtdMinProd(cProd,nQtde)
Local cArea      := Alias()
Local aAreaAnt := U_PegaArea({"SB1"})
local lRet := .T.
Local _cEmpr :=  alltrim(FWGrpCompany())

IF _cEmpr == "01" //TecPolpa est· fora por enquanto
   dbselectarea("SB1")
   dbsetorder(1)
   dbseek(xFilial("SB1")+cProd)
   IF found() .AND. (SB1->B1_ESTOQUE != "S") .AND. (LEN(ALLTRIM(cProd)) == 12)
      DO CASE
      CASE (SUBSTR(cProd,11,2) == "01") .AND. (nQtde < 12)
         lRet := .f.
      CASE (SUBSTR(cProd,11,2) == "02") .and. (SUBSTR(cProd,4,2) $ "41-42-43ñ49-62-92") .AND. (nQtde < 16) // Chamado 018057
         lRet := .f.
      CASE (SUBSTR(cProd,11,2) == "03") .and. (SUBSTR(cProd,4,2) $ "41-42-43ñ49-62-92") .AND. (nQtde < 5) // Chamado 018057
         lRet := .f.
      ENDCASE

   ENDIF 
ENDIF 

U_VoltaArea(aAreaAnt)

if !empty(cArea)
	dbselectarea(cArea)
endif
return(lRet)


/*
Cleber(20/08/20) -> FunÁ„o para determinar identificaÁ„o de tÌtulos nos CNABs 
para as empresas 
//Obs.: FunÁ„o chamada no processamento do arquivo banc·rio, SE1 j· est· posicionado!!!
*/
User Function DetIdCNAB()
Local _cEmpr := alltrim(FWGrpCompany())+alltrim(FWCodFil())
Local _cRet

if (_cEmpr == "01010101") .OR. (_cEmpr == "01010104") .OR. (_cEmpr == "01060101")
   _cRet := SE1->E1_PREFIXO+SUBSTR(SE1->E1_NUM,1,6)+SE1->E1_PARCELA+"01"
else
   _cRet := SE1->E1_IDCNAB //TecPolpa trabalha com E1_IDCNAB. Padronizar pra qualquer outra nova empresa j· trabalhar com o campo padr„o
endif 
return(_cRet)

/*
Cleber(18/12/20) -> FunÁ„o para determinar cod FCI ‡ partir do cÛd 
produto
//Obs.: FunÁ„o chamada no cad pedidos, gatilhos
*/
User Function DetCodFci(_cProd)
Local cArea      := Alias()
Local _cNumEmp := alltrim(FWGrpCompany())+alltrim(FWCodFil())
Local _cRet := ""
Local cAux,cPerVen,nMes,nAno,cPerCal
Local aAreaAnt := U_PegaArea({"CFD"})

				cAux := dtos(date())
				cPerVen := substr(cAux,5,2)+substr(cAux,1,4)
				//PerÌodo de c·lculo
				nAno := year(date())
				nMes := month(date()) - 2
				if nMes <= 0
					nMes := 12+nMes
					nAno--
				endif
				cPerCal := padl(alltrim(str(nMes)),2,"0")+padl(alltrim(str(nAno)),4,"0")

            dbselectarea("CFD")   
            dbsetorder(2)
			   //CFD_FILIAL+CFD_COD+CFD_PERCAL+CFD_PERVEN
			   cAux := iif((_cNumEmp == "01010106") .OR. (_cNumEmp == "01010107"),"010101",xFilial("CFD"))
			   dbseek(cAux+_cProd+cPerCal+cPerVen,.T.)
				if found()
					_cRet := CFD->CFD_FCICOD
				endif
U_VoltaArea(aAreaAnt)

if !empty(cArea)
	dbselectarea(cArea) 
endif 

return(_cRet)

// produto de custeio
// verifica se eh produto de custeio
User Function IsProdCusto(cProd,lVar)

Local aArea := {SB1->(GetArea()),GetArea()}
Local cTipo := GetMv("MV_XTPPRDC",,"MO/GG")
Local lRet := .F.

Default lVar := .F.

If !lVar
   SB1->(dbSetOrder(1))
   If SB1->(dbSeek(xFilial("SB1")+cProd))
      If SB1->B1_TIPO $ cTipo .or. !Empty(SB1->B1_GCCUSTO) .or. !Empty(SB1->B1_CCCUSTO)
         lRet := .T.
      Endif
   Endif
Else
   If M->B1_TIPO $ cTipo .or. !Empty(M->B1_GCCUSTO) .or. !Empty(M->B1_CCCUSTO)
      lRet := .T.
   Endif
Endif

aEval(aArea,{|x| RestArea(x)})

Return(lRet)


// produto de custeio
// filtro para query para produto de custeio
User Function IsFQProdCusto()

Local cRet := ""
Local cTipo := GetMv("MV_XTPPRDC",,"MO/GG")

cRet := " AND (NOT (B1_TIPO IN "+FormatIn(cTipo,"/")+" OR B1_GCCUSTO <> ' ' OR B1_CCCUSTO <> ' ')) "

Return(cRet)


User Function VerZ17(cGrpTrib,cNcm)
Local cArea      := Alias()
local lRet := .f.
dbselectarea("Z17")
dbsetorder(1)
dbseek(xFilial("Z17")+cGrpTrib+cNcm)
if found()
   lRet := .t.
endif 

if !empty(cArea)
	dbselectarea(cArea) 
endif 
return(lRet)

//FunÁ„o para atualizar o campo A5_CODPRCA que dever· conter o cabeÁalho dos Kits Coca Cola
//Uso: TECPOLPA
//ATEN«√O! EspecÌfico para fornecedore RECOFARMA!!! CÛdigo de Fornecedor 002511, Loja 01!!!
User Function VKitsSA5()
Local cArea      := Alias()
Local aAreaAnt := U_PegaArea({"SA5","SG1"})
Local lRet := .t.
Local cRet,cProdSA5

dbselectarea("SA5")
dbsetorder(2)
if Select("TMPG1")<>0		
	dbselectarea("TMPG1")
	dbclosearea()
endif 
//Chama funÁ„o que verifica se h· inconsistÍncia
cQuery := "SELECT dbo.VerKitsSA5('"+xFilial("SG1")+"') AS RET"
TCQuery cQuery ALIAS "TMPG1" NEW
dbselectarea("TMPG1")
cRet := ALLTRIM(TMPG1->RET)
if !(cRet == "OK")
   lRet := .f.
   MsgAlert(cRet)
   dbclosearea()
else 
   dbclosearea()
   cQuery := "SELECT DISTINCT G1_COD AS CODPRO FROM "+RetSqlName("SG1")+" WHERE (D_E_L_E_T_ <> '*') AND (G1_FILIAL = '"+xFilial("SG1")+"') AND (G1_QUANT < 0.0) "
   TCQuery cQuery ALIAS "TMPG1" NEW
   dbselectarea("TMPG1")
   dbgotop()
   do while !eof()
      cProdSA5 := ""
      dbselectarea("SG1")
      dbsetorder(1)
      MsSeek(xFilial("SG1")+TMPG1->CODPRO,.t.)
      do while !eof() .and. (SG1->G1_FILIAL = xFilial("SG1")) .AND. (TMPG1->CODPRO == SG1->G1_COD)
         if SG1->G1_QUANT >= 0
            cProdSA5 := SG1->G1_COMP
            exit 
         endif
         dbskip()
      enddo 
      IF !Empty(cProdSA5)
         dbselectarea("SA5") //A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA                                                                                                                         
         MsSeek(xFilial("SA5")+cProdSA5+"00251101",.t.) //CÛdigo fornecedor exclusivo
         if found()
            if !(alltrim(SA5->A5_CODPRCA) == ALLTRIM(TMPG1->CODPRO))
               reclock("SA5",.F.)
               SA5->A5_CODPRCA := TMPG1->CODPRO
               msunlock()
            endif 
         endif 
      ENDIF 
      dbselectarea("TMPG1")
      dbskip()
   enddo 
   dbselectarea("TMPG1")
   dbclosearea()
endif //Fim  if !(cRet == "OK")

U_VoltaArea(aAreaAnt)
if !empty(cArea)
	dbselectarea(cArea) 
endif 
return(lRet)
