#include "protheus.ch"
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
#include "sigawin.ch"
#include "colors.ch"
#include "font.ch"
#Translate MSGBOX( => IW_MsgBox(
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP053 º Autor ³ Luís Gustavo de Souza º Data ³ 18/09/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ajuste de preços de tabela.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRPCP053()
     Local cPlanilha
     Private cCadastro := "Ajuste de Tab. de Precos"
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta um aRotina proprio                                            ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Private aRotina := { {"Pesquisar" ,'AxPesqui'                    ,0,1      },;
                          {"Visualizar",'ExecBlock("PCP0531",.f.,.f.)',0,2      },;
                          {"Alterar"   ,'ExecBlock("PCP0532",.f.,.f.)',0,4,2    } }

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta array com os campos para o Browse                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Private aCampos := { {"CÓDIGO","B1_COD","@!"} }
     Private cDelFunc := ".T." 
     Private cString := "SB1",cPerg,nPercInt
     u_zcfga01( 'BRPCP053' ) //LGS#2021201 - Gravação de log de utilização da rotina
     DbSelectArea("SB1")
     DbSetOrder(1)

     DbSelectArea("SX3")
     DbSetOrder(1)
     cPerg := "ES"+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2)
     //ValidPerg()
     Pergunte(cPerg)   

     cPlanilha := Alltrim(mv_par01)+".pdv"
     nPercInt  := u_detpercint(cPlanilha)
     DbSelectArea(cString)
     mBrowse( 6,1,22,75,cString,,)
Return

User Function PCP0531()
     Private oFnt
     Private cPro := SB1->B1_COD
     Private cDes := SB1->B1_DESC
     Private nTB1 := Iif(SB1->B1_ESTOQUE=="S", SB1->B1_PRV1, Posicione("SB5",1,xFilial("SB5")+SB1->B1_COD,"B5_PRV2") )
     Private cEst := Iif(SB1->B1_ESTOQUE=="S","Sim","Não")
     Private oDlg

     nOpc := 0
        
     DEFINE MSDIALOG oDlg FROM 00,00 TO 11,80 TITLE OemToAnsi( "Alteração do Cadastro de Produtos" ) OF oMainWnd
            @ 015, 003 TO 080,313
            @ 025, 010 SAY OemToAnsi( "Codigo: ")    SIZE 025,008
            @ 025, 100 SAY OemToAnsi( "Descricao: ") SIZE 025,008
            @ 025, 240 SAY OemToAnsi( "P.Estoque: ") SIZE 025,008
            @ 045, 010 SAY OemToAnsi( "Preço : ")      SIZE 035,008
            @ 025, 040 MSGET oPro Var cPro Picture "@!"                When .f. SIZE 050,008 of oDlg PIXEL
            @ 025, 130 MSGET oDes Var cDes Picture "@!"                When .f. SIZE 100,008 of oDlg PIXEL
            @ 025, 270 MSGET oEst Var cEst Picture "@!"                When .f. SIZE 015,008 of oDlg PIXEL
            @ 045, 040 MSGET oTB1 Var nTB1 Picture "@E 9,999,999.9999" When .f. SIZE 050,008 of oDlg PIXEL
     ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, { || nOpc := 1,oDlg:End() }, { || oDlg:End() } ) CENTERED
     If nOpc == 0
     ElseIf nOpc == 1
     Endif
Return

