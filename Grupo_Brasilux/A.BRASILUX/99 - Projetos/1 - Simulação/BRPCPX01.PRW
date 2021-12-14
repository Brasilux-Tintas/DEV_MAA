#include "ap5mail.ch"
#include "colors.ch"                                                                     
#include "font.ch"                                                                               
#include "topconn.ch"
#include "avprint.ch"                                                                                
#include "protheus.ch"
#include "rwmake.ch"   
#INCLUDE "FWBROWSE.CH"                                                                                          

#define DS_MODALFRAME            128  // 0x80
#define WS_POPUP          2147483648  // 0x80000000L                        
#define WS_CAPTION          12582912  // 0x00C00000L
#define WS_VISIBLE         268435456  // 0x10000000L
#define GEL_ARQ  01
#define GEL_POS  02
#define GEL_HF1  03
#define GEL_MRK  04
//#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
  ±±ºPrograma  ³ BRPCPX01 ºAutor  ³ Luís Gustavo       º Data ³  10/03/04   º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºDesc.     ³ Rotina de simulação, inclusão, visualização e teste com as º±±
  ±±º          ³ fómulas de Tintas.                                         º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºUso       ³ BRASILUX                                                   º±±
  ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  ±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
  ±±³   Data   ³  BOPS  ³ Programador ³Alteracao                            ³±±
  ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
  ±±³ 10/03/04 ³ XXXXXX ³ GUSTAVO     ³ Revisão geral do programa para novas³±±
  ±±³          ³        ³             ³implementações e melhorias.          ³±±
  ±±³          ³        ³             ³                                     ³±±
  ±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±*/
/******************************************************************************************************************/
/***              FUNÇÕES UTILIZADAS NO MÓDULO DE PLANEJAMENTO E CONTROLE DA PRODUÇÃO - SIMULAÇÃO               ***/
/******************************************************************************************************************/
/***  FUNÇÃO  # F. AUXIL. #                                                                                     ***/
/******************************************************************************************************************/
/*** BRPCPX01 #           # CHAMADA PRINCIPAL DO PROGRAMA DE FORMULAÇÃO                                         ***/
/***          # AxPesqui  # Chamada da função da microsiga para pesquisas                                       ***/
/***          # PCPX01_A  # Visualiza / exclui fórmulas                                                         ***/

User Function BRPCPX01()
     //Local   nPos,cLinhas,cAux,cQuery
     Private cCadastro := "Manutenção da Estrutura do Produto"
     Private cCodUsr   := RetCodUsr()
     Private cAcessos  := ""
     Private cRotina   := "BRPCPX01"
     Private lFiltro   := .f.                                                                   // Filtro para produtos da linha Brasimix
     Private lFiltBM   := .f.
     Private _cFiltro   := "" //'(ZM_FILIAL == "'+xFilial("SZM")+'")'                                           // Filtro para itens pendentes
     //Private cFiltBM   := '(LEN(ALLTRIM(ZM_CODIGO)) # 6) .AND. (Substr(ZM_CODIGO,1,2) # "BM")' // Filtro para itens do tipo BM
     Private cFiltBM   := "" // Filtro para itens do tipo BM
     Private lAcs1     := .f.
     Private lAcs2     := .f.
     Private lAcs3     := .f.
     Private lAcs4     := .f.
     Private lAcs5     := .f.
     Private lAcs6     := .f.
     Private lAcs7     := .f.
     Private lAcs8     := .f.
     Private lAcs9     := .f.
     Private lAcsA     := .f.
     Private cQueryZM  := ""
	 Private aIndexSZM := {}
	 Private oObjBrow  := Nil
     Private nIniFil   := 1
	 Private nOpcFil   := 3
	 Private oTemptable:= ""
//   Private aRotina   := { { OemToAnsi("&Pesquisar")        , 'AxPesqui'            , 0, 1} ,;
     Private aRotina   := { { OemToAnsi("&Pesquisar")        , 'PesqBrw'            , 0, 1} ,;
                            { OemToAnsi("&Visualiza")        , 'U_PCPX01_A(1)'       , 0, 2} ,;
                            { OemToAnsi("&Simulação")        , 'U_PCPX01_8(3)'       , 0, 3} ,;
                            { OemToAnsi("Produto &Novo")     , 'U_PCPX01_2(1)'       , 0, 3} ,;
                            { OemToAnsi("&Manutenção")       , 'U_PCPX01_1(2)'       , 0, 4} ,;
                            { OemToAnsi("&Exclusão")         , 'U_PCPX01_1(1, , , , .t.)', 0, 5} ,;
                            { OemToAnsi("&Liberação")        , 'U_PCPX01_3()'        , 0, 6},;
                            { OemToAnsi("&Impressão")        , 'U_PCPX01_9()'        , 0, 6}   }


     Private aCores    := { { 'SZM->ZM_STATUS == "EE"', 'DISABLE'    },;
                            { 'SZM->ZM_STATUS == "PP"', 'BR_AMARELO' },;
                            { 'SZM->ZM_STATUS == "EA"', 'BR_AZUL'    },;
                            { 'SZM->ZM_STATUS == "AC"', 'ENABLE'     },;
                            { 'SZM->ZM_STATUS == "RE"', 'BR_PRETO'   },;
                            { 'SZM->ZM_STATUS == "RT"', 'BR_CINZA'   } }


//Cleber(27/09/20)->Tem que ter autorização de acesso da Diretoria(Sócios/Proprietários), independente de o usuário ser administrador 
   	DbSelectArea("SZW")
   	DbSetOrder(5)
   	DbSeek(__CUSERID + funname())
   	if !found() .or. (found() .and. (substr(ZW_ACESSOS,1,1) != "*"))
         MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
   		return(.f.)
   	endif
     u_zcfga01( 'BRPCPX01' ) //LGS#2021203 - Gravação de log de utilização da rotina

     cRotina  := Stuff(cRotina, Len(cRotina)+1, 10 - Len(cRotina), space(10 - Len(cRotina)))
     cAcessos := Posicione("SZW", 4, xFilial("SZW")+cRotina+cCodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS")    
     
     lAcs1    := Iif((SubStr(cAcessos, 01, 1) == '*') .or. (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0), .t., .f.) //Gera revisão PI
     lAcs2    := Iif((SubStr(cAcessos, 02, 1) == '*') .or. (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0), .t., .f.) //Libera revisão PI
     lAcs3    := Iif((SubStr(cAcessos, 03, 1) == '*') .or. (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0), .t., .f.) //Gera revisão PA
     lAcs4    := Iif((SubStr(cAcessos, 04, 1) == '*') .or. (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0), .t., .f.) //Libera revisão PA
     lAcs5    := Iif((SubStr(cAcessos, 05, 1) == '*') .or. (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0), .t., .f.) //Liberação Diretoria
     lAcs6    := Iif((SubStr(cAcessos, 06, 1) == '*') .or. (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0), .t., .f.) //Produtos BRASIMIX
     lAcs7    := Iif((SubStr(cAcessos, 07, 1) == '*') .or. (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0), .t., .f.) //Filtra BM
     lAcs8    := Iif((SubStr(cAcessos, 08, 1) == '*') .or. (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0), .t., .f.) //Visualiza Estrutura
     lAcs9    := Iif((SubStr(cAcessos, 09, 1) == '*') .or. (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0), .t., .f.) //Usuário Ativo
     lAcsA    := Iif((SubStr(cAcessos, 10, 1) == '*') .or. (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) == 0), .t., .f.) //Recebe e-mail
     If !lAcs9
        MsgBox("Usuário não possui acesso a essa opção", "Atenção", "STOP")
        Return
     Endif
     
     
	cFiltBM := ""
 	If !lAcs6
  		lFiltBM := .t.         
    	cFiltBM := '(Substr(ZM_CODIGO,1,2) != "BM")'
//    	cFiltBM := "(SUBSTRING(ZM_CODIGO,1,2) = 'BM')"
  	Endif

/*	if lFiltBM			
        dbselectarea("SZM")
        Set Filter To &(cFiltBM)
 	endif */

     If lAcs8
        aadd(aRotina, { OemToAnsi("Es&trutura")                , 'U_PCPX01_4()'            , 0, 6} )
     Endif
     aadd(aRotina, { OemToAnsi("Mostrar Pendentes (todos)")    , 'U_PCPX01_6(1,1)'   , 0, 0} )
     aadd(aRotina, { OemToAnsi("Mostrar Pendentes Diretoria")  , 'U_PCPX01_6(1,2)'   , 0, 0} )
     aadd(aRotina, { OemToAnsi("Desligar Filtro Ativo")        , 'U_PCPX01_6(2,3)'   , 0, 0} )
     aadd(aRotina, { OemToAnsi("Ficha Pro&cesso")              , 'U_fFichaOp(SZM->ZM_CODIGO, SZM->ZM_REVISAO, SZM->ZM_DESCRIC)', 0, 6} )
     aadd(aRotina, { OemToAnsi("&Histórico")                   , 'U_PCPA04_7()'      , 0, 6} )
     //aadd(aRotina, { OemToAnsi("&Histórico")                   , 'U_PCPX01_5("SI")'        , 0, 6} )
     aadd(aRotina, { OemToAnsi("Le&genda")                     , 'U_PCPX01_7()'            , 0, 6} )

	DbSelectArea("SZM")
 	DbSetOrder(1)

	_cFiltro   := cFiltBM                                  
	if empty(_cFiltro)
//		_cFiltro := ".T."
	endif 

	DbSelectArea("SZM")
	dbgotop()

//    mBrowse( 6,1,22,75,"SZM", , , , , , aCores) //, , , , , , , ,_cFilSql
	oObjBrow := FWMBrowse():New()
	oObjBrow:SetAlias("SZM")		// Indica o Alias da tabela utilizada no Browse
	oObjBrow:SetMenuDef(cRotina)
	oObjBrow:SetWalkThru(.F.)
	oObjBrow:SetUseFilter(.T.)
	IF type("oObjBrow:lDetails") != "U"
		oObjBrow:lDetails := .F.
	endif 
	oObjBrow:SetExecuteDef(2)		// Elemento do aRotina executado no duplo clique
	oObjBrow:AddLegend( 'SZM->ZM_STATUS == "EE"' , 'DISABLE'    , "Analise Química" )
	oObjBrow:AddLegend( 'SZM->ZM_STATUS == "PP"' , 'BR_AMARELO' , "Analise PCP" )
	oObjBrow:AddLegend( 'SZM->ZM_STATUS == "EA"' , 'BR_AZUL'    , "Analise Diretoria" )
	oObjBrow:AddLegend( 'SZM->ZM_STATUS == "AC"' , 'ENABLE'     , "Aprovado" )
	oObjBrow:AddLegend( 'SZM->ZM_STATUS == "RE"' , 'BR_PRETO'   , "Rejeitado" )
	oObjBrow:AddLegend( 'SZM->ZM_STATUS == "RT"' , 'BR_CINZA'   , "Retorno Status" )
	oObjBrow:Activate()	
 	EndFilBrw("SZM",aIndexSZM)
Return

/********************************************************************************************/
/*** PCPX01_8 - Mostra o numero da revisão que será gerada para o produto.                ***/
/********************************************************************************************/
User Function PCPX01_8(nOpc)
    Local cDesEmb := ""
	Local lTemPaKg:= .f.

	If !EstaAutori(SZM->ZM_CODIGO)
		Alert("Acesso Não Autorizado!")
		return(.f.)
	Endif 
    If Posicione("SZM", 3, xFilial("SZM")+SZM->ZM_CODIGO, "ZM_STATUS") $ 'EE.PP'
    	Alert("Existe produto em Análise Química / ou Análise do PCP. Dê manutenção ou exclua-o antes de prosseguir !")	
		return(.f.)    
    Endif
    If U_TemPAemK(SZM->ZM_CODIGO)
    	Alert("Existe produto acabado em KG e o PI esta em Litro, Simule um produto com final 99 PI na unidade de medida K!!")	
		lTemPaKg := .t.
		//return(.f.)
    Endif	
    If MsgYesNo("Será gerada a revisão "+StrZero(Val(Posicione("SZM", 3, xFilial("SZM")+SZM->ZM_CODIGO, "ZM_REVISAO"))+1, 3)+" para o produto "+Alltrim(SZM->ZM_CODIGO)+" ("+Alltrim(SZM->ZM_DESCRIC)+"), continua ?", "Continua...")
        If !SubStr(SZM->ZM_CODIGO, 11, 2) $ '00.99' .and. Len(Alltrim(SZM->ZM_CODIGO)) == 12
           cDesEmb := Posicione("SZ5", 1, xFilial("SZ5")+SubStr(SZM->ZM_CODIGO, 11, 2), "Z5_DESCR")
    	Endif    
        U_PCPX01_1(nOpc, SZM->ZM_CODIGO, Posicione("SB1", 1, xFilial("SB1")+SZM->ZM_CODIGO, "B1_DESC"), 'PE', ,cDesEmb)
    Endif
Return

User Function TemPAemK(cCodigo)

    Local cArea := Alias()
    Local aAreaAnt := U_PegaArea({"SZM"})

    Local lTemPaKg := .f.
	Local lJaTem99 := .f.
	Local cId 	   := ""

	DbSelectArea("SZM")
    DbSetOrder(3)
    DbSeek(xFilial("SZM")+cCodigo,.t.)
    If Found()
    	cId := SZM->ZM_ID
		DbSelectArea("SZM")
	    DbSetOrder(4)
	    DbSeek(xFilial("SZM")+cId,.t.)
    	While !Eof() .and. SZM->ZM_FILIAL == xFilial("SZM") .and. Alltrim(SZM->ZM_ID) == Alltrim(cID)
    	    If Posicione("SZ5", 1, xFilial("SZ5")+SubStr(SZM->ZM_CODIGO, 11, 2), "Z5_UMEMB") == "K"
        	    lTemPaKg := .t.
            Endif
            If Substr(SZM->ZM_CODIGO,11,2) ='99'
            	lJaTem99 := .t.
            Endif
            DbSelectArea("SZM")
            DbSkip()
       	Enddo
    Endif
	If lJaTem99
		lTemPaKg := .f.
	Endif	
	DbSelectArea("SZM")
	DbCloseArea()
	              

	U_VoltaArea(aAreaAnt)

	If !Empty(cArea)
   		DbSelectArea(cArea)
	Endif
		
Return(lTemPaKg)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
  ±±ºPrograma  ³ PCPX01_1 ºAutor  ³ Luís Gustavo       º Data ³  10/03/04   º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºDesc.     ³ Rotina utilizada na visualização, simulação(inclusão), ma- º±±
  ±±º          ³ nutenção e exclusão de fórmulas.                           º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºUso       ³ BRASILUX                                                   º±±
  ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//User Function PCPX01_1(nOpc, cCodigo, cDescri, cProExi, lExcl, cDesEmb, cLocal, cPosIpi, cGrupo2)
