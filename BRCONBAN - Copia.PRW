//#include "rwmake.ch"
#include "PROTHEUS.CH"
#include "Fileio.ch"
#include "TBICONN.CH"
#include "topconn.ch"
#include "COLORS.CH"
#include "RPTDEF.CH"
#include "FWPrintSetup.ch"
#include "font.ch"
#include "PROTHEUS.CH"
#include "RPTDEF.CH"

/*/{Protheus.doc} BRCONBAN
Programa que exibe as informações salvas na tabela ZAK -  Comprovantes de Pagamento Bradesco
@type function Menu
@version  1.00
@author marioantonaccio
@since 20/07/2026
@return character, sem retorno
/*/
User Function BRCONBAN()
	Local aArea       := FWGetArea()                    as array
	Local oBrowse                                       as object
	Private aRotina   := {}                             as array
	Private cCadastro := "Extrator de Retorno Bancario" as character
	Private cCGCAtu   := ""                             as character
	Private cString   := "ZAK"                          as character

	//Aviso( 'VarInfo', VarInfo('xEmpFil', totvs.framework.company.xEmpFil("SE1","01","010106") , , .F. ) ,{'ok'} ,4,,,, .T.)
	aRotina := MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZAK")
	oBrowse:SetDescription(cCadastro)
	oBrowse:DisableDetails()

	oBrowse:Activate()
	FWRestArea(aArea)

Return (Nil)

/*/{Protheus.doc} MenuDef
Opções de Menu
@type function Tela
@version  1.00
@author marioantonaccio
@since 20/07/2026
@return array, opções que podem ser acessadas
/*/
Static Function MenuDef()
	Local aRotina := {}

	aadd(aRotina, {"Visualizar", "AXVISUAL"    , 0, 2})
	aadd(aRotina, {"Pesquisar" , "U_BRCONBRA()", 0, 2})
	aadd(aRotina, {"Importar"  , "U_BRPAGRET()", 0, 3})

Return (aRotina)

/*/{Protheus.doc} BRCONBRA
Programa que faz a consulta e exibe a informação salva na tabela ZAK
@type function Tela
@version  1.00
@author marioantonaccio
@since 20/07/2026
@return character, sem retorno
/*/
User Function BRCONBRA()

    Private aButtons := {}                  as array
    Private aSays    := {}                  as array
    Private cCPF     := ""                  as character
    Private cFunci   := ""                  as character
    Private cNomRel  := ""                  as character
    Private cQry     := ""                  as character
    Private cTitulo  := "CONSULTA BRADESCO" as character
    Private lParam   := .F.                 as logical

    AADD(aSays, "Informe o CPF do funcionário para buscar suas informações!")

    AADD(aButtons, {5, .T., {||  xParamBox()           }})
    AADD(aButtons, {1, .T., {|o| fBusca(o)             }})
    AADD(aButtons, {2, .T., {|o| dbCloseArea(), MS_Flush(), o:oWnd:End()}})

    FormBatch(cTitulo, aSays, aButtons,, 200, 405)

Return (NIL)

/*/{Protheus.doc} fBusca
Rotina de Busca - Objeto
@type function Processamento
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param o, object, Objeto que permite digitação apra busaca
@return character, sem retorno
/*/
Static Function fBusca(o)
    If ConsArq()
        o:oWnd:End()
    EndIf
Return (NIL)

/*/{Protheus.doc} fMontaQry
Mota query de pesquisa 
@type function Processamento
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param cCPFParam, character, informação a ser pesquisada
@return character, query montada
/*/
Static Function fMontaQry(cCPFParam)
    Local cQ := ""
    cQ := "    SELECT DISTINCT                          " + CRLF
    cQ += "    ZAK.ZAK_FUNCPF  AS CPF,                  " + CRLF
    cQ += "    ZAK.ZAK_FUNNOM  AS NOME,                 " + CRLF
    cQ += "    ZAK.ZAK_FUNCON  AS CONTA,                " + CRLF
    cQ += "    ZAK.ZAK_FUNAGE  AS AGENCIA,              " + CRLF
    cQ += "    ZAK.ZAK_FUNBAN  AS BANCO,                " + CRLF
    cQ += "    ZAK.ZAK_FUNTIP  AS TIPO                  " + CRLF
    cQ += "    FROM " + RetSqlName("ZAK") + " ZAK       " + CRLF
    cQ += "    WHERE ZAK.D_E_L_E_T_ = ' '               " + CRLF
    cQ += "    AND ZAK.ZAK_FUNCPF = '" + cCPFParam + "' " + CRLF
    cQ += "    ORDER BY NOME                            " + CRLF
Return (cQ)

/*/{Protheus.doc} ConsArq
Executa a Consulta
@type function Processamento
@version  1.00
@author marioantonaccio
@since 20/07/2026
@return object, inicia o processo
/*/
Static Function ConsArq()
    Local aDados := {}             as array
    Local cAlias := GetNextAlias() as character

    If .NOT. lParam
        MsgAlert("Parâmetros não informados, consulta cancelada.")
        Return .F.
    EndIf

    cCPF := fLimpaCPF(cFunci)

    If Empty(cCPF)
        MsgAlert("CPF não informado, consulta cancelada.")
        Return .F.
    EndIf

    cQry := fMontaQry(cCPF)

    If Select(cAlias) <> 0
        (cAlias)->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,, cQry), cAlias, .F., .T.)
    DbSelectArea(cAlias)
  
    While !Eof()
        AAdd(aDados, {;
            AllTrim((cAlias)->CPF)    ,;
            AllTrim((cAlias)->NOME)   ,;
            AllTrim((cAlias)->CONTA)  ,;
            AllTrim((cAlias)->AGENCIA),;
            AllTrim((cAlias)->BANCO)  ,;
            AllTrim((cAlias)->TIPO)   ;
            })
        DbSkip()
    EndDo

    (cAlias)->(dbCloseArea())

Return (fMostDados(aDados, cFunci))

/*/{Protheus.doc} xParamBox
Tela de pesquisa
@type function Tela
@version  1.00
@author marioantonaccio
@since 20/07/2026
@return character, sem retorno
/*/
Static Function xParamBox()
    Local aParambox := {} as array
    Local aRet      := {} as array

    AADD(aParambox, {1, "Funcionário (CPF)", Space(14), "", "", "ZAK", "", 0, .F.})

    If Parambox(aParambox, "Informe o CPF", @aRet)
        cFunci := AllTrim(aRet[1])
        lParam := .T.
    Else
        lParam := .F.
    EndIf
Return (NIL)

