#include "rwmake.ch"
#include "topconn.ch"

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ BRFATR07 ∫ Autor ≥ LuÌs G. de Souza   ∫ Data ≥  16/12/05   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Codigo gerado pelo AP6 IDE.                                ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Brasilux Tintas TÈcnicas Ltda.                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function BRFATR07()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "FATURAMENTO"
     //Local cPict         := ""
     Local titulo        := "FATURAMENTO"
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
     Private nomeprog    := "BRFATR07" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "FATR07"
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR07" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SF2"
         
	 if !u_VldAcesso(funname())
	     MsgBox("Acesso n„o autorizado!---->"+funname(),"AtenÁ„o","Alert")
      	 return 
  	 endif 

	 CriaSX1(cPerg)
	 Pergunte(cPerg,.F.)

     DbSelectArea("SF2")
     DbSetOrder(1)

	 wnrel:="BRFATR07"
	
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
           Titulo := "Faturamento x Produto (Analitico)"
           Cabec1 := "CLIENTE                               REPRESENTANTE                         CIDADE                   CL PERIODO  QUANT.   VALOR"
        Else
           Titulo := "Faturamento x Produto (SintÈtico) - "+dToc(mv_par12)+' a '+dToc(mv_par13)
           Cabec1 := "                                                                                                                 QUANT.   VALOR"
        Endif
        Cabec2 := ""
     ElseIf mv_par11 == 2
            If mv_par15 == 1
               Titulo := "Faturamento x Linha (AnalÌtico)"
               Cabec1 := "CLIENTE                               REPRESENTANTE                         CIDADE                   CL PERIODO  QUANT.   VALOR"
            Else
               Titulo := "Faturamento x Linha (SintÈtico) - "+dToc(mv_par12)+' a '+dToc(mv_par13)
               Cabec1 := "                                                                                                                 QUANT.   VALOR"
            Endif
            Cabec2 := ""
     ElseIf mv_par11 == 3
        Titulo := "Faturamento x Cliente (Produto)"
        Cabec1 := "PRODUTO                                                                                                 PERIODO  QUANT.   VALOR"
        Cabec2 := ""
     ElseIf mv_par11 == 4
        Titulo := "Faturamento x Representante (Produto)"
        Cabec1 := "PRODUTO                                                                                                 PERIODO  QUANT.   VALOR"
        Cabec2 := ""
     ElseIf mv_par10 == 5
            If mv_par14 == 1
               If mv_par15 == 1
                  Titulo := "Faturamento x Cliente (Linha - Analitico)"
                  Cabec1 := "LINHA                                                                                                   PERIODO  QUANT.   VALOR"
               Else
                  Titulo := "Faturamento x Cliente (Linha - SintÈtico) - "+dToc(mv_par12)+' a '+dToc(mv_par13)
                  Cabec1 := "LINHA                                                                                                            QUANT.   VALOR"
               Endif
               Cabec2 := ""
            ElseIf mv_par14 == 2
                   If mv_par15 == 1
                      Titulo := "Faturamento x Representante (Linha - Analitico)"
                      Cabec1 := "LINHA                                                                                                   PERIODO  QUANT.   VALOR"
                   Else
                      Titulo := "Faturamento x Representante (Linha - SintÈtico) - "+dToc(mv_par12)+' a '+dToc(mv_par13)
                      Cabec1 := "LINHA                                                                                                            QUANT.   VALOR"
                   Endif
                   Cabec2 := ""
            Endif
     Endif
     Processa({|| FATR07_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunáÑo    ≥ FATR07_1 ∫ Autor ≥ LuÌs G. de Souza   ∫ Data ≥  16/12/05   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriáÑo ≥ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ∫±±
±±∫          ≥ monta a janela com a regua de processamento.               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Programa principal                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function FATR07_1(Cabec1, Cabec2, Titulo, nLin)
      // Local nOrdem
       Local cQry1   := ""
      // Local cQry3   := ""                  // 1234567890123456                       1234567890123456                       1234567890123456                       1234567890123456    12345
       Local cCodPro := ""
       Local cCodLin := ""
       Local cCodCli := ""
       Local nQtdRec := 0
       Local nQtdGer := 0
       Local nValGer := 0
       Local nTotQtd := 0
       Local nTotVal := 0
       Local nQtdPro := 0
       Local nValPro := 0
       Local nQtdLin := 0
       Local nValLin := 0       
       Local cClas := Iif(mv_par10 == 1, 'Consumidor Final', Iif(mv_par10 == 2, 'IndustrializaÁ„o', Iif(mv_par10 == 3, 'N„o Contribuinte', Iif(mv_par10 == 4, 'Comercio/Revenda', 'Todos'))))
  
  /*
  UNION ALL 
SELECT D1_FORNECE AS CLIENTE,MAX(A1_NOME) AS RAZAO,A1_EST,A1_COD_MUN,MAX(CC2_MUN) AS CIDADE,
SUM(D1_TOTAL*-1) AS VALOR 
FROM SD1010 SD1 WITH (NOLOCK) 
LEFT OUTER JOIN SF4010 SF4 ON (SF4.D_E_L_E_T_ <> '*') AND (D1_TES = F4_CODIGO) 
LEFT OUTER JOIN SA1010 SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (D1_FORNECE = A1_COD) 
LEFT OUTER JOIN CC2010 CC2 WITH (NOLOCK) ON (CC2.D_E_L_E_T_ <> '*') AND (CC2_EST = A1_EST) AND (CC2_CODMUN = A1_COD_MUN) 
WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_TIPO = 'D') AND (A1_EST <> 'EX') AND (F4_DUPLIC = 'S') AND 
(D1_DTDIGIT BETWEEN '20140801' AND '20140831') 
*/
       
       cQuery := "WITH TMP AS (SELECT SUBSTRING(F2_EMISSAO, 5, 2)+'/'+SUBSTRING(F2_EMISSAO, 1, 4) AS PERIODO,D2_COD AS CODIGO,F2_CLIENTE AS CLIENTE,F2_VEND1 AS VENDEDOR,F2_CODCID AS CIDADE,"+;
       "SUM(D2_QUANT) AS QUANTIDADE, SUM(D2_TOTAL) AS TOTAL "+;
       "FROM "+RetSqlName("SD2")+" SD2 "+;
       "LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = D2_FILIAL) AND (F2_DOC = D2_DOC) AND (D2_SERIE = F2_SERIE) "+;
       "LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (F4_CODIGO = D2_TES) "+;
	   "WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (SF4.F4_DUPLIC = 'S') "
       if !empty(MV_PAR01)
       		cQuery += "AND (LEN(D2_COD) = 12) AND "+U_ParamSql("SUBSTRING(D2_COD,4,2)",MV_PAR01)+" "
	   endif
       cQuery += "  AND (D2_COD                  BETWEEN '"+mv_par02+"' AND '"+mv_par03+"') "
       cQuery += "  AND (F2_CLIENTE              BETWEEN '"+mv_par04+"' AND '"+mv_par05+"') "
       cQuery += "  AND (F2_VEND1                BETWEEN '"+mv_par06+"' AND '"+mv_par07+"') "
       cQuery += "  AND (F2_CODCID               BETWEEN '"+mv_par08+"' AND '"+mv_par09+"') "
       cQuery += "  AND (F2_EMISSAO              BETWEEN '"+dtos(mv_par12)+"' AND '"+dtos(mv_par13)+"') "
       If (mv_par10 <> 5) .and. (cNumEmp = "01")
          cQuery += " AND (F2_CLAS = '"+Iif(mv_par10 == 1, 'C', Iif(mv_par10 == 2, 'I', Iif(mv_par10 == 3, 'N', 'V')))+"') "
       Endif
       cQuery += "GROUP BY SUBSTRING(F2_EMISSAO, 5, 2)+'/'+SUBSTRING(F2_EMISSAO, 1, 4),D2_COD,F2_CLIENTE,F2_VEND1,F2_CODCID "
       IF MV_PAR16 == 2
       		cQuery += "UNION ALL "+;
       		"SELECT SUBSTRING(D1_DTDIGIT, 5, 2)+'/'+SUBSTRING(D1_DTDIGIT, 1, 4) AS PERIODO,D1_COD AS CODIGO,D1_FORNECE AS CLIENTE,F2_VEND1 AS VENDEDOR,F2_CODCID AS CIDADE,"+;
       		"SUM(D1_QUANT*-1.0) AS QUANTIDADE, SUM(D1_TOTAL*-1.0) AS TOTAL "+;
       		"FROM "+RetSqlName("SD1")+" SD1 "+;
       		"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = D1_FILIAL) AND (F2_DOC = D1_NFORI) AND (D1_SERIORI = F2_SERIE) AND (D1_FORNECE = F2_CLIENTE) "+;
       		"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (F4_CODIGO = D1_TES) "+;
       		"WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'D') AND (SF4.F4_DUPLIC = 'S') "
       		if !empty(MV_PAR01)
       			cQuery += "AND (LEN(D1_COD) = 12) AND "+U_ParamSql("SUBSTRING(D1_COD,4,2)",MV_PAR01)+" "
       		endif
       		cQuery += "  AND (D1_COD                  BETWEEN '"+mv_par02+"' AND '"+mv_par03+"') "
       		cQuery += "  AND (D1_FORNECE              BETWEEN '"+mv_par04+"' AND '"+mv_par05+"') "
       		cQuery += "  AND (F2_VEND1                BETWEEN '"+mv_par06+"' AND '"+mv_par07+"') "
       		cQuery += "  AND (F2_CODCID               BETWEEN '"+mv_par08+"' AND '"+mv_par09+"') "
       		cQuery += "  AND (D1_DTDIGIT              BETWEEN '"+dtos(mv_par12)+"' AND '"+dtos(mv_par13)+"') "
       		If (mv_par10 <> 5) .and. (cNumEmp = "01")
       			cQuery += " AND (F2_CLAS = '"+Iif(mv_par10 == 1, 'C', Iif(mv_par10 == 2, 'I', Iif(mv_par10 == 3, 'N', 'V')))+"') "
       		Endif
       		cQuery += "GROUP BY SUBSTRING(D1_DTDIGIT, 5, 2)+'/'+SUBSTRING(D1_DTDIGIT, 1, 4),D1_COD,D1_FORNECE,F2_VEND1,F2_CODCID "  
       	ENDIF    		
       	cQuery += ") "
       	
       	DO CASE
       	CASE (mv_par11 == 1) .OR. (mv_par11 == 3)
       		cQry1 := "SELECT PERIODO,CODIGO,CLIENTE,VENDEDOR,CIDADE,SUM(QUANTIDADE) AS QUANTIDADE, SUM(TOTAL) AS TOTAL FROM TMP "+;
       		"GROUP BY PERIODO,CODIGO,CLIENTE,VENDEDOR,CIDADE "
       	CASE (mv_par11 == 2)
       		cQry1 := "SELECT PERIODO,SUBSTRING(CODIGO,4,2) AS CODIGO,CLIENTE,VENDEDOR,CIDADE,SUM(QUANTIDADE) AS QUANTIDADE, SUM(TOTAL) AS TOTAL FROM TMP "+;
       		"GROUP BY PERIODO,SUBSTRING(CODIGO,4,2),CLIENTE,VENDEDOR,CIDADE "
        CASE (mv_par11 == 4) //REPRESENTANTE X PRODUTO
       		cQry1 :=  "SELECT PERIODO,CODIGO,VENDEDOR,CIDADE,SUM(QUANTIDADE) AS QUANTIDADE, SUM(TOTAL) AS TOTAL FROM TMP "+;
       		"GROUP BY PERIODO,CODIGO,VENDEDOR,CIDADE "
        CASE (mv_par11 == 5)
            If mv_par14 == 1
            	cQry1 := "SELECT PERIODO,SUBSTRING(CODIGO,4,2) AS CODIGO,CLIENTE,VENDEDOR,CIDADE,SUM(QUANTIDADE) AS QUANTIDADE, SUM(TOTAL) AS TOTAL FROM TMP "+;
            	"GROUP BY PERIODO,SUBSTRING(CODIGO,4,2),CLIENTE,VENDEDOR,CIDADE "
            Else
             	cQry1 := "SELECT PERIODO,SUBSTRING(CODIGO,4,2) AS CODIGO,VENDEDOR,CIDADE,SUM(QUANTIDADE) AS QUANTIDADE, SUM(TOTAL) AS TOTAL FROM TMP "+;
            	"GROUP BY PERIODO,SUBSTRING(CODIGO,4,2),VENDEDOR,CIDADE "
            Endif
        ENDCASE
        cQuery += cQry1	
      If mv_par11 == 1
           cQuery += "ORDER BY CODIGO, CLIENTE, PERIODO "
       ElseIf mv_par11 == 2
          cQuery += "ORDER BY CODIGO, CLIENTE, PERIODO "
       ElseIf mv_par11 == 3
       	  cQuery += "ORDER BY CLIENTE,VENDEDOR,CODIGO,PERIODO"
       ElseIf mv_par11 == 4 //REPRESENTANTE X PRODUTO
       	  cQuery += "ORDER BY VENDEDOR,CODIGO,PERIODO"
       ElseIf mv_par11 == 5
              If mv_par14 == 1
              	 cQuery += "ORDER BY CLIENTE,CODIGO,PERIODO"
               ElseIf mv_par14 == 2
               	 cQuery += "ORDER BY VENDEDOR,CODIGO,PERIODO"
              Endif
       Endif
       
       TCQuery cQuery ALIAS "TCQ" NEW
       nQtdRec := 100 //QRE->QTDREC

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
             If nLin > 60 // Salto de P·gina. Neste caso o formulario tem 55 linhas...
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
                @ nLin, 000 PSAY Alltrim(cCodPro) Picture "@R XXX99.99.999-99"
                @ nLin, 016 PSAY ' - '+SubStr(Posicione("SB1", 1, xFilial("SB1")+TCQ->CODIGO, "B1_DESC"), 1, 30)
                @ nLin, 060 PSAY cClas
                nLin += 1
                If mv_par15 == 1
                   @ nLin, 000 PSAY Replicate("-", 132)
                   nLin += 1
                Endif
                nTotQtd := 0
                nTotVal := 0
                While !Eof() .AND. TCQ->CODIGO == cCodPro
                      IncProc()
                      If nLin > 60 // Salto de P·gina. Neste caso o formulario tem 55 linhas...
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
                         @ nLin, 120 PSAY TCQ->TOTAL      Picture "@E 99,999,999.99"
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
                          If nLin > 60 // Salto de P·gina. Neste caso o formulario tem 55 linhas...
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
                             @ nLin, 120 PSAY TCQ->TOTAL      Picture "@E 99,999,999.99"
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
                          If nLin > 60 // Salto de P·gina. Neste caso o formulario tem 55 linhas...
                             nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                             nLin += 1
                          Endif
                          If mv_par15 == 1
                             @ nLin, 000 PSAY TCQ->CODIGO Picture "@R XX 99.99.999-99"
                             @ nLin, 016 PSAY SubStr(Posicione("SB1", 1, xFilial("SB1")+TCQ->CODIGO, "B1_DESC"), 1, 30)
                             @ nLin, 104 PSAY TCQ->PERIODO
                             @ nLin, 113 PSAY TCQ->QUANTIDADE Picture "@E 999999"
                             @ nLin, 120 PSAY TCQ->TOTAL      Picture "@E 99,999,999.99"
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
                             @ nLin, 120 PSAY nValPro         Picture "@E 99,999,999.99"
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
                          If nLin > 60 // Salto de P·gina. Neste caso o formulario tem 55 linhas...
                             nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                             nLin += 1
                          Endif
                          If mv_par15 == 1
                             @ nLin, 000 PSAY TCQ->CODIGO Picture "@R XX 99.99.999-99"
                             @ nLin, 016 PSAY SubStr(Posicione("SB1", 1, xFilial("SB1")+TCQ->CODIGO, "B1_DESC"), 1, 30)
                             @ nLin, 104 PSAY TCQ->PERIODO
                             @ nLin, 113 PSAY TCQ->QUANTIDADE Picture "@E 999999"
                             @ nLin, 120 PSAY TCQ->TOTAL      Picture "@E 99,999,999.99"
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
                             @ nLin, 120 PSAY nValPro         Picture "@E 99,999,999.99"
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
                             If nLin > 60 // Salto de P·gina. Neste caso o formulario tem 55 linhas...
                                nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                                nLin += 1
                             Endif
                             If mv_par15 == 1
                                @ nLin, 000 PSAY TCQ->CODIGO Picture "@R 99"
                                @ nLin, 003 PSAY '- '+SubStr(Posicione("SZ1", 1, xFilial("SZ1")+TCQ->CODIGO, "Z1_DESCR"), 1, 30)
                                @ nLin, 104 PSAY TCQ->PERIODO
                                @ nLin, 113 PSAY TCQ->QUANTIDADE Picture "@E 999999"
                                @ nLin, 120 PSAY TCQ->TOTAL      Picture "@E 99,999,999.99"
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
                                @ nLin, 120 PSAY nValLin Picture "@E 99,999,999.99"
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
                                 If nLin > 60 // Salto de P·gina. Neste caso o formulario tem 55 linhas...
                                    nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                                    nLin += 1
                                 Endif
                                 If mv_par15 == 1
                                    @ nLin, 000 PSAY TCQ->CODIGO Picture "@R 99"
                                    @ nLin, 003 PSAY '- '+SubStr(Posicione("SZ1", 1, xFilial("SZ1")+TCQ->CODIGO, "Z1_DESCR"), 1, 30)
                                    @ nLin, 104 PSAY TCQ->PERIODO
                                    @ nLin, 113 PSAY TCQ->QUANTIDADE Picture "@E 999999"
                                    @ nLin, 120 PSAY TCQ->TOTAL      Picture "@E 99,999,999.99"
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
                                    @ nLin, 120 PSAY nValLin Picture "@E 99,999,999.99"
                                    nLin += 1
                                 Endif
                           Enddo
                    Endif
             Endif
             @ nLin, 000 PSAY Replicate("-", 132)
             nLin += 1
             @ nLin, 113 PSAY nTotQtd Picture "@E 999999"
             @ nLin, 120 PSAY nTotVal Picture "@E 99,999,999.99"
             nLin += 2 // Avanca a linha de impressao
       EndDo
       @ nLin, 000 PSAY Replicate("=", 132)
       nLin += 1
       @ nLin, 000 PSAY 'TOTAL GERAL ===>>>>>>'
       @ nLin, 113 PSAY nQtdGer Picture "@E 999999"
       @ nLin, 120 PSAY nValGer Picture "@E 99,999,999.99"
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
/*** VLDPERG  - Gera perguntas para paramentros do relatÛrio.                                                   ***/
/******************************************************************************************************************/
Static Function CriaSX1(cPerg)

Local aHelp := {}                                                                                                                                       
   

AAdd(aHelp, {{"Informe a Linha de Produto"},  {"Informe a Linha de Produto"}, {"Informe a Linha de Produto"}})

       U_xPutSX1(cPerg, "01",   "Linha(s) Produto"  ,"Linha(s) Produto"    ,"Linha(s) Produto"    , "mv_ch1", "C", 99,00,00, "G",  "",    "",""  ,""  ,"mv_Par01" ,""                 ,"","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],cPerg)
       U_xPutSX1(cPerg, "02",   "Do Produto         ", "Do Produto         ", "Do Produto         ", "mv_ch3", "C", 15, 0, 0, "G", " ", "SB1", " ", " ", "mv_par02", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg)
       U_xPutSX1(cPerg, "03",   "AtÈ o Produto      ", "AtÈ o Produto      ", "AtÈ o Produto      ", "mv_ch4", "C", 15, 0, 0, "G", " ", "SB1", " ", " ", "mv_par03", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg)
       U_xPutSX1(cPerg, "04",   "Do Cliente         ", "Do Cliente         ", "Do Cliente         ", "mv_ch5", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par04", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg)
       U_xPutSX1(cPerg, "05",   "AtÈ o Cliente      ", "AtÈ o Cliente      ", "AtÈ o Cliente      ", "mv_ch6", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par05", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg)
       U_xPutSX1(cPerg, "06",   "Do Representante   ", "Do Representante   ", "Do Representante   ", "mv_ch7", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "mv_par06", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg)
       U_xPutSX1(cPerg, "07",   "AtÈ o Representante", "AtÈ o Representante", "AtÈ o Representante", "mv_ch8", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "mv_par07", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg)
       U_xPutSX1(cPerg, "08",   "Da Cidade          ", "Da Cidade          ", "Da Cidade          ", "mv_ch9", "C",  6, 0, 0, "G", " ", "SZ7", " ", " ", "mv_par08", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg)
       U_xPutSX1(cPerg, "09",   "AtÈ a Cidade       ", "AtÈ a Cidade       ", "AtÈ a Cidade       ", "mv_cha", "C",  6, 0, 0, "G", " ", "SZ7", " ", " ", "mv_par09", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg)
       U_xPutSX1(cPerg, "10",   "Tipo Consumidor    ", "Tipo Consumidor    ", "Tipo Consumidor    ", "mv_chb", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par10", "Consumidor Final", "Consumidor Final", "Consumidor Final"   , " "   , "IndustrializaÁ„o", "IndustrializaÁ„o"     , "IndustrializaÁ„o"     , "N„o Contribuinte", "N„o Contribuinte"     , "N„o Contribuinte"     , "Comercio/Revenda", "Comercio/Revenda"     , "Comercio/Revenda"     , "Todos"       ,  "Todos",  "Todos"     , Nil  , Nil     , Nil     , cPerg)
       U_xPutSX1(cPerg, "11",   "Imprime por        ", "Imprime por        ", "Imprime por        ", "mv_chc", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par11", "Produto"         , "Produto", "Produto"     , " "   , "Linha"           , "Linha"     , "Linha"     , "Cliente x Prod." , "Cliente x Prod."     , "Cliente x Prod."     , "Repres. x Prod." , "Repres. x Prod."     , "Repres. x Prod."     , "Par‚metro 15",  "Par‚metro 15",  "Par‚metro 15"     , Nil  , Nil     , Nil     , cPerg)
       U_xPutSX1(cPerg, "12",   "Do Periodo         ", "Do Periodo         ", "Do Periodo         ", "mv_chd", "D",  8, 0, 0, "G", " ",   " ", " ", " ", "mv_par12", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg)
       U_xPutSX1(cPerg, "13",   "AtÈ o Periodo      ", "AtÈ o Periodo      ", "AtÈ o Periodo      ", "mv_che", "D",  8, 0, 0, "G", " ",   " ", " ", " ", "mv_par13", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg)
       U_xPutSX1(cPerg, "14",   "Imprime por        ", "Imprime por        ", "Imprime por        ", "mv_chf", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par14", "Cliente x Linha" , "Cliente x Linha", "Cliente x Linha"     , " "   , "Repres. x Linha" , "Repres. x Linha"     , "Repres. x Linha "     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg)
       U_xPutSX1(cPerg, "15",   "Analitico/Sintetico", "Analitico/Sintetico", "Analitico/Sintetico", "mv_chg", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par15", "Analitico"       , " ", " "     , " "   , "Sintetico"       , " "     , " "     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg)
       U_xPutSX1(cPerg, "16",   "Nao Deduz Dev/Deduz Dev","Nao Deduz Dev/Deduz Dev","Nao Deduz Dev/Deduz Dev", "mv_chh", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par16", "Nao Deduz Dev"       , "Nao Deduz Dev", "Nao Deduz Dev"     , " "   , "Deduz Devoluc"       , "Deduz Devoluc"     , "Deduz Devoluc"     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg)
Return
