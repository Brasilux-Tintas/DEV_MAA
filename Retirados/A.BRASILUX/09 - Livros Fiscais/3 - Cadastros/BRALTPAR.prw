#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³         ³ Autor ³                       ³ Data ³           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ CADASTRO DE ALTERAÇÃO DE PARAMETROS PARA CONTABILIDADE     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LANÇAMENTO E EXCLUSÕES DE NOTAS RETROATIVAS E TAMBÉM FECHA ³±±
±±³	MENTO DO PARAMETRO QUE CONTROLA MOVIMENTAÇÕES FINANCEIRAS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³                                               ³±±
±±³              ³  /  /  ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

//Constantes
#Define CLR_AZUL      RGB(058,074,119)									//Cor Azul

//Variaveis
Static COL_T1 	:= 001				//Primeira Coluna da tela
Static COL_T2 	:= 123				//Segunda Coluna da tela
Static COL_T3 	:= 245				//Terceira Coluna da tela
Static COL_T4 	:= 367				//Quarta Coluna da tela
Static ESP_CAMPO	:= 038				//Espaçamento do campo para coluna
Static TAM_FILIAL	:= FWSizeFilial()	//Tamanho do campo Filial


/*/{Protheus.doc} zCadSX6

Lista parâmetros ao usuário com as opções de incluir, alterar e excluir

@author Atilio

@since 14/11/2014

@version 1.0

	@param aParams, Array, Parâmetros que serão listados ao usuário para edição

	@param lCombo, Lógico, Define se os parâmetros serão mostrados em combo quando houver inclusão

	@param lDelet, Lógico, Define se será possível a exclusão de parâmetros

	@example

	aParams := { "MV_X_AMBOF","MV_X_USERS"}

	u_zCadSX6(aParams, .T., .T.)

/*/

User Function BRALTPAR()
	u_zCadSx6({"MV_ULMES","MV_DATAFIN","MV_CHVNFE","MV_VCHVNFE"},.T.,.F.)

Return


