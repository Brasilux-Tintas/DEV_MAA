#Include "totvs.ch"
#INCLUDE 'PROTHEUS.CH'                                        
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'COLORS.CH'                                                                              
#INCLUDE 'FONT.CH'
#INCLUDE 'INKEY.CH'
#INCLUDE 'vkey.CH'
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BRFATX70  ³ Autor ³ José Uliana         ³ Data ³ 11/10/24  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera Pedido de Transferência para Matriz   por Pallet      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function BRFATX70()
Local _cNomefunc := PadR(funname(), TamSX3("ZW_ROTINA")[1],' ') 
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
   	Private nQtdeItens := 150 //150 //Quantidade máxima de itens por pedido de transferência

     Private oTempTbl1
   
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFontEnv", "oFon3Env", "oDlg1Env", "oGrp1Env", "oSay1Env", "oSay2Env", "oGet1Env", "oGet2Env", "oBtn1Env", "oBtn2Env")
     SetPrvt("oBtn3Env", "oBtn4Env", "oBtn5Env", "oBtn6Env", "oBtn7Env", "oBrw1Env", "oGrp3Env", "oSay4Env", "oBtn6Env", "oSay3Env")
     SetPrvt("oSay7Env", "oSay8Env", "oSay9Env", "oSayAEnv", "oSay2Env")

	// Jose 11/10/2024
 	If !u_VldAcesso(_cNomefunc)
      	MsgBox("Acesso não autorizado!---->"+_cNomefunc,"Atenção","Alert")
     	Return 
  	Endif 

// Jose 11/11/2024   Acesso empresas 010106 ou 010108
     If !(alltrim(cNumEmp) == "01010106") .and. !(alltrim(cNumEmp) == "01010108")
          MessageBox( "Acesso deverá ser feito pelo Deposito Araraquara ou Guarulhos!", "Atenção", 48 )
          return
     Endif 
