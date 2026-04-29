#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch" 
#include 'font.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "DIRECTRY.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VMFAT013 º Autor ³ Luis Gustavo       º Data ³  11/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Borderos.                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ VIAMIX                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function VMFAT013()
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Declaracao de Variaveis                                             ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Private cVldAlt   := "u_VMF013_1()"    // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
    Private cVldExc   := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
    Private cString   := "ZZ0"
    Private cCadastro := "Controle de Coletas Depósito - SP"
    Private cOkFunc   := ".T."

    Private aRotina   := { { OemToAnsi("Pesquisar") 		, "AxPesqui"  		, 0, 1 },;
                           { OemToAnsi("Visualizar")		, "AxVisual"  		, 0, 2 },;
                           { OemToAnsi("Alterar")   		, "u_VMF013_1()"    , 0, 4 },;
                           { OemToAnsi("Baixa Coleta") 		, "u_VMF013_3()"    , 0, 5 },;
                           { OemToAnsi("Relat. Conferencia"), "u_BRDESGRU()"    , 0, 6 },;
						   { OemToAnsi("Legenda")           , "U_FAT0131" 		, 0, 7 },;
                           { OemToAnsi("Imprimir Etiqueta") , "u_ImpEtiqX"		, 0, 8 },;
	  					   { OemToAnsi("Imprimir Bordero")  , "u_EtiqBord"		, 0, 9 }}
                          
    Private aCores    := { { ' EMPTY(ZZ0_MOTIVO) .and.  EMPTY(ZZ0_ENTREG)', 'BR_AZUL'},;
                           { '!EMPTY(ZZ0_MOTIVO) .and.  EMPTY(ZZ0_ENTREG)', 'DISABLE'},;
                           { ' EMPTY(ZZ0_MOTIVO) .and. !EMPTY(ZZ0_ENTREG)', 'ENABLE' } }
     

	//cVldAlt   := "u_VMF013_1()"    

	//AxCadastro(cString, cCadastro, cVldExc, cVldAlt)
	//DbSelectArea("ZZ0")
    //DbSetOrder(1)

    DbSelectArea("ZZ0")
    DbSetOrder(1)

    mBrowse( 06, 01, 22, 75, cString, , , , , , aCores)
     
    DbSelectArea("SA4")
    DbSetOrder(1)
     
Return


