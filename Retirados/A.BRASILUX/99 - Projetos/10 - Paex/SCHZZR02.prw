#include "protheus.ch"
#include 'tbiconn.ch'
#include 'error.ch'
#include 'topconn.ch'                                                                                                                                                                                                                            
#INCLUDE "RWMAKE.CH"


/*/
+----------------------------------------------------------------------------+
| Função | SCHZZR002 | Autor |Tiago Lucio | www.chaus.com.br |Data 24/04/2014| 
+----------------------------------------------------------------------------+
| Descrição | Schedule para geração dos registros para a tabela ZZR das 	 |
|				Ordens de Produção não baixadas devido alguma ocorrencia.    |
|				A rotina executa a baixa de OPs (PAs) no fim da execução.	 |
|																			 |
|+---------------------------------------------------------------------------+
| Uso | SIGAPCP |															 |
|+---------------------------------------------------------------------------+
/*/                            


User Function SCHZZR02( _aParm )
     
     Local a_cFil       := {"010101","060101"}
     Local aParm        := Iif( ValType( _aParm ) == 'U', { "01", a_cFil, "2"}, _aParm )
     Local i
     //Local aParm        := Iif(ValType(aParm) == 'U', {"01", "010101", "2"}, aParm)
     Local cEmp         := Alltrim(Transform(aParm[1],'@!'))
     //Local cFil         := Alltrim(Transform(aParm[2],'@!'))
     Local nOpc         := Alltrim(Transform(aParm[3],'@!'))
     Local cAuxMens     := ""
     Private lEndThread
     //LGS#20200210 - Adequação de release 12.1.25 e posteriores
     //ConOut("***********************************************")
     //ConOut("*  SCHZZR002 - BAIXA AUTOMATICA DE PA         *")
     //ConOut("***********************************************")
     cAuxMens += "***********************************************" + CHR(13) + CHR(10)
     cAuxMens += "*  SCHZZR002 - BAIXA AUTOMATICA DE PA         *" + CHR(13) + CHR(10)
     cAuxMens += "***********************************************"
     FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', cAuxMens, 0 )

     // RPCSetType(3)  // Nao utilizar licenca  Retirado pois causa erro ao rodar manual e trocar de módulo
    // bErro := {|e| SCHZZR(e, nOpc)} //Tratamento dos erros cometidos
     lEndThread := .f.
     //RpcMyErro()
    // ErrorBlock(bErro)
     
     If nOpc == '1'
        For i:= 1 to Len(a_cFil)
	       	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL a_cFil[i] TABLES "SB1", "SC2", "SD3", "SD4", "SH6", "SX6"
	        If a_cFil[i] == '010101'
		        //LGS#20200210 - Adequação de release 12.1.25 e posteriores
		        //ConOut("-- INICIO")
		        FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', "-- INICIO", 0 )
    		        U_SCHZZR2(nOpc, cEmp, a_cFil[i]) //Faz o processamento das gerações das ordens de produção
	            //LGS#20200210 - Adequação de release 12.1.25 e posteriores
	            //ConOut("-- FIM")
	            FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', "-- FIM", 0 )
			Endif
	        RESET ENVIRONMENT
		Next i
     Else
     	If cFilAnt == '010101'
	    	Processa( { |lEnd| U_SCHZZR2(nOpc, cEmp, cFilAnt ) }, "Baixa automatica de OPs (PA)", ,.t.) //Faz o processamento das baixas das ordens de produção
        Endif
     Endif
Return(Nil)

User Function SCHZZR2(nOpc, cEmp, cFil)
      
Local cQuery,cQuery1,cQuery2 
Local nQuant                                                                                          
Local nSaldoB2
//Local nFlagSaldo	:= 0  // Flag indicando se acho saldo em outro armazem
Local aVetor 		:= {} 
Local lAltaprop		:=.F.
Local aSaldos 		:= {}
//PRIVATE cCusMed  	:= ""
PRIVATE aRegSD3  	:= {} 

