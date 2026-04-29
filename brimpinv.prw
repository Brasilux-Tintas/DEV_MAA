//Bibliotecas
#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
#Define PAD_JUSTIFY 3 //Opção disponível somente a partir da versão 1.6.2 da TOTVS Printer

//Cor(es)
Static nCorCinza  := RGB(110, 110, 110)
//Static nCorDestaq := RGB(000, 208, 028)

/*/{Protheus.doc} BRImpInv
Função para importar informações do fornecedor via csv
@author Atilio
@since 07/06/2021
@version 1.0
@type function
/*/

User Function BRImpInv()
    Local aArea     := GetArea()
    Private cArqOri := ""

    //Mostra o Prompt para selecionar arquivos
    cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )

    //Se tiver o arquivo de origem
    If ! Empty(cArqOri)

        //Somente se existir o arquivo e for com a extensão CSV
        If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
            Processa({|| fImporta() }, "Importando...")
        Else
            MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
        EndIf
    EndIf

    RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fImporta                                                               |
 | Desc:  Função que importa os dados                                            |
*-------------------------------------------------------------------------------*/

Static Function fImporta()
    Local aArea      := GetArea()
    Local cArqLog    := "BRImpInv_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".log"
    Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local nLinhaAtu  := 0
    Local aLinha     := {}
    Local oArquivo
    Local aLinhas
    Local c_Filial   := ""
    Local cCod       := ""
    Local aPergs   := {}
    Local nQuant   := 0
    Local cTipo:=" "
    Local nMV:=1
    Local aMvPar:={}
    Private cDirLog    := GetTempPath() + "x_importacao\"
    Private cLog       := ""
    Private aResult     := {{},{}}

    //Se a pasta de log não existir, cria ela

    For nMv := 1 To 60
        aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
    Next nMv

    If ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIf

    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)

    //Se o arquivo pode ser aberto
    If (oArquivo:Open())

        //Se não for fim do arquivo
        If ! (oArquivo:EoF())

            //Definindo o tamanho da régua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)

            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()

            //Enquanto tiver linhas
            While (oArquivo:HasLine())

                //Incrementa na tela a mensagem
                nLinhaAtu++
                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr(cLinAtu, ",")

                //Se não for o cabeçalho (encontrar o texto "Código" na linha atual)
                If ! "FILIAL" $ Upper(cLinAtu)

                    //Zera as variaveis
                    c_Filial   := aLinha[1]
                    cCod       := StrTran(aLinha[2],"'","")
                    cCod:=Padr(cCod,15,' ')
                    SB2->(dbSetOrder(1))
                    If SB2->(dbSeek(c_Filial+cCod+"04"))
                        If SB2->B2_QATU == 0
                            cLog += "- Lin" + cValToChar(nLinhaAtu) + ", produto zerado ;" + CRLF
                        Else
                            SB1->(dbSetOrder(1))
                            If SB1->(dbSeek(xFilial("SB1")+cCod))
                                AADD(aResult[1],SB1->B1_COD)
                                AADD(aResult[2],SB1->B1_CODBAR)
                            Else
                                cLog += "- Lin" + cValToChar(nLinhaAtu) + ", produto nao encontrado (SB1);" + CRLF
                            End
                        End
                    Else
                        cLog += "- Lin" + cValToChar(nLinhaAtu) + ", produto nao encontrado (SB2) ;" + CRLF
                    End
                Else
                    cLog += "- Lin" + cValToChar(nLinhaAtu) + ", linha não processada - cabeçalho;" + CRLF
                EndIf

            EndDo

            //Se tiver log, mostra ele
            If ! Empty(cLog)
                If FWAlertYesNo("Deseja ver arquivo de log ?", "Arquivo de LOG")
                    cLog := "Processamento finalizado, abaixo as mensagens de log: " + CRLF + cLog
                    MemoWrite(cDirLog + cArqLog, cLog)
                    ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
                End
            EndIf

        Else
            MsgStop("Arquivo não tem conteúdo!", "Atenção")
        EndIf

        //Fecha o arquivo
        oArquivo:Close()
    Else
        MsgStop("Arquivo não pode ser aberto!", "Atenção")
    EndIf

    If Len(aResult) > 0
        If FWAlertYesNo("Deseja gerar as etiquetas ?", "Geração Etiquetas")
            nQuant:=Len(aResult[1])
            aAdd(aPergs,{2, "Tipo Cod Bar",   cTipo, {"1=FWMSBar","2=Code128","3=Ean13","4=Code128C","5=Pdf417","6=QRCode","7=FWMSBar(V)"},     122, ".T.", .F.})
            aAdd(aPergs,{1, "Qtde Etiquetas", nQuant,   "@E 999,999",     "Positivo()", "",    ".T.", 80,  .F.})
            aAdd(aPergs,{9,"Maximo de Etiquetas: "+cValTochar(nQuant),150,7,.T.})

            If ParamBox(aPergs, "Informe os parâmetros")
                Processa({|| BRImpI01(mv_par01,mv_par02) }, "Imprimindo...")
            End
        End

        If FWAlertYesNo("Deseja gerar Plano Mestre de Inventario ?", "Plano Mestre")
            Processa({|| BRImpI02() }, "Gerando Plano Mestre...")
        End

    End

    For nMv := 1 To Len( aMvPar )
        &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
    Next nMv

    FWRestArea(aArea)

