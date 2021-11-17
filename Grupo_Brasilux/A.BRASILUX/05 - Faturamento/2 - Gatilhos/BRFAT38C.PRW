#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT38C ºAutor  ³ Marcos C.D. Vieira º Data ³  17/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consistencias para otimizacao do pedido.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Alterado: 15/05/02 - Cleber Orati Domingues
          Considerada situação onde pedido usa fornecedor.
*/
User Function BRFAT38C()
     Local nArea  := Alias()
     Local nRecno := Recno()
     Local nIndex := IndexOrd()
     Local _cAlias, cUf, cTipoCons

     M->C6_IEST := Space(20)
     If (M->C5_TIPO $ "D_B")
        _cAlias := "SA2"
     Else
        _cAlias := "SA1"
     Endif
     cUf       := ""
     cTipoCons := ""
     DbSelectArea(_cAlias)
     DbSetOrder(1)
     DbSeek(xFilial(_cAlias)+M->C5_CLIENTE, .F.)
     If Found()
        If (M->C5_TIPO $ "D_B")
           cUf       := SA2->A2_EST
           cTipoCons := SA2->A2_CLAS
        Else
           cUf       := SA1->A1_EST
           cTipoCons := SA1->A1_CLAS
        Endif
     Endif

     DbSelectArea("SZ8")
     DbSetOrder(1)
     DbSeek(xFilial("SZ8")+cUf+cTipoCons, .F.)
     If Found()
        M->C6_IEST := SZ8->Z8_IEST
     EndIf      

     DbSelectArea(nArea)
     DbSetOrder(nIndex)
     DbGoto(nRecno)

Return(M->C6_IEST)