#Include "Protheus.ch"
#Include "TopConn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP039  ºAutor  ³ Nelieder Corneta  º Data ³  17/01/2022 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Etiquetas p/ Volumes (BrasTintas)                           ±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
 
User Function  BRPCP039()

//Fontes
Private cFontUti  := "Tahoma"
Private oFontAno  := TFont():New(cFontUti, , -38)
Private oFontBtn  := TFont():New(cFontUti, , -14)
Private oFontBtnn  := TFont():New(cFontUti, , -14, ,.T.)
Private oFontSub  := TFont():New(cFontUti, , -16)
Private oFontSubN := TFont():New(cFontUti, , -20, , .T.)

//Tamanho da Janela
Private nJanLarg  := 475
Private nJanAltu  := 400

/* bordero de pedidos */
Private cBordero1 := SPACE(6)
Private oBordero1

/* data bordero */
Private oDtBord1,oDtBord2
Private dDtBord1 := cTod("  /  /  ")
Private dDtBord2 := cTod("  /  /  ")

/* pedido */
Private oPedido1,oPedido2
Private cPedido1 := SPACE(6)
Private cPedido2 := SPACE(6)

/* bordero despacho */
Private cBordesp := SPACE(6)
Private oBordesp

/* produtos */
Private cProd1 := SPACE(12)
Private cProd2 := SPACE(12)
Private oProd1,oProd2

/* imprimi nº Pedido */
Private  oChkBox, lCheck := .F.

/* tamanho etiqueta */
Private  oTM, cTM 

/* tamanho etiqueta */
Private  oOrdem, cOrdem 

/* qtd etiquetas */
Private  oQtd, cQtd 

/* quadrante */
Private cLocaliz1 := SPACE(12)
Private cLocaliz2 := SPACE(12)
Private oLocaliz1,oLocaliz2

Private oLPT,cLPT
Private aLPT      :={}

DEFINE MSDIALOG oDlg TITLE "Estiquetas de Volumes" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

