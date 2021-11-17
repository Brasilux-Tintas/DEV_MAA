#Include "PROTHEUS.CH"
#Include "COLORS.CH"
#Include "TOPCONN.CH"
#include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "sigawin.ch"
#include "STDWIN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
// Ponto de entrada para estornar a transferencia
// Dyego Figueiredo - www.chaus.com.br
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MA260EXC()
     Local aArea   := GetArea()   
     Local recnoD3 := SD3->(RECNO()) 
 
     If FWCodEmp() = '11' //Empresas que são do grupo 11(Tecpolpa).
        If !Empty(SD3->D3_XDOCPAL)
           EstornaPal(SD3->D3_XDOCPAL)
        //Else
        //   EstornaPallet(SD3->D3_DOC) // casos onde o pallet eh incluso no mesmo doc do pa/ta
        Endif
        If !Empty(SD3->D3_XDOCPA2)
           EstornaPal(SD3->D3_XDOCPA2)
        Endif
        SD3->(DbGoto(recnoD3))
        RestArea(aArea)
     Endif
Return 


//Funcao para selecionar a documento relativo ao estorno
Static Function EstornaPal(cDocPallet)

DbSelectArea("SD3")
SD3->(DbSetOrder(2)) //	D3_FILIAL 	D3_DOC 	D3_COD
SD3->(dbSeek(xFilial("SD3")+ cDocPallet ))
While !SD3->(EOF()) .AND. AllTrim(SD3->D3_DOC) == AllTrim(cDocPallet )
		 
	//If Alltrim(SD3->D3_COD) == Alltrim(GETMV("MV_XCODPLT")) .AND. SD3->D3_ESTORNO != "S"
	If ehPalete(Alltrim(SD3->D3_COD))  .AND. SD3->D3_ESTORNO != "S"
	 	EstPallet(SD3->D3_DOC,  SD3->D3_NUMSEQ)
	Endif			
	
	SD3->(DBSKIP())							
Enddo

Return


