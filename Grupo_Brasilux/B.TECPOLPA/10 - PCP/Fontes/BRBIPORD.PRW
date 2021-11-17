//#include "PRTODEF.CH"
#include "TOTVS.ch"
#include "protheus.ch"
#include "topconn.ch" 
#include "rwmake.ch"
#INCLUDE "TBICONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                        
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPIPORD 							  º Data ³  28/06/19  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±                  
±±ºDescricao ³ Consulta Status de Ordem de produção que devem passar pelo º±±
±±º          ³ conferência das matérias primas utilizadas na fabricação   º±±
±±º          ³ do suco.  												  º±±
±±º Cleber(15/10/21)->Alteração de Colunas de SC2 pra mostrar nro Ord Servº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TECPOLPA						.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß                                                         
/*/                                                                                                        
User Function BRPIPORD()

Local cTabSx3,cQuery
Private aColunas
   	 Private cAcessos   := ""
   	 Private cRotina    := "BRPIPORD"
     Private cCodUsr    := RetCodUsr()

     Private cCadastro := "Conferência de Empenho das Ordens de Produção"


   	 cRotina  := Stuff(cRotina, Len(cRotina)+1, 10 - Len(cRotina), space(10 - Len(cRotina)))

     Private aRotina   := { {"Pesquisar"               , "AxPesqui    "	, 0, 1} ,;
                            {"Visualizar"              , "AxVisual    "	, 0, 2} ,;
                            {"Separação de Material"   , "U_BIPORD_1()"	, 0, 9} ,;
                            {"Estornar Ultima fase O.P", "U_BIPORD_3()"	, 0, 9} ,;
                            {"Imprime Ordem Separacao ", "U_TCPCP002()"	, 0, 9} ,;
							{"Legenda 			   "   , "U_BIPORD_4()"	, 0, 9}}

//                            {"Imprime ordem coleta "   , "U_BRPIPORD()"	, 0, 9} ,;
			              

     //If u_fRetGrupoUser() $ '000000'  // Estorna todo o processo       
     //   aadd(aRotina, { OemToAnsi("Estorno")  , "AxAltera    ", 0, 4} )
     //Endif
     
     Private aCores    := { {'Empty(SC2->C2_XSTATUS)'   , 'BR_CINZA  '   } ,; // OPS SEM COLETA DE DADOS
                            {'SC2->C2_XSTATUS  $ "1"'   , 'BR_AMARELO'   } ,; // OPS INCIADAS COM BIPE SEPARAÇÃO 
                            {'SC2->C2_XSTATUS  $ "2"'   , 'BR_LARANJA'   } ,; // OPS INICIADAS COM BIPE NA PRODUÇÃO
                            {'SC2->C2_XSTATUS  $ "3"'   , 'BR_VERDE'     }  } // OPS APTAS PARA O APONTAMENTO DE PRODUÇÃO
                            
     Private cString   := "SC2"
	 /*
[n][1]  -->  Descrição do campo
[n][2]  -->  Nome do campo
[n][3]  -->  Tipo do dado: “C” (caracter), “N” (numérico), “D” (data), etc.
[n][4]  -->  Tamanho
[n][5]  -->  Número de casas decimais
[n][6]  -->  Picture (formatação dos dados)
*/
aColunas   := {}
cTabSx3 := "SX3"+substr(cNumEmp,1,2)+"0"
cQuery := "SELECT X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO,X3_PICTURE FROM "+cTabSx3+" SX3 WHERE (D_E_L_E_T_ <> '*') AND (X3_ARQUIVO = 'SC2') AND "+;
"(X3_CAMPO IN ('C2_NUM','C2_ITEM','C2_SEQUEN','C2_PRODUTO','C2_LOCAL','C2_QUANT','C2_XORDSEP')) ORDER BY X3_ORDEM"
TCQUERY cQuery ALIAS "TMPSX3" NEW
DbSelectArea("TMPSX3")
dbgotop()
do while !eof()
	aadd(aColunas,{TMPSX3->X3_TITULO,TMPSX3->X3_CAMPO,TMPSX3->X3_TIPO,TMPSX3->X3_TAMANHO,TMPSX3->X3_DECIMAL,TMPSX3->X3_PICTURE})
 	dbskip()
enddo
DbSelectArea("TMPSX3")
dbclosearea()

	 DbSelectArea("SC2")
     DbSetOrder(1)

     DbSelectArea(cString)
    
     mBrowse(6, 1, 22, 75, cString,aColunas,,,,, aCores)

Return


