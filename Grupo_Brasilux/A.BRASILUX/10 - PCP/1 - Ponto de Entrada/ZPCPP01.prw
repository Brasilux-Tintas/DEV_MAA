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

User Function ZPCPP01()
Local nTotal
Local cQuery1
Local UniEmb := ""
Local Volume := ""


    if (AllTrim(SB1->B1_TIPO) = 'PA') .And. (alltrim(FWCodFil())<> '010106') .And. (alltrim(FWCodFil()) <> '010107')
        
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

            DbSelectArea("SB5")
            SB5->( DbSetorder( 1 ) )
            If SB5->( DbSeeK( xFilial("SB5") + SB1->B1_COD ) )
                If !Empty(SB5->B5_UMDIPI) .OR. !Empty(SB5->B5_CONVDIP)
                    Reclock( "SB5", .F. )
                        SB5->B5_2CODBAR  := "SEM GTIN"
                    SB5->( MsUnLock() )                    
                EndIf
            Endif 

        Else
            
            Reclock("SB1",.F.) 
                SB1->B1_CODBAR  := ""
                SB1->B1_CODGTIN := ""
            SB1->( MsUnlock() )
            
            FWAlertError("Não foi possivel Gerar o codigo GTIN.", "Cadastro de Produto")
        EndIf
    EndIf

    //Cadastrar 2a. UM quando não tem estrutura, pegar de SZ5010
    cEmba := SUBSTR(AllTrim(SB1->B1_COD),11,2)
    If (Len(AllTrim(SB1->B1_COD)) == 12) .And. (alltrim(FWCodFil())<> '010106') .And. (alltrim(FWCodFil()) <> '010107')
        
        If (cEmba <> "00") .And. (cEmba <> "99")

            DbSelectArea("SG1")
            SG1->(dbSetOrder(1))
            If !SG1->(dbSeek(xFilial("SG1")+PadR(SB1->B1_COD,Len(SG1->G1_COD))))
                
                DbSelectArea("SZ5")
                SZ5->(dbSetOrder(1))
                If SZ5->(dbSeek(xFilial("SZ5")+PadR(cEmba,Len(SZ5->Z5_EMB))))
                    Volume := SZ5->Z5_VOLUME
                    UniEmb := SZ5->Z5_UMEMB
                Endif

                Reclock("SB1",.F.) 
                    SB1->B1_SEGUM   := UniEmb
                    SB1->B1_TIPCONV := "M"
                    SB1->B1_CONV    := Volume
                SB1->( MsUnlock() )


            EndIf

        Else
            If (AllTrim(SB1->B1_UM)) == "L"
                Reclock("SB1",.F.) 
                    SB1->B1_SEGUM   := "k"
                    SB1->B1_TIPCONV := "M"
                    SB1->B1_CONV    := SB1->B1_PESOESP
                SB1->( MsUnlock() )
            EndIf

        EndIf


    EndIf


return()
/*

                cQry := "UPDATE "+RetSqlName("SB1")+" SET B1_SEGUM = @cUm,B1_TIPCONV = 'M', "
                cQry += "B1_CONV = ISNULL(Z5_VOLUME,0) "
                cQry += "FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "
                cQry += "LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON (SZ5.D_E_L_E_T_ <> '*') AND (Z5_EMB = '"+UniEmb+"')  "
                cQry += "WHERE SB1.R_E_C_N_O_ = "+AllTrim(Str(Recno))+"  "
                TcSqlExec(cQry)

*/
