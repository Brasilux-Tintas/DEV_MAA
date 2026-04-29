#Include "Protheus.ch"
 
/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA200POS  ³ Autor ³ Nelieder M Corneta   ³ Data ³ 17/08/22 ³±±
±±³ Atualizado Bradesco  ³ Autor ³ Nelieder M Corneta   ³ Data ³ 01/03/23 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ PE Geração CNAB ocorrencias                       		  ³±±
±±³			 ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
 
User Function FA200POS()
Local aArea := GetArea()
Local cPrefixo := PADR( SUBSTR(ParamIxb[01][1],1,3) ,TamSx3("E1_PREFIXO")[1] )
Local cTitulo  := PADR( SUBSTR(ParamIxb[01][1],4,6) ,TamSx3("E1_NUM")[1] )
Local cParcela := PADR( SUBSTR(ParamIxb[01][1],10,1),TamSx3("E1_PARCELA")[1] )

/* retorna quando for tecpolpa ou banco diferente de 341 */
If (alltrim(FWGrpCompany())) == '11' //.OR. (AllTrim(SEB->EB_BANCO) <> "341")
    Return(.T.)
EndIf    


DbSelectARea("SE1")
DbSetOrder(1)
                            // Prefixo                          Titulo                Parcela 
IF MsSeek(xFilial("SE1")+cPrefixo+cTitulo+cParcela)
    
    RecLock("SE1",.F.)
    SE1->E1_XCNAB := SEB->EB_REFBAN
    MsUnLock()

EndIf    

RestArea(aArea)
return(.T.)
