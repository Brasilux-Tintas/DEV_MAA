#INCLUDE "Colors.ch"
#include 'protheus.ch'
#include 'DBTREE.ch'
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function MYTREE()  

Private cPedido  :=space(6)
Private cCliente :=space(150)
Private cNumNf   :=space(6)
Private oPedido 
Private oNumNf
Private oCliente
Private cFlag := 0
Private cTransp := space(7)
Private oTransp 
Private oAgend
Private cAgend
Private oPedEx
Private cPedEx

SetPrvt("oFont")
     u_zcfga01( 'MYTREE' ) //LGS#2021201 - Gravação de log de utilização da rotina
//oFont   := TFont():New( "MS Sans Serif", 0, -12, , .T., 0, , 700, .F., .F., , , , , , )
oFont   := TFont():New( 'Courier new', 0, -12, , .T., 0, , 700, .F., .F., , , , , , )

DEFINE DIALOG oDlg TITLE "Consulta Pedidos Bipados" FROM 10,10 TO 600,850 COLOR CLR_BLACK,CLR_WHITE PIXEL  
DEFINE DBTREE odbTree FROM 20,00 TO 275,450 OF oDlg CARGO

@ 004, 005 MSGET oPedido  VAR cPedido  SIZE  30, 012 OF oDlg  COLORS 0, 16777215 PIXEL FONT oFont When .t.
@ 004, 040 MSGET oCliente VAR cCliente SIZE 140, 012 OF oDlg  COLORS 0, 16777215 PIXEL FONT oFont When .t.
@ 004, 185 MSGET oNumnf   VAR cNumNf   SIZE  30, 012 OF oDlg  COLORS 0, 16777215 PIXEL FONT oFont When .t. 
@ 004, 220 MSGET oTransp   VAR cTransp   SIZE  30, 012 OF oDlg  COLORS 0, 16777215 PIXEL FONT oFont When .t.
@ 004, 255 MSGET oAgend   VAR cAgend   SIZE  30, 012 OF oDlg  COLORS 0, 16777215 PIXEL FONT oFont When .t.
@ 004, 285 MSGET oPedEx   VAR cPedEx   SIZE  60, 012 OF oDlg  COLORS 0, 16777215 PIXEL FONT oFont When .t.
@ 275, 005 SAY "Legenda" SIZE  30, 012 OF oDlg  COLORS 0, 16777215 PIXEL
@ 285, 005 BITMAP o2 RESNAME "BR_VERMELHO"	SIZE 16,16 NOBORDER PIXEL
@ 285, 012 SAY " -Não bipado /Parcialmente Bipado" SIZE  120, 30 OF oDlg  COLORS 0, 16777215 PIXEL
@ 285, 100 BITMAP o2 RESNAME "BR_AZUL"	SIZE 16,16 NOBORDER PIXEL
@ 285, 107 SAY " -Pedido Bipado/Não transferido" SIZE  100, 30 OF oDlg  COLORS 0, 16777215 PIXEL
@ 285, 200 BITMAP o2 RESNAME "BR_VERDE"	SIZE 16,16 NOBORDER PIXEL
@ 285, 207 SAY " -Bipado e transferido " SIZE  70, 30 OF oDlg  COLORS 0, 16777215 PIXEL

oPedido:bLostFocus := {|| fCarPed(cPedido) }

TButton():New( 004, 345, "Gerar", oDlg,{|| MsgRun("Gerando dados !!", "Aguarde",{|| Consult(oDlg,cPedido,odbTree) } ) },30,012,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 004, 375, "Sair" , oDlg,{|| oDlg:End() },30,012,,,.F.,.T.,.F.,,.F.,,,.F. )    

ACTIVATE DIALOG oDlg CENTER 

Return                                                                 	

Static Function fCarPed(cPedido)
Local cCodCli        
Local tQuery :=""

