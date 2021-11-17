#include "TOPCONN.CH"
#include "RWMAKE.CH"
#INCLUDE "TBICONN.CH"




/*     
Chamado no ponto de entrada - MT410LIOK 
Objetivo: Verifica se o produto,fornecedor e cliente estao com o cadastro ok 
(passaram por todas etapas)
*/


User Function CHROTG13()


	Local lRet := .T.
	Local aArea := GetArea()
	
	Local cAliaAnte := Alias()
	Local nAreaAnte := IndexOrd()
	Local nRegiAnte := RecNo()
	                   
	Local _nItem			:= 0
	Local _lRet				:= .T.
	Local _cProduto 		:= ACols[n,Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})]



	_nItem := n
	_nCont := 1
                                                                             
	If ACOLS[N,LEN(ACOLS[N])] // Entra se a linha estiver apagada

		nRetorno := .T.
		dbSelectArea(cAliaAnte)
		dbSetOrder(nAreaAnte)
		dbGoTo(nRegiAnte)
		Return(nRetorno)
	EndIf

		
//verifica se o cadastro do cliente foi finalizado
	If  SUPERGETMV("CF_ATIVARC", .F. , .F.)
		lRet := validaC(  M->C5_CLIENTE,M->C5_LOJACLI )
	Endif
    
    // verifica se o cadastro do produto foi finalizado
	If  lRet .AND. SUPERGETMV("CF_ATIVARP", .F. , .F.)
		lRet := validaP(_cProduto)
	Endif


	n := _nItem


// oGetDad:oBrowse:refresh()


	
Return lRet


            
//verifica se finalizou o cadastro  produto
Static Function validaP(cProduto)

	Local lRet := .T.
	Local nX
 
	dbselectArea('SB1')
	dbsetorder(1)
	dbgotop()

	lRet := .T.

	//For nX := 1 To Len(aCols)
	
	If dbSeek(xFilial('SB1')+cproduto )
		 
		If !GdDeleted(N) .And. Alltrim(SB1->B1_XCETAPA)  < Alltrim(GetMv("CF_ETAPAP") )
			MsgBox("O cadastro do produto '"+Alltrim(SB1->B1_COD)+ " (item "+AllTrim(str(N))+") " +"' ainda não foi finalizado. Favor, cobrar do setor responsável. ", "Atenção - ChRotG13.prw", "ALERT")
			lRet := .F.
				//exit
		Endif
	Endif
	//next nX
	
Return lRet


             
//verifica se finalizou o cadastro de cliente 
Static Function validaC(cCliente, cLoja)

	Local lRet := .T.
	Local nX
  
	dbselectArea('SA1')
	dbsetorder(1)
	dbgotop()
	If dbSeek(xFilial('SA1')+cCliente + cLoja)
		If  !GdDeleted(N) .And. Alltrim(SA1->A1_XCETAPA) < AllTrim(GetMv("CF_ETAPAC") )
			MsgBox("O cadastro do cliente ainda não foi finalizado. Favor, cobrar do setor responsável. ", "Atenção", "ALERT - ChRotG13.prw")
	    //mensagem  
			lRet :=  .F.
		Endif
	
	EndIF
	
Return lRet