User Function PCPX01_1(nOpc, _cCodigo, _cDescri, _cProExi, lExcl, cDesEmb, _cPLocal)
     Local aCpoEnChoice := { "ZM_CODIGO", "ZM_DESCRIC", "ZM_RESPONS", "ZM_DTINCLU", "ZM_REVISAO", "ZM_PESESP", "ZM_CATALIS", "ZM_RELCAT", "ZM_ROTEIRO","ZM_POSIPI","ZM_EX_NCM","ZM_XCODANT"  }
     Local aAltEnChoice := {}
     Local aAltGetDados := {}
     Local nReg         := SZM->(Recno())
     Local nOpcE        := Iif(nOpc == 1, 2, 3)
     Local lVirtual     := .t.
     Local aHeaderVig   := {}
     Local aDadVig      := {}
     Local oPerFor
     Local oPesEsp
     Local oCusRea
     Local oCusDol
     Local oPrcVig
     Local nPerFor      := 0
     Local nPesEsp      := 0
     Local nCusDol      := 0
     Local cFieldOk     := Iif( nOpc == 1, "AllwaysTrue()", "U_fVCamGD(oGetD, aCols, aHeader, M->ZM_CODIGO, M->ZM_REVISAO, M->ZM_TIPO, M->ZM_UM, M->ZM_TIPOPRO, @oPernew, @nPerNew, @oPesNew, @nPesNew, @oCusRNe, @nCusRNe, @oCusDNe, @nCusDNe, @oPrcNew, @nPrcNew, @oVarPrc, @nVarPrc, nCusRea, @oBitMap, nPrcVig, nOpcX, @oCalPVC, @nCalPVC, @oCalBri, @nCalBri, @oCusOuN, @nCusOuN)" )
     Local cLinOk       := Iif( nOpc == 1, "AllwaysTrue()", "U_fVLinGD(oGetD, aCols, aHeader, M->ZM_CODIGO, M->ZM_REVISAO, M->ZM_TIPO, M->ZM_UM, M->ZM_TIPOPRO, @oPernew, @nPerNew, @oPesNew, @nPesNew, @oCusRNe, @nCusRNe, @oCusDNe, @nCusDNe, @oPrcNew, @nPrcNew, @oVarPrc, @nVarPrc, nCusRea, @oBitMap, nPrcVig, nOpcX, @oCalPVC, @nCalPVC, @oCalBri, @nCalBri, @oCusOuN, @nCusOuN)" )
     Local cTudoOk      := Iif( nOpc == 1, "AllwaysTrue()", "U_fVTudGD(oGetD, aCols, aHeader, M->ZM_CODIGO, M->ZM_REVISAO, M->ZM_TIPO, M->ZM_UM, M->ZM_TIPOPRO)" )
     Local nLinhas      := 50
     Local cBitmap      := ''
     Local nOpcA        := 0
     //Local lFil         := .f.
     Local lCont        := .f.
     Local nCnt
     lExcl        := Iif(lExcl == Nil, .f., lExcl)
     Private lSaida     := .f.
     Private nCusRea    := 0 ; Private nVarPrc := 0
     Private nPerNew    := 0 ; Private oPerNew
     Private nPesNew    := 0 ; Private oPesNew
     Private nCusRNe    := 0 ; Private oCusRNe
     Private nCusDNe    := 0 ; Private oCusDNe
     Private nCusOuO    := 0 ; Private oCusOuO
     Private nCusOuN    := 0 ; Private oCusOuN
     Private nPrcNew    := 0 ; Private oPrcNew
     Private nOldPVC    := 0 ; Private oOldPVC
     Private nOldBri    := 0 ; Private oOldBri
     Private nCalPVC    := 0 ; Private oCalPVC
     Private nCalBri    := 0 ; Private oCalBri
     Private oCusVig         ; Private oCusAtu
     Private nOpcX      := nOpc
     Private oVarPrc
     Private _CLOCAL
     Private nPrcVig    := 0
     Private aCols      := {}
     Private aHeader    := {}
     Private aTELA      := Array(0,0)
     Private aGets      := Array(0)
     Private cCodigo    := Iif(_cCodigo == Nil, SZM->ZM_CODIGO , _cCodigo)
     Private cDescri    := Iif(_cDescri == Nil, SZM->ZM_DESCRIC, _cDescri)
     Private cProExi    := Iif(_cProExi == Nil, SZM->ZM_TIPOPRO, _cProExi)
     Private cLocal     := Iif(_cPLocal == Nil, SZM->ZM_LOCAL,   _cPLocal)
     Private cRespon    := Iif(nOpc    == 3  , cUsername, SZM->ZM_RESPONS)
     Private cStatus    := Iif(nOpc    == 3  , "EE", SZM->ZM_STATUS)
     //Private cTipoPro   := Iif(nOpc    == 3  , If(!(cNumEmp == "01010104"),  If(Len(Alltrim(cCodigo)) == 12, Iif(SubStr(cCodigo, 11, 2) $ '00.99', 'PI', 'PA'), 'PI'), Iif(cNumEmp = '01010104', If(Len(Alltrim(cCodigo)) == 12, Iif(SubStr(cCodigo, 11, 2) $ '00.99', 'PI', 'PA'), 'PA'), 'PA') ), SZM->ZM_TIPO )
     Private cTipoPro   := Iif(nOpc    == 3  ,   If(Len(Alltrim(cCodigo)) == 12, Iif(SubStr(cCodigo, 11, 2) $ '00.99', 'PI', 'PA'), 'PI') , SZM->ZM_TIPO )
     Private cRevisao   := Iif(nOpc    == 3  , "001", SZM->ZM_REVISAO)
     Private cPosIpi    := SZM->ZM_POSIPI //Iif(cPosIpi == Nil, SZM->ZM_POSIPI , cPosIpi)
     Private cGrupo2    := SZM->ZM_GRUPO2 //Iif(cGrupo2 == Nil, SZM->ZM_GRUPO2,  cGrupo2)
     Private cExNcm     := SZM->ZM_EX_NCM
     If !EstaAutori(SZM->ZM_CODIGO)
		Alert("Acesso Não Autorizado!")
		return(.f.)
	 Endif 

     If !U_fVerPerm(cRespon, cStatus, cAcessos, nOpc, cCodigo, cTipoPro)
        If lFiltro
           U_PCPX01_6(1)
        Endif
        Return
     Else
        If lExcl
           If !SZM->ZM_STATUS $ 'EE'
              MsgBox("Esse status não permite a exclusão da fórmula !!!","Atenção","STOP")
              If lFiltro
                 U_PCPX01_6(1)
              Endif
              Return
           Else
              If (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) != 0) .and. !Alltrim(Upper(cUsername)) $ Alltrim(Upper(SZM->ZM_RESPONS))
                 MsgBox("Usuário não autorizado a efetuar exclusão dessa estrutura !!!","Atenção","STOP")
                 If lFiltro
                    U_PCPX01_6(1)
                 Endif
                 Return
              Endif
           Endif
        Endif
     Endif

     If nOpc == 3
        DbSelectArea("SZM")
        DbSetOrder(3)
        DbSeek(xFilial("SZM")+cCodigo,.t.)
        If Found()
           cRevisao := StrZero(Val(SZM->ZM_REVISAO)+1, 3)
        Endif
        lJaEApr := .t.
        DbSelectArea("SZM")
        DbSetOrder(3)
        DbSeek(xFilial("SZM")+cCodigo,.t.)
        If Found()
           While !Eof() .and. SZM->ZM_CODIGO == cCodigo
                 If SZM->ZM_STATUS == "AC"
                    lJaEApr := .f.
                 Endif
                 DbSelectArea("SZM")
                 DbSkip()
           Enddo
           If lJaEApr
              cProExi := 'PN'
           Endif
        Endif
     Endif
     If nOpc <> 1
        If cTipoPro == 'PA'
           aAltEnchoice := Iif(nOpc <> 2, { "ZM_SOLICIT", "ZM_MOTIVO", "ZM_DESCRIC", "ZM_CATALIS", "ZM_RELCAT", "ZM_PADCOR","ZM_POSIPI","ZM_EX_NCM","ZM_XCODANT","ZM_GRUPO2" }, { "ZM_DESCRIC", "ZM_ROTEIRO", "ZM_CATALIS", "ZM_RELCAT","ZM_POSIPI","ZM_EX_NCM","ZM_XCODANT","ZM_GRUPO2" } )
        Else
           aAltEnchoice := Iif(nOpc <> 2, { "ZM_SOLICIT", "ZM_MOTIVO", "ZM_DESCRIC", "ZM_CATALIS", "ZM_RELCAT", "ZM_PADCOR","ZM_POSIPI","ZM_EX_NCM","ZM_XCODANT","ZM_GRUPO2" }, { "ZM_DESCRIC", "ZM_ROTEIRO", "ZM_CATALIS", "ZM_RELCAT","ZM_POSIPI","ZM_EX_NCM","ZM_XCODANT","ZM_GRUPO2"  } )
        Endif
        aAltGetDados := { "ZN_COMP", "ZN_TRT", "ZN_PERC", "ZN_PERDA", "ZN_OPERACA" }
     Endif

     RegToMemory("SZM",.F.)
     DbSelectArea("SZM")

     M->ZM_MOTIVO := Iif(nOpc == 3, "", U_fBusLog(SZM->ZM_ID, "SI", "EE" ))
     cRespon      := Iif(Empty(cRespon), cUsername, cRespon)
     If nOpc <> 1
        If nOpc == 3
           For nCnt := 1 to FCount()
               M->&(Field(nCnt)) := CriaVar(Field(nCnt))
           Next nCnt
        Endif
        M->ZM_CODIGO  := cCodigo
        M->ZM_REVISAO := cRevisao
        M->ZM_DESCRIC := cDescri
        M->ZM_POSIPI  := cPosIpi
        M->ZM_EX_NCM  := cExNcm
        M->ZM_RESPONS := cRespon
        M->ZM_TIPO    := cTipoPro
        //M->ZM_TIPO    := Iif(cNumEmp = "01010104", Iif( Len(AllTrim(cCodigo)) == 12 .and. SubStr(cCodigo, 11, 2) == '00', 'PI', 'PA'), Iif( Len(AllTrim(cCodigo)) == 4 .or. Len(AllTrim(cCodigo)) == 5 .or. Len(AllTrim(cCodigo)) == 6, 'PI', Iif( SubStr(cCodigo,11,02) $ "00", "PI", "PA" ) ) )
        M->ZM_GRUPO2  := cGrupo2
        M->ZM_SOLICIT := Iif(nOpc == 3, "", SZM->ZM_SOLICIT)
		  If Len(Alltrim(cCodigo)) == 12 
			If M->ZM_TIPO $ 'PI'			
				If cNumEmp ="01010101"
					_cLocal = Iif(Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodigo, 04, 02), "Z1_LOCPAD")='20','20','02')
				Else
					_cLocal ='02'
				Endif
			Elseif M->ZM_TIPO $ 'PA'
				If cNumEmp ="01010101"		
					_cLocal = Iif(Posicione("SZ1", 1, xFilial("SZ1")+SubStr(cCodigo, 04, 02), "Z1_LOCPAD")='02','P1','P2')				
				Else
					_cLocal =Iif(cNumEmp == "01060101",'P1','03')
				Endif
			Endif
		  Endif
        M->ZM_LOCAL   := Iif( Len(AllTrim(cCodigo)) == 4 .or. Len(AllTrim(cCodigo)) == 5 .or. Len(AllTrim(cCodigo)) == 6, cLocal , _cLocal ) //Iif(cNumEmp = "01010104", '03', Iif( Len(AllTrim(cCodigo)) == 4 .or. Len(AllTrim(cCodigo)) == 5 .or. Len(AllTrim(cCodigo)) == 6, cLocal , Iif( SubStr(cCodigo,11,02) $ "00", _cLocal, "02" ) ) ) //Iif(cNumEmp $ "0104", '03', Iif( Len(AllTrim(cCodigo)) == 4 .or. Len(AllTrim(cCodigo)) == 5 .or. Len(AllTrim(cCodigo)) == 6, '02', Iif( SubStr(cCodigo,11,02) $ "00", "02", "03" ) ) )
        M->ZM_TIPOPRO := cProExi
       // M->ZM_UM      := Iif(cNumEmp = "01010104", Iif( Len(AllTrim(cCodigo)) == 12, Iif(SubStr(cCodigo, 11, 2) == '00', 'L ', 'UN'), 'K  '), Iif( Len(AllTrim(cCodigo)) == 4 .or. Len(AllTrim(cCodigo)) == 5 .or. Len(AllTrim(cCodigo)) == 6, 'K ', Iif( SubStr(cCodigo,11,02) $ "00", "L ", "UN" ) ) )
        //M->ZM_UM      := Iif(cNumEmp = "01010104", Iif( Len(AllTrim(cCodigo)) == 12, Iif(SubStr(cCodigo, 11, 2) == '00', 'L ', 'UN'), 'K  '), Iif( Len(AllTrim(cCodigo)) == 4 .or. Len(AllTrim(cCodigo)) == 5 .or. Len(AllTrim(cCodigo)) == 6, 'K ', Iif( SubStr(cCodigo,11,02) $ "00", "L ", Iif(SubStr(cCodigo, 11, 2) == '99', 'K ', 'UN') ) ) )
        M->ZM_UM      := Iif( Len(AllTrim(cCodigo)) == 4 .or. Len(AllTrim(cCodigo)) == 5 .or. Len(AllTrim(cCodigo)) == 6, 'K ', Iif( SubStr(cCodigo,11,02) $ "00", "L ", Iif(SubStr(cCodigo, 11, 2) == '99', 'K ', 'UN') ) ) 
        cDesEmb       := Iif(Empty(cDesEmb), Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_DESCR"), cDesEmb)
        If M->ZM_TIPO $ 'PA'
           M->ZM_DESEMB := cDesEmb
        Endif
        If cProExi == 'PN'
           M->ZM_PESESP  := 1.00
        Else
           M->ZM_PESESP  := Posicione("SB1", 1, xFilial("SB1")+M->ZM_CODIGO, "B1_PESOESP")
        Endif
     Endif
     If nOpc == 1
        M->ZM_CATALIS := Posicione("SZM", 1, xFilial("SZM")+M->ZM_CODIGO, "ZM_CATALIS")
        M->ZM_RELCAT  := Posicione("SZM", 1, xFilial("SZM")+M->ZM_CODIGO, "ZM_RELCAT")
        M->ZM_ROTEIRO := Posicione("SZM", 1, xFilial("SZM")+M->ZM_CODIGO, "ZM_ROTEIRO")
        M->ZM_XCODANT := Posicione("SZM", 1, xFilial("SZM")+M->ZM_CODIGO, "ZM_XCODANT")
        M->ZM_DESEMB  := Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 2), "Z5_DESCR") 
        M->ZM_POSIPI  := Posicione("SZM", 1, xFilial("SZM")+M->ZM_CODIGO, "ZM_POSIPI")
        M->ZM_EX_NCM  := Posicione("SZM", 1, xFilial("SZM")+M->ZM_CODIGO, "ZM_EX_NCM")
        M->ZM_GRUPO2  := Posicione("SB1", 1, xFilial("SB1")+M->ZM_CODIGO, "B1_GRUPO2")
     ElseIf nOpc == 2
        M->ZM_CATALIS := M->ZM_CATALIS
        M->ZM_RELCAT  := M->ZM_RELCAT
        M->ZM_ROTEIRO := M->ZM_ROTEIRO
        M->ZM_XCODANT := M->ZM_XCODANT
        M->ZM_POSIPI  := Posicione("SZM", 1, xFilial("SZM")+M->ZM_CODIGO, "ZM_POSIPI")
        M->ZM_EX_NCM  := Posicione("SZM", 1, xFilial("SZM")+M->ZM_CODIGO, "ZM_EX_NCM")
        //M->ZM_GRUPO2  := Posicione("SZM", 1, xFilial("SZM")+M->ZM_CODIGO, "ZM_GRUPO2")
        M->ZM_GRUPO2  := Posicione("SB1", 1, xFilial("SB1")+M->ZM_CODIGO, "B1_GRUPO2")
     Else
        M->ZM_CATALIS := Posicione("SB1", 1, xFilial("SB1")+M->ZM_CODIGO, "B1_CATALIS")
        M->ZM_RELCAT  := Posicione("SB1", 1, xFilial("SB1")+M->ZM_CODIGO, "B1_RELCAT1")
        M->ZM_ROTEIRO := Posicione("SB1", 1, xFilial("SB1")+M->ZM_CODIGO, "B1_OPERPAD")
        M->ZM_POSIPI  := Posicione("SZM", 1, xFilial("SZM")+M->ZM_CODIGO, "ZM_POSIPI")	
        M->ZM_EX_NCM  := Posicione("SZM", 1, xFilial("SZM")+M->ZM_CODIGO, "ZM_EX_NCM")
        M->ZM_XCODANT := Posicione("SZM", 1, xFilial("SZM")+M->ZM_CODIGO, "ZM_XCODANT")
        M->ZM_GRUPO2  := Posicione("SB1", 1, xFilial("SB1")+M->ZM_CODIGO, "B1_GRUPO2")
     Endif
     If lCont
        Return
     Endif
     U_fMonHea(aHeader)
     U_fMonCol(aCols, aHeader, nOpc, M->ZM_CODIGO, M->ZM_REVISAO, M->ZM_ID, M->ZM_TIPO, M->ZM_UM, M->ZM_PESESP)
     
     nPrcVig := U_fBusPrc(cCodigo, "VIG",     , "2", aHeader, aCols)
     If nOpc == 3
        nPrcNew := U_fBusPrc(cCodigo, Iif(M->ZM_TIPOPRO $ 'PE', "VIG", 'NEW'),  , "2", aHeader, aCols)
     Else
        nPrcNew := U_fBusPrc(cCodigo, "NEW", cRevisao, "2", aHeader, aCols)
     Endif
     If nOpc == 3 .or. nOpc == 2
        If Len(Alltrim(M->ZM_CODIGO)) == 12
           If !Empty(Posicione("SZ3", 1, xFilial("SZ3")+SubStr(Alltrim(M->ZM_CODIGO), 6, 2)+SubStr(Alltrim(M->ZM_CODIGO), 8, 3), "Z3_PADCOR")) .and. Posicione("ZZE", 1, xFilial("ZZE")+Posicione("SZ3", 1, xFilial("SZ3")+SubStr(Alltrim(M->ZM_CODIGO), 6, 2)+SubStr(Alltrim(M->ZM_CODIGO), 8, 3), "Z3_PADCOR"), "ZZE_LIBERA") $ "S.R"
              M->ZM_PCREVIS := "S"
              M->ZM_PADCOR  := Posicione("ZZE", 1, xFilial("ZZE")+Posicione("SZ3", 1, xFilial("SZ3")+SubStr(Alltrim(M->ZM_CODIGO), 6, 2)+SubStr(Alltrim(M->ZM_CODIGO), 8, 3), "Z3_PADCOR"), "ZZE_DESCRI")
           Endif
        ElseIf Len(Alltrim(M->ZM_CODIGO)) == 5
               If !Empty(Posicione("SZ3", 1, xFilial("SZ3")+Alltrim(M->ZM_CODIGO), "Z3_PADCOR"))  .and. Posicione("ZZE", 1, xFilial("ZZE")+Posicione("SZ3", 1, xFilial("SZ3")+SubStr(Alltrim(M->ZM_CODIGO), 6, 2)+SubStr(Alltrim(M->ZM_CODIGO), 8, 3), "Z3_PADCOR"), "ZZE_LIBERA") $ "S"
                  M->ZM_PCREVIS := "S"
                  M->ZM_PADCOR  := Posicione("ZZE", 1, xFilial("ZZE")+Posicione("SZ3", 1, xFilial("SZ3")+Alltrim(M->ZM_CODIGO), "Z3_PADCOR"), "ZZE_DESCRI")
               Endif
        ElseIf Len(Alltrim(M->ZM_CODIGO)) == 6
               If !Empty(Posicione("SZ3", 1, xFilial("SZ3")+SubStr(Alltrim(M->ZM_CODIGO), 1, 5), "Z3_PADCOR"))  .and. Posicione("ZZE", 1, xFilial("ZZE")+Posicione("SZ3", 1, xFilial("SZ3")+SubStr(Alltrim(M->ZM_CODIGO), 6, 2)+SubStr(Alltrim(M->ZM_CODIGO), 8, 3), "Z3_PADCOR"), "ZZE_LIBERA") $ "S"
                  M->ZM_PCREVIS := "S"
                  M->ZM_PADCOR  := Posicione("ZZE", 1, xFilial("ZZE")+Posicione("SZ3", 1, xFilial("SZ3")+SubStr(Alltrim(M->ZM_CODIGO), 1, 5), "Z3_PADCOR"), "ZZE_DESCRI")
               Endif
        Endif
     Endif

     DEFINE MSDIALOG oDlg FROM 000,000 TO 033,100 TITLE OemToAnsi("Formulação") OF oMainWnd
     DEFINE FONT oFont SIZE 8,0 BOLD
	        EnChoice("SZM",nReg,nOpcE,,,,aCpoEnchoice,{020,001,100,395},aAltEnchoice,3,,,,,,lVirtual)

            /**************************************************************************/
            @ 090,050 SAY OemToAnsi("FORMULA VIGENTE")      SIZE 100,009 COLOR CLR_BLUE PIXEL OF oDlg  FONT oFont
            @ 100,001 LISTBOX oForVig FIELDS TITLE ""       SIZE 193,080 	            PIXEL OF oDlg
            /**************************************************************************/
   
            @ 182,001 GROUP oGrp1 TO 211,195 LABEL  OemToAnsi('Especificações...')    COLOR CLR_HRED  PIXEL OF oDlg
            @ 187,025 SAY OemToAnsi("% Fórmula: ")                        SIZE 030,09                 PIXEL OF oDlg
            @ 186,055 MSGET oPerFor VAR nPerFor PICTURE '@E 999.99%'      SIZE 030,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 187,105 SAY OemToAnsi("P. Especif.: ")                      SIZE 030,09                 PIXEL OF oDlg
            @ 186,135 MSGET oPesEsp VAR nPesEsp PICTURE '@E 99999.99999'  SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 199,025 SAY OemToAnsi("PVC")                                SIZE 030,09                 PIXEL OF oDlg
            @ 198,055 MSGET oOldPVC VAR nOldPVC PICTURE '@E 999.999'      SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 199,105 SAY OemToAnsi("Brilho 60%")                         SIZE 030,09                 PIXEL OF oDlg
            @ 198,135 MSGET oOldBri VAR nOldBri PICTURE '@E 999.999'      SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg

            @ 212,001 GROUP oGrp1 TO 241,195 LABEL  OemToAnsi('Totais...')            COLOR CLR_HRED  PIXEL OF oDlg
            @ 217,020 SAY OemToAnsi("Custo(R$/"+Alltrim(M->ZM_UM)+"): ")  SIZE 040,09                 PIXEL OF oDlg
            @ 216,055 MSGET oCusRea VAR nCusRea PICTURE '@E 9,999.999'    SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            If Alltrim(M->ZM_UM) $ 'L' .and. Alltrim(M->ZM_TIPO) $ 'PI'
               @ 229,020 SAY oCusVig VAR OemToAnsi("Custo(R$/K): ")       SIZE 040,09                 PIXEL OF oDlg
               @ 228,055 MSGET oCusOuO VAR nCusOuO PICTURE '@E 9,999.999' SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            Endif
            @ 217,105 SAY OemToAnsi("Custo(U$): ")                        SIZE 030,09                 PIXEL OF oDlg
            @ 216,135 MSGET oCusDol VAR nCusDol PICTURE '@E 9,999.999'    SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 229,025 SAY oSayVig   VAR OemToAnsi("Prç Venda:")           SIZE 030,09                 PIXEL OF oDlg
            @ 228,055 MSGET oPrcVig VAR nPrcVig PICTURE '@E 9,999.999'    SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg

            U_fBusVig(M->ZM_CODIGO, M->ZM_REVISAO, M->ZM_TIPO, @aHeaderVig, @aDadVig, @oPerFor, @nPerFor, @oPesEsp, @nPesEsp, @oCusRea, @nCusRea, @oCusDol, @nCusDol, @oPrcVig, @nPrcVig, @nOldPVC, @nOldBri, , 1, , oSayVig, @nCusOuO, @oCusOuO, @oCusVig )

            /**************************************************************************/
            @ 090,260 SAY OemToAnsi("REVISÃO: "+M->ZM_REVISAO)           SIZE 100,09 COLOR CLR_BLUE  PIXEL OF oDlg  FONT oFont

            /**************************************************************************/
            @ 182,197 GROUP oGrp2 TO 211,394 LABEL  OemToAnsi('Especificações...')    COLOR CLR_HRED  PIXEL OF oDlg
            @ 187,222 SAY OemToAnsi("% Fórmula: ")                        SIZE 030,09                 PIXEL OF oDlg
            @ 186,252 MSGET oPerNew VAR nPerNew PICTURE '@E 999.99%'      SIZE 030,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 187,300 SAY OemToAnsi("P. Especif.: ")                      SIZE 030,09                 PIXEL OF oDlg
            @ 186,332 MSGET oPesNew VAR nPesNew PICTURE '@E 99999.99999'  SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 199,222 SAY OemToAnsi("PVC:")                               SIZE 030,09                 PIXEL OF oDlg
            @ 198,252 MSGET oCalPVC VAR nCalPVC PICTURE '@E 999.999'      SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 199,300 SAY OemToAnsi("Brilho 60%:")                        SIZE 030,09                 PIXEL OF oDlg
            @ 198,332 MSGET oCalBri VAR nCalBri PICTURE '@E 999.999'      SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg

            @ 212,197 GROUP oGrp3 TO 241,394 LABEL  OemToAnsi('Totais...')            COLOR CLR_HRED  PIXEL OF oDlg
            @ 217,217 SAY OemToAnsi("Custo(R$/"+Alltrim(M->ZM_UM)+"): ")  SIZE 040,09                 PIXEL OF oDlg
            @ 216,252 MSGET oCusRNe VAR nCusRNe PICTURE '@E 9,999.999'    SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            If Alltrim(M->ZM_UM) $ 'L' .and. Alltrim(M->ZM_TIPO) $ 'PI'
               @ 229,217 SAY oCusAtu VAR OemToAnsi("Custo(R$/K): ")       SIZE 040,09                 PIXEL OF oDlg
               @ 228,252 MSGET oCusOuN VAR nCusOuN PICTURE '@E 9,999.999' SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            Endif
            @ 217,300 SAY OemToAnsi("Custo(U$): ")                        SIZE 030,09                 PIXEL OF oDlg
            @ 216,332 MSGET oCusDNe VAR nCusDNe PICTURE '@E 9,999.999'    SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 229,222 SAY oSayPrc   VAR OemToAnsi("Prç Venda:")           SIZE 030,09                 PIXEL OF oDlg
            @ 228,252 MSGET oPrcNew VAR nPrcNew PICTURE '@E 9,999.999'    SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 229,300 SAY oSayVar   VAR OemToAnsi("Variação:")            SIZE 035,09                 PIXEL OF oDlg
            @ 228,332 MSGET oVarPrc VAR nVarPrc PICTURE '@E 9,999.99%'    SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 225,378 BITMAP oBitmap RESOURCE cBitmap                     SIZE 015,15 ADJUST          PIXEL OF oDlg NO BORDER
            /**************************************************************************/
            DbSelectArea("SZM")
            oGetD := MsGetDados():New( 100, 197, 180, 393, nOpcE, cLinOk, cTudoOk, "", .T., aAltGetDados, 2, , nLinhas, cFieldOk )

            U_fMonRod(M->ZM_CODIGO, M->ZM_REVISAO, M->ZM_TIPO, M->ZM_UM, M->ZM_TIPOPRO, aCols, aHeader, @oPerNew, @nPerNew, @oPesNew, @nPesNew, @oCusRNe, @nCusRNe, @oCusDNe, @nCusDNe, @oPrcNew, @nPrcNew, @oVarPrc, @nVarPrc, @oBitmap, @cBitMap, nCusRea, nPrcVig, oSayPrc, @oCalPVC, @nCalPVC, @oCalBri, @nCalBri, .f., , @nCusOuN, @oCusOuN, nOpc, @oCusAtu )

            oDlg:nStyle       := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
            oForVig:aHeaders  := aHeaderVig
            oForVig:SetArray(aDadVig)
            oForVig:bLine     := {|| oForVig:aArray[oForVig:nAt] }
            oPerFor:lReadOnly := .t. ; oPerNew:lReadOnly := .t.
            oPesEsp:lReadOnly := .t. ; oPesNew:lReadOnly := .t.
            oCusRea:lReadOnly := .t. ; oCusRNe:lReadOnly := .t.
            oCusDol:lReadOnly := .t. ; oCusDNe:lReadOnly := .t.
            oPrcVig:lReadOnly := .t. ; oPrcNew:lReadOnly := .t.
            oVarPrc:lReadOnly := .t. ; oCalPVC:lReadOnly := .t.
            oCalBri:lReadOnly := .t. ; oOldPVC:lReadOnly := .t.
            oOldBri:lReadOnly := .t.
            If Alltrim(M->ZM_UM) $ 'L' .and. Alltrim(M->ZM_TIPO) $ 'PI'
               oCusOuO:lReadOnly := .t. ; oCusOuN:lReadOnly := .t.
            EndIf
            oGetD:oBrowse:Refresh()
     If nOpc == 1
        ACTIVATE MSDIALOG oDlg VALID lSaida ON INIT SIButton( { || lSaida := .t., nOpca := 1, oDlg:End() }, { || lSaida := .t., oDlg:End() }, oDlg, M->ZM_CODIGO, M->ZM_DESCRIC, M->ZM_REVISAO, M->ZM_TIPO, M->ZM_TIPOPRO, nOpc ) CENTERED
        If nOpcA == 1
           If lExcl
              nOpc := 4
              Begin Transaction
                    U_fGrvSim(nOpc)
              End Transaction
           Endif
        Endif
     Else
        ACTIVATE MSDIALOG oDlg VALID lSaida ON INIT SIButton( {|| lSaida := .t., nOpca := 1, Iif(oGetD:TudoOk(), Iif(obrigatorio(aGets,aTela), oDlg:Destroy(), nOpca := 0), nOpca := 0), iif(nOpcA==1, oDlg:End(), nOpcA == 0) }, {|| lSaida := .t., nOpca := 0, oDlg:End() }, oDlg, M->ZM_CODIGO, M->ZM_DESCRIC, M->ZM_REVISAO, M->ZM_TIPO, M->ZM_TIPOPRO, M->ZM_POSIPI,nOpc) CENTERED

        If nOpcA == 1           
           Begin Transaction
                 U_fGrvSim(nOpc, nPesNew, nCalPVC, nCalBri)
                 lCont := .t.
           End Transaction
        ElseIf nOpcA == 0
        Endif
     Endif

     If lFiltro 
        U_PCPX01_6(1)
     Endif
     DbSelectArea("SZM")
     DbSetOrder(1)

