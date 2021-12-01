#include "protheus.ch"
#include 'totvs.ch'
#include 'appexcel.ch'
/*/
+----------------------------------------------------------------------+
| Função | BRFATR93  | Autor | Jose Uliana   | Data | 08/02/2021       |
+----------------------------------------------------------------------+
| Descrição | EXPORTACAO PARA EXCEL GENERICO                           |
+----------------------------------------------------------------------+
| Uso |  ADVPL |     COD BARRAS X PRODUTOS POR LINHA                   |
+----------------------------------------------------------------------+
/*/

User Function BRFATR93()
Local aCabExcel :={}
Local aItensExcel :={}
Local _cPerg:="BRFATR93"
     u_zcfga01( 'BRFATR93' ) //LGS#2021201 - Gravação de log de utilização da rotina
/**********************************************************************************
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Envia controle para a funcao SETPRINT - checa se o uauário tem permissão   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     
   if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
   endif 
**********************************************************************************/

//********************************************************************************
//sobre colocar Substituição Tricutária segue abaixo o comentário da Renata Fiscal com a Janaini vendas
//Teams do dia 30/07/2021
//[15:11] Janaini - Vendas
//oi Sr José, boa tarde. Falei coma Renata e passou a seguinte informação.
//Que se for pra gente colocar ST SIM OU NÃO, não tem problema, podemos colocar. 
//Pode acontecer sim de sofrer alteração, mas essas alterações são portarias, 
//e quando acontece o cliente é comunicado.
//********************************************************************************

//( _cPerg ) Chamada da Criação das perguntas  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
If !Pergunte( _cPerg ) 
    Return() //Se cancelar as perguntas sai do programa
Endif

//AADD(aCabExcel, {"TITULO DO CAMPO","TIPO",NTAMANHO,NDECIMAIS})
AADD(aCabExcel, {"CODIGO"    ,"C", 15, 0})
AADD(aCabExcel, {"DESCRICAO" ,"C", 38, 0})
AADD(aCabExcel, {"LINHA"     ,"C", 02, 0})
AADD(aCabExcel, {"DESCLINHA" ,"C", 35, 0})
AADD(aCabExcel, {"CODBARRA"  ,"C", 15, 0})
AADD(aCabExcel, {"VALIDADE"  ,"N", 05, 0})
AADD(aCabExcel, {"NCM"       ,"N", 08, 0})
AADD(aCabExcel, {"IPI"       ,"N", 03, 0})
//AADD(aCabExcel, {"ICM"       ,"N", 02, 2})
//AADD(aCabExcel, {"IMPORTADO" ,"C", 01, 0})
//AADD(aCabExcel, {"SUBTRI"    ,"N", 05, 0})
AADD(aCabExcel, {"SUBSTTRIB" ,"C", 03, 0})
AADD(aCabExcel, {"PESOLIQ"   ,"N", 06, 4})
AADD(aCabExcel, {"PESOBRUTO" ,"N", 06, 4})
AADD(aCabExcel, {"OBS"       ,"C", 01, 0})

MsgRun("Favor Aguardar.....", "Selecionando os Registros",;
 {|| GProcItens(aCabExcel, @aItensExcel)})

MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
 {||DlgToExcel({{"GETDADOS",;
 "COD BARRAS X LINHAS DE PRODUTOS",;
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
cQuery += "       SB1.B1_POSIPI  AS NCM,     SB1.B1_IPI    AS IPI, " + CHR(13) + CHR(10)
// inibito abaixo para melhor estudo de viabilidade Janaini
//cQuery += "       SB1.B1_PICM    AS ICM, SB1.B1_IMPORT AS IMPORTADO, " + CHR(13) + CHR(10)
cQuery += "       SB1.B1_PESO    AS PESOLIQ, SB1.B1_PESBRU AS PESOBRUTO, '' AS OBS, " + CHR(13) + CHR(10)
CQuery += "       SZ1.Z1_VALIDAD AS VALIDADE, " + CHR(13) + CHR(10)
CQuery += "       SZ1.Z1_LINHA   AS LINHA, " + CHR(13) + CHR(10)
CQuery += "       SZ1.Z1_DESCR   AS DESCLINHA, " + CHR(13) + CHR(10)
// liberado pela renata conforme observação acima ///////JOSE///////
//CQuery += "       SB1.B1_PICMRET AS SUBTRI, " + CHR(13) + CHR(10)
cQuery += "  CASE WHEN SB1.B1_PICMRET = '35' THEN 'SIM' ELSE 'NÃO' END AS SUBSTTRIB, " + CHR(13) + CHR(10)
cQuery += "  CASE WHEN SB1.B1_MSBLQL = '1'  THEN 'EM DESUSO' ELSE " + CHR(13) + CHR(10)
cQuery += "  CASE WHEN (SB1.B1_VEND  = 'N') THEN 'NAO VENDIDO' " + CHR(13) + CHR(10)
cQuery += "  ELSE RTRIM(SB1.B1_CODBAR) +dbo.DigVer(SB1.B1_CODBAR) END END AS CODBARRA " + CHR(13) + CHR(10)
cQuery += "  FROM SB1010 SB1, SZ1010 SZ1 " + CHR(13) + CHR(10)
cQuery += " WHERE (SB1.D_E_L_E_T_ = '') AND (LEN(SB1.B1_CODBAR) = 12) AND (B1_TIPO = 'PA') "  + CHR(13) + CHR(10)
cQuery += "   AND (SB1.B1_FILIAL             BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"') " + CHR(13) + CHR(10) 
cQuery += "   AND (SUBSTRING(SB1.B1_COD,4,2) BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"') " + CHR(13) + CHR(10)
cQuery += "   AND (SZ1.D_E_L_E_T_ <> '*') AND (SUBSTRING(SB1.B1_COD,4,2) = SZ1.Z1_LINHA) "    + CHR(13) + CHR(10) 
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
