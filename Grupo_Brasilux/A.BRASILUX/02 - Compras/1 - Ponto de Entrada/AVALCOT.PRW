#include "protheus.ch"
#include "topconn.ch"
  /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
  ±±ºPrograma  ³ AVALCOT º Autor ³ Cleber Orati        º Data ³  17/11/10   º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºDescri‡„o ³ Manipula Pedido de Compras da tabela SC7                   º±±
  ±±º          ³ Usado aqui p/ verificar se TES está preenchido             º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±³ Uso      ³ PONTO DE ENTRADA                                           ³±±
  ±±³          ³                                                            ³±±
  ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
  //25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function AVALCOT()
     Local nEvento := PARAMIXB[1]
     Local cAlias := Alias()
     Local aAreaAnt := u_PegaArea({"SB1","SA5"})
     Local cTes := ""

dbselectarea("SA5")
IF (SA5->(FieldPos("A5_TES")) > 0) // Campo customizado que grava o TES na amarração Produto x Fornecedor
   If (nEvento == 4) .and. EMPTY(alltrim(SC7->C7_TES))
           cTes := alltrim(SC7->C7_TES)
           //Cleber (17/11/2010) -> Preencher TES caso esteja em Branco!
           IF empty(cTes) .and. !empty(SC7->C7_FORNECE)
              dbselectarea("SA5")
              dbsetorder(1) //A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO                                                                                                                         
              dbseek(xFilial("SA5")+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO)
              if found() 
                 cTes := ALLTRIM(SA5->A5_TES)
              endif
           ENDIF
           IF empty(cTes)
              dbselectarea("SB1") 
              DbSetOrder(1)
              dbseek(xFilial("SB1")+SC7->C7_PRODUTO)
              if found() .and. !empty(SB1->B1_TE)                         
                 cTes := alltrim(SB1->B1_TE)
              endif
           endif
           if !empty(cTes) //.and. (alltrim(SC7->C7_TES) <> cTes)
              dbselectarea("SC7")
              lBloqueado := U_EstaBloqueado("SC7",recno())
              if !lBloqueado
                 reclock("SC7",.f.)
              endif
              SC7->C7_TES := cTes
              if !lBloqueado
                 MsUnLock()
              endif
           endif

           U_VoltaArea(aAreaAnt)
   EndIf
ENDIF //Fim IF (SA5->(FieldPos("A5_TES")) > 0)
IF !EMPTY(cAlias)
   DbSelectArea(cAlias)
ENDIF        
Return