Return Nil

/********************************************************************************************/
/*** SIButton - Monta a enchoice bar da Rotina PCPX01_1.                                  ***/
/********************************************************************************************/
Static Function SIButton(bOk, bCancel, oDlgPad, cCodigo, cDescri, cRevisao, cTipo, cTipoPro,cPosIpi, nOpc)
       Local oBar
       DEFINE BUTTONBAR oBar SIZE 25, 25 3D TOP OF oDlgPad
       DEFINE BUTTON RESOURCE "S4WB005N" OF oBar       ACTION NaoDisp()           //TOOLTIP OemToAnsi("Recortar")
       DEFINE BUTTON RESOURCE "S4WB006N" OF oBar       ACTION NaoDisp()           //TOOLTIP OemToAnsi("Copiar")
       DEFINE BUTTON RESOURCE "S4WB007N" OF oBar       ACTION NaoDisp()           //TOOLTIP OemToAnsi("Colar")
       DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora()       //TOOLTIP OemToAnsi("Calculadora...")
       DEFINE BUTTON RESOURCE "S4WB009N" OF oBar       ACTION Agenda()           // TOOLTIP OemToAnsi("Agenda...")
       DEFINE BUTTON RESOURCE "S4WB010N" OF oBar       ACTION OurSpool()          //TOOLTIP OemToAnsi("Gerenciador de Impressão...")
       DEFINE BUTTON RESOURCE "S4WB016N" OF oBar GROUP ACTION HelProg()           //TOOLTIP OemToAnsi("Help de Programa...")

       //If !(cNumEmp == "01010104")
          DEFINE BUTTON RESOURCE "S4WB007N" OF oBar    ACTION U_fMonOpe(nOpc, cCodigo, cRevisao, cDescri, @aHeader, @aCols)  TOOLTIP OemToAnsi("Operações...")
          DEFINE BUTTON RESOURCE "S4WB009N" OF oBar    ACTION U_fFichaOP(cCodigo, cRevisao, cDescri)                         TOOLTIP OemToAnsi("Ficha de Processo...")
          If cTipo $ "PI" .and. SubStr(Alltrim(cCodigo),11,2) $ "00.99"
             DEFINE BUTTON RESOURCE "CONTAINR" OF oBar ACTION fIncrPA(nOpc, @aHeader, @aCols, cCodigo, cRevisao, cTipoPro)   TOOLTIP OemToAnsi("Embalagens")
          Endif
       //Endif
       DEFINE BUTTON oBtOk RESOURCE "OK" OF oBar GROUP ACTION ( lOk := Eval(bOk)) //TOOLTIP OemToAnsi("<Ctrl + O>")
       SetKEY(15,oBtOk:bAction)  // K_CTRL_O

       DEFINE BUTTON oBtCan RESOURCE "CANCEL" OF oBar ACTION ( Eval(bCancel))     //TOOLTIP OemToAnsi("<Ctrl + X>")
       SetKEY(24,oBtCan:bAction) // K_CTRL_X

       oBar:bRClicked := { || AllwaysTrue() }

Return NIL
 


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
  ±±ºPrograma  ³ PCPX01_6 ºAutor  ³ Luís Gustavo       º Data ³  10/03/04   º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºDesc.     ³ Filtra registros pendentes.                                º±±
  ±±º          ³                                                            º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºUso       ³ BRASILUX                                                   º±±
  ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*
User Function PCPX01_6(nOnOff)
	
     Local cFilAux := ''   
     Local cAux,aAux,nReg
		_cFiltro   := cFiltBM
     	If nOnOff == 1      // Liga Filtro Inicial
     		if !empty(_cFiltro)
     			_cFiltro += " .AND. "
     		endif 
     		_cFiltro += '(ZM_STATUS != "AC") .AND. (ZM_STATUS != "RE")'
        	lFiltro := .t.
        	nIniFil := 2

     	ElseIf nOnOff == 2  // Desliga Filtro
            lFiltro := .f.
            nIniFil := 1
		Endif                     

		dbselectarea("SZM")
   
		if oObjBrow:Filtrate()
			nReg := recno()
			oObjBrow:DeleteFilter("Pendentes") 
			dbgoto(nReg)
		endif
		
		if !empty(_cFiltro)
		  	oObjBrow:AddFilter("Pendentes",_cFiltro,,.t.,,,,"Pendentes")
		endif            
Return
*/


User Function PCPX01_6(nOnOff,nOpcFil)

	_cFiltro   := cFiltBM
    If nOnOff ==1 
	    lFiltro := .t.
        nIniFil := 2
	  	If !Empty(_cFiltro)
   			_cFiltro += " .AND. "
   		Endif 
	   	If nOpcFil == 1 // Filtra Todos os Pendentes
	   		_cFiltro += '(ZM_STATUS != "AC") .AND. (ZM_STATUS != "RE")'
		    oObjBrow:CleanExFilter()
			oObjBrow:DeleteFilter("Pendentes Diretoria") 
			oObjBrow:AddFilter("Todos os Pendentes",_cFiltro,,.t.,,,,"Todos os Pendentes") 	
	    	oObjBrow:SetUseFilter(.T.)
	    	oObjBrow:ExecuteFilter (.T.) // executa o filtro 			
			nReg := recno()
			DbGoto(nReg)
	    	oObjBroW:GoTo(nReg)
	   	Elseif nOpcFil == 2 // Filtra Diretoria
	   		_cFiltro += '(ZM_STATUS = "EA") '        		
		    oObjBrow:CleanExFilter()
			oObjBrow:DeleteFilter("Todos os Pendentes") 
			oObjBrow:AddFilter("Pendentes Diretoria",_cFiltro,,.t.,,,,"Pendentes Diretoria")
			oObjBrow:SetUseFilter(.T.)			
			nReg := recno()
			DbGoto(nReg)
	    	oObjBroW:GoTo(nReg)
	   	Endif
	Elseif nOnOff == 2  // Desliga Filtro Ativo    	
        lFiltro := .f.
        nIniFil := 1
		If oObjBrow:Filtrate()
			nReg := recno()
	    	oObjBrow:CleanExFilter()
			oObjBrow:DeleteFilter("Todos os Pendentes") 
			oObjBrow:DeleteFilter("Pendentes Diretoria")
		    oObjBrow:GetFilterDefault()
		    oObjBrow:SetUseFilter(.F.)
			DbGoto(nReg)
	    	oObjBroW:GoTo(nReg)
        Endif
	Endif     	
 
	Dbselectarea("SZM")
   

           
	//oObjBrow:Refresh(.T.)   
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
  ±±ºPrograma  ³ PCPX01_7 ºAutor  ³ Luís Gustavo       º Data ³  10/03/04   º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºDesc.     ³ Mostra legenda do status dos registros.                    º±±
  ±±º          ³                                                            º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºUso       ³ BRASILUX                                                   º±±
  ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/




