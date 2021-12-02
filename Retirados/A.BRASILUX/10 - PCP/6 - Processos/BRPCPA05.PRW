//#include 'brasilux.ch'
#include "protheus.ch"
#include 'topconn.ch'
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCPA05 ºAutor  ³ Luís G. de Souza   º Data ³  13/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Integração do Microsiga com planilhas do Excel.            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRPCPA05()
     Local   cQry1  := ""                     //                         1234567890
     Local   cTpPl  := SubStr(ParamIxb, 1, 1) //Tipo da Planilha -       1123121234
     Local   cCdFn  := SubStr(ParamIxb, 2, 3) //Código do Funcionário
     Local   cDiaP  := SubStr(ParamIxb, 5, 2) //Mês
     Local   cAnoP  := SubStr(ParamIxb, 7, 4) //Ano
     Local nY
     Private aItens := {}
     
     If cTpPl $ '1'
        cQry1 := ""
        cQry1 += "SELECT DISTINCT ENV.ENVASADOR AS ENVASA, SRA.RA_NOME AS NOME "
        cQry1 += "FROM LOTE_X_ENVASADORES ENV WITH (NOLOCK) "
        cQry1 += "LEFT OUTER JOIN "+RetSqlName("SRA")+" SRA ON '"+xFilial("SRA")+"' = SRA.RA_FILIAL AND ENV.ENVASADOR = SRA.RA_MAT AND SRA.D_E_L_E_T_ = '' "
        cQry1 += "WHERE LEN(ENV.ENVASADOR) = 3 "
        cQry1 += "ORDER BY 2 "
        TCQuery cQry1 ALIAS "TCQ" NEW
        DbSelectArea("TCQ")
        DbGoTop()
        While !Eof()
              aAdd(aItens, {TCQ->ENVASA, TCQ->NOME})
              DbSelectArea("TCQ")
              DbSkip()
        Enddo
        DbSelectArea("TCQ")
        DbCloseArea()
        For nY := 1 To (100 - Len(aItens))
            aAdd(aItens, { , })
        Next
     ElseIf cTpPl $ '2'
            For nY := 1 To 31
                aAdd(aItens, {StrZero(nY, 2), 0, 0})
            Next
            cQry1 := ""
            cQry1 += "SELECT SUBSTRING(ENV.FIM, 1, 2) AS DIA, COUNT(ENV.LOTE) AS LOTE, SUM(ENV.VOLUME) AS VOLUME "
            cQry1 += "FROM LOTE_X_ENVASADORES ENV WITH (NOLOCK) "
            cQry1 += "WHERE SUBSTRING(ENV.FIM, 4, 2) = '"+cDiaP+"' "
            cQry1 += "  AND SUBSTRING(ENV.FIM, 7, 4) = '"+cAnoP+"' "
            cQry1 += "  AND ENV.ENVASADOR = '"+cCdFn+"' "
            cQry1 += "GROUP BY SUBSTRING(ENV.FIM, 1, 2) "
            cQry1 += "ORDER BY SUBSTRING(ENV.FIM, 1, 2) "
            TCQuery cQry1 ALIAS "TCQ" NEW
            DbSelectArea("TCQ")
            DbGoTop()
            While !Eof()
                  aItens[aScan(aItens, {|x| x[1] == TCQ->DIA})][2] += TCQ->LOTE
                  aItens[aScan(aItens, {|x| x[1] == TCQ->DIA})][3] += TCQ->VOLUME
                  DbSelectArea("TCQ")
                  DbSkip()
            Enddo
            DbSelectArea("TCQ")
            DbCloseArea()
            For nY := 1 To (32 - Len(aItens))
                aAdd(aItens, { , , })
            Next
     ElseIf cTpPl $ '3'
     EndIf
Return(aItens)     