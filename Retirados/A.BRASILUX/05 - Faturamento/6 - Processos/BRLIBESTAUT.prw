#include "RWMAKE.CH" 
#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "AP5MAIL.CH" 
                                           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LIBESTAUT บ Autor ณ Tiago Lucio(Chaus)บ Data ณ  05/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ                 
ฑฑบDesc.     ณ Realiza Libera็ใo de estoque automแtica                    บฑฑ               
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Faturamento                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                           


User Function LIBESTAUT()
Local i
Local aArea         := GetArea()
Local cQryLibEst    := ""
Local cQryEst       := ""
Local nQtdaLib      := 0    // Qtd a Liberar
Local aPedLib       := {}   // Array que recebe dados do C9 com qtd do jแ liberada em estoque
Local nQtdAnt       := 0    // Qtd que ficarแ bloqueada ap๓s a libera็ใo parcial
Local aRegAte		:= {}                                                                                      
Local lCompleto     :=.T.    //O pedido ้ completo at้ que se encontre um item que nใo tenha saldo em estoque 

//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101"

//If GetMV("MV_XLIBAUT")

	//cQryLibEst :=" SELECT C9_FILIAL,C9_PEDIDO,C9_CLIENTE FROM SC9010 SC9 WITH(NOLOCK) LEFT OUTER JOIN SC5010 SC5 WITH(NOLOCK) ON C9_FILIAL = C5_FILIAL AND C9_PEDIDO = C5_NUM AND SC5.D_E_L_E_T_ ='' "
	//cQryLibEst +=" WHERE SC9.D_E_L_E_T_ ='' AND C9_FILIAL ='010101' AND C5_LIBCAD ='T' AND C5_LIBPED ='T' AND C5_LIBCRE ='T' AND C5_LIBDIR ='T' AND C9_NFISCAL ='' AND C9_BLEST ='02' AND C5_APROVA <>'2' " 
	//cQryLibEst +=" WHERE SC9.D_E_L_E_T_ ='' AND C9_FILIAL ='010101' AND C5_LIBCAD ='T' AND C5_LIBPED ='T' AND C5_LIBCRE <> 'T' AND C5_LIBDIR ='F' AND C9_NFISCAL ='' AND C9_BLEST <>'02' AND C5_APROVA ='2' " 
    //cQryLibEst +="SELECT C5_APROVA ,* FROM SC5010 WHERE C5_FILIAL ='010101' AND C5_EMISSAO >='20100101' AND C5_EMISSAO <='20131231'  AND C5_APROVA ='2' AND C5_NOTA ='' AND D_E_L_E_T_ =''"

	//cQryLibEst +=" AND C9_PEDIDO IN('366183','366828','367392','367423','367425','367426','367434','367438','367440','367445','367451','367452','367453','367456','367457') "
	//cQryLibEst +=" GROUP BY C9_FILIAL,C9_PEDIDO,C9_CLIENTE "
	//cQryLibEst +=" ORDER BY C9_PEDIDO "
	
    cQryLibEst +=" SELECT DISTINCT C5_NUM, C5_CLIENTE, C5_FILIAL FROM SC9010 SC9 WITH (NOLOCK) LEFT OUTER JOIN SC5010 SC5 WITH (NOLOCK) ON (C5_FILIAL = C9_FILIAL) AND (C5_NUM = C9_PEDIDO) AND (SC5.D_E_L_E_T_ = '') LEFT OUTER JOIN SC6010 SC6 WITH (NOLOCK) ON (C5_FILIAL = C6_FILIAL) AND (C5_NUM = C6_NUM) AND (SC6.D_E_L_E_T_ = '') WHERE SC9.C9_FILIAL  = '010101' AND SC9.D_E_L_E_T_ = '' AND SC6.C6_ENTREG < ='20140615' AND (C5_TIPO  =  'N') AND (C5_FLAG  <> 'S') AND (C5_APROVA = '1') AND (C9_NFISCAL = '') ORDER BY C5_NUM "
	
	IF (Select("QRYLIBEST") > 0)
		QRYLIBEST->(DbCloseArea())
	EndIf
	//cQryLibEst := ChangeQuery(cQryLibEst)
	TCQUERY cQryLibEst NEW ALIAS "QRYLIBEST"
	QRYLIBEST->(DBGoTop())                                          
	
	If (QRYLIBEST->(EOF()))
		QRYLIBEST->(DbCloseArea())
		RestArea(aArea)
		Return Nil
	EndIf

	While !(QRYLIBEST->(EOF()))                               
	     aAdd(aRegAte, {QRYLIBEST->C5_NUM, QRYLIBEST->C5_CLIENTE, QRYLIBEST->C5_FILIAL}  )
    	//aAdd(aRegAte, {QRYLIBEST->C9_PEDIDO, QRYLIBEST->C9_CLIENTE, QRYLIBEST->C9_FILIAL}  )
	    QRYLIBEST->(DBSkip())
	EndDo
	
	QRYLIBEST->(DBCloseArea())
	
   //	aSort(aRegAte,,,{|x,y| Strzero(x[4],4)+ Strzero(x[5],4) < Strzero(y[4],4) +Strzero(y[5],4)} )                 //Ordena pela quantidade de produtos e depois pela quantidade de itens de produtos
	  
