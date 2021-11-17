#include "rwmake.ch"        
#include "topconn.ch"   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT080 ºAutor  ³Cleber O. Domingues º Data ³  11/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de faturamento no periodo por representante      º±±
±±º          ³ considerando qtde. máxima de clientes por representante.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
 - Variaveis utilizadas para parametros:
   mv_par01 - Periodo de
   mv_par02 - Periodo até
   mv_par03 - Representante de
   mv_par04 - Representante ate
   mv_par05 - Quantidade Máxima de Clientes
   mv_par06 - Estado de
   mv_par07 - Estado até
*/
User Function BRFAT080()     
     Local cDesc1   := PADC("Rel. de Faturamento por Representante, destacando COMISSAO",74)
     Local cDesc2   := PADC(" ",74)
     Local cDesc3   := PADC(" ",74)
     Local titulo   := "FATURAMENTO POR REPRESENTANTE"
     Local nLin     := 0
     Local Cabec1   := ""
     Local Cabec2   := ""

     Private CbTxt    := ""
     Private limite   := 80
     Private tamanho  := "P"
     Private nomeprog := "BRFAT080"
     Private nTipo    := 18
     Private aReturn  := { "Especial", 1, "Administracao", 1, 2, 1, "", 1 }
     Private nLastKey := 0
     Private cPerg    := "BRFT80"
     Private CbCont   := 0
     Private m_pag    := 01
     Private wnrel    := "BRFAT080"
     Private cString  := "SF2"
     
     if !u_VldAcesso(funname())
         MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
         return 
     endif 

     //ValidPerg()
     Pergunte(cPerg, .F.)   

     Cabec1  := "PERIODO DE "+dtoc(mv_par01)+" ATE "+dtoc(mv_par02)
     Cabec2  := "CLIENTE                                C  VALOR FATURADO    CIDADE"


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
       Local cRepres  := ""
       Local cAux     := ""
       Local nCol     := 0
       Local nTotal   := 0
     /*  Cleber(17/04/20) 
       cQuery = "SELECT F2_CLIENTE AS CLIENTE,MAX(F2_RAZAO) AS RAZAO,MAX(A1_CODCID) AS CODCID,"+;
       "MAX(Z7_NOME) AS CIDADE,SUM(F2_VALMERC) AS VALOR,"+;
                "F2_VEND1 AS REPRES,MAX(SA3.A3_NOME) AS RAZAOREPR "+;
                "FROM "+RetSqlName("SF2")+" SF2 LEFT OUTER JOIN "
       cQuery = cQuery + " "+RetSqlName("SA3")+" SA3 ON (SF2.F2_VEND1 = SA3.A3_COD) AND (SA3.D_E_L_E_T_ <> '*') "+;
       "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 ON (SA1.D_E_L_E_T_ <> '*') AND (F2_CLIENTE = A1_COD) "+;
       "LEFT OUTER JOIN "+RetSqlName("SZ7")+" SZ7 ON (SZ7.D_E_L_E_T_ <> '*') AND (A1_CODCID = Z7_COD) "
       cQuery = cQuery + " WHERE (SF2.F2_FILIAL = '"+xFilial("SF2")+"')"
       cQuery = cQuery + " AND (SF2.F2_EMISSAO BETWEEN '"+DTOS(MV_PAR01) +"' AND '"+DTOS(MV_PAR02)+"')"
       cQuery = cQuery + " AND (SF2.D_E_L_E_T_ <> '*')"
       cQuery = cQuery + " AND (SF2.F2_VEND1 > '')"
       cQuery = cQuery + " AND (SF2.F2_EST BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' ) "
       cQuery = cQuery + " AND SF2.F2_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
       cQuery = cQuery + " GROUP BY SF2.F2_VEND1,SF2.F2_CLIENTE "
       cQuery = cQuery + "ORDER BY REPRES,CIDADE,CODCID,CLIENTE"
*/

       cQuery := "SELECT F2_CLIENTE AS CLIENTE,MAX(F2_RAZAO) AS RAZAO,MAX(A1_CODCID) AS CODCID,"+;
       "MAX(Z7_NOME) AS CIDADE,SUM(F2_VALMERC) AS VALOR,"+; 
		"F2_VEND1 AS REPRES,MAX(SA3.A3_NOME) AS RAZAOREPR,MAX(A1_CLAS) AS TIPOCLI "+; 
		"FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "+;
		"LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (SA3.D_E_L_E_T_ <> '*') AND (SF2.F2_VEND1 = SA3.A3_COD) "+; 
        "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (F2_CLIENTE = A1_COD) "+;
        "LEFT OUTER JOIN "+RetSqlName("SZ7")+" SZ7 WITH (NOLOCK) ON (SZ7.D_E_L_E_T_ <> '*') AND (A1_CODCID = Z7_COD) "+;
        "WHERE (SF2.D_E_L_E_T_ <> '*') AND (SF2.F2_FILIAL = '"+xFilial("SF2")+"') "+;
        "AND (SF2.F2_EMISSAO BETWEEN '"+DTOS(MV_PAR01) +"' AND '"+DTOS(MV_PAR02)+"')" +;
        "AND (SF2.F2_VEND1 > '') " +;
        "AND (SF2.F2_EST BETWEEN '"+mv_par06+"' AND '"+mv_par07+"') "+;
        "AND (SF2.F2_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"')" +;
        "GROUP BY SF2.F2_VEND1,SF2.F2_CLIENTE "+; 
        "ORDER BY REPRES,VALOR DESC"

       TCQuery cQuery NEW ALIAS "TMP" 

       DbSelectArea("TMP")
       Dbgotop()

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Inicializa  regua de impressao                            ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       //0         1         2         3         4         5         6         7         8
       //012345678901234567890123456789012345678901234567890123456789012345678901234567890
       //CLIENTE                                C  VALOR FATURADO    CIDADE
       //999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  X  9,999,999,999.99  XXXXXXXXXXXXXXXXXXXX
       nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
       nLin += 1
       SetRegua(Reccount())
       While !Eof()
             If nlin >= 58
                nLin += 1
                @ nLin,000 PSAY Replicate("_",80)
                nLin := Cabec(titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                nLin += 1
             Endif
             nLin += 1
             @ nLin,000 PSAY Replicate("-",80)
             cRepres  = TMP->REPRES
             cAux    := cRepres+"-"+TMP->RAZAOREPR
             nLin += 1
             nCol = 40 - int(Len(cAux)/2)
             @ nLin,nCol PSAY cAux
             nLin += 1
             @ nLin,000 PSAY Replicate("-",80)

             nTotal   := 0 
             nContCli := 0
             DbSelectArea("TMP")
             While !Eof() .AND. (TMP->REPRES == cRepres)
                   If ((mv_par05 > 0) .and. (nContCli < mv_par05)) .or. (mv_par05 <= 0)
                      nContCli++
                      If nlin >= 59
                         nLin += 1
                         @nLin,000 PSAY Replicate("_",80)
                         nLin := Cabec(titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                         nLin += 1
                      Endif        
                      nLin += 1
                      @ nLin,000 PSAY TMP->CLIENTE+"-"+SubStr(TMP->RAZAO, 1, 30)
                      @ nLin,039 PSAY SubStr(Posicione("SA1", 1, xFilial("SA1")+TMP->CLIENTE, "A1_CLAS"), 1, 1)
                      @ nLin,042 PSAY TMP->VALOR picture "@E 9,999,999,999.99"
                      @ nLin,060 PSAY SubStr(TMP->CIDADE, 1, 15)
                      nTotal += TMP->VALOR
                   Endif
                   DbSelectArea("TMP")
                   DbSkip()
                   IncRegua()
             Enddo
             If nlin >= 58
                nLin += 1
                @nLin,000 PSAY Replicate("_",80)
                nLin := Cabec(titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                nLin += 1
             Endif
             nLin += 1
             @nLin,000 PSAY Replicate("-",80)
             nLin += 1
             @nLin,000 PSAY "QTDE CLIENTES : "
             @nLin,016 PSAY nContCli picture "@E 9999"  
             @nLin,032 PSAY "TOTAIS: "
             @nLin,042 PSAY nTotal picture "@E 9,999,999,999.99"
             nLin += 1
             @nLin,000 PSAY Replicate("-",80)
       Enddo
       If nlin >= 60
          nLin := Cabec(titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
          nLin += 1
       Endif         
       nLin += 1
       @nLin,000 PSAY Replicate("_",80)

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³                      FIM DA IMPRESSAO                        ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       DbSelectArea("TMP")
       DbCloseArea()
       
 
       
       Set Device To Screen
       If aReturn[5] == 1
          Set Printer TO
          DbCommitAll()
          OurSpool(wnrel)
       Endif

Return

/****************************************************************************************************************/
/*** VALIDPERG - Grava perguntas no SX1.                                                                      ***/
/****************************************************************************************************************/
/*
Static Function ValidPerg()
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs, {cPerg, "01", "Data Emissao De  ?", "", "", "mv_ch1", "D", 08, 0, 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",    "", ""})
       AADD(aRegs, {cPerg, "02", "Data Emissao Ate ?", "", "", "mv_ch2", "D", 08, 0, 0, "G", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",    "", ""})
       AADD(aRegs, {cPerg, "03", "Repres. De       ?", "", "", "mv_ch3", "C", 06, 0, 0, "G", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA3", ""})
       AADD(aRegs, {cPerg, "04", "Repres Ate       ?", "", "", "mv_ch4", "C", 06, 0, 0, "G", "", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA3", ""})
       AADD(aRegs, {cPerg, "05", "Qte Cli p. Repr  ?", "", "", "mv_ch5", "N", 06, 0, 0, "G", "", "mv_par05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",    "", ""})
       AADD(aRegs, {cPerg, "06", "Do estado        ?", "", "", "mv_ch6", "C", 02, 0, 0, "G", "", "mv_par06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",  "12", ""})
       AADD(aRegs, {cPerg, "07", "Ate o estado     ?", "", "", "mv_ch7", "C", 02, 0, 0, "G", "", "mv_par07", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",  "12", ""})

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
Return
*/