#INCLUDE "VKEY.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"                                                                       
#include "tbiconn.ch"
#include "error.ch"
#include "topconn.ch"

#DEFINE ZSTR0001 "Não Existem transferências a serem confirmadas"
#DEFINE ZSTR0002 "Atenção!!!"
#DEFINE ZSTR0003 "Chamada do Programa Invalida."
#DEFINE ZSTR0004 "Aprovação das Transferências"
#DEFINE ZSTR0005 "&Filtrar"
#DEFINE ZSTR0006 "&Baixar/Sair"

#DEFINE _D3_FILIAL	1
#DEFINE _D3_COD		2
#DEFINE _D3_LOCAL	3
#DEFINE _D3_TIPO	4
#DEFINE _D3_DOC		5
#DEFINE _D3_QUANT	6
#DEFINE _D3_CLASSI	7
#DEFINE _D3_OBSERV	8 
#DEFINE _D3_USUAR	09            
#DEFINE _D3_EMISSAO	10
#DEFINE _D3_NUMSEQ	11
#DEFINE _FIELDS		12
//#DEFINE _R_E_C_N_O_	AT_FIELDS	//Deixar AT_R_E_C_N_O_ sempre como ultimo campo do aListBox
#DEFINE _R_E_C_N_O_	12	//Deixar AT_R_E_C_N_O_ sempre como ultimo campo do aListBox

#IFNDEF VAR_NAME_LEN
	#DEFINE VAR_NAME_LEN	50
#ENDIF	


/*/
+------------------------------------------------------------------------------------+
| Função | BRAPTRANS | Autor | André Maester 					|Data 13/07/2016 	 |
+------------------------------------------------------------------------------------+
| Descrição | Rotina criada para aprovação das transferências entre almoxarifados    |
|			  Na intenção de controlar as transferências e de quem recebeu o produto |
| 			  confirme o recebimento, ou solicite o estorno via Workflow   		     |
+--- --------------------------------------------------------------------------------+
| Uso | SIGAPCP |																	 |
|+-----------------------------------------------------------------------------------+
/*/                            


User Function BRAPTRANS()

	Local lRet			:= .F.
	Local nVarNameLen	:= SetVarNameLen( VAR_NAME_LEN )		//Para Poder usar Nomes Longos
	Local cQry          := ""
	Private cLocal 		:= ""
	Private aListBox	:= {}
	Private nATListBox	:= 0 
  	Private cRotina     := "BRAPTRAN"
	Private AT_FIELDS   :=""
	//Set Key VK_F4 TO MT010F4()
    SetKey( VK_F4, { || MT010F4() } )

 	If !u_VldAcesso(cRotina)
			Messagebox("Acesso não autorizado!---->"+cRotina,"Atenção...",48) 
     	Return 
  	Endif 	
	cLocal := Posicione("SZH", 1, xFilial("SZH")+__cUserId, "ZH_LOCAPRO")
	
	cQry := ""
	cQry += " SELECT D3_FILIAL, D3_COD, D3_LOCAL, D3_QUANT, D3_TIPO, D3_DOC, D3_USUARIO, D3_OBS, D3_XAPROVA, D3_EMISSAO, R_E_C_N_O_ , D3_NUMSEQ "
	cQry += " FROM "+RetSqlname("SD3")+" SD3  WITH(NOLOCK) "
	cQry += " WHERE D3_FILIAL ='"+xFilial("SD3")+"'"
	cQry += " AND D3_ESTORNO <>'S' " 
	cQry += " AND SD3.D_E_L_E_T_ ='' " 
	cQry += " AND D3_TM ='499' " 
	If Len(Alltrim(cLocal)) >0
		cQry += " AND D3_LOCAL IN('"+Alltrim(cLocal)+"') "
	Else
	   //	cQry += " AND D3_LOCAL IN('R1','R2','01','02','10','20','70') " 
	   	cQry += " AND D3_LOCAL IN('01','10','70') " 
	Endif
	cQry += " AND D3_USUARIO <>'' "  
	cQry += " AND D3_XAPROVA = '' "
	cQry += " AND D3_CF ='DE4' "  
	cQry += " AND D3_USUARIO NOT LIKE '"+cUserName+"'"
	cQry += " AND D3_EMISSAO >='"+Alltrim(GETMV("MV_XDTAPRO"))+"'"
	cQry += " ORDER BY R_E_C_N_O_ "

    TCQuery cQry ALIAS "TCQ" NEW
    DbSelectArea("TCQ")

   	If eof()
    	Aviso("Aviso","Não existem transferências pendentes de classificação para este almoxarifado.",{"OK"})      
    	DbSelectArea("TCQ")
    	DbCloseArea()
    	Return	    
   	EndIf

   	DbSelectArea("TCQ")
   	DbCloseArea()	

	BEGIN SEQUENCE
		Private aCTTBloqcBox
		Private aCTTBloqBox		:= Sx3Box2Arr( "D3_XAPROVA" , @aCTTBloqcBox )
		Private cCTTBloqCBox	:= Space( GetSx3Cache( "D3_XAPROVA" , "X3_TAMANHO" ) )

		//Private aLocBox			:= {'  ','01','02','R1','10','20','R2','70'}
		Private aLocBox			:= {'  ','01','10','70'}
		Private cLocCBox		:= Space( GetSx3Cache( "D3_LOCAL" , "X3_TAMANHO" ) )

		
		Private lCTTBloqFBox	:= .F.
		Private oListBox

		lRet := BuildLBoxArray( .F. )
		If !( lRet )
			MsgInfo( ZSTR0001 , ZSTR0002 )
			BREAK
		Endif	

		lRet := EditList()

	END SEQUENCE

	SetVarNameLen( nVarNameLen )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AVALF4   ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 01/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada da funcao F4                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum 	                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA241                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MT010F4()

	Local cFilBkp := xFilial("SB1")
	//Set Key VK_F4 TO
    SetKey( VK_F4, { || } )
	If FWModeAccess("SB1")=="E"
		cFilAnt := SB1->B1_FILIAL
	EndIf	
	MaViewSB2(SD3->D3_COD)
	cFilAnt := cFilBkp
	//Set Key VK_F4 TO MT010F4()
    SetKey( VK_F4, { || MT010F4() } )