/*ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclusão e exclusão dos produtos bipados para ord. produção³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function BIPORD_1(nOpc)   // 1 - Separação  / 2 - Produção

     Private cGetOrdS   := Space(06) //"      /    "	// Ordem de Separação cGet1Env para cGetOrdS C2_XORDSEP
     Private cGetOrPr   := Space(11)				    // Ordem de Produção C2_XOP cGet2Env para cGetOrPr
     Private cGetDescP  := Space(45)                    // Descrição do Produto B1_DESC
     Private cGetEtiqu  := Space(10)                    // Etiqueta do produto CB0_CODETI
     Private cGetDesP2  := Space(45)                    // Descrição do Produto da etiqueta B1_DESC
     Private cGetCodPr  := Space(15)					// Código do produto da  etiqueta
     Private cSay6Env   := ""
     Private nCount     := 0
     Private cCor4Env   := 0
     Private _CodProd   := ""
     Private nQtdTotal  := 0
     Private lJaFech    := .f.
     Private lTelaJaFechada := .f.  
  	 Private cRotina    := "BRBIPORD"
  	 Private aCores     :={}
     Private aCpoBro    :={}  
     Private cStAtual   := ""
           
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFontEnv" , "oDlg1Env" , "oGrp1Env", "oSayOrdS", "oSayOrPr", "oGetOrPr", "oGetOrPr", "oGetOrdS", "oSayEtiqu")
     SetPrvt("oGetEtiqu", "oGetDesP2", "oBtn1Env", "oBrw1Env", "oBtn2Env", "oBtn4Env", "oBtn5Env", "oSay7Env", "oSay8Env")
     SetPrvt("oBtnCEnv","oGetCodPr", "oSay6Env")
     
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFontEnv   := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
     oFon2Env   := TFont():New( "Courier New"  , 0,  19, , .T., 0, , 400, .F., .F., , , , , , )
     oFon3Env   := TFont():New( "Courier New"  , 0,  25, , .T., 0, , 400, .F., .F., , , , , , )

     oDlg1Env   := MSDialog():New( 140, 264, 720, 1205, "CONFERÊNCIA DE ITENS EMPENHADOS NA ORDEM DE PRODUÇÃO", , , .F., , , , , , .T., , , .T. )
     
     oGrp1Env   := TGroup():New( 003, 004, 068, 470, "Ordem Separação", oDlg1Env, CLR_RED, CLR_WHITE, .T., .F. )
     oGrp2Env   := TGroup():New( 070, 004, 288, 470, "", oDlg1Env, CLR_BLACK, CLR_WHITE, .T., .F. )
     
     oSayOrdS   := TSay():New( 012, 100, { || "ORD. SEPARAÇÃO:"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 110, 012)
     oGetOrdS   := TGet():New( 010, 200, { |u| If(PCount() > 0, cGetOrdS := u, cGetOrdS)}, oGrp1Env, 080, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGetOrdS", , ) 
          
     oSayOrPr   := TSay():New( 032, 008, { || "Ord. Prod:"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 050, 012)
     oGetOrPr   := TGet():New( 030, 054, { |u| If(PCount() > 0, cGetOrPr  := u, cGetOrPr )}, oGrp1Env, 080, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGetOrPr", , ) 
     oGetDescP  := TGet():New( 030, 136, { |u| If(PCount() > 0, cGetDescP := u, cGetDescP)}, oGrp1Env, 250, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGetDescP", , ) 

     oGetOrPr:bLostFocus := {|| Iif(!Empty(Alltrim(cGetOrPr)),fCarOrdS(cGetOrPr),"")} // Carrega os itens empenhados da OP

     oSayEtiqu  := TSay():New( 052, 008, { || "Etiqueta:"}, oGrp1Env, , oFontEnv, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 012)
     oGetEtiqu  := TGet():New( 050, 054, { |u| If(PCount() > 0, cGetEtiqu  := u, cGetEtiqu )}, oGrp1Env, 080, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGetEtiqu", , ) 

     oGetEtiqu:bLostFocus := {|| Iif(!Empty(Alltrim(cGetEtiqu)),fValEtiq(cGetEtiqu),"")} // 
     
     oGetCodPr  := TGet():New( 050, 136, { |u| If(PCount() > 0, cGetCodPr  := u, cGetCodPr )}, oGrp1Env, 090, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGetCodPr", , ) 
     oGetDesP2  := TGet():New( 050, 228, { |u| If(PCount() > 0, cGetDesP2 := u, cGetDesP2)}, oGrp1Env, 240, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFontEnv,   , , .T., "", , , .F., .F., , .F., .F., "", "cGetDesP2", , ) 

     oBtn1Env   := TButton():New( 009, 400, "Finaliza Fase", oGrp1Env, {|| fAtStatu(cGetOrPr,2) }, 065, 016, , oFontEnv, , .T., , "", , , , .F. )
     oBtn2Env   := TButton():New( 030, 450, "L", oGrp1Env, {|| BIPORD_5()}, 015, 016, , oFontEnv, , .T., , "", , , , .F. )
     
     oBtn5Env   := TButton():New( 072, 392, "<- Estorna Item " , oGrp2Env, {|| BIPORD_2() }, 075, 016, , oFon2Env, , .T., , "", , , , .F. )

     oSay6Env   := TSay():New( 270, 010, { || cSay6Env}  , oGrp1Env, , oFon3Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 240, 012)
     oSay7Env   := TSay():New( 270, 450, { || nCount}    , oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 020, 020)
     oSay8Env   := TSay():New( 270, 345, { || "Total Etiquetas:"}, oGrp2Env, , oFon3Env, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 125, 020)
     
  
     
     oTb2Pall()
     DbSelectArea("TMPITE")
     DbSetOrder(1)
     DbGoTop()
     oBrw1Env                        := MsSelect():New( "TMPITE", "", "", { {"TMPPRO", "", "Produto", "@R XXXXXXXXXXXXXXX"}, {"TMPDESC", "", "Descrição", "@!"}, {"TMPLOT", "", "Lote", "@E XXXXXXXXXXXXXXXX"}, { "TMPQTD", "", "Empenho", "@E 999,999,999.9999"} , {"TMPQTB", "", "Empenho. Bipado", "@E 999,999,999.9999"}, {"TMPQET", "", "Qtd Etiq.", "@E 9999"}, {"TMPTIP", "", "Tipo Separação", "@!"} }, .F.     ,      ,{090, 007, 266, 467}, , , oGrp2Env,, aCores ) 
     oBrw1Env:oBrowse:oFont          := oFon2Env
     oBrw1Env:oBrowse:lAdjustColSize := .t.
     oBrw1Env:oBrowse:Refresh()
   	 //oGetOrPr:Setfocus()
     cGetOrPr := SC2->C2_XOP
  	 fCarOrdS(cGetOrPr)
   	 oGetEtiqu:Setfocus()
     oDlg1Env:Activate(,,,.T.)
   	      
     //If !lJaFech
     //	lTelaJaFechada := .t.
     //   fSairOrS()
     //Endif
     
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ BIPORD_2() Estorna item da ordem de separação
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function BIPORD_2()

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Declaração de cVariable dos componentes                                 ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

	Private cGet1Mnt   := Space(10) 
 	Private cGet2Mnt   := Space(15)  
  	Private nGet3Mnt   := 0 	    
 	Private cGet4Mnt   := Space(45) 
	Private cGet5Mnt   := Space(16)  
     

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
 	±± Declaração de Variaveis Private dos Objetos                             ±±
  	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
   	SetPrvt("oFontMn1", "oFontMn2", "oDlg1Mnt", "oSay1Mnt", "oSay4Mnt", "oSay2Mnt", "oSay3Mnt", "oGet1Mnt", "oGet2Mnt")
    SetPrvt("oGet3Mnt", "oBtn2Mnt", "oBtn1Mnt", "oGet4Mnt", "oSay5Mnt",)
         
 
    If Empty(Alltrim(cGetOrPr))
    	Return
    Endif
    
    //cStAtual := Posicione("SC2", 1, xFilial("SC2")+SubStr(cGetOrPr, 1, 11), "C2_XSTATUS")
    cStAtual := fStAtual(cGetOrPr)

    If !cStAtual $'1.2'
		Messagebox("Não é possível estornar o item nesta fase, verifique !!","Atenção...",48)		
    	Return
    Endif


    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Definicao do Dialog e todos os seus componentes.                        ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    
    oFontMn1   := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
    oFontMn2   := TFont():New( "MS Sans Serif", 0, -16, , .F., 0, , 400, .F., .F., , , , , , )
    oDlg1Mnt   := MSDialog():New( 258, 252, 350, 920, "Estorno da Etiqueta", , , .F., , , , , , .T., , , .T. )
    oSay1Mnt   := TSay():New( 009, 002, {|| "Etiqueta"   }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)
    oGet1Mnt   := TGet():New( 007, 039, {|u| If(PCount() > 0, cGet1Mnt := u, cGet1Mnt)}, oDlg1Mnt, 070, 012, '@!'              , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .F. , .F., ""   ,"cGet1Mnt", , )
    oGet2Mnt   := TGet():New( 007, 113, {|u| If(PCount() > 0, cGet2Mnt := u, cGet2Mnt)}, oDlg1Mnt, 090, 012, '@!'          , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"cGet2Mnt", , )
    oSay3Mnt   := TSay():New( 009, 245, {|| "Qtde"     }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 028, 012)
    oGet3Mnt   := TGet():New( 007, 265, {|u| If(PCount() > 0, nGet3Mnt := u, nGet3Mnt)}, oDlg1Mnt, 070, 012, '@E 999,999,999.9999'       , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"nGet3Mnt", , )
    oSay4Mnt   := TSay():New( 026, 002	, {|| "Descr.:"   }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)                                                                                         
    oGet4Mnt   := TGet():New( 025, 039, {|u| If(PCount() > 0, cGet4Mnt := u, cGet4Mnt)}, oDlg1Mnt, 204, 012, '@!'              , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"cGet4Mnt", , )
    oSay5Mnt   := TSay():New( 026, 245, {|| "Lote"     }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 024, 012)
    oGet5Mnt   := TGet():New( 025, 265, {|u| If(PCount() > 0, cGet5Mnt := u, cGet5Mnt)}, oDlg1Mnt, 070, 012, '@!'       , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T. , .F., ""   ,"cGet5Mnt", , )

    oGet1Mnt:bLostFocus := {|| fEstEtiq(cStAtual) } // 1 - Separação / 2 - Produção

    oDlg1Mnt:Activate( , , , .T.)

Return



/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fEstEtiq() - Estorna Etiqueta Limpar campos (CB0) e (SD4)
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fEstEtiq(cStAtual)

	DbSelectArea('CB0')
	CB0->(DbSetOrder(1))
	CB0->(DbSeek(xFilial("CB0")+cGet1Mnt))
			
	If !CB0->(EOF())
		If ( (Alltrim(CB0->CB0_XORDSE) == Alltrim(cGetOrdS)) .AND.  (Alltrim(CB0->CB0_OP) == Alltrim(cGetOrPr)) )
			
			cGet2Mnt := CB0->CB0_CODPRO
			nGet3Mnt := CB0->CB0_QTDE
			cGet5Mnt := CB0->CB0_LOTE
			
			DbSelectArea('SB1')
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("CB0")+CB0->CB0_CODPRO))
			If !SB1->(EOF())
				cGet4Mnt := SB1->B1_DESC			
				If !SB1->B1_NAOSEPA $ '1.3'

					Messagebox("Esse produto não foi bipado, portanto não pode ser estornado, verifique !!","Atenção...",48)		

					DbSelectArea('SB1')
					DbCloseArea()

					DbSelectArea('CB0')
					DbCloseArea()
					oGet1Mnt:Setfocus()
					Return
				Endif					
			Endif
			
			If Alltrim(CB0->CB0_XSTATUS) <> Alltrim(cStAtual)
				Messagebox("Não é possível estornar esta etiqueta, já que o Status do Produto e da Op estão diferentes !!","Atenção...",48)	
				DbSelectArea('CB0')
				DbCloseArea()
				oGet1Mnt:Setfocus()
				Return
			Endif
			
			If MsgYesNo("Confirma a operação de estorno da etiqueta bipada ? Produto -> '"+(CB0->CB0_CODPRO)+"' ?", "Estorno da Etiqueta ->"+CB0->CB0_CODETI )	  
			
				Begin Transaction
					DbSelectArea("SD4")
					DbOrderNickName("SD48")
					//DbSetOrder(8)       // D4_FILIAL+D4_OP+D4_COD+D4_LOTECTL+D4_TRT        
					DbSeek(xFilial("SD4")+(Alltrim(CB0->CB0_OP) + Space(14 - Len(Alltrim(CB0->CB0_OP))))+CB0->CB0_CODPRO+CB0->CB0_LOTE)
			
					If !SD4->(EOF())
						RecLock('SD4', .F.)
							SD4->D4_XSTATUS := Iif(cStAtual=='1','','1')
						MsUnLock()		    				
					Endif
			
					DbSelectArea("SD4")
					DbCloseArea()
			
					RecLock('CB0', .F.)
						If cStAtual == '1'
							CB0->CB0_XUSRSE :=	""
							CB0->CB0_XDTSEP :=	CTOD("  /  /    ")
							CB0->CB0_XHRSEP :=	""
							CB0->CB0_XSTATU :=  ""
							CB0->CB0_OP     :=  ""
							CB0->CB0_XORDSE :=  ""
						Else
							CB0->CB0_XUSRPR :=	""
							CB0->CB0_XDTPRO :=	CTOD("  /  /    ")
							CB0->CB0_XHRPRO :=	""
							CB0->CB0_XSTATU :=  '1'
							If Empty(Alltrim(CB0->CB0_XUSRSE)) // se não foi bipado na separação (ajuste de fórmula), excluir dados de ordem de separação e ordem de produção
								CB0->CB0_OP     :=  ""
								CB0->CB0_XORDSE :=  ""
							Endif	
						Endif
					MsUnlock()
			
				End Transaction
				oGet1Mnt:Setfocus()
				fAtStatu(cGetOrPr,1) // Atualiza Status da SD4
				fCarOrdS(cGetOrPr) // Atualiza legendas
			Endif
		Else
			If Empty(Alltrim(CB0->CB0_XORDSE)) .or. Empty(Alltrim(CB0->CB0_OP))
				Messagebox("Esta não foi bipada nesta ordem de separação ou já foi estornada !!","Atenção...",48)
			Else
				Messagebox("Esta etiqueta esta bipada para outra ordem de produção --> "+CB0->CB0_OP+" / ord. separação --> "+CB0->CB0_XORDSE+" !!","Atenção...",48)
			Endif		
		Endif
	Endif

	DbSelectArea("CB0")
	DbCloseArea()


Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ BIPORD_3() - Estorna a ordem de produção especificada
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

User Function BIPORD_3()

Local cQry1 :=""
Local cQry2 :=""
Local cQry3 :=""
Local lSucesso := .t.
cStAtual := SC2->C2_XSTATUS

If SC2->C2_XSTATUS $'1.2.3' 

	If MsgYesNo("Confirma a operação de estorno da ordem de Produção '"+(SC2->C2_XOP)+"' ?", "Estorno da O.P" )	  
   			
   		Begin Transaction
   	
   			cQry1 := ""
   			If SC2->C2_XSTATUS $ '1.2'
   				cQry1 += " UPDATE "+RetSqlName("CB0")+" SET CB0_OP ='', CB0_XORDSE ='', CB0_XUSRPR ='', CB0_XDTPRO= '', CB0_XHRPRO ='', CB0_XUSRSE ='', CB0_XDTSEP ='', CB0_XHRSEP ='', CB0_XSTATU ='' "
   			ElseIf SC2->C2_XSTATUS == '3'
   				cQry1 += " UPDATE "+RetSqlName("CB0")+" SET CB0_XUSRPR ='', CB0_XDTPRO= '', CB0_XHRPRO ='', CB0_XSTATU ='1'"
   			Endif
   			cQry1 += " FROM "+RetSqlName("CB0")+" CB0 LEFT OUTER JOIN "+RetSqlName("SD4")+" SD4 ON D4_FILIAL = CB0_FILIAL AND D4_OP = CB0_OP AND D4_COD = CB0_CODPRO AND D4_LOTECTL = CB0_LOTE AND SD4.D_E_L_E_T_ ='' "
   			cQry1 += " WHERE CB0.D_E_L_E_T_ ='' AND CB0_FILIAL ='"+xFilial("CB0")+"' AND CB0_OP ='"+(SC2->C2_XOP)+"'"
			lSucesso := (TcSQLExec(cQry1) >= 0)
			If !lSucesso
				MsgStop(TcSqlError())
				DisarmTrans()
			else 
   				
				cQry2 := ""
				cQry2 += " UPDATE "+RetSqlName("SD4")+" SET D4_XSTATUS ='"+Iif(SC2->C2_XSTATUS $'1.2','','1')+"' FROM "+RetSqlName("SD4")+" SD4 WHERE SD4.D_E_L_E_T_ ='' AND D4_FILIAL ='"+xFilial("SD4")+"' AND D4_OP ='"+(SC2->C2_XOP)+"' AND D4_XSTATUS <>''"
				lSucesso := (TcSQLExec(cQry2) >= 0)
				If !lSucesso
					MsgStop(TcSqlError())
					DisarmTrans()
				else 

					cQry3 := ""
					cQry3 += " UPDATE "+RetSqlName("SC2")+" SET C2_XSTATUS ='"+Iif(SC2->C2_XSTATUS $ '3','2','1')+"' WHERE (C2_FILIAL ='"+xFilial("SC2")+"') AND (D_E_L_E_T_ = '') AND C2_XOP ='"+(SC2->C2_XOP)+"'" 
					lSucesso := (TcSQLExec(cQry3) >= 0)
					If !lSucesso
						MsgStop(TcSqlError())
						DisarmTrans()
					Endif 
				Endif 
			Endif 
       	
       	End Transaction
		if lSucesso 
       		MsgInfo("Ordem de Produção "+SC2->C2_XOP+" estornada com Sucesso !!!", 'Estorno de O.P')
		endif 

    Endif
Else
   	MsgInfo("Status atual da Ordem de Produção "+SC2->C2_XOP+" não permite estorno, ou não foi dado inicio a separação !!!", 'Estorno de O.P')

Endif
    


Return




/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fSairOrS() Fechar Janela e Excluir tabela temporária
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fSairOrS()

    If !lTelaJaFechada
	    oDlg1Env:End()
    Endif
//    DbSelectArea("TMPITE")
//    oTempTable:Delete()
    
Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTb2Pall() - Cria temporario para o Alias: TMPITE
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTb2Pall()

Local aFields := {}
Local oTempTable
Local cAlias := "TMPITE"
//-------------------
//Criação do objeto
//-------------------
If ChkFile("TMPITE") 
	DbSelectArea("TMPITE")
    DbClosearea()
Endif


oTempTable := FWTemporaryTable():New( cAlias )
//--------------------------
//Monta os campos da tabela
//--------------------------

aAdd(aFields, {"TMPPRO" , "C", 15, 0} )
aAdd(aFields, {"TMPDESC", "C", 45, 0} )
aAdd(aFields, {"TMPLOT" , "C", 16, 0} )
aAdd(aFields, {"TMPQTD" , "N", 14, 4} )
aAdd(aFields, {"TMPQTB" , "N", 14, 4} )
aAdd(aFields, {"TMPQET" , "N",  4, 0} )
aAdd(aFields, {"TMPSTA" , "C",  1, 0} )
aAdd(aFields, {"TMPTIP" , "C",  8, 0} ) // BIPA / Nao BIPA / VALIDA


oTemptable:SetFields( aFields )
//oTempTable:AddIndex("01", {"TMPETI"} )
oTempTable:AddIndex("01", {"TMPPRO", "TMPLOT"}) 

//------------------
//Criação da tabela
//------------------
oTempTable:Create()

aAdd(aCores,{"TMPITE->TMPSTA == ' '","BR_CINZA"	  })
aAdd(aCores,{"TMPITE->TMPSTA == '1'","BR_AMARELO" })
aAdd(aCores,{"TMPITE->TMPSTA == '2'","BR_LARANJA" }) 
aAdd(aCores,{"TMPITE->TMPSTA == '3'","BR_VERDE"   })
//------------------------------------
//Executa query para leitura da tabela
//------------------------------------
/*
cQuery := "select * from "+ oTempTable:GetRealName()
MPSysOpenQuery( cQuery, 'QRYTMP' )
DbSelectArea('QRYTMP')
while !eof()
    for nI := 1 to fcount()
        varinfo(fieldname(nI),fieldget(ni))
    next
    dbskip()
Enddo
*/     
//---------------------------------
//Exclui a tabela
//---------------------------------
//oTempTable:Delete()
// If ChkFile("TMPITE")
//	DbSelectArea("TMPITE")
//    DbCloseArea()
//Endif
Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fCarOrdS() - Carrega os itens empenhados da Ordem de Produção
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fCarOrdS(cNumOP)

	If Empty(Alltrim(cNumOP)) .or. Len(Alltrim(cNumOP)) <> 11
		oGetOrPr:Setfocus()
		Return
	Endif

	cStAtual := Posicione("SC2", 1, xFilial("SC2")+SubStr(cNumOP, 1, 11), "C2_XSTATUS")
	
	If Empty(Alltrim(Posicione("SC2", 1, xFilial("SC2")+SubStr(cNumOP, 1, 11), "C2_XORDSEP")))
		Messagebox("Não foi gerada ordem de separação para a O.p Específicada, verifique !!","Atenção...",48)		
		oGetOrPr:Setfocus()
		Return
	Endif

	If !(cStAtual) $ '1.2.3' 
		Messagebox("Status de separação da O.p inválido, deve ser Separação ou Produção, verifique !!","Atenção...",48)		
		oGetOrPr:Setfocus()
		Return
	Endif

	If ChkFile("TMPITE")
		DbSelectArea("TMPITE")
		DbGoTop()
		Zap
	Endif

    nCount :=0

    cQry1 := ""
    cQry1 += " SELECT C2_XOP, C2_PRODUTO, C2_XORDSEP, D4_COD, B1_DESC, B1_NAOSEPA, D4_QUANT, D4_LOTECTL, " 
    cQry1 += " CASE WHEN D4_XSTATUS =''  AND B1_NAOSEPA ='2' THEN C2_XSTATUS ELSE " 
    cQry1 += " CASE WHEN D4_XSTATUS <>'' AND B1_NAOSEPA <>'2' AND C2_XSTATUS ='3' THEN C2_XSTATUS ELSE D4_XSTATUS END END AS D4_XSTATUS, "
    cQry1 += " C2_XSTATUS, ISNULL(SUM(CB0_QTDE),0) AS CB0_QTDE, COUNT(CB0.R_E_C_N_O_) AS 'ITENSBIPADOS', "  
    cQry1 += " CASE WHEN B1_NAOSEPA IN('1') THEN 'BIPA' ELSE CASE WHEN B1_NAOSEPA IN('','2') THEN 'NAO BIPA' ELSE 'VALIDA' END END AS 'TIPOPRO' " 
    cQry1 += " FROM "+RetSqlName("SC2")+" SC2 WITH(NOLOCK) " 
    cQry1 += " LEFT OUTER JOIN "+RetSqlName("SD4")+" SD4 WITH(NOLOCK) ON D4_FILIAL = C2_FILIAL AND D4_OP = C2_XOP AND SD4.D_E_L_E_T_ ='' "
    cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = D4_FILIAL AND B1_COD = D4_COD AND SB1.D_E_L_E_T_ ='' "
    cQry1 += " LEFT OUTER JOIN "+RetSqlName("CB0")+" CB0 WITH(NOLOCK) ON CB0_FILIAL = D4_FILIAL AND CB0_OP = D4_OP AND CB0_CODPRO = D4_COD AND CB0_LOTE = D4_LOTECTL AND C2_XSTATUS = CB0_XSTATU AND CB0.D_E_L_E_T_ =''  "
    cQry1 += " WHERE SC2.D_E_L_E_T_ ='' "
    cQry1 += " AND C2_FILIAL ='"+XFILIAL("SC2")+"'"
    cQry1 += " AND C2_XOP ='"+cNumOp+"'"
    cQry1 += " AND B1_TIPO <>'MO' "
    cQry1 += " GROUP BY C2_XOP, C2_PRODUTO, C2_XORDSEP, D4_COD, B1_DESC, B1_NAOSEPA, D4_QUANT, D4_LOTECTL, D4_XSTATUS, C2_XSTATUS" 
    cQry1 += " ORDER BY D4_COD "     
    
    //TCQuery cQry1 ALIAS "TCQ" NEW
    MPSysOpenQuery( cQry1, 'TCQ' )
    DbSelectArea("TCQ")

    If !Eof()
  		cGetOrdS := TCQ->C2_XORDSEP
		cGetDescP:= Posicione("SB1", 1, xFilial("SB1")+TCQ->C2_PRODUTO, "B1_DESC")
	    While !Eof()
    		RecLock("TMPITE", .T.)
				TMPITE->TMPPRO := TCQ->D4_COD
				TMPITE->TMPDESC:= TCQ->B1_DESC
				TMPITE->TMPLOT := TCQ->D4_LOTECTL
        	    TMPITE->TMPQTD := TCQ->D4_QUANT
	            TMPITE->TMPQTB := TCQ->CB0_QTDE
	            TMPITE->TMPQET := TCQ->ITENSBIPADOS
				TMPITE->TMPSTA := TCQ->D4_XSTATUS
				TMPITE->TMPTIP := TCQ->TIPOPRO
				nCount := (TCQ->ITENSBIPADOS+nCount)
			MsUnLock()
	        DbSelectArea("TCQ")
	        DbSkip()
		Enddo
		oGetEtiqu:Setfocus()
		oGetOrdS:Disable()

	Else
		Messagebox("Ordem de Produção inválida, verifique o número digitado !!","Atenção...",48)		
		oGetOrPr:Setfocus()
    Endif
    DbSelectArea("TCQ")
	DbCloseArea()    
  
    If ChkFile("TMPITE")
   	    DbSelectArea("TMPITE")
        DbGoTop()
	    oBrw1Env:oBrowse:GoTop()
    	oBrw1Env:oBrowse:Refresh()
    Endif	
	
	If cStAtual == '1'
		cSay6Env := "CONFERÊNCIA EM FASE DE SEPARAÇÃO"
	ElseIf cStAtual == '2'
		cSay6Env := "CONFERÊNCIA EM FASE DE PRODUÇÃO"
	ElseIf cStAtual == '3'
		cSay6Env := "CONFERÊNCIA CONCLUÍDA"
	Else
		cSay6Env := ""
	Endif
	oSay6Env:Refresh()	
    cGetEtiqu := space(10)
    oGetEtiqu:Refresh()
    cGetDesP2 := space(30)
    oGetDesP2:Refresh()
    cGetCodPr := space(15)
    oGetCodPr:Refresh()

Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fValEtiq() - Valida o código da etiqueta CB0
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fValEtiq(cGetEtiqu)