@ 010, 010 SAY OemToAnsi("Nº do Borderô Pedido.: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 008, 090 MSGET oBordero1 VAR cBordero1 PICTURE "@!" SIZE 050,010 COLOR CLR_BLUE F3 "SZF" PIXEL VALID ValBord() OF  oDlg FONT oFontBtn

/*054008*/
@ 029, 010 SAY OemToAnsi("Dt do Borderô Ped.: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 028, 090 MSGET oDtBord1 VAR dDtBord1 SIZE 050,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn
@ 029, 150 SAY OemToAnsi(" Até ") SIZE 060,009 PIXEL OF oDlg FONT oFontBtn
@ 028, 180 MSGET oDtBord2 VAR dDtBord2 SIZE 050,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

@ 047, 010 SAY OemToAnsi("Nro Bord. DESPACHO") SIZE 080,009 PIXEL  OF oDlg FONT oFontBtn
@ 048, 090 MSGET oBordesp VAR cBordesp SIZE 050,010 COLOR CLR_BLUE F3 "SZA" PIXEL VALID ValBordSP() OF oDlg FONT oFontBtn


@ 065, 010 SAY OemToAnsi("Pedido .: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 064, 090 MSGET oPedido1 VAR cPedido1 SIZE 050,010 COLOR CLR_BLUE F3 "SC5" PIXEL OF oDlg FONT oFontBtn
@ 065, 150 SAY OemToAnsi(" Até ") SIZE 060,009 PIXEL OF oDlg FONT oFontBtn
@ 064, 180 MSGET oPedido2 VAR cPedido2 SIZE 050,010 COLOR CLR_BLUE F3 "SC5" PIXEL OF oDlg FONT oFontBtn


/* campos desabilitados - Mirinho informou que não são utilizados */
@ 083, 010 SAY OemToAnsi("Produto de .: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 084, 090 MSGET oProd1 VAR cProd1 SIZE 050,010 COLOR CLR_BLUE F3 "SB1" PIXEL OF oDlg FONT oFontBtn When .F.
@ 083, 150 SAY OemToAnsi(" Até ") SIZE 060,009 PIXEL OF oDlg FONT oFontBtn
@ 084, 180 MSGET oProd2 VAR cProd2 SIZE 050,010 COLOR CLR_BLUE F3 "SB1" PIXEL OF oDlg FONT oFontBtn When .F.

@ 101, 010 SAY OemToAnsi("Quadrante de .: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 102, 090 MSGET oLocaliz1 VAR cLocaliz1 SIZE 050,010 COLOR CLR_BLUE F3 "LOCALI" PIXEL OF oDlg FONT oFontBtn
@ 101, 150 SAY OemToAnsi(" Até ") SIZE 060,009 PIXEL OF oDlg FONT oFontBtn
@ 102, 180 MSGET oLocaliz2 VAR cLocaliz1 SIZE 050,010 COLOR CLR_BLUE F3 "LOCALI" PIXEL OF oDlg FONT oFontBtn

/* lista as portas de impressoras disponiveis */
@ 125, 010 SAY OemToAnsi("Porta\Impressora") SIZE 100,009 PIXEL OF oDlg FONT oFontBtn
@ 125, 090 MSCOMBOBOX oLPT VAR cLPT ITEMS aLPT SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL FONT oFontBtn
ListPort()

cQtd := 0
@ 143, 010 SAY OemToAnsi("Qtd Etiq por Pedido..:") SIZE 090,009 PIXEL OF oDlg FONT oFontBtn
@ 142, 090 MSGET oQtd VAR cQtd PICTURE "999" SIZE 050,010 COLOR CLR_BLUE PIXEL OF oDlg FONT oFontBtn

@ 162, 010 CHECKBOX oChkBox VAR lCheck PROMPT "Imprimir Nro Pedido" SIZE 90,15 OF oDlg FONT oFontBtnn PIXEL


/* desabilitado pois o sistema possui apenas um tamanho de etiqueta */
/*@ 143, 010 SAY OemToAnsi("Tamanho Etiq .: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 144, 090 MSCOMBOBOX oTM VAR cTM ITEMS {'80x45'} SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL FONT oFontBtn*/

/* desabilitado pois mirinho não utiliza essa função */
/*@ 161, 010 SAY OemToAnsi("Ordem .: ") SIZE 080,009 PIXEL OF oDlg FONT oFontBtn
@ 162, 090 MSCOMBOBOX oOrdem VAR cOrdem ITEMS {'Pedido','Quadrante','Embalagem'} SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL FONT oFontBtn*/

nlinha := 20

/* botões */
@ 200-nlinha,004 BUTTON oBtnFech PROMPT "Imprimir" SIZE 060, 018 OF oDlg ACTION Zebra() FONT oFontBtn PIXEL
@ 200-nlinha,090 BUTTON oBtnFech PROMPT "Visualizar" SIZE 060, 018 OF oDlg ACTION ReportPrint() FONT oFontBtn PIXEL
@ 200-nlinha,173 BUTTON oBtnFech PROMPT "Fechar" SIZE 060, 018 OF oDlg ACTION (oDlg:End()) FONT oFontBtn PIXEL


oDlg:lEscClose := .T.

ACTIVATE MSDIALOG oDlg CENTERED

Return



return()


/*/{Protheus.doc} pesquisar
Pesquisa query
@type function
@author neliedercorneta
@since 17/01/2022
/*/
static Function pesquisar()

cQry  = " SELECT ISNULL(ZG_LOCALIZ,'') AS ZG_LOCALIZ,C9_PEDIDO,C9_CLIENTE,SC5.C5_VOLUME1,ISNULL(A1_NOME,'') AS A1_NOME,ISNULL(A1_MUN,'') AS A1_MUN,ISNULL(A1_EST,'') AS A1_EST," 
cQry += " ISNULL(A2_NOME,'') AS A2_NOME,ISNULL(A2_MUN,'') AS A2_MUN,ISNULL(A2_EST,'') AS A2_EST, A4_NOME,A4_REGIAO "

//cQry += " CODBARRA = CASE WHEN (B1PED.B1_TIPO = 'PA') AND (LEN(B1PED.B1_COD) = 12) AND (B1PED.B1_CODBAR > '') THEN '1'+B1_CODBAR ELSE '' END "


cQry += " FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) "

/* alterado em 15/07/2022 */
/*if !empty(cBordero1) .OR. !empty(dDtBord2)
	cQry += "RIGHT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON (SZG.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = '"+xFilial("SZG")+"') AND (C9_PEDIDO = RIGHT(ZG_PEDIDO,6)) "
	IF !empty(cBordero1)
		cQry += "AND (ZG_CODIGO = '"+cBordero1+"') "
	ENDIF 
	IF !empty(dDtBord2) 
		cQry += "LEFT OUTER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON (SZF.D_E_L_E_T_ <> '*') AND (ZF_FILIAL = '"+xFilial("SZF")+"') AND (ZG_CODIGO = ZF_CODIGO) "
	ENDIF 
ENDIF */

IF !EMPTY(cBordesp)
	cQry += "RIGHT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH (NOLOCK) ON (SZB.D_E_L_E_T_ <> '*') AND (ZB_FILIAL = '"+xFilial("SZB")+"') AND (ZB_CODIGO = '"+cBordesp+"') AND (C9_PEDIDO = RIGHT(ZB_PEDIDO,6)) "
ENDIF 
cQry += "LEFT OUTER JOIN "+RetSqlName("SB1")+" B1PED WITH (NOLOCK) ON (C9_FILIAL = B1PED.B1_FILIAL) AND (C9_PRODUTO = B1PED.B1_COD) AND (B1PED.D_E_L_E_T_ <> '*') "
cQry += "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (C9_CLIENTE = A1_COD) AND (SA1.D_E_L_E_T_ <> '*') AND (LEN(C9_CLIENTE) = 6) "
cQry += "LEFT OUTER JOIN "+RetSqlName("SA2")+" SA2 WITH (NOLOCK) ON (C9_CLIENTE = A2_COD) AND (SA2.D_E_L_E_T_ <> '*') AND (LEN(C9_CLIENTE) = 5) "

cQry += " LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) ON (SUBSTRING(C9_PRODUTO,4,2) = Z1_LINHA) "
cQry += " AND (SZ1.D_E_L_E_T_ <> '*') AND (Z1_FILIAL = '"+xFilial("SZ1")+"') "

cQry += " LEFT OUTER JOIN "+RETSQLNAME("SZG")+" SZG WITH (NOLOCK) ON (SZG.D_E_L_E_T_ <> '*') AND (ZG_FILIAL = C9_FILIAL) AND (C9_PEDIDO = RIGHT(ZG_PEDIDO,6)) "

cQry += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (C9_FILIAL = C5_FILIAL) AND (C9_PEDIDO = C5_NUM) AND (SC5.D_E_L_E_T_ <> '*') "
cQry += "LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH (NOLOCK) ON (SC5.C5_REDESP = A4_COD) AND (SA4.D_E_L_E_T_ <> '*') "
cQry += "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B2_FILIAL = '"+xFilial("SB2")+"') AND (B1PED.B1_COD = B2_COD) AND (B1PED.B1_LOCPAD = B2_LOCAL) "

/* incluido em 15/07/2022 */
if !empty(cBordero1) .OR. !empty(dDtBord2)
	IF !empty(dDtBord2) 
		cQry += "LEFT OUTER JOIN "+RetSqlName("SZF")+" SZF WITH (NOLOCK) ON (SZF.D_E_L_E_T_ <> '*') AND (ZF_FILIAL = '"+xFilial("SZF")+"') AND (ZG_CODIGO = ZF_CODIGO) "
	ENDIF 
ENDIF 

cQry += "WHERE "
cQry +=  "(SC9.D_E_L_E_T_ <>  '*') AND (SC9.C9_FILIAL = '"+xFilial('SC9')+"') AND (SC5.C5_APROVA = '1') AND (LEN(B2_LOCALIZ) > 0) "
if !empty(cPedido2) .and. (cPedido2 >= cPedido1)
	cQry +=  "AND (SC9.C9_PEDIDO BETWEEN '"+cPedido1+"' AND '"+cPedido2+"') "
ENDIF

/* incluido em 15/07/2022 */
if !empty(cBordero1) .OR. !empty(dDtBord2)
	IF !empty(cBordero1)
		cQry += "AND (ZG_CODIGO = '"+cBordero1+"') "
	ENDIF 
ENDIF 


IF !EMPTY(cLocaliz2)
	cQry +=  "AND (SB2.B2_LOCALIZ BETWEEN '"+ALLTRIM(cLocaliz1)+"' AND '"+cLocaliz2+"') "
endif
	

if !empty(cProd2) .and. (cProd2 >= cProd1)
	cQry += "AND (SC9.C9_PRODUTO >= '"+cProd1+"') AND (SC9.C9_PRODUTO <= '"+cProd2+"') "
endif

if !empty(dDtBord2)
	cQry += "AND SZF.ZF_EMISSAO BETWEEN '"+dtos(dDtBord1)+"' AND '"+dtos(dDtBord2)+"'"
endif

cQry += " GROUP BY C9_PEDIDO,C9_CLIENTE,SC5.C5_VOLUME1,A1_NOME,A1_MUN,A1_EST,  A2_NOME,A2_MUN,A2_EST,A4_NOME,A4_REGIAO,ZG_LOCALIZ "
cQry += " ORDER BY C9_PEDIDO"

/* verifica quem é o usuário */
    cUsuario = PswChave(RetCodUsr())
    if (cUsuario == 'neliedercorneta') 
        /* gera log do script sql */
        GravaSQL(cQry)
    Endif

 /* verifica se arquivo está aberto e finaliza */
    IF Select("QCON") <> 0
        DbSelectArea("QCON")
        DbCloseArea()
    ENDIF
    
    //TMPP QCON
    TCQUERY cQry NEW ALIAS "QCON"  
    //Count To nTotal 

    dbSelectArea("QCON")
    QCON->(dbGoTop())


return


/*/{Protheus.doc} ReportPrint
Impressão na Tela
@type function
@author neliedercorneta
@since 17/01/2022
/*/
Static Function ReportPrint()

Local cloop := 0
Local nloop := 0

Private oPrint
Private oFont10     := TFont():New('Arial',,10,,.F.,,,,.F.,.F.)
Private oFont10n    := TFont():New('Arial',,10,,.T.,,,,.F.,.F.)

pesquisar()
dbSelectArea("QCON")
QCON->(dbGoTop())

    oPrint := TMSPrinter():New(OemToAnsi('Etiqueta de produto'))
    oPrint:SetPortrait()
    
    oPrint:StartPage()  
    nLin  := 0050
    nRow1 := 0
    cPage := 0
    cont := 0
    col2 := 0
    ////TMSPrinter(): Line ( [ nTop], [ nLeft], [ nBottom], [ nRight], [ uParam5] ) -->
    
    //cPedido := ''
    While !QCON->(eof())
        nloop := QCON->C5_VOLUME1      

      //  if QCON->C9_PEDIDO == cPedido
           // QCON->(dbSkip())
        //else

        For cloop := 1 to nloop
               // cPedido := QCON->C9_PEDIDO 
                cPage++
                oPrint:Say(nLin,0110+col2,OemToAnsi('Pedido : '),oFont10,,,,0)

                if lCheck                    
                    oPrint:Say(nLin,0230+col2,OemToAnsi(Alltrim(QCON->C9_PEDIDO)),oFont10n,,,,0)
                endif    

                nLin += 040
                oPrint:Line (nLin,010+col2,nLin,900+col2)
                
                nLin  += 010
                oPrint:Say(nLin,0110+col2,OemToAnsi(Alltrim(QCON->A1_NOME)),oFont10n,,,,0)
                nLin += 040
                nRow1 += 091
                oPrint:Line (nLin,010+col2,nLin,900+col2)

                nLin  += 010
                oPrint:Say(nLin,0110+col2,OemToAnsi('Cidade'),oFont10,,,,0)
                oPrint:Say(nLin,0230+col2,OemToAnsi(Alltrim(QCON->A1_MUN)),oFont10n,,,,0)
                nLin += 040
                nRow1 += 091
                oPrint:Line (nLin,010+col2,nLin,900+col2)


                nLin  += 010
                oPrint:Say(nLin,0110+col2,OemToAnsi('REDESP'),oFont10,,,,0)
                oPrint:Say(nLin,0230+col2,OemToAnsi(Alltrim(QCON->A4_NOME)),oFont10n,,,,0)
                nLin += 040
                nRow1 += 091
                oPrint:Line (nLin,010+col2,nLin,900+col2)

                nLin  += 010
                oPrint:Say(nLin,0110+col2,OemToAnsi('Q VOL'),oFont10,,,,0)
                oPrint:Say(nLin,0230+col2,OemToAnsi(Alltrim(cValToChar(QCON->C5_VOLUME1))),oFont10n,,,,0)
                nLin += 040
                nRow1 += 091
                oPrint:Line (nLin,010+col2,nLin,900+col2)

                if col2 == 1000
                    col2 = 0
                     nLin := nLin + 250
                else
                    col2 = 1000
                    nLin := nLin - 250
                endif                    
        

                
        if cPage == 12
            oPrint:EndPage()
            cPage := 0
            nRow1 := 0
            nLin  := 0050
        endif            

        next 

  //  Endif
    

     QCON->(dbSkip())
    enddo 

    oPrint:Preview()
    oPrint:end()

return


/*/{Protheus.doc} Zebra
Impressão das Etiquetas
@type function
@author neliedercorneta
@since 17/01/2022
/*/
Static Function Zebra()
Local cModelo 	:= "ZEBRA"
Local cloop := 0
Local nloop := 0

pesquisar()

dbSelectArea("QCON")
QCON->(dbGoTop())

    
    While !QCON->(eof())
        nloop := QCON->C5_VOLUME1      
       
        if (cQtd > 0)
            nloop:= cQtd
        Endif
        
        For cloop := 1 to nloop

            MSCBPRINTER(cModelo, cLPT,,12,.F.,,,,,,.F.,)
            MSCBCHKSTATUS(.F.)
            MSCBBEGIN(1,6)

            
            /* Pedido e Codigo do Produto */
            MSCBSAY(03,04,"PEDIDO:","N","A","015,008")
            /* habilita impressão no nº do pedido */
            if lCheck                    
                MSCBSAY(14,03.5,Alltrim(QCON->C9_PEDIDO), "N", "0", "030,040") // negrito
            endif    

            MSCBLineH(00,7,190,3,'B')
            

            /* Nome do Cliente  */

            cCliente = Alltrim(QCON->A1_NOME)

            MSCBSAY(03,09,cCliente, "N", "0", "020,020") // negrito
            MSCBLineH(00,12,190,3,'B')

            /* Cidade */
            MSCBSAY(03,14,"Cidade: ","N","A","015,008") // negrito
            MSCBSAY(13,14,Alltrim(QCON->A1_MUN)+"-"+Alltrim(QCON->A1_EST), "N", "0", "020,020")
            MSCBLineH(00,17,190,3,'B')

            /* Transportadora */
            MSCBSAY(03,19,"REDESP: ","N","A","015,008")
            MSCBSAY(13,19,Alltrim(QCON->A4_NOME), "N", "0", "020,020")
            MSCBLineH(00,22,190,3,'B')

            /* volume */
            MSCBSAY(03,24,"Q VOL.: ","N","A","015,008")
            MSCBSAY(14,23.5,Alltrim(STR(QCON->C5_VOLUME1))+" L.: ", "N", "0", "030,040") // negrito
            MSCBLineH(00,27,190,3,'B')

            MSCBSAY(02,30,"Q:"+Alltrim(QCON->ZG_LOCALIZ),  "N", "0","40,70") // negrito
            MSCBEND()

            MSCBCLOSEPRINTER()

        next 

     QCON->(dbSkip())
    enddo 


return


/*/{Protheus.doc} GravaSQL
Grava Query no arquivo Texto para Validação
@type function
@author neliedercorneta
@since 17/01/2022
@param script, variant, query
/*/
Static Function GravaSQL(script)

Local cArq := ""


cArq := "C:\Temp\sql.txt" //a pasta deve ser válida.


MemoWrite ( cArq , script )


Return

/*/{Protheus.doc} ValBord
Validação do Campo Bordero
@type function
@author neliedercorneta
@since 17/01/2022
@return variant, verdadeiro ou falso
/*/
Static Function ValBord()


if Empty(cBordero1)
    return(.T.)
endif

cQuery := "SELECT ZF_FLAG FROM "+RetSqlName("SZF")+" WITH (NOLOCK)"
cQuery += "WHERE (D_E_L_E_T_ <> '*') AND "
cQuery += "(ZF_FILIAL = '"+xFilial("SZF")+"') AND "
cQuery += "(ZF_CODIGO = '"+ALLTRIM(cBordero1)+"') "

IF Select("TMP") <> 0
    DbSelectArea("TMP")
    DbCloseArea()
ENDIF

TCQUERY cQuery NEW ALIAS "TMP"  
Count To nTotal 
TMP->(dbGoTop())

 if nTotal < 1
    MsgAlert('Borderô Inexistente!', 'Atenção')
    return(.F.)
 endif

 IF !(TMP->ZF_FLAG $ 'E.P.T.R')
    MsgAlert('Este borderô não pode ser impresso ainda!', 'Atenção')
    return(.F.)
 Endif




return(.T.)

/*/{Protheus.doc} ValBordSP
Validação do Campo Bordero de Despacho
@type function
@author neliedercorneta
@since 17/01/2022
/*/
Static Function ValBordSP()

if Empty(cBordesp)
    return(.T.)
endif

cQuery := "SELECT R_E_C_N_O_ FROM "+RetSqlName("SZA")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND "
cQuery += "(ZA_FILIAL = '"+xFilial("SZA")+"') AND "
cQuery += "(ZA_CODIGO = '"+ALLTRIM(cBordesp)+"') "

if Select("TMP") <> 0
    DbSelectArea("TMP")
    DbCloseArea()
end

TCQUERY cQuery NEW ALIAS "TMP"  
Count To nTotal 
TMP->(dbGoTop())

 if nTotal < 1
    MsgAlert('Borderô Inexistente!', 'Atenção')
    return(.F.)
 endif

return(.T.)        

/*/{Protheus.doc} ListPort
Lista Portas de Impressões Disponiveis
@type function
@author neliedercorneta
@since 17/01/2022
/*/
Static function ListPort()
local i
local porta

for i := 1 to 9
	
	porta := "LPT"+CValToChar(i)

	if IsPrinter(Porta)
		  aAdd(aLPT,Porta)
		  oLPT:SetItems(aLPT)
	endif  
next

return
