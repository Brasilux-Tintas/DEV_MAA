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
±±³Programa  ³ BRFATX64  ³ Autor ³ André Maester      ³ Data ³ 09/02/2015³ ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem / Desmontagem de Pallets                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³ 17/06/15³ Inclusão do campo ZZJ_LOCPRO que grava o Lo  ³±±
±±³                cal de origem do Pallet (p1 ou p2) dependendo de onde o³±±
±±³				   produto é produzido									  ³±±
±±³              ³  /  /  ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function BRFATX64()

    Private cGet1Env   := Space(11) //"      /    "	// Pallet
    Private cGet2Env   := Space(06)				    // Lote
    Private cGet3Env   := "     .  .   -  "    // Produto
    Private cSay1Env   := Space(01)
    Private cSay2Env   := Space(01)
    Private cSay4Env   := Space(20)
    Private cSay3Env   := Space(30)
    Private cSay5Env   := Space(30)
	
    Private nCapPallet := 0
    Private nCapAntPal := 0
    Private lProdMist  :=.f.
    Private nCBox1Co   := ""
	Private nCBox1Lo   := Space(04)
    Private cCor4EnB   := CLR_BLUE
    Private cCor4EnR   := CLR_RED
    Private cCor4Env   := 0
    Private nQtdeIni   := 0
    Private cPallet    := ""
    Private cMaxSeq    := ""
    Private _CodProd   := ""
    Private _cMaxSeq   := ""
    Private nQtdTotal  := 0
	Private cCodBarra  := ""
    Private _cSeq      := ""
    Private lJaFech    := .f.
    Private lTelaJaFechada := .f.
    Private aDelete    :={} //  aAdd(aDelete, { cGet1Env, cCodBarra } )     
    Private lCheck     :=.F.
    Private oTempTbl1
	Private _ZPPAR0118 := GetMV( "ZP_PAR0118" ) // Libera Bloqueio de Lotes

    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Declaração de Variaveis Private dos Objetos                             ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    SetPrvt("oFontEnv", "oDlg1Env", "oGrp1Env", "oSay1Env", "oSay2Env", "oGet1Env", "oGet2Env", "oBtn1Env", "oBtn2Env")
    SetPrvt("oBtn3Env", "oBtn4Env", "oBtn5Env", "oBtn6Env", "oBrw1Env", "oGrp3Env", "oBtn7Env", "oBtn8Env", "oBtn9Env")
    SetPrvt("oSay4Env", "oBtn6Env", "oSay3Env", "oSay5Env", "oCBox1"  , "oBtnAEnv", "oSay2Loc", "oCBox1Co")

    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Definicao do Dialog e todos os seus componentes.                        ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    oFontEnv   := TFont():New( "MS Sans Serif", 0, -18, , .F., 0, , 400, .F., .F., , , , , , )
    oFon2Env   := TFont():New( "Courier New"  , 0,  19, , .T., 0, , 400, .F., .F., , , , , , )
    oDlg1Env   := MSDialog():New( 140, 264, 680, 980, "Monta / Desmonta / Transfere Pallet", , , .F., , , , , , .T., , , .T. )
    oGrp1Env   := TGroup():New( 003, 004, 048, 356, "Dados do Pallet", oDlg1Env, CLR_RED, CLR_WHITE, .T., .F. )
    oSay1Env   := TSay():New( 012, 008, { || "Pallet:"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
    oGet1Env   := TGet():New( 010, 064, { |u| If(PCount() > 0, cGet1Env := u, cGet1Env)}, oGrp1Env, 080, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGet1Env", , ) 
    oGet1Env:bLostFocus := {|| Iif(!Empty(Alltrim(cGet1Env)),fCarPall(cGet1Env),"")}
	oCBox1     := TCheckBox():New( 012,150,"Informa QTDE",{|u| If(PCount() > 0, lCheck := u, lCheck)},oGrp1Env,080,012,,,oFontEnv,,CLR_BLUE ,CLR_WHITE,,.t.,"Habilita / Desabilita Digitação da Quantidade",, )	

    oBtn3Env   := TButton():New( 028, 008, "Novo Pallet", oGrp1Env, {|| fNPal()}, 052, 016, , oFontEnv, , .T., , "", , , , .F. )
    oSay4Env   := TSay():New( 030, 152, { || cSay4Env  }, oGrp1Env, , oFontEnv, .F., .F., .F., .T., cCor4Env, CLR_WHITE, 106, 012)
    oBtn1Env   := TButton():New( 009, 297, "Confirma", oGrp1Env, {|| fSMntPal()}, 052, 016, , oFontEnv, , .T., , "", , , , .F. )
    oBtnAEnv   := TButton():New( 009, 240, "T. Rampa", oGrp1Env, {|| fTrLRampa()},045, 016, , oFontEnv, , .T., , "", , , , .F. )
    oBtn2Env   := TButton():New( 030, 297, "Abandona", oGrp1Env, {|| fSairMPa()}, 052, 016, , oFontEnv, , .T., , "", , , , .F. )
    oGrp2Env   := TGroup():New( 050, 004, 268, 356, "", oDlg1Env, CLR_BLACK, CLR_WHITE, .T., .F. )

    oCBox1Lo   := TComboBox():New( 058, 290, {|u| If(PCount() > 0, nCBox1Lo := u, nCBox1Lo)}, {"", "FAB1", "FAB2","DEPO","ARA"}, 060, 016, oGrp2Env, , , , CLR_BLACK, CLR_WHITE, .T., oFon2Env, "", , , , ,  , , nCBox1Lo )
	oSay2Loc   := TSay():New( 078, 290, { || "Localização"}, oGrp2Env, , oFon2Env, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012)
	oCBox1Lo:Refresh()

    oBtn4Env   := TButton():New( 088, 290, "<- Monta     " , oGrp2Env, {|| fMntPallet(1) }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )
    oBtn5Env   := TButton():New( 108, 290, "<- Desmonta  " , oGrp2Env, {|| fMntPallet(2) }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )

	oSay2Env   := TSay():New( 168, 290, { || "Impressora"}, oGrp2Env, , oFon2Env, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012)
    oCBox1Co   := TComboBox():New( 150, 290, {|u| If(PCount() > 0, nCBox1Co := u, nCBox1Co)}, {"", "ZEBRA S4M", "ZEBRA ZT230"}, 060, 016, oGrp2Env, , , , CLR_BLACK, CLR_WHITE, .T., oFon2Env, "", , , , ,  , , nCBox1Co )
    oBtn6Env   := TButton():New( 178, 290, "<- Imp.Etq ->" , oGrp2Env, {|| fIEtPallet(nCBox1Co) }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )
    oBtn7Env 	:= TButton():New( 198, 290, "<- Res. Pro->" , oGrp2Env, {|| U_fResPallet(1) }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )
    oBtn9Env 	:= TButton():New( 218, 290, "<- Res. Emb->" , oGrp2Env, {|| U_fResPallet(2) }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )
    oBtn8Env 	:= TButton():New( 238, 290, "<-Transfere->" , oGrp2Env, {|| fTrLocais( )  }, 060, 016, , oFon2Env, , .T., , "", , , , .F. )     
    oSay3Env   := TSay():New( 038, 076, { || cSay3Env  },   oGrp1Env, , oFon2Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 240, 012)
	oSay5Env   := TSay():New( 028, 076, { || cSay5Env  },   oGrp1Env, , oFon2Env, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)

    oTblIPall()
    DbSelectArea("TMPITE")
    DbSetOrder(1)
    DbGoTop()
    oBrw1Env   := MsSelect():New( "TMPITE", "", "", { {"TMPPRO", "", "Codigo", "@R XX 99.99.999-99"}, {"TMPSEQ", "", "Sequ.", "@!"}, { "TMPQTD", "", "Quantidade", "@E 999,999"}, {"TMPLOT", "", "Lote   ", "@E 999999"} }, .F., , {056, 007, 266, 280}, , , oGrp2Env ) 

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


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fResPallet() - Ver o Resumo dos Produtos que fazem parte do Pallet .
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
User Function fResPallet(nOpc)
	Local nY
	Local aResPal := {}
 	Local cMsgRes := ""
	//Local cCodPro := ""
	Local nQtdVol := 0
	Local nTQtd   := 0
	Local nTVol   := 0
	
    If nOpc == 1

		cQry1 := " "
		cQry1 += " WITH TMP AS (SELECT ZZK_CODIGO, ZZK_PRODUT, B1_DESC, ZZK_QUANT,  CASE WHEN LEN(ZZK_CODBAR)=14 THEN SUBSTRING(ZZK_CODBAR,9,2) ELSE '0'+dbo.DetVol(ZZK_FILIAL,ZZK_PRODUT) END AS 'QTDVOL'   "		
		cQry1 += " FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (B1_FILIAL = ZZK_FILIAL) AND ZZK_PRODUT = B1_COD AND SB1.D_E_L_E_T_ ='' "
		cQry1 += " WHERE (ZZK.D_E_L_E_T_ ='') AND (ZZK_FILIAL = '"+xFilial("ZZK")+"') " 
		cQry1 += " AND (ZZK_CODIGO ='"+Alltrim(cGet1Env)+"') )"
		cQry1 += " SELECT TMP.ZZK_CODIGO, TMP.ZZK_PRODUT, TMP.B1_DESC, SUM(TMP.ZZK_QUANT) AS ZZK_QUANT,(SUM(TMP.ZZK_QUANT)/TMP.QTDVOL) AS QTDVOL "  
		cQry1 += " FROM TMP "
		cQry1 += " GROUP BY TMP.ZZK_CODIGO ,TMP.ZZK_PRODUT, TMP.B1_DESC, TMP.QTDVOL, ZZK_QUANT "   
		cQry1 += " ORDER BY ZZK_PRODUT "
	Elseif nOpc ==2
		cQry1 := " "
		/*
		cQry1 += " SELECT ZZK_CODIGO, '     '+SUBSTRING(ZZK_PRODUT,11,2)+'     ' AS EMB, Z5_DESCR, SUM(ZZK_QUANT) AS ZZK_QUANT, SUBSTRING(ZZK_CODBAR,9,2) AS 'QTDVOL' "
		cQry1 += " FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (B1_FILIAL = ZZK_FILIAL) AND (ZZK_PRODUT = B1_COD) AND SB1.D_E_L_E_T_ ='' "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON (Z5_FILIAL = '"+xFilial("SZ5")+"') AND (Z5_EMB = SUBSTRING(ZZK_PRODUT,11,2)) AND SZ5.D_E_L_E_T_ ='' "
		cQry1 += " WHERE (ZZK.D_E_L_E_T_ ='') AND (ZZK_FILIAL = '"+xFilial("ZZK")+"') " 
		cQry1 += " AND (ZZK_CODIGO ='"+Alltrim(cGet1Env)+"')"
		cQry1 += " GROUP BY ZZK_CODIGO, SUBSTRING(ZZK_PRODUT,11,2), Z5_DESCR ,SUBSTRING(ZZK_CODBAR,9,2) "  
		cQry1 += " ORDER BY SUBSTRING(ZZK_PRODUT,11,2),SUBSTRING(ZZK_CODBAR,9,2) " */
		
		cQry1 += " WITH TMP AS (SELECT ZZK_CODIGO, '     '+SUBSTRING(ZZK_PRODUT,11,2)+'     ' AS EMB, Z5_DESCR, ZZK_QUANT, "
		cQry1 += " CASE WHEN LEN(ZZK_CODBAR)=14 THEN SUBSTRING(ZZK_CODBAR,9,2) ELSE '0'+dbo.DetVol(ZZK_FILIAL,ZZK_PRODUT) END AS 'QTDVOL' "
		cQry1 += " FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (B1_FILIAL = ZZK_FILIAL) AND (ZZK_PRODUT = B1_COD) AND SB1.D_E_L_E_T_ ='' "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON (Z5_FILIAL = '"+xFilial("SZ5")+"') AND (Z5_EMB = SUBSTRING(ZZK_PRODUT,11,2)) AND SZ5.D_E_L_E_T_ ='' "
		cQry1 += " WHERE (ZZK.D_E_L_E_T_ ='') AND (ZZK_FILIAL = '"+xFilial("ZZK")+"') " 
		cQry1 += " AND (ZZK_CODIGO ='"+Alltrim(cGet1Env)+"') )"
		cQry1 += " SELECT TMP.ZZK_CODIGO, TMP.EMB, TMP.Z5_DESCR, SUM(TMP.ZZK_QUANT) AS ZZK_QUANT, TMP.QTDVOL"//, (SUM(TMP.ZZK_QUANT) / TMP.QTDVOL) AS 'VOL' "
		cQry1 += " FROM TMP GROUP BY TMP.ZZK_CODIGO, TMP.EMB, TMP.Z5_DESCR, TMP.QTDVOL "
		cQry1 += " ORDER BY TMP.EMB "

	Elseif nOpc ==3
		cQry1 := " "
		cQry1 += " WITH TMP AS (SELECT ZZK_CODIGO, ZZK_QUANT,CASE WHEN LEN(ZZK_CODBAR)=14 THEN SUBSTRING(ZZK_CODBAR,9,2) ELSE '0'+dbo.DetVol(ZZK_FILIAL,ZZK_PRODUT) END AS 'QTDVOL' ,'GRPEMB' =ISNULL((SELECT TOP 1 B1_GRUPO2 FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (G1_FILIAL = SB1.B1_FILIAL) AND (G1_COMP = SB1.B1_COD) " 
		cQry1 += " WHERE (SG1.D_E_L_E_T_ = '') AND (G1_FILIAL = ZZK_FILIAL) AND (G1_COD = ZZK_PRODUT) AND (SB1.B1_GRUPO LIKE 'E%') AND (SB1.B1_GRUPO2 > '')),'99') "
		cQry1 += " FROM "+RetSqlName("ZZK")+" ZZK  WITH (NOLOCK) "
		cQry1 += " WHERE (ZZK.D_E_L_E_T_ ='') AND (ZZK_FILIAL = '"+xFilial("ZZK")+"') "
		cQry1 += " AND (ZZK_CODIGO ='"+Alltrim(cGet1Env)+"')) "
		cQry1 += " SELECT ZZK_CODIGO, ISNULL(X5_CHAVE,'XX') AS X5_CHAVE, ISNULL(X5_DESCRI,'SEM CLASSFI') AS X5_DESCRI, SUM(ZZK_QUANT) AS ZZK_QUANT, (SUM(TMP.ZZK_QUANT)/TMP.QTDVOL) AS QTDVOL "
		cQry1 += " FROM TMP "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) ON (SX5.D_E_L_E_T_ = '') AND (X5_FILIAL = X5_FILIAL) "
		cQry1 += " AND (X5_CHAVE = GRPEMB) AND SX5.D_E_L_E_T_ ='' AND X5_TABELA ='03' "
		cQry1 += " GROUP BY ZZK_CODIGO,X5_CHAVE, X5_DESCRI, QTDVOL "
		cQry1 += " ORDER BY X5_DESCRI "	
	Endif 
	TCQuery cQry1 ALIAS "TCQ" NEW
 	DbSelectArea("TCQ")
  	DbGoTop()
	If !Eof()
	   	While !Eof()
    		If nOpc = 1
	    		aAdd(aResPal, {TCQ->ZZK_PRODUT ,TCQ->B1_DESC ,TCQ->ZZK_QUANT, (TCQ->QTDVOL)})
				nTQtd += TCQ->ZZK_QUANT 
			    nTVol += TCQ->QTDVOL
			Elseif nOpc = 2
				aAdd(aResPal, {TCQ->EMB ,TCQ->Z5_DESCR ,TCQ->ZZK_QUANT, VAL(TCQ->QTDVOL)})			
			    //nTVol += VAL(TCQ->QTDVOL)
			Elseif nOpc = 3
				//LGS#20200210 - Adequação de release 12.1.25 e posteriores
				aAdd(aResPal, {TCQ->X5_CHAVE ,TCQ->X5_DESCRI ,TCQ->ZZK_QUANT, TCQ->QTDVOL})
				nTQtd += TCQ->ZZK_QUANT 
			    nTVol += TCQ->QTDVOL
			Endif
	     	DbSelectArea("TCQ")
    	  	DbSkip()
	    Enddo
    Else
  		Messagebox("Salve o Pallet antes de consultar o resumo!! ","Atenção...",48)    	
    Endif
    DbSelectArea("TCQ")
    DbCloseArea()

	If Len(aResPal) > 0
 		cMsgRes += '    RESUMO DA MONTAGEM DO PALLET '+Alltrim(cGet1Env)+'   '+Chr(13)+Chr(10)
     	If nOpc == 1
   			cMsgRes += '+--------------+-----------------------+------+------+'+Chr(13)+Chr(10)
	     	cMsgRes += '|  PRODUTO     |   DESCRIÇÃO           | QTDE | VOL  |'+Chr(13)+Chr(10)
	      	cMsgRes += '+--------------+-----------------------+------+------+'+Chr(13)+Chr(10)
        Elseif nOpc == 2
	   		cMsgRes += '+--------------+--------------------------+----------+'+Chr(13)+Chr(10)
			cMsgRes += '|  EMBALAGEM   |   DESCRIÇÃO              | VOLUMES  |'+Chr(13)+Chr(10)        
          	cMsgRes += '+--------------+--------------------------+----------+'+Chr(13)+Chr(10)
        Elseif nOpc == 3
	   		cMsgRes += '+-----------+--------------------------+------+------+'+Chr(13)+Chr(10)
			cMsgRes += '|  GRUPO    |   DESCRIÇÃO              | QTDE | VOL  |'+Chr(13)+Chr(10)                
	      	cMsgRes += '+-----------+--------------------------+------+------+'+Chr(13)+Chr(10)
        Endif
       	
       	For nY := 1 To Len(aResPal)
    	    If nOpc == 1 
    	    	cMsgRes += '| '+Substr(aResPal[nY][1],1,12)+' | '+Substr(aResPal[nY][2],1,21)+' |'+Transform(aResPal[nY][3], "@E 99999")+' | '+Transform(aResPal[nY][4], "@E 9999")+' |'+Chr(13)+Chr(10)
		       	cMsgRes += '+--------------+-----------------------+------+------+'+Chr(13)+Chr(10)
	       		//cMsgRes += '|                        TOTAIS        |'+Transform(nTQtd, "@E 99999")+' | '+Transform(nTVol, "@E 9999")+' |'+Chr(13)+Chr(10)
	       	   	//cMsgRes += '+--------------------------------------+------+------+'+Chr(13)+Chr(10)

	       	Elseif nOpc == 2
    	    	If (aResPal[nY][4]) > 0
    	    		nQtdVol := (aResPal[nY][3] / aResPal[nY][4])   
    	    		nTVol   += nQtdVol
				Endif
    	    	cMsgRes += '| '+Substr(aResPal[nY][1],1,12)+' | '+Substr(aResPal[nY][2],1,24)+' | '+Iif(aResPal[nY][4]<=0,'  ---  ',Transform(nQtdVol, "@E 9999999"))+'  |'+Chr(13)+Chr(10)
    	       	cMsgRes += '+--------------+--------------------------+----------+'+Chr(13)+Chr(10)
	       		//cMsgRes += '|                        TOTAL            |  '+Transform(nTQtd, "@E 99999")+' |'+Chr(13)+Chr(10)
	       	   	//cMsgRes += '+-----------------------------------------+----------+'+Chr(13)+Chr(10)

    	    Elseif nOpc == 3 
    	    	cMsgRes += '|    '+Substr(aResPal[nY][1],1,3)+Space(3)+' | '+Substr(aResPal[nY][2],1,24)+' |'+Transform(aResPal[nY][3], "@E 99999")+' | '+Transform(aResPal[nY][4], "@E 9999")+' |'+Chr(13)+Chr(10)
		       	cMsgRes += '+-----------+--------------------------+------+------+'+Chr(13)+Chr(10)
	       		//cMsgRes += '|                        TOTAIS        |'+Transform(nTQtd, "@E 99999")+' | '+Transform(nTVol, "@E 9999")+' |'+Chr(13)+Chr(10)
	       	   	//cMsgRes += '+--------------------------------------+------+------+'+Chr(13)+Chr(10)
	       	
	       	Endif
	       
        Next
        If nOpc == 2
  			cMsgRes += '|                        TOTAL            |  '+Transform(nTVol, "@E 99999")+'   |'+Chr(13)+Chr(10)
   	   		cMsgRes += '+-----------------------------------------+----------+'+Chr(13)+Chr(10)
        Else
			cMsgRes += '|                        TOTAIS        |'+Transform(nTQtd, "@E 99999")+' | '+Transform(nTVol, "@E 9999")+' |'+Chr(13)+Chr(10)
	       	cMsgRes += '+--------------------------------------+------+------+'+Chr(13)+Chr(10)
        Endif 	
    Endif
    
    If !Empty(cMsgRes)
    	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     	±± Declaração de cVariable dos componentes                                 ±±
      	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
        Private cMGet1Ms

		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
  		±± Declaração de Variaveis Private dos Objetos                             ±±
    	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     	SetPrvt("oFontMsg", "oDlg1Msg", "oMGet1Ms")

		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
  		±± Definicao do Dialog e todos os seus componentes.                        ±±
    	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     	cMGet1Ms   := cMsgRes
      	oFontMsg   := TFont():New( "Courier New", 0, -13, , .F., 0, , 400, .F., .F., , , , , , )
       	oDlg1Msg   := MSDialog():New( 229, 262, 600, 730, "Resumo do Pallet", , , .F., , , , , , .T., , , .T. )
        oMGet1Ms   := TMultiGet():New( 003, 003, {|u| If(PCount() > 0, cMGet1Ms := u, cMGet1Ms)}, oDlg1Msg, 235,180, oFontMsg, , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .F., , , .F., , )
		oDlg1Msg:Activate(, , , .T.)
        
		If ChkFile("TMPITE")
	 		DbSelectArea("TMPITE")
			DbSetOrder(1)
			DbGoTop()

		    oBrw1Env:oBrowse:GoTop()
		    oBrw1Env:oBrowse:Refresh()
        Endif	    
  	Endif
Return()

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fTrPallet() Transferir Pallet de um Armazem para Outro (Após Montagem do Pallet)
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fTrPallet(cGet1Env, cLocOri, cLocDest) //Pallet, Armazem de Origem, Armazem de Destino

Local aAuto 	:= {}
Local aItem		:= {}
Local aTrPallet := {}  
Local cNumDoc 	:= NextNumero("SD3",2,"D3_DOC",.T.)
//Local _texto 	:= "" 
Local cQry1     := ""
Local cMenssag  := ""
//Local lOk		:= .T.
Local lTemQtde  := .T.
Local nI 		:= 0
Local nSaldo    := 0
Local nOpcAuto	:= 3 	// Indica qual tipo de ação será tomada (Inclusão/Exclusão)
Local cLote	 	:= ""	// Lote
Local cProduto 			// Cod Produto
Local cDescProd 		// Descrição do produto
Local cUM 				// Unidade de medida
Local nQuant 			// Quantidade
 

cLocOri := Upper(cLocOri)

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.
	
	If Empty(Alltrim(cGet1Env))
		Messagebox("Não é possível transferir o Pallet, pois seu código esta em Branco !!","Atenção...",48)    	
		Return
	Endif
	If Upper(Alltrim(cLocOri)) == Upper(Alltrim(cLocDest))
		Messagebox("Não é possível transferir o Pallet com o Local de Origem igual ao Local de Destino !!","Atenção...",48)    	
	 	Return
	Endif
	If Empty(Alltrim(cLocOri)) .or. Empty(Alltrim(cLocDest))
		Messagebox("Não é possível transferir o Pallet sem informar o Local de Origem e Local de Destino !!","Atenção...",48)    	
	 	Return
	Endif
	If Empty(Alltrim(Posicione("SX5", 1, xFilial("SX5")+'99'+Alltrim(cLocOri), "X5_DESCRI"))) 
		Messagebox("Verifique o almoxarifado digitado, pois ainda não existe este almoxarifado "+cLocOri+" no cadastro !!","Atenção...",48)    	
	 	Return
	Endif
	If Empty(Alltrim(Posicione("SX5", 1, xFilial("SX5")+'99'+Alltrim(cLocDest), "X5_DESCRI")))
		Messagebox("Verifique o almoxarifado digitado, pois ainda não existe este almoxarifado "+cLocDest+" no cadastro !!","Atenção...",48)    	
	 	Return
	Endif
	If !Alltrim(cLocOri) $ '03.12.13.30.90.G3.P1.P2.D1' .or. !Alltrim(cLocDest) $ '03.12.13.30.90.G3'
		Messagebox("Veririque os almoxarifados digitados pois ORIGEM ou DESTINO não são almoxarifados de PA !!","Atenção...",48)    		
		Return
	Endif

	cQry1 := " "
	cQry1 += " SELECT ZZK_CODIGO, ZZK_PRODUT, B1_DESC, SUM(ZZK_QUANT) AS ZZK_QUANT, B1_UM "
	cQry1 += " FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (B1_FILIAL = ZZK_FILIAL) AND (ZZK_PRODUT = B1_COD) AND SB1.D_E_L_E_T_ ='' "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) ON (ZZJ_FILIAL = ZZK_FILIAL) AND (ZZJ_CODIGO = ZZK_CODIGO) AND ZZJ.D_E_L_E_T_ ='' "
	cQry1 += " WHERE (ZZK.D_E_L_E_T_ ='') AND (ZZK_FILIAL = '"+xFilial("ZZK")+"') " 
	cQry1 += " AND ZZK_CODIGO ='"+Alltrim(cGet1Env)+"'"
	cQry1 += " AND ZZJ_FLAG ='1' "
	cQry1 += " GROUP BY ZZK_CODIGO, ZZK_PRODUT, B1_DESC, B1_UM "  
	cQry1 += " ORDER BY ZZK_CODIGO "

	TCQuery cQry1 ALIAS "TCQ" NEW
 	DbSelectArea("TCQ")
  	DbGoTop()
	If !(TCQ->(EOF()))  
	   	While !(TCQ->(EOF()))  
		   	DbSelectArea("SB2")
 			DbSetorder(1)
 			DbSeek(xFilial("SB2")+(TCQ->ZZK_PRODUT)+(cLocOri))
	 		nSaldo := SaldoSb2()
    
    		aAdd(aTrPallet, {Alltrim(cGet1Env), TCQ->ZZK_PRODUT ,TCQ->ZZK_QUANT, TCQ->B1_DESC, TCQ->B1_UM, IIF((TCQ->ZZK_QUANT > nSaldo),1,0),nSaldo})
	     	DbSelectArea("TCQ")
    	  	DbSkip()
	    Enddo
    Else
		Messagebox("Não encontrado produtos salvos com o código deste Pallet, salve-o primeiro ou verifique o código do Pallet !!","Atenção...",48)    	
	 	DbSelectArea("TCQ")
		DbCloseArea()
	 	Return
    Endif
 	DbSelectArea("TCQ")
	DbCloseArea()
    
    cMenssag  := "Atenção, não existe(m) saldo suficiente para os produto(s) abaixo :"+Chr(13)+Chr(10)+Chr(13)+Chr(10)
	For nI:= 1 To Len(aTrPallet)     
      	If aTrPallet[nI][6] == 1
      		lTemQtde := .F.
      		cMenssag += aTrPallet[nI][2]+"  / Qtd Pallet -> "+Alltrim(Str(aTrPallet[nI][3]))+"  / Qtd Disponível -> "+Alltrim(Str(aTrPallet[nI][7]))+Chr(13)+Chr(10)      	
      	Endif
	Next nI
    
	If lTemQtde	
   	   //PutMv("MV_ESTNEG" , "S")    
   	   PutMv("MV_ESTNEG" , "N")    
		Begin Transaction
			For nI:= 1 To Len(aTrPallet)     
				//DbSelectArea("SB1")
				//DbSetOrder(1)
				//DbGotop()
				//SB1->(DBSEEK(xFilial("SB1")+aTrPallet[nI][2] ))
				cObs        := Alltrim(aTrPallet[nI][1])
				cProduto 	:= aTrPallet[nI][2]
				nQuant 		:= aTrPallet[nI][3]
				cDescProd 	:= aTrPallet[nI][4]
				cUm 		:= aTrPallet[nI][5]
			
				aAuto := {}
				aItem := {}
				aadd(aAuto,{cNumDoc,dDataBase})  	
				aadd(aItem,	cProduto) 		 		//D3_COD		
				aadd(aItem,	cDescProd)     			//D3_DESCRI				
				aadd(aItem,	cUm)  		 			//D3_UM		
				aadd(aItem,	cLocOri)      			//D3_LOCAL		
				aadd(aItem,	"")			   			//D3_LOCALIZ		
				aadd(aItem,	cProduto) 				//D3_COD		
				aadd(aItem,	cDescProd)     			//D3_DESCRI				
				aadd(aItem,	cUm)  		  			//D3_UM		
				aadd(aItem,	cLocDest)  		  		//D3_LOCAL		
				aadd(aItem,	"")				   		//D3_LOCALIZ		
				aadd(aItem,	cObs)	  				//D3_NUMSERI		
				aadd(aItem,	cLote)					//D3_LOTECTL  		
				aadd(aItem,	"")         			//D3_NUMLOTE		
				aadd(aItem,	criavar("D3_DTVALID"))  //D3_DTVALID	
				aadd(aItem,	0)						//D3_POTENCI		
				aadd(aItem,	nQuant) 				//D3_QUANT		
		   		aadd(aItem, criavar("D3_QTSEGUM"))	//D3_QTSEGUM
				aadd(aItem, criavar("D3_ESTORNO"))  //D3_ESTORNO
				aadd(aItem, criavar("D3_NUMSEQ"))   //D3_NUMSEQ 
				aadd(aItem, "")						//D3_LOTECTL
				aadd(aItem,	criavar("D3_DTVALID"))  //D3_DTVALID			
				aadd(aItem,	"")						//D3_ITEMGRD
//				aadd(aItem,criavar("D3_IDDCF"))		//D3_IDDCF
				aadd(aItem,criavar("D3_OBSERVA  "))	//D3_OBSERVA  
				
				DbSelectArea("SB2")
				DbSetOrder(1)
				DbGotop()

				If !SB2->(DBSEEK(xFilial("SB2")+cProduto+cLocDest ))
					CriaSB2( cProduto, cLocDest)
				Endif

				//PutMv("MV_ESTNEG" , "N")  

				lMsErroAuto := .f.
				aadd(aAuto,aItem)
				MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)				

				/*If lMsErroAuto			
					//PutMv("MV_ESTNEG" , "N")   
					Messagebox("Tranferência de Pallet não Realizada ","Atenção...",48)    						
	        	    DisarmTransaction() 
					MostraErro()		
					oDlg1Tr:End()
					Return
				EndIf */

			Next nI
		
			If !lMsErroAuto 
			 	DbSelectArea("ZZJ")
				DbSetOrder(1)
				DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
				If Found() 
					Reclock("ZZJ",.f.)
						If Upper(cLocOri) $ 'P1.P2'
						    ZZJ->ZZJ_LOCPRO := cLocOri
						Else
							ZZJ->ZZJ_FLAG 	:= '2'
							ZZJ->ZZJ_DTTRAN := Date()
							ZZJ->ZZJ_HTRAN  := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
							ZZJ->ZZJ_LOCORI := cLocOri
							ZZJ->ZZJ_LOCDES := cLocDest
						Endif
					MsUnlock()
			    Endif
				DbSelectArea("ZZJ")
				DbCloseArea()

				Messagebox("Tranferência de Pallet realizada com sucesso !! ","Atenção...",48)    		
				cSay3Env := "Pallet transferido. Origem: "+cLocOri+" Destino: "+cLocDest
				oDlg1Tr:End()
	    	Else
				PutMv("MV_ESTNEG" , "N")   
				Messagebox("Tranferência de Pallet não Realizada ","Atenção...",48)    						
        	    DisarmTransaction() 
				MostraErro()		
				oDlg1Tr:End()
			Endif
		End Transaction
	
		//PutMv("MV_ESTNEG" , "N")                                                                      
    Else
    	Messagebox(cMenssag,"Saldo Insuficiente...",48)
    	oDlg1Tr:End()
    Endif

	PutMv("MV_ESTNEG" , "N")                                                                      
    
