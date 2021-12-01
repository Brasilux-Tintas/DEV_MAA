#include "RWMAKE.CH" 
#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "TBICONN.CH"
                                           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma  ณ LIBESTAUT บ Autor ณ Andr้ Maester       บ Data ณ 23/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ                 
ฑฑบDesc.     ณ Realiza Libera็ใo de estoque conforme a defini็ใo das regrasบฑฑ
ฑฑ 1บ Border๔ mais antigo 												   บฑฑ
ฑฑ 2บ Pedidos Completos com produtos em estoque							   บฑฑ
ฑฑ	•	Pedidos Com menor Volume										   บฑฑ
ฑฑ	•	Pedidos Com menor quantidade de itens diferentes                   บฑฑ
ฑฑ3บPedidos Incompletos que cont้m somente produto classe “AB” da curva ABCบฑฑ
ฑฑ	•	Pedidos Com menor Volume                                           บฑฑ
ฑฑ	•	Pedidos Com menor quantidade de itens diferentes                   บฑฑ
ฑฑ 4บ Pedidos Incompletos que nใo somente produto classe “AB” da curva ABC บฑฑ
ฑฑ 	•	Pedidos Com menor Volume										   บฑฑ
ฑฑ	•	Pedidos Com menor quantidade de itens diferentes                   บฑฑ               
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Faturamento                                                 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                           
/*
User Function BRSCHLEST(aParm)
     Local aParm        := Iif(ValType(aParm) == 'U', {"01", "010101", "2"}, aParm)
     Local cEmp         := Alltrim(Transform(aParm[1],'@!'))
     Local cFil         := Alltrim(Transform(aParm[2],'@!'))
     Local nOpc         := Alltrim(Transform(aParm[3],'@!')) 
     Private lEndThread
     //ConOut("******************************************************************")
     //ConOut("*  BRSCHLEST - LIBERA RESERVA DE ESTOQUE DOS PEDIDOS  EM BORDERO *")
     //ConOut("******************************************************************")
     lEndThread := .f.
     If nOpc == '1'
        PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil TABLES "SB1", "SB2", "SZG", "SB3", "SC9", "SC5"
      	  //ConOut("-- INICIO")
        	  U_BRFATLIBEST(nOpc, cEmp, cFil ) 
          //ConOut("-- FIM")
        RESET ENVIRONMENT
     Else
        Processa( { |lEnd| U_BRFATLIBEST(nOpc, cEmp, cFil ) }, "Reserva Estoque de Pedidos em Border๔", ,.t.) 
     Endif
Return(Nil) */

User Function BRFATLIBEST(cBordero, cTipoPed, nTipoBaixa ,cProduto) 

// BORDERO A SER PROCESSADO -NUMERO DO BORDERO    
// TIPO PEDIDO A PROCESSAR  -1-NรO PROCESSADOS / 2-JA PROCESSADOS
// TIPO BAIXA               -1-TODOS OU 2-SOMENTE INCOMPLETOS   
// PRODUTO                  -CODIGO DO PRODUTO
		
//Local cBordero                                                                                                      
//Local nTipoBor
//Local nTipoBaixa
//Local cProduto
Local aArea         := GetArea()
Local i
Local cQryLibEst    := ""
Local cQryEst       := ""
Local lCompleto     :=.T.    //O pedido ้ completo at้ que se encontre um item que nใo tenha saldo em estoque 
Local lReservaItem  :=.F.                                                                                           

If !GetMv("MV_XHABBOR") .and. cNumEmp <> ('01010101')
	MsgBox("Empresa nใo utiliza esta rotina ou parametro MV_XHABBOR nใo configurado!!", "Aten็ใo", "STOP")
    Return
Endif

