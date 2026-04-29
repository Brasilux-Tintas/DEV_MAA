#include "totvs.ch"

//***************************************************************//
// Programa.......: M410SOLI                                     //
// Autor..........: Cleber Orati                                 //
// Ult. Alteração.:                                              //
// Data...........: 23/01/2013                                   //
// Ocorrência.....: Criação desse ponto de entrada para suprir   //
//                  necessidade devido alteração da lei no esta- //
//                  do do MT de acordo com a lei 9.480 de 17/12/ //
//                  2010.                                        //
// Data...........: 23/01/2013                                   //
// Data...........: 11/03/2016-Alt MVA solic Fernando            //
// Data...........: 23/02/2017-Ajuste Cons Final GO              //
// Ocorrência.....: OBS.: Usado em conjunto com M460SOLI!!!!     //
// Data...........: 04/11/2015                                   //
// Ocorrência.....: Adaptação de lei adicional de MT             //
//                                                               //
// Data...........: 25/09/2019                                   //
// Alteração......: Luís Gustavo                                 //
// Ocorrência.....: Adequação para release 12.1.25               //
// Data...........: 05/10/2021                                   //
// Alteração......: Cleber Orati                                 //
// Ocorrência.....: Incremento do FECP no retorno do array       //
//***************************************************************//
User Function M410SOLI()  
     /*
     Local aRetSol    := {}  
     aadd(aRetSol,2)
     aadd(aRetSol,1)      
     Return(aRetSol)
     Static Function Teste
     */
     Local lWebServ   := IsInCallStack("fGetImposto") // Identifica se está executando via Webservice GetImposto
     Local cArea      := alias()
     Local aArea      := U_PegaArea({"SF4","SB1","CC3","CFC"})
     Local _nDec, nPosQTDVEN, nPosPRCVEN, nPosValor, nPosProd, _nLinha, cNcm, nMargemRef, cCnae
     Local cUfOrigem  := alltrim(GETMV("MV_ESTADO"))
     Local nValICM    := 0
     Local nAliqInt   := 0
     Local nBaseSubst := 0 
     Local nSt        := 0    
     lOCAL nAliqSol   := 0
     Local aRetSol    := {}  
	Local _nBaseFCP := 0 // Base do FCP-ST
	Local _nAliqFCP := 0 // Aliquota do FCP-ST
	Local _nValFCP := 0 // Valor do FCP-ST
     Local nPosTES, nMva, nMvaSist, cTpPedido, cCodTes, cCodPro, nQtdVen, nPrcVen, nVlrTot,cCest

      // Validação de MV para execução da rotina, 
      //caso o MV não exista ou esteja com valor zerado, a rotina é encerrada 
      //retornando array vazio, evitando processamento desnecessário e possíveis erros de execução.  
      // MAA - 20260407
      If .NOT. SuperGetMV("BR_410SOLI",.F.,.F.)
        Return(aRetSol)
    End

     u_zcfga01( 'M410SOLI' ) //LGS#2021201 - Gravação de log de utilização da rotina
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Chamada via Webservice GetImposto.                    ³
     //³ Variáveis do GETIMPOSTO que podem ser utilizadas:     ³
     //³ _cTipoPed: Tipo de pedido                             ³
     //³ _cCliente: Código do cliente                          ³
     //³ _cLoja   : Loja do cliente                            ³
     //³ _cTipoCli: Tipo de cliente                            ³
     //³ _cTpFrete: Tipo de frete                              ³
     //³ _aProdutos: vetor dos itens do GetImposto             ³
     //³ _aProdutos[nItem][1]: Código do produto               ³
     //³ _aProdutos[nItem][2]: Código do TES                   ³
     //³ _aProdutos[nItem][3]: Quantidade                      ³
     //³ _aProdutos[nItem][4]: Preço unitário                  ³
     //³ _aProdutos[nItem][5]: Valor total                     ³
     //³ _aProdutos[nItem][6]: Valor desconto                  ³
     //³ _aProdutos[nItem][7]: Valor frete                     ³
     //³ _aProdutos[nItem][8]: Valor despesa                   ³
     //³ _aProdutos[nItem][9]: Valor seguro                    ³
     //³ _aProdutos[nItem][10]: Valor frete autonomo           ³
     //³                                                       ³
     //³ Variáveis que podem ser alteradas e retornadas:       ³
     //³ - As mesmas do ponto de entrada M410SOLI              ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If alltrim(FWGrpCompany()) == '01' //Empresas do grupo BRASILUX.
        cTpPedido := iif(lWebServ,_cTipoPed,M->C5_TIPO)     
      cNcm := ""
      cCest := ""

      If cTpPedido = "N" //Tipo de Pedido sempre de Vendas ("N") Normal  
           _nLinha := PARAMIXB[1]    
           nAliqICM := MaFisRet(_nLinha, "IT_ALIQICM")
           // Det. da Aliq. ICM interna do estado destino       
           //cAux     := alltrim(GETMV("MV_ESTICM"))
         if (ALLTRIM(SA1->A1_EST) == cUfOrigem)
              nAliqInt := nAliqICM/100
         else 
              nAliqInt := U_Aliqinterna(SA1->A1_EST) //val(SUBSTR(cAux, At(SA1->A1_EST, cAux)+2, 2)) / 100
         endif 
         nAliqSol := nAliqInt*100

         if !lWebServ
              nPosTES     := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_TES" }) //Posicionamento do campo C6_TES no aHeader
              nPosProd := aScan(aHeader, {|x| Trim(x[2]) == "C6_PRODUTO" }) //Posicionamento do campo C6_PRODUTO no aHeader
              nPosQTDVEN     := aScan(aHeader, {|x| Trim(x[2]) == "C6_QTDVEN" }) //Posicionamento do campo C6_QTDVEN no aHeader
              nPosPRCVEN     := aScan(aHeader, {|x| Trim(x[2]) == "C6_PRCVEN" }) //Posicionamento do campo C6_PRCVEN no aHeader
              nPosVALOR := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_VALOR" }) //Posicionamento do campo C6_VALOR no aHeader
              cCodTes := aCols[_nLinha][nPosTES]
              cCodPro := aCols[_nLinha][nPosProd]
              nQtdVen := aCols[_nLinha][nPosQTDVEN]
              nPrcVen := aCols[_nLinha][nPosPRCVEN]
              nVlrTot := aCols[_nLinha][nPosVALOR]
         else
              cCodTes := _aProdutos[_nLinha][2]
              cCodPro := _aProdutos[_nLinha][1]
              nQtdVen := _aProdutos[_nLinha][3]
              nPrcVen := _aProdutos[_nLinha][4]
              nVlrTot := _aProdutos[_nLinha][5]
         endif 
         
         dbselectarea("SF4")
         dbsetorder(1)
         dbseek(xFilial("SF4")+cCodTes)
         IF  (SF4->F4_INCSOL = "S")
              nBaseSubst := MaFisRet(_nLinha, "IT_BASESOL")
              dbselectarea("SB1")
              dbsetorder(1)
              dbseek(xFilial("SB1")+cCodPro)  
            if found()
               cNcm := ALLTRIM(SB1->B1_POSIPI)
               cCest := ALLTRIM(SB1->B1_CEST)
            endif 
              cCnae := alltrim(SA1->A1_CNAE)
              if empty(cCnae)
                 cCnae := "XXXX-X/XX"
              endif 
			      /* //Cleber -> Chamado 015949, MT mudou regras pra 01/01/20
              //Essa mudança diz respeito a lei 9.480 para o Estado do MT para Subst. Tributária
              IF !empty(cNcm) .AND. (SA1->A1_EST $ 'MT') .AND. (SA1->A1_CLAS = 'V')                                                           
                 nPosQTDVEN     := nQtdVen //Posicionamento do campo C6_QTDVEN no aHeader
                 nPosPRCVEN     := nPrcVen //Posicionamento do campo C6_PRCVEN no aHeader
                 nAliqSol := nAliqICM //Alíq. icms subst. é o próprio icms
                 nVlrIpi    := MaFisRet(_nLinha,"IT_VALIPI")
                 nFrete     := MaFisRet(_nLinha,"IT_FRETE")
                 cLeiMT := "N"
                 if (cCnae $ Alltrim(GetMv("MV_CNAEMT"))) 
                    cQuery := "SELECT dbo.FISCAL_MT_LEI_948010('"+cNcm+"') AS TANALEI"  
                    cAliasTmp := U_NovoCursor()
                    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasTmp, .T., .T.)
				  	DbSelectArea(cAliasTmp)
			   		DbGoTop()
					cLeiMT := IIF(!eof() .and. !bof(),(cAliasTmp)->TANALEI,"N")
				  	dbclosearea(cAliasTmp)
                 endif     
				
                 DO CASE
                    CASE (cLeiMT == "S")
					nValAcres  := 0.45 //MVA utilizado pela Lei
					//Solic. Fernando Mauri em 17/06/13, carga total não pode ser menor que 10.15%
					if (( 1 + nValAcres )*nAliqSol) < 10.15  
						nAliqSol := round(10.15/( 1 + nValAcres ),2)
					endif 

					_nDec := TamSX3("D2_BRICMS")[2]
					nBaseSubst := round(( ( nQtdVen * nPrcVen)+ nFrete + nVlrIpi ) * ( 1 + nValAcres ),_nDec)
					aAdd(aRetSol, nBaseSubst)

					_nDec := TamSX3("D2_ICMSRET")[2]
					aAdd(aRetSol, ROUND(nBaseSubst * ( nAliqSol / 100 ),_nDec) )       

					_nDec := TamSX3("D2_MARGEM")[2]     
					MaFisLoad("IT_MARGEM" ,NoRound(nValAcres*100,_nDec),_nLinha)  // Cleber -> só por garantia, antigamente o vetor de retorno só contemplava base e valor
					
					_nDec := TamSX3("D2_ALIQSOL")[2]
					MaFisLoad("IT_ALIQSOL" ,nAliqSol,_nLinha) // Cleber -> só por garantia, antigamente o vetor de retorno só contemplava base e valor 
                    CASE (cNcm $ "32081010-32091010-32099011-32099019-38140090-32141010-32141020-35069190")
					nValAcres  := 0 //Sem MVA, decreto-MT 1355 de 04/09/12 ,art. 1º, III, § 4°-A-2, II
					nAliqSol := 25   

					_nDec := TamSX3("D2_BRICMS")[2]
					nBaseSubst := round(( ( nQtdVen * nPrcVen)+ nFrete + nVlrIpi ) * ( 1 + nValAcres ),_nDec)
					aAdd(aRetSol, nBaseSubst)

					_nDec := TamSX3("D2_ICMSRET")[2]
					aAdd(aRetSol, ROUND(nBaseSubst * ( nAliqSol / 100 ),_nDec) )       

					_nDec := TamSX3("D2_MARGEM")[2]
					MaFisLoad("IT_MARGEM" ,NoRound(nValAcres*100,_nDec),_nLinha)  

					_nDec := TamSX3("D2_ALIQSOL")[2]
					MaFisLoad("IT_ALIQSOL" ,nAliqSol,_nLinha)  
                    OTHERWISE
				
					dbselectarea("CC3")
					dbsetorder(1)
					dbseek(xFilial("CC3")+cCnae)
					If found() .AND. (CC3->CC3_CARGMT > 0) 
						nCargaMedia := CC3->CC3_CARGMT   
					else  
						//15/03/2016->CNAE não mencionado nos itens anteriores considerar 17% de acordo com a lei
						nCargaMedia := 17
					endif    
						
					// Det. da Aliq. ICM interna do estado destino       
					//cAux     := GETMV("MV_ESTICM")
					nAliqInt := U_Aliqinterna(SA1->A1_EST) //val(SUBSTR(cAux, At(SA1->A1_EST, cAux)+2, 2)) / 100
					nValIcm := MaFisRet(_nLinha,"IT_VALICM")
					_nDec := TamSX3("D2_ICMSRET")[2]
					nSomaVlr := ( nQtdVen * nPrcVen) + nFrete + nVlrIpi
					nValST := NOROUND(nSomaVlr*nCargaMedia/100,_nDec)

					_nDec := TamSX3("D2_BRICMS")[2]
					nBaseSubst := round( (nValIcm+nValST)/nAliqInt,_nDec)
					aAdd(aRetSol, nBaseSubst)
					aAdd(aRetSol, nValST )       

					_nDec := TamSX3("D2_MARGEM")[2] 
					nValAcres := 1- (nBaseSubst/nSomaVlr)
					MaFisLoad("IT_MARGEM" ,NoRound(nValAcres*100,_nDec),_nLinha)      
                 ENDCASE 
              ELSE //If (SA1->A1_EST $ 'MT') .AND. (SA1->A1_CLAS = 'V')
			   */
                 //Considerar FECP na aliq. icm
				dbselectarea("CFC")
				dbsetorder(1)
				dbseek(xFilial("CFC")+cUforigem+SA1->A1_EST)
				if found()
					_nAliqFCP := CFC->CFC_ALQFCP
					nAliqSol += _nAliqFCP
				endif 

				_nDec := TamSX3("D2_ALIQSOL")[2]
				MaFisLoad("IT_ALIQSOL" ,nAliqSol,PARAMIXB[1])  //Atenção! Detectado em 17/08/21 que o comando MafisLoad não está sendo acatado!!!

				_nDec := TamSX3("D2_MARGEM")[2]
				//(Cleber - 12/11/15 -> Nova aliquota de MVA para MG à partir de 01/12/15				
            //(Cleber) - 01/02/2022->Chamado 025427, alteração pra SP
            do case
            case (SA1->A1_EST = "BA") .AND. !empty(cNcm) .AND. (cNcm = "32149000")
               nMargemRef := 1.45 //Renata (24/08/2021)
            //(Sergio - 23/08/2023) -> Chamado R2315 (Renata) alteração do ST p/ MG - Alíquota da MVA do grupo 3204
            case (SA1->A1_EST = "MG") .AND. !empty(cNcm) .AND. !(cNcm = "32061119") .AND. ((substr(cNcm,1,4) $ "2821.3206.3208.3209") .OR. (cNcm = "321000")) //.OR. (cNcm = "32041700"))
					nMargemRef := 1.64
            //11/03/2016->Solic Fernando Mauri excluir esses mvas					          	
            //21/11/2016->Reunião com Fernando, volta situação anterior com exceção de MG. Apresentado PDF da Sitivesp com NCMs
            case (SA1->A1_EST = "SP") .AND. !empty(cNcm) .AND. ((substr(cNcm,1,4) $ "3208.3209") .OR. (cNcm = "321000")) // Jose mudar dia 29/10/2024
					   nMargemRef := 1.52  // Jose mudar dia 29/10/2024 DE   1.53             	
            case (SA1->A1_EST = "SP") .AND. !empty(cNcm) .AND. !(cNcm = "32061119") .AND. ((substr(cNcm,1,4) $ "2821.3206") .OR. ((cNcm = "32041700") .AND. (cCest = '2400200'))) //Chamado 025536, considerar CEST
					   nMargemRef := 2.14 // Jose mudar dia 29/10/2024 DE  2.18
            case (SA1->A1_EST $ "MG-SP") .AND. !empty(cNcm) .AND. ((substr(cNcm,1,4) $ "3204.3206.3212") .OR. (cNcm = "32050000")) // Jose mudar dia 29/10/2024
            //11/04/2017 -> Chamado 006914, Fernando Mauri
               if SA1->A1_EST = "MG"
					   nMargemRef := 1.6468
               else 
                  if (cNcm = "32041700") // Jose mudar dia 29/10/2024
                      nMargemRef := 2.14 // Jose mudar dia 29/10/2024 DE  2.18
                  Else // Jose mudar dia 29/10/2024
   					    nMargemRef := 1.93  // Jose mudar dia 29/10/2024 DE 2.03  
                  Endif // Jose mudar dia 29/10/2024
               endif 
