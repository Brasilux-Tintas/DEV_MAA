#include "protheus.ch"
#include "topconn.ch"
#include "winapi.ch"
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
#Translate MSGBOX( => IW_MsgBox(
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
  ฑฑบPrograma  ณ BRSEN002 บAutor  ณ                    บ Data ณ  13/09/04   บฑฑ
  ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
  ฑฑบDesc.     ณ Programa para cadastramento de rotinas e acessos.          บฑฑ
  ฑฑบ          ณ                                                            บฑฑ
  ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
  ฑฑบUso       ณ BRASILUX                                                   บฑฑ
  ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
  ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
  ฑฑณ   Data   ณ  BOPS  ณ Programador ณAlteracao                            ณฑฑ
  ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
  ฑฑณ 13/09/04 ณ XXXXXX ณ GUSTAVO     ณ Inicio de desenvolvimento.          ณฑฑ
  ฑฑณ          ณ        ณ             ณ                                     ณฑฑ
  ฑฑณ          ณ        ณ             ณ                                     ณฑฑ
  ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ*/
User Function BRSEN002()
     //Local   nPos       
     

          
     Private cCadastro := "Cadastro de Rotinas x Acessos"
     Private cCodUsr   := RetCodUsr()
     Private aRotina   := {	{ OemToAnsi("&Pesquisar")            , 'AxPesqui'     , 0, 1} ,;
                            { OemToAnsi("&Visualizar")           , 'U_SEN002_1(1)', 0, 2} ,;
                            { OemToAnsi("&Incluir")              , 'U_SEN002_1(2)', 0, 3} ,;
                            { OemToAnsi("&Alterar")              , 'U_SEN002_1(3)', 0, 3} ,;
                            { OemToAnsi("&Excluir")              , 'U_SEN002_1(4)', 0, 4} ,;
                            { OemToAnsi("&Usuแrios")             , 'U_SEN002_2(1)', 0, 5} ,;
							{ OemToAnsi("Transferir Permissao")  , 'U_validusr', 0, 5} }
	
   if PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) <> 0 
      MsgBox("Acesso nใo autorizado!---->"+funname(),"Aten็ใo","Alert")
      return 
    endif
    
     DbSelectArea("SZY")
     DbSetOrder(1)

     mBrowse( 6,1,22,75,"SZY",,,,,,)
Return

