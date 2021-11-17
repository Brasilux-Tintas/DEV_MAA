#Include 'Protheus.ch'




/** Chamado no ponto de entrada MT010BRW - PE Adiciona Botoes no MATA010
*** Inclui o botao de legenda no cadastro de produto
***/

User Function CHROTP02()

	Local aButton	:= {}

	// campos disponiveis cadastro de produto
	Public _DisCpsP

	// campos obrigatorios cadastro de produto
	Public _ObrCpsP


	aAdd(aButton,{"Legenda","U_MT010LEG", 0, 3 })



/**
*** Funcao chamada na abertura do cadastro de produtos para
*** setar a variavel com os campos disponiveis do usuario
*** Dyego / Chaus
***/

	If  ( FunName() = 'MATA010' )
		U_CHROTG08("SB1")
		_DisCpsP := U_CHROTG06("P")
		_ObrCpsP := U_CHROTG07("P")
	Endif


Return aButton