// JOSE 02/10/2024 case !(SA1->A1_EST $ "MG-AC-AM-TO-PE") .AND. ((substr(cNcm,1,4) $ "3204.3206.3212.2821") .OR. (cNcm = "32050000") )  // AC,PE, TO
              case !(SA1->A1_EST $ "MG-AM") .AND. ((substr(cNcm,1,4) $ "3204.3206.3212.2821") .OR. (cNcm = "32050000") )  // JOSE 02/10/2024
               //À partir de 01/05/2019, chamado 013806
               do case
               case SA1->A1_EST = "RS"
                  nMargemRef := 2.18
               case SA1->A1_EST = "PR"
                  nMargemRef := 1.53
               case SA1->A1_EST $ "AC-AL-MS-PE-RO-TO" // JOSE 01/10/2024
                  nMargemRef := 1.35   // JOSE 01/10/2024
               otherwise
                  nMargemRef := 1.50
               endcase 
               //nMargemRef := iif(SA1->A1_EST $ 'SP-PR',1.53,1.50) //01/08/17 -> SP passa a ter 50% : 09/08/17 -> VOLTA A 53%!!
            otherwise
               //À partir de 01/05/2019, chamado 013806
               do case
                  case SA1->A1_EST $ "SP-RS"
                     nMargemRef := 1.58
                  case SA1->A1_EST = "PR"
                     nMargemRef := 1.38
                  otherwise
                     nMargemRef := 1.35
               endcase 
               //nMargemRef := iif(SA1->A1_EST $ 'SP-PR',1.38,1.35)
            endcase  
                    
            IF SA1->A1_EST = "MT"
                    	//MT à partir de 01/01/20, não há ajuste de MVA, chamado 015949
                    	IF ALLTRIM(SA1->A1_GRPTRIB) == "MTO" //Exceção de MVA para MT
                    		nMva := 56.4
                    	ELSE
                    		nMva := 56.4 //E-mail em 09/01/20 -> Desconsiderar percentual 72.12 até segunda ordem
                    	ENDIF
            ELSE
                    	nMva := ROUND(((nMargemRef*(1-(nAliqICM/100))/(1-(nAliqSol/100)))-1)*100,_nDec)
            ENDIF 
            nMvaSist := MaFisRet(_nLinha, "IT_MARGEM") 
				
            if (SF4->F4_MKPSOL <> "1")
						IF ((nMvaSist > 0) .and. (nMva != nMvaSist)) .OR. (nBaseSubst == 0.0)
	        	
							//Cleber(12/05/16) -> Venda Suframa com desconto de ICMS, tem que tirar do vlr da ST o icms Próprio descontado, ele vem com Zero! 
							//FALHA DO PROTHEUS, depois de reajuste de alíquotas pelos estados as novas atualizações
							//passaram a trazer Base ST agregando PIS+COFINS para vendas SUFRAMA!!
		    	         nValIcm := MaFisRet(_nLinha,"IT_VALICM")
	    					if (nValIcm == 0.0) .AND. (SA1->A1_CALCSUF $ "S-I") .AND. (nAliqICM > 0)
	    						nValIcm := MaFisRet(_nLinha, "IT_BICMORI")*nAliqIcm/100   
	    					endif 
							//MaFisLoad("IT_BASESOL" ,nBaseSubst,_nLinha)  
	
							_nDec := TamSX3("D2_BRICMS")[2]   
							//Cleber(04/05/18) -> Ao atualizar patch Reinf está zerando base ST, FALHA DO PROTHEUS


	    					if (nBaseSubst == 0.0) 
		    					nBaseSubst := round(( (nVlrTot)+ MaFisRet(_nLinha,"IT_VALIPI")+MaFisRet(_nLinha,"IT_FRETE") ) * ( 1 + (nMva/100) ),_nDec)
		    				else
		    					nBaseSubst := round(nBaseSubst*(1+(nMva/100))/(1+(nMvaSist/100)),_nDec)
	    					endif 
						   aAdd(aRetSol, nBaseSubst)
							_nDec := TamSX3("D2_ICMSRET")[2]
							nSt := ROUND((nBaseSubst*nAliqSol/100) - nValIcm,_nDec)
						  	aAdd(aRetSol, nSt )       
							MaFisLoad("IT_MARGEM" ,nMva,_nLinha)  
   						aAdd(aRetSol, nMva)
   						aAdd(aRetSol, nAliqSol)
   						_nBaseFCP := nBaseSubst
	   					aAdd(aRetSol, _nBaseFCP)
		   				aAdd(aRetSol, _nAliqFCP)
			   			_nDec := TamSX3("D2_VFECPST")[2]
				   		_nValFCP := ROUND(_nBaseFCP*_nAliqFCP/100,_nDec)
					   	aAdd(aRetSol, _nValFCP)
						ENDIF
				else
						//Cleber(23/02/17)->Lei específica de Goiás (Lei nº 11.651/91, art. 56) que majora a base do icms    
						//Cleber(19/07/17)->Chamado 007723, Nadia solicitou mudança na regra da lei de Goiás
						//Cleber(28/12/17)->Chamado 009017, mudança à partir de 2018, considerar TODOS OS ESTADOS
						_nDec := TamSX3("D2_BRICMS")[2]   
							//Cleber(04/05/18) -> Ao atualizar patch Reinf está zerando base ST, FALHA DO PROTHEUS
	   				if (nBaseSubst == 0.0) 
	    					nBaseSubst := round(( (nVlrTot)+ MaFisRet(_nLinha,"IT_VALIPI")+MaFisRet(_nLinha,"IT_FRETE") ) ,_nDec)
	    				endif 

						//IF (SA1->A1_EST = "GO") .AND. (SA1->A1_CLAS = 'C') .AND. (nBaseSubst > 0)
						IF !(ALLTRIM(SA1->A1_EST) == ALLTRIM(GETMV("MV_ESTADO"))) .AND. (SA1->A1_CLAS = 'C') .AND. (nBaseSubst > 0)
			              	//nValIcm := MaFisRet(_nLinha,"IT_VALICM")
							_nDec := TamSX3("D2_BRICMS")[2]   
							nBaseSubst := round(nBaseSubst/(1-nAliqInt),_nDec)
							aAdd(aRetSol, nBaseSubst)
							_nDec := TamSX3("D2_ICMSRET")[2]
							//aAdd(aRetSol, ROUND((nBaseSubst*nAliqSol/100) - nValIcm,_nDec) )       
							aAdd(aRetSol, ROUND((nBaseSubst*(nAliqSol-nAliqICM)/100),_nDec) )       
   						aAdd(aRetSol, nMvaSist)
   						aAdd(aRetSol, nAliqSol)
							_nBaseFCP := nBaseSubst
						   aAdd(aRetSol, _nBaseFCP)
						   aAdd(aRetSol, _nAliqFCP)
						   _nDec := TamSX3("D2_VFECPST")[2]
						   _nValFCP := ROUND(_nBaseFCP*_nAliqFCP/100,_nDec)
						   aAdd(aRetSol, _nValFCP)

						ENDIF 
			   endif 					
				
	        //Endif // FIM If (SA1->A1_EST $ 'MT') .AND. (SA1->A1_CLAS = 'V') -> (Chamado 015949, MT mudou lei pra 01/01/20)
         ENDIF // fim if  (SF4->F4_INCSOL = "S")
      Endif // Fim if cTpPedido = "N"
   Endif // fim If alltrim(FWGrpCompany()) == '01' //Empresas que não são do grupo 11(Tecpolpa).
U_VoltaArea(aArea)
If !empty(cArea)
   dbselectarea(cArea)
Endif
Return(aRetSol)