User Function SEN002_1(nOpc)
     Local aCpoEnChoice := {"ZY_ROTINA", "ZY_NOMEROT", "ZY_DTINCLU", "ZY_USERINC", "ZY_DTALTER", "ZY_USERALT", "ZY_ITEM" }
     Local aAltEnChoice := Iif(nOpc == 2, {"ZY_ROTINA", "ZY_NOMEROT"}, Iif(nOpc == 3, {"ZY_NOMEROT"}, {} ) )
     Local aAltGetDados := {"ZY_NOMACS"}
     Local nReg         := SZM->(Recno())
     Local nOpcE        := Iif(nOpc == 1 .or. nOpc == 4, 2, 3)
     Local nOpcA        := 0
     Local lVirtual     := .t.
     Local bCampo       := {|nCpo| Field(nCpo)}
     Local nY
     Local cFieldOk     := Iif( nOpc == 1 .or. nOpc == 4, "AllwaysTrue()", "AllwaysTrue()" )
     Local cLinOk       := Iif( nOpc == 1 .or. nOpc == 4, "AllwaysTrue()", "AllwaysTrue()" )
     Local cTudoOk      := Iif( nOpc == 1 .or. nOpc == 4, "AllwaysTrue()", "AllwaysTrue()" )
     Private nOpcX      := Iif(nOpc == 1 .or. nOpc == 4, 2, 3)
     Private aHeader    := {}
     Private aCols      := {}
     Private nLinhas    := 10
     Private aTELA      := Array(0,0)
     Private aGets      := Array(0)
     
     For nY := 1 TO LEN(aCpoEnChoice)
         M->&(EVAL(bCampo, nY)) := FieldGet(nY)
     Next
     If nOpc == 2
        M->ZY_ROTINA  := CriaVar("ZY_ROTINA")
        M->ZY_NOMEROT := CriaVar("ZY_NOMEROT")
        M->ZY_DTINCLU := CriaVar("ZY_DTINCLU")
        M->ZY_USERINC := CriaVar("ZY_USERINC")
        M->ZY_DTALTER := CriaVar("ZY_DTALTER")
        M->ZY_USERALT := CriaVar("ZY_USERALT")
        M->ZY_ITEM    := CriaVar("ZY_ITEM")
        M->ZY_NOMACS  := CriaVar("ZY_NOMACS")
     Else
        M->ZY_ROTINA  := SZY->ZY_ROTINA
        M->ZY_NOMEROT := SZY->ZY_NOMEROT
        M->ZY_DTINCLU := SZY->ZY_DTINCLU
        M->ZY_USERINC := SZY->ZY_USERINC
        M->ZY_DTALTER := SZY->ZY_DTALTER
        M->ZY_USERALT := SZY->ZY_USERALT
        M->ZY_ITEM    := SZY->ZY_ITEM
        M->ZY_NOMACS  := SZY->ZY_NOMACS
     Endif
     fMonHea(aHeader)
     fMonCol(@aCols, aHeader, nOpc, SZY->ZY_ROTINA)
     DEFINE MSDIALOG oDlg FROM 000,000 TO 023,072 TITLE OemToAnsi("Rotinas x Acessos") OF oMainwnd
            EnChoice("SZY", nReg, nOpcE,,,,aCpoEnchoice, {015, 001, 064, 280}, aAltEnchoice, 3,,,,,, lVirtual)
            
            oGetD := MsGetDados():New( 066, 001, 170, 280, nOpcE, cLinOk, cTudoOk, "", .T., aAltGetDados, 2, , nLinhas, cFieldOk )
            
            oDlg:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     ACTIVATE MSDIALOG oDlg VALID .T. ON INIT fMonEnc( {||nOpca := 1, Iif(obrigatorio(aGets,aTela), odlg:End(), nOpca := 0)}, {||odlg:End()}, oDlg) CENTERED
     If nOpca == 1
        If nOpc == 2 //Inclusใo
           For nY := 1 To Len(aCols)
               If !aCols[nY][Len(aHeader)+1]
                  RecLock("SZY", .t.)
                     SZY->ZY_FILIAL  := xFilial("SZY")
                     SZY->ZY_ROTINA  := M->ZY_ROTINA
                     SZY->ZY_NOMEROT := M->ZY_NOMEROT
                     SZY->ZY_DTINCLU := M->ZY_DTINCLU
                     SZY->ZY_USERINC := M->ZY_USERINC
                     SZY->ZY_ITEM    := aCols[nY][1]
                     SZY->ZY_NOMACS  := aCols[nY][2]
                  MsUnLock()
               Endif
           Next  
        ElseIf nOpc == 3 //Altera็ใo
               For nY := 1 To Len(aCols)
                   If !aCols[nY][Len(aHeader)+1]
                      DbSelectArea("SZY")
                      DbSetOrder(2)
                      DbSeek(xFilial("SZY")+M->ZY_ROTINA+aCols[nY][1],.t.)
                      If Found()
                         RecLock("SZY", .f.)
                              SZY->ZY_NOMEROT := M->ZY_NOMEROT
                              SZY->ZY_DTALTER := dDataBase
                              SZY->ZY_USERALT := cUsername
                              SZY->ZY_ITEM    := aCols[nY][1]
                              SZY->ZY_NOMACS  := aCols[nY][2]
                      Else
                         RecLock("SZY", .t.)
                            SZY->ZY_FILIAL  := xFilial("SZY")
                            SZY->ZY_ROTINA  := M->ZY_ROTINA
                            SZY->ZY_NOMEROT := M->ZY_NOMEROT
                            SZY->ZY_DTINCLU := M->ZY_DTINCLU
                            SZY->ZY_USERINC := M->ZY_USERINC
                            SZY->ZY_ITEM    := aCols[nY][1]
                            SZY->ZY_NOMACS  := aCols[nY][2]
                      Endif
                      MsUnLock()
                   Else
                      DbSelectArea("SZY")
                      DbSetOrder(2)
                      DbSeek(xFilial("SZY")+M->ZY_ROTINA+aCols[nY][1],.t.)
                      If Found()
                         RecLock("SZY", .f.)
                           Delete
                         MsUnLock()
                      Endif
                   Endif
               Next  
        ElseIf nOpc == 4 //Exclusใo
               If MsgYesNo("Deseja realmente excluir os acessos dessa rotina ?","Aten็ใo...")
                  For nY := 1 To Len(aCols)
                      If !aCols[nY][Len(aHeader)+1]
                         DbSelectArea("SZY")
                         DbSetOrder(2)
                         DbSeek(xFilial("SZY")+M->ZY_ROTINA+aCols[nY][1],.t.)
                         If Found()
                            RecLock("SZY", .f.)
                               Delete
                            MsUnLock()
                         Endif
                      Endif
                  Next
               Endif
        Endif
     Endif