Return 


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fTrLRampa() - Inclusão de Origem e Destino na transferência da Rampa
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fTrLRampa() 

	Private cGet3Tr   := Space(2) 
	Private cGet4Tr   := Space(2) 

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±	
	±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    
	SetPrvt("oFontTr1", "oFontTr2", "oDlg1Tr", "oSay3Tr", "oSay4Tr", "oGet3Tr", "oGet4Tr")
          
    DbSelectArea("ZZJ")
	DbSetOrder(1)
	DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
	If Found()
		If !Empty(ZZJ->ZZJ_LOCPRO)
			Messagebox("Pallet já passou pela Rampa. Local de Produção..: "+ZZJ->ZZJ_LOCPRO,"Atenção...",48) 
    		DbSelectArea("ZZJ")
    		DbClosearea()
        	Return
		Endif
   	Else
		Messagebox("Código de Pallet não encontrado, salve o Pallet antes de transferir ou verifique o código do Pallet digitado !!","Atenção...",48)
   		DbSelectArea("ZZJ")
   		DbClosearea()
       	Return
	Endif
	
    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Definicao do Dialog e todos os seus componentes.                        ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    oFontTr1  := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
    oFontTr2  := TFont():New( "MS Sans Serif", 0, -16, , .F., 0, , 400, .F., .F., , , , , , )
    oDlg1Tr   := MSDialog():New( 258, 232, 383, 570, "Transferência de RAMPA", , , .F., , , , , , .T., , , .T. )
    oSay3Tr   := TSay():New( 005, 010, {|| "Orig.: (P1/P2)"  }, oDlg1Tr, , oFontTr1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012)
    oGet3Tr   := TGet():New( 020, 025, {|u| If(PCount() > 0, cGet3Tr := u, cGet3Tr)}, oDlg1Tr, 024, 012, '@R XX'          , , CLR_BLACK, CLR_WHITE, oFontTr2, , , .T., "", , , .F., .F., , .F. , .F., "99"    ,"cGet3Tr", , )
    oSay4Tr   := TSay():New( 005, 095, {|| "Dest.: (03)"  }, oDlg1Tr, , oFontTr1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012)
    oGet4Tr   := TGet():New( 020, 110, {|u| If(PCount() > 0, cGet4Tr := u, cGet4Tr)}, oDlg1Tr, 024, 012, '@R XX'          , , CLR_BLACK, CLR_WHITE, oFontTr2, , , .T., "", , , .F., .F., , .F. , .F., "99"    ,"cGet4Tr", , )
    oBtn1Tr   := TButton():New( 042, 120, "Transfere", oDlg1Tr, {|| fTrPallet(cGet1Env, cGet3Tr,cGet4Tr)}  , 045, 018, , oFontTr2, , .T., , "", , , , .F. )
    oGet3Tr:bValid     := {|| Iif(Upper(Alltrim(cGet3Tr)) $ 'P1.P2', Upper(Alltrim(cGet3Tr)), oGet3Tr:Setfocus() ) }
    //oGet3Tr:bLostFocus := {|| cGet4Tr:= Iif(Upper(Alltrim(cGet3Tr)) $ 'P2', '30' ,Iif(Upper(Alltrim(cGet3Tr)) $ 'P1', '03',oGet3Tr:Setfocus())) }
	oGet3Tr:bLostFocus := {|| cGet4Tr:= Iif(Upper(Alltrim(cGet3Tr)) $ 'P1.P2', '03',oGet3Tr:Setfocus()) }
   
    oDlg1Tr:Activate( , , , .T.)

