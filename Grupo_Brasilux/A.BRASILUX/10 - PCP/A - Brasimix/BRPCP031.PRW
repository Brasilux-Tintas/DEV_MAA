#Include "Protheus.ch"
#Include "TopConn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRPCP031  บAutor  ณ Nelieder Corneta  บ Data ณ  13/12/2021 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Programar OPดs especificos, antigo BrasTintas               ฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Descri็ใo das fun็๕es utilizadas no programa                          บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ PCP031_01 ฑฑ Identifica Itens Selecionados para produ็ใo               ฑฑ 
ฑฑบ PCP031_02 ฑฑ Seleciona registros e popula grid                         ฑฑ 
ฑฑบ PCP031_03 ฑฑ Marca ou Desmarca todos os checkbox                       ฑฑ 
ฑฑบ PCP031_04 ฑฑ Fun็ใo chamada ao selecionar linha do grid (checkbox)     ฑฑ 
ฑฑบ PCP031_05 ฑฑ Inseri dados nas tabelas Especificos e Espedidos          ฑฑ 
ฑฑบ PCP031_06 ฑฑ Atualiza o campo C6_XESPECI no Pedido                     ฑฑ 
ฑฑบ PCP031_07 ฑฑ Gera Ordem de Produ็ใo                                    ฑฑ 
ฑฑบ PCP031_10 ฑฑ Pergunta se deve produzir (Sim/Nใo)                       ฑฑ 
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

 
/*/{Protheus.doc} BRPCP031
Programar OPดs especificos, antigo BrasTintas
@type function
@version 1.0  
@author neliedercorneta
@since 13/12/2021
/*/ 
User Function BRPCP031()

    Local aArea := GetArea()
    Local nTipo     := 1
    
    //Objetos da Janela
    Private oDlgPvt
    Private oMsGetSBM
    Private aHeadSBM := {}
    Private aColsSBM := {}
    Private oBtnSalv
    Private oBtnDesm
    Private oBtnPesq
    Private oBtnFech
    Private oBtnLege
	Private nRet := 12632256

    //Tamanho da Janela
    Private    nJanLarg    := 1200
    Private    nJanAltu    := 850

    Private oBord
    Private cBord := space(30)

    Private FlagMarc := .F.

    //Fontes
    Private    cFontUti   := "Tahoma"
    Private    oFontAno   := TFont():New(cFontUti,,-38)
    Private    oFontSub   := TFont():New(cFontUti,,-16)
    Private    oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
    Private    oFontBtn   := TFont():New(cFontUti,,-14)

    //              Ttญtulo               Campo        Mรกscara Tamanho   Decimal    Valid         Usado      Tipo F3    Combo   Contexto   ComboBox     Relacao	 Inicializador Browse    Mostra no Browse   X3_VISUAL 
    aAdd(aHeadSBM, {" ",                  "Leg"    ,   "@BMP"  , 002    , 0         , "   "     , "   "     , "C"       , "",    "V", 		"", 		"",			""						, "V"				,"S"})        
    aAdd(aHeadSBM, {"Produto",            "PRODUTO",    ""     , 020    , 0         , ".T."     , ".T."     , "C"       , "",    ""						  	  } )
    aAdd(aHeadSBM, {"Pedido",             "PEDIDO",     ""     , 015    , 0         , "   "     , ".T."     , "C"       , "",    ""							  } )
    aAdd(aHeadSBM, {"Codigo ",            "CODIGO",     ""     , 015    , 0         , "   "     , ".T."     , "C"       , "",    ""} )
    aAdd(aHeadSBM, {"Nome",               "NOME",       ""     , 080    , 0         , "   "     , ".T."     , "C"       , "",    ""} )
    aAdd(aHeadSBM, {"Qtde",               "QTDE",       ""     , 010    , 0         , "   "     , ".T."     , "C"       , "",    ""} )    
    aAdd(aHeadSBM, {"Liberado",           "XX_LIN",     "@BMP" , 010    , 0         , ".F."     , "   "     , "C"       , "",    "V", "", "","", "V"})
    aAdd(aHeadSBM, {"Fabricar ?",         "CHECKBOL",   "@BMP" , 010    , 0         , "   "     , "   "     , "C"       , "",    "V", "", "","", "V","S"})        
    aAdd(aHeadSBM, {"VOLUME",             "VOLUME",     "  "   , 010    , 0         , "   "     , "   "     , "C"       , "",    ""} )
    aAdd(aHeadSBM, {"REDESP",             "REDESP",     "  "   , 010    , 0         , "   "     , "   "     , "C"       , "",    ""} )
    aAdd(aHeadSBM, {"REGISTRO",           "REGISTRO",   " "    , 010    , 0         , "   "     , "   "     , "C"       , "",    ""} )
	aAdd(aHeadSBM, {"FLAGCOR",            "FLAGCOR"    ,"  "   , 010    , 0         , "   "     , "   "     , "N"       , "",    "V", 		"", 		"",			""						, "V"				,"S"})        

    dbselectarea("ZA6")    
    dbselectarea("ZA5")    
    
    If !LockByName("BRPCP031", .T., .F.)
        MsgStop("Rotina bloqueada para uso!", "Aten็ใo")
        Return
    else
        LockByName("BRPCP031",.T.,.F.)    
    EndIf
 
    //Cria็ใo da tela com os dados que serใo informados
    DEFINE MSDIALOG oDlgPvt TITLE "Programa็ใo de Produtos Especificos" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
    @ 006, (nJanLarg/2-001)-(0052*01.2) BUTTON oBtnFech  PROMPT "Fechar (ESC)"          SIZE 060, 018 OF oDlgPvt ACTION fechar()  FONT oFontBtn PIXEL
    @ 006, (nJanLarg/2-001)-(0052*03)   BUTTON oBtnPesq  PROMPT "Buscar Produtos (F5)"  SIZE 080, 018 OF oDlgPvt ACTION MsAguarde({|| PCP031_02(nTipo) },"Pesquisando...","Aguarde...") FONT oFontBtn PIXEL
    @ 005, (nJanLarg/2-001)-(0052*09)   RADIO  oTipo VAR nTipo PROMPT OemToAnsi("Todos os produtos"),OemToAnsi("Somente Especificos") OF oDlgPvt PIXEL  SIZE 75,12 
    @ 008, (nJanLarg/2-001)-(0052*10)   MSGET  oBord VAR cBord PICTURE "@!" SIZE 40,10 COLOR CLR_BLUE PIXEL OF oDlgPvt FONT oFontBtn
    @ 010, (nJanLarg/2-001)-(0052*11.3) SAY OemToAnsi("Filtrar o Bord๊ro")  SIZE 060,009  PIXEL OF oDlgPvt FONT oFontSub
         
    //Grid dos grupos
    oMsGetSBM := MsNewGetDados():New( 029,;                 //nTop      - Linha Inicial
                                      003,;                 //nLeft     - Coluna Inicial
                                      ((nJanAltu-50)/2)-3,; //nBottom   - Linha Final
                                      (nJanLarg/2)-3,;      //nRight    - Coluna Final
                                      GD_UPDATE,;           //nStyle    - Estilos para edi็ใo da Grid (GD_INSERT = Inclusใo de Linha; GD_UPDATE = Altera็ใo de Linhas; GD_DELETE = Exclusใo de Linhas)
                                      "AllwaysTrue()",;     //cLinhaOk  - Valida็ใo da linha
                                      ,;                    //cTudoOk   - Valida็ใo de todas as linhas
                                      "",;                  //cIniCpos  - Fun็ใo para inicializa็ใo de campos
                                      {('QTDE')},;          //aAlter    - Colunas que podem ser alteradas
                                      ,;                    //nFreeze   - N๚mero da coluna que serแ congelada
                                      9999,;                //nMax      - Mแximo de Linhas
                                      ,;                    //cFieldOK  - Valida็ใo da coluna
                                      ,;                    //cSuperDel - Valida็ใo ao apertar '+'
                                      ,;                    //cDelOk    - Valida็ใo na exclusใo da linha
                                      oDlgPvt,;             //oWnd      - Janela que ้ a dona da grid
                                      aHeadSBM,;            //aHeader   - Cabe็alho da Grid
                                      aColsSBM)             //aCols     - Dados da Grid
    
    oMsGetSBM:oBrowse:bLDblClick := {|| oMsGetSBM:EditCell(), PCP031_04(oMsGetSBM,oMsGetSBM:oBrowse:ColPos)}    
    oMsGetSBM:oBrowse:nLinhas := 1.5 
    oMsGetSBM:oBrowse:SetCSS(;
            "QHeaderView::Section {font-weight: bold;} " +; //Cabe็alho
            "QTableView { font-size: 14px; } "; //Grid
        )
	oMsGetSBM:oBrowse:lUseDefaultColors := .F.		
	oMsGetSBM:oBrowse:SetBlkBackColor({|| GETDCLR(oMsGetSBM:nAt,8421376)})	
                                   
    @ 403, 005  BUTTON oBtnSalv  PROMPT "Produzir (F8)" SIZE 060, 018 OF oDlgPvt ACTION (PCP031_10()) FONT oFontBtn PIXEL
    @ 403, 480  BUTTON oBtnDesm  PROMPT "Desmarcar\Marcar Todos (F12)" SIZE 115, 018 OF oDlgPvt ACTION PCP031_03() FONT oFontBtn PIXEL
    
    SetKey( VK_F12, { || PCP031_03() } )
    SetKey( VK_F8,  { || PCP031_10() } )
    SetKey( VK_F5,  { || MsAguarde({|| PCP031_02(nTipo) },"Pesquisando...","Aguarde...")  } )
    
    
    oDlgPvt:lEscClose := .T.
    ACTIVATE MSDIALOG oDlgPvt CENTERED
     
    RestArea(aArea)
