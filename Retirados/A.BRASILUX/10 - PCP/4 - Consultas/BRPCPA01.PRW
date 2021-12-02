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
±±ºPrograma  ³ BRPCPA01 							  º Data ³  01/07/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±                  
±±ºDescricao ³ Consulta dos logs de baixas de Ordens de Produção 		  º±±
±±º          ³ Estorna O.Ps, Consulta O.Ps com Erros, O.Ps em Aberto      º±±
±±º          ³ Substituir o acompanhamento das O.Ps por Planilha          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß                                                         
/*/                                                                                                        
User Function BRPCPA01()
     Local _lOpen
     Private cAcessos   := ""
     Private cRotina    := "BRPCPA01"
     Private cCodUsr    := RetCodUsr()
     Private lAcs1      := .f.  //Acessa a Rotina
     Private lAcs2      := .f.  //Altera Informações ZZA
     Private lAcs3      := .f.  //Estorna P.I
     Private lAcs4      := .f.  //Exclui Apontadores Demitidos
     Private lAcs5      := .f.  //Estorna P.A
     Private lAcs6      := .f.  //Exclui ou Gera Saldo PI
     Private lAcs7      := .f.  //Mv_estneg
     Private oTempTbl01
     Private oTempTbl02
     Private oTempTbl03
     Private oTempTbl04
     Private oTempTbl05
     Private oTempTbl06
     Private oTempTbl07
     Private oTempTbl08
     Private oTempTbl09
     Private oTempTbl10
     Private oTempTbl11
     Private _cAliasSX3 := GetNextAlias()
     Private cCadastro  := "Log das Ordens de Produção"
     Private aRotina    := {}

     If (cNumEmp == "01010104")
        MsgBox("Essa empresa não utiliza esta Rotina! ","ATENÇÃO...","STOP")
        Return nil
     Endif

     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200206 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0
     
     If !_lOpen //LGS#20200206 - Adequação para release 12.1.25
        Return
     Endif
   	 cRotina  := Stuff(cRotina, Len(cRotina)+1, 10 - Len(cRotina), space(10 - Len(cRotina)))
   	 cAcessos := Posicione("SZW", 4, xFilial("SZW")+cRotina+cCodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS")

   	 lAcs1    := Iif(SubStr(cAcessos, 01, 1) == '*', .t., .f.) //Acessa a rotina
   	 lAcs2    := Iif(SubStr(cAcessos, 02, 1) == '*', .t., .f.) //Alterar ZZA
   	 lAcs3    := Iif(SubStr(cAcessos, 03, 1) == '*', .t., .f.) //Estorna P.I
   	 lAcs4    := Iif(SubStr(cAcessos, 04, 1) == '*', .t., .f.) //Exclui Apontadores Demitidos
   	 lAcs5    := Iif(SubStr(cAcessos, 05, 1) == '*', .t., .f.) //Estorna P.A
   	 lAcs6    := Iif(SubStr(cAcessos, 06, 1) == '*', .t., .f.) //Exclui ou Gera Saldo PI
   	 lAcs7    := Iif(SubStr(cAcessos, 07, 1) == '*', .t., .f.) //Mv_EstNeg


   

   aadd(aRotina, { OemToAnsi("Pesquisar")          , "AxPesqui"  	, 0, 1 } )
   aadd(aRotina, { OemToAnsi("Visualizar")	       , "AxVisual"  	, 0, 2 } )
   aadd(aRotina, { OemToAnsi("Alterar")            , "AxAltera"     , 0, 4 } )
   aadd(aRotina, { OemToAnsi("A Conferir")         , "U_PCPA01_3()"	, 0, 9 } )
   aadd(aRotina, { OemToAnsi("Abertas")            , "U_PCPA01_4()"	, 0, 9 } )
   aadd(aRotina, { OemToAnsi("Ops a Arquivar")     , "U_PCPA01_5()"	, 0, 9 } )
   aadd(aRotina, { OemToAnsi("Apontamentos")       , "U_PCPA01_7()"	, 0, 9 } )
   aadd(aRotina, { OemToAnsi("Estorna P.I")        , "U_PCPA01_E()"	, 0, 9 } )
   aadd(aRotina, { OemToAnsi("Estorna P.A")        , "U_PCPA01_F()"	, 0, 9 } )            
   aadd(aRotina, { OemToAnsi("Processa Baixa O.ps"), "U_PROBAIXAOP()", 0, 9 } )      
   aadd(aRotina, { OemToAnsi("Legenda")            , "U_PCPA01_2()"	, 0, 9 } )
   aadd(aRotina, { OemToAnsi("Arquivamento Ops")   , "U_fRecebOp()"	, 0, 9 } )
   aadd(aRotina, { OemToAnsi("Nomes_apontamento")  , "U_PCPA01R()"	, 0, 9 } )

   /*
     Private aRotina   := { {"Pesquisar"          , "AxPesqui    "	, 0, 1} ,;
                            {"Visualizar"         , "AxVisual    "	, 0, 2} ,;
                            {"A Conferir"         , "U_PCPA01_3()"	, 0, 9} ,;
                            {"Abertas"            , "U_PCPA01_4()"	, 0, 9} ,;
                            {"Ops a Arquivar"     , "U_PCPA01_5()"	, 0, 9} ,;
                            {"Apontamentos"       , "U_PCPA01_7()"	, 0, 9} ,;
                            {"Estorna P.I"        , "U_PCPA01_E()"	, 0, 9} ,;
                            {"Estorna P.A"        , "U_PCPA01_F()"	, 0, 9} ,;
                            {"Rel. Perda/Sobra"   , "U_PCPA01_P()"	, 0, 9} ,;
                            {"Rel. Inf. Especif"  , "U_BRPCPR20()"	, 0, 9} ,;  
							       {"PI Bras x PA Disso" , "U_PCPA01_R()"	, 0, 9} ,;   	 
			                   {"Processa Baixa O.ps", "U_PROBAIXAOP()" , 0, 9} ,;
			                   {"Legenda"            , "U_PCPA01_2()"	, 0, 9} ,;
			                   {"Arquivamento Ops"   , "U_fRecebOp()"	, 0, 9} ,;
      							 {"Nomes_apontamento"  , "U_PCPA01R()"	   , 0, 9}}


     If lAcs2 .or. u_fRetGrupoUser() $ '000000'  // Altera ZZA       
        aadd(aRotina, { OemToAnsi("Alterar")  , "AxAltera    ", 0, 4} )
     Endif
*/
     If lAcs4 .or. u_fRetGrupoUser() $ '000000' // Exclui Apontadores Demitidos
//     	aadd(aRotina, { OemToAnsi("Manut.  Apontadores")  , "U_BRPCPA66()", 0, 9} )  
   		aadd(aRotina, { OemToAnsi("Exclui Ap. Inativos")  , "U_PCPA01_A()", 0, 9} )
     Endif
     If lAcs6 .and. !u_fRetGrupoUser() $ '000000' // Exclui saldo 
     	aadd(aRotina, { OemToAnsi("Exclui Saldo PI")  , "U_fAtuaZZA()", 0, 9} )
     Endif     
     If lAcs7 .or. u_fRetGrupoUser() $ '000000' // Altera MV_ESTNEG
     	aadd(aRotina, { OemToAnsi("Altera Mv_EstNeg")  , "U_BRPCPA12()", 0, 9} )
     Endif
  
     Private aCores    := { {'Empty(ZZA->ZZA_FLAG)'   , 'BR_BRANCO'  } ,;
                            {'ZZA->ZZA_FLAG $ "E.1"'  , 'BR_VERDE'   } ,;
                            {'ZZA->ZZA_FLAG $ "2"'    , 'BR_AMARELO' } ,;
                            {'ZZA->ZZA_FLAG $ "3"'    , 'BR_AZUL'    } ,;
                            {'ZZA->ZZA_FLAG $ "4"'    , 'BR_LARANJA' } ,;
                            {'ZZA->ZZA_FLAG $ "5.9.B.P"', 'DISABLE'    } ,;
                            {'ZZA->ZZA_FLAG $ "6"'    , 'BR_PINK'    } ,;                            
                            {'ZZA->ZZA_FLAG $ "7"'    , 'BR_CINZA'   } ,;                            
                            {'ZZA->ZZA_FLAG $ "8"'    , 'BR_MARROM'  } ,;
                            {'ZZA->ZZA_FLAG $ "X"'    , 'BR_PRETO'   }  }
     Private cString   := "ZZA"

     If !lAcs1 
       	MsgBox("Usuário não possui acesso a essa a essa Rotina", "Atenção", "STOP")
       	Return
     Endif

     DbSelectArea("ZZA")
     DbSetOrder(1)

     DbSelectArea(cString)
         
     mBrowse( 06, 01, 22, 75, cString, , , , , , aCores)
    
     DbSelectArea(_cAliasSX3)
     DbCloseArea()

Return


User Function BRFATTPD()

Private oDlga
Private oOK      := LoadBitmap(GetResources(),'BR_VERDE')
Private oNO      := LoadBitmap(GetResources(),'BR_VERMELHO')          
//Private cGetPed1 :=Space(6)
//Private cGetPed2 :=Space(6)
//Private cGetProd :=Space(12)
Private aBrowse1 := {}
//Private aBrowse2 := {}


SetPrvt("oFont1", "oSayPed1", "oGetPed1", "oSayPed2", "oGetPed2", "oSayProd", "oGetProd","oBtnBusc")

DEFINE MSDIALOG oDlga FROM 0,0 TO 502,660 PIXEL TITLE 'CONSULTA SALDO ARMAZÉM INTERMEDIÁRIO' 

    
	Private oBrowse1 := TWBrowse():New( 020 , 001, 300, 210,,{'','CODIGO','DESCRIÇÃO','LOCAL','QTDE ATUAL'}  ,{15,45,140,20,10}, oDlga, ,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
    oFont1   := TFont():New( "MS Sans Serif", 0, -13, , .T., 0, , 700, .F., .F., , , , , , ) 
    //oSayPed1 := TSay():New( 004, 005, {|| "Pedido Orig.:"  }, oDlga, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 009 )

    TButton():New( 002, 240, "Carregar"     ,oDlga,{|| u_fBusPed()}, 40, 012, , , , .T., , "", , , , .F. )     
    TButton():New( 235, 240, "Sair"         ,oDlga,{|| oDlga:End()   },30,12,,,,.T.,,"",,,,.F.)
                 

//DelArqTmp() // funcao padrao para excluir arquivos temporarios da pasta \system
                         
// 	oDlga:Activate(,,,.T.)

//Return 


//User Function fBusPed()



    cQry :=" " 
	cQry +=" SELECT B2_COD, B1_DESC, B2_LOCAL, B2_QATU "
	cQry +=" FROM "+RetSqlName("SB2")+" SB2 WITH(NOLOCK) LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B2_FILIAL = B1_FILIAL AND B2_COD = B1_COD AND SB1.D_E_L_E_T_ ='' "
	cQry +=" WHERE B2_FILIAL ='"+XFilial("SB2")+"'  AND B2_QATU <> 0 AND SB2.D_E_L_E_T_ ='' AND B2_LOCAL IN('P1','P2') "
	cQry +=" ORDER BY B2_LOCAL, B2_COD "
	

    TCQuery cQry ALIAS "TCQ" NEW
    DbSelectArea("TCQ")
    DbGoTop()
	If !Eof()
    	While !Eof()//         1          2             3             4                5  
	    	aAdd(aBrowse1, { (.T.), TCQ->B2_COD, TCQ->B1_DESC, TCQ->B2_LOCAL, TCQ->B2_QATU } )    
        	DbSelectArea("TCQ")
        	DbSkip()
    	Enddo
    	oBrowse1:SetArray(aBrowse1)
		oBrowse1:bLine := {||{If(aBrowse1[oBrowse1:nAt,01],oOK,oNO),aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],aBrowse1[oBrowse1:nAt,04],aBrowse1[oBrowse1:nAt,05] } }
    	oBrowse1:Refresh()
		//oBrowse1:bLDblClick := {|| lEditCell(@aBrowse1,oBrowse1,'@9999!',4),aBrowse1[oBrowse1:nAt][1] := .F.,oBrowse1:DrawSelect()}
    Endif
	DbSelectArea("TCQ")
    DbCloseArea()
    
	
    oBrowse1:Refresh()
    oDlga:Activate(,,,.T.)


Return 

/*User Function BRFATTPD()

Private oDlga
Private oOK      := LoadBitmap(GetResources(),'BR_VERDE')
Private oNO      := LoadBitmap(GetResources(),'BR_VERMELHO')          
Private cGetPed1 :=Space(6)
Private cGetPed2 :=Space(6)
Private cGetProd :=Space(12)
Private aBrowse1 := {}
Private aBrowse2 := {}


SetPrvt("oFont1", "oSayPed1", "oGetPed1", "oSayPed2", "oGetPed2", "oSayProd", "oGetProd","oBtnBusc")

DEFINE MSDIALOG oDlga FROM 0,0 TO 502,860 PIXEL TITLE 'TROCA DE PRODUTOS RESERVADOS ENTRE PEDIDOS' 

    
	Private oBrowse1 := TWBrowse():New( 020 , 001, 220, 210,,{'','CODIGO','DESCRIÇÃO','QTD RESERV','LOCALIZ.'}  ,{25,40,15,10}, oDlga, ,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
	Private oBrowse2 := TWBrowse():New( 020 , 222, 210, 210,,{'','CODIGO','DESCRIÇÃO','QTD SOL.','QTD A RESER.'},{25,40,15,10}, oDlga, ,,,,{||},,,,,,,.T.,,.T.,,.T.,,,)
	//oTBrowseButton := TBrowseButton( 1, 1, "Ligar",, { || ShellExecute( "Open", "skype:cleitonalvesfernandes?call", "NULL", "C:\", 1 ) },50, 10 )
    oFont1   := TFont():New( "MS Sans Serif", 0, -13, , .T., 0, , 700, .F., .F., , , , , , ) 
    oSayPed1 := TSay():New( 004, 005, {|| "Pedido Orig.:"  }, oDlga, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 009 )
    oGetPed1 := TGet():New( 002, 053, {|u| If( PCount() > 0, cGetPed1 := u, cGetPed1) }, oDlga, 040, 010, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "", "cGetPed1", , )
    oSayPed2 := TSay():New( 004, 099, {|| "Pedido Dest.:"  }, oDlga, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 009 )
    oGetPed2 := TGet():New( 002, 148, {|u| If( PCount() > 0, cGetPed2 := u, cGetPed2) }, oDlga, 040, 010, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "", "cGetPed2", , )
    oSayProd := TSay():New( 004, 195, {|| "Produto.:"      }, oDlga, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 030, 009 )
    oGetProd := TGet():New( 002, 230, {|u| If( PCount() > 0, cGetProd := u, cGetProd) }, oDlga, 060, 010, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "", "cGetProd", , )


    TButton():New( 002, 310, "Carregar"     ,oDlga,{|| u_fBusPed()}, 40, 012, , , , .T., , "", , , , .F. )     
    TButton():New( 235, 140, "Qtd a Liberar",oDlga,{|| lEditCell(@aBrowse1,oBrowse1,'@9999!',4) },40,10,,,,.T.)
    TButton():New( 235, 310, "Legenda"      ,oDlga,{|| ShellExecute( "Open", "skype:cleitonalvesfernandes?call", "NULL", "C:\", 1 ) },35,10,,,,.T.)
    TButton():New( 235, 370, "Sair"         ,oDlga,{|| oDlga:End()   },30,10,,,,.T.,,"",,,,.F.)
                 

DelArqTmp() // funcao padrao para excluir arquivos temporarios da pasta \system
                         
 	oDlga:Activate(,,,.T.)

Return */


/*User Function fBusPed()

cGetPed1:='370559'
cGetPed2:='370382'

cGetProd:=''

    cQry :=" " 
	cQry +=" SELECT C9_PEDIDO, C9_PRODUTO, B1_DESC, C9_QTDLIB, ISNULL(DC_LOCALIZ,'') AS DC_LOCALIZ, CASE WHEN C9_BLEST ='02' THEN 'F' ELSE 'T' END AS C9_BLEST, C9_ITEM "
	cQry +=" FROM SC9010 SC9 WITH(NOLOCK) " 
    cQry +=" LEFT OUTER JOIN SB1010 SB1 WITH(NOLOCK) ON C9_FILIAL = B1_FILIAL AND C9_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ ='' "
	cQry +=" LEFT OUTER JOIN SDC010 SDC WITH(NOLOCK) ON DC_FILIAL = C9_FILIAL AND DC_PRODUTO = C9_PRODUTO AND DC_ITEM = C9_ITEM AND DC_PEDIDO = C9_PEDIDO AND SDC.D_E_L_E_T_ ='' "
	cQry +=" WHERE C9_PEDIDO ='"+cGetPed1+"' AND C9_FILIAL ='"+XFilial("SC9")+"' AND SC9.D_E_L_E_T_='' AND C9_NFISCAL ='' AND C9_BLEST <>'02' "
	If !Empty(cGetProd) 
		cQry +=" AND C9_PRODUTO ='"+CGetProd+"'" 
	Endif
	cQry +=" ORDER BY C9_PRODUTO "

    TCQuery cQry ALIAS "TCQ" NEW
    DbSelectArea("TCQ")
    DbGoTop()
	If !Eof()
    	While !Eof()         //                1                        2                   3             4                5              6               7
	    	aAdd(aBrowse1, {IIF(ALLTRIM(TCQ->C9_BLEST)='F',.F.,.T.),TCQ->C9_PRODUTO, TCQ->B1_DESC, TCQ->C9_QTDLIB, TCQ->DC_LOCALIZ, TCQ->C9_PEDIDO,TCQ->C9_ITEM } )    
        	DbSelectArea("TCQ")
        	DbSkip()
    	Enddo
    	oBrowse1:SetArray(aBrowse1)
		oBrowse1:bLine := {||{If(aBrowse1[oBrowse1:nAt,01],oOK,oNO),aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],aBrowse1[oBrowse1:nAt,04],aBrowse1[oBrowse1:nAt,05] } }
    	oBrowse1:Refresh()
		oBrowse1:bLDblClick := {|| lEditCell(@aBrowse1,oBrowse1,'@9999!',4),aBrowse1[oBrowse1:nAt][1] := .F.,oBrowse1:DrawSelect()}
    Endif
	DbSelectArea("TCQ")
    DbCloseArea()
    
    cQry :=" " 
	cQry +=" SELECT C9_PEDIDO, C9_PRODUTO, C6_DESCRI, C9_QTDLIB, ISNULL(DC_LOCALIZ,'') AS DC_LOCALIZ, CASE WHEN C9_BLEST ='02' THEN 'F' ELSE 'T' END AS C9_BLEST, C9_ITEM "
	cQry +=" FROM SC9010 SC9 WITH(NOLOCK) " 
	cQry +=" LEFT OUTER JOIN SC6010 SC6 WITH(NOLOCK) ON C6_FILIAL = C9_FILIAL AND C9_PRODUTO = C9_PRODUTO AND C9_ITEM = C6_ITEM AND C9_PEDIDO = C6_NUM AND SC6.D_E_L_E_T_ ='' "
	cQry +=" LEFT OUTER JOIN SDC010 SDC WITH(NOLOCK) ON DC_FILIAL = C9_FILIAL AND DC_PRODUTO = C9_PRODUTO AND DC_ITEM = C9_ITEM AND DC_PEDIDO = C9_PEDIDO AND SDC.D_E_L_E_T_ ='' "
	cQry +=" WHERE C9_PEDIDO ='"+cGetPed2+"' AND C9_FILIAL ='"+XFilial("SC9")+"' AND SC9.D_E_L_E_T_=''  AND C9_BLEST ='02' AND C9_NFISCAL ='' "
	If !Empty(cGetProd) 
		cQry +=" AND C9_PRODUTO ='"+CGetProd+"'" 
	Endif
	cQry +=" ORDER BY C9_PRODUTO "

    TCQuery cQry ALIAS "TCQ" NEW
    DbSelectArea("TCQ")
    DbGoTop()
    If !Eof()
	    While !Eof()         //                         1                2                3              4            5        6            7
		    aAdd(aBrowse2, {IIF(ALLTRIM(TCQ->C9_BLEST)='F',.F.,.T.),TCQ->C9_PRODUTO, TCQ->C6_DESCRI, TCQ->C9_QTDLIB,    ,TCQ->C9_PEDIDO, C9_ITEM} )    
	        DbSelectArea("TCQ")
	        DbSkip()
	    Enddo
		oBrowse2:SetArray(aBrowse2)
		oBrowse2:bLine := {||{If(aBrowse2[oBrowse2:nAt,01],oOK,oNO),aBrowse2[oBrowse2:nAt,02],aBrowse2[oBrowse2:nAt,03],aBrowse2[oBrowse2:nAt,04],aBrowse2[oBrowse2:nAt,05] } }
	    oBrowse2:Refresh()
		//oBrowse2:bLDblClick := {|| aBrowse2[oBrowse2:nAt][1] := !aBrowse2[oBrowse2:nAt][1],oBrowse2:DrawSelect()}
	Endif    
    
    DbSelectArea("TCQ")
    DbCloseArea()
	
    oBrowse1:Refresh()
    oBrowse2:Refresh()
    //oDlga:Activate(,,,.T.)


Return */

//LGS#20200131 - Adequação de release 12.1.25 e posteriores
/*
Static Function TstLegenda()

Local oDlg
PRIVATE oBMp1
PRIVATE oBMp2
PRIVATE oFnt
PRIVATE oSay 
	DEFINE MSDIALOG oDlg FROM 0,0 TO 80,180 PIXEL TITLE 'Legenda'
	
	oFnt := TFont():New('COMICS',,20,.T.,,,,,.T.,.F.)
	oSay := TSay():New(08,20,{|| ' - Reservado'},oDlg,,oFnt,,,,.T.,CLR_BLACK,CLR_BLACK)
	oSay := TSay():New(24,20,{|| ' - A Reservar'},oDlg,,oFnt,,,,.T.,CLR_BLACK,CLR_BLACK)
	
	//@ 010,010 BITMAP oBMP1 RESOURCE 'BR_VERDE' SIZE 025,025 OF oDlg PIXEL
	
	oBMP1 := tBitMap():Create(oDlg)
	oBMP1:SetBMP('BR_VERDE')
	oBMP1:nLeft := 18
	oBMP1:nTop := 20
	oBMP1:lAutoSize := .T.

	//@ 025,010 BITMAP oBMP2 RESOURCE 'BR_VERMELHO' SIZE 025,025 OF oDlg PIXEL
	oBMP2 := tBitMap():Create(oDlg)
	oBMP2:SetBMP('BR_VERMELHO')
	oBMP2:nLeft := 18
	oBMP2:nTop := 52
	oBMP2:lAutoSize := .T.	

	
	ACTIVATE MSDIALOG oDlg CENTERED
		
Return nil		*/

//LGS#20200131 - Adequação de release 12.1.25 e posteriores
/*
Static Function LibTrocP()
Local nY, nX
Local aPed1 :={} // Recebe os itens que foram marcados para serem trocados, este item perderá a reserva
	    
	Begin Transaction

		For nY:= 1 to Len(aBrowse1)
			If aBrowse1[oBrowse1:nAt,01] =.F.
				aAdd(aPed1, {aBrowse1[oBrowse1:nAt,06],aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,04],aBrowse1[oBrowse1:nAt,05],aBrowse1[oBrowse1:nAt,07]} )    
    		Endif
		Next
		For nX:= 1 to Len(aBrowse2)
			If aBrowse2[oBrowse2:nAt,01] =.T.
				aAdd(aPed2, {aBrowse2[oBrowse2:nAt,06],aBrowse2[oBrowse1:nAt,02],aBrowse2[oBrowse1:nAt,04],aBrowse2[oBrowse2:nAt,05],aBrowse2[oBrowse2:nAt,07]} )    
    		Endif
		Next
        // Estorna Item Marcado

		DBSelectArea("SC9")
		SC9->(DBSetOrder(1))	// C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
		SC9->(DbSeek(xFilial("SC9")+aBrowse1[oBrowse1:nAt,02]+aBrowse1[oBrowse1:nAt,07])) // Posiciona no registro da SC9 que possue estoque liberado
		While !(SC9->(eof())) .AND. aBrowse1[oBrowse1:nAt,02]== SC9->C9_PEDIDO .AND. aBrowse1[oBrowse1:nAt,07]== SC9->C9_ITEM 
			SC9->(a460Estorna())  
			SC9->(dbSkip())		 
		EndDo
		DbSelectArea("SC9")
		DbCloseArea()	

		DbSelectArea("SC6")	   
		SC6->(DbSetOrder(1))// C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_  
		SC6->(DbSeek(xFilial("SC6")+aBrowse1[oBrowse1:nAt,02]))
		If !(SC6->(eof())) .AND. xFilial("SC6")== SC6->C6_FILIAL .AND. aBrowse1[oBrowse1:nAt,02] == SC6->C6_NUM
			SC6->(MaLiberOk({aBrowse1[oBrowse1:nAt,02]},.F.))
		Endif

		DbSelectArea("SC6")
		DbCloseArea()

	    //Libera Item Marcado


	End Transaction

    
    // LIBERA AVALIANDO APENAS ESTOQUE
    //(Registro do SC6  ,Quantidade a Liberar,Bloqueio de Credito,Bloqueio de Estoque,Avaliacao de Credito,Avaliacao de Estoque,Permite Liberacao Parcial,Tranfere Locais automaticamente )
	MaLibDoFat(SC6->(RecNo()) ,SC6->C6_QTDVEN            ,.T.                ,.T.                ,.F.               ,.T.                 ,.F.                      ,.F.,,,,,,0,)

	
   
Return()*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PCPA01_A³ - Exclui Apontadores Que já foram demitidos	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function PCPA01_A()

Local cQry1  := ""
Local cFunc  := ""

    DelArqTmp() 
    If !lAcs4  
       MsgBox("Usuário não possui acesso a essa a essa Rotina", "Atenção", "STOP")
       Return
    Endif
    TcRefresh("ZZE") 
    TcRefresh("ZZE010")    

    TcRefresh("SPED400") 
    TcRefresh("SPED400")    

    cQry1 := " "
	cQry1 +=" SELECT X5_TABELA,X5_CHAVE, RA_NOME , RA_MAT"
	cQry1 +=" FROM "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) "
	cQry1 +=" LEFT OUTER JOIN "+RetSqlName("SRA")+" SRA WITH (NOLOCK) ON RA_FILIAL = X5_FILIAL AND RA_MAT = X5_CHAVE "
	cQry1 +=" WHERE X5_TABELA IN('XB','XE','XC','XL') AND SX5.D_E_L_E_T_ ='' AND RA_DEMISSA <>'' "
	cQry1 +=" AND RA_FILIAL ='"+xFilial("SRA")+"' "
	cQry1 +=" ORDER BY RA_DEMISSA "
    TCQuery cQry1 ALIAS "TCQ" NEW
    DbSelectArea("TCQ")
    DbGoTop()
    While !Eof()
    	cFunc += SUBSTR(TCQ->RA_MAT,1,4)+" - "+Alltrim(TCQ->RA_NOME)+CHR(13)+CHR(10)
        DbSelectArea("TCQ")
        DbSkip()
    Enddo
    If Len(cFunc)> 0
    	If MsgYesNo("Deseja Remover da Lista de Apontadores os funcionários que estão inativos??"+CHR(13)+CHR(10)+(cFunc)+".", "Atenção")	
	   		cQry1 := " "
	   		cQry1 += " UPDATE "+RetSqlName("SX5")+" SET D_E_L_E_T_ ='*' FROM "+RetSqlName("SX5")+" SX5 LEFT OUTER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = X5_FILIAL AND RA_MAT = X5_CHAVE "
	   		cQry1 += " WHERE X5_TABELA IN('XB','XE','XC','XL') AND SX5.D_E_L_E_T_ ='' AND RA_DEMISSA <>'' AND RA_FILIAL ='"+xFilial("SRA")+"'"
	   		XXX := TCSQLExec(cQry1) 
		    Messagebox("Nomes removidos com Sucesso !!","Atenção...",64) 	
		Endif	   		
    Else
    	Messagebox("Não existe(m) apontador(es) inativo(s) para ser(em) excluído(s) !!","Atenção...",64)
    Endif
    DbSelectArea("TCQ")
    DbCloseArea()

Return


User Function PCPA01_2()
     Local ny       := 0
     Local nx       := 0
     Local cTitulo  := OemToAnsi("Log")
     Local cMensagem:= OemToAnsi("Log de Baixa de OP")
     Local aCores   := { {"BR_VERDE"   , "OP TINTAS / PASTAS / CONCENT. - APTO DE INICIO"        },; //1
                         {"BR_AMARELO" , "OP TINTAS / PASTAS / CONCENT. - APTO PESAGEM"          },; //2
                         {"BR_AZUL"    , "OP TINTAS / PASTAS / CONCENT. - APTO COLORISTA"        },; //3
                         {"BR_LARANJA" , "OP TINTAS / PASTAS / CONCENT. - APTO LABORATÓRIO"      },; //4
                         {"DISABLE"    , "OP TINTAS / PASTAS / CONCENT. - BAIXADA"               },; //5
                         {"BR_PINK"    , "OP ENVASE                     - APTO DE INICIO"        },; //6
                         {"BR_CINZA"   , "OP ENVASE                     - APTO DE BAIXA PARCIAL" },; //7
                         {"BR_MARROM"  , "OP ENVASE                     - APTO DE BAIXA TOTAL"   },; //8
                         {"DISABLE"    , "OP ENVASE                     - BAIXADA"               } } //5
//						 {"BR_BRANCO  ", ""                         },; //
     Local aBmp[Len(aCores)]
     //Local aSays[Len(aCores)]
     Local oDlgLeg
     nXSize := 14

     DEFINE MSDIALOG oDlgLeg FROM 0,0 TO (Len(aCores)*20)+50,554 TITLE cTitulo Of oMainWnd PIXEL
            oDlgLeg:bLClicked:= {||oDlgLeg:End()}
            DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
            @ 0 , 0 BITMAP RESNAME "PROJETOAP" oF oDlgLeg SIZE 35,155 NOBORDER WHEN .F. PIXEL
            @ 11,35 TO 013,400 LABEL '' OF oDlgLeg PIXEL
            @ 03,37 SAY cMensagem OF oDlgLeg PIXEL SIZE 100,009 FONT oBold
            For nx := 1 to Len(aCores)
                @ 19+((nx-1)*10),44 BITMAP aBmp[nx] RESNAME aCores[nx][1] of oDlgLeg SIZE 20,20 NOBORDER WHEN .F. PIXEL
                @ 19+((nx-1)*10),(nXSize/2) + 47 SAY If((ny+=1)==ny,aCores[ny][2]+If(ny==Len(aCores),If((ny:=0)==ny,"",""),""),"") of oDlgLeg PIXEL
            Next
            ny := 0
     ACTIVATE MSDIALOG oDlgLeg CENTERED
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PCPA01_5³ -Consulta Ordens de Producao a Arquivar    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function PCPA01_5()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private nCBxOrd := "Emissao"
     Private cGetInf := Space(10)
     Private aSelLin := {}

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1", "oDlg1", "oSay1", "oSay2", "oBrwSC2", "oBtn1", "oBtn2", "oCBxOrd", "oGetInf", "oBtn3")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1     := TFont():New( "@Arial Unicode MS", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1      := MSDialog():New( 088, 232, 561, 1062, "Ordens de Produção abertas", , , .F., , , , , , .T., , , .T. )
     oSay1      := TSay():New( 004, 068, {||"CONSULTA DAS ORDENS DE PRODUÇÃO A ARQUIVAR"}, oDlg1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 276, 012)
     oSay2      := TSay():New( 222, 096, {||"Pesquisa:"} , oDlg1, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008)
     oGetInf    := TGet():New( 221, 132, {|u| If(PCount() > 0, cGetInf := u, cGetInf)}, oDlg1, 060, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetInf", ,)
     oGetInf:bLostFocus := {|| fBusInf() }
     oTblA()
     DbSelectArea("TC2")
     DbSetOrder(1)
     oBrwSC2    := MsSelect():New( "TC2", "", "", {{"TC2_ORDEM", "", "Ordem", "@R XXXXXX-99-999"}, {"TC2_LOTE", "", "Lote", "@R 999999"}, {"TC2_PRODUTO", "", "Produto", "@R XXX99.99.999-99"}, {"TC2_EMISSAO", "", "Emissao", "@R 99/99/9999"}, {"TC2_QUANT", "", "Qtde", "@B 999,999.99"}, {"TC2_LINHA", "", "Linha", "@R XX"}, {"TC2_INIC", "", "Iniciadas", ""}, {"TC2_FINAL", "", "Finalizadas", ""}}, .F., , {024, 000, 216, 412}, , , oDlg1 ) 
     oBtn1      := TButton():New( 220, 316, "Imprimir", oDlg1, {|| fImpInf(1)   }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn2      := TButton():New( 220, 372, "Sair"    , oDlg1, {|| oDlg1:End() }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn3      := TButton():New( 220, 196, "Buscar"  , oDlg1, {|| fBusInf()   }, 037, 012, , , , .T., , "", , , , .F. )
     oCBxOrd    := TComboBox():New( 220, 004, {|u| If(PCount() > 0, nCBxOrd := u, nCBxOrd)}, {"Ordem", "Lote", "Linha", "Emissao", "Produto", "Inicio", "Inicio (Inverso)", "Final", "Final (Inverso)"}, 072, 010, oDlg1, , , , CLR_BLACK, CLR_WHITE, .T., , "", , , , , , , nCBxOrd )
     oCBxOrd:bLostFocus := {|| fMudOrd()}

     oDlg1:Activate(,,,.T.)
     DbSelectArea("TC2")
     DbCloseArea()
     oTempTbl01:Delete()
Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTblA() - Cria temporario para o Alias: TC2
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTblA()
       Local aFds := {}
       //Local cTmp

       aAdd( aFds , {"TC2_ORDEM" , "C", 011, 000} )
       aAdd( aFds , {"TC2_LOTE"  , "C", 006, 000} )
       aAdd( aFds , {"TC2_PRODUT", "C", 015, 000} )
       aAdd( aFds , {"TC2_EMISSA", "D", 010, 000} )
       aAdd( aFds , {"TC2_QUANT" , "N", 010, 002} )
       aAdd( aFds , {"TC2_LINHA" , "C", 002, 000} )
       aAdd( aFds , {"TC2_INIC"  , "C", 018, 000} )
       aAdd( aFds , {"TC2_FINAL" , "C", 018, 000} )
       aAdd( aFds , {"TC2_INIINV", "C", 018, 000} )
       aAdd( aFds , {"TC2_FININV", "C", 018, 000} )
       aAdd( aFds , {"TC2_FLAG"  , "C", 001, 000} )

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 03/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cTmp := CriaTrab( aFds, .T. )
       //DbUseArea(.t., , cTmp, "TC2", .t., .f.)

       //DbCreateIndex(SubStr(cTmp, 1, 10)+'1', "TC2_ORDEM ", {|| "TC2_ORDEM "})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'2', "TC2_LOTE  ", {|| "TC2_LOTE  "})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'3', "TC2_LINHA ", {|| "TC2_LINHA "})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'4', "TC2_EMISSA", {|| "TC2_EMISSA"})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'5', "TC2_PRODUT", {|| "TC2_PRODUT"})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'6', "TC2_INIC"  , {|| "TC2_INIC"  })
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'7', "TC2_INIINV", {|| "TC2_INIINV"})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'8', "TC2_FINAL" , {|| "TC2_FINAL" })
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'9', "TC2_FININV", {|| "TC2_FININV"})
       
       //DbClearInd()
       //DbSetIndex(SubStr(cTmp, 1, 10)+'1')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'2')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'3')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'4')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'5')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'6')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'7')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'8')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'9')
       oTempTbl01 := FWTemporaryTable():New( "TC2" )
       oTempTbl01:SetFields( aFds )
       oTempTbl01:AddIndex( "cInd01", { "TC2_ORDEM"  } )
       oTempTbl01:AddIndex( "cInd02", { "TC2_LOTE"   } )
       oTempTbl01:AddIndex( "cInd03", { "TC2_LINHA"  } )
       oTempTbl01:AddIndex( "cInd04", { "TC2_EMISSA" } )
       oTempTbl01:AddIndex( "cInd05", { "TC2_PRODUT" } )
       oTempTbl01:AddIndex( "cInd06", { "TC2_INIC"   } )
       oTempTbl01:AddIndex( "cInd07", { "TC2_INIINV" } )
       oTempTbl01:AddIndex( "cInd08", { "TC2_FINAL"  } )
       oTempTbl01:AddIndex( "cInd09", { "TC2_FININV" } )
       oTempTbl01:Create()
       /********************************************************************************************************************************/
       DbSetOrder(4)
       
       MsgRun(OemToAnsi("Selecionando Ordens de Produção..."), OemToAnsi("Aguarde..."), { ||fBusOps()} )
Return
     
