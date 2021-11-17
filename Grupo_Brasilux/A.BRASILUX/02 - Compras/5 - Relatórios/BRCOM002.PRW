#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRCOM02  บ Autor ณ Luํs Gustavo       บ Data ณ  19/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rela็ใo de NF de compras x Periodo.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function brcom02()
     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Declaracao de Variaveis                                             ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

     Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2         := "de acordo com os parametros informados pelo usuario."
     Local cDesc3         := "Rela็ใo da Ultima Nota Fiscal x Perํodo"
     //Local cPict          := ""
     Local titulo         := "Rela็ใo da Ultima Nota Fiscal x Perํodo"
     Local nLin           := 80

     Local Cabec1         := "                                                 *  CUSTO   *                       U L T I M A   N O T A   F I S C A L                        * 
     Local Cabec2         := "PRODUTO           DESCRICAO                      * GRAVADO  * EMISSAO  N. FISCAL  FORNECEDOR                            QUANTIDADE   VL. UNIT. * 
                         //   999999999999999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | 9,999.99 | 99/99/99 999999/999 999999/99 - XXXXXXXXXXXXXXXXXXXXXXXXX 999,999.9999 9,999.99
                         //  01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                         //  0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
     //Local imprime        := .T.
     Local aOrd := {}
     Private lEnd         := .F.
     Private lAbortPrint  := .F.
     //Private CbTxt        := ""
     Private limite       := 220
     Private tamanho      := "G"
     Private nomeprog     := "BRCOM02" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo        := 15
     Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
     Private nLastKey     := 0
     Private cbtxt        := Space(10)
     Private cbcont       := 00
     Private CONTFL       := 01
     Private m_pag        := 01
     Private cPerg        := padr("COM002",10," ")
     Private wnrel        := "BRCOM02" // Coloque aqui o nome do arquivo usado para impressao em disco

     Private cString      := "SD1"

     ValidPerg()
     pergunte(cPerg,.f.)
     dbSelectArea("SD1")
     dbSetOrder(1)

     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Monta a interface padrao com o usuario...                           ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

     wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     Titulo := Titulo + " - De: "+Dtoc(mv_par01)+" Ate: "+Dtoc(mv_par02)
     RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  19/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
       //Local nOrdem
       Local cQuery
       Local aQNFIS := {}
       Local i
       
       cQuery := ""
       cQuery += "SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_UPRC "
       cQuery += "FROM "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) "
       cQuery += "WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
       cQuery += "  AND SB1.D_E_L_E_T_ = '' "
       cQuery += "  AND SB1.B1_COD BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
       cQuery += "  AND SB1.B1_TIPO BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
       cQuery += "ORDER BY SB1.B1_COD "
       TCQUERY cQuery ALIAS "QNPRO" NEW
       DbSelectArea("QNPRO")
       DbGoTop()
       While !Eof()
             cQuery := ""
             cQuery += "SELECT TOP 1 SD1.D1_EMISSAO, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SA2.A2_NOME, SD1.D1_COD, SD1.D1_QUANT, SD1.D1_VUNIT "
             cQuery += "FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "
             cQuery += "LEFT OUTER JOIN "+RetSqlName("SA2")+" SA2 WITH (NOLOCK) ON SA2.A2_FILIAL = '' AND SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_LOJA = SD1.D1_LOJA AND SA2.D_E_L_E_T_ = '' "
             cQuery += "WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' "
             cQuery += "  AND SD1.D_E_L_E_T_ = '' "
             cQuery += "  AND SD1.D1_EMISSAO BETWEEN '"+dTos(mv_par01)+"' AND '"+dTos(mv_par02)+"' "
             cQuery += "  AND SD1.D1_COD = '"+QNPRO->B1_COD+"' "
             cQuery += "ORDER BY SD1.D1_EMISSAO DESC "
             TCQUERY cQuery ALIAS "QNFIS" NEW
             DbSelectArea("QNFIS")
             DbGoTop()
             While !Eof()
                   aAdd(aQNFIS, { QNPRO->B1_COD+' - '+QNPRO->B1_DESC, QNPRO->B1_UPRC,;
                                  SUBSTR(QNFIS->D1_EMISSAO,7,2)+"/"+SUBSTR(QNFIS->D1_EMISSAO,5,2)+"/"+SUBSTR(QNFIS->D1_EMISSAO,3,2),;
                                  QNFIS->D1_DOC+"/"+QNFIS->D1_SERIE,;
                                  QNFIS->D1_FORNECE+"/"+QNFIS->D1_LOJA+" - "+SUBSTR(QNFIS->A2_NOME,1,25),;
                                  QNFIS->D1_QUANT,;
                                  QNFIS->D1_VUNIT})
                   DbSelectArea("QNFIS")
                   DbSkip()
             Enddo
             DbSelectArea("QNFIS")
             DbCloseArea()
             DbSelectArea("QNPRO")
             DbSkip()
       Enddo
       DbSelectArea("QNPRO")
       DbCloseArea()

       /*
       cQuery := ""
       cQuery := cQuery + "SELECT D1.D1_EMISSAO, D1.D1_DOC, D1.D1_SERIE, D1.D1_FORNECE, D1.D1_LOJA, A2.A2_NOME, D1.D1_COD, B1.B1_DESC, D1.D1_QUANT, D1.D1_VUNIT "
       cQuery := cQuery + "FROM "+RetSqlName("SD1")+" D1 "
       cQuery := cQuery + "INNER JOIN "+RetSqlName("SB1")+" B1 ON B1.B1_FILIAL+B1.B1_COD = D1.D1_FILIAL+D1.D1_COD "
       cQuery := cQuery + "INNER JOIN "+RetSqlName("SA2")+" A2 ON A2.A2_COD+A2.A2_LOJA = D1.D1_FORNECE+D1.D1_LOJA "
       cQuery := cQuery + "WHERE D1.D1_FILIAL = '01' AND D1.D_E_L_E_T_ = '' "
       cQuery := cQuery + "  AND B1.D_E_L_E_T_ = '' "
       cQuery := cQuery + "  AND A2.D_E_L_E_T_ = '' "       
       cQuery := cQuery + "  AND D1.D1_EMISSAO BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' "
       cQuery := cQuery + "  AND D1.D1_COD     BETWEEN '"+(mv_par03)+"'     AND '"+(mv_par04)+"' "
       cQuery := cQuery + "ORDER BY D1.D1_COD+D1.D1_EMISSAO DESC "
       
       TCQUERY cQuery NEW ALIAS "QNFIS"
       
       DbSelectArea("QNFIS")
       DbGoTop()
       While !Eof()
             cProd := QNFIS->D1_COD
             _Vez := 1
             While !Eof() .and. QNFIS->D1_COD == cProd 
                   If _Vez == 1
                      aadd(aQNFIS, { QNFIS->D1_COD+" - "+QNFIS->B1_DESC,;
                                     SUBSTR(QNFIS->D1_EMISSAO,7,2)+"/"+SUBSTR(QNFIS->D1_EMISSAO,5,2)+"/"+SUBSTR(QNFIS->D1_EMISSAO,3,2),;
                                     QNFIS->D1_DOC+"/"+QNFIS->D1_SERIE,;
                                     QNFIS->D1_FORNECE+"/"+QNFIS->D1_LOJA+" - "+SUBSTR(QNFIS->A2_NOME,1,25),;
                                     QNFIS->D1_QUANT,;
                                     QNFIS->D1_VUNIT,;
                                     "",;
                                     "",;
                                     "",;
                                     0,;
                                     0 })
                                     _Vez := _Vez + 1
                   ElseIf _Vez == 2
                          nPos := aScan(aQNFIS,{ |x| SUBSTR(x[1],1,15) == QNFIS->D1_COD })
                          If nPos > 0
                             aQNFIS[nPos,7]  := SUBSTR(QNFIS->D1_EMISSAO,7,2)+"/"+SUBSTR(QNFIS->D1_EMISSAO,5,2)+"/"+SUBSTR(QNFIS->D1_EMISSAO,3,2)
                             aQNFIS[nPos,8]  := QNFIS->D1_DOC+"/"+QNFIS->D1_SERIE
                             aQNFIS[nPos,9]  := QNFIS->D1_FORNECE+"/"+QNFIS->D1_LOJA+" - "+SUBSTR(QNFIS->A2_NOME,1,25)
                             aQNFIS[nPos,10] := QNFIS->D1_QUANT
                             aQNFIS[nPos,11] := QNFIS->D1_VUNIT
                          Endif
                          _Vez := _Vez + 1
                   Endif
                   DbSelectArea("QNFIS")
                   DbSkip()
             Enddo
       Enddo
       aSort(aQNFIS,,, { |x, y| x[1] < y[1] })
       
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       DbSelectArea("QNFIS")
       DbCloseArea("QNFIS")

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Busca Produtos que estao sem ultima entrada no periodo              ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       _Ret := "('"
       For i := 1 to Len(aQNFIS)
           If Empty(aQNFIS[i,07])
              _Ret := _Ret + Alltrim(SubString(aQNFIS[i,01],1,15))+"','"
           Endif
       Next
       _Ret := SubString(_Ret,1,Len(_Ret)-2)+")"
       
       cQuery := ""
       cQuery := cQuery + "SELECT D1.D1_EMISSAO, D1.D1_DOC, D1.D1_SERIE, D1.D1_FORNECE, D1.D1_LOJA, A2.A2_NOME, D1.D1_COD, B1.B1_DESC, D1.D1_QUANT, D1.D1_VUNIT "
       cQuery := cQuery + "FROM "+RetSqlName("SD1")+" D1 "
       cQuery := cQuery + "INNER JOIN "+RetSqlName("SB1")+" B1 ON B1.B1_FILIAL+B1.B1_COD = D1.D1_FILIAL+D1.D1_COD "
       cQuery := cQuery + "INNER JOIN "+RetSqlName("SA2")+" A2 ON A2.A2_COD+A2.A2_LOJA = D1.D1_FORNECE+D1.D1_LOJA "
       cQuery := cQuery + "WHERE D1.D1_FILIAL = '01' AND D1.D_E_L_E_T_ = '' "
       cQuery := cQuery + "  AND B1.D_E_L_E_T_ = '' "
       cQuery := cQuery + "  AND A2.D_E_L_E_T_ = '' "       
       cQuery := cQuery + "  AND D1.D1_EMISSAO BETWEEN '"+Dtos(mv_par05)+"' AND '"+Dtos(mv_par01)+"' "
       cQuery := cQuery + "  AND D1.D1_COD     In "+_Ret+" "
       cQuery := cQuery + "ORDER BY D1.D1_COD+D1.D1_EMISSAO DESC "

       TCQUERY cQuery NEW ALIAS "QNFIS"

       DbSelectArea("QNFIS")
       DbGoTop()
       While !Eof()
             cProd := QNFIS->D1_COD
             _Vez := 1
             While !Eof() .and. QNFIS->D1_COD == cProd 
                   If _Vez == 1
                      nPos := aScan(aQNFIS,{ |x| SUBSTR(x[1],1,15) == QNFIS->D1_COD })
                      If nPos > 0
                         aQNFIS[nPos,7]  := SUBSTR(QNFIS->D1_EMISSAO,7,2)+"/"+SUBSTR(QNFIS->D1_EMISSAO,5,2)+"/"+SUBSTR(QNFIS->D1_EMISSAO,3,2)
                         aQNFIS[nPos,8]  := QNFIS->D1_DOC+"/"+QNFIS->D1_SERIE
                         aQNFIS[nPos,9]  := QNFIS->D1_FORNECE+"/"+QNFIS->D1_LOJA+" - "+SUBSTR(QNFIS->A2_NOME,1,25)
                         aQNFIS[nPos,10] := QNFIS->D1_QUANT
                         aQNFIS[nPos,11] := QNFIS->D1_VUNIT
                      Endif
                      _Vez := _Vez + 1
                   Endif
                   DbSelectArea("QNFIS")
                   DbSkip()
             Enddo
       Enddo

       DbSelectArea("QNFIS")
       DbCloseArea("QNFIS")
       */
       SetRegua(Len(aQNFIS))

       For i := 1 to Len(aQNFIS)
             //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
             //ณ Verifica o cancelamento pelo usuario...                             ณ
             //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

             If lAbortPrint
                @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif

             //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
             //ณ Impressao do cabecalho do relatorio. . .                            ณ
             //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
             //PRODUTO           DESCRICAO                      * GRAVADO  * EMISSAO  N. FISCAL  FORNECEDOR                            QUANTIDADE   VL. UNIT. * 
             //999999999999999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | 9,999.99 | 99/99/99 999999/999 999999/99 - XXXXXXXXXXXXXXXXXXXXXXXXX 999,999.9999 9,999.99
             //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
             //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22

             If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                nLin := nLin + 1
             Endif
             @ nLin,000 PSAY aQNFIS[i,1]
             @ nLin,049 PSAY "*"
             @ nLin,051 PSAY aQNFIS[i,2] Picture "@E 9,999.99"
             @ nLin,060 PSAY "*"
             @ nLin,062 PSAY aQNFIS[i,3]
             @ nLin,071 PSAY aQNFIS[i,4]
             @ nLin,082 PSAY aQNFIS[i,5]
             @ nLin,120 PSAY aQNFIS[i,6] Picture "@E 999,999.9999"
             @ nLin,133 PSAY aQNFIS[i,7] Picture "@E 9,999.99"
             //@nLin,132 PSAY "*"
             //@nLin,134 PSAY aQNFIS[i,7]
             //@nLin,143 PSAY aQNFIS[i,8]
             //@nLin,154 PSAY aQNFIS[i,9]
             //@nLin,192 PSAY aQNFIS[i,10] Picture "@E 999,999.9999"
             //@nLin,205 PSAY aQNFIS[i,11] Picture "@E 9,999.99"
             nLin := nLin + 1 // Avanca a linha de impressao
       Next

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Finaliza a execucao do relatorio...                                 ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       SET DEVICE TO SCREEN

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณVALIDPERG บ Autor ณ AP5 IDE            บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValidPerg()
       Local i, j
       _sAlias := Alias()
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs,{cPerg,"01","Do Periodo        ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"02","Ate o Periodo     ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"03","Do Produto        ?","","","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"04","Ate Produto       ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       //AADD(aRegs,{cPerg,"05","Data Limite Final ?","","","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"05","Do Tipo           ?","","","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"06","At้ Tipo          ?","","","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       For i := 1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i,2])
              RecLock("SX1",.T.)
              For j := 1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                  Endif
              Next
              MsUnlock()
           Endif
       Next     
       DbSelectArea(_sAlias)
Return