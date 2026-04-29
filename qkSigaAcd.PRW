#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "apvt100.ch"

// STATIC __aRetCount	:= {} //Array que armazenara o retorno da analise do inventario ==>{lOk, aProdOk,aEtiQtdOk,aEtiLidas}
// STATIC __cMestre	:= ""

/*
Function: 4kNewInv()
Nova rotina de inventario

Autor:
Marcio Barretos

--		
Alteracao -> (18/05/2023-VALTER) - Alteração para buscar OP da tabela SZ5, pois no coletor não traz ITEM DA OP

*/		
User Function qkNewInv()

Local aTela
//Local nOpc

Private cArmazem
Private cEndereco
Private cEtiqend
Private cProduto
Private cEtiqProd
Private nQtdEtiq
Private cClasses 	:= ""
Private cCodOpe  	:=CBRetOpe()   //Busca o Cod. do Operador na Tabela "CB1"
Private aProdEnd	:={}
Private lMsErroAuto	:= .F.
Private lUsaCB001 	:=UsaCB0("01")
Private lUsaCB002 	:=UsaCB0("02")
Private lModelo1  	:=GetMv("MV_CBINVMD")=="1"
Private lForcaQtd 	:=GetMV("MV_CBFCQTD",,"2") =="1"
Private aRolos		:= {}
Private nRolos      := 0
Private nRecRol     := 0
Private cArmaz		:= SPace(2)
Private lQRCODE_	:= .F.
Private nQtdTot     := 0 

If Empty(cCodOpe)   //Se o Cod. de Usuario logado nao estiver cadastrado na Tabela "CB1"
	VTAlert("Operador nao cadastrado","Aviso",.T.,,3)
	Return .F.
EndIf
Do While .T.
	aTela := VtSave()
	VTCLear()
	@ 0,0 VTSAY "Inventario"
	@ 1,0 VTSay 'Selecione:'

	cCodInv := Space(TamSX3("CBA_CODINV")[1])
	@ 2,0 VTSay 'Codigo Mestre'
	@ 3,0 VTGet cCodInv Pict '@!'Valid QkVCInv(cCodInv)  F3 "CBB"
	VTRead

	If VtLastkey() == 27
		Return
	EndIf

	cArmazem := CBA->CBA_LOCAL

	While .T.

		VTClear
		VTCLEARBUFFER()
		cEndereco:= Space(15)
		nQtdTot := 0 
		@ 0,0 VTSAY "Inventario"
		@ 1,0 VTSay "Codigo Mestre"
		@ 2,0 VTSay "["+DTOC(CBA->CBA_DATA)	+"]"
		@ 3,0 VTSay "Endereco"
		@ 4,0 VTGet cEndereco Pict '@!' Valid QkVEnder()  //Criada a validacao do Endereco...Denis 07/06/16
		Vtread
		If VtLastkey() == 27 
			VTClear
			Exit
		EndIf
			
		If Empty(cEndereco)
			VTClear
			Loop
		EndIf
					
		nQtdTot     := 0 
		@ 0,0 VTSAY "Inventario"
		@ 1,0 VTSay "Codigo Mestre"
		@ 2,0 VTSay "["+DTOC(CBA->CBA_DATA)	+"]"
		@ 3,0  VTSay "Endereco"
		//@ 3,10 VTSay Transform(checkZZ5(cEndereco,cArmazem),"9999")
		@ 3,10 VTSay cEndereco
		/*
		@ 4,0  VTSay "Qtd Rolos:"
		@ 4,12 VTGet nQtdTot Pict '@E 9999' Valid nQtdTot > 0
		*/
		Vtread
		If VtLastkey() == 27 //.or. Empty(cEndereco)
			VTClear
			Loop
		EndIf

		nRolos:=QtdRolEnd("I")   //Caso a conexao do coletor caiu, ao retornar mostra a quantidade de rolos ja lidos no endereco. ... Denis 07/06/16
		//Evitando o usuario ter que ir ate um computador p/ imprimir os rolos que ja foram lidos, p/ saber a quantidade do endereco.

		While .T.

			VTClear
			VTCLEARBUFFER()
			cEtiqend := Space(52)
			cProduto := Space(15)
			cEtiqProd:= Space(52)
			aRolos   := {}

			@ 0,0 VTSay 'Inventario'
			@ 1,0 VTSay 'Armazem ' + cArmazem
			@ 2,0 VTSay 'Endereco ' + SubStr(cEndereco,3,8)
			@ 3,0 VTSay 'Rolos Lidos ' 
			//@ 4,0 VTSay  Trim(Str(nRolos,4,0))+'/'+Trim(Str(nQtdTot,4,0))	
			@ 4,0 VTSay  Trim(Str(nRolos,4,0))
			@ 6,0 VTSay "Rolo"
			@ 7,0 VTGet cEtiqProd pict "@!" Valid VTLastkey() == 5  .or. QkVERolo("I"," ")
			VTRead

			If VtLastkey() == 27
				VTClear
				Exit
			EndIf
		
			grvZZ8("I")

			++nRolos
			//If nRolos = nQtdTot
			//	VTAlert("Endereço Finalizado","Aviso",.T.,3000)
			//	Exit
			//Endif	
		End
		//If nRolos = nQtdTot
		//	Loop
		//Endif			
	End
End

Return


/*
Function: VldEnder
Valida a leitura da etiqueta de Endereco

Autor:
Denis Soares da Silva - 07/06/16

*/
Static Function QkVEnder()

Local cOpc:=" "
Private lQRCODE_:= .F.

VTClear
VTCLEARBUFFER()
If Len(Alltrim(cEndereco)) <> 4
	@ 5,0 VTSay "Endereco: " + Alltrim(cEndereco)
	@ 6,0 VTSay "Esta Correto? S/N "
	@ 7,0 VTGet cOpc Pict '!' Valid !Empty(cOpc) .and. cOpc$"SN"
	VTRead
	@ 5,0 VTSay Space(20)
	@ 6,0 VTSay Space(20)
	@ 7,0 VTSay Space(10)
	If cOpc=="N"
		Return .F.
	Endif
