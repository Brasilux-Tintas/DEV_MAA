#include 'protheus.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP003 ºAutor  ³ Fernando Roquete   º Data ³  28/03/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verificação da estrutura do produto para PI (Litros)       º±±
±±º 22/05/01 ³ Cleber O. Domingues                                        º±±
±±º          ³ Mudei o arredondamento da multiplicação, de 3, p/ 6 casas  º±±
±±º          ³ decimais.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRPCP003()
     Local _UmPAI, _TpPAI, _PesoEsp
     Local _nArea1 := Alias()
     Local _Recno1 := Recno()
     Local _Index1 := IndexOrd()  
     Local _Qtd    := 0.000000

     DbSelectArea("SB1")
     DbSetOrder(1)
     DbSeek(xFilial("SB1")+cCodAtual, .f.)
     If Found()
        _UmPAI   := Alltrim(SB1->B1_UM)
        _TpPAI   := Alltrim(SB1->B1_TIPO)
        _PesoEsp := SB1->B1_PESOESP
        If _TpPAI == "PA"
           If (Len(Alltrim(cCodAtual)) != 5) 
              _Qtd := Round(M->G1_PERC, 6)
           Else                              
           		IF (_UmPAI = "K") .OR. (_UmPAI = "KG")
              		_Qtd := Round(M->G1_PERC / 100, 6)         // Formulação Resina
             	else 
	              	_Qtd := Round(M->G1_PERC, 6)
	            endif 
           Endif
        Else
           DbSelectArea("SB1")
           DbSetOrder(1)
           DbSeek(xFilial("SB1")+M->G1_Comp, .f.)
           If Found()
              If (Alltrim(SB1->B1_UM) == _UmPAI)
                 _Qtd := Round(M->G1_PERC / 100, 6)
              Else
                 _Qtd := Round(_PesoEsp * (M->G1_PERC / 100), 6)
              Endif  
              // produto de custeio
              If U_IsProdCusto(M->G1_COMP)
                  _Qtd := Round(M->G1_PERC / 100, 6)
              Endif 
           Endif
        Endif  
     Endif
     DbSelectArea(_nArea1)
     DbSetOrder(_Index1)
     DbGoto(_Recno1)
Return(_Qtd)

