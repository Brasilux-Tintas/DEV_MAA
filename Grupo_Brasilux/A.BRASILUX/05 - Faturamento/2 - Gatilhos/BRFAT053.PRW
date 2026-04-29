
#include "protheus.ch"
#include "topconn.ch"
//#Translate MSGBOX( => IW_MsgBox(
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BRFAT053  ºAutor  ³Edmar Rodrigo       º Data ³  05/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho para calcular a TES                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Cleber       ³15/05/02³      ³ Não estava considerando pedido que usa ³±±
±±³              ³        ³      ³ fornecedor.                            ³±±
±±³ Gustavo      ³30/10/02³      ³ Modificada funcao para receber parame- ³±±
±±³              ³        ³      ³ tros, e acrescida no gatilho de orca - ³±±
±±³              ³        ³      ³ mentos.                                ³±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFAT053(_cTipo, cCliente, cProduto) 
	 Local cArea    := Alias()
     Local aAreaAnt := U_PegaArea({"SA1","SA2","SB1","SA7","SYD"})
     Local cTes     :=""
     Local cQuery   :=""
     Local _cFilial,cAuxFilial
     Local cTipoMov,cGrTrib,cGrProd,cUf,cSuframa,cTemSt,cCalcSuf,cInterUf,lIpizero,cMunZf
     u_zcfga01( 'BRFAT053' ) //LGS#2021201 - Gravação de log de utilização da rotina
     lIpizero := .f. //Chamado 007956=>Clientes Suframa fora dos mun. zona franca e com IPI zero tratar como venda normal
     cMunZf := "" //Conterá cód. município Zona Franca
     If !(_cTipo $ "D_B") 

        dbselectarea("SA1")
        dbsetorder(1)
		DbSeek(xFilial("SA1")+cCliente, .F.)
		if found()
     		dbselectarea("SA7")
	     	dbsetorder(1)                  
     	
    	 	dbseek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+cProduto)
    	 	if found()
    	 		cTes := alltrim(SA7->A7_XTES)
    	 	endif
		Else
			MsgStop("Cliente não Encontrado")
  		endif 

		dbselectarea("Z17")
		dbsetorder(1)
		dbselectarea("SYD")
		dbsetorder(1)
		DbSelectArea("SB1")
        DbSetorder(1)

		_cFilial = xFilial("Z01")
		cTipoMov := ""
		cGrTrib := ""
		cGrProd := ""
		cUf := ""
		cSuframa := ""
		cTemSt := ""
		cCalcSuf := ""
		cInterUf := ""
		cTipoMov := "0"+SA1->A1_CLAS
		cUf := SA1->A1_EST         
		cMunZf := ALLTRIM(SA1->A1_CODMUN)
		cSuframa := IIF(!EMPTY(ALLTRIM(SA1->A1_SUFRAMA)),"S","N")
		cGrTrib := ALLTRIM(SA1->A1_GRPTRIB)
		if cSuframa = "S"
			cCalcSuf := alltrim(SA1->A1_CALCSUF)  
