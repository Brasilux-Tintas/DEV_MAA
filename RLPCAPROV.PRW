//Bibliotecas
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#Include "Totvs.ch"
#Include 'Protheus.ch'

/*/{Protheus.doc} RPCAPROV
Listagem de Pedido de Compras Aprovado Automaticamente
@type function Relatorio
@version  1.0
@author Andreia Domingos
@since 15/10/2025
@return Character, sme retorno
/*/
User Function RPCAPROV()

    Local aArea   := FWGetArea()
    Local aPergs  := {}
    Local cfilde  := Space(TamSX3( 'CR_FILIAL' )[1])
    Local cfilAte := StrTran(cfilde, ' ' , 'Z' )
    Local cNumDe  := Space(TamSX3( 'CR_NUM' )[1])
    Local cNumAte := StrTran(cNumDe, ' ' , 'Z' )
    Local dDatade := Ctod(Space(8))
    Local dDataAt := Ctod(Space(8))
    Local nMV //Contador de parametros para salvar - MAAA 20251023
    Local aMvPar  := {} // Array para armazenar parametros - mAA 20251023

    Private oFWMsExcel
    Private cWorkSheet := "Pedido de Compras Aprovado Automaticamente"
    // Private cValor := Alltrim(Transform(SE2->E2_VALOR, "@E 9,999,999.99"))
    Private cTitulo    := "Listagem de Pedido de Compras Aprovado Automaticamente"
    //Private nRecnose2  := Recno()

    // Preserva os mv_par pois a função parambox altera os mesmos MAA 20251023
    For nMv := 1 To 60 // 60 é numero de parametros ativos
        aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
    Next nMv

    //Adicionando os parametros do ParamBox
    aadd(aPergs, {1, "Filial De"  , cFILDe , "", ".T.", "", ".T.", 10, .F.}) // MV_PAR01
    aadd(aPergs, {1, "Filial Até" , cFILAte, "", ".T.", "", ".T.", 10, .T.}) // MV_PAR02
    aadd(aPergs, {1, "Pedido De"  , cNumDe , "", ".T.", "", ".T.", 50, .F.}) // MV_PAR03
    aadd(aPergs, {1, "Pedido Até" , cNumAte, "", ".T.", "", ".T.", 50, .T.}) // MV_PAR04
    aadd(aPergs, {1, "Emissao De" , dDatade, "", ""   , "", ""   , 50, .F.}) // MV_PAR05
    aadd(aPergs, {1, "Emissao Até", dDataAt, "", ""   , "", ""   , 50, .F.}) // MV_PAR06

    //Se a pergunta for confirma, cria as definicoes do relatorio
    If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .F., .F.)

        Processa({|| fGeraExcel()})

    EndIf

    // Restaura os parametros anteriores -MAA 20251023
    For nMv := 1 To Len( aMvPar )
        &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
    Next nMv

    FWRestArea(aArea)

Return NIL