/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fBusOps()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fBusOps()
       Local cQry1 := ""
       //Buscar dados da tabela SC2 para todos as Ordens de Produçõa em aberto.
       cQry1 += "SELECT SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN AS ORDEM, SC2.C2_LOTE AS LOTE, SC2.C2_PRODUTO AS PRODUT, SC2.C2_QUANT AS QUANT, SC2.C2_EMISSAO AS EMISSAO, ZZA.ZZA_DTINI AS DTINI, ZZA.ZZA_HINI AS HINI, ZZA.ZZA_DTFIM AS DTFIM, ZZA.ZZA_HFIM AS HFIM, ZZA.ZZA_FLAG AS FLAG "
       cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) ON ZZA.ZZA_FILIAL = SC2.C2_FILIAL AND ZZA.ZZA_ORDEM = SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN AND ZZA.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = SC2.C2_FILIAL AND SB1.B1_COD = SC2.C2_PRODUTO AND SB1.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
       cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
       cQry1 += "  AND SC2.C2_DATRF  <> '' "
       cQry1 += "  AND ZZA.ZZA_ENVIA  = '' "
       cQry1 += "  AND SB1.B1_TIPO    = 'PI'"    
       cQry1 += "  AND ZZA.ZZA_DTFIM <> '' "
       cQry1 += "ORDER BY SC2.C2_EMISSAO "

       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       aSelLin := {}
       While !Eof()
             cSelLin := space(02)
             RecLock("TC2", .t.)
                TC2->TC2_ORDEM  := TCQ->ORDEM
                TC2->TC2_LOTE   := TCQ->LOTE
                TC2->TC2_PRODUT := TCQ->PRODUT
                TC2->TC2_EMISSA := STOD(TCQ->EMISSAO)
                TC2->TC2_QUANT  := TCQ->QUANT
                If Len(Alltrim(TCQ->PRODUT)) == 6
                   TC2->TC2_LINHA := 'CA'
                   cSelLin := 'CA'
                ElseIf Len(Alltrim(TCQ->PRODUT)) == 5
                       TC2->TC2_LINHA := 'CS'
                       cSelLin := 'CS'
                ElseIf Len(Alltrim(TCQ->PRODUT)) == 4
                       TC2->TC2_LINHA := 'PT'
                       cSelLin := 'PT'
                Else
                   TC2->TC2_LINHA := SubStr(TCQ->PRODUT, 4, 2)
                   cSelLin := SubStr(TCQ->PRODUT, 4, 2)
                Endif
                TC2->TC2_INIC   := DTOC(STOD(TCQ->DTINI))+' - '+Transform(TCQ->HINI, "@R 99:99")
                TC2->TC2_INIINV := INVERTE(DTOC(STOD(TCQ->DTINI))+' - '+Transform(TCQ->HINI, "@R 99:99"))
                TC2->TC2_FINAL  := DTOC(STOD(TCQ->DTFIM))+' - '+Transform(TCQ->HFIM, "@R 99:99")
                TC2->TC2_FININV := INVERTE(DTOC(STOD(TCQ->DTFIM))+' - '+Transform(TCQ->HFIM, "@R 99:99"))
                TC2->TC2_FLAG   := TCQ->FLAG
             MsUnLock()
             nPos := aScan(aSelLin, {|x| x[1] == cSelLin})
             If nPos == 0
                aAdd(aSelLin, {cSelLin, Iif(cSelLin $ 'CA', "Concentrado Base d'agua", Iif(cSelLin $ 'CS', "Concentrado Base solvente", Iif(cSelLin $ 'PT', "Pastas/Soluções", Posicione("SZ1", 1, xFilial("SZ1")+cSelLin, "Z1_DESCR") ) ) ) } )
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TC2")
       DbGoTop()
       //Verificar o status da mesma na tabela de apontamentos ZZA 
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fMudOrd()  Muda Ordenação
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fMudOrd()
       DbSelectArea("TC2")
       DbSetOrder(oCBxOrd:nAt)
       DbGoTop()
       If oCBxOrd:nAt == 1     //Ordem
          oSay2:lVisibleControl := .t.
          oGetInf:lVisibleControl := .t.
          oBtn3:lVisibleControl := .t.
          cGetInf := Space(11)
       ElseIf oCBxOrd:nAt == 2 //Lote
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(06)
       ElseIf oCBxOrd:nAt == 3 //Linha
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(2)
       ElseIf oCBxOrd:nAt == 4 //Emissão
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(10)
       ElseIf oCBxOrd:nAt == 5 //Produto
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(15)
       ElseIf oCBxOrd:nAt == 6 //Inicio
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(18)
       ElseIf oCBxOrd:nAt == 7 //Inicio (invertido)
              oSay2:lVisibleControl := .f.
              oGetInf:lVisibleControl := .f.
              oBtn3:lVisibleControl := .f.
       ElseIf oCBxOrd:nAt == 8 //Final
              oSay2:lVisibleControl := .t.                                                                         
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(18)
       ElseIf oCBxOrd:nAt == 9 //Final (invertido)
              oSay2:lVisibleControl := .f.
              oGetInf:lVisibleControl := .f.
              oBtn3:lVisibleControl := .f.
       Endif
       oBrwSC2:oBrowse:Refresh()
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PCPA01_4³ -Consulta Ordens de Producao em Aberto 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function PCPA01_4()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private nCBxOrd := "Emissao"
     Private cGetInf := Space(10)
     Private aSelLin := {}

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1", "oDlg1", "oSay1", "oSay2", "oBrwSC2", "oBtn1", "oBtn2", "oCBxOrd", "oGetInf", "oBtn3")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1     := TFont():New( "@Arial Unicode MS", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1      := MSDialog():New( 088, 232, 561, 1062, "Ordens de Produção abertas", , , .F., , , , , , .T., , , .T. )
     oSay1      := TSay():New( 004, 068, {||"CONSULTA DAS ORDENS DE PRODUÇÃO EM ABERTO"}, oDlg1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 276, 012)
     oSay2      := TSay():New( 222, 096, {||"Pesquisa:"} , oDlg1, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008)
     oGetInf    := TGet():New( 221, 132, {|u| If(PCount() > 0, cGetInf := u, cGetInf)}, oDlg1, 060, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetInf", ,)
     oGetInf:bLostFocus := {|| fBusInf() }
     oTbl1()
     DbSelectArea("TC2")
     DbSetOrder(1)
     oBrwSC2    := MsSelect():New( "TC2", "", "", {{"TC2_ORDEM", "", "Ordem", "@R XXXXXX-99-999"}, {"TC2_LOTE", "", "Lote", "@R 999999"}, {"TC2_PRODUTO", "", "Produto", "@R XXX99.99.999-99"}, {"TC2_EMISSAO", "", "Emissao", "@R 99/99/9999"}, {"TC2_QUANT", "", "Qtde", "@B 999,999.99"}, {"TC2_LINHA", "", "Linha", "@R XX"}, {"TC2_INIC", "", "Iniciadas", ""}, {"TC2_FINAL", "", "Finalizadas", ""}}, .F., , {024, 000, 216, 412}, , , oDlg1 ) 
     oBtn1      := TButton():New( 220, 316, "Imprimir", oDlg1, {|| fImpInf(2)   }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn2      := TButton():New( 220, 372, "Sair"    , oDlg1, {|| oDlg1:End() }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn3      := TButton():New( 220, 196, "Buscar"  , oDlg1, {|| fBusInf()   }, 037, 012, , , , .T., , "", , , , .F. )
     oCBxOrd    := TComboBox():New( 220, 004, {|u| If(PCount() > 0, nCBxOrd := u, nCBxOrd)}, {"Ordem", "Lote", "Linha", "Emissao", "Produto", "Inicio", "Inicio (Inverso)", "Final", "Final (Inverso)"}, 072, 010, oDlg1, , , , CLR_BLACK, CLR_WHITE, .T., , "", , , , , , , nCBxOrd )
     oCBxOrd:bLostFocus := {|| fMudaOrdem()}

     oDlg1:Activate(,,,.T.)
     DbSelectArea("TC2")
     DbCloseArea()
     oTempTbl02:Delete()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1() - Cria temporario para o Alias: TC2
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1()
       Local aFds := {}
       //Local cTmp

       aAdd( aFds , {"TC2_ORDEM" , "C", 011, 000} )
       aAdd( aFds , {"TC2_LOTE"  , "C", 006, 000} )
       aAdd( aFds , {"TC2_PRODUT", "C", 015, 000} )
       aAdd( aFds , {"TC2_EMISSA", "D", 010, 000} )
       aAdd( aFds , {"TC2_QUANT" , "N", 010, 002} )
       aAdd( aFds , {"TC2_LINHA" , "C", 002, 000} )
       aAdd( aFds , {"TC2_INIC"  , "C", 018, 000} )
       aAdd( aFds , {"TC2_FINAL" , "C", 018, 000} )
       aAdd( aFds , {"TC2_INIINV", "C", 018, 000} )
       aAdd( aFds , {"TC2_FININV", "C", 018, 000} )
       aAdd( aFds , {"TC2_FLAG"  , "C", 001, 000} )

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 03/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cTmp := CriaTrab( aFds, .T. )
       //DbUseArea(.t., , cTmp, "TC2", .t., .f.)

       //DbCreateIndex(SubStr(cTmp, 1, 10)+'1', "TC2_ORDEM ", {|| "TC2_ORDEM "})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'2', "TC2_LOTE  ", {|| "TC2_LOTE  "})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'3', "TC2_LINHA ", {|| "TC2_LINHA "})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'4', "TC2_EMISSA", {|| "TC2_EMISSA"})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'5', "TC2_PRODUT", {|| "TC2_PRODUT"})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'6', "TC2_INIC"  , {|| "TC2_INIC"  })
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'7', "TC2_INIINV", {|| "TC2_INIINV"})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'8', "TC2_FINAL" , {|| "TC2_FINAL" })
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'9', "TC2_FININV", {|| "TC2_FININV"})
       
       //DbClearInd()
       //DbSetIndex(SubStr(cTmp, 1, 10)+'1')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'2')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'3')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'4')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'5')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'6')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'7')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'8')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'9')
       oTempTbl02 := FWTemporaryTable():New( "TC2" )
       oTempTbl02:SetFields( aFds )
       oTempTbl02:AddIndex( "cInd01", { "TC2_ORDEM"  } )
       oTempTbl02:AddIndex( "cInd02", { "TC2_LOTE"   } )
       oTempTbl02:AddIndex( "cInd03", { "TC2_LINHA"  } )
       oTempTbl02:AddIndex( "cInd04", { "TC2_EMISSA" } )
       oTempTbl02:AddIndex( "cInd05", { "TC2_PRODUT" } )
       oTempTbl02:AddIndex( "cInd06", { "TC2_INIC"   } )
       oTempTbl02:AddIndex( "cInd07", { "TC2_INIINV" } )
       oTempTbl02:AddIndex( "cInd08", { "TC2_FINAL"  } )
       oTempTbl02:AddIndex( "cInd09", { "TC2_FININV" } )
       oTempTbl02:Create()
       /********************************************************************************************************************************/
       DbSetOrder(4)
       
       MsgRun(OemToAnsi("Selecionando Ordens de Produção..."), OemToAnsi("Aguarde..."), { ||fBusDad()} )
Return
     
/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fBusDad()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fBusDad()
       Local cQry1 := ""
       //Buscar dados da tabela SC2 para todos as Ordens de Produçõa em aberto.
       cQry1 += "SELECT SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN AS ORDEM, SC2.C2_LOTE AS LOTE, SC2.C2_PRODUTO AS PRODUT, SC2.C2_QUANT AS QUANT, SC2.C2_EMISSAO AS EMISSAO, ZZA.ZZA_DTINI AS DTINI, ZZA.ZZA_HINI AS HINI, ZZA.ZZA_DTFIM AS DTFIM, ZZA.ZZA_HFIM AS HFIM, ZZA.ZZA_FLAG AS FLAG "
       cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) ON ZZA.ZZA_FILIAL = SC2.C2_FILIAL AND ZZA.ZZA_ORDEM = SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN AND ZZA.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
       cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
       cQry1 += "  AND SC2.C2_DATRF   = '' "
       cQry1 += "ORDER BY SC2.C2_EMISSAO "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       aSelLin := {}
       While !Eof()
             cSelLin := space(02)
             RecLock("TC2", .t.)
                TC2->TC2_ORDEM  := TCQ->ORDEM
                TC2->TC2_LOTE   := TCQ->LOTE
                TC2->TC2_PRODUT := TCQ->PRODUT
                TC2->TC2_EMISSA := STOD(TCQ->EMISSAO)
                TC2->TC2_QUANT  := TCQ->QUANT
                If Len(Alltrim(TCQ->PRODUT)) == 6
                   TC2->TC2_LINHA := 'CA'
                   cSelLin := 'CA'
                ElseIf Len(Alltrim(TCQ->PRODUT)) == 5
                       TC2->TC2_LINHA := 'CS'
                       cSelLin := 'CS'
                ElseIf Len(Alltrim(TCQ->PRODUT)) == 4
                       TC2->TC2_LINHA := 'PT'
                       cSelLin := 'PT'
                Else
                   TC2->TC2_LINHA := SubStr(TCQ->PRODUT, 4, 2)
                   cSelLin := SubStr(TCQ->PRODUT, 4, 2)
                Endif
                TC2->TC2_INIC   := DTOC(STOD(TCQ->DTINI))+' - '+Transform(TCQ->HINI, "@R 99:99")
                TC2->TC2_INIINV := INVERTE(DTOC(STOD(TCQ->DTINI))+' - '+Transform(TCQ->HINI, "@R 99:99"))
                TC2->TC2_FINAL  := DTOC(STOD(TCQ->DTFIM))+' - '+Transform(TCQ->HFIM, "@R 99:99")
                TC2->TC2_FININV := INVERTE(DTOC(STOD(TCQ->DTFIM))+' - '+Transform(TCQ->HFIM, "@R 99:99"))
                TC2->TC2_FLAG   := TCQ->FLAG
             MsUnLock()
             nPos := aScan(aSelLin, {|x| x[1] == cSelLin})
             If nPos == 0
                aAdd(aSelLin, {cSelLin, Iif(cSelLin $ 'CA', "Concentrado Base d'agua", Iif(cSelLin $ 'CS', "Concentrado Base solvente", Iif(cSelLin $ 'PT', "Pastas/Soluções", Posicione("SZ1", 1, xFilial("SZ1")+cSelLin, "Z1_DESCR") ) ) ) } )
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TC2")
       DbGoTop()
       //Verificar o status da mesma na tabela de apontamentos ZZA 
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fMudaOrdem()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fMudaOrdem()
       DbSelectArea("TC2")
       DbSetOrder(oCBxOrd:nAt)
       DbGoTop()
       If oCBxOrd:nAt == 1     //Ordem
          oSay2:lVisibleControl := .t.
          oGetInf:lVisibleControl := .t.
          oBtn3:lVisibleControl := .t.
          cGetInf := Space(11)
       ElseIf oCBxOrd:nAt == 2 //Lote
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(06)
       ElseIf oCBxOrd:nAt == 3 //Linha
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(2)
       ElseIf oCBxOrd:nAt == 4 //Emissão
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(10)
       ElseIf oCBxOrd:nAt == 5 //Produto
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(15)
       ElseIf oCBxOrd:nAt == 6 //Inicio
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(18)
       ElseIf oCBxOrd:nAt == 7 //Inicio (invertido)
              oSay2:lVisibleControl := .f.
              oGetInf:lVisibleControl := .f.
              oBtn3:lVisibleControl := .f.
       ElseIf oCBxOrd:nAt == 8 //Final
              oSay2:lVisibleControl := .t.                                                                         
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(18)
       ElseIf oCBxOrd:nAt == 9 //Final (invertido)
              oSay2:lVisibleControl := .f.
              oGetInf:lVisibleControl := .f.
              oBtn3:lVisibleControl := .f.
       Endif
       oBrwSC2:oBrowse:Refresh()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fBusInf()   
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fBusInf()
       DbSelectArea("TC2")
       DbSetOrder(oCBxOrd:nAt)
       If oCBxOrd:nAt == 4
          DbSeek(CTOD(cGetInf))
       Else
          DbSeek(cGetInf)
       Endif
       oBrwSC2:oBrowse:Refresh()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºDescricao ³ Impressão das Sobras e Perdas dos apontamentos de Produção º±±
