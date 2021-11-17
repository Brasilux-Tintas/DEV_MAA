 
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"       
#include 'error.ch'
#include "tbiconn.ch"
                                                      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EnderProd ºAutor  ³ Luís G. de Souza   º Data ³  23/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Bordero de Pedidos Aprovados.                              º±±
±±º          ³ Antigo BRFAT065.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EnderProd()
     

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
  //   Private cOpcCon    := Iif(cOpcCon == Nil, "M", cOpcCon)
     
     Private cSayPro    := Space(1)
     Private cCodPro    := Space(15)
     Private cSayDes    := Space(1)
     Private cDesPro    := Space(30)
     Private cSayLoc    := Space(1)
     Private cLocPro    := Space(15)
     Private cSayOrd    := Space(1)
     Private cOrdPro    := Space(11)
     Private nQrdInf    := Space(11)
     Private aOrdPro    := {}
     Private cCodLot    := Space(06)
     Private cSayCon    := Space(1)
     Private nQtdOrd    := 0
     Private cSayMar    := Space(1)
     Private nQtdMar    := 0
     Private cSayEst    := Space(1)
     Private nQtdEst    := 0
     Private cSayEnv    := Space(1)
     Private nQtdEnv    := 0
     Private cSayAtu    := Space(1)     
     Private nQtdAtu    := 0
     Private nQtdQua    := 0
     Private cSayDis    := Space(1)     
     Private nQtdDis    := 0
     Private cSaySep    := Space(1)     
     Private nQtdSep    := 0
     Private cAuxPed    := ""
     Private lProest    := .f.
     Private ctipo	    :=""

  //    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1" , "oFont2" , "oDlg1"  , "oBtnPed", "oBtnNes", "oBtnAtu", "oBtnSai", "oGrpDiv", "oSayPro", "oCodPro")
     SetPrvt("oSayDes", "oDesPro", "oSayLoc", "oLocPro", "oGrpPrE", "oSayOrd", "oOrdPro", "oSayCon", "oQtdOrd", "oSayMar")
     SetPrvt("oQtdMar", "oSayEst", "oQtdEst", "oSayEnv", "oQtdEnv", "oSayAtu", "oQtdAtu", "oSaySep", "oQtdSep", "oSayDis")
     SetPrvt("oQtdDis", "oGrpDes", "oBrwDes", "oGrpPed", "oBrwPed", "oSayQua", "oQtdQua","oGrpPrB")

		
	 nQrdInf:= 0
	 nQtdMar:=0
	 cLocPro:=CriaVar("BE_LOCALIZ")
	 oCodPro:=CriaVar("B1_COD")
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1     := TFont():New( "Courier New", 0, -11, , .F., 0, , 400, .F., .F., , , , , , )
     oFont2     := TFont():New( "Courier New", 0, -13, , .T., 0, , 700, .F., .F., , , , , , )
     oFont3     :=  TFont():New("ARIAL",10,30,.T.,.T.,5,.T.,5,.T.,.F.)
     
     oDlg1      := MSDialog():New( 265, 250, 751, 1028, "Endereçamento de Produtos (PA)", , , .F., , , , , , .T., , , .T. )

     oBtnSai    := TButton():New( 230, 352, "Sair"       , oDlg1, {|| oDlg1:End() }, 037, 012, , , , .T., , "", , , , .F. )
	 oBtnExe    := TButton():New( 230, 310, "OK"       , oDlg1, {|| ValidaForm() }, 037, 012,,,.F.,.T.,.F.,,.F.,,,.F. )

     oGrpDiv    := TGroup():New( 016, 004, 016, 392, "", oDlg1, CLR_BLACK, CLR_WHITE, .T., .F. )
     oSayPro    := TSay():New( 018, 004, {||"Produto:"}                               , oDlg1  , ,oFont3, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE)
     oCodPro    := TGet():New( 032, 004, {|u| If(PCount() > 0, cCodPro := u, cCodPro)}, oDlg1  , 072, 10, '@!', , CLR_BLACK, CLR_WHITE, oFont3, , , .T., "", , , .F., .F., , .F., .F., "", "cCodPro", , )
     oCodPro:bLostFocus := {|| fCodPro(), Iif(!Empty(cCodPro), MsAguarde( {|| oTbl1(2)}, "Aguarde...", "Buscando..."), ), Iif(!Empty(cCodPro), MsAguarde( {|| oTbl2(2)}, "Aguarde...", "Buscando pedidos..."), )}

     oSayDes    := TSay():New( 018, 084, {||"Descrição:"}                             , oDlg1  , , oFont3, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE)
     oDesPro    := TGet():New( 032, 084, {|u| If(PCount() > 0, cDesPro := u, cDesPro)}, oDlg1  , 200, 10, '@!' , , CLR_BLACK, CLR_WHITE, oFont3, , , .T., "", , , .F., .F., , .T., .F., "", "cDesPro", , )
     oSayLoc    := TSay():New( 018, 292, {||"Endereço:"}                           , oDlg1  , , oFont3, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE)
     oLocPro    := TGet():New( 032, 292, {|u| If(PCount() > 0, cLocPro := u, cLocPro)}, oDlg1, 80, 10, '@!'  , , CLR_BLACK, CLR_WHITE, oFont3, , , .T., "", , , .F., .F., , .F., .F., "", "cLocPro", , )
     oLocPro:bF3 := &("{|| IIf(ConPad1(,,,'SBE',,,.F.),Eval({|| cLocPro := SBE->BE_LOCALIZ,oLocPro:Refresh()}),Substr(SBE->BE_LOCALIZ,1,2)=='F2')}")
      
     oGrpPrE    := TGroup():New( 048, 004, 100, 388, "", oDlg1, CLR_BLACK, CLR_WHITE, .T., .F. )
     // oSayOrd    := TSay():New( 056, 008, {|| cTipocod}                                  , oGrpPrE, , oFont3, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE)
    
     
     oSayOrdv    := TSay():New( 056, 008, {||"Cód. Pallet:"}                                 , oGrpPrE, , oFont3, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE)
     oCodProv    := TGet():New( 071, 008, {|u| If(PCount() > 0, cOrdPro := u, cOrdPro)}, oGrpPrE, 060, 10, '99999/9999'  , , CLR_BLACK, CLR_WHITE, oFont3, , , .T., "", , , .F., .F., , .F., .F., "", "cOrdPro", , )
     oCodProv:bLostFocus := {|| fOrdPro() }
     oSayConv    := TSay():New( 056, 150, {||"Quant. Informada:"}                            , oGrpPrE, , oFont3, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE)
     oQtdOrdv    := TGet():New( 071, 150, {|u| If(PCount() > 0, nQrdInf := u, nQrdInf)}, oGrpPrE, 80, 10, '@E 99999999.9999'  , , CLR_BLACK, CLR_WHITE, oFont3, , , .T., "", , , .F., .F., , .F., .F., "", "nQrdInf", , )
	 oQtdOrdv:bLostFocus := {|| calcQuant() }                                
     oSayMarv    := TSay():New( 056, 280, {||"Quant. Itens:"}                                , oGrpPrE, , oFont3, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE)
     //  oQtdMarv    := TGet():New( 094, 300, {|u| If(PCount() > 0, nQtdMar := u, nQtdMar)}, oGrpPrE, 80, 10, '@E 99999999.9999', , CLR_BLACK, CLR_WHITE, oFont3, , , .T., "", , , .F., .F., , .T., .F., "", "nQtdMar", , )
     oQtdEst    := TGet():New( 071, 280, {|u| If(PCount() > 0, nQtdEst := u, nQtdEst)}, oGrpPrE, 80, 10, '@E 99999999.9999', {|| positivo() }, CLR_BLACK, CLR_WHITE, oFont3, , , .T., "", , , .F., .F., , .F., .F., "", "nQtdEst", , )
		
     oGrpDiv2    := TGroup():New( 016, 004, 016, 392, "", oDlg1, CLR_BLACK, CLR_WHITE, .T., .F. )
     oDlg1:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
     oCodPro:SetFocus()
     oDlg1:Activate(,,,.T.)
     //DbSelectArea("ZT1")
     //DbCloseArea()
     //DbSelectArea("ZT2")
     //DbCloseArea()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fCodPro() - Busca informações de tela após da digitação do código de barras ou do produto
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fCodPro()
       cCodPro := StrTran(StrTran(cCodPro, '-'), '.')
       cOrdPro := space(11)
       nQtdOrd := 0
       nQtdMar := 0
       nQtdEst := 0
       nQtdEnv := 0
       nQtdEnv := 0
       nQtdQua := 0
       nQtdAtu := 0
       nQtdSep := 0
       nQtdDis := 0

       lProEst := !Empty(Posicione("SB2", 1, xFilial("SB2")+Posicione("SB1", 1, xFilial("SB1")+Alltrim(StrTran(StrTran(cCodPro, '.'), '-')), "B1_LOCPAD"), "B2_LOCALIZ"))
       If Empty(cCodPro)
          ApMsgStop("Codigo Inválido !!!")
          cCodPro := space(15)
          oCodPro:Refresh()
          cDesPro := space(30)
          oDesPro:Refresh()
          cLocPro := space(15)
          oLocPro:Refresh()
          oCodPro:SetFocus()
          cLocPro := space(15)
          oLocPro:Refresh()
          nQtdAtu := 0

          Return(.f.)
       ElseIf SubStr(cCodPro, 1, 3) $ '789' //  Identificação de produto unitário
              DbSelectArea("SB1")
              DbSetOrder(5)
              //DbSeek(xFilial("SB1")+SubStr(Alltrim(cCodPro), 1, Len(Alltrim(cCodPro))-1), .t.)
              DbSeek(xFilial("SB1")+cCodPro, .t.)
              If (SB1->(eof()))
                 ApMsgStop("Codigo Inválido !!!")
         
                 Return(.f.)
              Else
                 If !SB1->B1_TIPO $ 'PA'
                    ApMsgStop("Codigo Inválido !!!")
              
                    Return(.f.)
                 Else
                    cCodPro := SB1->B1_COD
					cDesPro := SB1->B1_DESC
					Tipocod := "Unitário"
					Aviso("Aviso","Foi informado o código de Produto unitário",{"OK"})
					cTipo:='U'
