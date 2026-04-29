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
±±³Programa  ³ BRFATX67  ³ Autor ³ André Maester       ³ Data ³ 06/08/15  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera Pedido de Transferência entre filiais por Pallet      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function BRFATX67() 

// Jose 11/11/2024   Acesso empresas 010101
     If !(alltrim(cNumEmp) == "01010101")
          cMens1 := "Acesso deverá ser feito pela Matriz!"
          MessageBox( cMens1, "Atenção", 48 )
          return
     Endif 
// Jose 11/11/2024 até aqui

	 Private cGet1Env   := Space(12) //"       /    "	Carga
     Private cSay1Env   := Space(01)
     Private cSay2Env   := Space(01)
     Private cSay4Env   := Space(20)
     Private cSay3Env   := Space(30)
     Private cGet5Env   := Space(02)
	 Private nCBox1Co   := ""
     Private cGet6Env   := ""//{"", "023818", "000521"}//'023818' // CLIENTE BRASILUX SP
     Private cCor4EnB   := CLR_BLUE
     Private cCor4EnR   := CLR_RED
     Private cCor4Env   := 0
     Private nCount     := 0
     Private nPeso      := 0
     Private nPesoTot   := Transform(0, "@E 999,999.99")
     Private cPallet    := ""
     Private lJaFech    := .f.
     Private lTelaJaFechada := .f. 
     Private oTempTbl1
   
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFontEnv", "oFon3Env", "oDlg1Env", "oGrp1Env", "oSay1Env", "oSay2Env", "oGet1Env", "oGet2Env", "oBtn1Env", "oBtn2Env")
     SetPrvt("oBtn3Env", "oBtn4Env", "oBtn5Env", "oBtn6Env", "oBtn7Env", "oBrw1Env", "oGrp3Env", "oSay4Env", "oBtn6Env", "oSay3Env")
     SetPrvt("oSay7Env", "oSay8Env", "oSay9Env", "oSayAEnv", "oSay2Env")

 	 If !u_VldAcesso(funname())
      	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
     	Return 
  	 Endif 

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFon1Env   := TFont():New( "Courier New"  , 0,  12, , .T., 0, , 400, .F., .F., , , , , , )
     oFontEnv   := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
     oFon2Env   := TFont():New( "Courier New"  , 0,  19, , .T., 0, , 400, .F., .F., , , , , , )
     oFon3Env   := TFont():New( "Courier New"  , 0,  25, , .T., 0, , 400, .F., .F., , , , , , )
     
     oDlg1Env   := MSDialog():New( 140, 264, 750, 1100, "Gera Pedido de Transferência", , , .F., , , , , , .T., , , .T. )  // Jose 11/04/2025  140, 264, 680, 980,
     oGrp1Env   := TGroup():New( 003, 004, 055, 500, "Dados da Carga", oDlg1Env, CLR_RED, CLR_WHITE, .T., .F. )  // Jose 11/04/2025   003, 004, 048, 356, 
     oSay1Env   := TSay():New( 012, 008, { || "Carga :"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
     oGet1Env   := TGet():New( 010, 041, { |u| If(PCount() > 0, cGet1Env := u, cGet1Env)}, oGrp1Env, 073, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGet1Env", , ) 
     oGet1Env:bLostFocus := {|| Iif(!Empty(Alltrim(cGet1Env)),fInfCarga(),"")}

     //oSay2Env   := TSay():New( 012, 008, { || "Carro :"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
     //oGet2Env   := TGet():New( 010, 040, { |u| If(PCount() > 0, cGet2Env := u, cGet2Env)}, oGrp1Env, 073, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGet2Env", , ) 
     
     oSay4Env   := TSay():New( 030, 152, { || cSay4Env  }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., cCor4Env, CLR_WHITE, 106, 012)
     oBtn1Env   := TButton():New( 009, 350, "Confirma", oGrp1Env, {|| fTrPLote()}, 052, 016, , oFontEnv, , .T., , "", , , , .T. ) // Jose 11/04/2025    009, 297,
     oBtn2Env   := TButton():New( 030, 350, "Abandona", oGrp1Env, {|| fSairTPa()}, 052, 016, , oFontEnv, , .T., , "", , , , .F. ) // Jose 11/04/2025    030, 297, 
     oGrp2Env   := TGroup():New( 059, 004, 268, 356, "", oDlg1Env, CLR_BLACK, CLR_WHITE, .T., .F. ) // Jose 11/04/2025 050, 004, 268, 356,

     oBtn3Env   := TButton():New( 068, 290, "<- Incluir ->" , oGrp2Env, {|| fMLocPall(1) }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )
     oBtn4Env   := TButton():New( 088, 290, "<- Excluir ->" , oGrp2Env, {|| fMLocPall(2) }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )
	 
	 
	 oSay2Env   := TSay():New( 138, 290, { || "Impressora"}, oGrp2Env, , oFon2Env, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012) // 138
     oCBox1Co   := TComboBox():New( 148, 290, {|u| If(PCount() > 0, nCBox1Co := u, nCBox1Co)}, {"", "ZEBRA S4M", "ZEBRA ZT230"}, 060, 016, oGrp2Env, , , , CLR_BLACK, CLR_WHITE, .T., oFon2Env, "", , , , ,  , , nCBox1Co ) // 138
     oBtn6Env   := TButton():New( 169, 290, "<- Imp.Etq ->" , oGrp2Env, {|| fIEtPallet(nCBox1Co) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. ) // 148

     oSay6Env   := TSay():New( 012, 120, {|| "Destino:"     }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 035, 012)  // Jose 11/04/2025   012, 202,

//   oSay6Env   := TSay():New( 030, 120, {|| "023818-Brasilux X Guarulhos"     }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 137, 030)  // Jose 11/04/2025  
//	 oSay6Env   := TSay():New( 040, 120, {|| "052817-Brasilux X Araraquara"    }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 137, 030)  // Jose 11/04/2025  
   //oGet6Env   := TGet():New( 010, 242, {|u| If(PCount() > 0, cGet6Env := u, cGet6Env)}, oDlg1Env, 036, 012, '@R 999999'          , , CLR_BLACK, CLR_WHITE, oFontEnv, , , .T., "", , , .F., .F., , .F. , .F., "SA1"    ,"cGet6Env", , )
   //oGet6Env   := TComboBox():New( 010, 159, {|u| If(PCount() > 0, cGet6Env := u, cGet6Env)}, {"", "023818", "052817"}, 050, 030, oGrp1Env, , , , CLR_BLACK, CLR_WHITE, .T., oFontEnv, "", , , , ,  , , cGet6Env )   // Jose 11/04/2025   010, 142,   050, 016,
     oGet6Env   := TComboBox():New( 010, 159, {|u| If(PCount() > 0, cGet6Env := SubStr(u, 1, 6), cGet6Env)}, {"", "023818 - Brasilux X Guarulhos", "052817 - Brasilux X Araraquara"}, 150, 030, oGrp1Env, , , , CLR_BLACK, CLR_WHITE, .T., oFontEnv, "", , , , ,  , , cGet6Env )   // Jose 11/04/2025    050, 030,

     oSay8Env   := TSay():New( 222, 283, { || "Pallets:"}, oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 050, 020)
     oSay7Env   := TSay():New( 222, 338, { || nCount    }, oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 020, 020)

     oSayAEnv   := TSay():New( 240, 288, { || "<- Peso ->"} , oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 020)
     oSay9Env   := TSay():New( 253, 284, { || nPesoTot    } , oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 065, 020)

     //oBtn5Env 	:= TButton():New( 238, 290, "<-Transfere->" , oGrp2Env, {|| fTrLocais( )  }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )     
     oSay3Env   := TSay():New( 031, 020, { || cSay3Env  },   oGrp1Env, , oFon2Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 245, 012)

     //oBtn7Env 	:= TButton():New( 128, 288, "<-Res Pallet->" , oGrp2Env, {|| U_fResPallet(2) }, 064, 016, , oFon2Env, , .T., , "", , , , .F. )
 	 //oBtn7Env:lVisibleControl := .f.	

     oBtn6Env 	:= TButton():New( 188, 288, "<-Res  Carga->"  , oGrp2Env, {|| fImpRel()       }, 064, 014, , oFon2Env, , .T., , "", , , , .F. ) // 064,016    

	 // Jose 09/10/2024  acrescentado 
     oBtn6Env 	:= TButton():New( 205, 284, "<-Dest.Pallet->" , oGrp2Env, {|| fDesPla()       }, 070, 014, , oFon2Env, , .T., , "", , , , .F. )
	 // Jose 09/10/2024  até aqui               
 	 //oBtn6Env:lVisibleControl := .f.	

     oTblTrans()
     DbSelectArea("TMPTRANS")
     DbSetOrder(1)
     DbGoTop()
     oBrw1Env   := MsSelect():New( "TMPTRANS", "", "", { {"TMPPAL", "", "Pallet", "@!"}, { "TMPVOL", "", "Volume", "@!"},{ "TMPUNI", "", "Qtd. Unit", "@!"},{ "TMPPES", "", "Peso", "@E 999,999.99"} ,{ "TMPSTA", "", "Pedidos", "@!"}}, .F., , {065, 007, 266, 280}, , , oGrp2Env ) // Jose 11/04/2025   056, 007, 266, 280
     
     oBrw1Env:oBrowse:oFont          := oFon2Env
     oBrw1Env:oBrowse:lAdjustColSize := .t.
     oBrw1Env:oBrowse:Refresh()
   	 oBtn3Env:SetFocus()
     
     oDlg1Env:Activate(,,,.T.)
     
     If !lJaFech
     	lTelaJaFechada := .t.
     Endif
     oTempTbl1:Delete()
Return  

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fIEtPallet() - Impressão da Etiqueta do Pallet
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fIEtPallet(cModelo)
    

    If Empty(Alltrim(cModelo))
   		Messagebox("Escolha o modelo da impressora antes de mandar a impressão !!!","Atenção...",48)
		Return
    Endif
	
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
  	Endif  
	DbSelectArea("TMPTRANS")
    DbSetOrder(1)
    DbGoTop()
	
	While (TMPTRANS->(!Eof()))


	    MSCBBEGIN(1, 6, , .f.)
        MSCBSAYBAR(05, 03, StrTran(TMPTRANS->TMPPAL,"/","")	       ,"N", "MB07", 15, .F., .T., .F., , 3, 2)
        MSCBSay(06,25,"VOL. "+Alltrim(str(TMPTRANS->TMPVOL)) 	   ,"N", "0"	,"30,30")
      //MSCBSay(28,25,"P. "+Alltrim(str(TMPTRANS->TMPPES))   	   ,"N", "0"	,"30,30")
        MSCBSay(32,25,"PEDIDO "+Alltrim(Substr(TMPTRANS->TMPSTA,1,9))+U_fNumNf(Substr(TMPTRANS->TMPSTA,1,6)) ,"N", "0"	,"30,30")
        MSCBCHKSTATUS(.f.)
        cText := MSCBEND()
        MSCBCLOSEPRINTER()
		


		DbSelectArea("TMPTRANS")
		DbSkip()
    Enddo

	
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fSairTPa() Função para perguntar antes de fechar a tela
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fSairTPa()

	If ChkFile("TMPTRANS")
		DbSelectArea("TMPTRANS")
		DbClosearea()
	Endif
    oDlg1Env:End()
    
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fTrPLote() - Geração  do pedido de transferência entre filiais através
                         dos Pallets separados na compra de produtos
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fTrPLote()

Local aCabec    := {}
Local aItens    := {}
Local aLinha    := {}
Local aProdBloq := {}
Local aProdNVend:= {}
Local aCustErro := {}
Local nDe 		:= 0
Local nPrcVen   := 0
Local _cItem    := ""
Local cObs      := ""
Local cNPedidos := ""
Local cAuxMens  := ""
//Local cLocPro   := ""
Local cQry      := ""
Local cQry1     := ""
Local cCodCARGA := ""
Local nW, nZ, nX, nI, nE, _nY
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.
//Private lCancelaTran:= .F.

	If Empty(Alltrim(cGet6Env))
		Return
	Endif
	If !Empty(Alltrim(cGet1Env))
		Return
	Endif
	If ChkFile("TMPTRANS") 
		DbSelectArea("TMPTRANS")
	    DbSetOrder(1)
	    DbGotop()
	Else
		Messagebox("Inclua ao menos um Pallet antes de tentar gerar o pedido de transferência !!","Atenção...",48)		
		Return
	Endif

    cPallets := "('"
    cObs     :=	"REMESSA ENTRE MATRIZ -> DEPÓSITO "+cGet6Env+" - (PALLETS BIPADOS) "
    
	DbSelectArea("TMPTRANS")
	DbGotop()
	While (TMPTRANS->(!Eof()))

        cPallets += TMPTRANS->TMPPAL+"', '"
        cObs 	 += TMPTRANS->TMPPAL+" / "
    	DbSelectArea("TMPTRANS")
	  	DbSkip()
    Enddo

    cPallets := SubStr(cPallets, 1, Len(cPallets)-3)+")"
	cObs     := SubStr(cObs, 1, Len(cObs)-3)	
	/*
	cQry1 := " "
	cQry1 += " SELECT ZZK_PRODUT, SUM(ZZK_QUANT) AS ZZK_QUANT, B1_MSBLQL, B1_VEND "//, B1_UM "
	cQry1 += " FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON ZZK_FILIAL = B1_FILIAL  AND ZZK_PRODUT = B1_COD AND SB1.D_E_L_E_T_ ='' "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZJ_CODIGO = ZZK_CODIGO AND ZZJ.D_E_L_E_T_ ='' "
	cQry1 += " WHERE ZZK.D_E_L_E_T_ ='' " 
	cQry1 += " AND ZZK_CODIGO IN "+cPallets
	cQry1 += " AND ZZJ_FLAG IN('3','4') "
	cQry1 += " AND ZZJ_FILIAL ='"+xFilial("ZZJ")+"'"
	cQry1 += " GROUP BY ZZK_PRODUT, B1_MSBLQL, B1_VEND" //, B1_DESC" //, B1_UM "  
	cQry1 += " ORDER BY SUBSTRING(ZZK_PRODUT,4,2), ZZK_PRODUT "
	*/

	cQry1 := " "
	cQry1 += " SELECT ZZK_PRODUT, SUM(ZZK_QUANT) AS ZZK_QUANT, B1_MSBLQL, B1_VEND, B1_TIPO, B1_PRV1, B2_CM1 "//, B1_UM "
	cQry1 += " FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON ZZK_FILIAL = B1_FILIAL  AND ZZK_PRODUT = B1_COD AND SB1.D_E_L_E_T_ ='' "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZJ_CODIGO = ZZK_CODIGO AND ZZJ.D_E_L_E_T_ ='' "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON B2_FILIAL = B1_FILIAL AND B2_COD = B1_COD AND B2_LOCAL = CASE WHEN B1_TIPO ='MP' THEN '01' ELSE CASE WHEN B1_TIPO ='PI' THEN '02' ELSE CASE WHEN B1_TIPO ='PA' THEN '03' ELSE CASE WHEN B1_TIPO ='MC' THEN '04' ELSE B1_LOCPAD END END END END AND SB2.D_E_L_E_T_ ='' "
	cQry1 += " WHERE ZZK.D_E_L_E_T_ ='' " 
	cQry1 += " AND ZZK_CODIGO IN "+cPallets "
	cQry1 += " AND ZZJ_FLAG IN('1','2','3','4') " 
	cQry1 += " AND ZZJ_FILIAL ='"+xFilial("ZZJ")+"'"
	cQry1 += " GROUP BY ZZK_PRODUT, B1_MSBLQL, B1_VEND, B1_TIPO, B2_CM1, B1_PRV1 " //, B1_DESC" //, B1_UM "  
	cQry1 += " ORDER BY SUBSTRING(ZZK_PRODUT,4,2), ZZK_PRODUT "

	TCQuery cQry1 ALIAS "TCQ" NEW
	DbSelectArea("TCQ")
	DbGoTop()
	
	aTrPallet 	:= {} 

	If TCQ->(EOF())  
   		Messagebox("Não encontrado produtos dentro dos pallets informados ! ","Atenção...",48)  
		DbSelectArea("TCQ")
		DbCloseArea()
		Return
	Else
		While !(TCQ->(EOF()))  
    		aAdd(aTrPallet, {TCQ->ZZK_PRODUT ,TCQ->ZZK_QUANT, TCQ->B1_TIPO, TCQ->B2_CM1, TCQ->B1_PRV1 }) //, TCQ->B1_DESC, TCQ->B1_UM})
	   		If TCQ->B1_MSBLQL ='1'
				aAdd(aProdBloq, {Alltrim(TCQ->ZZK_PRODUT)} )	
		   	Endif
		   	If TCQ->B1_VEND ='N'
				aAdd(aProdNVend, {Alltrim(TCQ->ZZK_PRODUT)} )		   	
	   		Endif
	   		DbSelectArea("TCQ")
   	  		DbSkip()
		Enddo
		DbSelectArea("TCQ")
		DbCloseArea()
	Endif

	Begin Transaction    

		If Len(aProdBloq) >0
			For nW := 1 to Len(aProdBloq)
	    	    cQry1 := ""
		        cQry1 := " UPDATE "+RetSqlName("SB1")+" 
		        cQry1 += " SET B1_MSBLQL  = '2' "     
        		cQry1 += " WHERE B1_FILIAL = '"+xFilial("SB1")+"'"
        	   	cQry1 += " AND B1_MSBLQL ='1' "
    	        cQry1 += " AND (D_E_L_E_T_ ='') AND B1_COD ='"+aProdBloq[nW][1]+"'"
	            TCSQLExec(cQry1)
    	    Next
		Endif	
		If Len(aProdNVend) >0
			For nZ := 1 to Len(aProdNVend)
	    	    cQry1 := ""
		        cQry1 := " UPDATE "+RetSqlName("SB1")+" 
		        cQry1 += " SET B1_VEND  = 'S' "     
        		cQry1 += " WHERE B1_FILIAL = '"+xFilial("SB1")+"'"
        	   	cQry1 += " AND B1_VEND ='N' "
    	        cQry1 += " AND (D_E_L_E_T_ ='') AND B1_COD ='"+aProdNVend[nZ][1]+"'"
	            TCSQLExec(cQry1)
    	    Next
	    Endif

		For nX := 1 To Ceiling(Len(aTrPallet)/150)       
		   	aCabec    := {}
	       	aItens    := {}
 		    _cItem    := 0
 		    nY 		  := 1
 		  //_cNumPed  := GetSxeNum("SC5","C5_NUM")

 		  //aAdd(aCabec,{"C5_FILIAL"     ,		xFilial("SC5")     										,Nil})
  	   	  //aAdd(aCabec,{"C5_LOJACLI"    ,		Posicione("SA1", 1, xFilial("SA1")+cGet6Env, "A1_LOJA")	,Nil})
		  //aAdd(aCabec,{"C5_NUM"        ,		_cNumPed												,.f.})
       		aAdd(aCabec,{"C5_TIPO"       ,		"N"              										,Nil})
	       	aAdd(aCabec,{"C5_CLIENTE"    ,		cGet6Env     											,Nil})
       		aAdd(aCabec,{"C5_EMISSAO"    ,		dDatabase          										,Nil})
       		aAdd(aCabec,{"C5_CONDPAG"    ,		"001"            									  	,Nil})
   	   	aAdd(aCabec,{"C5_TPFRETE"    , 		"C"                             					    ,NIL})       
 		aAdd(aCabec,{"C5_DEPOSI"     , 		"N"   							                        ,NIL})  
       		aAdd(aCabec,{"C5_TRANSP"     ,		"00250"      	   										,Nil})
	       	//aAdd(aCabec,{"C5_REDESP"     ,		"" 		  	   											,Nil})
    	   	aAdd(aCabec,{"C5_OBS"        ,		cObs      												,Nil})
		aAdd(aCabec,{"C5_X_OBSFA"    ,		cObs      												,Nil})
		aAdd(aCabec,{"C5_OBSNF"      , 		"Transferência de Mercadorias para DEPÓSITO FECHADO!!"	,NIL})


			DbSelectArea("SX3")
			SX3->( DbSetOrder(1) )
			SX3->( DbSeek( "SX5" ) )
			While !Eof() .and. SX3->X3_ARQUIVO == 'SC5'
			      If Alltrim( SX3->X3_CAMPO ) != 'C5_NUM'
				     _wVar := "M->" + SX3->X3_CAMPO
					 &wVar := CriaVar( SX3->X3_CAMPO )
				  Endif
			      SX3->( DbSkip( ) )
			EndDo
			For _nY := 1 To Len( aCabec )
			    Private &( "M->" + aCabec[_nY][1] ) := aCabec[_nY][2]
			Next
		  //cNPedidos += _cNumPed+" / " 
	    			//  (Limite definido para quebra dos pedidos de transferência)   
			For nI:= (nDe + 1) To Iif((150 + nDe) <= Len(aTrPallet), (150 + nDe), Len(aTrPallet))

	            If nY < 100
    	       	    _cItem = Alltrim(Str(nY))
                    If Len(_cItem) == 1
        	            _cItem = "0"+_cItem
                    Endif
                Else
                	_cItem = Alltrim(Str(nY))
                    _cItem = SubStr(_cItem, Len(_cItem), 1)
                    _cItem = Chr(Int((nY - 100)/10)+65) + _cItem
                Endif  
                nY:= (nY+1)

  	      		cQry := "SELECT dbo.PrecoEstoque('"+xFilial("SB1")+"','"+aTrPallet[nI][1]+"') AS PRCESTOQUE " // CUSTO DE FECHAMENTO DE ESTOQUE 
           		TCQuery cQry ALIAS "TCQ" NEW
	      		DbSelectArea("TCQ")
           		If !eof() .and. !bof()
	           		nPrcVen:= TCQ->PRCESTOQUE
    	  		Endif	
    	  		DbSelectArea("TCQ")
    	  		DbClosearea()	
				// TCQ->ZZK_PRODUT ,TCQ->ZZK_QUANT, TCQ->B1_TIPO, TCQ->B2_CM1, TCQ-B1_PRV1
				
				//      TCQ->B2_CM1 >0
				/*
				If aTrPallet[nI][4] > 0 
					If aTrPallet[nI][3] =='PA' //TCQ->B1_TIPO ='PA' 
						//     TCQ->B1_PRV1 > TCQ->B2_CM1
						If aTrPallet[nI][5] > aTrPallet[nI][4] 
							nPrcVen := aTrPallet[nI][4]//(TCQ->B2_CM1)
						Else
							aAdd(aCustErro, {aTrPallet[nI][1], aTrPallet[nI][2], aTrPallet[nI][4], _cItem} )		
						Endif
					Else
						nPrcVen := aTrPallet[nI][4]//(TCQ->B2_CM1)
					Endif
				Else
					aAdd(aCustErro, {aTrPallet[nI][1],aTrPallet[nI][2],aTrPallet[nI][4],_cItem} )	
				Endif
				*/
                aLinha := {}
				aAdd(aLinha,{"C6_ITEM"   ,      _cItem								                    ,Nil})
    		    aAdd(aLinha,{"C6_PRODUTO",		aTrPallet[nI][1]   										,Nil})
	    	    aAdd(aLinha,{"C6_QTDVEN" ,		aTrPallet[nI][2]   										,Nil})
        		aAdd(aLinha,{"C6_PRCVEN" ,		Round(nPrcVen,5)										,Nil})
	        	aAdd(aLinha,{"C6_TES"    ,		"823"              										,Nil})

    		    aAdd(aItens,aLinha)
                
		    Next nI

	       	lMsErroAuto := .F.
    	   	lMsHelpAuto := .F.

	        DbSelectArea("SA1")
    	    DbSetOrder(1)

	        DbSelectArea("SC6")
    	    DbSetOrder(1)
    	    
	        DbSelectArea("SC5")
    	    DbSetOrder(1)

            //MsgRun("Gerando pedido de transferência por Pallets !!", "Aguarde", {|| MSExecAuto({|x,y,z| Mata410(x,y,z)},aCabec,aItens,3) } )
			MSExecAuto({|x,y,z| Mata410(x,y,z)},aCabec,aItens,3)
    	   	If lMsErroAuto
	            DisarmTransaction()
        	    MostraErro()
        	    //RollBackSxE()
       			DbSelectArea("TMPTRANS")
			  	DbGotop()
    	        //Return //LGS#20200210 - Adequação de release 12.1.25 e posteriores - Não pode usar return dentro de Begin transaction
	        Else
    	    	//ConfirmSX8()
        		nDe := (nDe + 150)
	        Endif

			cNPedidos += SC5->C5_NUM+" / " 
		
		Next nX
		
		DbSelectArea("TMPTRANS")
	    DbGotop()

		While (TMPTRANS->(!Eof()))
	    	Reclock("TMPTRANS",.f.)
				TMPTRANS->TMPSTA := cNPedidos
			MsUnlock()
	
			DbSelectArea("TMPTRANS")
		  	DbSkip()
	
		Enddo			

	    cQry1 := ""
	    cQry1 += " SELECT TOP 1 ZZJ.ZZJ_CARGA "
	    cQry1 += " FROM "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) "
	    cQry1 += " WHERE ZZJ.ZZJ_FILIAL = '"+xFilial("ZZJ")+"'"
	    cQry1 += " AND ZZJ.ZZJ_DTTRAN   = '"+DTOS(Date())+"' "
	    cQry1 += " ORDER BY ZZJ.ZZJ_CARGA DESC "
	    TCQUERY cQry1 ALIAS "TCQ" NEW
	    DbSelectArea("TCQ")
    	DbGoTop()
	
	    cCodCARGA := Iif(Empty(TCQ->ZZJ_CARGA), 'C'+SubStr(Dtos(Date()), 7, 2)+SubStr(Dtos(Date()), 5, 2)+SubStr(Dtos(Date()), 3, 2)+'/'+'0001', SubStr(TCQ->ZZJ_CARGA, 1, 8)+StrZero(Val(SubStr(TCQ->ZZJ_CARGA, 9, 4))+1, 4) )
        //           Iif(Empty(TCQ->ZZJ_CARGA),     SubStr(Dtos(Date()), 7, 2)+SubStr(Dtos(Date()), 5, 2)+SubStr(Dtos(Date()), 3, 2)+'/'+'0001', SubStr(TCQ->ZZJ_CARGA, 1, 7)+StrZero(Val(SubStr(TCQ->ZZJ_CARGA, 8, 4))+1, 4) )

    	DbSelectArea("TCQ")
	    DbCloseArea()


   		cQry1 := " "
   		cQry1 += " UPDATE "+RetSqlName("ZZJ")+" SET ZZJ_FLAG ='5', ZZJ_OBSPED ='"+cNPedidos+"', ZZJ_CARGA ='"+cCodCARGA+"' FROM "+RetSqlName("ZZJ")+"  WHERE ZZJ_CODIGO IN "+cPallets "
   		cQry1 += " AND D_E_L_E_T_ ='' AND ZZJ_FLAG IN('1','2','3','4') AND ZZJ_FILIAL ='"+xFilial("ZZJ")+"'"
   		XXX := TCSQLExec(cQry1) 
        If XXX <> 0
	        cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
            MemoWrit(cNomArq, cQry1)
        Endif
        // BLOQUEAR NOVAMENTE OS PRODUTOS QUE FORAM LIBERADOS PRA EMISSÃO DO PEDIDO
		If Len(aProdBloq) >0
			For nW := 1 to Len(aProdBloq)
	    	    cQry1 := ""
		        cQry1 := " UPDATE "+RetSqlName("SB1")+" 
		        cQry1 += " SET B1_MSBLQL  = '1' "     
        		cQry1 += " WHERE B1_FILIAL = '"+xFilial("SB1")+"'"
        	   	cQry1 += " AND B1_MSBLQL ='2' "
    	        cQry1 += " AND (D_E_L_E_T_ ='') AND B1_COD ='"+aProdBloq[nW][1]+"'"
	            TCSQLExec(cQry1)
    	    Next
		Endif	
		
		If Len(aProdNVend) >0
			For nZ := 1 to Len(aProdNVend)
	    	    cQry1 := ""
		        cQry1 := " UPDATE "+RetSqlName("SB1")+" 
		        cQry1 += " SET B1_VEND  = 'N' "     
        		cQry1 += " WHERE B1_FILIAL = '"+xFilial("SB1")+"'"
        	   	cQry1 += " AND B1_VEND ='S' "
    	        cQry1 += " AND (D_E_L_E_T_ ='') AND B1_COD ='"+aProdNVend[nZ][1]+"'"
	            TCSQLExec(cQry1)
    	    Next
	    Endif
		//aAdd(aCustErro, {aTrPallet[nI][1],aTrPallet[nI][2],aTrPallet[nI][4],_cItem} )	
		If Len(aCustErro) >0
			cAuxMens := ""
			For nE := 1 to Len(aCustErro)
				cAuxMens += "PRODUTO -> "+aCustErro[nE][1]+"  QTDE->  "+TRANSFORM(aCustErro[nE][2],'@E 999,999,999')+"  CUSTO MEDIO NO MOMENTO DO PEDIDO ->   "+TRANSFORM(aCustErro[nE][3],'@E 999,999,999.9999')
	         	cAuxMens +=" "+chr(13)+chr(10)
				cAuxMens +=" "+chr(13)+chr(10)
			Next
			  cAuxMens += chr(13)+chr(10)+"Prog. Origem : BRFATX67"
	    	  U_EnvMail("BRASILUX - Verificar Custo dos itens dos pedidos "+cNPedidos+"  !",cAuxMens,"andre@brasilux.com.br","")                       	  
	    Endif


	End Transaction		
	
	cGet1Env := cCodCARGA 
	
    Messagebox("Pedido(s) de transferência por Pallet(s) gerado(s) com Sucesso !! ","Atenção...",48)    		
    cSay3Env := "Pedido(s) de transferência por Pallet(s) gerado(s) com Sucesso !!"
    
    oSay3Env:Refresh()
    
	If ChkFile("TMPTRANS") 
		DbSelectArea("TMPTRANS")
	    DbGotop()
	Endif

    oBrw1Env:oBrowse:GoTop()
    oBrw1Env:oBrowse:Refresh()
    oBtn1Env:lVisibleControl := .f.
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fInfPall() - Carrega Pallets Bipados e transformados em pedidos 
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fInfCarga()
       Local cQry1
    Local nCount   := 0
    Local nPeso    := 0
    Local nPesoTot := 0

	If Empty(Alltrim(cGet1Env))
		Return
	Endif
	If Len(Alltrim(cGet1Env)) = 11 
		cGet1Env  := Substr(cGet1Env,1,7)+'/'+Substr(cGet1Env,7,4) 
	Endif
	cSay3Env := ""
	cSay5Env := ""

	If ChkFile("TMPTRANS")
		DbSelectArea("TMPTRANS")
		//DbGoTop()
		//Zap
        //LGS#20191029 - Substituido comando ZAP devido a utilização de função do banco.
        TCSqlExec("DELETE FROM " + oTempTbl1:GetRealName() )
	Endif

    cQry1 := ""
    cQry1 += "SELECT ZZJ_CODIGO, ZZJ_OBSPED "
    cQry1 += "FROM "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) "
    cQry1 += " WHERE (ZZJ.ZZJ_FILIAL = '"+XFILIAL("ZZJ")+"') "
    cQry1 += "   AND (ZZJ.D_E_L_E_T_ = '') "
    cQry1 += "   AND ZZJ.ZZJ_CARGA = '"+cGet1Env+"' "
    cQry1 += "ORDER BY ZZJ_CODIGO"

    TCQuery cQry1 ALIAS "TCC" NEW
    DbSelectArea("TCC")
    If !Eof()
	    While !Eof()
	    	RecLock("TMPTRANS", .T.)
				TMPTRANS->TMPPAL := TCC->ZZJ_CODIGO
				TMPTRANS->TMPUNI := U_fTotUnit(TCC->ZZJ_CODIGO,1)
				TMPTRANS->TMPVOL := U_fTotUnit(TCC->ZZJ_CODIGO,2)
				TMPTRANS->TMPPES := round(u_fPesPallet(TCC->ZZJ_CODIGO),2)
	            TMPTRANS->TMPSTA := TCC->ZZJ_OBSPED
			MsUnLock()

			nCount   := (nCount +1) 
			oSay7Env:Refresh()
			nPeso    += TMPTRANS->TMPPES
			nPesoTot := Transform(nPeso, "@E 999,999.99")
			oSay9Env:Refresh()

        	DbSelectArea("TCC")
	        DbSkip()
		Enddo
	Else
		Messagebox("Código da Carga Digitado inválido, verifique !!","Atenção...",48)	  		
		cGet1Env := Space(12)
		oGet1Env:Setfocus()
    Endif
    DbSelectArea("TCC")
	DbCloseArea()    

    If ChkFile("TMPTRANS")
   	    DbSelectArea("TMPTRANS")
        DbGoTop()
	    oBrw1Env:oBrowse:GoTop()
    	oBrw1Env:oBrowse:Refresh()
    Endif	
    
Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fInfPall() - Consulta situação do Pallet (Transferido ou a Transferir)
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

/*Static Function fInfPall(cPallet)

	If Empty(Alltrim(cPallet))
		Return
	Endif
	If Len(Alltrim(cPallet)) = 10
		cGet1Env  := Substr(cPallet,1,6)+'/'+Substr(cPallet,7,4)
		cPallet := cGet1Env 	
	Endif
	cSay3Env := ""
	
	DbSelectArea("ZZJ")
	DbSetOrder(1)
	DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
	If Found() 
		If ZZJ->ZZJ_FLAG $ '1'
			cSay3Env := "Pallet de movimentação interna, aguardando transferência !"
		Elseif ZZJ->ZZJ_FLAG $ '2'
			cSay3Env := "Pallet de movimentação. Origem: "+ZZJ->ZZJ_LOCORI+" Destino: "+ZZJ->ZZJ_LOCDES			
		Elseif ZZJ->ZZJ_FLAG $ '3.4' 
			cSay3Env := "Pallet de Compra ainda sem pedido de transferência !!"		
		Elseif ZZJ->ZZJ_FLAG $ '5' 
			cSay3Env := "Pallet de Compra com pedido de transferência gerado!!"		
		Endif
		//oBtn6Env:lVisibleControl := .t.	
		//oBtn7Env:lVisibleControl := .t.	
	Else
		//oBtn6Env:lVisibleControl := .f.
		//oBtn7Env:lVisibleControl := .f.	
	Endif
	
	DbSelectArea("ZZJ")
	DbClosearea()	    

Return*/

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTblTrans() - Cria temporario para o Alias: TMPTRANS
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function oTblTrans()
	Local aFds := {}
    //Local cTmp
    
	If ChkFile("TMPTRANS") 
		DbSelectArea("TMPTRANS")
	    DbClosearea()
	Endif

    aAdd( aFds , {"TMPPAL"  ,"C", 011, 000} )   // PALLET
	aAdd( aFds , {"TMPVOL"  ,"N", 006, 000} )   // TOTAL DE VOLUMES DO PALLET
	aAdd( aFds , {"TMPUNI"  ,"N", 006, 000} )   // TOTAL DE PRODUTOS UNITARIO    
    aAdd( aFds , {"TMPPES"  ,"N", 009, 002} )   // PESO TOTAL PALLET
	aAdd( aFds , {"TMPSTA"  ,"C", 040, 000} )   // STATUS
    
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 28/10/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
    //cTmp := U_NovoArqTrab("dbf") //CriaTrab( , .F. )
    //DbCreate(cTmp+".dbf", aFds, "DBFCDXADS")
    //Use (cTmp+".Dbf") Alias TMPTRANS VIA "DBFCDXADS" New Exclusive

    //DbCreateIndex(cTmp+"_1.cdx", "TMPPAL"	   , {||"TMPPAL"} )
    //DbCreateIndex(cTmp+"_2.cdx", "TMPPES"	   , {||"TMPPES"} )
    
    //DbClearInd()
    //DbSetIndex(cTmp+"_1")
    //DbSetIndex(cTmp+"_2")
    
       oTempTbl1 := FWTemporaryTable():New( 'TMPTRANS' )
       oTempTbl1:SetFields( aFds )
       oTempTbl1:AddIndex( "cInd01", { "TMPPAL" } )
       oTempTbl1:AddIndex( "cInd02", { "TMPPES" } )
       oTempTbl1:Create()
       /********************************************************************************************************************************/

    DbSetOrder(1)

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fMLocPall() - Inclusão do Local de Origem e Destino do Pallet
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fMLocPall(nOpcMnt) // 1 - Inclui / 2 - Exclui

	Private cGet1Tr   := Space(11) 


	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±	
	±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    
	SetPrvt("oFontTr1", "oFontTr2", "oDlg1Tr", "oSay1Tr", "oSay2Tr", "oSay3Tr", "oGet1Tr")
          

    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Definicao do Dialog e todos os seus componentes.                        ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    

	
	If Empty(Alltrim(cGet6Env))
		Messagebox("Escolha o código da filial que será gerada a nota fiscal de transferência (Guarulhos / Araraquara) !!","Atenção...",48)
		Return
	Endif
	oGet6Env:disable()
	
	oFontTr1  := TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
    oFontTr2  := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
    oDlg1Tr   := MSDialog():New( 258, 232, 383, 570, "Transferência de Pallet", , , .F., , , , , , .T., , , .T. )


    oSay1Tr   := TSay():New( 023, 008, {|| "Pallet.:"     }, oDlg1Tr, , oFontTr1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 012)
    oGet1Tr   := TGet():New( 020, 047, {|u| If(PCount() > 0, cGet1Tr := u, cGet1Tr)}, oDlg1Tr, 088, 018, '@!'             , , CLR_BLACK, CLR_WHITE, oFontTr1, , , .T., "", , , .F., .F., , .F. , .F., ""      ,"cGet1Tr", , )

    oBtn1Tr   := TButton():New( 046, 122, "Confirma", oDlg1Tr, {|| oDlg1Tr:End()}  , 048, 014, , oFontTr2, , .T., , "", , , , .F. )
    oGet1Tr:bLostFocus := {|| FtrPallet(cGet1Tr,nOpcMnt)}
    oDlg1Tr:Activate( , , , .T.)

Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ
Function  ³ FtrPallet()  Salvar Dados nas Tabelas Temporárias (Inclusão e Exclusão de Pallets) 
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function FtrPallet(_cPallet,nOpcMnt)
	
	Local cPallets := ""
	Local cQry1    := ""

	If Empty(Alltrim(_cPallet))
		Return
	Endif
	If Len(Alltrim(_cPallet)) = 10
		cGet1Env  := Substr(_cPallet,1,6)+'/'+Substr(_cPallet,7,4)
		_cPallet := cGet1Env 	
	Endif

    If (nOpcMnt == 1)     // ver se é inclusão ou exclusão
	 	DbSelectArea("ZZJ")
		DbSetOrder(1)
		DbSeek(xFilial("ZZJ")+(_cPallet), .t.)   
		If Found() .and. (ZZJ->ZZJ_FILIAL == XFilial("ZZJ"))
			/*
			If ZZJ->ZZJ_FLAG $ '1'
				Messagebox("Pallet de movimentação interna, aguardando transferência !! ","Atenção...",48)
				oGet1Tr:Setfocus()
			Elseif ZZJ->ZZJ_FLAG $ '2'
				Messagebox("Pallet de movimentação interna, transferido. Origem: "+ZZJ->ZZJ_LOCORI+" Destino: "+ZZJ->ZZJ_LOCDES, "Atenção...",48)			
				oGet1Tr:Setfocus()
			Elseif ZZJ->ZZJ_FLAG $ '5' 
				Messagebox("Pallet de Compra de pedidos por Borderô, com pedido de transferência gerado !! ","Atenção...",48)		
				oGet1Tr:Setfocus()
			*/
// acrescentado por Jose 25/09/2024 -------------
		If ZZJ->ZZJ_FLAG $ '5' 
				Messagebox("Pallet de Compra de pedidos por Borderô, com pedido de transferência gerado e Gerou Nota Fiscal de Transferência !! ","Atenção...",48)		
				oGet1Tr:Setfocus()
				Return
			Endif

//---  até aqui 25/09/2024 ----------------------

			If ZZJ->ZZJ_FLAG $ '1.2'
				DbSelectArea("TMPTRANS")
				DbSetOrder(1)
				DbSeek(Alltrim(ZZJ->ZZJ_CODIGO), .t.)  
				If !(TMPTRANS->(eof())) .and. (Alltrim(ZZJ->ZZJ_CODIGO) == Alltrim(TMPTRANS->TMPPAL))
					Messagebox("Pallet -->"+(_cPallet)+" já foi bipado / digitado !!","Atenção...",48)    	
					oGet1Tr:Setfocus()
					Return
				Else
					RecLock("TMPTRANS", .T.)
						TMPTRANS->TMPPAL := (_cPallet)
						TMPTRANS->TMPSTA := "Não Transferido"
						TMPTRANS->TMPUNI := U_fTotUnit(_cPallet,1)
						TMPTRANS->TMPVOL := U_fTotUnit(_cPallet,2)
						TMPTRANS->TMPPES := round(u_fPesPallet(_cPallet),2)
					MsUnLock()
					nCount   := (nCount +1) 
					oSay7Env:Refresh()
					nPeso    += TMPTRANS->TMPPES
					nPesoTot := Transform(nPeso, "@E 999,999.99")
					oSay9Env:Refresh()
				Endif
			Elseif ZZJ->ZZJ_FLAG $ '3.4' 
				If (ZZJ->ZZJ_LOCALI) $ 'FAB2' .AND. (ZZJ->ZZJ_FLAG $ '3')
					Messagebox("Pallet Montado na Fabrica 2 / Deve ser transferido de almoxarifado antes da geração da nota fiscal.", "Atenção...",48)			
					oGet1Tr:Setfocus()
					Return
				Else
					If (ZZJ->ZZJ_TIPBOR $ '2.4.5') .OR. (ZZJ->ZZJ_BORDER <> 'VARIOS ' .AND. Posicione("SZF", 1, xFilial("SZF")+ZZJ->ZZJ_BORDER, "ZF_TIPOBOR")='2')
						DbSelectArea("TMPTRANS")
						DbSetOrder(1)
						DbSeek(Alltrim(ZZJ->ZZJ_CODIGO), .t.)  
						If !(TMPTRANS->(eof())) .and. (Alltrim(ZZJ->ZZJ_CODIGO) == Alltrim(TMPTRANS->TMPPAL))
							Messagebox("Pallet -->"+(_cPallet)+" já foi bipado / digitado !!","Atenção...",48)    	
							oGet1Tr:Setfocus()
							Return
						Else
							RecLock("TMPTRANS", .T.)
								TMPTRANS->TMPPAL := (_cPallet)
								TMPTRANS->TMPSTA := "Não Transferido"
								TMPTRANS->TMPUNI := U_fTotUnit(_cPallet,1)
								TMPTRANS->TMPVOL := U_fTotUnit(_cPallet,2)
								TMPTRANS->TMPPES := round(u_fPesPallet(_cPallet),2)
							MsUnLock()
							nCount   := (nCount +1) 
							oSay7Env:Refresh()
							nPeso    += TMPTRANS->TMPPES
							nPesoTot := Transform(nPeso, "@E 999,999.99")
							oSay9Env:Refresh()
						Endif
					ElseIf Alltrim(ZZJ->ZZJ_TIPBOR)='' .AND. Alltrim(ZZJ->ZZJ_BORDER) <> 'VARIOS'		       		
						Reclock("ZZJ",.f.)
							ZZJ->ZZJ_TIPBOR := Posicione("SZF", 1, xFilial("SZF")+ZZJ->ZZJ_BORDER, "ZF_TIPOBOR")
						MsUnlock()
					Else
						Messagebox("Pallet -->"+(_cPallet)+" tem o tipo de borderô inválido, se for pallet Depósito deve ser alterado o tipo, verifique !!","Atenção...",48)    	
						oGet1Tr:Setfocus()
						Return
					Endif
				Endif
		    Endif
	    Else
			Messagebox("Pallet -->"+(_cPallet)+" não cadastrado !!","Atenção...",48)
			oSay1Tr:Setfocus() 
			Return   		    
	    Endif
	    DbSelectArea("ZZJ")
	    DbCloseArea()
	

		If ChkFile("TMPTRANS") 
			DbSelectArea("TMPTRANS")
	    	DbSetOrder(1)
		    DbGotop()
		Endif

		cPallets := "('"
    
		DbSelectArea("TMPTRANS")
		DbGotop()

		While (TMPTRANS->(!Eof()))
			cPallets += TMPTRANS->TMPPAL+"', '"
			DbSelectArea("TMPTRANS")
			DbSkip()
		Enddo

		cPallets := SubStr(cPallets, 1, Len(cPallets)-3)+")"

		cQry := " "
		cQry += " SELECT DISTINCT ZZK_CODIGO AS PALLET, ZZK_LOTE AS LOTE "
		cQry += " FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
		cQry += " LEFT OUTER JOIN "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZJ_CODIGO = ZZK_CODIGO AND ZZJ.D_E_L_E_T_ ='' "
		cQry += " LEFT OUTER JOIN "+RetSqlName("ZAE")+" ZAE WITH (NOLOCK) ON ZAE_FILIAL = ZZK_FILIAL AND ZAE_PRODUT = ZZK_PRODUT AND ZAE_LOTE = ZZK_LOTE AND ZAE.D_E_L_E_T_ ='' "
		cQry += " WHERE ZZK.D_E_L_E_T_ ='' " 
		cQry += " AND ZZK_CODIGO IN "+cPallets "
		cQry += " AND ZZJ_FLAG IN('1','2','3','4') "
		cQry += " AND ZZK_LOTE <>'' "
		cQry += " AND ZAE_TIPO = '1' "
		cQry += " AND ZZJ_FILIAL ='"+xFilial("ZZJ")+"'"

		TCQuery cQry ALIAS "TCQ" NEW
		DbSelectArea("TCQ")
		DbGoTop()

		If !TCQ->(EOF()) 
			Messagebox("Pallet -->"+(TCQ->PALLET)+" não será incluído pois o lote "+(TCQ->LOTE)+" esta bloqueado !!","Atenção...",48)
			DbSelectArea("TMPTRANS")
	    	DbSetOrder(1)
	    	DbSeek(TCQ->PALLET, .t.)   
			If Found()
				RecLock("TMPTRANS", .F.)
					DbDelete()
				MsUnlock()		
				nCount   := (nCount -1)
				oSay7Env:Refresh()
				nPeso    := (nPeso - round(u_fPesPallet(_cPallet),2))
				nPesoTot := Transform(nPeso, "@E 999,999.99")
				oSay9Env:Refresh()
			Endif
		Endif
		DbSelectArea("TCQ")
		DbCloseArea()


		cQry1 := " "
		cQry1 += " SELECT COUNT(*) AS TOTALITEM
		cQry1 += " FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON ZZK_FILIAL = B1_FILIAL  AND ZZK_PRODUT = B1_COD AND SB1.D_E_L_E_T_ ='' "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZJ_CODIGO = ZZK_CODIGO AND ZZJ.D_E_L_E_T_ ='' "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON B2_FILIAL = B1_FILIAL AND B2_COD = B1_COD AND B2_LOCAL = CASE WHEN B1_TIPO ='MP' THEN '01' ELSE CASE WHEN B1_TIPO ='PI' THEN '02' ELSE CASE WHEN B1_TIPO ='PA' THEN '03' ELSE CASE WHEN B1_TIPO ='MC' THEN '04' ELSE B1_LOCPAD END END END END AND SB2.D_E_L_E_T_ ='' "
		cQry1 += " WHERE ZZK.D_E_L_E_T_ ='' " 
		cQry1 += " AND ZZK_CODIGO IN "+cPallets "
		cQry1 += " AND ZZJ_FLAG IN('1','2','3','4') "
		cQry1 += " AND ZZJ_FILIAL ='"+xFilial("ZZJ")+"'"

		TCQuery cQry1 ALIAS "TCQ" NEW
		DbSelectArea("TCQ")
		DbGoTop()
	
		aTrPallet 	:= {} 
		If !TCQ->(EOF()) .AND. (TCQ->TOTALITEM > 150)
			Messagebox("Pallet -->"+(_cPallet)+" não será incluído pois ultrapassa 150 itens na nota de transferência !!","Atenção...",48)
			DbSelectArea("TMPTRANS")
	    	DbSetOrder(1)
	    	DbSeek(_cPallet, .t.)   
			If Found()
				RecLock("TMPTRANS", .F.)
					DbDelete()
				MsUnlock()		
				nCount   := (nCount -1)
				oSay7Env:Refresh()
				nPeso    := (nPeso - round(u_fPesPallet(_cPallet),2))
				nPesoTot := Transform(nPeso, "@E 999,999.99")
				oSay9Env:Refresh()
	    	Endif	
		Endif

		DbSelectArea("TCQ")
		DbCloseArea()
	ElseIf (nOpcMnt == 2)  
		DbSelectArea("TMPTRANS")
	    DbSetOrder(1)
	    DbSeek(_cPallet, .t.)   
		If Found()
			RecLock("TMPTRANS", .F.)
				DbDelete()
			MsUnlock()		
			nCount   := (nCount -1)
			oSay7Env:Refresh()
			nPeso    := (nPeso - round(u_fPesPallet(_cPallet),2))
			nPesoTot := Transform(nPeso, "@E 999,999.99")
			oSay9Env:Refresh()
	    Endif	
	Endif

	If ChkFile("TMPTRANS") 
		DbSelectArea("TMPTRANS")
	    DbGotop()
	Endif

    oGet1Tr:SetFocus()
    cGet1Tr := Space(11)
    oGet1Tr:Refresh()

    oBrw1Env:oBrowse:GoTop()
    oBrw1Env:oBrowse:Refresh()
Return


/*ÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fVCodPall() - Validação do código do pallet na manutenção
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
/*
Static Function fVCodPall(nOpcMnt)  //1 - Inclui 2- Exclui

    //Local nVol 		:= 0
    //Local cQry 		:= ""
    //Local nQtdAtual := 0

	If Empty(Alltrim(cGet1Tr)) 
		Return
	Endif

    If ChkFile("TMPTRANS")
	    DbSelectArea("TMPTRANS")
    	DbSetOrder(1)
    	DbGoTop()
    Endif
   	DbSeek(Alltrim(cGet1Tr), .F.)
    If Found()
	    If nOpcMnt == 1
  	  		oGet4Mnt:SetFocus()
			Return
      	Endif
    Endif
    If nOpcMnt == 1   // Incluir
		DbSelectArea("ZZJ")
		DbSetOrder(1)
		DbSeek(xFilial("ZZJ")+cGet1Tr, .t.)   
		If Found()  
			If ZZJ->ZZJ_FLAG == "1"
				Messagebox("Este Pallet foi montado para transferência interna, não é possivel utilizá-lo para montagem da carga!!","Atenção...",48) 
    			oGet1Tr:Setfocus()
    			DbSelectArea("ZZJ")
    			DbClosearea()
    	    	Return
			ElseIf ZZJ->ZZJ_FLAG == "2"
				Messagebox("Este Pallet foi montado para transferência interna e já foi transferido. Origem..: "+ZZJ->ZZJ_LOCORI+" Destino..: "+ZZJ->ZZJ_LOCDES,"Atenção...",48) 
    			oGet1Tr:Setfocus()
    			DbSelectArea("ZZJ")
    			DbClosearea()
    	    	Return
			ElseIf ZZJ->ZZJ_FLAG == "5"
				Messagebox( "Este Pallet já foi utilizado na montagem de pedido de transferência.", " Atenção...",48) 
    			oGet1Tr:Setfocus()
    			DbSelectArea("ZZJ")
    			DbClosearea()
    	    	Return
			Endif		
	   	Else
			Messagebox("Pallet não encontrado, Verifique !!","Atenção...",48) 	   	
   			oGet1Tr:Setfocus()
   			DbSelectArea("ZZJ")
   			DbClosearea()
   	    	Return
	   	Endif
	   	DbSelectArea("ZZJ")
		DbCloseArea()

	Elseif nOpcMnt = 2 // Excluir
		DbSelectArea("TMPTRANS")
   		DbSetOrder(1)
   		DbGoTop()
	   	DbSeek(Alltrim(cGet1Tr), .F.)
   		If Found() .AND. (Alltrim(TMPTRANS->TMPPAL) == Alltrim(cGet1Tr))
   			RecLock("TMPTRANS", .f.)
                DbDelete()             
       		MsUnLock()
        Else
    		Messagebox("Este Pallet não se encontra na lista, Verifique!!!","Atenção...",48)
    		oGet1Tr:SetFocus()                                     	
		   	cGet1Tr := space(11)
    		oGet1Tr:Refresh()
       	Endif
	Endif            
	DbSelectArea("TMPTRANS")
   	DbSetOrder(1)
   	DbGoTop()	
Return*/


User Function fNumNf(Pedido)

	Local cNumNf := ""
	Local cQry1  :=""    

	cQry1 := " "
	cQry1 += " SELECT F2_DOC AS NUMNF "	
	cQry1 += " FROM "+RetSqlName("SF2")+" 
	cQry1 += " WHERE D_E_L_E_T_ ='' " 
	cQry1 += " AND F2_FILIAL ='"+xFilial("SF2")+"'"
	cQry1 += " AND F2_PEDIDO ='"+Pedido+"'"
    TCQuery cQry1 ALIAS "TCQ" NEW
	
	If !Eof()
		cNumNf := TCQ->NUMNF
	Endif		
    
    DbSelectArea("TCQ")
    DbCloseArea()
    
Return(cNumNf)   

User Function fTotUnit(cPallet,nOpc)

	Local nTotal :=0
	Local cQry1  :=""    

	cQry1 := " "
	If nOpc == 1
		cQry1 += " SELECT SUM(ZZK_QUANT) AS ZZK_QUANT "
	Elseif nOpc == 2
		cQry1 += " SELECT COUNT(R_E_C_N_O_) AS ZZK_QUANT "	
	Endif
	cQry1 += " FROM "+RetSqlName("ZZK")+" 
	cQry1 += " WHERE D_E_L_E_T_ ='' " 
	cQry1 += " AND ZZK_FILIAL ='"+xFilial("ZZK")+"'"
	cQry1 += " AND ZZK_CODIGO ='"+cPallet+"'"
    TCQuery cQry1 ALIAS "TCQ" NEW
	
	If !Eof()
		nTotal := TCQ->ZZK_QUANT
	Endif		
    
    DbSelectArea("TCQ")
    DbCloseArea()
    
Return(nTotal)   

/*ÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fPesPallet() - Calcula o peso do Pallet
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

User Function fPesPallet(cPallet)

	Local cQry1  :=""    
	Local nPeso  :=0
    
	If ChkFile("TCQ")
		DbSelectArea("TCQ")
		DbClosearea()
	Endif

	cQry1 += " SELECT ZZK_CODIGO, SUM(ZZK_QUANT * B1_PESBRU) AS PESO "
	cQry1 += " FROM "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = ZZK_FILIAL AND B1_COD = ZZK_PRODUT AND SB1.D_E_L_E_T_ ='' "
	cQry1 += " WHERE ZZK_CODIGO ='"+cPallet+"'"
	cQry1 += " AND ZZK.D_E_L_E_T_ ='' "
	cQry1 += " AND ZZK_FILIAL ='"+xFilial("ZZK")+"'"
	cQry1 += " GROUP BY ZZK_CODIGO "
    TCQuery cQry1 ALIAS "TCQ" NEW

	If !Eof()
		nPeso := TCQ->PESO
	Endif		
    
    DbSelectArea("TCQ")
    DbCloseArea()

Return(nPeso)


/*ÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fImpRel() - Relatório de Montagem de Carga por Pallets
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fImpRel()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE Titulo 	:=""
PRIVATE cDesc1	:=""
PRIVATE cDesc2	:=""
PRIVATE cDesc3 	:="" 
PRIVATE cCabec1 := ""
PRIVATE cCabec2 := ""  
PRIVATE nTipo 	:= 18
PRIVATE M_Pag   := 01
PRIVATE Tamanho	:= "P"
PRIVATE Limite 	:= 80
PRIVATE cString	:= "ZZK"
PRIVATE Cabec1,Cabec2,WnRel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BRPCPX67"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRPCPX67"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


DbSelectArea("TMPTRANS")
DbSetOrder(1)
If Eof() 
	Messagebox("Bipe os Pallets para montar a carga antes de tentar emitir o relatório !!","Atenção...",48) 
	Return
Endif
    
//CriaSX1(cPerg)  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "BRPCPX67"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey==27
	dbClearFilter()
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento do Relatorio                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RptDetail()})

Return


Static Function RptDetail()

DbSelectArea("TMPTRANS")
If Mv_Par01 == 1
	DbSetOrder(1)
Else
	DbSetOrder(2)
Endif	
DbGoTop()	

If Eof() 
	Messagebox("Bipe os Pallets para montar a carga antes de tentar emitir o relatório !!","Atenção...",48) 
	Return
Endif

Titulo := "Previsão de Carregamento por Bip "   
cCabec1 :="Pallet               Qtd. Unit.      Volume             Peso"

SetRegua( RECCOUNT( ) ) 

Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)                       
_nLin := 08  
cTotalCount := cTotalPallet := cTotalVol := cTPeso := cFlag:= 0                                                                                         

While !Eof()

	If _nLin > 55                                                                    	
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 08
	Endif 

	If !Eof() .and. cFlag = 1
		@ _nLin,000 psay replicate("-",80)
		@ _nLin++
	EndIf 

	@_nLin,000 PSAY TMPTRANS->TMPPAL
	@_nLin,021 PSAY Transform(TMPTRANS->TMPUNI,"@E 999999")
	@_nLin,036 PSAY Transform(TMPTRANS->TMPVOL,"@E 999999")
	@_nLin,050 PSAY Transform(TMPTRANS->TMPPES,"@E 999,999.99")
	@ _nLin++		
	
	cTotalCount  += TMPTRANS->TMPUNI
	cTotalPallet += 1 
	cTotalVol	 += TMPTRANS->TMPVOL
	cTPeso       += TMPTRANS->TMPPES
	If _nLin > 55
		cFlag := 0
	Else
		cFlag := 1
	EndIf

	DbSelectArea("TMPTRANS")	 
	DbSkip()
  
EndDo        
  	If _nLin > 55                                                                    	
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 08
	Endif

	@ _nLin,000 psay replicate("_",80)
	@ _nLin++		
	@_nLin,000 PSAY "Qtd. Unit Total:"
   	@_nLin,022 PSAY Transform(cTotalCount,"@E 999999")
	@_nLin,050 PSAY "Total Pallets..:"
	@_nLin,072 PSAY Transform(cTotalPallet,"@E 999")
	@ _nLin++
	@_nLin,000 PSAY "Volume Total...:"
	@_nLin,022 PSAY Transform(cTotalVol,"@E 999999")    
	@ _nLin++
	@_nLin,000 PSAY "Peso Total.....:"
	@_nLin,020 PSAY Transform(cTPeso,"@E 999,999.99")    

	Set Device To Screen

	If aReturn[5] == 1
   		Set Printer TO
	    dbcommitAll()
   		ourspool(wnrel)
	Endif

	DbSelectArea("TMPTRANS")
	DbSetOrder(1)
	DbGoTop()
		
Return

//LGS#20200210 - Adequação de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)	

Local aHelp := {}

AAdd(aHelp, {{"Ordenar Por:"},  {""}, {""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","Ordernar por: " ,"","","mv_ch1","N",1,00,00,"C","","","","","MV_PAR01","Pallet","","","","Peso","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")

Return*/

/*ÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fDesPla() - Relatório de Destino do Paletts
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

// Jose 09/10/2024 Acrescentado
Static Function fDesPla()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE Titulo 	:=""
PRIVATE cDesc1	:=""
PRIVATE cDesc2	:=""
PRIVATE cDesc3 	:="" 
PRIVATE cCabec1 := ""
PRIVATE cCabec2 := ""  
PRIVATE nTipo 	:= 18
PRIVATE M_Pag   := 01
PRIVATE Tamanho	:= "P"
PRIVATE Limite 	:= 80
PRIVATE cString	:= "ZZK"
PRIVATE Cabec1,Cabec2,WnRel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BRPCPX67"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRPCPX67"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


DbSelectArea("TMPTRANS")
DbSetOrder(1)
If Eof() 
	Messagebox("Bipe os Pallets para montar a carga antes de tentar emitir o relatório !!","Atenção...",48) 
	Return
Endif
    
//CriaSX1(cPerg)  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "BRPCPX67"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey==27
	dbClearFilter()
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento do Relatorio de Pallets              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RptDetaip()})

Return

Static Function RptDetaip()
Local _zCodigo := ''
Local _zPedido := ''
Local _zLocal  := ''
Local _zPallet := ''
Local _zNotas  := ''

DbSelectArea("TMPTRANS")
If Mv_Par01 == 1
	DbSetOrder(1)
Else
	DbSetOrder(2)
Endif	
DbGoTop()	

If Eof() 
	Messagebox("Bipe os Pallets para montar a carga antes de tentar emitir o relatório !!","Atenção...",48) 
	Return
Endif

Titulo := "Destino e Endereçamento dos Pallets "   
//cCabec1 :="Pallet               Qtd. Unit.      Volume             Peso"

SetRegua( RECCOUNT( ) ) 

//Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)         
//Cabec(titulo,cCabec2,nomeprog,tamanho,nTipo)                   
_nLin := 04  
cTotalCount := cTotalPallet := cTotalVol := cTPeso := cFlag:= 0      


While !Eof()

//	If _nLin > 55                                                                    	
//		@ _nLin,000 psay replicate("_",80)
//		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
//		_nLin := 08
//	Endif 

	If !Eof() .and. cFlag = 1
//		@ _nLin,000 psay replicate("-",80)
		@ _nLin++
	EndIf 

////////

    DbSelectArea("TCP")
    DbCloseArea()
/*            José 10/10/2024
    cQry11 := " "
    cQry11 += " SELECT ZZJ_CARGA, ZZJ_CODIGO, ZZK_PEDIDO, ZZK_PRODUT, ZZK_QUANT, B2_LOCALIZ, C5_NOTA
    cQry11 += " FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
    cQry11 += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON ZZK_FILIAL = C5_FILIAL  AND ZZK_PEDIDO = C5_NUM AND SC5.D_E_L_E_T_ ='' "
    cQry11 += " LEFT OUTER JOIN "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZJ_CODIGO = ZZK_CODIGO AND ZZJ.D_E_L_E_T_ ='' "
    cQry11 += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON B2_FILIAL = ZZK_FILIAL AND B2_COD = ZZK_PRODUT AND SB2.D_E_L_E_T_ =''  " //AND B2_LOCAL = CASE WHEN B1_TIPO ='MP' THEN '01' ELSE CASE WHEN B1_TIPO ='PI' THEN '02' ELSE CASE WHEN B1_TIPO ='PA' THEN '03' ELSE CASE WHEN B1_TIPO ='MC' THEN '04' ELSE B1_LOCPAD END END END END "
    cQry11 += " WHERE ZZK.D_E_L_E_T_ ='' " 
    cQry11 += " AND ZZK_CODIGO IN ('"+TMPTRANS->TMPPAL+"') "
    cQry11 += " AND ZZJ_CARGA = '"+cGet1Env+"' " 
    cQry11 += " AND ZZJ_FLAG IN('1','2','3','4',5) "
    cQry11 += " AND ZZJ_FILIAL ='"+xFilial("ZZJ")+"'"
    Jose 10/10/2024 até aqui */

	If cGet6Env = '023818'
	   _zLocal = 'G3'
	Else
	   _zLocal = 'A3'
	EndIf
    cQry11 := " "
    cQry11 += " SELECT ZZJ_CARGA, "
    cQry11 += "        ZZJ_CODIGO, "
    cQry11 += " 	   ZZJ_OBSPED, "
    cQry11 += " 	   ZZK_PRODUT, "
    cQry11 += "        SUM(ZZK_QUANT) AS ZZK_QUANT, "
    cQry11 += "        B2_LOCALIZ, "

    cQry11 += "	       SC51.C5_NOTA AS NOTA1, "
    cQry11 += "	       SC52.C5_NOTA AS NOTA2, "
    cQry11 += "   	   SC53.C5_NOTA AS NOTA3, "
    cQry11 += "   	   SC54.C5_NOTA AS NOTA4 "

    cQry11 += "  FROM "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK)  "
    cQry11 += " 	    LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK_FILIAL = ZZJ_FILIAL "
    cQry11 += " 	                                                           AND ZZK_CODIGO = ZZJ_CODIGO "
    cQry11 += " 									                           AND ZZK.D_E_L_E_T_ = '' "
    cQry11 += " 	    LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON B2_FILIAL = ZZK_FILIAL "
    cQry11 += " 	                                                           AND B2_COD = ZZK_PRODUT "
    cQry11 += "      							     		                   AND B2_LOCAL = '"+_zLocal+"'
    cQry11 += " 										                 	   AND SB2.D_E_L_E_T_ = '' "

    cQry11 += "	   LEFT OUTER JOIN SC5010 SC51 WITH (NOLOCK) ON SC51.C5_FILIAL = ZZK_FILIAL " 	    
    cQry11 += "	                                            AND SC51.C5_NUM    = SUBSTRING(ZZJ_OBSPED,1,6)     "
    cQry11 += "											    AND SC51.D_E_L_E_T_ = '' "
    cQry11 += "	   LEFT OUTER JOIN SC5010 SC52 WITH (NOLOCK) ON SC52.C5_FILIAL = ZZK_FILIAL " 	    
    cQry11 += "	                                            AND SC52.C5_NUM    = SUBSTRING(ZZJ_OBSPED,10,6) "    
    cQry11 += "	        								    AND SC52.D_E_L_E_T_ = '' "
    cQry11 += "	   LEFT OUTER JOIN SC5010 SC53 WITH (NOLOCK) ON SC53.C5_FILIAL = ZZK_FILIAL  "	    
    cQry11 += "	                                            AND SC53.C5_NUM    = SUBSTRING(ZZJ_OBSPED,19,6) "    
    cQry11 += "											    AND SC53.D_E_L_E_T_ = '' "
    cQry11 += "    LEFT OUTER JOIN SC5010 SC54 WITH (NOLOCK) ON SC54.C5_FILIAL = ZZK_FILIAL " 	    
    cQry11 += "	                                            AND SC54.C5_NUM    = SUBSTRING(ZZJ_OBSPED,28,6) "    
    cQry11 += "											    AND SC54.D_E_L_E_T_ = '' "


    cQry11 += " WHERE ZZJ_FILIAL = '"+xFilial("ZZJ")+"' "
    cQry11 += "   AND ZZJ.D_E_L_E_T_ = '' "
    cQry11 += "   AND ZZJ_CARGA = '"+cGet1Env+"' " 
    cQry11 += "   AND ZZJ_FLAG IN ('1','2','3','4') "
    cQry11 += " GROUP BY ZZJ_CARGA, ZZJ_CODIGO, ZZK_PRODUT, ZZK_QUANT, ZZJ_OBSPED, B2_LOCALIZ, "
    cQry11 += " 	     SC51.C5_NOTA, SC52.C5_NOTA, SC53.C5_NOTA, SC54.C5_NOTA  "
    cQry11 += " ORDER BY ZZJ_CARGA, ZZJ_CODIGO, ZZK_PRODUT "

    TCQuery cQry11 ALIAS "TCP" NEW
    DbSelectArea("TCP")
    DbGoTop()
    While (TCP->(!Eof()))
 		  If TCP->ZZJ_CODIGO <> _zCodigo
		     _zCodigo := TCP->ZZJ_CODIGO
//			 _nLin := 60
//		     If _nLin > 55                                                                    	
//	            @ _nLin,000 psay replicate("_",80)
//		        Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
	    	    _nLin := 04 //08
//	         Endif
	         @_nLin,000 PSAY "DESTINO :-"
			 If cGet6Env = '023818'
			    @_nLin,022 PSAY "CD GUARULHOS"
			 Else
		        @_nLin,022 PSAY "CD ARARAQUARA"
			 EndIf
			 If TCP->ZZJ_CODIGO <> _zPallet
			    _zPallet := TCP->ZZJ_CODIGO
			    _zPedido := TCP->ZZJ_OBSPED
			    @_nLin := _nLin+2	
	            @_nLin,000 PSAY "PALLET :-"
		 	    @_nLin,022 PSAY TCP->ZZJ_CODIGO	
			    @_nLin := _nLin+2		
	            @_nLin,000 PSAY "PEDIDO :-"
		 	    @_nLin,022 PSAY TCP->ZZJ_OBSPED

			    @ _nLin++
				_zNotas  = Alltrim(TCP->NOTA1)
				_zNotas += ' / '
				_zNotas += Alltrim(TCP->NOTA2)
				_zNotas += ' / '
				_zNotas += Alltrim(TCP->NOTA3)
				_zNotas += ' / '
				_zNotas += Alltrim(TCP->NOTA4)
	            @_nLin,000 PSAY "NOTA(S) FISCAL(IS):-"
		 	    @_nLin,022 PSAY _zNotas 

			    @_nLin := _nLin+2	
			    @_nLin,000 PSAY "PRODUTO             QTDE            LOCALIZAÇÃO"
			    @ _nLin++	
			 EndIf
		  EndIf
		  If TCP->ZZJ_OBSPED <> _zPedido
		     _zPedido := TCP->ZZJ_OBSPED
		     @ _nLin++		
	         @_nLin,000 PSAY "PEDIDO :-"
		 	 @_nLin,022 PSAY TCP->ZZJ_OBSPED
/*
			 @ _nLin++
	         @_nLin,000 PSAY "NOTA(S) FISCAL(IS):-"
		 	 @_nLin,022 PSAY TCP->NOTA1
			 @_nLin,028 PSAY "/"
		 	 @_nLin,031 PSAY TCP->NOTA2
			 @_nLin,038 PSAY "/"
			 @_nLin,040 PSAY TCP->NOTA3
			 @_nLin,047 PSAY "/"
			 @_nLin,049 PSAY TCP->NOTA4
*/
//	         @_nLin,036 PSAY " / "	
//			 @_nLin,045 PSAY TCP->C5_NOTA
			 @_nLin := _nLin+2		
			 @_nLin,000 PSAY "PRODUTO             QTDE            LOCALIZAÇÃO"
			 @ _nLin++
		  EndIf
	      @_nLin,000 PSAY TCP->ZZK_PRODUT
	      @_nLin,021 PSAY TCP->ZZK_QUANT
	      @_nLin,036 PSAY TCP->B2_LOCALIZ
	      @ _nLin++	
	      If _nLin > 55
	 	     cFlag := 0
	      Else
		     cFlag := 1
	      EndIf

	      DbSelectArea("TCP")	 
	      DbSkip()
  
    EndDo        

/////////
//	@_nLin,000 PSAY TMPTRANS->TMPPAL
//	@_nLin,021 PSAY Transform(TMPTRANS->TMPUNI,"@E 999999")
//	@_nLin,036 PSAY Transform(TMPTRANS->TMPVOL,"@E 999999")
//	@_nLin,050 PSAY Transform(TMPTRANS->TMPPES,"@E 999,999.99")
//	@ _nLin++		
	
//	cTotalCount  += TMPTRANS->TMPUNI
//	cTotalPallet += 1 
//	cTotalVol	 += TMPTRANS->TMPVOL
//	cTPeso       += TMPTRANS->TMPPES
 If _nLin > 55
		cFlag := 0
	Else
		cFlag := 1
	EndIf

	DbSelectArea("TMPTRANS")	 
	DbSkip()
  
EndDo        
//  	If _nLin > 55                                                                    	
//		@ _nLin,000 psay replicate("_",80)
//		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
//		_nLin := 08
//	Endif

//	@ _nLin,000 psay replicate("_",80)
//	@ _nLin++		
//	@_nLin,000 PSAY "Qtd. Unit Total:"
// 	@_nLin,022 PSAY Transform(cTotalCount,"@E 999999")
//	@_nLin,050 PSAY "Total Pallets..:"
//	@_nLin,072 PSAY Transform(cTotalPallet,"@E 999")
//	@ _nLin++
//	@_nLin,000 PSAY "Volume Total...:"
//	@_nLin,022 PSAY Transform(cTotalVol,"@E 999999")    
//	@ _nLin++
//	@_nLin,000 PSAY "Peso Total.....:"
//	@_nLin,020 PSAY Transform(cTPeso,"@E 999,999.99")    

	Set Device To Screen

	If aReturn[5] == 1
   		Set Printer TO
	    dbcommitAll()
   		ourspool(wnrel)
	Endif

	DbSelectArea("TMPTRANS")
	DbSetOrder(1)
	DbGoTop()
		
Return