User Function VMF013_1()                                                            

	  
	DbSelectArea("ZZ0")   //ZZ0_FILIAL+ZZ0_PEDIDO
	DbSetOrder(4)
	DbSeek(xFilial("ZZ0")+ZZ0->ZZ0_PEDIDO)
	If Found()      
		Define Dialog oDlg Title "Alterar Dados da Coleta " From 100,100 To 450,650 Pixel
	
		
		aTFolder1 := { "Pedido - "+ZZ0_PEDIDO+'  Nf - '+ZZ0_NFISCA}
		oTFolder1 := TFolder():new( 0,10,aTFolder1,,oDlg,,,,.t.,,230,190 )    
    
	   	cCliente := POSICIONE("SA1",1,XFILIAL("SA1")+ZZ0->ZZ0_CLIENT,"A1_NOME")  
		@ 017, 003 SAY "Cliente: " SIZE 180, 007 OF oTFolder1:aDialogs[1] COLORS  8415564, 0 PIXEL  
		@ 015, 035 MSGET oCliente VAR cCliente OF oTFolder1:aDialogs[1] SIZE 150,05 PIXEL WHEN .F.
	
		M->ZZ0_PLIQUI := ZZ0->ZZ0_PLIQUI
		@ 031, 003 SAY "Peso Liquido: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS  8415564, 0 PIXEL  
		@ 029, 035 MSGET oPesoL VAR M->ZZ0_PLIQUI PICTURE "@E 99,999.999" OF oTFolder1:aDialogs[1	] SIZE 50,05 PIXEL WHEN .F.

		M->ZZ0_PBRUTO := ZZ0->ZZ0_PBRUTO
		@ 031, 100 SAY "Peso Bruto: " SIZE 052, 007 OF oTFolder1:aDialogs[1] COLORS 8415564,1540 PIXEL 
		@ 029, 135 MSGET oPesoB VAR M->ZZ0_PBRUTO  PICTURE "@E 99,999.999" OF oTFolder1:aDialogs[1] SIZE 050,007 PIXEL WHEN .F.

	    M->ZZ0_CGCRED := ZZ0->ZZ0_CGCRED
		@ 047, 003 SAY "CNPJ Tranp: " SIZE 180, 007 OF oTFolder1:aDialogs[1] COLORS  8415564, 0 PIXEL  
	    @ 045, 035 MSGET oCNPJRedesp VAR M->ZZ0_CGCRED  OF oTFolder1:aDialogs[1]  F3 'SA4CGC' SIZE 060,05  PIXEL

	    oCNPJRedesp:bLostFocus :=  {|| FValTransp(M->ZZ0_CGCRED) }

		M->ZZ0_RESDES :=  ZZ0->ZZ0_RESDES
		@ 047, 100 SAY "Resp. Des: " SIZE 80, 007 OF oTFolder1:aDialogs[1] COLORS  8415564, 0 PIXEL  
    	oCBResDes := TComboBox():New( 058, 165, {|u| If(PCount() > 0, M->ZZ0_RESDES := u, M->ZZ0_RESDES)}, {"01", "02", "03", "04", "05", "06", "07", "08", "09"}, 032, 014, oDlg, , , , CLR_BLACK, CLR_WHITE, .T., oFont, "", , , , , , , M->ZZ0_RESDES )
		
	    cTransp := POSICIONE("SA4", 3, xFilial("SA4")+ZZ0->ZZ0_CGCRED, "A4_NOME")
		@ 063, 003 SAY "Transporte: " SIZE 180, 007 OF oTFolder1:aDialogs[1] COLORS  8415564, 0 PIXEL  
		@ 065, 035 MSGET oTransp  VAR cTransp OF oTFolder1:aDialogs[1] SIZE 150,05 PIXEL WHEN .F.

		M->ZZ0_NROCOL := ZZ0->ZZ0_NROCOL
		@ 079, 003 SAY "Num Coleta: " SIZE 150, 007 OF oTFolder1:aDialogs[1] COLORS 8415564,0  PIXEL
		@ 077, 035 MSGET oColeta VAR M->ZZ0_NROCOL OF oTFolder1:aDialogs[1]  SIZE 60,007 PIXEL 

	    M->ZZ0_CONTAT := ZZ0->ZZ0_CONTAT
		@ 079, 100 SAY "Contato: " SIZE 180, 007 OF oTFolder1:aDialogs[1] COLORS  8415564, 0 PIXEL  
		@ 077, 135 MSGET oContato VAR M->ZZ0_CONTAT OF oTFolder1:aDialogs[1] SIZE 100,05 PIXEL  

	    M->ZZ0_ENTREG := ZZ0->ZZ0_ENTREG
		@ 095, 003 SAY "Data Entrega: " SIZE 180, 007 OF oTFolder1:aDialogs[1] COLORS  8415564, 0 PIXEL  
		@ 093, 035 MSGET oEntreg VAR M->ZZ0_ENTREG OF oTFolder1:aDialogs[1] PICTURE '  /  /  ' SIZE 50,05 PIXEL  

	    M->ZZ0_OBS := ZZ0->ZZ0_OBS
		@ 0111, 003 SAY "Observação: " SIZE 180, 007 OF oTFolder1:aDialogs[1] COLORS  8415564, 0 PIXEL  
		@ 0109, 035 MSGET oObserv VAR M->ZZ0_OBS  OF oTFolder1:aDialogs[1] SIZE 150,05 PIXEL  

		@140, 060 Button "Confirmar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[1] Action(U_VMF013_2(ZZ0->ZZ0_PEDIDO),oDlg:End())
		@140, 110 Button "Cancelar" Size 040, 015 PIXEL OF oTFolder1:aDialogs[1] Action(oDlg:End())
	
		Activate Dialog oDlg Centered  
		
Endif	

Return()


