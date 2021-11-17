#include 'protheus.ch'
#include "topconn.ch"
#include "avprint.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCPR11 ºAutor  ³ Luís G. de Souza   º Data ³  19/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressão de códigos de barra para produção.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRPCPR11()
     Private cPerg   := "PCPR11"
     Private nLinMax := 2920
     Private nColMax := 2350

     //VldPerg()  //LGS#20200131 - Adequação de release 12.1.25 e posteriores
     If !Pergunte(cPerg,.t.)
        Return
     Else
        MsAguarde({|| PCPR11_1() }, "Aguarde", "Buscando informações conforme parâmetros...")
        DbSelectArea("TCQ")            
        DbGotop()
        If Eof()
           MsgBox("Não há dados a serem processados com estes parâmetros!!!","Atenção","STOP")
           DbSelectArea("TCQ") 
           DbCloseArea()
           Return
        Endif  
     Endif
     Processa({|lEnd| PCPR11_2()})

     DbSelectArea("TCQ")
     DbCloseArea()
Return

/**********************************************************************************************************/
/*** PCPR11_1 - Busca informações conforme parâmetros no Banco de Dados                                  ***/
/**********************************************************************************************************/
Static Function PCPR11_1()
       Local cQry1 := ""
       If mv_par01 == 1 //Tachos
          cQry1 += "SELECT SUBSTRING(SH1.H1_CODIGO, 1, 2)+'-'+SUBSTRING(SH1.H1_CODIGO, 3, 4) AS H1_CODIGO, SH1.H1_DESCRI "
          cQry1 += "FROM "+RetSqlName("SH1")+" SH1 WITH (NOLOCK) "
          cQry1 += "WHERE SH1.H1_FILIAL = '"+xFilial("SH1")+"' "
          cQry1 += "  AND SH1.D_E_L_E_T_ = '' "
          cQry1 += "  AND SUBSTRING(SH1.H1_CODIGO, 3, 2) = 'TC' "
          cQry1 += "ORDER BY SH1.H1_CODIGO "
       Else

       Endif
       TCQuery cQry1 NEW ALIAS "TCQ"
Return