If !Len(Alltrim(GetMv("MV_BXMANEW"))) >1
//Validação para sobra de PI no processo de produção
    
	cQuery:=" SELECT DISTINCT C2_LOTE FROM "+RetSQlName("SC2")+" SC2  WITH (NOLOCK) "
	cQuery+=" LEFT OUTER JOIN "+RetSQlName("ZZA")+" ZZA WITH (NOLOCK) ON C2_FILIAL = ZZA_FILIAL AND C2_LOTE = ZZA_LOTE AND C2_OP = ZZA_ORDEM AND ZZA.D_E_L_E_T_ ='' "
	cQuery+=" LEFT OUTER JOIN "+RetSQlName("SB1")+" SB1 WITH (NOLOCK) ON C2_FILIAL =  B1_FILIAL AND C2_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ ='' "
	cQuery+=" WHERE SC2.D_E_L_E_T_ ='' AND C2_FILIAL ='"+xFilial("SC2")+"' AND B1_TIPO ='PI' AND SUBSTRING(C2_PRODUTO,11,2)='00' "
	cQuery+=" AND ZZA_SP ='' AND ZZA_SOBRA =0 AND ZZA_PERDA =0 AND C2_DATRF <>''"
	cQuery+=" AND ZZA_FLAG ='5' AND C2_DATRF >'"+DTOS(GetMV("MV_ULMES "))+"'
	cQuery+=" AND C2_LOTE NOT IN (SELECT ZZR_LOTE FROM "+RetSQlName("ZZR")+" ZZR  WITH (NOLOCK) WHERE ZZR_FILIAL ='"+xFilial("ZZR")+"' AND ZZR.D_E_L_E_T_='' AND ZZR_TIPO='PA') "
	cQuery+=" AND (SELECT COUNT(ZZA1.ZZA_PRODUT)  FROM "+RetSQlName("ZZA")+" ZZA1 WITH (NOLOCK) WHERE ZZA1.ZZA_FILIAL ='"+xFilial("ZZA")+"' AND ZZA1.D_E_L_E_T_ = '' "
	cQuery+=" AND SUBSTRING(ZZA1.ZZA_PRODUT, 1, 10) = SUBSTRING(ZZA.ZZA_PRODUT, 1, 10) AND ZZA1.ZZA_LOTE = ZZA.ZZA_LOTE AND ZZA1.ZZA_FLAG <>'6' AND ZZA1.ZZA_QUANT >0 AND SUBSTRING(ZZA1.ZZA_PRODUT, 11, 2) <> '00') >0  "
	cQuery+=" ORDER BY C2_LOTE "

	IF (Select("TMPPA") > 0 )
		TMPPA->(DbCloseArea())
	EndIf
	TCQuery cQuery  ALIAS "TMPPA" NEW
	
	While !(TMPPA->(eof()))
		ValidaSobr(TMPPA->C2_LOTE)	
		TMPPA->(dbSkip())
	EndDo

	//Valida roubo de saldo
	cQuery2:= " SELECT ZZA_ORDEM, ZZA_PRODUT, ZZA_LOTE FROM "+RetSQlName("ZZA")+" WHERE ZZA_GEROCO ='1' AND ZZA_FILIAL='"+xFilial("ZZA")+"' AND D_E_L_E_T_='' "
	
	IF (Select("TMPPA") > 0 )
   		TMPPA->(DbCloseArea())
	EndIf
	
	TCQuery cQuery2  ALIAS "TMPPA" NEW
	While !(TMPPA->(eof()))
		ValidRoubo(TMPPA->ZZA_ORDEM,TMPPA->ZZA_PRODUT,TMPPA->ZZA_LOTE)	
		TMPPA->(dbSkip())
	EndDo

    /*
	//Validação para falta de PI no processo de produção
	cQuery:= "	SELECT DISTINCT ZZA_LOTE  "
	cQuery+= "	FROM "+RetSQlName("ZZA")+" ZZA WITH(NOLOCK) "
	cQuery+= "  INNER JOIN "+RetSQlName("SB1")+" SB1 WITH(NOLOCK) ON ZZA_FILIAL = B1_FILIAL AND ZZA_PRODUT = B1_COD AND ZZA.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
	cQuery+= "	WHERE ZZA_FLAG IN ('4','8','7')  "
	cQuery+= "	AND ZZA.D_E_L_E_T_='' AND ZZA_FILIAL='"+xFilial("ZZA")+"' "
	cQuery+= "	AND ZZA_ORDEM NOT IN (SELECT ZZR_OP FROM ZZR010 ZZR WHERE ZZR_FILIAL='"+xFilial("ZZR")+"' AND ZZR.D_E_L_E_T_='' )  AND ZZA_QUANT >0 "
	cQuery+= "	AND LEN(B1_COD)=12 AND B1_TIPO='PA' AND ZZA_CAMPO <>'' "
	cQuery+= "	ORDER BY  ZZA_LOTE "
	*/
	IF (Select("TMPPA") > 0 )
   		TMPPA->(DbCloseArea())
	EndIf
	
	TCQuery cQuery  ALIAS "TMPPA" NEW

	While !(TMPPA->(eof()))
		ValidaFalt(TMPPA->C2_LOTE)
		TMPPA->(dbSkip())
	EndDo

	cQuery:="  		SELECT ZZA.ZZA_ORDEM, ZZA.ZZA_LOTE,	ZZA.ZZA_PRODUT, SB1.B1_TIPO, SB1.B1_UM,	SB1.B1_APROPRI,	"
	cQuery+="		ZZA.ZZA_QUANT,	SC2.C2_QUANT, SC2.C2_QUJE, ZZA.ZZA_DTINI, ZZA.ZZA_HINI,	ZZA.ZZA_DTFIM, ZZA.ZZA_HFIM,	"
	cQuery+="		ZZA.ZZA_HELP,	"                     //Se Primeiro Digito for "1" Baixa OP do Almx 02 , caso contrario Gera produto no "20"
	cQuery+="		COUNT(ZZF.ZZF_ORDEM) AS QTDZZF, "   //Quantidade de materias primas que foram baixadas. Se maior que zero tem quantidade pendente.
	cQuery+="		ZZA.R_E_C_N_O_, SC2.C2_ROTEIRO,	SC2.C2_LOCAL, C2_NUM+C2_ITEM+C2_SEQUEN AS C2_OP	"
	cQuery+="		FROM "+RetSQlName("ZZA")+" ZZA WITH (NOLOCK) INNER JOIN "+RetSQlName("SB1")+" SB1 ON ZZA_FILIAL = SB1.B1_FILIAL AND ZZA.ZZA_PRODUT = SB1.B1_COD AND ZZA.D_E_L_E_T_= SB1.D_E_L_E_T_  "
	cQuery+="		LEFT OUTER JOIN "+RetSQlName("ZZF")+" ZZF WITH (NOLOCK) ON ZZF.ZZF_FILIAL = ZZA.ZZA_FILIAL AND ZZF.ZZF_ORDEM = ZZA.ZZA_ORDEM AND ZZF.D_E_L_E_T_ = '' "
	cQuery+="		LEFT OUTER JOIN "+RetSQlName("SC2")+" SC2 WITH (NOLOCK) ON SC2.C2_FILIAL = ZZA.ZZA_FILIAL AND SC2.C2_OP = ZZA.ZZA_ORDEM AND SC2.D_E_L_E_T_ = ''   "
	cQuery+="		WHERE ZZA.ZZA_FILIAL = '"+xFIlial('ZZA')+"' "	
	cQuery+="		AND ZZA.D_E_L_E_T_ = '' AND ZZA.ZZA_FLAG  IN ('4','7','8')	 AND ZZA_CAMPO <>''  AND  B1_TIPO='PA' "
	//cQuery+="		AND SC2.C2_QUJE=0 	" - SO BAIXA OP QUE NÃO FOI BAIXADA PARCIALMENTE - RETIRADO EM 22/08/14
	cQuery+="		GROUP BY ZZA.ZZA_ORDEM, ZZA.ZZA_LOTE, ZZA.ZZA_PRODUT, SB1.B1_TIPO,SB1.B1_UM,SB1.B1_APROPRI, ZZA.ZZA_QUANT, ZZA.ZZA_DTINI, ZZA.ZZA_HINI, ZZA.ZZA_DTFIM, ZZA.ZZA_HFIM, ZZA.ZZA_HELP, ZZA.R_E_C_N_O_, SC2.C2_QUANT, SC2.C2_QUJE,SC2.C2_ROTEIRO, SC2.C2_LOCAL, C2_NUM+C2_ITEM+C2_SEQUEN " 	
	cQuery+="		ORDER BY QTDZZF,ZZA_DTINI,ZZA_HINI  "
	  
	              
	cQuery1="		SELECT DISTINCT B2_COD, B2_LOCAL, B2_QATU AS B2_QATU		"
	cQuery1+="		FROM "+RetSQlName("ZZA")+" ZZA WITH (NOLOCK) INNER JOIN SB1010 SB1 ON ZZA_FILIAL = SB1.B1_FILIAL AND ZZA.ZZA_PRODUT = SB1.B1_COD AND ZZA.D_E_L_E_T_= SB1.D_E_L_E_T_  		"								  
	cQuery1+="		LEFT OUTER JOIN "+RetSQlName("ZZF")+" ZZF WITH (NOLOCK) ON ZZF.ZZF_FILIAL = ZZA.ZZA_FILIAL AND ZZF.ZZF_ORDEM = ZZA.ZZA_ORDEM AND ZZF.D_E_L_E_T_ = ''		"							  
	cQuery1+="		LEFT OUTER JOIN "+RetSQlName("SC2")+" SC2 WITH (NOLOCK) ON SC2.C2_FILIAL = ZZA.ZZA_FILIAL AND SC2.C2_OP = ZZA.ZZA_ORDEM AND SC2.D_E_L_E_T_ = ''   "
	cQuery1+="		INNER JOIN "+RetSQlName("SD4")+" SD4 WITH (NOLOCK) ON ZZA.ZZA_FILIAL = SD4.D4_FILIAL AND ZZA.ZZA_ORDEM = SD4.D4_OP AND  ZZA.D_E_L_E_T_ =  SD4.D_E_L_E_T_ "
	cQuery1+="		INNER JOIN "+RetSQlName("SB2")+" SB2 WITH (NOLOCK) ON SD4.D4_FILIAL = SB2.B2_FILIAL AND  SD4.D4_COD = SB2.B2_COD AND SD4.D4_LOCAL = SB2.B2_LOCAL AND SD4.D_E_L_E_T_ =  SB2.D_E_L_E_T_ 	"
	cQuery1+="		WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' 	"		
	cQuery1+="		AND ZZA.D_E_L_E_T_ = '' 	   "     
	cQuery1+="		AND ZZA.ZZA_FLAG  IN ('4','7','8')	AND ZZA_CAMPO <>'' AND  B1_TIPO='PA' "
	//cQuery1+="		AND SC2.C2_QUJE=0 	"  - SO BAIXA OP QUE NÃO FOI BAIXADA PARCIALMENTE - RETIRADO EM 22/08/14
	
	IF (Select("TMPSB2") > 0 )
		TMPSB2->(DbCloseArea())
	EndIf

	TCQuery cQuery1  ALIAS "TMPSB2" NEW

	While !(TMPSB2->(eof()))
		Aadd(aSaldos,{TMPSB2->B2_COD,TMPSB2->B2_LOCAL,TMPSB2->B2_QATU}) //monta o array com os saldos do SB2 antes de executar o processamento
		TMPSB2->(dbSkip())
	Enddo

	IF (Select("TMPZZR") > 0 )
		TMPZZR->(DbCloseArea())
	EndIf

	TCQuery cQuery  ALIAS "TMPZZR" NEW
	dbselectarea("TMPZZR")
	dbgotop()       

	While !(TMPZZR->(eof()))
 		cLocal:=locItem(TMPZZR->C2_LOCAL,SB1->B1_TIPO,SB1->B1_APROPRI)
   		dbselectarea("SD4")	
 		SD4->(dbSetOrder(2)) //D4_FILIAL+D4_OP+D4_COD+D4_LOCAL    
   		SD4->(dbSeek(xFilial("SD4")+Trim(TMPZZR->ZZA_ORDEM))) 
   		
   		While !(SD4->(Eof())).And. xFilial("SD4")==SD4->D4_FILIAL .And. Trim(TMPZZR->ZZA_ORDEM)==Trim(SD4->D4_OP)   //Varre os itens empenhados da SD4
   			IncProc( "Processando OP : "+ Trim(TMPZZR->ZZA_ORDEM))  
   		   	dbSelectArea("ZZF")
   		    ZZF->(dbSetOrder(4))		//  ZZF_FILIAL, ZZF_ORDEM, ZZF_CODIGO, ZZF_TRT, R_E_C_N_O_, D_E_L_E_T_
   		    ZZF->(dbSeek(xFilial("ZZF")+Trim(SD4->D4_OP)+(SD4->D4_COD)+Trim(SD4->D4_TRT)))
   		    	
   		    IF !(ZZF->(eof())) .AND. (ZZF->ZZF_FILIAL = xFilial("ZZF")) .AND. (Trim(ZZF->ZZF_ORDEM) = Trim(SD4->D4_OP)) .AND. (Trim(ZZF->ZZF_CODIGO) =Trim(SD4->D4_COD))
   		    	nQuant	:= round(ZZF->ZZF_QTDUSA,4)
   		    Else
   		    	nQuant	:= round(SD4->D4_QUANT,4)
   		    EndIf
        	
            nPos := aScanX( aSaldos, { |X,Y| X[1] == SD4->D4_COD .And.  X[2] == SD4->D4_LOCAL})
             
            If aSaldos[nPos][3] < nQuant
				//nSaldoB2 :=	IIF(aSaldos[nPos][3] <0, (Abs(aSaldos[nPos][3]) + (nQuant * 2 )), aSaldos[nPos][3]) 
				nSaldoB2 :=	IIF(aSaldos[nPos][3] <0, (Abs(aSaldos[nPos][3]) + (nQuant * 2)), aSaldos[nPos][3]) 
   			    //nSaldoB2 :=	SB2->B2_QATU  
		        nDocumento:=  NextNumero("SD3",2,"D3_DOC",.T.)   //Gera o proximo numero de documento
	               	  		
				lAltaprop:=.F.		               		   			
		            
		        dBselectArea("SB1")
		        dbSetOrder(1)   
		        SB1->(dbSeek(xFilial("SB1")+SD4->D4_COD+SD4->D4_LOCAL))
		        cTipo:= SB1->B1_TIPO
		               		   			
		        If (SB1->B1_TIPO $ 'MP.PA')   
			      	If (SB1->B1_TIPO == 'MP') .AND. (SB1->B1_APROPRI=='I')
			          	BEGIN TRANSACTION
			            	If SB1->(Found())
					        	RecLock("SB1",.F.)
					            	SB1->B1_APROPRI:='D'
					            MsUnLock()
					         ENDIF	
			           	END TRANSACTION
						lAltaprop:=.T.
					EndIf	
			        nQuant := ABS(nQuant - nSaldoB2)       		  		
			        aVetor := {}
			        aVetor := { {"D3_FILIAL" 	, xFilial("SD3")					, NIL},;
			                    {"D3_TM"     	, "110"         	   				, NIL},;  //Falta de produção
			          			{"D3_COD"    	, SD4->D4_COD   					, NIL},;
			                    {"D3_LOCAL"  	, IIF(SD4->D4_LOCAL=='99',locItemInd(TMPZZR->C2_LOCAL,SB1->B1_TIPO,SB1->B1_APROPRI),SD4->D4_LOCAL), NIL},;
			                    {"D3_EMISSAO"	, DATE()        	   				, NIL},;   
			                    {"D3_DOC"    	, nDocumento    	 				, NIL},;
			                    {"D3_UM"     	, SB1->B1_UM    	   				, NIL},;
			                    {"D3_TURNO"  	, 'ZZR21'    	 					, NIL},;
			                    {"D3_OBS"    	, Trim(SD4->D4_OP)	 		 		, NIL},;
			                    {"D3_QUANT"  	, nQuant						 	, NIL} } 
			                      
			            lMsErroAuto:=.f.      
			            MSExecAuto({|x,y| MATA240(x, y)}, aVetor, 3) 
			                                
				        If lMsErroAuto
			              	mostraerro() 
						Else    
			                cClass	:=""    //classificação feita pelo usuario
		               		cFlag 	:="M"   //Flag do tipo de correçaõ feita pelo sistema
		               	 	cCor  	:="1"   //corrigida pelo sistema      
		               	 	cDescr	:=""
			                If SD4->D4_LOCAL	=='99' //Se o armazem for igual a 99 é preciso fazer a transferencia
			                	If a260Processa(SD4->D4_COD,locItemInd(TMPZZR->C2_LOCAL,SB1->B1_TIPO,SB1->B1_APROPRI),nQuant  ,nDocumento,DATE(),,,,,,,SD4->D4_COD,SD4->D4_LOCAL,,,,,,,,,,,,,,,,,,,,,,)
			               			GravaZZR(TMPZZR->ZZA_ORDEM, TMPZZR->C2_LOCAL,TMPZZR->ZZA_PRODUT,TMPZZR->ZZA_LOTE,cClass, cDescr,nDocumento,SD4->D4_COD,SD4->D4_LOCAL,nQuant,cCor,cFlag,IIF(LEN(TMPZZR->ZZA_PRODUT)<12,'PI',IIF(SUBSTR(TMPZZR->ZZA_PRODUT,11,2)=='00','PI','PA')))  //inclui o registro da ZZR
			               		EndIf	
			                Else 
			                	GravaZZR(TMPZZR->ZZA_ORDEM, TMPZZR->C2_LOCAL,TMPZZR->ZZA_PRODUT,TMPZZR->ZZA_LOTE,cClass, cDescr,nDocumento,SD4->D4_COD,SD4->D4_LOCAL,nQuant,cCor,cFlag,IIF(LEN(TMPZZR->ZZA_PRODUT)<12,'PI',IIF(SUBSTR(TMPZZR->ZZA_PRODUT,11,2)=='00','PI','PA')))  //inclui o registro da ZZR
			               	EndIf
			            EndIf
			    	EndIf
			                                 
				   	dBselectArea("SB1")   
				   	SB1->(dbSeek(xFilial("SB1")+SD4->D4_COD+SD4->D4_LOCAL))
					dbSetOrder(1)		
					If SB1->B1_APROPRI=='D' .And. lAltaprop
				  		IF SB1->(Found())
							BEGIN TRANSACTION
						    	RecLock("SB1",.F.)
						        	SB1->B1_APROPRI:='I'
						        MsUnLock()
								lAltaprop:=.F.
						  	END TRANSACTION
						ENDIF    
					EndIf		                             
       			EndIf
			SD4->(DbSkip())
   	    EndDo
  		TMPZZR->(DbSkip())
	EndDo

