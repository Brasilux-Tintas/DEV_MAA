
User Function BRPCPA11()
     Private aGerTxtOps := {}
     Private cCallMenu  := "S"
     DBSELECTAREA("SB2")
     DBSELECTAREA("SC2")
     //MsgStop("Geração de Ops.", "Atençao...")
     Mata650()
     //MsgStop("Saindo da geração de Ops.", "Atençao...")
     If Len(aGerTxtOps) > 0
        u_fGerTXTOps(aGerTxtOps)
     Endif
Return