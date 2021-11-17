#include "rwmake.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATR53 º Autor ³ Cleber Orati       º Data ³  11/12/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Pedidos Colocados no Periodo                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATR53()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Vendas"
     //Local cPict         := ""
     Local titulo        := "VENDAS"
     Local nLin          := 80
     Local Cabec1        := ""
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "M"
     Private nomeprog    := "BRFATR53" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "BRFATR53"
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR53" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SC5"
         
	 if !u_VldAcesso(funname())
         MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      	 return 
  	 endif 

	 //CriaSX1(cPerg)
	 Pergunte(cPerg,.F.)

     DbSelectArea("SC5")
     DbSetOrder(1)

	 wnrel:="BRFATR53"
	
     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4] == 1, 15, 18)
     If mv_par11 == 1
        If mv_par15 == 1
           Titulo := "Vendas x Produto (Analitico)"
           Cabec1 := "CLIENTE                               REPRESENTANTE                         CIDADE                   CL PERIODO  QUANT. VALOR"
        Else
           Titulo := "Vendas x Produto (Sintético) - "+dToc(mv_par12)+' a '+dToc(mv_par13)
           Cabec1 := "                                                                                                                 QUANT. VALOR"
        Endif
        Cabec2 := ""
     ElseIf mv_par11 == 2
            If mv_par15 == 1
               Titulo := "Vendas x Linha (Analítico)"
               Cabec1 := "CLIENTE                               REPRESENTANTE                         CIDADE                   CL PERIODO  QUANT. VALOR"
            Else
               Titulo := "Vendas x Linha (Sintético) - "+dToc(mv_par12)+' a '+dToc(mv_par13)
               Cabec1 := "                                                                                                                 QUANT. VALOR"
            Endif
            Cabec2 := ""
     ElseIf mv_par11 == 3
        Titulo := "Vendas x Cliente (Produto)"
        Cabec1 := "PRODUTO                                                                                                 PERIODO  QUANT. VALOR"
        Cabec2 := ""
     ElseIf mv_par11 == 4
        Titulo := "Vendas x Representante (Produto)"
        Cabec1 := "PRODUTO                                                                                                 PERIODO  QUANT. VALOR"
        Cabec2 := ""
     ElseIf mv_par10 == 5
            If mv_par14 == 1
               If mv_par15 == 1
                  Titulo := "Vendas x Cliente (Linha - Analitico)"
                  Cabec1 := "LINHA                                                                                                   PERIODO  QUANT. VALOR"
               Else
                  Titulo := "Vendas x Cliente (Linha - Sintético) - "+dToc(mv_par12)+' a '+dToc(mv_par13)
                  Cabec1 := "LINHA                                                                                                            QUANT. VALOR"
               Endif
               Cabec2 := ""
            ElseIf mv_par14 == 2
                   If mv_par15 == 1
                      Titulo := "Vendas x Representante (Linha - Analitico)"
                      Cabec1 := "LINHA                                                                                                   PERIODO  QUANT. VALOR"
                   Else
                      Titulo := "Vendas x Representante (Linha - Sintético) - "+dToc(mv_par12)+' a '+dToc(mv_par13)
                      Cabec1 := "LINHA                                                                                                            QUANT. VALOR"
                   Endif
                   Cabec2 := ""
            Endif
     Endif
     Processa({|| FATR07_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FATR07_1 º Autor ³ Luís G. de Souza   º Data ³  16/12/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FATR07_1(Cabec1, Cabec2, Titulo, nLin)

       Local cQry1 := ""
       Local cQry2 := ""
       Local cQry3 := ""                  // 1234567890123456                       1234567890123456                       1234567890123456                       1234567890123456    12345
       Local cClas := Iif(mv_par10 == 1, 'Consumidor Final', Iif(mv_par10 == 2, 'Industrialização', Iif(mv_par10 == 3, 'Não Contribuinte', Iif(mv_par10 == 4, 'Comercio/Revenda', 'Todos'))))
       If mv_par11 == 1
          cQry1 += "SELECT SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4) AS PERIODO, "
          cQry1 += "       C6_PRODUTO AS CODIGO, C5_CLIENTE AS CLIENTE, C5_VEND1 AS VENDEDOR, A1_CODCID AS CIDADE, "
          cQry1 += "       SUM(C6_QTDVEN) AS QUANTIDADE, SUM(C6_VALOR/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS TOTAL "
       ElseIf mv_par11 == 2
          cQry1 += "SELECT SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4) AS PERIODO, "
          cQry1 += "       SUBSTRING(C6_PRODUTO, 4, 2) AS CODIGO, C5_CLIENTE AS CLIENTE, C5_VEND1 AS VENDEDOR, A1_CODCID AS CIDADE, "
          cQry1 += "       SUM(C6_QTDVEN) AS QUANTIDADE, SUM(C6_VALOR/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS TOTAL "
       ElseIf mv_par11 == 3
          cQry1 += "SELECT SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4) AS PERIODO, "
          cQry1 += "       C6_PRODUTO AS CODIGO, C5_CLIENTE AS CLIENTE, C5_VEND1 AS VENDEDOR, A1_CODCID AS CIDADE, "
          cQry1 += "       SUM(C6_QTDVEN) AS QUANTIDADE, SUM(C6_VALOR/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS TOTAL "
       ElseIf mv_par11 == 4 //REPRESENTANTE X PRODUTO
          cQry1 += "SELECT SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4) AS PERIODO, "
          cQry1 += "       C6_PRODUTO AS CODIGO, C5_VEND1 AS VENDEDOR, A1_CODCID AS CIDADE, "
          cQry1 += "       SUM(C6_QTDVEN) AS QUANTIDADE, SUM(C6_VALOR/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS TOTAL "
       ElseIf mv_par11 == 5
              If mv_par14 == 1
                 cQry1 += "SELECT SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4) AS PERIODO, "
                 cQry1 += "       SUBSTRING(C6_PRODUTO, 4, 2) AS CODIGO, C5_CLIENTE AS CLIENTE, C5_VEND1 AS VENDEDOR, A1_CODCID AS CIDADE, "
                 cQry1 += "       SUM(C6_QTDVEN) AS QUANTIDADE, SUM(C6_VALOR/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS TOTAL "
              ElseIf mv_par14 == 2
                 cQry1 += "SELECT SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4) AS PERIODO, "
                 cQry1 += "       SUBSTRING(C6_PRODUTO, 4, 2) AS CODIGO, C5_VEND1 AS VENDEDOR, "
                 cQry1 += "       SUM(C6_QTDVEN) AS QUANTIDADE, SUM(C6_VALOR/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS TOTAL "
              Endif
       Endif
       cQry2 += "SELECT COUNT(*) AS QTDREC "
       cQry3 += "FROM "+RetSqlName("SC5")+" FAT WITH (NOLOCK) "
       cQry3 += "LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (C5_FILIAL = C6_FILIAL) AND (C5_NUM = C6_NUM) AND (SC6.D_E_L_E_T_ <> '*') "
       cQry3 += "LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ = '') AND (F4_FILIAL = '"+xFilial("SF4")+"') and (F4_CODIGO = C6_TES) "
       cQry3 += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ = '') AND (A1_FILIAL = '"+xFilial("SA1")+"') and (C5_CLIENTE = A1_COD) "
	   cQry3 += "WHERE (FAT.D_E_L_E_T_ <> '*') AND "
	   cQry3 += "(C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_TIPO = 'N') AND (C5_APROVA <> '2') AND ((SF4.F4_DUPLIC <> 'N') OR (C6_TES = '519')) "   
	   //Chamado 007514, tirar códigos de repres. especificos do Glaidon 
	   if __cUserId = "000282"
			cQry3 += "AND (C5_VEND1 NOT IN ('000250','000444','000303','000333','000438','000276')) "
	   endif 

       if !empty(MV_PAR01) .OR. (MV_PAR11 == 2)
	   		cQry3 += "AND (LEN(C6_PRODUTO) = 12) "
	   endif
	   
       if !empty(MV_PAR01)
	   		cQry3 += "AND "+U_ParamSql("SUBSTRING(C6_PRODUTO,4,2)",MV_PAR01)+" "
	   endif
       cQry3 += "  AND (C6_PRODUTO             BETWEEN '"+mv_par02+"' AND '"+mv_par03+"') "
       cQry3 += "  AND (C5_CLIENTE             BETWEEN '"+mv_par04+"' AND '"+mv_par05+"') "
       cQry3 += "  AND (C5_VEND1               BETWEEN '"+mv_par06+"' AND '"+mv_par07+"') "
       cQry3 += "  AND (A1_CODCID              BETWEEN '"+mv_par08+"' AND '"+mv_par09+"') "
       cQry3 += "  AND (C5_EMISSAO             BETWEEN '"+dtos(mv_par12)+"' AND '"+dtos(mv_par13)+"') "
       If mv_par10 <> 5
          cQry3 += " AND (A1_CLAS = '"+Iif(mv_par10 == 1, 'C', Iif(mv_par10 == 2, 'I', Iif(mv_par10 == 3, 'N', 'V')))+"') "
       Endif
		if !empty(MV_PAR16)   
			cAux := U_RegiaoGeo(MV_PAR16)
			if !empty(cAux)
				cQry3 += "AND (A1_EST IN ("+cAux+")) "
			endif 
		endif		                           

       if !empty(MV_PAR17)
	   		cQry3 += "AND ((A1_SATIV2 = '') OR ("+U_ParamSql("A1_SATIV2",MV_PAR17)+")) "
	   endif

       if !empty(MV_PAR18)
	   		cQry3 += "AND "+U_ParamSql("A1_EST",MV_PAR18)+" "
	   endif

       cQry1 += cQry3
       cQry2 += cQry3
       If mv_par11 == 1
          cQry1 += "GROUP BY SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4), C6_PRODUTO, C5_CLIENTE, C5_VEND1, A1_CODCID "
          cQry1 += "ORDER BY C6_PRODUTO, C5_CLIENTE, SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4) "
       ElseIf mv_par11 == 2
          cQry1 += "GROUP BY SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4), SUBSTRING(C6_PRODUTO, 4, 2), C5_CLIENTE, C5_VEND1, A1_CODCID "
          cQry1 += "ORDER BY SUBSTRING(C6_PRODUTO, 4, 2), C5_CLIENTE, SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4) "
       ElseIf mv_par11 == 3
          cQry1 += "GROUP BY SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4), C5_CLIENTE, C6_PRODUTO, C5_VEND1, A1_CODCID "
          cQry1 += "ORDER BY C5_CLIENTE+C5_VEND1, C6_PRODUTO, SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4) "
       ElseIf mv_par11 == 4 //REPRESENTANTE X PRODUTO
          cQry1 += "GROUP BY SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4), C5_VEND1, C6_PRODUTO, A1_CODCID "
          cQry1 += "ORDER BY C5_VEND1, C6_PRODUTO, SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4) "
       ElseIf mv_par11 == 5
              If mv_par14 == 1
                 cQry1 += "GROUP BY SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4), SUBSTRING(C6_PRODUTO, 4, 2), C5_CLIENTE, C5_VEND1, A1_CODCID "
                 cQry1 += "ORDER BY C5_CLIENTE, SUBSTRING(C6_PRODUTO, 4, 2), SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4) "
              ElseIf mv_par14 == 2
                     cQry1 += "GROUP BY SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4), C5_VEND1, SUBSTRING(C6_PRODUTO, 4, 2) "
                     cQry1 += "ORDER BY C5_VEND1, SUBSTRING(C6_PRODUTO, 4, 2), SUBSTRING(C5_EMISSAO, 5, 2)+'/'+SUBSTRING(C5_EMISSAO, 1, 4) "
              Endif
       Endif
       
       TCQuery cQry1 ALIAS "TCQ" NEW
       TCQuery cQry2 ALIAS "QRE" NEW
       DbSelectArea("QRE")
       nQtdRec := QRE->QTDREC
       DbSelectArea("QRE")
       DbCloseArea()

       DbSelectArea("TCQ")
       DbGoTop()
       ProcRegua(nQtdRec)
       nQtdGer := 0
       nValGer := 0
       While !Eof()
             If lAbortPrint
                @ nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif
             If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                nLin += 1
             Endif
             If mv_par11 == 1 //PRODUTO
                //CLIENTE                               REPRESENTANTE                         CIDADE                   CL PERIODO  QUANT. VALOR
                //0         1         2         3         4         5         6         7         8         9         10        11        12        13
                //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
                //XX 99.99.999-99 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                                                                   XXXXXXXXXXXXXXXX
                //-------------------------------------------------------------------------------------------------------------------------------------
                //999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999999-XXXXXXXXXXXXXXXXX XX 99/9999  999999 9,999,999.99
                cCodPro := TCQ->CODIGO
                @ nLin, 000 PSAY Alltrim(cCodPro) Picture "@R XX 99.99.999-99"
                @ nLin, 016 PSAY ' - '+SubStr(Posicione("SB1", 1, xFilial("SB1")+TCQ->CODIGO, "B1_DESC"), 1, 30)
                @ nLin, 115 PSAY cClas
                nLin += 1
                If mv_par15 == 1
                   @ nLin, 000 PSAY Replicate("-", 132)
                   nLin += 1
                Endif
                nTotQtd := 0
                nTotVal := 0
                While !Eof() .AND. TCQ->CODIGO == cCodPro
                      IncProc()
                      If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                         nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                         nLin += 1
                      Endif
                      If mv_par15 == 1
                         @ nLin, 000 PSAY TCQ->CLIENTE +'-'+SubStr(Posicione("SA1", 1, xFilial("SA1")+TCQ->CLIENTE , "A1_NOME"), 1, 30)
                         @ nLin, 038 PSAY TCQ->VENDEDOR+'-'+SubStr(Posicione("SA3", 1, xFilial("SA3")+TCQ->VENDEDOR, "A3_NOME"), 1, 30)
                         @ nLin, 076 PSAY TCQ->CIDADE  +'-'+SubStr(Posicione("SZ7", 1, xFilial("SZ7")+TCQ->CIDADE  , "Z7_NOME"), 1, 17)
                         If mv_par10 == 5
                            cClaCli := Posicione("SA1", 1, xFilial("SA1")+TCQ->CLIENTE, "A1_CLAS")
                            @ nLin, 101 PSAY Iif(cClaCli $ 'C', 'CF', Iif(cClaCli $ 'I', 'IN', Iif(cClaCli $ 'N', 'NC', Iif(cClaCli $ 'V', 'CR', 'CD'))))
                         Endif
                         @ nLin, 104 PSAY TCQ->PERIODO
                         @ nLin, 113 PSAY TCQ->QUANTIDADE Picture "@E 999999"
                         @ nLin, 120 PSAY TCQ->TOTAL      Picture "@E 9,999,999.99"
                         nLin += 1
                      Endif
                      nTotQtd += TCQ->QUANTIDADE
                      nTotVal += TCQ->TOTAL
                      nQtdGer += TCQ->QUANTIDADE
                      nValGer += TCQ->TOTAL
                      DbSelectArea("TCQ")
                      DbSkip() // Avanca o ponteiro do registro no arquivo
                Enddo
             ElseIf mv_par11 == 2 //LINHA
                    //CLIENTE                               REPRESENTANTE                         CIDADE                   CL PERIODO  QUANT. VALOR
                    //0         1         2         3         4         5         6         7         8         9         10        11        12        13
                    //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
                    //99 - XXXXXXXXXXXXXXXXXXXX                                                                                          XXXXXXXXXXXXXXXX
                    //-------------------------------------------------------------------------------------------------------------------------------------
                    //999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999999-XXXXXXXXXXXXXXXXX XX 99/9999  999999 9,999,999.99
                    cCodLin := TCQ->CODIGO
                    @ nLin, 000 PSAY Alltrim(cCodLin)+' - '+SubStr(Posicione("SZ1", 1, xFilial("SZ1")+TCQ->CODIGO, "Z1_DESCR"), 1, 30)
                    @ nLin, 115 PSAY cClas
                    nLin += 1
                    If mv_par15 == 1
                       @ nLin, 000 PSAY Replicate("-", 132)
                       nLin += 1
                    Endif
                    nTotQtd := 0
                    nTotVal := 0
                    While !Eof() .AND. TCQ->CODIGO == cCodLin
                          IncProc()
                          If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                             nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                             nLin += 1
                          Endif
                          If mv_par15 == 1
                             @ nLin, 000 PSAY TCQ->CLIENTE +'-'+SubStr(Posicione("SA1", 1, xFilial("SA1")+TCQ->CLIENTE , "A1_NOME"), 1, 30)
                             @ nLin, 038 PSAY TCQ->VENDEDOR+'-'+SubStr(Posicione("SA3", 1, xFilial("SA3")+TCQ->VENDEDOR, "A3_NOME"), 1, 30)
                             @ nLin, 076 PSAY TCQ->CIDADE  +'-'+SubStr(Posicione("SZ7", 1, xFilial("SZ7")+TCQ->CIDADE  , "Z7_NOME"), 1, 17)
                             If mv_par10 == 5
                                cClaCli := Posicione("SA1", 1, xFilial("SA1")+TCQ->CLIENTE, "A1_CLAS")
                                @ nLin, 101 PSAY Iif(cClaCli $ 'C', 'CF', Iif(cClaCli $ 'I', 'IN', Iif(cClaCli $ 'N', 'NC', Iif(cClaCli $ 'V', 'CR', 'CD'))))
                             Endif
                             @ nLin, 104 PSAY TCQ->PERIODO
                             @ nLin, 113 PSAY TCQ->QUANTIDADE Picture "@E 999999"
                             @ nLin, 120 PSAY TCQ->TOTAL      Picture "@E 9,999,999.99"
                             nLin += 1
                          Endif
                          nTotQtd += TCQ->QUANTIDADE
                          nTotVal += TCQ->TOTAL
                          nQtdGer += TCQ->QUANTIDADE
                          nValGer += TCQ->TOTAL
                          DbSelectArea("TCQ")
                          DbSkip() // Avanca o ponteiro do registro no arquivo
                    Enddo
             ElseIf mv_par11 == 3 //CLIENTE X PRODUTO
                    //PRODUTO                                                                                                 PERIODO  QUANT. VALOR
                    //0         1         2         3         4         5         6         7         8         9         10        11        12        13
                    //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
                    //999999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999-XXXXXXXXXXXXXXXXXXXX        XXXXXXXXXXXXXXXX
                    //-------------------------------------------------------------------------------------------------------------------------------------
                    //XX 99.99.999-99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                                                          99/9999  999999 9,999,999.99
                    cCodCli := TCQ->CLIENTE+TCQ->VENDEDOR
                    @ nLin, 000 PSAY Alltrim(TCQ->CLIENTE)+ ' - '+SubStr(Posicione("SA1", 1, xFilial("SA1")+TCQ->CLIENTE , "A1_NOME"), 1, 30)
                    @ nLin, 041 PSAY Alltrim(TCQ->VENDEDOR)+'-'+  SubStr(Posicione("SA3", 1, xFilial("SA3")+TCQ->VENDEDOR, "A3_NOME"), 1, 30)
                    @ nLin, 080 PSAY Alltrim(TCQ->CIDADE)+  '-'+  SubStr(Posicione("SZ7", 1, xFilial("SZ7")+TCQ->CIDADE  , "Z7_NOME"), 1, 20)
                    @ nLin, 115 PSAY cClas
                    nLin += 1
                    @ nLin, 000 PSAY Replicate("-", 132)
                    nLin += 1
                    nTotQtd := 0
                    nTotVal := 0
                    While !Eof() .AND. TCQ->CLIENTE+TCQ->VENDEDOR == cCodCli
                          IncProc()
                          If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                             nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                             nLin += 1
                          Endif
                          If mv_par15 == 1
                             @ nLin, 000 PSAY TCQ->CODIGO Picture "@R XX 99.99.999-99"
                             @ nLin, 016 PSAY SubStr(Posicione("SB1", 1, xFilial("SB1")+TCQ->CODIGO, "B1_DESC"), 1, 30)
                             @ nLin, 104 PSAY TCQ->PERIODO
                             @ nLin, 113 PSAY TCQ->QUANTIDADE Picture "@E 999999"
                             @ nLin, 120 PSAY TCQ->TOTAL      Picture "@E 9,999,999.99"
                             nLin += 1
                             nTotQtd += TCQ->QUANTIDADE
                             nTotVal += TCQ->TOTAL
                             nQtdGer += TCQ->QUANTIDADE
                             nValGer += TCQ->TOTAL
                             DbSelectArea("TCQ")
                             DbSkip() // Avanca o ponteiro do registro no arquivo
                          Else
                             cCodPro := TCQ->CODIGO
                             nQtdPro := 0
                             nValPro := 0
                             @ nLin, 000 PSAY TCQ->CODIGO Picture "@R XX 99.99.999-99"
                             @ nLin, 016 PSAY SubStr(Posicione("SB1", 1, xFilial("SB1")+TCQ->CODIGO, "B1_DESC"), 1, 30)
                             While !Eof() .and. (TCQ->CLIENTE+TCQ->VENDEDOR == cCodCli) .and. (TCQ->CODIGO == cCodPro)
                                   nQtdPro += TCQ->QUANTIDADE
                                   nValPro += TCQ->TOTAL
                                   nQtdGer += TCQ->QUANTIDADE
                                   nValGer += TCQ->TOTAL
                                   nTotQtd += TCQ->QUANTIDADE
                                   nTotVal += TCQ->TOTAL
                                   DbSelectArea("TCQ")
                                   DbSkip()
                             Enddo
                             @ nLin, 113 PSAY nQtdPro         Picture "@E 999999"
                             @ nLin, 120 PSAY nValPro         Picture "@E 9,999,999.99"
                             nLin += 1
                          Endif
                    Enddo
             ElseIf mv_par11 == 4 //REPRESENTANTE X PRODUTO
                    //PRODUTO                                                                                                 PERIODO  QUANT. VALOR
                    //0         1         2         3         4         5         6         7         8         9         10        11        12        13
                    //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
                    //999999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999-XXXXXXXXXXXXXXXXXXXX        XXXXXXXXXXXXXXXX
                    //-------------------------------------------------------------------------------------------------------------------------------------
                    //XX 99.99.999-99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                                                          99/9999  999999 9,999,999.99
                    cCodRep := TCQ->VENDEDOR
                    @ nLin, 000 PSAY Alltrim(cCodRep)+' - '+SubStr(Posicione("SA3", 1, xFilial("SA3")+TCQ->VENDEDOR, "A3_NOME"), 1, 30)
                    @ nLin, 115 PSAY cClas
                    nLin += 1
                    @ nLin, 000 PSAY Replicate("-", 132)
                    nLin += 1
                    nTotQtd := 0
                    nTotVal := 0
                    While !Eof() .AND. TCQ->VENDEDOR == cCodRep
                          IncProc()
                          If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                             nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                             nLin += 1
                          Endif
                          If mv_par15 == 1
                             @ nLin, 000 PSAY TCQ->CODIGO Picture "@R XX 99.99.999-99"
                             @ nLin, 016 PSAY SubStr(Posicione("SB1", 1, xFilial("SB1")+TCQ->CODIGO, "B1_DESC"), 1, 30)
                             @ nLin, 104 PSAY TCQ->PERIODO
                             @ nLin, 113 PSAY TCQ->QUANTIDADE Picture "@E 999999"
                             @ nLin, 120 PSAY TCQ->TOTAL      Picture "@E 9,999,999.99"
                             nLin += 1
                             nTotQtd += TCQ->QUANTIDADE
                             nTotVal += TCQ->TOTAL
                             nQtdGer += TCQ->QUANTIDADE
                             nValGer += TCQ->TOTAL
                             DbSelectArea("TCQ")
                             DbSkip() // Avanca o ponteiro do registro no arquivo
                          Else
                             cCodPro := TCQ->CODIGO
                             nQtdPro := 0
                             nValPro := 0
                             @ nLin, 000 PSAY TCQ->CODIGO Picture "@R XX 99.99.999-99"
                             @ nLin, 016 PSAY SubStr(Posicione("SB1", 1, xFilial("SB1")+TCQ->CODIGO, "B1_DESC"), 1, 30)
                             While !Eof() .and. (TCQ->VENDEDOR == cCodRep) .and. (TCQ->CODIGO == cCodPro)
                                   nQtdPro += TCQ->QUANTIDADE
                                   nValPro += TCQ->TOTAL
                                   nQtdGer += TCQ->QUANTIDADE
                                   nValGer += TCQ->TOTAL
                                   nTotQtd += TCQ->QUANTIDADE
                                   nTotVal += TCQ->TOTAL
                                   DbSelectArea("TCQ")
                                   DbSkip()
                             Enddo
                             @ nLin, 113 PSAY nQtdPro         Picture "@E 999999"
                             @ nLin, 120 PSAY nValPro         Picture "@E 9,999,999.99"
                             nLin += 1
                          Endif
                    Enddo
             ElseIf mv_par11 == 5
                    If mv_par14 == 1 //CLIENTE X LINHA
                       //LINHA                                                                                                   PERIODO  QUANT. VALOR
                       //0         1         2         3         4         5         6         7         8         9         10        11        12        13
                       //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
                       //999999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999-XXXXXXXXXXXXXXXXXXXX        XXXXXXXXXXXXXXXX
                       //-------------------------------------------------------------------------------------------------------------------------------------
                       //99 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                                                                     99/9999  999999 9,999,999.99
                       cCodCli := TCQ->CLIENTE+TCQ->VENDEDOR
                       @ nLin, 000 PSAY Alltrim(TCQ->CLIENTE)+ ' - '+SubStr(Posicione("SA1", 1, xFilial("SA1")+TCQ->CLIENTE , "A1_NOME"), 1, 30)
                       @ nLin, 041 PSAY Alltrim(TCQ->VENDEDOR)+'-'+  SubStr(Posicione("SA3", 1, xFilial("SA3")+TCQ->VENDEDOR, "A3_NOME"), 1, 30)
                       @ nLin, 080 PSAY Alltrim(TCQ->CIDADE)+  '-'+  SubStr(Posicione("SZ7", 1, xFilial("SZ7")+TCQ->CIDADE  , "Z7_NOME"), 1, 20)
                       @ nLin, 115 PSAY cClas
                       nLin += 1
                       @ nLin, 000 PSAY Replicate("-", 132)
                       nLin += 1
                       nTotQtd := 0
                       nTotVal := 0
                       While !Eof() .AND. TCQ->CLIENTE+TCQ->VENDEDOR == cCodCli
                             IncProc()
                             If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                                nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                                nLin += 1
                             Endif
                             If mv_par15 == 1
                                @ nLin, 000 PSAY TCQ->CODIGO Picture "@R 99"
                                @ nLin, 003 PSAY '- '+SubStr(Posicione("SZ1", 1, xFilial("SZ1")+TCQ->CODIGO, "Z1_DESCR"), 1, 30)
                                @ nLin, 104 PSAY TCQ->PERIODO
                                @ nLin, 113 PSAY TCQ->QUANTIDADE Picture "@E 999999"
                                @ nLin, 120 PSAY TCQ->TOTAL      Picture "@E 9,999,999.99"
                                nLin += 1
                                nTotQtd += TCQ->QUANTIDADE
                                nTotVal += TCQ->TOTAL
                                nQtdGer += TCQ->QUANTIDADE
                                nValGer += TCQ->TOTAL
                                DbSelectArea("TCQ")
                                DbSkip() // Avanca o ponteiro do registro no arquivo
                             Else
                                cCodLin := TCQ->CODIGO
                                nQtdLin := 0
                                nValLin := 0
                                @ nLin, 000 PSAY TCQ->CODIGO Picture "@R 99"
                                @ nLin, 003 PSAY '- '+SubStr(Posicione("SZ1", 1, xFilial("SZ1")+TCQ->CODIGO, "Z1_DESCR"), 1, 30)
                                While !Eof() .and. (TCQ->CLIENTE+TCQ->VENDEDOR == cCodCli) .and. (TCQ->CODIGO == cCodLin)
                                      nQtdLin += TCQ->QUANTIDADE
                                      nValLin += TCQ->TOTAL
                                      nTotQtd += TCQ->QUANTIDADE
                                      nTotVal += TCQ->TOTAL
                                      nQtdGer += TCQ->QUANTIDADE
                                      nValGer += TCQ->TOTAL
                                      DbSelectArea("TCQ")
                                      DbSkip()
                                Enddo
                                @ nLin, 113 PSAY nQtdLin Picture "@E 999999"
                                @ nLin, 120 PSAY nValLin Picture "@E 9,999,999.99"
                                nLin += 1
                             Endif
                       Enddo
                    ElseIf mv_par14 == 2 //REPRESENTANTE X LINHA
                           //LINHA                                                                                                   PERIODO  QUANT. VALOR
                           //0         1         2         3         4         5         6         7         8         9         10        11        12        13
                           //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
                           //999999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                                                                            XXXXXXXXXXXXXXXX
                           //-------------------------------------------------------------------------------------------------------------------------------------
                           //99 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                                                                     99/9999  999999 9,999,999.99
                           cCodRep := TCQ->VENDEDOR
                           @ nLin, 000 PSAY Alltrim(TCQ->VENDEDOR)+'-'+  SubStr(Posicione("SA3", 1, xFilial("SA3")+TCQ->VENDEDOR, "A3_NOME"), 1, 30)
                           @ nLin, 115 PSAY cClas
                           nLin += 1
                           @ nLin, 000 PSAY Replicate("-", 132)
                           nLin += 1
                           nTotQtd := 0
                           nTotVal := 0
                           While !Eof() .AND. TCQ->VENDEDOR == cCodRep
                                 IncProc()
                                 If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                                    nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                                    nLin += 1
                                 Endif
                                 If mv_par15 == 1
                                    @ nLin, 000 PSAY TCQ->CODIGO Picture "@R 99"
                                    @ nLin, 003 PSAY '- '+SubStr(Posicione("SZ1", 1, xFilial("SZ1")+TCQ->CODIGO, "Z1_DESCR"), 1, 30)
                                    @ nLin, 104 PSAY TCQ->PERIODO
                                    @ nLin, 113 PSAY TCQ->QUANTIDADE Picture "@E 999999"
                                    @ nLin, 120 PSAY TCQ->TOTAL      Picture "@E 9,999,999.99"
                                    nLin += 1
                                    nTotQtd += TCQ->QUANTIDADE
                                    nTotVal += TCQ->TOTAL
                                    nQtdGer += TCQ->QUANTIDADE
                                    nValGer += TCQ->TOTAL
                                    DbSelectArea("TCQ")
                                    DbSkip() // Avanca o ponteiro do registro no arquivo
                                 Else
                                    cCodLin := TCQ->CODIGO
                                    nQtdLin := 0
                                    nValLin := 0
                                    @ nLin, 000 PSAY TCQ->CODIGO Picture "@R 99"
                                    @ nLin, 003 PSAY '- '+SubStr(Posicione("SZ1", 1, xFilial("SZ1")+TCQ->CODIGO, "Z1_DESCR"), 1, 30)
                                    While !Eof() .and. (TCQ->VENDEDOR == cCodRep) .and. (TCQ->CODIGO == cCodLin)
                                          nQtdLin += TCQ->QUANTIDADE
                                          nValLin += TCQ->TOTAL
                                          nTotQtd += TCQ->QUANTIDADE
                                          nTotVal += TCQ->TOTAL
                                          nQtdGer += TCQ->QUANTIDADE
                                          nValGer += TCQ->TOTAL
                                          DbSelectArea("TCQ")
                                          DbSkip()
                                    Enddo
                                    @ nLin, 113 PSAY nQtdLin Picture "@E 999999"
                                    @ nLin, 120 PSAY nValLin Picture "@E 9,999,999.99"
                                    nLin += 1
                                 Endif
                           Enddo
                    Endif
             Endif
             @ nLin, 000 PSAY Replicate("-", 132)
             nLin += 1
             @ nLin, 113 PSAY nTotQtd Picture "@E 999999"
             @ nLin, 120 PSAY nTotVal Picture "@E 9,999,999.99"
             nLin += 2 // Avanca a linha de impressao
       EndDo
       @ nLin, 000 PSAY Replicate("=", 132)
       nLin += 1
       @ nLin, 000 PSAY 'TOTAL GERAL ===>>>>>>'
       @ nLin, 113 PSAY nQtdGer Picture "@E 999999"
       @ nLin, 120 PSAY nValGer Picture "@E 9,999,999.99"
       nLin += 1
       @ nLin, 000 PSAY Replicate("=", 132)
       nLin += 1
       DbSelectArea("TCQ")
       DbCloseArea()

       SET DEVICE TO SCREEN

       If aReturn[5]==1
          DbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif
       MS_FLUSH()
Return

/******************************************************************************************************************/
/*** VLDPERG  - Gera perguntas para paramentros do relatório.                                                   ***/
/******************************************************************************************************************/
/*
Static Function CriaSX1(cPerg)

Local aHelp := {}                                                                                                                                       
   

AAdd(aHelp, {{"Informe a Linha de Produto"},  {"Informe a Linha de Produto"}, {"Informe a Linha de Produto"}})

	PutSX1(cPerg, "01",   "Linha(s) Produto"   , "Linha(s) Produto"   , "Linha(s) Produto"   , "mv_ch1", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],cPerg)
	PutSX1(cPerg, "02",   "Do Produto         ", "Do Produto         ", "Do Produto         ", "mv_ch3", "C", 15, 0, 0, "G", " ", "SB1", " ", " ", "mv_par02", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "03",   "Até o Produto      ", "Até o Produto      ", "Até o Produto      ", "mv_ch4", "C", 15, 0, 0, "G", " ", "SB1", " ", " ", "mv_par03", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "04",   "Do Cliente         ", "Do Cliente         ", "Do Cliente         ", "mv_ch5", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par04", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "05",   "Até o Cliente      ", "Até o Cliente      ", "Até o Cliente      ", "mv_ch6", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par05", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "06",   "Do Representante   ", "Do Representante   ", "Do Representante   ", "mv_ch7", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "mv_par06", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "07",   "Até o Representante", "Até o Representante", "Até o Representante", "mv_ch8", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "mv_par07", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "08",   "Da Cidade          ", "Da Cidade          ", "Da Cidade          ", "mv_ch9", "C",  6, 0, 0, "G", " ", "SZ7", " ", " ", "mv_par08", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
 	PutSX1(cPerg, "09",   "Até a Cidade       ", "Até a Cidade       ", "Até a Cidade       ", "mv_cha", "C",  6, 0, 0, "G", " ", "SZ7", " ", " ", "mv_par09", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
  	PutSX1(cPerg, "10",   "Tipo Consumidor    ", "Tipo Consumidor    ", "Tipo Consumidor    ", "mv_chb", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par10", "Consumidor Final", "Consumidor Final", "Consumidor Final"     , " "   , "Industrialização", "Industrialização"     , "Industrialização"     , "Não Contribuinte", "Não Contribuinte"     , "Não Contribuinte"     , "Comercio/Revenda", "Comercio/Revenda"     , "Comercio/Revenda"     , "Todos"       ,  "Todos",  "Todos"     , Nil  , Nil     , Nil     ,cPerg)
   	PutSX1(cPerg, "11",   "Imprime por        ", "Imprime por        ", "Imprime por        ", "mv_chc", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par11", "Produto"         , " ", " "     , " "   , "Linha"           , " "     , " "     , "Cliente x Prod." , " "     , " "     , "Repres. x Prod." , " "     , " "     , "Parâmetro 15",  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
    PutSX1(cPerg, "12",   "Do Periodo         ", "Do Periodo         ", "Do Periodo         ", "mv_chd", "D",  8, 0, 0, "G", " ",   " ", " ", " ", "mv_par12", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
    PutSX1(cPerg, "13",   "Até o Periodo      ", "Até o Periodo      ", "Até o Periodo      ", "mv_che", "D",  8, 0, 0, "G", " ",   " ", " ", " ", "mv_par13", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
    PutSX1(cPerg, "14",   "Imprime por        ", "Imprime por        ", "Imprime por        ", "mv_chf", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par14", "Cliente x Linha" , "Cliente x Linha", "Cliente x Linha"     , " "   , "Repres. x Linha" , "Repres. x Linha"     , "Repres. x Linha"     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
    PutSX1(cPerg, "15",   "Analitico/Sintetico", "Analitico/Sintetico", "Analitico/Sintetico", "mv_chg", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par15", "Analitico"       , "Analitico", "Analitico"     , " "   , "Sintetico"       , "Sintetico"     , "Sintetico"     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSx1(cPerg, "16",   "Região Geográf?"    , "Região Geográf?"    , "Região Geográf?"    , "mv_chh", "C",2,0,0,"G","","ZE","","","mv_par16","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
	PutSX1(cPerg, "17",   "Segmento(s)        ", "Segmento(s)        ", "Segmento(s)        ", "mv_chi", "C", 99,00,00, "G",  "", "T3",  "",  "", "mv_Par17","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
	PutSX1(cPerg, "18",   "Estado(s)          ", "Estado(s)          ", "Estado(s)          ", "mv_chj", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par18","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil ,cPerg)
Return
*/