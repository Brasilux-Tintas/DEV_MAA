#Include "Protheus.ch"
#Include "TopConn.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRPCP036  บAutor  ณ Nelieder Corneta  บ Data ณ  13/12/2021 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Estornar programa็ใo especificos                            ฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function BRPCP036()

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

    //Tamanho da Janela
    Private    nJanLarg    := 1200
    Private    nJanAltu    := 850

    Private oData
    Private cData := cTod("  /  /  ")
    cData := Date()

    Private oLote
    Private cLote := SPACE(6)
    


    Private FlagMarc := .F.

    //Fontes
    Private    cFontUti   := "Tahoma"
    Private    oFontAno   := TFont():New(cFontUti,,-38)
    Private    oFontSub   := TFont():New(cFontUti,,-16)
    Private    oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
    Private    oFontBtn   := TFont():New(cFontUti,,-14)
    //              Ttญtulo               Campo        Mรกscara Tamanho   Decimal    Valid         Usado      Tipo F3    Combo
    aAdd(aHeadSBM, {" ",                  "Leg"    ,   "@BMP"  , 002    , 0         , "   "     , "   "     , "C"       , "",    "V", "", "","", "V","S"})        
    aAdd(aHeadSBM, {"Produto",            "PRODUTO",    ""     , 020    , 0         , ".T."     , ".T."     , "C"       , "",    ""} )
    aAdd(aHeadSBM, {"Pedido",             "PEDIDO",     ""     , 015    , 0         , "   "     , ".T."     , "C"       , "",    ""} )
    aAdd(aHeadSBM, {"Codigo ",            "CODIGO",     ""     , 015    , 0         , "   "     , ".T."     , "C"       , "",    ""} )
    aAdd(aHeadSBM, {"Nome",               "NOME",       ""     , 080    , 0         , "   "     , ".T."     , "C"       , "",    ""} )
    aAdd(aHeadSBM, {"Qtde",               "QTDE",       ""     , 010    , 0         , "   "     , ".T."     , "C"       , "",    ""} )    
    aAdd(aHeadSBM, {"Estornar ?",         "CHECKBOL",   "@BMP" , 010    , 0         , "   "     , "   "     , "C"       , "",    "V", "", "","", "V","S"})            
    aAdd(aHeadSBM, {"Registro",           "REGISTRO",   ""    , 015    , 0         , "   "     , "   "     , "C"       , "",    ""} )
    aAdd(aHeadSBM, {"ID",                 "ID",         ""    , 015    , 0         , "   "     , "   "     , "C"       , "",    ""} )
    aAdd(aHeadSBM, {"Lote",               "LOTE",       ""    , 015    , 0         , "   "     , "   "     , "C"       , "",    ""} )

    
    
 
    //Cria็ใo da tela com os dados que serใo informados
    DEFINE MSDIALOG oDlgPvt TITLE "Estorno Produ็ใo de Produtos Especificos" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
    @ 006, (nJanLarg/2-001)-(0052*01.2) BUTTON oBtnFech  PROMPT "Fechar (ESC)"        SIZE 060, 018 OF oDlgPvt ACTION oDlgPvt:End()                               FONT oFontBtn PIXEL
    @ 006, (nJanLarg/2-001)-(0052*03) BUTTON oBtnPesq  PROMPT "Buscar Produtos (F5)"        SIZE 080, 018 OF oDlgPvt ACTION MsAguarde({|| PCP036_01(nTipo) },"Pesquisando...","Aguarde...")                               FONT oFontBtn PIXEL
    
	@ 008, (nJanLarg/2-001)-(0052*8.8) MSGET oLote VAR clote PICTURE "999999" SIZE 50,10 COLOR CLR_BLUE PIXEL OF oDlgPvt FONT oFontBtn
    @ 010, (nJanLarg/2-001)-(0052*9.3) SAY OemToAnsi("Lote: ") SIZE 060,009  PIXEL OF oDlgPvt FONT oFontSub

	@ 008, (nJanLarg/2-001)-(0052*10.8) MSGET oData VAR cData PICTURE "@!" SIZE 50,10 COLOR CLR_BLUE PIXEL OF oDlgPvt FONT oFontBtn
    @ 010, (nJanLarg/2-001)-(0052*11.3) SAY OemToAnsi("Dia: ") SIZE 060,009  PIXEL OF oDlgPvt FONT oFontSub
         
        //Grid dos grupos
        oMsGetSBM := MsNewGetDados():New(    029,;                //nTop      - Linha Inicial
                                            003,;                 //nLeft     - Coluna Inicial
                                            ((nJanAltu-50)/2)-3,; //nBottom   - Linha Final
                                            (nJanLarg/2)-3,;      //nRight    - Coluna Final
                                             GD_UPDATE,;          //nStyle    - Estilos para edi็ใo da Grid (GD_INSERT = Inclusใo de Linha; GD_UPDATE = Altera็ใo de Linhas; GD_DELETE = Exclusใo de Linhas)
                                            "AllwaysTrue()",;     //cLinhaOk  - Valida็ใo da linha
                                            ,;                    //cTudoOk   - Valida็ใo de todas as linhas
                                            "",;                  //cIniCpos  - Fun็ใo para inicializa็ใo de campos
                                            {('REGISTRO','ID','LOTES')},;          //aAlter    - Colunas que podem ser alteradas
                                            ,;                    //nFreeze   - N๚mero da coluna que serแ congelada
                                            9999,;                //nMax      - Mแximo de Linhas
                                            ,;                    //cFieldOK  - Valida็ใo da coluna
                                            ,;                    //cSuperDel - Valida็ใo ao apertar '+'
                                            ,;                    //cDelOk    - Valida็ใo na exclusใo da linha
                                            oDlgPvt,;             //oWnd      - Janela que ้ a dona da grid
                                            aHeadSBM,;            //aHeader   - Cabe็alho da Grid
                                            aColsSBM)             //aCols     - Dados da Grid
    
    oMsGetSBM:oBrowse:bLDblClick := {|| oMsGetSBM:EditCell(), FlagChec(oMsGetSBM,oMsGetSBM:oBrowse:ColPos)}    
    oMsGetSBM:oBrowse:nLinhas := 1.5   
    oMsGetSBM:oBrowse:SetCSS(;
            "QHeaderView::Section {font-weight: bold;} " +; //Cabeรงallho
            "QTableView { font-size: 14px; } "; //Grid
        )
                                   
    @ 403, 005  BUTTON oBtnSalv  PROMPT "Estornar (F8)"        SIZE 060, 018 OF oDlgPvt ACTION (PCP036_02())                     FONT oFontBtn PIXEL
    //@ 403, 005  BUTTON oBtnSalv  PROMPT "Estornar (F8)"        SIZE 060, 018 OF oDlgPvt ACTION (PCP036_03())                     FONT oFontBtn PIXEL
    @ 403, 480  BUTTON oBtnDesm  PROMPT "Desmarcar\Marcar Todos (F12)"        SIZE 115, 018 OF oDlgPvt ACTION desmarca()       FONT oFontBtn PIXEL
    
    SetKey( VK_F12, { || desmarca() } )
    SetKey( VK_F8, { || PCP036_02() } )
    SetKey( VK_F5, { || MsAguarde({|| PCP036_01(nTipo) },"Pesquisando...","Aguarde...")  } )
    
    
    oDlgPvt:lEscClose := .T.
    ACTIVATE MSDIALOG oDlgPvt CENTERED
     
    RestArea(aArea)
