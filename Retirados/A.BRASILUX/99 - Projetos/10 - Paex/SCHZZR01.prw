#include "protheus.ch"
#include 'tbiconn.ch'
#include 'error.ch'
#include 'topconn.ch'
#INCLUDE "RWMAKE.CH"

/*/
+----------------------------------------------------------------------------+
| Função | SCHZZR001 | Autor |Tiago Lucio | www.chaus.com.br |Data 24/04/2014|
+----------------------------------------------------------------------------+  
| Descrição | Schedule para geração dos registros para a tabela ZZR das 	 |
|				Ordens de Produção não baixadas devido alguma ocorrencia.    |
|				A rotina executa a baixa de OPs no fim da execução.		     |
|																		     |
|+---------------------------------------------------------------------------+
| Uso | SIGAPCP |															 |
|+---------------------------------------------------------------------------+
/*/                            

User Function SCHZZR01( _aParm )
     Local a_cFil       := {"010101","060101"}
     Local aParm        := Iif( ValType( _aParm ) == 'U', {"01", a_cFil , "2"}, _aParm )
     Local i
     Local cAuxMens     := ""
     //Local aParm      := Iif(ValType(aParm) == 'U', {"01", "010101", "2"}, aParm)
     Local cEmp         := Alltrim(Transform(aParm[1],'@!'))
     //Local cFil       := Alltrim(Transform(aParm[2],'@!'))
     Local nOpc         := Alltrim(Transform(aParm[3],'@!'))
     Private lEndThread
     //LGS#20200210 - Adequação de release 12.1.25 e posteriores
     //ConOut("***********************************************")
     //ConOut("*  SCHZZR01 - BAIXA AUTOMATICA DE PI          *")
     //ConOut("***********************************************")
     cAuxMens += "***********************************************" + CHR(13) + CHR(10)
     cAuxMens += "*  SCHZZR01 - BAIXA AUTOMATICA DE PI          *" + CHR(13) + CHR(10)
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
    		        U_SCHZZR1(nOpc, cEmp, a_cFil[i]) //Faz o processamento das gerações das ordens de produção
   		        //LGS#20200210 - Adequação de release 12.1.25 e posteriores
	            //ConOut("-- FIM")
	            FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', "-- FIM", 0 )
			Endif
	        RESET ENVIRONMENT
		Next i
     Else
     	If cFilAnt == '010101'
	    	Processa( { |lEnd| U_SCHZZR1(nOpc, cEmp, cFilAnt) }, "Baixa automatica de OPs (PA)", ,.t.) //Faz o processamento das baixas das ordens de produção
        Endif
     Endif

Return(Nil)

User Function SCHZZR1(nOpc, cEmp, _cFil )
      
Local 	nQuant                                                                                          
Local 	nSaldoB2
Local 	aVetor 		:= {} 
Local 	aSaldos 	:= {}
Local  	lAltaprop	:= .F.
//Local 	nFlagSaldo	:= 0 //Flag indicando se acho saldo em outro armazem
Local 	cQuery      := ""
Local 	cQuery1     := ""
PRIVATE cCusMed  	:= ""
PRIVATE aRegSD3  	:= {} 

cCusMed  := GetMv("MV_CUSMED") 

If cCusMed == "O"
	PRIVATE nHdlPrv 			// Endereco do arquivo de contra prova dos lanctos cont.
	PRIVATE lCriaHeader := .T.	// Para criar o header do arquivo Contra Prova
	PRIVATE cLoteEst 			// Numero do lote para lancamentos do estoque
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona numero do Lote para Lancamentos do Faturamento     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX5")
	SX5->(dbSeek(xFilial("SX5")+"09EST"))
	cLoteEst:=IIf(Found(),Trim(X5Descri()),"EST ")
	PRIVATE nTotal := 0 	// Total dos lancamentos contabeis
	PRIVATE cArquivo		// Nome do arquivo contra prova
EndIf

