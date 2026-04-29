//Bibliotecas
#Include "TOTVS.CH"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
 
//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
 
//Cores
#Define COR_CINZA   RGB(180, 180, 180)
#Define COR_PRETO   RGB(000, 000, 000)
 
//Colunas
#Define COL_PRIMEIRA   0005
#Define COL_DESCR      0095

/*/{Protheus.doc} ZFATR01
Relatório de impressão de Minuta de Despacho
@type function
@version v2022.01
@author Luís Gustavo de Souza  /    alterado por Jose uliana 
@since 26/02/2022              /                 13/12/2022
/*/
User Function ZFATR01()
     Local aArea := GetArea()
     
     Processa( { || fMontaRel() }, "Processando..." )
     
     RestArea(aArea)
Return
 
/*/{Protheus.doc} fMontaRel
Função que monta o relatório
@type function
@version v2022.01
@author Luís Gustavo Souza   /    alterado por Jose Uliana
@since 26/02/2022            /                 13/12/2022 
/*/
Static Function fMontaRel()
       Local cCaminho    := ""
       Local cArquivo    := ""
       Local nAtual      := 0
       Local nTotal      := 0
       Local _cQryTmp    := GetNextAlias()
       Local _cPerg      := 'ZFATR01'
       Local _lNormal    := .T.
       //Linhas e colunas
       Private nLinAtu   := 000
       Private nTamLin   := 010
       Private nLinFin   := 820
       Private nColIni   := 005
       Private nColFin   := 550
       Private nColMeio  := (nColFin-nColIni)/2
       //Objeto de Impressao
       Private oPrintPvt
       //Variaveis auxiliares
       Private dDataGer  := Date()
       Private cHoraGer  := Time()
       Private nPagAtu   := 1
       Private cNomeUsr  := UsrRetName(RetCodUsr())
       //Fontes
       Private cNomeFont := "Courier New"
       Private oFontDet  := TFont():New(cNomeFont, 9, -11, .T., .F., 5, .T., 5, .T., .F.)
       Private oFontDetN := TFont():New(cNomeFont, 9, -11, .T., .T., 5, .T., 5, .T., .F.)
       Private oFontRod  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
       Private oFontTit  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)

       IncProc( "Aguarde, busca de dados..." )
       //Abertura de tabelas necessarias
       DbSelectArea("SA1")
       SA1->( DbSetOrder( 1 ) )
       DbSelectArea("SA2")
       SA2->( DbSetOrder( 1 ) )
       DbSelectArea("SA4")
       SA4->( DbSetOrder( 1 ) )

       //Executando pergunte do relatorio
       If Pergunte( _cPerg, .T. )
          _cNumBor  := MV_PAR01
          _OrdemCla := MV_PAR02
       else
          Return
       EndIf

       //Definindo o diretorio como a tempororia do S.O. e o nome do arquivo com a data e hora (sem dois pontos)
       cCaminho  := GetTempPath()
       cArquivo  := "ZFATR01_" + dToS( dDataGer ) + "_" + StrTran( cHoraGer, ':', '-' )

       //Criando o objeto do FMSPrinter
       oPrintPvt := FWMSPrinter():New( cArquivo, IMP_PDF, .F., "", .T., , @oPrintPvt, "", , , , .T. )

       //Setando os atributos necessarios do relatorio
       oPrintPvt:SetResolution(72)
       oPrintPvt:SetPortrait()
       oPrintPvt:SetPaperSize(DMPAPER_A4)
       oPrintPvt:SetMargin(60, 60, 60, 60)

       //Montando a consulta

       IF _OrdemCla = 1
          BEGINSQL ALIAS _cQryTmp
                SELECT ROW_NUMBER() OVER(ORDER BY SF2.F2_DOC DESC) AS Row,
                       SZB.ZB_PEDIDO, 
                       SZG.ZG_LOCALIZ,
                       SF2.F2_FILIAL,  SF2.F2_DOC,     SF2.F2_CLIENTE, SF2.F2_LOJA,    SF2.F2_VALBRUT, SF2.F2_PBRUTO, 
                       SF2.F2_PLIQUI,  SF2.F2_VALMERC, SF2.F2_VALIPI,  SF2.F2_FRETE,   SF2.F2_PEDIDO, 
                       SF2.F2_SEGURO,  SF2.F2_ICMSRET, SF2.F2_ESPECI1, SF2.F2_ESPECI2, SF2.F2_ESPECI3, SF2.F2_ESPECI4, 
                       SF2.F2_VOLUME1, SF2.F2_TIPO,    SF2.F2_REDESP,  SF2.F2_SERIE,   SF2.F2_PEDIDO
                FROM %table:SZB% SZB
                LEFT JOIN %table:SZG% SZG ON SZG.ZG_FILIAL = SZB.ZB_FILIAL AND SZG.D_E_L_E_T_ = '' AND SZG.ZG_PEDIDO = SZB.ZB_PEDIDO
                LEFT JOIN %table:SF2% SF2 ON SF2.F2_FILIAL = SZB.ZB_FILIAL AND SF2.D_E_L_E_T_ = '' AND SF2.F2_PEDIDO = SUBSTRING( SZB.ZB_PEDIDO, 3, 6 )
                WHERE SZB.ZB_FILIAL  = %exp:xFilial("SZB")%
                  AND SZB.D_E_L_E_T_ = ''
                  AND SZB.ZB_CODIGO = %exp:_cNumBor%
                ORDER BY SF2.F2_DOC,    SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA
          ENDSQL     
       Else
          BEGINSQL ALIAS _cQryTmp
                SELECT ROW_NUMBER() OVER(ORDER BY SF2.F2_DOC DESC) AS Row,
                       SZB.ZB_PEDIDO, 
                       SZG.ZG_LOCALIZ,
                       SF2.F2_FILIAL,  SF2.F2_DOC,     SF2.F2_CLIENTE, SF2.F2_LOJA,    SF2.F2_VALBRUT, SF2.F2_PBRUTO, 
                       SF2.F2_PLIQUI,  SF2.F2_VALMERC, SF2.F2_VALIPI,  SF2.F2_FRETE,   SF2.F2_PEDIDO, 
                       SF2.F2_SEGURO,  SF2.F2_ICMSRET, SF2.F2_ESPECI1, SF2.F2_ESPECI2, SF2.F2_ESPECI3, SF2.F2_ESPECI4, 
                       SF2.F2_VOLUME1, SF2.F2_TIPO,    SF2.F2_REDESP,  SF2.F2_SERIE,   SF2.F2_PEDIDO,
                       'TRANSP' =  ( ISNULL( ( SA4.A4_NOME ),'' ) )
                FROM %table:SZB% SZB
                LEFT JOIN %table:SZG% SZG ON SZG.ZG_FILIAL = SZB.ZB_FILIAL AND SZG.D_E_L_E_T_ = '' AND SZG.ZG_PEDIDO = SZB.ZB_PEDIDO
                LEFT JOIN %table:SF2% SF2 ON SF2.F2_FILIAL = SZB.ZB_FILIAL AND SF2.D_E_L_E_T_ = '' AND SF2.F2_PEDIDO = SUBSTRING( SZB.ZB_PEDIDO, 3, 6 )
                LEFT JOIN %table:SA4% SA4 ON SA4.A4_COD    = SF2.F2_REDESP AND SA4.D_E_L_E_T_ = '' 
                WHERE SZB.ZB_FILIAL  = %exp:xFilial("SZB")%
                  AND SZB.D_E_L_E_T_ = ''
                  AND SZB.ZB_CODIGO = %exp:_cNumBor%
                ORDER BY SA4.A4_NOME, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA 
          ENDSQL
       EndIf

       //Conta o total de registros, seta o tamanho da regua, e volta pro topo
       nTotal := (_cQryTmp)->ROW
       ProcRegua( nTotal )

       //Imprime o cabe�alho
       If nTotal <= 0
          MessageBox( "Nao existe dados a serem impressos...", "Atencao", 48 )
          Return
       Else
          fImpCab()
       Endif
       nAtual := 0
     
       //Enquanto houver registros
       While !(_cQryTmp)->( EoF() )
             nAtual++
             IncProc( "Imprimindo minuta. Nota: " + (_cQryTmp)->F2_DOC + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")..." )
             _lNormal := !( (_cQryTmp)->F2_TIPO $ "DB" )
             If _lNormal
                SA1->( DbSeek( xFilial("SA1") + (_cQryTmp)->F2_CLIENTE) )
             Else
                SA2->( DbSeek( xFilial("SA1") + (_cQryTmp)->F2_CLIENTE) )
             Endif
             SA4->( DbSeek( xFilial("SA4") + (_cQryTmp)->F2_REDESP ) )
             //Se a linha atual mais o espaco que sera utilizado forem maior que a linha final, imprime rodape e cabecalho
             If nLinAtu + nTamLin > nLinFin
                fImpRod()
                fImpCab()
             EndIf

             //Imprimindo a linha atual
             oPrintPvt:SayAlign( nLinAtu  , 005, "NF:"                                                                                                      , oFontDet , 0020, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu-1, 025, (_cQryTmp)->F2_DOC                                                                                         , oFontDetN, 0040, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu  , 090, "SERIE:"                                                                                                   , oFontDet , 0045, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu-1, 140, (_cQryTmp)->F2_SERIE                                                                                       , oFontDetN, 0020, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu  , 185, "VALOR:"                                                                                                   , oFontDet , 0045, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu-1, 235, TransForm( (_cQryTmp)->F2_VALMERC + (_cQryTmp)->F2_VALIPI + (_cQryTmp)->F2_FRETE + (_cQryTmp)->F2_SEGURO + (_cQryTmp)->F2_ICMSRET, "@E 99,999,999.99" ), oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu  , 340, "PEDIDO:"                                                                                                  , oFontDet , 0040, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu-1, 385, (_cQryTmp)->F2_PEDIDO + "  -  " + (_cQryTmp)->ZG_LOCALIZ                                                   , oFontDetN, 0100, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             nLinAtu += nTamLin
             //Imprimindo a linha 
             oPrintPvt:SayAlign( nLinAtu  , 005, "CLIENTE :"                                                                                                , oFontDet , 0050, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu-1, 060, SubStr( Iif( _lNormal, SA1->A1_NOME, SA2->A2_NOME ), 1, 40 )                                               , oFontDetN, 0220, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu  , 305, "| DATA:"                                                                                                  , oFontDet , 0080, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             nLinAtu += nTamLin
             oPrintPvt:SayAlign( nLinAtu  , 005, "ENDERECO:"                                                                                                , oFontDet , 0050, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu-1, 060, SubStr( Iif( _lNormal, Iif( Empty( SA1->A1_ENDENT ), SA1->A1_END, SA1->A1_ENDENT ) , SA2->A2_END ), 1, 40 ), oFontDetN, 0220, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu  , 305, "| ASSINATURA:"                                                                                            , oFontDet , 0080, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             nLinAtu += nTamLin
             oPrintPvt:SayAlign( nLinAtu  , 005, "BAIRRO..:"                                                                                                , oFontDet , 0050, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu-1, 060, Iif( _lNormal, Iif( Empty( SA1->A1_BAIRROE ), SA1->A1_BAIRRO, SA1->A1_BAIRROE ), SA2->A2_BAIRRO )          , oFontDetN, 0220, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu  , 305, "CIDADE:"                                                                                                  , oFontDet , 0045, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu-1, 355, Iif( _lNormal, Iif( Empty( SA1->A1_MUNE ), SA1->A1_MUN, SA1->A1_MUNE ), SA2->A2_MUN )                      , oFontDetN, 0220, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             nLinAtu += nTamLin
             oPrintPvt:SayAlign( nLinAtu  , 005, "TRANSP..:"                                                                                                , oFontDet , 0050, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu-1, 060, SA4->A4_NOME                                                                                               , oFontDetN, 0220, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             nLinAtu += nTamLin
             oPrintPvt:SayAlign( nLinAtu  , 005, "END.....:"                                                                                                , oFontDet , 0050, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu-1, 060, Alltrim( SA4->A4_END ) + '  -  ' + Alltrim( SA4->A4_MUN ) + '  -  ' + Alltrim( SA4->A4_BAIRRO )            , oFontDetN, 0400, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             nLinAtu += nTamLin
             oPrintPvt:SayAlign( nLinAtu  , 005, "P.BRUTO.:"                                                                                                , oFontDet , 0050, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu-1, 060, TransForm( (_cQryTmp)->F2_PBRUTO, "@E 999,999.99" )                                                        , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu  , 185, "P.LIQUIDO:"                                                                                               , oFontDet , 0055, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu-1, 245, TransForm( (_cQryTmp)->F2_PLIQUI, "@E 999,999.99" )                                                        , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu  , 340, "VOLUMES:"                                                                                                 , oFontDet , 0050, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu-1, 395, TransForm( (_cQryTmp)->F2_VOLUME1, "@E 999,999.99" )                                                       , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             nLinAtu += nTamLin
             nLinAtu += nTamLin
             oPrintPvt:SayAlign( nLinAtu  , 005, "CONFERENCIA:"                                                                                             , oFontDet , 0080, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             oPrintPvt:SayAlign( nLinAtu  , 305, "DESPACHO:"                                                                                                , oFontDet , 0080, nTamLin, COR_PRETO, PAD_LEFT, 0 )
             nLinAtu += nTamLin
             nLinAtu += nTamLin
             oPrintPvt:Line( nLinAtu, nColIni, nLinAtu, nColFin, CLR_BLACK, "-2" )

             nLinAtu += nTamLin
             (_cQryTmp)->( DbSkip() )
       EndDo
       (_cQryTmp)->( DbCloseArea() )
     
       //Se ainda tiver linhas sobrando na pagina, imprime o rodape final
       If nLinAtu <= nLinFin
          fImpRod()
       EndIf
     
       //Mostrando o relatorio
       oPrintPvt:Preview()
Return

/*/{Protheus.doc} fImpCab
Funcao que imprime o cabecalho
@type function
@version v2022.01
@author Lui�s Gustavo de Souza      /  Alterado por Jose Uliana
@since 26/02/2022                  /               13/12/2022
/*/
Static Function fImpCab()
       Local cTexto   := ""
       Local nLinCab  := 030
     
       //Iniciando Pagina
       oPrintPvt:StartPage()
       //Cabecalho
       cTexto := "Minuta de Faturamento"
       oPrintPvt:SayBitmap( nLinCab, nColIni, 'LGRL' + FWCodEmp() + FWCodFil() + '.BMP', 44, 19 )
       oPrintPvt:SayAlign( nLinCab, nColMeio - 120, cTexto, oFontTit, 240, 20, COR_PRETO, PAD_CENTER, 0 )
       //Linha Separatoria
       nLinCab += (nTamLin * 2)
       oPrintPvt:Line( nLinCab, nColIni, nLinCab, nColFin, COR_CINZA )
       //Cabecalho das colunas
       nLinCab += nTamLin
       //Atualizando a linha inicial do relatorio
       nLinAtu := nLinCab + 3
Return
 
/*/{Protheus.doc} fImpRod
Funcao que imprime o rodape
@type function
@version v2022.01
@author Lui�s Gustavo Souza      /    Alterado por Jose Uliana
@since 26/02/2022               /                 13/12/2022
/*/
Static Function fImpRod()
       Local nLinRod   := nLinFin + nTamLin
       Local cTextoEsq := ''
       Local cTextoDir := ''

       //Linha Separatoria
       oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin, COR_CINZA)
       nLinRod += 3
       //Dados da Esquerda e Direita
       cTextoEsq := dToC( dDataGer ) + "    " + cHoraGer + "    " + FunName() + "    " + cNomeUsr
       cTextoDir := "Pagina " + cValToChar( nPagAtu )
       //Imprimindo os textos
       oPrintPvt:SayAlign(nLinRod, nColIni,    cTextoEsq, oFontRod, 200, 05, COR_CINZA, PAD_LEFT,  0)
       oPrintPvt:SayAlign(nLinRod, nColFin-40, cTextoDir, oFontRod, 040, 05, COR_CINZA, PAD_RIGHT, 0)
       //Finalizando a pagina e somando mais um
       oPrintPvt:EndPage()
       nPagAtu++
Return
