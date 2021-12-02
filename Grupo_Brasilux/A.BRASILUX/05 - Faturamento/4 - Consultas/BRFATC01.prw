#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BRFATC01 ³ Autor ³ Luís G. de Souza      ³ Data ³09/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³                                               ³±±
±±³              ³  /  /  ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function BRFATC01()
     Private cSay1Con   := Space(1)
     Private cSay2Con   := Space(1)
     Private dGet1Con   := CtoD(" ")
     Private dGet2Con   := dDataBase
     Private nCBox1Co  
     u_zcfga01( 'BRFATC01' ) //LGS#2021201 - Gravação de log de utilização da rotina
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1Co", "oDlg1Con", "oSay1Con", "oSay2Con", "oBrw1Con", "oBtn1Con", "oGet1Con", "oGet2Con", "oCBox1Co")
     SetPrvt("oBtn2Con", "oBtn3Con", "oBtn4Con")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oDlg1Con   := MSDialog():New( 091, 232, 665, 927, "Consulta Pedidos Liberados", , , .F., , , , , , .T., , , .T. )
     oFont1Co   := TFont():New( "MS Sans Serif",0,-19,,.F.,0,,400,.F.,.F.,,,,,, )
     oSay1Con   := TSay():New( 006, 002, {|| "De:" }, oDlg1Con, , oFont1Co, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 020, 009)
     oGet1Con   := TGet():New( 004, 020, {|u| If(PCount()>0,dGet1Con:=u,dGet1Con)},oDlg1Con, 048, 014,'',,CLR_BLACK,CLR_WHITE,oFont1Co,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dGet1Con",,)
     oSay2Con   := TSay():New( 006, 075, {|| "Até:"}, oDlg1Con, , oFont1Co, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 020, 009)
     oGet2Con   := TGet():New( 004, 093,{|u| If(PCount()>0,dGet2Con:=u,dGet2Con)},oDlg1Con,048,014,'',,CLR_BLACK,CLR_WHITE,oFont1Co,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dGet2Con",,)
     MsAguarde( {|| oTbl1Tmp("C") }, "Aguarde", "Buscando informações...")
     DbSelectArea("TMPCON")
     DbSetOrder(1)
//     oBrw1Con   := MsSelect():New( "TMPCON","","",{{"PEDI","","Pedido",""},{"CODC","","Cliente",""},{"NOME","","Nome do Cliente",""},{"ESTA","","UF",""},{"REPR","","Representante",""},{"FLAG","","Imp.?",""}, {"PEDP","","Ped. Progr.",""},{"EMIS","","Emissao",""},{"LIBC","","Liberacao",""},{"DIAS","","Atraso","@E 9999"},{"ESPE","","Qtde. Esp.",""},{"ESTO","","Estoque",""},{"BORP","","Bor. Pedidos",""},{"BORD","","Bor. Desp.",""}},.F.,,{024, 003, 285, 347},,, oDlg1Con ) 
     oBrw1Con   := MsSelect():New( "TMPCON","","",{{"PEDI","","Pedido",""},{"CODC","","Cliente",""},{"NOME","","Nome do Cliente",""},{"ESTA","","UF",""},{"REPR","","Representante",""},{"FLAG","","Imp.?",""}, {"PEDP","","Ped. Progr.",""},{"EMIS","","Emissao",""},{"LIBC","","Liberacao",""},{"DIAS","","Atraso Dt Lib","@E 9999"},{"DIASP","","Atraso Dt Prog","@E 9999"},{"ESPE","","Qtde. Esp.",""},{"ESTO","","Estoque",""},{"BORP","","Bor. Pedidos",""},{"BORD","","Bor. Desp.",""},{"DTDESP","","Dt a Despachar",""}},.F.,,{024, 003, 285, 347},,, oDlg1Con ) 
     oBrw1Con:oBrowse:nFreeze := 3
     oCBox1Co   := TComboBox():New( 007, 150, {|u| If(PCount()>0,nCBox1Co:=u,nCBox1Co)},{"Pedido", "Atraso"}, 056, 016,oDlg1Con,,,,CLR_BLACK,CLR_WHITE,.T.,oFont1Co,"",,,,,,,nCBox1Co )
     oCBox1Co:bChange := {|| DbSelectArea("TMPCON"), DBSetOrder(oCBox1Co:nAt), oBrw1Con:oBrowse:Refresh(), DbGoTop() }

     oBtn2Con   := TButton():New( 006, 209, "Filtra" , oDlg1Con, {|| MsAguarde( {|| oTbl1Tmp("F") }, "Aguarde", "Buscando informações...")  }, 032, 012, , , , .T., , "", , , , .F. )
     oBtn3Con   := TButton():New( 006, 244, "Imprime", oDlg1Con, {|| u_BRFATR16("C") }                                                       , 032, 012, , , , .T., , "", , , , .F. )
     oBtn4Con   := TButton():New( 006, 279, "Observ.", oDlg1Con, {|| fMonObs()       }                                                       , 032, 012, , , , .T., , "", , , , .F. )
     oBtn1Con   := TButton():New( 006, 314, "Sair"   , oDlg1Con, {|| oDlg1Con:End() }                                                        , 032, 012, , , , .T., , "", , , , .F. )
     oDlg1Con:Activate(, , , .T.)
     DbSelectArea("TMPCON")
     DbCloseArea()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1Tmp() - Cria temporario para o Alias: TMPCON
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1Tmp(cTipCha)
       Local aFds := {}
       Local cTmp,cLibCre,dLibCre
       Local cQry := ""
	   
	   If SELECT( "TMPCON" ) <> 0
           DbSelectArea("TMPCON")
           DbCloseArea()
       Endif

       If cTipCha $ 'C'
          Aadd( aFds , {"PEDI", "C", 006, 000} )
          Aadd( aFds , {"CODC", "C", 006, 000} )
          Aadd( aFds , {"NOME", "C", 040, 000} )
          Aadd( aFds , {"FLAG", "C", 003, 000} )
          Aadd( aFds , {"PEDP", "D", 008, 000} )
          Aadd( aFds , {"EMIS", "D", 008, 000} )
          Aadd( aFds , {"LIBC", "D", 008, 000} )
          Aadd( aFds , {"DIAS", "N", 005, 000} )
          Aadd( aFds , {"DIASP", "N", 005, 000} )
          Aadd( aFds , {"DIIN", "C", 005, 000} )
          Aadd( aFds , {"ESPE", "N", 003, 000} )
          Aadd( aFds , {"ESTO", "N", 003, 000} )
          Aadd( aFds , {"BORP", "C", 006, 000} )
          Aadd( aFds , {"BORD", "C", 006, 000} )
          Aadd( aFds , {"ESTA", "C", 002, 000} )
          Aadd( aFds , {"REPR", "C", 025, 000} )
          Aadd( aFds , {"DTDESP", "D", 008, 000} )

          oTempTable := FWTemporaryTable():New( 'TMPCON' )
          oTemptable:SetFields( aFds )
          oTempTable:AddIndex( "cTmp_1", { "PEDI" } )
          oTempTable:AddIndex( "cTmp_2", { "DIIN" } )
          oTempTable:Create()


//          cTmp := CriaTrab( , .F. )
//          dbcreate(cTmp+".dbf", aFds, "DBFCDXADS")
//          Use (cTmp+".Dbf") Alias TMPCON VIA "DBFCDXADS" New Exclusive
//          DbCreateIndex(cTmp+"_1.cdx", "PEDI", {||"PEDI"} )
//          DbCreateIndex(cTmp+"_2.cdx", "DIIN", {||"DIIN"} )
//          DbClearInd()
//          DbSetIndex(cTmp+"_1")
//          DbSetIndex(cTmp+"_2")
//          DbSetOrder(1)
 
       Else
          DbSelectArea("TMPCON")
          Zap
       Endif
       
	   cQry := ""
       cQry += "SELECT SC5.C5_NUM, SC5.C5_CLIENTE, SA1.A1_NOME, SC5.C5_FLAG, SA1.A1_EST, SA1.A1_VEND, "
       cQry += "       'PED_PRO' = CASE WHEN SC5.C5_PEDPROG = '' THEN '' ELSE CONVERT(VARCHAR(10), ISNULL(CAST(ISNULL(SC5.C5_PEDPROG, '') AS DATETIME), ''), 103) END, "
       cQry += "       'EMISSAO' = CONVERT(VARCHAR(10), CAST(SC5.C5_EMISSAO AS DATETIME), 103), "
       cQry += "       'LIB_CRE' = (SELECT MAX(C9_DTLCRED) "
       cQry += "                    FROM "+RETSQLNAME("SC9")+" SC9 WITH (NOLOCK) "
       cQry += "                    WHERE SC9.C9_FILIAL = SC5.C5_FILIAL "
       cQry += "                       AND SC9.D_E_L_E_T_ = '' "
       cQry += "                       AND SC9.C9_PEDIDO = SC5.C5_NUM), "
	/*
       cQry += "       'LIB_CRE' = (SELECT CONVERT(VARCHAR(10), CAST(SC9.C9_DTLCRED AS DATETIME), 103) AS QTD_ESP "
       cQry += "                    FROM "+RETSQLNAME("SC9")+" SC9 WITH (NOLOCK) "
       cQry += "                    WHERE SC9.C9_FILIAL = SC5.C5_FILIAL "
       cQry += "                       AND SC9.D_E_L_E_T_ = '' "
       cQry += "                       AND SC9.C9_PEDIDO = SC5.C5_NUM "
       cQry += "                    GROUP BY SC9.C9_DTLCRED), "
*/       
       cQry += "       'QTD_ESP' = (SELECT COUNT(SB2.B2_LOCALIZ) AS QTD_ESP "
       cQry += "                    FROM "+RETSQLNAME("SC9")+" SC9 WITH (NOLOCK) "
       cQry += "                    LEFT OUTER JOIN SB1010 SB1 WITH (NOLOCK) ON (SB1.B1_FILIAL = SC9.C9_FILIAL) AND (SB1.B1_COD = SC9.C9_PRODUTO) AND (SB1.D_E_L_E_T_ = '') "
       cQry += "                    LEFT OUTER JOIN SB2010 SB2 WITH (NOLOCK) ON (SB2.B2_FILIAL = SC9.C9_FILIAL) AND (SB2.B2_COD = SB1.B1_COD) AND (SB2.B2_LOCAL = SB1.B1_LOCPAD) AND (SB2.D_E_L_E_T_ = '') "
       cQry += "                    WHERE SC9.C9_FILIAL = SC5.C5_FILIAL "
       cQry += "                       AND SC9.D_E_L_E_T_ = '' "
       cQry += "                       AND SC9.C9_PEDIDO = SC5.C5_NUM "
       cQry += "                       AND SB2.B2_LOCALIZ = ''), "
       cQry += "       'QTD_EST' = (SELECT COUNT(SB2.B2_LOCALIZ) AS QTD_EST "
       cQry += "                    FROM "+RETSQLNAME("SC9")+" SC9 WITH (NOLOCK) "
       cQry += "                    LEFT OUTER JOIN SB1010 SB1 WITH (NOLOCK) ON (SB1.B1_FILIAL = SC9.C9_FILIAL) AND (SB1.B1_COD = SC9.C9_PRODUTO) AND (SB1.D_E_L_E_T_ = '') "
       cQry += "                    LEFT OUTER JOIN "+RETSQLNAME("SB2")+" SB2 WITH (NOLOCK) ON (SB2.B2_FILIAL = SB1.B1_FILIAL) AND (SB2.B2_COD = SB1.B1_COD) AND (SB2.B2_LOCAL = SB1.B1_LOCPAD) AND (SB2.D_E_L_E_T_ = '') "
       cQry += "                    WHERE SC9.C9_FILIAL = SC5.C5_FILIAL "
       cQry += "                       AND SC9.D_E_L_E_T_ = '' "
       cQry += "                       AND SC9.C9_PEDIDO = SC5.C5_NUM "
       cQry += "                       AND SB2.B2_LOCALIZ <> ''), "
       cQry += "       'BOR_PED' = (SELECT TOP 1 SZG.ZG_CODIGO "
       cQry += "                    FROM "+RETSQLNAME("SZG")+" SZG WITH (NOLOCK) "
       cQry += "                    WHERE SZG.ZG_FILIAL = SC5.C5_FILIAL "
       cQry += "                      AND SZG.ZG_PEDIDO = '"+substr(cNumEmp,1,2)+"'+SC5.C5_NUM "
       cQry += "                      AND SZG.D_E_L_E_T_ = ''), "
       cQry += "       'BOR_DES' = (SELECT TOP 1 SZB.ZB_CODIGO+ZA_DTDESPA AS CODDT "
       cQry += "                    FROM "+RETSQLNAME("SZB")+" SZB WITH (NOLOCK) "+;
       								"LEFT OUTER JOIN "+RETSQLNAME("SZA")+" SZA WITH (NOLOCK) ON (SZA.D_E_L_E_T_ <> '*') AND (ZB_FILIAL = ZA_FILIAL) AND (ZB_CODIGO = ZA_CODIGO) "
       cQry += "                    WHERE SZB.ZB_FILIAL = SC5.C5_FILIAL "
       cQry += "                      AND SZB.ZB_PEDIDO = '"+substr(cNumEmp,1,2)+"'+SC5.C5_NUM "
       cQry += "                      AND SZB.D_E_L_E_T_ = '') "
       cQry += "FROM "+RETSQLNAME("SC5")+" SC5 WITH (NOLOCK) "
       cQry += "LEFT OUTER JOIN "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_COD = SC5.C5_CLIENT AND SA1.D_E_L_E_T_ = '' "
       cQry += "WHERE SC5.C5_FILIAL  = '"+xFilial("SC5")+"' "
       cQry += "  AND SC5.D_E_L_E_T_ = '' "
       //cQry += "  AND SC5.C5_APROVA  = '1' "
       cQry += "  AND SC5.C5_LIBPED ='T' AND SC5.C5_LIBCRE ='T' AND SC5.C5_LIBDIR ='T' " // pegar os pedidos que estão aprovados e não estão atualizando o c5_aprova =1 
       cQry += "  AND SC5.C5_NOTA    = '' "
       cQry += "  AND SC5.C5_TIPO    = 'N' "
       cQry += "ORDER BY 1 "
       TCQuery cQry ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       While !Eof()              
       		cLibCre := TCQ->LIB_CRE
       		dLibCre := ctod(substr(cLibCre,7,2)+'/'+substr(cLibCre,5,2)+'/'+substr(cLibCre,1,4))
             If dLibCre >= dGet1Con .and. dLibCre <= dGet2Con
             Else
                DbSelectArea("TCQ")
                DbSkip()
                Loop
             Endif
             RecLock("TMPCON", .t.)
                TMPCON->PEDI := TCQ->C5_NUM
                TMPCON->CODC := TCQ->C5_CLIENTE
                TMPCON->NOME := TCQ->A1_NOME
                TMPCON->FLAG := Iif(TCQ->C5_FLAG $ 'S', 'SIM', 'NÂO')
                TMPCON->PEDP := CTOD(TCQ->PED_PRO)
                TMPCON->EMIS := CTOD(TCQ->EMISSAO)
                TMPCON->LIBC := dLibCre //CTOD(TCQ->LIB_CRE)
                TMPCON->DIAS := Iif(Empty(TCQ->LIB_CRE), 0, dDataBase - dLibCre)
                TMPCON->DIASP := Iif(Empty(TCQ->PED_PRO), Iif(Empty(TCQ->LIB_CRE), 0, dDataBase - dLibCre), dDataBase - CTOD(TCQ->PED_PRO))
                TMPCON->DIIN := Inverte( StrZero( Iif(Empty(TCQ->LIB_CRE), 0, dDataBase - dLibCre), 5) )
                TMPCON->ESPE := TCQ->QTD_ESP
                TMPCON->ESTO := TCQ->QTD_EST
                TMPCON->BORP := TCQ->BOR_PED
                TMPCON->BORD := SUBSTR(TCQ->BOR_DES,1,6)
                TMPCON->ESTA := TCQ->A1_EST
                TMPCON->REPR := ALLTRIM(TCQ->A1_VEND)+' - '+Posicione("SA3", 1, xFilial("SA3")+TCQ->A1_VEND, "A3_NREDUZ")
                TMPCON->DTDESP := CTOD(SUBSTR(TCQ->BOR_DES,13,2)+"/"+SUBSTR(TCQ->BOR_DES,11,2)+"/"+SUBSTR(TCQ->BOR_DES,7,4))
             MsUnLock()
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TMPCON")
       If cTipCha $ 'F'
          DbSetOrder(oBrw1Con:oBrowse:nAt)
       Endif
       DbGoTop()
Return

Static Function fMonObs()
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       Local nOpcO        := 0
       Private cGet1Obs   := TMPCON->PEDI
       Private cGet2Obs   := TMPCON->CODC+'-'+TMPCON->NOME
       Private cGet3Obs   := ""
       Private cMGet1Ob
       Private cMGet2Ob
       Private cSay1Obs   := Space(1)
       Private cSay2Obs   := Space(1)
       Private cSay3Obs   := Space(1)

		dbselectarea("SA1")
		dbsetorder(1)
		dbseek(xFilial("SA1")+SubStr(TMPCON->CODC, 1, 6))
		if found()
			cGet3Obs := TRIM(SA1->A1_DDD)+"-"+SA1->A1_TEL
		endif 
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oFont2Con", "oDlg2Con", "oSay1Obs", "oSay2Obs", "oSay3Obs", "oGet1Obs", "oGet2Obs", "oGet3Obs", "oMGet1Ob")
       SetPrvt("oBtn1Obs")
       DbSelectArea("SC5")
       DbSetOrder(1)
       DbSeek(xFilial("SC5")+TMPCON->PEDI, .t.)
       If Found()
          cMGet2Ob := MSMM(SC5->C5_OBSPED, , , , 3)
       Else
          MsgStop("Pedido não encontrado ou excluido. Verifique!")
          Return
       Endif
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oFont2Con  := TFont():New( "MS Sans Serif",0,-19,,.F.,0,,400,.F.,.F.,,,,,, )
       oDlg2Con   := MSDialog():New( 295,414,610,0990,"Observação",,,.F.,,,,,,.T.,,,.T. )
       oSay1Obs   := TSay():New( 005,004,{||"Pedido:"},oDlg2Con,,oFont2Con,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,012)
       oSay2Obs   := TSay():New( 025,004,{||"Cliente:"},oDlg2Con,,oFont2Con,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,012)
       oSay3Obs   := TSay():New( 005,184,{||"Fone:"},oDlg2Con,,oFont2Con,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,012)
       oGet1Obs   := TGet():New( 004,040,{|u| If(PCount()>0,cGet1Obs:=u,cGet1Obs)},oDlg2Con,036,014,'',,CLR_BLACK,CLR_WHITE,oFont2Con,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGet1Obs",,)
       oGet2Obs   := TGet():New( 024,040,{|u| If(PCount()>0,cGet2Obs:=u,cGet2Obs)},oDlg2Con,248,014,'',,CLR_BLACK,CLR_WHITE,oFont2Con,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGet2Obs",,)
       oGet3Obs   := TGet():New( 004,212,{|u| If(PCount()>0,cGet3Obs:=u,cGet3Obs)},oDlg2Con,075,014,'',,CLR_BLUE,CLR_WHITE,oFont2Con,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGet3Obs",,)
       oMGet1Ob   := TMultiGet():New( 044,004,{|u| If(PCount()>0,cMGet1Ob:=u,cMGet1Ob)},oDlg2Con,284,048,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
       oMGet2Ob   := TMultiGet():New( 096,004,{|u| If(PCount()>0,cMGet2Ob:=u,cMGet2Ob)},oDlg2Con,284,040,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.T.,,,.F.,,  )
       oBtn2Obs   := TButton():New( 140,244, "Sair"    , oDlg2Con, { || nOpcO := 0, oDlg2Con:End() }, 037,012,,,,.T.,,"",,,,.F. )
       oBtn1Obs   := TButton():New( 140,200, "Confirma", oDlg2Con, { || nOpcO := 1, oDlg2Con:End() }, 037,012,,,,.T.,,"",,,,.F. )
       oDlg2Con:Activate(,,,.T.)
       If nOpcO == 1 //Gravar Informação.
          If !Empty(cMGet1Ob)
             cObsMsg := Alltrim(cUserName)+" ("+dToc(dDataBase)+" "+Time()+"):"+Chr(13)+chr(10)
             cObsMsg += Upper(cMGet1Ob)+Chr(13)+chr(10)+Chr(13)+chr(10)
             cObsMsg += cMGet2Ob
             DbSelectArea("SC5")
             DbSetOrder(1)
             DbSeek(xFilial("SC5")+TMPCON->PEDI, .t.)
             If Found()
                MSMM(SC5->C5_OBSPED, , , cObsMsg, 1, , , "SC5", "C5_OBSPED")
             Endif
          Endif
       Endif
Return
