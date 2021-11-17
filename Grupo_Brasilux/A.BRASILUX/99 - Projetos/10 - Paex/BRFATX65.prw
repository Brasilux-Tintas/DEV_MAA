#INCLUDE 'PROTHEUS.CH'                                          
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'COLORS.CH'                                                                              
#INCLUDE 'FONT.CH'                                                                            
#INCLUDE 'INKEY.CH'
#INCLUDE 'vkey.CH'
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BRFATX65  ³ Autor ³ André Maester       ³ Data ³ 12/12/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Transferência de Pallets em Lote                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function BRFATX65()
     Private cGet1Env   := Space(11) //"      /    "	// Pallet
     Private cSay4Env   := Space(20)
     Private cSay3Env   := Space(30)
     Private cGet5Env   := Space(02)
     Private cGet6Env   := Space(02)
     Private cCor4Env   := 0
     Private nCount     := 0
     Private cPallet    := ""
     Private cCodBarra 	:= ""
     Private lJaFech    := .f.
     Private lTelaJaFechada := .f.
     Private aDelete    :={} //  aAdd(aDelete, { cGet1Env, cCodBarra } )     
	 Private lCBox1En   := .f. 
	 Private lCboxTr    := .f.
	 Private oTempTbl1
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFontEnv", "oFon3Env", "oDlg1Env", "oGrp1Env", "oSay1Env", "oSay2Env", "oGet1Env", "oGet2Env", "oBtn1Env", "oBtn2Env","oCBox1En")
     SetPrvt("oBtn3Env", "oBtn4Env", "oBtn5Env", "oBtn6Env", "oBtn7Env", "oBrw1Env", "oGrp3Env", "oSay4Env", "oBtn6Env", "oSay3Env","oSay7Env","oSay8Env")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

     oFontEnv   := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
     oFon2Env   := TFont():New( "Courier New"  , 0,  19, , .T., 0, , 400, .F., .F., , , , , , )
     oFon3Env   := TFont():New( "Courier New"  , 0,  25, , .T., 0, , 400, .F., .F., , , , , , )
     
     oDlg1Env   := MSDialog():New( 140, 264, 680, 980, "Transferencia de Pallets", , , .F., , , , , , .T., , , .T. )
     oGrp1Env   := TGroup():New( 003, 004, 048, 356, "Dados do Pallet", oDlg1Env, CLR_RED, CLR_WHITE, .T., .F. )
     oSay1Env   := TSay():New( 012, 008, { || "Pallet:"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
     oGet1Env   := TGet():New( 010, 040, { |u| If(PCount() > 0, cGet1Env := u, cGet1Env)}, oGrp1Env, 073, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGet1Env", , ) 
     oGet1Env:bLostFocus := {|| Iif(!Empty(Alltrim(cGet1Env)),fInfPall(cGet1Env),"")}
     
     oSay4Env   := TSay():New( 030, 152, { || cSay4Env  }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., cCor4Env, CLR_WHITE, 106, 012)
     oBtn1Env   := TButton():New( 009, 297, "Confirma", oGrp1Env, {|| fTrPLote()}, 052, 016, , oFontEnv, , .T., , "", , , , .T. )
     oBtn2Env   := TButton():New( 030, 297, "Abandona", oGrp1Env, {|| fSairTPa()}, 052, 016, , oFontEnv, , .T., , "", , , , .F. )
     oGrp2Env   := TGroup():New( 050, 004, 268, 356, "", oDlg1Env, CLR_BLACK, CLR_WHITE, .T., .F. )
     
     oCBox1En   := TCheckBox():New( 057, 284, "Pallet Compra", {|u| If(PCount() > 0, lCBox1En := u, lCBox1En) }, oGrp2Env, 69, 008, , ,oFon2Env , , CLR_BLACK, CLR_WHITE, , .T., "",  , {|| fPreeLocal()} )
     oCBox1Tr   := TCheckBox():New( 067, 284, "Altera Local", {|u| If(PCount() > 0, lCboxTr := u, lCboxTr) }, oGrp2Env, 69, 008, , ,oFon2Env , , CLR_BLACK, CLR_WHITE, , .T., "",  , {|| fPreeLocal()} )

     //oCBox1En:bLostFocus := {|| fPreeLocal()}
     
     oBtn3Env   := TButton():New( 078, 290, "<- Incluir ->" , oGrp2Env, {|| fMLocPall(1) }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )
     oBtn4Env   := TButton():New( 098, 290, "<- Excluir ->" , oGrp2Env, {|| fMLocPall(2) }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )

     oSay5Env   := TSay():New( 012, 120, {|| "Origem:"      }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 012)
     oGet5Env   := TGet():New( 010, 156, {|u| If(PCount() > 0, cGet5Env := u, cGet5Env)}, oDlg1Env, 024, 012, '@R X9'          , , CLR_BLACK, CLR_WHITE, oFontEnv, , , .T., "", , , .F., .F., , .F. , .F., "99"    ,"cGet5Env", , )
     oSay6Env   := TSay():New( 012, 200, {|| "Destino:"     }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 012)
     oGet6Env   := TGet():New( 010, 240, {|u| If(PCount() > 0, cGet6Env := u, cGet6Env)}, oDlg1Env, 024, 012, '@R X9'          , , CLR_BLACK, CLR_WHITE, oFontEnv, , , .T., "", , , .F., .F., , .F. , .F., "99"    ,"cGet6Env", , )
	 
	 oGet5Env:bLostFocus := {|| Iif(!Empty(Alltrim(cGet5Env)),fVerLocal(),"")}
	 oGet6Env:bLostFocus := {|| Iif(!Empty(Alltrim(cGet5Env)),fVerLocal(),"")}
     
     oSay7Env   := TSay():New( 245, 338, { || nCount}    , oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 020, 020)
     oSay8Env   := TSay():New( 245, 283, { || "Pallets:"}, oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 050, 020)
     //oBtn5Env 	:= TButton():New( 238, 290, "<-Transfere->" , oGrp2Env, {|| fTrLocais( )  }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )     
     oSay3Env   := TSay():New( 0295, 018, { || cSay3Env  },   oGrp1Env, , oFon2Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 240, 012)

     oBtn6Env 	:= TButton():New( 128, 290, "<- Res 1 ->" , oGrp2Env, {|| U_fResPallet(1) }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )
 	 oBtn6Env:lVisibleControl := .f.	
     oBtn7Env 	:= TButton():New( 148, 290, "<- Res 2 ->" , oGrp2Env, {|| U_fResPallet(2) }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )
 	 oBtn7Env:lVisibleControl := .f.	

     oTblTrans()
     DbSelectArea("TMPTRANS")
     DbSetOrder(1)
     DbGoTop()
     oBrw1Env   := MsSelect():New( "TMPTRANS", "", "", { {"TMPPAL", "", "Pallet", "@!"}, {"TMPORI", "", "Origem", "@!"}, { "TMPDES", "", "Destino", "@!"},{ "TMPSTA", "", "Status", "@!"},{ "TMPUNI", "", "Qtd. Unit", "@!"}}, .F., , {056, 007, 266, 280}, , , oGrp2Env ) 
     
     oBrw1Env:oBrowse:oFont          := oFon2Env
     oBrw1Env:oBrowse:lAdjustColSize := .t.
     oBrw1Env:oBrowse:Refresh()
   	 oBtn3Env:SetFocus()
     
     oDlg1Env:Activate(,,,.T.)
     
     If !lJaFech
     	lTelaJaFechada := .t.
     Endif
     If ValType( oTempTbl1 ) == 'O'
	     oTempTbl1:Delete()
	 Endif	 

Return  
  
Static Function fVerLocal()
	
	If Empty(Alltrim(cGet5Env)) .or. Empty(Alltrim(cGet6Env)) 
		Return
	Endif
	If (Len(Alltrim(cGet5Env)) <> 2) 
		Messagebox("Verifique o Almoxarifado digitado no Campo Local Origem !!!","Atenção...",48)	
		Return
	Endif
	If (Len(Alltrim(cGet6Env)) <> 2)
		Messagebox("Verifique o Almoxarifado digitado no Campo Local Destino !!","Atenção...",48)	
		Return
	Endif

	cGet5Env := UPPER(cGet5Env)
	cGet6Env := UPPER(cGet6Env)	
	If !Empty(Alltrim(cGet5Env)) .and. lCboxTr
		If Alltrim(cGet5Env) = 'P1'
		 	cGet6Env :='03'	
		ElseIf Alltrim(cGet5Env) = 'P2'
		 	cGet6Env :='30'
		ElseIf Alltrim(cGet5Env) = '30'
		 	cGet6Env :='03'
		ElseIf Alltrim(cGet5Env) = '10'
		 	cGet6Env :='01'
		ElseIf Alltrim(cGet5Env) = '01'
		 	cGet6Env :='10'
		Endif

	Endif

Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fSairTPa() Função para perguntar antes de fechar a tela
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

 
Static Function fPreeLocal()

	If (lCBox1En) .and. !(lCboxTr)
		cGet5Env := '30'	
		cGet6Env := '03'
		oGet5Env:lReadOnly := .t.
		oGet6Env:lReadOnly := .t.	
	Else
		//cGet5Env := Space(2)	
		//cGet6Env := Space(2)
		oGet5Env:lReadOnly := .f.
		oGet6Env:lReadOnly := .f.	
	Endif
    //oBtn3Env:Setfocus()
    oGet5Env:Refresh()
    oGet6Env:Refresh()
Return()

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fSairTPa() Função para perguntar antes de fechar a tela
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fSairTPa()
/*	
	Local lRet

	If ChkFile("TMPTRANS")
	   	DbSelectArea("TMPTRANS")
	   	DbSetOrder(1)
	   	DbSeek(Alltrim(cGet1Env), .F.)
		If Found()
			lRet := MsgBox("Deseja transferir o(s) Palllet(s) antes de Sair ?'","Pergunta","YESNO")
		    If lRet
    			fTrPLote() // Transfere o lote de Pallets digitados
		 	Endif 
		Endif
		DbSelectArea("TMPTRANS")
		DbClosearea()
	Endif
*/	
    If !lTelaJaFechada
	    oDlg1Env:End()
    Endif
    lJaFech :=.t. 

	If ChkFile("TMPTRANS")
		DbSelectArea("TMPTRANS")
		DbCloseArea()
	Endif
/*
    oDlg1Env:End()
*/
Return()

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fTrPLote() - Transferência de Pallets em Lote
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fTrPLote()

Local aAuto 		:= {}
Local aItem			:= {}
Local aTrPallet 	:= {}  
Local cNumDoc 		:= NextNumero("SD3",2,"D3_DOC",.T.)
Local lAbrePar		:= .f.
Local nI 			:= 0
Local nSaldo        := 0
Local nOpcAuto		:= 3 	// Indica qual tipo de ação será tomada (Inclusão/Exclusão)
Local cLote	 		:= ""	
Local _cErrPallet 	:= ""
Local cStrErr       := ""
Local cQry1     	:= ""
Local cProduto 			// Cod Produto
Local cDescProd 		// Descrição do produto
Local cUM 				// Unidade de medida
Local nQuant 			// Quantidade
Local nY
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.
Private lCancelaTran:= .F.

	If ChkFile("TMPTRANS") 
		DbSelectArea("TMPTRANS")
	    DbSetOrder(1)
	    DbGotop()
	Else
		Messagebox("Inclua ao menos um Pallet antes de tentar transferi-lo !!","Atenção...",48)		
		Return
	Endif

	While (TMPTRANS->(!Eof()))
	   //	fTrPallet(TMPTRANS->TMPPAL, TMPTRANS->TMPORI, TMPTRANS->TMPORI) //Pallet, Armazem de Origem, Armazem de Destino
		
		cQry1 := " "
		cQry1 += " SELECT ZZK_CODIGO, ZZK_PRODUT, B1_DESC, SUM(ZZK_QUANT) AS ZZK_QUANT, B1_UM "
		cQry1 += " FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON ZZK_FILIAL = B1_FILIAL  AND ZZK_PRODUT = B1_COD AND SB1.D_E_L_E_T_ ='' "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZJ_CODIGO = ZZK_CODIGO AND ZZJ.D_E_L_E_T_ ='' "
		cQry1 += " WHERE ZZK.D_E_L_E_T_ ='' "
		cQry1 += " AND ZZK_FILIAL ='"+xFilial("ZZK")+"'"  
		cQry1 += " AND ZZK_CODIGO ='"+Alltrim(TMPTRANS->TMPPAL)+"'"
		cQry1 += " AND ZZJ_FLAG NOT IN('2','4') "
		cQry1 += " GROUP BY ZZK_CODIGO, ZZK_PRODUT, B1_DESC, B1_UM "  
		cQry1 += " ORDER BY ZZK_CODIGO "

		TCQuery cQry1 ALIAS "TCQ" NEW
	 	DbSelectArea("TCQ")
	  	DbGoTop()
	   	aTrPallet 	:= {} 

   		While !(TCQ->(EOF()))  
    		aAdd(aTrPallet, {TMPTRANS->TMPPAL, TCQ->ZZK_PRODUT ,TCQ->ZZK_QUANT, TCQ->B1_DESC, TCQ->B1_UM, TMPTRANS->TMPORI, TMPTRANS->TMPDES })
	     	DbSelectArea("TCQ")
   		  	DbSkip()
	    Enddo

	 	DbSelectArea("TCQ")
		DbCloseArea()

		//Begin Transaction

		//For nI:= 1 To Len(aTrPallet)     
		lTemSaldo 	 := .t.
		lCancelaTran := .f.	
		lAbrePar	 := .f.  
		For nY:= 1 To Len(aTrPallet)     
	   	    If (Alltrim(aTrPallet[nY][1]) == Alltrim(TMPTRANS->TMPPAL))
		       	//If lTemSaldo
		   	    DbSelectArea("SB2")
				DbSetorder(1)
				DbSeek(xFilial("SB2")+(aTrPallet[nY][2])+(aTrPallet[nY][6]))
			 	If Found()
					nSaldo := SaldoSb2()
				Endif
           		If (aTrPallet[nY][3] > SB2->B2_QATU)
           			 cStrErr    += "Falta de Saldo Disponível. Verifique !!"+Chr(13)+Chr(10)      	
           			_cErrPallet += TMPTRANS->TMPPAL+' - '+aTrPallet[nY][2]+' Motivo --> '+cStrErr+Chr(10)+Chr(13)
           			lTemSaldo   := .f.
           		Endif
           		If aTrPallet[nY][3] > nSaldo
                	lAbrePar :=.t.
				Endif
        		//Endif
           	Endif
		Next nY			
        
		
		If lTemSaldo		


	        Begin Transaction

				For nI:= 1 To Len(aTrPallet)     
	    
		       		cObs      := Alltrim(aTrPallet[nI][1])
					cProduto  := aTrPallet[nI][2]
					nQuant 	  := aTrPallet[nI][3]
					cDescProd := aTrPallet[nI][4]
					cUm 	  := aTrPallet[nI][5]
					cLocOri   := aTrPallet[nI][6]
					cLocDest  := aTrPallet[nI][7]
					aAuto     := {}
					aItem     := {}
					aadd(aAuto,{cNumDoc,dDataBase})  	
					aadd(aItem,	cProduto) 		 		//D3_COD		
					aadd(aItem,	cDescProd)     			//D3_DESCRI				
					aadd(aItem,	cUm)  		 			//D3_UM		
					aadd(aItem,	cLocOri)      			//D3_LOCAL		
					aadd(aItem,	"")			   			//D3_LOCALIZ		
					aadd(aItem,	cProduto) 				//D3_COD		
					aadd(aItem,	cDescProd)     			//D3_DESCRI				
					aadd(aItem,	cUm)  		  			//D3_UM		
					aadd(aItem,	cLocDest)  		  		//D3_LOCAL		
					aadd(aItem,	"")				   		//D3_LOCALIZ		
					aadd(aItem,	cObs)	  				//D3_NUMSERI		
					aadd(aItem,	cLote)					//D3_LOTECTL  		
					aadd(aItem,	"")         			//D3_NUMLOTE		
					aadd(aItem,	criavar("D3_DTVALID"))  //D3_DTVALID					
					aadd(aItem,	0)						//D3_POTENCI		
					aadd(aItem,	nQuant) 				//D3_QUANT		
				   	aadd(aItem, criavar("D3_QTSEGUM"))	//D3_QTSEGUM
					aadd(aItem, criavar("D3_ESTORNO"))  //D3_ESTORNO
					aadd(aItem, criavar("D3_NUMSEQ"))   //D3_NUMSEQ 
					aadd(aItem, "")						//D3_LOTECTL
					aadd(aItem,	criavar("D3_DTVALID"))  //D3_DTVALID					
					aadd(aItem,	"")						//D3_ITEMGRD
//					aadd(aItem,criavar("D3_IDDCF"))	    //D3_IDDCF
					aadd(aItem,criavar("D3_OBSERVA"))   //D3_OBSERVA  
					
					DbSelectArea("SB2")
					DbSetOrder(1)
					DbGotop()
					If !SB2->(DBSEEK(xFilial("SB2")+cProduto+cLocDest ))
						CriaSB2( cProduto, cLocDest)
					Endif
	                If lAbrePar
    	            	PutMv("MV_ESTNEG" , "S") 
        	        Endif

					//PutMv("MV_ESTNEG" , "S")                                                                      
        		
					lMsErroAuto := .f.
					aadd(aAuto,aItem)
					MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)				
		
					If lMsErroAuto			
						cStrErr := MemoLine( MemoRead( NomeAutoLog() ), 30, 1)
						PutMv("MV_ESTNEG" , "N")   
						If "MA240NEGAT" $ cStrErr
           	    	    	cStrErr := "SALDO DO PRODUTO -> "+cProduto+" INSUFICIENTE OU RESERVADO !" 
						Endif
						_cErrPallet += TMPTRANS->TMPPAL+' - '+cProduto+' Motivo --> '+cStrErr+Chr(10)+Chr(13)
						//_cErrPallet += TMPTRANS->TMPPAL+'  - '+cStrErr+Chr(10)+Chr(13)
    	    	    	lCancelaTran := .T.
   	        			//DisarmTransaction() 
						MostraErro()		
					Endif

				Next nI
   		
				If !lCancelaTran 
				 	DbSelectArea("ZZJ")
					DbSetOrder(1)
					DbSeek(xFilial("ZZJ")+TMPTRANS->TMPPAL, .t.)   
					If Found() 
						Reclock("ZZJ",.f.)
							If Upper(cLocOri) $ 'P1.P2'
							    ZZJ->ZZJ_LOCPRO := cLocOri
							Else
								If ZZJ->ZZJ_FLAG <> '5' 	
									ZZJ->ZZJ_FLAG 	:= Iif(lCBox1En =.t. .AND. Alltrim(ZZJ->ZZJ_BORDER) <> "",'4','2')
								Endif
								ZZJ->ZZJ_DTTRAN := Date()
								ZZJ->ZZJ_HTRAN  := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
								ZZJ->ZZJ_LOCORI := cLocOri
								ZZJ->ZZJ_LOCDES := cLocDest
							Endif
						MsUnlock()
				    Endif   	
					DbSelectArea("ZZJ")
					DbCloseArea()
					oBtn1Env:lVisibleControl := .f.
	
					DbSelectArea("TMPTRANS")
					Reclock("TMPTRANS",.f.)
						TMPTRANS->TMPSTA := "Transf. Sucesso"
					MsUnlock()
				Else
					PutMv("MV_ESTNEG" , "N")   
        			DisarmTransaction() 
					MostraErro()		
				Endif
			    PutMv("MV_ESTNEG" , "N")  
				//Messagebox("Tranferência do Pallet realizada com sucesso !! ","Atenção...",48)    		
				//cSay3Env := "Pallet transferido. Origem: "+cLocOri+" Destino: "+cLocDest
				//oDlg1Tr:End()

	    		//DbSelectArea("TMPTRANS")
		    	//DbSkip()
			End Transaction		
		Endif
   		DbSelectArea("TMPTRANS")
    	DbSkip()
	Enddo

    If !Empty(_cErrPallet)
    	Messagebox("As transferências dos seguintes Pallets não foram realizadas : "+Chr(10)+Chr(13)+_cErrPallet,"Atenção...",48)    
    Else
		Messagebox("Tranferência do(s) Pallets realizada(s) com sucesso !! ","Atenção...",48)    		
    Endif
    
	If ChkFile("TMPTRANS") 
		DbSelectArea("TMPTRANS")
	    DbGotop()
	Endif

    oBrw1Env:oBrowse:GoTop()
    oBrw1Env:oBrowse:Refresh()
    
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fInfPall() - Consulta situação do Pallet (Transferido ou a Transferir)
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fInfPall(cPallet)

	If Empty(Alltrim(cPallet))
		Return
	Endif
	If Len(Alltrim(cPallet)) = 10
		cGet1Env  := Substr(cPallet,1,6)+'/'+Substr(cPallet,7,4)
		cPallet := cGet1Env 	
	Endif
	cSay3Env := ""
	
	DbSelectArea("ZZJ")
	DbSetOrder(1)
	DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
	If Found() 
		If ZZJ->ZZJ_FLAG $ '1'
			cSay3Env := "Pallet aguardando transferência !! "
		Elseif ZZJ->ZZJ_FLAG $ '2'
			cSay3Env := "Pallet transferido. Origem: "+ZZJ->ZZJ_LOCORI+" Destino: "+ZZJ->ZZJ_LOCDES			
		Elseif ZZJ->ZZJ_FLAG $ '3'
			cSay3Env := "Pallet de Compra de pedidos por Borderô !! !! "		
		Elseif ZZJ->ZZJ_FLAG $ '4' 
			cSay3Env := "P. de Compra Transf.Origem: "+ZZJ->ZZJ_LOCORI+" Destino: "+ZZJ->ZZJ_LOCDES			
		Elseif ZZJ->ZZJ_FLAG $ '5'
		 	cSay3Env := "P. de Compra Transf.Origem: "+ZZJ->ZZJ_LOCORI+" Destino: "+ZZJ->ZZJ_LOCDES
		Endif
		oBtn6Env:lVisibleControl := .t.	
		oBtn7Env:lVisibleControl := .t.	
	Else
		oBtn6Env:lVisibleControl := .f.
		oBtn7Env:lVisibleControl := .f.	
	Endif
	
	DbSelectArea("ZZJ")
	DbClosearea()	    

Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTblTrans() - Cria temporario para o Alias: TMPTRANS
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function oTblTrans()
	Local aFds := {}

	//If ChkFile("TMPTRANS") 
	If Select("TMPTRANS") <> 0    
		DbSelectArea("TMPTRANS")
	    DbClosearea()
	Endif

    aAdd( aFds , {"TMPPAL"  ,"C", 011, 000} )   // PALLET
	aAdd( aFds , {"TMPORI"  ,"C", 002, 000} )   // ARMAZEM ORIGEM
	aAdd( aFds , {"TMPDES"  ,"C", 002, 000} )   // ARMAZEM DESTINO
	aAdd( aFds , {"TMPSTA"  ,"C", 016, 000} )   // STATUS
	aAdd( aFds , {"TMPUNI"  ,"N", 004, 000} )   // TOTAL DE PRODUTOS UNITARIO    
    
    //aAdd( aFds , {"TMPDEL"  ,"C", 001, 000} )   // DELETADO

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 28/10/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
    //cTmp := U_NovoArqTrab("dbf") //CriaTrab( , .F. )
    //DbCreate(cTmp+".dbf", aFds, "DBFCDXADS")
    //Use (cTmp+".dbf") Alias TMPTRANS VIA "DBFCDXADS" New Exclusive 
    //dbselectarea("TMPTRANS")
    //DbCreateIndex(cTmp+"_1.cdx", "TMPPAL"	   , {||"TMPPAL"} )
    //DbClearInd()
    //DbSetIndex(cTmp+"_1")
    //DbSetIndex(cTmp+"_2")
    //DbSetOrder(1)

       oTempTbl1 := FWTemporaryTable():New( 'TMPTRANS' )
       oTempTbl1:SetFields( aFds )
       oTempTbl1:AddIndex( "cInd01", { "TMPPAL" } )
       oTempTbl1:Create()
       /********************************************************************************************************************************/
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fMLocPall() - Inclusão do Local de Origem e Destino do Pallet
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fMLocPall(nOpcMnt) // 1 - Inclui / 2 - Exclui

	Private cGet1Tr   := Space(11) 
	Private cGet2Tr   := Space(2) 
	Private cGet3Tr   := Space(2) 

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±	
	±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    
	SetPrvt("oFontTr1", "oFontTr2", "oDlg1Tr", "oSay1Tr", "oSay2Tr", "oSay3Tr", "oGet1Tr", "oGet2Tr", "oGet3Tr")
          
    DbSelectArea("ZZJ")
	DbSetOrder(1)
	DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
	If Found() .AND. (ZZJ->ZZJ_FILIAL == XFILIAL("ZZJ"))
		If (ZZJ->ZZJ_FLAG == "2" .OR. ZZJ->ZZJ_FLAG == "4") 
			Messagebox("Pallet já transferido. Origem..: "+ZZJ->ZZJ_LOCORI+" Destino..: "+ZZJ->ZZJ_LOCDES,"Atenção...",48) 
    		DbSelectArea("ZZJ")
    		DbClosearea()
        	Return
	  	Elseif (ZZJ->ZZJ_FLAG == "5") 
			If !Empty(Alltrim(ZZJ->ZZJ_LOCDES))
				Messagebox("Pedido de transferência entre filiais já gerado e Pallet já transferido. Origem..: "+ZZJ->ZZJ_LOCORI+" Destino..: "+ZZJ->ZZJ_LOCDES,"Atenção...",48) 
				DbSelectArea("ZZJ")
   				DbClosearea()
   				Return
			Else
				Messagebox("Pedido de transferência entre filiais já gerado, porém, não houve transferência entre almoxarifados !!","Atenção...",48) 			
			Endif
   			DbSelectArea("ZZJ")
   			DbClosearea()
       		//Return
		Endif
   	Endif

    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Definicao do Dialog e todos os seus componentes.                        ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    oFontTr1  := TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
    oFontTr2  := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
    oDlg1Tr   := MSDialog():New( 258, 232, 383, 570, "Transferência de Pallet", , , .F., , , , , , .T., , , .T. )


    oSay1Tr   := TSay():New( 023, 008, {|| "Pallet.:"     }, oDlg1Tr, , oFontTr1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 012)
    oGet1Tr   := TGet():New( 020, 047, {|u| If(PCount() > 0, cGet1Tr := u, cGet1Tr)}, oDlg1Tr, 088, 018, '@!'             , , CLR_BLACK, CLR_WHITE, oFontTr1, , , .T., "", , , .F., .F., , .F. , .F., ""      ,"cGet1Tr", , )
    If (nOpcMnt == 1)
		If Empty(cGet5Env) 
			Messagebox("Informe o Local de Origem da Transferência dos Pallets","Atenção...",48) 		
			oGet5Env:Setfocus()
			Return
	    Endif
		If Empty(cGet6Env) 
			Messagebox("Informe o Local de Destino da Transferência dos Pallets","Atenção...",48) 		
			oGet5Env:Setfocus()
			Return
	    Endif
	    
	Endif

    oBtn1Tr   := TButton():New( 046, 122, "Confirma", oDlg1Tr, {|| oDlg1Tr:End()}  , 048, 014, , oFontTr2, , .T., , "", , , , .F. )
    oGet1Tr:bLostFocus := {|| FtrPallet(cGet1Tr,cGet5Env,cGet6Env,nOpcMnt)}
    oDlg1Tr:Activate( , , , .T.)

Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ
Function  ³ FtrPallet()  Salvar Dados nas Tabelas Temporárias (Inclusão e Exclusão de Pallets) 
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function FtrPallet(_cPallet,_cLocOri,_cLocDes,nOpcMnt)
	
	If Empty(Alltrim(_cPallet))
		Return
	Endif
	If Len(Alltrim(_cPallet)) = 10
		cGet1Env  := Substr(_cPallet,1,6)+'/'+Substr(_cPallet,7,4)
		_cPallet := cGet1Env 	
	Endif
	If (nOpcMnt == 1)
		If (Alltrim(_cLocOri) == Alltrim(_cLocDes))
			Messagebox("Não é possível transferir o Pallet com o Local de Origem igual ao Local de Destino !!","Atenção...",48)    	
		 	Return
		Endif
		If (Empty(Alltrim(_cLocOri)) .or. Empty(Alltrim(_cLocDes))) 
			Messagebox("Não é possível transferir o Pallet sem informar o Local de Origem e Local de Destino !!","Atenção...",48)    	
		 	Return
		Endif
    	If Empty(Alltrim(Posicione("SX5", 1, xFilial("SX5")+'99'+Alltrim(_cLocOri), "X5_DESCRI"))) 
			Messagebox("Verifique o almoxarifado digitado, pois ainda não existe "+_cLocOri+" no cadastro de almoxarifados !!","Atenção...",48)    	
	 		Return
		Endif
		If Empty(Alltrim(Posicione("SX5", 1, xFilial("SX5")+'99'+Alltrim(_cLocDes), "X5_DESCRI")))
			Messagebox("Verifique o almoxarifado digitado, pois ainda não existe "+_cLocDes+" no cadastro de almoxarifados !!","Atenção...",48)    	
	 		Return
		Endif
		If !Alltrim(_cLocOri) $ '03.30.P1.P2.01.10' .or. !Alltrim(_cLocDes) $ '03.30.01.10.13'
			Messagebox("Veririque os almoxarifados digitados pois ORIGEM ou DESTINO não estão dentro da lista de almoxarifados permitidos !!","Atenção...",48)    		
			Return
		Endif
    Endif

    If (nOpcMnt == 1)     // ver se é inclusão ou exclusão
	 	DbSelectArea("ZZJ")
		DbSetOrder(1)
		DbSeek(xFilial("ZZJ")+(_cPallet), .t.)   
		If Found() .and. (ZZJ->ZZJ_FILIAL == XFilial("ZZJ"))
			If ZZJ->ZZJ_FLAG == '1' .OR. (ZZJ->ZZJ_FLAG $ '3.5' .AND. lCBox1En) .AND. Empty(Alltrim(ZZJ->ZZJ_LOCDES))
				DbSelectArea("TMPTRANS")
				DbSetOrder(1)
			    DbSeek(Alltrim(_cPallet), .t.)  
				If Found() .and. (Alltrim(_cPallet) == Alltrim(TMPTRANS->TMPPAL))
					Messagebox("Pallet -->"+(_cPallet)+" já foi bipado / digitado !!","Atenção...",48)    	
					oSay1Tr:Setfocus()
				Else
					RecLock("TMPTRANS", .T.)
						TMPTRANS->TMPPAL := (_cPallet)
						TMPTRANS->TMPORI := (_cLocOri)
						TMPTRANS->TMPDES := (_cLocDes)
						TMPTRANS->TMPSTA := Iif(Alltrim(ZZJ->ZZJ_LOCPRO) $ 'P1.P2',"Transf. Rampa", "Ñ Transferido")
						TMPTRANS->TMPUNI := fTotUnit(_cPallet)
					MsUnLock()
					nCount := (nCount +1)
					oSay7Env:Refresh()
				Endif
	       	Elseif (ZZJ->ZZJ_FLAG $ '2.4.5') 
				Messagebox("Pallet -->"+(_cPallet)+" já transferido. Origem: "+ZZJ->ZZJ_LOCORI+" Destino: "+ZZJ->ZZJ_LOCDES+" !!","Atenção...",48)
	       	Endif
	    Else
			Messagebox("Pallet -->"+(_cPallet)+" não cadastrado !!","Atenção...",48)    		    
	    Endif
	    DbSelectArea("ZZJ")
	    DbCloseArea()
	ElseIf (nOpcMnt == 2)  
		DbSelectArea("TMPTRANS")
	    DbSetOrder(1)
	    DbSeek(_cPallet, .t.)   
		If Found()
			RecLock("TMPTRANS", .F.)
				DbDelete()
			MsUnlock()		
			nCount := (nCount -1)
			oSay7Env:Refresh()
	    Endif	
	Endif

	If ChkFile("TMPTRANS") 
		DbSelectArea("TMPTRANS")
	    DbGotop()
	Endif

    oGet1Tr:SetFocus()
    cGet1Tr := Space(11)
    oGet1Tr:Refresh()

    oBrw1Env:oBrowse:GoTop()
    oBrw1Env:oBrowse:Refresh()
Return


Static Function fTotUnit(cPallet)
	Local nTotal :=0
	Local cQry1  :=""    

	cQry1 := "SELECT SUM(ZZK_QUANT) AS ZZK_QUANT "
	cQry1 += "FROM "+RetSqlName("ZZK")+" WITH (NOLOCK) " 
	cQry1 += "WHERE (D_E_L_E_T_ ='') " 
	cQry1 += "AND (ZZK_FILIAL ='"+xFilial("ZZK")+"') "
	cQry1 += "AND (ZZK_CODIGO ='"+cPallet+"') "
    TCQuery cQry1 ALIAS "TCQ" NEW
	
	If !Eof()
		nTotal := TCQ->ZZK_QUANT
	Endif		
    
    DbSelectArea("TCQ")
    DbCloseArea()
    
Return(nTotal)
