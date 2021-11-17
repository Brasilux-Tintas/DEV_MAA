#INCLUDE "TOTVS.CH"

User Function MALTCLI()
     Local nArea1    := Alias()
     Local lBloqueou := .f.
  Local  _cGrpEmp := ALLTRIM(FWGrpCompany())
     
If _cGrpEmp <> '11'
        /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
        ±±ºPrograma  ³ MA030TOK ºAutor  ³ Cleber O. Dominguesº Data ³  26/03/03   º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºDesc.     ³ Após confirmação da alteração/exclusão de cliente marca pa-º±±
        ±±º          ³ ra enviar dados para o representante.                      º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
        ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
        DO CASE
        CASE !EMPTY(ALLTRIM(SA1->A1_INATIVO)) .AND. (SA1->A1_MSBLQL != '1')
             If !lBloqueou
                dbselectarea("SA1")
                RecLock("SA1", .F.)
                lBloqueou := .T.
             Endif 
             SA1->A1_MSBLQL := '1'
        CASE !(SA1->A1_X_SIM3G == "S")
             If !lBloqueou
                dbselectarea("SA1")
                RecLock("SA1", .F.)
                lBloqueou := .T.
             Endif 
             SA1->A1_X_SIM3G := "S"
        ENDCASE
        IF (SA1->A1_X_SIM3G = "S")
           If !lBloqueou
              dbselectarea("SA1")
              RecLock("SA1", .F.)
              lBloqueou := .T.
           Endif 
           SA1->A1_X_EXPO  := " "
           SA1->A1_X_DTATU := DATE()
        ENDIF 
         if lBloqueou
       		dbselectarea("SA1")
       		msunlock()
         endif
          U_EnviaRec("SA1", SA1->A1_COD, .F., SA1->A1_VEND)
Endif	
// Manter cad. de cliente bloqueado enquanto departamento fiscal não marcar como Liberado (A1_XLIBFIS)
//Cleber (17/09/2021)->Chamado 023841, retirar validação
/*
IF SA1->(FieldPos("A1_XLIBFIS")) > 0
   IF !SA1->A1_XLIBFIS .AND. (SA1->A1_MSBLQL != '1')
      RecLock("SA1", .F.)
      SA1->A1_MSBLQL := '1'
      msunlock()
		cCC      := "fiscal@brasilux.com.br" //'contabilidade@brasilux.com.br'
		cPara := alltrim(UsrRetMail(__cUserId))
      cMens := "O Cliente do grupo "+_cGrpEmp+" ("+SA1->A1_COD+'-'+SA1->A1_LOJA+"-"+ALLTRIM(SA1->A1_NOME)+") necessita da LIBERAÇÃO do Setor Fiscal."
		U_EnvMail("MALTCLI - Liberação Setor Fiscal",cMens,cPara,cCC,"") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
   ENDIF 
ENDIF 
*/
DbSelectArea( nArea1 )
Return 