Return (NIL)

Static Function BRImpI01(cTipo,nQuant)

    Local aArea        := FWGetArea()
    Local cArquivo     := 'braimpinvz'+RetCodUsr()+'_'+ dToS(Date()) + '.pdf'
    Local nI
    Private oPrintPvt
    Private cHoraEx    := Time()
    Private nPagAtu    := 1
    Private cLogoEmp   := fLogoEmp()

    //Linhas e colunas
    Private nLinAtu    := 0
    Private nLinFin    := 800
    Private nColIni    := 010
    Private nColFin    := 580
    Private nColMeio   := (nColFin-nColIni)/2
    //Declarando as fontes
    Private cNomeFont  := 'Arial'
    Private oFontDet   := TFont():New(cNomeFont, /*uPar2*/, -11, /*uPar4*/, .F., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F.)
    Private oFontDetN  := TFont():New(cNomeFont, /*uPar2*/, -13, /*uPar4*/, .T., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F.)
    Private oFontRod   := TFont():New(cNomeFont, /*uPar2*/, -8,  /*uPar4*/, .F., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F.)
    Private oFontMin   := TFont():New(cNomeFont, /*uPar2*/, -7,  /*uPar4*/, .F., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F.)
    Private oFontTit   := TFont():New(cNomeFont, /*uPar2*/, -15, /*uPar4*/, .T., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F.)

    ProcRegua(Len(aResult))

    //Criando o objeto de impressao
    oPrintPvt := FWMSPrinter():New(;
        cArquivo,;    // cFilePrinter
        IMP_PDF,;     // nDevice
        .F.,;         // lAdjustToLegacy
        ,;            // cPathInServer
        .T.,;         // lDisabeSetup
        ,;            // lTReport
        @oPrintPvt,;  // oPrintSetup
        ,;            // cPrinter
        ,;            // lServer
        ,;            // lParam10
        ,;            // lRaw
        .T.;          // lViewPDF
        )
    oPrintPvt:cPathPDF := GetTempPath()
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    oPrintPvt:SetPaperSize(DMPAPER_A4)
    oPrintPvt:SetMargin(0, 0, 0, 0)

    //Inicia a página imprimindo o cabecalho
    fImpCab()

    For nI:=1 To  If(nQuant>Len(aResult[1]),Len(aResult[1]),nQuant)

        IncProc("Imprimindo "+ cValToChar(nI) + " de " + cValToChar(Len(aResult[1])) + "...")

        oPrintPvt:SayAlign(nLinAtu, 01, "Produto "+aResult[1][nI]+"/"+aResult[2][nI], oFontRod, 400, 20, nCorCinza, PAD_LEFT, /*nAlignVert*/)

        Do Case

            Case cTipo == "1"
                //Método FWMSBar
                oPrintPvt:FWMSBar(;
                    "INT25",;     // cTypeBar
                    nLinAtu / 8,; // nRow
                    200,; // nCol
                    If( .NOT. Empty(aResult[2][nI]),aResult[2][nI],aResult[1][nI]),;   // cCode
                    oPrintPvt,;   // oPrint
                    ,;            // lCheck
                    ,;            // Color
                    .T.,;         // lHorz
                    ,;            // nWidth
                    ,;            // nHeigth
                    ,;            // lBanner
                    ,;            // cFont
                    ,;            // cMode
                    .F.,;         // lPrint
                    ,;            // nPFWidth
                    ,;            // nPFHeigth
                    ;             // lCmtr2Pix
                    )

            Case cTipo == "2"
                //Método CODE128
                oPrintPvt:Code128(;
                    nLinAtu ,; // nRow
                    200,;      // nCol
                    If( .NOT. Empty(aResult[2][nI]),aResult[2][nI],aResult[1][nI]),;    // cCodeBar
                    1,;            // nWidth
                    30,;           // nHeight
                    .T.,;          // lSay
                    oFontMin,;     // oFont
                    300;           // nTotalWidth
                    )

            Case cTipo == "3"
                //Método Ean13
                oPrintPvt:Ean13(;
                    nLinAtu ,;        // nRow
                    200,;        // nCol
                    If( .NOT. Empty(aResult[2][nI]),aResult[2][nI],aResult[1][nI]),; // cCodeBar
                    100,;                 // nTotalWidth
                    30;                   // nHeight
                    )

            Case cTipo == "5"
                //Método Pdf417
                oPrintPvt:Pdf417(;
                    nLinAtu ,;           // nRow
                    200,;                // nCol
                    If( .NOT. Empty(aResult[2][nI]),aResult[2][nI],aResult[1][nI]),;    // cCodeBar
                    150,;                    // nSizeBar
                    30;                      // nHeight
                    )

            Case cTipo == "6"
                //Método QRCode
                oPrintPvt:QRCode(;
                    nLinAtu+30 ,;   // nRow
                    380,;        // nCol
                    If(.NOT. Empty(aResult[2][nI]),aResult[2][nI],aResult[1][nI]),;      // cCodeBar
                    65;              // nSizeBar
                    )

            Case cTipo == "7"
                //Método FWMSBar (Vertical)
                oPrintPvt:FWMSBar(;
                    "CODE128",;            // cTypeBar
                    nLinAtu / 8 - 19,;     // nRow
                    nColIni / 8,;          // nCol
                    If(.NOT. Empty(aResult[2][nI]),aResult[2][nI],aResult[1][nI]),; // cCode
                    oPrintPvt,;            // oPrint
                    ,;                     // lCheck
                    ,;                     // Color
                    .F.,;                  // lHorz
                    ,;                     // nWidth
                    ,;                     // nHeigth
                    ,;                     // lBanner
                    ,;                     // cFont
                    ,;                     // cMode
                    .F.,;                  // lPrint
                    ,;                     // nPFWidth
                    ,;                     // nPFHeigth
                    ;                      // lCmtr2Pix
                    )

        EndCase

        nLinAtu += 80

        fQuebra()

    Next

    //Imprime o Ãºltimo rodapÃ© e abre o PDF
    fImpRod()
    oPrintPvt:Preview()

    FWRestArea(aArea)