Local Atualiza := .f.
Local cQry 	   := ""
//Local cStAtual := ""


If (Empty(Alltrim(cGetEtiqu)) .or. Len(Alltrim(cGetEtiqu)) <> 10)  
	oGetEtiqu:Setfocus()
	Return
Endif

If Empty(Alltrim(cGetOrPr)) .or. Len(Alltrim(cGetOrPr)) <> 11
	oGetOrPr:Setfocus()
	Return
Endif

cStAtual := Posicione("SC2", 1, xFilial("SC2")+SubStr(cGetOrPr, 1, 11), "C2_XSTATUS")
//cStAtual := fStAtual(cGetOrPr)

If !cStAtual $'1.2'
	oGetEtiqu:Setfocus()
	Return
Endif

DbSelectArea('CB0')
CB0->(DbSetOrder(1))
CB0->(DbSeek(xFilial("CB0")+cGetEtiqu))
			
If !CB0->(EOF())
	If (Empty(Alltrim(CB0->CB0_OP)) .and. Empty(Alltrim(CB0->CB0_XORDSE))) .or.  (Alltrim(CB0->CB0_OP) == Alltrim(cGetOrPr) )

		cGetCodPr := CB0->CB0_CODPRO
		cGetDesP2 := Posicione("SB1", 1, xFilial("SB1")+CB0->CB0_CODPRO, "B1_DESC")

		If ChkFile("TCQ")
			DbSelectArea("TCQ")
		    DbCloseArea()
		Endif

		cQry :="" 
		cQry +=" SELECT C2_XOP, C2_PRODUTO, C2_XORDSEP, D4_COD, B1_DESC, B1_NAOSEPA, D4_QUANT, D4_LOTECTL, C2_XSTATUS, ISNULL(SUM(CB0_QTDE),0) AS CB0_QTDE, COUNT(CB0.R_E_C_N_O_) AS 'ITENSBIPADOS', " 
		cQry +=" CASE WHEN D4_XSTATUS ='' AND  B1_NAOSEPA ='2' THEN C2_XSTATUS ELSE D4_XSTATUS END AS D4_XSTATUS "
		cQry +=" FROM "+RetSqlName("SC2")+" SC2 WITH(NOLOCK) "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SD4")+" SD4 WITH(NOLOCK) ON D4_FILIAL = C2_FILIAL AND D4_OP = C2_XOP AND SD4.D_E_L_E_T_ ='' "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = D4_FILIAL AND B1_COD = D4_COD AND SB1.D_E_L_E_T_ =''" 
		cQry +=" LEFT OUTER JOIN "+RetSqlName("CB0")+" CB0 WITH(NOLOCK) ON CB0_FILIAL = D4_FILIAL AND CB0_OP = D4_OP AND CB0_CODPRO = D4_COD AND CB0_LOTE = D4_LOTECTL AND CB0.D_E_L_E_T_ =''  "
		If cStAtual <>'1'
			cQry +=" AND C2_XSTATUS = CB0_XSTATU "
		Endif
		cQry +=" WHERE SC2.D_E_L_E_T_ ='' "
		cQry +=" AND C2_FILIAL ='"+XFILIAL("SC2")+"'"
		cQry +=" AND C2_XOP ='"+cGetOrPr+"'"
		cQry +=" AND D4_COD ='"+CB0->CB0_CODPRO+"'"
		cQry +=" AND D4_LOTECTL ='"+CB0->CB0_LOTE+"'"
		cQry +=" AND B1_TIPO <>'MO' "
		cQry +=" GROUP BY C2_XOP, C2_PRODUTO, C2_XORDSEP, D4_COD, B1_DESC, B1_NAOSEPA, D4_QUANT, D4_LOTECTL, D4_XSTATUS, C2_XSTATUS" 
		cQry +=" ORDER BY D4_COD "     
		
		TCQuery cQry ALIAS "TCQ" NEW
		DbSelectArea("TCQ")		 		
		
		If !Eof() 
			If TCQ->C2_XSTATUS $ '1.2' .and. TCQ->B1_NAOSEPA $ '1.3' // se a o.p esta em fase de separação e produto deve ser bipado
				DbSelectArea("SD4")
				DbOrderNickName("SD48")
				//DbSetOrder(8)       // D4_FILIAL+D4_OP+D4_COD+D4_LOTECTL+D4_TRT        
				DbSeek(xFilial("SD4")+(Alltrim(TCQ->C2_XOP) + Space(14 - Len(Alltrim(TCQ->C2_XOP))))+CB0->CB0_CODPRO+CB0->CB0_LOTE)
				If !SD4->(EOF()) .AND. (SD4->D4_FILIAL == xFilial("SD4")) .AND. (SD4->D4_OP = cGetOrPr) .AND. (SD4->D4_COD == CB0->CB0_CODPRO) .AND. (SD4->D4_LOTECTL == CB0->CB0_LOTE)
					//Do While !Eof()  
						If TCQ->B1_NAOSEPA $ '1'
							If  (TCQ->CB0_QTDE + CB0->CB0_QTDE) < TCQ->D4_QUANT
								Atualiza := .t.
							ElseIf (TCQ->CB0_QTDE + CB0->CB0_QTDE) == TCQ->D4_QUANT 
								RecLock('SD4', .F.)
									SD4->D4_XSTATUS := TCQ->C2_XSTATUS
								MsUnLock()		    				
								Atualiza := .t.
							Elseif (TCQ->CB0_QTDE + CB0->CB0_QTDE) > TCQ->D4_QUANT
								Messagebox("Quantidade na etiqueta bipada ultrapassa o total empenhado. Total empenhado( "+TransForm(SD4->D4_QUANT,"@E 999,999,999.9999")+" ) !!, Verifique !!","Atenção...",48)
								oGetEtiqu:Setfocus()
								DbSelectArea("TCQ")
								DbCloseArea()
								Return
							Endif
						Elseif TCQ->B1_NAOSEPA $ '3'
							If (TCQ->CB0_QTDE + CB0->CB0_QTDE) < TCQ->D4_QUANT 
								Atualiza := .t.
							Elseif (TCQ->CB0_QTDE + CB0->CB0_QTDE) >= TCQ->D4_QUANT	
								RecLock('SD4', .F.)
									SD4->D4_XSTATUS := TCQ->C2_XSTATUS
								MsUnLock()
								Atualiza := .t.
							Endif		    				
						Endif	
						If Atualiza 
							RecLock('CB0', .F.)
								If TCQ->C2_XSTATUS == '1'
									CB0->CB0_XUSRSE :=	RetCodUsr()										// usuário que bipou em fase separação
									CB0->CB0_XDTSEP :=	Date()											// data em que a etiqueta foi bipada
									CB0->CB0_XHRSEP :=	SubStr(Time(), 1, 2)+':'+SubStr(Time(), 4, 2)	// hora em que a etiqueta foi bipada
									CB0->CB0_XSTATU :=  '1'
								Else
									CB0->CB0_XUSRPR :=	RetCodUsr()										// usuário que bipou em fase de produção
									CB0->CB0_XDTPRO :=	Date()											// data em que a etiqueta foi bipada
									CB0->CB0_XHRPRO :=	SubStr(Time(), 1, 2)+':'+SubStr(Time(), 4, 2)	// hora em que a etiqueta foi bipada
									CB0->CB0_XSTATU :=  '2'
								Endif
								If Empty(Alltrim(CB0->CB0_XORDSE)) .or. Empty(Alltrim(CB0->CB0_OP))  
									CB0->CB0_XORDSE := cGetOrdS  											// número ordem de separação
									CB0->CB0_OP     := cGetOrPr  											// número ordem de produção
								Endif
							MsUnLock()	
						Else
							Messagebox("Divergência entre de quantidade ou tipo de produto, etiqueta não considerada na ordem de sepração !!, Verifique o cadastro de produto, e etiqueta bipada x empenho !!","Atenção...",48)
							DbSelectArea("TCQ")
							DbCloseArea()
							oGetEtiqu:Setfocus()
						Endif
    					
						//DbSelectarea("SD4")
						//DbSkip()
					//Enddo
	
				Else
					Messagebox("Etiqueta bipada não corresponde ao item empenhado, verifique (etiqueta x empenho) !!","Atenção...",48)
					oGetEtiqu:Setfocus()
					DbSelectArea("TCQ")
					DbCloseArea()
					Return
				Endif	
			Endif
		Else
			Messagebox("Etiqueta bipada não corresponde ao item empenhado, verifique código do produto, ou lote !!","Atenção...",48)
			oGetEtiqu:Setfocus()
			DbSelectArea("TCQ")
			DbCloseArea()
			Return
		Endif
		
	Else
		Messagebox("Essa etiqueta já esta associada a ordem de produção "+CB0->CB0_OP+", portanto não pode ser bipada novamente, verifique  !!","Atenção...",48)		
		DbSelectArea('CB0')
		DbCloseArea()
		oGetEtiqu:Setfocus()
		Return
	Endif