/*/{Protheus.doc} fMostDados
Mostra dados de Pesquisa
@type function Tela
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param aDados, array, Array com Dados
@param cFunci, character, CPF do funcionário
@return logical, indica se fecha a pesquisa
/*/
Static Function fMostDados(aDados, cFunci)
    Local cBrw      := ""  as character
    Local lFechaIni := .T. as logical
    Local lVolta    := .F. as logical
    Local oBrw             as object
    Local oBtnExp          as object
    Local oBtnSai          as object
    Local oBtnVol          as object
    Local oDlg             as object

    If Len(aDados) == 0
        ApMsgStop("Funcionário sem informações cadastradas.")
        fLimpaParam()
        Return .F.
    EndIf

    DEFINE MSDIALOG oDlg ;
        TITLE OemToAnsi("Folha de Pagamento - " + AllTrim(cFunci)) ;
        From 000, 000 To 290, 900 PIXEL

    @ 005, 005 LISTBOX oBrw VAR cBrw ;
        FIELDS HEADER "CPF", "NOME", "CONTA", "AGENCIA", "BANCO", "TIPO" ;
        SIZE 440, 125 OF oDlg PIXEL

    oBrw:SetArray(aDados)
    oBrw:bLine := {|| {;
        fMaskCPF(aDados[oBrw:nAt][1]),;
        OemToAnsi(aDados[oBrw:nAt][2]),;
        aDados[oBrw:nAt][3],;
        aDados[oBrw:nAt][4],;
        aDados[oBrw:nAt][5],;
        aDados[oBrw:nAt][6];
        }}
    oBrw:lAdjustColSize := .T.
    oDlg:nStyle := nOR(DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE)

    @ 132, 005 BUTTON oBtnVol PROMPT "Voltar"   SIZE 070, 013 OF oDlg ACTION (lVolta := .T., oDlg:End()) PIXEL
    @ 132, 080 BUTTON oBtnExp PROMPT "Exportar" SIZE 055, 013 OF oDlg ACTION fRelFun(aDados, cFunci) PIXEL
    @ 132, 385 BUTTON oBtnSai PROMPT "Sair"     SIZE 050, 013 OF oDlg ACTION (fLimpaParam(), lFechaIni := .F., oDlg:End()) PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

    If lVolta
        xParamBox()
        If lParam
            Return ConsArq()
        EndIf
        fLimpaParam()
        Return .F.
    EndIf
Return (lFechaIni)

/*/{Protheus.doc} fRelFun
Relatório do Funcionário
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param aDados, array, Array com Dados
@param cFunci, character, CPF do funcionário
@return character, sem retorno
/*/
Static Function fRelFun(aDados, cFunci)
    Local oReport := Nil as object

    If Len(aDados) == 0
        MsgAlert(OemToAnsi("Nenhum dado para exportar."))
        Return
    EndIf

    cCPF := aDados[1][1]
    cNomRel := OemToAnsi(AllTrim(cFunci))

    oReport := fDefRelFun()
    oReport:PrintDialog()

    cCPF := ""
    cNomRel := ""
Return (NIL)

/*/{Protheus.doc} fDefRelFun
Imprime Comprovante
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 20/07/2026
@return Object, obejto do relatorio
/*/
Static Function fDefRelFun()
    Local oReport  := Nil as object
    Local oSection := Nil as object

    oReport := TReport():New( ;
        "BRCRELFUN",;
        OemToAnsi("Detalhe do Pagamento - Crédito em Conta Salário"),;
        ,;
        {|oRpt| fPrnRelFun(oRpt)},;
        OemToAnsi("Funcionário: " + cNomRel) ;
        )

    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .F.
    oReport:oPage:SetPaperSize(9)
    oReport:SetPortrait()
    oReport:SetLineHeight(50)
    oReport:nFontBody := 10

    oSection := TRSection():New(oReport, OemToAnsi("Dados do Funcionário"), {"QRY_ZAKREL"})
    oSection:SetTotalInLine(.F.)

    TRCell():New(oSection, "CPF"    , "QRY_ZAKREL", "CPF"              ,, 20,,, "LEFT",,,,, .F.,,, .T.)
    TRCell():New(oSection, "NOME"   , "QRY_ZAKREL", OemToAnsi("Nome")  ,, 50,,, "LEFT",,,,, .F.,,, .F.)
    TRCell():New(oSection, "BANCO"  , "QRY_ZAKREL", "Banco"            ,, 10,,, "LEFT",,,,, .F.,,, .F.)
    TRCell():New(oSection, "AGENCIA", "QRY_ZAKREL", OemToAnsi("Agência"),, 10,,, "LEFT",,,,, .F.,,, .F.)
    TRCell():New(oSection, "CONTA"  , "QRY_ZAKREL", "Conta"            ,, 20,,, "LEFT",,,,, .F.,,, .F.)
    TRCell():New(oSection, "TIPO"   , "QRY_ZAKREL", "Tipo"             ,, 15,,, "LEFT",,,,, .F.,,, .F.)

Return (oReport)

/*/{Protheus.doc} fPrnRelFun
Executa o relatorio
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param oReport, object, obejto do relatorio
@return character, sem retorno
/*/
Static Function fPrnRelFun(oReport)
    Local aArea  := FWGetArea() as array
    Local nAtual := 0           as numeric
    Local nTotal := 0           as numeric
    Local oSect  := Nil         as object

    oSect := oReport:Section(1)

    If Select("QRY_ZAKREL") <> 0
        dbSelectArea("QRY_ZAKREL")
        dbCloseArea()
    EndIf

    PlsQuery(cQry, "QRY_ZAKREL")
    dbSelectArea("QRY_ZAKREL")
    Count To nTotal
    oReport:SetMeter(nTotal)

    oSect:Init()
    QRY_ZAKREL->(dbGoTop())
    While !QRY_ZAKREL->(Eof())
        nAtual++
        oReport:SetMsgPrint(OemToAnsi("Imprimindo " + cValToChar(nAtual) + " de " + cValToChar(nTotal)))
        oReport:IncMeter()
        oSect:PrintLine()
        QRY_ZAKREL->(dbSkip())
    EndDo
    oSect:Finish()
    QRY_ZAKREL->(dbCloseArea())

    FWRestArea(aArea)
Return (NIL)

/*/{Protheus.doc} fLimpaParam
Limpa totalmente os parametros caso o funcionario não tenha dados 
assim já volta vazia para uma nova consulta
@type function Tela
@version  1.00
@author marioantonaccio
@since 20/07/2026
@return Character, sem retorno
/*/
Static Function fLimpaParam()
    cCPF   := ""  
    cFunci := ""   
    cQry   := ""   
    lParam := .F.  
Return (NIL)


/*/{Protheus.doc} fMaskCPF
Mascara para usar no CPF
@type function Processamento
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param cCPFParam, character, CPF para consulta
@return character, Varaivel de CPF com mascara
/*/
Static Function fMaskCPF(cCPFParam)
    Local cRet := AllTrim(cCPFParam) as character
    If Len(cRet) == 11
        cRet := SubStr(cRet,1,3) + "." + SubStr(cRet,4,3) + "." + SubStr(cRet,7,3) + "-" + SubStr(cRet,10,2)
    EndIf
Return (cRet)

/*/{Protheus.doc} fLimpaCPF
Verifica se o CPF esta vazio ou se tem a quantidade de caracteres e após isso limpa a formatação
@type function Tela
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param cCPFParam, character, CPF para consulta
@return character, Variavel do CPF
/*/
Static Function fLimpaCPF(cCPFParam)
    Local cRet  := AllTrim(StrTran(StrTran(StrTran(cCPFParam, ".", ""), "-", ""), " ", "")) as characer
    Local cTemp := ""                                                                       as character
    Local nI    := 0                                                                        as numeric

    For nI := 1 To Len(cRet)
        If SubStr(cRet, nI, 1) >= "0" .And. SubStr(cRet, nI, 1) <= "9"
            cTemp += SubStr(cRet, nI, 1)
        EndIf
    Next nI

    If Len(cTemp) <> 11 .Or. Empty(cTemp)
        Return ""
    EndIf