Return



/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fTrLocais() - Inclusão do Local de Origem e Destino do Pallet
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fTrLocais() 
	
	Private L241

	Private cGet1Tr   := Space(2) 
	Private cGet2Tr   := Space(2) 

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±	
	±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    
	SetPrvt("oFontTr1", "oFontTr2", "oDlg1Tr", "oSay1Tr", "oSay2Tr", "oGet1Tr", "oGet2Tr")
          
    DbSelectArea("ZZJ")
	DbSetOrder(1)
	DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
	If Found()
		If ZZJ->ZZJ_FLAG == "2"
			Messagebox("Pallet já transferido. Origem..: "+ZZJ->ZZJ_LOCORI+" Destino..: "+ZZJ->ZZJ_LOCDES,"Atenção...",48) 
    		DbSelectArea("ZZJ")
    		DbClosearea()
        	Return
	  	Else
		  	//cGet1Tr := Iif(Alltrim(ZZJ->ZZJ_LOCPRO) $ 'P2', '30' ,Iif(Alltrim(ZZJ->ZZJ_LOCPRO) $ 'P1', '03',Space(2)))
			cGet1Tr := Iif(Alltrim(ZZJ->ZZJ_LOCPRO) $ 'P1.P2', '03',Space(2))
		Endif
   	Else
		Messagebox("Código de Pallet não encontrado, salve o Pallet antes de transferir ou verifique o código do Pallet digitado !!","Atenção...",48)
   		DbSelectArea("ZZJ")
   		DbClosearea()
       	Return
	Endif
	
    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Definicao do Dialog e todos os seus componentes.                        ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    oFontTr1  := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
    oFontTr2  := TFont():New( "MS Sans Serif", 0, -16, , .F., 0, , 400, .F., .F., , , , , , )
    oDlg1Tr   := MSDialog():New( 258, 232, 383, 570, "Transferência de Pallet", , , .F., , , , , , .T., , , .T. )
    oSay1Tr   := TSay():New( 016, 015, {|| "Origem.:"      }, oDlg1Tr, , oFontTr1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 012)
    oGet1Tr   := TGet():New( 013, 050, {|u| If(PCount() > 0, cGet1Tr := u, cGet1Tr)}, oDlg1Tr, 024, 012, '@R 99'          , , CLR_BLACK, CLR_WHITE, oFontTr2, , , .T., "", , , .F., .F., , .F. , .F., "99"    ,"cGet1Tr", , )
    oSay2Tr   := TSay():New( 016, 080, {|| "Destino:"     }, oDlg1Tr, , oFontTr1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 012)
    oGet2Tr   := TGet():New( 013, 120, {|u| If(PCount() > 0, cGet2Tr := u, cGet2Tr)}, oDlg1Tr, 024, 012, '@R 99'          , , CLR_BLACK, CLR_WHITE, oFontTr2, , , .T., "", , , .F., .F., , .F. , .F., "99"    ,"cGet2Tr", , )
    oBtn1Tr   := TButton():New( 040, 120, "Transfere", oDlg1Tr, {|| fTrPallet(cGet1Env, cGet1Tr,cGet2Tr)}  , 045, 018, , oFontTr2, , .T., , "", , , , .F. )
    //oGet1Tr:bValid := {|| A240Local() }
    //oGet2Tr:bValid := {|| A240Local() }
   
    oDlg1Tr:Activate( , , , .T.)

    Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fSMntPal()  Salvar Dados das Tabelas Temporárias - Botão Confirmar Tela Principal
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fSMntPal()
    Local nY
	
	If Empty(Alltrim(cGet1Env))
		Return
	Endif

    DbSelectArea("ZZJ")
	DbSetOrder(1)
	DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
	If Found()
		If ZZJ->ZZJ_FLAG == "2"
			Messagebox("Não é possível alterar este Pallet, Pallet já foi transferido !","Atenção...",48) 
			DbSelectArea("ZZJ")
			DbClosearea()
			Return
		Endif
	Endif

	Begin Transaction
        If cGet1Env $ "NOVO PALLET"
        	FGrvNPal() // Gravar ZZJ o Número do Pallet
        Endif
		DbSelectArea("ZZJ")
		DbSetOrder(1)
		DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
		If Found()
		If !ZZJ->ZZJ_FLAG $ '2'
				RecLock("ZZJ", .f.)
					ZZJ->ZZJ_DTFIM := Date()
					ZZJ->ZZJ_HFIM  := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
				MsUnLock()
			Endif
		Endif
        For nY :=1 to Len(aDelete)
			If !lCheck
				DbSelectArea("ZZK")
				DbSetOrder(5)
				DbGoTop()            		
				DbSeek(xFilial("ZZK")+aDelete[nY][2], .t.)   
				If Found() 
					If (aDelete[nY][1]) == Alltrim(cGet1Env)
						RecLock("ZZK", .F.)
							DbDelete()
						MsUnlock()		
					Endif
				Endif	
			Else
				DbSelectArea("ZZK")
				DbSetOrder(2)
				DbGoTop()            		
				DbSeek(xFilial("ZZK")+aDelete[nY][1]+aDelete[nY][2]+aDelete[nY][2], .t.)   
				If Found() 
					RecLock("ZZK", .F.)
						DbDelete()
					MsUnlock()		
				Endif	
			Endif
        Next
		DbSelectArea("TMPITE")
		DbSetOrder(1)
		DbGoTop()    
		If !Eof()
			While !Eof() .And. ((Alltrim(cGet1Env) == Alltrim(TMPITE->TMPPAL)) .OR. (TMPITE->TMPPAL $ "NOVO PALLET"))
				If TMPITE->TMPPAL $ "NOVO PALLET"
					RecLock("TMPITE", .F.)
						TMPITE->TMPPAL := (cGet1Env)
					MsUnlock()
				Endif
				DbSelectArea("ZZK")
				If !lCheck .and. (len(Alltrim(TMPITE->TMPCBR)) <> 42)  // Não buscar pelo código de barras qdo a quantidade for digitada
					DbSetOrder(5)
					DbGoTop()    
					DbSeek(xFilial("ZZK")+ALLTRIM(TMPITE->TMPCBR), .t.)   
				Else
   					DbSetOrder(2) //ZZK_FILIAL+ZZK_CODIGO+ZZK_PRODUT+ZZK_SEQENV                                                                                                                                  
					DbGotop()
					DbSeek(xFilial("ZZK")+TMPITE->TMPPAL+TMPITE->TMPPRO+TMPITE->TMPSEQ, .t.)      					
				Endif
				If !Found()
					RecLock("ZZK", .T.)
						ZZK_FILIAL := xFilial("ZZK")
						ZZK_CODIGO := TMPITE->TMPPAL
						ZZK_LOTE   := TMPITE->TMPLOT
						ZZK_SEQENV := TMPITE->TMPSEQ
						ZZK_PRODUT := TMPITE->TMPPRO
						ZZK_QUANT  := TMPITE->TMPQTD
						ZZK_CODBAR := TMPITE->TMPCBR
						ZZK_DATA   := Date()
						ZZK_HORA   := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
						ZZK_FLAG   := '1'
					MsUnLock()
				Endif
				DbSelectArea("TMPITE")
				DbSkip()
			Enddo
		Else
			DbSelectArea("ZZJ")
			DbSetOrder(1)
			DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
			If Found()
				RecLock("ZZJ", .F.)
					DbDelete()
				MsUnlock()		
				CGet1Env := Space(11) 
			Endif
		Endif    	
	End Transaction

	aDelete :={}   

	If ChkFile("TMPITE") 
		DbSelectArea("TMPITE")
	    //DbGotop()
		//Zap
        //LGS#20191029 - Substituido comandoZAP devido a utilização de função do banco.
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
		If !Empty(Alltrim(cGet1Env))
			fCarPall(cGet1Env)
		Endif
		oCBox1Lo:Enable()
	Endif
	//oCBox1Lo:Enable()
    //oGet1Env:bLostFocus := {|| Iif(!Empty(Alltrim(cGet1Env)),fCarPall(cGet1Env),""), MsAguarde( {|| Iif(!Empty(Alltrim(cGet1Env)),fCarPall(cGet1Env),"")}, "Aguarde...", "Buscando produtos no Pallet")}
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fSairMPa()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fSairMPa()
	
	Local lRet
	If ChkFile("TMPITE")
	   	DbSelectArea("TMPITE")
	   	DbSetOrder(1)
	   	DbSeek(Alltrim(cGet1Env), .F.)
		If Found()
		 	DbSelectArea("ZZJ")
			DbSetOrder(1)
			DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
			If Found() 
				If ZZJ->ZZJ_FLAG $ '1'
					lRet := MsgBox("Deseja SALVAR as alterações antes de Sair ?'","Pergunta","YESNO")
				    If lRet
	    				fSMntPal()
				 	Endif 
				Endif 
			Else
				lRet := MsgBox("Deseja SALVAR as alterações antes de Sair ?'","Pergunta","YESNO")
			    If lRet
    				fSMntPal()
			 	Endif
			Endif
		 	DbSelectArea("ZZJ")
			DbClosearea()
		Endif
		DbSelectArea("TMPITE")
		DbClosearea()
	Endif
	
	//If ChkFile("TMPCAB")
	//	DbSelectArea("TMPCAB")
	//	DbClosearea()
	//Endif
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
	//aAdd( aFds , {"TMPORI"  ,"C", 002, 000} )   // ARMAZEM ORIGEM
    //aAdd( aFds , {"TMPFLG"  ,"C", 001, 000} )   // FLAG
	aAdd( aFds , {"TMPCBR"  ,"C", 042, 000} )   // CODIGO DE BARRAS
    aAdd( aFds , {"TMPDEL"  ,"C", 001, 000} )   // DELETADO

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
       oTempTbl1:AddIndex( "cInd01", { "TMPPAL", "TMPSEQ" } )
       oTempTbl1:AddIndex( "cInd02", { "TMPPAL", "TMPPRO", "TMPSEQ" } )
       oTempTbl1:AddIndex( "cInd03", { "TMPPAL", "TMPINV" } )
       oTempTbl1:AddIndex( "cInd04", { "TMPPAL", "TMPCBR" } )
       oTempTbl1:AddIndex( "cInd05", { "TMPCBR" } )
       oTempTbl1:Create()
       /********************************************************************************************************************************/
    
    DbSetOrder(1)