/**************************************************************************************/
/*** Estorno dos Pedidos Bloqueados Pelo Cr้dito - Ficarใo com Estoque Bloqueado
/**************************************************************************************/    
	If Len(aRegAte) > 0
	
 		For i = 1 to len(aRegAte)
			DBSelectArea("SC9")
			SC9->(DBSetOrder(1))
			SC9->(DbSeek(xFilial("SC9")+aRegAte[i,1]))	// C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
			While !(SC9->(eof())) .And.aRegAte[i,1] == SC9->C9_PEDIDO
				SC9->(a460Estorna())  // Estorna o registro
				SC9->(dbSkip())		 
			EndDo
			SC9->(DbCloseArea())  
					 
			DbSelectArea("SC6")	   
			SC6->(DbSetOrder(1))// C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_  
			SC6->(DbSeek(xFilial("SC6")+aRegAte[i,1]))
			
			While !(SC6->(eof())) .And. aRegAte[i,1] == SC6->C6_NUM 
					                                                       
			  	BEGIN TRANSACTION
	    			nQtdaLib:= SC6->C6_QTDVEN
               	// LIBERA CREDITO - BLOQUEIA ESTOQUE
   					MaLibDoFat(SC6->(RecNo()),nQtdaLib        ,.T.                 ,.F.                ,.T.                 ,.F.                 ,.F.                      ,.F.,,,,,,0,)
   			//MaLibDoFat(Registro do SC6 ,Quantidade a Liberar,Bloqueio de Credito ,Bloqueio de Estoque,Avaliacao de Credito,Avaliacao de Estoque,Permite Liberacao Parcial,Tranfere Locais automaticamente )
				END TRANSACTION		
				SC6->(dbSkip())		
	   	        Begin Transaction
        			SC6->(MaLiberOk({aRegAte[i,1]},.F.))
     			End Transaction
				
			EndDo 
		Next
	EndIf
//Endif		