Return Nil


/*/
	Funcao:		EditList
	Descricao:	uso de GetCellRect para permitir a Edicao de uma Celula do Browse ListBox (TWBrowse)
	Sintaxe:	EditList()
/*/
Static Function EditList()

	Local aAdvSize
	Local aObjSize
	Local aObjCoords
	Local aInfoAdvSize
	Local aCTTHeader
	Local bCTTBloqLBoxWhen
	Local bCTTBloqComboBoxSetGet
	Local bCTTBloqCheckBoxSetGet
	Local oDlg
	Local oPanel
	Local oGrpListBox
	Local oGrpFiltraCTTBloq
	Local oBtnSair
	Local oCTTBloqCBox
	Local oCTTBloqChkBox
	//Local bATCTTBoq
	//Local nATCTTBloqBox
	//Local bATSetor
	//Local nATSetorBox
	

	IF !( IsInCallStack( "EditList" ) )
		MsgInfo( ZSTR0003 , ZSTR0002 )	//"Chamada do Programa Invalida."###"Atenção!"
		Return( .F. )
	EndIF

	//Define a Acao de bLine para a Coluna D3_XAPROVA
	//LGS#20200128 - Ajuste de variáveis definidas
	//bATCTTBoq			:= { ||	IF(	( ( nATCTTBloqBox := aScan( aCTTBloqcBox , {|e| ( e[2] == aListBox[ oListBox:nAT ][ IIF(Trim(AT_D3_CLASSI)=='',0,AT_D3_CLASSI) ] ) } ) ) > 0 ), aCTTBloqBox[nATCTTBloqBox], "" )}
	//bATCTTBoq			:= { ||	IF(	( ( nATCTTBloqBox := aScan( aCTTBloqcBox , {|e| ( e[2] == aListBox[ oListBox:nAT ][ IIF(Trim(_D3_CLASSI)=='',0,_D3_CLASSI) ] ) } ) ) > 0 ), aCTTBloqBox[nATCTTBloqBox], "" )}
	//bATCTT				:= { ||	IF(	( ( nATCTTBox     := aScan( aCTTBloqcBox , {|e| ( e[2] == aListBox[ oListBox:nAT ][ IIF(Trim(AT_D3_CLASSI)=='',0,AT_D3_CLASSI) ] ) } ) ) > 0 ), aCTTBloqBox[nATCTTBloqBox], "" )}			
	//bATCTT				:= { ||	IF(	( ( nATCTTBox     := aScan( aCTTBloqcBox , {|e| ( e[2] == aListBox[ oListBox:nAT ][ IIF(Trim(_D3_CLASSI)=='',0,_D3_CLASSI) ] ) } ) ) > 0 ), aCTTBloqBox[nATCTTBloqBox], "" )}

	
	aCTTHeader			:= {	GetX3Titulo("D3_FILIAL")	,;
								GetX3Titulo("D3_COD")		,;
								GetX3Titulo("D3_LOCAL")		,;
								GetX3Titulo("D3_TIPO")		,;
								GetX3Titulo("D3_DOC")		,;
								GetX3Titulo("D3_QUANT")		,;
								GetX3Titulo("D3_XAPROVA")	,;
								GetX3Titulo("D3_OBS")		,;
								GetX3Titulo("D3_USUARIO")	,;
								GetX3Titulo("D3_EMISSAO")	,;
								GetX3Titulo("D3_NUMSEQ")	,;							
							    GetX3Titulo("R_E_C_N_O_")	}									

	//LGS#20200128 - Ajuste de variáveis definidas
	//bCTTBloqLBoxWhen		:= { || Empty( aListBox[ oListBox:nAT ][ AT_D3_CLASSI  ] ) }
	bCTTBloqLBoxWhen		:= { || Empty( aListBox[ oListBox:nAT ][ _D3_CLASSI  ] ) }
	bCTTBloqComboBoxSetGet	:= { |cSetGet| IF( PCount() > 0 , cCTTBloqCBox := cSetGet, cCTTBloqCBox ) }
	bCTTBloqCheckBoxSetGet	:= { |lSetGet| IF( PCount() > 0 , lCTTBloqFBox := lSetGet , lCTTBloqFBox ) }

	//Obtem as Coordenadas para a Janela
	aAdvSize		:= MsAdvSize( .F. , .F. )
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aObjCoords		:= {}
	aObjSize		:= {}
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aAdd( aObjCoords , { 015 , 035 , .T. , .F. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	DEFINE MSDIALOG oDlg TITLE ZSTR0004 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL //"Centros de Custo"
	
			@ 000,000 MSPANEL oPanel OF oDlg
			oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
			oGrpListBox	:= TGroup():New(	aObjSize[1][1],	;//<nTop>
											aObjSize[1][2],	;//<nLeft>
											aObjSize[1][3],	;//<nBottom>
											aObjSize[1][4],	;//<nRight>
											ZSTR0004,		;//<cLabel>###"Centros de Custo"
											oPanel,			;//<oWnd>
											CLR_BLACK,		;//<nClrFore>
											CLR_WHITE,		;//<nClrBack>
											.T.,			;//<.lPixel.>
											.T.				;//[<.lDesign.>]
										) 

			oListBox 			:=	TWBrowse():New(		aObjSize[1][1]+8,		;//<nRow>
   														aObjSize[1][2]+2,		;//<nCol>
			    	 									aObjSize[1][4]-5,		;//<nWidth>
    	 												aObjSize[1,3]-10,		;//<nHeigth>
      													NIL,					;//[\{|| \{<Flds> \} \}]
			      										aCTTHeader,				;//[\{<aHeaders>\}]
      													{ 25 , 65 , 35 , 20, 50, 40, 090, 170, 70, 40,0, 20},	;//[\{<aColSizes>\}]
		      											oGrpListBox,			;//<oDlg>
			    	  									NIL,					;//<(cField)>
	      												NIL,					;//<uValue1>
			      										NIL,					;//<uValue2>
						      							NIL,					;//[<{uChange}>]
			      										NIL,                    ;//[\{|nRow,nCol,nFlags|<uLDblClick>\}]
      													NIL,					;//[\{|nRow,nCol,nFlags|<uRClick>\}]
			    	  									NIL,					;//<oFont>
	    					  							NIL,					;//<oCursor>
				      									NIL,					;//<nClrFore>
    						  							NIL,					;//<nClrBack>
			      										NIL,					;//<cMsg>###"Centros de Custo"
						      							.T.,					;//<.update.>
			      										NIL,					;//<cAlias>
      													.T.,					;//<.pixel.>
						      							bCTTBloqLBoxWhen,		;//<{uWhen}>
      													.T.,					;//<.design.>
			      										NIL,					;//<{uValid}>
		      											NIL,					;//<{uLClick}>
			      										NIL						;//[\{<{uAction}>\}]
      									)

			oListBox:SetArray(aListBox)
			oListBox:bLDblClick := { |nRow,nCol,nFlags| Iif(oListBox:ColPos==8,GrvSugest(@aListBox,@oListBox,oListBox:nAt,oListBox:ColPos),EditLBoxCol(@nRow,@nCol,@nFlags)) }
			/*oListBox:bLine		:= { ||SD3->( MsGoto( aListBox[ oListBox:nAT ][ AT_R_E_C_N_O_  ] ) ),;
										{	aListBox[ oListBox:nAT ][ _D3_FILIAL 	],	;
										    aListBox[ oListBox:nAT ][ _D3_COD  	],	;
											aListBox[ oListBox:nAT ][ _D3_LOCAL 	],	;
											aListBox[ oListBox:nAT ][ _D3_TIPO 	],	;
											aListBox[ oListBox:nAT ][ _D3_DOC  	],	;
											aListBox[ oListBox:nAT ][ _D3_QUANT  	],	;
		  								    aListBox[ oListBox:nAT ][ _D3_CLASSI 	],	;
		  								    aListBox[ oListBox:nAT ][ _D3_OBSERV  ],	;
		  								    aListBox[ oListBox:nAT ][ _D3_USUAR	],	; 
		  								    aListBox[ oListBox:nAT ][ _D3_EMISSAO	],	; 		  								    
		  								    aListBox[ oListBox:nAT ][ _D3_NUMSEQ	],	; 	
		  									aListBox[ oListBox:nAT ][ _R_E_C_N_O_ ]	};
		  																		     }*/
            oListBox:bLine		:= { ||SD3->( MsGoto( aListBox[ oListBox:nAT ][ _R_E_C_N_O_  ] ) ),;
										{	aListBox[ oListBox:nAT ][ _D3_FILIAL 	],	;
										    aListBox[ oListBox:nAT ][ _D3_COD  	],	;
											aListBox[ oListBox:nAT ][ _D3_LOCAL 	],	;
											aListBox[ oListBox:nAT ][ _D3_TIPO 	],	;
											aListBox[ oListBox:nAT ][ _D3_DOC  	],	;
											aListBox[ oListBox:nAT ][ _D3_QUANT  	],	;
		  								    aListBox[ oListBox:nAT ][ _D3_CLASSI 	],	;
		  								    aListBox[ oListBox:nAT ][ _D3_OBSERV  ],	;
		  								    aListBox[ oListBox:nAT ][ _D3_USUAR	],	; 
		  								    aListBox[ oListBox:nAT ][ _D3_EMISSAO	],	; 		  								    
		  								    aListBox[ oListBox:nAT ][ _D3_NUMSEQ	],	; 	
		  									aListBox[ oListBox:nAT ][ _R_E_C_N_O_ ]	};
		  																		     }
            //LGS#20200128 - Ajuste de variáveis definidas
			/*oGrpFiltraCTTBloq	:= TGroup():New(;
													( aObjSize[2,1] ),						;//<nTop>
													( ( aObjSize[2,4] / 100 ) *30 ),		;//<nLeft>
													( aObjSize[2,3] - 3 ),					;//<nBottom>
													( ( aObjSize[2,4]/100 * 60 ) - 2 ),		;//<nRight>
													ZSTR0005+": "+aCTTHeader[AT_D3_LOCAL],	;//<cLabel>###"Filtar"
													oPanel,									;//<oWnd>
													CLR_BLACK,								;//<nClrFore>
													CLR_WHITE,								;//<nClrBack>
													.T.,									;//<.lPixel.>
													.T.										;//[<.lDesign.>]
												)*/
												 
            oGrpFiltraCTTBloq	:= TGroup():New(;
													( aObjSize[2,1] ),						;//<nTop>
													( ( aObjSize[2,4] / 100 ) *30 ),		;//<nLeft>
													( aObjSize[2,3] - 3 ),					;//<nBottom>
													( ( aObjSize[2,4]/100 * 60 ) - 2 ),		;//<nRight>
													ZSTR0005+": "+aCTTHeader[_D3_LOCAL],	;//<cLabel>###"Filtar"
													oPanel,									;//<oWnd>
													CLR_BLACK,								;//<nClrFore>
													CLR_WHITE,								;//<nClrBack>
													.T.,									;//<.lPixel.>
													.T.										;//[<.lDesign.>]
												)
			oCTTBloqCBox		:= TComboBox():New(;
														aObjSize[2,1]+15,							;//<nRow>
														( ( ( aObjSize[2,4] /100 ) *30 ) + 10 ),	;//<nCol>
														bCTTBloqComboBoxSetGet,						;//bSETGET(<cVar>)
														aLocBox,									;//<aItems>
														80,											;//<nWidth>
														50,											;//<nHeight>
														oGrpFiltraCTTBloq,							;//<oWnd>
														NIL,										;//<nHelpId>
														NIL,										;//[{|Self|<uChange>}]
														{ || EvalFilter() },						;//<{uValid}>
														NIL,										;//<nClrText>
														NIL,										;//<nClrBack>
														.T.,										;//<.pixel.>
														NIL,										;//<oFont>
														NIL,										;//<cMsg>
														.T.,										;//<.update.>
														NIL,										;//<{uWhen}>
														.T.,										;//<.design.>
														NIL,										;//<acBitmaps>
														NIL,										;//[{|nItem|<uBmpSelect>}]
														NIL,										;//???
														cCTTBloqCBox								;//<(cVar)>
													)

			oCTTBloqChkBox		:= TCheckBox():New(;
														( aObjSize[2,1]+15 ),				;//<nRow>
														( aObjSize[2,4]/100*30 )+10+80,		;//<nCol>
														ZSTR0005,							;//<cCaption>###"Filtrar"
														bCTTBloqCheckBoxSetGet,				;//[bSETGET(<lVar>)]
														oGrpFiltraCTTBloq,					;//<oWnd>
														044,								;//<nWidth>
														008,								;//<nHeight>
														NIL,								;//<nHelpId>
														{ || EvalFilter(.T.) },				;//[<{uClick}>]
														NIL,								;//<oFont>
														NIL,								;//<{ValidFunc}>
														CLR_BLACK,							;//<nClrFore>
														CLR_WHITE,							;//<nClrBack>
														.T.,								;//<.design.>
														.T.,								;//<.pixel.>
														NIL,								;//<cMsg>	
														NIL,								;//<.update.>
														NIL									;//<{WhenFunc}>
													 )	

			oBtnSair			:= TButton():New(;
														( aObjSize[2,1] + 4  ),		;//<nRow>
														( aObjSize[2,4] - 48 ),		;//<nCol>
														ZSTR0006,					;//<cCaption>###"&Sair"
														oPanel,						;//<oWnd>
														{ || BrClose( oDlg ) },	;//<{uAction}>
														048,						;//<nWidth>
														028,						;//<nHeight>
														NIL,						;//<nHelpId>
														NIL,						;//<oFont>
														NIL,						;//<.default.>
														.T.,						;//<.pixel.>
														.T.,						;//<.design.>
														NIL,						;//<cMsg>
														NIL,						;//<.update.>
														NIL,                   		;//<{WhenFunc}>
														NIL,						;//<{uValid}>
														.F.							;//<.lCancel.>
												)

	ACTIVATE DIALOG oDlg CENTERED ON INIT ( oListBox:SetFocus() )

Return( .T. )

/*/
	Funcao:		BuildLBoxArray
	Autor:		Marinaldo de Jesus
	Data:		02/10/2011
	Descricao:	Carregar os dados em aListBox
	Sintaxe:	BuildLBoxArray( lFiltro )
/*/
Static Function BuildLBoxArray( lFiltro )

	Local aArea		:= GetArea()
	Local cAlias	:= GetNextAlias()
	Local cWhere	:= "" 

	aSize( aListBox , 0 )
	nATListBox := 0

	DEFAULT lFiltro	:= .F.

	cWhere	+= " AND "
	If Empty(Trim(cCTTBloqCBox))
		cWhere	+= " D3_ESTORNO <>'S' AND SD3.D_E_L_E_T_ ='' AND D3_TM ='499' AND D3_CF ='DE4' " 
		If Len(Alltrim(cLocal)) >0
			cWhere	+= " AND D3_LOCAL IN('"+Alltrim(cLocal)+"') "			
		Else
			//cWhere	+= " AND D3_LOCAL IN('01','02','10','20','R1','R2','70') "
			cWhere	+= " AND D3_LOCAL IN('01','10','70') "
		Endif
		cWhere	+= " AND D3_USUARIO <>'' AND D3_EMISSAO >='"+Alltrim(GETMV("MV_XDTAPRO"))+"'"
		cWhere	+= " AND D3_NUMSERI = '' AND D3_XAPROVA = '' AND D3_FILIAL ='"+xFilial("SD3")+"'" "
		cWhere	+= " AND D3_USUARIO NOT LIKE '"+cUserName+"'"
	Else
		cWhere	+= " D3_ESTORNO <>'S' AND SD3.D_E_L_E_T_ ='' AND D3_TM ='499' AND D3_CF ='DE4' " 
		If Len(Alltrim(cLocal)) >0
			cWhere	+= " AND D3_LOCAL IN('"+Alltrim(cLocal)+"') "			
		Else
			cWhere	+= " AND D3_LOCAL IN('"+cCTTBloqCBox+"') "
		Endif
		cWhere	+= " AND D3_USUARIO <>'' AND D3_EMISSAO >='"+Alltrim(GETMV("MV_XDTAPRO"))+"'"
		cWhere	+= " AND D3_NUMSERI = '' AND D3_XAPROVA = '' AND D3_FILIAL ='"+xFilial("SD3")+"'"
		cWhere	+= " AND D3_USUARIO NOT LIKE '"+cUserName+"'"
	EndIf	

	cWhere	:= "%"+cWhere+"%"

	BEGINSQL ALIAS cAlias
		%NoParser%
		SELECT 
			SD3.D3_FILIAL ,
			SD3.D3_COD    ,
			SD3.D3_LOCAL  ,
			SD3.D3_TIPO   ,  
			SD3.D3_DOC    ,   
			SD3.D3_XAPROVA,
			SD3.D3_QUANT  ,  
			SD3.D3_USUARIO,
			SD3.D3_OBS    ,
			SD3.D3_EMISSAO,
			SD3.D3_NUMSEQ ,
			SD3.R_E_C_N_O_ AS RECNO
		
		FROM
			%table:SD3% SD3	WITH (NOLOCK)
		WHERE (
			SD3.%NotDel%
		)	
			%exp:cWhere%
		ORDER BY
			SD3.D3_FILIAL,
			SD3.D3_DOC,
			SD3.D3_LOCAL,
			SD3.D3_COD
	ENDSQL

//IF ( nATListBox > 0 )

	While ( cAlias )->( !Eof() )
		++nATListBox
		//aAdd( aListBox , Array( AT_FIELDS ) )
		aAdd( aListBox , Array( _FIELDS ) )
		aListBox[ nATListBox ][ _D3_FILIAL 	] := ( cAlias )->D3_FILIAL
		aListBox[ nATListBox ][ _D3_COD 	] := ( cAlias )->D3_COD
		aListBox[ nATListBox ][ _D3_LOCAL   ] := ( cAlias )->D3_LOCAL
		aListBox[ nATListBox ][ _D3_TIPO   	] := ( cAlias )->D3_TIPO
		aListBox[ nATListBox ][ _D3_DOC   	] := ( cAlias )->D3_DOC
		aListBox[ nATListBox ][ _D3_QUANT   ] := ( cAlias )->D3_QUANT
		aListBox[ nATListBox ][ _D3_CLASSI  ] := ( cAlias )->D3_XAPROVA
		aListBox[ nATListBox ][ _D3_OBSERV  ] := ( cAlias )->D3_OBS
		aListBox[ nATListBox ][ _D3_USUAR   ] := ( cAlias )->D3_USUARIO
		aListBox[ nATListBox ][ _D3_EMISSAO ] := Substr(( cAlias )->D3_EMISSAO,7,2)+"/"+Substr(( cAlias )->D3_EMISSAO,5,2)+"/"+Substr(( cAlias )->D3_EMISSAO,1,4)
		aListBox[ nATListBox ][ _D3_NUMSEQ  ] := ( cAlias )->D3_NUMSEQ
		aListBox[ nATListBox ][ _R_E_C_N_O_ ] := ( cAlias )->RECNO
		( cAlias )->( dbSkip() )
	End While

	IF ( nATListBox == 0 )
	//Else
		++nATListBox
		//aAdd( aListBox , Array( AT_FIELDS ) )
		aAdd( aListBox , Array( _FIELDS ) )
		aListBox[ nATListBox ][ _D3_FILIAL  ] := Space( GetSx3Cache( "D3_FILIAL" , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ _D3_COD 	] := Space( GetSx3Cache( "D3_COD" 	 , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ _D3_LOCAL 	] := Space( GetSx3Cache( "D3_LOCAL"  , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ _D3_TIPO   	] := Space( GetSx3Cache( "D3_TIPO"   , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ _D3_DOC   	] := Space( GetSx3Cache( "D3_DOC"    , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ _D3_QUANT   ] := Space( GetSx3Cache( "D3_QUANT"  , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ _D3_CLASSI  ] := Space( GetSx3Cache( "D3_XAPROVA", "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ _D3_OBSERV  ] := Space( GetSx3Cache( "D3_OBS" 	 , "X3_TAMANHO" ) ) ///
		aListBox[ nATListBox ][ _D3_USUAR   ] := Space( GetSx3Cache( "D3_USUARIO", "X3_TAMANHO" ) ) ///
		aListBox[ nATListBox ][ _D3_EMISSAO ] := Space( GetSx3Cache( "D3_EMISSAO", "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ _D3_NUMSEQ  ] := Space( GetSx3Cache( "D3_NUMSEQ" , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ _R_E_C_N_O_ ] := 0
	EndIF


	(cAlias)->( dbCloseArea() )
	dbSelectArea("SD3")

	RestArea( aArea )

Return( ( nATListBox > 0 ) )
                                                                                                  	
/*/
	Funcao:		EditLBoxCol
	Autor:		Tiago Lucio
	Data:		22/05/2014
	Descricao:	Acao para bLDblClick do ListBox
	Sintaxe:	EditLBoxCol(nRow,nCol,nFlags) 
*/
Static Function EditLBoxCol(nRow,nCol,nFlags) 
	
	Local lEdit	:= .F.

	//LGS#20200128 - Ajuste de variáveis definidas
	//IF ( ( nATListBox > 0 ) .and. ( oListBox:ColPos == AT_D3_CLASSI  ) )
	IF ( ( nATListBox > 0 ) .and. ( oListBox:ColPos == _D3_CLASSI  ) )
		EditLBoxCBox(@oListBox,@aCTTBloqBox,@oListBox:ColPos)
		Eval( oListBox:bLine )
		/*IF SD3->( !Eof() .and. !Bof() )
			lEdit	:= SD3->( RecLock( "SD3" , .F. ) )
			IF ( lEdit )
				SD3->D3_XAPROVA	:= aListBox[ oListBox:nAT ][ AT_D3_CLASSI ]
				If 	SD3->D3_XAPROVA<>' '
				    If Trim(SD3->D3_XAPROVA)=='1'
				    	SD3->D3_XAPROVA:="1-Ok, Recebido '"+Substr(cUserName,1,25)+"'"				    
				    //Elseif Trim(SD3->D3_XAPROVA)=='2'
					//    SD3->D3_XAPROVA:="2-Nao Recebido '"+cUserName+"'"                
				    //Elseif Trim(SD3->D3_XAPROVA)=='3'
					//	SD3->D3_XAPROVA:="3-Mov. Errada (Estornar) '"+cUserName+"'"			    
				    EndIf
				EndIf
				SD3->( MsUnLock() )
			EndIF
		EndIF*/
	Endif
Return ( lEdit )



Static Function GrvSugest(aListBox, oListBox, nLin, nCol) 

    Local cRegist
    //Local i     
    
    //LGS#20200128 - Ajuste de variáveis definidas
    //If (oListBox:ColPos == AT_D3_OBSERV)
    If (oListBox:ColPos == _D3_OBSERV)
   		lEditCell(@aListBox,oListBox,"@!",nCol) 
	    cRegist := aListBox[nLin,nCol] 	
	    //If (oListBox:ColPos == AT_D3_OBSERV) .and. (!Empty(cRegist))
	    If (oListBox:ColPos == _D3_OBSERV) .and. (!Empty(cRegist))
	    	/*
	    	dbSelectArea("ZZR")
			ZZR->(dbSetOrder(3)) 	//ZZR_FILIAL, ZZR_OP, ZZR_LOCAL, ZZR_DOC, ZZR_DATA, R_E_C_N_O_, D_E_L_E_T_  
			ZZR->(dbSeek(xFilial("ZZR")+aListBox[nLin,03]+aListBox[nLin,05]+aListBox[nLin,08]))	                                    
     		IF ZZR->( !Eof() .and. !Bof() )
				ZZR->(RecLock("ZZR",.F.))
					ZZR->ZZR_REGIST	:= Alltrim(aListBox[nLin,nCol])
				ZZR->( MsUnLock() )
			Endif
			DbSelectArea("ZZR")
			DbCloseArea() */
		Endif
	Endif
Return 

/*/
	Funcao:		EvalFilter
	Autor:		Marinaldo de Jesus
	Data:		02/10/2011
	Descricao:	Filtro dos dados da ListBox
	Sintaxe:	EvalFilter()
/*/
Static Function EvalFilter( lRefresh )
	DEFAULT lRefresh	:= .F.
	IF (( lCTTBloqFBox ).or.( lRefresh ))
		BuildLBoxArray( .T. )
		oListBox:nAT	:= 1
		oListBox:Reset()
		oListBox:Refresh()
		oListBox:SetFocus()
	EndIF
Return( .T. )


Static Function BrClose (oDlg)
    Local nI
    Local cAprov 	 	:= ""
    Local cObserv	 	:= ""
	Local cRecno 	 	:= ""
	Local cQry   	 	:= ""
	Local _cErrTrans 	:= ""
	Local cStrErr    	:= ""
	Private cCusMed  	:= GetMv("MV_CUSMED")
	Private ACTBDIA     := ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o custo medio e' calculado On-Line               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If cCusMed == "O"
		Private nHdlPrv 			// Endereco do arquivo de contra prova dos lanctos cont.
		Private lCriaHeader := .T.	// Para criar o header do arquivo Contra Prova
		Private cLoteEst 			// Numero do lote para lancamentos do estoque
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona numero do Lote para Lancamentos do Faturamento     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SX5")
		SX5->(dbSeek(xFilial("SX5")+"09EST"))
		cLoteEst:=IIf(Found(),Trim(X5Descri()),"EST ")
		Private nTotal := 0 	// Total dos lancamentos contabeis
		Private cArquivo		// Nome do arquivo contra prova
	EndIf    

	For nI := 1 To Len(aListBox)
		//LGS#20200128 - Ajuste de variáveis definidas
		//cAprov := aListBox[nI][ AT_D3_CLASSI ]
		cAprov := aListBox[nI][ _D3_CLASSI ]
		If Alltrim(cAprov) <> ''
		    If Trim(cAprov)=='1'
		    	cAprov:="1-Ok, Recebido "+cUserName
				//cObserv := aListBox[nI][ AT_D3_OBSERV ]
				cObserv := aListBox[nI][ _D3_OBSERV ]
				If !Empty(cObserv)
				   	cObserv :=Alltrim(cObserv)+' - '+Time()
				EndIf
				//LGS#20200128 - Ajuste de variáveis definidas
	            //cRecno := aListBox[nI][ AT_R_E_C_N_O_ ]
	            cRecno := aListBox[nI][ _R_E_C_N_O_ ]
				cQry := " UPDATE "+RetSqlName("SD3")+" SET D3_XAPROVA ='"+cAprov+"' , D3_OBS ='"+cObserv+"' WHERE R_E_C_N_O_ = "+Str(cRecno)

				XXX := TCSQLEXEC(cQry)
	   		    If XXX <> 0
	           		cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
	           	 	MemoWrit(cNomArq, cQry)
	       		Endif
		    Elseif Trim(cAprov)=='2' .or. Trim(cAprov)=='3'
				If Trim(cAprov)=='2' 
				    cAprov:="2-Nao Recebido "+cUserName
					cTexto:= "Erro de Transferência. O produto informado na transferência não chegou até o almoxarifado informado."

				ElseIf Trim(cAprov)=='3' 
					cAprov="3-Mov. Errada "+cUserName
					cTexto:= "Erro de Transferência. Houve erro na transferência do produto abaixo relacionado. Produto trocado ou quantidade errada."

				Endif			
				// estorna e manda e-mail p/ os envolvidos

				DbSelectArea("SD3")
           		SD3->(dbSetOrder(8)	) //  D3_FILIAL, D3_DOC, D3_NUMSEQ, R_E_C_N_O_, D_E_L_E_T_ 
           		SD3->(dbSeek(xFilial("SD3")+aListBox[nI][5]+aListBox[nI][11]))
			            
		        If !(SD3->(eof())) .and. (xFilial("SD3") == SD3->D3_FILIAL) .and. (Alltrim(aListBox[nI][5]) == Alltrim(SD3->D3_DOC)) .and. (Alltrim(aListBox[nI][11]) == Alltrim(SD3->D3_NUMSEQ))
					If 	Trim(SD3->D3_ESTORNO)<>'S'	
						lTemSaldo :=.t.
						Begin Transaction
					   	    DbSelectArea("SB2")
							DbSetorder(1)
							DbSeek(xFilial("SB2")+(aListBox[nI][2])+(aListBox[nI][3]))
						 	If Found()
				           		If (aListBox[nI][6] > SB2->B2_QATU)
				           			 cStrErr   += "Falta de Saldo Disponível. !!"+Chr(13)+Chr(10)      	
				           			_cErrTrans += aListBox[nI][2]+' Local '+aListBox[nI][3]+' Motivo --> '+cStrErr+Chr(10)+Chr(13)
				           			lTemSaldo   := .f.
			    	       		Endif	
                    		Endif
                            If lTemSaldo 
								lMsErroAuto:=.F.	
								cTexto+= CHR(13)+CHR(10)+"Codigo produto:  "+SD3->D3_COD + " quantidade transferida:  "+Transform(SD3->D3_QUANT,"@E 99999.9999")
								cTexto+= CHR(13)+CHR(10)+"Local Destino :  "+SD3->D3_LOCAL
								cTexto+= CHR(13)+CHR(10)+"Transferido por: "+SD3->D3_USUARIO 
					            If Alltrim(aListBox[nI][8]) <> ''
									cTexto+= CHR(13)+CHR(10)+"Observação: "+aListBox[nI][8]           
				 				Endif
			 					cTexto+= CHR(13)+CHR(10)+"Estornado por: "+ Posicione("SZH", 1, xFilial("SZH")+__cUserId, "ZH_NOME")
								cAssunto := "ESTORNO DE TRANSFERENCIA: "+SD3->D3_DOC
                        	
	    	    	            lMsErroAuto:=.f.      
	        	    	        dbSelectArea("SD3")
	    		 				PutMv("MV_ESTNEG" , "S") 
		                	    dbselectarea("SD3")
	                        	YYY := A260Estorn("SD3",SD3->D3_NUMSEQ,5)
				    			PutMv("MV_ESTNEG" , "N") 
					   		    If !YYY 
					           		cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
 		                        	XXX := 'PROGRAMA BRAPTRANS - > A260Estorn("SD3",SD3->D3_NUMSEQ,5) - '+SD3->D3_NUMSEQ
					           	 	MemoWrit(cNomArq,XXX )
					       		Else
									DbSelectArea("SD3")
           							SD3->(dbSetOrder(8)	) //  D3_FILIAL, D3_DOC, D3_NUMSEQ, R_E_C_N_O_, D_E_L_E_T_ 
           							SD3->(dbSeek(xFilial("SD3")+aListBox[nI][5]+aListBox[nI][11]))
			            
							        If !(SD3->(eof())) .and. (xFilial("SD3") == SD3->D3_FILIAL) .and. (Alltrim(aListBox[nI][5]) == Alltrim(SD3->D3_DOC)) .and. (Alltrim(aListBox[nI][11]) == Alltrim(SD3->D3_NUMSEQ))
										If 	Trim(SD3->D3_ESTORNO)=='S'	
									
											//LGS#20200128 - Ajuste de variáveis definidas
											//cObserv := aListBox[nI][ AT_D3_OBSERV ]
											cObserv := aListBox[nI][ _D3_OBSERV ]
											If !Empty(cObserv)
											   	cObserv :=Alltrim(cObserv)+' - '+Time()
											EndIf
							        	    //cRecno := aListBox[nI][ AT_R_E_C_N_O_ ]
							        	    cRecno := aListBox[nI][ _R_E_C_N_O_ ]
											cQry := " UPDATE "+RetSqlName("SD3")+" SET D3_XAPROVA ='"+cAprov+"' , D3_OBS ='"+cObserv+"' WHERE R_E_C_N_O_ = "+Str(cRecno)
		                	
											XXX := TCSQLEXEC(cQry)
	
							   		    	If XXX <> 0
								           		cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
								           	 	MemoWrit(cNomArq, cQry)
						       				Endif
											HDMail(cAssunto,cTexto)
										Endif
									Endif
								Endif
							Else
								If Trim(cAprov)=='2' 
									cTexto:= "Falta de Saldo para estorno. O produto abaixo não chegou até o almoxarifado e não possui saldo para estorno. CORRIGIR URGENTE."
								ElseIf Trim(cAprov)=='3' 
									cTexto:= "Falta de Saldo para estorno. Houve erro na transferência do produto abaixo relacionado. Produto trocado ou quantidade errada. CORRIGIR URGENTE."
								Endif
								cTexto+= CHR(13)+CHR(10)+"Codigo produto:  "+SD3->D3_COD + " quantidade transferida:  "+Transform(SD3->D3_QUANT,"@E 99999.9999")
								cTexto+= CHR(13)+CHR(10)+"Local Destino :  "+SD3->D3_LOCAL
								cTexto+= CHR(13)+CHR(10)+"Transferido por: "+SD3->D3_USUARIO 
					            If Alltrim(aListBox[nI][8]) <> ''
									cTexto+= CHR(13)+CHR(10)+"Observação: "+aListBox[nI][8]           
				 				Endif
			 					cTexto+= CHR(13)+CHR(10)+"Tentativa de estorno por: "+ Posicione("SZH", 1, xFilial("SZH")+__cUserId, "ZH_NOME")
								cAssunto := "FALTA DE SALDO PARA ESTORNO DE TRANSFERENCIA INDEVIDA OU INCORRETA : "+SD3->D3_DOC

								HDMail(cAssunto,cTexto)
							Endif
						End Transaction
					Endif
                Endif
		    EndIf
		EndIf				
	Next
    If !Empty(_cErrTrans)
	   	Messagebox("O estorno dos seguintes produtos não foram foram realizados : "+Chr(10)+Chr(13)+_cErrTrans,"Atenção...",48)    
	Endif

	oDlg:End()

Return()


Static FUNCTION HDMail(cAssunto,cTexto)

	Local cPara,cCC,cArquivo

	cPara 	 :="pcp@brasilux.com.br"
	cCC      :=""
	cArquivo := ''
	U_EnvMail(cAssunto,cTexto,cPara,cCC,cArquivo)

Return()


/*/
	Funcao:		EditLBoxCBox
	Autor:		Marinaldo de Jesus
	Data:		02/10/2011
	Descricao:	Permite Adicionar um ComboBox Editavel em uma ListBox
	Sintaxe:	EditLBoxCBox( oListBox , aCTTBloqBox , nColPos )
/*/
Static Function EditLBoxCBox( oListBox , aCTTBloqBox , nColPos )

	Local aDim

	Local bSetGet		:= { |u| IF( nATListBox > 0,														;
										IF( PCount() == 0,													;
											oListBox:aArray[oListBox:nAT][nColPos],							;
											oListBox:aArray[oListBox:nAT][nColPos] := u						;
										),																	;
									NIL																		;
								 )																			;
							}
	Local oDlg
	Local oComboBox

	GetCellRect( @oListBox , @aDim )	//Obtenho as Coordenadas da Celula
	DEFINE MSDIALOG oDlg FROM 0,0 TO 0,0 STYLE nOR( WS_VISIBLE , WS_POPUP ) PIXEL WINDOW oListBox:oWnd
		oComboBox		:= TComboBox():New(;
												0,										;//<nRow>
												0,										;//<nCol>
												bSetGet,								;//bSETGET(<cVar>)
												aCTTBloqBox,							;//<aItems>
												80,										;//<nWidth>
												50,										;//<nHeight>
												oDlg,									;//<oWnd>
												NIL,									;//<nHelpId>
												NIL,									;//[{|Self|<uChange>}]
												{ || .T. },								;//<{uValid}>
												NIL,									;//<nClrText>
												NIL,									;//<nClrBack>
												.T.,									;//<.pixel.>
												NIL,									;//<oFont>
												NIL,									;//<cMsg>
												.T.,									;//<.update.>
												NIL,									;//<{uWhen}>
												.F.,									;//<.design.>
												NIL,									;//<acBitmaps>
												NIL,									;//[{|nItem|<uBmpSelect>}]
												NIL,									;//???
												oListBox:aArray[oListBox:nAT][nColPos]	;//<(cVar)>
										)
		oComboBox:Move( -2 , -2 , ( ( aDim[ 4 ] - aDim[ 2 ] ) + 4 ) , ( ( aDim[ 3 ] - aDim[ 1 ] ) + 4 ) )
		oDlg:Move( aDim[1] , aDim[2] , ( aDim[4]-aDim[2] ) , ( aDim[3]-aDim[1] ) )
		@ 0, 0 BUTTON oBtn PROMPT "" SIZE 0,0 OF oDlg
		oBtn:bGotFocus	:= { || oDlg:nLastKey := VK_RETURN , oDlg:End(0) }
	ACTIVATE MSDIALOG oDlg

Return( NIL )

/*/
	Funcao:		GetX3Titulo
	Autor:		Marinaldo de Jesus
	Data:		25/09/2011
	Descricao:	Obtem X3_TITULO conforme Local
	Sintaxe:	GetX3Titulo( cField )
/*/
Static Function GetX3Titulo( cField )
	Local cX3Titulo := GetSx3Cache( cField , "X3_TITULO" )
	IF ( cX3Titulo == NIL )
		cX3Titulo	:= cField
	EndIF
Return( cX3Titulo )   


/*/
	Funcao:		BRAPFALT()
	Data:		11/10/2016
	Descricao:	WORKFLOW DIÁRIO INFORMANDO QUANTAS TRANSFERÊNCIAS FORAM REALIZADAS 
				E NÃO HOUVE ACEITE DO RESPONSÁVEL PELO ALMOXARIFADO
/*/
User Function BRAPFALT()

	Local cQry
    Local cPara    	:= "pcp@brasilux.com.br"
    Local cAssunto  := "PRODUTOS TRANSFERIDOS SEM ACEITE/RECUSA DO RESPONSÁVEL PELO ALMOXARIFADO"
    Local cMsg		:= ""

	cTmp := U_NovoCursor()  
	
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 

	cQry := ""
	cQry += " SELECT D3_FILIAL, D3_COD, D3_LOCAL, D3_QUANT, D3_TIPO, D3_DOC, "
	cQry += " D3_USUARIO, D3_XAPROVA, SUBSTRING(D3_EMISSAO,7,2)+'/'+SUBSTRING(D3_EMISSAO,5,2)+'/'+SUBSTRING(D3_EMISSAO,1,4) AS D3_EMISSAO  "
	cQry += " FROM "+RetSqlname("SD3")+" SD3  WITH(NOLOCK) "
	cQry += " WHERE D3_FILIAL ='"+xFilial("SD3")+"'"
	cQry += " AND D3_ESTORNO <>'S' " 
	cQry += " AND SD3.D_E_L_E_T_ ='' " 
	cQry += " AND D3_TM ='499' " 
	cQry += " AND D3_LOCAL IN('01','10','70') " 
	cQry += " AND D3_USUARIO NOT IN('Amaester','') "  
	cQry += " AND D3_XAPROVA = '' "
	cQry += " AND D3_CF ='DE4' "  
	cQry += " AND D3_EMISSAO BETWEEN('"+Alltrim(GETMV("MV_XDTAPRO"))+"') AND (GETDATE())"
	cQry += " ORDER BY D3_LOCAL, R_E_C_N_O_ "

 
	TcQuery cQry ALIAS (cTmp) NEW   
	DbSelectArea(cTmp)        
	

   	If (cTmp)->(eof()) //se o arquivo estiver vazio, sai da rotina
   		 (cTmp)->(DbCloseArea()) 
   		 Return()
   	EndIf		
   	dbselectarea(cTmp)
   
	/**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0' font size='1'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>FILIAL</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PRODUTO</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>LOCAL</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>TIPO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>QTDE</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>EMISSÃO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>USUARIO</th>"
	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	While !eof()
		cMsg+="<tr>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->D3_FILIAL)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->D3_COD)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->D3_LOCAL)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->D3_TIPO)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM((cTmp)->D3_QUANT,'@E 999,999,999.99')+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->D3_EMISSAO)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->D3_USUARIO)+"</td>"
		cMsg+="</tr>"
  
	    (cTmp)->(dbSkip())
  	End
  
  
	cMsg+="</table>"
  	cMsg+="</body>"
  	cMsg+="</html>" 
   
  	(cTmp)->(DbCloseArea()) 
    
    U_EnvMail(cAssunto, cMsg, cPara)
  	
  	RESET ENVIRONMENT

Return


/*
#IFDEF __DEBUG	//Se estiver definida, executo diretamente pela tela de abertura do sistema


	User Function dbgLBoxE()
	Return( EvalPrg( { || EdtLBoxCol() } , "01" , "010101" , "SIGAPCP" , "SD3" ) )


		Funcao:		EvalPrg
		Autor:		Marinaldo de Jesus
		Data:		02/10/2011
		Descricao:	Executa um Programa Diretamente
		Sintaxe:	EvalPrg( bExec , cEmp , cFil , cModulo , cTables )

	Static Function EvalPrg( bExec , cEmp , cFil , cModulo , cTables )

		Local nVarNameLen	:= SetVarNameLen( VAR_NAME_LEN )		//Para Poder usar Nomes Longos
	
		Local bWindowInit	:= { || Eval( bExec ) }
		Local lPrepEnv		:= ( IsBlind() .or. ( Select( "SM0" ) == 0 ) )
		
		Local uRet
	
		BEGIN SEQUENCE
	
			IF ( lPrepEnv )
				RpcSetType( 3 )
				PREPARE ENVIRONMENT EMPRESA( cEmp ) FILIAL ( cFil ) MODULO ( cModulo ) TABLES ( cTables )
				SetVarNameLen( VAR_NAME_LEN )
				InitPublic()
				SetsDefault()
			EndIF
	
				IF ( Type(  "oMainWnd" ) == "O" )
					uRet := Eval( bExec )
					BREAK
				EndIF
	
				bWindowInit	:= { || uRet := Eval( bExec ) }
				DEFINE WINDOW oMainWnd FROM 0,0 TO 0,0 TITLE OemToAnsi( FunName() )
			  	ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT ( Eval( bWindowInit ) , oMainWnd:End() )
			
			IF ( lPrepEnv )
				RESET ENVIRONMENT
			EndIF	
	
		END SEQUENCE

		SetVarNameLen( nVarNameLen )
	
	Return( uRet )
	
#ENDIF