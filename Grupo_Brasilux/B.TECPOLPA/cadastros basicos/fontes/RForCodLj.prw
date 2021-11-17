
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RForCODLJ ºAutor³Mauricio-www.chaus.com.br ºData ³ 09/03/16  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esta rotina e chamada via garilho da A2_CGC e tem como      º±±
±±º          ³ objetivo, verificar se ja existe no cadastro de fornecedores º±±
±±º          ³ uma matriz/loja e sugerir no A2_COD o mesno codigo do      º±±
±±º          ³ fornecedor e no campo A1_LOJA sugerir a loja do fornecedor º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function RForCodLj(_Orig)

Local     aAreaOld     := SA1->(GetArea())
Local     cCNPJ        := M->A2_CGC
Local     cA2_COD      := M->A2_COD
Local     cA2_LOJA     := M->A2_LOJA
Local     cCGCBAse     
Local     nLoja            
Local  i              
Local _Ret := " "
     
 
If Len(Alltrim(cCNPJ)) > 11
     M->A2_TIPO = "J"
Else
     M->A2_TIPO = "F"  //LGS#20190927 - Ajustado para pessoa Fisica - Chamado 014928 com José Uliana
Endif                     

If M->A2_TIPO == "J"
	cA2_LOJA     := SubStr(cCNPJ,9,2)
	nLoja          := Val(cA2_LOJA)
	     // Faço controle se o numero da loja for maior que 100, ajusta pelo Microsiga
	If nLoja >= 100
		cA2_LOJA     := "99"
	 	For i := 1 To (nLoja - 100)
	    	cA2_LOJA := Soma1(cA1_LOJA)
	 	Next       
	 Else
	 	cA2_LOJA     := SubStr(cCNPJ,11,2)  
	  	teste := " "
	 Endif
	 cCGCBase := SubStr(cCNPJ,1,8)   
	 teste := " "
	 DbSelectArea("SA2")
	 DbSetOrder(3)
	 If DbSeek(xFilial("SA2")+cCGCBase) 
	          cA2_COD      := SA2->A2_COD
	          // Efetua loop para evitar duplicidade de Loja, mesmo que não corresponda a loja do CNPJ
	          While .T.
	               DbSelectArea("SA2")
	               DbSetOrder(1)
	               If DbSeek(xFilial("SA2")+cA2_COD+cA2_LOJA) 
	                  cA2_LOJA := Soma1(cA2_LOJA)
	               Else
	                    Exit
	               Endif
	          Enddo
	 Else
	 	cA2_COD      :=  GETSXENUM("SA2","A2_COD")   
	 Endif   
Else
	cA2_COD      :=  GETSXENUM("SA2","A2_COD")
	cA2_LOJA     := '01' //LGS#20190927 - Ajustado para pessoa Fisica - Chamado 014928 com José Uliana
EndIf
	
	
If _Orig="LJ"
	_Ret :=   cA2_LOJA
ElseIF   _Orig= "COD"
	_Ret := cA2_COD
EndIF 

teste := " "

RestArea(aAreaOld)       
Return(_Ret)