Return Nil

Static Function fMonEnc(bOk, bCancel, oDlgPad)
       Local oBar

       DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlgPad
       DEFINE BUTTON RESOURCE "S4WB005N" OF oBar       ACTION NaoDisp()           TOOLTIP OemToAnsi("Recortar")
       DEFINE BUTTON RESOURCE "S4WB006N" OF oBar       ACTION NaoDisp()           TOOLTIP OemToAnsi("Copiar")
       DEFINE BUTTON RESOURCE "S4WB007N" OF oBar       ACTION NaoDisp()           TOOLTIP OemToAnsi("Colar")
       DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora()       TOOLTIP OemToAnsi("Calculadora...")
       DEFINE BUTTON RESOURCE "S4WB009N" OF oBar       ACTION Agenda()            TOOLTIP OemToAnsi("Agenda...")
       DEFINE BUTTON RESOURCE "S4WB010N" OF oBar       ACTION OurSpool()          TOOLTIP OemToAnsi("Gerenciador de Impressใo...")
       DEFINE BUTTON RESOURCE "S4WB016N" OF oBar GROUP ACTION HelProg()           TOOLTIP OemToAnsi("Help de Programa...")
       DEFINE BUTTON oBtOk RESOURCE "OK" OF oBar GROUP ACTION ( lOk := Eval(bOk)) TOOLTIP OemToAnsi("<Ctrl + O>")
       SetKEY(15,oBtOk:bAction)  // K_CTRL_O

       DEFINE BUTTON oBtCan RESOURCE "CANCEL" OF oBar ACTION ( Eval(bCancel))     TOOLTIP OemToAnsi("<Ctrl + X>")
       SetKEY(24,oBtCan:bAction) // K_CTRL_X

       oBar:bRClicked := { || AllwaysTrue() }
Return Nil