Return (cTemp)

/*/{Protheus.doc} BRPAGRET
Programa que le o arquivo de retorno de pagamento bancario (.ret),
extrai os dados dos blocos A/B/Z e gera um CSV com:
  - Conta bancaria (sem zeros a esquerda)
  - Nome do favorecido
  - Tipo de pagamento (ADI / FER / FOL / RSC)
  - Data de lancamento (DD/MM/AAAA)
  - Data de credito    (DD/MM/AAAA)
  - Valor com centavos (R$)
  - Autenticacao bancaria (linha Z)
Funcionalidades adicionais:
  - Pesquisa de arquivo via cGetFile com diretorio de rede pre-definido
  - Filtro opcional por nome do favorecido (parcial, sem distincao de maiusculas)
Layout do arquivo retorno (posicoes 1-based):
  Linha A:
    [01-13] Cabecalho sequencial
    [14]    Tipo de registro = 'A'
    [15-45] Conta bancaria (30 chars)
    [43-73] Nome do favorecido (31 chars)
    [74-76] Tipo de pagamento  (ADI/FER/FOL/RSC)
    [94-101] Data de lancamento (DDMMAAAA)
    [120-134] Valor (15 digitos inteiros / 100 = valor com centavos)
    [155-162] Data de credito (DDMMAAAA)
  Linha Z:
    [14]    Tipo de registro = 'Z'
    Primeira sequencia numerica >= 10 digitos apos pos 14 = autenticacao
@type function Processamento
@version 1.00
@author marioantonaccio
@since 08/04/2026
@return character, sem retorno
/*/
User Function BRPAGRET()

	Local cMsgIntro := "" as character
	Private cCGCAtu := "" as character

	cMsgIntro := ;
		"Este programa executa:" + CRLF + ;
		" " + Chr(149) + " Leitura do arquivo de retorno bancario (.ret)" + CRLF + ;
		" " + Chr(149) + " Extracao dos blocos A (dados) e Z (autenticacao)" + CRLF + ;
		" " + Chr(149) + " Tipos suportados: ADI, FER, FOL, RSC" + CRLF + ;
		" " + Chr(149) + " Pesquisa de arquivo diretamente em pasta de rede" + CRLF + ;
		" " + Chr(149) + " Filtro opcional por nome do favorecido" + CRLF + ;
		" " + Chr(149) + " Geracao de arquivo CSV separado por ponto-e-virgula" + CRLF + ;
		" " + Chr(149) + " Geracao de LOG detalhado do processamento" + CRLF + CRLF + ;
		"Clique SIM para selecionar o arquivo."

	If .NOT. FWAlertNoYes(cMsgIntro, "Extrator de Retorno Bancario")
		Return (NIL)
	Else
		If FWAlertNoYes("Deseja pré-processar e copiar os aquivos retorno de pagamento?", "Arquivos de Retorno Bancario")
		   ShellExecute( "open", "c:\spool\VerifBancario.exe", "", "", 1 )	
		End

		Processa({|| BRPAGRET01()}, "Processando retorno bancario...")
	EndIf

Return (NIL)