Else
	Messagebox("Não encontrado código da etiqueta na tabela CB0, verifique o número digitado/bipado !!","Atenção...",48)		
	DbSelectArea('CB0')
	DbCloseArea()
	oGetEtiqu:Setfocus()
Endif
	fAtStatu(cGetOrPr,1) // Atualiza Status da SD4
	fCarOrdS(cGetOrPr) // Atualiza legendas
Return



/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fStAtual() - Retorna o Status atual da Op, por problemas no posicione
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fStAtual(cNumOp)

Local cQry :=""

If ChkFile("TCQ")
	DbSelectArea("TCQ")
    DbCloseArea()
Endif


cQry :=""
cQry += " SELECT C2_XSTATUS AS cStAtual FROM "+RetSqlName("SC2")+" 
cQry += " WHERE C2_FILIAL ='"+xFilial("SC2")+"' AND D_E_L_E_T_ ='' AND C2_XOP ='"+cNumOp+"'"

TCQuery cQry ALIAS "TCQ" NEW
DbSelectArea("TCQ")		 		
		
If !Eof() 
	cStAtual := TCQ->cStAtual
Else
	cStAtual := Posicione("SC2", 1, xFilial("SC2")+SubStr(cGetOrPr, 1, 11), "C2_XSTATUS")