//					oSayOrd:Refresh()
                 Endif
              Endif
		   EndIf	  
           //Identificação do volume
		   
		   cQuery:=" SELECT B1_COD, B1_DESC, B1_TIPO FROM "+RetSQlName("SB1")+" WHERE B1_FILIAL='"+xFilial("SB1")+"' AND B1_XCODBRV='"+Alltrim(cCodPro)+"' AND D_E_L_E_T_='' "
		   IF (Select("TMP") > 0 )
				TMP->(DbCloseArea())
		   EndIf
		   TCQuery cQuery ALIAS "TMP" NEW
		   DbSelectArea("TMP")
           DbGoTop()
			 
           If (TMP->(eof()))
             
           Else
                 If !TMP->B1_TIPO $ 'PA'
                    ApMsgStop("Codigo Inválido !!!")
                
                    Return(.f.)  
                 Else
                    cCodPro := TMP->B1_COD
					cDesPro := TMP->B1_DESC
					cTipocod := "Volume"
					cTipo:='V'
					oSayOrd:Refresh()
					Aviso("Aviso","Foi informado o código de Volume",{"OK"})
					//oCodPro:Refresh()
					//oDesPro:Refresh()
                 Endif
           Endif    
		   //Return(.T.)			  
         
	   
	   //Identificação de Pallet
           cQuery:=" SELECT B1_COD, B1_DESC, B1_TIPO FROM SB1010 WHERE B1_FILIAL='010101' AND B1_XCODBRP='"+Alltrim(cCodPro)+"' AND D_E_L_E_T_='' "
		   IF (Select("TMP") > 0 )
				TMP->(DbCloseArea())
		   EndIf
		   TCQuery cQuery ALIAS "TMP" NEW
		   DbSelectArea("TMP")
           DbGoTop()
           If (TMP->(eof()))

              
           Else
                 If !TMP->B1_TIPO $ 'PA'
                    ApMsgStop("Codigo Inválido !!!")
               
                    Return(.f.)
                 Else
                    return .F.//sai da rotina
                 	cOrdPro := cCodPro
                    cCodPro := TMP->B1_COD
					cDesPro := TMP->B1_DESC
					Tipocod := "Pallet"
					cTipo:='P'
					
					oSayOrd:Refresh()
					
					Aviso("Aviso","Foi informado o código de Pallet",{"OK"})
					
                 Endif
           Endif     
          
       
     Return(.f.)
