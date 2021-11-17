#include "protheus.ch"
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
#include "sigawin.ch"
#include "colors.ch"
#include "font.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP048 º Autor ³ Luís Gustavo de Souza º Data ³ 20/02/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de produtos específico - somente para aparecer o  º±±
±±º          ³ peso específico dos produtos.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRPCP048()
     Private cCadastro := "Alteração do Cadastro de Produtos"
     Private aRotina := { {"Pesquisar" , 'AxPesqui'                      , 0, 1   },;
                          {"Visualizar", 'ExecBlock("PCP0481", .f., .f.)', 0, 2   },;
                          {"Alterar"   , 'ExecBlock("PCP0482", .f., .f.)', 0, 4, 2} }
     Private aCampos := { {"CÓDIGO", "B1_COD", "@!"} }
     Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
     Private cString := "SB1"
     Private cTable   :=""
     
     DbSelectArea("SB1")
     DbSetOrder(1)
     mBrowse( 06, 01, 22, 75, cString, , )
     //cTable:= RetSqlName("SB1")
     //TcRefresh(cTable)
Return

User Function PCP0481()
     Private oFont
     Private cPro     := SB1->B1_COD
     Private cDes     := SB1->B1_DESC
     Private nPes     := SB1->B1_PESOESP
     Private cLocPad  := SB1->B1_LOCPAD
     Private cRoteiro := SB1->B1_OPERPAD
     Private oDlg
     nOpc := 0
        
     DEFINE MSDIALOG oDlg FROM 00,00 TO 11,80 TITLE OemToAnsi( "Alteração do Cadastro de Produtos" ) OF oMainWnd
     DEFINE FONT oFont SIZE 9,0 BOLD
     
     @ 015, 003 TO 080,313
     @ 020, 020 SAY OemToAnsi( "Codigo: ")    SIZE 055,008 PIXEL OF oDlg
     @ 020, 125 SAY OemToAnsi( "Descrição: ") SIZE 025,008 PIXEL OF oDlg
     @ 040, 020 SAY OemToAnsi( "P. Especifico: ")    SIZE 035,008 PIXEL OF oDlg
     @ 040, 125 SAY OemToAnsi( "Loc Padrão: ") SIZE 030,008 PIXEL OF oDlg
     @ 040, 190 SAY OemToAnsi( "Roteiro: ")    SIZE 030,008 PIXEL OF oDlg
     
     @ 020, 065 MSGET oOP      Var cPro     Picture "@R 99999999999"   When .f. SIZE 050,008 of oDlg PIXEL
     @ 020, 160 MSGET oPro     Var cDes     Picture "@!"               When .f. SIZE 100,008 of oDlg PIXEL
     @ 040, 065 MSGET oPes     Var nPes     Picture "@E 999,999.99999" When .f. SIZE 050,008 of oDlg PIXEL
     @ 040, 160 MSGET oLocPad  Var cLocpad  Picture "@E 99"            When .f. SIZE 020,008 of oDlg PIXEL
     @ 040, 220 MSGET oRoteiro Var cRoteiro Picture "@E 99"            When .f. SIZE 020,008 of oDlg PIXEL     
     
     
     
     ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, { || nOpc := 1,oDlg:End() }, { || oDlg:End() } ) CENTERED
     If nOpc == 0
     ElseIf nOpc == 1
     Endif
Return

User Function PCP0482()
     Private oFont
     Private cPro	  := SB1->B1_COD
     Private cDes	  := SB1->B1_DESC
     Private nPes     := SB1->B1_PESOESP
     Private cLocPad  := SB1->B1_LOCPAD
     Private cRoteiro := SB1->B1_OPERPAD

     Private oDlg
     nOpc := 0
        
     DEFINE MSDIALOG oDlg FROM 00,00 TO 11,80 TITLE OemToAnsi( "Alteração do Cadastro de Produtos" ) OF oMainWnd
     DEFINE FONT oFont SIZE 9,0 BOLD

     @ 015, 003 TO 080,313
     @ 020, 020 SAY OemToAnsi( "Codigo: ")    SIZE 055,008 PIXEL OF oDlg
     @ 020, 125 SAY OemToAnsi( "Descrição: ") SIZE 025,008 PIXEL OF oDlg
     @ 040, 020 SAY OemToAnsi( "P. Especifico: ")    SIZE 035,008 PIXEL OF oDlg
     @ 040, 125 SAY OemToAnsi( "Loc Padrão: ") SIZE 030,008 PIXEL OF oDlg
     @ 040, 190 SAY OemToAnsi( "Roteiro: ")    SIZE 030,008 PIXEL OF oDlg
     
     @ 020, 065 MSGET oOP  Var cPro Picture "@R 99999999999"  When .f. SIZE 050,008 of oDlg PIXEL
     @ 020, 160 MSGET oPro Var cDes Picture "@!"              When .f. SIZE 100,008 of oDlg PIXEL
     @ 040, 065 MSGET oPes Var nPes Picture "@E 999,999.99999"         SIZE 050,008 of oDlg PIXEL
     @ 040, 160 MSGET oLocPad  Var cLocpad  Picture "@E 99"            SIZE 020,008 of oDlg PIXEL
     @ 040, 220 MSGET oRoteiro Var cRoteiro Picture "@E 99"            SIZE 020,008 of oDlg PIXEL     
     
     ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, { || nOpc := 1,oDlg:End() }, { || oDlg:End() } ) CENTERED
     If nOpc == 0
     ElseIf nOpc == 1
            RecLock("SB1",.f.)
               SB1->B1_PESOESP := nPes
               SB1->B1_LOCPAD  := cLocpad 
               SB1->B1_OPERPAD := cRoteiro	
            MsUnLock()
            DbSelectArea("SB1")
            DbSetOrder(1)
            DbSeek(xFilial("SB1")+SB1->B1_COD,.t.)
            If Found()
               If !(cNumEmp == "01010104")
                  If (SB1->B1_TIPO == "MP")
                     Alert("Atencao! O Programa ira' recalcular os Pesos Especificos"+chr(13)+;
                           "e podera' demorar! Nao tente interromper o processamento"+chr(13)+;
                           "pois podera' comprometer as estruturas de Produtos!")
                     U_CalcPesoEsp(SB1->B1_COD)     
                  Endif
               Endif
            Endif
     Endif
Return