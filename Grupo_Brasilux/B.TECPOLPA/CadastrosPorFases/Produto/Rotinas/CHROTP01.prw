#Include 'Protheus.ch'


/**  Chamado no ponto de entrada A010TOK - Validação para inclusão ou alteração do Produto
*** Funcao chamada para validar se o usuario preencheu os campos obrigatorios
*** de acordo com a regra por campos/tipo de cadastro/Grupo de Usuario definida na tabela SZP
***/


User Function CHROTP01()

Local lRet := .T.

If  Altera .OR. Inclui
	lRet := U_ChRotG04("P")
Endif

Return lRet