If !Len(Alltrim(GetMv("MV_BXMANEW"))) >1
//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101"  

	cQuery:="  		SELECT ZZA.ZZA_ORDEM,	"
	cQuery+="  		ZZA.ZZA_LOTE,	"
	cQuery+="			ZZA.ZZA_PRODUT, 	"
	cQuery+="			SB1.B1_TIPO,	"
	cQuery+="			SB1.B1_UM,	"
	cQuery+="			SB1.B1_APROPRI,	"
	cQuery+="			ZZA.ZZA_QUANT,	"				//Quantidade já apontadas
	cQuery+="			SC2.C2_QUANT,	"                      //Quantidade Original 
	cQuery+="			SC2.C2_QUJE,	"                       //Quantidade já baixada anteriormente
	cQuery+="			ZZA.ZZA_DTINI, 	"
	cQuery+="			ZZA.ZZA_HINI,	" 
	cQuery+="			ZZA.ZZA_DTFIM,	"
	cQuery+="			ZZA.ZZA_HFIM,	"
	cQuery+="			ZZA.ZZA_HELP,	"                     //Se Primeiro Digito for "1" Baixa OP do Almx 02 , caso contrario Gera produto no "20"
	cQuery+="			COUNT(ZZF.ZZF_ORDEM) AS QTDZZF, "   //Quantidade de materias primas que foram baixadas. Se maior que zero tem quantidade pendente.
	cQuery+="			ZZA.R_E_C_N_O_, 	"
	cQuery+="			SC2.C2_ROTEIRO,	"
	cQuery+="			SC2.C2_LOCAL,	"
	cQuery+="			C2_NUM+C2_ITEM+C2_SEQUEN AS C2_OP	"
	cQuery+="	FROM "+RetSQlName("ZZA")+" ZZA WITH (NOLOCK) INNER JOIN "+RetSQlName("SB1")+" SB1 ON ZZA_FILIAL = SB1.B1_FILIAL AND ZZA.ZZA_PRODUT = SB1.B1_COD AND ZZA.D_E_L_E_T_= SB1.D_E_L_E_T_  "
	cQuery+="								  LEFT OUTER JOIN "+RetSQlName("ZZF")+" ZZF WITH (NOLOCK) ON ZZF.ZZF_FILIAL = ZZA.ZZA_FILIAL AND ZZF.ZZF_ORDEM = ZZA.ZZA_ORDEM AND ZZF.D_E_L_E_T_ = '' "
	cQuery+="								  LEFT OUTER JOIN "+RetSQlName("SC2")+" SC2 WITH (NOLOCK) ON SC2.C2_FILIAL = ZZA.ZZA_FILIAL AND SC2.C2_OP = ZZA.ZZA_ORDEM AND SC2.D_E_L_E_T_ = ''   "
	cQuery+="	WHERE ZZA.ZZA_FILIAL = '"+xFIlial('ZZA')+"' "	
	cQuery+="			AND ZZA.D_E_L_E_T_ = '' "
	cQuery+="	        AND ZZA.ZZA_FLAG  = '4' "
	cQuery+=" 			  AND ZZA_CAMPO<>' ' "
	//cQuery+="  AND ZZA.ZZA_PRODUT='BT 970500700'"    //REMOVER APÓS VALIDAÇÃO
	//cQuery+="	        AND ZZA.ZZA_DTFIM <= '"+dDatFin+"' "+;
	cQuery+="	GROUP BY ZZA.ZZA_ORDEM, ZZA.ZZA_LOTE, ZZA.ZZA_PRODUT, SB1.B1_TIPO,SB1.B1_UM,SB1.B1_APROPRI, ZZA.ZZA_QUANT, ZZA.ZZA_DTINI, ZZA.ZZA_HINI, ZZA.ZZA_DTFIM, ZZA.ZZA_HFIM, ZZA.ZZA_HELP, ZZA.R_E_C_N_O_, SC2.C2_QUANT, SC2.C2_QUJE,SC2.C2_ROTEIRO, SC2.C2_LOCAL, C2_NUM+C2_ITEM+C2_SEQUEN " 	
	cQuery+="	ORDER BY QTDZZF,ZZA_DTINI,ZZA_HINI  "
	  
	              
	cQuery1="		SELECT DISTINCT B2_COD, B2_LOCAL, B2_QATU AS B2_QATU		"
	cQuery1+="		FROM "+RetSQlName("ZZA")+" ZZA WITH (NOLOCK) INNER JOIN SB1010 SB1 ON ZZA_FILIAL = SB1.B1_FILIAL AND ZZA.ZZA_PRODUT = SB1.B1_COD AND ZZA.D_E_L_E_T_= SB1.D_E_L_E_T_  		"								  
	cQuery1+="		LEFT OUTER JOIN "+RetSQlName("ZZF")+" ZZF WITH (NOLOCK) ON ZZF.ZZF_FILIAL = ZZA.ZZA_FILIAL AND ZZF.ZZF_ORDEM = ZZA.ZZA_ORDEM AND ZZF.D_E_L_E_T_ = '' "							  
	cQuery1+="		LEFT OUTER JOIN "+RetSQlName("SC2")+" SC2 WITH (NOLOCK) ON SC2.C2_FILIAL = ZZA.ZZA_FILIAL AND SC2.C2_OP = ZZA.ZZA_ORDEM AND SC2.D_E_L_E_T_ = ''   "
	cQuery1+="		INNER JOIN "+RetSQlName("SD4")+" SD4 WITH (NOLOCK) ON	ZZA.ZZA_FILIAL = SD4.D4_FILIAL AND ZZA.ZZA_ORDEM = SD4.D4_OP AND  ZZA.D_E_L_E_T_ =  SD4.D_E_L_E_T_ "
	cQuery1+="		INNER JOIN "+RetSQlName("SB2")+" SB2 WITH (NOLOCK) ON SD4.D4_FILIAL = SB2.B2_FILIAL AND  SD4.D4_COD = SB2.B2_COD AND SD4.D4_LOCAL = SB2.B2_LOCAL AND SD4.D_E_L_E_T_ =  SB2.D_E_L_E_T_ 	"
	cQuery1+="		WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' 	"		
	cQuery1+="		AND ZZA.D_E_L_E_T_ = '' 	   "     
	cQuery1+="		AND ZZA.ZZA_FLAG  = '4'	"
	cQuery1+=" 			  AND ZZA_CAMPO<>' ' "


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
	    	dbSelectArea("ZZF")
   	    	ZZF->(dbSetOrder(4))		//  ZZF_FILIAL, ZZF_ORDEM, ZZF_CODIGO, ZZF_TRT, R_E_C_N_O_, D_E_L_E_T_
   	    	ZZF->(dbSeek(xFilial("ZZF")+Trim(SD4->D4_OP)+(SD4->D4_COD)+Trim(SD4->D4_TRT)))
   	   		nPos := aScanX( aSaldos, { |X,Y| X[1] == SD4->D4_COD .And.  X[2] == SD4->D4_LOCAL})  //ALTERADO PARA GRAVAÇÃO DO CAMPO ZZR_QUANT COM A QUANTIDADE GERADA E NÃO COM A QUANTIDADE TOTAL DA ORDEM DE PRODUÇÃO
   	   		nSaldoB2 :=	aSaldos[nPos][3]    		    	

   	    	If !(SD4->(eof()))
   	    		nQuant	:=  ROUND(SD4->D4_QUANT,4) 
   	    		//nQuant	:=  (ZZF->ZZF_QTDUSA - nSaldoB2) //ZZF->ZZF_QTDUSA
   	    	Else
   	    		nQuant	:=  ROUND(ZZF->ZZF_QTDUSA,4) 
   	    		//nQuant	:=  (SD4->D4_QUANT - nSaldoB2) 	 //SD4->D4_QUANT
   	    	EndIf

	   		IncProc( "Processando OP : "+Trim(SD4->D4_OP))  
            If aSaldos[nPos][3] < nQuant
				nSaldoB2 	:=	aSaldos[nPos][3] 
	   			nDocumento	:=  NextNumero("SD3",2,"D3_DOC",.T.)   //Gera o proximo numero de documento
				lAltaprop:=.F.		               		   			
		  		dBselectArea("ZZA") 
		    	dbSetorder(1)  
		     	SB1->(dbSeek(xFilial("ZZA")+SD4->D4_COD+SD4->D4_LOCAL))
		      	cTipo:= SB1->B1_TIPO

		       	If SB1->B1_APROPRI=='I'
		        	BEGIN TRANSACTION
		            	If SB1->(Found())
				        	RecLock("SB1",.F.)
				        		SB1->B1_APROPRI:='D'
				        	MsUnLock()
				         Endif	
			        END TRANSACTION
					lAltaprop:=.T.
				EndIf		

	   			nQuant := (nQuant - nSaldoB2) // atualizar o valor da variavel para gravação correta do valor na tabela de ocorrências	               		   		
	      		aVetor := {}
	        	aVetor := { {"D3_FILIAL"     	, xFilial("SD3")        		, NIL},;
	         				{"D3_TM"     		, "110"        					, NIL},;  //Falta de produção
			           		{"D3_COD"    		, SD4->D4_COD  					, NIL},;
			             	{"D3_LOCAL"  		, IIF(SD4->D4_LOCAL=='99',locItemInd(TMPZZR->C2_LOCAL,SB1->B1_TIPO,SB1->B1_APROPRI),SD4->D4_LOCAL), NIL},;
	    		          	{"D3_EMISSAO"		, DATE()  			   			, NIL},;   
			                {"D3_DOC"			, nDocumento  		  			, NIL},;
	    		            {"D3_UM"			, SB1->B1_UM  		 			, NIL},;
	    		            {"D3_OBS"			, SD4->D4_OP  	   				, NIL},;
	            		    {"D3_QUANT"  		, nQuant    	   				, NIL} }   
	        	lMsErroAuto:=.f.      
				MSExecAuto({|x,y| MATA240(x, y)}, aVetor, 3) 
	                                
				If lMsErroAuto
	   				mostraerro() 
		        Else    
	         		cClass	:="" 	// Classificação feita pelo usuario
            		cFlag	:="M"   // Flag do tipo de correçaõ feita pelo sistema
              		cCor	:="1" 	// Corrigida pelo sistema      
               		cDescr	:=""

					If  SD4->D4_LOCAL=='99' //Se o armazem for igual a 99 é preciso fazer a transferencia
	    				If a260Processa(SD4->D4_COD,locItemInd(TMPZZR->C2_LOCAL,SB1->B1_TIPO,SB1->B1_APROPRI), (nQuant) ,nDocumento,DATE(),,,,,,,SD4->D4_COD,SD4->D4_LOCAL,,,,,,,,,,,,,,,,,,,,,,)
	        				GravaZZR(TMPZZR->ZZA_ORDEM, TMPZZR->C2_LOCAL,TMPZZR->ZZA_PRODUT,TMPZZR->ZZA_LOTE,cClass, cDescr,nDocumento,SD4->D4_COD,SD4->D4_LOCAL,nQuant,cCor,cFlag,IIF(LEN(TMPZZR->ZZA_PRODUT)<12,'PI',IIF(SUBSTR(TMPZZR->ZZA_PRODUT,11,2) $ '00.99','PI','PA')))  //inclui o registro da ZZR
	            		EndIf	
	              	Else 
	               		GravaZZR(TMPZZR->ZZA_ORDEM, TMPZZR->C2_LOCAL,TMPZZR->ZZA_PRODUT,TMPZZR->ZZA_LOTE,cClass, cDescr,nDocumento,SD4->D4_COD,SD4->D4_LOCAL,nQuant,cCor,cFlag,IIF(LEN(TMPZZR->ZZA_PRODUT)<12,'PI',IIF(SUBSTR(TMPZZR->ZZA_PRODUT,11,2) $ '00.99','PI','PA')))  //inclui o registro da ZZR
	               	EndIf
	            EndIf

	   			dBselectArea("SB1")
		 		dbSetOrder(1)   
		 		SB1->(dbSeek(xFilial("SB1")+SD4->D4_COD+SD4->D4_LOCAL))
											
				If SB1->B1_APROPRI=='D' .And. lAltaprop
					IF SB1->(Found())
		   				BEGIN TRANSACTION
				     		RecLock("SB1",.F.)
				       			SB1->B1_APROPRI:='I'
				          	MsUnLock()
							lAltaprop:=.F.
				   		END TRANSACTION
				   	Endif
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
| Função | AliasTMPSG | Autor |Tiago Lucio | www.chaus.com.br |Data 24/04/2014 |
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
| Descrição | Função estatica para localizar o local do item da OP de acordo	| 
|				regra Brasilux para fabricas 1 e 2								|
|																				|
|																				|
|+------------------------------------------------------------------------------+
| Uso | SIGAPCP |																|
|+------------------------------------------------------------------------------+
/*/             


Static Function locItem(_localOp,_tipoItem,_apropItem)
   
Private cRetorno:=""
		If TRIM(_localOp)=='02'  
  			If  TRIM(_tipoItem)=='MP' 
     			if  TRIM(_apropItem)=='I'   //MP de apropriação indireta
        			cRetorno := '99' 
           		Else
             		cRetorno := '01' 
              	EndIf	
             ElseIf TRIM(_tipoItem)=='PI'
             	cRetorno := '02'
             EndIf
              			
        ElseIf TRIM(_localOp)=='20'  
        	If  TRIM(_tipoItem)=='MP'
            	if  TRIM(_apropItem)=='I'     //MP de apropriação indireta
              		cRetorno := '99' 
              	Else
              		cRetorno := '10' 
              	EndIf
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
        	if  TRIM(_tipoItem)=='MP'
            	cRetorno := '10'
            ElseIf TRIM(_tipoItem)=='PI'
            	cRetorno := '20'
            EndIf
        EndIf		

Return cRetorno 



/*/
+-----------------------------------------------------------------------------------+
| Função | locItemInd   | Autor |Tiago Lucio | www.chaus.com.br |Data 24/04/2014    |
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
  					if TRIM(_localOp)=='02'  
              			if  TRIM(_tipoItem)=='MP' 
              			
              					cRetorno := '01' 
              					
              			ElseIf TRIM(_tipoItem)=='PI'
              				cRetorno := '02'
              			EndIf
              			
              		ElseIf TRIM(_localOp)=='20'  
              			if  TRIM(_tipoItem)=='MP' 
              					cRetorno := '10' 
              				
              			ElseIf TRIM(_tipoItem)=='PI'
              					cRetorno := '20'
              			EndIf    
              			
              		ElseIf TRIM(_localOp)=='03.P1'  //Empenho de MP de Ordem de Envase  fabrica 1
              			if  TRIM(_tipoItem)=='MP'
              				cRetorno := '01'
              			ElseIf TRIM(SB1->B1_TIPO)=='PI'
              				cRetorno := '02'
              			EndIf	
              		ElseIf TRIM(_localOp)=='30.P2'  //Empenho de MP de Ordem de Envase  fabrica 2
              			if  TRIM(_tipoItem)=='MP'
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
 
Static Function gravaZZR(cOP, cLocal,cProduto,cLote,cClass, cDescr,cDoc,cItem,cLocItem,nQuant,cCor,cFlag,cTipo)

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
		ZZR->ZZR_QUANT 		:= ROUND(nQuant,4)
		ZZR->ZZR_COR 		:= cCor    
		ZZR->ZZR_FLAG 		:= cFlag 
		ZZR->ZZR_TIPO 		:= cTipo 
	MsUnLock() // Confirma e finaliza a operação


Return   

