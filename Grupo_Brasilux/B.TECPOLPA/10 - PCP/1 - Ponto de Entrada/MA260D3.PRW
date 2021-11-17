#Include "PROTHEUS.CH"
#Include "COLORS.CH"
#Include "TOPCONN.CH"
#include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "sigawin.ch"
#include "STDWIN.CH"
#INCLUDE "TBICONN.CH"
// Ponto de entrada apos confirmacao da transferencia
// Objetivo: incluir uma transferencia do Pallet apos a transferencia do PA/TA 
// Dyego Figueiredo - www.chaus.com.br
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MA260D3()
     Local aArea      := GetArea()
     Local recnoD3    := SD3->(RECNO())
     Local qtdPallets := 0
     Private _aregSD3 := aClone(AREGSD3)
     Private cDocOrig := SD3->D3_DOC
     Private cSeqOrig := SD3->D3_NUMSEQ

    If FWCodEmp() = '11' //Empresas que são do grupo 11(Tecpolpa).
       // VERIFICA SE EH PA/TA
       If !Posicione("SB1",1,xFilial("SB1")+M->CCODORIG,"B1_TIPO") $ "PA/TA" .or. Alltrim(M->cLocDest) != GetMv("MV_XARDPLT")
          SD3->(DbGoto(recnoD3))
          RestArea(aArea)
          Return
       Endif
       codPalete := Alltrim(GETMV("MV_XCODPLT"))
       codCliPalet := ""
       qtdPalCli := 0
       aRetSaldo := salPalCli()
       codCliPalet := aRetSaldo[1]
       qtdPalCli := aRetSaldo[2]
       //os armazens de origem e destino, devem ser os mesmos do Pallet
       qtdPallets := calcQtd(M->cCodOrig, M->NQUANT260)
       // se tem paletes do cliente suficiente, transfere eles
       If (qtdPalCli >= qtdPallets  )
          TransfPall(qtdPallets, codCliPalet)
          // se tem paletes do cliente mas nao sao suficientes, transfere os paletes dos clientes e o restante da tecpolpa
       Elseif (qtdPalCli >0 )
              TransfPall(qtdPalCli, codCliPalet)
              TransfPall(qtdPallets - qtdPalCli, codPalete)
              // senao transfere apenas paletes tecpolpa
       Elseif (qtdPallets >0 )
              TransfPall(qtdPallets, codPalete)
       Endif
       SD3->(DbGoto(recnoD3))
       RestArea(aArea)
     Endif
Return


Static function TransfPall(qtdPallets, codPalete)

	//Local aVetor     := {}
	//Local nOpc       := 3 //-Opção de execução da rotina, informado nos parametros quais as opções possiveis
	 
	//Local cSeqDocto := SD3->D3_NUMSEQ
	Local i
	//Local lRet := .F.
	//Local lOK  := .F.
	//Local aItens:={}
	//Local aItem:={}
	Local cRetorno := ""
	Private lMsErroAuto:=.F.

 	

	If len(_aregSD3) > 0
		SD3->(DbGoto(_aregSD3[1]))
	
		cDocto := SD3->D3_DOC
	Else
		return
	Endif
					
	cDocto	:= GetSxENum("SD3","D3_DOC",1)
	
	
	While (.T.)
		If Empty(Posicione("SD3",2,xFilial("SD3")+cDocto,"D3_DOC"))
			exit
		Endif
		
		cDocto	:= GetSxENum("SD3","D3_DOC",1)
	EndDo
					
		
	aAuto := {}
	aadd(aAuto,{cDocto,dDataBase})  //Cabecalho
		
		
	aadd(aAuto,	arrayPalle( qtdPallets,codPalete ) )
	
										
	MSExecAuto({|x,y| mata261(x,y)},aAuto,3)
		
	if lMsErroAuto
		RollbackSx8()
	Else
		//If  reclock('SD3',.T.)
			ConfirmSx8()
		//	msunlock('SD3')
		//Endif
	endif

	If lMsErroAuto
		cRetorno := MostraErro()
		
	Else
	   		
	   		//certifica que gravou o documento correto
		DbSelectArea("SD3")
		SD3->(DbSetOrder(2)) //	D3_FILIAL 	D3_DOC 	D3_COD
		If  SD3->(dbSeek(xFilial("SD3")+ cDocto ))
		 
			If Alltrim(SD3->D3_COD) == codPalete //Alltrim(GETMV("MV_XCODPLT"))
				For i:= 1 to len (_aregSD3)
					SD3->(DbGoto(_aregSD3[i]))
						
					// grava na SD3 do PA o codigo da transferencia do PA -> Amarra o Pa com o Pallet
					If  Empty(SD3->D3_XDOCPAL) .and. cDocOrig == SD3->D3_DOC .and.  cSeqOrig == SD3->D3_NUMSEQ
						reclock('SD3',.F.)
						SD3->D3_XDOCPAL := cDocto
						msunlock('SD3')
					
					// grava na SD3 do PA o codigo da transferencia do PA -> Amarra o Pa com o Pallet
					elseIf !Empty(SD3->D3_XDOCPAL) .and. Empty(SD3->D3_XDOCPA2) .and. cDocOrig == SD3->D3_DOC .and.  cSeqOrig == SD3->D3_NUMSEQ
						reclock('SD3',.F.)
						SD3->D3_XDOCPA2 := cDocto
						msunlock('SD3')
					Endif
				Next i
				
				
			Endif
		 
		Endif
		cRetorno := "Sucesso"
	Endif

			
Return .T.