/*/{Protheus.doc} BRPAGRET01
Funcao principal de leitura e extracao do arquivo de retorno bancario.
Abre cGetFile apontando para diretorio de rede configuravel e solicita
filtro opcional de nome antes de iniciar o processamento.
@type function Processamento
@version 1.00
@author marioantonaccio
@since 08/04/2026
@return character, sem retorno
/*/
Static Function BRPAGRET01()
	// --- Arrays ---
	Local aLinhas      := {} as array
	Local aRegistros   := {} as array

	// --- Strings ---
	Local cArqCSV      := "" as character
	
	Local cDataHoraFim := "" as character
	Local cDataHoraIni := "" as character
	Local cDiretorio   := "" as character
	//Local cDirRede     := "" as character // Diretorio de rede inicial do cGetFile
	Local cDrive       := "" as character
	Local cExtensao    := "" as character
	Local cFiltroNome  := "" as character // Filtro de nome digitado pelo usuario
	Local cHoraFim     := "" as character
	Local cHoraIni     := "" as character
	Local cLinha       := "" as character
	Local cLogArq      := "" as character
	Local cNome        := "" as character
	Local cArqOrig     := "" as character

	// --- Numericos ---
	Local nHandle    := 0 as numeric
	Local nHCSV      := 0 as numeric
	Local nHLog      := 0 as numeric
	Local nRegistros := 0 as numeric
	Local nTotal     := 0 as numeric
	Private cArqImp  := "" as character

	cDataHoraIni := DtoC(Date()) + " " + Time()
	cHoraIni     := Time()

	// =========================================================
	// 1. DIRETORIO DE REDE - ajuste o caminho conforme o ambiente
	//    Exemplos:
	//      Windows mapeado : "G:\Retornos\"
	//      UNC direto      : "\\servidor\compartilhamento\retornos\"
	//      Linux/Totvs     : "/mnt/rede/retornos/"
	// =========================================================
	//cDirRede := "\\servidor\retornos\"   // << ALTERE PARA O CAMINHO DA REDE

	// =========================================================
	// 2. SELECAO DO ARQUIVO VIA cGetFile COM DIRETORIO DE REDE
	//    O quarto parametro define o diretorio inicial do dialogo.
	//    Se o caminho de rede nao existir ou nao estiver acessivel,
	//    o dialogo abre no diretorio padrao sem gerar erro.
	// =========================================================
	/*
	cArqOrig := cGetFile( ;
		"Arquivos RET (*.ret)|*.ret|Arquivos TXT (*.txt)|*.txt|", ;
		"Selecione o arquivo de retorno bancario", ;
		1, ;          // Indice do filtro inicial (1 = *.ret)
		cDirRede, ;   // Diretorio inicial: pasta de rede
		.F. ;         // Nao permite selecao multipla
		)
	*/
	//salvar arquivo cArqOrig para saber qual arquivo estamos mexendo
	//Chamando o cGetFile para pegar um arquivo txt ou xml, mostrando o servidor
	cArqOrig := cGetFile( 'Arquivos RET (*.ret)|*.ret|Arquivos TXT (*.txt)|*.txt|Todos Arquivos|*.*',; //[ cMascara],
		"Selecione o arquivo de retorno bancario",;                  //[ cTitulo],
		0,;                                      //[ nMascpadrao],
		'C:\',;                                  //[ cDirinicial],
		.F.,;                                    //[ lSalvar],
		GETF_LOCALHARD  + GETF_NETWORKDRIVE,;    //[ nOpcoes],
		.T.)                                     //[ lArvore]

	If Empty(cArqOrig)
		FWAlertError("Nenhum arquivo selecionado.", "Selecao de arquivo", NIL)
		Return (NIL)
	EndIf

	// =========================================================
	// 3. FILTRO OPCIONAL POR NOME DO FAVORECIDO
	//    O usuario digita parte do nome (ou deixa em branco para
	//    processar todos). A comparacao sera feita sem distincao
	//    de maiusculas/minusculas (Upper x Upper).
	// =========================================================
	//cFiltroNome := FWInputBox( "Filtro por nome (ou parte) do favorecido: BRANCO = TODOS", "")

	If Aviso("Filtro por nome do favorecido",;
			@cFiltroNome,;
			{"OK", "Cancelar"},;
			1,;
			"Digite parte do nome ou o nome completo para filtrar os registros." + CRLF + ;
			"Deixe em branco para incluir TODOS os registros.",;
			/*nRotAutDefault*/,;
			/*cBitmap*/,;
			.T.) <> 1
		cFiltroNome := ""
	Else
		cFiltroNome:=AllTrim(cFiltroNome)
	EndIf

	// Confirmacao do filtro ao usuario
	If .NOT. Empty(cFiltroNome)
		If .NOT. FWAlertNoYes( ;
				"Sera aplicado o seguinte filtro de nome:" + CRLF + CRLF + ;
				"  >> " + Upper(cFiltroNome) + " <<" + CRLF + CRLF + ;
				"Somente registros cujo nome do favorecido" + CRLF + ;
				"contenha esse texto serao incluidos no CSV e no LOG." + CRLF + CRLF + ;
				"Confirma?", ;
				"Confirmar Filtro" ;
				)
			FWAlertInfo("Processamento cancelado pelo usuario.", "Cancelado", NIL)
			Return (NIL)
		EndIf
	EndIf

	// =========================================================
	// 4. MONTAGEM DOS CAMINHOS DE SAIDA
	// =========================================================
	SplitPath(cArqOrig, @cDrive, @cDiretorio, @cNome, @cExtensao)
	cArqCSV := cDrive + cDiretorio + ChgFileExt(cNome, "_extrato.csv")
	cLogArq := cDrive + cDiretorio + ChgFileExt(cNome, "_extrato.log")
	cArqImp:=cNome

	//validar pois o mesmo não considera os arquivos na mesma pasta para uma proxima leitura...
	// Remove arquivos anteriores
	If File(cArqCSV)
		If FERASE(cArqCSV) == -1
			FWAlertError("Nao foi possivel excluir o arquivo:" + CRLF + cArqCSV, "Erro na exclusao")
			Return (NIL)
		End
	End
	If File(cLogArq)
		If FERASE(cLogArq) == -1
			FWAlertError("Nao foi possivel excluir o arquivo:" + CRLF + cLogArq, "Erro na exclusao")
			Return (NIL)
		End
	End

	// =========================================================
	// 5. CRIACAO DO LOG
	// =========================================================
	nHLog := FCreate(cLogArq)
	If nHLog < 0
		FWAlertError("Erro ao criar arquivo de LOG.", "Erro", NIL)
		Return (NIL)
	End

	FWrite(nHLog, "LOG DO PROCESSAMENTO - RETORNO BANCARIO" + CRLF)
	FWrite(nHLog, "Arquivo origem   : " + cArqOrig     + CRLF)
	FWrite(nHLog, "Iniciado em      : " + cDataHoraIni + CRLF)
	If Empty(cFiltroNome)
		FWrite(nHLog, "Filtro de nome   : (todos os registros)" + CRLF + CRLF)
	Else
		FWrite(nHLog, "Filtro de nome   : " + Upper(cFiltroNome) + " (comparacao parcial, sem case)" + CRLF + CRLF)
	EndIf

	// =========================================================
	// 6. LEITURA DO ARQUIVO DE RETORNO
	// =========================================================
	If File(cArqOrig)
		FWMsgRun(, {|| nHandle := FT_FUse(cArqOrig)}, "Processando", "Aguarde... lendo arquivo...")
		If nHandle == -1
			FWAlertError("Erro na abertura do arquivo.", "Erro na abertura", NIL)
			FClose(nHLog)
			Return (NIL)
		End
		FT_FGoTop()
		aLinhas := {}
		While .NOT. FT_FEOF()
			cLinha := FT_FReadLn()
			AAdd(aLinhas, cLinha)
			FT_FSKIP()
		End
		FT_FUSE()
	Else
		FWAlertError("Arquivo nao encontrado.", "Nao encontrado", NIL)
		FClose(nHLog)
		Return (NIL)
	EndIf

	FWrite(nHLog, "Total de linhas lidas: " + cValToChar(Len(aLinhas)) + CRLF + CRLF)

	// =========================================================
	// 7. CRIACAO DO CSV
	// =========================================================
	nHCSV := FCreate(cArqCSV)
	If nHCSV < 0
		FWAlertError("Erro ao criar arquivo CSV.", "Erro", NIL)
		FClose(nHLog)
		Return (NIL)
	End

	// Cabecalho CSV
	FWrite(nHCSV, ;
		"CONTA"         + ";" + ;
		"NOME"          + ";" + ;
		"CPF"          + ";" + ;
		"TIPO"          + ";" + ;
		"DT_LANCAMENTO" + ";" + ;
		"DT_CREDITO"    + ";" + ;
		"VALOR"         + ";" + ;
		"AUTENTICACAO"  + CRLF)

	// Cabecalho LOG
	FWrite(nHLog, Replicate("=", 135) + CRLF)
	FWrite(nHLog, ;
		PadR("CONTA",          22) + " | " + ;
		PadR("NOME",           32) + " | " + ;
		PadR("CPF",            32) + " | " + ;
		PadR("TIPO",            4) + " | " + ;
		PadR("DT_LANC",        10) + " | " + ;
		PadR("DT_CRED",        10) + " | " + ;
		PadL("VALOR",          14) + " | " + ;
		PadR("AUTENTICACAO",   26) + CRLF)
	FWrite(nHLog, Replicate("-", 135) + CRLF)

	// =========================================================
	// 8. EXTRACAO DOS BLOCOS A/Z COM FILTRO DE NOME
	// =========================================================
	nRegistros := BRPAGRET02(@aLinhas, nHCSV, nHLog, @nTotal, cFiltroNome, @aRegistros)

	// =========================================================
	// 9. RODAPE DO LOG E ENCERRAMENTO
	// =========================================================
	cDataHoraFim := DtoC(Date()) + " " + Time()
	cHoraFim     := Time()

	FWrite(nHLog, Replicate("=", 135) + CRLF + CRLF)
	FWrite(nHLog, "=== RESUMO FINAL ===" + CRLF)
	FWrite(nHLog, "Finalizado em    : " + cDataHoraFim + CRLF)
	FWrite(nHLog, "Tempo gasto      : " + ElapTime(cHoraIni, cHoraFim) + CRLF)
	FWrite(nHLog, "Filtro nome aplic: " + If(Empty(cFiltroNome), "(nenhum)", Upper(cFiltroNome)) + CRLF)
	FWrite(nHLog, "Registros gerados: " + cValToChar(nRegistros) + CRLF)
	FWrite(nHLog, "Valor total      : " + AllTrim(Transform(nTotal, "@ER 999999999.99")) + CRLF)
	FWrite(nHLog, "CSV gerado       : " + cArqCSV + CRLF)
	FClose(nHCSV)
	FClose(nHLog)

	If nRegistros > 0
		BRPAGRET06(@aRegistros, nTotal, cFiltroNome, cArqOrig)
	EndIf

	FWAlertSuccess( ;
		"Processamento finalizado!" + CRLF + CRLF + ;
		"Filtro de nome    : " + If(Empty(cFiltroNome), "(todos)", Upper(cFiltroNome)) + CRLF + ;
		"Registros gerados : " + cValToChar(nRegistros) + CRLF + ;
		"Valor total       : R$ " + AllTrim(Transform(nTotal, "@ER 999999999.99")) + CRLF + CRLF + ;
		"CSV gerado        : " + cArqCSV + CRLF + ;
		"Log gerado        : " + cLogArq, ;
		"Extracao Concluida")