Endif

DbSelectArea("TCQ")
DbCloseArea()

Return(cStAtual)




/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fAtStatu() - Atualiza o Status da SC2 e SD4 para a fase de Separação / Produção
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fAtStatu(cNumOp,nOpc) // nOpc 1- Finaliza Item / 2- Finaliza Op

Local cQry 		:=""
Local cQry1 	:=""
Local cQry2 	:=""
Local lSucesso := .t.

If Empty(Alltrim(cNumOp)) .or. Len(Alltrim(cNumOp)) <> 11
	Return
Endif

If ChkFile("TCQ")
	DbSelectArea("TCQ")
    DbCloseArea()
Endif


cQry += " SELECT C2_XSTATUS, D4_XSTATUS FROM "+RetSqlName("SC2")+" SC2 WITH(NOLOCK) " 
cQry += " LEFT OUTER JOIN "+RetSqlName("SD4")+" SD4 WITH(NOLOCK) ON D4_FILIAL = C2_FILIAL AND D4_OP = C2_XOP AND SD4.D_E_L_E_T_ ='' " 
cQry += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = D4_FILIAL AND B1_COD = D4_COD AND SB1.D_E_L_E_T_ ='' "
cQry += " WHERE C2_XOP ='"+cNumOp+"' " 
cQry += " AND SC2.D_E_L_E_T_ ='' "
cQry += " AND C2_FILIAL ='"+xFilial("SC2")+"' "
cQry += " AND B1_TIPO <>'MO' AND B1_NAOSEPA IN('','1','3') "
cQry += " GROUP BY C2_XSTATUS, D4_XSTATUS "
cQry += " HAVING D4_XSTATUS <> C2_XSTATUS "

