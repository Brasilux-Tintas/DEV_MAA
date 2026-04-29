#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} AVALCOT
Manipula Pedido de Compras da tabela SC7 Usado aqui p/ verificar se TES está preenchido
@type function Processamento
@version  1.01
@author Cleber Orati /  alterado por marioantonaccio
@since 17/11/10  alterado em 20/01/2026
@return character, sem retorno
@see
25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
/*/
User Function AVALCOT()

   Local aAreaAnt := u_PegaArea({"SB1", "SA5"})
   Local cAlias   := Alias()
   Local cTes            as character
   Local lGrvTes  := .F. as logical
   Local nEvento  := PARAMIXB[1]

   If (nEvento == 4)

      cTes :=AllTrim(SC7->C7_TES)

      If EMPTY(AllTrim(cTes))

         lGrvTes:=.T.

         u_zcfga01( 'AVALCOT' ) //LGS#2021118 - Gravação de log de utilização da rotina

         IF (SA5->(FieldPos("A5_TES")) > 0) // Campo customizado que grava o TES na amarração Produto x Fornecedor
            SA5->(dbSetOrder(1))
            SA5->(dbSeek(xFilial("SA5")+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO))
            If SA5->(Found())
               cTes := AllTrim(SA5->A5_TES)
            End
         End

         If Empty(cTes)
            SB1->(dbSetOrder(1))
            SB1->(dbSeek(xFiLial("SB1")+SC7->C7_PRODUTO))
            If SB1->(Found())
               cTes := AllTrim(SB1->B1_TE)
            End
         End

      End

      If  lGrvTes
         dbSelectArea("SC7")
         lBloqueado := U_EstaBloqueado("SC7",recno())
         If  .NOT. lBloqueado
            RecLock("SC7",.F.)
         End
         SC7->C7_TES := cTes
         If .NOT. lBloqueado
            MsUnLock()
         End
      End

      If .NOT. Empty(cAlias)
         DbSelectArea(cAlias)
      End
   End

   U_VoltaArea(aAreaAnt)

Return (NIL)
