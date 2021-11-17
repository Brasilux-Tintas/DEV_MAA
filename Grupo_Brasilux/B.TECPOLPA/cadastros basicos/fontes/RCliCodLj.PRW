
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCLICODLJ ºAutor³Mauricio-www.chaus.com.br ºData ³ 09/03/16  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esta rotina e chamada via garilho da A1_CGC e tem como      º±±
±±º          ³ objetivo, verificar se ja existe no cadastro de clientes   º±±
±±º          ³ uma matriz/loja e sugerir no A1_COD o mesno codigo do      º±±
±±º          ³ cliente e no campo A1_LOJA sugerir a loja do cliente       º±±
±±º          ³                                                            º±±   
±±º          ³Foi inclusa a opcao de gatilhar o codigo de engenharia do   º±±   
±±º          ³cliente, caso o cnpj seja igual ao da matriz/loja ja        º±±   
±±º          ³cadastrado        										  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function RCliCodLj(_Orig)

	Local     aAreaOld     := SA1->(GetArea())
	Local     cCNPJ        := M->A1_CGC
	Local     cA1_COD      := M->A1_COD
	Local     cA1_LOJA     := M->A1_LOJA
	Local 	  cA1_XCODENG  := M->A1_XCODENG
	Local     cCGCBAse
	Local     nLoja
	Local  i
	Local _Ret := " "
     
// Forço atualização para Juridica se o numero de digitos for maior que 11
	If Len(Alltrim(cCNPJ)) > 11
		M->A1_PESSOA = "J"
	Endif
	teste := " "
	
	If M->A1_PESSOA == "J"
		cA1_LOJA     := SubStr(cCNPJ,9,2)
		nLoja          := Val(cA1_LOJA)
     // Faço controle se o numero da loja for maior que 100, ajusta pelo Microsiga
		If nLoja >= 100
			cA1_LOJA     := "99"
			For i := 1 To (nLoja - 100)
				cA1_LOJA := Soma1(cA1_LOJA)
			Next
		Else
			cA1_LOJA     := SubStr(cCNPJ,11,2)
			teste := " "
		Endif
		cCGCBase := SubStr(cCNPJ,1,8)
		teste := " "
			
		DbSelectArea("SA1")
		DbSetOrder(3)
		If DbSeek(xFilial("SA1")+cCGCBase)
			cA1_COD      	:= SA1->A1_COD
			cA1_XCODENG	:= SA1->A1_XCODENG
          // Efetua loop para evitar duplicidade de Loja, mesmo que não corresponda a loja do CNPJ
			While .T.
				DbSelectArea("SA1")
				DbSetOrder(1)
				If DbSeek(xFilial("SA1")+cA1_COD+cA1_LOJA)
					cA1_LOJA := Soma1(cA1_LOJA)
				Else
					Exit
				Endif
			Enddo
		Else
   	 		
   	 		
			
			//cA1_COD      :=  GETSXENUM("SA1","A1_COD")
			
			// Inicio Dyego - trata para chamar o proximo numero apenas uma vez
			If Empty(M->A1_COD)
				cA1_COD      :=  GETSX8NUM("SA1","A1_COD")
			
				dbSelectArea("SA1")
				dbSetOrder(1)
				While SA1->(MsSeek(xFilial("SA1")+cA1_COD))
					ConfirmSX8()
					cA1_COD   :=  GETSX8NUM("SA1","A1_COD")
				EndDo
			Endif
			//fim 
			
			
		Endif
     //M->A1_COD      := cA1_COD
    // M->A1_LOJA      := cA1_LOJA
 
	Else //pessoa fisica
	
	    // Inicio Dyego - Trata pessoa fisica
		If Empty(M->A1_COD)
			cA1_COD      :=  GETSX8NUM("SA1","A1_COD")
			
			dbSelectArea("SA1")
			dbSetOrder(1)
			While SA1->(MsSeek(xFilial("SA1")+cA1_COD))
				ConfirmSX8()
				cA1_COD   :=  GETSX8NUM("SA1","A1_COD")
			EndDo
		Endif
		//fim 
	Endif
	

	If _Orig="LJ"
		_Ret :=   cA1_LOJA
	ElseIf  _Orig="COD"
		_Ret := cA1_COD
	ElseIf  _Orig="ENG"
		_Ret := cA1_XCODENG
	EndIF

	teste := " "
	RestArea(aAreaOld)
Return(_Ret)