Static Function FValTransp(cCnpj)

	DbSelectArea("SA4")
	DbSetOrder(3)
	DbSeek(xFilial("SA4")+cCnpj,.t.)
	If Found()
		cTransp := SA4->A4_NOME	
	Else
   		Messagebox("Cnpj do redespacho inválido  !!!","Atenção...",48)			
	Endif
	oTransp:Refresh()

	DbSelectArea("SA4")
	DbSetOrder(1)

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VMF013_2()Função para liberação dos endereços ocupados pelo pedido no depósito ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
User Function VMF013_2(cPedido)
	
	Local lRet 	  := .t.
	Local cQry 	  := " "
    //Local i    	  := 1
	Local nY      := 1
	Local aLibEnd := {}
	//If ALTERA 
		Begin Transaction

			DbSelectArea("ZZ0")   //ZZ0_FILIAL+ZZ0_PEDIDO
			DbSetOrder(4)
			DbSeek(xFilial("ZZ0")+cPedido,.t.)
			If Found()  				                                                                                                                                           
				Reclock("ZZ0",.f.)
					ZZ0->ZZ0_CGCRED := M->ZZ0_CGCRED
					ZZ0->ZZ0_COLETA := Iif(Alltrim(M->ZZ0_ENTREG) <> '  /  /  ', 'S','N')
					ZZ0->ZZ0_RESDES := Substr(M->ZZ0_RESDES,2,1)
					ZZ0->ZZ0_ENTREG := M->ZZ0_ENTREG
					ZZ0->ZZ0_NROCOL := M->ZZ0_NROCOL
					ZZ0->ZZ0_CONTAT := M->ZZ0_CONTAT
					ZZ0->ZZ0_OBS    := M->ZZ0_OBS
				MsUnlock()		    
			Endif

        	If  Substr(dtoc(M->ZZ0_ENTREG),1,2)  <> "  "

				cQry := " "	
				cQry += " SELECT ZZT_CODIGO, ZZT_TIPO, ZZT_STATUS "
				cQry += " FROM "+RetSqlName("ZZT")+" ZZT WITH (NOLOCK) "
				cQry += " LEFT OUTER JOIN "+RetSqlName("ZZU")+" ZZU WITH (NOLOCK) "
				cQry += " ON ZZT_FILIAL = ZZU_FILIAL AND ZZT_CODIGO = ZZU_ENDERE AND ZZU.D_E_L_E_T_ ='' "
				cQry += " WHERE ZZT.D_E_L_E_T_ ='' "
				cQry += " AND ZZT_FILIAL ='"+xFilial("ZZT")+"'"
				cQry += " AND ZZT_STATUS ='2' "
				cQry += " AND ZZU_PEDIDO  ='"+ZZ0->ZZ0_PEDIDO+"'"				

				TCQUERY cQry ALIAS "TCQ" NEW
				DbSelectArea("TCQ")
				While !Eof()            
		    		aAdd(aLibEnd, {TCQ->ZZT_CODIGO})					
					DbSelectArea("TCQ")
					DbSkip()
				Enddo
				DbSelectArea("TCQ")
				DbCloseArea()
                If Len(aLibEnd) >0
					cQry := " "
					cQry += " UPDATE "+RetSqlName("ZZU")+" SET D_E_L_E_T_ ='*' "
					cQry += " WHERE D_E_L_E_T_ ='' AND ZZU_FILIAL ='"+xFilial("ZZU")+"' AND ZZU_PEDIDO ='"+ZZ0->ZZ0_PEDIDO+"'"
   					TCSQLExec(cQry) 
		
					For nY:= 1 To Len(aLibEnd)
		   				cQry1 := " "
						cQry1 += " UPDATE "+RetSqlName("ZZT")+" SET ZZT_STATUS ='1' FROM "+RetSqlName("ZZT")+" ZZT LEFT OUTER JOIN "+RetSqlName("ZZU")+" ZZU "
	   					cQry1 += " ON ZZT_FILIAL = ZZU_FILIAL AND ZZT_CODIGO = ZZU_ENDERE AND ZZU.D_E_L_E_T_ ='' "
	   					cQry1 += " WHERE ZZT.D_E_L_E_T_ ='' AND ZZT_FILIAL ='"+xFilial("ZZT")+"'"
			   			cQry1 += " AND ZZU_PEDIDO IS NULL AND ZZT_CODIGO ='"+aLibEnd[nY][1]+"'"
				   		TCSQLExec(cQry1) 
					Next nY
				Endif				
		    Endif

   			
		End Transaction
	
	//Endif
    DbSelectArea("ZZ0")
    DbSetOrder(1)


Return(lRet)

User Function FAT0131() 