Return

Static Function fCarPall(cPallet)
	
	If Empty(Alltrim(cPallet)) .or. (cGet1Env $ "NOVO PALLET")
		Return
	Endif
	If Len(Alltrim(cPallet)) = 10
		cGet1Env  := Substr(cPallet,1,6)+'/'+Substr(cPallet,7,4)
		cPallet := cGet1Env 	
	Endif
	cSay3Env := ""
	cSay5Env := ""

	If ChkFile("TMPITE")
		DbSelectArea("TMPITE")
		//DbGoTop()
		//Zap
        //LGS#20191029 - Substituido comandoZAP devido a utilização de função do banco.
        TCSqlExec("DELETE FROM " + oTempTbl1:GetRealName() )
	Endif

    cQry1 := ""
    cQry1 += "SELECT ZZK_CODIGO, ZZK_LOTE, ZZK_SEQENV, ZZK_PRODUT, ZZK_QUANT, ZZK_LOCORI, ZZK_FLAG, ZZJ_FLAG, ZZK_CODBAR, ZZJ_LOCALI   "
    cQry1 += "FROM "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) "
    cQry1 += "LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZJ_CODIGO = ZZK_CODIGO AND ZZK.D_E_L_E_T_ ='' "
    cQry1 += " WHERE (ZZJ.ZZJ_FILIAL = '"+XFILIAL("ZZJ")+"') "
    cQry1 += "  AND (ZZJ.D_E_L_E_T_ = '') "
    cQry1 += "  AND ZZK.ZZK_CODIGO = '"+cPallet+"' "
    //cQry1 += "	AND (ZZJ_BORDER ='') "
    cQry1 += " ORDER BY ZZK_CODIGO, ZZK_PRODUT, ZZK_SEQENV"

    TCQuery cQry1 ALIAS "TCQ" NEW
    nConOrd := 1
    DbSelectArea("TCQ")
    If !Eof()
		If TCQ->ZZJ_FLAG $ '3.4'
			Messagebox("Tipo de Pallet inválido (Compra por Borderô), verifique o código do Pallet bipado / digitado !!!","Atenção...",48)	  		
			//cGet1Env := Space(11)
			oGet1Env:Setfocus()
		Else
			While !Eof()
				RecLock("TMPITE", .T.)
					TMPITE->TMPPAL := TCQ->ZZK_CODIGO
					TMPITE->TMPLOT := TCQ->ZZK_LOTE
					TMPITE->TMPSEQ := TCQ->ZZK_SEQENV
					TMPITE->TMPPRO := TCQ->ZZK_PRODUT
					TMPITE->TMPQTD := TCQ->ZZK_QUANT
					TMPITE->TMPCBR := TCQ->ZZK_CODBAR
					TMPITE->TMPINV := Inverte(TCQ->ZZK_SEQENV)
				    //TMPITE->TMPORI := TCQ->ZZK_LOCORI
					//TMPITE->TMPFLG := TCQ->ZZK_FLAG
				MsUnLock()
				DbSelectArea("TCQ")
				DbSkip()
			Enddo
			
			If !lTelaJaFechada
				oBtn3Env:Enable()
			Endif
			//oBtn3Env:Enable()
			If Alltrim(TMPITE->TMPCBR) $ 'DIG'
				lCheck :=.t.
				oCBox1:Refresh()
			Else
				lCheck :=.f.
				oCBox1:Refresh()
			Endif
		Endif
	Else
		Messagebox("Pallet Inexistente, verifique o número do Pallet digitado / bipado !!!","Atenção...",48)	  		
		cGet1Env := Space(11)
		oBtn3Env:Enable()
		nCBox1Lo:=Space(04)
		oCBox1Lo:Enable()
		oGet1Env:Setfocus()
    Endif
    DbSelectArea("TCQ")
	DbCloseArea()    

    If ChkFile("TMPITE")
		DbSelectArea("TMPITE")
        DbGoTop()
		oBrw1Env:oBrowse:GoTop()
		oBrw1Env:oBrowse:Refresh()
    Endif	
	
	DbSelectArea("ZZJ")
	DbSetOrder(1)
	DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
	If Found() 
		nCBox1Lo :=ZZJ->ZZJ_LOCALI
		oCBox1Lo:Refresh()
		If !Empty(Alltrim(ZZJ->ZZJ_LOCPRO)) .and. ZZJ->ZZJ_FLAG $ '1'
			cSay5Env := "Pallet já passou pela Rampa. Origem -> "+ZZJ->ZZJ_LOCPRO 
		Endif
		If ZZJ->ZZJ_FLAG $ '2'
			cSay3Env := "Pallet transferido. Origem: "+ZZJ->ZZJ_LOCORI+" Destino: "+ZZJ->ZZJ_LOCDES
		Endif
	Endif
	DbSelectArea("ZZJ")
	DbClosearea()	    

Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fIEtPallet() - Impressão da Etiqueta do Pallet
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fIEtPallet(cModelo)

	If cGet1Env $ "NOVO PALLET"   
   		Messagebox("Salve o Pallet antes de Imprimir a etiqueta !!!","Atenção...",48)
		Return
	Endif
    If Empty(Alltrim(cModelo))
   		Messagebox("Escolha o modelo da impressora antes de mandar a impressão !!!","Atenção...",48)
		Return
    Endif
    //Verificação de Impressora ativa
    //oPrint   := TMSPrinter():New("Impressão de Etiquetas de Pallets")
    //lPrinter := oPrint:IsPrinterActive()
    If Alltrim(cModelo) $ "ZEBRA S4M" 
		cModelo   := "S4M"
    Elseif Alltrim(cModelo) $ "ZEBRA ZT230"
		cModelo   := "ZEBRA"
    Endif
    cPorta    := "LPT1" //Porta da impressora
    nTam      := 120    //Tamanho da etiqueta
    lTipo     := .f.    //.f.=Local; .t.=Servidor ou Outro Servidor
    lDrvWin   := .f.    //Usa Drive do Windows
    //For nY := 1 To 2    // IMPRIMIR APENAS 1 ETIQUETA POR VEZ - SOLICITADO POR CLEITON
 	   MSCBPRINTER(cModelo, cPorta, , nTam, lTipo, , , , , , lDrvWin)
       
       If !MSCBIsPrinter('LPT1')
    	   Messagebox("Impressora não encontrada!","Atenção",48)
           MSCBCLOSEPRINTER()