Return

Static Function oTbl1(nNum)

Return
Static Function oTbl2(nNum)

Return

Static Function ValidaForm()


 Local _aItensSDB:={},aitSDB:={},aCabSDA:={}
 Local nQuant:=1
 Local cItem:=''
 Private 	 lMsErroAuto:=.F.
 PRIVATE cCusMed  := ""
 PRIVATE aRegSD3  := {}
 
 cCusMed  := GetMv("MV_CUSMED")  

If cCusMed == "O"
	PRIVATE nHdlPrv 			// Endereco do arquivo de contra prova dos lanctos cont.
	PRIVATE lCriaHeader := .T.	// Para criar o header do arquivo Contra Prova
	PRIVATE cLoteEst 			// Numero do lote para lancamentos do estoque
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona numero do Lote para Lancamentos do Faturamento     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX5")
	SX5->(dbSeek(xFilial("SX5")+"09EST"))
	cLoteEst:=IIf(Found(),Trim(X5Descri()),"EST ")
	PRIVATE nTotal := 0 	// Total dos lancamentos contabeis
	PRIVATE cArquivo		// Nome do arquivo contra prova
EndIf
	                  
If Trim(cCodPro)==''
	Aviso("Existem campos em branco","Entre com o código de barras para endereçar",{"OK"})
	return