BrwLegenda(OemToAnsi("Posição das Notas Fiscais"),OemToAnsi("Status"),{ {"DISABLE", "Parada no Depósito"  } ,;
                                                                        {"BR_AZUL", "Aguardando Coleta"   } ,;
                                                                        {"ENABLE" , "Mercadoria Entregue" } })
Return

User Function ImpEtiqX()
Local cSerie, cTransp
	If Empty(ZZ0_REDESP) 
   		Messagebox("Nota com redespacho em branco, favor verificar !!!","Atenção...",48)
		Return
	Endif
    cModelo := "ZEBRA"  //ZT230
    cSerie := Posicione("SF2",10, xFilial("SF2")+ZZ0_PEDIDO,"F2_SERIE")   
   	cTransp := Posicione("SA4",1, xFilial("SA4")+ZZ0_REDESP,"A4_NOME")
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
        MSCBSay(06,03,Alltrim(cTransp) ,"N", "0"	,"30,30")
        MSCBSay(06,07,"CNPJ: "+Alltrim(ZZ0_CGCRED)   	 ,"N", "0"	,"30,30")
        MSCBSay(06,11,"Nf: "+Alltrim(ZZ0_NFISCA)+SPACE(3)+"Serie: "+Alltrim(cSerie) ,"N", "0"	,"30,30")
     // MSCBSay(06,15,"Telefone: "+ZZ0_TELEFONE			 ,"N", "0"	,"30,30")
           
        MSCBCHKSTATUS(.f.)
        cText := MSCBEND()
        MSCBCLOSEPRINTER()

	Endif
Return        

User Function EtiqBord()  
Local cTransp,cSerie
PRIVATE cPerg   := "EtiqBord"
  
//CriaSX1(cPerg)  //LGS#20200213 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.T.)

cQuery := "SELECT ZZ0_PEDIDO, ZZ0_CGCRED,ZZ0_NFISCA, ZZ0_REDESP "
cQuery += "FROM "+RetSqlName("ZZ0")+" ZZ0 WITH(NOLOCK) "
cQuery += "WHERE ZZ0_BORDER = ('"+MV_PAR01+"') AND ZZ0.D_E_L_E_T_ <> '*'"
	cQuery += "ORDER BY ZZ0_REDESP"

if used()
	DbSelectArea("TCQ")
	DbCloseArea()
endif 
TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

	If Empty(TCQ->ZZ0_REDESP) 
   		Messagebox("Nota com redespacho em branco, favor verificar !!!","Atenção...",48)
		Return
	ElseIf Eof()                                                                        
		Messagebox("Bordero sem pedido, favor verificar !!!","Atenção...",48)
		Return
	Endif
    
   	cModelo := "ZEBRA"  //ZT230
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
  		While !EOF()                                                                                                	
  			cTransp := Posicione("SA4",1, xFilial("SA4")+TCQ->ZZ0_REDESP,"A4_NOME") 
 		 	cSerie := Posicione("SF2",10, xFilial("SF2")+ZZ0_PEDIDO,"F2_SERIE") 
  			MSCBBEGIN(1, 6, , .f.)
       		MSCBSay(07,03,Alltrim(cTransp) ,"N", "0"	,"30,30")
       		MSCBSay(07,07,"CNPJ: "+Alltrim(TCQ->ZZ0_CGCRED)   	 ,"N", "0"	,"30,30")
        	MSCBSay(07,11,"Nf: "+Alltrim(TCQ->ZZ0_NFISCA)+SPACE(3)+"Serie: "+cSerie ,"N", "0"	,"30,30")
    	 // MSCBSay(06,15,"Telefone: "+ZZ0_TELEFONE			 ,"N", "0"	,"30,30")
      		dbselectarea("TCQ")	 
			dbskip()    
			cTransp := Posicione("SA4",1, xFilial("SA4")+TCQ->ZZ0_REDESP,"A4_NOME")
	   	    cSerie  := Posicione("SF2",10, xFilial("SF2")+TCQ->ZZ0_PEDIDO,"F2_SERIE") 
	  		MSCBSay(07,19,Alltrim(cTransp) ,"N", "0"	,"30,30")  
	   		MSCBSay(07,23,"CNPJ: "+Alltrim(TCQ->ZZ0_CGCRED)   	 ,"N", "0"	,"30,30")
        	MSCBSay(07,27,"Nf: "+Alltrim(TCQ->ZZ0_NFISCA)+SPACE(3)+"Serie: "+cSerie ,"N", "0"	,"30,30")    	 
    	    MSCBCHKSTATUS(.f.)
	        cText := MSCBEND()
			MSCBCLOSEPRINTER()
			dbselectarea("TCQ")	 
			dbskip() 
		EndDo
	Endif
	dbSelectArea("TCQ")
    dbCloseArea()