//           Exit
       Else   
	       MSCBBEGIN(1, 6, , .f.)
		   /*
		   MB01 - Interleaved 2 of 5 / EAN14
		   MB02 - Code 39 
		   MB03 - EAN 8 
		   MB04 - EAN 13 
		   MB05 - UPC A 
		   MB06 - UPC E 
		   MB07 - CODE 128 */
           //MSCBSAYBAR(05, 03, StrTran(cGet1Env,"/",""), "N", "MB01", 15, .F., .T., .F., , 3, 2)
           MSCBSAYBAR(05, 03, StrTran(cGet1Env,"/",""), "N", "MB07", 15, .F., .T., .F., , 3, 2)
           
 //Para EPL:
// 			MSCBSAY(05,03,"Produto: "+SB1->B1_MAPA1,"N","4" ,"1,2")

// Para ZPL:
 //MSCBSAY(04,12,"Produto: "+SB1->B1_MAPA1,"N","0" ,"020,030")   
           
           MSCBCHKSTATUS(.f.)
           cText := MSCBEND()
           MSCBCLOSEPRINTER()

           //cArq := 'C:\TEMP\'+strtran(cGet1Env,"/","")+'.ETQ'
           //MemoWrit(cArq, cText)
           //Type cArq > prn
	   Endif
	//Next 

Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fMntPallet() - Manutenção dos itens de montagem do Pallet
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fMntPallet(nOpcMnt) // 1 - Monta / 2 - Desmonta
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Declaração de cVariable dos componentes                                 ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

	Private cGet1Mnt   := Space(42) //Iif(nOpcMnt == 1, Space(15), TMPITE->TMPPRO)
 	Private cGet2Mnt   := Space(3)  //Iif(nOpcMnt == 1, Space(3) , TMPITE->TMPSEQ)
  	Private nGet3Mnt   := 0 	    //Iif(nOpcMnt == 1, 0        , TMPITE->TMPQTD) 
   	Private nGet7Mnt   := 0 	    //Iif(nOpcMnt == 1, 0        , TMPITE->TMPQTD) 
	Private cGet5Mnt   := Space(6)  //Iif(nOpcMnt == 1, Space(06), TMPITE->TMPLOT) 
 	Private cGet4Mnt   := Space(30) //Iif(nOpcMnt == 1, Space(30), Posicione("SB1", 1, xFilial("SB1")+TMPITE->TMPPRO, "B1_DESC"))
  	Private cSay1Mnt   := Space(1)
   	Private cSay2Mnt   := Space(1)
    Private cSay3Mnt   := Space(1)
    Private cSay4Mnt   := Space(1)
    Private cSay6Mnt   := Space(140)
    Private nVolAtual  := 0
    Private lJaBipou   :=.f.

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
 	±± Declaração de Variaveis Private dos Objetos                             ±±
  	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
   	SetPrvt("oFontMn1", "oFontMn2", "oDlg1Mnt", "oSay1Mnt", "oSay4Mnt", "oSay2Mnt", "oSay3Mnt", "oGet1Mnt", "oGet2Mnt")
    SetPrvt("oGet3Mnt", "oBtn2Mnt", "oBtn1Mnt", "oGet4Mnt", "oSay5Mnt", "oGet5Mnt", "oSay6Mnt", "oGet7Mnt" )
    
    If Empty(Alltrim(cGet1Env))
    	Return
    Endif
           
	If nOpcMnt == 1
		DbSelectArea("ZZJ")
		DbSetOrder(1)
		DbSeek(xFilial("ZZJ")+cGet1Env, .t.)   
		If Found()
			If ZZJ->ZZJ_FLAG == "2"
				Messagebox("Pallet já transferido não pode ser alterado.","Atenção...",48) 
	   			Return
		  	Endif
	    Endif
    Endif
    
    If ChkFile("TMPITE")
   		DbSelectArea("TMPITE")
        DbGoTop()
       	oBrw1Env:oBrowse:GoTop()
       	oBrw1Env:oBrowse:Refresh()
    Endif
    
	If lCheck .and. (nOpcMnt ==1)
       //	If oBrw1Env[oBrowse:2][2] $ '002' //oBrw1Env[oBrowse:02,02] $ '002'    	 // aBrowse1[oBrowse1:nAt][1]
    		Messagebox("Pallets com quantidades digitadas só podem conter 1 produto por Pallet !!","Atenção...",48) 
       //	Endif
	Endif

    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Definicao do Dialog e todos os seus componentes.                        ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    
    oFontMn1   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
    oFontMn2   := TFont():New( "MS Sans Serif", 0, -16, , .F., 0, , 400, .F., .F., , , , , , )
    oDlg1Mnt   := MSDialog():New( 258, 232, 380, 867, "Manutenção do Pallet", , , .F., , , , , , .T., , , .T. )
    oSay1Mnt   := TSay():New( 009, 004, {|| "Codigo:"   }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)
    oGet1Mnt   := TGet():New( 007, 045, {|u| If(PCount() > 0, cGet1Mnt := u, cGet1Mnt)}, oDlg1Mnt, 070, 012, '@!', , CLR_BLACK, CLR_WHITE				 , oFontMn2, , , .T., "", , , .F., .F., , .F. , .F.,  ""    ,"cGet1Mnt", , )
    oSay4Mnt   := TSay():New( 026, 004, {|| "Descr.:"}, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)                                                                                         
    oGet4Mnt   := TGet():New( 025, 045, {|u| If(PCount() > 0, cGet4Mnt := u, cGet4Mnt)}, oDlg1Mnt, 196, 012, '@!'                 , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""    ,"cGet4Mnt", , )
    oSay5Mnt   := TSay():New( 026, 250, {|| "Lote:"      }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 024, 012)
    oGet5Mnt   := TGet():New( 025, 276, {|u| If(PCount() > 0, cGet5Mnt := u, cGet5Mnt)}, oDlg1Mnt, 024, 012, '@R 999999'          , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""    ,"cGet5Mnt", , )
    oSay2Mnt   := TSay():New( 009, 120, {|| "Seq:"      }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 024, 012)
    oGet2Mnt   := TGet():New( 007, 143, {|u| If(PCount() > 0, cGet2Mnt := u, cGet2Mnt)}, oDlg1Mnt, 024, 012, '@R 999'             , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , Iif(!lCheck .and. nOpcMnt == 2 ,.T.,.F.) , .F., ""    ,"cGet2Mnt", , )
    oSay3Mnt   := TSay():New( 009, 180, {|| "Qtde:"     }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 028, 012)
    oGet3Mnt   := TGet():New( 007, 205, {|u| If(PCount() > 0, nGet3Mnt := u, nGet3Mnt)}, oDlg1Mnt, 024, 012, '@E 999999'       , ,    CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , Iif(!lCheck,.T.,.F.) 					, .F., ""    ,"nGet3Mnt", , )
    oSay4Mnt   := TSay():New( 009, 250, {|| "Total:"     }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 028, 012)
    oGet7Mnt   := TGet():New( 007, 276, {|u| If(PCount() > 0, nGet7Mnt := u, nGet7Mnt)}, oDlg1Mnt, 024, 012, '@E 999999'       , ,    CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""    ,"nGet7Mnt", , )
    oSay6Mnt   := TSay():New( 043, 004, {||  cSay6Mnt}, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 220, 012)                                                                                         
	//oTblCBar() 
    oBtn1Mnt   := TButton():New( 044, 273, "Confirma", oDlg1Mnt, {|| fManuPal(nOpcMnt)}  , 040, 014, , oFontMn2, , .T., , "", , , , .F. )
    oGet1Mnt:bLostFocus := {|| fValCodPro(nOpcMnt) }
    oGet2Mnt:bLostFocus := {|| Iif(lCheck .and. nOpcMnt == 2, fBusSequ(cGet2Mnt), cGet2Mnt) }
    oGet3Mnt:bLostFocus := {|| Iif(lCheck, nGet7Mnt := nGet3Mnt, nGet7Mnt) }

    oDlg1Mnt:Activate( , , , .T.)

