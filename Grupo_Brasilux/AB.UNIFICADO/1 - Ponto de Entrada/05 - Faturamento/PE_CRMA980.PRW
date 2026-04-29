#include "Protheus.ch"
#include "FWMVCDEF.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CRMA980  ºAutor  ³ Nelieder M Corneta º Data ³  10/08/2022 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada em MVC cadastro de cliente                º±±
±±º          ³ Substitui PE MA030TOK                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descrição   ³ Codigo Operação                                         º±±
±±  Visualizar' ³ OPERATION 2                                             º±±
±±  Incluir'    ³ OPERATION 3                                             º±± 
±±  Alterar'    ³ OPERATION 4                                             º±± 
±±  Excluir'    ³ OPERATION 5                                             º±± 
±±  Imprimir'   ³ OPERATION 8                                             º±± 
±±  Copiar'     ³ OPERATION 9                                             º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function CRMA980() 
Local aParam        := PARAMIXB
Local xRet          := .T.
Local lIsGrid       := .F.
Local cIDPonto      := ''
Local cIDModel      := ''
Local oObj          := NIL
Local cRazao        := M->A1_NOME
Local cCodRedz      := M->A1_XCODENG
Local  _cGrpEmp     := ALLTRIM(FWGrpCompany())
Local aArea         := GetArea()