User Function PCPX01_7()
     BrwLegenda(OemToAnsi("Legenda"), "Status", { {"DISABLE"    ,"Analise Química"   } ,;
                                                  {"BR_AMARELO" ,"Analise PCP"       } ,;
                                                  {"BR_AZUL"    ,"Analise Diretoria" } ,;
                                                  {"ENABLE"     ,"Aprovado"          } ,;
                                                  {"BR_PRETO"   ,"Rejeitado"         } ,;
                                                  {"BR_CINZA"  ,"Retorno Status"    } })
     If lFiltro
        U_PCPX01_6(1)
     Endif
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fIncrPA  ºAutor  ³ Luís Gustavo       º Data ³  06/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a inclusão de produtos acabados.                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fIncrPA(nOpc, aHeaderA, aColsA, cCodigo, cRevisao, cTipoPro)
       Local nOpcb        := 0
       Local aAltGetDados := Iif(nOpc == 1, {}, {"ZP_EMB"} )
       Local nOpcG        := Iif(nOpc == 1, 2, 3)
       //Local lVirtual     := .t.
       Local cFieldOk     := Iif( nOpc == 1, "AllwaysTrue()", "AllwaysTrue()" )
       Local cLinOk       := Iif( nOpc == 1, "AllwaysTrue()", "AllwaysTrue()" )
       Local cTudoOk      := Iif( nOpc == 1, "AllwaysTrue()", "U_fTudInc()"   )
       Local nLinhas      := 20
       Local lAchou 		:=.F.
       //Local cQry1        := ""
       Local nX
       Local _lOpen        := .F. //LGS#20200210 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200210 - Adequação para release 12.1.25
       Private aHeader    := {}
       Private aCols      := {}
       Private nUsado     := 0
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta o array aHeader para a GetDados()                      ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200210 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0

       If !_lOpen //LGS#20200210 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SZP")
       While !Eof() .And. (X3_ARQUIVO == "SZP")
             IF X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. !(TRIM(X3_CAMPO) $ "ZP_FILIAL") .And. !(TRIM(X3_CAMPO) $ "ZP_CODIGO") .And. !(TRIM(X3_CAMPO) $ "ZP_REVISAO")
	            nUsado := nUsado+1
	            AADD(aHeader, { Trim(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
             EndIf
             dbSkip()
       Enddo*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("SZP") )
       While !Eof() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SZP")
             IF X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .And. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .And. !( TRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZP_FILIAL") .And. !( TRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZP_CODIGO") .And. !( TRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZP_REVISAO")
	            nUsado := nUsado+1
	            aAdd(aHeader,{ TRIM( ( _cAliasSX3 )->( X3_TITULO ) ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
             EndIf
             dbSkip()
       Enddo

     /*
   	 If ChkFile("TCE")
 		DbSelectArea("TCE")
	   	DbCloseArea()
     Endif       
     // PROCURAR PRIMEIRO NA SZP 
     cQry1 += " SELECT DISTINCT ZP_FILIAL, ZP_CODIGO, ZP_EMB "
     cQry1 += " FROM "+RetSqlName("SZP")+" SZP WITH (NOLOCK) "
     cQry1 += " WHERE SZP.ZP_FILIAL  = '"+xFilial("SZP")+"' "
     cQry1 += "  AND SZP.D_E_L_E_T_ = '' "
     cQry1 += "  AND SZP.ZP_CODIGO ='"+Alltrim(cCodigo)+"'"
     cQry1 += " ORDER BY SZP.ZP_EMB "

     TCQuery cQry1 ALIAS "TCE" NEW
     DbSelectArea("TCE")
     DbGoTop()
      
     While !Eof() .and. (xFilial("SZP") == TCE->ZP_FILIAL) .and. (Alltrim(cCodigo) == Alltrim(TCE->ZP_CODIGO))
	    lAchou :=.t.
	 	aAdd(aCols, Array(nUsado + 1) )
	 	For nX := 1 to nUsado
			If aHeader[nX][10] $ "R"
            	aCols[Len(aCols)][nX] := Alltrim(TCE->ZP_EMB)
   			ElseIf aHeader[nX][10] $ "V"
      			aCols[Len(aCols)][nX] := Posicione("SZ5", 1, xFilial("SZ5")+aCols[Len(aCols)][1], "Z5_DESCR")
         	Endif
      	Next
	    aCols[Len(aCols)][nUsado + 1] := .f.
        DbSelectArea("TCE")
        DbSkip()
	 Enddo
     */
     If !lAchou 
     	DbSelectArea("SZP")
     	DbSetOrder(1)
	    DbSeek(xFilial("SZP")+cCodigo+cRevisao,.t.)
     	If Found()
        	While !Eof() .and. (xFilial("SZP") == SZP->ZP_FILIAL) .and. (Alltrim(cCodigo) == Alltrim(SZP->ZP_CODIGO)) .and. (cRevisao == SZP->ZP_REVISAO)
	              AADD(aCols, Array(nUsado + 1) )
    	          For nX := 1 to nUsado
        	          //If (Substr(Alltrim(cCodigo),11,2)$ '00' .and. Posicione("SZ5", 1, xFilial("SZ5")+aCols[Len(aCols)][1], "Z5_UMEMB") $ 'L') .or. (Substr(Alltrim(cCodigo),11,2)$ '99' .and. Posicione("SZ5", 1, xFilial("SZ5")+aCols[Len(aCols)][1], "Z5_UMEMB") $ 'K')
        	          	 If !aHeader[nX][2] ==  'ZP_DESCEMB' 
	                     	aCols[Len(aCols)][nX] := FieldGet(FieldPos(aHeader[nX][2]))
    	              	 Else
        	             	aCols[Len(aCols)][nX] := Posicione("SZ5", 1, xFilial("SZ5")+aCols[Len(aCols)][1], "Z5_DESCR")
	                     Endif 
	   				  //Endif
	              Next
    	          aCols[Len(aCols)][nUsado + 1] := .f.
	              DbSelectArea("SZP")
    	          DbSkip()
	        Enddo
    	ElseIf cTipoPro $ "PE"
	            DbSelectArea("SB1")
    	        DbSetOrder(1)
        	    DbSeek(xFilial("SB1")+SubStr(Alltrim(cCodigo), 1, 10),.t.)
            	If Found()
	               While !Eof() .and. SubStr(Alltrim(SB1->B1_COD), 1, 10) == SubStr(Alltrim(cCodigo), 1, 10)
    	                 If !SubStr(Alltrim(SB1->B1_COD),11,02) $ "00.99"
        	                AADD(aCols, Array(nUsado + 1) )
            	            For nX := 1 to nUsado
	                            If aHeader[nX][10] $ "R"
    	                           aCols[Len(aCols)][nX] := SubStr(SB1->B1_COD,11,02)
        	                    ElseIf aHeader[nX][10] $ "V"
            	                       aCols[Len(aCols)][nX] := Posicione("SZ5", 1, xFilial("SZ5")+aCols[Len(aCols)][1], "Z5_DESCR")
                	            Endif
                    	    Next
	                        aCols[Len(aCols)][nUsado + 1] := .f.
    	                 Endif
        	             DbSelectArea("SB1")
            	         DbSkip()
	               Enddo
	            Else
    	           AADD(aCols, Array(nUsado + 1) )
        	       For nX := 1 to nUsado
            	       If aHeader[nX][10] $ "R"
	                      aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2])
    	               ElseIf aHeader[nX][10] $ "V"
        	                  aCols[Len(aCols)][nX] := ""
            	       Endif
	               Next
    	           aCols[Len(aCols)][nUsado + 1] := .f.
        	    Endif
	    Else
    	    AADD(aCols, Array(nUsado + 1) )
	        For nX := 1 to nUsado
    	        If aHeader[nX][10] $ "R"
        	       aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2])
	            ElseIf aHeader[nX][10] $ "V"
    	               aCols[Len(aCols)][nX] := ""
        	    Endif
	        Next
    	    aCols[Len(aCols)][nUsado + 1] := .f.
	    Endif
     Endif
     aSort(aCols ,,,{|x,y| x[1] < y[1] })
     DEFINE MSDIALOG oDlgE TITLE OemToAnsi("Embalagens") From 9,0 to 20,50 of oMainWnd
            DbSelectArea("SZM")
            oGetE := MsGetDados():New( 15, 1, 80, 195, nOpcG, cLinOk, cTudoOk, "", .T., aAltGetDados, nOpcG, , nLinhas, cFieldOk)
            oGetE:oBrowse:NFreeze := 0
     ACTIVATE MSDIALOG oDlgE ON INIT EnchoiceBar(oDlgE, {|| nOpcb := 1, If(oGetE:TudoOk(), oDlgE:End(), nOpcb := 0)},{|| oDlgE:End() } ) CENTERED
     If nOpcb == 1
        DbSelectArea("SZP")
        //DbSetOrder(3)
        DbSetOrder(2)
        For nX := 1 to Len(aCols)
            DbSeek(xFilial("SZP")+cCodigo+cRevisao+aCols[nX][1],.t.)
            //If Substr(Alltrim(cCodigo),11,2) =='99' .and. Posicione("SZ5", 1, xFilial("SZ5")+aCols[nX][1], "Z5_UMEMB") == 'L'
            //	MsgStop ("Não é possível escolher embalagem em Litro para produtos desenvolvidos em KG")
            //	DbSelectArea("SZP")
            //	DbCloseArea()
            //	Return
			//Elseif Substr(Alltrim(cCodigo),11,2) =='00' .and. Posicione("SZ5", 1, xFilial("SZ5")+aCols[nX][1], "Z5_UMEMB") == 'K'
            //	MsgStop ("Não é possível escolher embalagem em Kg para produtos desenvolvidos em Litro")
            //	DbSelectArea("SZP")
            //	DbCloseArea()
            //	Return
            //Endif */
            If !Found()
               If !aCols[nX][Len(aHeader) + 1] == .t.
                  RecLock("SZP",.t.)
                     SZP->ZP_FILIAL  := xFilial("SZP")
                     SZP->ZP_CODIGO  := cCodigo
                     SZP->ZP_REVISAO := cRevisao
                     SZP->ZP_EMB     := aCols[nX][1]
                  MsUnLock()
               Endif	
            Else
               If !aCols[nX][Len(aHeader) + 1] == .t.
                  RecLock("SZP",.f.)
                     SZP->ZP_EMB := aCols[nX][1]
                  MsUnLock()
               Else
                  RecLock("SZP",.f.)
                     Delete
                  MsUnLock()
                  cQry := ""
                  cQry += "SELECT SZM.ZM_ID "
                  cQry += "FROM "+RetSqlName("SZM")+" SZM WITH (NOLOCK) "
                  cQry += "WHERE SZM.ZM_FILIAL = '"+xFilial("SZM")+"' "
                  cQry += "  AND SZM.ZM_CODIGO  = '"+cCodigo+"' "
                  cQry += "  AND SZM.ZM_REVISAO = '"+cRevisao+"' "
                  TCQUERY cQry ALIAS "TCQEMB" NEW
                  DbSelectArea("TCQEMB")
                  DbGoTop()
                  cId := TCQEMB->ZM_ID
                  DbSelectArea("TCQEMB")
                  DbCloseArea()
                  cQry := ""
                  cQry += "SELECT SZM.ZM_REVISAO, COUNT(*) AS QTDEMB "
                  cQry += "FROM "+RetSqlName("SZM")+" SZM WITH (NOLOCK) "
                  cQry += "WHERE SZM.ZM_FILIAL  = '"+xFilial("SZM")+"' "
                  cQry += "  AND SZM.ZM_CODIGO  = '"+SubStr(Alltrim(cCodigo),1,10)+aCols[nX][1]+"' "
                  cQry += "  AND SZM.ZM_STATUS  = 'RT' "
                  cQry += "  AND SZM.D_E_L_E_T_ = '' "
                  cQry += "  AND SZM.ZM_ID      = '"+cId+"' "
                  cQry += "GROUP BY SZM.ZM_REVISAO "
                  TCQUERY cQry ALIAS "TCQEMB" NEW
                  DbSelectArea("TCQEMB")
                  DbGoTop()
                  nQtd := TCQEMB->QTDEMB
                  cRev := TCQEMB->ZM_REVISAO
                  DbSelectArea("TCQEMB")
                  DbCloseArea()
                  If nQtd > 0
                     cQry := ""
                     cQry += "UPDATE "+RetSqlName("SZM")+" SET D_E_L_E_T_ = '*' "
                     cQry += "WHERE ZM_FILIAL = '"+xFilial("SZM")+"' AND ZM_CODIGO = '"+SubStr(Alltrim(cCodigo),1,10)+aCols[nX][1]+"' AND ZM_STATUS = 'RT' AND ZM_ID = '"+cId+"' AND D_E_L_E_T_ = '' "
                     TCSQLEXEC(cQry)
                     cQry := ""
                     cQry += "UPDATE "+RetSqlName("SZN")+" SET D_E_L_E_T_ = '*' "
                     cQry += "WHERE ZN_FILIAL = '"+xFilial("SZM")+"' AND ZN_CODIGO = '"+SubStr(Alltrim(cCodigo),1,10)+aCols[nX][1]+"' AND ZN_REVISAO = '"+cRev+"' AND D_E_L_E_T_ = '' "
                     TCSQLEXEC(cQry)
                  Endif
                  DbSelectArea("SZP")
               Endif
            Endif
        Next
     Endif
     aCols   := aColsA
     aHeader := aHeaderA
     n       := 1
     
       DbSelectArea( _cAliasSX3 )
       DbCloseArea()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCPX01_3 ºAutor  ³ Luís Gustavo       º Data ³  06/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Liberação de produtos em simulação.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCPX01_3()
     //Local cArea    := alias()
     //Local aAreaAnt := U_PegaArea({"SZM","SZT"})
     Local aTitles   := { OemToAnsi("Marcar para "), OemToAnsi("Formulação") }
     Local aMarcacao := {}
     Local cIdentif  := SZM->ZM_ID
     Local aLogPro   := {}
     Local cTxtHis
     Local cRespons  := ''
     Local cProdRev  := ''
     Local cTxtMemo  := ''
     Local aDadVig   := {}
     Local aTitVig   := {}
     Local aDadAtu   := {}
     Local aTitAtu   := {}
     Local bPage     := {|n| Eval(oFolder:bSetOption, 1), oFolder:nOption := 1, fLibPag(n, @aGeral, @aMarcacao, @aTitVig, @aDadVig, @oForVig) }
     Private cCodigo := ""
     Private cDescri := "" 
     Private cPosIpi := ""
     Private cExNcm  := ""
     Private cTipo   := ""
     Private cRevisao:= SZM->ZM_REVISAO
     Private cLocal  := ""
     Private cTpProd := Iif(SZM->ZM_TIPOPRO == 'PE', 'EXISTENTE', 'NOVO')
     Private cPosAtu := ""
     Private nPerFor := 0
     Private nPesEsp := 0
     Private nCusRea := 0
     Private nCusDol := 0
     Private nPrcVig := 0
     Private nPerNew := 0
     Private nPesNew := 0
     Private nCusRNe := 0
     Private nCusDNe := 0
     Private nPrcNew := 0
     Private nVarPrc := 0
     Private nOldPVC := 0
     Private nOldBri := 0
     Private nNewPVC := 0
     Private nNewBri := 0
     Private nCusOuO    := 0 ; Private oCusOuO
     Private nCusOuN    := 0 ; Private oCusOuN
     Private oCusVig ; Private oCusAtu
     Private cBitMap := ""
     Private lSaida  := .f.
     Private aGeral  := { "", 0, Nil, Nil }

     If lFiltro
        U_PCPX01_6(2)
        lFiltro := .t. //Como o filtro é desligado dentro da rotina de liberação, então deve-se colocar verdadeiro 
                       //na variável para que na saida da rotina seja feito o filtro novamente.
     Endif
	if !EstaAutori(SZM->ZM_CODIGO)
		Alert("Acesso Não Autorizado!")
		return(.f.)
	endif 

     If SZM->ZM_STATUS $ 'AC.RE'
        MsgBox('Esse status não permite liberação !!!', 'Atenção', 'INFO')
        If lFiltro
           U_PCPX01_6(1)
        Endif
        Return
     Endif
     If !U_fVerPerm(SZM->ZM_RESPONS, SZM->ZM_STATUS, cAcessos, 4, SZM->ZM_CODIGO, Iif(SZM->ZM_STATUS == 'PP', 'PA', SZM->ZM_TIPO) )
        If lFiltro
           U_PCPX01_6(1)
        Endif
        Return
     Endif
	 //Iif( Empty( Iif( Empty(M->ZM_POSIPI), Iif( Len(Alltrim(M->ZM_CODIGO)) == 12, Posicione( "SZ6", 1, xFilial("SZ6")+SubStr(Alltrim(M->ZM_CODIGO), 1, 3)+SubStr(Alltrim(M->ZM_CODIGO), 4, 2)+SubStr(Alltrim(M->ZM_CODIGO), 6, 2), "Z6_CLASFIS"), "99999999"), M->ZM_POSIPI) ), "99999999", Iif( Len(Alltrim(M->ZM_CODIGO)) == 12, Posicione( "SZ6", 1, xFilial("SZ6")+SubStr(Alltrim(M->ZM_CODIGO), 1, 3)+SubStr(Alltrim(M->ZM_CODIGO), 4, 2)+SubStr(Alltrim(M->ZM_CODIGO), 6, 2), "Z6_CLASFIS"), "99999999") )
	 If Len(Alltrim(SZM->ZM_CODIGO)) == 12
	 	cPosIPI := ""
	 	dbselectarea("SZ6")
	 	dbsetorder(1)
	 	dbseek(xFilial("SZ6")+SubStr(Alltrim(SZM->ZM_CODIGO), 1, 3)+SubStr(Alltrim(SZM->ZM_CODIGO), 4, 2)+SubStr(Alltrim(SZM->ZM_CODIGO), 6, 2))
	 	if found()
	 		cPosIPI := SZ6->Z6_CLASFIS
	 		cExNcm := SZ6->Z6_EX_NCM
	 	else 
	    	If MsgYesNo("Cadastre primeiro a classificação do produto antes de liberá-lo para a próxima etapa. Deseja fazer isso agora ??"+CHR(13)+CHR(10)+(SZM->ZM_CODIGO)+".", "Atenção")	
			    U_BRFAT007()
	    		Return(.f.)
				//U_VoltaArea(aAreaAnt)
				//If !empty(cArea)
			 	//	DbSelectArea(cArea)
			 	//Endif 
			Else
				Return(.f.)
			Endif
		
		Endif
     Endif
     
     fBusHis(@aLogPro, SZM->ZM_ID, 1)

     If fLibPri( @aGeral, @aMarcacao, cIdentif )
        DbSelectArea(aGeral[GEL_ARQ])
        DEFINE MSDIALOG oDlg TITLE OemToAnsi("Análise de Formulas") FROM 000,000 TO 032,100 OF oMainWnd
        DEFINE FONT oFont SIZE 8,0 BOLD
               /**********************************************************************/
               /***                     CABEÇALHO DA APROVAÇÃO                     ***/
               /**********************************************************************/
               @ 013,001 GROUP oGrp1 TO 032,235 LABEL OemToAnsi('Dados do Produto')                                                                                      PIXEL OF oDlg
	           @ 018,005 MSGET oCodigo                VAR    cCodigo                PICTURE PesqPict("SZM","ZM_CODIGO" , 15) SIZE 050,09 WHEN .F.                        PIXEL OF oDlg
               @ 018,060 MSGET oDescri                VAR    cDescri                PICTURE PesqPict("SZM","ZM_DESCRIC", 30) SIZE 130,09 WHEN .F.                        PIXEL OF oDlg
               @ 018,195 MSGET oTipo                  VAR    cTipo                  PICTURE PesqPict("SZM","ZM_TIPO")        SIZE 012,09 WHEN .F. CENTER                 PIXEL OF oDlg
               @ 018,215 MSGET oLocal                 VAR    cLocal                 PICTURE PesqPict("SZM","ZM_LOCAL")       SIZE 012,09 WHEN .F. CENTER                 PIXEL OF oDlg

               @ 013,237 GROUP oGrp2 TO 032,290 LABEL OemToAnsi('Tipo do Produto')                                                                                       PIXEL OF oDlg
               @ 019,240 SAY   oTpProd                PROMPT cTpProd                                                         SIZE 070,09                  COLOR CLR_BLUE PIXEL OF oDlg FONT oFont

               @ 013,292 GROUP oGrp3 TO 032,320 LABEL OemToAnsi('Item(ns)')                                                                                               PIXEL OF oDlg
               @ 019,295 SAY   oPosAtu                PROMPT cPosAtu                                                         SIZE 020,09                 COLOR CLR_BLUE PIXEL OF oDlg FONT oFont

               @ 013,322 GROUP oGrp3 TO 032,396 LABEL OemToAnsi('Anterior / Próximo')                                                                                    PIXEL OF oDlg
               DEFINE SBUTTON FROM 017,326 TYPE 20 ACTION Eval(bPage,-1) ENABLE                                                                                                OF oDlg
               DEFINE SBUTTON FROM 017,363 TYPE 19 ACTION Eval(bPage,+1) ENABLE                                                                                                OF oDlg

               /**********************************************************************/
               /***                             FOLDERS                            ***/
               /**********************************************************************/
               oFolder            := TFolder():New( 033, 001, aTitles, {"HEADER"}, oDlg, , , , .T., .F., 394, 209 )
               oFolder:bSetOption := {|x| fLibFol(x, oFolder:nOption, oFolder, @aGeral, @aMarcacao) }

               /**********************************************************************/
               /***                FOLDER - MARCAR PARA - LIBERAÇÃO                ***/
               /**********************************************************************/
               aGeral[GEL_MRK]    := MsSelect():New(aGeral[GEL_ARQ], "TMP_OK", , aGeral[GEL_HF1], .F., "XX", {001, 001, 035, 391}, , , oFolder:aDialogs[1] )
               aGeral[GEL_MRK]:oBrowse:lCanAllMark := .F.
               aGeral[GEL_MRK]:bMark := {|| fMrkDis( @aGeral, @aMarcacao ) }


               @ 037,001 GROUP oGrp4 TO 194,391 LABEL OemToAnsi('Histórico')                                                                                               PIXEL OF oFolder:aDialogs[1]
               @ 043,003 GROUP oGrp5 TO 112,389 LABEL OemToAnsi('Movimentos')                                                                                             PIXEL OF oFolder:aDialogs[1]
               @ 048,006 LISTBOX oTxtHis VAR cTxtHis FIELDS HEADER TitSx3("ZT_ID")[1], TitSx3("ZT_PROCESS")[1], TitSx3("ZT_STATUS")[1], "Geração"  SIZE 379,060          PIXEL OF oFolder:aDialogs[1] ON CHANGE fBusHis( aLogPro, , 2, oTxtHis:nAt, @oTxtMemo, @cTxtMemo, @oRespons, @cRespons, @oProdRev, @cProdRev)
               @ 114,003 GROUP oGrp6 TO 133,070 LABEL OemToAnsi('Responsavel')                                                                                            PIXEL OF oFolder:aDialogs[1]
               @ 119,006 MSGET oRespons   VAR cRespons                                                                                              SIZE 060,009 WHEN .F. PIXEL OF oFolder:aDialogs[1]
               @ 135,003 GROUP oGrp7 TO 154,070 LABEL OemToAnsi('Produto / Revisão')                                                                                      PIXEL OF oFolder:aDialogs[1]
               @ 140,006 MSGET oProdRev   VAR cProdRev                                                                                              SIZE 060,009 WHEN .F. PIXEL OF oFolder:aDialogs[1]
               @ 114,072 GROUP oGrp8 TO 191,389 LABEL OemToAnsi('Motivo / Justificativa da alteração')                                                                    PIXEL OF oFolder:aDialogs[1]
               oTxtMemo   := TMultiGet():New( 119, 075, { |u| If(PCount() > 0, cTxtMemo := u, cTxtMemo) }, oGrp8, 312, 068, , , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .T., , , .F., , )
               //@ 119,075 MSGET oTxtMemo   VAR cTxtMemo                                                                                              SIZE 312,068 WHEN .F. PIXEL OF oFolder:aDialogs[1]
		       If SZM->ZM_STATUS $ 'EA'
		           oBtn1Lib   := TButton():New( 216, 010, "Observação", oDlg, {|| MsgRun(OemToAnsi('Observações da liberação do produto ...... Aguarde....'), '', {|| CursorWait(), U_fGrvLDir(SZT->ZT_ID), CursorArrow() } ) }, 056, 012, , , , .T., , "", , , , .F. )
		       Endif
		       
               bHisLine := { || { aLogPro[oTxtHis:nAt,1], aLogPro[oTxtHis:nAt,2], aLogPro[oTxtHis:nAt,3], aLogPro[oTxtHis:nAt,4] } }

               oTxtHis:SetArray(aLogPro)
               oTxtHis:bLine    := bHisLine
               oTxtHis:GoTop()
               /**********************************************************************/
               /***                      FOLDER - FORMULAÇÃO                       ***/
               /**********************************************************************/
               @ 001,050 SAY OemToAnsi("FORMULA VIGENTE")                                                  SIZE 100,009 COLOR CLR_BLUE  PIXEL OF oFolder:aDialogs[2] FONT oFont
               @ 010,001 GROUP oGrp9 TO 039,195 LABEL OemToAnsi('Especificações...')                                    COLOR CLR_HRED  PIXEL OF oFolder:aDialogs[2]
               @ 015,025 SAY OemToAnsi("% Fórmula: ")                                                      SIZE 030,009                 PIXEL OF oFolder:aDialogs[2]
               @ 014,055 MSGET oPerFor                VAR nPerFor                PICTURE '@E 999.99%'      SIZE 030,009 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]
               @ 015,105 SAY OemToAnsi("P. Especif.: ")                                                    SIZE 030,009                 PIXEL OF oFolder:aDialogs[2]
               @ 014,135 MSGET oPesEsp                VAR nPesEsp                PICTURE '@E 99999.99999'  SIZE 040,009 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]
               @ 027,025 SAY OemToAnsi("PVC:")                                                             SIZE 030,009                 PIXEL OF oFolder:aDialogs[2]
               @ 026,055 MSGET oOldPVC                VAR nOldPVC                PICTURE '@E 999.999'      SIZE 030,009 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]
               @ 027,105 SAY OemToAnsi("Brilho 60%")                                                       SIZE 030,009                 PIXEL OF oFolder:aDialogs[2]
               @ 026,135 MSGET oOldBri                VAR nOldBri                PICTURE '@E 999.999'      SIZE 030,009 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]
               
               @ 040,001 GROUP oGrp1 TO 069,195 LABEL  OemToAnsi('Totais...')                                           COLOR CLR_HRED  PIXEL OF oFolder:aDialogs[2]
               @ 045,020 SAY OemToAnsi("Custo(R$/"+Alltrim(aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][12])+"): ")  SIZE 040,009                 PIXEL OF oFolder:aDialogs[2]
               @ 044,055 MSGET oCusRea                VAR nCusRea                PICTURE '@E 999,999.999'    SIZE 040,009 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]
               If Alltrim(aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][12]) $ 'L' .and. Alltrim(aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][9]) $ 'PI'
                  @ 057,020 SAY oCusVig VAR OemToAnsi("Custo(R$/K): ")       SIZE 040,09                 PIXEL OF oFolder:aDialogs[2]
                  @ 056,055 MSGET oCusOuO VAR nCusOuO PICTURE '@E 999,999.999' SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]
               Endif
               @ 045,105 SAY OemToAnsi("Custo(U$): ")                                                      SIZE 030,009                 PIXEL OF oFolder:aDialogs[2]
               @ 044,135 MSGET oCusDol                VAR nCusDol                PICTURE '@E 999,999.999'    SIZE 040,009 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]
               @ 057,025 SAY oSayVig VAR OemToAnsi("Prç Venda:")                                           SIZE 030,009                 PIXEL OF oFolder:aDialogs[2]
               @ 056,055 MSGET oPrcVig                VAR nPrcVig                PICTURE '@E 999,999.999'    SIZE 040,009 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]

               @ 071,001 LISTBOX oForVig FIELDS TITLE ""                                                   SIZE 193,123 	            PIXEL OF oFolder:aDialogs[2]
               /*************************************************************************************************/
               @ 001,260 SAY OemToAnsi("REVISÃO: "+aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][4]) SIZE 100,009 COLOR CLR_BLUE  PIXEL OF oFolder:aDialogs[2] FONT oFont
               @ 010,197 GROUP oGrpA TO 039,391 LABEL OemToAnsi('Especificações...')                                    COLOR CLR_HRED  PIXEL OF oFolder:aDialogs[2]
               @ 015,222 SAY OemToAnsi("% Fórmula: ")                                                              SIZE 030,009                 PIXEL OF oFolder:aDialogs[2]
               @ 014,252 MSGET oPerNew                VAR nPerNew                PICTURE '@E 999.99%'              SIZE 030,009 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]
               @ 015,300 SAY OemToAnsi("P. Especif.: ")                                                            SIZE 030,009                 PIXEL OF oFolder:aDialogs[2]
               @ 014,332 MSGET oPesNew                VAR nPesNew                PICTURE '@E 99999.99999'          SIZE 040,009 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]
               @ 027,222 SAY OemToAnsi("PVC:")                                                                     SIZE 030,009                 PIXEL OF oFolder:aDialogs[2]
               @ 026,252 MSGET oNewPVC                VAR nNewPVC                PICTURE '@E 999.999'              SIZE 030,009 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]
               @ 027,300 SAY OemToAnsi("Brilho 60%")                                                               SIZE 030,009                 PIXEL OF oFolder:aDialogs[2]
               @ 026,332 MSGET oNewBri                VAR nNewBri                PICTURE '@E 999.999'              SIZE 030,009 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]

               @ 040,197 GROUP oGrp1 TO 069,391 LABEL  OemToAnsi('Totais...')                                           COLOR CLR_HRED  PIXEL OF oFolder:aDialogs[2]
               @ 045,217 SAY OemToAnsi("Custo(R$/"+Alltrim(aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][12])+"): ") SIZE 040,009                 PIXEL OF oFolder:aDialogs[2]
               @ 044,252 MSGET oCusRNe                VAR nCusRNe                PICTURE '@E 999,999.999'            SIZE 040,009 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]
               If Alltrim(aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][12]) $ 'L' .and. Alltrim(aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][9]) $ 'PI'
                  @ 057,217 SAY oCusAtu VAR OemToAnsi("Custo(R$/K): ")       SIZE 040,09                 PIXEL OF oFolder:aDialogs[2]
                  @ 056,252 MSGET oCusOuN VAR nCusOuN PICTURE '@E 999,999.999' SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]
               Endif
               @ 045,300 SAY OemToAnsi("Custo(U$): ")                                                              SIZE 030,009                 PIXEL OF oFolder:aDialogs[2]
               @ 044,332 MSGET oCusDNe                VAR nCusDNe                PICTURE '@E 999,999.999'            SIZE 040,009 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]
               @ 057,222 SAY oSayPrc VAR OemToAnsi("Prç Venda:")                                                   SIZE 030,009                 PIXEL OF oFolder:aDialogs[2]
               @ 056,252 MSGET oPrcNew                VAR nPrcNew                PICTURE '@E 999,999.999'            SIZE 040,009 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]
               @ 057,300 SAY oVarPrc VAR OemToAnsi("Variação:")                                                    SIZE 035,009                 PIXEL OF oFolder:aDialogs[2]
               @ 056,332 MSGET oVarPrc                VAR nVarPrc                PICTURE '@E 999,999.999'            SIZE 040,009 COLOR CLR_HBLUE PIXEL OF oFolder:aDialogs[2]
               @ 053,376 BITMAP oBitMap               RESOURCE cBitMap                                             SIZE 015,015 ADJUST          PIXEL OF oFolder:aDialogs[2] NO BORDER
               @ 071,197 LISTBOX oForAtu FIELDS TITLE ""                                                           SIZE 193,123 	            PIXEL OF oFolder:aDialogs[2]
               /*************************************************************************************************/
               U_fBusVig(aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][2], aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][4], aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][9], @aTitVig, @aDadVig, @oPerFor, @nPerFor, @oPesEsp, @nPesEsp, @oCusRea, @nCusRea, @oCusDol, @nCusDol, @oPrcVig, @nPrcVig, ;
                         @nOldPVC, @nOldBri, @aGeral, 2, @aMarcacao, @oSayVig, @nCusOuO, @oCusOuO, @oCusVig )

               U_fMonHea(@aTitAtu)
               U_fMonCol(@aDadAtu, @aTitAtu, 1, aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][2], aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][4], aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][6], aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][9], aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][12], aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][14] )

               oDlg:nStyle     := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
               oForVig:aHeaders  := aTitVig
               oForVig:SetArray(aDadVig)
               oForVig:bLine     := {|| oForVig:aArray[oForVig:nAt] }

               oForAtu:aHeaders  := aTitVig
               oForAtu:SetArray(aDadAtu)
               oForAtu:bLine     := {|| oForAtu:aArray[oForAtu:nAt] }

               oPerFor:lReadOnly := .t. ; oPesEsp:lReadOnly := .t. ; oCusRea:lReadOnly := .t. 
               oCusDol:lReadOnly := .t. ; oPrcVig:lReadOnly := .t. ; oPerNew:lReadOnly := .t.
               oPesNew:lReadOnly := .t. ; oCusRNe:lReadOnly := .t. ; oCusDNe:lReadOnly := .t. 
               oPrcNew:lReadOnly := .t. ; oVarPrc:lReadOnly := .t. ; oOldPVC:lReadOnly := .t.
               oOldBri:lReadOnly := .t. ; oNewPVC:lReadOnly := .t. ; oNewBri:lReadOnly := .t.
               If Alltrim(aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][12]) $ 'L' .and. Alltrim(aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][9]) $ 'PI'
                  oCusOuO:lReadOnly := .t. ; oCusOuN:lReadOnly := .t.
               Endif
        ACTIVATE MSDIALOG oDlg VALID lSaida ON INIT fLibEnB(oDlg, {|| lSaida := .t., oDlg:End() }, {|| lSaida := .t., oDlg:End() }, bPage, @aGeral, cCodigo, cRevisao, @aMarcacao, @lSaida) CENTERED
        If ( Select(aGeral[GEL_ARQ])<> 0 )
           DbSelectArea(aGeral[GEL_ARQ])
           DbCloseArea()
           If Type("oTempTable") == "O"
              oTempTable:Delete()
           Endif
        EndIf
     Endif
     If lFiltro 
        U_PCPX01_6(1)
        lFiltro := .t.
     Endif
     DbSelectArea("SZM")
     DbSetOrder(1)
Return


/********************************************************************************************/
/*** fGrvLDir - BOTÃO PARA GRAVAR OBSERVAÇÃO NA LIBERAÇÃO DA DIRETORIA CHAMADO 000689   ***/
/********************************************************************************************/