If nTipoBaixa =1 // TODOS OS PEDIDOS OU SOMENTE INCOMPLETOS
	
	//Query de acordo politica de libera็ใo de estoque Brasilux
	cQryLibEst += " WITH TMP AS (SELECT DISTINCT C9_PEDIDO AS PEDIDO FROM "+RetSqlName("SC9")+" WITH(NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (C9_FILIAL = '"+XFilial("SC9")+"') AND (C9_BLEST = '02')) "
	cQryLibEst += " SELECT ZG_CODIGO,PEDIDO, C5_VOLUME1 AS QTDEVOL, "
	cQryLibEst += " QTDEITENS = (SELECT COUNT(R_E_C_N_O_) FROM "+RetSqlName("SC6")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+XFilial("SC6")+"') AND (C6_NUM = TMP.PEDIDO)), "
	cQryLibEst += " CLASSEAB = (SELECT COUNT(SB3.R_E_C_N_O_) FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
	cQryLibEst += " LEFT OUTER JOIN "+RetSqlName("SB3")+" SB3 WITH (NOLOCK) ON (SB3.D_E_L_E_T_ <> '*') AND (B3_FILIAL = C6_FILIAL) AND (B3_COD = C6_PRODUTO) "
	cQryLibEst += " WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+XFilial("SC6")+"') AND (C6_NUM = TMP.PEDIDO) AND (B3_CLASSE IN ('A','B'))), "
	cQryLibEst += " ITEMJALIB = (SELECT COUNT(R_E_C_N_O_) FROM "+RetSqlName("SC9")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <>'*') AND C9_BLEST ='' AND C9_FILIAL ='"+XFilial("SC9")+"' AND C9_PEDIDO =TMP.PEDIDO) "
	cQryLibEst += " FROM TMP  "
	cQryLibEst += " LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH(NOLOCK) ON (SZG.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = '"+XFilial("SZG")+"') AND (SUBSTRING(ZG_PEDIDO,3,6) = TMP.PEDIDO) "
	cQryLibEst += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+XFilial("SC5")+"') AND (TMP.PEDIDO = C5_NUM) "
	cQryLibEst += " WHERE (SZG.R_E_C_N_O_ IS NOT NULL) "
	If !Empty(cBordero)
		cQryLibEst += " AND (SZG.ZG_CODIGO ='"+cBordero+"') "  // NฺMERO DO BORDERO A SER PROCESSADO
	Endif
	If cTipoPed $ '1.2'  // 1-NรO PROCESSADOS / 2-JA PROCESSADOS
		cQryLibEst += " AND (SZG.ZG_FLAGLIB ='"+cTipoPed+"') "  // TIPO PEDIDO A PROCESSAR  -1-NรO PROCESSADOS / 2-JA PROCESSADOS
	Endif
	If !Empty(cProduto) // USAR A MESMA REGRA DE LIBERAวรO NA RAMPA (IDENFICANDO O PRODUTO NA TRANFERสNCIA DE ENDEREวO ALMO PRODUวรO P/ ALMO ESTOQUE
		cQryLibEst += " AND (SELECT COUNT(R_E_C_N_O_) FROM "+RetSqlName("SC6")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+XFilial("SC6")+"') AND (C6_NUM = TMP.PEDIDO) AND  (C6_PRODUTO ='"+cProduto+"'))  >0  "
    Endif
	cQryLibEst += " AND (SELECT COUNT(R_E_C_N_O_) FROM SC9010 WITH (NOLOCK) WHERE (D_E_L_E_T_ <>'*') AND C9_BLEST ='' AND C9_FILIAL ='"+XFilial("SC9")+"' AND C9_PEDIDO =TMP.PEDIDO)  =0  "
	cQryLibEst += " ORDER BY ZG_CODIGO,QTDEVOL,QTDEITENS  "

	IF (Select("QRYLIBEST") > 0 )
   		QRYLIBEST->(DbCloseArea())
	EndIf
	TCQUERY cQryLibEst NEW ALIAS "QRYLIBEST"
	QRYLIBEST->(DBGoTop())                                          
	  
