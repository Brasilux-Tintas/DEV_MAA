#INCLUDE "VKEY.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"  
#include 'error.ch'
#include 'topconn.ch'

#ifndef PORTUGUESE
		#DEFINE ZSTR0001 "Não Existem Informações de Centros de Custo para a Empresa Selecionada"
		#DEFINE ZSTR0002 "Atenção!!!"
		#DEFINE ZSTR0003 "Chamada do Programa Invalida."
		#DEFINE ZSTR0004 "Ocorrencias OPs"
		#DEFINE ZSTR0005 "&Filtrar"
		#DEFINE ZSTR0006 "&Baixar/Sair"
#endif

#DEFINE AT_ZZR_COR		1
#DEFINE AT_ZZR_FIL   	2
#DEFINE AT_ZZR_OP		3
#DEFINE AT_ZZR_PRO  	4
#DEFINE AT_ZZR_LOC  	5
#DEFINE AT_ZZR_TIP		6
#DEFINE AT_ZZR_LOT		7
#DEFINE AT_ZZR_DOC		8
#DEFINE AT_ZZR_ITE		9
#DEFINE AT_ZZR_LPR  	10
#DEFINE AT_ZZR_QUA   	11
#DEFINE AT_ZZR_CLA   	12
#DEFINE AT_ZZR_SET	    13
#DEFINE AT_ZZR_REG   	14 ///
#DEFINE AT_ZZR_SUG   	15 ///
#DEFINE AT_ZZR_USU   	16
#DEFINE AT_ZZR_DAT   	17
#DEFINE AT_ZZR_HOR	    18
#DEFINE AT_FIELDS		19
#DEFINE AT_R_E_C_N  	AT_FIELDS	//Deixar AT_R_E_C_N_O_ sempre como ultimo campo do aListBox

#IFNDEF VAR_NAME_L
	#DEFINE VAR_NAME_L	50
#ENDIF	

/*/
	Funcao:		EdtLBoxCol
	Autor:		Tiago Lucio
	Data:		24/04/2014
	Descricao:	Rotina de classificação de ocorrencias PCP
	Sintaxe:	EdtLBoxCol()
/*/

/*/
+------------------------------------------------------------------------------------+
| Função | EdtLBoxColZZR | Autor |Tiago Lucio | www.chaus.com.br |Data 24/04/2014 	 |
+------------------------------------------------------------------------------------+
| Descrição | Rotina para criar tela de edição do tipo 	Colunas editaveis	         |
|				para classificação das ocorrencias								     |
| 																	    		     |
+--- --------------------------------------------------------------------------------+
| Uso | SIGAPCP |																	 |
|+-----------------------------------------------------------------------------------+
/*/                            


User Function EdtLBCZZR()
     Local lRet				:= .F.

     Local nVarNameLen		:= SetVarNameLen( VAR_NAME_L )		//Para Poder usar Nomes Longos

	Private aListBox		:= {}
	Private nATListBox		:= 0 
	
	//If !l010Auto
	Set Key VK_F4 TO MT010F4()
	//Set Key VK_F5 TO MostraEmp() //Em construção 
//EndIf
	
	dbSelectArea("ZZR")
	ZZR->(dbsetOrder(1))
	ZZR->(dbSeek(xFilial("ZZR")))
	
   IF ZZR->(eof())
    	Aviso("EdtLBoxColZZR.PRW","Este arquivo se encontra vazio, não é possivel abri-lo.",{"OK"})      
    	Return	    
   Else
   		While !(ZZR->(eof()))
   			If ZZR->ZZR_CLASSI <>'' .And. ZZR->ZZR_COR=='1' //Não foi efetivada a classificação.
   				RecLock("ZZR",.F.)
   				ZZR->ZZR_CLASSI:=''
				MsUnLock()
			EndIf		
   			ZZR->(dbSkip())
   		EndDO
   EndIf
	

	BEGIN SEQUENCE

		lRet := BuildLBoxArray( .F. )
		IF !( lRet )
			MsgInfo( ZSTR0001 , ZSTR0002 )	//"Não Existem Informações de Centro de Custo para a Empresa Selecionada"###"Atenção!!!"
			BREAK
		EndIF	

		Private aCTTBloqcBox
		Private aCTTBloqBox		:= Sx3Box2Arr( "ZZR_CLASSI" , @aCTTBloqcBox )
		Private cCTTBloqCBox	:= Space( GetSx3Cache( "ZZR_CLASSI" , "X3_TAMANHO" ) )
		
		Private aSETBloqcBox
		Private aSETBloqBox		:= Sx3Box2Arr( "ZZR_SETOR" , @aSETBloqcBox )
		Private cSETBloqCBox	:= Space( GetSx3Cache( "ZZR_SETOR" , "X3_TAMANHO" ) )
		
		Private aREGBloqcBox
		Private aREGBloqBox 	:= Sx3Box2Arr( "ZZR_REGIST" , @aSETBloqcBox )
		Private cREGBloqCBox	:= Space( GetSx3Cache( "ZZR_REGIST" , "X3_TAMANHO" ) )
        
		Private aSUGBloqcBox
		Private aSUGBloqBox 	:= Sx3Box2Arr( "ZZR_SUGEST" , @aSETBloqcBox )
		Private cSUGBloqCBox	:= Space( GetSx3Cache( "ZZR_SUGEST" , "X3_TAMANHO" ) )

		Private lCTTBloqFBox	:= .F.

		Private oListBox

		lRet := EditListBoxCol()

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
       Set Key VK_F4 TO

       If FWModeAccess("SB1")=="E"
          cFilAnt := SB1->B1_FILIAL
       EndIf
       MaViewSB2(ZZR->ZZR_ITEM)
       cFilAnt := cFilBkp
       Set Key VK_F4 TO MT010F4()
Return Nil