Return



Static Function GETDCLR(nLinha,nCor)
	
	
	Local nProd    := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "PRODUTO"})
	Local nFcor    := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "FLAGCOR"})
	Local aColsAux := oMsGetSBM:aCols
	
	if aColsAux[nLinha][nFcor] <>  0	
		Return aColsAux[nLinha][nFcor]
	endif	

	if (nLinha > 1)

		Atual := SUBSTRING(aColsAux[nLinha][nProd],1,10)

		if nLinha >= 2
			Anterior := SUBSTRING(aColsAux[nLinha-1][nProd],1,10)
		EndIf

		if nLinha < Len(aColsAux)
			Proximo := SUBSTRING(aColsAux[nLinha+1][nProd],1,10)
		else
			Proximo := '0'
		EndIf

		/*if Atual == Proximo .AND. Anterior == Atual
                nRet := 12632256
         endif*/

            if Atual == Proximo .AND. Anterior <> Atual
                if nRet == 12632256
                    nRet := 16776960
                else
                    nRet := 12632256
                endif
            endif
            
            if Atual <> Proximo .AND. Anterior <> Atual
                if nRet == 12632256
                    nRet := 16776960
                else
                    nRet := 12632256
                endif

            endif

            if  Anterior == Atual
                nRet := nRet
            endif

	end