Return

/*ÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fBusSequ() - Validação da Sequencia na desmontagem do Pallet (passando qtde)
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fBusSequ(cGet2Mnt)
	If lCheck
	    DbSelectArea("TMPITE")
    	DbSetOrder(2)
    	DbGoTop()	
	   	DbSeek(cGet1Env+cGet1Mnt+cGet2Mnt, .F.)
   		If Found() .AND. (Alltrim(TMPITE->TMPPAL) == Alltrim(cGet1Env)) 
			nGet3Mnt := TMPITE->TMPQTD 
		Else
		    OGet2Mnt:Setfocus()
		Endif
	Endif
Return


/*ÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fValCodPro() - Validação do código do produto na manutenção do Pallet
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fValCodPro(nOpcMnt)  //1 - Montagem do Pallet 2- Desmontagem

    Local cQry 		:= ""
    Local nVol 		:= 0
    Local nQtdAtual := 0
    Local lVencido  := .f.
    //Local lProdMist :=.f.

    lJaBipou := .f.

    cCodBarra := Substr(cGet1Mnt,1,len(alltrim(cGet1Mnt)))
	
	If Empty(Alltrim(cGet1Env)) .or. Empty(Alltrim(cCodBarra))
		Return
	Endif
	//If !(Len(Alltrim(cCodBarra)) == 14 .or. Len(Alltrim(cCodBarra)) == 18)
	DbSelectArea("SB1")
    DbSetOrder(1)
	DbSeek(xFilial("SB1")+Substr(cCodBarra,1,12), .t.)                                                         
 	If !Found() 
		If !(Len(Alltrim(cCodBarra)) == 14 .or. Len(Alltrim(cCodBarra)) == 18 .or.  Len(Alltrim(cCodBarra)) == 42 )
			Messagebox("Tamanho do código de Barras incompatível com os padrões utilizados (14 / 18 / 42 digitos)!!","Verifique...",48)
	   		oGet1Mnt:SetFocus()
	   		Return
		Endif
	Else
		oGet1Mnt:SetFocus()
	   	Return
	Endif

	If Len(Alltrim(cCodBarra)) == 18 .or. Len(Alltrim(cCodBarra)) == 14
		If !lCheck
	    	DbSelectArea("TMPITE")
	   		DbSetOrder(4)
   			DbGoTop()
			DbSeek(cGet1Env+cCodBarra, .F.)
	    	If Found()
		    	If nOpcMnt == 1
  		  			oGet4Mnt:SetFocus()
  	   		   		lJaBipou :=.t.
	      		Endif
    		Else
	    		If nOpcMnt == 2 .and. Len(Alltrim(Posicione("SB1", 1, xFilial("SB1")+cGet1Mnt, "B1_DESC")))==0
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
					If Found() .and. ZZJ->ZZJ_FLAG $ '1.2'
						Messagebox("Produto já digitado em Pallet..: "+ZZK->ZZK_CODIGO+" Faça a desmontagem do Pallet antes de bipar !!","Atenção...",48)
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
   		Endif
    Endif
    If Len(Alltrim(cCodBarra)) == 42
		DbSelectArea("SB1")
	    DbSetOrder(5)
		DbSeek(xFilial("SB1")+Substr(cCodBarra,04,12), .t.)                                                         
	 	If Found() 
  			If SB1->B1_MSBLQL <> '1'
				//cGet5Mnt  := Substr(Alltrim(cCodBarra),42,06)
				cGet5Mnt  := Substr(Alltrim(cCodBarra),29,06)
				cGet1Mnt := (SB1->B1_COD)  
				//dDtValida := cTod(Substr(cCodBarra,28,02)+'/'+Substr(cCodBarra,26,02)+'/'+Substr(cCodBarra,24,02))//     ("20"+Substr(Alltrim(cCodBarra),24,06))
				dDtValida := cTod(Substr(cCodBarra,37,02)+'/'+Substr(cCodBarra,39,02)+'/'+Substr(cCodBarra,41,02))//     ("20"+Substr(Alltrim(cCodBarra),24,06))
				If DateDiffDay(dDtValida, dDatabase ) < 360 //Apura Diferenca em Dias entre duas Datas > 
					lVencido :=.t.	
				Endif
			Else
       	     	Messagebox("Produto bloqueado !!!","Atenção...",48)
				oGet1Mnt:SetFocus()
           	  	cGet1Mnt := space(42)
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
			Endif
		Endif	
		//cGet1Mnt  := Substr(Alltrim(cCodBarra),04,13)
	ElseIf Len(Alltrim(cCodBarra)) == 18
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
       	     	Messagebox("Produto bloqueado !!!","Atenção...",48)
				oGet1Mnt:SetFocus()
           	  	cGet1Mnt := space(42)
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
			Endif
		Endif	
    ElseIf Len(Alltrim(cCodBarra)) == 14
    	DbSelectArea("SC2")
	    DbSetOrder(13)
	    DbSeek(xFilial("SC2")+Alltrim(Substr(cGet1Mnt,1,6)), .t.)
    	If Found() 
	    	While !(SC2->(Eof())) .AND. (XFilial("SC2") == SC2->C2_FILIAL) .AND. (Substr(cGet1Mnt,1,6) == Alltrim(SC2->C2_LOTE)) 
				If Substr(cGet1Mnt,7,2) == Substr(SC2->C2_PRODUTO,11,2) 
					If DateDiffMonth(dDatabase, SC2->C2_DATPRF  ) > 35
					   	lVencido :=.t.
					Else
						cGet5Mnt := Substr(cGet1Mnt,1,6)
						cGet1Mnt := (SC2->C2_PRODUTO)
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
	   	   	cGet1Mnt:= PADR(cGet1Mnt,42,' ')
	   	   	//oGet1Mnt:SetFocus()
			Return
		Endif
    Endif
    
	If lVencido 
		Messagebox("Problemas na identificação do Lote ou / Produto fora de validade, bipe novamente este produto / confirme a data de validade !!!","Atenção...",48)
    	oGet1Mnt:SetFocus()
		cGet1Mnt:= PADR(cGet1Mnt,42,' ')
		oGet1Mnt:SetFocus()
    	lVencido := .f.
    	Return
    Endif
    If BLQLOTE(cGet5Mnt)
		Messagebox("Lote bloqueado pelo setor de qualidade, não é possível separar, Verifique !!","Atenção...",48)
    	oGet1Mnt:SetFocus()
		cGet1Mnt:= PADR(cGet1Mnt,42,' ')
		oGet1Mnt:SetFocus()
		If ChkFile("TCR")
			DbSelectArea("TCR")
			DbCloseArea()
		Endif
		Return()
	EndIf	
	If nOpcMnt = 1
	    If lJabiPou 
	    	If Alltrim(_CodProd) <> Alltrim(cGet1Mnt)
	     		nGet7Mnt:=0
	    		nVol 	:=0
				cGet1Mnt:= PADR(cGet1Mnt,42,' ')
				oGet1Mnt:SetFocus()
		  	Endif
			Return
	    Endif
		DbSelectArea("SB1")
	    DbSetOrder(1)
		DbSeek(xFilial("SB1")+cGet1Mnt, .t.)                                                         
	 	If Found() 
  			If SB1->B1_MSBLQL <> '1'
	    		If SB1->B1_TIPO $ 'PA.PI.MP'
    	  			cGet4Mnt := SB1->B1_DESC
         			cGet2Mnt := U_fMaxSeq()
	                If !lCheck
		                If Len(Alltrim(cCodBarra)) == 14 // etiquetas novas já trazem a relação de volumes 
							nGet3Mnt := Val(Substr(Alltrim(cCodBarra),9,2))
						//ElseIF Len(Alltrim(cCodBarra)) == 42
						//	nGet3Mnt := Val(Substr(Alltrim(cCodBarra),21,6))							
						Else
		    	            cQry += " SELECT RELVOL = dbo.DetVol('"+xFilial("SB1")+"','"+Alltrim(cGet1Mnt)+"')"
  						    TCQuery cQry ALIAS "TCR" NEW
							nGet3Mnt := Val(TCR->RELVOL)
						Endif
						nGet7Mnt := (nGet7Mnt + nGet3Mnt) // Soma no Total a quantidade bipada
						//nVol := (nGet7Mnt/Val(TCR->RELVOL))
						nVol := (nGet7Mnt/nGet3Mnt)
					    _CodProd   := cGet1Mnt
					    nCapPallet := fVerCPall(_CodProd)
					    If nCapPallet <> nCapAntPal .and. (nCapAntPal <> 0) .or. lProdMist
							lProdMist := .t.
							cSay3Env  := "Produtos com capacidade de Pallett misturados"						
						Else
							If nCapPallet = 0
								cSay3Env := "Capacidade Total do Pallet ainda não cadastrada!"
	                        Else
								cSay3Env := "Capacidade Total do Pallet "+TransForm(nCapPallet,"@E 9999")
							Endif
						Endif
	
	            	   	oGet1Mnt:SetFocus()
						nCapAntPal := nCapPallet
						oSay3Env:Refresh()
						cSay6Mnt := "MONTAGEM - VOL. BIPADOS..:  "+Alltrim(TransForm(nVol, "@E 9999"))+Iif(nCapPallet <>0 .and. !lProdMist,"  RESTANDO ..: "+TransForm((nCapPallet-nVol),"@E 9999")," ")

					    If ChkFile("TCR")
						    DbSelectArea("TCR")
		    				DbCloseArea()
				    	Endif
	       	   			RecLock("TMPITE", .T.)
							TMPITE->TMPPAL := (cGet1Env)
				            TMPITE->TMPPRO := cGet1Mnt
				    		TMPITE->TMPCBR := Iif(!lCheck,(cCodBarra),"")
							TMPITE->TMPLOT := cGet5Mnt
			        	    TMPITE->TMPSEQ := cGet2Mnt
			            	TMPITE->TMPQTD := nGet3Mnt
				            TMPITE->TMPINV := Inverte(TMPITE->TMPSEQ)
				            cGet1Mnt 	   := Space(42)
				            cGet1Mnt       := PADR(TMPITE->TMPPRO,42,' ')
					    MsUnLock()
					Else
	       	   			oGet3Mnt:SetFocus()
       	   			Endif
				Else
        	     	oGet1Mnt:SetFocus()
            	  	cGet1Mnt := space(42)
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
  				Endif
			Else
	 			Messagebox("Produto bloqueado, verifique!!!","Atenção...",48)
   				oGet1Mnt:SetFocus()
		     	cGet1Mnt := space(42)
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
			Endif
	 	Else
    		Messagebox("Código de barras não reconhecido, verifique!!!","Atenção...",48)
     		oGet1Mnt:SetFocus()
	      	cGet1Mnt := space(42)
    	   	oGet1Mnt:Refresh()
        	cGet4Mnt := space(30)
	        oGet4Mnt:Refresh()
  		Endif
		If !lCheck
			oGet1Mnt:SetFocus() 
		Endif	
		DbSelectArea("SB1")
    	DbCloseArea()
	Elseif nOpcMnt = 2 // Desmontagem
		If !lCheck
			DbSelectArea("TMPITE")
			DbSetOrder(4) // pallet + código de barras
			DbGoTop()    
		   	DbSeek(cGet1Env+cCodBarra, .F.)
	   		If Found() .AND. (Alltrim(TMPITE->TMPPAL) == Alltrim(cGet1Env))
	  			cGet4Mnt := Posicione("SB1", 1, xFilial("SB1")+TMPITE->TMPPRO, "B1_DESC")
	   	 		cGet5Mnt := TMPITE->TMPLOT
	   			cGet2Mnt := TMPITE->TMPSEQ
				nQtdAtual:= fProdPalle() 
		        If Len(Alltrim(cCodBarra)) == 14
					nGet3Mnt := Val(Substr(Alltrim(cCodBarra),9,2))
				Else
			        cQry += " SELECT RELVOL = dbo.DetVol('"+xFilial("SB1")+"','"+Alltrim(cGet1Mnt)+"')"
	  			    TCQuery cQry ALIAS "TCR" NEW
					nGet3Mnt := Val(TCR->RELVOL)
				Endif
				nGet7Mnt 	:= (nQtdAtual-nGet3Mnt) // Subtrai no Total a quantidade bipada
				nVol		:= (nGet7Mnt/nGet3Mnt)
				nVolAtual 	:= (nVolAtual +1)
				cSay6Mnt  	:= "DESMONTAGEM - VOL. BIPADOS..:  "+TransForm(nVolAtual, "@E 9999")
			    _CodProd 	:= cGet1Mnt
		    	cGet1Mnt    := PADR(cGet1Mnt,42,' ')
	   	       	oGet4Mnt:Refresh()
    	       	oGet2Mnt:Refresh()
	       	   	oGet1Mnt:SetFocus()
			    If ChkFile("TCR")
				    DbSelectArea("TCR")
		   			DbCloseArea()
			    Endif

   				RecLock("TMPITE", .f.)
	                aAdd(aDelete, { cGet1Env, cCodBarra } )
	                DbDelete()             
	       		MsUnLock()
	        Else
    			Messagebox("Produto não encontrado neste Pallet, verifique!!!","Atenção...",48)
	    		oGet1Mnt:SetFocus()                                     	
			   	cGet1Mnt := space(42)
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
	       	Endif
		Elseif lCheck // desmontar informando quantidade
		    DbSelectArea("TMPITE")
	    	DbSetOrder(2)
	    	DbGoTop()	
		   	DbSeek(cGet1Env+cGet1Mnt, .F.)
	   		If Found() .AND. (Alltrim(TMPITE->TMPPAL) == Alltrim(cGet1Env)) .AND. (Substr(cCodBarra,1,6) == TMPITE->TMPLOT)
				cGet4Mnt := Posicione("SB1", 1, xFilial("SB1")+TMPITE->TMPPRO, "B1_DESC")
				oGet2Mnt:SetFocus() 
            Else
       			Messagebox("Produto / Lote não encontrado neste Pallet, verifique!!!","Atenção...",48)
	    		oGet1Mnt:SetFocus()                                     	
			   	cGet1Mnt := space(42)
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
            Endif
		Endif
	Endif            
	DbSelectArea("TMPITE")
   	DbSetOrder(1)
   	DbGoTop()	

Return
 
/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fProdPallet()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fProdPalle()

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
    		nQtd += TMPITE->TMPQTD
    		DbSkip()
    	Enddo
	Else
		cQry1 := ""
	    cQry1 += " SELECT SUM(ZZK_QUANT) AS ZZK_QUANT "
	    cQry1 += " FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "
	    cQry1 += " WHERE ZZK.D_E_L_E_T_ ='' "
	    cQry1 += " AND ZZK_FILIAL = '"+XFILIAL("ZZK")+"' "
    	cQry1 += " AND ZZK.ZZK_CODIGO = '"+Alltrim(cGet1Env)+"' "

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
Static Function fManuPal(nOpc)

 	If Len(Alltrim(cGet1Mnt)) == 0
		Messagebox("Bipe o código de barras antes de confirmar !!","Verifique...",48)		
	   	oGet1Mnt:SetFocus()
		Return
	Endif
	If nOpc == 1
 		If nGet7Mnt > 0
   			_cMaxSeq := cGet2Mnt
      	Endif
      	If !lCheck
	      	nQtdTotal := 0
		Else
			If nGet3Mnt <= 0
				Messagebox("Quantidade inválida!!","Verifique...",48)
			   	oGet1Mnt:SetFocus()
				Return
			Else	
				RecLock("TMPITE", .T.)
					TMPITE->TMPPAL := (cGet1Env)
					TMPITE->TMPPRO := cGet1Mnt
					TMPITE->TMPCBR := 'DIG'
					TMPITE->TMPLOT := cGet5Mnt
				 	TMPITE->TMPSEQ := cGet2Mnt
				  	TMPITE->TMPQTD := nGet3Mnt
					TMPITE->TMPINV := Inverte(TMPITE->TMPSEQ)
				MsUnLock()
			Endif
		Endif
	ElseIf nOpc == 2
   	 	If Len(Alltrim(cGet2Mnt)) == 0
			Messagebox("Informe a sequencia do produto que será excluído !!","Verifique...",48)		
		   	oGet2Mnt:SetFocus()
			Return
		Endif
    	If !lCheck
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
    	Else
  	    	DbSelectArea("TMPITE")
   			DbSetOrder(2)
   			DbGoTop()
			DbSeek(cGet1Env+cGet1Mnt+cGet2Mnt, .F.)
    		If Found()
            	RecLock("TMPITE", .f.)
   		            aAdd(aDelete, { cGet1Env, cGet1Mnt, cGet2Mnt} )    // carrega array pra excluir da tabela zzk na confirmação
		           	DbDelete()             
    	       	MsUnLock()
      		Endif
    	Endif
	Endif           			  
    oDlg1Mnt:End()
    DbSelectArea("TMPITE")
    DbSetOrder(1)
    DbGoTop()
         
Return  

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Function fMaxSeq - Incremento de Sequencia na inclusão dos produtos no Pallet 
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
User Function fMaxSeq() 
	
 	Local cArea := Alias()
 	Local aArea := U_PegaArea({"TMPITE"})
	
    DbSelectArea("TMPITE")
    DbSetOrder(3)
    DbGoBottom()
    
    DbSeek(cGet1Env, .F.)
    If !Found()
    	cMaxSeq := StrZero(1,3)
    Else
    	cMaxSeq := StrZero(Val(TMPITE->TMPSEQ)+1, 3) 
	Endif
    
	DbSelectArea("TMPITE")
    DbSetOrder(3)
    DbGoTop()
	
    U_VoltaArea(aArea)
	If !Empty(cArea)
		DbSelectArea(cArea)
	Endif
	 
Return(cMaxSeq)

Static Function fNPal()

	Local cQry1   := ""
	//Local cQry2   := ""
    Local nCodReg := ""
    //Local cLocali := ""
	//Local cNumIP  := GetClientIP()       
	oCBox1Lo:Refresh()

	If Empty(Alltrim(nCBox1Lo)) .and. alltrim(FWCodFil()) =='010101'
		Messagebox("Informe o local onde o Pallet esta sendo montado (FAB-1 / FAB-2 / DEPOS) !!","Verifique...",48)		
		oCBox1Lo:Setfocus()
		Return
	Endif

	aDelete  := {}
	lCheck   := .f.
	cGet1Env := "NOVO PALLET"
	cSay3Env := ""
	cSay5Env := ""
	
	If ChkFile("TMPCAB")
		DbSelectArea("TMPCAB")
		DbGoTop()
		Zap
	Endif
	If ChkFile("TMPITE")
		DbSelectArea("TMPITE")
		//DbGoTop()
	 	//Zap
        //LGS#20191029 - Substituido comandoZAP devido a utilização de função do banco.
        TCSqlExec("DELETE FROM " + oTempTbl1:GetRealName() )
	Endif 
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
		cQry1 += "  AND ZZJ.ZZJ_DTINI  = '"+DTOS(Date())+"' "
		cQry1 += " ORDER BY ZZJ.ZZJ_CODIGO DESC "

		TCQUERY cQry1 ALIAS "TCQ" NEW
		DbSelectArea("TCQ")
		DbGoTop()

		cCodSeq := Iif(Empty(TCQ->ZZJ_CODIGO), SubStr(Dtos(Date()), 7, 2)+SubStr(Dtos(Date()), 5, 2)+SubStr(Dtos(Date()), 3, 2)+'/'+'0001', SubStr(TCQ->ZZJ_CODIGO, 1, 7)+StrZero(Val(SubStr(TCQ->ZZJ_CODIGO, 8, 4))+1, 4) )
		cNomArq := SubStr(cCodSeq, 8, 4)
		DbSelectArea("TCQ")
		DbCloseArea()
		
		
		/*
		cQry1 := ""
		cQry1 += "INSERT INTO "+RetSqlName("ZZJ")+" (ZZJ_FILIAL,  ZZJ_CODIGO  ,  ZZJ_DTINI         , ZZJ_HINI                                       ,  R_E_C_N_O_ , ZZJ_FLAG,   ZZJ_USER, ZZJ_LOCALI      ) "
		cQry1 += "                  VALUES('"+xFilial("ZZJ")+"', '"+cCodSeq+"',  '"+DTOS(Date())+"', '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "+nCodReg+" ,  '1'    , '"+__cUserId+"' , '"+cLocali+"' ) "
		XXX := TCSQLExec(cQry1)		
		If XXX <> 0
			cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
			MemoWrit(cNomArq, cQry1)
		Endif
		*/
		
		DbSelectArea("ZZJ")
		DbSetOrder(1)
		DbSeek(xFilial("ZZJ")+cCodSeq, .t.)   
		If !Found() 
			Reclock("ZZJ",.t.)
				ZZJ->ZZJ_FILIAL := xFilial("ZZJ")
				ZZJ->ZZJ_CODIGO := cCodSeq
				ZZJ->ZZJ_DTINI  := Date()
				ZZJ->ZZJ_HINI   := SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)
				ZZJ->ZZJ_FLAG   := '1'
				ZZJ->ZZJ_USER   := __cUserId
				ZZJ->ZZJ_LOCALI := nCBox1Lo
			MsUnlock()
		Endif
		
		DbSelectArea("ZZJ")
		DbCloseArea()
		/*	
		If ChkFile("TMPITE")
			DbSelectArea("TMPITE")
			DbGoTop()
			//Zap
		Endif */

	   //oBtn3Env:Disable()
       cGet1Env := cCodSeq
    Endif
	oGet1Env:Refresh()
	oBtn3Env:Disable()
	oBrw1Env:oBrowse:GoTop()
	oBrw1Env:oBrowse:Refresh()
	ocBox1:Refresh()
	oCBox1Lo:Refresh()
	oCBox1Lo:Disable()
	