Endif

Return   

/*/
+-------------------------------------------------------------------------------+
| Função | AliasTMPSG  | Autor |Tiago Lucio | www.chaus.com.br |Data 24/04/2014 |
+-------------------------------------------------------------------------------+
| Descrição | Função estatica para criar a consulta da SG1 para calcular  	   |
|				a quantidade a ser produzida de cada item de acordo a estrutura   |
|				daquele produto. A quantida da OPs e o codigo do produto são	   |
|				passadas por parametro.											       |
|																				          |
|																				    	   |
|+------------------------------------------------------------------------------+
| Uso | SIGAPCP |																	       |
|+------------------------------------------------------------------------------+
/*/                            
/*
Static Function AliasTMPSG(_quantPrd,_produto,_comp)

private cQuery:=""

cQuery+="	SELECT G1_FILIAL, "	
cQuery+="	G1_COD, "
cQuery+="	B1_QB, "	   
cQuery+="	ROUND("+Str(_quantPrd)+" * B1_QB,2) AS QTB_BASE, "
cQuery+="	G1_COMP, "	   
cQuery+="	G1_QUANT, "		
cQuery+="	ROUND(G1_QUANT * "+Str(_quantPrd)+",2)  AS QTD_COMP_SEM_PERDA, "
cQuery+="	ROUND(((G1_QUANT * "+Str(_quantPrd)+") /(100-G1_PERDA))*100,2)  AS QTD_COMP_COM_PERDA,  " 
cQuery+="	G1_PERDA, "
cQuery+="	G1_INI, " 
cQuery+="	G1_FIM, "
cQuery+="	G1_FIXVAR "
cQuery+="	FROM "+RetSQlName("SG1")+" SG1  WITH (NOLOCK) INNER JOIN "+RetSQlName("SB1")+" SB1  WITH (NOLOCK)  ON SG1.G1_FILIAL = SB1.B1_FILIAL AND SG1.G1_COD = SB1.B1_COD AND SG1.D_E_L_E_T_ = SB1.D_E_L_E_T_
cQuery+="	WHERE SG1.D_E_L_E_T_ = ' ' "
cQuery+="		AND G1_FILIAL 	= '"+xFilial("SG1")+"' "
cQuery+="		AND G1_COD 		= '"+TRIM(_produto)+"' "
cQuery+="		AND G1_COMP		= '"+TRIM(_comp)+"' "


// CLOSE QUERY "TMPSG1" //Fecha alias se estiver aberto 
IF (Select("TMPSG1") > 0 )
   TMPSG1->(DbCloseArea())
EndIf
    

TCQuery cQuery ALIAS "TMPSG1" NEW


Return */


/*/
+-------------------------------------------------------------------------------+
| Função | locItem	  | Autor |Tiago Lucio | www.chaus.com.br |Data 24/04/2014  |
+-------------------------------------------------------------------------------+
| Descrição | Função estatica para localizar o local do item da OP de acordo    | 
|				regra Brasilux para fabricas 1 e 2							    |
|																			    |
|																			    |
|+------------------------------------------------------------------------------+
| Uso | SIGAPCP |															    |
|+------------------------------------------------------------------------------+
/*/             