EndIf
If Trim(cLocPro)==''
	Aviso("Existem campos em branco","Entre com o endereço para endereçar",{"OK"})
	return
EndIf
If nQtdEst<=0
	Aviso("Existem campos em branco","Entre com uma quantidade de itens valido para endereçar",{"OK"})
	return
EndIf

dbSelectArea("SBE")
SBE->(dbsetOrder(9))	// BE_FILIAL, BE_LOCALIZ, R_E_C_N_O_, D_E_L_E_T_
SBE->(dbSeek(xFilial("SBE")+Trim(cLocPro)))

if SBE->(EOF())
	Aviso("Aviso","Endereço "+Trim(cLocPro)+" não é válido. Entre com um endereço existente ",{"OK"})
	Return	
EndIf

dbSelectArea("SDA")
SDA->(dbSetOrder(1))	// DA_FILIAL, DA_PRODUTO, DA_LOCAL, DA_NUMSEQ, DA_DOC, DA_SERIE, DA_CLIFOR, DA_LOJA, R_E_C_N_O_, D_E_L_E_T_
SDA->(dbSeek(xFilial("SDA")+cCodPro+'02'))

if SDA->(EOF())
	//Aviso("Aviso","Não foi possivel endereçar o item "+Trim(cCodPro)+". Item não possui endereço válido. ",{"OK"})
	//Return	
EndIf

lOk:=.F.
While !(SDA->(eof())) .And. cCodPro==SDA->DA_PRODUTO .And. SDA->DA_LOCAL =='02' .And. !lOk
	
	if SDA->DA_SALDO>=nQtdEst
		lOk:=.T.
	EndIf
	SDA->(dbSkip())