Static Function fMonHea(aHeader)
       Local nUsado := 0
       Local _lOpen     := .F. //LGS#20200211 - Adequa็ใo para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200211 - Adequa็ใo para release 12.1.25

       // ABERTURA DO DICIONมRIO SX3 - LGS#20200211 - Adequa็ใo para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0
       If !_lOpen //LGS#20200211 - Adequa็ใo para release 12.1.25
          MessageBox( "Nใo foi possํvel abrir dicionแrio de dados.", "Aten็ใo", 16 )
          Return
       Endif

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAวรO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SZY")
       While !Eof() .And. (X3_ARQUIVO == "SZY")
             If TRIM(SX3->X3_CAMPO) $ 'ZY_ITEM.ZY_NOMACS'
                nUsado += 1
                AADD(aHeader, { Trim(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
             Endif
             DbSkip()
       Enddo*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("SZY") )
       While !Eof() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SZY")
             If TRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZY_ITEM.ZY_NOMACS'
                nUsado += 1
                AADD(aHeader, { Trim( ( _cAliasSX3 )->( X3_TITULO ) ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
             Endif
             DbSkip()
       Enddo
       /********************************************************************************************************************************/
       DbSelectArea( _cAliasSX3 )
       DbCloseArea()      
Return

Static Function fMonCol(aCols, aHeader, nOpc, cRotina)
       Local nUsado := Len(aHeader)
       Local cQry1  := ""
       Local nX, nY
       If !nOpc == 2
          cQry1 += "SELECT * "
          cQry1 += "FROM "+RetSqlName("SZY")+" SZY "
          cQry1 += "WHERE SZY.ZY_FILIAL  = '"+xFilial("SZY")+"' "
          cQry1 += "  AND SZY.D_E_L_E_T_ = '' "
          cQry1 += "  AND SZY.ZY_ROTINA  = '"+cRotina+"' "
          TCQuery cQry1 ALIAS "TCQ" NEW
          DbSelectArea("TCQ")
          DbGoTop()
          While !Eof()
                AADD(aCols, Array(nUsado + 1))
                For nX := 1 To nUsado
                    If Alltrim(aHeader[nX][2]) $ 'ZY_ITEM'
                       aCols[Len(aCols)][nX] := TCQ->ZY_ITEM
                    ElseIf Alltrim(aHeader[nX][2]) $ 'ZY_NOMACS'
                           aCols[Len(aCols)][nX] := TCQ->ZY_NOMACS
                    Endif
                Next
                aCols[Len(aCols)][nUsado + 1] := .F.
                DbSelectArea("TCQ")
                DbSkip()
          Enddo
          DbSelectArea("TCQ")
          DbCloseArea()
          If nOpc == 3
             For nY := 1 TO 10
                 nPos := aScan(aCols, {|x| x[1] == StrZero(nY,2)})
                 If nPos == 0
                    AADD(aCols, Array(nUsado + 1) )
                    For nX := 1 To Len(aHeader)
                        aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2])
                    Next
                    aCols[Len(aCols)][1] := StrZero(nY, 2)
                    aCols[Len(aCols)][Len(aHeader) + 1] := .F.
                 Endif
             Next                                    	
          Endif
       Else
          For nY := 1 To 10
              AADD(aCols, Array(nUsado + 1) )
              For nX := 1 To nUsado
                  aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2])
              Next
              aCols[Len(aCols)][1] := StrZero(nY, 2) //Item na inclusใo
              aCols[Len(aCols)][nUsado + 1] := .F.
          Next
       Endif
Return

User Function SEN002_2(nOpc)
     Local cRotina  := SZY->ZY_ROTINA+'  '
     //Local cNomRot  := SZY->ZY_NOMEROT
     Local cQry1    := ""
     Local nOpca    := 0
     Local aAcs     := {}
     Local aHeader  := {}
     Local aDadUsr  := {}
     Local nY
     Local cUser  := CriaVar("ZW_USUARIO")
     Local cDept  := CriaVar("ZW_DEPTO")
     
     cQry1 += "SELECT * "
     cQry1 += "FROM "+RetSqlName("SZY")+" SZY "
     cQry1 += "WHERE SZY.D_E_L_E_T_ = '' "
     cQry1 += "  AND SZY.ZY_FILIAL  = '"+xFilial("SZY")+"' "
     cQry1 += "  AND SZY.ZY_ROTINA  = '"+cRotina+"' "
     cQry1 += "ORDER BY SZY.ZY_ITEM "
     TCQuery cQry1 ALIAS "TCQ" NEW
     DbSelectArea("TCQ")
     DbGoTop()
     While !Eof()
           aadd(aAcs, { TCQ->ZY_NOMACS, 'oAcs'+TCQ->ZY_ITEM, .f. })
           DbSelectArea("TCQ")
           DbSkip()
     Enddo
     DbSelectArea("TCQ")
     DbCloseArea()
     aadd(aHeader,"Usuแrio")
     aadd(aHeader,"Nome")
     aadd(aHeader,"Acessos")
     
     cQry1 := ""
     cQry1 += "SELECT * "
     cQry1 += "FROM "+RetSqlName("SZW")+" SZW "
     cQry1 += "WHERE SZW.ZW_FILIAL = '"+xFilial("SZW")+"' "
     cQry1 += "  AND SZW.ZW_ROTINA = '"+cRotina+"' "
     cQry1 += "  AND SZW.D_E_L_E_T_ = '' "
     TCQUERY cQry1 ALIAS "TCQ" NEW
     DbSelectArea("TCQ")
     DbGoTop()
     While !Eof()
           PswOrder(1)
           If PswSeek(TCQ->ZW_USUARIO)
              aRet := PswRet(1)
              aadd(aDadUsr,{ Transform(TCQ->ZW_USUARIO, X3Picture(SZW->ZW_USUARIO)),;
                             aRet[1][2], ;
                             Transform(TCQ->ZW_ACESSOS, X3Picture(SZW->ZW_ACESSOS)),;
                             Transform(TCQ->ZW_EMPFIL, X3Picture(SZW->ZW_EMPFIL)),;
                             Transform(TCQ->ZW_DEPTO, X3Picture(SZW->ZW_DEPTO)),;
                             Iif(SubStr(TCQ->ZW_ACESSOS, 9, 1) == '*', Transform("SIM","@!"), Transform("NรO","@!") ) })
           Endif
           DbSelectArea("TCQ")
           DbSkip()
     Enddo
     DbSelectArea("TCQ")
     DbCloseArea()

     If Len(aDadUsr) == 0
        aadd(aDadUsr,{space(06), space(15), space(10), space(05), space(03), space(03)})
     Endif

     DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Cadastro de Acessos x Usuแrio") FROM 9,0 TO 23,89 OF oMainWnd
            @ 030,001 GROUP oGrp3 TO 090,198   LABEL  OemToAnsi('')                             PIXEL OF oDlg1
            @ 035,005 LISTBOX oUsrCad FIELDS TITLE ""                                   SIZE 190,66 	            PIXEL OF oDlg1
            /*******************************************************************************************************************************/
            @ 025,200 GROUP oGrp1 TO 030,350   LABEL  OemToAnsi('')                                                 PIXEL OF oDlg1
            @ 034,205 SAY OemToAnsi("Usuแrio:")                                         SIZE 030,09 COLOR CLR_HBLUE PIXEL OF oDlg1
            @ 033,240 MSGET oUser    VAR cUser          PICTURE "999999"      WHEN .T.  SIZE 010,09                 PIXEL OF oDlg1 F3 "SZH"
            /*******************************************************************************************************************************/
            @ 034,275 SAY OemToAnsi("Depto.: ")                                         SIZE 030,09 COLOR CLR_HBLUE PIXEL OF oDlg1
            @ 033,310 MSGET oDept    VAR cDept          PICTURE "@!"          WHEN .T.  SIZE 010,09                 PIXEL OF oDlg1 //F3 "XZY"
            /*******************************************************************************************************************************/
            @ 047,200 GROUP oGrp2 TO 100,350     LABEL  OemToAnsi('')                                               PIXEL OF oDlg1
            @ 050,205 CHECKBOX aAcs[01][2] VAR aAcs[01][3] PROMPT OemToAnsi(aAcs[01][1])    SIZE 055,10             PIXEL OF oDlg1
            @ 050,270 CHECKBOX aAcs[02][2] VAR aAcs[02][3] PROMPT OemToAnsi(aAcs[02][1])    SIZE 055,10             PIXEL OF oDlg1
            @ 060,205 CHECKBOX aAcs[03][2] VAR aAcs[03][3] PROMPT OemToAnsi(aAcs[03][1])    SIZE 055,10             PIXEL OF oDlg1
            @ 060,270 CHECKBOX aAcs[04][2] VAR aAcs[04][3] PROMPT OemToAnsi(aAcs[04][1])    SIZE 055,10             PIXEL OF oDlg1
            @ 070,205 CHECKBOX aAcs[05][2] VAR aAcs[05][3] PROMPT OemToAnsi(aAcs[05][1])    SIZE 055,10             PIXEL OF oDlg1
            @ 070,270 CHECKBOX aAcs[06][2] VAR aAcs[06][3] PROMPT OemToAnsi(aAcs[06][1])    SIZE 055,10             PIXEL OF oDlg1
            @ 080,205 CHECKBOX aAcs[07][2] VAR aAcs[07][3] PROMPT OemToAnsi(aAcs[07][1])    SIZE 055,10             PIXEL OF oDlg1
            @ 080,270 CHECKBOX aAcs[08][2] VAR aAcs[08][3] PROMPT OemToAnsi(aAcs[08][1])    SIZE 055,10             PIXEL OF oDlg1
            @ 090,205 CHECKBOX aAcs[09][2] VAR aAcs[09][3] PROMPT OemToAnsi(aAcs[09][1])    SIZE 055,10             PIXEL OF oDlg1
            @ 090,270 CHECKBOX aAcs[10][2] VAR aAcs[10][3] PROMPT OemToAnsi(aAcs[10][1])    SIZE 055,10             PIXEL OF oDlg1
            For nY := 1 TO 10
                If Empty(aAcs[nY][1])
                   aAcs[nY][2]:lVisible := .f.
                Endif
            Next
            oUsrCad:aHeaders := aHeader
            oUsrCad:SetArray(aDadUsr)
            oUsrCad:bLine    := {|| oUsrCad:aArray[oUsrCad:nAt] }
            oUser:cName := "cUser"
            oUser:bLostFocus := { ||If(fValida(1, cUser), .t., SetFocus(oUser:hWnd)) }

     ACTIVATE MSDIALOG oDlg1 ON INIT fEnchBar(oDlg1, {||nOpca := 1, oDlg1:End()},{||nOpca := 0, oDlg1:End()}, cRotina) CENTERED
     If nOpca == 1
        If !Empty(cUser)
           DbSelectArea("SZW")
           DbSetOrder(4)
           DbSeek(xFilial("SZW")+cRotina+cUser+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), .t.)
           If Found()
              If MsgYesNo("Usuแrio jแ existe, deseja alterar ?", "Aten็ใo...")
                 RecLock("SZW", .f.)
                    SZW->ZW_ACESSOS := If(aAcs[01][3],'*',space(1))+If(aAcs[02][3],'*',space(1))+If(aAcs[03][3],'*',space(1))+If(aAcs[04][3],'*',space(1))+If(aAcs[05][3],'*',space(1))+If(aAcs[06][3],'*',space(1))+If(aAcs[07][3],'*',space(1))+If(aAcs[08][3],'*',space(1))+If(aAcs[09][3],'*',space(1))+If(aAcs[10][3],'*',space(1))
                    SZW->ZW_DTALTER := dDataBase
                    SZW->ZW_USERALT := cUsername
                    SZW->ZW_DEPTO   := cDept
              Endif
           Else
              RecLock("SZW", .t.)
                 SZW->ZW_FILIAL  := xFilial("SZW")
                 SZW->ZW_ROTINA  := cRotina
                 SZW->ZW_USUARIO := cUser
                 SZW->ZW_EMPFIL  := SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2)
                 SZW->ZW_ACESSOS := If(aAcs[01][3],'*',space(1))+If(aAcs[02][3],'*',space(1))+If(aAcs[03][3],'*',space(1))+If(aAcs[04][3],'*',space(1))+If(aAcs[05][3],'*',space(1))+If(aAcs[06][3],'*',space(1))+If(aAcs[07][3],'*',space(1))+If(aAcs[08][3],'*',space(1))+If(aAcs[09][3],'*',space(1))+If(aAcs[10][3],'*',space(1))
                 SZW->ZW_DTINCLU := dDataBase
                 SZW->ZW_USERINC := cUsername
                 SZW->ZW_DEPTO   := cDept
           Endif
           MsUnLock()
        Endif
     Endif