Return


User Function VMF013_3()  

Private oSay1, oSay2, oSay3, oSay4, oSay5, oSay6, cSay1, cSay2, cSay3, cSay4, cSay5, cSay6, oSayM, oSayD
Private cchvnfe := space(44), cPedido, ochvnfe, oDlg, oBtn, oBtn2
Private dDtbaixa:=Date(), oDtBaixa
Private oFont   := TFont():New( "MS Sans Serif", 0, -18, , .F., 0, , 400, .F., .F., , , , , , )

oDlg    := MSDialog():New( 140, 264, 580, 960, "BAIXA COLETA DEPÓSITO", , , .F., , , , , , .T., , , .T. )
oSayM    := TSay():New( 060, 010, {|| "Mensagem"},oDlg,, oFont,,,, .T., CLR_WHITE,CLR_RED ) 

oSayM    := TSay():New( 010, 010, { || "CHAVE NFE:"}, oDlg, , oFont, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 012)
ochvnfe := TGet():New( 010, 060, { |u| If(PCount() > 0, cchvnfe := u, cchvnfe)}, oDlg, 0250, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFont,   , , .T., "", , , .F., .F., , .F., .F., "", "cchvnfe", , ) 
ochvnfe:bLostFocus := {|| Iif(!Empty(Alltrim(cchvnfe)),fConsNFe(cchvnfe),"")}
//oBtn    := TButton():New( 010, 285, "CONSULTAR", oDlg, {|| fConsNFe(cchvnfe) }, 055, 016, , oFont, , .T., , "", , , , .F. )

oSayD    := TSay():New( 030, 010, { || "DATA COLETA:"}, oDlg, , oFont, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 055, 012)
oDtBaixa:= TGet():New( 030, 060, { |u| If(PCount() > 0, dDtBaixa := u, dDtBaixa)}, oDlg, 060, 014, '@!' , , CLR_BLACK, CLR_WHITE, oFont,   , , .T., "", , , .F., .F., , .F., .F., "", "dDtBaixa", , ) 
oBtn2   := TButton():New( 180, 285, "BAIXAR", oDlg, {|| fBaixCol(cPedido) }, 055, 016, , oFont, , .T., , "", , , , .F. )

oDlg:Activate(,,,.T.)

Return()            

Static Function fConsNFe(cchvnfe)

Local cQuery, cQuery1, cEndereco 

cEndereco    := Space(200)

cSay1  := Space(200)
cSay2  := Space(200)
cSay3  := Space(200)
cSay4  := Space(200)
cSay5  := Space(200)
cSay6  := Space(200)

oSay1  := TSay():New( 060, 010, { || cSay1  },   oDlg, , oFont, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)
oSay2  := TSay():New( 080, 010, { || cSay2	},   oDlg, , oFont, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)
oSay3  := TSay():New( 100, 010, { || cSay3	},   oDlg, , oFont, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)
oSay4  := TSay():New( 120, 010, { || cSay4  },   oDlg, , oFont, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)
oSay5  := TSay():New( 140, 010, { || cSay5 	},   oDlg, , oFont, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)
oSay6  := TSay():New( 160, 010, { || cSay6	},   oDlg, , oFont, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)

oSay1:Refresh()
oSay2:Refresh()
oSay3:Refresh()
oSay4:Refresh()
oSay5:Refresh()
oSay6:Refresh()