/*/{Protheus.doc} fGeraExcel
Criacao do arquivo Excel na funcao
@type function Processamento
@version  1.0
@author Andreia Domingos
@since 15/10/2025
@return character, sem retorno
/*/
Static Function fGeraExcel()

    Local cQuery   := ""
    Local cPasta   := AllTrim(GetSrvProfString("StartPath","")) //GetTempPath() +(CriaTrab(Nil,.F.) + ".xls")
    Local cArquivo := (CriaTrab(Nil,.F.) + ".xls")
    Local nAtual   := 0
    Local lCopia

    // Default nRecnose2 := 0

    cQuery := "  SELECT DISTINCT   "        + CRLF
    cQuery += "       CR_FILIAL     "        + CRLF
    cQuery += "      ,CR_NUM       "        + CRLF
    cQuery += "      ,C7_USER      "        + CRLF
    cQuery += "      ,CR_EMISSAO   "        + CRLF
    cQuery += "      ,CR_TOTAL     "        + CRLF
    cQuery += "      ,C7_CC      "        + CRLF
    cQuery += "      ,CR_GRUPO     "        + CRLF
    cQuery += "      ,CR_APROV     "        + CRLF
    cQuery += "      ,CR_DATALIB   "        + CRLF
    cQuery += " FROM " + RetSqlName("SCR") + " SCR (NOLOCK)"         + CRLF
    cQuery += " INNER JOIN " + RetSqlName("SC7") + " SC7 (NOLOCK)"   + CRLF
    cQuery += " ON SC7.C7_FILIAL = CR_FILIAL "   + CRLF
    cQuery += " AND SC7.C7_NUM = CR_NUM "        + CRLF
    cQuery += " AND SC7.C7_RESIDUO = '' "        + CRLF
    cQuery += " AND SC7.D_E_L_E_T_ = '' "        + CRLF
    If SCR->(FieldPos("CR_AUTOMAT")) > 0
        cQuery += " AND SCR.CR_AUTOMAT = 'S' "           + CRLF
    End
    cQuery += " AND  SCR.CR_FILIAL >= '" + MV_PAR01 + "'" + CRLF
    cQuery += " AND  SCR.CR_FILIAL <= '" + MV_PAR02 + "'" + CRLF
    cQuery += " AND  SCR.CR_NUM >='" + MV_PAR03 + "'" + CRLF
    cQuery += " AND  SCR.CR_NUM <='" + MV_PAR04 + "'" + CRLF
    cQuery += " AND  SCR.CR_EMISSAO >='" + DTOS(MV_PAR05) + "'" + CRLF
    cQuery += " AND  SCR.CR_EMISSAO <='" + DTOS(MV_PAR06) + "'" + CRLF

    //Executando consulta e setando o total da regua
    PlsQuery(cQuery, "QRY_TRPAI")
    DbSelectArea("QRY_TRPAI")

    //Cria a planilha do excel
    oFWMsExcel := FWMSExcel():New()

    //Criando a aba da planilha
    oFWMsExcel:AddworkSheet(cWorkSheet)

    //Criando a Tabela e as colunas
    oFWMsExcel:AddTable(cWorkSheet, cTitulo)

    //oFWMsExcel:AddColumn(cWorkSheet, cTitulo, Coluna, (1-Esquerda 2-Centralizado 3-Direita),(1-Geral 2-Numerico 3-Monetário 4-Data, Totalizar? .T. ou .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Filial" , 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Pedido" , 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Comprador" , 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Emissao" , 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Valor Total" , 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Cod. Centro de Custo" , 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Desc. Centro de Custo" , 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Grupo Aprovacao" , 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Aprovador" , 1, 4, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "Data Liberacao" , 1, 1, .F.)

    //Definindo o tamanho da regua
    //Count To nTotal
    nTotal := Contar("QRY_TRPAI", ".T.")
    ProcRegua(nTotal)
    QRY_TRPAI->(DbGoTop())

    //Percorrendo os dados da query
    While .NOT. (QRY_TRPAI->(EoF()))

        //Incrementando a regua
        nAtual++

        IncProc("Adicionando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
        //Adicionando uma nova linha
        oFWMsExcel:AddRow (cWorkSheet, cTitulo,;
            { QRY_TRPAI->CR_FILIAL+" "+ FwFilialName( , QRY_TRPAI->CR_FILIAL, 1 ),;
            QRY_TRPAI->CR_NUM,;
            Alltrim( UsrFullName(QRY_TRPAI->C7_USER)),;
            QRY_TRPAI->CR_EMISSAO,;
            Alltrim(Transform(QRY_TRPAI->CR_TOTAL, "@E 9,999,999.99")),;
            QRY_TRPAI->C7_CC,;
            POSICIONE("CTT", 1, XFILIAL("CTT") + QRY_TRPAI->C7_CC, "CTT_DESC01"),;
            QRY_TRPAI->CR_GRUPO,;
            POSICIONE("SAK", 1, XFILIAL("SAK") + QRY_TRPAI->CR_APROV, "AK_NOME"),;
            QRY_TRPAI->CR_DATALIB;
            })

        QRY_TRPAI->(DbSkip())

    EndDo

    QRY_TRPAI->(DbCloseArea())

    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cPasta+cArquivo)

    If GetRemoteType() == 5             //Verifica se é WEB ou Desktop
        lCopia:=(CPYS2TW(cPasta+cArquivo, .T.)==0)   //WEB
    Else
        lCopia:=CpyS2T( cPasta+cArquivo, AllTrim(GetMV('MV_QPATHWT')), .F. )
    Endif

    If lCopia
        FWAlertInfo("O Arquivo "+"<u><b>"+cArquivo+"</u></b>"+ " foi gravado na pasta "+CRLF+CRLF+ AllTrim(GetMV('MV_QPATHWT')), "Arquivo copiado")
        If ApOleClient("MsExcel")
            oExcelApp := MsExcel():New()
            oExcelApp:WorkBooks:Open( AllTrim(GetMV('MV_QPATHWT')) + cArquivo )
            oExcelApp:SetVisible(.T.)
            oExcel := Nil
        Else
            FWAlertWarning("O Excel nao esta instalado na máquina!...tentando abri...", "Excel")
            ShellExecute( "Open",  AllTrim(GetMV('MV_QPATHWT')) + cArquivo, "",AllTrim(GetMV('MV_QPATHWT')), 1 )
        Endif
    Else
        FWAlertWarning("Não foi possivel copiar o arquivo para máquina local", "Mao copiado")
    End
Return NIL

