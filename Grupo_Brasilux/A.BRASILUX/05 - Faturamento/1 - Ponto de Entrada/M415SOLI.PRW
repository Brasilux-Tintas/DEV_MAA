#include "totvs.ch"

//***************************************************************//
// Programa.......: M415SOLI                                     //
// Autor..........: Cleber Orati                                 //
// Ult. Alteração.:                                              //
// Data...........: 10/02/2015                                   //
// Data...........: 23/02/2017-Ajuste Cons Final GO              //
// Ocorrência.....: Criação desse ponto de entrada para suprir   //
//                  necessidade devido alteração da lei no esta- //
//                  do do MT de acordo com a lei 9.480 de 17/12/ //
//                  2010.                                        //
// Data...........: 10/02/2015                                   //
// Ocorrência.....: OBS.: Usado em conjunto com M460SOLI!!!!     //
//                                                               //
// Data...........: 25/09/2019                                   //
// Alteração......: Luís Gustavo                                 //
// Ocorrência.....: Adequação para release 12.1.25               //
//***************************************************************//
User Function M415SOLI()
	
	Local cArea := alias()
	Local aArea := U_PegaArea({"SF4","SB1","CC3","CFC"})
     Local cAux,_nDec,nPosQTDVEN,nPosPRCVEN,nQtdVen,nPrcVen,nPosProd
     Local _nLinha,cNcm,cQuery,nMargemRef,nAliqInt,nCargaMedia,nValIcm
     Local nSomaVlr,nValST,cCnae
     Local cUfOrigem := alltrim(GETMV("MV_ESTADO"))
     Local nValAcres  := 0
     Local nBasICM    := 0
     Local nValICM    := 0
     Local nAliqInt   := 0
     Local nVlrIpi    := 0
     Local nFrete     := 0
     Local nBaseSubst := 0     
     lOCAL nAliqSol  := 0
     Local aRetSol    := {}  
     Local nPosTES,nMva,nMvaSist
     u_zcfga01( 'M415SOLI' ) //LGS#2021201 - Gravação de log de utilização da rotina
     If alltrim(FWGrpCompany()) == '01' //Empresas que não são do grupo 11(Tecpolpa).
		_nLinha := PARAMIXB[1]    
		nAliqICM := MaFisRet(_nLinha, "IT_ALIQICM")
		// Det. da Aliq. ICM interna do estado destino       