cQuery := " SELECT ZZ0_FILIAL, ZZ0_BORDER, ZZ0_PEDIDO, F2_DOC, F2_SERIE, F2_CLIENTE,F2_RAZAO, ZZ0_CONTAT,ZZ0_NROCOL, ZZ0_REDESP, A4_NOME, ROUND(ZZ0_PBRUTO,0) AS ZZ0_PBRUTO, ZZ0_VOLUME, ZZ0_COLETA,ZZ0_ENTREG,ZZ0_OBS, SUBSTRING(F2_EMISSAO,7,2)+'/'+SUBSTRING(F2_EMISSAO,5,2)+'/'+SUBSTRING(F2_EMISSAO,1,4) AS F2_EMISSAO "
cQuery += " FROM "+RetSqlName("ZZ0")+" ZZ0 WITH(NOLOCK) "
cQuery += " LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH(NOLOCK) ON F2_FILIAL = ZZ0_FILIAL AND F2_DOC = ZZ0_NFISCA AND ZZ0_PEDIDO = F2_PEDIDO AND F2_CLIENT = ZZ0_CLIENT AND SF2.D_E_L_E_T_ ='' "
cQuery += " LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH(NOLOCK) ON A4_FILIAL = A4_FILIAL AND A4_COD = ZZ0_REDESP AND SA4.D_E_L_E_T_ ='' "
cQuery += " WHERE ZZ0.D_E_L_E_T_ ='' "
cQuery += " AND ZZ0_FILIAL ='"+xFilial("ZZ0")+"'"
cQuery += " AND F2_CHVNFE  = '"+alltrim(cchvnfe)+"'"

TCQUERY cQuery ALIAS "TCQ" NEW
DbSelectArea("TCQ")
	If Eof()
		Messagebox("Chave digitada / bipada não encontrada !!","Atenção...",48) 
		dbSelectArea("TCQ")
		dbCloseArea()
		ochvnfe:Setfocus()
		Return
	Endif
	cPedido := alltrim(TCQ->ZZ0_PEDIDO)
	cQuery1 := " SELECT ZZU_PALLET, ZZU_ENDERE FROM "+RetSqlName("ZZU")+" ZZU WITH(NOLOCK) "
	cQuery1 += " WHERE ZZU.D_E_L_E_T_ ='' "
	cQuery1 += " AND ZZU_FILIAL ='"+xFilial("ZZU")+"'"
	cQuery1 += " AND ZZU_PEDIDO = '"+cPedido+"'"
	
	TCQUERY cQuery1 ALIAS "TCQ1" NEW
	DbSelectArea("TCQ1")
	If !Eof()
		While !Eof()            
			cEndereco :=  cEndereco+"   "+SUBSTRING(TCQ1->ZZU_ENDERE,1,7)
			DbSelectArea("TCQ1")
			DbSkip()
		Enddo
	Else
		cEndereco := "ENDEREÇO JÁ LIBERADO
		Messagebox("Endereçamento já baixado !!","Atenção...",48) 
		//cEndereco := "ENDEREÇO JÁ LIBERADO"
		//ccchvnfe  := ""            
		//ochvnfe:Setfocus()
	Endif

	cSay1  :="Pedido....: "+TCQ->ZZ0_PEDIDO+space(5)+"Nota: "+TCQ->F2_DOC+" - "+TCQ->F2_SERIE+space(5)+"Emissão: "+TCQ->F2_EMISSAO
	cSay2  :="Cliente...: "+TCQ->F2_CLIENTE+space(3)+TCQ->F2_RAZAO   
	cSay3  :="Transporte: "+SUBSTR(TCQ->A4_NOME,1,50) 
	cSay4  :="Nro Coleta: "+SUBSTRING(TCQ->ZZ0_NROCOL,1,30)+Space(5)+"Contato: "+TCQ->ZZ0_CONTAT
	cSay5  :="Endereço..: "+Alltrim(cEndereco)
	cSay6  :="Observação: "+SUBSTRING(TCQ->ZZ0_OBS,1,40)

	oSay1  := TSay():New( 060, 010, { || cSay1  },   oDlg, , oFont, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)
	oSay2  := TSay():New( 080, 010, { || cSay2	},   oDlg, , oFont, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)
	oSay3  := TSay():New( 100, 010, { || cSay3	},   oDlg, , oFont, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)
	oSay4  := TSay():New( 120, 010, { || cSay4  },   oDlg, , oFont, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)
	oSay5  := TSay():New( 140, 010, { || cSay5 	},   oDlg, , oFont, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)
	oSay6  := TSay():New( 160, 010, { || cSay6	},   oDlg, , oFont, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)
    

	dbSelectArea("TCQ1")
	dbCloseArea()

dbSelectArea("TCQ")
dbCloseArea()

