#include "rwmake.ch"
#include "brsen001.ch"
#include "topconn.ch" 
#include "colors.ch"
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRSEN001 บAutor  ณ                    บ Data ณ  27/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para cadastrar os acessos dos usuแrios para rotinas บฑฑ
ฑฑบ          ณ especificas da Brasilux.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BRSEN001(cRotina)
     Local aHeader   := {}
     Local aDadUsr   := {}
     Local cQry1     := ""
     Local nOpca     := 0
     Private oUser, oEMFL, oUsrCad, oGrp1, oGrp2, oGrp3, oAcs1, oAcs2, oAcs3, oAcs4, oAcs5, oAcs6, oAcs7, oAcs8, oAcs9, oAcsA
     Private cUser   := CriaVar("ZW_USUARIO")
     Private cEMFL   := CriaVar("ZW_EMPFIL")
     Private lAcs1   := .f.
     Private lAcs2   := .f.
     Private lAcs3   := .f.
     Private lAcs4   := .f.
     Private lAcs5   := .f.
     Private lAcs6   := .f.
     Private lAcs7   := .f.
     Private lAcs8   := .f.
     Private lAcs9   := .t.
     Private lAcsA   := .f.
     cRotina         := Stuff(cRotina, Len(cRotina)+1, 10 - Len(cRotina), space(10 - Len(cRotina)))
     aadd(aHeader,"Usuแrio")
     aadd(aHeader,"Nome")
     aadd(aHeader,"Emp./Fil.")
     aadd(aHeader,"Acessos")
     aadd(aHeader,"Ativo?")
     
     cQry1 += "SELECT * "
     cQry1 += "FROM "+RetSqlName("SZW")+" SZW WITH (NOLOCK) "
     cQry1 += "WHERE SZW.ZW_FILIAL = '"+xFilial("SZW")+"' "
     cQry1 += "  AND SZW.ZW_ROTINA = '"+cRotina+"' "
     cQry1 += "  AND SZW.D_E_L_E_T_ = '' "
     
     TCQUERY cQry1 ALIAS "TCQ" NEW
     
     DbSelectArea("TCQ")
     DbGoTop()
     While !Eof()
           PswOrder(1)
           PswSeek(TCQ->ZW_USUARIO)
           aRet := PswRet(1)
           aadd(aDadUsr,{ Transform(TCQ->ZW_USUARIO,X3Picture(SZW->ZW_USUARIO)),;
                          aRet[1][2], ;
                          Transform(TCQ->ZW_EMPFIL,X3Picture(SZW->ZW_EMPFIL)),;
                          Transform(TCQ->ZW_ACESSOS,X3Picture(SZW->ZW_ACESSOS)),;
                          Iif(TCQ->ZW_ATIVO == "S", Transform("SIM","@!"),Transform("NรO","@!") ) })

           DbSelectArea("TCQ")
           DbSkip()
     Enddo
     DbSelectArea("TCQ")
     DbCloseArea()
     
     If Len(aDadUsr) == 0
        aadd(aDadUsr,{space(06), space(15), space(05), space(06), space(03)})
     Endif
     
     DEFINE MSDIALOG oDlg TITLE OemToAnsi("Cadastro de Acessos") FROM 9,0 TO 21,89 OF oMainWnd
            @ 012,001 GROUP oGrp3 TO 090,198   LABEL  OemToAnsi('Usuแrios Cadastrados')                             PIXEL OF oDlg
            @ 017,005 LISTBOX oUsrCad FIELDS TITLE ""                                   SIZE 190,066 	            PIXEL OF oDlg

            @ 012,200 GROUP oGrp1 TO 030,350   LABEL  OemToAnsi('')                                                 PIXEL OF oDlg
            @ 017,205 SAY OemToAnsi("Usuแrio:")                                         SIZE 030,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 016,240 MSGET oUser    VAR cUser          PICTURE "999999"      WHEN .T.  SIZE 010,09                 PIXEL OF oDlg F3 "USR"
            @ 017,275 SAY OemToAnsi("Emp./Fil.:")                                       SIZE 030,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 016,310 MSGET oEMFL    VAR cEMFL          PICTURE "@R 99/99"    WHEN .T.  SIZE 010,09                 PIXEL OF oDlg F3 "EMP"
            @ 032,200 GROUP oGrp2 TO 090,350   LABEL  OemToAnsi('Acessos')                                          PIXEL OF oDlg
            If cRotina $ 'BRFATX01  '
               @ 037,205 CHECKBOX oAcs1 VAR lAcs1 PROMPT OemToAnsi("Aprova Sintegra")    SIZE 055,10                 PIXEL OF oDlg
               @ 037,270 CHECKBOX oAcs2 VAR lAcs2 PROMPT OemToAnsi("Aprova Pedido")      SIZE 055,10                 PIXEL OF oDlg
               @ 047,205 CHECKBOX oAcs3 VAR lAcs3 PROMPT OemToAnsi("Aprova Cr้dito")     SIZE 055,10                 PIXEL OF oDlg
               @ 047,270 CHECKBOX oAcs4 VAR lAcs4 PROMPT OemToAnsi("Aprova Diretoria")   SIZE 055,10                 PIXEL OF oDlg
            ElseIf cRotina $ 'BRPCPX01  '
                   @ 037,205 CHECKBOX oAcs1 VAR lAcs1 PROMPT OemToAnsi("Gera revisใo PI")      SIZE 055,10                 PIXEL OF oDlg
                   @ 037,270 CHECKBOX oAcs2 VAR lAcs2 PROMPT OemToAnsi("Libera revisใo PI")    SIZE 055,10                 PIXEL OF oDlg
                   @ 047,205 CHECKBOX oAcs3 VAR lAcs3 PROMPT OemToAnsi("Gera revisใo PA")      SIZE 055,10                 PIXEL OF oDlg
                   @ 047,270 CHECKBOX oAcs4 VAR lAcs4 PROMPT OemToAnsi("Libera revisใo PA")    SIZE 055,10                 PIXEL OF oDlg
                   @ 057,205 CHECKBOX oAcs5 VAR lAcs5 PROMPT OemToAnsi("Libera็ใo diretoria")  SIZE 055,10                 PIXEL OF oDlg
                   @ 057,270 CHECKBOX oAcs6 VAR lAcs6 PROMPT OemToAnsi("Produtos BRASIMIX")    SIZE 055,10                 PIXEL OF oDlg
                   @ 067,270 CHECKBOX oAcs8 VAR lAcs8 PROMPT OemToAnsi("Visualiza Estrutura")  SIZE 055,10                 PIXEL OF oDlg
                   @ 077,270 CHECKBOX oAcsA VAR lAcsA PROMPT OemToAnsi("Recebe e-mail ?")      SIZE 055,10                 PIXEL OF oDlg
            Endif
            @ 077,205 CHECKBOX oAcs9 VAR lAcs9 PROMPT OemToAnsi("Usuแrio Ativo?")       SIZE 055,10                 PIXEL OF oDlg
            
            oUsrCad:aHeaders := aHeader
            oUsrCad:SetArray(aDadUsr)
            oUsrCad:bLine    := {|| oUsrCad:aArray[oUsrCad:nAt] }
            
            oUser:cName := "cUser"
            oEMFL:cName := "cEMFL"
            oUser:bLostFocus := { ||If(fValida(1), .t., SetFocus(oUser:hWnd)) }
            oEMFL:bLostFocus := { ||If(fValida(2), .t., SetFocus(oEMFL:hWnd)) }
            
     ACTIVATE MSDIALOG oDlg ON INIT fEnchBar(oDlg, {||nOpca:=1, oDlg:End()},{||nOpca:=0, oDlg:End()}) CENTERED
     If nOpca == 1
        If !Empty(cUser) .and. !Empty(cEMFL)
           DbSelectArea("SZW")
           DbSetOrder(1)
           RecLock("SZW",.t.)
              SZW->ZW_FILIAL  := xFilial("SZW")
              SZW->ZW_USUARIO := cUser
              SZW->ZW_EMPFIL  := cEMFL
              SZW->ZW_ACESSOS := If(lAcs1,'*',space(1))+If(lAcs2,'*',space(1))+If(lAcs3,'*',space(1))+If(lAcs4,'*',space(1))+If(lAcs5,'*',space(1))+If(lAcs6,'*',space(1))+If(lAcs7,'*',space(1))+If(lAcs8,'*',space(1))+If(lAcs9,'*',space(1))+If(lAcsA,'*',space(1))
              SZW->ZW_DTINCLU := dDataBase
              SZW->ZW_ATIVO   := If(lAcs9, 'S', 'N')
              SZW->ZW_ROTINA  := cRotina
           MsUnLock()
        Endif
     Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fEnchBar บAutor  ณ Luํs Gustavo       บ Data ณ  28/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Enchoicebar do cadastro de acessos.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fEnchBar(oDlg,bOk,bCancel)
       Local aButtons
       
       aButtons := { {"S4WB005N" ,{||U_fEdtAcs(cRotina) },"Editar Acessos"  } }
       aadd(aButtons,{"EXCLUIR"  ,{||U_fExcAcs(cRotina) },"Excluir Acessos"} )