Endif
VTCLEARBUFFER()
Return .T.


/*
	Function: VldEtiRolo
		Valida a leitura da etiqueta do produto
	
	Autor:
		Marcio Barretos - 02/07/12
		
*/
Static Function QkVERolo(cOrig,cEndereco)

Local cLote,dDtVal,cNumSer,cOp,cPartida,cRoman,clFornece,clLojaFor, cNotaFi, nPesoIni, cOpEtiq
Local c4KTRFPU := "", a:=0
Local oEtiq    := class_Etiqueta():New()
Local oRolo
Default cEndereco := ""
Private cCodProd:=" "
Private nQuant:=0
Private lQRCODE_:=.f.

If Empty(cEtiqProd)
	VTAlert("Cod.Barra incorreto","Aviso",.T.,,3) 
	Return .F.
Endif	
oRolo := oEtiq:lerEtiqueta(cEtiqProd)

If oEtiq:gotError()
	VTAlert(oEtiq:getLastError(),"AVISO",.T.,,3)	
	cEtiqProd:= Space(48)
	FreeObj(oEtiq)
	FreeObj(oRolo)	
	Return .F.
EndIf

//VTAlert("Tamanho: "+STR(Len(Alltrim(cEtiqProd))),"AVISO",.T.,3000)
If oEtiq:trazTipo() == "QR"
   
	cNumSer  := Substr(cEtiqProd,1,7)
	nQuant   := Val(Substr(AllTrim(cEtiqProd),9))/100

// Fernando - 31/08/2018
   lQRCODE_:=.F.
   IF Substr(cEtiqProd,1,2)='QR' .AND. LEN(ALLTRIM(cEtiqProd))=9
   		lQRCODE_	:=.T.
    	cNumSer := Substr(cEtiqProd,3,7)
    	// VTAlert("QRCODE " + cNumSer,"AVISO",.T.,4000)
   ENDIF

	SZ5->(dbSetOrder(2))
	SZ5->(MsSeek(xFilial("SZ5")+cNumSer))
	If SZ5->(Found())
		//VTAlert("Rolo .. ENCONTRADO "+STR(SZ5->(RECNO())),"AVISO",.T.,3000)
		cCodProd  := SZ5->Z5_PROD
		cLote    := " "
		dDtVal   := " "
		cOp      := SZ5->Z5_OP
		cPartida := SZ5->Z5_PARTIDA
		nRecRol  := SZ5->(Recno())

// Fernando - 31/08/2018
		IF lQRCODE_
			nQUANT:=SZ5->Z5_PESOATU
		ENDIF 

	Else
		VTAlert("Rolo invalido - Reimprimir etiqueta","AVISO",.T.,,3)
		
		cOpc:=" "
		
		@ 5,0 VTSay "Erro na leitura!"
		@ 6,0 VTSay "Deseja Continuar? S/N"
		@ 7,0 VTGet cOpc Pict '!' Valid !Empty(cOpc) .and. cOpc $ "SN"
		VTRead
		@ 5,0 VTSay Space(20)
		@ 6,0 VTSay Space(20)
		@ 7,0 VTSay Space(10)
		
		If cOpc == "N"
			cEtiqProd:= Space(48)
			FreeObj(oEtiq)
			FreeObj(oRolo)	
			Return .F.
		Endif
		
	Endif
	cEtiqProd:= Space(48)
Else 
	cEtiqProd:= Space(48)
	cCodProd := oRolo:trazCodProd()
	nQuant   := oRolo:trazQuant()
	cLote    := " "
	dDtVal   := " "
	cNumSer  := oRolo:trazNumSer()
	//VALTER - ALTERADO AQUI PARA BUSCAR OP COM SEQUENCIA DA SZ5 ABAIXO E CRIADO cOpEtiq PARA COMPARAR COM SZ5
	//cOp      := oRolo:trazOp()
	cOpEtiq    := oRolo:trazOp()
	//
	cPartida := oRolo:trazPartida()

	SZ5->(dbSetOrder(2))
	SZ5->(MsSeek(xFilial("SZ5")+cNumSer))
	nRecRol  := SZ5->(Recno())
	cOp      := SZ5->Z5_OP
	IF  Empty(SZ5->Z5_OP)
		cOp      := oRolo:trazOp()
	ENDIF 
	//VALTER
	
Endif

SB1->(dbSetOrder(1))
SB1->(MsSeek(xFilial("SB1")+cCodProd))
If !SB1->(Found())
	VTAlert("Produto nao encontrado: "+cCodProd,"ATENCAO",.T.,,3)
	cEtiqProd:= Space(48)
	FreeObj(oEtiq)
	FreeObj(oRolo)	
	Return .F.
Endif

//Bloquar inventario de produtos que NAO foram selecionados para inventario...Denis 17/04/13
If cOrig=="I"    //Se foi chamado pela rotina de inventario
	SB2->(dbSetOrder(1))
	SB2->(MsSeek(xFilial("SB2")+cCodProd+cArmazem))
	If SB2->(Found())
		If SB2->B2_DTINV == CTOD("  /  /  ") .OR. SB2->B2_DINVFIM == CTOD("  /  /  ")
			VTAlert("Nao inventariar esse prod.: "+cCodProd,"ATENCAO",.T.,,3)
			cEtiqProd:= Space(48)
			FreeObj(oEtiq)
			FreeObj(oRolo)	
			Return .F.
		Endif
	Else
		VTAlert("Produto nao existe no SB2: "+cCodProd,"ATENCAO",.T.,,3)
		cEtiqProd:= Space(48)
		FreeObj(oEtiq)
		FreeObj(oRolo)	
		Return .F.
	Endif
Endif
//...Denis 17/04/13

If nQuant <= 0
	VTAlert("Peso lido menor ou igual a zero","ATENCAO",.T.,,3)
	cEtiqProd:= Space(48)
	FreeObj(oEtiq)
	FreeObj(oRolo)	
	Return .F.