tQuery := "SELECT D_E_L_E_T_ AS Deletado,C5_CLIENTE,C5_NOTA,C5_TRANSP,C5_XNROCOL FROM SC5010 WHERE C5_NUM = '"+alltrim(cPedido)+"' AND (C5_FILIAL = '"+xFilial("SC5")+"') ORDER BY D_E_L_E_T_"
TCQUERY tQuery ALIAS "TMP" NEW
dbSelectArea("TMP")

If TMP->Deletado == "*"
	cPedEx := "Pedido foi Excluído" 
	cCodCli := TMP->C5_CLIENTE
	cNumNf  := TMP->C5_NOTA       
	cTransp  := TMP->C5_TRANSP
	If !Empty(TMP->C5_XNROCOL) 
		cAgend := "Sim"
	Else
	 	cAgend := "Não"
	EndIf
	cCliente:= Posicione("SA1", 1, xFilial("SA1")+cCodCli,"A1_NOME") 
Else
	dbSelectArea("SC5")   
	dbsetorder(1)
	dbseek(xFilial("SC5")+Substr(cPedido,1,6))
	if found()
	   cPedEx := ""
		cCodCli := C5_CLIENTE
		cNumNf  := C5_NOTA       
		cTransp  := C5_TRANSP
		If !Empty(C5_XNROCOL) 
			cAgend := "Sim"
		Else
		 	cAgend := "Não"
		EndIf
		cCliente:= Posicione("SA1", 1, xFilial("SA1")+cCodCli,"A1_NOME") 
	else
		Messagebox("Número de Pedido Inválido, Verifique!!!","Atenção...",48)
		cNumNf  :=Space(06)
		cCliente:=Space(140)
		cPedEx := Space(20)
		oPedido:SetFocus()
		DbSelectArea("TCQ")
		DbCloseArea()
	Endif

EndIF
dbSelectArea("TMP")
dbCloseArea()

oCliente:Refresh()
oNumNf:Refresh()
oTransp:Refresh()
oAgend:Refresh()  
oPedEx:Refresh()                

Return                          
Static Function Consult(oDlg,cPedido,odbTree)

Private cBip := Array(300)
Private cLastDate[1]

If cFlag == 1
	odbTree:DelItem()
