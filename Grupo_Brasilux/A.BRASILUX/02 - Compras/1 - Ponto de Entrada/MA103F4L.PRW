#include "protheus.ch"
  /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
  ±±ºPrograma  ³ MA103F4L º Autor ³ Cleber Orati       º Data ³  26/01/21   º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºDescri‡„o ³ Alteração de Taxa de Moeda do Pedido durante a digitação   º±±
  ±±º          ³ da NF. Deve-se pegar a PTAX da emissão da nota e não  da   º±±
  ±±º          ³ emissão do pedido. Solução encontrada foi alterar a taxa   º±±
  ±±º          ³ do pedido no momento da seleção na entrada da nota         º±±
  ±±º          ³ Chamado nro 020704                                         º±±
    ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±³ Uso      ³ PONTO DE ENTRADA                                           ³±±
  ±±³          ³ COM - MATA103 - ENTRADA DE NOTAS FISCAIS                   ³±±
  ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MA103F4L()
local aF4For := PARAMIXB[1]
LOCAL aRecSC7 := PARAMIXB[2]
Local nI,nTx
For nI := Len(aF4For) To 1 Step -1
    SC7->(dbGoto(aRecSC7[nI]))   
    if (SC7->C7_MOEDA > 1) 
        dbselectarea("SC7")
        nTx := xMoeda(1,SC7->C7_MOEDA,1,dDEmissao,TamSx3("C7_TXMOEDA")[2])
        RecLock("SC7",.f.)
        SC7->C7_TXMOEDA := nTx
        msunlock()
    endif 
Next nI
Return NIL
