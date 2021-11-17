#include "protheus.ch"
#include 'totvs.ch'
#include 'appexcel.ch'
/*/
+-----------------------------------------------------------------------
| Função | BRGPE091  | Autor | Jose Uliana   | Data | 25/05/2021       |
+-----------------------------------------------------------------------
| Descrição | EXPORTACAO PARA EXCEL GENERICO |
+-----------------------------------------------------------------------
| Uso |  ADVPL | Relatório Funcionários, cargos, salarios, Custo       |  
+-----------------------------------------------------------------------
/*/

User Function BRGPE091()
Local aCabExcel :={}
Local aItensExcel :={}
Local _cPerg:="BRGPE091"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT - checa se o uauário tem permissão ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*    
   if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
*/

//( _cPerg ) Chamada da Criação das perguntas  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
If !Pergunte( _cPerg ) 
        Return() //Se cancelar as perguntas sai do programa
 Endif

// AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO", NTAMANHO, NDECIMAIS})
AADD(aCabExcel, {"FILIAL"       ,"C", 06, 0})
AADD(aCabExcel, {"NOME"         ,"C", 30, 0})
AADD(aCabExcel, {"MATRICULA"    ,"C", 06, 0})
AADD(aCabExcel, {"ADMISSAO"     ,"D", 08, 0})
AADD(aCabExcel, {"CCUSTO"       ,"C", 06, 0})
AADD(aCabExcel, {"DESCUSTO"     ,"C", 30, 0})
AADD(aCabExcel, {"FUNCAO"       ,"C", 06, 0})
AADD(aCabExcel, {"DESFUNC"      ,"C", 30, 0})
AADD(aCabExcel, {"CARGO"        ,"C", 06, 0})
AADD(aCabExcel, {"DESCARGO"     ,"C", 30, 0})
AADD(aCabExcel, {"SALARIO"      ,"N", 09, 2})
AADD(aCabExcel, {"VALORATS"     ,"N", 09, 2})
AADD(aCabExcel, {"VALORPERIC"   ,"N", 09, 2})
AADD(aCabExcel, {"VALORADCF"    ,"N", 09, 2})
AADD(aCabExcel, {"OBS"          ,"C", 01, 0})

MsgRun("Favor Aguardar.....", "Selecionando os Registros",;
 {|| GProcItens(aCabExcel, @aItensExcel)})

MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
 {||DlgToExcel({{"GETDADOS",;
 "Relatório Funcionários,Cargos,Salários,C.Custo",;
 aCabExcel,aItensExcel}})})

Return
/*/
+-----------------------------------------------------------------------
| Função | GProcItens | Autor | Jose Uliana | Data |   08/02/2021      |
+-----------------------------------------------------------------------
| Uso |  ADVPL |
+-----------------------------------------------------------------------
/*/
Static Function GProcItens(aHeader, aCols)
Local _cAlias := GetNextAlias() // Declarei meu Alias

Local aItem
Local nX

