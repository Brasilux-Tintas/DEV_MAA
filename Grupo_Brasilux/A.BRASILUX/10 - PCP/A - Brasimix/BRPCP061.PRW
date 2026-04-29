#include 'protheus.ch'
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRPCP061()  
Private cCodBar := space(20),oCodBar,oDlg 
Private cCodProd, cDescri, cLote, cPedido, cNota, cSerie, cLocal, cPallet, cBorPed, cBorDesp, cNome, cData, cHora
Private oFont:= TFont():New("Courier New",,-14,.T.)
Private oSay
DEFINE MSDIALOG oDlg TITLE "Consulta Codigo de Barra" FROM 000, 000 TO 350, 500 PIXEL   
oSay := TSay():New( 10, 10, {|| "Mensagem"},oDlg,, oFont,,,, .T., CLR_WHITE,CLR_RED ) 

@ 010, 010 SAY  "C�d Barra"  SIZE 052, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 005, 045 MSGET oCodBar VAR cCodBar SIZE 100, 010 OF oDlg  COLORS 0, 16777215 PIXEL When .t.
@ 005, 155 Button "Consultar" Size 030, 012 PIXEL OF oDlg Action(CONSCBAR(cCodBar))   
@ 005, 210 Button "Imprimir" Size 030, 012 PIXEL OF oDlg  Action(FGerEtq(Alltrim(cPedido)+' '+Alltrim(cCodProd)))

ACTIVATE MSDIALOG oDlg CENTERED
return                                          
Return Nil

Static Function CONSCBAR(cCodBar)

cQuery := "SELECT ZZK_CODIGO, ZZK_PRODUT, B1_DESC, ZZK_LOTE, ZZK_PEDIDO, C5_NOTA, C5_SERIE, ZG_CODIGO, ZG_LOCALIZ, ZB_CODIGO, ZH_NOME,ZZK_DATA, ZZK_HORA "
cQuery += "FROM "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) "
cQuery += "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL  = ZZK_FILIAL AND B1_COD = ZZK_PRODUT AND SB1.D_E_L_E_T_ ='' "
cQuery += "LEFT OUTER JOIN "+RetSqlName("ZZJ")+" ZZJ WITH(NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZJ_CODIGO = ZZK_CODIGO AND ZZJ.D_E_L_E_T_ ='' "
cQuery += "LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH(NOLOCK) ON ZG_FILIAL  = ZZK_FILIAL AND SUBSTRING(ZG_PEDIDO, 3,6) = ZZK_PEDIDO AND SZG.D_E_L_E_T_ ='' "
cQuery += "LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH(NOLOCK) ON ZB_FILIAL  = ZG_FILIAL AND ZB_PEDIDO = ZG_PEDIDO AND SZB.D_E_L_E_T_ ='' "
cQuery += "LEFT OUTER JOIN "+RetSqlName("SZH")+" SZH WITH(NOLOCK) ON ZH_FILIAL  = ZH_FILIAL AND ZH_CODIGO = ZZJ_USER AND SZH.D_E_L_E_T_ ='' "
cQuery += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON C5_FILIAL  = ZZK_FILIAL AND C5_NUM = ZZK_PEDIDO AND SC5.D_E_L_E_T_ ='' "
cQuery += "WHERE ZZK_CODBAR IN ('"+alltrim(cCodBar)+"') AND (ZZK_FILIAL = '"+xFilial("ZZK")+"') AND ZZK.D_E_L_E_T_ ='' AND ZZK_PEDIDO <> ''"

TCQUERY cQuery ALIAS "TCQ" NEW
DbSelectArea("TCQ")
DbGotop()

cCodProd := TCQ->ZZK_PRODUT
cDescri := TCQ->B1_DESC
cLote := TCQ->ZZK_LOTE
cPedido := TCQ->ZZK_PEDIDO
cNota := TCQ->C5_NOTA
cSerie := TCQ->C5_SERIE
cLocal := TCQ->ZG_LOCALIZ
cPallet := TCQ->ZZK_CODIGO
cBorPed := TCQ->ZG_CODIGO
cBorDesp := TCQ->ZB_CODIGO
cNome := TCQ->ZH_NOME
cData := SUBSTR(TCQ->ZZK_DATA,7,2)+'/'+SUBSTR(TCQ->ZZK_DATA,5,2)+'/'+SUBSTR(TCQ->ZZK_DATA,1,4)
cHora:=SUBSTR(TCQ->ZZK_HORA,1,2)+':'+SUBSTR(TCQ->ZZK_HORA,3,2)
DADOSBAR()

dbSelectArea("TCQ")
dbCloseArea()
Return Nil

Static Function DADOSBAR()

@ 030, 010 SAY oSay PROMPT cCodProd+space(1)+cDescri FONT oFont SIZE 400, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 050, 010 SAY oSay PROMPT "Lote: "+cLote+space(5)+"Pedido: "+cPedido+space(5)+"Nota: "+cNota+cSerie FONT oFont SIZE 400, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 070, 010 SAY oSay PROMPT "Local: "+cLocal+space(5)+"Pallet: "+cPallet FONT oFont SIZE 400, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 090, 010 SAY oSay PROMPT "Bord Pedido: "+cBorPed+	space(5)+"Bord Despacho: "+cBorDesp FONT oFont SIZE 400, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 110, 010 SAY oSay PROMPT "Bipado por: "+cNome FONT oFont SIZE 400, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 130, 010 SAY oSay PROMPT "Hora: "+cHora+space(5)+" Data: "+cData FONT oFont SIZE 400, 007 OF oDlg COLORS 0, 16777215 PIXEL
Return Nil            

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*Function  ³ FGerEtq() - Função que gera o arquivo txt contendo o produto e o*
*		  ³	Pedido para uma pasta local, será lido pelo programa que imprimi *
*		  ³	rá etiquetas de volume											 *
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function FGerEtq(cPedProduto)
	Local cLin      := ""
    Private cArqTxt := ""
    Private nHandle := ""
    Private nTamLin := 22
    Private cEOL    := "CHR(13)+CHR(10)"                                                                  
    cEOL := Trim(cEOL)
    cEOL := &cEOL
    
	cArqTxt += "C:\TEMP\etq"                                                 
	cArqTxt += SUBSTR(DTOS(DATE()),7,2)+SUBSTR(DTOS(DATE()),5,2)
	cArqTxt += SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)+".txt"

  	nHandle := FCREATE(cArqTxt)          
	cLin := Space(nTamLin)+cEOL  // Variavel para criacao da linha do registros para gravacao
   	cCpo := cPedProduto 
  	cLin := Stuff(cLin, 001, 022, cCpo)
   	If fWrite(nHandle, cLin, Len(cLin)) != Len(cLin)
       	If !MsgAlert("Ocorreu um erro na gravacao do arquivo da Etiqueta !","Atencao!")
           	Return
       	Endif
	Endif                                                                               
//FWrite(nHandle, cLin + CRLF)   
	FClose(nHandle)
Return