Return

 

Static Function PCP036_01(nTipo)

    /*
        nTipo = 1 todos os produtos
        nTipo = 2 Somente Especificos
    */
Local aArea  := GetArea()
Local cQuery   := ""
// Local nAtual := 0
Local nTotal := 0
//Local nLiberado := 0
//Local nFabric
//Local xVarProd
//Local cVarProd
Local leg

    /* imagem que representa checck */
Private     _oOk          := LoadBitmap( GetResources(), "CHECKED"   )
Private     _oNo          := LoadBitmap( GetResources(), "UNCHECKED" )
aColsSBM := {}


//Seleciona dados do documento de entrada
cQuery := " SELECT ESPECIFICOS.ID,ESPECIFICOS.PRODUTO,ESPEPEDIDOS.PEDIDO,ESPEPEDIDOS.QUANT AS QTDE,ESPECIFICOS.LOTE LOTE, "
cQuery += " C5_CLIENTE AS CLIENTE,A1_NOME AS RAZAO,SC6.R_E_C_N_O_ AS REG  "
cQuery += " FROM ESPECIFICOS WITH (NOLOCK)   "
cQuery += " LEFT OUTER JOIN ESPEPEDIDOS WITH (NOLOCK) ON ((ESPECIFICOS.ID = ESPEPEDIDOS.ID) AND (PRODUTO = EMBAL))   "
cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SC5")+" SC5 WITH (NOLOCK) ON ('"+xFilial("SC5")+"' = C5_FILIAL) AND (ESPEPEDIDOS.PEDIDO = C5_NUM) AND (SC5.D_E_L_E_T_ <> '*')   "
cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SC6")+" SC6 WITH (NOLOCK) ON ('"+xFilial("SC6")+"' = C6_FILIAL) AND (ESPEPEDIDOS.PEDIDO = C6_NUM) AND   "
cQuery += " (ESPEPEDIDOS.EMBAL = C6_PRODUTO) AND (SC6.D_E_L_E_T_ <> '*')   "
cQuery += " LEFT OUTER JOIN "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) ON (C5_CLIENTE = A1_COD) AND (SA1.D_E_L_E_T_ <> '*')   "
cQuery += " WHERE (ESPECIFICOS.EMPRESA = '"+ALLTRIM(cNumEmp)+"')   "
//cQuery += " AND (ESPECIFICOS.EMISSAO = '"+DTOS(cData)+"' ) AND (LEN(ESPECIFICOS.LOTE) = 0)  "
cQuery += " AND (ESPECIFICOS.EMISSAO = '"+DTOS(cData)+"' )   "

