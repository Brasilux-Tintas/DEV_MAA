#Include "Protheus.ch"
 
/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA040INC  ³ Autor ³ Nelieder M Corneta   ³ Data ³ 28/07/22 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ponto de Entrada Inclusão contas a receber       		  ³±±
±±³			 ³ Projeto para desabilitar as triggers do banco de dados     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*
CNTA121 - Gestão de Contratos
FINA040 - Financeiro
FINA460 - Financeiro Renegociação
*/

User Function FA040INC()
    Local aArea := GetArea()
    Local lRet  := .T.
    
    /* parametro que habita uso via PE */
    If !GETMV("ZP_PAR0060")
        Return .T.
    Endif


    If alltrim(FWGrpCompany()) == '11'
        
         IF !EMPTY(M->E1_CLIENTE)
            M->E1_ITEMCTA := "C"+M->E1_CLIENTE+M->E1_LOJA
        ENDIF

        M->E1_X_EXPO  := ""
     
        IF (M->E1_TIPO == "NCC") .OR. (M->E1_TIPO == "AB-") .OR. (M->E1_TIPO == "JP") .OR. (M->E1_TIPO == "RA")
            M->E1_X_SIM3G = "N"
        ELSE
            M->E1_X_SIM3G = "S"
        ENDIF

        Return lRet

    Endif


    /* verificar parametros do titulo*/
    IF (M->E1_TIPO = 'NF') .AND. RetNat(ALLTRIM(M->E1_NATUREZ)) .AND. (LEN(RTRIM(M->E1_PEDIDO)) > 0) .AND. (LEN(RTRIM(M->E1_BCO)) = 0) 
        
        /* tem pedido de vendas */
        DbSelectARea("SC5")
	    DbSetOrder(1)
	    IF MsSeek(xFilial("SC5")+M->E1_PEDIDO)    
            
            /* tem banco no pedido de vendas */
            IF (LEN(RTRIM(SC5->C5_BANCO)) > 0)
                M->E1_BCO = SC5->C5_BANCO
            ENDIF

        ENDIF   

    ENDIF

     /* verificar parametros do titulo*/
    IF (M->E1_TIPO = 'NF') .AND. RetNat(ALLTRIM(M->E1_NATUREZ)) .AND. (LEN(RTRIM(M->E1_PEDIDO)) > 0)  
        
        /* tem pedido de vendas */
        DbSelectARea("SC5")
	    DbSetOrder(1)
	    IF MsSeek(xFilial("SC5")+M->E1_PEDIDO)    
            
            IF (M->E1_COMIS1 <> SC5->C5_COMIS1)

                M->E1_COMIS1 = SC5->C5_COMIS1

            ENDIF

        ENDIF   

    ENDIF

   
    /* tem gatilho no E1_CLIENTE protheus */
    IF !EMPTY(M->E1_CLIENTE)
        M->E1_ITEMCTA := "C"+M->E1_CLIENTE
    ENDIF

   
     /* já tem na X3_RELACAO DATE() */
     M->E1_X_DTATU := Dtos(dDataBase)
     
     M->E1_X_EXPO  := ""
     
     IF (M->E1_TIPO == "NCC") .OR. (M->E1_TIPO == "AB-") .OR. (M->E1_TIPO == "JP") .OR. (M->E1_TIPO == "RA")
        M->E1_X_SIM3G = "N"
     ELSE
        M->E1_X_SIM3G = "S"
     ENDIF

     
    RestArea(aArea)
Return lRet



/* Função que verifica se natureza informada no titulo corresponde com */
/* a natureza informada no parametro ZP_PAR0059 */

Static Function RetNat(pNatu)
Local retorna,aString 
Local i
Local Naturez := GETMV("ZP_PAR0059")

aString := strtokarr (Naturez, ",")

retorna := .F.
For i := 1 to len(aString)

    if aString[i] == pNatu
        retorna := .T.
        exit
    Endif

Next


return(retorna)