Endif

//Inicio...Denis 12/09/13
If nQuant > 40
	VTAlert("Peso lido maior que 40 KG","ATENCAO",.T.,,3)
	FreeObj(oEtiq)
	FreeObj(oRolo)	
	cEtiqProd:= Space(48)
	Return .F.
Endif
	
If cOrig == "I"
	cRoman:="INVENT"
elseIf cOrig == "E"
	cRoman:="ENDERA"
EndIf
dbSelectArea("SZ5")
SZ5->(dbSetOrder(2)) 
SZ5->(MsSeek(xFilial("SZ5")+cNumSer))  
If SZ5->(Found())
    cRoman:=SZ5->Z5_ROMAN  //Denis 07/06/14
    clFornece := SZ5->Z5_FORNENF//Adam Diniz - 16/06/2014 - Gravacao dos campos de fornecedor na ZZ8
    clLojaFor := SZ5->Z5_LOJAFOR//Adam Diniz - 16/06/2014 - Gravacao dos campos de fornecedor na ZZ8
	cNotaFi   := SZ5->Z5_NFISCAL
	nPesoIni  := SZ5->Z5_PESOINI 
    
	//VALIDAR ARMAZEM      tanto para a rotina de Inventário quanto para Enderecamento
	If SZ5->Z5_ALMOXA <> cArmazem  //Armazem diferente, Bloqueia para nao gerar desbalanceamento de saldo entre SB2 x SZ5
		VTAlert("Rolo "+cNumSer+" esta no armazem ("+SZ5->Z5_ALMOXA+") e nao no ("+cArmazem+")","ATENCAO",.T.,,3)
		cEtiqProd:= Space(48)
		FreeObj(oEtiq)
		FreeObj(oRolo)	
		Return .F.
	Endif
		
    //VALIDAR Cod. Produto tanto para a rotina de Inventário quanto para Enderecamento
	If SZ5->Z5_PROD <> cCodProd   //Produto difrente, Bloqueia para nao gerar desbalanceamento de saldo entre SB2 x SZ5
		VTAlert("Rolo "+cNumSer+" esta como prod. "+SZ5->Z5_PROD+" e nao "+cCodProd,"ATENCAO",.T.,,3)
		cEtiqProd:= Space(48)
		FreeObj(oEtiq)
		FreeObj(oRolo)	
		Return .F.
	Endif

	//VALIDAR OP   tanto para a rotina de Inventário quanto para Enderecamento
	IF !Empty(SZ5->Z5_OP)
		lC_OP:=Alltrim(SZ5->Z5_OP)
	    nTamOP:=Len(lC_OP)
		lTemLet:=.F.
		For a:=1 to nTamOP
			IF .Not. IsDigit(Substr(lC_OP,a,1))
		         lTemLet   := .T.
		         Exit
			Endif	 
		Next a
		
// Fernando 31/08/2018
//		If .Not. lTemLet    //Caso Tiver letra NAO valida OP, devido na etiqueta estara impresso 6 zeros "000000"

		If .Not. lTemLet  .AND. .NOT. lQRCODE_  //Caso Tiver letra NAO valida OP, devido na etiqueta estara impresso 6 zeros "000000"
		    //VALTER - ALTERADO CAMPO DA OP QUE VEM DA ETIQUETA
			//If SubStr(SZ5->Z5_OP,1,6) != cOp 
			If SubStr(SZ5->Z5_OP,1,6) != cOpEtiq 
				VTAlert("OP da Etiqueta é diferente do Sistema. Imprima nova Etiqueta.","ATENCAO",.T.,,3)
				cEtiqProd:= Space(48)
				FreeObj(oEtiq)
				FreeObj(oRolo)	
				Return .F.		
            Endif
		Endif
	Endif
Endif
//Fim...Denis 12/09/13


//VALIDAR SE JA FOI VENDIDO     tanto para a rotina de Inventário quanto para Enderecamento  
//Devido o pessoal da separacao estar reimprimindo etiquetas existentes e colando em rolos sem identificação. Já foi avisado para nao fazerem mais isso. 
//Denis 02/06/14
dbSelectArea("SZB")  //Rolos Vendidos
SZB->(dbSetOrder(2)) //ZB_FILIA+ZB_SERIE+ZB_ROLO
If SZB->(MsSeek(xFilial("SZB")+cNumSer))
	VTAlert("Rolo "+cNumSer+" ja vendido. Gerar novo RG e ler novamente","ATENCAO",.T.,,3)

	cOpc:=" "

	@ 5,0 VTSay "Erro na leitura!"
	@ 6,0 VTSay "Deseja Continuar? S/N"
	@ 7,0 VTGet cOpc Pict '!' Valid !Empty(cOpc) .and. cOpc $ "SN"
	VTRead
	@ 5,0 VTSay Space(20)
	@ 6,0 VTSay Space(20)
	@ 7,0 VTSay Space(10)

	If cOpc == "N"
		FreeObj(oEtiq)
		FreeObj(oRolo)	
		cEtiqProd:= Space(48)
		Return .F.
	Endif
	
Endif

If cOrig=="I"   //Inventario
	ZZ8->(dbSetOrder(1))
	//ZZ8->(MsSeek(xFilial("ZZ8")+cNumSer+cCodProd))  //Anulado por Denis em 06/07/13
	ZZ8->(MsSeek(xFilial("ZZ8")+cNumSer))  //Denis 06/07/13 -- Corrigido pois no inventario Julho/2013 deixou inventariar RG duplicado com produto diferente 
	Do While !ZZ8->(Eof())	.and. ZZ8->ZZ8_SERIE+ZZ8->ZZ8_NUMERO == cNumSer
		If ZZ8->(FieldPos("ZZ8_ORIG") >0 ) .And. ZZ8->ZZ8_ORIG <> 'I'
			ZZ8->( dbSkip() )
			Loop
		EndIf
		If ZZ8->ZZ8_INVENT == CBA->CBA_DATA
			VTAlert("Rolo "+cNumSer+" ja inventariado no endereço: "+ZZ8->ZZ8_ENDERE,"ATENCAO",.T.,,3)
			cEtiqProd:= Space(48)
			FreeObj(oEtiq)
			FreeObj(oRolo)	
			Return .F.
		Endif
		ZZ8->(dbSkip()) 	
	Enddo 
