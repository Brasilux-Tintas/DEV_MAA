#include "TOTVS.ch"
#include "topconn.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FC010CON ºAutor  ³ Cleber O. Dominguesº Data ³  26/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra se cliente tem titulos em lucros e perdas.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//30/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function FC010CON()
     Local cEmprs := ""
     Local nArea  := Alias() 
     Local cQuery := ""
Local  _cGrpEmp := ALLTRIM(FWGrpCompany())
     u_zcfga01( 'FC010CON' ) //LGS#2021202 - Gravação de log de utilização da rotina
     If _cGrpEmp == '01' //Empresas que são do grupo 01-BRASILUX.
        cQuery += "SELECT TOP 1 '01' AS EMPRESA "
        cQuery += "FROM "+RetSqlName("SE1")+" SE1 WITH (NOLOCK) "
        cQuery += "WHERE (SE1.E1_CLIENTE = '"+SA1->A1_COD+"') "
        cQuery += "  AND (SE1.E1_NATUREZ = '801004') "
        cQuery += "  AND (SE1.D_E_L_E_T_ <> '*') "
        cQuery += "UNION ALL "
        cQuery += "SELECT TOP 1 '02' AS EMPRESA "
        cQuery += "FROM SE1020 SE1 WITH (NOLOCK) "
        cQuery += "WHERE (SE1.E1_CLIENTE = '"+SA1->A1_COD+"') "
        cQuery += "  AND (SE1.E1_NATUREZ = '801004') "
        cQuery += "  AND (SE1.D_E_L_E_T_ <> '*') "
        cQuery += "UNION ALL "
        cQuery += "SELECT TOP 1 '03' AS EMPRESA "
        cQuery += "FROM SE1030 SE1 WITH (NOLOCK) "
        cQuery += "WHERE (SE1.E1_CLIENTE = '"+SA1->A1_COD+"') "
        cQuery += "  AND (SE1.E1_NATUREZ = '801004') "
        cQuery += "  AND (SE1.D_E_L_E_T_ <> '*') "
        cQuery += "ORDER BY EMPRESA "
        TCQUERY cQuery ALIAS "TMPLP" NEW

        DbSelectArea("TMPLP")
        DbGoTop()
        cEmprs := ""
        While !Eof()
              cEmprs += TMPLP->EMPRESA+","
              DbSkip()
        Enddo

        If !Empty(cEmprs)
           cEmprs := SubStr(cEmprs, 1, Len(cEmprs) - 1)
           MsgBox("Cliente POSSUI título(s) em LUCROS E PERDAS na(s) empresa(s) "+cEmprs+"!", "*** AVISO ***", "INFO")
        Else
           MsgBox("Cliente NÃO POSSUI título(s) em LUCROS E PERDAS!", "*** AVISO ***", "INFO")
        Endif
        DbSelectArea("TMPLP")
        DbCloseArea("TMPLP")
        DbSelectArea(nArea)
     Endif
Return(.t.)