/**********************************************************************************************************/
/*** PCPR11_2 - Impressão do relatório.                                                                 ***/
/**********************************************************************************************************/
Static Function PCPR11_2()
       oPrn   := TMSPrinter():New( "Impressão de Código de Barras dos Recursos." )
       oPrn:SetPortrait()      //SetLandscape()
       nLin   := 2
       nCol   := 1
       nLinPx := 30
       nPos   := 1
       oFont1 := TFont():New("Courier New"        , 9, 14, .F., .F.,  5, .F., 5, .F., .F.)
       oFont2 := TFont():New("Courier New"        , 9, 19, .F., .F.,  5, .F., 5, .F., .F.)
       oFont3 := TFont():New("Courier New Itálico", 9, 14, .T., .F.,  5, .T., 5, .F., .F.)
       AVPRINT oPrn NAME "Impressão de Código de Barras dos Recursos."
               AVPAGE
                 /*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
                   ±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
                   ±±³Fun‡…o    ³MSBAR       ³ Autor ³ ALEX SANDRO VALARIO ³ Data ³  06/99   ³±±
                   ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
                   ±±³Descri‡…o ³ Imprime codigo de barras                                   ³±±
                   ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
                   ±±³Parametros³ 01 cTypeBar String com o tipo do codigo de barras          ³±± 
                   ±±³          ³             "EAN13","EAN8","UPCA" ,"SUP5"   ,"CODE128"     ³±±
                   ±±³          ³             "INT25","MAT25,"IND25","CODABAR","CODE3_9"     ³±±
                   ±±³          ³ 02 nRow     Numero da Linha em centimentros                ³±±
                   ±±³          ³ 03 nCol     Numero da coluna em centimentros               ³±±
                   ±±³          ³ 04 cCode    String com o conteudo do codigo                ³±±
                   ±±³          ³ 05 oPr      Obejcto Printer                                ³±±
                   ±±³          ³ 06 lcheck	  Se calcula o digito de controle                ³±±
                   ±±³          ³ 07 Cor      Numero da Cor, utilize a "common.ch"           ³±±
                   ±±³          ³ 08 lHort    Se imprime na Horizontal                       ³±±
                   ±±³          ³ 09 nWidth	  Numero do Tamanho da barra em centimetros      ³±±
                   ±±³          ³ 10 nHeigth  Numero da Altura da barra em milimetros        ³±±
                   ±±³          ³ 11 lBanner  Se imprime o linha em baixo do codigo          ³±±
                   ±±³          ³ 12 cFont    String com o tipo de fonte                     ³±±
                   ±±³          ³ 13 cMode    String com o modo do codigo de barras CODE128  ³±±
                   ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
                   ±±³ Uso      ³ ImpressÆo de etiquetas c¢digo de Barras para HP e Laser    ³±±
                   ±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
                   ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
                   ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
                 If mv_par01 == 1
                    oPrn:Say( nLinPx, (nColMax / 2) - (oPrn:GetTextWidth( "CÓDIGOS DE BARRA - TACHOS", oFont2 ) / 2), "CÓDIGOS DE BARRA - TACHOS", oFont2, , , , )
                    nLinPx += 60
                    oPrn:Line(nLinPx, 30, nLinPx, nColMax)
                 Else
//StrZero(ASC("P"), 2) + StrZero(ASC("R"), 2) + StrZero(ASC("T"), 2) + StrZero(ASC("C"), 2) + StrZero(ASC("0"), 2) + StrZero(ASC("1"), 2) + EanDigito(StrZero(ASC("P"), 2) + StrZero(ASC("R"), 2) + StrZero(ASC("T"), 2) + StrZero(ASC("C"), 2) + StrZero(ASC("0"), 2) + StrZero(ASC("1"), 2))
                 Endif
                 DbSelectArea("TCQ")
                 DbGoTop()
                 While !Eof()
                       cSubDiv := SubStr(TCQ->H1_CODIGO, 1, 2)
                       nLinPX += 10
                       oPrn:Say(nLinPx, 30, Iif(cSubDiv $ 'MT', 'MARTELADO', 'PRODUÇÃO'), oFont3, , , , )
                       While !Eof() .and. SubStr(TCQ->H1_CODIGO, 1, 2) $ cSubDiv
                             _CodBar := TCQ->H1_CODIGO
                             If nPos == 1
                                MSBAR("CODE3_9",  nLin,  nCol     , _CodBar, oPrn, .f., NIL, NIL, Nil, 1, NIL, NIL, NIL, .f.)
                                _Lin := nLin + 1
                                _Col := nCol
                                oPrn:Cmtr2Pix(@_Lin, @_Col)
                                oPrn:Say(_Lin,   _Col, Alltrim(_CodBar)+' - '+TCQ->H1_DESCRI, oFont1, , , , )
                                nPos += 1
                             ElseIf nPos == 2
                                    MSBAR("CODE3_9",  nLin,  nCol + 10, _CodBar, oPrn, .f., NIL, NIL, Nil, 1, NIL, NIL, NIL, .f.)
                                    _Lin := nLin + 1
                                    _Col := nCol + 10
                                    oPrn:Cmtr2Pix(@_Lin, @_Col)
                                    oPrn:Say(_Lin, _Col, Alltrim(_CodBar)+' - '+TCQ->H1_DESCRI, oFont1, , , , )
                                    nLin += 1.5
                                    nPos := 1
                                    If _Lin >= nLinMax
                                       nLin   := 2
                                       nCol   := 1
                                       AVNEWPAGE
                                         If mv_par01 == 1
                                            nLinPx += 30
                                            oPrn:Say( nLinPx, (nColMax / 2) - (oPrn:GetTextWidth( "CÓDIGOS DE BARRA - TACHOS", oFont2 ) / 2), "CÓDIGOS DE BARRA - TACHOS", oFont2, , , , )
                                            nLinPx += 60
                                            oPrn:Line(nLinPx, 30, nLinPx, nColMax)
                                            nLinPx += 10
                                            oPrn:Say(nLinPx, 30, Iif(cSubDiv $ 'MT', 'MARTELADO', 'PRODUÇÃO'), oFont3, , , , )
                                         Else
                                         Endif
                                      Endif
                             Endif
                             DbSelectArea("TCQ")
                             DbSkip()
                       Enddo
                 Enddo
               AVENDPAGE
       AVENDPRINT
Return

/**********************************************************************************************************/
/*** VldPerg - Monta perguntas na tabela SX1                                                            ***/
/**********************************************************************************************************/
//LGS#20200131 - Adequação de release 12.1.25 e posteriores
/*
Static Function VldPerg()
       Local aHelp1 := {}
       aAdd( aHelp1, "Tipo de recurso para impressão de  " )
       aAdd( aHelp1, "códigos de barras.                 " )
       PutSX1("PCPR11    ", "01"  ,   "Tachos ou Tanques ", ""     , ""     , "mv_ch1", "N"  , 1       , 0       , 1      , "C" , " "   , " ", " "    , " "  , "mv_par01", "Tachos", " "     , " "     , " "   , "Tanques", " "     , " "     , ".", " "     , " "     , ".", " "     , " "     , ".",  " "     ,  " "     , aHelp1  , Nil     , Nil     , "PCPR11" )
Return */