aColsAux[nLinha][nFcor] := nRet	
Return nRet

Static Function fechar()
    UnlockByName("BRPCP031", .T., .F., .F.)
    (oDlgPvt:End())
return


/*/{Protheus.doc} PCP031_04
Fun็ใo chamada ao selecionar linha do grid (checkbox)
@type function
@author neliedercorneta
@since 15/12/2021
@param oMsGetSBM, object, grid
@param coluna, character, qual coluna selecionada
/*/
Static Function PCP031_04(oMsGetSBM,coluna)
   
    if coluna <> 6
        oMsGetSBM:aCols[oMsGetSBM:nAt,8] := iif(oMsGetSBM:aCols[oMsGetSBM:nAt,8] == 'LBOK','LBNO','LBOK')
    EndIf
    
Return


/*/{Protheus.doc} PCP031_02
Seleciona registros e popula grid
@type function
@version 1.0 
@author neliedercorneta
@since 15/12/2021
@param nTipo, numeric, nTipo = 1 todos os produtos ou  nTipo = 2 Somente Especificos
/*/
Static Function PCP031_02(nTipo)

    /*
        nTipo = 1 todos os produtos
        nTipo = 2 Somente Especificos
    */

Local aArea  := GetArea()
Local cQuery   := ""
Local nAtual := 0
Local nTotal := 0
Local nLiberado := 0
Local nFabric
//Local xVarProd
//Local cVarProd
Local leg

        /* imagem que representa checck */
Private     _oOk          := LoadBitmap( GetResources(), "CHECKED"   )
Private     _oNo          := LoadBitmap( GetResources(), "UNCHECKED" )
aColsSBM := {}


