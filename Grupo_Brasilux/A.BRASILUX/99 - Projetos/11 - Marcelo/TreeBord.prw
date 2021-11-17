#INCLUDE "Colors.ch"
#include 'protheus.ch'
#include 'DBTREE.ch'
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function TreeBord()  
     Private cBordero :=space(140)
     Private cDescri
     Private cNumNf   :=space(6)
     Private oBordero, oDescri 
     Private oNumNf
     Private oCliente
     Private cFlag    := cFlagBip := 0
     Private cTransp  := space(7)
     Private oTransp 
     Private cLocalz
     Private oFont    := TFont():New( "MS Sans Serif", 0, -12, , .T., 0, , 700, .F., .F., , , , , , )

     DEFINE DIALOG oDlg TITLE "Consulta Bordero Bipados" FROM 10,10 TO 600,800 COLOR CLR_BLACK,CLR_WHITE PIXEL  
     DEFINE DBTREE odbTree FROM 20,00 TO 275,400 OF oDlg CARGO

            @ 004, 005 MSGET oBordero  VAR cBordero  SIZE  30, 012 OF oDlg  COLORS 0, 16777215 PIXEL FONT oFont When .t.
            @ 004, 040 MSGET oDescri  VAR cDescri  SIZE  140, 012 OF oDlg  COLORS 0, 16777215 PIXEL FONT oFont When .f.
            @ 275, 005 SAY "Legenda" SIZE  30, 012 OF oDlg  COLORS 0, 16777215 PIXEL
            @ 285, 005 BITMAP o2 RESNAME "BR_VERMELHO"	SIZE 16,16 NOBORDER PIXEL
            @ 285, 012 SAY " -Não bipado /Parcialmente Bipado" SIZE  120, 30 OF oDlg  COLORS 0, 16777215 PIXEL
            @ 285, 100 BITMAP o2 RESNAME "BR_AZUL"	SIZE 16,16 NOBORDER PIXEL
            @ 285, 107 SAY " -Pedido Bipado/Não tresferido" SIZE  100, 30 OF oDlg  COLORS 0, 16777215 PIXEL
            @ 285, 200 BITMAP o2 RESNAME "BR_VERDE"	SIZE 16,16 NOBORDER PIXEL
            @ 285, 207 SAY " -Bipado e transferido " SIZE  70, 30 OF oDlg  COLORS 0, 16777215 PIXEL

            oBordero:bLostFocus := {|| fCarPed( cBordero ) }

            TButton():New( 004, 260, "Gerar", oDlg,{|| MsgRun("Gerando dados !!", "Aguarde",{|| Consult(oDlg,cBordero,odbTree) } ) },30,012,,,.F.,.T.,.F.,,.F.,,,.F. )
            TButton():New( 004, 295, "Sair" , oDlg,{|| oDlg:End() },30,012,,,.F.,.T.,.F.,,.F.,,,.F. )    

     ACTIVATE DIALOG oDlg CENTER 

Return                                                                 	

Static Function fCarPed( cBordero )
       dbSelectArea("SZA")   
       dbsetorder(1)
       dbseek(xFilial("SZA")+Substr(cBordero,1,6))
       If Found()
          cDescri := ZA_DESCR
       EndIf  
       oDescri:Refresh()
Return

Static Function verBord( cBord, _nPos)
       Local cCodCli
       //Local n := 1
       Local n := _nPos

       dbSelectArea("SC5")   
       dbsetorder(1)
       dbseek(xFilial("SC5")+Substr(cBord,1,6))
       If Found()
          cCodCli := C5_CLIENTE
          cBipPed[n][4]  := C5_NOTA       
          cBipPed[n][5]  := C5_TRANSP  
          If !Empty(C5_XNROCOL) 
             cBipPed[n][8] := "Sim"
          Else
             cBipPed[n][8] := "Não"
          EndIf
          cBipPed[n][3]:= Posicione("SA1", 1, xFilial("SA1")+cCodCli,"A1_NOME") 
       Endif
Return

