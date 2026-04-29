#Include "Protheus.ch"
 
/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA60TRAN  ³ Autor ³ Nelieder M Corneta   ³ Data ³ 21/09/22 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ PE Utilizado para limpar campos do Boleto                  ³±±
±±³			 ³ FA60TRAN será executado ao final da rotina de              ³±±
±±³ transferência de contas a receber, após gravação de dados             ³±± 
±±³ e da contabilização                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
 
User Function FA60TRAN()
Local aArea  := GetArea()
Local cQuery := ""

    if Empty(SE1->E1_PORTADO)

        RecLock("SE1",.F.)
            Replace E1_ZZDVNN   WITH  ''
            Replace E1_ZZSUBCO  WITH  ''
            Replace E1_XCNAB    WITH  ''
        MsUnlock()

        cQuery := "UPDATE "+RetSqlName("SE1")+" SET E1_XPIX = NULL WHERE R_E_C_N_O_ = "+AllTrim(str(RecNo()))+" "
        TCSqlExec(cQuery)
    Endif
    
    

RestArea(aArea)
return nil