Return Nil

Static Function fEnchBar(oDlg, bOk, bCancel, cRotina)
       Local aButtons
       aButtons := { {"S4WB005N" ,{||fEdtAcs(cRotina, .f.) },"Editar Acessos"  } }
       aadd(aButtons,{"EXCLUIR"  ,{||fEdtAcs(cRotina, .t.) },"Excluir Acessos"} )
Return(EnchoiceBar(oDlg,bOK,bcancel,,aButtons))

Static Function fEdtAcs(cRotina, lExcl)
       Local nOpcb    := 0
       Local aAcsE    := {}
       Local cQry1    := ""
       Local cEUser := oUsrCad:aArray[oUsrCad:nAt][1]
       Local cEDept := oUsrCad:aArray[oUsrCad:nAt][5]
       Local nY
     
       cQry1 += "SELECT * "
       cQry1 += "FROM "+RetSqlName("SZY")+" SZY "
       cQry1 += "WHERE SZY.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZY.ZY_FILIAL  = '"+xFilial("SZY")+"' "
       cQry1 += "  AND SZY.ZY_ROTINA  = '"+cRotina+"' "
       cQry1 += "ORDER BY SZY.ZY_ITEM "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             aadd(aAcsE, { TCQ->ZY_NOMACS, 'oAcs'+TCQ->ZY_ITEM, Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][3], Val(TCQ->ZY_ITEM), 01) == '*', .t., .f.) })
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
     
       If !Empty(Alltrim(oUsrCad:aArray[oUsrCad:nAt][1]))
          DEFINE MSDIALOG oDlgEdt TITLE OemToAnsi("Edita Acessos") From 9,0 TO 23,42 OF oMainWnd
                 @ 012,001 GROUP oEGrp1 TO 030,154   LABEL  OemToAnsi('')                                                        PIXEL OF oDlgEdt
                 @ 017,005 SAY OemToAnsi("Usuแrio:")                                                SIZE 030,09 COLOR CLR_HBLUE  PIXEL OF oDlgEdt
                 @ 016,040 MSGET oEUser    VAR cEUser         PICTURE "999999"      WHEN .F.        SIZE 010,09                  PIXEL OF oDlgEdt F3 "USR"
                 /*******************************************************************************************************************************/
                 @ 017,075 SAY OemToAnsi("Depto.: ")                                                SIZE 030,09 COLOR CLR_HBLUE  PIXEL OF oDlgEdt
                 @ 016,110 MSGET oEDept    VAR cEDept         PICTURE "@!"          WHEN .T.        SIZE 010,09                  PIXEL OF oDlgEdt F3 "XZY"
                 /*******************************************************************************************************************************/
                 @ 032,001 GROUP oEGrp2 TO 089,154   LABEL  OemToAnsi('Acessos')                                                 PIXEL OF oDlgEdt
                 @ 037,005 CHECKBOX aAcsE[01][2] VAR aAcsE[01][3] PROMPT OemToAnsi(aAcsE[01][1])    SIZE 055,10                  PIXEL OF oDlgEdt
                 @ 037,070 CHECKBOX aAcsE[02][2] VAR aAcsE[02][3] PROMPT OemToAnsi(aAcsE[02][1])    SIZE 055,10                  PIXEL OF oDlgEdt
                 @ 047,005 CHECKBOX aAcsE[03][2] VAR aAcsE[03][3] PROMPT OemToAnsi(aAcsE[03][1])    SIZE 055,10                  PIXEL OF oDlgEdt
                 @ 047,070 CHECKBOX aAcsE[04][2] VAR aAcsE[04][3] PROMPT OemToAnsi(aAcsE[04][1])    SIZE 055,10                  PIXEL OF oDlgEdt
                 @ 057,005 CHECKBOX aAcsE[05][2] VAR aAcsE[05][3] PROMPT OemToAnsi(aAcsE[05][1])    SIZE 055,10                  PIXEL OF oDlgEdt
                 @ 057,070 CHECKBOX aAcsE[06][2] VAR aAcsE[06][3] PROMPT OemToAnsi(aAcsE[06][1])    SIZE 055,10                  PIXEL OF oDlgEdt
                 @ 067,005 CHECKBOX aAcsE[07][2] VAR aAcsE[07][3] PROMPT OemToAnsi(aAcsE[07][1])    SIZE 055,10                  PIXEL OF oDlgEdt
                 @ 067,070 CHECKBOX aAcsE[08][2] VAR aAcsE[08][3] PROMPT OemToAnsi(aAcsE[08][1])    SIZE 055,10                  PIXEL OF oDlgEdt
                 @ 077,005 CHECKBOX aAcsE[09][2] VAR aAcsE[09][3] PROMPT OemToAnsi(aAcsE[09][1])    SIZE 055,10                  PIXEL OF oDlgEdt
                 @ 077,070 CHECKBOX aAcsE[10][2] VAR aAcsE[10][3] PROMPT OemToAnsi(aAcsE[10][1])    SIZE 055,10                  PIXEL OF oDlgEdt
                 For nY := 1 TO 10
                     If Empty(aAcsE[nY][1])
                        aAcsE[nY][2]:lVisible := .f.
                     Endif
                     If lExcl
                        aAcsE[nY][2]:bWhen := {||.f.}
                     Endif
                 Next
               
          ACTIVATE MSDIALOG oDlgEdt ON INIT EnchoiceBar(oDlgEdt,{|| nOpcb := 1, oDlgEdt:End() },{|| nOpcb := 0, oDlgEdt:End() }) CENTERED
          If nOpcb == 1
             If lExcl
                DbSelectArea("SZW")
                DbSetOrder(4)
                DbSeek(xFilial("SZW")+cRotina+cEUser+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2),.t.)
                If Found()
                   RecLock("SZW",.f.)
                      Delete
                   MsUnLock()
                   lUltReg := Iif((Len(oUsrCad:aArray) - 1) == 0, .t., .f.)
                   nNewTam := Iif((Len(oUsrCad:aArray) - 1) == 0, 1, (Len(oUsrCad:aArray) - 1))
                   If lUltReg
                      aadd(oUsrCad:aArray,{space(06), space(15), space(10), space(05), space(03), space(03)})
                   Endif
                   oUsrCad:aArray := aSize(aDel(oUsrCad:aArray,oUsrCad:nAt),nNewTam)
                Endif
             Else
                DbSelectArea("SZW")
                DbSetOrder(4)
                DbSeek(xFilial("SZW")+cRotina+cEUser+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2),.t.)
                If Found()
                   RecLock("SZW",.f.)
                      SZW->ZW_ACESSOS := If(aAcsE[01][3],'*',space(1))+If(aAcsE[02][3],'*',space(1))+If(aAcsE[03][3],'*',space(1))+If(aAcsE[04][3],'*',space(1))+If(aAcsE[05][3],'*',space(1))+If(aAcsE[06][3],'*',space(1))+If(aAcsE[07][3],'*',space(1))+If(aAcsE[08][3],'*',space(1))+If(aAcsE[09][3],'*',space(1))+If(aAcsE[10][3],'*',space(1))
                      SZW->ZW_DTALTER := dDataBase
                      SZW->ZW_USERALT := cUsername
                      SZW->ZW_DEPTO   := cEDept
                   MsUnLock()
                   oUsrCad:aArray[oUsrCad:nAt][3] := If(aAcsE[01][3],'*',space(1))+If(aAcsE[02][3],'*',space(1))+If(aAcsE[03][3],'*',space(1))+If(aAcsE[04][3],'*',space(1))+If(aAcsE[05][3],'*',space(1))+If(aAcsE[06][3],'*',space(1))+If(aAcsE[07][3],'*',space(1))+If(aAcsE[08][3],'*',space(1))+If(aAcsE[09][3],'*',space(1))+If(aAcsE[10][3],'*',space(1))
                   oUsrCad:aArray[oUsrCad:nAt][5] := cEDept
                   oUsrCad:aArray[oUsrCad:nAt][6] := If(aAcsE[09][3], 'SIM', 'NรO')
                Endif
             Endif
          Endif
       Else
          MsgBox("Nใo existe cadastro a ser editado.","Aten็ใo","Alert")
       Endif
Return
        
Static Function fValida(nValida, cUser)
       If nValida == 1
          If !Empty(cUser)
             PswOrder(1)
             If PswSeek(cUser)
                lRet := .t.
             Else
                lRet := .f.
                MsgBox("Usuแrio nใo cadastrado !","Aten็ใo","STOP")
             Endif
          Else
             lRet := .t.
          Endif
       Endif
Return(lRet)