Return

Static Function fGrvNPal() // Grava Numeração do Pallet Antes de Salvar

	Local cQry1   := ""
	//Local cQry2   := ""
    Local nCodReg := ""
    //Local cLocali := ""
	//Local cNumIP  := GetClientIP()       
    
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

		cQry1 := ""
		cQry1 += "INSERT INTO "+RetSqlName("ZZJ")+" (ZZJ_FILIAL,  ZZJ_CODIGO  ,  ZZJ_DTINI         , ZZJ_HINI                                       ,  R_E_C_N_O_ , ZZJ_FLAG,   ZZJ_USER, ZZJ_LOCALI      ) "
		cQry1 += "                  VALUES('"+xFilial("ZZJ")+"', '"+cCodSeq+"',  '"+DTOS(Date())+"', '"+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+"', "+nCodReg+" ,  '1'    , '"+__cUserId+"' , '"+nCBox1Lo+"' ) "
		XXX := TCSQLExec(cQry1)		
		If XXX <> 0
			cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
			MemoWrit(cNomArq, cQry1)
		Endif
		/*	
		If ChkFile("TMPITE")
			DbSelectArea("TMPITE")
			DbGoTop()
	   	   //Zap
	   	Endif */

	   	//oBtn3Env:Disable()
		cGet1Env := cCodSeq
    Endif