ElseIf cOrig $ "E,T" //Enderecamento  ou  Transferencia
	dbSelectArea("SZ5")
	SZ5->(dbSetOrder(2)) //Z5_FILIAL+Z5_SERIE+Z5_NUMERO+Z5_PROD
	SZ5->(MsSeek(xFilial("SZ5")+cNumSer))  //Denis 06/07/13 -- Validar somente RG do rolo
	If SZ5->(Found())
		
		If SZ5->Z5_PESOATU == 0
			VTAlert("Rolo com saldo zerado: "+cNumSer+" ("+DTOC(ZZ8->ZZ8_INVENT)+") ","ATENCAO",.T.,,3)
			cEtiqProd:= Space(48)
			FreeObj(oEtiq)
			FreeObj(oRolo)	
			Return .F.
        Endif

		If cOrig=="T" //Transferencia  ... Denis 15/07/16
			_cUser	:= c4KTRFPU //GetMv("MV_4KTRFPU") // usuario fazem transferencia mas so de punho para punho
			_cTrfUs	:= GetMv("MV_4KTRFUS") // usuarios que podem fazer transferencia
			If U_ChkAlcada("4KTRFPU", .F. ) .and. !Alltrim(Upper(Substr(cUserName,1,8))) $ Upper(Alltrim(_cTrfUs))
				VTAlert("Usuario nao autorizado a efetuar Transferencia","ATENCAO",.T.,,3)
				cEtiqProd:= Space(48)
				FreeObj(oEtiq)
				FreeObj(oRolo)	
				Return .F.
			Endif

			SB2->(dbSetOrder(1))
			SB2->(MsSeek(xFilial("SB2")+cCodProd+cArmazem))
			If SB2->(Found())
				If SB2->B2_QATU < nQuant
					VTAlert("Qtde. em Estoque menor que peso do rolo.","ATENCAO",.T.,,3)
					cEtiqProd:= Space(48)
					FreeObj(oEtiq)
					FreeObj(oRolo)	
					Return .F.
			    Endif
			Else
				VTAlert(cCodProd+" no Almox. Origem: "+cArmazem+" Nao existe no SB2","ATENCAO",.T.,,3)
				cEtiqProd:= Space(48)
				FreeObj(oEtiq)
				FreeObj(oRolo)	
				Return .F.
			Endif
		Endif

		If cOrig=="E" //Enderecamento
			If ALLTRIM(SZ5->Z5_ENDEREC) == Alltrim(cEndereco)
				VTAlert("Rolo "+cNumSer+" já endereçado no endereço: "+SZ5->Z5_ENDEREC,"ATENCAO",.T.,,3)
				cEtiqProd:= Space(48)
				FreeObj(oEtiq)
				FreeObj(oRolo)	
				Return .F.
	        Endif
		Endif

	Endif
Endif

If ( Asc(Substr(cNumSer,1,1)) < 65 .or. Asc(Substr(cNumSer,1,1)) > 90) .or.;
( Asc(Substr(cNumSer,2,1)) < 65 .or. Asc(Substr(cNumSer,2,1)) > 90).or.;
( Asc(Substr(cNumSer,3,1)) < 65 .or. Asc(Substr(cNumSer,3,1)) > 90).or.;
( Asc(Substr(cNumSer,4,1)) < 48 .or. Asc(Substr(cNumSer,4,1)) > 57).or.;
( Asc(Substr(cNumSer,5,1)) < 48 .or. Asc(Substr(cNumSer,5,1)) > 57).or.;
( Asc(Substr(cNumSer,6,1)) < 48 .or. Asc(Substr(cNumSer,6,1)) > 57).or.;
( Asc(Substr(cNumSer,7,1)) < 48 .or. Asc(Substr(cNumSer,7,1)) > 57)
	VTAlert("Caracter invalido no rolo: "+cNumSer,"ATENCAO",.T.,,3)
	cEtiqProd:= Space(48)
	FreeObj(oEtiq)
	FreeObj(oRolo)	
	Return .F.  
Endif

//Adam Diniz - 16/06/2014 - Gravacao dos campos de fornecedor na ZZ8
aadd(aRolos,{cCodProd,nQuant,cLote,dDtVal,cNumSer,cOp,cPartida,cRoman,clFornece,clLojaFor,cNotaFi,nPesoIni})
FreeObj(oEtiq)
FreeObj(oRolo)	
cEtiqProd:= Space(48)
Return .T.

/*
	Function: CBVLDNS
		Valida numero de serie
	
	Autor:
		Marcio Barretos - 30/06/12

*/
User Function CBVLDNS()

If FwCodEmp() <> "07"
	VTAlert("Numero Serie","Aviso",.T.,,3) //"Numero de Serie invalido"###"Aviso"
EndIf

Return .T.

User Function CBINV01()

    Local _cEtiqNew := ''
    Local _cEtiq	:= PARAMIXB[3]
    Local _cSerie	:= " "
    Local _cRolo	:= " "

	If FwCodEmp() <> "07"

		//VTAlert("CBINV01: "+_cEtiq,"Aviso",.T.,,3)
		_cEtiqNew := _cEtiq

	Else

		If SubStr(_cEtiq,1,2) == "QR"

            _cSerie := Substr(_cEtiq,3,3)
            _cRolo  := Substr(_cEtiq,6,Len(_cEtiq))

            _cEtiqNew := _cSerie + _cRolo

		Else

            _cEtiqNew := _cEtiq //Faz a validação/ alteração de etiqueta necessária

        EndIF

	EndIf

Return _cEtiqNew           

User Function CBINV04

