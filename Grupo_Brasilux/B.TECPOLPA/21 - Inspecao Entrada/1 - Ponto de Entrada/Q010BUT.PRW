#include 'Protheus.ch'
#include 'TOPConn.ch'
#include 'Rwmake.ch'
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "XMLXFUN.CH"
/*
+===============================================
+Função: Q010BUT()						       +
+Autor: Igor Manrique/Chaus +++ Data:08/05/2017+
+Função para incluir a função de Copiar uma    +
+		Especificação de Produto			   +
+==============================================+
*/
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function Q010BUT()
     If FWCodEmp() == '11' //Empresas que são do grupo 11(Tecpolpa).
        AADD(aButtons, {"Copiar Esp. Prod.", {|| U_EspPro()}, "Copiar Esp. Prod.", "Copiar Esp. Prod."} )
     Endif
Return(aButtons)

User Function EspPro()
Local cProd := Space(12)
Local cRev	:= Space(2)
Local oDlg

@ 65,153 To 229,435 Dialog oDlg Title OemToAnsi("Cópia Produto")
@ 09,009 Say OemToAnsi("Produto") Size 99,8
@ 15,009 Get cProd Picture "@!" F3 "QE6" Valid (ExistCPO("QE6",cProd)) Size 59,10
@ 28,009 Say OemToAnsi("Revisão") Size 99,8
@ 34,009 Get cRev Picture "@!" Size 59,10
@ 050	,039 BMPBUTTON TYPE 1 ACTION Close(oDlg)
Activate Dialog oDlg Centered

If !Empty(cProd) .OR. !Empty(cRev)
	U_COPIESP(cProd,cRev)
Else
	Alert("Informar Produto e/ou Especificação para cópia")
Endif

Return


User Function COPIESP(cProduto,cRevisa)
Local _aArea :=GetArea()

Local _nPosEns    := GdFieldPos("QE7_ENSAIO",	aHeadEns)
Local _nPosDEn    := GdFieldPos("QE7_DESENS",	aHeadEns)
Local _nPosUM     := GdFieldPos("QE7_UNIMED",	aHeadEns)
Local _nPosNom    := GdFieldPos("QE7_NOMINA",	aHeadEns)
Local _nPosAFI    := GdFieldPos("QE7_AFI",		aHeadEns)
Local _nPosAFS    := GdFieldPos("QE7_AFS",		aHeadEns)
Local _nPosLIC    := GdFieldPos("QE7_LIC",		aHeadEns)
Local _nPosNiv    := GdFieldPos("QE7_NIVEL",	aHeadEns)
Local _nPosDesNiv := GdFieldPos("QE7_DESNIV",	aHeadEns)
Local _nPosTip    := GdFieldPos("QE7_TIPO",		aHeadEns)
Local _nPosLab    := GdFieldPos("QE7_LABOR",	aHeadEns)
Local _nPosSeq    := GdFieldPos("QE7_SEQLAB",	aHeadEns)
Local _nPosMin    := GdFieldPos("QE7_MINMAX",	aHeadEns)
//Local _nPosDoc    := GdFieldPos("QE7_METODO",	aHeadEns)
//Local _nPosDocRev := GdFieldPos("QE7_REVDOC",	aHeadEns)
Local _nPosFor    := GdFieldPos("QE7_FORMUL",	aHeadEns)
Local _nPsAmIIn   := GdFieldPos("QE7_AM_INS",	aHeadEns)
Local _nPosDUM    := GdFieldPos("QE7_DUNMED",	aHeadEns)
Local _nPosDLab   := GdFieldPos("QE7_DESLAB",	aHeadEns)
//Local _nPosProd   := GdFieldPos("QE7_PRODUT",	aHeadEns)
//Local _nPosPRevi  := GdFieldPos("QE7_REVI",		aHeadEns)
//Local _nPosPlAm   := GdFieldPos("QE7_PLAMO",	aHeadEns)
//Local _nPosDPlA   := GdFieldPos("QE7_DESPLA",	aHeadEns)
Local _nPosEnD    := GdFieldPos("QE7_ENSDES",	aHeadEns)
Local _nPosAmIn   := GdFieldPos("QE7_AM_INS",	aHeadEns)
//Local _nPosAliWT  := GdFieldPos("QE7_ALI_WT",	aHeadEns)
Local _nPosRecWT  := GdFieldPos("QE7_REC_WT",	aHeadEns)
Local _nPosTex	  := GdFieldPos("QE8_TEXTO",    aHeadEns)


