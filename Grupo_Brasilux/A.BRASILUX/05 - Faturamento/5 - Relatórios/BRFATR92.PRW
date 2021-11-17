#include "protheus.ch"
#include 'totvs.ch'
#include 'appexcel.ch'
/*/
+-----------------------------------------------------------------------
| Função | BRFATR92  | Autor | Jose Uliana   | Data | 08/02/2021       |
+-----------------------------------------------------------------------
| Descrição | EXPORTACAO PARA EXCEL GENERICO |
+-----------------------------------------------------------------------
| Uso |  ADVPL |     COD BARRAS X PRODUTOS
+-----------------------------------------------------------------------
/*/

User Function BRFATR92()
Local aCabExcel :={}
Local aItensExcel :={}
Local _cPerg:="BRFATR92"

//( _cPerg ) Chamada da Criação das perguntas  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
If !Pergunte( _cPerg ) 
    Return() //Se cancelar as perguntas sai do programa
Endif

// AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO", NTAMANHO, NDECIMAIS})
AADD(aCabExcel, {"CODIGO"    ,"C", 15, 0})
AADD(aCabExcel, {"DESCRICAO" ,"C", 38, 0})
AADD(aCabExcel, {"CODBARRA"  ,"C", 15, 0})
AADD(aCabExcel, {"VALIDADE"  ,"N", 05, 0})
AADD(aCabExcel, {"NCM"       ,"N", 08, 0})
AADD(aCabExcel, {"IPI"       ,"N", 03, 0})
AADD(aCabExcel, {"PESOLIQ"   ,"N", 06, 4})
AADD(aCabExcel, {"PESOBRUTO" ,"N", 06, 4})
AADD(aCabExcel, {"OBS"       ,"C", 01, 0})

MsgRun("Favor Aguardar.....", "Selecionando os Registros",;
 {|| GProcItens(aCabExcel, @aItensExcel)})

MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
 {||DlgToExcel({{"GETDADOS",;
 "COD BARRAS X PRODUTOS",;
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

// Começo da Consulta SQL =  Query

cQuery := "SELECT DISTINCT SB1.B1_COD AS CODIGO, SB1.B1_DESC AS DESCRICAO, " + CHR(13) + CHR(10)
cQuery += "       SB1.B1_POSIPI AS NCM,   SB1.B1_IPI    AS IPI, " + CHR(13) + CHR(10)
cQuery += "       SB1.B1_PESO AS PESOLIQ, SB1.B1_PESBRU AS PESOBRUTO, '' AS OBS, " + CHR(13) + CHR(10)
CQuery += "       SZ1.Z1_VALIDAD AS VALIDADE, " + CHR(13) + CHR(10)
cQuery += "  CASE WHEN SB1.B1_MSBLQL = '1' THEN 'EM DESUSO' ELSE " + CHR(13) + CHR(10)
cQuery += "  CASE WHEN (SB1.B1_VEND = 'N') THEN 'NAO VENDIDO' "  + CHR(13) + CHR(10)
cQuery += "  ELSE RTRIM(SB1.B1_CODBAR) +dbo.DigVer(SB1.B1_CODBAR) END END AS CODBARRA "  + CHR(13) + CHR(10)
cQuery += "  FROM SB1010 SB1, SZ1010 SZ1 " + CHR(13) + CHR(10)
cQuery += " WHERE (SB1.D_E_L_E_T_ = '') AND (LEN(SB1.B1_CODBAR) = 12)  AND (B1_TIPO = 'PA') " + CHR(13) + CHR(10)
cQuery += "   AND (SB1.B1_COD like ('"+ SUBSTR(MV_PAR03,1,10) +"%') or (SB1.B1_COD like ('"+ SUBSTR(MV_PAR04,1,10) +"%'))) " + CHR(13) + CHR(10)
cQuery += "   AND (SB1.B1_FILIAL BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"') " + CHR(13) + CHR(10) 
cQuery += "   AND (SZ1.D_E_L_E_T_ <> '*') AND (SUBSTRING(SB1.B1_COD,4,2) = SZ1.Z1_LINHA) " + CHR(13) + CHR(10) 
cQuery += "ORDER BY CODIGO " + CHR(13) + CHR(10)

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
