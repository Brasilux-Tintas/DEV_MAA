
//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} zReport
Função que gera TOTVS Report de forma genérica
@type function
@author Atilio
@since 17/12/2016
@version 1.0
	@example
	u_zReport()
/*/
User function BFCFGM24()
	
Return zReport()


Static Function zReport()
	Local aArea := GetArea()
	Local _lOpen        := .F. //LGS#20200207 - Adequação para release 12.1.25
	//Grupos
	Local oGrpGer
	Local oGrpDef
	Local oGrpPar
	Local oGrpEma
	Private cAutor := "zReport"
	Private cData  := dToC(Date())
	//Dimensões da janela
	Private nJanLarg := 800
	Private nJanAltu := 500
	//Outros Objetos e variáveis
	Private oDlgPvt
	Private oBtnFec
	Private oBtnGer
	Private aTpPad := {"S=Sim", "N=Nao"}
	//Campos do grupo Geral
	Private oSayUserF, oGetUserF, cGetUserF := "xRelat" + Space(2)
	Private oSayDirec, oGetDirec, cGetDirec := GetTempPath()
	Private oSayTitul, oGetTitul, cGetTitul := "Relatorio" + Space(21)
	Private nLenDirec := 120
	//Campos do grupo Definições
	Private aTpOri := {"R=Retrato", "P=Paisagem"}
	Private aTpFon := {"P=Padrao",  "1=Padrao. Tamanho 8", "2=Padrao. Tamanho 12"}
	Private oSayOrien, oCmbOrien, cCmbOrien := "R"
	Private oSayFonte, oCmbFonte, cCmbFonte := "P"
	//Campos do grupo Parâmetros
	Private oSayUtili, oCmbUtili, cCmbUtili := "N"
	Private oSayPergu, oGetPergu, cGetPergu := Space(10)
	Private oSayMostr, oCmbMostr, cCmbMostr := "N"
	//Campos do grupo de e-Mail
	Private oSayEnvia, oCmbEnvia, cCmbEnvia := "N"
	Private oSayEmail, oGetEmail, cGetEmail := Space(100)
	//Campos da aba do SQL
	Private oSaySQL, oPanelSQL, oEditSQL, cEditSQL := ""
	Private oSayQuebr, oGetQuebr, cGetQuebr := Space(30)
	Private oChkEdit, lChkEdit := .F.
	Private oMsGetCam
	Private aHeaderCam := {}
	Private aColsCam   := {}
	Private oChkTot, lChkTot := .F.
	Private oMsGetTot
	Private aHeaderTot := {}
	Private aColsTot   := {}
	//Barras de Rolagem e abas
	Private oFolderPvt
	Private oScrollRel
	Private oScrollSQL
	Private _cAliasSX3  := GetNextAlias() //LGS#20200207 - Adequação para release 12.1.25
	
     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200207 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0
     
     If !lOpen
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
        Return
     Endif
	//Campos para informar manualmente
	//                Titulo             Campo       Picture   Tamanho   Dec Valid         Usado  Tipo F3  Contexto Combo                                                     Ini Padrão
	aAdd(aHeaderCam,{ "Campo",           "XX_CAMPO", "",       010,      0,  ".T.",        ".T.", "C", "", "",      "",                                                       ""} )
	aAdd(aHeaderCam,{ "Titulo",          "XX_TITUL", "",       020,      0,  ".T.",        ".T.", "C", "", "",      "",                                                       ""} )
	aAdd(aHeaderCam,{ "Mascara",         "XX_MASCA", "",       020,      0,  ".T.",        ".T.", "C", "", "",      "",                                                       ""} )
	aAdd(aHeaderCam,{ "Tamanho",         "XX_TAMCP", "@E 999", 003,      0,  "Positivo()", ".T.", "N", "", "",      "",                                                       ""} )
	aAdd(aHeaderCam,{ "Alinhamento",     "XX_ALINH", "",       001,      0,  ".T.",        ".T.", "C", "", "",      "0=Padrao;1=Esquerda;2=Direita;3=Centralizado",           "'0'"} )
	aAdd(aHeaderCam,{ "Quebra a Linha?", "XX_QUEBR", "",       001,      0,  ".T.",        ".T.", "C", "", "",      "S=Sim;N=Nao",                                            "'N'"} )
	aAdd(aHeaderCam,{ "Cor de Fundo",    "XX_FUNDO", "",       001,      0,  ".T.",        ".T.", "C", "", "",      "0=Padrao;1=Preto;2=Branco;3=Vermelho;4=Verde;5=Azul",    "'0'"} )
	aAdd(aHeaderCam,{ "Cor da Fonte",    "XX_FONTE", "",       001,      0,  ".T.",        ".T.", "C", "", "",      "0=Padrao;1=Preto;2=Branco;3=Vermelho;4=Verde;5=Azul",    "'0'"} )
	aAdd(aHeaderCam,{ "Negrito?",        "XX_NEGRI", "",       001,      0,  ".T.",        ".T.", "C", "", "",      "S=Sim;N=Nao",                                            "'N'"} )
	
	//Campos para totalizar
	//                Titulo             Campo       Picture Tamanho   Dec Valid         Usado  Tipo F3  Contexto Combo                                                                               Ini Padrão
	aAdd(aHeaderTot,{ "Campo",           "XX_CAMPO", "",     010,      0,  ".T.",        ".T.", "C", "", "",      "",                                                                                 ""} )
	aAdd(aHeaderTot,{ "Mascara",         "XX_MASCA", "",     020,      0,  ".T.",        ".T.", "C", "", "",      "",                                                                                 ""} )
	aAdd(aHeaderTot,{ "Totalizar",       "XX_TOTAL", "",     001,      0,  ".T.",        ".T.", "C", "", "",      "0=Soma (SUM);1=Contar (COUNT);2=Maximo (MAX);3=Minimo (MIN);4=Media (AVERAGE)",    "'0'"} )
	
	//Deixando com espaços a direita
	cGetDirec := PadR(cGetDirec, nLenDirec)
	
	//Criando a janela
	DEFINE MSDIALOG oDlgPvt TITLE "zReport - Gerador de TOTVS Report" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
		//Folders / Pastas
		@ 001, 003 FOLDER oFolderPvt SIZE (nJanLarg/2)-4, (nJanAltu/2)-30 OF oDlgPvt ITEMS	"Relatório",;
																										"Dados - SQL" COLORS 0, 14215660 PIXEL
	
		//Criando barras de rolagem
		@ 001, 003 SCROLLBOX oScrollRel HORIZONTAL VERTICAL SIZE (nJanAltu/2)-45, 	(nJanLarg/2)-13 OF oFolderPvt:aDialogs[1]
		@ 001, 003 SCROLLBOX oScrollSQL HORIZONTAL VERTICAL SIZE (nJanAltu/2)-45, 	(nJanLarg/2)-13 OF oFolderPvt:aDialogs[2]
		
		//Aba do Relatório, Grupo Geral
		@ 001, 001	GROUP oGrpGer TO 055, (nJanLarg/2)-24	PROMPT "Geral: "	OF oScrollRel COLOR RGB(255,0,0), 16777215 PIXEL
			@ 013, 006   SAY   oSayUserF PROMPT "User Function:" SIZE 040, 007 OF oScrollRel                    PIXEL
			@ 011, 045   MSGET oGetUserF VAR    cGetUserF        SIZE 040, 007 OF oScrollRel COLORS 0, 16777215 PIXEL
			@ 028, 006   SAY   oSayDirec PROMPT "Diretório:"     SIZE 030, 007 OF oScrollRel                    PIXEL
			@ 026, 045   MSGET oGetDirec VAR    cGetDirec        SIZE 250, 007 OF oScrollRel COLORS 0, 16777215 VALID (fVldDir()) PIXEL
			@ 043, 006   SAY   oSayTitul PROMPT "Título:"        SIZE 030, 007 OF oScrollRel                    PIXEL
			@ 041, 045   MSGET oGetTitul VAR    cGetTitul        SIZE 130, 007 OF oScrollRel COLORS 0, 16777215 PIXEL
		
		//Aba do Relatório, Grupo Definições
		@ 058, 001	GROUP oGrpDef TO 097, (nJanLarg/2)-24	PROMPT "Definições: "	OF oScrollRel COLOR RGB(255,0,0), 16777215 PIXEL
			@ 070, 006  SAY  oSayOrien  PROMPT "Orientação Padrão:"     SIZE 060, 007 OF oScrollRel                    PIXEL
			@ 068, 055  MSCOMBOBOX oCmbOrien VAR cCmbOrien ITEMS aTpOri SIZE 040, 007 OF oScrollRel COLORS 0, 16777215 PIXEL
			@ 085, 006  SAY  oSayFonte  PROMPT "Fonte Utilizada:"       SIZE 060, 007 OF oScrollRel                    PIXEL
			@ 083, 055  MSCOMBOBOX oCmbFonte VAR cCmbFonte ITEMS aTpFon SIZE 060, 007 OF oScrollRel COLORS 0, 16777215 PIXEL
		
		//Aba do Relatório, Grupo de Parâmetros
		@ 100, 001	GROUP oGrpPar TO 154, (nJanLarg/2)-24	PROMPT "Parâmetros: "	OF oScrollRel COLOR RGB(255,0,0), 16777215 PIXEL
			@ 112, 006  SAY   oSayUtili  PROMPT "Utiliza Grupo de Perguntas?"     SIZE 080, 007 OF oScrollRel                    PIXEL
			@ 110, 085  MSCOMBOBOX oCmbUtili VAR cCmbUtili ITEMS aTpPad           SIZE 030, 007 OF oScrollRel COLORS 0, 16777215 VALID (fVldPer()) PIXEL
			@ 127, 006  SAY   oSayPergu  PROMPT "Código Grupo de Perguntas:"      SIZE 040, 007 OF oScrollRel                    PIXEL
			@ 125, 085  MSGET oGetPergu  VAR    cGetPergu                         SIZE 060, 007 OF oScrollRel COLORS 0, 16777215 PIXEL
			@ 142, 006  SAY   oSayMostr  PROMPT "Mostra página de Parâmetros?"    SIZE 080, 007 OF oScrollRel                    PIXEL
			@ 140, 085  MSCOMBOBOX oCmbMostr VAR cCmbMostr ITEMS aTpPad           SIZE 030, 007 OF oScrollRel COLORS 0, 16777215 PIXEL
			oGetPergu:lActive := .F.
			oCmbMostr:lActive := .F.
		
		//Aba do Relatório, Grupo de e-Mails
		@ 157, 001	GROUP oGrpEma TO 196, (nJanLarg/2)-24	PROMPT "e-Mail: "	OF oScrollRel COLOR RGB(255,0,0), 16777215 PIXEL
			@ 169, 006  SAY   oSayEnvia  PROMPT "Envia por e-Mail?"               SIZE 080, 007 OF oScrollRel                    PIXEL
			@ 167, 075  MSCOMBOBOX oCmbEnvia VAR cCmbEnvia ITEMS aTpPad           SIZE 030, 007 OF oScrollRel COLORS 0, 16777215 VALID (fVldEma()) PIXEL
			@ 184, 006  SAY   oSayEmail  PROMPT "e-Mails (separados por ';'):"    SIZE 080, 007 OF oScrollRel                    PIXEL
			@ 182, 075  MSGET oGetEmail  VAR    cGetEmail                         SIZE 140, 007 OF oScrollRel COLORS 0, 16777215 PIXEL
			oGetEmail:lActive := .F.
		
		//Aba de dados, get referente ao SQL
		@ 006, 003   SAY   oSaySQL PROMPT "Consulta SQL:" SIZE 040, 007 OF oScrollSQL                    PIXEL
		oPanelSQL := tPanel():New(001, 045, "", oScrollSQL, , , , RGB(000,000,000), RGB(254,254,254), 330, 	060)
		oEditSQL  := tSimpleEditor():New(	000,; //nRow
												000,; //nCol
												oPanelSQL,; //oWnd
												330,; //nWidth
												060,; //nHeight
												cEditSQL,; //cText
												.F. ) //lReadOnly
		oEditSQL:bValid := {|| fVldSQL()}
		oEditSQL:TextFormat(2)
		@ 065, 001  SAY   oSayQuebr  PROMPT "Quebrar relatório por:"      SIZE 060, 007 OF oScrollSQL                    PIXEL
		@ 063, 072  MSGET oGetQuebr  VAR    cGetQuebr                     SIZE 100, 007 OF oScrollSQL COLORS 0, 16777215 PIXEL
		
		//Edição de colunas
		@ 075, 001 CHECKBOX oChkEdit   VAR lChkEdit PROMPT "Deseja informar as colunas manualmente?" SIZE 115, 007 OF oScrollSQL COLORS 0, 16777215 PIXEL
		oChkEdit:bChange := {|| fVldChkEdt()}
		oMsGetCam := MsNewGetDados():New(	085,;										//nTop
    											003,;										//nLeft
    											145,;										//nBottom
    											373,;										//nRight
    											GD_INSERT+GD_DELETE+GD_UPDATE,;			//nStyle
    											"AllwaysTrue()",;							//cLinhaOk
    											,;											//cTudoOk
    											"",;										//cIniCpos
    											,;											//aAlter
    											,;											//nFreeze
    											99,;										//nMax
    											,;											//cFieldOK
    											,;											//cSuperDel
    											,;											//cDelOk
    											oScrollSQL,;								//oWnd
    											aHeaderCam,;								//aHeader
    											aColsCam)									//aCols
		oMsGetCam:lActive := .F.
		
		//Totalizadores
		@ 150, 001 CHECKBOX oChkTot   VAR lChkTot PROMPT "Deseja totalizar colunas?" SIZE 115, 007 OF oScrollSQL COLORS 0, 16777215 PIXEL
		oChkTot:bChange := {|| fVldChkTot()}
		oMsGetTot := MsNewGetDados():New(	160,;										//nTop
    											003,;										//nLeft
    											200,;										//nBottom
    											373,;										//nRight
    											GD_INSERT+GD_DELETE+GD_UPDATE,;			//nStyle
    											"AllwaysTrue()",;							//cLinhaOk
    											,;											//cTudoOk
    											"",;										//cIniCpos
    											,;											//aAlter
    											,;											//nFreeze
    											99,;										//nMax
    											,;											//cFieldOK
    											,;											//cSuperDel
    											,;											//cDelOk
    											oScrollSQL,;								//oWnd
    											aHeaderTot,;								//aHeader
    											aColsTot)									//aCols
		oMsGetTot:lActive := .F.
		
		//Ações
		@ (nJanAltu/2)-27, 003	GROUP oGrpAco TO (nJanAltu/2)-1, 	(nJanLarg/2)-1	PROMPT "Ações: "	OF oDlgPvt COLOR 0, 16777215 PIXEL
			
			//Botões
			@ (nJanAltu/2)-21, (nJanLarg/2)-(61*1) BUTTON oBtnFec PROMPT "Fechar" SIZE 058, 017 OF oDlgPvt ACTION(oDlgPvt:End())     PIXEL
			@ (nJanAltu/2)-21, (nJanLarg/2)-(61*2) BUTTON oBtnFec PROMPT "Gerar" SIZE 058, 017 OF oDlgPvt ACTION(fGerar())     PIXEL
			
		//Mudando o foco para user function
		oGetUserF:SetFocus()
	ACTIVATE MSDIALOG oDlgPvt CENTERED

    DbSelectArea( _cAliasSX3 )
    DbCloseArea()

	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fVldDir                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/12/2016                                                   |
 | Desc:  Função que valida o diretório digitado                       |
 *---------------------------------------------------------------------*/