Return (NIL)

/*/{Protheus.doc} BRPAGRET02
Varre o array de linhas do arquivo de retorno, extrai os dados dos blocos
compostos por linha A (dados) + linha B (endereco) + linha Z (autenticacao)
e grava cada registro no CSV e no LOG.
Quando a linha Z nao existir, grava o registro com autenticacao em branco.
Aplica filtro parcial de nome quando cFiltroNome nao estiver vazio:
a comparacao e feita em Upper() para ignorar maiusculas/minusculas.
Posicoes utilizadas na linha A (1-based):
  [14]      Tipo de registro = 'A'
  [15-42]   Conta bancaria (28 chars) - gravada sem zeros a esquerda
  [43-73]   Nome do favorecido (31 chars)
  [74-76]   Tipo de pagamento: ADI / FER / FOL / RSC
  [94-101]  Data de lancamento DDMMAAAA
  [120-134] Valor bruto (15 digitos inteiros; dividir por 100 = R$ com centavos)
  [155-162] Data de credito DDMMAAAA
Posicao utilizada na linha Z:
  Primeira sequencia numerica com 10+ digitos apos posicao 14 = autenticacao
@type function Auxiliar
@version 1.00
@author marioantonaccio
@since 08/04/2026
@param aLinhas,     array,     Array com todas as linhas do arquivo (by reference)
@param nHCSV,       numeric,   Handle do arquivo CSV
@param nHLog,       numeric,   Handle do arquivo LOG
@param nTotal,      numeric,   Acumulador do valor total (by reference)
@param cFiltroNome, character, Texto parcial para filtrar nome (vazio = todos)
@param aRegistros,  array,     Registros extraidos para impressao (by reference)
@return numeric, quantidade de registros gravados
/*/
Static Function BRPAGRET02(aLinhas, nHCSV, nHLog, nTotal, cFiltroNome, aRegistros)
	// --- Strings ---
	Local cAutent   := "" as character
	Local cConta    := "" as character
	Local cContaRaw := "" as character
	Local cDtCred   := "" as character
	Local cDtLanc   := "" as character
	Local cDtPrev   := "" as character
	Local cFiltroUp := "" as character // Filtro em maiusculas para comparacao
	Local cNome     := "" as character
	Local cNroPag   := "" as character
	Local cTipoPag  := "" as character
	Local cTipoReg  := "" as character
	Local cValorRaw := "" as character
	Local cEmpAge   := "" as character
	Local cEmpBan   := "" as character
	Local cEmpCon   := "" as character
	Local cEmpDoc   := "" as character
	Local cEmpNome  := "" as character

	// --- Numericos ---
	Local nI         := 0 as numeric
	Local nIndex     := 0 as numeric
	Local nRegistros := 0 as numeric
	Local nValor     := 0 as numeric

	// --- Logicos ---
	Local lBlocoA      := .F. as logical
	Local lPassaFiltro := .F. as logical // .T. se o bloco A passa pelo filtro de nome

	// Dados do bloco corrente
	Local cContaA  := "" as character
	Local cCodEmpA := "" as character
	Local cDtCredA := "" as character
	Local cDtLancA := "" as character
	Local cDtPrevA := "" as character
	Local cEmpAgeA := "" as character
	Local cEmpBanA := "" as character
	Local cEmpConA := "" as character
	Local cEmpPagA := "" as character
	Local cFunAgeA := "" as character
	Local cFunBanA := "" as character
	Local cFunConA := "" as character
	Local cNomeA   := "" as character
	Local cNroPagA := "" as character
	Local cTipoA   := "" as character
	Local cCPFA    := "" as character
	Local nValorA  := 0  as numeric

	// Pre-processa o filtro uma unica vez em maiusculas
	cFiltroUp := Upper(AllTrim(cFiltroNome))

	ProcRegua(Len(aLinhas))

	// Header do lote/empresa (segmento C no layout recebido).
	For nIndex := 1 To Len(aLinhas)
		If Len(aLinhas[nIndex]) >= 71 .AND. SubStr(aLinhas[nIndex], 9, 1) == "C"
			cEmpBan  := AllTrim(SubStr(aLinhas[nIndex], 1, 3))
			cEmpDoc  := BRPAGRET09(SubStr(aLinhas[nIndex], 19, 14))
			cEmpAge  := AllTrim(SubStr(aLinhas[nIndex], 53, 5))
			cEmpCon  := AllTrim(SubStr(aLinhas[nIndex], 59, 12))
			cEmpNome := AllTrim(SubStr(aLinhas[nIndex], 73, 30))
			Exit
		EndIf
	Next

	If Empty(cEmpBan) .OR. Empty(cEmpDoc) .OR. Empty(cEmpAge) .OR. Empty(cEmpCon)
		FWrite(nHLog, "ERRO: Header de empresa nao localizado ou incompleto no arquivo." + CRLF)
		FWAlertError("Nao foi possivel validar os dados da empresa no header do arquivo.", "Validacao da empresa", NIL)
		Return (0)
	EndIf

	If .NOT. BRPAGRET10(cEmpDoc, cEmpNome)
		FWrite(nHLog, "ERRO: CNPJ do arquivo (" + cEmpDoc + ") nao confere com a empresa/filial logada." + CRLF)
		Return (0)
	EndIf

	FWrite(nHLog, "Empresa arquivo : " + cEmpDoc + " - " + cEmpNome + CRLF)
	FWrite(nHLog, "Banco empresa   : " + cEmpBan + " / Agencia: " + cEmpAge + " / Conta: " + cEmpCon + CRLF + CRLF)

	For nIndex := 1 To Len(aLinhas)
		IncProc()

		If Len(aLinhas[nIndex]) < 14
			Loop
		End

		cTipoReg := SubStr(aLinhas[nIndex], 14, 1)

		// -------------------------------------------------------
		// Linha A: extrai os dados principais do pagamento
		// -------------------------------------------------------
		If cTipoReg == "A"

			// Se o arquivo nao trouxe linha Z para o bloco anterior,
			// grava mesmo assim com autenticacao em branco.
			If lBlocoA
				BRPAGRET05(nHCSV, nHLog, cEmpAgeA, cEmpConA, cCodEmpA, cEmpBanA, cEmpPagA, cFunBanA, cFunAgeA, cFunConA, cNomeA, cCPFA, cTipoA, cDtLancA, cNroPagA, cDtCredA, nValorA, cDtPrevA, "", @nTotal, @aRegistros)
				nRegistros++
				lBlocoA := .F.
			EndIf

			// Nome: posicoes 44-73 (30 chars) - extraido primeiro para aplicar filtro
			cNome := AllTrim(SubStr(aLinhas[nIndex], 44, 30))

			If Empty(cFiltroUp)
				lPassaFiltro := .T.
			Else
				lPassaFiltro := ( cFiltroUp $ Upper(cNome) )
			EndIf

			If .NOT. lPassaFiltro
				lBlocoA := .F.
				Loop
			EndIf

			cContaRaw := AllTrim(SubStr(aLinhas[nIndex], 30, 12))
			cFunBanA  := AllTrim(SubStr(aLinhas[nIndex], 21, 03))
			cFunAgeA  := AllTrim(SubStr(aLinhas[nIndex], 24, 05))
			cFunConA  := AllTrim(SubStr(aLinhas[nIndex], 30, 12))

			cEmpBanA  := cEmpBan
			cEmpAgeA  := cEmpAge
			cEmpConA  := cEmpCon

			cConta := cContaRaw
			For nI := 1 To Len(cConta)
				If .NOT. (SubStr(cConta, nI, 1) == "0")
					Exit
				End
			End
			cConta := SubStr(cConta, nI)

			// Tipo pagamento: posicoes 74-76 (3 chars)
			cTipoPag := AllTrim(SubStr(aLinhas[nIndex], 74, 3))
			cNroPag  := AllTrim(SubStr(aLinhas[nIndex], 77, 15))

			// Data lancamento: posicoes 94-101 (DDMMAAAA)
			cDtLanc := BRPAGRET03(AllTrim(SubStr(aLinhas[nIndex], 94, 8)))

			// Valor: posicoes 120-134 (15 digitos inteiros / 100)
			cValorRaw := AllTrim(SubStr(aLinhas[nIndex], 120, 15))
			nValor    := 0
			If cValorRaw == StrTran(cValorRaw, " ", "") .AND. Len(cValorRaw) > 0
				nValor := Val(cValorRaw) / 100
			End

			// Data credito: posicoes 155-162 (DDMMAAAA)
			cDtCred := BRPAGRET03(AllTrim(SubStr(aLinhas[nIndex], 155, 8)))

			// Guarda bloco A para complementar com linha B e fechar na linha Z
			cContaA  := cConta
			cCodEmpA := cEmpDoc
			cDtCredA := cDtCred
			cDtLancA := cDtLanc
			cDtPrevA := cDtCred
			cEmpPagA := cCGCAtu
			cNomeA   := cNome
			cNroPagA := cNroPag
			cTipoA   := cTipoPag
			cCPFA    := ""
			nValorA  := nValor
			lBlocoA  := .T.
		End

		// -------------------------------------------------------
		// Linha B: complementa o bloco A com CPF e data prevista
		// -------------------------------------------------------
		If cTipoReg == "B" .AND. lBlocoA
			// Segmento B: pos. 18 = tipo inscricao; pos. 19-32 = CPF/CNPJ.
			cCPFA := BRPAGRET09(SubStr(aLinhas[nIndex], 19, 14))
			If Len(cCPFA) > 11
				cCPFA := SubStr(cCPFA, Len(cCPFA) - 10, 11)
			EndIf

			cDtPrev := BRPAGRET03(AllTrim(SubStr(aLinhas[nIndex], 127, 8)))
			If !Empty(cDtPrev)
				cDtPrevA := cDtPrev
			EndIf
		End

		// -------------------------------------------------------
		// Linha Z: fecha o bloco e grava o registro
		// -------------------------------------------------------
		If cTipoReg == "Z" .AND. lBlocoA
			// Autenticacao: primeira sequencia numerica >= 10 digitos apos pos 14
			cAutent := BRPAGRET04(SubStr(aLinhas[nIndex], 15))

			BRPAGRET05(nHCSV, nHLog, cEmpAgeA, cEmpConA, cCodEmpA, cEmpBanA, cEmpPagA, cFunBanA, cFunAgeA, cFunConA, cNomeA, cCPFA, cTipoA, cDtLancA, cNroPagA, cDtCredA, nValorA, cDtPrevA, cAutent, @nTotal, @aRegistros)
			nRegistros++
			lBlocoA := .F.
		End
	Next

	// Ultimo bloco do arquivo sem linha Z.
	If lBlocoA
		BRPAGRET05(nHCSV, nHLog, cEmpAgeA, cEmpConA, cCodEmpA, cEmpBanA, cEmpPagA, cFunBanA, cFunAgeA, cFunConA, cNomeA, cCPFA, cTipoA, cDtLancA, cNroPagA, cDtCredA, nValorA, cDtPrevA, "", @nTotal, @aRegistros)
		nRegistros++
	EndIf