User Function zCadSX6(aParams, lCombo, lDelet)

	Local aArea   := GetArea()
	Local aAreaX6 := SX6->(GetArea())
	Local nAtual  := 0
	Local nColuna := 6
	Default lCombo := .T.
	Default lDelet := .F.
	Default aParams := {}
	Private lComboPvt := lCombo
	Private aParamsPvt := {}
	Private cParamsPvt := ""

	//Tamanho da Janela

	Private aTamanho := MsAdvSize()
	Private nJanLarg := aTamanho[5]
	Private nJanAltu := aTamanho[6]
	Private nColMeio := (nJanLarg)/4
	Private nEspCols := ((nJanLarg/2)-12)/4
	COL_T1 	:= 003
	COL_T2 	:= COL_T1+nEspCols
	COL_T3 	:= COL_T2+nEspCols
	COL_T4 	:= COL_T3+nEspCOls

	//Objetos gráficos

	Private oDlgSX6
	//GetDados
	Private oMsGet
	Private aHeader 	:= {}
	Private aCols		:= {}

	//Botões

	Private aButtons	:= {}
	//aAdd(aButtons,{"Incluir",    "{|| fInclui()}", "oBtnInclui"})
	aAdd(aButtons,{"Alterar",    "{|| fAltera()}", "oBtnAltera"})
	aAdd(aButtons,{"Visualizar", "{|| fVisualiza()}", "oBtnVisual"})

	/*If lDelet
		aAdd(aButtons,{"Excluir",    "{|| fExclui()}", "oBtnExclui"})
	EndIf*/

	aAdd(aButtons,{"Sair", "{|| oDlgSX6:End()}", "oBtnSair"})

	

	//Se não tiver parâmetros

	If Len(aParams) <= 0
		MsgStop("Parâmetros devem ser informados!", "Atenção")
		Return
	Else
		aParamsPvt := aParams
		cParamsPvt := ""
		
		//Percorrendo os parâmetros e adicionando

		For nAtual := 1 To Len(aParamsPvt)
			cParamsPvt += aParamsPvt[nAtual]+";"
		Next

	EndIf

	

	//Adicionando cabeçalho

	aAdd(aHeader,{"Filial", 	"ZZ_FILIAL",	"@!",	TAM_FILIAL,	0,	".F.",	".F.",	"C",	"",	""	,})
	aAdd(aHeader,{"Parâmetro", 	"ZZ_PARAME",	"@!",	010,			0,	".F.",	".F.",	"C",	"",	""	,})
	aAdd(aHeader,{"Tipo",  		"ZZ_TIPO",		"@!",	001,			0,	".F.",	".F.",	"C",	"",	""	,})
	aAdd(aHeader,{"Descrição",  "ZZ_DESCRI",	"@!",	150,			0,	".F.",	".F.",	"C",	"",	""	,})
	aAdd(aHeader,{"Conteúdo",   "ZZ_CONTEU",	"@!",	250,			0,	".F.",	".F.",	"C",	"",	""	,})
	aAdd(aHeader,{"RecNo",      "ZZ_RECNUM",	"",		018,			0,	".F.",	".F.",	"N",	"",	""	,})

	

	//Atualizando o aCols
	fAtuaCols(.T.)

	

	//Criando a janela

	DEFINE MSDIALOG oDlgSX6 TITLE "Parâmetros:" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
		oMsGet := MsNewGetDados():New(	3,;  //nTop	
										3,;	//nLeft
  										(nJanAltu/2)-33,;	//nBottom
  										(nJanLarg/2)-3,;    //nRight
   										GD_INSERT+GD_DELETE+GD_UPDATE,;	 //nStyle
   										"AllwaysTrue()",;	//cLinhaOk
   										,;				    //cTudoOk
   										"",;				//cIniCpos
   										,;					//aAlter
   										,;					//nFreeze
   										999999,;			//nMax
   										,;					//cFieldOK
   										,;					//cSuperDel
   										,;					//cDelOk
   										oDlgSX6,;			//oWnd
   										aHeader,;			//aHeader
   										aCols)				//aCols  

    	oMsGet:lActive := .F.


		//Grupo Legenda

		@ (nJanAltu/2)-30, 003 	GROUP oGrpLeg TO (nJanAltu/2)-3, (nJanLarg/2)-3 	PROMPT "Ações: " 		OF oDlgSX6 COLOR 0, 16777215 PIXEL

		//Adicionando botões

		For nAtual := 1 To Len(aButtons)
			@ (nJanAltu/2)-20, nColuna  BUTTON &(aButtons[nAtual][3]) PROMPT aButtons[nAtual][1]   SIZE 60, 014 OF oDlgSX6  PIXEL
			(&(aButtons[nAtual][3]+":bAction := "+aButtons[nAtual][2]))
			nColuna += 63
		Next

	ACTIVATE MSDIALOG oDlgSX6 CENTERED

	RestArea(aAreaX6)
	RestArea(aArea)

Return



/*---------------------------------------------------------------------*

 | Func:  fInclui                                                      |

 | Autor: Daniel Atilio                                                |

 | Data:  14/11/2014                                                   |

 | Desc:  Função de inclusão de parâmetro                              |

 | Obs.:  /                                                            |

 *---------------------------------------------------------------------*/



Static Function fInclui()

	Local nAtual   := oMsGet:nAt
	Local aColsAux := oMsGet:aCols
	Local nPosRecNo:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })

	fMontaTela(3, 0)

Return



/*---------------------------------------------------------------------*

 | Func:  fAltera                                                      |

 | Autor: Daniel Atilio                                                |

 | Data:  14/11/2014                                                   |

 | Desc:  Função de alteração de parâmetro                             |

 | Obs.:  /                                                            |

 *---------------------------------------------------------------------*/



