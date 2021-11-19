#include 'rwmake.ch'

User Function BREST006(cCod)
     Local cCodBar := IIf(cCod == Nil,"",cCod)
     u_zcfga01( 'BREST006' ) //LGS#2021119 - Gravação de log de utilização da rotina
     if len(alltrim(cCod) < 12)
     	return("")
     endif 
     If !Empty(cCodBar)
        cRet := EST0061(cCodBar)
        Return(cRet)
     Else
        Processa({|| EST0061(cCodBar)}, "CODIGO DE BARRAS")
     Endif
Return


Static Function EST0061(cCodBar)
       Local i
       private F, nInd, cStr, cRet

       F := Array(10)

       F[01] := "#11111"
       F[02] := "$12122"
       F[03] := "%12212"
       F[04] := "&12221"
       F[05] := " 21122"
       F[06] := "(22112"
       F[07] := ")22211"
       F[08] := "*21212"
       F[09] := "+21221"
       F[10] := ",22121"

       If Empty(cCodBar)
          DbSelectArea("SB1")
          DbSetOrder(1)
          DbGoTop()
          ProcRegua(9000)
          While !Eof()
                IncProc("Processando produto: "+SB1->B1_COD)
                If SB1->B1_TIPO <> "PA"
                   DbSkip()
                   Loop
                Endif
                If !Empty(SB1->B1_CBCONV )
                   DbSkip()
                   Loop
                Endif
                If len(SubStr(Alltrim(SB1->B1_CODBAR),1,12)) != 12
                   DbSkip()
                   Loop
                Endif
                cCod := Substr(Alltrim(SB1->B1_CODBAR),1,12)
                cDig := EANDIGITO(Substr(Alltrim(SB1->B1_CODBAR),1,12))
           
                cCod := cCod+cDig

                nInd := val(substr(cCod,1,1))+1
                cStr := F[nInd]
                cRet := substr(cStr,1,1)+"!"+substr(cCod,2,1)
                For i := 2 to 6
                    cDig := substr(cCod,i+1,1)
                    Do Case
                       Case substr(cStr,i,1) == "1"
                            cRet := cRet+cDig
                       Case substr(cStr,i,1) == "2"
                            cRet := cRet + chr(asc("A")+val(cDig))
                    EndCase
                Next
                cRet := cRet + "-"
	
                For i = 1 to 6
                    cDig := substr(cCod,i+7,1)
                    cRet := cRet + chr(asc("a")+val(cDig))
                Next
                cRet := cRet + "!"
           
                DbSelectArea("SB1")
                RecLock("SB1",.f.)
                   SB1->B1_CBCONV := cRet
                MsUnLock()
                DbSkip()
          Enddo
       Else
          cCod := Substr(Alltrim(cCodBar),1,12)
          cDig := EANDIGITO(Substr(Alltrim(cCodBar),1,12))
           
          cCod := cCod+cDig

          nInd := val(substr(cCod,1,1))+1
          cStr := F[nInd]
          cRet := substr(cStr,1,1)+"!"+substr(cCod,2,1)
          For i := 2 to 6
              cDig := substr(cCod,i+1,1)
              Do Case
                 Case substr(cStr,i,1) == "1"
                      cRet := cRet+cDig
                 Case substr(cStr,i,1) == "2"
                      cRet := cRet + chr(asc("A")+val(cDig))
              EndCase
          Next
          cRet := cRet + "-"

          For i = 1 to 6
              cDig := substr(cCod,i+7,1)
              cRet := cRet + chr(asc("a")+val(cDig))
          Next
          cRet := cRet + "!"
          Return(cRet)
       Endif
Return
