#include "protheus.ch"
#include 'totvs.ch'
#include 'appexcel.ch'
/*/
+-----------------------------------------------------------------------
| Função | BRFATR91  | Autor | Jose Uliana   | Data | 08/02/2021       |
+-----------------------------------------------------------------------
| Descrição | EXPORTACAO PARA EXCEL GENERICO |
+-----------------------------------------------------------------------
| Uso |  ADVPL | COD BARRAS X CLIENTE 
+-----------------------------------------------------------------------
/*/

User Function BRFATR91()
Local aCabExcel :={}
Local aItensExcel :={}
Local _cPerg:="BRFATR91"

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
AADD(aCabExcel, {"SUBSTRIB"  ,"C", 03, 0})
AADD(aCabExcel, {"PESOLIQ"   ,"N", 06, 4})
AADD(aCabExcel, {"PESOBRUTO" ,"N", 06, 4})
AADD(aCabExcel, {"RELVOL"    ,"N", 10, 0})
AADD(aCabExcel, {"OBS"       ,"C", 01, 0})

MsgRun("Favor Aguardar.....", "Selecionando os Registros",;
 {|| GProcItens(aCabExcel, @aItensExcel)})

MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
 {||DlgToExcel({{"GETDADOS",;
 "COD BARRAS X CLIENTE ",;
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

cQuery := "SELECT DISTINCT SD2.D2_COD AS CODIGO,RTRIM(ISNULL(SZ1.Z1_DESCR,''))+' - '+RTRIM(SB1.B1_DESC)+' '+ISNULL(SZ5.Z5_DESCR,'') AS DESCRICAO," + CHR(13) + CHR(10)
cQuery += "CASE WHEN SB1.B1_MSBLQL = '1' THEN 'EM DESUSO'    ELSE "  + CHR(13) + CHR(10)
cQuery += "CASE WHEN (SB1.B1_VEND = 'N') THEN 'NAO VENDIDO'  ELSE RTRIM(SB1.B1_CODBAR) +dbo.DigVer(SB1.B1_CODBAR) END END AS CODBARRA, "  + CHR(13) + CHR(10)
cQuery += "       SZ1.Z1_VALIDAD AS VALIDADE, SB1.B1_POSIPI AS NCM, SB1.B1_IPI AS IPI, "  + CHR(13) + CHR(10)
cQuery += " CASE WHEN SB1.B1_PICMRET > 0 THEN 'SIM' ELSE 'NAO' END AS SUBSTRIB, SB1.B1_PESO AS PESOLIQ, SB1.B1_PESBRU AS PESOBRUTO," + CHR(13) + CHR(10)
cQuery += " dbo.DetVol(SD2.D2_FILIAL,SD2.D2_COD) AS RELVOL, '' AS OBS " + CHR(13) + CHR(10)
cQuery += " FROM SD2010 SD2 " + CHR(13) + CHR(10)
cQuery += "      LEFT OUTER JOIN SB1010 SB1 ON (SB1.D_E_L_E_T_ <> '*') AND (SD2.D2_FILIAL = SB1.B1_FILIAL) AND (SD2.D2_COD = SB1.B1_COD) " + CHR(13) + CHR(10)
cQuery += "      LEFT OUTER JOIN SZ5010 SZ5 ON (SZ5.D_E_L_E_T_ <> '*') AND (SUBSTRING(SD2.D2_COD,11,2) = SZ5.Z5_EMB) " + CHR(13) + CHR(10)
cQuery += "      LEFT OUTER JOIN SZ1010 SZ1 ON (SZ1.D_E_L_E_T_ <> '*') AND (SUBSTRING(SD2.D2_COD,4,2) = SZ1.Z1_LINHA) " + CHR(13) + CHR(10)
cQuery += "WHERE (SD2.D_E_L_E_T_ <> '*') AND (LEN(SB1.B1_CODBAR) = 12) "  + CHR(13) + CHR(10)  // AND (SD2.D2_CLIENTE = '010181') " + CHR(13) + CHR(10)
cQuery += "  AND (SD2.D2_CLIENTE BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"') " + CHR(13) + CHR(10)
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



