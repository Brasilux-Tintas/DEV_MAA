#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT046 ºAutor  ³                    º Data ³  28/12/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Formação de Preços                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA.                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFAT046()
     Local nRegB1, nOrdemB1,I
     Local nArea   := Alias()
     Local nRecno  := Recno()
     Local nIndex  := IndexOrd()
     Local nCustoR := 0       // Custo em R$
     Local nPerInt := 0       // Percentuais Internos
     DbSelectArea("SB1")
     nRegB1   := Recno()
     nOrdemB1 := IndexOrd()

     For I := 1 TO Len(aArray)
         If Alltrim(aArray[I][3]) == "CUSTO TOTAL DO PRODUTO"
            nCustoR := nCustoR + aArray[I][6]
         ElseIf Alltrim(aArray[I][3]) == "CUSTO DA MAO DE OBRA R$"
                nCustoR := nCustoR + aArray[I][6]
         ElseIf (Alltrim(aArray[I][3]) == "PIS(%)") .or. (Alltrim(aArray[I][3]) == "IVA(%)")
                nPerInt := nPerInt + aArray[I][6]
         ElseIf Alltrim(aArray[I][3]) == "COFINS(%)"
                nPerInt := nPerInt + aArray[I][6]
         ElseIf Alltrim(aArray[I][3]) == "CONTR. SOCIAL(%)"
                nPerInt := nPerInt + aArray[I][6]
         ElseIf Alltrim(aArray[I][3]) == "IR SOBRE LUCRO(%)"
                nPerInt := nPerInt + aArray[I][6]
         ElseIf Alltrim(aArray[I][3]) == "C.P.M.F.(%)"
                nPerInt := nPerInt + aArray[I][6]
         ElseIf Alltrim(aArray[I][3]) == "DESP. ADMINISTRATIVAS(%)"
                nPerInt := nPerInt + aArray[I][6]
         ElseIf Alltrim(aArray[I][3]) == "GASTOS GERAIS(%)"
                nPerInt := nPerInt + aArray[I][6]
         ElseIf Alltrim(aArray[I][3]) == "DESP. COMERCIAIS(%)"
                nPerInt := nPerInt + aArray[I][6]
         EndIf
     Next

     DbSelectArea("SB1")
     DbSetorder(1)
     DbSeek(xFilial("SB1")+aArray[1][4], .F.)
     If Found()
        RecLock("SB1", .F.)
           SB1->B1_CUSTOR := nCustoR
           SB1->B1_PERINT := nPerInt
           ///////////////////////////////////////////////////////////////////////////////////////////////////
           // Cleber, 28/03/05  		                                                                    //
           // Atualizar Campo B1_UPRC para PI's, que é denominado Preço para a Tabela de Preços, no caso    //
           // informativo. Para MP's esse campo é usado como base para o cálculo de custo de matéria prima. //
           ///////////////////////////////////////////////////////////////////////////////////////////////////
           If SB1->B1_TIPO = 'PI'
              SB1->B1_UPRC := nCustoR
           Endif
        MsUnlock()    
        If (Len(Alltrim(aArray[1][4])) == 12)
           DbSelectArea("SZ1")
           DbSetOrder(1)
           DbSeek(xFilial("SZ1")+SubStr(aArray[1][4], 4, 2))
           If Found()
              DbSelectArea("SB1")
              RecLock("SB1", .F.)
                 SB1->B1_LUCRO   := SZ1->Z1_LUCRO
                 SB1->B1_LCRMIN  := SZ1->Z1_LUCRMIN
                 SB1->B1_LUCRO2  := SZ1->Z1_LUCRO2
                 SB1->B1_LUCROM2 := SZ1->Z1_LUCROM2
              MsUnLock()
              // Enviar alteracoes p/ representante
              If ((cNumEmp = "01010101") .or. (cNumEmp = "01060101")) .and. (SB1->B1_TIPO == 'PA')
                 U_EnviaRec("SB1", SB1->B1_COD, .f.)
              Endif
           Endif
        Endif 
     Endif
     DbSelectArea("SB1")
     DbSetOrder(nOrdemB1)
     DbGoto(nRegB1)

     DbSelectArea(nArea)
     DbSetOrder(nIndex)
     DbGoto(nRecno)
Return(0)