Static Function fAltera()

	Local nAtual   := oMsGet:nAt
	Local aColsAux := oMsGet:aCols
	Local nPosRecNo:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })


	//Se tiver recno válido

	If aColsAux[nAtual][nPosRecNo] != 0
		fMontaTela(4, aColsAux[nAtual][nPosRecNo])
	EndIf

Return



/*---------------------------------------------------------------------*

 | Func:  fExclui                                                      |

 | Autor: Daniel Atilio                                                |

 | Data:  14/11/2014                                                   |

 | Desc:  Função de exclusão de parâmetro                              |

 | Obs.:  /                                                            |

 *---------------------------------------------------------------------*/



Static Function fExclui()
	Local nAtual   := oMsGet:nAt
	Local aColsAux := oMsGet:aCols
	Local nPosRecNo:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })


	//Se tiver recno válido

	If aColsAux[nAtual][nPosRecNo] != 0
		fMontaTela(5, aColsAux[nAtual][nPosRecNo])
	EndIf
Return



/*---------------------------------------------------------------------*

 | Func:  fVisualiza                                                   |

 | Autor: Daniel Atilio                                                |

 | Data:  14/11/2014                                                   |

 | Desc:  Função de visualização de parâmetro                          |

 | Obs.:  /                                                            |

 *---------------------------------------------------------------------*/



Static Function fVisualiza()

	Local nAtual   := oMsGet:nAt
	Local aColsAux := oMsGet:aCols
	Local nPosRecNo:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })

	

	//Se tiver recno válido
	If aColsAux[nAtual][nPosRecNo] != 0
		fMontaTela(2, aColsAux[nAtual][nPosRecNo])
	EndIf
Return



/*---------------------------------------------------------------------*

 | Func:  fAtuaCols                                                    |

 | Autor: Daniel Atilio                                                |

 | Data:  14/11/2014                                                   |

 | Desc:  Função que atualiza o aCols com os parâmetros                |

 | Obs.:  Como a intenção é ter poucos parâmetros, sempre ele irá      |

 |        percorrer a SX6 e adicionar no aCols                         |

 *---------------------------------------------------------------------*/



Static Function fAtuaCols(lFirst)

	Local aAreaSX6 := SX6->(GetArea())
	aCols := {}

	//Selecionando a tabela de parâmetros e indo ao topo

	DbSelectArea("SX6")
	SX6->(DbGoTop())

	//Percorrendo os parâmetros, e adicionando somente os que estão na filtragem

	While !SX6->(EoF())
		If Alltrim(SX6->X6_VAR) $ cParamsPvt
			aAdd( aCols, {	SX6->X6_FIL,;	//Filial
							SX6->X6_VAR,;											//Parâmetro
							SX6->X6_TIPO,;										//Tipo
							SX6->X6_DESCRIC+SX6->X6_DESC1+SX6->X6_DESC2,;		//Descrição
							SX6->X6_CONTEUD,;										//Conteúdo
							SX6->(RecNo()),;										//RecNo
							.F.})													//Excluído?
		EndIf
		SX6->(DbSkip())

	EndDo



	//Se tiver zerada, adiciona conteúdo em branco

	If Len(aCols) == 0
		aAdd( aCols, {	"",;		//Filial
						"",;		//Parâmetro
						"",;		//Tipo
						"",;		//Descrição
						"",;		//Conteúdo
						0,;			//RecNo
						.F.})		//Excluído?
	EndIf



	//Senão for a primeira vez, atualiza grid

	If !lFirst
		oMsGet:setArray(aCols)
	EndIf

	RestArea(aAreaSX6)

Return



/*---------------------------------------------------------------------*

 | Func:  fMontaTela                                                   |

 | Autor: Daniel Atilio                                                |

 | Data:  14/11/2014                                                   |

 | Desc:  Função que atualiza o aCols com os parâmetros                |

 | Obs.:  /                                                            |

 *---------------------------------------------------------------------*/