Static Function fVldDir()
	Local lRet := .T.
	
	//Se tiver em branco, já retorna falha
	If Empty(cGetDirec)
		MsgAlert("Preencha um diretório")
		lRet := .F.
		
	Else
		//Se o diretório não existir
		If ! ExistDir(cGetDirec)
			//Se for confirmado tenta criar
			If MsgYesNo("O diretório informado não existe, deseja criar?", "Atenção")
				MakeDir(cGetDirec)
				
				//Se mesmo assim o diretório não existir, retorna falso
				If ! ExistDir(cGetDirec)
					MsgAlert("Não foi possível criar o diretório.", "Atenção")
					lRet := .F.
				EndIf
				
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	//Se for retornar exito
	If lRet
		cGetDirec := Alltrim(cGetDirec)
		
		//Tratamento para adicionar barra
		If SubStr(cGetDirec, Len(cGetDirec), 1) != '\'
			cGetDirec += '\'
		EndIf
		
		//Tratamento para adicionar espaços em branco
		cGetDirec := PadR(cGetDirec, nLenDirec)
		oGetDirec:Refresh()
	EndIf
Return lRet

/*---------------------------------------------------------------------*
 | Func:  fVldPer                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/12/2016                                                   |
 | Desc:  Função que valida se utilizará pergunta / parâmetros         |
 *---------------------------------------------------------------------*/