Static Function LocItem(_localOp,_tipoItem,_apropItem)
   
Private cRetorno:=""
	If TRIM(_localOp)=='02'  
    	If  TRIM(_tipoItem)=='MP' 
        	If  TRIM(_apropItem)=='I'   //MP de apropriação indireta
            	cRetorno := '99' 
            Else
            	cRetorno := '01' 
            EndIf	
        ElseIf TRIM(_tipoItem)=='PI'
        	cRetorno := '02'
        EndIf
	ElseIf TRIM(_localOp)=='20'  
		If  TRIM(_tipoItem)=='MP'
        	If  TRIM(_apropItem)=='I'     //MP de apropriação indireta
  				cRetorno := '99' 
      		Else
        		cRetorno := '10' 
        	EndIf
        ElseIf TRIM(_tipoItem)=='PI'
        	cRetorno := '20'
        EndIf    
  	ElseIf TRIM(_localOp)$ '03.P1'  //Empenho de MP de Ordem de Envase  fabrica 1
   		If  TRIM(_tipoItem)=='MP'
     		cRetorno := '01'
     	ElseIf TRIM(SB1->B1_TIPO)=='PI'
      		cRetorno := '02'
        ElseIf TRIM(_tipoItem)=='PA'
			cRetorno := Alltrim(_localOp)        
        EndIf
    ElseIf TRIM(_localOp)=='30.P2'  //Empenho de MP de Ordem de Envase  fabrica 2
    	If  TRIM(_tipoItem)=='MP'
     		cRetorno := '10'
       	ElseIf TRIM(_tipoItem)=='PI'
        	cRetorno := '20'
        ElseIf TRIM(_tipoItem)=='PA'
			cRetorno := Alltirm(_localOp)       
        EndIf
        
    EndIf		

Return cRetorno 

/*/
+-----------------------------------------------------------------------------------+
| Função | locItemIndi  | Autor |Tiago Lucio | www.chaus.com.br |Data 24/04/2014    |
+-----------------------------------------------------------------------------------+
| Descrição | Função estatica para localizar o local do item da OP de acordo	 	    | 
|				regra Brasilux para fabricas 1 e 2	para não jogar o saldo         	    |
|				do produto no armazem 99 para movimentação				              |
|																				    	       |
|+----------------------------------------------------------------------------------+
| Uso | SIGAPCP |																	       	|
|+----------------------------------------------------------------------------------+
/*/             


Static Function locItemInd(_localOp,_tipoItem,_apropItem)
   
Private cRetorno:=""
	If TRIM(_localOp)=='02'  
    	If  TRIM(_tipoItem)=='MP' 
			cRetorno := '01' 
		ElseIf TRIM(_tipoItem)=='PI'
			cRetorno := '02'
		EndIf

  	ElseIf TRIM(_localOp)=='20'  
   		If  TRIM(_tipoItem)=='MP' 
     		cRetorno := '10' 
       	ElseIf TRIM(_tipoItem)=='PI'
        	cRetorno := '20'
        EndIf    

	ElseIf TRIM(_localOp) $ '03.P1'  //Empenho de MP de Ordem de Envase  fabrica 1
		If  TRIM(_tipoItem)=='MP'
  			cRetorno := '01'
		ElseIf TRIM(SB1->B1_TIPO)=='PI'
			cRetorno := '02'
		EndIf	

	ElseIf TRIM(_localOp) $ '30.P2'  //Empenho de MP de Ordem de Envase  fabrica 2
		If  TRIM(_tipoItem)=='MP'
			cRetorno := '10'
		ElseIf TRIM(_tipoItem)=='PI'
			cRetorno := '20'
		EndIf
	EndIf		

Return cRetorno 
 

/*
  Localiza o local do item da OP de acordo regra Brasilux para fabricas 1 e 2
*/


/*/
+-------------------------------------------------------------------------------+
| Função | GravaZZR | Autor |Tiago Lucio | www.chaus.com.br |Data 24/04/2014    |
+-------------------------------------------------------------------------------+
| Descrição | Função estatica gravar dados na tabela ZZR						   | 
|																					       |
|																				          |
|																				    	   |
|+------------------------------------------------------------------------------+
| Uso | SIGAPCP |																	       |
|+------------------------------------------------------------------------------+
/*/
 
Static Function GravaZZR(cOP, cLocal,cProduto,cLote,cClass, cDescr,cDoc,cItem,cLocItem,nQuant,cCor,cFlag,cTipo)

	DbSelectArea("ZZR")
	RecLock("ZZR",.T.)
		ZZR->ZZR_FILIAL 	:= xFilial("ZZR") 
		ZZR->ZZR_OP 		:= cOP
		ZZR->ZZR_PRODUTO 	:= cProduto
		ZZR->ZZR_LOCAL 		:= cLocal  
		ZZR->ZZR_LOTE 		:= cLote    
		ZZR->ZZR_CLASSI		:= cClass     
		//ZZR->ZZR_DESCRI:=cDescr     
		ZZR->ZZR_DOC 		:= cDoc
		ZZR->ZZR_ITEM 		:= cItem
		ZZR->ZZR_LOCPROD 	:= cLocItem     
		ZZR->ZZR_QUANT 		:= nQuant
		ZZR->ZZR_COR 		:= cCor    
		ZZR->ZZR_FLAG 		:= cFlag      
		ZZR->ZZR_TIPO 		:= cTipo   
	MsUnLock() // Confirma e finaliza a operação


Return   

Static Function ValidaFalt(cLote)
//Local nI
Local nDocumento:=  NextNumero("SD3",2,"D3_DOC",.T.)   //Gera o proximo numero de documento
Local SomaPI  :=0
Local SomaPA  :=0
Local aArray  :={}
//Local lTotal  :=.F.
//Local lApontPA:= .T.
Local aSaldos :={}
Local cOP     :=""
Local cNumOp  :=""
Local aPa     :={}
Local cont:=0
Local nX


cQuery1:="	SELECT B2_COD, B2_LOCAL, B2_QATU "
cQuery1+="	FROM "+RetSQlName("SC2")+" SC2 WITH (NOLOCK) " 
cQuery1+="	INNER JOIN "+RetSQlName("SB1")+" SB1 WITH (NOLOCK) ON SC2.C2_FILIAL= SB1.B1_FILIAL  AND C2_PRODUTO = B1_COD AND SC2.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
cQuery1+="	INNER JOIN "+RetSQlName("ZZA")+" ZZA  WITH (NOLOCK) ON SC2.C2_FILIAL=ZZA_FILIAL AND SC2.C2_OP = ZZA_ORDEM AND SC2.D_E_L_E_T_ = ZZA.D_E_L_E_T_ "
cQuery1+="  INNER JOIN "+RetSQlName("SB2")+"  SB2 WITH (NOLOCK) ON SC2.C2_PRODUTO = B2_COD AND SC2.C2_LOCAL = B2_LOCAL AND SC2.D_E_L_E_T_ = SB2.D_E_L_E_T_ "
cQuery1+="	WHERE C2_FILIAL='"+xFilial("SC2")+"' AND SC2.D_E_L_E_T_='' AND C2_LOTE='"+TRIM(cLote)+"' AND C2_DATPRF<>''  "
cQuery1+="  GROUP BY B2_COD, B2_LOCAL, B2_QATU "

IF (Select("TMPSB2") > 0 )
	TMPSB2->(DbCloseArea())
EndIf

TCQuery cQuery1  ALIAS "TMPSB2" NEW

While !(TMPSB2->(eof()))
	Aadd(aSaldos,{TMPSB2->B2_COD,TMPSB2->B2_LOCAL,TMPSB2->B2_QATU}) //monta o array com os saldos do SB2 antes de executar o processamento
	TMPSB2->(dbSkip())
Enddo

//Verifica OPs encerradas que possui falta saldo após a finalização 