Static Function fMontaTela(nOpcP, nRecP)

	Local nColuna := 6
	Local nEsp := 15
	Local nAtual
	Private nOpcPvt := nOpcP
	Private nRecPvt := nRecP
	Private aOpcTip := {" ", "C - Caracter", "N - Numérico", "L - Lógico", "D - Data", "M - Memo"}
	Private oFontNeg := TFont():New("Tahoma")
	Private oDlgEdit

	//Campos
	Private oGetFil, cGetFil
	Private oGetPar, cGetPar
	Private oGetTip, cGetTip
	Private oGetDes, cGetDes
	Private oGetCon, cGetCon
	Private oGetRec, nGetRec

	//Botões

	Private aBtnPar	:= {}
	aAdd(aBtnPar,{"Confirmar",   "{|| fBtnEdit(1)}", "oBtnConf"})
	aAdd(aBtnPar,{"Cancelar",    "{|| fBtnEdit(2)}", "oBtnCanc"})

	//Se não for inclusão, pega os campos conforme array

	If nOpcP != 3
		aColsAux := oMsGet:aCols
		nLinAtu  := oMsGet:nAt
		nPosFil  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_FILIAL" })
		nPosPar  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_PARAME" })
		nPosTip  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_TIPO" })
		nPosDes  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_DESCRI" })
		nPosCon  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_CONTEU" })
		nPosRec  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })

		//Atualizando gets

		cGetFil := aColsAux[nLinAtu][nPosFil]
		cGetPar := aColsAux[nLinAtu][nPosPar]
		cGetTip := aColsAux[nLinAtu][nPosTip]
		cGetDes := aColsAux[nLinAtu][nPosDes]
		cGetCon := aColsAux[nLinAtu][nPosCon]
		nGetRec := aColsAux[nLinAtu][nPosRec]

		//Caracter

		If cGetTip == "C"
			cGetTip := aOpcTip[2]
		//Numérico
		ElseIf cGetTip == "N"
			cGetTip := aOpcTip[3]
		//Lógico
		ElseIf cGetTip == "L"
			cGetTip := aOpcTip[4]
		//Data
		ElseIf cGetTip == "D"
			cGetTip := aOpcTip[5]
		//Memo
		ElseIf cGetTip == "M"
			cGetTip := aOpcTip[6]
		EndIf

	//Senão, deixa os campos zerados

	Else

		//Atualizando gets
		cGetFil := Space(TAM_FILIAL)
		cGetPar := Space(010)
		cGetTip := aOpcTip[1]
		cGetDes := Space(150)
		cGetCon := Space(250)
		nGetRec := 0
	EndIf

	oFontNeg:Bold := .T.

	//Criando a janela

	DEFINE MSDIALOG oDlgEdit TITLE "Dados:" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

		nLinAux := 6
			//Filial
			@ nLinAux    , COL_T1						SAY				oSayFil PROMPT	"Filial:"						SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL							PIXEL
			@ nLinAux-003, COL_T1+ESP_CAMPO				MSGET			oGetFil VAR		cGetFil						SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215						PIXEL
			//Parâmetro
			@ nLinAux    , COL_T2						SAY				oSayPar PROMPT	"Parâmetro:"					SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL		FONT oFontNeg		PIXEL
			If lComboPvt
				@ nLinAux-003, COL_T2+ESP_CAMPO			MSCOMBOBOX		oGetPar VAR		cGetPar ITEMS aParamsPvt		SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215						PIXEL
			Else
				@ nLinAux-003, COL_T2+ESP_CAMPO			MSGET			oGetPar VAR		cGetPar						SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215	VALID (cGetPar $ cParamsPvt)	PIXEL
			EndIf
			//Tipo
			@ nLinAux    , COL_T3						SAY				oSayTip PROMPT	"Tipo:"						SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL		FONT oFontNeg		PIXEL
    		@ nLinAux-003, COL_T3+ESP_CAMPO				MSCOMBOBOX		oGetTip VAR		cGetTip ITEMS aOpcTip		SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215						PIXEL
			//RecNo
			@ nLinAux    , COL_T4						SAY				oSayRec PROMPT	"RecNo:"						SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL							PIXEL
			@ nLinAux-003, COL_T4+ESP_CAMPO				MSGET			oGetRec VAR		nGetRec						SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215						PIXEL
		nLinAux += nEsp
			//Descrição
			@ nLinAux    , COL_T1						SAY				oSayDes PROMPT	"Descrição:"					SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL		FONT oFontNeg		PIXEL
			@ nLinAux-003, COL_T1+ESP_CAMPO				MSGET			oGetDes VAR		cGetDes						SIZE 300, 010 OF oDlgEdit COLORS 0, 16777215						PIXEL
		nLinAux += nEsp
			//Conteúdo
			@ nLinAux    , COL_T1						SAY				oSayCon PROMPT	"Conteúdo:"					SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL		FONT oFontNeg		PIXEL
			@ nLinAux-003, COL_T1+ESP_CAMPO				MSGET			oGetCon VAR		cGetCon						SIZE 300, 010 OF oDlgEdit COLORS 0, 16777215						PIXEL

		//Grupo Legenda
		@ (nJanAltu/2)-30, 003 	GROUP oGrpLegEdit TO (nJanAltu/2)-3, (nJanLarg/2)-3 	PROMPT "Ações (Confirmação): " 		OF oDlgEdit COLOR 0, 16777215 PIXEL
		//Adicionando botões
		For nAtual := 1 To Len(aBtnPar)
			@ (nJanAltu/2)-20, nColuna  BUTTON &(aBtnPar[nAtual][3]) PROMPT aBtnPar[nAtual][1]   SIZE 60, 014 OF oDlgEdit  PIXEL
			(&(aBtnPar[nAtual][3]+":bAction := "+aBtnPar[nAtual][2]))
			nColuna += 63
		Next

		//Se for visualização ou exclusão, todos os gets serão desabilitados
		If nOpcP == 2 .Or. nOpcP == 5
			oGetFil:lActive := .F.
			oGetPar:lActive := .F.
			oGetTip:lActive := .F.
			oGetDes:lActive := .F.
			oGetCon:lActive := .F.
		Else
			//Se for alteração, desabilita a Filial, Parâmetro e Tipo
			If nOpcP == 4
				oGetFil:lActive := .F.
				oGetPar:lActive := .F.
				oGetTip:lActive := .F.
			EndIf
		EndIf
		//Campo de RecNo sempre será desabilitado

		oGetRec:lActive := .F.

	ACTIVATE MSDIALOG oDlgEdit CENTERED