Return()


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ TMPETQMark() - Funcao para marcar o MsSelect
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
/*Static Function TMPEMark() // TMPEtqMark
	
	Local lDesMarca := TMPETQ->(IsMark("MARCA", cMarca))
    Local nRecno    := TMPETQ->(Recno())
    
    DbSelectArea("TMPETQ")
    DbGoTop()
    
    While !Eof()
    	If nRecno == Recno()
        	RecLock("TMPETQ", .F.)
            	If lDesmarca
                	TMPETQ->MARCA := "  "
                Else
                    TMPETQ->MARCA := cMarca
                Endif
             TMPETQ->(MsUnlock())
     	Else
      		RecLock("TMPETQ", .F.)
            	TMPETQ->MARCA := "  "
            TMPETQ->(MsUnlock())
        Endif
        DbSelectArea("TMPETQ")
        DbSkip()
	Enddo
    
    DbSelectArea("TMPETQ")
    DbGoTop()
    oBrwSel:oBrowse:Refresh()
    
Return*/

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fVerCPall() - Funcao para retornar capacidade de empilhamento do *
		  ³	Pallet de acordo com tabela ZZ por Embalagem MP                  *
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fVerCPall(_cProduto)
	
	Local cQry 			:= ""
	Local nCapacidade 	:= 0
	
	cQry += " SELECT G1_COD, X5_CHAVE, X5_DESCRI  FROM "+RetSqlName("SX5")+" SX5 WITH(NOLOCK) "
	cQry += " LEFT OUTER JOIN "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) ON X5_FILIAL = '"+xFilial("SX5")+"' AND X5_CHAVE = G1_COMP AND SG1.D_E_L_E_T_ ='' "
	cQry += " WHERE SX5.D_E_L_E_T_ ='' AND X5_TABELA ='ZZ' AND G1_COD ='"+Alltrim(_cProduto)+"' AND G1_FILIAL ='"+xFilial("SG1")+"'"

    TCQUERY cQry ALIAS "TCQ" NEW
    DbSelectArea("TCQ")
    DbGoTop()	 
  	If !Eof() .and. !Bof()
    	nCapacidade := Val(TCQ->X5_DESCRI)
    Endif
    DbSelectArea("TCQ")
    DbCloseArea()
          
Return(nCapacidade)

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
			//Messagebox("Não é possível separar este produto pois o lote esta bloqueado, verifique !!","Atenção...",48)   
			cReturn := .T.
		EndIf 
	EndIf

EndIf	

Return cReturn