TCQuery cQry ALIAS "TCQ" NEW
DbSelectArea("TCQ")		

If Eof()
	
	cStAtual := Alltrim(Posicione("SC2", 1, xFilial("SC2")+SubStr(cNumOP, 1, 11), "C2_XSTATUS"))
	//cStAtual := fStAtual(cNumOp)
	cStNovo  := Iif(cStAtual =='1','2','3' )
 	If nOpc == 1

	    cQry1 := ""
        cQry1 += "UPDATE "+RetSqlName("SD4")+" SET D4_XSTATUS ='"+cStNovo+"' WHERE D4_FILIAL ='"+xFilial("SD4")+"' AND D_E_L_E_T_ ='' AND D4_OP ='"+cNumOP+"' AND D4_XSTATUS ='"+cStAtual+"'" 
        TCSQLExec(cQry1)		
		lSucesso := (TcSQLExec(cQry1) >= 0)
		If !lSucesso
			MsgStop(TcSqlError())
		Endif 

    Elseif nOpc == 2     
    	
    	Begin Transaction
    	
    		cQry1 := ""
    		cQry1 += "UPDATE "+RetSqlName("SD4")+" SET D4_XSTATUS ='"+cStNovo+"' WHERE D4_FILIAL ='"+xFilial("SD4")+"' AND D_E_L_E_T_ ='' AND D4_OP ='"+cNumOP+"' AND D4_XSTATUS ='"+cStAtual+"'" 
			lSucesso := (TcSQLExec(cQry1) >= 0)
			If !lSucesso
				MsgStop(TcSqlError())
				DisarmTrans()
			else 

				cQry2 := ""
				cQry2 += "UPDATE "+RetSqlName("SC2")+" SET C2_XSTATUS ='"+cStNovo+"' WHERE C2_FILIAL ='"+xFilial("SC2")+"' AND D_E_L_E_T_ ='' AND C2_XOP ='"+cNumOP+"'"
				lSucesso := (TcSQLExec(cQry2) >= 0)
				If !lSucesso
					MsgStop(TcSqlError())
					DisarmTrans()
				else 
		    		Messagebox("Ordem de produção "+cNumOp+" mudou de Status --> "+Iif(cStNovo ='2','Produção', 'Apontamento'),"Atenção...",48)
				endif 
			endif 
    		
    	End Transaction

   		oDlg1Env:End()
   		//u_BIPORD_1()
   		//cGetOrPr := cNumOP
	Endif
	
	
	DbSelectArea("TCQ")		
	DbCloseArea()
	
	fCarOrdS(cNumOp)
	
	cGetEtiqu := space(10)
    oGetEtiqu:Refresh()
    cGetDesP2 := space(30)
    oGetDesP2:Refresh()
    cGetCodPr := space(15)
    oGetCodPr:Refresh()
    oGetEtiqu:Setfocus()