If FwCodEmp() <> "07"
//	VTAlert("CBINV04: "+cProduto,"Aviso",.T.,,3)
EndIf

Return .T.   


/*
	Function: VldCodInv
		Valida numero de serie

	Autor:


*/
Static Function QkVCInv(cCodInv,lAlert)
Local lRetorno
Local lV035VLDM :=ExistBlock("V035VLDM")
Local cUltCont
Local aCBC:={}
Local nX,nY
Default lAlert:= .t.
If Empty(cCodInv)
	VtKeyBoard(chr(23))
	Return .f.
EndIf
CBA->(DbSetOrder(1))
If ! CBA->(MsSeek(xFilial('CBA')+cCodInv))
	VTBeep(3)
	VTAlert('Codigo mestre de inventario nao cadastrado','Atencao',.t.,,3) 
	VTKeyBoard(chr(20))
	Return .f.
EndIf
If CBA->CBA_STATUS$"4-5" // 4=Finalizado / 5=Processado
	VTBeep(3)
	VTAlert('Inventario finalizado','Atencao',.t.,,3) 
	VTKeyBoard(chr(20))
	Return .f.
EndIf
If (CB1->CB1_INVPVC<>"1")// mesmo operador executar o mesmo inventario
	CBB->(dbSetOrder(2))
	If CBB->(MsSeek(xFilial('CBB')+"2"+cCodOpe+CBA->CBA_CODINV ))
		VTBeep(3)
		VTAlert("Operador ja realizou contagem para o inventario","Sem permissao",.t.,,3) 
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
EndIf
If DTOS(CBA->CBA_DATA)#DTOS(dDataBase)
	VTAlert('Data do "Mestre de Inventario" deve ser igual a "Data Base" do sistema!',"Aviso",.t.,,3)
	VTAlert("So sera possivel executar este Mestre de Inventario na data -> "+DTOC(CBA->CBA_DATA)+" <-","Aviso",.t.,3) 
	VTKeyBoard(chr(20))
	Return .f.
EndIf
If CBA->CBA_CONTS == 1
	CBB->(DbSetOrder(1))
	If CBB->(MsSeek(xFilial('CBB')+CBA->CBA_CODINV )) .and. CBB->CBB_USU # cCodOpe
		VTBeep(3)
		VTAlert("Somente o Operador "+CBB->CBB_USU+" pode dar continuidade a este inventario","Contagens == 1",.t.,,3)  
		VTKeyBoard(chr(20))
		Return .f.
	Endif
Endif
CBB->(DbSetOrder(2))
If CBB->(MsSeek(xFilial('CBB')+"1"+cCodOpe+CBA->CBA_CODINV ))
	If ! CBB->(RLock())
		VTBeep(3)
		VTAlert('Operador executando inventario em outro terminal','Atencao',.t.,,3) 
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	CBB->(DBUnLock())
	Reclock("CBB",.f.)
Else
	cUltCont:=Space(6)
	If ! lModelo1 // se for modelo 2 tem que verificar se tem autorizacao
		If CBA->CBA_AUTREC=="2" // BLOQUEADO
			VTBeep(3)
			VTAlert('Atencao',"Inventario bloqueado para auditoria",.t.,,3) 
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		cUltCont := CBUltCont(CBA->CBA_CODINV)
	EndIf
	Reclock("CBB",.T.)
	CBB->CBB_FILIAL := xFilial("CBB")
	CBB->CBB_NUM    := CBProxCod('MV_USUINV')
	CBB->CBB_CODINV := CBA->CBA_CODINV
	CBB->CBB_USU    := cCodOpe
	// CBB_NCONT  := nCont   // verificar necessidade
	CBB->CBB_STATUS := "1"
	CBB->(MsUnlock())
	Reclock("CBB",.F.)

	//-- transpor as contagens batidas para este usuario
	If ! lModelo1 .and. ! Empty(cUltCont)
		CBC->(DbSetOrder(1))
		CBC->(MsSeek(xFilial('CBC')+cUltCont))
		While CBC->(!Eof() .and. xFilial('CBC')+cUltCont == CBC_FILIAL+CBC_NUM)
			If CBC->CBC_CONTOK=="1"
				aadd(aCBC,array(CBC->(FCount())))
				For nX:= 1 to CBC->(FCount())
					aCBC[len(aCBC),nX] := CBC->(FieldGet(nX))
				Next
			EndIf
			CBC->(DbSkip())
		End
		For nX:= 1 to len(aCBC)
			Reclock("CBC",.t.)
			For nY := 1 to CBC->(FCount())
				If CBC->(FieldName(nY)) == "CBC_CODINV"
					CBC->CBC_CODINV    := CBB->CBB_CODINV
				ElseIf CBC->(FieldName(nY)) == "CBC_NUM"
					CBC->CBC_NUM    := CBB->CBB_NUM
				Else
					CBC->(FieldPut(nY,aCBC[nX,nY]))
				EndIf
			Next
			CBC->(MsUnLock())
		Next
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Analisando Classificacao por curva ABC                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cClasses := ""
If CBA->CBA_CLASSA=="1"
	cClasses+="A"
EndIf
If CBA->CBA_CLASSB=="1"
	cClasses+="B"
EndIf
If CBA->CBA_CLASSC=="1"
	cClasses+="C"
EndIf

//CBLoadEst(aProdEnd,.F.)
If CBA->CBA_STATUS=='0'
	IniciaCBM(aProdEnd)
EndIf
RecLock("CBA",.f.)
If ! lModelo1 // se for modelo 2 tem que verificar se tem autorizacao
	CBA->CBA_AUTREC:="2" // BLOQUEADO
EndIf
CBA->CBA_STATUS := "1"  // 1=Em andamento
CBA->(MsUnlock())

If lV035VLDM
	   lRetorno := ExecBlock("V035VLDM",.F.,.F.)
	   lRetorno := If(ValType(lRetorno)=="L",lRetorno,.T.)
	   VTKeyBoard(chr(20))
	   If !lRetorno
	      Return .F.
	   Endif
Endif