Static Function fVldPer()
	Local lRet := .T.
	
	//Se vai utilizar, habilita componentes
	If cCmbUtili == 'S'
		oGetPergu:lActive := .T.
		oCmbMostr:lActive := .T.
		
	//Senão, desabilita
	Else
		oGetPergu:lActive := .F.
		oCmbMostr:lActive := .F.
	EndIf
	
	//Atualiza os componentes
	oGetPergu:Refresh()
	oCmbMostr:Refresh()
	oGetPergu:SetFocus()
Return lRet

/*---------------------------------------------------------------------*
 | Func:  fVldEma                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/12/2016                                                   |
 | Desc:  Função que valida se utilizará disparo por e-Mail            |
 *---------------------------------------------------------------------*/

Static Function fVldEma()
	Local lRet := .T.
	
	//Se vai utilizar, habilita componentes
	If cCmbEnvia == 'S'
		oGetEmail:lActive := .T.
		
	//Senão, desabilita
	Else
		oGetEmail:lActive := .F.
	EndIf
	
	//Atualiza os componentes
	oGetEmail:Refresh()
	oGetEmail:SetFocus()
Return lRet

/*---------------------------------------------------------------------*
 | Func:  fVldSQL                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/12/2016                                                   |
 | Desc:  Função que valida a query SQL digitada                       |
 *---------------------------------------------------------------------*/