// Jose 11/11/2024 até aqui


     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFon1Env   := TFont():New( "Courier New"  , 0,  12, , .T., 0, , 400, .F., .F., , , , , , )
     oFontEnv   := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
     oFon2Env   := TFont():New( "Courier New"  , 0,  19, , .T., 0, , 400, .F., .F., , , , , , )
     oFon3Env   := TFont():New( "Courier New"  , 0,  25, , .T., 0, , 400, .F., .F., , , , , , )
     
     oDlg1Env   := MSDialog():New( 140, 264, 750, 1100, "Gera Pedido de Devolução para a Matriz", , , .F., , , , , , .T., , , .T. )
     oGrp1Env   := TGroup():New( 003, 004, 048, 356, "Dados da Carga", oDlg1Env, CLR_RED, CLR_WHITE, .T., .F. )
     oSay1Env   := TSay():New( 012, 008, { || "Carga :"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
     oGet1Env   := TGet():New( 010, 040, { |u| If(PCount() > 0, cGet1Env := u, cGet1Env)}, oGrp1Env, 073, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGet1Env", , ) 
     oGet1Env:bLostFocus := {|| Iif(!Empty(Alltrim(cGet1Env)),fInfCarga(),"")}

     //oSay2Env   := TSay():New( 012, 008, { || "Carro :"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
     //oGet2Env   := TGet():New( 010, 040, { |u| If(PCount() > 0, cGet2Env := u, cGet2Env)}, oGrp1Env, 073, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGet2Env", , ) 
     
     oSay4Env   := TSay():New( 030, 152, { || cSay4Env  }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., cCor4Env, CLR_WHITE, 106, 012)
     oBtn1Env   := TButton():New( 009, 297, "Confirma", oGrp1Env, {|| MsAguarde({|| fTrPLote()}, "Aguarde...", "Processando...")}, 052, 016, , oFontEnv, , .T., , "", , , , .T. )

	 oBtn2Env   := TButton():New( 030, 297, "Abandona", oGrp1Env, {|| fSairTPa()}, 052, 016, , oFontEnv, , .T., , "", , , , .F. )
     oGrp2Env   := TGroup():New( 050, 004, 268, 356, "", oDlg1Env, CLR_BLACK, CLR_WHITE, .T., .F. )

     oBtn3Env   := TButton():New( 068, 290, "<- Incluir ->" , oGrp2Env, {|| fMLocPall(1) }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )
     oBtn4Env   := TButton():New( 088, 290, "<- Excluir ->" , oGrp2Env, {|| fMLocPall(2) }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )
	 
	 
	 oSay2Env   := TSay():New( 138, 290, { || "Impressora"}, oGrp2Env, , oFon2Env, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012) // 138
     oCBox1Co   := TComboBox():New( 148, 290, {|u| If(PCount() > 0, nCBox1Co := u, nCBox1Co)}, {"", "ZEBRA S4M", "ZEBRA ZT230"}, 060, 016, oGrp2Env, , , , CLR_BLACK, CLR_WHITE, .T., oFon2Env, "", , , , ,  , , nCBox1Co ) // 138
     oBtn6Env   := TButton():New( 169, 290, "<- Imp.Etq ->" , oGrp2Env, {|| fIEtPallet(nCBox1Co) }, 060, 012, , oFon2Env, , .T., , "", , , , .F. ) // 148

     oSay6Env   := TSay():New( 012, 202, {|| "Destino :"     }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 035, 012)
     //oGet6Env   := TGet():New( 010, 242, {|u| If(PCount() > 0, cGet6Env := u, cGet6Env)}, oDlg1Env, 036, 012, '@R 999999'          , , CLR_BLACK, CLR_WHITE, oFontEnv, , , .T., "", , , .F., .F., , .F. , .F., "SA1"    ,"cGet6Env", , )
     oGet6Env   := TComboBox():New( 010, 242, {|u| If(PCount() > 0, cGet6Env := u, cGet6Env)}, {"", "00354"}, 050, 016, oGrp1Env, , , , CLR_YELLOW, CLR_WHITE, .T., oFontEnv, "", , , , ,  , , cGet6Env ) // {"", "023818", "052817"}

     oSay8Env   := TSay():New( 222, 283, { || "Pallets:"}, oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 050, 020)
     oSay7Env   := TSay():New( 222, 338, { || nCount    }, oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 020, 020)

     oSayAEnv   := TSay():New( 240, 288, { || "<- Peso ->"} , oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 020)
     oSay9Env   := TSay():New( 253, 284, { || nPesoTot    } , oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 065, 020)

     //oBtn5Env 	:= TButton():New( 238, 290, "<-Transfere->" , oGrp2Env, {|| fTrLocais( )  }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )     
     oSay3Env   := TSay():New( 031, 020, { || cSay3Env  },   oGrp1Env, , oFon2Env, .F., .F., .F., .T., CLR_YELLOW, CLR_WHITE, 245, 015)

     //oBtn7Env 	:= TButton():New( 128, 288, "<-Res Pallet->" , oGrp2Env, {|| U_fResPallet(2) }, 064, 016, , oFon2Env, , .T., , "", , , , .F. )
 	 //oBtn7Env:lVisibleControl := .f.	

     oBtn6Env 	:= TButton():New( 188, 288, "<-Res  Carga->"  , oGrp2Env, {|| fImpRel()       }, 064, 014, , oFon2Env, , .T., , "", , , , .F. ) // 064,016 Jose 09/10/2024
	 // Jose 09/10/2024  acrescentado 
     oBtn6Env 	:= TButton():New( 205, 284, "<-Dest.Pallet->" , oGrp2Env, {|| fDesPla()       }, 070, 014, , oFon2Env, , .T., , "", , , , .F. )
	 // Jose 09/102024  até aqui               
 	 //oBtn6Env:lVisibleControl := .f.	

     oTblTrans()
     DbSelectArea("TMPTRANS")
     DbSetOrder(1)
     DbGoTop()
     oBrw1Env   := MsSelect():New( "TMPTRANS", "", "", { {"TMPPAL", "", "Pallet", "@!"}, { "TMPVOL", "", "Volume", "@!"},{ "TMPUNI", "", "Qtd. Unit", "@!"},{ "TMPPES", "", "Peso", "@E 999,999.99"} ,{ "TMPSTA", "", "Pedidos", "@!"}}, .F., , {056, 007, 266, 280}, , , oGrp2Env ) 
     
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
           MSCBSay(32,25,"PEDIDO "+Alltrim(Substr(TMPTRANS->TMPSTA,1,9))+fNumNfm(Substr(TMPTRANS->TMPSTA,1,6)) ,"N", "0"	,"30,30")
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
Function  ³ fTrPLote() - Geração  do pedido de transferência PARA MATRIZ através
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
Local _cItem    := ""
Local cObs      := ""
Local cNPedidos := ""
Local cAuxMens  := ""
//Local cLocPro   := ""
Local cQry1     := ""
Local cCodCARGA := ""
Local nW, nZ, nX, nI, nE, _nY, _nSalDev,_nSalDisp,_nQtdDev,_lCompletouCarga,nTotPed
Local nIni,nFim,cNotaIni,cNotaFim,nP,_cPed,_cSerieNf,_lReturn,_lAutoriz,_cLocal,_cAux
Local nMaxTentativas := 5 // Quantidade máxima de tentativas de monitoramento de notas fiscais
Local nTentatiavas   := 0 // Contador de tentativas de monitoramento
Local nTamNota  := GetSx3Cache("F2_DOC"  ,"X3_TAMANHO")
Local nTamSerie := GetSx3Cache("F2_SERIE","X3_TAMANHO")
Local _oNota, _oPedido as Object
Local aParam         := Array(5) //Parâmetros para o monitoramento de notas fiscais transmitidas
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
    cObs     :=	"RETORNO ENTRE DEPÓSITO -> MATRIZ "+cGet6Env+" - (PALLETS BIPADOS) " // Jose 21/11/2024 "REMESSA ENTRE DEPÓSITO -> MATRIZ "+cGet6Env+" - (PALLETS BIPADOS) "
    
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
	cQry1 += " SELECT ZZK_PRODUT, SUM(ZZK_QUANT) AS ZZK_QUANT, B1_MSBLQL, B1_VEND, B1_TIPO "//, B1_PRV1, B2_CM1, B1_UM "
	cQry1 += " FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL  = '"+xFilial("SB1")+"' AND ZZK_PRODUT = B1_COD AND SB1.D_E_L_E_T_ ='' "  // jOSE 14/10/2024 ZZK_FILIAL
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZJ_CODIGO = ZZK_CODIGO AND ZZJ.D_E_L_E_T_ ='' "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON B2_FILIAL = '010101' AND B2_COD = B1_COD AND B2_LOCAL = CASE WHEN B1_TIPO ='MP' THEN '01' ELSE CASE WHEN B1_TIPO ='PI' THEN '02' ELSE CASE WHEN B1_TIPO ='PA' THEN '03' ELSE CASE WHEN B1_TIPO ='MC' THEN '04' ELSE B1_LOCPAD END END END END AND SB2.D_E_L_E_T_ ='' " // jOSE 14/10/2024 B1_FILIAL
	cQry1 += " WHERE ZZK.D_E_L_E_T_ ='' " 
	cQry1 += " AND ZZK_CODIGO IN "+cPallets 
	cQry1 += " AND ZZJ_FLAG IN('1','2','3','4') " 
	cQry1 += " AND ZZJ_FILIAL = '010101' " //  jose 14/10/2024  '"+xFilial("ZZJ")+"'/"/
	cQry1 += " GROUP BY ZZK_PRODUT, B1_MSBLQL, B1_VEND, B1_TIPO, B2_CM1, B1_PRV1 " //, B1_DESC" //, B1_UM "  
	cQry1 += " ORDER BY SUBSTRING(ZZK_PRODUT,4,2), ZZK_PRODUT ;"

	TCQuery cQry1 ALIAS "TCQ" NEW
	DbSelectArea("TCQ")
	DbGoTop()
	
	If TCQ->(EOF())  
   	   Messagebox("Não encontrado produtos dentro dos pallets informados ! ","Atenção...",48)  
	   DbSelectArea("TCQ")
	   DbCloseArea()
	   Return
	endif 
	aTrPallet 	:= {} 
	_lCompletouCarga := .t. // Flag para verificar se completou a carga com devolução das notas de entrada

   	While !(TCQ->(EOF()))  
	   		 If TCQ->B1_MSBLQL ='1'
				aAdd(aProdBloq, {Alltrim(TCQ->ZZK_PRODUT)} )	
		   	 Endif
		   	 If TCQ->B1_VEND ='N'
				aAdd(aProdNVend, {Alltrim(TCQ->ZZK_PRODUT)} )		   	
	   		 Endif



	        //Cleber(09/08/25) -> Buscar saldos de devolução disponíveis
			cQry1 := "WITH TMP AS (SELECT C6_NUM,C6_ITEM,C6_PRODUTO,C6_NFORI,C6_ITEMORI,C6_SERIORI,C6_QTDVEN FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
			cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = C6_FILIAL) AND (C5_NUM = C6_NUM) "
			cQry1 += "LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) ON (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = C6_FILIAL) AND (D2_PEDIDO = C6_NUM) AND (D2_ITEMPV = C6_ITEM) "
			cQry1 += "WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C5_CLIENTE = '"+cGet6Env+"') AND "
			cQry1 += "(C6_TES = '827') AND (C5_TIPO = 'D') AND (C6_PRODUTO = '"+TCQ->ZZK_PRODUT+"') AND (SD2.R_E_C_N_O_ IS NULL) ) "
			cQry1 += "SELECT D1_QUANT - (D1_QTDEDEV - ISNULL(TMP.C6_QTDVEN,0)) AS SALDEV,D1_VUNIT,D1_DOC,D1_SERIE,D1_ITEM, D1_QTDEDEV, D1_VALDEV, D1_TOTAL  "
			cQry1 += "FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "
			cQry1 += "LEFT OUTER JOIN TMP WITH (NOLOCK) ON (D1_DOC = TMP.C6_NFORI) AND (D1_SERIE = TMP.C6_SERIORI) AND (TMP.C6_PRODUTO = D1_COD) AND (TMP.C6_ITEMORI = D1_ITEM) "
			cQry1 += "WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'N') AND (D1_FORNECE = '"+cGet6Env+"') AND "
			cQry1 += "(D1_TES = '227') AND (D1_COD = '"+TCQ->ZZK_PRODUT+"') AND (D1_QUANT > (D1_QTDEDEV - ISNULL(TMP.C6_QTDVEN,0))) "
			cQry1 += "ORDER BY D1_DTDIGIT ;"
			If Select('TCQ1') > 0
				DbSelectArea("TCQ1")
				DbCloseArea()
			endif 
			TCQuery cQry1 ALIAS "TCQ1" NEW
			DbSelectArea("TCQ1")
			DbGoTop()
			_nSalDev := TCQ->ZZK_QUANT //Saldo total a devolver
			_nQtdDev := 0 //Quantidade a devolver
			//_VUnit   := 0 
		
			while !(TCQ1->(EOF())) .and. _nSalDev > 0
				_VUnit   := 0 
				_nSalDisp := TCQ1->SALDEV //Quantidade disponível do item
				if _nSalDev < _nSalDisp
					_nQtdDev := _nSalDev
				elseif _nSalDev == _nSalDisp
					_nQtdDev := _nSalDisp
					TCQ1->D1_VUNIT := ((TCQ1->D1_TOTAL - TCQ1->D1_VALDEV) / _nQtdDev)
				elseif _nSalDev > _nSalDisp
					_nQtdDev := _nSalDisp
					_VUnit :=  ((TCQ1->D1_TOTAL - TCQ1->D1_VALDEV) / _nQtdDev) // TRATAMENTO PARA NÃO DAR DIFERENÇA DE ARREDONDAMENTO
				endif
				_nSalDisp := _nSalDisp - _nQtdDev
				_nSalDev := _nSalDev - _nQtdDev
				
	    		aAdd(aTrPallet, {TCQ->ZZK_PRODUT ,_nQtdDev, TCQ->B1_TIPO, Iif(_VUnit > 0 , _VUnit , TCQ1->D1_VUNIT), TCQ1->D1_DOC,TCQ1->D1_SERIE,TCQ1->D1_ITEM }) //, TCQ->B1_DESC, TCQ->B1_UM})
				if _nSalDisp <= 0
					dbskip()
				endif 
			enddo 
			if _nSalDev > 0
				_lCompletouCarga := .f. // Não completou a carga, pois ainda há saldo a devolver
				// Se não houver saldo disponível para devolução, exibe mensagem de erro
				messagebox("Produto "+TCQ->ZZK_PRODUT+" não possui saldo disponível para devolução nas notas de entrada!","Atenção",48)
				exit 
			endif 

    	     //aAdd(aTrPallet, {TCQ->ZZK_PRODUT ,TCQ->ZZK_QUANT, TCQ->B1_TIPO, TCQ->B2_CM1, TCQ->B1_PRV1 }) //, TCQ->B1_DESC, TCQ->B1_UM})
	   		 DbSelectArea("TCQ")
   	  		 DbSkip()
	Enddo
	DbSelectArea("TCQ")
	DbCloseArea()/*

			while !(TCQ1->(EOF())) .and. _nSalDev > 0
				_nSalDisp := TCQ1->SALDEV //Quantidade disponível do item
				if _nSalDev <= _nSalDisp
					_nQtdDev := _nSalDev
				else
					_nQtdDev := _nSalDisp
				endif
				_nSalDisp := _nSalDisp - _nQtdDev
				_nSalDev := _nSalDev - _nQtdDev
	    		aAdd(aTrPallet, {TCQ->ZZK_PRODUT ,_nQtdDev, TCQ->B1_TIPO, TCQ1->D1_VUNIT, TCQ1->D1_DOC,TCQ1->D1_SERIE,TCQ1->D1_ITEM }) //, TCQ->B1_DESC, TCQ->B1_UM})
				if _nSalDisp <= 0
					dbskip()
				endif 
			enddo 
			if _nSalDev > 0
				_lCompletouCarga := .f. // Não completou a carga, pois ainda há saldo a devolver
				// Se não houver saldo disponível para devolução, exibe mensagem de erro
				messagebox("Produto "+TCQ->ZZK_PRODUT+" não possui saldo disponível para devolução nas notas de entrada!","Atenção",48)
				exit 
			endif 

    	     //aAdd(aTrPallet, {TCQ->ZZK_PRODUT ,TCQ->ZZK_QUANT, TCQ->B1_TIPO, TCQ->B2_CM1, TCQ->B1_PRV1 }) //, TCQ->B1_DESC, TCQ->B1_UM})
	   		 DbSelectArea("TCQ")
   	  		 DbSkip()
	Enddo
	DbSelectArea("TCQ")
	DbCloseArea()
	*/

	if !_lCompletouCarga
		return // Se não completou a carga, não gera o pedido
	endif 

	nCount     := Ceiling(Len(aTrPallet)/nQtdeItens) // Quantidade de pedidos a serem gerados
	nPesoTot   := 0
	For nE := 1 To Len(aTrPallet)
		nPesoTot += aTrPallet[nE][2] * aTrPallet[nE][4] // aTrPallet[nE][4] Peso Unitário
	Next
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

		nTotPed := 0
		For nX := 1 To Ceiling(Len(aTrPallet)/nQtdeItens)       
		   	aCabec    := {}
	       	aItens    := {}
 		    _cItem    := 0
 		    nY 		  := 1
 		  //_cNumPed  := GetSxeNum("SC5","C5_NUM")

 		    aAdd(aCabec,{"C5_FILIAL"     ,		xFilial("SC5")     								        ,Nil}) 
  	   	  //aAdd(aCabec,{"C5_LOJACLI"    ,		Posicione("SA1", 1, xFilial("SA1")+cGet6Env, "A1_LOJA")	,Nil})
		  //aAdd(aCabec,{"C5_NUM"        ,		_cNumPed												,.f.})
       		aAdd(aCabec,{"C5_TIPO"       ,		"D"              										,Nil}) // Jose 22/11/2024 "D"  
	       	aAdd(aCabec,{"C5_CLIENTE"    ,		cGet6Env     											,Nil})
       		aAdd(aCabec,{"C5_EMISSAO"    ,		dDatabase          										,Nil})
       		aAdd(aCabec,{"C5_CONDPAG"    ,		"001"            									  	,Nil})
   	   	    aAdd(aCabec,{"C5_TPFRETE"    , 		"C"                             					    ,NIL})       
 		    aAdd(aCabec,{"C5_DEPOSI"     , 		"N"   							                        ,NIL})  
       		aAdd(aCabec,{"C5_TRANSP"     ,		"00250"      	   										,Nil})
          //aAdd(aCabec,{"C5_REDESP"     ,		"" 		  	   											,Nil})
    	   	aAdd(aCabec,{"C5_OBS"        ,		cObs      												,Nil})
			aAdd(aCabec,{"C5_X_OBSFA"    ,		cObs      												,Nil})
			aAdd(aCabec,{"C5_OBSNF"      , 		"Devolução de Mercadorias para MATRIZ!! "           	,NIL}) // 21/11/2024 "Transferência de Mercadorias para DEPÓSITO FECHADO!!"

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
			For nI:= (nDe + 1) To Iif((nQtdeItens + nDe) <= Len(aTrPallet), (nQtdeItens + nDe), Len(aTrPallet))

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
				/* //Cleber(09/08/25) -> Estará pegando custos da nota de entrada
  	      		cQry := "SELECT dbo.PrecoEstoque('010101'"+",'"+aTrPallet[nI][1]+"') AS PRCESTOQUE " // CUSTO DE FECHAMENTO DE ESTOQUE //   Jose 14/10/2024 '"+xFilial("SB1")+"'
           		TCQuery cQry ALIAS "TCQ" NEW
	      		DbSelectArea("TCQ")
           		If !eof() .and. !bof()
	           		nPrcVen:= TCQ->PRCESTOQUE
    	  		Endif	
    	  		DbSelectArea("TCQ")
    	  		DbClosearea()	
				*/
				//Cleber(09/08/25) -> Estará pegando custos da nota de entrada
                aLinha := {}
				aAdd(aLinha,{"C6_ITEM"   ,      _cItem								                    ,Nil})
    		    aAdd(aLinha,{"C6_PRODUTO",		aTrPallet[nI][1]   										,Nil})
	    	    aAdd(aLinha,{"C6_QTDVEN" ,		aTrPallet[nI][2]   										,Nil})
        		aAdd(aLinha,{"C6_PRCVEN" ,		aTrPallet[nI][4]  										,Nil})
	        	aAdd(aLinha,{"C6_TES"    ,		"827"              										,Nil}) // Jose 21/11/2024 "823"
        		aAdd(aLinha,{"C6_NFORI"  ,		aTrPallet[nI][5]   								        ,Nil})
        		aAdd(aLinha,{"C6_SERIORI",		aTrPallet[nI][6]   								        ,Nil})
				aAdd(aLinha,{"C6_ITEMORI",		aTrPallet[nI][7]   								        ,Nil})
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
/*       			DbSelectArea("TMPTRANS")
			  	DbGotop() */
				exit // Se houve erro, sai do loop e não gera mais pedidos
    	      //Return //LGS#20200210 - Adequação de release 12.1.25 e posteriores - Não pode usar return dentro de Begin transaction
	        Else
				dbselectarea("ZB7")
         		RecLock("ZB7", .T.)
				ZB7->ZB7_FILIAL := xFilial("ZB7")
				ZB7->ZB7_CODIGO := GetSXENum("ZB7","ZB7_CODIGO",1)
				ZB7->ZB7_ORIGEM := '0' //Pedido
				ZB7->ZB7_FILORI := xFilial("SC5")
				ZB7->ZB7_CODORI := SC5->C5_NUM
				ZB7->ZB7_PROCES := "Nota Fiscal a ser gerada" 
				ZB7->ZB7_CODPRO := "003" //Saídas como Devolução Depósitos->Matriz
				ZB7->ZB7_STATUS := "E1" //Colocar status de alerta, se cair o sistema ficará o alerta
         		MsUnLock()

    	      //ConfirmSX8()
        		nDe := (nDe + nQtdeItens)
	        Endif

			cNPedidos += SC5->C5_NUM+" / " 
			nTotPed++ 
		Next nX
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
    	DbSelectArea("TCQ")
	    DbCloseArea()

		DbSelectArea("TMPTRANS")
	    DbGotop()


		If !lMsErroAuto
		

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
			cQry1 += " WHERE (ZZJ.D_E_L_E_T_ <> '*') AND ZZJ.ZZJ_FILIAL = '010101' " // '"+xFilial("ZZJ")+"'"  jose 11/10/2024
			cQry1 += " AND ZZJ.ZZJ_DTTRAN   = '"+DTOS(Date())+"' "
			cQry1 += " ORDER BY ZZJ.ZZJ_CARGA DESC "
			TCQUERY cQry1 ALIAS "TCQ" NEW
			DbSelectArea("TCQ")
			DbGoTop()
		
			cCodCARGA := Iif(Empty(TCQ->ZZJ_CARGA), 'C'+SubStr(Dtos(Date()), 7, 2)+SubStr(Dtos(Date()), 5, 2)+SubStr(Dtos(Date()), 3, 2)+'/'+'0001', SubStr(TCQ->ZZJ_CARGA, 1, 8)+StrZero(Val(SubStr(TCQ->ZZJ_CARGA, 9, 4))+1, 4) )
			//           Iif(Empty(TCQ->ZZJ_CARGA),     SubStr(Dtos(Date()), 7, 2)+SubStr(Dtos(Date()), 5, 2)+SubStr(Dtos(Date()), 3, 2)+'/'+'0001', SubStr(TCQ->ZZJ_CARGA, 1, 7)+StrZero(Val(SubStr(TCQ->ZZJ_CARGA, 8, 4))+1, 4) )

			DbSelectArea("TCQ")
			DbCloseArea()

	//  jOSE 11/11/2024 TIRADO SET ZZJ_FLAG ='5' E SUBSTITUIIDO POR SET ZZJ_LOCORI = ZZJ_LOCALI
			_cLocal := Iif(xFilial("ZZJ") = '010108', 'A3', 'G3') 
			cQry1 := " "
			cQry1 += " UPDATE "+RetSqlName("ZZJ")+" SET ZZJ_LOCORI = '"+_cLocal+"', ZZJ_OBSPED ='"+cNPedidos+"', ZZJ_CARGA ='"+cCodCARGA+"' FROM "+RetSqlName("ZZJ")+"  WHERE ZZJ_CODIGO IN "+cPallets "
			cQry1 += " AND D_E_L_E_T_ ='' AND ZZJ_FLAG IN('1','2','3','4') AND ZZJ_FILIAL = '010101' " // Jose 14/10/204 '"+xFilial("ZZJ")+"'"
			XXX := TCSQLExec(cQry1) 
			If XXX <> 0
				cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
				MemoWrit(cNomArq, cQry1)
			Endif
		//aAdd(aCustErro, {aTrPallet[nI][1],aTrPallet[nI][2],aTrPallet[nI][4],_cItem} )	
			If Len(aCustErro) >0
				cAuxMens := ""
				For nE := 1 to Len(aCustErro)
					cAuxMens += "PRODUTO -> "+aCustErro[nE][1]+"  QTDE->  "+TRANSFORM(aCustErro[nE][2],'@E 999,999,999')+"  CUSTO MEDIO NO MOMENTO DO PEDIDO ->   "+TRANSFORM(aCustErro[nE][3],'@E 999,999,999.9999')
					cAuxMens +=" "+chr(13)+chr(10)
					cAuxMens +=" "+chr(13)+chr(10)
				Next
				cAuxMens += chr(13)+chr(10)+"Prog. Origem : BRFATX70"
				U_EnvMail("BRASILUX - Verificar Custo dos itens dos pedidos "+cNPedidos+"  !",cAuxMens,"andre@brasilux.com.br","")                       	  
			Endif
	endif 	
	End Transaction		
	If lMsErroAuto
		return
	endif 
	cGet1Env := cCodCARGA 

    cSay3Env := "Pedido(s) de transferência gerado(s) com Sucesso !!"
	oSay3Env:SetText(cSay3Env)
	MsProcTxt(cSay3Env)
	oSay3Env:CtrlRefresh()


/*
    Messagebox("Pedido(s) de transferência por Pallet(s) gerado(s) com Sucesso !! ","Aviso",48)    		
    cSay3Env := "Pedido(s) de transferência por Pallet(s) gerado(s) !!"
    
    oSay3Env:Refresh()
  */  

	If nTotPed >0
		_lReturn := .f.
		nIni := 1
		nFim := 6
		cNotaIni := ""
		cNotaFim := ""
		_cSerieNf := PadR( "1", nTamSerie)
		// Cleber(01/08/25) : Primeiro gerar as notas para depois transmitir todas de uma vez
		For nP := 1 to nTotPed
			_cPed := SUBSTR(cNPedidos,nIni,6)
			dbselectarea("ZB7")
			dbsetorder(2)
			_cAux := xFilial("ZB7")+"0"+PADR(_cPed,GetSx3Cache("ZB7_CODORI"  ,"X3_TAMANHO"))+xFilial("SC5")
			dbselectarea("ZB7")
			dbseek(_cAux,.T.)
				
			dbselectarea("SC5")

			_oNota	:= BRAFATS02_NF():New() //Cleber(28/07/25) : iniciando o objeto aqui ao invés de no começo da função
			_oPedido	:= BRAFATS02_PEDIDO():New()
			_oPedido:FreeBySC6(_cPed)
			_oNota:MakeByPedido(_cPed)
			_oNota:cSerie	:= _cSerieNf
			cSay3Env := 'Gerando a Nota Fiscal para o pedido: '+_cPed
			oSay3Env:SetText(cSay3Env)
			MsProcTxt(cSay3Env)
			oSay3Env:CtrlRefresh()

			_lReturn := _oNota:Save()
			If _lReturn 
				cSay3Env := "Pedido  de transferência "+_cPed+" FATURADO !!"
				oSay3Env:SetText(cSay3Env)
				MsProcTxt(cSay3Env)
				oSay3Env:CtrlRefresh()

				DbSelectArea("SF2")
				DbOrderNickName("SF2001") //F2_FILIAL+F2_PEDIDO  
				DbSeek(xFilial("SF2")+_cPed, .F.)
				If Found()
					if nP == 1
						cNotaIni := SF2->F2_DOC
					endif 
					cNotaFim := SF2->F2_DOC
					dbselectarea("ZB7")
					RecLock("ZB7", .F.)
					ZB7->ZB7_PROCES := "Nota Fiscal a ser transmitida"
					ZB7->ZB7_CODREF := SF2->F2_DOC
					ZB7->ZB7_STATUS := "E2" //Colocar status de alerta ainda
					MsUnLock()
				else 
					cSay3Env := "Pedido NÃO GEROU NF!!"
					dbselectarea("ZB7")
					RecLock("ZB7", .F.)
					ZB7->ZB7_PROCES := cSay3Env
					ZB7->ZB7_STATUS := "E9" //Colocar status de alerta ainda
					MsUnLock()


					oSay3Env:CtrlRefresh()
					Messagebox(cSay3Env,"Atenção...",48)   
					return
				endif

			else 
				dbselectarea("ZB7")
				RecLock("ZB7", .F.)
				ZB7->ZB7_PROCES := "Pedido NÃO GEROU NF"
				ZB7->ZB7_STATUS := "E9" 
				MsUnLock()

				return 
			endif 
			freeobj(_oNota)
			freeobj(_oPedido)
			_oNota	:= Nil 
			_oPedido	:= Nil

			nIni := (nIni+9)
			nFim := (nFim+9)
		Next nP

		cSay3Env := "Transmitindo NFe(s) "
		oSay3Env:SetText(cSay3Env)
		MsProcTxt(cSay3Env)
		oSay3Env:CtrlRefresh()

		if !Empty(cNotaIni) .and. !Empty(cNotaFim)
			dbselectarea("SF2")

			_oNota	:= ERPFISS01_NFE_SEFAZ():New()
	
			_oNota:Init()

			_oNota:oFaixaDeNotas:cSerie	:= _cSerieNf
			_oNota:oFaixaDeNotas:cNumero_Inicial	:= cNotaIni
			_oNota:oFaixaDeNotas:cNumero_Final	:= cNotaFim
			_lReturn := _oNota:Transmite()    
			if _lReturn
				cSay3Env := "Nota(s) Fiscal(is) de Transferência transmitidas !!"
				oSay3Env:SetText(cSay3Env)
				MsProcTxt(cSay3Env)
				oSay3Env:CtrlRefresh()
				//_oNota:PrintDANFEII()	//Cleber(01/08/25) : Não funciona.
				FreeObj(_oNota)
				_oNota := Nil
				//Monitora NF-e
				_lAutoriz := .t.
				nTentatiavas   := 0
				nMaxTentativas := (nTotPed * 3)+1 // Cleber(01/08/25) : Máximo de tentativas para aguardar autorização das notas de transferência
				dbselectarea("SF2")
				dbsetorder(1)
				While (nTentatiavas < nMaxTentativas)
					cSay3Env := "Aguardando autorização da(s) Nota(s) Fiscal(is) ..."
					oSay3Env:SetText(cSay3Env)
					MsProcTxt(cSay3Env)
					oSay3Env:CtrlRefresh()
					//cNota := PadR( cNotaIni, nTamNota)
					dbseek(FWxFilial("SF2")+padr(cNotaIni,nTamNota)+_cSerieNf,.T.)
					_lAutoriz := .t.
					while _lAutoriz .and. !eof() .and. (SF2->F2_FILIAL == FWxFilial("SF2")) .and. (SF2->F2_SERIE == _cSerieNf) .and. (SF2->F2_DOC <= cNotaFim)  
						_lAutoriz := !Empty(SF2->F2_DAUTNFE)
						if !_lAutoriz
							dbselectarea("ZB7")
							dbsetorder(2)
							_cAux := xFilial("ZB7")+"0"+PADR(SF2->F2_PEDIDO,GetSx3Cache("ZB7_CODORI"  ,"X3_TAMANHO"))+xFilial("SC5")
							dbselectarea("ZB7")
							dbseek(_cAux,.T.)
							if found()
								RecLock("ZB7", .F.)
								ZB7->ZB7_PROCES := "NF de Transferência NÃO AUTORIZADA!"
								ZB7->ZB7_STATUS := "E9"
								MsUnLock()
							endif 
							exit 
						endif 
						dbselectarea("SF2")
						dbskip()
					enddo 
					if !_lAutoriz
						aParam[01] := PadR( _cSerieNf, nTamSerie)
						aParam[02] := padr(cNotaIni,nTamNota)
						aParam[03] := padr(cNotaFim,nTamNota)

						ChamaMonit(aParam, /*nTpMonitor*/, /*cModelo*/, /*lCte*/ , /*lMsg*/, /*lMDFe*/, /*lTMS*/)
					else 
						exit // Sai do loop se já tiver autorizado
					endif 
					//Aguarda alguns segundos para monitorar novamente
					Sleep(3000) 
					nTentatiavas++
				EndDo
				//Se não autorizar pela rotina anterior, tentar uma alternativa
				if !_lAutoriz
					dbselectarea("SF2")
					dbsetorder(1)
					dbseek(FWxFilial("SF2")+padr(cNotaIni,nTamNota)+_cSerieNf,.T.)
					while !eof() .and. (SF2->F2_FILIAL == FWxFilial("SF2")) .and. (SF2->F2_SERIE == _cSerieNf) .and. (SF2->F2_DOC <= cNotaFim)  
						aInfo := u_zTransNfe(SF2->F2_DOC, SF2->F2_SERIE)
						_lAutoriz := aInfo[1]
						if !_lAutoriz
							exit 
						endif 
						dbselectarea("SF2")
						dbskip()
					enddo
				endif 

				if !_lAutoriz
					cSay3Env := "NFe(s) NÃO AUTORIZADA(S), verifique !!"+ aInfo[2]
					oSay3Env:SetText(cSay3Env)
					MsProcTxt(cSay3Env)
					oSay3Env:CtrlRefresh()
				else 
						dbselectarea("ZB7")
						dbsetorder(2) //ZB7_FILIAL+ZB7_ORIGEM+ZB7_CODORI+ZB7_FILORI                                                                                                                     
						dbselectarea("SF2")
						dbsetorder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO                                                                                                  
						dbseek(xFilial("SF2")+cNotaIni+PadR( _cSerieNf, nTamSerie),.t.)
						do while !eof() .and. (SF2->F2_SERIE == PadR( _cSerieNf, nTamSerie) ) .and. (SF2->F2_DOC >= cNotaIni) .and. (SF2->F2_DOC <= cNotaFim)
							dbselectarea("ZB7")
							dbseek(xFilial("ZB7")+"0"+PADR(SF2->F2_PEDIDO,GetSx3Cache("ZB7_CODORI"  ,"X3_TAMANHO"))+xFilial("SC5"),.T.)
							if found()
								RecLock("ZB7", .F.)
								ZB7->ZB7_PROCES := "A ser dada a entrada na nota no depósito"
								ZB7->ZB7_STATUS := "E3" 
								MsUnLock()
							endif 
							dbselectarea("SF2")
							dbskip()
						enddo 
					fGerDanfe(cNotaIni, cNotaFim, _cSerieNf,Nil,"NFE_"+cNotaIni+"-"+cNotaFim+"_TRANSF_CLIENTE_"+cGet6Env) // Cleber(01/08/25) : Gerando Danfe para as notas de transferência					
				endif 
			else 
				cSay3Env := "Nota(s) Fiscal(is) de Transferência NÃO TRANSMITIDA(S), verifique !!"
				Messagebox(cSay3Env,"Atenção...",48)   
				oSay3Env:SetText(cSay3Env)
				MsProcTxt(cSay3Env)
				oSay3Env:CtrlRefresh()
				return
			endif
			_oNota	:= Nil
		else 
			cSay3Env := "Nenhuma Nota Fiscal de Transferência gerada !!"
			oSay3Env:SetText(cSay3Env)
			MsProcTxt(cSay3Env)
			oSay3Env:CtrlRefresh()
			Messagebox(cSay3Env,"Atenção...",48)   
			return 
		endif
	Endif    

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
    cQry1 += " WHERE (ZZJ.ZZJ_FILIAL = '010101') " // '"+XFILIAL("ZZJ")+"') "
    cQry1 += "   AND (ZZJ.D_E_L_E_T_ = '') "
    cQry1 += "   AND ZZJ.ZZJ_CARGA = '"+cGet1Env+"' "
    cQry1 += "ORDER BY ZZJ_CODIGO"

    TCQuery cQry1 ALIAS "TCC" NEW
    DbSelectArea("TCC")
    If !Eof()
	    While !Eof()
	    	RecLock("TMPTRANS", .T.)
				TMPTRANS->TMPPAL := TCC->ZZJ_CODIGO
//				TMPTRANS->TMPUNI := U_fTotUnim(TCC->ZZJ_CODIGO,1) // jose 26//03/2025
                TMPTRANS->TMPUNI := fTotUnim(TCC->ZZJ_CODIGO,1) // jose 26//03/2025
//				TMPTRANS->TMPVOL := U_fTotUnim(TCC->ZZJ_CODIGO,2)// jose 26//03/2025
                TMPTRANS->TMPVOL := fTotUnim(TCC->ZZJ_CODIGO,2)// jose 26//03/2025
				TMPTRANS->TMPPES := round(fPesPalem(TCC->ZZJ_CODIGO),2)
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
	Local _zFilial := "010101"

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
		DbSeek(xFilial("ZZJ",_zFilial)+(_cPallet), .t.)  // Jose 14/10/2024 xFilial("ZZJ")
		If Found() .and. (ZZJ->ZZJ_FILIAL == _zFilial)   // Jose 14/10/2024 XFilial("ZZJ"))
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

// Jose 11/11/2024 alterado 

	        If ZZJ->ZZJ_LOCORI $ 'G3.A3'
				Messagebox("Pallet de Compra de pedidos por Borderô, com pedido de transferência gerado e Gerou Nota Fiscal de Transferência !! ","Atenção...",48)		
				oGet1Tr:Setfocus()
				Return
			Endif
// Jose 11/11/2024 até aqui

// Jose 11/11/2024 inibido 
/*
			If ZZJ->ZZJ_FLAG $ '5' 
				Messagebox("Pallet de Compra de pedidos por Borderô, com pedido de transferência gerado e Gerou Nota Fiscal de Transferência !! ","Atenção...",48)		
				oGet1Tr:Setfocus()
				Return
			Endif.
*/
// Jose 11/11/2024 aTÉ aQUI

//---  até aqui 25/09/2024 ----------------------

            If ZZJ->ZZJ_FLAG == '5' // Jose 22/11/2024
	           Messagebox("Este Pallet já foi feito Transferência para Guarulhos não pode ser Feita Nota Fiscal para ele ! ","Atenção...",48)  // Jose 22/11/2024
	           oGet1Tr:Setfocus() // Jose 22/11/2024
	           Return // Jose 22/11/2024
			Endif

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
//						TMPTRANS->TMPUNI := U_fTotUnim(_cPallet,1) // jose 26/03/2025
						TMPTRANS->TMPUNI := fTotUnim(_cPallet,1) // jose 26/03/2025
//						TMPTRANS->TMPVOL := U_fTotUnim(_cPallet,2) // jose 26/03/2025
                        TMPTRANS->TMPVOL := fTotUnim(_cPallet,2) // jose 26/03/2025
						TMPTRANS->TMPPES := round(fPesPalem(_cPallet),2) // jose 26/03/2025  u_fPesPalem
					MsUnLock()
					nCount   := (nCount +1) 
					oSay7Env:Refresh()
					nPeso    += TMPTRANS->TMPPES
					nPesoTot := Transform(nPeso, "@E 999,999.99")
					oSay9Env:Refresh()
				Endif
			Elseif ZZJ->ZZJ_FLAG $ '3.4' 
				/*
				If (ZZJ->ZZJ_LOCALI) $ 'FAB2' .AND. (ZZJ->ZZJ_FLAG $ '3')
					Messagebox("Pallet Montado na Fabrica 2 / Deve ser transferido de almoxarifado antes da geração da nota fiscal.", "Atenção...",48)			
					oGet1Tr:Setfocus()
					Return
					*/
				
					If (ZZJ->ZZJ_TIPBOR $ '2.3.4.5.6.7.8.9') .OR. (ZZJ->ZZJ_BORDER <> 'VARIOS ' .AND. Posicione("SZF", 1, xFilial("SZF")+ZZJ->ZZJ_BORDER, "ZF_TIPOBOR")='2')
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
//								TMPTRANS->TMPUNI := U_fTotUnim(_cPallet,1) // jose 26/03/2025
                                TMPTRANS->TMPUNI := fTotUnim(_cPallet,1) // jose 26/03/2025
//								TMPTRANS->TMPVOL := U_fTotUnim(_cPallet,2) // jose 26/03/2025
                                TMPTRANS->TMPUNI := fTotUnim(_cPallet,1) // jose 26/03/2025
								TMPTRANS->TMPPES := round(fPesPalem(_cPallet),2) // jose 26/03/2025 u_fPesPalem
							MsUnLock()
							nCount   := (nCount +1) 
							oSay7Env:Refresh()
							nPeso    += TMPTRANS->TMPPES
							nPesoTot := Transform(nPeso, "@E 999,999.99")
							oSay9Env:Refresh()
						Endif
					ElseIf Alltrim(ZZJ->ZZJ_TIPBOR)='' .AND. Alltrim(ZZJ->ZZJ_BORDER) <> 'VARIOS'		       		
						Reclock("ZZJ",.f.)
							ZZJ->ZZJ_TIPBOR := Posicione("SZF", 1, '010101'+ZZJ->ZZJ_BORDER, "ZF_TIPOBOR") // jose 27/03/2025 'xFilial("SZF")'
						MsUnlock()
					Else
						Messagebox("Pallet -->"+(_cPallet)+" tem o tipo de borderô inválido, se for pallet Depósito deve ser alterado o tipo, verifique !!","Atenção...",48)    	
						oGet1Tr:Setfocus()
						Return
					Endif
				//Endif
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


		If cPallets == "('"
		   Messagebox("Pallet -->"+(_cPallet)+" não cadastrado !!"+TMPTRANS->TMPPAL,"Atenção...",48)
		   oSay1Tr:Setfocus() 
	       return
		Endif 

		//Cleber(06/08/25) -> Esta linha abaixo estava antes do If cPallets == "('" acima, dava erro quando não tinha nenhum pallet cadastrado
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
		cQry += " AND ZZJ_FILIAL =  '010101' " //'"+xFilial("ZZJ")+"'"

		TCQuery cQry ALIAS "TCQ" NEW
		DbSelectArea("TCQ")
		DbGoTop()

		If  !TCQ->(EOF())  //!TCQ->(EOF()) 
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
				nPeso    := (nPeso - round(fPesPalem(_cPallet),2)) // jose 26/03/2025 u_fPesPalem
				nPesoTot := Transform(nPeso, "@E 999,999.99")
				oSay9Env:Refresh()
			Endif
		Endif
		DbSelectArea("TCQ")
		DbCloseArea()

/*// Cleber(08/08/25) -> Não limitar a quantidade de itens, será dividido o pedido
		cQry1 := " "
		cQry1 += " SELECT COUNT(DISTINCT(ZZK_PRODUT)) AS TOTALITEM "
		cQry1 += " FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON ZZK_FILIAL = B1_FILIAL  AND ZZK_PRODUT = B1_COD AND SB1.D_E_L_E_T_ ='' "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZJ_CODIGO = ZZK_CODIGO AND ZZJ.D_E_L_E_T_ ='' "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON B2_FILIAL = B1_FILIAL AND B2_COD = B1_COD AND B2_LOCAL = CASE WHEN B1_TIPO ='MP' THEN '01' ELSE CASE WHEN B1_TIPO ='PI' THEN '02' ELSE CASE WHEN B1_TIPO ='PA' THEN '03' ELSE CASE WHEN B1_TIPO ='MC' THEN '04' ELSE B1_LOCPAD END END END END AND SB2.D_E_L_E_T_ ='' "
		cQry1 += " WHERE ZZK.D_E_L_E_T_ ='' " 
		cQry1 += " AND ZZK_CODIGO IN "+cPallets "
		cQry1 += " AND ZZJ_FLAG IN('1','2','3','4') "
		cQry1 += " AND ZZJ_FILIAL = '010101' " // Jose 14/10/2024 '"+xFilial("ZZJ")+"'"

		TCQuery cQry1 ALIAS "TCQ" NEW
		DbSelectArea("TCQ")
		DbGoTop()
		aTrPallet 	:= {} 
	
		If !TCQ->(EOF()) .AND. (TCQ->TOTALITEM > nQtdeItens)
			Messagebox("Pallet -->"+(_cPallet)+" não será incluído pois ultrapassa "+alltrim(str(nQtdeItens))+" itens na nota de transferência !!","Atenção...",48)

			DbSelectArea("TMPTRANS")
	    	DbSetOrder(1)
	    	DbSeek(_cPallet, .t.)   
			If Found()
				RecLock("TMPTRANS", .F.)
					DbDelete()
				MsUnlock()		
				nCount   := (nCount -1)
				oSay7Env:Refresh()
				nPeso    := (nPeso - round(fPesPalem(_cPallet),2))   // jose 26/03/2025 u_fPesPalem
				nPesoTot := Transform(nPeso, "@E 999,999.99")
				oSay9Env:Refresh()
	    	Endif	
		Endif
*/

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
			nPeso    := (nPeso - round(fPesPalem(_cPallet),2)) // jose 26/03/2025 u_fPesPalem
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


Static Function fNumNfm(Pedido)

	Local cNumNf := ""
	Local cQry1  :=""    

	cQry1 := " "
	cQry1 += " SELECT F2_DOC AS NUMNF "	
	cQry1 += " FROM "+RetSqlName("SF2")+" 
	cQry1 += " WHERE D_E_L_E_T_ ='' " 
	cQry1 += " AND F2_FILIAL = '010101' " // Jose 14/10/2024 '"+xFilial("SF2")+"'"
	cQry1 += " AND F2_PEDIDO ='"+Pedido+"'"
    TCQuery cQry1 ALIAS "TCQ" NEW
	
	If !Eof()
		cNumNf := TCQ->NUMNF
	Endif		
    
    DbSelectArea("TCQ")
    DbCloseArea()
    
Return(cNumNf)   

Static Function fTotUnim(cPallet,nOpc)

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
	cQry1 += " AND ZZK_FILIAL = '010101' "  // Jose 14/10/2024 '"+xFilial("ZZK")+"'"
	cQry1 += " AND ZZK_CODIGO ='"+cPallet+"'"
    TCQuery cQry1 ALIAS "TCQ" NEW
	
	If !Eof()
		nTotal := TCQ->ZZK_QUANT
	Endif		
    
    DbSelectArea("TCQ")
    DbCloseArea()
    
Return(nTotal)   

/*ÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fPesPalem() - Calcula o peso do Pallet
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fPesPalem(cPallet)

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
	cQry1 += " AND ZZK_FILIAL = '010101' " // Jose 14/102024 '"+xFilial("ZZK")+"'"
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
PRIVATE nomeprog:= "BRFATX70" //"BRFATX67"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRFATX67"

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

wnrel:= "BRFATX70"    //" "BRFATX67"            //Nome Default do relatorio em Disco
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
PRIVATE nomeprog:= "BRFATX70" //"BRFATX67"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRFATX67"

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

wnrel:= "BRFATX70" // "BRFATX67"            //Nome Default do relatorio em Disco
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

	If !Eof() .and. cFlag = 1
		@ _nLin++
	EndIf 

    DbSelectArea("TCP")
    DbCloseArea()
	//If cGet6Env = '000521'
	   _zLocal = '03'
	//Else
	//   _zLocal = '30'
	//EndIf
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
    cQry11 += "   	   SC54.C5_NOTA AS NOTA4, "
    cQry11 += "   	   SC55.C5_NOTA AS NOTA5, "
    cQry11 += "   	   SC56.C5_NOTA AS NOTA6 "

    cQry11 += "  FROM "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK)  "
    cQry11 += " 	    LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK_FILIAL = ZZJ_FILIAL "
    cQry11 += " 	                                                           AND ZZK_CODIGO = ZZJ_CODIGO "
    cQry11 += " 									                           AND ZZK.D_E_L_E_T_ = '' "
    cQry11 += " 	    LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON B2_FILIAL = ZZK_FILIAL "
    cQry11 += " 	                                                           AND B2_COD = ZZK_PRODUT "
    cQry11 += "      							     		                   AND B2_LOCAL = '"+_zLocal+"'
    cQry11 += " 										                 	   AND SB2.D_E_L_E_T_ = '' "


    cQry11 += "	        LEFT OUTER JOIN SC5010 SC51 WITH (NOLOCK) ON SC51.C5_FILIAL = ZZK_FILIAL " 	    
    cQry11 += "	                                                 AND SC51.C5_NUM    = SUBSTRING(ZZJ_OBSPED,1,6)     "
    cQry11 += "											         AND SC51.D_E_L_E_T_ = '' "
    cQry11 += "	        LEFT OUTER JOIN SC5010 SC52 WITH (NOLOCK) ON SC52.C5_FILIAL = ZZK_FILIAL " 	    
    cQry11 += "	                                                 AND SC52.C5_NUM    = SUBSTRING(ZZJ_OBSPED,10,6) "    
    cQry11 += "	        								         AND SC52.D_E_L_E_T_ = '' "
    cQry11 += "	        LEFT OUTER JOIN SC5010 SC53 WITH (NOLOCK) ON SC53.C5_FILIAL = ZZK_FILIAL  "	    
    cQry11 += "	                                                 AND SC53.C5_NUM    = SUBSTRING(ZZJ_OBSPED,19,6) "    
    cQry11 += "											         AND SC53.D_E_L_E_T_ = '' "
    cQry11 += "         LEFT OUTER JOIN SC5010 SC54 WITH (NOLOCK) ON SC54.C5_FILIAL = ZZK_FILIAL " 	    
    cQry11 += "	                                                 AND SC54.C5_NUM    = SUBSTRING(ZZJ_OBSPED,28,6) "    
    cQry11 += "											         AND SC54.D_E_L_E_T_ = '' "
    cQry11 += "	        LEFT OUTER JOIN SC5010 SC55 WITH (NOLOCK) ON SC55.C5_FILIAL = ZZK_FILIAL  "	    
    cQry11 += "	                                                 AND SC55.C5_NUM    = SUBSTRING(ZZJ_OBSPED,36,6) "    
    cQry11 += "											         AND SC55.D_E_L_E_T_ = '' "
    cQry11 += "         LEFT OUTER JOIN SC5010 SC56 WITH (NOLOCK) ON SC56.C5_FILIAL = ZZK_FILIAL " 	    
    cQry11 += "	                                                 AND SC56.C5_NUM    = SUBSTRING(ZZJ_OBSPED,44,6) "    
    cQry11 += "											         AND SC56.D_E_L_E_T_ = '' "

    cQry11 += " WHERE ZZJ_FILIAL = '010101' " //'"+xFilial("ZZJ")+"' "
    cQry11 += "   AND ZZJ.D_E_L_E_T_ = '' "
    cQry11 += "   AND ZZJ_CARGA      = '"+cGet1Env+"' " 
    cQry11 += "   AND ZZJ_FLAG IN ('1','2','3','4','5') "
    cQry11 += " GROUP BY ZZJ_CARGA,    ZZJ_CODIGO,   ZZK_PRODUT,   ZZK_QUANT, ZZJ_OBSPED, B2_LOCALIZ, "
    cQry11 += " 	     SC51.C5_NOTA, SC52.C5_NOTA, SC53.C5_NOTA, SC54.C5_NOTA, SC55.C5_NOTA, SC56.C5_NOTA  "
    cQry11 += " ORDER BY ZZJ_CARGA,    ZZJ_CODIGO,   ZZK_PRODUT "

    TCQuery cQry11 ALIAS "TCP" NEW
    DbSelectArea("TCP")
    DbGoTop()
    While (TCP->(!Eof()))
 		  If TCP->ZZJ_CODIGO <> _zCodigo
		     _zCodigo := TCP->ZZJ_CODIGO
        	 _nLin := 04 
	         @_nLin,000 PSAY "DESTINO :-"
			 If cGet6Env = '00354'
			    @_nLin,022 PSAY "BRASILUX"
			 Else
		        @_nLin,022 PSAY ""
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
				_zNota = ''
				If Alltrim(TCP->NOTA1) <> ''
			  	   _zNotas  = Alltrim(TCP->NOTA1)
				   _zNotas += ' / '
				EndIf
				If Alltrim(TCP->NOTA2) <> ''
				   _zNotas += Alltrim(TCP->NOTA2)
			   	   _zNotas += ' / '
				EndIf
				If Alltrim(TCP->NOTA3) <> ''
				   _zNotas += Alltrim(TCP->NOTA3)
				   _zNotas += ' / '
				EndIf
				If Alltrim(TCP->NOTA4) <> ''
				   _zNotas += Alltrim(TCP->NOTA4)
				   _zNotas += ' / '
				Endif
				If Alltrim(TCP->NOTA5) <> ''
				   _zNotas += Alltrim(TCP->NOTA5)
				   _zNotas += ' / '
				EndIf
				If Alltrim(TCP->NOTA6) <> ''
			  	  _zNotas += Alltrim(TCP->NOTA6)
				EndIf

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

 If _nLin > 55
		cFlag := 0
	Else
		cFlag := 1
	EndIf

	DbSelectArea("TMPTRANS")	 
	DbSkip()
  
EndDo        
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

/*ÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄ
Cleber (10/08/2025) -> Função para gerar DANFE. Está sendo chamada a função u_DanfeProc no modo retrato como um 
serviço (oDanfe:lInJob := .t.) para que a impressão seja feita em segundo plano, permitindo que o usuário continue 
utilizando o sistema.
*/
Static Function fGerDanfe(cNotaIni,cNotaFim , cSerie, cPasta, cNomdanf, lServer)

    Local aArea     := GetArea()
    Local cIdent    := ""
    Local cArquivo  := ""
    Local oDanfe    
    //Local lEnd      := .F.
    Local nTamNota  := GetSx3Cache("F2_DOC"  ,"X3_TAMANHO")
    Local nTamSerie := GetSx3Cache("F2_SERIE","X3_TAMANHO")
    Local cPergunt  := "NFSIGW"
    Private PixelX
    Private PixelY
    Private nConsNeg
    Private nConsTex
    Private oRetNF
    Private nColAux

    Default cNotaIni   := ""
    Default cNotaFim   := ""
    Default cSerie  := SuperGetMV("MV_X_SERNF", .T., "1")
    Default cPasta  := "\spool\" //GetTempPath()
    Default cNomdanf:= cNotaIni+"-"+cNotaFim + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-")  
    Default lServer := .T. 

    //Se existir nota
    If ! Empty(cNotaIni) .and. ! Empty(cNotaFim)
        //Pega o IDENT da empresa
        cIdent := RetIdEnti()
         
        //Se o último caracter da pasta não for barra, será barra para integridade
        If SubStr(cPasta, Len(cPasta), 1) != "\"
            cPasta += "\"
        EndIf         
        
        cArquivo:= cNomdanf
                 
        //Define as perguntas da DANFE
        Pergunte(cPergunt,.F.)
        SetMVValue( cPergunt, "MV_PAR01", PadR(cNotaIni ,  nTamNota)) //Nota Inicial       
        SetMVValue( cPergunt, "MV_PAR02", PadR(cNotaFim ,  nTamNota)) //Nota Inicial
        SetMVValue( cPergunt, "MV_PAR03", PadR(cSerie, nTamSerie)) //Série da Nota
        SetMVValue( cPergunt, "MV_PAR04", 2						 ) //NF de Saida
        SetMVValue( cPergunt, "MV_PAR05", 2						 ) //Frente e Verso = Não
        SetMVValue( cPergunt, "MV_PAR06", 2						 ) //DANFE simplificado = Nao            
            
        //Chamo de novo pra carregar na memória
        Pergunte(cPergunt,.F.)
        //Cria a Danfe
        oDanfe := FWMSPrinter():New(cArquivo+".pdf", IMP_PDF, .F., cPasta, .T.,  ,  ,  ,.F.,  ,.F.,.F.)

        oDanfe:cPathPDF := cPasta                
        			         
		//Propriedades da DANFE
		oDanfe:SetResolution(78)
        oDanfe:SetPortrait()
        oDanfe:SetPaperSize(DMPAPER_A4)
        oDanfe:SetMargin(60, 60, 60, 60)

        //Força a impressão em PDF
        oDanfe:nDevice  := 6
        oDanfe:lServer  := lServer
        oDanfe:lViewPDF := .T.        
        oDanfe:lInJob := .t.
        //Variáveis obrigatórias da DANFE (pode colocar outras abaixo)
        PixelX    := oDanfe:nLogPixelX()
        PixelY    := oDanfe:nLogPixelY()
        nConsNeg  := 0.4
        nConsTex  := 0.5
        oRetNF    := Nil
        nColAux   := 0
         
                                                          
            //Chamando a impressão da danfe no RDMAKE        
            u_DanfeProc(@oDanfe, @lEnd, cIdent, Nil, Nil, .F., .F.)    
            oDanfe:Preview()


/*
            //Chamando a impressão da danfe no RDMAKE        
			u_DANFE_P1(cIdEnt,@cVar1,@cVar2,@oDanfe,,.f.)  
			/*oDanfe:lInJob := .f.
            oDanfe:Preview()*/
*/
    EndIf
    FreeObj(oDanfe)
    RestArea(aArea)
Return
