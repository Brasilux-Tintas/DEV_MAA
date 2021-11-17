#include 'protheus.ch'
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP011 ºAutor  ³ Fernando Roquete   º Data ³  10/12/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Formação de preço de venda.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRPCP011()   
     Local cArea := Alias()
     Local aAreaAnt := U_PegaArea({"SG1","SB1"})
     Local cQuery,cAlias,cQry
     //Local cArea

     DbSelectArea("SG1")
     DbSetOrder(1)

     DbSelectArea("SB1")
     DbSetOrder(1)

     _VlrMov :=0.00
     Do Case
        Case Paramixb == "MO"          //Valor da Mão de Obra  
			cQry := "SELECT dbo.ValorMO"+iif(cNumEmp = "05","05","")+"('"+xFilial("SG1")+"','"+aArray[1][4]+"',1) AS CUSTO"    
			cAlias := U_NovoCursor()
		 	DbUseArea(.T., "TOPCONN", TcGenQry( , , cQry), cAlias, .T., .T.)
		  	DbSelectArea(cAlias)
		   	DbGoTop()
		    if !eof() .and. !bof()
				_VlrMov := (cAlias)->CUSTO
			else
				_VlrMov := 0
			endif          
		  	DbSelectArea(cAlias)
		  	dbclosearea()
/*        
			DbSelectArea("SB1")
			DbSetorder(1)
   			DbSeek(xFilial("SB1")+aArray[1][4], .F.)
      		If Found()            
             	do case 
             	case (SB1->B1_GRTRIB $ '002.005') .or. !(alltrim(SB1->B1_TIPO) $ "PA_PI")
                   _VlrMov := 0
                case Len(Alltrim(aArray[1][4])) # 12
                   _VlrMov := SB1->B1_VLRMO   
              	otherwise
                   	// Definir custo por litro	
                   	DbSelectArea("SZ1")     // LINHA DE PRODUTO
                   	DbSetOrder(1)
                   	DbSeek(xFilial("SZ1")+SubStr(aArray[1][4],4,2), .f.)
                   	If Found().And. SZ1->Z1_VLRMO # 0.00
                   		do case
                   		case alltrim(SB1->B1_UM) == 'L'
                     		_VlrMov := SZ1->Z1_VLRMO
                   		case alltrim(SB1->B1_UM) $ 'K_KG'
                     		_VlrMov := SZ1->Z1_VLRMO/SB1->B1_PESOESP
                      	case alltrim(SB1->B1_SEGUM) == 'L'
                      		_VlrMov := SZ1->Z1_VLRMO*SB1->B1_CONV
                      	otherwise 
		                   	_VlrMov := iif(alltrim(SB1->B1_TIPO) $ "PA_PI",SB1->B1_VLRMO,0)
						endcase
					else
	                   _VlrMov := SB1->B1_VLRMO   
	    			endif 
					If _VlrMov == 0 // Se ainda não preencheu o Vlr. MO, pegar pela embalagem
						DbSelectArea("SZ5")     // EMBALAGEM
						DbSetOrder(1)
						DbSeek(xFilial("SZ5")+SubStr(aArray[1][4],11,2), .f.)
						If Found()
							_VlrMov := SZ1->Z1_VLRMO * SZ5->Z5_VOLUME  // valor da mo por litro * volume da embalagem
						Endif    
      				Endif
      			endcase 
			Endif        
*/			
        Case Paramixb == "LU"          //% do Lucro
             DbSelectArea("SB1")
             DbSetOrder(1)
             DbSeek(xFilial("SB1")+aArray[1][4], .F.)
             If Found()
                If Len(Alltrim(aArray[1][4])) >= 12
                   DbSelectArea("SZ1")
                   DbSetOrder(1)
                   DbSeek(xFilial("SZ1")+SubStr(aArray[1][4],4,2), .f.)
                   If Found()
                      _VlrMov := SZ1->Z1_LUCRO
                   Endif
                Else   
                   _VlrMov := SB1->B1_LUCRO
                Endif    
             Endif
        Case Paramixb == "CO"          //% da Comissão
             DbSelectArea("SB1")
             DbSetOrder(1)
             DbSeek(xFilial("SB1")+aArray[1][4], .F.)
             If Found()
                If Len(Alltrim(aArray[1][4])) >= 12
                   DbSelectArea("SZ1")
                   DbSetOrder(1)
                   DbSeek(xFilial("SZ1")+SubStr(aArray[1][4],4,2), .f.)
                   If Found() 
                      _VlrMov := SZ1->Z1_COMISSA
                   Endif
                Else   
                   _VlrMov := SB1->B1_COMIS
                Endif    
             Endif
        Case Paramixb == "L2"          //% do Lucro
             DbSelectArea("SB1")
             DbSetOrder(1)
             DbSeek(xFilial("SB1")+aArray[1][4], .F.)
             If Found()
                If Len(Alltrim(aArray[1][4])) >= 12
                   DbSelectArea("SZ1")
                   DbSetOrder(1)
                   DbSeek(xFilial("SZ1")+SubStr(aArray[1][4],4,2), .f.)
                   If Found()
                      _VlrMov := SZ1->Z1_LUCRO2
                   Endif
                Else
                   _VlrMov := SB1->B1_LUCRO2
                Endif

             Endif
        Case Paramixb == "US"          //Custo de Materia prima considerando preço de produtos em Dolar, convertidos pra Reais
        	cQuery := "exec PrecoDolarConvertido '"+xFilial("SB1")+"','"+aArray[1][4]+"'"
        	TCQUERY cQuery ALIAS "TMPDOLAR" NEW
        	dbselectarea("TMPDOLAR")
			dbgotop()
			if !eof()
				_VlrMov := TMPDOLAR->CUSTO
			else       
				_VlrMov := 0
			endif    
        	dbselectarea("TMPDOLAR")
	        DbCloseArea()
			    	
     EndCase

	U_VoltaArea(aAreaAnt)

	if !empty(cArea)
   		DbSelectArea(cArea)
	endif
	Return(_VlrMov)       
	