Static Function fVldSQL()
	Local lRet := .T.
	
	//Atualiza o texto
	cEditSQL := Upper(oEditSQL:RetText())
	oEditSQL:Load(cEditSQL)
	oEditSQL:Refresh()
Return lRet

/*---------------------------------------------------------------------*
 | Func:  fVldChkEdt                                                   |
 | Autor: Daniel Atilio                                                |
 | Data:  17/12/2016                                                   |
 | Desc:  Função que valida o check de edição                          |
 *---------------------------------------------------------------------*/

Static Function fVldChkEdt()
	Local lRet := .T.
	
	//Se tiver checado que irá informar as colunas
	If lChkEdit
		oMsGetCam:lActive := .T.
		
	//Senão
	Else
		oMsGetCam:lActive := .F.
	EndIf
	
	oMsGetCam:Refresh()
Return lRet

/*---------------------------------------------------------------------*
 | Func:  fVldChkTot                                                   |
 | Autor: Daniel Atilio                                                |
 | Data:  17/12/2016                                                   |
 | Desc:  Função que valida o check de totalizadores                   |
 *---------------------------------------------------------------------*/

Static Function fVldChkTot()
	Local lRet := .T.
	
	//Se tiver checado que irá informar as colunas
	If lChkTot
		oMsGetTot:lActive := .T.
		
	//Senão
	Else
		oMsGetTot:lActive := .F.
	EndIf
	
	oMsGetTot:Refresh()
Return lRet

/*---------------------------------------------------------------------*
 | Func:  fGerar                                                       |
 | Autor: Daniel Atilio                                                |
 | Data:  17/12/2016                                                   |
 | Desc:  Função que que valida a geração do arquivo prw               |
 *---------------------------------------------------------------------*/

Static Function fGerar()
	Local nOK := 0
	Local nAtual := 0
	Local aDadCel := oMsGetCam:aCols
	Local nPosCam := aScan(aHeaderCam, {|x| AllTrim(Upper(x[2])) == "XX_CAMPO"})
	Local nPosTam := aScan(aHeaderCam, {|x| Alltrim(Upper(x[2])) == "XX_TAMCP"})
	cEditSQL := Alltrim(Upper(oEditSQL:RetText()))
	
	//Se estiver marcado para utilizar parâmetros, porém a pergunta estiver vazia
	If cCmbUtili == 'S' .And. Empty(cGetPergu)
		MsgAlert("Preencha o código do grupo de perguntas!", "Atenção")
		Return
	EndIf
	
	//Se estiver marcado para enviar email, porém o destinatário estiver vazio
	If cCmbEnvia == 'S' .And. Empty(cGetEmail)
		MsgAlert("Preencha o(s) e-Mail(s) que receberão o relatório!", "Atenção")
		Return
	EndIf
	
	//Se não tiver consulta sql
	If Empty(cEditSQL)
		MsgAlert("Insira uma consulta SQL!", "Atenção")
		Return
	EndIf
	
	//Se for informado manualmente, verifica se tem alguma coluna em branco
	If lChkEdit .And. Len(aDadCel) > 0
		//Percorre os dados
		For nAtual := 1 To Len(aDadCel)
			//Se a linha não estiver excluída
			If ! aDadCel[nAtual][Len(aHeaderCam) + 1]
				//Se tiver campo, incrementa
				If ! Empty(aDadCel[nAtual][nPosCam]) .And. aDadCel[nAtual][nPosTam] != 0
					nOk++
				EndIf
			EndIf
		Next
		
		If nOk == 0
			MsgAlert("Não existem campos válidos para impressão (verifique campo e/ou tamanho)!", "Atenção")
			Return
		EndIf
	EndIf
	
	//Chama a criação do prw
	MsAguarde({|| fCriaPrw()}, "Aguarde...", "Criando o .prw", .T.)
Return

/*---------------------------------------------------------------------*
 | Func:  fCriaPrw                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  17/12/2016                                                   |
 | Desc:  Função que gera o prw com as definições do TOTVS Report      |
 *---------------------------------------------------------------------*/

