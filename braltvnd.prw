#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*/{Protheus.doc} BRALTVND
Permite a alteração de Vendedores cadastrados nos clientes em massa
@type function Processamento
@version  1.0
@author marioantonaccio
@since 10/03/2026
@return character, sem retorno
/*/
User Function BRALTVND()

    Local aButtons := {}  as Array
    Local aPerg    := {}  as Array
    Local aSays    := {}  as Array
    Local cPerg    := " " as Character
    Local lOk      := .F. as Logical

    //Verifica se usuario tem acesso a funcao
    If .NOT. U_VldAcesso(FUNNAME())
        FwAlertError("Acesso NÃO autorizado---->"+FUNNAME(),"Atenção")
        Return (NIL)
    End
    //Identifica se a rotina esta em uso
    If .NOT. SuperGetMV("BR_ALTVND",.F.,.F.)
        FwAlertError("Rotina nao Liberada para uso!","Atenção (BR_ALTVND)")
        Return(NIL)
    End

    U_ZCFGA01( 'BRALTVND' )

    cPerg        := "BRALTVND"
    AADD(aPerg,{cPerg, "01", "Alterar Vendedor DE?","MV_PAR01", "MV_CH1", "C", TamSX3('A3_COD')[01], 0, 0,"G", "","SA3", "","","","","",""})
    AADD(aPerg,{cPerg, "02", "Para Vendedor ?"     ,"MV_PAR02", "MV_CH2", "C", TamSX3('A3_COD')[01], 0, 0,"G", "","SA3", "","","","","",""})
    AADD(aPerg,{cPerg, "03", "Do Cliente    ?"     ,"MV_PAR03", "MV_CH3", "C", TamSX3('A1_COD')[01], 0, 0,"G", "","SA1", "","","","","",""})
    AADD(aPerg,{cPerg, "04", "Ate Cliente   ?"     ,"MV_PAR04", "MV_CH4", "C", TamSX3('A1_COD')[01], 0, 0,"G", "","SA1", "","","","","",""})

    //Se nao existir as perguntas na SX1, ele cria
    If .NOT. FWSX1Util():ExistPergunte(cPerg)
        XCRIASX1(cPerg,.F.,aPerg)
    Else
        XCRIASX1(cPerg,.T.,aPerg)
    End

    //Popula as linhas que serão mostradas na tela
    aAdd(aSays, "Esse programa tem como objetivo efetuar a troca de um vendedor/Representante")
    aAdd(aSays, "no cadastro de Clientes (SA1) por outro.")

    //Botões da tela, cada botão tem um Bloco de Código
    aAdd(aButtons, { 5, .T., {|| Pergunte(cPerg, .T. ) } } )
    aAdd(aButtons, { 1, .T., {|| lOk := .T., FechaBatch() }} )
    aAdd(aButtons, { 2, .T., {|| lOk := .F., FechaBatch() }} )

    //Chama a tela principal
    FormBatch("Alteração de Vendedor/Representante", aSays, aButtons)

    //Se foi confirmado a tela
    If lOk
        Processa( { |lEnd| BRALTV01() }, "Processando Alteração Vendedor/Representante.....")
    EndIf

Return (NIL)

/*/{Protheus.doc} BRALTV01
Processo de alteração de vendedores e gravação de logs
@type function Processamento
@version  1.00
@author marioantonaccio
@since 10/03/2026
@return character, sem retorno
/*/
Static Function BRALTV01()

    Local aCampos  := {} as array
    Local aConteud := {} as array
    Local cCampo         as character
    Local cMsg           as character
    Local nI             as numeric
    Local nReg     := 0  as Numeric
    Local nRegOk   := 0  as Numeric

    // Verifica PArametros obrigatorios
    If Empty(mv_par01) .Or. Empty(mv_par02)
        FWAlertError("Parametros de Vendedor Origem e Destino devem ser informados!!", "Parametros Incompletos")
        Return(NIL)
    End
    If mv_par01 == mv_par02
        FWAlertError("Vendedor/Representante de Origem e Destino nao podem ser iguais!!", "Parametros Invalidos")
        Return(NIL)
    EndIf
    SA3->(dbSetOrder(1))
    If .NOT. SA3->(DbSeek(xFilial("SA3") + mv_par01))
        FWAlertError("Vendedor/Representante Origem nao encontrado!!", "Vendedor/Representante Invalido")
        Return(NIL)
    End

    If .NOT. SA3->(DbSeek(xFilial("SA3") + mv_par02))
        FWAlertError("Vendedor/Representante Destino nao encontrado!!", "Vendedor/Representante Invalido")
        Return(NIL)
    Else
        If SA3->A3_MSBLQL == '1'
            FWAlertError("Vendedor/Representante Destino esta bloqueado para vendas!!", "Vendedor/Representante Bloqueado")
            Return(NIL)
        EndIf
    End

    SA1->(dbSetOrder(1))
    If .NOT. Empty(mv_par03) .And. .NOT. SA1->(DbSeek(xFilial("SA1") + mv_par03))
        FWAlertError("Cliente Inicial nao encontrado!!", "Cliente Invalido")
        Return(NIL)
    End

    If .NOT. Empty(mv_par04) .And. .NOT. SA1->(DbSeek(xFilial("SA1") + mv_par04))
        FWAlertError("Cliente Final nao encontrado!!", "Cliente Invalido")
        Return(NIL)
    End

    // Fim validação Parametros

    aCampos  :={"A1_VEND", "A1_X_EXPO", "A1_X_SIM3G"}

    //Seleciona os Registros
    BeginSql AlIAS "XSA1"
        SELECT
            R_E_C_N_O_ AS REGSA1
        FROM
            %TABLE:SA1%
        WHERE
            %NOTDEL%
            AND A1_VEND = %EXP:MV_PAR01%
            AND A1_COD >= %EXP:MV_PAR03%
            AND A1_COD <= %EXP:MV_PAR04%
    EndSQL

    //Contaem de registros conforme parametro
    nReg:=CONTAR("XSA1",".NOT. EOF()")

    // Se nao existir registros retorna
    If nReg == 0
        XSA1->(dbCloseArea())
        FWAlertError("Nao existem Clientes Cadastrados para esse Vendedor: "+mv_par01, "Sem Clientes")
        Return(NIL)
    End

    cMsg:="Existem "+cValToChar(nReg)+ " Clientes"+CRLF
    cMsg+="para esse vendedor: "+mv_par01+CRLF+CRLF
    cMsg+="Deseja efetuar a Alteração desse vendedor "+mv_par01+ " para esse:" +mv_par02+" ?"

    //Confirma execução rotina
    If FWAlertNoYes(cMsg, "Alteração de Vendedor")

        SA1->(dbSetOrder(1))

        XSA1->(dbGoTop())

        ProcRegua(nReg)

        While XSA1->(.NOT. EOF())

            IncProc("Processando...")

            SA1->(dbGoTo(XSA1->REGSA1))

            If SA1->A1_VEND == mv_par01

                //Guarda Conteudo anterior do campo
                For nI:=1 To Len(aCampos)
                    cCampo:="SA1->"+aCampos[nI]
                    AADD(aConteud,&cCampo)
                Next

                // Atualiza Campos
                RecLock("SA1",.F.)
                SA1->A1_VEND:= mv_par02
                SA1->A1_X_EXPO :=" "
                SA1->A1_X_SIM3G:="S"
                MSUnLock()

                //Grava Log
                ZAJ->(dbSetOrder(1))
                For nI:=1 To Len(aCampos)

                    cCampo:="SA1->"+aCampos[nI]

                    If aConteud[nI] <> &cCampo

                        ZAJ->(dbSetOrder(1))
                        RecLock("ZAJ",.T.)
                        ZAJ->ZAJ_FILIAL := FWxFilial( 'ZAJ' )
                        ZAJ->ZAJ_NUMERO := "ALTVEN "
                        ZAJ->ZAJ_FORNEC := SA1->A1_COD
                        ZAJ->ZAJ_LOJA   := SA1->A1_LOJA
                        ZAJ->ZAJ_PROD   := "Rot:BRALTVND"
                        ZAJ->ZAJ_CAMPO  := aCampos[nI]
                        ZAJ->ZAJ_DE     := aConteud[nI]
                        ZAJ->ZAJ_PARA   := &cCampo
                        ZAJ->ZAJ_SEQ    := cValToChar(nI)
                        ZAJ->ZAJ_DTALT  := dDataBase
                        ZAJ->ZAJ_HORA   := Time()
                        ZAJ->ZAJ_USRALT := cUserName
                        ZAJ->ZAJ_TIPO   := "VD"
                        MsUnLock()
                    End

                Next
                nRegOk++
            End

            XSA1->(dbSkip())

        End

        cMsg:="Rotina Finalizada Com SUCESSO!!!"+CRLF
        cMsg+="Registros Alterados: "+cValToChar(nRegOk)
        FWAlertSuccess(cMsg, "Rotina Finalizada")

        If FWAlertYesNo("Deseja ver o Log de Alteração?", "LOG de alterações")
            BRALTV02()
        End
    Else
        //Abortado rotina
        FWAlertError("Transferencia de vendedor/representante nao realizada!!", "Rotina nao executada")
    End

    XSA1->(dbCloseArea())

Return(Nil)

/*/{Protheus.doc} xCriaSX1
Grava Perguntas na SX1
@type function Processamento
@version  1.0
@author marioantonaccio
@since 11/03/2026
@param cPerg, character, Grupo de perguntas
@param lAchou, logical, Indica se já encontrou o grupo
@param aPerg, array, Paramentors das perguntas
@return character, sem retorno
/*/
Static Function xCriaSX1(cPerg,lAchou,aPerg)

    Local aPergunte  as Array
    Local cGrupo     as Character
    Local lOk := .F. as Logical
    Local nI         as Numeric
    Local nSpace     as Numeric
    Local oFWSX1     as Object

    If lAchou
        oFWSX1 := FWSX1Util():New()

        oFWSX1:AddGroup(cPerg)
        oFWSX1:SearchGroup()

        aPergunte := oFWSX1:GetGroup(cPerg)

        If Len (aPergunte[2])  <>  Len(aPerg)
            lOk:=.T.
        End
        aSize(aPergunte,0)
        oFWSX1:Destroy()
        FreeObj(oFWSX1)
    Else
        lOk:=.T.
    End

    If lOk

        SX1->(dbSetOrder(1))

        For nI:=1 To Len(aPerg)
            nSpace := Len(SX1->X1_GRUPO) - Len(AllTrim(aPerg[nI][1]))
            cGrupo:=AllTrim(aPerg[nI][1])+Space(nSpace)
            If .NOT. SX1->(DbSeek(cGrupo+aPerg[nI][02]))
                RecLock('SX1', .T.)
            Else
                RecLock('SX1', .F.)
            End
            X1_GRUPO   := aPerg[nI][01]
            X1_ORDEM   := aPerg[nI][02]
            X1_PERGUNT := aPerg[nI][03]
            X1_PERSPA  := aPerg[nI][03]
            X1_PERENG  := aPerg[nI][03]
            X1_VAR01   := aPerg[nI][04]
            X1_VARIAVL := aPerg[nI][05]
            X1_TIPO    := aPerg[nI][06]
            X1_TAMANHO := aPerg[nI][07]
            X1_DECIMAL := aPerg[nI][08]
            X1_PRESEL  := aPerg[nI][09]
            X1_GSC     := aPerg[nI][10]
            X1_VALID   := aPerg[nI][11]
            X1_F3      := aPerg[nI][12]
            X1_PICTURE := aPerg[nI][13]
            X1_DEF01   := aPerg[nI][14]
            X1_DEFSPA1 := aPerg[nI][14]
            X1_DEFENG1 := aPerg[nI][14]
            X1_DEF02   := aPerg[nI][15]
            X1_DEFSPA2 := aPerg[nI][15]
            X1_DEFENG2 := aPerg[nI][15]
            X1_DEF03   := aPerg[nI][16]
            X1_DEFSPA3 := aPerg[nI][16]
            X1_DEFENG3 := aPerg[nI][16]
            X1_DEF04   := aPerg[nI][17]
            X1_DEFSPA4 := aPerg[nI][17]
            X1_DEFENG4 := aPerg[nI][17]
            X1_DEF05   := aPerg[nI][18]
            X1_DEFSPA5 := aPerg[nI][18]
            X1_DEFENG5 := aPerg[nI][18]
            MsUnLock()
        Next
    End

Return Nil

/*/{Protheus.doc} BRALTV02()
Geraçao e impressao de arquivo de LOG de Alterações
@type function Relatorio
@version  1.0
@author marioantonaccio
@since 11/03/2026
@return character, sem retorno
/*/
Static Function BRALTV02()

    Private oReport                  as Object
    Private oSecSC                   as Object

    //Cria as definições do relatório
    oReport := ReportDef()
    oReport:PrintDialog()

Return (NIL)

/*/{Protheus.doc} ReportDef
Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS  monta a janela com a regua de processamento.
@type function Processamento
@version  1.0
@author marioantonaccio
@since 30/01/2026
@return object, Objeto Report
/*/
Static Function ReportDef()

    Local cTitle  as Character
    Local oReport as Object

    cTitle := "Log de Alteração de Vendedor"
    //--------------------------------------------------------------------------
    //³Criacao do componente de impressao                                      ³
    //³                                                                        ³
    //³TReport():New                                                           ³
    //³ExpC1 : Nome do relatorio                                               ³
    //³ExpC2 : Titulo                                                          ³
    //³ExpC3 : Pergunte                                                        ³
    //³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
    //³ExpC5 : Descricao                                                       ³
    //³                                                                        ³
    //--------------------------------------------------------------------------
    oReport:=TReport():New("BRALTV02",cTitle,"", {|oReport| _FQuery(),RPrintCom(oReport)},;
        "Este programa emite o Relatorio de LOG de Alteracao de Vendedor/Representante.")

    oReport:lParamPage:=.F.
    oReport:lTotalInLine:=.F.
    oReport:SetLandScape()
    oReport:nFontBody := 8
    oReport:nLineHeight := 30
    oReport:lDisableOrientation:=.F.
    oReport:nEnvironment:=2
    oReport:lEdit:=.F.
    oReport:SetLeftMargin(1)

    oSecSC:= TRSection():New(oReport,"Processo")
    oSecSC:SetHeaderPage()
    oSecSC:nLinesBefore := 0

Return(oReport)

/*/{Protheus.doc} RPrintCom
Processa as informacoes e imprime o relatorio
@type function Processamento
@version  1.0
@author marioantonaccio
@since 30/01/2026
@param oReport, object, Obejto do relatorio
@return character, sem retorno
@see
//oSection1:SetTotalInLine(.F.)
//DEFINE FUNCTION FROM oSection1:Cell('PAC_COMIS') FUNCTION SUM NO END SECTION PICTURE '@E@Z 999.99'
oSecSC:Cell("NQTD"):Hide()
/*/
Static Function RPrintCom(oReport)

    Local cTitulo       := oReport:Title()    as Object
    Local oSecSC        := oReport:Section(1) as Object
    Private lEndPage    := .F.                as Logical
    Private lEndRep     := .T.                as Logical
    Private lEndReport  := .T.                as Logical
    Private lEndSection := .T.                as Logical

    oSecSC := oReport:Section(1)

    TRCell():New(oSecSC,"ZAJ_FORNEC"	,"   ","Cliente"	    ," ",TamSX3('ZAJ_FORNEC')[01]   	,/*lPixel*/,{||XDEM->ZAJ_FORNEC},"LEFT")
    TRCell():New(oSecSC,"ZAJ_LOJA"	    ,"   ","Loja"	        ," ",TamSX3('ZAJ_LOJA')[01]		    ,/*lPixel*/,{||XDEM->ZAJ_LOJA},"LEFT")
    TRCell():New(oSecSC,"NOMECLI"		,"   ","Nome Cliente"	," ",20								,/*lPixel*/,{||Substr(AllTRim(Posicione("SA1",1,xFilial("SA1")+XDEM->ZAJ_FORNEC+XDEM->ZAJ_LOJA,"A1_NREDUZ")),1,12)},"LEFT")
    TRCell():New(oSecSC,"NCAMPO"		,"   ","Campo Alterado"	," ",20								,/*lPixel*/,{||RetTitle(XDEM->ZAJ_CAMPO)},"LEFT")
    TRCell():New(oSecSC,"ZAJ_DE"		,"   ","DE"				,"@!",TamSX3("ZAJ_DE")[01]+5		,/*lPixel*/,{||XDEM->ZAJ_DE},"LEFT")
    TRCell():New(oSecSC,"ZAJ_PARA"		,"   ","PARA"			,"@!",TamSX3("ZAJ_PARA")[01]		,/*lPixel*/,{||XDEM->ZAJ_PARA},"LEFT")
    TRCell():New(oSecSC,"ZAJ_DTALT"	    ,"   ","Data Alter"		,"@D",TamSX3("ZAJ_DTALT")[01]+5		,/*lPixel*/,{||XDEM->ZAJ_DTALT},"LEFT")
    TRCell():New(oSecSC,"ZAJ_HORA"		,"   ","Hora Alter"		,"@!",TamSX3("ZAJ_HORA")[01]+5		,/*lPixel*/,{||XDEM->ZAJ_HORA},"LEFT")
    TRCell():New(oSecSC,"ZAJ_USRALT"	,"   ","Usuario Alt"	," ",TamSX3("ZAJ_USRALT")[01]		,/*lPixel*/,{||XDEM->ZAJ_USRALT},"LEFT")

    // Quebra 1 - Solicitacao
    oBreak1 := TRBreak():New(oSecSC,{|| (XDEM->ZAJ_PROD) },"Processo")

    oReport:SetTotalInLine(.F.)
    oReport:lUnderLine := .F.

    dbSelectArea("XDEM")
    nCount:=Contar("XDEM",".NOT. EOF()")
    XDEM->(dbGotop())

    // Titulo
    oReport:SetTitle(cTitulo)

    // Regua
    oReport:SetMeter(nCount)

    // Esconde a Secao referente a Filial para impressao somente dos totais
    oReport:cFontBody := 'Courier New'
    oReport:nFontBody := 6
    oReport:EndReport(.F.)

    oSecSC:lHeaderSection := .T.
    oSecSC:Init()

    While .NOT. oReport:Cancel() .And. .NOT. XDEM->(EOF())

        If oReport:Cancel()
            Exit
        EndIf

        oReport:SetMsgPrint("Imprimindo ...")
        oReport:SkipLine()
        oReport:IncMeter()

        oSecSC:PrintLine()

        If oReport:nDevice == 4 .And. oSecSC:lHeaderSection
            oReport:lHeaderVisible := .F.
            oSecVend:lHeaderSection := .F.
        EndIf

        XDEM->(DbSkip())

    End
    oSecSC:Finish()

    dbSelectArea("XDEM")

    oReport:Finish()

    If Select ("XDEM") > 0
        XDEM->(DbCloseArea())
    EndIf

Return (NIL)

/*/{Protheus.doc} _FQuery
Motagem Uqry para filtro
@type function Processamento
@version  1.0
@author marioantonaccio
@since 30/01/2026
@return character, sem retorno
/*/
Static Function _FQuery()

    //Montando consulta de dados
    BeginSql Alias "XDEM"
        COLUMN ZAJ_DTALT AS DATE
        SELECT
            ZAJ_PROD,
            ZAJ_FORNEC,
            ZAJ_LOJA,
            ZAJ_CAMPO,
            ZAJ_DE,
            ZAJ_PARA,
            ZAJ_DTALT,
            ZAJ_HORA,
            ZAJ_USRALT
        FROM
            %TABLE:ZAJ%
        WHERE
            %NOTDEL%
            AND ZAJ_FILIAL = %XFILIAL:ZAJ%
            AND ZAJ_DTALT = %EXP:DTOS(dDataBase)%
            AND ZAJ_TIPO = 'VD'
            AND RTRIM(ZAJ_DE) <> RTRIM(ZAJ_PARA)
        ORDER BY
            ZAJ_HORA,
            ZAJ_PROD,
            ZAJ_FORNEC,
            ZAJ_LOJA
    EndSQL

Return (NIL)
