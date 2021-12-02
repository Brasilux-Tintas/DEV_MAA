#include "rwmake.ch"
#include "topconn.ch"
#include "colors.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFIN019 ºAutor  ³ Marcos C.D. Vieira º Data ³  21/04/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Selecionar duplicatas para enviar para Instituição de Co-  º±±
±±º          ³ brança.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFIN019()
     //Local aMarked := {}       
     Private oTempTbl01
     SetPrvt("Exec, cPerg, aCampos, cDuplic, cInstCobr, cPrefixo, cNumBor")
     u_zcfga01( 'BRFIN019' ) //LGS#2021202 - Gravação de log de utilização da rotina
     //cNomeArq := ""
     //aCampos  := {}
     nOpcA    := 0
     i        := 1

     oDlg := oSend( MSDialog(), "New", 8, 10, 18, 63,"Seleção de Duplicatas para Cobrança",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)

     @ 20,013 SAY "Este programa tem como função selecionar duplicatas para Cobrança através "
     @ 30,013 SAY "de uma PRIORIDADE de titulos selecionados pelo usuário.                   "
     @ 57,170 BMPBUTTON TYPE 09 ACTION (SelDup())

     bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
     bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
     bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }
     oSend( oDlg, "Activate",,,, .T.,,, bInit )
Return Nil

Static Function SelDup()
       //cNomeArq := ""
       aCampos  := {}

       aAdd(aCampos, { "NUMDUP" , "C", 11, 0})

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 30/12/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cNomeArq := CriaTrab(aCampos)
       //DbUseArea( .T.,, cNomeArq ,"DUP", .F. , .F. )
       //IndRegua("DUP", cNomeArq, "NUMDUP",,, "Selecionando Registros...")
       oTempTbl01 := FWTemporaryTable():New( "DUP" )
       oTempTbl01:SetFields( aCampos )
       oTempTbl01:AddIndex( "cInd01", { "NUMDUP" } )
       oTempTbl01:Create()

       cNumBor   := Soma1(GetMV("MV_NUMBORR"), 6)
       cDuplic   := Space(08)
       cPrefixo  := Space(03)
       cInstCobr := Space(03)
       nLin      := 10
       nCol      := 090
       nLista    := 1
       nCor      := 1

       @ 001,001 TO 200,510 DIALOG oDlg1 TITLE "Ordem de Duplicatas Selecionadas"
       @ 005,015 SAY "Borderô Nº"  COLOR CLR_BLUE
       @ 005,045 SAY cNumBor       COLOR CLR_HBLUE
       @ 020,015 SAY "Inst.Cobr."
       @ 020,045 GET cInstCobr PICTURE '@!' Valid !VAZIO() .AND. INSTCOB() F3 "SZL"
       @ 050,015 SAY "Prefixo   "
       @ 050,045 GET cPrefixo  PICTURE '@!'
       @ 065,015 SAY "Tit./Parc."
       @ 065,045 GET cDuplic   PICTURE '@!' Valid !VAZIO()

       @ 005,085 to 080,255
       @ 085,150 BMPBUTTON TYPE 10 ACTION GeraDup()
       @ 085,180 BMPBUTTON TYPE 02 ACTION (FechaArq(), Close(oDlg1))
       @ 085,210 BMPBUTTON TYPE 01 ACTION (GravaDup(), Close(oDlg1))

       ACTIVATE DIALOG oDlg1 CENTERED
Return

Static Function GeraDup()
       If nLista == 6
          nLin      := 10
          nCol      := 090
          nLista    := 1
          If nCor == 1
             nCor := 2
          Else
             nCor := 1
          Endif  
       Endif           

       If nCor == 1
          @ nLin,nCol SAY cDuplic
       Else
          @ nLin,nCol SAY cDuplic COLOR CLR_HRED
       Endif

       DbSelectArea("DUP")
       DbSetOrder(1)
       DbSeek(cDuplic)
       If !Found()
          Reclock("DUP", .T.)
             NUMDUP  := cPrefixo+cDuplic
          MsUnlock()
       Endif

       nLin    += 10
       If nLin == 70
          nLin   := 10
          nCol   += 30
          nLista += 1
       Endif
Return

Static Function GravaDup()
       DbSelectArea("DUP")
       DbSetOrder(1)
       DbGotop()
       While !Eof()
             DbSelectArea("SE1")
             DbSetOrder(1)
             DbSeek(xFilial("SE1")+DUP->NUMDUP, .T.)
             If !Eof()
                If Empty(SE1->E1_INSTCOB) .AND. SE1->E1_SALDO <> 0
                   Reclock("SE1", .F.)
                      SE1->E1_INSTCOB := cInstCobr
                      SE1->E1_NUMBOR  := cNumBor
                      SE1->E1_DATABOR := dDataBase
                      SE1->E1_SITUACA := "5"
                      SE1->E1_HIST    := Alltrim(SZL->ZL_NREDUZ)+"/"+Alltrim(SE1->E1_HIST)
                      SE1->E1_PORTADO := ""
                      SE1->E1_CONTA   := ""
                      SE1->E1_BCO     := ""
                   MsUnlock()
                Endif
             Endif
             DbSelectArea("DUP")
             DbSkip()
       Enddo
       //LGS#20200130 - Adequação de release 12.1.25
       //DbSelectArea("SX6")
       GetMv("MV_NUMBORR")
       //RecLock("SX6", .F.)
       //   SX6->X6_CONTEUD := cNumbor
       //MsUnlock()            
       PutMv( "MV_NUMBORR", cNumbor )
       FechaArq()
Return                 

Static Function FechaArq()
       DbSelectArea("DUP")
       DbCloseArea()
       oTempTbl01:Delete()
       Use
       //Ferase(cNomeArq+".DBF")         // Elimina arquivos de Trabalho
       //Ferase(cNomeArq+OrdBagExt())    // Elimina arquivos de Trabalho
Return

Static Function InstCob()
       DbSelectArea("SZL")
       DbSetorder(1)
       DbSeek(xFilial("SZL")+cInstCobr)
       @ 032,015 SAY SZL->ZL_NREDUZ COLOR CLR_CYAN
Return