/*
Else

	Messagebox("Não é possível finalizar essa fase, Op ->"+cNumOp+" , conferência incompleta !! ","Atenção...",48)
	DbSelectArea("TCQ")		
	DbCloseArea()
    oGetEtiqu:Setfocus()
	*/

Endif

Return


// Legenda da SC2 (C2_XSTATUS)
User Function BIPORD_4()
     
     Local ny       := 0
     Local nx       := 0
     Local cTitulo  := OemToAnsi("Legenda da Situação Atual da OP")
     Local cMensagem:= OemToAnsi("Conferência de Empenho")
  

     Local aCores   := { {"BR_CINZA"   , "OPS SEM ORDEM DE SEPARAÇÃO" },; //''
                         {"BR_AMARELO" , "OPS BIPE SEPARAÇÃO"         },; //1
                         {"BR_LARANJA" , "OPS BIPE NA PRODUÇÃO"       },; //2
                         {"BR_VERDE"   , "OPS APTAS PARA O APONTAMENTO DE PRODUÇÃO"} } //3

     Local aBmp[Len(aCores)]
     Local aSays[Len(aCores)]
     Local oDlgLeg
     nXSize := 14

     DEFINE MSDIALOG oDlgLeg FROM 0,0 TO (Len(aCores)*20)+50,554 TITLE cTitulo Of oMainWnd PIXEL
            oDlgLeg:bLClicked:= {||oDlgLeg:End()}
            DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
            @ 0 , 0 BITMAP RESNAME "BRPIPORD" oF oDlgLeg SIZE 35,155 NOBORDER WHEN .F. PIXEL
            @ 11,35 TO 013,400 LABEL '' OF oDlgLeg PIXEL
            @ 03,37 SAY cMensagem OF oDlgLeg PIXEL SIZE 100,009 FONT oBold
            For nx := 1 to Len(aCores)
                @ 19+((nx-1)*10),44 BITMAP aBmp[nx] RESNAME aCores[nx][1] of oDlgLeg SIZE 20,20 NOBORDER WHEN .F. PIXEL
                @ 19+((nx-1)*10),(nXSize/2) + 47 SAY If((ny+=1)==ny,aCores[ny][2]+If(ny==Len(aCores),If((ny:=0)==ny,"",""),""),"") of oDlgLeg PIXEL
            Next
            ny := 0
     ACTIVATE MSDIALOG oDlgLeg CENTERED

