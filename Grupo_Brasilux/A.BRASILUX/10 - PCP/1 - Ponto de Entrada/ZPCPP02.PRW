#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  ZPCPP01 ºAutor  ³ Nelieder Corneta º Data ³  15/04/2023   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Sustituição da Trigger trig_inclui_SB1010                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function ZPCPP02()

    // Verifica CodBar  
    if (AllTrim(SB1->B1_TIPO) = 'PA') .And. (alltrim(FWCodFil())<> '010106') .And. (alltrim(FWCodFil()) <> '010107')
        
        DbSelectArea("ZA1")
        ZA1->(dbSetOrder(1))
        If ZA1->(dbSeek(xFilial("ZA1")+PadR(SB1->B1_COD,Len(SB1->B1_COD)))) 
            // Tem CodBar Cadastrado na ZA1, mas não tem na SB1
            If AllTrim(ZA1->ZA1_GTIN) <> AllTrim(SB1->B1_CODBAR)
                Reclock("SB1",.F.) 
                    SB1->B1_CODBAR  := SUBSTR(ZA1->ZA1_GTIN,1,12)
                    SB1->B1_CODGTIN := ZA1->ZA1_GTIN
                SB1->( MsUnlock() )
            EndIf
        Else 
                // Não tem CodBar e cadastra                
                Processa()               
        EndIf
    EndIf

    If (AllTrim(SB1->B1_VEND) == 'N') .OR. (AllTrim(SB1->B1_MSBLQL) == "1")
        DbSelectArea("ZZ6")
        ZZ6->(dbSetOrder(1)) //ZZ6_FILIAL+ZZ6_EMPR+ZZ6_TABELA+ZZ6_CHAVE
        If ZZ6->(dbSeek(xFilial("ZZ6")+PadR(Alltrim(FWCodFil()),Len(ZZ6->ZZ6_EMPR))+PadR("SB1",Len(ZZ6->ZZ6_TABELA))+PadR(SB1->B1_COD,Len(ZZ6->ZZ6_CHAVE))  )) 
             Reclock("ZZ6",.F.) 
                    ZZ6->ZZ6_PROCES := "N"
                    ZZ6->ZZ6_APAGAR := .T.
                    ZZ6->ULTATUALIZ := dDataBase
             ZZ6->( MsUnlock() )
        EndIf
        //UPDATE ZZ6010 SET ZZ6_PROCES = 'N', ZZ6_APAGAR = 'T',ULTATUALIZ = GETDATE() WHERE (D_E_L_E_T_ <> '*') AND (ZZ6_EMPR = @cFilial) AND (ZZ6_TABELA = 'SB1') AND (ZZ6_CHAVE = @cProd)
    
    Else
    
    EndIf


        return()


Static Function Processa()
Local nTotal
Local cQuery1

    cQuery1 := " SELECT TOP 1 * FROM "+RetSQlName("ZA1")+" ZA1 WHERE ZA1_FILIAL = '"+xFilial("ZA1")+"'  "
    cQuery1 += " AND ZA1_PRODUT = '' AND ZA1.D_E_L_E_T_ = '' "

    /* verifica se arquivo está aberto e finaliza */
    IF Select("TMP") <> 0
        DbSelectArea("TMP")
        DbCloseArea()
    ENDIF

    TCQUERY cQuery1 NEW ALIAS "TMP"  
    Count To nTotal 
    TMP->(dbGoTop())

    If nTotal > 0

        DbSelectArea("ZA1")
        ZA1->(dbSetOrder(3))
        ZA1->(dbSeek(xFilial("ZA1")+PadR(TMP->ZA1_GTIN,Len(ZA1->ZA1_GTIN))))

        Reclock("ZA1",.F.) 
            ZA1->ZA1_PRODUT := SB1->B1_COD
        ZA1->( MsUnlock() )

        Reclock("SB1",.F.) 
            SB1->B1_CODBAR  := SUBSTR(TMP->ZA1_GTIN,1,12)
            SB1->B1_CODGTIN := TMP->ZA1_GTIN
        SB1->( MsUnlock() )

    Else
        
        Reclock("SB1",.F.) 
            SB1->B1_CODBAR  := ""
            SB1->B1_CODGTIN := ""
        SB1->( MsUnlock() )
        
        FWAlertError("Não foi possivel Gerar o codigo GTIN.", "Cadastro de Produto")
    EndIf

Return()