//		cAux     := alltrim(GETMV("MV_ESTICM"))
		IF ALLTRIM(SA1->A1_EST) == cUfOrigem       
			nAliqInt := nAliqICM/100
		else 			
			nAliqInt := U_Aliqinterna(SA1->A1_EST) //val(SUBSTR(cAux, At(SA1->A1_EST, cAux)+2, 2)) / 100
		endif 
		nAliqSol := nAliqInt*100
		nPosTES     := aScan(aHeader, {|x| AllTrim(x[2]) == "CK_TES" }) //Posicionamento do campo CK_QTDVEN no aHeader
		
		dbselectarea("SF4")
		dbsetorder(1)
		dbseek(xFilial("SF4")+iif(empty(aHeader[nPosTES,9]),aCols[_nLinha][nPosTES],(aHeader[nPosTES,9])->CK_TES)) //aCols[_nLinha][nPosTES])
		
		if  (SF4->F4_INCSOL = "S")
			nBaseSubst := MaFisRet(_nLinha, "IT_BASESOL")
			nPosProd := aScan(aHeader, {|x| Trim(x[2]) == "CK_PRODUTO" }) //Posicionamento do campo CK_PRCVEN no aHeader
			nPosQTDVEN     := aScan(aHeader, {|x| Trim(x[2]) == "CK_QTDVEN" }) //Posicionamento do campo CK_QTDVEN no aHeader
			nQtdVen := iif(empty(aHeader[nPosQTDVEN,9]),aCols[_nLinha][nPosQTDVEN],(aHeader[nPosQTDVEN,9])->CK_QTDVEN)
			nPosPRCVEN     := aScan(aHeader, {|x| Trim(x[2]) == "CK_PRCVEN" }) //Posicionamento do campo CK_PRCVEN no aHeader
			nPrcVen := iif(empty(aHeader[nPosPRCVEN,9]),aCols[_nLinha][nPosPRCVEN],(aHeader[nPosPRCVEN,9])->CK_PRCVEN)
			dbselectarea("SB1")
			dbsetorder(1)
			dbseek(xFilial("SB1")+iif(empty(aHeader[nPosProd,9]),aCols[_nLinha][nPosProd],(aHeader[nPosProd,9])->CK_PRODUTO))  //aCols[_nLinha][nPosProd]
			cNcm := iif(found(),TRIM(SB1->B1_POSIPI),"") 
			cCnae := alltrim(SA1->A1_CNAE)
			if empty(cCnae)
				cCnae := "XXXX-X/XX"
			endif 
			
			/* //Cleber -> Chamado 015949, MT mudou regras pra 01/01/20
			//Essa mudança diz respeito a lei 9.480 para o Estado do MT para Subst. Tributária
			IF !empty(cNcm) .AND. (SA1->A1_EST $ 'MT') .AND. (SA1->A1_CLAS = 'V')                                                           
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
					nBaseSubst := round(( ( nQtdVen*nPrcVen)+ nFrete + nVlrIpi ) * ( 1 + nValAcres ),_nDec)
					aAdd(aRetSol, nBaseSubst)
					_nDec := TamSX3("D2_ICMSRET")[2]
					aAdd(aRetSol, ROUND(nBaseSubst * ( nAliqSol / 100 ),_nDec) )       
					_nDec := TamSX3("D2_MARGEM")[2]
					MaFisLoad("IT_MARGEM" ,NoRound(nValAcres*100,_nDec),_nLinha)  
					_nDec := TamSX3("D2_ALIQSOL")[2]
					MaFisLoad("IT_ALIQSOL" ,nAliqSol,_nLinha)  
				CASE (cNcm $ "32081010-32091010-32099011-32099019-38140090-32141010-32141020-35069190")
					nValAcres  := 0 //Sem MVA, decreto-MT 1355 de 04/09/12 ,art. 1º, III, § 4°-A-2, II
					nAliqSol := 25   
					_nDec := TamSX3("D2_BRICMS")[2]
					nBaseSubst := round(( (nQtdVen*nPrcVen)+ nFrete + nVlrIpi ) * ( 1 + nValAcres ),_nDec)
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
						nSomaVlr := ( aCols[_nLinha][nPosQTDVEN] * aCols[_nLinha][nPosPRCVEN]) + nFrete + nVlrIpi
						nValST := NOROUND(nSomaVlr*nCargaMedia/100,_nDec)
						_nDec := TamSX3("D2_BRICMS")[2]
						nBaseSubst := round( (nValIcm+nValST)/nAliqInt,_nDec)
						aAdd(aRetSol, nBaseSubst)
						aAdd(aRetSol, nValST )       
						_nDec := TamSX3("D2_MARGEM")[2] 
						nValAcres := 1- (nBaseSubst/nSomaVlr)
						MaFisLoad("IT_MARGEM" ,NoRound(nValAcres*100,_nDec),_nLinha)  
				  //	Endif
				
				ENDCASE 

				
			ELSE //If (SA1->A1_EST $ 'MT') .AND. (SA1->A1_CLAS = 'V')
			*/
				//Considerar FECP na aliq. icm int
				dbselectarea("CFC")
				dbsetorder(1)
				dbseek(xFilial("CFC")+cUforigem+SA1->A1_EST)
				if found()
					nAliqSol += CFC->CFC_ALQFCP
				endif 

				_nDec := TamSX3("D2_ALIQSOL")[2]
				MaFisLoad("IT_ALIQSOL" ,nAliqSol,PARAMIXB[1])  

				_nDec := TamSX3("D2_MARGEM")[2]     
				
				//(Cleber - 12/11/15 -> Nova aliquota de MVA para MG à partir de 01/12/15				
               	do case
            	case (SA1->A1_EST = "BA") .AND. !empty(cNcm) .AND. (cNcm = "32149000")
               		nMargemRef := 1.45 //Renata (24/08/2021)
                case (SA1->A1_EST = "MG") .AND. !empty(cNcm) .AND. !(cNcm = "32061119") .AND. ((substr(cNcm,1,4) $ "3208.3209.2821.3206") .OR. (cNcm = "321000") .OR. (cNcm = "32041700"))
					nMargemRef := 1.64                	
				//11/03/2016->Solic Fernando Mauri excluir esses mvas					          	
				//21/11/2016->Reunião com Fernando, volta situação anterior com exceção de MG. Apresentado PDF da Sitivesp com NCMs
                case (SA1->A1_EST = "MG") .AND. !empty(cNcm) .AND. ((substr(cNcm,1,4) $ "3204.3206.3212") .OR. (cNcm = "32050000"))
                //11/04/2017 -> Chamado 006914, Fernando Mauri
					nMargemRef := 1.6468                	
				case !(SA1->A1_EST $ "MG-AC-AM-TO-PE") .AND. ((substr(cNcm,1,4) $ "3204.3206.3212.2821") .OR. (cNcm = "32050000") )
					//À partir de 01/05/2019, chamado 013806
					do case
					case SA1->A1_EST $ "SP-RS"
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

						//Cleber(04/05/18) -> Ao atualizar patch Reinf está zerando base ST, FALHA DO PROTHEUS
						_nDec := TamSX3("D2_BRICMS")[2]   
    					if (nBaseSubst == 0.0) 
	    					nBaseSubst := round(( (nQtdVen*nPrcVen)+ MaFisRet(_nLinha,"IT_VALIPI")+MaFisRet(_nLinha,"IT_FRETE") ) * ( 1 + (nMva/100) ),_nDec)
	    				else
	    					nBaseSubst := round(nBaseSubst*(1+(nMva/100))/(1+(nMvaSist/100)),_nDec)
    					endif 
    					
					   	aAdd(aRetSol, nBaseSubst)
						_nDec := TamSX3("D2_ICMSRET")[2]
						nSt := ROUND((nBaseSubst*nAliqSol/100) - nValIcm,_nDec)
					  	aAdd(aRetSol, nSt )       
						MaFisLoad("IT_MARGEM" ,nMva,_nLinha)  
					ENDIF
				else
					//Cleber(23/02/17)->Lei específica de Goiás (Lei nº 11.651/91, art. 56) que majora a base do icms
					//Cleber(19/07/17)->Chamado 007723, Nadia solicitou mudança na regra da lei de Goiás
					//Cleber(28/12/17)->Chamado 009017, mudança à partir de 2018, considerar TODOS OS ESTADOS
					//IF (SA1->A1_EST = "GO") .AND. (SA1->A1_CLAS = 'C') .AND. (nBaseSubst > 0)
					//Cleber(04/05/18) -> Ao atualizar patch Reinf está zerando base ST, FALHA DO PROTHEUS
					_nDec := TamSX3("D2_BRICMS")[2]   
   					if (nBaseSubst == 0.0) 
    					nBaseSubst := round(( (nQtdVen*nPrcVen)+ MaFisRet(_nLinha,"IT_VALIPI")+MaFisRet(_nLinha,"IT_FRETE") ),_nDec)
    				endif 
					IF !(ALLTRIM(SA1->A1_EST) == ALLTRIM(GETMV("MV_ESTADO"))) .AND. (SA1->A1_CLAS = 'C') .AND. (nBaseSubst > 0)
		              	//nValIcm := MaFisRet(_nLinha,"IT_VALICM")
						_nDec := TamSX3("D2_BRICMS")[2]   
						nBaseSubst := round(nBaseSubst/(1-nAliqInt),_nDec)
						aAdd(aRetSol, nBaseSubst)
						_nDec := TamSX3("D2_ICMSRET")[2]
						aAdd(aRetSol, ROUND((nBaseSubst*(nAliqSol-nAliqICM)/100),_nDec) )       
					ENDIF 
				endif 					
				
	       // Endif // FIM If (SA1->A1_EST $ 'MT') .AND. (SA1->A1_CLAS = 'V') -> (Chamado 015949, MT mudou lei pra 01/01/20)
		Endif // fim if  (SF4->F4_INCSOL = "S")
U_VoltaArea(aArea)
if !empty(cArea)
	dbselectarea(cArea)
endif 
     Endif
Return(aRetSol)
