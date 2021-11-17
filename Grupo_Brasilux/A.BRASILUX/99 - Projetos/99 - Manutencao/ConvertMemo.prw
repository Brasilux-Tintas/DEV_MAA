#INCLUDE "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO2     º Autor ³ AP6 IDE            º Data ³  11/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ConvertMemo(cCampo)
     Processa({ || ProcRot()})
Return

Static Function ProcRot()
     DbSelectArea("SC5")
     DbSetOrder(1)
     DbSeek('01138000')
     ProcRegua(RecCount())
     DbGoTop()
     While !Eof()
           IncProc("Pedido: "+SC5->C5_NUM)
           If Empty(SC5->C5_NOTA)
              cDesMemo := SC5->C5_OBS
              If !Empty(Alltrim(u_Tiraacento(cDesMemo))) .AND. Empty(SC5->C5_OBSSC5)
                 //Inclusão
                 MSMM(SC5->C5_OBSSC5, , , cDesMemo, 1, , , "SC5", "C5_OBSSC5")
              Endif
              cDesMemo := SC5->C5_OBSNF
              If !Empty(Alltrim(u_Tiraacento(cDesMemo))) .AND. Empty(SC5->C5_OBSNFS)
                 //Inclusão
                 MSMM(SC5->C5_OBSNFS, , , cDesMemo, 1, , , "SC5", "C5_OBSNFS")
              Endif
           Endif
           DbSelectArea("SC5")
           DbSkip()
     Enddo
Return