/**************************************************************************************/
/*** Libera็ใo de Pedidos Completos			                                       ***/
/**************************************************************************************/    
	While !QRYLIBEST->(EOF()) 
		If QRYLIBEST->ITEMJALIB =0    // S๓ entrar na rotina pedidos que nใo tem nenhum item liberado                 
			lCompleto := .T.
			DbSelectArea("SC6")	   
			SC6->(DbSetOrder(1))// C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_  
			SC6->(DbSeek(xFilial("SC6")+QRYLIBEST->PEDIDO))

			While !(SC6->(eof())) .And. xFilial("SC6")== SC6->C6_FILIAL .And. QRYLIBEST->PEDIDO == SC6->C6_NUM .And. lCompleto //Varre todos os itens de um pedido
				cQRYEST := " SELECT SB2.B2_COD, SB2.B2_QATU, SB2.B2_QEMP, SB2.B2_RESERVA, SC9.C9_BLEST, "
				cQRYEST += " (SB2.B2_QATU - (SB2.B2_QEMP + SB2.B2_RESERVA)) SALDO, SB2.B2_LOCAL  "			
				cQRYEST += " FROM " + RetSqlName("SB2") + " SB2 WITH (NOLOCK) LEFT OUTER JOIN "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) ON B2_FILIAL = C9_FILIAL AND B2_COD = C9_PRODUTO AND B2_LOCAL = C9_LOCAL AND SC9.D_E_L_E_T_ ='' "
				cQRYEST += " WHERE ((SB2.B2_QATU - (SB2.B2_QEMP + SB2.B2_RESERVA)) >= "+Str(SC6->C6_QTDVEN)+") AND SB2.B2_COD = '"+Alltrim(SC6->C6_PRODUTO)+"' "			
				cQRYEST += " AND SC9.C9_PEDIDO ='"+Alltrim(SC6->C6_NUM)+"' AND SB2.B2_LOCAL ='"+Alltrim(SC6->C6_LOCAL)+"' AND SB2.B2_FILIAL = '"+ xFilial("SB2")+"'"
				cQRYEST += " AND SB2.D_E_L_E_T_ = '' "
				  
				TCQUERY cQRYEST NEW ALIAS "QRYEST"
				QRYEST->(DBGoTop())
					                                                        
				If (QRYEST->(eof()))    
					If Posicione("SF4", 1, xFilial("SF4")+SC6->C6_TES, "F4_ESTOQUE") ='S'
						lCompleto:=.F. 	//Pedido nใo ้ completo	
					Endif
				EndIf			
				SC6->(dbSkip())		
				QRYEST->(DBCloseArea())	
			EndDo
			
			If lCompleto //Se ้ completo reserva estoque
				DBSelectArea("SC9")
   				SC9->(DBSetOrder(1))	// C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
				SC9->(DbSeek(xFilial("SC9")+QRYLIBEST->PEDIDO)) // Posiciona no registro da SC9 que possue estoque liberado
    
				While !(SC9->(eof())) .And. (xFilial("SC9")== SC9->C9_FILIAL) .And. (QRYLIBEST->PEDIDO == SC9->C9_PEDIDO) //่ completo, varre todos os itens do pedido
					SC9->(a460Estorna())  // Estorna o registro
					SC9->(dbSkip())		 
				EndDo
				DbSelectArea("SC9")
				DbCloseArea()	
				                 
				DbSelectArea("SC6")	   
				SC6->(DbSetOrder(1))// C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_  
				SC6->(DbSeek(xFilial("SC6")+QRYLIBEST->PEDIDO))
				While !(SC6->(eof())) .And. (xFilial("SC6")== SC6->C6_FILIAL) .And. (QRYLIBEST->PEDIDO == SC6->C6_NUM)
					BEGIN TRANSACTION
                        If Posicione("SF4", 1, xFilial("SF4")+SC6->C6_TES, "F4_ESTOQUE") $ 'N'
 			                MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN         ,.T.                 ,.F.                ,.T.                 ,.T.                 ,.F.                      ,.F.)  
                        Else
                        // LIBERA AVALIANDO APENAS ESTOQUE
					  		MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN         ,.T.                 ,.T.                ,.F.                 ,.T.                 ,.F.                      ,.F.,,,,,,0,)  
	    	               //MaLibDoFat(Registro do SC6 ,Quantidade a Liberar,Bloqueio de Credito ,Bloqueio de Estoque,Avaliacao de Credito,Avaliacao de Estoque,Permite Liberacao Parcial,Tranfere Locais automaticamente )
						Endif
				    END TRANSACTION		
					SC6->(dbSkip())		
				EndDo
				BEGIN TRANSACTION
					SC6->(MaLiberOk({QRYLIBEST->PEDIDO},.F.))  //APROVAวรO DO PEDIDO
				END TRANSACTION
				DbSelectArea("SC6")
				DbCloseArea()

			   	DbSelectArea("SZG")
				SZG->(dbSetOrder(2)) 	//ZG_FILIAL, ZG_PEDIDO, ZG_CODIGO, R_E_C_N_O_, D_E_L_E_T_
				DbSeek(xFilial("SZG")+'01'+QRYLIBEST->PEDIDO)
				If !(SZG->(eof()))
					BEGIN TRANSACTION
			   	   		SZG->(RecLock("SZG",.F.))
				    	SZG->ZG_FLAGLIB:='2' //Marca o pedido como processado
				    	MsUnLock()
					END TRANSACTION
				EndIf
			   	DbSelectArea("SZG")
	            DbCloseArea()
	   		Endif
		Endif
		DbSelectArea("QRYLIBEST")
	    DbSkip()
	Enddo

	QRYLIBEST->(DBCloseArea())