If CBA->CBA_TIPINV =="2" .and. lAlert
	VTAlert("Va para o Armazem "+CBA->CBA_LOCAL+" Endereco "+CBA->CBA_LOCALI,"Aviso",.t.,,3)
EndIf
Return .t.  

/*
	Function: qkNewEnd()
		Nova rotina de Enderecamento
	
	Autor:                                                                             
		Marcio Barretos
		
*/			
User Function qkNewEnd()

Local aTela

Private cArmazem	:= Space(02)
Private cEndereco
Private cEtiqend
Private cProduto
Private cEtiqProd
Private nQtdEtiq
Private cClasses 	:= ""
Private cCodOpe  	:=CBRetOpe()
Private aProdEnd	:={}
Private lMsErroAuto	:= .F.
Private lUsaCB001 	:=UsaCB0("01")
Private lUsaCB002 	:=UsaCB0("02")
Private lModelo1  	:=GetMv("MV_CBINVMD")=="1"
Private lForcaQtd 	:=GetMV("MV_CBFCQTD",,"2") =="1"
Private aRolos		:= {}
Private nRolos      := 0
Private nRecRol     := 0

If Empty(cCodOpe)
	VTAlert("Operador nao cadastrado","Aviso",.T.,,3) 
	Return .F.
EndIf

aTela := VtSave()
VTCLear()
@ 0,0 VTSAY "--ENDERECAMENTO--"
@ 2,0 VTSay "Armazem:"
@ 3,0 VTGet cArmazem Pict '@!' Valid Len(Alltrim(cArmazem))== 2
Vtread

If VtLastkey() == 27
	VTClear
	Return
EndIf  


Do While .t.
	cEndereco:= Space(15)

		VTCLear()
		@ 0,0 VTSAY "--ENDERECAMENTO--"
		@ 2,0 VTSay "Endereco:"
//		@ 3,0 VTGet cEndereco Pict '@!' Valid !Empty(cEndereco)
		@ 3,0 VTGet cEndereco Pict '@!' Valid VldEnd(cArmazem,@cEndereco)

		Vtread

	If VtLastkey() == 27
		VTClear
		Return
	EndIf  
	
		cEtiqProd:= Space(48)

	While .T.

		VTClear
		
		cEtiqend := Space(48)
		cProduto := Space(15)
		aRolos   := {}                             
		
		@ 0,0 VTSAY "--ENDERECAMENTO--"		
		@ 1,0 VTSay "Armazem:" + cArmazem
		@ 2,0 VTSay "Endereco:" + cEndereco
		@ 3,0 VTSay "Rolos Lidos:" + Str(nRolos)

		cEtiqProd:= Space(48)
			
		@ 5,0 VTSay "Rolo: "
		@ 6,0 VTGet cEtiqProd pict "@!" Valid VTLastkey() == 5  .or. QkVERolo("E",cEndereco)
		VTRead

			If VtLastkey() == 27
				VTClear
				Return
			EndIf
	
		SZ5->(dbGoTo(nRecRol))
		RecLock("SZ5",.F.)
		SZ5->Z5_ENDEREC  := cEndereco
		SZ5->Z5_4KDTEND  := Date()   //Data do Enderacamento já existia ha 2 anos, porem nao estava sendo utilizado. Colocado p/ Gravar em 18/11/14 por Denis
        SZ5->Z5_USENDER  := cUserName  //Usuario que enderecou, criado por Denis  em 14/12/15
		msUnlock()
		++nRolos
	End
End
Return


/*
=========================================================================================
Funcao    -> QtdRolEnd           Autor->Denis                        Data -> 07/06/16
-----------------------------------------------------------------------------------------
Descricao ->  Retorna a Quantidade de Rolos Lidos no Endereco do Inventario
=========================================================================================
*/
*---------------------------------*
Static Function QtdRolEnd(cOrig)
*---------------------------------*

Local lC_Query:=" "
Local nQRE:=0

lC_Query := " SELECT COUNT(*) QTROEN FROM " + RetSqlName("ZZ8")  + " ZZ8"
lC_Query += " WHERE ZZ8.ZZ8_FILIAL='" + xFilial("ZZ8") + "'"
lC_Query += " AND ZZ8.D_E_L_E_T_ = ' '"
lC_Query += " AND RTRIM(ZZ8.ZZ8_ENDERE) = '"+Alltrim(cEndereco)+"'"
	If cOrig == "I"
		lC_Query += " AND ZZ8.ZZ8_INVENT = '"+DTOS(CBA->CBA_DATA)+"'"
	EndIf
	lC_Query += " AND ZZ8.ZZ8_ORIG   = '"+cOrig+"'"	
TcQuery lC_Query Alias TZZ8 New
nQRE:= TZZ8->QTROEN
TZZ8->(DbCloseArea())

Return nQRE

	/*
	=========================================================================================
	Funcao    -> QkTrsfRol           Autor->Denis Soares da Silva          Data -> 13/07/16
	-----------------------------------------------------------------------------------------
	Descricao ->  Transferencia de rolos entre almoxarifados
	=========================================================================================
	*/
*---------------------------------*
User Function qkTrsfRol()
*---------------------------------*

Private cArmazem	:= Space(02)
Private cArmDest	:= Space(02)
Private nRecRol     := 0
Private cCodOpe  	:= CBRetOpe()
Private cEtiqProd


If Empty(cCodOpe)   //Se o Cod. de Usuario logado nao estiver cadastrado na Tabela "CB1"
	VTAlert("Operador nao cadastrado","Aviso",.T.,,3)
	Return .F.
EndIf

aTela := VtSave()
VTCLear()

