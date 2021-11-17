#include "rwmake.ch"        
#include "topconn.ch"   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATR75 ºAutor  ³Cleber Orati        º Data ³  19/11/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de faturamento no periodo por Cliente x Produto      º±±
±±º          ³ e Repr                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
 - Parâmetros utilizados:
   mv_par01 - Periodo de
   mv_par02 - Periodo até
   mv_par03 - Cliente de
   mv_par04 - Cliente ate
   mv_par05 - Representante de
   mv_par06 - Representante ate
*/
User Function BRFATR75()     
     Local cDesc1   := PADC("Rel. de Faturamento por Vendedor ",220)
     Local cDesc2   := PADC(" x Clientes x Produto",220)
     Local cDesc3   := PADC(" ",220)
     Local titulo   := "FATURAMENTO POR REPR X CLIENTE x PRODUTO"
     Local nLin     := 0
     Local Cabec1   := ""
     Local Cabec2   := ""

     Private CbTxt    := ""
     Private limite   := 220
     Private tamanho  := "G"
     Private nomeprog := "BRFATR75"
     Private nTipo    := 15
     Private aReturn  := { "Especial", 1, "Administracao", 1, 2, 1, "", 1 }
     Private nLastKey := 0
     Private cPerg    := "BRFATR75"
     Private CbCont   := 0
     Private m_pag    := 01
     Private wnrel    := "BRFATR75"
     Private cString  := "SF2"
     
      if !u_VldAcesso(funname())
      		MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      		return 
      endif 

     //ValidPerg()  //LGS#20200207 - Adequação de release 12.1.25 e posteriores
     Pergunte(cPerg, .F.)   

     Cabec1  := "PERIODO DE "+dtoc(mv_par01)+" ATE "+dtoc(mv_par02)
//																																																			                            204
     		  //     0         1         2           3        4        5         6         7         8        9          10       11        12        13         14         15                16          17      18        19        20  9,999,999,999                                                                                                                                                                                                                                                                                                                
     		  // 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
     Cabec2  := "VENDEDOR                                        CLIENTE                                          PRODUTO          LINHA                           NOME PRODUTO                                                          QTDE "


     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     wnrel := SetPrint(cString, wnrel, cPerg, Titulo, cDesc1, cDesc2, cDesc3, .T., , .T., Tamanho)

     If nLastKey == 27
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica Posicao do Formulario na Impressora                 ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicio do Processamento do Relatorio                         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     
     RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/****************************************************************************************************************/
/*** RunReport - Busca de dados e impressão do relatório.                                                     ***/
/****************************************************************************************************************/
Static Function RunReport(Cabec1, Cabec2, Titulo, nLin)
       Local cQuery   := ""
       //Local cCliente := ""
       Local cRepres  := ""
       Local cAux     := ""
       Local nSoma    := 0
       //Local nCol     := 0
       //Local nTotal   := 0
       //Local _aCampos := {}
       Local nQtdeV
       
       cQuery := "SELECT F2_VEND1 AS CODREPR,MAX(A3_NOME) AS NOMEVEND,D2_CLIENTE AS CODCLI,"+;
       "MAX(F2_RAZAO) AS RAZAO,D2_COD AS CODPRO,MAX(B1_DESC) AS DESCRPROD,"+;
       "LINHA = MAX(CASE WHEN LEN(D2_COD) = 12 THEN Z1_DESCR ELSE '' END), "+;
       "SUM(D2_QUANT) AS QTDE "+;
       "FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+; 
       "LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = D2_FILIAL) AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) "+; 
       "LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (SA3.D_E_L_E_T_ <> '*') AND (A3_FILIAL = '"+xFilial("SA3")+"') AND (F2_VEND1 = A3_COD) "+; 
       "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = D2_FILIAL) AND (B1_COD = D2_COD) "+; 
       "LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D2_TES = F4_CODIGO) "+;
       "LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) ON (SZ1.D_E_L_E_T_ <> '*') AND (Z1_FILIAL = '"+xFilial("SZ1")+"') AND (SUBSTRING(D2_COD,4,2) = Z1_LINHA) "+; 
       "WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND ((F4_DUPLIC <> 'N') OR (D2_TES = '519')) "+; 
       "AND (D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "
       IF !EMPTY(MV_PAR04) .AND. (MV_PAR04 >= MV_PAR03)
       		cQuery += "AND (D2_CLIENTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
       ENDIF
       IF !EMPTY(MV_PAR06) .AND. (MV_PAR04 >= MV_PAR05)
       		cQuery += "AND (F2_VEND1 BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') "
       ENDIF
		if !empty(MV_PAR07)   
			cAux := U_RegiaoGeo(MV_PAR07)
			if !empty(cAux)
				cQuery += "AND (D2_EST IN ("+cAux+")) "
			endif 
		endif		                           

       cQuery += "GROUP BY F2_VEND1,D2_CLIENTE,D2_COD "+; 
       "ORDER BY CODREPR,CODCLI,LINHA,CODPRO"
       TCQuery cQuery NEW ALIAS "TCQ" 