//Seleciona dados do documento de entrada
cQuery := " SELECT  SC6.R_E_C_N_O_ AS REG,C6_PRODUTO AS PRODUTO,B1_GRTRIB,C6_NUM AS PEDIDO,A1_NOME AS RAZAO,C6_CLI AS CLIENTE, "
cQuery += " C6_QTDVEN AS QTDE,C5_ESPECI4,C5_APROVA,C5_VOLUME1 AS VOLUME,C5_REDESP AS REDESP,C5_TIPO,B2_LOCALIZ AS LOCALIZ,"
cQuery += " FATURADO = CASE WHEN LEN(C5_NOTA) > 0 		THEN 'S' ELSE 'N' END,"
cQuery += " TEMG1 = ISNULL((SELECT TOP 1 R_E_C_N_O_ FROM "+RETSQLNAME("SG1")+" SG1 WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (G1_FILIAL = SC6.C6_FILIAL) AND (G1_COD = SC6.C6_PRODUTO)),0) "
cQuery += " FROM "+RETSQLNAME("SC6")+" SC6 WITH (NOLOCK)  "
cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '') AND (C6_TES = F4_CODIGO) "
cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) ON (C6_CLI = A1_COD) AND (SA1.D_E_L_E_T_ <> '*') "
cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SC5")+" SC5 WITH (NOLOCK) ON (C6_FILIAL = C5_FILIAL) AND (C6_NUM = C5_NUM) AND (SC5.D_E_L_E_T_ <> '*') "
cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SB1")+" SB1 WITH (NOLOCK) ON (C6_FILIAL = B1_FILIAL) AND (C6_PRODUTO = B1_COD) AND (SB1.D_E_L_E_T_ <> '*') "
cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B1_FILIAL = B2_FILIAL) AND (B1_COD = B2_COD) AND (B1_LOCPAD = B2_LOCAL) "
cQuery += " LEFT OUTER JOIN "+RETSQLNAME("QI2")+" QI2 WITH (NOLOCK) ON (QI2.D_E_L_E_T_ <> '*') AND (QI2_FILIAL = '"+xFilial("SC6")+"') AND (QI2_CODPRO > '') AND (QI2_CODPRO = C6_PRODUTO)  AND (QI2_STATUS = '2') "

if (!empty(cBord))
	cQuery += " LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON (C6_FILIAL = ZG_FILIAL) AND (C6_NUM = SUBSTRING(ZG_PEDIDO,3,6)) AND (SZG.D_E_L_E_T_ <> '*') "
EndIf

cQuery += " WHERE (C6_FILIAL = '"+xFilial("SC6")+"') AND (SC6.C6_XESPECI = 0) AND (SC6.D_E_L_E_T_ <> '*') AND (LEN(C6_PRODUTO) = 12) AND  "
cQuery += " (C5_LIBCAD = 'T') AND (C5_APROVA <> '2') AND (C5_TIPO = 'N') AND (C6_NOTA = '') AND (F4_ESTOQUE = 'S')  "

    /* Desconsiderar Transfer๊ncias de Matใo p/ Guarulhos */
cQuery += " AND (A1_CGC NOT LIKE '72770878%') "

if (!empty(cBord))
	cQuery += " AND ZG_CODIGO = '"+cBord+"' "
EndIf

        /* somente especificos */
if nTipo == 2
	cQuery += " AND ((B2_LOCALIZ = '') OR (B2_LOCALIZ IS NULL)) "
	cQuery += " AND (QI2.R_E_C_N_O_ IS NULL) "
EndIf

cQuery += " ORDER BY C6_PRODUTO "

IF Select("QRY_SBM") <> 0
	DbSelectArea("QRY_SBM")
	DbCloseArea()
ENDIF

cUsuario = PswChave(RetCodUsr())
if (cUsuario == 'neliedercorneta')
            /* gera log do script sql */
	GravaSQL(cQuery)
Endif


TCQuery cQuery New Alias "QRY_SBM"

//Setando o tamanho da r้gua
Count To nTotal
ProcRegua(nTotal)

//Enquanto houver dados
QRY_SBM->(DbGoTop())

While !QRY_SBM->(EoF())

	if (!empty(cBord))
		if  AllTrim(QRY_SBM->ZG_CODIGO) <> AllTrim(cBord )
			QRY_SBM->(DbSkip())
			loop
		Endif

	EndIf

	//Atualizar r้gua de processamento
	nAtual++

	if QRY_SBM->C5_APROVA == "1"
		nLiberado = _oOk
		nFabric = "LBOK"
	else
		nLiberado = _oNo
		nFabric = "LBNO"
	EndIf
	qProd = QRY_SBM->PRODUTO
	qPedi = QRY_SBM->PEDIDO
	qClie = QRY_SBM->CLIENTE
	qQtde = Padr(QRY_SBM->QTDE, 3)

	/*if cVarProd == xVarProd
		leg := LoadBitmap(GetResources(),'br_verde')
	else
		leg := LoadBitmap(GetResources(),'br_azul')
	EndIf*/


	aAdd(aColsSBM, { ;
		leg,;
		QRY_SBM->PRODUTO,;
		QRY_SBM->PEDIDO,;
		QRY_SBM->CLIENTE,;
		QRY_SBM->RAZAO,;
		Padr(QRY_SBM->QTDE, 3),;
		nLiberado,;
		nFabric,;
		AllTrim(cValToChar(QRY_SBM->VOLUME)),;
		QRY_SBM->REDESP,;
		cValToChar(QRY_SBM->REG),;
		0,;
		.F.;
		})

	QRY_SBM->(DbSkip())