While .T.

	@ 0,0 VTSAY "--TRANSFERENCIA--"
	@ 1,0 VTSay "Almox. Origem:"
	@ 2,0 VTGet cArmazem Pict '@!' Valid cArmazem<>"98"
	VTRead
	If VtLastkey() == 27 .or. Empty(cArmazem) .or. Len(Alltrim(cArmazem))<> 2
		VTClear
		Exit
	EndIf
	If !cArmazem$"01,20,21,92,93,94,95,96,97"
		VTAlert("Almox. Invaliddo","ATENCAO",.T.,,3)
		cArmazem:= Space(02)
		Loop
	Endif

	@ 3,0 VTSay 'Almox. Destino:'
	@ 4,0 VTGet cArmDest Pict '@!'  Valid cArmazem<>"98"
	VTRead
	If VtLastkey() == 27 .or. Empty(cArmDest) .or. Len(Alltrim(cArmDest))<> 2
		VTClear
		Exit
	EndIf
	If !cArmDest$"01,20,21,92,93,94,95,96,97"
		VTAlert("Almox. Invaliddo","ATENCAO",.T.,,3)
		cArmDest:= Space(02)
		Loop
	Endif


	While .T.

		cEtiqProd:= Space(48)

		@ 5,0 VTSay "Rolo"
		@ 6,0 VTGet cEtiqProd pict "@!" Valid VTLastkey()==5 .or. VtLastkey()==27 .or. QkVERolo("T"," ")
		VTRead

		If VTLastkey()==5 .or. VtLastkey() == 27
			VTClear
			Exit
		EndIf

        	    //P.Orig ,Arm.Orig ,Q.Orig, P.Dest ,Arm.Dest,Q.Dest
		u_QkTrsf(cCodProd,cArmazem,nQuant,cCodProd,cArmDest,nQuant)  //Executa a Transferencia gerando movimento no SD3

		SZ5->(dbGoTo(nRecRol))
		RecLock("SZ5",.F.)
		SZ5->Z5_ALMOXA := cArmDestaRolos
		msUnlock()

	End

End

Return

Static Function grvZZ8(cOrig)

	RecLock("ZZ8",.T.)
	ZZ8->ZZ8_FILIAL  := xFilial("ZZ8")
	ZZ8->ZZ8_ROMAN   := aRolos[Len(aRolos),8]   //Substituido "INVENT" ... Denis 07/06/14
	ZZ8->ZZ8_OP      := aRolos[Len(aRolos),6]
	ZZ8->ZZ8_PARTIDA := aRolos[Len(aRolos),7]
	ZZ8->ZZ8_PROD    := aRolos[Len(aRolos),1]
	ZZ8->ZZ8_ALMOXA  := cArmazem
	ZZ8->ZZ8_NFISCA   := aRolos[Len(aRolos),11]
	If cOrig == "I"
		ZZ8->ZZ8_DTENT   := CBA->CBA_DATA
	Else
		ZZ8->ZZ8_DTENT   := dDatabase
	EndIf
	ZZ8->ZZ8_NUMERO  := Substr(aRolos[Len(aRolos),5],4,4)
	ZZ8->ZZ8_SERIE   := Substr(aRolos[Len(aRolos),5],1,3)
	ZZ8->ZZ8_DOCCQ   := " "
	ZZ8->ZZ8_SEQCQ   := " "
	ZZ8->ZZ8_PRODTR  := " "
	If cOrig == "I"
		ZZ8->ZZ8_INVENT  := CBA->CBA_DATA
	EndIf
	ZZ8->ZZ8_PESOAT  := aRolos[Len(aRolos),2]
	ZZ8->ZZ8_PESOIN  := aRolos[Len(aRolos),12]
	ZZ8->ZZ8_ENDERE  := Alltrim(cEndereco)
	ZZ8->ZZ8_FLAG    := .T.                        //Denis 17/04/13
	ZZ8->ZZ8_FORNEN  := aRolos[Len(aRolos),9] //Adam Diniz - 16/06/2014 - Gravacao dos campos de fornecedor na ZZ8
	ZZ8->ZZ8_LOJAFO  := aRolos[Len(aRolos),10]//Adam Diniz - 16/06/2014 - Gravacao dos campos de fornecedor na ZZ8
	ZZ8->ZZ8_ORIG    := cOrig
	//ZZ8->ZZ8_LOTECTL := Substr(aRolos[1,6],1,6) + Strzero(Val(right(aRolos[1,7],4)))
	msUnlock() 
				
Return

Static Function checkZZ8(cLocal)
	Local cAliasQry := getNextAlias()

	BeginSql alias cAliasQry 
		SELECT ZZ8_ENDERE
		FROM %table:ZZ8% ZZ8
		WHERE ZZ8_FILIAL = %xFilial:ZZ8% AND
		ZZ8_PROD    = %Exp:aRolos[Len(aRolos),1]%  AND
		ZZ8_OP      = %Exp:aRolos[Len(aRolos),6]%  AND
		ZZ8_PARTID  = %Exp:aRolos[Len(aRolos),7]%  AND
		ZZ8_ALMOXA  = %Exp:cLocal%       AND
		ZZ8_ORIG    = 'E' AND 
		ZZ8.%notdel%
		//aadd(aRolos,{cCodProd,nQuant,cLote,dDtVal,cNumSer,cOp,cPartida,cRoman,clFornece,clLojaFor})		
	EndSql 
	
	If (cAliasQry)->(!Eof())
		VTAlert("Rolo " + aRolos[Len(aRolos),6] + " ja enderecado no endereco " + (cAliasQry)->ZZ8_ENDERE,"Aviso",.T.,,3)
		Return .F. 
	EndIf

Return .T.

Static Function checkZZ5(cEnde,cLocal)
	Local cAliasQry := getNextAlias()
	Local nCount := 0 

	BeginSql alias cAliasQry 
		SELECT 1    
		FROM %table:SZ5% SZ5
		WHERE Z5_FILIAL = %xFilial:SZ5% AND
		Z5_ENDEREC  = %Exp:cEnde%       AND
		Z5_ALMOXA   = %Exp:cLocal%      AND
		SZ5.%notdel%		
	EndSql 
	
	Do While (cAliasQry)->(!Eof())
		++nCount
		(cAliasQry)->(dbSkip())
	EndDo

Return nCount