//cQuery:=" SELECT DISTINCT B1_CONV,C2_QUANT,C2_QUJE, (B1_CONV * ZZA_QUANT) QTDETOTAL, SB1.B1_TIPO, SC2.C2_OP,SC2.C2_LOCAL, SC2.C2_PRODUTO, SC2.C2_LOTE, SB1.B1_TIPO, B1_UM "
cQuery:=" SELECT DISTINCT B1_CONV, SUM(ZZA_QUANT) AS C2_QUANT,SUM(C2_QUJE) AS C2_QUJE, (B1_CONV * SUM(ZZA_QUANT)) AS QTDETOTAL, SB1.B1_TIPO, SC2.C2_OP,SC2.C2_LOCAL, SC2.C2_PRODUTO, SC2.C2_LOTE, SB1.B1_TIPO, B1_UM	"
cQuery+=" FROM "+RetSQlName("SC2")+" SC2 WITH (NOLOCK) " 
cQuery+=" INNER JOIN "+RetSQlName("SB1")+" SB1 WITH (NOLOCK) ON SC2.C2_FILIAL = SB1.B1_FILIAL  AND C2_PRODUTO = B1_COD AND SC2.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
cQuery+=" INNER JOIN "+RetSQlName("ZZA")+" ZZA WITH (NOLOCK) ON SC2.C2_FILIAL = ZZA_FILIAL AND SC2.C2_OP = ZZA_ORDEM AND SC2.D_E_L_E_T_ = ZZA.D_E_L_E_T_ "
cQuery+=" WHERE C2_FILIAL='"+xFilial("SC2")+"' AND SC2.D_E_L_E_T_='' AND C2_LOTE='"+TRIM(cLote)+"'"
cQuery+=" GROUP BY B1_TIPO, C2_OP, C2_PRODUTO, C2_LOTE, B1_UM, B1_CONV, C2_LOCAL "
cQuery+=" ORDER BY SC2.C2_OP"

IF (Select("TMPZZR") > 0 )
   TMPZZR->(DbCloseArea())
EndIf

TCQuery cQuery ALIAS "TMPZZR" NEW

While !(TMPZZR->(eof()))
	Cont+=1
	If TMPZZR->B1_TIPO=='PI'
		IncProc( "Processando OP (pi) : "+ Trim(TMPZZR->C2_OP)) 
		/* dbSelectArea("SH6") //verifica se PI foi apontado totalmente
		SH6->(dbSetOrder(1))	//H6_FILIAL, H6_OP, H6_PRODUTO, H6_OPERAC, H6_SEQ, H6_DATAINI, H6_HORAINI, H6_DATAFIN, H6_HORAFIN, R_E_C_N_O_, D_E_L_E_T_
		SH6->(dbSeek(xFilial("SH6")+TMPZZR->C2_OP))
		
		While !(SH6->(eof())) .And. Trim(TMPZZR->C2_OP) == Trim(SH6->H6_OP)
		
			If SH6->H6_PT=='T'
				lTotal:=.T.
			EndIf	
			SH6->(dbSkip())
		EndDo
		*/
		SomaPI  += TMPZZR->C2_QUJE
		cItem   := TMPZZR->C2_PRODUTO
		cLocItem:= TMPZZR->C2_LOCAL
		nQuant  := TMPZZR->C2_QUANT
		cUni    := TMPZZR->B1_UM
		cNumOp  := TMPZZR->C2_OP
	
	ElseIf TMPZZR->B1_TIPO=='PA'
		
	    SomaPA  += QTDETOTAL
		//SomaPA+=(IIF(TMPZZR->C2_QUJE==0,TMPZZR->C2_QUANT*TMPZZR->B1_CONV,TMPZZR->QTDETOTAL)) //se ja foi baixado pega da C2_QUJE senão pega da  C2_QUANT 
		cOp 	:=TMPZZR->C2_OP
		cLocal  :=TMPZZR->C2_LOCAL
		cProdut :=TMPZZR->C2_PRODUTO
		clote   :=TMPZZR->C2_LOTE
		cTipo   := TMPZZR->B1_TIPO
		aAdd(aPa,{cOp,cLocal,cProdut,clote,cTipo})
	EndIf
	
	TMPZZR->(dbSkip())
EndDo
	
	aArray:=VldRegrPA(SomaPA,SomaPI)
	nPos := aScanX( aSaldos, { |X,Y| X[1] == citem .And.  X[2] == cLocItem})
	nSaldo:= aSaldos[nPos][3] 
	
	If SomaPA>SomaPI .AND. Cont> 1 .AND. LEN(Alltrim(cNumOp))>1   //Falta saldo do PI

		If  aArray[1]  //Se verdadeiro não é ocorrencia, baixa automaticamente
			aVetor := {}
		//	nDocumento:=  NextNumero("SD3",2,"D3_DOC",.T.)   //Gera o proximo numero de documento
	  		aVetor := { {"D3_FILIAL" , xFilial("SD3")		, NIL},;
	           			{"D3_TM"     , "110"         		, NIL},;  //Falta de produção
	           			{"D3_COD"    , cItem  		 		, NIL},;
	               		{"D3_LOCAL"  , cLocItem		 		, NIL},;
	                   	{"D3_EMISSAO", DATE()  		 		, NIL},;   
	                   	{"D3_DOC"	 , nDocumento  	 		, NIL},;
	                   	{"D3_UM"	 , cUni  		 		, NIL},;
	                    {"D3_TURNO"  , 'ZZR22'		 		, NIL},;
           	        	{"D3_OBS"    , Alltrim(cNumOp)		, NIL},;                                               
	                   	{"D3_QUANT"  , Abs(SomaPA-SomaPI)	, NIL} }   
	        lMsErroAuto:=.f.      
	        MSExecAuto({|x,y| MATA240(x, y)}, aVetor, 3) 
	                                
		    If lMsErroAuto
               	Mostraerro()
	        Else
				dbSelectArea("ZZA")
				ZZA->(dbSetorder(2))//ZZA_FILIAL, ZZA_ORDEM, R_E_C_N_O_, D_E_L_E_T_
				ZZA->(dbSeek(xFilial("ZZA")+cNumOp))
															
				IF ZZA->(Found())
					BEGIN TRANSACTION
						RecLock("ZZA",.F.)
							ZZA->ZZA_SP    :='1'
							ZZA->ZZA_PERDA := ABS(SomaPI-SomaPA)
						MsUnLock()
					END TRANSACTION
				Endif       	
	        EndIf
	    Else
			If aArray[3]=='S'	 //Faz a baixa
				aVetor := {}
	            aVetor := { {"D3_FILIAL" , xFilial("SD3")		, NIL},;
	              			{"D3_TM"     , "110"      	   	    , NIL},;  //Falta de produção
	                        {"D3_COD"    , cItem  	  			, NIL},;
	                        {"D3_LOCAL"  , cLocItem	  			, NIL},;
	                        {"D3_EMISSAO", DATE()  	  			, NIL},;   
	                        {"D3_DOC"	 , nDocumento  			, NIL},;
	                        {"D3_UM"	 , cUni  		  		, NIL},;
		                    {"D3_TURNO"  , 'ZZR23'   			, NIL},;
	           	        	{"D3_OBS"    , Alltrim(cNumOp)		, NIL},;                                               
	                        {"D3_QUANT"  , Abs(SomaPA-SomaPI)	, NIL} }   
	            lMsErroAuto:=.f.      
	            MSExecAuto({|x,y| MATA240(x, y)}, aVetor, 3) 
	                               
		        If lMsErroAuto
                  	Mostraerro()
    			Else
					dbSelectArea("ZZA")
					ZZA->(dbSetorder(2))//ZZA_FILIAL, ZZA_ORDEM, R_E_C_N_O_, D_E_L_E_T_
					ZZA->(dbSeek(xFilial("ZZA")+cNumOp))
														
					IF ZZA->(Found())
						BEGIN TRANSACTION
							RecLock("ZZA",.F.)
								ZZA->ZZA_SP    :='1'
								ZZA->ZZA_PERDA := ABS(SomaPI-SomaPA)
							MsUnLock()
						END TRANSACTION
					Endif       	
                EndIf
			Endif  
			If aArray[2]=='S'	 //Gera Ocorrencia
				FOR nX := 1 TO Len(aPa)
       		   		gravaZZR(aPa[nX][1],aPa[nX][2],aPa[nX][3],aPa[nX][4],"", "",nDocumento,cItem,cLocItem,nQuant,"1","M",aPa[nX][5])	
				NEXT nX
			Endif	
    	EndIf
	EndIf
		
Return 

Static Function ValidaSobr(cLote)

Local lOpAberta := .F.
Local nDocumento:=  NextNumero("SD3",2,"D3_DOC",.T.)   //Gera o proximo numero de documento
Local SomaPI  :=0
Local SomaPA  :=0
Local aArray  :={}
Local lTotal  :=.F.
Local lApontPA:=.T.
Local aSaldos :={}
Local cont    :=0
Local cOP     :=""
Local cNumOp  :=""
Local aPa     :={}
Local nX

