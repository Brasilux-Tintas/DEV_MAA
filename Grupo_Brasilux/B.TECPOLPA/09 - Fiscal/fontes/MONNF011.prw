#INCLUDE "PROTHEUS.CH"

/*
* Funcao			: MONNF011 
* Autor				: Marcos Bortoluci
* Data				: 16/01/2019
* Descrição			: Array para execução de JOB por Empresa/Filial
* Observacoes		: 
*/ 
User Function MONNF011() 
	Local aParam 	:= {}
	
	If ISINCALLSTACK("U_MONNF002") .Or. ISINCALLSTACK("U_MONNF020") //Comunicação com o SEFAZ
		// Empresa/Filial
		aAdd(aParam , { "01" , "010101" })	// CNPJ 72770878000117 - GRUPO BRASILUX - MATRIZ
		aAdd(aParam , { "01" , "060101" })	// CNPJ 59599555000144 - GRUPO BRASILUX - DISSOLTEX
		aAdd(aParam , { "11" , "11" })		// CNPJ 14848969000121 - GRUPO TECPOLPA - TECPOLPA
	EndIf
	                                      
	If ISINCALLSTACK("U_MONNF004") //Recebimento de E-mail
		// Empresa/Filial
	EndIf
	
	If ISINCALLSTACK("U_MONNF005") //Leitura do XML e importação para o Banco de Conhecimento do Protheus
		// Empresa/Filial
	EndIf
	
Return(aParam)