#Include 'Protheus.ch'

/*/{Protheus.doc} MT094CPC
O Ponto de Entrada MT094CPC tem como funcionalidade exibir informações de outros campos
reais do pedido de compra/autorização de entrega no momento da liberação do documento.
Campos do tipo MEMO não são exibidos na grid.
@type function
@version 12.1.2310
@author jerfferson.menezes
@since 11/10/2024
@return character, String que contém o nome dos campos da tabela de pedido de compra/autorização de entrega intercalados com barras verticais.
@obs O ponto de entrada pode ser utilizado para exibir campos no App Meu Protheus
/*/
User Function MT094CPC()

	Local cCampos := " " //  A separação dos campos devem ser feitos com uma barra vertical ( | ), igual é demonstrado no exemplo.

	If .NOT. EMpty(SC7->C7_NUMSC)
		SC1->(dbSetorder(1))
		SC1->(dbSeek(xFilial("SC1")+SC7->C7_NUMSC))

		cCampos := "C7_JUSTIFI" //  A separação dos campos devem ser feitos com uma barra vertical ( | ), igual é demonstrado no exemplo.
	Else
		//cCampos := "C7_JUSTIFI|C7_OBSM|C7_NUMSC" //  A separação dos campos devem ser feitos com uma barra vertical ( | ), igual é demonstrado no exemplo.
		cCampos := "C7_JUSTIFI" //  A separação dos campos devem ser feitos com uma barra vertical ( | ), igual é demonstrado no exemplo.
	End
Return (cCampos)

/*
	Local cNumPC := ""
	Local cObsPC := " " // Exemplo: Campo extra na SC7 (Pedido de Compra)
	Local cObsSC := " " // Exemplo: Campo extra na SC7 (Pedido de Compra)
	Local lRet := .T.
	Local cMsg := " " // Variável para montar a mensagem a ser exibida
	Local aArea:=FwGetArea() // Guarda a área atual para retornar ao final da rotina

	// Verifica se a tabela SCR está posicionada (garantia da rotina)
	If Select("SCR") == 0
		SCR->(dbSetOrder(1))
	Else
		// O número do documento a ser liberado geralmente está no campo CR_DOC
		cNumPC := AllTrim(SCR->CR_NUM)

		// **IMPORTANTE**: A tabela que precisa ser consultada (SC7 ou SC9) deve ser
		// verificada, a rotina MATA094 trabalha com ambos. Para simplificar o exemplo,
		// vamos considerar que estamos focando na SC7 (Pedido de Compra).

		SC7->(DbSetOrder(1)) // C7_NUM + C7_ITEM + C7_FILIAL
		If SC7->(DbSeek(xFilial("SC7") + cNumPC)) // Busca o PC pela chave
			// Pega o conteúdo do campo extra
			If .NOT. Empty(SC7->C7_OBSM)
				cObsPC:=AllTrim(SC7->C7_OBSM)
			End
			If .NOT. Empty(SC7->C7_NUMSC)
				SC1->(dbSetOrder(1))
				SC1->(dbSeek(xFilial(SC7->C7_FILIAL) + SC7->C7_NUMSC))
				If .NOT. Empty(SC1->C1_OBS)
					cObsSC := AllTrim(SC1->SC1_OBS)
				End
			End

			// Exibe a informação para o usuário.
			// O PROTHEUS já tem um layout para isso na rotina.
			// O ideal é usar uma função de help ou mensagem para exibir o dado.
			cMSg:=" "
			If .NOT. Empty(cObsPC)
				cMSg += "Observação PC: " +CRLF+ cObsPC + " "
			End
			If .NOT. Empty(cObsSC)
				cMSg += "Observação SC: " + CRLF + cObsSC + " "
			End

			If .NOT. Empty(cMSg)
				// Exemplo usando a função de mensagem do Protheus, mas pode ser adaptada para o layout do App Meu Protheus
				// A função FWAlertInfo é apenas ilustrativa, substitua pela função de exibição de mensagem adequada ao seu contexto.
				//
				FWAlertInfo(cMsg,"Informação Extra")

				//Aviso("INFORMAÇÃO EXTRA:", "Conteúdo do " + cCampoExtra + ": " + cConteudoExtra, {"OK"})

				// Se a sua intenção for só mostrar o dado sem travar, pode ser um
				// MsgRun('...'), mas se for um dado crítico, uma pausa pode ser útil.

			EndIf
		End
	EndIf
	FWRestAea(aArea)
Return lRet
*/