User Function fGrvLDir(cID)

       //Local cMenssag := ""
       Local nOpcA    := 0
       Private cMGet1Mo

       SetPrvt("oDlg1Mot", "oMGet1Mo", "oBtn1Mot")
       
       //If Empty(aMarcacao[1][1][1])
       oDlg1Mot   := MSDialog():New( 091, 232, 260, 560, "Observações para a Fórmula", , , .F., , , , , , .T., , , .T. )
       oMGet1Mo   := TMultiGet():New( 004, 004, {|u| If(PCount() > 0, cMGet1Mo := u, cMGet1Mo)}, oDlg1Mot, 156, 060, , , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .F., , , .F., ,  )
       oBtn1Mot   := TButton():New( 068, 122, "Confirma", oDlg1Mot, {|| nOpcA := 1, oDlg1Mot:End() }, 037, 012, , , , .T., , "", , , , .F. )

       oDlg1Mot:Activate(, , , .T.)
       If nOpcA == 0
          MsgStop("Atenção, não pode haver devolução da fórmula sem o motivo.", "Atenção...")
          Return
       Else
       	   If !Empty(cMGet1Mo)
                DbSelectArea("SZT")
                RecLock("SZT", .t.)
                   cMotDev := "Observações Diretoria"+Chr(10)+Chr(13)
                   cMotDev += cMGet1Mo
                   SZT->ZT_FILIAL  := xFilial("SZT")
                   SZT->ZT_ID      := cID
                   SZT->ZT_PROCESS := "SI"
                   SZT->ZT_STATUS  := "OD"
                   SZT->ZT_LOG     := cMotDev
                   SZT->ZT_USUARIO := cUserName
                   SZT->ZT_DATAGER := dDataBase
                   SZT->ZT_HORAGER := Time()
                MsUnLock()
           Else
                MsgStop("Atenção, é necessário digitar alguma observação antes de salvar !!", "Verifique...")
                Return
           Endif
       Endif
       //Endif
Return