Static Function MostraEmp( )
       Local cLinha := " "
       Local cMsg   := " "
       
       DbSelectArea( "SD4" )
       SD4->( DbSetOrder( 2 ) )		//D4_FILIAL, D4_OP, D4_COD, D4_LOCAL, R_E_C_N_O_, D_E_L_E_T_
       SD4->( DbSeek( xFilial( "SD4" ) + ZZR->ZZR_OP ) )

       While !( SD4->( eof() ) ) .And. Trim( ZZR->ZZR_OP ) == Trim( SD4->D4_OP )
             IF Trim( ZZR->ZZR_OP ) == Trim( SD4->D4_OP ) .And.  Trim( ZZR->ZZR_ITEM ) == Trim( SD4->D4_COD ) .And. Trim( ZZR->ZZR_LOCPRO ) == Trim( SD4->D4_LOCAL )
                cLinha := " " + CHR(13) + CHR(10)

               cMsg := "------------------ " + Trim( SD4->D4_OP ) + " ------------------" + cLinha + cLinha
               cMsg += "Produto: " + Trim( SD4->D4_COD ) + cLinha
               cMsg += "Almoxarifado: " + Trim( SD4->D4_LOCAL ) + cLinha
               cMsg += "DT Empenho: " + DTOC(SD4->D4_DATA) + cLinha
               cMsg += "Sal. Empenho:  " + Str( SD4->D4_QUANT ) + cLinha
               cMsg += "Qtd. Empenho:  " + Str( SD4->D4_QTDEORI ) + cLinha
               cMsg += "Sequencia:  " + Trim( SD4->D4_TRT ) + cLinha
               Aviso( "Empenho do Item", cMsg, { "Sair" } )
	        EndIf
	        SD4->( dbSkip( ) )	
       EndDo
Return