//Funcao para estornar a transferencia do Pallet
Static function EstPallet(cDocPallet, cNumSeq)	
	//Local cArmOri    := '' // Armazem de Origem
	//Local cArmDestin := '' // Armazem de destino
	Local cDocto := ""
	//Local i
	Local cRetorno := ""

	Private lMsHelpAuto := .F. // se .t. direciona as mensagens de help para o arq. de log
	Private lMsErroAuto := .F. //necessario a criacao, pois sera //atualizado quando houver
	
	
		//cDocto	:= GetSxENum("SD3","D3_DOC",1)		
	cDocto := cDocPallet				
					
	aAuto := {}
	aadd(aAuto,{cDocto,dDataBase})  //Cabecalho
		
		
	aadd(aAuto,	arrayPalle( cNumSeq ) )
	
										
	MSExecAuto({|x,y| mata261(x,y)},aAuto,6) // estorno
		

	If lMsErroAuto
		cRetorno := MostraErro("C:\temp\rtransf\")
		
		IF ('A260NAO' $ Upper(cRetorno) )
			cRetorno := "Sucesso"
			
		Else
			AVISO("MA260EXC", cRetorno, { "Ok" }, 1)
			DisarmTransaction() 
		Endif	
	Else
		cRetorno := "Sucesso"
	Endif

			
Return .T.



Static Function arrayPalle( cNumSeq)

	cArmDestin :=  GETMV("MV_XARDPLT") //  Armazem padrao de destino dos Pallets E1PA
	//cArmOrigem :=  GETMV("MV_XAROPLT") //  Armazem padrao de origem dos Pallets ECPC

	cCodPallet 	:= GETMV("MV_XCODPLT")
	cDesc 		:= Posicione("SB1",1,xFilial("SB1")+cCodPallet,"B1_DESC")
	cArmOrigem 	:= Posicione("SB1",1,xFilial("SB1")+cCodPallet,"B1_LOCPAD")

	//LGS#20200131 - Adequação de release 12.1.25 e posteriores
	//CONOUT("PALLET-->")
	FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', "PALLET-->", 0 )
	//CONOUT(cCodPallet)
	FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', cCodPallet, 0 )
	
	aItem := {}

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If !SB1->(dbSeek(xFilial("SB1")+ cCodPallet ) )
		Return
	Endif
	dValid := dDatabase+SB1->B1_PRVALID
		
			
			
		//Itens a Incluir				
	aadd(aItem,SB1->B1_COD)  	//D3_COD
	aadd(aItem,SB1->B1_DESC)    //D3_DESCRI
	aadd(aItem,SB1->B1_UM)  	//D3_UM
		

	//aadd(aItem,SB1->B1_LOCPAD  )//D3_LOCAL
	aadd(aItem,cArmDestin)      //D3_LOCAL
	aadd(aItem,"")				//D3_LOCALIZ
			
	aadd(aItem,SB1->B1_COD)  	//D3_COD
	aadd(aItem,SB1->B1_DESC)    //D3_DESCRI
	aadd(aItem,SB1->B1_UM)  	//D3_UM
				
	//aadd(aItem,cArmDestin)      //D3_LOCAL
	aadd(aItem,cArmOrigem )//D3_LOCAL
	aadd(aItem,"")				//D3_LOCALIZ
			
	aadd(aItem,"")          	//D3_NUMSERI
	aadd(aItem,"")				//D3_LOTECTL
	aadd(aItem,"")         		//D3_NUMLOTE
	aadd(aItem,dValid)			//D3_DTVALID
	aadd(aItem,0)				//D3_POTENCI
	aadd(aItem,1) 				//D3_QUANT
	aadd(aItem,0)				//D3_QTSEGUM
	aadd(aItem,"S")   			//D3_ESTORNO
	aadd(aItem,cNumSeq)    		//D3_NUMSEQ
	aadd(aItem,"")				//D3_LOTECTL
	aadd(aItem,dValid)			//D3_DTVALID
	aadd(aItem,"")				//D3_ITEMGRD
	aadd(aItem,"")				//D3_IDDCF   //Alteração por Igor MAnrique - Chaus, acrescentando campo necessário 12.1.16
	aadd(aItem,"")				//D3_OBSERVA //Alteração por Igor MAnrique - Chaus, acrescentando campo necessário 12.1.16
										
Return aItem



//VERIFICA SE O CODIGO EH DE PALETE
Static function ehPalete(cCod )

	Local cCodPalet := ""
	//Local qAtua := 0
	Local lRet := .F.

	Private cQLinha   := Chr(13) + Chr(10)

	If Select("TMSB2")<>0
		dbselectarea("TMSB2")
		dbclosearea()
	Endif

	cQuery := "SELECT B1_COD, B1_DESC, B1_LOCPAD							"+cQLinha
	cQuery += "FROM "+RetSqlName("SB1")+" SB1 								"+cQLinha
	cQuery += "WHERE SB1.D_E_L_E_T_ = '' 									"+cQLinha
	cQuery += "AND B1_FILIAL 	= '"+xFilial("SB1")+"'						"+cQLinha
	cQuery += "AND B1_COD = '" + cCod+ "' 	     	"+cQLinha
	cQuery += "AND B1_DESC LIKE 'PALETE%'									"+cQLinha

	

	TCQUERY cQuery ALIAS TMSB2 NEW
	dbSelectArea("TMSB2")
	dbGoTop()

	If TMSB2->(EOF())
 	   //LGS#20200131 - Adequação de release 12.1.25 e posteriores
	   //ConOut("A Query nao retornou dados - fonte MA260.prw")
	   FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', "A Query nao retornou dados - fonte MA260.prw", 0 )
	Endif

	If !TMSB2->(EOF()) 
 
		cCodPalet 	:= TMSB2->B1_COD
		lRet := .T.
		
	EndIf

Return lRet 
