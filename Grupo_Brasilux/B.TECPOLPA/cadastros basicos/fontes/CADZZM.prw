#Include 'Protheus.ch'
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH"
  
/**  axcadastro ZZM - Custo de MOD
***  Objetivo: auxiliar o custo da MOD na formação de preços
***/      

User Function CADZZM()

	Private cCadastro := "Custo de Mao de Obra"
	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
		{"Visualizar","AxVisual",0,2} ,;
		{"Incluir","u_cIncZZM",0,3} ,; // {"Incluir","AxInclui",0,3} ,;
		{"Alterar","u_cAltZZM",0,4} ,;
		{"Excluir","AxDeleta",0,5} }

	Private cString := "ZZM"
	dbSelectArea("ZZM")
	dbSetOrder(1)


	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString)

Return


User Function cIncZZM()
           
	Local nOpcao := 0
	Local cTudoOk     := ".T."
	Local cMod1 := 'MOD147T1001' + space(TamSx3("B9_COD")[1] - 11)
	Local cMod2 := 'MOD147T1002' + space(TamSx3("B9_COD")[1] - 11)
	Local cMod3 := 'MOD147T1003' + space(TamSx3("B9_COD")[1] - 11)
	
	dbSelectArea("ZZM")
	dbSetOrder(1)
//If !dbSeek(xFilial('SA2')+M->A2_COD)
	nOpcao := axInclui("ZZM",0,3,,,,cTudoOk)
	If nOpcao == 1
		If MsgYesNo("Deseja gravar o novo valor do custo da hora da mao de obra no cadastro de produtos (esse valor sera usado na formacao de preco) ?")
			altCusto(cMod1, ZZM->ZZM_CUSTOH)
			altCusto(cMod2, ZZM->ZZM_CUSTOH)
			altCusto(cMod3, ZZM->ZZM_CUSTOH)
		Endif
		
		If MsgYesNo("Deseja fazer a inclusao do saldo inicial com o valor do custo da hora da mao de obra?")
			SaldoIni(cMod1, "01", ZZM->ZZM_CUSTOH)
			SaldoIni(cMod2, "01", ZZM->ZZM_CUSTOH)
			SaldoIni(cMod3, "01", ZZM->ZZM_CUSTOH)
		Endif
	EndIf

Return .T.


User Function cAltZZM()
           
	Local nOpcao 	:= 0
	LOCAL nReg    	:= ZZM->( Recno() )
	Local cTudoOk   := ".T."
	Local cMod1 := 'MOD147T1001' + space(TamSx3("B9_COD")[1] - 11)
	Local cMod2 := 'MOD147T1002' + space(TamSx3("B9_COD")[1] - 11)
	Local cMod3 := 'MOD147T1003' + space(TamSx3("B9_COD")[1] - 11)
 

	dbSelectArea("ZZM")
	dbSetOrder(1)
//If !dbSeek(xFilial('SA2')+M->A2_COD)
	nOpcao := AxAltera("ZZM",nReg,4,,,,,cTudoOk)
	If nOpcao == 1
		If MsgYesNo("Deseja gravar o novo valor do custo da hora da mao de obra no cadastro de produtos (esse valor sera usado na formacao de preco) ?")
			altCusto(cMod1, ZZM->ZZM_CUSTOH)
			altCusto(cMod2, ZZM->ZZM_CUSTOH)
			altCusto(cMod3, ZZM->ZZM_CUSTOH)
		Endif
		
		If MsgYesNo("Deseja fazer a inclusao do saldo inicial com o valor do custo da hora da mao de obra?")
			SaldoIni(cMod1, "01", ZZM->ZZM_CUSTOH)
			SaldoIni(cMod2, "01", ZZM->ZZM_CUSTOH)
			SaldoIni(cMod3, "01", ZZM->ZZM_CUSTOH)
		Endif
	
	EndIf
    

Return .T.

Static Function altCusto(cMod, nCusto)


	dbSelectArea("SB1")
	dbSetOrder(1)
	dbGoTop()

	If dbSeek(xFilial('SB1')+cMod)
		SB1->(RecLock("SB1",.F.))
		SB1->B1_XUPRC 	:= nCusto
		SB1->B1_XMAXPRC := nCusto
		SB1->(MsUnLock())
	
	Endif

Return


Static Function SaldoIni(cProduto, cLocDest, nCusto)

	Local aAutoSB9 := {}
	Local lMsErroAuto

	dbSelectArea("SB9")
	dbSetOrder(1)
	dbSeek(xFilial("SB9")+cProduto+cLocDest  )

	nOpc := 0
	
	If Found()//Alltrim(cSB9) == ''
		nOpc := 4	 // altera saldo inicial
	Else
		nOpc := 3	 // inclui saldo inicial
	EndIf
	
	aadd (aAutoSB9, {'B9_FILIAL',  	xFilial('SB9')	,NIL})
	aadd (aAutoSB9, {'B9_COD',  	cProduto   		,NIL})
	aadd (aAutoSB9, {'B9_LOCAL',	cLocDest		,NIL})
	aadd (aAutoSB9, {'B9_QINI',		1				,NIL})
	aadd (aAutoSB9, {'B9_VINI1',	nCusto			,NIL})
	aadd (aAutoSB9, {'B9_CM1',		nCusto			,NIL})
		
   			
	MsExecAuto({|x,y,z|MATA220(x,y,z)},aAutoSB9,nOpc)
	    
	If lMsErroAuto
		Alert("Erro ao incluir armazem "+alltrim(cLocDest)+" para o produto "+alltrim(cProduto)+". Informe este erro ao depto de Inform�tica!")
				//mostraerro("\log_execauto\","mata220_"+Alltrim(StrTran(cProduto,'/',''))+"_"+Alltrim(cLocDest)+".txt")
		lMsErroAuto := .F.
	EndIf
	    

	
  
Return