±±º          ³ André Maester                             Data 28/10/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PCPA01_P()
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Declaracao de Variaveis                                             ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
       Local cDesc2        := "de acordo com os parametros informados pelo usuario."
       Local cDesc3        := "Relação de Sobras ou Perdas no Apontamento de Produção"
       //Local cPict         := ""
       Local titulo        := "Relação de Perdas ou Sobras durante Apontamento"                                                          
       Local nLin          := 80
       Local Cabec1        := ""
       Local Cabec2        := ""
       //Local imprime       := .T.
       Local aOrd          := {}
       Private lEnd        := .F.
       Private lAbortPrint := .F.
       //Private CbTxt       := ""
       Private limite      := 132
       Private tamanho     := "M"
       Private nomeprog    := "BRPCPA01" // Coloque aqui o nome do programa para impressao no cabecalho
       Private nTipo       := 18
       Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
       Private nLastKey    := 0
       Private cPerg       := "APCP03"
       Private cbtxt       := Space(10)
       Private cbcont      := 0
       Private CONTFL      := 1
       Private m_pag       := 01
       Private wnrel       := "BRPCPA01" // Coloque aqui o nome do arquivo usado para impressao em disco
       Private cString     := "ZZA"
       Private cRetLin     := ''
       //DbSelectArea("TC2")
       //DbSetOrder(1)

       //oPerg3()        //LGS#20200203 - Adequação ao release 12.1.25 e posteriores
       Pergunte(cPerg,.T.)
              
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta a interface padrao com o usuario...                           ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       wnrel := SetPrint(cString, NomeProg,      , @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)
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
 	   
       Processa({|| fRunRel1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ fRunRel1  º Autor ³ 					   º Data ³ 28/10/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fRunRel1(Cabec1, Cabec2, Titulo, nLin)
	
	   Local nTotalSp   := 0
       Local cLinhaAnt  := ""
	   //Local nTotalAnt  := 0
	   Local cQry := ""

	   /*  *** *** *** *** *** *** *** *** *** 
	   *** *** *** *** *** *** *** *** *** ***        
	   *** mv_par01 - Da Data              ***  
	   *** mv_par02 - Ate a Data 		   *** 
	   *** mv_par03 - Da Linha  		   *** 
	   *** mv_par04 - Até a Linha		   *** 
	   *** mv_par05 - Do Produto 		   *** 
	   *** mv_par06 - Até o Produto		   *** 
	   *** mv_par07 - Sobras/Perdas		   *** 
	   *** mv_par08 - Analitico/Sintético  *** 
	   *** *** *** *** *** *** *** *** *** ***
	   */

	   If Mv_Par08 =1  // (ANALITICO OU SINTÉTICO)
	   	  cQry := " SELECT "+Iif(!Empty(mv_par04),"SUBSTRING(ZZA_PRODUT ,1,5)","ZZA_PRODUT")+" AS ZZA_PRODUT,"+Iif(!Empty(mv_par04),"Z1_DESCR","B1_DESC")+" ,SUM(ZZA_QUANT) AS ZZA_QUANT, "
          cQry += " CASE WHEN ZZA_SP ='1' THEN COUNT(ZZA_ORDEM) END AS ZZA_CPERDA, "
	      cQry += " CASE WHEN ZZA_SP ='6' THEN COUNT(ZZA_ORDEM) END AS ZZA_CSOBRA, "
	   Elseif Mv_Par08 = 2
	   	  cQry := " SELECT ZZA_ORDEM,ZZA_PRODUT, B1_DESC ,SUM(ZZA_QUANT) AS ZZA_QUANT," 
	   Endif
	   cQry += " SUM(ZZA_PERDA) AS ZZA_PERDA, SUM(ZZA_SOBRA) AS ZZA_SOBRA, ROUND(((SUM(ZZA_PERDA) / SUM(ZZA_QUANT) )*100),4) AS ZZA_PER, "
       cQry += " ROUND(((SUM(ZZA_SOBRA) / SUM(ZZA_QUANT) )*100),4) AS ZZA_SOB  "
	   cQry += " FROM "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) "
	   cQry += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON ZZA_FILIAL = B1_FILIAL AND ZZA_PRODUT = B1_COD AND SB1.D_E_L_E_T_ ='' " 
	   cQry += " LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) ON (Z1_FILIAL = '"+xFilial("SZ1")+"') AND (SUBSTRING(ZZA_PRODUT,4,2) = Z1_LINHA) AND SZ1.D_E_L_E_T_ ='' " 
	   cQry += " WHERE ZZA_FILIAL ='"+xFilial("ZZA")+"' AND ZZA.D_E_L_E_T_ ='' AND ZZA_SP ='"+Iif((mv_par07)=1,"6","1")+"'  AND ZZA_FLAG ='5' "
	   cQry += " AND ZZA_DTLOG BETWEEN ('"+dtos(mv_par01)+"') AND ('"+dtos(mv_par02)+"')"
	   If Mv_Par08 = 1
	       If Empty(mv_par06) .and. !Empty(mv_par04)
	   	   	   cQry += " AND SUBSTRING(ZZA_PRODUT,4,2) BETWEEN ('"+mv_par03+"') AND ('"+mv_par04+"')"
	   		   cQry += " GROUP BY SUBSTRING(ZZA_PRODUT ,1,5), SUBSTRING(ZZA_PRODUT ,4,2), ZZA_SP, Z1_DESCR "	   
   	   	       cQry += " ORDER BY SUBSTRING(ZZA_PRODUT ,4,2) "
	       ElseIf Empty(mv_par04) .and. !Empty(mv_par06) 
	   	       cQry += " AND ZZA_PRODUT BETWEEN ('"+mv_par05+"') AND ('"+mv_par06+"')"
	   		   cQry += " GROUP BY ZZA_PRODUT, SUBSTRING(ZZA_PRODUT ,4,2), ZZA_SP,  B1_DESC "
	           cQry += " ORDER BY ZZA_PRODUT "
	       Elseif (!Empty(mv_par04) .and. !Empty(mv_par06)) .or.  (Empty(mv_par04) .and. Empty(mv_par06))
   	       	   cQry += " AND SUBSTRING(ZZA_PRODUT,4,2) BETWEEN ('"+mv_par03+"') AND ('"+mv_par04+"')"
   	           cQry += " GROUP BY SUBSTRING(ZZA_PRODUT ,1,5), SUBSTRING(ZZA_PRODUT ,4,2), ZZA_SP, Z1_DESCR "	   
   	           cQry += " ORDER BY SUBSTRING(ZZA_PRODUT ,4,2) "
   	       Endif    
	   Elseif Mv_par08 = 2
	       If Empty(mv_par06) .and. !Empty(mv_par04)
	   	   	   cQry += " AND SUBSTRING(ZZA_PRODUT,4,2) BETWEEN ('"+mv_par03+"') AND ('"+mv_par04+"')"
	       Endif
	       If Empty(mv_par04) .and. !Empty(mv_par06) 
	   	       cQry += " AND ZZA_PRODUT BETWEEN ('"+mv_par05+"') AND ('"+mv_par06+"')"
	       Endif
  		   cQry += " GROUP BY ZZA_ORDEM, ZZA_PRODUT, SUBSTRING(ZZA_PRODUT ,4,2), ZZA_SP, B1_DESC "  	   
	   	   cQry += " ORDER BY SUBSTRING(ZZA_PRODUT ,4,2),ZZA_PRODUT, ZZA_ORDEM "
	   Endif
   	   
       TCQuery cQry ALIAS "TCQ" NEW

       DbSelectArea("TCQ")
       DbGoTop()

       ProcRegua(RecCount())

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
               	If Mv_Par08 = 1                                                 
               		Cabec1 :=" "+Iif((Mv_Par08)=1,"CARAC / LINHA    DESC LINHA","PRODUTO          DESCRIÇÃO ")+"                          QTD LITROS     "+Iif((Mv_Par07)=1,"PERDA LTS","SOBRA LTS")+"        % "+Iif((Mv_Par07)=1,"PERDA","SOBRA")+"    O.PS ENVASADAS"
                Elseif Mv_Par08 = 2
  	              	Cabec1 :=" ORD. PROD       PRODUTO        DESCRIÇÃO                          QTD LITROS    "+Iif((Mv_Par07)=1,"PERDA LTS","SOBRA LTS")+"    % "+Iif((Mv_Par07)=1,"PERDA","SOBRA")+"  
  	            Endif	
                nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                nLin += 1
            Endif

            If Mv_Par08 =1
            	If Alltrim(cLinhaAnt) <> Substr(TCQ->ZZA_PRODUT,4,2) .and. Len(cLinhaAnt)=2
            		@ nLin,000 PSAY replicate("-",110)
               		nLin += 1
               		@ nLin,068 PSAY Iif((Mv_par07)=1,"TOTAL PERDA NESTA LINHA..: ","TOTAL SOBRA NESTA LINHA..: ")
           			@ nLin,100 PSAY nTotalSp     Picture "@E 999,999.99"
           			nTotalSp :=0
           			nLin += 2
				Endif            	
			    @ nLin,001 PSAY TCQ->ZZA_PRODUT  Picture "@R XX 999999999"            
            	If Empty(mv_par06)
	           		@ nLin,018 PSAY Substr(TCQ->Z1_DESCR,1,30)
				Elseif Empty(mv_par04)
					@ nLin,018 PSAY Substr(TCQ->B1_DESC,1,30)
				Endif		
            	@ nLin,050 PSAY TCQ->ZZA_QUANT   Picture "@E 999,999,999.999"
            	If Mv_par07 = 2
              		@ nLin,067 PSAY TCQ->ZZA_PERDA   Picture "@E 99,999.9999"
	         		@ nLin,081 PSAY TCQ->ZZA_PER     Picture "@E 99,999.9999"
             	 	@ nLin,098 PSAY TCQ->ZZA_CPERDA  Picture "@E 99999"
             	   	nTotalSp := (nTotalSp + TCQ->ZZA_PERDA)
            	Elseif Mv_par07 =1
             		@ nLin,067 PSAY TCQ->ZZA_SOBRA   Picture "@E 99,999.99"
	         		@ nLin,081 PSAY TCQ->ZZA_SOB     Picture "@E 99,999.99"
             		@ nLin,098 PSAY TCQ->ZZA_CSOBRA  Picture "@E 99999"
	                nTotalSp := (nTotalSp + TCQ->ZZA_SOBRA)
            	Endif
           		cLinhaAnt := Substr(TCQ->ZZA_PRODUT,4,2) 
           	    nLin += 1 // Avanca a linha de impressao
            
		    ElseIf Mv_Par08 = 2
            	If Alltrim(cLinhaAnt) <> Substr(TCQ->ZZA_PRODUT,4,2) .and. Len(cLinhaAnt)=2
            		@ nLin,000 PSAY replicate("-",110)
               		nLin += 1
               		@ nLin,068 PSAY Iif((Mv_par07)=1,"TOTAL PERDA NESTA LINHA..: ","TOTAL SOBRA NESTA LINHA..: ")
           			@ nLin,100 PSAY nTotalSp     Picture "@E 999,999.99"
           			nTotalSp :=0
           			nLin += 2
				Endif            	

                @ nLin,001 PSAY TCQ->ZZA_ORDEM  Picture "@R XXXXXX99999"
            	@ nLin,015 PSAY TCQ->ZZA_PRODUT  Picture "@R XX 999999999"
				@ nLin,030 PSAY Substr(TCQ->B1_DESC,1,30)
            	@ nLin,063 PSAY TCQ->ZZA_QUANT   Picture "@E 999,999,999.99"
            	If Mv_par07 = 2
              		@ nLin,080 PSAY TCQ->ZZA_PERDA   Picture "@E 99,999.99"
	         		@ nLin,090 PSAY TCQ->ZZA_PER     Picture "@E 99,999.99"
             	   	nTotalSp := (nTotalSp + TCQ->ZZA_PERDA)
            	Elseif Mv_par07 =1
             		@ nLin,080 PSAY TCQ->ZZA_SOBRA   Picture "@E 99,999.99"
	         		@ nLin,090 PSAY TCQ->ZZA_SOB     Picture "@E 99,999.99"
	                nTotalSp := (nTotalSp + TCQ->ZZA_SOBRA)
            	Endif
           		cLinhaAnt := Substr(TCQ->ZZA_PRODUT,4,2) 
           	    nLin += 1 // Avanca a linha de impressao
		    Endif	

           	DbSelectArea("TCQ")
           	DbSkip() // Avanca o ponteiro do registro no arquivo
       EndDo
  	   
  	   @ nLin,000 PSAY replicate("-",110)
       nLin += 1
       @ nLin,068 PSAY Iif((Mv_par07)=1,"TOTAL PERDA NESTA LINHA..: ","TOTAL SOBRA NESTA LINHA..: ")
       @ nLin,100 PSAY nTotalSp     Picture "@E 999,999.99"

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
Function  ³ oPerg3() - Cria grupo de Perguntas.
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
//LGS#20200203 - Adequação ao release 12.1.25 e posteriores
/*Static Function oPerg3()

       Local aHelpPor := {}

	   AAdd(aHelpPor, {{"Informe a data Inicial a ser consultada"			  }, {""}, {""}})
	   AAdd(aHelpPor, {{"Informe a data final a ser consultada"				  }, {""}, {""}})
	   AAdd(aHelpPor, {{"Informe a linha  do produto"						  }, {""}, {""}})
	   AAdd(aHelpPor, {{"Informe a linha  do produto"                         }, {""}, {""}})
	   AAdd(aHelpPor, {{"Informe o código do produto"                         }, {""}, {""}})
	   AAdd(aHelpPor, {{"Informe o código do produto"                         }, {""}, {""}})
	   AAdd(aHelpPor, {{"Escolha entre (Perdas ou Sobras na produção"         }, {""}, {""}})
	   AAdd(aHelpPor, {{"Informe o tipo de relatório (Analitico ou Sintético)"}, {""}, {""}})
       
       PutSx1( 'APCP03', '01', 'Da Data             ? ' , '', '', 'mv_ch1', 'D',08,00,00, 'G', '', ''        , ''          , '', 'mv_par01', ''         , '', ''		 , '', ''     , '', '', '', '', '', '', '', '', '', '', '', aHelpPor[1,1], {}, {} )
       PutSx1( 'APCP03', '02', 'Ate a Data          ? ' , '', '', 'mv_ch2', 'D',08,00,00, 'G', '', ''        , ''          , '', 'mv_par02', ''         , '', ''		 , '', ''     , '', '', '', '', '', '', '', '', '', '', '', aHelpPor[2,1], {}, {} )
	   PutSX1( 'APCP03', '03', 'Da Linha            ? ' , '', '', 'mv_ch3', 'C',02,00,00, 'G', '', ''        , ''          , '', 'mv_par03', ''		    , '', ''		 , '', ''	  , '', '', '', '', '', '', '', '', '', '', '', aHelpPor[3,1], {}, {} )
       PutSX1( 'APCP03', '04', 'Até a Linha         ? ' , '', '', 'mv_ch4', 'C',02,00,00, 'G', '', ''        , ''          , '', 'mv_par04', ''		    , '', ''		 , '', ''	  , '', '', '', '', '', '', '', '', '', '', '', aHelpPor[4,1], {}, {} )
	   PutSX1( 'APCP03', '05', 'Do Produto          ? ' , '', '', 'mv_ch5', 'C',15,00,00, 'G', '', 'SB1'	 , ''          , '', 'mv_par05', ''		    , '', ''		 , '', ''	  , '', '', '', '', '', '', '', '', '', '', '', aHelpPor[5,1], {}, {} )
       PutSX1( 'APCP03', '06', 'Até o Produto       ? ' , '', '', 'mv_ch6', 'C',15,00,00, 'G', '', 'SB1'     , ''          , '', 'mv_par06', ''		    , '', ''		 , '', ''	  , '', '', '', '', '', '', '', '', '', '', '', aHelpPor[6,1], {}, {} )
	   PutSX1( 'APCP03', '07', 'Sobras/Perdas       ? ' , '', '', 'mv_ch7', 'N',01,00,01, 'C', '', ''        , ''          , '', 'mv_par07', 'Sobras'   , '', 'Perdas'   , '', ''     , '', '', '', '', '', '', '', '', '', '', '', aHelpPor[7,1], {}, {} )
	   PutSX1( 'APCP03', '08', 'Analitico/Sintético ? ' , '', '', 'mv_ch8', 'N',01,00,01, 'C', '', ''        , ''          , '', 'mv_par08', 'Analitico', '', 'Sintético', '', ''     , '', '', '', '', '', '', '', '', '', '', '', aHelpPor[8,1], {}, {} )

       aHelpPor := {}
Return*/


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºDescricao ³ Impressão de Ordens de Produção Abertas                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fImpInf(nOpc)
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Declaracao de Variaveis                                             ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
       Local cDesc2        := "de acordo com os parametros informados pelo usuario."
       Local cDesc3        := "Relação de OPs Abertas"
       //Local cPict         := ""
       Local titulo        := Iif(nOpc =1,"Relação de Ops a Arquivar","Relação de OPs Abertas")                                                          
       Local nLin          := 80
       Local Cabec1        := "ORDEM          LOTE    PRODUTO          QTDE.     DT. INICIO          STATUS"
       Local Cabec2        := ""
       //Local imprime       := .T.
       Local aOrd          := {}
       Private lEnd        := .F.
       Private lAbortPrint := .F.
       //Private CbTxt       := ""
       Private limite      := 80
       Private tamanho     := "P"
       Private nomeprog    := "BRPCPA01" // Coloque aqui o nome do programa para impressao no cabecalho
       Private nTipo       := 18
       Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
       Private nLastKey    := 0
       Private cPerg       := ""
       Private cbtxt       := Space(10)
       Private cbcont      := 0
       Private CONTFL      := 1
       Private m_pag       := 01
       Private wnrel       := "BRPCPA01" // Coloque aqui o nome do arquivo usado para impressao em disco
       Private cString     := "TC2"
       Private cRetLin     := ''
       Private mvpar01
       DbSelectArea("TC2")
       DbSetOrder(1)
        
       //oPerg1() //LGS#20200203 - Adequação ao release 12.1.25 e posteriores
       If Pergunte('APCP01', .t.)
          mvpar01 := mv_par01
          If mvpar01 == 1
             fSelLin()
             If Empty(cRetLin)
                Return
             Endif
          ElseIf mvpar01 == 2
               If !Pergunte('APCP02', .t.)
                  Return
               Endif
          Endif
       Else
          Return
       Endif

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta a interface padrao com o usuario...                           ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       wnrel := SetPrint(cString, NomeProg,      , @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

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

/*/
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
/*/
Static Function fRunRel(Cabec1, Cabec2, Titulo, nLin)

       //Local nOrdem

       DbSelectArea(cString)
       DbSetOrder(1)
       If mvpar01 == 1
          cFilTC2 := "TC2_LINHA $ cRetLin"
          DbSetFilter( {||&cFilTC2}, cFilTC2 )
       ElseIf mvpar01 == 2
              cDatIni := DTOC(mv_par01)+' - 00:00'
              cDatFim := DTOC(mv_par02)+' - 00:00'
              cFilTC2 := "TC2_INIC >= cDatIni .and. TC2_INIC <= cDatFim "
              DbSetFilter( {||&cFilTC2}, cFilTC2 )
       Endif
       ProcRegua(RecCount())
       DbSetOrder(7)
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

             // ORDEM          LOTE    PRODUTO          QTDE.     DT. INICIO          STATUS
             // 999999-99-999  999999  XX 99.99.999-99  9,999.99  99/99/9999 - 99:99  XXXXXXXXX
             // 1234567890123  123456  123456789012345  12345678  123456789012345678
             // 1234567890123456789012345678901234567890123456789012345678901234567890123456789
             //          1         2         3         4         5         6         7
             @ nLin,001 PSAY TC2->TC2_ORDEM   Picture "@R XXXXXX-99-999"
             @ nLin,016 PSAY TC2->TC2_LOTE    Picture "@R 999999"
             @ nLin,024 PSAY TC2->TC2_PRODUT  Picture "@R XXX99.99.999-99"
             @ nLin,041 PSAY TC2->TC2_QUANT   Picture "@E 9,999.99"
             @ nLin,051 PSAY TC2->TC2_INIC
             If !Empty(TC2->TC2_FLAG)
                If TC2->TC2_FLAG == '1'
                   @ nLin, 071 PSAY "TPC INICI" Picture "@!"
                ElseIf TC2->TC2_FLAG == '2'
                       @ nLin, 071 PSAY "TPC PESAG" Picture "@!"
                ElseIf TC2->TC2_FLAG == '3'
                       @ nLin, 071 PSAY "TPC COLOR" Picture "@!"
                ElseIf TC2->TC2_FLAG == '4'
                       @ nLin, 071 PSAY "TPC LABOR" Picture "@!"
                ElseIf TC2->TC2_FLAG == '5'
                       @ nLin, 071 PSAY "FINALIZAD" Picture "@!"
                ElseIf TC2->TC2_FLAG == '6'
                       @ nLin, 071 PSAY "E. INICIO" Picture "@!"
                ElseIf TC2->TC2_FLAG == '7'
                       @ nLin, 071 PSAY "E. PARCIA" Picture "@!"
                ElseIf TC2->TC2_FLAG == '8'
                       @ nLin, 071 PSAY "E. TOTAL " Picture "@!"
                ElseIf TC2->TC2_FLAG == 'X'
                       @ nLin, 071 PSAY "EXCLUIDA " Picture "@!"
                Endif
             Endif
             nLin += 1 // Avanca a linha de impressao
             DbSelectArea("TC2")
             DbSkip() // Avanca o ponteiro do registro no arquivo
       EndDo
       Set Filter To
       DbGoTop()
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
Function  ³ oPerg1() - Cria grupo de Perguntas.
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
//LGS#20200203 - Adequação ao release 12.1.25 e posteriores
/*
Static Function oPerg1()
       Local aHelpPor := {}
       aAdd(aHelpPor, "Selecione um item para emissao do relatorio.  "      )
       aAdd(aHelpPor, "Linha - Seleciona as Linhas a serem impressas."      )
       aAdd(aHelpPor, "Inicio - Seleciona as OPs. pelo inicio de produção." )
       PutSx1( 'APCP01', '01', 'Tipo do Relatório', '', '', 'mv_ch1', 'N', 1, 0, 1, 'C', '', '', '', '', 'mv_par01', 'Linha', '', '', '', 'Inicio', '', '', '', '', '', '', '', '', '', '', '', aHelpPor, {}, {} )
       aHelpPor := {}

       aAdd(aHelpPor, "Informe a data inicial do perido a ser impresso."      )
       PutSx1( 'APCP02', '01', 'Da Data'          , '', '', 'mv_ch1', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par01', ''     , '', '', '', ''      , '', '', '', '', '', '', '', '', '', '', '', aHelpPor, {}, {} )
       PutSx1( 'APCP02', '02', 'Ate a Data'       , '', '', 'mv_ch2', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par02', ''     , '', '', '', ''      , '', '', '', '', '', '', '', '', '', '', '', aHelpPor, {}, {} )
       aHelpPor := {}
Return */

Static Function fSelLin()
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oDlg2", "oBrwLin", "oBtnCon", "oBtnSai")

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
      ±± Definicao do Dialog e todos os seus componentes.                        ±±
      Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
      oDlg2      := MSDialog():New( 088, 232, 323, 540, "Selecione as linhas", , , .F., , , , , , .T., , , .T. )
      oTbl2()
      DbSelectArea("LIN")

      DbSetOrder(1)
      oBrwLin    := MsSelect():New( "LIN", "MARCA", "", {{"MARCA","","",""}, {"LINHA","","Linha","XX"}, {"DESC","","Descricao","@!"}}, .F., , {004, 004, 096, 148}, , , oDlg2 ) 
      oBtnCon    := TButton():New( 100, 064, "Confirmar", oDlg2, {|| fMarcaLinh(), oDlg2:End()}, 037, 012, , , , .T., , "", , , , .F. )
      oBtnSai    := TButton():New( 100, 108, "Sair"     , oDlg2, {|| cRetLin := '', oDlg2:End()}, 037, 012, , , , .T., , "", , , , .F. )

      oDlg2:Activate(,,,.T.)
      DbSelectArea("LIN")
      DbCloseArea()
      oTempTbl05:Delete()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl2() - Cria temporario para o Alias: LIN
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl2()
       Local aFds := {}
       //Local cTmp
       Local nZ

       aAdd( aFds , {"MARCA", "C", 002, 000} )
       aAdd( aFds , {"LINHA", "C", 002, 000} )
       aAdd( aFds , {"DESC" , "C", 025, 000} )

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 06/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cTmp := CriaTrab( aFds, .T. )
       //Use (cTmp) Alias LIN New Exclusive
       //Index On LINHA To (cTmp)
       oTempTbl05 := FWTemporaryTable():New( "LIN" )
       oTempTbl05:SetFields( aFds )
       oTempTbl05:AddIndex( "cInd01", { "LINHA" } )
       oTempTbl05:Create()
       /********************************************************************************************************************************/

       For nZ := 1 To Len(aSelLin)
           RecLock("LIN", .t.)
              LIN->MARCA := ""
              LIN->LINHA := aSelLin[nZ][1]
              LIN->DESC  := aSelLin[nZ][2]
           MsUnLock()
       Next
       DbSelectArea("LIN")
       DbGoTop()
Return

Static Function fMarcaLinh()
       cRetLin := ''
       DbSelectArea("LIN")
       DbGoTop()
       While !Eof()
             If LIN->( IsMark("MARCA", ThisMark(), ThisInv() ) )
                cRetLin += "."+LIN->LINHA
             Endif
             DbSelectArea("LIN")
             DbSkip()
       EndDo
       DbSelectArea("LIN")
       DbGoTop()
       If !Empty(cRetLin)
          cRetLin := "'"+SubStr(cRetLin, 2)+"'"
       Endif
Return(cRetLin)                   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa ³PCPA01_3³ Consulta Ordens de Producao Pendentes de Conferência³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function PCPA01_3()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private nCBxOrd := "Ordem" 
     Private cGetInf := Space(10)
     Private aSelLin := {}

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1", "oDlg1", "oSay1", "oSay2", "oBrwSC2", "oBtn1", "oBtn2", "oCBxOrd", "oGetInf", "oBtn3")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1     := TFont():New( "@Arial Unicode MS", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1      := MSDialog():New( 088, 232, 561, 1062, "Consulta Ordens de Produção Pendentes", , , .F., , , , , , .T., , , .T. )
     oSay1      := TSay():New( 004, 068, {||"CONSULTA DAS ORDENS DE PRODUÇÃO PENDENTES"}, oDlg1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 276, 012)
     oSay2      := TSay():New( 222, 096, {||"Pesquisa:"} , oDlg1, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008)
     oGetInf    := TGet():New( 221, 132, {|u| If(PCount() > 0, cGetInf := u, cGetInf)}, oDlg1, 060, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetInf", ,)
     oGetInf:bLostFocus := {|| fOrdErr() }
     oTbl3()
     DbSelectArea("TZA")
     DbSetOrder(1)
     oBrwSC2    := MsSelect():New( "TZA", "", "", {{"TZA_ORDEM", "", "Ordem", "@R XXXXXX-99-999"}, {"TZA_LOTE", "", "Lote", "@R 999999"}, {"TZA_PRODUTO", "", "Produto", "@R XXX99.99.999-99"}, {"TZA_QUANT", "", "Quantidade", "@B 999,999.99"}, {"TZA_LINHA", "", "Linha", "@R XX"}, {"TZA_EMISSAO", "", "Dt. LOG", "@R 99/99/9999"}, {"TZA_HORA", "", "Hora", ""},{"TZA_HELP", "", "Help", ""} , {"TZA_CAMPO", "", "Erro", ""}}, .F., , {024, 000, 216, 412}, , , oDlg1 ) 
     oBtn1      := TButton():New( 220, 316, "Imprimir"      , oDlg1, {|| fImpErr()   }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn2      := TButton():New( 220, 372, "Sair"          , oDlg1, {|| oDlg1:End() }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn3      := TButton():New( 220, 196, "Buscar"        , oDlg1, {|| fOrdErr()   }, 037, 012, , , , .T., , "", , , , .F. )
     //oBtn4      := TButton():New( 220, 272, "Apontamentos"  , oDlg1, {|| U_PCPA01_7()}, 039, 012, , , , .T., , "", , , , .F. )     
     oCBxOrd    := TComboBox():New( 220, 004, {|u| If(PCount() > 0, nCBxOrd := u, nCBxOrd)}, {"Ordem", "Lote", "Linha", "Dt. LOG", "Produto"}, 072, 010, oDlg1, , , , CLR_BLACK, CLR_WHITE, .T., , "", , , , , , , nCBxOrd )
     oCBxOrd:bLostFocus := {|| fMudaErro()}

     oDlg1:Activate(,,,.T.)
     DbSelectArea("TZA")
     DbCloseArea()
     oTempTbl03:Delete()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl3() - Cria temporario para o Alias: TC2
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl3()
       Local aFds := {}
       //Local cTmp

       aAdd( aFds , {"TZA_ORDEM" , "C", 011, 000} )
       aAdd( aFds , {"TZA_LOTE"  , "C", 006, 000} )
       aAdd( aFds , {"TZA_PRODUT", "C", 015, 000} )
       aAdd( aFds , {"TZA_EMISSA", "D", 010, 000} )
       aAdd( aFds , {"TZA_QUANT" , "N", 010, 002} )
       aAdd( aFds , {"TZA_LINHA" , "C", 002, 000} )
       aAdd( aFds , {"TZA_HELP"  , "C", 030, 000} )
       aAdd( aFds , {"TZA_CAMPO" , "C", 050, 000} )
       aAdd( aFds , {"TZA_FLAG"  , "C", 001, 000} )
       aAdd( aFds , {"TZA_HORA"  , "C", 006, 000} )

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 03/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cTmp := CriaTrab( aFds, .T. )
       //DbUseArea(.t., , cTmp, "TZA", .t., .f.)

       //DbCreateIndex(SubStr(cTmp, 1, 10)+'1', "TZA_ORDEM ", {|| "TZA_ORDEM "})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'2', "TZA_LOTE  ", {|| "TZA_LOTE  "})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'3', "TZA_LINHA ", {|| "TZA_LINHA "})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'4', "TZA_EMISSA", {|| "TZA_EMISSA"})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'5', "TZA_PRODUT", {|| "TZA_PRODUT"})
       
       //DbClearInd()
       //DbSetIndex(SubStr(cTmp, 1, 10)+'1')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'2')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'3')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'4')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'5')
       
       oTempTbl03 := FWTemporaryTable():New( "TZA" )
       oTempTbl03:SetFields( aFds )
       oTempTbl03:AddIndex( "cInd01", { "TZA_ORDEM"  } )
       oTempTbl03:AddIndex( "cInd02", { "TZA_LOTE"   } )
       oTempTbl03:AddIndex( "cInd03", { "TZA_LINHA"  } )
       oTempTbl03:AddIndex( "cInd04", { "TZA_EMISSA" } )
       oTempTbl03:AddIndex( "cInd05", { "TZA_PRODUT" } )
       /********************************************************************************************************************************/
       DbSelectArea("TZA")
       DbSetOrder(1)

       MsgRun(OemToAnsi("Selecionando Ordens de Produção..."), OemToAnsi("Aguarde..."), { ||fBusErr()} )
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fBusErr()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fBusErr()
       Local cQry1 := ""
       //Buscar dados da Tabela ZZA para todos as Ordens de Produção que tem pelo menos 1 apontamento e que não passaram por conferência
       cQry1 += "SELECT ZZA.ZZA_ORDEM, ZZA.ZZA_LOTE, ZZA.ZZA_PRODUT, ZZA.ZZA_QUANT, ZZA.ZZA_DTLOG, ZZA.ZZA_HORA, ZZA.ZZA_HELP, ZZA.ZZA_CAMPO, ZZA.ZZA_FLAG "
       cQry1 += "FROM "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON ZZA.ZZA_FILIAL = SB1.B1_FILIAL AND ZZA.ZZA_PRODUT = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' " 
       cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
       cQry1 += "  AND ZZA.D_E_L_E_T_ = '' AND ZZA.ZZA_FLAG IN('5') AND ZZA.ZZA_SP ='' "
       cQry1 += "  AND SB1.B1_TIPO ='PI' AND LEN(ZZA.ZZA_PRODUT)=12 "  
       cQry1 += "  AND (SELECT COUNT(ZZA_LOTE) FROM "+RetSqlName("ZZA")+" ZZA1 WITH (NOLOCK) WHERE ZZA1.ZZA_FILIAL = ZZA.ZZA_FILIAL AND ZZA1.ZZA_LOTE = ZZA.ZZA_LOTE AND ZZA1.D_E_L_E_T_ ='' AND ZZA1.ZZA_FLAG NOT IN('6','E')) >1 "
       cQry1 += "ORDER BY ZZA.ZZA_DTLOG, ZZA.ZZA_HORA "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       aSelLin := {}
       DbSelecArea("TZA")
       While !Eof()
             cSelLin := space(02)
             RecLock("TZA", .t.)
                TZA->TZA_ORDEM  := TCQ->ZZA_ORDEM
                TZA->TZA_LOTE   := TCQ->ZZA_LOTE
                TZA->TZA_PRODUT := TCQ->ZZA_PRODUT
                TZA->TZA_EMISSA := STOD(TCQ->ZZA_DTLOG)
                TZA->TZA_QUANT  := TCQ->ZZA_QUANT
                If Len(Alltrim(TCQ->ZZA_PRODUT)) == 6
                   TZA->TZA_LINHA := 'CA'
                   cSelLin := 'CA'
                ElseIf Len(Alltrim(TCQ->ZZA_PRODUT)) == 5
                       TZA->TZA_LINHA := 'CS'
                       cSelLin := 'CS'
                ElseIf Len(Alltrim(TCQ->ZZA_PRODUT)) == 4
                       TZA->TZA_LINHA := 'PT'
                       cSelLin := 'PT'
                Else
                   TZA->TZA_LINHA := SubStr(TCQ->ZZA_PRODUT, 4, 2)
                   cSelLin := SubStr(TCQ->ZZA_PRODUT, 4, 2)
                Endif
                TZA->TZA_HELP   := TCQ->ZZA_HELP
                TZA->TZA_CAMPO  := TCQ->ZZA_CAMPO
                TZA->TZA_FLAG   := TCQ->ZZA_FLAG
				TZA->TZA_HORA   := TCQ->ZZA_HORA
                
            /*    If TZA->TZA_FLAG $ '1'
                   TZA->TZA_STATUS := '1 - TPC - INICIO'
                ElseIf TZA->TZA_FLAG $ '2'
                       TZA->TZA_STATUS := '2 - TPC - PESAGEM'
                ElseIf TZA->TZA_FLAG $ '3'
                       TZA->TZA_STATUS := '3 - TPC - COLORISTA'
                ElseIf TZA->TZA_FLAG $ '4'
                       TZA->TZA_STATUS := '4 - TPC - LABORATORIO'
                ElseIf TZA->TZA_FLAG $ '6'
                       TZA->TZA_STATUS := '6 - ENV - INICIO'
                ElseIf TZA->TZA_FLAG $ '7'
                       TZA->TZA_STATUS := '7 - ENV - PARCIAL'
                ElseIf TZA->TZA_FLAG $ '8'
                       TZA->TZA_STATUS := '8 - ENV - TOTAL'
                ElseIf TZA->TZA_FLAG $ 'X'
                       TZA->TZA_STATUS := 'X - EXCLUSÃO'
                Endif */
             MsUnLock()
             nPos := aScan(aSelLin, {|x| x[1] == cSelLin})
             If nPos == 0
                aAdd(aSelLin, {cSelLin, Iif(cSelLin $ 'CA', "Concentrado Base d'agua", Iif(cSelLin $ 'CS', "Concentrado Base solvente", Iif(cSelLin $ 'PT', "Pastas/Soluções", Posicione("SZ1", 1, xFilial("SZ1")+cSelLin, "Z1_DESCR") ) ) ) } )
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TZA")
       DbGoTop()
       //Verificar o status da mesma na tabela de apontamentos ZZA 
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fOrdErr()   
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fOrdErr()
       DbSelectArea("TZA")
       DbSetOrder(oCBxOrd:nAt)
       If oCBxOrd:nAt == 4
          DbSeek(CTOD(cGetInf))
       Else
          DbSeek(cGetInf)
       Endif
       oBrwSC2:oBrowse:Refresh()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fMudaErro()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fMudaErro()
       DbSelectArea("TZA")
       DbSetOrder(oCBxOrd:nAt)
       DbGoTop()
       If oCBxOrd:nAt == 1     //Ordem
          oSay2:lVisibleControl := .t.
          oGetInf:lVisibleControl := .t.
          oBtn3:lVisibleControl := .t.
          cGetInf := Space(11)
       ElseIf oCBxOrd:nAt == 2 //Lote
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(06)
       ElseIf oCBxOrd:nAt == 3 //Linha
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(2)
       ElseIf oCBxOrd:nAt == 4 //Emissão
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(10)
       ElseIf oCBxOrd:nAt == 5 //Produto
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(15)
       ElseIf oCBxOrd:nAt == 6 //Status
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(18)
       Endif
       oBrwSC2:oBrowse:Refresh()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fImpErr  º Impressão de Ordens de Produção a Conferir.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fImpErr()
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Declaracao de Variaveis                                             ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
       Local cDesc2        := "de acordo com os parametros informados pelo usuario."
       Local cDesc3        := "Relação de OPs com Erros"
       //Local cPict         := ""
       Local titulo        := "Relação de OPs a Conferir"
       Local nLin          := 80
       Local Cabec1        := "ORDEM          LOTE    PRODUTO             QTDE.     STATUS             ERRO"
       Local Cabec2        := ""
       //Local imprime       := .T.
       Local aOrd          := {}
       Private lEnd        := .F.
       Private lAbortPrint := .F.
       //Private CbTxt       := ""
       Private limite      := 132
       Private tamanho     := "M"
       Private nomeprog    := "BRPCPA01" // Coloque aqui o nome do programa para impressao no cabecalho
       Private nTipo       := 18
       Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
       Private nLastKey    := 0
       Private cPerg       := ""
       Private cbtxt       := Space(10)
       Private cbcont      := 0
       Private CONTFL      := 1
       Private m_pag       := 01
       Private wnrel       := "BRPCPA01" // Coloque aqui o nome do arquivo usado para impressao em disco
       Private cString     := "TZA"
       Private mvpar01
       DbSelectArea("TZA")
       DbSetOrder(1)
        
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta a interface padrao com o usuario...                           ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       wnrel := SetPrint(cString, NomeProg,      , @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

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

       Processa({|| fRunErr(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ fRunErr  º Autor ³ Luís G. de Souza   º Data ³  16/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fRunErr(Cabec1, Cabec2, Titulo, nLin)
       //Local nOrdem

       DbSelectArea(cString)
       DbSetOrder(1)

       ProcRegua(RecCount())
       DbSetOrder(1)
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

             // ORDEM          LOTE    PRODUTO          QTDE.     STATUS                ERRO
             // 999999-99-999  999999  XX 99.99.999-99  9,999.99  XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
             // 1234567890123  123456  123456789012345  12345678  12345678901234567890  123456789012345678901234567890123456789012345678901234567890
             // 123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
             //          1         2         3         4         5         6         7         8         9         100       110       12        13
             @ nLin,001 PSAY TZA->TZA_ORDEM   Picture "@R XXXXXX-99-999"
             @ nLin,016 PSAY TZA->TZA_LOTE    Picture "@R 999999"
             @ nLin,024 PSAY TZA->TZA_PRODUT  Picture "@R XXX99.99.999-99"
             @ nLin,041 PSAY TZA->TZA_QUANT   Picture "@E 9,999.99"
             @ nLin,051 PSAY TZA->TZA_STATUS  Picture "@R!"
             @ nLin,073 PSAY TZA->TZA_CAMPO   Picture "@R!"

             nLin += 1 // Avanca a linha de impressao
             DbSelectArea("TZA")
             DbSkip() // Avanca o ponteiro do registro no arquivo
       EndDo

       Set Filter To
       DbGoTop()
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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PCPA01_9 ³ Autor ³ Luis G. de Souza      ³ Data ³ 17/06/08 ³±±
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
User Function PCPA01_9()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cGetHor    := Time()
     //Private cGetRes    := Space(10)
     Private dGetDat    := dDataBase
     Private cMarca     := GetMark()
     Private nCBxRes
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1", "oDlg1", "oGrp1", "oSay1", "oSay2", "oSay3", "oGet1", "oGet2", "oGet3", "oBrw1", "oBtn1", "oBtn2", "oCBxRes")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1     := TFont():New( "MS Sans Serif",0,-16,,.T.,0,,700,.F.,.F.,,,,,, )
     oDlg1      := MSDialog():New( 088, 232, 587, 927, "Envia Ordens de Produção para produção", , , .F., , , , , , .T., , , .T. )
     oGrp1      := TGroup():New( 000, 000, 028, 344, "", oDlg1, CLR_BLACK, CLR_WHITE, .T., .F. )
     oSay1      := TSay():New( 009, 004, {||"Data:"}       , oGrp1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 028, 008)
     oSay2      := TSay():New( 009, 104, {||"Hora:"}       , oGrp1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 028, 008)
     oSay3      := TSay():New( 009, 204, {||"Responsavel:"}, oGrp1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 060, 010)
     oGetDat    := TGet():New( 008, 032, {|u| If(PCount() > 0, dGetDat := u, dGetDat)}, oGrp1, 060, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .T., .F., "", "dGetDat", ,)
     oGetHor    := TGet():New( 008, 132, {|u| If(PCount() > 0, cGetHor := u, cGetHor)}, oGrp1, 060, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .T., .F., "", "cGetHor", ,)
     //oGetRes    := TGet():New( 008, 264, {|u| If(PCount() > 0, cGetRes := u, cGetRes)}, oGrp1, 072, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "", "cGetRes", ,)
     oCBxRes    := TComboBox():New( 008, 264, {|u| If(PCount() > 0, nCBxRes := u, nCBxRes)}, {"Denir", "Lucio", "Marcos", "Marquinhos", "Nonis", "Paulinho", "Reaproveit", "Resina", "Valdir"}, 072, 014, oGrp1, , , , CLR_BLACK, CLR_WHITE, .T., oFont1, "", , , , , , , nCBxRes )

     MsgRun(OemToAnsi("Selecionando Ordens de Produção..."), OemToAnsi("Aguarde..."), { || oTbl4()} )
     
     DbSelectArea("TMP")
     DbSetOrder(1)
     DbGoTop()
     oBrw1      := MsSelect():New( "TMP", "TMP_MARCA", "", { {"TMP_MARCA", "", "", ""}, {"TMP_ORDEM", "", "Ordem", "@R XXXXXX-99-999"}, {"TMP_LOTE", "", "Lote", "@R 999999"}, {"TMP_EMISSA", "", "Emissão", ""}, {"TMP_PRODUT", "", "Produto", "@R! XXX99.99.999-99"}, {"TMP_QTDE", "", "Qtde.", "@E 999,999.99"} }, .F., cMarca, {032, 000, 228, 344}, , , oDlg1 ) 
     oBrw1:bAval               := {||TMPMark()}
     oBrw1:oBrowse:lHasMark    := .T.
     oBrw1:oBrowse:lCanAllmark := .F.

     oBtn1      := TButton():New( 232, 304, "Sair"           , oDlg1, { || oDlg1:End() }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn2      := TButton():New( 232, 256, "Confirmar"      , oDlg1, { || fGrvEnvio() }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn3      := TButton():New( 232, 004, "Inverte Seleção", oDlg1, { || fInvSelec() }, 052, 012, , , , .T., , "", , , , .F. )
     oCbxRes:SetFocus()
     oDlg1:Activate(, , , .T.)
     DbSelectArea("TMP")
     DbCloseArea()
     oTempTbl06:Delete()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl4() - Cria temporario para o Alias: TMP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl4()
       Local aFds := {}
       //Local cTmp
       Local cQry := ""

       Aadd( aFds , {"TMP_MARCA" , "C", 002, 000} )
       Aadd( aFds , {"TMP_ORDEM" , "C", 011, 000} )
       Aadd( aFds , {"TMP_LOTE"  , "C", 006, 000} )
       Aadd( aFds , {"TMP_EMISSA", "D", 008, 000} )
       Aadd( aFds , {"TMP_PRODUT", "C", 015, 000} )
       Aadd( aFds , {"TMP_QTDE"  , "N", 010, 002} )

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 06/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cTmp := CriaTrab( aFds, .T. )
       //Use (cTmp) Alias TMP New Exclusive
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'1', "TMP_ORDEM ", {|| "TMP_ORDEM "})
       //DbClearInd()
       //DbSetIndex(SubStr(cTmp, 1, 10)+'1')
       //DbSetOrder(1)
       oTempTbl06 := FWTemporaryTable():New( "TMP" )
       oTempTbl06:SetFields( aFds )
       oTempTbl06:AddIndex( "cInd01", { "TMP_ORDEM" } )
       oTempTbl06:Create()
       /********************************************************************************************************************************/

       cQry += "SELECT SC2.C2_OP, SC2.C2_LOTE, SC2.C2_QUANT, SC2.C2_EMISSAO, SC2.C2_PRODUTO, ZZA.ZZA_ORDEM, ZZA_ENVIA, ZZA_DTENV, ZZA_HENV "
       cQry += "FROM "+RetSqlName("SC2")+" SC2 WITH(NOLOCK) "
       cQry += "LEFT OUTER JOIN "+RetSqlName("ZZA")+" ZZA WITH(NOLOCK) ON ZZA.ZZA_FILIAL = SC2.C2_FILIAL AND ZZA.ZZA_ORDEM = SC2.C2_OP AND ZZA.D_E_L_E_T_ = '' "
       cQry += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
       cQry += "  AND SC2.D_E_L_E_T_ = '' "
       cQry += "  AND SC2.C2_QUJE    = 0 "
       cQry += "  AND SC2.C2_DATRF   = '' "
       cQry += "  AND SC2.C2_UM IN('L', 'K', 'KG') "
       cQry += "  AND ISNULL(ZZA.ZZA_ENVIA, '') <> 'S' "
       cQry += "ORDER BY SC2.C2_EMISSAO "
       TCQuery cQry ALIAS "TCQ" NEW

       DbSelectArea("TCQ")
       While !Eof()
             RecLock("TMP", .t.)
                TMP->TMP_MARCA  := cMarca
                TMP->TMP_ORDEM  := TCQ->C2_OP
                TMP->TMP_LOTE   := TCQ->C2_LOTE
                TMP->TMP_EMISSA := STOD(TCQ->C2_EMISSAO)
                TMP->TMP_PRODUT := TCQ->C2_PRODUTO
                TMP->TMP_QTDE   := TCQ->C2_QUANT
             MsUnLock()
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ TMPMark() - Funcao para marcar o MsSelect
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function TMPMark()
       Local lDesMarca := TMP->(IsMark("TMP_MARCA", cMarca))

       RecLock("TMP", .F.)
       If lDesmarca
          TMP->TMP_MARCA := "  "
       Else
          TMP->TMP_MARCA := cMarca
       Endif
       TMP->(MsUnlock())
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ GrvEnvio() - Funcao para gravar envio de dados
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fGrvEnvio()
       If Empty(nCBxRes)
          MsgStop("Favor informar nome do responsável.")
          oCbxRes:SetFocus()
          Return
       Endif
       DbSelectArea("TMP")
       DbGoTop()
       While !Eof()
             If Marked("TMP_MARCA")
                DbSelectArea("ZZA")
                DbSetOrder(2)
                DbSeek(xFilial("ZZA")+TMP->TMP_ORDEM, .t.)
                If !Found()
                   RecLock("ZZA", .t.)
                      ZZA->ZZA_FILIAL := xFilial("ZZA")
                      ZZA->ZZA_ORDEM  := TMP->TMP_ORDEM
                      ZZA->ZZA_LOTE   := TMP->TMP_LOTE
                      ZZA->ZZA_PRODUT := TMP->TMP_PRODUT
                      ZZA->ZZA_ENVIA  := 'S'
                      ZZA->ZZA_DTENV  := dGetDat
                      ZZA->ZZA_HENV   := SubStr(StrTran(cGetHor, ':'), 1, 4)
                      ZZA->ZZA_RENV   := SubStr(nCBxRes, 1, 10)
                   MsUnLock()
                Else
                   RecLock("ZZA", .f.)
                      ZZA->ZZA_ENVIA  := 'S'
                      ZZA->ZZA_DTENV  := dGetDat
                      ZZA->ZZA_HENV   := SubStr(StrTran(cGetHor, ':'), 1, 4)
                      ZZA->ZZA_RENV   := SubStr(cGetRes, 1, 10)
                   MsUnLock()
                Endif
             Endif
             DbSelectArea("TMP")
             DbSkip()
       Enddo
       oDlg1:End()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCPA01_6 º Autor ³ 				     º Data ³   /  /      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressão de Ordens de Produção Enviadas para Produção     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PCPA01_6()
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Relação de OPs Enviadas para produção"
     //Local cPict         := ""
     Local titulo        := "Relação de OPs Enviadas para produção"
     Local nLin          := 80
     Local Cabec1        := "ORDEM          LOTE    PRODUTO          QTDE."
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     //Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRPCPA01" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "ZZAENV"
     Private cbtxt       := Space(10)
     Private cbcont      := 0
     Private CONTFL      := 1
     Private m_pag       := 01
     Private wnrel       := "BRPCPA01" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "ZZA"
     Private cRetLin     := ''
     Private mvpar01
     DbSelectArea("ZZA")
     DbSetOrder(1)
     cHora   := ""
     amvpar2 := {"DENIR" , "LUCIO"   , "MARCOS"    , "MARQUINHOS"}
     amvpar3 := {"NONIS" , "PAULINHO", "REAPROVEIT", "RESINA"}
     amvpar4 := {"VALDIR"}
     //oPerg2()  //LGS#20200203 - Adequação ao release 12.1.25 e posteriores
     If Pergunte('ZZAENV', .t.)
        If mv_par02 == 5
           If mv_par03 == 5
              cRespon := amvpar4[mv_par04]
           Else
              cRespon := amvpar3[mv_par03]
           Endif
        Else
           cRespon := amvpar2[mv_par02]
        Endif
     Else
        Return
     Endif
     aHora := {}
     cQry1 := ""
     cQry1 += "SELECT ZZA.ZZA_HENV "
     cQry1 += "FROM "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) "
     cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
     cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
     cQry1 += "  AND ZZA.ZZA_DTENV  = '"+DtoS(mv_par01)+"' "
     cQry1 += "  AND UPPER(ZZA.ZZA_RENV) = '"+cRespon+"' "
     cQry1 += "GROUP BY ZZA.ZZA_HENV "
     TCQuery cQry1 ALIAS "TCQ" NEW
     DbSelectArea("TCQ")
     DbGoTop()
     While !Eof()
           aAdd(aHora, SubStr(TCQ->ZZA_HENV, 1, 2)+':'+SubStr(TCQ->ZZA_HENV, 3, 2))
           DbSelectArea("TCQ")
           DbSkip()
     Enddo
     DbSelectArea("TCQ")
     DbCloseArea()

     DbSelectArea("ZZA")
     If Len(aHora) <= 0
        MsgStop("Sem dados a serem impressos...")
        Return
     Else
        If Len(aHora) = 1
           cHora := aHora[1]
        Else
           cHora := fBusHor(aHora)
        Endif
     Endif
     If Empty(cHora)
        MsgStop("Sem dados a serem impressos...")
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta a interface padrao com o usuario...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     wnrel := SetPrint(cString, NomeProg,      , @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

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

     Processa({|| fImpEnv(Cabec1, Cabec2, Titulo, nLin, cHora) }, Titulo)
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oPerg2() - Cria grupo de Perguntas.
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
//LGS#20200203 - Adequação ao release 12.1.25 e posteriores
/*
Static Function oPerg2()
       Local aHelpPor := {}
       aAdd(aHelpPor, "Informe a data de envio da O.P.         ")
       PutSx1( 'ZZAENV', '01', 'Data envio'          , '', '', 'mv_ch1', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par01', ''      , '', '', '', ''        , '', '', ''                , ''  , '', ''        , '', '', ''                 , '', '', aHelpPor, {}, {} )

       aHelpPor := {}
       aAdd(aHelpPor, "Informe o usuário responsável que foi   ")
       aAdd(aHelpPor, "enviada a O.P. ou a última opção para   ")
       aAdd(aHelpPor, "usar os parâmetros seguintes.           ")
       PutSx1('ZZAENV', '02', 'Responsável'         , '', '', 'mv_ch2', 'N', 1, 0, 1, 'C', '', '', '', '', 'mv_par02', 'Denir'      , '', '', '', 'Lucio'         , '', '', 'Marcos'      , '', '', 'Marquinhos', '', '', 'PROXIMO PARAMETRO', '', '', aHelpPor, {}, {} )

       aHelpPor := {}
       aAdd(aHelpPor, "Informe o usuário responsável que foi   ")
       aAdd(aHelpPor, "enviada a O.P. ou a última opção para   ")
       aAdd(aHelpPor, "usar os parâmetros seguintes.           ")
       PutSx1( 'ZZAENV', '03', 'Responsável'         , '', '', 'mv_ch3', 'N', 1, 0, 1, 'C', '', '', '', '', 'mv_par03', 'Nonis' , '', '', '', 'Paulinho', '', '', 'Reaproveit', '', '', 'Resina'    , '', '', 'PROXIMO PARAMETRO', '', '', aHelpPor, {}, {} )

       aHelpPor := {}
       aAdd(aHelpPor, "Informe o usuário responsável que foi   ")
       aAdd(aHelpPor, "enviada a O.P.                          ")
       PutSx1( 'ZZAENV', '04', 'Responsável'         , '', '', 'mv_ch4', 'N', 1, 0, 1, 'C', '', '', '', '', 'mv_par04', 'Valdir', '', '', '', ''        , '', '', ''                , '', '', ''          , '', '', ''                 , '', '', aHelpPor, {}, {} )
Return */

Static Function fBusHor(aHora)
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oDlg2", "oBrwHor", "oBtnCon", "oBtnSai")
       Private cMarca := GetMark()

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
      ±± Definicao do Dialog e todos os seus componentes.                        ±±
      Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
      oDlg2      := MSDialog():New( 088, 232, 323, 540, "Selecione a hora...", , , .F., , , , , , .T., , , .T. )
      oTbl5(aHora)
      DbSelectArea("HOR")

      DbSetOrder(1)
      oBrwHor    := MsSelect():New( "HOR", "MARCA"    , "", {{"MARCA", "", "", ""}, {"HORA", "", "Hora", "" } }, .F., cMarca, {004, 004, 096, 148}, , , oDlg2 ) 
      oBrwHor:bAval               := {||HorMark()}
      oBrwHor:oBrowse:lHasMark    := .T.
      oBrwHor:oBrowse:lCanAllmark := .F.

      oBtnCon    := TButton():New( 100, 064, "Confirmar", oDlg2, {|| cRetHor := fMarcaHora() , oDlg2:End()}, 037, 012, , , , .T., , "", , , , .F. )
      oBtnSai    := TButton():New( 100, 108, "Sair"     , oDlg2, {|| cRetHor := '', oDlg2:End()}, 037, 012, , , , .T., , "", , , , .F. )

      oDlg2:Activate(,,,.T.)
      DbSelectArea("HOR")
      DbCloseArea()
      oTempTbl07:Delete()
Return(cRetHor)


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl5() - Cria temporario para o Alias: HOR
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl5(aHora)
       Local aFds := {}
       //Local cTmp
       Local nZ

       aAdd( aFds , {"MARCA", "C", 002, 000} )
       aAdd( aFds , {"HORA" , "C", 005, 000} )

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 06/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cTmp := CriaTrab( aFds, .T. )
       //Use (cTmp) Alias HOR New Exclusive
       //Index On HORA To (cTmp)
       oTempTbl07 := FWTemporaryTable():New( "HOR" )
       oTempTbl07:SetFields( aFds )
       oTempTbl07:AddIndex( "cInd01", { "HORA" } )
       oTempTbl07:Create()
       /********************************************************************************************************************************/
       For nZ := 1 To Len(aHora)
           RecLock("HOR", .t.)
              HOR->MARCA := space(02)
              HOR->HORA  := aHora[nZ]
           MsUnLock()
       Next
       DbSelectArea("HOR")
       DbGoTop()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ HorMark() - Funcao para marcar o MsSelect
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function HorMark()
       Local lDesMarca := HOR->(IsMark("MARCA", cMarca))

       nRecAtu := RecNo()
       DbSelectArea("HOR")
       DbGoTop()
       While !Eof()
             RecLock("HOR", .F.)
                If nRecAtu == RecNo()
                   If lDesmarca
                      HOR->MARCA := space(02)
                   Else
                      HOR->MARCA := cMarca
                   Endif
                Else
                   HOR->MARCA := "  "
                Endif
             HOR->(MsUnlock())
             DbSelectArea("HOR")
             DbSkip()
       Enddo
       DbSelectArea("HOR")
       DbGoTo(nRecAtu)
       oBrwHor:oBrowse:Refresh()
Return

Static Function fMarcaHora()
       cRetHor := ''
       DbSelectArea("HOR")
       DbGoTop()
       While !Eof()
             If HOR->( IsMark("MARCA", ThisMark(), ThisInv() ) )
                cRetHor := HOR->HORA
             Endif
             DbSelectArea("HOR")
             DbSkip()
       EndDo
       DbSelectArea("HOR")
       DbGoTop()
Return(cRetHor)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ fImpEnv  º Autor ³ Luís G. de Souza   º Data ³  18/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fImpEnv(Cabec1, Cabec2, Titulo, nLin, cHora)
       //Local nOrdem

       cQry1 := ""
       cQry1 += "SELECT * "
       cQry1 += "FROM "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) "
       cQry1 += "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
       cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND ZZA.ZZA_DTENV  = '"+DtoS(mv_par01)+"' "
       cQry1 += "  AND ZZA.ZZA_HENV   = '"+StrTran(cHora, ":")+"' "
       cQry1 += "  AND UPPER(ZZA.ZZA_RENV) = '"+cRespon+"' "
       cQry1 += "ORDER BY ZZA.ZZA_ORDEM "
       TCQuery cQry1 ALIAS "TCQ" NEW

       ProcRegua(100)
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
                @ nLin, 000 PSAY "RESPONSAVEL: "+TCQ->ZZA_RENV+"      DATA: "+DTOC(STOD(TCQ->ZZA_DTENV))+"      HORA: "+SubStr(TCQ->ZZA_HENV, 1, 2)+":"+SubStr(TCQ->ZZA_HENV, 3, 2)+" "
                nLin += 2
             Endif

             // ORDEM          LOTE    PRODUTO          QTDE.     
             // 999999-99-999  999999  XX 99.99.999-99  9,999.99  
             // 1234567890123  123456  123456789012345  12345678  123456789012345678
             // 1234567890123456789012345678901234567890123456789012345678901234567890123456789
             //          1         2         3         4         5         6         7
             @ nLin,001 PSAY TCQ->ZZA_ORDEM   Picture "@R XXXXXX-99-999"
             @ nLin,016 PSAY TCQ->ZZA_LOTE    Picture "@R 999999"
             @ nLin,024 PSAY Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM, "C2_PRODUTO")  Picture "@R XXX99.99.999-99"
             @ nLin,041 PSAY Posicione("SC2", 1, xFilial("SC2")+TCQ->ZZA_ORDEM, "C2_QUANT")    Picture "@E 9,999.99"
             nLin += 1 // Avanca a linha de impressao
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

Static Function fInvSelec()
       DbSelectArea("TMP")
       DbGoTop()
       While !Eof()
             lDesMarca := TMP->(IsMark("TMP_MARCA", cMarca))
             RecLock("TMP", .F.)
                If lDesmarca
                   TMP->TMP_MARCA := "  "
                Else
                   TMP->TMP_MARCA := cMarca
                Endif
             TMP->(MsUnlock())
             DbSelectArea("TMP")
             DbSkip()
       Enddo
       DbSelectArea("TMP")
       DbGoTop()
       oBrw1:oBrowse:Refresh()
Return

#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PCPA01_7 ³ Autor ³ Luís Gustavo de Souza ³ Data ³ 17/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta apontamentos de produção.                         ³±±
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
User Function PCPA01_7()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cGetFPC    := Space(1)
     Private cGetFPP    := Space(1)
     Private CGETFPA    := Space(1)
     Private cGetIPP    := Space(1)
     Private cGetLib    := Space(1)
     Private cGetOrd    := Space(13)
     Private cGetLot    := Space(6)
     Private cGetQtd    := 0
     Private cGetPEL    := Space(1)
     Private cGetPET    := Space(1)
     Private cGetPFL    := Space(1)
     Private cGetTar    := Space(1)
     Private cSayFPC    := Space(1)
     Private cSayFPP    := Space(1)
     Private cSayFPA    := Space(1)
     Private cSayIPP    := Space(1)
     Private cSayLib    := Space(1)
     Private cSayOrd    := Space(1)
     Private cSayPEL    := Space(1)
     Private cSayPET    := Space(1)
     Private cSayPFL    := Space(1)
     Private cSayTar    := Space(1)
	 Private cSay4Env   := Space(35)
	 Private cSay5Env   := Space(35)
     Private cGetPro    := Space(12)
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1"  , "oDlg1"   , "oSayOrd", "oSayLot", "oSayQtd", "oGrpApt", "oBrwApt", "oGrpOri", "oGetOrd", "oGetLot", "oBrwOri", "oGetEnv", "oBrwEnv")
     SetPrvt("oSayTar" , "oSayIPP" , "oGetTar", "oGetIPP", "oGrpFPO", "oSayFPP", "oGetFPP", "oGrpCol", "oSayFPC", "oSayLib", "oBtnSai", "oSayEnv", "cGetEnv")
     SetPrvt("oGetLib" , "oGrpLab" , "oSayPFL", "oSayPET", "oSayPEL", "oGetPFL", "oGetPET", "oGetPEL", "oGrpEnv", "oGrpPer", "oBtnApt", "oGrpIOP", "oGetEnv")
     SetPrvt("oSay4Env", "oSay5Env", "oFont2" , "oBtnGSa", "oBtnESa", "oBtnSOk", "oBtnASo", "oSayFPA")
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1     := TFont():New( "MS Sans Serif", 0, -13, , .T., 0, , 700, .F., .F., , , , , , )
     oFont2     := TFont():New( "MS Sans Serif", 0, -15, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1      := MSDialog():New( 070, 232, 635, 857, "Consulta Apontamento de Produção", , , .F., , , , , , .T., , , .T. )
     oSayOrd    := TSay():New( 006, 005, {|| "O.P.:"  }, oDlg1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 022, 009 )
     oGetOrd    := TGet():New( 004, 030, {|u| If( PCount() > 0, cGetOrd := u, cGetOrd) }, oDlg1, 060, 010, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "", "cGetOrd", , )
     oSayLot    := TSay():New( 006, 115, {|| "Lote:"  }, oDlg1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 022, 008)
     oGetLot    := TGet():New( 004, 140, {|u| If( PCount() > 0, cGetLot := u, cGetLot) }, oDlg1, 044, 010, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "", "cGetLot", , )

     //oGetLot:bValid     := {|| Iif(Len(Alltrim(cGetLot)) = 6, fBusLote(cGetLot), oGetLot:Setfocus() ) }

     oSayQtd    := TSay():New( 006, 215, {|| "Qtde.:" }, oDlg1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 022, 008)
     oGetQtd    := TGet():New( 004, 245, {|u| If( PCount() > 0, cGetQtd := u, cGetQtd) }, oDlg1, 044, 010, '@E 999,999.999', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .T., .F., "", "cGetQtd", , )
     oTblOri()
     DbSelectArea("ORI")
   	 DbSetOrder(1)
     oGrpOri    := TGroup():New( 017, 004, 089, 136, "Original:", oDlg1, CLR_BLACK, CLR_WHITE, .T., .F. )
     oBrwOri    := MsSelect():New( "ORI", "", "", { {"ORI_COMP", "", "Componente", "@R! XX 99.99.999-99"}, {"ORI_TRT", "", "Sequ.", "@!"}, {"ORI_QTDE", "", "Qtde", "@E 999,999.9999"} }, .F., , {024, 008, 085, 132}, , , oGrpOri )
     oTblApt()
     DbSelectArea("APT")
   	 DbSetOrder(1)
     oGrpApt    := TGroup():New( 017, 140, 089, 312, "Apontamentos:", oDlg1, CLR_BLACK, CLR_WHITE, .T., .F. )
	 	oBrwApt    := MsSelect():New( "APT", "", "", { {"APT_COMP", "", "Componente", "@R! XX 99.99.999-99"}, {"APT_TRT", "", "Sequ.", "@!"}, {"APT_QTDE", "", "Qtde", "@E 999,999.9999"}, {"APT_LOCA", "", "Local", ""} }, .F., , {024, 144, 085, 308}, , , oGrpApt )
     	oGrpIOP    := TGroup():New( 092, 004, 133, 136, "Inicio de Pesagem:", oDlg1, CLR_BLACK, CLR_WHITE, .T., .F. )
     	oSayTar    := TSay():New( 106,008,{||"Tara:"},oGrpIOP,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,009)
     	oGetTar    := TGet():New( 104,048,{|u| If(PCount()>0,cGetTar:=u,cGetTar)},oGrpIOP,040,010,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGetTar",,)
     	oSayIPP    := TSay():New( 119,008,{||"Peso Ini:"},oGrpIOP,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,009)
     	oGetIPP    := TGet():New( 117,048,{|u| If(PCount()>0,cGetIPP:=u,cGetIPP)},oGrpIOP,040,010,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGetIPP",,)
     oGrpFPO    := TGroup():New( 092,140,133,312,"Fim Pesagem:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
     	oSayFPP    := TSay():New( 106,144,{||"Peso Final:"},oGrpFPO,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,009)
     	oGetFPP    := TGet():New( 104,184,{|u| If(PCount()>0,cGetFPP:=u,cGetFPP)},oGrpFPO,040,010,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGetFPP",,)
     	oSayFPA    := TSay():New( 119,144,{||"Peso Apur.:"},oGrpFPO,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,009)
     	oGetFPA    := TGet():New( 117,184,{|u| If(PCount()>0,cGetFPA:=u,cGetFPA)},oGrpFPO,040,010,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGetFPA",,)
	 oGrpCol    := TGroup():New( 135,004,174,136,"Colorista:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	 	oSayFPC    := TSay():New( 145,008,{||"Peso Final:"},oGrpCol,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,009)
		oSayLib    := TSay():New( 158,008,{||"Liberação:"},oGrpCol,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,009)
	 	oGetFPC    := TGet():New( 145,048,{|u| If(PCount()>0,cGetFPC:=u,cGetFPC)},oGrpCol,040,010,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGetFPC",,)
	 	oGetLib    := TGet():New( 158,048,{|u| If(PCount()>0,cGetLib:=u,cGetLib)},oGrpCol,040,010,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGetLib",,)
	 oGrpLab    := TGroup():New( 135,140,174,312,"Laboratório:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	 	oSayPFL    := TSay():New( 145,144,{||"Peso Final:"},oGrpLab,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,009)
	 	oSayPET    := TSay():New( 158,144,{||"P. E. Teo.:"},oGrpLab,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,009)
	 	oSayPEL    := TSay():New( 158,225,{||"P. E. Lab.:"},oGrpLab,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,009)
	 	oGetPFL    := TGet():New( 145,184,{|u| If(PCount()>0,cGetPFL:=u,cGetPFL)},oGrpLab,040,010,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGetPFL",,)
	 	oGetPET    := TGet():New( 158,184,{|u| If(PCount()>0,cGetPET:=u,cGetPET)},oGrpLab,040,010,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGetPET",,)
		oGetPEL    := TGet():New( 158,267,{|u| If(PCount()>0,cGetPEL:=u,cGetPEL)},oGrpLab,040,010,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cGetPEL",,)
     oGrpEnv    := TGroup():New( 176,004,238,312,"Envase:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
   	 	oTblEnv() 
   	 	DbSelectArea("_ENV")
   	 	DbSetOrder(1)
   		oBrwEnv    := MsSelect():New( "_ENV", "", "", { {"ENV_PROD", "", "Produto"   , "@R! XX 99.99.999-99"}, {"ENV_DESCR", "", "Descrição", "@!"}, {"ENV_QTDORI", "", "Qtde Orig.", "@E 99999"}, {"ENV_QTDENT", "", "Qtde Entr.", "@E 99999"} ,{"ENV_DATRF", "", "Data Fechto", "@!"}}, .F., , {182,006,236,310}, , , oGrpEnv )
   	 oGrpPer    := TGroup():New( 240,004,280,312,"Perda / Sobra:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
        oSay4Env   := TSay():New( 250, 010, { || cSay4Env  },   oGrpPer, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)
        oSay5Env   := TSay():New( 264, 010, { || cSay5Env  },   oGrpPer, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 240, 012)
	 	oBtnGSa    := TButton():New( 245,270,"Gerar Saldo ",oDlg1,,037,012,,,,.t.,,"",,,,.F. )
	 	oBtnESa    := TButton():New( 245,270,"Exclui Saldo",oDlg1,,037,012,,,,.t.,,"",,,,.F. )
	 	oBtnSOk    := TButton():New( 245,270,"Conferir    ",oDlg1,,037,012,,,,.t.,,"",,,,.F. )
		//oBtnASo	   := TButton():New( 245,270,"Aponta Sobra",oDlg1,,037,012,,,,.t.,,"",,,,.F. )
	 	oBtnSai    := TButton():New( 265,270,"Sair"        ,oDlg1,{ || fSair() },037,012,,,,.T.,,"",,,,.T. )
		oBtnApt    := TButton():New( 104,267,"Apontadores" ,oDlg1,{ || U_fApont(cGetOrd) },037,012,,,,.T.,,"",,,,.F. )
	   //	oBtnApt    := TButton():New( 118,267,"Imprimi Inf" ,oDlg1,{ || U_fApont(cGetOrd) },037,012,,,,.T.,,"",,,,.F. )

     oGetOrd:SetFocus()
     oGetOrd:bLostFocus := { || fBusOrd() }
     //oGetLot:bLostFocus := { || fBusLote(cGetLot) }
 	 oDlg1:Activate(,,,.T.)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fImpIOp  º Impressão de Ordens de Produção a Conferir.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//LGS#20200131 - Adequação de release 12.1.25 e posteriores
/*
Static Function fImpIOp()
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Declaracao de Variaveis                                             ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
       Local cDesc2        := "de acordo com os parametros informados pelo usuario."
       Local cDesc3        := "Impressão das Informaçõs de Apontamento"
       //Local cPict         := ""
       Local titulo        := "Impressão das Informaçõs de Apontamento"
       Local nLin          := 80
       Local Cabec1        := "ORDEM          LOTE    PRODUTO             QTDE.     STATUS             ERRO"
       Local Cabec2        := ""
       //Local imprime       := .T.
       Local aOrd          := {}
       Private lEnd        := .F.
       Private lAbortPrint := .F.
       //Private CbTxt       := ""
       Private limite      := 80
       Private tamanho     := "P"
       Private nomeprog    := "BRPCPA01" // Coloque aqui o nome do programa para impressao no cabecalho
       Private nTipo       := 18
       Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
       Private nLastKey    := 0
       Private cPerg       := ""
       Private cbtxt       := Space(10)
       Private cbcont      := 0
       Private CONTFL      := 1
       Private m_pag       := 01
       Private wnrel       := "BRPCPA01" // Coloque aqui o nome do arquivo usado para impressao em disco
       Private cString     := "TZA"
       Private mvpar01
       DbSelectArea("TZA")
       DbSetOrder(1)
        
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta a interface padrao com o usuario...                           ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       wnrel := SetPrint(cString, NomeProg,      , @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

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

       Processa({|| fRunIOp(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return */

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ fRunIOp  º André Maester              º Data ³  25/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//LGS#20200131 - Adequação de release 12.1.25 e posteriores
/*
Static Function fRunIOp(Cabec1, Cabec2, Titulo, nLin)
       //Local nOrdem

       
       DbSelectArea(cString)
       DbSetOrder(1)

       ProcRegua(RecCount())
       DbSetOrder(1)
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

             // ORDEM          LOTE    PRODUTO          QTDE.     STATUS                ERRO
             // 999999-99-999  999999  XX 99.99.999-99  9,999.99  XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
             // 1234567890123  123456  123456789012345  12345678  12345678901234567890  123456789012345678901234567890123456789012345678901234567890
             // 123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
             //          1         2         3         4         5         6         7         8         9         100       110       12        13
             @ nLin,001 PSAY TZA->TZA_ORDEM   Picture "@R XXXXXX-99-999"
             @ nLin,016 PSAY TZA->TZA_LOTE    Picture "@R 999999"
             @ nLin,024 PSAY TZA->TZA_PRODUT  Picture "@R XXX99.99.999-99"
             @ nLin,041 PSAY TZA->TZA_QUANT   Picture "@E 9,999.99"
             @ nLin,051 PSAY TZA->TZA_STATUS  Picture "@R!"
             @ nLin,073 PSAY TZA->TZA_CAMPO   Picture "@R!"

             nLin += 1 // Avanca a linha de impressao
             DbSelectArea("TZA")
             DbSkip() // Avanca o ponteiro do registro no arquivo
       EndDo

       Set Filter To
       DbGoTop()
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
Return*/


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Function  ³ fSair() - Fechar os arquivos Temporários e Sair da Tela
 ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fSair()

If ChkFile("ORI")
	DbSelectArea("ORI")
	DbCloseArea()
	If Type("oTempTbl08") == "O"
	   oTempTbl08:Delete()
	Endif
Endif

If ChkFile("APT")
	DbSelectArea("APT")
	DbCloseArea()
    If Type("oTempTbl09") == "O"
       oTempTbl09:Delete()
    Endif
Endif

If ChkFile("_ENV")
	DbSelectArea("_ENV")
	DbCloseArea()
	If Type( "oTempTbl11" ) == "O"
	   oTempTbl11:Delete()
	Endif
Endif

oDlg1:End()

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Function  ³ fBusLote() - Busca Informações de Apontamento de Mps, Pas, 
  						   Saldos gerados (Busca pelo Lote de PI)
 ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
//LGS#20200203 - Adequação de release 12.1.25 e posteriores
/*
Static Function fBusLote(cLote)
    If Empty(cLote) .or. Len(cLote) <> 6
    	Return
    Endif
    DbSelectArea("SC2")
    DbSetOrder(13)
    DbSeek(xFilial("SC2")+Alltrim(cLote), .t.)
    If Found() 
    	While !(SC2->(Eof())) .AND. ((XFilial("SC2") == SC2->C2_FILIAL) .AND. Alltrim(cLote) == Alltrim(SC2->C2_LOTE)) 
			If Substr(SC2->C2_PRODUTO,11,2) $ '00.99'
				cGetOrd := (SC2->C2_OP)
			Endif
			DbSelectArea("SC2")
			DbSkip()        	
  		Enddo
		DbSelectArea("SC2")
		DbCloseArea()
		fBusOrd()
	Else
		DbSelectArea("SC2")
		DbCloseArea()
   	   	//cGetLote:SetFocus()
	Endif


Return*/

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Function  ³ fBusOrd() - Busca Informações de Apontamento de Mps, Pas, 
  						  Saldos gerados (Busca pela O.P de PI)
 ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fBusOrd()

	   Local 	nQtdVol  := 0
	   Local    nSaldo   := 0
	   Local 	nQtdConv := ""
	   Local 	cTipoPro := ""
	   Local 	cProduto := ""
	   Local 	cLocal   := ""
       Local 	cPerSobr :=""
       Local 	cZZACampo:= ""
       Local 	lOpAjut  := .f.
       Local 	lExistApt:= .f.
       Local 	nZZAPESP := 1
	   Local    cQry1    := ""
	   Private  nVolSC2  := 0
	   Private  nVolZZA  := 0

	   cGetFPC    := Space(1)
       cGetFPP    := Space(1)
       cGetFPA    := Space(1)
       cGetIPP    := Space(1)
       cGetLib    := Space(1)
       cGetLot    := Space(6)
       cGetQtd    := 0
       cGetPEL    := Space(1)
       cGetPET    := Space(1)
       cGetPFL    := Space(1)
       cGetTar    := Space(1)
       cSayFPC    := Space(1)
       cSayFPP    := Space(1)
       cSayFPA    := Space(1)
       cSayIPP    := Space(1)
       cSayLib    := Space(1)
       cSayOrd    := Space(1)
       cSayPEL    := Space(1)
       cSayPET    := Space(1)
       cSayPFL    := Space(1)
       cSayTar    := Space(1)
	   cSay4Env   := "" 		  		         	        
	   cSay5Env   := ""
	   If ChkFile("ORI")       
       	  DbSelectArea("ORI")
       	  DbGoTop()
       	  //LGS#20200211 - Adequação de release 12.1.25 e posteriores
       	  //Zap
       	  TCSqlExec("DELETE FROM " + oTempTbl08:GetRealName() )
       Endif
       If ChkFile("APT")
          DbSelectArea("APT")
          DbGoTop()
       	  //LGS#20200211 - Adequação de release 12.1.25 e posteriores
          //Zap
          TCSqlExec("DELETE FROM " + oTempTbl09:GetRealName() )
       Endif
       If ChkFile("_ENV")
          DbSelectArea("_ENV")
          DbGoTop()
       	  //LGS#20200211 - Adequação de release 12.1.25 e posteriores
          //Zap
          TCSqlExec("DELETE FROM " + oTempTbl11:GetRealName() )
       Endif
       If Len(Alltrim(cGetOrd))=6
       		cGetOrd := Substr(cGetOrd,1,6)+'01001'
       Endif

       If Len(Alltrim(cGetOrd)) <> 11 
       	   Return
       Endif
       
       DbSelectArea("ZZA")
       DbSetOrder(2)
       DbSeek(xFilial("ZZA")+SubStr(cGetOrd, 1, 11), .t.)
       If Found() .and. Alltrim(cGetOrd)== Alltrim(ZZA->ZZA_ORDEM)
          If (Posicione("SB1", 1, xFilial("SB1")+ZZA->ZZA_PRODUT, "B1_TIPO") <> 'PI') 
          	  MsgStop("Digite o código de uma O.P de Produto Intermediário Válida !!")
          	  oGetOrd:SetFocus()
          	  Return
          Endif
          cGetPro := ZZA->ZZA_PRODUT	 
          cGetLot := ZZA->ZZA_LOTE
          cGetTar := Transform(ZZA->ZZA_TARA   ,"@E 9999.999")              // tara balança
          cGetIPP := Transform(ZZA->ZZA_PESPES,"@E 99999.999")  			// peso pesagem
          cGetFPP := Transform((ZZA->ZZA_PESPES+ZZA_TARA),"@E 99999.999")  	// peso final pesagem  +(peso pesagem + tara)
		  cGetFPA := Transform((ZZA->ZZA_PESAPU),"@E 99999.999")  	        // peso final apurado na balança          
          cGetFPC := Transform(ZZA->ZZA_PESCOL,"@E 99999.999")  			// peso colorista
          cGetLib := ZZA->ZZA_DTCOL                             			// data liberação colorista
          cGetPET := Transform(ZZA->ZZA_PESESP, "@E 999.9999")  			// peso especifico terórico
          cGetPEL := Transform(ZZA->ZZA_PESLAB, "@E 999.9999")  			// peso especifico laboratóri
          cGetPFL := Transform(ZZA->ZZA_PESFIN,"@E 99999.999")  			// peso final        
          cGetQtd := Round(ZZA->ZZA_QUANT,2)                              	// litros          
           
          cQry1 := ""
          cQry1 += "SELECT D4_COD, D4_QTDEORI, D4_TRT  "
          cQry1 += " FROM "+RetSqlname("SD4")+" SD4 WITH(NOLOCK) "
          cQry1 += " WHERE SD4.D4_FILIAL  = '"+xFilial("SD4")+"' "
          cQry1 += "  AND SD4.D_E_L_E_T_ = '' 
		  If (cNumEmp == "01010101")			
          	cQry1 +=" AND SD4.D4_OP > '94498601001'"    // primeira op apontada que não excluiu sd4
          Endif
          cQry1 += "  AND SD4.D4_OP  = '"+Alltrim(cGetOrd)+"' "
          cQry1 += " ORDER BY SD4.D4_TRT, D4_QTDEORI " 
          TCQuery cQry1 ALIAS "TCD" NEW
          If !Eof()
              While !Eof()
                  // produto de custeio
                  If U_IsProdCusto(TCD->D4_COD)
                     TCD->(dbSkip())
                     Loop
                  Endif   

                  RecLock("ORI", .t.)
                  ORI->ORI_COMP := TCD->D4_COD
                  ORI->ORI_TRT  := TCD->D4_TRT
                  ORI->ORI_QTDE := Round(TCD->D4_QTDEORI, 3)
              	   MsUnLock()
              	   DbSelectArea("TCD")
              	   DbSkip()
          	  EndDo
	      Else
          
          // rotina era utilizada pois o sd4 era excluído até 04/2014
           
          	cQry1 := ""
          	cQry1 += "SELECT SG1.G1_COMP, SG1.G1_TRT, ROUND((SG1.G1_QUANT + (SG1.G1_QUANT * (SG1.G1_PERDA / 100))), 3) AS G1_QUANT "
          	cQry1 += "FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
          	cQry1 += "WHERE SG1.G1_FILIAL  = '"+xFilial("SG1")+"' "
          	cQry1 += "  AND SG1.D_E_L_E_T_ = '' "
          	cQry1 += "  AND SG1.G1_COD     = '"+ZZA->ZZA_PRODUT+"' "
          	cQry1 += "ORDER BY SG1.G1_TRT "
          	TCQuery cQry1 ALIAS "TCQ" NEW

          	While !Eof()
                // produto de custeio
                If U_IsProdCusto(TCQ->G1_COMP)
                   TCQ->(dbSkip())
                   Loop
                Endif   
                If Len(Alltrim(TCQ->G1_COMP)) == 5 .or. Len(Alltrim(TCQ->G1_COMP)) == 6
                   If Round(TCQ->G1_QUANT * cGetQtd, 3) > 30.0
                      cQry1 := ""
                      cQry1 += "SELECT SG1.G1_COMP, SG1.G1_TRT, ROUND((SG1.G1_QUANT + (SG1.G1_QUANT * (SG1.G1_PERDA / 100))), 3) AS G1_QUANT "
                      cQry1 += "FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
                      cQry1 += "WHERE SG1.G1_FILIAL  = '"+xFilial("SG1")+"' "
                      cQry1 += "  AND SG1.D_E_L_E_T_ = '' "
                      cQry1 += "  AND SG1.G1_COD     = '"+TCQ->G1_COMP+"' "
                      cQry1 += "ORDER BY SG1.G1_TRT "
                      TCQuery cQry1 ALIAS "TCO" NEW
                      While !Eof()
                        // produto de custeio
                        If U_IsProdCusto(TCO->G1_COMP)
                           TCO->(dbSkip())
                           Loop
                        Endif   
                        RecLock("ORI", .t.)
                        ORI->ORI_COMP := TCO->G1_COMP
                        ORI->ORI_TRT  := TCO->G1_TRT
                        ORI->ORI_QTDE := Round((TCQ->G1_QUANT * cGetQtd) * TCO->G1_QUANT, 3)
                        MsUnLock()
                        DbSelectArea("TCO")
                        DbSkip()
                      EndDo
                      DbSelectArea("TCO")
                      DbCloseArea()
                   ElseIf Empty(Posicione("SB2", 1, xFilial("SB2")+TCQ->G1_COMP+Posicione("SB1",1,xFilial("SB1")+TCQ->G1_COMP,"B1_LOCPAD"), "B2_LOCALIZ"))
                          cQry1 := ""
                          cQry1 += "SELECT SG1.G1_COMP, SG1.G1_TRT, ROUND((SG1.G1_QUANT + (SG1.G1_QUANT * (SG1.G1_PERDA / 100))), 3) AS G1_QUANT "
                          cQry1 += "FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
                          cQry1 += "WHERE SG1.G1_FILIAL  = '"+xFilial("SG1")+"' "
                          cQry1 += "  AND SG1.D_E_L_E_T_ = '' "
                          cQry1 += "  AND SG1.G1_COD     = '"+TCQ->G1_COMP+"' "
                          cQry1 += "ORDER BY SG1.G1_TRT "
                          TCQuery cQry1 ALIAS "TCO" NEW
                          While !Eof()
                              // produto de custeio
                              If U_IsProdCusto(TCO->G1_COMP)
                                 TCO->(dbSkip())
                                 Loop
                              Endif   
                              RecLock("ORI", .t.)
                              ORI->ORI_COMP := TCO->G1_COMP
                              ORI->ORI_TRT  := TCO->G1_TRT
                              ORI->ORI_QTDE := Round((TCQ->G1_QUANT * cGetQtd) * TCO->G1_QUANT, 3)
                              MsUnLock()
                              DbSelectArea("TCO")
                              DbSkip()
                          EndDo
                          DbSelectArea("TCO")
                          DbCloseArea()
                   Else
                      RecLock("ORI", .t.)
                         ORI->ORI_COMP := TCQ->G1_COMP
                         ORI->ORI_TRT  := TCQ->G1_TRT
                         ORI->ORI_QTDE := Round(TCQ->G1_QUANT * cGetQtd, 3)
                      MsUnLock()
                   Endif
                Else
                   RecLock("ORI", .t.)
                      ORI->ORI_COMP := TCQ->G1_COMP
                      ORI->ORI_TRT  := TCQ->G1_TRT
                      ORI->ORI_QTDE := Round(TCQ->G1_QUANT * cGetQtd, 3)
                   MsUnLock()
                Endif
                DbSelectArea("TCQ")
                DbSkip()
          
          	Enddo  
            DbSelectArea("TCQ")
            DbCloseArea()
          Endif

		  If ChkFile("TCD")
			DbSelectArea("TCD")
			DbCloseArea()
		  Endif
          
          // buscar dados do apontamento
          cQry1 := ""
          cQry1 += "SELECT ZZF_CODIGO, ZZF_TRT, ROUND(ZZF_QTDUSA, 3) AS ZZF_QTDUSA, ZZF_LOCAL "
		  cQry1 += "FROM "+RetSqlName("ZZF")+" ZZF WITH (NOLOCK) "
          cQry1 += "WHERE ZZF.ZZF_FILIAL  = '"+xFilial("ZZF")+"' "
          cQry1 += "  AND ZZF.D_E_L_E_T_ = '' "
          cQry1 += "  AND ZZF.ZZF_LOTE  = '"+cGetLot+"' "
          cQry1 += "ORDER BY ZZF.ZZF_TRT "
	      TCQuery cQry1 ALIAS "TCA" NEW
          While !Eof()
	          RecLock("APT", .t.)
    	          APT->APT_COMP := TCA->ZZF_CODIGO
                  APT->APT_TRT  := TCA->ZZF_TRT
                  APT->APT_QTDE := Round(TCA->ZZF_QTDUSA, 3)
 				  APT->APT_LOCA := TCA->ZZF_LOCAL
               MsUnLock()
               DbSelectArea("TCA")
               DbSkip()
		  EndDo
          DbSelectArea("TCA")
          DbCloseArea()
       	  
       	  DbSelectArea("TCE")
       	  DbCloseArea()
       	  // buscar dados do envase
       	  cQry1 := ""
       	  cQry1 += "SELECT SC2.C2_PRODUTO, SC2.C2_QUANT, SC2.C2_QUJE, SC2.C2_LOCAL, B1_DESC, B1_TIPO,  "
	   	  cQry1 += "SUBSTRING(SC2.C2_DATRF,7,2)+'/'+SUBSTRING(SC2.C2_DATRF,5,2)+'/'+SUBSTRING(SC2.C2_DATRF,1,4) AS C2_DATRF "
	   	  cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) "
       	  cQry1 += "ON SC2.C2_FILIAL = SB1.B1_FILIAL AND SC2.C2_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
       	  cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
       	  //cQry1 += "  AND SB1.B1_TIPO = 'PA' "
       	  cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
       	  cQry1 += "  AND SC2.C2_LOTE  = '"+cGetLot+"' "
       	  cQry1 += "ORDER BY SC2.C2_OP "
	   	  TCQuery cQry1 ALIAS "TCE" NEW
       	  DbSelectArea("TCE")
       	  DbGoTop()
    	  	 While !Eof()                                                                                                                                                                                                                                              
		     	If TCE->B1_TIPO == "PA"
    		    	RecLock("_ENV", .t.)
    		    		_ENV->ENV_PROD   := TCE->C2_PRODUTO
        	        	_ENV->ENV_DESCR  := TCE->B1_DESC
            	    	_ENV->ENV_QTDORI := TCE->C2_QUANT
 						_ENV->ENV_QTDENT := TCE->C2_QUJE
 						_ENV->ENV_DATRF  := TCE->C2_DATRF
		            MsUnLock()
      			Elseif TCE->B1_TIPO =="PI"
					nVolSC2 := TCE->C2_QUJE
				Endif       					
    		 	DbSelectArea("TCE")
             	DbSkip()
		  	 EndDo
	         DbSelectArea("TCE")
       	     DbCloseArea()
       Else
          cGetOrd := space(13)
          oGetOrd:Refresh()
     //     oGetOrd:SetFocus()
       Endif

       //Fazer ajuste do informativo PERDA / SOBRA
       DbSelectArea("ZZA")
       DbSetOrder(3)
       DbSeek(xFilial("ZZA")+Alltrim(cGetLot), .t.)
       nQtdVol := 0
       If Found()
       		While !Eof() .and. (ZZA->ZZA_FILIAL == XFilial("ZZA")) .and. (ZZA->ZZA_LOTE == Alltrim(cGetLot))
	            nQtdConv := Posicione("SB1", 1, xFilial("SB1")+ZZA->ZZA_PRODUT, "B1_CONV")
	            cTipoPro := Posicione("SB1", 1, xFilial("SB1")+ZZA->ZZA_PRODUT, "B1_TIPO") 
	            cSegUM   := Posicione("SB1", 1, xFilial("SB1")+ZZA->ZZA_PRODUT, "B1_SEGUM") 
	            //nZZAPESP := Posicione("SB1", 1, xFilial("SB1")+ZZA->ZZA_PRODUT, "B1_PESOESP")
	            If cTipoPro == 'PI'  
    	         	cProduto := ZZA->ZZA_PRODUT
    	         	cLocal   := Iif(SubStr(ZZA->ZZA_HELP, 1, 1) $ '1', '02', '20')
      	         	nZZAPESP := Iif(ZZA->ZZA_PESLAB >0, ZZA->ZZA_PESLAB, ZZA->ZZA_PESESP)
      	         	If !Empty(ZZA->ZZA_HFIM) .and. ZZA->ZZA_FLAG $ '5'
     		      		nVolZZA := ZZA->ZZA_QUANT
                 		If lOpAjut =.f.
 		          			lOpAjut  = Iif(!Empty(ZZA->ZZA_SP),.t.,.f.)
 		          			cPerSobr = Iif(!Empty(ZZA->ZZA_SP),Alltrim(ZZA->ZZA_SP),"")
        	     		Endif
            	 	Else
                		nVolZZA  := 0
                		cZZACampo:= ZZA->ZZA_CAMPO
             		Endif
            	Elseif cTipoPro == 'PA' .and. !(ZZA->ZZA_FLAG) $ '6.9.X'
             		//nQtdVol += Iif(Alltrim(cSegUM) $ 'K' ,(ZZA->ZZA_QUANT * (nQtdConv/ nZZAPESP)), (ZZA->ZZA_QUANT * nQtdConv))
             	    nQtdVol += (ZZA->ZZA_QUANT * nQtdConv)
             	    lExistApt := .t.
             	Endif
             	DbSelectArea("ZZA")
             	DbSkip()
       		Enddo
       Endif
       DbSelectArea("ZZA")
       DbClosearea()

       nSaldo := (Iif(nVolSC2 > 0, nVolSC2, nVolZZA)-nQtdVol)
       If lExistApt 
       		If cPerSobr $ "A.S" .or. cPerSobr ==""
          		If nVolZZA > 0
 	 				If cPerSobr $ "S.A"
 	 					oBtnESa:lVisible := .f.
		  				oBtnSOk:lVisible := .f.
						oBtnGSa:lVisible := .f.
						//oBtnASo:lVisible := .f.					       		
					Else
						//oBtnASo:lVisible := .t.
						//oBtnASo:bAction  := {|| fAptSobra(cProduto,nSaldo,cLocal)}					       		
					Endif
	          		If lOpAjut  
    	        		If Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cGetOrd, 1, 11), "ZZA_SOBRA") > 0 
	    	        		cSay4Env := "Apontado Sobra de "+Alltrim(TransForm(Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cGetOrd, 1, 11), "ZZA_SOBRA"), "@E 9999.999"))+Iif(Substring(cGetPro,11,2)=='99'," Kg "," Litros ")
    					Else
    						cSay4Env := "Apontado Sobra de de 0,000 "+Iif(Substring(cGetPro,11,2)=='99'," Kg "," Litros ")
        	    		Endif
    	        		If Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cGetOrd, 1, 11), "ZZA_PERDA") > 0 
	        	    		cSay5Env := "Apontado Perda de "+Alltrim(TransForm(Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cGetOrd, 1, 11), "ZZA_PERDA"), "@E 9999.999"))+Iif(Substring(cGetPro,11,2)=='99'," Kg "," Litros ")
						Else
							cSay5Env := "Apontado Perda de 0,000 "+Iif(Substring(cGetPro,11,2)=='99'," Kg "," Litros ")
						Endif
	          		Else
    	      			If nSaldo > 0 
	    	      			cSay4Env := "Saldo Excedente de "+Alltrim(TransForm(Abs(nSaldo), "@E 9999.9999"))+Iif(Substring(cGetPro,11,2)=='99'," Kg "," Litros ")
                        Else
							cSay5Env := "Faltando Saldo de "+Alltrim(TransForm((nSaldo), "@E 9999.9999"))+Iif(Substring(cGetPro,11,2)=='99'," Kg "," Litros ")                        
                        Endif
    					    	  		
        	  		Endif
	          		oSay4Env:nClrText := CLR_BLUE
					oSay5Env:nClrText := CLR_RED
   	 	  		Else
   	 	  			oSay4Env:nClrText := CLR_RED
   	 	  			cSay4Env := "PI NÃO BAIXADO. "+Substr(cZZACampo,1,40)
					//oBtnASo:lVisible := .f.					       		
				Endif	
            Else
				cSay4Env := "Não foi apontado Sobra até o momento para esta O.P"
				//oBtnASo:lVisible := .t.					       		            
                oSay4Env:Refresh()
		        oSay5Env:Refresh()
            Endif
            /*
   			If Iif(nVolSC2 > 0, nVolSC2, nVolZZA) > nQtdVol .OR. cPerSobr ='6' //Sobrando Saldo PI
          		If lOpAjut  
          			//cSay4Env := "Eliminado Saldo de "+Alltrim(TransForm(nSaldo, "@E 9,999.9999"))+" Litros "
            		cSay4Env := "Eliminado Saldo de "+Alltrim(TransForm(Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cGetOrd, 1, 11), "ZZA_SOBRA"), "@E 9,999.9999"))+Iif(Substring(cGetPro,11,2)=='99'," Quilos "," Litros ")
            		oBtnESa:lVisible := .f.
          		Else
          			cSay4Env := "Sobrando "+Alltrim(TransForm(Abs(nSaldo), "@E 9,999.99999"))+Iif(Substring(cGetPro,11,2)=='99'," Quilos "," Litros ")
            		oBtnESa:lVisible := .f.
          		Endif
          		oSay4Env:nClrText := CLR_BLUE
   	 	  	   //	oBtnESa:bAction  := {|| u_fExcSald(cProduto,Abs(nSaldo),cLocal)}
   	 	  		oBtnGSa:lVisible := .f.
   	 	  		oBtnSOk:lVisible := .f.
       		ElseIf Iif(nVolSC2 > 0, nVolSC2, nVolZZA) < nQtdVol .OR. cPerSobr ='1' // Faltando Saldo PI
          		If nVolZZA > 0
          			If lOpAjut
          				//cSay4Env := "Gerado Saldo de "+Alltrim(TransForm(ABS(nSaldo), "@E 9,999.9999"))+" Litros "
    	 				cSay4Env := "Gerado Saldo de "+Alltrim(TransForm(Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cGetOrd, 1, 11), "ZZA_PERDA"), "@E 9,999.99999"))+Iif(Substring(cGetPro,11,2)=='99'," Quilos "," Litros ")
    	 				oBtnGSa:lVisible := .f. ; oBtnGSa:Refresh()
          			Else
          				cSay4Env := "Faltando "+Alltrim(TransForm(ABS(nSaldo), "@E 9,999.99999"))+Iif(Substring(cGetPro,11,2)=='99'," Quilos "," Litros ")
    	 				oBtnGSa:lVisible := .f. ; oBtnGSa:Refresh()
          			Endif
          			oSay4Env:nClrText := CLR_RED
   	 	  		   //	oBtnGSa:bAction  := {|| u_fGeraSal(cProduto,nSaldo,cLocal)}
   	 	  			oBtnESa:lVisible := .f.
   	 	  			oBtnSOk:lVisible := .f.
   	 	  		Else
   	 	  			oSay4Env:nClrText := CLR_RED
   	 	  			cSay4Env := "PI NÃO BAIXADO. "+Substr(cZZACampo,1,40)
   	 	  			oBtnESa:lVisible := .f.
   	 	  			oBtnSOk:lVisible := .f.
					oBtnGSa:lVisible := .f.
				Endif	
       		Else // If nVolZZA = nQtdVol // Saldo ZZA Batendo com Volume Apontado. Somente Registrar Conferência!!
          		If lOpAjut
		    		oSay4Env:nClrText := CLR_BLACK
					cSay4Env := "Ordem de Produção Já Conferida!!! " 		  		      
            		oBtnSOk:lVisible := .f.
    	 			oBtnGSa:lVisible := .f.
            		oBtnESa:lVisible := .f.
     	  		Else
            		oSay4Env:nClrText := CLR_BLUE
            		cSay4Env := "Ordem de Produção a Conferir!!! " 		  		         	        
     	 			oBtnSOk:bAction  := {|| u_fConfeOp()}
   	        		oBtnSOk:lVisible := .t. 
      	 			oBtnGSa:lVisible := .f.
            		oBtnESa:lVisible := .f.
          		Endif
       		Endif */
       Else
       		oSay4Env:nClrText := CLR_BLUE
       		If cTipoPro $ 'PI' .and. Len(Alltrim(cProduto)) < 12
       			cSay4Env := "O.P de Produto Intermediário !!! " 		  		         	        
		   	    cSay5Env := ""
   	        Else
   	        	cSay4Env := "O.P sem apontamento de P.A !!! " 		  		         	        
		   	    cSay5Env := ""
   	        Endif
   	        oBtnSOk:lVisible := .f. 
      	 	oBtnGSa:lVisible := .f.
            oBtnESa:lVisible := .f.
       Endif		
       oSay4Env:Refresh()
       oSay5Env:Refresh()
       oBtnGSa:Refresh()
       oBtnESa:Refresh()  
       oBtnSOk:Refresh()
	   //oBtnASo:Refresh()       
       
       If ChkFile("ORI")
       	  DbSelectArea("ORI")
          DbGoTop()
          oBrwOri:oBrowse:GoTop()
          oBrwOri:oBrowse:Refresh()
       Endif
	   If ChkFile("APT")
	      DbSelectArea("APT")
	      DbGotop()	 
          oBrwApt:oBrowse:GoTop()
          oBrwApt:oBrowse:Refresh()
       Endif
	   If ChkFile("_ENV")
	      DbSelectArea("_ENV")
	      DbGotop()	 
          oBrwEnv:oBrowse:GoTop()
          oBrwEnv:oBrowse:Refresh()
       Endif   
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fQtdAju() - Informa a quantidade de Sobra KG na OP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fQtdAju(nQtdAju, cProcesso)
	Local nOpcAju := 0
    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Declaração de cVariable dos componentes                                 ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    Private nGet1Aju   := nQtdAju

    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Declaração de Variaveis Private dos Objetos                             ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    SetPrvt("oFont1Aj", "oDlg1Aju", "oGrp1Aju", "oBtn2Aju", "oBtn3Aju", "oBtn1Aju", "oGet1Aju", "oBtn4Aju", "oBtn5Aju")
    SetPrvt("oBtn7Aju", "oBtn8Aju")

    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Definicao do Dialog e todos os seus componentes.                        ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    
    oFont1Aj   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
    oDlg1Aju   := MSDialog():New( 095, 232, 180, 677, "Apontar Qtde de Sobra", , , .F., , , , , , .T., , , .T. )
    oGrp1Aju   := TGroup():New( 000, 004, 020, 221, "", oDlg1Aju, CLR_BLACK, CLR_WHITE, .T., .F. )
    oBtn1Aju   := TButton():New( 005, 008, "+++"     , oDlg1Aju, {|| fMntQtd("A3", cProcesso) }, 020, 012, , oFont1Aj, , .T., , "", , , , .F. )
    oBtn2Aju   := TButton():New( 005, 034, "++"      , oDlg1Aju, {|| fMntQtd("A2", cProcesso) }, 017, 012, , oFont1Aj, , .T., , "", , , , .F. )
    oBtn3Aju   := TButton():New( 005, 056, "+"       , oDlg1Aju, {|| fMntQtd("A1", cProcesso) }, 013, 012, , oFont1Aj, , .T., , "", , , , .F. )
    oGet1Aju   := TGet():New( 004, 080,{|u| If(PCount() > 0, nGet1Aju := u, nGet1Aju)}, oDlg1Aju, 030, 012, '@E 9,999.999', , CLR_BLACK, CLR_WHITE, oFont1Aj, , , .T., "", , , .F., .F., , .T., .F., "", "nGet1Aju", ,)
    oBtn4Aju   := TButton():New( 005, 155, "-"       , oDlg1Aju, {|| fMntQtd("D1", cProcesso) }, 013, 012, , oFont1Aj, , .T., , "", , , , .F. )
    oBtn5Aju   := TButton():New( 005, 173, "- -"     , oDlg1Aju, {|| fMntQtd("D2", cProcesso) }, 017, 012, , oFont1Aj, , .T., , "", , , , .F. )
    oBtn6Aju   := TButton():New( 005, 196, "- - -"   , oDlg1Aju, {|| fMntQtd("D3", cProcesso) }, 020, 012, , oFont1Aj, , .T., , "", , , , .F. )
    oBtn7Aju   := TButton():New( 024, 004, "Volta"   , oDlg1Aju, { || lOpcMnt := .f., nOpcAju := 0, oDlg1Aju:end()               }, 037, 012, , , , .T., , "", , , , .F. )
    oBtn8Aju   := TButton():New( 024, 184, "Confirma", oDlg1Aju, { || lOpcMnt := .f., nOpcAju := 1, oDlg1Aju:end() }, 037, 012, , , , .T., , "", , , , .F. )

    oDlg1Aju:Activate( , , , .T.)
    If nOpcAju == 1
    	nOpcAju := 0
    	nGet3Mnt := nGet1Aju
	Else
        nGet1Aju := 0
	Endif
		   	
Return(nGet1Aju)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fMntQtd() - Manutenção das quantidades no apontamento da Sobra
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fMntQtd(cOpcMnt, cProcesso)

	If SubStr(cOpcMnt, 1, 1) $ 'A' //Adiciona
    	If SubStr(cOpcMnt, 2, 1) $ '1'
        	If cProcesso $ '01' // Apontamento de Sobra
            	nGet1Aju := Int(nGet1Aju) + (Int(Int((nGet1Aju - Int(nGet1Aju)) * 1000) / 100) + 1) / 10
            Endif
 		ElseIf SubStr(cOpcMnt, 2, 1) $ '2'
            If cProcesso $ '01' // Apontamento de Sobra
	            nGet1Aju := (Int(nGet1Aju) + 1) + ((Int(Int((nGet1Aju - Int(nGet1Aju)) * 1000) / 100) * 100) ) / 1000
            Endif
	    ElseIf SubStr(cOpcMnt, 2, 1) $ '3'
    		If cProcesso $ '01' // Apontamento de Sobra
            	nGet1Aju := (Int(nGet1Aju) + 10) + ((Int(Int((nGet1Aju - Int(nGet1Aju)) * 1000) / 100) * 100) ) / 1000
            Endif
		Endif
	ElseIf SubStr(cOpcMnt, 1, 1) $ 'D' //Diminui
		If SubStr(cOpcMnt, 2, 1) $ '1'
        	If cProcesso $ '01' // Apontamento de Sobra
            	nGet1Aju := Int(nGet1Aju) + ((Int(Int((nGet1Aju - Int(nGet1Aju)) * 1000) / 100) * 100) - 100) / 1000
	         	If nGet1Aju < 0
    	            nGet1Aju := 0
	                Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)
    	        Endif
            Endif
		ElseIf SubStr(cOpcMnt, 2, 1) $ '2'
        	If cProcesso $ '01' // Apontamento de Sobra
            	If (Int(nGet1Aju) - 1) >= 0.0
                	nGet1Aju := (Int(nGet1Aju) - 1) + ((Int(Int((nGet1Aju - Int(nGet1Aju)) * 1000) / 100) * 100) ) / 1000
                Else
                    Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)	
                Endif
            Endif
  		ElseIf SubStr(cOpcMnt, 2, 1) $ '3'
        	If cProcesso $ '01' // Apontamento de Sobra
            	If (Int(nGet1Aju) - 10) >= 0.0
                	nGet1Aju := (Int(nGet1Aju) - 10) + ((Int(Int((nGet1Aju - Int(nGet1Aju)) * 1000) / 100) * 100) ) / 1000
             	Else
                	Messagebox("Quantidade não pode ser negativa.!!!","Atenção...",48)	
				Endif
           Endif
    	Endif
	Endif
Return

Static Function FAptSobra(cProduto, nSaldo, cLocal)

Local _aIteAju  	:= {}
Local _aCabMov  	:= {}
Local _aAuxMov  	:= {}
//Local cQry  		:= ""
Local cQry1 		:= ""
Local nQtdAju 		:= 0
Local nPesEsp 		:= 0
Local lSoAtualiza 	:= .f. 

	nQtdAju   := fQtdAju(nQtdAju, "01")
    nVolSobra := nQtdAju 
    nVolDigit := nQtdAju 

    If MsgYesNo("Confirma o valor da sobra apontado com "+cValtoChar(Round((nVolSobra),3))+" KG ?", "Apontamento de Sobra")	  
		nQtdVol   := nSaldo //FVolProdAcab()

        cQry1 := " SELECT B2_COD,B2_LOCAL, B2_QATU, B1_DESC, B1_UM, SB2.R_E_C_N_O_ , C2_QUJE, ZZA_QUANT  "
        cQry1 += " FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
        cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON C2_FILIAL = B2_FILIAL AND C2_PRODUTO = B2_COD AND B2_LOCAL ='"+cLocal+"' AND SB2.D_E_L_E_T_ ='' "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) ON ZZA_FILIAL = C2_FILIAL AND ZZA_LOTE = C2_LOTE AND ZZA_ORDEM = C2_OP AND ZZA.D_E_L_E_T_ ='' "
        cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = B2_FILIAL AND B1_COD = B2_COD AND SB1.D_E_L_E_T_ ='' "
		cQry1 += " WHERE SC2.D_E_L_E_T_ ='' "
		cQry1 += " AND C2_OP       ='"+Alltrim(cGetOrd)+"'"
		cQry1 += " AND C2_PRODUTO  ='"+Alltrim(cProduto)+"'"
		cQry1 += " AND C2_FILIAL   ='"+xFilial("SC2")+"'"
		

        TCQuery cQry1 ALIAS "TMPSC2" NEW
        DbSelectArea("TMPSC2")
        DbgoTop()					
        If Eof()
				
		Endif
		cUndMed   := TMPSC2->B1_UM 
		cDescPro  := TMPSC2->B1_DESC 
        nQtdAtu   := TMPSC2->B2_QATU
        nReg      := TMPSC2->R_E_C_N_O_
		nVolSC2   := TMPSC2->C2_QUJE
		nVolZZA   := TMPSC2->ZZA_QUANT
		
        DbSelectArea("TMPSC2")
        DbCloseArea()

		_aIteAju  := {}
		_aCabMov  := {}
		_aAuxMov  := {}

		Begin Transaction
	   		If nQtdAju > (nQtdVol)
   				nQtdAju  := Iif(nQtdVol <0, Abs(nQtdVol)+nQtdAju ,nQtdAju-Abs(nQtdVol)) 		          	
			    _aCabMov := {{"D3_TM"      , '109'      							    , NIL},;
    	       	  			{"D3_EMISSAO"  , dDatabase   						  	    , NIL} }

			    _aAuxMov := {{"D3_COD"    , Alltrim(cProduto)     	        		    , NIL},;
				      		{"D3_QUANT"   , Abs(nQtdAju)   							   	, NIL},;
       						{"D3_UM"      , cUndMed									   	, NIL},;
			       	       	{"D3_LOCAL"   , cLocal										, NIL},; 
				           	{"D3_OBS"     , Alltrim(cGetOrd)					      	, NIL},; 
		           	        {"D3_DOC"     , NextNumero("SD3",2,"D3_DOC",.T.)  	        , NIL} } 
        	
        	    aAdd(_aIteAju, _aAuxMov)
		
				If U_EstaBloqueado('SB2',nReg)
					Messagebox("Registro estava Bloqueado !! "+nReg,"Atenção...",64)    	
		            DbSelectArea("SB2")
	                MsUnLock()
				Endif

				lMsErroAuto := .f.
				MSExecAuto({|x, y, z| MATA241(x, y, z)}, _aCabMov, _aIteAju, 3)

				If lMsErroAuto
					DisarmTransaction() 
				    Mostraerro()
					//Return() //LGS#20200206 - Adequação de release 12.1.25 e posteriores - Não pode usar return dentro de begin transaction
				Else
					Messagebox("Apontamento de Sobra realizado com Sucesso !! ","Atenção...",64)  
				 	//oBtnASo:lVisible := .f. 
				Endif

            Elseif nQtdAju <= Abs(nQtdVol) 
	       		nQtdAju :=  Iif(nQtdAju = Abs(nQtdVol), nQtdAju, (Abs(nQtdVol)-nQtdAju))
				If (nQtdAtu < ABS(nQtdAju)) .and. (nQtdAtu >0)
					nQtdAju := nQtdAtu
				ElseIf nQtdAtu = 0 .or. nQtdAju =0 // se não existir saldo no b2 ou se a quantidade apontada de sobra for igual a zero
                    lSoAtualiza := .t.
		  		Endif
      		    
       			_aCabMov := {{"D3_TM"    , '599'        						 , NIL},;
	    	    	        {"D3_EMISSAO", dDatabase    						 , NIL} }
  	
	    	    _aAuxMov := {{"D3_COD"    , Alltrim(cProduto)    				 , NIL},;
				    	    {"D3_QUANT"   , Abs(nQtdAju)						 , NIL},;
					  	    {"D3_UM"      , cUndMed								 , NIL},;
          	    	        {"D3_LOCAL"   , cLocal								 , NIL},; 
   		   	   	    	    {"D3_OBS"     , Alltrim(cGetOrd)                     , NIL},; 
	               	        {"D3_DOC"     , NextNumero("SD3",2,"D3_DOC",.T.)  	 , NIL} } 

	      	    aAdd(_aIteAju, _aAuxMov)                                                                           
	
			    lMsErroAuto := .f.

       		    If !lSoAtualiza				  
					If U_EstaBloqueado('SB2',nReg)
						Messagebox("Registro Bloqueado !! "+nReg,"Atenção...",64)    	
		                DbSelectArea("SB2")
        	            MsUnLock()
					Endif
					PutMv("MV_ESTNEG" , "S")  
			        MSExecAuto({|x, y, z| MATA241(x, y, z)}, _aCabMov, _aIteAju, 3)
                Endif

				PutMv("MV_ESTNEG" , "N")  
	
			    If lMsErroAuto
    				DisarmTransaction() 
                   	cStrErr := MemoLine( MemoRead( NomeAutoLog() ), 30, 1)
                   	If "MA240NEGAT" $ cStrErr
	                	Messagebox("Não existe saldo suficiente para exclusão !!","Atenção...",64)    	
                   	Else
						Mostraerro()
						//Return()  //LGS#20200206 - Adequação de release 12.1.25 e posteriores - Não pode usar return dentro de begin transaction
				  	Endif 
				Else
					Messagebox("Apontamento de Sobra realizado com Sucesso !! ","Atenção...",64)  
				 	//oBtnASo:lVisible := .f. 
				Endif
			Endif
			
			nVolTotPI := Iif(nVolSC2 > 0, nVolSC2, nVolZZA)
			nVolTotPA := FVolTotPa()
			nVolPerda := Iif(nVolTotPI - (nVolTotPA + nVolSobra) <0, 0 , nVolTotPI - (nVolTotPA + nVolSobra)) 
                	
	        nPesEsp := Posicione("ZZA", 2, xFilial("ZZA")+SubStr(cGetOrd, 1, 11), "ZZA_PESLAB") 
	     	nPesEsp := Iif(nPesEsp =0, Posicione("SB1", 1, xFilial("SB1")+Alltrim(cProduto), "B1_PESOESP") , nPesEsp)
    	                    
        	If Alltrim(cUndMed) $ 'L' 
				nVolSobra := Iif(nVolSobra > 0, Round((nVolSobra / nPesEsp),4), 0 )
		   		nVolPerda := Iif(nVolPerda > 0, Round((nVolPerda / nPesEsp),4), 0 )
		  	Endif                 

			cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_SP = '"+Iif(Substr(Alltrim(cProduto),4,2) $ '97-98-99' .OR. nVolSobra = 0,'S','A')+"', ZZA_SOBRA="+StrTran(TransForm((nVolSobra), '@E 9999.99999'), ",", ".")+", ZZA_PERDA="+StrTran(TransForm((nVolPerda), '@E 9999.99999'), ",", ".")+"  WHERE D_E_L_E_T_ ='' AND ZZA_FILIAL ='"+xFilial("ZZA")+"' AND ZZA_ORDEM = '"+Alltrim(cGetOrd)+"' "
			TCSQLExec(cQry1)		
	
			cQry2 := "UPDATE "+RetSqlName("SC2")+" SET C2_XSOBRA ="+StrTran(TransForm((nVolDigit), '@E 9999.99999'), ",", ".")+"  WHERE D_E_L_E_T_ ='' AND C2_FILIAL ='"+xFilial("SC2")+"' AND C2_OP = '"+Alltrim(cGetOrd)+"' "
			TCSQLExec(cQry2)		
            
			fBusOrd()
			
        End Transaction

    Endif
Return

// Retorna o volume do Pa apontado na OP
Static Function FVolTotPa()

	cArea:= GetArea()

	DbSelectArea("ZZA")
 	DbSetOrder(3)
    DbSeek(xFilial("ZZA")+Alltrim(cGetLot), .t.)
	nQtdVol := 0
    If Found()
		While !Eof() .and. (ZZA->ZZA_FILIAL == XFilial("ZZA")) .AND. (ZZA->ZZA_LOTE == Alltrim(cGetLot))
			nQtdConv := Posicione("SB1", 1, xFilial("SB1")+ZZA->ZZA_PRODUT, "B1_CONV")
			cTipoPro := Posicione("SB1", 1, xFilial("SB1")+ZZA->ZZA_PRODUT, "B1_TIPO") 
        	If cTipoPro == 'PA' .and. !(ZZA->ZZA_FLAG) $ '6.9.X'
        		nQtdVol += (ZZA->ZZA_QUANT * nQtdConv)
        	Endif
		    DbSelectArea("ZZA")
        	DbSkip()
		Enddo
	Endif
	
	DbSelectArea("ZZA")
	DbClosearea()

                                                                               
	RestArea(cArea)  

Return(nQtdVol)

User Function fAtuaZZA()

	Local cQry 		:= ""
	Local lOcorren	:= .f.
	Local lOpAberta	:= .f.
	Local nPorcent  := 0
	Local aVetor 	:= {}
  	//Local cDocument := ""
  	
  	If ChkFile("TCE")
		DbSelectArea("TCE")
		DbCloseArea()
	Endif    
    Return() // rotina desativada em 10/06/16
    /*
	cQry += " WITH TMP AS (SELECT ZZA_FILIAL AS FILIAL, ZZA.ZZA_ORDEM AS ORDEM, ZZA_LOTE AS LOTE, ZZA_PRODUT AS PRODUT, ROUND(ZZA_QUANT,4) AS QUANT, CASE WHEN SUBSTRING(ZZA_HELP,1,1) ='1' THEN '02' ELSE '20' END AS LOC, B2_QATU AS QATU, B1_UM "
	cQry += " FROM "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) "
	cQry += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON ZZA_FILIAL = B1_FILIAL AND ZZA_PRODUT = B1_COD AND SB1.D_E_L_E_T_ ='' "
	cQry += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH(NOLOCK) ON B2_FILIAL = ZZA_FILIAL AND B2_COD = ZZA_PRODUT AND B2_LOCAL = CASE WHEN SUBSTRING(ZZA_HELP,1,1) ='1' THEN '02' ELSE '20' END AND SB2.D_E_L_E_T_ ='' "
	cQry += " WHERE ZZA_FILIAL ='"+XFilial("ZZA")+"' AND ZZA.D_E_L_E_T_ ='' AND ZZA_SP ='' AND  ZZA_FLAG ='5' AND ZZA_QUANT >0 AND ZZA_SOBRA =0 AND ZZA_PERDA =0 AND B1_TIPO ='PI' AND LEN(B1_COD)=12)"
	cQry += " SELECT TMP.FILIAL, TMP.LOC, TMP.LOTE, TMP.ORDEM, SC2.C2_OP AS 'ORDEMPA', TMP.PRODUT, TMP.B1_UM, SC2.C2_PRODUTO AS 'PRODUTPA', TMP.QUANT , SUM(C2_QUJE * B1_CONV) AS TOTALBAIXADO,  ROUND((ROUND(TMP.QUANT,2) - ROUND(SUM(C2_QUJE * B1_CONV),2)),5) AS DIFERENCA  "
	cQry += " FROM TMP " 																						
	cQry += " LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ON C2_FILIAL = TMP.FILIAL AND C2_LOTE = TMP.LOTE AND SUBSTRING(TMP.PRODUT,1,10) = SUBSTRING(C2_PRODUTO,1,10) AND SC2.D_E_L_E_T_ ='' "
	cQry += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON C2_FILIAL = B1_FILIAL AND C2_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ ='' "
	cQry += " WHERE B1_TIPO ='PA' AND C2_DATRF <>'' AND C2_FILIAL ='"+XFilial("SC2")+"' AND C2_DATRF >'"+DTOS(GetMV("MV_ULMES"))+"'" 
	cQry += " AND C2_LOTE NOT IN (SELECT ZZR_LOTE FROM "+RetSqlName("ZZR")+" ZZR  WITH (NOLOCK) WHERE ZZR_FILIAL ='"+xFilial("ZZR")+"' AND ZZR.D_E_L_E_T_='' AND ZZR_TIPO='PA') "
	cQry += " GROUP BY TMP.FILIAL, TMP.LOTE, TMP.PRODUT, TMP.QUANT, TMP.LOC, TMP.QATU, TMP.ORDEM, SC2.C2_OP, SC2.C2_PRODUTO, TMP.B1_UM "
	cQry += " HAVING (ROUND(TMP.QATU,2) >= ROUND((TMP.QUANT - SUM(C2_QUJE * B1_CONV)),2)) AND (ROUND(TMP.QUANT,2) - ROUND(SUM(C2_QUJE * B1_CONV),2)) >=0
	cQry += " ORDER BY TMP.LOTE "
     */

	cQry += " WITH TMP AS "
	cQry += " (SELECT ZZA_FILIAL AS FILIAL, ZZA.ZZA_ORDEM AS ORDEM, ZZA_LOTE AS LOTE, ZZA_PRODUT AS PRODUT, ROUND(ZZA_QUANT,4) AS QUANT, CASE WHEN SUBSTRING(ZZA_HELP,1,1) ='1' THEN '02' ELSE '20' END AS LOC, B2_QATU AS QATU, B1_UM  "
	cQry += " FROM "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) "
	cQry += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON ZZA_FILIAL = B1_FILIAL AND ZZA_PRODUT = B1_COD AND SB1.D_E_L_E_T_ ='' "
	cQry += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH(NOLOCK) ON B2_FILIAL = ZZA_FILIAL AND B2_COD = ZZA_PRODUT AND B2_LOCAL = CASE WHEN SUBSTRING(ZZA_HELP,1,1) ='1' THEN '02' ELSE '20' END AND SB2.D_E_L_E_T_ ='' "
	cQry += " WHERE ZZA_FILIAL ='"+XFilial("ZZA")+"' AND ZZA.D_E_L_E_T_ ='' AND ZZA_SP ='' AND  ZZA_FLAG ='5' AND ZZA_QUANT >0 AND ZZA_SOBRA =0 AND ZZA_PERDA =0 AND B1_TIPO ='PI' AND LEN(B1_COD)=12)"
	cQry += " SELECT TMP.ORDEM, TMP.LOTE, TMP.PRODUT, TMP.LOC, TMP.QATU, SUM(C2_QUJE * B1_CONV) AS 'TOTALBAIXADO', ROUND(TMP.QUANT - SUM(C2_QUJE * B1_CONV),2) AS 'DIFERENCA' FROM TMP "
	cQry += " LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 ON C2_FILIAL = TMP.FILIAL AND C2_LOTE = TMP.LOTE AND SC2.D_E_L_E_T_ ='' "
	cQry += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = C2_FILIAL AND B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ ='' "
	cQry += " WHERE B1_TIPO ='PA' AND C2_DATRF <>'' AND C2_FILIAL ='"+XFilial("SC2")+"' AND C2_DATRF >'"+DTOS(GetMV("MV_ULMES"))+"'" 
	cQry += " AND SUBSTRING(C2_PRODUTO,11,2) NOT IN('00','99') AND C2_LOTE NOT IN (SELECT ZZR_LOTE FROM "+RetSqlName("ZZR")+" ZZR  WITH (NOLOCK) WHERE ZZR_FILIAL ='"+xFilial("ZZR")+"' AND ZZR.D_E_L_E_T_='' AND ZZR_TIPO='PA') "
	cQry += " GROUP BY TMP.LOTE, TMP.PRODUT, TMP.QUANT, TMP.LOC, TMP.QATU, TMP.ORDEM " 
	cQry += " HAVING (ROUND(TMP.QATU,2) >= ROUND((TMP.QUANT - SUM(C2_QUJE * B1_CONV)),2)) AND (ROUND(TMP.QUANT,2) - ROUND(SUM(C2_QUJE * B1_CONV),2)) >=0 "
	cQry += " ORDER BY TMP.LOTE "

    TCQuery cQry ALIAS "TCE" NEW
    DbSelectArea("TCE")
    DbGoTop()

  	While !(TCE->(EOF()))
		If (TCE->DIFERENCA = 0)
			cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_SP = '5' WHERE D_E_L_E_T_= '' AND ZZA_FILIAL ='"+xFilial("ZZA")+"' AND ZZA_ORDEM = '"+Alltrim(TCE->ORDEM)+"' "
			XXX := TCSQLExec(cQry1)		
		ElseIf (TCE->DIFERENCA <> 0 .and. !Substr(Alltrim(TCE->PRODUT),4,2) $ '97.98.99')
			DbSelectArea("ZZS")
			DbGoTop()
            // Verifica se o saldo excedente esta dentro do limite em percentual definido como normal para o saldo total da op.
			While !(ZZS->(eof())) .AND. (ZZS->ZZS_FILIAL = XFilial("ZZS"))
				If (TCE->DIFERENCA >= ZZS->ZZS_QTMIN) .AND. (TCE->DIFERENCA <= ZZS->ZZS_QTMAX) 
					nPorcent:= ROUND(((TCE->DIFERENCA * 100) / TCE->TOTALBAIXADO),2)
					If (nPorcent <= ZZS->ZZS_PERCEN) //Esta dentro da porcentagem permitida para baixa, não é ocorrencia
						lOcorren :=	.f.
					Else
						lOcorren :=	.t.
					EndIF
				EndIf
				ZZS->(dbSkip())
			EndDo
            DbSelectArea("ZZS")
            DbCloseArea()
            
	    	lOpAberta :=.f.
    	    DbSelectArea("SC2")
		    DbSetOrder(13)
		    DbSeek(xFilial("SC2")+Alltrim(TCE->LOTE), .t.)
		    If Found() 
		    	While !(SC2->(Eof())) .AND. (XFilial("SC2") == SC2->C2_FILIAL) .AND. (SC2->C2_LOTE == Alltrim(TCE->LOTE))
					If Empty(SC2->C2_DATRF)
						lOpAberta := .t.
					Endif
					DbSelectArea("SC2")
					DbSkip()        	
		  		Enddo
		    Endif
			DbSelectArea("SC2")
			DbCloseArea()
	       	
	       	If !lOpAberta .and. !lOcorren
            	aVetor := {}
			    aVetor := { {"D3_FILIAL"    , xFilial("SD3")   				, NIL},;
			   		        {"D3_TM"     	, "600"         				, NIL},;  //Sobra
			                {"D3_COD"    	, Alltrim(TCE->PRODUT) 			, NIL},;
			                {"D3_LOCAL"  	, TCE->LOC		  				, NIL},;
			                {"D3_EMISSAO"	, dDatabase		  				, NIL},;   
			                {"D3_DOC"		, TCE->LOTE  					, NIL},;
			                {"D3_UM"		, Posicione("SB1", 1, xFilial("SB1")+Alltrim(TCE->PRODUT), "B1_UM"), NIL},;  
		       	        	{"D3_TURNO"     , ""							, NIL},; 
		       	        	{"D3_OBS"       , Alltrim(TCE->ORDEM)			, NIL},;  // -> Grava no número da o.p do Pa que gerou a exclusão do saldo                                              
			                {"D3_QUANT"  	, ROUND((TCE->DIFERENCA),5 )	, NIL} }  // não é possível gravar no campo D3_OP pq a mesma já pode ter  
				 															 		  // sido encerrada e neste caso a movimentação não ocorre.
				lMsErroAuto:=.f.      
			    MSExecAuto({|x,y| MATA240(x, y)}, aVetor, 3) 

				If !lMsErroAuto
					cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_SP = '6', ZZA_SOBRA="+StrTran(TransForm(ABS(TCE->DIFERENCA), '@E 999999.99999'), ",", ".")+"  WHERE D_E_L_E_T_ ='' AND ZZA_FILIAL ='"+xFilial("ZZA")+"' AND ZZA_ORDEM = '"+Alltrim(TCE->ORDEM)+"' "
					XXX := TCSQLExec(cQry1)		
				EndIf
            Endif
		    /*
		    If lOcorren .and. !lOpAberta 	// Gera Ocorrencia
			    cDocument:=  NextNumero("SD3",2,"D3_DOC",.T.)   //Gera o proximo numero de documento
 	         //GravaZZR( cOP         ,cLocal                       ,cProduto     ,cLote    ,cClass ,cDescr,cDoc     ,cItem      ,cLocItem,nQuant                 ,cCor,cFlag,cTipo)
			    GravaZZR(TCE->ORDEMPA,IIF(TCE->LOC $'02','03','30'),TCE->PRODUTPA,TCE->LOTE,""     ,""    ,cDocument,TCE->PRODUT,TCE->LOC,ROUND(TCE->DIFERENCA,5),"1" ,"M"  ,'PA')		
         	EndIf */ 
		Endif 
		DbSelectArea("TCE")
		DbSkip()
    Enddo
    
	DbSelectArea("ZZS")
	DbCloseArea()
	
    DbSelectArea("TCE")
    DbCloseArea() 
    
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Function  ³ fApont() - Carrega na tela os apontadores da Ordem de Produção
 ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
User Function fApont(cGetOrdem)
     
     Local cQry := ""
     //Local nCont:= 0
     SetPrvt("oBrwApt2", "Apt2")

     oTblApt2() // CRIAR TABELA TEMPORÁRIA
   	 
   	 DbSelectArea("APT2")
   	 DbSetOrder(1)
     
     If ChkFile("APT2")
        DbSelectArea("APT2")
        DbGoTop()
     	//LGS#20200211 - Adequação de release 12.1.25 e posteriores
       	//Zap
       	TCSqlExec("DELETE FROM " + oTempTbl10:GetRealName() )
     Endif

     If Len(Alltrim(cGetOrdem))==0 
     	Return
     Endif
	 cQry := ""
     cQry +=" SELECT CASE WHEN ZZG.ZZG_TPUSER ='B' THEN '1 - BALAN' ELSE "
     cQry +=" 	     CASE WHEN ZZG.ZZG_TPUSER ='L' THEN '2 - LABOR' ELSE "
     cQry +="   	 CASE WHEN ZZG.ZZG_TPUSER ='C' THEN '3 - COLOR' ELSE "
     cQry +="   	 CASE WHEN ZZG.ZZG_TPUSER ='E' THEN '4 - ENVAS' ELSE "
	 cQry +="   	 CASE WHEN ZZG.ZZG_TPUSER ='Y' THEN '5 - PESA1' ELSE "     
	 cQry +="   	 CASE WHEN ZZG.ZZG_TPUSER ='Z' THEN '6 - PESA2' ELSE ZZG_TPUSER END END END END END END AS ZZG_TPUSER, "
     cQry += " ZZG.ZZG_SEQENV, ZZG.ZZG_PROENV, ISNULL(ZZA.ZZA_QUANT,0) AS ZZA_QUANT, SRA.RA_MAT, SRA.RA_NOME, ZZA.ZZA_FLAG "
     cQry += " FROM "+RetSqlName("ZZG")+" ZZG WITH(NOLOCK) LEFT OUTER JOIN "+RetSqlName("SRA")+" SRA WITH(NOLOCK) "
     cQry += " ON ZZG_FILIAL = RA_FILIAL AND ZZG_FILMAT = RA_MAT AND SRA.D_E_L_E_T_ ='' "
     cQry += " LEFT OUTER JOIN "+RetSqlName("ZZA")+" ZZA WITH(NOLOCK) "
     cQry += " ON ZZA_FILIAL = ZZG_FILIAL AND ZZA_LOTE = ZZG_LOTE  AND ZZA_PRODUT = ZZG_PROENV AND ZZA_SEQENV = ZZG_SEQENV AND ZZA.D_E_L_E_T_ ='' "
     cQry += " WHERE ZZG.ZZG_FILIAL  = '"+xFilial("ZZG")+"' "
     cQry += "  AND ZZG.D_E_L_E_T_ = '' "
     cQry += "  AND ZZG.ZZG_ORDEM  = '"+cGetOrdem+"' "
     cQry += "ORDER BY ZZG_PROENV, ZZG.R_E_C_N_O_   "
     TCQuery cQry ALIAS "TCQ" NEW
	 If !Eof()
	 	While !Eof()
	    	 RecLock("APT2", .t.)
         		APT2->APT2_TPUSE := TCQ->ZZG_TPUSER
            	APT2->APT2_SEQEN := TCQ->ZZG_SEQENV
            	APT2->APT2_PROEN := TCQ->ZZG_PROENV
            	APT2->APT2_QUANT := Iif(TCQ->ZZA_QUANT=0 .AND. LEN(ALLTRIM(TCQ->ZZG_PROENV))>0 .AND. !TCQ->ZZA_FLAG $ '6' ,'ENCE' , Iif(TCQ->ZZA_QUANT =0, "-", ALLTRIM(STR(TCQ->ZZA_QUANT))) )
            	APT2->APT2_FILMA := TCQ->RA_MAT
				APT2->APT2_NOME  := Substr(TCQ->RA_NOME,1,25)
         	MsUnLock()
         	DbSelectArea("TCQ")
         	DbSkip()
     	EndDo
     Else
     	MsgStop ("Não encontrado apontadores para a O.P Especificada")
     Endif
     
     DbSelectArea("TCQ")
     DbCloseArea() 
    
     U_PCPA01_8()
     
Return
          
/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Function  ³ PCPA01_8() - Tela que carrega a tabela temporária com os Apon
  						   tadores da Ordem de produção  
 ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

User Function PCPA01_8() 

Local oDlg

	oDlg 	:= MSDIALOG():New(000,000,262,562, 'Apontadores da Ordem de Produção',,,,,,,,,.T.)
	
    If ChkFile("APT2")     
        DbSelectArea("APT2")
        DbGotop()	 
    Endif
     	
	oBrowse := MsSelBr():New( 02,01,272,128,,,,oDlg,,,,,,,,,,,,.F.,'APT2',.T.,,.F.,,, )
	oBrowse:AddColumn(TCColumn():New('Processo' ,{||APT2->APT2_TPUSE},,,,'LEFT',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New('Sequ.'    ,{||APT2->APT2_SEQEN},,,,'CENTER',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New('Produto'  ,{||APT2->APT2_PROEN},,,,'LEFT',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New('Quant'    ,{||APT2->APT2_QUANT},,,,'CENTER',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New('Matric.'  ,{||APT2->APT2_FILMA},,,,'CENTER',,.F.,.F.,,,,.F.,))
	oBrowse:AddColumn(TCColumn():New('Nome'     ,{||APT2->APT2_NOME },,,,'LEFT',,.F.,.F.,,,,.F.,))

    TBrowseButton():New(131,218,'Sair',oDlg,{|| oDlg:End() },37,12,,,.F.,.T.,.F.,,.F.,,,)
    

oDlg:lCentered := .T.
oDlg:Activate()

Return 


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Function  ³ fConfeOp() - Alimentar Campo ZZA_SP com 5 Ok Conferida  
 ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

User Function fConfeOp()

Local cQry1   :=""	

    If !lAcs6  
       	MsgBox("Usuário não possui acesso a essa a essa Rotina", "Atenção", "STOP")
      	Return
    Endif

 	cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_SP ='5' WHERE D_E_L_E_T_ ='' AND ZZA_FILIAL ='"+xFilial("ZZA")+"' AND ZZA_ORDEM = '"+Alltrim(cGetOrd)+"' "
	XXX := TCSQLExec(cQry1)
	oBtnSOk:lVisible := .f. ; oBtnSOk:Refresh()		
	Messagebox("Ordem de Produção Conferida !!","Atenção...",64) 	
	
Return                                           

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Function  ³ fGeraSal() - Inclusão de pequenos saldos que faltam durante
  							o apontamento de produção em função do arrendonda
  							mento da balança de 200 em 200 grs
  							André Maester Julho/2013
 ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

User Function fGeraSal(cProduto,nSaldo,cLocal)

Local cQry1   := ""	
Local cNumOp  := ""
Local aAuxMov := {}
Local aCabMov := {}
Local aIteAju := {}

Private lMsErroAuto := .f. //necessario a criacao

    If !lAcs6  
       	MsgBox("Usuário não possui acesso a essa a essa Rotina", "Atenção", "STOP")
      	Return
    Endif
    
    DbSelectArea("SC2")
    DbSetOrder(13)
    DbSeek(xFilial("SC2")+Alltrim(cGetLot), .t.)
    If Found() 
    	While !Eof() .and. (SC2->C2_FILIAL == xFilial("SC2")) .and. (SC2->C2_LOTE == Alltrim(cGetLot))
			If Empty(SC2->C2_DATRF) .and. Len(Alltrim(SC2->C2_PRODUTO)) == 12 .and. !Substr(SC2->C2_PRODUTO,11,2) $ '00.99'     
				cNumOp := Alltrim(SC2->C2_OP)         	
			Endif
			DbSelectArea("SC2")
			DbSkip()        	
  		Enddo
    Endif
    //If Len(cNumOp) >0           	
       	aCabMov := {{"D3_TM"     , '110'        												  , NIL},;
           	        {"D3_EMISSAO", dDatabase    											   	  , NIL} }

    	aAuxMov := {{"D3_COD"     , Alltrim(cProduto)             								  , NIL},;
       	   			{"D3_QUANT"   , ABS(nSaldo)                   								  , NIL},;
       				{"D3_UM"      , Posicione("SB1", 1, xFilial("SB1")+Alltrim(cProduto), "B1_UM"), NIL},;
               	    {"D3_LOCAL"   , cLocal														  , NIL},; 
               	    {"D3_OBS"     , Iif(Empty(Alltrim(cNumOp)),Alltrim(cGetOrd),"")    	    	  , NIL},; 
               	    {"D3_DOC"     , NextNumero("SD3",2,"D3_DOC",.T.)  	 	 	 			      , NIL},; 
                   	{"D3_OP"      , Iif(!Empty(Alltrim(cNumOp)),"", Alltrim(cNumOp))              , NIL} }

       	aAdd(aIteAju, aAuxMov)
	
		lMsErroAuto := .f.
		MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteAju, 3)
	
		//Colocar um campo de controle no ZZA pra marcar o.ps que já tiveram saldo ajustado				
		If !lMsErroAuto
			cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_SP ='1', ZZA_PERDA ="+StrTran(TransForm(ABS(nSaldo), '@E 999999.999999'), ",", ".")+"  WHERE D_E_L_E_T_ ='' AND ZZA_FILIAL ='"+xFilial("ZZA")+"' AND ZZA_ORDEM = '"+Alltrim(cGetOrd)+"' "
			XXX := TCSQLExec(cQry1)
    		oBtnGSa:lVisible := .f.
            oBtnGSa:Refresh()		
			Messagebox("Saldo gerado com Sucesso!!","Atenção...",64) 		
		Else
			Mostraerro() 
		EndIf
	/*Else   // Caso a O.p esteja Encerrada
	   If MsgYesNo("O.p já foi encerrada.!! Deseja Marcar esta O.P como conferida ??", "Atenção")	
			cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_SP ='1', ZZA_PERDA ="+StrTran(TransForm(ABS(nSaldo), '@E 999,999.99999'), ",", ".")+"  WHERE D_E_L_E_T_ ='' AND ZZA_FILIAL ='"+xFilial("ZZA")+"' AND ZZA_ORDEM = '"+Alltrim(cGetOrd)+"' "
			XXX := TCSQLExec(cQry1)
    		oBtnGSa:lVisible := .f.
            oBtnGSa:Refresh()		
		Endif	   		
	Endif	*/
		
	DbSelectArea("SC2")
	DbCloseArea()

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Function  ³ fExcSaldo() - Exclusão de pequenos saldos que sobram durante
  							o apontamento de produção
 ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

User Function fExcSald(cProduto,nSaldo,cLocal)

	Local cQry1   :=""	
	Local aAuxMov := {}
	Local aCabMov := {}
	Local aIteAju := {}
	Local cNumOp  := ""
	Local nRecSal := Abs(nSaldo)
	Local lSoAtualiza   := .f.
	Local lOpAberta     := .f.
	Private lMsErroAuto := .f. //necessario a criacao

    If !lAcs6  
       	MsgBox("Usuário não possui acesso a essa a essa Rotina", "Atenção", "STOP")
      	Return
    Endif
    
    DbSelectArea("SC2")
    DbSetOrder(13)
    DbSeek(xFilial("SC2")+Alltrim(cGetLot), .t.)
    If Found() 
    	While !Eof() .and. (SC2->C2_FILIAL == xFilial("SC2")) .and. (SC2->C2_LOTE == Alltrim(cGetLot))
			If Len(Alltrim(SC2->C2_PRODUTO)) == 12 .and. Substr(SC2->C2_PRODUTO,11,2) $ '00.99'       
				cNumOp := Alltrim(SC2->C2_OP)         	
			Else
				If Empty(SC2->C2_DATRF)
					lOpAberta := .t.
				Endif
			Endif	
			DbSelectArea("SC2")
			DbSkip()        	
  		Enddo
    Endif
    If Len(cNumOp) >0         	
    	DBSelectArea("SB2")
    	DbSetOrder(1)
    	DbSeek(xFilial("SB2")+cProduto+cLocal, .t.)  //B2_FILIAL+B2_COD+B2_LOCAL                                                                                                                                       
    	If Found() .and. (SB2->B2_FILIAL == xFilial("SB2")) .and. (Alltrim(SB2->B2_COD) == Alltrim(cProduto))
       		//If SB2->B2_QATU < ABS(nSaldo) .and. ((ABS(nSaldo)- SB2->B2_QATU) < 5.4) .and. SB2->B2_QATU >0
			If (SB2->B2_QATU < ABS(nSaldo)) .and. (SB2->B2_QATU >0)
       			nSaldo := SB2->B2_QATU
			ElseIf SB2->B2_QATU = 0
				lSoAtualiza =.t.
			Endif
       	Endif
    	If lOpAberta  // Não permitir a exclusão de saldo para ops com apontamento em aberto
 	    	Msgbox("Atenção, existe O.P de P.A em aberto !! Encerre os apontamentos de P.A antes de excluir o saldo !!", "Verifique")	
       	    DBSelectArea("SB2")
    		DbCloseArea()
    		Return 
       	Else
       		If Substr(Alltrim(cProduto),11,2) $ '99' .and. Substr(Alltrim(cProduto),4,2) $ '97.98.99'
    	    	If !MsgYesNo("Este produto é também vendido a Granel, deseja realmente excluir o saldo deste produto?", "Atenção")	
			    	DBSelectArea("SB2")
			    	DbCloseArea() 
					Return
				Endif
			Endif       			
       	Endif
    	DBSelectArea("SB2")
    	DbCloseArea() 
       	If !lSoAtualiza 
       		aCabMov := {{"D3_TM"     , '600'        												  , NIL},;
           		        {"D3_EMISSAO", dDatabase    											   	  , NIL} }

    		aAuxMov := {{"D3_COD"     , Alltrim(cProduto)             								  , NIL},;
       	   				{"D3_QUANT"   , ABS(nSaldo)                   								  , NIL},;
       					{"D3_UM"      , Posicione("SB1", 1, xFilial("SB1")+Alltrim(cProduto), "B1_UM"), NIL},;
           	    	    {"D3_LOCAL"   , cLocal														  , NIL},; 
           	        	{"D3_OBS"     , Alltrim(cNumOp)                                               , NIL} }// -> Grava no número da o.p do Pa que gerou a exclusão do saldo
																										  // não é possível gravar no campo D3_OP pq a mesma já pode ter 
       		aAdd(aIteAju, aAuxMov)                                                                            // sido encerrada e neste caso a movimentação não ocorre.
//           	    	    {"D3_DOC"     , Alltrim(cGetLot)											  , NIL},; 

	
			lMsErroAuto := .f.
			MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteAju, 3)
	
			//Colocar um campo de controle no ZZA pra marcar o.ps que já tiveram saldo ajustado				
			If !lMsErroAuto
				cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_SP = '6', ZZA_SOBRA="+StrTran(TransForm(ABS(nRecSal), '@E 999999.99999'), ",", ".")+"  WHERE D_E_L_E_T_ ='' AND ZZA_FILIAL ='"+xFilial("ZZA")+"' AND ZZA_ORDEM = '"+Alltrim(cGetOrd)+"' "
				XXX := TCSQLExec(cQry1)		
		    	oBtnESa:lVisible := .f.
            	oBtnESa:Refresh()		
				Messagebox("Saldo excluído com Sucesso!!","Atenção...",64) 			
			Else
				Mostraerro() 
			EndIf
	    Else
			cQry1 := "UPDATE  "+RetSqlName("ZZA")+" SET ZZA_SP = '6', ZZA_SOBRA="+StrTran(TransForm(ABS(nRecSal), '@E 999999.999999'), ",", ".")+"  WHERE D_E_L_E_T_ ='' AND ZZA_FILIAL ='"+xFilial("ZZA")+"' AND ZZA_ORDEM = '"+Alltrim(cGetOrd)+"' "
			XXX := TCSQLExec(cQry1)		
	    	oBtnESa:lVisible := .f.
           	oBtnESa:Refresh()		
			Messagebox("Atualizada informações sobre a sobra de P.I para este lote!!","Atenção...",64) 			
		Endif		
	Endif	
		
	DbSelectArea("SC2")
	DbCloseArea()

Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTblOri() - Cria temporario para o Alias: ORI
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTblOri()

       Local aFds := {}
       //Local cTmp

       aAdd( aFds , {"ORI_COMP", "C", 015, 000} )
       aAdd( aFds , {"ORI_TRT" , "C", 003, 000} )
       aAdd( aFds , {"ORI_QTDE", "N", 009, 004} )
       
       If Chkfile("ORI")
	      DbSelectArea("ORI")
	      DbCloseArea()
	      If Type("oTempTbl08") == 'O'
	         oTempTbl08:Delete()
	      Endif
	   Endif		
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 06/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cTmp := CriaTrab( aFds, .T. )
       //Use (cTmp) Alias ORI New Exclusive
       //Index On ORI_TRT To (cTmp)
       oTempTbl08 := FWTemporaryTable():New( "ORI" )
       oTempTbl08:SetFields( aFds )
       oTempTbl08:AddIndex( "cInd01", { "ORI_TRT" } )
       oTempTbl08:Create()
       /********************************************************************************************************************************/

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTblApt() - Cria temporario para o Alias: APT
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function oTblApt()
       Local aFds := {}
       //Local cTmp

       aAdd( aFds , {"APT_COMP", "C", 015, 000} )
       aAdd( aFds , {"APT_TRT" , "C", 003, 000} )
       aAdd( aFds , {"APT_QTDE", "N", 009, 004} )
       aAdd( aFds , {"APT_LOCA", "C", 003, 000} )
       
       If Chkfile("APT")
	      DbSelectArea("APT")
	      DbCloseArea()
	      If Type("oTempTbl09") == "O"
	         oTempTbl09:Delete()
	      Endif
	   Endif
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 06/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cTmp := CriaTrab( aFds, .T. )
       //Use (cTmp) Alias APT New Exclusive
       //Index On APT_TRT To (cTmp)
       oTempTbl09 := FWTemporaryTable():New( "APT" )
       oTempTbl09:SetFields( aFds )
       oTempTbl09:AddIndex( "cInd01", { "APT_TRT" } )
       oTempTbl09:Create()
       /********************************************************************************************************************************/
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTblApt2() - Cria temporario para o Alias: APT2
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function oTblApt2()
       Local aFds := {}
       //Local cTmp

       aAdd( aFds , {"APT2_TPUSE", "C", 009, 000} )                  
       aAdd( aFds , {"APT2_SEQEN", "C", 002, 000} )
       aAdd( aFds , {"APT2_PROEN", "C", 012, 000} )
       aAdd( aFds , {"APT2_QUANT", "C", 004, 000} )
       aAdd( aFds , {"APT2_FILMA", "C", 006, 000} )
       aAdd( aFds , {"APT2_NOME" , "C", 025, 000} )
       
       If Chkfile("APT2")
	      DbSelectArea("APT2")
	      DbCloseArea()
	      If Type("oTempTbl10") == "O"
	         oTempTbl10:Delete()
	      Endif
	   Endif
       
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 06/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cTmp := CriaTrab( aFds, .T. )
       //Use (cTmp) Alias APT2 New Exclusive
       //Index On APT2_TPUSE To (cTmp)
       oTempTbl10 := FWTemporaryTable():New( "APT2" )
       oTempTbl10:SetFields( aFds )
       oTempTbl10:AddIndex( "cInd01", { "APT2_TPUSE" } )
       oTempTbl10:Create()
       /********************************************************************************************************************************/
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTblEnv() - Cria temporario para o Alias: ENV
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTblEnv()
       Local aFds := {}
       //Local cTmp

       aAdd( aFds , {"ENV_PROD"   , "C", 015, 000} )
       aAdd( aFds , {"ENV_DESCR"  , "C", 027, 000} )
       aAdd( aFds , {"ENV_QTDORI" , "N", 005, 000} )
       aAdd( aFds , {"ENV_QTDENT" , "N", 005, 000} )
       aAdd( aFds , {"ENV_DATRF"  , "C", 011, 000} )
       
       If Chkfile("_ENV")
	      DbSelectArea("_ENV")
	      DbCloseArea()
	      oTempTbl11:Delete()
	   Endif

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 06/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cTmp := CriaTrab( aFds, .T. )
       //Use (cTmp) Alias ENV New Exclusive
       //Index On ENV_PROD To (cTmp)
       oTempTbl11 := FWTemporaryTable():New( "_ENV" )
       oTempTbl11:SetFields( aFds )
       oTempTbl11:AddIndex( "cInd01", { "ENV_PROD" } )
       oTempTbl11:Create()
       /********************************************************************************************************************************/
Return

User Function PCPA01_L()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cGetLog    := Space(8)

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1", "oDlg1", "oSay1", "oGetLog", "oBtnCon")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1     := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1      := MSDialog():New( 088, 232, 133, 595, "Mostra Log de erro", , , .F., , , , , , .T., , , .T. )
     oSayLog    := TSay():New( 004, 004, {|| "Nome do Log:"                          }, oDlg1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 060, 012)
     oGetLog    := TGet():New( 004, 068, {|u| If(PCount() > 0, cGetLog := u, cGetLog)}, oDlg1, 060, 012, '@!', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "", "cGetLog", ,)
     oBtnCon    := TButton():New( 004, 136, "Confirma", oDlg1, { || MostraLog() }, 037, 012, , , , .T., , "", , , , .F. )
     oDlg1:Activate(, , , .T.)
Return

Static Function MostraLog()
       //Local cStartPath := GetSrvProfString("Startpath","")
       cNome := If(cGetLog = Nil, "", Alltrim(cGetLog))
       If !Empty(cNome)
          DEFINE FONT oFont NAME "Courier New" SIZE 5,0
          cNome += ".LOG"
          cMemo := MemoRead(cNome)
          DEFINE MSDIALOG oDlg TITLE cNome From 3,0 to 340,417 PIXEL
                 @ 5,5 GET oMemo  VAR cMemo MEMO SIZE 200,145 OF oDlg PIXEL
                 oMemo:bRClicked := {||AllwaysTrue()}
                 oMemo:oFont:=oFont

                 DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
                 //DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,OemToAnsi("Salvar Como...")),If(cFile="",.t.,MemoWrite(cFile,cMemo)),oDlg:End()) ENABLE OF oDlg PIXEL //Salva e Apaga
                 //DEFINE SBUTTON  FROM 153,115 TYPE 6 ACTION (PrintAErr(cNome),oDlg:End()) ENABLE OF oDlg PIXEL //Imprime e Apaga
          ACTIVATE MSDIALOG oDlg CENTER
       Else
          MsgStop("Digite um nome de arquivo para visualiza-lo")
       Endif
       cGetLog := space(08)
       oGetLog:Refresh()
       oGetLog:SetFocus()
Return

User Function PCPA01_F() // ESTORNA APONTAMENTO PA
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     //Local nOpc         := GD_INSERT+GD_DELETE+GD_UPDATE
     Private aCoBrwApt  := {}
     Private aCoBrwSc2  := {}
     Private aHoBrwApt  := {}
     Private aHoBrwSc2  := {}
     Private cGetLot    := ZZA->ZZA_LOTE
     Private cGetOrd    := Transform(ZZA->ZZA_ORDEM, "@R XXXXXX-99-999")
     Private cGetSta    := Iif(ZZA->ZZA_FLAG $ '6', 'APTO - INICIO', Iif(ZZA->ZZA_FLAG $ '7', 'APTO - PARCIAL', Iif(ZZA->ZZA_FLAG $ '8', 'APTO - TOTAL', Iif(ZZA->ZZA_FLAG $ '5', 'BAIXADA', 'ENCERRADA'))))
     Private cSayEst    := Space(1)
     Private cSayOrd    := Space(1)
     Private nbSelecao
     Private aSelecao   := Iif(ZZA->ZZA_FLAG $ '5.6.7.8', {'', 'APTO - INICIO'}, '')
     Private noBrwApt   := 0
     Private noBrwSc2   := 0
     Private oBrwSc2
     Private oBrwApt

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1"   , "oDlg1"  , "oSayOrd", "oSayEst", "oGetOrd", "oGetSta", "oGetLot", "oGrpTr1", "oGrp2", "oGrp3", "oGrp4")
     SetPrvt("cbSelecao", "cBtnCon", "oBtnSai", "oBrwSc2", "oBrwApt")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Verificação da Data Final do Apontamento em relação ao último fechamento±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
   	 
     If !lAcs5 
       	MsgBox("Usuário não possui acesso a essa a essa Rotina", "Atenção", "STOP")
       	Return
     Endif
     
     If !ZZA->ZZA_FLAG $ '5.6.7.8'
        MsgStop("Ordem de produção não pode ser estornada. Verifique!")
        Return
     Endif
     If !Empty(ZZA->ZZA_DTFIM)
        If !ZZA->ZZA_DTFIM > GETMV("MV_ULMES")
        	MsgStop("Ordem de produção não pode ser estornada - Data Fechamento superior. Verifique!")
            Return
        Endif
     Endif
     If Substr(ZZA->ZZA_PRODUT,11,2) $ '00.99' .and. Len(Alltrim(ZZA->ZZA_PRODUT)) == 12      // PEGAR SOMENTE O.P DE P.A
   	 	MsgStop("Ordem de produção escolhida não é P.A Tinta. Verifique!")
        Return
     Endif

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1     := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1      := MSDialog():New( 088, 232, 389, 860, "Estorno de OPs - PA", , , .F., , , , , , .T., , , .T. )
     oSayOrd    := TSay():New( 004, 012, {| | "Ordem de Produção:"}, oDlg1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 088, 009)
     oGetOrd    := TGet():New( 002, 100, {|u| If(PCount() > 0, cGetOrd := u, cGetOrd)}, oDlg1, 068, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .T., .F., "", "cGetOrd", , )
     oGetSta    := TGet():New( 002, 216, {|u| If(PCount() > 0, cGetSta := u, cGetSta)}, oDlg1, 084, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .T., .F., "", "cGetSta", , )
     oGetLot    := TGet():New( 002, 172, {|u| If(PCount() > 0, cGetLot := u, cGetLot)}, oDlg1, 036, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .T., .F., "", "cGetLot", , )
     oGrpTr1    := TGroup():New( 024, 004, 116, 156, "Original", oDlg1, CLR_BLACK, CLR_WHITE, .T., .F. )
     MHoBrwSc2()
     MCoBrwSc2()
     oBrwSc2    := MsNewGetDados():New(032, 008, 112, 152, 4, 'AllwaysTrue()', 'AllwaysTrue()', '', .f., 0, 99, 'AllwaysTrue()', '', 'AllwaysTrue()', oGrpTr1, aHoBrwSc2, aCoBrwSc2 )

     oGrp2      := TGroup():New( 024,160,116,312,"Apontamento",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
     MHoBrwApt()
     MCoBrwApt()
     oBrwApt    := MsNewGetDados():New(032, 164, 112, 308, 4, 'AllwaysTrue()', 'AllwaysTrue()', '', .f., 0, 99, 'AllwaysTrue()', '', 'AllwaysTrue()', oGrp2, aHoBrwApt, aCoBrwApt )

     oSayEst    := TSay():New( 132, 012, {||"Estornar para:"}, oDlg1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 064, 009)
     cbSelecao  := TComboBox():New( 131, 080, {|u| If(PCount() > 0, nbSelecao := u, nbSelecao)}, aSelecao, 100, 014, oDlg1, , , , CLR_BLACK, CLR_WHITE, .T., oFont1, "", , , , , , , nbSelecao )
     oGrp3      := TGroup():New( 017,000,021,316,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
     oGrp5      := TGroup():New( 120,000,124,317,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )

     cBtnCon    := TButton():New( 132,192,"Confirma", oDlg1, {|| fConEsPa()   }, 037,012,,,,.T.,,"",,,,.F. )
     oBtnSai    := TButton():New( 132, 244, "Sair"  , oDlg1, {|| oDlg1:End() }, 037, 012, , , , .T., , "", , , , .F. )

     oDlg1:Activate(, , , .T.)

Return

// Verificar se a rotina de baixa de O.P esta sendo executada por alguém
User Function fConBaiO()

Local cFlagRot := ""
Local lStatus    := .T.
	cFlagRot := Alltrim(GETMV('MV_BXMANEW'))
	/*
	DbUseArea(.t., __LocalDrive, 'SX6'+substr(cNumEmp,1,2)+'0', 'TSX6', .t., .f.)
	DbSelectArea("TSX6")
	DbSetOrder(1)

	DbSeek(Substr(cNumEmp,3,2)+'MV_BXMANEW')  
	If Found()
		cFlagRot := Alltrim(TSX6->X6_CONTEUD)
	Endif
	DbSelectArea("TSX6")
	DbCloseArea()
	*/
	If Empty(cFlagRot)
		lStatus :=.f.
	Endif

Return(lStatus)

Static Function fConEsPa()     // ESTORNO DE PRODUTOS ACABADOS
       
       Local aEstSD3P := {}
       //Local aOpeEst  := {}
       Local aIteMov  := {}
       Local aAuxMov  := {}
       //Local lTemMovAnt := .f.
       Local cDoc     := ""
       //Local cFlagRot := ""
       //Local cAuxQbr  := ""
	   //Local cQbr1Tx  := ""
	   //Local cQbr2Tx  := ""
	   //Local cQbr3Tx  := ""
	   //Local cQbr4Tx  := ""
       //Local cMsgTel  := ""
       Local cOpPa    := Alltrim(ZZA->ZZA_ORDEM)
       Local cOpPi    := ""
	   //Local aCampos    := {} 
	   Local aBloq := {}
	   Local cArqBloq, nX
	   Local _cAreaBloq := ""


       Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
 	   Private lMsErroAuto := .f. //necessario a criacao
       
       If Empty(nbSelecao)
          MsgStop("Selecione uma opção para estorno.")
       Else
          // Verificar se a rotina esta sendo executada por alguém
		  //cFlagRot := ALLTRIM(GETMV('MV_BXMANEW'))
          //If Empty(cFlagRot)
			          
    		//cArqBloq := "SCHP"+Substr(ALLTRIM(CNumEmp),3,6)+".DTC"
    		cArqBloq := "BRPCPA01"+Substr(ALLTRIM(CNumEmp),3,6)
	   		aBloq := U_BloqProg(cArqBloq) //Retorna matriz com primeira coluna verdadeiro ou falso se tá bloqueado e segunda coluna com nome de quem está bloqueando ou nome da área de trabalho gerada
   			if aBloq[1,1] //Já estava bloqueado?
   				cAux := "O programa de baixa de ops já está sendo executado !! Aguarde !! -> "+aBloq[1,2]
				Messagebox(cAux,"Atenção...",64) 			
				return
			endif 
			_cAreaBloq := aBloq[1,4]

          	  If nbSelecao $ 'APTO - INICIO'
   			     Begin Transaction

		          	PutMv("MV_BXMANEW", "N"+"|"+Alltrim(cUserName)+"|"+Time()+"|"+Dtoc(MsDate()) )
	    	        PutMv("MV_ESTNEG" , "N")
          	  		cQry := ""
   					cQry += " SELECT H6_OP, H6_OBSERVA, H6_PRODUTO, H6_OPERAC, H6_RECURSO "
   					cQry += " FROM "+RetSqlName("SH6")+" SH6 WITH(NOLOCK)"
   					cQry += " WHERE SH6.H6_FILIAL  = '"+xFilial("SH6")+"' "
   					cQry += " AND SH6.H6_OP  = '"+ZZA->ZZA_ORDEM+"' "
					cQry += " AND D_E_L_E_T_ = '' "     						
    				cQry += "ORDER BY SH6.H6_OBSERVA DESC "
    				TCQuery cQry ALIAS "TCQ1" NEW
                    While !Eof()
                    	If !Empty(TCQ1->H6_OPERAC) //VERIFICA SE EXISTE OPERAÇÃO CADASTRADA PARA ESSE PRODUTO
                    		aOpeBai := {}
                    		aAdd(aOpeBai, {"H6_OP"     , SubStr(ZZA->ZZA_ORDEM+space(10), 1, 14), Nil } )
                    		aAdd(aOpeBai, {"H6_PRODUTO", ZZA->ZZA_PRODUT                        , Nil } )
                    		aAdd(aOpeBai, {"H6_OPERAC" , TCQ1->H6_OPERAC                        , Nil } )
                    		aAdd(aOpeBai, {"H6_RECURSO", TCQ1->H6_RECURSO                       , Nil } )

                    		lMsErroAuto := .f.
                    		DbSelectArea("SF5")
                    		MSFILTER('')
                    		DbSelectArea("SF5")
                    		DbSetOrder(1)
                    		DbSelectArea("SH6")
                    		MsExecAuto( {|x, y| Mata681(x, y)}, aOpeBai, 5)
                    		If lMsErroAuto
                       			MsgBox("Operação não pode ser estornada.", "ATENÇÃO")
                       			MostraErro()
                       			DisarmTransaction() 
			          	        PutMv("MV_BXMANEW", "")   
			          	        PutMv("ZP_PAR0015", "")   
			          	        /*
			          	        IF !empty(_cAreaBloq) .and. Select(_cAreaBloq) <> 0
									DbSelectArea(_cAreaBloq)
									DbCloseArea()
									//FErase(cArqBloq)
								ENDIF 
								*/           
                       			//Return() //LGS#20200206 - Adequação de release 12.1.25 e posteriores - Não pode usar return dentro de Begin Transaction
                    		Endif
                    	Else
                       		MsgBox("Não foi possível estornar, ordem de produção baixada sem Operação definida. Estorne pelo Apontamento de Produção PCP", "ATENÇÃO")
                      	Endif
                      	DbSelectArea("TCQ1")
                      	DbSkip()
					Enddo
		            DbSelectArea("TCQ1")
		            DbCloseArea()
                 	
                	If ZZA->ZZA_FLAG $ '5.6.7.8' 
                    	aEstSD3P := {}
                   	 	
                   	 	DbSelectArea("ZZA")	
						ZZA->(dbSetOrder(3)) // ZZA_FILIAL, ZZA_LOTE
						ZZA->(dbSeek(xFilial("ZZA")+Alltrim(cGetLot)))
						While !(ZZA->(eof())) .and. (ZZA->ZZA_FILIAL == xFilial("ZZA")) .and. (ZZA->ZZA_LOTE== Alltrim(cGetLot))
							If SUBSTR(ZZA->ZZA_PRODUT,11,2) $ '00.99'
						 		cOpPi:=Alltrim(ZZA->ZZA_ORDEM)
						 	EndIf
						 	ZZA->(dbSkip())
						EndDo
                            

                    	/*cQry1 += " SELECT SUBSTRING(ZZA_ORDEM,1,11) AS ZZA_ORDEM, D3_TM, D3_DOC, D3_EMISSAO"
                    	cQry1 += " FROM "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) " 
                    	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SD3")+" SD3 WITH (NOLOCK) ON ZZA_FILIAL = D3_FILIAL AND ZZA_ORDEM = D3_OP  AND SD3.D_E_L_E_T_  =''  "
                    	cQry1 += " WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
                    	cQry1 += "  AND ZZA.D_E_L_E_T_ = '' "  
                    	cQry1 += "  AND SUBSTRING(SD3.D3_DOC,1,6) <> '"+Substr(ZZA->ZZA_ORDEM,1,6)+"' "
                    	cQry1 += "  AND ZZA.ZZA_ORDEM = '"+ZZA->ZZA_ORDEM+"' "
                    	cQry1 += "  AND ZZA.ZZA_PROSOB <> ''  "
                    	cQry1 += "  AND SD3.D3_ESTORNO <> 'S' "
                    	cQry1 += " GROUP BY ZZA_ORDEM, D3_TM, D3_DOC, D3_EMISSAO " */
				      	If !Empty(Alltrim(cOpPi))
					      	cQry1 := " "
    	                	cQry1 += " SELECT D3_FILIAL, D3_DOC, D3_TM, D3_EMISSAO, D3_OBS, D3_COD  FROM "+RetSqlName("SD3")+" WITH (NOLOCK) " 
        	            	cQry1 += " WHERE (D3_OP ='"+Alltrim(cOpPi)+"' OR D3_OBS ='"+Alltrim(cOpPi)+"')"
            	        	cQry1 += " AND D_E_L_E_T_ ='' AND D3_ESTORNO <>'S' " 
                	    	cQry1 += " AND D3_FILIAL ='"+xFilial("SD3")+"'"
                    		cQry1 += " AND D3_ESTORNO <>'S' AND D3_TM IN('100','110','600') "
                    		TCQuery cQry1 ALIAS "ETMP" NEW
                    
	                    	DbSelectArea("ETMP")
    	                	While !Eof() .and. (XFilial("SD3")== ETMP->D3_FILIAL) 
        	                    aAdd(aEstSD3P, {'', ETMP->D3_DOC, ETMP->D3_TM, ETMP->D3_EMISSAO, ETMP->D3_COD  })
            	              	DbSelectArea("ETMP")
                	          	DbSkip()
                    		Enddo
                    		DbSelectArea("ETMP")
	                    	DbCloseArea()
    	                	//Voltar itens baixados - SD3 ESTORNO POR DOCUMENTO
        	            	aIteMov := {}
            				aAuxMov := {}
                	    	For nX := 1 To Len(aEstSD3P) 
                    	   		If Alltrim(cDoc) <> Alltrim(aEstSD3P[nX][2])
                       				DbSelectArea("SD3") 
									DbSetOrder(2) 
	                            	DbSeek(xFilial("SD3")+aEstSD3P[nX][2]+aEstSD3P[nX][5], .t.)  // D3_FILIAL+D3_DOC+D3_COD    
            	                	If !Eof() .and. (SD3->D3_FILIAL == XFilial("SD3")) .and. (Alltrim(SD3->D3_DOC)== Alltrim(aEstSD3P[nX][2])) .and. (Alltrim(SD3->D3_COD) == Alltrim(aEstSD3P[nX][5]))
        	                       		cDoc := aEstSD3P[nX][2]
                	            		aCabMov := { {"D3_DOC"     ,aEstSD3P[nX][2]    , NIL},;   // DOC      2
                    	        				 	 {"D3_TM"     , aEstSD3P[nX][3]    , NIL},;   // TIPO M   3
                        	    				  	 {"D3_EMISSAO", aEstSD3P[nX][4]    , NIL} }   // EMISSAO  4
                            	
                        				aAuxMov := { {"D3_TM"    ,  aEstSD3P[nX][3]    , NIL},;   // TIPO M   3
                       							 	 {"D3_OP"     , aEstSD3P[nX][1]    , NIL},;   // OP       1
                               		   			 	 {"D3_ESTORNO", "S"                , NIL},;   // ESTORNO
                           	      				 	 {"D3_TURNO"  , "EFP"              , NIL} }

	                      				aAdd(aIteMov, aAuxMov)
    	                        		lMsErroAuto := .f.
                          
        	                    		MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteMov, 6)
                            		
            	                		If lMsErroAuto
            	                		    //LGS#20200206 - Adequação de release 12.1.25 e posteriores		
											//ConOut("Erro no estorno! DOC "+aEstSD3P[nX][2])
											FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "Erro no estorno! DOC "+aEstSD3P[nX][2], 0 )
        		    	              		MostraErro()
						          	        /*
						          	        IF !empty(_cAreaBloq) .and. Select(_cAreaBloq) <> 0
												DbSelectArea(_cAreaBloq)
												DbCloseArea()
												//FErase(cArqBloq)
											ENDIF 
		                	          		*/
		                	          		//Return() //LGS#20200206 - Adequação de release 12.1.25 e posteriores - Não pode usar return dentro de Begin Transaction
										EndIf	
                            		Endif	
	                       		Endif
    	               		Next
	                    	DbSelectArea("SD3")
    	                	DbClosearea()
	                 	Endif 
	                	DbSelectArea("SC2")
    					DbCloseArea()
        			Endif 
              	 	   
              	 	DbSelectArea("ZZA") 
   				 	DbSetOrder(3) 
                 	DbSeek(xFilial("ZZA")+Alltrim(cGetLot), .t.)  // filial + lote
                 	While !Eof() .and. (xFilial("ZZA")== ZZA->ZZA_FILIAL) .and. (Alltrim(cGetLot) == Alltrim(ZZA->ZZA_LOTE))
                 		If (Alltrim(ZZA->ZZA_ORDEM) == Alltrim(cOpPa))
	            			cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET D_E_L_E_T_ = '*', ZZA_HELP ='' , ZZA_CAMPO =SUBSTRING(ZZA_HELP, 1, 2)+' - Estornado em "+Dtoc(dDataBase)+" às "+Time()+ "' WHERE ZZA_FILIAL ='"+xFilial("ZZA")+"' AND D_E_L_E_T_ = '' AND ZZA_ORDEM = '"+Alltrim(ZZA->ZZA_ORDEM)+"'"
							XXX := TCSQLEXEC(cQry1)
        	    		    If XXX <> 0
            	        		cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                	       	 	MemoWrit(cNomArq, cQry1)
                  			Endif
	              	 	ElseIF SUBSTR(ZZA->ZZA_PRODUT,11,2) $ '00.99'
	            			cQry1 := "UPDATE "+RetSqlName("ZZA")+" SET ZZA_SP = '', ZZA_PERDA =0, ZZA_SOBRA =0  WHERE ZZA_FILIAL ='"+xFilial("ZZA")+"' AND D_E_L_E_T_ = '' AND ZZA_ORDEM = '"+Alltrim(ZZA->ZZA_ORDEM)+"'"
							XXX := TCSQLEXEC(cQry1)
        	    		    If XXX <> 0
            	        		cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                	       	 	MemoWrit(cNomArq, cQry1)
                  			Endif
                  		Endif 
                 		DbSelectArea("ZZA")
                 		DbSkip()
                 	Enddo
                 	DbSelectArea("ZZA")
                 	DbCloseArea() 
                 	
               //     PutMv("MV_ESTNEG", "N")                 
          	        PutMv("MV_BXMANEW", "")                 
          	        PutMv("ZP_PAR0015", "") 
          	        /*
          	        IF !empty(_cAreaBloq) .and. Select(_cAreaBloq) <> 0
						DbSelectArea(_cAreaBloq)
						DbCloseArea()
						//FErase(cArqBloq)
					ENDIF 
					*/
				End Transaction

               	Messagebox("Ordem de Produção Estornada com Sucesso !!","Atenção...",64) 			
				oDlg1:End()
          	 Endif
          
          /*
          
          Else
   		     cAuxQbr := cFlagRot
         	 cQbr1Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1) )
         	 cAuxQbr := Stuff(cAuxQbr, 1, At("|", cAuxQbr), "" )
         	 cQbr2Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1) )
         	 cAuxQbr := Stuff(cAuxQbr, 1, At("|", cAuxQbr), "" )
         	 cQbr3Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1) )
         	 cAuxQbr := Stuff(cAuxQbr, 1, At("|", cAuxQbr), "" )
         	 cQbr4Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1)  )
         	 cMsgTel := "A baixa de O.ps esta em uso por: "+cQbr2Tx+", desde às: "+cQbr3Tx+" do dia "+cQbr4Tx+". Aguarde o término para estornar a O.P !!!"

         	 MsgStop(cMsgTel)
         	 If Hrs2Min( time() ) - Hrs2Min( SubStr( cFlagRot, 2 + At( "|", SubStr( cFlagRot, 3) ) + 1 ) ) >= 20 .or. Hrs2Min( time() ) - Hrs2Min( SubStr( cFlagRot, 2 + At( "|", SubStr( cFlagRot, 3) ) + 1 ) ) < 0
         	 	PutMv("MV_BXMANEW", "")
         	 Endif
     	  Endif */
	   Endif
IF !empty(_cAreaBloq) .and. Select(_cAreaBloq) <> 0
	DbSelectArea(_cAreaBloq)
    DBRUnlock( aBloq[1,3]) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
	DbCloseArea()
	//FErase(cArqBloq)
ENDIF
 
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrwSc2 ) - Monta aHeader da MsNewGetDados para o Alias: TMP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrwSc2()
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 06/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SC2")
       While !Eof() .and. SX3->X3_ARQUIVO == "SC2"
       		If AllTrim(SX3->X3_CAMPO) $ "C2_PRODUTO"
            	noBrwSc2++
                Aadd(aHoBrwSc2, { Trim(( _cAliasSX3 )->( X3_TITULO )), "C2_PRODUTO", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
            ElseIf AllTrim(SX3->X3_CAMPO) $ "C2_QUANT"
            	noBrwSc2++
                Aadd(aHoBrwSc2, { Trim(( _cAliasSX3 )->( X3_TITULO )), "C2_QUANT", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
            ElseIf AllTrim(SX3->X3_CAMPO) $ "C2_QUJE"
                noBrwSc2++
               Aadd(aHoBrwSc2, { Trim(( _cAliasSX3 )->( X3_TITULO )), "C2_QUJE", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
            EndIf
       		DbSkip()
       EndDo */
       DbSelectArea(_cAliasSX3)
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("SC2") )
       While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SC2"
       		If AllTrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "C2_PRODUTO"
            	noBrwSc2++
                Aadd( aHoBrwSc2, { ( _cAliasSX3 )->( X3_Titulo ), "C2_PRODUTO", ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
            ElseIf AllTrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "C2_QUANT"
            	noBrwSc2++
                Aadd( aHoBrwSc2, { ( _cAliasSX3 )->( X3_Titulo ), "C2_QUANT"  , ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
            ElseIf AllTrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "C2_QUJE"
                noBrwSc2++
                Aadd( aHoBrwSc2, { ( _cAliasSX3 )->( X3_Titulo ), "C2_QUJE"   , ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
            EndIf
       		DbSkip()
       EndDo
       /********************************************************************************************************************************/
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrwSc2() - Monta aCols da MsNewGetDados para o Alias: TMP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrwSc2()
       Local nI
       //Local aAux    := {}
       Local cQry    := ""

       cQry += "SELECT SC2.C2_PRODUTO, SC2.C2_QUANT, SC2.C2_QUJE "
       cQry += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
       cQry += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
       cQry += "  AND SC2.D_E_L_E_T_ = '' "
       cQry += "  AND SC2.C2_OP = '"+ZZA->ZZA_ORDEM+"' "
       cQry += "ORDER BY SC2.C2_OP, SC2.C2_PRODUTO "
       TCQuery cQry ALIAS "TCQ" New
       DbSelectArea("TCQ")
       While !Eof()
             Aadd(aCoBrwSc2, Array(noBrwSc2+1))
             For nI := 1 To noBrwSc2
                 If Alltrim(aHoBrwSc2[nI][2]) $ 'C2_PRODUTO'
                    aCoBrwSc2[Len(aCoBrwSc2)][nI] := CriaVar('C2_PRODUTO')
                    aCoBrwSc2[Len(aCoBrwSc2)][nI] := TCQ->C2_PRODUTO
                 ElseIf Alltrim(aHoBrwSc2[nI][2]) $ 'C2_QUANT'
                    aCoBrwSc2[Len(aCoBrwSc2)][nI] := CriaVar('C2_QUANT')
                    aCoBrwSc2[Len(aCoBrwSc2)][nI] := TCQ->C2_QUANT
                 ElseIf Alltrim(aHoBrwSc2[nI][2]) $ 'C2_QUJE'
                    aCoBrwSc2[Len(aCoBrwSc2)][nI] := CriaVar('C2_QUJE')
                    aCoBrwSc2[Len(aCoBrwSc2)][nI] := TCQ->C2_QUJE
                 Endif
             Next
             aCoBrwSc2[Len(aCoBrwSc2)][noBrwSc2+1] := .F.
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       If Len(aCoBrwSc2) <= 0
          Aadd(aCoBrwSc2, Array(noBrwSc2+1))
          For nI := 1 To noBrwSc2
              If Alltrim(aHoBrwSc2[nI][2]) $ 'C2_PRODUTO'
                  aCoBrwSc2[1][nI] := CriaVar('C2_PRODUTO')
              ElseIf Alltrim(aHoBrwSc2[nI][2]) $ 'C2_QUANT'
                  aCoBrwSc2[1][nI] := CriaVar('C2_QUANT')
              ElseIf Alltrim(aHoBrwSc2[nI][2]) $ 'C2_QUJE'
                  aCoBrwSc2[1][nI] := CriaVar('C2_QUJE')
              Endif
          Next
          aCoBrwSc2[1][noBrwSc2+1] := .F.
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fGSaldPI( Gera Saldo PI Automaticamente() Abril/2014
	Em cima de uma percentual específicado via parametro, esta função gera o saldo
	faltante nas baixas de ordens de produção para agilizar as baixas.
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
User Function fGSaldPI

Local cQry := ""
Local cTipoPro:=""
Local cProduto:="" 
Local cLocal  :=""

Local nQtdVol :=0
Local nVolSC2 :=0
Local nVolZZA :=0
Local nQtdConv:=0

	cQry += " SELECT SC2.C2_LOTE,SC2.C2_PRODUTO, B1_DESC, SC2.C2_LOCAL "
	cQry += " FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
	cQry += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON SC2.C2_FILIAL = SB1.B1_FILIAL AND SC2.C2_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
	cQry += " LEFT OUTER JOIN "+RetSqlName("ZZA")+" ZZA WITH(NOLOCK) ON ZZA.ZZA_FILIAL = SC2.C2_FILIAL AND ZZA.ZZA_LOTE = SC2.C2_LOTE AND ZZA.D_E_L_E_T_ =''  "
	cQry += " WHERE SC2.C2_FILIAL = '"+xFilial("SC2")+"' " 
	cQry += " AND SB1.B1_TIPO = 'PA' " 
	cQry += " AND SC2.D_E_L_E_T_ = '' "
	cQry += " AND ZZA.ZZA_FLAG   IN('7', '8', '9', 'E') "
	cQry += " AND ZZA.ZZA_DTFIM  <= '20140403' "
	cQry += " AND SC2.C2_DATRF ='' "
	cQry += " GROUP BY C2_LOTE, SC2.C2_PRODUTO, B1_DESC, SC2.C2_LOCAL "
	cQry += " ORDER BY SC2.C2_LOTE "
	TCQuery cQry ALIAS "TCQ" New
    
    DbSelectArea("TCQ")
    DbGotop()
    While !Eof()
   	    nQtdVol := 0
    	nVolSC2 := 0
    	nVolZZA := 0
    	
    	DbSelectArea("ZZA")
    	DbSetOrder(3)
    	DbSeek(xFilial("ZZA")+Alltrim(TCQ->C2_LOTE), .t.)
    	If Found()
    		While !Eof() .and. (ZZA->ZZA_LOTE == Alltrim(TCQ->C2_LOTE))
	    		nQtdConv := Posicione("SB1", 1, xFilial("SB1")+ZZA->ZZA_PRODUT, "B1_CONV")
	        	cTipoPro := Posicione("SB1", 1, xFilial("SB1")+ZZA->ZZA_PRODUT, "B1_TIPO") 
		        If cTipoPro == 'PI' 
    		       	cProduto := ZZA->ZZA_PRODUT
    		       	nVolSC2  := Posicione("SC2", 1, xFilial("SC2")+ZZA->ZZA_ORDEM, "C2_QUJE")
    		       	cLocal   := Iif(SubStr(ZZA->ZZA_HELP, 1, 1) $ '1', '02', '20')
    	    	   	If !Empty(ZZA->ZZA_HFIM) .and. ZZA->ZZA_FLAG $ '5'
	     		   		nVolZZA := ZZA->ZZA_QUANT
    	           		If lOpAjut =.f.
 			       			lOpAjut = Iif(!Empty(ZZA->ZZA_SP),.t.,.f.)
        		   		Endif
             		Else
	               		nVolZZA  := 0
    	           		cZZACampo:= ZZA->ZZA_CAMPO
        	     	Endif
            	Elseif cTipoPro == 'PA' .and. !(ZZA->ZZA_FLAG) $ '6.9.X'
	            	nQtdVol += (ZZA->ZZA_QUANT * nQtdConv)
    	            lExistApt := .t.
        	    Endif

	        	DbSelectArea("ZZA")
		        DbSkip()

	        Enddo

	    	DbSelectArea("ZZA")
    		DbClosearea()

			nSaldo := (Iif(nVolSC2 > 0, nVolSC2, nVolZZA)-nQtdVol)
       		
       		If nSaldo >0
	       		If lExistApt 
    	   			If Iif(nVolSC2 > 0, nVolSC2, nVolZZA) < nQtdVol // Faltando Saldo PI
	    	    		If nVolZZA > 0
   				  			u_fGeraSal(cProduto,nSaldo,cLocal)
						Endif	
					Endif	
        		Endif
            Endif

		Endif
    	

		DbSelectArea("TCQ")
		DbSkip()
    Enddo    
 	DbSelectArea("TCQ")
   	DbClosearea()

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrwApt() - Monta aHeader da MsNewGetDados para o Alias: TRB
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrwApt()
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 06/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("ZZA")
       While !Eof() .and. SX3->X3_ARQUIVO == "ZZA"
             If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
                If AllTrim(SX3->X3_CAMPO) $ "ZZA_PRODUT"
                	noBrwApt++
                   	Aadd(aHoBrwApt, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZA_PRODUT", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
                ElseIf AllTrim(SX3->X3_CAMPO) $ "ZZF_FLAG"
                    noBrwApt++
                    Aadd(aHoBrwApt, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZA_FLAG", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
                ElseIf AllTrim(SX3->X3_CAMPO) $ "ZZA_QUANT"
                    noBrwApt++
                    Aadd(aHoBrwApt, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZA_QUANT", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
                ElseIf AllTrim(SX3->X3_CAMPO) $ "ZZA_SEQENV"
                    noBrwApt++
                    Aadd(aHoBrwApt, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZA_SEQENV", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
                EndIf
             EndIf
             DbSkip()
       EndDo*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("ZZA") )
       While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "ZZA"
             If X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL )
                If AllTrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZZA_PRODUT"
                	noBrwApt++
                   	Aadd( aHoBrwApt, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZA_PRODUT", ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
                ElseIf AllTrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZZF_FLAG"
                    noBrwApt++
                    Aadd( aHoBrwApt, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZA_FLAG"  , ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
                ElseIf AllTrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZZA_QUANT"
                    noBrwApt++
                    Aadd( aHoBrwApt, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZA_QUANT" , ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
                ElseIf AllTrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZZA_SEQENV"
                    noBrwApt++
                    Aadd( aHoBrwApt, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZA_SEQENV", ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
                EndIf
             EndIf
             DbSkip()
       EndDo
       /********************************************************************************************************************************/
Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrwApt() - Monta aCols da MsNewGetDados para o Alias: TRB
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrwApt()
       //Local aAux := {}
       Local cQry := ""
       Local nI
       cQry += "SELECT ZZA.ZZA_PRODUT, ZZA.ZZA_FLAG, ZZA.ZZA_QUANT, ZZA.ZZA_SEQENV "
       cQry += "FROM "+RetSqlName("ZZA")+" ZZA WITH (NOLOCK) "
       cQry += "WHERE ZZA.ZZA_FILIAL = '"+xFilial("ZZA")+"' "
       cQry += "  AND ZZA.D_E_L_E_T_ = '' "
       cQry += "  AND ZZA.ZZA_ORDEM  = '"+ZZA->ZZA_ORDEM+"' "
       cQry += "ORDER BY ZZA.ZZA_PRODUT, ZZA.ZZA_SEQENV "
       TCQuery cQry ALIAS "TCQ" New
       DbSelectArea("TCQ")
       While !Eof()
             Aadd(aCoBrwApt, Array(noBrwApt+1))
             For nI := 1 To noBrwApt
                 If Alltrim(aHoBrwApt[nI][2]) $ 'ZZA_PRODUT'
                    aCoBrwApt[Len(aCoBrwApt)][nI] := CriaVar('ZZA_PRODUT')
                    aCoBrwApt[Len(aCoBrwApt)][nI] := TCQ->ZZA_PRODUT
                 ElseIf Alltrim(aHoBrwApt[nI][2]) $ 'ZZA_FLAG'
                    aCoBrwApt[Len(aCoBrwApt)][nI] := CriaVar('ZZA_FLAG')
                    aCoBrwApt[Len(aCoBrwApt)][nI] := TCQ->ZZA_FLAG
                 ElseIf Alltrim(aHoBrwApt[nI][2]) $ 'ZZA_QUANT'
                     aCoBrwApt[Len(aCoBrwApt)][nI] := CriaVar('ZZA_QUANT')
                     aCoBrwApt[Len(aCoBrwApt)][nI] := TCQ->ZZA_QUANT
                 ElseIf Alltrim(aHoBrwApt[nI][2]) $ 'ZZA_SEQENV'
                     aCoBrwApt[Len(aCoBrwApt)][nI] := CriaVar('ZZA_SEQENV')
                     aCoBrwApt[Len(aCoBrwApt)][nI] := TCQ->ZZA_SEQENV
                 Endif
             Next
             aCoBrwApt[Len(aCoBrwApt)][noBrwApt+1] := .F.
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       If Len(aCoBrwApt) <= 0
          Aadd(aCoBrwApt, Array(noBrwApt+1))
          For nI := 1 To noBrwApt
              If Alltrim(aHoBrwApt[nI][2]) $ 'ZZA_PRODUT'
                 aCoBrwApt[1][nI] := CriaVar('ZZA_PRODUT')
              ElseIf Alltrim(aHoBrwApt[nI][2]) $ 'ZZA_FLAG'
                     aCoBrwApt[1][nI] := CriaVar('ZZA_FLAG')
              ElseIf Alltrim(aHoBrwApt[nI][2]) $ 'ZZA_QUANT'
                     aCoBrwApt[1][nI] := CriaVar('ZZA_QUANT')
              Endif
          Next
          aCoBrwApt[1][noBrwApt+1] := .F.
       Endif
Return

User Function PCPA01_E()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     //Local nOpc         := GD_INSERT+GD_DELETE+GD_UPDATE
     //Private lAcs3      := .f. // Estorna P.I
     Private aCoBrwBai  := {}
     Private aCoBrwOri  := {}
     Private aHoBrwBai  := {}
     Private aHoBrwOri  := {}
     Private cGetLot    := ZZA->ZZA_LOTE
     Private cGetOrd    := Transform(ZZA->ZZA_ORDEM, "@R XXXXXX-99-999")
     Private cGetSta    := Iif(ZZA->ZZA_FLAG $ '1', 'PESAGEM - INICIO', Iif(ZZA->ZZA_FLAG $ '2', 'PESAGEM - FIM', Iif(ZZA->ZZA_FLAG $ '3', 'COLORISTA', Iif(ZZA->ZZA_FLAG $ '4', 'LABORATORIO', Iif(ZZA->ZZA_FLAG $ '5', 'BAIXADA', 'ENCERRADA')))))
     Private cSayEst    := Space(1)
     Private cSayOrd    := Space(1)
     Private nbSelecao
     //Private aSelecao   := Iif(ZZA->ZZA_FLAG $ '1', {'', 'CANCELA BAIXAS'}, Iif(ZZA->ZZA_FLAG $ '2', {'', 'CANCELA BAIXAS', 'PESAGEM - INICIO'}, Iif(ZZA->ZZA_FLAG $ '3', {'', 'CANCELA BAIXAS', 'PESAGEM - INICIO', 'PESAGEM - FIM'}, Iif(ZZA->ZZA_FLAG $ '4', {'', 'CANCELA BAIXAS', 'PESAGEM - INICIO', 'PESAGEM - FIM', 'COLORISTA'}, Iif(ZZA->ZZA_FLAG $ '5', {'', 'CANCELA BAIXAS', 'PESAGEM - INICIO', 'PESAGEM - FIM', 'COLORISTA', 'LABORATORIO'}, {'', 'CANCELA BAIXAS', 'PESAGEM - INICIO', 'PESAGEM - FIM', 'COLORISTA', 'LABORATORIO'})))))
     Private aSelecao   := Iif(ZZA->ZZA_FLAG $ '1.2.3.4.5', {'', 'CANCELA BAIXAS'}, '')
     Private noBrwBai   := 0
     Private noBrwOri   := 0
     Private oBrwOri
     Private oBrwBai

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1"   , "oDlg1"  , "oSayOrd", "oSayEst", "oGetOrd", "oGetSta", "oGetLot", "oGrpTr1", "oGrp2", "oGrp3", "oGrp4")
     SetPrvt("cbSelecao", "cBtnCon", "oBtnSai", "oBrwOri", "oBrwBai")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Verificação da Data Final do Apontamento em relação ao último fechamento±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
   	 
     If !lAcs3
       	MsgBox("Usuário não possui acesso a essa a essa Rotina", "Atenção", "STOP")
       	Return
     Endif
     
     If !ZZA->ZZA_FLAG $ '1.2.3.4.5.P'
        MsgStop("Ordem de produção não pode ser estornada. Verifique!")
        Return
     Endif
     If !Empty(ZZA->ZZA_DTFIM)
        If !ZZA->ZZA_DTFIM > GETMV("MV_ULMES")
        	MsgStop("Ordem de produção não pode ser estornada - Data Fechamento superior. Verifique!")
            Return
        Endif
     Endif
     If !Substr(ZZA->ZZA_PRODUT,11,2) $ '00.99' .and. Len(Alltrim(ZZA->ZZA_PRODUT)) == 12      // PEGAR SOMENTE O.P DE P.I
   	 	MsgStop("Ordem de produção escolhida não é P.I Tinta. Verifique!")
        Return
     Endif

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1     := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1      := MSDialog():New( 088, 232, 389, 860, "Estorno de OPs - PI", , , .F., , , , , , .T., , , .T. )
     oSayOrd    := TSay():New( 004, 012, {| | "Ordem de Produção:"}, oDlg1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 088, 009)
     oGetOrd    := TGet():New( 002, 100, {|u| If(PCount() > 0, cGetOrd := u, cGetOrd)}, oDlg1, 068, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .T., .F., "", "cGetOrd", , )
     oGetSta    := TGet():New( 002, 216, {|u| If(PCount() > 0, cGetSta := u, cGetSta)}, oDlg1, 084, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .T., .F., "", "cGetSta", , )
     oGetLot    := TGet():New( 002, 172, {|u| If(PCount() > 0, cGetLot := u, cGetLot)}, oDlg1, 036, 012, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .T., .F., "", "cGetLot", , )
     oGrpTr1    := TGroup():New( 024, 004, 116, 156, "Original", oDlg1, CLR_BLACK, CLR_WHITE, .T., .F. )
     MHoBrwOri()
     MCoBrwOri()
     oBrwOri    := MsNewGetDados():New(032, 008, 112, 152, 4, 'AllwaysTrue()', 'AllwaysTrue()', '', .f., 0, 99, 'AllwaysTrue()', '', 'AllwaysTrue()', oGrpTr1, aHoBrwOri, aCoBrwOri )

     oGrp2      := TGroup():New( 024,160,116,312,"Baixada",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
     MHoBrwBai()
     MCoBrwBai()
     oBrwBai    := MsNewGetDados():New(032, 164, 112, 308, 4, 'AllwaysTrue()', 'AllwaysTrue()', '', .f., 0, 99, 'AllwaysTrue()', '', 'AllwaysTrue()', oGrp2, aHoBrwBai, aCoBrwBai )

     oSayEst    := TSay():New( 132, 012, {||"Estornar para:"}, oDlg1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 064, 009)
     cbSelecao  := TComboBox():New( 131, 080, {|u| If(PCount() > 0, nbSelecao := u, nbSelecao)}, aSelecao, 100, 014, oDlg1, , , , CLR_BLACK, CLR_WHITE, .T., oFont1, "", , , , , , , nbSelecao )
     oGrp3      := TGroup():New( 017,000,021,316,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
     oGrp5      := TGroup():New( 120,000,124,317,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )

     cBtnCon    := TButton():New( 132,192,"Confirma", oDlg1, {|| fConEst()   }, 037,012,,,,.T.,,"",,,,.F. )
     oBtnSai    := TButton():New( 132, 244, "Sair"  , oDlg1, {|| oDlg1:End() }, 037, 012, , , , .T., , "", , , , .F. )

     oDlg1:Activate(, , , .T.)

Return

Static Function fConEst()

       Local aEstSD3P 	:= {}
       //Local aOpeEst  	:= {}
       Local aIteMov  	:= {}
       Local aAuxMov  	:= {}
       //Local lTemMovAnt := .f.
       Local cDoc     	:= ""
       //Local cFlagRot 	:= ""
       //Local cAuxQbr  	:= ""
	   //Local cQbr1Tx  	:= ""
	   //Local cQbr2Tx  	:= ""
	   //Local cQbr3Tx  	:= ""
	   //Local cQbr4Tx  	:= ""
       //Local cMsgTel  	:= ""
       Local cQry1    	:= ""
       //Local cQry2    	:= ""
	   Local cAux       := "" 
	   //Local aCampos    := {} 
	   //Local cArqBloq
	   Local _cAreaBloq, nSLT, nX

       Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
 	   Private lMsErroAuto := .f. //necessario a criacao
       
       If Empty(nbSelecao)
          MsgStop("Selecione uma opção para estorno.")
       Else

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /* cArqBloq := "SCHP"+Substr(ALLTRIM(CNumEmp),3,6)+".DTC"
		  If file(cArqBloq)
		  	fErase(cArqBloq)
  		  Endif              
	      _cAreaBloq := U_NovoCursor()

	  	  If File(cArqBloq)
    	 	Use (cArqBloq) Alias (_cAreaBloq) VIA "CTREECDX" New 
			    DbSelectArea(_cAreaBloq)
			    If !eof() .and. !bof()  
    				cAux := "O programa de baixa de ops já está sendo executado !! Aguarde !! -> "+(_cAreaBloq)->USUARIO
					Messagebox(cAux,"Atenção...",64) 			
					//MsgBox(cAux, "Atenção!", "STOP")
		   			DbCloseArea()
			   		Return
	    		Endif
		  Endif*/
        /********************************************************************************************************************************/

          // Verificar se a rotina esta sendo executada por alguém
   		  //cFlagRot := Alltrim(GETMV('MV_BXMANEW'))
          //If Empty(cFlagRot)
          	//PutMv("MV_BXMANEW", "N"+"|"+Alltrim(cUserName)+"|"+Time()+"|"+Dtoc(MsDate()) )
          	  If nbSelecao $ 'CANCELA BAIXAS'
    	  	      Begin Transaction
                        /********************************************************************************************************************************/
                        /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
                      /*aCampos := { {"USUARIO"    ,"C",20,0} }
			 		  DbCreate(cArqBloq, aCampos, "CTREECDX")               

					  Use (cArqBloq) Alias (_cAreaBloq) VIA "CTREECDX" New 
					  DbSelectArea(_cAreaBloq)
				
					  Reclock(_cAreaBloq,.t.)
							(_cAreaBloq)->USUARIO := Alltrim(cUserName)
					  MsUnlock()*/    
                        If !Empty( Alltrim( GetMV( 'ZP_PAR0015' ) ) )
                           cAux := "O programa já está sendo usado por: " + Alltrim( GetMV( 'ZP_PAR0015' ) )
                           MessageBox( cAux, "Atenção!", 16 )
                           //return //LGS#20200207 - Adequação de release 12.1.25 e posteriores - Não pode ser usado return dentro de um begin transaction 
                        Else
                           PutMV( "ZP_PAR0015", RTRIM( cUserName ) )
                        Endif
                        /********************************************************************************************************************************/
  					//PutMv("MV_ESTNEG", "S")      

          	  //If nbSelecao $ 'PESAGEM - INICIO'
            	    If ZZA->ZZA_FLAG $ '5.4.3.2.1'
                	    aRotBai := {}
 	                    fBusRot(@aRotBai, ZZA->ZZA_ORDEM, ZZA->ZZA_PRODUT, Posicione("SC2", 1, xFilial("SC2")+ZZA->ZZA_ORDEM, "C2_ROTEIRO"))
              		    nQtdEsto := 0
                    	For nSLT := 1 To Len(aRotBai)
                        	If !Empty(aRotBai[nSLT][4]) //VERIFICA SE OPERAÇÃO JÁ FOI BAIXADA
                           		aOpeBai := {}
                           		aAdd(aOpeBai, {"H6_OP"     , SubStr(ZZA->ZZA_ORDEM+space(10), 1, 14), Nil } )
                           		aAdd(aOpeBai, {"H6_PRODUTO", ZZA->ZZA_PRODUT                        , Nil } )
                           		aAdd(aOpeBai, {"H6_OPERAC" , aRotBai[nSLT][1]                       , Nil } )
                           		aAdd(aOpeBai, {"H6_RECURSO", aRotBai[nSLT][2]                       , Nil } )

                           		lMsErroAuto := .f.
                           		DbSelectArea("SF5")
                           		MSFILTER('')
                           		DbSelectArea("SF5")
                           		DbSetOrder(1)
                           		DbSelectArea("SH6")
                           		MsExecAuto( {|x, y| Mata681(x, y)}, aOpeBai, 5)
                           		If !lMsErroAuto
                              		aRotBai[nSLT][4] := '' 
                              		nQtdEsto += 1
                           		Else
                              		MsgBox("Operação não pode ser estornada.", "ATENÇÃO")
                              		nSLT := Len(aRotBai)
                              		MostraErro()
                              		//Return() //LGS#20200206 - Adequação de release 12.1.25 e posteriores - Não pode usar return dentro de um begin transaction
                           		Endif
                        	Else
                           		nQtdEsto += 1
                        	Endif
                    	Next
                   		If ZZA->ZZA_FLAG == '5'
                   			If nQtdEsto == Len(aRotBai)
                   				RecLock("ZZA", .f.)
                       				ZZA->ZZA_FLAG   := '4'
                   				MsUnLock()
                    		Endif
                    	Endif	
                 	Endif
                 	If ZZA->ZZA_FLAG $ '4.3.2.1' // //Voltar itens baixados 
                    	aEstSD3P := {}
                    	cQry1 := ""
                    	cQry1 += " SELECT D3_FILIAL, SUBSTRING(SD3.D3_OP,1,11) AS ZZF_ORDEM, D3_TM, D3_DOC, D3_EMISSAO, D3_COD "
                    	cQry1 += " FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK) " 
                    	cQry1 += " LEFT OUTER JOIN "+RetSqlName("ZZF")+" ZZF WITH (NOLOCK) ON ZZF_FILIAL = D3_FILIAL AND ZZF_ORDEM = D3_OP AND ZZF_CODIGO = D3_COD AND ZZF_TRT = D3_TRT AND ZZF.D_E_L_E_T_  =''  "
                    	cQry1 += " WHERE SD3.D3_FILIAL = '"+xFilial("ZZA")+"' "
                    	cQry1 += "  AND SD3.D_E_L_E_T_ = '' "
                    	cQry1 += "  AND (SD3.D3_OP  = '"+ZZA->ZZA_ORDEM+"' OR SD3.D3_OBS = '"+ZZA->ZZA_ORDEM+"')"
                    	//cQry1 += "  AND ZZF.ZZF_FLAG = '1' "
                    	cQry1 += "  AND SD3.D3_ESTORNO <> 'S' AND SD3.D3_TM IN('100','110','600') "
                    	cQry1 += " GROUP BY D3_FILIAL, SD3.D3_OP, D3_TM, D3_DOC, D3_EMISSAO, D3_COD "
                    	TCQuery cQry1 ALIAS "ETMP" NEW
                    	DbSelectArea("ETMP")
                    	While !Eof() .and. (xFilial("ZZA") == ETMP->D3_FILIAL) 
                        	         //             1            2             3            4                5
                            aAdd(aEstSD3P, {ETMP->ZZF_ORDEM, ETMP->D3_DOC, ETMP->D3_TM, ETMP->D3_EMISSAO, ETMP->D3_COD   })
                          	DbSelectArea("ETMP")
                          	DbSkip()
                    	Enddo
                    	DbSelectArea("ETMP")
                    	DbCloseArea()
                    	//Voltar itens baixados do Laboratorio - SD3 ESTORNO POR DOCUMENTO
                    	aIteMov := {}
            			aAuxMov := {}
                    	For nX := 1 To Len(aEstSD3P) 
                       		If Alltrim(cDoc) <> Alltrim(aEstSD3P[nX][2])
                       			DbSelectArea("SD3") 
								DbSetOrder(2) 
                            	DbSeek(xFilial("SD3")+aEstSD3P[nX][2]+aEstSD3P[nX][5], .t.)  // D3_FILIAL+D3_DOC+D3_COD
                            	If !Eof() .and. (SD3->D3_FILIAL == XFilial("SD3")) .and. (Alltrim(SD3->D3_DOC)== Alltrim(aEstSD3P[nX][2])) .and. (Alltrim(SD3->D3_COD) == Alltrim(aEstSD3P[nX][5]))
                            		cDoc := aEstSD3P[nX][2]
	                           		aCabMov := { {"D3_DOC"     ,aEstSD3P[nX][2]    , NIL},;   // DOC      2
       	                    				 	 {"D3_TM"     , aEstSD3P[nX][3]    , NIL},;   // TIPO M   3
           	                				  	 {"D3_EMISSAO", aEstSD3P[nX][4]    , NIL} }   // EMISSAO  4
   	
                   	    			aAuxMov := { {"D3_TM"    ,  aEstSD3P[nX][3]    , NIL},;   // TIPO M   3
                   							 	 {"D3_OP"     , aEstSD3P[nX][1]    , NIL},;   // OP       1
                           	   		   		 	 {"D3_ESTORNO", "S"                , NIL},;   // ESTORNO
                       	    	  			 	 {"D3_TURNO"  , "EFP"              , NIL} }
	
   	                  				aAdd(aIteMov, aAuxMov)
       	                    		lMsErroAuto := .f.
                            		MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCabMov, aIteMov, 6)
									If lMsErroAuto		
										//LGS#20200206 - Adequação de release 12.1.25 e posteriores
										//ConOut("Erro no estorno! DOC "+aEstSD3P[nX][2])
										FwLogMSG( "ERROR", , 'SIGAPCP', funname(), '', '01', "Erro no estorno! DOC "+aEstSD3P[nX][2], 0 )
   	    		                  		MostraErro()
		                          		//Return()  //LGS#20200206 - Adequação de release 12.1.25 e posteriores - Não pode usar return dentro de um begin transaction
									EndIf
                            	Endif
                       		Endif
                   		Next
                    	DbSelectArea("SD3")
                    	DbClosearea()
						/*
                        If GetMV("MV_XHABZZF") // Parametro implementado para controle da exclusão do SD4
                        	// PROVISORIAMENTE RETORNANDO O EMPENHO ORGINAL (ESTUDANDO FORMA DE VOLTAR A USAR APENAS SD4 NO EMPENHO) JAN/2014
							cQry2 := ""
							cQry2 += " UPDATE "+RetSqlName("SD4")+" SET D_E_L_E_T_ ='', R_E_C_D_E_L_ = 0 WHERE D_E_L_E_T_ ='*' AND D4_FILIAL ='"+xFilial("SD4")+"' AND D4_OP ='"+ALLTRIM(ZZA->ZZA_ORDEM)+"'"
	                   		TCSQLExec(cQry2)
	      				Endif */
                 	Endif
             	    // ATUALIZAR ZZF DOS ITENS DO ALMOXARIFADO 99 QUE JÁ FORAM ESTORNADOS JUNTO COM O ROTEIRO DE OPERAÇÕES NO COMEÇO DO PROGRAMA
              	 	DbSelectArea("ZZF") 
   				 	DbSetOrder(1) 
                 	DbSeek(xFilial("ZZF")+Alltrim(ZZA->ZZA_ORDEM), .t.)  // filial + o.p
                 	If Found() .and. (xFilial("ZZF")== ZZF->ZZF_FILIAL) .and. (Alltrim(ZZA->ZZA_ORDEM) == Alltrim(ZZF->ZZF_ORDEM))
            			//cQry1 := "UPDATE "+RetSqlName("ZZF")+" SET ZZF_FLAG = '2', ZZF_OBS ='EST -'+SUBSTRING(ZZF_OBS, 1, 2)+' - Estornado' WHERE ZZF_FILIAL ='"+xFilial("ZZF")+"'  AND D_E_L_E_T_ = '' AND ZZF_ORDEM = '"+Alltrim(ZZF->ZZF_ORDEM)+"' AND ZZF_FLAG IN('1') AND ZZF_LOCAL ='99' "
						cQry1 := "UPDATE "+RetSqlName("ZZF")+" SET D_E_L_E_T_ ='*', ZZF_OBS ='EST -'+SUBSTRING(ZZF_OBS, 1, 2)+' - Estornado' WHERE ZZF_FILIAL ='"+xFilial("ZZF")+"'  AND D_E_L_E_T_ = '' AND ZZF_ORDEM = '"+Alltrim(ZZF->ZZF_ORDEM)+"'"
						XXX := TCSQLEXEC(cQry1)
            		    If XXX <> 0
                    		cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
                       	 	MemoWrit(cNomArq, cQry1)
                  		Endif
              	 	Endif
                 	DbSelectArea("ZZF")
                 	DbCloseArea() 
                 	// APAGAR A LINHA DA TABELA ZZA PARA SER RECRIADA SOMENTE QUANDO FOR O.P FOR REAPONTADA (NÃO BAIXAR ITENS QUE FORAM ESTORNADOS)
              	 	DbSelectArea("ZZA") 
   				 	DbSetOrder(2) 
                 	DbSeek(xFilial("ZZA")+Alltrim(ZZA->ZZA_ORDEM), .t.)  // filial + o.p
                 	If Found()
                 		RecLock("ZZA", .f.)
                        	ZZA->ZZA_CAMPO  := SUBSTR(ZZA->ZZA_HELP, 1, 2)+" - E90 - ESTORNADA EM "+Dtoc(dDataBase)+" às "+Time()+" ' "
                    		DbDelete()
                    	MsUnLock()
				 	Endif                    	
              	 	DbSelectArea("ZZA") 
                 	DbCloseArea()
          	        //PutMv("MV_BXMANEW", "")                 
					//PutMv("MV_ESTNEG", "N")                 
   					PutMv("ZP_PAR0015", "")  
   			       	Messagebox("Ordem de Produção Estornada com Sucesso !!","Atenção...",64) 			
					oDlg1:End()

					DbSelectArea(_cAreaBloq)
					DbCloseArea()
					//FErase(cArqBloq)           
 
	    	  End Transaction
//            ElseIf nbSelecao $ 'PESAGEM - FIM'
//            ElseIf nbSelecao $ 'COLORISTA'
//            ElseIf nbSelecao $ 'LABORATORIO'
//            ElseIf nbSelecao $ 'BAIXADA'
          	  Endif
          
          /*Else
   		      cAuxQbr := cFlagRot
         	  cQbr1Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1) )
         	  cAuxQbr := Stuff(cAuxQbr, 1, At("|", cAuxQbr), "" )
         	  cQbr2Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1) )
         	  cAuxQbr := Stuff(cAuxQbr, 1, At("|", cAuxQbr), "" )
         	  cQbr3Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1) )
         	  cAuxQbr := Stuff(cAuxQbr, 1, At("|", cAuxQbr), "" )
         	  cQbr4Tx := SubStr(cAuxQbr, 1, Iif( At("|", cAuxQbr) == 0, 10, At("|", cAuxQbr) - 1)  )
         	  cMsgTel := "A baixa de O.ps esta em uso por: "+cQbr2Tx+", desde às: "+cQbr3Tx+" do dia "+cQbr4Tx+". Aguarde o término para estornar a O.P !!!"

         	  MsgStop(cMsgTel)
         	  If Hrs2Min( time() ) - Hrs2Min( SubStr( cFlagRot, 2 + At( "|", SubStr( cFlagRot, 3) ) + 1 ) ) >= 20 .or. Hrs2Min( time() ) - Hrs2Min( SubStr( cFlagRot, 2 + At( "|", SubStr( cFlagRot, 3) ) + 1 ) ) < 0
         	  	 PutMv("MV_BXMANEW", "")
         	  Endif
     	  Endif */
	Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrwOri() - Monta aHeader da MsNewGetDados para o Alias: TMP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrwOri()
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 06/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*
       DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SG1")
       While !Eof() .and. SX3->X3_ARQUIVO == "SG1"
             If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
                If AllTrim(SX3->X3_CAMPO) $ "G1_COMP"
                   noBrwOri++
                   Aadd(aHoBrwOri, { Trim(( _cAliasSX3 )->( X3_TITULO )), "G1_COMP", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
                ElseIf AllTrim(SX3->X3_CAMPO) $ "G1_TRT"
                   noBrwOri++
                   Aadd(aHoBrwOri, { Trim(( _cAliasSX3 )->( X3_TITULO )), "G1_TRT", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
                ElseIf AllTrim(SX3->X3_CAMPO) $ "G1_QUANT"
                   noBrwOri++
                   Aadd(aHoBrwOri, { Trim(( _cAliasSX3 )->( X3_TITULO )), "G1_QUANT", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
                EndIf
             Endif
             DbSkip()
       EndDo*/
       DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SG1")
       While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SG1"
             If X3Uso(( _cAliasSX3 )->( X3_USADO )) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL )
                If AllTrim(( _cAliasSX3 )->( X3_CAMPO )) $ "G1_COMP"
                   noBrwOri++
                   Aadd(aHoBrwOri, { Trim(( _cAliasSX3 )->( X3_TITULO )), "G1_COMP" , ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
                ElseIf AllTrim(( _cAliasSX3 )->( X3_CAMPO )) $ "G1_TRT"
                   noBrwOri++
                   Aadd(aHoBrwOri, { Trim(( _cAliasSX3 )->( X3_TITULO )), "G1_TRT"  , ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
                ElseIf AllTrim(( _cAliasSX3 )->( X3_CAMPO )) $ "G1_QUANT"
                   noBrwOri++
                   Aadd(aHoBrwOri, { Trim(( _cAliasSX3 )->( X3_TITULO )), "G1_QUANT", ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
                EndIf
             Endif
             DbSkip()
       EndDo
Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrwOri() - Monta aCols da MsNewGetDados para o Alias: TMP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrwOri()
       //Local aAux    := {}
       Local cQry    := ""
       Local nI
       Local nQtdOrd := Iif(ZZA->ZZA_FLAG == '1', 0, ZZA->ZZA_PESPES)
       cQry += "SELECT SG1.G1_COMP, SG1.G1_TRT, (SG1.G1_QUANT + (SG1.G1_QUANT * (SG1.G1_PERDA / 100))) * "+StrTran(Alltrim(Transform(nQtdOrd, "@E 999999999999.99")), ",", ".")+" AS G1_QUANT "
       cQry += "FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
       cQry += "WHERE SG1.G1_FILIAL  = '"+xFilial("ZZA")+"' "
       cQry += "  AND SG1.D_E_L_E_T_ = '' "
       cQry += "  AND SG1.G1_COD     = '"+ZZA->ZZA_PRODUT+"' "
       cQry += "ORDER BY SG1.G1_TRT "
       TCQuery cQry ALIAS "TCQ" New
       DbSelectArea("TCQ")
       While !Eof()
             // produto de custeio
             If U_IsProdCusto(TCQ->G1_COMP)
               TCQ->(dbSkip())
               Loop
             Endif   
             Aadd(aCoBrwOri, Array(noBrwOri+1))
             For nI := 1 To noBrwOri
                 If Alltrim(aHoBrwOri[nI][2]) $ 'G1_COMP'
                    aCoBrwOri[Len(aCoBrwOri)][nI] := CriaVar('G1_COMP')
                    aCoBrwOri[Len(aCoBrwOri)][nI] := TCQ->G1_COMP
                 ElseIf Alltrim(aHoBrwOri[nI][2]) $ 'G1_TRT'
                        aCoBrwOri[Len(aCoBrwOri)][nI] := CriaVar('G1_TRT')
                        aCoBrwOri[Len(aCoBrwOri)][nI] := TCQ->G1_TRT
                 ElseIf Alltrim(aHoBrwOri[nI][2]) $ 'G1_QUANT'
                        aCoBrwOri[Len(aCoBrwOri)][nI] := CriaVar('G1_QUANT')
                        aCoBrwOri[Len(aCoBrwOri)][nI] := TCQ->G1_QUANT
                 Endif
             Next
             aCoBrwOri[Len(aCoBrwOri)][noBrwOri+1] := .F.
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       If Len(aCoBrwOri) <= 0
          Aadd(aCoBrwOri, Array(noBrwOri+1))
          For nI := 1 To noBrwOri
              If Alltrim(aHoBrwOri[nI][2]) $ 'G1_COMP'
                 aCoBrwOri[1][nI] := CriaVar('G1_COMP')
              ElseIf Alltrim(aHoBrwOri[nI][2]) $ 'G1_TRT'
                     aCoBrwOri[1][nI] := CriaVar('G1_TRT')
              ElseIf Alltrim(aHoBrwOri[nI][2]) $ 'G1_QUANT'
                     aCoBrwOri[1][nI] := CriaVar('G1_QUANT')
              Endif
          Next
          aCoBrwOri[1][noBrwOri+1] := .F.
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrwBai() - Monta aHeader da MsNewGetDados para o Alias: TRB
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrwBai()
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 06/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("ZZF")
       While !Eof() .and. SX3->X3_ARQUIVO == "ZZF"
       		If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
            	If AllTrim(SX3->X3_CAMPO) $ "ZZF_CODIGO"
                   noBrwBai++
                   Aadd(aHoBrwBai, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZF_CODIGO", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
                ElseIf AllTrim(SX3->X3_CAMPO) $ "ZZF_TRT"
                       noBrwBai++
                       Aadd(aHoBrwBai, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZF_TRT", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
                ElseIf AllTrim(SX3->X3_CAMPO) $ "ZZF_QTDUSA"
                       noBrwBai++
                       Aadd(aHoBrwBai, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZF_QTDUSA", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
                ElseIf AllTrim(SX3->X3_CAMPO) $ "ZZF_OBS"
                       noBrwBai++
                       Aadd(aHoBrwBai, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZF_OBS", SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
                EndIf
            EndIf
            DbSkip()
       Enddo*/
       DbSelectArea( _cAliasSX3 )
       DbSetOrder(1)
       DbSeek("ZZF")
       While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "ZZF"
       		If X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL )
            	If AllTrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZZF_CODIGO"
                   noBrwBai++
                   Aadd(aHoBrwBai, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZF_CODIGO", ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
                ElseIf AllTrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZZF_TRT"
                   noBrwBai++
                   Aadd(aHoBrwBai, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZF_TRT"   , ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
                ElseIf AllTrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZZF_QTDUSA"
                   noBrwBai++
                   Aadd(aHoBrwBai, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZF_QTDUSA", ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
                ElseIf AllTrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZZF_OBS"
                   noBrwBai++
                   Aadd(aHoBrwBai, { Trim(( _cAliasSX3 )->( X3_TITULO )), "ZZF_OBS"   , ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
                EndIf
            EndIf
            DbSkip()
       Enddo
Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrwBai() - Monta aCols da MsNewGetDados para o Alias: TRB
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrwBai()
       //Local aAux := {}
       Local cQry := ""
       Local nI
       cQry += "SELECT ZZF.ZZF_CODIGO, ZZF.ZZF_TRT, ZZF.ZZF_QTDUSA, ZZF.ZZF_OBS "
       cQry += "FROM "+RetSqlName("ZZF")+" ZZF WITH (NOLOCK) "
       cQry += "WHERE ZZF.ZZF_FILIAL = '"+xFilial("ZZF")+"' "
       cQry += "  AND ZZF.D_E_L_E_T_ = '' "
       cQry += "  AND ZZF.ZZF_ORDEM  = '"+ZZA->ZZA_ORDEM+"' "
       cQry += "ORDER BY ZZF.ZZF_TRT "
       TCQuery cQry ALIAS "TCQ" New
       DbSelectArea("TCQ")
       While !Eof()
             Aadd(aCoBrwBai, Array(noBrwBai+1))
             For nI := 1 To noBrwBai
                 If Alltrim(aHoBrwBai[nI][2]) $ 'ZZF_CODIGO'
                    aCoBrwBai[Len(aCoBrwBai)][nI] := CriaVar('ZZF_CODIGO')
                    aCoBrwBai[Len(aCoBrwBai)][nI] := TCQ->ZZF_CODIGO
                 ElseIf Alltrim(aHoBrwBai[nI][2]) $ 'ZZF_TRT'
                        aCoBrwBai[Len(aCoBrwBai)][nI] := CriaVar('ZZF_TRT')
                        aCoBrwBai[Len(aCoBrwBai)][nI] := TCQ->ZZF_TRT
                 ElseIf Alltrim(aHoBrwBai[nI][2]) $ 'ZZF_QTDUSA'
                        aCoBrwBai[Len(aCoBrwBai)][nI] := CriaVar('ZZF_QTDUSA')
                        aCoBrwBai[Len(aCoBrwBai)][nI] := TCQ->ZZF_QTDUSA
                 ElseIf Alltrim(aHoBrwBai[nI][2]) $ 'ZZF_OBS'
                        aCoBrwBai[Len(aCoBrwBai)][nI] := CriaVar('ZZF_OBS')
                        aCoBrwBai[Len(aCoBrwBai)][nI] := TCQ->ZZF_OBS
                 Endif
             Next
             aCoBrwBai[Len(aCoBrwBai)][noBrwBai+1] := .F.
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       If Len(aCoBrwBai) <= 0
          Aadd(aCoBrwBai, Array(noBrwBai+1))
          For nI := 1 To noBrwBai
              If Alltrim(aHoBrwBai[nI][2]) $ 'ZZF_CODIGO'
                 aCoBrwBai[1][nI] := CriaVar('ZZF_CODIGO')
              ElseIf Alltrim(aHoBrwBai[nI][2]) $ 'ZZF_TRT'
                     aCoBrwBai[1][nI] := CriaVar('ZZF_TRT')
              ElseIf Alltrim(aHoBrwBai[nI][2]) $ 'ZZF_QTDUSA'
                     aCoBrwBai[1][nI] := CriaVar('ZZF_QTDUSA')
              Endif
          Next
          aCoBrwBai[1][noBrwBai+1] := .F.
       Endif
Return

/******************************************************************************************************************/
/*** FBUSROT - BUSCA ROTEIRO DE OPERAÇÃO PARA BAIXAS DAS ORDENS DE PRODUÇÕES                                    ***/
/******************************************************************************************************************/
STATIC Function fBusRot(aRotBai, cOrdem, cProduto, cRoteiro, cSeqEnv)
       cQrySG2 := ""
       cQrySG2 += "SELECT SG2.G2_OPERAC, SG2.G2_RECURSO, SG2.G2_DESCRI "
       cQrySG2 += "FROM "+RetSqlName("SG2")+" SG2 WITH (NOLOCK) "
       cQrySG2 += "WHERE SG2.G2_FILIAL  = '"+xFilial("SG2")+"' "
       cQrySG2 += "  AND SG2.D_E_L_E_T_ = '' "
       cQrySG2 += "  AND SG2.G2_CODIGO  = '"+cRoteiro+"' "
       cQrySG2 += "  AND SG2.G2_PRODUTO = '"+cProduto+"' "
       cQrySG2 += "ORDER BY SG2.G2_OPERAC "
       TCQuery cQrySG2 ALIAS "ROT" NEW
       DbSelectArea("ROT")
       While !Eof()
             cOperac := Posicione("SH6", 1, xFilial("SH6")+SubStr(cOrdem+space(10), 1, 13)+cProduto+ROT->G2_OPERAC, "H6_OPERAC")
             aAdd(aRotBai, {ROT->G2_OPERAC, ROT->G2_RECURSO, ROT->G2_DESCRI, cOperac, ""})
             DbSelectArea("SH6")
             DbSetOrder(1)
             DbSeek(xFilial("SH6")+SubStr(cOrdem+space(10), 1, 13)+cProduto+ROT->G2_OPERAC, .t.)
             If Found()
                While !Eof() .and. Alltrim(SH6->H6_OP) == Alltrim(SubStr(cOrdem+space(10), 1, 13)) .and. SH6->H6_PRODUTO == cProduto .and. SH6->H6_OPERAC == ROT->G2_OPERAC
                      If !Empty(SH6->H6_OBSERVA)
                         aRotBai[Len(aRotBai)][4] := ""
                         If Empty(aRotBai[Len(aRotBai)][5])
                            aRotBai[Len(aRotBai)][5] := Alltrim(SH6->H6_OBSERVA)
                         Else
                            aRotBai[Len(aRotBai)][5] += "."+Alltrim(SH6->H6_OBSERVA)
                         Endif
                      Else
                         aRotBai[Len(aRotBai)][4] := cOperac
                      Endif
                      DbSelectArea("SH6")
                      DbSkip()
                EndDo
             EndIf
             DbSelectArea("ROT")
             DbSkip()
       Enddo
       DbSelectArea("ROT")
       DbCloseArea()
       aSort(aRotBai,,, {|x, y| x[1] > y[1] })
Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PCPA01_4³ -Consulta Ordens de Producao em Aberto 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function PCPA01_R()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private nCBxOrd := "Emissao"
     Private cGetInf := Space(10)
     Private aSelLin := {}

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFont1", "oDlg1", "oSay1", "oSay2", "oBrwSC2", "oBtn1", "oBtn2", "oCBxOrd", "oGetInf", "oBtn3")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1     := TFont():New( "@Arial Unicode MS", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1      := MSDialog():New( 088, 232, 561, 1112, "LOTES PI BRASILUX X PA DISSOLTEX", , , .F., , , , , , .T., , , .T. )
     oSay1      := TSay():New( 004, 068, {||"CONSULTA LOTES PI BRASILUX X PA DISSOLTEX"}, oDlg1, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 276, 012)
     oSay2      := TSay():New( 222, 096, {||"Pesquisa:"} , oDlg1, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008)
     oGetInf    := TGet():New( 221, 132, {|u| If(PCount() > 0, cGetInf := u, cGetInf)}, oDlg1, 060, 008, '', , CLR_BLACK, CLR_WHITE, , , , .T., "", , , .F., .F., , .F., .F., "", "cGetInf", ,)
     oGetInf:bLostFocus := {|| fBusInLot() }
     oTblLote()
     DbSelectArea("TCL")
     DbSetOrder(1)
     oBrwSC2    := MsSelect():New( "TCL", "", "", {{"TCL_PEDIDO", "", "Pedido", "@R XXXXXX"}, {"TCL_LOTEB", "", "L. Bra", "@R 999999"}, {"TCL_PRODUT", "", "Produto", "@R XXX99.99.999-99"}, {"TCL_EMISPI", "", "Emissao PI", "@R 99/99/9999"}, {"TCL_QUANT", "", "Qtd Sol.", "@B 999,999.99"}, {"TCL_LINHA", "", "Linha", "@R XX"}, {"TCL_FECHPI", "", "Fechto PI", "@R 99/99/9999"},  {"TCL_LOTED", "", "L. Dis", "@R 999999"}, {"TCL_FECHPA", "", "Fechto PA", "@R 99/99/9999"}, {"TCL_BORDBR", "", "Bord. Br", "@R 999999"}, {"TCL_LOCALI", "", "Localiz.", ""}}, .F., , {024, 000, 216, 442}, , , oDlg1 ) 
     //oBtn1      := TButton():New( 220, 316, "Imprimir", oDlg1, {|| fImpInf()   }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn2      := TButton():New( 220, 372, "Sair"    , oDlg1, {|| oDlg1:End() }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn3      := TButton():New( 220, 196, "Buscar"  , oDlg1, {|| fBusInLot()   }, 037, 012, , , , .T., , "", , , , .F. )
     oCBxOrd    := TComboBox():New( 220, 004, {|u| If(PCount() > 0, nCBxOrd := u, nCBxOrd)}, {"Pedido", "L. Bra", "Linha", "Emissao", "Produto" }, 072, 010, oDlg1, , , , CLR_BLACK, CLR_WHITE, .T., , "", , , , , , , nCBxOrd )
     oCBxOrd:bLostFocus := {|| fMudOrBu()}

     oDlg1:Activate(,,,.T.)
     DbSelectArea("TCL")
     DbCloseArea()
     oTempTbl04:Delete()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTblLote() - Cria temporario para o Alias: TCL
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTblLote()
       Local aFds := {}
       //Local cTmp

       aAdd( aFds , {"TCL_PEDIDO" 	, "C", 006, 000} )
       aAdd( aFds , {"TCL_LOTEB"   	, "C", 006, 000} )
       aAdd( aFds , {"TCL_PRODUT"  	, "C", 015, 000} )
       aAdd( aFds , {"TCL_EMISPI" 	, "D", 010, 000} )
       aAdd( aFds , {"TCL_QUANT"   	, "N", 010, 002} )
       aAdd( aFds , {"TCL_LINHA"  	, "C", 002, 000} )
       aAdd( aFds , {"TCL_FECHPI"   , "D", 010, 000} )
       aAdd( aFds , {"TCL_LOTED"   	, "C", 006, 000} )
       aAdd( aFds , {"TCL_FECHPA"   , "D", 010, 000} )
       aAdd( aFds , {"TCL_BORDBR"  	, "C", 006, 000} )
       aAdd( aFds , {"TCL_LOCALI"   , "C", 010, 000} )

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 03/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cTmp := CriaTrab( aFds, .T. )
       //DbUseArea(.t., , cTmp, "TCL", .t., .f.)

       //DbCreateIndex(SubStr(cTmp, 1, 10)+'1', "TCL_PEDIDO" 	, {|| "TCL_ORDEM "})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'2', "TCL_LOTEB"  	, {|| "TCL_LOTEB "})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'3', "TCL_LINHA" 	, {|| "TCL_LINHA "})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'4', "TCL_EMISPI" 	, {|| "TCL_EMISPI"})
       //DbCreateIndex(SubStr(cTmp, 1, 10)+'5', "TCL_PRODUT"	, {|| "TCL_PRODUT"})

       //DbClearInd()
       //DbSetIndex(SubStr(cTmp, 1, 10)+'1')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'2')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'3')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'4')
       //DbSetIndex(SubStr(cTmp, 1, 10)+'5')
       oTempTbl04 := FWTemporaryTable():New( "TCL" )
       oTempTbl04:SetFields( aFds )
       oTempTbl04:AddIndex( "cInd01", { "TCL_ORDEM"  } )
       oTempTbl04:AddIndex( "cInd02", { "TCL_LOTEB"   } )
       oTempTbl04:AddIndex( "cInd03", { "TCL_LINHA"  } )
       oTempTbl04:AddIndex( "cInd04", { "TCL_EMISPI" } )
       oTempTbl04:AddIndex( "cInd05", { "TCL_PRODUT" } )
       /********************************************************************************************************************************/
       DbSetOrder(2)
       
       MsgRun(OemToAnsi("Selecionando Lotes PI Brasilux x Lotes PA Dissoltex..."), OemToAnsi("Aguarde..."), { ||fCarLotBR()} )
Return
     
/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fCarLotBR()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fCarLotBR()
    
    Local cQry1 := ""

	cQry1 += " SELECT SC2DI.C2_XPEDBRA AS 'C2_XPEDBRA', SC2BR.C2_LOTE AS 'C2_LOTEBR', SC2DI.C2_PRODUTO AS 'C2_PRODUTO', SB1DI.B1_DESC, " 
	//cQry1 += " SC2DI.C2_QUANT AS 'C2_QUANT', SUBSTRING(SC2BR.C2_EMISSAO,7,2)+'/'+SUBSTRING(SC2BR.C2_EMISSAO,5,2)+'/'+SUBSTRING(SC2BR.C2_EMISSAO,1,4) AS 'C2_EMISSAOBR', "  
	//cQry1 += " SUBSTRING(SC2BR.C2_DATRF,7,2)+'/'+SUBSTRING(SC2BR.C2_DATRF,5,2)+'/'+SUBSTRING(SC2BR.C2_DATRF,1,4) AS 'C2_DATRFBR', SC2DI.C2_LOTE AS 'C2_LOTEDI', "
	//cQry1 += " SUBSTRING(SC2DI.C2_DATRF,7,2)+'/'+SUBSTRING(SC2DI.C2_DATRF,5,2)+'/'+SUBSTRING(SC2DI.C2_DATRF,1,4) AS 'C2_DATRFDI', ISNULL(SZGBR.ZG_CODIGO,'') AS 'ZG_CODIGO', "
	cQry1 += " SC2DI.C2_QUANT AS 'C2_QUANT', SC2BR.C2_EMISSAO AS 'C2_EMISSAOBR', SC2BR.C2_DATRF AS 'C2_DATRFBR', SC2DI.C2_LOTE AS 'C2_LOTEDI', "
	cQry1 += " SC2DI.C2_DATRF AS 'C2_DATRFDI', ISNULL(SZGBR.ZG_CODIGO,'') AS 'ZG_CODIGO', "
	cQry1 += " ISNULL(SZGBR.ZG_LOCALIZ,'') AS 'ZG_LOCALIZ' "
	cQry1 += " FROM "+RetSqlName("SC2")+" SC2DI WITH(NOLOCK) "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2BR WITH(NOLOCK) ON SC2DI.C2_FILIAL = '060101' AND SC2DI.C2_XLOTEBR = SC2BR.C2_LOTE AND SC2BR.D_E_L_E_T_ ='' "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1DI WITH(NOLOCK) ON SB1DI.B1_FILIAL = SC2DI.C2_FILIAL AND SB1DI.B1_COD = SC2DI.C2_PRODUTO AND SB1DI.D_E_L_E_T_ ='' "
	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SZG")+" SZGBR WITH(NOLOCK) ON SZGBR.ZG_FILIAL = '010101' AND SUBSTRING(SZGBR.ZG_PEDIDO,3,6) = SC2DI.C2_XPEDBRA AND SZGBR.D_E_L_E_T_ ='' "
	cQry1 += " WHERE SC2DI.C2_XLOTEBR <> '' AND SC2DI.D_E_L_E_T_ ='' AND SC2BR.C2_FILIAL ='010101' "
	cQry1 += " ORDER BY SC2BR.C2_LOTE, SC2DI.C2_PRODUTO  "

    TCQuery cQry1 ALIAS "TCQ" NEW
    DbSelectArea("TCQ")
    DbGoTop()
    
    aSelLin := {}
    While !Eof()
    	cSelLin := space(02)
        RecLock("TCL", .t.)
        	TCL->TCL_PEDIDO  := TCQ->C2_XPEDBRA
            TCL->TCL_LOTEB   := TCQ->C2_LOTEBR
            TCL->TCL_PRODUT  := TCQ->C2_PRODUTO
            TCL->TCL_QUANT   := TCQ->C2_QUANT
            TCL->TCL_EMISPI	 := STOD(TCQ->C2_EMISSAOBR)
            If Len(Alltrim(TCQ->C2_PRODUTO)) == 6
                TCL->TCL_LINHA := 'CA'
                cSelLin := 'CA'
            ElseIf Len(Alltrim(TCQ->C2_PRODUTO)) == 5
                TCL->TCL_LINHA := 'CS'
                cSelLin := 'CS'
            ElseIf Len(Alltrim(TCQ->C2_PRODUTO)) == 4
                TCL->TCL_LINHA := 'PT'
                cSelLin := 'PT'
            Else
               TCL->TCL_LINHA := SubStr(TCQ->C2_PRODUTO, 4, 2)
               cSelLin := SubStr(TCQ->C2_PRODUTO, 4, 2)
            Endif
            TCL->TCL_FECHPI    := STOD(TCQ->C2_DATRFBR)
            TCL->TCL_LOTED     := TCQ->C2_LOTEDI
            TCL->TCL_FECHPA    := STOD(TCQ->C2_DATRFDI)
			TCL->TCL_BORDBR    := TCQ->ZG_CODIGO 
			TCL->TCL_LOCALI    := TCQ->ZG_LOCALIZ
        MsUnLock()
        
        nPos := aScan(aSelLin, {|x| x[1] == cSelLin})
        If nPos == 0
            aAdd(aSelLin, {cSelLin, Iif(cSelLin $ 'CA', "Concentrado Base d'agua", Iif(cSelLin $ 'CS', "Concentrado Base solvente", Iif(cSelLin $ 'PT', "Pastas/Soluções", Posicione("SZ1", 1, xFilial("SZ1")+cSelLin, "Z1_DESCR") ) ) ) } )
        Endif
        
        DbSelectArea("TCQ")
        DbSkip()
    Enddo
    
    DbSelectArea("TCQ")
    DbCloseArea()
    
    DbSelectArea("TCL")
    DbGoTop()
    
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fMudOrBu()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fMudOrBu()
       DbSelectArea("TCL")
       DbSetOrder(oCBxOrd:nAt)
       DbGoTop()
       If oCBxOrd:nAt == 1     //Pedido
          oSay2:lVisibleControl := .t.
          oGetInf:lVisibleControl := .t.
          oBtn3:lVisibleControl := .t.
          cGetInf := Space(11)
       ElseIf oCBxOrd:nAt == 2 //Lote Brasilux
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(06)
       ElseIf oCBxOrd:nAt == 3 // Linha
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(2)
       ElseIf oCBxOrd:nAt == 4 // Emissão PI
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(10)
       ElseIf oCBxOrd:nAt == 5 // Produto
              oSay2:lVisibleControl := .t.
              oGetInf:lVisibleControl := .t.
              oBtn3:lVisibleControl := .t.
              cGetInf := Space(15)
       Endif
       oBrwSC2:oBrowse:Refresh()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fBusInLot()   
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fBusInLot()
       DbSelectArea("TCL")
       DbSetOrder(oCBxOrd:nAt)
       If oCBxOrd:nAt == 4
          DbSeek(CTOD(cGetInf))
       Else
          DbSeek(cGetInf)
       Endif
       oBrwSC2:oBrowse:Refresh()
Return



User Function PCPA01R()
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio nome de apontamento"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "Tabela              Matricula Funcionário"
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "PCPA01R"
PRIVATE aLinha  := { },nLastKey := 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "PCPA01R"            //Nome Default do relatorio em Disco

wnrel:=SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)
//wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

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

return

/////////////////////////////////////////////////////////
// Funçào....: RPTDETAIL    Data....: 08/06/15         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
//Local nTotal := 0
//Local 	_nCont := 0
//Local lNormal
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery :=" SELECT CASE WHEN (X5_TABELA ='XB') THEN '1 -) BALANÇA' ELSE "
cQuery +="CASE WHEN (X5_TABELA ='XC') THEN '2 -) COLORISTA' ELSE "  
cQuery +="CASE WHEN (X5_TABELA ='XL') THEN '3 -) LABORATORIO' ELSE "  
cQuery +="CASE WHEN (X5_TABELA ='XE') THEN '4 -) ENVASE' END END END END AS 'TIPO_APTO', X5_CHAVE AS 'MATRICULA', X5_DESCRI AS 'FUNCIONARIO' "
cQuery +="FROM  "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) "
cQuery +="WHERE SX5.D_E_L_E_T_ ='' AND (X5_FILIAL = '"+cfilant+"') AND X5_TABELA IN ('XE','XB','XC','XL') "   
cQuery +="ORDER BY TIPO_APTO, X5_DESCRI"

TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

SetRegua(RECCOUNT()) 
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)                       
_nLin := 08                                                                                             

cAuxTabela  := TCQ->TIPO_APTO
While !Eof()
	if _nLin > 55                                                                    	
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 08  
	endif
	@ _nLin,000 psay TCQ->TIPO_APTO
	@ _nLin,020 psay TCQ->MATRICULA
	@ _nLin,030 psay TCQ->FUNCIONARIO
	@ _nLin++	
	cAuxTabela  := TCQ->TIPO_APTO
	dbselectarea("TCQ")	 
	dbskip() 
EndDo
	dbSelectArea("TCQ")
    dbCloseArea()
Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif
Return      


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ FRecebOp() - Bipa a Ordem de produção para ser Marcada como Arquivada pelo PCP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

User Function fRecebOp()

	Private cGet1Tr   := Space(11) 

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±	
	±± Declaração de Variaveis Private dos Objetos                             ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    
	SetPrvt("oFontTr1", "oFontTr2", "oDlg1Tr", "oSay1Tr", "oSay2Tr", "oSay3Tr", "oGet1Tr")

    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
    ±± Definicao do Dialog e todos os seus componentes.                        ±±
    Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    oFontTr1  := TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
    oFontTr2  := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
    oDlg1Tr   := MSDialog():New( 258, 232, 383, 570, "Arquiva Ordens de Produção", , , .F., , , , , , .T., , , .T. )


    oSay1Tr   := TSay():New( 023, 008, {|| "O.P..:"     }, oDlg1Tr, , oFontTr1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 012)
    oGet1Tr   := TGet():New( 020, 047, {|u| If(PCount() > 0, cGet1Tr := u, cGet1Tr)}, oDlg1Tr, 088, 018, '@!'             , , CLR_BLACK, CLR_WHITE, oFontTr1, , , .T., "", , , .F., .F., , .F. , .F., ""      ,"cGet1Tr", , )
    oGet1Tr:bLostFocus := {|| fArquivaOp(Alltrim(cGet1Tr))}
  //oBtn1Tr   := TButton():New( 046, 122, "Sair", oDlg1Tr, {|| oDlg1Tr:End()}  , 048, 014, , oFontTr2, , .T., , "", , , , .F. )
	oBtn1Tr   := TButton():New( 046, 122, "Confirma", oDlg1Tr, {|| fArquivaOp(Alltrim(cGet1Tr))}  , 048, 014, , oFontTr2, , .T., , "", , , , .F. )    
    oDlg1Tr:Activate( , , , .T.)

	
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
±± Function  ³ fArquivaOp() - Marca a Op como recebida pela PCP, devolvida pela produção para arquivamento 
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

Static Function fArquivaOp(cNumOp)	

    Local lOpFechada := .t.
    
    If Empty(cGet1Tr) 
    	oGet1Tr:SetFocus()
    	Return
    Endif	
    
    DbSelectArea("ZZA")
    DbSetOrder(2)
    DbSeek(xFilial("ZZA")+cNumOp, .t.)
    If !Found()
		Messagebox("Ordem de produção Inexistente ou Excluída !! ","Atenção...",48)    	
	ElseIf (Posicione("SB1", 1, xFilial("SB1")+ZZA->ZZA_PRODUT, "B1_TIPO") <> 'PI')  
		Messagebox("Confira apenas as ordens de produção principal (Produtos intermediários) !! ","Atenção...",48)    	
 	Else
 		If ZZA->ZZA_ENVIA $ 'S'
			Messagebox("Ordem de produção devolvida anteriormente !! ","Atenção...",48)
			oGet1Tr:SetFocus()
			DbSelectArea("SC2")
			DbClosearea()
			Return()    	
 		Else
		    DbSelectArea("SC2")
		    DbSetOrder(13)
		    DbSeek(xFilial("SC2")+Alltrim(ZZA->ZZA_LOTE), .t.)
		    If Found() 
		    	While !Eof() .and. (SC2->C2_FILIAL ==ZZA->ZZA_FILIAL) .and. (Alltrim(SC2->C2_LOTE) == Alltrim(ZZA->ZZA_LOTE))
					If Empty(SC2->C2_DATRF)
						lOpFechada := .f.
					Endif
					DbSelectArea("SC2")
					DbSkip()        	
		  		Enddo
		    Endif
			DbSelectArea("SC2")
			DbCloseArea()	 		
	 		If lOpFechada
		 		RecLock("ZZA", .f.)
	   				ZZA->ZZA_ENVIA  := 'S' 
	   				ZZA->ZZA_DTENV  := dDatabase
	   				ZZA->ZZA_HENV   := Time()
	   				ZZA->ZZA_RENV   := Alltrim(cUserName)
				MsUnLock()
				cGet1Tr := Space(11) 
			Else
				Messagebox("Lote possui ordens de produção em aberto, encerre-as primeiro antes de Arquivar!! ","Atenção...",48)  			
			Endif
		Endif
  	Endif
    DbSelectArea("ZZA")
    DbSetOrder(1)

	oGet1Tr:SetFocus()
	
Return



/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fTrans40() - Transferência dos produtos para o armazem 40 projeto recebimento
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

User Function fTrans40()

Local aAuto 		:= {}
Local aItem			:= {}
Local aTrPallet 	:= {}  
Local cNumDoc 		:= NextNumero("SD3",2,"D3_DOC",.T.)
//Local lOk			:= .T.
Local nI 			:= 0
Local nSaldo        := 0
Local nOpcAuto		:= 3 	// Indica qual tipo de ação será tomada (Inclusão/Exclusão)
Local cLote	 		:= ""	
Local _cErrPallet 	:= ""
Local cStrErr       := ""
//Local _texto 		:= "" 
Local cQry1     	:= ""
Local cProduto 			// Cod Produto
Local cDescProd 		// Descrição do produto
Local cUM 				// Unidade de medida
Local nQuant 			// Quantidade
Local nY
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.
Private lCancelaTran:= .F.

	cQry1 := " "
	cQry1 += " SELECT ZZL.ZZL_PRODUT AS 'B1_COD', SB1.B1_DESC, B1_UM, B2_LOCAL, SUM(CAST(SUBSTRING(ZZL.ZZL_LOCALI,(PATINDEX( '%=%' , ZZL.ZZL_LOCALI )+1),6) AS FLOAT)) AS 'TOTAL ENDEREÇADO', B2_QATU "
	cQry1 += " FROM ZZL010 ZZL WITH (NOLOCK)  "
	cQry1 += " LEFT OUTER JOIN SB1010 SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = ZZL.ZZL_FILIAL AND SB1.B1_COD = ZZL.ZZL_PRODUT AND SB1.D_E_L_E_T_ = ''  "
	cQry1 += " LEFT OUTER JOIN SB2010 SB2 WITH (NOLOCK) ON SB2.B2_FILIAL = ZZL.ZZL_FILIAL AND SB2.B2_COD = ZZL.ZZL_PRODUT AND SB2.D_E_L_E_T_ = ''  "
	cQry1 += " WHERE (ZZL.ZZL_FILIAL='010101') AND (ZZL.D_E_L_E_T_='') AND SB1.B1_TIPO ='MP' AND LEN(ZZL_PRODUT)<12 AND  "
	cQry1 += " SB2.B2_LOCAL = CASE WHEN SUBSTRING(ZZL_LOCALI,1,1)IN('R','r') THEN '01' ELSE CASE WHEN SUBSTRING(ZZL_LOCALI,1,1)IN('T','t') THEN '10' END END "
	cQry1 += " AND SUBSTRING(ZZL_LOCALI,1,1)IN('T','t') --AND ZZL_PRODUT ='0003           ' "
	cQry1 += " GROUP BY ZZL.ZZL_PRODUT, SB1.B1_DESC, B2_LOCAL, B2_QATU, B1_UM "
	cQry1 += " ORDER BY B2_LOCAL, ZZL_PRODUT "


	TCQuery cQry1 ALIAS "TCQ" NEW
 	DbSelectArea("TCQ")
  	DbGoTop()
   	aTrPallet 	:= {} 

	While !(TCQ->(EOF()))  
  		aAdd(aTrPallet, { 'CRIAÇÃO ARM. 15' , TCQ->B1_COD ,TCQ->B2_QATU, TCQ->B1_DESC, TCQ->B1_UM, TCQ->B2_LOCAL, '15' })
     	DbSelectArea("TCQ")
	  	DbSkip()
    Enddo

 	DbSelectArea("TCQ")
	DbCloseArea()
   
	lTemSaldo 	 := .t.
	lCancelaTran := .f.	
  
	For nY:= 1 To Len(aTrPallet)     
   	    DbSelectArea("SB2")
		DbSetorder(1)
		DbSeek(xFilial("SB2")+(aTrPallet[nY][2])+(aTrPallet[nY][6]))
	 	If Found()
			nSaldo := SaldoSb2()
		Endif
   		If (aTrPallet[nY][3] > nSaldo)
   			 cStrErr    += "Falta de Saldo Disponível. Verifique !!"+Chr(13)+Chr(10)      	
   			_cErrPallet += aTrPallet[nY][2]+' Motivo --> '+cStrErr+Chr(10)+Chr(13)
   			lTemSaldo   := .f.
   		Endif	
	Next nY			
        
		
	If lTemSaldo		

        Begin Transaction

			For nI:= 1 To Len(aTrPallet)     
	    
	       		cObs      := Alltrim(aTrPallet[nI][1])
				cProduto  := aTrPallet[nI][2]
				nQuant 	  := aTrPallet[nI][3]
				cDescProd := aTrPallet[nI][4]
				cUm 	  := aTrPallet[nI][5]
				cLocOri   := aTrPallet[nI][6]
				cLocDest  := aTrPallet[nI][7]
				aAuto     := {}
				aItem     := {}
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
				aadd(aItem,criavar("D3_OBSERVA"))	//D3_OBSERVA  				
	  	    	
				DbSelectArea("SB2")
				DbSetOrder(1)
				DbGotop()
				If !SB2->(DBSEEK(xFilial("SB2")+cProduto+cLocDest ))
					CriaSB2( cProduto, cLocDest)
				Endif
				PutMv("MV_ESTNEG" , "S")                                                                      
       		
				lMsErroAuto := .f.
				aadd(aAuto,aItem)
				MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)				
	
				If lMsErroAuto			
					cStrErr := MemoLine( MemoRead( NomeAutoLog() ), 30, 1)
					If "MA240NEGAT" $ cStrErr
       	    	    	cStrErr := "SALDO DO PRODUTO -> "+cProduto+" INSUFICIENTE OU RESERVADO !" 
					Endif
					_cErrPallet += cProduto+' Motivo --> '+cStrErr+Chr(10)+Chr(13)
    	   	    	lCancelaTran := .T.
					MostraErro()		
				Endif

			Next nI
   		
			If !lCancelaTran 

			Else
        		DisarmTransaction() 
				MostraErro()		
			Endif

		End Transaction		
	Endif
    PutMv("MV_ESTNEG" , "N")  

    If !Empty(_cErrPallet)
    	Messagebox("As transferências dos seguintes PRODUTOS não foram realizadas : "+Chr(10)+Chr(13)+_cErrPallet,"Atenção...",48)    
    Else
		Messagebox("Tranferência do(s) PRODUTOS realizada(s) com sucesso !! ","Atenção...",48)    		
    Endif
    
   
Return
