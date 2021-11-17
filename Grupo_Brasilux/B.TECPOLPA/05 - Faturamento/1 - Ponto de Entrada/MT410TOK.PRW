#include "TOPCONN.CH"
#include "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

//Dyego Figueredo
//Valida pedido de venda
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MT410TOK()
     Local lRet      := .T.
     Local temPallet := .F.
     Local lBoleto,_cGrpEmp
	_cGrpEmp := alltrim(FWGrpCompany())


     If _cGrpEmp == '11' //Empresas que são do grupo 11(Tecpolpa).
        lBoleto   := GETMV("MV_XIMPBOL")
		//Cleber(03/08/21)-> Não executar pergunta de inclusão de pallet caso estiver em rotina automática
		If (ValAtrib("l410Auto") <> "U" .and. l410Auto) //release 12.1.25 if ( Type("l410Auto") <> "U" .And. l410Auto )
			FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', "Inclusao Via SigaAuto, nao perguntar sobre inclusao de pallet...", 0 )
		else

	        temPallet := validaPall()
    	    If !temPallet
        	   	If MSGYESNO( "Deseja incluir os Paletes? ", "MT410TOK" ) // MSG
            	  u_INCPALLET()
           		Endif
        	Endif
			If GETMV("MV_XHTESPV")
				lRet :=  validaTES()
			Endif
		endif
        If lBoleto
           GerBol()
        Endif
     Endif
Return lRet



// VERIFICA SE TEM PALLETS NO PEDIDO DE VENDA
Static Function validaPall()

	Local _lRet := .F.
	Local _aArea := GetArea()
	Local pCodPro:= aScan(aHeader,{|x| Alltrim(x[2]) == "C6_PRODUTO"})
	//Local cCodPallet 	:= GETMV("MV_XCODPLT") 	// "1AAACFPPFE14"
	Local i := 0

	If M->C5_TIPO = "N"

		For i:= 1 to len(aCols)

			If  aCols[i][len(aHeader)+1]
				loop
			Endif


			_descPro := SUBSTRING(Posicione( "SB1", 1, xFILIAL("SB1")+aCols[i, pCodPro] ,"B1_DESC" ), 1,6)
			If  _descPro == "PALETE" //aCols[i, pCodPro] == cCodPallet
				_lRet := .T.
			Endif



		Next
	EndIf
	RestArea(_aArea)

Return(_lRet)




