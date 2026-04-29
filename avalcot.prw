User Function AVALCOT()
   Local nEvento := PARAMIXB[1]
   Local aArea := FWGetArea()
   Local aAprov    := {}         // { {Usuario, Limite}, ... }
   Local nI

   If nEvento == 4
      /*
    dbSelectArea('SC7')
    RecLock('SC7',.F.)
    SC7->C7_CUSTOM := TableUsr->FieldCustom
    MsUnlock()
      */
    MaAlcDoc({SC7->C7_NUM,"IP",,,,,,,,,,,},dDataBase,1)
End
   FWRestArea(aArea)
Return