EndDo

QRY_SBM->(DbGotop())
QRY_SBM->(DbCloseArea())


RestArea(aArea)
oMsGetSBM:SetArray(aColsSBM)
oMsGetSBM:oBrowse:Refresh()

//oMsGetSBM:oBrowse:SetBlkBackColor({|| GETDCLR(oMsGetSBM:nAt,8421376)})
//AltLeg()




Return

Static Function AltLeg()

	Local aColsAux := oMsGetSBM:aCols
	Local nLinha   := 0
	Local nFlag    := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "Leg"})
	Local nProd    := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "PRODUTO"})
	Local Atual
	Local Anterior
	Local Proximo
    Local xCor := "br_branco"

	

	//Percorrendo todas as linhas
	For nLinha := 1 To Len(aColsAux)

        if nLinha == 1
            aColsAux[nLinha][nFlag] = LoadBitmap(GetResources(),'br_branco')
            xCor := "br_branco"
        else
            Anterior := SUBSTRING(aColsAux[nLinha-1][nProd],1,10)
            Atual := SUBSTRING(aColsAux[nLinha][nProd],1,10)
            
            /* pega proximo */
            if nLinha < Len(aColsAux);Proximo := SUBSTRING(aColsAux[nLinha+1][nProd],1,10);else;Proximo := '0';EndIf

            if Atual == Proximo .AND. Anterior == Atual
                aColsAux[nLinha][nFlag] = LoadBitmap(GetResources(),xCor)
            endif

            if Atual == Proximo .AND. Anterior <> Atual
                if xCor == "br_branco"
                    xCor := "br_verde"
                else
                    xCor := "br_branco"
                endif
                aColsAux[nLinha][nFlag] = LoadBitmap(GetResources(),xCor)
            endif
            
            if Atual <> Proximo .AND. Anterior <> Atual
                if xCor == "br_branco"
                    xCor := "br_verde"
                else
                    xCor := "br_branco"
                endif
                aColsAux[nLinha][nFlag] = LoadBitmap(GetResources(),xCor)
            endif

            if  Anterior == Atual
                aColsAux[nLinha][nFlag] = LoadBitmap(GetResources(),xCor)
            endif

        endif

		/*Atual := SUBSTRING(aColsAux[nLinha][nProd],1,10)

		if nLinha >= 2
			Anterior := SUBSTRING(aColsAux[nLinha-1][nProd],1,10)
		EndIf

		if nLinha < Len(aColsAux)
			Proximo := SUBSTRING(aColsAux[nLinha+1][nProd],1,10)
		else
			Proximo := '0'
		EndIf

		if Atual == Proximo .or. Anterior == Atual
			aColsAux[nLinha][nFlag] = LoadBitmap(GetResources(),'br_verde')
			Continua := .T.
		Else
			aColsAux[nLinha][nFlag] = LoadBitmap(GetResources(),'br_branco')
			Continua := .F.
		EndIf*/


	Next

return

/*/{Protheus.doc} PCP031_03
Marca ou Desmarca todos os checkbox
@type function
@author neliedercorneta
@since 15/12/2021
/*/
Static Function PCP031_03()

	Local aColsAux := oMsGetSBM:aCols
	Local nLinha   := 0
	Local nFlag    := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "CHECKBOL"})
	Local valor

	if FlagMarc ==  .F.
		valor := 'LBNO'
		FlagMarc :=  .T.
	else
		valor := 'LBOK'
		FlagMarc :=  .F.
	EndIf

	//Percorrendo todas as linhas
	For nLinha := 1 To Len(aColsAux)
		aColsAux[nLinha][nFlag] = valor
	Next

return

/*/{Protheus.doc} PCP031_10
Fun็ใo que pergunta se deseja produzir
@type function
@author neliedercorneta
@since 15/12/2021
/*/
Static Function PCP031_10()

	If MsgYesNo('Confirma Produ็ใo ?', 'Aten็ใo')
		Processa({|| PCP031_01()}, "Aguardem... !")
	else
		return()
	Endif

