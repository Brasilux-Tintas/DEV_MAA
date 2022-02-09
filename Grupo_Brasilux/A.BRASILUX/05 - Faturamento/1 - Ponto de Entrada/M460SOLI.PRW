#include "totvs.ch"

//***************************************************************//
// Programa.......: M460SOLI                                     //
// Autor..........:                                              //
// Ult. Alteração.:                                              //
// Data...........: 18/01/2010                                   //
// Data...........: 23/02/2017-Ajuste Cons Final GO              //
// Ocorrência.....: Criação desse ponto de entrada para suprir   //
//                  necessidade devido alteração da lei no esta- //
//                  do do MT de acordo com a lei 9.480 de 17/12/ //
//                  2010.                                        //
// Data...........:                                              //
// Ocorrência.....:                                              //
// Obs: Utilizado em conjunto com M410SOLI e M415SOLI!!!         //
//                                                               //
// Data...........: 25/09/2019                                   //
// Alteração......: Luís Gustavo                                 //
// Ocorrência.....: Adequação para release 12.1.25               //
// Data...........: 05/10/2021                                   //
// Alteração......: Cleber Orati                                 //
// Ocorrência.....: Incremento do FECP no retorno do array       //
//***************************************************************//
User Function M460SOLI()
     Local cAlias := Alias()
     Local aArea := U_PegaArea({"SB1","CC3","CFC"})
     Local _nDec,cNcm,nMargemRef,nAliqInt,nValIcm,cCnae,cCest
     Local cUfOrigem := alltrim(GETMV("MV_ESTADO"))
     Local nAliqICM    := 0
     Local nVlrIpi    := 0
     Local nFrete     := 0
     Local nBaseSubst := 0     
     lOCAL nAliqSol  := 0
     Local aRetSol    := {}   
	Local _nBaseFCP := 0 // Base do FCP-ST
	Local _nAliqFCP := 0 // Aliquota do FCP-ST
	Local _nValFCP := 0 // Valor do FCP-ST
	Local _nItem := ParamIxb[1] //Item do aCols
//	Local _cItemSC6
     Local nMva,nMvaSist
     u_zcfga01( 'M460SOLI' ) //LGS#2021201 - Gravação de log de utilização da rotina
