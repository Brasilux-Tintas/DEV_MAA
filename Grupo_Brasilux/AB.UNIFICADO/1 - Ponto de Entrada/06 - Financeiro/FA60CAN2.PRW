#Include "Protheus.ch"
 
/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA60CAN2  ³ Autor ³ Nelieder M Corneta   ³ Data ³ 28/07/22 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ PE Gravação de SE1 no estorno do borderô	                  ³±±
±±³			 ³ Projeto para desabilitar as triggers do banco de dados     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
 
User Function FA60CAN2()
Local aArea := GetArea()

/* Nelieder Corneta 01/08/2022 */
/* Rotina que subistitiu triggers da SE1 */

/* caso não seja brasilux sai da função */
   //If alltrim(FWGrpCompany()) == '01'
      
      /* parametro que habita uso via PE */
      If GETMV("ZP_PAR0060")
            RecLock("SE1",.F.)
                Replace E1_ZZDVNN   WITH  ''
                Replace E1_ZZSUBCO  WITH  ''
            MsUnlock()
      Endif

    //EndIf  

RestArea(aArea)
return nil