// VERIFICA SE O ITEM DO TA TEM SALDO INVENTARIADO E OBRIGA A TES SER TES Q NAO ATUALIZA SALDO DE TERCEIROS
Static Function validaTES()

	Local _lRet 	:= .T.
	Local _aArea 	:= GetArea()
	Local pCodPro	:= aScan(aHeader,{|x| Alltrim(x[2]) == "C6_PRODUTO"})
	Local pCodTES	:= aScan(aHeader,{|x| Alltrim(x[2]) == "C6_TES"})
	Local pCodLocal	:= aScan(aHeader,{|x| Alltrim(x[2]) == "C6_LOCAL"})
	Local pCodLote	:= aScan(aHeader,{|x| Alltrim(x[2]) == "C6_LOTECTL"})
    Local _cMVXTESIN:= getMV("MV_XTESINV")  //LGS#20200207 - Adequação de release 12.1.25 e posteriores
	Local pCodItem	:= aScan(aHeader,{|x| Alltrim(x[2]) == "C6_ITEM"})

	// TA tem saldo inventariado
	Local temRegra := .F.

	Local i := 0



	If M->C5_TIPO = "N"

		For i:= 1 to len(aCols)

			If  aCols[i][len(aHeader)+1]
				loop
			Endif



			_cProd 	:= aCols[i, pCodPro]
			_cLocal := aCols[i, pCodLocal]
			_cLote 	:= aCols[i, pCodLote]
			_cTes 	:= aCols[i, pCodTES]

			If Posicione("SB1",1,XfILIAL("SB1")+(_cProd),"B1_TIPO") $ "TA"

				dbSelectArea("SB8")
				SB8->(dbSetOrder(3)) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL
				If SB8->(dbSeek(xFilial("SB8")+_cProd+_cLocal+_cLote))

					IF SB8->B8_ORIGLAN $ "MN"

			 		// AS TES DAS MPS DEVEM SER  525
			 		  temRegra := .T.
			 		  exit

					Endif
				Endif
			Endif
		Next
	EndIf

	If M->C5_TIPO = "N" .AND. temRegra

		For i:= 1 to len(aCols)

			If  aCols[i][len(aHeader)+1]
				loop
			Endif

			_cProd 	:= aCols[i, pCodPro]
			_cLocal := aCols[i, pCodLocal]
			_cLote 	:= aCols[i, pCodLote]
			_cTes 	:= aCols[i, pCodTES]
			_cItem 	:= aCols[i, pCodItem]

			//NAO VALIDA PRODUTOS DA TECPOLPA
			//LGS#20200207 - Adequação de release 12.1.25 e posteriores
			//If SUBSTR(_cProd, 1,4) !=  "1AAA" .AND.  Posicione("SB1",1,XfILIAL("SB1")+(_cProd),"B1_TIPO") $ "TE/TM" .AND. !(_cTes $ getMV("MV_XTESINV"))
			If SUBSTR(_cProd, 1,4) !=  "1AAA" .AND.  Posicione("SB1",1,XfILIAL("SB1")+(_cProd),"B1_TIPO") $ "TE/TM" .AND. !(_cTes $ _cMVXTESIN )
				_lRet := .F.
				//LGS#20200207 - Adequação de release 12.1.25 e posteriores
				//Aviso("MT410TOK.PRW","Item "+_cItem+" .Como o saldo do item do TA foi inventariado, a TES da MPs deve ser a (MV_XTESINV:"+ getMV("MV_XTESINV") +") . Favor corrigir.",{"OK"})
				Aviso("MT410TOK.PRW","Item "+_cItem+" .Como o saldo do item do TA foi inventariado, a TES da MPs deve ser a (MV_XTESINV:"+ _cMVXTESIN +") . Favor corrigir.",{"OK"})
				exit
			Endif


		Next
	EndIf



	RestArea(_aArea)

Return(_lRet)



Static Function GerBol()

Local lTer          :=.T.
Local cBoleto		:=.F.
Local aArea			:=GetArea()
Local cTes			:= ""
Local i := 0

If !(IsInCallStack("A410Inclui").OR.IsInCallStack("A410Altera").OR.IsInCallStack("A410Copia"))
	Return(lTer)
EndIf


If lBoleto = .F.
	Return(lTer)
Endif

//Alteração por Igor Manrique, caso for marcado manualmente irá ignorar as outras validações
If M->C5_XBOLETO == .T.
	Return(lTer)
Endif


For i := 1 to Len(aCols)
 	cTes	:= aCols[i, GdFieldPos("C6_TES",aHeader)]
Next i

dbSelectArea("SF4")
SF4->(dbSetOrder(1))
SF4->(dbSeek(SF4->F4_FILIAL+cTES))

If SF4->F4_DUPLIC == "N"
	Return(lTer)
Endif



cQLinha :=  Chr(13) + Chr(10)

cQuery1 := "SELECT A1_XBOLETO FROM "+ RETSQLNAME("SA1") +cQLinha
cQuery1 += "WHERE A1_COD = '"+M->C5_CLIENTE+"' AND D_E_L_E_T_ = ' '"


IIF(Select("TMPQUERY")!= 0, TMPQUERY->(DbCLoseArea()), )

TCQUERY cQuery1 ALIAS TMPQUERY NEW
dbSelectArea("TMPQUERY")

If TMPQUERY->(EOF())
   //LGS#20200207 - Adequação de release 12.1.25 e posteriores
   //ConOut("A Query nao retorou dados")
   FwLogMSG( "ERROR", , 'SIGAFAT', funname(), '', '01', "A Query nao retorou dados", 0 )
Endif

While !TMPQUERY->(EOF())

	cBoleto := TMPQUERY->A1_XBOLETO
	dbSkip()
EndDo

TMPQUERY->(DbCLoseArea())

dbSelectArea(aArea)


If cBoleto = "T"
	M->C5_XBOLETO := .T.
Else
	M->C5_XBOLETO := .F.
Endif


Return(lTer)

static Function ValAtrib(atributo)
Return (type(atributo) )