/**************************************************************************************/
/*** Libera็ใo de Pedidos Incompletos	(Em estoque)                                  ***/
/**************************************************************************************/  
/*
	If Len(aRegAte) > 0
	
 		For i = 1 to len(aRegAte)
 		
 		
	  		//Busca os itens de cada pedido no border๔
			DbSelectArea("SC6")	   
			SC6->(DbSetOrder(1))// C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_  
			SC6->(DbSeek(xFilial("SC6")+aRegAte[i,1]))
			
			lCompleto:=.T. 
			
			While !(SC6->(eof())) .And. xFilial("SC6")== SC6->C6_FILIAL .And. aRegAte[i,1] == SC6->C6_NUM .And. lCompleto //Varre todos os itens de um pedido
				
				cQRYEST := " SELECT SB2.B2_COD, SB2.B2_QATU, SB2.B2_QEMP, SB2.B2_RESERVA, "
				cQRYEST += " (SB2.B2_QATU - (SB2.B2_QEMP + SB2.B2_RESERVA)) SALDO, SB2.B2_LOCAL  "			
				cQRYEST += " FROM " + RetSqlName("SB2") + " SB2 "
				cQRYEST += " WHERE ((SB2.B2_QATU - (SB2.B2_QEMP + SB2.B2_RESERVA)) > "+Str(SC6->C6_QTDVEN)+") AND SB2.B2_COD = '" +  Trim(SC6->C6_PRODUTO) + "' "			
				cQRYEST += " AND SB2.B2_LOCAL = '" + Trim(SC6->C6_LOCAL) + "' AND SB2.B2_FILIAL = '" + xFilial("SB2") + "' "
				cQRYEST += " AND SB2.D_E_L_E_T_ <> '*' "
				  
				TCQUERY cQRYEST NEW ALIAS "QRYEST"
				QRYEST->(DBGoTop())
				
					                                                        
				If (QRYEST->(eof()))       //Nใo tem saldo suficiente
					lCompleto:=.F. 	//Pedido nใo ้ completo	
				EndIf			
				SC6->(dbSkip())		
				QRYEST->(DBCloseArea())	
			EndDo
			
//			if lCompleto //Se ้ completo reserva estoque
					
				//	aRegAte[i,6]:='C' //Marca o item do array como completo
					
					
					DBSelectArea("SC9")
     				SC9->(DBSetOrder(1))	// C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
					SC9->(DbSeek(xFilial("SC9")+aRegAte[i,7])) // Posiciona no registro da SC9 que possue estoque liberado
					    	
					
					While !(SC9->(eof())) .And.aRegAte[i,1] == SC9->C9_PEDIDO //่ completo, varre todos os itens do pedido
								
						SC9->(a460Estorna())  // Estorna o registro
						SC9->(dbSkip())		 
					EndDo
					 
					
					DbSelectArea("SC6")	   
					SC6->(DbSetOrder(1))// C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_  
					SC6->(DbSeek(xFilial("SC6")+aRegAte[i,1]))
				
					While !(SC6->(eof())) .And. xFilial("SC6")== SC6->C6_FILIAL .And. aRegAte[i,1] == SC6->C6_NUM
						                                                       
						BEGIN TRANSACTION
     				 	
							 nQtdaLib:= SC6->C6_QTDVEN
							 
							 MaLibDoFat(SC6->(RecNo()),nQtdaLib,.T.,.T.,.T.,.F.,.F.,.F.,,,,,,0,)  
							 dbSelectArea("SZG")
							 SZG->(dbSetOrder(2)) 	//ZG_FILIAL, ZG_PEDIDO, ZG_CODIGO, R_E_C_N_O_, D_E_L_E_T_
							 dbSeek(xFilial("SZG")+aRegAte[i,7])
										
							 iF !(SZG->(eof()))
						    	SZG->(RecLock("SZG",.F.))
						        SZG->ZG_FLAGLIB:='2' //Marca o pedido como liberado
						        MsUnLock()
						     EndIf	  
							
				         END TRANSACTION		
						 SC6->(dbSkip())		
								
					EndDo
     				 
     				
			//EndIf
			
	
		Next
		
	EndIf
EndIf		
			
		/*	
		//	If (QRYLIBEST->C9_QTDLIB > QRYEST->SALDO) 
					If (aRegAte[i,6] > QRYEST->SALDO)
						nQtdaLib := QRYEST->SALDO                                                 
					Else
						nQtdaLib := aRegAte[i,6]
					EndIf
				  	QRYEST->(DBCloseArea())          
				  	
				  	aPedLib := GetPedAber(aRegAte[i,2],aRegAte[i,3])
		  			Begin Transaction 
						If !Empty(aPedLib)
							//cแculo da nova qtd a ser liberada					
							nQtdaLib := (nQtdaLib + aPedLib[1,2])
			
						    //Cแlculo da qtd restante para liberar no estoque
						    //nQtdAnt := (QRYLIBEST->C6_QTDEMP - nQtdaLib)
							nQtdAnt := (aRegAte[i,7] - nQtdaLib)
							                             
							DBSelectArea("SC9")
								SC9->(DbGoto(aPedLib[1,1])) // Posiciona no registro da SC9 que possue estoque liberado
								SC9->(a460Estorna()) // Estorna o registro
							//	SC9->(DbGoto(QRYLIBEST->SC9RECNO)) //Posiciona no registro da SC9 que possue estoque bloqueado 
								SC9->(DbGoto(aRegAte[i,9])) //Posiciona no registro da SC9 que possue estoque bloqueado
								SC9->(a460Estorna())  // Estorna o registro
							SC9->(DbCloseArea())  
														 
															
																	
							If Empty(aPedLib[1,3])// Se jแ foi realizado a liberacao do credito do pedido
								//Libera nova qtd, tanto no credito quanto estoque
								//MaLibDoFat(QRYLIBEST->(SC6RECNO),nQtdaLib,.T.,.T.,.F.,.F.,.F.,.F.,,,,,,0,)  
								MaLibDoFat(aRegAte[i,10],nQtdaLib,.T.,.T.,.F.,.F.,.F.,.F.,,,,,,0,)
								If (nQtdAnt > 0)// se a qtd restante a liberar for maior que zero
									//Libera a qtd restante, avaliando apenas o estoque
									//MaLibDoFat(QRYLIBEST->(SC6RECNO),nQtdAnt,.T.,.T.,.F.,.T.,.F.,.F.,,,,,,0,) 
									MaLibDoFat(aRegAte[i,10],VAL(TRANSFORM(nQtdAnt,"999,999,999.99")),.T.,.T.,.F.,.T.,.F.,.F.,,,,,,0,)
								EndIf
						    Else
						    	//Libera nova qtd avaliando credito
								//MaLibDoFat(QRYLIBEST->(SC6RECNO),nQtdaLib,.T.,.T.,.T.,.T.,.F.,.F.,,,,,,0,)	
								MaLibDoFat(aRegAte[i,10],nQtdaLib,.T.,.T.,.T.,.T.,.F.,.F.,,,,,,0,)			    	 
								If (nQtdAnt > 0)// se a qtd restante a liberar for maior que zero
									//Libera a qtd restante, avaliando o credito e o estoque
									//MaLibDoFat(QRYLIBEST->(SC6RECNO),nQtdAnt,.T.,.F.,.T.,.F.,.F.,.F.,,,,,,0,) 
									MaLibDoFat(aRegAte[i,10],VAL(TRANSFORM(nQtdAnt,"999,999,999.99")),.T.,.F.,.T.,.F.,.F.,.F.,,,,,,0,)
								EndIf
						    EndIf
						
						Else	
							//Cแlculo da qtd restante para liberar no estoque
						    //nQtdAnt := (QRYLIBEST->C6_QTDEMP - nQtdaLib)
						    nQtdAnt := (aRegAte[i,7] - nQtdaLib)
						    DBSelectArea("SC9")
							//SC9->(DbGoto(QRYLIBEST->SC9RECNO)) 
							SC9->(DbGoto(aRegAte[i,9]))
							SC9->(a460Estorna())
							SC9->(DbCloseArea())  
			      
	  //					If Empty(QRYLIBEST->C9_BLCRED) // Se pedido jแ estiver com o credito liberado 
	  						If Empty(aRegAte[i,8]) // Se pedido jแ estiver com o credito liberado
								//Libera nova qtd, tanto no credito quanto estoque
								//MaLibDoFat(QRYLIBEST->(SC6RECNO),nQtdaLib,.T.,.T.,.F.,.F.,.F.,.F.,,,,,,0,) 
								MaLibDoFat(aRegAte[i,10],nQtdaLib,.T.,.T.,.F.,.F.,.F.,.F.,,,,,,0,)
								If (nQtdAnt > 0)// se a qtd restante a liberar for maior que zero
									//Libera a qtd restante, avaliando apenas o estoque
									//MaLibDoFat(QRYLIBEST->(SC6RECNO),nQtdAnt,.T.,.T.,.F.,.T.,.F.,.F.,,,,,,0,) 
									MaLibDoFat(aRegAte[i,10],nQtdAnt,.T.,.T.,.F.,.T.,.F.,.F.,,,,,,0,)
								EndIf
							Else //Pedido bloqueado no credito
								//Libera nova qtd em estoque, avaliando o cr้dito
								//MaLibDoFat(QRYLIBEST->(SC6RECNO),nQtdaLib,.T.,.T.,.T.,.T.,.F.,.F.,,,,,,0,)					 
								MaLibDoFat(aRegAte[i,10],nQtdaLib,.T.,.T.,.T.,.T.,.F.,.F.,,,,,,0,)					
								If (nQtdAnt > 0)// se a qtd restante a liberar for maior que zero
									//Libera a qtd restante, avaliando o credito e o estoque
									//MaLibDoFat(QRYLIBEST->(SC6RECNO),nQtdAnt,.T.,.F.,.T.,.F.,.F.,.F.,,,,,,0,) 
									MaLibDoFat(aRegAte[i,10],VAL(TRANSFORM(nQtdAnt,"999,999,999.99")),.T.,.F.,.T.,.F.,.F.,.F.,,,,,,0,)
								EndIf
							EndIf
						EndIf
						//SC6->(MaLiberOk({QRYLIBEST->C6_NUM},.F.))
						SC6->(MaLiberOk({aRegAte[i,2]},.F.))
					End Transaction
				EndIf			 
		Next
		
	EndIf
EndIf */
	