/* alterado em 17/03/2022 */
cQuery += " AND LOTE = ''    "

if  !Empty(cLote)
	cQuery += " AND LOTE = '"+clote+"'    "
endif	

cQuery += " ORDER BY ESPECIFICOS.PRODUTO "

IF Select("EST_TMP") <> 0
	DbSelectArea("EST_TMP")
	DbCloseArea()
ENDIF

cUsuario = PswChave(RetCodUsr())
if (cUsuario == 'neliedercorneta')
        /* gera log do script sql */
	GravaSQL(cQuery)
Endif


TCQuery cQuery New Alias "EST_TMP"

//Setando o tamanho da r้gua
Count To nTotal
ProcRegua(nTotal)

//Enquanto houver dados
EST_TMP->(DbGoTop())
nFabric = "LBNO"
While !EST_TMP->(EoF())
	//nAtual++

	qProd = EST_TMP->PRODUTO
	qPedi = EST_TMP->PEDIDO
	qClie = EST_TMP->CLIENTE
	qQtde = Padr(EST_TMP->QTDE, 3)

//            cValToChar(EST_TMP->REG),;
	aAdd(aColsSBM, { ;
		leg,;
		EST_TMP->PRODUTO,;
		EST_TMP->PEDIDO,;
		EST_TMP->CLIENTE,;
		EST_TMP->RAZAO,;
		Padr(EST_TMP->QTDE, 3),;
		nFabric,;
		cValToChar(EST_TMP->REG),;
		EST_TMP->ID,;
		EST_TMP->LOTE,;
		.F.;
		})

	EST_TMP->(DbSkip())

EndDo
EST_TMP->(DbGotop())
EST_TMP->(DbCloseArea())


RestArea(aArea)
// linhas visiveis
//oBrowse:nRowCount()
//MsgAlert(oMsGetSBM:oBrowse:nRowCount())
oMsGetSBM:SetArray(aColsSBM)
oMsGetSBM:oBrowse:Refresh()
AltLeg()

Return

Static Function FlagChec(oMsGetSBM,coluna)

	oMsGetSBM:aCols[oMsGetSBM:nAt,7] := iif(oMsGetSBM:aCols[oMsGetSBM:nAt,7] == 'LBOK','LBNO','LBOK')

Return

Static Function desmarca()

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

Static Function PCP036_02()
    If MsgYesNo('Confirma Estorno ?', 'Aten็ใo', 'ALERT')
		MsAguarde({|| PCP036_04() },"Iniciando estorno, aguarde...","Aguarde...") 
	Endif
return