User Function PCP0532()
     Local nCusto, nMo, nLucro, nComissao, nLcrMin, nAux, nIcms
     //Local nLucro2, nLucroM2
	 private aArray
     Private oFnt
     Private cPro := SB1->B1_COD
     Private cDes := SB1->B1_DESC
     Private nTB1 := Iif(SB1->B1_ESTOQUE == "S", SB1->B1_PRV1, Posicione("SB5",1,xFilial("SB5")+SB1->B1_COD,"B5_PRV2") )
     Private cEst := Iif(SB1->B1_ESTOQUE=="S","Sim","Não")
     Private oDlg
     
     If !Upper( AllTrim( cUserName ) ) $ Upper( GETMV( "MV_ALTTABP" ) )
        MsgBox("Acesso negado. Entre em contato com o Administrador do Sistema!!!","Atenção...","ALERT")
        Return
     Endif
     If !SB1->B1_TIPO $ "PA"
        MsgBox("Acesso negado. Produto não é do tipo Produto Acabado (PA)!!!","Atenção...","ALERT")
        Return
     Endif
     nOpc := 0
     DEFINE MSDIALOG oDlg FROM 00,00 TO 11,80 TITLE OemToAnsi( "Alteracao do Cadastro de Produtos" ) OF oMainWnd
            @ 015, 003 TO 080,313
            @ 025, 010 SAY OemToAnsi( "Codigo: ")    SIZE 025,008
            @ 025, 100 SAY OemToAnsi( "Descricao: ") SIZE 025,008
            @ 025, 240 SAY OemToAnsi( "P.Estoque: ") SIZE 025,008
            @ 045, 010 SAY OemToAnsi( "Preço : ")  SIZE 035,008
            @ 025, 040 MSGET oPro Var cPro Picture "@!"                When .f. SIZE 050,008 of oDlg PIXEL
            @ 025, 130 MSGET oDes Var cDes Picture "@!"                When .f. SIZE 100,008 of oDlg PIXEL
            @ 025, 270 MSGET oEst Var cEst Picture "@!"                When .f. SIZE 015,008 of oDlg PIXEL
            @ 045, 040 MSGET oTB1 Var nTB1 Picture "@E 9,999,999.9999"          SIZE 050,008 of oDlg PIXEL
     ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, { || nOpc := 1,oDlg:End() }, { || oDlg:End() } ) CENTERED
     If nOpc == 0
     ElseIf nOpc == 1
			aArray    := {}
			aadd(aArray,{"", "", "", SB1->B1_COD})
			nCusto    := 0
			nCusto    := U_CustoPro(SB1->B1_COD)
			nMo       := ExecBlock("BRPCP011", .F., .F., "MO")
			nLucro    := ExecBlock("BRPCP011", .F., .F., "LU")
			nComissao := ExecBlock("BRPCP011", .F., .F., "CO")   
			nIcms     := GETMV("MV_ICMPAD")
			nLcrMin   := nLucro
			nAuxLucro := u_calclucro(nCusto+nMo,nPercInt+nComissao+nIcms,nTB1)
			DbSelectArea("SZ1")   
			DbSetOrder(1)
			DbSeek(xFilial("SZ1")+SubStr(SB1->B1_COD, 4, 2))
			If Found() .and. (Len(Alltrim(SB1->B1_COD)) == 12)
				nLcrMin := SZ1->Z1_LUCRMIN
			Endif
            nAux    := nAuxLucro - (nLucro - nLcrMin)
            nLcrMin := nAux
            nLucro  := nAuxLucro

			DbSelectArea("SB1")
			reclock("SB1",.F.)
		  	SB1->B1_CUSTOR  := nCusto+nMo
		  	SB1->B1_PERINT  := nPercInt
			SB1->B1_LUCRO   := nLucro
			SB1->B1_LCRMIN  := nLcrMin
			SB1->B1_LUCRO2  := nLucro
			SB1->B1_LUCROM2 := nLcrMin	
			SB1->B1_PRV1    := nTB1
			SB1->B1_COMIS   := nComissao
      		MsUnLock()
   			DbSelectArea("SB5")
   			DbSetOrder(1)
      		DbSeek(xFilial("SB5")+SB1->B1_COD, .t.)
        	If Found()
         		RecLock("SB5",.f.)
         	Else
          		RecLock("SB5",.T.)
                   SB5->B5_FILIAL := xFilial("SB5")
                   SB5->B5_COD    := SB1->B1_COD
                   SB5->B5_CEME   := SB1->B1_DESC
            Endif
          	SB5->B5_PRV2 := nTB1
            MsUnLock()
            // Enviar alteracoes p/ representante
            If (cNumEmp = "01010101") .and. ((SB1->B1_TIPO == 'PA') .OR. (DbSeek(xFilial("SX5")+"Z3"+Alltrim(SB1->B1_COD)) .AND. (SB1->B1_VEND == 'S')))
               U_EnviaRec("SB1", SB1->B1_COD, .f.)
            Endif
      Endif
Return
/*
Static Function ValidPerg()
       Local _sAlias := Alias()
       Local i, j
       
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg, 10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs, {cPerg, "01", "Planilha  ?", "", "", "mv_ch1", "C", 10, 0, 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",  "", "", "", " ", "", ""})

       For i := 1 to Len(aRegs)
           If !DbSeek(cPerg+aRegs[i][2])
              RecLock("SX1", .T.)
                 For j := 1 to FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j, aRegs[i][j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return*/
