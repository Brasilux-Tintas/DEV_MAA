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

User Function BRGPE090()
Local aCabExcel :={}
Local aItensExcel :={}
Local _cPerg:="BRGPE090"
     u_zcfga01( 'BRGPE090' ) //LGS#2021202 - Gravação de log de utilização da rotina
/**********************************************************************************
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT - checa se o uauário tem permissão ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     
   if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
************************************************************************************/

//( _cPerg ) Chamada da Criação das perguntas  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
If !Pergunte( _cPerg ) 
        Return() //Se cancelar as perguntas sai do programa
 Endif

AADD(aCabExcel, {"FILIAL"      ,"C", 06, 0})
AADD(aCabExcel, {"MATRICULA"   ,"N", 06, 0})
AADD(aCabExcel, {"NOME"        ,"C", 35, 0})
AADD(aCabExcel, {"ADMISSAO"    ,"D", 10, 0})
AADD(aCabExcel, {"CARGO"       ,"N", 06, 0})
AADD(aCabExcel, {"DESCRICAO"   ,"C", 35, 0})
AADD(aCabExcel, {"SETOR"       ,"N", 06, 0})
AADD(aCabExcel, {"DESCSETOR"   ,"C", 35, 0})
AADD(aCabExcel, {"FORMACAO"    ,"N", 03, 0})
AADD(aCabExcel, {"ESCOLAR"     ,"C", 35, 0})
AADD(aCabExcel, {"OBS"         ,"C", 01, 0})

MsgRun("Favor Aguardar.....", "Selecionando os Registros",;
 {|| GProcItens(aCabExcel, @aItensExcel)})

MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
 {||DlgToExcel({{"GETDADOS",;
 "FORMAÇÃO ESCOLAR",;
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

cQuery := "Select SRA.RA_FILIAL  AS 'FILIAL',SRA.RA_MAT AS 'MATRICULA',SRA.RA_NOME AS 'NOME', " + CHR(13) + CHR(10)
cQuery += "SUBSTRING(SRA.RA_ADMISSA,7,2) + '/' + SUBSTRING(SRA.RA_ADMISSA,5,2) + '/' + SUBSTRING(SRA.RA_ADMISSA,1,4) AS 'ADMISSAO'," + CHR(13) + CHR(10)
cQuery += "       SRA.RA_CARGO AS 'CARGO',SQ3.Q3_DESCSUM AS 'DESCRICAO', " + CHR(13) + CHR(10)
cQuery += "       SRA.RA_CC AS 'SETOR',CTT.CTT_DESC01 AS 'DESCSETOR',SRA.RA_GRINRAI AS 'FORMACAO', " + CHR(13) + CHR(10)
cQuery += "       SX5.X5_DESCRI AS 'ESCOLAR', '' AS 'OBS' " + CHR(13) + CHR(10)
cQuery += "  FROM "+RETSQLNAME("SRA")+" SRA " + CHR(13) + CHR(10)
cQuery += "  LEFT OUTER JOIN "+RETSQLNAME("SQ3")+" SQ3 ON (SQ3.D_E_L_E_T_ = '')   AND (SQ3.Q3_CARGO  = SRA.RA_CARGO) " + CHR(13) + CHR(10)   
cQuery += "  LEFT OUTER JOIN "+RETSQLNAME("SX5")+" SX5 ON (SX5.X5_TABELA  = '26') AND (SX5.X5_CHAVE  = SRA.RA_GRINRAI) " + CHR(13) + CHR(10)
cQuery += "  LEFT OUTER JOIN "+RETSQLNAME("CTT")+" CTT ON (CTT.D_E_L_E_T_ = '')   AND (CTT.CTT_CUSTO = SRA.RA_CC) " + CHR(13) + CHR(10)
cQuery += " WHERE SRA.D_E_L_E_T_ = '' AND SRA.RA_DEMISSA = '' AND SRA.RA_FILIAL BETWEEN "+ MV_PAR01 +" AND "+ MV_PAR02 +" " + CHR(13) + CHR(10)
cQuery += "   AND SRA.RA_CATFUNC BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"' " + CHR(13) + CHR(10)
cQuery += "GROUP BY SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME,SRA.RA_ADMISSA,SRA.RA_CARGO,SQ3.Q3_DESCSUM,SRA.RA_CC, " + CHR(13) + CHR(10)
cQuery += "         CTT.CTT_DESC01, SRA.RA_GRINRAI,SX5.X5_DESCRI " + CHR(13) + CHR(10)
cQuery += "ORDER BY SRA.RA_FILIAL,SRA.RA_MAT ASC " + CHR(13) + CHR(10)

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