/*/
	Funcao:		EditListBoxCol
	Autor:		Tiago Lucio/Chaus
	Data:		22/05/2014
	Descricao:	uso de GetCellRect para permitir a Edicao de uma Celula do Browse ListBox (TWBrowse)
	Sintaxe:	EditListBoxCol()
/*/
Static Function EditListBoxCol()
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
       Local bATCTTBoq
       Local nATCTTBloqBox
       Local bATSetor
       Local nATSetorBox
       IF !( IsInCallStack( "EditListBoxCol" ) )
          MsgInfo( ZSTR0003 , ZSTR0002 )	//"Chamada do Programa Invalida."###"Atenção!"
          Return( .F. )
       EndIF

       //Define a Acao de bLine para a Coluna ZZR_CLASSI
         //bATCTTBoq := { ||	IF(	( ( nATCTTBloqBox := aScan( aCTTBloqcBox , { |e| ( e[2] == aListBox[ oListBox:nAT ][ IIF(Trim(AT_ZZR_CLA)=='',0,AT_ZZR_CLA) ] ) } ) ) > 0 ), aCTTBloqBox[nATCTTBloqBox], "" ) }
         bATCTTBoq   := { | | nATCTTBloqBox := aScan( aCTTBloqcBox, { |e| e[2] == aListBox[ oListBox:nAT ][ AT_ZZR_CLA ] } ), If( nATCTTBloqBox  > 0, aCTTBloqBox[nATCTTBloqBox], "" ) }
         //bATCTT    := { ||	IF(	( ( nATCTTBox     := aScan( aCTTBloqcBox , { |e| ( e[2] == aListBox[ oListBox:nAT ][ IIF(Trim(AT_ZZR_CLA)=='',0,AT_ZZR_CLA) ] ) } ) ) > 0 ), aCTTBloqBox[nATCTTBloqBox], "" ) }			
         bATCTT      := { || nATCTTBox      := aScan( aCTTBloqcBox, { |e| e[2] == aListBox[ oListBox:nAT ][ AT_ZZR_CLA ] } ), Iif( nATCTTBox     > 0, aCTTBloqBox[nATCTTBloqBox], "" ) }
       //Define a Acao de bLine para a Coluna ZR_SETOR
         //bATSETBoq := { ||	IF(	( ( nATSetBloqBox := aScan( aSETBloqcBox , {|e| ( e[2] == aListBox[ oListBox:nAT ][ IIF(Trim(AT_ZZR_SET)=='',0,AT_ZZR_SET) ] ) } ) ) > 0 ),	aSTTBloqBox[nATSETBloqBox], "" )}
         bATSETBoq   := { || nATSetBloqBox  := aScan( aSETBloqcBox, { |e| e[2] == aListBox[ oListBox:nAT ][ AT_ZZR_SET ] } ), Iif( nATSetBloqBox > 0, aCTTBloqBox[nATSETBloqBox], "" ) }
         //bATSetor  := { || IF(	( ( nATSetorBox   := aScan( aSETBloqcBox , {|e| ( e[2] == aListBox[ oListBox:nAT ][ IIF(Trim(AT_ZZR_SET)=='',0,AT_ZZR_SET) ] ) } ) ) > 0 ),	aSETBloqBox[nATSETBloqBox],	"" )}										
         bATSetor    := { || nATSetorBox    := aScan( aSETBloqcBox, { |e| e[2] == aListBox[ oListBox:nAT ][ AT_ZZR_SET ] } ), Iif( nATSetorBox   > 0, aSETBloqBox[nATSETBloqBox], "" ) }
       ///
         //bATREGBoq := { || IF(	( ( nATREGBloqBox := aScan( cREGBloqcBox , {|e| ( e[2] == aListBox[ oListBox:nAT ][ Trim(AT_ZZR_REG)] ) } ) ) > 0 ), aREGBloqBox[nATREGBloqBox], "" )}
         bATREGBoq   := { || nATREGBloqBox  := aScan( cREGBloqcBox, { |e| e[2] == aListBox[ oListBox:nAT ][ AT_ZZR_REG ] } ), Iif( nATREGBloqBox > 0, aREGBloqBox[nATREGBloqBox], "" ) }
         //bATRREG   := { || IF(	( ( nATREGBox     := aScan( aREGBloqcBox , {|e| ( e[2] == aListBox[ oListBox:nAT ][ Trim(AT_ZZR_REG)] ) } ) ) > 0 ), aREGBloqBox[nATREGBloqBox], "" )}
         bATRREG     := { || nATREGBox      := aScan( aREGBloqcBox, { |e| e[2] == aListBox[ oListBox:nAT ][ AT_ZZR_REG ] } ), Iif( nATREGBox     > 0, aREGBloqBox[nATREGBloqBox], "" ) }
         //bATSUGBoq := { || IF(	( ( nATSUGBloqBox := aScan( cSUGBloqcBox , {|e| ( e[2] == aListBox[ oListBox:nAT ][ Trim(AT_ZZR_SUG)] ) } ) ) > 0 ), aSUGBloqBox[nATSUGBloqBox], "" )}
         bATSUGBoq   := { || nATSUGBloqBox  := aScan( cSUGBloqcBox, { |e| e[2] == aListBox[ oListBox:nAT ][ AT_ZZR_SUG ] } ), Iif( nATSUGBloqBox > 0, aSUGBloqBox[nATSUGBloqBox], "" ) }
         //bATRSUG   := { || IF(	( ( nATSUGBox     := aScan( aSUGBloqcBox , {|e| ( e[2] == aListBox[ oListBox:nAT ][ Trim(AT_ZZR_SUG)] ) } ) ) > 0 ), aSUGBloqBox[nATSUGBloqBox], "" )}			
         bATRSUG     := { || nATSUGBox      := aScan( aSUGBloqcBox, { |e| e[2] == aListBox[ oListBox:nAT ][ AT_ZZR_SUG ] } ), Iif( nATSUGBox     > 0, aSUGBloqBox[nATSUGBloqBox], "" ) }
       aCTTHeader			:= {;  
								"Status classi.",;
								"Filial",;
								GetX3Titulo("ZZR_OP")	,;
								GetX3Titulo("ZZR_PRODUT")	,;
								GetX3Titulo("ZZR_LOCAL")		,;
								GetX3Titulo("ZZR_TIPO")		,;
								GetX3Titulo("ZZR_LOTE")		,;
								GetX3Titulo("ZZR_DOC")	,;
								GetX3Titulo("ZZR_ITEM")	,;
								GetX3Titulo("ZZR_LOCPRO")	,;
								GetX3Titulo("ZZR_QUANT")	,;
								GetX3Titulo("ZZR_CLASSI")		,;
								GetX3Titulo("ZZR_SETOR")		,;
								GetX3Titulo("ZZR_REGIST")		,; ///
								GetX3Titulo("ZZR_SUGEST")		,; ///
								GetX3Titulo("ZZR_USUAR")		,;
								GetX3Titulo("ZZR_DATA")		,;
							    GetX3Titulo("ZZR_HORA"),	 ;   
							    GetX3Titulo("R_E_C_N_O_")	 ;
							    							}									

       bCTTBloqLBoxWhen		:= { || !Empty( aListBox[ oListBox:nAT ][ AT_ZZR_OP  ] ) }
       //bCTTBloqComboBoxSetGet	:= { |cSetGet| IF( PCount() > 0 , cCTTBloqCBox := SubStr( cSetGet , 1 , 1 ), cCTTBloqCBox ) }
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
	
			oGrpListBox	:= TGroup():New(;
											aObjSize[1][1],	;//<nTop>
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

			oListBox 			:=	TWBrowse():New(;
   														aObjSize[1][1]+8,		;//<nRow>
   														aObjSize[1][2]+2,		;//<nCol>
			    	 									aObjSize[1][4]-5,		;//<nWidth>
    	 												aObjSize[1,3]-10,		;//<nHeigth>
      													NIL,					;//[\{|| \{<Flds> \} \}]
			      										aCTTHeader,				;//[\{<aHeaders>\}]
      													{ 45 , 25 , 45 , 40, 10, 10, 20, 40, 40, 15, 20, 80, 60 },	;//[\{<aColSizes>\}]
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
			//oListBox:bLDblClick := Iif(oListBox:ColPos==14,lEditCell(aListBox,oListBox,"@!",EditLBoxCol(@nRow,@nCol,@nFlags)),nil)

			oListBox:bLDblClick := { |nRow,nCol,nFlags| Iif(oListBox:ColPos==14 .or. oListBox:ColPos==15,GrvSugest(@aListBox,@oListBox,oListBox:nAt,oListBox:ColPos),EditLBoxCol(@nRow,@nCol,@nFlags)) }
			//oListBox:bLDblClick := { |nRow,nCol,nFlags| Iif(oListBox:ColPos==14 .or. oListBox:ColPos==15,lEditCell(aListBox,oListBox,"@!",oListBox:ColPos),EditLBoxCol(@nRow,@nCol,@nFlags)) }
			//oListBox:bLDblClick := { |nRow,nCol,nFlags| EditLBoxCol(@nRow,@nCol,@nFlags) }
			oListBox:bLine		:= { ||ZZR->( MsGoto( aListBox[ oListBox:nAT ][ AT_R_E_C_N  ] ) ),;
										{;   
										    aListBox[ oListBox:nAT ][ AT_ZZR_COR  	],	;	
											aListBox[ oListBox:nAT ][ AT_ZZR_FIL    ],	;
										    aListBox[ oListBox:nAT ][ AT_ZZR_OP  	],	;
										    aListBox[ oListBox:nAT ][ AT_ZZR_PRO    ],	;
											aListBox[ oListBox:nAT ][ AT_ZZR_LOC 	],	;
											aListBox[ oListBox:nAT ][ AT_ZZR_TIP 	],	;
											aListBox[ oListBox:nAT ][ AT_ZZR_LOT  	],	;
											aListBox[ oListBox:nAT ][ AT_ZZR_DOC  	],	;
											aListBox[ oListBox:nAT ][ AT_ZZR_ITE  	],	;
											aListBox[ oListBox:nAT ][ AT_ZZR_LPR    ],	;
											aListBox[ oListBox:nAT ][ AT_ZZR_QUA    ],	;
		  								    aListBox[ oListBox:nAT ][ AT_ZZR_CLA    ],	;
		  								    aListBox[ oListBox:nAT ][ AT_ZZR_SET    ],	;
		  								    aListBox[ oListBox:nAT ][ AT_ZZR_REG    ],	; ///
		  								    aListBox[ oListBox:nAT ][ AT_ZZR_SUG    ],	; ///		  								    
		  									aListBox[ oListBox:nAT ][ AT_ZZR_USU    ],	;
		  									aListBox[ oListBox:nAT ][ AT_ZZR_DAT  	],	;
		  									aListBox[ oListBox:nAT ][ AT_ZZR_HOR  	],	;
		  									aListBox[ oListBox:nAT ][ AT_R_E_C_N    ]	;
		  																		     };
		  																		     }
		  																										  

			oGrpFiltraCTTBloq	:= TGroup():New(;
													( aObjSize[2,1] ),						;//<nTop>
													( ( aObjSize[2,4] / 100 ) *30 ),		;//<nLeft>
													( aObjSize[2,3] - 3 ),					;//<nBottom>
													( ( aObjSize[2,4]/100 * 60 ) - 2 ), 	;//<nRight>
													"Filtrar: "+aCTTHeader[AT_ZZR_CLA], 	;//<cLabel>###"Filtar"
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
														aCTTBloqBox,								;//<aItems>
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
														( aObjSize[2,4]/100*30 )+10+80,	;//<nCol>
														"Filtrar",							;//<cCaption>###"Filtrar"
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
														"&Sair",					;//<cCaption>###"&Sair"
														oPanel,						;//<oWnd>
														{ || CloseApp( oDlg ) },	;//<{uAction}>
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

	IF ( ( lFiltro ) .and. ( lCTTBloqFBox ) )
		cWhere	+= " AND "
		If Trim(cCTTBloqCBox)==''
			cWhere	+= "ZZR.ZZR_CLASSI='" + cCTTBloqCBox + "'"
		Else
			cWhere	+= "ZZR.ZZR_CLASSI LIKE '%" + cCTTBloqCBox + "%'"	
		EndIf	
	EndIF

	cWhere	:= "%"+cWhere+"%"

	BEGINSQL ALIAS cAlias
		%NoParser%
		SELECT 
			ZZR.ZZR_COR,   
			ZZR.ZZR_FILIAL,
			ZZR.ZZR_OP,
			ZZR.ZZR_PRODUT,
			ZZR.ZZR_LOCAL,  
			ZZR.ZZR_TIPO,   
			ZZR.ZZR_LOTE,
			ZZR.ZZR_DOC,  
			ZZR.ZZR_ITEM,
			ZZR.ZZR_LOCPRO,
			ZZR.ZZR_QUANT,     
			ZZR.ZZR_CLASSI,
            ZZR.ZZR_REGIST, ///
            ZZR.ZZR_SUGEST, ///
			ZZR.ZZR_SETOR,
			ZZR.ZZR_USUAR,                       
			ZZR.ZZR_DATA,     
			ZZR.ZZR_HORA,
			ZZR.R_E_C_N_O_ AS RECNO
		
		FROM
			%table:ZZR% ZZR	WITH (NOLOCK)
		WHERE (
			ZZR.%NotDel%
	   //	AND
		 //	ZZR.D_E_L_E_T_ = ' '
		)	
			%exp:cWhere%
		ORDER BY
			ZZR.ZZR_FILIAL,
			ZZR.ZZR_LOTE,
			ZZR.ZZR_OP
	ENDSQL

//IF ( nATListBox > 0 )

	While ( cAlias )->( !Eof() )
		++nATListBox
		aAdd( aListBox , Array( AT_FIELDS ) )
		aListBox[ nATListBox ][ AT_ZZR_COR 		]	:= IIF(( cAlias )->ZZR_COR=='1','Sem classificação', 'Classificada')
		aListBox[ nATListBox ][ AT_ZZR_FIL	 	]	:= ( cAlias )->ZZR_FILIAL
		aListBox[ nATListBox ][ AT_ZZR_OP 		]	:= ( cAlias )->( AllTrim(ZZR_OP) )
		aListBox[ nATListBox ][ AT_ZZR_PRO      ]	:= ( cAlias )->ZZR_PRODUT
		aListBox[ nATListBox ][ AT_ZZR_LOC   	]	:= ( cAlias )->ZZR_LOCAL
		aListBox[ nATListBox ][ AT_ZZR_TIP   	]	:= ( cAlias )->ZZR_TIPO
		aListBox[ nATListBox ][ AT_ZZR_LOT   	]	:= ( cAlias )->ZZR_LOTE
		aListBox[ nATListBox ][ AT_ZZR_DOC   	]	:= ( cAlias )->ZZR_DOC
		aListBox[ nATListBox ][ AT_ZZR_ITE   	]	:= ( cAlias )->ZZR_ITEM
		aListBox[ nATListBox ][ AT_ZZR_LPR      ]	:= ( cAlias )->ZZR_LOCPRO
		aListBox[ nATListBox ][ AT_ZZR_QUA  	]	:= ( cAlias )->ZZR_QUANT
		aListBox[ nATListBox ][ AT_ZZR_CLA      ]	:= ( cAlias )->ZZR_CLASSI
		aListBox[ nATListBox ][ AT_ZZR_SET   	]	:= ( cAlias )->ZZR_SETOR
		aListBox[ nATListBox ][ AT_ZZR_REG  	]	:= ( cAlias )->ZZR_REGIST ///
		aListBox[ nATListBox ][ AT_ZZR_SUG      ]	:= ( cAlias )->ZZR_SUGEST ///
		aListBox[ nATListBox ][ AT_ZZR_USU   	]	:= ( cAlias )->ZZR_USUAR
		aListBox[ nATListBox ][ AT_ZZR_DAT   	]	:= Substr(( cAlias )->ZZR_DATA,7,2)+"/"+Substr(( cAlias )->ZZR_DATA,5,2)+"/"+Substr(( cAlias )->ZZR_DATA,1,4)
		aListBox[ nATListBox ][ AT_ZZR_HOR   	]	:= ( cAlias )->ZZR_HORA
		aListBox[ nATListBox ][ AT_R_E_C_N     	]	:= ( cAlias )->RECNO
		( cAlias )->( dbSkip() )
	End

	IF ( nATListBox == 0 )
	//Else
		++nATListBox
		aAdd( aListBox , Array( AT_FIELDS ) )
		aListBox[ nATListBox ][ AT_ZZR_COR  	]	:= Space( GetSx3Cache( "ZZR_COR"  	, "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_ZZR_FIL  	]	:= Space( GetSx3Cache( "ZZR_FILIAL" , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_ZZR_OP 		]	:= Space( GetSx3Cache( "ZZR_OP" 	, "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_ZZR_PRO    	]	:= Space( GetSx3Cache( "ZZR_PRODUT" , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_ZZR_LOC   	]	:= Space( GetSx3Cache( "ZZR_LOCAL"  , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_ZZR_TIP   	]	:= Space( GetSx3Cache( "ZZR_TIPO"   , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_ZZR_LOT   	]	:= Space( GetSx3Cache( "ZZR_LOTE"   , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_ZZR_DOC 	 	]	:= Space( GetSx3Cache( "ZZR_DOC"   	, "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_ZZR_ITE   	]	:= Space( GetSx3Cache( "ZZR_ITEM"   , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_ZZR_LPR      ]	:= Space( GetSx3Cache( "ZZR_LOCPRO" , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_ZZR_QUA   	]	:= Space( GetSx3Cache( "ZZR_QUANT"  , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_ZZR_CLA      ]	:= Space( GetSx3Cache( "ZZR_CLASSI" , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_ZZR_SET   	]	:= Space( GetSx3Cache( "ZZR_SETOR"  , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_ZZR_REG      ]	:= Space( GetSx3Cache( "ZZR_REGIST" , "X3_TAMANHO" ) ) ///
		aListBox[ nATListBox ][ AT_ZZR_SUG      ]	:= Space( GetSx3Cache( "ZZR_SUGEST" , "X3_TAMANHO" ) ) ///
		aListBox[ nATListBox ][ AT_ZZR_USU   	]	:= Space( GetSx3Cache( "ZZR_USUAR"  , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_ZZR_DAT   	]	:= Space( GetSx3Cache( "ZZR_DATA"   , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_ZZR_HOR   	]	:= Space( GetSx3Cache( "ZZR_HORA"   , "X3_TAMANHO" ) )
		aListBox[ nATListBox ][ AT_R_E_C_N   	]	:= 0
	EndIF

	(cAlias)->( dbCloseArea() )
	dbSelectArea("ZZR")

	RestArea( aArea )

Return( ( nATListBox > 0 ) )
                                                                                  	
/*/
	Funcao:		EditLBoxCol
	Autor:		Tiago Lucio/Chaus
	Data:		22/05/2014
	Descricao:	Acao para bLDblClick do ListBox
	Sintaxe:	EditLBoxCol(nRow,nCol,nFlags) 
*/
Static Function EditLBoxCol(nRow,nCol,nFlags) 
	
	Local lEdit	:= .F.

	IF ( ( nATListBox > 0 ) .and. ( oListBox:ColPos == AT_ZZR_CLA  ) )
		EditLBoxCBox(@oListBox,@aCTTBloqBox,@oListBox:ColPos)
		Eval( oListBox:bLine )
		IF ZZR->( !Eof() .and. !Bof() )
			lEdit	:= ZZR->( RecLock( "ZZR" , .F. ) )
			IF ( lEdit )
				ZZR->ZZR_CLASSI	:= aListBox[ oListBox:nAT ][ AT_ZZR_CLA ]
				If 	ZZR->ZZR_CLASSI<>' '
				    If Trim(ZZR->ZZR_CLASSI)=='1'
				    	ZZR->ZZR_CLASSI:="1 - Transferencia"				    
				    Elseif Trim(ZZR->ZZR_CLASSI)=='2'
					    ZZR->ZZR_CLASSI:="2 - Entrada da Nota"
				    Elseif Trim(ZZR->ZZR_CLASSI)=='3'
						ZZR->ZZR_CLASSI:="3 - Saldo do PA"			    
				    Elseif Trim(ZZR->ZZR_CLASSI)=='4'
						ZZR->ZZR_CLASSI:="4 - Erro de Apontamento"			    
				    Elseif Trim(ZZR->ZZR_CLASSI)=='5'
						ZZR->ZZR_CLASSI:="5 - Erro de Saldo"			    
				    EndIf
				EndIf
				ZZR->( MsUnLock() )
			EndIF
		EndIF
	ElseIf ( ( nATListBox > 0 ) .and. ( oListBox:ColPos == AT_ZZR_ITE ) )
			MT010F4()
	ElseIf ( ( nATListBox > 0 ) .and. ( oListBox:ColPos == AT_ZZR_SET ) )
		EditLBoxCBox(@oListBox,@aSETBloqBox,@oListBox:ColPos)
		Eval( oListBox:bLine )
		IF ZZR->( !Eof() .and. !Bof() )
			lEdit	:= ZZR->( RecLock( "ZZR" , .F. ) )
			IF ( lEdit )
				ZZR->ZZR_SETOR	:= aListBox[ oListBox:nAT ][ AT_ZZR_SET ]
				If 	ZZR->ZZR_SETOR <>' '
				    If Trim(ZZR->ZZR_SETOR)=='1'
				    	ZZR->ZZR_SETOR:="1 - Pasta F1"				    
				    Elseif Trim(ZZR->ZZR_SETOR)=='2'
					    ZZR->ZZR_SETOR:="2 - Pasta F2"
				    Elseif Trim(ZZR->ZZR_SETOR)=='3'
						ZZR->ZZR_SETOR:="3 - Producao F1"			    
				    Elseif Trim(ZZR->ZZR_SETOR)=='4'
						ZZR->ZZR_SETOR:="4 - Producao F2"			    
				    Elseif Trim(ZZR->ZZR_SETOR)=='5'
						ZZR->ZZR_SETOR:="5 - Labor F1"			    
				    Elseif Trim(ZZR->ZZR_SETOR)=='6'
				    	ZZR->ZZR_SETOR:="6 - Labor F2"				    
				    Elseif Trim(ZZR->ZZR_SETOR)=='7'
					    ZZR->ZZR_SETOR:="7 - Envase F1"
				    Elseif Trim(ZZR->ZZR_SETOR)=='8'
						ZZR->ZZR_SETOR:="8 - Envase F2"			    
				    Elseif Trim(ZZR->ZZR_SETOR)=='9'
						ZZR->ZZR_SETOR:="9 - Almox F1"			    
				    Elseif Trim(ZZR->ZZR_SETOR)=='10'
						ZZR->ZZR_SETOR:="10 - Almox F2"			    
				    EndIf
				EndIf
				ZZR->( MsUnLock() )
			EndIF
		Endif
	Endif
Return ( lEdit )



Static Function GrvSugest(aListBox, oListBox, nLin, nCol) 

Local cRegist
Local cSugest       
Local i     
    
    If (oListBox:ColPos == AT_ZZR_REG)
   		lEditCell(@aListBox,oListBox,"@!",nCol) 
	    cRegist := aListBox[nLin,nCol] 	
	    If (oListBox:ColPos == AT_ZZR_REG) .and. (!Empty(cRegist))
	    	dbSelectArea("ZZR")
			ZZR->(dbSetOrder(3)) 	//ZZR_FILIAL, ZZR_OP, ZZR_LOCAL, ZZR_DOC, ZZR_DATA, R_E_C_N_O_, D_E_L_E_T_  
			ZZR->(dbSeek(xFilial("ZZR")+aListBox[nLin,03]+aListBox[nLin,05]+aListBox[nLin,08]))	                                    
     		IF ZZR->( !Eof() .and. !Bof() )
				ZZR->(RecLock("ZZR",.F.))
					ZZR->ZZR_REGIST	:= Alltrim(aListBox[nLin,nCol])
				ZZR->( MsUnLock() )
			Endif
			DbSelectArea("ZZR")
			DbCloseArea()
		Endif
	Elseif (oListBox:ColPos ==  AT_ZZR_SUG) 
   		lEditCell(@aListBox,oListBox,"@!",nCol) 
	    cSugest := aListBox[nLin,nCol] 	
	    If (oListBox:ColPos == AT_ZZR_SUG) .and. (!Empty(cSugest))
	    	dbSelectArea("ZZR")
			ZZR->(dbSetOrder(3)) 	//ZZR_FILIAL, ZZR_OP, ZZR_LOCAL, ZZR_DOC, ZZR_DATA, R_E_C_N_O_, D_E_L_E_T_  
			ZZR->(dbSeek(xFilial("ZZR")+aListBox[nLin,03]+aListBox[nLin,05]+aListBox[nLin,08]))	                                    
     		IF ZZR->( !Eof() .and. !Bof() )
				ZZR->(RecLock("ZZR",.F.))
					ZZR->ZZR_SUGEST	:= Alltrim(aListBox[nLin,nCol])
				ZZR->( MsUnLock() )
			Endif
			DbSelectArea("ZZR")
			DbCloseArea()
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

/*/
	Funcao:		CloseApp
	Autor:		Marinaldo de Jesus
	Data:		02/10/2011
	Descricao:	Acao do Botao Sair
	Sintaxe:	EvalFilter()
/*/
Static Function CloseApp( oDlg ) 

   
	private cQuery:="" 
	private lEstorno:=.T.
	private cErros:="" 
	private lMsErroAuto:=.F.       
	
	private cCodOrig:= ""                                         
	private cUmOrig:=  ""
	private cLocOrig:= "" 
	private nRecOrig:= 0 
	
	private cCodDest:= ""                                         
	private cUmDest:=  ""
	private cLocDest:= ""  
	private nRecDest:= 0 
	
	private nQuant:=0
	private nQtSec:=0
	private dEmissao:=date()  
	private nErros:=0  
	private cArea:=getArea()  
	private lAltaprop:=.F.
	private aErros:={}
	private nQuanItem:=0
	
	
	private cCusMed  := GetMv("MV_CUSMED")  

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
	
	
	cQuery := " SELECT ZZR_OP, ZZR_LOCAL, ZZR_TIPO, ZZR_LOTE, ZZR_DOC, ZZR_PRODUT,ZZR_QUANT, ZZR_CLASSI, ZZR_SUGEST, ZZR_REGIST, "
	cQuery += " ZZR_SETOR, ZZR_DOC, ZZR_ITEM, ZZR_LOCPRO, ZZR_USUAR, ZZR_FLAG, R_E_C_N_O_ "
	cQuery += " FROM "+RetSqlName("ZZR")+" "
	cQuery += " WHERE ZZR_COR ='1' AND ZZR_CLASSI <>'' "  //Itens classificados pelo usuario para serem classificados
	cQuery += " AND D_E_L_E_T_ ='' AND ZZR_FILIAL ='"+xFilial("ZZR")+"'"
	cQuery += " ORDER BY ZZR_LOTE "	

	IF (Select("TMPZZR") > 0 )
   		TMPZZR->(DbCloseArea())                                                     
	EndIf

	TCQuery cQuery ALIAS "TMPZZR" NEW
	
	While !(TMPZZR->(eof())) 
	   //	oListBox:GoTop() // jogar no primeiro registro do browse
	   	//oListBox:CleanFilter()
//	   	oListBox:Refresh()
		If SUBSTR(ZZR->ZZR_CLASSI,1,1)=='5' // Ocorrencia de falta de saldo nao gera movimentação de estorno 05/06/14
			nOpc:=Aviso("EditLBoxCol.PRG", "A classificação '5 - Erro de Saldo' não gera movimentação interna de estorno."+ Chr(13) + Chr(10)+" Deseja continuar?",{"Sim","Não"})
			dbSelectArea("ZZR")
			If nOpc==1
      			ZZR->(dbSetOrder(3)) 	//ZZR_FILIAL, ZZR_OP, ZZR_LOCAL, ZZR_DOC, ZZR_DATA, R_E_C_N_O_, D_E_L_E_T_  
          		ZZR->(dbSeek(xFilial("ZZR")+TMPZZR->ZZR_OP+TMPZZR->ZZR_LOCAL+TMPZZR->ZZR_DOC))	                                    
	           	RecLock("ZZR", .F. )
		        nQuanItem:= nQuanItem + 1 //controla quantidade itens classificados
		        // BEGIN TRANSACTION
				If !(ZZR->(eof()))
					RecLock( "ZZR" , .F. )
						ZZR->ZZR_COR		:='2' 
						ZZR->ZZR_USUAR		:=Substr(cUsuario,7,15)
						ZZR->ZZR_DATA		:=date()//Substr(date(),7,2)+"/"+Substr(date(),5,2)+"/"+Substr(date(),1,4)
						ZZR->ZZR_HORA		:=Time()
					MsUnLock() 
				EndIf	 
			EndIf							 
		Else
			DBSelectArea("SB2")
    		SB2->(DBSetOrder(1)) //B2_FILIAL, B2_COD, B2_LOCAL, R_E_C_N_O_, D_E_L_E_T_
    		SB2->(DBSeek(xFilial("SB2")+TMPZZR->ZZR_ITEM+TMPZZR->ZZR_LOCPRO))
    		
    		If SB2->B2_QATU < TMPZZR->ZZR_QUANT //Não foi feito a correção do saldo no armazem
    			Aviso("EdtLBoxColZZR.PRW","O Saldo disponivel no armazem "+Trim(SB2->B2_LOCAL)+" é menor que a quantidade solicitada pelo empenho "+Trim(SB2->B2_COD)+". "+;
    			" Verifique se o acerto da ocorrencia foi realizada!",{"OK"})
    		Else
		    	nErros:=0        
		    	lAltaprop:=.F.
				aItem := {}
				aCab :={}
					
				cQuery:="	SELECT DISTINCT A.D3_DOC AS DOC,A.D3_EMISSAO AS EMISSAO, A.D3_TM MOV_ENT,B.D3_TM MOV_SAI, A.D3_COD PROD_ENT,B.D3_COD PROD_SAI, A.D3_QUANT QUANT,A.D3_SEGUM AS QT2, A.D3_LOCAL LOC_ENT, B.D3_LOCAL LOC_SAI, A.R_E_C_N_O_ REC_ENT, B.R_E_C_N_O_ REC_SAI 	" 
				cQuery+="	FROM "+RetSQlName("SD3")+" A WITH (NOLOCK) "
				cQuery+="	LEFT JOIN "+RetSQlName("SD3")+" B WITH (NOLOCK)  ON A.D3_FILIAL=B.D3_FILIAL AND A.D3_DOC = B.D3_DOC AND A.D3_COD = B.D3_COD AND A.D3_QUANT= B.D3_QUANT AND A.D3_ESTORNO=B.D3_ESTORNO AND A.D_E_L_E_T_ = B.D_E_L_E_T_	"
				cQuery+="	WHERE A.D3_DOC = '"+Trim(TMPZZR->ZZR_DOC)+"' AND A.D3_FILIAL='"+xFilial("SD3")+"' AND A.D_E_L_E_T_='' AND B.D3_TM ='499' AND A.D3_TM='999' AND LTrim(RTrim(A.D3_ESTORNO)) <>'S'"
						
				IF (Select("TMPSD3") > 0 )
  					TMPSD3->(DbCloseArea())
				EndIf
   
				TCQuery cQuery ALIAS "TMPSD3" NEW
					
				dbSelectArea("SD3")
           		SD3->(dbSetOrder(8)	)	//  D3_FILIAL, D3_DOC, D3_NUMSEQ, R_E_C_N_O_, D_E_L_E_T_ 
           		SD3->(dbSeek(xFilial("SD3")+TMPZZR->ZZR_DOC))
            			            			
           		dBselectArea("SB1")   
	    		SB1->(dbSeek(xFilial("SB1")+SD3->D3_COD))
		    
		    	BEGIN TRANSACTION
		    			
				If SB1->B1_APROPRI=='I'
				   	lAltaprop:=.T.
					RecLock("SB1",.F.)
					    SB1->B1_APROPRI:='D'
					MsUnLock()
				EndIf		
						
				//END TRANSACTION		            				  
           		If !(TMPSD3->(eof()))  //Verifica se houve transferencia para o armazem de requisição			
					a260Processa(TMPSD3->PROD_ENT,TMPSD3->LOC_ENT,TMPSD3->QUANT,TMPSD3->DOC,TMPSD3->EMISSAO,TMPSD3->QT2,,,,,,TMPSD3->PROD_SAI,TMPSD3->LOC_SAI,,.T., TMPSD3->REC_ENT, TMPSD3->REC_SAI,,Nil,,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,,Nil,Nil,,)	
				Endif
						
				dbSelectArea("SD3")
           		SD3->(dbSetOrder(8)	)	//  D3_FILIAL, D3_DOC, D3_NUMSEQ, R_E_C_N_O_, D_E_L_E_T_ 
           		SD3->(dbSeek(xFilial("SD3")+TMPZZR->ZZR_DOC))
			            
		        While !(SD3->(eof())) .And. Trim(TMPZZR->ZZR_DOC) == Trim(SD3->D3_DOC)  //Percorre todas as incidencias do movimento do documento
					If 	Trim(SD3->D3_ESTORNO)<>'S'	
						lMsErroAuto:=.F.	
						aCab:={}
						aItem:={}
						aCab := {{"D3_FILIAL"    ,SD3->D3_FILIAL    ,Nil},; 
							  	 {"D3_DOC"    ,SD3->D3_DOC    ,Nil},; 
					             {"D3_TM"     ,SD3->D3_TM      ,Nil},; 
					             {"D3_CC"     ,SD3->D3_CC        ,Nil},;
					             {"D3_LOCAL"     ,SD3->D3_LOCAL       ,Nil},; 
					             {"D3_EMISSAO",SD3->D3_EMISSAO ,Nil}} 
							            	  
				  		aAdd(aItem, { {"D3_FILIAL"     , SD3->D3_FILIAL       , NIL},;                 	
									  {"D3_DOC",  SD3->D3_DOC , NIL},;    
		                   		      {"D3_TM"     , SD3->D3_TM       , NIL},; 
		                              {"D3_COD"    , SD3->D3_COD  , NIL},;
		                              {"D3_LOCAL"  , SD3->D3_LOCAL, NIL},;
		                              {"D3_UM"    , SD3->D3_UM  , NIL},;
		                              {"D3_EMISSAO",SD3->D3_EMISSAO , NIL},;
		                              {"D3_QUANT",  SD3->D3_QUANT  , NIL},;
		                              {"D3_GRUPO",  SD3->D3_GRUPO  , NIL},;
		                              {"D3_CF",  SD3->D3_CF  , NIL},;
		                              {"D3_TIPO",  SD3->D3_TIPO  , NIL},;      
		                              {"D3_NUMSEQ",  SD3->D3_NUMSEQ , NIL}})                                      	                                      

	                    lMsErroAuto:=.f.      
	                    dbSelectArea("SD3")
	    		        MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItem,6)//Estorno 
	                                
		             	If lMsErroAuto
	                 		mostraerro()   
		                    Aadd(aErros,TMPZZR->ZZR_OP)
		                    nErros:=nErros + 1
			                DISARMTRANSACTION() //Rollback 
	                                    
                	        dbSelectArea("ZZR")
            	            ZZR->(dbSetOrder(3)) 	//ZZR_FILIAL, ZZR_OP, ZZR_LOCAL, ZZR_DOC, ZZR_DATA, R_E_C_N_O_, D_E_L_E_T_  
                    	    ZZR->(dbSeek(xFilial("ZZR")+TMPZZR->ZZR_OP+TMPZZR->ZZR_LOCAL+TMPZZR->ZZR_DOC))	                                    
							If !(ZZR->(eof()))
								RecLock( "ZZR" , .F. )
									ZZR->ZZR_COR		:="1" 
									ZZR->ZZR_USUAR		:=" "
									ZZR->ZZR_DATA		:=CTOD("  /  /  ")
									ZZR->ZZR_HORA		:=" "  
									ZZR->ZZR_CLASSI   	:=" "
									ZZR->ZZR_REGIST     :=" "
									ZZR->ZZR_SUGEST     :=" "
								MsUnLock()  
							EndIf	
	    	            Else   
		                 	 dbSelectArea("ZZR")
    	                     ZZR->(dbSetOrder(3)) 	//ZZR_FILIAL, ZZR_OP, ZZR_LOCAL, ZZR_DOC, ZZR_DATA, R_E_C_N_O_, D_E_L_E_T_  
        	                 ZZR->(dbSeek(xFilial("ZZR")+TMPZZR->ZZR_OP+TMPZZR->ZZR_LOCAL+TMPZZR->ZZR_DOC))	                                    
            	             RecLock( "ZZR" , .F. )
	            	         nQuanItem:= nQuanItem + 1 //controla quantidade itens classificados
	                         // BEGIN TRANSACTION
							 If !(ZZR->(eof()))
							 	RecLock( "ZZR" , .F. )
									ZZR->ZZR_COR		:='2' 
									ZZR->ZZR_USUAR		:=Substr(cUsuario,7,15)
									ZZR->ZZR_DATA		:=date()//Substr(date(),7,2)+"/"+Substr(date(),5,2)+"/"+Substr(date(),1,4)
									ZZR->ZZR_HORA		:=Time()
								MsUnLock() 
							 EndIf	  
							 //END TRANSACTION
                             //	END TRANSACTION   //Commit          
	   					EndIf
			    		//END TRANSACTION
			
						dBselectArea("SB1")   
					    SB1->(dbSeek(xFilial("SB1")+SD3->D3_COD))
		    
					    If SB1->B1_APROPRI=='D' .And. lAltaprop
						    RecLock("SB1",.F.)
							    SB1->B1_APROPRI:='I'
							MsUnLock()
							lAltaprop:=.F.
						EndIf		
					EndIf
					
					SD3->(dbSkip()) 
				EndDo
	
				END TRANSACTION  
			EndIf
		EndIf
		TMPZZR->(dbSkip())
	EndDo
	
	nErros:= Len(aErros)
	
	If nErros==0
			Aviso("EDTLBOXCLZZR.PRW","Foram classificados "+Str(nQuanItem)+" Itens com sucesso",{"OK"})
	Else
		nCont:=1
		cMsgErro:=""
		While 	nCont <= nErros
			cMsgErro:=  cMsgErro + Chr(13) + Chr(10) + aErros[nCont]
			nCont := nCont + 1
		EndDo
		Aviso("EDTLBOXCLZZR.PRW","Alguns itens não foram classificados :"+cMsgErro,{"OK"})	
	EndIf
	
	ncont :=1
	           
	RestArea(cArea)
	//Aviso("Aviso","Encerrando...",{"OK"})
	oDlg:End()
		
Return( .T. )

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

//#IFDEF __DEBUG	//Se estiver definida, executo diretamente pela tela de abertura do sistema

	User Function dbgLBoxE()
	Return( EvalPrg( { || EdtLBoxCol() } , "01" , "010101" , "SIGAPCP" , "ZZR" ) )

	/*/
		Funcao:		EvalPrg
		Autor:		Marinaldo de Jesus
		Data:		02/10/2011
		Descricao:	Executa um Programa Diretamente
		Sintaxe:	EvalPrg( bExec , cEmp , cFil , cModulo , cTables )
	/*/
	Static Function EvalPrg( bExec , cEmp , cFil , cModulo , cTables )

		Local nVarNameLen	:= SetVarNameLen( VAR_NAME_L )		//Para Poder usar Nomes Longos
	
		Local bWindowInit	:= { || Eval( bExec ) }
		Local lPrepEnv		:= ( IsBlind() .or. ( Select( "SM0" ) == 0 ) )
		
		Local uRet
	
		BEGIN SEQUENCE
	
			IF ( lPrepEnv )
				RpcSetType( 3 )
				PREPARE ENVIRONMENT EMPRESA( cEmp ) FILIAL ( cFil ) MODULO ( cModulo ) TABLES ( cTables )
				SetVarNameLen( VAR_NAME_L )
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