RestArea(aArea) 

Return Nil       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GetPedAber บ Autor ณ Rafael (Chaus)  บ Data ณ  07/12/10    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel por verificar se o ํtem do pedido foi   บฑฑ
ฑฑบ          ณ liberado parcialmente.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Faturamento                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GetPedAber(_Ped,_Ite)

Local aRetorno := {}
	
cQryPedAber := " SELECT C9.R_E_C_N_O_ AS SC9RECNO, "
cQryPedAber += "		C9.C9_QTDLIB AS QTDLIB, "
cQryPedAber += "		C9.C9_BLCRED AS CRED "
cQryPedAber += " FROM "+RetSqlName("SC9")+" C9 "
cQryPedAber += " WHERE C9.C9_PEDIDO = '"+_Ped+"' "
cQryPedAber += " AND C9.C9_FILIAL = '"+xFilial("SC9")+"' "
cQryPedAber += " AND C9.C9_ITEM = '"+_Ite+"' " 
cQryPedAber += " AND C9.C9_BLEST = '' "
cQryPedAber += " AND C9.C9_NFISCAL = '' " 
cQryPedAber += " AND C9.C9_XCGFLAG <> 'S' " 
cQryPedAber += " AND C9.D_E_L_E_T_ = '' "   
	
cQryPedAber := ChangeQuery(cQryPedAber)
TCQUERY cQryPedAber NEW ALIAS "QRYPEDABER"
QRYPEDABER->(DBGoTop())                                          
	
If (QRYPEDABER->(!EOF()))
 AADD(aRetorno,{QRYPEDABER->SC9RECNO,QRYPEDABER->QTDLIB,QRYPEDABER->CRED}) 	 
EndIf

QRYPEDABER->(DbCloseArea()) 
 
Return (aRetorno)