oBtn2:SetFocus()


Return Nil            

Static Function fBaixCol(cPedido)

	Local aLibEnd := {}
	Local cQry    := ""
	Local cQry1   := ""
	Local nY 	  := 1

	If cPedido <> Nil  /*Adicionado por Lucas - 23-09-2025. Chamado R8950*/
	
		Begin Transaction

			DbSelectArea("ZZ0")   //ZZ0_FILIAL+ZZ0_PEDIDO
			DbSetOrder(4)
			DbSeek(xFilial("ZZ0")+cPedido,.t.)
			If Found()  				                                                                                                                                           
				Reclock("ZZ0",.f.)
					ZZ0->ZZ0_ENTREG := dDtBaixa
					ZZ0->ZZ0_COLETA := Iif(Alltrim(dDtBaixa) <> '  /  /  ', 'S','N')
				MsUnlock()		    
			Endif

			If  Substr(dtoc(dDtBaixa),1,2)  <> "  "
				cQry := " "	
				cQry += " SELECT ZZT_CODIGO, ZZT_TIPO, ZZT_STATUS "
				cQry += " FROM "+RetSqlName("ZZT")+" ZZT WITH (NOLOCK) "
				cQry += " LEFT OUTER JOIN "+RetSqlName("ZZU")+" ZZU WITH (NOLOCK) "
				cQry += " ON ZZT_FILIAL = ZZU_FILIAL AND ZZT_CODIGO = ZZU_ENDERE AND ZZU.D_E_L_E_T_ ='' "
				cQry += " WHERE ZZT.D_E_L_E_T_ ='' "
				cQry += " AND ZZT_FILIAL ='"+xFilial("ZZT")+"'"
				cQry += " AND ZZT_STATUS ='2' "
				cQry += " AND ZZU_PEDIDO  ='"+cPedido+"'"				

				TCQUERY cQry ALIAS "TCQ" NEW
				DbSelectArea("TCQ")

				While !Eof()            
    				aAdd(aLibEnd, {TCQ->ZZT_CODIGO})					
					DbSelectArea("TCQ")
					DbSkip()
				Enddo

				DbSelectArea("TCQ")
				DbCloseArea()
	
			    If Len(aLibEnd) >0
					cQry := " "
					cQry += " UPDATE "+RetSqlName("ZZU")+" SET D_E_L_E_T_ ='*' "
					cQry += " WHERE D_E_L_E_T_ ='' AND ZZU_FILIAL ='"+xFilial("ZZU")+"' AND ZZU_PEDIDO ='"+cPedido+"'"
   					TCSQLExec(cQry) 

					For nY:= 1 To Len(aLibEnd)
						cQry1 := " "
						cQry1 += " UPDATE "+RetSqlName("ZZT")+" SET ZZT_STATUS ='1' "
						cQry1 += " FROM "+RetSqlName("ZZT")+" ZZT LEFT OUTER JOIN "+RetSqlName("ZZU")+" ZZU "
						cQry1 += " ON ZZT_FILIAL = ZZU_FILIAL AND ZZT_CODIGO = ZZU_ENDERE AND ZZU.D_E_L_E_T_ ='' "
						cQry1 += " WHERE ZZT.D_E_L_E_T_ ='' AND ZZT_FILIAL ='"+xFilial("ZZT")+"'"
		   				cQry1 += " AND ZZU_PEDIDO IS NULL AND ZZT_CODIGO ='"+aLibEnd[nY][1]+"'"
			   			TCSQLExec(cQry1) 
					Next nY
				Endif				
			Endif
		End Transaction
	
	Else 
		MessageBox("Preencha o campo CHAVE","Atenção",48)
		ochvnfe:Setfocus()
		Return 
	EndIf 
	
	
    DbSelectArea("ZZ0")
	DbSetOrder(1)

	Messagebox("Endereço do pedido foi liberado !!!","Atenção...",48)
	ochvnfe:Setfocus()
	
Return


//LGS#20200213 - Adequação de release 12.1.25 e posteriores
/*
Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues,ingles, espanhol
AAdd(aHelp, {{"Bordero"  },  {"Bordero"}, {"Bordero"}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[cValid],[cF3],[cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","Bordero " ,"Bordero ","Bordero ","mv_ch1","C",6,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")

Return*/