EndDo

if !lOk
//	Aviso("Aviso","Não há saldo suficiente deste produto para endereçar ",{"OK"})
	//Return	
EndIf


lMsErroAuto:=.F.
aCabSDA:={}
aItSDB:={}
_aItensSDB:={}
aCab:={}
aItem:={}
lOk:=.F.
nDocumento:=  NextNumero("SD3",2,"D3_DOC",.T.)   //Gera o proximo numero de documento



//a260Processa(SDA->DA_PRODUTO,SDA->DA_LOCAL,nQtdEst,nDocumento,DATE(),,,,,,,SDA->DA_PRODUTO,"03",,,,,,,,,,,,,,,,,,,,,,)

dbSelectArea("SDA")
SDA->(dbSetOrder(1))	// DA_FILIAL, DA_PRODUTO, DA_LOCAL, DA_NUMSEQ, DA_DOC, DA_SERIE, DA_CLIFOR, DA_LOJA, R_E_C_N_O_, D_E_L_E_T_
SDA->(dbSeek(xFilial("SDA")+cCodPro+'03'))

lOk:=.F.
While  !(SDA->(eof())).And. SDA->DA_PRODUTO==cCodPro .And. SDA->DA_LOCAL=='03' .And. !lOk

	iF SDA->DA_SALDO >=nQtdEst
		lOk:=.T.
		cProd:= SDA->DA_PRODUTO
		cLocaliz:= cLocPro
		cSequencia:=SDA->DA_NUMSEQ
		cDoc:= SDA->DA_DOC
		cLocal:= SDA->DA_LOCAL
	EndIf
	SDA->(dbSkip())
EndDo



if !lOk
	Aviso("Aviso","Não foi possivel endereçar o item "+Trim(SBE->BE_LOCAL)+". Não há saldo suficiente. ",{"OK"})
	Return	
EndIf



//Busca o proximo item na SDB se existir
cQuery:= " SELECT MAX(DB_ITEM) AS SEQUEN FROM "+RetSQlName("SDB")+" WITH(NOLOCK)	 "
cQuery+= " WHERE DB_FILIAL='"+xFilial("SDB")+"'  AND DB_PRODUTO='"+Trim(cCodPro)+"' AND "
cQuery+= " DB_LOCAL= '"+Trim(cLocal)+"' AND DB_NUMSEQ='"+Trim(cSequencia)+"' AND DB_LOCALIZ='" +Trim(cLocaliz)+"' AND D_E_L_E_T_='' "

IF (Select("TMPSDB") > 0 )
   		TMPSDB->(DbCloseArea())
EndIf

TCQuery cQuery  ALIAS "TMPSDB" NEW

if TMPSDB->(eof())
	nQuant:=1
Else
	nQuant:=Val(TMPSDB->SEQUEN) + 1
EndIf

cItem:=STRZERO(nQuant, 4)

if verifBorde(cProd)
	cLocaliz:='CA0000001' //Localização da carga
EndIf

EndePA(cProd,cSequencia,cDoc,cLocal,nQtdEst,cLocaliz,cItem)


Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fOrdPro() - Funcao para carregar dados da Ordem de Produção
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fOrdPro()
	
Return

Static Function calcQuant()

if cTipo=='U'  //Código de produto unitário
	nQtdEst:= nQrdInf
EndIf


Return

Static Function EndePA(_produt,_seq,_doc, _armaz,_quant,_ender,_item)


private cArea:=GetArea()

private aCab:={}
private aItem:={}	
private aCabSDA    := {}
private aItSDB         := {}
private _aItensSDB := {} 


private lMsErroAuto:=.F.