EndIf
If cPedido <> ' ' 
	cQuery:= "SELECT C6_ITEM, C6_PRODUTO,len(C6_PRODUTO) as cProduto, C6_DESCRI,len(C6_DESCRI) as cDescri, C6_QTDVEN, ISNULL(ZZK_CODIGO, '-') AS ZZK_CODIGO, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, MAX(ZZJ_DTFIM)AS DATAFIM,ZG_LOCALIZ,ZZJ_USER AS USUARIO, "
	cQuery+= "CASE WHEN ZZJ_OBSPED <>'' THEN 'S' ELSE 'N' END AS ZZJ_TRANSF "
	cQuery+= "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "	
	cQuery+= "LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PEDIDO = C6_NUM AND ZZK_PRODUT = C6_PRODUTO  AND ZZK.D_E_L_E_T_ ='' "
	cQuery+= "LEFT OUTER JOIN "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZK_CODIGO = ZZJ_CODIGO AND ZZJ.D_E_L_E_T_ ='' "
	cQuery+= "LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON ZG_FILIAL = C6_FILIAL AND SUBSTRING(ZG_PEDIDO,3,6) = C6_NUM AND SZG.D_E_L_E_T_ ='' " 
	cQuery+= "WHERE C6_FILIAL ='"+xFilial("SC6")+"' AND SC6.D_E_L_E_T_ ='' "	
	cQuery+= "AND C6_NUM =('"+cPedido+"') "	
	If SUBSTR(cTransp,0,5) == "00700" .OR. SUBSTR(cTransp,0,5) == "00573"	
		cQuery+= "AND SUBSTRING(C6_PRODUTO,4,2) NOT IN('55') "
	EndIf
	cQuery+= "GROUP BY C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_QTDVEN, ZZK_CODIGO,ZZJ_DTFIM ,ZG_LOCALIZ,ZZJ_OBSPED,ZZJ_USER "
	cQuery+= "ORDER BY C6_ITEM, ZZK_CODIGO"    
	
	TCQUERY cQuery ALIAS "TCQ" NEW

	DbSelectArea("TCQ")
	alertbip()
    
	DbSelectArea("TCQ")
	DbGotop()  

    cDataFim := cLastDate[1]
	cDataFim :=	Substr(cDataFim,7,2)+"/"+Substr(cDataFim,5,2)+"/"+Substr(cDataFim,1,4)
	cFlag := 1   
	j := 2
    cAuxProd := TCQ->C6_PRODUTO
    DBADDTREE odbTree PROMPT PADR("Pedido"+space(10)+cPedido+" "+cDataFim+space(5)+TCQ->ZG_LOCALIZ,150)  RESOURCE cBip[1] CARGO "#0001"

	While !Eof()
		If cAuxProd == TCQ->C6_PRODUTO .AND. !EOF()
			DBADDTREE  odbTree PROMPT TCQ->C6_ITEM+Space(5)+PADR(TCQ->C6_PRODUTO,TamSx3("C6_PRODUTO")[1])+space(5)+PADR(TCQ->C6_DESCRI,TamSx3("C6_DESCRI")[1])+PADL(alltrim(Transform(TCQ->C6_QTDVEN,"@E 999999")),6) OPENED RESOURCE  cBip[j] CARGO "#0002"
			While !Eof() .AND. cAuxProd == TCQ->C6_PRODUTO   
				cUsuario := Posicione("SZH", 1, xFilial("SZH")+TCQ->USUARIO,"ZH_NOME")
				DBADDITEM odbTree PROMPT PADR(TCQ->ZZK_CODIGO,TamSx3("ZZK_CODIGO")[1])+" "+padl(alltrim(Transform(ZZK_QUANT,"@E 999999")),6)+SPACE(10)+PADR(cUsuario,30)	 RESOURCE "" CARGO "#0003" 
				dbselectarea("TCQ")	 
				dbskip() 
			EndDo
			cAuxProd := TCQ->C6_PRODUTO
			DBENDTREE odbTree 
			j++
		EndIf		
	EndDo                                                	
EndIf
odbTree:EndTree()

dbSelectArea("TCQ")
dbCloseArea()

Return()     

Static Function alertbip()
cLastDate[1] := TCQ->DATAFIM
i := 2

cAuxPro := TCQ->C6_PRODUTO
cValor:= cTotal:= cVerm:= cAzul:=0
 
While !Eof()
   	If cAuxPro == TCQ->C6_PRODUTO .AND. !EOF()   
   		While !Eof() .AND. cAuxPro == TCQ->C6_PRODUTO
   			cValor += TCQ->ZZK_QUANT
   			cTotal := TCQ->C6_QTDVEN 
   			dDataFim := TCQ->DATAFIM
   			cTransf := TCQ->ZZJ_TRANSF
   			dbselectarea("TCQ")	 
			dbskip() 
   		EndDo 
   		cAuxPro := TCQ->C6_PRODUTO
   		If cLastDate[1] < dDataFim 
   			cLastDate[1] := dDataFim
   		EndIf
   		If cTotal == cValor
   			If cTransf = 'S' 
   				cBip[i]	:= "BR_VERDE"
   			Else
				cBip[i]	:= "BR_AZUL" 
				cAzul := 1
			EndIf  			
   		Else                     
   			cBip[i]	:= "BR_VERMELHO" 
   			cVerm := 1
   		EndIf
   		i++ 
   		cValor := 0
   	EndIf   	
EndDo
if cVerm == 0           
	If cAzul == 0
		cBip[1] := "BR_VERDE"               	
	Else
		cBip[1] := "BR_AZUL"
	EndIf
Else	                     
	cBip[1] := "BR_VERMELHO"
EndIf

Return()
