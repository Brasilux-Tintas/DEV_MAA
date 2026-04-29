#include "totvs.ch"
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} ZP_APROVPC
Rotina automatica para tratar pedidos de compra pendentes.
nivel02 com mais ou igual 2 dias sem aprovacao
@type function Processamento
@version  1.0
@author Andreia Domingo
@since 08/10/2025
@return character, sem retorno
/*/
User Function ZP_APROVPC()

	//Local cQuery := ""
	//Local cQUdbm := ""
	Local lJob:=.F.

	// Verifica se ambiente esta aberto
	if GetRemoteType() == -1

		lJob:=.T.
		RpcClearEnv()
		RpcSetType(3) // 3 = Rotina automÃ¡tica

		if Type("cFilAnt") == "C" .and. TCIsConnected()
			ConOut("Ambiente Protheus aberto e pronto para uso - ZP_APROVPC")
		else
			//PREPARE ENVIRONMENT PROG
			RpcSetEnv("11","01",,,"COM")
		End

		//Define a empresa e filial a serem processadas
		//FWSetMV('MV_PAR01', 'SUA_FILIAL', .T.)

	End

	//Reposicionado a verificação e fechamento da tabela temporaria para ser a primeira instrução a ser executada MAA 20251020
	IF Select("QRY_SCR") > 0
		DbSelectArea("QRY_SCR")
		QRY_SCR->(DbCloseArea())
	End

	// Define a query para buscar os pedidos pendentes]
	/*
	cQuery := "  SELECT CR_NUM, CR_TIPO,CR_APROV, "
	cQuery += "  CR_FILIAL,CR_USER, CR_GRUPO,CR_ITGRP,  "
	cQuery += "  CR_NIVEL,CR_STATUS,CR_EMISSAO,CR_TOTAL,CR_MOEDA, "
	cQuery += "  CR_TXMOEDA,CR_PRAZO,CR_AVISO,CR_ESCALON,CR_ESCALSP, "
	cQuery += "  CR_NFMOBLQ, CR_TIPCOM,CR_NFMOTBL "
	cQuery += "  FROM  "+ RetSqlName("SCR") + " SCR (NOLOCK) " + " WHERE  SCR.D_E_L_E_T_ <> '*' "
	cQuery += "  AND CR_FILIAL= '" + xFilial("SCR") + "'  AND CR_STATUS IN ('01','02') AND  CR_NIVEL='02' "
	cQuery += "  AND DATEDIFF(DAY, CR_EMISSAO, GETDATE()) >= 2 "

	// Cria uma conexao  com o banco de dados
	DbUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), "QRY_SCR",.F.,.T.)
	*/
	BeginSQl Alias "QRY_SCR"
		SELECT
			SCR.CR_NUM,
			SCR.CR_TIPO,
			SCR.CR_APROV,
			SCR.CR_FILIAL,
			SCR.CR_USER,
			SCR.CR_GRUPO,
			SCR.CR_ITGRP,
			SCR.CR_NIVEL,
			SCR.CR_STATUS,
			SCR.CR_EMISSAO,
			SCR.CR_TOTAL,
			SCR.CR_MOEDA,
			SCR.CR_TXMOEDA,
			SCR.CR_PRAZO,
			SCR.CR_AVISO,
			SCR.CR_ESCALON,
			SCR.CR_ESCALSP,
			SCR.CR_NFMOBLQ,
			SCR.CR_TIPCOM,
			SCR.CR_NFMOTBL
		FROM
			%Table:SCR% SCR (NOLOCK)
		WHERE
			SCR.%NOTDEL%
			AND SCR.CR_FILIAL = %XFILIAL:SCR%
			AND SCR.CR_STATUS IN ('01', '02')
			AND SCR.CR_NIVEL = '02'
			AND DATEDIFF(DAY, SCR.CR_EMISSAO, GETDATE()) >= 2
	EndSQl

	// Percorre os registros encontrados
	While QRY_SCR->(!Eof())

		SCR->(DbSetOrder(3)) //-- CR_FILIAL+CR_TIPO+CR_NUM+CR_APROV

		If SCR->(DbSeek(xFilial("SCR")+ QRY_SCR->CR_TIPO + QRY_SCR->CR_NUM + QRY_SCR->CR_APROV))

			cNewNiv:=Soma1(SCR->CR_NIVEL)

			SAL->(dbSetOrder(2))
			If SAL->(MsSeek(xFilial("SAL")+SCR->(CR_GRUPO+cNewNiv)))

				If SAL->AL_MSBLQL == "1" // se  nivel estiver bloqueado entao nao faz nada
					QRY_SCR->(dbSkip())
					Loop
				End

				//Verifico se tem nivel superior para gerar nova aprovação
				//Se Encontrei, e se tem nivel superior aprovo e gero proximo nivel
				//Caso der erro nao atualiza mais nada
				If MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,,SCR->CR_APROV,,SCR->CR_GRUPO,,,,,},dDataBase,4)

					RecLock("SCR",.F.)
					SCR->CR_OBS:="Aprovação Autom. apos 2 dias"
					If SCR->(FieldPos("CR_AUTOMAT")) > 0 //Incluida verificação de existencia de campo para evitar EROOR.LOG  MAA 20251020
						SCR->CR_AUTOMAT := 'S'
					End
					SCR->(MsUnLock())

					// Cria novo registro
					RecLock('SCR', .T.)
					SCR->CR_FILIAL  := QRY_SCR->CR_FILIAL
					SCR->CR_NUM     := QRY_SCR->CR_NUM
					SCR->CR_TIPO    := QRY_SCR->CR_TIPO
					SCR->CR_USER    := SAL->AL_USER
					SCR->CR_APROV   := SAL->AL_APROV
					SCR->CR_GRUPO   := QRY_SCR->CR_GRUPO
					SCR->CR_ITGRP   := QRY_SCR->CR_ITGRP
					SCR->CR_NIVEL   := cNewNiv
					SCR->CR_STATUS  := '02'
					SCR->CR_EMISSAO := SToD(QRY_SCR->CR_EMISSAO)
					SCR->CR_TOTAL   := QRY_SCR->CR_TOTAL
					SCR->CR_MOEDA   := QRY_SCR->CR_MOEDA
					SCR->CR_TXMOEDA := QRY_SCR->CR_TXMOEDA
					SCR->CR_PRAZO   := SToD(QRY_SCR->CR_PRAZO)
					SCR->CR_AVISO   := SToD(QRY_SCR->CR_AVISO)
					SCR->CR_ESCALON := .F.
					SCR->CR_ESCALSP := .F.
					SCR->CR_TIPCOM  := QRY_SCR->CR_TIPCOM
					If SCR->(FieldPos("CR_AUTOMAT")) > 0 //Incluida verificação de existencia de campo para evitar EROOR.LOG  MAA 20251020
						SCR->CR_AUTOMAT := 'S'
					End
					SCR->(MsUnlock())

					/*
					cQUsc7 := " SELECT C7_ITEM,C7_TOTAL   "
					cQUsc7 += " FROM "+ RetSqlName("SC7") + " SC7 (NOLOCK) "
					cQUsc7 += " WHERE  SC7.D_E_L_E_T_ <> '*' "
					cQUsc7 +="  AND C7_FILIAL= '" + xFilial("SC7") + "'
					cQUsc7 += " AND C7_NUM='" + QRY_SCR->CR_NUM + "' "

					DbUseArea(.T., "TOPCONN", TCGenQry( , , cQUsc7), "cQUsc7",.F.,.T.)
					*/
					BeginSQL Alias "cQUsc7"
						SELECT
							SC7.C7_ITEM,
							SC7.C7_TOTAL
						FROM
							%Table:SC7% SC7 (NOLOCK)
						WHERE
							SC7.%NotDel%
							AND SC7.C7_FILIAL = %XFILIAL:SC7%
							AND SC7.C7_NUM = %EXP:QRY_SCR->CR_NUM%
					EndSQL

					While cQUsc7->(.NOT. EOF())

						DbSelectArea("DBM")
						DBM->(DbSetOrder(1))
						//DBM->(DbGoTop()) //Retirado o reposicionamnto para TOP de arquivo visto que os registros virão de query MAA 20251020

						/*
						cQUdbm:= " SELECT * FROM "+ RetSqlName("DBM") + " DBM (NOLOCK) "
						cQUdbm+= " WHERE DBM_NUM= '" + QRY_SCR->CR_NUM + "' "
						cQUdbm+= " AND DBM_GRUPO = '" + QRY_SCR->CR_GRUPO + "' "
						cQUdbm+= " AND DBM_ITGRP ='" + QRY_SCR->CR_ITGRP + "' "
						cQUdbm+= " AND DBM_USAPRO ='" + SAL->AL_APROV + "' "
						cQUdbm+= " AND DBM_USER  ='" + SAL->AL_USER + "' "
						cQUdbm+= " AND DBM.D_E_L_E_T_ = ' ' " //acrescentado linha de D_E_L_E_T_ MAA 20251020

						DbUseArea(.T., "TOPCONN", TCGenQry( , , cQUdbm), "cQUdbm",.F.,.T.)
						*/
						BeginSQL Alias "cQUdbm"
							SELECT
								COUNT(*) AS REG 
							FROM
								%Table:DBM% DBM (NOLOCK)
							WHERE
								DBM.%NotDel%
								AND DBM.DBM_FILIAL = %XFILIAL:DBM%
								AND DBM.DBM_NUM = %Exp:QRY_SCR->CR_NUM%
								AND DBM.DBM_GRUPO = %Exp:QRY_SCR->CR_GRUPO%
								AND DBM.DBM_ITGRP = %Exp:QRY_SCR->CR_ITGRP%
								AND DBM.DBM_USAPRO = %Exp:SAL->AL_APROV%
								AND DBM.DBM_USER = %Exp:SAL->AL_USER%
						EndSQL

						If  cQUdbm->REG == 0 //(EOF())

							//!(DBM->(DbSeek(xFilial("DBM")+QRY_SCR->CR_NUM+QRY_SCR->CR_GRUPO+QRY_SCR->CR_ITGRP+QRY_SCR->CR_USER))) //	DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USER+DBM_USEROR
							// if DBM->(DbSeek(Alltrim(QRY_SCR->CR_FILIAL+QRY_SCR->CR_NUM)+Alltrim(QRY_SCR->CR_GRUPO+QRY_SCR->CR_ITGRP+QRY_SCR->CR_USER+"  ")))

							RecLock('DBM', .T.)

							DBM->DBM_FILIAL := QRY_SCR->CR_FILIAL
							DBM->DBM_TIPO   := QRY_SCR->CR_TIPO
							DBM->DBM_NUM    := QRY_SCR->CR_NUM
							DBM->DBM_ITEM   := cQUsc7->C7_ITEM
							DBM->DBM_GRUPO  := QRY_SCR->CR_GRUPO
							DBM->DBM_ITGRP  := QRY_SCR->CR_ITGRP
							DBM->DBM_USER   := SAL->AL_USER
							DBM->DBM_APROV  := '2'
							DBM->DBM_USAPRO := SAL->AL_APROV
							DBM->DBM_TIPCOM := (SubStr(cQUsc7->C7_ITEM, 2, 3))
							DBM->DBM_VALOR  := cQUsc7->C7_TOTAL

							DBM->(MsUnlock())

						EndIf

						cQUdbm->(DbCloseArea())

						cQUsc7->(DbSkip())
					End

					cQUsc7->(DbCloseArea())

				Endif
			End

		End

		QRY_SCR->(DbSkip())

	EndDo

	QRY_SCR->(DbCloseArea())

	If lJob
		// Finaliza o ambiente
		//RESTORE ENVIRONMENT PROG
		RpcClearEnv()
	End

Return (NIL)
