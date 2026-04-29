#include "protheus.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
  ±±ºPrograma  ³ MA650EMP ºAutor  ³ Luís Gustavo       º Data ³  15/09/04   º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºDesc.     ³ Ponto de entrada para ajustes na quantidade empenhada, de- º±±
  ±±º          ³ vido ao ajuste de cor das fórmulas.                        º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºUso       ³ BRASILUX                                                   º±±
  ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
  /* - Após a inclusão do novo aHeader pelo P.E. MTA650AC e calculado o valor -
       do acerto de cor pelo P.E. EMP650, é utilizado esse P.E. MA650EMP para a
       gravação da informação no campo D4_ACECOR do arquivo SD4.
  */
//30/09/2019 - Luís Gustavo - Adequação para release 12.1.25  
User Function MA650EMP()
     Local _aArea := getarea()
     Local lRegD4, nRegD4, nOrdD4
     Local nPosAce, nPosTRT, nPosSLo, nPosNLo, nY

     Local aBrowse := {}
     Local cOP := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
     Local oOP

     //Fontes
     Private cFontUti  := "Tahoma"
     Private oFontAno  := TFont():New(cFontUti, , -38)
     Private oFontBtn  := TFont():New(cFontUti, , -14)
     Private oFontSub  := TFont():New(cFontUti, , -16)
     Private oFontSubN := TFont():New(cFontUti, , -20, , .T.)

     //Tamanho da Janela
     Private nJanLarg  := 900
     Private nJanAltu  := 550
     //---------------- LGS#20231023 ----- RETIRADA DA GRAVAÇÃO DO LOG DE ROTINA PARA MELHORA DE PERFORMANCE.
     //u_zcfga01( 'MA650EMP' ) //LGS#2021201 - Gravação de log de utilização da rotina
     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        DbSelectArea("SD4") 
        nOrdD4 := IndexOrd()
        If !eof() .and. !bof()
           lRegD4 := .t.
           nRegD4 := recno()
        Else
           lRegD4 := .f.
        Endif
        If GETMV("MV_AJUSCOR")
           nPosAce := aScan(aHeader, {|x| AllTrim(x[2]) == 'D4_ACECOR'})
           nPosTRT := aScan(aHeader, {|x| AllTrim(x[2]) == 'G1_TRT'}) 
           nPosSLo := aScan(aHeader, {|x| AllTrim(x[2]) == 'D4_NUMLOTE'})
           nPosNLo := aScan(aHeader, {|x| AllTrim(x[2]) == 'D4_LOTECTL'})
           For nY := 1 To Len(aCols)
               DbSelectArea("SD4")
               DbSetOrder(1)
               //DbSeek(xFilial("SD4")+aCols[nY][1]+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD+aCols[nY][nPosTRT]+aCols[nY][nPosNLo]+aCols[nY][nPosSLo],.t.)
               DbSeek(xFilial("SD4")+aCols[nY][1]+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD+aCols[nY][nPosTRT],.t.)
               If Found()
                  RecLock("SD4", .f.)
                     SD4->D4_ACECOR := aCols[nY][nPosAce]
                     SD4->D4_NUMLOTE:= aCols[nY][nPosSLo]   // GRAVANDO CAMPO G1_OPERACA POIS NÃO UTILIZAMOS RASTREABILIDADE (IMPRESSÃO ORDENADA POR ESTE CAMPO PARA LATEX) -0880.0881.0082.
                  MsUnLock()
               Endif
           Next
        Endif
        DbSelectArea("SD4")
        Dbsetorder(nOrdD4)
        If lRegD4
           dbgoto(nRegD4)
        Endif
        restarea(_aArea)
     Endif

      If FWCodEmp() == '11' .AND. funname() == "MATA650"
        
         DbSelectArea("SD4")
         DbSetOrder(2)
         DbSeek(xFilial("SD4")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,.t.)
         While (!SD4->(EoF())) .AND. (allTrim(SD4->D4_OP) == allTrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
            
            dbSelectArea("SB2")
		      dbSetOrder(1)
		      SB2->(dbGoTop())
		      If dbSeek(xFilial("SB2")+PadR(SD4->D4_COD,TamSx3("D4_COD")[1])+PadR(SD4->D4_LOCAL,TamSx3("D4_LOCAL")[1]))            
               
               SB1->(DbSeek(xFilial("SB1")+PadR(SD4->D4_COD, tamsx3('B1_COD') [1])))
               If (SaldoSb2() < 0) .AND. (SB1->B1_TIPO <> "MO")
                  
                   aAdd(aBrowse, { ;
                                 SD4->D4_COD,;
                                 SB1->B1_DESC,;
                                 SD4->D4_LOCAL,;
                                 SD4->D4_QUANT,;
                                 SaldoSb2();
                              })

               Endif
            
            Endif
            SD4->(DbSkip())

         EndDo

         /* incluido por Nelieder 07/12/2022 */
         if len(aBrowse) > 0

               DEFINE MSDIALOG oDlg TITLE "Produtos com saldo Negativo" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

               @ 004, 003 MSPANEL oPanel SIZE 600, 080 OF oDlg COLORS 0, 14215660 CENTERED RAISED

               @ 010, 010 SAY OemToAnsi("Nº da OP.: ") SIZE 060,009 PIXEL OF oDlg FONT oFontBtn
               @ 008, 060 MSGET oOP VAR cOP PICTURE "@!" SIZE 090,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

               @ 240,010 BUTTON oBtnFech PROMPT "Sair" SIZE 060, 018 OF oDlg ACTION oDlg:End() FONT oFontBtn PIXEL

               oBrowse  := TCBrowse():New(030, 004, 450, 200, , {'Produto','Descrição','Local','Qtd','Saldo'}, {20,50}, oDlg, , , , , , , oFontBtn, , , , , .F., , .T., , .F., , ,)

               // Seta vetor para a browse
               oBrowse:SetArray(aBrowse)

               // Monta a linha a ser exibina no Browse
               oBrowse:bLine  := {||{  aBrowse[oBrowse:nAt,01],;
                                       aBrowse[oBrowse:nAt,02],;
                                       aBrowse[oBrowse:nAt,03],;
                                       aBrowse[oBrowse:nAt,04],;
                                       aBrowse[oBrowse:nAt,05];
                                       }}


              
               oDlg:lEscClose := .T.

               ACTIVATE MSDIALOG oDlg CENTERED
         
         Endif



      Endif   
      
Return