return

/*/{Protheus.doc} PCP031_01
Identifica Itens Selecionados para produ็ใo 
@type function
@version 1.0 
@author neliedercorneta
@since 15/12/2021
/*/
Static Function PCP031_01()


	Local aColsAux := oMsGetSBM:aCols
	Local nFlag    := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "CHECKBOL"})
	Local nPedido  := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "PEDIDO"})
	Local nCliente := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "CODIGO"})
	Local nVolume  := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "VOLUME"})
	Local nRedeSP  := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "REDESP"})
	Local nProduto := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "PRODUTO"})
	Local nQTDE    := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "QTDE"})
	Local nREG     := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "REGISTRO"})


	Local vPedido,vcliente
	Local nLinha   := 0
	Local cflag
	Local aTMP := {}

	if Len(aColsAux) <= 1
		MsgStop('Aten็ใo, Buscar Produtos antes de Produzir!')
		return()
	EndIf

	For nLinha := 1 To Len(aColsAux)
		cflag = (aColsAux[nLinha][nFlag] )
		if cflag == "LBOK"
			vPedido  := AllTrim(aColsAux[nLinha]  [nPedido])
			vcliente := AllTrim(aColsAux[nLinha]  [nCliente])
			vProduto := AllTrim(aColsAux[nLinha]  [nProduto])
			vVolume  := AllTrim(aColsAux[nLinha]  [nVolume])
			vQTDE    := AllTrim(aColsAux[nLinha]  [nQTDE])
			vRedeSP  := AllTrim(aColsAux[nLinha]  [nRedeSP])
			vREG     := AllTrim(aColsAux[nLinha]  [nREG])

			aAdd(aTMP, { ;
				vProduto,;
				vPedido,;
				vcliente,;
				vQTDE,;
				vVolume,;
				vRedeSP,;
				vREG;
				})
		end
	Next
	if len(aTMP) < 1
		MsgStop('Necessแrio selecionar um item !','Produzir')
		return()
	EndIf

	PCP031_05(aTMP)

return