Return (nRegistros)

/*/{Protheus.doc} BRPAGRET03
Converte data no formato DDMMAAAA para DD/MM/AAAA.
Retorna a string original se nao for uma data valida.
@type function Auxiliar
@version 1.00
@author marioantonaccio
@since 08/04/2026
@param cData, character, Data no formato DDMMAAAA
@return character, Data formatada DD/MM/AAAA
/*/
Static Function BRPAGRET03(cData)
	Local cRet := "" as character
	
	cData := AllTrim(cData)
	If Len(cData) == 8 .AND. cData == StrTran(cData, " ", "")
		If Val(cData) > 0 .OR. cData == "00000000"
			cRet := SubStr(cData,1,2) + "/" + SubStr(cData,3,2) + "/" + SubStr(cData,5,4)
		Else
			cRet := cData
		End
	Else
		cRet := cData
	End
Return (cRet)

/*/{Protheus.doc} BRPAGRET05
Grava uma linha extraida no CSV e no LOG.
@type function Auxiliar
@version 1.00
@author marioantonaccio
@since 08/04/2026
@param nHCSV,       numeric,   Handle do arquivo CSV
@param nHLog,       numeric,   Handle do arquivo LOG
@param cContaA,     character, Conta bancaria
@param cNomeA,      character, Nome do favorecido
@param cTipoA,      character, Tipo de pagamento
@param cDtLancA,    character, Data de lancamento
@param cDtCredA,    character, Data de credito
@param nValorA,     numeric,   Valor do pagamento
@param cAutent,     character, Autenticacao bancaria
@param nTotal,      numeric,   Acumulador do valor total (by reference)
@param aRegistros,  array,     Registros extraidos para impressao (by reference)
@return character,sem retorno
/*/
Static Function BRPAGRET05(nHCSV, nHLog, cEmpAgeA, cEmpConA, cCodEmpA, cEmpBanA, cEmpPagA, cFunBanA, cFunAgeA, cFunConA, cNomeA, cCPFA, cTipoA, cDtLancA, cNroPagA, cDtCredA, nValorA, cDtPrevA, cAutent, nTotal, aRegistros)
	Local _cFilial := cFilAnt   as character
	Local aArea    := GetArea() as array
	Local aAreaZAK := NIL       as array

	// --- Grava no CSV ---
	FWrite(nHCSV, ;
		cFunConA + ";" + ;
		cNomeA   + ";" + ;
		cCPFA    + ";" + ;
		cTipoA   + ";" + ;
		cDtLancA + ";" + ;
		cDtCredA + ";" + ;
		StrTran(AllTrim(Transform(nValorA, "@ER 999999999.99")), ".", ",") + ";" + ;
		cAutent  + CRLF)

	// --- Grava no LOG ---
	FWrite(nHLog, ;
		PadR(cFunConA, 22) + " | " + ;
		PadR(cNomeA,   32) + " | " + ;
		PadR(Transform(Val(cCPFA), "@R 999.999.999-99"), 14) + " | " + ;
		PadR(cTipoA,    4) + " | " + ;
		PadR(cDtLancA, 10) + " | " + ;
		PadR(cDtCredA, 10) + " | " + ;
		PadL(Transform(nValorA, "@ER 999999999.99"), 14) + " | " + ;
		cAutent + CRLF)

	// --- Grava na tabela ZAK ---
	DbSelectArea("ZAK")
	aAreaZAK := GetArea()

	RecLock("ZAK", .T.)
	ZAK->ZAK_FILIAL := _cFilial
	ZAK->ZAK_EMPAGE := SubStr(cEmpAgeA, 1, TamSX3("ZAK_EMPAGE")[1])
	ZAK->ZAK_EMPCON := SubStr(cEmpConA, 1, TamSX3("ZAK_EMPCON")[1])
	ZAK->ZAK_CODEMP := SubStr(cCodEmpA, 1, TamSX3("ZAK_CODEMP")[1])
	ZAK->ZAK_EMPBAN := SubStr(cEmpBanA, 1, TamSX3("ZAK_EMPBAN")[1])
	ZAK->ZAK_EMPPAG := SubStr(cEmpPagA, 1, TamSX3("ZAK_EMPPAG")[1])
	ZAK->ZAK_FUNNOM := SubStr(cNomeA,   1, TamSX3("ZAK_FUNNOM")[1])
	ZAK->ZAK_FUNCPF := SubStr(cCPFA,    1, TamSX3("ZAK_FUNCPF")[1])
	ZAK->ZAK_FUNCON := SubStr(cFunConA, 1, TamSX3("ZAK_FUNCON")[1])
	ZAK->ZAK_FUNAGE := SubStr(cFunAgeA, 1, TamSX3("ZAK_FUNAGE")[1])
	ZAK->ZAK_FUNBAN := SubStr(cFunBanA, 1, TamSX3("ZAK_FUNBAN")[1])
	ZAK->ZAK_FUNTIP := SubStr(cTipoA,   1, TamSX3("ZAK_FUNTIP")[1])
	ZAK->ZAK_DTLANC := BRPAGRET_CtoD(cDtLancA)
	ZAK->ZAK_NROPAG := SubStr(cNroPagA, 1, TamSX3("ZAK_NROPAG")[1])
	ZAK->ZAK_DTPAG  := BRPAGRET_CtoD(cDtCredA)
	ZAK->ZAK_VALPAG := nValorA
	ZAK->ZAK_DTPREV := BRPAGRET_CtoD(cDtPrevA)
	//MAA
	ZAK->ZAK_DTIMP 	:= dDataBase
	ZAK->USRIMP		:= UsrRetName(RetCodUsr())
	ZAK_ARQUIV		:= AllTrim(cArqImp)
	MsUnLock()

	nTotal += nValorA
	AAdd(aRegistros, {cFunConA, cNomeA, cCPFA, cTipoA, cDtLancA, cDtCredA, nValorA, cAutent})

	RestArea(aAreaZAK)
	RestArea(aArea)

