#include "PROTHEUS.ch"
#include "avprint.ch"    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO5     º Autor ³ AP6 IDE            º Data ³  23/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FATX01_H()
     Local Cabec1  := "CLIENTE                                       PEDIDO   EMISSAO   VLR. MERC.   VLR.TOTAL    REPRESENTANTE"
     Local Cabec2  := ""
     Local Titulo  := "Relatório de Pedidos a Liberar"
     Local NomPro  := "FATX01_H"
     Local cOrien  := "P" //R=Retrato # P=Paisagem
     Local nPag    := 0
     Local nLin    := 0
     Local nMaxL   := Iif(cOrien == "P", 50, 75)
     Local nConReg := Iif(cOrien == "P", 51, 76)
     Private oFo1  := TFont():New("Courier New", 9, 14, .F., .T., 5, .F., 5, .T., .F.)
     Private oFo2  := TFont():New("Courier New", 9, 10, .F., .T., 5, .F., 5, .T., .F.)
     Private oFo3  := TFont():New("Courier New", 9, 10, .F., .F., 5, .T., 5, .T., .F.)
     //                      0         1         2         3         4         5         6         7         8         9         10        11        12        13
     //                      0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
     //                      999999/99 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999  99/99/99  999,999.99  999,999.99  999999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
     //                      CLIENTE                                        PEDIDO  EMISSAO   VLR. MERC.  VLR.TOTAL   REPRESENTANTE
     oPrn:= TMSPrinter():New(Titulo)
     oPrn:SetLandscape() //SetPortrait()

     AVPRINT oPrn NAME Titulo
       AVPAGE
         DbSelectArea("TMP")
         DbGoTop()
         While !Eof()
               If nConReg > nMaxL
                  nConReg := 0
                  nTotPag := Iif( ( ( RecCount() / 50 ) - Int( ( RecCount() / 50 ) ) ) > 0, Int( ( RecCount() / 50 ) ) + 1, Int( ( RecCount() / 50 ) ) )
                  nLin := u_fImpCabGrf(cOrien, Cabec1, Cabec2, Titulo, NomPro, nTotPag, @nPag )
               Endif

               oPrn:Say ( LC("C", nLin) , LC("C",  1.1), TMP->CLIENTE , oFo3 )                             //CLIENTE  - 45 * 0.18 = 8.1
               oPrn:Say ( LC("C", nLin) , LC("C",  9.7), TMP->PEDIDO  , oFo3 )                             //PEDIDO   -  6 * 0.18 = 1.08
               oPrn:Say ( LC("C", nLin) , LC("C", 11.3), DTOC(TMP->EMISSAO) , oFo3 )                       //EMISSAO  -  8 * 0.18 = 1.44
               oPrn:Say ( LC("C", nLin) , LC("C", 13.3), TRANSFORM(TMP->VLRMERC, "@E 999,999.99") , oFo3 ) //VLRMERC  - 10 * 0.18 = 1.8
               oPrn:Say ( LC("C", nLin) , LC("C", 15.6), TRANSFORM(TMP->VLRTOT,  "@E 999,999.99") , oFo3 ) //VLRTOT   - 10 * 0.18 = 1.8
               oPrn:Say ( LC("C", nLin) , LC("C", 17.9), TMP->VENDEDOR, oFo3 )                             //VENDEDOR - 45 * 0.18 = 8.1
               nConReg += 1
               nLin    += 0.35
               DbSelectArea("TMP")
               DbSkip()
         Enddo
       AVENDPAGE
     AVENDPRINT
     DbSelectArea("TMP")
     DbGoTop()
     MS_FLUSH()
Return