Return

/*/{Protheus.doc} fLogoEmp
FunÃ§Ã£o que retorna o logo da empresa conforme configuraÃ§Ã£o da DANFE
@author Atilio
@since 28/02/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function fLogoEmp()
    Local cLogo       := "\x_imagens\logo.png"
Return cLogo

/*/{Protheus.doc} fImpCab
FunÃ§Ã£o que imprime o cabeÃ§alho do relatÃ³rio
@author Atilio
@since 28/02/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function fImpCab()
    // Local cTexto   := ''
    Local nLinCab  := 015

    //Iniciando Pagina
    oPrintPvt:StartPage()

    //Imprime o logo
    //If File(cLogoEmp)
    //    oPrintPvt:SayBitmap(005, nColIni, cLogoEmp, 030, 030)
    //EndIf

    //Cabecalho
    //cTexto := 'Testes CÃ³digos de Barras'
    //oPrintPvt:SayAlign(nLinCab, nColMeio-200, cTexto, oFontTit, 400, 20, nCorDestaq, PAD_CENTER, /*nAlignVert*/)

    //Linha Separatoria
    //nLinCab += 020
    //oPrintPvt:Line(nLinCab,   nColIni, nLinCab,   nColFin, nCorDestaq)

    //Atualizando a linha inicial do relatorio
    nLinAtu := nLinCab + 10
Return

/*/{Protheus.doc} fImpRod
FunÃ§Ã£o que imprime o rodapÃ© e encerra a pÃ¡gina
@author Atilio
@since 28/02/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function fImpRod()
    //Local nLinRod:= nLinFin
    //Local cTexto := ''

    ////Linha Separatoria
    //oPrintPvt:Line(nLinRod,   nColIni, nLinRod,   nColFin, nCorDestaq)
    //nLinRod += 3

    //Dados da Esquerda
    //cTexto := dToC(dDataBase) + '     ' + cHoraEx + '     ' + FunName() + ' (zVid0092)     ' + UsrRetName(RetCodUsr())
    //oPrintPvt:SayAlign(nLinRod, nColIni, cTexto, oFontRod, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

    //Direita
    //cTexto := 'Pagina '+cValToChar(nPagAtu)
    //oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 10, /*nClrText*/, PAD_RIGHT, /*nAlignVert*/)

    //Finalizando a pagina e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
Return

Static Function fQuebra()
    If nLinAtu >= nLinFin-10
        fImpRod()
        fImpCab()
    EndIf
Return