Return



/*---------------------------------------------------------------------*

 | Func:  fBtnEdit                                                     |

 | Autor: Daniel Atilio                                                |

 | Data:  16/12/2014                                                   |

 | Desc:  Função que confirma a tela                                   |

 | Obs.:  /                                                            |

 *---------------------------------------------------------------------*/



Static Function fBtnEdit(nConf)
	Local aAreaAux := GetArea()

	//Se for o Cancelar
	If nConf == 2
		oDlgEdit:End()
	//Se for o Confirmar
	ElseIf nConf == 1
		//Se for visualizar
		If nOpcPvt == 2
			oDlgEdit:End()
	
		//Senão for visualizar
		Else
			//Se for exclusão
			If nOpcPvT == 5
				SX6->(DbGoTo(nRecPvt))
				RecLock("SX6", .F.)
					DbDelete()
				SX6->(MsUnlock())
				oDlgEdit:End()
			Else
				//Descrição ou conteúdo em branco?
				If Empty(cGetDes) .Or. Empty(cGetCon)
					If !MsgYesNo("O campo <b>Descrição</b> e/ou <b>Conteúdo</b> estão com conteúdo em branco!<br>Deseja continuar?", "Atenção")
						Return
					EndIf
				EndIf
				//Se for inclusão
				If nOpcPvt == 3
					//Tipo e parâmetro em branco?
					If Empty(cGetTip) .Or. Empty(cGetPar)
						MsgAlert("O campo <b>Parâmetro</b> e/ou <b>Tipo</b> estão com conteúdo em branco!", "Atenção")
						Return
					EndIf
					//Já existe registro?
					SX6->(DbGoTop())
					If (SX6->(DbSeek(cGetFil+cGetPar)))
						MsgAlert("Filial e Parâmetro já existem!", "Atenção")
						Return
					EndIf


					//Travando tabela para inclusão
					RecLock("SX6", .T.)
					X6_FIL			:= cGetFil
					X6_VAR			:= cGetPar
					X6_TIPO		:= cGetTip
				//Se for alteração, trava tabela para alteração
				ElseIf nOpcPvt == 4
					SX6->(DbGoTo(nRecPvt))
					RecLock("SX6", .F.)
				EndIf

				//Gravando informações
				X6_DESCRIC		:= SubStr(cGetDes,001,50)
				X6_DESC1		:= SubStr(cGetDes,051,50)
				X6_DESC2		:= SubStr(cGetDes,101,50)
				X6_CONTEUD		:= cGetCon
				SX6->(MsUnlock())

				oDlgEdit:End()
			EndIf

		EndIf
		//Atualizando a grid
		fAtuaCols(.F.)
	EndIf

	RestArea(aAreaAux)

