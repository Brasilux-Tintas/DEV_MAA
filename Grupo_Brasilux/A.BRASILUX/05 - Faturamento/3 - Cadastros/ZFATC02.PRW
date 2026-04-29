#Include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ZFATC02  ³ Autor ³ Nelieder M Corneta   ³ Data ³ 20/03/23 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Politica Comercial                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function ZFATC02()
Private cAliq

    Tela()

return()

Static Function Tela ()

//Fontes
Private cFontUti  := "Tahoma"
Private oFontBtn  := TFont():New(cFontUti, , -20)
Private oFontBtg  := TFont():New(cFontUti, , -14)

//Tamanho da Janela
Private nJanLarg  := 1250
Private nJanAltu  := 555


/* Politica de Desconto */
Private oBrDesc18 
Private oBrDesc12 
Private oBrDesc7  

Private aBrDesc18   := {}
Private aBrDesc12   := {}
Private aBrDesc7    := {}

/* Politica de Comissionamento */
Private oBrComi18 
Private oBrComi12 
Private oBrComi7  

Private aBrComi18   := {}
Private aBrComi12   := {}
Private aBrComi7    := {}

Private cDesc     := SC5->C5_DESCON4
Private oDesc

Private cFrete    := SC5->C5_XVLRFRE
Private oFrete

Private cTPedido  := 0
Private oPedido

Private cVend := ""

// Planilha Financeira

U_RetICMS()

DEFINE MSDIALOG oDlg TITLE "Politica Comercial & Politica Comissionamento" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

    dbselectarea("ZAD")
    
    //Top  Left                  Bot  Rig
    @ 001, 001	GROUP oGrpGer TO 035, 313	PROMPT OF oDlg COLOR RGB(255,0,0), 16777215 PIXEL
    @ 010, 110 SAY OemToAnsi("Politica de Desconto") SIZE 130,015 PIXEL OF oDlg FONT oFontBtn
    
    //Top  Left                  Bot  Rig
    @ 001, 315	GROUP oGrpGer  TO 035, 627 PROMPT OF oDlg COLOR RGB(255,0,0), 16777215 PIXEL
    @ 010, 410 SAY OemToAnsi("Politica de Comissionamento") SIZE 130,015 PIXEL OF oDlg FONT oFontBtn

    
    // Politica Desconto
    @ 035,003 FOLDER oFldDesc PROMPTS '18%','12%','7%' SIZE 310, 200 OF oDlg  PIXEL

    // Politica Comissionamento
    @ 035,315 FOLDER oFldComi PROMPTS '18%','12%','7%' SIZE 310, 200 OF oDlg  PIXEL
 
    CarBrw()

    oDlg:lEscClose      := .T.
    
    //Top  Left                   Bot  Rig
    @ 240, 001	GROUP oGrpGer  TO 277, 627 PROMPT OF oDlg COLOR RGB(255,0,0), 16777215 PIXEL

    cVend := ""
    SA3->(dbSetOrder(1))
    if SA3->(dbSeek(xFilial("SA3")+PadR(SC5->C5_VEND1,Len(SA3->A3_COD))))
        cVend := AllTrim(SA3->A3_COD)+" - "+AllTrim(SA3->A3_NOME) 
    EndIf

    // localiza cliente
    SA1->(dbSetOrder(1))
    SA1->(dbSeek(xFilial("SA1")+PadR(SC5->C5_CLIENTE,Len(SA1->A1_COD))))
    
    @ 245, 005 SAY OemToAnsi("Nº Pedido..:")        SIZE 130,015 PIXEL OF oDlg FONT oFontBtg
    @ 245, 046 SAY OemToAnsi(Alltrim(SC5->C5_NUM))  SIZE 130,015 PIXEL OF oDlg FONT oFontBtg

    @ 245, 090 SAY OemToAnsi("Cliente....:")                                   SIZE 200,015 PIXEL OF oDlg FONT oFontBtg
    @ 245, 130 SAY OemToAnsi(AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NOME)) SIZE 200,015 PIXEL OF oDlg FONT oFontBtg

    @ 260, 005 SAY OemToAnsi("Aliq.ICMS..:") SIZE 130,015 PIXEL OF oDlg FONT oFontBtg
    @ 260, 046 SAY OemToAnsi(cAliq) SIZE 130,015 PIXEL OF oDlg FONT oFontBtg

    @ 260, 090 SAY OemToAnsi("Vendedor...:") SIZE 200,015 PIXEL OF oDlg FONT oFontBtg  
    @ 260, 130 SAY OemToAnsi(Alltrim(cVend)) SIZE 200,015 PIXEL OF oDlg FONT oFontBtg  
    
    
    @ 245, 300 SAY OemToAnsi("Cidade.....:") SIZE 200,015 PIXEL OF oDlg FONT oFontBtg
    @ 245, 340 SAY OemToAnsi(AllTrim(SA1->A1_MUN)+" - "+AllTrim(SA1->A1_EST)) SIZE 200,015 PIXEL OF oDlg FONT oFontBtg
        
    @ 250, 490 BUTTON oBtnFech PROMPT "Calcular" SIZE 060, 013 OF oDlg ACTION (Calcular(SC5->C5_NUM)) FONT oFontBtn PIXEL
    @ 250, 565 BUTTON oBtnFech PROMPT "Sair"     SIZE 060, 013 OF oDlg ACTION (oDlg:End()) FONT oFontBtn PIXEL