Static Function Consult( oDlg, cBordero, odbTree )
       Local _nX        := 0
       Local _nContPed  := 0 
       Local oFontTree  := TFont():New( "Courier New", 0, -12, , .T., 0, , 700, .F., .F., , , , , , )
       Private cPedidos := Array(200,2)
       Private cBip     := Array(1)
       Private cBips    := Array(200,5)
       Private cBipPed  := Array(200,8)
       Private cLastDate[1]
       Private x        := 1  
       Private CBIPT    := ""

       If cFlag == 1
          odbTree:DelItem()
       EndIf
       pegaped()
       consped()    
       cFlag := 1   
       j := p := 1       
       For _nX := 1 To Len( cPedidos )
           If !( cPedidos[_nX][1] == Nil )
              _nContPed++
           Endif
       Next
       x := _nContPed
       DBADDTREE odbTree PROMPT "Bordero"+space(10)+cBordero RESOURCE cBipT CARGO "#0001"
       odbTree:oFont := oFontTree
       //While j < x
       For _nX := 1 To _nContPed
             //DBADDITEM odbTree PROMPT TRANSFORM(cBipPed[j][2],"@E 999999")+SPACE(5)+SUBSTR(cBipPed[j][3],0,50)+SPACE(5)+TRANSFORM(cBipPed[j][4],"@E 999999999")+ SPACE(5)+TRANSFORM(cBipPed[j][5],"@E 99999")+SPACE(5)+cBipPed[j][6]+SPACE(5)+cBipPed[j][7]+SPACE(5)+cBipPed[j][8] RESOURCE cBipPed[j][1]  CARGO "#0003"
             DBADDITEM odbTree PROMPT TRANSFORM( cBipPed[_nX][2], "@E 999999" ) + SPACE(2) + SUBSTR( Alltrim( cBipPed[_nX][3] ) + space(40), 0, 40) + SPACE(2) + TRANSFORM( cBipPed[_nX][4], "@E 999999999" ) + SPACE(2) + TRANSFORM( cBipPed[_nX][5], "@E 99999" ) + SPACE(2) + cBipPed[_nX][6] + SPACE(2) + cBipPed[_nX][7] + SPACE(2) + cBipPed[_nX][8] RESOURCE cBipPed[_nX][1]  CARGO "#0003"
             //j++
       Next
       //EndDo
       odbTree:EndTree()

       dbSelectArea("TCQ")
       dbCloseArea()
Return()     

//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------

Static Function alertbip()
cLastDate[1] := TCQ->DATAFIM
i := 1
cCount := 0
cAuxPro := TCQ->C6_PRODUTO          
cValor:= cTotal:= cVerm:= cAzul:=0                             	
cLocalz := TCQ->ZG_LOCALIZ
 
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
   				cBips[i][1]	:= "BR_VERDE"
   			Else
				cBips[i][1]	:= "BR_AZUL" 
				cAzul := 1   
			EndIf  			
   		Else                     
   			cBips[i][1]	:= "BR_VERMELHO" 
   			cVerm := 1 
   		EndIf
   		i++ 
   		cValor := 0
    EndIf   	
EndDo
if cVerm == 0           
	If cAzul == 0
		cBip[1] := "BR_VERDE" 
		If cFlagBip < 2
			cFlagBip := 1
		EndIf
	Else 
		cBip[1] := "BR_AZUL"
		If cFlagBip < 3
			cFlagBip := 2
		EndIf
	EndIf              	
Else	                     
	cBip[1] := "BR_VERMELHO"
	cFlagBip := 3
EndIf
Return()

