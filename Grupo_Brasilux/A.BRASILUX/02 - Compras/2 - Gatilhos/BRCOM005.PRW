#include 'topconn.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRCOM005 ºAutor  ³ Luís G. de Souza   º Data ³  20/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho para atualizar pelo ultimo preço na inclusão de um º±±
±±º          ³ contrato de compras para autorização de entrega.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRCOM005()
     Local nPrcUni := 0
     Local cQry    := ""
     Local aArea      := GetArea()  
     u_zcfga01( 'BRCOM005' ) //LGS#2021118 - Gravação de log de utilização da rotina
     cQry += "SELECT TOP 1 SD1.D1_VUNIT AS PRCUNIT "
     cQry += "FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "
     cQry += "WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"' "
     cQry += "  AND SD1.D_E_L_E_T_ = '' "
     cQry += "  AND SD1.D1_FORNECE = '"+CA125FORN+"' "
     cQry += "  AND SD1.D1_LOJA    = '"+CA125LOJ+"' "
     cQry += "  AND SD1.D1_COD     = '"+aCols[n][aScan(aHeader, {|x| Alltrim(x[2]) = "C3_PRODUTO"})]+"' " 
     cQry += "ORDER BY SD1.R_E_C_N_O_ DESC "
     TCQuery cQry ALIAS "TCQ" NEW
     DbSelectArea("TCQ")
     DbGoTop()
     nPrcUni := TCQ->PRCUNIT
     DbSelectArea("TCQ")
     DbCloseArea()
     
     RestArea(aArea)
Return(nPrcUni)