Static Function BRImpI02()

    Local nI
    Local lPrdBloq    := .F.
    Local aLog        := {}
    Local aArea       := FwGetArea()
    Local cTexto:=""

    aadd(aLog,{"Rotina","Linha","Cod Inv","Produto","Local","Endereco"})

    ProcRegua(Len(aResult[1]))

    If .NOT. Pergunte("AIA032")
        Return (Nil)
    EndIf

    If	MV_PAR04 < 1
        MsgAlert("O numero de contagens nao pode ser igual ou inferior a zero, favor verificar !!!")
        Return (Nil)
    EndIf

    For nI:=1 To Len(aResult[1])

        IncProc()

        dbSelectArea("SB5")
        SB5->(dbSetOrder(1))

        dbSelectArea("SB1")
        SB1->(dbSetOrder(1))
 
        If SB1->(dbSeek(xFilial("SB1")+aResult[1][nI]))

            If SB1->B1_COD > MV_PAR03
                Loop
            End

            If lPrdBloq .And. SB1->B1_MSBLQL == "1"
                Loop
            Else
                If .NOT. ExistCpo("SB1",SB1->B1_COD)
                    lPrdBloq := .T.
                    Loop
                EndIf
            EndIf

            CBA->(dbSetOrder(3)) //CBA_FILIAL+CBA_TIPINV+CBA_STATUS+CBA_LOCAL+CBA_PROD+CBA_DATA
            If	CBA->(dbSeek(xFilial("CBA")+"1"+"0"+MV_PAR01+SB1->B1_COD+DTOS(MV_PAR05))) .OR.;
                    CBA->(dbSeek(xFilial("CBA")+"1"+"1"+MV_PAR01+SB1->B1_COD+DTOS(MV_PAR05)))
                Loop
            EndIf

            //Gerar mestre de inventario para armazens com saldo
            //esta validacao so ocorre por produto
            SB2->(DbSetorder(1))
            If	.NOT. SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+MV_PAR01))
                Loop
            EndIf

            //So analisa um produto para bloqueio se encontrar na tabela de complemento,
            //caso contrario eu crio o mestre
            If	MV_PAR06==1 .and. SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))
                If	.NOT. Empty(SB5->B5_PERIOT) .And. (SB5->(B5_DTINV+B5_PERIOT)>dDataBase)
                    Loop
                EndIf
            EndIf

            BRImpI03(aResult[1][nI],aLog,nI)
        End
    Next

    FwRestArea(aArea)
    For nI:=1 to Len(aLog)
            cTexto+=Padr(aLog[nI][1],15,' ')+;
            Padr(aLog[nI][2],10,' ')+;
            Padr(aLog[nI][3],15,' ')+;
            Padr(aLog[nI][4],15,' ')+;
            Padr(aLog[nI][5],10,' ')+;
            Padr(aLog[nI][6],10,' ')+CRLF
    Next    
    BRImpI04("Imp Inventario","BRImpI03",cTexto)

Return NIl

Static Function BRImpI03(cProduto,aLog,nI)

    cCodInv := GetSXENum("CBA","CBA_CODINV")
    RecLock("CBA",.T.)
    CBA->CBA_Filial := xFilial("CBA")
    CBA->CBA_CODINV := cCodInv
    CBA->CBA_DATA   := MV_PAR05
    CBA->CBA_CONTS  := MV_PAR04
    CBA->CBA_STATUS := "0"
    CBA->CBA_TIPINV := "1"
    CBA->CBA_PROD   := Padr(cProduto,TamSx3("B1_COD")[1],' ')
    CBA->CBA_LOCAL  := MV_PAR01
    CBA->CBA_LOCALIZ:= SuperGetMv("BR_ENMATES",.F.,"ESCRITOR")
    CBA->CBA_CLASSA := Str(MV_PAR07,1)
    CBA->CBA_CLASSB := Str(MV_PAR08,1)
    CBA->CBA_CLASSC := Str(MV_PAR09,1)
    CBA->CBA_INVGUI := Str(MV_PAR10,1)
    CBA->CBA_RECINV := Str(MV_PAR11,1)
    MsUnlock()

    If __lSX8
        ConfirmSx8()
    EndIf

    //Mestres de Inventario gerados
    aadd(aLog,{"BRImpInv",StrZero(nI,3,0),CBA_CODINV,cProduto,CBA->CBA_LOCAL,CBA->CBA_LOCALIZ})

Return (NIL)


Static Function BRImpI04(cTitulo,cHeader,cBody)

    Local oModal := Nil 

    oModal := FWDialogModal():New()
    oModal:SetTitle( cTitulo )
    oModal:SetFreeArea( 290, 250 )
    oModal:SetEscClose( .T. )
    oModal:SetBackground( .T. )
    oModal:CreateDialog()

    TMultiGet():New( 030, 020, { || cHeader + CRLF + CRLF + cBody },;
     oModal:GetPanelMain(), 250, 190,,,,,, .T.,,,,,, .T.,,,,, .T. )

    oModal:Activate()

Return()
