#include "rwmake.ch"
#include "topconn.ch"
#include "colors.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFIN020 ºAutor  ³ Marcos C.D. Vieira º Data ³  06/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Selecionar duplicatas para enviar para Lucros e Perdas.    º±±
±±º 26/06/03 ³ Baixa Automatica dos Títulos como Dação                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFIN020()
     //Local aMarked := {}
     SetPrvt("Exec, cPerg, aCampos, cDuplic, cPrefixo")
     Private nLista := 0
     Private nLin   := 0
     Private nCol   := 0
     Private nCor   := 0
     Private oTempTbl01

     //cNomeArq := ""
     //aCampos  := {}
     nOpcA    := 0
     i        := 1

     oDlg := oSend( MSDialog(), "New", 8, 10, 18, 63,"Seleção de Duplicatas para Lucros e Perdas",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)
     @ 20,13  SAY "Este programa tem como função selecionar duplicatas para Lucros e Perdas  "
     @ 30,13  SAY "através de uma PRIORIDADE de titulos selecionados pelo usuário.           "
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
       //DbUseArea( .T.,, cNomeArq , "DUP", .F. , .F. )
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
       @ 050,015 SAY "Prefixo   "
       @ 050,045 GET cPrefixo  PICTURE '@!'
       @ 065,015 SAY "Tit./Parc."
       @ 065,045 GET cDuplic   PICTURE '@!' Valid !VAZIO()

       @ 005,085 to 080,255
       @ 085,150 BMPBUTTON TYPE 10 ACTION GeraDup()
       @ 085,180 BMPBUTTON TYPE 02 ACTION (FechaArq(),Close(oDlg1))
       @ 085,210 BMPBUTTON TYPE 01 ACTION (GravaDup(),Close(oDlg1))
 
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
       DbSetorder(1) 
       DbSeek(cDuplic)
       If !Found()
          Reclock("DUP", .T.)
             NUMDUP  := cPrefixo+cDuplic
          MsUnlock()
       Endif
       nLin    += 10
       If nLin == 70
          nLin   := 10
          nCol   += 030
          nLista += 1
       Endif  
Return

Static Function GravaDup()
     //Local aVetor := {}
     Private lMsErroAuto

     DbSelectArea("DUP")
     DbSetorder(1)
     DbGotop()
     While !Eof()
           DbSelectArea("SE1")
           DbSetOrder(1)
           DbSeek(xFilial("SE1")+DUP->NUMDUP, .T.)
           If !Eof()
              If SE1->E1_SALDO > 0
                 RecLock("SE1", .F.)
                    SE1->E1_NATUREZ := "801004"
                    SE1->E1_SITUACA := "0"
                    SE1->E1_HIST    := "LUCROS PERDAS"
                    SE1->E1_NUMBOR  := cNumBor
                    SE1->E1_DATABOR := dDataBase
                    SE1->E1_NUMBCO  := ""
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
     //RecLock("SX6",.F.)
     //   SX6->X6_CONTEUD := cNumbor
     //MsUnlock()
     PutMv("MV_NUMBORR", cNumbor )

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