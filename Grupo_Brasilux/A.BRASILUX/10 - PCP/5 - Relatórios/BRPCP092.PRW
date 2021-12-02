#include "protheus.ch"
#include 'totvs.ch'
#include 'appexcel.ch'
/*/
+-----------------------------------------------------------------------
| Função | BRFATR91  | Autor | Jose Uliana   | Data | 08/02/2021       |
+-----------------------------------------------------------------------
| Descrição | EXPORTACAO PARA EXCEL GENERICO |
+-----------------------------------------------------------------------
| Uso |  ADVPL | Relatório  Apontamentos de produção - Saldo PI Litros   
+-----------------------------------------------------------------------
/*/

User Function BRPCP092()
Local aCabExcel :={}
Local aItensExcel :={}
Local _cPerg:="BRPCP092"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT - checa se o uauário tem permissão ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     
   if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
     u_zcfga01( 'BRPCP092' ) //LGS#2021201 - Gravação de log de utilização da rotina
//( _cPerg ) Chamada da Criação das perguntas  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
If !Pergunte( _cPerg ) 
        Return() //Se cancelar as perguntas sai do programa
 Endif

// AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO", NTAMANHO, NDECIMAIS})
AADD(aCabExcel, {"PRODUTO"      ,"C", 15, 0})
AADD(aCabExcel, {"DESCRICAO"    ,"C", 38, 0})
AADD(aCabExcel, {"APROPRI"      ,"C", 08, 0})
AADD(aCabExcel, {"LOCALI"       ,"C", 05, 0})
AADD(aCabExcel, {"QTDATUAL"     ,"N", 06, 4})
AADD(aCabExcel, {"EMPENHO"      ,"N", 06, 4})
AADD(aCabExcel, {"DISPONIVEL"   ,"N", 06, 4})
AADD(aCabExcel, {"ENTRPREVISTA" ,"N", 06, 4})
AADD(aCabExcel, {"MEDIA"        ,"N", 06, 0})
AADD(aCabExcel, {"DIAS"         ,"N", 06, 0})
AADD(aCabExcel, {"OBS"          ,"C", 01, 0})

MsgRun("Favor Aguardar.....", "Selecionando os Registros",;
 {|| GProcItens(aCabExcel, @aItensExcel)})

MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
 {||DlgToExcel({{"GETDADOS",;
 "Apont.Prod.Saldo PI Litros",;
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

cQuery := "SELECT SB2.B2_COD AS 'PRODUTO', SB1.B1_DESC AS 'DESCRICAO', '' AS OBS, " + CHR(13) + CHR(10)
cQuery := cQuery + "CASE WHEN SB1.B1_APROPRI ='I' THEN 'INDIRETO' ELSE 'DIRETO' END AS 'APROPRI', SB2.B2_LOCAL AS 'LOCALI', " + CHR(13) + CHR(10)
cQuery := cQuery + "          SB2.B2_QATU AS 'QTDATUAL', SB2.B2_QEMP AS 'EMPENHO', " + CHR(13) + CHR(10)
cQuery := cQuery + "   ROUND((SB2.B2_QATU - SB2.B2_QEMP - SB2.B2_RESERVA - SB2.B2_QEMPN),2) AS 'DISPONIVEL', " + CHR(13) + CHR(10)
cQuery := cQuery + "          SB2.B2_SALPEDI AS 'ENTRPREVISTA', ISNULL(ZZ2.ZZ2_MEDIA,0) AS 'MEDIA', " + CHR(13) + CHR(10)
cQuery := cQuery + "CASE WHEN ISNULL(ZZ2.ZZ2_MEDIA,0) <= 0 THEN 0 ELSE " + CHR(13) + CHR(10)
cQuery := cQuery + "   ROUND((SB2.B2_QATU-SB2.B2_QEMP-SB2.B2_RESERVA-SB2.B2_QEMPN+SB2.B2_SALPEDI) / (ISNULL(ZZ2.ZZ2_MEDIA,0) / 22),0) END AS 'DIAS' " + CHR(13) + CHR(10)
cQuery := cQuery + "FROM SB2010 SB2 WITH(NOLOCK) " + CHR(13) + CHR(10)
cQuery := cQuery + "  LEFT OUTER JOIN SB1010 SB1 WITH(NOLOCK) ON SB2.B2_FILIAL  = SB1.B1_FILIAL AND SB2.B2_COD  = SB1.B1_COD AND SB1.D_E_L_E_T_ ='' " + CHR(13) + CHR(10)
cQuery := cQuery + "  LEFT OUTER JOIN ZZ2010 ZZ2 WITH(NOLOCK) ON ZZ2.ZZ2_FILIAL = SB1.B1_FILIAL AND ZZ2.ZZ2_COD = SB1.B1_COD AND ZZ2.D_E_L_E_T_ ='' " + CHR(13) + CHR(10)
cQuery := cQuery + "WHERE SB2.D_E_L_E_T_ ='' AND SB2.B2_FILIAL ='010101' " + CHR(13) + CHR(10)          // AND  SB2.B2_LOCAL IN ('02','20','99','R1','R2') AND SB1.B1_TIPO ='PI' " Inibido para colocar os paramentros
cQuery := cQuery + "  AND SB2.B2_LOCAL BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' AND SB1.B1_TIPO ='PI' " + CHR(13) + CHR(10)
cQuery := cQuery + "  AND (SB2.B2_LOCAL <> 'R0' AND SB2.B2_LOCAL <> '40' AND SB2.B2_LOCAL <> '98') " + CHR(13) + CHR(10)
cQuery := cQuery + "  AND LEN(SB2.B2_COD)< 12 AND (SB2.B2_QATU <> 0 OR SB2.B2_SALPEDI <> 0 OR SB2.B2_QEMP <> 0) " + CHR(13) + CHR(10)
cQuery := cQuery + "ORDER BY SB1.B1_APROPRI, SB2.B2_COD, SB2.B2_LOCAL " + CHR(13) + CHR(10)

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