/*-    
	DbSelectArea("SC2")
	DbSetOrder(13)
	DbSeek(xFilial("SC2")+Alltrim(cLote), .t.)

	lValida:=.t.
	If Found() 
		While !(SC2->(Eof())) .AND. (XFilial("SC2") == SC2->C2_FILIAL) .AND. (SC2->C2_LOTE == Alltrim(cLote))
			If Empty(SC2->C2_DATRF)
				lValida := .f.
			End
			DbSelectArea("SC2")
			DbSkip()        	
	  	Enddo
	Endif
	DbSelectArea("SC2")
	DbCloseArea()

    */
 	dbSelectArea("ZZA")	
	ZZA->(dbSetOrder(3)) // ZZA_FILIAL, ZZA_LOTE, R_E_C_N_O_, D_E_L_E_T_
	ZZA->(dbSeek(xFilial("ZZA")+Trim(cLote)))
	 
	lValida:=.T.
	While !(ZZA->(eof())) .AND. (ZZA->ZZA_FILIAL = xFilial("ZZA")) .AND. (ZZA->ZZA_LOTE  =  Trim(cLote))
		If ZZA->ZZA_FLAG=='6'
	 		lValida:=.F.
	 	EndIf
	 	ZZA->(dbSkip())
	EndDo

	If !lValida //Se existem apontamentos nao finalizados na OPs, nao processa o lote
		return
	EndIf

	cQuery1:="  SELECT B2_COD, B2_LOCAL, B2_QATU "
	cQuery1+="	FROM "+RetSQlName("SC2")+" SC2 WITH (NOLOCK) " 
	cQuery1+="	INNER JOIN "+RetSQlName("SB1")+" SB1 WITH (NOLOCK) ON SC2.C2_FILIAL = SB1.B1_FILIAL  AND C2_PRODUTO = B1_COD AND SC2.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
	cQuery1+="	INNER JOIN "+RetSQlName("ZZA")+" ZZA WITH (NOLOCK) ON SC2.C2_FILIAL = ZZA_FILIAL AND SC2.C2_OP = ZZA_ORDEM AND SC2.D_E_L_E_T_ = ZZA.D_E_L_E_T_ "
	cQuery1+="	INNER JOIN "+RetSQlName("SB2")+" SB2 WITH (NOLOCK) ON SC2.C2_FILIAL = SB2.B2_FILIAL AND SC2.C2_PRODUTO = SB2.B2_COD AND SC2.C2_LOCAL = SB2.B2_LOCAL AND SC2.D_E_L_E_T_ = SB2.D_E_L_E_T_ "
	cQuery1+="	WHERE C2_FILIAL='"+xFilial("SC2")+"' AND SC2.D_E_L_E_T_='' AND C2_DATPRF <>''  "
	cQuery1+="	AND ZZA_LOTE NOT IN (SELECT ZZR_LOTE FROM ZZR010 ZZR WHERE ZZR_FILIAL='"+xFilial("ZZR")+"' AND ZZR.D_E_L_E_T_='' AND ZZR_TIPO='PA' ) "
	cQuery1+="	AND C2_LOTE='"+TRIM(cLote)+"'  "
	cQuery1+="	ORDER BY B2_COD, B2_LOCAL, B2_QATU  "
	
	IF (Select("TMPSB2") > 0 )
   		TMPSB2->(DbCloseArea())
	EndIf
	
	TCQuery cQuery1  ALIAS "TMPSB2" NEW
	
	While !(TMPSB2->(eof()))
		Aadd(aSaldos,{TMPSB2->B2_COD,TMPSB2->B2_LOCAL,TMPSB2->B2_QATU}) //monta o array com os saldos do SB2 antes de executar o processamento
		TMPSB2->(dbSkip())
	Enddo
	 
	//Verifica OPs encerradas que possui sobra de salda após a finalização (Falta checar se OP foi finalizada)
	
	cQuery:="  SELECT DISTINCT ZZA_FLAG, B1_CONV,SUM(ZZA_QUANT) AS C2_QUANT,C2_QUJE, (B1_CONV * C2_QUJE) QTDETOTAL, SB1.B1_TIPO, SC2.C2_OP,SC2.C2_LOCAL, SC2.C2_PRODUTO, SC2.C2_LOTE, SB1.B1_TIPO, B1_UM "
	cQuery+="  FROM "+RetSQlName("SC2")+" SC2 WITH (NOLOCK) " 
	cQuery+="  INNER JOIN "+RetSQlName("SB1")+" SB1 WITH (NOLOCK) ON SC2.C2_FILIAL = SB1.B1_FILIAL  AND C2_PRODUTO = B1_COD AND SC2.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
	cQuery+="  INNER JOIN "+RetSQlName("ZZA")+" ZZA WITH (NOLOCK) ON SC2.C2_FILIAL = ZZA_FILIAL AND SC2.C2_OP = ZZA_ORDEM AND SC2.D_E_L_E_T_ = ZZA.D_E_L_E_T_ "
	cQuery+="  WHERE C2_FILIAL='"+xFilial("SC2")+"' AND SC2.D_E_L_E_T_='' AND C2_DATRF <>'' AND ZZA_SP ='' "
	cQuery+="  AND ZZA_LOTE NOT IN (SELECT ZZR_LOTE FROM ZZR010 ZZR WHERE ZZR_FILIAL='"+xFilial("ZZR")+"' AND ZZR.D_E_L_E_T_=''  AND ZZR_TIPO='PA' ) "
	cQuery+="  AND C2_LOTE='"+TRIM(cLote)+"'  "
	//cQuery+="	AND (C2_OP IN (SELECT H6_OP FROM "+RetSQlName("SH6")+" WHERE H6_OP=C2_OP AND H6_FILIAL='"+xFilial("SH6")+"' AND D_E_L_E_T_='' AND H6_PT='T') OR B1_TIPO='PA')  "
	cQuery+="  GROUP BY C2_PRODUTO,ZZA_FLAG, B1_CONV, C2_QUJE, B1_TIPO, C2_LOCAL, C2_OP, C2_LOTE, B1_UM "
	cQuery+="  ORDER BY SC2.C2_OP"
	
	IF (Select("TMPZZR") > 0 )
	   TMPZZR->(DbCloseArea())
	EndIf

	TCQuery cQuery ALIAS "TMPZZR" NEW

	While !(TMPZZR->(eof()))
		Cont+=1
		If TMPZZR->B1_TIPO=='PI'
			IncProc( "Processando OP : "+ Trim(TMPZZR->C2_OP)) 
			
			dbSelectArea("SH6") //verifica se PI foi apontado totalmente
			SH6->(dbSetOrder(1))	//H6_FILIAL, H6_OP, H6_PRODUTO, H6_OPERAC, H6_SEQ, H6_DATAINI, H6_HORAINI, H6_DATAFIN, H6_HORAFIN, R_E_C_N_O_, D_E_L_E_T_
			SH6->(dbSeek(xFilial("SH6")+TMPZZR->C2_OP))
			
			While !(SH6->(eof())) .And. Trim(TMPZZR->C2_OP) == Trim(SH6->H6_OP)
				If SH6->H6_PT=='T'
					lTotal:=.T.
				EndIf	
				SH6->(dbSkip())
			EndDo
			SomaPI  += TMPZZR->C2_QUJE
			cItem   := TMPZZR->C2_PRODUTO
			cLocItem:= TMPZZR->C2_LOCAL
			nQuant  := TMPZZR->C2_QUANT
			cUni    := TMPZZR->B1_UM
			cNumOp	:= TMPZZR->C2_OP 
			
		ElseIf TMPZZR->B1_TIPO=='PA'
			If TMPZZR->C2_QUJE==0
				lApontPA:=.F.
			EndIf
			
			SomaPA	+= (IIF(TMPZZR->C2_QUJE==0,TMPZZR->C2_QUANT*TMPZZR->B1_CONV,TMPZZR->QTDETOTAL)) //se ja foi baixado pega da C2_QUJE senão pega da  C2_QUANT 
			cOP		:= TMPZZR->C2_OP
			cLocal	:= TMPZZR->C2_LOCAL
			cProdut	:= TMPZZR->C2_PRODUTO
			clote	:= TMPZZR->C2_LOTE
			cTipo	:= TMPZZR->B1_TIPO
			aAdd(aPa,{cOp,cLocal,cProdut,clote,cTipo})
		EndIf
		TMPZZR->(dbSkip())
	EndDo

	If Cont>1
		
		lOpAberta :=.f.
		
		DbSelectArea("SC2")   // VERIFICA SE EXISTE OP EM ABERTO (NÃO EXCLUIR SALDO CASO EXISTA) 22/08/14
    	DbSetOrder(13)
 	   	DbSeek(xFilial("SC2")+Alltrim(clote), .t.)
	    If Found() 
    		While !Eof() .and. (SC2->C2_FILIAL == xFilial("SC2")) .and. (Alltrim(SC2->C2_LOTE) == Alltrim(clote))
				If Empty(SC2->C2_DATRF)
					lOpAberta := .t.
				Endif
				DbSelectArea("SC2")
				DbSkip()        	
  			Enddo
	    Endif 
		DbSelectArea("SC2")
		DbCloseArea()

		dbSelectArea("SD3")
		SD3->(dbSetOrder(2))  //D3_FILIAL, D3_DOC, D3_COD, R_E_C_N_O_, D_E_L_E_T_
		If (SD3->(dbSeek(xFilial("SD3")+Trim(nDocumento))))	 //Verifica se já existe lançamento 
			If Trim(SD3->D3_COD)==Trim(cItem)
				Return
			EndIf
		EndIf	
		aArray:=VldRegrPA(SomaPA,SomaPI)
		nDocumento:=clote		
				                
		If SomaPI>SomaPA .And. lTotal .AND. Len(Alltrim(cNumOp))>1  .and. !lOpAberta		//houve sobra de saldo de PI após apontar todos os PAs	
			If aArray[1]
				nPos := aScanX( aSaldos, { |X,Y| X[1] == citem .And.  X[2] == cLocItem})
				If aSaldos[nPos][3] >= (SomaPI-SomaPA)
	            	aVetor := {}
				    aVetor := { {"D3_FILIAL"    , xFilial("SD3") 	, NIL},;
				   		        {"D3_TM"     	, "600"          	, NIL},;  //Sobra
				                {"D3_COD"    	, cItem  		 	, NIL},;
				                {"D3_LOCAL"  	, cLocItem		 	, NIL},;
				                {"D3_EMISSAO"	, DATE()  		 	, NIL},;   
				                {"D3_DOC"		, nDocumento  	 	, NIL},;
				                {"D3_TURNO"		, "ZR02"  		 	, NIL},;
				                {"D3_UM"		, cUni  		 	, NIL},;
			       	        	{"D3_OBS"       , Alltrim(cNumOp)	, NIL},;                                               
				                {"D3_QUANT"  	, (SomaPI-SomaPA)	, NIL} }   
					lMsErroAuto:=.f.      
				    MSExecAuto({|x,y| MATA240(x, y)}, aVetor, 3) 
					                                    
					If lMsErroAuto
				       	MostraErro() 
					Else
						dbSelectArea("ZZA")
						ZZA->(dbSetorder(2))//ZZA_FILIAL, ZZA_ORDEM, R_E_C_N_O_, D_E_L_E_T_
						ZZA->(dbSeek(xFilial("ZZA")+cNumOp))												
	              		    
	              	    IF ZZA->(Found())
	              	   		BEGIN TRANSACTION
			           		   	RecLock("ZZA",.F.)
				           		   	ZZA->ZZA_SP    :='6'
				           		   	ZZA->ZZA_SOBRA := Abs(SomaPI-SomaPA)
			           		   	MsUnLock()
						
			                END TRANSACTION
			             ENDIF    
			 		EndIf
			  	EndIf  
			Else
				If  aArray[3]=='S'  // Exclui o saldo restante automaticamente
					nPos := aScanX( aSaldos, { |X,Y| X[1] == citem .And.  X[2] == cLocItem})
        			If aSaldos[nPos][3] >= (SomaPI-SomaPA)
	             	 	//nDocumento:=clote					
						aVetor := {}
				        aVetor := { {"D3_FILIAL" , xFilial("SD3")  , NIL},;
				        		    {"D3_TM"     , "600"           , NIL},;  //Sobra
									{"D3_COD"    , cItem  		   , NIL},;
									{"D3_LOCAL"  , cLocItem		   , NIL},;
									{"D3_EMISSAO", DATE()  		   , NIL},;   
									{"D3_DOC"	 , nDocumento  	   , NIL},;
					                {"D3_TURNO"	 , "ZR02"  		   , NIL},;
									{"D3_UM"	 , cUni  		   , NIL},;
    		           	        	{"D3_OBS"    , Alltrim(cNumOp) , NIL},;                                               
				     				{"D3_QUANT"  , (SomaPI-SomaPA) , NIL} }   
				        lMsErroAuto:=.f.      
				        MSExecAuto({|x,y| MATA240(x, y)}, aVetor, 3) 
					                                    
						If lMsErroAuto
				           	mostraerro() 
						Else
							dbSelectArea("ZZA")
							ZZA->(dbSetorder(2))//ZZA_FILIAL, ZZA_ORDEM, R_E_C_N_O_, D_E_L_E_T_
							ZZA->(dbSeek(xFilial("ZZA")+cNumOp))												
	              		    
	              		    IF ZZA->(Found())
	              		   		BEGIN TRANSACTION
			               		   	RecLock("ZZA",.F.)
				               		   	ZZA->ZZA_SP    :='6'
				               		   	ZZA->ZZA_SOBRA := Abs(SomaPI-SomaPA)
			               		   	MsUnLock()
			                     END TRANSACTION
			                ENDIF    
				        EndIf
					EndIf
			    EndIf 
			    If aArray[2]=='S' 	//gera Ocorrencia
				  //nDocumento:=clote
				    FOR nX := 1 TO Len(aPa)
 					    gravaZZR(aPa[nX][1],aPa[nX][2],aPa[nX][3],aPa[nX][4],"", "",nDocumento,cItem,cLocItem,nQuant,"1","M",aPa[nX][5])		
					NEXT nX             	  
	         	EndIf 
		    EndIf         
		 EndIf    
	EndIf
