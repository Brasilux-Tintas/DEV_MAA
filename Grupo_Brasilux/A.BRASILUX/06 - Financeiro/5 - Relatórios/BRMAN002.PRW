#include "protheus.ch"
#include 'totvs.ch'
#include 'appexcel.ch'
/*/
+-----------------------------------------------------------------------
| Função | BRMAN002  | Autor | Jose Uliana   | Data | 13/04/2021       |
+-----------------------------------------------------------------------
| Descrição | EXPORTACAO PARA EXCEL GENERICO |
+-----------------------------------------------------------------------
| Uso |  ADVPL | Relatório de Multas de Transito  
+-----------------------------------------------------------------------
/*/

User Function BRMAN002()
Local aCabExcel :={}
Local aItensExcel :={}
Local _cPerg:="BRMAN002"
     u_zcfga01( 'BRMAN002' ) //LGS#2021202 - Gravação de log de utilização da rotina
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
AADD(aCabExcel, {"FILIAL"       ,"C", 20, 0})
AADD(aCabExcel, {"PREFIXO"      ,"C", 03, 0})
AADD(aCabExcel, {"TITULO"       ,"N", 09, 0})
AADD(aCabExcel, {"NUMINFR"      ,"N", 09, 0})
AADD(aCabExcel, {"CODINFR"      ,"N", 06, 0})
AADD(aCabExcel, {"ORGATUA"      ,"N", 04, 0})
AADD(aCabExcel, {"NOMORG"       ,"C", 30, 0})
AADD(aCabExcel, {"DTINFR"       ,"D", 08, 0})
AADD(aCabExcel, {"HORINFR"      ,"C", 05, 0})
AADD(aCabExcel, {"PLACA"        ,"C", 07, 0})
AADD(aCabExcel, {"TINFR"        ,"C", 50, 0})
AADD(aCabExcel, {"RODOVIA"      ,"C", 06, 0})
AADD(aCabExcel, {"LOCALINFR"    ,"C", 40, 0})
AADD(aCabExcel, {"CIDINFR"      ,"C", 20, 0})
AADD(aCabExcel, {"UFINFR"       ,"C", 02, 0})
AADD(aCabExcel, {"MOTORISTA"    ,"C", 35, 0})
AADD(aCabExcel, {"DTVENC"       ,"D", 08, 0})
AADD(aCabExcel, {"VALLIQ"       ,"N", 09, 2})
AADD(aCabExcel, {"OBS"          ,"C", 01, 0})

MsgRun("Favor Aguardar.....", "Selecionando os Registros",;
 {|| GProcItens(aCabExcel, @aItensExcel)})

MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
 {||DlgToExcel({{"GETDADOS",;
 "Rel. de Multas de Transito",;
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

cQuery := "SELECT CASE WHEN T10.TRX_FILIAL = '010101' THEN 'BRASILUX/MATRIZ' " + CHR(13) + CHR(10)       
cQuery := cQuery + "   WHEN T10.TRX_FILIAL = '010102' THEN 'BRASILUX/ESCRITÓRIO' " + CHR(13) + CHR(10)
cQuery := cQuery + "   WHEN T10.TRX_FILIAL = '010103' THEN 'BRASILUX/SÃO PAULO' " + CHR(13) + CHR(10)    
cQuery := cQuery + "	  WHEN T10.TRX_FILIAL = '010104' THEN 'BRASILUX/RESINA' " + CHR(13) + CHR(10)
cQuery := cQuery + "   WHEN T10.TRX_FILIAL = '010105' THEN 'BRASILUX/OBRA' " + CHR(13) + CHR(10)          
cQuery := cQuery + "	  WHEN T10.TRX_FILIAL = '010106' THEN 'BRASILUX/DEPOSITO' " + CHR(13) + CHR(10)
cQuery := cQuery + "   WHEN T10.TRX_FILIAL = '010107' THEN 'BRASILUX/DEPOSITO MATÃO' " + CHR(13) + CHR(10)
cQuery := cQuery + "	  WHEN T10.TRX_FILIAL = '060101'THEN 'DISSOLTEX' else " + CHR(13) + CHR(10)
cQuery := cQuery + "        T10.TRX_FILIAL END AS 'FILIAL', T10.TRX_PREFIX AS 'PREFIXO', T10.TRX_NUMSE2 AS 'TITULO', " + CHR(13) + CHR(10)
cQuery := cQuery + "		    T10.TRX_NUMAIT AS 'NUMINFR',     T10.TRX_CODINF AS 'CODINFR', T10.TRX_CODOR AS 'ORGATUA', " + CHR(13) + CHR(10)
cQuery := cQuery + "			 TRZ.TRZ_NOMOR  AS 'NOMORG',      T10.TRX_RODOVI AS 'RODOVIA', T10.TRX_LOCAL  AS 'LOCALINFR', " + CHR(13) + CHR(10)
cQuery := cQuery + "			 T10.TRX_CIDINF AS 'CIDINFR',     T10.TRX_UFINF  AS 'UFINFR',  T10.TRX_RHINFR AS 'HORINFR', " + CHR(13) + CHR(10)
cQuery := cQuery + "			 T10.TRX_NOME   AS 'MOTORISTA',   T10.TRX_PLACA  AS 'PLACA',   TSH.TSH_DESART AS 'TINFR', " + CHR(13) + CHR(10)
cQuery := cQuery + "			(T10.TRX_VALOR - T10.TRX_DESCON) AS 'VALLIQ', " + CHR(13) + CHR(10)
cQuery := cQuery + " SUBSTRING(T10.TRX_DTINFR,7,2) + '/' + SUBSTRING(T10.TRX_DTINFR,5,2) + '/' + SUBSTRING(T10.TRX_DTINFR,1,4) AS 'DTINFR', " + CHR(13) + CHR(10)
cQuery := cQuery + " SUBSTRING(T10.TRX_DTVECI,7,2) + '/' + SUBSTRING(T10.TRX_DTVECI,5,2) + '/' + SUBSTRING(T10.TRX_DTVECI,1,4) AS 'DTVENC', " + CHR(13) + CHR(10)
cQuery := cQuery + "         '' AS 'Obs' " + CHR(13) + CHR(10)
cQuery := cQuery + "FROM "+RETSQLNAME("TRX")+" T10 WITH(NOLOCK) " + CHR(13) + CHR(10)
cQuery := cQuery + "     LEFT OUTER JOIN "+RETSQLNAME("TSH")+" TSH WITH (NOLOCK) ON T10.TRX_CODINF = TSH.TSH_CODINF AND TSH.D_E_L_E_T_ <> '*' " + CHR(13) + CHR(10)
cQuery := cQuery + "     LEFT OUTER JOIN "+RETSQLNAME("TRZ")+" TRZ WITH (NOLOCK) ON T10.TRX_CODOR  = TRZ.TRZ_CODOR  AND TRZ.D_E_L_E_T_ <> '*' " + CHR(13) + CHR(10)
cQuery := cQuery + "		                                                        AND T10.TRX_FILIAL = TRZ.TRZ_FILIAL " + CHR(13) + CHR(10)
cQuery := cQuery + "WHERE T10.D_E_L_E_T_ <> '*' AND T10.TRX_FILIAL BETWEEN "+ MV_PAR01 +" AND "+ MV_PAR02 +" "  + CHR(13) + CHR(10)
cQuery := cQuery + "   AND T10.TRX_DTINFR BETWEEN '"+ DTOS(MV_PAR03) +"' AND '"+ DTOS(MV_PAR04) +"' " + CHR(13) + CHR(10)
cQuery := cQuery + "Order By T10.TRX_FILIAL, T10.TRX_DTINFR " + CHR(13) + CHR(10)

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