Return(EnchoiceBar(oDlg,bOK,bcancel,,aButtons))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fEdtAcs  บAutor  ณ Luํs Gustavo       บ Data ณ  28/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Editor dos acessos.                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function fEdtAcs(cRotina)
     Local nOpcb := 0
     Private oEGrp1, oEGrp2, oEUser, oEEMFL, oEAcs1, oEAcs2, oEAcs3, oEAcs4, oEAcs5, oEAcs6, oEAcs7, oEAcs8, oEAcs9, oEAcsA
     Private cEUser := oUsrCad:aArray[oUsrCad:nAt][1]
     Private cEEMFL := oUsrCad:aArray[oUsrCad:nAt][3]
     Private lEAcs1 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 01, 01) == '*', .t., .f.)
     Private lEAcs2 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 02, 01) == '*', .t., .f.)
     Private lEAcs3 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 03, 01) == '*', .t., .f.)
     Private lEAcs4 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 04, 01) == '*', .t., .f.)
     Private lEAcs5 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 05, 01) == '*', .t., .f.)
     Private lEAcs6 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 06, 01) == '*', .t., .f.)
     Private lEAcs7 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 07, 01) == '*', .t., .f.)
     Private lEAcs8 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 08, 01) == '*', .t., .f.)
     Private lEAcs9 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 09, 01) == '*', .t., .f.)
     Private lEAcsA := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 10, 01) == '*', .t., .f.)
     cRotina        := Stuff(cRotina, Len(cRotina)+1, 10 - Len(cRotina), space(10 - Len(cRotina)))
     
     If !Empty(Alltrim(oUsrCad:aArray[oUsrCad:nAt][1]))
        DEFINE MSDIALOG oDlgEdt TITLE OemToAnsi("Editor de Acessos") From 9,0 TO 21,39 OF oMainWnd
               @ 012,001 GROUP oEGrp1 TO 030,154   LABEL  OemToAnsi('')                                                  PIXEL OF oDlgEdt
               @ 017,005 SAY OemToAnsi("Usuแrio:")                                           SIZE 030,09 COLOR CLR_HBLUE PIXEL OF oDlgEdt
               @ 016,040 MSGET oEUser    VAR cEUser         PICTURE "999999"      WHEN .F.  SIZE 010,09                  PIXEL OF oDlgEdt F3 "USR"
               @ 017,075 SAY OemToAnsi("Emp./Fil.:")                                         SIZE 030,09 COLOR CLR_HBLUE PIXEL OF oDlgEdt
               @ 016,110 MSGET oEEMFL    VAR cEEMFL          PICTURE "@R 99/99"    WHEN .F.  SIZE 010,09                 PIXEL OF oDlgEdt F3 "EMP"
               @ 032,001 GROUP oEGrp2 TO 089,154   LABEL  OemToAnsi('Acessos')                                           PIXEL OF oDlgEdt
               If cRotina $ 'BRFATX01  '
                  @ 037,005 CHECKBOX oEAcs1 VAR lEAcs1 PROMPT OemToAnsi("Aprova Sintegra")    SIZE 055,10                 PIXEL OF oDlgEdt
                  @ 037,070 CHECKBOX oEAcs2 VAR lEAcs2 PROMPT OemToAnsi("Aprova Pedido")      SIZE 055,10                 PIXEL OF oDlgEdt
                  @ 047,005 CHECKBOX oEAcs3 VAR lEAcs3 PROMPT OemToAnsi("Aprova Cr้dito")     SIZE 055,10                 PIXEL OF oDlgEdt
                  @ 047,070 CHECKBOX oEAcs4 VAR lEAcs4 PROMPT OemToAnsi("Aprova Diretoria")   SIZE 055,10                 PIXEL OF oDlgEdt
               Else
                  @ 037,005 CHECKBOX oEAcs1 VAR lEAcs1 PROMPT OemToAnsi("Gera revisใo PI")      SIZE 055,10                 PIXEL OF oDlgEdt
                  @ 037,070 CHECKBOX oEAcs2 VAR lEAcs2 PROMPT OemToAnsi("Libera revisใo PI")    SIZE 055,10                 PIXEL OF oDlgEdt
                  @ 047,005 CHECKBOX oEAcs3 VAR lEAcs3 PROMPT OemToAnsi("Gera revisใo PA")      SIZE 055,10                 PIXEL OF oDlgEdt
                  @ 047,070 CHECKBOX oEAcs4 VAR lEAcs4 PROMPT OemToAnsi("Libera revisใo PA")    SIZE 055,10                 PIXEL OF oDlgEdt
                  @ 057,005 CHECKBOX oEAcs5 VAR lEAcs5 PROMPT OemToAnsi("Libera็ใo diretoria")  SIZE 055,10                 PIXEL OF oDlgEdt
                  @ 057,070 CHECKBOX oEAcs6 VAR lEAcs6 PROMPT OemToAnsi("Produtos BRASIMIX")    SIZE 055,10                 PIXEL OF oDlgEdt
                  @ 067,070 CHECKBOX oEAcs8 VAR lEAcs8 PROMPT OemToAnsi("Visualiza Estrutura")  SIZE 055,10                 PIXEL OF oDlgEdt               
                  @ 077,070 CHECKBOX oEAcsA VAR lEAcsA PROMPT OemToAnsi("Recebe e-mail ?")      SIZE 055,10                 PIXEL OF oDlgEdt
               Endif
               @ 077,005 CHECKBOX oEAcs9 VAR lEAcs9 PROMPT OemToAnsi("Usuแrio Ativo?")       SIZE 055,10                 PIXEL OF oDlgEdt
        ACTIVATE MSDIALOG oDlgEdt ON INIT EnchoiceBar(oDlgEdt,{|| nOpcb := 1, oDlgEdt:End() },{|| nOpcb := 0, oDlgEdt:End() }) CENTERED
        
        If nOpcb == 1
           DbSelectArea("SZW")
           DbSetOrder(4)
           DbSeek(xFilial("SZW")+cRotina+cEUser+cEEMFL,.t.)
           If Found()
              RecLock("SZW",.f.)
                 SZW->ZW_ACESSOS := If(lEAcs1,'*',space(1))+If(lEAcs2,'*',space(1))+If(lEAcs3,'*',space(1))+If(lEAcs4,'*',space(1))+If(lEAcs5,'*',space(1))+If(lEAcs6,'*',space(1))+If(lEAcs7,'*',space(1))+If(lEAcs8,'*',space(1))+If(lEAcs9,'*',space(1))+If(lEAcsA,'*',space(1))
                 SZW->ZW_ATIVO   := If(lEAcs9, 'S', 'N')
                 SZW->ZW_DTALTER := dDataBase
              MsUnLock()
              oUsrCad:aArray[oUsrCad:nAt][4] := If(lEAcs1,'*',space(1))+If(lEAcs2,'*',space(1))+If(lEAcs3,'*',space(1))+If(lEAcs4,'*',space(1))+If(lEAcs5,'*',space(1))+If(lEAcs6,'*',space(1))+If(lEAcs7,'*',space(1))+If(lEAcs8,'*',space(1))+If(lEAcs9,'*',space(1))+If(lEAcsA,'*',space(1))
              oUsrCad:aArray[oUsrCad:nAt][5] := If(lEAcs9, 'SIM', 'NรO')
           Endif
         Endif
     Else
        MsgBox("Nใo existe cadastro a ser editado.","Aten็ใo","Alert")
     Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fExcAcs  บAutor  ณ Luํs Gustavo       บ Data ณ  28/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exclusใo dos acessos.                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function fExcAcs(cRotina)
     Local nOpcb := 0
     Private oEGrp1, oEGrp2, oEUser, oEEMFL, oEAcs1, oEAcs2, oEAcs3, oEAcs4, oEAcs5, oEAcs6, oEAcs7, oEAcs8, oEAcs9, oEAcsA
     Private cEUser := oUsrCad:aArray[oUsrCad:nAt][1]
     Private cEEMFL := oUsrCad:aArray[oUsrCad:nAt][3]
     Private lEAcs1 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 01, 01) == '*', .t., .f.)
     Private lEAcs2 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 02, 01) == '*', .t., .f.)
     Private lEAcs3 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 03, 01) == '*', .t., .f.)
     Private lEAcs4 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 04, 01) == '*', .t., .f.)
     Private lEAcs5 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 05, 01) == '*', .t., .f.)
     Private lEAcs6 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 06, 01) == '*', .t., .f.)
     Private lEAcs7 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 07, 01) == '*', .t., .f.)
     Private lEAcs8 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 08, 01) == '*', .t., .f.)
     Private lEAcs9 := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 09, 01) == '*', .t., .f.)
     Private lEAcsA := Iif(SubStr(oUsrCad:aArray[oUsrCad:nAt][4], 10, 01) == '*', .t., .f.)
     
     cRotina        := Stuff(cRotina, Len(cRotina)+1, 10 - Len(cRotina), space(10 - Len(cRotina)))
     
     DEFINE MSDIALOG oDlgEdt TITLE OemToAnsi("Editor de Acessos") From 9,0 TO 21,39 OF oMainWnd
            @ 012,001 GROUP oEGrp1 TO 030,154   LABEL  OemToAnsi('')                                                  PIXEL OF oDlgEdt
            @ 017,005 SAY OemToAnsi("Usuแrio:")                                           SIZE 030,09 COLOR CLR_HBLUE PIXEL OF oDlgEdt
            @ 016,040 MSGET oEUser    VAR cEUser         PICTURE "999999"      WHEN .F.  SIZE 010,09                  PIXEL OF oDlgEdt F3 "USR"
            @ 017,075 SAY OemToAnsi("Emp./Fil.:")                                         SIZE 030,09 COLOR CLR_HBLUE PIXEL OF oDlgEdt
            @ 016,110 MSGET oEEMFL    VAR cEEMFL          PICTURE "@R 99/99"    WHEN .F.  SIZE 010,09                 PIXEL OF oDlgEdt F3 "EMP"
            @ 032,001 GROUP oEGrp2 TO 089,154   LABEL  OemToAnsi('Acessos')                                           PIXEL OF oDlgEdt
            If cRotina $ 'BRFATX01  '
               @ 037,005 CHECKBOX oEAcs1 VAR lEAcs1 PROMPT OemToAnsi("Libera Pedidos")       SIZE 055,10                 PIXEL OF oDlgEdt
               @ 037,070 CHECKBOX oEAcs2 VAR lEAcs2 PROMPT OemToAnsi("Aprova Cr้dito")       SIZE 055,10                 PIXEL OF oDlgEdt
               @ 047,005 CHECKBOX oEAcs3 VAR lEAcs3 PROMPT OemToAnsi("Libera็ใo Diretoria")  SIZE 055,10                 PIXEL OF oDlgEdt
               @ 047,070 CHECKBOX oEAcs4 VAR lEAcs4 PROMPT OemToAnsi("Consulta Hist๓rico")   SIZE 055,10                 PIXEL OF oDlgEdt
               @ 057,005 CHECKBOX oEAcs5 VAR lEAcs5 PROMPT OemToAnsi("Consulta Itens")       SIZE 055,10                 PIXEL OF oDlgEdt
               @ 057,070 CHECKBOX oEAcs6 VAR lEAcs6 PROMPT OemToAnsi("Consulta Cadastro")    SIZE 055,10                 PIXEL OF oDlgEdt
            Else
               @ 037,005 CHECKBOX oEAcs1 VAR lEAcs1 PROMPT OemToAnsi("Gera revisใo PI")      SIZE 055,10                 PIXEL OF oDlgEdt
               @ 037,070 CHECKBOX oEAcs2 VAR lEAcs2 PROMPT OemToAnsi("Libera revisใo PI")    SIZE 055,10                 PIXEL OF oDlgEdt
               @ 047,005 CHECKBOX oEAcs3 VAR lEAcs3 PROMPT OemToAnsi("Gera revisใo PA")      SIZE 055,10                 PIXEL OF oDlgEdt
               @ 047,070 CHECKBOX oEAcs4 VAR lEAcs4 PROMPT OemToAnsi("Libera revisใo PA")    SIZE 055,10                 PIXEL OF oDlgEdt
               @ 057,005 CHECKBOX oEAcs5 VAR lEAcs5 PROMPT OemToAnsi("Libera็ใo diretoria")  SIZE 055,10                 PIXEL OF oDlgEdt
               @ 057,070 CHECKBOX oEAcs6 VAR lEAcs6 PROMPT OemToAnsi("Produtos BRASIMIX")    SIZE 055,10                 PIXEL OF oDlgEdt
               @ 067,070 CHECKBOX oEAcs8 VAR lEAcs8 PROMPT OemToAnsi("Visualiza Estrutura")  SIZE 055,10                 PIXEL OF oDlgEdt               
               @ 077,070 CHECKBOX oEAcsA VAR lEAcsA PROMPT OemToAnsi("Recebe e-mail ?")      SIZE 055,10                 PIXEL OF oDlgEdt
            Endif
            @ 077,005 CHECKBOX oEAcs9 VAR lEAcs9 PROMPT OemToAnsi("Usuแrio Ativo ?")       SIZE 055,10                 PIXEL OF oDlgEdt
            Iif( !oEAcs1 == Nil, oEAcs1:bWhen := {||.F.}, )
            Iif( !oEAcs2 == Nil, oEAcs2:bWhen := {||.F.}, )
            Iif( !oEAcs3 == Nil, oEAcs3:bWhen := {||.F.}, )
            Iif( !oEAcs4 == Nil, oEAcs4:bWhen := {||.F.}, )
            Iif( !oEAcs5 == Nil, oEAcs5:bWhen := {||.F.}, )
            Iif( !oEAcs6 == Nil, oEAcs6:bWhen := {||.F.}, )
            Iif( !oEAcs7 == Nil, oEAcs7:bWhen := {||.F.}, )
            Iif( !oEAcs8 == Nil, oEAcs8:bWhen := {||.F.}, )
            Iif( !oEAcs9 == Nil, oEAcs9:bWhen := {||.F.}, )
            Iif( !oEAcsA == Nil, oEAcsA:bWhen := {||.F.}, )
            
     ACTIVATE MSDIALOG oDlgEdt ON INIT EnchoiceBar(oDlgEdt,{|| nOpcb := 1, oDlgEdt:End() },{|| nOpcb := 0, oDlgEdt:End() }) CENTERED
     If nOpcb == 1
        DbSelectArea("SZW")
        DbSetOrder(4)
        DbSeek(xFilial("SZW")+cRotina+cEUser+cEEMFL,.t.)
        If Found()
           RecLock("SZW",.f.)
              delete
           MsUnLock()
           lUltReg := Iif((Len(oUsrCad:aArray) - 1) == 0, .t., .f.)
           nNewTam := Iif((Len(oUsrCad:aArray) - 1) == 0, 1, (Len(oUsrCad:aArray) - 1))
           If lUltReg
              aadd(oUsrCad:aArray,{space(06), space(15), space(05), space(06), space(03)})
           Endif
           oUsrCad:aArray := aSize(aDel(oUsrCad:aArray,oUsrCad:nAt),nNewTam)

        Endif
     Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fValida  บAutor  ณ Luํs Gustavo       บ Data ณ  28/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็๕es diversas.                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fValida(nValida)
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
       ElseIf nValida == 2
              If !Empty(cEMFL)
                 /*DbSelectArea("SM0")
                 DbSetOrder(1)
                 If DbSeek(cEMFL) */
                    DbSelectArea("SZW")
                    DbSetOrder(4)
                    If DbSeek(xFilial("SZW")+cRotina+cUser+cEMFL,.t.)
                       lRet := .f.
                       MsgBox("Esse usuแrio jแ estแ cadastrado para essa empresa / filial.","Aten็ใo","STOP")
                    Else
                       lRet := .t.
                    Endif
                 /*Else
                    lRet := .f.
                    MsgBox("Nใo existe esse empresa / filial cadastrada no sistema.","Aten็ใo","STOP")
                 Endif */
              Else
                 lRet := .t.
              Endif
       Endif
Return(lRet)