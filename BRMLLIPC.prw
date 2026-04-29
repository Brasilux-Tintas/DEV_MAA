#Include "Totvs.ch"
/*/{Protheus.doc} BRMLLIPC
Programa para rodar em JOB para enviar email para aprovadores informadno de pendencias de liberação em PC
@type function Processamento
@version  1.00
@author marioantonaccio
@since 18/03/2026
@return character, sem retorno
/*/
User Function BRMLLIPC()

	Local aAprov    := {}       as array
	Local aDocAprv  := {}       as array
	Local aDocs     := {}       as array
	Local aLinhas   := {}       as array
	Local aPend     := {}       as array
	Local cAprov    := ""       as character
	Local cDoc      := ""       as character
	Local cDoc2     := ""       as character
	Local cEmail    := ""       as character
	Local cForn     := ""       as character
	Local cHTML     := ""       as character
	Local cLoja     := ""       as character
	Local cRazao    := ""       as character
	Local cRazao2   := ""       as character
	Local cRowColor := ""       as character
	Local cTipo     := ""       as character
	Local cTipo2    := ""       as character
	Local cUsrID    := ""       as character
	Local dDt       := CTOD("") as date
	Local dEmissao  := CTOD("") as date
	Local nI        := 0        as numeric
	Local nJ        := 0        as numeric
	Local nNivel    := 0        as numeric
	Local nTot2     := 0        as numeric
	Local nTotal    := 0        as numeric
	Local nTotalGer := 0        as numeric

	// Verifica se ambiente esta aberto
	if GetRemoteType() == -1

		lJob:=.T.
		RpcClearEnv()
		RpcSetType(3) // 3 = Rotina automÃ¡tica

		if Type("cFilAnt") == "C" .and. TCIsConnected()
			ConOut("Ambiente Protheus aberto e pronto para uso - ZP_APROVPC")
		else
			//PREPARE ENVIRONMENT PROG
			RpcSetEnv("01","01",,,"COM")
		End

		//Define a empresa e filial a serem processadas
		//FWSetMV('MV_PAR01', 'SUA_FILIAL', .T.)

	End

	// 1. LER PENDÊNCIAS (SCR)
	BeginSql Alias "XSCR"
		SELECT
			CR_APROV,
			CR_NUM,
			CR_TIPO,
			CR_NIVEL,
			CR_TOTAL
		FROM
			%TABLE:SCR%
		WHERE
			CR_FILIAL = %XFILIAL:SCR%
			AND CR_STATUS = '02'
			AND CR_TIPO IN ('PC', 'IP')
			AND %NOTDEL%
		ORDER BY
			CR_APROV,
			CR_NUM
	EndSQl

	While .NOT. XSCR->(Eof())
		AAdd(aPend, {XSCR->CR_APROV,XSCR->CR_NUM,XSCR->CR_TIPO,XSCR->CR_NIVEL,XSCR->CR_TOTAL })
		XSCR->(DbSkip())
	EndDo
	XSCR->(dbCloseArea())

	If Len(aPend) == 0
		Return(NIL)
	EndIf

	// 2. LISTAR APROVADORES ÚNICOS
	For nI := 1 To Len(aPend)
		cAprov := aPend[nI][1]
		If ASCAN(aAprov, cAprov) == 0
			AAdd(aAprov, cAprov)
		EndIf
	Next

	// 3. AGRUPAR DOCUMENTOS POR APROVADOR
	For nI := 1 To Len(aAprov)

		cAprov := aAprov[nI]
		aDocs := {}  // Agora usa a variável LOCAL já declarada no topo
		For nJ := 1 To Len(aPend)
			If aPend[nJ][1] == cAprov
				AAdd(aDocs, { ;
					aPend[nJ][2], ; // Doc
					aPend[nJ][3], ; // Tipo
					aPend[nJ][4], ; // Nivel
					aPend[nJ][5] }) // Total
			EndIf
		Next

		AAdd(aDocAprv , { cAprov, aDocs })
	Next

	// 5. ENVIAR EMAIL POR APROVADOR
	For nI := 1 To Len(aDocAprv )

		cAprov := aDocAprv [nI][1]
		aDocs  := aDocAprv [nI][2]
		cUsrID := ""
		cEmail := ""

		SAK->(DbSetOrder(1))
		If SAK->(DbSeek(xFilial("SAK")+cAprov))
			cUsrID := AllTrim(SAK->AK_USER)
		EndIf

		If .NOT. Empty(cUsrID)
			cEmail :=  UsrRetMail(cUsrID)
		EndIf

		If Empty(cEmail)
			Loop
		EndIf

		// 5.1 Montar array de linhas COM fornecedor e emissão
		aLinhas := {}   
		For nJ := 1 To Len(aDocs)

			cDoc     := aDocs[nJ][1]
			cTipo    := aDocs[nJ][2]
			nNivel   := aDocs[nJ][3]
			nTotal   := aDocs[nJ][4]

			cForn    := ""
			cLoja    := ""
			dEmissao := Ctod("")
			cRazao   := ""

			// SC7: fornecedor + emissão
			SC7->(DbSetOrder(1))
			If SC7->(DbSeek(xFilial("SC7")+Substr(cDoc,1,6)))
				cForn    := AllTrim(SC7->C7_FORNECE)
				cLoja    := AllTrim(SC7->C7_LOJA)
				dEmissao := SC7->C7_EMISSAO

				// SA2: nome do fornecedor
				SA2->(DbSetOrder(1))
				If SA2->(DbSeek(xFilial("SA2")+SC7->C7_FORNECE + SC7->C7_LOJA))
					cRazao := AllTrim(SA2->A2_NREDUZ)
				EndIf
			End

			AAdd(aLinhas, {cTipo,cDoc,cRazao,dEmissao,nTotal })

		Next

		// 5.2 ORDENAR POR NOME DO FORNECEDOR
		ASort(aLinhas,,,{|x,y| x[3] < y[3] })

		// 5.3 Montar HTML (com zebra stripes)
		cHTML     := "" // Agora usa a variável LOCAL já declarada no topo
		cRowColor := "" // Agora usa a variável LOCAL já declarada no topo
		nTotalGer := 0 // Agora usa a variável LOCAL já declarada no topo

		//Corpo email
		cHtml:="<p>Prezado(a) Senhor(a) : "+AllTrim(Posicione("SAK",2,XfILIAL("SAK")+cUsrId,"AK_NOME"))+"</p>"
		cHtml+="<p>Existe(m) pedido(s) de Compra que necessita(m) de sua liberação</p>"
		cHtml+='<table style="height: 52px; width: 563px;" border="3">'
		cHtml+="<tbody>"
		cHtml+="<tr>"
		cHtml+='<td style="width: 106px;">Tipo</td>'
		cHtml+='<td style="width: 132px;">Numero</td>'
		cHtml+='<td style="width: 120.766px;">Emissao</td>'
		cHtml+='<td style="width: 170.234px; text-align: left;">Fornecedor</td>
		cHtml+='<td style="width: 133px; text-align: right;">Valor</td>'
		cHtml+='</tr>'

		For nJ := 1 To Len(aLinhas)

			cTipo2    := aLinhas[nJ][1]  // Agora usa variável LOCAL declarada no topo
			cDoc2     := aLinhas[nJ][2]
			cRazao2   := aLinhas[nJ][3]
			dDt       := aLinhas[nJ][4]
			nTot2     := aLinhas[nJ][5]

			// acumulador total geral
			nTotalGer += nTot2

			cHtml+='<tr>'
			cHtml+='<td style="width: 106px; text-align: left;">'+aLinhas[nJ][1]+'</td>'
			cHtml+='<td style="width: 132px; text-align: left;">'+aLinhas[nJ][2]+'</td>'
			cHtml+='<td style="width: 120.766px; text-align: left;">'+cValToChar(aLinhas[nJ][4])+'</td>'
			cHtml+='<td style="width: 170.234px; text-align: left;">'+aLinhas[nJ][3]+'</td>'
			cHtml+='<td style="width: 133px; text-align: right;">'+Transform(aLinhas[nJ][5],"@ER 999,999,999.99")+'</td>'
			cHtml+='</tr>'
			// cor alternada
		/*
			If (nJ % 2) == 0
				cRowColor := " style='background-color:#f2f2f2;' "
			Else
				cRowColor := " style='background-color:#ffffff;' "
			EndIf
*/
		Next

		// 5.4 TOTAL GERAL AO FINAL
		cHtml+='<tr>'
		cHtml+='<td style="width: 106px;">'+"Total"+'</td>'
		cHtml+='<td style="width: 132px;">'+Space(01)+'</td>'
		cHtml+='<td style="width: 120.766px;">'+Space(01)+'</td>'
		cHtml+='<td style="width: 170.234px;">'+Space(01)+'</td>'
		cHtml+='<td style="width: 133px;text-align: right;">'+Transform(nTotalGer,"@ER 999,999,999.99")+'</td>'
		cHtml+='</tr>
		cHtml+='</tbody>
		cHtml+='</table>
		cHtml+='<p>Para Libera&ccedil;&atilde;o pode utilizar o m&oacute;dulo COMPRAS do sistema Protheus atraves da rotina <span style="text-decoration: underline;">Libera&ccedil;&atilde;o de Pedidos</span> ou pode-se utilizar o aplicativo&nbsp; <strong><span style="text-decoration: underline;">MEU PROTHEUS</span></strong></p>
		cHtml+='<p>&nbsp;</p>
		cHtml+='<p style="text-align: left;">Atenciosamente</p>'
		
		aAnexos:={}
		//cEmail:="marioantonaccio@brasilux.com.br"
		lEnvio   := GPEMail("Documentos Pendentes para liberação",  cHTML, cEmail, aAnexos, .T.)
	Next

Return (NIL)