ACTIVATE MSDIALOG oDlg CENTERED


Return()

// Carrega Browsers
Static Function CarBrw()
Local _cUfCliFor
    
  oBrDesc18  := TCBrowse():New(002, 002, 300, 175, , {'Faixa De', 'Faixa Ate', 'Desc1','Desc2','Desc3','Desc4','Desc5' }, {60,60,30,30,30,30,30}, oFldDesc:aDialogs[1], , , , , , , , , , , , .F., , .T., , .F., , ,)
  oBrDesc12  := TCBrowse():New(002, 002, 300, 175, , {'Faixa De', 'Faixa Ate', 'Desc1','Desc2','Desc3','Desc4','Desc5' }, {60,60,30,30,30,30,30}, oFldDesc:aDialogs[2], , , , , , , , , , , , .F., , .T., , .F., , ,)
  oBrDesc7   := TCBrowse():New(002, 002, 300, 175, , {'Faixa De', 'Faixa Ate', 'Desc1','Desc2','Desc3','Desc4','Desc5' }, {60,60,30,30,30,30,30}, oFldDesc:aDialogs[3], , , , , , , , , , , , .F., , .T., , .F., , ,)
    
  If SC5->C5_TIPO $ "D_B"
      DbSelectArea("SA2")
      If SA2->( DbSeek( xFilial("SA2") + SC5->C5_CLIENTE ) )
        _cUfCliFor := SA2->A2_EST
      Endif
  Else
      DbSelectArea("SA1")
      SA1->( DbSeek( xFilial("SA1") + SC5->C5_CLIENTE ) )
      If Found()
        _cUfCliFor := SA1->A1_EST
      Endif
  Endif
    
  //GetMV( "ZP_PAR0089" ) Estados ICMS 7%                                   
  //GetMV( "ZP_PAR0090" ) Estados ICMS 12%                                  
  //GetMV( "ZP_PAR0091" ) Estados ICMS 18%                                  

  If _cUfCliFor $ GetMV( "ZP_PAR0089" )
      _nICMPol := "1"  // 7%
      cAliq    := "7%"
    ElseIf _cUfCliFor $ GetMV( "ZP_PAR0090" )
      _nICMPol := "2"  // 12%
      cAliq    := "12%"
    ElseIf _cUfCliFor $ GetMV( "ZP_PAR0091" )
      _nICMPol := "3"  // 18%
      cAliq    := "18%"
  Endif
 
  dbselectarea("ZAD")
  dbsetorder(2) // ZAD_FILIAL+ZAD_TPEST
  dbgotop()
  //dbseek(xFilial("ZAD")+PadR(_nICMPol, tamsx3('ZAD_TPEST') [1]))
  While ZAD->(!eof()) //.AND. (ZAD->ZAD_TPEST == _nICMPol)
    
    If  (ZAD->ZAD_VALID) >= (dDataBase) 
    
      If ZAD->ZAD_TPTAB == "1"

        // Politica Desconto
        If     ZAD->ZAD_TPEST == "1" // 7%
          aAdd(aBrDesc7, {TransForm(ZAD->ZAD_FXDE, "@E 999,999.99"),TransForm(ZAD->ZAD_FXATE, "@E 999,999.99"),Alltrim(Str(ZAD->ZAD_DESC1))+"%",Alltrim(Str(ZAD->ZAD_DESC2))+"%",Alltrim(Str(ZAD->ZAD_DESC3))+"%",Alltrim(Str(ZAD->ZAD_DESC4))+"%",Alltrim(Str(ZAD->ZAD_DESC5))+"%"})
        ElseIf ZAD->ZAD_TPEST == "2" // 12%
          aAdd(aBrDesc12, {TransForm(ZAD->ZAD_FXDE, "@E 999,999.99"),TransForm(ZAD->ZAD_FXATE, "@E 999,999.99"),Alltrim(Str(ZAD->ZAD_DESC1))+"%",Alltrim(Str(ZAD->ZAD_DESC2))+"%",Alltrim(Str(ZAD->ZAD_DESC3))+"%",Alltrim(Str(ZAD->ZAD_DESC4))+"%",Alltrim(Str(ZAD->ZAD_DESC5))+"%"})
        ElseIf ZAD->ZAD_TPEST == "3" // 18%
          aAdd(aBrDesc18, {TransForm(ZAD->ZAD_FXDE, "@E 999,999.99"),TransForm(ZAD->ZAD_FXATE, "@E 999,999.99"),Alltrim(Str(ZAD->ZAD_DESC1))+"%",Alltrim(Str(ZAD->ZAD_DESC2))+"%",Alltrim(Str(ZAD->ZAD_DESC3))+"%",Alltrim(Str(ZAD->ZAD_DESC4))+"%",Alltrim(Str(ZAD->ZAD_DESC5))+"%"})      
        Endif

      Else  

      // Politica Comissao
      If  ZAD->ZAD_TPEST == "1" // 7%
        aAdd(aBrComi7, {TransForm(ZAD->ZAD_FXDE, "@E 999,999.99"),TransForm(ZAD->ZAD_FXATE, "@E 999,999.99"),Alltrim(Str(ZAD->ZAD_DESC1))+"%",Alltrim(Str(ZAD->ZAD_DESC2))+"%",Alltrim(Str(ZAD->ZAD_DESC3))+"%",Alltrim(Str(ZAD->ZAD_DESC4))+"%",Alltrim(Str(ZAD->ZAD_DESC5))+"%"})
      ElseIf ZAD->ZAD_TPEST == "2" // 12%
        aAdd(aBrComi12, {TransForm(ZAD->ZAD_FXDE, "@E 999,999.99"),TransForm(ZAD->ZAD_FXATE, "@E 999,999.99"),Alltrim(Str(ZAD->ZAD_DESC1))+"%",Alltrim(Str(ZAD->ZAD_DESC2))+"%",Alltrim(Str(ZAD->ZAD_DESC3))+"%",Alltrim(Str(ZAD->ZAD_DESC4))+"%",Alltrim(Str(ZAD->ZAD_DESC5))+"%"})
      ElseIf ZAD->ZAD_TPEST == "3" // 18%
        aAdd(aBrComi18, {TransForm(ZAD->ZAD_FXDE, "@E 999,999.99"),TransForm(ZAD->ZAD_FXATE, "@E 999,999.99"),Alltrim(Str(ZAD->ZAD_DESC1))+"%",Alltrim(Str(ZAD->ZAD_DESC2))+"%",Alltrim(Str(ZAD->ZAD_DESC3))+"%",Alltrim(Str(ZAD->ZAD_DESC4))+"%",Alltrim(Str(ZAD->ZAD_DESC5))+"%"})      
      Endif

    Endif  

  Endif  

    ZAD->(dbSkip())
  Enddo

  if Len(aBrDesc18) == 0
    aBrDesc18 := {{ '' , '' , '', '' , '', '', ''}}
  Endif

  if Len(aBrDesc12) == 0
    aBrDesc12 := {{ '' , '' , '', '' , '', '', ''}}
  Endif

  If Len(aBrDesc7)  == 0
    aBrDesc7  := {{ '' , '' , '', '' , '', '', ''}}
  Endif  
     
  oBrDesc18:SetArray(aBrDesc18)
  oBrDesc12:SetArray(aBrDesc12)
  oBrDesc7 :SetArray(aBrDesc7)
  
  oBrDesc18:bLine  := {||{  aBrDesc18[oBrDesc18:nAt,01],;
                            aBrDesc18[oBrDesc18:nAt,02],;
                            aBrDesc18[oBrDesc18:nAt,03],;
                            aBrDesc18[oBrDesc18:nAt,04],;
                            aBrDesc18[oBrDesc18:nAt,05],;
                            aBrDesc18[oBrDesc18:nAt,06],;
                            aBrDesc18[oBrDesc18:nAt,07];
                          }}    

  oBrDesc12:bLine  := {||{  aBrDesc12[oBrDesc12:nAt,01],;
                            aBrDesc12[oBrDesc12:nAt,02],;
                            aBrDesc12[oBrDesc12:nAt,03],;
                            aBrDesc12[oBrDesc12:nAt,04],;
                            aBrDesc12[oBrDesc12:nAt,05],;
                            aBrDesc12[oBrDesc12:nAt,06],;
                            aBrDesc12[oBrDesc12:nAt,07];
                          }}    

  oBrDesc7:bLine   := {||{  aBrDesc7[oBrDesc7:nAt,01],;
                            aBrDesc7[oBrDesc7:nAt,02],;
                            aBrDesc7[oBrDesc7:nAt,03],;
                            aBrDesc7[oBrDesc7:nAt,04],;
                            aBrDesc7[oBrDesc7:nAt,05],;
                            aBrDesc7[oBrDesc7:nAt,06],;
                            aBrDesc7[oBrDesc7:nAt,07];
                          }}                             

  // Politica Comissionamento
  oBrComi18  := TCBrowse():New(002, 002, 300, 175, , {'Faixa De', 'Faixa Ate', 'Desc1','Desc2','Desc3','Desc4','Desc5' }, {60,60,30,30,30,30,30}, oFldComi:aDialogs[1], , , , , , , , , , , , .F., , .T., , .F., , ,)
  oBrComi12  := TCBrowse():New(002, 002, 300, 175, , {'Faixa De', 'Faixa Ate', 'Desc1','Desc2','Desc3','Desc4','Desc5' }, {60,60,30,30,30,30,30}, oFldComi:aDialogs[2], , , , , , , , , , , , .F., , .T., , .F., , ,)
  oBrComi7   := TCBrowse():New(002, 002, 300, 175, , {'Faixa De', 'Faixa Ate', 'Desc1','Desc2','Desc3','Desc4','Desc5' }, {60,60,30,30,30,30,30}, oFldComi:aDialogs[3], , , , , , , , , , , , .F., , .T., , .F., , ,)

  if Len(aBrComi18) == 0
    aBrComi18 := {{ '' , '' , '', '' , '', '', ''}}
  Endif

  if Len(aBrComi12) == 0
    aBrComi12 := {{ '' , '' , '', '' , '', '', ''}}
  Endif

  if Len(aBrComi7) == 0
    aBrComi7 := {{ '' , '' , '', '' , '', '', ''}}
  Endif
    
  oBrComi18 :SetArray(aBrComi18)
  oBrComi12 :SetArray(aBrComi12)
  oBrComi7  :SetArray(aBrComi7)
   
    
  oBrComi18:bLine  := {||{  aBrComi18[oBrComi18:nAt,01],;
                            aBrComi18[oBrComi18:nAt,02],;
                            aBrComi18[oBrComi18:nAt,03],;
                            aBrComi18[oBrComi18:nAt,04],;
                            aBrComi18[oBrComi18:nAt,05],;
                            aBrComi18[oBrComi18:nAt,06],;
                            aBrComi18[oBrComi18:nAt,07];
                          }}    

  oBrComi12:bLine  := {||{  aBrComi12[oBrComi12:nAt,01],;
                            aBrComi12[oBrComi12:nAt,02],;
                            aBrComi12[oBrComi12:nAt,03],;
                            aBrComi12[oBrComi12:nAt,04],;
                            aBrComi12[oBrComi12:nAt,05],;
                            aBrComi12[oBrComi12:nAt,06],;
                            aBrComi12[oBrComi12:nAt,07];
                          }}                                

  oBrComi7:bLine   := {||{  aBrComi7[oBrComi7:nAt,01],;
                            aBrComi7[oBrComi7:nAt,02],;
                            aBrComi7[oBrComi7:nAt,03],;
                            aBrComi7[oBrComi7:nAt,04],;
                            aBrComi7[oBrComi7:nAt,05],;
                            aBrComi7[oBrComi7:nAt,06],;
                            aBrComi7[oBrComi7:nAt,07];
                          }}                                                            

   