/*/{Protheus.doc} PCP031_05
Inseri dados nas tabelas Especificos e Espedidos
@type function
@author neliedercorneta
@since 15/12/2021
@param aColsAux, array, matriz contendo os dados selecionads
/*/
Static Function PCP031_05(aColsAux)
	Local nLinha
	//Local GeraRec  := "0"
	Local PriID  := 0
	Local pProduto := '0' // proximo
	Local vProduto := '0' // atual
	Local aProduto := '0' // anterior

	PriID = last_rec('ESPEPEDIDOS')
	For nLinha := 1 To Len(aColsAux)
		vProduto := AllTrim(aColsAux[nLinha]    [1])

		if (Len(aColsAux)) > nLinha
			pProduto := AllTrim(aColsAux[nLinha+1]  [1])
		else
			aProduto := '0'
		EndIf

		if (nLinha > 1)
			aProduto := AllTrim(aColsAux[nLinha-1]  [1])
		else
			aProduto := '0'
		Endif

		vPedido  := AllTrim(aColsAux[nLinha]    [2])
		vcliente := AllTrim(aColsAux[nLinha]    [3])
		vQTDE    := AllTrim(aColsAux[nLinha]    [4])
		vVolume  := AllTrim(aColsAux[nLinha]    [5])
		vRedeSP  := AllTrim(aColsAux[nLinha]    [6])
		vRG      := AllTrim(aColsAux[nLinha]    [7])

		if SUBSTRING(vProduto,1,10) != SUBSTRING(aProduto,1,10)
			//GeraRec := '0'
			MaxReg   := last_rec('ESPEPEDIDOS')
		endif	

		cQuery := ""
		cQuery := " INSERT INTO ESPEPEDIDOS (EMPRESA,CLIENTE,VOLUME,REDESP,PEDIDO,EMBAL,QUANT,ID) VALUES "
		cQuery += " ('"+ALLTRIM(cNumEmp)+"','"+vcliente+"','"+cValToChar(vVolume)+"','"+vRedeSP+"','"+vPedido+"','"+vProduto+"','"+cValToChar(vQTDE)+"','"+cValToChar(MaxReg)+"') "

		cQuery += " INSERT INTO "+RETSQLNAME("ZA6")+" (ZA6_FILIAL,ZA6_EMPRES,ZA6_CLIENT,ZA6_VOLUME,ZA6_REDESP,ZA6_PEDIDO,ZA6_EMBAL,ZA6_QUANT,ZA6_ID,R_E_C_N_O_) VALUES
		cQuery += " ('"+xFilial("ZA6")+"','"+ALLTRIM(cNumEmp)+"','"+vcliente+"','"+cValToChar(vVolume)+"','"+vRedeSP+"','"+vPedido+"','"+vProduto+"','"+cValToChar(vQTDE)+"','"+cValToChar(MaxReg)+"',(SELECT CASE WHEN MAX(R_E_C_N_O_)+1  IS NULL THEN 0 ELSE MAX(R_E_C_N_O_)+1 end FROM "+RETSQLNAME("ZA6")+")) "

		nStatus := TCSqlExec(cQuery)

		if (nStatus < 0)
			MsgAlert("TCSQLError() " + TCSQLError())
			return()
		endif

	/*	if (SUBSTRING(vProduto,1,10) == SUBSTRING(pProduto,1,10)) .OR. (SUBSTRING(vProduto,1,10) == SUBSTRING(aProduto,1,10))
    
			if GeraRec == '0'
				MaxReg   := last_rec('ESPEPEDIDOS')
			EndIf

			cQuery := ""
			cQuery := " INSERT INTO ESPEPEDIDOS (EMPRESA,CLIENTE,VOLUME,REDESP,PEDIDO,EMBAL,QUANT,ID) VALUES "
			cQuery += " ('"+ALLTRIM(cNumEmp)+"','"+vcliente+"','"+cValToChar(vVolume)+"','"+vRedeSP+"','"+vPedido+"','"+vProduto+"','"+cValToChar(vQTDE)+"','"+cValToChar(MaxReg)+"') "

			cQuery += " INSERT INTO "+RETSQLNAME("ZA6")+" (ZA6_FILIAL,ZA6_EMPRES,ZA6_CLIENT,ZA6_VOLUME,ZA6_REDESP,ZA6_PEDIDO,ZA6_EMBAL,ZA6_QUANT,ZA6_ID,R_E_C_N_O_) VALUES
			cQuery += " ('"+xFilial("ZA6")+"','"+ALLTRIM(cNumEmp)+"','"+vcliente+"','"+cValToChar(vVolume)+"','"+vRedeSP+"','"+vPedido+"','"+vProduto+"','"+cValToChar(vQTDE)+"','"+cValToChar(MaxReg)+"',(SELECT CASE WHEN MAX(R_E_C_N_O_)+1  IS NULL THEN 0 ELSE MAX(R_E_C_N_O_)+1 end FROM "+RETSQLNAME("ZA6")+")) "

			nStatus := TCSqlExec(cQuery)

			if (nStatus < 0)
				MsgAlert("TCSQLError() " + TCSQLError())
				return()
			endif


			GeraRec = '1'

		else

			GeraRec = '0'
			MaxReg   := last_rec('ESPEPEDIDOS')
			cQuery := ""
			cQuery := " INSERT INTO ESPEPEDIDOS (EMPRESA,CLIENTE,VOLUME,REDESP,PEDIDO,EMBAL,QUANT,ID) VALUES "
			cQuery += " ('"+ALLTRIM(cNumEmp)+"','"+vcliente+"','"+cValToChar(vVolume)+"','"+vRedeSP+"','"+vPedido+"','"+vProduto+"','"+cValToChar(vQTDE)+"','"+cValToChar(MaxReg)+"') "

			cQuery += " INSERT INTO "+RETSQLNAME("ZA6")+" (ZA6_FILIAL,ZA6_EMPRES,ZA6_CLIENT,ZA6_VOLUME,ZA6_REDESP,ZA6_PEDIDO,ZA6_EMBAL,ZA6_QUANT,ZA6_ID,R_E_C_N_O_) VALUES
			cQuery += " ('"+xFilial("ZA6")+"','"+ALLTRIM(cNumEmp)+"','"+vcliente+"','"+cValToChar(vVolume)+"','"+vRedeSP+"','"+vPedido+"','"+vProduto+"','"+cValToChar(vQTDE)+"','"+cValToChar(MaxReg)+"',(SELECT CASE WHEN MAX(R_E_C_N_O_)+1  IS NULL THEN 0 ELSE MAX(R_E_C_N_O_)+1 end FROM "+RETSQLNAME("ZA6")+")) "

			nStatus := TCSqlExec(cQuery)

			if (nStatus < 0)
				MsgAlert("TCSQLError() " + TCSQLError())
				return()
			endif

		EndIf*/


		PCP031_06(vRG)
	Next
    
	PCP031_07(PriID)

