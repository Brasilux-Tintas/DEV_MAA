//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} User Function zTiSQL
Função do Terminal de Informação para executar consultas SQL em bases Protheus. SOMENTE ADMINISTRADORES podem executar.
@type  Function
@author Atilio
@since 19/12/2020
@version version
@example
    u_zTiSQL()
@obs Função ideal para ser usada em ambientes TCloud, pode ser colocado um atalho ao iniciar o sistema via AfterLogin
    User Function AfterLogin()
        SetKey(K_SH_F11, { || u_zTiSQL() }) //Shift + F11
    Return
@see https://terminaldeinformacao.com
/*/

User Function zTiSQL()
    Local aArea
    Local cEmpAux := "01"
    Local cFilAux := "010101"
    Local cUsrAux := "admin"
    Local cPswAux := "" // NÃO RECOMENDÁVEL colocar a senha de administrador chumbada no fonte, a não ser que se crie uma criptografia de forma que NÍNGUÉM possa descobrir!!!!
    Private lProgInic := .F.
    Return
    //Se vier direto do programa inicial (u_zTiSQL ao invés de SIGAMDI / SIGAADV), prepara o ambiente
    If Select("SX2") == 0
		RPCSetEnv(cEmpAux, cFilAux, cUsrAux, cPswAux, "", "")
        lContinua := .T.
        lProgInic := .T.

    //Senão, se vier de dentro do SIGAMDI / SIGAADV, verifica se o usuário está no grupo de Administradores
    Else
        lContinua := FWIsAdmin()
    EndIf
    aArea := GetArea()

    //Se deu tudo certo, abre a tela
    If lContinua
        fMontaTela()
    Else
        MsgStop("Somente usuários admin podem acessar a rotina!", "Atenção")
    EndIf

    RestArea(aArea)
Return

/*/{Protheus.doc} fMontaTela
Função que realiza a montagem da tela
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fMontaTela()
    Local nLinObj := 0
    Local nLargBtn := 60
    //Blocos de código chamados pelos botões
    Local bExecutar := {|| fZeraLog(), fExecutar() }
    Local bAbrir    := {|| fZeraLog(), fAbrir() }
    Local bSalvar   := {|| fZeraLog(), fSalvar() }
    Local bFechar   := {|| oDlgSQL:End() }
	Local bExportar := {|| fZeraLog(), fExportar() }
	Local bIndentar := {|| fZeraLog(), fIndentar() }
	Local bSelect   := {|| fZeraLog(), fGerSelect() }
	Local bUpdate   := {|| fZeraLog(), fGerUpdate() }
    Local bAjuda    := {|| fZeraLog(), fAjuda() }
    Local bCampos   := {|| fZeraLog(), fConsSX3()}
    //Fontes
    Private cFontPad    := "Tahoma"
    Private oFontBtn    := TFont():New(cFontPad, , -14)
	Private oFontBtnN   := TFont():New(cFontPad, , -14, , .T.)
    Private oFontMod    := TFont():New(cFontPad, , -38)
	Private oFontSub    := TFont():New(cFontPad, , -20)
	Private oFontSubN   := TFont():New(cFontPad, , -20, , .T.)
    //Caminho do arquivo que guarda a última execução de query
    Private cUltPasta := GetTempPath()
    Private cLastQry  := GetTempPath() + "ztisql.txt"
    //Objetos da Janela
    Private lCentered
    Private oBtnExe
    Private oBtnAbr
    Private oBtnSal
    Private oBtnFec
	Private oBtnExp
	Private oBtnInd
	Private oBtnSel
	Private oBtnUpd
    Private oSayModulo, cSayModulo := 'CFG'
    Private oSayTitulo, cSayTitulo := 'zTiSQL - Execucao de Queries SQL'
    Private oSaySubTit, cSaySubTit := 'https://terminaldeinformacao.com'
    Private oDlgSQL
    Private oPanSQL
    Private oPanResult
    Private oEditSQL, cEditSQL := "Digite aqui sua query (F3 para selecionar campos do Dicionário)..."
    Private oSayLog, cSayLog
    //Tamanho da janela
    Private aTamanho
    Private nJanLarg
    Private nJanAltu
    Private nJanAltMei
    //Resultados da query
    Private oEditResult
    Private oMResult
    Private aHeadResu  := {}
    Private lEmExecucao := .F.
    Private cAliasResu  := ""

    //Se vier do programa inicial, a dimensão será diferente
    If lProgInic
        aTamanho  := GetScreenRes()
        nJanLarg  := aTamanho[1]
        nJanAltu  := aTamanho[2] - 80
        lCentered := .F.
    Else
        aTamanho  := MsAdvSize()
        nJanLarg  := aTamanho[5]
        nJanAltu  := aTamanho[6]
        lCentered := .T.
    EndIf
    nJanAltMei := nJanAltu/4

    //Se existir o arquivo, busca o conteúdo
    If File(cLastQry)
        oFile   := FwFileReader():New(cLastQry)
        If oFile:Open()
            //Busca o conteúdo do arquivo
            cArqConteu := oFile:FullRead()
            cEditSQL   := cArqConteu
            oFile:Close()
        EndIf
    EndIf

	//Define os atalhos do F3 e F5
    SetKey(VK_F3, bCampos)
	SetKey(VK_F5, bExecutar)

    //Cria a janela
    oDlgSQL := TDialog():New(0, 0, nJanAltu, nJanLarg, cSayTitulo, , , , , CLR_BLACK, RGB(250, 250, 250), , , .T.)
        //Títulos e SubTítulos
        oSayModulo := TSay():New(004, 003, {|| cSayModulo}, oDlgSQL, "", oFontMod,  , , , .T., RGB(149, 179, 215), , 200, 30, , , , , , .F., , )
        oSayTitulo := TSay():New(004, 045, {|| cSayTitulo}, oDlgSQL, "", oFontSub,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oSaySubTit := TSay():New(014, 045, {|| cSaySubTit}, oDlgSQL, "", oFontSubN, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )

		//Botões
        oBtnExe := TButton():New(001, (nJanLarg/2) - (nLargBtn * 5), "[F5] Executar",      oDlgSQL, bExecutar, nLargBtn*2, 012, , oFontBtnN, , .T., , , , , , )
        oBtnAbr := TButton():New(001, (nJanLarg/2) - (nLargBtn * 3), "Abrir .sql",         oDlgSQL, bAbrir,    nLargBtn,   012, , oFontBtn,  , .T., , , , , , )
        oBtnSal := TButton():New(001, (nJanLarg/2) - (nLargBtn * 2), "Salvar .sql",        oDlgSQL, bSalvar,   nLargBtn,   012, , oFontBtn,  , .T., , , , , , )
        oBtnFec := TButton():New(001, (nJanLarg/2) - (nLargBtn * 1), "Fechar",             oDlgSQL, bFechar,   nLargBtn,   012, , oFontBtn,  , .T., , , , , , )
        oBtnAju := TButton():New(015, (nJanLarg/2) - (nLargBtn * 5), "Ajuda / Help",       oDlgSQL, bAjuda,    nLargBtn,   012, , oFontBtn,  , .T., , , , , , )
		oBtnExp := TButton():New(015, (nJanLarg/2) - (nLargBtn * 4), "Export. Resultado",  oDlgSQL, bExportar, nLargBtn,   012, , oFontBtn,  , .T., , , , , , )
		oBtnInd := TButton():New(015, (nJanLarg/2) - (nLargBtn * 3), "Indentar Query",     oDlgSQL, bIndentar, nLargBtn,   012, , oFontBtn,  , .T., , , , , , )
		oBtnSel := TButton():New(015, (nJanLarg/2) - (nLargBtn * 2), "Gerar Select",       oDlgSQL, bSelect,   nLargBtn,   012, , oFontBtn,  , .T., , , , , , )
		oBtnUpd := TButton():New(015, (nJanLarg/2) - (nLargBtn * 1), "Gerar Update",       oDlgSQL, bUpdate,   nLargBtn,   012, , oFontBtn,  , .T., , , , , , )

        //Observação
        nLinObj := 028
        oSayObs := TSay():New(nLinObj, 003, {|| "Para executar queries: ou 1 = Selecione o texto e aperte F5, ou 2 = Aperte F5 que irá executar todo o texto digitado"}, oDlgSQL, "", oFontBtn, , , , .T., RGB(150, 150, 150), , (nJanLarg/2) - 6, 10, , , , , , .F., , )

        //Cria o editor de consulta SQL
		nLinObj := 038
        oPanSQL := tPanel():New(nLinObj, 3, "", oDlgSQL, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2) - 3, nJanAltMei - 26)
            oEditSQL := TSimpleEditor():Create(oPanSQL)
            oEditSQL:lAutoIndent := .T.
            oEditSQL:TextFamily("Consolas")
            oEditSQL:nWidth := oPanSQL:nWidth
            oEditSQL:nHeight := oPanSQL:nHeight
            oEditSQL:TextFormat(2) //1=Html; 2=Plain Text
            oEditSQL:TextSize(11)
            oEditSQL:Load(cEditSQL)
            oEditSQL:Refresh()

        //Cria o Painel que conterá o resultado
        nLinObj := nJanAltMei + 12
        oPanResult := tPanel():New(nLinObj, 3, "", oDlgSQL, , , , RGB(000,000,000), RGB(200,200,200), (nJanLarg/2) - 3, (nJanAltu/2) - nLinObj - 10)

        //Log dos erros
        nLinObj := (nJanAltu/2) - 10
        oSayLog := TSay():New(nLinObj, 003, {|| cSayLog}, oDlgSQL, "", oFontBtn, , , , .T., RGB(254, 0, 0), , (nJanLarg/2) - 6, 10, , , , , , .F., , )

    //Ativa e exibe a janela
    oDlgSQL:Activate(, , , lCentered, {|| .T.}, , )
