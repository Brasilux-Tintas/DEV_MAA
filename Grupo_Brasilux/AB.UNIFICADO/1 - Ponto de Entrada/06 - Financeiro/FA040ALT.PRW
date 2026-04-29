#Include "Protheus.ch"
 
/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA040ALT  ³ Autor ³ Nelieder M Corneta   ³ Data ³ 28/07/22 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ PE Alteração contas a receber                       		  ³±±
±±³			 ³ Projeto para desabilitar as triggers do banco de dados     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
 
User Function FA040ALT()
Local aArea := GetArea()
Local lRet  := .T.

    
    /* parametro que habita uso via PE */
    If !GETMV("ZP_PAR0060")
        Return .T.
    Endif

    IF !EMPTY(M->E1_CLIENTE)

        If alltrim(FWGrpCompany()) == '11'
            M->E1_ITEMCTA := "C"+M->E1_CLIENTE+M->E1_LOJA
        else
            M->E1_ITEMCTA := "C"+M->E1_CLIENTE    
        Endif

    ENDIF

    If alltrim(FWGrpCompany()) == '01'
        M->E1_X_DTATU := Dtos(dDataBase)
    Endif    

    IF (M->E1_TIPO == "NCC") .OR. (M->E1_TIPO == "AB-") .OR. (M->E1_TIPO == "JP") .OR. (M->E1_TIPO == "RA")
        M->E1_X_SIM3G = "N"
        M->E1_X_EXPO  := "N"    
    ELSE
        M->E1_X_SIM3G = "S"
        M->E1_X_EXPO  := ""    
    ENDIF        

    
   
    IF !EMPTY(SE1->E1_NUMBCO) .AND. EMPTY(M->E1_NUMBCO)
        M->E1_ZZDVNN  := ''
        M->E1_ZZSUBCO := ''
    ENDIF

    

RestArea(aArea)
return(lRet)