Return

/*/{Protheus.doc} PCP031_07
Gera Ordem de Produ็ใo
@type function
@author neliedercorneta
@since 15/12/2021
@param ID, variant, ID para Gera็ใo da OP
/*/
Static Function PCP031_07(ID)

	Local cEmissao := DToS(dDataBase)
	Local cQuery := ""

	IF Select("QRY_SBM") <> 0
		DbSelectArea("QRY_SBM")
		DbCloseArea()
	ENDIF

	cQuery := " SELECT ID,EMBAL FROM ESPEPEDIDOS WHERE ID >= "+cValToChar(ID)+" GROUP BY ID,EMBAL ORDER BY ID  "

	TCQuery cQuery New Alias "QRY_SBM"


	//Setando o tamanho da r้gua
	Count To nTotal
	ProcRegua(nTotal)

	//Enquanto houver dados
	QRY_SBM->(DbGoTop())
	While !QRY_SBM->(EoF())

		cQuery := ""
		cQuery := " INSERT INTO ESPECIFICOS (EMISSAO,PRODUTO,QUANT,LOTE,EMPRESA,ID) VALUES "
		cQuery += " ('"+cEmissao+"','"+QRY_SBM->EMBAL+"','0','','"+ALLTRIM(cNumEmp)+"','"+QRY_SBM->ID+"') "

		cQuery += " INSERT INTO "+RETSQLNAME("ZA5")+" (ZA5_FILIAL,ZA5_EMISSA,ZA5_PRODUT,ZA5_QUANT,ZA5_LOTE,ZA5_EMPRES,ZA5_ID,R_E_C_N_O_) VALUES "
		cQuery += " ('"+xFilial("ZA5")+"','"+cEmissao+"','"+QRY_SBM->EMBAL+"','0','','"+ALLTRIM(cNumEmp)+"','"+QRY_SBM->ID+"',(SELECT CASE WHEN MAX(R_E_C_N_O_)+1  IS NULL THEN 0 ELSE MAX(R_E_C_N_O_)+1 end FROM "+RETSQLNAME("ZA5")+"))

		nStatus := TCSqlExec(cQuery)

		if (nStatus < 0)
			MsgAlert("TCSQLError() " + TCSQLError())
			return()
		endif




		QRY_SBM->(DbSkip())

	EndDo

	/* alterado em 17/03/2022
	//Processa({|| U_BRPCP035()}, "Gerando OPs Especificos, esse processo pode demorar... !")

    /* refresch no grid */
	PCP031_02(1)

	MsgAlert('Inserido '+cValToChar(nTotal)+' produto(s) com Sucesso !')

return


/*/{Protheus.doc} PCP031_06
Atualiza o campo C6_XESPECI no Pedido
@type function
@author neliedercorneta
@since 15/12/2021
@param RECNO, variant, R_E_C_N_O_ do registro selecionado
/*/
Static Function PCP031_06(RECNO)

	local cQuery := ""

	cQuery := " UPDATE "+RetSqlName("SC6")+" SET C6_XESPECI = 1 WHERE R_E_C_N_O_ = "+RECNO+" "

	nStatus := TCSqlExec(cQuery)

	if (nStatus < 0)
		MsgAlert("TCSQLError() " + TCSQLError())
		return()
	endif

return


Static Function last_rec(Tabela)
	local cQuery1

	IF Select("TM_LAST") <> 0
		DbSelectArea("TM_LAST")
		DbCloseArea()
	ENDIF

	cQuery1 := "SELECT MAX(ID)+1 AS ID FROM "+Tabela+" WITH (NOLOCK)"
	TCQuery cQuery1 New Alias "TM_LAST"

	TM_LAST->(DbGoTop())

return(TM_LAST->ID)

/* UPD_SC6 */
Static Function UPD_SC6(cPedido)
	local cQuery

	cQuery := " UPDATE "+RetSqlName("SC6")+" SET C6_XESPECI = 1 WHERE R_E_C_N_O_ = '"+cPedido+"' "
	TCSQLEXEC(cQuery)

return

Static Function GravaSQL(script)

	Local cArq := ""


	cArq := "C:\Temp\sql.txt" //a pasta deve ser vแlida.


	MemoWrite ( cArq , script )


Return