Return (NIL)

/*/{Protheus.doc} BRPAGRET_CtoD
Converte "DD/MM/AAAA" para Date
@type function Processamento
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param cData, character, variavel contendo a data no formato DD/MM/AAAA
@return date, variavel data convertida
/*/
Static Function BRPAGRET_CtoD(cData)

	Local dRet := CtoD("") as date

	If Len(AllTrim(cData)) == 10
		// Protheus espera formato do SET DATE (geralmente DDMMYYYY via CtoD)
		dRet := StoD(SubStr(cData,7,4) + SubStr(cData,4,2) + SubStr(cData,1,2))
	EndIf
Return (dRet)

/*/{Protheus.doc} BRPAGRET09
Mantem apenas digitos de uma string.
@type function Processamento
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param cTexto, character, variavel a ser verificada
@return character, variavel contendo apenas digitos
/*/
Static Function BRPAGRET09(cTexto)
	Local cRet  := "" as character
	Local nI    := 0  as numeric
	Local cChar := "" as character

	For nI := 1 To Len(cTexto)
		cChar := SubStr(cTexto, nI, 1)
		If cChar >= "0" .AND. cChar <= "9"
			cRet += cChar
		EndIf
	Next

Return (cRet)
 
/*/{Protheus.doc} BRPAGRET10
Valida o CNPJ do header contra a empresa/filial logada no Protheus.
@type function Processamento
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param cEmpDoc, character, Empresa do Docuemntop
@param cEmpNome, character, Nome da Empresa
@return Logical, indica se a validação CNPJ está ok
/*/
Static Function BRPAGRET10(cEmpDoc, cEmpNome)
	// Local cCGCAtu := "" as character
	Local aArea   := GetArea() as array
	Local aAreaM0 := NIL       as array
	Local lRet    := .T.       as logical

	DbSelectArea("SM0")
	aAreaM0 := GetArea()
	SM0->(DBGoTop()) // M0_CODIGO + M0_CODFIL
	WHILE (!SM0->(EOF()))
		If SM0->M0_CGC == cEmpDoc 
			cCGCAtu := SM0->M0_CODIGO + SM0->M0_CODFIL
			Exit
		EndIf
		SM0->(DBSkip())
	END

		If (Empty(cCGCAtu))
		FWAlertError( ;
				"O CNPJ do arquivo nao confere com a empresa/filial logada." + CRLF + CRLF + ;
				"Arquivo : " + cEmpDoc + " - " + cEmpNome + CRLF + ;
				"Logada  : " + cCGCAtu + CRLF + ;
				"Filial  : " + cFilAnt, ;
				"Validacao da empresa", NIL)
			lRet := .F.
		EndIf

	RestArea(aAreaM0)
	RestArea(aArea)

Return (lRet)