Return

/*/{Protheus.doc} fExecutar
Função que executa a instrução SQL
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fExecutar()
    Local cComeco   := ""
    Local cTextoSel := oEditSQL:RetTextSel()
    Local lContinua := .T.
    Local cTexto    := oEditSQL:RetText()
    Private oTempTable := NIL
    //Se estiver em execução, avisa que não é possível
    If lEmExecucao
        cSayLog := "Existe uma query em execução na memória, aguarde o término!"
        oSayLog:Refresh()
        MsgStop(cSayLog, "Atenção")

    //Senão executa a query
    Else
        lEmExecucao := .T.
        //Se existir texto selecionado
        If ! Empty(cTextoSel)
            //Substitui o caractere interrogação por espaço vazio (-enter- e -tab-)
            cTextoSel := StrTran(cTextoSel, "?", '')

        //Senão, será todo o texto digitado
        Else
            cTextoSel := cTexto
        EndIf
        
        //Grava o texto na temporária do S.O.
        fSalvArq(cLastQry)

        //Se houver texto selecionado
        If ! Empty(cTextoSel)

            //Busca o começo da query, até o primeiro espaço
            cComeco := Alltrim(Upper(cTextoSel))
            cComeco := SubStr(cComeco, 1, At(' ', cComeco))

            //Se a query for um Select
            If "SELECT" $ cComeco
                //Se não tiver WHERE nem TOP
                If ! "WHERE" $ Upper(cTextoSel) .And. ! "TOP " $ Upper(cTextoSel)
                    lContinua := MsgYesNo("Não foi encontrado os comandos WHERE e TOP na query, isso pode causar uma lentidão na busca, deseja continuar?", "Executar SELECT")
                EndIf

                //Se for continuar, chama a execução da query
                If lContinua
                    RptStatus({|| fSelecionar(cTextoSel)}, "Processando", "Buscando Registros...")
                EndIf

            //Se for uma manipulação
            ElseIf "UPDATE" $ cComeco .Or. "INSERT" $ cComeco .Or. "DELETE" $ cComeco
                lContinua := MsgYesNo("Comandos de manipulação de dados podem ser prejudiciais para integridade de dados na base, você deseja continuar?", "Atenção")

                //Se for continuar, chama a execução da query
                If lContinua
                    RptStatus({|| fManipular(cTextoSel)}, "Processando", "Atualizando Registros...")
                EndIf

            //Senão, não encontrou
            Else
                cSayLog := "Comando não reconhecido!"
                oSayLog:Refresh()
                MsgStop(cSayLog, "Atenção")
            EndIf
        Else
            cSayLog := "Selecione o texto da query que será executada"
            oSayLog:Refresh()
            MsgInfo(cSayLog, "Atenção")
        EndIf

        lEmExecucao := .F.
    EndIf
    
Return

/*/{Protheus.doc} fAbrir
Função para abrir um arquivo
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fAbrir()
    Local aArea   := GetArea()
    Local cDirIni := cUltPasta
    Local cTipArq := "Arquivos query (*.sql) | Arquivos texto (*.txt)"
    Local cTitulo := "Selecione um arquivo"
    Local lSalvar := .F.
    Local cArqSel := ""
    Local oFile
    Local cArqConteu := ""
 
    //Chama a função para buscar arquivos
    cArqSel := tFileDialog(;
        cTipArq,;  // Filtragem de tipos de arquivos que serão selecionados
        cTitulo,;  // Título da Janela para seleção dos arquivos
        ,;         // Compatibilidade
        cDirIni,;  // Diretório inicial da busca de arquivos
        lSalvar,;  // Se for .T., será uma Save Dialog, senão será Open Dialog
        ;          // Se não passar parâmetro, irá pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT será possível pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY será possível selecionar o diretório
    )

    //Se o arquivo existir
    If ! Empty(cArqSel) .And. File(cArqSel)

        //Tenta abrir o arquivo
        oFile   := FwFileReader():New(cArqSel)
        If oFile:Open()
            //Busca o conteúdo do arquivo
            cArqConteu  := oFile:FullRead()
            oEditSQL:Load(cArqConteu)
            oEditSQL:Refresh()
            oFile:Close()

            cUltPasta := SubStr(cArqSel, 1, RAt("\", cArqSel))
        Else
            cSayLog := "Não foi possível abrir o arquivo"
            oSayLog:Refresh()
            MsgStop(cSayLog, "Atenção")
        EndIf
    EndIf
 
    RestArea(aArea)
Return

/*/{Protheus.doc} fSalvar
Função para salvar um arquivo acionado pelo botão
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fSalvar()
    Local aArea   := GetArea()
    Local cDirIni := cUltPasta
    Local cTipArq := "Arquivos query (*.sql) | Arquivos texto (*.txt)"
    Local cTitulo := "Digite um nome do arquivo e selecione o local"
    Local lSalvar := .T.
    Local cArqSel := ""
 
    //Chama a função para buscar arquivos
    cArqSel := tFileDialog(;
        cTipArq,;  // Filtragem de tipos de arquivos que serão selecionados
        cTitulo,;  // Título da Janela para seleção dos arquivos
        ,;         // Compatibilidade
        cDirIni,;  // Diretório inicial da busca de arquivos
        lSalvar,;  // Se for .T., será uma Save Dialog, senão será Open Dialog
        ;          // Se não passar parâmetro, irá pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT será possível pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY será possível selecionar o diretório
    )

    //Se o arquivo existir
    If ! Empty(cArqSel)
        //Salva o arquivo
        fSalvArq(cArqSel)

        //Atualiza a última pasta
        cUltPasta := SubStr(cArqSel, 1, RAt("\", cArqSel))
    EndIf
 
    RestArea(aArea)
Return

/*/{Protheus.doc} fSalvArq
Função que salva o arquivo em uma pasta
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fSalvArq(cArquivo)
    Local oFWriter
    Local cTexto   := oEditSQL:RetText()
    
    //Grava o arquivo com o conteúdo textual
    oFWriter := FWFileWriter():New(cArquivo, .T.)
    oFWriter:Create()
    oFWriter:Write(cTexto)
    oFWriter:Close()
Return

/*/{Protheus.doc} fConsSX3
Função para abrir a lista de campos do dicionário
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fConsSX3()
    Local lOk     := .F.
    Local aCampos := {}
    Local cTexto  := ""
    Local nAtual
    
    //Chama a consulta
    lOk := u_zConsSX3()

    //Se a consulta for confirmada
    If lOk
        //Se existir o retorno
        If ! Empty(__cRetorn)
            __cRetorn := Alltrim(__cRetorn)
            aCampos := StrTokArr(__cRetorn, ",")

            //Percorre os campos
            For nAtual := 1 To Len(aCampos)
                If ! Empty(aCampos[nAtual])
                    cTexto += "    " + aCampos[nAtual] + "," + CRLF
                EndIf
            Next

            //Atualiza o texto, com o que já existia
            cEditSQL := cTexto + CRLF + oEditSQL:RetText()
            oEditSQL:Load(cEditSQL)
            oEditSQL:Refresh()
        EndIf
    EndIf
Return

/*/{Protheus.doc} fGerSelect
Função que gera uma query SQL
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fGerSelect()
    Local aPergs   := {}
    Local cTabela  := Space(20)
    Local cCampos  := Space(100)
    Local nLinhas  := 0
    Local nOrden   := 1
    Local cQuery   := ""
    
    //Adiciona os parâmetros
    aAdd(aPergs, {1, "Tabela",                          cTabela, "@!",     ".T.",        "", ".T.", 070, .T.})
    aAdd(aPergs, {1, "Campos (separados por vírgula)",  cCampos, "@!",     ".T.",        "", ".T.", 110, .F.})
    aAdd(aPergs, {1, "Número de Linhas (SQL Server)",   nLinhas, "@E 999", "Positivo()", "", ".T.", 040, .F.})
    aAdd(aPergs, {2, "Ordenação",                       nOrden,  {"1=Sem Ordenação", "2=RecNo Decrescente", "3=RecNo Crescente"},   090, ".T.", .F.})
    
    //Se a pergunta foi confirmada
    If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .F., .F.)
        cTabela := Alltrim(MV_PAR01)
        cCampos := Alltrim(MV_PAR02)
        nLinhas := MV_PAR03
        nOrden  := Val(cValToChar(MV_PAR04))

        //Monta a query
        cQuery := " SELECT " + CRLF

        //Se houver quantidade de linhas
        If nLinhas > 0
            cQuery += " TOP " + cValToChar(nLinhas) + " " + CRLF
        EndIf

        //Se houver campos
        If ! Empty(cCampos)
            cQuery += "     " + cCampos + " " + CRLF
        Else
            cQuery += "     * " + CRLF
        EndIf

        //Agora monta o from
        cQuery += " FROM " + CRLF

        //Se o alias tiver só 3 no tamanho, busca com RetSQLName
        If Len(cTabela) == 3
            cQuery += "     " + RetSQLName(cTabela) + " T " + CRLF

        //Senão, será o nome da tabela inteira
        Else
            cQuery += "     " + cTabela + " " + CRLF
        EndIf

        //Agora por último, monta o WHERE default
        cQuery += " WHERE " + CRLF
        
        //Se a tabela for de 3 caracteres, filtra o campo de filial
        If Len(cTabela) == 3
            cQuery += "     " + IIf(SubStr(cTabela, 1, 1) == "S", SubStr(cTabela, 2), cTabela) + "_FILIAL = '" + FWxFilial(cTabela) + "' AND " + CRLF
        EndIf

        //Filtro de campo deletado
        cQuery += "     T.D_E_L_E_T_ = '' " + CRLF

        //Se a ordenação for diferente da padrão
        If nOrden != 1
            cQuery += " ORDER BY " + CRLF

            //Se for decrescente
            If nOrden == 2
                cQuery += "     T.R_E_C_N_O_ DESC " + CRLF

            //Se for crescente
            ElseIf nOrden == 3
                cQuery += "     T.R_E_C_N_O_ ASC " + CRLF
            EndIf
        EndIf

        //Atualiza o texto, com o que já existia
        cEditSQL := cQuery + CRLF + oEditSQL:RetText()
        oEditSQL:Load(cEditSQL)
        oEditSQL:Refresh()
    EndIf
Return

/*/{Protheus.doc} fAjuda
Função que abre a página online de help
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fAjuda()
    Local cLink := "https://terminaldeinformacao.com/ztisql"

    //Abre o link no navegador padrão
    ShellExecute("Open", cLink, "", "", 1)
Return

/*/{Protheus.doc} fManipular
Executa uma query de manipulação na base de dados
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fManipular(cQuery)
    Local nStatus   := 0
    Local cMensagem := ""
    Local cInicio   := Time()
    Local cTermino  := ""

    SetRegua(2)

    //Se a grid existe, exclui ela
    If Type("oMResult") != "U"
        oMResult := Nil
        FreeObj(oMResult)
    EndIf

    //Se o label existe, exclui ele
    If Type("oEditResult") != "U"
        oEditResult := Nil
        FreeObj(oEditResult)
    EndIf

    //Agora irá executar a query
    IncRegua()
    nStatus  := TCSQLExec(cQuery)
    cTermino := Time()

    //Se houve erro
    If (nStatus < 0)
        cMensagem := "Erro na execução da query: " + CRLF + CRLF
        cMensagem += TCSQLError()
    Else
        cMensagem := "Comando executado com sucesso!"
    EndIf

    //Cria o label avisando do resultado
    oEditResult := TSimpleEditor():Create(oPanResult)
    oEditResult:lAutoIndent := .T.
    oEditResult:TextFamily("Consolas")
    oEditResult:nWidth := oPanResult:nWidth
    oEditResult:nHeight := oPanResult:nHeight
    oEditResult:TextFormat(2) //1=Html; 2=Plain Text
    oEditResult:TextSize(09)
    oEditResult:Load(cMensagem)
    oEditResult:Refresh()
    oEditResult:lReadOnly := .T.

    //Atualiza o log com o tempo total
    fAtuLog(cInicio, cTermino, 0)
Return

/*/{Protheus.doc} fZeraLog
Função acionada para zerar o log do rodapé
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fZeraLog()
    cSayLog := ""
    oSayLog:Refresh()
Return

/*/{Protheus.doc} fZeraLog
Função para atualizar o log com o tempo de execução da query
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fAtuLog(cInicio, cTermino, nQtdLinhas)
    cSayLog := "Inicio: " + cInicio
    cSayLog += " | Termino: " + cTermino
    cSayLog += " | Tempo Total: " + ElapTime(cInicio, cTermino)
    If nQtdLinhas != 0
        cSayLog += " | Quantidade de Linhas: " + cValToChar(nQtdLinhas)
    EndIf
    oSayLog:Refresh()
Return

/*/{Protheus.doc} fGerUpdate
Função que gera uma query SQL de atualização (update)
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fGerUpdate()
    Local aPergs     := {}
    Local cTabela    := Space(20)
    Local cCampo     := Space(20)
    Local cConteud   := Space(100)
    Local cQuery     := ""
    Local cTipoCampo := ""
    
    //Adiciona os parâmetros
    aAdd(aPergs, {1, "Tabela",                                        cTabela,  "@!",     ".T.",        "", ".T.", 070, .T.})
    aAdd(aPergs, {1, "Campo",                                         cCampo,   "@!",     ".T.",        "", ".T.", 100, .T.})
    aAdd(aPergs, {1, "Conteúdo",                                      cConteud, "",       ".T.",        "", ".T.", 100, .T.})
    
    //Se a pergunta foi confirmada
    If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .F., .F.)
        cTabela   := Alltrim(MV_PAR01)
        cCampo    := Alltrim(MV_PAR02)
        cConteud  := Alltrim(MV_PAR03)

        //Monta a query
        cQuery := " UPDATE " + CRLF

        //Se o alias tiver só 3 no tamanho, busca com RetSQLName
        If Len(cTabela) == 3
            cQuery += "     " + RetSQLName(cTabela) + " " + CRLF

        //Senão, será o nome da tabela inteira
        Else
            cQuery += "     " + cTabela + " " + CRLF
        EndIf

        //Agora monta a atualização
        cQuery += " SET " + CRLF
        cQuery += "     " + cCampo + " = "

        //Se o campo existe no dicionário
        If GetSX3Cache(cCampo, "X3_TITULO") != ""
            //Busca o tipo do campo
            cTipoCampo := GetSX3Cache(cCampo, "X3_TIPO")

            //Se for data
            If cTipoCampo == 'D'
                //Se o conteúdo tiver barra
                If "/" $ cConteud
                    cConteud := dToS(cToD(cConteud))
                EndIf
            EndIf

            //Se o tipo do campo for caractere ou data
            If cTipoCampo $ 'C,D'
                //Se o conteúdo já tiver apóstrofo
                If "'" $ cConteud
                    cQuery += cConteud
                Else
                    cQuery += "'" + cConteud + "'"
                EndIf

            //Senão, atualiza com conteúdo default
            Else
                cQuery += cConteud
            EndIf

        //Senão, pega exatamente como o usuário digitou
        Else
            cQuery += cConteud
        EndIf
        cQuery += " " + CRLF

        //Agora por último, monta o WHERE default
        cQuery += " WHERE " + CRLF
        
        //Se a tabela for de 3 caracteres, filtra o campo de filial
        If Len(cTabela) == 3
            cQuery += "     " + IIf(SubStr(cTabela, 1, 1) == "S", SubStr(cTabela, 2), cTabela) + "_FILIAL = '" + FWxFilial(cTabela) + "' AND " + CRLF
        EndIf

        //Filtro de campo deletado
        cQuery += "     D_E_L_E_T_ = '' " + CRLF

        //Atualiza o texto, com o que já existia
        cEditSQL := cQuery + CRLF + oEditSQL:RetText()
        oEditSQL:Load(cEditSQL)
        oEditSQL:Refresh()
    EndIf
Return

/*/{Protheus.doc} fSelecionar
Executa uma query de seleção na base de dados
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fSelecionar(cQuery)
    Local nStatus   := 0
    Local cMensagem := ""
    Local cInicio   := Time()
    Local cTermino  := ""
    Local aEstrut   := {}
    Local nCampo    := 0
    Local cCampo
    Local cTitulo
    Local cMascara
    Local nQtdLinhas := 0
    Local cAliasGrid := GetNextAlias()

    SetRegua(3)

    //Se tiver aberto o alias, fecha ele
    If Select(cAliasGrid) > 0
        (cAliasGrid)->(DbCloseArea())
    EndIf
    cAliasResu := cAliasGrid

    //Se a grid existe, exclui ela
    If Type("oMResult") != "U"
        oMResult := Nil
        FreeObj(oMResult)
    EndIf

    //Se o label existe, exclui ele
    If Type("oEditResult") != "U"
        oEditResult := Nil
        FreeObj(oEditResult)
    EndIf

    //Agora irá executar a query
    IncRegua()
    nStatus  := TCSQLExec(cQuery)
    cTermino := Time()

    //Se houve erro
    If (nStatus < 0)
        cMensagem := "Erro na execução da query de SELECT: " + CRLF + CRLF
        cMensagem += TCSQLError()

        //Cria o label avisando do resultado
        oEditResult := TSimpleEditor():Create(oPanResult)
        oEditResult:lAutoIndent := .T.
        oEditResult:TextFamily("Consolas")
        oEditResult:nWidth := oPanResult:nWidth
        oEditResult:nHeight := oPanResult:nHeight
        oEditResult:TextFormat(2) //1=Html; 2=Plain Text
        oEditResult:TextSize(09)
        oEditResult:Load(cMensagem)
        oEditResult:Refresh()
        oEditResult:lReadOnly := .T.
    Else

        //Executa a query
        IncRegua()
        TCQuery cQuery New Alias "TMP_SQL"
        Count To nQtdLinhas
        TMP_SQL->(DbGoTop())
        cTermino := Time()
        
        //Percorre a estrutura e retira campos reservados
        aEstrutTmp   := TMP_SQL->(DbStruct())
        aEstrut      := {}
        For nCampo := 1 To Len(aEstrutTmp)
            cCampo := Alltrim(aEstrutTmp[nCampo][1])

            //Se o campo não for um reservado, adiciona na estrutura que será usada na grid
            If ! cCampo $ "R_E_C_N_O_ , R_E_C_D_E_L_ , D_E_L_E_T_,S_T_A_M_P_,I_N_S_D_T_"
                aAdd(aEstrut, aClone(aEstrutTmp[nCampo]))
            EndIf
        Next

        //Percorre a estrutura, para montar o cabeçalho da grid
        aHeadResu := {}
        For nCampo := 1 To Len(aEstrut)
            cCampo := aEstrut[nCampo][1]

            //Se o campo existir no dicionário, busca o título e a máscara dele
            If GetSX3Cache(cCampo, "X3_TITULO") != ""
                cTitulo  := Alltrim(GetSX3Cache(cCampo, "X3_TITULO")) + " (" + Alltrim(cCampo) + ")"
                cMascara := GetSX3Cache(cCampo, "X3_PICTURE")
            Else
                cTitulo  := cCampo
                cMascara := ""
            EndIf

            //Adiciona no cabeçalho que será usado na grid
            aAdd(aHeadResu, {cCampo, , cTitulo, cMascara})
        Next

        //Cria a temporária que vai ser usada na grid
        oTempTable := FWTemporaryTable():New(cAliasGrid)
        oTempTable:SetFields(aEstrut)
		oTempTable:Create()

        //Agora copia os dados da query para a temporária
        DbSelectArea(cAliasGrid)
        Append From TMP_SQL
        TMP_SQL->(DbCloseArea())
        (cAliasGrid)->(DbGoTop())

        //Cria a grid
        oMResult := MsSelect():New(cAliasGrid, /*cCampo*/, /*cCpo*/, aHeadResu, /*lInv*/, /*cMar*/, {0, 0, oPanResult:nHeight / 2, oPanResult:nWidth / 2}, /*cTopFun*/, /*cBotFun*/, oPanResult)
        oMResult:oBrowse:SetCSS(u_zCSSGrid())
        oMResult:oBrowse:Refresh()
    EndIf

    //Atualiza o log com o tempo total
    fAtuLog(cInicio, cTermino, nQtdLinhas)
Return

/*/{Protheus.doc} fExportar
Função para exportar o resultado da query para arquivo
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fExportar()
    Local aArea     := GetArea()
    Local cDirIni   := cUltPasta
    Local cTipArq   := "Planilha do Excel - requer PRINTER mais novo (*.xlsx) | Planilha do Excel em XML (*.xml) | Arquivo texto (*.txt)"
    Local cTitulo   := "Selecione um local para gerar"
    Local lSalvar   := .T.
    Local cArqSel   := ""
    Local cExtensao := ""
    Local cPasta    := ""
    Local cArquivo  := ""
    Private cDelim  := ""
 
    //Se tiver grid
    If Type("oMResult") != "U"
        //Chama a função para buscar arquivos
        cArqSel := tFileDialog(;
            cTipArq,;  // Filtragem de tipos de arquivos que serão selecionados
            cTitulo,;  // Título da Janela para seleção dos arquivos
            ,;         // Compatibilidade
            cDirIni,;  // Diretório inicial da busca de arquivos
            lSalvar,;  // Se for .T., será uma Save Dialog, senão será Open Dialog
            ;          // Se não passar parâmetro, irá pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT será possível pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY será possível selecionar o diretório
        )

        //Se o arquivo existir
        If ! Empty(cArqSel)
            //Pega a extensão do arquivo
            cExtensao := Alltrim(Upper(cArqSel))
            cExtensao := SubStr(cExtensao, RAt(".", cExtensao) + 1)

            //Separa a pasta do arquivo
            cPasta   := SubStr(cArqSel, 1, RAt('\', cArqSel))
            cArquivo := StrTran(cArqSel, cPasta, '')

            //Se for texto
            If cExtensao == "TXT"
                DbSelectArea(cAliasResu)
                (cAliasResu)->(DbGoTop())

                //Realiza a exportação
                Copy To (cPasta + cArquivo) DELIMITED WITH (cDelim)

                //Abre o arquivo
                ShellExecute("OPEN", cArquivo, "", cPasta, 1)
            
            //Senão, se for planilha do Excel antiga
            ElseIf cExtensao == "XML"
                RptStatus({|| fExcel(cArqSel, 1)}, "Exportando", "Gerando Excel...")

            //Senão, se for planilha do Excel
            ElseIf cExtensao == "XLSX"
                RptStatus({|| fExcel(cArqSel, 2)}, "Exportando", "Gerando Excel...")

                //Abre o arquivo
                ShellExecute("OPEN", cArquivo, "", cPasta, 1)
            EndIf

            cUltPasta := SubStr(cArqSel, 1, RAt("\", cArqSel))
        EndIf

    Else
        cSayLog := "Para acionar a exportação, execute um SELECT"
        oSayLog:Refresh()
        MsgStop(cSayLog, "Atenção")
    EndIf

    RestArea(aArea)
Return

/*/{Protheus.doc} fExcel
Função para o Excel da tabela temporária
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fExcel(cArquivo, nTipo)
	Local oFWMsExcel
	Local cWorkSheet := "zTiSQL"
	Local cTitulo    := "Exportacao de dados"
	Local nTotal := 0
    Local nCampo
    Local aLinha
	
    //Define o tamanho da régua
	DbSelectArea(cAliasResu)
    (cAliasResu)->(DbGoTop())
    Count To nTotal
    SetRegua(nTotal)
    (cAliasResu)->(DbGoTop())
	
	//Cria a planilha do excel
    If nTipo == 1
        oFWMsExcel := FwMsExcel():New()
    ElseIf nTipo == 2
	    oFWMsExcel := FwMsExcelXlsx():New()
    EndIf
	
	//Criando a aba da planilha
	oFWMsExcel:AddworkSheet(cWorkSheet)
	
	//Criando a Tabela e as colunas
	oFWMsExcel:AddTable(cWorkSheet, cTitulo)
    For nCampo := 1 To Len(aHeadResu)
        //Pega o tipo do campo
        nTipo  := 1 //General
        nAlign := 1 //Left
        If GetSX3Cache(aHeadResu[nCampo][1], "X3_TIPO") == "N"
            nTipo  := 2 //Number
            nAlign := 3 //Right
        EndIf

        //Adiciona a coluna
        oFWMsExcel:AddColumn(cWorkSheet, cTitulo, aHeadResu[nCampo][3], nAlign, nTipo, .F.)
    Next
	
	//Percorrendo os dados da query
	While !((cAliasResu)->(EoF()))
		
		//Incrementando a regua
		IncRegua()

        //Cria uma nova linha
        aLinha := {}
        For nCampo := 1 To Len(aHeadResu)
            aAdd(aLinha, (cAliasResu)->(&(aHeadResu[nCampo][1])))
        Next
		
		//Adicionando uma nova linha
		oFWMsExcel:AddRow(cWorkSheet, cTitulo, aClone(aLinha))
		
		(cAliasResu)->(DbSkip())
	EndDo
	
	//Ativando o arquivo e gerando
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)
    oFWMsExcel:DeActivate()

    //Se for em XML, força abrir pelo Excel
    If nTipo == 1
        //Abrindo o excel e abrindo o arquivo xml
        oExcel := MsExcel():New()
        oExcel:WorkBooks:Open(cArquivo)
        oExcel:SetVisible(.T.)
        oExcel:Destroy()
    EndIf
Return

/*/{Protheus.doc} fExcel
Função para abrir uma URL com a query para indentação
@type  Function
@author Daniel Atilio
@since 19/12/2020
@version version
@see https://terminaldeinformacao.com
/*/

Static Function fIndentar()
    Local cTextoSel := oEditSQL:RetTextSel()
    Local cLink     := "https://www.freeformatter.com/sql-formatter.html?sqlString="

    //Se tiver vazio o texto selecionado, mostra a mensagem
    If Empty(cTextoSel)
        cSayLog := "Selecione o texto para que seja possível indentar!"
        oSayLog:Refresh()
        MsgStop(cSayLog, "Atenção")
    Else
        //Substitui o caractere interrogação por espaço vazio (-enter- e -tab-)
        cTextoSel := StrTran(cTextoSel, "?", '')

        //No link, será enviado a query
        cLink += cTextoSel
        ShellExecute("Open", cLink, "", "", 1)
    EndIf
Return