Return

/*
User Function BRALTPAR()

	Private cGet1 := GetMv("MV_ULMES")
	Private cGet2 := GetMv("MV_DATAFIN")
	Private cGet3 := SUPERGETMV ("MV_CHVNFE",.T.,"",'        ')

//	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//	±± Declaração de Variaveis Private dos Objetos                             ±±
//	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
/*
	SetPrvt("oDlg1","oSay1","oSay2","oSay3","oGet1","oGet2","oGet3","oBtn1")

	If !u_VldAcesso(funname())
		MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
		Return
	Endif

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Definicao do Dialog e todos os seus componentes.                        ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
/*
	oDlg1      := MSDialog():New( 092,232,249,698,"ALTERAÇÃO DE PARAMETROS",,,.F.,,,,,,.T.,,,.T. )
	oSay1      := TSay():New( 020,012,{||"MV_ULMES"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay2      := TSay():New( 036,012,{||"MV_DATAFIN"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
	oSay3      := TSay():New( 052,012,{||"MV_CHVNFE"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)

	oGet1      := TGet():New( 020,050,{|u| If(PCount() > 0, cGet1 := u, cGet1)},oDlg1,060,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGet1",,)
	oGet2      := TGet():New( 035,050,{|u| If(PCount() > 0, cGet2 := u, cGet2)},oDlg1,060,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGet2",,)
	oGet3      := TGet():New( 051,050,{|u| If(PCount() > 0, cGet3 := u, cGet3)},oDlg1,040,003,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGet3",,)

	oBtn1      := TButton():New( 048,168,"ALTERAR",oDlg1,{|| fGravPar()},037,012,,,,.T.,,"",,,,.F. )

	oDlg1:Activate(,,,.T.)

Return

Static Function fGravPar()

	If Substr(Dtoc(cGet1),1,1)=''
		MsgStop("Parametro MV_ULMES deve ser preenchido !", "Atenção")
		Return
	Endif

	If Substr(Dtoc(cGet2),1,1)=''
		MsgStop("Parametro MV_DATAFIN deve ser preenchido !", "Atenção")
		Return
	Endif

	If Substr(cGet3,1,1)=''
		MsgStop("Parametro MV_CHVNFE deve ser preenchido !", "Atenção")
		Return
	Endif

	If MsgYesNo("Confirma a atualização dos parametros para a filial CORRENTE ?", "Atenção")

		PutMv("MV_ULMES"   , cGet1)
		PutMv("MV_DATAFIN" , cGet2)
		PutMv("        MV_CHVNFE"  , cGet3)

	Endif

	Messagebox("Informações salvas!!!","Atenção...",64)

Return

*/

