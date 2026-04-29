#include "protheus.ch"
#include 'tbiconn.ch'
#include "rwmake.ch"
#include "topconn.ch"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MS520DEL  ³ Autor ³ Nelieder M Corneta   ³ Data ³ 28/07/22 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ PE após a exlusão da NF de Saida                   		  ³±±
±±³			 ³ Projeto para desabilitar as triggers do banco de dados     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function MS520DEL() 

/* trigger SF2010 */ 
   If alltrim(FWGrpCompany()) == '01'
        If GETMV("ZP_PAR0061")
            
            /* duvida se registro são utilizados */
            cSql := "UPDATE SZ9010 SET D_E_L_E_T_ = '*' WHERE (Z9_FILIAL = '"+xFilial("SF2")+"' ) AND (Z9_NF = '"+AllTrim(SF2->F2_DOC)+"') AND (Z9_SERIENF = '"+AllTrim(SF2->F2_SERIE)+"')"
            TCSqlExec(cSql)
            
            cSql := "UPDATE SZ0010 SET D_E_L_E_T_ = '*' WHERE (Z0_FILIAL = '"+xFilial("SF2")+"' ) AND (Z0_NF = '"+AllTrim(SF2->F2_DOC)+"') AND (Z0_SERIENF = '"+AllTrim(SF2->F2_SERIE)+"')"
            TCSqlExec(cSql)

            If !Empty(SF2->F2_PEDIDO)
               cSql := " UPDATE ZZ6010 SET ZZ6_PROCES = 'N',ZZ6_APAGAR = 'F',ZZ6_DIA = CONVERT(VARCHAR,getdate(),112),ULTATUALIZ = GETDATE() WHERE (D_E_L_E_T_ <> '*') AND "
		         cSql += " (ZZ6_TABELA = 'SC5') AND (ZZ6_EMPR = '"+xFilial("SF2")+"') AND (ZZ6_CHAVE = '"+SF2->F2_PEDIDO+"') " 
            Endif   

            If Select("TMP_ZZ0") <> 0
	            TMP_ZZ0->(dbCloseArea())
            endif 	 


            BeginSQL Alias "TMP_ZZ0"
                SELECT TOP 1 R_E_C_N_O_ FROM ZZ0040 WHERE D_E_L_E_T_ <> '*' AND ZZ0_FILIAL = %xFilial:SF2% AND 
		        ZZ0_PEDIDO = %exp:SF2->F2_PEDIDO%
            EndSQL    
            RecnoZZ0 := TMP_ZZ0->R_E_C_N_O_
            /* Registros localizados */
            Count To nRecCount
            
            If nRecCount > 0
               cSql := "UPDATE ZZ0040 SET ZZ0_NFISCA = '' WHERE (D_E_L_E_T_ <> '*') AND (ZZ0_FILIAL = '"+xFilial("SF2")+"') AND (ZZ0_PEDIDO = '"+SF2->F2_PEDIDO+"')"
               TCSqlExec(cSql)
            Endif



            
            


        Endif

   Endif




Return