/********************************************************************************************/
/*** FLIBPRI - VERIFICAÇÃO E MONTAGEM DAS VARIAVEIS DA LIBERACAO DE PRODUTOS              ***/
/********************************************************************************************/
Static Function fLibPri(aGeral, aMarcacao, cIdentif)
       Local aArea     := GetArea()
       Local aAreaAnt   := u_PegaArea( {"SB1","SZM"} )
       Local aAreaSX3  := SX3->(GetArea())
       Local aStru     := {}
       Local nUsadoSZM := 0
       //Local nUsadoSG1 := 0
       Local aCampoSZM := {}
       Local cQuerySZM := ""
       Local aStrutSZM := SZM->(dbStruct())
       Local cAliasSZM:= "PCPX01"
       Local nX,cTipoPro
       Local _lOpen        := .F. //LGS#20200210 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200210 - Adequação para release 12.1.25

       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200210 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0

       If !_lOpen //LGS#20200210 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif
       
       aMarcacao := {}
       aGeral[GEL_HF1] := {}  // Matriz para marcarção do registro

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Efetua a montagem da planilha de marcação                              ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       MsSeek("SZM")
       While ( !Eof() .And. SX3->X3_ARQUIVO == "SZM" )
             If ( X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_CONTEXT<>"V" .And. Trim(X3_CAMPO) <> "ZM_MOTIVO" )
                nUsadoSZM++
                AADD(aCampoSZM,{SX3->X3_CAMPO,SX3->X3_PICTURE})
             EndIf
             DbSelectArea("SX3")
             DbSkip()
       EndDo*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( MsSeek("SZM") )
       While ( !Eof() .And. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SZM" )
             If ( X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .And. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .And. ( _cAliasSX3 )->( X3_CONTEXT ) <> "V" .And. Trim( ( _cAliasSX3 )->( X3_CAMPO ) ) <> "ZM_MOTIVO" )
                nUsadoSZM++
                AADD( aCampoSZM, { ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ) } )
             EndIf
             DbSelectArea( _cAliasSX3 )
             ( _cAliasSX3 )->( DbSkip() )
       EndDo
       /********************************************************************************************************************************/
       aadd(aGeral[GEL_HF1], {"TMP_OK"     , "", "", ""})
       aadd(aGeral[GEL_HF1], {"TMP_CODIGO" , "", RetTitle("ZM_CODIGO") , PesqPict("SZM","ZM_CODIGO" ) } )
       aadd(aGeral[GEL_HF1], {"TMP_DESCRI" , "", RetTitle("ZM_DESCRIC"), PesqPict("SZM","ZM_DESCRIC") } )
       aadd(aGeral[GEL_HF1], {"TMP_REVISA" , "", RetTitle("ZM_REVISAO"), PesqPict("SZM","ZM_REVISAO") } )
       aadd(aGeral[GEL_HF1], {"TMP_RESPON" , "", RetTitle("ZM_RESPONS"), PesqPict("SZM","ZM_RESPONS") } )

       /*DbSelectArea("SX3")
       DbSetOrder(2)
       MsSeek("ZM_CODIGO")
       aadd(aStru, {"TMP_OK"    , "C"         , 2              , 0               } )
       aadd(aStru, {"TMP_CODIGO", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
       MsSeek("ZM_DESCRIC")
       aadd(aStru, {"TMP_DESCRI", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
       MsSeek("ZM_REVISAO")
       aadd(aStru, {"TMP_REVISA", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
       MsSeek("ZM_RESPONS")
       aadd(aStru, {"TMP_RESPON", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
       MsSeek("ZM_ID")
       aadd(aStru, {"TMP_ID"    , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
       MsSeek("ZM_CATALIS")
       aadd(aStru, {"TMP_CATALI", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
       MsSeek("ZM_RELCAT")
       aadd(aStru, {"TMP_RELCAT", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
       MsSeek("ZM_TIPO")
       aadd(aStru, {"TMP_TIPO"  , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
       MsSeek("ZM_LOCAL")
       aadd(aStru, {"TMP_LOCAL" , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
       MsSeek("ZM_TIPOPRO")
       aadd(aStru, {"TMP_TIPOPR", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )*/
       //LGS#20200210 - Adequação de release 12.1.25 e posteriores
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(2) )
       MsSeek("ZM_CODIGO")
       aadd(aStru, {"TMP_OK"    , "C"         , 2              , 0               } )
       aadd(aStru, {"TMP_CODIGO", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
       MsSeek("ZM_DESCRIC")
       aadd(aStru, {"TMP_DESCRI", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
       MsSeek("ZM_REVISAO")
       aadd(aStru, {"TMP_REVISA", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
       MsSeek("ZM_RESPONS")
       aadd(aStru, {"TMP_RESPON", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
       MsSeek("ZM_ID")
       aadd(aStru, {"TMP_ID"    , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
       MsSeek("ZM_CATALIS")
       aadd(aStru, {"TMP_CATALI", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
       MsSeek("ZM_RELCAT")
       aadd(aStru, {"TMP_RELCAT", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
       MsSeek("ZM_TIPO")
       aadd(aStru, {"TMP_TIPO"  , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
       MsSeek("ZM_LOCAL")
       aadd(aStru, {"TMP_LOCAL" , ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )
       MsSeek("ZM_TIPOPRO")
       aadd(aStru, {"TMP_TIPOPR", ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ) } )

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //aGeral[GEL_ARQ] := CriaTrab(aStru,.T.)
       //dbUseArea(.T., __LocalDrive, aGeral[GEL_ARQ], aGeral[GEL_ARQ], .F., .F.)
       aGeral[GEL_ARQ] := GetNextAlias()
       oTempTable := FWTemporaryTable():New( aGeral[GEL_ARQ] )
       oTemptable:SetFields( aStru )
       oTempTable:Create()
       /********************************************************************************************************************************/

       cQuerySZM := ""
       For nX := 1 To Len(aStrutSZM)
           cQuerySZM += ","+aStrutSZM[nX][1]
       Next nX
       cQuerySZM := "SELECT "+SubStr(cQuerySZM,2)+" "
       cQuerySZM += " FROM "+RetSqlName("SZM")+" SZM WITH (NOLOCK) "
       cQuerySZM += "WHERE SZM.ZM_FILIAL = '"+xFilial("SZM")+"' "
       cQuerySZM += "  AND SZM.ZM_ID     = '"+cIdentif+"' "
       cQuerySZM += "  AND SZM.D_E_L_E_T_ = '' "
       cQuerySZM += "  AND SZM.ZM_STATUS <> 'RT' "
       If SZM->ZM_STATUS $ "PP"
          cQuerySZM += "  AND SUBSTRING(SZM.ZM_CODIGO,11,2) NOT IN('00','99') "
          cQuerySZM += "  AND SZM.ZM_STATUS NOT IN('EE','RE','AC') "
       Endif
       If SZM->ZM_STATUS $ "EA"
          cQuerySZM += "  AND SZM.ZM_STATUS = 'EA' "
       Endif
       cQuerySZM += "ORDER BY SZM.ZM_TIPO DESC, SZM.ZM_CODIGO, SZM.ZM_REVISAO "
       //cQuerySZM := ChangeQuery(cQuerySZM)
       dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySZM),cAliasSZM,.T.,.T.)
       //TCQuery cQuerySZM ALIAS cAliasSZM NEW
       DbSelectArea((cAliasSZM))
       For nX := 1 To Len(aStrutSZM)
           If ( !aStrutSZM[nX][2] $ "C.M" )
              TcSetField(cAliasSZM, aStrutSZM[nX][1], aStrutSZM[nX][2], aStrutSZM[nX][3], aStrutSZM[nX][4])
           EndIf
       Next nX
       dbselectarea("SB1")
       dbsetorder(1)
       nX := 0
       cQuebra := ""
       DbSelectArea((cAliasSZM))
       While ( !Eof() .And. (cAliasSZM)->ZM_FILIAL == xFilial("SZM") .And. (cAliasSZM)->ZM_ID == cIdentif )
             If ( Empty(cQuebra) .Or. cQuebra <> ((cAliasSZM)->ZM_CODIGO+(cAliasSZM)->ZM_REVISAO) )
                aadd(aMarcacao, {})
                nX      := Len(aMarcacao)
                cQuebra := ((cAliasSZM)->ZM_CODIGO+(cAliasSZM)->ZM_REVISAO)
             Endif
             //Cleber(31/03/2021) -> Está dando erro na liberação da diretoria (não identificado) de produto existente
             //em SB1 sendo que em ZM_TIPOPRO está como PN (Produto Novo), tentando contornar o problema aqui
            cTipoPro := (cAliasSZM)->ZM_TIPOPRO
            if cTipoPro = "PN"
               dbselectarea("SB1")
               dbseek(xFilial("SB1")+(cAliasSZM)->ZM_CODIGO)
               if found()
                  cTipoPro := "PE"
               endif
            endif 

             aadd(aMarcacao[nX], { Space(2)               , (cAliasSZM)->ZM_CODIGO, (cAliasSZM)->ZM_DESCRIC, (cAliasSZM)->ZM_REVISAO, (cAliasSZM)->ZM_RESPONS, (cAliasSZM)->ZM_ID,;
                                   (cAliasSZM)->ZM_CATALIS, (cAliasSZM)->ZM_RELCAT, (cAliasSZM)->ZM_TIPO   , (cAliasSZM)->ZM_LOCAL  , cTipoPro, (cAliasSZM)->ZM_UM,;
                                   (cAliasSZM)->ZM_ROTEIRO, (cAliasSZM)->ZM_PESESP, (cAliasSZM)->ZM_XCODANT ,(cAliasSZM)->ZM_VERIFCO, (cAliasSZM)->ZM_GRUPO2} )
             DbSelectArea(cAliasSZM)
             DbSkip()
       EndDo

       DbSelectArea( _cAliasSX3 )
       DbCloseArea()

       DbSelectArea(cAliasSZM)
       DbCloseArea()
       DbSelectArea("SZM")

       U_VoltaArea(aAreaAnt)
       RestArea(aAreaSX3)
       RestArea(aArea)
Return(Len(aMarcacao) > 0)

/********************************************************************************************/
/*** FMRKDIS - Rotina para marcar e dismarcar na liberação                                ***/
/********************************************************************************************/
Static Function fMrkDis( aGeral, aMarcacao )
       Local aArea    := GetArea()
       Local cAlias   := aGeral[GEL_ARQ]
       Local nPosAtu  := aGeral[GEL_POS]
       Local nLinha   := (cAlias)->(RecNo())

       If (cAlias)->( IsMark("TMP_OK", ThisMark(), ThisInv() ) )
          RecLock(cAlias)
             (cAlias)->TMP_OK := "XX"
          MsUnLock()
       Else
          RecLock(cAlias)
             (cAlias)->TMP_OK := ""
          MsUnLock()
       EndIf
       aMarcacao[nPosAtu][nLinha][1] := (cAlias)->TMP_OK
       RestArea(aArea)
Return(.t.)

/********************************************************************************************/
/*** FLIBPAG - Rotina para troca de pagina na liberação.                                  ***/
/********************************************************************************************/
Static Function fLibPag( nSoma, aGeral, aMarcacao, aTitVig, aDadVig, oForVig)
       //Local aArea   := GetArea()
       Local cAlias  := aGeral[GEL_ARQ]
       Local nPosAtu := aGeral[GEL_POS]
       Local nY, nX
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Ajusta a nova posicao atual                                            ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       nPosAtu += nSoma
       nPosAtu := Min(nPosAtu, Len(aMarcacao) )
       nPosAtu := Max(1, nPosAtu)
       aGeral[GEL_POS] := nPosAtu

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Limpa o arquivo temporario                                             ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       //LGS#20200211 - Adequação de release 12.1.25 e posteriores
       DbSelectArea(cAlias)
       //Zap
       TCSqlExec("DELETE FROM " + oTemptable:GetRealName() )
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Atualiza os dados da Planilha de cotacao                               ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       For nX := 1 To Len(aMarcacao[nPosAtu])
           RecLock(cAlias, .t.)
              For nY := 1 To FCount()
                  FieldPut(nY, aMarcacao[nPosAtu][nX][nY])
              Next nY
           MsUnLock()
       Next nX
       aGeral[GEL_MRK]:oBrowse:GoTop()
       aGeral[GEL_MRK]:oBrowse:Refresh()

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Atualiza os dados do cabecalho da analise de formulas                  ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       cCodigo := aMarcacao[nPosAtu][1][02] ; oCodigo:Refresh()
       cDescri := aMarcacao[nPosAtu][1][03] ; oDescri:Refresh()
       cTipo   := aMarcacao[nPosAtu][1][09] ; oTipo:Refresh()
       cLocal  := aMarcacao[nPosAtu][1][10] ; oLocal:Refresh()
       cTpProd := Iif(aMarcacao[nPosAtu][1][11] == 'PE', 'EXISTENTE', 'NOVO')
       oTpProd:Refresh()
       oPosAtu:cCaption := StrZero(nPosAtu, 2)+"/"+StrZero( Len(aMarcacao), 2 )
       oPosAtu:Refresh()
       aTitVig := {}
       aDadVig := {}
       nPerFor := 0 ; nPesEsp := 0 ; nCusRea := 0 ; nCusDol := 0 ; nPrcVig := 0
       U_fBusVig(aMarcacao[nPosAtu][1][02], aMarcacao[nPosAtu][1][04], aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][9], @aTitVig, @aDadVig, @oPerFor, @nPerFor, @oPesEsp, @nPesEsp, @oCusRea, @nCusRea, @oCusDol, @nCusDol, @oPrcVig, @nPrcVig, ;
                 @nOldPVC, @nOldBri, @aGeral, 2, @aMarcacao, @oSayVig, @nCusOuO, @oCusOuO, @oCusVig)

       oForVig:aHeaders  := aTitVig
       oForVig:SetArray(aDadVig)
       oForVig:bLine     := {|| oForVig:aArray[oForVig:nAt] }
       oForVig:Refresh()

       aTitAtu := {}
       aDadAtu := {}
       nPerNew := 0
       nPesNew := 0
       nCusRNe := 0
       nCusDNe := 0
       nPrcNew := 0

       U_fMonHea(@aTitAtu)
       U_fMonCol(@aDadAtu, @aTitAtu, 1, aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][2], aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][4], aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][6], aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][9], aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][12], aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][14] )
       U_fMonRod( aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][02], aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][04], ; // Codigo, Revisao
                  aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][09], aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][12], ; // Tipo, Unidade Med.
                  aMarcacao[Iif(aGeral[GEL_POS] == 0, 1, aGeral[GEL_POS])][1][11], aDadAtu, aTitAtu, @oPerNew, @nPerNew, @oPesNew, @nPesNew, ;        // Tipo Produto, aCols, aHeader, Obj. Percentual, Percentual, Obj. Peso Espec., Peso Espec.
                  @oCusRNe, @nCusRNe, @oCusDNe, @nCusDNe, @oPrcNew, @nPrcNew, ; //Obj. Custo Real, Custo Real, Obj. Custo Dolar, Custo Dolar, Obj. Preco Novo, Preco Novo
                  @oVarPrc, @nVarPrc, @oBitMap, @cBitMap, nCusRea, nPrcVig, ; // Obj. Variacao, Variacao, Obj. BitMap, Nome do BitMap, Custo Vigente, Preço Vigente
                  oSayPrc, @oNewPVC, @nNewPVC, @oNewBri, @nNewBri, .t., aMarcacao, @nCusOuN, @oCusOuN, ,@oCusAtu ) //Variavel Texto do Preço, Verdadeiro se for Liberacao, Matriz com dados se for liberacao

       oForAtu:aHeaders  := aTitVig
       oForAtu:SetArray(aDadAtu)
       oForAtu:bLine     := {|| oForAtu:aArray[oForAtu:nAt] }
       oForAtu:Refresh()

       oBitMap:cResName := cBitMap ; oBitMap:Refresh()
Return(.t.)

/********************************************************************************************/
/*** FLIBFOL - Rotina para troca de folder na liberação.                                  ***/
/********************************************************************************************/
Static Function fLibFol(nFldDst, nFldAtu, oFolder, aGeral, aMarcacao)
       Local aArea   := GetArea()
       //Local nPosAtu := aGeral[GEL_POS]

       If ( nFldDst <> nFldAtu )
          aGeral[GEL_MRK]:oBrowse:lDisablePaint   := .t.
          Do Case
             Case ( nFldDst == 1 )
                  aGeral[GEL_MRK]:oBrowse:lDisablePaint := .F.
                  aGeral[GEL_MRK]:oBrowse:Gotop()
                  aGeral[GEL_MRK]:oBrowse:Refresh()
          EndCase
       Endif
       RestArea(aArea)
Return(.t.)

/********************************************************************************************/
/*** FLIBENB - Rotina para gerar enchoice bar na liberação.                               ***/
/********************************************************************************************/
Static Function fLibEnB(oDlg, bOk, bCancel, bPage, aGeral, cCodigo, cRevisao, aMarcacao, lSaida)
       Local aHeader := {}
       Local aCols   := {}
       //Local lVolta  := .f.
       //Local bSet15, bSet24, bSet2, bSet5, bSet18,lOk
       Private oBar
       Eval(bPage,1)

       DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg
       DEFINE BUTTON        RESOURCE "S4WB010N" OF oBar       ACTION OurSpool()                                                                                      //TOOLTIP OemToAnsi("Gerenciador de Impressão...")
       DEFINE BUTTON        RESOURCE "S4WB016N" OF oBar GROUP ACTION HelProg()                                                                                       //TOOLTIP OemToAnsi("Help de Programa...")
       DEFINE BUTTON        RESOURCE "S4WB007N" OF oBar GROUP ACTION DbSelectArea(aGeral[GEL_ARQ]), U_fMonOpe(1, TMP_CODIGO, TMP_REVISA, TMP_DESCRI, aHeader, aCols) TOOLTIP OemToAnsi("Operações...")
       DEFINE BUTTON        RESOURCE "S4WB009N" OF oBar GROUP ACTION DbSelectArea(aGeral[GEL_ARQ]), U_fFichaOp(TMP_CODIGO, TMP_REVISA, TMP_DESCRI)                   TOOLTIP OemToAnsi("Ficha de Processo...")
       If !Posicione("SZM", 1, xFilial("SZM")+&(aGeral[GEL_ARQ]+"->TMP_CODIGO")+&(aGeral[GEL_ARQ]+"->TMP_REVISA"), "ZM_STATUS") $ 'EE'
          DEFINE BUTTON        RESOURCE "S4WB014B" OF oBar GROUP ACTION U_fRetSta(oDlg, @aGeral, @aMarcacao, @lSaida), Iif(lSaida, oDlg:End(), )                     TOOLTIP OemToAnsi("Retorna status anterior...")
          If !Posicione("SZM", 1, xFilial("SZM")+&(aGeral[GEL_ARQ]+"->TMP_CODIGO")+&(aGeral[GEL_ARQ]+"->TMP_REVISA"), "ZM_STATUS") $ 'PP'
             DEFINE BUTTON        RESOURCE "S4WB021N" OF oBar GROUP ACTION U_fRejFor(oDlg, @aGeral, @aMarcacao)                                                      TOOLTIP OemToAnsi("Rejeita...")
          Endif
       Endif
       oBar:nGroups += 2
       DEFINE BUTTON oBtOk  RESOURCE "S4WB018N" OF oBar GROUP ACTION lSaida := .t., U_fAprFor(oDlg, @aGeral, @aMarcacao)                                             TOOLTIP OemToAnsi("Aprova...")
       DEFINE BUTTON oBtCan RESOURCE "S4WB019N" OF oBar       ACTION lSaida := .t., oDlg:End()                                                                       TOOLTIP OemToAnsi("Sair...")

       oBar:bRClicked := {|| AllwaysTrue()}

Return Nil

/********************************************************************************************/
/*** FBUSHIS - Rotina para buscar histórico da revisão.                                   ***/
/********************************************************************************************/
Static Function fBusHis(aLogPro, cId, nTpHis, nPos, oTxtMemo, cTxtMemo, oRespons, cRespons, oProdRev, cProdRev)
    //Local cQuery := ""
    
    If nTpHis == 1
		DbSelectArea("SZT")
	    DbSetOrder(1)
	    DbSeek(xFilial("SZT")+cId, .t.)
	    If Found()
	    	While !Eof() .and. SZT->ZT_ID == cId
				cProcess := Iif(SZT->ZT_PROCESS $ "SI", "Simulação", "Solicitação" ) 
				cStatus	 := Iif(SZT->ZT_STATUS $ "EE", "Produto em simulação.", Iif(SZT->ZT_STATUS $ "PP", "Produto no PCP", Iif(SZT->ZT_STATUS $ "AC", "Baixa Pend. Diretoria" ,Iif(SZT->ZT_STATUS $ "MD", "Motivo de Devolução", Iif(SZT->ZT_STATUS $ "OD", "Observação Diretoria.", Iif(SZT->ZT_STATUS $ "RT", "Retorno de formulação.", Iif(SZT->ZT_STATUS $ "EA", "Produto na Diretoria.", "." ) ) ) ) ) ) )
	            cGeracao := DTOC(SZT->ZT_DATAGER)+" - "+SZT->ZT_HORAGER
                If PswSeek(SZT->ZT_USUARIO, .t.)
                	cUserSZT := Alltrim(PSWRET()[1][4])
                Else
                    cUserSZT := Alltrim(SZT->ZT_USUARIO)
                Endif
				aadd(aLogPro, { SZT->ZT_ID, cProcess, cStatus, cGeracao, '', SZT->ZT_PROCESS, SZT->ZT_STATUS, SZT->ZT_SEQ, SZT->ZT_LOG, cUserSZT} )
	            DbSelectArea("SZT")
	            DbSkip()
	        EndDo
	    Endif
	    DbSelectArea("SZT")
	    DbCloseArea()
	Else
		//cRespons := Posicione("SZT", 2, xFilial("SZT")+aLogPro[nPos,1]+aLogPro[nPos,6]+aLogPro[nPos,7], "ZT_USUARIO")
        //cTxtMemo := Posicione("SZT", 2, xFilial("SZT")+aLogPro[nPos,1]+aLogPro[nPos,6]+aLogPro[nPos,7], "ZT_LOG")
        cTxtMemo := "*** "+Alltrim(aLogPro[nPos,10])+" ***" + Chr(13)+Chr(10) + aLogPro[nPos,09]
        cRespons := aLogPro[nPos,10]
        If aLogPro[nPos,6] == "SO"

        Else
           cProdRev := Alltrim(Posicione("SZM", 5, xFilial("SZM")+aLogPro[nPos,1]+SubStr(aLogPro[nPos,8],1,1), "ZM_CODIGO"))+" / "+Alltrim(Posicione("SZM", 5, xFilial("SZM")+aLogPro[nPos,1]+SubStr(aLogPro[nPos,8],1,1), "ZM_REVISAO"))
        Endif
        oRespons:Refresh()
        oProdRev:Refresh()
        oTxtMemo:Refresh()
	Endif
	
Return

/********************************************************************************************/
/*** FBUSHIS - Rotina para buscar histórico da revisão.                                   ***/
/********************************************************************************************/
User Function PCPX01_9()
     Local   cStatus, _ni
     Local   aImpr   := {}
     Private nLin    := 0
     Private nLinha  := 0
     Private nColuna := 50
     PRIVATE nTamanho  :="P"
     Private nlinMax := 2800
     Private nColMax := 2350
     Private nColBox := 2200

	if !EstaAutori(SZM->ZM_CODIGO)
		Alert("Acesso Não Autorizado!")
		return(.f.)
	endif 


     If !lAcs8
     	MsgBox("Usuário sem acesso a impressão de fórmulas.!!","Atenção","STOP")
     	Return()
     Endif
     nlargura:= IF(nTamanho=="P",2250,IF(nTamanho=="G",2300,2500))
     cTitulo :=Iif(TYPE("NewHead")!="U",NewHead,"Formula em Simulacao")
     cNomPrg := Alltrim("FOMUL")

     // Tamanho da pagina A4 em pixels 
     // Largura: 595 x Altura: 842 Retrato    - SetPortrait()
     // Largura: 595 x Altura: 842 Paisagem   - SetLandscape()
     
     AVPRINT oPrn NAME "Relatorio de Formulação."
             //oFont1 := TFont():New("XXX", 9 , 07,.F.,.T., 5 ,.T., 5 ,.T.,.F.)
             //                        1    2   3   4   5   6   7   8   9   10
             //                        |    |   |   |   |   |   |   |   |   +-->>> <Lógico>   - Sublinhado
             //                        |    |   |   |   |   |   |   |   +------>>> <Lógico>   - Itálico
             //                        |    |   |   |   |   |   |   +---------->>> <>
             //                        |    |   |   |   |   |   +-------------->>> <Lógico>   -
             //                        |    |   |   |   |   +------------------>>>
             //                        |    |   |   |   +---------------------->>> <Lógico>   - Negrito
             //                        |    |   |   +-------------------------->>>
             //                        |    |   +------------------------------>>> <Numérico> - Tamanho
             //                        |    +---------------------------------->>> <Numérico> - Tamanho
             //                        +--------------------------------------->>> <Texto>    - Nome da Fonte
             oPrn:SetPage(9) //Seta Papel como A4
             oPrn:SetLoMetricMode()
             oFont1 := TFont():New("Courier New" ,9,19,.F.,.T.,5,.T.,5,.F.,.F.)
             oFont2 := TFont():New("Courier New" ,9,13,.F.,.T.,5,.F.,5,.F.,.F.) 
             oFont3 := TFont():New("Courier New" ,9,13,.F.,.F.,5,.F.,5,.T.,.F.)
             oFont4 := TFont():New("Courier New" ,9,13,.F.,.T.,5,.F.,5,.T.,.F.) 
             oFont5 := TFont():New("Courier New" ,9,12,.F.,.T.,5,.F.,5,.F.,.F.) 
             oFont6 := TFont():New("Courier New" ,9,12,.F.,.T.,5,.F.,5,.T.,.F.) 
             oFont7 := TFont():New("Courier New" ,9,12,.F.,.F.,5,.F.,5,.F.,.F.) 
             oFont8 := TFont():New("Courier New" ,9,12,.F.,.T.,5,.F.,5,.F.,.F.) 
             oFont9 := TFont():New("Courier New" ,9,11,.F.,.T.,5,.F.,5,.F.,.F.) 
     
             AVPAGE
               // Cabeçalho da Impressão
               nLinha  := 040
               nColuna := 030
               //oSend(oPrn, "SayBitmap", nLin, 100, "BRASILUX.BMP" , 400, 200 )
               oPrn:Box( nLinha-10, nColuna       , nColuna * 4, nColMax )
               oPrn:Say(nLinha    , nColuna +  800, "FÓRMULA EM SIMULAÇÃO", oFont1,,,,)
               nLinha += 100
               oPrn:Say(nLinha    , nColuna +  600, "PRODUTO"    , oFont2,,,,)
               oPrn:Say(nLinha    , nColuna + 1400, "REVISÃO"    , oFont2,,,,)
               oPrn:Say(nLinha    , nColuna + 1900, "RESPONSÁVEL", oFont2,,,,)
               nLinha += 60
               oPrn:Say(nLinha    , nColuna       , SubStr(SZM->ZM_CODIGO, 1, 5)+"."+SubStr(SZM->ZM_CODIGO, 6, 2)+"."+SubStr(SZM->ZM_CODIGO, 8, 3)+"-"+SubStr(SZM->ZM_CODIGO, 11, 2)+" - "+SZM->ZM_DESCRIC, oFont3,,,,)
               oPrn:Say(nLinha    , nColuna + 1450, SZM->ZM_REVISAO                     , oFont4,,,,)
               oPrn:Say(nLinha    , nColuna + 1850, SZM->ZM_RESPONS                     , oFont3,,,,)
               nLinha += 60
               If SZM->ZM_STATUS $ "AC"
                  cStatus := 'APROVADO - FÓRMULA VIGENTE'
               ElseIf SZM->ZM_STATUS $ "EE"
                      cStatus := 'EM ELABORAÇÃO - FÓRMULA BLOQUEADA'
               ElseIf SZM->ZM_STATUS $ "PP"
                      cStatus := 'PCP - FÓRMULA BLOQUEADA'
               ElseIf SZM->ZM_STATUS $ "EA"
                      cStatus := 'DIRETORIA - FÓRMULA BLOQUEADA'
               ElseIf SZM->ZM_STATUS $ "RE"
                      cStatus := 'REJEITADO - FÓRMULA BLOQUEADA'
               Else
                  cStatus := ""
               Endif
               oPrn:Say(nLinha    , nColuna       , "STATUS: "+cStatus, oFont5,,,,)
               nLinha += 60
               oPrn:Line(nlinha, nColuna, nlinha, nColMax)
               nLinha += 60
               oPrn:Say(nLinha    , nColuna + 1000, "FÓRMULA", oFont1,,,,)
               nLinha += 60
               oPrn:Line(nlinha, nColuna, nlinha, nColMax)
               nLinha += 80
               oPrn:Say(nLinha    , nColuna + 500, "MATÉRIA PRIMA", oFont6,,,,)
               oPrn:Say(nLinha    , nColuna + 1400,"QUANTIDADE"   , oFont6,,,,)
               oPrn:Say(nLinha    , nColuna + 1800,"PERCENTUAL"   , oFont6,,,,)
               oPrn:Say(nLinha    , nColuna + 2200,"SEQ."         , oFont6,,,,)
               //Colunas
               oPrn:Line(nlinha+20, nColuna     , nlinha+60, nColuna     )
               oPrn:Line(nlinha+20, nColuna+1270, nlinha+60, nColuna+1270)
               
               oPrn:Line(nlinha+20, nColuna+1370, nlinha+60, nColuna+1370)
               oPrn:Line(nlinha+20, nColuna+1670, nlinha+60, nColuna+1670)
               
               oPrn:Line(nlinha+20, nColuna+1770, nlinha+60, nColuna+1770)
               oPrn:Line(nlinha+20, nColuna+2070, nlinha+60, nColuna+2070)
               
               oPrn:Line(nlinha+20, nColuna+2170, nlinha+60, nColuna+2170)
               oPrn:Line(nlinha+20, nColuna+2320, nlinha+60, nColuna+2320)
               
               nLinha += 60
               oPrn:Line(nlinha, nColuna     , nlinha, nColuna+1270)
               oPrn:Line(nlinha, nColuna+1370, nlinha, nColuna+1670)
               oPrn:Line(nlinha, nColuna+1770, nlinha, nColuna+2070)
               oPrn:Line(nlinha, nColuna+2170, nlinha, nColuna+2320)
               
               nLinha += 30
               aImpr := fBusDados()
               If Len(aImpr) > 0
                  aSort(aImpr ,,,{|x,y| x[1] < y[1] })
                  nTotQtd := 0
                  nTotPer := 0
                  For _ni := 1 to Len(aImpr)
                      oPrn:Say(nLinha,nColuna     , aImpr[_ni][2], oFont7,,,,)
                      oPrn:Say(nLinha,nColuna+1430, Transform(aImpr[_ni][3],"@E 9,999.999"), oFont7,,,,)
                      oPrn:Say(nLinha,nColuna+1880, Transform(aImpr[_ni][4],"@E   999.999"), oFont7,,,,)
                      oPrn:Say(nLinha,nColuna+2220, aImpr[_ni][1], oFont7,,,,)
                      nLinha += 60
                      nTotQtd := nTotQtd + aImpr[_ni][3]
                      nTotPer := nTotPer + aImpr[_ni][4]
                  Next
                  oPrn:Line(nlinha, nColuna, nlinha, nColMax)
                  nLinha +=  30
                  oPrn:Say(nLinha, nColuna+1430, Transform(nTotQtd,"@E 9,999.999 KG"), oFont8,,,,)
                  oPrn:Say(nLinha, nColuna+1880, Transform(nTotPer,"@E   999.999 %"), oFont8,,,,)
                  nLinha += 600
                  oPrn:Box( nLinha, nColuna, nLinha+60, nColMax )
                  oPrn:Say(nLinha    , nColuna +  300, "FÓRMULA EM DESENVOLVIMENTO  -  PRODUÇÃO PROIBIDA", oFont1,,,,)
               Endif
               oPrn:Line(nlinMax-30, nColuna, nlinMax-30, nColMax)
               oPrn:Say( nLinMax-25, nColuna, Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL), oFont9,,,,)
               oPrn:Line(nlinMax+10, nColuna, nlinMax+10, nColMax)
             AVENDPAGE
     AVENDPRINT

     oFont1:End() ; oFont2:End() ; oFont3:End() ; oFont4:End() ; oFont5:End() 
     oFont6:End() ; oFont7:End() ; oFont8:End() ; oFont9:End()

     MS_FLUSH() 
Return

Static Function fBusDados()
       Local aDados := {}
       DbSelectArea("SZN")
       DbSetOrder(2)
       DbSeek(xFilial("SZN")+SZM->ZM_CODIGO+SZM->ZM_REVISAO,.t.)
       If Found()
          While !Eof() .and. SZN->ZN_CODIGO == SZM->ZM_CODIGO .and. SZN->ZN_REVISAO == SZM->ZM_REVISAO
               // produto de custeio
               If U_IsProdCusto(SZN->ZN_COMP)
                  SZN->(dbSkip())
                  Loop
               Endif   
          
                DbSelectArea("SB1")
                DbSetOrder(1)
                DbSeek(xFilial("SB1")+SZN->ZN_COMP,.t.)
                If Found() .and. (!(cNumEmp = "01010101") .OR. (SUBSTR(SB1->B1_GRUPO,1,1) == "E")) // (Cleber) - 04/04/13 - Thiago pediu pra não mostrar descrições na impressão! (04/04/13), exceto grupos de embalagens
                   cDesc := SubStr(SB1->B1_DESC,1,40)
                Else
                   cDesc := ""
                Endif
                aadd(aDados,{SZN->ZN_TRT, SZN->ZN_COMP+" - "+cDesc, SZN->ZN_QUANT, SZN->ZN_PERC})
                DbSelectArea("SZN")
                DbSkip()
          Enddo
       Endif
Return(aDados)

/******************************************************************************************************************/
/***  FUNÇÃO  # F. AUXIL. #                                                                                     ***/
/******************************************************************************************************************/
/*** PCPX01_A #           # Chamada da visualização / exclusão da formulação.                                   ***/
/***          # fBusLog   # Busca Log da simulação.                                                             ***/
/***          # fCarrRev  # Carrega dados da revisão da fórmula.                                                ***/
/***          # fCarrVig  # Carrega dados da fórmula vigente.                                                   ***/
/***          # fEncBarG  # Enchoice Bar utilizada para criação de botões especificos.                          ***/
/***          # fMonOper  # Monta estrutura de operações do produto.                                            ***/
/***          # fFichaOP  # Imprime a Ficha de Processo do Produto                                              ***/
/***          # fIncEmba  # Monta entrada e manutenção de embalagens para os produtos tintas.                   ***/
/***          # fCPvcBri  # Calcula PVC e BRILHO de um produto/revisão                                          ***/
/***          # fCCusPro  # Função recursiva para calculo do custo de um PI.                                    ***/
/******************************************************************************************************************/
User Function PCPX01_A(nOpc)
     Local aAcho        := {} 
     //Local aAltEnChoice := {}             //Campos a serem alterados na Enchoice
     Local aAltGet      := {}             //Campos a serem alterados na GetDados
     Local nReg         := SZM->(Recno()) //Numero do Registro posicionado
     Local nOpcE        := 2              //Variável que indica a operação da enchoice
     Local lVirtual     := .t.            //Verifica se utiliza campo virtual na EnChoice
     Local nOpcA        := 0              //Variável utilizada na saída do sistema pelo botão cancela
     //Local bCampo       := {|nCpo| Field(nCpo)}
     Local oForVig, oPerVig, oPesVig, oPVCVig, oBriVig, oCusRVg, oCusDVg, oCusOVg, oPrcVig //Objetos da parte vigente
     Local          nPerVig, nPesVig, nPVCVig, nBriVig, nCusRVg, nCusDVg, nCusOVg, nPrcVig //Variáveis da parte vigente
     Local oGetRev, oPerRev, oPesRev, oPVCRev, oBriRev, oCusRRv, oCusDRv, oCusORv, oPrcRev //Objetos da parte revisão
     Local          nPerRev, nPesRev, nPVCRev, nBriRev, nCusRRv, nCusDRv, nCusORv, nPrcRev //Variáveis da parte revisão
     Local oVarVal, oBitMap               //Objetos da variação
     Local nVarVal, cBitMap, nVarVig               //Variáveis da variação
     Local aHeadVig     := {}             //Cabeçalho para fórmula vigente
     Local aColsVig     := {}             //aCols da fórmula vigente
     Local cAux
     Private aHeader    := {}             //Cabeçalho para fórmula revisão
     Private aCols      := {}             //aCols da fórmula revisão
     Private lSaida     := .f.            //Validação para saída do sistema

	 If !EstaAutori(SZM->ZM_CODIGO)
		Alert("Acesso Não Autorizado!")
		return(.f.)
	 Endif 

	nCusRRv := 0 //Cleber (23/11/16)-> Por alguma razão essa variável não é atualizada e dá erro abaixo ao tentar utilizar, por isso o valor está sendo zerado aqui
     //Verifica Status da Formulação e permissão do usuário para efetuar a exclusão da fórmula.
     If nOpc == 2
        If !SZM->ZM_STATUS $ 'EE'
           MsgBox("Esse status não permite a exclusão da fórmula !!!","Atenção","STOP")
           Return
        Else
           If !Alltrim(Upper(cUsername)) $ Alltrim(Upper(SZM->ZM_RESPONS))
              MsgBox("Usuário não autorizado a efetuar exclusão dessa estrutura !!!","Atenção","STOP")
              Return
           Endif
        Endif
     Endif
     //Montagem dos Campos da Enchoice de acordo com o item referido.
     If Len(Alltrim(SZM->ZM_CODIGO)) == 12
        aAcho := { "ZM_CODIGO", "ZM_REVISAO", "ZM_DESCRIC", "ZM_RESPONS", "ZM_DTINCLU", "ZM_TIPO", "ZM_CATALIS", "ZM_RELCAT", "ZM_TIPOPRO", "ZM_SOLICIT", "ZM_LOCAL", "ZM_UM", "ZM_ROTEIRO", "ZM_DESEMB", "ZM_PADCOR","ZM_POSIPI","ZM_EX_NCM", "ZM_XCODANT","ZM_VERIFCO", "ZM_GRUPO2"}
     Else
        If Len(Alltrim(SZM->ZM_CODIGO)) == 4 //.or. cNumEmp = '01010104'
           aAcho := { "ZM_CODIGO", "ZM_REVISAO", "ZM_DESCRIC", "ZM_RESPONS", "ZM_DTINCLU", "ZM_TIPO",                          "ZM_TIPOPRO", "ZM_SOLICIT", "ZM_LOCAL", "ZM_UM", "ZM_ROTEIRO","ZM_POSIPI","ZM_EX_NCM", "ZM_XCODANT","ZM_VERIFCO"}
        Else
           aAcho := { "ZM_CODIGO", "ZM_REVISAO", "ZM_DESCRIC", "ZM_RESPONS", "ZM_DTINCLU", "ZM_TIPO",                          "ZM_TIPOPRO", "ZM_SOLICIT", "ZM_LOCAL", "ZM_UM", "ZM_ROTEIRO", "ZM_PADCOR","ZM_POSIPI","ZM_EX_NCM", "ZM_XCODANT" }
        Endif
     Endif
     RegToMemory("SZM", .F.)
     M->ZM_MOTIVO := U_fBusLog(SZM->ZM_ID, "SI", "EE" )
     nPesVig      := Posicione("SB1", 1, xFilial("SB1")+M->ZM_CODIGO, "B1_PESOESP")
     nPrcVig      := Posicione("SB1", 1, xFilial("SB1")+M->ZM_CODIGO, "B1_PRV1")
     nPrcRev      := 0
     /************************************/
        If Len(Alltrim(M->ZM_CODIGO)) == 12
           If !Empty(Posicione("SZ3", 1, xFilial("SZ3")+SubStr(Alltrim(M->ZM_CODIGO), 6, 2)+SubStr(Alltrim(M->ZM_CODIGO), 8, 3), "Z3_PADCOR")) .and. Posicione("ZZE", 1, xFilial("ZZE")+Posicione("SZ3", 1, xFilial("SZ3")+SubStr(Alltrim(M->ZM_CODIGO), 6, 2)+SubStr(Alltrim(M->ZM_CODIGO), 8, 3), "Z3_PADCOR"), "ZZE_LIBERA") $ "S.R"
              M->ZM_PCREVIS := "S"
              M->ZM_PADCOR  := Posicione("ZZE", 1, xFilial("ZZE")+Posicione("SZ3", 1, xFilial("SZ3")+SubStr(Alltrim(M->ZM_CODIGO), 6, 2)+SubStr(Alltrim(M->ZM_CODIGO), 8, 3), "Z3_PADCOR"), "ZZE_DESCRI")
           Endif
        ElseIf Len(Alltrim(M->ZM_CODIGO)) == 5
               If !Empty(Posicione("SZ3", 1, xFilial("SZ3")+Alltrim(M->ZM_CODIGO), "Z3_PADCOR"))  .and. Posicione("ZZE", 1, xFilial("ZZE")+Posicione("SZ3", 1, xFilial("SZ3")+SubStr(Alltrim(M->ZM_CODIGO), 6, 2)+SubStr(Alltrim(M->ZM_CODIGO), 8, 3), "Z3_PADCOR"), "ZZE_LIBERA") $ "S"
                  M->ZM_PCREVIS := "S"
                  M->ZM_PADCOR  := Posicione("ZZE", 1, xFilial("ZZE")+Posicione("SZ3", 1, xFilial("SZ3")+Alltrim(M->ZM_CODIGO), "Z3_PADCOR"), "ZZE_DESCRI")
               Endif
        ElseIf Len(Alltrim(M->ZM_CODIGO)) == 6
               If !Empty(Posicione("SZ3", 1, xFilial("SZ3")+SubStr(Alltrim(M->ZM_CODIGO), 1, 5), "Z3_PADCOR"))  .and. Posicione("ZZE", 1, xFilial("ZZE")+Posicione("SZ3", 1, xFilial("SZ3")+SubStr(Alltrim(M->ZM_CODIGO), 6, 2)+SubStr(Alltrim(M->ZM_CODIGO), 8, 3), "Z3_PADCOR"), "ZZE_LIBERA") $ "S"
                  M->ZM_PCREVIS := "S"
                  M->ZM_PADCOR  := Posicione("ZZE", 1, xFilial("ZZE")+Posicione("SZ3", 1, xFilial("SZ3")+SubStr(Alltrim(M->ZM_CODIGO), 1, 5), "Z3_PADCOR"), "ZZE_DESCRI")
               Endif
        Endif
     /************************************/
     fCarrRev(@aHeader, @aCols, @nPerRev, @nPesRev, @nPVCRev, @nBriRev, @nCusRRv, @nCusDRv, @nCusORv, @nPrcRev)
     
     DEFINE MSDIALOG oDlg FROM 000,000 TO 033,100 TITLE OemToAnsi("Formulação") OF oMainWnd

     DEFINE FONT oFont SIZE 8,0 BOLD
            EnChoice("SZM", nReg, nOpcE, , , , aAcho, {015, 001, 090, 395}, aAcho, 3, , , , , , lVirtual)

            /******************************************************************************************************/
            @ 090,050 SAY OemToAnsi("FORMULA VIGENTE")      SIZE 100,009 COLOR CLR_BLUE PIXEL OF oDlg  FONT oFont
            @ 100,001 LISTBOX oForVig FIELDS TITLE ""       SIZE 193,080 	            PIXEL OF oDlg
            /******************************************************************************************************/
            @ 182,001 GROUP oGrp1 TO 211,195 LABEL  OemToAnsi('Especificações...')    COLOR CLR_HRED  PIXEL OF oDlg
            @ 187,025 SAY OemToAnsi("% Fórmula: ")                        SIZE 030,09                 PIXEL OF oDlg
            @ 186,055 MSGET oPerVig VAR nPerVig PICTURE '@E 999.99%'      SIZE 030,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 187,105 SAY OemToAnsi("P. Especif.: ")                      SIZE 030,09                 PIXEL OF oDlg
            @ 186,135 MSGET oPesVig VAR nPesVig PICTURE '@E 99999.99999'  SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 199,025 SAY OemToAnsi("PVC")                                SIZE 030,09                 PIXEL OF oDlg
            @ 198,055 MSGET oPVCVig VAR nPVCVig PICTURE '@E 999.999'      SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 199,105 SAY OemToAnsi("Brilho 60%")                         SIZE 030,09                 PIXEL OF oDlg
            @ 198,135 MSGET oBriVig VAR nBriVig PICTURE '@E 999.999'      SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            /******************************************************************************************************/
            @ 212,001 GROUP oGrp1 TO 241,195 LABEL  OemToAnsi('Totais...')            COLOR CLR_HRED  PIXEL OF oDlg
            @ 217,020 SAY OemToAnsi("Custo(R$/"+Alltrim(M->ZM_UM)+"): ")  SIZE 040,09                 PIXEL OF oDlg
            @ 216,055 MSGET oCusRVg VAR nCusRVg PICTURE '@E 9,999.999'    SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            If Alltrim(M->ZM_UM) $ 'L' .and. Alltrim(M->ZM_TIPO) $ 'PI'
               @ 229,020 SAY oCusVig VAR OemToAnsi("Custo(R$/K): ")       SIZE 040,09                 PIXEL OF oDlg
               @ 228,055 MSGET oCusOVg VAR nCusOVg PICTURE '@E 9,999.999' SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            Endif

            @ 217,105 SAY OemToAnsi("Custo(U$): ")                        SIZE 030,09                 PIXEL OF oDlg
            @ 216,135 MSGET oCusDVg VAR nCusDVg PICTURE '@E 9,999.999'    SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 229,025 SAY oSayVig   VAR OemToAnsi("Prç Venda:")           SIZE 030,09                 PIXEL OF oDlg
            @ 228,055 MSGET oPrcVig VAR nPrcVig PICTURE '@E 9,999.999'    SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg

			//Chamado 007637, mostrar na visualização a variação na fórmula vigente
            fCarrVig(@aHeadVig, @aColsVig, @nPerVig, @nPVCVig, @nBriVig, @nCusRVg, @nCusDVg, @nCusOVg, @nPrcVig, nPesVig, @nCusRRv, @nPrcRev, oBitMap, @cBitMap, @nVarVal)
			nVarVig := ((1/(1+(nVarVal/100))) - 1)*100 //Converter variação relativa à fórmula vigente
            @ 229,105 SAY oSayVar   VAR OemToAnsi("Variação:")            SIZE 035,09                 PIXEL OF oDlg
            @ 228,135 MSGET oVarVal VAR nVarVig PICTURE '@E 9,999.99%'    SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg 

            /******************************************************************************************************/
            cAux := iif(cBitMap = 'QMT_OK','QMT_NO',iif(cBitMap = 'QMT_NO','QMT_OK','QMT_COND'))
            @ 225,181 BITMAP oBitmap RESOURCE cAux                     SIZE 015,15 ADJUST          PIXEL OF oDlg NO BORDER
            
            oForVig:aHeaders  := aHeadVig
            oForVig:SetArray(aColsVig)
            oForVig:bLine     := {|| oForVig:aArray[oForVig:nAt] }
            oPerVig:lReadOnly := .t. ; oPesVig:lReadOnly := .t. ; oPVCVig:lReadOnly := .t. ; oBriVig:lReadOnly := .t.
            oCusRVg:lReadOnly := .t. ; oCusDVg:lReadOnly := .t. ; oPrcVig:lReadOnly := .t.
            If Alltrim(M->ZM_TIPO) $ 'PI'
               If Alltrim(M->ZM_UM) $ 'L'
                  oCusOVg:lReadOnly := .t.
                  oSayVig:lVisibleControl := .f.
                  oPrcVig:lVisibleControl := .f.
               ElseIf Alltrim(M->ZM_UM) $ 'K.KG'
                  oSayVig:lVisibleControl := .f.
                  oPrcVig:lVisibleControl := .f.
               Endif
            Endif
            /******************************************************************************************************/
            @ 090,260 SAY OemToAnsi("REVISÃO: "+M->ZM_REVISAO)           SIZE 100,09 COLOR CLR_BLUE  PIXEL OF oDlg  FONT oFont
            DbSelectArea("SZM")
            oGetRev := MsGetDados():New( 100, 197, 180, 393, 2, "AllwaysTrue()", "AllwaysTrue()", "", .T., aAltGet, 2, , 100, "AllwaysTrue()")

            /******************************************************************************************************/
            @ 182,197 GROUP oGrp2 TO 211,394 LABEL  OemToAnsi('Especificações...')    COLOR CLR_HRED  PIXEL OF oDlg
            @ 187,222 SAY OemToAnsi("% Fórmula: ")                        SIZE 030,09                 PIXEL OF oDlg
            @ 186,252 MSGET oPerRev VAR nPerRev PICTURE '@E 999.99%'      SIZE 030,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 187,300 SAY OemToAnsi("P. Especif.: ")                      SIZE 030,09                 PIXEL OF oDlg
            @ 186,332 MSGET oPesRev VAR nPesRev PICTURE '@E 99999.99999'  SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 199,222 SAY OemToAnsi("PVC:")                               SIZE 030,09                 PIXEL OF oDlg
            @ 198,252 MSGET oPVCRev VAR nPVCRev PICTURE '@E 999.999'      SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 199,300 SAY OemToAnsi("Brilho 60%:")                        SIZE 030,09                 PIXEL OF oDlg
            @ 198,332 MSGET oBriRev VAR nBriRev PICTURE '@E 999.999'      SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            /******************************************************************************************************/
            @ 212,197 GROUP oGrp3 TO 241,394 LABEL  OemToAnsi('Totais...')            COLOR CLR_HRED  PIXEL OF oDlg
            @ 217,217 SAY OemToAnsi("Custo(R$/"+Alltrim(M->ZM_UM)+"): ")  SIZE 040,09                 PIXEL OF oDlg
            @ 216,252 MSGET oCusRRv VAR nCusRRv PICTURE '@E 9,999.999'    SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            If Alltrim(M->ZM_UM) $ 'L' .and. Alltrim(M->ZM_TIPO) $ 'PI'
               @ 229,217 SAY oCusRev VAR OemToAnsi("Custo(R$/K): ")       SIZE 040,09                 PIXEL OF oDlg
               @ 228,252 MSGET oCusORv VAR nCusORv PICTURE '@E 9,999.999' SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            Endif
            @ 217,300 SAY OemToAnsi("Custo(U$): ")                        SIZE 030,09                 PIXEL OF oDlg
            @ 216,332 MSGET oCusDRv VAR nCusDRv PICTURE '@E 9,999.999'    SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
            @ 229,222 SAY oSayRev   VAR OemToAnsi("Prç Venda:")           SIZE 030,09                 PIXEL OF oDlg
            @ 228,252 MSGET oPrcRev VAR nPrcRev PICTURE '@E 9,999.999'    SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
			//Chamado 007637, mostrar na visualização a variação na fórmula vigente
/*            @ 229,300 SAY oSayVar   VAR OemToAnsi("Variação:")            SIZE 035,09                 PIXEL OF oDlg
            @ 228,332 MSGET oVarVal VAR nVarVal PICTURE '@E 9,999.99%'    SIZE 040,09 COLOR CLR_HBLUE PIXEL OF oDlg
*/            
            @ 225,378 BITMAP oBitmap RESOURCE cBitmap                     SIZE 015,15 ADJUST          PIXEL OF oDlg NO BORDER
            /******************************************************************************************************/
            oDlg:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
            oBitMap:cResName := cBitMap
            oPerRev:lReadOnly := .t. ; oPesRev:lReadOnly := .t. ; oPVCRev:lReadOnly := .t. ; oBriRev:lReadOnly := .t.
            oCusRRv:lReadOnly := .t. ; oCusDRv:lReadOnly := .t. ; oPrcRev:lReadOnly := .t. ; oVarVal:lReadOnly := .t.
            If Alltrim(M->ZM_TIPO) $ 'PI'
               If Alltrim(M->ZM_UM) $ 'L'
                  oCusORv:lReadOnly := .t.
                  oSayRev:lVisibleControl := .f.
                  oPrcRev:lVisibleControl := .f.
               ElseIf Alltrim(M->ZM_UM) $ 'K.KG'
               	  oSayRev:lVisibleControl := .f.
                  oPrcRev:lVisibleControl := .f.
               Endif
            Endif
            /******************************************************************************************************/
     ACTIVATE MSDIALOG oDlg VALID lSaida ON INIT fEncBarG( { || lSaida := .t., nOpca := 1, oDlg:End() }, { || lSaida := .t., oDlg:End() }, oDlg, nOpc) CENTERED
Return

/******************************************************************************************************************/
/*** fEncBarG - Rotina para montagem da enchoice bar geral de todo o sistema de formulação.                     ***/
/******************************************************************************************************************/
Static Function fEncBarG(bOk, bCancel, oDlgPad, nOpc)
       Local oBar

       DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlgPad
       DEFINE BUTTON        RESOURCE "S4WB005N" OF oBar       ACTION NaoDisp()           TOOLTIP OemToAnsi("Recortar")
       DEFINE BUTTON        RESOURCE "S4WB006N" OF oBar       ACTION NaoDisp()           TOOLTIP OemToAnsi("Copiar")
       DEFINE BUTTON        RESOURCE "S4WB007N" OF oBar       ACTION NaoDisp()           TOOLTIP OemToAnsi("Colar")
       DEFINE BUTTON        RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora()       TOOLTIP OemToAnsi("Calculadora...")
       DEFINE BUTTON        RESOURCE "S4WB009N" OF oBar       ACTION Agenda()            TOOLTIP OemToAnsi("Agenda...")
       DEFINE BUTTON        RESOURCE "S4WB010N" OF oBar       ACTION OurSpool()          TOOLTIP OemToAnsi("Gerenciador de Impressão...")
       DEFINE BUTTON        RESOURCE "S4WB016N" OF oBar GROUP ACTION HelProg()           TOOLTIP OemToAnsi("Help de Programa...")
       /***********************************************************************************************************/
       DEFINE BUTTON        RESOURCE "S4WB007N" OF oBar       ACTION U_fMonOper(nOpc, M->ZM_CODIGO, M->ZM_REVISAO, M->ZM_DESCRIC) TOOLTIP OemToAnsi("Operações...")
       DEFINE BUTTON        RESOURCE "S4WB009N" OF oBar       ACTION U_fFichaOP(      M->ZM_CODIGO, M->ZM_REVISAO, M->ZM_DESCRIC) TOOLTIP OemToAnsi("Ficha de Processo...")
       If M->ZM_TIPO $ 'PI' .AND. Len(Alltrim(M->ZM_CODIGO)) == 12
          DEFINE BUTTON        RESOURCE "CONTAINR" OF oBar       ACTION U_fIncEmba(nOpc, M->ZM_CODIGO, M->ZM_REVISAO, M->ZM_TIPOPRO) TOOLTIP OemToAnsi("Embalagens")
       Endif
       /***********************************************************************************************************/       
       DEFINE BUTTON oBtOk  RESOURCE "OK"       OF oBar GROUP ACTION ( lOk := Eval(bOk)) //TOOLTIP OemToAnsi("<Ctrl + O>")
       SetKEY(15,oBtOk:bAction)  // K_CTRL_O
       DEFINE BUTTON oBtCan RESOURCE "CANCEL"   OF oBar GROUP ACTION ( Eval(bCancel))    //TOOLTIP OemToAnsi("<Ctrl + X>")
       SetKEY(24,oBtCan:bAction) // K_CTRL_X
       oBar:bRClicked := { || AllwaysTrue() }
Return Nil

/******************************************************************************************************************/
/*** fCarrVig - Monta variáveis das fórmulas vigentes                                                           ***/
/******************************************************************************************************************/
Static Function fCarrVig(aHeadVig, aColsVig, nPerVig, nPVCVig, nBriVig, nCusRVg, nCusDVg, nCusOVg, nPrcVig, nPesVig, nCusRRv, nPrcRev, oBitMap, cBitMap, nVarVal)
       Local aMatSZN := {}
       Local aMatSG1 := {}
       Local nLin    := 0
       Local cQry1   := ""
       Local nX, nY
       Local _lOpen        := .F. //LGS#20200210 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200210 - Adequação para release 12.1.25
     
       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200210 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0

       If !_lOpen //LGS#20200210 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif

       //Matriz da estrutura do SZN e do aHeader da fórmula vigente
       aAdd(aMatSZN, {"ZN_COMP"   , "C", 15, 0}) ; aAdd(aHeadVig, "Componente"  ) ; aAdd(aMatSZN, {"ZN_DESC"   , "C", 30, 0}) ; aAdd(aHeadVig, "Descrição"   )
       aAdd(aMatSZN, {"ZN_TRT"    , "C", 03, 0}) ; aAdd(aHeadVig, "Seq."        ) ; aAdd(aMatSZN, {"ZN_PERC"   , "N", 10, 6}) ; aAdd(aHeadVig, "% Formula"   )
       aAdd(aMatSZN, {"ZN_QUANT"  , "N", 12, 6}) ; aAdd(aHeadVig, "Quantidade"  ) ; aAdd(aMatSZN, {"ZN_PERDA"  , "N", 05, 2}) ; aAdd(aHeadVig, "Perda"       )
       aAdd(aMatSZN, {"ZN_PESESP" , "N", 13, 5}) ; aAdd(aHeadVig, "Pes. Espec." ) ; aAdd(aMatSZN, {"ZN_CUSTOUN", "N", 12, 6}) ; aAdd(aHeadVig, "Custo Unit." )
       aAdd(aMatSZN, {"ZN_CUSTORE", "N", 09, 3}) ; aAdd(aHeadVig, "Custo (R$) " ) ; aAdd(aMatSZN, {"ZN_CUSTODO", "N", 09, 3}) ; aAdd(aHeadVig, "Custo (U$) " )
       aAdd(aMatSZN, {"ZN_INI"    , "D", 08, 0}) ; aAdd(aHeadVig, "Data Inicial") ; aAdd(aMatSZN, {"ZN_FIM"    , "D", 08, 0}) ; aAdd(aHeadVig, "Data Final"  )
       aAdd(aMatSZN, {"ZN_FIXVAR" , "C", 01, 0}) ; aAdd(aHeadVig, "Fixo/Variav.") ; aAdd(aMatSZN, {"ZN_REVINI" , "C", 03, 0}) ; aAdd(aHeadVig, "Rev. Inicial")
       aAdd(aMatSZN, {"ZN_REVFIM" , "C", 03, 0}) ; aAdd(aHeadVig, "Rev. Final  ") ; aAdd(aMatSZN, {"ZN_OPERACA", "C", 02, 0}) ; aAdd(aHeadVig, "Operacao    ")
       //Matriz da estrutura do SG1
       aAdd(aMatSG1, {"G1_COMP"   , "C", 15, 0}) ; aAdd(aMatSG1, {"G1_DESC"   , "C", 30, 0}) ; aAdd(aMatSG1, {"G1_TRT"    , "C", 03, 0}) ; aAdd(aMatSG1, {"G1_PERC"   , "N", 10, 6})
       aAdd(aMatSG1, {"G1_QUANT"  , "N", 12, 6}) ; aAdd(aMatSG1, {"G1_PERDA"  , "N", 05, 2}) ; aAdd(aMatSG1, {"G1_PESESP" , "N", 13, 5}) ; aAdd(aMatSG1, {"G1_CUSTOUN", "N", 12, 6})
       aAdd(aMatSG1, {"G1_CUSTORE", "N", 09, 3}) ; aAdd(aMatSG1, {"G1_CUSTODO", "N", 09, 3}) ; aAdd(aMatSG1, {"G1_INI"    , "D", 08, 0}) ; aAdd(aMatSG1, {"G1_FIM"    , "D", 08, 0})
       aAdd(aMatSG1, {"G1_FIXVAR" , "C", 01, 0}) ; aAdd(aMatSG1, {"G1_REVINI" , "C", 03, 0}) ; aAdd(aMatSG1, {"G1_REVFIM" , "C", 03, 0}) ; aAdd(aMatSG1, {"G1_OPERACA", "C", 02, 0})
       cQry1 := ""
       For nX := 1 To Len(aMatSG1)
           If !Alltrim(aMatSG1[nX][1]) $ 'G1_DESC.G1_PESESP.G1_CUSTOUN.G1_CUSTORE.G1_CUSTODO'
              cQry1 += ","+aMatSg1[nX][1]
           Endif
       Next nX
       nPosCom := aScan(aMatSG1, { |x| Trim(x[1]) == "G1_COMP"    } )
       nPosPda := aScan(aMatSG1, { |x| Trim(x[1]) == "G1_PERDA"   } )
       nPosQtd := aScan(aMatSG1, { |x| Trim(x[1]) == "G1_QUANT"   } )
       nPosPer := aScan(aMatSG1, { |x| Trim(x[1]) == "G1_PERC"    } )
       nPosCUn := aScan(aMatSG1, { |x| Trim(x[1]) == "G1_CUSTOUN" } )
       nPosCRe := aScan(aMatSG1, { |x| Trim(x[1]) == "G1_CUSTORE" } )
       nPosCDo := aScan(aMatSG1, { |x| Trim(x[1]) == "G1_CUSTODO" } )
       nPosPes := aScan(aMatSG1, { |x| Trim(x[1]) == "G1_PESESP"  } )
       nPosOpe := aScan(aMatSG1, { |x| Trim(x[1]) == "G1_OPERACA" } )
       cQry1 := "SELECT "+SubStr(cQry1, 2)+" "
       cQry1 += "FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
       cQry1 += "WHERE SG1.G1_FILIAL='"+xFilial("SZN")+"' "
       cQry1 += "  AND SG1.G1_COD='"+M->ZM_CODIGO+"' "
       cQry1 += "  AND SG1.D_E_L_E_T_=' ' "
       cQry1 += "ORDER BY SG1.G1_TRT "
       TCQuery cQry1 ALIAS "QSG1" NEW
       DbSelectArea("QSG1")
       
       For nX := 1 To Len(aMatSG1)
           If ( aMatSG1[nX][2]<>"C" ) .AND. !(Alltrim(aMatSG1[nX][1]) $ 'G1_PESESP.G1_CUSTOUN.G1_CUSTORE.G1_CUSTODO')
              TcSetField("QSG1", aMatSG1[nX][1], aMatSG1[nX][2], aMatSG1[nX][3], aMatSG1[nX][4])
           EndIf
       Next
       DbGoTop()
       While !Eof()
            // produto de custeio
            //If U_IsProdCusto(QSG1->G1_COMP)
            //   QSG1->(dbSkip())
            //   Loop
            //Endif   

             aAdd(aColsVig, Array( Len( aMatSG1 ) ) )
             nLin ++
             For nX := 1 To Len(aMatSG1)
                 If aMatSG1[nX][1] $ "G1_COMP.G1_TRT.G1_PERC.G1_QUANT.G1_PERDA.G1_INI.G1_FIM.G1_FIXVAR.G1_REVINI.G1_REVFIM.G1_OPERACA"
                    aColsVig[nLin][nX] := QSG1->&(aMatSG1[nX][1])
                 Else
                    If aMatSG1[nX][1] $ "G1_DESC"
                       aColsVig[nLin][nX] := Posicione("SB1", 1, xFilial("SB1")+aColsVig[nLin][nPosCom], "B1_DESC")
                    ElseIf aMatSG1[nX][1] $ "G1_PESESP"
                           aColsVig[nLin][nX] := Posicione("SB1", 1, xFilial("SB1")+aColsVig[nLin][nPosCom], "B1_PESOESP")
                    ElseIf aMatSG1[nX][1] $ "G1_CUSTOUN"
                           // produto de custeio
                           If U_IsProdCusto(aColsVig[nLin][nPosCom])
                              aColsVig[nLin][nX] := CriaVar("ZN_CUSTOUN")
                              Loop
                           Endif    
                           If Posicione("SB1", 1, xFilial("SB1")+aColsVig[nLin][nPosCom], "B1_TIPO") $ "MP.MC"
                              aColsVig[nLin][nX] := Round(Posicione("SB1", 1, xFilial("SB1")+aColsVig[nLin][nPosCom], "B1_UPRC"), 3)
                           Else
                              aColsVig[nLin][nX] := Round(U_fCCusPro(aColsVig[nLin][nPosCom]), 3)//Round(U_CustoPro(aColsVig[nLin][nPosCom]), 3)
                           Endif
                    ElseIf aMatSG1[nX][1] $ "G1_CUSTORE"
                           // produto de custeio
                           If U_IsProdCusto(aColsVig[nLin][nPosCom])
                              aColsVig[nLin][nX] := CriaVar("ZN_CUSTORE")
                              Loop
                           Endif    
                           //aColsVig[nLin][nX] := (aColsVig[nLin][nPosQtd] + (aColsVig[nLin][nPosQtd] * (aColsVig[nLin][nPosPda] / 100))) * aColsVig[nLin][nPosCUn]
						   aColsVig[nLin][nX] := (aColsVig[nLin][nPosQtd] / (1-(aColsVig[nLin][nPosPda] / 100))) * aColsVig[nLin][nPosCUn]
                    ElseIf aMatSG1[nX][1] $ "G1_CUSTODO"
                           // produto de custeio
                           If U_IsProdCusto(aColsVig[nLin][nPosCom])
                              aColsVig[nLin][nX] := CriaVar("ZN_CUSTODO")
                              Loop
                           Endif    
                           //aColsVig[nLin][nX] := (aColsVig[nLin][nPosQtd] + (aColsVig[nLin][nPosQtd] * (aColsVig[nLin][nPosPda] / 100))) / Posicione("SM2", 1, dDataBase, "M2_MOEDA2")
						   aColsVig[nLin][nX] := (aColsVig[nLin][nPosQtd] / (1- (aColsVig[nLin][nPosPda] / 100))) / Posicione("SM2", 1, dDataBase, "M2_MOEDA2")
                    Endif
                 Endif
             Next
             DbSelectArea("QSG1")
             DbSkip()
       Enddo
     DbSelectArea("QSG1")
     DbCloseArea()
     nPerVig := 0
     nCusRVg := 0
     nCusDVg := 0
     If Len(aColsVig) == 0
        aadd(aColsVig, {} )
        For nX := 1 To Len(aMatSG1)
            aadd(aColsVig[1], "")
        Next nX
     Else
        For nX := 1 To Len(aColsVig)
            // produto de custeio
            If U_IsProdCusto(aColsVig[nX][nPosCom])
               Loop
            Endif   
            If Posicione("SB1", 1, xFilial("SB1")+M->ZM_CODIGO, "B1_TIPO") $ "PA"
               nPerVig := 0
            Else
               nPerVig += aColsVig[nX][nPosPer]
            Endif
            nCusRVg += Round(aColsVig[nX][nPosCRe], 3)
            nCusDVg += Round(aColsVig[nX][nPosCDo], 3)
        Next
     Endif
     //LGS#20200210 - Adequação de release 12.1.25 e posteriores
     /*DbSelectArea("SX3")
     DbSetOrder(2)
     For nX := 1 To Len(aMatSZN)
         MsSeek( Trim(aMatSZN[nX][1]) )
         For nY := 1 To Len(aColsVig)
             aColsVig[nY][nX] := TransForm(aColsVig[nY][nX], SX3->X3_PICTURE)
         Next
     Next*/
     DbSelectArea( _cAliasSX3 )
     ( _cAliasSX3 )->( DbSetOrder(2) )
     For nX := 1 To Len(aMatSZN)
         MsSeek( Trim(aMatSZN[nX][1]) )
         For nY := 1 To Len(aColsVig)
             aColsVig[nY][nX] := TransForm(aColsVig[nY][nX], ( _cAliasSX3 )->( X3_PICTURE ) )
         Next
     Next
     If M->ZM_TIPO $ 'PI' .and. Alltrim(Posicione("SZM", 1, xFilial("SZM")+M->ZM_CODIGO+M->ZM_REVISAO, "ZM_UM")) == 'L'
        nCusOVg := nCusRVg / nPesVig
   	 Endif    
     aPVCBri := {}
     aPVCBri := U_fCPvcBri(M->ZM_CODIGO)
     nPVCVig := aPVCBri[1]
     nBriVig := aPVCBri[2]
     If M->ZM_TIPO $ 'PI'
        If QtdComp(nCusRRv) <> QtdComp(nCusRVg)
           nDifer := QtdComp(nCusRRv) - QtdComp(nCusRVg)
           If ABS(nDifer) < 0.005
              nCusRRv := Iif(nDifer < 0, (nCusRRv + (nDifer * -1)), nCusRRv - nDifer)
           Endif
        Endif 
        if nCusRRv > 0 //Cleber (23/11/16) -> Estava dando divisão por zero!
	        nVarVal := Round( ( ( ( nCusRRv / Iif(nCusRVg == 0, nCusRRv, nCusRVg) ) - 1 ) * 100 ), 3)
		else
			nVarVal := 0
		endif 
							       
        cBitMap := Iif( nVarVal == 0, 'QMT_COND', Iif( nVarVal < 0, 'QMT_OK', 'QMT_NO' ) )
     Else
        If QtdComp(nPrcRev) <> QtdComp(nPrcVig)
           nDifer := QtdComp(nPrcRev) - QtdComp(nPrcVig)
           If ABS(nDifer) < 0.005
              nPrcRev := Iif(nDifer < 0, (nPrcRev + (nDifer * -1)), nPrcRev - nDifer)
           Endif
        Endif
        nVarVal := Round( ( ( ( nPrcRev / Iif(nPrcVig == 0, nPrcRev, nPrcVig) ) - 1 ) * 100 ), 3)
        cBitMap := Iif( nVarVal == 0, 'QMT_COND', Iif( nVarVal < 0, 'QMT_OK', 'QMT_NO' ) )
     Endif
     DbSelectArea( _cAliasSX3 )
     DbCloseArea()
Return

/******************************************************************************************************************/
/*** fCarrRev - Monta variáveis das fórmulas revisadas.                                                         ***/
/******************************************************************************************************************/
Static Function fCarrRev(aHeader, aCols, nPerRev, nPesRev, nPVCRev, nBriRev, nCusRRv, nCusDRv, nCusORv, nPrcRev)
       Local nUsado := 0
       Local cQry   := ""
       Local nPosCom := 0
       Local nPosPer := 0
       Local nPosQtd := 0
       Local nPosPda := 0
       Local nPosCUn := 0
       Local nPosCRe := 0
       Local nPosCDo := 0
       Local nPosPEs := 0
       Local nPosSeq := 0
       Local nPosDes := 0
       Local nPosOpe := 0
       Local nSomPes := 0
       Local cKL     := ""
       Local nX, nY,cQry1,cTcq
       //Local nZ
       Local _lOpen        := .F. //LGS#20200207 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200207 - Adequação para release 12.1.25
     
       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200207 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0

       If !_lOpen //LGS#20200128 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 07/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SZN")
       While !Eof() .And. (X3_ARQUIVO == "SZN")
             If X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. !(TRIM(X3_CAMPO) $ "ZN_FILIAL")
                nUsado += 1
                AADD(aHeader, { Trim(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
             EndIf
             DbSkip()
       Enddo*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("SZN") )
       While !Eof() .And. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SZN")
             If X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .And. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) .And. !( TRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZN_FILIAL" )
                nUsado += 1
                AADD(aHeader, { Trim( ( _cAliasSX3 )->( X3_TITULO ) ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_VALID ), ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
             EndIf
             DbSkip()
       Enddo
       /********************************************************************************************************************************/
       nPosCom := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_COMP"   } )
       nPosPer := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERC"   } )
       nPosQtd := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_QUANT"  } )
       nPosPda := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PERDA"  } )
       nPosCUn := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTOUN"} )
       nPosCRe := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTORE"} )
       nPosCDo := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_CUSTODO"} )
       nPosPEs := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_PESESP" } )
       nPosSeq := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_TRT"    } )
       nPosDes := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_DESC"   } )
       nPosOpe := aScan( aHeader, { |x| Alltrim(x[2]) == "ZN_OPERACA"} )
	   cKL     := Iif(Alltrim(Posicione("SZ5", 1, xFilial("SZ5")+SubStr(M->ZM_CODIGO, 11, 02), "Z5_UMEMB"))='K','99','00')
      
       DbSelectArea("SZN")
       DbSetOrder(2)
       DbSeek(xFilial("SZN")+M->ZM_CODIGO+M->ZM_REVISAO, .t.)
       If Found()
          cQry += "SELECT SZN.ZN_COMP    AS ZN_COMP, ISNULL(SB1.B1_DESC, "
          cQry += " ( SELECT SZM.ZM_DESCRIC FROM "+RetSqlName("SZM")+" SZM WITH (NOLOCK) WHERE SZM.ZM_FILIAL = '"+xFilial("SZM")+"' AND SZM.D_E_L_E_T_ = '' AND SZM.ZM_CODIGO ='"+Substr(M->ZM_CODIGO,1,10)+cKL+"' AND SZM.ZM_REVISAO = '"+M->ZM_REVISAO+"' ) ) AS ZN_DESC, "
          cQry += "       SZN.ZN_TRT     AS ZN_TRT    , SZN.ZN_PERC    AS ZN_PERC, "
          cQry += "       SZN.ZN_QUANT   AS ZN_QUANT  , SZN.ZN_PERDA   AS ZN_PERDA, "
          cQry += "       CASE WHEN "
		  cQry += "       	LEN(SZN.ZN_CODIGO) = 12 AND SUBSTRING(SZN.ZN_CODIGO, 11, 2) NOT IN('00','99') "
	      cQry += "       THEN SZN.ZN_PESESP "
		  cQry += "	      ELSE SB1.B1_PESOESP END 
		  cQry += "       AS ZN_PESESP                , 0              AS ZN_CUSTOUN, "//          cQry += "       SB1.B1_PESOESP AS ZN_PESESP , 0              AS ZN_CUSTOUN, "
          cQry += "       0              AS ZN_CUSTORE, 0              AS ZN_CUSTODO, "
          cQry += "       SZN.ZN_INI     AS ZN_INI    , SZN.ZN_FIM     AS ZN_FIM, "
          cQry += "       SZN.ZN_FIXVAR  AS ZN_FIXVAR , SZN.ZN_REVINI  AS ZN_REVINI, "
          cQry += "       SZN.ZN_REVFIM  AS ZN_REVFIM , SZN.ZN_OPERACA AS ZN_OPERACA "
          cQry += "FROM "+RetSqlName("SZN")+" SZN WITH (NOLOCK) "
          cQry += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SZN.ZN_FILIAL = SB1.B1_FILIAL AND SZN.ZN_COMP = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
          cQry += "WHERE SZN.D_E_L_E_T_ = '' "
          cQry += "  AND SZN.ZN_FILIAL  = '"+xFilial("SZN")+"' "
          cQry += "  AND SZN.ZN_CODIGO  = '"+M->ZM_CODIGO+"' "
          cQry += "  AND SZN.ZN_REVISAO = '"+M->ZM_REVISAO+"' "
          cQry += "ORDER BY SZN.ZN_FILIAL, SZN.ZN_CODIGO, SZN.ZN_REVISAO, SZN.ZN_TRT "
          TCQuery cQry ALIAS "TCQ" NEW
          DbSelectArea("TCQ")
          DbGoTop()
          While !Eof()
               // produto de custeio
               //If U_IsProdCusto(TCQ->ZN_COMP)
               //   TCQ->(dbSkip())
               //   Loop
               //Endif   

                aAdd(aCols, Array(nUsado + 1))
                For nX := 1 To nUsado
                    If Alltrim(aHeader[nX][2]) $ 'ZN_CUSTOUN'
                       // produto de custeio
                       If U_IsProdCusto(aCols[Len(aCols)][nPosCom])
                           aCols[Len(aCols)][nX] := CriaVar("ZN_CUSTOUN")
                           Loop
                       Endif    
                       If Posicione("SB1", 1, xFilial("SB1")+aCols[Len(aCols)][1], "B1_TIPO") $ 'MP.MC'
                          aCols[Len(aCols)][nX] := Round(Posicione("SB1", 1, xFilial("SB1")+aCols[Len(aCols)][1], "B1_UPRC"), 6)
                       Else
                          If Len(Alltrim(aCols[Len(aCols)][1])) == 12
                             cQry1 := ""
                             cQry1 += "SELECT * "
                             cQry1 += "FROM "+RetSqlName("SZM")+" SZM WITH (NOLOCK) "
                             cQry1 += "WHERE SZM.ZM_FILIAL  = '"+xFilial("SZM")+"' "
                             cQry1 += "  AND SZM.D_E_L_E_T_ = '' "
                             cQry1 += "  AND SZM.ZM_ID      = '"+M->ZM_ID+"' "
                             cQry1 += "  AND SUBSTRING(SZM.ZM_CODIGO, 11, 2) IN('"+Substr(aCols[Len(aCols)][1],11,2)+"') "
                             TCQuery cQry1 ALIAS "REV" NEW
                             DbSelectArea("REV")
                             DbGoTop()
                             If Eof()
                                aCols[Len(aCols)][nX] := Round(U_fCCusPro(aCols[Len(aCols)][nPosCom],Nil), 3)
                             Else
                                aCols[Len(aCols)][nX] := Round(U_fCCusPro(aCols[Len(aCols)][nPosCom],REV->ZM_REVISAO), 3)
                             Endif
                             DbSelectArea("REV")
                             DbCloseArea()
                          Else
                             aCols[Len(aCols)][nX] := Round(U_fCCusPro(aCols[Len(aCols)][1],Nil), 3)
                          Endif
                       Endif
                    ElseIf Alltrim(aHeader[nX][2]) $ 'ZN_CUSTORE'
                           // produto de custeio
                           If U_IsProdCusto(aCols[Len(aCols)][nPosCom])
                              aCols[Len(aCols)][nX] := CriaVar("ZN_CUSTORE")
                              Loop
                           Endif   
                           //aCols[Len(aCols)][nX] := ( aCols[Len(aCols)][nPosQtd] + ( aCols[Len(aCols)][nPosQtd] / (1- ( aCols[Len(aCols)][nPosPda] / 100 ) ) ) ) * aCols[Len(aCols)][nPosCUn]
						   aCols[Len(aCols)][nX] := ( ( aCols[Len(aCols)][nPosQtd] / (1- ( aCols[Len(aCols)][nPosPda] / 100 ) ) ) ) * aCols[Len(aCols)][nPosCUn]
                    ElseIf Alltrim(aHeader[nX][2]) $ 'ZN_CUSTODO'
                           // produto de custeio
                           If U_IsProdCusto(aCols[Len(aCols)][nPosCom])
                              aCols[Len(aCols)][nX] := CriaVar("ZN_CUSTODO")
                              Loop
                           Endif   
                           //aCols[Len(aCols)][nX] := ( aCols[Len(aCols)][nPosQtd] + ( aCols[Len(aCols)][nPosQtd] * ( aCols[Len(aCols)][nPosPda] / 100 ) ) ) / Posicione("SM2", 1, dDataBase, "M2_MOEDA2")
                           aCols[Len(aCols)][nX] := ( aCols[Len(aCols)][nPosQtd] / (1- ( aCols[Len(aCols)][nPosPda] / 100 ) ) ) / Posicione("SM2", 1, dDataBase, "M2_MOEDA2")
                    ElseIf AllTrim(aHeader[nX][2]) == 'ZN_QUANT'
                           If TCQ->&(aHeader[nX][2]) == 0
                              If M->ZM_TIPO $ 'PA'
                                 aCols[Len(aCols)][nX] := aCols[Len(aCols)][nPosPer]
                              Else
                                 // produto de custeio
                                 If U_IsProdCusto(aCols[Len(aCols)][nPosCom])
                                    aCols[Len(aCols)][nX] := (aCols[Len(aCols)][nPosPer] / 100)
                                    Loop
                                 Endif   
                                 If Alltrim(M->ZM_UM) $ 'K'
                                    aCols[Len(aCols)][nX] := (aCols[Len(aCols)][nPosPer] / 100)
                                 Else
                                    aCols[Len(aCols)][nX] := (aCols[Len(aCols)][nPosPer] / 100) * M->ZM_PESESP
                                 Endif
                              Endif
                           Else
                              aCols[Len(aCols)][nX] := TCQ->&(aHeader[nX][2])
                           Endif
                    Else
                       If aHeader[nX][8] $ 'D'
                          aCols[Len(aCols)][nX] := ctod(SubStr(TCQ->&(aHeader[nX][2]), 7,2)+'/'+SubStr(TCQ->&(aHeader[nX][2]), 5,2)+'/'+SubStr(TCQ->&(aHeader[nX][2]), 1,4))
                       Else
                          aCols[Len(aCols)][nX] := TCQ->&(aHeader[nX][2])
                       Endif
                    Endif
                Next
                aCols[Len(aCols)][nUsado + 1] := .F.
                // produto de custeio
                If U_IsProdCusto(aCols[Len(aCols)][nPosCom])
                Else
                   nSomPes += aCols[Len(aCols)][nPosPer] / aCols[Len(aCols)][nPosPEs]
                Endif   
                DbSelectArea("TCQ")
                DbSkip()
          Enddo
          DbSelectArea("TCQ")
          DbCloseArea()

         //Cleber(04/12/20)->Chamado 020112, estava mostrando custo incoerente em determinadas circunstâncias
		   cTcq := U_NovoCursor()   
         cQry1 := "SELECT dbo.CustoMpSZN('"+xFilial("SZN")+"','"+M->ZM_CODIGO+"',1.0,'"+M->ZM_REVISAO+"') AS CUSTO "
         TCQuery cQry1 NEW ALIAS (cTcq)
         DbSelectArea(cTcq)
         nCusRRv := (cTcq)->CUSTO
		   dbselectarea(cTcq)
		   dbCloseArea()

          //nCusRRv := 0 //Cleber(04/12/20)->Chamado 020112, estava mostrando custo incoerente em determinadas circunstâncias
          nCusDRv := 0
          If !M->ZM_TIPO $ 'PA'
             nPesRev := M->ZM_PESESP
             nPVCRev := M->ZM_PVC
             nBriRev := M->ZM_BRILHO
             nPerRev := 0
             For nY := 1 To Len(aCols)
                 // produto de custeio
                 If U_IsProdCusto(aCols[nY][nPosCom])
                     Loop
                 Endif    
                 nPerRev += aCols[nY][nPosPer]
                 //nCusRRv += aCols[nY][nPosCRe] //Cleber(04/12/20)->Chamado 020112, estava mostrando custo incoerente em determinadas circunstâncias
                 nCusDRv += aCols[nY][nPosCDo]
             Next
             If Alltrim(Posicione("SZM", 1, xFilial("SZM")+M->ZM_CODIGO+M->ZM_REVISAO, "ZM_UM")) == 'L'
                nCusOrv := nCusRRv / nPesRev
             Else
                nCusOrv := nCusRRv
                //nCusORv := 0
             Endif
          Else
             nPerRev := 0
             nPesRev := 0
             nPVCRev := 0
             nBriRev := 0
             nPerRev := 0
             For nY := 1 To Len(aCols)
                 // produto de custeio
                 If U_IsProdCusto(aCols[nY][nPosCom])
                     Loop
                 Endif    
                 nCusRRv += aCols[nY][nPosCRe]
                 //nCusRRv += aCols[nY][nPosCRe] //Cleber(04/12/20)->Chamado 020112, estava mostrando custo incoerente em determinadas circunstâncias
                 nCusDRv += aCols[nY][nPosCDo]
             Next
 			 If !M->ZM_STATUS $ 'AC'
 			 	nPrcRev := U_fBusPrc(M->ZM_CODIGO, Iif(M->ZM_TIPOPRO $ 'PE', "VIG", 'NEW'),  , "2", aHeader, aCols)
			 Else
 	    	 	//nPrcRev := U_fBusPrc(M->ZM_CODIGO, "VIG",  , "2", aHeader, aCols)
			 	nPrcRev := U_fCPrcVen(M->ZM_CODIGO, M->ZM_REVISAO, 'REV')
			 Endif
          Endif
          aPVCBri := {}
          aPVCBri := U_fCPvcBri(M->ZM_CODIGO, M->ZM_REVISAO, aHeader, aCols)
          nPVCRev := aPVCBri[1]
          nBriRev := aPVCBri[2]
       Else
          aAdd(aCols, Array(nUsado + 1) )
          For nX := 1 To nUsado
              aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2])
          Next
          aCols[Len(aCols)][nUsado + 1] := .F.
       Endif
       aSort(aCols ,,,{|x,y| x[3] < y[3] })
       DbSelectArea( _cAliasSX3 )
       DbCloseArea()
Return

Static Function EstaAutori(_cCodigo)
       Local _aRetInf, _nX
       Local lRet,cLinha,nArea,_cCodUsr
       //Local lAux
       nArea    := Alias()
       _cCodUsr := RetCodUsr()
       _aRetInf := FWGetSX5( "W0", _cCodUsr )
       lRet     := .t.
      If PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),_cCodUsr) != 0
          If Len(Trim(_cCodigo)) == 12
             lRet   := .f.
             cLinha := Substr(_cCodigo,4,2)
             
             /********************************************************************************************************************************/
             /*** BLOCO ALTERADO EM 10/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
             /*DbSelectarea("SX5")
             dbsetorder(1)
             dbseek(xFilial("SX5")+"W0"+_cCodUsr,.t.)
             do while !eof() .and. (xFilial("SX5") = SX5->X5_FILIAL) .AND. (SX5->X5_TABELA = 'W0') .AND. (SX5->X5_CHAVE == _cCodUsr)
                if alltrim(SX5->X5_DESCRI) == alltrim(xFilial("SG1"))+cLinha
                   lRet = .t.
                   exit
                endif
                dbselectarea("SX5")
                dbskip()
             enddo*/
             For _nX := 1 To Len( _aRetInf )
                 If _aRetInf[_nX][3] == _cCodUsr
                    If Alltrim( _aRetInf[_nX][4] ) == Alltrim( xFilial("SG1") ) + cLinha
                       lRet = .t.
                       exit
                    Endif
                 Endif
             Next
             If lRet .and. lFiltBM
                lRet := &cFiltBM
             Endif 
          Endif 
      Endif 
       DbSelectArea(nArea)
return(lRet)