Endif
	
	/**************************************************************************************/
	/*** Libera็ใo de Pedidos Incompletos	                                            ***/
	/**************************************************************************************/  

	cQryLibEst := ""
	//Query de acordo politica de libera็ใo de estoque Brasilux Para Pedidos Incompletos
	cQryLibEst += " WITH TMP AS (SELECT DISTINCT C9_PEDIDO AS PEDIDO FROM "+RetSqlName("SC9")+" WITH(NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (C9_FILIAL = '"+XFilial("SC9")+"') AND (C9_BLEST = '02')) "
	cQryLibEst += " SELECT ZG_CODIGO,PEDIDO, C5_VOLUME1 AS QTDEVOL, "
	cQryLibEst += " QTDEITENS = (SELECT COUNT(R_E_C_N_O_) FROM "+RetSqlName("SC6")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+XFilial("SC6")+"') AND (C6_NUM = TMP.PEDIDO)), "
	cQryLibEst += " CLASSEAB = (SELECT COUNT(SB3.R_E_C_N_O_) FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
	cQryLibEst += " LEFT OUTER JOIN "+RetSqlName("SB3")+" SB3 WITH (NOLOCK) ON (SB3.D_E_L_E_T_ <> '*') AND (B3_FILIAL = C6_FILIAL) AND (B3_COD = C6_PRODUTO) "
	cQryLibEst += " WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+XFilial("SC6")+"') AND (C6_NUM = TMP.PEDIDO) AND (B3_CLASSE IN ('A','B'))), " 
	cQryLibEst += " ITEMJALIB = (SELECT COUNT(R_E_C_N_O_) FROM "+RetSqlName("SC9")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <>'*') AND C9_BLEST ='' AND C9_FILIAL ='"+XFilial("SC9")+"' AND C9_PEDIDO =TMP.PEDIDO) "
	cQryLibEst += " FROM TMP " 
	cQryLibEst += " LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH(NOLOCK) ON (SZG.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = '"+XFilial("SZG")+"') AND (SUBSTRING(ZG_PEDIDO,3,6) = TMP.PEDIDO) "
	cQryLibEst += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+XFilial("SC5")+"') AND (TMP.PEDIDO = C5_NUM) "
	cQryLibEst += " WHERE (SZG.R_E_C_N_O_ IS NOT NULL) AND (SZG.ZG_FLAGLIB ='1') " 
	If !Empty(cBordero) 
		cQryLibEst += " AND (SZG.ZG_CODIGO ='"+cBordero+"') "  // NฺMERO DO BORDERO A SER PROCESSADO
	Endif
	If cTipoPed $ '1.2'  // 1-NรO PROCESSADOS / 2-JA PROCESSADOS
		cQryLibEst += " AND (SZG.ZG_FLAGLIB ='"+cTipoPed+"') "  // TIPO PEDIDO A PROCESSAR  -1-NรO PROCESSADOS / 2-JA PROCESSADOS
	Endif
	If !Empty(cProduto) // USAR A MESMA REGRA DE LIBERAวรO NA RAMPA (IDENFICANDO O PRODUTO NA TRANFERสNCIA DE ENDEREวO ALMO PRODUวรO P/ ALMO ESTOQUE
		cQryLibEst += " AND (SELECT COUNT(R_E_C_N_O_) FROM "+RetSqlName("SC6")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+XFilial("SC6")+"') AND (C6_NUM = TMP.PEDIDO) AND  (C6_PRODUTO ='"+cProduto+"'))  >0  "
    Endif
	cQryLibEst += " ORDER BY ZG_CODIGO,QTDEVOL,QTDEITENS  "

	IF (Select("QRYLIBEST") > 0 )
   		QRYLIBEST->(DbCloseArea())
	EndIf
	TCQUERY cQryLibEst NEW ALIAS "QRYLIBEST"
	
	If (QRYLIBEST->(EOF()))
		QRYLIBEST->(DbCloseArea())
		RestArea(aArea)
		Return Nil
	EndIf

	For i = 1 to 2  // liberar primeiro os pedidos que tenham somente itens classe a e b e na segunda passada liberar pedidos que contenham produtos que nใo somente a e b
		QRYLIBEST->(DBGoTop())                                          
		While !QRYLIBEST->(EOF()) 
			If Iif(i= 1,(QRYLIBEST->CLASSEAB = QRYLIBEST->QTDEITENS), (QRYLIBEST->CLASSEAB < QRYLIBEST->QTDEITENS))                                     
				lReservaItem :=.F.
				DbSelectArea("SC6")	   
				SC6->(DbSetOrder(1))// C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_  
				SC6->(DbSeek(xFilial("SC6")+QRYLIBEST->PEDIDO))
				While !(SC6->(eof())) .And. (xFilial("SC6")== SC6->C6_FILIAL) .And. (QRYLIBEST->PEDIDO == SC6->C6_NUM)   //Varre todos os itens de um pedido
					cQRYEST := " SELECT SB2.B2_COD, SB2.B2_QATU, SB2.B2_QEMP, SB2.B2_RESERVA, SC9.C9_BLEST, SC9.C9_ITEM, " 
					cQRYEST += " (SB2.B2_QATU - (SB2.B2_QEMP + SB2.B2_RESERVA)) SALDO, SB2.B2_LOCAL  "			
					cQRYEST += " FROM " + RetSqlName("SB2") + " SB2 WITH (NOLOCK) LEFT OUTER JOIN "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) ON B2_FILIAL = C9_FILIAL AND B2_COD = C9_PRODUTO AND B2_LOCAL = C9_LOCAL AND SC9.D_E_L_E_T_ ='' "
					cQRYEST += " WHERE ((SB2.B2_QATU - (SB2.B2_QEMP + SB2.B2_RESERVA)) >= "+Str(SC6->C6_QTDVEN)+") AND SB2.B2_COD = '" +  Trim(SC6->C6_PRODUTO) + "' "			
					cQRYEST += " AND SC9.C9_PEDIDO ='"+Alltrim(SC6->C6_NUM)+"' AND SB2.B2_LOCAL ='"+Alltrim(SC6->C6_LOCAL)+"' AND SB2.B2_FILIAL = '"+xFilial("SB2")+"'"
					cQRYEST += " AND SB2.D_E_L_E_T_ = '' "
				  
					TCQUERY cQRYEST NEW ALIAS "QRYEST"
					QRYEST->(DBGoTop())
                                   
					If (QRYEST->(!eof())) .AND. !Empty(QRYEST->C9_BLEST)   
						lReservaItem:=.T. 	// Reserva Item com Estoque Suficiente
						DBSelectArea("SC9")
						SC9->(DBSetOrder(1))	// C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
						SC9->(DbSeek(xFilial("SC9")+QRYLIBEST->PEDIDO+SC6->C6_ITEM)) // Posiciona no registro da SC9 que possue estoque liberado
						While !(SC9->(eof())) .And. (xFilial("SC9")== SC9->C9_FILIAL) .And. (QRYLIBEST->PEDIDO == SC9->C9_PEDIDO) .AND. (SC6->C6_ITEM == SC9->C9_ITEM)  //่ completo, varre todos os itens do pedido
							SC9->(a460Estorna())  // Estorna o registro
							SC9->(dbSkip())		 
						EndDo
						DbSelectArea("SC9")
						DbCloseArea()	

						BEGIN TRANSACTION
                                        // LIBERA AVALIANDO APENAS ESTOQUE
                    	   		        //(Registro do SC6  ,Quantidade a Liberar,Bloqueio de Credito,Bloqueio de Estoque,Avaliacao de Credito,Avaliacao de Estoque,Permite Liberacao Parcial,Tranfere Locais automaticamente )
	    	           		MaLibDoFat(SC6->(RecNo()) ,SC6->C6_QTDVEN            ,.T.                ,.T.                ,.F.               ,.T.                 ,.F.                      ,.F.,,,,,,0,)
							//If (QRYLIBEST->QTDEITENS - QRYLIBEST->ITEMJALIB) =1 // SE FOR O ฺLTIMO ITEM A SER LIBERADO - MARCA O PEDIDO COMO TOTALMENTE COMPLETO
							//	DbSelectArea("SZG")
							// 	SZG->(dbSetOrder(2)) 	//ZG_FILIAL, ZG_PEDIDO, ZG_CODIGO, R_E_C_N_O_, D_E_L_E_T_
							// 	DbSeek(xFilial("SZG")+'01'+QRYLIBEST->PEDIDO)
							// 	If !(SZG->(eof()))
						    //		SZG->(RecLock("SZG",.F.))
						    //    	SZG->ZG_FLAGLIB:='2' //Marca o pedido como completamente liberado
						    //    	MsUnLock()
						    // 	EndIf
		     				// 	DbSelectArea("SZG")
				    	    //  DbCloseArea()
							//Endif						
						END TRANSACTION		
					EndIf			
					SC6->(dbSkip())		

					DbSelectArea("QRYEST")
					DBCloseArea()	
				EndDo
				If lReservaItem
					Begin Transaction
	   					SC6->(MaLiberOk({QRYLIBEST->PEDIDO},.F.))
					End Transaction
				Endif
			   	
			   	DbSelectArea("SZG")
				SZG->(dbSetOrder(2)) 	//ZG_FILIAL, ZG_PEDIDO, ZG_CODIGO, R_E_C_N_O_, D_E_L_E_T_
				DbSeek(xFilial("SZG")+'01'+QRYLIBEST->PEDIDO)
				If !(SZG->(eof()))
					BEGIN TRANSACTION
			   	   		SZG->(RecLock("SZG",.F.))
				    	SZG->ZG_FLAGLIB:='2' //Marca o pedido processado pela Rotina
				    	MsUnLock()
					END TRANSACTION
				EndIf
			   	DbSelectArea("SZG")
	            DbCloseArea()
				
				DbSelectArea("SC6")
				DbCloseArea()
			Endif
			DbSelectArea("QRYLIBEST")
       		DbSkip()
		Enddo
	Next
	DbSelectArea("QRYLIBEST")
   	DbCloseArea()
	
RestArea(aArea) 
Return Nil       