// Monta os itens da transferencia
Static Function arrayPalle( qtdPallets, cCodPallet)

	If qtdPallets <= 0
		Return
	Endif

	//cCodPallet 	:= GETMV("MV_XCODPLT")
	cDesc 		:= Posicione("SB1",1,xFilial("SB1")+cCodPallet,"B1_DESC")
	
	cArmOrigem := GetMv("MV_XAROPLT")
	cArmDestin := GetMv("MV_XARDPLT")

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
	Else
		cArmOrigem := SB1->B1_LOCPAD
	Endif
	dValid := dDatabase+SB1->B1_PRVALID
		
			
			
		//Itens a Incluir				
	aadd(aItem,SB1->B1_COD)  	//D3_COD
	aadd(aItem,SB1->B1_DESC)    //D3_DESCRI
	aadd(aItem,SB1->B1_UM)  	//D3_UM
		

	aadd(aItem,cArmOrigem  )		//D3_LOCAL
	aadd(aItem,"")				//D3_LOCALIZ
			
	aadd(aItem,SB1->B1_COD)  	//D3_COD
	aadd(aItem,SB1->B1_DESC)    //D3_DESCRI
	aadd(aItem,SB1->B1_UM)  	//D3_UM
				
	aadd(aItem,cArmDestin )      //D3_LOCAL
	aadd(aItem,"")				//D3_LOCALIZ
			
	aadd(aItem,"")          	//D3_NUMSERI
	aadd(aItem,"")				//D3_LOTECTL
	aadd(aItem,"")         		//D3_NUMLOTE
	aadd(aItem,dValid)			//D3_DTVALID
	aadd(aItem,0)				//D3_POTENCI
	aadd(aItem,qtdPallets)		//D3_QUANT
	aadd(aItem,0)				//D3_QTSEGUM
	aadd(aItem,"")   			//D3_ESTORNO
	aadd(aItem,"")         		//D3_NUMSEQ
	aadd(aItem,"")				//D3_LOTECTL
	aadd(aItem,dValid)			//D3_DTVALID
	aadd(aItem,"")				//D3_ITEMGRD
	//aadd(aItem,"")	comentar se 16 descomentar se for 17			//D3_IDDCF //Alteração por Igor MAnrique - Chaus, acrescentando campo necessário 12.1.16
	aadd(aItem,"")				//D3_OBSERVA //Alteração por Igor MAnrique - Chaus, acrescentando campo necessário 12.1.16								
		
Return aItem


//Calcula a quantidade de pallets que serao transferidos
Static Function calcQtd(_cCodProd, qtdPa )

	Local nQtdPallet := 0

	Dbselectarea("SB5")
	SB5->(dbSetorder(1))
	If !SB5->(dbSeek(xFilial("SB5")+_cCodProd))
		MsgAlert("Não será realizada a transferência de armazém do Pallet, pois o complemento do produto "+_cCodProd+" não foi cadastrado. Realize a transferência do Pallet manualmente e atualize o complemento do produto mencionado.  " , "MA260D3.PRW")
			
		Return nQtdPallet
	Endif
		
	If SB5->B5_EMPMAX*SB5->B5_ECPROFU == 0
		MsgAlert("Não será realizada a transferência de armazém do Pallet, pois o complemento do produto "+_cCodProd+" foi cadastrado incorretamente, o lastro não pode ser zero. Realize a transferência do Pallet manualmente e atualize o complemento do produto mencionado. " , "MA260D3.PRW")
		
		Return nQtdPallet
	Endif
		
		   
	nQtdPallet +=  Ceiling(  qtdPa / (SB5->B5_EMPMAX*SB5->B5_ECPROFU) )
		
Return nQtdPallet





//VERIFICA SE O CLIENTE POSSUI PALETE PROPRIO E QUANTO TEM DE SALDO
Static function salPalCli( )

	Local cCodPalet := ""
	Local qAtua := 0

	Private cQLinha   := Chr(13) + Chr(10)

	If Select("TMSB2")<>0
		dbselectarea("TMSB2")
		dbclosearea()
	Endif

	cQuery := "SELECT B1_COD, B1_DESC, B1_LOCPAD, B2_QATU					"+cQLinha
	cQuery += "FROM "+RetSqlName("SB1")+" SB1 								"+cQLinha
	cQuery += "		INNER JOIN "+RetSqlName("SB2")+" SB2 ON B2_FILIAL 	= '"+xFilial("SB2")+"' AND B2_COD = B1_COD AND B1_LOCPAD = B2_LOCAL	AND SB2.D_E_L_E_T_ = '' 	"+cQLinha
	cQuery += "WHERE SB1.D_E_L_E_T_ = '' 									"+cQLinha
	cQuery += "AND B1_FILIAL 	= '"+xFilial("SB1")+"'						"+cQLinha
	cQuery += "AND B1_COD LIKE '" + SUBSTR(SD3->D3_COD,1,4) + "%' 	     	"+cQLinha
	cQuery += "AND B1_DESC LIKE 'PALETE%'									"+cQLinha

	

	TCQUERY cQuery ALIAS TMSB2 NEW
	dbSelectArea("TMSB2")
	dbGoTop()

	If TMSB2->(EOF())
		//LGS#20200131 - Adequação de release 12.1.25 e posteriores
		//ConOut("A Query nao retornou dados - fonte MA260.prw")
		FwLogMSG( "INFO", , 'SIGAPCP', funname(), '', '01', "A Query nao retornou dados - fonte MA260.prw", 0 )
	Endif

	If !TMSB2->(EOF()) .AND.  B2_QATU > 0
 
		cCodPalet 	:= TMSB2->B1_COD
		qAtua 		:= TMSB2->B2_QATU
		
	EndIf

Return {cCodPalet,qAtua }