/* registros selecionados */
Static Function PCP036_04()


	Local aColsAux := oMsGetSBM:aCols
	Local nFlag    := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "CHECKBOL"})
	Local nREG     := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "REGISTRO"})
	Local nID      := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "ID"})
    Local nLOTE    := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "LOTE"})


	Local nLinha   := 0
	Local cflag
	Local cSele    := 0
    Local nStatus  
	//Local aTMP := {}
	Local cQuery := ''

	For nLinha := 1 To Len(aColsAux)
		cflag = (aColsAux[nLinha][nFlag] )
		if cflag == "LBOK"
			cSele := 1
		endif
	Next

	if cSele == 0
		MsgStop('Aten็ใo, Selecione um item para o estorno !')
		return()
	EndIf

	For nLinha := 1 To Len(aColsAux)
		cflag = (aColsAux[nLinha][nFlag] )
		if cflag == "LBOK"
			vREG     := AllTrim(aColsAux[nLinha]  [nREG])
			vID      := AllTrim(aColsAux[nLinha]  [nID])
            vLOTE      := AllTrim(aColsAux[nLinha]  [nLOTE])

            cQuery   := "UPDATE "+RetSqlName("SC6")+" SET C6_XESPECI = 0 WHERE R_E_C_N_O_ ="+vREG+" "
			nStatus := TCSqlExec(cQuery)

			if (nStatus < 0)
				MsgAlert("TCSQLError() " + TCSQLError())
				return()
			endif

			cQuery   := "DELETE FROM ESPEPEDIDOS WHERE (EMPRESA = '"+cNumEmp+"') AND (ID = '"+vID+"') AND EMBAL "
			cQuery   += "IN(SELECT PRODUTO FROM ESPECIFICOS WHERE (EMPRESA = '"+cNumEmp+"') AND LOTE = '"+vLOTE+"' AND (ID = '"+vID+"'))"

			cQuery   += "DELETE FROM "+RetSqlName("ZA6")+" WHERE (ZA6_EMPRES = '"+cNumEmp+"') AND (ZA6_ID = '"+vID+"') AND ZA6_EMBAL "
			cQuery   += "IN(SELECT ZA5_PRODUT FROM "+RetSqlName("ZA5")+" WHERE (ZA5_EMPRES = '"+cNumEmp+"') AND ZA5_LOTE = '"+vLOTE+"' AND (ZA5_ID = '"+vID+"'))"
			nStatus  := TCSqlExec(cQuery)

			if (nStatus < 0)
				MsgAlert("TCSQLError() " + TCSQLError())
				return()
			endif

			cQuery   := "DELETE FROM ESPECIFICOS WHERE (EMPRESA = '"+cNumEmp+"') AND LOTE = '"+vLOTE+"' AND (ID = '"+vID+"')"
			cQuery   += "DELETE FROM "+RetSqlName("ZA5")+" WHERE (ZA5_EMPRES = '"+cNumEmp+"') AND ZA5_LOTE = '"+vLOTE+"' AND (ZA5_ID = '"+vID+"')"
			nStatus := TCSqlExec(cQuery)

			if (nStatus < 0)
				MsgAlert("TCSQLError() " + TCSQLError())
				return()
			endif

            
            cQuery   := "UPDATE "+RetSqlName("SZZ")+" SET D_E_L_E_T_ = '*' WHERE ZZ_LOTE = '"+vLOTE+"' "
			nStatus := TCSqlExec(cQuery)

			if (nStatus < 0)
				MsgAlert("TCSQLError() " + TCSQLError())
				return()
			endif
            MsProcTxt('Excluindo Ordem de Produ็ใo Aguarde... !')
            
			/* alterado em 17/03/2022 */
			//PCP036_03(vLOTE)

		end
	Next

	MsgAlert('Registro(s) excluido com Sucesso !')
	PCP036_01(2)
    


return



Static Function AltLeg()

	Local aColsAux := oMsGetSBM:aCols
	Local nLinha   := 0
	Local nFlag    := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "Leg"})
	Local nProd    := aScan(aHeadSBM, {|x| Alltrim(x[2]) == "PRODUTO"})
	Local Atual
	Local Anterior
	Local Proximo
	Local Continua := .F.



	//Percorrendo todas as linhas
	For nLinha := 1 To Len(aColsAux)

		Atual := SUBSTRING(aColsAux[nLinha][nProd],1,10)

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
		EndIf
	Next

return

Static Function GravaSQL(script)

	Local cArq := ""


	cArq := "C:\Temp\sql.txt" //a pasta deve ser vแlida.


	MemoWrite ( cArq , script )


Return


Static Function PCP036_03(clote)
Local aMATA650 := {} 
Private lMsErroAuto := .F.

IF Select("ESP") <> 0
	DbSelectArea("ESP")
	DbCloseArea()
ENDIF


SC2->(DbSetOrder(13))//FILIAL + LOTE
SC2->(DbSeek(xFilial("SC2")+clote))

msExecAuto({|x,Y| Mata650(x,Y)},aMATA650,5)

lMsErroAuto := .F.
If !lMsErroAuto
    MsProcTxt('Excluindo Ordem de Produ็ใo Aguarde...  !')
Else
    MsProcTxt('Erro!')
    MostraErro()
EndIf

return