// ----------------------------------------------------------------------------------------- //
// Consulta teste para leitura de codigo de barras e DataMatrix
// 05/08/2021 Criado por Fernando
// ----------------------------------------------------------------------------------------- //

User Function qkTstEtiq()
aTela := VtSave()
VTCLear()

// VTAlert("Teste leitura etiqueta","ATENCAO",.T.,4000)
SZ5->(dbSetOrder(2))
While .T.

	cEtiqProd:= Space(55)  // Quantidade maxima de caracteres do codigo d barras: EAN128 / Datamatrix ou QRCode

	cCodProd := " "
	cNumSer  := " "
	cOp      := " "
	cPartida := " "
	nQuant	:= 0
	cOpc	:= " "
	cRG		:= space(7)
	cEndereco:= space(15)

	VTCLear()
	VTCLEARBUFFER()

	@ 1,0 VTSay "Codigo:"
	@ 2,0 VTGet cEtiqProd pict "@!" 
	VTRead()

	If VTLastkey()==5 .or. VtLastkey() == 27 
		VTClear()
		VTAlert("Saindo da função","...",.T.,,3)
		VTAlert("Saindo da função","...",.T.,,3)
		Exit
	EndIf

	If !oEtiq:gotError()
		oRolo := oEtiq:lerEtiqueta(cEtiqProd)

		If oEtiq:trazTipo() == "QR" 
			VTAlert("Rotina " + oEtiq:trazTipo() ,"." + oEtiq:trazNumSer() + ".",.T.,,3)
				VTCLear()
				@ 0,1 VTSAY "QRCode C-" + str(len(cEtiqProd),2,0)
		Elseif  oEtiq:trazTipo() == "Tinturaria"
			VTAlert("Caracteres: " + str(len(cEtiqProd)),".Rotina Tint 8-1.",.T.,,3)
				VTCLear()
				@ 0,1 VTSAY "Tintura C-" + str(len(cEtiqProd),2,0)
		Elseif  oEtiq:trazTipo() == "Protheus"
			VTAlert("Caracteres: " + str(len(cEtiqProd),3,0),".Rotina P 01.",.T.,,3)
			VTCLear()
			@ 0,1 VTSAY "Protheus C-" + str(len(cEtiqProd),2,0) 
		EndIf

		@ 1,1 VTSAY "Prod " + oRolo:trazCodProd()
		@ 2,1 VTSAY "RG  " 	+ oRolo:trazRg() + " " + oRolo:trazNumSer()
		@ 3,1 VTSAY "Peso " + oRolo:trazQuant()
		@ 4,1 VTSAY "OP   " + oRolo:trazOp()
		@ 5,1 VTSAY "Part " + oRolo:trazPartida()
		@ 6,1 VTSAY "Ender " + oRolo:trazEndereco()
		@ 0,16 VTSay "Wait."
		@ 0,21 VTGet cOpc Pict '!' 
		Vtread()
		loop

	Else
		VTAlert( oEtiq:getLastError() ,"AVISO",.T.,,3)
		loop
	Endif
End

Return


/*
Function: VldEnder
Valida a leitura da etiqueta de Endereco

Autor:
Denis Soares da Silva - 07/06/16

*/
User Function QkVerEnd()

Local cEndereco
Local nCount     := 0
Local cAliasQry  := getNextAlias()
Local oExplorer  := fileManagement():New()	
Local oFileLog   := fileSerasa():New()

Do While .t.
	cEndereco:= Space(15)

	VTCLear()
	@ 0,0 VTSAY "--ENDERECAMENTO--"
    @ 2,0 VTSay "Endereco:"
	@ 3,0 VTGet cEndereco Pict '@!' Valid !Empty(cEndereco)
	Vtread

	If VtLastkey() == 27
		VTClear
		Return
	EndIf  
		
	BeginSql alias cAliasQry 
		SELECT Z5_ALMOXA,Z5_NUMERO, Z5_SERIE, Z5_PESOATU 
		FROM %table:SZ5% SZ5
		WHERE Z5_FILIAL = %xFilial:SZ5% AND
		Z5_ENDEREC  = %Exp:cEndereco%   AND
		SZ5.%notdel%		
	EndSql 
	If (cAliasQry)->(!Eof())
		AutoGRLog(" ROLOS      PESO   ALM.")
	
		Do While (cAliasQry)->(!Eof())
			AutoGRLog( (cAliasQry)->( Z5_SERIE + " " + Z5_NUMERO ) + "     " + AllTrim(TRANSFORM( (cAliasQry)->( Z5_PESOATU ) ,"@E 99.99"))+ "    " + (cAliasQry)->( Z5_ALMOXA )   )
			(cAliasQry)->(dbSkip())
			nCount++ 
		EndDo
		AutoGRLog("Qtd Rolos: " + allTrim(str(nCount)) )

		VTDispFile(NomeAutoLog(),.t.)
		oFileLog:setName( NomeAutoLog() )
		oExplorer:deleteFile( oFileLog )

	EndIf
	(cAliasQry)->( dbcloseArea() )
	nCount := 0
End
FreeObj(oFileLog)
FreeObj(oExplorer)

Return

User Function qktstEtq()
	Private cEtiqProd  := "0181656614451000009063800010024101048710000021"

	@ 6,0 VTSay "Rolo"
	@ 7,0 VTGet cEtiqProd pict "@!" Valid VTLastkey() == 5  .or. QkVERolo("I"," ")
	VTRead

Return 

Static Function VldEnd(cArmazem,cEndereco)

	If FwCodEmp() <> "07"

		If Empty(cEndereco)
        	Return .F.
		EndIf

	Else
	
		dbSelectArea("SBE")
		SBE->(dbSetOrder(1))
		SBE->(dbGoTop())
		If !SBE->( dbSeek( xFilial("SBE") + cArmazem + cEndereco ) )
			VTBeep(3)
        	VTAlert("Endereço não possui cadastro.","Aviso",.T.,4000)
			cEndereco:= Space(15)
        	Return .F.
		EndIf

	EndIf

Return .T.
