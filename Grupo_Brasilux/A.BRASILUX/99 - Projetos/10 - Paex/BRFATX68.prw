#INCLUDE 'PROTHEUS.CH'                                          
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'COLORS.CH'                                                                              
#INCLUDE 'FONT.CH'
#INCLUDE 'INKEY.CH'
#INCLUDE 'vkey.CH'


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±                   
±±³Programa  ³ BRFATX68  ³ Autor ³ André Maester      ³ Data ³ /11/2015³   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem / Desmontagem de Pallets (Linha de Montagem Rampa)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³ 04/11/15³ Inclusão da Rotina, remonta compra de produto³±±
±±³                de vários borderos de pedidos.						  ³±±
±±³              ³  /  /  ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function BRFATX68()
    Private cGet1Env   := Space(11) //"      /    "	// Pallet
    Private cGet2Env   := Space(06)				    // Bordero
    Private cGet3Env   := "     .  .   -  "    // Produto
    Private cSay1Env   := Space(01)
    Private cSay2Env   := Space(01)
    Private cSay4Env   := Space(20)
    Private cSay3Env   := Space(30)
    Private nCapPallet := 0
    Private nCapAntPal := 0
    Private nCount     := 0
    Private lProdMist  :=.f.
    Private nCBox1Co   := ""
	Private nCBox1Lo   := Space(04)
    Private cCBox2     := "2-DEPOSITO"
    Private cCor4Env   := 0
    Private nQtdeIni   := 0
    Private cPallet    := ""
    Private cMaxSeq    := ""
    Private _CodProd   := ""
    Private _cMaxSeq   := ""
    Private nQtdTotal  := 0
	Private cCodBarra  := ""
    //Private _cSeq      := ""
    Private lJaFech    := .f.
    Private lTelaJaFechada := .f.  
    Private lCheck     := .t.
	Private cRotina    := "BRFATX68"
	Private cCodUsr   := RetCodUsr()
	Private cAcessos  := Posicione("SZW", 4, xFilial("SZW")+cRotina+__cUserID+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS")
	Private oTempTbl1
	Private _ZPPAR0118 := GetMV( "ZP_PAR0118" ) // Libera Bloqueio de Lotes

    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Declaração de Variaveis Private dos Objetos                             ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    SetPrvt("oFontEnv", "oDlg1Env", "oGrp1Env", "oSay1Env", "oSay2Env", "oGet1Env", "oGet2Env", "oBtn1Env", "oBtn2Env")
    SetPrvt("oBtn3Env", "oBtn4Env", "oBtn5Env", "oBtn6Env", "oBrw1Env", "oGrp3Env", "oBtn7Env", "oBtn8Env", "oBtn9Env")
    SetPrvt("oSay4Env", "oBtn6Env", "oSay3Env", "oSay5Env", "oCBox1"  , "oBtnAEnv", "oBtnBEnv", "oSay6Env", "oSay7Env")
    SetPrvt("oBtnCEnv", "oSay8Env", "oCBox2"  , "oSay9Env", "oSay2Loc", "oCBox1Lo")

	If !u_VldAcesso(funname())
		MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
		Return 
	Endif 

    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Definicao do Dialog e todos os seus componentes.                        ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    oFontEnv   := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
    oFon2Env   := TFont():New( "Courier New"  , 0,  19, , .T., 0, , 400, .F., .F., , , , , , )
    oFon3Env   := TFont():New( "Courier New"  , 0,  25, , .T., 0, , 400, .F., .F., , , , , , )

    oDlg1Env   := MSDialog():New( 140, 264, 700, 980, "Re Monta Compra (Monta Pallets nas Rampas)", , , .F., , , , , , .T., , , .T. )
    oGrp1Env   := TGroup():New( 003, 004, 058, 356, "Dados do Pallet", oDlg1Env, CLR_RED, CLR_WHITE, .T., .F. )
    oSay1Env   := TSay():New( 012, 008, { || "Pallet:"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
    oGet1Env   := TGet():New( 010, 060, { |u| If(PCount() > 0, cGet1Env := u, cGet1Env)}, oGrp1Env, 080, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGet1Env", , ) 
    oGet1Env:bLostFocus := {|| Iif(!Empty(Alltrim(cGet1Env)),fCarPall(cGet1Env),"")}

    oSay6Env   := TSay():New( 028, 150, { || "Borderô:"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
    oGet2Env   := TGet():New( 028, 200, { |u| If(PCount() > 0, cGet2Env := u, cGet2Env)}, oGrp1Env, 080, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGet2Env", , ) 
	
	oSay9Env   := TSay():New( 012, 150, { || "Tipo Bor:"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 045, 012)
    oCBox2     := TComboBox():New( 010, 200, {|u| If(PCount() > 0, cCBox2 := u, cCBox2)}, {"1-AGLUTINADO","2-DEPOSITO - GRU", "3-REGIAO-RETIRA","4-EXPORTACAO","5-CARGA FECHADA","8-CARGA-MATRIZ","9-DEPOSITO - ARA"}, 080, 026, oGrp1Env, , , , CLR_BLACK, CLR_WHITE, .T., oFon2Env, "", , , , ,  , , cCBox2 )
    //oCBox2     := TComboBox():New( 010, 200, {|u| If(PCount() > 0, cCBox2 := u, cCBox2)}, {"1-AGLUTINADO","2-DEPOSITO", "3-REGIAO-RETIRA","4-EXPORTACAO","6-AMOSTRAS","7-VOL. QUEBRADO"}, 080, 026, oGrp1Env, , , , CLR_BLACK, CLR_WHITE, .T., oFon2Env, "", , , , ,  , , cCBox2 )

    oBtn3Env   := TButton():New( 038, 008, "Novo Pallet", oGrp1Env, {|| fNPal()}, 052, 016, , oFontEnv, , .T., , "", , , , .F. )
    oGet2Env:bLostFocus := {|| Iif(!Empty(Alltrim(cGet2Env)),fValBord(cGet2Env),"")}

    oSay4Env   := TSay():New( 030, 152, { || cSay4Env  }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., cCor4Env, CLR_WHITE, 106, 012)
    oBtn1Env   := TButton():New( 009, 297, "Confirma", oGrp1Env, {|| fSMntPal()}, 052, 016, , oFontEnv, , .T., , "", , , , .F. )

    oBtn2Env   := TButton():New( 030, 297, "Abandona", oGrp1Env, {|| fSairMPa()}, 052, 016, , oFontEnv, , .T., , "", , , , .F. )
    oGrp2Env   := TGroup():New( 060, 004, 278, 356, "", oDlg1Env, CLR_BLACK, CLR_WHITE, .T., .F. )
	oCBox1     := TCheckBox():New( 267,215,"Pallet Padrão",{|u| If(PCount() > 0, lCheck := u, lCheck)},oGrp2Env,080,012,,,oFontEnv,,CLR_BLUE ,CLR_WHITE,,.t.,"Bloqueia Bipe Qdo Ultrapassa Limite",, )	// 266,287

//  oCBox1Lo   := TComboBox():New( 062, 290, {|u| If(PCount() > 0, nCBox1Lo := u, nCBox1Lo)}, {"","FAB1", "FAB2","DEPO"}, 060, 016, oGrp2Env, , , , CLR_BLACK, CLR_WHITE, .T., oFon2Env, "", , , , ,  , , nCBox1Lo ) // Jose 21/09/2024 Substituido pelo de baixo
    oCBox1Lo   := TComboBox():New( 062, 290, {|u| If(PCount() > 0, nCBox1Lo := u, nCBox1Lo)}, {"","FAB1","FAB2","ARA","DEPO"}, 060, 016, oGrp2Env, , , , CLR_BLACK, CLR_WHITE, .T., oFon2Env, "", , , , ,  , , nCBox1Lo ) 
	oSay2Loc   := TSay():New( 077, 290, { || "Localização"}, oGrp2Env, , oFon2Env, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012)

    oBtn4Env   := TButton():New( 088, 290, "<- Monta     " , oGrp2Env, {|| fMntPallet(1) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. ) // 068
    oBtn5Env   := TButton():New( 105, 290, "<- Desmonta  " , oGrp2Env, {|| fMntPallet(2) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. ) // 088

    oSay7Env   := TSay():New( 122, 338, { || nCount}    , oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 020, 020) // 108
    oSay8Env   := TSay():New( 122, 283, { || "Volumes:"}, oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 050, 020) // 108

	oSay2Env   := TSay():New( 138, 290, { || "Impressora"}, oGrp2Env, , oFon2Env, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012) // 138
    oCBox1Co   := TComboBox():New( 148, 290, {|u| If(PCount() > 0, nCBox1Co := u, nCBox1Co)}, {"", "ZEBRA S4M", "ZEBRA ZT230"}, 060, 016, oGrp2Env, , , , CLR_BLACK, CLR_WHITE, .T., oFon2Env, "", , , , ,  , , nCBox1Co ) // 138
    
	oBtn6Env   := TButton():New( 169, 290, "<- Imp.Etq ->" , oGrp2Env, {|| fIEtPallet(nCBox1Co) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. ) // 148
    oBtn7Env   := TButton():New( 184, 290, "<- Res. Pro->" , oGrp2Env, {|| U_fResPallet(1) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. ) // 168
    oBtn9Env   := TButton():New( 199, 290, "<- Res. Emb->" , oGrp2Env, {|| U_fResPallet(2) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. ) // 188
    oBtnAEnv   := TButton():New( 214, 290, "<- Res. Grp->" , oGrp2Env, {|| U_fResPallet(3) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. ) // 208
    oBtnBEnv   := TButton():New( 229, 290, "<- Rel. Bor->" , oGrp2Env, {|| U_fImpInf()     }, 060, 012, , oFon2Env, , .T., , "", , , , .F. ) // 218
    oBtnBEnv   := TButton():New( 244, 290, "<- Rel. Exc->" , oGrp2Env, {|| U_fImpExc(SUBSTRING(cCBox2,1,1)) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. ) 
	oBtnCEnv   := TButton():New( 260, 310, "Destruir"      , oGrp2Env, {|| fDelPallet()    }, 040, 012, , oFon2Env, , .T., , "", , , , .F. ) // 246, 310
    
    oSay3Env   := TSay():New( 046, 073, { || cSay3Env  },   oGrp1Env, , oFon2Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 240, 012)
	

    oTblIPall()
    DbSelectArea("TMPITE")
    DbSetOrder(1)
    DbGoTop()
    oBrw1Env   := MsSelect():New( "TMPITE", "", "", { {"TMPPRO", "", "Produto", "@R XX 99.99.999-99"}, {"TMPSEQ", "", "Sequ.", "@!"}, {"TMPLOT", "", "Lote   ", "@R X99999"}, { "TMPQTD", "", "Quantidade", "@E 999,999"} , {"TMPPED", "", "Pedido", "@E 999999"}, {"TMPCBR", "", "Cod. Barras", "@R X99999999999999999"}  }, .F., , {066, 007, 266, 280}, , , oGrp2Env ) // Jose 07/03/2025  "Lote   ", "@E 999999"   "Cod. Barras", "@E 999999999999999999"

    oBrw1Env:oBrowse:oFont          := oFon2Env
    oBrw1Env:oBrowse:lAdjustColSize := .t.
    oBrw1Env:oBrowse:Refresh()
	oBtn3Env:SetFocus()
    
    oDlg1Env:Activate(,,,.T.)
    
    If !lJaFech
		lTelaJaFechada := .t.
        fSairMPa()
    Endif
    oTempTbl1:Delete()

Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fSMntPal()  Salvar Dados das Tabelas Temporárias - Botão Confirmar Tela Principal
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fSMntPal()

	If Empty(Alltrim(cGet1Env)) //.or.  Empty(Alltrim(cGet2Env))
		Return
	Endif

    DbSelectArea("ZZJ")
	DbSetOrder(1)
	DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
	If Found()
		If ZZJ->ZZJ_FLAG == "4"
			Messagebox("Não é possível alterar este Pallet, pois já foi transformado em pedido de transferência !","Atenção...",48) 
    		DbSelectArea("ZZJ")
    		DbClosearea()
        	Return
	  	Endif
   	Endif

	Begin Transaction
	
		DbSelectArea("TMPITE")
	    DbSetOrder(1)
		DbGoTop()    
		If Eof()
		    DbSelectArea("ZZJ")
		    DbSetOrder(1)
		    DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
		    If Found() .and. (xFilial("ZZJ") == ZZJ->ZZJ_FILIAL) .and. (Alltrim(cGet1Env) == Alltrim(ZZJ->ZZJ_CODIGO))
				RecLock("ZZJ", .F.)
					DbDelete()
				MsUnlock()		
				CGet1Env := Space(11) 
			Endif
		Else    	
		    DbSelectArea("ZZJ")
	    	DbSetOrder(1)
		    DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
		    If Found() .and. (xFilial("ZZJ") == ZZJ->ZZJ_FILIAL) .and. (Alltrim(cGet1Env) == Alltrim(ZZJ->ZZJ_CODIGO))
			    If ZZJ->ZZJ_FLAG $ '3'
				    RecLock("ZZJ", .f.)
			    	    ZZJ->ZZJ_DTFIM := Date()
			    	    ZZJ->ZZJ_HFIM  := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
			    	    ZZJ->ZZJ_TIPBOR:= Substr(cCBox2,1,1)
		    	    MsUnLock()
				Endif
			Endif
        Endif

	End Transaction

	If ChkFile("TMPITE") 
		DbSelectArea("TMPITE")
	    //DbGotop()
		//Zap
        //LGS#20191029 - Substituido comando ZAP devido a utilização de função do banco.
        TCSqlExec("DELETE FROM " + oTempTbl1:GetRealName() )
	Endif
	If ChkFile("ZZK") 
		DbSelectArea("ZZK")
		DbCloseArea()
	Endif
	If ChkFile("ZZJ") 
	    DbSelectArea("ZZJ")
		DbCloseArea()
	Endif    
    If !lTelaJaFechada
	    oBtn3Env:Enable()
	    oGet2Env:Enable()
	    oCBox2:Enable()
		oCBox1Lo:Enable()
    Endif
    If !Empty(Alltrim(cGet1Env))
	    fCarPall(cGet1Env)
	Endif
	

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fSairMPa()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fSairMPa()
	//Local lRet
	
    If !lTelaJaFechada
	    oDlg1Env:End()
    Endif
    lJaFech :=.t. 

Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTblIPall() - Cria temporario para o Alias: TMPITE
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTblIPall()
	Local aFds := {}
    //Local cTmp
    
	If ChkFile("TMPITE") 
		DbSelectArea("TMPITE")
	    DbClosearea()
	Endif

    aAdd( aFds , {"TMPINV"  ,"C", 003, 000} )   // ORDEM INVERTIDA
    aAdd( aFds , {"TMPPAL"  ,"C", 011, 000} )   // PALLET
    aAdd( aFds , {"TMPLOT"  ,"C", 006, 000} )   // LOTE
    aAdd( aFds , {"TMPSEQ"  ,"C", 003, 000} )   // SEQUENCIA
    aAdd( aFds , {"TMPPRO"  ,"C", 015, 000} )   // PRODUTO
    aAdd( aFds , {"TMPQTD"  ,"N", 011, 003} )   // QUANTIDADE
	aAdd( aFds , {"TMPCBR"  ,"C", 018, 000} )   // CODIGO DE BARRAS
    aAdd( aFds , {"TMPDEL"  ,"C", 001, 000} )   // DELETADO
    aAdd( aFds , {"TMPPED"  ,"C", 006, 000} )   // PEDIDO
    
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 28/10/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
    //cTmp := U_NovoArqTrab("dbf") //CriaTrab( , .F. )
    //DbCreate(cTmp+".dbf", aFds, "DBFCDXADS")
    //Use (cTmp+".Dbf") Alias TMPITE VIA "DBFCDXADS" New Exclusive
    //DbCreateIndex(cTmp+"_1.cdx", "TMPPAL+TMPSEQ"	   , {||"TMPPAL+TMPSEQ"} )
    //DbCreateIndex(cTmp+"_2.cdx", "TMPPAL+TMPPRO+TMPSEQ", {||"TMPPAL+TMPPRO+TMPSEQ"} )
    //DbCreateIndex(cTmp+"_3.cdx", "TMPPAL+TMPINV"       , {||"TMPPAL+TMPINV"} )
    //DbCreateIndex(cTmp+"_4.cdx", "TMPPAL+TMPCBR"	   , {||"TMPPAL+TMPCBR"} )
    //DbCreateIndex(cTmp+"_5.cdx", "TMPCBR"			   , {||"TMPCBR"} )
    
    //DbClearInd()
    //DbSetIndex(cTmp+"_1")
    //DbSetIndex(cTmp+"_2")
    //DbSetIndex(cTmp+"_3")
    //DbSetIndex(cTmp+"_4")
    //DbSetIndex(cTmp+"_5")
       oTempTbl1 := FWTemporaryTable():New( 'TMPITE' )
       oTempTbl1:SetFields( aFds )
       oTempTbl1:AddIndex( "cInd01", { "TMPPAL", "TMPSEQ"           } )
       oTempTbl1:AddIndex( "cInd02", { "TMPPAL", "TMPPRO", "TMPSEQ" } )
       oTempTbl1:AddIndex( "cInd03", { "TMPPAL", "TMPINV"           } )
       oTempTbl1:AddIndex( "cInd04", { "TMPPAL", "TMPCBR"           } )
       oTempTbl1:AddIndex( "cInd05", { "TMPCBR"                     } )
       oTempTbl1:Create()
       /********************************************************************************************************************************/

    DbSetOrder(1)

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fValBord() - Valida Borderô de Pedidos digitado a ser separado
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fValBord(cNumBord)

	If Empty(Alltrim(cNumBord)) .or. Alltrim(cNumBord) $ "VARIOS"
		Return
	Endif
	//cSay3Env := ""

 	DbSelectArea("SZF")
  	DbSetOrder(1)
   	DbSeek(xFilial("SZF")+cNumBord, .t.)
    If !Found() .and. !Alltrim(cNumBord) $ "VARIOS"	
		Messagebox("Borderô de pedido inválido, verifique !!!","Atenção...",48)
		oGet2Env:Setfocus()
		Return	  		     	
    Else
		If SZF->ZF_FLAG $ 'Z'
			Messagebox("Atenção, o Status deste pallet esta como finalizado, portanto, se houve desmontagem de pallet após a finalização, é preciso alterar o status do Bordero para incompleto !!!","Atenção...",48)
			oGet2Env:Setfocus()
			Return	  		     	
		Endif
		If !SZF->ZF_FLAG $ 'Y.X'
			Messagebox("Status do Borderô Inválido para Compra, Somente é possível comprar após processamento do baixa retirada !!!","Atenção...",48)
			oGet2Env:Setfocus()
			Return	  		     	
		Endif
		
		If Alltrim(SZF->ZF_TIPOBOR) ='1'
			cCBox2 :="1-AGLUTINADO"
		Elseif Alltrim(SZF->ZF_TIPOBOR) ='2'
			cCBox2 :="2-DEPOSITO - GRU"
		Elseif Alltrim(SZF->ZF_TIPOBOR) ='3'
			cCBox2 :="3-REGIAO-RETIRA"
		Elseif Alltrim(SZF->ZF_TIPOBOR) ='4'
			cCBox2 :="4-EXPORTACAO"
		Elseif Alltrim(SZF->ZF_TIPOBOR) ='5'
			cCBox2 :="5-CARGA FECHADA"
		Elseif Alltrim(SZF->ZF_TIPOBOR) ='8'
			cCBox2 :="8-CARGA-MATRIZ"	
		Elseif Alltrim(SZF->ZF_TIPOBOR) ='9' // Jose 11/11/2024
			cCBox2 :="9-DEPOSITO - ARA" // Jose 11/11/2024
		Endif	
		
		If Alltrim(SZF->ZF_TIPOBOR) <> Substr(cCBox2,1,1)
			Messagebox("Verifique o tipo de Borderô, pois não corresponde ao tipo escolhido !!!","Atenção...",48)
			oCBox2:Setfocus()    
		Endif	

    Endif
    
    DbSelectArea("SZF")
    DbCloseArea()

	If ChkFile("TMPITE")
		DbSelectArea("TMPITE")
		DbSetorder(1)
		DbGoTop()
	Endif
    oBtn4Env:Setfocus()
    
Return

Static Function fCarPall(cPallet)

	nCapPallet := 0 
	nCapAntPal := 0
	lProdMist  := .f.
	
	If Empty(Alltrim(cPallet)) .or. (cGet1Env $ "NOVO PALLET")
		Return
	Endif
	If Len(Alltrim(cPallet)) = 10
		cGet1Env  := Substr(cPallet,1,6)+'/'+Substr(cPallet,7,4)
		cPallet := cGet1Env 	
	Endif
	cSay3Env := ""

	If ChkFile("TMPITE")
		DbSelectArea("TMPITE")
		//DbGoTop()
		//Zap
        //LGS#20191029 - Substituido comando ZAP devido a utilização de função do banco.
        TCSqlExec("DELETE FROM " + oTempTbl1:GetRealName() )
	Endif

    nCount :=0

    cQry1 := ""
    cQry1 += " SELECT ZZK_CODIGO, ZZK_LOTE, ZZK_SEQENV, ZZK_PRODUT, ZZK_QUANT, ZZK_LOCORI, ZZJ_FLAG, ZZK_CODBAR, ZZK_PEDIDO , ZZJ_BORDER, ZZJ_TIPBOR, ZZJ_LOCALI "
    cQry1 += " FROM "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) "
    cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZJ_CODIGO = ZZK_CODIGO AND ZZK.D_E_L_E_T_ ='' "
    cQry1 += " WHERE (ZZJ.ZZJ_FILIAL = '"+XFILIAL("ZZJ")+"') "
    cQry1 += "  AND (ZZJ.D_E_L_E_T_ = '') "
    cQry1 += "  AND ZZK.ZZK_CODIGO = '"+cPallet+"' " 
    //cQry1 += "  AND (ZZJ_BORDER <> '') " 
    cQry1 += " ORDER BY ZZK_CODIGO, ZZK_SEQENV " 

    TCQuery cQry1 ALIAS "TCQ" NEW
	
    //nConOrd := 1
    DbSelectArea("TCQ")
    If !Eof()
	    If TCQ->ZZJ_FLAG $ '1.2'
			Messagebox("Tipo de Pallet inválido (Transferências Internas), verifique o código do Pallet bipado / digitado !!!","Atenção...",48)	  		
			oGet1Env:Setfocus()
        Else
			Do Case
       			Case TCQ->ZZJ_TIPBOR $ '1'
	            	cCBox2 := '1-AGLUTINADO'
    	   		Case TCQ->ZZJ_TIPBOR $ '2'
        	    	cCBox2 := '2-DEPOSITO - GRU'
       			Case TCQ->ZZJ_TIPBOR $ '3'
	            	cCBox2 := '3-REGIAO-RETIRA'
    	   		Case TCQ->ZZJ_TIPBOR $ '4'
        	    	cCBox2 := '4-EXPORTACAO'
    	   		Case TCQ->ZZJ_TIPBOR $ '5'
        	    	cCBox2 := '5-CARGA FECHADA'
	       		Case TCQ->ZZJ_TIPBOR $ '6'
    	        	cCBox2 := '6-AMOSTRAS'
       			Case TCQ->ZZJ_TIPBOR $ '7'
	            	cCBox2 := '7-VOL. QUEBRADO'
       			Case TCQ->ZZJ_TIPBOR $ '8'	            
	            	cCBox2 := '8-CARGA-MATRIZ'
    	   		Case TCQ->ZZJ_TIPBOR $ '9'
        	    	cCBox2 := '9-DEPOSITO - ARA'
				OtherWise
        	    	cCBox2 := '2-DEPOSITO'
			EndCase       		
	  		cGet2Env:=TCQ->ZZJ_BORDER
  			oGet2Env:Refresh()
			nCBox1Lo:=TCQ->ZZJ_LOCALI
			oCBox1Lo:Refresh()
			oBtn3Env:Enable()
		    oCBox2:Enable()
			oCBox1Lo:Enable()
		    While !Eof()

   			    nCapPallet := fVerCPall(TCQ->ZZK_PRODUT)
			    If nCapPallet <> nCapAntPal .and. (nCapAntPal <> 0) .or. lProdMist
					lProdMist := .t.
					cSay3Env  := "Produtos com capacidade de Pallett misturados"						
				Else
					If nCapPallet = 0
						cSay3Env := "Capacidade Total do Pallet ainda não cadastrada!"
                    Else
						cSay3Env := "Capacidade Total do Pallet"+TransForm(nCapPallet,"@E 9999")+" Volumes "
					Endif
				Endif
				nCapAntPal:= nCapPallet
				oSay3Env:Refresh()
	    		
	    		RecLock("TMPITE", .T.)
					TMPITE->TMPPAL := TCQ->ZZK_CODIGO
					TMPITE->TMPLOT := TCQ->ZZK_LOTE
	        	    TMPITE->TMPSEQ := TCQ->ZZK_SEQENV
		            TMPITE->TMPPRO := TCQ->ZZK_PRODUT
		            TMPITE->TMPQTD := TCQ->ZZK_QUANT
					TMPITE->TMPCBR := TCQ->ZZK_CODBAR
					TMPITE->TMPINV := Inverte(TCQ->ZZK_SEQENV)
					TMPITE->TMPPED := TCQ->ZZK_PEDIDO  
					nCount := (nCount + 1)
				MsUnLock()
		        DbSelectArea("TCQ")
		        DbSkip()
  			Enddo
		Endif
	Else
		Messagebox("Pallet Inexistente, verifique o número do Pallet digitado / bipado !!!","Atenção...",48)		
		cGet1Env := Space(11)
		oBtn3Env:Enable() 
		oCBox2:Enable()
		oCBox1Lo:Enable()
		oGet1Env:Setfocus()
    Endif
    DbSelectArea("TCQ")
	DbCloseArea()    
    
    oSay7Env:Refresh()
    
    If ChkFile("TMPITE")
   	    DbSelectArea("TMPITE")
        DbGoTop()
	    oBrw1Env:oBrowse:GoTop()
    	oBrw1Env:oBrowse:Refresh()
    Endif	
    oGet2Env:Disable()
    oCBox2:Disable()
	oCBox1Lo:Disable()
Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fIEtPallet() - Impressão da Etiqueta do Pallet
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fIEtPallet(cModelo)
    
    Local nPeso   := 0
    Local nVolume := 0  
    
	If cGet1Env $ "NOVO PALLET"   
   		Messagebox("Salve o Pallet antes de Imprimir a etiqueta !!!","Atenção...",48)
		Return
	Endif
    If Empty(Alltrim(cModelo))
   		Messagebox("Escolha o modelo da impressora antes de mandar a impressão !!!","Atenção...",48)
		Return
    Endif
	
	nPeso   := round(u_fPesPallet(cGet1Env),2)
    nVolume := U_fTotUnit(cGet1Env,2)
    
    If Alltrim(cModelo) $ "ZEBRA S4M" 
		cModelo   := "S4M"
    Elseif Alltrim(cModelo) $ "ZEBRA ZT230"
		cModelo   := "ZEBRA"
    Endif
    cPorta    := "LPT1" //Porta da impressora
    nTam      := 120    //Tamanho da etiqueta
    lTipo     := .f.    //.f.=Local; .t.=Servidor ou Outro Servidor
    lDrvWin   := .f.    //Usa Drive do Windows

	MSCBPRINTER(cModelo, cPorta, , nTam, lTipo, , , , , , lDrvWin)
       
    If !MSCBIsPrinter('LPT1')
    	Messagebox("Impressora não encontrada!","Atenção",48)
        MSCBCLOSEPRINTER()
		Return
  	Else   
	    MSCBBEGIN(1, 6, , .f.)
        MSCBSAYBAR(05, 03, StrTran(cGet1Env,"/","")	,"N", "MB07", 15, .F., .T., .F., , 3, 2)
        MSCBSay(06,25,"V. "+Alltrim(str(nVolume)) 	,"N", "0"	,"30,30")
        MSCBSay(28,25,"P. "+Alltrim(str(nPeso))   	,"N", "0"	,"30,30")
        MSCBSay(50,25,"B. "+Alltrim(cCBox2)			,"N", "0"	,"30,30")
           
        MSCBCHKSTATUS(.f.)
        cText := MSCBEND()
        MSCBCLOSEPRINTER()

	Endif
Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fMntPallet() - Manutenção dos itens de montagem do Pallet
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fMntPallet(nOpcMnt) // 1 - Monta / 2 - Desmonta
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Declaração de cVariable dos componentes                                 ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

	Private cGet1Mnt   := Space(20) 
 	Private cGet2Mnt   := Space(3)  
  	Private nGet3Mnt   := 0 	    
   	Private nGet7Mnt   := 0 	    
	Private cGet5Mnt   := Space(6)  
 	Private cGet4Mnt   := Space(30) 
  	//Private cSay1Mnt   := Space(1)
   	//Private cSay2Mnt   := Space(1)
    //Private cSay3Mnt   := Space(1)
    //Private cSay4Mnt   := Space(1)
    Private cSay6Mnt   := Space(140)
    Private cGet8Mnt   := Space(06)
    Private nGet9Mnt   := Space(04)
    Private nGetAMnt   := Space(04)
     
    Private nVolAtual  := 0
    Private lJaBipou   :=.f.

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
 	±± Declaração de Variaveis Private dos Objetos                             ±±
  	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
   	SetPrvt("oFontMn1", "oFontMn2", "oDlg1Mnt", "oSay1Mnt", "oSay4Mnt", "oSay2Mnt", "oSay3Mnt", "oGet1Mnt", "oGet2Mnt")
    SetPrvt("oGet3Mnt", "oBtn2Mnt", "oBtn1Mnt", "oGet4Mnt", "oSay5Mnt", "oGet5Mnt", "oSay6Mnt", "oGet7Mnt", "oGet8Mnt" )
	SetPrvt("oGet9Mnt", "oGetAMnt", "oSay8Mnt", "oSay9Mnt", "oSayAMnt", "oSayBMnt")           
	
	    
    If Empty(Alltrim(cGet1Env))
    	Return
    Endif
	
	If nOpcMnt == 1
		DbSelectArea("ZZJ")
		DbSetOrder(1)
		DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
		If Found() .and. (ZZJ->ZZJ_FILIAL == xFilial("ZZJ")) .and. (ZZJ->ZZJ_BORDER <>'')
			If ZZJ->ZZJ_FLAG == "4"
				Messagebox("Pallet já transformado em pedido de transferência e não pode ser alterado!!","Atenção...",48) 
	   			Return
		  	Endif
	    Endif
    Endif
    If Substr(cCBox2,1,1) $ '5.8' .and.(Empty(Alltrim(cGet2Env)) .or. Alltrim(cGet2Env) ="VARIOS")
    	Messagebox("Informe o número de bordero para compra de carga fechada, informação obrigatória!!","Atenção...",48) 
		Return		
    Endif
    oCBox2:Disable()
	oCBox1Lo:Disable()
    oGet2Env:Disable()
    
    If ChkFile("TMPITE")
   		DbSelectArea("TMPITE")
        DbGoTop()
       	oBrw1Env:oBrowse:GoTop()
       	oBrw1Env:oBrowse:Refresh()
    Endif

    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Definicao do Dialog e todos os seus componentes.                        ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    
    oFontMn1   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
    oFontMn2   := TFont():New( "MS Sans Serif", 0, -16, , .F., 0, , 400, .F., .F., , , , , , )
    oDlg1Mnt   := MSDialog():New( 258, 252, 400, 897, "Manutenção da Compra", , , .F., , , , , , .T., , , .T. )
    oSay1Mnt   := TSay():New( 009, 003, {|| "Codigo"   }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)
    oGet1Mnt   := TGet():New( 007, 037, {|u| If(PCount() > 0, cGet1Mnt := u, cGet1Mnt)}, oDlg1Mnt, 073, 012, '@!'              , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .F. , .F., ""   ,"cGet1Mnt", , )
    oSay4Mnt   := TSay():New( 026, 003, {|| "Descr.:"   }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)                                                                                         
    oGet4Mnt   := TGet():New( 025, 037, {|u| If(PCount() > 0, cGet4Mnt := u, cGet4Mnt)}, oDlg1Mnt, 206, 012, '@!'              , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"cGet4Mnt", , )
    oSay5Mnt   := TSay():New( 026, 250, {|| "Lote"     }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 024, 012)
    oGet5Mnt   := TGet():New( 025, 276, {|u| If(PCount() > 0, cGet5Mnt := u, cGet5Mnt)}, oDlg1Mnt, 024, 012, '@R X99999'       , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"cGet5Mnt", , ) // Jose 07/03/2025   '@R 999999' 
    oSay2Mnt   := TSay():New( 009, 120, {|| "Seq"      }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 024, 012)
    oGet2Mnt   := TGet():New( 007, 143, {|u| If(PCount() > 0, cGet2Mnt := u, cGet2Mnt)}, oDlg1Mnt, 024, 012, '@R 999'          , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"cGet2Mnt", , )
    oSay3Mnt   := TSay():New( 009, 180, {|| "Qtde"     }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 028, 012)
    oGet3Mnt   := TGet():New( 007, 205, {|u| If(PCount() > 0, nGet3Mnt := u, nGet3Mnt)}, oDlg1Mnt, 024, 012, '@E 999999'       , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"nGet3Mnt", , )
    oSay4Mnt   := TSay():New( 009, 250, {|| "Total"    }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 028, 012)
    oGet7Mnt   := TGet():New( 007, 276, {|u| If(PCount() > 0, nGet7Mnt := u, nGet7Mnt)}, oDlg1Mnt, 024, 012, '@E 999999'       , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"nGet7Mnt", , )
    oSay6Mnt   := TSay():New( 060, 004, {||  cSay6Mnt}, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 230, 011)                                                                                         
    oSay8Mnt   := TSay():New( 045, 003, {|| "Pedido"    }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
    oGet8Mnt   := TGet():New( 043, 037, {|u| If(PCount() > 0, cGet8Mnt := u, cGet8Mnt)}, oDlg1Mnt, 042, 012, '@!'              , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"cGet8Mnt", , )
    oSay9Mnt   := TSay():New( 045, 081, {|| "Qtd Pedido"}, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 055, 012)
    oGet9Mnt   := TGet():New( 043, 127, {|u| If(PCount() > 0, nGet9Mnt := u, nGet9Mnt)}, oDlg1Mnt, 034, 012, '@R 9999'         , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F.,  ""  ,"nGet9Mnt", , )
    oSayAMnt   := TSay():New( 045, 165, {|| "Separado"  }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 055, 012)
    oGetAMnt   := TGet():New( 043, 205, {|u| If(PCount() > 0, nGetAMnt := u, nGetAMnt)}, oDlg1Mnt, 034, 012, '@R 9999'         , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"nGetAMnt", , )

    //oBtn1Mnt   := TButton():New( 056, 272, "Confirma", oDlg1Mnt, {|| fManuPal(nOpcMnt)}  , 050, 014, , oFontMn2, , .T., , "", , , , .F. )
    oGet1Mnt:bLostFocus := {|| fValCodPro(nOpcMnt) }
    //oGet2Mnt:bLostFocus := {|| Iif(nOpcMnt == 2, fBusSequ(cGet2Mnt), cGet2Mnt) }
    oGet3Mnt:bLostFocus := {|| (nGet7Mnt := nGet3Mnt) }

    oDlg1Mnt:Activate( , , , .T.)

Return


/*ÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fValCodPro() - Validação do código do produto na manutenção do Pallet
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fValCodPro(nOpcMnt)  //1 - Montagem do Pallet 2- Desmontagem
 
    Local cQry 		:= ""
    Local nVol 		:= 0
    Local nPrazo    := 0
    Local nValida   := 0
    Local nQtdAtual := 0
    Local aGerEtq   := {}
    Local dDtValida := ""
    Local lMandarEmail,cEmailDest,cAssunto,cMensEmail
    Local _nXVALIDA := GetMv("MV_XVALIDA") //LGS#20200210 - Adequação de release 12.1.25 e posteriores ACIMA 120 dias
    Local _nXVALESP := GetMv("MV_XVALESP") //LGS#20200210 - Adequação de release 12.1.25 e posteriores   90 dias
    //Local _n
    
    //Local lProdMist :=.f.

    lJaBipou := .f.
    cCodBarra := Substr(cGet1Mnt,1,18)
	
	If Empty(Alltrim(cGet1Env)) .or. Empty(Alltrim(cCodBarra))
		Return
	Endif
	//If !(Len(Alltrim(cCodBarra)) == 12 .or. Len(Alltrim(cCodBarra)) == 14 .or. Len(Alltrim(cCodBarra)) == 18)
	If !(Len(Alltrim(cCodBarra)) == 14 .or. Len(Alltrim(cCodBarra)) == 18)
		Messagebox("Tamanho do código de Barras incompatível com os padrões utilizados (14 ou 18 digitos)!!","Verifique...",48)
	   	oGet1Mnt:SetFocus()
	   	Return
	Endif
	If Len(Alltrim(cCodBarra)) == 14 .and. Val(Substr(Alltrim(cCodBarra),9,2)) ==0 .and. nOpcMnt == 1
		Messagebox("Leitura da quantidade do código de barras incorreta. Bipe novamente, quantidade zero não permitida !!","Verifique...",48)
	   	oGet1Mnt:SetFocus()
	   	Return
	Endif
    DbSelectArea("TMPITE")
   	DbSetOrder(4)
   	DbGoTop()
	DbSeek(cGet1Env+cCodBarra, .F.)
	If Found()
		If nOpcMnt == 1
    		nGet7Mnt :=0
	    	nVol     :=0
  	   	   	lJaBipou :=.t.
			Messagebox("Produto JÁ foi bipado neste Pallet, verifique !!!","Atenção...",48)
			cGet1Mnt := PADR(cGet1Mnt,20,' ')
			oGet4Mnt:SetFocus()
  	   	   	Return
	    Endif
  	Else
	   	If nOpcMnt == 2 
			Messagebox("Produto não foi bipado neste Pallet, portanto não é possível retirá-lo!!!","Atenção...",48)
    		Return
	   	Endif  
    Endif
    
    DbSelectArea("ZZK")
    DbSetOrder(5)
	DbGoTop()    
    DbSeek(xFilial("ZZK")+cCodBarra, .t.)   
	If Found() 
	    If nOpcMnt == 1
			DbSelectArea("ZZJ")
			DbSetOrder(1)
			DbSeek(xFilial("ZZJ")+ZZK->ZZK_CODIGO, .t.)   
			If Found() .and. ZZJ->ZZJ_FLAG $ '3.4.5' .AND. (TRIM(ZZK->ZZK_PEDIDO <>''))
				Messagebox("Produto já digitado em OUTRO PALLET..: "+ZZK->ZZK_CODIGO+" !! Verifique ou faça a desmontagem antes de incluir neste Pallet !!","Atenção...",48)
				DbSelectArea("ZZK")
		    	DbCloseArea()

				DbSelectArea("ZZJ")
				DbCloseArea()

	    		oGet1Mnt:SetFocus()
	   			Return
	   		Endif
	   		DbSelectArea("ZZJ")
			DbCloseArea()
		Endif
	Endif    
	
	DbSelectArea("ZZK")
	DbCloseArea()
	
	//Cleber(15/05/18)-> Quando envia e-mail antes de gerar arquivo .txt atrasa emissão de etiquetas, tentar guardar informações para enviar email depois!
	lMandarEmail := .f.
	cEmailDest := ""
	cAssunto := ""
	cMensEmail := ""
    If Len(Alltrim(cCodBarra)) == 18
		DbSelectArea("SB1")
	    DbSetOrder(5)
		DbSeek(xFilial("SB1")+Substr(cGet1Mnt,1,12), .t.)                                                         
	 	If Found() 
  			If SB1->B1_MSBLQL <> '1'
	    		//If SB1->B1_TIPO $ 'PA'
					cGet5Mnt := '999999'//Substr(cGet1Mnt,1,6)
					cGet1Mnt := (SB1->B1_COD)  
				//Endif
			Else
				Messagebox("Produto bloqueado, verifique!!!","Atenção...",48)
       	     	oGet1Mnt:SetFocus()
           	  	cGet1Mnt := space(20)
           		oGet1Mnt:Refresh()
                cGet4Mnt := space(30)
   	            oGet4Mnt:Refresh()
       	        cGet2Mnt := space(3)
           	    oGet2Mnt:Refresh()
                nGet3Mnt := 0
       	        oGet3Mnt:Refresh()
   	            nGet7Mnt := 0
           	    oGet7Mnt:Refresh()
       			cGet5Mnt := space(6)
				oGet5Mnt:Refresh()
				cGet8Mnt:= space(6)
				oGet8Mnt:Refresh()
				nGet9Mnt:=space(4)
				oGet9Mnt:Refresh()
				nGetAMnt:=space(4)
				oGetAMnt:Refresh()
				Return
			Endif
		Endif
		DbSelectArea("SB1")
		DbCloseArea()	
    Else
    	DbSelectArea("SC2")
	    DbSetOrder(13)
	    DbSeek(xFilial("SC2")+Alltrim(Substr(cGet1Mnt,1,6)), .t.)
    	If Found() 
	    	While !lMandarEmail .and. !(SC2->(Eof())) .AND. (XFilial("SC2") == SC2->C2_FILIAL) .AND. (Substr(cGet1Mnt,1,6) == Alltrim(SC2->C2_LOTE)) 
				If Substr(cGet1Mnt,7,2) == Substr(SC2->C2_PRODUTO,11,2) 
					cGet5Mnt := Substr(cGet1Mnt,1,6)
					cGet1Mnt := (SC2->C2_PRODUTO)
					If Empty(SC2->C2_DATRF) .AND. (SC2->C2_QUJE = 0)	// disparar workflow chamado 
						Messagebox("Produto bipado, porém não existe nenhuma baixa do produto nesta o.p, entre em contato com o PCP !!","Atenção...",48) 				
						cAuxMens := "Produto bipado sem nenhuma baixa na ordem de produção de PA. "+chr(13)+chr(10)
					   	
				        cAuxMens +="Lote.........: "+(SC2->C2_LOTE)+chr(13)+chr(10)
						cAuxMens +="Produto......: "+SC2->C2_PRODUTO+chr(13)+chr(10)
 					    cAuxMens +=" "+chr(13)+chr(10)
						cAuxMens += chr(13)+chr(10)+"Prog. Origem : BRFATX68"

						//Cleber(15/05/18)-> Quando envia e-mail antes de gerar arquivo .txt atrasa emissão de etiquetas, tentar guardar informações para enviar email depois!
   						If Substr(SC2->C2_FILIAL,1,2)== "06"
						  //U_EnvMail("DISSOLTEX - Lote "+SC2->C2_LOTE+" já esta sendo comprado e a O.P ainda não foi baixada !",cAuxMens,silene@brasilux.com.br","")                       	  
		       		   	Else
		       		   		lMandarEmail := .t.
		       		   		cEmailDest := "pcp@brasilux.com.br"
		       		   		cAssunto := "BRASILUX - Lote "+SC2->C2_LOTE+" já esta sendo comprado e a O.P ainda não foi baixada !"
		       		   		cMensEmail := cAuxMens
		   				    //U_EnvMail("BRASILUX - Lote "+SC2->C2_LOTE+" já esta sendo comprado e a O.P ainda não foi baixada !",cAuxMens,"pcp@brasilux.com.br","")                       	  
						Endif   
					Endif 
					dDtValida:= u_ValidProd(SC2->C2_LOTE,SC2->C2_PRODUTO)
					nPrazo   := (dDtValida - dDataBase)

					If u_ValMesesPro(SC2->C2_PRODUTO) <= 6   // função que retorna validade em meses do produto
						//LGS#20200210 - Adequação de release 12.1.25 e posteriores
						//nValida := GetMv("MV_XVALESP") //100
						nValida := _nXVALESP //100
					Else
						//LGS#20200210 - Adequação de release 12.1.25 e posteriores
						//nValida := GetMv("MV_XVALIDA") //180
						nValida := _nXVALIDA //180
					Endif

					If nPrazo <= nValida 						
						Messagebox("Produto bipado vencerá em "+cValtoChar(nPrazo)+" dias e portanto não poderá ser comprado, entre em contato com o Supervisor  !!","Atenção...",48) 				
  					    cAuxMens := "Produto bipado vencerá em "+cValtoChar(nPrazo)+" dias e portanto não poderá ser comprado !"+chr(13)+chr(10)

				        cAuxMens +="Lote...............:  "+(SC2->C2_LOTE)+chr(13)+chr(10)
						cAuxMens +="Produto............:  "+SC2->C2_PRODUTO+chr(13)+chr(10)
 					    cAuxMens +="Validade...........:  "+DToc(dDtValida)+chr(13)+chr(10)
 					    cAuxMens +="Mínimo em dias.....:  "+cValToChar(nValida)+chr(13)+chr(10)

 					    cAuxMens +=" "+chr(13)+chr(10)
						cAuxMens += chr(13)+chr(10)+"Prog. Origem : BRFATX68"
        	
   						If Substr(SC2->C2_FILIAL,1,2)== "06"
						  //U_EnvMail("DISSOLTEX - Lote "+SC2->C2_LOTE+" com data inferior ao mínimo exigido para envio !",cAuxMens,silene@brasilux.com.br","")                       	  
		       		   	Else
		   				    U_EnvMail("BRASILUX - Lote "+SC2->C2_LOTE+" com data inferior ao mínimo exigido para envio !",cAuxMens,"expedicao@brasilux.com.br,pcp@brasilux.com.br","")                       	  
						Endif   
				  		cGet1Mnt:= PADR(cGet1Mnt,20,' ')

						DbSelectArea("SC2")
						DbCloseArea()
						Return
					Endif
				Endif
				DbSelectArea("SC2")
				DbSkip()        	
	  		Enddo
			DbSelectArea("SC2")
			DbCloseArea()
		Else
			DbSelectArea("SC2")
			DbCloseArea()
	  		cGet1Mnt:= PADR(cGet1Mnt,20,' ')
	   	   	Messagebox("Lote lido/digitado não existe, verifique !!!","Atenção...",48)
	   	   	//oGet1Mnt:SetFocus()
			Return
		Endif
    Endif
    If Alltrim(cGet1Mnt) == Alltrim(cCodBarra) // Se o código de barras não for traduzido para código de produto
     	cGet1Mnt:= PADR(cGet1Mnt,20,' ')
		Messagebox("Código de barras inválido ou lote ou op não apontada ou inexistente, verifique !!!","Atenção...",48)
   	   	//oGet1Mnt:SetFocus()
   	  	Return
    Endif

/*---  Jose 26/12/2024   inibido por solicitação do André -------------------------------------------------------------
    If nOpcMnt = 1
		// COMPRAR PRIMEIRO PEGANDO O MENOR QUANTIDADE E DEPOIS A SEQUENCIA DO PEDIDO MAIS ANTIGO
		cQry :=" SELECT TOP 1 ZF_CODIGO, C5_DTAPR, C6_NUM, C6_PRODUTO, B1_DESC, B1_TIPO, C6_QTDVEN, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, 'FALTA' =(ISNULL(SUM(ZZK_QUANT),0) - C6_QTDVEN) "
		cQry +=" FROM "+RetSqlName("SZG")+" SZG WITH(NOLOCK) "
//-------------  ACRESCENTADO POR JOSE 28/07/2022 --------------------------
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON (ZG_FILIAL  = C5_FILIAL) AND (SUBSTRING(ZG_PEDIDO,3,6) = C5_NUM) AND (SC5.D_E_L_E_T_ ='') "
//--------------------------------------------------------------------------
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) ON (ZG_FILIAL  = C6_FILIAL) AND (SUBSTRING(ZG_PEDIDO,3,6) = C6_NUM) AND (SC6.D_E_L_E_T_ ='') "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) ON (ZZK_FILIAL = C6_FILIAL) AND (ZZK_PRODUT = C6_PRODUTO) AND (ZZK_PEDIDO = C6_NUM) AND (ZZK.D_E_L_E_T_ ='') "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON (C6_FILIAL  = B1_FILIAL) AND (C6_PRODUTO = B1_COD) AND (SB1.D_E_L_E_T_ ='') " 
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON (F4_FILIAL  ='"+XFilial("SF4")+"') AND (F4_CODIGO = C6_TES) AND (SF4.D_E_L_E_T_ ='') "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SZF")+" SZF WITH(NOLOCK) ON (ZF_FILIAL  = ZG_FILIAL) AND (ZF_CODIGO = ZG_CODIGO) AND (SZF.D_E_L_E_T_ ='') "
		cQry +=" WHERE SZG.D_E_L_E_T_ ='' "
		cQry +=" AND ZG_FILIAL ='"+XFilial("SZG")+"' "
		If Empty(Alltrim(cGet2Env)) .or. Alltrim(cGet2Env) ="VARIOS"    			     // X - COMPRANDO FALTAS NA RAMPA COM TODOS OS PEDIDOS EM BORDERO DE DESPACHO
			cQry +=" AND ZF_TIPOBOR ='"+Substr(cCBox2,1,1)+"' AND ZF_FLAG IN('Y','X') "  // Y - COMPRANDO AS FALTAS NA RAMPA 
		Else																		     // Z - FINALIZADO COMPRA POR BIPE
			cQry +=" AND ZF_TIPOBOR ='"+Substr(cCBox2,1,1)+"' AND ZF_CODIGO ='"+Alltrim(cGet2Env)+"' "
		Endif
		cQry +=" AND C6_PRODUTO ='"+Alltrim(cGet1Mnt)+"' "
		cQry +=" AND F4_ESTOQUE ='S' "
		If GetMv("MV_XBIPFAT") == .F.
			cQry +=" AND C6_NOTA ='' "
		Endif
		cQry +=" GROUP BY ZF_CODIGO, C6_NUM, C6_PRODUTO, C6_QTDVEN, B1_DESC, B1_TIPO, C5_DTAPR "
		cQry +=" HAVING ISNULL(SUM(ZZK_QUANT),0) < C6_QTDVEN " 
//------------   INIBIDO POR JOSE 28/07/2022 E SUBSTITUIDO PELO DE BAIXO -----------------------------
//		cQry +=" ORDER BY ZF_CODIGO, FALTA DESC, C6_NUM " --- 10/08/2022
//      cQry +=" ORDER BY C5_DTAPR ASC, C6_NUM ASC , FALTA DESC"  //-----  23/08/2022
//----------------------------------------------------------------------------------------------------
        cQry +=" ORDER BY ZF_CODIGO ASC, C6_NUM ASC , FALTA DESC"
			   	TCQuery cQry ALIAS "TCQ1" NEW
    	DbSelectArea("TCQ1")	
        If !(TCQ1->(Eof())) 
----   Jose até aqui 26/12/2024 -----------------------------------------------------------------------*/
//   Acrescentado Jose 26/12/2024     por solicitação do André ------------------------------------------
    If nOpcMnt = 1
        // COMPRAR PRIMEIRO PEGANDO A MENOR QUANTIDADE E DEPOIS A SEQUENCIA DO PEDIDO MAIS ANTIGO
        cQry :=" SELECT TOP 1 C6_FILIAL, C6_NUM, C6_PRODUTO, B1_DESC, ( SELECT dbo.DetVol(C6_FILIAL,C6_PRODUTO) )  AS 'VOL', B1_TIPO, B1_RELVOL, C6_QTDVEN, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, 'FALTA' =(ISNULL(SUM(ZZK_QUANT),0) - C6_QTDVEN), " //, Z1_DESCRE
        cQry +="'VOLUME' = ( ( ISNULL ( SUM ( ZZK_QUANT ),0 ) - C6_QTDVEN ) / ( SELECT dbo.DetVol ( C6_FILIAL,C6_PRODUTO ) ) * -1) , "
        cQry +=" C9_BLOQ = (SELECT COUNT(C9_ITEM) FROM "+RetSqlName("SC9")+" SC9 WITH(NOLOCK) WHERE (C9_FILIAL  = C6_FILIAL) AND (C9_PEDIDO = C6_NUM) AND (SC9.D_E_L_E_T_ ='')  AND (C9_BLEST ='02') ), "
        cQry +=" TEMSC9  = (SELECT COUNT(*) FROM "+RetSqlName("SC9")+" SC9 WITH(NOLOCK) WHERE (C9_FILIAL  = C6_FILIAL) AND (C9_PEDIDO = C6_NUM) AND (SC9.D_E_L_E_T_ ='') ) "
        cQry +=" FROM "+RetSqlName("SZG")+" SZG WITH(NOLOCK) "
        cQry +=" LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) ON (ZG_FILIAL  = C6_FILIAL) AND (SUBSTRING(ZG_PEDIDO,3,6) = C6_NUM) AND (SC6.D_E_L_E_T_ ='') "
        cQry +=" LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) ON (ZZK_FILIAL = C6_FILIAL) AND (ZZK_PRODUT = C6_PRODUTO) AND (ZZK_PEDIDO = C6_NUM) AND (ZZK.D_E_L_E_T_ ='') "
        cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON (C6_FILIAL  = B1_FILIAL) AND (C6_PRODUTO = B1_COD) AND (SB1.D_E_L_E_T_ ='') "
        cQry +=" LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON (F4_FILIAL  ='"+XFilial("SF4")+"') AND (F4_CODIGO = C6_TES) AND (SF4.D_E_L_E_T_ ='') "
        cQry +=" WHERE SZG.D_E_L_E_T_ ='' "
        cQry +=" AND ZG_FILIAL ='"+XFilial("SZG")+"' "
        cQry +=" AND ZG_CODIGO ='"+Alltrim(cGet2Env)+"' "
        cQry +=" AND C6_PRODUTO ='"+Alltrim(cGet1Mnt)+"' "
        cQry +=" AND F4_ESTOQUE ='S' "
        If GetMv("MV_XBIPFAT") == .F.
            cQry +=" AND C6_NOTA ='' "
        Endif      
        cQry +=" GROUP BY C6_NUM, C6_PRODUTO, C6_QTDVEN, B1_DESC, B1_TIPO, C6_FILIAL, B1_RELVOL"
        cQry +=" HAVING ISNULL(SUM(ZZK_QUANT),0) < C6_QTDVEN "
        cQry +=" ORDER BY FALTA DESC, C6_NUM "

	   	TCQuery cQry ALIAS "TCQ1" NEW
    	DbSelectArea("TCQ1")	
        If !(TCQ1->(Eof())) 
            If GetMv("ZP_PAR0332") // verificar se o pedido que esta sendo separado
                If TCQ1->TEMSC9 == 0
                    Messagebox("Pedido( "+TCQ1->C6_NUM+" ) não pode ser separado pois NÃO tem itens COM estoque liberado!  Verifique com o Planejamento Logístico !!","Atenção...",48)
                    DbSelectArea("TCQ1")
                    DbCloseArea()
                    Return
                Elseif TCQ1->C9_BLOQ >0
                    Messagebox("Pedido( "+TCQ1->C6_NUM+" ) não pode ser separado pois tem itens SEM liberação de estoque!  Verifique com o Planejamento Logístico !!","Atenção...",48)
                    DbSelectArea("TCQ1")
                    DbCloseArea()
                    Return
                Endif
            Endif

//  Jose 26/12/2024  Até aqui ---------------------------------------------------------------------------

	    	If TCQ1->B1_TIPO $ 'PA.PI.MP.MC'
			   If ChkFile("TCR")
				  DbSelectArea("TCR")
				  DbCloseArea()
			   Endif
	            cQry := " "
	            cQry += " SELECT RELVOL = dbo.DetVol('"+xFilial("SB1")+"','"+(cGet1Mnt)+"')"
				TCQuery cQry ALIAS "TCR" NEW
	            DbSelectArea("TCR")
	            If Len(Alltrim(cCodBarra)) == 14 // etiquetas novas já trazem a relação de volumes 
					nGet3Mnt := Val(Substr(Alltrim(cCodBarra),9,2))
					If Val(TCR->RELVOL) < (nGet3Mnt)
				     	Messagebox("Quantidade bipada / digitada na etiqueta é maior do que volume cadastrado para o produto !!","Atenção...",48)
					    If ChkFile("TCR")
						    DbSelectArea("TCR")
			   				DbCloseArea()
				    	Endif
				    	DbSelectArea("TCQ1")
				    	DbCloseArea()
				    	Return
					Endif
				Else
	                //cQry := " "
	                //cQry += " SELECT RELVOL = dbo.DetVol('"+xFilial("SB1")+"','"+(cGet1Mnt)+"')"
				    //TCQuery cQry ALIAS "TCR" NEW
					nGet3Mnt := Val(TCR->RELVOL)
				Endif
				nGet7Mnt   := (nGet7Mnt + nGet3Mnt) // Soma no Total a quantidade bipada
				nVol 	   := (nGet7Mnt/nGet3Mnt)
			    _CodProd   := cGet1Mnt
			    nCapPallet := fVerCPall(_CodProd)
       			cGet2Mnt   := MaxSequ()
      			cGet4Mnt   := TCQ1->B1_DESC
				cGet8Mnt   := TCQ1->C6_NUM
				nGet9Mnt   := TCQ1->C6_QTDVEN
				nGetAMnt   := (TCQ1->ZZK_QUANT + nGet3Mnt) // já separado + quantidade bipada
                If nGetAMnt > nGet9Mnt  // se quantidade + bipe atual ultrapassa qtde total do pedido (caso dos proutos que tem mais de uma relação de volume)
                	Messagebox("Quantidade no volume bipado ultrapassa a total do pedido. Total Pedido( "+TransForm(nGet9Mnt,"@E 9999")+" ) !!, Verifique !!","Atenção...",48)
					oGet1Mnt:SetFocus()
					cSay6Mnt  := TransForm((nGetAMnt-nGet9Mnt), "@E 9999")+" unidades a mais, verifique a rel. de volumes !"
					nGet7Mnt  := (nGet7Mnt - nGet3Mnt) // subtrair total
					DbSelectArea("TCQ1")
			    	DbCloseArea()
					Return
				Endif                
			    If nCapPallet <> nCapAntPal .and. (nCapAntPal <> 0) .or. lProdMist
					lProdMist := .t.
					cSay3Env  := "Produtos com capacidade de Pallett misturados"						
				Else
					If nCapPallet = 0
						cSay3Env := "Capacidade Total do Pallet ainda não cadastrada!"
                    Else
						cSay3Env := "Capacidade Total do Pallet "+TransForm(nCapPallet,"@E 9999")+" Volumes"
						If lCheck
						     If (nCount + 1) > nCapPallet
						     	Messagebox("Capacidade do Pallet já foi atingida, não é possível incluir mais produtos neste Pallet !!!","Atenção...",48)
							    If ChkFile("TCR")
								    DbSelectArea("TCR")
					   				DbCloseArea()
						    	Endif
								DbSelectArea("TCQ1")
						    	DbCloseArea() 
						    
						    	DbSelectArea("TMPITE")
							   	DbSetOrder(1)
							   	DbGoTop()	

							 	oGet1Mnt:SetFocus()
							 	Return
							 Endif							 							     			
						Endif
					Endif
				Endif
				
    			nCount    := (nCount + 1)
				nCapAntPal:= nCapPallet
				oSay7Env:Refresh()
				oSay3Env:Refresh()
           	   	oGet1Mnt:SetFocus()
				cSay6Mnt  := "MONTAGEM - VOL. BIPADOS..:  "+Alltrim(TransForm(nCount, "@E 9999"))+Iif(nCapPallet <>0 .and. !lProdMist,"  RESTANDO ..: "+TransForm((nCapPallet-nCount),"@E 9999")," ")
			    If ChkFile("TCR")
				    DbSelectArea("TCR")
	   				DbCloseArea()
		    	Endif

				//Nelieder - 21/07/23 Bloqueio de Lote
				If BLQLOTE(cGet5Mnt)
					oSay7Env:Refresh()
					oSay3Env:Refresh()
					oGet1Mnt:SetFocus()
					DbSelectArea("TCQ1")
			    	DbCloseArea()
					return()
				EndIf	


			   	Begin Transaction
				   	If cGet1Env $ "NOVO PALLET"  // gravar o número do pallet na primeira inclusão do produto
				    	fGrvNPal()
				    Endif
	   	   			DbSelectArea("TMPITE")
   		   			RecLock("TMPITE", .T.)
						TMPITE->TMPPAL := (cGet1Env)
			            TMPITE->TMPPRO := cGet1Mnt
	    	    	    TMPITE->TMPSEQ := cGet2Mnt
	        	    	TMPITE->TMPQTD := nGet3Mnt
						TMPITE->TMPLOT := cGet5Mnt
			    		TMPITE->TMPCBR := (cCodBarra)
						TMPITE->TMPPED := cGet8Mnt
			            TMPITE->TMPINV := Inverte(TMPITE->TMPSEQ)
			            cGet1Mnt 	   := Space(20)
			            cGet1Mnt       := PADR(TMPITE->TMPPRO,20,' ')
				    MsUnLock()
					DbSelectArea("ZZK")
				    DbSetOrder(5)
					DbGoTop()    
				    DbSeek(xFilial("ZZK")+TMPITE->TMPCBR, .t.)   
   					If !Found() .OR. (Found() .AND. ALLTRIM(ZZK->ZZK_CODIGO) # ALLTRIM(TMPITE->TMPPAL))
			    		RecLock("ZZK", .T.)
							ZZK->ZZK_FILIAL := xFilial("ZZK")
							ZZK->ZZK_CODIGO := TMPITE->TMPPAL
							ZZK->ZZK_LOTE   := TMPITE->TMPLOT
							ZZK->ZZK_SEQENV := TMPITE->TMPSEQ
							ZZK->ZZK_PRODUT := TMPITE->TMPPRO
							ZZK->ZZK_QUANT  := TMPITE->TMPQTD
							ZZK->ZZK_CODBAR := TMPITE->TMPCBR
							ZZK->ZZK_DATA   := Date()
							ZZK->ZZK_HORA   := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
							ZZK->ZZK_FLAG   := '1' 
							ZZK->ZZK_PEDIDO := TMPITE->TMPPED
						MsUnLock()
					Endif
					aadd(aGerEtq, {cGet8Mnt+' '+cGet1Mnt})

					//***********************************************************************************/
					//*** BRASILUX
					//*** 12/11/2021 - Nelieder Corneta - Adequação para impressão de Etiquetas de volume
					//***								  pelo protheus (excluindo agente)							

					cPedido = cGet8Mnt /* pega valor do pedido */
					cProduto = cGet1Mnt /* pega valor do produto */

					/* pega valor do paramentro para habilitar a impressão pelo protheus */
					_Etinew := GETMV("ZP_PAR0033")
					if _Etinew == .F.
						FGerEtq(aGerEtq) /* usa impressão por agende */
					else
						U_BRPCP032(cPedido,cProduto) /* usa impressão pelo protheus */
					Endif						


					//FGerEtq(aGerEtq)
					// INCLUIR AQUI FUNÇÃO PARA BAIXAR ITEM DO RELATÓRIO DE FALTAS
                    DbSelectArea("ZZC")
                    DbSetOrder(2) // ZZC_FILIAL+ZZC_PEDIDO+ZZC_PRODUT                                                                                                                                
                    DbSeek(xFilial("ZZC")+TMPITE->TMPPED+TMPITE->TMPPRO, .t.)
                    If Found() .and. (ZZC->ZZC_FILIAL == XFilial("ZZC")) .and. (Alltrim(ZZC->ZZC_PEDIDO) == Alltrim(TMPITE->TMPPED)) .and. (Alltrim(ZZC->ZZC_PRODUTO) == Alltrim(TMPITE->TMPPRO)) 
                    	RecLock("ZZC", .f.)
                            ZZC->ZZC_RETIRA += TMPITE->TMPQTD
                            ZZC->ZZC_VOLRET += 1
                            ZZC->ZZC_SEPARA := Iif(nGet9Mnt = nGetAMnt,'S','N')
                            ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                            ZZC->ZZC_GAVETA := Iif(nGet9Mnt = nGetAMnt, Space(03),'999')
                        MsUnLock()
					Else
                       	RecLock("ZZC", .t.)
                           	ZZC->ZZC_FILIAL := xFilial("ZZC") //ZG_FILIAL+ZG_PEDIDO+ZG_CODIGO                                                                                                                                   
                            ZZC->ZZC_BORDER := Posicione("SZG", 2, xFilial("SZG")+'01'+TMPITE->TMPPED, "ZG_CODIGO")
                            ZZC->ZZC_PEDIDO := TMPITE->TMPPED
                            ZZC->ZZC_PRODUT := TMPITE->TMPPRO
                            ZZC->ZZC_QUANTI := nGet9Mnt
                            ZZC->ZZC_RETIRA += TMPITE->TMPQTD
                            ZZC->ZZC_VOLRET += 1   //ZB_FILIAL+ZB_PEDIDO+ZB_CODIGO                                                                                                                                   
                            ZZC->ZZC_CARGA  := Posicione("SZB", 2, xFilial("SZB")+'01'+TMPITE->TMPPED, "ZB_CODIGO")
                            ZZC->ZZC_GAVETA := Iif(nGet9Mnt = nGetAMnt, Space(03),'999')
                            ZZC->ZZC_TPINCL := 'W'
                            ZZC->ZZC_DESPAC := 'N'
                            ZZC->ZZC_SEPARA := Iif(nGet9Mnt = nGetAMnt,'S','N')
                            ZZC->ZZC_LOTE   := Space(06)
                            ZZC->ZZC_SEMID  := Space(01)
                            ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                            ZZC->ZZC_LOCEXP := Space(09)
                            ZZC->ZZC_RESERV := 0.0
                            ZZC->ZZC_VOLUME := 0
                            ZZC->ZZC_OCUPAC := 0
                       	MsUnLock()
					Endif
   	   			End Transaction
   	   		Else
 				Messagebox("Tipo de produto inválido, bipe somente PA, PI, MP e MC !!","Atenção...",48)
				oGet1Mnt:SetFocus()
				cGet1Mnt := space(20)
				oGet1Mnt:Refresh()
		   		cGet4Mnt := space(30)
			    oGet4Mnt:Refresh()
			    cGet2Mnt := space(3)
		    	oGet2Mnt:Refresh()
		   		nGet3Mnt := 0
			    oGet3Mnt:Refresh()
			   	nGet7Mnt := 0
	    		oGet7Mnt:Refresh()
			   	cGet5Mnt := space(6)
				oGet5Mnt:Refresh()
				cGet8Mnt:= space(6)
				oGet8Mnt:Refresh()
				nGet9Mnt:=space(4)
				oGet9Mnt:Refresh()
				nGetAMnt:=space(4)
				oGetAMnt:Refresh()
   	   		Endif
	 	Else
    		Messagebox("Este produto não faz parte do tipo de borderô escolhido /(ou)/ Todos os volumes deste produto já foram comprados para este tipo de borderô !!, Verifique!!!","Atenção...",48)
    		oGet1Mnt:SetFocus()
   		Endif
	
		DbSelectArea("TCQ1")
    	DbCloseArea()
    	
    	
	Elseif nOpcMnt = 2 // Retirada da carga
		DbSelectArea("TMPITE")
		DbSetOrder(4) // pallet + código de barras
		DbGoTop()    
	   	DbSeek(cGet1Env+cCodBarra, .F.)
		If Found() .AND. (Alltrim(TMPITE->TMPPAL) == Alltrim(cGet1Env))
			cGet4Mnt := Posicione("SB1", 1, xFilial("SB1")+TMPITE->TMPPRO, "B1_DESC")
	 		cGet5Mnt := TMPITE->TMPLOT
			cGet2Mnt := TMPITE->TMPSEQ
			cGet8Mnt := TMPITE->TMPPED
			nQtdAtual:= fProdPalle(1) // qtde de itens do mesmo produto no bordero 
			nGet9Mnt := fProdPalle(2) // qtde de itens do mesmo produto no pedido 
	        If Len(Alltrim(cCodBarra)) == 14
				nGet3Mnt := Val(Substr(Alltrim(cCodBarra),9,2))
			Else
		        cQry := ""
		        cQry += " SELECT RELVOL = dbo.DetVol('"+xFilial("SB1")+"','"+(cGet1Mnt)+"')"
			    TCQuery cQry ALIAS "TCR" NEW
				nGet3Mnt := Val(TCR->RELVOL)
			Endif
		    nGetAMnt := (nGet9Mnt-nGet3Mnt)
			nGet7Mnt 	:= (nQtdAtual-nGet3Mnt) // Subtrai no Total a quantidade bipada
			nVol		:= (nGet7Mnt/nGet3Mnt)
			nVolAtual 	:= (nVolAtual +1)
			cSay6Mnt  	:= "DESMONTAGEM - VOL. BIPADOS..:  "+TransForm(nVolAtual, "@E 9999")
		    _CodProd 	:= cGet1Mnt
  			nCount      := (nCount - 1)
			oSay7Env:Refresh()
			cGet1Mnt       := PADR(cGet1Mnt,20,' ')
	       	oGet4Mnt:Refresh()
           	oGet2Mnt:Refresh()
	   	   	oGet1Mnt:SetFocus()
		    If ChkFile("TCR")
			    DbSelectArea("TCR")
	   			DbCloseArea()
		    Endif
            
			Begin Transaction
				RecLock("TMPITE", .f.)
    	            DbDelete()             
       			MsUnLock()

				DbSelectArea("ZZK")
			    DbSetOrder(5)  // filial + código barras + pallet
				DbGoTop()            		
	    		DbSeek(xFilial("ZZK")+cCodBarra+cGet1Env, .t.)   
			    If Found() .and. (ZZK->ZZK_FILIAL == xFilial("ZZK")) .and. (Alltrim(ZZK->ZZK_CODIGO) == Alltrim(cGet1Env))
					RecLock("ZZK", .F.)
						DbDelete()
					MsUnlock()		
			    Endif
			    // Incluir aqui função para voltar item na tabela de faltantes	
                DbSelectArea("ZZC")
                DbSetOrder(2) // ZZC_FILIAL+ZZC_PEDIDO+ZZC_PRODUT                                                                                                                                
                DbSeek(xFilial("ZZC")+TMPITE->TMPPED+TMPITE->TMPPRO, .t.)
                If Found() .and. (ZZC->ZZC_FILIAL == XFilial("ZZC")) .and. (Alltrim(ZZC->ZZC_PEDIDO) == Alltrim(TMPITE->TMPPED)) .and. (Alltrim(ZZC->ZZC_PRODUTO) == Alltrim(TMPITE->TMPPRO)) 
	               	RecLock("ZZC", .f.)
       	                ZZC->ZZC_RETIRA := Iif((ZZC->ZZC_RETIRA - TMPITE->TMPQTD)>=0,(ZZC->ZZC_RETIRA - TMPITE->TMPQTD),0)
	                    ZZC->ZZC_VOLRET := Iif((ZZC->ZZC_VOLRET - 1)>=0,(ZZC->ZZC_VOLRET - 1),0)
                        ZZC->ZZC_SEPARA := Iif(nGet9Mnt = nGetAMnt,'S','N')
                        ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                        ZZC->ZZC_GAVETA := Iif(nGet9Mnt = nGetAMnt, Space(03),'999')
                    MsUnLock()
        		Endif

    		End Transaction
        Else
   			Messagebox("Produto não encontrado neste Pallet, verifique o volume bipado !!!","Atenção...",48)
			oGet1Mnt:SetFocus()
			cGet1Mnt := space(20)
			oGet1Mnt:Refresh()
	   		cGet4Mnt := space(30)
		    oGet4Mnt:Refresh()
		    cGet2Mnt := space(3)
		    oGet2Mnt:Refresh()
	   		nGet3Mnt := 0
		    oGet3Mnt:Refresh()
		   	nGet7Mnt := 0
	    	oGet7Mnt:Refresh()
		   	cGet5Mnt := space(6)
			oGet5Mnt:Refresh()
			cGet8Mnt:= space(6)
			oGet8Mnt:Refresh()
			nGet9Mnt:=space(4)
			oGet9Mnt:Refresh()
			nGetAMnt:=space(4)
			oGetAMnt:Refresh()
       	Endif
	Endif            

	if lMandarEmail
		U_EnvMail(cAssunto,cMensEmail,cEmailDest,"")
	endif                        	  
	
	DbSelectArea("TMPITE")
   	DbSetOrder(1)
   	DbGoTop()	

Return
 
/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fProdPalle(Opc)  1-) Total Pallet 2-) Total Pedido
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fProdPalle(Opc)

 	Local cArea := Alias()
 	Local aArea := U_PegaArea({"TMPITE"})
 	
    Local nQtd  := 0
    Local cQry1 := ""

	DbSelectArea("TMPITE")
   	DbSetOrder(2)
   	DbGoTop()	
    DbSeek(cGet1Env+cGet1Mnt, .F.)
    If !Eof()
    	While !Eof() .AND. (Alltrim(cGet1Env) == Alltrim(TMPITE->TMPPAL)) .AND. (Alltrim(cGet1Mnt) == Alltrim(TMPITE->TMPPRO))
    		If Opc == 2 .and. Alltrim(TMPITE->TMPPED) == Alltrim(cGet8Mnt)
				nQtd += TMPITE->TMPQTD
    		Else
	    		nQtd += TMPITE->TMPQTD
    		Endif
    		DbSkip()
    	Enddo
	Else
		cQry1 := ""
	    cQry1 += " SELECT SUM(ZZK_QUANT) AS ZZK_QUANT "
	    cQry1 += " FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
	    cQry1 += " WHERE ZZK.D_E_L_E_T_ ='' "
	    cQry1 += " AND ZZK_FILIAL = '"+XFILIAL("ZZK")+"' "
    	cQry1 += " AND ZZK.ZZK_CODIGO = '"+Alltrim(cGet1Env)+"' "
		If Opc == 2
			cQry1 += " AND ZZK.ZZK_PRODUT = '"+Alltrim(cGet1Mnt)+"' "   
			cQry1 += " AND ZZK.ZZK_PEDIDO = '"+Alltrim(cGet8Mnt)+"' "   
		Endif
		
    	TCQuery cQry1 ALIAS "TCQ" NEW
    	DbSelectArea("TCQ")	
        If !Eof()
		    nQtd := TCQ->ZZK_QUANT
		Endif
    	DbSelectArea("TCQ")	
    	DbCloseArea()
	Endif 
    
    U_VoltaArea(aArea)
	If !Empty(cArea)
		DbSelectArea(cArea)
	Endif
	    	
Return(nQtd)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fManuPal(nOpc)
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
/*Static Function fManuPal(nOpc)

 	If Len(Alltrim(cGet1Mnt)) == 0
		Messagebox("Bipe o código de barras antes de confirmar !!","Verifique...",48)		
	   	oGet1Mnt:SetFocus()
		Return
	Endif
	If nOpc == 1
 		If nGet7Mnt > 0
   			_cMaxSeq := cGet2Mnt
      	Endif
      	nQtdTotal := 0
	ElseIf nOpc == 2
    	If nGet7Mnt = 0
   	    	DbSelectArea("TMPITE")
   			DbSetOrder(2)
    		//DbSetOrder(5)
   			DbGoTop()
   			//DbSeek(cGet1Env+cGet1Mnt, .F.)
			DbSeek(cGet1Env+cGet1Mnt+cGet2Mnt, .F.)
   			If Found()
       	    	RecLock("TMPITE", .f.)
	            	DbDelete()             
   	          	MsUnLock()
   			Endif
        Elseif nGet7Mnt > 0
   	    	DbSelectArea("TMPITE")       //
   			DbSetOrder(2)
    		DbGoTop()
   			DbSeek(cGet1Env+cGet1Mnt+cGet2Mnt, .F.)
   			If Found()
      			RecLock("TMPITE", .f.)
	        		TMPITE->TMPQTD := nGet3Mnt                              			  
       	   		MsUnLock()
           	Endif
   	  	Endif
	Endif           			  
    oDlg1Mnt:End()
    DbSelectArea("TMPITE")
    DbSetOrder(1)
    DbGoTop()
         
Return  
*/

Static Function fNPal()

    If MsgYesNo("Confirma novo Pallet com tipo de borderô "+Alltrim(cCBox2)+" ?", "Atenção")

		If Empty(Alltrim(nCBox1Lo)) .and. alltrim(FWCodFil()) =='010101'
			Messagebox("Informe o local onde o Pallet esta sendo montado (FAB-1 / FAB-2 / ARA / DEPOS) !!","Verifique...",48)		
			oCBox1Lo:Setfocus()
			Return
		Endif


		cGet1Env := "NOVO PALLET"
		cSay3Env := ""
		lCheck   := .t.
		
	 	If ChkFile("TMPITE")
			DbSelectArea("TMPITE")
			//DbGoTop()
		 	//Zap
            //LGS#20191029 - Substituido comando ZAP devido a utilização de função do banco.
            TCSqlExec("DELETE FROM " + oTempTbl1:GetRealName() )
		Endif 
		oBtn3Env:Disable()
	    oCBox2:Disable()
		oCBox1Lo:Disable()
	    oGet2Env:Enable()
		oBrw1Env:oBrowse:GoTop()
		oBrw1Env:oBrowse:Refresh()
		oBtn4Env:Setfocus()	
	
	//Else
	//    oCBox2:Enable()
	//    oGet2Env:Enable()
	Endif
	
Return

Static Function fGrvNPal() // Grava Numeração do Pallet Antes de Salvar

	Local cQry1   := ""
	//Local cQry2   := ""
    Local nCodReg := ""
    //Local cLocali := ""
	//Local cNumIP  := GetClientIP()
	Local cBordero:= "VARIOS"    

    If cGet1Env $ "NOVO PALLET"  
       //Buscar o ultimo R_E_C_N_O_ para Inclusão
		cQry1 += " SELECT MAX(R_E_C_N_O_) AS R_E_C_N_O_ "
		cQry1 += " FROM  "+RetSqlName("ZZJ")+" WITH (NOLOCK) "

		TCQUERY cQry1 ALIAS "TCQ" NEW
		DbSelectArea("TCQ")
		DbGoTop()
		nCodReg := Str(TCQ->R_E_C_N_O_ + 1, 10)

		DbSelectArea("TCQ")
		DbCloseArea()
/*
       	// Buscar Localização baseado no cadastro de IP do Antivirus
		cQry2 += " SELECT Z11_LOCALI FROM "+RetSqlName("Z11")+" WITH(NOLOCK) "
		cQry2 += " WHERE D_E_L_E_T_ ='' AND D_E_L_E_T_ ='' AND Z11_CODIGO IN('000006') AND Z11_IP ='"+Alltrim(cNumIP)+"'"

		TCQUERY cQry2 ALIAS "TCR" NEW
		DbSelectArea("TCR")
		DbGoTop()
		If !Eof()
			cLocali := Alltrim(TCR->Z11_LOCALI)
		Endif		       
		DbSelectArea("TCR")
		DbCloseArea()
*/
		cQry1 := ""
		cQry1 += " SELECT TOP 1 ZZJ.ZZJ_CODIGO "
		cQry1 += " FROM "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) "
		cQry1 += " WHERE ZZJ.ZZJ_FILIAL = '"+xFilial("ZZJ")+"'"
       	//cQry1 += "  AND ZZJ.D_E_L_E_T_ = '' "
		cQry1 += "  AND ZZJ.ZZJ_DTINI  = '"+DTOS(Date())+"' "
		cQry1 += " ORDER BY ZZJ.ZZJ_CODIGO DESC "

		TCQUERY cQry1 ALIAS "TCQ" NEW
		DbSelectArea("TCQ")
		DbGoTop()

		cCodSeq := Iif(Empty(TCQ->ZZJ_CODIGO), SubStr(Dtos(Date()), 7, 2)+SubStr(Dtos(Date()), 5, 2)+SubStr(Dtos(Date()), 3, 2)+'/'+'0001', SubStr(TCQ->ZZJ_CODIGO, 1, 7)+StrZero(Val(SubStr(TCQ->ZZJ_CODIGO, 8, 4))+1, 4) )
		cNomArq := SubStr(cCodSeq, 8, 4)
		DbSelectArea("TCQ")
		DbCloseArea()
		
		cBordero := Iif(Alltrim(cGet2Env) ="", "VARIOS", Alltrim(cGet2Env))

		DbSelectArea("ZZJ")
		DbSetOrder(1)
		DbSeek(xFilial("ZZJ")+cCodSeq, .t.)   
		If !Found() 
			Reclock("ZZJ",.t.)
				ZZJ->ZZJ_FILIAL := xFilial("ZZJ")
				ZZJ->ZZJ_CODIGO := cCodSeq
				ZZJ->ZZJ_DTINI  := Date()
				ZZJ->ZZJ_HINI   := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
				ZZJ->ZZJ_FLAG   := '3'
				ZZJ->ZZJ_BORDER	:= cGet2Env
				ZZJ->ZZJ_USER   := __cUserId
				ZZJ->ZZJ_BORDER := cBordero
				ZZJ->ZZJ_LOCALI := nCBox1Lo
				ZZJ->ZZJ_TIPBOR := Substr(cCBox2,1,1)
			MsUnlock()
		Endif

/*
		cBordero := Iif(Alltrim(cGet2Env) ="", "VARIOS", Alltrim(cGet2Env))
		cQry1 := ""
		cQry1 += "INSERT INTO "+RetSqlName("ZZJ")+" (ZZJ_FILIAL,  ZZJ_CODIGO  ,  ZZJ_DTINI         , ZZJ_HINI                                       ,  R_E_C_N_O_ , ZZJ_FLAG,   ZZJ_USER     ,   ZZJ_BORDER  ,  ZZJ_LOCALI  ,   ZZJ_TIPBOR  ) "
		cQry1 += "                  VALUES('"+xFilial("ZZJ")+"', '"+cCodSeq+"',  '"+DTOS(Date())+"', '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "+nCodReg+" ,  '3'    , '"+__cUserId+"', '"+cBordero+"', '"+cLocali+"', '"+Substr(cCBox2,1,1)+"'  ) "
		XXX := TCSQLExec(cQry1)		
		If XXX <> 0
			cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
			MemoWrit(cNomArq, cQry1)
		Endif
*/
		If ChkFile("TMPITE")
			DbSelectArea("TMPITE")
		   	//DbGoTop()
	   	   	//Zap
           	//LGS#20191029 - Substituido comando ZAP devido a utilização de função do banco.
			TCSqlExec("DELETE FROM " + oTempTbl1:GetRealName() )
		Endif 

		oBtn3Env:Disable()  
		oCBox2:Disable()
		oCBox1Lo:Disable()
		cGet1Env := cCodSeq
		oGet1Env:Refresh()
    Endif

Return()


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fVerCPall() - Funcao para retornar capacidade de empilhamento do *
		  ³	Pallet de acordo com tabela ZZ por Embalagem MP                  *
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fVerCPall(_cProduto)
	
	Local cQry 			:= ""
	Local nCapacidade 	:= 0
	
	cQry += " SELECT G1_COD, X5_CHAVE, X5_DESCRI AS X5DESCRI  FROM "+RetSqlName("SX5")+" SX5 WITH(NOLOCK) "
	cQry += " LEFT OUTER JOIN "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) ON X5_FILIAL = '"+xFilial("SX5")+"' AND X5_CHAVE = G1_COMP AND SG1.D_E_L_E_T_ ='' "
	cQry += " WHERE SX5.D_E_L_E_T_ ='' AND X5_TABELA ='ZZ' AND G1_COD ='"+Alltrim(_cProduto)+"' AND G1_FILIAL ='"+xFilial("SG1")+"'"

    TCQUERY cQry ALIAS "TCP" NEW
    DbSelectArea("TCP")
    DbGoTop()	 
    If !Eof() .and. !Bof()
    	//nCapacidade := Val( ( TCP )->( X5_DESCRI ) )
    	nCapacidade := Val( TCP->X5DESCRI )
    Endif
    DbSelectArea("TCP")
    DbCloseArea()
          
Return(nCapacidade)    

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ FGerEtq() - Função que gera o arquivo txt contendo o produto e o *
		  ³	Pedido para uma pasta local, será lido pelo programa que imprimi *
		  ³	rá etiquetas de volume											 *
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function FGerEtq(aGerEtq)
	Local cLin      := ""
    Private cArqTxt := ""
    Private nHandle := ""
    Private nTamLin := 22
    Private cEOL    := "CHR(13)+CHR(10)"
    
    cEOL := Trim(cEOL)
    cEOL := &cEOL
    
	cArqTxt += "C:\TEMP\etq"
	cArqTxt += SUBSTR(DTOS(DATE()),7,2)+SUBSTR(DTOS(DATE()),5,2)
	cArqTxt += SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)+".txt"

	cLin := Space(nTamLin)+cEOL  // Variavel para criacao da linha do registros para gravacao
   	cCpo := aGerEtq[01][01] 
  	cLin := Stuff(cLin, 001, 022, cCpo)
   	nHandle := FCREATE(cArqTxt)          
   	If fWrite(nHandle, cLin, Len(cLin)) != Len(cLin)
       	If !MsgAlert("Ocorreu um erro na gravacao do arquivo da Etiqueta !","Atencao!")
           	Return
       	Endif
	Endif
	//FWrite(nHandle, cLin + CRLF)   
	FClose(nHandle)
	
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Function MaxSequ - Incremento de Sequencia na inclusão dos produtos no Pallet 
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MaxSequ() 
	
 	Local cArea := Alias()
 	Local aArea := U_PegaArea({"ZZK"})
	Local cQry1 := ""
	
    cQry1 := " SELECT ISNULL(MAX(ZZK_SEQENV), '0') AS ZZK_SEQENV FROM "+RetSqlName("ZZK")+" WITH(NOLOCK) WHERE ZZK_FILIAL = '"+xFilial("ZZK")+"' AND ZZK_CODIGO = '"+cGet1Env+"' AND D_E_L_E_T_ = '' "
    TCQuery cQry1 ALIAS "TMPSEQ" NEW
    DbSelectArea("TMPSEQ")
    cMaxSeq := StrZero(Val(TMPSEQ->ZZK_SEQENV) + 1, 3)
    DbSelectArea("TMPSEQ")
    DbCloseArea()
	
    U_VoltaArea(aArea)
	If !Empty(cArea)
		DbSelectArea(cArea)
	Endif
	 
Return(cMaxSeq)
                   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºDescricao ³ Apagar Itens e Cabeçalho de Pallet de compra                º±±
±±º          ³ (usado qdo há divergência nas contagens de o pallet é bipadoº±±
±±º             novamente)                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fDelPallet()
    
    Local lRet  := .f.
    Local cQry1 := " " 
    Local cQry2 := " " 

    If !SubStr(cAcessos, 2, 1) $ '*' //.or. !(PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0)
		Messagebox("Usuário sem permissão para Destruir Pallets !!","Atenção...",48) 	
		Return    
	Endif        
    
    If Empty(Alltrim(cGet1Env)) .or.  Empty(Alltrim(cGet2Env))
		Return
	Endif
    
 	DbSelectArea("ZZJ")
	DbSetOrder(1)
	DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
	If Found() 
		If ZZJ->ZZJ_FLAG $ '3'
			lRet := MsgBox("Deseja DESTRUIR este PALLET e todos os itens já bipados nele ?'","Pergunta","YESNO")
		    If lRet
				Begin Transaction
                    // Voltar itens bipados para a tabela ZZC (Faltas)
					If ChkFile("TMPITE")
				   	    DbSelectArea("TMPITE")
				        DbGoTop()
						While !Eof()
		                    DbSelectArea("ZZC")
        		            DbSetOrder(2) // ZZC_FILIAL+ZZC_PEDIDO+ZZC_PRODUT                                                                                                                                
                		    DbSeek(xFilial("ZZC")+TMPITE->TMPPED+TMPITE->TMPPRO, .t.)
		                    If Found() .and. (ZZC->ZZC_FILIAL == XFilial("ZZC")) .and. (Alltrim(ZZC->ZZC_PEDIDO) == Alltrim(TMPITE->TMPPED)) .and. (Alltrim(ZZC->ZZC_PRODUTO) == Alltrim(TMPITE->TMPPRO)) 
        		            	RecLock("ZZC", .f.)
                	                ZZC->ZZC_RETIRA := Iif((ZZC->ZZC_RETIRA - TMPITE->TMPQTD)>=0,(ZZC->ZZC_RETIRA - TMPITE->TMPQTD),0)
			                        ZZC->ZZC_VOLRET := Iif((ZZC->ZZC_VOLRET - 1)>=0,(ZZC->ZZC_VOLRET - 1),0)
                		            //ZZC->ZZC_RETIRA -= TMPITE->TMPQTD
                        		    //ZZC->ZZC_VOLRET -= 1
		                            ZZC->ZZC_SEPARA := 'N'
        		                    ZZC->ZZC_DTHOT  := DTOC(dDataBase)+' - '+Time()
                		            ZZC->ZZC_GAVETA := '999'
		                        MsUnLock()
							Endif										
					   	    DbSelectArea("TMPITE")
							DbSkip()
						Enddo	
				    Endif	

			   		cQry1 := " "
			   		cQry1 += " UPDATE "+RetSqlName("ZZJ")+" SET D_E_L_E_T_ ='*' FROM "+RetSqlName("ZZJ")+"  WHERE ZZJ_CODIGO ='"+cGet1Env+"'" 
			   		cQry1 += " AND D_E_L_E_T_ ='' AND ZZJ_FLAG IN('3') AND ZZJ_BORDER ='"+cGet2Env+"' AND ZZJ_FILIAL ='"+xFilial("ZZJ")+"'"
			   		XXX := TCSQLExec(cQry1) 
			        If XXX <> 0
			        	DisarmTransaction()
						Messagebox("Erro durante o processo de exclusão do Pallet !!","Atenção...",48) 	
					 	DbSelectArea("ZZJ")
						DbCloseArea()
			        	//Return  //LGS#20200210 - Adequação de release 12.1.25 e posteriores - Não pode usar return dentro de Begin transaction
			        Endif
	
			   		cQry2 := " "
			   		cQry2 += " UPDATE "+RetSqlName("ZZK")+" SET D_E_L_E_T_ ='*' FROM "+RetSqlName("ZZK")+"  WHERE ZZK_CODIGO ='"+cGet1Env+"'" 
			   		cQry2 += " AND D_E_L_E_T_ ='' AND ZZK_PEDIDO <>'' AND ZZK_FILIAL ='"+xFilial("ZZK")+"'"
			   		XXX := TCSQLExec(cQry2) 
			        If XXX <> 0
			        	DisarmTransaction()
						Messagebox("Erro durante o processo de exclusão do Pallet  !!","Atenção...",48) 	
					 	DbSelectArea("ZZJ")
						DbCloseArea()
			        	//Return  //LGS#20200210 - Adequação de release 12.1.25 e posteriores - Não pode usar return dentro de Begin transaction
			        Endif
				End Transaction					    

				Messagebox("Pallet "+cGet1Env+" foi DESTRUIDO e os produtos foram liberados !!","Atenção...",48) 

		    Endif
		Elseif ZZJ->ZZJ_FLAG $ '4'
			Messagebox("Não é possível DESTRUIR este Pallet, pois já foi transformado em pedido de transferência !","Atenção...",48) 
		Endif
	Else
		Messagebox("Pallet "+cGet1Env+" não encontrado, verifique !!","Atenção...",48) 	
	Endif
		 
 	DbSelectArea("ZZJ")
	DbCloseArea()
	
	fNPal() // novo pallet

Return()


/*/
{Protheus.doc} BLQLOTE
(long_description)
@type  Function
@author Nelieder Corneta
@since 20/07/2023
@param cLote
@return return
/*/
Static Function BLQLOTE(cLote)
Local cReturn := .F.

If _ZPPAR0118 // Bloqueio de lote = .T.

	DbSelectArea("ZAE")
	DbSetOrder(2)
	If DbSeek(xFilial("ZAE")+cLote)
		If ZAE->ZAE_TIPO == "1"
			U_ZPCPC02(cLote)
			cReturn := .T. // Lote está bloqueado
		EndIf 
	EndIf

EndIf	

Return cReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºDescricao ³ Impressão dos itens não comprados em um determinado borderoº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*
Static Function fImpInf()
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Declaracao de Variaveis                                             ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
       Local cDesc2        := "de acordo com os parametros informados pelo usuario."
       Local cDesc3        := "Relação de produtos não comprados no Bordero"
       Local cPict         := ""
       Local titulo        := "Relação de produtos não comprados "                                                          
       Local nLin          := 80
       Local Cabec1        := ""
       Local Cabec2        := ""
       Local imprime       := .T.
       Local aOrd          := {}
       Private lEnd        := .F.
       Private lAbortPrint := .F.
       Private CbTxt       := ""
       Private limite      := 80 
       Private tamanho     := "P"
       Private nomeprog    := "BRFATX66" // Coloque aqui o nome do programa para impressao no cabecalho
       Private nTipo       := 18
       Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
       Private nLastKey    := 0
       Private cPerg       := 'FATX66'
       Private m_pag       := 01
       Private wnrel       := "BRFATX66" // Coloque aqui o nome do arquivo usado para impressao em disco
       Private cString     := ''
       Private cRetLin     := ''


       If Empty(Alltrim(cGet2Env))
			Messagebox("Informe o código do Borderô de pedidos antes de consultar !","Atenção...",48)
			Return        
       Endif
        
	   oPerg()
       Pergunte('FATX66', .t.)

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta a interface padrao com o usuario...                           ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Limite := Iif(mv_par02 = 1, 132, 80)
       Tamanho:= Iif(mv_par02 = 1, "M", "P")
       wnrel  := SetPrint(cString, NomeProg,      , @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

       If nLastKey == 27
          Return
       Endif

       SetDefault(aReturn,cString)

       If nLastKey == 27
          Return
       Endif

       nTipo := If(aReturn[4]==1,15,18)

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       Processa({|| fRunRel(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ fRunRel  º Autor ³ 					   º Data ³  / /      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*
Static Function fRunRel(Cabec1, Cabec2, Titulo, nLin)

       Local cQry := ""

       If Empty(Alltrim(cGet2Env))
			Messagebox("Informe o código do Borderô de pedidos antes de consultar !","Atenção...",48)
			Return        
       Endif
        If Mv_Par02 = 1
		   Cabec1 := "PEDIDO  PRODUTO           (BORD "+cGet2Env+")                   QTD TOTAL  QTD COMPRA   QTD FALTA       GRP  LOCALIZAÇÃO      PROVISÓRIO"

		   cQry +=" SELECT C6_FILIAL, ZG_CODIGO, C6_NUM, ZG_LOCALIZ, C6_PRODUTO, B1_DESC, C6_QTDVEN, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, (C6_QTDVEN - ISNULL(SUM(ZZK_QUANT),0)) AS 'ZZK_FALTA', "
		   cQry +=" 'GRPEMB'    =ISNULL((SELECT TOP 1 B1_GRUPO2 FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
		   cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (G1_FILIAL = SB1.B1_FILIAL) AND (G1_COMP = SB1.B1_COD)  WHERE (SG1.D_E_L_E_T_ = '') AND (G1_FILIAL = C6_FILIAL) AND (G1_COD = C6_PRODUTO) AND (SB1.B1_GRUPO LIKE 'E%') AND (SB1.B1_GRUPO2 > '')),'99'),"
		   cQry +=" 'LOCALIZ'   =ISNULL((SELECT B2_LOCALIZ FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) WHERE B2_FILIAL = B1_FILIAL AND B2_COD = B1_COD AND B2_LOCAL = B1_LOCPAD AND SB2.D_E_L_E_T_ ='' ),''), "
		   cQry +=" 'ZZLLOCALIZ'=ISNULL((SELECT TOP 1 ZZL_LOCALI FROM "+RetSqlName("ZZL")+" ZZL WITH (NOLOCK) WHERE ZZL_FILIAL = B1_FILIAL AND ZZL_PRODUT = B1_COD AND ZZL.D_E_L_E_T_ ='' ),'')
		   cQry +="	FROM "+RetSqlName("SZG")+" SZG WITH (NOLOCK) "
		   cQry +="	LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON ZG_FILIAL = C6_FILIAL AND SUBSTRING(ZG_PEDIDO,3,6) = C6_NUM AND SC6.D_E_L_E_T_ ='' "
    	   cQry +="	LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PEDIDO = C6_NUM AND ZZK_PRODUT = C6_PRODUTO AND ZZK.D_E_L_E_T_ = '' "
		   cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = C6_FILIAL AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ ='' "
		   cQry +="	WHERE ZG_CODIGO = '"+cGet2Env+"'"
		   If Mv_Par01 = 1  // FILTRA OS SPRAYS DO RELATÓRIO
		 	   cQry +="	AND SUBSTRING(C6_PRODUTO,4,2) NOT IN('55') " 
		   Endif
		   cQry +=" AND ZG_FILIAL   = '"+xFilial("SZG")+"'"
		   cQry +=" AND SZG.D_E_L_E_T_ ='' "
		   cQry +="	GROUP BY ZG_CODIGO, C6_NUM, ZG_LOCALIZ, B1_DESC, C6_PRODUTO, C6_QTDVEN, B1_FILIAL, B1_COD, B1_LOCPAD, C6_FILIAL "
		   cQry +=" HAVING (C6_QTDVEN - ISNULL(SUM(ZZK_QUANT),0)) <> 0 "
		   cQry +=" ORDER BY 10,11,12,5,7,3 "
       Else
           /*
		   cQry +=" WITH TMP AS(SELECT C6_FILIAL, ZG_CODIGO, C6_NUM, C6_PRODUTO, C6_DESCRI, C6_QTDVEN , 'GRPEMB' =ISNULL((SELECT TOP 1 B1_GRUPO2 FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
		   cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (G1_FILIAL = SB1.B1_FILIAL) AND (G1_COMP = SB1.B1_COD)  WHERE (SG1.D_E_L_E_T_ = '') AND (G1_FILIAL = C6_FILIAL) AND (G1_COD = C6_PRODUTO) AND (SB1.B1_GRUPO LIKE 'E%') AND (SB1.B1_GRUPO2 > '')),'99')  "
		   cQry +=" FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
		   cQry +=" LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON ZG_FILIAL = C6_FILIAL AND SUBSTRING(ZG_PEDIDO,3,6) = C6_NUM AND SZG.D_E_L_E_T_ =''
		   cQry +=" WHERE SC6.D_E_L_E_T_ ='' AND C6_FILIAL ='"+xFilial("SC6")+"'" 
		   cQry +=" AND ZG_CODIGO ='"+cGet2Env+"' AND LEN(C6_PRODUTO)=12 ) "
		   cQry +=" SELECT TMP.ZG_CODIGO, C6_PRODUTO, C6_DESCRI, SUM(C6_QTDVEN) AS C6_QTDVEN, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, (SUM(C6_QTDVEN) - ISNULL(SUM(ZZK_QUANT),0)) AS 'ZZK_FALTA', TMP.GRPEMB, ISNULL(X5_DESCRI,'SEM CLASSFICAÇÃO') AS X5_DESCRI, COUNT(ZZK_PRODUT) AS 'VOLBIP' "
		   cQry +=" FROM TMP "
		   cQry +=" LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON TMP.C6_FILIAL = ZZK_FILIAL AND TMP.C6_NUM = ZZK_PEDIDO AND TMP.C6_PRODUTO = ZZK_PRODUT AND ZZK.D_E_L_E_T_ ='' "
		   cQry +=" LEFT OUTER JOIN "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) ON (SX5.D_E_L_E_T_ = '') AND (X5_FILIAL = '"+xFilial("SX5")+"') AND (X5_CHAVE = GRPEMB) AND SX5.D_E_L_E_T_ ='' AND X5_TABELA ='03' "
		   If Mv_Par01 = 1  // FILTRA OS SPRAYS DO RELATÓRIO
		 	   cQry +="	WHERE SUBSTRING(C6_PRODUTO,4,2) NOT IN('55') " 
 		   Endif
		   cQry +=" GROUP BY TMP.ZG_CODIGO, C6_PRODUTO, C6_DESCRI, TMP.GRPEMB, X5_DESCRI   "
		   //cQry +=" HAVING (C6_QTDVEN - ISNULL(SUM(ZZK_QUANT),0)) <> 0 "
		   cQry +=" HAVING (SUM(C6_QTDVEN) - ISNULL(SUM(ZZK_QUANT),0)) <> 0 "
		   cQry +=" ORDER BY TMP.GRPEMB, SUBSTRING(C6_PRODUTO,4,2), C6_PRODUTO "
             *

  		   Cabec1 := "   GRUPO          (BORDERO "+cGet2Env+")            QTD TOTAL  QTD COMPRA   QTD FALTA"

		   cQry +=" WITH TMP AS (SELECT C6_FILIAL, ZG_CODIGO, C6_PRODUTO, C6_NUM,  (C6_QTDVEN), ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, 'GRPEMB' =ISNULL((SELECT TOP 1 B1_GRUPO2 FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
		   cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (G1_FILIAL = SB1.B1_FILIAL) AND (G1_COMP = SB1.B1_COD)  WHERE (SG1.D_E_L_E_T_ = '') AND (G1_FILIAL = C6_FILIAL) AND (G1_COD = C6_PRODUTO) AND (SB1.B1_GRUPO LIKE 'E%') AND (SB1.B1_GRUPO2 > '')),'99'), COUNT(ZZK_PRODUT) AS 'VOLBIP' "
		   cQry +=" FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
		   cQry +=" LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON ZG_FILIAL = C6_FILIAL AND SUBSTRING(ZG_PEDIDO,3,6) = C6_NUM AND SZG.D_E_L_E_T_ =''
		   cQry +=" LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON SC6.C6_FILIAL = ZZK_FILIAL AND SC6.C6_NUM = ZZK_PEDIDO AND SC6.C6_PRODUTO = ZZK_PRODUT AND ZZK.D_E_L_E_T_ =''  
		   cQry +=" WHERE SC6.D_E_L_E_T_ ='' AND C6_FILIAL ='"+xFilial("SC6")+"'" 
		   If Mv_Par01 = 1  // FILTRA OS SPRAYS DO RELATÓRIO
		 	    cQry +=" AND SUBSTRING(C6_PRODUTO,4,2) NOT IN('55') " 
 		   Endif
		   cQry +=" AND ZG_CODIGO ='"+cGet2Env+"' AND LEN(C6_PRODUTO)=12 "
		   cQry +=" GROUP BY C6_FILIAL, ZG_CODIGO, C6_PRODUTO, C6_QTDVEN, C6_NUM ) "
		   cQry +=" SELECT TMP.ZG_CODIGO, SUM(C6_QTDVEN) AS C6_QTDVEN, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, (SUM(C6_QTDVEN) - ISNULL(SUM(ZZK_QUANT),0)) AS 'ZZK_FALTA', TMP.GRPEMB, ISNULL(X5_DESCRI,'SEM CLASSFICAÇÃO') AS X5_DESCRI  "
		   cQry +=" FROM TMP "
		   cQry +=" LEFT OUTER JOIN "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) ON (SX5.D_E_L_E_T_ = '') AND (X5_FILIAL = '"+xFilial("SX5")+"') AND (X5_CHAVE = GRPEMB) AND SX5.D_E_L_E_T_ ='' AND X5_TABELA ='03' "
		   cQry +=" GROUP BY TMP.ZG_CODIGO, TMP.GRPEMB, X5_DESCRI "
		   cQry +=" HAVING (SUM(C6_QTDVEN) - ISNULL(SUM(ZZK_QUANT),0)) <> 0  "
		   cQry +=" ORDER BY TMP.GRPEMB "
			
	   Endif	       	

       TCQuery cQry ALIAS "TCQ" NEW
       ProcRegua(RecCount())
       DbGoTop()
       While !Eof()
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Verifica o cancelamento pelo usuario...                             ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If lAbortPrint
                @ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif

             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Impressao do cabecalho do relatorio. . .                            ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                nLin += 1
             Endif
             
			 If Mv_Par02 = 1
	             //"PEDIDO  PRODUTO                                     QTD TOTAL  QTD COMPRA   QTD FALTA   LOCALIZAÇÃO          "
    	         // 999999	XX 999999999 123456789012345678901234567890   99999       99999      99999
        	     // 12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	             //          1         2         3         4         5         6         7         8         9         10        11
    	         @ nLin,001 PSAY TCQ->C6_NUM      Picture "@R XXXXXX"
        	     @ nLin,009 PSAY TCQ->C6_PRODUTO  Picture "@R XXXXXXXXXXXX"
            	 @ nLin,023 PSAY Substr(TCQ->B1_DESC,1,30) 
	             @ nLin,059 PSAY TCQ->C6_QTDVEN   Picture "@E 99999"
    	         @ nLin,071 PSAY Iif(TCQ->ZZK_QUANT=0, '-',TCQ->ZZK_QUANT)
        	     @ nLin,082 PSAY TCQ->ZZK_FALTA   Picture "@E 99999"
        	     @ nLin,098 PSAY TCQ->GRPEMB
        	     @ nLin,105 PSAY TCQ->LOCALIZ 
        	     @ nLin,122 PSAY TCQ->ZZLLOCALIZ
        	     
	             nLin += 1 // Avanca a linha de impressao

       	     Else

	             //"GRUPO   					  			  	  QTD TOTAL  QTD COMPRA   QTD FALTA"
    	         // 99	XXXXXXXXXXXXXXXXXXXXXXXXX    				 99999       99999      99999  
        	     // 12345678901234567890123456789012345678901234567890123456789012345678901234567890
	             //          1         2         3         4         5         6         7         8

    	         @ nLin,001 PSAY TCQ->GRPEMB      Picture "@R XX"
    	         @ nLin,005 PSAY Substr(TCQ->X5_DESCRI,1,30)   
	       	     //@ nLin,033 PSAY TCQ->C6_PRODUTO  Picture "@R XXXXXXXXXXXX"
            	 //@ nLin,049 PSAY Substr(TCQ->C6_DESCRI,1,30) 
	             @ nLin,048 PSAY TCQ->C6_QTDVEN   Picture "@E 99999"
    	         @ nLin,059 PSAY Iif(TCQ->ZZK_QUANT =0, '-', TCQ->ZZK_QUANT)  
        	     @ nLin,071 PSAY TCQ->ZZK_FALTA   Picture "@E 99999"
        	     //@ nLin,124 PSAY Iif(TCQ->VOLBIP =0, '-', TCQ->VOLBIP)

	             nLin += 1 // Avanca a linha de impressao
       	     
       	     Endif
       	  DbSelectArea("TCQ")
       	  DbSkip() // Avanca o ponteiro do registro no arquivo
	   EndDo

       DbSelectArea("TCQ")
       DbCloseArea()
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Finaliza a execucao do relatorio...                                 ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       SET DEVICE TO SCREEN

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Se impressao em disco, chama o gerenciador de impressao...          ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif
       MS_FLUSH()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oPerg() - Cria grupo de Perguntas.
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*
Static Function oPerg()

       Local aHelpPor := {}
	   AAdd(aHelpPor, {{"Filtra os Sprays do relatório de faltas ?"}, {""}, {""}})
	   AAdd(aHelpPor, {{"Faltas por Produto ou por Grupo ?"}		, {""}, {""}})

	   PutSX1( 'FATX66', '01', 'Filtra Sprays ? 		   ' , '', '', 'mv_ch1', 'N',01,00,01, 'C', '', ''        , ''          , '', 'mv_par01', 'Sim'    , '', '', '', ''     , 'Não'  , '', '', '', '', '', '', '', '', '', '', aHelpPor[1,1], {}, {} )
	   PutSX1( 'FATX66', '02', 'Faltas por Produto/ Grupo? ' , '', '', 'mv_ch2', 'N',01,00,01, 'C', '', ''        , ''          , '', 'mv_par02', 'Produto', '', '', '', ''     , 'Grupo', '', '', '', '', '', '', '', '', '', '', aHelpPor[1,2], {}, {} )

       aHelpPor := {}
Return

/*



User Function BRFATX69()

Local oDlg
Local cVar     := ""
Local cTitulo  := "Consulta Borderos"
Local lMark    := .F.
Local oOk      := LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo      := LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local oChk1
Local oChk2
Local cData

Private lChk1 := .F.
Private lChk2 := .F.
Private oLbx
Private aVetor := {}

dbSelectArea("SZF")
dbSetOrder(1)
dbSeek(xFilial("SZF"))

//+-------------------------------------+
//| Carrega o vetor conforme a condicao |
//+-------------------------------------+
While !Eof() .And. (SZF->ZF_FILIAL == xFilial("SZF")) 
   If (!SZF->ZF_FLAG $ 'D.T.R') .AND. (SZF->ZF_TIPOBOR =='2')	

        cData := TransForm(SZF->ZF_DATAINI,X3Picture("A6_SALATU"))
   		aAdd( aVetor, {	lMark	 , ;
   						ZF_CODIGO, ;
   						cData    } )
   Endif
   dbSkip()
End

//+-----------------------------------------------+
//| Monta a tela para usuario visualizar consulta |
//+-----------------------------------------------+
If Len( aVetor ) == 0
   Aviso( cTitulo, "Nao existe borderôs em aberto", {"Ok"} )
   Return
Endif

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL
   
@ 10,10 LISTBOX oLbx FIELDS HEADER ;
   " ", "BORDERO", "DATA INICIO" ;
   SIZE 230,095 OF oDlg PIXEL ON dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1])

oLbx:SetArray( aVetor )                                         	
oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),;
                       aVetor[oLbx:nAt,2],;
                       aVetor[oLbx:nAt,3]}}
	 
@ 110,10 CHECKBOX oChk1 VAR lChk1 PROMPT "Marca/Desmarca Todos" SIZE 70,7 PIXEL OF oDlg ;
         ON CLICK( aEval( aVetor, {|x| x[1] := lChk1 } ),oLbx:Refresh() )

//+----------------------------------------------------------------
//| ... ou utilizando a função aEval()
//+----------------------------------------------------------------
@ 110,95 CHECKBOX oChk2 VAR lChk2 PROMPT "Iverter a seleção" SIZE 70,7 PIXEL OF oDlg ;
         ON CLICK( aEval( aVetor, {|x| x[1] := !x[1] } ), oLbx:Refresh() )

DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER

Return
      