User Function fImpCabGrf(cOrient, cCabec1, cCabec2, cTitulo, cNomPro, nTotPag, nPagAtu)
     //Verificação das variáveis dos parâmetros
     cOrient := Iif(cOrient == Nil,  "R", cOrient ) //P=Paisagem # R=Retrato
     cCabec1 := Iif(cCabec1 == Nil,   "", cCabec1 ) //1º Linha de Cabeçalho 
     cCabec2 := Iif(cCabec2 == Nil,   "", cCabec2 ) //2º Linha de Cabeçalho 
     cTitulo := Iif(cTitulo == Nil,   "", cTitulo ) //Titulo do Relatório
     cNomPro := Iif(cNomPro == Nil,   "", cNomPro ) //Nome do Programa
     nTotPag := Iif(nTotPag == Nil,    1, nTotPag ) //Total de paginas

     //Calculos para posicionamentos - Considerando papel A4 21,0 x 29,7 cm - TODAS AS MEDIDAS SÃO EM CENTIMETROS
     nColIni := 1                                                            //Coluna Inicio para impressão do traço
     nColImp := 1.1                                                          //Coluna Inicio para impressão dos dados
     nColDir := 0.54                                                         //Recuo da Coluna da Direita
     nTamMax := Iif(cOrient == "R",   58,  106    )                          //Numero maximo de caracteres para o titulo
     nTamOri := Iif(cOrient $ "R" , 20.0, 28.7    )                          //Coluna Final  para impressão do traço dependendo da orientação (Paisagem ou Retrato)
     nTamCar := 0.18                                                         //Tamanho da caracter em cm
     nTamTit := Len(cTitulo)                                                 //Tamanho da string do titulo
     nTamTit := Iif(nTamTit > nTamMax, SubStr(cTitulo, 1, nTamMax), nTamTit) //Verifica se o tamanho maximo do titulo não excede o espaço disponível
     nTamSub := 17                                                           //Tamanho dos sub-titulos da direita da pagina
     nColTit := ((nTamOri - nColIni) / 2) - ((nTamTit * nTamCar) / 2)        //Coluna para inicio de impressão do Titulo

     //Ajustes de variáveis
     If Empty(cCabec2)
        If !Empty(cCabec1)
           cCabec2 := cCabec1
           cCabec1 := ""
        Endif
     Endif

     If nPagAtu > 0
        AVNEWPAGE
     Endif
     nPagAtu += 1
     nLin    := 0.49
     //1º Linha - Traço, mais forte  - 0.49
     oPrn:Line( LC("C", nLin       ), LC("C", nColIni), LC("C", nLin       ), LC("C", nTamOri) ) //0.49
     oPrn:Line( LC("C", nLin + 0.01), LC("C", nColIni), LC("C", nLin + 0.01), LC("C", nTamOri) ) //0.50
     oPrn:Line( LC("C", nLin + 0.02), LC("C", nColIni), LC("C", nLin + 0.02), LC("C", nTamOri) ) //0.51
     //2º Linha - Empresa / Folha
     nLin += 0.03
     oPrn:SayBitmap(LC("C", nLin   ), LC("C", nColImp), "\SYSTEM\LGRL"+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2)+".bmp", LC("C", 2), LC("C", 0.7))    //0.52
     oPrn:Say ( LC("C", nLin       ), LC("C", (nTamOri - nColDir) - (nTamSub * nTamCar)), "Folha....: "+StrZero(nPagAtu, 3)+"/"+StrZero(nTotPag, 3), oFo3 )
     //3º Linha - Programa / Titulo / Data de Referência
     nLin += 0.30
     oPrn:Say ( LC("C", nLin       ), LC("C", nColImp)                                  , "PROGRAMA.: "+cNomPro        , oFo3 )
     oPrn:Say ( LC("C", nLin       ), LC("C", nColTit)                                  , cTitulo                      , oFo2 )
     oPrn:Say ( LC("C", nLin       ), LC("C", (nTamOri - nColDir) - (nTamSub * nTamCar)), "Dt. Ref..: "+DTOC(dDataBase), oFo3 )
     //4º Linha - Hora / Emissão
     nLin += 0.30
     oPrn:Say ( LC("C", nLin       ), LC("C", nColImp)                                  , "HORA.....: "+Time()         , oFo3 )
     oPrn:Say ( LC("C", nLin       ), LC("C", (nTamOri - nColDir) - (nTamSub * nTamCar)), "Emissão..: "+DTOC(MsDate()) , oFo3 )
     //5º Linha - Traço, mais forte  - 1.49
     nLin += 0.37
     oPrn:Line( LC("C", nLin       ), LC("C", nColIni), LC("C", nLin       ), LC("C", nTamOri) ) //1.49
     oPrn:Line( LC("C", nLin + 0.01), LC("C", nColIni), LC("C", nLin + 0.01), LC("C", nTamOri) ) //1.50
     oPrn:Line( LC("C", nLin + 0.02), LC("C", nColIni), LC("C", nLin + 0.02), LC("C", nTamOri) ) //1.51
     //6º Linha - 1º Linha do Cabeçalho - 1.52
     nLin += 0.03
     oPrn:Say ( LC("C", nLin       ), LC("C", nColImp)                                  , cCabec1                      , oFo2 ) //1.52
     //7º Linha - 2º Linha do Cabeçalho - 1.82
     nLin += 0.30
     oPrn:Say ( LC("C", nLin       ), LC("C", nColImp)                                  , cCabec2                      , oFo2 ) //1.82
     //8º Linha - Traço mais fino
     nLin += 0.32
     oPrn:Line( LC("C", nLin       ), LC("C", nColIni), LC("C", nLin       ), LC("C", nTamOri) ) //2.11
     //1º Linha para impressão de dados
     nLin += 0.10
Return(nLin)

/*========================================================================
CONVERTE AS MEDIDAS EM Cm PARA Pixel
*/
STATIC FUNCTION LC(cCoord, nCm)
       LOCAL nFator := IF(cCoord == "L", 0.26, 0.31)
RETURN (nCm - nFator) * 50 / 0.42