// BeginSql Alias _cAlias  // Começo da Consulta SQL =  Query
cQuery := "Select SRA.RA_FILIAL AS 'FILIAL',  SRA.RA_NOME AS 'NOME', SRA.RA_MAT AS 'MATRICULA', " + CHR(13) + CHR(10)
cQuery := cQuery + "SUBSTRING(SRA.RA_ADMISSA,7,2) + '/' + SUBSTRING(SRA.RA_ADMISSA,5,2) + '/' + SUBSTRING(SRA.RA_ADMISSA,1,4) AS 'ADMISSAO', " + CHR(13) + CHR(10)
cQuery := cQuery + "SRA.RA_CC AS 'CCUSTO', CTT.CTT_DESC01 AS 'DESCUSTO', SRA.RA_CODFUNC AS 'FUNCAO', SRJ.RJ_DESC AS 'DESFUNC', SRA.RA_CARGO AS 'CARGO', SQ3.Q3_DESCSUM AS 'DESCARGO', " + CHR(13) + CHR(10)
cQuery := cQuery + "SRA.RA_SALARIO AS 'SALARIO' , " + CHR(13) + CHR(10)
cQuery := cQuery + "VALORATS   = ISNULL((SELECT TOP 1 RD_VALOR FROM "+RETSQLNAME("SRD")+" SDR WHERE (SDR.D_E_L_E_T_ <> '*') AND (SDR.RD_FILIAL = SRA.RA_FILIAL) AND (SDR.RD_MAT = SRA.RA_MAT) AND (SDR.RD_PD = '005') ORDER BY SDR.RD_DATARQ DESC),0.0), " + CHR(13) + CHR(10)
cQuery := cQuery + "VALORPERIC = ISNULL((SELECT TOP 1 RD_VALOR FROM "+RETSQLNAME("SRD")+" SDR WHERE (SDR.D_E_L_E_T_ <> '*') AND (SDR.RD_FILIAL = SRA.RA_FILIAL) AND (SDR.RD_MAT = SRA.RA_MAT) AND (SDR.RD_PD = '004') ORDER BY SDR.RD_DATARQ DESC),0.0), " + CHR(13) + CHR(10)
cQuery := cQuery + "VALORADCF  = ISNULL((SELECT TOP 1 RD_VALOR FROM "+RETSQLNAME("SRD")+" SDR WHERE (SDR.D_E_L_E_T_ <> '*') AND (SDR.RD_FILIAL = SRA.RA_FILIAL) AND (SDR.RD_MAT = SRA.RA_MAT) AND (SDR.RD_PD = '698') ORDER BY SDR.RD_DATARQ DESC),0.0), " + CHR(13) + CHR(10)
//---------------  trocado pelo de cima Jose 22/06/2021
//cQuery := cQuery + "    VALORATS   = ISNULL((SELECT TOP 1 R3_VALOR FROM SR3010 WHERE (D_E_L_E_T_ <> '*') AND (R3_FILIAL = SRA.RA_FILIAL) AND (R3_MAT = SRA.RA_MAT) AND (R3_PD = '110') ORDER BY R3_DATA DESC),0.0), " + CHR(13) + CHR(10)
//cQuery := cQuery + "    VALORPERIC = ISNULL((SELECT TOP 1 R3_VALOR FROM SR3010 WHERE (D_E_L_E_T_ <> '*') AND (R3_FILIAL = SRA.RA_FILIAL) AND (R3_MAT = SRA.RA_MAT) AND (R3_PD = '206') ORDER BY R3_DATA DESC),0.0), " + CHR(13) + CHR(10)
//cQuery := cQuery + "    VALORADCF  = ISNULL((SELECT TOP 1 R3_VALOR FROM SR3010 WHERE (D_E_L_E_T_ <> '*') AND (R3_FILIAL = SRA.RA_FILIAL) AND (R3_MAT = SRA.RA_MAT) AND (R3_PD = '076') ORDER BY R3_DATA DESC),0.0), " + CHR(13) + CHR(10)
//----------------------------------------------------------------------------
cQuery := cQuery + "    '' AS 'Obs' " + CHR(13) + CHR(10)
cQuery := cQuery + "  FROM "+RETSQLNAME("SRA")+" SRA WITH(NOLOCK) " + CHR(13) + CHR(10)
cQuery := cQuery + "  LEFT OUTER JOIN "+RETSQLNAME("CTT")+" CTT ON (CTT.D_E_L_E_T_ = '') AND (CTT.CTT_FILIAL = " + IIF( FWCODEMP() == '11', "''", 'SUBSTRING(SRA.RA_FILIAL,1,2)' ) + ") AND (CTT.CTT_CUSTO = SRA.RA_CC) " + CHR(13) + CHR(10)
cQuery := cQuery + "  LEFT OUTER JOIN "+RETSQLNAME("SRJ")+" SRJ ON (SRJ.D_E_L_E_T_ = '') AND (SRJ.RJ_FILIAL  = SUBSTRING(RA_FILIAL,1,2)) AND (SRJ.RJ_FUNCAO = SRA.RA_CODFUNC) " + CHR(13) + CHR(10) 
cQuery := cQuery + "  LEFT OUTER JOIN "+RETSQLNAME("SQ3")+" SQ3 ON (SQ3.D_E_L_E_T_ = '') AND (SQ3.Q3_CARGO = SRA.RA_CARGO) " + CHR(13) + CHR(10)  
cQuery := cQuery + " WHERE (SRA.D_E_L_E_T_ = '') AND (SRA.RA_SITFOLH <> 'D') AND SRA.RA_FILIAL BETWEEN "+ MV_PAR01 +" AND "+ MV_PAR02 +" " + CHR(13) + CHR(10)
cQuery := cQuery + "ORDER BY SRA.RA_FILIAL, SRA.RA_MAT " + CHR(13) + CHR(10)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),_cAlias,.T.,.T.)

DbSelectArea(_cAlias)
DbGotop()

While (_cAlias)->(!EOF())
 aItem := Array(Len(aHeader))

 For nX := 1 to Len(aHeader)
 IF aHeader[nX][2] == "C"
 aItem[nX] := CHR(160)+(_cAlias)->&(aHeader[nX][1])
 ELSE
 aItem[nX] := (_cAlias)->&(aHeader[nX][1])
 ENDIF
 Next nX

 AADD(aCols,aItem)
 aItem := {}
 (_cAlias)->(dbSkip())
End
Return 



