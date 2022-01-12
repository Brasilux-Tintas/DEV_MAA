#Include "Protheus.ch"
#Include "TopConn.ch"


/*
rotina que exporta dados das tabelas
    ESPECIFICOS PARA ZA5010	
    ESPEDIDOS PARA ZA6010	
*/ 
User Function BRPCP034()

	cUsuario = PswChave(RetCodUsr())
    if (cUsuario <> 'neliedercorneta') 
        MsgAlert('Usuário sem Acesso', 'Exporta dados.')
        return()
    Endif

	Processa({|| PROC_ESPECI()}, "Processando Especificos...")
	Processa({|| PROC_ESPED()}, "Processando Espedidos.....")

return	


Static Function PROC_ESPECI()	

	/**************************************************************************************/
	/*** IMPORTA ESPECIFICOS.						                                    ***/
	/**************************************************************************************/

    cQuery := "SELECT TOP 1000 * FROM ESPECIFICOS ORDER BY ID DESC"

	IF Select("TMP_EXP") <> 0
		DbSelectArea("TMP_EXP")
		DbCloseArea()
	ENDIF
	TCQuery cQuery New Alias "TMP_EXP"

	Count To nTotal
	ProcRegua(nTotal)
	TMP_EXP->(DbGoTop())
	conta := 0
	While !TMP_EXP->(EoF())
        /* Grava Registros */    
		dbselectarea("ZA5")
		reclock("ZA5",.T.)
		ZA5->ZA5_ID      := TMP_EXP->ID
		ZA5->ZA5_EMISSA  := StoD(TMP_EXP->EMISSAO)
		ZA5->ZA5_PRODUT  := TMP_EXP->PRODUTO
		ZA5->ZA5_QUANT   := TMP_EXP->QUANT
		ZA5->ZA5_LOTE    := TMP_EXP->LOTE
		ZA5->ZA5_EMPRES  := TMP_EXP->EMPRESA		
		msunlock()
		conta++
		IncProc("Analisando registro " + cValToChar(conta) + " de " + cValToChar(nTotal) + "...")

		TMP_EXP->(DbSkip())
	ENDDO

return()


Static Function PROC_ESPED()	

	/**************************************************************************************/
	/*** IMPORTA ESPEDIDOS.							                                    ***/
	/**************************************************************************************/


	cQuery := "SELECT TOP 1000 * FROM ESPEPEDIDOS ORDER BY ID DESC"

	IF Select("TMP_EXP") <> 0
		DbSelectArea("TMP_EXP")
		DbCloseArea()
	ENDIF
	TCQuery cQuery New Alias "TMP_EXP"

	Count To nTotal
	ProcRegua(nTotal)
	TMP_EXP->(DbGoTop())
	conta := 0
	While !TMP_EXP->(EoF())
        /* Grava Registros */    
		dbselectarea("ZA6")
		reclock("ZA6",.T.)
		ZA6->ZA6_ID      := TMP_EXP->ID
		ZA6->ZA6_PEDIDO  := TMP_EXP->PEDIDO
		ZA6->ZA6_CLIENT  := TMP_EXP->CLIENTE
		ZA6->ZA6_REDESP  := TMP_EXP->REDESP
		ZA6->ZA6_VOLUME  := TMP_EXP->VOLUME
		ZA6->ZA6_EMBAL   := TMP_EXP->EMBAL
		ZA6->ZA6_QUANT   := TMP_EXP->QUANT
		ZA6->ZA6_EMPRES  := TMP_EXP->EMPRESA
		msunlock()
		conta++
		IncProc("Analisando registro " + cValToChar(conta) + " de " + cValToChar(nTotal) + "...")

		TMP_EXP->(DbSkip())
	ENDDO


return