_produt:= _produt+Space( GetSx3Cache( "DB_PRODUTO" , "X3_TAMANHO" ) - Len(_produt) )
_seq:= _seq+Space( GetSx3Cache( "DB_NUMSEQ" , "X3_TAMANHO" ) - Len(_seq) )
_doc:= _doc+Space( GetSx3Cache( "DB_DOC" , "X3_TAMANHO" ) - Len(_doc) )
_armaz:= _armaz+Space( GetSx3Cache( "DB_LOCAL" , "X3_TAMANHO" ) - Len(_armaz) )
_ender:= _ender+Space( GetSx3Cache( "DB_LOCALIZ" , "X3_TAMANHO" ) - Len(_ender) )


//BEGIN TRANSACTION

			M->DB_LOCALIZ:=_ender
 			aCabSDA := {{"DA_PRODUTO" ,_produt,Nil},;  //15	    
						{"DA_NUMSEQ"  ,_seq,Nil}}  //6

			aItSDB := {{"DB_ITEM"	  ,_item	      ,Nil},;        //4           
				  {"DB_ESTORNO"  ," "	      ,Nil},;               //1   
				  {"DB_LOCALIZ"  ,_ender    ,Nil},;         //15          
				  {"DB_DATA"	  ,dDataBase    ,Nil},;                   
				  {"DB_QUANT"  ,_quant                  ,Nil}}      
	  
	  
	    		 aadd(_aItensSDB,aItSDB)
	   
	   
	   			begin transaction
      				
      				POSICIONE("SBE",1,xFilial("SBE")+_ender+_armaz,"BE_LOCALIZ")    //BE_FILIAL, BE_LOCAL, BE_LOCALIZ, R_E_C_N_O_, D_E_L_E_T_		
					MSExecAuto({|x,y,z| MATA265(x,y,z)},aCabSDA,_aItensSDB,3) 
					
					If lMsErroAuto 
					     Mostraerro() 
					     DisarmTransaction() 
						
					
					Else     
						
	   						MsgAlert("Enderaçamento Ok!")
					 
					Endif
	  
					   
END TRANSACTION  //Comita a transação

RestArea(cArea)

Return lMsErroAuto

/*
Verifica Se ja existe bordero em aberto com pedido de tal produto

*/

Static Function verifBorde(cProduto)

	Private cRet:= .F.


  cQuery:="  SELECT ZF_CODIGO, C9_BLEST ,C9_PEDIDO, C9_PRODUTO, C9_LOCAL, ZG_LOCALIZ "
 
  cQuery+="  FROM  "+RetSQlName("SZG")+" SZG WITH(NOLOCK) "  
  
  cQuery+="  		LEFT JOIN "+RetSQlName("SC9")+" SC9 WITH(NOLOCK)  ON ZG_FILIAL=C9_FILIAL AND SUBSTRING(ZG_PEDIDO,3,6) = C9_PEDIDO AND SZG.D_E_L_E_T_ = SC9.D_E_L_E_T_ "

  cQuery+="  		LEFT JOIN  "+RetSQlName("SZF")+" SZF  ON ZG_FILIAL = ZF_FILIAL AND ZG_CODIGO = ZF_CODIGO AND SZG.D_E_L_E_T_ = SZF.D_E_L_E_T_   "
  
  cQuery+="  		WHERE ZG_FILIAL='"+xFilial("SZG")+"' AND SZG.D_E_L_E_T_='' AND C9_BLEST='02' AND C9_PRODUTO= '"+Trim(cProduto)+"' "
  
  cQuery+="   					GROUP BY  ZF_CODIGO, C9_BLEST ,C9_PEDIDO, C9_PRODUTO, C9_LOCAL, ZG_LOCALIZ	"

  cQuery+="    				ORDER BY  ZF_CODIGO, C9_BLEST ,C9_PEDIDO, C9_PRODUTO, C9_LOCAL, ZG_LOCALIZ   "
  
  IF (Select("TMPSZG") > 0 )
   		TMPSZG->(DbCloseArea())
  EndIf

  TCQuery cQuery  ALIAS "TMPSZG" NEW
  
  if !(TMPSZG->(eof()))
  
  		cRet:=.T.
  		
  		//TMPSZG->(dbSkip())
  EndIf 
  


Return cRet