// 12/01/09=>Solicit. Fernando Mauri, todos os clientes Suframa com desc. passarao a ter Desc. ICMS+PIS+COFINS (Cleber)
/*
			IF (cCalcSuf = "S")
				IF (SA1->A1_CODCID $ '002054.002259')
					cCalcSuf := "S"
				ELSE
					cCalcSuf := "I"
				endif 
			endif 
*/					
		else
			cCalcSuf := "N"
		endif 
			         
		if empty(cCalcSuf) 
			cCalcSuf := "N"
		endif 

		cInterUf := iif(getmv("MV_ESTADO") = cUf,"N","S")
    	dbselectarea("SB1")
		DbSeek(xFilial("SB1")+cProduto,.t.)
		If Found()                            
			cGrProd := alltrim(SB1->B1_GRTRIB)
			dbselectarea("Z17")
			cAuxFilial := xFilial("Z17")
			msseek(cAuxFilial+SB1->B1_POSIPI+SB1->B1_EX_NCM)
			do while !eof() .and. (cAuxFilial == Z17->Z17_FILIAL) .AND. (Z17->Z17_NCM = SB1->B1_POSIPI) .AND. (Z17->Z17_EX_NCM = SB1->B1_EX_NCM)
				cTemSt := IIF(Z17->Z17_TEM_ST = "1","S","N")
				IF !EMPTY(ALLTRIM(Z17->Z17_EST)) .AND. (ALLTRIM(Z17->Z17_EST) == ALLTRIM(SA1->A1_EST))
					exit 
				ENDIF 
				dbselectarea("Z17")
				dbskip()
			enddo 

			dbselectarea("SYD")
			dbseek(xFilial("SYD")+SB1->B1_POSIPI+SB1->B1_EX_NCM)
			if found()
				if empty(cTemSt)
					cTemSt := IIF(SYD->YD_TEM_ST = "2","N","S")     
				endif 
				lIpizero := iif(SYD->YD_PER_IPI > 0.0,.F.,.T.) //Chamado 007956=>Clientes Suframa fora dos mun. zona franca e com IPI zero tratar como venda normal
			else
				if empty(cTemSt)
					cTemSt := iif(SB1->B1_PICMRET > 0,"S","N")   
				endif 
			endif 
		Else
			MsgStop("Produto não Encontrado")
		endif 
		
		//Chamado 007956=>Tratar como venda normal para cliente suframa quando a aliq. IPI for zero
		if lIpizero .and. (cSuframa <> "N") .and. (cCalcSuf = "N") .and. empty(cMunZf)             
			cSuframa := "N"
		endif 
			

		if empty(cGrProd)
			cGrProd := "001"
		endif 
		IF cGrProd == "005"
			cGrProd := "002" //O grupo 005, assim como o 002, é grupo de revenda, só muda o icms, portanto o TES é o mesmo
		endif 
		/*
		Cleber(04/11/2015) -> Todos os produtos, sem exceção, terão ST para Mato Grosso, solic. Fernando Mauri    
		22/01/16 -> à partir de 01/04/2016 o estado de MT irá acatar convenio no que se refere a isenção de ST
		19/04/16 -> regra para MT permanece a mesma, foi adiada a adequação ao convenio
		30/12/19 -> Chamado 015949, MT mudou as regras a serem aplicadas em 01/01/20
		*/
		/*Chamado 015949, MT mudou regras
		if (SA1->A1_EST = "MT") 
			cTemSt := "S"
		endif 
		*/
		/*
		Cleber(29/04/2019) -> Chamado 013778, à partir de 01/05/2019 o estado de SC não mais irá ter ST!! 
		*/
		IF (cUf = "SC")
			cTemSt := "N"
		ENDIF
		if empty(cTemSt)
			cTemSt := "N"
		endif 
		if empty(cTes)
            	
	     	cQuery := "SELECT TES = dbo.DetTes('"+_cFilial+"','"+cTipoMov+"','"+cCliente+"','"+cGrTrib+"','"+cProduto+;
    	 	"','"+cGrProd+"','"+cUf+"','"+cSuframa+"','"+cTemSt+"','"+cCalcSuf+"','"+cInterUf+"')"

		    /* Incluido por Nelieder em 15/12/2022 */
			IF Select("TCQ") <> 0
      			DbSelectArea("TCQ")
      			DbCloseArea()
   			ENDIF

     		TCQuery cQuery ALIAS "TCQ" NEW

			DbSelectArea("TCQ")
  			DbGoTop()
			cTes := alltrim(TCQ->TES)
			dbselectarea("TCQ")
			dbclosearea()
		endif
		if empty(cTes)
			dbselectarea("SB1")
	        If DbSeek(xfilial("SB1")+cProduto,.F.)
    	       If !Empty(SB1->B1_TS)
        	      cTes := SB1->B1_TS
        	   else 
            	  DbSelectArea("SA1")
            	  If DbSeek(xFilial("SA1")+cCliente)
	              		cTes := ALLTRIM(IIF(cTemSt == "S",SA1->A1_TESCST,SA1->A1_TESSST))
        	      Else
        	      		MsgStop("Cliente não Encontrado")
	              Endif
    	       Endif
        	Endif
	        If Empty(cTes)
	        	DbSelectArea("SZ8") // Cadastro de Estados c/ Subst. Trib
	        	DbSetorder(1)
	        	If DbSeek(xfilial("SZ8")+SA1->A1_EST+SA1->A1_CLAS, .F.)
	        		cTes := SA1->A1_TESCST
	        	Else
	        		cTes := SA1->A1_TESSST
	        	Endif
	        Endif    
     	endif    
        
     Endif
                          
     U_VoltaArea(aAreaAnt)

     if !empty(cArea)
     	DbSelectArea(cArea)
     endif
Return(cTes)