Static Function pegaped()
       //Local n, x
       Local _nCont := 1
	   Local cQuery:= "SELECT SUBSTRING(ZB_PEDIDO,3,6) AS PEDIDO, C5_TRANSP "

       cQuery += "FROM "+RetSqlName("SZB")+" SZB WITH (NOLOCK)"
       cQuery += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON C5_FILIAL= ZB_FILIAL AND SC5.D_E_L_E_T_ <> '*' AND C5_NUM =  SUBSTRING(ZB_PEDIDO,3,6) "
       cQuery += "WHERE ZB_FILIAL ='"+xFilial("SZB")+"' AND SZB.D_E_L_E_T_ <> '*' AND ZB_CODIGO = ('"+cBordero+"') "
       cQuery += "ORDER BY PEDIDO"
       TCQUERY cQuery ALIAS "TCQ" NEW

       DbSelectArea("TCQ")
       DbGotop()  

       While !Eof()
             //cPedidos[x][1] := TCQ->PEDIDO 
             //cPedidos[x][2] := TCQ->C5_TRANSP
             //x++
             cPedidos[ _nCont ][ 1 ] := TCQ->PEDIDO
             cPedidos[ _nCont ][ 2 ] := TCQ->C5_TRANSP
             _nCont++
             dbselectarea("TCQ")	 
             dbskip() 	
       EndDo   
       dbSelectArea("TCQ")                                        	
       dbCloseArea()           
Return()                           

Static Function consped()
       Local n
       For n:= 1 To Len( cPedidos )
           If !Empty(cPedidos[n][1])
              cQuery:= "SELECT C6_ITEM, C6_PRODUTO,len(C6_PRODUTO) as cProduto, C6_DESCRI,len(C6_DESCRI) as cDescri, C6_QTDVEN, ISNULL(ZZK_CODIGO, '-') AS ZZK_CODIGO, ISNULL(SUM(ZZK_QUANT),0) AS ZZK_QUANT, MAX(ZZJ_DTFIM) AS DATAFIM,ZG_LOCALIZ, "
              cQuery+= "CASE WHEN ZZJ_OBSPED <>'' THEN 'S' ELSE 'N' END AS ZZJ_TRANSF "
              cQuery+= "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "	
              cQuery+= "LEFT OUTER JOIN "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) ON ZZK_FILIAL = C6_FILIAL AND ZZK_PEDIDO = C6_NUM AND ZZK_PRODUT = C6_PRODUTO AND ZZK.D_E_L_E_T_ = '' "
              cQuery+= "LEFT OUTER JOIN "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZK_CODIGO = ZZJ_CODIGO AND ZZJ.D_E_L_E_T_ = '' "
              cQuery+= "LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON ZG_FILIAL = C6_FILIAL AND SUBSTRING(ZG_PEDIDO,3,6) = C6_NUM AND SZG.D_E_L_E_T_ = '' " 
              cQuery+= "WHERE C6_FILIAL ='"+xFilial("SC6")+"' AND SC6.D_E_L_E_T_ ='' "	
              cQuery+= "AND C6_NUM =('"+cPedidos[n][1]+"') "	
              If SUBSTR(cPedidos[n][2],0,5) == "00700" .OR. SUBSTR(cPedidos[n][2],0,5) == "00573"	
                 cQuery+= "AND SUBSTRING(C6_PRODUTO,4,2) NOT IN('55') "
              EndIf
              cQuery+= "GROUP BY C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_QTDVEN, ZZK_CODIGO,ZZJ_DTFIM ,ZG_LOCALIZ,ZZJ_OBSPED "
              cQuery+= "ORDER BY C6_ITEM, ZZK_CODIGO"

              TCQUERY cQuery ALIAS "TCQ" NEW                                                                                 	

              DbSelectArea("TCQ")
              alertbip()  

              cBipPed[n][1] := cBip[1] // Cor do pedido
              cBipPed[n][2] := cPedidos[n][1] // Numero do pedido
              verBord( cBipPed[n][2], n )                               	
              cDataFim := cLastDate[1]
              cBipPed[n][6] := Substr(cDataFim,7,2)+"/"+Substr(cDataFim,5,2)+"/"+Substr(cDataFim,1,4) 
              cBipPed[n][7] := cLocalz
              dbSelectArea("TCQ")
              dbCloseArea()
           EndIf
       Next
       If cFlagBip == 1
          cBipT := "BR_VERDE"
       ElseIf cFlagBip == 2
              cBipT := "BR_AZUL"
       Else
          cBipT := "BR_VERMELHO"
       EndIf
Return