Return 

Static Function ValidRoubo(cOrdem,cProdut,cLote)

Local nDocumento:=  NextNumero("SD3",2,"D3_DOC",.T.)   //Gera o proximo numero de documento
Local SomaPI	:=0
Local SomaPA	:=0
Local aArray	:={}
//Local lTotal	:=.F.
//Local lApontPA:= .T.
Local aSaldos	:={}
Local cOP		:=""
Local cNumOp	:=""
Local aPa		:={}
Local Cont	:=0
Local nX

cQuery1:="	SELECT B2_COD, B2_LOCAL, B2_QATU "
cQuery1+="	FROM "+RetSQlName("SC2")+" SC2 WITH (NOLOCK) " 
cQuery1+="	INNER JOIN "+RetSQlName("SB1")+" SB1 WITH (NOLOCK) ON SC2.C2_FILIAL  = SB1.B1_FILIAL  AND C2_PRODUTO = B1_COD AND SC2.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
cQuery1+="	INNER JOIN "+RetSQlName("ZZA")+" ZZA WITH (NOLOCK) ON SC2.C2_FILIAL  = ZZA_FILIAL AND SC2.C2_OP = ZZA_ORDEM AND SC2.D_E_L_E_T_ = ZZA.D_E_L_E_T_ "
cQuery1+="  INNER JOIN "+RetSQlName("SB2")+" SB2 WITH (NOLOCK) ON SC2.C2_PRODUTO = B2_COD AND SC2.C2_LOCAL = B2_LOCAL AND SC2.D_E_L_E_T_ = SB2.D_E_L_E_T_ "
cQuery1+="	WHERE C2_FILIAL='"+xFilial("SC2")+"' AND SC2.D_E_L_E_T_='' AND C2_LOTE='"+TRIM(cLote)+"' AND C2_DATRF<>'' AND ZZA.ZZA_SP =''  "
cQuery1+="  GROUP BY B2_COD, B2_LOCAL, B2_QATU "                                                        //C2_DATPRF

IF (Select("TMPSB2") > 0 )
	TMPSB2->(DbCloseArea())
EndIf

TCQuery cQuery1  ALIAS "TMPSB2" NEW

While !(TMPSB2->(eof()))
	
	Aadd(aSaldos,{TMPSB2->B2_COD,TMPSB2->B2_LOCAL,TMPSB2->B2_QATU}) //monta o array com os saldos do SB2 antes de executar o processamento
	TMPSB2->(dbSkip())
Enddo

//Verifica OPs encerradas que possui sobra de salda após a finalização (Falta checar se OP foi finalizada)

cQuery:="  SELECT DISTINCT B1_CONV,C2_QUANT,C2_QUJE, (B1_CONV * ZZA_QUANT) AS QTDETOTAL, SB1.B1_TIPO, SC2.C2_OP,SC2.C2_LOCAL, SC2.C2_PRODUTO, SC2.C2_LOTE, SB1.B1_TIPO, B1_UM "
cQuery+="  FROM "+RetSQlName("SC2")+" SC2 WITH (NOLOCK) " 
cQuery+="  INNER JOIN "+RetSQlName("SB1")+" SB1 WITH (NOLOCK) ON (SC2.C2_FILIAL = SB1.B1_FILIAL)  AND (SC2.C2_PRODUTO = SB1.B1_COD) AND (SC2.D_E_L_E_T_ = SB1.D_E_L_E_T_) "
cQuery+="  INNER JOIN "+RetSQlName("ZZA")+" ZZA WITH (NOLOCK) ON (SC2.C2_FILIAL = ZZA.ZZA_FILIAL) AND (SC2.C2_OP = ZZA.ZZA_ORDEM)   AND (SC2.D_E_L_E_T_ = ZZA.D_E_L_E_T_) "
cQuery+="  WHERE C2_FILIAL='"+xFilial("SC2")+"' AND SC2.D_E_L_E_T_='' AND C2_LOTE='"+TRIM(cLote)+"' AND C2_DATRF <>''  "
cQuery+="  ORDER BY SC2.C2_OP "