If alltrim(FWGrpCompany()) == '01' //Empresas que não são do grupo 11(Tecpolpa).
 	//_cItemSC6 := ParamIxb[2] //Item do Pedido de Venda (C6_ITEM)
    cNcm := ""
    cCest := ""
    If SC5->C5_TIPO = "N" //Tipo de Pedido sempre de Vendas ("N") Normal
		nAliqICM := MaFisRet(_nItem, "IT_ALIQICM")
		// Det. da Aliq. ICM interna do estado destino       
		//cAux     := alltrim(GETMV("MV_ESTICM"))
		IF ALLTRIM(SA1->A1_EST) == cUfOrigem 
			nAliqInt := nAliqICM/100
		else 
			nAliqInt := U_Aliqinterna(SA1->A1_EST) //val(SUBSTR(cAux, At(SA1->A1_EST, cAux)+2, 2)) / 100
		endif  
		nAliqSol := nAliqInt*100
		//nMva := ROUND((((1.35)*(1-(nAliqICM/100))/(1-nAliqInt))-1)*100,2)
		
		if (SF4->F4_INCSOL = "S")
			nBaseSubst := MaFisRet(_nItem, "IT_BASESOL")
			dbselectarea("SB1")
			dbsetorder(1)
			dbseek(xFilial("SB1")+SC6->C6_PRODUTO)
			if found()
				cNcm := ALLTRIM(SB1->B1_POSIPI) 
				cCest := alltrim(SB1->B1_CEST)
			endif 
			cCnae := alltrim(SA1->A1_CNAE)
			if empty(cCnae)
				cCnae := "XXXX-X/XX"
			endif 
			
			/* //Cleber -> Chamado 015949, MT mudou regras pra 01/01/20
			//Essa mudança diz respeito a lei 9.480 para o Estado do MT para Subst. Tributária 
			IF !empty(cNcm) .AND. (SA1->A1_EST $ 'MT') .AND. (SA1->A1_CLAS = 'V')                                                           
				nAliqSol := nAliqICM //Alíq. icms subst. é o próprio icms
				nVlrIpi    := MaFisRet(_nItem,"IT_VALIPI")
				nFrete     := MaFisRet(_nItem,"IT_FRETE")
				cMensNf = Alltrim(MSMM(SC5->C5_OBSNFS)) 
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
					nBaseSubst := round(( ( SC6->C6_QTDVEN * SC6->C6_PRCVEN)+ nFrete + nVlrIpi ) * ( 1 + nValAcres ),_nDec)
					aAdd(aRetSol, nBaseSubst)

					_nDec := TamSX3("D2_ICMSRET")[2]
					aAdd(aRetSol, ROUND(nBaseSubst * ( nAliqSol / 100 ),_nDec) )       

					_nDec := TamSX3("D2_MARGEM")[2]
					aAdd(aRetSol, NoRound(nValAcres*100,_nDec) )       
					MaFisLoad("IT_MARGEM" ,NoRound(nValAcres*100,_nDec),_nItem)  // Cleber -> só por garantia, antigamente o vetor de retorno só contemplava base e valor

					_nDec := TamSX3("D2_ALIQSOL")[2]
					aAdd(aRetSol, nAliqSol )       
					MaFisLoad("IT_ALIQSOL" ,nAliqSol,_nItem)  // Cleber -> só por garantia, antigamente o vetor de retorno só contemplava base e valor
					_cMens := "RED CARGA TRIBUTARIA CONCEDIDA PELA UF DO MT REF. ICMS SUBS. TRIBUTARIA CONF LEI ESTADUAL 9.480 DE 1712/10, PUBLIC NO DOE 17/12/10. - Lei regulament pelo Decro 07 de 14/01/11 - DOE MT de 14/01/11, alterando o RICMS-MT e Decreto 313 de 11/05/11."
				CASE (cNcm $ "32081010-32091010-32099011-32099019-38140090-32141010-32141020-35069190")
					nValAcres  := 0 //Sem MVA, decreto-MT 1355 de 04/09/12 ,art. 1º, III, § 4°-A-2, II
					nAliqSol := 25   

					_nDec := TamSX3("D2_BRICMS")[2]
					nBaseSubst := round(( ( SC6->C6_QTDVEN * SC6->C6_PRCVEN)+ nFrete + nVlrIpi ) * ( 1 + nValAcres ),_nDec)
					aAdd(aRetSol, nBaseSubst)

					_nDec := TamSX3("D2_ICMSRET")[2]
					aAdd(aRetSol, ROUND(nBaseSubst * ( nAliqSol / 100 ),_nDec) )       

					_nDec := TamSX3("D2_MARGEM")[2]
					aAdd(aRetSol, NoRound(nValAcres*100,_nDec) )       
					MaFisLoad("IT_MARGEM" ,NoRound(nValAcres*100,_nDec),_nItem)    
					
					_nDec := TamSX3("D2_ALIQSOL")[2]
					aAdd(aRetSol, nAliqSol )       
					MaFisLoad("IT_ALIQSOL" ,nAliqSol,_nItem)  
					_cMens := "Prod com tributacao diferenciada por NCM conf decreto-MT 1355 de 04/09/12 ,art. 1o., III, paragrafo 4o.-A-2, II"
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
						nValIcm := MaFisRet(_nItem,"IT_VALICM")
						_nDec := TamSX3("D2_ICMSRET")[2]
						nSomaVlr := (SC6->C6_QTDVEN * SC6->C6_PRCVEN)+ nFrete + nVlrIpi
						nValST := NOROUND(nSomaVlr*nCargaMedia/100,_nDec)
						_nDec := TamSX3("D2_BRICMS")[2]
						nBaseSubst := round( (nValIcm+nValST)/nAliqInt,_nDec)
						aAdd(aRetSol, nBaseSubst)
						aAdd(aRetSol, nValST )       
						_nDec := TamSX3("D2_MARGEM")[2] 
						nValAcres := 1- (nBaseSubst/nSomaVlr)
						aAdd(aRetSol, NoRound(nValAcres*100,_nDec) )       
						MaFisLoad("IT_MARGEM" ,NoRound(nValAcres*100,_nDec),_nItem)  
						aAdd(aRetSol, nAliqSol )       
				        _cMens := "Artigo 157(Regime Estimativa por Operação Simplificada) conforme Anexo XIII do RICMS MT"
//					Endif
				
				ENDCASE 
    			if !empty(_cMens) .AND. !(_cMens $ cMensNf)
     				if !empty(cMensNf)
						cMensNf += "**"
					endif 
					cMensNf += _cMens
					//MSMM(SC5->C5_OBSNFS, , ,cMensNf    , 1, , , "SC5", "C5_OBSNFS")   
					
					//Msmm -  ( [ cChave ] [ nTam ] [ nLin ] [ cString ] [ nOpc ] [ nTamSize ] [ lWrap ] [ cAlias ] [ cCpoChave ] [ cRealAlias ] [ lSoInclui ] ) --> uRet
					   				
    			endif 

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
				MaFisLoad("IT_ALIQSOL" ,nAliqSol,_nItem)  
				
				_nDec := TamSX3("D2_MARGEM")[2]       
 				//(Cleber - 12/11/15 -> Nova aliquota de MVA para MG à partir de 01/12/15				
              //(Cleber) - 01/02/2022->Chamado 025427, alteração pra SP
               do case
            	case (SA1->A1_EST = "BA") .AND. !empty(cNcm) .AND. (cNcm = "32149000")
               		nMargemRef := 1.45 //Renata (24/08/2021)
                case (SA1->A1_EST = "MG") .AND. !empty(cNcm) .AND. !(cNcm = "32061119") .AND. ((substr(cNcm,1,4) $ "3208.3209.2821.3206") .OR. (cNcm = "321000") .OR. (cNcm = "32041700"))
					nMargemRef := 1.64                	
				//11/03/2016->Solic Fernando Mauri excluir esses mvas					          	
				//21/11/2016->Reunião com Fernando, volta situação anterior com exceção de MG. Apresentado PDF da Sitivesp com NCMs
				case (SA1->A1_EST = "SP") .AND. !empty(cNcm) .AND. ((substr(cNcm,1,4) $ "3208.3209") .OR. (cNcm = "321000"))
						nMargemRef := 1.53                	
            	case (SA1->A1_EST = "SP") .AND. !empty(cNcm) .AND. !(cNcm = "32061119") .AND. ((substr(cNcm,1,4) $ "2821.3206") .OR. ((cNcm = "32041700") .AND. (cCest = '2400200'))) //Chamado 025536, considerar CEST
						nMargemRef := 2.18                	
				case (SA1->A1_EST $ "MG-SP") .AND. !empty(cNcm) .AND. ((substr(cNcm,1,4) $ "3204.3206.3212") .OR. (cNcm = "32050000"))
                //11/04/2017 -> Chamado 006914, Fernando Mauri
				if SA1->A1_EST = "MG"
					nMargemRef := 1.6468                	
				else 
						nMargemRef := 2.03                	
				endif 
				case !(SA1->A1_EST $ "MG-AC-AM-TO-PE") .AND. ((substr(cNcm,1,4) $ "3204.3206.3212.2821") .OR. (cNcm = "32050000") )
					//À partir de 01/05/2019, chamado 013806
					do case
				case SA1->A1_EST = "RS"
						nMargemRef := 2.18
					case SA1->A1_EST = "PR"
						nMargemRef := 1.53
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
				nMvaSist := MaFisRet(_nItem, "IT_MARGEM")
				IF (SF4->F4_MKPSOL <> "1")  
					IF ((nMvaSist > 0) .and. (nMva != nMvaSist)) .OR. (nBaseSubst == 0.0)
						//Cleber(12/05/16) -> Venda Suframa com desconto de ICMS, tem que tirar do vlr da ST o icms Próprio descontado, ele vem com Zero!
		              	nValIcm := MaFisRet(_nItem,"IT_VALICM")
    					if (nValIcm == 0.0) .AND. (SA1->A1_CALCSUF $ "S-I") .AND. (nAliqICM > 0)
    						nValIcm := MaFisRet(_nItem, "IT_BICMORI")*nAliqIcm/100
    					endif 
					
						_nDec := TamSX3("D2_BRICMS")[2]   

						//Cleber(04/05/18) -> Ao atualizar patch Reinf está zerando base ST, FALHA DO PROTHEUS
    					if (nBaseSubst == 0.0) 
    						nVlrIpi    := MaFisRet(_nItem,"IT_VALIPI")
    						nFrete     := MaFisRet(_nItem,"IT_FRETE")
	    					nBaseSubst := round(( (SC6->C6_QTDVEN * SC6->C6_PRCVEN)+ nVlrIpi+nFrete ) * ( 1 + (nMva/100) ),_nDec)
	    				else
	    					nBaseSubst := round(nBaseSubst*(1+(nMva/100))/(1+(nMvaSist/100)),_nDec)
    					endif 


						aAdd(aRetSol, nBaseSubst)
						_nDec := TamSX3("D2_ICMSRET")[2]
						aAdd(aRetSol, ROUND((nBaseSubst*nAliqSol/100) - nValIcm,_nDec) )       
						MaFisLoad("IT_MARGEM" ,nMva,_nItem)  
						aAdd(aRetSol, nMva)
						aAdd(aRetSol, nAliqSol)
						_nBaseFCP := nBaseSubst
						aAdd(aRetSol, _nBaseFCP)
						aAdd(aRetSol, _nAliqFCP)
						_nDec := TamSX3("D2_VFECPST")[2]
						_nValFCP := ROUND(_nBaseFCP*_nAliqFCP/100,_nDec)
						aAdd(aRetSol, _nValFCP)

					ENDIF 
				ELSE 
					//Cleber(23/02/17)->Lei específica de Goiás (Lei nº 11.651/91, art. 56) que majora a base do icms
					//Cleber(19/07/17)->Chamado 007723, Nadia solicitou mudança na regra da lei de Goiás
					//Cleber(28/12/17)->Chamado 009017, mudança à partir de 2018, considerar TODOS OS ESTADOS
					//IF (SA1->A1_EST = "GO") .AND. (SA1->A1_CLAS = 'C') .AND. (nBaseSubst > 0)
					//Cleber(04/05/18) -> Ao atualizar patch Reinf está zerando base ST, FALHA DO PROTHEUS
					_nDec := TamSX3("D2_BRICMS")[2]   
    				if (nBaseSubst == 0.0) 
    					nVlrIpi    := MaFisRet(_nItem,"IT_VALIPI")
    					nFrete     := MaFisRet(_nItem,"IT_FRETE")
	    				nBaseSubst := round(( (SC6->C6_QTDVEN * SC6->C6_PRCVEN)+ nVlrIpi+nFrete ) ,_nDec)
	    			endif 
	    			

					IF !(ALLTRIM(SA1->A1_EST) == ALLTRIM(GETMV("MV_ESTADO"))) .AND. (SA1->A1_CLAS = 'C') .AND. (nBaseSubst > 0)
		              	//nValIcm := MaFisRet(_nItem,"IT_VALICM")
						nBaseSubst := round(nBaseSubst/(1-nAliqInt),_nDec)
						aAdd(aRetSol, nBaseSubst)
						_nDec := TamSX3("D2_ICMSRET")[2]
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
			 
				ENDIF 	                                          
					
				
        	//Endif // Fim IF !empty(cNcm) .AND. (SA1->A1_EST $ 'MT') .AND. (SA1->A1_CLAS = 'V') -> (Chamado 015949, MT mudou lei pra 01/01/20)
    	endif // Fim (SF4->F4_INCSOL = "S")
	Endif //If SC5->C5_TIPO = "N" 
Endif //If ALLTRIM(FWGrpCompany()) <> '11'
U_VoltaArea(aArea)
if !empty(cAlias)
	dbselectarea(cAlias)
endif 

Return(aRetSol)