Static Function fCriaPrw()
	Local cArquivo  := Alltrim(cGetUserF)+".prw"
	Local nHdl      := 0
	Local aStrutAux := {}
	Local aDadCel   := oMsGetCam:aCols
	Local aDadTot   := oMsGetTot:aCols
	Local nAtual    := 0
	//Local aAreaX3   := SX3->(GetArea())
	Local cTitulo   := ""
	Local cPicture  := ""
	Local cTamanho  := ""
	Local cAlinham  := ""
	Local cQuebr    := ""
	Local cFundo    := ""
	Local cFonte    := ""
	Local cNegrito  := ""
	Local cTotal    := ""
	Local cQuebra   := ""
	Local nPos1Cam  := aScan(aHeaderCam, {|x| AllTrim(Upper(x[2])) == "XX_CAMPO"})
	Local nPos1Tit  := aScan(aHeaderCam, {|x| Alltrim(Upper(x[2])) == "XX_TITUL"})
	Local nPos1Pic  := aScan(aHeaderCam, {|x| Alltrim(Upper(x[2])) == "XX_MASCA"})
	Local nPos1Tam  := aScan(aHeaderCam, {|x| Alltrim(Upper(x[2])) == "XX_TAMCP"})
	Local nPos1Ali  := aScan(aHeaderCam, {|x| Alltrim(Upper(x[2])) == "XX_ALINH"})
	//Local nPos1Que  := aScan(aHeaderCam, {|x| Alltrim(Upper(x[2])) == "XX_QUEBR"})
	Local nPos1Fun  := aScan(aHeaderCam, {|x| Alltrim(Upper(x[2])) == "XX_FUNDO"})
	Local nPos1Fon  := aScan(aHeaderCam, {|x| Alltrim(Upper(x[2])) == "XX_FONTE"})
	Local nPos1Neg  := aScan(aHeaderCam, {|x| Alltrim(Upper(x[2])) == "XX_NEGRI"})
	Local nPos2Cam  := aScan(aHeaderTot, {|x| Alltrim(Upper(x[2])) == "XX_CAMPO"})
	Local nPos2Pic  := aScan(aHeaderTot, {|x| Alltrim(Upper(x[2])) == "XX_MASCA"})
	Local nPos2Tot  := aScan(aHeaderTot, {|x| Alltrim(Upper(x[2])) == "XX_TOTAL"})
	Local lFirst    := .T.
	Local aSQL      := StrTokArr(cEditSQL, CRLF)
	
	//Pegando a estrutura da query
	TCQuery cEditSQL New Alias "QRY_AUX"
	aStrutAux := QRY_AUX->(DbStruct())
	QRY_AUX->(DbCloseArea())
	
	//Se o arquivo já existir
	If File(Alltrim(cGetDirec)+cArquivo)
		//Se deseja sobrepor, exclui o arquivo
		If MsgYesNo("Arquivo já existe, deseja sobrepor?", "Atenção")
			fErase(Alltrim(cGetDirec)+cArquivo)
		Else
			Return
		EndIf
	EndIf

	//Cria o arquivo
	nHdl := fCreate(Alltrim(cGetDirec)+cArquivo)
	
	//Se houve algum erro finaliza
	If nHdl < 0
		MsgAlert("Erro ao criar o arquivo: " + cValToChar(fError()))
		
	//Senão gera o conteúdo do arquivo
	Else
		//Cabeçalho
		fWrite(nHdl, '//Bibliotecas' + STR_PULA)
		fWrite(nHdl, '#Include "Protheus.ch"' + STR_PULA)
		fWrite(nHdl, '#Include "TopConn.ch"' + STR_PULA)
		fWrite(nHdl, '	' + STR_PULA)
		fWrite(nHdl, '//Constantes' + STR_PULA)
		fWrite(nHdl, '#Define STR_PULA		Chr(13)+Chr(10)' + STR_PULA)
		fWrite(nHdl, '	' + STR_PULA)
		fWrite(nHdl, '/*/{Protheus.doc} ' + Alltrim(cGetUserF) + STR_PULA)
		fWrite(nHdl, 'Relatório - ' + cGetTitul + STR_PULA)
		fWrite(nHdl, '@author ' + cAutor + STR_PULA)
		fWrite(nHdl, '@since ' + cData + STR_PULA)
		fWrite(nHdl, '@version 1.0' + STR_PULA)
		fWrite(nHdl, '	@example' + STR_PULA)
		fWrite(nHdl, '	u_'+Alltrim(cGetUserF)+'()' + STR_PULA)
		fWrite(nHdl, '	@obs Função gerada pelo zReport()' + STR_PULA)
		fWrite(nHdl, '/*/' + STR_PULA)
		fWrite(nHdl, '	' + STR_PULA)
		
		//Função principal
		fWrite(nHdl, 'User Function '+Alltrim(cGetUserF)+'()' + STR_PULA)
		fWrite(nHdl, '	Local aArea   := GetArea()' + STR_PULA)
		fWrite(nHdl, '	Local oReport' + STR_PULA)
		fWrite(nHdl, '	Local lEmail  := .F.' + STR_PULA)
		fWrite(nHdl, '	Local cPara   := "'+Alltrim(cGetEmail)+'"' + STR_PULA)
		fWrite(nHdl, '	Private cPerg := ""' + STR_PULA)
		
		//Se utilizar grupo de pergunta
		If cCmbUtili == 'S'
			fWrite(nHdl, '	' + STR_PULA)
			fWrite(nHdl, '	//Definições da pergunta' + STR_PULA)
			fWrite(nHdl, '	cPerg := "'+cGetPergu+'"' + STR_PULA)
			fWrite(nHdl, '	' + STR_PULA)
			fWrite(nHdl, '	//Se a pergunta não existir, zera a variável' + STR_PULA)
			fWrite(nHdl, '	DbSelectArea("SX1")' + STR_PULA)
			fWrite(nHdl, '	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM' + STR_PULA)
			fWrite(nHdl, '	If ! SX1->(DbSeek(cPerg))' + STR_PULA)
			fWrite(nHdl, '		cPerg := Nil' + STR_PULA)
			fWrite(nHdl, '	EndIf' + STR_PULA)
		EndIf
		
		//Se utiliza disparo por e-Mail
		If cCmbEnvia == 'S'
			fWrite(nHdl, '	' + STR_PULA)
			fWrite(nHdl, '	//Será enviado por e-Mail' + STR_PULA)
			fWrite(nHdl, '	lEmail := .T.' + STR_PULA)
		EndIf
		
		fWrite(nHdl, '	' + STR_PULA)
		fWrite(nHdl, '	//Cria as definições do relatório' + STR_PULA)
		fWrite(nHdl, '	oReport := fReportDef()' + STR_PULA)
		fWrite(nHdl, '	' + STR_PULA)
		fWrite(nHdl, '	//Será enviado por e-Mail?' + STR_PULA)
		fWrite(nHdl, '	If lEmail' + STR_PULA)
		fWrite(nHdl, '		oReport:nRemoteType := NO_REMOTE' + STR_PULA)
		fWrite(nHdl, '		oReport:cEmail := cPara' + STR_PULA)
		fWrite(nHdl, '		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html' + STR_PULA)
		fWrite(nHdl, '		oReport:SetPreview(.F.)' + STR_PULA)
		fWrite(nHdl, '		oReport:Print(.F., "", .T.)' + STR_PULA)
		fWrite(nHdl, '	//Senão, mostra a tela' + STR_PULA)
		fWrite(nHdl, '	Else' + STR_PULA)
		fWrite(nHdl, '		oReport:PrintDialog()' + STR_PULA)
		fWrite(nHdl, '	EndIf' + STR_PULA)
		fWrite(nHdl, '	' + STR_PULA)
		fWrite(nHdl, '	RestArea(aArea)' + STR_PULA)
		fWrite(nHdl, 'Return' + STR_PULA)
		fWrite(nHdl, '	' + STR_PULA)
		
		//Definições do relatório
		fWrite(nHdl, '/*-------------------------------------------------------------------------------*' + STR_PULA)
		fWrite(nHdl, ' | Func:  fReportDef                                                             |' + STR_PULA)
		fWrite(nHdl, ' | Desc:  Função que monta a definição do relatório                              |' + STR_PULA)
		fWrite(nHdl, ' *-------------------------------------------------------------------------------*/' + STR_PULA)
		fWrite(nHdl, '	' + STR_PULA)
		fWrite(nHdl, 'Static Function fReportDef()' + STR_PULA)
		fWrite(nHdl, '	Local oReport' + STR_PULA)
		fWrite(nHdl, '	Local oSectDad := Nil' + STR_PULA)
		fWrite(nHdl, '	Local oBreak := Nil' + STR_PULA)
		
		//Se tiver totalizadores
		If lChkTot .And. Len(aDadTot) > 0
			For nAtual := 1 To Len(aDadTot)
				//Se tiver campo válido
				If !Empty(aDadTot[nAtual][nPos2Cam])
					fWrite(nHdl, '	Local oFunTot'+cValToChar(nAtual)+' := Nil' + STR_PULA)
				EndIf
			Next
		EndIf
		
		fWrite(nHdl, '	' + STR_PULA)
		fWrite(nHdl, '	//Criação do componente de impressão' + STR_PULA)
		fWrite(nHdl, '	oReport := TReport():New(	"'+Alltrim(cGetUserF)+'",;		//Nome do Relatório' + STR_PULA)
		fWrite(nHdl, '								"'+Alltrim(cGetTitul)+'",;		//Título' + STR_PULA)
		fWrite(nHdl, '								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101' + STR_PULA)
		fWrite(nHdl, '								{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão' + STR_PULA)
		fWrite(nHdl, '								)		//Descrição' + STR_PULA)
		fWrite(nHdl, '	oReport:SetTotalInLine(.F.)' + STR_PULA)
		fWrite(nHdl, '	oReport:lParamPage := .F.' + STR_PULA)
		fWrite(nHdl, '	oReport:oPage:SetPaperSize(9) //Folha A4' + STR_PULA)
		
		//Se for Retrato
		If cCmbOrien == 'R'
			fWrite(nHdl, '	oReport:SetPortrait()' + STR_PULA)
		
		//Se for Paisagem
		ElseIf cCmbOrien == 'P'
			fWrite(nHdl, '	oReport:SetLandscape()' + STR_PULA)
		EndIf
		
		//Se a fonte for tamanho 8
		If cCmbFonte == '1'
			fWrite(nHdl, '	oReport:SetLineHeight(50)' + STR_PULA)
			fWrite(nHdl, '	oReport:nFontBody := 08' + STR_PULA)
		
		//Se a fonte for tamanho 12
		ElseIf cCmbFonte == '2'
			fWrite(nHdl, '	oReport:SetLineHeight(60)' + STR_PULA)
			fWrite(nHdl, '	oReport:nFontBody := 12' + STR_PULA)
		EndIf
		fWrite(nHdl, '	' + STR_PULA)
		fWrite(nHdl, '	//Criando a seção de dados' + STR_PULA)
		fWrite(nHdl, '	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence' + STR_PULA)
		fWrite(nHdl, '									"Dados",;		//Descrição da seção' + STR_PULA)
		fWrite(nHdl, '									{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção' + STR_PULA)
		fWrite(nHdl, '	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha' + STR_PULA)
		fWrite(nHdl, '	' + STR_PULA)
		fWrite(nHdl, '	//Colunas do relatório' + STR_PULA)
		
		//Se foi informado as colunas manualmente
		If lChkEdit .And. Len(aDadCel) > 0
			//Percorre os dados informados pelo usuário
			For nAtual := 1 To Len(aDadCel)
				//Se a linha não estiver excluída
				If ! aDadCel[nAtual][Len(aHeaderCam) + 1]
					//Se tiver campo, adiciona um trcell
					If ! Empty(aDadCel[nAtual][nPos1Cam])
					
						//Tratamento para o título
						If !Empty(aDadCel[nAtual][nPos1Tit])
							cTitulo   := Alltrim(aDadCel[nAtual][nPos1Tit])
						Else
							cTitulo   := Capital(Alltrim(aDadCel[nAtual][nPos1Cam]))
						EndIf
						
						//Tratamento para a máscara
						If !Empty(aDadCel[nAtual][nPos1Pic])
							cPicture  := '"'+Alltrim(aDadCel[nAtual][nPos1Pic])+'"'
						Else
							cPicture  := "/*cPicture*/"
						EndIf
						
						//Tratamento para o tamanho
						cTamanho := cValToChar(aDadCel[nAtual][nPos1Tam])
						
						//Tratamento para alinhamento
						If aDadCel[nAtual][nPos1Ali] != '0'
							If aDadCel[nAtual][nPos1Ali] == '1'
								cAlinham := '"LEFT"'
							ElseIf aDadCel[nAtual][nPos1Ali] == '2'
								cAlinham := '"RIGHT"'
							Else
								cAlinham := '"CENTER"'
							EndIf
						Else
							cAlinham := "/*cAlign*/"
						EndIf
						
						//Tratamento para quebra de linha
						If aDadCel[nAtual][nPos1Ali] == 'S'
							cQuebr := ".T."
						Else
							cQuebr := "/*lLineBreak*/"
						EndIf
						
						//Tratamento para cor de fundo
						If aDadCel[nAtual][nPos1Fun] != '0'
							If aDadCel[nAtual][nPos1Fun] == '1'
								cFundo := "RGB(000,000,000)"
							ElseIf aDadCel[nAtual][nPos1Fun] == '2'
								cFundo := "RGB(254,254,254)"
							ElseIf aDadCel[nAtual][nPos1Fun] == '3'
								cFundo := "RGB(255,000,000)"
							ElseIf aDadCel[nAtual][nPos1Fun] == '4'
								cFundo := "RGB(000,255,000)"
							Else
								cFundo := "RGB(000,000,255)"
							EndIf
						Else
							cFundo := "/*nClrBack*/"
						EndIf
						
						//Tratamento para cor da fonte
						If aDadCel[nAtual][nPos1Fon] != '0'
							If aDadCel[nAtual][nPos1Fon] == '1'
								cFonte := "RGB(000,000,000)"
							ElseIf aDadCel[nAtual][nPos1Fon] == '2'
								cFonte := "RGB(254,254,254)"
							ElseIf aDadCel[nAtual][nPos1Fon] == '3'
								cFonte := "RGB(255,000,000)"
							ElseIf aDadCel[nAtual][nPos1Fon] == '4'
								cFonte := "RGB(000,255,000)"
							Else
								cFonte := "RGB(000,000,255)"
							EndIf
						Else
							cFonte := "/*nClrFore*/"
						EndIf
						
						//Tratamento para negrito
						If aDadCel[nAtual][nPos1Neg] == 'S'
							cNegrito := ".T."
						Else
							cNegrito := "/*lBold*/"
						EndIf
						
						fWrite(nHdl, '	TRCell():New(oSectDad, '+;
							'"'+Alltrim(aDadCel[nAtual][nPos1Cam])+'", '+;
							'"QRY_AUX", '+;
							'"'+cTitulo+'", '+;
							cPicture+', '+;
							cTamanho+', '+;
							'/*lPixel*/,'+;
							'/*{|| code-block de impressao }*/,'+;
							cAlinham+','+;
							cQuebr+','+;
							'/*cHeaderAlign */,'+;
							'/*lCellBreak*/,'+;
							'/*nColSpace*/,'+;
							'/*lAutoSize*/,'+;
							cFundo+','+;
							cFonte+','+;
							cNegrito+')' + STR_PULA)
					EndIf
				EndIf
			Next
		
		//Senão, pega todas da estrutura da query
		Else
			//LGS#20200207 - Adequação de release 12.1.25 e posteriores
			/*
			DbSelectArea('SX3')
			SX3->(DbSetOrder(2)) //X3_CAMPO
		    */
		    DbSelectArea( _cAliasSX3 )
		    ( _cAliasSX3 )->( DbSetOrder(2) )
			//Percorre a estrutura
			For nAtual := 1 To Len(aStrutAux)
				//Se conseguir posicionar no campo
				//LGS#20200207 - Adequação de release 12.1.25 e posteriores
				//If SX3->(DbSeek(aStrutAux[nAtual][1]))
				If ( _cAliasSX3 )->( DbSeek( aStrutAux[nAtual][1] ) )
					//cTitulo := Alltrim(SX3->X3_TITULO)
					cTitulo := Alltrim( ( _cAliasSX3 )->( X3_TITULO ) )
				Else
					cTitulo := Capital(Alltrim(aStrutAux[nAtual][1]))
				EndIf
				
				fWrite(nHdl, '	TRCell():New(oSectDad, '+;
					'"'+Alltrim(aStrutAux[nAtual][1])+'", '+;
					'"QRY_AUX", '+;
					'"'+cTitulo+'", '+;
					'/*Picture*/, '+;
					cValToChar(aStrutAux[nAtual][3])+', '+;
					'/*lPixel*/,'+;
					'/*{|| code-block de impressao }*/,'+;
					'/*cAlign*/,'+;
					'/*lLineBreak*/,'+;
					'/*cHeaderAlign */,'+;
					'/*lCellBreak*/,'+;
					'/*nColSpace*/,'+;
					'/*lAutoSize*/,'+;
					'/*nClrBack*/,'+;
					'/*nClrFore*/,'+;
					'/*lBold*/)' + STR_PULA)
			Next
		EndIf
		
		//Se tiver quebra
		If !Empty(cGetQuebr)
			fWrite(nHdl, '	' + STR_PULA)
			fWrite(nHdl, '	//Definindo a quebra' + STR_PULA)
			fWrite(nHdl, '	oBreak := TRBreak():New(oSectDad,{|| QRY_AUX->('+Alltrim(cGetQuebr)+') },{|| "SEPARACAO DO RELATORIO" })' + STR_PULA)
			fWrite(nHdl, '	oSectDad:SetHeaderBreak(.T.)' + STR_PULA)
			cQuebra := "oBreak"
		Else
			cQuebra := ""
		EndIf
		
		//Se tiver totalizadores
		If lChkTot .And. Len(aDadTot) > 0
			fWrite(nHdl, '	' + STR_PULA)
			For nAtual := 1 To Len(aDadTot)
				//Se tiver campo válido
				If !Empty(aDadTot[nAtual][nPos2Cam])
					If lFirst
						fWrite(nHdl, '	//Totalizadores' + STR_PULA)
						lFirst := .F.
					EndIf
					
					//Tratamento para a máscara
					If !Empty(aDadTot[nAtual][nPos2Pic])
						cPicture  := '"'+Alltrim(aDadTot[nAtual][nPos2Pic])+'"'
					Else
						cPicture  := "/*cPicture*/"
					EndIf
					
					//Tratamento para o total
					If aDadTot[nAtual][nPos2Tot] == '0'
						cTotal := '"SUM"'
					ElseIf aDadTot[nAtual][nPos2Tot] == '1'
						cTotal := '"COUNT"'
					ElseIf aDadTot[nAtual][nPos2Tot] == '2'
						cTotal := '"MAX"'
					ElseIf aDadTot[nAtual][nPos2Tot] == '3'
						cTotal := '"MIN"'
					Else
						cTotal := '"AVERAGE"'
					EndIf
					
					//Adiciona a função
					fWrite(nHdl, '	oFunTot'+cValToChar(nAtual)+' := TRFunction():New(oSectDad:Cell("'+Alltrim(aDadTot[nAtual][nPos2Cam])+'"),,'+cTotal+','+cQuebra+',,'+cPicture+')' + STR_PULA)
					fWrite(nHdl, '	oFunTot'+cValToChar(nAtual)+':SetEndReport(.F.)' + STR_PULA)
				EndIf
			Next
		EndIf
	
		fWrite(nHdl, 'Return oReport' + STR_PULA)
		fWrite(nHdl, '	' + STR_PULA)
		
		//Impressão do relatório
		fWrite(nHdl, '/*-------------------------------------------------------------------------------*' + STR_PULA)
		fWrite(nHdl, ' | Func:  fRepPrint                                                              |' + STR_PULA)
		fWrite(nHdl, ' | Desc:  Função que imprime o relatório                                         |' + STR_PULA)
		fWrite(nHdl, ' *-------------------------------------------------------------------------------*/' + STR_PULA)
		fWrite(nHdl, '	' + STR_PULA)
		fWrite(nHdl, 'Static Function fRepPrint(oReport)' + STR_PULA)
		fWrite(nHdl, '	Local aArea    := GetArea()' + STR_PULA)
		fWrite(nHdl, '	Local cQryAux  := ""' + STR_PULA)
		fWrite(nHdl, '	Local oSectDad := Nil' + STR_PULA)
		fWrite(nHdl, '	Local nAtual   := 0' + STR_PULA)
		fWrite(nHdl, '	Local nTotal   := 0' + STR_PULA)
		fWrite(nHdl, '	' + STR_PULA)
		fWrite(nHdl, '	//Pegando as seções do relatório' + STR_PULA)
		fWrite(nHdl, '	oSectDad := oReport:Section(1)' + STR_PULA)
		fWrite(nHdl, '	' + STR_PULA)
		fWrite(nHdl, '	//Montando consulta de dados' + STR_PULA)
		
		//Percorrendo a consulta sql
		fWrite(nHdl, '	cQryAux := ""' + STR_PULA)
		For nAtual := 1 To Len(aSQL)
			fWrite(nHdl, '	cQryAux += "'+(aSQL[nAtual])+'"		+ STR_PULA' + STR_PULA)
		Next
		fWrite(nHdl, '	cQryAux := ChangeQuery(cQryAux)' + STR_PULA)
		fWrite(nHdl, '	' + STR_PULA)
		
		fWrite(nHdl, '	//Executando consulta e setando o total da régua' + STR_PULA)
		fWrite(nHdl, '	TCQuery cQryAux New Alias "QRY_AUX"' + STR_PULA)
		fWrite(nHdl, '	Count to nTotal' + STR_PULA)
		fWrite(nHdl, '	oReport:SetMeter(nTotal)' + STR_PULA)
		
		DbSelectArea('SX3')
		SX3->(DbSetOrder(2)) //X3_CAMPO
		SX3->(DbGoTop())
		
		//Percorre a estrutura
		For nAtual := 1 To Len(aStrutAux)
			//Se conseguir posicionar no campo
			//LGS#20200207 - Adequação de release 12.1.25 e posteriores
			//If SX3->(DbSeek(aStrutAux[nAtual][1]))
			If ( _cAliasSX3 )->( DbSeek(aStrutAux[nAtual][1] ) )
				//Se for campo do tipo data
				//If SX3->X3_TIPO == 'D'
				If ( _cAliasSX3 )->( X3_TIPO ) == 'D'
					fWrite(nHdl, '	TCSetField("QRY_AUX", "'+Alltrim(aStrutAux[nAtual][1])+'", "D")' + STR_PULA)
				EndIf
			EndIf
		Next
		fWrite(nHdl, '	' + STR_PULA)
		
		fWrite(nHdl, '	//Enquanto houver dados' + STR_PULA)
		fWrite(nHdl, '	oSectDad:Init()' + STR_PULA)
		fWrite(nHdl, '	QRY_AUX->(DbGoTop())' + STR_PULA)
		fWrite(nHdl, '	While ! QRY_AUX->(Eof())' + STR_PULA)
		fWrite(nHdl, '		//Incrementando a régua' + STR_PULA)
		fWrite(nHdl, '		nAtual++' + STR_PULA)
		fWrite(nHdl, '		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")' + STR_PULA)
		fWrite(nHdl, '		oReport:IncMeter()' + STR_PULA)
		fWrite(nHdl, '		' + STR_PULA)
		fWrite(nHdl, '		//Imprimindo a linha atual' + STR_PULA)
		fWrite(nHdl, '		oSectDad:PrintLine()' + STR_PULA)
		fWrite(nHdl, '		' + STR_PULA)
		fWrite(nHdl, '		QRY_AUX->(DbSkip())' + STR_PULA)
		fWrite(nHdl, '	EndDo' + STR_PULA)
		fWrite(nHdl, '	oSectDad:Finish()' + STR_PULA)
		fWrite(nHdl, '	QRY_AUX->(DbCloseArea())' + STR_PULA)
		fWrite(nHdl, '	' + STR_PULA)
		fWrite(nHdl, '	RestArea(aArea)' + STR_PULA)
		fWrite(nHdl, 'Return' + STR_PULA)
		fClose(nHdl)
		
		//Se o arquivo foi criado
		If File(Alltrim(cGetDirec)+cArquivo)
			If MsgYesNo("Arquivo gerado, deseja visualizar?", "Atenção")
				ShellExecute("open", cArquivo, "", Alltrim(cGetDirec), 1)
			EndIf
		EndIf
	EndIf
	
	//RestArea(aAreaX3)
Return