IF (Select("TMPZZR") > 0 )
   TMPZZR->(DbCloseArea())
EndIf

TCQuery cQuery ALIAS "TMPZZR" NEW

While !(TMPZZR->(eof()))
	
	Cont+=1
	If TMPZZR->B1_TIPO=='PI'
		SomaPI	+= TMPZZR->C2_QUJE
		cItem	:= TMPZZR->C2_PRODUTO
		cLocItem:= TMPZZR->C2_LOCAL
		nQuant	:= TMPZZR->C2_QUANT
		cUni	:= TMPZZR->B1_UM
		cNumOp	:= TMPZZR->C2_OP // TESTE
		
	ElseIf TMPZZR->B1_TIPO=='PA'
	    SomaPA+= QTDETOTAL
		//SomaPA+=(IIF(TMPZZR->C2_QUJE==0,TMPZZR->C2_QUANT*TMPZZR->B1_CONV,TMPZZR->QTDETOTAL)) //se ja foi baixado pega da C2_QUJE senão pega da  C2_QUANT 
		cOp		:= TMPZZR->C2_OP
		cLocal	:= TMPZZR->C2_LOCAL
		cProdut	:= TMPZZR->C2_PRODUTO
		clote	:= TMPZZR->C2_LOTE
		cTipo	:= TMPZZR->B1_TIPO
		aAdd(aPa,{cOp,cLocal,cProdut,clote,cTipo})
	EndIf
	
	TMPZZR->(dbSkip())
EndDo
	
	aArray:=VldRegrPA(SomaPA,SomaPI)
	nPos := aScanX( aSaldos, { |X,Y| X[1] == citem .And.  X[2] == cLocItem})
	nSaldo:= aSaldos[nPos][3] 
	
	If (SomaPA > SomaPI) .AND. (Cont > 1) .AND. Len(Alltrim(cNumOp))>1  //Falta saldo do PI
		If  aArray[1]  //Se verdadeiro não é ocorrencia, baixa automaticamente
			aVetor := {}
		//	nDocumento:=  NextNumero("SD3",2,"D3_DOC",.T.)   //Gera o proximo numero de documento
            aVetor := { {"D3_FILIAL"    , xFilial("SD3") 	, NIL},;
               			{"D3_TM"        , "110"          	, NIL},;  //Falta de produção
               			{"D3_COD"       , cItem          	, NIL},;
                   		{"D3_LOCAL"     , cLocItem       	, NIL},;
                      	{"D3_EMISSAO"   , DATE()         	, NIL},;   
                       	{"D3_DOC"       , nDocumento     	, NIL},;
	                    {"D3_TURNO"     , 'ZZR24' 			, NIL},;
                       	{"D3_UM"        , cUni           	, NIL},;
                       	{"D3_QUANT"     , Abs(SomaPA-SomaPI), NIL} }   
            lMsErroAuto:=.f.      
            MSExecAuto({|x,y| MATA240(x, y)}, aVetor, 3) 
	                                
            If lMsErroAuto
                mostraerro()
            Else
				dbSelectArea("ZZA")
				ZZA->(dbSetorder(2))//ZZA_FILIAL, ZZA_ORDEM, R_E_C_N_O_, D_E_L_E_T_
				ZZA->(dbSeek(xFilial("ZZA")+cNumOp))
													
		        IF ZZA->(Found())
		        	BEGIN TRANSACTION
				     	RecLock("ZZA",.F.)
				       		ZZA->ZZA_SP    :='1'
				       		ZZA->ZZA_PERDA :=  ABS(SomaPI-SomaPA)
				    	 MsUnLock()
				    END TRANSACTION
				Endif       	
            EndIf
	    Else
		    If aArray[3]=='S'	 //Faz a baixa
				 aVetor := {}
	             aVetor := { {"D3_FILIAL" , xFilial("SD3") 		, NIL},;
	              			{"D3_TM"     , "110"        		, NIL},;  //Falta de produção
	                        {"D3_COD"    , cItem  				, NIL},;
	                        {"D3_LOCAL"  , cLocItem				, NIL},;
	                        {"D3_EMISSAO", DATE()  				, NIL},;   
	                        {"D3_DOC"	 , nDocumento  			, NIL},;
		                    {"D3_TURNO"  , 'ZZR25'  			, NIL},;
	                        {"D3_UM"	 , cUni  				, NIL},;
	                        {"D3_QUANT"  , Abs(SomaPA-SomaPI) 	, NIL} }   
	             lMsErroAuto:=.f.      
	             MSExecAuto({|x,y| MATA240(x, y)}, aVetor, 3) 
	                                
		         If lMsErroAuto
	          		mostraerro()
				 Else
					 dbSelectArea("ZZA")
					 ZZA->(dbSetorder(2))//ZZA_FILIAL, ZZA_ORDEM, R_E_C_N_O_, D_E_L_E_T_
					 ZZA->(dbSeek(xFilial("ZZA")+cNumOp))
													
			         IF ZZA->(Found())
			        	 BEGIN TRANSACTION
					     	 RecLock("ZZA",.F.)
					       		 ZZA->ZZA_SP    :='1'
					       		 ZZA->ZZA_PERDA := ABS(SomaPI-SomaPA)
					    	  MsUnLock()
					     END TRANSACTION
					 Endif       	
	             EndIf
			Endif  
				
			If aArray[2]=='S'	 //Gera Ocorrencia
	       			
				FOR nX := 1 TO Len(aPa)
       		   		gravaZZR(aPa[nX][1],aPa[nX][2],aPa[nX][3],aPa[nX][4],"", "",nDocumento,cItem,cLocItem,nQuant,"1","M",aPa[nX][5])	
				NEXT nX
			Endif	
		EndIf
    EndIf
  
dbSelectArea("ZZA")
ZZA->(dbSetorder(2))//ZZA_FILIAL, ZZA_ORDEM, R_E_C_N_O_, D_E_L_E_T_
ZZA->(dbSeek(xFilial("ZZA")+Cordem))

While !(ZZA->(eof())) .And. (Alltrim(ZZA->ZZA_ORDEM) ==Alltrim(Cordem)) .And. (Alltrim(ZZA->ZZA_LOTE)==Alltrim(cLote)) 

If ZZA_GEROCO=='1'
	BEGIN TRANSACTION
		If ZZA->(Found())
		   RecLock("ZZA",.F.)
			   ZZA->ZZA_GEROCO:='2'
		   MsUnLock()
		ENDIF	
    END TRANSACTION
EndIf

ZZA->(dbSkip())
EndDo 

		
Return	




Static Function VldRegrPA(nQtdPA,nQtdPI)

Local aRet:={.f.    ,''    ,''     ,0 }
//				|		|		|		|	
//				|		|		|		|
//				|		|		|		|____ 4. Retorna percentual calculado
//				|		|		|
//				|		|		|___________ 3. F->Baixa OP  T-> Não baixa OP (caso esteja fora da porcentagem, se estiver dentro, vai baixar independente deste campo)
//				|		|
//   		    |		|__________________ 2. N-> Não gera ocorrencia  S-> Gera ocorrencia (caso esteja fora da porcentagem) 
//				|
//				|_________________________ 1. N-> Não esta dentro do percentual  S-> Está dentro do percentual


//Local cArea:= getArea()
Local nDif :=0
Local nPorcent

dbSelectArea("ZZS")
dbGoTop()

While !(ZZS->(eof()))
	If (nQtdPA>=ZZS->ZZS_QTMIN) .And. (nQtdPA<= ZZS->ZZS_QTMAX) .And. !(aRet[1])
		aRet[2] := ZZS->ZZS_OCORRE
		aRet[3] := ZZS->ZZS_BAIXA
		nDif    := IIF(nQtdPA > nQtdPI,nQtdPA - nQtdPI,nQtdPI-nQtdPA) //Trata valor negativo
		nPorcent:= (nDif)*100/nQtdPA
		aRet[4] := ROUND(nPorcent,2)
		If nPorcent<=ZZS->ZZS_PERCEN //Esta dentro da porcentagem permitida para baixa, não é ocorrencia
			aRet[1]:=	.T.
		EndIF
	EndIf
	ZZS->(dbSkip())
EndDo


Return aRet