DbSelectArea("TCQ")
SetRegua(Reccount())
nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
nLin += 1
nSoma := 0
DbSelectArea("TCQ")
DbGoTop()
While !Eof() .and. !lAbortPrint
	cRepres := TCQ->CODREPR
	nQtdeV := 0
	do while !eof() .and. (TCQ->CODREPR == cRepres)
		nLin++
		If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
			nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
			nLin += 1
		Endif                
		If lAbortPrint
			@ nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
	
		@ nLin, 000 PSAY SUBSTR(TCQ->CODREPR+"-"+TCQ->NOMEVEND,1,47)
		@ nLin, 048 PSAY SUBSTR(TCQ->CODCLI+"-"+TCQ->RAZAO,1,47)
		@ nLin, 097 PSAY TCQ->CODPRO
		@ nLin, 114 PSAY SUBSTR(TCQ->LINHA,1,29) 
		@ nLin, 146 PSAY TCQ->DESCRPROD 
		@ nLin, 207 PSAY TCQ->QTDE PICTURE "@E 9,999,999,999"
	
		nSoma += TCQ->QTDE
		nQtdeV += TCQ->QTDE
		dbselectarea("TCQ")
		dbskip()
	enddo
	nLin++
	If (nLin+2) > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
		nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
		nLin += 1
	Endif                
	@ nLin, 000 PSAY Replicate("-", 220)
	nLin++
	@ nLin, 173 PSAY 'QTDE VENDEDOR '+cRepres+' ===>>>>>>'
	@ nLin, 207 PSAY nQtdeV PICTURE "@E 9,999,999,999"
	nLin++
	@ nLin, 000 PSAY Replicate("-", 220)
ENDDO 	

nLin++
If (nLin+2) > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
	nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
	nLin += 1
Endif                

@ nLin, 000 PSAY Replicate("=", 220)
nLin++
@ nLin, 173 PSAY 'QTDE TOTAL ===>>>>>>'
@ nLin, 207 PSAY nSoma PICTURE "@E 9,999,999,999"
nLin++
@ nLin, 000 PSAY Replicate("=", 220)
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

/****************************************************************************************************************/
/*** VALIDPERG - Grava perguntas no SX1.                                                                      ***/
/****************************************************************************************************************/
//LGS#20200207 - Adequação de release 12.1.25 e posteriores
/*Static Function ValidPerg()
Local _sAlias
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs, {cPerg, "01", "Data Faturam De  ?", "", "", "mv_ch1", "D", 08, 0, 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",    "", ""})
       AADD(aRegs, {cPerg, "02", "Data Faturam Ate ?", "", "", "mv_ch2", "D", 08, 0, 0, "G", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",    "", ""})
       AADD(aRegs, {cPerg, "03", "Cliente De       ?", "", "", "mv_ch3", "C", 06, 0, 0, "G", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA1", ""})
       AADD(aRegs, {cPerg, "04", "Cliente Ate      ?", "", "", "mv_ch4", "C", 06, 0, 0, "G", "", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA1", ""})
       AADD(aRegs, {cPerg, "05", "Repres. De       ?", "", "", "mv_ch5", "C", 06, 0, 0, "G", "", "mv_par05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA3", ""})
       AADD(aRegs, {cPerg, "06", "Repres Ate       ?", "", "", "mv_ch6", "C", 06, 0, 0, "G", "", "mv_par06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA3", ""})
       AADD(aRegs, {cPerg, "07", "Região Geográf   ?", "", "", "mv_ch7", "C", 02, 0, 0, "G", "", "mv_par07", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "ZE", ""})

       For i := 1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i,2])
              RecLock("SX1",.T.)
                 For j:=1 to FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j,aRegs[i,j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return */