If aParam <> NIL
    oObj        := aParam[1]
    cIDPonto    := aParam[2]
    cIDModel    := aParam[3]
    lIsGrid     := (Len(aParam) > 3)
    nOperation := oObj:GetOperation()


    if (_cGrpEmp == '01')

        /* Pré validção dos campos */
        if (cIdPonto == 'MODELPOS') .AND. (nOperation == 3)

            // trava CNPJ duplicado        operação de incluir
            If (M->A1_EST <> "EX") 
                DbSelectARea("SA1")
                DbSetOrder(3)
                IF MsSeek(xFilial("SA1")+PadR(M->A1_CGC,LEN(M->A1_CGC)) ) 
                    Help( ,, 'Help',, "CNPJ/CPF já Cadastrado !", 1, 0 )
                    Return .F.  
                ENDIF
            EndIf  

            // trava Codigo Duplicado
            DbSelectARea("SA1")
            DbSetOrder(1)
            IF MsSeek(xFilial("SA1")+PadR(M->A1_COD,LEN(M->A1_COD))+PadR(M->A1_LOJA,LEN(M->A1_LOJA)) ) 
                Help( ,, 'Help',, "Codigo de Cliente já Cadastrado !", 1, 0 )
                Return .F.  
            ENDIF


            /* TIRADO DO MA030TOK*/               
            DO CASE
            CASE !Empty(M->A1_ENDCOB) .and. (EMPTY(M->A1_MUNC) .or. Empty(M->A1_ESTC) .or. Empty(M->A1_CEPC))
                Help( ,, 'Help',, "Preencha o Município, UF e CEP de COBRANÇA!", 1, 0 )
                Return .F. 
                
            CASE (M->A1_EST = "MT") .AND. Empty(M->A1_CNAE) .and. (empty(M->A1_PESSOA) .OR. (M->A1_PESSOA = "J"))
                Help( ,, 'Help',, "Preencha o Código CNAE!", 1, 0 )
                Return .F. 
            OTHERWISE
                U_EnviaRec("SA1", M->A1_COD, .F., M->A1_VEND)
            ENDCASE

            IF !EMPTY(ALLTRIM(M->A1_INATIVO)) .AND. (M->A1_MSBLQL != '1')
                SA1->A1_MSBLQL := '1'
            ENDIF   

        EndIf

         /*   Depois de gravar dados   */
        if (cIdPonto == 'MODELCOMMITNTTS') .AND. (nOperation == 3)
                DbSelectARea("CTD")
                DbSetOrder(1)
                If !MsSeek(xFilial("CTD")+PadR('C'+M->A1_COD,LEN(CTD->CTD_ITEM)) )
                    RecLock("CTD", .T.)
                    CTD->CTD_FILIAL := xFilial("CTD")
                    CTD->CTD_ITEM 	:= "C"+M->A1_COD
                    CTD->CTD_CLASSE := "2"
                    CTD->CTD_DESC01 := M->A1_NOME
                    CTD->CTD_BLOQ   := "2"
                    CTD->CTD_DTEXIS := STOD("19800101")
                    CTD->CTD_ITLP   := "C"+M->A1_COD
                    CTD->CTD_CLOBRG := "2"
                    CTD->CTD_ACCLVL := "1"
                    MsUnlock()   
                EndIf          
        EndIf   

         if (cIdPonto == 'MODELCOMMITNTTS') .AND. (nOperation == 4)
            
            /* TIRADO DO MA030TOK*/ //MasterSales
            RecLock("SA1", .F.)
            SA1->A1_X_EXPO  := ""
            SA1->A1_X_DTATU := DATE()
            
            IF !EMPTY(M->A1_VEND)
                SA1->A1_X_SIM3G := "S"
            ELSE
                SA1->A1_X_SIM3G := "N"
            ENDIF

            IF (AllTrim(M->A1_EST) == "EX") .AND. (nOperation == 3)
                
                If (AllTrim(M->A1_TIPO) <> "X") 
                    SA1->A1_TIPO := "X"
                EndIf
            else
              
                If M->A1_CLAS == "I"
                    SA1->A1_TIPO :=  "I"
                elseif M->A1_CLAS == "N"
                    SA1->A1_TIPO :=  "F"                
                else  
                    SA1->A1_TIPO :=  "S"                
                EndIf

            EndIf   

            If (M->A1_DESC > 0) .AND. (SUBSTRING(M->A1_CGC,1,8) = '72770878') .AND. (nOperation == 3)
                SA1->A1_DESC := 0
            EndIf

            If (M->A1_DESCDST > 0) .AND. (SUBSTRING(M->A1_CGC,1,8) = '72770878') .AND. (nOperation == 3)
                SA1->A1_DESCDST := 0
            EndIf    

            msunlock()

          

        EndIf

         /*   Depois Excluir de gravar dados   */
        if (cIdPonto == 'MODELCOMMITNTTS') .AND. (nOperation == 5)
            
            DbSelectARea("CTD")
            DbSetOrder(1)
            If MsSeek(xFilial("CTD")+PadR('C'+M->A1_COD,LEN(CTD->CTD_ITEM)) )
                If RecLock("CTD",.F.)
                    CTD->(DbDelete())
                    CTD->(MsUnlock())
                EndIf    
            EndIf    

        EndIf

    EndIf

    /*******************/
    /***** TecPolpa ****/
    /*******************/

    if (_cGrpEmp == '11')   


           /* antes de gravar, valida campos */
        if (cIdPonto == 'MODELPOS') .AND. (nOperation == 3)

            /* trava CNPJ duplicado */      
            If (M->A1_EST <> "EX")
                DbSelectARea("SA1")
                DbSetOrder(3)
                IF MsSeek(xFilial("SA1")+PadR(M->A1_CGC,LEN(M->A1_CGC)) ) 
                    Help( ,, 'Help',, "CNPJ/CPF já Cadastrado !", 1, 0 )
                    Return .F.  
                ENDIF
            EndIf  

            // trava Codigo Duplicado
            DbSelectARea("SA1")
            DbSetOrder(1)
            IF MsSeek(xFilial("SA1")+PadR(M->A1_COD,LEN(M->A1_COD))+PadR(M->A1_LOJA,LEN(M->A1_LOJA)) ) 
                Help( ,, 'Help',, "Codigo de Cliente já Cadastrado !", 1, 0 )
                Return .F.  
            ENDIF

        Endif         

        /*   Depois de gravar dados   */
        if (cIdPonto == 'MODELCOMMITNTTS') .AND. (nOperation == 3)

             /* TIRADO DO MA030TOK*/ //MasterSales
            RecLock("SA1", .F.)
            
            SA1->A1_X_DTATU := DATE()
            
            IF !EMPTY(M->A1_VEND)

                If SA1->A1_MSBLQL == "1"
                    SA1->A1_X_SIM3G := "S"
                    SA1->A1_X_EXPO  := "N"
                else
                    SA1->A1_X_SIM3G := "S"
                    SA1->A1_X_EXPO  := ""
                EndIf
                
            ELSE
                SA1->A1_X_SIM3G := "N"
                SA1->A1_X_EXPO  := "N"
            ENDIF

            msunlock()
                
            /* TIRADO DO MA030TOK*/
            DbSelectArea("SBX")
            DbSetOrder(1) //BX_FILIAL BX_CONJUN BX_CODOP
            If !SBX->(DbSeek( xFilial("SBX") + PadR("002",LEN(BX_CONJUN) ) + PadR(cCodRedz,LEN(BX_CODOP) ) ))
                Begin Transaction
                RecLock("SBX", .T.)
                SBX->BX_FILIAL 	:= xFilial("SBX")
                SBX->BX_CONJUN 	:= "002"
                SBX->BX_CODOP  	:= cCodRedz
                SBX->BX_DESC  	:= cRazao
                SBX->BX_ATIVO  	:= "1"
                MsUnlock()
                End Transaction
            EndIf


            If (nOperation == 3)
                DbSelectARea("CTD")
                DbSetOrder(1)
                If !MsSeek(xFilial("CTD")+PadR('C'+M->A1_COD+M->A1_LOJA,LEN(CTD->CTD_ITEM)) )

                    RecLock("CTD", .T.)
                    CTD->CTD_FILIAL := xFilial("CTD")
                    CTD->CTD_ITEM 	:= "C"+M->A1_COD+M->A1_LOJA
                    CTD->CTD_CLASSE := "2"
                    CTD->CTD_DESC01 := M->A1_NOME
                    CTD->CTD_BLOQ   := "2"
                    CTD->CTD_DTEXIS := STOD("19800101")
                    CTD->CTD_ITLP   := "C"+M->A1_COD+M->A1_LOJA
                    CTD->CTD_CLOBRG := "2"
                    CTD->CTD_ACCLVL := "1"
                    MsUnlock()

                EndIf    
            EndIf    


            EndIf    
        EndIf     
    

Endif    


RestArea(aArea)
Return xRet
