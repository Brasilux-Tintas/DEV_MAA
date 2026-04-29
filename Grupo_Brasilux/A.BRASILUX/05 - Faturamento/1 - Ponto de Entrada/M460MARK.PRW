#Include "totvs.CH"
#INCLUDE "TOPCONN.CH"


 /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
  ฑฑบPrograma  ณ M460MARK บAutor  ณ Nelieder Corneta   บ Data ณ  01/01/23   บฑฑ
  ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
  ฑฑบDescri็ใo ณ Ponto de entrada utilizado para sinalizar pedidos -        บฑฑ
  ฑฑบ          ณ selecionados para bloquear produtos negativos.             บฑฑ
  ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
  ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
  ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/


User Function M460MARK()

Local cMark   := PARAMIXB[1] // MARCA UTILIZADA
Local lInvert := PARAMIXB[2] // SELECIONOU "MARCA TODOS"    
Local cQry    := ""
Local aBrowse := {}
Local cRet    := .T.

//Fontes
Local cFontUti  := "Tahoma"
Local oFontBtn  := TFont():New(cFontUti, , -14)

//Tamanho da Janela
Local nJanLarg  := 400
Local nJanAltu  := 250
Local _ZPPAR0116 := GetMV( "ZP_PAR0116" ) // Libera Bloqueio de Lotes


     /* Parametro que habilita o bloqueio por saldo negativo */
     if !GETMV("ZP_PAR0077") .OR. FWCodEmp() == '11'
          Return .T.
     EndIf



     cQry := " SELECT C9_PRODUTO,C9_LOCAL,SUM(C9_QTDLIB)C9_QTDLIB  FROM "+RetSqlName("SC9")+" SC9 "
     cQry += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_  <> '*' AND B1_COD = C9_PRODUTO AND B1_FILIAL = C9_FILIAL AND C9_NFISCAL = '' "
     cQry += " INNER JOIN "+RetSqlName("SC6")+" SC6 ON SC6.D_E_L_E_T_  <> '*' AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM AND B1_COD = C6_PRODUTO AND C6_FILIAL = C9_FILIAL "
     cQry += " INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.D_E_L_E_T_  <> '*' AND F4_CODIGO = C6_TES "
     cQry += " AND F4_ESTOQUE = 'S' "
     cQry += " WHERE SC9.D_E_L_E_T_  <> '*'  AND C9_FILIAL = '"+xFilial("SC9")+"' "
     
     If !lInvert

          cQry += " AND C9_OK = '"+cMark+"' "

     else

          cQry += " AND C9_X_FLAG = '"+RetCodUsr()+"' AND C9_OK <> '"+cMark+"' "

     EndIf          
     
     cQry += " GROUP BY C9_PRODUTO,C9_LOCAL "
     cQry += " ORDER BY C9_PRODUTO "


IF Select("TCQ") <> 0
	DbSelectArea("TCQ")
	DbCloseArea()
ENDIF

TCQuery cQry ALIAS "TCQ" NEW

dbSelectArea("TCQ")
TCQ->(dbGoTop())

While !TCQ->(EoF())

    DbSelectArea("SB2")
	DbSetorder(1)
	DbSeek(xFilial("SB2")+(TCQ->C9_PRODUTO)+(TCQ->C9_LOCAL))
	nSaldo := SB2->B2_QATU//SaldoSb2()
    
     iF (nSaldo-TCQ->C9_QTDLIB) < 0
        
        aAdd(aBrowse, { ;
            TCQ->C9_PRODUTO,;
            TCQ->C9_QTDLIB,;
            TCQ->C9_LOCAL,;
            SB2->B2_QATU;
        })
        
     EndIf

    TCQ->(DbSkip())

EndDo

If len(aBrowse) > 0 

    cRet := .F.
    
    DEFINE MSDIALOG oDlg TITLE "Produto com saldo Negativo, nใo serแ possivel prosseguir !" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

    @ 105,005 BUTTON oBtnFech PROMPT "Sair" SIZE 050, 015 OF oDlg ACTION oDlg:End() FONT oFontBtn PIXEL

    oBrowse  := TCBrowse():New(005, 004, 200, 080, , {'Produto','Qtd Liberar','Local','Saldo Atual'}, {20,20,20,20}, oDlg, , , , , , , oFontBtn, , , , , .F., , .T., , .F., , ,)

    // Seta vetor para a browse
    oBrowse:SetArray(aBrowse)

    // Monta a linha a ser exibina no Browse
    oBrowse:bLine  := {||{    aBrowse[oBrowse:nAt,01],;
                              aBrowse[oBrowse:nAt,02],;
                              aBrowse[oBrowse:nAt,03],;
                              aBrowse[oBrowse:nAt,04];
                            }}

    /* habilita fechar tela no botใo esc */
    oDlg:lEscClose := .T.

    ACTIVATE MSDIALOG oDlg CENTERED

EndIf    


     If _ZPPAR0116
          // Fun็ใo que verifica lote bloqueado
          cQry := " SELECT DISTINCT(ZZK_LOTE) LOTE  FROM "+RetSqlName("SC9")+" SC9 "
          cQry += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_  <> '*' AND B1_COD = C9_PRODUTO AND B1_FILIAL = C9_FILIAL AND C9_NFISCAL = '' "
          cQry += " INNER JOIN "+RetSqlName("SC6")+" SC6 ON SC6.D_E_L_E_T_  <> '*' AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM AND B1_COD = C6_PRODUTO AND C6_FILIAL = C9_FILIAL "
          cQry += " INNER JOIN "+RetSqlName("ZZK")+" ZZK ON ZZK.D_E_L_E_T_  <> '*' AND ZZK_PEDIDO = C9_PEDIDO AND ZZK_FILIAL = C9_FILIAL "
          cQry += " INNER JOIN "+RetSqlName("ZAE")+" ZAE ON ZAE.D_E_L_E_T_  <> '*' AND ZAE_LOTE = ZZK_LOTE AND ZAE_FILIAL = C9_FILIAL AND ZAE_TIPO = '1' "
          cQry += " WHERE SC9.D_E_L_E_T_  <> '*'  AND C9_FILIAL = '"+xFilial("SC9")+"' "
          
          If !lInvert

               cQry += " AND C9_OK = '"+cMark+"' "

          else

               cQry += " AND C9_X_FLAG = '"+RetCodUsr()+"' AND C9_OK <> '"+cMark+"' "

          EndIf          
          
          IF Select("TCL") <> 0
               DbSelectArea("TCL")
               DbCloseArea()
          ENDIF

          TCQuery cQry ALIAS "TCL" NEW
          Count To nTotal
          TCL->(DbGoTop())

          If nTotal > 0
               U_ZPCPC02(TCL->LOTE)
               cRet := .F.
          EndIf
          
     EndIf     



Return(cRet)