return()

Static Function Calcular(cPedido)
Local VlUnTab    := 0
Local VlTotal    := 0
Local SmTotal    := 0
Local SmDupli    := 0
Local VlDesc     := 0
Local cProdEst 

dbselectarea("SC6")
dbsetorder(1) 
SC6->( DbSeek( xFilial("SC6") + PadR(cPedido, tamsx3('C6_NUM') [1]) ) )

  While SC6->(!eof()) .AND. (cPedido == SC6->C6_NUM)
    
    SB1->(DbSeek(xFilial("SB1")+PadR(SC6->C6_PRODUTO, tamsx3('C6_PRODUTO') [1])))
    cProdEst := Iif( SB1->B1_ESTOQUE == "S", .T., .F. )
    
    If !cProdEst
      DbSelectArea("SB5")
        If SB5->( DbSeek( xFilial("SB5") + SC6->C6_PRODUTO ) )
          VlUnTab := SB5->B5_PRV2
        Endif
    Else
      VlUnTab := SB1->B1_PRV1
    Endif

    VlTotal := (VlUnTab * SC6->C6_QTDVEN)
    SmTotal := SmTotal + VlTotal

    SmDupli := SmDupli + SC6->C6_VALOR
    SC6->(dbSkip())
  Enddo

  VlDesc := IIF( SmTotal > 0, ROUND( ( 1 - ( SmDupli / SmTotal ) ) * 100, 2 ), 0 ) 

return(VlDesc)