Local _cProduto := QE6->QE6_PRODUT
Local _cRevisa	:= QE6->QE6_REVI

Local aItensQE7	  := queryQE7(_cProduto,_cRevisa)
Local aItensQE8	  := queryQE8(_cProduto,_cRevisa)
Local aAux		  :={}

Local I  := 0
Local nI := 0
Local nX := 0

IIf(EMPTY(ALLTRIM(M->acols[1][1])) .AND. M->aCols[1][Len(aHeadEns)+1] ==.F.,M->aCols[1][Len(aHeadEns)+1] :=.T.,M->aCols[1][Len(aHeadEns)+1] :=.F.)

aAuxOrig :=aclone(acols)

aAux := Array(Len(aHeadEns)+1)

	For I := 1 To Len( aHeadEns )

		If ! (aHeadEns[I,2] $ "QE7_ALI_WT/QE7_REC_WT/QE8_ALI_WT/QE8_REC_WT")
			aAux[I] := CriaVar(aHeadEns[I,2],.T.)
		Else
			aAux[I] :=	aCols[1][I]

		Endif

	Next I


aAuxLimpo := aclone(aAux)



 /*
 _nPosEns    := GdFieldPos("QE7_ENSAIO",	aHeadEns)
 _nPosDEn    := GdFieldPos("QE7_DESENS",	aHeadEns)
 _nPosUM     := GdFieldPos("QE7_UNIMED",	aHeadEns)
 _nPosNom    := GdFieldPos("QE7_NOMINA",	aHeadEns)
 _nPosAFI    := GdFieldPos("QE7_AFI",		aHeadEns)
 _nPosAFS    := GdFieldPos("QE7_AFS",		aHeadEns)
 _nPosLIC    := GdFieldPos("QE7_LIC",		aHeadEns)
 _nPosNiv    := GdFieldPos("QE7_NIVEL",		aHeadEns)
 _nPosDesNiv := GdFieldPos("QE7_DESNIV",	aHeadEns)
 _nPosTip    := GdFieldPos("QE7_TIPO",		aHeadEns)
 _nPosLab    := GdFieldPos("QE7_LABOR",		aHeadEns)
 _nPosSeq    := GdFieldPos("QE7_SEQLAB",	aHeadEns)
 _nPosMin    := GdFieldPos("QE7_MINMAX",	aHeadEns)
 _nPosDoc    := GdFieldPos("QE7_METODO",	aHeadEns)
 _nPosDocRev := GdFieldPos("QE7_REVDOC",	aHeadEns)
 _nPosFor    := GdFieldPos("QE7_FORMUL",	aHeadEns)
 _nPsAmIIn   := GdFieldPos("QE7_AM_INS",	aHeadEns)
 _nPosDUM    := GdFieldPos("QE7_DUNMED",	aHeadEns)
 _nPosDLab   := GdFieldPos("QE7_DESLAB",	aHeadEns)
 _nPosProd   := GdFieldPos("QE7_PRODUT",	aHeadEns)
 _nPosPRevi  := GdFieldPos("QE7_REVI",		aHeadEns)
 _nPosPlAm   := GdFieldPos("QE7_PLAMO",		aHeadEns)
 _nPosDPlA   := GdFieldPos("QE7_DESPLA",	aHeadEns)
 _nPosEnD    := GdFieldPos("QE7_ENSDES",	aHeadEns)
 _nPosAmIn   := GdFieldPos("QE7_AM_INS",	aHeadEns)
 _nPosAliWT  := GdFieldPos("QE7_ALI_WT",	aHeadEns)
 _nPosRecWT  := GdFieldPos("QE7_REC_WT",	aHeadEns)
*/

