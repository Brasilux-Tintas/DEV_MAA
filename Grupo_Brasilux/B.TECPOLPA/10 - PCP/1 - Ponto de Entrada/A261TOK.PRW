#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#include "totvs.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"
//Dyego Figueiredo / Chaus
//Ponto de entrada para  incluir a transferencia do Pallet
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function A261TOK
     Local lRet := .T.
     // verifica se foi inclui os pallets, se nao foi, inclui

     If FWCodEmp() = '11' //Empresas que são do grupo 11(Tecpolpa).
        qtdPallets := CheckPalle()
        If qtdPallets > 0
           IncPallet(qtdPallets)
           MsgAlert("Pallet incluso", "A261TOK.PRW")
        Elseif qtdPallets < 0
               lRet := .F.
        Endif
     Endif
Return lRet

//retorna a quantidade de pallets a incluir
//se o Pallet nao tiver sido inserido e se o produto inserido por PA/TA
Static Function CheckPalle()

Local nRet 			:= 0
Local cCodPallet 	:= GETMV("MV_XCODPLT")
Local posD3COD 		:= GdFieldPos("D3_COD",	aHeader)
Local posD3QUANT 	:= GdFieldPos("D3_QUANT", aHeader)

Local posD3OLOCAL 	:= aScan(aHeader,{|x| Alltrim(x[1])=="Armazem Orig."})
Local posD3DLOCAL 	:= aScan(aHeader,{|x| Alltrim(x[1])=="Armazem Destino"})

Local cArmOrigem 	:= GetMv("MV_XAROPLT")
Local cArmDestin 	:= GetMv("MV_XARDPLT")

Local i 			:= 0

For i := 1 to Len(aCols)

	_cCodProd	:=  aCols[i, posD3COD]
	_nQuant		:=  aCols[i, posD3QUANT]

 	If  ! aCols[i][len(aHeader)+1] .and. Alltrim(aCols[i, posD3COD]) == Alltrim(cCodPallet)
		 Return 0
	Endif

	If  Posicione("SB1",1,xFilial("SB1")+_cCodProd,"B1_TIPO") $ "PA/TA" .AND.  ;
		 Alltrim(aCols[i, posD3OLOCAL]) == Alltrim(cArmOrigem) .AND.   Alltrim(aCols[i, posD3DLOCAL]) == Alltrim(cArmDestin)

		Dbselectarea("SB5")
		SB5->(dbSetorder(1))
		If !SB5->(dbSeek(xFilial("SB5")+_cCodProd))
			MsgAlert("O complemento do produto não foi cadastrado, código do produto: " + _cCodProd, "A261TOK.PRW")
			Return -1
		Endif

		If SB5->B5_EMPMAX*SB5->B5_ECPROFU == 0
			MsgAlert("O complemento do produto foi cadastrado incorretamente, o lastro não pode ser zero, código do produto: " + _cCodProd, "A261TOK.PRW")
			Return -1
		Endif

		nRet  +=  Ceiling(  _nQuant / (SB5->B5_EMPMAX*SB5->B5_ECPROFU) )
	Endif

Next i

Return nRet


Static Function IncPallet(qtdPallets)

Local cCodPallet 	:= GETMV("MV_XCODPLT")
Local cArmOrigem 	:= GetMv("MV_XAROPLT")
Local cArmDestin 	:= GetMv("MV_XARDPLT")

SB1->(dbSetorder(1))
	If !SB1->(dbSeek(xFilial("SB1")+cCodPallet))
		MsgAlert("Produto do Pallet não localizado, código: " + cCodPallet, "A261TOK.PRW")

		Return
Endif

	aAux:={}
	aAux:=aclone(acols[1])

	dValid := dDatabase+SB1->B1_PRVALID


	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Prod.Orig."})] 		:= SB1->B1_COD //1
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Desc.Orig."})] 		:= SB1->B1_DESC //2
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="UM Orig."})] 		:= SB1->B1_UM //3
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Armazem Orig."})] 	:= cArmOrigem //4
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Endereco Orig."})] 	:= "" //5
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Prod.Destino"})] 	:= SB1->B1_COD //6
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Desc.Destino"})] 	:= SB1->B1_DESC //7
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="UM Destino"})] 		:= SB1->B1_UM //8
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Armazem Destino"})] := cArmDestin //9
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Endereco Destino"})]:= "" //10
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Numero Serie"})] 	:= "" //11
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Lote"})] 			:= "" //12
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Sub-Lote"})] 		:= "" //13
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Validade"})] 		:= dValid //14
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Potencia"})] 		:= 0 //15
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Quantidade"})] 		:= qtdPallets //16
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Qt 2aUM"})] 		:= 0 //17
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Estornado"})] 		:= "" //18
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Sequencia"})] 		:= "" //19
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Lote Destino"})] 	:= "" //20
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Validade Destino"})]:= dValid //21
	aAux[aScan(aHeader,{|x| Alltrim(x[1])=="Item Grade"})] 		:= "" //22


	Aadd(acols,aAux)



	//RestArea(_aArea)
	SysRefresh()
	GETDREFRESH()



Return