Return


// Legenda da SD4 (D4_XSTATUS)
Static Function BIPORD_5()
     
     Local ny       := 0
     Local nx       := 0
     Local cTitulo  := OemToAnsi("Legenda da Situação do Item")
     Local cMensagem:= OemToAnsi("Conferência de Empenho")
  

     Local aCores   := { {"BR_CINZA"   , "ITEM NÃO SEPARADO" 			   },; //''
                         {"BR_AMARELO" , "ITEM BIPADO EM FASE DE SEPARAÇÃO"},; //1
                         {"BR_LARANJA" , "ITEM BIPADO EM FASE DE PRODUÇÃO "},; //2
                         {"BR_VERDE"   , "CONFERÊNCIA DO ITEM FINALIZADA"} } //3

     Local aBmp[Len(aCores)]
     Local aSays[Len(aCores)]
     Local oDlgLeg
     nXSize := 14

     DEFINE MSDIALOG oDlgLeg FROM 0,0 TO (Len(aCores)*20)+50,554 TITLE cTitulo Of oMainWnd PIXEL
            oDlgLeg:bLClicked:= {||oDlgLeg:End()}
            DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
            @ 0 , 0 BITMAP RESNAME "BRPIPORD" oF oDlgLeg SIZE 35,155 NOBORDER WHEN .F. PIXEL
            @ 11,35 TO 013,400 LABEL '' OF oDlgLeg PIXEL
            @ 03,37 SAY cMensagem OF oDlgLeg PIXEL SIZE 100,009 FONT oBold
            For nx := 1 to Len(aCores)
                @ 19+((nx-1)*10),44 BITMAP aBmp[nx] RESNAME aCores[nx][1] of oDlgLeg SIZE 20,20 NOBORDER WHEN .F. PIXEL
                @ 19+((nx-1)*10),(nXSize/2) + 47 SAY If((ny+=1)==ny,aCores[ny][2]+If(ny==Len(aCores),If((ny:=0)==ny,"",""),""),"") of oDlgLeg PIXEL
            Next
            ny := 0
     ACTIVATE MSDIALOG oDlgLeg CENTERED

Return