If Len(aItensQE7) >0


	For nI := 1 To Len(aItensQE7)
		cLIE := aItensQE7[nI][18]
		cLSE := aItensQE7[nI][19]


  		aAux[_nPosEns]    := aItensQE7[nI][1]
  		aAux[_nPosDEn] 	  := A010DEns(aAux[_nPosEns] )
  		aAux[_nPosUM]     := aItensQE7[nI][2]
  		aAux[_nPosDUM]    := QA_DESUM(aAux[_nPosUM],.F.)
  		aAux[_nPosNom]    := aItensQE7[nI][3]
  		aAux[_nPosLIC]    := aItensQE7[nI][4]
  		aAux[_nPosNiv]    := aItensQE7[nI][5]
  		aAux[_nPosDesNiv] := If(!Empty(aAux[_nPosNiv]),	PadR(Tabela("Q6",aAux[_nPosNiv]),TamSX3("QE7_DESNIV")[1]),Space(TamSX3("QE7_DESNIV")[1]))
  		aAux[_nPosTip]    := aItensQE7[nI][6]
  		aAux[_nPosLab]    := aItensQE7[nI][7]
  		aAux[_nPosDLab]   := If(!Empty(aAux[_nPosLab]),PadR(Tabela("Q2",aAux[_nPosLab]),TamSX3("QE7_DESLAB")[1]),Space(TamSX3("QE7_DESLAB")[1]))
  		aAux[_nPosSeq]    := aItensQE7[nI][8]
  		aAux[_nPosMin]    := aItensQE7[nI][9]
  		aAux[_nPosFor] 	  := aItensQE7[nI][11]
  		aAux[_nPsAmIIn]   := aItensQE7[nI][12]
  		aAux[_nPosEnD] 	  := aItensQE7[nI][16]
  		aAux[_nPosAmIn]   := aItensQE7[nI][17]
  		aAux[_nPosRecWT]  := 0
  		aAux[len(aHeadEns)+1] :=.F.

  		If At(":",AllTrim(aAux[_nPosNom])) > 0
			If aAux[_nPosMin] $ "1ß2"
				aAux[_nPosAFI] 	:= cLIE
			EndIf

			If aAux[_nPosMin] $ "1ß3"
				aAux[_nPosAFS]  	:= cLSE
			EndIf
		ElseIf At("i",AllTrim(aAux[_nPosMin])) > 0
			If aAux[_nPosMin] $ "1ß2"
				aAux[_nPosAFI]   := qCalPol({cLIE,aAux[_nPosMin]},2,aAux[_nPosAFI])
			EndIf

			If aaAux[_nPosMin] $ "1ß3"
				aAux[_nPosAFS]   := qCalpol({cLSE,aAux[_nPosMin]},2,aAux[_nPosAFS])
			EndIf
		Else
			If cPaisLoc <> "MEX"
				nDec := If("," $ AllTrim(aAux[_nPosNom]),Len(AllTrim(aAux[_nPosNom]))-At(",",AllTrim(aAux[_nPosNom])),0)
			Else
				nDec := If("." $ AllTrim(aAux[_nPosNom]),Len(AllTrim(aAux[_nPosNom]))-At(".",AllTrim(aAux[_nPosNom])),0)
			Endif

			If aAux[_nPosMin] $ "1ß2"
				aAux[_nPosAFI] := Str(SuperVal(cLIE)-SuperVal(aAux[_nPosNom]),TamSx3("QE7_AFI")[1],nDec)
				If cPaisLoc <> "MEX"
					aAux[_nPosAFI] := StrTran(aAux[_nPosAFI],".",",")
				Endif
			EndIf

			If aAux[_nPosMin] $ "1ß3"
				aAux[_nPosAFS] := Str(SuperVal(cLSE)-SuperVal(aAux[_nPosNom]),TamSx3("QE7_AFS")[1],nDec)
				If cPaisLoc <> "MEX"
					aAux[_nPosAFS] := StrTran(aAux[_nPosAFS],".",",")
				Endif
			EndIf
		EndIf

  		Aadd(aAuxOrig,aAux)

		aAux := aClone(aAuxLimpo)

	Next nI

	If Len(aItensQE8) <1
		M->acols := aAuxOrig
	Endif

Endif
	//M->acols := aAuxOrig

If Len(aItensQE8) > 0


	For nX := 1 To Len(aItensQE8)

  		aAux[_nPosEns]    := aItensQE8[nX][1]
  		aAux[_nPosDEn] 	  := A010DEns(aAux[_nPosEns] )
  		aAux[_nPosEnD] 	  := aItensQE8[nX][2]
  		aAux[_nPosLab]    := aItensQE8[nX][3]
  		aAux[_nPosDLab]   := If(!Empty(aAux[_nPosLab]),PadR(Tabela("Q2",aAux[_nPosLab]),TamSX3("QE8_DESLAB")[1]),Space(TamSX3("QE8_DESLAB")[1]))
  		aAux[_nPosSeq]    := aItensQE8[nX][4]
  		aAux[_nPosTex]    := aItensQE8[nX][5]
		aAux[_nPosAmIn]   := aItensQE8[nX][6]
  		aAux[_nPosRecWT]  := 0
  		aAux[len(aHeadEns)+1] :=.F.


  		Aadd(aAuxOrig,aAux)

		aAux := aClone(aAuxLimpo)

	Next nX

	M->acols := aAuxOrig