/*/{Protheus.doc} BRPAGRET06
Gera preview PDF do retorno Bradesco com logo fixa do banco.
Para exibir a logo, mantenha o arquivo BRADESCO.BMP no StartPath do AppServer.
@type function Auxiliar
@version 1.00
@author marioantonaccio
@since 08/04/2026
@param aRegistros,  array,     Registros extraidos
@param nTotal,      numeric,   Valor total extraido
@param cFiltroNome, character, Filtro aplicado
@param cArqOrig,    character, Arquivo origem processado
@return character, sem retorno
/*/
Static Function BRPAGRET06(aRegistros, nTotal, cFiltroNome, cArqOrig)
	Local cArquivo := ""  as character
	Local cFiltro  := ""  as character
	Local cLogo    := ""  as character
	Local cOrigem  := ""  as character
	Local nI       := 0   as numeric
	Local nLin     := 0   as numeric
	Local nLinFim  := 520 as numeric
	Local nPag     := 1   as numeric
	Local oFontCab := NIL as object
	Local oFontDet := NIL as object
	Local oFontRod := NIL as object
	Local oFontTit := NIL as object
	Local oPrint   := NIL as object

	cArquivo := "BRPAGRET_" + DToS(Date()) + "_" + StrTran(Time(), ":", "-")
	cLogo    := GetSrvProfString("StartPath", "") + "BRADESCO.BMP"
	cFiltro  := If(Empty(cFiltroNome), "(todos)", Upper(AllTrim(cFiltroNome)))
	cOrigem  := SubStr(cArqOrig, Max(1, Len(cArqOrig) - 80))

	oFontTit := TFont():New("Arial", 9, -16, .T., .T., 5, .T., 5, .T., .F.)
	oFontCab := TFont():New("Arial", 9, -10, .T., .T., 5, .T., 5, .T., .F.)
	oFontDet := TFont():New("Arial", 9, -09, .T., .F., 5, .T., 5, .T., .F.)
	oFontRod := TFont():New("Arial", 9, -08, .T., .F., 5, .T., 5, .T., .F.)

	oPrint := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrint, "", , , , .T.)
	oPrint:SetResolution(72)
	oPrint:SetLandscape()
	oPrint:SetPaperSize(DMPAPER_A4)
	oPrint:SetMargin(40, 40, 40, 40)

	For nI := 1 To Len(aRegistros)
		If nI == 1 .OR. nLin > nLinFim
			If nI > 1
				BRPAGRET08(oPrint, oFontRod, nPag)
				nPag++
			EndIf
			BRPAGRET07(oPrint, oFontTit, oFontCab, cLogo, cFiltro, cOrigem)
			nLin := 105
		EndIf

		oPrint:SayAlign(nLin, 040, aRegistros[nI][01], oFontDet, 080, 10, /*nClrText*/, PAD_LEFT, 0)
		oPrint:SayAlign(nLin, 125, SubStr(aRegistros[nI][02], 1, 34), oFontDet, 180, 10, /*nClrText*/, PAD_LEFT, 0)
		oPrint:SayAlign(nLin, 310, aRegistros[nI][04], oFontDet, 035, 10, /*nClrText*/, PAD_CENTER, 0)
		oPrint:SayAlign(nLin, 350, aRegistros[nI][05], oFontDet, 060, 10, /*nClrText*/, PAD_CENTER, 0)
		oPrint:SayAlign(nLin, 415, aRegistros[nI][06], oFontDet, 060, 10, /*nClrText*/, PAD_CENTER, 0)
		oPrint:SayAlign(nLin, 480, Transform(aRegistros[nI][07], "@E 999,999,999.99"), oFontDet, 090, 10, /*nClrText*/, PAD_RIGHT, 0)
		oPrint:SayAlign(nLin, 575, aRegistros[nI][08], oFontDet, 170, 10, /*nClrText*/, PAD_LEFT, 0)
		nLin += 12
	Next

	oPrint:Line(nLin + 4, 040, nLin + 4, 745, COR_CINZA)
	nLin += 10
	oPrint:SayAlign(nLin, 395, "TOTAL", oFontCab, 080, 10, /*nClrText*/, PAD_RIGHT, 0)
	oPrint:SayAlign(nLin, 480, Transform(nTotal, "@E 999,999,999.99"), oFontCab, 090, 10, /*nClrText*/, PAD_RIGHT, 0)
	BRPAGRET08(oPrint, oFontRod, nPag)

	oPrint:Preview()

Return (NIL)

/*/{Protheus.doc} BRPAGRET07
Imprime cabecalho do relatorio Bradesco.
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param oPrint, object, Obejto Relatorio
@param oFontTit, object, Objeto Fonte do Titulo
@param oFontCab, object, Objeto Fonte do Cabecalho
@param cLogo, character, Caminho do Logo
@param cFiltro, character, Filtro aplicado
@param cOrigem, character, Origem do Arquivo
@return character, sem retorno
/*/
Static Function BRPAGRET07(oPrint, oFontTit, oFontCab, cLogo, cFiltro, cOrigem)

	oPrint:StartPage()
	If File(cLogo)
		oPrint:SayBitmap(020, 040, cLogo, 055, 028)
	EndIf
	oPrint:SayAlign(025, 110, "Retorno Bancario Bradesco", oFontTit, 280, 18, /*nClrText*/, PAD_LEFT, 0)
	oPrint:SayAlign(048, 110, "Filtro: " + cFiltro, oFontCab, 300, 10, /*nClrText*/, PAD_LEFT, 0)
	oPrint:SayAlign(062, 110, "Arquivo: ..." + cOrigem, oFontCab, 500, 10, /*nClrText*/, PAD_LEFT, 0)

	oPrint:Line(082, 040, 082, 745, COR_CINZA)
	oPrint:SayAlign(090, 040, "CONTA", oFontCab, 080, 10, /*nClrText*/, PAD_LEFT, 0)
	oPrint:SayAlign(090, 125, "NOME", oFontCab, 180, 10, /*nClrText*/, PAD_LEFT, 0)
	oPrint:SayAlign(090, 310, "TIPO", oFontCab, 035, 10, /*nClrText*/, PAD_CENTER, 0)
	oPrint:SayAlign(090, 350, "DT LANC.", oFontCab, 060, 10, /*nClrText*/, PAD_CENTER, 0)
	oPrint:SayAlign(090, 415, "DT CRED.", oFontCab, 060, 10, /*nClrText*/, PAD_CENTER, 0)
	oPrint:SayAlign(090, 480, "VALOR", oFontCab, 090, 10, /*nClrText*/, PAD_RIGHT, 0)
	oPrint:SayAlign(090, 575, "AUTENTICACAO", oFontCab, 170, 10, /*nClrText*/, PAD_LEFT, 0)
	oPrint:Line(102, 040, 102, 745, COR_CINZA)

Return (NIL)

/*/{Protheus.doc} BRPAGRET08
Imprime rodape e fecha pagina do relatorio Bradesco.
@type function Relatorio
@version  1.00
@author marioantonaccio
@since 20/07/2026
@param oPrint, object, Objeto Relatorio
@param oFontRod, object, Objeto Fonte de Rodape
@param nPag, numeric, Numero da Pagina
@return character, sem retorno
/*/
Static Function BRPAGRET08(oPrint, oFontRod, nPag)

	oPrint:Line(555, 040, 555, 745, COR_CINZA)
	oPrint:SayAlign(560, 040, DToC(Date()) + " " + Time() + "  " + FunName(), oFontRod, 250, 10, COR_CINZA, PAD_LEFT, 0)
	oPrint:SayAlign(560, 680, "Pagina " + cValToChar(nPag), oFontRod, 065, 10, COR_CINZA, PAD_RIGHT, 0)
	oPrint:EndPage()

Return (NIL)

/*/{Protheus.doc} BRPAGRET04
Extrai a autenticacao bancaria da linha Z: localiza a primeira sequencia
numerica com 10 ou mais digitos consecutivos na string recebida.
@type function Auxiliar
@version 1.00
@author marioantonaccio
@since 08/04/2026
@param cTexto, character, Conteudo da linha Z apos a posicao 14
@return character, Codigo de autenticacao ou vazio se nao encontrado
/*/
Static Function BRPAGRET04(cTexto)
	Local cRet   := "" as character
	Local cBloco := "" as character
	Local nI     := 0  as numeric
	Local cChar  := "" as character

	nI := 1
	While nI <= Len(cTexto)
		cChar := SubStr(cTexto, nI, 1)
		If cChar >= "0" .AND. cChar <= "9"
			cBloco += cChar
		Else
			If Len(cBloco) >= 10
				cRet := cBloco
				Exit
			End
			cBloco := ""
		End
		nI++
	End

	// Testa o ultimo bloco (caso a linha termine com digitos)
	If Empty(cRet) .AND. Len(cBloco) >= 10
		cRet := cBloco
	End

Return (cRet)