Endif

	SysRefresh()
	GETDREFRESH()

	RestArea(_aArea)

Return


Static Function QueryQE7(cProduto,cRevisao)

	Local _cQryQE7 := ""
	Local _aItAc	  := {}
	Private cQLinha   := Chr(13) + Chr(10)

	If Select("TMQE7")<>0
		dbselectarea("TMQE7")
		dbclosearea()
	Endif

	_cQryQE7 := "SELECT QE7_FILIAL,QE7_PRODUT,QE7_REVI,QE7_ENSAIO,QE7_ENSDES,QE7_LABOR,QE7_SEQLAB,QE7_UNIMED,QE7_MINMAX,QE7_NOMINA,QE7_LIE,"+cQlinha
	_cQryQE7 += "QE7_LSE,QE7_LIC,QE7_LSC,QE7_TIPO,QE7_NIVEL,QE7_PLAMO,QE7_METODO,QE7_REVDOC,QE7_AM_INS,QE7_DESPLA,QE7_FORMUL,QE7_OK FROM "+RetSqlName("QE7")+ cQLinha
	_cQryQE7 += "WHERE QE7_FILIAL = '"+xFilial("QE7")+"' AND QE7_PRODUT = '"+cProduto+"' AND QE7_REVI ='"+cRevisao+"'" +cQlinha
	_cQryQE7 += "AND D_E_L_E_T_ <> '*'"

	TCQUERY _cQryQE7 ALIAS TMQE7 NEW
	dbSelectArea("TMQE7")
	dbGoTop()

	If TMQE7->(EOF())
		//ConOut("A Query nao retornou dados - fonte QE010ROT.prw")
	Endif

	While !TMQE7->(EOF())
		aadd(_aItAc,   {TMQE7->QE7_ENSAIO, TMQE7->QE7_UNIMED, TMQE7->QE7_NOMINA, TMQE7->QE7_LIC, TMQE7->QE7_NIVEL, TMQE7->QE7_TIPO, TMQE7->QE7_LABOR, TMQE7->QE7_SEQLAB, TMQE7->QE7_MINMAX, TMQE7->QE7_REVDOC, TMQE7->QE7_FORMUL, TMQE7->QE7_AM_INS, TMQE7->QE7_PRODUT, TMQE7->QE7_REVI, TMQE7->QE7_PLAMO, TMQE7->QE7_ENSDES, TMQE7->QE7_AM_INS, TMQE7->QE7_LIE, TMQE7->QE7_LSE})
		dbSelectArea("TMQE7")
		TMQE7->(dbSkip())
	EndDo


Return _aItAc


Static Function QueryQE8(cProduto,cRevisao)

	Local _cQryQE8 	  := ""
	Local _aItQE8	  := {}
	Private cQLinha   := Chr(13) + Chr(10)

	If Select("TMQE8")<>0
		dbselectarea("TMQE8")
		dbclosearea()
	Endif

	_cQryQE8 := "SELECT QE8_FILIAL, QE8_PRODUT,QE8_REVI,QE8_ENSAIO,"+cQlinha
	_cQryQE8 += "QE8_ENSDES,QE8_LABOR,QE8_SEQLAB,QE8_TEXTO,QE8_TIPO,QE8_NIVEL,QE8_PLAMO,QE8_METODO, QE8_REVDOC,QE8_AM_INS,QE8_DESPLA FROM "+RetSqlName("QE8")+ cQLinha
	_cQryQE8 += "WHERE QE8_FILIAL = '"+xFilial("QE8")+"' AND QE8_PRODUT = '"+cProduto+"' AND QE8_REVI ='"+cRevisao+"'" +cQlinha
	_cQryQE8 += "AND D_E_L_E_T_ <> '*'"

	TCQUERY _cQryQE8 ALIAS TMQE8 NEW
	dbSelectArea("TMQE8")
	dbGoTop()

	If TMQE8->(EOF())
		//ConOut("A Query nao retornou dados - fonte QE010ROT.prw")
	Endif

	While !TMQE8->(EOF())
		aadd(_aItQE8,   {TMQE8->QE8_ENSAIO,TMQE8->QE8_ENSDES,TMQE8->QE8_LABOR,TMQE8->QE8_SEQLAB,TMQE8->QE8_TEXTO,TMQE8->QE8_AM_INS})
		dbSelectArea("TMQE8")
		TMQE8->(dbSkip())
	EndDo


Return _aItQE8